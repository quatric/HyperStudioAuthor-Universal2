#import "HyperPlayerBasePrefix.h"
#import "HSTransitionEffect.h"


@interface HSQTTransitionEffect : HSTransitionEffect <EXKeyValueCoding>
{
    id _effectReference;
    HSPointer *_effectDescription;
    unsigned int _swapsInputs:1;
    unsigned int _isExternal:1;
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)setAtomContainerData:(id)aData;
- (id)atomContainerData;
- (BOOL)isExternal;
- (id)createQuartzRendererForSize:(CGSize)aSize;
- (id)createOpenGLRendererForContext:(id)aContext pixelFormat:(id)aFormat;
- (BOOL)hasOpenGLRenderer;
- (BOOL)hasQuartzRenderer;
- (BOOL)isNewFrameAtTime:(double)aTime relativeToTime:(double)aTime2;
- (BOOL)isSlow;
- (NSUInteger)hash;
- (BOOL)isEqual:(id)aEqual;
- (BOOL)HSQTTransitionEffect_swapsInputs;
- (char **)HSQTTransitionEffect_effectDescription;
- (void)dealloc;
- (id)initWithAtomContainerData:(id)aData;
- (id)initWithEffectFilePath:(id)aPath swappedInputs:(BOOL)aInputs;
- (id)initWithEffectFilePath:(id)aPath;
@end

// Draws a QuickTime transition effect description with Quartz.
@interface HSQTTransitionQuartzRenderer : NSObject <HSQuartzTransitionRenderer, HSTransitionRenderer, NSObject>
{
    CGSize _size;
    HSPointer *_effectDescription;
    id _startImage;
    id _endImage;
    struct CGImage *_startFrame;
    struct CGImage *_endFrame;
    void *_frameBuffer;
    struct CGContext *_frameContext;
    unsigned int _swapsInputs:1;
    unsigned int _isSizeChanged:1;
}
- (struct CGImage *)frameImageAtTime:(double)aTime;
- (void)renderFrameAtTime:(double)aTime inCoreGraphicsContext:(struct CGContext *)aContext;
- (struct CGImage *)HSQTTransitionQuartzRenderer_createFrameImageAtTime:(double)aTime;
- (void)setEndImage:(id)aImage;
- (void)setStartImage:(id)aImage;
- (void)setRendererSize:(CGSize)aSize;
- (CGSize)rendererSize;
- (char **)effectDescription;
- (void)dealloc;
- (id)initWithSize:(CGSize)aSize effectDescription:(id)aDescription swappedInputs:(BOOL)aInputs;
- (id)init;
@end

