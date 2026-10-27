#import "HSStoryboardItemsCache.h"
static id sDAT_0034283c;

static id sDAT_0034283c;


@implementation HSStoryboardItemsCache

/* i386 ivar offsets: _parentView=0x4, _stack=0x8, _items=0xc, _draggedItemsInitialIndexes=0x10, _draggedItemsRemoved=0x14, _draggedItems=0x18, _dragPlaceholder=0x1c, _dropIndex=0x20 */

- (NSUInteger)dropIndex
{
    return _dropIndex;
}

- (void)insertDragPlaceholderAtIndex:(NSUInteger)aIndex
{
    if (_dropIndex != aIndex) {
        if ([_items count] < aIndex) {
            aIndex = [_items count];
        }
        _dropIndex = aIndex;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008e0d6 @ 0008e0d6, 24 bytes * /

void FUN_0008e0d6(HSStoryboardItemsCache *self,SEL _cmd)

{
  if (self->_dropIndex != 0x7fffffff) {
    self->_dropIndex = 0x7fffffff;
  }
  return;
}

*/
- (void)removeDragPlaceholder
{
    if (_dropIndex != NSNotFound) {
        _dropIndex = NSNotFound;
    }
}

- (BOOL)isDraggedSolidGroup
{
    id pvVar1;

    pvVar1 = [self draggedItemsInitialIndexes];
    return (unsigned int)((int)[pvVar1 lastIndex] - (int)[pvVar1 firstIndex]) <= (int)[pvVar1 count] - 1U;
}

- (void)clearDraggedItems
{
    [self setDraggedItems:nil];
    _draggedItemsRemoved = NO;
}

- (void)restoreDraggedItems
{
    NSEnumerator *self_00;
    id self_01;

    if (_draggedItemsRemoved != NO) {
        self_00 = [_draggedItems objectEnumerator];
        self_01 = [self_00 nextObject];
        while (self_01 != nil) {
            [self_01 setParent:_parentView];
            [_items insertObject:self_01 atIndex:[self_01 tag]];
            [self registerForActionsAttributeChangesForItem:self_01];
            [_parentView storyboardItemsCacheDidAddItem:self_01 atIndex:[self_01 tag]];
            self_01 = [self_00 nextObject];
        }
        _draggedItemsRemoved = NO;
    }
}

- (void)removeDraggedItems
{
    NSEnumerator *self_00;
    id self_01;
    NSUInteger pvVar1;

    if (_draggedItemsRemoved == NO) {
        self_00 = [_draggedItems objectEnumerator];
        self_01 = [self_00 nextObject];
        while (self_01 != nil) {
            pvVar1 = [_items indexOfObject:self_01];
            [_parentView storyboardItemsCacheWillRemoveItem:self_01 atIndex:pvVar1];
            [self unregisterForActionsAttributeChangesForItem:self_01];
            [self_01 setParent:nil];
            [_items removeObject:self_01];
            [_parentView storyboardItemsCacheDidRemoveItem:self_01 atIndex:pvVar1]
            ;
            self_01 = [self_00 nextObject];
        }
        _draggedItemsRemoved = YES;
    }
}

- (void)setDraggedItems:(id)aItems
{
    NSEnumerator *self_00;
    id pvVar1_2;
    id pvVar1_3;

    if (![_draggedItems isEqual:aItems]) {
        [_draggedItems release];
        pvVar1_2 = [aItems retain];
        _draggedItems = pvVar1_2;
        self_00 = [pvVar1_2 objectEnumerator];
        pvVar1_3 = [self_00 nextObject];
        while (pvVar1_3 != nil) {
            [pvVar1_3 setTag:[_items indexOfObject:pvVar1_3]];
            pvVar1_3 = [self_00 nextObject];
        }
        [self takeDraggedItemsInitialIndexes];
    }
}

- (id)draggedItemsInitialIndexes
{
    return _draggedItemsInitialIndexes;
}

- (void)takeDraggedItemsInitialIndexes
{
    [_draggedItemsInitialIndexes release];
    _draggedItemsInitialIndexes = [[self draggedItemsIndexes] retain];
}

- (id)draggedItemsIndexes
{
    id pvVar1;
    id pvVar3;
    NSEnumerator *pvVar2_2;

    pvVar1 = [NSMutableIndexSet new];
    pvVar2_2 = [[self draggedItems] objectEnumerator];
    while( YES ) {
        pvVar3 = [pvVar2_2 nextObject];
        if (pvVar3 == nil) break;
        [pvVar1 addIndex:[self indexOfStoryboardItem:pvVar3]];
    }
    pvVar1 = [pvVar1 autorelease];
    return pvVar1;
}

- (id)draggedItems
{
    return _draggedItems;
}

- (id)dragPlaceholder
{
    id pvVar1;
    id pvVar1_2;

    pvVar1 = _dragPlaceholder;
    if (pvVar1 == nil) {
        pvVar1_2 = [HSEmptyStoryboardItem new];
        _dragPlaceholder = pvVar1_2;
        [pvVar1_2 setParent:_parentView];
        pvVar1 = _dragPlaceholder;
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008e6cb @ 0008e6cb, 634 bytes * /

void FUN_0008e6cb(HSStoryboardItemsCache *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  undefined4 uVar3;
  id pvVar4;
  id self_00;
  int iVar5;
  id pvVar6;
  id pvVar7;
  
  pvVar1 = _objc_msgSend(self->_items,sel_objectEnumerator);
  pvVar2 = _objc_msgSend(pvVar1,sel_nextObject);
  if (pvVar2 != (id)0x0) {
    iVar5 = 0;
    do {
      pvVar6 = pvVar2;
      _objc_msgSend(self->_parentView,sel_storyboardItemsCacheWillRemoveItem_atIndex_,pvVar2,iVar5);
      _objc_msgSend(pvVar6,sel_setParent_,0);
      _objc_msgSend(self->_parentView,sel_storyboardItemsCacheDidRemoveItem_atIndex_,pvVar2,iVar5);
      iVar5 = iVar5 + 1;
      pvVar2 = _objc_msgSend(pvVar1,sel_nextObject);
    } while (pvVar2 != (id)0x0);
  }
  uVar3 = 0;
  _objc_msgSend(self,sel_unregisterForActionsAttributeChanges);
  pvVar1 = (id)0x0;
  _objc_msgSend(self->_items,sel_makeObjectsPerformSelector_withObject_,sel_setParent_,0);
  _objc_msgSend(self->_items,sel_removeAllObjects);
  _objc_msgSend(self->_draggedItems,sel_release);
  self->_draggedItems = (id)0x0;
  _objc_msgSend(self,sel_items);
  pvVar2 = _objc_msgSend(self->_stack,sel_hyperCount);
  if (pvVar2 != (id)0x0) {
    pvVar6 = (id)0x0;
    do {
      pvVar7 = pvVar6;
      pvVar4 = _objc_msgSend(self->_stack,sel_hyperChildAtIndex_,pvVar6,pvVar1);
      if (pvVar4 == (id)0x0) {
LAB_0008e8a8:
        pvVar4 = _objc_msgSend(self,sel_stubItem,pvVar7,pvVar1);
      }
      else {
        self_00 = _objc_msgSend(cls_HSStoryboardItem,sel_new,pvVar7,pvVar1,pvVar2,uVar3,pvVar4);
        pvVar7 = pvVar4;
        pvVar4 = _objc_msgSend(self_00,sel_autorelease);
        _objc_msgSend(pvVar4,sel_setCard_,pvVar7);
        if (pvVar4 == (id)0x0) goto LAB_0008e8a8;
      }
      _objc_msgSend(self->_items,sel_addObject_,pvVar4);
      _objc_msgSend(pvVar4,sel_setParent_,self->_parentView);
      _objc_msgSend(self,sel_registerForActionsAttributeChangesForItem_,pvVar4);
      pvVar1 = pvVar6;
      _objc_msgSend(self->_parentView,sel_storyboardItemsCacheDidAddItem_atIndex_,uVar3,pvVar6);
      pvVar6 = (id)((int)pvVar6 + 1);
    } while (pvVar6 < pvVar2);
  }
  return;
}

*/
- (void)rebuildCache
{
    NSEnumerator *enumerator = [_items objectEnumerator];
    NSUInteger index = 0;
    id item;
    while ((item = [enumerator nextObject]) != nil) {
        [_parentView storyboardItemsCacheWillRemoveItem:item atIndex:index];
        [item setParent:nil];
        [_parentView storyboardItemsCacheDidRemoveItem:item atIndex:index];
        index++;
    }
    [self unregisterForActionsAttributeChanges];
    [_items makeObjectsPerformSelector:@selector(setParent:) withObject:nil];
    [_items removeAllObjects];
    [_draggedItems release];
    _draggedItems = nil;
    [self items];
    NSUInteger count = [_stack hyperCount];
    for (NSUInteger i = 0; i < count; i++) {
        id card = [_stack hyperChildAtIndex:i];
        if (card == nil) {
            item = [self stubItem];
        } else {
            item = [[HSStoryboardItem new] autorelease];
            [item setCard:card];
            if (item == nil) {
                item = [self stubItem];
            }
        }
        [_items addObject:item];
        [item setParent:_parentView];
        [self registerForActionsAttributeChangesForItem:item];
        [_parentView storyboardItemsCacheDidAddItem:item atIndex:i];
    }
}

- (id)stubItem
{
    if (sDAT_0034283c == nil) {
        sDAT_0034283c = [HSStoryboardItem new];
    }
    return sDAT_0034283c;
}

- (id)items
{
    id pvVar1;

    pvVar1 = _items;
    if (pvVar1 == nil) {
        pvVar1 = [NSMutableArray new];
        _items = pvVar1;
    }
    return pvVar1;
}

- (void)registerForActionsAttributeChanges
{
    NSEnumerator *self_00;
    id pvVar1;

    self_00 = [_items objectEnumerator];
    while( YES ) {
        pvVar1 = [self_00 nextObject];
        if (pvVar1 == nil) break;
        [self registerForActionsAttributeChangesForItem:pvVar1];
    }
}

- (void)unregisterForActionsAttributeChanges
{
    NSEnumerator *self_00;
    id pvVar1;

    self_00 = [_items objectEnumerator];
    while( YES ) {
        pvVar1 = [self_00 nextObject];
        if (pvVar1 == nil) break;
        [self unregisterForActionsAttributeChangesForItem:pvVar1];
    }
}

- (void)unregisterForActionsAttributeChangesForItem:(id)aItem
{
    [[[aItem card] attributeObservingController] removeObserver:self selector:@selector(cardActionAttributeDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSActionsAttribute)];
}

- (void)registerForActionsAttributeChangesForItem:(id)aItem
{
    [[[aItem card] attributeObservingController] addObserver:self selector:@selector(cardActionAttributeDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSActionsAttribute) withPriority:-0.25];
}

- (void)cardActionAttributeDidChange:(id)aChange
{
    [_parentView storyboardItemsCacheDidUpdateItem:[self itemForCard:[aChange object]]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008ebc6 @ 0008ebc6, 1008 bytes * /

void FUN_0008ebc6(HSStoryboardItemsCache *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  int iVar4;
  id pvVar5;
  id local_14;
  
  pvVar1 = _objc_msgSend(self,sel_stack);
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperChildren);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectEnumerator);
  pvVar2 = _objc_msgSend(pvVar1,sel_nextObject);
  if (pvVar2 != (id)0x0) {
    local_14 = (id)0x0;
    do {
      pvVar5 = pvVar2;
      pvVar3 = _objc_msgSend(self,sel_itemForCard_,pvVar2);
      pvVar3 = _objc_msgSend(pvVar3,sel_retain);
      if (pvVar3 == (id)0x0) {
        pvVar3 = _objc_msgSend(cls_HSStoryboardItem,sel_new,pvVar5);
        _objc_msgSend(pvVar3,sel_setCard_,pvVar2);
        _objc_msgSend(pvVar3,sel_setParent_,self->_parentView);
        _objc_msgSend(self->_items,sel_insertObject_atIndex_,pvVar3,local_14);
        _objc_msgSend(self,sel_registerForActionsAttributeChangesForItem_,pvVar3);
        pvVar2 = self->_parentView;
LAB_0008ee40:
        pvVar5 = pvVar3;
        _objc_msgSend(pvVar2,sel_storyboardItemsCacheDidAddItem_atIndex_,pvVar3,local_14);
      }
      else {
        pvVar5 = pvVar3;
        pvVar2 = _objc_msgSend(self->_items,sel_indexOfObject_,pvVar3);
        if (local_14 != pvVar2) {
          _objc_msgSend(self->_parentView,sel_storyboardItemsCacheWillRemoveItem_atIndex_,pvVar3,
                        pvVar2);
          _objc_msgSend(self,sel_unregisterForActionsAttributeChangesForItem_,pvVar3);
          _objc_msgSend(pvVar3,sel_setParent_,0);
          _objc_msgSend(self->_items,sel_removeObject_,pvVar3);
          _objc_msgSend(self->_parentView,sel_storyboardItemsCacheDidRemoveItem_atIndex_,pvVar3,
                        pvVar2);
          _objc_msgSend(pvVar3,sel_setParent_,self->_parentView);
          _objc_msgSend(self->_items,sel_insertObject_atIndex_,pvVar3,local_14);
          _objc_msgSend(self,sel_registerForActionsAttributeChangesForItem_,pvVar3);
          pvVar2 = self->_parentView;
          goto LAB_0008ee40;
        }
      }
      _objc_msgSend(pvVar3,sel_release,pvVar5);
      local_14 = (id)((int)local_14 + 1);
      pvVar2 = _objc_msgSend(pvVar1,sel_nextObject);
    } while (pvVar2 != (id)0x0);
  }
  pvVar1 = _objc_msgSend(self,sel_stack);
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperCount);
  pvVar2 = _objc_msgSend(self->_items,sel_count);
  while (pvVar1 < pvVar2) {
    pvVar2 = _objc_msgSend(self->_items,sel_count);
    iVar4 = (int)pvVar2 + -1;
    pvVar2 = _objc_msgSend(self->_items,sel_objectAtIndex_,iVar4);
    _objc_msgSend(self,sel_unregisterForActionsAttributeChangesForItem_,pvVar2);
    _objc_msgSend(self->_parentView,sel_storyboardItemsCacheWillRemoveItem_atIndex_,pvVar2,iVar4);
    _objc_msgSend(self->_items,sel_removeObjectAtIndex_,iVar4);
    _objc_msgSend(self->_parentView,sel_storyboardItemsCacheDidRemoveItem_atIndex_,pvVar2,iVar4);
    pvVar2 = _objc_msgSend(self->_items,sel_count);
  }
  _objc_msgSend(self->_draggedItems,sel_release);
  self->_draggedItems = (id)0x0;
  return;
}

*/
- (void)synchronizeWithStack
{
    NSEnumerator *enumerator = [[[self stack] hyperChildren] objectEnumerator];
    NSUInteger index = 0;
    id card;
    while ((card = [enumerator nextObject]) != nil) {
        id item = [[self itemForCard:card] retain];
        if (item == nil) {
            item = [HSStoryboardItem new];
            [item setCard:card];
            [item setParent:_parentView];
            [_items insertObject:item atIndex:index];
            [self registerForActionsAttributeChangesForItem:item];
            [_parentView storyboardItemsCacheDidAddItem:item atIndex:index];
        } else {
            NSUInteger oldIndex = [_items indexOfObject:item];
            if (index != oldIndex) {
                [_parentView storyboardItemsCacheWillRemoveItem:item atIndex:oldIndex];
                [self unregisterForActionsAttributeChangesForItem:item];
                [item setParent:nil];
                [_items removeObject:item];
                [_parentView storyboardItemsCacheDidRemoveItem:item atIndex:oldIndex];
                [item setParent:_parentView];
                [_items insertObject:item atIndex:index];
                [self registerForActionsAttributeChangesForItem:item];
                [_parentView storyboardItemsCacheDidAddItem:item atIndex:index];
            }
        }
        [item release];
        index++;
    }
    while ([[self stack] hyperCount] < [_items count]) {
        NSUInteger last = [_items count] - 1;
        id item = [_items objectAtIndex:last];
        [self unregisterForActionsAttributeChangesForItem:item];
        [_parentView storyboardItemsCacheWillRemoveItem:item atIndex:last];
        [_items removeObjectAtIndex:last];
        [_parentView storyboardItemsCacheDidRemoveItem:item atIndex:last];
    }
    [_draggedItems release];
    _draggedItems = nil;
}

- (void)invalidateAllItems
{
    NSEnumerator *self_00;
    id self_01;

    self_00 = [_items objectEnumerator];
    while( YES ) {
        self_01 = [self_00 nextObject];
        if (self_01 == nil) break;
        [self_01 invalidateAllImageCaches];
    }
}

- (void)invalidateAllItemsWithoutThumbnails
{
    NSEnumerator *self_00;
    id self_01;

    self_00 = [_items objectEnumerator];
    while( YES ) {
        self_01 = [self_00 nextObject];
        if (self_01 == nil) break;
        [self_01 invalidateImageCaches];
    }
}

- (void)invalidate
{
    [self rebuildCache];
}

- (void)invalidateWithChangedItemOrder
{
    [self synchronizeWithStack];
}

- (void)invalidateWithRemovedItem
{
    [self synchronizeWithStack];
}

- (void)invalidateWithAddedItem
{
    [self synchronizeWithStack];
}

- (void)selectAllItems
{
    NSEnumerator *self_00;
    id self_01;

    self_00 = [_items objectEnumerator];
    while( YES ) {
        self_01 = [self_00 nextObject];
        if (self_01 == nil) break;
        [self_01 setSelected:YES];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008f161 @ 0008f161, 278 bytes * /

id FUN_0008f161(HSStoryboardItemsCache *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_selectedItems);
  pvVar1 = _objc_msgSend(pvVar1,sel_count);
  if (pvVar1 < (id)0x2) {
    pvVar1 = _objc_msgSend(self,sel_selectedItems);
    pvVar1 = _objc_msgSend(pvVar1,sel_extraFirstObject);
    op = sel_card;
  }
  else {
    pvVar1 = _objc_msgSend(cls_NSMutableArray,sel_array);
    pvVar2 = _objc_msgSend(self,sel_selectedItems);
    pvVar2 = _objc_msgSend(pvVar2,sel_objectEnumerator);
    while (pvVar3 = _objc_msgSend(pvVar2,sel_nextObject), op = sel_queryHyperInterfaceForAllObjects_
          , pvVar3 != (id)0x0) {
      pvVar3 = _objc_msgSend(pvVar3,sel_card);
      _objc_msgSend(pvVar1,sel_addObject_,pvVar3);
    }
  }
  pvVar1 = _objc_msgSend(pvVar1,op);
  return pvVar1;
}

*/
- (id)selectedHyperObject
{
    if ([[self selectedItems] count] < 2) {
        return [[[self selectedItems] extraFirstObject] card];
    }
    NSMutableArray *cards = [NSMutableArray array];
    NSEnumerator *enumerator = [[self selectedItems] objectEnumerator];
    id item;
    while ((item = [enumerator nextObject]) != nil) {
        [cards addObject:[item card]];
    }
    return [cards queryHyperInterfaceForAllObjects:@protocol(HSCardAttributes)];
    return 0;
}

- (id)activeCard
{
    return [[[self selectedItems] extraFirstObject] card];
}

- (id)selectedItemsIndexes
{
    id self_00;
    NSEnumerator *self_01;
    id pvVar1_2;

    self_00 = [[NSMutableIndexSet alloc] initWithIndexSet:[NSIndexSet indexSet]];
    self_01 = [_items objectEnumerator];
    pvVar1_2 = [self_01 nextObject];
    while (pvVar1_2 != nil) {
        if ([pvVar1_2 isSelected]) {
            [self_00 addIndex:[self indexOfStoryboardItem:pvVar1_2]];
        }
        pvVar1_2 = [self_01 nextObject];
    }
    return [self_00 autorelease];
}

- (id)selectedItems
{
    id pvVar1;
    id self_00;
    id local_14;

    local_14 = nil;
    pvVar1 = [_items objectEnumerator];
    while( YES ) {
        self_00 = [pvVar1 nextObject];
        if (self_00 == nil) break;
        if ([self_00 isSelected]) {
            if (local_14 == nil) {
                local_14 = [NSMutableArray new];
            }
            [local_14 addObject:self_00];
        }
    }
    if (local_14 == nil) {
        pvVar1 = nil;
    }
    else {
        pvVar1 = [NSArray arrayWithArray:local_14];
        [local_14 release];
    }
    return pvVar1;
}

- (id)itemForCard:(id)aCard
{
    NSEnumerator *self_00;
    id pvVar1;
    id self_01;

    self_00 = [_items objectEnumerator];
    do {
        self_01 = [self_00 nextObject];
        if (self_01 == nil) {
            return nil;
        }
        pvVar1 = [self_01 card];
    } while (pvVar1 != aCard);
    return self_01;
}

- (NSUInteger)indexOfStoryboardItem:(id)aItem
{
    return (unsigned int)[_items indexOfObject:aItem];
}

- (id)objectInStoryboardItemsAtIndex:(NSUInteger)aIndex
{
    return [_items objectAtIndex:aIndex];
}

- (NSUInteger)numberOfItems
{
    return (unsigned int)[_items count];
}

- (void)setStack:(id)aStack
{
    if (_stack != aStack) {
        [_stack release];
        _stack = [aStack retain];
        [self invalidate];
    }
}

- (id)stack
{
    return _stack;
}

- (id)parentView
{
    return _parentView;
}

- (void)setParentView:(id)aView
{
    if (_parentView != aView) {
        _parentView = aView;
        [_items makeObjectsPerformSelector:@selector(setParent:) withObject:aView];
    }
}

- (void)dealloc
{
    [_items makeObjectsPerformSelector:@selector(setParent:) withObject:nil];
    [_items release];
    [_stack release];
    [_draggedItems release];
    [_dragPlaceholder release];
    [_draggedItemsInitialIndexes release];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008e0f9 @ 0008e0f9, 64 bytes * /

id FUN_0008e0f9(HSStoryboardItemsCache *self,SEL _cmd)

{
  id pvVar1;
  HSStoryboardItemsCache *local_c;
  undefined *local_8;
  
  local_c = self;
  local_8 = PTR_s_NSObject_0034ec50;
  pvVar1 = _objc_msgSendSuper(&local_c,sel_init);
  if (pvVar1 != (id)0x0) {
    *(undefined4 *)((int)pvVar1 + 0x20) = 0x7fffffff;
  }
  return pvVar1;
}

*/
- (id)init
{
    self = [super init];
    if (self != nil) {
        _dropIndex = NSNotFound;
    }
    return self;
    return 0;
}

@end

