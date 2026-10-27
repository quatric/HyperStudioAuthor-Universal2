#import "HyperPlayerBasePrefix.h"
#import "HSWeaklyReferencedObject.h"


@interface HSMutableSizeAttributesImplementation : HSWeaklyReferencedObject <HSNodeUnitBasedHyperImplementationCreating, HSStandaloneMutableSizeAttributes, HSStandaloneSizeAttributes, HSSizeAttributes, HSAttributes, HyperInterface, NSObject, HSWidthAttribute, HSSizeAttribute, HSGeometryAttribute, HSVisualAttribute, HSUndoableAttribute, HSAttribute, HSHeightAttribute, HSMutableSizeAttributes>
{
    HSNode *_node;
    id<HSSizeNodeStorage> _nodeStorage;
    id<HSDefaultSizeSubattributes> _defaultSizeSubattributes;
}
+ (id)hyperImplementationWithNode:(id)aNode unit:(id)aUnit;
- (id)attributeObservingController;
- (void)setSize:(NSSize)aSize;
- (NSSize)size;
- (NSSize)defaultSize;
- (CGFloat)height;
- (CGFloat)width;
- (id)hyperObject;
- (id)nodeStorage;
- (id)node;
- (void)dealloc;
- (id)initWithNodeStorage:(id)aStorage node:(id)aNode;
- (id)init;
@end

