#import "HSStackController.h"

@implementation HSStackController

/* i386 ivar offsets: _stripScrollView=0x4, _stripSwitcher=0x8, _stackViewDelegate=0xc, _cardIndexHeader=0x10, _cardIndexContainerView=0x14, _scrollUpButton=0x18, _scrollDownButton=0x1c, _selectionChangeDelegate=0x20, _stack=0x24, _displayedCards=0x28, _badgedIconRenderersByUID=0x2c, _uidsToUpdatePreviewImage=0x30, _needsToUpdateImages=0x34, _onceInited=0x35, _isEditingDisabled=0x36, _draggedCard=0x38, _areBadgedIconsVisible=0x3c, _mediaStripUpdateDisabled=0x3d, _mediaStripUpdateTimer=0x40 */

- (id)previewImageToStoreForCard:(id)aCard
{
    return [self previewImageForCard:aCard];
}

- (id)thumbnailImageToStoreForCard:(id)aCard
{
    return [self thumbnailImageForCard:aCard];
}

- (NSRect)stackViewFrame
{
    NSRect result;

    result = [_stripScrollView frame];
    return result;
}

- (id)mediaStripSwitcher
{
    return _stripSwitcher;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00060889 @ 00060889, 1206 bytes * /

BOOL FUN_00060889(HSStackController *self,SEL _cmd,id mediaStrip,id acceptDrop,uint item,
                 uint dropOperation)

{
  undefined *self_00;
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  cfstringStruct *pcVar6;
  id self_01;
  SEL op;
  undefined *puVar7;
  
  self_00 = _objc_msgSend(acceptDrop,sel_draggingPasteboard);
  puVar1 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,&cfstr_HSCardPasteboardType);
  pvVar2 = _objc_msgSend(self_00,sel_availableTypeFromArray_,puVar1);
  puVar7 = (undefined *)item;
  if (pvVar2 != (id)0x0) {
    pvVar2 = _objc_msgSend(acceptDrop,sel_draggingSource,puVar1);
    puVar1 = sel_representedObject;
    pvVar2 = _objc_msgSend(pvVar2,sel_respondsToSelector_,sel_representedObject);
    if ((char)pvVar2 == '\0') {
      pvVar2 = (id)0x0;
    }
    else {
      pvVar2 = _objc_msgSend(acceptDrop,sel_draggingSource,puVar1);
      pvVar2 = _objc_msgSend(pvVar2,sel_representedObject);
    }
    pvVar3 = _objc_msgSend(acceptDrop,sel_draggingSource,puVar1);
    if (((pvVar3 == mediaStrip) ||
        ((pvVar2 != (id)0x0 && (pvVar3 = _objc_msgSend(self,sel_stack,puVar1), pvVar2 == pvVar3))))
       && (pvVar2 = _objc_msgSend(acceptDrop,sel_draggingSourceOperationMask,puVar1),
          ((uint)pvVar2 & 0x10) != 0)) {
      pvVar2 = _objc_msgSend(acceptDrop,sel_draggingSource);
      if ((pvVar2 != mediaStrip) || (self->_draggedCard == (id)0x0)) {
        pvVar3 = _objc_msgSend(cls_NSMutableArray,sel_array);
        pcVar6 = &cfstr_HSCardsIndexPasteboardType;
        pvVar2 = _objc_msgSend(self_00,sel_propertyListForType_,&cfstr_HSCardsIndexPasteboardType);
        pvVar4 = _objc_msgSend(pvVar2,sel_objectEnumerator);
        pvVar2 = _objc_msgSend(pvVar4,sel_nextObject);
        while (pvVar2 != (id)0x0) {
          pvVar5 = _objc_msgSend(self,sel_stack,pcVar6);
          pvVar2 = _objc_msgSend(pvVar2,sel_unsignedIntValue);
          pcVar6 = _objc_msgSend(pvVar5,sel_hyperChildAtIndex_,pvVar2);
          _objc_msgSend(pvVar3,sel_addObject_);
          pvVar2 = _objc_msgSend(pvVar4,sel_nextObject);
        }
        pvVar3 = _objc_msgSend(pvVar3,sel_objectEnumerator,pcVar6);
        pvVar2 = _objc_msgSend(pvVar3,sel_nextObject);
        puVar1 = &DAT_00363e78;
        for (pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_00363e78);
            pvVar2 != (id)0x0; pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_00363e78)
            ) {
          pvVar4 = _objc_msgSend(self,sel_stack,puVar1);
          pvVar5 = _objc_msgSend(pvVar4,sel_indexOfHyperChild_,pvVar2);
          self_01 = _objc_msgSend(self,sel_stack);
          pvVar4 = (id)(item - 1);
          if (item < pvVar5) {
            pvVar4 = (id)item;
          }
          _objc_msgSend(self_01,sel_setIndex_ofHyperChild_,pvVar4,pvVar2);
          pvVar2 = _objc_msgSend(pvVar3,sel_nextObject);
          puVar1 = &DAT_00363e78;
          item = item + (item < pvVar5);
        }
        goto LAB_00060ce5;
      }
      pvVar2 = _objc_msgSend(self,sel_stack);
      pvVar2 = _objc_msgSend(pvVar2,sel_hyperChildren);
      pvVar4 = _objc_msgSend(pvVar2,sel_indexOfObject_,self->_draggedCard);
      pvVar3 = _objc_msgSend(self,sel_stack);
      pvVar2 = self->_draggedCard;
      op = sel_setIndex_ofHyperChild_;
      puVar1 = (undefined *)item;
      puVar7 = (undefined *)item;
      if (pvVar4 < item) {
        puVar1 = (undefined *)(item - 1);
        puVar7 = (undefined *)(item - 1);
      }
    }
    else {
      pvVar2 = _objc_msgSend(acceptDrop,sel_draggingSourceOperationMask,puVar1);
      if (((uint)pvVar2 & 1) == 0) goto LAB_00060ce5;
      pvVar2 = _objc_msgSend(cls_HSCoachingHelpManager,sel_sharedCoachingHelpManager);
      _objc_msgSend(pvVar2,sel_disableObjectRegistration);
      pvVar2 = _objc_msgSend(self,sel_stack);
      _objc_msgSend(pvVar2,sel_insertCardsFromPasteboard_atIndex_,self_00,item);
      pvVar3 = _objc_msgSend(cls_HSCoachingHelpManager,sel_sharedCoachingHelpManager);
      op = sel_enableObjectRegistration;
      puVar1 = self_00;
      pvVar2 = (id)item;
    }
    _objc_msgSend(pvVar3,op,puVar1,pvVar2,puVar7);
  }
LAB_00060ce5:
  _objc_msgSend(self->_draggedCard,sel_release,puVar1);
  self->_draggedCard = (id)0x0;
  _objc_msgSend(mediaStrip,sel_reloadData);
  _objc_msgSend(mediaStrip,sel_selectItemAtIndex_,puVar7);
  return '\x01';
}

*/
- (BOOL)mediaStrip:(id)aStrip acceptDrop:(id)aDrop item:(NSUInteger)aItem dropOperation:(NSUInteger)aOperation
{
    NSPasteboard *pasteboard = [aDrop draggingPasteboard];
    NSUInteger selectIndex = aItem;

    if ([pasteboard availableTypeFromArray:[NSArray arrayWithObject:@"HSCardPasteboardType"]] != nil) {
        id representedObject = nil;
        if ([[aDrop draggingSource] respondsToSelector:@selector(representedObject)]) {
            representedObject = [[aDrop draggingSource] representedObject];
        }
        if (([aDrop draggingSource] == aStrip || (representedObject != nil && representedObject == [self stack]))
            && ([aDrop draggingSourceOperationMask] & NSDragOperationMove) != 0) {
            if ([aDrop draggingSource] == aStrip && _draggedCard != nil) {
                NSUInteger draggedIndex = [[[self stack] hyperChildren] indexOfObject:_draggedCard];
                selectIndex = draggedIndex < aItem ? aItem - 1 : aItem;
                [[self stack] setIndex:selectIndex ofHyperChild:_draggedCard];
            }
            else {
                NSMutableArray *cards = [NSMutableArray array];
                NSEnumerator *indexEnumerator = [[pasteboard propertyListForType:@"HSCardsIndexPasteboardType"] objectEnumerator];
                id index;
                while ((index = [indexEnumerator nextObject]) != nil) {
                    [cards addObject:[[self stack] hyperChildAtIndex:[index unsignedIntValue]]];
                }
                NSEnumerator *cardEnumerator = [cards objectEnumerator];
                NSUInteger insertIndex = aItem;
                id child;
                // Stops at the first object that is not a node child, as the original did.
                while ((child = [[cardEnumerator nextObject] queryHyperInterface:@protocol(HSNodeChild)]) != nil) {
                    NSUInteger childIndex = [[self stack] indexOfHyperChild:child];
                    [[self stack] setIndex:(insertIndex < childIndex ? insertIndex : insertIndex - 1) ofHyperChild:child];
                    if (insertIndex < childIndex) {
                        insertIndex++;
                    }
                }
            }
        }
        else if (([aDrop draggingSourceOperationMask] & NSDragOperationCopy) != 0) {
            [[HSCoachingHelpManager sharedCoachingHelpManager] disableObjectRegistration];
            [[self stack] insertCardsFromPasteboard:pasteboard atIndex:aItem];
            [[HSCoachingHelpManager sharedCoachingHelpManager] enableObjectRegistration];
        }
    }
    [_draggedCard release];
    _draggedCard = nil;
    [aStrip reloadData];
    [aStrip selectItemAtIndex:selectIndex];
    return YES;
}

- (NSUInteger)mediaStrip:(id)aStrip validateDrop:(id)aDrop proposedItem:(NSUInteger)aItem proposedDropOperation:(NSUInteger)aOperation
{
    return 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0006056a @ 0006056a, 799 bytes * /

BOOL FUN_0006056a(HSStackController *self,SEL _cmd,id mediaStrip,uint writeItemWithIndex,
                 id toPasteboard)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  undefined4 extraout_EDX;
  
  pvVar2 = _objc_msgSend(self,sel_displayedCards);
  pvVar2 = _objc_msgSend(pvVar2,sel_objectAtIndex_,writeItemWithIndex);
  pvVar2 = _objc_msgSend(pvVar2,sel_retain);
  self->_draggedCard = pvVar2;
  pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_00363c5c);
  pvVar3 = _objc_msgSend(self->_draggedCard,sel_queryHyperInterface_,&DAT_00363dec);
  pvVar3 = _objc_msgSend(pvVar3,sel_size);
  pvVar4 = _objc_msgSend(cls_NSImage,sel_alloc);
  pvVar2 = _objc_msgSend(pvVar2,sel_imageOfSize_visualizationProtocol_,pvVar3,extraout_EDX,
                         &DAT_00363c84);
  pvVar2 = _objc_msgSend(pvVar2,sel_TIFFRepresentation);
  pvVar2 = _objc_msgSend(pvVar4,sel_initWithData_,pvVar2);
  pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
  pvVar3 = _objc_msgSend(self->_draggedCard,sel_queryHyperInterface_,&DAT_00363e50);
  pvVar3 = _objc_msgSend(pvVar3,sel_mediaUIDs);
  if (pvVar3 != (id)0x0) {
    pvVar4 = _objc_msgSend(self->_draggedCard,sel_queryHyperInterface_,&DAT_00363e64);
    pvVar4 = _objc_msgSend(pvVar4,sel_unrefreshingUIDs);
    puVar1 = cls_HSPasteboardDataProvider;
    pvVar5 = _objc_msgSend(self,sel_zone);
    pvVar5 = _objc_msgSend(puVar1,sel_allocWithZone_,pvVar5);
    pvVar6 = _objc_msgSend(self,sel_stack);
    pvVar6 = _objc_msgSend(pvVar6,sel_cardGroupController);
    pvVar6 = _objc_msgSend(pvVar6,sel_allGroupedObjectsUIDs);
    puVar1 = cls_NSArray;
    pvVar7 = _objc_msgSend(self->_draggedCard,sel_fullDictionaryRepresentation);
    pvVar7 = _objc_msgSend(puVar1,sel_arrayWithObject_,pvVar7);
    pvVar2 = _objc_msgSend(pvVar5,sel_initWithCards_UIDs_groupUIDs_unrefreshingUIDs_cardImage_,
                           pvVar7,pvVar3,pvVar6,pvVar4,pvVar2);
    pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
    pvVar2 = _objc_msgSend(pvVar2,sel_declareTypesForPasteboard_,toPasteboard);
    puVar1 = cls_NSArray;
    pvVar3 = _objc_msgSend(cls_NSNumber,sel_numberWithUnsignedInt_,writeItemWithIndex);
    pvVar3 = _objc_msgSend(puVar1,sel_arrayWithObject_,pvVar3);
    if ((char)pvVar2 != '\0') {
      pvVar2 = _objc_msgSend(toPasteboard,sel_setPropertyList_forType_,pvVar3,
                             &cfstr_HSCardsIndexPasteboardType);
      return (char)pvVar2 != '\0';
    }
  }
  return '\0';
}

*/
- (BOOL)mediaStrip:(id)aStrip writeItemWithIndex:(NSUInteger)aIndex toPasteboard:(id)aPasteboard
{
    _draggedCard = [[[self displayedCards] objectAtIndex:aIndex] retain];
    id imageProvider = [_draggedCard queryHyperInterface:@protocol(HSUserObjectImageProvider)];
    NSSize size = [(id<HSSizeAttributes>)[_draggedCard queryHyperInterface:@protocol(HSSizeAttributes)] size];
    NSImage *image = [[[NSImage alloc] initWithData:[[imageProvider imageOfSize:size visualizationProtocol:@protocol(HSVisualization)] TIFFRepresentation]] autorelease];
    id mediaUIDs = [[_draggedCard queryHyperInterface:@protocol(HSMediaCopySupport)] mediaUIDs];
    if (mediaUIDs == nil) {
        return NO;
    }
    id unrefreshingUIDs = [[_draggedCard queryHyperInterface:@protocol(HSActionCopySupport)] unrefreshingUIDs];
    HSPasteboardDataProvider *provider = [[[HSPasteboardDataProvider allocWithZone:[self zone]] initWithCards:[NSArray arrayWithObject:[_draggedCard fullDictionaryRepresentation]] UIDs:mediaUIDs groupUIDs:[[[self stack] cardGroupController] allGroupedObjectsUIDs] unrefreshingUIDs:unrefreshingUIDs cardImage:image] autorelease];
    BOOL declared = [provider declareTypesForPasteboard:aPasteboard];
    NSArray *indexes = [NSArray arrayWithObject:[NSNumber numberWithUnsignedInt:(unsigned int)aIndex]];
    if (!declared) {
        return NO;
    }
    return [aPasteboard setPropertyList:indexes forType:@"HSCardsIndexPasteboardType"];
}

- (id)pasteboardTypesForMediaStrip:(id)aStrip
{
    return [NSArray arrayWithObjects:@"HSCardPasteboardType", @"HSCardsIndexPasteboardType", nil];
}

- (id)representedObjectForMediaStrip:(id)aStrip
{
    return [self stack];
}

- (void)mediaStripShouldResignFirstResponder:(id)aResponder
{
    id pvVar1_3;

    pvVar1_3 = [[[self stack] document] cardView];
    [[pvVar1_3 window] makeFirstResponder:pvVar1_3];
}

- (void)mediaStripShouldBecomeFirstResponder:(id)aResponder
{
    if ([[aResponder window] firstResponder] != aResponder) {
        [[aResponder window] makeFirstResponder:aResponder];
    }
}

- (void)setStackViewDelegate:(id)aDelegate
{
    _stackViewDelegate = aDelegate;
}

- (id)stackViewDelegate
{
    return _stackViewDelegate;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000603c9 @ 000603c9, 84 bytes * /

void FUN_000603c9(HSStackController *self,SEL _cmd,id mediaStripToggleCardIndex)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_isStripVisible);
  op = sel_hideCardIndex_;
  if ((char)pvVar1 != '\0') {
    op = sel_showCardIndex_;
  }
  _objc_msgSend(self,op,0);
  return;
}

*/
- (void)mediaStripToggleCardIndex:(id)aIndex
{
    if ([self isStripVisible]) {
        [self showCardIndex:nil];
    }
    else {
        [self hideCardIndex:nil];
    }
}

- (BOOL)mediaStrip:(id)aStrip handleKeyEventBySelector:(SEL)aSelector
{
    BOOL pvVar1;

    if ((_stackViewDelegate != nil) && (pvVar1 = [_stackViewDelegate respondsToSelector:@selector(stackView:handleKeyEventBySelector:)], pvVar1)) {
        return (BOOL)[_stackViewDelegate stackView:self handleKeyEventBySelector:aSelector];
    }
    return NO;
}

- (void)mediaStrip:(id)aStrip doubleClickedOnItemAtIndex:(NSUInteger)aIndex insideImage:(BOOL)aImage modifiers:(NSUInteger)aModifiers
{
    [self notifyDelegateOfClickCount:(aImage != NO) + 1 modifiers:aModifiers];
}

- (void)mediaStrip:(id)aStrip clickedOnItemAtIndex:(NSUInteger)aIndex insideImage:(BOOL)aImage
{
    if (aIndex != NSNotFound) {
        [self setActiveCardIndex:aIndex];
    }
    [self notifySelectionDidChangeAndConditionallyActivate:YES];
    [self notifyDelegateOfClickCount:1 modifiers:0];
}

- (BOOL)userInteractionEnabledForMediaStrip:(id)aStrip
{
    BOOL BVar1;

    if ([self stack] == nil) {
        BVar1 = YES;
    }
    else {
        if ([[[[self stack] document] navigationController] currentNavigationOperation] == nil) {
            if (![[[HSToolManager sharedToolManager] toolView] isOccupiedByTool]) {
                return ![[[self stack] document] isInAnimationMode];
            }
        }
        BVar1 = NO;
    }
    return BVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0006009e @ 0006009e, 266 bytes * /

void FUN_0006009e(HSStackController *self,SEL _cmd,int notifyDelegateOfClickCount,uint modifiers)

{
  id pvVar1;
  SEL op;
  undefined *puVar2;
  
  if (1 < notifyDelegateOfClickCount) {
    pvVar1 = _objc_msgSend(self,sel_stack);
    pvVar1 = _objc_msgSend(pvVar1,sel_isStackProtected);
    if (((char)pvVar1 == '\0') &&
       (pvVar1 = _objc_msgSend(self->_stackViewDelegate,sel_respondsToSelector_,
                               sel_selectActiveCardAndShowInspector), (char)pvVar1 != '\0')) {
      _objc_msgSend(self->_stackViewDelegate,sel_selectActiveCardAndShowInspector_,self);
      if ((modifiers & 0xffff0000) != 0x100000) {
        return;
      }
      puVar2 = sel_editActionsForActiveCard;
      pvVar1 = _objc_msgSend(self->_stackViewDelegate,sel_respondsToSelector_,
                             sel_editActionsForActiveCard);
      if ((char)pvVar1 == '\0') {
        return;
      }
      pvVar1 = self->_stackViewDelegate;
      op = sel_editActionsForActiveCard;
      goto LAB_00060166;
    }
  }
  puVar2 = sel_selectActiveCard;
  pvVar1 = _objc_msgSend(self->_stackViewDelegate,sel_respondsToSelector_,sel_selectActiveCard);
  if ((char)pvVar1 == '\0') {
    return;
  }
  pvVar1 = self->_stackViewDelegate;
  op = sel_selectActiveCard;
LAB_00060166:
  _objc_msgSend(pvVar1,op,puVar2);
  return;
}

*/
- (void)notifyDelegateOfClickCount:(NSInteger)aCount modifiers:(NSUInteger)aModifiers
{
    // The original asks for the argumentless selector but sends the one-argument variant;
    // HSEditorWindowController implements both.
    if (aCount > 1 && ![[self stack] isStackProtected] && [_stackViewDelegate respondsToSelector:@selector(selectActiveCardAndShowInspector)]) {
        [_stackViewDelegate selectActiveCardAndShowInspector:self];
        if ((aModifiers & 0xffff0000) == NSEventModifierFlagCommand && [_stackViewDelegate respondsToSelector:@selector(editActionsForActiveCard)]) {
            [_stackViewDelegate editActionsForActiveCard];
        }
        return;
    }
    if ([_stackViewDelegate respondsToSelector:@selector(selectActiveCard)]) {
        [_stackViewDelegate selectActiveCard];
    }
}

- (id)mediaStrip:(id)aStrip badgedIconForItemAtIndex:(NSUInteger)aIndex
{
    id pvVar1;

    if (_areBadgedIconsVisible == NO) {
        pvVar1 = nil;
    }
    else {
        pvVar1 = [[self badgedIconRendererForCardAtIndex:aIndex] combinedIconsImage];
    }
    return pvVar1;
}

- (id)mediaStrip:(id)aStrip labelForItemAtIndex:(NSUInteger)aIndex
{
    return [[_displayedCards objectAtIndex:aIndex] hyperTitle];
}

- (id)mediaStrip:(id)aStrip imageForItemAtIndex:(NSUInteger)aIndex
{
    return [self imageForCardAtIndex:aIndex];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00061026 @ 00061026, 267 bytes * /

ulonglong FUN_00061026(HSStackController *self,SEL _cmd,id mediaStrip,uint imageSizeForItemAtIndex)

{
  undefined *puVar1;
  char cVar2;
  id pvVar3;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  undefined *puVar4;
  undefined4 local_18;
  id local_14;
  
  pvVar3 = _objc_msgSend(self,sel_displayedCards);
  pvVar3 = _objc_msgSend(pvVar3,sel_objectAtIndex_,imageSizeForItemAtIndex);
  puVar4 = &DAT_00363dec;
  pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_00363dec);
  puVar1 = PTR_0033607c;
  local_14 = *(id *)PTR_0033607c;
  local_18 = *(undefined4 *)(PTR_0033607c + 4);
  if (pvVar3 != (id)0x0) {
    local_14 = _objc_msgSend(pvVar3,sel_size,puVar4);
    local_18 = extraout_EDX;
  }
  cVar2 = _NSEqualSizes(local_14,local_18,*(undefined4 *)puVar1,*(undefined4 *)(puVar1 + 4));
  if (cVar2 != '\0') {
    local_14 = _objc_msgSend(self,sel_imageSize);
    local_18 = extraout_EDX_00;
  }
  return CONCAT44(local_18,local_14);
}

*/
- (NSSize)mediaStrip:(id)aStrip imageSizeForItemAtIndex:(NSUInteger)aIndex
{
    id sizeAttributes = [[[self displayedCards] objectAtIndex:aIndex] queryHyperInterface:@protocol(HSSizeAttributes)];
    NSSize size = NSZeroSize;
    if (sizeAttributes != nil) {
        size = [(id<HSSizeAttributes>)sizeAttributes size];
    }
    if (NSEqualSizes(size, NSZeroSize)) {
        size = [self imageSize];
    }
    return size;
}

- (NSUInteger)numberOfRowsInMediaStrip:(id)aStrip
{
    return (unsigned int)[_displayedCards count];
}

- (void)setMediaStripUpdateDisabled:(BOOL)aDisabled
{
    _mediaStripUpdateDisabled = aDisabled;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005fef9 @ 0005fef9, 192 bytes * /

void FUN_0005fef9(HSStackController *self,SEL _cmd,id hideCardIndex)

{
  undefined4 uVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar2 = _objc_msgSend(cls_HSEditorController,sel_sharedDocumentController);
  pvVar2 = _objc_msgSend(pvVar2,sel_isMultiDocument);
  if ((char)pvVar2 == '\0') {
    pvVar2 = _objc_msgSend(cls_HSUI,sel_sharedUI);
    uVar1 = *(undefined4 *)PTR_00336128;
    pvVar3 = _objc_msgSend(cls_NSNumber,sel_numberWithBool_,0);
    _objc_msgSend(pvVar2,sel_setSettings_forKey_,pvVar3,uVar1);
  }
  _objc_msgSend(self->_stripSwitcher,sel_hideStrip_,hideCardIndex);
  return;
}

*/
- (void)hideCardIndex:(id)aIndex
{
    if (![[HSEditorController sharedDocumentController] isMultiDocument]) {
        [[HSUI sharedUI] setSettings:[NSNumber numberWithBool:NO] forKey:HSUIModeIsCardIndexShown];
    }
    [_stripSwitcher hideStrip:aIndex];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005fe39 @ 0005fe39, 192 bytes * /

void FUN_0005fe39(HSStackController *self,SEL _cmd,id showCardIndex)

{
  undefined4 uVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar2 = _objc_msgSend(cls_HSEditorController,sel_sharedDocumentController);
  pvVar2 = _objc_msgSend(pvVar2,sel_isMultiDocument);
  if ((char)pvVar2 == '\0') {
    pvVar2 = _objc_msgSend(cls_HSUI,sel_sharedUI);
    uVar1 = *(undefined4 *)PTR_00336128;
    pvVar3 = _objc_msgSend(cls_NSNumber,sel_numberWithBool_,1);
    _objc_msgSend(pvVar2,sel_setSettings_forKey_,pvVar3,uVar1);
  }
  _objc_msgSend(self->_stripSwitcher,sel_showStrip_,showCardIndex);
  return;
}

*/
- (void)showCardIndex:(id)aIndex
{
    if (![[HSEditorController sharedDocumentController] isMultiDocument]) {
        [[HSUI sharedUI] setSettings:[NSNumber numberWithBool:YES] forKey:HSUIModeIsCardIndexShown];
    }
    [_stripSwitcher showStrip:aIndex];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005fd6c @ 0005fd6c, 205 bytes * /

void FUN_0005fd6c(HSStackController *self,SEL _cmd,BOOL hideStripAndEnable,BOOL moveFrame)

{
  undefined4 uVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar2 = _objc_msgSend(cls_HSEditorController,sel_sharedDocumentController);
  pvVar2 = _objc_msgSend(pvVar2,sel_isMultiDocument);
  if ((char)pvVar2 == '\0') {
    pvVar2 = _objc_msgSend(cls_HSUI,sel_sharedUI);
    uVar1 = *(undefined4 *)PTR_00336128;
    pvVar3 = _objc_msgSend(cls_NSNumber,sel_numberWithBool_,0);
    _objc_msgSend(pvVar2,sel_setSettings_forKey_,pvVar3,uVar1);
  }
  _objc_msgSend(self->_stripSwitcher,sel_hideStripAndEnable_moveFrame_,(int)hideStripAndEnable,
                (int)moveFrame);
  return;
}

*/
- (void)hideStripAndEnable:(BOOL)aEnable moveFrame:(BOOL)aFrame
{
    if (![[HSEditorController sharedDocumentController] isMultiDocument]) {
        [[HSUI sharedUI] setSettings:[NSNumber numberWithBool:NO] forKey:HSUIModeIsCardIndexShown];
    }
    [_stripSwitcher hideStripAndEnable:aEnable moveFrame:aFrame];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005fca9 @ 0005fca9, 195 bytes * /

void FUN_0005fca9(HSStackController *self,SEL _cmd,BOOL hideStripAndEnable)

{
  undefined4 uVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar2 = _objc_msgSend(cls_HSEditorController,sel_sharedDocumentController);
  pvVar2 = _objc_msgSend(pvVar2,sel_isMultiDocument);
  if ((char)pvVar2 == '\0') {
    pvVar2 = _objc_msgSend(cls_HSUI,sel_sharedUI);
    uVar1 = *(undefined4 *)PTR_00336128;
    pvVar3 = _objc_msgSend(cls_NSNumber,sel_numberWithBool_,0);
    _objc_msgSend(pvVar2,sel_setSettings_forKey_,pvVar3,uVar1);
  }
  _objc_msgSend(self->_stripSwitcher,sel_hideStripAndEnable_,(int)hideStripAndEnable);
  return;
}

*/
- (void)hideStripAndEnable:(BOOL)aEnable
{
    if (![[HSEditorController sharedDocumentController] isMultiDocument]) {
        [[HSUI sharedUI] setSettings:[NSNumber numberWithBool:NO] forKey:HSUIModeIsCardIndexShown];
    }
    [_stripSwitcher hideStripAndEnable:aEnable];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005fbe6 @ 0005fbe6, 195 bytes * /

void FUN_0005fbe6(HSStackController *self,SEL _cmd,BOOL showStripAndEnable)

{
  undefined4 uVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar2 = _objc_msgSend(cls_HSEditorController,sel_sharedDocumentController);
  pvVar2 = _objc_msgSend(pvVar2,sel_isMultiDocument);
  if ((char)pvVar2 == '\0') {
    pvVar2 = _objc_msgSend(cls_HSUI,sel_sharedUI);
    uVar1 = *(undefined4 *)PTR_00336128;
    pvVar3 = _objc_msgSend(cls_NSNumber,sel_numberWithBool_,1);
    _objc_msgSend(pvVar2,sel_setSettings_forKey_,pvVar3,uVar1);
  }
  _objc_msgSend(self->_stripSwitcher,sel_showStripAndEnable_,(int)showStripAndEnable);
  return;
}

*/
- (void)showStripAndEnable:(BOOL)aEnable
{
    if (![[HSEditorController sharedDocumentController] isMultiDocument]) {
        [[HSUI sharedUI] setSettings:[NSNumber numberWithBool:YES] forKey:HSUIModeIsCardIndexShown];
    }
    [_stripSwitcher showStripAndEnable:aEnable];
}

- (BOOL)isStripVisible
{
    return (BOOL)[_stripSwitcher isStripVisible];
}

- (BOOL)stackViewPerformDragging:(id)aDragging
{
    return NO;
}

- (BOOL)selectCardWithUID:(id)aUID
{
    NSUInteger pvVar1;

    pvVar1 = [self indexOfCardWithUID:aUID];
    if (pvVar1 != NSNotFound) {
        [self selectCardWithIndex:pvVar1];
    }
    return pvVar1 != NSNotFound;
}

- (NSUInteger)indexOfCardWithUID:(id)aUID
{
    NSUInteger pvVar1;
    NSUInteger pvVar3;

    pvVar3 = 0;
    pvVar1 = [_displayedCards count];
    while( YES ) {
        if (pvVar1 <= pvVar3) {
            return NSNotFound;
        }
        if ([[[_displayedCards objectAtIndex:pvVar3] hyperUID] isEqual:aUID]) break;
        pvVar3 = (pvVar3 + 1);
    }
    return (unsigned int)pvVar3;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005f979 @ 0005f979, 348 bytes * /

void FUN_0005f979(HSStackController *self,SEL _cmd,uint selectCardWithIndex)

{
  id pvVar1;
  id self_00;
  uint uVar2;
  undefined4 uVar3;
  
  pvVar1 = _objc_msgSend(cls_HSEditorController,sel_sharedDocumentController);
  pvVar1 = _objc_msgSend(pvVar1,sel_currentDocument);
  self_00 = _objc_msgSend(self,sel_mediaStripView);
  uVar3 = 1;
  uVar2 = selectCardWithIndex;
  _objc_msgSend(self_00,sel_setSelectedItemIndex_force_,selectCardWithIndex,1);
  if (selectCardWithIndex != 0x7fffffff) {
    pvVar1 = _objc_msgSend(pvVar1,sel_modeSwitcher,uVar2,uVar3);
    pvVar1 = _objc_msgSend(pvVar1,sel_switching);
    if ((char)pvVar1 == '\0') {
      pvVar1 = _objc_msgSend(self,sel_mediaStripView,uVar2,uVar3);
      _objc_msgSend(pvVar1,sel_scrollItemAtIndexToCenter_,selectCardWithIndex);
      uVar2 = selectCardWithIndex;
    }
  }
  pvVar1 = _objc_msgSend(self,sel_mediaStripView,uVar2,uVar3);
  pvVar1 = _objc_msgSend(pvVar1,sel_selectedItemIndex);
  if (pvVar1 != (id)0x7fffffff) {
    pvVar1 = _objc_msgSend(self,sel_mediaStripView,uVar2,uVar3);
    pvVar1 = _objc_msgSend(pvVar1,sel_selectedItemIndex);
    _objc_msgSend(self,sel_setActiveCardIndex_,pvVar1);
  }
  _objc_msgSend(self,sel_notifySelectionDidChangeAndConditionallyActivate_,0);
  return;
}

*/
- (void)selectCardWithIndex:(NSUInteger)aIndex
{
    id document = [[HSEditorController sharedDocumentController] currentDocument];
    [(HSMediaStripView *)[self mediaStripView] setSelectedItemIndex:aIndex force:YES];
    if (aIndex != NSNotFound && ![[document modeSwitcher] switching]) {
        [(HSMediaStripView *)[self mediaStripView] scrollItemAtIndexToCenter:aIndex];
    }
    if ([(HSMediaStripView *)[self mediaStripView] selectedItemIndex] != NSNotFound) {
        [self setActiveCardIndex:[(HSMediaStripView *)[self mediaStripView] selectedItemIndex]];
    }
    [self notifySelectionDidChangeAndConditionallyActivate:NO];
}

- (void)mediaStripSwitcherDidShowMediaStrip:(id)aStrip
{

}

- (void)mediaStripSwitcherWillHideMediaStrip:(id)aStrip
{
    [self notifyHyperSelectionHolderWantsToResign];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005f8a6 @ 0005f8a6, 173 bytes * /

void FUN_0005f8a6(HSStackController *self,SEL _cmd,uint setActiveCardIndex)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_mediaStripView);
  pvVar1 = _objc_msgSend(pvVar1,sel_activeItemIndex);
  if (pvVar1 != (id)setActiveCardIndex) {
    pvVar1 = _objc_msgSend(self,sel_mediaStripView);
    _objc_msgSend(pvVar1,sel_setActiveItemIndex_force_,setActiveCardIndex,1);
    pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    _objc_msgSend(pvVar1,sel_postNotificationName_object_,
                  &cfstr_HSStackViewDidChangeActiveCardNotification,self);
  }
  return;
}

*/
- (void)setActiveCardIndex:(NSUInteger)aIndex
{
    if ([(HSMediaStripView *)[self mediaStripView] activeItemIndex] != aIndex) {
        [(HSMediaStripView *)[self mediaStripView] setActiveItemIndex:aIndex force:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSStackViewDidChangeActiveCardNotification" object:self];
    }
}

- (void)makeFirstResponder
{
    id self_00;

    self_00 = [self mediaStripView];
    if ([[self_00 window] firstResponder] != self_00) {
        [[self_00 window] makeFirstResponder:self_00];
    }
}

- (id)activeCard
{
    return [self cardAtIndex:[[self mediaStripView] activeItemIndex]];
}

- (BOOL)showsFirstResponderStatus
{
    return (BOOL)[[self mediaStripView] showsFirstResponderStatus];
}

- (void)displaySelectionHolderInactiveState
{
    [[self mediaStripView] setShowsFirstResponderStatus:NO];
}

- (void)displaySelectionHolderActiveStateAndBecomeFirstResponder:(BOOL)aResponder
{
    [[self mediaStripView] setShowsFirstResponderStatus:YES];
}

- (BOOL)isPrimarySelectionAccessorForCurrentlyHeldSelection
{
    BOOL bVar2;

    if (![self isStripVisible]) {
        bVar2 = NO;
    }
    else {
        bVar2 = [self showsFirstResponderStatus];
    }
    return bVar2;
}

- (BOOL)updateSelectionWithInactiveCardViewSelectionAccessor:(id)aAccessor
{
    return NO;
}

- (BOOL)isInterestedToBeSynchronizedWithInactiveCardViewSelectionAccessor:(id)aAccessor
{
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005f5e2 @ 0005f5e2, 233 bytes * /

BOOL FUN_0005f5e2(HSStackController *self,SEL _cmd,id updateSelectionWithSelectionAccessor)

{
  id pvVar1;
  undefined4 ****ppppuVar2;
  byte bVar3;
  undefined4 ****ppppuVar4;
  id *ppvVar5;
  undefined4 ***local_18;
  id local_14;
  
  pvVar1 = _objc_msgSend(updateSelectionWithSelectionAccessor,sel_queryHyperInterface_,&DAT_00363db0
                        );
  if ((pvVar1 == (id)0x0) &&
     (pvVar1 = _objc_msgSend(updateSelectionWithSelectionAccessor,sel_queryHyperInterface_,
                             &DAT_00363dd8), pvVar1 == (id)0x0)) {
    return '\0';
  }
  local_14 = (id)0x0;
  local_18 = (undefined4 ****)0x0;
  ppvVar5 = &local_14;
  ppppuVar4 = &local_18;
  _objc_msgSend(updateSelectionWithSelectionAccessor,sel_getSelectedHyperObject_orObjects_,ppppuVar4
                ,ppvVar5);
  if (local_14 == (id)0x0) {
    ppppuVar2 = (undefined4 ****)local_18;
    if ((undefined4 ****)local_18 == (undefined4 ****)0x0) {
      bVar3 = 0;
      goto LAB_0005f6a5;
    }
  }
  else {
    ppppuVar2 = _objc_msgSend(local_14,sel_lastObject,ppppuVar4,ppvVar5);
  }
  _objc_msgSend(self,sel_selectObject_,ppppuVar2,ppvVar5);
  bVar3 = 1;
  ppppuVar4 = ppppuVar2;
LAB_0005f6a5:
  pvVar1 = _objc_msgSend(self,sel_isStripVisible,ppppuVar4,ppvVar5);
  return bVar3 & (byte)pvVar1;
}

*/
- (BOOL)updateSelectionWithSelectionAccessor:(id)aAccessor
{
    id object = nil;
    id objects = nil;
    BOOL selected = NO;

    if ([aAccessor queryHyperInterface:@protocol(HSCardSelectionAccessor)] == nil && [aAccessor queryHyperInterface:@protocol(HSStackSelectionAccessor)] == nil) {
        return NO;
    }
    [aAccessor getSelectedHyperObject:&object orObjects:&objects];
    if (objects != nil) {
        object = [objects lastObject];
    }
    if (object != nil) {
        [self selectObject:object];
        selected = YES;
    }
    return selected && [self isStripVisible];
}

- (void)selectHyperObjects:(id)aObjects
{
    [self selectObject:[aObjects lastObject]];
    [self notifySelectionDidChangeAndConditionallyActivate:YES];
}

- (void)selectHyperStack
{
    [self selectCardWithIndex:NSNotFound];
    [self notifySelectionDidChangeAndConditionallyActivate:YES];
}

- (void)selectHyperObject:(id)aObject
{
    [self selectObject:aObject];
    [self notifySelectionDidChangeAndConditionallyActivate:YES];
}

- (void)selectObject:(id)aObject
{
    id pvVar1;
    NSUInteger pvVar3;
    id pvVar2_2;

    pvVar1 = [aObject queryHyperInterface:@protocol(HSStackAttributes)];
    pvVar3 = [[self mediaStripView] selectedItemIndex];
    pvVar2_2 = nil;
    if (pvVar1 == nil) {
        pvVar2_2 = aObject;
    }
    if ([pvVar2_2 implementsHyperInterface:@protocol(HSCardAttributes)]) {
        if ([_displayedCards count] != 0) {
            pvVar3 = [_displayedCards indexOfObject:pvVar2_2];
        }
    }
    if (pvVar3 != NSNotFound) {
        [self selectCardWithIndex:pvVar3];
    }
}

- (id)selectedHyperObject
{
    id pvVar1;

    if (_isEditingDisabled == NO) {
        pvVar1 = [self selectedCard];
        if (pvVar1 == nil) {
            pvVar1 = [self stack];
        }
    }
    else {
        pvVar1 = nil;
    }
    return pvVar1;
}

- (id)selectedCard
{
    return [self cardAtIndex:[[self mediaStripView] selectedItemIndex]];
}

- (id)cardAtIndex:(NSUInteger)aIndex
{
    NSUInteger pvVar1;

    if ((aIndex != NSNotFound) && (pvVar1 = [_displayedCards count], aIndex < pvVar1)) {
        return [_displayedCards objectAtIndex:aIndex];
    }
    return nil;
}

- (NSUInteger)numberOfCards
{
    return (unsigned int)[_displayedCards count];
}

- (void)invalidateSelectionChangeDelegate
{
    [self setSelectionChangeDelegate:nil];
}

- (void)setSelectionChangeDelegate:(id)aDelegate
{
    _selectionChangeDelegate = aDelegate;
}

- (id)selectionChangeDelegate
{
    return _selectionChangeDelegate;
}

- (void)cardActorDidChange:(id)aChange
{
    [self cardBadgedIconAffectingAttributeDidChangeForObject:[aChange object]];
}

- (void)cardGroupAttributeDidChange:(id)aChange
{
    [self cardBadgedIconAffectingAttributeDidChangeForObject:[aChange object]];
}

- (void)cardBadgedIconAffectingAttributeDidChange:(id)aChange
{
    [self cardBadgedIconAffectingAttributeDidChangeForObject:[aChange object]];
}

- (void)cardBadgedIconAffectingAttributeDidChangeForObject:(id)aObject
{
    id self_00;
    id pvVar1;
    NSUInteger pvVar2;

    self_00 = [aObject queryHyperInterface:@protocol(HSObjectAttributes)];
    pvVar1 = [self_00 hyperUID];
    if (pvVar1 != nil) {
        pvVar2 = [self indexOfCardWithUID:pvVar1];
        if ((pvVar1 != nil) && (pvVar2 != NSNotFound)) {
            if ([self cardAtIndex:pvVar2] == self_00) {
                [self updateBadgedIconForCardAtIndex:pvVar2 uid:pvVar1];
            }
        }
    }
}

- (void)updateBadgedIconsForAllItems
{
    NSUInteger pvVar1;
    NSInteger pvVar2;

    pvVar1 = [_displayedCards count];
    if (pvVar1 != 0) {
        pvVar2 = 0;
        do {
            [self updateBadgedIconForCardAtIndex:pvVar2 uid:nil];
            pvVar2 = (pvVar2 + 1);
        } while (pvVar2 < pvVar1);
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005efe0 @ 0005efe0, 262 bytes * /

void FUN_0005efe0(HSStackController *self,SEL _cmd,int updateBadgedIconForCardAtIndex,id uid)

{
  id pvVar1;
  SEL op;
  
  if (uid == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_cardAtIndex_,updateBadgedIconForCardAtIndex);
    uid = _objc_msgSend(pvVar1,sel_hyperUID);
  }
  else if ((updateBadgedIconForCardAtIndex == 0x7fffffff) &&
          (pvVar1 = _objc_msgSend(self,sel_indexOfCardWithUID_,uid), pvVar1 == (id)0x7fffffff)) {
    pvVar1 = (id)0x0;
    goto LAB_0005f080;
  }
  if (uid == (id)0x0) {
    pvVar1 = (id)0x0;
  }
  else {
    pvVar1 = _objc_msgSend(self->_badgedIconRenderersByUID,sel_objectForKey_,uid);
  }
LAB_0005f080:
  op = sel_invalidateTraits;
  if (self->_areBadgedIconsVisible != '\0') {
    pvVar1 = _objc_msgSend(pvVar1,sel_updateTraitsIfNeeded);
    if ((char)pvVar1 == '\0') {
      return;
    }
    pvVar1 = _objc_msgSend(self->_stripScrollView,sel_mediaStripView);
    op = sel_setNeedsDisplayForItemAtIndex_;
  }
  _objc_msgSend(pvVar1,op);
  return;
}

*/
- (void)updateBadgedIconForCardAtIndex:(NSInteger)aIndex uid:(id)aUid
{
    NSInteger index = aIndex;
    id uid = aUid;
    id renderer = nil;

    if (uid == nil) {
        uid = [[self cardAtIndex:index] hyperUID];
    }
    else if (index == NSNotFound) {
        index = [self indexOfCardWithUID:uid];
        if (index == NSNotFound) {
            uid = nil;
        }
    }
    if (uid != nil) {
        renderer = [_badgedIconRenderersByUID objectForKey:uid];
    }
    if (_areBadgedIconsVisible) {
        if ([renderer updateTraitsIfNeeded]) {
            [[_stripScrollView mediaStripView] setNeedsDisplayForItemAtIndex:index];
        }
    }
    else {
        [renderer invalidateTraits];
    }
}

- (void)cardBadgedIconDidChange:(id)aChange
{
    id pvVar1;
    NSUInteger pvVar2;

    pvVar1 = [aChange object];
    if ((pvVar1 != nil) && (_areBadgedIconsVisible != NO)) {
        pvVar2 = [self indexOfCardWithUID:[[_badgedIconRenderersByUID allKeysForObject:pvVar1] lastObject]];
        if (pvVar2 != NSNotFound) {
            [[_stripScrollView mediaStripView] setNeedsDisplayForItemAtIndex:pvVar2];
        }
    }
}

- (void)hideAuxiliaryIconsDidChange:(id)aChange
{
    [self refreshBadgedIconsVisibility];
}

- (void)refreshBadgedIconsVisibility
{
    [self setAreBadgedIconsVisible:(unsigned int)(![[NSUserDefaults standardUserDefaults] boolForKey:HSHideAuxiliaryIcons])];
    [[_stripScrollView mediaStripView] setShowsBadgedIcons:[self areBadgedIconsVisible]];
}

- (void)setAreBadgedIconsVisible:(BOOL)aVisible
{
    if (((BOOL)_areBadgedIconsVisible != (aVisible != NO)) && (_areBadgedIconsVisible = aVisible != NO, aVisible != NO)) {
        [[_badgedIconRenderersByUID allValues] makeObjectsPerformSelector:@selector(updateTraitsIfInvalid) withObject:nil];
    }
}

- (BOOL)areBadgedIconsVisible
{
    return _areBadgedIconsVisible;
}

- (id)badgedIconRendererForCardAtIndex:(NSUInteger)aIndex
{
    id pvVar2;
    id pvVar3;
    id pvVar1_2;
    id pvVar4_4;

    if (aIndex < [_displayedCards count]) {
        pvVar1_2 = [_displayedCards objectAtIndex:aIndex];
        pvVar2 = [pvVar1_2 hyperUID];
        if ((pvVar1_2 != nil) && (pvVar2 != nil)) {
            pvVar3 = [_badgedIconRenderersByUID objectForKey:pvVar2];
            if (pvVar3 != nil) {
                return pvVar3;
            }
            pvVar4_4 = [[[HSAuxiliaryUserObjectTraits alloc] init] autorelease];
            [pvVar4_4 setUserObject:pvVar1_2];
            [[self badgedIconRenderersByUID] setObject:pvVar4_4 forKey:pvVar2];
            return pvVar4_4;
        }
    }
    return nil;
}

- (void)stackAttributesChanged:(id)aChanged
{
    [self setNeedsToUpdateImages:YES];
    [self updateStackProtection];
}

- (void)updateStackProtection
{
    BOOL pvVar1;

    pvVar1 = [_stack isStackProtected];
    [[self mediaStripView] setDragAndDropEnabled:(unsigned int)(!pvVar1)];
}

- (void)cardTitleChanged:(id)aChanged
{
    id pvVar1_2;
    NSUInteger pvVar1_3;

    pvVar1_2 = [[aChanged object] queryHyperInterface:@protocol(HSNodeAttributes)];
    if (pvVar1_2 == nil) {
        pvVar1_3 = NSNotFound;
    }
    else {
        pvVar1_3 = [pvVar1_2 hyperIndex];
    }
    if (pvVar1_3 < [_displayedCards count]) {
        [[_stripScrollView mediaStripView] reloadItemAtIndex:pvVar1_3];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005eaec @ 0005eaec, 147 bytes * /

void FUN_0005eaec(HSStackController *self,SEL _cmd,
                 id HSStackController_HSUIModeSettingsDidChangeNotification)

{
  id pvVar1;
  SEL op;
  
  if (self->_stack != (id)0x0) {
    pvVar1 = _objc_msgSend(cls_HSUI,sel_sharedUI);
    pvVar1 = _objc_msgSend(pvVar1,sel_settingsForKey_,*(undefined4 *)PTR_00336128);
    pvVar1 = _objc_msgSend(pvVar1,sel_boolValue);
    op = sel_hideStrip_;
    if ((char)pvVar1 != '\0') {
      op = sel_showStrip_;
    }
    _objc_msgSend(self->_stripSwitcher,op,self);
  }
  return;
}

*/
- (void)HSStackController_HSUIModeSettingsDidChangeNotification:(id)aNotification
{
    if (_stack == nil) {
        return;
    }
    if ([[[HSUI sharedUI] settingsForKey:HSUIModeIsCardIndexShown] boolValue]) {
        [_stripSwitcher showStrip:self];
    }
    else {
        [_stripSwitcher hideStrip:self];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005ea2d @ 0005ea2d, 191 bytes * /

BOOL FUN_0005ea2d(HSStackController *self,SEL _cmd,id shouldSkipImagesUpdatingOnCardNotification)

{
  BOOL BVar1;
  id pvVar2;
  
  pvVar2 = _objc_msgSend(shouldSkipImagesUpdatingOnCardNotification,sel_attributeChange);
  if (pvVar2 == (id)0x80) {
    BVar1 = '\0';
  }
  else {
    if (DAT_003427ec == (id)0x0) {
      pvVar2 = _objc_msgSend(cls_NSEProtocolSet,sel_alloc);
      DAT_003427ec = _objc_msgSend(pvVar2,sel_initWithProtocols_,&DAT_00363cac,&DAT_00363c98,0);
    }
    pvVar2 = _objc_msgSend(shouldSkipImagesUpdatingOnCardNotification,
                           sel_HSStackController_changedVisualAttributes);
    pvVar2 = _objc_msgSend(DAT_003427ec,sel_intersectsProtocolSet_,pvVar2);
    BVar1 = (BOOL)pvVar2;
  }
  return BVar1;
}

*/
- (BOOL)shouldSkipImagesUpdatingOnCardNotification:(id)aNotification
{
    static NSEProtocolSet *sTextViewAttributes = nil;

    if ([aNotification attributeChange] == 0x80) {
        return NO;
    }
    if (sTextViewAttributes == nil) {
        sTextViewAttributes = [[NSEProtocolSet alloc] initWithProtocols:@protocol(HSSystemTextViewVerticalScrollPositionAttribute), @protocol(HSSystemTextViewSelectedRangeAttribute), nil];
    }
    return [sTextViewAttributes intersectsProtocolSet:[aNotification HSStackController_changedVisualAttributes]];
}

- (BOOL)isAnimationPlayingOnCard:(id)aCard
{
    BOOL bVar2;

    if ([[[aCard animationController] playingAnimations] count] == 0) {
        bVar2 = [[HSInteractiveAnimationManager sharedAnimationManager] hasCurrentlyPlayedAnimations];
    }
    else {
        bVar2 = YES;
    }
    return bVar2;
}

- (BOOL)performanceAllowsToUpdateImagesOnCardNotification:(id)aNotification
{
    BOOL bVar2;

    if (![self isAnimationPlayingOnCard:[aNotification object]]) {
        bVar2 = ![self shouldSkipImagesUpdatingOnCardNotification:aNotification];
    }
    else {
        bVar2 = NO;
    }
    return bVar2;
}

- (void)updateOnCardVisualAttributeNotification:(id)aNotification
{
    id pvVar1;

    pvVar1 = [aNotification object];
    [[self uidsToUpdatePreviewImage] addObject:[pvVar1 hyperUID]];
    if ([self performanceAllowsToUpdateImagesOnCardNotification:aNotification]) {
        [self setNeedsToUpdateImages:YES];
    }
}

- (void)HSStackController_cardVisualAttributesDidEndChangeContinuously:(id)aContinuously
{
    if ([[aContinuously HSStackController_changedVisualAttributes] count] != 0) {
        [self updateOnCardVisualAttributeNotification:aContinuously];
    }
}

- (void)HSStackController_cardVisualAttributesDidChange:(id)aChange
{
    if ([[aChange HSStackController_notContiniouslyChangedVisualAttributes] count] != 0) {
        [self updateOnCardVisualAttributeNotification:aChange];
    }
}

- (NSSize)imageSize
{
    return [[self stack] hyperCardSize];
}

- (id)imageForCardAtIndex:(NSUInteger)aIndex
{
    return [self imageForCard:[_displayedCards objectAtIndex:aIndex]];
}

- (id)imageForCard:(id)aCard
{
    id pvVar1_3;

    pvVar1_3 = [[[self stack] document] thumbnailImageForCard:aCard];
    if (pvVar1_3 == nil) {
        pvVar1_3 = [self thumbnailImageForCard:aCard];
        [[[self stack] document] setThumbnailImage:pvVar1_3 forCard:aCard];
        [[[self stack] document] setPreviewImage:[self previewImageForCard:aCard] forCard:aCard];
    }
    return pvVar1_3;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00061131 @ 00061131, 439 bytes * /

id FUN_00061131(HSStackController *self,SEL _cmd,id previewImageForCard)

{
  id pvVar1;
  float extraout_EDX;
  float fVar2;
  float fVar3;
  float fVar4;
  float fVar5;
  undefined1 local_1c [8];
  undefined4 local_14;
  undefined4 local_10;
  
  pvVar1 = _objc_msgSend(self,sel_stack);
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperCardSize);
  fVar5 = *(float *)PTR_00336074;
  fVar4 = *(float *)(PTR_00336074 + 4);
  if ((640.0 < (float)pvVar1) || (480.0 < extraout_EDX)) {
    fVar2 = (float)pvVar1 / extraout_EDX;
    fVar5 = *(float *)PTR_00336078;
    fVar4 = *(float *)(PTR_00336078 + 4);
    if (fVar2 <= 1.3333334) {
      fVar3 = 480.0;
      pvVar1 = (id)(fVar2 * 480.0);
    }
    else {
      pvVar1 = (id)0x44200000;
      fVar3 = 640.0 / fVar2;
    }
    fVar4 = ((fVar4 + 240.0) - (fVar3 * 0.5 + fVar4)) + fVar4;
    fVar5 = ((fVar5 + 320.0) - ((float)pvVar1 * 0.5 + fVar5)) + fVar5;
  }
  else {
    fVar4 = ((fVar4 + 240.0) - (extraout_EDX * 0.5 + fVar4)) + fVar4;
    fVar5 = ((fVar5 + 320.0) - ((float)pvVar1 * 0.5 + fVar5)) + fVar5;
    fVar3 = extraout_EDX;
  }
  _NSIntegralRect(local_1c,CONCAT44(fVar4,fVar5),CONCAT44(fVar3,pvVar1));
  pvVar1 = _objc_msgSend(previewImageForCard,sel_queryHyperInterface_,&DAT_00363c5c);
  pvVar1 = _objc_msgSend(pvVar1,sel_imageOfSize_,local_14,local_10);
  return pvVar1;
}

*/
- (id)previewImageForCard:(id)aCard
{
    NSSize cardSize = [[self stack] hyperCardSize];
    NSRect rect;

    if (cardSize.width > 640.0 || cardSize.height > 480.0) {
        CGFloat ratio = cardSize.width / cardSize.height;
        if (ratio <= 1.3333334) {
            cardSize = NSMakeSize(ratio * 480.0, 480.0);
        }
        else {
            cardSize = NSMakeSize(640.0, 640.0 / ratio);
        }
    }
    rect = NSMakeRect(320.0 - cardSize.width * 0.5, 240.0 - cardSize.height * 0.5, cardSize.width, cardSize.height);
    rect = NSIntegralRect(rect);
    return [[aCard queryHyperInterface:@protocol(HSUserObjectImageProvider)] imageOfSize:rect.size];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005e4df @ 0005e4df, 341 bytes * /

id FUN_0005e4df(HSStackController *self,SEL _cmd,id thumbnailImageForCard)

{
  id pvVar1;
  id pvVar2;
  float extraout_EDX;
  float fVar3;
  float fVar4;
  float fVar5;
  
  pvVar1 = _objc_msgSend(self,sel_mediaStripView);
  pvVar2 = _objc_msgSend(thumbnailImageForCard,sel_hyperIndex);
  pvVar1 = _objc_msgSend(pvVar1,sel_sizeForItemAtIndex_,pvVar2);
  if (((float)pvVar1 != 0.0) || (NAN((float)pvVar1))) {
    fVar4 = ABS((float)pvVar1);
  }
  else {
    fVar4 = 1.0;
  }
  fVar3 = 1.0;
  fVar5 = 0.0005;
  if (1.0 <= fVar4) {
    fVar5 = fVar4 * 0.0005;
  }
  if (fVar5 + 0.0 < (float)pvVar1) {
    if ((extraout_EDX != 0.0) || (NAN(extraout_EDX))) {
      fVar3 = ABS(extraout_EDX);
    }
    fVar4 = 0.0005;
    if (1.0 <= fVar3) {
      fVar4 = fVar3 * 0.0005;
    }
    if (fVar4 + 0.0 < extraout_EDX) {
      pvVar2 = _objc_msgSend(thumbnailImageForCard,sel_queryHyperInterface_,&DAT_00363c5c);
      pvVar1 = _objc_msgSend(pvVar2,sel_imageOfSize_visualizationProtocol_,pvVar1,extraout_EDX,
                             &DAT_00363c70);
      return pvVar1;
    }
  }
  return (id)0x0;
}

*/
- (id)thumbnailImageForCard:(id)aCard
{
    NSSize size = [(HSMediaStripView *)[self mediaStripView] sizeForItemAtIndex:[aCard hyperIndex]];
    CGFloat magnitude = size.width != 0.0 ? fabs(size.width) : 1.0;
    CGFloat epsilon = magnitude >= 1.0 ? magnitude * 0.0005 : 0.0005;
    if (size.width > epsilon) {
        magnitude = size.height != 0.0 ? fabs(size.height) : 1.0;
        epsilon = magnitude >= 1.0 ? magnitude * 0.0005 : 0.0005;
        if (size.height > epsilon) {
            return [[aCard queryHyperInterface:@protocol(HSUserObjectImageProvider)] imageOfSize:size visualizationProtocol:@protocol(HSPlayerVisualization)];
        }
    }
    return nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000612e8 @ 000612e8, 642 bytes * /

void FUN_000612e8(HSStackController *self,SEL _cmd,id refreshImages)

{
  int iVar1;
  int iVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  int local_6c [22];
  HSStackController *local_14;
  
  local_14 = self;
  _objc_exception_try_enter(local_6c);
  iVar1 = __setjmp(local_6c);
  if (iVar1 == 0) {
    pvVar3 = _objc_msgSend(local_14,sel_uidsToUpdatePreviewImage);
    pvVar3 = _objc_msgSend(pvVar3,sel_count);
    if ((pvVar3 != (id)0x0) && (local_14->_mediaStripUpdateDisabled == '\0')) {
      pvVar3 = _objc_msgSend(local_14,sel_uidsToUpdatePreviewImage);
      pvVar3 = _objc_msgSend(pvVar3,sel_objectEnumerator);
      while( true ) {
        pvVar6 = _objc_msgSend(pvVar3,sel_nextObject);
        if (pvVar6 == (id)0x0) break;
        pvVar4 = _objc_msgSend(local_14,sel_stack);
        pvVar4 = _objc_msgSend(pvVar4,sel_childWithUID_,pvVar6);
        pvVar5 = _objc_msgSend(local_14,sel_stack);
        pvVar5 = _objc_msgSend(pvVar5,sel_document);
        _objc_msgSend(pvVar5,sel_setThumbnailImage_forCard_,0,pvVar4);
        pvVar5 = _objc_msgSend(local_14,sel_stack);
        pvVar5 = _objc_msgSend(pvVar5,sel_document);
        _objc_msgSend(pvVar5,sel_setPreviewImage_forCard_,0,pvVar4);
        pvVar4 = _objc_msgSend(local_14->_stripScrollView,sel_mediaStripView);
        pvVar6 = _objc_msgSend(local_14,sel_indexOfCardWithUID_,pvVar6);
        _objc_msgSend(pvVar4,sel_reloadItemAtIndex_,pvVar6);
      }
      pvVar3 = _objc_msgSend(local_14,sel_uidsToUpdatePreviewImage);
      _objc_msgSend(pvVar3,sel_removeAllObjects);
    }
  }
  else {
    iVar2 = _objc_exception_extract(local_6c);
    _objc_exception_try_enter(local_6c);
    iVar1 = __setjmp(local_6c);
    if (iVar1 == 0) {
      iVar1 = _objc_exception_match(cls_NSException,iVar2);
      if (iVar1 != 0) goto LAB_00061535;
      _objc_exception_try_exit(local_6c);
    }
    else {
      iVar2 = _objc_exception_extract(local_6c);
    }
    if (iVar2 != 0) {
                    /* WARNING: Subroutine does not return * /
      _objc_exception_throw(iVar2);
    }
  }
LAB_00061535:
  _objc_exception_try_exit(local_6c);
  _objc_msgSend(local_14,sel_setNeedsToUpdateImages_,0);
  local_14->_mediaStripUpdateTimer = (id)0x0;
  return;
}

*/
- (void)refreshImages:(id)aImages
{
    @try {
        if ([[self uidsToUpdatePreviewImage] count] != 0 && !_mediaStripUpdateDisabled) {
            NSEnumerator *enumerator = [[self uidsToUpdatePreviewImage] objectEnumerator];
            id uid;
            while ((uid = [enumerator nextObject]) != nil) {
                id card = [[self stack] childWithUID:uid];
                [[[self stack] document] setThumbnailImage:nil forCard:card];
                [[[self stack] document] setPreviewImage:nil forCard:card];
                [[_stripScrollView mediaStripView] reloadItemAtIndex:[self indexOfCardWithUID:uid]];
            }
            [[self uidsToUpdatePreviewImage] removeAllObjects];
        }
    }
    @catch (NSException *exception) {
    }
    [self setNeedsToUpdateImages:NO];
    _mediaStripUpdateTimer = nil;
}

- (id)uidsToUpdatePreviewImage
{
    id pvVar1;

    pvVar1 = _uidsToUpdatePreviewImage;
    if (pvVar1 == nil) {
        pvVar1 = [NSMutableSet new];
        _uidsToUpdatePreviewImage = pvVar1;
    }
    return pvVar1;
}

- (BOOL)isEnabled
{
    return _isEditingDisabled == NO;
}

- (void)setEnabled:(BOOL)aEnabled
{
    if ((BOOL)_isEditingDisabled != (aEnabled == NO)) {
        _isEditingDisabled = aEnabled == NO;
        [self notifySelectionDidChangeAndConditionallyActivate:NO];
    }
}

- (void)notifySelectionDidChangeAndConditionallyActivate:(BOOL)aActivate
{
    char cVar1;

    if (aActivate == NO) {
        cVar1 = NO;
    }
    else {
        cVar1 = [self isStripVisible];
    }
    [self notifyHyperSelectionDidChangeAndActivate:cVar1];
}

- (BOOL)isCardNavigationEnabled
{
    return (BOOL)[[self mediaStripView] isEnabled];
}

- (void)setCardNavigationEnabled:(BOOL)aEnabled
{
    [[self mediaStripView] setEnabled:aEnabled];
}

- (void)setStack:(id)aStack forceSelection:(BOOL)aSelection
{
    int uVar1;
    id pvVar2;
    id pvVar2_3;
    int uVar1_2;

    if (_stack != aStack) {
        pvVar2 = nil;
        if (_stack != nil) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:0 object:_stack];
            uVar1 = HSActualDidAttributeChanges;
            [_stack removeObserver:self selector:@selector(stackAttributesChanged:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSStackAttributes)];
            [_stack removeObserver:self selector:@selector(stackContentsDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSNodeContainerChildrenAttribute)];
            [_stack removeObserver:self selector:@selector(HSStackController_cardVisualAttributesDidChange:) ofChanges:2 ofChildrenAttribute:@protocol(HSVisualAttribute)];
            [_stack removeObserver:self selector:@selector(HSStackController_cardVisualAttributesDidEndChangeContinuously:) ofChanges:0x80 ofChildrenAttribute:@protocol(HSVisualAttribute)];
            [_stack removeObserver:self selector:@selector(cardTitleChanged:) ofChanges:uVar1 ofChildrenAttribute:@protocol(HSCardTitleAttribute)];
            [_stack removeObserver:self selector:@selector(cardGroupAttributeDidChange:) ofChanges:uVar1 ofChildrenAttribute:@protocol(HSCardGroupAttribute)];
            [_stack removeObserver:self selector:@selector(cardActorDidChange:) ofChanges:uVar1 ofChildrenAttribute:@protocol(HSActionsAttribute)];
            pvVar2 = _stack;
        }
        [pvVar2 release];
        pvVar2_3 = [aStack retain];
        _stack = pvVar2_3;
        if (pvVar2_3 != nil) {
            uVar1_2 = HSActualDidAttributeChanges;
            [pvVar2_3 addObserver:self selector:@selector(stackAttributesChanged:) ofChanges:uVar1_2 ofAttributesOfHyperInterface:@protocol(HSStackAttributes) withPriority:-0.25];
            [_stack addObserver:self selector:@selector(stackContentsDidChange:) ofChanges:uVar1_2 ofAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:-0.25];
            [_stack addObserver:self selector:@selector(HSStackController_cardVisualAttributesDidChange:) ofChanges:2 ofChildrenAttribute:@protocol(HSVisualAttribute) withPriority:-0.25]
            ;
            [_stack addObserver:self selector:@selector(HSStackController_cardVisualAttributesDidEndChangeContinuously:) ofChanges:0x80 ofChildrenAttribute:@protocol(HSVisualAttribute) withPriority:-0.25];
            [_stack addObserver:self selector:@selector(cardTitleChanged:) ofChanges:uVar1_2 ofChildrenAttribute:@protocol(HSCardTitleAttribute) withPriority:-0.25];
            [_stack addObserver:self selector:@selector(cardGroupAttributeDidChange:) ofChanges:uVar1_2 ofChildrenAttribute:@protocol(HSCardGroupAttribute) withPriority:-0.25];
            [_stack addObserver:self selector:@selector(cardActorDidChange:) ofChanges:uVar1_2 ofChildrenAttribute:@protocol(HSActionsAttribute) withPriority:-0.25];
            [self refreshBadgedIconsVisibility];
        }
        [self reloadCardsForceSelectionIfPossible:aSelection];
        [self updateStackProtection];
    }
}

- (void)setStack:(id)aStack
{
    [self setStack:aStack forceSelection:NO];
}

- (id)stack
{
    return _stack;
}

- (void)stackContentsDidChange:(id)aChange
{
    [self reloadCardsForceSelectionIfPossible:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005d9ff @ 0005d9ff, 1281 bytes * /

void FUN_0005d9ff(HSStackController *self,SEL _cmd,BOOL reloadCardsForceSelectionIfPossible)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  id pvVar8;
  id pvVar9;
  id local_1c;
  
  pvVar1 = _objc_msgSend(self,sel_mediaStripView);
  pvVar2 = _objc_msgSend(pvVar1,sel_selectedItemIndex);
  pvVar1 = _objc_msgSend(self,sel_selectedCard);
  pvVar3 = _objc_msgSend(pvVar1,sel_hyperUID);
  pvVar3 = _objc_msgSend(pvVar3,sel_retain);
  pvVar4 = _objc_msgSend(self,sel_stack);
  pvVar4 = _objc_msgSend(pvVar4,sel_hyperChildren);
  pvVar5 = _objc_msgSend(pvVar4,sel_count);
  pvVar6 = _objc_msgSend(self,sel_displayedCards);
  pvVar7 = _objc_msgSend(pvVar6,sel_count);
  local_1c = _objc_msgSend(pvVar4,sel_indexOfObject_,pvVar1);
  if (local_1c == (id)0x7fffffff) {
    if (pvVar2 == (id)0x7fffffff) {
      local_1c = (id)0x0;
    }
    else {
      local_1c = pvVar2;
      if ((pvVar5 < pvVar7) && (pvVar2 != (id)0x0)) {
        pvVar1 = pvVar2;
        for (pvVar8 = (id)0x0; pvVar8 != pvVar2; pvVar8 = (id)((int)pvVar8 + 1)) {
          pvVar9 = _objc_msgSend(pvVar6,sel_objectAtIndex_,pvVar1);
          pvVar9 = _objc_msgSend(pvVar4,sel_indexOfObject_,pvVar9);
          if (pvVar9 != (id)0x7fffffff) break;
          pvVar1 = (id)((int)pvVar1 + -1);
        }
        pvVar1 = _objc_msgSend(pvVar6,sel_objectAtIndex_,pvVar1);
        local_1c = _objc_msgSend(pvVar4,sel_indexOfObject_,pvVar1);
      }
    }
  }
  pvVar2 = _objc_msgSend(self,sel_displayedCards,pvVar1);
  _objc_msgSend(pvVar2,sel_removeAllObjects);
  pvVar2 = _objc_msgSend(cls_NSMutableSet,sel_set);
  if (pvVar5 != (id)0x0) {
    pvVar6 = (id)0x0;
    do {
      pvVar1 = _objc_msgSend(pvVar4,sel_objectAtIndex_,pvVar6);
      _objc_msgSend(self->_displayedCards,sel_addObject_,pvVar1);
      pvVar1 = _objc_msgSend(pvVar1,sel_hyperUID);
      _objc_msgSend(pvVar2,sel_addObject_,pvVar1);
      pvVar6 = (id)((int)pvVar6 + 1);
    } while (pvVar6 < pvVar5);
  }
  pvVar6 = _objc_msgSend(cls_NSMutableSet,sel_set,pvVar1);
  pvVar8 = _objc_msgSend(self->_badgedIconRenderersByUID,sel_keyEnumerator);
  pvVar4 = _objc_msgSend(pvVar8,sel_nextObject);
  while (pvVar4 != (id)0x0) {
    pvVar1 = pvVar4;
    pvVar9 = _objc_msgSend(pvVar2,sel_member_,pvVar4);
    if (pvVar9 == (id)0x0) {
      _objc_msgSend(pvVar6,sel_addObject_,pvVar4);
      pvVar1 = pvVar4;
    }
    pvVar4 = _objc_msgSend(pvVar8,sel_nextObject,pvVar1);
  }
  pvVar2 = _objc_msgSend(pvVar6,sel_objectEnumerator,pvVar1);
  while (pvVar4 = _objc_msgSend(pvVar2,sel_nextObject,pvVar1), pvVar4 != (id)0x0) {
    pvVar1 = _objc_msgSend(self->_badgedIconRenderersByUID,sel_objectForKey_,pvVar4);
    pvVar6 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    _objc_msgSend(pvVar6,sel_removeObserver_name_object_,self,0,pvVar1);
    _objc_msgSend(self->_badgedIconRenderersByUID,sel_removeObjectForKey_,pvVar4);
    pvVar1 = pvVar4;
  }
  if (pvVar5 != pvVar7) {
    pvVar2 = _objc_msgSend(self->_stripScrollView,sel_mediaStripView,pvVar1);
    _objc_msgSend(pvVar2,sel_noteNumberOfItemsChanged);
  }
  pvVar2 = _objc_msgSend(self->_stripScrollView,sel_mediaStripView,pvVar1);
  _objc_msgSend(pvVar2,sel_reloadData);
  _objc_msgSend(pvVar3,sel_release);
  if (((pvVar3 != (id)0x0 || reloadCardsForceSelectionIfPossible != '\0') && (pvVar5 != (id)0x0)) &&
     ((pvVar3 == (id)0x0 ||
      (pvVar2 = _objc_msgSend(self,sel_selectCardWithUID_,0), pvVar1 = pvVar4, (char)pvVar2 == '\0')
      ))) {
    pvVar1 = _objc_msgSend(self,sel_mediaStripView,pvVar1);
    _objc_msgSend(pvVar1,sel_setSelectedItemIndex_,0x7fffffff);
    pvVar1 = _objc_msgSend(self,sel_mediaStripView);
    _objc_msgSend(pvVar1,sel_setActiveItemIndex_,0x7fffffff);
    _objc_msgSend(self,sel_selectCardWithIndex_,local_1c);
    _objc_msgSend(self,sel_notifySelectionDidChangeAndConditionallyActivate_,0);
  }
  return;
}

*/
- (void)reloadCardsForceSelectionIfPossible:(BOOL)aPossible
{
    NSUInteger selectedIndex = [(HSMediaStripView *)[self mediaStripView] selectedItemIndex];
    id selectedCard = [self selectedCard];
    id selectedUID = [[selectedCard hyperUID] retain];
    NSArray *children = [[self stack] hyperChildren];
    NSUInteger childCount = [children count];
    NSMutableArray *displayedCards = [self displayedCards];
    NSUInteger displayedCount = [displayedCards count];
    NSUInteger selectIndex = [children indexOfObject:selectedCard];

    if (selectIndex == NSNotFound) {
        if (selectedIndex == NSNotFound) {
            selectIndex = 0;
        }
        else {
            selectIndex = selectedIndex;
            if (childCount < displayedCount && selectedIndex != 0) {
                // Walk back from the old selection to the nearest card that is still in the stack.
                NSUInteger index = selectedIndex;
                for (NSUInteger i = 0; i != selectedIndex; i++) {
                    if ([children indexOfObject:[displayedCards objectAtIndex:index]] != NSNotFound) {
                        break;
                    }
                    index--;
                }
                selectIndex = [children indexOfObject:[displayedCards objectAtIndex:index]];
            }
        }
    }
    [[self displayedCards] removeAllObjects];
    NSMutableSet *uids = [NSMutableSet set];
    for (NSUInteger i = 0; i < childCount; i++) {
        id card = [children objectAtIndex:i];
        [_displayedCards addObject:card];
        [uids addObject:[card hyperUID]];
    }
    NSMutableSet *staleUIDs = [NSMutableSet set];
    NSEnumerator *keyEnumerator = [_badgedIconRenderersByUID keyEnumerator];
    id uid;
    while ((uid = [keyEnumerator nextObject]) != nil) {
        if ([uids member:uid] == nil) {
            [staleUIDs addObject:uid];
        }
    }
    NSEnumerator *staleEnumerator = [staleUIDs objectEnumerator];
    while ((uid = [staleEnumerator nextObject]) != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[_badgedIconRenderersByUID objectForKey:uid]];
        [_badgedIconRenderersByUID removeObjectForKey:uid];
    }
    if (childCount != displayedCount) {
        [[_stripScrollView mediaStripView] noteNumberOfItemsChanged];
    }
    [[_stripScrollView mediaStripView] reloadData];
    [selectedUID release];
    // selectedUID is still owned by the old selected card, so it stays valid after the release.
    if ((selectedUID != nil || aPossible) && childCount != 0 && (selectedUID == nil || ![self selectCardWithUID:selectedUID])) {
        [(HSMediaStripView *)[self mediaStripView] setSelectedItemIndex:NSNotFound];
        [(HSMediaStripView *)[self mediaStripView] setActiveItemIndex:NSNotFound];
        [self selectCardWithIndex:selectIndex];
        [self notifySelectionDidChangeAndConditionallyActivate:NO];
    }
}

- (void)reloadCards
{
    [self reloadCardsForceSelectionIfPossible:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0006156f @ 0006156f, 93 bytes * /

id FUN_0006156f(HSStackController *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = (id)_NSCreateMapTable(*(undefined8 *)PTR_00336398,*(undefined8 *)(PTR_00336398 + 8),
                                 *(undefined8 *)(PTR_00336398 + 0x10),*(undefined4 *)PTR_0033639c,
                                 *(undefined4 *)(PTR_0033639c + 4),*(undefined4 *)(PTR_0033639c + 8)
                                 ,0);
  return pvVar1;
}

*/
- (id)HSStackController_createCardToRendererMap
{
    return (id)NSCreateMapTable(NSNonOwnedPointerMapKeyCallBacks, NSObjectMapValueCallBacks, 0);
}

- (id)mediaStripView
{
    return [_stripScrollView mediaStripView];
}

- (id)badgedIconRenderersByUID
{
    id pvVar1;

    pvVar1 = _badgedIconRenderersByUID;
    if (pvVar1 == nil) {
        pvVar1 = [NSMutableDictionary new];
        _badgedIconRenderersByUID = pvVar1;
    }
    return pvVar1;
}

- (id)displayedCards
{
    id pvVar1;

    pvVar1 = _displayedCards;
    if (pvVar1 == nil) {
        pvVar1 = [NSMutableArray new];
        _displayedCards = pvVar1;
    }
    return pvVar1;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_stack removeAttributeObserver:self];
    [_mediaStripUpdateTimer invalidate];
    [[_stripScrollView mediaStripView] setDelegate:0];
    [[_stripScrollView mediaStripView] setDataSource:0];
    [_stripScrollView release];
    [_displayedCards release];
    [_stack release];
    [[_badgedIconRenderersByUID allValues] makeObjectsPerformSelector:@selector(hyperInvalidate)];
    [_badgedIconRenderersByUID release];
    _badgedIconRenderersByUID = nil;
    [_uidsToUpdatePreviewImage release];
    [_draggedCard release];
    [_stripSwitcher setDelegate:0];
    [_stripSwitcher release];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005d8a3 @ 0005d8a3, 149 bytes * /

void FUN_0005d8a3(HSStackController *self,SEL _cmd,BOOL setNeedsToUpdateImages)

{
  id pvVar1;
  
  if (((bool)self->_needsToUpdateImages != (setNeedsToUpdateImages != '\0')) &&
     (self->_needsToUpdateImages = setNeedsToUpdateImages != '\0', setNeedsToUpdateImages != '\0'))
  {
    if (self->_mediaStripUpdateTimer != (id)0x0) {
      _objc_msgSend(self->_mediaStripUpdateTimer,sel_invalidate);
      self->_mediaStripUpdateTimer = (id)0x0;
    }
    pvVar1 = _objc_msgSend(cls_NSTimer,
                           sel_scheduledTimerWithTimeInterval_target_selector_userInfo_repeats_,0,
                           0x40000000,self,sel_refreshImages_,0,0);
    self->_mediaStripUpdateTimer = pvVar1;
  }
  return;
}

*/
- (void)setNeedsToUpdateImages:(BOOL)aImages
{
    if (_needsToUpdateImages != (aImages != NO)) {
        _needsToUpdateImages = aImages != NO;
        if (aImages) {
            if (_mediaStripUpdateTimer != nil) {
                [_mediaStripUpdateTimer invalidate];
                _mediaStripUpdateTimer = nil;
            }
            _mediaStripUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(refreshImages:) userInfo:nil repeats:NO];
        }
    }
}

- (void)awakeFromNib
{
    [self onceInitIfNeeded];
    [_cardIndexHeader setImage:[NSImage imageNamed:@"CardIndex_Header"]];
    [_cardIndexContainerView setDrawsBorder:NO];
    [_cardIndexContainerView setDrawsFill:YES];
    [_cardIndexContainerView setTintColor:[NSColor colorWithCalibratedWhite:0.1 alpha:1.0]];
    [_cardIndexContainerView setOpaque:YES];
    [_scrollUpButton setTarget:_stripScrollView];
    [_scrollUpButton setAction:@selector(scrollUpAction:)];
    [_scrollUpButton setContinuous:YES];
    [_scrollDownButton setTarget:_stripScrollView];
    [_scrollDownButton setAction:@selector(scrollDownAction:)];
    [_scrollDownButton setContinuous:YES];
    [_stripScrollView retain];
    [_stripSwitcher retain];
    [[_stripScrollView mediaStripView] setDelegate:self];
    [[_stripScrollView mediaStripView] setDataSource:self];
    [[_stripScrollView mediaStripView] setShowsLabels:YES];
    [[_stripScrollView mediaStripView] setShowsBadgedIcons:_areBadgedIconsVisible];
    [[_stripScrollView mediaStripView] setRemovesSelectionOnClickBetweenItems:NO];
    [[_stripScrollView mediaStripView] setShowsFirstResponderStatus:YES];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        [self onceInitIfNeeded];
    }
    return self;
}

- (void)onceInit
{
    _onceInited = YES;
    if (![[HSEditorController sharedDocumentController] isMultiDocument]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSStackController_HSUIModeSettingsDidChangeNotification:) name:HSUIModeSettingsDidChangeNotification object:[HSUI sharedUI]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSStackController_HSUIModeSettingsDidChangeNotification:) name:HSUIModeDidChangeNotification object:[HSUI sharedUI]];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideAuxiliaryIconsDidChange:) name:HSHideAuxiliaryIconsDidChangeNotification object:0];
}

- (void)onceInitIfNeeded
{
    if (_onceInited == NO) {
        [self onceInit];
    }
}

- (void)hideCardIndexWithoutAnimation
{
    [_stripSwitcher makeStripVisibleWithoutAnimation:NO];
}

- (void)showCardIndexWithoutAnimation
{
    [_stripSwitcher makeStripVisibleWithoutAnimation:YES];
}

- (id)badgetIconRendererForCardIndex:(id)aIndex
{
    return [self badgedIconRendererForCardAtIndex:[aIndex unsignedIntValue]];
}

@end

@implementation HSAttributeNotification (HSStackController_IncludeUnderlyingInfo)

- (id)HSStackController_notContiniouslyChangedVisualAttributes
{
    id pvVar1;
    id self_00;
    id pvVar2;
    id pvVar1_2;

    pvVar1 = [self object];
    self_00 = [NSEMutableProtocolSet protocolSet];
    pvVar2 = [self HSStackController_changedVisualAttributes];
    if (pvVar2 != nil) {
        [self_00 unionProtocolSet:pvVar2];
    }
    pvVar1_2 = [pvVar1 attributesBeingChangedContinuously];
    if (pvVar1_2 != nil) {
        [self_00 minusProtocolSet:pvVar1_2];
    }
    return self_00;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00060d99 @ 00060d99, 520 bytes * /

id FUN_00060d99(id self,SEL _cmd)

{
  int iVar1;
  undefined *puVar2;
  char cVar3;
  id self_00;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  undefined4 *puVar7;
  undefined4 *self_01;
  cfstringStruct *pcVar8;
  undefined1 *puVar9;
  undefined4 uVar10;
  id local_78;
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined1 local_50 [64];
  
  self_00 = _objc_msgSend(cls_NSEMutableProtocolSet,sel_protocolSet);
  local_74 = 0;
  local_70 = 0;
  local_6c = (int *)0x0;
  local_68 = 0;
  local_64 = 0;
  local_60 = 0;
  local_5c = 0;
  local_58 = 0;
  pvVar4 = _objc_msgSend(self,sel_attributeProtocolSet);
  puVar9 = local_50;
  puVar7 = &local_74;
  uVar10 = 0x10;
  local_78 = _objc_msgSend(pvVar4,sel_countByEnumeratingWithState_objects_count_,puVar7,puVar9,0x10)
  ;
  puVar2 = PTR_00336340;
  if (local_78 != (id)0x0) {
    iVar1 = *local_6c;
    do {
      pvVar6 = (id)0x0;
      do {
        if (iVar1 != *local_6c) {
          pvVar5 = _objc_msgSend(self,sel_attributeProtocolSet,puVar7,puVar9,uVar10);
          _objc_enumerationMutation(pvVar5);
        }
        self_01 = *(undefined4 **)(local_70 + (int)pvVar6 * 4);
        pvVar6 = (id)((int)pvVar6 + 1);
        if (*(double *)puVar2 <= 677.0 && *(double *)puVar2 != 677.0) {
          puVar7 = (undefined4 *)&DAT_00363b94;
          pvVar5 = _objc_msgSend(self_01,sel_conformsTo_,&DAT_00363b94,puVar9,uVar10);
          cVar3 = (char)pvVar5;
        }
        else {
          cVar3 = _protocol_conformsToProtocol(self_01,&DAT_00363b94);
        }
        if (cVar3 != '\0') {
          _objc_msgSend(self_00,sel_addProtocol_,self_01);
          puVar7 = self_01;
        }
      } while (pvVar6 < local_78);
      puVar9 = local_50;
      puVar7 = &local_74;
      uVar10 = 0x10;
      local_78 = _objc_msgSend(pvVar4,sel_countByEnumeratingWithState_objects_count_,puVar7,puVar9,
                               0x10);
    } while (local_78 != (id)0x0);
  }
  pvVar4 = _objc_msgSend(self,sel_userInfo,puVar7,puVar9,uVar10);
  pcVar8 = &cfstr_HSUnderlyingAttributeNotification;
  pvVar4 = _objc_msgSend(pvVar4,sel_objectForKey_,&cfstr_HSUnderlyingAttributeNotification);
  if (pvVar4 != (id)0x0) {
    pvVar4 = _objc_msgSend(pvVar4,sel_HSStackController_changedVisualAttributes,pcVar8,puVar9,uVar10
                          );
    _objc_msgSend(self_00,sel_unionProtocolSet_,pvVar4);
  }
  return self_00;
}

*/
- (id)HSStackController_changedVisualAttributes
{
    NSEMutableProtocolSet *attributes = [NSEMutableProtocolSet protocolSet];
    for (Protocol *protocol in [self attributeProtocolSet]) {
        if (protocol_conformsToProtocol(protocol, @protocol(HSVisualAttribute))) {
            [attributes addProtocol:protocol];
        }
    }
    id underlying = [[self userInfo] objectForKey:@"HSUnderlyingAttributeNotification"];
    if (underlying != nil) {
        [attributes unionProtocolSet:[underlying HSStackController_changedVisualAttributes]];
    }
    return attributes;
}

@end

