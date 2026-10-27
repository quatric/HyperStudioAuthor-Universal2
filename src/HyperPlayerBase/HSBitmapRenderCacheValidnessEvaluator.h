#import "HyperPlayerBasePrefix.h"


@interface HSBitmapRenderCacheValidnessEvaluator : NSObject <HSRenderCacheValidnessEvaluator, NSObject>
{
    unsigned int _evaluatesForScaling:1;
    unsigned int _evaluatesForSkewing:1;
    unsigned int _evaluatesForRotation:1;
    unsigned int _evaluatesForOffset:1;
}
+ (id)validnessEvaluatorForScaling:(BOOL)aScaling skewing:(BOOL)aSkewing rotation:(BOOL)aRotation offset:(BOOL)aOffset;
+ (CGFloat)bitmapValidnessForOffset:(NSSize)aOffset;
+ (CGFloat)bitmapValidnessForRotationAngle:(CGFloat)aAngle;
+ (CGFloat)bitmapValidnessForSkewAngle:(CGFloat)aAngle;
+ (CGFloat)bitmapValidnessForScaleFactor:(NSSize)aFactor;
+ (CGFloat)HSBitmapRenderCacheValidnessEvaluator_bitmapValidnessForScaleFactor:(CGFloat)aFactor;
- (id)validnessEvaluatorByMergingWithValidnessEvaluator:(id)aEvaluator;
- (id)minBitmapValidnessEvaluatorForMergingWithBitmapValidnessEvaluator:(id)aEvaluator;
- (CGFloat)evaluateForAffineTransform:(CGAffineTransform)aTransform withContentValidness:(CGFloat)aValidness contentAffineTransform:(CGAffineTransform)aTransform2;
- (NSSize)offsetForAffineTransform:(CGAffineTransform)aTransform withContentAffineTransform:(CGAffineTransform)aTransform2;
- (CGFloat)rotationAngleForAffineTransform:(CGAffineTransform)aTransform withContentAffineTransform:(CGAffineTransform)aTransform2;
- (CGFloat)skewAngleForAffineTransform:(CGAffineTransform)aTransform withContentAffineTransform:(CGAffineTransform)aTransform2;
- (NSSize)scaleFactorForAffineTransform:(CGAffineTransform)aTransform withContentAffineTransform:(CGAffineTransform)aTransform2;
- (BOOL)evaluatesForOffset;
- (BOOL)evaluatesForRotation;
- (BOOL)evaluatesForSkewing;
- (BOOL)evaluatesForScaling;
- (NSUInteger)hash;
- (BOOL)isEqual:(id)aEqual;
- (BOOL)HSBitmapRenderCacheValidnessEvaluator_isEqualToBitmapValidnessEvaluator:(id)aEvaluator;
- (id)initToEvaluateForScaling:(BOOL)aScaling skewing:(BOOL)aSkewing rotation:(BOOL)aRotation offset:(BOOL)aOffset;
- (id)init;
@end

