#import "HyperPlayerBasePrefix.h"


@interface HSGroupRenderCacheValidnessEvaluator : NSObject <HSRenderCacheValidnessEvaluator, NSObject>
{
    id<HSRenderCacheValidnessEvaluator> _validnessEvaluator1;
    id<HSRenderCacheValidnessEvaluator> _validnessEvaluator2;
}
- (id)validnessEvaluatorByMergingWithValidnessEvaluator:(id)aEvaluator;
- (CGFloat)evaluateForAffineTransform:(CGAffineTransform)aTransform withContentValidness:(CGFloat)aValidness contentAffineTransform:(CGAffineTransform)aTransform2;
- (BOOL)isEqual:(id)aEqual;
- (BOOL)containsValidnessEvaluator:(id)aEvaluator;
- (id)HSGroupRenderCacheValidnessEvaluator_validnessEvaluator2;
- (id)HSGroupRenderCacheValidnessEvaluator_validnessEvaluator1;
- (void)dealloc;
- (id)initWithValidnessEvaluator:(id)aEvaluator andValidnessEvaluator:(id)aEvaluator2;
- (id)init;
@end

