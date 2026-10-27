#import "HyperPlayerBasePrefix.h"
#import "HSGenericGroupRenderLayer.h"


@interface HSGenericEffectSourceAreaInverseClipRenderLayer : HSGenericGroupRenderLayer
{
    id<HSEffectAttributes> _effectAttributes;
    HSRegion *_contentBoundingRegion;
    HSMutableMultipleObjectsAttributeSet *_contentBoundingRegionAttributes;
}
- (void)renderLayerDidChangeBoundingRegion:(id)aRegion;
- (id)calculateBoundingRegion;
- (void)HSGenericEffectSourceAreaInverseClipRenderLayer_contentBoundingRegionDidChange:(id)aChange;
- (id)contentBoundingRegion;
- (void)fillBoundingRegionAttributesSet:(id)aSet;
- (void)HSGenericEffectSourceAreaInverseClipRenderLayer_linkContentBoundingRegionToAttributes;
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate;
- (void)fillVisualizationAttributesSet:(id)aSet;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject renderSublayerCapacity:(NSUInteger)aCapacity cachingPolicy:(NSInteger)aPolicy;
@end

