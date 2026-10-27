#import "HSRotateCardObjectTracker.h"
@implementation HSRotateCardObjectTracker
- (void)mouseUp:(id)aUp inView:(id)aView
{
    [self mouseEvent:aUp inView:aView];
    [[[self geometryAttributes] attributeObservingController] endContinuousChangeOfAttribute:@protocol(HSRotationAngleAttribute)];
    [super mouseUp:aUp inView:aView];
}
- (void)postprocessMouseDown:(id)aDown inView:(id)aView
{
    [super postprocessMouseDown:aDown inView:aView];
    id geometry = [self geometryAttributes];
    NSRect frame = [geometry frameBoundingRect];
    _centerPoint.x = frame.origin.x + frame.size.width * 0.5f;
    _centerPoint.y = frame.size.height * 0.5f + frame.origin.y;
    _startObjectAngle = [geometry rotationAngle];
    NSPoint start = [self startPoint];
    _rotationHandleStartAngle = atan2(start.y - _centerPoint.y, start.x - _centerPoint.x);
    [[geometry attributeObservingController] beginContinuousChangeOfAttribute:@protocol(HSRotationAngleAttribute)];
}
- (void)processMouseDragged:(id)aDragged inView:(id)aView
{
    [super processMouseDragged:aDragged inView:aView];
    [self mouseEvent:aDragged inView:aView];
}
- (void)mouseEvent:(id)aEvent inView:(id)aView
{
    NSPoint point = [aView convertPointFromViewSpaceToUserSpace:[aView convertPoint:[aEvent locationInWindow] fromView:nil]];
    float handleAngle = atan2(point.y - _centerPoint.y, point.x - _centerPoint.x);
    // Shift snaps to 45 degrees, Option to 15.
    int step;
    if ([aEvent modifierFlags] & NSEventModifierFlagShift)
        step = 45;
    else if ([aEvent modifierFlags] & NSEventModifierFlagOption)
        step = 15;
    else
        step = 0;
    float angle = (_startObjectAngle - 6.2831855f) - (_rotationHandleStartAngle - handleAngle);
    if (step != 0) {
        int degrees = (int)lroundf(angle * 180.0f / 3.1415927f);
        int quotient = degrees / step;
        int remainder = abs(degrees) % step;
        if (remainder != 0) {
            if ((step - 1) / 2 <= remainder)
                quotient += quotient >= 0 ? 1 : -1;
            degrees = quotient * step;
        }
        angle = (float)degrees * 3.1415927f / 180.0f;
    }
    [[self geometryApplier] rotateTo:angle aboutRelativePoint:NSMakePoint(0.5, 0.5) withLayoutGuidingContext:nil];
}
@end
