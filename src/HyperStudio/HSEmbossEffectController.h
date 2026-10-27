#import "HyperStudioPrefix.h"
#import "HSEffectCompositeController.h"


@interface HSEmbossEffectController : HSEffectCompositeController
{
    NSSlider *_reliefSlider;
    NSButton *_grayscaleSwitch;
}
+ (id)createEffect;
- (void)grayscaleDidChange:(id)aChange;
- (void)reliefDidChange:(id)aChange;
- (void)didLoadNib;
- (void)revertSettingsToDefault;
- (BOOL)isColorized;
- (void)setColorized:(BOOL)aColorized;
- (CGFloat)reliefValue;
- (void)setReliefValue:(CGFloat)aValue;
- (id)undoActionName;
- (id)nibName;
@end

