#import "HyperStudioPrefix.h"


@interface HSAnimationPickObjectCanvasLayer : HSCompositeCanvasLayer
{
    id<HSAnimationPickObjectCanvasLayerDelegate> _delegate;
}
- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags hitTestInfo:(id)aInfo event:(id)aEvent;
- (BOOL)handleMouseMovedAtPoint:(NSPoint)aPoint insideView:(BOOL)aView event:(id)aEvent;
- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo;
- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo;
- (BOOL)handleKeyEventSelector:(SEL)aSelector;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
@end

