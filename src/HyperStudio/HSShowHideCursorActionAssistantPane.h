#import "HyperStudioPrefix.h"
#import "HSActionAssistantSettingsApplier.h"
#import "HSNBAAssistantPane.h"


@interface HSShowHideCursorActionAssistantPane : HSNBAAssistantPane
{
    NSMatrix *_actionMatrix;
}
- (void)validateUI;
- (void)validateUIWithNotification:(id)aNotification;
- (void)cursorActionChanged:(id)aChanged;
- (id)initialKeyView;
- (id)helpTopicKey;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (id)actionAttribute;
- (id)actionAttributes;
- (id)showHideActionAssistantPaneApplier;
- (Class)applierClass;
- (id)actionType;
- (id)init;
@end

@interface HSShowHideCursorActionAssistantPaneApplier : HSActionAssistantSettingsApplier
{
    int _initialChangeCursorVisibilityAction;
    int _changeCursorVisibilityAction;
}
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setChangeCursorVisibilityAction:(NSInteger)aAction;
- (void)setUpInitialSettings;
- (id)showHideCursorActionAttributes;
@end

