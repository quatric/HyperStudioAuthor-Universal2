#import "HyperPlayerBasePrefix.h"
#import "HSWeaklyReferencedObject.h"


@interface HSVectorBrushAttributesImplementation : HSWeaklyReferencedObject <HSNodeUnitBasedHyperImplementationCreating, HSVectorBrushAttributes, HSAttributes, HyperInterface, NSObject, HSVectorBrushToolBoundingRectAttribute, HSAttribute>
{
    HSNode *_node;
    HSVectorBrushNodeUnit *_nodeUnit;
}
+ (id)hyperImplementationWithNode:(id)aNode unit:(id)aUnit;
- (id)attributeObservingController;
- (id)brushRenderer;
- (NSRect)hyperToolBoundingRect;
- (id)hyperTouchProvider;
- (id)hyperTool;
- (id)hyperObject;
- (id)node;
- (void)dealloc;
- (id)initWithNodeUnit:(id)aUnit node:(id)aNode;
@end

