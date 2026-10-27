#import "HyperPlayerBasePrefix.h"
#import "HSGenericRenderCache.h"


@interface HSGenericImageRenderCache : HSGenericRenderCache
{
    NSImageRep *_imageRep;
}
- (void)drawRegion:(id)aRegion;
- (BOOL)intersectsWithRegion:(id)aRegion;
- (BOOL)containsRegion:(id)aRegion;
- (void)dealloc;
- (id)initWithImageRep:(id)aRep renderLayer:(id)aLayer affineTransform:(CGAffineTransform)aTransform temporaryValidness:(CGFloat)aValidness persistentValidness:(CGFloat)aValidness2 validnessEvaluator:(id)aEvaluator;
- (id)initWithRenderLayer:(id)aLayer affineTransform:(CGAffineTransform)aTransform temporaryValidness:(CGFloat)aValidness persistentValidness:(CGFloat)aValidness2 validnessEvaluator:(id)aEvaluator;
@end

