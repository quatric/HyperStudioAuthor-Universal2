#import "HyperStudioPrefix.h"
#import "HSActionAssistantSettingsApplier.h"
#import "HSNBAAssistantPane.h"


@interface HSCardShufflerActionAssistantPane : HSNBAAssistantPane
{
    NSPopUpButton *_startingCardPopUp;
    NSPopUpButton *_endingCardPopUp;
    NSButton *_clearChangesCheckBox;
    BOOL _shouldUpdatePopUpLists;
}
- (id)cardTitles;
- (void)clearChangesChanged:(id)aChanged;
- (void)updateRelatedPopUpButton:(id)aButton selectedMenuItem:(id)aItem;
- (void)chooseEndingCard:(id)aCard;
- (void)chooseStartingCard:(id)aCard;
- (void)updatePopUpLists;
- (void)validateUserInterface;
- (void)validateUIWithNotification:(id)aNotification;
- (id)helpTopicKey;
- (void)stackChanged:(id)aChanged;
- (void)removeActionAssistantPaneObserver;
- (void)addActionAssistantPaneObserver;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (id)actionAttribute;
- (id)actionAttributes;
- (id)actionType;
- (id)cardShufflerActionAsssistantApplier;
- (Class)applierClass;
- (id)init;
@end

@interface HSCardShufflerActionAssistantPaneApplier : HSActionAssistantSettingsApplier
{
    id<HSCardShufflerActionAttributes> _actionAttributes;
    unsigned int _initialStartingCardIndex;
    unsigned int _initialEndingCardIndex;
    BOOL _initialShouldClearChanges;
    unsigned int _startingCardIndex;
    unsigned int _endingCardIndex;
    BOOL _shouldClearChanges;
}
- (void)setShouldClearChanges:(BOOL)aChanges;
- (void)setEndingCardIndex:(NSUInteger)aIndex;
- (void)setStartingCardIndex:(NSUInteger)aIndex;
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setUpInitialSettings;
- (id)cardShufflerActionAttributes;
- (void)dealloc;
@end

