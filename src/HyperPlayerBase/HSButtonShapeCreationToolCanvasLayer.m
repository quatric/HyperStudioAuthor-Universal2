#import "HSButtonShapeCreationToolCanvasLayer.h"
@implementation HSButtonShapeCreationToolCanvasLayer
- (void)cancelOperation:(id)aOperation
{
    [[self buttonShapeCreationTool] handleCancelOpertaion];
}
- (id)buttonShapeCreationTool
{
    return [super tool];
}
@end
