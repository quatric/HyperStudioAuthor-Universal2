#import "HyperStudioPrefix.h"
#import "HSActionAssistantSettingsApplier.h"
#import "HSNBAAssistantPane.h"


@interface HSKeyMapperActionAssistantPane : HSNBAAssistantPane <NSTableViewDataSource, NSObject>
{
    NSTableView *_tableView;
    NSMenu *_characterMenu;
    NSMutableArray *_availableObjects;
    HSActionsPaneButtonBackgroundRenderer *_buttonBackgroundRenderer;
    HSKeyMapperActionShortcutAssistantPane *_shortcutPane;
    NSMutableDictionary *_keyMappingsByIndex;
}
- (void)checkKeyMappingsForUIDKey;
- (void)shortcutPaneDidEnd:(id)aEnd;
- (void)openShortcutPaneForKeyMapping:(id)aMapping;
- (id)shortcutPane;
- (id)keyMappingDictionaryForObject:(id)aObject;
- (id)keyMappingsByIndex;
- (id)keyMappingForObjectWithUID:(id)aUID;
- (id)keyMappingForObjectWithTitle:(id)aTitle;
- (BOOL)isShortcutEnabledForObject:(id)aObject;
- (id)availableObjects;
- (void)validateUIWithNotification:(id)aNotification;
- (void)tableView:(id)aView willDisplayCell:(id)aCell forTableColumn:(id)aColumn row:(NSInteger)aRow;
- (id)buttonBackgroundRenderer;
- (void)tableView:(id)aView setObjectValue:(id)aValue forTableColumn:(id)aColumn row:(NSInteger)aRow;
- (id)tableView:(id)aView objectValueForTableColumn:(id)aColumn row:(NSInteger)aRow;
- (NSInteger)numberOfRowsInTableView:(id)aView;
- (id)initialKeyView;
- (id)helpTopicKey;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (id)actionAttribute;
- (void)validateTableView;
- (id)actionType;
- (id)actionAttributes;
- (id)keyMapperActionAssistantPaneApplier;
- (Class)applierClass;
- (void)awakeFromNib;
- (void)dealloc;
- (id)init;
@end

@interface HSKeyMapperActionAssistantPaneApplier : HSActionAssistantSettingsApplier
{
    NSArray *_initialKeyMappings;
    NSArray *_keyMappings;
}
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setKeyMappings:(id)aMappings;
- (void)setUpInitialSettings;
- (id)keyMapperActionAttributes;
- (void)dealloc;
@end

