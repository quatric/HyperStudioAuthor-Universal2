#import "HSEditorZoomController.h"

static const float HSEditorZoomFactors[] = { 0.1f, 0.17f, 0.25f, 0.375f, 0.5f, 0.75f, 1.0f, 1.25f, 1.5f, 1.75f, 2.0f, 3.0f, 4.0f, 5.0f, 6.0f, 7.0f, 8.0f };

@implementation HSEditorZoomController

+ (BOOL)canZoomToActualSizeForZoomFactor:(CGFloat)aFactor
{
    float factor = aFactor;
    float actual = [self actualZoomFactor];
    float scale = MAX(factor != 0.0f ? fabsf(factor) : 1.0f, actual != 0.0f ? fabsf(actual) : 1.0f);
    return fabsf(factor - actual) > scale * 0.0005f;
}

+ (BOOL)canZoomInForZoomFactor:(CGFloat)aFactor
{
    float zoomIn = 0.0f;
    [self nextZoomOutFactor:NULL zoomInFactor:&zoomIn forZoomFactor:aFactor];
    return !isnan(zoomIn);
}

+ (BOOL)canZoomOutForZoomFactor:(CGFloat)aFactor
{
    float zoomOut = 0.0f;
    [self nextZoomOutFactor:&zoomOut zoomInFactor:NULL forZoomFactor:aFactor];
    return !isnan(zoomOut);
}

+ (CGFloat)zoomFactorValueFrom:(id)aFrom
{
    float minFactor = [self minZoomFactor];
    float maxFactor = [self maxZoomFactor];
    int percent = (int)roundf(HSNonLinearValueForSlider(aFrom) * 100.0f);
    if ((unsigned)(percent - 97) <= 7)
        percent = 100;
    if (percent < 400)
        percent = (percent / 5 + (percent % 5 > 2)) * 5;
    else
        percent = (percent / 100 + (percent % 100 > 50)) * 100;
    float factor = MAX(minFactor, percent * 0.01f);
    return MIN(maxFactor, factor);
}

+ (CGFloat)actualZoomFactor
{
    return 1.0;
}

+ (CGFloat)maxZoomFactor
{
    return 8.0;
}

+ (CGFloat)minZoomFactor
{
    return 0.1f;
}

+ (void)nextZoomOutFactor:(float *)aFactor zoomInFactor:(float *)aFactor2 forZoomFactor:(CGFloat)aFactor3
{
    float factor = aFactor3;
    float zoomOut, zoomIn;
    NSUInteger count = sizeof(HSEditorZoomFactors) / sizeof(HSEditorZoomFactors[0]);
    if (fabsf(factor - 0.1f) <= 0.0049f) {
        zoomOut = NAN;
        zoomIn = 0.17f;
    } else if (factor < 0.1f) {
        zoomOut = NAN;
        zoomIn = 0.1f;
    } else if (fabsf(factor - 8.0f) <= 0.0049f) {
        zoomOut = 7.0f;
        zoomIn = NAN;
    } else if (factor > 8.0f) {
        zoomOut = 8.0f;
        zoomIn = NAN;
    } else {
        // The original binary-searches the table; a linear scan finds the same neighbours.
        NSUInteger i = 1;
        while (i < count - 1 && fabsf(factor - HSEditorZoomFactors[i]) > 0.0049f && factor > HSEditorZoomFactors[i])
            i++;
        if (fabsf(factor - HSEditorZoomFactors[i]) <= 0.0049f) {
            zoomOut = HSEditorZoomFactors[i - 1];
            zoomIn = HSEditorZoomFactors[i + 1];
        } else {
            zoomOut = HSEditorZoomFactors[i - 1];
            zoomIn = HSEditorZoomFactors[i];
        }
    }
    if (aFactor != NULL)
        *aFactor = zoomOut;
    if (aFactor2 != NULL)
        *aFactor2 = zoomIn;
}

@end
