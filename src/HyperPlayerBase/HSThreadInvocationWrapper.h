#import "HyperPlayerBasePrefix.h"


@interface HSThreadInvocationWrapper : NSObject
{
    NSInvocation *_invocation;
    id _objectToHold;
    unsigned int _isPending:1;
    unsigned int _isOneShotAllowedInInvalidState:1;
}
+ (id)invocationWrapperWithInvocation:(id)aInvocation objectToHold:(id)aHold forOneShotTimer:(BOOL)aTimer;
- (void)invokeOnMainThread:(struct __CFRunLoopTimer *)aThread;
- (void)HSThreadInvocationWrapper_invoke:(id)aInvoke;
- (void)invalidate;
- (id)invocation;
- (void)dealloc;
- (id)initWithInvocation:(id)aInvocation objectToHold:(id)aHold forOneShotTimer:(BOOL)aTimer;
@end

@interface HSThreadInvocationsContainer : NSObject
{
    struct __CFArray *_invocationsHolder;
    NSLock *_invocationsHolderLock;
}
- (void)invoke;
- (BOOL)addInvocationNotAccumulatively:(id)aAccumulatively;
- (BOOL)addInvocationAccumulatively:(id)aAccumulatively;
- (void)dealloc;
- (id)init;
@end

@interface NSThread (HSExtensions)
+ (id)hyperScheduledThreadTimerWithFireIntervalSinceNow:(double)aNow interval:(double)aInterval mainThreadTarget:(id)aTarget selector:(SEL)aSelector repeats:(BOOL)aRepeats;
+ (id)hyperScheduledThreadTimerWithFireDate:(id)aDate interval:(double)aInterval mainThreadTarget:(id)aTarget selector:(SEL)aSelector repeats:(BOOL)aRepeats;
+ (id)hyperScheduledThreadTimerWithInterval:(double)aInterval mainThreadTarget:(id)aTarget selector:(SEL)aSelector repeats:(BOOL)aRepeats;
+ (id)hyperScheduledThreadTimerWithFireIntervalSinceNow:(double)aNow interval:(double)aInterval mainThreadTarget:(id)aTarget selector:(SEL)aSelector object:(id)aObject repeats:(BOOL)aRepeats;
+ (id)hyperScheduledThreadTimerWithFireDate:(id)aDate interval:(double)aInterval mainThreadTarget:(id)aTarget selector:(SEL)aSelector object:(id)aObject repeats:(BOOL)aRepeats;
+ (id)hyperScheduledThreadTimerWithInterval:(double)aInterval mainThreadTarget:(id)aTarget selector:(SEL)aSelector object:(id)aObject repeats:(BOOL)aRepeats;
+ (id)hyperScheduledThreadTimerWithFireIntervalSinceNow:(double)aNow interval:(double)aInterval mainThreadInvocation:(id)aInvocation repeats:(BOOL)aRepeats;
+ (id)hyperScheduledThreadTimerWithFireDate:(id)aDate interval:(double)aInterval mainThreadInvocation:(id)aInvocation repeats:(BOOL)aRepeats;
+ (id)hyperScheduledThreadTimerWithInterval:(double)aInterval mainThreadInvocation:(id)aInvocation repeats:(BOOL)aRepeats;
+ (void)NSThread_HSExtensions_timerThreadRoutine;
+ (id)NSThreadHSExtensions_hyperScheduledThreadTimerWithFireDate:(double)aDate interval:(double)aInterval mainThreadInvocation:(id)aInvocation repeats:(BOOL)aRepeats setFirstArgument:(BOOL)aArgument;
- (void)hyperInvokeOnMainThread:(id)aThread accumulateIdentical:(BOOL)aIdentical;
- (void)NSThread_HSExtensions_makeObject:(NSUInteger)aObject performSelector:(SEL)aSelector;
@end

