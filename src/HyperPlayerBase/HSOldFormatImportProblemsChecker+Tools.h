#import "HyperPlayerBasePrefix.h"
#import "HSOldFormatImportProblemsChecker.h"


@interface HSOldFormatImportProblemsChecker (Tools)
- (void)checkActionForId:(NSInteger)aId;
- (NSUInteger)fontTraitMaskForFaceStyle:(NSUInteger)aStyle;
- (NSUInteger)fontTraitMaskForFaceStyle:(NSUInteger)aStyle applyToObject:(id)aObject;
- (id)actionObjectPathForApplePath:(id)aPath;
- (id)actionObjectPathForPath:(id)aPath;
- (id)pathForApplePath:(id)aPath;
- (id)stringForImportedData:(id)aData;
@end

