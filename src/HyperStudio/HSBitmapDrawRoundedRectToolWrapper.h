#import "HyperStudioPrefix.h"
#import "HSBitmapDrawShapeToolWrapper.h"


@interface HSBitmapDrawRoundedRectToolWrapper : HSBitmapDrawShapeToolWrapper
{
}
- (BOOL)canProvideSelectedShape;
- (void)provideSelectionPath:(struct CGPath *)aPath withOrientedRectTransform:(CGAffineTransform)aTransform;
- (id)initWithBTTool:(id)aTool;
@end

