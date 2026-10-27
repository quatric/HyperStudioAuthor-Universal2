#import "HyperPlayerBasePrefix.h"


@interface HSFluidSwipe : NSObject
{
    float _gestureAmount;
    unsigned int _phase;
    BOOL _isComplete;
    BOOL _isCanceled;
}
+ (id)swipe;
- (id)description;
- (float)gestureAmount;
- (void)setGestureAmount:(float)aAmount;
- (unsigned int)phase;
- (void)setPhase:(unsigned int)aPhase;
- (BOOL)isComplete;
- (void)setIsComplete:(BOOL)aFlag;
- (BOOL)isCanceled;
- (void)setIsCanceled:(BOOL)aFlag;
@end
