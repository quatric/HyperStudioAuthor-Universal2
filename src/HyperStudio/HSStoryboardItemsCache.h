#import "HyperStudioPrefix.h"


@interface HSStoryboardItemsCache : NSObject
{
    HSStoryboardView *_parentView;
    HSStack *_stack;
    NSMutableArray *_items;
    NSIndexSet *_draggedItemsInitialIndexes;
    BOOL _draggedItemsRemoved;
    NSArray *_draggedItems;
    HSEmptyStoryboardItem *_dragPlaceholder;
    NSUInteger _dropIndex;
}
- (NSUInteger)dropIndex;
- (void)insertDragPlaceholderAtIndex:(NSUInteger)aIndex;
- (void)removeDragPlaceholder;
- (BOOL)isDraggedSolidGroup;
- (void)clearDraggedItems;
- (void)restoreDraggedItems;
- (void)removeDraggedItems;
- (void)setDraggedItems:(id)aItems;
- (id)draggedItemsInitialIndexes;
- (void)takeDraggedItemsInitialIndexes;
- (id)draggedItemsIndexes;
- (id)draggedItems;
- (id)dragPlaceholder;
- (void)rebuildCache;
- (id)stubItem;
- (id)items;
- (void)registerForActionsAttributeChanges;
- (void)unregisterForActionsAttributeChanges;
- (void)unregisterForActionsAttributeChangesForItem:(id)aItem;
- (void)registerForActionsAttributeChangesForItem:(id)aItem;
- (void)cardActionAttributeDidChange:(id)aChange;
- (void)synchronizeWithStack;
- (void)invalidateAllItems;
- (void)invalidateAllItemsWithoutThumbnails;
- (void)invalidate;
- (void)invalidateWithChangedItemOrder;
- (void)invalidateWithRemovedItem;
- (void)invalidateWithAddedItem;
- (void)selectAllItems;
- (id)selectedHyperObject;
- (id)activeCard;
- (id)selectedItemsIndexes;
- (id)selectedItems;
- (id)itemForCard:(id)aCard;
- (NSUInteger)indexOfStoryboardItem:(id)aItem;
- (id)objectInStoryboardItemsAtIndex:(NSUInteger)aIndex;
- (NSUInteger)numberOfItems;
- (void)setStack:(id)aStack;
- (id)stack;
- (id)parentView;
- (void)setParentView:(id)aView;
- (void)dealloc;
- (id)init;
@end

