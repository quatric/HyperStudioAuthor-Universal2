#import "HyperStudioPrefix.h"
#import "HSEffectCompositeController.h"


@interface HSBrightnessEffectController : HSEffectCompositeController
{
    NSSlider *_brightnessSlider;
    NSSlider *_contrastSlider;
    NSSlider *_saturationSlider;
    float _minBrightnessValue;
    float _minSaturationValue;
    float _minContrastValue;
    float _maxBrightnessValue;
    float _maxSaturationValue;
    float _maxContrastValue;
    float _defaultBrightnessValue;
    float _defaultSaturationValue;
    float _defaultContrastValue;
}
+ (id)createEffect;
- (void)saturationDidChange:(id)aChange;
- (void)contrastDidChange:(id)aChange;
- (void)brightnessDidChange:(id)aChange;
- (void)didLoadNib;
- (void)revertSettingsToDefault;
- (CGFloat)contrast;
- (void)setContrast:(CGFloat)aContrast;
- (CGFloat)saturation;
- (void)setSaturation:(CGFloat)aSaturation;
- (CGFloat)brightness;
- (void)setBrightness:(CGFloat)aBrightness;
- (id)undoActionName;
- (id)nibName;
@end

