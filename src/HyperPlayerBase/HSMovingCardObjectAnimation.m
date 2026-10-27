#import "HSMovingCardObjectAnimation.h"
// Moves a card object in a straight line to a destination point over a
// duration, 60 times a second. The position is kept in polar form around
// the destination: the radius shrinks linearly to 0. The base point is the
// object's center (type 0) or its frame origin. Moves aren't undoable.

// The angle from aPoint seen from the destination.
static float HSMovingCardObjectAngle(NSPoint aPoint, NSPoint aDestination)
{
    float angle = atanf((aDestination.y - aPoint.y) / (aDestination.x - aPoint.x));
    if (aPoint.x < aDestination.x)
        angle += (float)M_PI;
    return angle;
}

@implementation HSMovingCardObjectAnimation

- (void)timerFireMethod:(id)aMethod
{
    [self recalculateAnimationParametersIfNeeded];
    NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceDate:_startDate];
    float angle = _angle;
    [[_animatedObject undoManager] disableUndoRegistration];
    double remaining = ((double)_duration - elapsed) / (double)_duration;
    if (remaining <= 0)
        remaining = 0;
    float radius = (float)((double)_radius * remaining);
    NSPoint point = NSMakePoint(radius * (float)cos(angle) + _dstPoint.x, (float)sin(angle) * radius + _dstPoint.y);
    if (_basePointType == 0)
        [[self geometryApplier] moveCenterTo:point withLayoutGuidingContext:nil];
    else
        [[self geometryApplier] moveFrameBoundingRectOriginTo:point withLayoutGuidingContext:nil];
    [[_animatedObject undoManager] enableUndoRegistration];
    if (remaining <= 0)
        [self stop];
}

- (void)stopTimer
{
    [_animationTimer invalidate];
    [_animationTimer release];
    _animationTimer = nil;
}

- (id)geometryAttributes
{
    return [_animatedObject queryHyperInterface:@protocol(HSGeometryAttributes)];
}

- (id)geometryApplier
{
    return [[_animatedObject queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
}

// After the destination changes, the motion restarts from the object's
// frame origin (whatever the base point type).
- (void)recalculateAnimationParametersIfNeeded
{
    if (!_needsUpdateAnimationParametrs)
        return;
    NSPoint origin = [[self geometryAttributes] frameBoundingRect].origin;
    float dx = _dstPoint.x - origin.x;
    float dy = _dstPoint.y - origin.y;
    _angle = HSMovingCardObjectAngle(origin, _dstPoint);
    _radius = sqrtf(dx * dx + dy * dy);
    _needsUpdateAnimationParametrs = NO;
}

- (void)updateDestinationPoint:(NSPoint)aPoint
{
    _dstPoint = aPoint;
    _needsUpdateAnimationParametrs = YES;
}

- (void)stop
{
    [self stopTimer];
    [_startDate release];
    _startDate = nil;
    [[[self geometryAttributes] attributeObservingController] endContinuousChangeOfAttributeSet:
        [NSEProtocolSet protocolSetWithProtocols:@protocol(HSHorizontalOffsetAttribute), @protocol(HSVerticalOffsetAttribute), nil]];
    [_owner animationDidFinishForAnimatedObject:_animatedObject];
}

- (void)start
{
    // (The original leaks the date set by the initializer.)
    [_startDate release];
    _startDate = [[NSDate date] retain];
    if (!_animationTimer)
        _animationTimer = [[NSThread hyperScheduledThreadTimerWithInterval:[self timerPeriod] mainThreadTarget:self selector:@selector(timerFireMethod:) repeats:YES] retain];
    [[[self geometryAttributes] attributeObservingController] beginContinuousChangeOfAttributeSet:
        [NSEProtocolSet protocolSetWithProtocols:@protocol(HSHorizontalOffsetAttribute), @protocol(HSVerticalOffsetAttribute), nil]];
}

- (double)timerPeriod
{
    return 1.0 / 60.0;
}

- (void)setOwner:(id)aOwner
{
    _owner = aOwner;
}

- (void)setBasePointType:(NSInteger)aType
{
    _basePointType = (int)aType;
}

- (void)setAnimatedObject:(id)aObject
{
    if (_animatedObject != aObject) {
        [_animatedObject release];
        _animatedObject = [aObject retain];
    }
}

- (void)dealloc
{
    [_animatedObject release];
    [self stopTimer];
    [_startDate release];
    _startDate = nil;
    [super dealloc];
}

- (id)initWithStartPoint:(NSPoint)aPoint dstPoint:(NSPoint)aPoint2 duration:(CGFloat)aDuration
{
    self = [super init];
    if (self) {
        float dx = aPoint2.x - aPoint.x;
        float dy = aPoint2.y - aPoint.y;
        _angle = HSMovingCardObjectAngle(aPoint, aPoint2);
        _radius = sqrtf(dx * dx + dy * dy);
        _dstPoint = aPoint2;
        _duration = aDuration;
        _startDate = [[NSDate date] retain];
    }
    return self;
}

@end
