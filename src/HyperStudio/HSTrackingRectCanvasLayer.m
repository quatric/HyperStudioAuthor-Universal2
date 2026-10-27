#import "HSTrackingRectCanvasLayer.h"

@interface NSObject (HSTrackingRectCanvasLayerDelegateMethods)
- (NSPoint)trackingRectCanvasLayer:(id)aLayer shouldStartTrackingWithPoint:(NSPoint)aPoint event:(id)anEvent;
- (NSRect)trackingRectCanvasLayer:(id)aLayer shouldChooseRect:(NSRect)aRect event:(id)anEvent;
- (void)trackingRectCanvasLayer:(id)aLayer didFinishTrackingWithRect:(NSRect)aRect event:(id)anEvent;
@end

@implementation HSTrackingRectCanvasLayer

- (NSRect)boundingRectOccupiedByLayer
{
    return NSZeroRect;
}

- (void)handleFlagsChanged:(id)aChanged inTrackingLoop:(id)aLoop
{
}

- (void)handleMouseUp:(id)aUp inTrackingLoop:(id)aLoop
{
    [self updateTrackingRectWithMouseEvent:aUp inView:[aLoop view]];
    [self setTrackingRectCanvasItem:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSTrackingRectCanvasLayerDidHandleMouseUpNotification" object:self];
}

- (void)handleMouseDragged:(id)aDragged inTrackingLoop:(id)aLoop
{
    [self updateTrackingRectWithMouseEvent:aDragged inView:[aLoop view]];
}

- (void)handleMouseDown:(id)aDown inTrackingLoop:(id)aLoop
{
}

- (void)updateTrackingRectWithMouseEvent:(id)aEvent inView:(id)aView
{
    NSPoint point = [aView convertPoint:[aEvent locationInWindow] fromView:nil];
    NSRect rect = [_trackingRectCanvasItem rectForUpdatingWithEndPoint:point inParentLayer:self];
    if ([_delegate respondsToSelector:@selector(trackingRectCanvasLayer:shouldChooseRect:event:)])
        rect = [_delegate trackingRectCanvasLayer:self shouldChooseRect:rect event:aEvent];
    [_trackingRectCanvasItem updateWithRect:rect inParentLayer:self];
}

- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo
{
    if ([_delegate respondsToSelector:@selector(trackingRectCanvasLayer:shouldStartTrackingWithPoint:event:)])
        aPoint = [_delegate trackingRectCanvasLayer:self shouldStartTrackingWithPoint:aPoint event:aEvent];
    [self setTrackingRectCanvasItem:[HSTrackingRectCanvasItem trackingRectCanvasItemWithStartingPoint:aPoint]];
    [[HSTrackingLoop trackingLoopWithView:[self renderingView] client:self] runWithMouseDownEvent:aEvent];
    [self setTrackingRectCanvasItem:nil];
    if ([_delegate respondsToSelector:@selector(trackingRectCanvasLayer:didFinishTrackingWithRect:event:)])
        [_delegate trackingRectCanvasLayer:self didFinishTrackingWithRect:_lastTrackingRect event:aEvent];
    return YES;
}

- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo
{
    return self;
}

- (NSRect)lastTrackingRect
{
    return _lastTrackingRect;
}

// The finished rectangle is kept in _lastTrackingRect when an item is replaced.
- (void)setTrackingRectCanvasItem:(id)aItem
{
    if (_trackingRectCanvasItem != aItem) {
        [self invalidateDisplay];
        if (_trackingRectCanvasItem)
            _lastTrackingRect = [_trackingRectCanvasItem rect];
        [_trackingRectCanvasItem release];
        _trackingRectCanvasItem = [aItem retain];
        [self invalidateDisplay];
    }
}

- (id)canvasItemAtIndex:(NSUInteger)aIndex
{
    return _trackingRectCanvasItem;
}

- (NSUInteger)numberOfCanvasItems
{
    return _trackingRectCanvasItem != nil;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (void)dealloc
{
    [_trackingRectCanvasItem release];
    [super dealloc];
}

@end
