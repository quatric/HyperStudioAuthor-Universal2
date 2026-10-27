#import "HyperStudioPrefix.h"
#import "HSActionAssistantSettingsApplier.h"
#import "HSNBAAssistantPane.h"


@interface HSQuitAnotherApplicationActionAssistantPane : HSNBAAssistantPane
{
    NSTextField *_appTextField;
    NSImageView *_appIconView;
    NSImage *_appIcon;
}
- (id)helpTopicKey;
- (void)validateUI;
- (void)validateUIWithNotification:(id)aNotification;
- (id)applicationIcon;
- (void)createApplicationIconIfNeeded;
- (void)setApplicationIcon:(id)aIcon;
- (void)chooseApplication:(id)aApplication;
- (id)initialKeyView;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (id)actionAttribute;
- (id)actionAttributes;
- (id)actionType;
- (id)quitAnotherApplicationActionAssistantPaneApplier;
- (Class)applierClass;
- (void)dealloc;
- (id)init;
@end

@interface HSQuitAnotherApplicationActionAssistantPaneApplier : HSActionAssistantSettingsApplier
{
    NSString *_applicationToQuit;
    NSString *_initialApplicationToQuit;
}
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setApplicationToQuit:(id)aQuit;
- (void)setUpInitialSettings;
- (id)quitAnotherApplicationActionAttributes;
- (void)dealloc;
@end

