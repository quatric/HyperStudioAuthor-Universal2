#import "HSBitmapRenderCacheValidnessEvaluator.h"

// How usable a bitmap cache stays under a new transform: 1 when it maps
// pixel for pixel, lower as it gets scaled, skewed, rotated or moved off the
// pixel grid. Tolerances and the odd normalizations are the original's.
@implementation HSBitmapRenderCacheValidnessEvaluator
+ (id)validnessEvaluatorForScaling:(BOOL)aScaling skewing:(BOOL)aSkewing rotation:(BOOL)aRotation offset:(BOOL)aOffset
{
    return [[[self alloc] initToEvaluateForScaling:aScaling skewing:aSkewing rotation:aRotation offset:aOffset] autorelease];
}
+ (CGFloat)bitmapValidnessForOffset:(NSSize)aOffset
{
    float width = (float)aOffset.width;
    float height = (float)aOffset.height;
    float roundedWidth = roundf(width);
    if (width - 0.005f <= roundedWidth && roundedWidth <= width + 0.005f) {
        float roundedHeight = roundf(height);
        if (height - 0.005f <= roundedHeight)
            return roundedHeight <= height + 0.005f ? 1.0f : 0.95f;
    }
    return 0.95f;
}
// The original folds negative remainders by adding 1 rather than pi/2.
+ (CGFloat)bitmapValidnessForRotationAngle:(CGFloat)aAngle
{
    float remainder = fmodf((float)aAngle, (float)M_PI_2);
    if (remainder < 0.0f)
        remainder += 1.0f;
    if (remainder >= -5e-05f && remainder <= 5e-05f)
        return 1.0f;
    if (remainder < 0.99995f)
        return 0.95f;
    return remainder <= 1.00005f ? 1.0f : 0.95f;
}
+ (CGFloat)bitmapValidnessForSkewAngle:(CGFloat)aAngle
{
    float angle = (float)aAngle;
    if (angle >= -5e-05f)
        return angle <= 5e-05f ? 1.0f : 0.95f;
    return 0.95f;
}
+ (CGFloat)bitmapValidnessForScaleFactor:(NSSize)aFactor
{
    float height = (float)[self HSBitmapRenderCacheValidnessEvaluator_bitmapValidnessForScaleFactor:aFactor.height];
    float width = (float)[self HSBitmapRenderCacheValidnessEvaluator_bitmapValidnessForScaleFactor:aFactor.width];
    return fminf(width, height);
}
+ (CGFloat)HSBitmapRenderCacheValidnessEvaluator_bitmapValidnessForScaleFactor:(CGFloat)aFactor
{
    float factor = (float)aFactor;
    if (factor >= 0.99995f && factor <= 1.00005f)
        return 1.0f;
    if (factor > 1.0f) {
        float excess = factor - 1.0f;
        if (excess <= 0.10005f)
            return 1.0f - fmaxf(excess, 0.05f);
        if (excess <= 0.50005f)
            return 1.0f - excess;
        return fminf(1.0f / factor, 0.5f);
    }
    float shortfall = 1.0f - factor;
    if (shortfall <= 0.50005f)
        return 1.0f - fmaxf((float)(shortfall * 0.2), 0.05f);
    return factor;
}
// Bitmap evaluators merge into one evaluating everything either does; a
// subclass instance merges itself, other kinds go into a group.
- (id)validnessEvaluatorByMergingWithValidnessEvaluator:(id)aEvaluator
{
    if (aEvaluator == self)
        return self;
    if ([aEvaluator isKindOfClass:[HSGroupRenderCacheValidnessEvaluator class]])
        return [aEvaluator validnessEvaluatorByMergingWithValidnessEvaluator:self];
    if (![aEvaluator isKindOfClass:[HSBitmapRenderCacheValidnessEvaluator class]])
        return [[[HSGroupRenderCacheValidnessEvaluator alloc] initWithValidnessEvaluator:self andValidnessEvaluator:aEvaluator] autorelease];
    if ([aEvaluator isKindOfClass:[self class]] && ![aEvaluator isMemberOfClass:[self class]])
        return [aEvaluator validnessEvaluatorByMergingWithValidnessEvaluator:self];
    id base = [self minBitmapValidnessEvaluatorForMergingWithBitmapValidnessEvaluator:aEvaluator];
    if ([self HSBitmapRenderCacheValidnessEvaluator_isEqualToBitmapValidnessEvaluator:aEvaluator])
        return base;
    return [[base class] validnessEvaluatorForScaling:([aEvaluator evaluatesForScaling] || _evaluatesForScaling) skewing:([aEvaluator evaluatesForSkewing] || _evaluatesForSkewing) rotation:([aEvaluator evaluatesForRotation] || _evaluatesForRotation) offset:([aEvaluator evaluatesForOffset] || _evaluatesForOffset)];
}
- (id)minBitmapValidnessEvaluatorForMergingWithBitmapValidnessEvaluator:(id)aEvaluator
{
    return self;
}
// The skew and rotation terms combine by minimum, the rest by product.
- (CGFloat)evaluateForAffineTransform:(CGAffineTransform)aTransform withContentValidness:(CGFloat)aValidness contentAffineTransform:(CGAffineTransform)aTransform2
{
    float validness = (float)aValidness;
    if (_evaluatesForScaling)
        validness *= (float)[[self class] bitmapValidnessForScaleFactor:[self scaleFactorForAffineTransform:aTransform withContentAffineTransform:aTransform2]];
    float angular = 1.0f;
    if (_evaluatesForSkewing)
        angular = (float)[[self class] bitmapValidnessForSkewAngle:[self skewAngleForAffineTransform:aTransform withContentAffineTransform:aTransform2]];
    if (_evaluatesForRotation)
        angular = fminf(angular, (float)[[self class] bitmapValidnessForRotationAngle:[self rotationAngleForAffineTransform:aTransform withContentAffineTransform:aTransform2]]);
    validness *= angular;
    if (_evaluatesForOffset)
        validness *= (float)[[self class] bitmapValidnessForOffset:[self offsetForAffineTransform:aTransform withContentAffineTransform:aTransform2]];
    return validness;
}
- (NSSize)offsetForAffineTransform:(CGAffineTransform)aTransform withContentAffineTransform:(CGAffineTransform)aTransform2
{
    return NSMakeSize(aTransform.tx, aTransform.ty);
}
- (CGFloat)rotationAngleForAffineTransform:(CGAffineTransform)aTransform withContentAffineTransform:(CGAffineTransform)aTransform2
{
    float angle;
    if (aTransform.a != 0 || aTransform.b != 0)
        angle = atan2f((float)aTransform.b, (float)aTransform.a);
    else
        angle = (float)((double)atan2f((float)aTransform.d, (float)aTransform.c) - M_PI_2);
    if (angle < 0.0f)
        angle += 6.2831855f;
    return angle;
}
- (CGFloat)skewAngleForAffineTransform:(CGAffineTransform)aTransform withContentAffineTransform:(CGAffineTransform)aTransform2
{
    float a = (float)aTransform.a, b = (float)aTransform.b, c = (float)aTransform.c, d = (float)aTransform.d;
    double angle = atan2((double)(a * c + b * d), (double)(a * d - b * c));
    if (angle < -M_PI_2)
        angle += M_PI;
    else if (angle > M_PI_2)
        angle -= M_PI;
    return nextafterf((float)angle, 0.0f);
}
- (NSSize)scaleFactorForAffineTransform:(CGAffineTransform)aTransform withContentAffineTransform:(CGAffineTransform)aTransform2
{
    return NSMakeSize(hypotf((float)aTransform.a, (float)aTransform.b), hypotf((float)aTransform.c, (float)aTransform.d));
}
- (BOOL)evaluatesForOffset
{
    return _evaluatesForOffset;
}
- (BOOL)evaluatesForRotation
{
    return _evaluatesForRotation;
}
- (BOOL)evaluatesForSkewing
{
    return _evaluatesForSkewing;
}
- (BOOL)evaluatesForScaling
{
    return _evaluatesForScaling;
}
- (NSUInteger)hash
{
    return _evaluatesForScaling | _evaluatesForSkewing << 1 | _evaluatesForRotation << 2 | _evaluatesForOffset << 3;
}
- (BOOL)isEqual:(id)aEqual
{
    if (self == aEqual)
        return YES;
    if (![aEqual isKindOfClass:[HSBitmapRenderCacheValidnessEvaluator class]])
        return NO;
    if ([aEqual isKindOfClass:[self class]] && ![aEqual isMemberOfClass:[self class]])
        return [aEqual isEqual:self];
    return [self HSBitmapRenderCacheValidnessEvaluator_isEqualToBitmapValidnessEvaluator:aEqual];
}
- (BOOL)HSBitmapRenderCacheValidnessEvaluator_isEqualToBitmapValidnessEvaluator:(id)aEvaluator
{
    return !![aEvaluator evaluatesForScaling] == !!_evaluatesForScaling && !![aEvaluator evaluatesForSkewing] == !!_evaluatesForSkewing && !![aEvaluator evaluatesForRotation] == !!_evaluatesForRotation && !![aEvaluator evaluatesForOffset] == !!_evaluatesForOffset;
}
- (id)initToEvaluateForScaling:(BOOL)aScaling skewing:(BOOL)aSkewing rotation:(BOOL)aRotation offset:(BOOL)aOffset
{
    self = [super init];
    if (self) {
        _evaluatesForScaling = aScaling & 1;
        _evaluatesForSkewing = aSkewing & 1;
        _evaluatesForRotation = aRotation & 1;
        _evaluatesForOffset = aOffset & 1;
    }
    return self;
}
- (id)init
{
    return [self initToEvaluateForScaling:NO skewing:NO rotation:NO offset:NO];
}
@end
