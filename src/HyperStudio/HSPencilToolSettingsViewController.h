#import "HyperStudioPrefix.h"
#import "HSToolSettingsViewController.h"


@interface HSPencilToolSettingsViewController : HSToolSettingsViewController <HSToolPaletteColorViewControllerDelegate, NSObject>
{
    NSView *_colorContainerView;
    HSToolPaletteColorViewController *_colorViewController;
    NSSlider *_pencilWidthSlider;
    NSImageView *_previewView;
    HSPseudoImageView *_pseudoImageView;
    NSBezierPath *_previewPath;
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
- (id)pencilTool;
- (void)didLoadNib;
- (id)nibName;
- (void)dealloc;
@end

