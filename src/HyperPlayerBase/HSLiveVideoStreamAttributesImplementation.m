#import "HSLiveVideoStreamAttributesImplementation.h"
#import "HSLiveObject.h"
#import "HSCaptureDeviceList.h"
#import "HSCaptureDeviceSession.h"
#import "HSFrameProcessor.h"
#import "HSNativeVideoPreviewFrameProcessor.h"
#import "HSSystem.h"

// The video stream of a live (camera) object: follows the capture device at
// the object's device index and keeps the session active while the object
// plays. Frame processor classes are reference counted; the last frame
// captured by each is kept (frames of derived processors are computed on
// demand from their preprocessing processor's frame).
@implementation HSLiveVideoStreamAttributesImplementation

static void HSLiveVideoActivateFrameProcessorClass(const void *aClass, const void *aCount, void *aSelf)
{
    [(id)aSelf HSLiveVideoStreamAttributesImplementation_activateCaptureDeviceWithFrameProcessorClass:(Class)aClass];
}

static void HSLiveVideoSetFrame(const void *aClass, const void *aFrame, void *aSelf)
{
    [(id)aSelf HSLiveVideoStreamAttributesImplementation_setFrame:(id)aFrame forFrameProcessorClass:(Class)aClass];
}

- (void)observeValueForKeyPath:(id)aPath ofObject:(id)aObject change:(id)aChange context:(void *)aContext
{
    if (_captureDevice != aObject)
        return;
    if ([aPath isEqualToString:@"inUseByAnotherApplication"] || [aPath isEqualToString:@"suspended"])
        [self performSelectorOnMainThread:@selector(HSLiveVideoStreamAttributesImplementation_captureDeviceDidChangeState:) withObject:aObject waitUntilDone:NO];
}

- (void)HSLiveVideoStreamAttributesImplementation_captureDeviceDidChangeState:(id)aState
{
    if (_captureDevice == aState)
        [_liveVideoObject notifyChange:2 ofAttribute:@protocol(HSVideoFrameAttribute) withUserInfo:nil];
}

- (void)HSLiveVideoStreamAttributesImplementation_captureDeviceListDidUpdate:(id)aUpdate
{
    [self HSLiveVideoStreamAttributesImplementation_adoptVideoDevicePostingNotifications:YES];
}

- (void)HSLiveVideoStreamAttributesImplementation_liveVideoObjectDidChangeHyperDeviceIndex:(id)aIndex
{
    [self HSLiveVideoStreamAttributesImplementation_adoptVideoDevicePostingNotifications:YES];
}

- (void)HSLiveVideoStreamAttributesImplementation_liveVideoObjectDidChangePlayingVideoState:(id)aState
{
    if ([_liveVideoObject isHyperPlaying]) {
        if (_captureDeviceActivationCounter == 0)
            [self HSLiveVideoStreamAttributesImplementation_activateCaptureDeviceWithContinuousChangeNotification:YES];
    } else if (_captureDeviceActivationCounter != 0) {
        [self HSLiveVideoStreamAttributesImplementation_deactivateCaptureDeviceWithContinuousChangeNotification:YES];
    }
}

- (id)attributeObservingController
{
    return _liveVideoObject;
}

- (id)videoFrameForVideoFrameProcessorClass:(Class)aClass
{
    if (_frameProcessorClassToReferenceCountMap == NULL ||
        CFDictionaryGetValue(_frameProcessorClassToReferenceCountMap, aClass) == NULL ||
        _frameProcessorClassToCapturedFrameMap == NULL)
        return nil;
    id frame = (id)CFDictionaryGetValue(_frameProcessorClassToCapturedFrameMap, aClass);
    if (frame != nil)
        return frame;
    id processor = [[[aClass alloc] init] autorelease];
    if (processor == nil)
        return nil;
    Class preprocessingClass = [processor preprocessingFrameProcessorClass];
    if (preprocessingClass == Nil)
        return nil;
    id preprocessedFrame = [self videoFrameForVideoFrameProcessorClass:preprocessingClass];
    if (preprocessedFrame == nil)
        return nil;
    frame = [processor outputFrameForPreprocessedFrame:preprocessedFrame];
    if (frame == nil)
        return nil;
    CFDictionarySetValue(_frameProcessorClassToCapturedFrameMap, aClass, frame);
    return frame;
}

- (void)removeVideoFrameProcessorClass:(Class)aClass
{
    [self HSLiveVideoStreamAttributesImplementation_removeVideoFrameProcessorClass:aClass];
}

- (void)addVideoFrameProcessorClass:(Class)aClass
{
    [self HSLiveVideoStreamAttributesImplementation_addVideoFrameProcessorClass:aClass];
}

- (BOOL)isPlayingVideo
{
    return [_liveVideoObject isHyperPlaying];
}

- (NSRect)videoRect
{
    id geometry = [_liveVideoObject queryHyperInterface:@protocol(HSGeometryAttributes)];
    if (geometry == nil)
        return NSZeroRect;
    return [geometry boundingRect];
}

- (id)liveVideoDevice
{
    return _captureDevice;
}

- (id)hyperObject
{
    return _liveVideoObject;
}

- (id)liveVideoObject
{
    return _liveVideoObject;
}

// The capture session client retains nothing, so the capture device is shut
// down before the last release.
- (void)release
{
    while (_captureDeviceActivationCounter != 0 && [self retainCount] == 1)
        [self HSLiveVideoStreamAttributesImplementation_deactivateCaptureDeviceWithContinuousChangeNotification:YES];
    [super release];
}

- (void)dealloc
{
    if (_captureDevice != nil) {
        if (_captureDeviceSession != nil)
            [self HSLiveVideoStreamAttributesImplementation_releaseCaptureDeviceSession];
        [_captureDevice removeObserver:self forKeyPath:@"inUseByAnotherApplication"];
        [_captureDevice removeObserver:self forKeyPath:@"suspended"];
        [_captureDevice release];
    }
    if (_captureDeviceList != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSCaptureDeviceListDidUpdateNotification" object:_captureDeviceList];
        [_captureDeviceList release];
    }
    if (_frameProcessorClassToReferenceCountMap != NULL)
        CFRelease(_frameProcessorClassToReferenceCountMap);
    if (_frameProcessorClassToCapturedFrameMap != NULL)
        CFRelease(_frameProcessorClassToCapturedFrameMap);
    [_liveVideoObject rejectImplementation:self];
    [_liveVideoObject removeObserver:self selector:@selector(HSLiveVideoStreamAttributesImplementation_liveVideoObjectDidChangePlayingVideoState:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSPlayingVideoStateAttribute)];
    [_liveVideoObject removeObserver:self selector:@selector(HSLiveVideoStreamAttributesImplementation_liveVideoObjectDidChangeHyperDeviceIndex:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSLiveObjectDeviceIndexAttribute)];
    [_liveVideoObject release];
    [super dealloc];
}

// Fails without QTKit-style capturing or a device list.
- (id)initWithLiveVideoObject:(id)aObject
{
    self = [super init];
    if (self == nil)
        return nil;
    if ([[HSSystem sharedSystem] isQTKitCapturingAvailable]) {
        NSArray *mediaTypes = [NSArray arrayWithObjects:QTMediaTypeVideo, QTMediaTypeMuxed, nil];
        if (mediaTypes != nil) {
            _captureDeviceList = [[HSCaptureDeviceList captureDeviceListForMediaTypes:mediaTypes] retain];
            if (_captureDeviceList != nil) {
                _liveVideoObject = [aObject retain];
                [self HSLiveVideoStreamAttributesImplementation_adoptVideoDevicePostingNotifications:NO];
                [_liveVideoObject associateImplementation:self withInterface:@protocol(HSVideoStreamAttributes)];
                [_liveVideoObject associateImplementation:self withInterface:@protocol(HSLiveVideoAttributes)];
                [_liveVideoObject addObserver:self selector:@selector(HSLiveVideoStreamAttributesImplementation_liveVideoObjectDidChangePlayingVideoState:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSPlayingVideoStateAttribute) withPriority:0.25f];
                [_liveVideoObject addObserver:self selector:@selector(HSLiveVideoStreamAttributesImplementation_liveVideoObjectDidChangeHyperDeviceIndex:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSLiveObjectDeviceIndexAttribute) withPriority:0.25f];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSLiveVideoStreamAttributesImplementation_captureDeviceListDidUpdate:) name:@"HSCaptureDeviceListDidUpdateNotification" object:_captureDeviceList];
                [self HSLiveVideoStreamAttributesImplementation_addVideoFrameProcessorClass:[HSNativeVideoFrameProcessor class]];
                if ([_liveVideoObject isHyperPlaying])
                    [self HSLiveVideoStreamAttributesImplementation_activateCaptureDeviceWithContinuousChangeNotification:YES];
                return self;
            }
        }
    }
    [self release];
    return nil;
}

- (void)HSLiveVideoStreamAttributesImplementation_postReceiveFrames
{
    [_liveVideoObject notifyChange:2 ofAttribute:@protocol(HSVideoFrameAttribute) withUserInfo:nil];
}

- (void)HSLiveVideoStreamAttributesImplementation_receiveFrames:(struct __CFDictionary *)aFrames
{
    CFDictionaryApplyFunction(aFrames, HSLiveVideoSetFrame, self);
}

- (void)HSLiveVideoStreamAttributesImplementation_setFrame:(id)aFrame forFrameProcessorClass:(Class)aClass
{
    if (CFDictionaryGetValue(_frameProcessorClassToReferenceCountMap, aClass) != NULL)
        CFDictionarySetValue(_frameProcessorClassToCapturedFrameMap, aClass, aFrame);
}

- (BOOL)HSLiveVideoStreamAttributesImplementation_preReceiveFrames
{
    BOOL ready = [self HSLiveVideoStreamAttributesImplementation_frameProcessorClassToCapturedFrameMap] != NULL;
    if (ready)
        [_liveVideoObject notifyChange:1 ofAttribute:@protocol(HSVideoFrameAttribute) withUserInfo:nil];
    return ready;
}

- (void)HSLiveVideoStreamAttributesImplementation_receiveFrame:(id)aFrame fromFrameProcessorOfClass:(Class)aClass
{
    [_liveVideoObject notifyChange:1 ofAttribute:@protocol(HSVideoFrameAttribute) withUserInfo:nil];
    if ([self HSLiveVideoStreamAttributesImplementation_frameProcessorClassToCapturedFrameMap] != NULL)
        CFDictionarySetValue(_frameProcessorClassToCapturedFrameMap, aClass, aFrame);
    [_liveVideoObject notifyChange:2 ofAttribute:@protocol(HSVideoFrameAttribute) withUserInfo:nil];
}

- (void)HSLiveVideoStreamAttributesImplementation_removeVideoFrameProcessorClass:(Class)aClass
{
    if (_frameProcessorClassToReferenceCountMap == NULL)
        return;
    NSUInteger count = (NSUInteger)CFDictionaryGetValue(_frameProcessorClassToReferenceCountMap, aClass);
    if (count == 0)
        return;
    if (count == 1) {
        CFDictionaryRemoveValue(_frameProcessorClassToReferenceCountMap, aClass);
        if (_captureDeviceActivationCounter != 0) {
            _captureDeviceActivationCounter--;
            [_captureDeviceSession deactivateForClient:_captureDeviceSessionClient withFrameProcessorClass:aClass];
        }
        if (_frameProcessorClassToCapturedFrameMap != NULL)
            CFDictionaryRemoveValue(_frameProcessorClassToCapturedFrameMap, aClass);
    } else {
        CFDictionarySetValue(_frameProcessorClassToReferenceCountMap, aClass, (const void *)(count - 1));
    }
}

- (void)HSLiveVideoStreamAttributesImplementation_addVideoFrameProcessorClass:(Class)aClass
{
    if (_frameProcessorClassToReferenceCountMap == NULL) {
        _frameProcessorClassToReferenceCountMap = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &NSEClassDictionaryKeyCallBacks, &kCFEUnsignedIntegerDictionaryValueCallBacks);
        if (_frameProcessorClassToReferenceCountMap == NULL)
            return;
    }
    NSUInteger count = (NSUInteger)CFDictionaryGetValue(_frameProcessorClassToReferenceCountMap, aClass);
    CFDictionarySetValue(_frameProcessorClassToReferenceCountMap, aClass, (const void *)(count + 1));
    if (count == 0 && _captureDeviceActivationCounter != 0)
        [self HSLiveVideoStreamAttributesImplementation_activateCaptureDeviceWithFrameProcessorClass:aClass];
}

// Switches to the device at the object's index, moving an active capture
// over to it.
- (void)HSLiveVideoStreamAttributesImplementation_adoptVideoDevicePostingNotifications:(BOOL)aNotifications
{
    NSUInteger index = [_liveVideoObject hyperDeviceIndex];
    id device = index < [_captureDeviceList captureDeviceCount] ? [_captureDeviceList captureDeviceAtIndex:index] : nil;
    if (device == _captureDevice)
        return;
    id attributes = nil;
    if (aNotifications) {
        attributes = [NSEProtocolSet protocolSetWithProtocols:@protocol(HSLiveVideoDeviceAttribute), @protocol(HSVideoFrameAttribute), nil];
        if (attributes != nil)
            [_liveVideoObject notifyChange:1 ofAttributeSet:attributes withUserInfo:nil];
    }
    unsigned int wasActive = _captureDeviceActivationCounter;
    if (_captureDevice != nil) {
        [_captureDevice removeObserver:self forKeyPath:@"inUseByAnotherApplication"];
        [_captureDevice removeObserver:self forKeyPath:@"suspended"];
        if (wasActive != 0)
            [self HSLiveVideoStreamAttributesImplementation_deactivateCaptureDeviceWithContinuousChangeNotification:NO];
        if (_captureDeviceSession != nil) {
            [self HSLiveVideoStreamAttributesImplementation_releaseCaptureDeviceSession];
            _captureDeviceSession = nil;
        }
        if (_frameProcessorClassToCapturedFrameMap != NULL)
            CFDictionaryRemoveAllValues(_frameProcessorClassToCapturedFrameMap);
        [_captureDevice release];
    }
    _captureDevice = [device retain];
    if (_captureDevice != nil) {
        [_captureDevice addObserver:self forKeyPath:@"inUseByAnotherApplication" options:0 context:NULL];
        [_captureDevice addObserver:self forKeyPath:@"suspended" options:0 context:NULL];
        if ([_liveVideoObject isHyperPlaying])
            [self HSLiveVideoStreamAttributesImplementation_activateCaptureDeviceWithContinuousChangeNotification:wasActive == 0];
    }
    if (wasActive != 0 && _captureDeviceActivationCounter == 0)
        [_liveVideoObject endContinuousChangeOfAttribute:@protocol(HSVideoFrameAttribute)];
    if (attributes != nil)
        [_liveVideoObject notifyChange:2 ofAttributeSet:attributes withUserInfo:nil];
}

- (void)HSLiveVideoStreamAttributesImplementation_deactivateCaptureDeviceWithContinuousChangeNotification:(BOOL)aNotification
{
    _captureDeviceActivationCounter = 0;
    [_captureDeviceSession deactivateForClient:_captureDeviceSessionClient];
    [_captureDeviceSessionClient invalidate];
    [_captureDeviceSessionClient release];
    _captureDeviceSessionClient = nil;
    if (aNotification)
        [_liveVideoObject endContinuousChangeOfAttribute:@protocol(HSVideoFrameAttribute)];
}

- (void)HSLiveVideoStreamAttributesImplementation_activateCaptureDeviceWithContinuousChangeNotification:(BOOL)aNotification
{
    if (_frameProcessorClassToReferenceCountMap == NULL)
        return;
    if (_captureDeviceSessionClient == nil) {
        _captureDeviceSessionClient = [[HSLiveVideoStreamAttributesImplementation_HSCaptureDeviceSessionClient alloc] initWithLiveVideoStreamAttributesImplementation:self];
        if (_captureDeviceSessionClient == nil)
            return;
    }
    if ([self HSLiveVideoStreamAttributesImplementation_captureDeviceSession] == nil)
        return;
    CFDictionaryApplyFunction(_frameProcessorClassToReferenceCountMap, HSLiveVideoActivateFrameProcessorClass, self);
    if (aNotification && _captureDeviceActivationCounter != 0)
        [_liveVideoObject beginContinuousChangeOfAttribute:@protocol(HSVideoFrameAttribute)];
}

- (void)HSLiveVideoStreamAttributesImplementation_activateCaptureDeviceWithFrameProcessorClass:(Class)aClass
{
    _captureDeviceActivationCounter++;
    [_captureDeviceSession activateForClient:_captureDeviceSessionClient withFrameProcessorClass:aClass];
}

- (struct __CFDictionary *)HSLiveVideoStreamAttributesImplementation_frameProcessorClassToCapturedFrameMap
{
    if (_frameProcessorClassToCapturedFrameMap == NULL)
        _frameProcessorClassToCapturedFrameMap = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &NSEClassDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    return _frameProcessorClassToCapturedFrameMap;
}

- (void)HSLiveVideoStreamAttributesImplementation_releaseCaptureDeviceSession
{
    NSString *identifier = [NSString stringWithFormat:@"0x%x", (unsigned int)(uintptr_t)self];
    if (identifier != nil)
        [_captureDeviceSession removeFrameDecayIntervalForClientIdentifier:identifier];
    [_captureDeviceSession release];
}

// Frames older than 10 s are dropped for this client.
- (id)HSLiveVideoStreamAttributesImplementation_captureDeviceSession
{
    if (_captureDeviceSession == nil && _captureDevice != nil) {
        NSString *identifier = [NSString stringWithFormat:@"0x%x", (unsigned int)(uintptr_t)self];
        if (identifier != nil) {
            _captureDeviceSession = [[HSCaptureDeviceSession captureDeviceSessionForDevice:_captureDevice] retain];
            [_captureDeviceSession setFrameDecayInterval:10.0 forClientIdentifier:identifier];
        }
    }
    return _captureDeviceSession;
}

@end

// Receives frames from the capture session's threads and hands them to the
// implementation on the main thread, coalescing the frames that arrive in
// between (the latest per processor class).
@implementation HSLiveVideoStreamAttributesImplementation_HSCaptureDeviceSessionClient

- (void)captureDeviceSession:(id)aSession didReceiveFrame:(id)aFrame fromFrameProcessorOfClass:(Class)aClass
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if ([NSThread currentThread] == _mainThread) {
        [_liveVideoStreamAttributesImplementation HSLiveVideoStreamAttributesImplementation_receiveFrame:aFrame fromFrameProcessorOfClass:aClass];
    } else {
        BOOL wasEmpty = NO;
        [_pendingCapturedFramesLock lock];
        if (_frameProcessorClassToPendingCapturedFrameMap == NULL) {
            _frameProcessorClassToPendingCapturedFrameMap = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &NSEClassDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
            wasEmpty = _frameProcessorClassToPendingCapturedFrameMap != NULL;
        } else {
            wasEmpty = CFDictionaryGetCount(_frameProcessorClassToPendingCapturedFrameMap) == 0;
        }
        if (_frameProcessorClassToPendingCapturedFrameMap != NULL)
            CFDictionarySetValue(_frameProcessorClassToPendingCapturedFrameMap, aClass, aFrame);
        [_pendingCapturedFramesLock unlock];
        if (wasEmpty)
            [self performSelectorOnMainThread:@selector(receivePendingFrames) withObject:nil waitUntilDone:NO];
    }
    [pool release];
}

- (void)receivePendingFrames
{
    if (![_liveVideoStreamAttributesImplementation HSLiveVideoStreamAttributesImplementation_preReceiveFrames])
        return;
    [_pendingCapturedFramesLock lock];
    if (_frameProcessorClassToPendingCapturedFrameMap != NULL) {
        [_liveVideoStreamAttributesImplementation HSLiveVideoStreamAttributesImplementation_receiveFrames:_frameProcessorClassToPendingCapturedFrameMap];
        CFDictionaryRemoveAllValues(_frameProcessorClassToPendingCapturedFrameMap);
    }
    [_pendingCapturedFramesLock unlock];
    [_liveVideoStreamAttributesImplementation HSLiveVideoStreamAttributesImplementation_postReceiveFrames];
}

- (void)invalidate
{
    _liveVideoStreamAttributesImplementation = nil;
}

- (void)dealloc
{
    if (_frameProcessorClassToPendingCapturedFrameMap != NULL)
        CFRelease(_frameProcessorClassToPendingCapturedFrameMap);
    [_pendingCapturedFramesLock release];
    [_mainThread release];
    [super dealloc];
}

- (id)initWithLiveVideoStreamAttributesImplementation:(id)aImplementation
{
    self = [super init];
    if (self == nil)
        return nil;
    _pendingCapturedFramesLock = [[NSLock alloc] init];
    if (_pendingCapturedFramesLock != nil) {
        _mainThread = [[NSThread currentThread] retain];
        if (_mainThread != nil) {
            _liveVideoStreamAttributesImplementation = aImplementation;
            return self;
        }
    }
    [self release];
    return nil;
}

@end
