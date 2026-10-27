// Removing a colour from 32-bit bitmaps (a movie's or an image's
// "transparent colour"): matching pixels become clear.
//
// The original has one copy of each loop per byte order; here one loop takes
// the byte offsets of the components. ARGB is a,r,g,b in memory; BGRA is
// b,g,r,a.
#import "HSFunctions.h"

typedef struct {
    unsigned char a, r, g, b;
} HSPixelLayout;

static const HSPixelLayout HSPixelLayoutARGB = {0, 1, 2, 3};
static const HSPixelLayout HSPixelLayoutBGRA = {3, 2, 1, 0};

// HS8BitMultiplicationTable / HS8BitDemultiplicationTable of the original are
// tables of rows; these compute the same values (checked against the binary's
// tables). A demultiplied component above its alpha (invalid premultiplied
// data) is clamped to 255.
static inline unsigned HSPremultiply(unsigned aValue, unsigned aAlpha)
{
    return (aValue * aAlpha + 127) / 255;
}

static inline unsigned HSDemultiply(unsigned aValue, unsigned aAlpha)
{
    unsigned value = (aValue * 255 + aAlpha / 2) / aAlpha;
    return value > 255 ? 255 : value;
}

// The hue of the HSL-tolerance comparison: not divided by the chroma, so
// 0...1530 with 255 per sector of the colour wheel.
static unsigned HSRoughHue(unsigned aRed, unsigned aGreen, unsigned aBlue, unsigned aMax, unsigned aMin)
{
    if (aMax == aMin)
        return 0;
    if (aMax == aGreen)
        return aBlue + 510 - aRed;
    if (aMax == aBlue)
        return aRed + 1020 - aGreen;
    return aGreen < aBlue ? aGreen + 1530 - aBlue : aGreen - aBlue;
}

// Copies the source into the (premultiplied) destination, clearing pixels
// that are transparent, exactly the colour, or within all three tolerances of
// it (hue, chroma = max − min, lightness = (max + min) / 2, each as a 0...1
// fraction of 255). All tolerances at 1 clear everything; all at 0 clear only
// the exact colour.
static void HSBitmapCopyRemovingColor(void *aDestination, size_t aDestinationRowBytes, HSPixelLayout aDestinationLayout,
                                      const void *aSource, size_t aSourceRowBytes, HSPixelLayout aSourceLayout, BOOL aSourcePremultiplied,
                                      size_t aWidth, size_t aHeight, UInt8 aRed, UInt8 aGreen, UInt8 aBlue,
                                      float aHueTolerance, float aChromaTolerance, float aLightnessTolerance)
{
    UInt8 lightnessTolerance = (UInt8)lroundf(aLightnessTolerance * 255);
    UInt8 chromaTolerance = (UInt8)lroundf(aChromaTolerance * 255);
    UInt8 hueTolerance = (UInt8)lroundf(aHueTolerance * 255);
    if (hueTolerance == 255 && chromaTolerance == 255 && lightnessTolerance == 255) {
        memset(aDestination, 0, aHeight * aDestinationRowBytes);
        return;
    }
    BOOL exactOnly = hueTolerance == 0 && chromaTolerance == 0 && lightnessTolerance == 0;
    unsigned targetMax = MAX(MAX(aRed, aGreen), aBlue);
    unsigned targetMin = MIN(MIN(aRed, aGreen), aBlue);
    unsigned targetChroma = targetMax - targetMin;
    unsigned targetLightness = (targetMax + targetMin) >> 1;
    unsigned targetHue = HSRoughHue(aRed, aGreen, aBlue, targetMax, targetMin);
    for (size_t y = 0; y < aHeight; y++) {
        const UInt8 *source = (const UInt8 *)aSource + y * aSourceRowBytes;
        UInt8 *destination = (UInt8 *)aDestination + y * aDestinationRowBytes;
        for (size_t x = 0; x < aWidth; x++, source += 4, destination += 4) {
            unsigned alpha = source[aSourceLayout.a];
            unsigned red = source[aSourceLayout.r], green = source[aSourceLayout.g], blue = source[aSourceLayout.b];
            if (aSourcePremultiplied && alpha != 0 && alpha != 255) {
                red = HSDemultiply(red, alpha);
                green = HSDemultiply(green, alpha);
                blue = HSDemultiply(blue, alpha);
            }
            BOOL clear = alpha == 0 || (red == aRed && green == aGreen && blue == aBlue);
            if (!clear && !exactOnly) {
                unsigned max = MAX(MAX(red, green), blue);
                unsigned min = MIN(MIN(red, green), blue);
                unsigned hueDifference = 0;
                if (max != min && targetMax != targetMin) {
                    unsigned hue = HSRoughHue(red, green, blue, max, min);
                    unsigned difference = targetHue > hue ? targetHue - hue : hue - targetHue;
                    if (difference >= 766)
                        difference = 1530 - difference;
                    hueDifference = difference > 255 ? 255 : difference;
                }
                unsigned lightness = (max + min) >> 1;
                unsigned lightnessDifference = lightness > targetLightness ? lightness - targetLightness : targetLightness - lightness;
                unsigned chroma = max - min;
                unsigned chromaDifference = chroma > targetChroma ? chroma - targetChroma : targetChroma - chroma;
                clear = hueDifference <= hueTolerance && chromaDifference <= chromaTolerance && lightnessDifference <= lightnessTolerance;
            }
            if (clear) {
                memset(destination, 0, 4);
            } else if (aSourcePremultiplied) {
                destination[aDestinationLayout.a] = source[aSourceLayout.a];
                destination[aDestinationLayout.r] = source[aSourceLayout.r];
                destination[aDestinationLayout.g] = source[aSourceLayout.g];
                destination[aDestinationLayout.b] = source[aSourceLayout.b];
            } else {
                destination[aDestinationLayout.a] = alpha;
                destination[aDestinationLayout.r] = HSPremultiply(red, alpha);
                destination[aDestinationLayout.g] = HSPremultiply(green, alpha);
                destination[aDestinationLayout.b] = HSPremultiply(blue, alpha);
            }
        }
    }
}

void HSBitmapBGRA8888PremultipliedCopyRemovingColorFromARGB8888(void *aDestination, size_t aDestinationRowBytes, const void *aSource, size_t aSourceRowBytes, size_t aWidth, size_t aHeight, UInt8 aRed, UInt8 aGreen, UInt8 aBlue, float aHueTolerance, float aChromaTolerance, float aLightnessTolerance)
{
    HSBitmapCopyRemovingColor(aDestination, aDestinationRowBytes, HSPixelLayoutBGRA, aSource, aSourceRowBytes, HSPixelLayoutARGB, NO,
                              aWidth, aHeight, aRed, aGreen, aBlue, aHueTolerance, aChromaTolerance, aLightnessTolerance);
}

void HSBitmapBGRA8888PremultipliedCopyRemovingColorFromBGRA8888(void *aDestination, size_t aDestinationRowBytes, const void *aSource, size_t aSourceRowBytes, size_t aWidth, size_t aHeight, UInt8 aRed, UInt8 aGreen, UInt8 aBlue, float aHueTolerance, float aChromaTolerance, float aLightnessTolerance)
{
    HSBitmapCopyRemovingColor(aDestination, aDestinationRowBytes, HSPixelLayoutBGRA, aSource, aSourceRowBytes, HSPixelLayoutBGRA, NO,
                              aWidth, aHeight, aRed, aGreen, aBlue, aHueTolerance, aChromaTolerance, aLightnessTolerance);
}

void HSBitmapARGB8888PremultipliedCopyRemovingColorFromBGRA8888(void *aDestination, size_t aDestinationRowBytes, const void *aSource, size_t aSourceRowBytes, size_t aWidth, size_t aHeight, UInt8 aRed, UInt8 aGreen, UInt8 aBlue, float aHueTolerance, float aChromaTolerance, float aLightnessTolerance)
{
    HSBitmapCopyRemovingColor(aDestination, aDestinationRowBytes, HSPixelLayoutARGB, aSource, aSourceRowBytes, HSPixelLayoutBGRA, NO,
                              aWidth, aHeight, aRed, aGreen, aBlue, aHueTolerance, aChromaTolerance, aLightnessTolerance);
}

void HSBitmapARGB8888PremultipliedCopyRemovingColorFromARGB8888(void *aDestination, size_t aDestinationRowBytes, const void *aSource, size_t aSourceRowBytes, size_t aWidth, size_t aHeight, UInt8 aRed, UInt8 aGreen, UInt8 aBlue, float aHueTolerance, float aChromaTolerance, float aLightnessTolerance)
{
    HSBitmapCopyRemovingColor(aDestination, aDestinationRowBytes, HSPixelLayoutARGB, aSource, aSourceRowBytes, HSPixelLayoutARGB, NO,
                              aWidth, aHeight, aRed, aGreen, aBlue, aHueTolerance, aChromaTolerance, aLightnessTolerance);
}

void HSBitmapBGRA8888PremultipliedCopyRemovingColorFromARGB8888Premultiplied(void *aDestination, size_t aDestinationRowBytes, const void *aSource, size_t aSourceRowBytes, size_t aWidth, size_t aHeight, UInt8 aRed, UInt8 aGreen, UInt8 aBlue, float aHueTolerance, float aChromaTolerance, float aLightnessTolerance)
{
    HSBitmapCopyRemovingColor(aDestination, aDestinationRowBytes, HSPixelLayoutBGRA, aSource, aSourceRowBytes, HSPixelLayoutARGB, YES,
                              aWidth, aHeight, aRed, aGreen, aBlue, aHueTolerance, aChromaTolerance, aLightnessTolerance);
}

void HSBitmapBGRA8888PremultipliedCopyRemovingColorFromBGRA8888Premultiplied(void *aDestination, size_t aDestinationRowBytes, const void *aSource, size_t aSourceRowBytes, size_t aWidth, size_t aHeight, UInt8 aRed, UInt8 aGreen, UInt8 aBlue, float aHueTolerance, float aChromaTolerance, float aLightnessTolerance)
{
    HSBitmapCopyRemovingColor(aDestination, aDestinationRowBytes, HSPixelLayoutBGRA, aSource, aSourceRowBytes, HSPixelLayoutBGRA, YES,
                              aWidth, aHeight, aRed, aGreen, aBlue, aHueTolerance, aChromaTolerance, aLightnessTolerance);
}

void HSBitmapARGB8888PremultipliedCopyRemovingColorFromBGRA8888Premultiplied(void *aDestination, size_t aDestinationRowBytes, const void *aSource, size_t aSourceRowBytes, size_t aWidth, size_t aHeight, UInt8 aRed, UInt8 aGreen, UInt8 aBlue, float aHueTolerance, float aChromaTolerance, float aLightnessTolerance)
{
    HSBitmapCopyRemovingColor(aDestination, aDestinationRowBytes, HSPixelLayoutARGB, aSource, aSourceRowBytes, HSPixelLayoutBGRA, YES,
                              aWidth, aHeight, aRed, aGreen, aBlue, aHueTolerance, aChromaTolerance, aLightnessTolerance);
}

void HSBitmapARGB8888PremultipliedCopyRemovingColorFromARGB8888Premultiplied(void *aDestination, size_t aDestinationRowBytes, const void *aSource, size_t aSourceRowBytes, size_t aWidth, size_t aHeight, UInt8 aRed, UInt8 aGreen, UInt8 aBlue, float aHueTolerance, float aChromaTolerance, float aLightnessTolerance)
{
    HSBitmapCopyRemovingColor(aDestination, aDestinationRowBytes, HSPixelLayoutARGB, aSource, aSourceRowBytes, HSPixelLayoutARGB, YES,
                              aWidth, aHeight, aRed, aGreen, aBlue, aHueTolerance, aChromaTolerance, aLightnessTolerance);
}

// The scaled hue of the in-place removal: 0...6·chroma.
static int HSScaledHue(int aRed, int aGreen, int aBlue, int aMax, int aMin)
{
    int chroma = aMax - aMin;
    if (chroma == 0)
        return 0;
    if (aMax == aGreen)
        return aBlue - aRed + chroma * 2;
    if (aMax == aBlue)
        return aRed - aGreen + chroma * 4;
    return aGreen < aBlue ? chroma * 6 + aGreen - aBlue : aGreen - aBlue;
}

// Clears, in place, the pixels of a premultiplied bitmap whose colour is
// within the tolerance (0...1) of the given one. The distance is (Δchroma)²·¾
// + (Δlightness)² + (hue distance in sectors, at most 1)²·chroma·chroma′; as in
// the original the sum is truncated to 16 bits before it's compared.
static void HSBitmapRemoveColor(void *aPixels, size_t aWidth, size_t aHeight, size_t aRowBytes, HSPixelLayout aLayout,
                                UInt8 aRed, UInt8 aGreen, UInt8 aBlue, float aTolerance)
{
    uint32_t tolerance = (uint32_t)lround((double)aTolerance * (double)aTolerance * 255.0 * 255.0);
    int targetMax = MAX(MAX(aRed, aGreen), aBlue);
    int targetMin = MIN(MIN(aRed, aGreen), aBlue);
    int targetChroma = targetMax - targetMin;
    int targetHue = HSScaledHue(aRed, aGreen, aBlue, targetMax, targetMin);
    for (size_t y = 0; y < aHeight; y++) {
        UInt8 *pixel = (UInt8 *)aPixels + y * aRowBytes;
        for (size_t x = 0; x < aWidth; x++, pixel += 4) {
            unsigned alpha = pixel[aLayout.a];
            if (alpha == 0)
                continue;
            int red = pixel[aLayout.r], green = pixel[aLayout.g], blue = pixel[aLayout.b];
            if (alpha != 255) {
                red = HSDemultiply(red, alpha);
                green = HSDemultiply(green, alpha);
                blue = HSDemultiply(blue, alpha);
            }
            if (red != aRed || green != aGreen || blue != aBlue) {
                int max = MAX(MAX(red, green), blue);
                int min = MIN(MIN(red, green), blue);
                int chroma = max - min;
                uint32_t hueTerm = 0;
                if (chroma != 0 && targetChroma != 0) {
                    int hue = HSScaledHue(red, green, blue, max, min);
                    uint32_t a = (uint32_t)(chroma * targetHue), b = (uint32_t)(hue * targetChroma);
                    uint32_t difference = a > b ? a - b : b - a;
                    uint32_t unit = (uint32_t)(chroma * targetChroma);
                    uint32_t distance = difference;
                    if (unit < difference) {
                        distance = unit;
                        if (unit * 5 < difference)
                            distance = unit * 6 - difference;
                    }
                    hueTerm = distance * distance / unit;
                }
                int lightness = (max + min) - (targetMin + targetMax);
                uint32_t sum = ((uint32_t)((chroma - targetChroma) * (chroma - targetChroma) * 3) >> 2)
                    + ((uint32_t)(lightness * lightness) >> 2) + hueTerm;
                if (tolerance < (sum & 0xffff))
                    continue;
            }
            memset(pixel, 0, 4);
        }
    }
}

void HSBitmapARGB8888PremultipliedRemoveColor(void *aPixels, size_t aWidth, size_t aHeight, size_t aRowBytes, UInt8 aRed, UInt8 aGreen, UInt8 aBlue, float aTolerance)
{
    HSBitmapRemoveColor(aPixels, aWidth, aHeight, aRowBytes, HSPixelLayoutARGB, aRed, aGreen, aBlue, aTolerance);
}

void HSBitmapBGRA8888PremultipliedRemoveColor(void *aPixels, size_t aWidth, size_t aHeight, size_t aRowBytes, UInt8 aRed, UInt8 aGreen, UInt8 aBlue, float aTolerance)
{
    HSBitmapRemoveColor(aPixels, aWidth, aHeight, aRowBytes, HSPixelLayoutBGRA, aRed, aGreen, aBlue, aTolerance);
}
