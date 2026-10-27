#import "HyperStudioPrefix.h"
#import "HSVectorDrawShapeTool.h"


@interface HSVectorDrawRoundedRectTool : HSVectorDrawShapeTool
{
}
- (BOOL)canProvideSelectedShape;
- (void)provideSelectionPath:(struct CGPath *)aPath withOrientedRectTransform:(CGAffineTransform)aTransform;
@end

