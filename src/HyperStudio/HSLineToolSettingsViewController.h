#import "HyperStudioPrefix.h"
#import "HSToolSettingsViewController.h"


@interface HSLineToolSettingsViewController : HSToolSettingsViewController <HSToolPaletteColorViewControllerDelegate, NSObject>
{
    NSView *_colorContainerView;
    HSToolPaletteColorViewController *_colorViewController;
    NSSlider *_lineWidthSlider;
    NSImageView *_previewView;
    HSPseudoImageView *_pseudoImageView;
}
- (void)validateBackgroundColor;
- (void)updatePreview;
- (id)colorPickingController;
- (void)colorViewController:(id)aController changedColorTo:(id)aTo;
- (BOOL)shouldDisplayGradientsAndPattersForColorViewController:(id)aController;
- (void)lineWidthChanged:(id)aChanged;
- (void)validateUserInterface;
- (void)updateUI;
- (void)didMount;
- (id)lineTool;
- (void)didLoadNib;
- (id)nibName;
- (void)dealloc;
@end

