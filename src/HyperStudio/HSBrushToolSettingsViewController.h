#import "HyperStudioPrefix.h"
#import "HSToolSettingsViewController.h"


@interface HSBrushToolSettingsViewController : HSToolSettingsViewController <HSToolPaletteColorViewControllerDelegate, NSObject>
{
    SMKGridControl *_gridControl;
    NSView *_colorContainerView;
    HSToolPaletteColorViewController *_colorViewController;
    NSSlider *_sizeSlider;
    NSImageView *_brushPreviewView;
    NSTextField *_nameField;
    HSPseudoImageView *_pseudoImageView;
    NSTableColumn *_settingsTitle;
    CGRect _brushRect;
    NSMutableDictionary *_previewPresets;
    unsigned int _currectToolIndex;
    BOOL _didFinishLoading;
}
- (void)selectionDidChangeInGridControl:(id)aControl;
- (id)gridControl:(id)aControl additionalInfoForItemAt:(NSInteger)aAt;
- (id)gridControl:(id)aControl imageForItemAt:(NSInteger)aAt;
- (id)gridControl:(id)aControl titleForItemAt:(NSInteger)aAt;
- (NSInteger)numberOfItemsInGridControl:(id)aControl;
- (Class)cellClass;
- (id)colorPickingController;
- (void)colorViewController:(id)aController changedColorTo:(id)aTo;
- (BOOL)shouldDisplayGradientsAndPattersForColorViewController:(id)aController;
- (void)brushSizeChanged:(id)aChanged;
- (void)validateBackgroundColor;
- (void)updateSelectedTemplate;
- (void)updateBrushColorIfNeeded;
- (void)refreshBrushPreview;
- (void)updateBrushSize;
- (void)updateUI;
- (id)currentPresetDictionary;
- (id)brushToolStorage;
- (id)brushTool;
- (void)didMount;
- (void)validateUserInterface;
- (void)didLoadNib;
- (id)nibName;
- (void)dealloc;
@end

