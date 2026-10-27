#import "HyperStudioPrefix.h"
#import "HSColorMatrixDataProvider.h"


@interface HSBigColorMatrixDataProvider : HSColorMatrixDataProvider <HSBigColorMatrixDataProvider, HSColorMatrixDataProvider, NSObject>
{
}
+ (id)sharedDataProvider;
- (id)defaultColorAtRow:(NSInteger)aRow column:(NSInteger)aColumn;
- (void)deactivateAllViews;
- (void)resetToDefault;
- (id)init;
@end

