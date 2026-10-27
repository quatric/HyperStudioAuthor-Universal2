#import "HyperPlayerBasePrefix.h"
#import "HSGenericGroupRenderLayer.h"


@interface HSTransparencyRenderLayer : HSGenericGroupRenderLayer
{
    unsigned int _isCreatingRenderCache:1;
}
- (BOOL)cacheRenderingInRegion:(id)aRegion forAffineTransform:(CGAffineTransform)aTransform withTransformationIntent:(struct HyperPlayerBase_anon12 *)aIntent acceptableValidnessLimit:(CGFloat)aLimit delegate:(id)aDelegate force:(BOOL)aForce share:(BOOL)aShare resultCache:(id *)aCache;
- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce;
- (void)drawRegion:(id)aRegion withDelegate:(id)aDelegate;
- (BOOL)requiresTransparencyLayer;
@end

@interface NSGraphicsContext (HSTransparencyRenderLayer)
+ (id)NSGraphicsContext_HSTransparencyRenderLayer_transparencyLayerRequests;
- (BOOL)isHyperTransparencyLayerRequested;
- (void)endHyperTransparencyLayerRequest;
- (void)beginHyperTransparencyLayerRequest;
@end

