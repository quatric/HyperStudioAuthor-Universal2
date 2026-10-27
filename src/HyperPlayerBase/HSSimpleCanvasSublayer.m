#import "HSSimpleCanvasSublayer.h"

@implementation HSSimpleCanvasSublayer

- (BOOL)isRunningInWindow
{
    return [_parentLayer isRunningInWindow];
}

- (BOOL)isRunning
{
    return [_parentLayer isRunning];
}

- (void)willStopRunningInWindow
{
}

- (void)didStartRunningInWindow
{
}

- (void)willStopRunning
{
}

- (void)didStartRunning
{
}

- (void)willResignActiveLayer
{
}

- (void)didBecomeActiveLayer
{
}

- (void)renderingViewTransformDidChange
{
}

- (void)contextDidChange
{
}

- (void)contextWillChange
{
}

- (void)representedObjectDidChange
{
}

- (void)representedObjectWillChange
{
}

- (id)parentLayer
{
    return _parentLayer;
}

- (void)setParentLayer:(id)aLayer
{
    // Not retained: the parent owns its sublayers.
    _parentLayer = aLayer;
}

- (BOOL)handleTouchesCancelledWithEvent:(id)aEvent hitTestInfo:(id)aInfo
{
    return NO;
}

- (BOOL)handleTouchesEndedWithEvent:(id)aEvent hitTestInfo:(id)aInfo
{
    return NO;
}

- (BOOL)handleTouchesMovedWithEvent:(id)aEvent hitTestInfo:(id)aInfo
{
    return NO;
}

- (BOOL)handleTouchesBeganWithEvent:(id)aEvent hitTestInfo:(id)aInfo
{
    return NO;
}

- (BOOL)handleSwipeGesture:(id)aGesture hitTestInfo:(id)aInfo
{
    return NO;
}

- (BOOL)handleRotationGestureWithEvent:(id)aEvent hitTestInfo:(id)aInfo
{
    return NO;
}

- (BOOL)handleMagnificationGestureWithEvent:(id)aEvent hitTestInfo:(id)aInfo
{
    return NO;
}

- (BOOL)handleScrollWheelAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo
{
    return NO;
}

- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags hitTestInfo:(id)aInfo event:(id)aEvent
{
    return nil;
}

- (BOOL)handleMouseUpAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo
{
    return NO;
}

- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo
{
    return NO;
}

- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo
{
    return nil;
}

- (id)hitTestNextInteractiveItemAfterItem:(id)aItem atPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSRect)boundingRectOccupiedByLayer
{
    return NSZeroRect;
}

- (void)renderRect:(NSRect)aRect
{
}

- (void)invalidateDisplay
{
}

- (id)representedObject
{
    return [_parentLayer representedObject];
}

- (id)context
{
    return [_parentLayer context];
}

- (id)renderingView
{
    return [[self context] renderingView];
}

@end
