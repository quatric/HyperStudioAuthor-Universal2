#import "HyperStudioPrefix.h"
#import "HSBitmapTool.h"


@interface HSBitmapDrawShapeToolWrapper : HSBitmapTool
{
}
- (void)provideSelectionPath:(struct CGPath *)aPath withOrientedRectTransform:(CGAffineTransform)aTransform;
- (BOOL)canProvideSelectedShape;
- (void)tool:(id)aTool didUpdateOutputForKey:(id)aKey;
- (id)settingsIdentifiers;
@end

