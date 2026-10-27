#import "HyperStudioPrefix.h"
#import "HSDrawShapeToolSettingsViewController.h"


@interface HSDrawRoundedRectToolSettingsViewController : HSDrawShapeToolSettingsViewController
{
}
- (void)cornerRadiusSliderChangedValueTo:(CGFloat)aTo;
- (id)accessibilitySliderDescriptionValue;
- (id)shapeTypeControlFillWithOutlineImage;
- (id)shapeTypeControlFillImage;
- (id)shapeTypeControlOutlineImage;
- (void)updateUI;
- (void)didLoadNib;
@end

