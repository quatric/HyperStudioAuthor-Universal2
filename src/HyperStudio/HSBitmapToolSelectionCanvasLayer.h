#import "HyperStudioPrefix.h"


@interface HSBitmapToolSelectionCanvasLayer : HSSimpleCanvasSublayer
{
    HSBitmapTool *_tool;
}
- (void)renderRect:(NSRect)aRect;
- (void)setTool:(id)aTool;
- (id)tool;
@end

