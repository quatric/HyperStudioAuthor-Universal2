#import "HyperStudioPrefix.h"
#import "HSToolSettingsViewController.h"


@interface HSEraserToolSettingsViewController : HSToolSettingsViewController <HSToolPaletteColorViewControllerDelegate, NSObject>
{
    NSView *_colorContainerView;
    HSToolPaletteColorViewController *_colorViewController;
    NSSlider *_eraserSizeSlider;
    BOOL _previousShouldShowsAlphaFlag;
}
- (void)actionEraseBackground:(id)aBackground;
- (id)colorPickingController;
- (void)colorViewController:(id)aController changedColorTo:(id)aTo;
- (BOOL)shouldDisplayGradientsAndPattersForColorViewController:(id)aController;
- (void)updateEraserSize;
- (void)eraserSizeChanged:(id)aChanged;
- (void)validateUserInterface;
- (void)updateUI;
- (void)willUnMount;
- (void)didMount;
- (id)eraserTool;
- (void)didLoadNib;
- (id)nibName;
- (void)dealloc;
@end

