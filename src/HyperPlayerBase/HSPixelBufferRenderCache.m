#import "HSPixelBufferRenderCache.h"
// A render cache held as a pixel buffer (drawn through a CGImage of it).
@implementation HSPixelBufferRenderCache
- (NSUInteger)cashSize
{
    return _pixelBuffer != NULL ? CVEPixelBufferGetDataSize(_pixelBuffer) : 0;
}
- (void)drawRegion:(id)aRegion
{
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    if (context == NULL || [self image] == NULL)
        return;
    CGContextConcatCTM(context, [self drawingAffineTransform]);
    CGRect rect = HSPixelAlignment_rectAlignPixel(context, CGRectMake(0, 0, CGImageGetWidth(_image), CGImageGetHeight(_image)));
    CGContextDrawImage(context, rect, _image);
}
- (struct CGImage *)image
{
    if (_image == NULL)
        _image = CGEImageCreateWithPixelBuffer(_pixelBuffer, kCVPixelBufferLock_ReadOnly, NULL, true, kCGRenderingIntentDefault);
    return _image;
}
// In the buffer's pixels, with a 0.01 margin.
- (BOOL)intersectsWithRegion:(id)aRegion
{
    size_t width = CVPixelBufferGetWidth(_pixelBuffer), height = CVPixelBufferGetHeight(_pixelBuffer);
    HSMutableRegion *region = [[aRegion mutableCopy] autorelease];
    [region applyAffineTransform:[self affineTransform]];
    return [region intersectsRect:NSMakeRect(-0.01, -0.01, width + 0.02, height + 0.02)];
}
- (BOOL)containsRegion:(id)aRegion
{
    size_t width = CVPixelBufferGetWidth(_pixelBuffer), height = CVPixelBufferGetHeight(_pixelBuffer);
    HSMutableRegion *region = [[aRegion mutableCopy] autorelease];
    [region applyAffineTransform:[self affineTransform]];
    return NSContainsRect(NSMakeRect(-0.01, -0.01, width + 0.02, height + 0.02), [region boundingRect]);
}
- (struct __CVBuffer *)pixelBuffer
{
    return _pixelBuffer;
}
- (void)dealloc
{
    CGImageRelease(_image);
    CVPixelBufferRelease(_pixelBuffer);
    [super dealloc];
}
- (id)initWithPixelBuffer:(struct __CVBuffer *)aBuffer renderLayer:(id)aLayer affineTransform:(CGAffineTransform)aTransform temporaryValidness:(CGFloat)aValidness persistentValidness:(CGFloat)aValidness2 validnessEvaluator:(id)aEvaluator
{
    self = [super initWithRenderLayer:aLayer affineTransform:aTransform temporaryValidness:aValidness persistentValidness:aValidness2 validnessEvaluator:aEvaluator];
    if (self != nil)
        _pixelBuffer = CVPixelBufferRetain(aBuffer);
    return self;
}
- (id)initWithRenderLayer:(id)aLayer affineTransform:(CGAffineTransform)aTransform temporaryValidness:(CGFloat)aValidness persistentValidness:(CGFloat)aValidness2 validnessEvaluator:(id)aEvaluator
{
    [self release];
    return nil;
}
@end
