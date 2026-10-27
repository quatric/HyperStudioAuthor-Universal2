#import "HyperPlayerBasePrefix.h"
#import "HSGenericRenderLayer.h"


@interface HSButtonObjectBackgroundRenderLayer : HSGenericRenderLayer <HSRenderLayerObserver, NSObject>
{
    id<HSButtonObjectAttributes> _buttonAttributes;
    NSString *_currentBackgroundStyle;
    HSGenericRenderLayer *_currentBackgroundRenderLayer;
}
- (void)renderLayerWantsToReexpand:(id)aReexpand;
- (void)renderLayerDidChangeBoundingRegion:(id)aRegion;
- (void)renderLayerDidChangeVisualizationMaskAttributesSet:(id)aSet;
- (void)renderLayerDidChangeVisualizationAttributesSet:(id)aSet;
- (void)getRenderCacheValidness:(float *)aValidness validnessEvaluator:(id *)aEvaluator includeScaling:(BOOL *)aScaling includeSkewing:(BOOL *)aSkewing includeRotation:(BOOL *)aRotation includeDevicePointAligning:(BOOL *)aAligning forRegion:(id)aRegion affineTransform:(CGAffineTransform)aTransform transformationIntent:(struct HyperPlayerBase_anon12 *)aIntent;
- (BOOL)willCacheRenderingInRegion:(id)aRegion withTransformationIntent:(struct HyperPlayerBase_anon12 *)aIntent countOnRenderSublayersInfluence:(NSInteger)aInfluence force:(BOOL)aForce;
- (BOOL)unionBoundingRegionOfLocalVisualAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion;
- (id)calculateBoundingRegion;
- (BOOL)requiresTransparencyLayer;
- (BOOL)isEmpty;
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate;
- (void)fillVisualizationMaskAttributesSet:(id)aSet;
- (void)fillVisualizationAttributesSet:(id)aSet;
- (id)currentBackgroundRenderLayer;
- (id)preferredBackgroundRenderLayer;
- (id)buttonAttributes;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy;
@end

