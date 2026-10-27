#import "HSTexturizerEffect.h"
// Texturizer: lights the image through an embossed grey texture tiled over
// it. The texture (scaled) is drawn into the second half of the mask
// buffer, and one of eight directional emboss kernels writes the relief
// into the first half; a relief table maps it to a brightness offset added
// to each (unpremultiplied) colour component.

// Emboss kernels 1-8 (3×3, row by row): the opposite corners or edges.
static const float HSTexturizerEmbossKernels[8][9] = {
    { 1, 0, 0, 0, 0, 0, 0, 0, -1 },
    { 0, 1, 0, 0, 0, 0, 0, -1, 0 },
    { 0, 0, 1, 0, 0, 0, -1, 0, 0 },
    { 0, 0, 0, 1, 0, -1, 0, 0, 0 },
    { -1, 0, 0, 0, 0, 0, 0, 0, 1 },
    { 0, -1, 0, 0, 0, 0, 0, 1, 0 },
    { 0, 0, -1, 0, 0, 0, 1, 0, 0 },
    { 0, 0, 0, -1, 0, 1, 0, 0, 0 },
};

// Any positive sum becomes 255; the rest is offset by the bias and
// truncated to a byte, as in the original.
static inline uint8_t HSTexturizerEmbossValue(float aSum, unsigned short aBias)
{
    return aSum > 0 ? 0xff : (uint8_t)(lroundf(aSum) + aBias);
}

// Kernels 1 and 5: upper left and lower right neighbours (wrapping).
static void HSTexturizerEmbossDiagonal(uint8_t *aDestination, const uint8_t *aSource, size_t aWidth, size_t aHeight, size_t aRowBytes, const float *aKernel, unsigned short aBias)
{
    for (size_t y = 0; y < aHeight; y++) {
        size_t up = y == 0 ? aHeight - 1 : y - 1;
        size_t down = y == aHeight - 1 ? 0 : y + 1;
        uint8_t *destination = aDestination + y * aRowBytes;
        for (size_t x = 0; x < aWidth; x++) {
            size_t left = x == 0 ? aWidth - 1 : x - 1;
            size_t right = x == aWidth - 1 ? 0 : x + 1;
            float sum = aKernel[8] * (float)aSource[down * aRowBytes + right] + (float)aSource[up * aRowBytes + left] * aKernel[0];
            destination[x] = HSTexturizerEmbossValue(sum, aBias);
        }
    }
}

// Kernels 2 and 6: the neighbours above and below.
static void HSTexturizerEmbossVertical(uint8_t *aDestination, const uint8_t *aSource, size_t aWidth, size_t aHeight, size_t aRowBytes, const float *aKernel, unsigned short aBias)
{
    for (size_t y = 0; y < aHeight; y++) {
        size_t up = y == 0 ? aHeight - 1 : y - 1;
        size_t down = y == aHeight - 1 ? 0 : y + 1;
        uint8_t *destination = aDestination + y * aRowBytes;
        for (size_t x = 0; x < aWidth; x++) {
            float sum = (float)aSource[up * aRowBytes + x] * aKernel[1] + (float)aSource[down * aRowBytes + x] * aKernel[7];
            destination[x] = HSTexturizerEmbossValue(sum, aBias);
        }
    }
}

// Kernels 3 and 7: upper right and lower left. The original takes the
// "lower" pixel from the same row (the row above on the last one): kept.
static void HSTexturizerEmbossAntidiagonal(uint8_t *aDestination, const uint8_t *aSource, size_t aWidth, size_t aHeight, size_t aRowBytes, const float *aKernel, unsigned short aBias)
{
    for (size_t y = 0; y < aHeight; y++) {
        size_t up = y == 0 ? aHeight - 1 : y - 1;
        size_t lower = y == aHeight - 1 ? y - 1 : y;
        uint8_t *destination = aDestination + y * aRowBytes;
        for (size_t x = 0; x < aWidth; x++) {
            size_t left = x == 0 ? aWidth - 1 : x - 1;
            size_t right = x == aWidth - 1 ? 0 : x + 1;
            float sum = aKernel[2] * (float)aSource[up * aRowBytes + right] + (float)aSource[lower * aRowBytes + left] * aKernel[6];
            destination[x] = HSTexturizerEmbossValue(sum, aBias);
        }
    }
}

// Kernels 4 and 8: the left and right neighbours.
static void HSTexturizerEmbossHorizontal(uint8_t *aDestination, const uint8_t *aSource, size_t aWidth, size_t aHeight, size_t aRowBytes, const float *aKernel, unsigned short aBias)
{
    for (size_t y = 0; y < aHeight; y++) {
        const uint8_t *source = aSource + y * aRowBytes;
        uint8_t *destination = aDestination + y * aRowBytes;
        for (size_t x = 0; x < aWidth; x++) {
            size_t left = x == 0 ? aWidth - 1 : x - 1;
            size_t right = x == aWidth - 1 ? 0 : x + 1;
            float sum = aKernel[5] * (float)source[right] + (float)source[left] * aKernel[3];
            destination[x] = HSTexturizerEmbossValue(sum, aBias);
        }
    }
}

typedef void (*HSTexturizerEmbossFunction)(uint8_t *, const uint8_t *, size_t, size_t, size_t, const float *, unsigned short);

static const HSTexturizerEmbossFunction HSTexturizerEmbossFunctions[8] = {
    HSTexturizerEmbossDiagonal, HSTexturizerEmbossVertical, HSTexturizerEmbossAntidiagonal, HSTexturizerEmbossHorizontal,
    HSTexturizerEmbossDiagonal, HSTexturizerEmbossVertical, HSTexturizerEmbossAntidiagonal, HSTexturizerEmbossHorizontal,
};

static void HSTexturizerEffectReleasePixels(void *aInfo, const void *aData, size_t aSize)
{
    NSZoneFree(NULL, (void *)aData);
}

// One premultiplied component: the unpremultiplied value plus the relief
// offset, clamped, premultiplied again (rounded up).
static uint8_t HSTexturizerComponent(uint8_t aValue, float aAlpha, int aOffset)
{
    float value = (float)aValue / aAlpha + (float)aOffset;
    if (value <= 0)
        value = 0;
    float clamped = value <= 255.0f ? value : 255.0f;
    float premultiplied = clamped * aAlpha;
    return premultiplied > 0 ? (uint8_t)lroundf(ceilf(premultiplied)) : 0;
}

@implementation HSTexturizerEffect
+ (id)effectDescriptionPlistName
{
    return @"TexturizerEffect";
}
- (void)HSTexturizerEffect_prepareMaskImageOffscreenData
{
    if (_textureImage == nil) {
        NSString *name = [[self effectAttributes] objectForKey:HSTETextureImageKey];
        _textureImage = [[self loadImageWithName:[name stringByDeletingPathExtension] extension:[name pathExtension]] retain];
        if (_textureImage == nil)
            return;
        _shouldUpdateTexturePixels = 1;
    }
    NSSize textureSize = [[_textureImage bestRepresentationForDevice:nil] size];
    NSRect textureRect = NSIntegralRect(NSMakeRect(0, 0, textureSize.width, textureSize.height));
    if (NSIsEmptyRect(textureRect))
        return;
    if (_shouldUpdateTexturePixels || _maskImagePixels == NULL) {
        float scale = [[[self effectAttributes] objectForKey:HSTEScaleKey] doubleValue];
        float width = (float)textureRect.size.width * scale;
        float height = (float)textureRect.size.height * scale;
        _maskPixelsWidth = width > 0 ? (unsigned int)lroundf(ceilf(width)) : 0;
        _maskPixelsHeight = height > 0 ? (unsigned int)lroundf(ceilf(height)) : 0;
        _maskPixelsBytesPerRow = (_maskPixelsWidth + 4) & ~3u;
        unsigned int size = _maskPixelsBytesPerRow * _maskPixelsHeight;
        if (size > _maskImagePixelsSize) {
            if (_maskImagePixels != NULL)
                NSZoneFree([self zone], _maskImagePixels);
            // Relief in the first half, the scaled texture in the second.
            _maskImagePixels = NSZoneMalloc([self zone], size * 2);
            _maskImagePixelsSize = _maskImagePixels != NULL ? size : 0;
        }
        if (_maskImagePixels != NULL) {
            CGColorSpaceRef gray = CGColorSpaceCreateDeviceGray();
            if (gray != NULL) {
                CGContextRef context = CGBitmapContextCreate((uint8_t *)_maskImagePixels + _maskImagePixelsSize, _maskPixelsWidth, _maskPixelsHeight, 8, _maskPixelsBytesPerRow, gray, (CGBitmapInfo)kCGImageAlphaNone);
                CGColorSpaceRelease(gray);
                if (context != NULL) {
                    [self copyCocoaImage:_textureImage toCGBitmapContext:context];
                    CGContextRelease(context);
                    _shouldUpdateTexturePixels = 0;
                    _shouldUpdateMaskPixels = 1;
                }
            }
        }
    }
    if (_maskImagePixels != NULL && _shouldUpdateMaskPixels) {
        unsigned int emboss = [[[self effectAttributes] objectForKey:HSTEEmbossKey] unsignedIntValue];
        uint8_t *relief = _maskImagePixels;
        const uint8_t *texture = relief + _maskImagePixelsSize;
        if (emboss - 1 < 8)
            HSTexturizerEmbossFunctions[emboss - 1](relief, texture, _maskPixelsWidth, _maskPixelsHeight, _maskPixelsBytesPerRow, HSTexturizerEmbossKernels[emboss - 1], 0x80);
        else
            // (The original left the relief half uninitialized without an
            // emboss direction.)
            memcpy(relief, texture, _maskImagePixelsSize);
        _shouldUpdateMaskPixels = 0;
    }
}
- (void)HSTexturizerEffect_prepareInputImagePixelsForWidth:(NSUInteger)aWidth height:(NSUInteger)aHeight bytesPerRow:(NSUInteger)aRow
{
    if (!_shouldUpdateImagePixels)
        return;
    unsigned int size = (unsigned int)(aRow * aHeight);
    void *pixels = _inputImagePixels;
    if (size > _inputImagePixelsSize) {
        if (pixels != NULL)
            NSZoneFree([self zone], pixels);
        pixels = NSZoneMalloc([self zone], size);
        _inputImagePixels = pixels;
        _inputImagePixelsSize = pixels != NULL ? size : 0;
    }
    if (pixels == NULL)
        return;
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    if (rgb == NULL)
        return;
    CGContextRef context = CGBitmapContextCreate(_inputImagePixels, aWidth, aHeight, 8, aRow, rgb, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(rgb);
    if (context != NULL) {
        [self copyCocoaImage:_inputImage toCGBitmapContext:context];
        CGContextRelease(context);
        _shouldUpdateImagePixels = 0;
    }
}
// The relief table: a cubic curve around 128 whose steepness grows with the
// relief (0…1), reversed unless inverted, normalised by twice its middle
// value. The curve is computed in 16 bits and truncated like the
// original's shorts; a zero middle copies the raw bytes of the first half.
- (void)HSTexturizerEffect_prepareIntensityTable
{
    if (!_shouldUpdateIntensityTable && _intensityTableInitialized)
        return;
    double relief = [[[self effectAttributes] objectForKey:HSTEReliefKey] doubleValue];
    BOOL inverted = [[[self effectAttributes] objectForKey:HSTEInversionFlagKey] boolValue];
    short curve[256];
    int step = inverted ? 1 : -1;
    short *entry = inverted ? curve : curve + 255;
    double strength = fmin(1.0, fmax(0.0, fabs(relief)));
    for (int i = 0; i < 256; i++) {
        double value = pow(((double)i - 128.0) / (2550.0 / (strength * 68.0 + 31.9)), 3.0);
        *entry = (short)lround(((value + 128.0 + 1.0) * 65535.0) / 255.0);
        entry += step;
    }
    double middle = (double)curve[127] + (double)curve[127];
    if (middle == 0)
        memcpy(_intensityTable, curve, sizeof(_intensityTable));
    else
        for (int i = 0; i < 256; i++)
            _intensityTable[i] = (signed char)lround(((double)curve[i] / middle) * -255.0 + 128.0);
    _intensityTableInitialized = 1;
    _shouldUpdateIntensityTable = 0;
}
- (void)setInvertMask:(id)aMask
{
    [self setAttribute:aMask forKey:HSTEInversionFlagKey];
    _shouldUpdateIntensityTable = 1;
}
- (void)setScale:(id)aScale
{
    [self setAttribute:aScale forKey:HSTEScaleKey];
    _shouldUpdateTexturePixels = 1;
}
- (void)setRelief:(id)aRelief
{
    [self setAttribute:aRelief forKey:HSTEReliefKey];
    _shouldUpdateIntensityTable = 1;
}
- (void)setEmboss:(id)aEmboss
{
    [self setAttribute:aEmboss forKey:HSTEEmbossKey];
    _shouldUpdateMaskPixels = 1;
}
- (void)setTextureImage:(id)aImage
{
    if (_textureImage == aImage)
        return;
    [_textureImage release];
    _textureImage = [aImage retain];
    CGImageRelease(_outputCGImage);
    _outputCGImage = NULL;
    [_outputImage release];
    _outputImage = nil;
    _shouldUpdateTexturePixels = 1;
}
- (id)outputImage
{
    if (_outputImage == nil) {
        CGImageRef image = [self outputCGImage];
        if (image == NULL)
            return nil;
        _outputImage = [[NSImage hyperImageWithCGImage:image] retain];
    }
    return _outputImage;
}
- (struct CGImage *)outputCGImage
{
    if (CGRectIsEmpty(_imageRect))
        return NULL;
    if (_outputCGImage != NULL)
        return _outputCGImage;
    size_t width = _imageRect.size.width > 0 ? lroundf(ceilf(_imageRect.size.width)) : 0;
    size_t height = _imageRect.size.height > 0 ? lroundf(ceilf(_imageRect.size.height)) : 0;
    size_t rowBytes = (width * 4 + 15) & ~(size_t)15;
    [self HSTexturizerEffect_prepareInputImagePixelsForWidth:width height:height bytesPerRow:rowBytes];
    [self HSTexturizerEffect_prepareMaskImageOffscreenData];
    // (A texture scaled to nothing would divide by zero below.)
    if (_inputImagePixels == NULL || _maskImagePixels == NULL || _maskPixelsWidth == 0 || _maskPixelsHeight == 0)
        return _outputCGImage;
    [self HSTexturizerEffect_prepareIntensityTable];
    uint8_t *output = NSZoneMalloc(NULL, height * rowBytes);
    if (output == NULL)
        return _outputCGImage;
    const uint8_t *relief = _maskImagePixels;
    for (size_t y = 0; y < height; y++) {
        const uint8_t *source = (const uint8_t *)_inputImagePixels + y * rowBytes;
        uint8_t *destination = output + y * rowBytes;
        const uint8_t *reliefRow = relief + (y % _maskPixelsHeight) * _maskPixelsBytesPerRow;
        for (size_t x = 0; x < width; x++, source += 4, destination += 4) {
            // ARGB, premultiplied.
            if (source[0] == 0) {
                memset(destination, 0, 4);
                continue;
            }
            int offset = _intensityTable[reliefRow[x % _maskPixelsWidth]];
            float alpha = (float)source[0] / 255.0f;
            destination[1] = HSTexturizerComponent(source[1], alpha, offset);
            destination[2] = HSTexturizerComponent(source[2], alpha, offset);
            destination[3] = HSTexturizerComponent(source[3], alpha, offset);
            destination[0] = source[0];
        }
    }
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, output, height * rowBytes, HSTexturizerEffectReleasePixels);
    if (provider == NULL) {
        NSZoneFree(NULL, output);
        return _outputCGImage;
    }
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    if (rgb != NULL) {
        _outputCGImage = CGImageCreate(width, height, 8, 32, rowBytes, rgb, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst, provider, NULL, false, kCGRenderingIntentDefault);
        CGColorSpaceRelease(rgb);
    }
    CGDataProviderRelease(provider);
    return _outputCGImage;
}
- (id)attributes
{
    return _effectDescription;
}
- (void)updateInputImageRelatedInfo
{
    if (_inputImage == nil) {
        _imageRect = CGRectZero;
        return;
    }
    NSSize size = [[_inputImage bestRepresentationForDevice:nil] size];
    _imageRect = CGRectIntegral(CGRectMake(0, 0, size.width, size.height));
    if (CGRectIsEmpty(_imageRect))
        return;
    [_outputImage release];
    _outputImage = nil;
    CGImageRelease(_outputCGImage);
    _outputCGImage = NULL;
    _shouldUpdateImagePixels = 1;
}
- (void)setAttribute:(id)aAttribute forKey:(id)aKey
{
    [super setAttribute:aAttribute forKey:aKey];
    [_outputImage release];
    _outputImage = nil;
    CGImageRelease(_outputCGImage);
    _outputCGImage = NULL;
}
- (void)dealloc
{
    [_textureImage release];
    [_effectDescription release];
    NSZone *zone = [self zone];
    if (_inputImagePixels != NULL)
        NSZoneFree(zone, _inputImagePixels);
    if (_maskImagePixels != NULL)
        NSZoneFree(zone, _maskImagePixels);
    CGImageRelease(_outputCGImage);
    [super dealloc];
}
- (id)initWithName:(id)aName
{
    self = [super init];
    if (self == nil)
        return nil;
    _effectDescription = [[[[self class] effectsDescription] objectForKey:aName] retain];
    if (_effectDescription == nil) {
        [self release];
        return nil;
    }
    [self setDefaults];
    return self;
}
@end
