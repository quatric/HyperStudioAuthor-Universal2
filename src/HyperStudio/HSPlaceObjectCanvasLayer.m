#import "HSPlaceObjectCanvasLayer.h"

@implementation HSPlaceObjectCanvasLayer

- (NSPoint)userPointFromEvent:(id)aEvent
{
    NSPoint location = [(NSEvent *)aEvent locationInWindow];
    if ([aEvent window] != nil)
        location = [[aEvent window] convertPointToScreen:location];
    id view = [self renderingView];
    location = [[view window] convertPointFromScreen:location];
    location = [view convertPoint:location fromView:nil];
    location = [view convertPointFromViewSpaceToUserSpace:location];
    return NSMakePoint(roundf(location.x), roundf(location.y));
}

- (BOOL)handleRawKeyDownEvent:(id)aEvent
{
    if ([(NSEvent *)aEvent keyCode] != 0x31)
        return NO;
    [_owner finishPlacingObjectForPlaceObjectCanvasLayer:self];
    return YES;
}

- (BOOL)handleKeyEventSelector:(SEL)aSelector
{
    if (aSelector == @selector(cancel:) || aSelector == @selector(cancelOperation:))
        [_owner cancelPlacingObjectForPlaceObjectCanvasLayer:self];
    else if (aSelector == @selector(insertNewline:))
        [_owner finishPlacingObjectForPlaceObjectCanvasLayer:self];
    else
        return NO;
    return YES;
}

- (BOOL)handleMouseMovedAtPoint:(NSPoint)aPoint insideView:(BOOL)aView event:(id)aEvent
{
    [_owner placeObjectCanvasLayer:self mouseMovedToPoint:[self userPointFromEvent:aEvent]];
    return YES;
}

- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo
{
    [_owner finishPlacingObjectForPlaceObjectCanvasLayer:self];
    return YES;
}

- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo
{
    return self;
}

- (void)setOwner:(id)aOwner
{
    _owner = aOwner;
}

- (id)owner
{
    return _owner;
}

@end
