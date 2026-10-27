#import "HyperPlayerBasePrefix.h"
#import "HSWeaklyReferencedObject.h"


@interface HSEditableImageAttributesImplementation : HSWeaklyReferencedObject <HSNodeUnitBasedHyperImplementationCreating, HSEditableImageAttributes, HSAttributes, HyperInterface, NSObject, HSImageAttribute, HSVisualAttribute, HSUndoableAttribute, HSAttribute, HSImageRectAttribute, HSEditableImageMediaAttributes>
{
    HSNode *_node;
    HSEditableImageNodeUnit *_nodeUnit;
    id<HSImageRectSubattributes> _imageRectSubattributes;
}
+ (id)hyperImplementationWithNode:(id)aNode unit:(id)aUnit;
- (id)attributeObservingController;
- (void)setEditableImageMedia:(id)aMedia;
- (id)editableImageMedia;
- (NSRect)imageRect;
- (void)endEditImage;
- (void)beginEditImage:(id)aImage inRect:(NSRect)aRect;
- (void)beginEditImage:(id)aImage;
- (void)endEditImageContinuously;
- (void)beginEditImageContinuously;
- (id)queryImageWithRequiredProtocols:(id *)aProtocols optionalProtocols:(id *)aProtocols2;
- (id)hyperObject;
- (id)node;
- (void)dealloc;
- (id)initWithNodeUnit:(id)aUnit node:(id)aNode;
@end

