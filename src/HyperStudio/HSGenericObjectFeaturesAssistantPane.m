#import "HSGenericObjectFeaturesAssistantPane.h"

@implementation HSGenericObjectFeaturesAssistantPane

/* i386 ivar offsets: _objectOwnerLabel=0x5c, _objectNameLabel=0x60, _commentsTextView=0x64, _cursorImageView=0x68, _cursorButton=0x6c, _draggableButton=0x70, _draggableSwitch=0x74, _groupObjectSwitch=0x78, _cardObjectController=0x7c */

- (void)editCursor:(id)aCursor
{
    id self_00;
    id pvVar1_5;
    id pvVar2_2;

    self_00 = [HSStackCursorsDataSource new];
    [self_00 setStack:[[[[self assistant] object] queryHyperInterface:@protocol(HSUserObjectSupport)] stack]];
    pvVar1_5 = [HSCursorAssistantPane new];
    [pvVar1_5 setStackCursorsDataSource:self_00];
    pvVar2_2 = [[HSObjectAssistantNavigationController alloc] initWithRootViewController:pvVar1_5];
    [self presentModalViewController:pvVar2_2 animated:YES];
    [pvVar2_2 release];
    [pvVar1_5 release];
    [self_00 release];
}

- (void)setDraggableOptions:(id)aOptions
{
    id self_00;
    id pvVar1_2;

    self_00 = [HSDropOffOptionsAssistansPane new];
    pvVar1_2 = [[HSObjectAssistantNavigationController alloc] initWithRootViewController:self_00];
    [self_00 setCardView:[[[[self stack] document] editorWindowController] cardView]];
    [self_00 setNavigationController:pvVar1_2];
    [self_00 setObject:[[self assistant] object]];
    [self_00 setObjectAssistantPaneDelegate:[self objectAssistantPaneDelegate]];
    [self presentModalViewController:pvVar1_2 animated:YES];
    [self_00 release];
    [pvVar1_2 release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000f0099 @ 000f0099, 478 bytes * /

void FUN_000f0099(HSGenericObjectFeaturesAssistantPane *self,SEL _cmd,
                 BOOL validateDropOptionsStateForDragableState)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_stack);
  pvVar1 = _objc_msgSend(pvVar1,sel_document);
  pvVar1 = _objc_msgSend(pvVar1,sel_editorWindowController);
  pvVar1 = _objc_msgSend(pvVar1,sel_cardView);
  pvVar2 = _objc_msgSend(self,sel_assistant);
  pvVar2 = _objc_msgSend(pvVar2,sel_object);
  pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_0036e350);
  pvVar3 = _objc_msgSend(self,sel_assistant);
  pvVar3 = _objc_msgSend(pvVar3,sel_object);
  pvVar3 = _objc_msgSend(pvVar3,sel_card);
  pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_0036e364);
  pvVar2 = _objc_msgSend(pvVar2,sel_dropOffTargetUID);
  pvVar2 = _objc_msgSend(pvVar3,sel_childInTreeWithUID_,pvVar2);
  pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_0036dcd4);
  if (pvVar2 != (id)0x0) {
    if (validateDropOptionsStateForDragableState == '\0') {
      _objc_msgSend(pvVar2,sel_setIsVisibleInEditor_,0);
      op = sel_hideCardChildIfNotHidden_invalidate_;
    }
    else {
      _objc_msgSend(pvVar2,sel_setIsVisibleInEditor_,1);
      op = sel_showCardChildIfHidden_invalidate_;
    }
    _objc_msgSend(pvVar1,op,pvVar2,1);
    _objc_msgSend(pvVar2,sel_setTemporary_,(uint)(validateDropOptionsStateForDragableState == '\0'))
    ;
  }
  _objc_msgSend(pvVar1,sel_setNeedsDisplay_,1);
  return;
}

*/
/* --- i386 decompilation (Ghidra) ---
/* FUN_000efd87 @ 000efd87, 786 bytes * /

void FUN_000efd87(HSGenericObjectFeaturesAssistantPane *self,SEL _cmd,id groupObjectChanged)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  undefined *puVar4;
  cfstringStruct *pcVar5;
  cfstringStruct *pcVar6;
  
  pvVar1 = _objc_msgSend(self,sel_objectAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_isGroupObject);
  pvVar2 = _objc_msgSend(groupObjectChanged,sel_state);
  if ((bool)(char)pvVar1 == (pvVar2 == (id)0x1)) {
    return;
  }
  pvVar1 = _objc_msgSend(self,sel_objectAttributes);
  op = sel_makeGroupObject;
  if (pvVar2 != (id)0x1) {
    puVar4 = &DAT_0036df2c;
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0036df2c);
    if (pvVar1 != (id)0x0) {
      pvVar1 = _objc_msgSend(self,sel_objectAttributes,puVar4);
      puVar4 = &DAT_0036e33c;
      pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0036e33c);
      pvVar1 = _objc_msgSend(pvVar1,sel_cardGroupUID);
      if (pvVar1 != (id)0x0) {
        pvVar1 = _objc_msgSend(cls_HSAlert,sel_new,puVar4);
        _objc_msgSend(pvVar1,sel_setAlertStyle_,5);
        pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
        pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                               &cfstr_Are_you_sure_you_want_to_ungroup_this_item_,&cfstr_empty,
                               &cfstr_Alerts);
        _objc_msgSend(pvVar1,sel_setMessageText_,pvVar2);
        pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
        pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                               &cfstr_You_will_lose_all_text_contained_in_this_field_o,&cfstr_empty,
                               &cfstr_Alerts);
        _objc_msgSend(pvVar1,sel_setInformativeText_,pvVar2);
        pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
        pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_Ungroup,
                               &cfstr_empty,&cfstr_Alerts);
        _objc_msgSend(pvVar1,sel_addButtonWithTitle_,pvVar2);
        pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
        pcVar6 = &cfstr_Alerts;
        pcVar5 = &cfstr_empty;
        pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_Cancel,
                               &cfstr_empty,&cfstr_Alerts);
        _objc_msgSend(pvVar1,sel_addButtonWithTitle_,pvVar2);
        pvVar3 = _objc_msgSend(pvVar1,sel_runModal);
        op = sel_release;
        if (pvVar3 == (id)0x3e8) {
          pvVar2 = _objc_msgSend(self,sel_objectAttributes,pvVar2,pcVar5,pcVar6);
          _objc_msgSend(pvVar2,sel_makeNonGroupObject);
          op = sel_release;
        }
        goto LAB_000efe07;
      }
    }
    pvVar1 = _objc_msgSend(self,sel_objectAttributes,puVar4);
    op = sel_makeNonGroupObject;
  }
LAB_000efe07:
  _objc_msgSend(pvVar1,op);
  return;
}

*/
- (void)groupObjectChanged:(id)aChanged
{
    BOOL isGroup = [[self objectAttributes] isGroupObject];
    NSInteger state = [aChanged state];
    if (isGroup == (state == 1)) {
        return;
    }
    if (state == 1) {
        [[self objectAttributes] makeGroupObject];
        return;
    }
    if ([[self objectAttributes] queryHyperInterface:@protocol(HSSystemTextViewAttributes)] != nil
        && [[[self objectAttributes] queryHyperInterface:@protocol(HSNodeAttributes)] cardGroupUID] != nil) {
        HSAlert *alert = [HSAlert new];
        [alert setAlertStyle:5];
        [alert setMessageText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Are you sure you want to ungroup this item?" value:@"" table:@"Alerts"]];
        [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"You will lose all text contained in this field on other cards if you make this field a non-group item." value:@"" table:@"Alerts"]];
        [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Ungroup" value:@"" table:@"Alerts"]];
        [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Cancel" value:@"" table:@"Alerts"]];
        if ([alert runModal] == 1000) {
            [[self objectAttributes] makeNonGroupObject];
        }
        [alert release];
    } else {
        [[self objectAttributes] makeNonGroupObject];
    }
}

- (void)commentsChanged:(id)aChanged
{
    id pvVar1_2;

    pvVar1_2 = [[_commentsTextView string] copy];
    [[[[self assistant] object] queryHyperInterface:@protocol(HSCommentsAttributes)] setHyperComments:pvVar1_2];
    [pvVar1_2 release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000efb97 @ 000efb97, 325 bytes * /

void FUN_000efb97(HSGenericObjectFeaturesAssistantPane *self,SEL _cmd,id textDidChange)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id extraout_EDX;
  
  pvVar1 = _objc_msgSend(self->_commentsTextView,sel_string);
  pvVar2 = _objc_msgSend(pvVar1,sel_hyperAttributedStringWithRecognizedLinks);
  pvVar3 = _objc_msgSend(self->_commentsTextView,sel_selectedRange);
  pvVar4 = _objc_msgSend(self->_commentsTextView,sel_textStorage);
  pvVar1 = _objc_msgSend(self->_commentsTextView,sel_textStorage);
  pvVar1 = _objc_msgSend(pvVar1,sel_length);
  _objc_msgSend(pvVar4,sel_replaceCharactersInRange_withAttributedString_,0,pvVar1,pvVar2);
  pvVar4 = _objc_msgSend(self->_commentsTextView,sel_string);
  pvVar4 = _objc_msgSend(pvVar4,sel_length);
  if ((id)((int)extraout_EDX + (int)pvVar3) < pvVar4) {
    pvVar1 = extraout_EDX;
    _objc_msgSend(self->_commentsTextView,sel_setSelectedRange_,pvVar3,extraout_EDX,pvVar2);
  }
  _objc_msgSend(self,sel_commentsChanged_,0,pvVar1,pvVar2);
  return;
}

*/
- (void)textDidChange:(id)aChange
{
    NSAttributedString *linked = [[_commentsTextView string] hyperAttributedStringWithRecognizedLinks];
    NSRange selection = [_commentsTextView selectedRange];
    [[_commentsTextView textStorage] replaceCharactersInRange:NSMakeRange(0, [[_commentsTextView textStorage] length]) withAttributedString:linked];
    if (selection.location + selection.length < [[_commentsTextView string] length]) {
        [_commentsTextView setSelectedRange:selection];
    }
    [self commentsChanged:nil];
}

- (void)objectCursorAttributesDidChange:(id)aChange
{
    [self validateCursorView];
}

- (void)objectCommentsAttributesDidChange:(id)aChange
{
    [self validateCommentsView];
}

- (void)textDidEndEditing:(id)aEditing
{
    [self commentsChanged:[aEditing object]];
}

- (void)objectAttributesDidChange:(id)aChange
{
    [self validateGroupObjectSwitch];
    [self validateDraggableOptionsButton];
}

- (void)validateDraggableOptionsButton
{
    BOOL pvVar2;
    NSString *pcVar3;
    id pvVar1_2;

    pvVar2 = [[self cardObjectAttributes] isDraggable];
    [_draggableButton setHidden:((unsigned int)(!pvVar2))];
    pvVar1_2 = _draggableSwitch;
    if (!pvVar2) {
        pcVar3 = [_draggableButton title];
    }
    else {
        pcVar3 = @"";
    }
    [pvVar1_2 setTitle:pcVar3];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ef905 @ 000ef905, 232 bytes * /

void FUN_000ef905(HSGenericObjectFeaturesAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  char cVar2;
  id pvVar3;
  id self_00;
  
  pvVar3 = _objc_msgSend(self,sel_cardObjectAttributes);
  self_00 = _objc_msgSend(self,sel_snappingOptionsAttributes);
  pvVar1 = self->_groupObjectSwitch;
  if (pvVar3 != (id)0x0) {
    pvVar3 = _objc_msgSend(pvVar3,sel_isLocked);
    if ((char)pvVar3 == '\0') {
      pvVar3 = _objc_msgSend(self_00,sel_isDropOffTarget);
      if ((char)pvVar3 == '\0') {
        cVar2 = '\x01';
        goto LAB_000ef981;
      }
    }
  }
  cVar2 = '\0';
LAB_000ef981:
  _objc_msgSend(pvVar1,sel_setEnabled_,(int)cVar2);
  pvVar1 = self->_groupObjectSwitch;
  pvVar3 = _objc_msgSend(self,sel_objectAttributes);
  pvVar3 = _objc_msgSend(pvVar3,sel_isGroupObject);
  _objc_msgSend(pvVar1,sel_setState_,(uint)((char)pvVar3 != '\0'));
  return;
}

*/
- (void)validateGroupObjectSwitch
{
    id cardAttributes = [self cardObjectAttributes];
    id snapping = [self snappingOptionsAttributes];
    BOOL enabled = NO;
    if (cardAttributes != nil && ![cardAttributes isLocked] && ![snapping isDropOffTarget]) {
        enabled = YES;
    }
    [_groupObjectSwitch setEnabled:enabled];
    [_groupObjectSwitch setState:[[self objectAttributes] isGroupObject] ? 1 : 0];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ef733 @ 000ef733, 466 bytes * /

void FUN_000ef733(HSGenericObjectFeaturesAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  SEL op;
  char cVar5;
  undefined *puVar6;
  
  pvVar1 = _objc_msgSend(self,sel_assistant);
  pvVar1 = _objc_msgSend(pvVar1,sel_object);
  puVar6 = &DAT_0036e1d4;
  pvVar2 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0036e1d4);
  pvVar2 = _objc_msgSend(pvVar2,sel_hyperCursor);
  if (pvVar2 == (id)0x0) {
    pvVar3 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0036e1fc);
    puVar6 = &DAT_0036df2c;
    pvVar4 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0036df2c);
    op = sel_textCursor;
    if (pvVar4 == (id)0x0 && pvVar3 == (id)0x0) {
      while ((pvVar2 == (id)0x0 && (pvVar1 != (id)0x0))) {
        puVar6 = &DAT_0036e2d8;
        pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0036e2d8);
        pvVar1 = _objc_msgSend(pvVar1,sel_hyperParent);
        if (pvVar1 != (id)0x0) {
          puVar6 = &DAT_0036e1d4;
          pvVar2 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0036e1d4);
          pvVar2 = _objc_msgSend(pvVar2,sel_hyperCursor);
        }
      }
      op = sel_defaultPlayerCursor;
      if (pvVar2 != (id)0x0) goto LAB_000ef87b;
    }
    pvVar2 = _objc_msgSend(cls_HSCursor,op,puVar6);
  }
LAB_000ef87b:
  pvVar1 = self->_cursorImageView;
  pvVar2 = _objc_msgSend(pvVar2,sel_image,puVar6);
  _objc_msgSend(pvVar1,sel_setImage_,pvVar2);
  pvVar3 = _objc_msgSend(self,sel_cardObjectAttributes);
  pvVar1 = self->_cursorButton;
  if ((pvVar3 == (id)0x0) ||
     (pvVar2 = _objc_msgSend(pvVar3,sel_isLocked,pvVar2), (char)pvVar2 != '\0')) {
    cVar5 = '\0';
  }
  else {
    cVar5 = '\x01';
  }
  _objc_msgSend(pvVar1,sel_setEnabled_,(int)cVar5);
  return;
}

*/
- (void)validateCursorView
{
    id object = [[self assistant] object];
    id cursor = [[object queryHyperInterface:@protocol(HSCursorAttributes)] hyperCursor];
    if (cursor == nil) {
        id textField = [object queryHyperInterface:@protocol(HSSystemTextFieldAttributes)];
        id textView = [object queryHyperInterface:@protocol(HSSystemTextViewAttributes)];
        if (textView != nil || textField != nil) {
            cursor = [HSCursor textCursor];
        } else {
            id node = object;
            while (cursor == nil && node != nil) {
                node = [[node queryHyperInterface:@protocol(HSNodeChild)] hyperParent];
                if (node != nil) {
                    cursor = [[node queryHyperInterface:@protocol(HSCursorAttributes)] hyperCursor];
                }
            }
            if (cursor == nil) {
                cursor = [HSCursor defaultPlayerCursor];
            }
        }
    }
    [_cursorImageView setImage:[cursor image]];
    id cardAttributes = [self cardObjectAttributes];
    [_cursorButton setEnabled:(cardAttributes != nil && ![cardAttributes isLocked])];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ef5c6 @ 000ef5c6, 365 bytes * /

void FUN_000ef5c6(HSGenericObjectFeaturesAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  int extraout_EDX;
  undefined *puVar5;
  
  pvVar1 = _objc_msgSend(self,sel_assistant);
  pvVar1 = _objc_msgSend(pvVar1,sel_object);
  puVar5 = &DAT_0036e1ac;
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0036e1ac);
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperComments);
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperAttributedStringWithRecognizedLinks);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(self->_commentsTextView,sel_selectedRange,puVar5);
    pvVar3 = _objc_msgSend(self->_commentsTextView,sel_textStorage);
    pvVar4 = _objc_msgSend(self->_commentsTextView,sel_textStorage);
    pvVar4 = _objc_msgSend(pvVar4,sel_length);
    _objc_msgSend(pvVar3,sel_replaceCharactersInRange_withAttributedString_,0,pvVar4,pvVar1);
    pvVar3 = _objc_msgSend(self->_commentsTextView,sel_string);
    pvVar3 = _objc_msgSend(pvVar3,sel_length);
    if ((id)(extraout_EDX + (int)pvVar2) < pvVar3) {
      _objc_msgSend(self->_commentsTextView,sel_setSelectedRange_,pvVar2,extraout_EDX,pvVar1);
    }
  }
  return;
}

*/
- (void)validateCommentsView
{
    id object = [[self assistant] object];
    NSAttributedString *linked = [[[object queryHyperInterface:@protocol(HSCommentsAttributes)] hyperComments] hyperAttributedStringWithRecognizedLinks];
    if (linked != nil) {
        NSRange selection = [_commentsTextView selectedRange];
        [[_commentsTextView textStorage] replaceCharactersInRange:NSMakeRange(0, [[_commentsTextView textStorage] length]) withAttributedString:linked];
        if (selection.location + selection.length < [[_commentsTextView string] length]) {
            [_commentsTextView setSelectedRange:selection];
        }
    }
}

- (void)validateUI
{
    [self validateCommentsView];
    [self validateCursorView];
    [self validateGroupObjectSwitch];
    [self validateDraggableOptionsButton];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ef365 @ 000ef365, 513 bytes * /

void FUN_000ef365(HSGenericObjectFeaturesAssistantPane *self,SEL _cmd)

{
  undefined4 uVar1;
  id pvVar2;
  id pvVar3;
  undefined **ppuVar4;
  undefined *puVar5;
  undefined *puVar6;
  undefined *puVar7;
  undefined4 uVar8;
  undefined *puVar9;
  undefined *local_1c [3];
  
  pvVar2 = _objc_msgSend(self,sel_assistant);
  pvVar2 = _objc_msgSend(pvVar2,sel_object);
  pvVar3 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_0036dcfc);
  pvVar3 = _objc_msgSend(pvVar3,sel_attributeObservingController);
  puVar9 = &DAT_0036dce8;
  uVar1 = *(undefined4 *)PTR_0033601c;
  puVar7 = sel_objectAttributesDidChange_;
  uVar8 = uVar1;
  _objc_msgSend(pvVar3,sel_removeObserver_selector_ofChanges_ofAttributesOfHyperInterface_,self,
                sel_objectAttributesDidChange_,uVar1,&DAT_0036dce8);
  puVar5 = &DAT_0036de3c;
  local_1c[0] = &DAT_0036df2c;
  local_1c[1] = &DAT_0036e0f8;
  local_1c[2] = (undefined *)0x0;
  ppuVar4 = local_1c;
  do {
    if (puVar5 == (undefined *)0x0) {
LAB_000ef497:
      pvVar3 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_0036e1ac,puVar7,uVar8,puVar9);
      pvVar3 = _objc_msgSend(pvVar3,sel_attributeObservingController);
      _objc_msgSend(pvVar3,sel_removeObserver_selector_ofChanges_ofAttribute_,self,
                    sel_objectCommentsAttributesDidChange_,uVar1,&DAT_0036e1c0);
      pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_0036e1d4);
      pvVar2 = _objc_msgSend(pvVar2,sel_attributeObservingController);
      _objc_msgSend(pvVar2,sel_removeObserver_selector_ofChanges_ofAttribute_,self,
                    sel_objectCursorAttributesDidChange_,uVar1,&DAT_0036e1e8);
      return;
    }
    puVar6 = puVar5;
    pvVar3 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,puVar5,puVar7,uVar8,puVar9);
    if (pvVar3 != (id)0x0) {
      pvVar3 = _objc_msgSend(pvVar3,sel_attributeObservingController,puVar6,puVar7,uVar8,puVar9);
      puVar7 = sel_objectAttributesDidChange_;
      uVar8 = uVar1;
      _objc_msgSend(pvVar3,sel_removeObserver_selector_ofChanges_ofAttributesOfHyperInterface_,self,
                    sel_objectAttributesDidChange_,uVar1,puVar5);
      puVar9 = puVar5;
      goto LAB_000ef497;
    }
    puVar5 = *ppuVar4;
    ppuVar4 = ppuVar4 + 1;
  } while( true );
}

*/
- (void)unsubscribeFromNotifications
{
    id object = [[self assistant] object];
    Protocol *candidates[3] = { @protocol(HSSystemButtonAttributes), @protocol(HSSystemTextViewAttributes), @protocol(HSSystemImageViewAttributes) };
    [[[object queryHyperInterface:@protocol(HSAttributes)] attributeObservingController] removeObserver:self selector:@selector(objectAttributesDidChange:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSCardObjectAttributes)];
    for (int i = 0; i < 3; i++) {
        id attributes = [object queryHyperInterface:candidates[i]];
        if (attributes != nil) {
            [[attributes attributeObservingController] removeObserver:self selector:@selector(objectAttributesDidChange:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:candidates[i]];
            break;
        }
    }
    [[[object queryHyperInterface:@protocol(HSCommentsAttributes)] attributeObservingController] removeObserver:self selector:@selector(objectCommentsAttributesDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSCommentsAttribute)];
    [[[object queryHyperInterface:@protocol(HSCursorAttributes)] attributeObservingController] removeObserver:self selector:@selector(objectCursorAttributesDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSCursorAttribute)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ef144 @ 000ef144, 545 bytes * /

void FUN_000ef144(HSGenericObjectFeaturesAssistantPane *self,SEL _cmd)

{
  undefined4 uVar1;
  id pvVar2;
  id pvVar3;
  undefined **ppuVar4;
  undefined *puVar5;
  undefined *puVar6;
  undefined *puVar7;
  undefined4 uVar8;
  undefined *puVar9;
  undefined4 uVar10;
  undefined *local_1c [3];
  
  pvVar2 = _objc_msgSend(self,sel_assistant);
  pvVar2 = _objc_msgSend(pvVar2,sel_object);
  pvVar3 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_0036dcfc);
  pvVar3 = _objc_msgSend(pvVar3,sel_attributeObservingController);
  puVar9 = &DAT_0036dce8;
  uVar1 = *(undefined4 *)PTR_0033601c;
  uVar10 = 0xbe800000;
  puVar7 = sel_objectAttributesDidChange_;
  uVar8 = uVar1;
  _objc_msgSend(pvVar3,sel_addObserver_selector_ofChanges_ofAttributesOfHyperInterface_withPriority_
                ,self,sel_objectAttributesDidChange_,uVar1,&DAT_0036dce8,0xbe800000);
  puVar5 = &DAT_0036de3c;
  local_1c[0] = &DAT_0036df2c;
  local_1c[1] = &DAT_0036e0f8;
  local_1c[2] = (undefined *)0x0;
  ppuVar4 = local_1c;
  do {
    if (puVar5 == (undefined *)0x0) {
LAB_000ef286:
      pvVar3 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_0036e1ac,puVar7,uVar8,puVar9,
                             uVar10);
      pvVar3 = _objc_msgSend(pvVar3,sel_attributeObservingController);
      _objc_msgSend(pvVar3,sel_addObserver_selector_ofChanges_ofAttribute_withPriority_,self,
                    sel_objectCommentsAttributesDidChange_,uVar1,&DAT_0036e1c0,0xbe800000);
      pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_0036e1d4);
      pvVar2 = _objc_msgSend(pvVar2,sel_attributeObservingController);
      _objc_msgSend(pvVar2,sel_addObserver_selector_ofChanges_ofAttribute_withPriority_,self,
                    sel_objectCursorAttributesDidChange_,uVar1,&DAT_0036e1e8,0xbe800000);
      return;
    }
    puVar6 = puVar5;
    pvVar3 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,puVar5,puVar7,uVar8,puVar9,uVar10);
    if (pvVar3 != (id)0x0) {
      pvVar3 = _objc_msgSend(pvVar3,sel_attributeObservingController,puVar6,puVar7,uVar8,puVar9,
                             uVar10);
      uVar10 = 0xbe800000;
      puVar7 = sel_objectAttributesDidChange_;
      uVar8 = uVar1;
      _objc_msgSend(pvVar3,
                    sel_addObserver_selector_ofChanges_ofAttributesOfHyperInterface_withPriority_,
                    self,sel_objectAttributesDidChange_,uVar1,puVar5,0xbe800000);
      puVar9 = puVar5;
      goto LAB_000ef286;
    }
    puVar5 = *ppuVar4;
    ppuVar4 = ppuVar4 + 1;
  } while( true );
}

*/
- (void)subscribeToNotifications
{
    id object = [[self assistant] object];
    Protocol *candidates[3] = { @protocol(HSSystemButtonAttributes), @protocol(HSSystemTextViewAttributes), @protocol(HSSystemImageViewAttributes) };
    [[[object queryHyperInterface:@protocol(HSAttributes)] attributeObservingController] addObserver:self selector:@selector(objectAttributesDidChange:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSCardObjectAttributes) withPriority:-0.25];
    for (int i = 0; i < 3; i++) {
        id attributes = [object queryHyperInterface:candidates[i]];
        if (attributes != nil) {
            [[attributes attributeObservingController] addObserver:self selector:@selector(objectAttributesDidChange:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:candidates[i] withPriority:-0.25];
            break;
        }
    }
    [[[object queryHyperInterface:@protocol(HSCommentsAttributes)] attributeObservingController] addObserver:self selector:@selector(objectCommentsAttributesDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSCommentsAttribute) withPriority:-0.25];
    [[[object queryHyperInterface:@protocol(HSCursorAttributes)] attributeObservingController] addObserver:self selector:@selector(objectCursorAttributesDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSCursorAttribute) withPriority:-0.25];
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    HSCommentsTextView *pHVar2;

    [super viewWillDisappear:aDisappear];
    [_cardObjectController setContent:0];
    pHVar2 = _commentsTextView;
    [self commentsChanged:pHVar2];
    if ([_commentsTextView delegate] == self) {
        pHVar2 = nil;
        [_commentsTextView setDelegate:0];
    }
    [self unsubscribeFromNotifications];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [self validateUI];
    [_commentsTextView setDelegate:self];
    [_commentsTextView setUsesFontPanel:NO];
    [_commentsTextView setAllowsUndo:NO];
    [_cardObjectController setContent:[self objectAttributes]];
    [self subscribeToNotifications];
}

- (id)snappingOptionsAttributes
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSMutableSnapOptionsAttributes)];
}

- (id)cardObjectAttributes
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSCardObjectAttributes)];
}

- (id)objectAttributes
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSMutableCardObjectAttributes)];
}

- (BOOL)isEnabled
{
    return ![[self object] implementsHyperInterface:@protocol(HSEmbeddedEditor)];
}

- (void)dealloc
{
    [_cardObjectController setContent:0];
    [_cardObjectController release];
    [super dealloc];
}

- (id)initWithNibName:(id)aName
{
    self = [super initWithNibName:aName];
    if (self != nil) {
        [self setTitle:[[NSBundle mainBundle] localizedStringForKey:@"Features" value:@"" table:@"AssistantPanes"]];
        [self setIcon:[NSImage imageNamed:@"features"]];
    }
    return self;
}

- (id)init
{
    return [self initWithNibName:@"TextViewFeaturesPane"];
}

@end

