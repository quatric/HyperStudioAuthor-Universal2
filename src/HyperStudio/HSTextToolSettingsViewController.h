#import "HyperStudioPrefix.h"
#import "HSToolSettingsViewController.h"


@interface HSTextToolSettingsViewController : HSToolSettingsViewController <HSToolPaletteColorViewControllerDelegate, NSObject>
{
    NSComboBox *_fontComboBox;
    NSComboBox *_fontSizeComboBox;
    HSSegmentedControl *_fontStyleMatrix;
    HSSegmentedControl *_alignmentMatrix;
    NSTextField *_characterSpaceField;
    NSStepper *_characterSpaceStepper;
    HSUserObjectInPlayerPreviewView *_formatPreview;
    NSView *_colorContainerView;
    HSToolPaletteColorViewController *_colorViewController;
    HSUserObjectInPlayerPreviewView *_outlinePreview;
    NSView *_outlineColorContainerView;
    HSToolPaletteColorViewController *_outlineColorViewController;
    HSSegmentedControl *_outlineMatrix;
    NSButton *_shadowSwitch;
    NSSlider *_offsetSlider;
    NSSlider *_blurSlider;
    NSControl *_angleSlider;
    NSTextField *_angleField;
    HSUserObjectInPlayerPreviewView *_shadowPreview;
    HSCustomTabView *_tabView;
    NSView *_formatView;
    NSView *_outlineView;
    NSView *_shadowView;
    float _characterSpaceValue;
    float _tabHeights[3];
    HSFontComboboxDataSource *_dataSource;
    NSTimer *_fontSizeApplierTimer;
    HSPreviewTextObject *_previewTextObject;
}
+ (id)availableFontSizes;
- (void)selectedTabDidChangeInCustomTabView:(id)aView;
- (void)comboBoxDataChanged:(id)aChanged;
- (void)comboBoxWillDismiss:(id)aDismiss;
- (void)controlTextDidEndEditing:(id)aEditing;
- (void)comboBoxSelectionDidChange:(id)aChange;
- (void)controlTextDidChange:(id)aChange;
- (void)setFontSize:(CGFloat)aSize;
- (void)applyFontSizeValue;
- (void)invalidateFontSizeApplierTimer;
- (void)setFontSizeApplierTimer;
- (id)colorPickingController;
- (void)colorViewController:(id)aController changedColorTo:(id)aTo;
- (BOOL)shouldDisplayGradientsAndPattersForColorViewController:(id)aController;
- (void)shadowAngleChanged:(id)aChanged;
- (void)blurChanged:(id)aChanged;
- (void)offsetChanged:(id)aChanged;
- (void)enableShadowControls:(BOOL)aControls;
- (void)shadowEnabled:(id)aEnabled;
- (void)outlineChanged:(id)aChanged;
- (void)characterSpacingValueChanged:(id)aChanged;
- (void)setUnderline:(id)aUnderline;
- (void)setItalic:(id)aItalic;
- (void)setBold:(id)aBold;
- (void)alignmentChanged:(id)aChanged;
- (void)readjustCharacterSpacingValue;
- (void)validateBackgroundColor;
- (void)validateTextStyleMatrixState;
- (void)validateOutlineMatrix;
- (void)validateUI;
- (void)validateShadowUI;
- (void)validateShadowUIWithNotification:(id)aNotification;
- (void)validateUIWithNotification:(id)aNotification;
- (void)rebuildPreview;
- (void)loadFontSizeComboBox;
- (void)loadFontComboBox;
- (id)genericFontAttributes;
- (id)shadowAttributes;
- (id)textObjectAttributes;
- (id)previewTextObject;
- (id)primaryPrototypeObject;
- (id)prototypeObject;
- (void)validateUserInterface;
- (void)willUnMount;
- (void)didMount;
- (void)didLoadNib;
- (id)nibName;
- (void)dealloc;
@end

