#import "HSVectorGraphicsTangentSelectionTracker.h"

@implementation HSVectorGraphicsTangentSelectionTracker

static BOOL HSNearlyEqual(float aValue, float aValue2)
{
    float magnitude = MAX(aValue != 0.0f ? fabsf(aValue) : 1.0f, aValue2 != 0.0f ? fabsf(aValue2) : 1.0f);
    return fabsf(aValue - aValue2) <= magnitude * 0.0005f;
}

// Drags a control point; unless Command is down, the neighbouring element's
// control point mirrors it through the shared anchor.
- (void)mouseEvent:(id)aEvent inView:(id)aView
{
    NSPoint point = [aView convertPointFromViewSpaceToUserSpace:[aView convertPoint:[aEvent locationInWindow] fromView:nil]];
    NSPoint start = [self startPoint];
    if (HSNearlyEqual(start.x, point.x) && HSNearlyEqual(start.y, point.y))
        return;
    [self adjustPoint:&point];
    NSPoint points[3] = { NSZeroPoint, NSZeroPoint, NSZeroPoint };
    id knob = [self selectionKnob];
    NSUInteger index = [knob associatedElementIndex] + ([knob isFirstControlPoint] ? 1 : 0);
    [[self vectorGraphicsAttributes] hyperElementAtIndex:index associatedPoints:points];
    NSPoint anchor = points[0];
    BOOL first = [knob isFirstControlPoint];
    points[first ? 1 : 2] = point;
    [[self mutableVectorGraphicsAttributes] setHyperElementAtIndex:index associatedPoints:points];
    if (!([aEvent modifierFlags] & NSEventModifierFlagCommand)) {
        NSUInteger neighbour = index + (first ? -1 : 1);
        if (neighbour < [[self vectorGraphicsAttributes] hyperElementCount]) {
            [[self vectorGraphicsAttributes] hyperElementAtIndex:neighbour associatedPoints:points];
            if (first)
                points[2] = NSMakePoint(points[0].x + points[0].x - point.x, points[0].y + points[0].y - point.y);
            else
                points[1] = NSMakePoint(anchor.x + anchor.x - point.x, anchor.y + anchor.y - point.y);
            [[self mutableVectorGraphicsAttributes] setHyperElementAtIndex:neighbour associatedPoints:points];
        }
    }
    if ([self layoutGuidingContext] != nil)
        [[self layoutGuidingContext] showAppliedLayoutGuidingRules];
}

@end
