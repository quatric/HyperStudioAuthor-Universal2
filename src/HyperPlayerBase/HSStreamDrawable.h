#import "HyperPlayerBasePrefix.h"


@interface HSStreamDrawable : NSObject
{
    struct __CVPixelBufferPool *_pixelBufferPool;
    struct OpaqueCMProfileRef *_colorProfile;
    struct CGColorSpace *_colorSpace;
    struct __CVBuffer *_currentPixelBuffer;
    CGPathRef _clipPath;
    unsigned int _invalidRectCount;
    struct __CFArray *_invalidRectsDataArray;
    NSData *_invalidRectsData;
    BOOL _clearsContextBeforeDraw;
}
- (struct __CVBuffer *)pixelBuffer;
- (void)drawRect:(NSRect)aRect;
- (void)drawRect:(CGRect)aRect inCoreGraphicsContext:(struct CGContext *)aContext;
- (BOOL)needsToDrawRect:(NSRect)aRect;
- (void)getRectsBeingDrawn:(NSRect **)aDrawn count:(unsigned int *)aCount;
- (void)setClearsContextBeforeDraw:(BOOL)aDraw;
- (BOOL)clearsContextBeforeDraw;
- (void)invalidateInRects:(NSRect *)aRects count:(NSUInteger)aCount;
- (void)invalidateInRect:(NSRect)aRect;
- (void)invalidate;
- (void)setColorProfile:(struct OpaqueCMProfileRef *)aProfile colorSpace:(struct CGColorSpace *)aSpace;
- (struct CGColorSpace *)colorSpace;
- (struct OpaqueCMProfileRef *)colorProfile;
- (void)dealloc;
- (id)initWithPixelBufferPoolAttributes:(id)aAttributes pixelBufferAttributes:(id)aAttributes2;
- (id)initWithWidth:(NSUInteger)aWidth height:(NSUInteger)aHeight;
- (id)init;
- (void)setClipPath:(CGPathRef)aPath;
@end

