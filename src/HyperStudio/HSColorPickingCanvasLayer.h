#import "HyperStudioPrefix.h"


@interface HSColorPickingCanvasLayer : HSSimpleCanvasSublayer
{
    id _delegate;
    HSToolView *_toolView;
}
- (BOOL)handleKeyEventSelector:(SEL)aSelector;
- (id)captureColorAtCardLocation:(NSPoint)aLocation;
- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags hitTestInfo:(id)aInfo event:(id)aEvent;
- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo;
- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo;
- (BOOL)isPointInCardRect:(NSPoint)aRect;
- (void)finalizeWithColor:(id)aColor;
- (void)startPickingColorInView:(id)aView withDelegate:(id)aDelegate;
- (void)dealloc;
@end

