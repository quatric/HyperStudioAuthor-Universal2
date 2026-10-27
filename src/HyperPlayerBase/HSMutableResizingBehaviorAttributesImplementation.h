#import "HyperPlayerBasePrefix.h"
#import "HSWeaklyReferencedObject.h"


@interface HSMutableResizingBehaviorAttributesImplementation : HSWeaklyReferencedObject <HSNodeUnitBasedHyperImplementationCreating, HSStandaloneMutableResizingBehaviorAttributes, HSStandaloneResizingBehaviorAttributes, HSResizingBehaviorAttributes, HSAttributes, HyperInterface, NSObject, HSSizeAspectRatioMaintainingPreferenceAttribute, HSGeometryBehaviorAttribute, HSAttribute, HSMutableResizingBehaviorAttributes>
{
    HSNode *_node;
    HSResizingBehaviorNodeUnit *_nodeUnit;
    id<HSResizingBehaviorSubattributes> _resizingBehaviorSubattributes;
}
+ (id)hyperImplementationWithNode:(id)aNode unit:(id)aUnit;
- (id)attributeObservingController;
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

