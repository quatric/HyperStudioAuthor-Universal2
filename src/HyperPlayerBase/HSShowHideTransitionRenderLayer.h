#import "HyperPlayerBasePrefix.h"
#import "HSGenericRenderCache.h"
#import "HSGenericRenderLayer.h"


@interface HSShowHideTransitionRenderLayer : HSGenericRenderLayer <HSRenderLayerObserver, NSObject>
{
    id<HSCardObjectAttributes> _cardObjectAttributes;
    id<HSShowHideTransitionAttributes> _showHideTransitionAtributes;
    HSShowHideTransitionRenderLayer_QuartzShowHideTransitionRenderLayer *_transitionRenderLayer;
}
- (void)renderLayerWantsToReexpand:(id)aReexpand;
- (void)renderLayerDidChangeBoundingRegion:(id)aRegion;
- (void)renderLayerDidChangeVisualizationMaskAttributesSet:(id)aSet;
- (void)renderLayerDidChangeVisualizationAttributesSet:(id)aSet;
- (void)drawRenderSublayersInRegion:(id)aRegion withDelegate:(id)aDelegate;
- (void)getRenderCacheValidness:(float *)aValidness validnessEvaluator:(id *)aEvaluator includeScaling:(BOOL *)aScaling includeSkewing:(BOOL *)aSkewing includeRotation:(BOOL *)aRotation includeDevicePointAligning:(BOOL *)aAligning forRegion:(id)aRegion affineTransform:(CGAffineTransform)aTransform transformationIntent:(struct HyperPlayerBase_anon12 *)aIntent;
- (BOOL)unionBoundingRegionOfSublayersVisualAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion;
- (id)calculateBoundingRegion;
- (void)fillBoundingRegionAttributesSet:(id)aSet;
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
- (id)HSShowHideTransitionRenderLayer_transitionRendererRenderLayer;
- (id)copyRemovingRenderSublayers;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy;
@end

@interface HSShowHideTransitionRenderLayer_QuartzShowHideTransitionRenderLayer : HSGenericRenderLayer <HSRenderLayerObserver, NSObject>
{
    id<HSCardObjectAttributes> _cardObjectAttributes;
    id<HSShowHideTransitionAttributes> _showHideTransitionAtributes;
    HSShowHideTransitionRenderLayer_QuartzShowHideTransitionRendererRenderLayer *_transitionRendererRenderLayer;
}
- (void)renderLayerWantsToReexpand:(id)aReexpand;
- (void)renderLayerDidChangeBoundingRegion:(id)aRegion;
- (void)renderLayerDidChangeVisualizationMaskAttributesSet:(id)aSet;
- (void)renderLayerDidChangeVisualizationAttributesSet:(id)aSet;
- (BOOL)cacheRenderingInRegion:(id)aRegion withAffineTransform:(CGAffineTransform)aTransform validness:(CGFloat)aValidness validnessEvaluator:(id)aEvaluator delegate:(id)aDelegate force:(BOOL)aForce share:(BOOL)aShare resultCache:(id *)aCache;
- (id)continuousChangeSensitiveVisualizationAttributes;
- (void)getRenderCacheValidness:(float *)aValidness validnessEvaluator:(id *)aEvaluator includeScaling:(BOOL *)aScaling includeSkewing:(BOOL *)aSkewing includeRotation:(BOOL *)aRotation includeDevicePointAligning:(BOOL *)aAligning forRegion:(id)aRegion affineTransform:(CGAffineTransform)aTransform transformationIntent:(struct HyperPlayerBase_anon12 *)aIntent;
- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce;
- (void)drawRenderSublayersInRegion:(id)aRegion withDelegate:(id)aDelegate;
- (BOOL)unionBoundingRegionOfConcreteAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion;
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
- (id)HSShowHideTransitionRenderLayer_QuartzShowHideTransitionRenderLayer_transitionRendererRenderLayer;
- (id)copyRemovingRenderSublayers;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy;
@end

@interface HSShowHideTransitionRenderLayer_QuartzShowHideTransitionRendererRenderLayer : HSGenericRenderLayer <HSRenderLayerObserver, NSObject>
{
    id<HSCardObjectAttributes> _cardObjectAttributes;
    id<HSShowHideTransitionAttributes> _showHideTransitionAtributes;
    id<HSRenderLayer> _contentRenderLayer;
}
- (void)renderLayerWantsToReexpand:(id)aReexpand;
- (void)renderLayerDidChangeBoundingRegion:(id)aRegion;
- (void)renderLayerDidChangeVisualizationMaskAttributesSet:(id)aSet;
- (void)renderLayerDidChangeVisualizationAttributesSet:(id)aSet;
- (BOOL)cacheRenderingInRegion:(id)aRegion withAffineTransform:(CGAffineTransform)aTransform validness:(CGFloat)aValidness validnessEvaluator:(id)aEvaluator delegate:(id)aDelegate force:(BOOL)aForce share:(BOOL)aShare resultCache:(id *)aCache;
- (struct __CVPixelBufferPool *)HSShowHideTransitionRenderLayer_QuartzShowHideTransitionRendererRenderLayer_createPixelBufferPoolWithWidth:(NSUInteger)aWidth height:(NSUInteger)aHeight;
- (id)continuousChangeSensitiveVisualizationAttributes;
- (void)invalidateRenderCache:(id)aCache withAttributeChangeNotification:(id)aNotification;
- (void)getRenderCacheValidness:(float *)aValidness validnessEvaluator:(id *)aEvaluator cachingTransform:(CGAffineTransform *)aTransform forRegion:(id)aRegion affineTransform:(CGAffineTransform)aTransform2 transformationIntent:(struct HyperPlayerBase_anon12 *)aIntent;
- (void)getRenderCacheValidness:(float *)aValidness validnessEvaluator:(id *)aEvaluator includeScaling:(BOOL *)aScaling includeSkewing:(BOOL *)aSkewing includeRotation:(BOOL *)aRotation includeDevicePointAligning:(BOOL *)aAligning forRegion:(id)aRegion affineTransform:(CGAffineTransform)aTransform transformationIntent:(struct HyperPlayerBase_anon12 *)aIntent;
- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce;
- (void)drawRenderSublayersInRegion:(id)aRegion withDelegate:(id)aDelegate;
- (BOOL)unionBoundingRegionOfConcreteAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion;
- (id)calculateBoundingRegion;
- (void)fillBoundingRegionAttributesSet:(id)aSet;
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

@interface HSShowHideTransitionRenderLayer_QuartzShowHideTransitionRendererRenderCache : HSGenericRenderCache
{
    id<HSQuartzTransitionRenderer> _quartzTransitionRenderer;
    struct __CVPixelBufferPool *_pixelBufferPool;
}
- (void)drawRegion:(id)aRegion;
- (BOOL)intersectsWithRegion:(id)aRegion;
- (BOOL)containsRegion:(id)aRegion;
- (id)description;
- (void)dealloc;
- (id)initWithQuartzTransitionRenderer:(id)aRenderer pixelBufferPool:(struct __CVPixelBufferPool *)aPool renderLayer:(id)aLayer affineTransform:(CGAffineTransform)aTransform temporaryValidness:(CGFloat)aValidness persistentValidness:(CGFloat)aValidness2 validnessEvaluator:(id)aEvaluator;
- (id)initWithRenderLayer:(id)aLayer affineTransform:(CGAffineTransform)aTransform temporaryValidness:(CGFloat)aValidness persistentValidness:(CGFloat)aValidness2 validnessEvaluator:(id)aEvaluator;
@end

