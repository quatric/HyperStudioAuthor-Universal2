#import "HyperPlayerBasePrefix.h"
#import "HSGenericGroupRenderLayer.h"


@interface HSGenericInternalGroupRenderLayer : HSGenericGroupRenderLayer
{
    id<HSNodeContainer> _nodeContainer;
    unsigned int _isAutoGroupingOfRenderSublayersForEfficientCachingCanceled:1;
    unsigned int _isWaitingForContinuousSubobjectsChange:1;
}
- (BOOL)unionBoundingRegionOfLocalVisualAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion;
- (void)fillVisualizationMaskAttributesSet:(id)aSet;
- (void)fillVisualizationAttributesSet:(id)aSet;
- (void)disableAutogroupingOfRenderSublayersForEfficientCaching;
- (void)enableAutogroupingOfRenderSublayersForEfficientCaching;
- (void)setAutogroupsRenderSublayersForEfficientCaching:(BOOL)aCaching;
- (void)HSGenericInternalGroupRenderLayer_subobjectsDidEndChangeContinuously:(id)aContinuously;
- (void)HSGenericInternalGroupRenderLayer_subobjectsDidChangeContinuously:(id)aContinuously;
- (void)HSGenericInternalGroupRenderLayer_subobjectsWillBeginChangeContinuously:(id)aContinuously;
- (void)HSGenericInternalGroupRenderLayer_subobjectsDidChange:(id)aChange;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject renderSublayerCapacity:(NSUInteger)aCapacity cachingPolicy:(NSInteger)aPolicy;
@end

