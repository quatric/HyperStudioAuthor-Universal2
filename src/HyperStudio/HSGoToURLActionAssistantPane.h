#import "HyperStudioPrefix.h"
#import "HSActionAssistantPane.h"
#import "HSActionAssistantSettingsApplier.h"


@interface HSGoToURLActionAssistantPane : HSActionAssistantPane
{
    NSView *_webPageView;
    NSView *_mailView;
    NSView *_containerView;
    NSPopUpButton *_urlTypePopup;
    NSTextField *_addressField;
    NSButton *_launchInForegroundSwitch;
    NSTextField *_emailAddressField;
    NSTextField *_emailSubjectField;
    id<HSEmailTextFieldController> _emailTextFieldController;
    HSAddressBookEmailTokenFieldController *_addressBookEmailTokenFieldController;
    id<HSGoToURLActionAttributes> _observableActionAttributes;
    NSView *_currentView;
}
- (void)controlTextDidChange:(id)aChange;
- (void)sendMailActionEmailSubjectAttributeDidChange:(id)aChange;
- (void)sendMailActionEmailAddressesAttributeDidChange:(id)aChange;
- (void)openWebPageActionLaunchInForegroundAttributeDidChange:(id)aChange;
- (void)openWebPageActionURLAttributeDidChange:(id)aChange;
- (void)actionTypeDidChange:(id)aChange;
- (void)paneDidCancel:(id)aCancel;
- (void)toggleLaunchInForeground:(id)aForeground;
- (void)emailSubjectChanged:(id)aChanged;
- (void)emailAddressesChanged:(id)aChanged;
- (void)URLChanged:(id)aChanged;
- (void)actionURLTypeChanged:(id)aChanged;
- (void)mountView:(id)aView;
- (void)viewDidAppear:(BOOL)aAppear;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)setObservableActionAttributes:(id)aAttributes;
- (BOOL)shouldEnableOKButtonInNavigationPaneSwitcher:(id)aSwitcher;
- (void)validateCurrentPane;
- (void)validateSendMailActionEmailSubject;
- (void)validateSendMailActionEmailAddresses;
- (void)validateOpenWebPageActionLaunchInForeground;
- (void)validateOpenWebPageActionURL;
- (id)helpTopicKey;
- (id)openWebPageActionAttributes;
- (id)sendMailActionAttributes;
- (id)actionAttributes;
- (id)actionType;
- (id)goToURLActionAssistantApplier;
- (Class)applierClass;
- (void)viewDidLoad;
- (void)dealloc;
- (id)init;
@end

@interface HSGoToURLActionAssistantPaneApplier : HSActionAssistantSettingsApplier
{
    NSArray *_initialEmailAddresses;
    NSString *_initialEmailSubject;
    NSURL *_initialURL;
    BOOL _initialLaunchInForeground;
    int _initialURLType;
    NSArray *_emailAddresses;
    NSString *_emailSubject;
    NSURL *_URL;
    BOOL _launchInForeground;
    int _URLType;
}
- (void)setLaunchInForeground:(BOOL)aForeground;
- (void)setURL:(id)aURL;
- (void)setEmailSubject:(id)aSubject;
- (void)setEmailAddresses:(id)aAddresses;
- (void)setURLType:(NSInteger)aType;
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setUpInitialSettings;
- (id)openWebPageActionAttributes;
- (id)sendMailActionAttributes;
- (id)goToURLActionAttributes;
- (void)dealloc;
@end

