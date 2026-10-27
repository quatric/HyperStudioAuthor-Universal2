#import "HyperPlayerBasePrefix.h"
#import "HSGenericGroupRenderLayer.h"


@interface HSGenericEffectSourceAreaRenderLayer : HSGenericGroupRenderLayer
{
    id<HSEffectAttributes> _effectAttributes;
}
- (BOOL)unionBoundingRegionOfSublayersVisualAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion;
- (id)calculateBoundingRegion;
- (void)fillBoundingRegionAttributesSet:(id)aSet;
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate;
- (void)fillVisualizationMaskAttributesSet:(id)aSet;
- (void)fillVisualizationAttributesSet:(id)aSet;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject renderSublayerCapacity:(NSUInteger)aCapacity cachingPolicy:(NSInteger)aPolicy;
@end

