#import "HSFrameRotationSelectionTracker.h"

static float HSFrameRotationToleranceScale(float aValue)
{
    return aValue != 0.0f ? fabsf(aValue) : 1.0f;
}

static BOOL HSFrameRotationIsGreaterOrEqual(float aValue, float aValue2)
{
    return aValue >= aValue2 - MAX(HSFrameRotationToleranceScale(aValue), HSFrameRotationToleranceScale(aValue2)) * 0.0005f;
}

// An angle (in radians) brought into [0, 2pi).
static float HSFrameRotationNormalizedAngle(float aAngle)
{
    double fullTurn = M_PI + M_PI;
    if (HSFrameRotationIsGreaterOrEqual(aAngle, fullTurn))
        return (float)(floorf((float)(aAngle / fullTurn)) * M_PI * -2.0 + aAngle);
    if (aAngle < 0.0f) {
        float angle = (float)((floorf((float)(fabsf(aAngle) / fullTurn)) + 1.0) * fullTurn + aAngle);
        if (HSFrameRotationIsGreaterOrEqual(angle, fullTurn))
            angle = (float)(angle + M_PI * -2.0);
        return angle;
    }
    return aAngle;
}

@implementation HSFrameRotationSelectionTracker

- (void)drawRect:(NSRect)aRect inView:(id)aView
{
}

- (void)invalidateSelectionKnobInView:(id)aView
{
    id knob = [self selectionKnob];
    id owner = [self trackingObject];
    NSRect frame = [knob frameForOwner:owner inView:aView];
    [aView setNeedsDisplayOpenGLSurfaceInRect:[knob boundingRectForOwner:owner frame:frame inView:aView]];
}

- (void)mouseUp:(id)aUp inView:(id)aView
{
    [self invalidateSelectionKnobInView:aView];
    [[self selectionKnob] setUsesTrackingKnobPosition:NO];
    [self invalidateSelectionKnobInView:aView];
    [self mouseEvent:aUp inView:aView];
    [[[self geometryAttributes] attributeObservingController] endContinuousChangeOfAttribute:@protocol(HSRotationAngleAttribute)];
    [super mouseUp:aUp inView:aView];
    if ([self layoutGuidingContext] != nil)
        [[self layoutGuidingContext] hideInfoTag];
}

- (void)postprocessMouseDown:(id)aDown inView:(id)aView
{
    [super postprocessMouseDown:aDown inView:aView];
    id geometry = [self geometryAttributes];
    NSRect frame = [geometry frameBoundingRect];
    _centerPoint.x = frame.origin.x + frame.size.width * 0.5;
    _centerPoint.y = frame.size.height * 0.5 + frame.origin.y;
    [self invalidateSelectionKnobInView:aView];
    [[self selectionKnob] setUsesTrackingKnobPosition:[self geometryApplier] != nil];
    [[self selectionKnob] setTrackingKnobPosition:[aView convertPoint:[(NSEvent *)aDown locationInWindow] fromView:nil]];
    [self invalidateSelectionKnobInView:aView];
    [[geometry attributeObservingController] beginContinuousChangeOfAttribute:@protocol(HSRotationAngleAttribute)];
}

- (void)processMouseDragged:(id)aDragged inView:(id)aView
{
    [super processMouseDragged:aDragged inView:aView];
    [self mouseEvent:aDragged inView:aView];
}

- (void)mouseEvent:(id)aEvent inView:(id)aView
{
    NSPoint center = [self centerPoint];
    NSPoint point = [aView convertPoint:[(NSEvent *)aEvent locationInWindow] fromView:nil];
    NSPoint userPoint = [aView convertPointFromViewSpaceToUserSpace:point];
    float angle = atan2(userPoint.y - center.y, userPoint.x - center.x);
    [self invalidateSelectionKnobInView:aView];
    [[self selectionKnob] setTrackingKnobPosition:point];
    [self invalidateSelectionKnobInView:aView];
    float degrees = (((float)(M_PI * 2.0) - HSFrameRotationNormalizedAngle(angle)) / (float)M_PI) * 180.0f;
    if (HSFrameRotationIsGreaterOrEqual(degrees, 360.0f))
        degrees -= 360.0f;
    long rounded = lroundf(degrees);
    int step = 0;
    if ([(NSEvent *)aEvent modifierFlags] & NSEventModifierFlagShift)
        step = 45;
    else if ([(NSEvent *)aEvent modifierFlags] & NSEventModifierFlagOption)
        step = 15;
    if (step != 0) {
        int quotient = (int)rounded / step;
        int remainder = abs((int)rounded) % step;
        if (remainder != 0) {
            if (remainder >= (step - 1) / 2)
                quotient += quotient >= 0 ? 1 : -1;
            rounded = quotient * step;
        }
        angle = HSFrameRotationNormalizedAngle(((float)(int)rounded * (float)M_PI) / -180.0f + (float)(M_PI * 2.0));
    }
    if ([self layoutGuidingContext] != nil) {
        int shown = (int)rounded;
        while (shown > 359)
            shown -= 360;
        if (shown < 0)
            shown = shown + 360 + (int)(((unsigned)~shown / 360) * 360);
        unichar degreeSign = 0x2218;
        [[self layoutGuidingContext] showInfoTagWithString:[NSString stringWithFormat:@"%i %@", shown, [NSString stringWithCharacters:&degreeSign length:1]]];
    }
    [[self geometryApplier] rotateTo:angle aboutRelativePoint:NSMakePoint(0.5, 0.5) withLayoutGuidingContext:nil];
}

- (id)selectionKnob
{
    return [super selectionKnob];
}

- (NSPoint)centerPoint
{
    return _centerPoint;
}

@end
