#import "HSBevelerEffect.h"

// Ramp used by the curved bevel shadings: info is {start, end, length}.
static void HSBevelerEffectEvaluateRamp(void *aInfo, const CGFloat *aIn, CGFloat *aOut)
{
    const float *ramp = aInfo;
    float t = (float)aIn[0] / ramp[2];
    if (t > 1.0f)
        t = 1.0f;
    aOut[0] = (ramp[1] - ramp[0]) * t + ramp[0];
}

static void HSBevelerEffectReleasePixels(void *aInfo, const void *aData, size_t aSize)
{
    NSZoneFree(NULL, (void *)aData);
}

@implementation HSBevelerEffect
+ (id)effectDescriptionPlistName
{
    return @"BevelerEffect";
}
- (void)setType:(id)aType
{
    [self setAttribute:aType forKey:HSBETypeFlagKey];
    _shouldUpdateMaskPixels = 1;
}
- (void)setInvert:(id)aInvert
{
    [self setAttribute:aInvert forKey:HSBEInversionFlagKey];
    _shouldUpdateIntensityTable = 1;
    _shouldUpdatePolyLightTable = 1;
    _shouldUpdateMaskPixels = 1;
}
- (void)setWidth:(id)aWidth
{
    float width = (float)[self HSBevelerEffect_adjustBevelWidth:[aWidth floatValue]];
    [self setAttribute:[NSNumber numberWithFloat:width] forKey:HSBEWidthKey];
    [self HSBevelerEffect_calculateInternalRectangleAndPathsForWidth:width];
    _shouldUpdateMaskPixels = 1;
}
- (void)setAttribute:(id)aAttribute forKey:(id)aKey
{
    [super setAttribute:aAttribute forKey:aKey];
    CGImageRelease(_outputCGImage);
    _outputCGImage = NULL;
    [_outputImage release];
    _outputImage = nil;
}
// Half the shorter side minus one, limited by the description's maximum
// (a negative maximum is subtracted); -1 when no bevel fits.
- (CGFloat)HSBevelerEffect_adjustMaxBevelSizeWithImageSize:(CGSize)aSize
{
    float size = roundf(fminf((float)aSize.width, (float)aSize.height) * 0.5f) - 1.0f;
    if (size <= _minBorderWidth)
        return -1;
    float max = roundf([[[[self attributes] objectForKey:HSBEWidthKey] objectForKey:HSAttributeMax] floatValue]);
    if (max != 0.0f) {
        if (max >= 0.0f)
            size = fminf(max, size);
        else
            size = size + max;
    }
    return fmaxf(_minBorderWidth, size);
}
- (CGFloat)HSBevelerEffect_adjustBevelWidth:(CGFloat)aWidth
{
    float width = fmaxf((float)aWidth, _minBorderWidth);
    if (_maxBorderWidth != 0.0f)
        width = fminf(width, _maxBorderWidth);
    return width;
}
// Each side is filled with an axial ramp perpendicular to the edge, clipped to
// the side's trapezoid; the middle gets the flat light value.
- (void)HSBevelerEffect_drawCurvedBevelInContext:(struct CGContext *)aContext
{
    static float sRamp[3] = {0.0f, 1.0f, 1.0f};
    float width = roundf((float)_internalRect.origin.x);
    float imageWidth = (float)_imageRect.size.width;
    float imageHeight = (float)_imageRect.size.height;
    float angles[4] = {(float)M_PI, (float)(M_PI * 0.5), (float)M_PI, (float)(M_PI * 0.5)};
    CGPoint *paths[4] = {_leftClipPath, _topClipPath, _rightClipPath, _bottomClipPath};
    float centers[4][2] = {
        {width * 0.5f, imageHeight * 0.5f},
        {imageWidth * 0.5f, imageHeight + width * -0.5f},
        {imageWidth + width * -0.5f, imageHeight * 0.5f},
        {imageWidth * 0.5f, width * 0.5f},
    };
    float sizes[4][2] = {
        {width + 2.0f, imageHeight + 2.0f},
        {imageWidth + 2.0f, width + 2.0f},
        {width + 2.0f, imageHeight + 2.0f},
        {imageWidth + 2.0f, width + 2.0f},
    };
    CGFunctionCallbacks callbacks = {0, HSBevelerEffectEvaluateRamp, NULL};
    CGFunctionRef function = CGFunctionCreate(sRamp, 1, NULL, 1, NULL, &callbacks);
    CGColorSpaceRef gray = CGColorSpaceCreateDeviceGray();
    CGContextSaveGState(aContext);
    CGContextClearRect(aContext, _imageRect);
    CGContextSetFillColorSpace(aContext, gray);
    int i;
    for (i = 0; i < 4; i++) {
        CGAffineTransform rotation = CGAffineTransformMakeRotation(angles[i]);
        double s = sin(angles[i]);
        double c = cos(angles[i]);
        float length = (float)(abs((int)(sizes[i][1] * s)) + abs((int)(sizes[i][0] * c)));
        float radius = floorf(length * 0.5f);
        if (fmodf(length, 2.0f) != 0.0f)
            radius += 1.0f;
        CGPoint start = CGPointMake(rotation.a * -radius + rotation.c * 0.0 + rotation.tx, rotation.b * -radius + rotation.d * 0.0 + rotation.ty);
        CGPoint end = CGPointMake(rotation.a * radius + rotation.c * 0.0 + rotation.tx, rotation.b * radius + rotation.d * 0.0 + rotation.ty);
        CGShadingRef shading = CGShadingCreateAxial(gray, start, end, function, false, false);
        if (!shading)
            continue;
        CGContextSaveGState(aContext);
        CGContextBeginPath(aContext);
        CGContextAddLines(aContext, paths[i], 5);
        CGContextClosePath(aContext);
        CGContextClip(aContext);
        CGContextTranslateCTM(aContext, _imageRect.origin.x + centers[i][0], _imageRect.origin.y + centers[i][1]);
        CGContextDrawShading(aContext, shading);
        CGShadingRelease(shading);
        CGContextRestoreGState(aContext);
    }
    CGFloat components[2] = {(_polyLight[0] * 255.0f) / 255.0f, 1.0};
    CGContextSetFillColor(aContext, components);
    CGContextFillRect(aContext, _internalRect);
    CGContextRestoreGState(aContext);
    CGFunctionRelease(function);
    CGColorSpaceRelease(gray);
}
- (void)HSBevelerEffect_drawFlatBevelInContext:(struct CGContext *)aContext
{
    BOOL invert = [[[self effectAttributes] objectForKey:HSBEInversionFlagKey] boolValue];
    CGPoint *paths[4] = {_topClipPath, _bottomClipPath, _rightClipPath, _leftClipPath};
    CGColorSpaceRef gray = CGColorSpaceCreateDeviceGray();
    CGContextSaveGState(aContext);
    CGFloat components[2] = {(_polyLight[0] * 255.0f) / 255.0f, 1.0};
    CGContextClearRect(aContext, _imageRect);
    CGContextSetFillColorSpace(aContext, gray);
    CGContextSetFillColor(aContext, components);
    CGContextFillRect(aContext, _internalRect);
    int i;
    for (i = 0; i < 4; i++) {
        float value = _polyLight[i + 1] * 256.0f;
        if (invert)
            value = 255.0f - value;
        components[0] = value / 255.0f;
        CGContextSaveGState(aContext);
        CGContextSetFillColor(aContext, components);
        CGContextBeginPath(aContext);
        CGContextAddLines(aContext, paths[i], 5);
        CGContextClosePath(aContext);
        CGContextDrawPath(aContext, kCGPathFill);
        CGContextRestoreGState(aContext);
    }
    CGContextRestoreGState(aContext);
    CGColorSpaceRelease(gray);
}
- (void)HSBevelerEffect_preparePolyLightTableUsingLight:(CGFloat)aLight
{
    if (!_shouldUpdatePolyLightTable && _polyLightTableInitialized)
        return;
    float light = (float)aLight;
    _polyLight[1] = light * 0.9f;
    _polyLight[4] = light * 0.8f;
    _polyLight[3] = light * 0.2f;
    _polyLight[2] = light * 0.1f;
    if (![[[self effectAttributes] objectForKey:HSBEInversionFlagKey] boolValue]) {
        _polyLight[1] = 1.0f - _polyLight[1];
        _polyLight[4] = 1.0f - _polyLight[4];
        _polyLight[3] = 1.0f - _polyLight[3];
        _polyLight[2] = 1.0f - _polyLight[2];
    }
    _polyLight[0] = light * 0.5f;
    _shouldUpdatePolyLightTable = 0;
    _polyLightTableInitialized = 1;
}
// Mask value -> signed brightness offset (128 - v, so 0 wraps to -128).
- (void)HSBevelerEffect_prepareIntensityTableForCurve:(CGFloat)aCurve
{
    if (!_shouldUpdateIntensityTable && _intensityTableInitialized)
        return;
    BOOL invert = [[[self effectAttributes] objectForKey:HSBEInversionFlagKey] boolValue];
    unsigned int i;
    for (i = 0; i < 256; i++) {
        long value = lroundf((float)(0xffffu * (i + 1)) / ((float)aCurve * 256.0f));
        if (invert)
            value = 0xffff - value;
        _intensityTable[i] = (signed char)(unsigned char)(-0x80 - (value / 257));
    }
    _shouldUpdateIntensityTable = 0;
    _intensityTableInitialized = 1;
}
// The four side trapezoids (left, right, top, bottom), each closed with a
// fifth point. The internal rectangle starts at (width, width), not at the
// image origin.
- (void)HSBevelerEffect_calculateInternalRectangleAndPathsForWidth:(CGFloat)aWidth
{
    CGFloat width = (float)aWidth;
    _internalRect.origin.x = width;
    _internalRect.origin.y = width;
    CGFloat internalWidth = _imageRect.size.width + width * -2.0;
    _internalRect.size.width = internalWidth;
    CGFloat internalHeight = width * -2.0 + _imageRect.size.height;
    _internalRect.size.height = internalHeight;
    CGFloat x = _imageRect.origin.x;
    CGFloat y = _imageRect.origin.y;
    CGFloat innerTop = internalHeight + width;
    CGFloat top = _imageRect.size.height + y;
    CGFloat innerRight = internalWidth + width;
    CGFloat right = _imageRect.size.width + x;
    _leftClipPath[0] = CGPointMake(x, y);
    _leftClipPath[1] = CGPointMake(width, width);
    _leftClipPath[2] = CGPointMake(width, innerTop);
    _leftClipPath[3] = CGPointMake(x, top);
    _leftClipPath[4] = CGPointMake(x, y);
    _rightClipPath[0] = CGPointMake(right, y);
    _rightClipPath[1] = CGPointMake(innerRight, width);
    _rightClipPath[2] = CGPointMake(innerRight, innerTop);
    _rightClipPath[3] = CGPointMake(right, top);
    _rightClipPath[4] = CGPointMake(right, y);
    _topClipPath[0] = CGPointMake(x, top);
    _topClipPath[1] = CGPointMake(width, innerTop);
    _topClipPath[2] = CGPointMake(innerRight, innerTop);
    _topClipPath[3] = CGPointMake(right, top);
    _topClipPath[4] = CGPointMake(x, top);
    _bottomClipPath[0] = CGPointMake(x, y);
    _bottomClipPath[1] = CGPointMake(width, width);
    _bottomClipPath[2] = CGPointMake(innerRight, width);
    _bottomClipPath[3] = CGPointMake(right, y);
    _bottomClipPath[4] = CGPointMake(x, y);
    _clipPointsInitialized = 1;
}
- (id)outputImage
{
    if (!_outputImage) {
        CGImageRef image = [self outputCGImage];
        if (image)
            _outputImage = [[NSImage hyperImageWithCGImage:image] retain];
    }
    return _outputImage;
}
// The input image (premultiplied ARGB) is brightened or darkened per pixel by
// the intensity table entry of the grey bevel mask.
- (struct CGImage *)outputCGImage
{
    if (CGRectIsEmpty(_imageRect))
        return NULL;
    if (_outputCGImage)
        return _outputCGImage;
    size_t width = _imageRect.size.width > 0 ? (size_t)lroundf(ceilf((float)_imageRect.size.width)) : 0;
    size_t height = _imageRect.size.height > 0 ? (size_t)lroundf(ceilf((float)_imageRect.size.height)) : 0;
    size_t maskRowBytes = (width + 4) & ~(size_t)3;
    size_t rowBytes = (width * 4 + 15) & ~(size_t)15;
    if (!_clipPointsInitialized)
        [self HSBevelerEffect_calculateInternalRectangleAndPathsForWidth:_minBorderWidth];
    if (_shouldUpdateImagePixels || !_workDataStorage) {
        size_t size = height * rowBytes;
        if (size > _workDataStorageSize) {
            if (_workDataStorage)
                NSZoneFree([self zone], _workDataStorage);
            _workDataStorage = NSZoneMalloc([self zone], size);
            _workDataStorageSize = _workDataStorage ? (unsigned int)size : 0;
        }
        if (!_workDataStorage)
            return _outputCGImage;
        CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
        if (!rgb)
            return _outputCGImage;
        CGContextRef context = CGBitmapContextCreate(_workDataStorage, width, height, 8, rowBytes, rgb, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
        CGColorSpaceRelease(rgb);
        if (!context)
            return _outputCGImage;
        [super copyCocoaImage:_inputImage toCGBitmapContext:context];
        CGContextRelease(context);
        _shouldUpdateImagePixels = 0;
    }
    [self HSBevelerEffect_preparePolyLightTableUsingLight:1.0];
    if (_shouldUpdateMaskPixels || !_maskDataStorage) {
        size_t size = height * maskRowBytes;
        if (size > _maskDataStorageSize) {
            if (_maskDataStorage)
                NSZoneFree([self zone], _maskDataStorage);
            _maskDataStorage = NSZoneMalloc([self zone], size);
            _maskDataStorageSize = _maskDataStorage ? (unsigned int)size : 0;
        }
        if (!_maskDataStorage)
            return _outputCGImage;
        CGColorSpaceRef gray = CGColorSpaceCreateDeviceGray();
        if (!gray)
            return _outputCGImage;
        CGContextRef context = CGBitmapContextCreate(_maskDataStorage, width, height, 8, maskRowBytes, gray, (CGBitmapInfo)kCGImageAlphaNone);
        CGColorSpaceRelease(gray);
        if (!context)
            return _outputCGImage;
        if ([[[self effectAttributes] objectForKey:HSBETypeFlagKey] boolValue])
            [self HSBevelerEffect_drawFlatBevelInContext:context];
        else
            [self HSBevelerEffect_drawCurvedBevelInContext:context];
        CGContextRelease(context);
        _shouldUpdateMaskPixels = 0;
    }
    UInt8 *output = NSZoneMalloc(NULL, _workDataStorageSize);
    if (!output)
        return _outputCGImage;
    [self HSBevelerEffect_prepareIntensityTableForCurve:1.0];
    const UInt8 *sourceRow = _workDataStorage;
    const UInt8 *maskRow = _maskDataStorage;
    UInt8 *outputRow = output;
    size_t x, y;
    for (y = 0; y < height; y++) {
        const UInt8 *source = sourceRow;
        const UInt8 *mask = maskRow;
        UInt8 *pixel = outputRow;
        for (x = 0; x < width; x++, source += 4, pixel += 4, mask++) {
            if (source[0] == 0) {
                *(UInt32 *)pixel = 0;
                continue;
            }
            float alpha = (float)source[0] / 255.0f;
            int c;
            for (c = 1; c < 4; c++) {
                float value = (float)(int)_intensityTable[*mask] + (float)source[c] / alpha;
                if (value <= 0.0f)
                    value = 0.0f;
                if (value > 255.0f)
                    value = 255.0f;
                pixel[c] = value * alpha > 0.0f ? (UInt8)lroundf(ceilf(value * alpha)) : 0;
            }
            pixel[0] = source[0];
        }
        sourceRow += rowBytes;
        maskRow += maskRowBytes;
        outputRow += rowBytes;
    }
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, output, _workDataStorageSize, HSBevelerEffectReleasePixels);
    if (!provider) {
        NSZoneFree(NULL, output);
        return _outputCGImage;
    }
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    if (rgb) {
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
    if (!_inputImage) {
        _imageRect = CGRectZero;
        return;
    }
    NSSize size = [[_inputImage bestRepresentationForDevice:nil] size];
    _imageRect = CGRectIntegral(CGRectMake(0, 0, size.width, size.height));
    if (CGRectIsEmpty(_imageRect))
        return;
    _maxBorderWidth = (float)[self HSBevelerEffect_adjustMaxBevelSizeWithImageSize:_imageRect.size];
    // Re-applies the width so it is clamped to the new maximum.
    [self setValue:[self valueForKey:HSBEWidthKey] forKey:HSBEWidthKey];
    CGImageRelease(_outputCGImage);
    _outputCGImage = NULL;
    [_outputImage release];
    _outputImage = nil;
    _shouldUpdateImagePixels = 1;
}
- (id)maxWidth
{
    return [NSNumber numberWithFloat:_maxBorderWidth];
}
- (void)dealloc
{
    [_effectDescription release];
    NSZone *zone = [self zone];
    if (_workDataStorage)
        NSZoneFree(zone, _workDataStorage);
    if (_maskDataStorage)
        NSZoneFree(zone, _maskDataStorage);
    CGImageRelease(_outputCGImage);
    [super dealloc];
}
- (id)initWithName:(id)aName
{
    self = [super init];
    if (self != nil) {
        _effectDescription = [[[[self class] effectsDescription] objectForKey:aName] retain];
        if (_effectDescription != nil) {
            _minBorderWidth = fmaxf([[[[self attributes] objectForKey:HSBEWidthKey] objectForKey:HSAttributeMin] floatValue], 0.0f);
            _maxBorderWidth = 0.0f;
            [super setDefaults];
            return self;
        }
    }
    [self release];
    return nil;
}
@end
