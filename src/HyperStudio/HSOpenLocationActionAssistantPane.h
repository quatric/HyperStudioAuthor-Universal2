#import "HyperStudioPrefix.h"
#import "HSActionAssistantPane.h"
#import "HSActionAssistantSettingsApplier.h"


@interface HSOpenLocationActionAssistantPane : HSActionAssistantPane
{
    NSTextField *_documentNameField;
    NSTextField *_applicationNameField;
    NSImageView *_documentIconView;
    NSImageView *_applicationIconView;
    NSButton *_openDocumentSwitch;
    NSButton *_openApplicationSwitch;
    NSButton *_quitAfterLaunchSwitch;
    NSButton *_launchInForegroundSwitch;
}
- (void)openApplicationChanged:(id)aChanged;
- (void)openDocumentChanged:(id)aChanged;
- (void)launchInForeground:(id)aForeground;
- (void)quitFromPlayer:(id)aPlayer;
- (void)chooseApplication:(id)aApplication;
- (void)chooseLocation:(id)aLocation;
- (void)validateUIWithNotification:(id)aNotification;
- (BOOL)shouldEnableOKButtonInNavigationPaneSwitcher:(id)aSwitcher;
- (BOOL)canApplyCurrentSettingsForObjectAssistant:(id)aAssistant;
- (void)validateUI;
- (id)helpTopicKey;
- (void)viewDidAppear:(BOOL)aAppear;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (id)actionAttribute;
- (id)actionAttributes;
- (id)actionType;
- (id)openLocationActionAssistantPaneApplier;
- (Class)applierClass;
- (id)init;
@end

@interface HSOpenLocationActionAssistantPaneApplier : HSActionAssistantSettingsApplier
{
    BOOL _quitFromPlayer;
    BOOL _launchInForeground;
    BOOL _opensDocument;
    BOOL _opensApplication;
    NSString *_applicationName;
    NSURL *_URL;
    BOOL _initialQuitFromPlayer;
    BOOL _initialLaunchInForeground;
    BOOL _initialOpensDocument;
    BOOL _initialOpensApplication;
    NSString *_initialApplicationName;
    NSURL *_initialURL;
}
- (void)setOpensApplication:(BOOL)aApplication;
- (void)setOpensDocument:(BOOL)aDocument;
- (void)setLaunchInForeground:(BOOL)aForeground;
- (void)setQuitAfterLaunch:(BOOL)aLaunch;
- (void)setURL:(id)aURL;
- (void)setApplicationName:(id)aName;
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setUpInitialSettings;
- (id)openLocationActionAttributes;
- (void)dealloc;
@end

