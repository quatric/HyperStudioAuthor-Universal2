#import "HyperStudioPrefix.h"
#import "HSToolSettingsViewController.h"


@interface HSDrawShapeToolSettingsViewController : HSToolSettingsViewController <HSToolPaletteColorViewControllerDelegate, NSObject>
{
    HSSegmentedControl *_shapeTypeControl;
    NSView *_outlineSettingsView;
    NSView *_fillSettingsView;
    HSCustomTabView *_fillAndOutlineSettingsTabView;
    NSView *_fillSettingsTabSubView;
    NSView *_outlineSettingsTabSubView;
    float _tabHeights[2];
    NSView *_currentSettingsView;
    BOOL _isUIValidationDisabled;
    HSToolPaletteColorViewController *_outlineColorViewController;
    NSView *_outlineColorContainerView;
    HSToolPaletteColorViewController *_fillColorViewController;
    NSView *_fillColorContainerView;
    HSToolPaletteColorViewController *_outlinWithFillColorViewController;
    NSView *_outlineWithFillColorContainerView;
    HSToolPaletteColorViewController *_fillWithOutlineColorViewController;
    NSView *_fillWithOutlineColorContainerView;
    NSSlider *_outlineWidthSlider;
    NSSlider *_outlineWithFillWidthSlider;
    NSImageView *_outlinePreview;
    NSImageView *_fillWithOutlinePreview;
    NSImageView *_outlineWithFillPreview;
    NSView *_cornerSettingsView;
    NSSlider *_cornerRadiusSlider;
    NSView *_containerView;
}
- (id)colorPickingController;
- (NSUInteger)tagForSettingsView:(id)aView;
- (id)prototypePathForPreviewWithFrame:(NSRect)aFrame;
- (void)validateBackgroundColor;
- (void)refreshPreviews;
- (void)refreshToolPreview:(id)aPreview;
- (void)updateLineWidthUIElements;
- (void)updateFillColorUIElements;
- (void)updateOutlineColorUIElements;
- (void)updateCurrentSettingsViewWithParentResize:(BOOL)aResize;
- (void)toolSettingsDidChange:(id)aChange;
- (void)selectedTabDidChangeInCustomTabView:(id)aView;
- (void)colorViewController:(id)aController changedColorTo:(id)aTo;
- (BOOL)shouldDisplayGradientsAndPattersForColorViewController:(id)aController;
- (void)cornerRadiusChanged:(id)aChanged;
- (void)lineWidthChanged:(id)aChanged;
- (void)fillAndOutlineShapeTypeChosen:(id)aChosen;
- (void)fillShapeTypeChosen:(id)aChosen;
- (void)outlineShapeTypeChosen:(id)aChosen;
- (void)validateUserInterface;
- (void)updateUI;
- (void)didMount;
- (void)willMount;
- (void)didLoadNib;
- (id)nibName;
- (void)cornerRadiusSliderChangedValueTo:(CGFloat)aTo;
- (id)accessibilitySliderDescriptionValue;
- (id)shapeTypeControlFillWithOutlineImage;
- (id)shapeTypeControlFillImage;
- (id)shapeTypeControlOutlineImage;
- (void)dealloc;
@end

