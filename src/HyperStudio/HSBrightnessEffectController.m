#import "HSBrightnessEffectController.h"

static float HSValueFromSlider(float aSlider, float aMin, float aMax, float aDefault)
{
    if (aSlider == 0.0f)
        return aDefault;
    if (aSlider >= 0.0f)
        return aDefault + (aMax - aDefault) * aSlider;
    return aDefault + (aMin - aDefault) * (0.0f - aSlider);
}

static float HSSliderFromValue(float aValue, float aMin, float aMax, float aDefault)
{
    if (aDefault == aValue)
        return 0.0f;
    if (aDefault <= aValue)
        return (aValue - aDefault) / (aMax - aDefault) + 0.0f;
    return -(aDefault - aValue) / (aDefault - aMin) + 0.0f;
}

@implementation HSBrightnessEffectController

+ (id)createEffect
{
    return [[HSEffect effectWithName:@"CIColorControls"] retain];
}

// Sliders run -1...1 around the filter's default, scaled separately toward its minimum and maximum.
- (void)saturationDidChange:(id)aChange
{
    [self setSaturation:HSValueFromSlider([aChange floatValue], _minSaturationValue, _maxSaturationValue, _defaultSaturationValue)];
}

- (void)contrastDidChange:(id)aChange
{
    [self setContrast:HSValueFromSlider([aChange floatValue], _minContrastValue, _maxContrastValue, _defaultContrastValue)];
}

- (void)brightnessDidChange:(id)aChange
{
    [self setBrightness:HSValueFromSlider([aChange floatValue], _minBrightnessValue, _maxBrightnessValue, _defaultBrightnessValue)];
}

- (void)didLoadNib
{
    NSDictionary *attributes = [[self effect] attributes];
    NSDictionary *brightness = [attributes objectForKey:@"inputBrightness"];
    _minBrightnessValue = [[brightness objectForKey:kCIAttributeSliderMin] floatValue];
    _maxBrightnessValue = [[brightness objectForKey:kCIAttributeSliderMax] floatValue];
    _defaultBrightnessValue = [[brightness objectForKey:kCIAttributeDefault] floatValue];
    NSDictionary *saturation = [attributes objectForKey:@"inputSaturation"];
    _minSaturationValue = [[saturation objectForKey:kCIAttributeSliderMin] floatValue];
    _maxSaturationValue = [[saturation objectForKey:kCIAttributeSliderMax] floatValue];
    _defaultSaturationValue = [[saturation objectForKey:kCIAttributeDefault] floatValue];
    NSDictionary *contrast = [attributes objectForKey:@"inputContrast"];
    _minContrastValue = [[contrast objectForKey:kCIAttributeSliderMin] floatValue];
    _maxContrastValue = [[contrast objectForKey:kCIAttributeSliderMax] floatValue];
    _defaultContrastValue = [[contrast objectForKey:kCIAttributeDefault] floatValue];
    [super didLoadNib];
}

- (void)revertSettingsToDefault
{
    [[self effect] setDefaults];
    [_brightnessSlider setFloatValue:HSSliderFromValue([self brightness], _minBrightnessValue, _maxBrightnessValue, _defaultBrightnessValue)];
    [_saturationSlider setFloatValue:HSSliderFromValue([self saturation], _minSaturationValue, _maxSaturationValue, _defaultSaturationValue)];
    [_contrastSlider setFloatValue:HSSliderFromValue([self contrast], _minContrastValue, _maxContrastValue, _defaultContrastValue)];
    [self update];
}

- (CGFloat)contrast
{
    return [[[self effect] valueForKey:@"inputContrast"] floatValue];
}

- (void)setContrast:(CGFloat)aContrast
{
    [[self effect] setValue:[NSNumber numberWithFloat:aContrast] forKey:@"inputContrast"];
    [self update];
}

- (CGFloat)saturation
{
    return [[[self effect] valueForKey:@"inputSaturation"] floatValue];
}

- (void)setSaturation:(CGFloat)aSaturation
{
    [[self effect] setValue:[NSNumber numberWithFloat:aSaturation] forKey:@"inputSaturation"];
    [self update];
}

- (CGFloat)brightness
{
    return [[[self effect] valueForKey:@"inputBrightness"] floatValue];
}

- (void)setBrightness:(CGFloat)aBrightness
{
    [[self effect] setValue:[NSNumber numberWithFloat:aBrightness] forKey:@"inputBrightness"];
    [self update];
}

- (id)undoActionName
{
    NSString *name = [[NSBundle mainBundle] localizedStringForKey:@"Brightness/Contrast" value:@"" table:@"UndoManager"];
    return [NSString stringWithFormat:[[NSBundle mainBundle] localizedStringForKey:@"ApplyGraphicEffect" value:@"" table:@"UndoManager"], name];
}

- (id)nibName
{
    return @"BrightnessEffectController";
}

@end
