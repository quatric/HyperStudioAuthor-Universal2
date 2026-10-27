#import "HSThreadInvocationWrapper.h"
#import <pthread.h>

// Timers that fire on a shared background "timer thread" and forward to the
// main thread, plus coalesced main-thread invocation queues.

// Timer thread state (all guarded by sTimerThreadLock):
// condition 0 idle, 1 thread requested, 2 thread started.
static NSConditionLock *sTimerThreadLock;
static NSThread *sTimerThread;
static id sTimerThreadProxy;
static CFRunLoopRef sTimerThreadRunLoop;
static CFRunLoopTimerRef sPendingTimer;
static pthread_once_t sTimerThreadLockOnce = PTHREAD_ONCE_INIT;
static HSThreadInvocationsContainer *sMainThreadInvocations;
static pthread_once_t sMainThreadInvocationsOnce = PTHREAD_ONCE_INIT;

static void HSThreadInvocationWrapper_createTimerThreadLock(void)
{
    sTimerThreadLock = [[NSConditionLock alloc] initWithCondition:0];
}
static void HSThreadInvocationWrapper_createMainThreadInvocations(void)
{
    sMainThreadInvocations = [HSThreadInvocationsContainer new];
}
static void HSThreadInvocationWrapper_timerFired(CFRunLoopTimerRef aTimer, void *aInfo)
{
    [(HSThreadInvocationWrapper *)aInfo invokeOnMainThread:aTimer];
}
static const void *HSThreadInvocationWrapper_retainInfo(const void *aInfo)
{
    return [(id)aInfo retain];
}
// The wrapper is released on the timer thread while that thread runs.
static void HSThreadInvocationWrapper_releaseInfo(const void *aInfo)
{
    if (sTimerThread == nil || [NSThread currentThread] == sTimerThread) {
        [(id)aInfo release];
        return;
    }
    [(HSThreadInvocationWrapper *)aInfo invalidate];
    [sTimerThreadProxy NSThread_HSExtensions_makeObject:(NSUInteger)aInfo performSelector:@selector(release)];
}
static const void *HSThreadInvocationsContainer_retain(CFAllocatorRef aAllocator, const void *aValue)
{
    return [(id)aValue retain];
}
static void HSThreadInvocationsContainer_release(CFAllocatorRef aAllocator, const void *aValue)
{
    [(id)aValue release];
}
// Invocations are "identical" when they have the same target and selector.
static Boolean HSThreadInvocationsContainer_equal(const void *aValue1, const void *aValue2)
{
    return [(NSInvocation *)aValue1 target] == [(NSInvocation *)aValue2 target]
        && [(NSInvocation *)aValue1 selector] == [(NSInvocation *)aValue2 selector];
}
static void HSThreadInvocationsContainer_invoke(const void *aValue, void *aContext)
{
    [(NSInvocation *)aValue invoke];
}
static const CFArrayCallBacks HSThreadInvocationsContainer_callBacks = {
    0, HSThreadInvocationsContainer_retain, HSThreadInvocationsContainer_release, NULL, HSThreadInvocationsContainer_equal
};

@implementation HSThreadInvocationWrapper
+ (id)invocationWrapperWithInvocation:(id)aInvocation objectToHold:(id)aHold forOneShotTimer:(BOOL)aTimer
{
    return [[[HSThreadInvocationWrapper alloc] initWithInvocation:aInvocation objectToHold:aHold forOneShotTimer:aTimer] autorelease];
}
// Timer thread side: hand the invocation to the main thread unless one is
// already pending.
- (void)invokeOnMainThread:(struct __CFRunLoopTimer *)aThread
{
    if (!_isPending && CFRunLoopTimerIsValid(aThread)) {
        _isPending = 1;
        [self performSelectorOnMainThread:@selector(HSThreadInvocationWrapper_invoke:) withObject:(id)aThread waitUntilDone:NO];
    }
}
- (void)HSThreadInvocationWrapper_invoke:(id)aInvoke
{
    CFRunLoopTimerRef timer = (CFRunLoopTimerRef)aInvoke;
    if (!_isOneShotAllowedInInvalidState && !CFRunLoopTimerIsValid(timer))
        return;
    [_invocation invoke];
    if (_isOneShotAllowedInInvalidState) {
        CFRunLoopTimerInvalidate(timer);
        _isOneShotAllowedInInvalidState = 0;
    }
    _isPending = 0;
}
- (void)invalidate
{
    _isOneShotAllowedInInvalidState = 0;
}
- (id)invocation
{
    return _invocation;
}
- (void)dealloc
{
    [_invocation release];
    [_objectToHold release];
    [super dealloc];
}
- (id)initWithInvocation:(id)aInvocation objectToHold:(id)aHold forOneShotTimer:(BOOL)aTimer
{
    self = [super init];
    if (self) {
        _invocation = [aInvocation retain];
        _objectToHold = [aHold retain];
        _isOneShotAllowedInInvalidState = aTimer ? 1 : 0;
    }
    return self;
}
@end

@implementation HSThreadInvocationsContainer
// Main thread side: runs everything queued so far.
- (void)invoke
{
    [_invocationsHolderLock lock];
    CFArrayRef invocations = _invocationsHolder;
    _invocationsHolder = CFArrayCreateMutable(NULL, 0, &HSThreadInvocationsContainer_callBacks);
    [_invocationsHolderLock unlock];
    if (invocations) {
        CFArrayApplyFunction(invocations, CFRangeMake(0, CFArrayGetCount(invocations)), HSThreadInvocationsContainer_invoke, NULL);
        CFRelease(invocations);
    }
}
// Replaces an identical queued invocation; returns YES when the queue was empty.
- (BOOL)addInvocationNotAccumulatively:(id)aAccumulatively
{
    const void *value = aAccumulatively;
    BOOL wasEmpty;
    [_invocationsHolderLock lock];
    CFIndex count = CFArrayGetCount(_invocationsHolder);
    if (count == 0) {
        CFArrayAppendValue(_invocationsHolder, value);
        wasEmpty = YES;
    } else {
        CFIndex index = CFArrayGetLastIndexOfValue(_invocationsHolder, CFRangeMake(0, count), value);
        if (index == -1)
            CFArrayAppendValue(_invocationsHolder, value);
        else
            CFArrayReplaceValues(_invocationsHolder, CFRangeMake(index, 1), &value, 1);
        wasEmpty = NO;
    }
    [_invocationsHolderLock unlock];
    return wasEmpty;
}
- (BOOL)addInvocationAccumulatively:(id)aAccumulatively
{
    [_invocationsHolderLock lock];
    CFIndex count = CFArrayGetCount(_invocationsHolder);
    CFArrayAppendValue(_invocationsHolder, aAccumulatively);
    [_invocationsHolderLock unlock];
    return count == 0;
}
- (void)dealloc
{
    [_invocationsHolderLock lock];
    if (_invocationsHolder)
        CFRelease(_invocationsHolder);
    [_invocationsHolderLock unlock];
    [_invocationsHolderLock release];
    [super dealloc];
}
- (id)init
{
    self = [super init];
    if (self) {
        _invocationsHolderLock = [NSLock new];
        if (_invocationsHolderLock == nil) {
            [self release];
            return nil;
        }
        [_invocationsHolderLock lock];
        _invocationsHolder = CFArrayCreateMutable(NULL, 0, &HSThreadInvocationsContainer_callBacks);
        [_invocationsHolderLock unlock];
    }
    return self;
}
@end

@implementation NSThread (HSExtensions)
static NSInvocation *NSThread_HSExtensions_invocation(id aTarget, SEL aSelector)
{
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[aTarget methodSignatureForSelector:aSelector]];
    [invocation setTarget:aTarget];
    [invocation setSelector:aSelector];
    return invocation;
}
// Selectors taking an argument get the timer as their first argument.
+ (id)hyperScheduledThreadTimerWithFireIntervalSinceNow:(double)aNow interval:(double)aInterval mainThreadTarget:(id)aTarget selector:(SEL)aSelector repeats:(BOOL)aRepeats
{
    NSInvocation *invocation = NSThread_HSExtensions_invocation(aTarget, aSelector);
    NSUInteger arguments = [[invocation methodSignature] numberOfArguments];
    id wrapper = [HSThreadInvocationWrapper invocationWrapperWithInvocation:invocation objectToHold:nil forOneShotTimer:!aRepeats];
    return [self NSThreadHSExtensions_hyperScheduledThreadTimerWithFireDate:CFAbsoluteTimeGetCurrent() + aNow interval:aInterval
                                                       mainThreadInvocation:wrapper repeats:aRepeats setFirstArgument:arguments > 2];
}
+ (id)hyperScheduledThreadTimerWithFireDate:(id)aDate interval:(double)aInterval mainThreadTarget:(id)aTarget selector:(SEL)aSelector repeats:(BOOL)aRepeats
{
    NSInvocation *invocation = NSThread_HSExtensions_invocation(aTarget, aSelector);
    NSUInteger arguments = [[invocation methodSignature] numberOfArguments];
    id wrapper = [HSThreadInvocationWrapper invocationWrapperWithInvocation:invocation objectToHold:nil forOneShotTimer:!aRepeats];
    return [self NSThreadHSExtensions_hyperScheduledThreadTimerWithFireDate:[aDate timeIntervalSinceReferenceDate] interval:aInterval
                                                       mainThreadInvocation:wrapper repeats:aRepeats setFirstArgument:arguments > 2];
}
+ (id)hyperScheduledThreadTimerWithInterval:(double)aInterval mainThreadTarget:(id)aTarget selector:(SEL)aSelector repeats:(BOOL)aRepeats
{
    NSInvocation *invocation = NSThread_HSExtensions_invocation(aTarget, aSelector);
    NSUInteger arguments = [[invocation methodSignature] numberOfArguments];
    id wrapper = [HSThreadInvocationWrapper invocationWrapperWithInvocation:invocation objectToHold:nil forOneShotTimer:!aRepeats];
    return [self NSThreadHSExtensions_hyperScheduledThreadTimerWithFireDate:aInterval + CFAbsoluteTimeGetCurrent() interval:aInterval
                                                       mainThreadInvocation:wrapper repeats:aRepeats setFirstArgument:arguments > 2];
}
// The object goes in the second argument and is kept alive by the wrapper.
+ (id)hyperScheduledThreadTimerWithFireIntervalSinceNow:(double)aNow interval:(double)aInterval mainThreadTarget:(id)aTarget selector:(SEL)aSelector object:(id)aObject repeats:(BOOL)aRepeats
{
    id object = aObject;
    NSInvocation *invocation = NSThread_HSExtensions_invocation(aTarget, aSelector);
    NSUInteger arguments = [[invocation methodSignature] numberOfArguments];
    if (arguments > 3)
        [invocation setArgument:&object atIndex:3];
    id wrapper = [HSThreadInvocationWrapper invocationWrapperWithInvocation:invocation objectToHold:object forOneShotTimer:!aRepeats];
    return [self NSThreadHSExtensions_hyperScheduledThreadTimerWithFireDate:aNow + CFAbsoluteTimeGetCurrent() interval:aInterval
                                                       mainThreadInvocation:wrapper repeats:aRepeats setFirstArgument:arguments > 2];
}
+ (id)hyperScheduledThreadTimerWithFireDate:(id)aDate interval:(double)aInterval mainThreadTarget:(id)aTarget selector:(SEL)aSelector object:(id)aObject repeats:(BOOL)aRepeats
{
    id object = aObject;
    NSInvocation *invocation = NSThread_HSExtensions_invocation(aTarget, aSelector);
    NSUInteger arguments = [[invocation methodSignature] numberOfArguments];
    if (arguments > 3)
        [invocation setArgument:&object atIndex:3];
    id wrapper = [HSThreadInvocationWrapper invocationWrapperWithInvocation:invocation objectToHold:object forOneShotTimer:!aRepeats];
    return [self NSThreadHSExtensions_hyperScheduledThreadTimerWithFireDate:[aDate timeIntervalSinceReferenceDate] interval:aInterval
                                                       mainThreadInvocation:wrapper repeats:aRepeats setFirstArgument:arguments > 2];
}
+ (id)hyperScheduledThreadTimerWithInterval:(double)aInterval mainThreadTarget:(id)aTarget selector:(SEL)aSelector object:(id)aObject repeats:(BOOL)aRepeats
{
    id object = aObject;
    NSInvocation *invocation = NSThread_HSExtensions_invocation(aTarget, aSelector);
    NSUInteger arguments = [[invocation methodSignature] numberOfArguments];
    if (arguments > 3)
        [invocation setArgument:&object atIndex:3];
    id wrapper = [HSThreadInvocationWrapper invocationWrapperWithInvocation:invocation objectToHold:object forOneShotTimer:!aRepeats];
    return [self NSThreadHSExtensions_hyperScheduledThreadTimerWithFireDate:aInterval + CFAbsoluteTimeGetCurrent() interval:aInterval
                                                       mainThreadInvocation:wrapper repeats:aRepeats setFirstArgument:arguments > 2];
}
+ (id)hyperScheduledThreadTimerWithFireIntervalSinceNow:(double)aNow interval:(double)aInterval mainThreadInvocation:(id)aInvocation repeats:(BOOL)aRepeats
{
    id wrapper = [HSThreadInvocationWrapper invocationWrapperWithInvocation:aInvocation objectToHold:nil forOneShotTimer:!aRepeats];
    return [self NSThreadHSExtensions_hyperScheduledThreadTimerWithFireDate:CFAbsoluteTimeGetCurrent() + aNow interval:aInterval
                                                       mainThreadInvocation:wrapper repeats:aRepeats setFirstArgument:NO];
}
+ (id)hyperScheduledThreadTimerWithFireDate:(id)aDate interval:(double)aInterval mainThreadInvocation:(id)aInvocation repeats:(BOOL)aRepeats
{
    id wrapper = [HSThreadInvocationWrapper invocationWrapperWithInvocation:aInvocation objectToHold:nil forOneShotTimer:!aRepeats];
    return [self NSThreadHSExtensions_hyperScheduledThreadTimerWithFireDate:[aDate timeIntervalSinceReferenceDate] interval:aInterval
                                                       mainThreadInvocation:wrapper repeats:aRepeats setFirstArgument:NO];
}
+ (id)hyperScheduledThreadTimerWithInterval:(double)aInterval mainThreadInvocation:(id)aInvocation repeats:(BOOL)aRepeats
{
    id wrapper = [HSThreadInvocationWrapper invocationWrapperWithInvocation:aInvocation objectToHold:nil forOneShotTimer:!aRepeats];
    return [self NSThreadHSExtensions_hyperScheduledThreadTimerWithFireDate:aInterval + CFAbsoluteTimeGetCurrent() interval:aInterval
                                                       mainThreadInvocation:wrapper repeats:aRepeats setFirstArgument:NO];
}
// Body of the timer thread: runs its run loop until no timers are left.
+ (void)NSThread_HSExtensions_timerThreadRoutine
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    [sTimerThreadLock lockWhenCondition:1];
    sTimerThread = [NSThread currentThread];
    // The original publishes the thread through a Distributed Objects root
    // proxy (NSConnection); the thread object itself serves that role here.
    sTimerThreadProxy = [sTimerThread retain];
    if (sTimerThreadProxy) {
        sTimerThreadRunLoop = CFRunLoopGetCurrent();
        CFRunLoopAddTimer(sTimerThreadRunLoop, sPendingTimer, kCFRunLoopDefaultMode);
        sPendingTimer = NULL;
    } else {
        sTimerThread = nil;
    }
    [sTimerThreadLock unlockWithCondition:2];
    while (sTimerThread) {
        if (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 30.0, false) == kCFRunLoopRunFinished) {
            [sTimerThreadLock lock];
            if (sPendingTimer == NULL) {
                // No timer is being added concurrently: stop the thread.
                sTimerThread = nil;
                [sTimerThreadProxy release];
                sTimerThreadProxy = nil;
                sTimerThreadRunLoop = NULL;
            } else {
                sPendingTimer = NULL;
            }
            [sTimerThreadLock unlock];
        }
    }
    [pool release];
}
+ (id)NSThreadHSExtensions_hyperScheduledThreadTimerWithFireDate:(double)aDate interval:(double)aInterval mainThreadInvocation:(id)aInvocation repeats:(BOOL)aRepeats setFirstArgument:(BOOL)aArgument
{
    if (aInvocation == nil)
        return nil;
    CFRunLoopTimerContext context = { 0, aInvocation, HSThreadInvocationWrapper_retainInfo, HSThreadInvocationWrapper_releaseInfo, NULL };
    double interval;
    if (!aRepeats)
        interval = DBL_MAX;
    else
        interval = aInterval <= 0.0 ? 1e-06 : aInterval;
    CFRunLoopTimerRef timer = CFRunLoopTimerCreate(NULL, aDate, interval, 0, 0, HSThreadInvocationWrapper_timerFired, &context);
    if (timer) {
        pthread_once(&sTimerThreadLockOnce, HSThreadInvocationWrapper_createTimerThreadLock);
        if (aArgument)
            [[aInvocation invocation] setArgument:&timer atIndex:2];
        [sTimerThreadLock lockWhenCondition:0];
        sPendingTimer = timer;
        if (sTimerThread == nil) {
            [NSThread detachNewThreadSelector:@selector(NSThread_HSExtensions_timerThreadRoutine) toTarget:[NSThread class] withObject:nil];
            [sTimerThreadLock unlockWithCondition:1];
            [sTimerThreadLock lockWhenCondition:2];
            [sTimerThreadLock unlockWithCondition:0];
            if (sTimerThread == nil) {
                CFRelease(timer);
                timer = NULL;
            }
        } else {
            [sTimerThreadLock unlockWithCondition:0];
            CFRunLoopAddTimer(sTimerThreadRunLoop, timer, kCFRunLoopDefaultMode);
        }
    }
    return [(id)timer autorelease];
}
- (void)hyperInvokeOnMainThread:(id)aThread accumulateIdentical:(BOOL)aIdentical
{
    if (aThread == nil)
        return;
    pthread_once(&sMainThreadInvocationsOnce, HSThreadInvocationWrapper_createMainThreadInvocations);
    BOOL wasEmpty = aIdentical ? [sMainThreadInvocations addInvocationAccumulatively:aThread]
                               : [sMainThreadInvocations addInvocationNotAccumulatively:aThread];
    if (wasEmpty)
        [sMainThreadInvocations performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:NO];
}
- (void)NSThread_HSExtensions_makeObject:(NSUInteger)aObject performSelector:(SEL)aSelector
{
    if (self == sTimerThread && [NSThread currentThread] != self) {
        // Runs on the timer thread (the original messages its DO proxy).
        [(id)aObject performSelector:aSelector onThread:self withObject:nil waitUntilDone:NO];
        return;
    }
    [(id)aObject performSelector:aSelector];
}
@end
