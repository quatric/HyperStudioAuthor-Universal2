#import "HSImagePreviewView.h"

@interface NSObject (HSImagePreviewViewDelegate)
- (void)mouseDownAtPoint:(NSPoint)aPoint atColor:(NSColor *)aColor inView:(NSView *)aView;
@end

@implementation HSImagePreviewView

- (BOOL)resignFirstResponder
{
    return YES;
}

- (BOOL)becomeFirstResponder
{
    return YES;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)mouseDown:(id)aDown
{
    if (_image == nil || ![_delegate respondsToSelector:@selector(mouseDownAtPoint:atColor:inView:)])
        return;
    NSPoint location = [(NSEvent *)aDown locationInWindow];
    // Fix: NSCachedImageRep window grabbing is gone; sample the view's own rendering instead.
    NSPoint viewPoint = [self convertPoint:location fromView:nil];
    NSRect sampleRect = NSMakeRect(floor(viewPoint.x), floor(viewPoint.y), 1.0, 1.0);
    NSBitmapImageRep *cached = [self bitmapImageRepForCachingDisplayInRect:sampleRect];
    [self cacheDisplayInRect:sampleRect toBitmapImageRep:cached];
    NSBitmapImageRep *pixelRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:1 pixelsHigh:1 bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace bitmapFormat:0 bytesPerRow:0 bitsPerPixel:32];
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:pixelRep]];
    [cached drawInRect:NSMakeRect(0.0, 0.0, 1.0, 1.0)];
    [NSGraphicsContext restoreGraphicsState];
    NSUInteger pixel[4] = { 0, 0, 0, 0 };
    [pixelRep getPixel:pixel atX:0 y:0];
    NSColor *color = [NSColor colorWithDeviceRed:pixel[0] / 255.0f green:pixel[1] / 255.0f blue:pixel[2] / 255.0f alpha:pixel[3] / 255.0f];
    if ([_delegate respondsToSelector:@selector(mouseDownAtPoint:atColor:inView:)])
        [_delegate mouseDownAtPoint:[(NSEvent *)aDown locationInWindow] atColor:color inView:self];
    [pixelRep release];
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (void)setFlippedHorizontally:(BOOL)aHorizontally
{
    _isFlippedHorizontally = aHorizontally;
}

- (void)setFlippedVertically:(BOOL)aVertically
{
    _isFlippedVertically = aVertically;
}

- (void)setScaling:(NSInteger)aScaling
{
    _scaling = (int)aScaling;
    [self setNeedsDisplay:YES];
}

- (NSInteger)scaling
{
    return _scaling;
}

- (void)setImage:(id)aImage
{
    if (_image != aImage) {
        [_image release];
        _image = [aImage retain];
        [self setNeedsDisplay:YES];
    }
}

- (id)image
{
    return _image;
}

- (void)drawRect:(NSRect)aRect
{
    NSRect bounds = [self bounds];
    CGAffineTransform transform = CGAffineTransformIdentity;
    if (_isFlippedVertically)
        transform = CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, bounds.size.height + 2.0 * bounds.origin.y);
    if (_isFlippedHorizontally) {
        transform.a = -transform.a;
        transform.c = -transform.c;
        transform.tx = 2.0 * bounds.origin.x + bounds.size.width - transform.tx;
    }
    CGContextConcatCTM([[NSGraphicsContext currentContext] CGContext], transform);
    [_image hyperDrawInRect:bounds ofBounds:bounds withAlignment:0 scaling:_scaling];
}

- (void)dealloc
{
    [_image release];
    [super dealloc];
}

@end
