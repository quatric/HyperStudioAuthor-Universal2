#import "HyperPlayerBasePrefix.h"
#import "HSGenericRenderCache.h"


@interface HSPixelBufferRenderCache : HSGenericRenderCache
{
    struct __CVBuffer *_pixelBuffer;
    struct CGImage *_image;
}
- (NSUInteger)cashSize;
- (void)drawRegion:(id)aRegion;
- (struct CGImage *)image;
- (BOOL)intersectsWithRegion:(id)aRegion;
- (BOOL)containsRegion:(id)aRegion;
- (struct __CVBuffer *)pixelBuffer;
- (void)dealloc;
- (id)initWithPixelBuffer:(struct __CVBuffer *)aBuffer renderLayer:(id)aLayer affineTransform:(CGAffineTransform)aTransform temporaryValidness:(CGFloat)aValidness persistentValidness:(CGFloat)aValidness2 validnessEvaluator:(id)aEvaluator;
- (id)initWithRenderLayer:(id)aLayer affineTransform:(CGAffineTransform)aTransform temporaryValidness:(CGFloat)aValidness persistentValidness:(CGFloat)aValidness2 validnessEvaluator:(id)aEvaluator;
@end

