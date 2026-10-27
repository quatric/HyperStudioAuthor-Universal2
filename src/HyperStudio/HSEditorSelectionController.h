#import "HyperStudioPrefix.h"


@interface HSEditorSelectionController : NSObject <HSAnythingSelectionAccessor, HSStackSelectionAccessor, HSSelectionAccessor, NSObject, HSCardSelectionAccessor, HSCardObjectSelectionAccessor, HSExtendedSelectionAccessor, HSSelectionHolderDelegate>
{
    HSEditorWindowController *_windowController;
    id<HSSelectionHolder> _activeSelectionHolder;
    BOOL _activeSelectionHolderWasExplicitlySet;
    BOOL _isEnabled;
    id<HSSelectionHolder> _cardView;
    id<HSStackView, HSSelectionHolder> _stackController;
    id<HSSelectionHolder> _storyboardView;
    unsigned int _addChildGroupingCount;
    unsigned int _removeChildGroupingCount;
    NSMutableArray *_addedChildrenWithinGroup;
    BOOL _processingActivation;
    BOOL _synchronizingWithInactiveSelectionHolder;
    BOOL _pendingActiveSelectionHolderRequest;
}
- (BOOL)refreshActiveSelectionHolderByRemovingSelectionHolder:(id)aHolder;
- (BOOL)refreshActiveSelectionHolderByRemovingSelectionHolder:(id)aHolder withAddedSelectionHolder:(id)aHolder2;
- (BOOL)refreshActiveSelectionHolder;
- (BOOL)refreshActiveSelectionHolderWithNotificationFromHolder:(id)aHolder wantsToActivate:(BOOL)aActivate wantsToBecomeFirstResponder:(BOOL)aResponder;
- (id)preferredSelectionHolderForSelectionAccessor:(id)aAccessor;
- (id)allSelectionHolders;
- (id)allSelectionHoldersPrioritizedForSelectionAccessor:(id)aAccessor;
- (void)updateAllSelectionHoldersAndChooseActiveWithSelectionAccessor:(id)aAccessor exceptSelectionHolder:(id)aHolder;
- (void)selectionHolderWantsToResignAndPassOnSelection:(id)aSelection;
- (void)selectionHolderWantsToReactivate:(id)aReactivate;
- (void)selectionHolderDidChangeSelectedHyperObject:(id)aObject wantsToActivate:(BOOL)aActivate;
- (BOOL)shouldIgnoreChangeNotificationsFromSelectionHolder:(id)aHolder;
- (id)hyperActiveSelectionHolder;
- (id)selectedHyperObject;
- (id)addedChildrenWithinGroup;
- (void)noteNodeContainer:(id)aContainer didRemoveChildren:(id)aChildren;
- (void)noteNodeContainer:(id)aContainer didAddChild:(id)aChild;
- (void)noteNodeContainerRemoveChildrenEndGrouping:(id)aGrouping;
- (void)noteNodeContainerRemoveChildrenBeginGrouping:(id)aGrouping;
- (void)noteNodeContainerAddChildrenEndGrouping:(id)aGrouping;
- (void)noteNodeContainerAddChildrenBeginGrouping:(id)aGrouping;
- (void)noteGroupOfChildrenRemoved;
- (void)noteGroupOfChildrenAdded:(id)aAdded;
- (void)noteWindowControllerWillClose;
- (void)noteWindowControllerDidBecomeMain;
- (void)setEnabled:(BOOL)aEnabled;
- (BOOL)isEnabled;
- (id)storyboardView;
- (void)setStoryboardView:(id)aView;
- (id)stackController;
- (void)setStackController:(id)aController;
- (id)cardView;
- (void)setCardView:(id)aView;
- (id)windowController;
- (void)setWindowController:(id)aController;
- (void)dealloc;
@end

@interface HSEditorSelectionController (HSSelectionChangeNotificationPosting)
- (void)postHyperSelectionDidChangeNotification;
- (void)postHyperSelectionDidChangeNotificationForce:(BOOL)aForce;
@end

