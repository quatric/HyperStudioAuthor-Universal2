#import "HyperPlayerBasePrefix.h"


@interface HSLayoutGrid : NSObject <HSLayoutGridGeometry, HSLayoutGeometryHolder, HyperInterface, NSObject, EXKeyValueCoding>
{
    NSSize _gridSpacing;
    NSUndoManager *_undoManager;
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)setGridSpacingAsString:(id)aString;
- (id)gridSpacingAsString;
- (void)setGridSpacing:(NSSize)aSpacing;
- (NSSize)gridSpacing;
- (BOOL)isHyperInfluencingLayout;
- (BOOL)snapToCornersOnMove;
- (BOOL)snapToNegativeValues;
- (BOOL)hyperGridUseMajorSteps;
- (BOOL)hyperGridUseMinorSteps;
- (CGFloat)yHyperGridMajorStep;
- (CGFloat)xHyperGridMajorStep;
- (CGFloat)yHyperGridMinorStep;
- (CGFloat)xHyperGridMinorStep;
- (void)setUndoManager:(id)aManager;
- (void)dealloc;
- (id)init;
@end

