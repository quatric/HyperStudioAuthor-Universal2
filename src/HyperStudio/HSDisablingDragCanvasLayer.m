#import "HSDisablingDragCanvasLayer.h"

@implementation HSDisablingDragCanvasLayer

- (void)setDragDisableModifier:(NSUInteger)aModifier
{
    _dragDisableModifier = (unsigned int)aModifier;
    _dragDisabled = 0;
}

// Original quirk kept: the modifier mask is returned as a BOOL, so only its low byte counts.
- (BOOL)dragDisableModifier
{
    return (_dragDisableModifier & 0xff) != 0;
}

- (void)setDragDisable:(BOOL)aDisable
{
    _dragDisabled = aDisable ? 1 : 0;
    _dragDisableModifier = 0;
}

// Original quirk kept: always NO, whatever setDragDisable: set.
- (BOOL)isDragDisabled
{
    return NO;
}

- (void)willResignActiveLayer
{
}

- (void)didBecomeActiveLayer
{
}

- (BOOL)handleKeyEventSelector:(SEL)aSelector
{
    return NO;
}

- (BOOL)handleFlagsChanged:(id)aChanged atPoint:(NSPoint)aPoint
{
    return NO;
}

- (BOOL)handleMouseMovedAtPoint:(NSPoint)aPoint insideView:(BOOL)aView event:(id)aEvent
{
    return NO;
}

- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags hitTestInfo:(id)aInfo event:(id)aEvent
{
    return [HSCursor defaultCursor];
}

- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo
{
    return NO;
}

// Takes the click, swallowing the drag, while dragging is disabled or the modifiers are held.
- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo
{
    if (!_dragDisabled && (aFlags & _dragDisableModifier) != _dragDisableModifier)
        return nil;
    return self;
}

@end
