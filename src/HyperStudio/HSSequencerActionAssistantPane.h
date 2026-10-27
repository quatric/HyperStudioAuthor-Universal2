#import "HyperStudioPrefix.h"
#import "HSActionAssistantSettingsApplier.h"
#import "HSNBAAssistantPane.h"


@interface HSSequencerActionAssistantPane : HSNBAAssistantPane <NSOutlineViewDataSource, NSObject, NSOutlineViewDelegate, NSControlTextEditingDelegate>
{
    NSView *_containerView;
    NSView *_emptyView;
    NSView *_mainView;
    NSOutlineView *_outlineView;
    NSView *_scrollOutlineView;
    HSImageView *_noActionsPaneBackgroundView;
    HSCheckBox *_objectsOnThisCardCheckBox;
    NSArray *_availableCards;
    NSView *_currentView;
}
- (void)showObjectsOnThisCardOnly:(id)aOnly;
- (void)validateUIWithNotification:(id)aNotification;
- (BOOL)outlineView:(id)aView shouldEditTableColumn:(id)aColumn item:(id)aItem;
- (BOOL)outlineView:(id)aView shouldSelectItem:(id)aItem;
- (id)outlineView:(id)aView toolTipForCell:(id)aCell rect:(NSRect *)aRect tableColumn:(id)aColumn item:(id)aItem mouseLocation:(NSPoint)aLocation;
- (void)outlineView:(id)aView willDisplayCell:(id)aCell forTableColumn:(id)aColumn item:(id)aItem;
- (void)outlineView:(id)aView setObjectValue:(id)aValue forTableColumn:(id)aColumn byItem:(id)aItem;
- (id)outlineView:(id)aView objectValueForTableColumn:(id)aColumn byItem:(id)aItem;
- (id)stateForItem:(id)aItem;
- (id)outlineView:(id)aView child:(NSInteger)aChild ofItem:(id)aItem;
- (BOOL)outlineView:(id)aView isItemExpandable:(id)aExpandable;
- (NSInteger)outlineView:(id)aView numberOfChildrenOfItem:(id)aItem;
- (void)outlineViewItemDidCollapse:(id)aCollapse;
- (void)outlineViewItemDidExpand:(id)aExpand;
- (void)reloadExpandedStatesForItems:(id)aItems;
- (void)setExpandedState:(BOOL)aState forItem:(id)aItem;
- (BOOL)expandedStateForItem:(id)aItem;
- (BOOL)isExpandedStateStoredForItem:(id)aItem;
- (id)sequenceItemForObjectWithUID:(id)aUID;
- (id)initialKeyView;
- (id)helpTopicKey;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (id)actionAttribute;
- (void)mountView:(id)aView;
- (id)availableCards;
- (id)availableObjectsOnCard:(id)aCard;
- (id)actionType;
- (void)viewDidLoad;
- (void)dealloc;
- (id)init;
- (id)actionAttributes;
- (id)sequencerActionAssistantPaneApplier;
- (Class)applierClass;
@end

@interface HSSequencerActionAssistantPaneApplier : HSActionAssistantSettingsApplier
{
    NSArray *_initialSequenceItems;
    NSArray *_sequenceItems;
}
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setSequenceItems:(id)aItems;
- (void)setUpInitialSettings;
- (id)sequencerActionAttributes;
- (void)dealloc;
@end

@interface HSActionSequencerLastSelectedActorHolder : NSObject <HSWeakReferencer>
{
    NSMapTable *_actorsMap;
}
+ (id)sharedActorHolder;
- (void)dereferenceObject:(id)aObject;
- (void)setLastSequenceActor:(id)aActor forActor:(id)aActor2;
- (id)lastSequenceActorForActor:(id)aActor;
- (void)dealloc;
@end

