#import "HSVectorGraphicsSelectionTracker.h"

static BOOL HSVectorTrackerFloatsAreEqual(float aValue1, float aValue2)
{
    float scale1 = aValue1 != 0.0f ? fabsf(aValue1) : 1.0f;
    float scale2 = aValue2 != 0.0f ? fabsf(aValue2) : 1.0f;
    return fabsf(aValue1 - aValue2) <= MAX(scale1, scale2) * 0.0005f;
}

@implementation HSVectorGraphicsSelectionTracker

- (void)mouseUp:(id)aUp inView:(id)aView
{
    [self mouseEvent:aUp inView:aView];
    [super mouseUp:aUp inView:aView];
}

- (void)processMouseDragged:(id)aDragged inView:(id)aView
{
    [super processMouseDragged:aDragged inView:aView];
    [self mouseEvent:aDragged inView:aView];
}

- (void)mouseEvent:(id)aEvent inView:(id)aView
{
    NSPoint point = [aView convertPointFromViewSpaceToUserSpace:[aView convertPoint:[(NSEvent *)aEvent locationInWindow] fromView:nil]];
    NSPoint startPoint = [self startPoint];
    if (HSVectorTrackerFloatsAreEqual(startPoint.x, point.x) && HSVectorTrackerFloatsAreEqual(startPoint.y, point.y))
        return;
    if ([[self layoutGuidingContext] isSnappingEnabled])
        [self adjustPoint:&point];
    NSPoint points[3] = { NSZeroPoint, NSZeroPoint, NSZeroPoint };
    NSUInteger index = [[self selectionKnob] associatedElementIndex];
    [[self vectorGraphicsAttributes] hyperElementAtIndex:index associatedPoints:points];
    float deltaX = points[0].x - point.x;
    float deltaY = points[0].y - point.y;
    points[2].x -= deltaX;
    points[2].y -= deltaY;
    points[0] = point;
    [[self mutableVectorGraphicsAttributes] setHyperElementAtIndex:index associatedPoints:points];
    NSUInteger nextIndex = index + 1;
    if (nextIndex < [[self vectorGraphicsAttributes] hyperElementCount]) {
        [[self mutableVectorGraphicsAttributes] hyperElementAtIndex:nextIndex associatedPoints:points];
        points[1].x -= deltaX;
        points[1].y -= deltaY;
        [[self mutableVectorGraphicsAttributes] setHyperElementAtIndex:nextIndex associatedPoints:points];
    }
    if ([self layoutGuidingContext] != nil)
        [[self layoutGuidingContext] showAppliedLayoutGuidingRules];
}

- (BOOL)adjustPoint:(NSPoint *)aPoint
{
    if ([self layoutGuidingContext] == nil || ![[self layoutGuidingContext] isSnappingEnabled])
        return NO;
    NSPoint original = *aPoint;
    NSRect rect = NSMakeRect(original.x, original.y, 1.0, 1.0);
    id rules = nil;
    id layoutObject = [[self trackingObject] queryHyperInterface:@protocol(HSCardObjectLayoutGuidingInterface)];
    [layoutObject setHyperIgnoredInLayoutGuiding:YES];
    BOOL adjusted = NO;
    if ([[[self layoutGuidingContext] layoutGuidingProcessor] snapRect:&rect edges:3 transformationDirectionHint:NSZeroSize appliedRules:&rules] && !NSEqualPoints(rect.origin, original)) {
        *aPoint = rect.origin;
        adjusted = YES;
    }
    [layoutObject setHyperIgnoredInLayoutGuiding:NO];
    [[self layoutGuidingContext] setAppliedLayoutGuidingRules:rules forSnappingRect:rect];
    return adjusted;
}

- (void)processMouseDown:(id)aDown inView:(id)aView
{
    [super processMouseDown:aDown inView:aView];
}

- (id)mutableVectorGraphicsAttributes
{
    return _vectorGraphicsAttributes;
}

- (id)vectorGraphicsAttributes
{
    return _vectorGraphicsAttributes;
}

- (void)setTrackingObject:(id)aObject
{
    [_vectorGraphicsAttributes release];
    _vectorGraphicsAttributes = nil;
    [super setTrackingObject:aObject];
    _vectorGraphicsAttributes = [[[self trackingObject] queryHyperInterface:@protocol(HSMutableVectorGraphicsAttributes)] retain];
}

- (void)dealloc
{
    [_vectorGraphicsAttributes release];
    [super dealloc];
}

@end
