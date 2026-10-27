#import "HSTrackingPointCanvasLayer.h"

static BOOL HSTrackingPointCoordinatesDiffer(CGFloat aValue, CGFloat anotherValue)
{
    CGFloat magnitude = aValue != 0 ? fabs(aValue) : 1.0f;
    CGFloat anotherMagnitude = anotherValue != 0 ? fabs(anotherValue) : 1.0f;
    if (anotherMagnitude <= magnitude)
        anotherMagnitude = magnitude;
    return fabs(aValue - anotherValue) > anotherMagnitude * 0.0005f;
}

@implementation HSTrackingPointCanvasLayer

- (void)willResignActiveLayer
{
}

- (void)didBecomeActiveLayer
{
}

- (NSRect)boundingRectOccupiedByLayer
{
    return NSZeroRect;
}

- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags hitTestInfo:(id)aInfo event:(id)aEvent
{
    return aView ? [HSCursor cursorNamed:HSCrossCursor] : nil;
}

- (void)handleFlagsChanged:(id)aChanged inTrackingLoop:(id)aLoop
{
}

- (void)handleMouseUp:(id)aUp inTrackingLoop:(id)aLoop
{
    [self updateTrackingPointWithMouseEvent:aUp inView:[aLoop view]];
}

- (void)handleMouseDragged:(id)aDragged inTrackingLoop:(id)aLoop
{
    [self updateTrackingPointWithMouseEvent:aDragged inView:[aLoop view]];
}

- (void)handleMouseDown:(id)aDown inTrackingLoop:(id)aLoop
{
    [self updateTrackingPointWithMouseEvent:aDown inView:[aLoop view]];
}

- (void)updateTrackingPointWithMouseEvent:(id)aEvent inView:(id)aView
{
    [self setTrackingPoint:[aView convertPoint:[aEvent locationInWindow] fromView:nil]];
}

- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo
{
    HSTrackingLoop *loop = [HSTrackingLoop trackingLoopWithView:[[self context] renderingView] client:self];
    _isTracking = YES;
    [loop runWithMouseDownEvent:aEvent];
    [self notifyDidFinishTrackingPoint];
    _trackingPoint = NSZeroPoint;
    _isTracking = NO;
    return YES;
}

- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo
{
    return self;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (void)notifyDidFinishTrackingPoint
{
    if ([_delegate respondsToSelector:@selector(trackingPointCanvasLayer:didFinishTrackingWithPoint:)])
        [_delegate trackingPointCanvasLayer:self didFinishTrackingWithPoint:_trackingPoint];
}

// Ignores changes smaller than a twentieth of a percent of the coordinates;
// the delegate may adjust the point first.
- (void)setTrackingPoint:(NSPoint)aPoint
{
    if (!HSTrackingPointCoordinatesDiffer(_trackingPoint.x, aPoint.x) && !HSTrackingPointCoordinatesDiffer(_trackingPoint.y, aPoint.y))
        return;
    if ([_delegate respondsToSelector:@selector(trackingPointCanvasLayer:shouldChoosePoint:)])
        aPoint = [_delegate trackingPointCanvasLayer:self shouldChoosePoint:aPoint];
    if (!HSTrackingPointCoordinatesDiffer(_trackingPoint.x, aPoint.x) && !HSTrackingPointCoordinatesDiffer(_trackingPoint.y, aPoint.y))
        return;
    _trackingPoint = aPoint;
}

- (NSPoint)trackingPoint
{
    return _trackingPoint;
}

@end
