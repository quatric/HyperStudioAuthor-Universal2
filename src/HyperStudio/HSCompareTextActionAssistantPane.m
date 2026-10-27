#import "HSCompareTextActionAssistantPane.h"

@implementation HSCompareTextActionAssistantPane

/* i386 ivar offsets: _responseObjectPopUpButton=0x88, _textToMatchObjectPopUpButton=0x8c, _comparisonSelectorPopUpButton=0x90, _definedStringTextField=0x94, _rightAnswerObjectPopUpButton=0x98, _wrongAnswerObjectPopUpButton=0x9c, _ignoreCaseSensitivityButton=0xa0, _stack=0xa4, _rightAnswerObjectsMenu=0xa8, _wrongAnswerObjectsMenu=0xac, _responseObjectsMenu=0xb0, _textToMatchObjectsMenu=0xb4, _comparisonSelectorMenu=0xb8 */

- (void)ignoreCaseSensitivityChanged:(id)aChanged
{
    [[self compareTextActionAssistantPaneApplier] setCaseSensitiveComparison:(unsigned int)([_ignoreCaseSensitivityButton state] != 0x1)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0027f214 @ 0027f214, 121 bytes * /

void FUN_0027f214(HSCompareTextActionAssistantPane *self,SEL _cmd,id comparisonSelectorChanged)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(self->_comparisonSelectorPopUpButton,sel_indexOfSelectedItem);
  self_00 = _objc_msgSend(self,sel_compareTextActionAssistantPaneApplier);
  pvVar2 = _objc_msgSend(cls_HSCompareTextAction,sel_compareSelectors);
  _objc_msgSend(self_00,sel_setComparisonSelector_,*(undefined4 *)((int)pvVar2 + (int)pvVar1 * 4));
  return;
}

*/
- (void)comparisonSelectorChanged:(id)aChanged
{
    [[self compareTextActionAssistantPaneApplier] setComparisonSelector:[HSCompareTextAction compareSelectors][[_comparisonSelectorPopUpButton indexOfSelectedItem]]];
}

- (void)definedStringChanged:(id)aChanged
{
    [[self compareTextActionAssistantPaneApplier] setDefinedString:[_definedStringTextField stringValue]];
}

- (void)wrongAnswerObjectChanged:(id)aChanged
{
    [[self compareTextActionAssistantPaneApplier] setComparisonMismatchObjectUID:[[[_wrongAnswerObjectPopUpButton selectedItem] representedObject] hyperUID]];
}

- (void)rightAnswerObjectChanged:(id)aChanged
{
    [[self compareTextActionAssistantPaneApplier] setComparisonMatchObjectUID:[[[_rightAnswerObjectPopUpButton selectedItem] representedObject] hyperUID]];
}

- (void)textToMatchObjectChanged:(id)aChanged
{
    NSInteger pvVar1;
    id pvVar2;
    id pvVar1_2;
    NSString *pvVar2_2;

    pvVar1 = [_textToMatchObjectPopUpButton indexOfSelectedItem];
    pvVar2 = [self compareTextActionAssistantPaneApplier];
    if (pvVar1 == 0) {
        [pvVar2 setTextToMatchObjectUID:nil];
        pvVar1_2 = [self compareTextActionAssistantPaneApplier];
        pvVar2_2 = [_definedStringTextField stringValue];
    }
    else {
        [pvVar2 setTextToMatchObjectUID:[[[_textToMatchObjectPopUpButton selectedItem] representedObject] hyperUID]];
        pvVar1_2 = [self compareTextActionAssistantPaneApplier];
        pvVar2_2 = nil;
    }
    [pvVar1_2 setDefinedString:pvVar2_2];
}

- (void)responseObjectChanged:(id)aChanged
{
    [[self compareTextActionAssistantPaneApplier] setResponseObjectUID:[[[_responseObjectPopUpButton selectedItem] representedObject] hyperUID]];
}

- (void)controlTextDidChange:(id)aChange
{
    [self definedStringChanged:aChange];
}

- (id)helpTopicKey
{
    return @"HSCompareText";
}

- (void)autosetupActionSettings
{
    id pvVar1_2;

    pvVar1_2 = [[self compareTextActionAssistantPaneApplier] compareTextActionAttributes];
    if ([pvVar1_2 comparisonMatchObjectUID] == nil) {
        [self rightAnswerObjectChanged:nil];
    }
    if ([pvVar1_2 comparisonMismatchObjectUID] == nil) {
        [self wrongAnswerObjectChanged:nil];
    }
    if ([_responseObjectPopUpButton isEnabled]) {
        [self responseObjectChanged:nil];
    }
    if ([_textToMatchObjectPopUpButton isEnabled]) {
        [self textToMatchObjectChanged:nil];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0027e41d @ 0027e41d, 2492 bytes * /

void FUN_0027e41d(HSCompareTextActionAssistantPane *self,SEL _cmd)

{
  HSCheckBox *self_00;
  id pvVar1;
  cfstringStruct *pcVar2;
  id pvVar3;
  id pvVar4;
  HSCompareTextActionAssistantPane *pHVar5;
  HSPopUpButton *pHVar6;
  uint uVar7;
  SEL pcVar8;
  
  _objc_msgSend(self->_responseObjectPopUpButton,sel_setMenu_,0);
  _objc_msgSend(self->_textToMatchObjectPopUpButton,sel_setMenu_,0);
  _objc_msgSend(self->_rightAnswerObjectPopUpButton,sel_setMenu_,0);
  _objc_msgSend(self->_wrongAnswerObjectPopUpButton,sel_setMenu_,0);
  _objc_msgSend(self->_rightAnswerObjectsMenu,sel_release);
  self->_rightAnswerObjectsMenu = (id)0x0;
  _objc_msgSend(self->_wrongAnswerObjectsMenu,sel_release);
  self->_wrongAnswerObjectsMenu = (id)0x0;
  _objc_msgSend(self->_responseObjectsMenu,sel_release);
  self->_responseObjectsMenu = (id)0x0;
  _objc_msgSend(self->_textToMatchObjectsMenu,sel_release);
  self->_textToMatchObjectsMenu = (id)0x0;
  pvVar1 = _objc_msgSend(self,sel_rightAnswerCardsMenu);
  _objc_msgSend(self,sel_validatePopUpButton_withMenu_,self->_rightAnswerObjectPopUpButton,pvVar1);
  pvVar1 = _objc_msgSend(self,sel_wrongAnswerCardsMenu);
  _objc_msgSend(self,sel_validatePopUpButton_withMenu_,self->_wrongAnswerObjectPopUpButton,pvVar1);
  pvVar1 = _objc_msgSend(self,sel_responseObjectsMenu);
  _objc_msgSend(self,sel_validatePopUpButton_withMenu_,self->_responseObjectPopUpButton,pvVar1);
  pcVar2 = _objc_msgSend(self,sel_textToMatchObjectsMenu);
  pHVar6 = self->_textToMatchObjectPopUpButton;
  _objc_msgSend(self,sel_validatePopUpButton_withMenu_,pHVar6,pcVar2);
  pvVar1 = _objc_msgSend(self,sel_compareTextActionAssistantPaneApplier);
  pvVar1 = _objc_msgSend(pvVar1,sel_compareTextActionAttributes);
  pvVar3 = _objc_msgSend(pvVar1,sel_comparisonMatchObjectUID);
  if (pvVar3 == (id)0x0) {
    pHVar6 = self->_rightAnswerObjectPopUpButton;
    pHVar5 = (HSCompareTextActionAssistantPane *)0x0;
    pcVar8 = sel_selectItemAtIndex_;
  }
  else {
    pvVar3 = self->_stack;
    pvVar4 = _objc_msgSend(pvVar1,sel_comparisonMatchObjectUID,pHVar6,pcVar2);
    pvVar3 = _objc_msgSend(pvVar3,sel_childInTreeWithUID_,pvVar4);
    pHVar6 = self->_rightAnswerObjectPopUpButton;
    if (pvVar3 == (id)0x0) {
      pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar4);
      pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,
                             &cfstr_HSObjectIsMissingPopupTitle,&cfstr_empty,&cfstr_Dialogs);
      _objc_msgSend(pHVar6,sel_setTitle_,pvVar3);
      pHVar6 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
      pcVar8 = sel_addObserver_selector_name_object_;
      pHVar5 = self;
      pcVar2 = (cfstringStruct *)sel_popUpButtonWillPopUp_;
    }
    else {
      pvVar4 = _objc_msgSend(self,sel_rightAnswerCardsMenu,pvVar4);
      pHVar5 = _objc_msgSend(pvVar4,sel_indexOfItemWithRepresentedObject_,pvVar3);
      pcVar8 = sel_selectItemAtIndex_;
    }
  }
  _objc_msgSend(pHVar6,pcVar8,pHVar5,pcVar2);
  pvVar3 = _objc_msgSend(pvVar1,sel_comparisonMismatchObjectUID);
  if (pvVar3 == (id)0x0) {
    pHVar6 = self->_wrongAnswerObjectPopUpButton;
    pHVar5 = (HSCompareTextActionAssistantPane *)0x0;
    pcVar8 = sel_selectItemAtIndex_;
  }
  else {
    pvVar3 = self->_stack;
    pvVar4 = _objc_msgSend(pvVar1,sel_comparisonMismatchObjectUID,pHVar5,pcVar2);
    pvVar3 = _objc_msgSend(pvVar3,sel_childInTreeWithUID_,pvVar4);
    pHVar6 = self->_wrongAnswerObjectPopUpButton;
    if (pvVar3 == (id)0x0) {
      pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar4);
      pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,
                             &cfstr_HSObjectIsMissingPopupTitle,&cfstr_empty,&cfstr_Dialogs);
      _objc_msgSend(pHVar6,sel_setTitle_,pvVar3);
      pHVar6 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
      pcVar8 = sel_addObserver_selector_name_object_;
      pHVar5 = self;
      pcVar2 = (cfstringStruct *)sel_popUpButtonWillPopUp_;
    }
    else {
      pvVar4 = _objc_msgSend(self,sel_wrongAnswerCardsMenu,pvVar4);
      pHVar5 = _objc_msgSend(pvVar4,sel_indexOfItemWithRepresentedObject_,pvVar3);
      pcVar8 = sel_selectItemAtIndex_;
    }
  }
  _objc_msgSend(pHVar6,pcVar8,pHVar5,pcVar2);
  pvVar3 = _objc_msgSend(pvVar1,sel_responseObjectUID);
  if (pvVar3 == (id)0x0) {
    pvVar3 = _objc_msgSend(self->_responseObjectPopUpButton,sel_isEnabled,pHVar5,pcVar2);
    pHVar6 = self->_responseObjectPopUpButton;
    if ((char)pvVar3 == '\0') {
      pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pHVar5,pcVar2);
      pcVar2 = &cfstr_empty;
      pHVar5 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_None,&cfstr_empty,
                             &cfstr_Dialogs);
      pcVar8 = sel_setTitle_;
    }
    else {
      pHVar5 = (HSCompareTextActionAssistantPane *)0x1;
      pcVar8 = sel_selectItemAtIndex_;
    }
  }
  else {
    pvVar3 = self->_stack;
    pvVar4 = _objc_msgSend(pvVar1,sel_responseObjectUID,pHVar5,pcVar2);
    pvVar3 = _objc_msgSend(pvVar3,sel_childInTreeWithUID_,pvVar4);
    pHVar6 = self->_responseObjectPopUpButton;
    if (pvVar3 == (id)0x0) {
      pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar4);
      pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,
                             &cfstr_HSTextObjectIsMissingPopupTitle,&cfstr_empty,&cfstr_Dialogs);
      _objc_msgSend(pHVar6,sel_setTitle_,pvVar3);
      pHVar6 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
      pcVar8 = sel_addObserver_selector_name_object_;
      pHVar5 = self;
      pcVar2 = (cfstringStruct *)sel_popUpButtonWillPopUp_;
    }
    else {
      pvVar4 = _objc_msgSend(self,sel_responseObjectsMenu,pvVar4);
      pHVar5 = _objc_msgSend(pvVar4,sel_indexOfItemWithRepresentedObject_,pvVar3);
      pcVar8 = sel_selectItemAtIndex_;
    }
  }
  _objc_msgSend(pHVar6,pcVar8,pHVar5,pcVar2);
  pvVar3 = _objc_msgSend(pvVar1,sel_textToMatchObjectUID);
  if (pvVar3 == (id)0x0) {
    pvVar3 = _objc_msgSend(self->_textToMatchObjectPopUpButton,sel_isEnabled,pHVar5,pcVar2);
    if ((char)pvVar3 != '\0') goto LAB_0027ecaf;
    pHVar6 = self->_textToMatchObjectPopUpButton;
    pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pHVar5,pcVar2);
    pcVar2 = &cfstr_empty;
    pHVar5 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_None,&cfstr_empty,
                           &cfstr_Dialogs);
    pcVar8 = sel_setTitle_;
  }
  else {
    pvVar3 = self->_stack;
    pvVar4 = _objc_msgSend(pvVar1,sel_textToMatchObjectUID,pHVar5,pcVar2);
    pvVar3 = _objc_msgSend(pvVar3,sel_childInTreeWithUID_,pvVar4);
    pHVar6 = self->_textToMatchObjectPopUpButton;
    if (pvVar3 == (id)0x0) {
      pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar4);
      pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,
                             &cfstr_HSTextObjectIsMissingPopupTitle,&cfstr_empty,&cfstr_Dialogs);
      _objc_msgSend(pHVar6,sel_setTitle_,pvVar3);
      pHVar6 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
      pcVar8 = sel_addObserver_selector_name_object_;
      pHVar5 = self;
      pcVar2 = (cfstringStruct *)sel_popUpButtonWillPopUp_;
    }
    else {
      pvVar4 = _objc_msgSend(self,sel_textToMatchObjectsMenu,pvVar4);
      pHVar5 = _objc_msgSend(pvVar4,sel_indexOfItemWithRepresentedObject_,pvVar3);
      pcVar8 = sel_selectItemAtIndex_;
    }
  }
  _objc_msgSend(pHVar6,pcVar8,pHVar5,pcVar2);
LAB_0027ecaf:
  pvVar3 = _objc_msgSend(pvVar1,sel_definedString,pHVar5,pcVar2);
  if (pvVar3 != (id)0x0) {
    pvVar3 = self->_definedStringTextField;
    pHVar5 = _objc_msgSend(pvVar1,sel_definedString,pHVar5,pcVar2);
    _objc_msgSend(pvVar3,sel_setStringValue_,pHVar5);
  }
  pvVar3 = self->_definedStringTextField;
  pvVar4 = _objc_msgSend(self->_textToMatchObjectPopUpButton,sel_indexOfSelectedItem,pHVar5);
  _objc_msgSend(pvVar3,sel_setEnabled_,(uint)(pvVar4 == (id)0x0));
  pvVar3 = _objc_msgSend(pvVar1,sel_comparisonSelector);
  pvVar4 = _objc_msgSend(cls_HSCompareTextAction,sel_compareSelectors);
  for (uVar7 = 0; (uVar7 < 7 && (*(id *)((int)pvVar4 + uVar7 * 4) != pvVar3)); uVar7 = uVar7 + 1) {
  }
  _objc_msgSend(self->_comparisonSelectorPopUpButton,sel_selectItemAtIndex_,uVar7);
  self_00 = self->_ignoreCaseSensitivityButton;
  pvVar1 = _objc_msgSend(pvVar1,sel_isCaseSensitiveComparison);
  _objc_msgSend(self_00,sel_setState_,(uint)((char)pvVar1 == '\0'));
  return;
}

*/
- (void)validateUI
{
    [_responseObjectPopUpButton setMenu:nil];
    [_textToMatchObjectPopUpButton setMenu:nil];
    [_rightAnswerObjectPopUpButton setMenu:nil];
    [_wrongAnswerObjectPopUpButton setMenu:nil];
    [_rightAnswerObjectsMenu release];
    _rightAnswerObjectsMenu = nil;
    [_wrongAnswerObjectsMenu release];
    _wrongAnswerObjectsMenu = nil;
    [_responseObjectsMenu release];
    _responseObjectsMenu = nil;
    [_textToMatchObjectsMenu release];
    _textToMatchObjectsMenu = nil;
    [self validatePopUpButton:_rightAnswerObjectPopUpButton withMenu:[self rightAnswerCardsMenu]];
    [self validatePopUpButton:_wrongAnswerObjectPopUpButton withMenu:[self wrongAnswerCardsMenu]];
    [self validatePopUpButton:_responseObjectPopUpButton withMenu:[self responseObjectsMenu]];
    [self validatePopUpButton:_textToMatchObjectPopUpButton withMenu:[self textToMatchObjectsMenu]];
    id attributes = [[self compareTextActionAssistantPaneApplier] compareTextActionAttributes];
    id uid = [attributes comparisonMatchObjectUID];
    if (uid == nil) {
        [_rightAnswerObjectPopUpButton selectItemAtIndex:0];
    } else {
        id object = [_stack childInTreeWithUID:[attributes comparisonMatchObjectUID]];
        if (object == nil) {
            [_rightAnswerObjectPopUpButton setTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSObjectIsMissingPopupTitle" value:@"" table:@"Dialogs"]];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popUpButtonWillPopUp:) name:NSPopUpButtonWillPopUpNotification object:_rightAnswerObjectPopUpButton];
        } else {
            [_rightAnswerObjectPopUpButton selectItemAtIndex:[[self rightAnswerCardsMenu] indexOfItemWithRepresentedObject:object]];
        }
    }
    uid = [attributes comparisonMismatchObjectUID];
    if (uid == nil) {
        [_wrongAnswerObjectPopUpButton selectItemAtIndex:0];
    } else {
        id object = [_stack childInTreeWithUID:[attributes comparisonMismatchObjectUID]];
        if (object == nil) {
            [_wrongAnswerObjectPopUpButton setTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSObjectIsMissingPopupTitle" value:@"" table:@"Dialogs"]];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popUpButtonWillPopUp:) name:NSPopUpButtonWillPopUpNotification object:_wrongAnswerObjectPopUpButton];
        } else {
            [_wrongAnswerObjectPopUpButton selectItemAtIndex:[[self wrongAnswerCardsMenu] indexOfItemWithRepresentedObject:object]];
        }
    }
    uid = [attributes responseObjectUID];
    if (uid == nil) {
        if ([_responseObjectPopUpButton isEnabled]) {
            [_responseObjectPopUpButton selectItemAtIndex:1];
        } else {
            [_responseObjectPopUpButton setTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"None" value:@"" table:@"Dialogs"]];
        }
    } else {
        id object = [_stack childInTreeWithUID:[attributes responseObjectUID]];
        if (object == nil) {
            [_responseObjectPopUpButton setTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSTextObjectIsMissingPopupTitle" value:@"" table:@"Dialogs"]];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popUpButtonWillPopUp:) name:NSPopUpButtonWillPopUpNotification object:_responseObjectPopUpButton];
        } else {
            [_responseObjectPopUpButton selectItemAtIndex:[[self responseObjectsMenu] indexOfItemWithRepresentedObject:object]];
        }
    }
    uid = [attributes textToMatchObjectUID];
    if (uid == nil) {
        if (![_textToMatchObjectPopUpButton isEnabled]) {
            [_textToMatchObjectPopUpButton setTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"None" value:@"" table:@"Dialogs"]];
        }
    } else {
        id object = [_stack childInTreeWithUID:[attributes textToMatchObjectUID]];
        if (object == nil) {
            [_textToMatchObjectPopUpButton setTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSTextObjectIsMissingPopupTitle" value:@"" table:@"Dialogs"]];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popUpButtonWillPopUp:) name:NSPopUpButtonWillPopUpNotification object:_textToMatchObjectPopUpButton];
        } else {
            [_textToMatchObjectPopUpButton selectItemAtIndex:[[self textToMatchObjectsMenu] indexOfItemWithRepresentedObject:object]];
        }
    }
    if ([attributes definedString] != nil) {
        [_definedStringTextField setStringValue:[attributes definedString]];
    }
    [_definedStringTextField setEnabled:[_textToMatchObjectPopUpButton indexOfSelectedItem] == 0];
    SEL comparisonSelector = [attributes comparisonSelector];
    SEL *selectors = [HSCompareTextAction compareSelectors];
    NSUInteger selectorIndex;
    for (selectorIndex = 0; selectorIndex < 7 && selectors[selectorIndex] != comparisonSelector; selectorIndex++) {
    }
    [_comparisonSelectorPopUpButton selectItemAtIndex:selectorIndex];
    [_ignoreCaseSensitivityButton setState:![attributes isCaseSensitiveComparison]];
}

- (void)validatePopUpButton:(id)aButton withMenu:(id)aMenu
{
    NSInteger pvVar1;

    pvVar1 = [aMenu numberOfItems];
    if (0 < (int)pvVar1) {
        [aButton setMenu:aMenu];
    }
    [aButton setEnabled:(unsigned int)(0 < (int)pvVar1)];
}

- (void)popUpButtonWillPopUp:(id)aUp
{
    [[aUp object] removeItemWithTitle:[[[aUp object] selectedItem] title]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSPopUpButtonWillPopUpNotification object:[aUp object]];
}

- (id)wrongAnswerCardsMenu
{
    id pvVar1;

    pvVar1 = _wrongAnswerObjectsMenu;
    if (pvVar1 == nil) {
        [self composeMenues];
        pvVar1 = _wrongAnswerObjectsMenu;
    }
    return pvVar1;
}

- (id)rightAnswerCardsMenu
{
    id pvVar1;

    pvVar1 = _rightAnswerObjectsMenu;
    if (pvVar1 == nil) {
        [self composeMenues];
        pvVar1 = _rightAnswerObjectsMenu;
    }
    return pvVar1;
}

- (id)textToMatchObjectsMenu
{
    id pvVar1;

    pvVar1 = _textToMatchObjectsMenu;
    if (pvVar1 == nil) {
        [self composeMenues];
        pvVar1 = _textToMatchObjectsMenu;
    }
    return pvVar1;
}

- (id)responseObjectsMenu
{
    id pvVar1;

    pvVar1 = _responseObjectsMenu;
    if (pvVar1 == nil) {
        [self composeMenues];
        pvVar1 = _responseObjectsMenu;
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0027fbe6 @ 0027fbe6, 2242 bytes * /

void FUN_0027fbe6(HSCompareTextActionAssistantPane *self,SEL _cmd)

{
  int iVar1;
  bool bVar2;
  bool bVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  undefined4 *puVar8;
  undefined1 *puVar9;
  id pvVar10;
  id pvVar11;
  id pvVar12;
  id pvVar13;
  undefined4 *self_00;
  undefined *puVar14;
  cfstringStruct *pcVar15;
  undefined1 *self_01;
  cfstringStruct *pcVar16;
  undefined1 *local_8c;
  id local_88;
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
  
  pvVar4 = _objc_msgSend(cls_NSMenu,sel_new);
  self->_rightAnswerObjectsMenu = pvVar4;
  pvVar4 = _objc_msgSend(cls_NSMenu,sel_new);
  self->_responseObjectsMenu = pvVar4;
  _objc_msgSend(pvVar4,sel_setAutoenablesItems_,0);
  pvVar4 = _objc_msgSend(self,sel_actionAttributes);
  pvVar4 = _objc_msgSend(pvVar4,sel_owner);
  pvVar5 = _objc_msgSend(pvVar4,sel_queryHyperInterface_,&DAT_00387a58);
  pvVar5 = _objc_msgSend(pvVar5,sel_hyperUID);
  puVar14 = &DAT_00387b0c;
  pvVar4 = _objc_msgSend(pvVar4,sel_queryHyperInterface_,&DAT_00387b0c);
  pvVar4 = _objc_msgSend(pvVar4,sel_hyperParent);
  if (pvVar4 == (id)0x0) {
    pvVar4 = _objc_msgSend(self,sel_card,puVar14);
  }
  pvVar4 = _objc_msgSend(pvVar4,sel_queryHyperInterface_,&DAT_00387a58);
  pvVar6 = _objc_msgSend(pvVar4,sel_hyperUID);
  pvVar4 = self->_rightAnswerObjectsMenu;
  pvVar7 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pcVar16 = &cfstr_empty;
  puVar8 = _objc_msgSend(pvVar7,sel_localizedStringForKey_value_table_,
                         &cfstr_HSNoActionStringMenuItemTitle,&cfstr_empty,&cfstr_Dialogs);
  self_01 = (undefined1 *)0x0;
  _objc_msgSend(pvVar4,sel_addItemWithTitle_action_keyEquivalent_,puVar8,0,&cfstr_empty);
  pvVar4 = _objc_msgSend(self->_stack,sel_hyperChildren);
  puVar9 = _objc_msgSend(pvVar4,sel_count);
  if (puVar9 != (undefined1 *)0x0) {
    local_8c = (undefined1 *)0x0;
    do {
      pvVar7 = _objc_msgSend(pvVar4,sel_objectAtIndex_,local_8c,self_01,pcVar16);
      pvVar10 = _objc_msgSend(pvVar7,sel_hyperUID);
      local_8c = local_8c + 1;
      pvVar11 = _objc_msgSend(pvVar10,sel_isEqual_,pvVar6);
      if ((char)pvVar11 == '\0') {
        pvVar11 = pvVar5;
        pvVar12 = _objc_msgSend(pvVar10,sel_isEqual_,pvVar5);
        if ((char)pvVar12 != '\0') goto LAB_0027fe88;
        bVar2 = false;
      }
      else {
LAB_0027fe88:
        pvVar11 = pvVar5;
        pvVar10 = _objc_msgSend(pvVar10,sel_isEqual_,pvVar5);
        if ((char)pvVar10 == '\0') {
          pvVar10 = _objc_msgSend(cls_NSMenuItem,sel_new,pvVar11);
          _objc_msgSend(pvVar10,sel_setRepresentedObject_,pvVar7);
          puVar14 = cls_NSString;
          pvVar11 = _objc_msgSend(pvVar7,sel_hyperTitle);
          pvVar11 = _objc_msgSend(puVar14,sel_stringWithFormat_,&cfstr__u_____,local_8c,pvVar11);
          _objc_msgSend(pvVar10,sel_setTitle_,pvVar11);
          pvVar11 = pvVar10;
          _objc_msgSend(self->_rightAnswerObjectsMenu,sel_addItem_,pvVar10);
          _objc_msgSend(pvVar10,sel_release);
        }
        bVar2 = true;
      }
      local_74 = 0;
      local_70 = 0;
      local_6c = (int *)0x0;
      local_68 = 0;
      local_64 = 0;
      local_60 = 0;
      local_5c = 0;
      local_58 = 0;
      pvVar10 = _objc_msgSend(pvVar7,sel_hyperChildren,pvVar11);
      self_01 = local_50;
      puVar8 = &local_74;
      pcVar16 = (cfstringStruct *)0x10;
      local_88 = _objc_msgSend(pvVar10,sel_countByEnumeratingWithState_objects_count_,puVar8,self_01
                               ,0x10);
      if (local_88 != (id)0x0) {
        iVar1 = *local_6c;
        bVar3 = true;
        do {
          local_78 = (id)0x0;
          do {
            if (iVar1 != *local_6c) {
              pvVar11 = _objc_msgSend(pvVar7,sel_hyperChildren,puVar8,self_01,pcVar16);
              _objc_enumerationMutation(pvVar11);
            }
            pvVar11 = *(id *)(local_70 + (int)local_78 * 4);
            if (bVar2) {
              pvVar12 = _objc_msgSend(pvVar11,sel_hyperUID,puVar8,self_01,pcVar16);
              pvVar13 = _objc_msgSend(pvVar5,sel_isEqual_,pvVar12);
              if ((char)pvVar13 == '\0') {
                pvVar12 = _objc_msgSend(cls_NSMenuItem,sel_new,pvVar12);
                _objc_msgSend(pvVar12,sel_setRepresentedObject_,pvVar11);
                pvVar13 = _objc_msgSend(pvVar11,sel_queryHyperInterface_,&DAT_00387a80);
                pvVar13 = _objc_msgSend(pvVar13,sel_hyperName);
                _objc_msgSend(pvVar12,sel_setTitle_,pvVar13);
                _objc_msgSend(self->_rightAnswerObjectsMenu,sel_addItem_,pvVar12);
                _objc_msgSend(pvVar12,sel_release);
              }
            }
            local_78 = (id)((int)local_78 + 1);
            puVar8 = (undefined4 *)&DAT_00387b20;
            pvVar11 = _objc_msgSend(pvVar11,sel_queryHyperInterface_,&DAT_00387b20);
            puVar14 = cls_NSString;
            if (pvVar11 != (id)0x0) {
              if (bVar3) {
                pvVar12 = _objc_msgSend(cls_NSBundle,sel_mainBundle,puVar8);
                pcVar16 = &cfstr_AssistantPanes;
                pvVar12 = _objc_msgSend(pvVar12,sel_localizedStringForKey_value_table_,
                                        &cfstr_Card_title,&cfstr_empty,&cfstr_AssistantPanes);
                self_01 = local_8c;
                puVar8 = _objc_msgSend(puVar14,sel_stringWithFormat_,pvVar12,local_8c);
                _objc_msgSend(self->_responseObjectsMenu,sel_insertSeparatorWithTitle_,puVar8);
                bVar3 = false;
              }
              self_00 = _objc_msgSend(cls_NSMenuItem,sel_new,puVar8,self_01,pcVar16);
              _objc_msgSend(self_00,sel_setRepresentedObject_,pvVar11);
              puVar14 = &DAT_00387a80;
              pvVar12 = _objc_msgSend(pvVar11,sel_queryHyperInterface_,&DAT_00387a80);
              pvVar12 = _objc_msgSend(pvVar12,sel_hyperName);
              if (pvVar12 == (id)0x0) {
LAB_0028028e:
                pvVar11 = _objc_msgSend(pvVar11,sel_queryHyperInterface_,&DAT_00387bfc);
                self_01 = _objc_msgSend(pvVar11,sel_hyperPlainText);
                pvVar11 = _objc_msgSend(self_01,sel_length);
                puVar14 = cls_NSString;
                if (pvVar11 < (id)0x15) {
                  pcVar15 = &cfstr_____;
                }
                else {
                  self_01 = _objc_msgSend(self_01,sel_substringToIndex_,0x14);
                  pcVar15 = &cfstr________;
                }
                pvVar12 = _objc_msgSend(puVar14,sel_stringWithFormat_,pcVar15,self_01);
              }
              else {
                pvVar13 = _objc_msgSend(pvVar12,sel_length,puVar14);
                if (pvVar13 == (id)0x0) goto LAB_0028028e;
              }
              _objc_msgSend(self_00,sel_setTitle_,pvVar12,self_01);
              puVar8 = self_00;
              _objc_msgSend(self->_responseObjectsMenu,sel_addItem_,self_00);
              _objc_msgSend(self_00,sel_release);
            }
          } while (local_78 < local_88);
          self_01 = local_50;
          puVar8 = &local_74;
          pcVar16 = (cfstringStruct *)0x10;
          local_88 = _objc_msgSend(pvVar10,sel_countByEnumeratingWithState_objects_count_,puVar8,
                                   self_01,0x10);
        } while (local_88 != (id)0x0);
      }
    } while (local_8c < puVar9);
  }
  pvVar4 = _objc_msgSend(self->_responseObjectsMenu,sel_copy,puVar8,self_01,pcVar16);
  self->_textToMatchObjectsMenu = pvVar4;
  pvVar5 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar5 = _objc_msgSend(pvVar5,sel_localizedStringForKey_value_table_,
                         &cfstr_HSDefinedTextStringMenuItemTitle,&cfstr_empty,&cfstr_Dialogs);
  _objc_msgSend(pvVar4,sel_insertItemWithTitle_action_keyEquivalent_atIndex_,pvVar5,0,&cfstr_empty,0
               );
  pvVar4 = _objc_msgSend(self->_rightAnswerObjectsMenu,sel_copy);
  self->_wrongAnswerObjectsMenu = pvVar4;
  return;
}

*/
- (void)composeMenues
{
    _rightAnswerObjectsMenu = [NSMenu new];
    _responseObjectsMenu = [NSMenu new];
    [_responseObjectsMenu setAutoenablesItems:NO];
    id owner = [[self actionAttributes] owner];
    id ownerUID = [[owner queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID];
    id ownerParent = [[owner queryHyperInterface:@protocol(HSNodeParentAttribute)] hyperParent];
    if (ownerParent == nil) {
        ownerParent = [self card];
    }
    id cardUID = [[ownerParent queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID];
    [_rightAnswerObjectsMenu addItemWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSNoActionStringMenuItemTitle" value:@"" table:@"Dialogs"] action:NULL keyEquivalent:@""];
    NSArray *cards = [_stack hyperChildren];
    NSUInteger cardCount = [cards count];
    for (NSUInteger cardIndex = 0; cardIndex < cardCount;) {
        id card = [cards objectAtIndex:cardIndex];
        id uid = [card hyperUID];
        cardIndex++;
        BOOL includesChildren;
        if ([uid isEqual:cardUID] || [uid isEqual:ownerUID]) {
            if (![uid isEqual:ownerUID]) {
                NSMenuItem *item = [NSMenuItem new];
                [item setRepresentedObject:card];
                [item setTitle:[NSString stringWithFormat:@"%u (%@)", (unsigned int)cardIndex, [card hyperTitle]]];
                [_rightAnswerObjectsMenu addItem:item];
                [item release];
            }
            includesChildren = YES;
        } else {
            includesChildren = NO;
        }
        BOOL firstTextObject = YES;
        for (id child in [card hyperChildren]) {
            if (includesChildren) {
                if (![ownerUID isEqual:[child hyperUID]]) {
                    NSMenuItem *item = [NSMenuItem new];
                    [item setRepresentedObject:child];
                    [item setTitle:[[child queryHyperInterface:@protocol(HSObjectNameAttribute)] hyperName]];
                    [_rightAnswerObjectsMenu addItem:item];
                    [item release];
                }
            }
            id textAttributes = [child queryHyperInterface:@protocol(HSSystemTextViewAttributes)];
            if (textAttributes != nil) {
                if (firstTextObject) {
                    NSString *header = [[NSBundle mainBundle] localizedStringForKey:@"Card title" value:@"" table:@"AssistantPanes"];
                    [_responseObjectsMenu insertSeparatorWithTitle:[NSString stringWithFormat:header, (unsigned int)cardIndex]];
                    firstTextObject = NO;
                }
                NSMenuItem *item = [NSMenuItem new];
                [item setRepresentedObject:textAttributes];
                NSString *name = [[textAttributes queryHyperInterface:@protocol(HSObjectNameAttribute)] hyperName];
                if (name == nil || [name length] == 0) {
                    NSString *text = [[textAttributes queryHyperInterface:@protocol(HSTextViewTextAttribute)] hyperPlainText];
                    if ([text length] < 0x15) {
                        name = [NSString stringWithFormat:@"\"%@\"", text];
                    } else {
                        name = [NSString stringWithFormat:@"\"%@...\"", [text substringToIndex:0x14]];
                    }
                }
                [item setTitle:name];
                [_responseObjectsMenu addItem:item];
                [item release];
            }
        }
    }
    _textToMatchObjectsMenu = [_responseObjectsMenu copy];
    [_textToMatchObjectsMenu insertItemWithTitle:[[NSBundle mainBundle] localizedStringForKey:@"HSDefinedTextStringMenuItemTitle" value:@"" table:@"Dialogs"] action:NULL keyEquivalent:@"" atIndex:0];
    _wrongAnswerObjectsMenu = [_rightAnswerObjectsMenu copy];
}

- (void)validateUIWithNotification:(id)aNotification
{
    [self validateUI];
}

- (id)initialKeyView
{
    return _responseObjectPopUpButton;
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [self removeActionAssistantPaneObserver];
    [super viewWillDisappear:aDisappear];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [_stack release];
    _stack = [[[[[[self actionAttributes] owner] hyperObjectForAction:[self actionAttributes]] queryHyperInterface:@protocol(HSUserObjectSupport)] stack] retain];
    [self validateUI];
    [self autosetupActionSettings];
    [self addActionAssistantPaneObserver];
}

- (id)actionAttribute
{
    return (id)@protocol(HSCompareTextActionAttributes);
}

- (id)actionAttributes
{
    return [[self compareTextActionAssistantPaneApplier] compareTextActionAttributes];
}

- (id)actionType
{
    return [HSCompareTextAction actionType];
}

- (id)compareTextActionAssistantPaneApplier
{
    return [self applier];
}

- (Class)applierClass
{
    return [HSCompareTextActionAssistantPaneApplier class];
}

- (void)dealloc
{
    [_stack release];
    [_rightAnswerObjectsMenu release];
    [_responseObjectsMenu release];
    [_wrongAnswerObjectsMenu release];
    [_textToMatchObjectsMenu release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"CompareTextAssistantPane"];
    return self;
}

@end

@implementation HSCompareTextActionAssistantPaneApplier

/* i386 ivar offsets: _initialResponseObjectUID=0x30, _initialTextToMatchObjectUID=0x34, _initialDefinedString=0x38, _initialComparisonMatchObjectUID=0x3c, _initialComparisonMismatchObjectUID=0x40, _initialComparisonSelector=0x44, _isCaseSensitiveComparisonInitially=0x48, _responseObjectUID=0x4c, _textToMatchObjectUID=0x50, _definedString=0x54, _comparisonMatchObjectUID=0x58, _comparisonMismatchObjectUID=0x5c, _comparisonSelector=0x60, _isCaseSensitiveComparison=0x64 */

- (BOOL)areSettingsEqual
{
    BOOL pvVar1;
    BOOL bVar2;

    pvVar1 = [super areSettingsEqual];
    if ((_responseObjectUID != nil) || (bVar2 = pvVar1, _initialResponseObjectUID != nil)) {
        if ((!pvVar1) || (pvVar1 = [_responseObjectUID isEqual:_initialResponseObjectUID], !pvVar1)) {
            bVar2 = NO;
        }
        else {
            bVar2 = YES;
        }
    }
    if ((_textToMatchObjectUID != nil) || (_initialTextToMatchObjectUID != nil)) {
        if ((bVar2) && (pvVar1 = [_textToMatchObjectUID isEqual:_initialTextToMatchObjectUID], pvVar1)) {
            bVar2 = YES;
        }
        else {
            bVar2 = NO;
        }
    }
    if ((_definedString != nil) || (_initialDefinedString != nil)) {
        if ((bVar2) && (pvVar1 = [_definedString isEqual:_initialDefinedString], pvVar1)) {
            bVar2 = YES;
        }
        else {
            bVar2 = NO;
        }
    }
    if ((_comparisonMatchObjectUID != nil) || (_initialComparisonMatchObjectUID != nil)) {
        if ((bVar2) && (pvVar1 = [_comparisonMatchObjectUID isEqual:_initialComparisonMatchObjectUID], pvVar1)) {
            bVar2 = YES;
        }
        else {
            bVar2 = NO;
        }
    }
    if ((_comparisonMismatchObjectUID == nil) && (_initialComparisonMismatchObjectUID == nil)) {
        if (!bVar2) {
            return NO;
        }
    }
    else {
        if (!bVar2) {
            return NO;
        }
        pvVar1 = [_comparisonMismatchObjectUID isEqual:_initialComparisonMismatchObjectUID];
        if (!pvVar1) {
            return NO;
        }
    }
    if (_comparisonSelector != _initialComparisonSelector) {
        return NO;
    }
    if (_isCaseSensitiveComparison != NO) {
        if (_isCaseSensitiveComparisonInitially == NO) {
            return YES;
        }
        if (_isCaseSensitiveComparison != NO) {
            return NO;
        }
    }
    return _isCaseSensitiveComparisonInitially != NO;
}

- (void)makeCurrentEqualToInitial
{
    id pvVar1;

    [super makeCurrentEqualToInitial];
    if (_initialResponseObjectUID != _responseObjectUID) {
        [_responseObjectUID release];
        pvVar1 = [_initialResponseObjectUID retain];
        _responseObjectUID = pvVar1;
    }
    if (_initialTextToMatchObjectUID != _textToMatchObjectUID) {
        [_textToMatchObjectUID release];
        pvVar1 = [_initialTextToMatchObjectUID retain];
        _textToMatchObjectUID = pvVar1;
    }
    if (_initialComparisonMatchObjectUID != _comparisonMatchObjectUID) {
        [_comparisonMatchObjectUID release];
        pvVar1 = [_initialComparisonMatchObjectUID retain];
        _comparisonMatchObjectUID = pvVar1;
    }
    if (_initialComparisonMismatchObjectUID != _comparisonMismatchObjectUID) {
        [_comparisonMismatchObjectUID release];
        pvVar1 = [_initialComparisonMismatchObjectUID retain];
        _comparisonMismatchObjectUID = pvVar1;
    }
    if (_initialDefinedString != _definedString) {
        [_definedString release];
        pvVar1 = [_initialDefinedString retain];
        _definedString = pvVar1;
    }
    _comparisonSelector = _initialComparisonSelector;
    _isCaseSensitiveComparison = _isCaseSensitiveComparisonInitially;
}

- (void)makeInitialEqualToCurrent
{
    id pvVar1;

    [super makeInitialEqualToCurrent];
    if (_initialResponseObjectUID != _responseObjectUID) {
        [_initialResponseObjectUID release];
        pvVar1 = [_responseObjectUID retain];
        _initialResponseObjectUID = pvVar1;
    }
    if (_initialTextToMatchObjectUID != _textToMatchObjectUID) {
        [_initialTextToMatchObjectUID release];
        pvVar1 = [_textToMatchObjectUID retain];
        _initialTextToMatchObjectUID = pvVar1;
    }
    if (_initialComparisonMatchObjectUID != _comparisonMatchObjectUID) {
        [_initialComparisonMatchObjectUID release];
        pvVar1 = [_comparisonMatchObjectUID retain];
        _initialComparisonMatchObjectUID = pvVar1;
    }
    if (_initialComparisonMismatchObjectUID != _comparisonMismatchObjectUID) {
        [_initialComparisonMismatchObjectUID release];
        pvVar1 = [_comparisonMismatchObjectUID retain];
        _initialComparisonMismatchObjectUID = pvVar1;
    }
    if (_initialDefinedString != _definedString) {
        [_initialDefinedString release];
        pvVar1 = [_definedString retain];
        _initialDefinedString = pvVar1;
    }
    _initialComparisonSelector = _comparisonSelector;
    _isCaseSensitiveComparisonInitially = _isCaseSensitiveComparison;
}

- (void)setInitialSettingsToObject
{
    id self_00;

    self_00 = [self compareTextActionAttributes];
    [self_00 setComparisonMatchObjectUID:_initialComparisonMatchObjectUID];
    [self_00 setComparisonMismatchObjectUID:_initialComparisonMismatchObjectUID];
    [self_00 setDefinedString:_initialDefinedString];
    [self_00 setResponseObjectUID:_initialResponseObjectUID];
    [self_00 setTextToMatchObjectUID:_initialTextToMatchObjectUID];
    [self_00 setComparisonSelector:_initialComparisonSelector];
    [self_00 setCaseSensitiveComparison:_isCaseSensitiveComparisonInitially];
    [super setInitialSettingsToObject];
}

- (void)setCurrentSettingsToObject
{
    id self_00;

    [super setCurrentSettingsToObject];
    self_00 = [self compareTextActionAttributes];
    [self_00 setComparisonMatchObjectUID:_comparisonMatchObjectUID];
    [self_00 setComparisonMismatchObjectUID:_comparisonMismatchObjectUID];
    [self_00 setDefinedString:_definedString];
    [self_00 setResponseObjectUID:_responseObjectUID];
    [self_00 setTextToMatchObjectUID:_textToMatchObjectUID];
    [self_00 setComparisonSelector:_comparisonSelector];
    [self_00 setCaseSensitiveComparison:_isCaseSensitiveComparison];
}

- (void)setCaseSensitiveComparison:(BOOL)aComparison
{
    if (((_isCaseSensitiveComparison != NO) && (aComparison == NO)) || ((_isCaseSensitiveComparison == NO && (aComparison != NO)))) {
        _isCaseSensitiveComparison = aComparison;
        [self disableUndo];
        [[self compareTextActionAttributes] setCaseSensitiveComparison:aComparison];
        [self enableUndo];
    }
}

- (void)setComparisonSelector:(SEL)aSelector
{
    if (_comparisonSelector != aSelector) {
        _comparisonSelector = aSelector;
        [self disableUndo];
        [[self compareTextActionAttributes] setComparisonSelector:aSelector];
        [self enableUndo];
    }
}

- (void)setDefinedString:(id)aString
{
    if (![_definedString isEqual:aString]) {
        [_definedString release];
        _definedString = [aString retain];
        [self disableUndo];
        [[self compareTextActionAttributes] setDefinedString:_definedString];
        [self enableUndo];
    }
}

- (void)setComparisonMismatchObjectUID:(id)aUID
{
    if (![_comparisonMismatchObjectUID isEqual:aUID]) {
        [_comparisonMismatchObjectUID release];
        _comparisonMismatchObjectUID = [aUID retain];
        [self disableUndo];
        [[self compareTextActionAttributes] setComparisonMismatchObjectUID:_comparisonMismatchObjectUID];
        [self enableUndo];
    }
}

- (void)setComparisonMatchObjectUID:(id)aUID
{
    if (![_comparisonMatchObjectUID isEqual:aUID]) {
        [_comparisonMatchObjectUID release];
        _comparisonMatchObjectUID = [aUID retain];
        [self disableUndo];
        [[self compareTextActionAttributes] setComparisonMatchObjectUID:_comparisonMatchObjectUID];
        [self enableUndo];
    }
}

- (void)setTextToMatchObjectUID:(id)aUID
{
    if (![aUID isEqual:_textToMatchObjectUID]) {
        [_textToMatchObjectUID release];
        _textToMatchObjectUID = [aUID retain];
        [self disableUndo];
        [[self compareTextActionAttributes] setTextToMatchObjectUID:_textToMatchObjectUID];
        [self enableUndo];
    }
}

- (void)setResponseObjectUID:(id)aUID
{
    if (![aUID isEqual:_responseObjectUID]) {
        [_responseObjectUID release];
        _responseObjectUID = [aUID retain];
        [self disableUndo];
        [[self compareTextActionAttributes] setResponseObjectUID:_responseObjectUID];
        [self enableUndo];
    }
}

- (id)compareTextActionAttributes
{
    return [[self actionAttributes] queryHyperInterface:@protocol(HSCompareTextActionAttributes)];
}

- (void)setUpInitialSettings
{
    id pvVar1;

    [super setUpInitialSettings];
    pvVar1 = [self compareTextActionAttributes];
    _initialResponseObjectUID = [[pvVar1 responseObjectUID] retain];
    _initialTextToMatchObjectUID = [[pvVar1 textToMatchObjectUID] retain];
    _initialDefinedString = [[pvVar1 definedString] retain];
    _initialComparisonMatchObjectUID = [[pvVar1 comparisonMatchObjectUID] retain];
    _initialComparisonMismatchObjectUID = [[pvVar1 comparisonMismatchObjectUID] retain];
    _initialComparisonSelector = [pvVar1 comparisonSelector];
    _isCaseSensitiveComparisonInitially = (BOOL)[pvVar1 isCaseSensitiveComparison];
    _responseObjectUID = [_initialResponseObjectUID retain];
    _textToMatchObjectUID = [_initialTextToMatchObjectUID retain];
    _definedString = [_initialDefinedString retain];
    _comparisonMatchObjectUID = [_initialComparisonMatchObjectUID retain];
    _comparisonMismatchObjectUID = [_initialComparisonMismatchObjectUID retain];
    _comparisonSelector = _initialComparisonSelector;
    _isCaseSensitiveComparison = _isCaseSensitiveComparisonInitially;
}

- (void)dealloc
{
    [_initialResponseObjectUID release];
    [_initialTextToMatchObjectUID release];
    [_initialDefinedString release];
    [_initialComparisonMatchObjectUID release];
    [_initialComparisonMismatchObjectUID release];
    [_responseObjectUID release];
    [_textToMatchObjectUID release];
    [_definedString release];
    [_comparisonMatchObjectUID release];
    [_comparisonMismatchObjectUID release];
    [super dealloc];
}

@end

