#import "HyperPlayerBasePrefix.h"
#import "HSGenericRenderLayer.h"


@interface HSOpacityRenderLayer : HSGenericRenderLayer <HSRenderLayerObserver, NSObject>
{
    id<HSOpacityAttributes> _opacityAttributes;
    id<HSRenderLayer> _contentRenderLayer;
}
- (void)renderLayerWantsToReexpand:(id)aReexpand;
- (void)renderLayerDidChangeBoundingRegion:(id)aRegion;
- (void)renderLayerDidChangeVisualizationMaskAttributesSet:(id)aSet;
- (void)renderLayerDidChangeVisualizationAttributesSet:(id)aSet;
- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce;
- (void)drawRenderSublayersInRegion:(id)aRegion withDelegate:(id)aDelegate;
- (id)calculateBoundingRegion;
- (void)fillVisualizationMaskAttributesSet:(id)aSet;
- (void)fillVisualizationAttributesSet:(id)aSet;
- (BOOL)isEmpty;
- (void)setContentRenderLayer:(id)aLayer;
- (id)contentRenderLayer;
- (BOOL)transparencyLayerRequirementAdditionFlagOfRenderSublayerAtIndex:(NSUInteger)aIndex;
- (BOOL)rootFlagOfRenderSublayerAtIndex:(NSUInteger)aIndex;
- (id)roleOfRenderSublayerAtIndex:(NSUInteger)aIndex;
- (id)renderSublayerAtIndex:(NSUInteger)aIndex;
- (NSUInteger)renderSublayerCount;
- (id)renderSublayers;
- (id)copyRemovingRenderSublayers;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy;
@end

