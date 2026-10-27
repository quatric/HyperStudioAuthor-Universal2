#import "HSReadWriteTextActionAssistantPane.h"

@implementation HSReadWriteTextActionAssistantPane

/* i386 ivar offsets: _textObjectsPopUpButton=0x88, _chooseFilePopUpButton=0x8c, _operationMatrix=0x90, _changeModeButton=0x94, _warningMessageTextField=0x98, _attributes=0x9c, _textObjectsMenu=0xa0, _fileMenu=0xa4, _textObjectIsMissing=0xa8, _noTextObjects=0xa9, _frameForRead=0xac, _frameForWrite=0xbc, _tooltipForRead=0xcc, _tooltipForWrite=0xd0 */

- (void)HSReadWriteTextActionAssistantPane_removeObservers
{
    int uVar1;
    id pvVar2;
    id pvVar2_2;
    int uVar1_2;

    pvVar2 = [self stack];
    uVar1 = HSActualWillAttributeChanges;
    [pvVar2 removeObserver:self selector:@selector(HSReadWriteTextActionAssistantPane_cardsWillChange:) ofChanges:uVar1 ofAttribute:@protocol(HSNodeContainerChildrenAttribute)];
    [pvVar2 removeObserver:self selector:@selector(HSReadWriteTextActionAssistantPane_objectsWillChange:) ofChanges:uVar1 ofAttribute:@protocol(HSNodeContainerChildrenAttribute) ofChildrenInDepthRange:NSMakeRange(0, 1)];
    uVar1_2 = HSActualDidAttributeChanges;
    [pvVar2 removeObserver:self selector:@selector(HSReadWriteTextActionAssistantPane_objectNameDidChange:) ofChanges:uVar1_2 ofAttribute:@protocol(HSObjectNameAttribute) ofChildrenInDepthRange:NSMakeRange(1, 1)];
    [pvVar2 removeObserver:self selector:@selector(HSReadWriteTextActionAssistantPane_objectEditableStateDidChange:) ofChanges:uVar1_2 ofAttribute:@protocol(HSSystemEditableAttribute) ofChildrenInDepthRange:NSMakeRange(1, 1)];
    pvVar2_2 = [_attributes attributeObservingController];
    [pvVar2_2 removeObserver:self selector:@selector(HSReadWriteTextActionAssistantPane_targetObjectWillBeUndoneOrRedone:) ofChanges:0x100 ofAttribute:@protocol(HSReadWriteTextActionTargetObjectAttribute)];
    [pvVar2_2 removeObserver:self selector:@selector(HSReadWriteTextActionAssistantPane_fileURLWillBeUndoneOrRedone:) ofChanges:0x100 ofAttribute:@protocol(HSReadWriteTextActionFileURLAttribute)];
    [pvVar2_2 removeObserver:self selector:@selector(HSReadWriteTextActionAssistantPane_operationWillBeUndoneOrRedone:) ofChanges:0x100 ofAttribute:@protocol(HSReadWriteTextActionOperationAttribute)];
    [pvVar2_2 removeObserver:self selector:@selector(HSReadWriteTextActionAssistantPane_modeWillBeUndoneOrRedone:) ofChanges:0x100 ofAttribute:@protocol(HSReadWriteTextActionModeAttribute)];
    [pvVar2_2 removeObserver:self selector:@selector(HSReadWriteTextActionAssistantPane_targetObjectWasUndoneOrRedone:) ofChanges:0x200 ofAttribute:@protocol(HSReadWriteTextActionTargetObjectAttribute)];
    [pvVar2_2 removeObserver:self selector:@selector(HSReadWriteTextActionAssistantPane_fileURLWasUndoneOrRedone:) ofChanges:0x200 ofAttribute:@protocol(HSReadWriteTextActionFileURLAttribute)];
    [pvVar2_2 removeObserver:self selector:@selector(HSReadWriteTextActionAssistantPane_modeWasUndoneOrRedone:) ofChanges:0x200 ofAttribute:@protocol(HSReadWriteTextActionModeAttribute)];
    [pvVar2_2 removeObserver:self selector:@selector(HSReadWriteTextActionAssistantPane_operationWasUndoneOrRedone:) ofChanges:0x200 ofAttribute:@protocol(HSReadWriteTextActionOperationAttribute)];
}

- (void)HSReadWriteTextActionAssistantPane_addObservers
{
    int uVar1;
    id pvVar2;
    id pvVar2_2;
    int uVar1_2;

    pvVar2 = [self stack];
    uVar1 = HSActualWillAttributeChanges;
    [pvVar2 addObserver:self selector:@selector(HSReadWriteTextActionAssistantPane_cardsWillChange:) ofChanges:uVar1 ofAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:-0.25];
    [pvVar2 addObserver:self selector:@selector(HSReadWriteTextActionAssistantPane_objectsWillChange:) ofChanges:uVar1 ofAttribute:@protocol(HSNodeContainerChildrenAttribute) ofChildrenInDepthRange:NSMakeRange(0, 1) withPriority:-0.25];
    uVar1_2 = HSActualDidAttributeChanges;
    [pvVar2 addObserver:self selector:@selector(HSReadWriteTextActionAssistantPane_objectNameDidChange:) ofChanges:uVar1_2 ofAttribute:@protocol(HSObjectNameAttribute) ofChildrenInDepthRange:NSMakeRange(1, 1) withPriority:-0.25];
    [pvVar2 addObserver:self selector:@selector(HSReadWriteTextActionAssistantPane_objectEditableStateDidChange:) ofChanges:uVar1_2 ofAttribute:@protocol(HSSystemEditableAttribute) ofChildrenInDepthRange:NSMakeRange(1, 1) withPriority:-0.25];
    pvVar2_2 = [_attributes attributeObservingController];
    [pvVar2_2 addObserver:self selector:@selector(HSReadWriteTextActionAssistantPane_targetObjectWillBeUndoneOrRedone:) ofChanges:0x100 ofAttribute:@protocol(HSReadWriteTextActionTargetObjectAttribute) withPriority:-0.25];
    [pvVar2_2 addObserver:self selector:@selector(HSReadWriteTextActionAssistantPane_fileURLWillBeUndoneOrRedone:) ofChanges:0x100 ofAttribute:@protocol(HSReadWriteTextActionFileURLAttribute) withPriority:-0.25];
    [pvVar2_2 addObserver:self selector:@selector(HSReadWriteTextActionAssistantPane_modeWillBeUndoneOrRedone:) ofChanges:0x100 ofAttribute:@protocol(HSReadWriteTextActionModeAttribute) withPriority:-0.25];
    [pvVar2_2 addObserver:self selector:@selector(HSReadWriteTextActionAssistantPane_operationWillBeUndoneOrRedone:) ofChanges:0x100 ofAttribute:@protocol(HSReadWriteTextActionOperationAttribute) withPriority:-0.25];
    [pvVar2_2 addObserver:self selector:@selector(HSReadWriteTextActionAssistantPane_targetObjectWasUndoneOrRedone:) ofChanges:0x200 ofAttribute:@protocol(HSReadWriteTextActionTargetObjectAttribute) withPriority:-0.25];
    [pvVar2_2 addObserver:self selector:@selector(HSReadWriteTextActionAssistantPane_fileURLWasUndoneOrRedone:) ofChanges:0x200 ofAttribute:@protocol(HSReadWriteTextActionFileURLAttribute) withPriority:-0.25];
    [pvVar2_2 addObserver:self selector:@selector(HSReadWriteTextActionAssistantPane_modeWasUndoneOrRedone:) ofChanges:0x200 ofAttribute:@protocol(HSReadWriteTextActionModeAttribute) withPriority:-0.25];
    [pvVar2_2 addObserver:self selector:@selector(HSReadWriteTextActionAssistantPane_operationWasUndoneOrRedone:) ofChanges:0x200 ofAttribute:@protocol(HSReadWriteTextActionOperationAttribute) withPriority:-0.25];
}

- (void)HSReadWriteTextActionAssistantPane_modeWasUndoneOrRedone:(id)aRedone
{
    id self_00;

    self_00 = [self readWriteTextActionAssistantPaneApplier];
    [self_00 setModeAsInitial];
    [self_00 disableUndo];
    [self_00 setCurrentModeToObject];
    [self_00 enableUndo];
}

- (void)HSReadWriteTextActionAssistantPane_modeWillBeUndoneOrRedone:(id)aRedone
{
    id self_00;

    self_00 = [self readWriteTextActionAssistantPaneApplier];
    [self_00 disableUndo];
    [self_00 setInitialModeToObject];
    [self_00 enableUndo];
}

- (void)HSReadWriteTextActionAssistantPane_operationWasUndoneOrRedone:(id)aRedone
{
    id self_00;

    self_00 = [self readWriteTextActionAssistantPaneApplier];
    [self_00 setOperationAsInitial];
    [self_00 disableUndo];
    [self_00 setCurrentOperationToObject];
    [self_00 enableUndo];
}

- (void)HSReadWriteTextActionAssistantPane_operationWillBeUndoneOrRedone:(id)aRedone
{
    id self_00;

    self_00 = [self readWriteTextActionAssistantPaneApplier];
    [self_00 disableUndo];
    [self_00 setInitialOperationToObject];
    [self_00 enableUndo];
}

- (void)HSReadWriteTextActionAssistantPane_fileURLWasUndoneOrRedone:(id)aRedone
{
    id self_00;

    self_00 = [self readWriteTextActionAssistantPaneApplier];
    [self_00 setFileURLAsInitial];
    [self_00 disableUndo];
    [self_00 setCurrentFileURLToObject];
    [self_00 enableUndo];
}

- (void)HSReadWriteTextActionAssistantPane_fileURLWillBeUndoneOrRedone:(id)aRedone
{
    id self_00;

    self_00 = [self readWriteTextActionAssistantPaneApplier];
    [self_00 disableUndo];
    [self_00 setInitialFileURLToObject];
    [self_00 enableUndo];
}

- (void)HSReadWriteTextActionAssistantPane_targetObjectWasUndoneOrRedone:(id)aRedone
{
    id self_00;

    self_00 = [self readWriteTextActionAssistantPaneApplier];
    [self_00 setTargetObjectAsInitial];
    [self_00 disableUndo];
    [self_00 setCurrentTargetObjectUIDToObject];
    [self_00 enableUndo];
}

- (void)HSReadWriteTextActionAssistantPane_targetObjectWillBeUndoneOrRedone:(id)aRedone
{
    id self_00;

    self_00 = [self readWriteTextActionAssistantPaneApplier];
    [self_00 disableUndo];
    [self_00 setInitialTargetObjectToObject];
    [self_00 enableUndo];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029f9a6 @ 0029f9a6, 333 bytes * /

void FUN_0029f9a6(HSReadWriteTextActionAssistantPane *self,SEL _cmd,
                 id HSReadWriteTextActionAssistantPane_objectEditableStateDidChange)

{
  id pvVar1;
  undefined *puVar2;
  SEL op;
  
  pvVar1 = _objc_msgSend(HSReadWriteTextActionAssistantPane_objectEditableStateDidChange,sel_object)
  ;
  puVar2 = &DAT_003891f0;
  pvVar1 = _objc_msgSend(pvVar1,sel_implementsHyperInterface_,&DAT_003891f0);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(HSReadWriteTextActionAssistantPane_objectEditableStateDidChange,
                           sel_object,puVar2);
    pvVar1 = _objc_msgSend(pvVar1,sel_isEditable);
    if ((char)pvVar1 == '\0') {
      pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,puVar2);
      _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,&cfstr_Text_object_is_not_editable
                    ,&cfstr_empty,&cfstr_AssistantPanes);
      puVar2 = _objc_msgSend(HSReadWriteTextActionAssistantPane_objectEditableStateDidChange,
                             sel_object);
      op = sel_HSReadWriteTextActionAssistantPane_removeItemAtPopUpByNodeChild_withErrorText_;
    }
    else {
      if (self->_textObjectIsMissing != '\0') {
        puVar2 = (undefined *)0x0;
        _objc_msgSend(self,sel_popUpButtonWillPopUp_,0);
      }
      _objc_msgSend(self,sel_HSReadWriteTextActionAssistantPane_validateTextObjectsPopUpButton,
                    puVar2);
      self = _objc_msgSend(self,sel_navigationPaneSwitcher);
      op = sel_validateUserInterface;
    }
    _objc_msgSend(self,op,puVar2);
  }
  return;
}

*/
- (void)HSReadWriteTextActionAssistantPane_objectEditableStateDidChange:(id)aChange
{
    if (![[aChange object] implementsHyperInterface:@protocol(HSSystemTextViewAttributes)]) {
        return;
    }
    if (![[aChange object] isEditable]) {
        [self HSReadWriteTextActionAssistantPane_removeItemAtPopUpByNodeChild:[aChange object] withErrorText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Text object is not editable" value:@"" table:@"AssistantPanes"]];
        return;
    }
    if (_textObjectIsMissing) {
        [self popUpButtonWillPopUp:nil];
    }
    [self HSReadWriteTextActionAssistantPane_validateTextObjectsPopUpButton];
    [[self navigationPaneSwitcher] validateUserInterface];
}

- (void)HSReadWriteTextActionAssistantPane_objectNameDidChange:(id)aChange
{
    id pvVar2;
    id pcVar3;
    id pcVar4;
    id pvVar1_3;
    NSInteger pvVar1_4;
    NSMenu *pvVar2_4;

    if ([[aChange object] implementsHyperInterface:@protocol(HSSystemTextViewAttributes)]) {
        pvVar1_3 = _textObjectsMenu;
        pvVar2 = [aChange object]
        ;
        pvVar1_4 = [pvVar1_3 indexOfItemWithRepresentedObject:pvVar2];
        if (-1 < (int)pvVar1_4) {
            pcVar3 = [[[aChange object] queryHyperInterface:@protocol(HSObjectAttributes)] hyperName];
            pvVar2_4 = [_textObjectsPopUpButton menu];
            pcVar4 = @"";
            if (pcVar3 != NULL) {
                pcVar4 = pcVar3;
            }
            [[pvVar2_4 itemAtIndex:pvVar1_4] setTitle:pcVar4];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a0ae4 @ 002a0ae4, 1000 bytes * /

void FUN_002a0ae4(HSReadWriteTextActionAssistantPane *self,SEL _cmd,
                 id HSReadWriteTextActionAssistantPane_objectsWillChange)

{
  int iVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  undefined1 *puVar5;
  id pvVar6;
  undefined4 *puVar7;
  undefined *puVar8;
  undefined4 uVar9;
  cfstringStruct *pcVar10;
  id local_e0;
  id local_dc;
  undefined4 local_d4;
  int local_d0;
  int *local_cc;
  undefined4 local_c8;
  undefined4 local_c4;
  undefined4 local_c0;
  undefined4 local_bc;
  undefined4 local_b8;
  undefined1 local_b4 [64];
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined1 local_50 [64];
  
  pvVar2 = _objc_msgSend(HSReadWriteTextActionAssistantPane_objectsWillChange,sel_userInfo);
  pvVar2 = _objc_msgSend(pvVar2,sel_valueForKey_,&cfstr_HSNodeChildrenForAddition);
  local_d4 = 0;
  local_d0 = 0;
  local_cc = (int *)0x0;
  local_c8 = 0;
  local_c4 = 0;
  local_c0 = 0;
  local_bc = 0;
  local_b8 = 0;
  puVar5 = local_b4;
  puVar7 = &local_d4;
  uVar9 = 0x10;
  local_dc = _objc_msgSend(pvVar2,sel_countByEnumeratingWithState_objects_count_,puVar7,puVar5,0x10)
  ;
  if (local_dc != (id)0x0) {
    iVar1 = *local_cc;
    do {
      pvVar6 = (id)0x0;
      do {
        if (iVar1 != *local_cc) {
          _objc_enumerationMutation(pvVar2);
        }
        puVar8 = &DAT_003891f0;
        pvVar3 = _objc_msgSend(*(id *)(local_d0 + (int)pvVar6 * 4),sel_implementsHyperInterface_,
                               &DAT_003891f0,puVar5,uVar9);
        if ((char)pvVar3 != '\0') {
          _objc_msgSend(self,sel_HSReadWriteTextActionAssistantPane_validateTextObjectsPopUpButton,
                        puVar8);
          pvVar2 = _objc_msgSend(self,sel_navigationPaneSwitcher);
          _objc_msgSend(pvVar2,sel_validateUserInterface);
          return;
        }
        pvVar6 = (id)((int)pvVar6 + 1);
      } while (pvVar6 < local_dc);
      puVar5 = local_b4;
      puVar7 = &local_d4;
      uVar9 = 0x10;
      local_dc = _objc_msgSend(pvVar2,sel_countByEnumeratingWithState_objects_count_,puVar7,puVar5,
                               0x10);
    } while (local_dc != (id)0x0);
  }
  pvVar2 = _objc_msgSend(HSReadWriteTextActionAssistantPane_objectsWillChange,sel_userInfo,puVar7,
                         puVar5,uVar9);
  pvVar2 = _objc_msgSend(pvVar2,sel_valueForKey_,&cfstr_HSNodeChildrenForRemoval);
  pvVar6 = _objc_msgSend(self,sel_assistant);
  pvVar6 = _objc_msgSend(pvVar6,sel_object);
  pvVar6 = _objc_msgSend(pvVar6,sel_queryHyperInterface_,&DAT_00389510);
  pvVar3 = _objc_msgSend(pvVar2,sel_containsObject_,pvVar6);
  if ((char)pvVar3 != '\0') {
    _objc_msgSend(self,sel_HSReadWriteTextActionAssistantPane_removeObservers,pvVar6);
  }
  local_74 = 0;
  local_70 = 0;
  local_6c = (int *)0x0;
  local_68 = 0;
  local_64 = 0;
  local_60 = 0;
  local_5c = 0;
  local_58 = 0;
  puVar5 = local_50;
  pcVar10 = (cfstringStruct *)0x10;
  local_e0 = _objc_msgSend(pvVar2,sel_countByEnumeratingWithState_objects_count_,&local_74,puVar5,
                           0x10);
  if (local_e0 != (id)0x0) {
    iVar1 = *local_6c;
    do {
      pvVar6 = (id)0x0;
      do {
        if (iVar1 != *local_6c) {
          _objc_enumerationMutation(pvVar2);
        }
        pvVar3 = *(id *)(local_70 + (int)pvVar6 * 4);
        puVar8 = &DAT_003891f0;
        pvVar4 = _objc_msgSend(pvVar3,sel_implementsHyperInterface_,&DAT_003891f0,puVar5,pcVar10);
        if ((char)pvVar4 != '\0') {
          pvVar4 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,puVar8);
          pcVar10 = &cfstr_AssistantPanes;
          puVar5 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,
                                 &cfstr_Text_object_is_missing,&cfstr_empty,&cfstr_AssistantPanes);
          _objc_msgSend(self,
                        sel_HSReadWriteTextActionAssistantPane_removeItemAtPopUpByNodeChild_withErrorText_
                        ,pvVar3,puVar5);
        }
        pvVar6 = (id)((int)pvVar6 + 1);
      } while (pvVar6 < local_e0);
      puVar5 = local_50;
      pcVar10 = (cfstringStruct *)0x10;
      local_e0 = _objc_msgSend(pvVar2,sel_countByEnumeratingWithState_objects_count_,&local_74,
                               puVar5,0x10);
    } while (local_e0 != (id)0x0);
  }
  return;
}

*/
- (void)HSReadWriteTextActionAssistantPane_objectsWillChange:(id)aChange
{
    for (id child in [[aChange userInfo] valueForKey:@"HSNodeChildrenForAddition"]) {
        if ([child implementsHyperInterface:@protocol(HSSystemTextViewAttributes)]) {
            [self HSReadWriteTextActionAssistantPane_validateTextObjectsPopUpButton];
            [[self navigationPaneSwitcher] validateUserInterface];
            return;
        }
    }
    NSArray *removed = [[aChange userInfo] valueForKey:@"HSNodeChildrenForRemoval"];
    if ([removed containsObject:[[[self assistant] object] queryHyperInterface:@protocol(HSNodeChild)]]) {
        [self HSReadWriteTextActionAssistantPane_removeObservers];
    }
    for (id child in removed) {
        if ([child implementsHyperInterface:@protocol(HSSystemTextViewAttributes)]) {
            [self HSReadWriteTextActionAssistantPane_removeItemAtPopUpByNodeChild:child withErrorText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Text object is missing" value:@"" table:@"AssistantPanes"]];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a0ecc @ 002a0ecc, 1708 bytes * /

void FUN_002a0ecc(HSReadWriteTextActionAssistantPane *self,SEL _cmd,
                 id HSReadWriteTextActionAssistantPane_cardsWillChange)

{
  int iVar1;
  int iVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  undefined1 *puVar7;
  id pvVar8;
  undefined4 *puVar9;
  undefined4 *self_00;
  undefined4 uVar10;
  cfstringStruct *pcVar11;
  id local_1b4;
  id local_1b0;
  id local_1ac;
  id local_1a8;
  id local_19c;
  id local_198;
  undefined4 local_194;
  int local_190;
  int *local_18c;
  undefined4 local_188;
  undefined4 local_184;
  undefined4 local_180;
  undefined4 local_17c;
  undefined4 local_178;
  undefined1 local_174 [64];
  undefined4 local_134;
  int local_130;
  int *local_12c;
  undefined4 local_128;
  undefined4 local_124;
  undefined4 local_120;
  undefined4 local_11c;
  undefined4 local_118;
  undefined1 local_114 [64];
  undefined4 local_d4;
  int local_d0;
  int *local_cc;
  undefined4 local_c8;
  undefined4 local_c4;
  undefined4 local_c0;
  undefined4 local_bc;
  undefined4 local_b8;
  undefined1 local_b4 [64];
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined1 local_50 [64];
  
  pvVar3 = _objc_msgSend(HSReadWriteTextActionAssistantPane_cardsWillChange,sel_userInfo);
  pvVar3 = _objc_msgSend(pvVar3,sel_valueForKey_,&cfstr_HSNodeChildrenForAddition);
  local_194 = 0;
  local_190 = 0;
  local_18c = (int *)0x0;
  local_188 = 0;
  local_184 = 0;
  local_180 = 0;
  local_17c = 0;
  local_178 = 0;
  puVar7 = local_174;
  puVar9 = &local_194;
  uVar10 = 0x10;
  local_1b0 = _objc_msgSend(pvVar3,sel_countByEnumeratingWithState_objects_count_,puVar9,puVar7,0x10
                           );
  if (local_1b0 != (id)0x0) {
    iVar1 = *local_18c;
    do {
      local_1a8 = (id)0x0;
      do {
        if (iVar1 != *local_18c) {
          _objc_enumerationMutation(pvVar3);
        }
        pvVar6 = *(id *)(local_190 + (int)local_1a8 * 4);
        local_134 = 0;
        local_130 = 0;
        local_12c = (int *)0x0;
        local_128 = 0;
        local_124 = 0;
        local_120 = 0;
        local_11c = 0;
        local_118 = 0;
        pvVar4 = _objc_msgSend(pvVar6,sel_hyperChildren,puVar9,puVar7,uVar10);
        puVar7 = local_114;
        puVar9 = &local_134;
        uVar10 = 0x10;
        local_198 = _objc_msgSend(pvVar4,sel_countByEnumeratingWithState_objects_count_);
        if (local_198 != (id)0x0) {
          iVar2 = *local_12c;
          do {
            pvVar8 = (id)0x0;
            do {
              if (iVar2 != *local_12c) {
                pvVar5 = _objc_msgSend(pvVar6,sel_hyperChildren,puVar9,puVar7,uVar10);
                _objc_enumerationMutation(pvVar5);
              }
              puVar9 = (undefined4 *)&DAT_003891f0;
              pvVar5 = _objc_msgSend(*(id *)(local_130 + (int)pvVar8 * 4),
                                     sel_implementsHyperInterface_,&DAT_003891f0,puVar7,uVar10);
              if ((char)pvVar5 != '\0') {
                _objc_msgSend(self,
                              sel_HSReadWriteTextActionAssistantPane_validateTextObjectsPopUpButton,
                              puVar9);
                pvVar3 = _objc_msgSend(self,sel_navigationPaneSwitcher);
                _objc_msgSend(pvVar3,sel_validateUserInterface);
                return;
              }
              pvVar8 = (id)((int)pvVar8 + 1);
            } while (pvVar8 < local_198);
            puVar7 = local_114;
            puVar9 = &local_134;
            uVar10 = 0x10;
            local_198 = _objc_msgSend(pvVar4,sel_countByEnumeratingWithState_objects_count_,puVar9,
                                      puVar7,0x10);
          } while (local_198 != (id)0x0);
        }
        local_1a8 = (id)((int)local_1a8 + 1);
      } while (local_1a8 < local_1b0);
      puVar7 = local_174;
      puVar9 = &local_194;
      uVar10 = 0x10;
      local_1b0 = _objc_msgSend(pvVar3,sel_countByEnumeratingWithState_objects_count_,puVar9,puVar7,
                                0x10);
    } while (local_1b0 != (id)0x0);
  }
  pvVar3 = _objc_msgSend(HSReadWriteTextActionAssistantPane_cardsWillChange,sel_userInfo,puVar9,
                         puVar7,uVar10);
  pvVar3 = _objc_msgSend(pvVar3,sel_valueForKey_,&cfstr_HSNodeChildrenForRemoval);
  pvVar6 = _objc_msgSend(self,sel_assistant);
  pvVar6 = _objc_msgSend(pvVar6,sel_object);
  pvVar6 = _objc_msgSend(pvVar6,sel_queryHyperInterface_,&DAT_00389510);
  pvVar4 = _objc_msgSend(pvVar3,sel_containsObject_,pvVar6);
  if ((char)pvVar4 != '\0') {
    _objc_msgSend(self,sel_HSReadWriteTextActionAssistantPane_removeObservers,pvVar6);
  }
  local_d4 = 0;
  local_d0 = 0;
  local_cc = (int *)0x0;
  local_c8 = 0;
  local_c4 = 0;
  local_c0 = 0;
  local_bc = 0;
  local_b8 = 0;
  puVar7 = local_b4;
  puVar9 = &local_d4;
  pcVar11 = (cfstringStruct *)0x10;
  local_1b4 = _objc_msgSend(pvVar3,sel_countByEnumeratingWithState_objects_count_,puVar9,puVar7,0x10
                           );
  if (local_1b4 != (id)0x0) {
    iVar1 = *local_cc;
    do {
      local_1ac = (id)0x0;
      do {
        if (iVar1 != *local_cc) {
          _objc_enumerationMutation(pvVar3);
        }
        pvVar6 = *(id *)(local_d0 + (int)local_1ac * 4);
        local_74 = 0;
        local_70 = 0;
        local_6c = (int *)0x0;
        local_68 = 0;
        local_64 = 0;
        local_60 = 0;
        local_5c = 0;
        local_58 = 0;
        pvVar4 = _objc_msgSend(pvVar6,sel_hyperChildren,puVar9,puVar7,pcVar11);
        puVar7 = local_50;
        puVar9 = &local_74;
        pcVar11 = (cfstringStruct *)0x10;
        local_19c = _objc_msgSend(pvVar4,sel_countByEnumeratingWithState_objects_count_);
        if (local_19c != (id)0x0) {
          iVar2 = *local_6c;
          do {
            pvVar8 = (id)0x0;
            do {
              if (iVar2 != *local_6c) {
                pvVar5 = _objc_msgSend(pvVar6,sel_hyperChildren,puVar9,puVar7,pcVar11);
                _objc_enumerationMutation(pvVar5);
              }
              self_00 = *(undefined4 **)(local_70 + (int)pvVar8 * 4);
              puVar9 = (undefined4 *)&DAT_003891f0;
              pvVar5 = _objc_msgSend(self_00,sel_implementsHyperInterface_,&DAT_003891f0,puVar7,
                                     pcVar11);
              if ((char)pvVar5 != '\0') {
                pvVar5 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,puVar9);
                pcVar11 = &cfstr_AssistantPanes;
                puVar7 = _objc_msgSend(pvVar5,sel_localizedStringForKey_value_table_,
                                       &cfstr_Text_object_is_missing,&cfstr_empty,
                                       &cfstr_AssistantPanes);
                _objc_msgSend(self,
                              sel_HSReadWriteTextActionAssistantPane_removeItemAtPopUpByNodeChild_withErrorText_
                              ,self_00,puVar7);
                puVar9 = self_00;
              }
              pvVar8 = (id)((int)pvVar8 + 1);
            } while (pvVar8 < local_19c);
            puVar7 = local_50;
            puVar9 = &local_74;
            pcVar11 = (cfstringStruct *)0x10;
            local_19c = _objc_msgSend(pvVar4,sel_countByEnumeratingWithState_objects_count_,puVar9,
                                      puVar7,0x10);
          } while (local_19c != (id)0x0);
        }
        local_1ac = (id)((int)local_1ac + 1);
      } while (local_1ac < local_1b4);
      puVar7 = local_b4;
      puVar9 = &local_d4;
      pcVar11 = (cfstringStruct *)0x10;
      local_1b4 = _objc_msgSend(pvVar3,sel_countByEnumeratingWithState_objects_count_,puVar9,puVar7,
                                0x10);
    } while (local_1b4 != (id)0x0);
  }
  return;
}

*/
- (void)HSReadWriteTextActionAssistantPane_cardsWillChange:(id)aChange
{
    for (id card in [[aChange userInfo] valueForKey:@"HSNodeChildrenForAddition"]) {
        for (id child in [card hyperChildren]) {
            if ([child implementsHyperInterface:@protocol(HSSystemTextViewAttributes)]) {
                [self HSReadWriteTextActionAssistantPane_validateTextObjectsPopUpButton];
                [[self navigationPaneSwitcher] validateUserInterface];
                return;
            }
        }
    }
    NSArray *removed = [[aChange userInfo] valueForKey:@"HSNodeChildrenForRemoval"];
    if ([removed containsObject:[[[self assistant] object] queryHyperInterface:@protocol(HSNodeChild)]]) {
        [self HSReadWriteTextActionAssistantPane_removeObservers];
    }
    for (id card in removed) {
        for (id child in [card hyperChildren]) {
            if ([child implementsHyperInterface:@protocol(HSSystemTextViewAttributes)]) {
                [self HSReadWriteTextActionAssistantPane_removeItemAtPopUpByNodeChild:child withErrorText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Text object is missing" value:@"" table:@"AssistantPanes"]];
            }
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029f56e @ 0029f56e, 793 bytes * /

void FUN_0029f56e(HSReadWriteTextActionAssistantPane *self,SEL _cmd,
                 id HSReadWriteTextActionAssistantPane_removeItemAtPopUpByNodeChild,id withErrorText
                 )

{
  HSPopUpButton *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id local_18;
  
  pvVar3 = HSReadWriteTextActionAssistantPane_removeItemAtPopUpByNodeChild;
  pvVar1 = _objc_msgSend(self->_textObjectsMenu,sel_indexOfItemWithRepresentedObject_,
                         HSReadWriteTextActionAssistantPane_removeItemAtPopUpByNodeChild);
  if ((int)pvVar1 < 0) {
    return;
  }
  pvVar2 = _objc_msgSend(self->_textObjectsMenu,sel_numberOfItems,pvVar3);
  if (1 < (int)pvVar2) {
    pvVar3 = _objc_msgSend(self->_textObjectsMenu,sel_numberOfItems,pvVar3);
    if (pvVar1 == (id)((int)pvVar3 + -1)) {
      local_18 = (id)((int)pvVar1 + -1);
      pvVar3 = local_18;
      pvVar2 = _objc_msgSend(self->_textObjectsMenu,sel_itemAtIndex_,local_18);
      pvVar2 = _objc_msgSend(pvVar2,sel_isSeparatorItem);
      if ((char)pvVar2 != '\0') goto LAB_0029f708;
    }
    if (pvVar1 == (id)0x0) {
      pvVar3 = (id)0x1;
      pvVar2 = _objc_msgSend(self->_textObjectsMenu,sel_itemAtIndex_,1);
      pvVar2 = _objc_msgSend(pvVar2,sel_isSeparatorItem);
      if ((char)pvVar2 != '\0') {
        local_18 = (id)0x0;
        goto LAB_0029f708;
      }
    }
    pvVar3 = (id)((int)pvVar1 + 1);
    pvVar2 = _objc_msgSend(self->_textObjectsMenu,sel_itemAtIndex_,pvVar3);
    pvVar2 = _objc_msgSend(pvVar2,sel_isSeparatorItem);
    if ((char)pvVar2 != '\0') {
      pvVar3 = (id)((int)pvVar1 + -1);
      pvVar2 = _objc_msgSend(self->_textObjectsMenu,sel_itemAtIndex_,pvVar3);
      pvVar2 = _objc_msgSend(pvVar2,sel_isSeparatorItem);
      local_18 = pvVar1;
      if ((char)pvVar2 != '\0') goto LAB_0029f708;
    }
  }
  local_18 = (id)0xffffffff;
LAB_0029f708:
  pvVar3 = _objc_msgSend(self->_textObjectsPopUpButton,sel_selectedItem,pvVar3);
  pvVar3 = _objc_msgSend(pvVar3,sel_representedObject);
  if (pvVar3 == HSReadWriteTextActionAssistantPane_removeItemAtPopUpByNodeChild) {
    _objc_msgSend(self->_textObjectsPopUpButton,sel_addItemWithTitle_,withErrorText);
    self_00 = self->_textObjectsPopUpButton;
    pvVar3 = _objc_msgSend(self_00,sel_lastItem);
    _objc_msgSend(self_00,sel_selectItem_,pvVar3);
    pvVar3 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    _objc_msgSend(pvVar3,sel_addObserver_selector_name_object_,self,sel_popUpButtonWillPopUp_,
                  *(undefined4 *)PTR_00336974,self->_textObjectsPopUpButton);
    self->_textObjectIsMissing = '\x01';
  }
  _objc_msgSend(self->_textObjectsMenu,sel_removeItemAtIndex_,pvVar1);
  if (local_18 != (id)0xffffffff) {
    _objc_msgSend(self->_textObjectsMenu,sel_removeItemAtIndex_,local_18);
    pvVar1 = local_18;
  }
  if ((self->_textObjectIsMissing != '\0') &&
     (pvVar3 = _objc_msgSend(self->_textObjectsMenu,sel_numberOfItems,pvVar1), pvVar3 == (id)0x1)) {
    _objc_msgSend(self,sel_HSReadWriteTextActionAssistantPane_setControlsEnabled_,0);
  }
  return;
}

*/
- (void)HSReadWriteTextActionAssistantPane_removeItemAtPopUpByNodeChild:(id)aChild withErrorText:(id)aText
{
    NSInteger index = [_textObjectsMenu indexOfItemWithRepresentedObject:aChild];
    if (index < 0) {
        return;
    }
    /* Also drop the card separator when the item was the card's only one. */
    NSInteger separatorIndex = -1;
    if ([_textObjectsMenu numberOfItems] > 1) {
        if (index == [_textObjectsMenu numberOfItems] - 1 && [[_textObjectsMenu itemAtIndex:index - 1] isSeparatorItem]) {
            separatorIndex = index - 1;
        } else if (index == 0 && [[_textObjectsMenu itemAtIndex:1] isSeparatorItem]) {
            separatorIndex = 0;
        } else if (index + 1 < [_textObjectsMenu numberOfItems] && index > 0 && [[_textObjectsMenu itemAtIndex:index + 1] isSeparatorItem] && [[_textObjectsMenu itemAtIndex:index - 1] isSeparatorItem]) {
            separatorIndex = index;
        }
    }
    if ([[_textObjectsPopUpButton selectedItem] representedObject] == aChild) {
        [_textObjectsPopUpButton addItemWithTitle:aText];
        [_textObjectsPopUpButton selectItem:[_textObjectsPopUpButton lastItem]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popUpButtonWillPopUp:) name:NSPopUpButtonWillPopUpNotification object:_textObjectsPopUpButton];
        _textObjectIsMissing = YES;
    }
    [_textObjectsMenu removeItemAtIndex:index];
    if (separatorIndex != -1) {
        [_textObjectsMenu removeItemAtIndex:separatorIndex];
    }
    if (_textObjectIsMissing && [_textObjectsMenu numberOfItems] == 1) {
        [self HSReadWriteTextActionAssistantPane_setControlsEnabled:NO];
    }
}

- (void)HSReadWriteTextActionAssistantPane_autosetupTextObjectSettings
{
    if ([_attributes targetObjectUID] == nil) {
        [self textObjectChanged:nil];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a1578 @ 002a1578, 1152 bytes * /

void FUN_002a1578(HSReadWriteTextActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  cfstringStruct *pcVar2;
  id pvVar3;
  id pvVar4;
  undefined *puVar5;
  SEL pcVar6;
  char local_11;
  
  pvVar1 = _objc_msgSend(self->_attributes,sel_fileURL);
  if (pvVar1 != (id)0x0) {
    return;
  }
  pcVar2 = _objc_msgSend(self->_attributes,sel_targetObjectUID);
  if (pcVar2 == (cfstringStruct *)0x0) {
LAB_002a1602:
    puVar5 = cls_NSBundle;
    pvVar1 = _objc_msgSend(cls_HSSystemTextView,sel_class);
    pvVar1 = _objc_msgSend(puVar5,sel_bundleForClass_,pvVar1);
    pcVar2 = &cfstr_TextField;
    pcVar6 = sel_localizedStringForKey_value_table_;
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_stack);
    pvVar1 = _objc_msgSend(pvVar1,sel_childInTreeWithUID_,pcVar2);
    pcVar6 = sel_hyperName;
    if (pvVar1 == (id)0x0) goto LAB_002a1602;
  }
  pvVar1 = _objc_msgSend(pvVar1,pcVar6,pcVar2);
  if (pvVar1 == (id)0x0) {
    return;
  }
  pvVar3 = _objc_msgSend(self,sel_documentDirectoryURL,pcVar2);
  pvVar3 = _objc_msgSend(pvVar3,sel_path);
  pvVar3 = _objc_msgSend(pvVar3,sel_stringByResolvingSymlinksInPath);
  if (pvVar3 != (id)0x0) {
    pvVar4 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    pvVar4 = _objc_msgSend(pvVar4,sel_bundlePath);
    pcVar2 = _objc_msgSend(pvVar4,sel_stringByResolvingSymlinksInPath);
    if (pcVar2 == (cfstringStruct *)0x0) {
      return;
    }
    pvVar4 = _objc_msgSend(pvVar3,sel_hasPrefix_,pcVar2);
    if ((char)pvVar4 != '\0') {
      pvVar3 = (id)0x0;
    }
  }
  local_11 = '\0';
  pvVar4 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults,pcVar2);
  if (pvVar3 == (id)0x0) {
    pvVar3 = _objc_msgSend(pvVar4,sel_stringForKey_,
                           &cfstr_HSReadWriteTextActionLastChosenAbsoluteLocation);
    if (pvVar3 == (id)0x0) {
      pvVar3 = (id)_NSSearchPathForDirectoriesInDomains(9,1,1);
      pvVar4 = _objc_msgSend(pvVar3,sel_count);
      if (pvVar4 == (id)0x0) {
        pcVar2 = &cfstr_empty;
      }
      else {
        pcVar2 = _objc_msgSend(pvVar3,sel_objectAtIndex_,0);
      }
      pcVar2 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr_______rtf,pcVar2,pvVar1);
      puVar5 = cls_NSURL;
      pcVar6 = sel_fileURLWithPath_;
      if (pcVar2 == (cfstringStruct *)0x0) {
        return;
      }
    }
    else {
      pvVar3 = _objc_msgSend(cls_NSURL,sel_URLWithString_,pvVar3);
      puVar5 = _objc_msgSend(pvVar3,sel_URLByAppendingPathComponent_,pvVar1);
LAB_002a190b:
      pcVar2 = &cfstr_rtf;
      pcVar6 = sel_URLByAppendingPathExtension_;
    }
    pvVar1 = _objc_msgSend(puVar5,pcVar6,pcVar2);
    if (pvVar1 == (id)0x0) {
      return;
    }
  }
  else {
    pvVar3 = _objc_msgSend(pvVar4,sel_stringForKey_,
                           &cfstr_HSReadWriteTextActionLastChosenRelativeLocation);
    if (pvVar3 == (id)0x0) {
      pvVar3 = _objc_msgSend(pvVar4,sel_stringForKey_,
                             &cfstr_HSReadWriteTextActionLastChosenAbsoluteLocation);
      if (pvVar3 != (id)0x0) {
        pvVar3 = _objc_msgSend(cls_NSURL,sel_URLWithString_,pvVar3);
        if (pvVar3 == (id)0x0) {
          return;
        }
        pvVar3 = _objc_msgSend(self,
                               sel_HSReadWriteTextActionAssistantPane_actionURLForUserURL_excludeApplicationBundle_relativeToStack_
                               ,pvVar3,0,&local_11);
        puVar5 = _objc_msgSend(pvVar3,sel_URLByAppendingPathComponent_,pvVar1);
        goto LAB_002a190b;
      }
      pvVar1 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr_file_______rtf,pvVar1);
      pcVar2 = _objc_msgSend(pvVar1,sel_stringByAddingPercentEscapesUsingEncoding_,4);
      puVar5 = cls_NSURL;
      pcVar6 = sel_URLWithString_;
      if (pcVar2 == (cfstringStruct *)0x0) {
        return;
      }
    }
    else {
      pvVar3 = _objc_msgSend(cls_NSURL,sel_URLWithString_,pvVar3);
      puVar5 = _objc_msgSend(pvVar3,sel_URLByAppendingPathComponent_,pvVar1);
      pcVar2 = &cfstr_rtf;
      pcVar6 = sel_URLByAppendingPathExtension_;
    }
    pvVar1 = _objc_msgSend(puVar5,pcVar6,pcVar2);
    if (pvVar1 == (id)0x0) {
      return;
    }
    local_11 = '\x01';
  }
  pvVar3 = _objc_msgSend(self,sel_readWriteTextActionAssistantPaneApplier,pcVar2);
  _objc_msgSend(pvVar3,sel_setFileURL_relativeToStack_,pvVar1,(int)local_11);
  return;
}

*/
- (void)HSReadWriteTextActionAssistantPane_autosetupFileURLSettings
{
    if ([_attributes fileURL] != nil) {
        return;
    }
    /* The file is named after the target text object. */
    NSString *name = nil;
    id targetObjectUID = [_attributes targetObjectUID];
    id target = targetObjectUID != nil ? [[self stack] childInTreeWithUID:targetObjectUID] : nil;
    if (target != nil) {
        name = [target hyperName];
    } else {
        name = [[NSBundle bundleForClass:[HSSystemTextView class]] localizedStringForKey:@"TextField" value:@"" table:@"UserClassesLocalizable"];
    }
    if (name == nil) {
        return;
    }
    NSString *stackPath = [[[[self documentDirectoryURL] path] stringByResolvingSymlinksInPath] retain];
    if (stackPath != nil) {
        NSString *bundlePath = [[[NSBundle mainBundle] bundlePath] stringByResolvingSymlinksInPath];
        if (bundlePath == nil) {
            [stackPath release];
            return;
        }
        if ([stackPath hasPrefix:bundlePath]) {
            [stackPath release];
            stackPath = nil;
        }
    }
    [stackPath autorelease];
    BOOL relativeToStack = NO;
    NSURL *fileURL;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (stackPath == nil) {
        NSString *location = [defaults stringForKey:@"HSReadWriteTextActionLastChosenAbsoluteLocation"];
        if (location == nil) {
            NSArray *directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *path = [NSString stringWithFormat:@"%@/%@.rtf", [directories count] != 0 ? [directories objectAtIndex:0] : @"", name];
            if (path == nil) {
                return;
            }
            fileURL = [NSURL fileURLWithPath:path];
        } else {
            fileURL = [[[NSURL URLWithString:location] URLByAppendingPathComponent:name] URLByAppendingPathExtension:@"rtf"];
        }
        if (fileURL == nil) {
            return;
        }
    } else {
        NSString *location = [defaults stringForKey:@"HSReadWriteTextActionLastChosenRelativeLocation"];
        if (location != nil) {
            fileURL = [[[NSURL URLWithString:location] URLByAppendingPathComponent:name] URLByAppendingPathExtension:@"rtf"];
            if (fileURL == nil) {
                return;
            }
            relativeToStack = YES;
        } else {
            location = [defaults stringForKey:@"HSReadWriteTextActionLastChosenAbsoluteLocation"];
            if (location != nil) {
                NSURL *locationURL = [NSURL URLWithString:location];
                if (locationURL == nil) {
                    return;
                }
                /* relativeToStack stays as the conversion leaves it. */
                fileURL = [[[self HSReadWriteTextActionAssistantPane_actionURLForUserURL:locationURL excludeApplicationBundle:NO relativeToStack:&relativeToStack] URLByAppendingPathComponent:name] URLByAppendingPathExtension:@"rtf"];
                if (fileURL == nil) {
                    return;
                }
            } else {
                NSString *string = [[NSString stringWithFormat:@"file:///%@.rtf", name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                if (string == nil) {
                    return;
                }
                fileURL = [NSURL URLWithString:string];
                if (fileURL == nil) {
                    return;
                }
                relativeToStack = YES;
            }
        }
    }
    [[self readWriteTextActionAssistantPaneApplier] setFileURL:fileURL relativeToStack:relativeToStack];
}

- (void)animationDidStop:(id)aStop
{
    [aStop release];
    [_changeModeButton setEnabled:YES];
}

- (void)animationDidEnd:(id)aEnd
{
    [aEnd release];
    [_changeModeButton setEnabled:YES];
}

- (void)operationChanged:(id)aChanged
{
    id self_00;

    self_00 = [self readWriteTextActionAssistantPaneApplier];
    [self_00 setOperation:(unsigned int)([[self_00 readWriteTextActionAttributes] operation] == 0)];
    [self HSReadWriteTextActionAssistantPane_swapButtonsWithAnimation];
    [self HSReadWriteTextActionAssistantPane_validateTextObjectsPopUpButton];
    [self HSReadWriteTextActionAssistantPane_validateFilePopUpButton];
    [self HSReadWriteTextActionAssistantPane_validateWarningMessageTextField];
}

- (void)modeChanged:(id)aChanged
{
    [[self readWriteTextActionAssistantPaneApplier] setMode:[_operationMatrix selectedRow]];
    if ([_attributes operation] == 0x1) {
        [self HSReadWriteTextActionAssistantPane_validateWarningMessageTextField];
    }
}

- (void)textObjectChanged:(id)aChanged
{
    id pvVar1_3;

    pvVar1_3 = [[[_textObjectsPopUpButton selectedItem] representedObject] hyperUID];
    if (pvVar1_3 != nil) {
        [[self readWriteTextActionAssistantPaneApplier] setTargetObjectUID:pvVar1_3];
    }
    [[self navigationPaneSwitcher] validateUserInterface];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a19f8 @ 002a19f8, 944 bytes * /

void FUN_002a19f8(HSReadWriteTextActionAssistantPane *self,SEL _cmd)

{
  undefined4 uVar1;
  undefined4 uVar2;
  HSPopUpButton *self_00;
  undefined *puVar3;
  undefined *puVar4;
  undefined *puVar5;
  undefined *puVar6;
  undefined *self_01;
  id pvVar7;
  id pvVar8;
  id pvVar9;
  undefined1 local_54 [16];
  undefined1 local_44 [16];
  undefined1 local_34 [16];
  undefined1 local_24 [20];
  
  puVar4 = cls_NSValue;
  puVar6 = cls_NSDictionary;
  puVar3 = PTR_00336548;
  uVar1 = *(undefined4 *)PTR_00336548;
  _objc_msgSend_stret(local_54,self->_chooseFilePopUpButton,sel_frame);
  pvVar7 = _objc_msgSend(puVar4,sel_valueWithRect_,(int)local_54._0_8_,SUB84(local_54._0_8_,4),
                         (int)local_54._8_8_,SUB84(local_54._8_8_,4));
  puVar5 = cls_NSValue;
  puVar4 = PTR_00336550;
  uVar2 = *(undefined4 *)PTR_00336550;
  _objc_msgSend_stret(local_44,self->_textObjectsPopUpButton,sel_frame);
  pvVar8 = _objc_msgSend(puVar5,sel_valueWithRect_,(int)local_44._0_8_,SUB84(local_44._0_8_,4),
                         (int)local_44._8_8_,SUB84(local_44._8_8_,4));
  puVar5 = PTR_00336554;
  pvVar7 = _objc_msgSend(puVar6,sel_dictionaryWithObjectsAndKeys_,self->_textObjectsPopUpButton,
                         *(undefined4 *)PTR_00336554,pvVar8,uVar2,pvVar7,uVar1,0);
  self_01 = cls_NSValue;
  puVar6 = cls_NSDictionary;
  uVar1 = *(undefined4 *)puVar3;
  _objc_msgSend_stret(local_34,self->_textObjectsPopUpButton,sel_frame);
  pvVar8 = _objc_msgSend(self_01,sel_valueWithRect_,(int)local_34._0_8_,SUB84(local_34._0_8_,4),
                         (int)local_34._8_8_,SUB84(local_34._8_8_,4));
  puVar3 = cls_NSValue;
  uVar2 = *(undefined4 *)puVar4;
  _objc_msgSend_stret(local_24,self->_chooseFilePopUpButton,sel_frame);
  pvVar9 = _objc_msgSend(puVar3,sel_valueWithRect_,(int)local_24._0_8_,SUB84(local_24._0_8_,4),
                         (int)local_24._8_8_,SUB84(local_24._8_8_,4));
  pvVar8 = _objc_msgSend(puVar6,sel_dictionaryWithObjectsAndKeys_,self->_chooseFilePopUpButton,
                         *(undefined4 *)puVar5,pvVar9,uVar2,pvVar8,uVar1,0);
  pvVar9 = _objc_msgSend(cls_NSViewAnimation,sel_alloc);
  pvVar7 = _objc_msgSend(cls_NSArray,sel_arrayWithObjects_,pvVar7,pvVar8,0);
  pvVar7 = _objc_msgSend(pvVar9,sel_initWithViewAnimations_,pvVar7);
  _objc_msgSend(pvVar7,sel_setDuration_,0x9999999a,0x3fc99999);
  _objc_msgSend(pvVar7,sel_setAnimationCurve_,1);
  _objc_msgSend(pvVar7,sel_setDelegate_,self);
  _objc_msgSend(pvVar7,sel_startAnimation);
  _objc_msgSend(self->_changeModeButton,sel_setEnabled_,0);
  pvVar7 = _objc_msgSend(self->_chooseFilePopUpButton,sel_toolTip);
  self_00 = self->_chooseFilePopUpButton;
  pvVar8 = _objc_msgSend(self->_textObjectsPopUpButton,sel_toolTip);
  _objc_msgSend(self_00,sel_setToolTip_,pvVar8);
  _objc_msgSend(self->_textObjectsPopUpButton,sel_setToolTip_,pvVar7);
  return;
}

*/
- (void)HSReadWriteTextActionAssistantPane_swapButtonsWithAnimation
{
    NSDictionary *textObjectsAnimation = [NSDictionary dictionaryWithObjectsAndKeys:
        _textObjectsPopUpButton, NSViewAnimationTargetKey,
        [NSValue valueWithRect:[_textObjectsPopUpButton frame]], NSViewAnimationStartFrameKey,
        [NSValue valueWithRect:[_chooseFilePopUpButton frame]], NSViewAnimationEndFrameKey, nil];
    NSDictionary *fileAnimation = [NSDictionary dictionaryWithObjectsAndKeys:
        _chooseFilePopUpButton, NSViewAnimationTargetKey,
        [NSValue valueWithRect:[_chooseFilePopUpButton frame]], NSViewAnimationStartFrameKey,
        [NSValue valueWithRect:[_textObjectsPopUpButton frame]], NSViewAnimationEndFrameKey, nil];
    /* Released in animationDidEnd:. */
    NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObjects:textObjectsAnimation, fileAnimation, nil]];
    [animation setDuration:0.2];
    [animation setAnimationCurve:NSAnimationEaseIn];
    [animation setDelegate:self];
    [animation startAnimation];
    [_changeModeButton setEnabled:NO];
    NSString *fileToolTip = [_chooseFilePopUpButton toolTip];
    [_chooseFilePopUpButton setToolTip:[_textObjectsPopUpButton toolTip]];
    [_textObjectsPopUpButton setToolTip:fileToolTip];
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    if (_textObjectIsMissing != NO) {
        [self HSReadWriteTextActionAssistantPane_removeObserverFromPopUpButton];
    }
    [self HSReadWriteTextActionAssistantPane_removeObservers];
    [super viewWillDisappear:aDisappear];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a1e1a @ 002a1e1a, 606 bytes * /

void FUN_002a1e1a(HSReadWriteTextActionAssistantPane *self,SEL _cmd,BOOL viewWillAppear)

{
  id pvVar1;
  NSRect *pNVar2;
  id *ppvVar3;
  NSPoint NVar4;
  NSSize NVar5;
  HSReadWriteTextActionAssistantPane *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_HSNBAAssistantPane_00356a50;
  _objc_msgSendSuper(&local_14,sel_viewWillAppear_,(int)viewWillAppear);
  _objc_msgSend(self->_attributes,sel_release);
  pvVar1 = _objc_msgSend(self,sel_readWriteTextActionAssistantPaneApplier);
  pvVar1 = _objc_msgSend(pvVar1,sel_readWriteTextActionAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_attributes = pvVar1;
  pvVar1 = _objc_msgSend(pvVar1,sel_operation);
  if (pvVar1 == (id)0x0) {
    pNVar2 = &self->_frameForRead;
  }
  else {
    pNVar2 = &self->_frameForWrite;
  }
  NVar4 = pNVar2->origin;
  NVar5 = pNVar2->size;
  _objc_msgSend(self->_textObjectsPopUpButton,sel_setFrame_,NVar4,NVar5);
  if (pvVar1 == (id)0x0) {
    ppvVar3 = &self->_tooltipForRead;
  }
  else {
    ppvVar3 = &self->_tooltipForWrite;
  }
  _objc_msgSend(self->_textObjectsPopUpButton,sel_setToolTip_,*ppvVar3,NVar4.y,NVar5);
  if (pvVar1 == (id)0x0) {
    pNVar2 = &self->_frameForWrite;
  }
  else {
    pNVar2 = &self->_frameForRead;
  }
  NVar4 = pNVar2->origin;
  NVar5 = pNVar2->size;
  _objc_msgSend(self->_chooseFilePopUpButton,sel_setFrame_,NVar4,NVar5);
  if (pvVar1 == (id)0x0) {
    ppvVar3 = &self->_tooltipForWrite;
  }
  else {
    ppvVar3 = &self->_tooltipForRead;
  }
  _objc_msgSend(self->_chooseFilePopUpButton,sel_setToolTip_,*ppvVar3,NVar4.y,NVar5);
  _objc_msgSend(self,sel_HSReadWriteTextActionAssistantPane_validateTextObjectsPopUpButton);
  _objc_msgSend(self,sel_HSReadWriteTextActionAssistantPane_validateFilePopUpButton);
  _objc_msgSend(self,sel_HSReadWriteTextActionAssistantPane_validateOperationMatrix);
  _objc_msgSend(self,sel_HSReadWriteTextActionAssistantPane_validateWarningMessageTextField);
  pvVar1 = _objc_msgSend(self,sel_applier);
  pvVar1 = _objc_msgSend(pvVar1,sel_actor);
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_003894e8);
  _objc_msgSend(pvVar1,sel_updateActionValidationStatus);
  pvVar1 = _objc_msgSend(self,sel_navigationPaneSwitcher);
  _objc_msgSend(pvVar1,sel_validateUserInterface);
  _objc_msgSend(self,sel_HSReadWriteTextActionAssistantPane_addObservers);
  return;
}

*/
- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [(id)_attributes release];
    _attributes = [[[self readWriteTextActionAssistantPaneApplier] readWriteTextActionAttributes] retain];
    BOOL isRead = [_attributes operation] == 0;
    [_textObjectsPopUpButton setFrame:isRead ? _frameForRead : _frameForWrite];
    [_textObjectsPopUpButton setToolTip:isRead ? _tooltipForRead : _tooltipForWrite];
    [_chooseFilePopUpButton setFrame:isRead ? _frameForWrite : _frameForRead];
    [_chooseFilePopUpButton setToolTip:isRead ? _tooltipForWrite : _tooltipForRead];
    [self HSReadWriteTextActionAssistantPane_validateTextObjectsPopUpButton];
    [self HSReadWriteTextActionAssistantPane_validateFilePopUpButton];
    [self HSReadWriteTextActionAssistantPane_validateOperationMatrix];
    [self HSReadWriteTextActionAssistantPane_validateWarningMessageTextField];
    [[[[self applier] actor] queryHyperInterface:@protocol(HSActionValidation)] updateActionValidationStatus];
    [[self navigationPaneSwitcher] validateUserInterface];
    [self HSReadWriteTextActionAssistantPane_addObservers];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029f195 @ 0029f195, 266 bytes * /

id FUN_0029f195(HSReadWriteTextActionAssistantPane *self,SEL _cmd,id panel,id userEnteredFilename,
               BOOL confirmed)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  char local_d;
  
  if (confirmed != '\0') {
    pvVar1 = _objc_msgSend(panel,sel_URL);
    local_d = '\0';
    if (pvVar1 == (id)0x0) {
      pvVar2 = (id)0x0;
    }
    else {
      pvVar2 = _objc_msgSend(self,
                             sel_HSReadWriteTextActionAssistantPane_actionURLForUserURL_excludeApplicationBundle_relativeToStack_
                             ,pvVar1,1,&local_d);
    }
    self_00 = _objc_msgSend(self,sel_readWriteTextActionAssistantPaneApplier);
    _objc_msgSend(self_00,sel_setFileURL_relativeToStack_,pvVar2,(int)local_d);
    _objc_msgSend(self,sel_HSReadWriteTextActionAssistantPane_validateFilePopUpButton);
    _objc_msgSend(self,sel_HSReadWriteTextActionAssistantPane_validateWarningMessageTextField);
    _objc_msgSend(self,
                  sel_HSReadWriteTextActionAssistantPane_updateUserDefaultsWithUserURL_actionURL_,
                  pvVar1,pvVar2);
    userEnteredFilename = _objc_msgSend(cls_NSString,sel_hyperUIDString);
  }
  return userEnteredFilename;
}

*/
- (id)panel:(id)aPanel userEnteredFilename:(id)aFilename confirmed:(BOOL)aConfirmed
{
    if (!aConfirmed) {
        return aFilename;
    }
    NSURL *userURL = [aPanel URL];
    BOOL relativeToStack = NO;
    NSURL *actionURL = nil;
    if (userURL != nil) {
        actionURL = [self HSReadWriteTextActionAssistantPane_actionURLForUserURL:userURL excludeApplicationBundle:YES relativeToStack:&relativeToStack];
    }
    [[self readWriteTextActionAssistantPaneApplier] setFileURL:actionURL relativeToStack:relativeToStack];
    [self HSReadWriteTextActionAssistantPane_validateFilePopUpButton];
    [self HSReadWriteTextActionAssistantPane_validateWarningMessageTextField];
    [self HSReadWriteTextActionAssistantPane_updateUserDefaultsWithUserURL:userURL actionURL:actionURL];
    /* The original hands back a fresh unique name, so the panel never writes the chosen file. */
    return [NSString hyperUIDString];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029ecc5 @ 0029ecc5, 1232 bytes * /

void FUN_0029ecc5(HSReadWriteTextActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  undefined *self_01;
  cfstringStruct *pcVar8;
  cfstringStruct *pcVar9;
  char cVar10;
  SEL op;
  cfstringStruct *pcVar11;
  
  pvVar1 = _objc_msgSend(self->_attributes,sel_absoluteFileURL);
  pvVar1 = _objc_msgSend(pvVar1,sel_path);
  if (pvVar1 == (id)0x0) {
    cVar10 = '\x01';
    goto LAB_0029f16b;
  }
  self_00 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
  pvVar4 = pvVar1;
  pvVar2 = _objc_msgSend(self_00,sel_fileExistsAtPath_,pvVar1);
  pvVar3 = _objc_msgSend(self->_attributes,sel_operation);
  pvVar7 = pvVar1;
  if (pvVar3 == (id)0x0) {
    if ((char)pvVar2 == '\0') {
      pvVar1 = self->_warningMessageTextField;
      pvVar4 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar4);
      pcVar9 = &cfstr_File_is_missing;
    }
    else {
      pvVar4 = _objc_msgSend(self_00,sel_isReadableFileAtPath_,pvVar1);
      if ((char)pvVar4 != '\0') goto LAB_0029f0c7;
      pvVar1 = self->_warningMessageTextField;
      pvVar4 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar7);
      pcVar9 = &cfstr_File_is_not_readable;
    }
LAB_0029edb0:
    pcVar8 = &cfstr_AssistantPanes;
    pcVar11 = &cfstr_empty;
    pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,pcVar9,&cfstr_empty,
                           &cfstr_AssistantPanes);
LAB_0029ef94:
    _objc_msgSend(pvVar1,sel_setStringValue_,pvVar4,pcVar11,pcVar8);
    pcVar8 = &cfstr_Warning_icon;
    cVar10 = '\0';
    self_01 = cls_NSImage;
    op = sel_imageNamed_;
  }
  else {
    pvVar4 = _objc_msgSend(pvVar1,sel_pathComponentsCount,pvVar4);
    for (pvVar3 = (id)0x1; pvVar3 < pvVar4; pvVar3 = (id)((int)pvVar3 + 1)) {
      pvVar5 = _objc_msgSend(pvVar1,sel_pathWithFirstComponents_,pvVar3);
      pvVar6 = _objc_msgSend(self_00,sel_fileExistsAtPath_,pvVar5);
      if ((char)pvVar6 == '\0') {
        pvVar1 = self->_warningMessageTextField;
        pvVar4 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar5);
        pcVar8 = &cfstr_AssistantPanes;
        pcVar11 = &cfstr_empty;
        pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,
                               &cfstr_Path_to_write_file_to_does_not_exist,&cfstr_empty,
                               &cfstr_AssistantPanes);
        goto LAB_0029ef94;
      }
    }
    if ((char)pvVar2 != '\0') {
      pvVar4 = _objc_msgSend(self_00,sel_isWritableFileAtPath_,pvVar1);
      if ((char)pvVar4 == '\0') {
        pvVar1 = self->_warningMessageTextField;
        pvVar4 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar7);
        pcVar9 = &cfstr_File_is_not_writable;
      }
      else {
        pvVar4 = _objc_msgSend(self->_attributes,sel_mode,pvVar7);
        if ((pvVar4 != (id)0x0) ||
           (pvVar7 = pvVar1, pvVar4 = _objc_msgSend(self_00,sel_isReadableFileAtPath_,pvVar1),
           (char)pvVar4 != '\0')) goto LAB_0029f0c7;
        pvVar1 = self->_warningMessageTextField;
        pvVar4 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar7);
        pcVar9 = &cfstr_File_to_write_in_append_mode_is_not_readable;
      }
      pcVar8 = &cfstr_AssistantPanes;
      pcVar11 = &cfstr_empty;
      pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,pcVar9,&cfstr_empty,
                             &cfstr_AssistantPanes);
      goto LAB_0029ef94;
    }
    pvVar7 = _objc_msgSend(pvVar1,sel_pathWithFirstComponents_,(int)pvVar4 + -1);
    pvVar4 = _objc_msgSend(self_00,sel_isWritableFileAtPath_,pvVar7);
    if ((char)pvVar4 == '\0') {
      pvVar1 = self->_warningMessageTextField;
      pvVar4 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar7);
      pcVar9 = &cfstr_Folder_to_write_file_to_is_not_writable;
      goto LAB_0029edb0;
    }
LAB_0029f0c7:
    self_01 = _objc_msgSend(cls_NSWorkspace,sel_sharedWorkspace,pvVar7);
    pcVar8 = _objc_msgSend(pvVar1,sel_pathExtension);
    cVar10 = '\x01';
    op = sel_iconForFileType_;
  }
  pvVar1 = _objc_msgSend(self_01,op,pcVar8);
  _objc_msgSend(pvVar1,sel_setSize_,0x41800000,0x41800000);
  pvVar4 = _objc_msgSend(self->_fileMenu,sel_itemAtIndex_,0);
  _objc_msgSend(pvVar4,sel_setImage_,pvVar1);
LAB_0029f16b:
  _objc_msgSend(self->_warningMessageTextField,sel_setHidden_,(int)cVar10);
  return;
}

*/
- (void)HSReadWriteTextActionAssistantPane_validateWarningMessageTextField
{
    NSString *path = [[_attributes absoluteFileURL] path];
    if (path == nil) {
        [_warningMessageTextField setHidden:YES];
        return;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL exists = [fileManager fileExistsAtPath:path];
    NSString *warning = nil;
    if ([_attributes operation] == 0) {
        if (!exists) {
            warning = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"File is missing" value:@"" table:@"AssistantPanes"];
        } else if (![fileManager isReadableFileAtPath:path]) {
            warning = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"File is not readable" value:@"" table:@"AssistantPanes"];
        }
    } else {
        NSInteger count = [path pathComponentsCount];
        for (NSInteger i = 1; i < count; i++) {
            if (![fileManager fileExistsAtPath:[path pathWithFirstComponents:i]]) {
                warning = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Path to write file to does not exist" value:@"" table:@"AssistantPanes"];
                break;
            }
        }
        if (warning == nil) {
            if (exists) {
                if (![fileManager isWritableFileAtPath:path]) {
                    warning = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"File is not writable" value:@"" table:@"AssistantPanes"];
                } else if ([_attributes mode] == 0 && ![fileManager isReadableFileAtPath:path]) {
                    warning = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"File to write in append mode is not readable" value:@"" table:@"AssistantPanes"];
                }
            } else if (![fileManager isWritableFileAtPath:[path pathWithFirstComponents:count - 1]]) {
                warning = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Folder to write file to is not writable" value:@"" table:@"AssistantPanes"];
            }
        }
    }
    NSImage *image;
    if (warning != nil) {
        [_warningMessageTextField setStringValue:warning];
        image = [NSImage imageNamed:@"Warning_icon"];
    } else {
        image = [[NSWorkspace sharedWorkspace] iconForFileType:[path pathExtension]];
    }
    [image setSize:NSMakeSize(16.0, 16.0)];
    [[_fileMenu itemAtIndex:0] setImage:image];
    [_warningMessageTextField setHidden:warning == nil];
}

- (void)HSReadWriteTextActionAssistantPane_validateOperationMatrix
{
    [_operationMatrix selectCellAtRow:[_attributes mode] column:0];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029e8b2 @ 0029e8b2, 959 bytes * /

void FUN_0029e8b2(HSReadWriteTextActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  uint uVar2;
  id pvVar3;
  id pvVar4;
  cfstringStruct *pcVar5;
  HSPopUpButton *pHVar6;
  SEL op;
  cfstringStruct *pcVar7;
  
  if (self->_textObjectIsMissing != '\0') {
    _objc_msgSend(self,sel_HSReadWriteTextActionAssistantPane_removeObserverFromPopUpButton);
  }
  _objc_msgSend(self->_textObjectsMenu,sel_release);
  self->_textObjectsMenu = (id)0x0;
  pvVar1 = _objc_msgSend(self,sel_textObjectsMenu);
  pvVar1 = _objc_msgSend(pvVar1,sel_numberOfItems);
  uVar2 = (uint)(0 < (int)pvVar1);
  _objc_msgSend(self,sel_HSReadWriteTextActionAssistantPane_setControlsEnabled_,uVar2);
  pvVar1 = _objc_msgSend(self->_attributes,sel_targetObjectUID);
  if (pvVar1 != (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_stack,uVar2);
    pvVar3 = _objc_msgSend(self->_attributes,sel_targetObjectUID);
    pvVar1 = _objc_msgSend(pvVar1,sel_childInTreeWithUID_,pvVar3);
    if (pvVar1 == (id)0x0) {
      pHVar6 = self->_textObjectsPopUpButton;
      pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar3);
      pcVar5 = &cfstr_AssistantPanes;
      pcVar7 = &cfstr_empty;
      pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                             &cfstr_Text_object_is_missing,&cfstr_empty,&cfstr_AssistantPanes);
    }
    else {
      pvVar4 = _objc_msgSend(pvVar1,sel_isEditable,pvVar3);
      if (((char)pvVar4 != '\0') ||
         (pvVar4 = _objc_msgSend(self->_attributes,sel_operation,pvVar3), pvVar4 == (id)0x1)) {
        pvVar3 = _objc_msgSend(self,sel_textObjectsMenu,pvVar3);
        pvVar1 = _objc_msgSend(pvVar3,sel_indexOfItemWithRepresentedObject_,pvVar1);
        if ((int)pvVar1 < 0) {
          return;
        }
        pHVar6 = self->_textObjectsPopUpButton;
        op = sel_selectItemAtIndex_;
        goto LAB_0029ec64;
      }
      pHVar6 = self->_textObjectsPopUpButton;
      pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar3);
      pcVar5 = &cfstr_AssistantPanes;
      pcVar7 = &cfstr_empty;
      pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                             &cfstr_Text_object_is_not_editable,&cfstr_empty,&cfstr_AssistantPanes);
    }
    _objc_msgSend(pHVar6,sel_addItemWithTitle_,pvVar1,pcVar7,pcVar5);
    pHVar6 = self->_textObjectsPopUpButton;
    pvVar1 = _objc_msgSend(pHVar6,sel_lastItem);
    _objc_msgSend(pHVar6,sel_selectItem_,pvVar1);
    pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    _objc_msgSend(pvVar1,sel_addObserver_selector_name_object_,self,sel_popUpButtonWillPopUp_,
                  *(undefined4 *)PTR_00336974,self->_textObjectsPopUpButton);
    self->_textObjectIsMissing = '\x01';
    return;
  }
  pvVar1 = _objc_msgSend(self->_textObjectsPopUpButton,sel_isEnabled,uVar2);
  pHVar6 = self->_textObjectsPopUpButton;
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,uVar2);
    pvVar3 = _objc_msgSend(self->_attributes,sel_operation);
    pcVar5 = &cfstr_No_text_objects;
    if (pvVar3 == (id)0x0) {
      pcVar5 = &cfstr_No_editable_text_objects;
    }
    pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,pcVar5,&cfstr_empty,
                           &cfstr_AssistantPanes);
    op = sel_addItemWithTitle_;
  }
  else {
    pvVar1 = (id)0x1;
    op = sel_selectItemAtIndex_;
  }
LAB_0029ec64:
  _objc_msgSend(pHVar6,op,pvVar1);
  return;
}

*/
- (void)HSReadWriteTextActionAssistantPane_validateTextObjectsPopUpButton
{
    if (_textObjectIsMissing) {
        [self HSReadWriteTextActionAssistantPane_removeObserverFromPopUpButton];
    }
    [_textObjectsMenu release];
    _textObjectsMenu = nil;
    [self HSReadWriteTextActionAssistantPane_setControlsEnabled:[[self textObjectsMenu] numberOfItems] > 0];
    if ([_attributes targetObjectUID] != nil) {
        id target = [[self stack] childInTreeWithUID:[_attributes targetObjectUID]];
        NSString *title;
        if (target == nil) {
            title = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Text object is missing" value:@"" table:@"AssistantPanes"];
        } else if ([target isEditable] || [_attributes operation] == 1) {
            NSInteger index = [[self textObjectsMenu] indexOfItemWithRepresentedObject:target];
            if (index >= 0) {
                [_textObjectsPopUpButton selectItemAtIndex:index];
            }
            return;
        } else {
            title = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Text object is not editable" value:@"" table:@"AssistantPanes"];
        }
        [_textObjectsPopUpButton addItemWithTitle:title];
        [_textObjectsPopUpButton selectItem:[_textObjectsPopUpButton lastItem]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popUpButtonWillPopUp:) name:NSPopUpButtonWillPopUpNotification object:_textObjectsPopUpButton];
        _textObjectIsMissing = YES;
        return;
    }
    if ([_textObjectsPopUpButton isEnabled]) {
        /* Index 0 is the first card's separator. */
        [_textObjectsPopUpButton selectItemAtIndex:1];
    } else if ([_attributes operation] == 0) {
        [_textObjectsPopUpButton addItemWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"No editable text objects" value:@"" table:@"AssistantPanes"]];
    } else {
        [_textObjectsPopUpButton addItemWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"No text objects" value:@"" table:@"AssistantPanes"]];
    }
}

- (void)HSReadWriteTextActionAssistantPane_setControlsEnabled:(BOOL)aEnabled
{
    [_textObjectsPopUpButton setMenu:_textObjectsMenu];
    if (aEnabled == NO) {
        [_textObjectsPopUpButton setEnabled:NO];
        [_operationMatrix setEnabled:NO];
        [_warningMessageTextField setHidden:YES];
        _noTextObjects = YES;
    }
    else {
        [_textObjectsPopUpButton setEnabled:YES];
        [_operationMatrix setEnabled:YES];
        if (_noTextObjects != NO) {
            [self HSReadWriteTextActionAssistantPane_validateFilePopUpButton];
        }
        _noTextObjects = NO;
    }
    [[self navigationPaneSwitcher] validateUserInterface];
}

- (void)HSReadWriteTextActionAssistantPane_validateFilePopUpButton
{
    [_fileMenu release];
    _fileMenu = nil;
    [self HSReadWriteTextActionAssistantPane_autosetupTextObjectSettings];
    [_chooseFilePopUpButton setMenu:[self fileMenu]];
}

- (id)fileMenu
{
    id pvVar1;

    pvVar1 = _fileMenu;
    if (pvVar1 == nil) {
        [self HSReadWriteTextActionAssistantPane_composeFileMenu];
        pvVar1 = _fileMenu;
    }
    return pvVar1;
}

- (id)textObjectsMenu
{
    id pvVar1;

    pvVar1 = _textObjectsMenu;
    if (pvVar1 == nil) {
        [self HSReadWriteTextActionAssistantPane_composeTextObjectsMenu];
        pvVar1 = _textObjectsMenu;
    }
    return pvVar1;
}

- (void)HSReadWriteTextActionAssistantPane_composeFileMenu
{
    id pvVar3;
    NSMenuItem *pvVar2_3;

    _fileMenu = [NSMenu new];
    [self HSReadWriteTextActionAssistantPane_autosetupFileURLSettings];
    pvVar3 = [_attributes filePath];
    pvVar2_3 = [_fileMenu addItemWithTitle:[pvVar3 lastPathComponent] action:@selector(HSReadWriteTextActionAssistantPane_openPathInFinder:) keyEquivalent:@""];
    [pvVar2_3 setRepresentedObject:[[_attributes absoluteFileURL] path]];
    [pvVar2_3 setTarget:self];
    [pvVar2_3 setToolTip:pvVar3];
    [_fileMenu addItem:[NSMenuItem separatorItem]];
    [[_fileMenu addItemWithTitle:[[NSBundle mainBundle] localizedStringForKey:@"Choose..." value:@"" table:@"AssistantPanes"] action:@selector(HSReadWriteTextActionAssistantPane_openDialogToChooseFile) keyEquivalent:@""] setTarget:self];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a2078 @ 002a2078, 953 bytes * /

void FUN_002a2078(HSReadWriteTextActionAssistantPane *self,SEL _cmd)

{
  int iVar1;
  int iVar2;
  bool bVar3;
  undefined *self_00;
  id pvVar4;
  undefined1 *puVar5;
  id self_01;
  id self_02;
  id pvVar6;
  id pvVar7;
  undefined4 *puVar8;
  undefined4 *self_03;
  cfstringStruct *pcVar9;
  undefined1 *puVar10;
  cfstringStruct *pcVar11;
  undefined1 *local_88;
  id local_84;
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
  self->_textObjectsMenu = pvVar4;
  _objc_msgSend(pvVar4,sel_setAutoenablesItems_,0);
  pvVar4 = _objc_msgSend(self,sel_stack);
  pvVar4 = _objc_msgSend(pvVar4,sel_hyperChildren);
  puVar5 = _objc_msgSend(pvVar4,sel_count);
  if (puVar5 != (undefined1 *)0x0) {
    local_88 = (undefined1 *)0x0;
    do {
      self_01 = _objc_msgSend(pvVar4,sel_objectAtIndex_,local_88);
      local_74 = 0;
      local_70 = 0;
      local_6c = (int *)0x0;
      local_68 = 0;
      local_64 = 0;
      local_60 = 0;
      local_5c = 0;
      local_58 = 0;
      self_02 = _objc_msgSend(self_01,sel_hyperChildren);
      puVar10 = local_50;
      puVar8 = &local_74;
      pcVar11 = (cfstringStruct *)0x10;
      local_88 = local_88 + 1;
      local_84 = _objc_msgSend(self_02,sel_countByEnumeratingWithState_objects_count_,puVar8,puVar10
                               ,0x10);
      if (local_84 != (id)0x0) {
        iVar2 = *local_6c;
        bVar3 = true;
        do {
          local_78 = (id)0x0;
          do {
            if (iVar2 != *local_6c) {
              pvVar6 = _objc_msgSend(self_01,sel_hyperChildren,puVar8,puVar10,pcVar11);
              _objc_enumerationMutation(pvVar6);
            }
            iVar1 = (int)local_78 * 4;
            puVar8 = (undefined4 *)&DAT_003891f0;
            local_78 = (id)((int)local_78 + 1);
            pvVar6 = _objc_msgSend(*(id *)(local_70 + iVar1),sel_queryHyperInterface_,&DAT_003891f0,
                                   puVar10,pcVar11);
            if (pvVar6 != (id)0x0) {
              pvVar7 = _objc_msgSend(pvVar6,sel_isEditable,puVar8);
              if ((char)pvVar7 == '\0') {
                pvVar7 = _objc_msgSend(self->_attributes,sel_operation,puVar8);
                if (pvVar7 != (id)0x1) goto LAB_002a23cf;
              }
              self_00 = cls_NSString;
              if (bVar3) {
                pvVar7 = _objc_msgSend(cls_NSBundle,sel_mainBundle,puVar8);
                pcVar11 = &cfstr_AssistantPanes;
                pvVar7 = _objc_msgSend(pvVar7,sel_localizedStringForKey_value_table_,
                                       &cfstr_Card_title,&cfstr_empty,&cfstr_AssistantPanes);
                puVar10 = local_88;
                puVar8 = _objc_msgSend(self_00,sel_stringWithFormat_,pvVar7,local_88);
                _objc_msgSend(self->_textObjectsMenu,sel_insertSeparatorWithTitle_,puVar8);
                bVar3 = false;
              }
              self_03 = _objc_msgSend(cls_NSMenuItem,sel_new,puVar8,puVar10,pcVar11);
              _objc_msgSend(self_03,sel_setRepresentedObject_,pvVar6);
              pvVar6 = _objc_msgSend(pvVar6,sel_queryHyperInterface_,&DAT_003893f8);
              pcVar9 = _objc_msgSend(pvVar6,sel_hyperName);
              if (pcVar9 == (cfstringStruct *)0x0) {
                pcVar9 = &cfstr_empty;
              }
              _objc_msgSend(self_03,sel_setTitle_,pcVar9);
              puVar8 = self_03;
              _objc_msgSend(self->_textObjectsMenu,sel_addItem_,self_03);
              _objc_msgSend(self_03,sel_release);
            }
LAB_002a23cf:
          } while (local_78 < local_84);
          puVar10 = local_50;
          puVar8 = &local_74;
          pcVar11 = (cfstringStruct *)0x10;
          local_84 = _objc_msgSend(self_02,sel_countByEnumeratingWithState_objects_count_,puVar8,
                                   puVar10,0x10);
        } while (local_84 != (id)0x0);
      }
    } while (local_88 < puVar5);
  }
  return;
}

*/
- (void)HSReadWriteTextActionAssistantPane_composeTextObjectsMenu
{
    _textObjectsMenu = [NSMenu new];
    [_textObjectsMenu setAutoenablesItems:NO];
    NSArray *cards = [[self stack] hyperChildren];
    NSUInteger count = [cards count];
    for (NSUInteger cardIndex = 0; cardIndex < count; cardIndex++) {
        id card = [cards objectAtIndex:cardIndex];
        BOOL isFirst = YES;
        for (id child in [card hyperChildren]) {
            id textObject = [child queryHyperInterface:@protocol(HSSystemTextViewAttributes)];
            if (textObject == nil) {
                continue;
            }
            /* Reading into a text object needs it to be editable. */
            if (![textObject isEditable] && [_attributes operation] != 1) {
                continue;
            }
            if (isFirst) {
                [_textObjectsMenu insertSeparatorWithTitle:[NSString stringWithFormat:[[NSBundle mainBundle] localizedStringForKey:@"Card title" value:@"" table:@"AssistantPanes"], cardIndex + 1]];
                isFirst = NO;
            }
            NSMenuItem *item = [NSMenuItem new];
            [item setRepresentedObject:textObject];
            NSString *name = [[textObject queryHyperInterface:@protocol(HSObjectAttributes)] hyperName];
            [item setTitle:name != nil ? name : @""];
            [_textObjectsMenu addItem:item];
            [item release];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029e3ec @ 0029e3ec, 197 bytes * /

void FUN_0029e3ec(HSReadWriteTextActionAssistantPane *self,SEL _cmd,
                 id HSReadWriteTextActionAssistantPane_openPathInFinder)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  
  self_00 = _objc_msgSend(HSReadWriteTextActionAssistantPane_openPathInFinder,sel_representedObject)
  ;
  pvVar1 = _objc_msgSend(self_00,sel_length);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
    pvVar1 = self_00;
    pvVar2 = _objc_msgSend(pvVar2,sel_fileExistsAtPath_,self_00);
    if ((char)pvVar2 != '\0') {
      pvVar1 = _objc_msgSend(cls_NSWorkspace,sel_sharedWorkspace,pvVar1);
      _objc_msgSend(pvVar1,sel_openFile_,self_00);
    }
  }
  _objc_msgSend(self->_chooseFilePopUpButton,sel_selectItemAtIndex_,0);
  return;
}

*/
- (void)HSReadWriteTextActionAssistantPane_openPathInFinder:(id)aFinder
{
    NSString *path = [aFinder representedObject];
    if ([path length] != 0 && [[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSWorkspace sharedWorkspace] openFile:path];
    }
    [_chooseFilePopUpButton selectItemAtIndex:0];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029deda @ 0029deda, 1298 bytes * /

void FUN_0029deda(HSReadWriteTextActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  HSReadWriteTextActionAssistantPane *self_00;
  id pvVar3;
  id pvVar4;
  cfstringStruct *pcVar5;
  SEL op;
  cfstringStruct *pcVar6;
  undefined4 uVar7;
  char local_11;
  
  pvVar1 = _objc_msgSend(self->_attributes,sel_absoluteFileURL);
  pvVar1 = _objc_msgSend(pvVar1,sel_path);
  pvVar2 = _objc_msgSend(self->_attributes,sel_operation);
  if (pvVar2 == (id)0x1) {
    self_00 = _objc_msgSend(cls_NSSavePanel,sel_savePanel);
    _objc_msgSend(self_00,sel_setCanCreateDirectories_,1);
    _objc_msgSend(self_00,sel_setAllowsOtherFileTypes_,1);
    pvVar2 = _objc_msgSend(cls_NSArray,sel_arrayWithObjects_,&cfstr_rtf,&cfstr_txt,&cfstr_doc,
                           &cfstr_rtfd,0);
    _objc_msgSend(self_00,sel_setAllowedFileTypes_,pvVar2);
    pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_Save_Text_File_As,
                           &cfstr_empty,&cfstr_AssistantPanes);
    _objc_msgSend(self_00,sel_setTitle_,pvVar2);
    pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_Choose,&cfstr_empty,
                           &cfstr_AssistantPanes);
    _objc_msgSend(self_00,sel_setPrompt_,pvVar2);
    pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    pcVar5 = &cfstr_AssistantPanes;
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_File_Name_,
                           &cfstr_empty,&cfstr_AssistantPanes);
    _objc_msgSend(self_00,sel_setNameFieldLabel_,pvVar2);
    _objc_msgSend(self_00,sel_setDelegate_,self);
    pvVar3 = _objc_msgSend(pvVar1,sel_lastPathComponent);
    pvVar4 = _objc_msgSend(pvVar1,sel_stringByDeletingLastPathComponent);
    op = sel_runModalForDirectory_file_;
  }
  else {
    pvVar4 = _objc_msgSend(cls_NSOpenPanel,sel_openPanel);
    _objc_msgSend(pvVar4,sel_setAllowsOtherFileTypes_,1);
    pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_Choose,&cfstr_empty,
                           &cfstr_AssistantPanes);
    _objc_msgSend(pvVar4,sel_setPrompt_,pvVar2);
    pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_Choose_Text_File,
                           &cfstr_empty,&cfstr_AssistantPanes);
    _objc_msgSend(pvVar4,sel_setTitle_,pvVar2);
    pcVar6 = &cfstr_rtfd;
    uVar7 = 0;
    pcVar5 = _objc_msgSend(cls_NSArray,sel_arrayWithObjects_,&cfstr_rtf,&cfstr_txt,&cfstr_doc,
                           &cfstr_rtfd,0);
    pvVar2 = _objc_msgSend(pvVar1,sel_lastPathComponent);
    pvVar1 = _objc_msgSend(pvVar1,sel_stringByDeletingLastPathComponent);
    pvVar3 = _objc_msgSend(pvVar4,sel_runModalForDirectory_file_types_,pvVar1,pvVar2,pcVar5);
    if (pvVar3 != (id)0x1) goto LAB_0029e3c1;
    pvVar4 = _objc_msgSend(pvVar4,sel_URL,pvVar1,pvVar2,pcVar5,pcVar6,uVar7);
    local_11 = '\0';
    if (pvVar4 == (id)0x0) {
      pvVar3 = (id)0x0;
    }
    else {
      pcVar5 = (cfstringStruct *)&local_11;
      pvVar2 = (id)0x1;
      pvVar1 = pvVar4;
      pvVar3 = _objc_msgSend(self,
                             sel_HSReadWriteTextActionAssistantPane_actionURLForUserURL_excludeApplicationBundle_relativeToStack_
                             ,pvVar4,1,pcVar5);
    }
    pvVar1 = _objc_msgSend(self,sel_readWriteTextActionAssistantPaneApplier,pvVar1,pvVar2,pcVar5);
    _objc_msgSend(pvVar1,sel_setFileURL_relativeToStack_,pvVar3,(int)local_11);
    _objc_msgSend(self,sel_HSReadWriteTextActionAssistantPane_validateFilePopUpButton);
    _objc_msgSend(self,sel_HSReadWriteTextActionAssistantPane_validateWarningMessageTextField);
    self_00 = self;
    op = sel_HSReadWriteTextActionAssistantPane_updateUserDefaultsWithUserURL_actionURL_;
  }
  _objc_msgSend(self_00,op,pvVar4,pvVar3);
  pvVar2 = pvVar3;
LAB_0029e3c1:
  _objc_msgSend(self->_chooseFilePopUpButton,sel_selectItemAtIndex_,0,pvVar2,pcVar5);
  return;
}

*/
- (void)HSReadWriteTextActionAssistantPane_openDialogToChooseFile
{
    NSString *path = [[_attributes absoluteFileURL] path];
    NSArray *types = [NSArray arrayWithObjects:@"rtf", @"txt", @"doc", @"rtfd", nil];
    if ([_attributes operation] == 1) {
        /* The choice is taken in panel:userEnteredFilename:confirmed:. */
        NSSavePanel *panel = [NSSavePanel savePanel];
        [panel setCanCreateDirectories:YES];
        [panel setAllowsOtherFileTypes:YES];
        [panel setAllowedFileTypes:types];
        [panel setTitle:[[NSBundle mainBundle] localizedStringForKey:@"Save Text File As" value:@"" table:@"AssistantPanes"]];
        [panel setPrompt:[[NSBundle mainBundle] localizedStringForKey:@"Choose" value:@"" table:@"AssistantPanes"]];
        [panel setNameFieldLabel:[[NSBundle mainBundle] localizedStringForKey:@"File Name:" value:@"" table:@"AssistantPanes"]];
        [panel setDelegate:self];
        [panel runModalForDirectory:[path stringByDeletingLastPathComponent] file:[path lastPathComponent]];
    } else {
        NSOpenPanel *panel = [NSOpenPanel openPanel];
        [panel setAllowsOtherFileTypes:YES];
        [panel setPrompt:[[NSBundle mainBundle] localizedStringForKey:@"Choose" value:@"" table:@"AssistantPanes"]];
        [panel setTitle:[[NSBundle mainBundle] localizedStringForKey:@"Choose Text File" value:@"" table:@"AssistantPanes"]];
        if ([panel runModalForDirectory:[path stringByDeletingLastPathComponent] file:[path lastPathComponent] types:types] == NSModalResponseOK) {
            NSURL *userURL = [panel URL];
            BOOL relativeToStack = NO;
            NSURL *actionURL = nil;
            if (userURL != nil) {
                actionURL = [self HSReadWriteTextActionAssistantPane_actionURLForUserURL:userURL excludeApplicationBundle:YES relativeToStack:&relativeToStack];
            }
            [[self readWriteTextActionAssistantPaneApplier] setFileURL:actionURL relativeToStack:relativeToStack];
            [self HSReadWriteTextActionAssistantPane_validateFilePopUpButton];
            [self HSReadWriteTextActionAssistantPane_validateWarningMessageTextField];
            [self HSReadWriteTextActionAssistantPane_updateUserDefaultsWithUserURL:userURL actionURL:actionURL];
        }
    }
    [_chooseFilePopUpButton selectItemAtIndex:0];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029ddf7 @ 0029ddf7, 227 bytes * /

void FUN_0029ddf7(HSReadWriteTextActionAssistantPane *self,SEL _cmd,
                 id HSReadWriteTextActionAssistantPane_updateUserDefaultsWithUserURL,id actionURL)

{
  id pvVar1;
  id self_00;
  cfstringStruct *pcVar2;
  SEL op;
  cfstringStruct *pcVar3;
  
  pvVar1 = _objc_msgSend(HSReadWriteTextActionAssistantPane_updateUserDefaultsWithUserURL,
                         sel_URLByDeletingLastPathComponent);
  pvVar1 = _objc_msgSend(pvVar1,sel_absoluteString);
  if (pvVar1 != (id)0x0) {
    self_00 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
    pcVar3 = &cfstr_HSReadWriteTextActionLastChosenAbsoluteLocation;
    _objc_msgSend(self_00,sel_setObject_forKey_,pvVar1,
                  &cfstr_HSReadWriteTextActionLastChosenAbsoluteLocation);
    pvVar1 = _objc_msgSend(actionURL,sel_URLByDeletingLastPathComponent);
    pcVar2 = _objc_msgSend(pvVar1,sel_absoluteString);
    if (pcVar2 == (cfstringStruct *)0x0) {
      pcVar2 = &cfstr_HSReadWriteTextActionLastChosenRelativeLocation;
      op = sel_removeObjectForKey_;
    }
    else {
      pcVar3 = &cfstr_HSReadWriteTextActionLastChosenRelativeLocation;
      op = sel_setObject_forKey_;
    }
    _objc_msgSend(self_00,op,pcVar2,pcVar3);
  }
  return;
}

*/
- (void)HSReadWriteTextActionAssistantPane_updateUserDefaultsWithUserURL:(id)aURL actionURL:(id)aURL2
{
    NSString *location = [[aURL URLByDeletingLastPathComponent] absoluteString];
    if (location == nil) {
        return;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:location forKey:@"HSReadWriteTextActionLastChosenAbsoluteLocation"];
    NSString *relativeLocation = [[aURL2 URLByDeletingLastPathComponent] absoluteString];
    if (relativeLocation == nil) {
        [defaults removeObjectForKey:@"HSReadWriteTextActionLastChosenRelativeLocation"];
    } else {
        [defaults setObject:relativeLocation forKey:@"HSReadWriteTextActionLastChosenRelativeLocation"];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029dc43 @ 0029dc43, 436 bytes * /

id FUN_0029dc43(HSReadWriteTextActionAssistantPane *self,SEL _cmd,
               id HSReadWriteTextActionAssistantPane_actionURLForUserURL,
               BOOL excludeApplicationBundle,BOOL *relativeToStack)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id self_00;
  cfstringStruct *pcVar4;
  
  pvVar1 = _objc_msgSend(self,sel_documentDirectoryURL);
  pvVar1 = _objc_msgSend(pvVar1,sel_path);
  pvVar2 = _objc_msgSend(pvVar1,sel_length);
  if (pvVar2 == (id)0x0) {
LAB_0029dc91:
    *relativeToStack = '\0';
  }
  else {
    pvVar2 = _objc_msgSend(HSReadWriteTextActionAssistantPane_actionURLForUserURL,sel_path);
    if (pvVar2 != (id)0x0) {
      pvVar3 = _objc_msgSend(pvVar2,sel_stringByResolvingSymlinksInPath);
      pcVar4 = &cfstr__Volumes;
      pvVar3 = _objc_msgSend(pvVar3,sel_hasPrefix_,&cfstr__Volumes);
      if ((char)pvVar3 != '\0') goto LAB_0029dc91;
      if (excludeApplicationBundle != '\0') {
        pvVar3 = _objc_msgSend(cls_NSBundle,sel_mainBundle,pcVar4);
        pvVar3 = _objc_msgSend(pvVar3,sel_bundlePath);
        pvVar3 = _objc_msgSend(pvVar3,sel_stringByResolvingSymlinksInPath);
        if (pvVar3 == (id)0x0) goto LAB_0029dded;
        self_00 = _objc_msgSend(pvVar1,sel_stringByResolvingSymlinksInPath,pcVar4);
        pvVar3 = _objc_msgSend(self_00,sel_hasPrefix_,pvVar3);
        if ((char)pvVar3 != '\0') goto LAB_0029dc91;
      }
      pvVar1 = _objc_msgSend(pvVar2,sel_relativePathToPath_,pvVar1);
      if (((pvVar1 != (id)0x0) &&
          (pvVar1 = _objc_msgSend(pvVar1,sel_stringByAddingPercentEscapesUsingEncoding_,4),
          pvVar1 != (id)0x0)) &&
         (pvVar1 = _objc_msgSend(&cfstr_file____,sel_stringByAppendingString_,pvVar1),
         pvVar1 != (id)0x0)) {
        pvVar1 = _objc_msgSend(cls_NSURL,sel_URLWithString_,pvVar1);
        *relativeToStack = '\x01';
        return pvVar1;
      }
    }
LAB_0029dded:
    HSReadWriteTextActionAssistantPane_actionURLForUserURL = (id)0x0;
  }
  return HSReadWriteTextActionAssistantPane_actionURLForUserURL;
}

*/
- (id)HSReadWriteTextActionAssistantPane_actionURLForUserURL:(id)aURL excludeApplicationBundle:(BOOL)aBundle relativeToStack:(BOOL *)aStack
{
    NSString *stackPath = [[self documentDirectoryURL] path];
    if ([stackPath length] == 0) {
        *aStack = NO;
        return aURL;
    }
    NSString *path = [aURL path];
    if (path != nil) {
        /* Files on other volumes are kept absolute. */
        if ([[path stringByResolvingSymlinksInPath] hasPrefix:@"/Volumes"]) {
            *aStack = NO;
            return aURL;
        }
        if (aBundle) {
            NSString *bundlePath = [[[NSBundle mainBundle] bundlePath] stringByResolvingSymlinksInPath];
            if (bundlePath == nil) {
                return nil;
            }
            /* Stacks inside the application bundle keep absolute URLs too. */
            if ([[stackPath stringByResolvingSymlinksInPath] hasPrefix:bundlePath]) {
                *aStack = NO;
                return aURL;
            }
        }
        NSString *relativePath = [[path relativePathToPath:stackPath] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if (relativePath != nil) {
            NSString *string = [@"file:///" stringByAppendingString:relativePath];
            if (string != nil) {
                *aStack = YES;
                return [NSURL URLWithString:string];
            }
        }
    }
    return nil;
}

- (void)popUpButtonWillPopUp:(id)aUp
{
    [self HSReadWriteTextActionAssistantPane_removeObserverFromPopUpButton];
}

- (void)HSReadWriteTextActionAssistantPane_removeObserverFromPopUpButton
{
    [[_textObjectsPopUpButton menu] removeItem:[_textObjectsPopUpButton selectedItem]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSPopUpButtonWillPopUpNotification object:_textObjectsPopUpButton];
    _textObjectIsMissing = NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029daa1 @ 0029daa1, 207 bytes * /

BOOL FUN_0029daa1(HSReadWriteTextActionAssistantPane *self,SEL _cmd,
                 id shouldEnableOKButtonInNavigationPaneSwitcher)

{
  id pvVar1;
  id pvVar2;
  bool bVar3;
  
  pvVar1 = _objc_msgSend(self->_attributes,sel_targetObjectUID);
  if (pvVar1 == (id)0x0) {
LAB_0029db44:
    bVar3 = false;
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_stack);
    pvVar2 = _objc_msgSend(self->_attributes,sel_targetObjectUID);
    pvVar1 = _objc_msgSend(pvVar1,sel_childInTreeWithUID_,pvVar2);
    pvVar1 = _objc_msgSend(pvVar1,sel_isEditable);
    if ((char)pvVar1 == '\0') {
      pvVar1 = _objc_msgSend(self->_attributes,sel_operation,pvVar2);
      if (pvVar1 != (id)0x1) goto LAB_0029db44;
    }
    pvVar1 = _objc_msgSend(self->_attributes,sel_fileURL,pvVar2);
    bVar3 = pvVar1 != (id)0x0;
  }
  return bVar3;
}

*/
- (BOOL)shouldEnableOKButtonInNavigationPaneSwitcher:(id)aSwitcher
{
    if ([_attributes targetObjectUID] == nil) {
        return NO;
    }
    id target = [[self stack] childInTreeWithUID:[_attributes targetObjectUID]];
    if (![target isEditable] && [_attributes operation] != 1) {
        return NO;
    }
    return [_attributes fileURL] != nil;
}

- (id)documentDirectoryURL
{
    return [[[[self stack] document] fileURL] URLByDeletingLastPathComponent];
}

- (id)actionAttributes
{
    return [[self readWriteTextActionAssistantPaneApplier] readWriteTextActionAttributes];
}

- (id)actionType
{
    return [HSReadWriteTextAction actionType];
}

- (id)readWriteTextActionAssistantPaneApplier
{
    return [self applier];
}

- (Class)applierClass
{
    return [HSReadWriteTextActionAssistantPaneApplier class];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a2431 @ 002a2431, 325 bytes * /

void FUN_002a2431(HSReadWriteTextActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  float local_34;
  float local_30;
  float local_2c;
  float local_28;
  float local_24;
  float local_20;
  float local_1c;
  float local_18;
  HSReadWriteTextActionAssistantPane *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_HSNBAAssistantPane_00356a50;
  _objc_msgSendSuper(&local_14,sel_viewDidLoad);
  _objc_msgSend_stret(&local_24,self->_textObjectsPopUpButton,sel_frame);
  (self->_frameForRead).origin.x = local_24;
  (self->_frameForRead).origin.y = local_20;
  (self->_frameForRead).size.width = local_1c;
  (self->_frameForRead).size.height = local_18;
  _objc_msgSend_stret(&local_34,self->_chooseFilePopUpButton,sel_frame);
  (self->_frameForWrite).origin.x = local_34;
  (self->_frameForWrite).origin.y = local_30;
  (self->_frameForWrite).size.width = local_2c;
  (self->_frameForWrite).size.height = local_28;
  pvVar1 = _objc_msgSend(self->_textObjectsPopUpButton,sel_toolTip);
  pvVar1 = _objc_msgSend(pvVar1,sel_copy);
  self->_tooltipForRead = pvVar1;
  pvVar1 = _objc_msgSend(self->_chooseFilePopUpButton,sel_toolTip);
  pvVar1 = _objc_msgSend(pvVar1,sel_copy);
  self->_tooltipForWrite = pvVar1;
  return;
}

*/
- (void)viewDidLoad
{
    [super viewDidLoad];
    _frameForRead = [_textObjectsPopUpButton frame];
    _frameForWrite = [_chooseFilePopUpButton frame];
    _tooltipForRead = [[_textObjectsPopUpButton toolTip] copy];
    _tooltipForWrite = [[_chooseFilePopUpButton toolTip] copy];
}

- (void)dealloc
{
    [_fileMenu release];
    [_textObjectsMenu release];
    [_tooltipForRead release];
    [_tooltipForWrite release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (id)init
{
    return [self initWithNibName:@"ReadWriteTextAssistantPane"];
}

@end

@implementation HSReadWriteTextActionAssistantPaneApplier

/* i386 ivar offsets: _initialTargetObjectUID=0x30, _initialFileURL=0x34, _initialMode=0x38, _initialOperation=0x3c, _targetObjectUID=0x40, _fileURL=0x44, _mode=0x48, _operation=0x4c, _actionAttributes=0x50, _isFileURLRelativeToStackInitially=0x54, _isFileURLRelativeToStack=0x54 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a053d @ 002a053d, 183 bytes * /

BOOL FUN_002a053d(HSReadWriteTextActionAssistantPaneApplier *self,SEL _cmd)

{
  byte bVar1;
  id pvVar2;
  HSReadWriteTextActionAssistantPaneApplier *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_HSActionAssistantSettingsApplier_00356a20;
  pvVar2 = _objc_msgSendSuper(&local_14,sel_areSettingsEqual);
  if ((char)pvVar2 == '\0') {
    return '\0';
  }
  bVar1 = self->_isFileURLRelativeToStackInitially[0];
  if ((bVar1 & 1) != 0) {
    if ((bVar1 & 2) == 0) {
      return '\0';
    }
    if ((bVar1 & 1) != 0) goto LAB_002a0589;
  }
  if ((bVar1 & 2) != 0) {
    return '\0';
  }
LAB_002a0589:
  if ((self->_targetObjectUID == (id)0x0 && self->_initialTargetObjectUID == (id)0x0) ||
     (pvVar2 = _objc_msgSend(self->_targetObjectUID,sel_isEqual_,self->_initialTargetObjectUID),
     (char)pvVar2 != '\0')) {
    if (((self->_fileURL == (id)0x0 && self->_initialFileURL == (id)0x0) ||
        (pvVar2 = _objc_msgSend(self->_fileURL,sel_isEqualTo_,self->_initialFileURL),
        (char)pvVar2 != '\0')) && (self->_mode == self->_initialMode)) {
      return self->_operation == self->_initialOperation;
    }
  }
  return '\0';
}

*/
- (BOOL)areSettingsEqual
{
    if (![super areSettingsEqual]) {
        return NO;
    }
    if (_isFileURLRelativeToStackInitially != _isFileURLRelativeToStack) {
        return NO;
    }
    if (!((_targetObjectUID == nil && _initialTargetObjectUID == nil) || [_targetObjectUID isEqual:_initialTargetObjectUID])) {
        return NO;
    }
    if (!((_fileURL == nil && _initialFileURL == nil) || [_fileURL isEqualTo:_initialFileURL])) {
        return NO;
    }
    return _mode == _initialMode && _operation == _initialOperation;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a05f4 @ 002a05f4, 186 bytes * /

void FUN_002a05f4(HSReadWriteTextActionAssistantPaneApplier *self,SEL _cmd)

{
  id pvVar1;
  HSReadWriteTextActionAssistantPaneApplier *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_HSActionAssistantSettingsApplier_00356a20;
  _objc_msgSendSuper(&local_14,sel_makeCurrentEqualToInitial);
  if (self->_initialTargetObjectUID != self->_targetObjectUID) {
    _objc_msgSend(self->_targetObjectUID,sel_release);
    pvVar1 = _objc_msgSend(self->_initialTargetObjectUID,sel_retain);
    self->_targetObjectUID = pvVar1;
  }
  if (self->_initialFileURL != self->_fileURL) {
    _objc_msgSend(self->_fileURL,sel_release);
    pvVar1 = _objc_msgSend(self->_initialFileURL,sel_retain);
    self->_fileURL = pvVar1;
  }
  self->_isFileURLRelativeToStackInitially[0] =
       self->_isFileURLRelativeToStackInitially[0] * '\x02' & 2 |
       self->_isFileURLRelativeToStackInitially[0] & 0xfd;
  self->_operation = self->_initialOperation;
  self->_mode = self->_initialMode;
  return;
}

*/
- (void)makeCurrentEqualToInitial
{
    [super makeCurrentEqualToInitial];
    if (_initialTargetObjectUID != _targetObjectUID) {
        [_targetObjectUID release];
        _targetObjectUID = [_initialTargetObjectUID retain];
    }
    if (_initialFileURL != _fileURL) {
        [_fileURL release];
        _fileURL = [_initialFileURL retain];
    }
    _isFileURLRelativeToStack = _isFileURLRelativeToStackInitially;
    _operation = _initialOperation;
    _mode = _initialMode;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a06ae @ 002a06ae, 186 bytes * /

void FUN_002a06ae(HSReadWriteTextActionAssistantPaneApplier *self,SEL _cmd)

{
  id pvVar1;
  HSReadWriteTextActionAssistantPaneApplier *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_HSActionAssistantSettingsApplier_00356a20;
  _objc_msgSendSuper(&local_14,sel_makeInitialEqualToCurrent);
  if (self->_initialTargetObjectUID != self->_targetObjectUID) {
    _objc_msgSend(self->_initialTargetObjectUID,sel_release);
    pvVar1 = _objc_msgSend(self->_targetObjectUID,sel_retain);
    self->_initialTargetObjectUID = pvVar1;
  }
  if (self->_initialFileURL != self->_fileURL) {
    _objc_msgSend(self->_initialFileURL,sel_release);
    pvVar1 = _objc_msgSend(self->_fileURL,sel_retain);
    self->_initialFileURL = pvVar1;
  }
  self->_isFileURLRelativeToStackInitially[0] =
       self->_isFileURLRelativeToStackInitially[0] >> 1 & 1 |
       self->_isFileURLRelativeToStackInitially[0] & 0xfe;
  self->_initialOperation = self->_operation;
  self->_initialMode = self->_mode;
  return;
}

*/
- (void)makeInitialEqualToCurrent
{
    [super makeInitialEqualToCurrent];
    if (_initialTargetObjectUID != _targetObjectUID) {
        [_initialTargetObjectUID release];
        _initialTargetObjectUID = [_targetObjectUID retain];
    }
    if (_initialFileURL != _fileURL) {
        [_initialFileURL release];
        _initialFileURL = [_fileURL retain];
    }
    _isFileURLRelativeToStackInitially = _isFileURLRelativeToStack;
    _initialOperation = _operation;
    _initialMode = _mode;
}

- (void)setModeAsInitial
{
    _initialMode = (int)[_actionAttributes mode];
}

- (void)setOperationAsInitial
{
    _initialOperation = (int)[_actionAttributes operation];
}

- (void)setFileURLAsInitial
{
    if (_initialFileURL != [_actionAttributes fileURL]) {
        [_initialFileURL release];
        _initialFileURL = [[_actionAttributes fileURL] copy];
    }
}

- (void)setTargetObjectAsInitial
{
    if (_initialTargetObjectUID != [_actionAttributes targetObjectUID]) {
        [_initialTargetObjectUID release];
        _initialTargetObjectUID = [[_actionAttributes targetObjectUID] retain];
    }
}

- (void)setInitialModeToObject
{
    [_actionAttributes setMode:_initialMode];
}

- (void)setInitialOperationToObject
{
    [_actionAttributes setOperation:_initialOperation];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029d777 @ 0029d777, 68 bytes * /

void FUN_0029d777(HSReadWriteTextActionAssistantPaneApplier *self,SEL _cmd)

{
  undefined4 uVar1;
  
  uVar1 = 0xffffffff;
  if ((self->_isFileURLRelativeToStackInitially[0] & 1) == 0) {
    uVar1 = 0;
  }
  _objc_msgSend(self->_actionAttributes,sel_setFileURL_relativeToStack_,self->_initialFileURL,uVar1)
  ;
  return;
}

*/
- (void)setInitialFileURLToObject
{
    [_actionAttributes setFileURL:_initialFileURL relativeToStack:_isFileURLRelativeToStackInitially];
}

- (void)setInitialTargetObjectToObject
{
    [_actionAttributes setTargetObjectUID:_initialTargetObjectUID];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a0768 @ 002a0768, 189 bytes * /

void FUN_002a0768(HSReadWriteTextActionAssistantPaneApplier *self,SEL _cmd)

{
  undefined4 uVar1;
  HSReadWriteTextActionAssistantPaneApplier *local_1c;
  undefined *local_18;
  
  _objc_msgSend(self->_actionAttributes,sel_setTargetObjectUID_,self->_initialTargetObjectUID);
  uVar1 = 0xffffffff;
  if ((self->_isFileURLRelativeToStackInitially[0] & 1) == 0) {
    uVar1 = 0;
  }
  _objc_msgSend(self->_actionAttributes,sel_setFileURL_relativeToStack_,self->_initialFileURL,uVar1)
  ;
  _objc_msgSend(self->_actionAttributes,sel_setOperation_,self->_initialOperation);
  _objc_msgSend(self->_actionAttributes,sel_setMode_,self->_initialMode);
  local_1c = self;
  local_18 = PTR_s_HSActionAssistantSettingsApplier_00356a20;
  _objc_msgSendSuper(&local_1c,sel_setInitialSettingsToObject);
  return;
}

*/
- (void)setInitialSettingsToObject
{
    [_actionAttributes setTargetObjectUID:_initialTargetObjectUID];
    [_actionAttributes setFileURL:_initialFileURL relativeToStack:_isFileURLRelativeToStackInitially];
    [_actionAttributes setOperation:_initialOperation];
    [_actionAttributes setMode:_initialMode];
    [super setInitialSettingsToObject];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a0825 @ 002a0825, 189 bytes * /

void FUN_002a0825(HSReadWriteTextActionAssistantPaneApplier *self,SEL _cmd)

{
  undefined4 uVar1;
  HSReadWriteTextActionAssistantPaneApplier *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSActionAssistantSettingsApplier_00356a20;
  _objc_msgSendSuper(&local_1c,sel_setCurrentSettingsToObject);
  _objc_msgSend(self->_actionAttributes,sel_setTargetObjectUID_,self->_targetObjectUID);
  uVar1 = 0xffffffff;
  if ((self->_isFileURLRelativeToStackInitially[0] & 2) == 0) {
    uVar1 = 0;
  }
  _objc_msgSend(self->_actionAttributes,sel_setFileURL_relativeToStack_,self->_fileURL,uVar1);
  _objc_msgSend(self->_actionAttributes,sel_setOperation_,self->_operation);
  _objc_msgSend(self->_actionAttributes,sel_setMode_,self->_mode);
  return;
}

*/
- (void)setCurrentSettingsToObject
{
    [super setCurrentSettingsToObject];
    [_actionAttributes setTargetObjectUID:_targetObjectUID];
    [_actionAttributes setFileURL:_fileURL relativeToStack:_isFileURLRelativeToStack];
    [_actionAttributes setOperation:_operation];
    [_actionAttributes setMode:_mode];
}

- (void)setCurrentModeToObject
{
    [_actionAttributes setMode:_mode];
}

- (void)setCurrentOperationToObject
{
    [_actionAttributes setOperation:_operation];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029d6a3 @ 0029d6a3, 68 bytes * /

void FUN_0029d6a3(HSReadWriteTextActionAssistantPaneApplier *self,SEL _cmd)

{
  undefined4 uVar1;
  
  uVar1 = 0xffffffff;
  if ((self->_isFileURLRelativeToStackInitially[0] & 2) == 0) {
    uVar1 = 0;
  }
  _objc_msgSend(self->_actionAttributes,sel_setFileURL_relativeToStack_,self->_fileURL,uVar1);
  return;
}

*/
- (void)setCurrentFileURLToObject
{
    [_actionAttributes setFileURL:_fileURL relativeToStack:_isFileURLRelativeToStack];
}

- (void)setCurrentTargetObjectUIDToObject
{
    [_actionAttributes setTargetObjectUID:_targetObjectUID];
}

- (void)setMode:(NSInteger)aMode
{
    if (_mode != aMode) {
        _mode = aMode;
        [self disableUndo];
        [_actionAttributes setMode:_mode];
        [self enableUndo];
    }
}

- (void)setOperation:(NSInteger)aOperation
{
    if (_operation != aOperation) {
        _operation = aOperation;
        [self disableUndo];
        [_actionAttributes setOperation:_operation];
        [self enableUndo];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029d4b9 @ 0029d4b9, 244 bytes * /

void FUN_0029d4b9(HSReadWriteTextActionAssistantPaneApplier *self,SEL _cmd,id setFileURL,
                 BOOL relativeToStack)

{
  byte bVar1;
  id pvVar2;
  undefined4 uVar3;
  
  bVar1 = self->_isFileURLRelativeToStackInitially[0] & 2;
  if (relativeToStack == '\0') {
    if (bVar1 != 0) goto LAB_0029d508;
  }
  else if (bVar1 == 0) goto LAB_0029d508;
  pvVar2 = _objc_msgSend(self->_fileURL,sel_isEqual_,setFileURL);
  if ((char)pvVar2 != '\0') {
    return;
  }
LAB_0029d508:
  pvVar2 = _objc_msgSend(setFileURL,sel_copy);
  _objc_msgSend(self->_fileURL,sel_release);
  self->_fileURL = pvVar2;
  self->_isFileURLRelativeToStackInitially[0] =
       self->_isFileURLRelativeToStackInitially[0] & 0xfd | relativeToStack * '\x02' & 2U;
  _objc_msgSend(self,sel_disableUndo);
  uVar3 = 0xffffffff;
  if ((self->_isFileURLRelativeToStackInitially[0] & 2) == 0) {
    uVar3 = 0;
  }
  _objc_msgSend(self->_actionAttributes,sel_setFileURL_relativeToStack_,self->_fileURL,uVar3);
  _objc_msgSend(self,sel_enableUndo);
  return;
}

*/
- (void)setFileURL:(id)aURL relativeToStack:(BOOL)aStack
{
    if ((aStack ? 1 : 0) == _isFileURLRelativeToStack && [_fileURL isEqual:aURL]) {
        return;
    }
    id fileURL = [aURL copy];
    [_fileURL release];
    _fileURL = fileURL;
    _isFileURLRelativeToStack = aStack ? 1 : 0;
    [self disableUndo];
    [_actionAttributes setFileURL:_fileURL relativeToStack:_isFileURLRelativeToStack];
    [self enableUndo];
}

- (void)setTargetObjectUID:(id)aUID
{
    if (![aUID isEqual:_targetObjectUID]) {
        [_targetObjectUID release];
        _targetObjectUID = [aUID retain];
        [self disableUndo];
        [_actionAttributes setTargetObjectUID:_targetObjectUID];
        [self enableUndo];
    }
}

- (id)readWriteTextActionAttributes
{
    id pvVar1;

    pvVar1 = _actionAttributes;
    if (pvVar1 == nil) {
        pvVar1 = [[[self actionAttributes] queryHyperInterface:@protocol(HSReadWriteTextActionAttributes)] retain];
        _actionAttributes = pvVar1;
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a08e2 @ 002a08e2, 315 bytes * /

void FUN_002a08e2(HSReadWriteTextActionAssistantPaneApplier *self,SEL _cmd)

{
  id pvVar1;
  HSReadWriteTextActionAssistantPaneApplier *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_HSActionAssistantSettingsApplier_00356a20;
  _objc_msgSendSuper(&local_14,sel_setUpInitialSettings);
  pvVar1 = _objc_msgSend(self,sel_readWriteTextActionAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_targetObjectUID);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_initialTargetObjectUID = pvVar1;
  pvVar1 = _objc_msgSend(self->_actionAttributes,sel_fileURL);
  pvVar1 = _objc_msgSend(pvVar1,sel_copy);
  self->_initialFileURL = pvVar1;
  pvVar1 = _objc_msgSend(self->_actionAttributes,sel_isFileURLRelativeToStack);
  self->_isFileURLRelativeToStackInitially[0] =
       self->_isFileURLRelativeToStackInitially[0] & 0xfe | (byte)pvVar1 & 1;
  pvVar1 = _objc_msgSend(self->_actionAttributes,sel_operation);
  self->_initialOperation = (int)pvVar1;
  pvVar1 = _objc_msgSend(self->_actionAttributes,sel_mode);
  self->_initialMode = (int)pvVar1;
  pvVar1 = _objc_msgSend(self->_initialTargetObjectUID,sel_retain);
  self->_targetObjectUID = pvVar1;
  pvVar1 = _objc_msgSend(self->_initialFileURL,sel_copy);
  self->_fileURL = pvVar1;
  self->_isFileURLRelativeToStackInitially[0] =
       self->_isFileURLRelativeToStackInitially[0] * '\x02' & 2 |
       self->_isFileURLRelativeToStackInitially[0] & 0xfd;
  self->_operation = self->_initialOperation;
  self->_mode = self->_initialMode;
  return;
}

*/
- (void)setUpInitialSettings
{
    [super setUpInitialSettings];
    _initialTargetObjectUID = [[[self readWriteTextActionAttributes] targetObjectUID] retain];
    _initialFileURL = [[_actionAttributes fileURL] copy];
    _isFileURLRelativeToStackInitially = [_actionAttributes isFileURLRelativeToStack] ? 1 : 0;
    _initialOperation = (int)[_actionAttributes operation];
    _initialMode = (int)[_actionAttributes mode];
    _targetObjectUID = [_initialTargetObjectUID retain];
    _fileURL = [_initialFileURL copy];
    _isFileURLRelativeToStack = _isFileURLRelativeToStackInitially;
    _operation = _initialOperation;
    _mode = _initialMode;
}

- (void)dealloc
{
    [_initialTargetObjectUID release];
    [_initialFileURL release];
    [_targetObjectUID release];
    [_fileURL release];
    [_actionAttributes release];
    [super dealloc];
}

@end

