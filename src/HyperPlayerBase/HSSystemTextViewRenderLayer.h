#import "HyperPlayerBasePrefix.h"
#import "HSGenericSystemViewRenderLayer.h"


@interface HSSystemTextViewRenderLayer : HSGenericSystemViewRenderLayer
{
    id<HSSystemTextViewAttributes> _systemTextViewAttributes;
}
- (BOOL)cacheRenderingInRegion:(id)aRegion withAffineTransform:(CGAffineTransform)aTransform validness:(CGFloat)aValidness validnessEvaluator:(id)aEvaluator delegate:(id)aDelegate force:(BOOL)aForce share:(BOOL)aShare resultCache:(id *)aCache;
- (void)getRenderCacheValidness:(float *)aValidness validnessEvaluator:(id *)aEvaluator includeScaling:(BOOL *)aScaling includeSkewing:(BOOL *)aSkewing includeRotation:(BOOL *)aRotation includeDevicePointAligning:(BOOL *)aAligning forRegion:(id)aRegion affineTransform:(CGAffineTransform)aTransform transformationIntent:(struct HyperPlayerBase_anon12 *)aIntent;
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate;
- (id)drawingSystemTextView;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy drawPlaceholderView:(BOOL)aView;
@end

