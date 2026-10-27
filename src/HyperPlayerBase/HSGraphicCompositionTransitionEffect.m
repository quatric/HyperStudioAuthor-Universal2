#import "HSGraphicCompositionTransitionEffect.h"
#import "HSGraphicComposition.h"

@implementation HSGraphicCompositionTransitionEffect

- (id)createQuartzRendererForSize:(CGSize)aSize
{
    id compositionRenderer = [_graphicComposition createQuartzRendererForSize:aSize];
    if (compositionRenderer == nil)
        return nil;
    id renderer = [[HSQuartzGraphicCompositionTransitionRenderer alloc] initWithQuartzGraphicCompositionRenderer:compositionRenderer];
    [compositionRenderer release];
    return renderer;
}

- (id)createOpenGLRendererForContext:(id)aContext pixelFormat:(id)aFormat
{
    id compositionRenderer = [_graphicComposition createOpenGLRendererForContext:aContext pixelFormat:aFormat];
    if (compositionRenderer == nil)
        return nil;
    id renderer = [[HSOpenGLGraphicCompositionTransitionRenderer alloc] initWithOpenGLGraphicCompositionRenderer:compositionRenderer];
    [compositionRenderer release];
    return renderer;
}

- (BOOL)hasOpenGLRenderer
{
    return [_graphicComposition hasOpenGLRenderer];
}

- (BOOL)hasQuartzRenderer
{
    return [_graphicComposition hasQuartzRenderer];
}

- (BOOL)isNewFrameAtTime:(double)aTime relativeToTime:(double)aTime2
{
    return aTime != aTime2;
}

- (BOOL)isSlow
{
    return [_graphicComposition isSlow];
}

- (NSUInteger)hash
{
    return [_graphicComposition hash];
}

- (BOOL)isEqual:(id)aEqual
{
    if (aEqual == self)
        return YES;
    if (![aEqual isKindOfClass:[HSGraphicCompositionTransitionEffect class]])
        return NO;
    // Let a more specific subclass decide.
    if (![aEqual isMemberOfClass:[self class]] && [aEqual isKindOfClass:[self class]])
        return [aEqual isEqual:self];
    return [_graphicComposition isEqual:[aEqual HSGraphicCompositionTransitionEffect_graphicComposition]];
}

- (id)HSGraphicCompositionTransitionEffect_graphicComposition
{
    return _graphicComposition;
}

- (void)dealloc
{
    [_graphicComposition release];
    [super dealloc];
}

- (id)initWithGraphicComposition:(id)aComposition
{
    self = [super init];
    if (self == nil)
        return nil;
    _graphicComposition = [aComposition retain];
    return self;
}

- (id)init
{
    [super release];
    return nil;
}

@end

@implementation HSQuartzGraphicCompositionTransitionRenderer

- (struct CGImage *)frameImageAtTime:(double)aTime
{
    return [_graphicCompositionRenderer frameImageAtTime:aTime];
}

- (void)renderFrameAtTime:(double)aTime inCoreGraphicsContext:(struct CGContext *)aContext
{
    [_graphicCompositionRenderer renderFrameAtTime:aTime inCoreGraphicsContext:aContext];
}

- (void)setEndImage:(id)aImage
{
    [_graphicCompositionRenderer setValue:aImage forInputKey:@"_protocolInput_DestinationImage"];
}

- (void)setStartImage:(id)aImage
{
    [_graphicCompositionRenderer setValue:aImage forInputKey:@"_protocolInput_SourceImage"];
}

- (void)setRendererSize:(CGSize)aSize
{
    [_graphicCompositionRenderer setRendererSize:aSize];
}

- (CGSize)rendererSize
{
    return [_graphicCompositionRenderer rendererSize];
}

- (void)dealloc
{
    [_graphicCompositionRenderer release];
    [super dealloc];
}

- (id)initWithQuartzGraphicCompositionRenderer:(id)aRenderer
{
    self = [super init];
    if (self == nil)
        return nil;
    _graphicCompositionRenderer = [aRenderer retain];
    return self;
}

- (id)init
{
    [super release];
    return nil;
}

@end

@implementation HSOpenGLGraphicCompositionTransitionRenderer

- (id)frameTextureAtTime:(double)aTime
{
    return [_graphicCompositionRenderer frameTextureAtTime:aTime];
}

- (void)renderFrameAtTime:(double)aTime
{
    [_graphicCompositionRenderer renderFrameAtTime:aTime];
}

- (void)setEndImage:(id)aImage
{
    [_graphicCompositionRenderer setValue:aImage forInputKey:@"_protocolInput_DestinationImage"];
}

- (void)setStartImage:(id)aImage
{
    [_graphicCompositionRenderer setValue:aImage forInputKey:@"_protocolInput_SourceImage"];
}

- (id)openGLContext
{
    return [_graphicCompositionRenderer openGLContext];
}

- (id)openGLPixelFormat
{
    return [_graphicCompositionRenderer openGLPixelFormat];
}

- (void)dealloc
{
    [_graphicCompositionRenderer release];
    [super dealloc];
}

- (id)initWithOpenGLGraphicCompositionRenderer:(id)aRenderer
{
    self = [super init];
    if (self == nil)
        return nil;
    _graphicCompositionRenderer = [aRenderer retain];
    return self;
}

- (id)init
{
    [super release];
    return nil;
}

@end
