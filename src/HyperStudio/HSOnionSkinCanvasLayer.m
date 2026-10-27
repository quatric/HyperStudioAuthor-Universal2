#import "HSOnionSkinCanvasLayer.h"

@implementation HSOnionSkinCanvasLayer

- (void)willResignActiveLayer
{
}

- (void)didBecomeActiveLayer
{
}

// Draws the image at 20% opacity, flipped into the rendering view's user space.
- (void)renderRect:(NSRect)aRect
{
    CGContextRef context;
    CGAffineTransform transform;
    CGFloat width, height;

    if (_image == NULL)
        return;
    context = [[NSGraphicsContext currentContext] CGContext];
    [NSGraphicsContext saveGraphicsState];
    width = CGImageGetWidth(_image);
    height = CGImageGetHeight(_image);
    transform = [[[self context] renderingView] userSpaceToViewSpaceCGAffineTransform];
    CGContextConcatCTM(context, CGAffineTransformConcat(CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, height), transform));
    CGContextSetAlpha(context, 0.2f);
    CGContextDrawImage(context, CGRectMake(0.0, 0.0, width, height), _image);
    [NSGraphicsContext restoreGraphicsState];
}

- (void)invalidateDisplay
{
    [[[self context] renderingView] setNeedsDisplayOpenGLSurface:YES];
}

- (void)dealloc
{
    CGImageRelease(_image);
    [super dealloc];
}

- (void)setCGImage:(struct CGImage *)aImage
{
    CGImageRef image = CGImageRetain(aImage);

    // Fix: the previous image was leaked.
    CGImageRelease(_image);
    _image = image;
    [self invalidateDisplay];
}

@end
