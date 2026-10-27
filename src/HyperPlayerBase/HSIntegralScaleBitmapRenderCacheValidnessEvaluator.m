#import "HSIntegralScaleBitmapRenderCacheValidnessEvaluator.h"
@implementation HSIntegralScaleBitmapRenderCacheValidnessEvaluator
- (NSSize)scaleFactorForAffineTransform:(CGAffineTransform)aTransform withContentAffineTransform:(CGAffineTransform)aTransform2
{
    // per axis: 1 when the content scale is already the whole number the
    // combined scale rounds to, else the transform's own scale
    float contentX = hypotf(aTransform2.a, aTransform2.b);
    float contentY = hypotf(aTransform2.c, aTransform2.d);
    float scaleX = hypotf(aTransform.a, aTransform.b);
    float scaleY = hypotf(aTransform.c, aTransform.d);
    float roundedX = fmaxf(1.0f, roundf(contentX * scaleX + 0.25f));
    float roundedY = fmaxf(1.0f, roundf(contentY * scaleY + 0.25f));
    return NSMakeSize(contentX == roundedX ? 1.0f : scaleX, contentY == roundedY ? 1.0f : scaleY);
}
- (BOOL)isEqual:(id)aEqual
{
    if (self == aEqual)
        return YES;
    if (![aEqual isKindOfClass:[HSIntegralScaleBitmapRenderCacheValidnessEvaluator class]])
        return NO;
    return [super isEqual:aEqual];
}
@end
