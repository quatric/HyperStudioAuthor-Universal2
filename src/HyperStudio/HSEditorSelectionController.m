#import "HSEditorSelectionController.h"

static id sLastNotifiedSelectionController;
static id sLastNotifiedSelectedObject;
static id sLastNotifiedActiveHolder;

@implementation HSEditorSelectionController

/* i386 ivar offsets: _windowController=0x4, _activeSelectionHolder=0x8, _activeSelectionHolderWasExplicitlySet=0xc, _isEnabled=0xd, _cardView=0x10, _stackController=0x14, _storyboardView=0x18, _addChildGroupingCount=0x1c, _removeChildGroupingCount=0x20, _addedChildrenWithinGroup=0x24, _processingActivation=0x28, _synchronizingWithInactiveSelectionHolder=0x29, _pendingActiveSelectionHolderRequest=0x2a */

- (BOOL)refreshActiveSelectionHolderByRemovingSelectionHolder:(id)aHolder
{
    return (BOOL)[self refreshActiveSelectionHolderByRemovingSelectionHolder:aHolder withAddedSelectionHolder:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00068ab7 @ 00068ab7, 171 bytes * /

BOOL FUN_00068ab7(HSEditorSelectionController *self,SEL _cmd,
                 id refreshActiveSelectionHolderByRemovingSelectionHolder,
                 id withAddedSelectionHolder)

{
  bool bVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  undefined4 uVar5;
  undefined4 uVar6;
  
  if ((self->_activeSelectionHolder == (id)0x0) ||
     (self->_activeSelectionHolder != refreshActiveSelectionHolderByRemovingSelectionHolder)) {
    bVar1 = false;
  }
  else {
    self->_activeSelectionHolder = (id)0x0;
    bVar1 = true;
  }
  uVar6 = 0;
  uVar5 = 0;
  pvVar3 = (id)0x0;
  pvVar2 = _objc_msgSend(self,
                         sel_refreshActiveSelectionHolderWithNotificationFromHolder_wantsToActivate_wantsToBecomeFirstResponder_
                         ,0,0,0);
  if ((withAddedSelectionHolder != (id)0x0) &&
     (pvVar4 = self->_activeSelectionHolder, pvVar4 != withAddedSelectionHolder)) {
    _objc_msgSend(withAddedSelectionHolder,sel_updateSelectionWithSelectionAccessor_,pvVar4,uVar5,
                  uVar6);
    pvVar3 = pvVar4;
  }
  if (bVar1 || (char)pvVar2 != '\0') {
    _objc_msgSend(self,sel_postHyperSelectionDidChangeNotification,pvVar3,uVar5,uVar6);
  }
  return bVar1 || (char)pvVar2 != '\0';
}

*/
- (BOOL)refreshActiveSelectionHolderByRemovingSelectionHolder:(id)aHolder withAddedSelectionHolder:(id)aHolder2
{
    BOOL removed = NO;
    if (_activeSelectionHolder != nil && _activeSelectionHolder == aHolder) {
        _activeSelectionHolder = nil;
        removed = YES;
    }
    BOOL refreshed = [self refreshActiveSelectionHolderWithNotificationFromHolder:nil wantsToActivate:NO wantsToBecomeFirstResponder:NO];
    if (aHolder2 != nil && _activeSelectionHolder != aHolder2) {
        [aHolder2 updateSelectionWithSelectionAccessor:_activeSelectionHolder];
    }
    if (removed || refreshed) {
        [self postHyperSelectionDidChangeNotification];
    }
    return removed || refreshed;
    return 0;
}

- (BOOL)refreshActiveSelectionHolder
{
    BOOL pvVar1;

    pvVar1 = [self refreshActiveSelectionHolderWithNotificationFromHolder:nil wantsToActivate:NO wantsToBecomeFirstResponder:NO];
    if (pvVar1) {
        [self postHyperSelectionDidChangeNotification];
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0006896c @ 0006896c, 233 bytes * /

BOOL FUN_0006896c(HSEditorSelectionController *self,SEL _cmd,
                 id refreshActiveSelectionHolderWithNotificationFromHolder,BOOL wantsToActivate,
                 BOOL wantsToBecomeFirstResponder)

{
  BOOL BVar1;
  id pvVar2;
  char cVar3;
  
  if (self->_isEnabled == '\0') {
    cVar3 = '\0';
    refreshActiveSelectionHolderWithNotificationFromHolder = (id)0x0;
  }
  else {
    if ((wantsToActivate != '\0') || (self->_activeSelectionHolderWasExplicitlySet == '\0')) {
      pvVar2 = _objc_msgSend(refreshActiveSelectionHolderWithNotificationFromHolder,
                             sel_selectedHyperObject);
      if (pvVar2 != (id)0x0) {
        cVar3 = '\x01';
        goto LAB_000689fe;
      }
    }
    pvVar2 = _objc_msgSend(self->_activeSelectionHolder,sel_selectedHyperObject);
    if (pvVar2 == (id)0x0) {
      cVar3 = '\0';
      refreshActiveSelectionHolderWithNotificationFromHolder =
           _objc_msgSend(self,sel_preferredSelectionHolderForSelectionAccessor_,
                         refreshActiveSelectionHolderWithNotificationFromHolder);
    }
    else {
      cVar3 = self->_activeSelectionHolderWasExplicitlySet;
      refreshActiveSelectionHolderWithNotificationFromHolder = self->_activeSelectionHolder;
    }
  }
LAB_000689fe:
  if ((refreshActiveSelectionHolderWithNotificationFromHolder == self->_activeSelectionHolder) &&
     (cVar3 == self->_activeSelectionHolderWasExplicitlySet)) {
    BVar1 = '\0';
  }
  else {
    _objc_msgSend(self->_activeSelectionHolder,sel_displaySelectionHolderInactiveState);
    self->_activeSelectionHolder = refreshActiveSelectionHolderWithNotificationFromHolder;
    self->_activeSelectionHolderWasExplicitlySet = cVar3;
    _objc_msgSend(refreshActiveSelectionHolderWithNotificationFromHolder,
                  sel_displaySelectionHolderActiveStateAndBecomeFirstResponder_,
                  (int)wantsToBecomeFirstResponder);
    BVar1 = '\x01';
  }
  return BVar1;
}

*/
- (BOOL)refreshActiveSelectionHolderWithNotificationFromHolder:(id)aHolder wantsToActivate:(BOOL)aActivate wantsToBecomeFirstResponder:(BOOL)aResponder
{
    BOOL explicitly;
    if (!_isEnabled) {
        explicitly = NO;
        aHolder = nil;
    } else {
        if (aActivate || !_activeSelectionHolderWasExplicitlySet) {
            if ([aHolder selectedHyperObject] != nil) {
                explicitly = YES;
                goto compare;
            }
        }
        if ([_activeSelectionHolder selectedHyperObject] == nil) {
            explicitly = NO;
            aHolder = [self preferredSelectionHolderForSelectionAccessor:aHolder];
        } else {
            explicitly = _activeSelectionHolderWasExplicitlySet;
            aHolder = _activeSelectionHolder;
        }
    }
compare:
    if (aHolder == _activeSelectionHolder && explicitly == _activeSelectionHolderWasExplicitlySet) {
        return NO;
    }
    [_activeSelectionHolder displaySelectionHolderInactiveState];
    _activeSelectionHolder = aHolder;
    _activeSelectionHolderWasExplicitlySet = explicitly;
    [aHolder displaySelectionHolderActiveStateAndBecomeFirstResponder:aResponder];
    return YES;
    return 0;
}

- (id)preferredSelectionHolderForSelectionAccessor:(id)aAccessor
{
    id pvVar2;
    id self_00;
    NSEnumerator *pvVar1_2;

    pvVar1_2 = [[self allSelectionHoldersPrioritizedForSelectionAccessor:aAccessor] objectEnumerator];
    do {
        self_00 = [pvVar1_2 nextObject];
        if (self_00 == nil) {
            return nil;
        }
        pvVar2 = [self_00 selectedHyperObject];
    } while (pvVar2 == nil);
    return self_00;
}

- (id)allSelectionHolders
{
    return [self allSelectionHoldersPrioritizedForSelectionAccessor:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000686e9 @ 000686e9, 474 bytes * /

id FUN_000686e9(HSEditorSelectionController *self,SEL _cmd,
               id allSelectionHoldersPrioritizedForSelectionAccessor)

{
  id self_00;
  id pvVar1;
  undefined *puVar2;
  
  self_00 = _objc_msgSend(cls_NSMutableArray,sel_arrayWithCapacity_,3);
  puVar2 = &DAT_003649f4;
  pvVar1 = _objc_msgSend(allSelectionHoldersPrioritizedForSelectionAccessor,sel_queryHyperInterface_
                         ,&DAT_003649f4);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_cardView,puVar2);
    if (pvVar1 != (id)0x0) {
      puVar2 = _objc_msgSend(self,sel_cardView,puVar2);
      _objc_msgSend(self_00,sel_addObject_,puVar2);
    }
    pvVar1 = _objc_msgSend(self,sel_storyboardView,puVar2);
    if (pvVar1 != (id)0x0) {
      puVar2 = _objc_msgSend(self,sel_storyboardView,puVar2);
      _objc_msgSend(self_00,sel_addObject_,puVar2);
    }
    pvVar1 = _objc_msgSend(self,sel_stackController,puVar2);
    if (pvVar1 == (id)0x0) {
      return self_00;
    }
    pvVar1 = _objc_msgSend(self,sel_stackController,puVar2);
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_storyboardView,puVar2);
    if (pvVar1 != (id)0x0) {
      puVar2 = _objc_msgSend(self,sel_storyboardView,puVar2);
      _objc_msgSend(self_00,sel_addObject_,puVar2);
    }
    pvVar1 = _objc_msgSend(self,sel_stackController,puVar2);
    if (pvVar1 != (id)0x0) {
      puVar2 = _objc_msgSend(self,sel_stackController,puVar2);
      _objc_msgSend(self_00,sel_addObject_,puVar2);
    }
    pvVar1 = _objc_msgSend(self,sel_cardView,puVar2);
    if (pvVar1 == (id)0x0) {
      return self_00;
    }
    pvVar1 = _objc_msgSend(self,sel_cardView,puVar2);
  }
  _objc_msgSend(self_00,sel_addObject_,pvVar1);
  return self_00;
}

*/
- (id)allSelectionHoldersPrioritizedForSelectionAccessor:(id)aAccessor
{
    NSMutableArray *holders = [NSMutableArray arrayWithCapacity:3];
    if ([aAccessor queryHyperInterface:@protocol(HSCardSelectionAccessor)] == nil) {
        if ([self cardView] != nil) {
            [holders addObject:[self cardView]];
        }
        if ([self storyboardView] != nil) {
            [holders addObject:[self storyboardView]];
        }
        if ([self stackController] != nil) {
            [holders addObject:[self stackController]];
        }
    } else {
        if ([self storyboardView] != nil) {
            [holders addObject:[self storyboardView]];
        }
        if ([self stackController] != nil) {
            [holders addObject:[self stackController]];
        }
        if ([self cardView] != nil) {
            [holders addObject:[self cardView]];
        }
    }
    return holders;
    return 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000685fd @ 000685fd, 236 bytes * /

void FUN_000685fd(HSEditorSelectionController *self,SEL _cmd,
                 id updateAllSelectionHoldersAndChooseActiveWithSelectionAccessor,
                 id exceptSelectionHolder)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  id pvVar3;
  undefined4 uVar4;
  undefined4 uVar5;
  undefined1 local_16;
  undefined4 local_14;
  
  pvVar3 = updateAllSelectionHoldersAndChooseActiveWithSelectionAccessor;
  pvVar1 = _objc_msgSend(self,sel_allSelectionHoldersPrioritizedForSelectionAccessor_,
                         updateAllSelectionHoldersAndChooseActiveWithSelectionAccessor);
  local_16 = 0;
  local_14 = (id)0x0;
  pvVar1 = _objc_msgSend(pvVar1,sel_objectEnumerator);
  while( true ) {
    self_00 = _objc_msgSend(pvVar1,sel_nextObject,pvVar3);
    if (self_00 == (id)0x0) break;
    if (self_00 != exceptSelectionHolder) {
      pvVar3 = updateAllSelectionHoldersAndChooseActiveWithSelectionAccessor;
      pvVar2 = _objc_msgSend(self_00,sel_updateSelectionWithSelectionAccessor_,
                             updateAllSelectionHoldersAndChooseActiveWithSelectionAccessor);
      if (local_14 == (id)0x0 && (byte)pvVar2 != 0) {
        local_14 = self_00;
      }
      local_16 = local_16 | (byte)pvVar2;
    }
  }
  uVar5 = 1;
  uVar4 = 1;
  pvVar3 = _objc_msgSend(self,
                         sel_refreshActiveSelectionHolderWithNotificationFromHolder_wantsToActivate_wantsToBecomeFirstResponder_
                         ,local_14,1,1);
  if (local_16 != 0 || (char)pvVar3 != '\0') {
    _objc_msgSend(self,sel_postHyperSelectionDidChangeNotification,local_14,uVar4,uVar5);
  }
  return;
}

*/
- (void)updateAllSelectionHoldersAndChooseActiveWithSelectionAccessor:(id)aAccessor exceptSelectionHolder:(id)aHolder
{
    NSArray *holders = [self allSelectionHoldersPrioritizedForSelectionAccessor:aAccessor];
    BOOL changed = NO;
    id firstChanged = nil;
    NSEnumerator *enumerator = [holders objectEnumerator];
    id holder;
    while ((holder = [enumerator nextObject]) != nil) {
        if (holder != aHolder) {
            BOOL updated = [holder updateSelectionWithSelectionAccessor:aAccessor];
            if (firstChanged == nil && updated) {
                firstChanged = holder;
            }
            changed = changed || updated;
        }
    }
    BOOL refreshed = [self refreshActiveSelectionHolderWithNotificationFromHolder:firstChanged wantsToActivate:YES wantsToBecomeFirstResponder:YES];
    if (changed || refreshed) {
        [self postHyperSelectionDidChangeNotification];
    }
}

- (void)selectionHolderWantsToResignAndPassOnSelection:(id)aSelection
{
    [self updateAllSelectionHoldersAndChooseActiveWithSelectionAccessor:aSelection exceptSelectionHolder:aSelection];
}

- (void)selectionHolderWantsToReactivate:(id)aReactivate
{
    if (_activeSelectionHolder == aReactivate) {
        [self postHyperSelectionDidChangeNotificationForce:YES];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00068390 @ 00068390, 518 bytes * /

void FUN_00068390(HSEditorSelectionController *self,SEL _cmd,
                 id selectionHolderDidChangeSelectedHyperObject,BOOL wantsToActivate)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  int iVar6;
  undefined4 uVar7;
  
  if ((self->_processingActivation == '\0') &&
     (self->_synchronizingWithInactiveSelectionHolder == '\0')) {
    if ((wantsToActivate == '\0') &&
       (pvVar2 = _objc_msgSend(self,sel_shouldIgnoreChangeNotificationsFromSelectionHolder_,
                               selectionHolderDidChangeSelectedHyperObject), (char)pvVar2 != '\0'))
    {
      if (self->_cardView != selectionHolderDidChangeSelectedHyperObject) {
        return;
      }
      self->_synchronizingWithInactiveSelectionHolder = '\x01';
      pvVar2 = selectionHolderDidChangeSelectedHyperObject;
      pvVar3 = _objc_msgSend(self,sel_allSelectionHoldersPrioritizedForSelectionAccessor_,
                             selectionHolderDidChangeSelectedHyperObject);
      pvVar3 = _objc_msgSend(pvVar3,sel_objectEnumerator);
      while (pvVar4 = _objc_msgSend(pvVar3,sel_nextObject,pvVar2), pvVar4 != (id)0x0) {
        if ((pvVar4 != selectionHolderDidChangeSelectedHyperObject) &&
           (pvVar2 = selectionHolderDidChangeSelectedHyperObject,
           pvVar5 = _objc_msgSend(pvVar4,
                                  sel_isInterestedToBeSynchronizedWithInactiveCardViewSelectionAccessor_
                                  ,selectionHolderDidChangeSelectedHyperObject),
           (char)pvVar5 != '\0')) {
          pvVar2 = selectionHolderDidChangeSelectedHyperObject;
          _objc_msgSend(pvVar4,sel_updateSelectionWithInactiveCardViewSelectionAccessor_,
                        selectionHolderDidChangeSelectedHyperObject);
        }
      }
      self->_synchronizingWithInactiveSelectionHolder = '\0';
      return;
    }
    self->_processingActivation = '\x01';
    pvVar2 = selectionHolderDidChangeSelectedHyperObject;
    pvVar3 = _objc_msgSend(self,sel_allSelectionHoldersPrioritizedForSelectionAccessor_,
                           selectionHolderDidChangeSelectedHyperObject);
    pvVar3 = _objc_msgSend(pvVar3,sel_objectEnumerator);
    while (pvVar4 = _objc_msgSend(pvVar3,sel_nextObject,pvVar2), pvVar4 != (id)0x0) {
      if (pvVar4 != selectionHolderDidChangeSelectedHyperObject) {
        pvVar2 = selectionHolderDidChangeSelectedHyperObject;
        _objc_msgSend(pvVar4,sel_updateSelectionWithSelectionAccessor_,
                      selectionHolderDidChangeSelectedHyperObject);
      }
    }
    iVar6 = (int)wantsToActivate;
    uVar7 = 0;
    pvVar2 = selectionHolderDidChangeSelectedHyperObject;
    pvVar3 = _objc_msgSend(self,
                           sel_refreshActiveSelectionHolderWithNotificationFromHolder_wantsToActivate_wantsToBecomeFirstResponder_
                           ,selectionHolderDidChangeSelectedHyperObject,iVar6,0);
    if (((char)pvVar3 == '\0') &&
       (self->_activeSelectionHolder != selectionHolderDidChangeSelectedHyperObject)) {
      cVar1 = self->_pendingActiveSelectionHolderRequest;
      self->_processingActivation = '\0';
      self->_pendingActiveSelectionHolderRequest = '\0';
      if (cVar1 != '\0') {
        _objc_msgSend(self,sel_selectionHolderDidChangeSelectedHyperObject_wantsToActivate_,
                      self->_activeSelectionHolder,0,uVar7);
      }
    }
    else {
      _objc_msgSend(self,sel_postHyperSelectionDidChangeNotification,pvVar2,iVar6,uVar7);
      self->_processingActivation = '\0';
      self->_pendingActiveSelectionHolderRequest = '\0';
    }
  }
  else if (self->_activeSelectionHolder == selectionHolderDidChangeSelectedHyperObject) {
    self->_pendingActiveSelectionHolderRequest = '\x01';
  }
  return;
}

*/
- (void)selectionHolderDidChangeSelectedHyperObject:(id)aObject wantsToActivate:(BOOL)aActivate
{
    if (!_processingActivation && !_synchronizingWithInactiveSelectionHolder) {
        if (!aActivate && [self shouldIgnoreChangeNotificationsFromSelectionHolder:aObject]) {
            if (_cardView != aObject) {
                return;
            }
            _synchronizingWithInactiveSelectionHolder = YES;
            NSEnumerator *enumerator = [[self allSelectionHoldersPrioritizedForSelectionAccessor:aObject] objectEnumerator];
            id holder;
            while ((holder = [enumerator nextObject]) != nil) {
                if (holder != aObject && [holder isInterestedToBeSynchronizedWithInactiveCardViewSelectionAccessor:aObject]) {
                    [holder updateSelectionWithInactiveCardViewSelectionAccessor:aObject];
                }
            }
            _synchronizingWithInactiveSelectionHolder = NO;
            return;
        }
        _processingActivation = YES;
        NSEnumerator *enumerator = [[self allSelectionHoldersPrioritizedForSelectionAccessor:aObject] objectEnumerator];
        id holder;
        while ((holder = [enumerator nextObject]) != nil) {
            if (holder != aObject) {
                [holder updateSelectionWithSelectionAccessor:aObject];
            }
        }
        BOOL refreshed = [self refreshActiveSelectionHolderWithNotificationFromHolder:aObject wantsToActivate:aActivate wantsToBecomeFirstResponder:NO];
        if (!refreshed && _activeSelectionHolder != aObject) {
            BOOL pending = _pendingActiveSelectionHolderRequest;
            _processingActivation = NO;
            _pendingActiveSelectionHolderRequest = NO;
            if (pending) {
                [self selectionHolderDidChangeSelectedHyperObject:_activeSelectionHolder wantsToActivate:NO];
            }
        } else {
            [self postHyperSelectionDidChangeNotification];
            _processingActivation = NO;
            _pendingActiveSelectionHolderRequest = NO;
        }
    } else if (_activeSelectionHolder == aObject) {
        _pendingActiveSelectionHolderRequest = YES;
    }
}

- (BOOL)shouldIgnoreChangeNotificationsFromSelectionHolder:(id)aHolder
{
    BOOL pvVar1;

    if ((_activeSelectionHolder == aHolder) && (pvVar1 = [aHolder isPrimarySelectionAccessorForCurrentlyHeldSelection], pvVar1)) {
        return NO;
    }
    return _activeSelectionHolderWasExplicitlySet != NO;
}

- (id)hyperActiveSelectionHolder
{
    return _activeSelectionHolder;
}

- (id)selectedHyperObject
{
    id pvVar1;

    if (_isEnabled == NO) {
        pvVar1 = nil;
    }
    else {
        pvVar1 = [_activeSelectionHolder selectedHyperObject];
    }
    return pvVar1;
}

- (id)addedChildrenWithinGroup
{
    id pvVar1;

    pvVar1 = _addedChildrenWithinGroup;
    if (pvVar1 == nil) {
        pvVar1 = [[NSMutableArray alloc] init];
        _addedChildrenWithinGroup = pvVar1;
    }
    return pvVar1;
}

- (void)noteNodeContainer:(id)aContainer didRemoveChildren:(id)aChildren
{
    if (_removeChildGroupingCount == 0) {
        [self refreshActiveSelectionHolder];
        [self postHyperSelectionDidChangeNotification];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0006820b @ 0006820b, 130 bytes * /

void FUN_0006820b(HSEditorSelectionController *self,SEL _cmd,id noteNodeContainer,id didAddChild)

{
  SEL op;
  
  if (self->_addChildGroupingCount == 0) {
    didAddChild = _objc_msgSend(cls_HSAddedNodeSelectionAccessor,
                                sel_nodeSelectionAccessorWithObject_,didAddChild);
    op = sel_updateAllSelectionHoldersAndChooseActiveWithSelectionAccessor_exceptSelectionHolder_;
  }
  else {
    self = _objc_msgSend(self,sel_addedChildrenWithinGroup);
    op = sel_addObject_;
  }
  _objc_msgSend(self,op,didAddChild);
  return;
}

*/
- (void)noteNodeContainer:(id)aContainer didAddChild:(id)aChild
{
    if (_addChildGroupingCount == 0) {
        [self updateAllSelectionHoldersAndChooseActiveWithSelectionAccessor:[HSAddedNodeSelectionAccessor nodeSelectionAccessorWithObject:aChild] exceptSelectionHolder:nil];
    } else {
        [[self addedChildrenWithinGroup] addObject:aChild];
    }
}

- (void)noteNodeContainerRemoveChildrenEndGrouping:(id)aGrouping
{
    unsigned int uVar1;

    uVar1 = _removeChildGroupingCount - 1;
    _removeChildGroupingCount = uVar1;
    if (uVar1 == 0) {
        [self noteGroupOfChildrenRemoved];
    }
}

- (void)noteNodeContainerRemoveChildrenBeginGrouping:(id)aGrouping
{
    _removeChildGroupingCount = _removeChildGroupingCount + 1;
}

- (void)noteNodeContainerAddChildrenEndGrouping:(id)aGrouping
{
    unsigned int uVar1;

    uVar1 = _addChildGroupingCount - 1;
    _addChildGroupingCount = uVar1;
    if (uVar1 == 0) {
        [self noteGroupOfChildrenAdded:[self addedChildrenWithinGroup]];
        [[self addedChildrenWithinGroup] removeAllObjects];
    }
}

- (void)noteNodeContainerAddChildrenBeginGrouping:(id)aGrouping
{
    _addChildGroupingCount = _addChildGroupingCount + 1;
}

- (void)noteGroupOfChildrenRemoved
{
    [self refreshActiveSelectionHolder];
    [self postHyperSelectionDidChangeNotification];
}

- (void)noteGroupOfChildrenAdded:(id)aAdded
{
    [self updateAllSelectionHoldersAndChooseActiveWithSelectionAccessor:[HSAddedNodeSelectionAccessor nodeSelectionAccessorWithObjectsArray:aAdded] exceptSelectionHolder:nil];
}

- (void)noteWindowControllerWillClose
{
    [self setEnabled:NO];
    [self postHyperSelectionDidChangeNotification];
}

- (void)noteWindowControllerDidBecomeMain
{
    [self postHyperSelectionDidChangeNotification];
}

- (void)setEnabled:(BOOL)aEnabled
{
    if ((BOOL)_isEnabled != (aEnabled != NO)) {
        _isEnabled = aEnabled != NO;
        [self refreshActiveSelectionHolder];
    }
}

- (BOOL)isEnabled
{
    return _isEnabled;
}

- (id)storyboardView
{
    return _storyboardView;
}

- (void)setStoryboardView:(id)aView
{
    id self_00;
    id self_01;

    self_00 = _storyboardView;
    if (self_00 != aView) {
        [self_00 setSelectionChangeDelegate:nil];
        self_01 = [aView retain];
        _storyboardView = self_01;
        [self_01 setSelectionChangeDelegate:self];
        [self refreshActiveSelectionHolderByRemovingSelectionHolder:self_00];
        [self_00 release];
    }
}

- (id)stackController
{
    return _stackController;
}

- (void)setStackController:(id)aController
{
    id self_00;
    id self_01;

    self_00 = _stackController;
    if (self_00 != aController) {
        [self_00 setSelectionChangeDelegate:nil];
        self_01 = [aController retain];
        _stackController = self_01;
        [self_01 setSelectionChangeDelegate:self];
        [self refreshActiveSelectionHolderByRemovingSelectionHolder:self_00];
        [self_00 release];
    }
}

- (id)cardView
{
    return _cardView;
}

- (void)setCardView:(id)aView
{
    id self_00;
    id self_01;

    self_00 = _cardView;
    if (self_00 != aView) {
        if ([self_00 selectionChangeDelegate] == self) {
            [_cardView setSelectionChangeDelegate:nil];
        }
        self_01 = [aView retain];
        _cardView = self_01;
        [self_01 setSelectionChangeDelegate:self];
        [self refreshActiveSelectionHolderByRemovingSelectionHolder:self_00];
        [self_00 release];
    }
}

- (id)windowController
{
    return _windowController;
}

- (void)setWindowController:(id)aController
{
    _windowController = aController;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_cardView setSelectionChangeDelegate:nil];
    [_cardView release];
    [_stackController setSelectionChangeDelegate:nil];
    [_stackController release];
    [_addedChildrenWithinGroup release];
    [super dealloc];
}

@end

@implementation HSEditorSelectionController (HSSelectionChangeNotificationPosting)

- (void)postHyperSelectionDidChangeNotification
{
    [self postHyperSelectionDidChangeNotificationForce:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00068b9a @ 00068b9a, 220 bytes * /

void FUN_00068b9a(HSEditorSelectionController *self,SEL _cmd,
                 BOOL postHyperSelectionDidChangeNotificationForce)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  HSEditorSelectionController *pHVar3;
  
  pvVar1 = _objc_msgSend(self,sel_selectedHyperObject);
  pHVar3 = (HSEditorSelectionController *)0x0;
  if (pvVar1 != (id)0x0) {
    pHVar3 = self;
  }
  pvVar2 = _objc_msgSend(self,sel_hyperActiveSelectionHolder);
  if ((postHyperSelectionDidChangeNotificationForce == '\0') && (DAT_00342734 == pvVar1)) {
    if ((DAT_00342730 == pHVar3) && (DAT_00342738 == pvVar2)) {
      return;
    }
    if ((DAT_00342734 == pvVar1) && (DAT_00342738 == pvVar2)) goto LAB_00068c52;
  }
  self_00 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(self_00,sel_postNotificationName_object_,
                &cfstr_HSSelectionHolderDidChangeSelectionNotification,self);
LAB_00068c52:
  DAT_00342730 = pHVar3;
  if (pvVar1 == (id)0x0) {
    DAT_00342730 = (HSEditorSelectionController *)0x0;
  }
  DAT_00342734 = pvVar1;
  DAT_00342738 = pvVar2;
  return;
}

*/
- (void)postHyperSelectionDidChangeNotificationForce:(BOOL)aForce
{
    id selected = [self selectedHyperObject];
    id controller = (selected != nil) ? self : nil;
    id holder = [self hyperActiveSelectionHolder];
    if (!aForce && sLastNotifiedSelectedObject == selected) {
        if (sLastNotifiedSelectionController == controller && sLastNotifiedActiveHolder == holder) {
            return;
        }
        if (sLastNotifiedSelectedObject == selected && sLastNotifiedActiveHolder == holder) {
            goto update;
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSSelectionHolderDidChangeSelectionNotification" object:self];
update:
    sLastNotifiedSelectionController = controller;
    if (selected == nil) {
        sLastNotifiedSelectionController = nil;
    }
    sLastNotifiedSelectedObject = selected;
    sLastNotifiedActiveHolder = holder;
}

@end

