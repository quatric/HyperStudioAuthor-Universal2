#import "BTCGMutableImage.h"
#import "BTMutableCGImageUndoer.h"

// A CGImage and the bitmap context it was made from. Edits go to the
// context; the image is re-copied from it the first time it is asked for
// after editing began, and again on each request while editing.

@implementation BTCGMutableImage

- (id)init
{
    [self release];
    return nil;
}

- (id)initWithCGImage:(struct CGImage *)aImage context:(struct CGContext *)aContext
{
    self = [super init];
    if (!self)
        return nil;
    _image = CGImageRetain(aImage);
    _imageContext = CGContextRetain(aContext);
    _isImageValid = 1;
    return self;
}

- (void)dealloc
{
    [_layerGraphicsContext release];
    CGContextRelease(_imageContext);
    CGImageRelease(_image);
    [super dealloc];
}

- (CGSize)imageSize
{
    return CGSizeMake(CGImageGetWidth(_image), CGImageGetHeight(_image));
}

- (struct CGPDFDocument *)coreGraphicsPDFDocument
{
    return NULL;
}

- (struct CGColorSpace *)coreGraphicsColorSpace
{
    return CGImageGetColorSpace(_image);
}

- (struct CGImage *)coreGraphicsImage
{
    if (!_isImageValid) {
        CGImageRef copy = CGImageCreateCopy(_image);
        CGImageRelease(_image);
        _image = copy;
        _isImageValid = !_isEditing;
    }
    return _image;
}

- (struct CGColor *)colorAtPoint:(CGPoint)aPoint
{
    if (!BTIsImagePoint(self, aPoint))
        return NULL;
    return (CGColorRef)CFAutorelease(BTCopyColorFromCGImage(self, aPoint));
}

- (void)drawInCGContext:(struct CGContext *)aContext inRect:(CGRect)aRect
{
    CGContextDrawImage(aContext, aRect, [self coreGraphicsImage]);
}

- (void)drawInCGContext:(struct CGContext *)aContext atPoint:(CGPoint)aPoint
{
    CGImageRef image = [self coreGraphicsImage];
    CGSize size = [self imageSize];
    CGContextDrawImage(aContext, CGRectMake(aPoint.x, aPoint.y, size.width, size.height), image);
}

- (void)drawInCurrentNSGraphicsContextInRect:(NSRect)aRect
{
    [self drawInCGContext:[[NSGraphicsContext currentContext] CGContext] inRect:NSRectToCGRect(aRect)];
}

- (void)drawInCurrentNSGraphicsContextAtPoint:(NSPoint)aPoint
{
    [self drawInCGContext:[[NSGraphicsContext currentContext] CGContext] atPoint:NSPointToCGPoint(aPoint)];
}

- (id)createImageUndoerWithDelegate:(id)aDelegate
{
    return [[BTMutableCGImageUndoer allocWithZone:[self zone]] initWithImage:self delegate:aDelegate];
}

- (void)prepareCGEditing
{
    _isEditing = 1;
    _isImageValid = 0;
}

- (void)beginCGEditing
{
    [self prepareCGEditing];
    CGContextSaveGState(_imageContext);
}

- (struct CGContext *)imageCGContext
{
    return _imageContext;
}

- (void)endCGEditing
{
    CGContextRestoreGState(_imageContext);
    [self finalizeCGEditing];
}

- (void)finalizeCGEditing
{
    _isEditing = 0;
}

- (void)prepareCocoaEditing
{
    [self prepareCGEditing];
    if (!_layerGraphicsContext)
        _layerGraphicsContext = [[NSGraphicsContext graphicsContextWithCGContext:_imageContext flipped:NO] retain];
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:_layerGraphicsContext];
}

- (void)beginCocoaEditing
{
    [self prepareCocoaEditing];
    [_layerGraphicsContext saveGraphicsState];
}

- (void)endCocoaEditing
{
    [_layerGraphicsContext restoreGraphicsState];
    [self finalizeCocoaEditing];
}

- (void)finalizeCocoaEditing
{
    [NSGraphicsContext restoreGraphicsState];
    [self finalizeCGEditing];
}

@end
