#import "HyperStudioPrefix.h"
#import "HSEffectCompositeController.h"


@interface HSBevelerEffectController : HSEffectCompositeController
{
    NSTextField *_widthTextField;
    NSButton *_roundedSwitch;
    NSButton *_raisedSwitch;
    NSStepper *_widthStepper;
}
+ (id)createEffect;
- (void)HSBevelerEffectController_setupWidthControls;
- (void)widthDidChange:(id)aChange;
- (BOOL)control:(id)aControl textShouldEndEditing:(id)aEditing;
- (void)raisedDidChange:(id)aChange;
- (void)roundedDidChange:(id)aChange;
- (void)updateSettingsBasedOnSwitchesState;
- (void)didLoadNib;
- (void)revertSettingsToDefault;
- (BOOL)isInversed;
- (void)setInversed:(BOOL)aInversed;
- (BOOL)isFlated;
- (void)setFlated:(BOOL)aFlated;
- (CGFloat)bevelWidth;
- (void)setBevelWidth:(CGFloat)aWidth;
- (void)setObject:(id)aObject;
- (id)undoActionName;
- (id)nibName;
@end

