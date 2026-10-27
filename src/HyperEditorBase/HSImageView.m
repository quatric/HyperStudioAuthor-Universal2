#import "HSImageView.h"

@implementation HSImageView

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

// The image stretched over the bounds.
- (void)drawRect:(NSRect)aRect
{
    NSRect imageRect = { NSZeroPoint, [_image size] };
    NSAffineTransform *transform = [NSAffineTransform hyperTransitionFromRect:[self bounds] toRect:imageRect];
    [_image drawInRect:aRect fromRect:[transform hyperTransformAndBoundRect:aRect] operation:NSCompositingOperationSourceOver fraction:1];
}

- (void)dealloc
{
    [_image release];
    [super dealloc];
}

@end
