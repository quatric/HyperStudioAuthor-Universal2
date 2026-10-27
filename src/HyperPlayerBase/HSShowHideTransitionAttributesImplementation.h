#import "HyperPlayerBasePrefix.h"
#import "HSWeaklyReferencedObject.h"


@interface HSShowHideTransitionAttributesImplementation : HSWeaklyReferencedObject <HSNodeUnitBasedHyperImplementationCreating, HSShowHideTransitionAttributes, HSAttributes, HyperInterface, NSObject, HSShowHideTransitionAttribute, HSAttribute, HSShowHideTransitionFrameAttribute, HSVisualAttribute, HSUndoableAttribute>
{
    HSNode *_node;
    HSShowHideTransitionNodeUnit *_nodeUnit;
}
+ (id)hyperImplementationWithNode:(id)aNode unit:(id)aUnit;
- (id)attributeObservingController;
- (double)transitionTime;
- (void)setTransition:(id)aTransition;
- (id)transition;
- (id)hyperObject;
- (id)node;
- (void)dealloc;
- (id)initWithNodeUnit:(id)aUnit node:(id)aNode;
@end

