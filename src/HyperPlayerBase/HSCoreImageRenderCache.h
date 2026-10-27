#import "HyperPlayerBasePrefix.h"
#import "HSGenericRenderCache.h"


@interface HSCoreImageRenderCache : HSGenericRenderCache
{
    CIImage *_image;
    CGRect _imageRect;
}
+ (id)defaultValidnessEvaluator;
- (void)drawRegion:(id)aRegion;
- (BOOL)intersectsWithRegion:(id)aRegion;
- (BOOL)containsRegion:(id)aRegion;
- (void)dealloc;
- (id)initWithCoreImage:(id)aImage rect:(NSRect)aRect renderLayer:(id)aLayer affineTransform:(CGAffineTransform)aTransform temporaryValidness:(CGFloat)aValidness persistentValidness:(CGFloat)aValidness2 validnessEvaluator:(id)aEvaluator;
- (id)initWithRenderLayer:(id)aLayer affineTransform:(CGAffineTransform)aTransform temporaryValidness:(CGFloat)aValidness persistentValidness:(CGFloat)aValidness2 validnessEvaluator:(id)aEvaluator;
@end

