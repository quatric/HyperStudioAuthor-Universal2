#import "HSGWorldCGImageWrapper.h"
static void HSGWorldCGImageWrapperReleaseData(void *aInfo, const void *aData, size_t aSize)
{
    free((void *)aData);
}
@implementation HSGWorldCGImageWrapper
+ (id)gWorldCGImageWithSize:(NSSize)aSize
{
    return [[[self alloc] initWithSize:aSize] autorelease];
}
- (void)clear
{
    memset(_gWorldData, 0, _gWorldDataSize);
}
- (struct CGImage *)cgImage
{
    return _cgImage;
}
// QuickDraw is gone: there is no GWorld over the pixels any more (NULL).
- (struct OpaqueGrafPtr *)gWorld
{
    return _gWorld;
}
- (void)dealloc
{
    if (_cgImage != NULL)
        CGImageRelease(_cgImage);
    [super dealloc];
}
// A 32-bit ARGB (premultiplied, big-endian) pixel buffer, rows 16-byte
// aligned, shown as a CGImage that reads it live. The original also wrapped
// it in a GWorld (QTNewGWorldFromPtr, k32ARGBPixelFormat) for QuickTime and
// QuickDraw drawing; nothing can draw through one now.
- (id)initWithSize:(NSSize)aSize
{
    self = [super init];
    if (self == nil)
        return nil;
    int height = (int)ceilf(aSize.height);
    int width = (int)ceilf(aSize.width);
    size_t rowBytes = ((width * 32 + 7) / 8 + 15) & ~(size_t)15;
    _gWorldDataSize = (int)(height * rowBytes);
    _gWorldData = malloc(_gWorldDataSize);
    memset(_gWorldData, 0, _gWorldDataSize);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace != NULL) {
        CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, _gWorldData, _gWorldDataSize, HSGWorldCGImageWrapperReleaseData);
        if (provider != NULL) {
            _cgImage = CGImageCreate((size_t)aSize.width, (size_t)aSize.height, 8, 32, rowBytes, colorSpace,
                                     kCGImageAlphaPremultipliedFirst, provider, NULL, false, kCGRenderingIntentDefault);
            CGDataProviderRelease(provider);
        } else
            free(_gWorldData);
        CGColorSpaceRelease(colorSpace);
    } else
        free(_gWorldData);
    if (_cgImage == NULL) {
        [self release];
        return nil;
    }
    return self;
}
@end
