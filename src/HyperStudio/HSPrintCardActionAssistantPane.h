#import "HyperStudioPrefix.h"
#import "HSActionAssistantSettingsApplier.h"
#import "HSNBAAssistantPane.h"


@interface HSPrintCardActionAssistantPane : HSNBAAssistantPane
{
    NSButton *_printDialogCheckBox;
    NSButton *_pageSetupDialogCheckBox;
    NSButton *_centerPrintoutCheckBox;
}
- (void)updateCheckboxes;
- (id)actionType;
- (void)validateUIWithNotification:(id)aNotification;
- (void)centerPrintoutCheckBoxStateChanged:(id)aChanged;
- (void)pageSetupDialogCheckBoxStateChanged:(id)aChanged;
- (void)printDialogCheckBoxStateChanged:(id)aChanged;
- (id)initialKeyView;
- (id)helpTopicKey;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (id)actionAttribute;
- (id)actionAttributes;
- (id)printCardActionAssistantPaneApplier;
- (Class)applierClass;
- (id)init;
@end

@interface HSPrintCardActionAssistantPaneApplier : HSActionAssistantSettingsApplier
{
    BOOL _initialNeedsShowPageSetupDialog;
    BOOL _initialNeedsShowPrintDialog;
    BOOL _initialNeedsCenterPrintout;
    BOOL _needsShowPageSetupDialog;
    BOOL _needsShowPrintDialog;
    BOOL _needsCenterPrintout;
}
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setCenterPrintout:(BOOL)aPrintout;
- (void)setShowPrintDialog:(BOOL)aDialog;
- (void)setShowPageSetupDialog:(BOOL)aDialog;
- (void)setUpInitialSettings;
- (id)printCardActionAttributes;
@end

