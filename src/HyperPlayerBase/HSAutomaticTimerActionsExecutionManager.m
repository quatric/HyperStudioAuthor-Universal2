#import "HSAutomaticTimerActionsExecutionManager.h"
#import "HSActionEvent.h"
#import "HSActionExecutionContext.h"
#import "HSFunctions.h"
#import "SMKApplicationKitData.h"

// Context for stopping the timers of all cards: the stack's own timer is
// kept and put back afterwards.
typedef struct {
    HSAutomaticTimerActionsExecutionManager *manager;
    id stack;
    NSTimer *stackTimer;
} HSAutomaticTimerKeepStackContext;

typedef struct {
    id stack;
    NSTimer *stackTimer;
} HSAutomaticArriveTimerKeepStackContext;

static void HSAutomaticTimerStopObservingAndInvalidate(const void *aKey, const void *aValue, void *aContext)
{
    [[[(id)aKey queryHyperInterface:@protocol(HSCardObjectAttributes)] attributeObservingController]
        removeObserver:(id)aContext selector:@selector(HSAutomaticTimerActionsExecutionManager_objectVisibilityDidChange:)
             ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSCardObjectHiddenAttribute)];
    [(NSTimer *)aValue invalidate];
}

static void HSAutomaticTimerInvalidate(const void *aKey, const void *aValue, void *aContext)
{
    [(NSTimer *)aValue invalidate];
}

static void HSAutomaticTimerInvalidateKeepingStack(const void *aKey, const void *aValue, void *aContext)
{
    HSAutomaticTimerKeepStackContext *context = aContext;
    if ([(id)aKey implementsHyperInterface:@protocol(HSStackAttributes)]) {
        context->stack = (id)aKey;
        context->stackTimer = [(NSTimer *)aValue retain];
        return;
    }
    [[[(id)aKey queryHyperInterface:@protocol(HSCardObjectAttributes)] attributeObservingController]
        removeObserver:context->manager selector:@selector(HSAutomaticTimerActionsExecutionManager_objectVisibilityDidChange:)
             ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSCardObjectHiddenAttribute)];
    [(NSTimer *)aValue invalidate];
}

// Same as above for the arrive timers, which are not observed.
static void HSAutomaticArriveTimerInvalidateKeepingStack(const void *aKey, const void *aValue, void *aContext)
{
    HSAutomaticArriveTimerKeepStackContext *context = aContext;
    if ([(id)aKey implementsHyperInterface:@protocol(HSStackAttributes)]) {
        context->stack = (id)aKey;
        context->stackTimer = [(NSTimer *)aValue retain];
        return;
    }
    [(NSTimer *)aValue invalidate];
}

static void HSAutomaticTimerPause(const void *aKey, const void *aValue, void *aContext)
{
    CFRunLoopTimerRef timer = (CFRunLoopTimerRef)aValue;
    __HSAutomaticTimerInfo *info = [(NSTimer *)aValue userInfo];
    [info setTimeLeftAfterResume:CFRunLoopTimerGetNextFireDate(timer) - *(CFAbsoluteTime *)aContext];
    CFRunLoopTimerSetNextFireDate(timer, DBL_MAX);
}

static void HSAutomaticTimerResume(const void *aKey, const void *aValue, void *aContext)
{
    __HSAutomaticTimerInfo *info = [(NSTimer *)aValue userInfo];
    if ([[[info object] queryHyperInterface:@protocol(HSCardObjectAttributes)] isHiddenInPlayer])
        return;
    CFRunLoopTimerSetNextFireDate((CFRunLoopTimerRef)aValue, [info timeLeftAfterResume] + *(CFAbsoluteTime *)aContext);
}

@implementation HSAutomaticTimerActionsExecutionManager

- (void)actionQueueDidStop:(id)aStop
{
    [_actionQueuesToStopIfNeeded removeObject:[aStop object]];
}

// Queues delayed from automatic actions are stopped with the timers.
- (void)actionQueue:(id)aQueue didSetupDelayTimer:(id)aTimer
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionQueueDidStop:)
                                                 name:@"HSActionQueueDidFinishNotification" object:aQueue];
    if (_actionQueuesToStopIfNeeded == nil)
        _actionQueuesToStopIfNeeded = [[NSMutableSet alloc] init];
    [_actionQueuesToStopIfNeeded addObject:aQueue];
}

- (void)HSAutomaticTimerActionsExecutionManager_automaticTimerFired:(id)aFired
{
    __HSAutomaticTimerInfo *info = [[aFired userInfo] retain];
    if ([aFired timeInterval] != 0.0) {
        if (![info repeats])
            [aFired setFireDate:[NSDate dateWithTimeIntervalSinceNow:DBL_MAX]];
    } else {
        id object = [info object];
        if ([[info actionEvent] isEqual:[HSActionEvent actionEventOfType:kHSArriveActionEventType]])
            CFDictionaryRemoveValue(_objectToArriveTimerMap, object);
    }
    [info runActionsIfNeeded];
    [info release];
}

// Hidden objects keep their timer parked in the distant future.
- (void)HSAutomaticTimerActionsExecutionManager_objectVisibilityDidChange:(id)aChange
{
    id object = [aChange object];
    BOOL hidden = [[object queryHyperInterface:@protocol(HSCardObjectAttributes)] isHiddenInPlayer];
    NSTimer *timer = (NSTimer *)CFDictionaryGetValue(_objectToTimerMap, object);
    NSDate *fireDate;
    if (!hidden) {
        fireDate = [NSDate dateWithTimeIntervalSinceNow:[(__HSAutomaticTimerInfo *)[timer userInfo] timeLeft]];
        if (fireDate == nil)
            return;
    } else {
        fireDate = [NSDate dateWithTimeIntervalSinceNow:DBL_MAX];
    }
    [timer setFireDate:fireDate];
}

- (BOOL)isAutomaticTimerActionsForStackRunning
{
    return _isAutomaticTimerActionsForStackRunning;
}

- (BOOL)isAutomaticTimerActionsForCardRunning
{
    return _isAutomaticTimerActionsForCardRunning;
}

- (BOOL)isRunningAutomaticTimer
{
    if (_objectToArriveTimerMap != NULL && CFDictionaryGetCount(_objectToArriveTimerMap) > 0)
        return YES;
    return _objectToTimerMap != NULL && CFDictionaryGetCount(_objectToTimerMap) > 0;
}

- (void)resumeAutomaticTimer
{
    if (!_isPaused)
        return;
    _isPaused = NO;
    CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
    if (_objectToArriveTimerMap != NULL)
        CFDictionaryApplyFunction(_objectToArriveTimerMap, HSAutomaticTimerResume, &now);
    if (_objectToTimerMap != NULL)
        CFDictionaryApplyFunction(_objectToTimerMap, HSAutomaticTimerResume, &now);
}

- (void)pauseAutomaticTimer
{
    _isPaused = YES;
    CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
    if (_objectToArriveTimerMap != NULL)
        CFDictionaryApplyFunction(_objectToArriveTimerMap, HSAutomaticTimerPause, &now);
    if (_objectToTimerMap != NULL)
        CFDictionaryApplyFunction(_objectToTimerMap, HSAutomaticTimerPause, &now);
}

- (void)stopAllAutomaticActionTimers
{
    _isAutomaticTimerActionsForCardRunning = NO;
    _isAutomaticTimerActionsForStackRunning = NO;
    if (_objectToArriveTimerMap != NULL) {
        CFDictionaryApplyFunction(_objectToArriveTimerMap, HSAutomaticTimerInvalidate, NULL);
        CFDictionaryRemoveAllValues(_objectToArriveTimerMap);
    }
    if (_objectToTimerMap != NULL) {
        CFDictionaryApplyFunction(_objectToTimerMap, HSAutomaticTimerStopObservingAndInvalidate, self);
        CFDictionaryRemoveAllValues(_objectToTimerMap);
    }
    [_actionQueuesToStopIfNeeded makeObjectsPerformSelector:@selector(stop:) withObject:nil];
}

- (void)stopAllAutomaticActionTimersForAllCards
{
    [self stopAllAutomaticActionTimersForCard:nil];
}

// With a nil card every timer except the stack's is stopped.
- (void)stopAllAutomaticActionTimersForCard:(id)aCard
{
    _isAutomaticTimerActionsForCardRunning = NO;
    if (_objectToArriveTimerMap != NULL && CFDictionaryGetCount(_objectToArriveTimerMap) != 0) {
        if (aCard == nil) {
            HSAutomaticArriveTimerKeepStackContext context = { nil, nil };
            CFDictionaryApplyFunction(_objectToArriveTimerMap, HSAutomaticArriveTimerInvalidateKeepingStack, &context);
            CFDictionaryRemoveAllValues(_objectToArriveTimerMap);
            if (context.stackTimer != nil) {
                CFDictionarySetValue(_objectToArriveTimerMap, context.stack, context.stackTimer);
                [context.stackTimer release];
            }
        } else {
            NSTimer *timer = (NSTimer *)CFDictionaryGetValue(_objectToArriveTimerMap, aCard);
            if (timer != nil) {
                [timer invalidate];
                CFDictionaryRemoveValue(_objectToArriveTimerMap, aCard);
            }
        }
    }
    if (_objectToTimerMap != NULL && CFDictionaryGetCount(_objectToTimerMap) != 0) {
        if (aCard == nil) {
            HSAutomaticTimerKeepStackContext context = { self, nil, nil };
            CFDictionaryApplyFunction(_objectToTimerMap, HSAutomaticTimerInvalidateKeepingStack, &context);
            CFDictionaryRemoveAllValues(_objectToTimerMap);
            if (context.stackTimer != nil) {
                CFDictionarySetValue(_objectToTimerMap, context.stack, context.stackTimer);
                [context.stackTimer release];
            }
        } else {
            NSUInteger count = [aCard hyperCount];
            NSTimer *timer = (NSTimer *)CFDictionaryGetValue(_objectToTimerMap, aCard);
            if (timer != nil) {
                [timer invalidate];
                CFDictionaryRemoveValue(_objectToTimerMap, aCard);
            }
            for (NSUInteger i = 0; i < count; i++) {
                id child = [aCard hyperChildAtIndex:i];
                NSTimer *childTimer = (NSTimer *)CFDictionaryGetValue(_objectToTimerMap, child);
                if (childTimer != nil) {
                    [[[child queryHyperInterface:@protocol(HSCardObjectAttributes)] attributeObservingController]
                        removeObserver:self selector:@selector(HSAutomaticTimerActionsExecutionManager_objectVisibilityDidChange:)
                             ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSCardObjectHiddenAttribute)];
                    [childTimer invalidate];
                    CFDictionaryRemoveValue(_objectToTimerMap, child);
                }
            }
        }
    }
}

- (void)runAutomaticTimerActionsForStack:(id)aStack withContext:(id)aContext actionEvent:(id)aEvent
{
    _isAutomaticTimerActionsForStackRunning = YES;
    id timer = [[aStack queryHyperInterface:@protocol(HSActor)] automaticTimerForActionEvent:aEvent];
    if ([timer runActionsAutomatically])
        [self startAutomaticTimerActionsForObject:aStack withContext:aContext delay:[timer delayBeforeRunActionsAutomatically] actionEvent:aEvent];
}

// On arrive, the default-event timers of the card's objects start too.
- (void)runAutomaticActionTimersForCard:(id)aCard withContext:(id)aContext actionEvent:(id)aEvent
{
    _isAutomaticTimerActionsForCardRunning = YES;
    if ([aEvent isEqual:[HSActionEvent actionEventOfType:kHSArriveActionEventType]]) {
        HSActionEvent *defaultEvent = [HSActionEvent actionEventOfType:kHSDefaultActionEventType];
        NSUInteger count = [aCard hyperCount];
        for (NSUInteger i = 0; i < count; i++) {
            id child = [aCard hyperChildAtIndex:i];
            id timerSettings = [[child queryHyperInterface:@protocol(HSActor)] automaticTimerForActionEvent:defaultEvent];
            if (![timerSettings runActionsAutomatically])
                continue;
            id cardObject = [child queryHyperInterface:@protocol(HSCardObjectAttributes)];
            BOOL hidden = [cardObject isHiddenInPlayer];
            id requestor = [[aContext navigationController] presentationSync];
            NSTimer *timer = [self HSAutomaticTimerActionsExecutionManager_automaticTimerForObject:child actionEvent:defaultEvent inContext:aContext
                                                                                            paused:(_isPaused || hidden)
                                                                                         withDelay:[timerSettings delayBeforeRunActionsAutomatically]
                                                                                         requestor:requestor];
            if (timer != nil) {
                [[cardObject attributeObservingController] addObserver:self selector:@selector(HSAutomaticTimerActionsExecutionManager_objectVisibilityDidChange:)
                                                             ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSCardObjectHiddenAttribute) withPriority:-0.25];
                [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
            }
        }
    }
    id timer = [[aCard queryHyperInterface:@protocol(HSActor)] automaticTimerForActionEvent:aEvent];
    if ([timer runActionsAutomatically])
        [self startAutomaticTimerActionsForObject:aCard withContext:aContext delay:[timer delayBeforeRunActionsAutomatically] actionEvent:aEvent];
}

- (void)startAutomaticTimerActionsForObject:(id)aObject withContext:(id)aContext delay:(double)aDelay actionEvent:(id)aEvent
{
    [self startAutomaticTimerActionsForObject:aObject withContext:aContext delay:aDelay actionEvent:aEvent
                                    requestor:[[aContext navigationController] presentationSync]];
}

- (void)startAutomaticTimerActionsForObject:(id)aObject withContext:(id)aContext delay:(double)aDelay actionEvent:(id)aEvent requestor:(id)aRequestor
{
    NSTimer *timer = [self HSAutomaticTimerActionsExecutionManager_automaticTimerForObject:aObject actionEvent:aEvent inContext:aContext
                                                                                    paused:_isPaused withDelay:aDelay requestor:aRequestor];
    if (timer != nil)
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

// Creates the timer (not yet scheduled) and records it per object; arrive
// timers live in their own map. A paused timer fires in the distant future
// and remembers its delay for resuming.
- (id)HSAutomaticTimerActionsExecutionManager_automaticTimerForObject:(id)aObject actionEvent:(id)aEvent inContext:(id)aContext paused:(BOOL)aPaused withDelay:(double)aDelay requestor:(id)aRequestor
{
    CFMutableDictionaryRef *map;
    if ([aEvent isEqual:[HSActionEvent actionEventOfType:kHSArriveActionEventType]])
        map = &_objectToArriveTimerMap;
    else
        map = &_objectToTimerMap;
    if (*map == NULL) {
        *map = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFEObjectPointerDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        if (*map == NULL)
            return nil;
    }
    __HSAutomaticTimerInfo *info = [[[__HSAutomaticTimerInfo alloc] initWithObject:aObject actionEvent:aEvent executionContext:aContext requestor:aRequestor] autorelease];
    if (info == nil)
        return nil;
    [info setTimeLeft:aDelay];
    NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:aPaused ? DBL_MAX : aDelay];
    if (fireDate == nil)
        return nil;
    if (aPaused)
        [info setTimeLeftAfterResume:aDelay];
    id timerSettings = [[aObject queryHyperInterface:@protocol(HSActor)] automaticTimerForActionEvent:aEvent];
    if (timerSettings == nil)
        return nil;
    double interval = [timerSettings delayBetweenRepeatingActions];
    if (interval < 0.0001 && interval != 0.0)
        interval = 0.0001;
    [info setRepeats:interval != 0.0];
    NSTimer *timer = [[[NSTimer alloc] initWithFireDate:fireDate interval:interval target:self
                                               selector:@selector(HSAutomaticTimerActionsExecutionManager_automaticTimerFired:)
                                               userInfo:info repeats:YES] autorelease];
    if (timer != nil)
        CFDictionarySetValue(*map, aObject, timer);
    return timer;
}

- (void)dealloc
{
    if (_actionQueuesToStopIfNeeded != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSActionQueueDidFinishNotification" object:nil];
        [_actionQueuesToStopIfNeeded release];
    }
    if (_objectToArriveTimerMap != NULL) {
        CFDictionaryApplyFunction(_objectToArriveTimerMap, HSAutomaticTimerInvalidate, NULL);
        CFRelease(_objectToArriveTimerMap);
    }
    if (_objectToTimerMap != NULL) {
        CFDictionaryApplyFunction(_objectToTimerMap, HSAutomaticTimerStopObservingAndInvalidate, self);
        CFRelease(_objectToTimerMap);
    }
    [super dealloc];
}

@end

@implementation __HSAutomaticTimerInfo

- (void)__HSAutomaticTimer_actionsForObjectDidFinish:(id)aFinish
{
    if ([[[aFinish userInfo] objectForKey:@"HSActionsForObjectDidFinishEventKey"] isEqual:_actionEvent]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSActionsForObjectDidFinishNotification" object:_object];
        _isBusy = NO;
    }
}

// Actions are not restarted while the previous run is still going.
- (void)runActionsIfNeeded
{
    if (_isBusy)
        return;
    NSArray *objects = [NSArray arrayWithObject:_object];
    if (objects == nil)
        return;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(__HSAutomaticTimer_actionsForObjectDidFinish:)
                                                 name:@"HSActionsForObjectDidFinishNotification" object:_object];
    _isBusy = YES;
    id animationController = [_actionExecutionContext animationController];
    [animationController beginContiniousPlayAnimationActionsStarting];
    [_actionExecutionContext runActionsForObjects:objects forRequestor:_requestor actionEvent:_actionEvent];
    [animationController endContiniousPlayAnimationActionsStarting];
}

- (void)setRepeats:(BOOL)aRepeats
{
    _isRepeats = aRepeats;
}

- (BOOL)repeats
{
    return _isRepeats;
}

- (void)setTimeLeftAfterResume:(double)aResume
{
    _timeLeftAfterResume = aResume;
}

- (double)timeLeftAfterResume
{
    return _timeLeftAfterResume;
}

- (void)setTimeLeft:(double)aLeft
{
    _timeLeft = aLeft;
}

- (double)timeLeft
{
    return _timeLeft;
}

- (id)actionEvent
{
    return _actionEvent;
}

- (id)object
{
    return _object;
}

- (void)dealloc
{
    if (_isBusy && _object != nil)
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSActionsForObjectDidFinishNotification" object:_object];
    [_object release];
    [_actionEvent release];
    [_actionExecutionContext release];
    [_requestor release];
    [super dealloc];
}

- (id)initWithObject:(id)aObject actionEvent:(id)aEvent executionContext:(id)aContext requestor:(id)aRequestor
{
    self = [super init];
    if (self != nil) {
        _object = [aObject retain];
        _actionEvent = [aEvent retain];
        _actionExecutionContext = [aContext retain];
        _requestor = [aRequestor retain];
    }
    return self;
}

- (id)init
{
    [self release];
    return nil;
}

@end
