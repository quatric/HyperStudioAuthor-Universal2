#import "HyperStudioPrefix.h"
#import "HSNBAAssistantPane.h"


@interface HSKeyMapperActionShortcutAssistantPane : HSNBAAssistantPane
{
    NSButton *_useCommandSwitch;
    NSButton *_useCustomKeyRadioButton;
    NSButton *_useSystemKeyRadioButton;
    NSTextField *_customKeyTextField;
    NSPopUpButton *_systemKeyPopUpButton;
    NSTextField *_descriptionTextFiled;
    NSMutableDictionary *_keyMapping;
}
- (void)paneDidCancel:(id)aCancel;
- (void)paneDidOK:(id)aOK;
- (void)customKeyDidChange:(id)aChange;
- (void)useSystemKeyDidChange:(id)aChange;
- (void)useCustomKeyDidChange:(id)aChange;
- (id)resultDictionary;
- (void)setInitialDictionary:(id)aDictionary;
- (void)viewWillAppear:(BOOL)aAppear;
- (Class)applierClass;
- (id)actionType;
- (id)navigationPaneSwitcher;
- (void)dealloc;
- (id)init;
@end

