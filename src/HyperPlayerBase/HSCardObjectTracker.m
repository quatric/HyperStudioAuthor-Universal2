#import "HSCardObjectTracker.h"
// Base mouse tracker for a card object: records the start point (in user
// space), the object's start origin and transform, and the last non-zero
// drag direction on each axis.

// Whether aValue is zero, within a relative tolerance of 0.0005.
static BOOL HSCardObjectTrackerIsZero(float aValue)
{
    float magnitude = aValue != 0 ? fabsf(aValue) : 1.0f;
    float tolerance = magnitude >= 1.0f ? magnitude * 0.0005f : 0.0005f;
    return fabsf(aValue) <= tolerance;
}

@implementation HSCardObjectTracker

- (void)mouseUp:(id)aUp inView:(id)aView
{
    [super mouseUp:aUp inView:aView];
    [_startTransform release];
    _startTransform = nil;
    [_inverseStartTransform release];
    _inverseStartTransform = nil;
    id context = [self layoutGuidingContext];
    if (context) {
        [context clearAppliedLayoutGuidingRules];
        [context showAppliedLayoutGuidingRules];
    }
}

- (void)processMouseDown:(id)aDown inView:(id)aView
{
    [super processMouseDown:aDown inView:aView];
    NSPoint point = [aView convertPoint:[aDown locationInWindow] fromView:nil];
    _startPoint = [aView convertPointFromViewSpaceToUserSpace:point];
    id geometry = [self geometryAttributes];
    _startOrigin = [geometry frameBoundingRect].origin;
    _startTransform = [[NSAffineTransform alloc] initWithHyperCGAffineTransform:[geometry affineTransform]];
}

- (void)mouseEvent:(id)aEvent inView:(id)aView
{
    NSPoint delta = NSZeroPoint;
    if ([(NSEvent *)aEvent type] == NSLeftMouseDragged) {
        delta.y = [aEvent deltaY];
        delta.x = [aEvent deltaX];
    }
    if (!HSCardObjectTrackerIsZero(delta.y) || HSCardObjectTrackerIsZero(_moveDirection.y))
        _moveDirection.y = delta.y;
    if (!HSCardObjectTrackerIsZero(delta.x) || HSCardObjectTrackerIsZero(_moveDirection.x))
        _moveDirection.x = delta.x;
}

- (NSRect)currentBoundingRect
{
    return [[self geometryAttributes] frameBoundingRect];
}

- (void)drawRect:(NSRect)aRect inView:(id)aView
{
}

- (id)inverseStartTransform
{
    if (!_inverseStartTransform) {
        _inverseStartTransform = [_startTransform copy];
        [_inverseStartTransform invert];
    }
    return [[_inverseStartTransform copy] autorelease];
}

- (id)startTransform
{
    return [[_startTransform copy] autorelease];
}

- (NSPoint)startOrigin
{
    return _startOrigin;
}

- (NSPoint)startPoint
{
    return _startPoint;
}

- (void)setTrackingObject:(id)aObject
{
    _trackingObject = aObject;
}

- (id)trackingObject
{
    return _trackingObject;
}

- (id)geometryApplier
{
    return [[[self trackingObject] queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
}

- (id)mutableGeometryAttributes
{
    return [[self trackingObject] queryHyperInterface:@protocol(HSMutableGeometryAttributes)];
}

- (id)geometryAttributes
{
    return [[self trackingObject] queryHyperInterface:@protocol(HSGeometryAttributes)];
}

- (id)copyWithZone:(NSZone *)aZone
{
    HSCardObjectTracker *copy = [[[self class] allocWithZone:aZone] init];
    [copy setTrackingObject:[self trackingObject]];
    [copy setLayoutGuidingContext:[self layoutGuidingContext]];
    copy->_startPoint = [self startPoint];
    copy->_startOrigin = [self startOrigin];
    copy->_startTransform = [[self startTransform] copy];
    copy->_inverseStartTransform = [[self inverseStartTransform] copy];
    return copy;
}

- (void)dealloc
{
    [_startTransform release];
    [_inverseStartTransform release];
    [super dealloc];
}

@end
