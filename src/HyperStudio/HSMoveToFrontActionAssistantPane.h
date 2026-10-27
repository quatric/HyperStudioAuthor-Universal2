#import "HyperStudioPrefix.h"
#import "HSActionAssistantSettingsApplier.h"
#import "HSNBAAssistantPane.h"


@interface HSMoveToFrontActionAssistantPane : HSNBAAssistantPane
{
    NSPopUpButton *_sourcePopUp;
    NSMutableArray *_availableSourceObjects;
}
- (void)validatePopUp:(id)aUp objectUID:(id)aUID context:(id)aContext;
- (void)validateUI;
- (void)validateUIWithNotification:(id)aNotification;
- (void)sourceChanged:(id)aChanged;
- (id)initialKeyView;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (id)actionAttribute;
- (void)fillInPopUp:(id)aUp objectUID:(id)aUID context:(id)aContext;
- (id)titleForObject:(id)aObject inMenu:(id)aMenu;
- (id)availableSourceObjects;
- (id)actionType;
- (id)helpTopicKey;
- (void)dealloc;
- (id)init;
- (id)actionAttributes;
- (id)moveToFrontActionAssistantPaneApplier;
- (Class)applierClass;
@end

@interface HSMoveToFrontActionAssistantPaneApplier : HSActionAssistantSettingsApplier
{
    HSUID *_initialSourceObjectUID;
    HSUID *_sourceObjectUID;
}
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setSourceObjectUID:(id)aUID;
- (void)setUpInitialSettings;
- (id)moveToFrontActionAttributes;
- (void)dealloc;
@end

