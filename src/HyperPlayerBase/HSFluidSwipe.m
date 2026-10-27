#import "HSFluidSwipe.h"

@implementation HSFluidSwipe

+ (id)swipe
{
    HSFluidSwipe *swipe = [self new];
    [swipe setPhase:0];
    [swipe setIsComplete:NO];
    [swipe setIsCanceled:NO];
    return [swipe autorelease];
}

- (id)description
{
    return [NSString stringWithFormat:@"<gestureAmount:%f phase:%d isComplete:%@>",
            (double)_gestureAmount, _phase, _isComplete ? @"YES" : @"NO"];
}

- (float)gestureAmount
{
    return _gestureAmount;
}

- (void)setGestureAmount:(float)aAmount
{
    _gestureAmount = aAmount;
}

- (unsigned int)phase
{
    return _phase;
}

- (void)setPhase:(unsigned int)aPhase
{
    _phase = aPhase;
}

- (BOOL)isComplete
{
    return _isComplete;
}

- (void)setIsComplete:(BOOL)aFlag
{
    _isComplete = aFlag;
}

- (BOOL)isCanceled
{
    return _isCanceled;
}

- (void)setIsCanceled:(BOOL)aFlag
{
    _isCanceled = aFlag;
}

@end
