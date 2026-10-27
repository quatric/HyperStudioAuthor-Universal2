#import "HyperStudioPrefix.h"
#import "HSEffectCompositeController.h"


@interface HSReplaceColorsEffectController : HSEffectCompositeController
{
    NSMatrix *_effectMatrix;
    HSGradientColorWell *_replaceColorWell;
    HSGradientColorWell *_withColorWell;
    NSButton *_replaceColorPickerButton;
    NSButton *_withColorPickerButton;
    NSSlider *_toleranceSlider;
    NSButton *_ignoreTransparencySwitch;
}
+ (id)defaultWithColor;
+ (id)defaultReplaceColor;
+ (id)createEffect;
- (id)pickingCursor;
- (void)mouseDownInEffectImageAtColor:(id)aColor;
- (void)mouseDownInOriginalImageAtColor:(id)aColor;
- (void)ignoreTransparencyDidChange:(id)aChange;
- (void)toleranceDidChange:(id)aChange;
- (void)startWithColorPicking:(id)aPicking;
- (void)startReplaceColorPicking:(id)aPicking;
- (void)withColorDidChange:(id)aChange;
- (void)replaceColorDidChange:(id)aChange;
- (void)effectDidChange:(id)aChange;
- (void)applyChanges;
- (void)willUnmount;
- (void)willMount;
- (void)didLoadNib;
- (void)revertSettingsToDefault;
- (void)setColorsExchanged:(BOOL)aExchanged;
- (BOOL)isColorsExchanged;
- (void)setWithColor:(id)aColor;
- (void)setReplaceColor:(id)aColor;
- (void)setTransparencyIgnored:(BOOL)aIgnored;
- (BOOL)isTransparencyIgnored;
- (void)setTolerance:(CGFloat)aTolerance;
- (CGFloat)tolerance;
- (id)undoActionName;
- (id)nibName;
@end

