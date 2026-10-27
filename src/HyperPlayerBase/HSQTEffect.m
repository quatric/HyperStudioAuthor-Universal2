#import "HSQTEffect.h"
#import "HSQTAtomContainer.h"
#import "NSImage+HSImageSize.h"

// QuickTime image effects (QTEffects.plist): the effect's parameters live in
// a QuickTime atom container exactly as the original kept them, and are
// read and written through input<Name>WithType:atomID: accessors that use
// QuickTime's encodings (big-endian integers, 16.16 fixed, RGBColor,
// kernel sizes stored as 2n+1). QuickTime's effect codecs are gone, so the
// image is filtered here instead, approximating each of the nine effects.

static NSDictionary *sQTEffectsDescription = nil;

static SInt32 HSQTEffectSwap(SInt32 aValue)
{
    return (SInt32)CFSwapInt32HostToBig((UInt32)aValue);
}

#pragma mark - Filtering

// Unpremultiplied RGB in 0-255 floats plus the original alpha bytes.
typedef struct {
    size_t width, height;
    float *rgb;
} HSQTEffectPixels;

static inline float HSQTEffectClamp(float aValue)
{
    return aValue < 0 ? 0 : (aValue > 255 ? 255 : aValue);
}

static inline const float *HSQTEffectPixelAt(const HSQTEffectPixels *aPixels, long aX, long aY)
{
    if (aX < 0) aX = 0;
    if (aY < 0) aY = 0;
    if (aX >= (long)aPixels->width) aX = aPixels->width - 1;
    if (aY >= (long)aPixels->height) aY = aPixels->height - 1;
    return aPixels->rgb + (aY * aPixels->width + aX) * 3;
}

static inline float HSQTEffectLuminance(const float *aRGB)
{
    return 0.299f * aRGB[0] + 0.587f * aRGB[1] + 0.114f * aRGB[2];
}

// Box blur, horizontal then vertical, with clamped edges.
static void HSQTEffectBoxBlur(HSQTEffectPixels *aPixels, long aRadius)
{
    if (aRadius < 1)
        return;
    size_t w = aPixels->width, h = aPixels->height;
    float *temp = malloc(w * h * 3 * sizeof(float));
    if (temp == NULL)
        return;
    float scale = 1.0f / (2 * aRadius + 1);
    for (size_t y = 0; y < h; y++)
        for (size_t x = 0; x < w; x++)
            for (int c = 0; c < 3; c++) {
                float sum = 0;
                for (long k = -aRadius; k <= aRadius; k++)
                    sum += HSQTEffectPixelAt(aPixels, (long)x + k, y)[c];
                temp[(y * w + x) * 3 + c] = sum * scale;
            }
    HSQTEffectPixels source = { w, h, temp };
    for (size_t y = 0; y < h; y++)
        for (size_t x = 0; x < w; x++)
            for (int c = 0; c < 3; c++) {
                float sum = 0;
                for (long k = -aRadius; k <= aRadius; k++)
                    sum += HSQTEffectPixelAt(&source, x, (long)y + k)[c];
                aPixels->rgb[(y * w + x) * 3 + c] = sum * scale;
            }
    free(temp);
}

static float *HSQTEffectCopyRGB(const HSQTEffectPixels *aPixels)
{
    size_t length = aPixels->width * aPixels->height * 3 * sizeof(float);
    float *copy = malloc(length);
    if (copy != NULL)
        memcpy(copy, aPixels->rgb, length);
    return copy;
}

static void HSQTEffectScale(HSQTEffectPixels *aPixels, float aScale)
{
    size_t count = aPixels->width * aPixels->height * 3;
    for (size_t i = 0; i < count; i++)
        aPixels->rgb[i] = HSQTEffectClamp(aPixels->rgb[i] * aScale);
}

static void HSQTEffectBlur(HSQTEffectPixels *aPixels, long aAmount, float aBrightness)
{
    // Two box passes come close to the gaussian QuickTime used.
    HSQTEffectBoxBlur(aPixels, aAmount);
    HSQTEffectBoxBlur(aPixels, aAmount);
    HSQTEffectScale(aPixels, aBrightness);
}

static void HSQTEffectSharpen(HSQTEffectPixels *aPixels, long aAmount, float aBrightness)
{
    float *original = HSQTEffectCopyRGB(aPixels);
    if (original == NULL)
        return;
    HSQTEffectBoxBlur(aPixels, 1);
    float strength = aAmount * 0.5f;
    size_t count = aPixels->width * aPixels->height * 3;
    for (size_t i = 0; i < count; i++)
        aPixels->rgb[i] = HSQTEffectClamp((original[i] + (original[i] - aPixels->rgb[i]) * strength) * aBrightness);
    free(original);
}

// Sobel edges sampled aThickness pixels apart; colorized edges keep each
// channel's own gradient, otherwise the luminance gradient is grey.
static void HSQTEffectEdgeDetect(HSQTEffectPixels *aPixels, long aThickness, BOOL aColorize)
{
    float *original = HSQTEffectCopyRGB(aPixels);
    if (original == NULL)
        return;
    HSQTEffectPixels source = { aPixels->width, aPixels->height, original };
    long d = MAX(aThickness, 1);
    for (size_t y = 0; y < aPixels->height; y++)
        for (size_t x = 0; x < aPixels->width; x++) {
            float *out = aPixels->rgb + (y * aPixels->width + x) * 3;
            const float *p[3][3];
            for (int j = -1; j <= 1; j++)
                for (int i = -1; i <= 1; i++)
                    p[j + 1][i + 1] = HSQTEffectPixelAt(&source, (long)x + i * d, (long)y + j * d);
            if (aColorize) {
                for (int c = 0; c < 3; c++) {
                    float gx = p[0][2][c] + 2 * p[1][2][c] + p[2][2][c] - p[0][0][c] - 2 * p[1][0][c] - p[2][0][c];
                    float gy = p[2][0][c] + 2 * p[2][1][c] + p[2][2][c] - p[0][0][c] - 2 * p[0][1][c] - p[0][2][c];
                    out[c] = HSQTEffectClamp(sqrtf(gx * gx + gy * gy));
                }
            } else {
                float l[3][3];
                for (int j = 0; j < 3; j++)
                    for (int i = 0; i < 3; i++)
                        l[j][i] = HSQTEffectLuminance(p[j][i]);
                float gx = l[0][2] + 2 * l[1][2] + l[2][2] - l[0][0] - 2 * l[1][0] - l[2][0];
                float gy = l[2][0] + 2 * l[2][1] + l[2][2] - l[0][0] - 2 * l[0][1] - l[0][2];
                out[0] = out[1] = out[2] = HSQTEffectClamp(sqrtf(gx * gx + gy * gy));
            }
        }
    free(original);
}

static void HSQTEffectEmboss(HSQTEffectPixels *aPixels, long aAmount)
{
    float *original = HSQTEffectCopyRGB(aPixels);
    if (original == NULL)
        return;
    HSQTEffectPixels source = { aPixels->width, aPixels->height, original };
    for (size_t y = 0; y < aPixels->height; y++)
        for (size_t x = 0; x < aPixels->width; x++) {
            float difference = HSQTEffectLuminance(HSQTEffectPixelAt(&source, (long)x + 1, (long)y + 1)) - HSQTEffectLuminance(HSQTEffectPixelAt(&source, (long)x - 1, (long)y - 1));
            float *out = aPixels->rgb + (y * aPixels->width + x) * 3;
            out[0] = out[1] = out[2] = HSQTEffectClamp(128 + difference * aAmount * 0.5f);
        }
    free(original);
}

// A 3x3 kernel, row by row, normalized by its sum unless that is zero.
static void HSQTEffectConvolve(HSQTEffectPixels *aPixels, const float *aCells)
{
    float *original = HSQTEffectCopyRGB(aPixels);
    if (original == NULL)
        return;
    HSQTEffectPixels source = { aPixels->width, aPixels->height, original };
    float sum = 0;
    for (int i = 0; i < 9; i++)
        sum += aCells[i];
    float scale = fabsf(sum) > 0.0001f ? 1 / sum : 1;
    for (size_t y = 0; y < aPixels->height; y++)
        for (size_t x = 0; x < aPixels->width; x++) {
            float *out = aPixels->rgb + (y * aPixels->width + x) * 3;
            for (int c = 0; c < 3; c++) {
                float value = 0;
                for (int j = -1; j <= 1; j++)
                    for (int i = -1; i <= 1; i++)
                        value += aCells[(j + 1) * 3 + i + 1] * HSQTEffectPixelAt(&source, (long)x + i, (long)y + j)[c];
                out[c] = HSQTEffectClamp(value * scale);
            }
        }
    free(original);
}

static void HSQTEffectRGBBalance(HSQTEffectPixels *aPixels, float aRed, float aGreen, float aBlue)
{
    size_t count = aPixels->width * aPixels->height;
    for (size_t i = 0; i < count; i++) {
        float *p = aPixels->rgb + i * 3;
        p[0] = HSQTEffectClamp(p[0] * aRed / 100);
        p[1] = HSQTEffectClamp(p[1] * aGreen / 100);
        p[2] = HSQTEffectClamp(p[2] * aBlue / 100);
    }
}

static float HSQTEffectHueToRGB(float aP, float aQ, float aT)
{
    if (aT < 0) aT += 1;
    if (aT > 1) aT -= 1;
    if (aT < 1.0f / 6) return aP + (aQ - aP) * 6 * aT;
    if (aT < 0.5f) return aQ;
    if (aT < 2.0f / 3) return aP + (aQ - aP) * (2.0f / 3 - aT) * 6;
    return aP;
}

// The hue is shifted by the hue value in degrees; saturation and lightness
// are scaled by theirs in percent.
static void HSQTEffectHSLBalance(HSQTEffectPixels *aPixels, float aHue, float aSaturation, float aLightness)
{
    size_t count = aPixels->width * aPixels->height;
    for (size_t i = 0; i < count; i++) {
        float *p = aPixels->rgb + i * 3;
        float r = p[0] / 255, g = p[1] / 255, b = p[2] / 255;
        float max = MAX(r, MAX(g, b)), min = MIN(r, MIN(g, b));
        float h = 0, s = 0, l = (max + min) / 2;
        if (max > min) {
            float d = max - min;
            s = l > 0.5f ? d / (2 - max - min) : d / (max + min);
            if (max == r)
                h = (g - b) / d + (g < b ? 6 : 0);
            else if (max == g)
                h = (b - r) / d + 2;
            else
                h = (r - g) / d + 4;
            h /= 6;
        }
        h = fmodf(h + aHue / 360 + 1, 1);
        s = MIN(MAX(s * aSaturation / 100, 0), 1);
        l = MIN(MAX(l * aLightness / 100, 0), 1);
        if (s == 0) {
            p[0] = p[1] = p[2] = l * 255;
        } else {
            float q = l < 0.5f ? l * (1 + s) : l + s - l * s;
            float pp = 2 * l - q;
            p[0] = HSQTEffectHueToRGB(pp, q, h + 1.0f / 3) * 255;
            p[1] = HSQTEffectHueToRGB(pp, q, h) * 255;
            p[2] = HSQTEffectHueToRGB(pp, q, h - 1.0f / 3) * 255;
        }
    }
}

// Values above the solarize point fold back by the solarize amount, then
// posterizing keeps amount + 1 levels per channel (0 leaves them alone).
static void HSQTEffectSolarize(HSQTEffectPixels *aPixels, float aAmount, float aPoint, long aPosterize)
{
    size_t count = aPixels->width * aPixels->height * 3;
    for (size_t i = 0; i < count; i++) {
        float value = aPixels->rgb[i];
        if (aAmount > 0 && value > aPoint)
            value = HSQTEffectClamp(aPoint - (value - aPoint) * aAmount);
        if (aPosterize > 0) {
            float levels = aPosterize;
            value = roundf(value / 255 * levels) / levels * 255;
        }
        aPixels->rgb[i] = value;
    }
}

// Maps the adjusted luminance onto a ramp from a dark to a light colour.
static void HSQTEffectColorTint(HSQTEffectPixels *aPixels, const float *aDark, const float *aLight, float aBrightness, float aContrast)
{
    size_t count = aPixels->width * aPixels->height;
    for (size_t i = 0; i < count; i++) {
        float *p = aPixels->rgb + i * 3;
        float l = HSQTEffectLuminance(p);
        l = (l - 128) * (aContrast + 128) / 128 + 128 + aBrightness;
        float t = HSQTEffectClamp(l) / 255;
        for (int c = 0; c < 3; c++)
            p[c] = aDark[c] + (aLight[c] - aDark[c]) * t;
    }
}

#pragma mark -

@implementation HSQTEffect

+ (id)effectsDescription
{
    if (sQTEffectsDescription == nil) {
        NSString *path = [[NSBundle bundleForClass:self] pathForResource:@"QTEffects" ofType:@"plist"];
        if (path != nil)
            sQTEffectsDescription = [[NSDictionary alloc] initWithContentsOfFile:path];
    }
    return sQTEffectsDescription;
}

// The nine convolution cells share one accessor, and so do the three
// multipliers of each colour balance.
- (id)selectorStringForKey:(id)aKey
{
    if ([aKey hasPrefix:@"InputCell"])
        return @"InputCell";
    if ([aKey hasSuffix:@"Multiplier"])
        return @"InputMultiplier";
    return aKey;
}

- (BOOL)getParamAtom:(id)aAtom atomID:(id)aID size:(NSInteger)aSize value:(void *)aValue
{
    HSQTAtom atom = HSQTFindChildByID((HSQTAtomContainer)_effectDesc, kHSQTParentAtomIsContainer, [aAtom unsignedIntValue], (SInt32)[aID longValue], NULL);
    if (atom == 0)
        return NO;
    return HSQTCopyAtomDataToPtr((HSQTAtomContainer)_effectDesc, atom, true, (SInt32)aSize, aValue, NULL) == noErr;
}

- (BOOL)addParamAtom:(id)aAtom atomID:(id)aID size:(NSInteger)aSize value:(void *)aValue
{
    OSType type = [aAtom unsignedIntValue];
    SInt32 atomID = (SInt32)[aID longValue];
    HSQTAtom atom = HSQTFindChildByID((HSQTAtomContainer)_effectDesc, kHSQTParentAtomIsContainer, type, atomID, NULL);
    if (atom != 0 && HSQTRemoveAtom((HSQTAtomContainer)_effectDesc, atom) != noErr)
        return NO;
    return HSQTInsertChild((HSQTAtomContainer)_effectDesc, kHSQTParentAtomIsContainer, type, atomID, 0, (SInt32)aSize, aValue, NULL) == noErr;
}

// Plain big-endian integers.

- (id)HSQTEffect_longWithType:(id)aType atomID:(id)aID
{
    SInt32 value = 0;
    if (![self getParamAtom:aType atomID:aID size:4 value:&value])
        return nil;
    return [NSNumber numberWithLong:HSQTEffectSwap(value)];
}

- (void)HSQTEffect_setLong:(id)aValue withType:(id)aType atomID:(id)aID
{
    SInt32 value = HSQTEffectSwap((SInt32)lrintf([aValue floatValue]));
    [self addParamAtom:aType atomID:aID size:4 value:&value];
}

// 16.16 fixed point.

- (id)HSQTEffect_fixedWithType:(id)aType atomID:(id)aID
{
    SInt32 value = 0;
    if (![self getParamAtom:aType atomID:aID size:4 value:&value])
        return nil;
    return [NSNumber numberWithFloat:HSQTEffectSwap(value) * (1.0f / 65536)];
}

- (void)HSQTEffect_setFixed:(id)aValue withType:(id)aType atomID:(id)aID
{
    float fixed = [aValue floatValue] * 65536;
    SInt32 value = fixed >= 2147483648.0f ? 0x7fffffff : (SInt32)fixed;
    value = HSQTEffectSwap(value);
    [self addParamAtom:aType atomID:aID size:4 value:&value];
}

// RGBColor: three big-endian 16-bit components.

- (id)HSQTEffect_colorWithType:(id)aType atomID:(id)aID
{
    UInt16 rgb[3] = { 0, 0, 0 };
    if (![self getParamAtom:aType atomID:aID size:6 value:rgb])
        return nil;
    return [NSColor colorWithCalibratedRed:CFSwapInt16BigToHost(rgb[0]) / 65535.0f
                                     green:CFSwapInt16BigToHost(rgb[1]) / 65535.0f
                                      blue:CFSwapInt16BigToHost(rgb[2]) / 65535.0f
                                     alpha:1];
}

- (void)HSQTEffect_setColor:(id)aColor withType:(id)aType atomID:(id)aID
{
    if (![[aColor colorSpaceName] isEqualToString:NSCalibratedRGBColorSpace])
        aColor = [aColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    if (aColor == nil)
        return;
    UInt16 rgb[3];
    rgb[0] = CFSwapInt16HostToBig((UInt16)(int)((float)[aColor redComponent] * 65535));
    rgb[1] = CFSwapInt16HostToBig((UInt16)(int)((float)[aColor greenComponent] * 65535));
    rgb[2] = CFSwapInt16HostToBig((UInt16)(int)((float)[aColor blueComponent] * 65535));
    [self addParamAtom:aType atomID:aID size:6 value:rgb];
}

- (id)inputContrastWithType:(id)aType atomID:(id)aID { return [self HSQTEffect_longWithType:aType atomID:aID]; }
- (void)setInputContrast:(id)aContrast withType:(id)aType atomID:(id)aID { [self HSQTEffect_setLong:aContrast withType:aType atomID:aID]; }
- (id)inputTintBrightnessWithType:(id)aType atomID:(id)aID { return [self HSQTEffect_longWithType:aType atomID:aID]; }
- (void)setInputTintBrightness:(id)aBrightness withType:(id)aType atomID:(id)aID { [self HSQTEffect_setLong:aBrightness withType:aType atomID:aID]; }
- (id)inputLightColorWithType:(id)aType atomID:(id)aID { return [self HSQTEffect_colorWithType:aType atomID:aID]; }
- (void)setInputLightColor:(id)aColor withType:(id)aType atomID:(id)aID { [self HSQTEffect_setColor:aColor withType:aType atomID:aID]; }
- (id)inputDarkColorWithType:(id)aType atomID:(id)aID { return [self HSQTEffect_colorWithType:aType atomID:aID]; }
- (void)setInputDarkColor:(id)aColor withType:(id)aType atomID:(id)aID { [self HSQTEffect_setColor:aColor withType:aType atomID:aID]; }
- (id)inputTintWithType:(id)aType atomID:(id)aID { return [self HSQTEffect_longWithType:aType atomID:aID]; }
- (void)setInputTint:(id)aTint withType:(id)aType atomID:(id)aID { [self HSQTEffect_setLong:aTint withType:aType atomID:aID]; }
- (id)inputPosterizeAmountWithType:(id)aType atomID:(id)aID { return [self HSQTEffect_longWithType:aType atomID:aID]; }
- (void)setInputPosterizeAmount:(id)aAmount withType:(id)aType atomID:(id)aID { [self HSQTEffect_setLong:aAmount withType:aType atomID:aID]; }
- (id)inputSolarizePointWithType:(id)aType atomID:(id)aID { return [self HSQTEffect_longWithType:aType atomID:aID]; }
- (void)setInputSolarizePoint:(id)aPoint withType:(id)aType atomID:(id)aID { [self HSQTEffect_setLong:aPoint withType:aType atomID:aID]; }
- (id)inputSolarizeAmountWithType:(id)aType atomID:(id)aID { return [self HSQTEffect_longWithType:aType atomID:aID]; }
- (void)setInputSolarizeAmount:(id)aAmount withType:(id)aType atomID:(id)aID { [self HSQTEffect_setLong:aAmount withType:aType atomID:aID]; }
- (id)inputMultiplierWithType:(id)aType atomID:(id)aID { return [self HSQTEffect_longWithType:aType atomID:aID]; }
- (void)setInputMultiplier:(id)aMultiplier withType:(id)aType atomID:(id)aID { [self HSQTEffect_setLong:aMultiplier withType:aType atomID:aID]; }
- (id)inputBottomAlphaPinWithType:(id)aType atomID:(id)aID { return [self HSQTEffect_longWithType:aType atomID:aID]; }
- (void)setInputBottomAlphaPin:(id)aPin withType:(id)aType atomID:(id)aID { [self HSQTEffect_setLong:aPin withType:aType atomID:aID]; }
- (id)inputTopAlphaPinWithType:(id)aType atomID:(id)aID { return [self HSQTEffect_longWithType:aType atomID:aID]; }
- (void)setInputTopAlphaPin:(id)aPin withType:(id)aType atomID:(id)aID { [self HSQTEffect_setLong:aPin withType:aType atomID:aID]; }
- (id)inputOffsetValueWithType:(id)aType atomID:(id)aID { return [self HSQTEffect_longWithType:aType atomID:aID]; }
- (void)setInputOffsetValue:(id)aValue withType:(id)aType atomID:(id)aID { [self HSQTEffect_setLong:aValue withType:aType atomID:aID]; }
- (id)inputGainValueWithType:(id)aType atomID:(id)aID { return [self HSQTEffect_fixedWithType:aType atomID:aID]; }
- (void)setInputGainValue:(id)aValue withType:(id)aType atomID:(id)aID { [self HSQTEffect_setFixed:aValue withType:aType atomID:aID]; }
- (id)inputCellWithType:(id)aType atomID:(id)aID { return [self HSQTEffect_fixedWithType:aType atomID:aID]; }
- (void)setInputCell:(id)aCell withType:(id)aType atomID:(id)aID { [self HSQTEffect_setFixed:aCell withType:aType atomID:aID]; }

// A big-endian 32-bit boolean.
- (id)inputColorizeWithType:(id)aType atomID:(id)aID
{
    SInt32 value = 0;
    if (![self getParamAtom:aType atomID:aID size:4 value:&value])
        return nil;
    return [NSNumber numberWithBool:(HSQTEffectSwap(value) & 0xff) != 0];
}

- (void)setInputColorize:(id)aColorize withType:(id)aType atomID:(id)aID
{
    SInt32 value = HSQTEffectSwap((signed char)[aColorize boolValue]);
    [self addParamAtom:aType atomID:aID size:4 value:&value];
}

- (id)inputBrightnessWithType:(id)aType atomID:(id)aID { return [self HSQTEffect_fixedWithType:aType atomID:aID]; }
- (void)setInputBrightness:(id)aBrightness withType:(id)aType atomID:(id)aID { [self HSQTEffect_setFixed:aBrightness withType:aType atomID:aID]; }

// Stored as the kernel size, 2n + 1.
- (id)inputAmountWithType:(id)aType atomID:(id)aID
{
    SInt32 value = 0;
    if (![self getParamAtom:aType atomID:aID size:4 value:&value])
        return nil;
    return [NSNumber numberWithLong:(HSQTEffectSwap(value) - 1) >> 1];
}

- (void)setInputAmount:(id)aAmount withType:(id)aType atomID:(id)aID
{
    SInt32 value = HSQTEffectSwap((SInt32)lrintf([aAmount floatValue]) * 2 + 1);
    [self addParamAtom:aType atomID:aID size:4 value:&value];
}

// Original quirk kept: keys the description doesn't list answer nil
// instead of going to NSObject's key-value coding.
- (id)valueForKey:(id)aKey
{
    NSDictionary *attribute = [_effectDescription objectForKey:aKey];
    id type = [attribute objectForKey:HSAttributeAtomType];
    id atomID = [attribute objectForKey:HSAttributeAtomID];
    if (type == nil || atomID == nil)
        return nil;
    NSString *name = [self selectorStringForKey:aKey];
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@%@WithType:atomID:", [[name substringToIndex:1] lowercaseString], [name substringFromIndex:1]]);
    if (![self respondsToSelector:selector])
        return nil;
    return [self performSelector:selector withObject:type withObject:atomID];
}

// A nil value stores the description's default (archived for colours).
- (void)setValue:(id)aValue forKey:(id)aKey
{
    NSDictionary *attribute = [_effectDescription objectForKey:aKey];
    id type = [attribute objectForKey:HSAttributeAtomType];
    id atomID = [attribute objectForKey:HSAttributeAtomID];
    if (type == nil || atomID == nil)
        return;
    id value = aValue;
    if (value == nil) {
        value = [attribute objectForKey:HSAttributeDefault];
        if (![[attribute objectForKey:HSAttributeClass] isEqualToString:NSStringFromClass([value class])] && [value isKindOfClass:[NSData class]])
            value = [NSUnarchiver unarchiveObjectWithData:value];
    }
    if (value == nil)
        return;
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"set%@:withType:atomID:", [self selectorStringForKey:aKey]]);
    NSMethodSignature *signature = [self methodSignatureForSelector:selector];
    // Fix: the original built the invocation without checking for a
    // signature, which raises for a key that has no setter.
    if (signature == nil)
        return;
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:self];
    [invocation setSelector:selector];
    [invocation setArgument:&value atIndex:2];
    [invocation setArgument:&type atIndex:3];
    [invocation setArgument:&atomID atIndex:4];
    [invocation invoke];
}

- (void)takeValue:(id)aValue forKey:(id)aKey
{
    [self setValue:aValue forKey:aKey];
}

// The value of an input, or its default from the description.
- (id)HSQTEffect_parameterForKey:(NSString *)aKey
{
    id value = [self valueForKey:aKey];
    if (value != nil)
        return value;
    NSDictionary *attribute = [_effectDescription objectForKey:aKey];
    value = [attribute objectForKey:HSAttributeDefault];
    if (![[attribute objectForKey:HSAttributeClass] isEqualToString:NSStringFromClass([value class])] && [value isKindOfClass:[NSData class]])
        value = [NSUnarchiver unarchiveObjectWithData:value];
    return value;
}

- (void)HSQTEffect_getRGB:(float *)aRGB forKey:(NSString *)aKey
{
    NSColor *color = [[self HSQTEffect_parameterForKey:aKey] colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    aRGB[0] = color ? [color redComponent] * 255 : 0;
    aRGB[1] = color ? [color greenComponent] * 255 : 0;
    aRGB[2] = color ? [color blueComponent] * 255 : 0;
}

- (void)HSQTEffect_applyToPixels:(HSQTEffectPixels *)aPixels
{
    OSType effect = [[_effectDescription objectForKey:HSAttributeEffectAtomType] unsignedIntValue];
    switch (effect) {
        case 'blur':
            HSQTEffectBlur(aPixels, [[self HSQTEffect_parameterForKey:@"InputAmount"] longValue], [[self HSQTEffect_parameterForKey:@"InputBrightness"] floatValue]);
            break;
        case 'shrp':
            HSQTEffectSharpen(aPixels, [[self HSQTEffect_parameterForKey:@"InputAmount"] longValue], [[self HSQTEffect_parameterForKey:@"InputBrightness"] floatValue]);
            break;
        case 'edge':
            HSQTEffectEdgeDetect(aPixels, ([[self HSQTEffect_parameterForKey:@"InputAmount"] longValue] - 1) / 2, [[self HSQTEffect_parameterForKey:@"InputColorize"] boolValue]);
            break;
        case 'embs':
            HSQTEffectEmboss(aPixels, [[self HSQTEffect_parameterForKey:@"InputAmount"] longValue]);
            break;
        case 'genk': {
            static NSString * const keys[9] = { @"InputCellOne", @"InputCellTwo", @"InputCellThree", @"InputCellFour", @"InputCellFive", @"InputCellSix", @"InputCellSeven", @"InputCellEight", @"InputCellNine" };
            float cells[9];
            for (int i = 0; i < 9; i++)
                cells[i] = [[self HSQTEffect_parameterForKey:keys[i]] floatValue];
            HSQTEffectConvolve(aPixels, cells);
            break;
        }
        case 'rgbb':
            HSQTEffectRGBBalance(aPixels, [[self HSQTEffect_parameterForKey:@"InputRedMultiplier"] floatValue], [[self HSQTEffect_parameterForKey:@"InputGreenMultiplier"] floatValue], [[self HSQTEffect_parameterForKey:@"InputBlueMultiplier"] floatValue]);
            break;
        case 'hslb':
            HSQTEffectHSLBalance(aPixels, [[self HSQTEffect_parameterForKey:@"InputHueMultiplier"] floatValue], [[self HSQTEffect_parameterForKey:@"InputSaturationMultiplier"] floatValue], [[self HSQTEffect_parameterForKey:@"InputLightnessMultiplier"] floatValue]);
            break;
        case 'solr':
            HSQTEffectSolarize(aPixels, [[self HSQTEffect_parameterForKey:@"InputSolarizeAmount"] floatValue], [[self HSQTEffect_parameterForKey:@"InputSolarizePoint"] floatValue], [[self HSQTEffect_parameterForKey:@"InputPosterizeAmount"] longValue]);
            break;
        case 'tint': {
            // Tints: 1 black and white, 2 X-ray, 3 sepia, 4 cobalt, else the
            // dark and light colours.
            float dark[3], light[3];
            switch ([[self HSQTEffect_parameterForKey:@"InputTint"] longValue]) {
                case 1: dark[0] = dark[1] = dark[2] = 0; light[0] = light[1] = light[2] = 255; break;
                case 2: dark[0] = dark[1] = dark[2] = 255; light[0] = light[1] = light[2] = 0; break;
                case 3: dark[0] = 40; dark[1] = 20; dark[2] = 0; light[0] = 255; light[1] = 240; light[2] = 200; break;
                case 4: dark[0] = 0; dark[1] = 0; dark[2] = 64; light[0] = 190; light[1] = 220; light[2] = 255; break;
                default:
                    [self HSQTEffect_getRGB:dark forKey:@"InputDarkColor"];
                    [self HSQTEffect_getRGB:light forKey:@"InputLightColor"];
                    break;
            }
            HSQTEffectColorTint(aPixels, dark, light, [[self HSQTEffect_parameterForKey:@"InputTintBrightness"] floatValue], [[self HSQTEffect_parameterForKey:@"InputContrast"] floatValue]);
            break;
        }
    }
}

// Filters the context's premultiplied ARGB pixels (QuickTime's k32ARGB
// GWorld in the original) and returns them as an image.
- (id)effectImageForContextImage:(struct CGContext *)aImage
{
    UInt8 *data = CGBitmapContextGetData(aImage);
    size_t width = CGBitmapContextGetWidth(aImage), height = CGBitmapContextGetHeight(aImage);
    size_t rowBytes = CGBitmapContextGetBytesPerRow(aImage);
    if (data == NULL || width == 0 || height == 0)
        return nil;
    HSQTEffectPixels pixels = { width, height, malloc(width * height * 3 * sizeof(float)) };
    if (pixels.rgb == NULL)
        return nil;
    for (size_t y = 0; y < height; y++)
        for (size_t x = 0; x < width; x++) {
            const UInt8 *p = data + y * rowBytes + x * 4;
            float *rgb = pixels.rgb + (y * width + x) * 3;
            float scale = p[0] ? 255.0f / p[0] : 0;
            for (int c = 0; c < 3; c++)
                rgb[c] = HSQTEffectClamp(p[c + 1] * scale);
        }
    [self HSQTEffect_applyToPixels:&pixels];
    for (size_t y = 0; y < height; y++)
        for (size_t x = 0; x < width; x++) {
            UInt8 *p = data + y * rowBytes + x * 4;
            const float *rgb = pixels.rgb + (y * width + x) * 3;
            for (int c = 0; c < 3; c++)
                p[c + 1] = (UInt8)lrintf(rgb[c] * p[0] / 255.0f);
        }
    free(pixels.rgb);
    CGImageRef image = CGBitmapContextCreateImage(aImage);
    if (image == NULL)
        return nil;
    NSImage *result = [NSImage hyperImageWithCGImage:image];
    CGImageRelease(image);
    return result;
}

- (id)category
{
    return HSQTEffectsCategory;
}

- (id)outputImage
{
    if (_inputImage == nil)
        return nil;
    NSSize size = [_inputImage size];
    size_t width = (size_t)ceilf(size.width), height = (size_t)ceilf(size.height);
    // Fix: an empty image made the original allocate nothing and fail later.
    if (width == 0 || height == 0)
        return nil;
    size_t rowBytes = (width * 4 + 15) & ~(size_t)15;
    void *data = calloc(height, rowBytes);
    if (data == NULL)
        return nil;
    id result = nil;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = colorSpace ? CGBitmapContextCreate(data, width, height, 8, rowBytes, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst) : NULL;
    CGColorSpaceRelease(colorSpace);
    if (context != NULL) {
        NSGraphicsContext *graphicsContext = [NSGraphicsContext graphicsContextWithCGContext:context flipped:NO];
        if (graphicsContext != nil) {
            NSGraphicsContext *previous = [[NSGraphicsContext currentContext] retain];
            [NSGraphicsContext setCurrentContext:graphicsContext];
            [_inputImage drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositingOperationCopy fraction:1];
            [NSGraphicsContext setCurrentContext:previous];
            [previous release];
            result = [self effectImageForContextImage:context];
        }
        CGContextRelease(context);
    }
    free(data);
    return result;
}

- (void)setInputImage:(id)aImage
{
    if (_inputImage != aImage) {
        [_inputImage release];
        _inputImage = [aImage retain];
    }
}

- (void)setDefaults
{
    NSEnumerator *enumerator = [[_effectDescription objectForKey:HSInputsAttribute] objectEnumerator];
    id key;
    while ((key = [enumerator nextObject]))
        [self takeValue:nil forKey:key];
}

- (id)attributes
{
    return _effectDescription;
}

- (id)inputKeys
{
    return [_effectDescription objectForKey:HSInputsAttribute];
}

- (id)name
{
    return [_effectDescription objectForKey:HSAttributeEffectName];
}

- (void)dealloc
{
    [_screenBitmap release];
    [_inputImage release];
    [_effectDescription release];
    [_previewImage release];
    if (_effectDesc != NULL)
        HSQTDisposeAtomContainer((HSQTAtomContainer)_effectDesc);
    [super dealloc];
}

// The atom container starts with the effect type ('what') and its source
// ('src ' = srcA), as a QuickTime effect description does. The original's
// effect image description (MakeImageDescriptionForEffect) has no use now.
- (id)initWithName:(id)aName
{
    if (!(self = [super init]))
        return nil;
    _effectDescription = [[[[self class] effectsDescription] objectForKey:aName] retain];
    if (_effectDescription != nil && HSQTNewAtomContainer((HSQTAtomContainer *)&_effectDesc) == noErr) {
        // Fix: the original stored the type in host (little-endian) order;
        // atom data is big-endian like the source atom below.
        OSType what = CFSwapInt32HostToBig([[_effectDescription objectForKey:HSAttributeEffectAtomType] unsignedIntValue]);
        OSType source = CFSwapInt32HostToBig('srcA');
        if (HSQTInsertChild((HSQTAtomContainer)_effectDesc, kHSQTParentAtomIsContainer, 'what', 1, 0, 4, &what, NULL) == noErr
            && HSQTInsertChild((HSQTAtomContainer)_effectDesc, kHSQTParentAtomIsContainer, 'src ', 1, 0, 4, &source, NULL) == noErr)
            return self;
    }
    [self release];
    return nil;
}

@end
