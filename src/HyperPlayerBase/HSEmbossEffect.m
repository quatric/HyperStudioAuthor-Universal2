#import "HSEmbossEffect.h"
// Emboss: each pixel's brightness becomes the difference between its upper
// left and lower right neighbours (wrapping at the edges), mapped through a
// relief table; "colorize" keeps the pixel's own colour under the relief.
@implementation HSEmbossEffect
+ (id)effectDescriptionPlistName
{
    return @"EmbossEffect";
}
- (void)setRelief:(id)aRelief
{
    float relief = [aRelief floatValue];
    if (relief < _minReliefValue)
        aRelief = [NSNumber numberWithFloat:_minReliefValue];
    else if (relief > _maxReliefValue)
        aRelief = [NSNumber numberWithFloat:_maxReliefValue];
    [self setAttribute:aRelief forKey:HSEEReliefValueKey];
    [self HSEmbossEffect_prepareIntensityTableForRelief:[aRelief floatValue]];
}
- (void)HSEmbossEffect_prepareIntensityTableForRelief:(CGFloat)aRelief
{
    for (int i = 0; i < 256; i++)
        _intensityTable[i] = (short)lroundf(((float)(i + 1) / -255.0f + 0.5f) * (float)aRelief);
    _intensityTableInitialized = 1;
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
static void HSEmbossEffectReleasePixels(void *aInfo, const void *aData, size_t aSize)
{
    NSZoneFree(NULL, (void *)aData);
}
static UInt8 HSEmbossEffectComponent(float aValue, float aAlpha)
{
    float clamped = aValue < 0 ? 0 : fminf(aValue, 255.0f);
    float premultiplied = clamped * aAlpha;
    return premultiplied > 0 ? (UInt8)lroundf(ceilf(premultiplied)) : 0;
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

    // The input image as premultiplied ARGB, redrawn when the input changed.
    if (_shouldUpdateImagePixels || _inputImagePixels == NULL) {
        size_t size = height * rowBytes;
        void *pixels = _inputImagePixels;
        if (size > _inputImagePixelsSize) {
            if (pixels != NULL)
                NSZoneFree([self zone], pixels);
            pixels = NSZoneMalloc([self zone], size);
            _inputImagePixels = pixels;
            _inputImagePixelsSize = pixels != NULL ? (unsigned int)size : 0;
        }
        CGColorSpaceRef space;
        if (pixels != NULL && (space = CGColorSpaceCreateDeviceRGB()) != NULL) {
            CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, rowBytes, space, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
            CGColorSpaceRelease(space);
            if (context != NULL) {
                [self copyCocoaImage:_inputImage toCGBitmapContext:context];
                CGContextRelease(context);
                _shouldUpdateImagePixels = 0;
            }
        }
    }
    if (_inputImagePixels == NULL)
        return NULL;
    UInt8 *output = NSZoneMalloc(NULL, _inputImagePixelsSize);
    if (output == NULL)
        return NULL;
    if (!_intensityTableInitialized)
        [self HSEmbossEffect_prepareIntensityTableForRelief:400.0];
    BOOL colorize = [[self valueForKey:HSEEColorizeFlagKey] boolValue];

    const UInt8 *input = _inputImagePixels;
    for (size_t y = 0; y < height; y++) {
        const UInt8 *row = input + y * rowBytes;
        const UInt8 *above = y == 0 ? input + (height - 1) * rowBytes : row - rowBytes;
        const UInt8 *below = y == height - 1 ? input : row + rowBytes;
        UInt8 *out = output + y * rowBytes;
        for (size_t x = 0; x < width; x++) {
            const UInt8 *upperLeft = above + (x == 0 ? width - 1 : x - 1) * 4;
            const UInt8 *lowerRight = below + (x == width - 1 ? 0 : x + 1) * 4;
            int difference = ((upperLeft[1] + upperLeft[2] + upperLeft[3]) - lowerRight[1] - lowerRight[2] - lowerRight[3]) / 3 + 128;
            int index = difference < 0 ? 0 : (difference < 256 ? difference : 255);
            const UInt8 *pixel = row + x * 4;
            UInt8 *result = out + x * 4;
            result[0] = pixel[0];
            if (pixel[0] == 0) {
                memset(result, 0, 4);
                continue;
            }
            float alpha = pixel[0] / 255.0f;
            float relief = _intensityTable[index];
            if (!colorize) {
                UInt8 gray = HSEmbossEffectComponent(relief + (float)(pixel[1] + pixel[2] + pixel[3]) / (alpha * 3.0f), alpha);
                result[1] = result[2] = result[3] = gray;
            } else {
                for (int c = 1; c < 4; c++)
                    result[c] = HSEmbossEffectComponent(relief + pixel[c] / alpha, alpha);
            }
        }
    }

    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, output, _inputImagePixelsSize, HSEmbossEffectReleasePixels);
    if (provider == NULL) {
        NSZoneFree(NULL, output);
        return _outputCGImage;
    }
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    if (space != NULL) {
        _outputCGImage = CGImageCreate(width, height, 8, 32, rowBytes, space, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst, provider, NULL, false, kCGRenderingIntentDefault);
        CGColorSpaceRelease(space);
    }
    CGDataProviderRelease(provider);
    return _outputCGImage;
}
- (id)attributes
{
    return _effectDescription;
}
- (void)setAttribute:(id)aAttribute forKey:(id)aKey
{
    [super setAttribute:aAttribute forKey:aKey];
    CGImageRelease(_outputCGImage);
    _outputCGImage = NULL;
    [_outputImage release];
    _outputImage = nil;
}
- (void)updateInputImageRelatedInfo
{
    if (_inputImage == nil) {
        _imageRect = CGRectZero;
        return;
    }
    NSSize size = [[_inputImage bestRepresentationForDevice:nil] size];
    _imageRect = CGRectIntegral(CGRectMake(0, 0, size.width, size.height));
    if (!CGRectIsEmpty(_imageRect)) {
        [_outputImage release];
        _outputImage = nil;
        CGImageRelease(_outputCGImage);
        _outputCGImage = NULL;
        _shouldUpdateImagePixels = 1;
    }
}
- (void)dealloc
{
    [_effectDescription release];
    CGImageRelease(_outputCGImage);
    if (_inputImagePixels != NULL)
        NSZoneFree([self zone], _inputImagePixels);
    [super dealloc];
}
- (id)initWithName:(id)aName
{
    self = [super init];
    if (self != nil) {
        _effectDescription = [[[[self class] effectsDescription] objectForKey:aName] retain];
        if (_effectDescription != nil) {
            NSDictionary *relief = [[self attributes] objectForKey:HSEEReliefValueKey];
            _minReliefValue = [[relief objectForKey:HSAttributeMin] floatValue];
            _maxReliefValue = [[relief objectForKey:HSAttributeMax] floatValue];
            [super setDefaults];
            return self;
        }
    }
    [self release];
    return nil;
}
@end
