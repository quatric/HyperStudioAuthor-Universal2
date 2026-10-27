#import "HyperStudioPrefix.h"
#import "HSColorMatrixDataProvider.h"


@interface HSPatternColorMatrixDataProvider : HSColorMatrixDataProvider
{
}
+ (id)sharedDataProvider;
- (id)defaultColorAtRow:(NSInteger)aRow column:(NSInteger)aColumn;
- (id)init;
@end

