#import "HyperPlayerBasePrefix.h"


@interface HSMovingCardObjectAnimation : NSObject <HSInteractiveAnimation, NSObject>
{
    HSConcreteCardObject *_animatedObject;
    NSPoint _dstPoint;
    float _radius;
    float _angle;
    float _duration;
    NSTimer *_animationTimer;
    NSDate *_startDate;
    id<HSInteractiveAnimationOwner> _owner;
    int _basePointType;
    BOOL _needsUpdateAnimationParametrs;
}
- (void)timerFireMethod:(id)aMethod;
- (void)stopTimer;
- (id)geometryAttributes;
- (id)geometryApplier;
- (void)recalculateAnimationParametersIfNeeded;
- (void)updateDestinationPoint:(NSPoint)aPoint;
- (void)stop;
- (void)start;
- (double)timerPeriod;
- (void)setOwner:(id)aOwner;
- (void)setBasePointType:(NSInteger)aType;
- (void)setAnimatedObject:(id)aObject;
- (void)dealloc;
- (id)initWithStartPoint:(NSPoint)aPoint dstPoint:(NSPoint)aPoint2 duration:(CGFloat)aDuration;
@end

