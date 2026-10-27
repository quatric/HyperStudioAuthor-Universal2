#import "HyperPlayerBasePrefix.h"
#import "HSGenericRenderLayer.h"


@interface HSGenericImageRenderLayer : HSGenericRenderLayer
{
    id<HSImageAttributes> _imageAttributes;
    id<HSEditableImageAttributes> _editableImageAttributes;
    id<HSTransparentColorAttributes> _transparentColorAttributes;
}
- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce;
- (BOOL)unionBoundingRegionOfLocalVisualAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion;
- (id)calculateBoundingRegion;
- (void)fillBoundingRegionAttributesSet:(id)aSet;
- (BOOL)requiresTransparencyLayer;
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate;
- (void)fillVisualizationAttributesSet:(id)aSet;
- (CGSize)HSGenericImageRenderLayer_imageSize;
- (NSRect)HSGenericImageRenderLayer_imageRect;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy;
@end

// The cel image without aColor (within the tolerances); nil if it can't be made.
NSImage *HSGenericImageRenderLayerRemovingColorFromCelImage(NSImage *aImage, NSColor *aColor, double aHueTolerance, double aChromaTolerance, double aLightnessTolerance);
