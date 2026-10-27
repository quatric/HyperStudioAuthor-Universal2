#import "HyperStudioPrefix.h"


@interface HSVectorBrushToolCanvasLayer : HSBaseBitmapToolCanvasLayer
{
}
- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo;
- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags hitTestInfo:(id)aInfo event:(id)aEvent;
- (void)renderRect:(NSRect)aRect;
@end

