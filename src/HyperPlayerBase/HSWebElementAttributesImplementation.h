#import "HyperPlayerBasePrefix.h"
#import "HSWeaklyReferencedObject.h"


@interface HSWebElementAttributesImplementation : HSWeaklyReferencedObject <HSNodeUnitBasedHyperImplementationCreating, HSWebElementAttributes, HSAttributes, HyperInterface, NSObject, HSWebElementHTMLCodeAttribute, HSAttribute, HSWebElementRefreshRateAttribute, HSWebElementPreviewImageAttribute, HSVisualAttribute, HSUndoableAttribute, HSWebElementContentAttribute>
{
    HSNode *_node;
    HSWebElementNodeUnit *_nodeUnit;
    id<HSSizeAttributes> _sizeAttributes;
    HSWebRenderer *_webRenderer;
}
+ (id)hyperImplementationWithNode:(id)aNode unit:(id)aUnit;
- (id)attributeObservingController;
- (void)reclaimWebView;
- (id)ejectWebView;
- (void)drawInRect:(NSRect)aRect clipToRect:(NSRect)aRect2;
- (struct CGImage *)previewImage;
- (id)HSWebElementAttributesImplementation_webRenderer;
- (void)setRefreshRate:(CGFloat)aRate;
- (CGFloat)refreshRate;
- (void)setHTMLCode:(id)aCode;
- (id)HTMLCode;
- (id)hyperObject;
- (id)nodeUnit;
- (id)node;
- (void)dealloc;
- (id)initWithNodeUnit:(id)aUnit node:(id)aNode;
- (id)init;
- (CGImageRef)copyPreviewImageWithScale:(CGSize)aScale;
@end

