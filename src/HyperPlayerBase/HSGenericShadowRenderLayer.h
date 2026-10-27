#import "HyperPlayerBasePrefix.h"
#import "HSGenericGroupRenderLayer.h"


@interface HSGenericShadowRenderLayer : HSGenericGroupRenderLayer
{
    id<HSGeometryAttributes> _geometryAttributes;
    id<HSShadowAttributes> _shadowAttributes;
    HSRegion *_contentBoundingRegion;
    HSMutableMultipleObjectsAttributeSet *_contentBoundingRegionAttributes;
}
- (void)renderLayerDidChangeBoundingRegion:(id)aRegion;
- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce;
- (BOOL)unionBoundingRegionOfSublayersVisualAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion;
- (id)calculateBoundingRegion;
- (void)HSGenericShadowRenderLayer_contentBoundingRegionDidChange:(id)aChange;
- (id)contentBoundingRegion;
- (void)fillBoundingRegionAttributesSet:(id)aSet;
- (void)HSGenericShadowRenderLayer_linkContentBoundingRegionToAttributes;
- (id)contentRegionForShadowRegion:(id)aRegion;
- (id)shadowRegionForContentRegion:(id)aRegion;
- (void)drawRenderSublayersInRegion:(id)aRegion withDelegate:(id)aDelegate;
- (void)fillVisualizationMaskAttributesSet:(id)aSet;
- (void)fillVisualizationAttributesSet:(id)aSet;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject renderSublayerCapacity:(NSUInteger)aCapacity cachingPolicy:(NSInteger)aPolicy;
@end

