#import "HyperPlayerBasePrefix.h"
#import "HSGraphicComposition.h"


@interface HSQCGraphicComposition : HSGraphicComposition
{
}
+ (id)compositionWithQuartzComposerComposition:(id)aComposition;
+ (id)compositionWithCompositionFilePath:(id)aPath;
@end

@interface HSQCGraphicComposition_Leopard : HSQCGraphicComposition
{
    QCComposition *_quartzComposerComposition;
}
- (id)createQuartzRendererForSize:(CGSize)aSize;
- (id)createOpenGLRendererForContext:(id)aContext pixelFormat:(id)aFormat;
- (BOOL)hasOpenGLRenderer;
- (BOOL)hasQuartzRenderer;
- (BOOL)isNewFrameAtTime:(double)aTime relativeToTime:(double)aTime2;
- (BOOL)isSlow;
- (id)quartzComposerComposition;
- (NSUInteger)hash;
- (BOOL)isEqual:(id)aEqual;
- (void)dealloc;
- (id)initWithQuartzComposerComposition:(id)aComposition;
- (id)init;
@end

@interface HSQCGraphicComposition_Tiger : HSQCGraphicComposition
{
    NSString *_compositionFilePath;
}
- (id)createQuartzRendererForSize:(CGSize)aSize;
- (id)createOpenGLRendererForContext:(id)aContext pixelFormat:(id)aFormat;
- (BOOL)hasOpenGLRenderer;
- (BOOL)hasQuartzRenderer;
- (BOOL)isNewFrameAtTime:(double)aTime relativeToTime:(double)aTime2;
- (BOOL)isSlow;
- (id)compositionFilePath;
- (NSUInteger)hash;
- (BOOL)isEqual:(id)aEqual;
- (void)dealloc;
- (id)initWithCompositionFilePath:(id)aPath;
- (id)init;
@end

@interface HSQuartzQCGraphicCompositionRenderer : NSObject <HSQuartzGraphicCompositionRenderer, HSGraphicCompositionRenderer, NSObject>
{
    CGSize _size;
    id _compositionReference;
    struct __CFDictionary *_inputs;
    struct __CVPixelBufferPool *_pixelBufferPool;
    NSWindow *_offscreenWindow;
    NSEOpenGLContext *_openGLContext;
    HSOpenGLQCGraphicCompositionRenderer *_openGLRenderer;
    unsigned int _isSizeChanged:1;
}
- (struct CGImage *)frameImageAtTime:(double)aTime;
- (void)renderFrameAtTime:(double)aTime inCoreGraphicsContext:(struct CGContext *)aContext;
- (struct CGImage *)HSQuartzQCGraphicCompositionRenderer_createFrameImageAtTime:(double)aTime;
- (id)valueForOutputKey:(id)aKey;
- (id)valueForInputKey:(id)aKey;
- (BOOL)setValue:(id)aValue forInputKey:(id)aKey;
- (id)outputKeys;
- (id)inputKeys;
- (void)setRendererSize:(CGSize)aSize;
- (CGSize)rendererSize;
- (void)dealloc;
- (id)initWithSize:(CGSize)aSize quartzComposerComposition:(id)aComposition;
- (id)initWithSize:(CGSize)aSize compositionFilePath:(id)aPath;
- (BOOL)HSQuartzQCGraphicCompositionRenderer_preinitWithSize:(CGSize)aSize;
- (id)init;
- (id)HSQuartzQCGraphicCompositionRenderer_createOpenGLRenderer;
@end

@interface HSOpenGLQCGraphicCompositionRenderer : NSObject <HSOpenGLGraphicCompositionRenderer, HSGraphicCompositionRenderer, NSObject>
{
    NSOpenGLPixelFormat *_openGLPixelFormat;
    NSOpenGLContext *_openGLContext;
    QCRenderer *_quartzComposerRenderer;
}
- (id)frameTextureAtTime:(double)aTime;
- (void)renderFrameAtTime:(double)aTime;
- (id)valueForOutputKey:(id)aKey;
- (id)valueForInputKey:(id)aKey;
- (BOOL)setValue:(id)aValue forInputKey:(id)aKey;
- (id)HSOpenGLQCGraphicCompositionRenderer_imageForQuartzComposerRenderer:(id)aRenderer;
- (id)outputKeys;
- (id)inputKeys;
- (id)openGLContext;
- (id)openGLPixelFormat;
- (void)dealloc;
- (id)initWithOpenGLContext:(id)aContext pixelFormat:(id)aFormat quartzComposerComposition:(id)aComposition;
- (id)initWithOpenGLContext:(id)aContext pixelFormat:(id)aFormat compositionFilePath:(id)aPath;
- (id)init;
@end

