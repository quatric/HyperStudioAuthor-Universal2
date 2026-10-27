#import "HyperPlayerBasePrefix.h"
#import "HSMovieVisualContextRenderer.h"


@interface HSMoviePixelBufferRenderer : HSMovieVisualContextRenderer <HSMovieRenderer, NSObject>
{
    struct CGColorSpace *_workingCGColorSpace;
    NSColorSpace *_workingColorSpace;
    struct CGImage *_currentFrameImage;
    struct __CVPixelBufferPool *_pixelBufferPool;
}
- (void)drawCurrentFrameInRect:(NSRect)aRect fromRelativeRect:(NSRect)aRect2 withTransparentColor:(id)aColor hueTolerance:(double)aTolerance chromaTolerance:(double)aTolerance2 lightnessTolerance:(double)aTolerance3;
- (void)drawFramePixelBuffer:(struct __CVBuffer *)aBuffer inRect:(NSRect)aRect fromRelativeRect:(NSRect)aRect2 withTransparentColor:(id)aColor hueTolerance:(double)aTolerance chromaTolerance:(double)aTolerance2 lightnessTolerance:(double)aTolerance3;
- (void)HSMoviePixelBufferRenderer_drawFramePixelBuffer:(struct __CVBuffer *)aBuffer inRect:(NSRect)aRect fromRelativeRect:(NSRect)aRect2 withTransparentColor:(id)aColor hueTolerance:(double)aTolerance chromaTolerance:(double)aTolerance2 lightnessTolerance:(double)aTolerance3;
- (struct __CVPixelBufferPool *)HSMoviePixelBufferRenderer_pixelBufferPoolWithWidth:(NSUInteger)aWidth height:(NSUInteger)aHeight;
- (void)drawCurrentFrameInRect:(NSRect)aRect fromRelativeRect:(NSRect)aRect2;
- (struct CGImage *)currentFrameImage;
- (void)invalidateCurrentFrame;
- (void)didUpdateCurrentFrameImageBuffer:(struct __CVBuffer *)aBuffer;
- (void)dealloc;
- (id)initWithQTMovie:(id)aMovie storage:(id)aStorage;
- (id)initWithQTMovie:(id)aMovie storage:(id)aStorage visualContext:(struct OpaqueQTVisualContext *)aContext;
@end

