#import "BTCGRawMutableImage.h"

// A mutable image whose bitmap bytes are also edited directly. The colour
// profile is a ColorSyncProfileRef now (CMProfileRef is gone).

@implementation BTCGRawMutableImage

- (id)initWithCGImage:(struct CGImage *)aImage context:(struct CGContext *)aContext
{
    [self release];
    return nil;
}

- (id)initWithCGImage:(struct CGImage *)aImage context:(struct CGContext *)aContext mutableBytes:(void *)aBytes format:(NSInteger)aFormat colorProfile:(struct OpaqueCMProfileRef *)aProfile
{
    self = [super initWithCGImage:aImage context:aContext];
    if (!self)
        return nil;
    if (aProfile)
        _imageColorProfile = (struct OpaqueCMProfileRef *)CFRetain(aProfile);
    _mutableImageBytes = aBytes;
    _imageFormat = (int)aFormat;
    return self;
}

- (void)dealloc
{
    if (_imageColorProfile)
        CFRelease(_imageColorProfile);
    [super dealloc];
}

- (const void *)imageBytes
{
    return _mutableImageBytes;
}

- (NSUInteger)imageBytesPerRow
{
    return CGImageGetBytesPerRow([self coreGraphicsImage]);
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
    return CGImageGetDecode([self coreGraphicsImage]);
}

// Raw images are undone by their owner.
- (id)createImageUndoerWithDelegate:(id)aDelegate
{
    return nil;
}

- (void)beginRawEditing
{
    [self prepareCGEditing];
}

- (void *)mutableImageBytes
{
    return _mutableImageBytes;
}

- (void)endRawEditing
{
    [self finalizeCGEditing];
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

@end
