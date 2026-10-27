#import "HSCaptureDeviceSession.h"
#import "HSFrameProcessor.h"
#import "HSThreadInvocationWrapper.h"
#import "QTCaptureDevice+QTECaptureDevice.h"
#import "SMKApplicationKitData.h"
#include <pthread.h>

// The shared sessions, by device set (weakly held: a session leaves when it
// goes).
static CFMutableDictionaryRef HSCaptureDeviceSessionsByDeviceSet = NULL;

static const void *HSCaptureDeviceSessionCopyDeviceSet(CFAllocatorRef aAllocator, const void *aSet)
{
    return CFSetCreateCopy(aAllocator, (CFSetRef)aSet);
}

// _openCaptureDevices closes the devices it lets go of.
static void HSCaptureDeviceSessionCloseDevice(CFAllocatorRef aAllocator, const void *aDevice)
{
    if ([(QTCaptureDevice *)aDevice isOpen])
        [(QTCaptureDevice *)aDevice close];
}

// Frame decay intervals (doubles, kept by value).
static const void *HSCaptureDeviceSessionRetainInterval(CFAllocatorRef aAllocator, const void *aInterval)
{
    double *interval = CFAllocatorAllocate(aAllocator, sizeof(double), 0);
    if (interval != NULL)
        *interval = *(const double *)aInterval;
    return interval;
}

static void HSCaptureDeviceSessionReleaseInterval(CFAllocatorRef aAllocator, const void *aInterval)
{
    CFAllocatorDeallocate(aAllocator, (void *)aInterval);
}

static CFStringRef HSCaptureDeviceSessionCopyIntervalDescription(const void *aInterval)
{
    return CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%f"), *(const double *)aInterval);
}

static Boolean HSCaptureDeviceSessionIntervalsAreEqual(const void *aInterval, const void *aInterval2)
{
    return *(const double *)aInterval == *(const double *)aInterval2;
}

static void HSCaptureDeviceSessionFindLongestInterval(const void *aIdentifier, const void *aInterval, void *aLongest)
{
    if (*(double *)aLongest < *(const double *)aInterval)
        *(double *)aLongest = *(const double *)aInterval;
}

static void HSCaptureDeviceSessionDelayDecayTimer(const void *aClass, const void *aTimer, void *aDelay)
{
    if (![(NSTimer *)aTimer isValid])
        return;
    NSDate *date = [[(NSTimer *)aTimer fireDate] addTimeInterval:*(double *)aDelay];
    if (date != nil)
        [(NSTimer *)aTimer setFireDate:date];
}

static void HSCaptureDeviceSessionDecayFrameNow(const void *aClass, const void *aTimer, void *aCapturedFrames)
{
    [(NSTimer *)aTimer invalidate];
    CFDictionaryRemoveValue((CFMutableDictionaryRef)aCapturedFrames, aClass);
}

static void HSCaptureDeviceSessionInvalidateTimer(const void *aClass, const void *aTimer, void *aContext)
{
    [(NSTimer *)aTimer invalidate];
}

static void HSCaptureDeviceSessionPreremoveFrameProcessor(const void *aClass, const void *aProcessor, void *aSession)
{
    [(HSCaptureDeviceSession *)aSession HSCaptureDeviceSession_preremoveFrameProcessor:(id)aProcessor];
}

static pthread_mutex_t *HSCaptureDeviceSessionCreateMutex(void)
{
    pthread_mutex_t *mutex = NSZoneMalloc(NULL, sizeof(pthread_mutex_t));
    if (mutex != NULL && pthread_mutex_init(mutex, NULL) != 0) {
        NSZoneFree(NULL, mutex);
        mutex = NULL;
    }
    return mutex;
}

static pthread_cond_t *HSCaptureDeviceSessionCreateCondition(void)
{
    pthread_cond_t *condition = NSZoneMalloc(NULL, sizeof(pthread_cond_t));
    if (condition != NULL && pthread_cond_init(condition, NULL) != 0) {
        NSZoneFree(NULL, condition);
        condition = NULL;
    }
    return condition;
}

static void HSCaptureDeviceSessionDestroyMutex(pthread_mutex_t *aMutex)
{
    if (aMutex == NULL)
        return;
    pthread_mutex_destroy(aMutex);
    NSZoneFree(NULL, aMutex);
}

static void HSCaptureDeviceSessionDestroyCondition(pthread_cond_t *aCondition)
{
    if (aCondition == NULL)
        return;
    pthread_cond_destroy(aCondition);
    NSZoneFree(NULL, aCondition);
}

// A capture session shared by the clients of a set of devices. Clients ask
// for frames by frame processor class; one processor of each class runs while
// it has clients (a processor may itself be a client of another processor),
// and its last frame stays available for a decay interval after its last
// client leaves. Frames arrive on capture threads; the client sets are
// guarded by a readers-writer lock (_clientsMutex), and a client leaving
// waits until no other thread is notifying it.
@implementation HSCaptureDeviceSession

+ (id)captureDeviceSessionForDeviceSet:(id)aSet
{
    if (HSCaptureDeviceSessionsByDeviceSet == NULL) {
        CFDictionaryKeyCallBacks keyCallBacks = kCFTypeDictionaryKeyCallBacks;
        keyCallBacks.retain = HSCaptureDeviceSessionCopyDeviceSet;
        HSCaptureDeviceSessionsByDeviceSet = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &keyCallBacks, &kCFEWeakObjectPointerDictionaryValueCallBacks);
        if (HSCaptureDeviceSessionsByDeviceSet == NULL)
            return nil;
    }
    HSCaptureDeviceSession *session = [(id)CFDictionaryGetValue(HSCaptureDeviceSessionsByDeviceSet, aSet) retain];
    if (session == nil) {
        session = [[self alloc] HSCaptureDeviceSession_initWithCaptureDeviceSet:aSet];
        if (session != nil)
            CFDictionaryAddValue(HSCaptureDeviceSessionsByDeviceSet, aSet, session);
    }
    return [session autorelease];
}

+ (id)captureDeviceSessionForDevice:(id)aDevice
{
    NSSet *set = [NSSet setWithObject:aDevice];
    if (set == nil)
        return nil;
    return [self captureDeviceSessionForDeviceSet:set];
}

+ (id)existingCaptureDeviceSessions
{
    CFIndex count = HSCaptureDeviceSessionsByDeviceSet != NULL ? CFDictionaryGetCount(HSCaptureDeviceSessionsByDeviceSet) : 0;
    if (count == 0)
        return [NSArray array];
    const void **sessions = NSZoneMalloc(NULL, count * sizeof(id));
    if (sessions == NULL)
        return nil;
    CFDictionaryGetKeysAndValues(HSCaptureDeviceSessionsByDeviceSet, NULL, sessions);
    NSArray *array = [NSArray arrayWithObjects:(id *)sessions count:count];
    NSZoneFree(NULL, sessions);
    return array;
}

// The session keeps frames for the longest interval any client asked for.
- (void)removeFrameDecayIntervalForClientIdentifier:(id)aIdentifier
{
    if (_clientIdentifierToCapturedFrameDecayIntervalMap == NULL)
        return;
    const void *value = NULL;
    if (!CFDictionaryGetValueIfPresent(_clientIdentifierToCapturedFrameDecayIntervalMap, aIdentifier, &value))
        return;
    double interval = *(const double *)value;
    CFDictionaryRemoveValue(_clientIdentifierToCapturedFrameDecayIntervalMap, aIdentifier);
    if (interval != _capturedFrameDecayInterval)
        return;
    double longest = 0.0;
    CFDictionaryApplyFunction(_clientIdentifierToCapturedFrameDecayIntervalMap, HSCaptureDeviceSessionFindLongestInterval, &longest);
    if (longest != _capturedFrameDecayInterval)
        [self HSCaptureDeviceSession_setCapturedFrameDecayInterval:longest];
}

- (void)setFrameDecayInterval:(double)aInterval forClientIdentifier:(id)aIdentifier
{
    double interval = aInterval;
    if (_clientIdentifierToCapturedFrameDecayIntervalMap == NULL) {
        CFDictionaryValueCallBacks valueCallBacks = {0, HSCaptureDeviceSessionRetainInterval, HSCaptureDeviceSessionReleaseInterval,
            HSCaptureDeviceSessionCopyIntervalDescription, HSCaptureDeviceSessionIntervalsAreEqual};
        _clientIdentifierToCapturedFrameDecayIntervalMap = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFCopyStringDictionaryKeyCallBacks, &valueCallBacks);
        if (_clientIdentifierToCapturedFrameDecayIntervalMap == NULL)
            return;
    }
    CFDictionarySetValue(_clientIdentifierToCapturedFrameDecayIntervalMap, aIdentifier, &interval);
    if (interval > _capturedFrameDecayInterval)
        [self HSCaptureDeviceSession_setCapturedFrameDecayInterval:interval];
}

- (double)frameDecayIntervalForClientIdentifier:(id)aIdentifier
{
    if (_clientIdentifierToCapturedFrameDecayIntervalMap == NULL)
        return 0.0;
    const double *interval = CFDictionaryGetValue(_clientIdentifierToCapturedFrameDecayIntervalMap, aIdentifier);
    return interval != NULL ? *interval : 0.0;
}

// The pending decay timers move by the change; no interval drops the frames
// waiting to decay at once.
- (void)HSCaptureDeviceSession_setCapturedFrameDecayInterval:(double)aInterval
{
    if (_frameProcessorClassToCapturedFrameMap != NULL) {
        pthread_mutex_lock((pthread_mutex_t *)_capturedFramesMutex);
        if (_frameProcessorClassToCapturedFrameDecayTimerMap != NULL) {
            if (aInterval != 0.0) {
                double delay = aInterval - _capturedFrameDecayInterval;
                CFDictionaryApplyFunction(_frameProcessorClassToCapturedFrameDecayTimerMap, HSCaptureDeviceSessionDelayDecayTimer, &delay);
            } else {
                CFDictionaryApplyFunction(_frameProcessorClassToCapturedFrameDecayTimerMap, HSCaptureDeviceSessionDecayFrameNow, _frameProcessorClassToCapturedFrameMap);
                CFDictionaryRemoveAllValues(_frameProcessorClassToCapturedFrameDecayTimerMap);
            }
        }
        pthread_mutex_unlock((pthread_mutex_t *)_capturedFramesMutex);
    }
    _capturedFrameDecayInterval = aInterval;
}

- (double)frameDecayInterval
{
    return _capturedFrameDecayInterval;
}

// The last frame of the processor class.
- (id)frameForFrameProcessorClass:(Class)aClass
{
    if (_frameProcessorClassToCapturedFrameMap == NULL)
        return nil;
    pthread_mutex_lock((pthread_mutex_t *)_capturedFramesMutex);
    id frame = [(id)CFDictionaryGetValue(_frameProcessorClassToCapturedFrameMap, aClass) retain];
    pthread_mutex_unlock((pthread_mutex_t *)_capturedFramesMutex);
    return [frame autorelease];
}

- (void)HSCaptureDeviceSession_beginReadingClients
{
    pthread_mutex_lock((pthread_mutex_t *)_clientsMutex);
    while (_isClientsWriteAccessPending)
        pthread_cond_wait((pthread_cond_t *)_clientsCondition, (pthread_mutex_t *)_clientsMutex);
    _clientsReadAccessCount++;
    pthread_mutex_unlock((pthread_mutex_t *)_clientsMutex);
}

- (void)HSCaptureDeviceSession_endReadingClients
{
    pthread_mutex_lock((pthread_mutex_t *)_clientsMutex);
    if (--_clientsReadAccessCount == 0)
        pthread_cond_signal((pthread_cond_t *)_clientsCondition);
    pthread_mutex_unlock((pthread_mutex_t *)_clientsMutex);
}

// Waits out the readers; returns holding _clientsMutex.
- (void)HSCaptureDeviceSession_beginWritingClients
{
    pthread_mutex_lock((pthread_mutex_t *)_clientsMutex);
    while (_isClientsWriteAccessPending)
        pthread_cond_wait((pthread_cond_t *)_clientsCondition, (pthread_mutex_t *)_clientsMutex);
    _isClientsWriteAccessPending = 1;
    while (_clientsReadAccessCount != 0)
        pthread_cond_wait((pthread_cond_t *)_clientsCondition, (pthread_mutex_t *)_clientsMutex);
    _isClientsWriteAccessPending = 0;
}

- (void)HSCaptureDeviceSession_endWritingClients
{
    pthread_cond_signal((pthread_cond_t *)_clientsCondition);
    pthread_mutex_unlock((pthread_mutex_t *)_clientsMutex);
}

// Called on a capture thread: keeps the frame and hands it to the clients of
// the processor's class still there, noting which thread notifies whom.
- (void)frameProcessor:(id)aProcessor didOutputFrame:(id)aFrame
{
    Class processorClass = [aProcessor class];
    pthread_mutex_lock((pthread_mutex_t *)_capturedFramesMutex);
    if (_frameProcessorClassToCapturedFrameMap == NULL)
        _frameProcessorClassToCapturedFrameMap = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &NSEClassDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    if (_frameProcessorClassToCapturedFrameMap != NULL)
        CFDictionarySetValue(_frameProcessorClassToCapturedFrameMap, processorClass, aFrame);
    pthread_mutex_unlock((pthread_mutex_t *)_capturedFramesMutex);

    const void *stackClients[4];
    const void **clients = NULL;
    CFIndex count = 0;
    [self HSCaptureDeviceSession_beginReadingClients];
    CFSetRef clientSet = _frameProcessorClassToClientsMap != NULL ? CFDictionaryGetValue(_frameProcessorClassToClientsMap, processorClass) : NULL;
    if (clientSet != NULL && (count = CFSetGetCount(clientSet)) != 0) {
        clients = count <= 4 ? stackClients : NSZoneMalloc(NULL, count * sizeof(id));
        if (clients != NULL)
            CFSetGetValues(clientSet, clients);
    }
    [self HSCaptureDeviceSession_endReadingClients];
    if (clients == NULL)
        return;
    NSThread *thread = [NSThread currentThread];
    for (CFIndex index = 0; index < count; index++) {
        id client = nil;
        [self HSCaptureDeviceSession_beginReadingClients];
        clientSet = _frameProcessorClassToClientsMap != NULL ? CFDictionaryGetValue(_frameProcessorClassToClientsMap, processorClass) : NULL;
        if (clientSet != NULL && CFSetContainsValue(clientSet, clients[index])) {
            client = (id)clients[index];
            pthread_mutex_lock((pthread_mutex_t *)_clientsNotificationMutex);
        }
        [self HSCaptureDeviceSession_endReadingClients];
        if (client == nil)
            continue;
        if (_clientBeingNotifiedToFrameProcessorClassesMap == NULL)
            _clientBeingNotifiedToFrameProcessorClassesMap = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFEWeakObjectPointerDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        if (_clientBeingNotifiedToFrameProcessorClassesMap != NULL) {
            CFMutableDictionaryRef threads = (CFMutableDictionaryRef)CFDictionaryGetValue(_clientBeingNotifiedToFrameProcessorClassesMap, client);
            if (threads == NULL) {
                threads = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &NSEClassDictionaryKeyCallBacks, &kCFEWeakObjectPointerDictionaryValueCallBacks);
                if (threads != NULL) {
                    CFDictionaryAddValue(_clientBeingNotifiedToFrameProcessorClassesMap, client, threads);
                    CFRelease(threads);
                }
            }
            if (threads != NULL)
                CFDictionaryAddValue(threads, processorClass, thread);
        }
        pthread_mutex_unlock((pthread_mutex_t *)_clientsNotificationMutex);
        @try {
            [client captureDeviceSession:self didReceiveFrame:aFrame fromFrameProcessorOfClass:processorClass];
        } @catch (id exception) {
            NSLog(@"Exception was raised while notifying a capture device session client. Ignored.");
            NSLog(@"(%@)", exception);
        }
        pthread_mutex_lock((pthread_mutex_t *)_clientsNotificationMutex);
        CFMutableDictionaryRef threads = _clientBeingNotifiedToFrameProcessorClassesMap != NULL
            ? (CFMutableDictionaryRef)CFDictionaryGetValue(_clientBeingNotifiedToFrameProcessorClassesMap, client) : NULL;
        if (threads != NULL) {
            CFDictionaryRemoveValue(threads, processorClass);
            pthread_cond_signal((pthread_cond_t *)_clientsNotificationCondition);
        }
        pthread_mutex_unlock((pthread_mutex_t *)_clientsNotificationMutex);
    }
    if (clients != stackClients)
        NSZoneFree(NULL, clients);
}

// Ends an activate; the session stops when nothing needs it.
- (void)deactivate
{
    if (--_clientlessActivationCounter == 0 && ![self HSCaptureDeviceSession_hasClients] && [_captureSession isRunning])
        [self HSCaptureDeviceSession_stopRunning];
}

static void HSCaptureDeviceSessionReleaseClassForClient(const void *aClass, void *aContext)
{
    id *context = aContext;
    [(HSCaptureDeviceSession *)context[0] HSCaptureDeviceSession_releaseFrameProcessorClass:(Class)aClass forClient:context[1]];
}

// Drops all of the client's processor classes, then waits until no other
// thread is notifying the client (unless it becomes a client again).
- (void)deactivateForClient:(id)aClient
{
    CFSetRef classes = _clientToFrameProcessorClassesMap != NULL ? CFDictionaryGetValue(_clientToFrameProcessorClassesMap, aClient) : NULL;
    if (classes != NULL) {
        id context[2] = {self, aClient};
        CFSetApplyFunction(classes, HSCaptureDeviceSessionReleaseClassForClient, context);
        CFDictionaryRemoveValue(_clientToFrameProcessorClassesMap, aClient);
    }
    if (_clientlessActivationCounter == 0 && ![self HSCaptureDeviceSession_hasClients] && [_captureSession isRunning])
        [self HSCaptureDeviceSession_stopRunning];
    else if (_clientsNotificationMutex == NULL)
        return;
    do {
        pthread_mutex_lock((pthread_mutex_t *)_clientsNotificationMutex);
        if (![self HSCaptureDeviceSession_isClientBeingNotifiedOnAnotherThread:aClient forFrameProcessorClass:Nil]) {
            CFDictionaryRef threads = _clientBeingNotifiedToFrameProcessorClassesMap != NULL
                ? CFDictionaryGetValue(_clientBeingNotifiedToFrameProcessorClassesMap, aClient) : NULL;
            if (threads != NULL && CFDictionaryGetCount(threads) == 0)
                CFDictionaryRemoveValue(_clientBeingNotifiedToFrameProcessorClassesMap, aClient);
            pthread_mutex_unlock((pthread_mutex_t *)_clientsNotificationMutex);
            return;
        }
        pthread_cond_wait((pthread_cond_t *)_clientsNotificationCondition, (pthread_mutex_t *)_clientsNotificationMutex);
        pthread_mutex_unlock((pthread_mutex_t *)_clientsNotificationMutex);
    } while (![self HSCaptureDeviceSession_isClientActive:aClient]);
}

- (void)deactivateForClient:(id)aClient withFrameProcessorClass:(Class)aClass
{
    BOOL clientLeft = YES;
    CFMutableSetRef classes = _clientToFrameProcessorClassesMap != NULL ? (CFMutableSetRef)CFDictionaryGetValue(_clientToFrameProcessorClassesMap, aClient) : NULL;
    if (classes != NULL) {
        CFIndex count = CFSetGetCount(classes);
        if (count == 0 || (count == 1 && CFSetContainsValue(classes, aClass)))
            CFDictionaryRemoveValue(_clientToFrameProcessorClassesMap, aClient);
        else if (count != 1) {
            CFSetRemoveValue(classes, aClass);
            clientLeft = NO;
        }
        // Original quirk kept: the class is released for the client even
        // when the client had another single class.
        [self HSCaptureDeviceSession_releaseFrameProcessorClass:aClass forClient:aClient];
    }
    if (_clientlessActivationCounter == 0 && ![self HSCaptureDeviceSession_hasClients] && [_captureSession isRunning])
        [self HSCaptureDeviceSession_stopRunning];
    else if (_clientsNotificationMutex == NULL)
        return;
    do {
        pthread_mutex_lock((pthread_mutex_t *)_clientsNotificationMutex);
        if (![self HSCaptureDeviceSession_isClientBeingNotifiedOnAnotherThread:aClient forFrameProcessorClass:aClass]) {
            CFDictionaryRef threads = _clientBeingNotifiedToFrameProcessorClassesMap != NULL
                ? CFDictionaryGetValue(_clientBeingNotifiedToFrameProcessorClassesMap, aClient) : NULL;
            if (clientLeft && threads != NULL && CFDictionaryGetCount(threads) == 0)
                CFDictionaryRemoveValue(_clientBeingNotifiedToFrameProcessorClassesMap, aClient);
            pthread_mutex_unlock((pthread_mutex_t *)_clientsNotificationMutex);
            return;
        }
        pthread_cond_wait((pthread_cond_t *)_clientsNotificationCondition, (pthread_mutex_t *)_clientsNotificationMutex);
        pthread_mutex_unlock((pthread_mutex_t *)_clientsNotificationMutex);
    } while (![self HSCaptureDeviceSession_isClientActive:aClient forFrameProcessorClass:aClass]);
}

- (BOOL)HSCaptureDeviceSession_hasClients
{
    return _clientToFrameProcessorClassesMap != NULL && CFDictionaryGetCount(_clientToFrameProcessorClassesMap) > 0;
}

// The client gets the frames of the processor class; the session runs.
- (void)activateForClient:(id)aClient withFrameProcessorClass:(Class)aClass
{
    if (_frameProcessorClassToCapturedFrameMap != NULL) {
        pthread_mutex_lock((pthread_mutex_t *)_capturedFramesMutex);
        [self HSCaptureDeviceSession_retainCapturedFrameForFrameProcessorClass:aClass];
        pthread_mutex_unlock((pthread_mutex_t *)_capturedFramesMutex);
    }
    if (_captureSession != nil) {
        if ([self HSCaptureDeviceSession_frameProcessorClassToFrameProcessorMap] == NULL
            || [self HSCaptureDeviceSession_frameProcessorToCaptureOutputMap] == NULL)
            return;
        [self HSCaptureDeviceSession_addFrameProcessorOfClass:aClass];
    }
    if ([self HSCaptureDeviceSession_addClient:aClient withFrameProcessorClass:aClass])
        [self HSCaptureDeviceSession_activate];
}

// Runs the session without a client (balanced by deactivate).
- (void)activate
{
    _clientlessActivationCounter++;
    [self HSCaptureDeviceSession_activate];
}

// A device that went away is closed; one free again is reopened.
- (void)HSCaptureDeviceSession_captureDeviceDidChangeState:(id)aState
{
    if (![_captureSession isRunning] || ![_captureDeviceSet containsObject:aState])
        return;
    if (![aState isConnected]) {
        CFSetRemoveValue(_openCaptureDevices, aState);
        return;
    }
    if ([aState QTE_isInUseByAnotherApplication] || CFSetContainsValue(_openCaptureDevices, aState))
        return;
    NSError *error = nil;
    if ([(QTCaptureDevice *)aState open:&error])
        CFSetSetValue(_openCaptureDevices, aState);
    else
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSCaptureDeviceSessionRuntimeErrorNotification" object:self
            userInfo:[NSDictionary dictionaryWithObjectsAndKeys:error, @"HSCaptureDeviceSessionErrorKey", nil]];
}

- (void)observeValueForKeyPath:(id)aPath ofObject:(id)aObject change:(id)aChange context:(void *)aContext
{
    if (![aPath isEqualToString:@"inUseByAnotherApplication"] && ![aPath isEqualToString:@"connected"])
        return;
    [self performSelectorOnMainThread:@selector(HSCaptureDeviceSession_captureDeviceDidChangeState:) withObject:aObject waitUntilDone:NO];
}

// Opens the devices (a session made for this keeps them open already),
// watches their state and starts the session.
- (void)HSCaptureDeviceSession_activate
{
    if (_openCaptureDevices == NULL) {
        CFSetCallBacks callBacks = {0, NULL, HSCaptureDeviceSessionCloseDevice, kCFEWeakObjectPointerSetCallBacks.copyDescription, NULL, NULL};
        _openCaptureDevices = CFSetCreateMutable(kCFAllocatorDefault, 0, &callBacks);
        if (_openCaptureDevices == NULL)
            return;
    }
    BOOL sessionIsNew = NO;
    if (_captureSession == nil) {
        if ([self HSCaptureDeviceSession_captureSessionForActivation:YES] == nil)
            return;
        sessionIsNew = YES;
    }
    if ([_captureSession isRunning])
        return;
    NSUInteger count = [_captureDeviceInputs count];
    for (NSUInteger index = 0; index < count; index++) {
        QTCaptureDevice *device = [[_captureDeviceInputs objectAtIndex:index] device];
        if (!sessionIsNew) {
            NSError *error = nil;
            if ([device open:&error])
                CFSetSetValue(_openCaptureDevices, device);
            else
                [[NSNotificationCenter defaultCenter] postNotificationName:@"HSCaptureDeviceSessionRuntimeErrorNotification" object:self
                    userInfo:[NSDictionary dictionaryWithObjectsAndKeys:error, @"HSCaptureDeviceSessionErrorKey", nil]];
        }
        [device addObserver:self forKeyPath:@"inUseByAnotherApplication" options:0 context:NULL];
        [device addObserver:self forKeyPath:@"connected" options:0 context:NULL];
    }
    [_captureSession startRunning];
}

- (id)captureSession
{
    if (_captureSession == nil)
        [self HSCaptureDeviceSession_captureSessionForActivation:NO];
    return _captureSession;
}

// Makes the session with an input per device (nil when one can't be added)
// and the processors of the classes in use.
- (id)HSCaptureDeviceSession_captureSessionForActivation:(BOOL)aActivation
{
    if (_clientsNotificationMutex == NULL) {
        _clientsNotificationMutex = (void *)HSCaptureDeviceSessionCreateMutex();
        if (_clientsNotificationMutex == NULL)
            return _captureSession;
    }
    if (_clientsNotificationCondition == NULL) {
        _clientsNotificationCondition = (void *)HSCaptureDeviceSessionCreateCondition();
        if (_clientsNotificationCondition == NULL)
            return _captureSession;
    }
    if (_captureDeviceInputs == nil) {
        _captureDeviceInputs = [[NSMutableArray alloc] init];
        if (_captureDeviceInputs == nil)
            return _captureSession;
    }
    _captureSession = [[QTCaptureSession alloc] init];
    if (_captureSession == nil)
        return nil;
    BOOL addedInputs = YES;
    for (QTCaptureDevice *device in _captureDeviceSet)
        if (![self HSCaptureDeviceSession_addInputForCaptureDevice:device remainOpen:aActivation]) {
            addedInputs = NO;
            break;
        }
    if (!addedInputs) {
        if (aActivation)
            CFSetRemoveAllValues(_openCaptureDevices);
        [_captureDeviceInputs release];
        _captureDeviceInputs = nil;
        [_captureSession release];
        _captureSession = nil;
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSCaptureDeviceSession_captureSessionRuntimeErrorNotification:) name:QTCaptureSessionRuntimeErrorNotification object:_captureSession];
        [self HSCaptureDeviceSession_addFrameProcessors];
    }
    return _captureSession;
}

- (void)HSCaptureDeviceSession_captureSessionRuntimeErrorNotification:(id)aNotification
{
    id error = [[aNotification userInfo] objectForKey:QTCaptureSessionErrorKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSCaptureDeviceSessionRuntimeErrorNotification" object:self
        userInfo:[NSDictionary dictionaryWithObjectsAndKeys:error, @"HSCaptureDeviceSessionErrorKey", nil]];
}

- (id)captureDeviceSet
{
    return _captureDeviceSet;
}

- (void)dealloc
{
    if (_captureSession != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:QTCaptureSessionRuntimeErrorNotification object:_captureSession];
        if ([_captureSession isRunning])
            [self HSCaptureDeviceSession_stopRunning];
        NSUInteger count = [_captureDeviceInputs count];
        for (NSUInteger index = 0; index < count; index++)
            [_captureSession removeInput:[_captureDeviceInputs objectAtIndex:index]];
        if (_frameProcessorClassToFrameProcessorMap != NULL)
            CFDictionaryApplyFunction(_frameProcessorClassToFrameProcessorMap, HSCaptureDeviceSessionPreremoveFrameProcessor, self);
        [_captureSession release];
    }
    [_captureDeviceInputs release];
    if (_openCaptureDevices != NULL)
        CFRelease(_openCaptureDevices);
    if (_captureDeviceSet != nil) {
        if (HSCaptureDeviceSessionsByDeviceSet != NULL)
            CFDictionaryRemoveValue(HSCaptureDeviceSessionsByDeviceSet, _captureDeviceSet);
        [_captureDeviceSet release];
    }
    if (_clientBeingNotifiedToFrameProcessorClassesMap != NULL)
        CFRelease(_clientBeingNotifiedToFrameProcessorClassesMap);
    HSCaptureDeviceSessionDestroyMutex((pthread_mutex_t *)_clientsNotificationMutex);
    HSCaptureDeviceSessionDestroyCondition((pthread_cond_t *)_clientsNotificationCondition);
    if (_frameProcessorToCaptureOutputMap != NULL)
        CFRelease(_frameProcessorToCaptureOutputMap);
    if (_frameProcessorClassToFrameProcessorMap != NULL)
        CFRelease(_frameProcessorClassToFrameProcessorMap);
    if (_clientToFrameProcessorClassesMap != NULL)
        CFRelease(_clientToFrameProcessorClassesMap);
    if (_frameProcessorClassToClientsMap != NULL)
        CFRelease(_frameProcessorClassToClientsMap);
    HSCaptureDeviceSessionDestroyMutex((pthread_mutex_t *)_clientsMutex);
    HSCaptureDeviceSessionDestroyCondition((pthread_cond_t *)_clientsCondition);
    if (_frameProcessorClassToReferenceCountMap != NULL)
        CFRelease(_frameProcessorClassToReferenceCountMap);
    if (_frameProcessorClassToCapturedFrameDecayTimerMap != NULL) {
        CFDictionaryApplyFunction(_frameProcessorClassToCapturedFrameDecayTimerMap, HSCaptureDeviceSessionInvalidateTimer, NULL);
        CFRelease(_frameProcessorClassToCapturedFrameDecayTimerMap);
    }
    if (_frameProcessorClassToCapturedFrameMap != NULL)
        CFRelease(_frameProcessorClassToCapturedFrameMap);
    HSCaptureDeviceSessionDestroyMutex((pthread_mutex_t *)_capturedFramesMutex);
    if (_clientIdentifierToCapturedFrameDecayIntervalMap != NULL)
        CFRelease(_clientIdentifierToCapturedFrameDecayIntervalMap);
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    _capturedFramesMutex = (void *)HSCaptureDeviceSessionCreateMutex();
    if (_capturedFramesMutex != NULL) {
        _clientsMutex = (void *)HSCaptureDeviceSessionCreateMutex();
        if (_clientsMutex != NULL) {
            _clientsCondition = (void *)HSCaptureDeviceSessionCreateCondition();
            if (_clientsCondition != NULL)
                return self;
        }
    }
    [self release];
    return nil;
}

// Stops the session and closes the devices.
- (void)HSCaptureDeviceSession_stopRunning
{
    [_captureSession stopRunning];
    CFSetRemoveAllValues(_openCaptureDevices);
    NSUInteger count = [_captureDeviceInputs count];
    for (NSUInteger index = 0; index < count; index++) {
        QTCaptureDevice *device = [[_captureDeviceInputs objectAtIndex:index] device];
        [device removeObserver:self forKeyPath:@"inUseByAnotherApplication"];
        [device removeObserver:self forKeyPath:@"connected"];
    }
}

- (void)HSCaptureDeviceSession_preremoveFrameProcessor:(id)aProcessor
{
    id output = (id)CFDictionaryGetValue(_frameProcessorToCaptureOutputMap, aProcessor);
    if (output != nil) {
        [_captureSession removeOutput:output];
        [aProcessor abandonCaptureOutput:output];
    }
    [aProcessor setDelegate:nil];
}

// A processor for every class in use.
- (void)HSCaptureDeviceSession_addFrameProcessors
{
    if (_frameProcessorClassToReferenceCountMap == NULL
        || [self HSCaptureDeviceSession_frameProcessorClassToFrameProcessorMap] == NULL
        || [self HSCaptureDeviceSession_frameProcessorToCaptureOutputMap] == NULL)
        return;
    CFIndex count = CFDictionaryGetCount(_frameProcessorClassToReferenceCountMap);
    if (count == 0)
        return;
    const void **classes = NSZoneMalloc(NULL, count * sizeof(Class));
    if (classes == NULL)
        return;
    CFDictionaryGetKeysAndValues(_frameProcessorClassToReferenceCountMap, classes, NULL);
    for (CFIndex index = 0; index < count; index++)
        [self HSCaptureDeviceSession_addFrameProcessorOfClass:(Class)classes[index]];
    NSZoneFree(NULL, classes);
}

- (struct __CFDictionary *)HSCaptureDeviceSession_frameProcessorToCaptureOutputMap
{
    if (_frameProcessorToCaptureOutputMap == NULL)
        _frameProcessorToCaptureOutputMap = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFEWeakObjectPointerDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    return _frameProcessorToCaptureOutputMap;
}

- (struct __CFDictionary *)HSCaptureDeviceSession_frameProcessorClassToFrameProcessorMap
{
    if (_frameProcessorClassToFrameProcessorMap == NULL)
        _frameProcessorClassToFrameProcessorMap = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &NSEClassDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    return _frameProcessorClassToFrameProcessorMap;
}

// A processor with a capture output joins the session; one without works on
// another processor's frames, as that processor's client (and gets its last
// frame at once).
- (void)HSCaptureDeviceSession_addFrameProcessorOfClass:(Class)aClass
{
    if (CFDictionaryGetValue(_frameProcessorClassToFrameProcessorMap, aClass) != NULL)
        return;
    HSFrameProcessor *processor = [[aClass alloc] init];
    if (processor == nil)
        return;
    [processor setDelegate:self];
    CFDictionaryAddValue(_frameProcessorClassToFrameProcessorMap, aClass, processor);
    [processor release];
    id output = [processor createCaptureOutputForCaptureInputs:_captureDeviceInputs];
    if (output != nil) {
        NSError *error = nil;
        if ([_captureSession addOutput:output error:&error])
            CFDictionaryAddValue(_frameProcessorToCaptureOutputMap, processor, output);
        else
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HSCaptureDeviceSessionRuntimeErrorNotification" object:self
                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:error, @"HSCaptureDeviceSessionErrorKey", nil]];
        [output release];
        return;
    }
    Class preprocessingClass = Nil;
    if (![processor conformsToProtocol:@protocol(HSCaptureDeviceSessionClient)]
        || (preprocessingClass = [processor preprocessingFrameProcessorClass]) == Nil
        || ![self HSCaptureDeviceSession_addClient:processor withFrameProcessorClass:preprocessingClass]) {
        [processor setDelegate:nil];
        CFDictionaryRemoveValue(_frameProcessorClassToFrameProcessorMap, aClass);
        return;
    }
    if (_frameProcessorClassToCapturedFrameMap != NULL) {
        pthread_mutex_lock((pthread_mutex_t *)_capturedFramesMutex);
        [self HSCaptureDeviceSession_retainCapturedFrameForFrameProcessorClass:preprocessingClass];
        id frame = [(id)CFDictionaryGetValue(_frameProcessorClassToCapturedFrameMap, preprocessingClass) retain];
        pthread_mutex_unlock((pthread_mutex_t *)_capturedFramesMutex);
        if (frame != nil) {
            [(id <HSCaptureDeviceSessionClient>)processor captureDeviceSession:self didReceiveFrame:frame fromFrameProcessorOfClass:preprocessingClass];
            [frame release];
        }
    }
    [self HSCaptureDeviceSession_addFrameProcessorOfClass:preprocessingClass];
}

// When the class has no clients left: its last frame decays (at once
// without an interval) and its processor leaves the session.
- (void)HSCaptureDeviceSession_releaseFrameProcessorClass:(Class)aClass forClient:(id)aClient
{
    [self HSCaptureDeviceSession_beginWritingClients];
    CFMutableSetRef clients = _frameProcessorClassToClientsMap != NULL ? (CFMutableSetRef)CFDictionaryGetValue(_frameProcessorClassToClientsMap, aClass) : NULL;
    if (clients != NULL) {
        CFIndex count = CFSetGetCount(clients);
        if (count == 0 || (count == 1 && CFSetContainsValue(clients, aClient)))
            CFDictionaryRemoveValue(_frameProcessorClassToClientsMap, aClass);
        else if (count != 1)
            CFSetRemoveValue(clients, aClient);
    }
    [self HSCaptureDeviceSession_endWritingClients];
    if (_frameProcessorClassToReferenceCountMap == NULL)
        return;
    NSUInteger referenceCount = (NSUInteger)CFDictionaryGetValue(_frameProcessorClassToReferenceCountMap, aClass);
    if (referenceCount == 0)
        return;
    if (referenceCount != 1) {
        CFDictionarySetValue(_frameProcessorClassToReferenceCountMap, aClass, (const void *)(referenceCount - 1));
        return;
    }
    if (_frameProcessorClassToCapturedFrameMap != NULL) {
        pthread_mutex_lock((pthread_mutex_t *)_capturedFramesMutex);
        if (_capturedFrameDecayInterval != 0.0) {
            if (_frameProcessorClassToCapturedFrameDecayTimerMap == NULL)
                _frameProcessorClassToCapturedFrameDecayTimerMap = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &NSEClassDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
            if (_frameProcessorClassToCapturedFrameDecayTimerMap != NULL) {
                NSTimer *timer = [NSThread hyperScheduledThreadTimerWithInterval:_capturedFrameDecayInterval mainThreadTarget:self
                    selector:@selector(HSCaptureDeviceSession_capturedFrameDecayTimer:releaseCapturedFrameForFrameProcessorClass:) object:aClass repeats:NO];
                if (timer != nil)
                    CFDictionaryAddValue(_frameProcessorClassToCapturedFrameDecayTimerMap, aClass, timer);
            }
        } else
            CFDictionaryRemoveValue(_frameProcessorClassToCapturedFrameMap, aClass);
        pthread_mutex_unlock((pthread_mutex_t *)_capturedFramesMutex);
    }
    id processor = _frameProcessorClassToFrameProcessorMap != NULL ? (id)CFDictionaryGetValue(_frameProcessorClassToFrameProcessorMap, aClass) : nil;
    if (processor != nil) {
        // Fix: the original looked the output up without checking for the map.
        id output = _frameProcessorToCaptureOutputMap != NULL ? (id)CFDictionaryGetValue(_frameProcessorToCaptureOutputMap, processor) : nil;
        if (output == nil) {
            if ([processor conformsToProtocol:@protocol(HSCaptureDeviceSessionClient)])
                [self deactivateForClient:processor];
        } else {
            [_captureSession removeOutput:output];
            [processor abandonCaptureOutput:output];
            CFDictionaryRemoveValue(_frameProcessorToCaptureOutputMap, processor);
        }
        [processor setDelegate:nil];
        [[processor retain] autorelease];
        CFDictionaryRemoveValue(_frameProcessorClassToFrameProcessorMap, aClass);
    }
    CFDictionaryRemoveValue(_frameProcessorClassToReferenceCountMap, aClass);
}

- (void)HSCaptureDeviceSession_capturedFrameDecayTimer:(id)aTimer releaseCapturedFrameForFrameProcessorClass:(id)aClass
{
    pthread_mutex_lock((pthread_mutex_t *)_capturedFramesMutex);
    if (CFDictionaryContainsKey(_frameProcessorClassToCapturedFrameDecayTimerMap, aClass)) {
        CFDictionaryRemoveValue(_frameProcessorClassToCapturedFrameMap, aClass);
        CFDictionaryRemoveValue(_frameProcessorClassToCapturedFrameDecayTimerMap, aClass);
    }
    pthread_mutex_unlock((pthread_mutex_t *)_capturedFramesMutex);
}

// Keeps the class's last frame (its decay is called off). The caller holds
// _capturedFramesMutex.
- (void)HSCaptureDeviceSession_retainCapturedFrameForFrameProcessorClass:(id)aClass
{
    if (_frameProcessorClassToCapturedFrameDecayTimerMap == NULL)
        return;
    NSTimer *timer = (id)CFDictionaryGetValue(_frameProcessorClassToCapturedFrameDecayTimerMap, aClass);
    if (timer == nil)
        return;
    [timer invalidate];
    CFDictionaryRemoveValue(_frameProcessorClassToCapturedFrameDecayTimerMap, aClass);
}

- (BOOL)HSCaptureDeviceSession_isClientActive:(id)aActive
{
    if (_clientToFrameProcessorClassesMap == NULL)
        return NO;
    return CFDictionaryContainsKey(_clientToFrameProcessorClassesMap, aActive);
}

- (BOOL)HSCaptureDeviceSession_isClientActive:(id)aActive forFrameProcessorClass:(Class)aClass
{
    // Original quirk kept: this read doesn't wait for a pending writer.
    pthread_mutex_lock((pthread_mutex_t *)_clientsMutex);
    _clientsReadAccessCount++;
    pthread_mutex_unlock((pthread_mutex_t *)_clientsMutex);
    BOOL active = NO;
    CFSetRef clients = _frameProcessorClassToClientsMap != NULL ? CFDictionaryGetValue(_frameProcessorClassToClientsMap, aClass) : NULL;
    if (clients != NULL)
        active = CFSetContainsValue(clients, aActive);
    [self HSCaptureDeviceSession_endReadingClients];
    return active;
}

// Whether a thread other than this one is notifying the client (of the class,
// or of any class when aClass is Nil). The caller holds
// _clientsNotificationMutex.
- (BOOL)HSCaptureDeviceSession_isClientBeingNotifiedOnAnotherThread:(id)aThread forFrameProcessorClass:(Class)aClass
{
    CFDictionaryRef threads = _clientBeingNotifiedToFrameProcessorClassesMap != NULL
        ? CFDictionaryGetValue(_clientBeingNotifiedToFrameProcessorClassesMap, aThread) : NULL;
    CFIndex count = threads != NULL ? CFDictionaryGetCount(threads) : 0;
    if (count == 0)
        return NO;
    const void *thread = NULL;
    if (aClass == Nil) {
        if (count > 1)
            return YES;
        CFDictionaryGetKeysAndValues(threads, NULL, &thread);
    } else
        thread = CFDictionaryGetValue(threads, aClass);
    return thread != [NSThread currentThread];
}

- (BOOL)HSCaptureDeviceSession_addInputForCaptureDevice:(id)aDevice remainOpen:(BOOL)aOpen
{
    NSError *error = nil;
    if (![(QTCaptureDevice *)aDevice open:&error]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSCaptureDeviceSessionRuntimeErrorNotification" object:self
            userInfo:[NSDictionary dictionaryWithObjectsAndKeys:error, @"HSCaptureDeviceSessionErrorKey", nil]];
        return NO;
    }
    QTCaptureDeviceInput *input = [QTCaptureDeviceInput deviceInputWithDevice:aDevice];
    if (input == nil) {
        [aDevice close];
        return NO;
    }
    if (![_captureSession addInput:input error:&error]) {
        [aDevice close];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSCaptureDeviceSessionRuntimeErrorNotification" object:self
            userInfo:[NSDictionary dictionaryWithObjectsAndKeys:error, @"HSCaptureDeviceSessionErrorKey", nil]];
        return NO;
    }
    [_captureDeviceInputs addObject:input];
    if (aOpen)
        CFSetSetValue(_openCaptureDevices, aDevice);
    else if ([aDevice isOpen])
        [aDevice close];
    return YES;
}

// Counts the class's use, once per client.
- (BOOL)HSCaptureDeviceSession_addClient:(id)aClient withFrameProcessorClass:(Class)aClass
{
    CFMutableSetRef classes = NULL;
    if (_clientToFrameProcessorClassesMap == NULL) {
        _clientToFrameProcessorClassesMap = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFEWeakObjectPointerDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        if (_clientToFrameProcessorClassesMap == NULL)
            return NO;
    } else
        classes = (CFMutableSetRef)CFDictionaryGetValue(_clientToFrameProcessorClassesMap, aClient);
    if (classes == NULL) {
        classes = CFSetCreateMutable(kCFAllocatorDefault, 0, &NSEClassSetCallBacks);
        if (classes == NULL)
            return NO;
        CFDictionaryAddValue(_clientToFrameProcessorClassesMap, aClient, classes);
        CFRelease(classes);
    }
    if (_frameProcessorClassToReferenceCountMap == NULL) {
        _frameProcessorClassToReferenceCountMap = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &NSEClassDictionaryKeyCallBacks, &kCFEUnsignedIntegerDictionaryValueCallBacks);
        if (_frameProcessorClassToReferenceCountMap == NULL)
            return NO;
    }
    if (![self HSCaptureDeviceSession_addClient:aClient forFrameProcessorClass:aClass])
        return NO;
    CFSetAddValue(classes, aClass);
    NSUInteger referenceCount = (NSUInteger)CFDictionaryGetValue(_frameProcessorClassToReferenceCountMap, aClass);
    CFDictionarySetValue(_frameProcessorClassToReferenceCountMap, aClass, (const void *)(referenceCount + 1));
    return YES;
}

- (BOOL)HSCaptureDeviceSession_addClient:(id)aClient forFrameProcessorClass:(Class)aClass
{
    BOOL added = NO;
    [self HSCaptureDeviceSession_beginWritingClients];
    if (_frameProcessorClassToClientsMap == NULL)
        _frameProcessorClassToClientsMap = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &NSEClassDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    if (_frameProcessorClassToClientsMap != NULL) {
        CFMutableSetRef clients = (CFMutableSetRef)CFDictionaryGetValue(_frameProcessorClassToClientsMap, aClass);
        if (clients == NULL) {
            clients = CFSetCreateMutable(kCFAllocatorDefault, 0, &kCFEWeakObjectPointerSetCallBacks);
            if (clients != NULL) {
                CFDictionaryAddValue(_frameProcessorClassToClientsMap, aClass, clients);
                CFRelease(clients);
            }
        }
        if (clients != NULL) {
            CFSetAddValue(clients, aClient);
            added = YES;
        }
    }
    [self HSCaptureDeviceSession_endWritingClients];
    return added;
}

- (id)HSCaptureDeviceSession_initWithCaptureDeviceSet:(id)aSet
{
    _captureDeviceSet = [[NSSet alloc] initWithSet:aSet];
    if (_captureDeviceSet == nil) {
        [super release];
        return nil;
    }
    return [self init];
}

@end
