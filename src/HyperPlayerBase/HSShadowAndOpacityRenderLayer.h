#import "HyperPlayerBasePrefix.h"
#import "HSBitmapRenderCacheValidnessEvaluator.h"
#import "HSGenericRenderCache.h"
#import "HSGenericRenderLayer.h"


@interface HSShadowAndOpacityRenderLayer : HSGenericRenderLayer <HSRenderLayerObserver, NSObject>
{
    id<HSGeometryAttributes> _geometryAttributes;
    id<HSShadowAttributes> _shadowAttributes;
    HSShadowAndOpacityRenderLayer_ShadowOpacityRenderLayer *_shadowOpacityRenderLayer;
    HSOpacityRenderLayer *_opacityRenderLayer;
}
- (void)renderLayerWantsToReexpand:(id)aReexpand;
- (void)renderLayerDidChangeBoundingRegion:(id)aRegion;
- (void)renderLayerDidChangeVisualizationMaskAttributesSet:(id)aSet;
- (void)renderLayerDidChangeVisualizationAttributesSet:(id)aSet;
- (void)getRenderCacheValidness:(float *)aValidness validnessEvaluator:(id *)aEvaluator includeScaling:(BOOL *)aScaling includeSkewing:(BOOL *)aSkewing includeRotation:(BOOL *)aRotation includeDevicePointAligning:(BOOL *)aAligning forRegion:(id)aRegion affineTransform:(CGAffineTransform)aTransform transformationIntent:(struct HyperPlayerBase_anon12 *)aIntent;
- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce;
- (void)drawRenderSublayersInRegion:(id)aRegion withDelegate:(id)aDelegate;
- (BOOL)unionBoundingRegionOfSublayersVisualAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion;
- (BOOL)unionBoundingRegionOfLocalVisualAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion;
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
- (id)initWithHyperObject:(id)aObject opacityAttributes:(BOOL)aAttributes cachingPolicy:(NSInteger)aPolicy;
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy;
@end

@interface HSShadowAndOpacityRenderLayer_ShadowOpacityRenderLayer : HSGenericRenderLayer <HSRenderLayerObserver, NSObject>
{
    id<HSShadowAttributes> _shadowAttributes;
    id<HSOpacityAttributes> _opacityAttributes;
    HSShadowAndOpacityRenderLayer_ShadowRenderLayer *_shadowRenderLayer;
}
- (void)renderLayerWantsToReexpand:(id)aReexpand;
- (void)renderLayerDidChangeBoundingRegion:(id)aRegion;
- (void)renderLayerDidChangeVisualizationMaskAttributesSet:(id)aSet;
- (void)renderLayerDidChangeVisualizationAttributesSet:(id)aSet;
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
- (id)copyRemovingRenderSublayers;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject opacityAttributes:(BOOL)aAttributes cachingPolicy:(NSInteger)aPolicy;
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy;
@end

@interface HSShadowAndOpacityRenderLayer_ShadowRenderLayer : HSGenericRenderLayer <HSRenderLayerObserver, NSObject, HSShadowAndOpacityRenderLayer_ShadowMaskConsumer>
{
    HSShadowAndOpacityRenderLayer_ShadowMaskRenderLayer *_shadowMaskRenderLayer;
    struct CGImage *_shadowMask;
    CGAffineTransform _shadowMaskTransform;
}
- (void)renderLayerWantsToReexpand:(id)aReexpand;
- (void)renderLayerDidChangeBoundingRegion:(id)aRegion;
- (void)renderLayerDidChangeVisualizationMaskAttributesSet:(id)aSet;
- (void)renderLayerDidChangeVisualizationAttributesSet:(id)aSet;
- (void)getRenderCacheValidness:(float *)aValidness validnessEvaluator:(id *)aEvaluator includeScaling:(BOOL *)aScaling includeSkewing:(BOOL *)aSkewing includeRotation:(BOOL *)aRotation includeDevicePointAligning:(BOOL *)aAligning forRegion:(id)aRegion affineTransform:(CGAffineTransform)aTransform transformationIntent:(struct HyperPlayerBase_anon12 *)aIntent;
- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce;
- (void)drawRenderSublayersInRegion:(id)aRegion withDelegate:(id)aDelegate;
- (void)HSShadowAndOpacityRenderLayer_ShadowMaskConsumer_setShadowMask:(struct CGImage *)aMask transform:(CGAffineTransform)aTransform;
- (BOOL)unionBoundingRegionOfSublayersVisualAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion;
- (BOOL)unionBoundingRegionOfLocalVisualAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion;
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

@interface HSShadowAndOpacityRenderLayer_ShadowMaskRenderLayer : HSGenericRenderLayer <HSRenderLayerObserver, NSObject>
{
    id<HSGeometryAttributes> _geometryAttributes;
    id<HSShadowAttributes> _shadowAttributes;
    id<HSRenderLayer> _contentRenderLayer;
    unsigned int _isHorizontalScaleInContentFlagInitialized:1;
    unsigned int _isHorizontalScaleInContent:1;
    unsigned int _isVerticalScaleInContentFlagInitialized:1;
    unsigned int _isVerticalScaleInContent:1;
    unsigned int _isWidthScaleInContentFlagInitialized:1;
    unsigned int _isWidthScaleInContent:1;
    unsigned int _isHeightScaleInContentFlagInitialized:1;
    unsigned int _isHeightScaleInContent:1;
    unsigned int _isHorizontalFlipInContentFlagInitialized:1;
    unsigned int _isHorizontalFlipInContent:1;
    unsigned int _isVerticalFlipInContentFlagInitialized:1;
    unsigned int _isVerticalFlipInContent:1;
    unsigned int _isRotationAngleInContentFlagInitialized:1;
    unsigned int _isRotationAngleInContent:1;
    unsigned int _isSkewAngleInContentFlagInitialized:1;
    unsigned int _isSkewAngleInContent:1;
    unsigned int _isShadowOffsetInContentFlagInitialized:1;
    unsigned int _isShadowOffsetInContent:1;
}
- (void)renderLayerWantsToReexpand:(id)aReexpand;
- (void)renderLayerDidChangeBoundingRegion:(id)aRegion;
- (void)renderLayerDidChangeVisualizationMaskAttributesSet:(id)aSet;
- (void)renderLayerDidChangeVisualizationAttributesSet:(id)aSet;
- (BOOL)cacheRenderingInRegion:(id)aRegion withAffineTransform:(CGAffineTransform)aTransform validness:(CGFloat)aValidness validnessEvaluator:(id)aEvaluator delegate:(id)aDelegate force:(BOOL)aForce share:(BOOL)aShare resultCache:(id *)aCache;
- (id)continuousChangeSensitiveVisualizationAttributes;
- (void)invalidateRenderCache:(id)aCache withAttributeChangeNotification:(id)aNotification;
- (void)getRenderCacheValidness:(float *)aValidness validnessEvaluator:(id *)aEvaluator includeScaling:(BOOL *)aScaling includeSkewing:(BOOL *)aSkewing includeRotation:(BOOL *)aRotation includeDevicePointAligning:(BOOL *)aAligning forRegion:(id)aRegion affineTransform:(CGAffineTransform)aTransform transformationIntent:(struct HyperPlayerBase_anon12 *)aIntent;
- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce;
- (void)drawRenderSublayersInRegion:(id)aRegion withDelegate:(id)aDelegate;
- (BOOL)HSShadowAndOpacityRenderLayer_ShadowMaskRenderLayer_createShadowMask:(struct CGImage **)aMask transform:(CGAffineTransform *)aTransform forRegion:(id)aRegion deviceTransform:(CGAffineTransform)aTransform2 withDelegate:(id)aDelegate maxArea:(CGFloat)aArea;
- (BOOL)unionBoundingRegionOfConcreteAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion;
- (id)calculateBoundingRegion;
- (id)contentRegionForShadowRegion:(id)aRegion;
- (id)shadowRegionForContentRegion:(id)aRegion;
- (void)fillBoundingRegionAttributesSet:(id)aSet;
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

@interface HSShadowAndOpacityRenderLayer_ShadowMaskRenderCacheValidnessEvaluator : HSBitmapRenderCacheValidnessEvaluator
{
    unsigned int _isBlurRadiusMaximizedHorizontally:1;
    unsigned int _isBlurRadiusMaximizedVertically:1;
}
- (NSSize)scaleFactorForAffineTransform:(CGAffineTransform)aTransform withContentAffineTransform:(CGAffineTransform)aTransform2;
- (BOOL)isEqual:(id)aEqual;
- (BOOL)HSShadowAndOpacityRenderLayer_ShadowMaskRenderCacheValidnessEvaluator_isBlurRadiusMaximizedVertically;
- (BOOL)HSShadowAndOpacityRenderLayer_ShadowMaskRenderCacheValidnessEvaluator_isBlurRadiusMaximizedHorizontally;
- (id)initWithBlurRadiusMaximizedHorizontally:(BOOL)aHorizontally vertically:(BOOL)aVertically toEvaluateForScaling:(BOOL)aScaling skewing:(BOOL)aSkewing rotation:(BOOL)aRotation offset:(BOOL)aOffset;
- (id)initToEvaluateForScaling:(BOOL)aScaling skewing:(BOOL)aSkewing rotation:(BOOL)aRotation offset:(BOOL)aOffset;
@end

@interface HSShadowAndOpacityRenderLayer_ShadowMaskRenderCache : HSGenericRenderCache
{
    struct CGImage *_shadowMask;
    CGAffineTransform _shadowMaskTransform;
}
- (void)drawRegion:(id)aRegion;
- (BOOL)intersectsWithRegion:(id)aRegion;
- (BOOL)containsRegion:(id)aRegion;
- (void)dealloc;
- (id)initWithShadowMask:(struct CGImage *)aMask renderLayer:(id)aLayer affineTransform:(CGAffineTransform)aTransform temporaryValidness:(CGFloat)aValidness persistentValidness:(CGFloat)aValidness2 validnessEvaluator:(id)aEvaluator;
- (id)initWithRenderLayer:(id)aLayer affineTransform:(CGAffineTransform)aTransform temporaryValidness:(CGFloat)aValidness persistentValidness:(CGFloat)aValidness2 validnessEvaluator:(id)aEvaluator;
@end

@interface NSGraphicsContext (HSShadowAndOpacityRenderLayer_ShadowMaskConsumer)
- (void)HSShadowAndOpacityRenderLayer_ShadowMaskConsumer_setShadowMask:(struct CGImage *)aMask transform:(CGAffineTransform)aTransform;
- (void)HSShadowAndOpacityRenderLayer_ShadowMaskConsumer_setShadowMaskConsumer:(id)aConsumer;
- (id)HSShadowAndOpacityRenderLayer_ShadowMaskConsumer_shadowMaskConsumer;
@end

