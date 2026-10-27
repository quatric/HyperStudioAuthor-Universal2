#import "HyperPlayerBasePrefix.h"
#import "HSGenericEffectRenderLayer.h"


@interface HSGenericCIEffectRenderLayer : HSGenericEffectRenderLayer
{
    id<HSCoreImageEffectAccessing> _coreImageEffectAccessing;
    CGRect _cachedBoundingRect;
}
- (BOOL)cacheRenderingInRegion:(id)aRegion withAffineTransform:(CGAffineTransform)aTransform validness:(CGFloat)aValidness validnessEvaluator:(id)aEvaluator delegate:(id)aDelegate force:(BOOL)aForce share:(BOOL)aShare resultCache:(id *)aCache;
- (void)getRenderCacheValidness:(float *)aValidness validnessEvaluator:(id *)aEvaluator includeScaling:(BOOL *)aScaling includeSkewing:(BOOL *)aSkewing includeRotation:(BOOL *)aRotation includeDevicePointAligning:(BOOL *)aAligning forRegion:(id)aRegion affineTransform:(CGAffineTransform)aTransform transformationIntent:(struct HyperPlayerBase_anon12 *)aIntent;
- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce;
- (void)drawRenderSublayersInRegion:(id)aRegion withDelegate:(id)aDelegate;
- (id)HSGenericCIEffectRenderLayer_cacheRenderingInRegion:(id)aRegion withTemporaryValidness:(CGFloat)aValidness persistentValidness:(CGFloat)aValidness2 delegate:(id)aDelegate share:(BOOL)aShare;
- (id)calculateBoundingRegion;
- (void)fillBoundingRegionAttributesSet:(id)aSet;
- (BOOL)requiresTransparencyLayer;
- (id)dummyCIImageWithSize:(NSSize)aSize;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy;
@end

