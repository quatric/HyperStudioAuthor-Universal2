#import "HyperStudioPrefix.h"
#import "HSActionAssistantSettingsApplier.h"
#import "HSNBAAssistantPane.h"


@interface HSMoveTextActionAssistantPane : HSNBAAssistantPane
{
    NSPopUpButton *_sourcePopUp;
    NSPopUpButton *_destinationPopUp;
    NSMatrix *_sourceMatrix;
    NSMatrix *_destinationMatrix;
    NSMutableArray *_availableTextObjects;
    struct __CFDictionary *_availableCardIndexes;
    NSArray *_availableCommentItems;
    NSMutableArray *_availableSourceObjects;
}
- (void)validatePopUp:(id)aUp objectUID:(id)aUID context:(id)aContext;
- (void)validateUI;
- (void)validateUIWithNotification:(id)aNotification;
- (void)sourceChanged:(id)aChanged;
- (void)destinationChanged:(id)aChanged;
- (void)sourceActionChanged:(id)aChanged;
- (void)destinationActionChanged:(id)aChanged;
- (id)initialKeyView;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)setSourceMatrixEnabled:(BOOL)aEnabled;
- (id)actionAttribute;
- (void)fillInPopUp:(id)aUp objectUID:(id)aUID context:(id)aContext;
- (id)availableDestinationObjects;
- (id)availableSourceObjects;
- (id)availableCommentItems;
- (id)availableTextObjects;
- (id)actionType;
- (id)helpTopicKey;
- (void)dealloc;
- (id)init;
- (id)actionAttributes;
- (id)moveTextActionAssistantPaneApplier;
- (Class)applierClass;
@end

@interface HSMoveTextActionAssistantPaneApplier : HSActionAssistantSettingsApplier
{
    HSUID *_initialSourceObjectUID;
    HSUID *_initialDestinationObjectUID;
    int _initialSourceDataType;
    int _initialSourceAction;
    int _initialDestinationAction;
    HSUID *_sourceObjectUID;
    HSUID *_destinationObjectUID;
    int _sourceDataType;
    int _sourceAction;
    int _destinationAction;
}
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setDestinationAction:(NSInteger)aAction;
- (void)setSourceAction:(NSInteger)aAction;
- (void)setSourceDataType:(NSInteger)aType;
- (void)setDestinationObjectUID:(id)aUID;
- (void)setSourceObjectUID:(id)aUID;
- (void)setUpInitialSettings;
- (id)moveTextActionAttributes;
- (void)dealloc;
@end

