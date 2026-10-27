#import "HyperPlayerBasePrefix.h"
#import "HSWeaklyReferencedObject.h"


@interface HSMutableClipPathsAttributesImplementation : HSWeaklyReferencedObject <HSNodeUnitBasedHyperImplementationCreating, HSMutableClipPathsAttributes, HSAttributes, HyperInterface, NSObject, HSClipPathsAttribute, HSVisualAttribute, HSUndoableAttribute, HSAttribute>
{
    HSMutableClipPathsNodeUnit *_nodeUnit;
    HSNode *_node;
    id<HSSizeAttributes> _sizeAttributes;
}
+ (id)hyperImplementationWithNode:(id)aNode unit:(id)aUnit;
- (id)attributeObservingController;
- (void)setAllClipPathsAsInitial;
- (void)removeAllClipPaths;
- (void)removeNonInitialClipPaths;
- (void)applyPathsAffineTransform:(CGAffineTransform)aTransform;
- (void)addObjectClipPath:(id)aPath;
- (void)addObjectClipPath:(id)aPath transform:(CGAffineTransform)aTransform;
- (void)addRelativeClipPath:(id)aPath;
- (void)addRelativeClipPath:(id)aPath transform:(CGAffineTransform)aTransform;
- (CGAffineTransform)relativeToObjectAffineTransform;
- (void)addObjectCropPath:(id)aPath transform:(CGAffineTransform)aTransform;
- (void)addRelativeCropPath:(id)aPath transform:(CGAffineTransform)aTransform;
- (id)clipPaths;
- (id)hyperObject;
- (id)nodeUnit;
- (id)node;
- (void)dealloc;
- (id)initWithNodeUnit:(id)aUnit node:(id)aNode;
@end

