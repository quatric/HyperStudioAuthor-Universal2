#import "HyperStudioPrefix.h"


@interface HSDisablingDragCanvasLayer : HSSimpleCanvasSublayer
{
    unsigned int _dragDisableModifier;
    unsigned int _dragDisabled:1;
}
- (void)setDragDisableModifier:(NSUInteger)aModifier;
- (BOOL)dragDisableModifier;
- (void)setDragDisable:(BOOL)aDisable;
- (BOOL)isDragDisabled;
- (void)willResignActiveLayer;
- (void)didBecomeActiveLayer;
- (BOOL)handleKeyEventSelector:(SEL)aSelector;
- (BOOL)handleFlagsChanged:(id)aChanged atPoint:(NSPoint)aPoint;
- (BOOL)handleMouseMovedAtPoint:(NSPoint)aPoint insideView:(BOOL)aView event:(id)aEvent;
- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags hitTestInfo:(id)aInfo event:(id)aEvent;
- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo;
- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo;
@end

