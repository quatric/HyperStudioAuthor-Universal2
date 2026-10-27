#import "HyperPlayerBasePrefix.h"
#import "HSGenericGroupRenderLayer.h"


@interface HSGenericEffectPlaceholderRenderLayer : HSGenericGroupRenderLayer
{
    id<HSEffectAttributes> _effectAttributes;
}
- (void)fillVisualizationMaskAttributesSet:(id)aSet;
- (void)fillVisualizationAttributesSet:(id)aSet;
- (id)effectAttributes;
- (void)HSGenericEffectPlaceholderRenderLayer_effectDidChange:(id)aChange;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject renderSublayerCapacity:(NSUInteger)aCapacity cachingPolicy:(NSInteger)aPolicy;
@end

