#import "HyperPlayerBasePrefix.h"
#import "HSWeaklyReferencedObject.h"


@interface HSMutableGeometryBehaviorAttributesImplementation : HSWeaklyReferencedObject <HSNodeUnitBasedHyperImplementationCreating, HSMutableGeometryBehaviorAttributes, HSGeometryBehaviorAttributes, HSResizingBehaviorAttributes, HSAttributes, HyperInterface, NSObject, HSSizeAspectRatioMaintainingPreferenceAttribute, HSGeometryBehaviorAttribute, HSAttribute, HSSizeScaleAspectRatioMaintainingPreferenceAttribute, HSMutableResizingBehaviorAttributes>
{
    HSNode *_node;
    HSGeometryBehaviorNodeUnit *_nodeUnit;
    id<HSStandaloneResizingBehaviorAttributes> _resizingBehaviorAttributes;
    id<HSStandaloneMutableResizingBehaviorAttributes> _mutableResizingBehaviorAttributes;
    id<HSGeometryBehaviorSubattributes> _geometryBehaviorSubattributes;
}
+ (id)hyperImplementationWithNode:(id)aNode unit:(id)aUnit;
- (id)attributeObservingController;
- (void)setPrefersToMaintainSizeScaleAspectRatio:(BOOL)aRatio;
- (BOOL)prefersToMaintainSizeScaleAspectRatio;
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
- (void)setPrefersToMaintainSizeAspectRatio:(BOOL)aRatio;
- (BOOL)prefersToMaintainSizeAspectRatio;
- (BOOL)canResizeVertically;
- (BOOL)canResizeHorizontally;
- (BOOL)canBreakSizeAspectRatio;
- (id)hyperObject;
- (id)nodeUnit;
- (id)node;
- (void)dealloc;
- (id)initWithNodeUnit:(id)aUnit node:(id)aNode;
- (id)init;
@end

