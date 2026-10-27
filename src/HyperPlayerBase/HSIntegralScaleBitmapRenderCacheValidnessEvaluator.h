#import "HyperPlayerBasePrefix.h"
#import "HSBitmapRenderCacheValidnessEvaluator.h"


@interface HSIntegralScaleBitmapRenderCacheValidnessEvaluator : HSBitmapRenderCacheValidnessEvaluator
{
}
- (NSSize)scaleFactorForAffineTransform:(CGAffineTransform)aTransform withContentAffineTransform:(CGAffineTransform)aTransform2;
- (BOOL)isEqual:(id)aEqual;
@end

