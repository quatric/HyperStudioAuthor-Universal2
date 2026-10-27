#import "HyperStudioPrefix.h"
#import "HSActionAssistantSettingsApplier.h"
#import "HSNBAAssistantPane.h"


@interface HSGoogleEarthActionAssistantPane : HSNBAAssistantPane
{
    NSTextField *_documentNameField;
    NSImageView *_documentIconView;
    NSButton *_quitAfterLaunchSwitch;
    NSButton *_launchInForegroundSwitch;
}
- (void)launchInForeground:(id)aForeground;
- (void)quitFromPlayer:(id)aPlayer;
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
- (id)googleEarthActionAssistantPaneApplier;
- (Class)applierClass;
- (id)init;
@end

@interface HSGoogleEarthActionAssistantPaneApplier : HSActionAssistantSettingsApplier
{
    BOOL _quitFromPlayer;
    BOOL _launchInForeground;
    NSURL *_URL;
    BOOL _initialQuitFromPlayer;
    BOOL _initialLaunchInForeground;
    NSURL *_initialURL;
}
- (void)setLaunchInForeground:(BOOL)aForeground;
- (void)setQuitAfterLaunch:(BOOL)aLaunch;
- (void)setURL:(id)aURL;
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setUpInitialSettings;
- (id)googleEarthActionAttributes;
- (void)dealloc;
@end

