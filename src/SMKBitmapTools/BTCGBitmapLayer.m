#import "BTCGBitmapLayer.h"
#import "BTMutableCGImageUndoer.h"

// A bitmap context edited in place. Its image shares the context's bytes
// (CGEBitmapContextCreateImageNoCopy) and is made again after each edit;
// while editing, images handed out are only valid until the edit ends.

@implementation BTCGBitmapLayer

+ (id)bitmapLayerWithCGContext:(struct CGContext *)aContext decode:(const CGFloat *)aDecode format:(NSInteger)aFormat colorProfile:(struct OpaqueCMProfileRef *)aProfile
{
    return [[[self alloc] initWithCGContext:aContext decode:aDecode format:aFormat colorProfile:aProfile] autorelease];
}

- (id)init
{
    [self release];
    return nil;
}

- (id)initWithCGContext:(struct CGContext *)aContext decode:(const CGFloat *)aDecode format:(NSInteger)aFormat colorProfile:(struct OpaqueCMProfileRef *)aProfile
{
    self = [super init];
    if (!self)
        return nil;
    if (aProfile)
        _imageColorProfile = (struct OpaqueCMProfileRef *)CFRetain(aProfile);
    if (aDecode) {
        _imageDecode = [[NSData alloc] initWithBytes:aDecode
                                              length:CGEBitmapContextGetNumberOfComponents(aContext) * 2 * sizeof(CGFloat)];
        if (!_imageDecode) {
            [self release];
            return nil;
        }
    }
    _bitmapContext = CGContextRetain(aContext);
    _imageFormat = (int)aFormat;
    return self;
}

- (void)dealloc
{
    CGImageRelease(_image);
    [_layerGraphicsContext release];
    if (_imageColorProfile)
        CFRelease(_imageColorProfile);
    [_imageDecode release];
    CGContextRelease(_bitmapContext);
    [super dealloc];
}

- (struct CGContext *)CGContext
{
    return _bitmapContext;
}

- (CGSize)imageSize
{
    return CGSizeMake(CGBitmapContextGetWidth(_bitmapContext), CGBitmapContextGetHeight(_bitmapContext));
}

- (struct CGPDFDocument *)coreGraphicsPDFDocument
{
    return NULL;
}

- (struct CGColorSpace *)coreGraphicsColorSpace
{
    return CGBitmapContextGetColorSpace(_bitmapContext);
}

- (struct CGImage *)coreGraphicsImage
{
    CGImageRef image = _image;
    if (!image) {
        image = CGEBitmapContextCreateImageNoCopy(_bitmapContext, [_imageDecode bytes], true,
                                                  kCGRenderingIntentDefault);
        if (!_isEditing)
            _image = image;
        else
            CFAutorelease(image);
    }
    return image;
}

- (struct CGColor *)colorAtPoint:(CGPoint)aPoint
{
    if (!BTIsImagePoint(self, aPoint))
        return NULL;
    CGColorRef color = BTCopyColorFromRawImage(self, aPoint);
    if (!color)
        color = BTCopyColorFromCGImage(self, aPoint);
    return (CGColorRef)CFAutorelease(color);
}

- (const void *)imageBytes
{
    return CGBitmapContextGetData(_bitmapContext);
}

- (NSUInteger)imageBytesPerRow
{
    return CGBitmapContextGetBytesPerRow(_bitmapContext);
}

- (NSInteger)imageFormat
{
    return _imageFormat;
}

- (struct OpaqueCMProfileRef *)imageColorProfile
{
    return _imageColorProfile;
}

- (const CGFloat *)imageDecode
{
    return [_imageDecode bytes];
}

- (void)drawInCGContext:(struct CGContext *)aContext inRect:(CGRect)aRect
{
    CGImageRef image = [self coreGraphicsImage];
    if (image)
        CGContextDrawImage(aContext, aRect, image);
}

- (void)drawInCGContext:(struct CGContext *)aContext atPoint:(CGPoint)aPoint
{
    CGSize size = [self imageSize];
    [self drawInCGContext:aContext inRect:CGRectMake(aPoint.x, aPoint.y, size.width, size.height)];
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
    CGImageRelease(_image);
    _image = NULL;
}

- (void)beginCGEditing
{
    [self prepareCGEditing];
    CGContextSaveGState(_bitmapContext);
}

- (struct CGContext *)imageCGContext
{
    return _bitmapContext;
}

- (void)endCGEditing
{
    CGContextRestoreGState(_bitmapContext);
    [self finalizeCGEditing];
}

- (void)finalizeCGEditing
{
    _isEditing = 0;
}

- (void)prepareCocoaEditing
{
    [self prepareCGEditing];
    _layerGraphicsContext = [[NSGraphicsContext graphicsContextWithCGContext:[self imageCGContext] flipped:NO] retain];
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
    [_layerGraphicsContext release];
    _layerGraphicsContext = nil;
    [self finalizeCGEditing];
}

- (void)beginRawEditing
{
    _isEditing = 1;
    CGImageRelease(_image);
    _image = NULL;
}

- (void *)mutableImageBytes
{
    return CGBitmapContextGetData(_bitmapContext);
}

- (void)endRawEditing
{
    _isEditing = 0;
}

@end
