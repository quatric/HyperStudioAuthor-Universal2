#import "HSStackTextProvider.h"

@implementation HSStackTextProvider

/* i386 ivar offsets: _windowController=0x4, _stack=0x8, _currentItem=0xc, _currentCard=0x10, _firstEnumerationItem=0x14, _selectionController=0x18, _selectedRange=0x1c, _selectedNameRange=0x24, _direction=0x2c, _wrapping=0x30, _uniqueSpellTag=0x34, _includeObjectNames=0x38 */

- (void)deactivateCurrentItem
{
    [[_windowController cardView] endEditorForObject:[self currentItem]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000c418f @ 000c418f, 987 bytes * /

BOOL FUN_000c418f(HSStackTextProvider *self,SEL _cmd,id hyperReplaceTextForCurrentItem,id inRanges)

{
  int iVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  undefined4 *puVar6;
  id pvVar7;
  undefined1 *extraout_EDX;
  SEL op;
  undefined *puVar8;
  undefined1 *puVar9;
  id local_80;
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined1 local_50 [64];
  
  pvVar2 = _objc_msgSend(self,sel_currentItem);
  if (pvVar2 != (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_currentItem);
    pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_0036b86c);
    pvVar3 = _objc_msgSend(self->_windowController,sel_cardView);
    pvVar3 = _objc_msgSend(pvVar3,sel_selectedHyperObject);
    puVar8 = &DAT_0036b894;
    pvVar4 = _objc_msgSend(pvVar3,sel_implementsHyperInterface_,&DAT_0036b894);
    if ((char)pvVar4 != '\0') {
      puVar8 = &DAT_0036bab0;
      pvVar4 = _objc_msgSend(pvVar3,sel_implementsHyperInterface_,&DAT_0036bab0);
      if ((char)pvVar4 != '\0') {
        pvVar4 = _objc_msgSend(pvVar3,sel_hyperObject,puVar8);
        pvVar5 = _objc_msgSend(self,sel_currentItem);
        if (pvVar4 == pvVar5) {
          pvVar4 = _objc_msgSend(pvVar3,sel_hyperText,puVar8);
          local_74 = 0;
          local_70 = 0;
          local_6c = (int *)0x0;
          local_68 = 0;
          local_64 = 0;
          local_60 = 0;
          local_5c = 0;
          local_58 = 0;
          puVar9 = local_50;
          puVar6 = &local_74;
          pvVar2 = (id)0x10;
          local_80 = _objc_msgSend(inRanges,sel_countByEnumeratingWithState_objects_count_,puVar6,
                                   puVar9,0x10);
          if (local_80 != (id)0x0) {
            iVar1 = *local_6c;
            do {
              pvVar5 = (id)0x0;
              do {
                if (iVar1 != *local_6c) {
                  _objc_enumerationMutation(inRanges);
                }
                puVar6 = _objc_msgSend(*(id *)(local_70 + (int)pvVar5 * 4),sel_rangeValue,puVar6,
                                       puVar9,pvVar2);
                pvVar2 = _objc_msgSend(pvVar4,sel_attributesAtIndex_effectiveRange_,puVar6,0);
                pvVar7 = _objc_msgSend(cls_NSAttributedString,sel_alloc);
                pvVar7 = _objc_msgSend(pvVar7,sel_initWithString_attributes_,
                                       hyperReplaceTextForCurrentItem,pvVar2);
                puVar9 = extraout_EDX;
                pvVar2 = pvVar7;
                _objc_msgSend(pvVar3,sel_replaceTextInRange_withAttributedString_);
                _objc_msgSend(pvVar7,sel_release);
                pvVar5 = (id)((int)pvVar5 + 1);
              } while (pvVar5 < local_80);
              puVar9 = local_50;
              puVar6 = &local_74;
              pvVar2 = (id)0x10;
              local_80 = _objc_msgSend(inRanges,sel_countByEnumeratingWithState_objects_count_,
                                       puVar6,puVar9,0x10);
            } while (local_80 != (id)0x0);
          }
          puVar8 = &DAT_0036b894;
          pvVar2 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_0036b894,puVar9,pvVar2);
          op = sel_saveEditing;
          inRanges = puVar9;
          goto LAB_000c4555;
        }
      }
    }
    pvVar3 = _objc_msgSend(pvVar2,sel_objectString,puVar8);
    if (pvVar3 != (id)0x0) {
      pvVar3 = _objc_msgSend(self,sel_currentItem,puVar8);
      pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_0036bb78);
      pvVar3 = _objc_msgSend(pvVar3,sel_isLocked);
      if ((char)pvVar3 == '\0') {
        _objc_msgSend(pvVar2,sel_replaceObjectString_inRanges_,hyperReplaceTextForCurrentItem,
                      inRanges);
        pvVar2 = _objc_msgSend(self->_selectionController,sel_selectedHyperObject);
        puVar8 = sel_updateEmbeddedViewWithEditingObject;
        pvVar3 = _objc_msgSend(pvVar2,sel_respondsToSelector_,
                               sel_updateEmbeddedViewWithEditingObject);
        op = sel_updateEmbeddedViewWithEditingObject;
        if ((char)pvVar3 == '\0') {
          return '\x01';
        }
LAB_000c4555:
        _objc_msgSend(pvVar2,op,puVar8,inRanges);
        return '\x01';
      }
    }
  }
  return '\0';
}

*/
- (BOOL)hyperReplaceTextForCurrentItem:(id)aItem inRanges:(id)aRanges
{
    if ([self currentItem] == nil) {
        return NO;
    }
    id stringAttribute = [[self currentItem] queryHyperInterface:@protocol(HSGenericObjectStringAttribute)];
    id editor = [[_windowController cardView] selectedHyperObject];
    if ([editor implementsHyperInterface:@protocol(HSRunTimeEditor)] && [editor implementsHyperInterface:@protocol(HSTextAttributes)] && [editor hyperObject] == [self currentItem]) {
        NSAttributedString *text = [editor hyperText];
        for (NSValue *value in aRanges) {
            NSRange range = [value rangeValue];
            NSDictionary *attributes = [text attributesAtIndex:range.location effectiveRange:NULL];
            NSAttributedString *replacement = [[NSAttributedString alloc] initWithString:aItem attributes:attributes];
            [editor replaceTextInRange:range withAttributedString:replacement];
            [replacement release];
        }
        [[editor queryHyperInterface:@protocol(HSRunTimeEditor)] saveEditing];
        return YES;
    }
    if ([stringAttribute objectString] == nil) {
        return NO;
    }
    if ([[[self currentItem] queryHyperInterface:@protocol(HSCardObjectLockedAttribute)] isLocked]) {
        return NO;
    }
    [stringAttribute replaceObjectString:aItem inRanges:aRanges];
    id selected = [_selectionController selectedHyperObject];
    if ([selected respondsToSelector:@selector(updateEmbeddedViewWithEditingObject)]) {
        [selected updateEmbeddedViewWithEditingObject];
    }
    return YES;
}

- (BOOL)setHyperNameForCurrentItem:(id)aItem
{
    BOOL BVar1;
    NSAccessibilityCustomRotorItemResult *pvVar2;
    id pvVar2_3;

    if ((_includeObjectNames == NO) || (pvVar2 = [self currentItem], pvVar2 == nil)) {
        BVar1 = NO;
    }
    else {
        pvVar2_3 = [[self currentItem] queryHyperInterface:@protocol(HSObjectNaming)];
        if (pvVar2_3 != nil) {
            if (![[[self currentItem] queryHyperInterface:@protocol(HSCardObjectLockedAttribute)] isLocked]) {
                [pvVar2_3 setObjectName:aItem];
                return YES;
            }
        }
        BVar1 = YES;
    }
    return BVar1;
}

- (void)setHyperTextForCurrentItem:(id)aItem
{
    BOOL pvVar2;
    id pvVar1_3;
    id pvVar1_4;

    if ([self currentItem] != nil) {
        pvVar1_3 = [[self currentItem] queryHyperInterface:@protocol(HSGenericObjectStringAttribute)];
        if (pvVar1_3 != nil) {
            [pvVar1_3 setObjectString:aItem];
            pvVar1_4 = [_selectionController selectedHyperObject];
            pvVar2 = [pvVar1_4 respondsToSelector:@selector(updateEmbeddedViewWithEditingObject)]
            ;
            if (pvVar2) {
                [pvVar1_4 updateEmbeddedViewWithEditingObject];
            }
        }
    }
}

- (void)selectCurrentItemNameWithRange:(NSRange)aRange
{
    if (_includeObjectNames != NO) {
        [[HSObjectAssistantController sharedAssistantController] selectObjectNameWithRange:aRange];
    }
    (_selectedNameRange).location = aRange.location;
    (_selectedNameRange).length = aRange.length;
}

- (void)selectCurrentItemStringWithRange:(NSRange)aRange
{
    id pvVar1_3;

    (_selectedRange).location = aRange.location;
    (_selectedRange).length = aRange.length;
    pvVar1_3 = [[[_windowController cardView] selectedHyperObject] queryHyperInterface:@protocol(HSTextObjectSelectionInterface)];
    if ((pvVar1_3 == nil) && (aRange.length != 0 || aRange.location != 0 )) {
        [self activateCurrentItem];
        pvVar1_3 = [[[_windowController cardView] selectedHyperObject] queryHyperInterface:@protocol(HSTextObjectSelectionInterface)];
    }
    if (pvVar1_3 != nil) {
        [pvVar1_3 setHyperSelectedRange:aRange];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000c4853 @ 000c4853, 471 bytes * /

void FUN_000c4853(HSStackTextProvider *self,SEL _cmd)

{
  id pvVar1;
  undefined *self_00;
  undefined *self_01;
  undefined *puVar2;
  undefined *puVar3;
  undefined *puVar4;
  
  if (self->_includeObjectNames == '\0') {
    return;
  }
  pvVar1 = _objc_msgSend(self,sel_currentItem);
  self_00 = _objc_msgSend(pvVar1,sel_hyperObject);
  puVar4 = &DAT_0036bb78;
  pvVar1 = _objc_msgSend(self_00,sel_queryHyperInterface_,&DAT_0036bb78);
  pvVar1 = _objc_msgSend(pvVar1,sel_isLocked);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(self->_selectionController,sel_cardView,puVar4);
    self_01 = _objc_msgSend(pvVar1,sel_selectedHyperObject);
    puVar2 = _objc_msgSend(self_01,sel_hyperObject);
    if ((self_01 == puVar2) || (puVar2 = _objc_msgSend(self_01,sel_hyperObject), puVar2 != self_00))
    {
      puVar4 = &DAT_0036b8bc;
      pvVar1 = _objc_msgSend(self_00,sel_queryHyperInterface_,&DAT_0036b8bc);
      puVar2 = _objc_msgSend(pvVar1,sel_hyperParent);
      pvVar1 = _objc_msgSend(self->_selectionController,sel_stackController);
      puVar3 = _objc_msgSend(pvVar1,sel_selectedHyperObject);
      if (puVar3 != puVar2) {
        pvVar1 = _objc_msgSend(self->_selectionController,sel_stackController,puVar4);
        _objc_msgSend(pvVar1,sel_selectHyperObject_,puVar2);
        puVar4 = puVar2;
      }
      if (self_01 != self_00) {
        pvVar1 = _objc_msgSend(self->_selectionController,sel_cardView,puVar4);
        puVar4 = self_00;
        _objc_msgSend(pvVar1,sel_selectHyperObject_,self_00);
      }
    }
    pvVar1 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController,puVar4);
    _objc_msgSend(pvVar1,sel_setSelectedInModelObjectAndBringAssistantToFront_,self_00);
    return;
  }
  return;
}

*/
- (void)activateInspectorOfCurrentItem
{
    if (!_includeObjectNames) {
        return;
    }
    id object = [[self currentItem] hyperObject];
    if ([[object queryHyperInterface:@protocol(HSCardObjectLockedAttribute)] isLocked]) {
        return;
    }
    id selected = [[_selectionController cardView] selectedHyperObject];
    if (selected == [selected hyperObject] || [selected hyperObject] != object) {
        id parent = [[object queryHyperInterface:@protocol(HSNodeChild)] hyperParent];
        if ([[_selectionController stackController] selectedHyperObject] != parent) {
            [[_selectionController stackController] selectHyperObject:parent];
        }
        if (selected != object) {
            [[_selectionController cardView] selectHyperObject:object];
        }
    }
    [[HSObjectAssistantController sharedAssistantController] setSelectedInModelObjectAndBringAssistantToFront:object];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000c4a2a @ 000c4a2a, 409 bytes * /

void FUN_000c4a2a(HSStackTextProvider *self,SEL _cmd)

{
  id pvVar1;
  undefined *self_00;
  undefined *self_01;
  undefined *puVar2;
  undefined *puVar3;
  undefined *puVar4;
  
  pvVar1 = _objc_msgSend(self,sel_currentItem);
  self_00 = _objc_msgSend(pvVar1,sel_hyperObject);
  pvVar1 = _objc_msgSend(self->_selectionController,sel_cardView);
  self_01 = _objc_msgSend(pvVar1,sel_selectedHyperObject);
  puVar2 = _objc_msgSend(self_01,sel_hyperObject);
  if ((self_01 != puVar2) && (puVar2 = _objc_msgSend(self_01,sel_hyperObject), puVar2 == self_00)) {
    return;
  }
  puVar2 = &DAT_0036b8bc;
  pvVar1 = _objc_msgSend(self_00,sel_queryHyperInterface_,&DAT_0036b8bc);
  puVar3 = _objc_msgSend(pvVar1,sel_hyperParent);
  pvVar1 = _objc_msgSend(self->_selectionController,sel_stackController);
  puVar4 = _objc_msgSend(pvVar1,sel_selectedHyperObject);
  if (puVar4 != puVar3) {
    pvVar1 = _objc_msgSend(self->_selectionController,sel_stackController,puVar2);
    _objc_msgSend(pvVar1,sel_selectHyperObject_,puVar3);
    puVar2 = puVar3;
  }
  if (self_01 != self_00) {
    pvVar1 = _objc_msgSend(self->_selectionController,sel_cardView,puVar2);
    puVar2 = self_00;
    _objc_msgSend(pvVar1,sel_selectHyperObject_,self_00);
  }
  pvVar1 = _objc_msgSend(self->_windowController,sel_cardView,puVar2);
  _objc_msgSend(pvVar1,sel_startEditorForObject_creationMode_,self_00,0);
  return;
}

*/
- (void)activateCurrentItem
{
    id object = [[self currentItem] hyperObject];
    id selected = [[_selectionController cardView] selectedHyperObject];
    if (selected != [selected hyperObject] && [selected hyperObject] == object) {
        return;
    }
    id parent = [[object queryHyperInterface:@protocol(HSNodeChild)] hyperParent];
    if ([[_selectionController stackController] selectedHyperObject] != parent) {
        [[_selectionController stackController] selectHyperObject:parent];
    }
    if (selected != object) {
        [[_selectionController cardView] selectHyperObject:object];
    }
    [[_windowController cardView] startEditorForObject:object creationMode:NO];
}

- (NSInteger)hyperSpellDocumentTag
{
    NSInteger pvVar1;

    pvVar1 = _uniqueSpellTag;
    if (pvVar1 == 0) {
        pvVar1 = [NSSpellChecker uniqueSpellDocumentTag];
        _uniqueSpellTag = (int)pvVar1;
    }
    return (int)pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000c4bfb @ 000c4bfb, 199 bytes * /

ulonglong FUN_000c4bfb(HSStackTextProvider *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  uint uVar3;
  uint extraout_EDX;
  
  if (self->_includeObjectNames == '\0') {
    pvVar1 = (id)0x0;
    uVar3 = 0;
  }
  else {
    pvVar1 = _objc_msgSend(self->_selectionController,sel_cardView);
    self_00 = _objc_msgSend(pvVar1,sel_selectedHyperObject);
    pvVar1 = self->_currentItem;
    pvVar2 = _objc_msgSend(self_00,sel_hyperObject);
    if (pvVar1 == pvVar2) {
      pvVar1 = _objc_msgSend(self_00,sel_hyperObject);
      if (self_00 != pvVar1) {
        uVar3 = 0;
        pvVar1 = (id)0x7fffffff;
        goto LAB_000c4cba;
      }
    }
    pvVar1 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
    pvVar1 = _objc_msgSend(pvVar1,sel_selectedObjectNameRange);
    uVar3 = extraout_EDX;
    if (pvVar1 == (id)0x7fffffff) {
      pvVar1 = (id)(self->_selectedNameRange).location;
      uVar3 = (self->_selectedNameRange).length;
    }
  }
LAB_000c4cba:
  return CONCAT44(uVar3,pvVar1);
}

*/
- (NSRange)selectedRangeForCurrentItemName
{
    if (!_includeObjectNames) {
        return NSMakeRange(0, 0);
    }
    id selected = [[_selectionController cardView] selectedHyperObject];
    if ((id)_currentItem == [selected hyperObject] && selected != [selected hyperObject]) {
        return NSMakeRange(NSNotFound, 0);
    }
    NSRange range = [[HSObjectAssistantController sharedAssistantController] selectedObjectNameRange];
    if (range.location == NSNotFound) {
        range = _selectedNameRange;
    }
    return range;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000c4cc2 @ 000c4cc2, 175 bytes * /

ulonglong FUN_000c4cc2(HSStackTextProvider *self,SEL _cmd)

{
  id pvVar1;
  uint extraout_EDX;
  uint uVar2;
  undefined *puVar3;
  
  pvVar1 = _objc_msgSend(self->_windowController,sel_cardView);
  pvVar1 = _objc_msgSend(pvVar1,sel_selectedHyperObject);
  puVar3 = &DAT_0036bb64;
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0036bb64);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self->_windowController,sel_cardView,puVar3);
    pvVar1 = _objc_msgSend(pvVar1,sel_selectedHyperObject);
    if (pvVar1 != (id)0x0) {
      pvVar1 = (id)(self->_selectedRange).location;
      uVar2 = (self->_selectedRange).length;
      goto LAB_000c4d5f;
    }
  }
  else {
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperSelectedRange,puVar3);
    uVar2 = extraout_EDX;
LAB_000c4d5f:
    if (pvVar1 != (id)0x7fffffff) goto LAB_000c4d6a;
  }
  pvVar1 = (id)0x0;
  uVar2 = 0;
LAB_000c4d6a:
  return CONCAT44(uVar2,pvVar1);
}

*/
- (NSRange)selectedRangeForCurrentItem
{
    id selection = [[[_windowController cardView] selectedHyperObject] queryHyperInterface:@protocol(HSTextObjectSelectionInterface)];
    NSRange range;
    if (selection != nil) {
        range = [selection hyperSelectedRange];
    }
    else {
        if ([[_windowController cardView] selectedHyperObject] == nil) {
            return NSMakeRange(0, 0);
        }
        range = _selectedRange;
    }
    if (range.location == NSNotFound) {
        return NSMakeRange(0, 0);
    }
    return range;
}

- (id)hyperNameForCurrentItem
{
    NSAccessibilityCustomRotorItemResult *pvVar1;
    id pvVar1_3;

    if ((_includeObjectNames != NO) && (pvVar1 = [self currentItem], pvVar1 != nil)) {
        pvVar1_3 = [[self currentItem] queryHyperInterface:@protocol(HSObjectNaming)];
        if (pvVar1_3 != nil) {
            return [pvVar1_3 objectName];
        }
    }
    return nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000c4ded @ 000c4ded, 306 bytes * /

id FUN_000c4ded(HSStackTextProvider *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  undefined *puVar4;
  
  pvVar1 = _objc_msgSend(self,sel_currentItem);
  if (pvVar1 == (id)0x0) {
    return (id)0x0;
  }
  pvVar1 = _objc_msgSend(self->_windowController,sel_cardView);
  pvVar1 = _objc_msgSend(pvVar1,sel_selectedHyperObject);
  puVar4 = &DAT_0036b894;
  pvVar2 = _objc_msgSend(pvVar1,sel_implementsHyperInterface_,&DAT_0036b894);
  if ((char)pvVar2 != '\0') {
    puVar4 = &DAT_0036bab0;
    pvVar2 = _objc_msgSend(pvVar1,sel_implementsHyperInterface_,&DAT_0036bab0);
    if ((char)pvVar2 != '\0') {
      pvVar2 = _objc_msgSend(pvVar1,sel_hyperObject,puVar4);
      pvVar3 = _objc_msgSend(self,sel_currentItem);
      if (pvVar2 == pvVar3) {
        pvVar1 = _objc_msgSend(pvVar1,sel_hyperText,puVar4);
        op = sel_string;
        goto LAB_000c4ece;
      }
    }
  }
  pvVar1 = _objc_msgSend(self,sel_currentItem,puVar4);
  puVar4 = &DAT_0036b86c;
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0036b86c);
  op = sel_objectString;
LAB_000c4ece:
  pvVar1 = _objc_msgSend(pvVar1,op,puVar4);
  return pvVar1;
}

*/
- (id)hyperTextForCurrentItem
{
    if ([self currentItem] == nil) {
        return nil;
    }
    id editor = [[_windowController cardView] selectedHyperObject];
    if ([editor implementsHyperInterface:@protocol(HSRunTimeEditor)] && [editor implementsHyperInterface:@protocol(HSTextAttributes)] && [editor hyperObject] == [self currentItem]) {
        return [[editor hyperText] string];
    }
    return [[[self currentItem] queryHyperInterface:@protocol(HSGenericObjectStringAttribute)] objectString];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000c4f1f @ 000c4f1f, 246 bytes * /

BOOL FUN_000c4f1f(HSStackTextProvider *self,SEL _cmd)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  self_00 = _objc_msgSend(self,sel_currentItem);
  if (self_00 != (id)0x0) {
    pvVar1 = _objc_msgSend(self_00,sel_queryHyperInterface_,&DAT_0036b8bc);
    pvVar2 = _objc_msgSend(self_00,sel_queryHyperInterface_,&DAT_0036b8bc);
    pvVar2 = _objc_msgSend(pvVar2,sel_hyperParent);
    pvVar3 = _objc_msgSend(self,sel_nearestTextItemInContainer_forItem_,pvVar2,pvVar1);
    if (pvVar3 != (id)0x0) {
      _objc_msgSend(self,sel_setCurrentItem_,pvVar3,pvVar1);
      pvVar2 = pvVar3;
    }
    pvVar3 = _objc_msgSend(self,sel_currentItem,pvVar2,pvVar1);
    if (pvVar3 != self->_firstEnumerationItem) {
      pvVar2 = _objc_msgSend(self,sel_currentItem,pvVar2,pvVar1);
      return pvVar2 != self_00;
    }
  }
  return '\0';
}

*/
- (BOOL)moveToNext
{
    id item = [self currentItem];
    if (item != nil) {
        id child = [item queryHyperInterface:@protocol(HSNodeChild)];
        id next = [self nearestTextItemInContainer:[[item queryHyperInterface:@protocol(HSNodeChild)] hyperParent] forItem:child];
        if (next != nil) {
            [self setCurrentItem:next];
        }
        if ([self currentItem] != _firstEnumerationItem) {
            return [self currentItem] != item;
        }
    }
    return NO;
}

- (BOOL)shouldEnableIncludeObjectNamesButton
{
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000c5015 @ 000c5015, 127 bytes * /

void FUN_000c5015(HSStackTextProvider *self,SEL _cmd,BOOL setIncludeObjectNames)

{
  id pvVar1;
  SEL op;
  
  if (((self->_includeObjectNames != '\0') && (setIncludeObjectNames == '\0')) ||
     ((self->_includeObjectNames == '\0' && (setIncludeObjectNames != '\0')))) {
    self->_includeObjectNames = setIncludeObjectNames;
    op = sel_refreshCurrentItem;
    if (setIncludeObjectNames == '\0') {
      pvVar1 = _objc_msgSend(self,sel_currentItem);
      pvVar1 = _objc_msgSend(self,sel_canBecomeCurrentItem_,pvVar1);
      op = sel_moveToNext;
      if ((char)pvVar1 != '\0') {
        return;
      }
    }
    _objc_msgSend(self,op);
  }
  return;
}

*/
- (void)setIncludeObjectNames:(BOOL)aNames
{
    if ((_includeObjectNames && !aNames) || (!_includeObjectNames && aNames)) {
        _includeObjectNames = aNames;
        if (!aNames) {
            if ([self canBecomeCurrentItem:[self currentItem]]) {
                return;
            }
            [self moveToNext];
            return;
        }
        [self refreshCurrentItem];
    }
}

- (void)setWrapsAround:(BOOL)aAround
{
    _wrapping = aAround;
}

- (void)setDirection:(NSInteger)aDirection
{
    _direction = aDirection;
}

- (void)startEnumeration
{
    [_firstEnumerationItem release];
    _firstEnumerationItem = [[self currentItem] retain];
}

- (void)selectionChanged:(id)aChanged
{
    if ([[aChanged object] respondsToSelector:@selector(selectedHyperObject)]) {
        if ([[[aChanged object] selectedHyperObject] implementsHyperInterface:@protocol(HSObjectAttributes)]) {
            [self refreshCurrentItem];
        }
    }
}

- (void)activeCardDidChange:(id)aChange
{
    [self setCurrentCard:[[[_selectionController stackController] activeCard] queryHyperInterface:@protocol(HSCardAttributes)]];
}

- (void)nodeContainerDidRemoveChild:(id)aChild
{
    if ([[[aChild userInfo] valueForKey:@"HSNodeChildrenForRemoval"] count] != 0) {
        [self refreshCurrentItem];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000c526b @ 000c526b, 799 bytes * /

id FUN_000c526b(HSStackTextProvider *self,SEL _cmd,id nearestTextItemInContainer,id forItem)

{
  int iVar1;
  bool bVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  int iVar7;
  undefined *puVar8;
  id local_1c;
  id local_14;
  
  puVar8 = &DAT_0036b8bc;
  pvVar3 = _objc_msgSend(nearestTextItemInContainer,sel_queryHyperInterface_,&DAT_0036b8bc);
  pvVar3 = _objc_msgSend(pvVar3,sel_hyperIndex);
  if (forItem == (id)0x0) {
    local_1c = (id)0x7fffffff;
  }
  else {
    local_1c = _objc_msgSend(forItem,sel_hyperIndex,puVar8);
  }
  bVar2 = false;
  pvVar5 = local_1c;
  local_14 = pvVar3;
  while( true ) {
    pvVar6 = local_14;
    pvVar4 = _objc_msgSend(self->_stack,sel_hyperChildAtIndex_,local_14);
    pvVar4 = _objc_msgSend(pvVar4,sel_hyperCount);
    iVar1 = self->_direction;
    if (pvVar5 == (id)0x7fffffff) {
      if (iVar1 == 1) {
        pvVar5 = (id)0x0;
      }
      else {
        pvVar5 = (id)0x0;
        if (pvVar4 != (id)0x0) {
          pvVar5 = (id)((int)pvVar4 + -1);
        }
      }
    }
    else if (iVar1 == 1) {
      pvVar5 = (id)((int)pvVar5 + 1);
    }
    else {
      pvVar5 = (id)((int)pvVar5 + -1);
    }
    if (pvVar4 <= pvVar5) break;
LAB_000c5505:
    if ((local_14 == pvVar3) &&
       ((pvVar5 == local_1c || (((pvVar5 == (id)0x0 && (local_1c == (id)0x7fffffff)) && (bVar2))))))
    goto LAB_000c5551;
    pvVar6 = _objc_msgSend(self->_stack,sel_hyperCount,pvVar6);
    if (local_14 < pvVar6) {
      pvVar6 = _objc_msgSend(self->_stack,sel_hyperChildAtIndex_,local_14);
      pvVar6 = _objc_msgSend(pvVar6,sel_hyperCount);
      if ((pvVar5 < pvVar6) &&
         (pvVar6 = _objc_msgSend(self->_stack,sel_hyperChildAtIndex_,local_14), pvVar6 != (id)0x0))
      {
        pvVar6 = _objc_msgSend(pvVar6,sel_queryHyperInterface_,&DAT_0036b8bc);
        pvVar6 = _objc_msgSend(pvVar6,sel_hyperChildAtIndex_,pvVar5);
        if ((pvVar6 != (id)0x0) &&
           (pvVar4 = _objc_msgSend(self,sel_canBecomeCurrentItem_,pvVar6), (char)pvVar4 != '\0')) {
LAB_000c5494:
          pvVar3 = _objc_msgSend(pvVar6,sel_queryHyperInterface_,&DAT_0036b880);
          return pvVar3;
        }
      }
    }
  }
  iVar7 = -1;
  if (iVar1 == 1) {
    iVar7 = 1;
  }
  local_14 = (id)(iVar7 + (int)local_14);
  pvVar5 = _objc_msgSend(self->_stack,sel_hyperCount,pvVar6);
  if (local_14 < pvVar5) {
LAB_000c54c0:
    pvVar6 = local_14;
    pvVar5 = _objc_msgSend(self->_stack,sel_hyperChildAtIndex_,local_14);
    pvVar4 = _objc_msgSend(pvVar5,sel_hyperCount);
    if (self->_direction == 1) {
      pvVar5 = (id)0x0;
    }
    else {
      pvVar5 = (id)((int)pvVar4 + -1);
      if (pvVar4 == (id)0x0) {
        pvVar5 = (id)0x0;
      }
    }
    goto LAB_000c5505;
  }
  if (self->_wrapping != '\0') {
    if (self->_direction == 1) {
      local_14 = (id)0x0;
      bVar2 = true;
    }
    else {
      local_14 = _objc_msgSend(self->_stack,sel_hyperCount,pvVar6);
      local_14 = (id)((int)local_14 + -1);
      bVar2 = true;
    }
    goto LAB_000c54c0;
  }
LAB_000c5551:
  pvVar3 = _objc_msgSend(self,sel_canBecomeCurrentItem_,forItem);
  pvVar6 = forItem;
  if ((char)pvVar3 == '\0') {
    return (id)0x0;
  }
  goto LAB_000c5494;
}

*/
- (id)nearestTextItemInContainer:(id)aContainer forItem:(id)aItem
{
    NSUInteger startCardIndex = [[aContainer queryHyperInterface:@protocol(HSNodeChild)] hyperIndex];
    NSUInteger startItemIndex = (aItem != nil) ? [aItem hyperIndex] : NSNotFound;
    BOOL wrapped = NO;
    NSUInteger cardIndex = startCardIndex;
    NSUInteger itemIndex = startItemIndex;
    while (YES) {
        NSUInteger count = [[_stack hyperChildAtIndex:cardIndex] hyperCount];
        if (itemIndex == NSNotFound) {
            itemIndex = (_direction == 1) ? 0 : ((count != 0) ? count - 1 : 0);
        }
        else if (_direction == 1) {
            itemIndex++;
        }
        else {
            itemIndex--;
        }
        if (itemIndex >= count) {
            NSUInteger nextCardIndex = cardIndex + ((_direction == 1) ? 1 : -1);
            if (nextCardIndex >= [_stack hyperCount]) {
                if (!_wrapping) {
                    break;
                }
                nextCardIndex = (_direction == 1) ? 0 : [_stack hyperCount] - 1;
                wrapped = YES;
            }
            NSUInteger nextCount = [[_stack hyperChildAtIndex:nextCardIndex] hyperCount];
            itemIndex = (_direction == 1) ? 0 : ((nextCount != 0) ? nextCount - 1 : 0);
            cardIndex = nextCardIndex;
        }
        if (cardIndex == startCardIndex && (itemIndex == startItemIndex || (itemIndex == 0 && startItemIndex == NSNotFound && wrapped))) {
            break;
        }
        if (cardIndex < [_stack hyperCount] && itemIndex < [[_stack hyperChildAtIndex:cardIndex] hyperCount]) {
            id card = [_stack hyperChildAtIndex:cardIndex];
            if (card != nil) {
                id child = [[card queryHyperInterface:@protocol(HSNodeChild)] hyperChildAtIndex:itemIndex];
                if (child != nil && [self canBecomeCurrentItem:child]) {
                    return [child queryHyperInterface:@protocol(HSObjectNaming)];
                }
            }
        }
    }
    if ([self canBecomeCurrentItem:aItem]) {
        return [aItem queryHyperInterface:@protocol(HSObjectNaming)];
    }
    return nil;
}

- (id)nearestTextItemInContainer:(id)aContainer
{
    return [self nearestTextItemInContainer:aContainer forItem:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000c55bf @ 000c55bf, 805 bytes * /

void FUN_000c55bf(HSStackTextProvider *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  undefined *self_00;
  int iVar3;
  SEL op;
  undefined *puVar4;
  
  pvVar1 = _objc_msgSend(self->_selectionController,sel_selectedHyperObject);
  puVar4 = &DAT_0036b894;
  pvVar2 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0036b894);
  if (pvVar2 != (id)0x0) {
    pvVar2 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager,puVar4);
    _objc_msgSend(pvVar2,sel_selectToolWithTag_,1);
  }
  puVar4 = sel_isHyperProxy;
  pvVar2 = _objc_msgSend(pvVar1,sel_respondsToSelector_,sel_isHyperProxy);
  if (((char)pvVar2 == '\0') ||
     (pvVar2 = _objc_msgSend(pvVar1,sel_isHyperProxy,puVar4), (char)pvVar2 == '\0')) {
    pvVar2 = _objc_msgSend(self,sel_canBecomeCurrentItem_,pvVar1);
    if ((char)pvVar2 == '\0') {
      pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0036b8bc);
      if (pvVar1 == (id)0x0) {
        return;
      }
      pvVar2 = _objc_msgSend(pvVar1,sel_implementsHyperInterface_,&DAT_0036b920);
      if ((char)pvVar2 == '\0') {
        puVar4 = &DAT_0036b7e0;
        pvVar2 = _objc_msgSend(pvVar1,sel_implementsHyperInterface_,&DAT_0036b7e0);
        if ((char)pvVar2 == '\0') {
          pvVar1 = _objc_msgSend(pvVar1,sel_hyperParent,puVar4);
          op = sel_nearestTextItemInContainer_forItem_;
        }
        else {
          pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0036b9e8);
          op = sel_nearestTextItemInContainer_;
        }
      }
      else {
        pvVar2 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0036b7b8);
        pvVar2 = _objc_msgSend(pvVar2,sel_hyperCount);
        if (pvVar2 == (id)0x0) {
          pvVar1 = (id)0x0;
          goto LAB_000c58d7;
        }
        pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0036b7b8);
        iVar3 = 0;
        if (self->_direction != 1) {
          iVar3 = (int)pvVar2 + -1;
        }
        pvVar1 = _objc_msgSend(pvVar1,sel_hyperChildAtIndex_,iVar3);
        op = sel_nearestTextItemInContainer_;
      }
      pvVar1 = _objc_msgSend(self,op,pvVar1);
    }
    else {
      pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0036b880);
    }
  }
  else {
    puVar4 = sel_compareWeight_;
    _objc_msgSend(pvVar1,sel_sortHyperInterfacesUsingSelector_,sel_compareWeight_);
    pvVar1 = _objc_msgSend(pvVar1,sel_allHyperInterfaces);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectEnumerator);
    do {
      self_00 = _objc_msgSend(pvVar1,sel_nextObject,puVar4);
      if (self_00 == (undefined *)0x0) {
        return;
      }
      puVar4 = self_00;
      pvVar2 = _objc_msgSend(self,sel_canBecomeCurrentItem_,self_00);
    } while ((char)pvVar2 == '\0');
    pvVar1 = _objc_msgSend(self_00,sel_queryHyperInterface_,&DAT_0036b880);
  }
LAB_000c58d7:
  _objc_msgSend(self,sel_setCurrentItem_,pvVar1);
  return;
}

*/
- (void)refreshCurrentItem
{
    id selected = [_selectionController selectedHyperObject];
    if ([selected queryHyperInterface:@protocol(HSRunTimeEditor)] != nil) {
        [(HSToolManager *)[HSToolManager sharedToolManager] selectToolWithTag:1];
    }
    id item = nil;
    if ([selected respondsToSelector:@selector(isHyperProxy)] && [selected isHyperProxy]) {
        [selected sortHyperInterfacesUsingSelector:@selector(compareWeight:)];
        id candidate = nil;
        for (id interface in [selected allHyperInterfaces]) {
            if ([self canBecomeCurrentItem:interface]) {
                candidate = interface;
                break;
            }
        }
        if (candidate == nil) {
            return;
        }
        item = [candidate queryHyperInterface:@protocol(HSObjectNaming)];
    }
    else if ([self canBecomeCurrentItem:selected]) {
        item = [selected queryHyperInterface:@protocol(HSObjectNaming)];
    }
    else {
        id child = [selected queryHyperInterface:@protocol(HSNodeChild)];
        if (child == nil) {
            return;
        }
        if ([child implementsHyperInterface:@protocol(HSStackAttributes)]) {
            NSUInteger count = [[child queryHyperInterface:@protocol(HSNodeContainerChildrenAttribute)] hyperCount];
            if (count == 0) {
                child = nil;
            }
            id card = [[child queryHyperInterface:@protocol(HSNodeContainerChildrenAttribute)] hyperChildAtIndex:(_direction == 1) ? 0 : count - 1];
            item = [self nearestTextItemInContainer:card];
        }
        else if ([child implementsHyperInterface:@protocol(HSCardAttributes)]) {
            item = [self nearestTextItemInContainer:[child queryHyperInterface:@protocol(HSNodeContainer)]];
        }
        else {
            item = [self nearestTextItemInContainer:[child hyperParent] forItem:child];
        }
    }
    [self setCurrentItem:item];
}

- (BOOL)canBecomeCurrentItem:(id)aItem
{
    BOOL bVar2;

    if ([aItem queryHyperInterface:@protocol(HSGenericObjectStringAttribute)] == nil) {
        if (_includeObjectNames == NO) {
            bVar2 = NO;
        }
        else {
            bVar2 = [[aItem queryHyperInterface:@protocol(HSObjectNaming)] objectName] != nil;
        }
    }
    else {
        bVar2 = YES;
    }
    return bVar2;
}

- (void)setCurrentItem:(id)aItem
{
    if (_currentItem != aItem) {
        [_currentItem release];
        _currentItem = [aItem retain];
        [self selectCurrentItemStringWithRange:NSMakeRange(0, 0)];
        [self selectCurrentItemNameWithRange:NSMakeRange(0, 0)];
    }
}

- (id)currentItem
{
    id pvVar1;

    pvVar1 = _currentItem;
    if (pvVar1 == nil) {
        [self refreshCurrentItem];
        pvVar1 = _currentItem;
    }
    return pvVar1;
}

- (void)setCurrentCard:(id)aCard
{
    int uVar1;
    id pvVar2;
    id pvVar2_2;

    if (_currentCard != aCard) {
        pvVar2 = [_currentCard attributeObservingController];
        uVar1 = HSActualDidAttributeChanges;
        [pvVar2 removeObserver:self selector:@selector(nodeContainerDidRemoveChild:) ofChanges:uVar1 ofAttribute:@protocol(HSNodeContainerChildrenAttribute)];
        [_currentCard release];
        pvVar2_2 = [aCard retain];
        _currentCard = pvVar2_2;
        [[pvVar2_2 attributeObservingController] addObserver:self selector:@selector(nodeContainerDidRemoveChild:) ofChanges:uVar1 ofAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:-0.25];
    }
}

- (void)setSelectionController:(id)aController
{
    NSNotificationCenter *self_00;

    if (_selectionController != aController) {
        self_00 = [NSNotificationCenter defaultCenter];
        if (_selectionController != nil) {
            [self_00 removeObserver:self name:@"HSSelectionHolderDidChangeSelectionNotification" object:_selectionController];
            [self_00 removeObserver:self name:@"HSStackViewDidChangeActiveCardNotification" object:[_selectionController stackController]];
            [_selectionController release];
        }
        _selectionController = [aController retain];
        [_stack release];
        _stack = [[[_selectionController stackController] stack] retain];
        [self setCurrentCard:[[[_selectionController stackController] activeCard] queryHyperInterface:@protocol(HSCardAttributes)]];
        if (_selectionController != nil) {
            [self_00 addObserver:self selector:@selector(selectionChanged:) name:@"HSSelectionHolderDidChangeSelectionNotification" object:_selectionController];
            [self_00 addObserver:self selector:@selector(activeCardDidChange:) name:@"HSStackViewDidChangeActiveCardNotification" object:[_selectionController stackController]];
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[_currentCard attributeObservingController] removeObserver:self selector:@selector(nodeContainerDidRemoveChild:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSNodeContainerChildrenAttribute)];
    [_currentCard release];
    [_stack release];
    [_currentItem release];
    [_selectionController release];
    [_firstEnumerationItem release];
    [super dealloc];
}

- (id)initWithWindowController:(id)aController selectionController:(id)aController2
{
    self = [super init];
    if (self != nil) {
        _windowController = aController;
        _direction = 1;
        [self setSelectionController:aController2];
    }
    return self;
}

@end

