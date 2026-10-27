#import "HyperStudioPrefix.h"
#import "HSActionAssistantSettingsApplier.h"
#import "HSNBAAssistantPane.h"


@interface HSShowMessageActionAssistantPane : HSNBAAssistantPane
{
    NSPopUpButton *_messageStylePopup;
    HSPlaceholderTextView *_messageTextView;
    NSTextField *_buttonTitleField;
    NSButton *_modalDialogSwitch;
    NSImageView *_messageIconView;
    HSImportDialogController *_importGraphicDialogController;
}
+ (id)createImageOfSize:(NSSize)aSize fromImage:(id)aImage resizeProportionally:(BOOL)aProportionally;
- (void)controlTextDidChange:(id)aChange;
- (void)messageIconChanged:(id)aChanged;
- (void)modalStateChanged:(id)aChanged;
- (void)messageTitleChanged:(id)aChanged;
- (void)messageStyleChanged:(id)aChanged;
- (void)validateMessageView;
- (void)validateUI;
- (void)validateUIWithNotification:(id)aNotification;
- (void)chooseMessageIcon:(id)aIcon;
- (id)importGraphicDialogController;
- (id)initialKeyView;
- (id)helpTopicKey;
- (void)paneDidOK:(id)aOK;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (id)actionAttribute;
- (id)actionType;
- (void)viewDidLoad;
- (id)actionAttributes;
- (id)showMessageActionAssistantPaneApplier;
- (Class)applierClass;
- (void)dealloc;
- (id)init;
@end

@interface HSShowMessageActionAssistantPaneApplier : HSActionAssistantSettingsApplier
{
    NSString *_initialMessageString;
    NSString *_initialButtonTitle;
    int _initialMessageStyle;
    BOOL _initialRunAsModalDialog;
    NSImage *_initialMessageIcon;
    NSString *_messageString;
    NSString *_buttonTitle;
    int _messageStyle;
    BOOL _runAsModalDialog;
    NSImage *_messageIcon;
}
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setMessageIcon:(id)aIcon;
- (void)setRunAsModalDialog:(BOOL)aDialog;
- (void)setMessageStyle:(NSInteger)aStyle;
- (void)setButtonTitle:(id)aTitle;
- (void)setMessageString:(id)aString;
- (void)setUpInitialSettings;
- (id)showMessageActionAttributes;
- (void)dealloc;
@end

