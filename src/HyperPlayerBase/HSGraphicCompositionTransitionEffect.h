#import "HyperPlayerBasePrefix.h"
#import "HSTransitionEffect.h"


@interface HSGraphicCompositionTransitionEffect : HSTransitionEffect
{
    HSGraphicComposition *_graphicComposition;
}
- (id)createQuartzRendererForSize:(CGSize)aSize;
- (id)createOpenGLRendererForContext:(id)aContext pixelFormat:(id)aFormat;
- (BOOL)hasOpenGLRenderer;
- (BOOL)hasQuartzRenderer;
- (BOOL)isNewFrameAtTime:(double)aTime relativeToTime:(double)aTime2;
- (BOOL)isSlow;
- (NSUInteger)hash;
- (BOOL)isEqual:(id)aEqual;
- (id)HSGraphicCompositionTransitionEffect_graphicComposition;
- (void)dealloc;
- (id)initWithGraphicComposition:(id)aComposition;
- (id)init;
@end

@interface HSQuartzGraphicCompositionTransitionRenderer : NSObject <HSQuartzTransitionRenderer, HSTransitionRenderer, NSObject>
{
    id<HSQuartzGraphicCompositionRenderer> _graphicCompositionRenderer;
}
- (struct CGImage *)frameImageAtTime:(double)aTime;
- (void)renderFrameAtTime:(double)aTime inCoreGraphicsContext:(struct CGContext *)aContext;
- (void)setEndImage:(id)aImage;
- (void)setStartImage:(id)aImage;
- (void)setRendererSize:(CGSize)aSize;
- (CGSize)rendererSize;
- (void)dealloc;
- (id)initWithQuartzGraphicCompositionRenderer:(id)aRenderer;
- (id)init;
@end

@interface HSOpenGLGraphicCompositionTransitionRenderer : NSObject <HSOpenGLTransitionRenderer, HSTransitionRenderer, NSObject>
{
    id<HSOpenGLGraphicCompositionRenderer> _graphicCompositionRenderer;
}
- (id)frameTextureAtTime:(double)aTime;
- (void)renderFrameAtTime:(double)aTime;
- (void)setEndImage:(id)aImage;
- (void)setStartImage:(id)aImage;
- (id)openGLContext;
- (id)openGLPixelFormat;
- (void)dealloc;
- (id)initWithOpenGLGraphicCompositionRenderer:(id)aRenderer;
- (id)init;
@end

