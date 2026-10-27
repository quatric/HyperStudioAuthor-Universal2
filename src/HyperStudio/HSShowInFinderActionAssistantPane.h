#import "HyperStudioPrefix.h"
#import "HSActionAssistantSettingsApplier.h"
#import "HSNBAAssistantPane.h"


@interface HSShowInFinderActionAssistantPane : HSNBAAssistantPane
{
    NSTextField *_pathTextField;
    NSImageView *_fileIconForPath;
}
- (void)controlTextDidChange:(id)aChange;
- (id)helpTopicKey;
- (void)validateUI;
- (void)validateUIWithNotification:(id)aNotification;
- (void)chooseFilePath:(id)aPath;
- (id)initialKeyView;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (id)actionAttribute;
- (id)actionAttributes;
- (id)actionType;
- (id)showInFinderActionAssistantPaneApplier;
- (Class)applierClass;
- (id)init;
@end

@interface HSShowInFinderActionAssistantPaneApplier : HSActionAssistantSettingsApplier
{
    NSString *_filePath;
    NSString *_initialFilePath;
}
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setFilePath:(id)aPath;
- (void)setUpInitialSettings;
- (id)showInFinderActionAttributes;
- (void)dealloc;
@end

