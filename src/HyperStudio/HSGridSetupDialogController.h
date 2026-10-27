#import "HyperStudioPrefix.h"


@interface HSGridSetupDialogController : HSGenericModalController
{
    NSButton *_displayCheckBox;
    NSButton *_snapToGridCheckBox;
    NSTextField *_horizontalSpacing;
    NSTextField *_verticalSpacing;
    NSMatrix *_gridMarkStyleMatrix;
    HSGradientColorWell *_gridColorWell;
    HSLayoutGridPreview *_gridPreview;
    NSStepper *_verticalStepper;
    NSStepper *_horizontalStepper;
    HSEditObjectDialogContext *_context;
}
- (void)resetToDefaults:(id)aDefaults;
- (void)verticalSpacingDidChange:(id)aChange;
- (void)horizontalSpacingDidChange:(id)aChange;
- (void)settingsDidChange:(id)aChange;
- (void)setupUIElementsWithGridSettings:(id)aSettings;
- (void)applyChanges;
- (BOOL)areSpacingFieldsValid;
- (void)ok:(id)aOk;
- (void)willShowWindow;
- (void)applySettingsTo:(id)aTo;
- (void)dealloc;
- (id)initWithContext:(id)aContext;
- (id)nibName;
@end

