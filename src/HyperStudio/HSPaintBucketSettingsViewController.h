#import "HyperStudioPrefix.h"
#import "HSToolSettingsViewController.h"


@interface HSPaintBucketSettingsViewController : HSToolSettingsViewController <HSToolPaletteColorViewControllerDelegate, NSObject>
{
    NSView *_colorContainerView;
    HSToolPaletteColorViewController *_colorViewController;
    NSSlider *_tolerenceSlider;
}
- (void)actionToleranceChanged:(id)aChanged;
- (id)colorPickingController;
- (void)colorViewController:(id)aController changedColorTo:(id)aTo;
- (BOOL)shouldDisplayGradientsAndPattersForColorViewController:(id)aController;
- (void)validateUserInterface;
- (void)updateBrushColor;
- (void)updateUI;
- (void)didMount;
- (void)didLoadNib;
- (id)nibName;
- (void)dealloc;
@end

