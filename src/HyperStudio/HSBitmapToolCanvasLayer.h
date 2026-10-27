#import "HyperStudioPrefix.h"


@interface HSBitmapToolCanvasLayer : HSBaseBitmapToolCanvasLayer
{
}
- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo;
- (void)renderRect:(NSRect)aRect;
- (void)setTool:(id)aTool;
- (id)tool;
@end

