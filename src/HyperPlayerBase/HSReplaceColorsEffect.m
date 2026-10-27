#import "HSReplaceColorsEffect.h"
// Replace colors: the pixels near the source color become the target color;
// with "ExchangeColors" the pixels near the target color also become the
// source color (a pixel near both takes the color it is further from).
// Nearness is a distance in lightness, chroma and hue (as 0…1 fractions),
// within the "ToleranceValue" (plus half a step); "IgnoreAlpha" leaves alpha
// out of it.
@implementation HSReplaceColorsEffect
// A color as the comparison needs it. (The original keeps premultiplied
// components in the target's unused component bytes.)
typedef struct {
    UInt8 alpha, red, green, blue;
    float hue, chroma, lightness;
    UInt32 premultiplied; // as a pixel: A, R, G, B bytes
} HSReplaceColorsInfo;

// The hue (0…1), chroma and lightness of a color.
static float HSReplaceColorsHue(float aRed, float aGreen, float aBlue, float *aChroma, float *aLightness)
{
    float max = aGreen, min = aRed;
    if (aGreen <= aRed) {
        max = aRed;
        min = aGreen;
    }
    if (aBlue > max)
        max = aBlue;
    else if (aBlue < min)
        min = aBlue;
    float chroma = max - min, hue = 0;
    if (chroma > 0) {
        if (max == aRed) {
            hue = (aGreen - aBlue) / chroma;
            if (hue < 0)
                hue += 6;
        } else if (max == aGreen) {
            hue = (aBlue - aRed) / chroma + 2;
        } else if (max == aBlue) {
            hue = (aRed - aGreen) / chroma + 4;
        }
        hue /= 6;
    }
    *aChroma = chroma;
    *aLightness = (max + min) * 0.5f;
    return hue;
}
static HSReplaceColorsInfo HSReplaceColorsInfoForColor(NSColor *aColor)
{
    float alpha = [aColor alphaComponent], red = [aColor redComponent], green = [aColor greenComponent], blue = [aColor blueComponent];
    HSReplaceColorsInfo info;
    info.alpha = (UInt8)lroundf(alpha * 255.0f);
    info.red = (UInt8)lroundf(red * 255.0f);
    info.green = (UInt8)lroundf(green * 255.0f);
    info.blue = (UInt8)lroundf(blue * 255.0f);
    UInt8 premultiplied[4] = {info.alpha, (UInt8)lroundf(red * alpha * 255.0f), (UInt8)lroundf(green * alpha * 255.0f), (UInt8)lroundf(blue * alpha * 255.0f)};
    memcpy(&info.premultiplied, premultiplied, 4);
    info.hue = HSReplaceColorsHue(red, green, blue, &info.chroma, &info.lightness);
    return info;
}
// Whether a premultiplied ARGB pixel is near the color, and how near. A
// transparent pixel is near a color as transparent as the tolerance; a
// transparent color matches any pixel whose alpha is near enough. The hue
// difference counts up to 1/6, weighted by both chromas.
static BOOL HSReplaceColorsMatches(const UInt8 *aPixel, const HSReplaceColorsInfo *aColor, double aTolerance, BOOL aIgnoreAlpha, float *aDistance)
{
    const double halfStep = 1.0 / 510;
    if (aTolerance >= 1 - halfStep)
        return YES;
    UInt32 pixel;
    memcpy(&pixel, aPixel, 4);
    if (pixel == aColor->premultiplied)
        return YES;
    UInt8 alpha = aPixel[0];
    if (alpha == 0) {
        if (aIgnoreAlpha || aColor->alpha == 0)
            return YES;
        return (double)(float)(aColor->alpha / 255.0) <= aTolerance;
    }
    if (aTolerance <= halfStep)
        return NO;
    if (!aIgnoreAlpha) {
        if ((double)fabsf(((float)alpha - (float)aColor->alpha) / 255.0f) > aTolerance + halfStep)
            return NO;
        if (aColor->alpha == 0)
            return YES;
    }
    float chroma, lightness;
    float hue = HSReplaceColorsHue(aPixel[1] / (float)alpha, aPixel[2] / (float)alpha, aPixel[3] / (float)alpha, &chroma, &lightness);
    double chromaDifference = (double)(chroma - aColor->chroma);
    double lightnessDifference = (double)(lightness - aColor->lightness);
    double hueTerm = 0;
    if ((double)chroma > halfStep && (double)aColor->chroma > halfStep) {
        double hueDifference = fabsf(hue - aColor->hue);
        if (hueDifference > 1.0 / 6)
            hueDifference = hueDifference > 5.0 / 6 ? 1 - hueDifference : 1.0 / 6;
        hueTerm = (double)chroma * 36.0 * (double)aColor->chroma * hueDifference * hueDifference;
    }
    double distance = sqrt(lightnessDifference * lightnessDifference + chromaDifference * 0.75 * chromaDifference + hueTerm);
    if (distance > aTolerance + halfStep)
        return NO;
    if (aDistance != NULL)
        *aDistance = (float)distance;
    return YES;
}
+ (id)effectDescriptionPlistName
{
    return @"ReplaceColorsEffect";
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
static void HSReplaceColorsEffectReleasePixels(void *aInfo, const void *aData, size_t aSize)
{
    NSZoneFree(NULL, (void *)aData);
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
    HSReplaceColorsInfo source = HSReplaceColorsInfoForColor(_sourceColor);
    HSReplaceColorsInfo target = HSReplaceColorsInfoForColor(_targetColor);
    NSDictionary *attributes = [self effectAttributes];
    BOOL ignoreAlpha = [[attributes objectForKey:@"IgnoreAlpha"] boolValue];
    double tolerance = [[attributes objectForKey:@"ToleranceValue"] doubleValue];
    BOOL exchange = [[attributes objectForKey:@"ExchangeColors"] boolValue];

    const UInt8 *input = _inputImagePixels;
    for (size_t y = 0; y < height; y++) {
        const UInt8 *pixel = input + y * rowBytes;
        UInt8 *out = output + y * rowBytes;
        for (size_t x = 0; x < width; x++, pixel += 4, out += 4) {
            if (!exchange) {
                if (HSReplaceColorsMatches(pixel, &source, tolerance, ignoreAlpha, NULL))
                    memcpy(out, &target.premultiplied, 4);
                else
                    memcpy(out, pixel, 4);
                continue;
            }
            float sourceDistance = 0, targetDistance = 0;
            memcpy(out, pixel, 4);
            BOOL nearSource = HSReplaceColorsMatches(pixel, &source, tolerance, ignoreAlpha, &sourceDistance);
            if (nearSource)
                memcpy(out, &target.premultiplied, 4);
            if (HSReplaceColorsMatches(pixel, &target, tolerance, ignoreAlpha, &targetDistance) && (!nearSource || targetDistance < sourceDistance))
                memcpy(out, &source.premultiplied, 4);
        }
    }

    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, output, _inputImagePixelsSize, HSReplaceColorsEffectReleasePixels);
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
- (void)setAttribute:(id)aAttribute forKey:(id)aKey
{
    [super setAttribute:aAttribute forKey:aKey];
    CGImageRelease(_outputCGImage);
    _outputCGImage = NULL;
    [_outputImage release];
    _outputImage = nil;
}
// A 0…1 tolerance, scaled to the description's range.
- (void)setTolerance:(double)aTolerance
{
    double tolerance = aTolerance < 0 ? 0 : aTolerance;
    if (tolerance >= 1)
        tolerance = 1;
    [self setAttribute:[NSNumber numberWithDouble:(_maxTolerance - _minTolerance) * tolerance + _minTolerance] forKey:@"ToleranceValue"];
}
- (void)setToleranceValue:(id)aValue
{
    [self setTolerance:[aValue doubleValue]];
}
- (void)setTargetColor:(id)aColor
{
    if (_targetColor == aColor)
        return;
    [_targetColor release];
    _targetColor = [[aColor colorUsingColorSpaceName:NSDeviceRGBColorSpace] retain];
    CGImageRelease(_outputCGImage);
    _outputCGImage = NULL;
    [_outputImage release];
    _outputImage = nil;
}
- (void)setSourceColor:(id)aColor
{
    if (_sourceColor == aColor)
        return;
    [_sourceColor release];
    _sourceColor = [[aColor colorUsingColorSpaceName:NSDeviceRGBColorSpace] retain];
    CGImageRelease(_outputCGImage);
    _outputCGImage = NULL;
    [_outputImage release];
    _outputImage = nil;
}
- (void)dealloc
{
    [_effectDescription release];
    CGImageRelease(_outputCGImage);
    if (_inputImagePixels != NULL)
        NSZoneFree([self zone], _inputImagePixels);
    [_sourceColor release];
    [_targetColor release];
    [super dealloc];
}
// White to black by default.
- (id)initWithName:(id)aName
{
    self = [super init];
    if (self != nil) {
        _effectDescription = [[[[self class] effectsDescription] objectForKey:aName] retain];
        if (_effectDescription != nil) {
            _sourceColor = [[NSColor colorWithDeviceRed:1 green:1 blue:1 alpha:1] retain];
            _targetColor = [[NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:1] retain];
            NSDictionary *tolerance = [_effectDescription objectForKey:@"ToleranceValue"];
            _minTolerance = [[tolerance objectForKey:HSAttributeMin] doubleValue];
            _maxTolerance = [[tolerance objectForKey:HSAttributeMax] doubleValue];
            [super setDefaults];
            return self;
        }
    }
    [self release];
    return nil;
}
@end
