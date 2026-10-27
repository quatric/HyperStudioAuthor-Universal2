#import "HyperPlayerBasePrefix.h"
#import "HSConcreteCardObject.h"


@interface HSSystemObject : HSConcreteCardObject <HSSystemObjectAttributes, HSAttributes, HyperInterface, NSObject, HSSystemViewAttribute, HSVisualAttribute, HSUndoableAttribute, HSAttribute, HSSystemViewDuplicatingInterface, HSGeometryBehaviorSubattributes>
{
}
+ (Class)nodeDataClass;
+ (id)defaultUnitClassNames;
- (id)hyperSizeMaxValue;
- (BOOL)canMoveVertically;
- (BOOL)canMoveHorizontally;
- (BOOL)canRotate;
- (BOOL)canSkew;
- (BOOL)canFlipVertically;
- (BOOL)canFlipHorizontally;
- (BOOL)canScaleVertically;
- (BOOL)canScaleHorizontally;
- (BOOL)canBreakSizeScaleAspectRatio;
- (BOOL)prefersResizingToScaling;
- (void)removeDuplicateHyperSystemView:(id)aView;
- (id)addDuplicateHyperSystemView;
- (id)placeholderSystemView;
- (id)hyperSystemView;
- (void)didCreateSystemView;
- (id)initUserObject;
@end

