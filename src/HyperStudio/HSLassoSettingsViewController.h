#import "HyperStudioPrefix.h"
#import "HSToolSettingsViewController.h"


@interface HSLassoSettingsViewController : HSToolSettingsViewController
{
    NSSlider *_tolerenceSlider;
    HSSegmentedControl *_modeMatrix;
    BOOL _isLassoSelectionSimpleMode;
}
- (void)HSLassoSettingsViewController_selectAllArea:(id)aArea;
- (void)lassoSelectionPencilModeChanged:(id)aChanged;
- (void)lassoSelectionReverseModeChanged:(id)aChanged;
- (void)lassoSelectionSimpleModeChanged:(id)aChanged;
- (void)actionToleranceChanged:(id)aChanged;
- (void)validateUserInterface;
- (id)regionEditingTool;
- (void)didLoadNib;
- (void)didMount;
- (id)nibName;
@end

