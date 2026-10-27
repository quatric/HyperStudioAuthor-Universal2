#import "HSShowHideObjectsActionAssistantPane.h"

static NSInteger HSShowHideCompareObjectNames(id aObject1, id aObject2, void *aContext)
{
    return [[[aObject1 queryHyperInterface:@protocol(HSObjectAttributes)] hyperName] caseInsensitiveCompare:[[aObject2 queryHyperInterface:@protocol(HSObjectAttributes)] hyperName]];
}

@implementation HSShowHideObjectsActionAssistantPane

/* i386 ivar offsets: _objectsTableView=0x78, _actionMenu=0x7c, _transitionsTab=0x80, _showEffectTransitionPopup=0x84, _showEffectSpeedSlider=0x88, _showEffectTransitionPreview=0x8c, _showEffectTransitionImageView=0x90, _hideEffectTransitionPopup=0x94, _hideEffectSpeedSlider=0x98, _hideEffectTransitionPreview=0x9c, _hideEffectTransitionImageView=0xa0, _objectsFilterSwitch=0xa4, _availableObjects=0xa8, _stack=0xac, _objectIcons=0xb0, _resourceNames=0xb4, _lastUserChosenShowTransitionName=0xb8, _lastUserChosenShowTransitionDuration=0xbc, _lastUserChosenHideTransitionName=0xc4, _lastUserChosenHideTransitionDuration=0xc8 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_00116f26 @ 00116f26, 410 bytes * /

int FUN_00116f26(HSShowHideObjectsActionAssistantPane *self,SEL _cmd)

{
  int iVar1;
  id self_00;
  id self_01;
  id pvVar2;
  id pvVar3;
  cfstringStruct *pcVar4;
  undefined1 *puVar5;
  undefined4 uVar6;
  int local_80;
  id local_7c;
  cfstringStruct local_74;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined1 local_50 [64];
  
  self_00 = _objc_msgSend(self,sel_HSShowHideObjectsActionAssistantPane_availableCardObjects);
  self_01 = _objc_msgSend(self,sel_HSShowHideObjectsActionAssistantPane_applier);
  local_74.field0_0x0 = 0;
  local_74.field1_0x4 = 0;
  local_74.field2_0x8 = (undefined *)0x0;
  local_74.field3_0xc = 0;
  local_64 = 0;
  local_60 = 0;
  local_5c = 0;
  local_58 = 0;
  puVar5 = local_50;
  pcVar4 = &local_74;
  uVar6 = 0x10;
  local_7c = _objc_msgSend(self_00,sel_countByEnumeratingWithState_objects_count_,pcVar4,puVar5,0x10
                          );
  if (local_7c == (id)0x0) {
    local_80 = 0;
  }
  else {
    iVar1 = *(int *)local_74.field2_0x8;
    local_80 = 0;
    do {
      pvVar3 = (id)0x0;
      do {
        if (iVar1 != *(int *)local_74.field2_0x8) {
          _objc_enumerationMutation(self_00);
        }
        pvVar2 = _objc_msgSend(*(id *)(local_74.field1_0x4 + (int)pvVar3 * 4),sel_hyperUID,pcVar4,
                               puVar5,uVar6);
        pvVar2 = _objc_msgSend(self_01,sel_actionSettingsForObjectUID_,pvVar2);
        pcVar4 = &cfstr_HSEnableVisibility;
        pvVar2 = _objc_msgSend(pvVar2,sel_objectForKey_);
        pvVar2 = _objc_msgSend(pvVar2,sel_boolValue);
        local_80 = local_80 + (uint)((char)pvVar2 != '\0');
        pvVar3 = (id)((int)pvVar3 + 1);
      } while (pvVar3 < local_7c);
      puVar5 = local_50;
      pcVar4 = &local_74;
      uVar6 = 0x10;
      local_7c = _objc_msgSend(self_00,sel_countByEnumeratingWithState_objects_count_,pcVar4,puVar5,
                               0x10);
    } while (local_7c != (id)0x0);
  }
  return local_80;
}

*/
- (NSInteger)checkedObjects
{
    id applier = [self HSShowHideObjectsActionAssistantPane_applier];
    NSInteger checked = 0;
    for (id object in [self HSShowHideObjectsActionAssistantPane_availableCardObjects]) {
        if ([[[applier actionSettingsForObjectUID:[object hyperUID]] objectForKey:@"HSEnableVisibility"] boolValue]) {
            checked++;
        }
    }
    return checked;
}

- (void)setLastUserChoosedTransitionParametersForHyperUID:(id)aUID
{
    id self_00;

    self_00 = [self HSShowHideObjectsActionAssistantPane_applier];
    if (_lastUserChosenShowTransitionName != nil) {
        [self_00 setValue:_lastUserChosenShowTransitionName forSettingKey:@"HSShowHideTransitionName" transitionTypeKey:@"HSObjectShowEffectTransition" objectUID:aUID];
        [self_00 setValue:[NSNumber numberWithDouble:_lastUserChosenShowTransitionDuration] forSettingKey:@"HSShowHideTransitionDuration" transitionTypeKey:@"HSObjectShowEffectTransition" objectUID:aUID];
    }
    if (_lastUserChosenHideTransitionName != nil) {
        [self_00 setValue:_lastUserChosenHideTransitionName forSettingKey:@"HSShowHideTransitionName" transitionTypeKey:@"HSObjectHideEffectTransition" objectUID:aUID];
        [self_00 setValue:[NSNumber numberWithDouble:_lastUserChosenHideTransitionDuration] forSettingKey:@"HSShowHideTransitionDuration" transitionTypeKey:@"HSObjectHideEffectTransition" objectUID:aUID];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0011688e @ 0011688e, 416 bytes * /

void FUN_0011688e(HSShowHideObjectsActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  cfstringStruct *pcVar3;
  cfstringStruct *pcVar4;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_selectedObjectUID);
  if (pvVar1 == (id)0x0) {
    return;
  }
  pvVar2 = _objc_msgSend(self,sel_HSShowHideObjectsActionAssistantPane_applier);
  pvVar1 = _objc_msgSend(pvVar2,sel_actionSettingsForObjectUID_,pvVar1);
  pcVar3 = &cfstr_HSObjectVisibilityAction;
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_HSObjectVisibilityAction);
  pvVar1 = _objc_msgSend(pvVar1,sel_integerValue);
  if (pvVar1 != (id)0x0) {
    op = sel_startCurrentObjectVisibilityActionTransition;
    if (pvVar1 != (id)0x3) {
      if (pvVar1 == (id)0x1) {
        pcVar4 = &cfstr_1;
      }
      else {
        pcVar4 = &cfstr_2;
      }
      pvVar1 = _objc_msgSend(self->_transitionsTab,sel_selectedTabViewItem,pcVar3);
      pvVar1 = _objc_msgSend(pvVar1,sel_identifier);
      pcVar3 = pcVar4;
      pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_,pcVar4);
      op = sel_startCurrentObjectVisibilityActionTransition;
      if ((char)pvVar1 == '\0') {
        self = self->_transitionsTab;
        op = sel_selectTabViewItemWithIdentifier_;
        pcVar3 = pcVar4;
      }
    }
    goto LAB_001169be;
  }
  pvVar1 = _objc_msgSend(self->_objectsTableView,sel_selectedRow,pcVar3);
  pvVar2 = _objc_msgSend(self,sel_HSShowHideObjectsActionAssistantPane_availableCardObjects);
  if ((pvVar1 == (id)0xffffffff) || (pvVar2 == (id)0x0)) {
LAB_00116965:
    pcVar3 = &cfstr_2;
  }
  else {
    pvVar1 = _objc_msgSend(pvVar2,sel_objectAtIndex_,pvVar1);
    pvVar1 = _objc_msgSend(pvVar1,sel_isHidden);
    if ((char)pvVar1 == '\0') goto LAB_00116965;
    pcVar3 = &cfstr_1;
  }
  self = self->_transitionsTab;
  op = sel_selectTabViewItemWithIdentifier_;
LAB_001169be:
  _objc_msgSend(self,op,pcVar3);
  return;
}

*/
- (void)selectCurrentObjectVisibilityActionTab
{
    id objectUID = [self selectedObjectUID];
    NSInteger action;
    NSString *identifier;
    NSInteger row;
    id objects;
    if (objectUID == nil) {
        return;
    }
    action = [[[[self HSShowHideObjectsActionAssistantPane_applier] actionSettingsForObjectUID:objectUID] objectForKey:@"HSObjectVisibilityAction"] integerValue];
    if (action != 0) {
        if (action != 3) {
            identifier = (action == 1) ? @"1" : @"2";
            if (![[[_transitionsTab selectedTabViewItem] identifier] isEqualToString:identifier]) {
                [_transitionsTab selectTabViewItemWithIdentifier:identifier];
                return;
            }
        }
        [self startCurrentObjectVisibilityActionTransition];
        return;
    }
    // Without an explicit action the tab follows the object's current visibility.
    row = [_objectsTableView selectedRow];
    objects = [self HSShowHideObjectsActionAssistantPane_availableCardObjects];
    identifier = @"2";
    if (row != -1 && objects != nil && [[objects objectAtIndex:row] isHidden]) {
        identifier = @"1";
    }
    [_transitionsTab selectTabViewItemWithIdentifier:identifier];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0011680e @ 0011680e, 128 bytes * /

void FUN_0011680e(HSShowHideObjectsActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  SEL op;
  cfstringStruct *pcVar2;
  
  pvVar1 = _objc_msgSend(self->_transitionsTab,sel_selectedTabViewItem);
  pvVar1 = _objc_msgSend(pvVar1,sel_identifier);
  pcVar2 = &cfstr_1;
  pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_,&cfstr_1);
  op = sel_startHideEffectTransition;
  if ((char)pvVar1 != '\0') {
    op = sel_startShowEffectTransition;
  }
  _objc_msgSend(self,op,pcVar2);
  return;
}

*/
- (void)startCurrentObjectVisibilityActionTransition
{
    if ([[[_transitionsTab selectedTabViewItem] identifier] isEqualToString:@"1"]) {
        [self startShowEffectTransition];
    }
    else {
        [self startHideEffectTransition];
    }
}

- (void)availableCardObjectsDidChange:(id)aChange
{
    [_availableObjects release];
    _availableObjects = nil;
    [self validateUIWithNotification:aChange];
}

- (void)setStack:(id)aStack
{
    int uVar1;
    id pvVar2;
    id pvVar2_2;

    if (_stack != aStack) {
        pvVar2 = [_stack queryHyperInterface:@protocol(HSNodeContainer)];
        uVar1 = HSActualDidAttributeChanges;
        [pvVar2 removeObserver:self selector:@selector(availableCardObjectsDidChange:) ofChanges:uVar1 ofChildrenAttribute:@protocol(HSNodeContainerChildrenAttribute)];
        [_stack release];
        pvVar2_2 = [aStack retain];
        _stack = pvVar2_2;
        [[pvVar2_2 queryHyperInterface:@protocol(HSNodeContainer)] addObserver:self selector:@selector(availableCardObjectsDidChange:) ofChanges:uVar1 ofChildrenAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:-0.25];
    }
}

- (id)stack
{
    id pvVar1;

    pvVar1 = _stack;
    if (pvVar1 == nil) {
        pvVar1 = [super stack];
        [self setStack:pvVar1];
        pvVar1 = _stack;
    }
    return pvVar1;
}

- (void)transitionViewDidFinishTransition:(id)aTransition
{
    if ((_showEffectTransitionPreview == aTransition) || (_hideEffectTransitionPreview == aTransition)) {
        [self HSShowHideObjectsActionAssistantPane_hideTransitionView:aTransition];
    }
    [super transitionViewDidFinishTransition:aTransition];
}

- (void)transitionViewDidStopTransition:(id)aTransition
{
    if ((_showEffectTransitionPreview == aTransition) || (_hideEffectTransitionPreview == aTransition)) {
        [self HSShowHideObjectsActionAssistantPane_hideTransitionView:aTransition];
    }
    [super transitionViewDidStopTransition:aTransition]
    ;
}

- (void)stopTransitionPreviewIfNeeded:(id)aNeeded
{
    if ([aNeeded isTransitionPlaying]) {
        [aNeeded stopTransition];
        [self HSShowHideObjectsActionAssistantPane_hideTransitionView:aNeeded];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001171ef @ 001171ef, 522 bytes * /

void FUN_001171ef(HSShowHideObjectsActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  double dVar3;
  undefined8 in_stack_ffffffcc;
  undefined4 uVar5;
  undefined8 uVar4;
  
  uVar5 = (undefined4)((ulonglong)in_stack_ffffffcc >> 0x20);
  pvVar1 = _objc_msgSend(self,sel_selectedObjectUID);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_HSShowHideObjectsActionAssistantPane_applier);
    pvVar1 = _objc_msgSend(pvVar2,sel_actionSettingsForObjectUID_,pvVar1);
    if (pvVar1 != (id)0x0) {
      pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_HSObjectHideEffectTransition);
      if (pvVar1 != (id)0x0) {
        uVar4 = CONCAT44(uVar5,&cfstr_HSShowHideTransitionName);
        pvVar2 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_HSShowHideTransitionName);
        if (pvVar2 != (id)0x0) {
          self_00 = _objc_msgSend(cls_HSTransitionEffectProvider,sel_sharedTransitionEffectProvider,
                                  uVar4);
          pvVar2 = _objc_msgSend(self_00,sel_transitionEffectWithName_,pvVar2);
          if (pvVar2 != (id)0x0) {
            pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_HSShowHideTransitionDuration);
            if (pvVar1 != (id)0x0) {
              dVar3 = _objc_msgSend_fpret(pvVar1,sel_doubleValue);
              if (dVar3 != 0.0) {
                _objc_msgSend(self->_hideEffectTransitionPreview,sel_setTransitionEffect_,pvVar2);
                _objc_msgSend(self->_hideEffectTransitionPreview,sel_setTransitionDuration_,dVar3);
                pvVar1 = _objc_msgSend(self->_hideEffectTransitionPreview,sel_window);
                _objc_msgSend(pvVar1,sel_disableScreenUpdatesUntilFlush);
                _objc_msgSend(self->_hideEffectTransitionPreview,sel_setHidden_,0);
                _objc_msgSend(self->_hideEffectTransitionImageView,sel_setHidden_,1);
                _objc_msgSend(self->_hideEffectTransitionPreview,sel_startTransition);
              }
            }
          }
        }
      }
    }
  }
  return;
}

*/
- (void)startHideEffectTransition
{
    id objectUID = [self selectedObjectUID];
    id settings;
    id transition;
    id name;
    id effect;
    id duration;
    double seconds;
    if (objectUID == nil) {
        return;
    }
    settings = [[self HSShowHideObjectsActionAssistantPane_applier] actionSettingsForObjectUID:objectUID];
    if (settings == nil || (transition = [settings objectForKey:@"HSObjectHideEffectTransition"]) == nil) {
        return;
    }
    if ((name = [transition objectForKey:@"HSShowHideTransitionName"]) == nil) {
        return;
    }
    if ((effect = [[HSTransitionEffectProvider sharedTransitionEffectProvider] transitionEffectWithName:name]) == nil) {
        return;
    }
    if ((duration = [transition objectForKey:@"HSShowHideTransitionDuration"]) == nil || (seconds = [duration doubleValue]) == 0.0) {
        return;
    }
    [_hideEffectTransitionPreview setTransitionEffect:effect];
    [_hideEffectTransitionPreview setTransitionDuration:seconds];
    // The window of the hide preview is used for both, as in the original.
    [[_hideEffectTransitionPreview window] disableScreenUpdatesUntilFlush];
    [_hideEffectTransitionPreview setHidden:NO];
    [_hideEffectTransitionImageView setHidden:YES];
    [_hideEffectTransitionPreview startTransition];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001173f9 @ 001173f9, 522 bytes * /

void FUN_001173f9(HSShowHideObjectsActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  double dVar3;
  undefined8 in_stack_ffffffcc;
  undefined4 uVar5;
  undefined8 uVar4;
  
  uVar5 = (undefined4)((ulonglong)in_stack_ffffffcc >> 0x20);
  pvVar1 = _objc_msgSend(self,sel_selectedObjectUID);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_HSShowHideObjectsActionAssistantPane_applier);
    pvVar1 = _objc_msgSend(pvVar2,sel_actionSettingsForObjectUID_,pvVar1);
    if (pvVar1 != (id)0x0) {
      pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_HSObjectShowEffectTransition);
      if (pvVar1 != (id)0x0) {
        uVar4 = CONCAT44(uVar5,&cfstr_HSShowHideTransitionName);
        pvVar2 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_HSShowHideTransitionName);
        if (pvVar2 != (id)0x0) {
          self_00 = _objc_msgSend(cls_HSTransitionEffectProvider,sel_sharedTransitionEffectProvider,
                                  uVar4);
          pvVar2 = _objc_msgSend(self_00,sel_transitionEffectWithName_,pvVar2);
          if (pvVar2 != (id)0x0) {
            pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_HSShowHideTransitionDuration);
            if (pvVar1 != (id)0x0) {
              dVar3 = _objc_msgSend_fpret(pvVar1,sel_doubleValue);
              if (dVar3 != 0.0) {
                _objc_msgSend(self->_showEffectTransitionPreview,sel_setTransitionEffect_,pvVar2);
                _objc_msgSend(self->_showEffectTransitionPreview,sel_setTransitionDuration_,dVar3);
                pvVar1 = _objc_msgSend(self->_hideEffectTransitionPreview,sel_window);
                _objc_msgSend(pvVar1,sel_disableScreenUpdatesUntilFlush);
                _objc_msgSend(self->_showEffectTransitionPreview,sel_setHidden_,0);
                _objc_msgSend(self->_showEffectTransitionImageView,sel_setHidden_,1);
                _objc_msgSend(self->_showEffectTransitionPreview,sel_startTransition);
              }
            }
          }
        }
      }
    }
  }
  return;
}

*/
- (void)startShowEffectTransition
{
    id objectUID = [self selectedObjectUID];
    id settings;
    id transition;
    id name;
    id effect;
    id duration;
    double seconds;
    if (objectUID == nil) {
        return;
    }
    settings = [[self HSShowHideObjectsActionAssistantPane_applier] actionSettingsForObjectUID:objectUID];
    if (settings == nil || (transition = [settings objectForKey:@"HSObjectShowEffectTransition"]) == nil) {
        return;
    }
    if ((name = [transition objectForKey:@"HSShowHideTransitionName"]) == nil) {
        return;
    }
    if ((effect = [[HSTransitionEffectProvider sharedTransitionEffectProvider] transitionEffectWithName:name]) == nil) {
        return;
    }
    if ((duration = [transition objectForKey:@"HSShowHideTransitionDuration"]) == nil || (seconds = [duration doubleValue]) == 0.0) {
        return;
    }
    [_showEffectTransitionPreview setTransitionEffect:effect];
    [_showEffectTransitionPreview setTransitionDuration:seconds];
    // The window of the hide preview is used for both, as in the original.
    [[_hideEffectTransitionPreview window] disableScreenUpdatesUntilFlush];
    [_showEffectTransitionPreview setHidden:NO];
    [_showEffectTransitionImageView setHidden:YES];
    [_showEffectTransitionPreview startTransition];
}

- (id)selectedObjectUID
{
    id pvVar1;
    NSInteger pvVar2;
    id pvVar1_2;

    pvVar1 = [self HSShowHideObjectsActionAssistantPane_availableCardObjects];
    pvVar2 = [_objectsTableView selectedRow];
    if ((pvVar2 == 0xffffffff) || (pvVar1 == nil)) {
        pvVar1_2 = nil;
    }
    else {
        pvVar1_2 = [[pvVar1 objectAtIndex:pvVar2] hyperUID];
    }
    return pvVar1_2;
}

- (id)HSShowHideObjectsActionAssistantPane_applier
{
    return [self applier];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00117603 @ 00117603, 839 bytes * /

void FUN_00117603(HSShowHideObjectsActionAssistantPane *self,SEL _cmd,
                 id HSShowHideObjectsActionAssistantPane_updateTransitionPreviewWithSettings)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  undefined4 *puVar4;
  id local_38;
  undefined1 local_34 [8];
  float local_2c;
  float local_28;
  undefined4 local_24;
  undefined4 uStack_20;
  float local_1c;
  float fStack_18;
  
  pvVar2 = _objc_msgSend(self->_transitionsTab,sel_selectedTabViewItem);
  pvVar2 = _objc_msgSend(pvVar2,sel_identifier);
  pvVar3 = _objc_msgSend(pvVar2,sel_isEqualToString_);
  if ((char)pvVar3 == '\0') {
    pvVar2 = _objc_msgSend(pvVar2,sel_isEqualToString_);
    if ((char)pvVar2 == '\0') {
      pvVar2 = (id)0x0;
      local_38 = (id)0x0;
    }
    else {
      pvVar2 = _objc_msgSend(self,sel_HSShowHideObjectsActionAssistantPane_applier);
      _objc_msgSend(HSShowHideObjectsActionAssistantPane_updateTransitionPreviewWithSettings,
                    sel_objectForKey_);
      pvVar2 = _objc_msgSend(pvVar2,sel_checkAndCorrectEffectSettings_);
      local_38 = self->_hideEffectTransitionImageView;
    }
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_HSShowHideObjectsActionAssistantPane_applier);
    _objc_msgSend(HSShowHideObjectsActionAssistantPane_updateTransitionPreviewWithSettings,
                  sel_objectForKey_);
    pvVar2 = _objc_msgSend(pvVar2,sel_checkAndCorrectEffectSettings_);
    local_38 = self->_showEffectTransitionImageView;
  }
  pvVar2 = _objc_msgSend(pvVar2,sel_objectForKey_);
  if (pvVar2 != (id)0x0) {
    pvVar2 = _objc_msgSend(cls_HSTransitionEffectProvider,sel_sharedTransitionEffectProvider);
    if (pvVar2 != (id)0x0) {
      pvVar2 = _objc_msgSend(pvVar2,sel_thumbnailForTransitionEffectWithName_);
      puVar4 = (undefined4 *)&stack0xffffff84;
      if (pvVar2 != (id)0x0) {
        _objc_msgSend_stret(local_34,local_38,sel_bounds);
        puVar4 = (undefined4 *)&stack0xffffff80;
        if ((0.0 < local_2c) && (puVar4 = (undefined4 *)&stack0xffffff80, 0.0 < local_28)) {
          _objc_msgSend(pvVar2,sel_size);
          cVar1 = _NSEqualSizes();
          puVar4 = (undefined4 *)&stack0xffffff80;
          if (cVar1 == '\0') {
            pvVar3 = _objc_msgSend(cls_NSImage,sel_alloc);
            pvVar3 = _objc_msgSend(pvVar3,sel_initWithSize_);
            pvVar3 = _objc_msgSend(pvVar3,sel_autorelease);
            puVar4 = (undefined4 *)&stack0xffffff80;
            if (pvVar3 != (id)0x0) {
              _objc_msgSend(pvVar3,sel_lockFocus);
              local_24 = 0;
              uStack_20 = 0;
              local_1c = local_2c;
              fStack_18 = local_28;
              _objc_msgSend(pvVar2,sel_drawInRect_fromRect_operation_fraction_);
              _objc_msgSend(pvVar3,sel_unlockFocus);
              puVar4 = (undefined4 *)&stack0xffffff80;
              pvVar2 = pvVar3;
            }
          }
        }
      }
      goto LAB_00117913;
    }
  }
  puVar4 = (undefined4 *)&stack0xffffff84;
  pvVar2 = (id)0x0;
LAB_00117913:
  puVar4[2] = pvVar2;
  puVar4[1] = sel_setImage_;
  *puVar4 = local_38;
  puVar4[-1] = 0x11792c;
  _objc_msgSend((id)*puVar4,(SEL)puVar4[1]);
  puVar4[2] = pvVar2;
  puVar4[1] = sel_setAlternateImage_;
  *puVar4 = local_38;
  puVar4[-1] = 0x117942;
  _objc_msgSend((id)*puVar4,(SEL)puVar4[1]);
  return;
}

*/
- (void)HSShowHideObjectsActionAssistantPane_updateTransitionPreviewWithSettings:(id)aSettings
{
    id identifier = [[_transitionsTab selectedTabViewItem] identifier];
    id settings = nil;
    NSButton *imageView = nil;
    id name;
    id provider;
    NSImage *image = nil;
    if ([identifier isEqualToString:@"1"]) {
        settings = [[self HSShowHideObjectsActionAssistantPane_applier] checkAndCorrectEffectSettings:[aSettings objectForKey:@"HSObjectShowEffectTransition"]];
        imageView = _showEffectTransitionImageView;
    }
    else if ([identifier isEqualToString:@"2"]) {
        settings = [[self HSShowHideObjectsActionAssistantPane_applier] checkAndCorrectEffectSettings:[aSettings objectForKey:@"HSObjectHideEffectTransition"]];
        imageView = _hideEffectTransitionImageView;
    }
    name = [settings objectForKey:@"HSShowHideTransitionName"];
    if (name != nil && (provider = [HSTransitionEffectProvider sharedTransitionEffectProvider]) != nil) {
        image = [provider thumbnailForTransitionEffectWithName:name];
        if (image != nil) {
            NSRect bounds = [imageView bounds];
            if (bounds.size.width > 0.0f && bounds.size.height > 0.0f && !NSEqualSizes([image size], bounds.size)) {
                NSImage *scaled = [[[NSImage alloc] initWithSize:bounds.size] autorelease];
                if (scaled != nil) {
                    [scaled lockFocus];
                    [image drawInRect:NSMakeRect(0.0f, 0.0f, bounds.size.width, bounds.size.height) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
                    [scaled unlockFocus];
                    image = scaled;
                }
            }
        }
    }
    [imageView setImage:image];
    [imageView setAlternateImage:image];
}

- (void)HSShowHideObjectsActionAssistantPane_setValue:(id)aValue forSettingKey:(id)aKey transitionTypeKey:(id)aKey2 updatePreview:(BOOL)aPreview
{
    id pvVar1;
    id self_00;

    pvVar1 = [self selectedObjectUID];
    if (pvVar1 != nil) {
        self_00 = [self HSShowHideObjectsActionAssistantPane_applier];
        [self_00 setValue:aValue forSettingKey:aKey transitionTypeKey:aKey2 objectUID:pvVar1];
        if (aPreview != NO) {
            [self HSShowHideObjectsActionAssistantPane_updateTransitionPreviewWithSettings:[[self HSShowHideObjectsActionAssistantPane_applier] actionSettingsForObjectUID:pvVar1]];
        }
    }
}

- (void)HSShowHideObjectsActionAssistantPane_validateUIWithActionSettings:(id)aSettings
{
    id pvVar1;
    id pvVar2;
    int pvVar3_2;

    pvVar1 = [aSettings objectForKey:@"HSObjectShowEffectTransition"];
    pvVar2 = [aSettings objectForKey:@"HSObjectHideEffectTransition"];
    pvVar3_2 = [[aSettings objectForKey:@"HSObjectVisibilityAction"] intValue];
    [self HSShowHideObjectsActionAssistantPane_validateEffectTransitionPopup:_showEffectTransitionPopup speedSlider:_showEffectSpeedSlider withTransitionSettings:pvVar1 canBeEnabled:(unsigned int)(pvVar3_2 != 0)];
    [self HSShowHideObjectsActionAssistantPane_validateEffectTransitionPopup:_hideEffectTransitionPopup speedSlider:_hideEffectSpeedSlider withTransitionSettings:pvVar2 canBeEnabled:(unsigned int)(pvVar3_2 != 0)];
}

- (void)HSShowHideObjectsActionAssistantPane_validateEffectTransitionPopup:(id)aPopup speedSlider:(id)aSlider withTransitionSettings:(id)aSettings canBeEnabled:(BOOL)aEnabled
{
    id pvVar1;
    id self_00;
    double local_24;

    if (aSettings == nil) {
        local_24 = 0.0;
    }
    else {
        pvVar1 = [aSettings objectForKey:@"HSShowHideTransitionName"]
        ;
        self_00 = [aSettings objectForKey:@"HSShowHideTransitionDuration"];
        if (self_00 == nil) {
            local_24 = 0.0;
        }
        else {
            local_24 = [self_00 doubleValue];
        }
        if (pvVar1 != nil) {
            [aPopup selectItemAtIndex:[aPopup indexOfItemWithRepresentedObject:pvVar1]];
        }
    }
    [aPopup setEnabled:aEnabled];
    if (0.0 < local_24) {
        [aSlider setDoubleValue:2.0 - local_24];
    }
    [aSlider setEnabled:(unsigned int)(aEnabled != NO && 0.0 < local_24)];
}

- (void)validateUIWithNotification:(id)aNotification
{
    [_objectsTableView reloadData];
    [self validateUI];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0011616d @ 0011616d, 447 bytes * /

id FUN_0011616d(HSShowHideObjectsActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined *puVar4;
  
  pvVar1 = self->_availableObjects;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self->_objectsFilterSwitch,sel_state);
    if (pvVar1 == (id)0x1) {
      pvVar1 = _objc_msgSend(self,sel_card);
    }
    else {
      pvVar1 = _objc_msgSend(self,sel_stack);
    }
    puVar4 = &DAT_003710a0;
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_003710a0);
    if (pvVar1 != (id)0x0) {
      pvVar2 = _objc_msgSend(cls_NSMutableArray,sel_new,puVar4);
      self->_availableObjects = pvVar2;
      pvVar2 = _objc_msgSend(pvVar1,sel_hyperDeepEnumerator);
      pvVar1 = _objc_msgSend(pvVar2,sel_nextObject);
      while (pvVar1 != (id)0x0) {
        puVar4 = &DAT_003710c8;
        pvVar3 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_003710c8);
        pvVar3 = _objc_msgSend(pvVar3,sel_canBeHidden);
        if ((char)pvVar3 != '\0') {
          pvVar3 = self->_availableObjects;
          puVar4 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00370fec);
          _objc_msgSend(pvVar3,sel_addObject_,puVar4);
        }
        pvVar1 = _objc_msgSend(pvVar2,sel_nextObject,puVar4);
      }
    }
    _objc_msgSend(self->_availableObjects,sel_sortUsingFunction_context_,FUN_0011632c,0);
    pvVar1 = self->_availableObjects;
  }
  return pvVar1;
}

*/
- (id)HSShowHideObjectsActionAssistantPane_availableCardObjects
{
    id container;
    if (_availableObjects == nil) {
        container = ([_objectsFilterSwitch state] == NSOnState) ? [self card] : [self stack];
        container = [container queryHyperInterface:@protocol(HSNodeContainer)];
        if (container != nil) {
            NSEnumerator *enumerator;
            id object;
            _availableObjects = [NSMutableArray new];
            enumerator = [container hyperDeepEnumerator];
            while ((object = [enumerator nextObject]) != nil) {
                if ([[object queryHyperInterface:@protocol(HSCardObjectAttributes)] canBeHidden]) {
                    [_availableObjects addObject:[object queryHyperInterface:@protocol(HSObjectAttributes)]];
                }
            }
        }
        [_availableObjects sortUsingFunction:HSShowHideCompareObjectNames context:NULL];
    }
    return _availableObjects;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00116065 @ 00116065, 264 bytes * /

void FUN_00116065(HSShowHideObjectsActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_selectedObjectUID);
  if (pvVar1 == (id)0x0) {
    _objc_msgSend(self->_showEffectTransitionPopup,sel_setEnabled_,0);
    _objc_msgSend(self->_showEffectSpeedSlider,sel_setEnabled_,0);
    _objc_msgSend(self->_hideEffectTransitionPopup,sel_setEnabled_,0);
    self = self->_hideEffectSpeedSlider;
    pvVar1 = (id)0x0;
    op = sel_setEnabled_;
  }
  else {
    self_00 = _objc_msgSend(self,sel_HSShowHideObjectsActionAssistantPane_applier);
    pvVar1 = _objc_msgSend(self_00,sel_actionSettingsForObjectUID_,pvVar1);
    _objc_msgSend(self,sel_HSShowHideObjectsActionAssistantPane_validateUIWithActionSettings_,pvVar1
                 );
    op = sel_HSShowHideObjectsActionAssistantPane_updateTransitionPreviewWithSettings_;
  }
  _objc_msgSend(self,op,pvVar1);
  return;
}

*/
- (void)validateUI
{
    id objectUID = [self selectedObjectUID];
    id settings;
    if (objectUID == nil) {
        [_showEffectTransitionPopup setEnabled:NO];
        [_showEffectSpeedSlider setEnabled:NO];
        [_hideEffectTransitionPopup setEnabled:NO];
        [_hideEffectSpeedSlider setEnabled:NO];
        return;
    }
    settings = [[self HSShowHideObjectsActionAssistantPane_applier] actionSettingsForObjectUID:objectUID];
    [self HSShowHideObjectsActionAssistantPane_validateUIWithActionSettings:settings];
    [self HSShowHideObjectsActionAssistantPane_updateTransitionPreviewWithSettings:settings];
}

- (void)filterChanged:(id)aChanged
{
    [_availableObjects release];
    _availableObjects = nil;
    [_objectsTableView reloadData];
}

- (void)previewHideEffectTransition:(id)aTransition
{
    [self startHideEffectTransition];
}

- (void)previewShowEffectTransition:(id)aTransition
{
    [self startShowEffectTransition];
}

- (void)actionHideEffectTransitionSpeedChanged:(id)aChanged
{
    double dVar2;

    [self stopTransitionPreviewIfNeeded:_hideEffectTransitionPreview];
    dVar2 = [aChanged doubleValue];
    _lastUserChosenHideTransitionDuration = 2.0 - dVar2;
    [self HSShowHideObjectsActionAssistantPane_setValue:[NSNumber numberWithDouble:2.0 - dVar2] forSettingKey:@"HSShowHideTransitionDuration" transitionTypeKey:@"HSObjectHideEffectTransition" updatePreview:YES];
    [self startHideEffectTransition];
}

- (void)actionHideEffectTransitionNameChanged:(id)aChanged
{
    double dVar2;
    id pvVar1_2;

    [self stopTransitionPreviewIfNeeded:_hideEffectTransitionPreview];
    pvVar1_2 = [[aChanged selectedItem] representedObject];
    [self HSShowHideObjectsActionAssistantPane_setValue:pvVar1_2 forSettingKey:@"HSShowHideTransitionName" transitionTypeKey:@"HSObjectHideEffectTransition" updatePreview:NO];
    [_lastUserChosenHideTransitionName release];
    _lastUserChosenHideTransitionName = [pvVar1_2 copy];
    if ([_hideEffectTransitionPopup indexOfSelectedItem] == 0) {
        dVar2 = 0.0;
    }
    else {
        dVar2 = 2.0 - [_hideEffectSpeedSlider doubleValue];
    }
    _lastUserChosenHideTransitionDuration = dVar2;
    [self HSShowHideObjectsActionAssistantPane_setValue:[NSNumber numberWithDouble:dVar2] forSettingKey:@"HSShowHideTransitionDuration" transitionTypeKey:@"HSObjectHideEffectTransition" updatePreview:YES];
    [self startHideEffectTransition];
}

- (void)actionShowEffectTransitionSpeedChanged:(id)aChanged
{
    double dVar2;

    [self stopTransitionPreviewIfNeeded:_showEffectTransitionPreview];
    dVar2 = [aChanged doubleValue];
    _lastUserChosenShowTransitionDuration = 2.0 - dVar2;
    [self HSShowHideObjectsActionAssistantPane_setValue:[NSNumber numberWithDouble:2.0 - dVar2] forSettingKey:@"HSShowHideTransitionDuration" transitionTypeKey:@"HSObjectShowEffectTransition" updatePreview:YES];
    [self startShowEffectTransition];
}

- (void)actionShowEffectTransitionNameChanged:(id)aChanged
{
    double dVar2;
    id pvVar1_2;

    [self stopTransitionPreviewIfNeeded:_showEffectTransitionPreview];
    pvVar1_2 = [[aChanged selectedItem] representedObject];
    [self HSShowHideObjectsActionAssistantPane_setValue:pvVar1_2 forSettingKey:@"HSShowHideTransitionName" transitionTypeKey:@"HSObjectShowEffectTransition" updatePreview:NO];
    [_lastUserChosenShowTransitionName release];
    _lastUserChosenShowTransitionName = [pvVar1_2 copy];
    if ([_showEffectTransitionPopup indexOfSelectedItem] == 0) {
        dVar2 = 0.0;
    }
    else {
        dVar2 = 2.0 - [_showEffectSpeedSlider doubleValue];
    }
    _lastUserChosenShowTransitionDuration = dVar2;
    [self HSShowHideObjectsActionAssistantPane_setValue:[NSNumber numberWithDouble:dVar2] forSettingKey:@"HSShowHideTransitionDuration" transitionTypeKey:@"HSObjectShowEffectTransition" updatePreview:YES];
    [self startShowEffectTransition];
}

- (void)tabView:(id)aView didSelectTabViewItem:(id)aItem
{
    [self stopTransitionPreviewIfNeeded:_showEffectTransitionPreview];
    [self stopTransitionPreviewIfNeeded:_hideEffectTransitionPreview];
    [self validateUI];
    [self startCurrentObjectVisibilityActionTransition];
}

- (void)tableViewSelectionDidChange:(id)aChange
{
    [self stopTransitionPreviewIfNeeded:_showEffectTransitionPreview];
    [self stopTransitionPreviewIfNeeded:_hideEffectTransitionPreview];
    [self validateUI];
    [self selectCurrentObjectVisibilityActionTab];
}

- (id)tableView:(id)aView toolTipForCell:(id)aCell rect:(NSRect *)aRect tableColumn:(id)aColumn row:(NSInteger)aRow mouseLocation:(NSPoint)aLocation
{
    NSBundle *pvVar2_6;
    id pcVar3_3;

    if (![[aColumn identifier] isEqual:@"HSObjectActionTableColumnIdentifier"]) {
        if (![[aColumn identifier] isEqual:@"HSObjectNameTableColumnIdentifier"]) {
            return nil;
        }
        pvVar2_6 = [NSBundle bundleForClass:[self class]];
        pcVar3_3 = @"HSObjectTableHeaderTooltip";
    }
    else {
        pvVar2_6 = [NSBundle bundleForClass:[self class]];
        pcVar3_3 = @"HSActionTableHeaderTooltip";
    }
    return [pvVar2_6 localizedStringForKey:pcVar3_3 value:@"" table:@"AssistantPanes"];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00115a3f @ 00115a3f, 866 bytes * /

void FUN_00115a3f(HSShowHideObjectsActionAssistantPane *self,SEL _cmd,id tableView,id setObjectValue
                 ,id forTableColumn,int row)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  HSShowHideObjectsActionAssistantPane *self_01;
  id pvVar4;
  SEL op;
  cfstringStruct *pcVar5;
  undefined4 uVar6;
  
  pvVar1 = _objc_msgSend(self,sel_HSShowHideObjectsActionAssistantPane_availableCardObjects);
  if (pvVar1 == (id)0x0) {
    return;
  }
  pvVar2 = _objc_msgSend(self,sel_HSShowHideObjectsActionAssistantPane_availableCardObjects);
  pvVar2 = _objc_msgSend(pvVar2,sel_objectAtIndex_,row);
  pvVar2 = _objc_msgSend(pvVar2,sel_hyperUID);
  pvVar3 = _objc_msgSend(forTableColumn,sel_identifier);
  pcVar5 = &cfstr_HSObjectActionTableColumnIdentifier;
  pvVar3 = _objc_msgSend(pvVar3,sel_isEqual_,&cfstr_HSObjectActionTableColumnIdentifier);
  if ((char)pvVar3 == '\0') {
    pvVar3 = _objc_msgSend(forTableColumn,sel_identifier,pcVar5);
    pcVar5 = &cfstr_HSCheckBoxTableColumnIdentifier;
    pvVar3 = _objc_msgSend(pvVar3,sel_isEqual_,&cfstr_HSCheckBoxTableColumnIdentifier);
    if ((char)pvVar3 == '\0') goto LAB_00115d7c;
    self_01 = _objc_msgSend(self,sel_HSShowHideObjectsActionAssistantPane_applier,pcVar5);
    pvVar3 = _objc_msgSend(self,sel_checkedObjects);
    if ((pvVar3 != (id)0x0) &&
       (pvVar3 = _objc_msgSend(setObjectValue,sel_intValue,pcVar5), pvVar3 != (id)0x0)) {
      _objc_msgSend(self,sel_setLastUserChoosedTransitionParametersForHyperUID_,pvVar2);
    }
    pcVar5 = &cfstr_HSEnableVisibility;
    uVar6 = 0;
    pvVar3 = pvVar2;
    _objc_msgSend(self_01,sel_setValue_forSettingKey_transitionTypeKey_objectUID_,setObjectValue,
                  &cfstr_HSEnableVisibility,0,pvVar2);
    pvVar4 = _objc_msgSend(setObjectValue,sel_intValue);
    if (pvVar4 == (id)0x0) goto LAB_00115d7c;
    pvVar3 = _objc_msgSend(self_01,sel_actionSettingsForObjectUID_,pvVar2,pcVar5,uVar6,pvVar3);
    pvVar3 = _objc_msgSend(pvVar3,sel_objectForKey_,&cfstr_HSObjectVisibilityAction);
    pvVar3 = _objc_msgSend(pvVar3,sel_intValue);
    if (pvVar3 != (id)0x0) goto LAB_00115d7c;
    pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,row);
    pvVar1 = _objc_msgSend(pvVar1,sel_isHidden);
    if ((char)pvVar1 == '\0') {
      uVar6 = 2;
    }
    else {
      uVar6 = 1;
    }
    pvVar1 = _objc_msgSend(cls_NSNumber,sel_numberWithInt_,uVar6);
    pcVar5 = &cfstr_HSObjectVisibilityAction;
    uVar6 = 0;
    op = sel_setValue_forSettingKey_transitionTypeKey_objectUID_;
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_HSShowHideObjectsActionAssistantPane_applier,pcVar5);
    self_00 = cls_NSNumber;
    pvVar3 = _objc_msgSend(setObjectValue,sel_intValue);
    pvVar3 = _objc_msgSend(self_00,sel_numberWithInt_,(int)pvVar3 + 1);
    pcVar5 = &cfstr_HSObjectVisibilityAction;
    uVar6 = 0;
    _objc_msgSend(pvVar1,sel_setValue_forSettingKey_transitionTypeKey_objectUID_,pvVar3,
                  &cfstr_HSObjectVisibilityAction,0,pvVar2);
    _objc_msgSend(self,sel_stopTransitionPreviewIfNeeded_,self->_showEffectTransitionPreview);
    pvVar1 = self->_hideEffectTransitionPreview;
    _objc_msgSend(self,sel_stopTransitionPreviewIfNeeded_,pvVar1);
    self_01 = self;
    op = sel_selectCurrentObjectVisibilityActionTab;
  }
  _objc_msgSend(self_01,op,pvVar1,pcVar5,uVar6,pvVar2);
LAB_00115d7c:
  _objc_msgSend(tableView,sel_setNeedsDisplay_,1);
  return;
}

*/
- (void)tableView:(id)aView setObjectValue:(id)aValue forTableColumn:(id)aColumn row:(NSInteger)aRow
{
    id objects = [self HSShowHideObjectsActionAssistantPane_availableCardObjects];
    id objectUID;
    id applier;
    if (objects == nil) {
        return;
    }
    objectUID = [[[self HSShowHideObjectsActionAssistantPane_availableCardObjects] objectAtIndex:aRow] hyperUID];
    if ([[aColumn identifier] isEqual:@"HSObjectActionTableColumnIdentifier"]) {
        [[self HSShowHideObjectsActionAssistantPane_applier] setValue:[NSNumber numberWithInt:[aValue intValue] + 1] forSettingKey:@"HSObjectVisibilityAction" transitionTypeKey:nil objectUID:objectUID];
        [self stopTransitionPreviewIfNeeded:_showEffectTransitionPreview];
        [self stopTransitionPreviewIfNeeded:_hideEffectTransitionPreview];
        [self selectCurrentObjectVisibilityActionTab];
    }
    else if ([[aColumn identifier] isEqual:@"HSCheckBoxTableColumnIdentifier"]) {
        applier = [self HSShowHideObjectsActionAssistantPane_applier];
        if ([self checkedObjects] != 0 && [aValue intValue] != 0) {
            [self setLastUserChoosedTransitionParametersForHyperUID:objectUID];
        }
        [applier setValue:aValue forSettingKey:@"HSEnableVisibility" transitionTypeKey:nil objectUID:objectUID];
        if ([aValue intValue] != 0 && [[[applier actionSettingsForObjectUID:objectUID] objectForKey:@"HSObjectVisibilityAction"] intValue] == 0) {
            // A newly checked object toggles its current visibility.
            [applier setValue:[NSNumber numberWithInt:([[objects objectAtIndex:aRow] isHidden] ? 1 : 2)] forSettingKey:@"HSObjectVisibilityAction" transitionTypeKey:nil objectUID:objectUID];
        }
    }
    [aView setNeedsDisplay:YES];
}

- (BOOL)tableView:(id)aView shouldEditTableColumn:(id)aColumn row:(NSInteger)aRow
{
    BOOL bVar2;

    if ([self HSShowHideObjectsActionAssistantPane_availableCardObjects] == nil) {
        bVar2 = NO;
    }
    else {
        if (![[aColumn identifier] isEqual:@"HSObjectActionTableColumnIdentifier"]) {
            bVar2 = [[aColumn identifier] isEqual:@"HSCheckBoxTableColumnIdentifier"];
        }
        else {
            bVar2 = YES;
        }
    }
    return bVar2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00115630 @ 00115630, 875 bytes * /

id FUN_00115630(HSShowHideObjectsActionAssistantPane *self,SEL _cmd,id tableView,
               id objectValueForTableColumn,int row)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  cfstringStruct *pcVar4;
  undefined *puVar5;
  
  pvVar1 = _objc_msgSend(self,sel_HSShowHideObjectsActionAssistantPane_availableCardObjects);
  if (pvVar1 == (id)0x0) {
LAB_00115991:
    pvVar1 = (id)0x0;
  }
  else {
    pvVar2 = _objc_msgSend(objectValueForTableColumn,sel_identifier);
    pcVar4 = &cfstr_HSObjectActionTableColumnIdentifier;
    pvVar2 = _objc_msgSend(pvVar2,sel_isEqual_,&cfstr_HSObjectActionTableColumnIdentifier);
    if ((char)pvVar2 == '\0') {
      pvVar2 = _objc_msgSend(objectValueForTableColumn,sel_identifier,pcVar4);
      pcVar4 = &cfstr_HSCheckBoxTableColumnIdentifier;
      pvVar2 = _objc_msgSend(pvVar2,sel_isEqual_,&cfstr_HSCheckBoxTableColumnIdentifier);
      if ((char)pvVar2 == '\0') {
        pvVar2 = _objc_msgSend(objectValueForTableColumn,sel_identifier,pcVar4);
        pvVar2 = _objc_msgSend(pvVar2,sel_isEqual_,&cfstr_HSObjectNameTableColumnIdentifier);
        if ((char)pvVar2 == '\0') goto LAB_00115991;
        pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,row);
        pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00370fec);
        pcVar4 = _objc_msgSend(pvVar1,sel_nonLocalizedKindName);
        puVar5 = &DAT_0037108c;
        pvVar2 = _objc_msgSend(pvVar1,sel_implementsHyperInterface_,&DAT_0037108c);
        if ((char)pvVar2 != '\0') {
          puVar5 = &DAT_0037108c;
          pvVar2 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0037108c);
          pvVar2 = _objc_msgSend(pvVar2,sel_nonLocalizedObjectKindKey);
          if (pvVar2 != (id)0x0) {
            puVar5 = &DAT_0037108c;
            pvVar2 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0037108c);
            pcVar4 = _objc_msgSend(pvVar2,sel_nonLocalizedObjectKindKey);
          }
        }
        _objc_msgSend(pvVar1,sel_hyperName,puVar5);
        op = sel_arrayForObjectWithType_name_;
      }
      else {
        pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,row);
        pvVar1 = _objc_msgSend(pvVar1,sel_hyperUID);
        pvVar2 = _objc_msgSend(self,sel_HSShowHideObjectsActionAssistantPane_applier);
        self = _objc_msgSend(pvVar2,sel_actionSettingsForObjectUID_,pvVar1);
        pcVar4 = &cfstr_HSEnableVisibility;
        op = sel_objectForKey_;
      }
    }
    else {
      pvVar2 = _objc_msgSend(pvVar1,sel_objectAtIndex_,row);
      pvVar2 = _objc_msgSend(pvVar2,sel_hyperUID);
      pvVar3 = _objc_msgSend(self,sel_HSShowHideObjectsActionAssistantPane_applier);
      pvVar2 = _objc_msgSend(pvVar3,sel_actionSettingsForObjectUID_,pvVar2);
      pcVar4 = &cfstr_HSObjectVisibilityAction;
      pvVar2 = _objc_msgSend(pvVar2,sel_objectForKey_,&cfstr_HSObjectVisibilityAction);
      pvVar3 = _objc_msgSend(pvVar2,sel_intValue);
      if (pvVar3 == (id)0x0) {
        pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,row);
        pvVar1 = _objc_msgSend(pvVar1,sel_isHidden);
        if ((char)pvVar1 == '\0') {
          pcVar4 = (cfstringStruct *)0x2;
        }
        else {
          pcVar4 = (cfstringStruct *)0x1;
        }
        pvVar2 = _objc_msgSend(cls_NSNumber,sel_numberWithInt_,pcVar4);
      }
      self = (HSShowHideObjectsActionAssistantPane *)cls_NSNumber;
      pvVar1 = _objc_msgSend(pvVar2,sel_intValue,pcVar4);
      pcVar4 = (cfstringStruct *)((int)pvVar1 + -1);
      op = sel_numberWithInt_;
    }
    pvVar1 = _objc_msgSend(self,op,pcVar4);
  }
  return pvVar1;
}

*/
- (id)tableView:(id)aView objectValueForTableColumn:(id)aColumn row:(NSInteger)aRow
{
    id objects = [self HSShowHideObjectsActionAssistantPane_availableCardObjects];
    if (objects == nil) {
        return nil;
    }
    if ([[aColumn identifier] isEqual:@"HSObjectActionTableColumnIdentifier"]) {
        id action = [[[self HSShowHideObjectsActionAssistantPane_applier] actionSettingsForObjectUID:[[objects objectAtIndex:aRow] hyperUID]] objectForKey:@"HSObjectVisibilityAction"];
        if ([action intValue] == 0) {
            action = [NSNumber numberWithInt:([[objects objectAtIndex:aRow] isHidden] ? 1 : 2)];
        }
        return [NSNumber numberWithInt:[action intValue] - 1];
    }
    if ([[aColumn identifier] isEqual:@"HSCheckBoxTableColumnIdentifier"]) {
        return [[[self HSShowHideObjectsActionAssistantPane_applier] actionSettingsForObjectUID:[[objects objectAtIndex:aRow] hyperUID]] objectForKey:@"HSEnableVisibility"];
    }
    if ([[aColumn identifier] isEqual:@"HSObjectNameTableColumnIdentifier"]) {
        id object = [[objects objectAtIndex:aRow] queryHyperInterface:@protocol(HSObjectAttributes)];
        id kind = [object nonLocalizedKindName];
        if ([object implementsHyperInterface:@protocol(HSObjectKindNameAttribute)] && [[object queryHyperInterface:@protocol(HSObjectKindNameAttribute)] nonLocalizedObjectKindKey] != nil) {
            kind = [[object queryHyperInterface:@protocol(HSObjectKindNameAttribute)] nonLocalizedObjectKindKey];
        }
        return [self arrayForObjectWithType:kind name:[object hyperName]];
    }
    return nil;
}

- (id)arrayForObjectWithType:(id)aType name:(id)aName
{
    id pvVar2;
    id pvVar1_2;
    id pvVar1_3;

    pvVar1_2 = [[self resourceNames] objectForKey:aType];
    if (pvVar1_2 == nil) {
        pvVar1_3 = nil;
        pvVar2 = nil;
    }
    else {
        pvVar2 = [self imageForObjectName:pvVar1_2 selected:YES];
        pvVar1_3 = [self imageForObjectName:pvVar1_2 selected:NO];
    }
    return [NSArray arrayWithObjects:aName, pvVar2, pvVar1_3, nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0011547a @ 0011547a, 248 bytes * /

id FUN_0011547a(HSShowHideObjectsActionAssistantPane *self,SEL _cmd,id imageForObjectName,
               BOOL selected)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  cfstringStruct *pcVar4;
  id pvVar5;
  
  pcVar4 = &cfstr__W;
  if (selected == '\0') {
    pcVar4 = &cfstr_empty;
  }
  pvVar1 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr_____,imageForObjectName,pcVar4);
  pvVar2 = _objc_msgSend(self->_objectIcons,sel_objectForKey_,pvVar1);
  if (pvVar2 == (id)0x0) {
    pvVar5 = pvVar1;
    pvVar2 = _objc_msgSend(cls_NSImage,sel_imageNamed_,pvVar1,imageForObjectName,pcVar4);
    pvVar3 = self->_objectIcons;
    if (pvVar3 == (id)0x0) {
      pvVar3 = _objc_msgSend(cls_NSMutableDictionary,sel_alloc,pvVar5,imageForObjectName,pcVar4);
      pvVar3 = _objc_msgSend(pvVar3,sel_init);
      self->_objectIcons = pvVar3;
    }
    _objc_msgSend(pvVar3,sel_setObject_forKey_,pvVar2,pvVar1,pcVar4);
  }
  return pvVar2;
}

*/
- (id)imageForObjectName:(id)aName selected:(BOOL)aSelected
{
    NSString *key = [NSString stringWithFormat:@"%@%@", aName, (aSelected ? @"_W" : @"")];
    NSImage *image = [_objectIcons objectForKey:key];
    if (image == nil) {
        image = [NSImage imageNamed:key];
        if (_objectIcons == nil) {
            _objectIcons = [[NSMutableDictionary alloc] init];
        }
        [_objectIcons setObject:image forKey:key];
    }
    return image;
}

- (id)resourceNames
{
    return [[NSDictionary dictionaryWithObjectsAndKeys:@"ShowHideObjectActionButton", @"HSButtonObject", @"ShowHideObjectActionImage", @"HSImageObject", @"ShowHideObjectActionText", @"HSSystemTextView", @"ShowHideObjectActionMovie", @"HSMovieObject", @"ShowHideObjectActionMovie", @"HSLiveObject", @"ShowHideObjectActionBrush", @"Brush Stroke", @"ShowHideObjectActionBrush", @"Spray Can Stroke", @"ShowHideObjectActionBrush", @"Pencil", @"ShowHideObjectActionLine", @"Line", @"ShowHideObjectActionShape", @"HSVectorGraphicsObject", @"ShowHideObjectActionShape", @"Rectangle", @"ShowHideObjectActionShape", @"RoundedRectangle", @"ShowHideObjectActionShape", @"Circle", nil] retain];
}

- (NSInteger)numberOfRowsInTableView:(id)aView
{
    return (int)[[self HSShowHideObjectsActionAssistantPane_availableCardObjects] count];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00117f0d @ 00117f0d, 577 bytes * /

void FUN_00117f0d(HSShowHideObjectsActionAssistantPane *self,SEL _cmd)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  undefined1 local_34 [16];
  undefined1 local_24 [20];
  
  puVar1 = cls_NSBundle;
  pvVar2 = _objc_msgSend(self,sel_class);
  pvVar2 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar2);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                         &cfstr_HSObjectTableHeaderTooltip,&cfstr_empty,&cfstr_AssistantPanes);
  pvVar3 = _objc_msgSend(self->_objectsTableView,sel_headerView);
  pvVar4 = _objc_msgSend(self->_objectsTableView,sel_headerView);
  pvVar5 = _objc_msgSend(self->_objectsTableView,sel_columnWithIdentifier_,
                         &cfstr_HSObjectNameTableColumnIdentifier);
  _objc_msgSend_stret(local_34,pvVar4,sel_headerRectOfColumn_,pvVar5);
  _objc_msgSend(pvVar3,sel_addToolTipRect_owner_userData_,(int)local_34._0_8_,
                SUB84(local_34._0_8_,4),(int)local_34._8_8_,SUB84(local_34._8_8_,4),pvVar2,0);
  puVar1 = cls_NSBundle;
  pvVar2 = _objc_msgSend(self,sel_class);
  pvVar2 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar2);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                         &cfstr_HSActionTableHeaderTooltip,&cfstr_empty,&cfstr_AssistantPanes);
  pvVar3 = _objc_msgSend(self->_objectsTableView,sel_headerView);
  pvVar4 = _objc_msgSend(self->_objectsTableView,sel_headerView);
  pvVar5 = _objc_msgSend(self->_objectsTableView,sel_columnWithIdentifier_,
                         &cfstr_HSObjectActionTableColumnIdentifier);
  _objc_msgSend_stret(local_24,pvVar4,sel_headerRectOfColumn_,pvVar5);
  _objc_msgSend(pvVar3,sel_addToolTipRect_owner_userData_,(int)local_24._0_8_,
                SUB84(local_24._0_8_,4),(int)local_24._8_8_,SUB84(local_24._8_8_,4),pvVar2,0);
  return;
}

*/
- (void)HSShowHideObjectsActionAssistantPane_addTableHeaderToolTips
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSTableHeaderView *header = [_objectsTableView headerView];
    [header addToolTipRect:[header headerRectOfColumn:[_objectsTableView columnWithIdentifier:@"HSObjectNameTableColumnIdentifier"]] owner:[bundle localizedStringForKey:@"HSObjectTableHeaderTooltip" value:@"" table:@"AssistantPanes"] userData:NULL];
    [header addToolTipRect:[header headerRectOfColumn:[_objectsTableView columnWithIdentifier:@"HSObjectActionTableColumnIdentifier"]] owner:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"HSActionTableHeaderTooltip" value:@"" table:@"AssistantPanes"] userData:NULL];
}

- (id)helpTopicKey
{
    return @"HSMultipleHide";
}

- (void)HSShowHideObjectsActionAssistantPane_hideTransitionView:(id)aView
{
    id self_00;

    if (_showEffectTransitionPreview == aView)
    {
        [_showEffectTransitionPreview setHidden:YES];
        self_00 = _showEffectTransitionImageView;
    }
    else {
        if (_hideEffectTransitionPreview != aView) {
            return;
        }
        [_hideEffectTransitionPreview setHidden:YES];
        self_00 = _hideEffectTransitionImageView;
    }
    [self_00 setHidden:NO];
}

- (Class)applierClass
{
    return [HSShowHideObjectsActionAssistantPaneApplier class];
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [self removeActionAssistantPaneObserver];
    [self setStack:nil];
    [_availableObjects release];
    _availableObjects = nil;
    [[_objectsTableView headerView] removeAllToolTips];
    [super viewWillDisappear:aDisappear];
}

- (void)viewDidAppear:(BOOL)aAppear
{
    [super viewDidAppear:aAppear];
    [[self window] makeFirstResponder:_objectsTableView];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00118270 @ 00118270, 813 bytes * /

void FUN_00118270(HSShowHideObjectsActionAssistantPane *self,SEL _cmd,BOOL viewWillAppear)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id self_00;
  cfstringStruct *pcVar4;
  id local_20;
  HSShowHideObjectsActionAssistantPane *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSActionAssistantPane_00350ff0;
  _objc_msgSendSuper(&local_1c,sel_viewWillAppear_,(int)viewWillAppear);
  _objc_msgSend(self,sel_addActionAssistantPaneObserver);
  _objc_msgSend(self,sel_stack);
  pvVar1 = _objc_msgSend(self,sel_HSShowHideObjectsActionAssistantPane_applier);
  pvVar2 = _objc_msgSend(self->_showEffectTransitionPopup,sel_itemAtIndex_,0);
  pvVar2 = _objc_msgSend(pvVar2,sel_representedObject);
  _objc_msgSend(pvVar1,sel_setDefaultTransitionName_,pvVar2);
  pvVar1 = _objc_msgSend(self,sel_HSShowHideObjectsActionAssistantPane_applier);
  pcVar4 = (cfstringStruct *)0x0;
  _objc_msgSend(pvVar1,sel_setDefaultTransitionDuration_,0,0);
  _objc_msgSend(self,sel_HSShowHideObjectsActionAssistantPane_addTableHeaderToolTips);
  _objc_msgSend(self->_objectsTableView,sel_reloadData);
  pvVar1 = _objc_msgSend(self,sel_HSShowHideObjectsActionAssistantPane_availableCardObjects);
  local_20 = (id)0x0;
  pvVar2 = _objc_msgSend(pvVar1,sel_count);
  do {
    if (pvVar2 <= local_20) {
LAB_00118464:
      pvVar1 = _objc_msgSend(self,sel_HSShowHideObjectsActionAssistantPane_availableCardObjects,
                             pcVar4);
      pvVar2 = _objc_msgSend(self,sel_assistant);
      pvVar2 = _objc_msgSend(pvVar2,sel_object);
      local_20 = _objc_msgSend(pvVar1,sel_indexOfObject_,pvVar2);
      if (local_20 == (id)0x7fffffff) {
        local_20 = (id)0x0;
      }
LAB_001184c8:
      pvVar1 = self->_objectsTableView;
      pvVar2 = _objc_msgSend(cls_NSIndexSet,sel_indexSetWithIndex_,local_20);
      _objc_msgSend(pvVar1,sel_selectRowIndexes_byExtendingSelection_,pvVar2,0);
      _objc_msgSend(self->_objectsTableView,sel_scrollRowToVisible_,local_20);
      _objc_msgSend(self->_showEffectSpeedSlider,sel_setDoubleValue_,0,0);
      _objc_msgSend(self->_hideEffectSpeedSlider,sel_setDoubleValue_,0,0);
      _objc_msgSend(self,sel_validateUI);
      return;
    }
    pvVar3 = _objc_msgSend(pvVar1,sel_objectAtIndex_,local_20);
    self_00 = _objc_msgSend(self,sel_HSShowHideObjectsActionAssistantPane_applier);
    pvVar3 = _objc_msgSend(pvVar3,sel_hyperUID);
    pvVar3 = _objc_msgSend(self_00,sel_actionSettingsForObjectUID_,pvVar3);
    pcVar4 = &cfstr_HSEnableVisibility;
    pvVar3 = _objc_msgSend(pvVar3,sel_objectForKey_,&cfstr_HSEnableVisibility);
    pvVar3 = _objc_msgSend(pvVar3,sel_boolValue);
    if ((char)pvVar3 != '\0') {
      if (local_20 != (id)0x7fffffff) goto LAB_001184c8;
      goto LAB_00118464;
    }
    local_20 = (id)((int)local_20 + 1);
  } while( true );
}

*/
- (void)viewWillAppear:(BOOL)aAppear
{
    id objects;
    NSUInteger count;
    NSUInteger index;
    [super viewWillAppear:aAppear];
    [self addActionAssistantPaneObserver];
    [self stack];
    [[self HSShowHideObjectsActionAssistantPane_applier] setDefaultTransitionName:[[_showEffectTransitionPopup itemAtIndex:0] representedObject]];
    [[self HSShowHideObjectsActionAssistantPane_applier] setDefaultTransitionDuration:0.0];
    [self HSShowHideObjectsActionAssistantPane_addTableHeaderToolTips];
    [_objectsTableView reloadData];
    objects = [self HSShowHideObjectsActionAssistantPane_availableCardObjects];
    count = [objects count];
    // Select the first checked object, else the assistant's own object.
    for (index = 0; index < count; index++) {
        if ([[[[self HSShowHideObjectsActionAssistantPane_applier] actionSettingsForObjectUID:[[objects objectAtIndex:index] hyperUID]] objectForKey:@"HSEnableVisibility"] boolValue]) {
            break;
        }
    }
    if (index >= count) {
        index = [[self HSShowHideObjectsActionAssistantPane_availableCardObjects] indexOfObject:[[self assistant] object]];
        if (index == NSNotFound) {
            index = 0;
        }
    }
    [_objectsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
    [_objectsTableView scrollRowToVisible:index];
    [_showEffectSpeedSlider setDoubleValue:0.0];
    [_hideEffectSpeedSlider setDoubleValue:0.0];
    [self validateUI];
}

- (id)actionAttribute
{
    return (id)@protocol(HSShowHideObjectActionAttributes);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0011859d @ 0011859d, 2018 bytes * /

void FUN_0011859d(HSShowHideObjectsActionAssistantPane *self,SEL _cmd)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  cfstringStruct *pcVar7;
  undefined4 extraout_EDX;
  id pvVar8;
  double dVar9;
  cfstringStruct *pcVar10;
  cfstringStruct *pcVar11;
  undefined4 uVar12;
  HSShowHideObjectsActionAssistantPane *local_2c;
  undefined *local_28;
  undefined1 local_24 [8];
  undefined4 local_1c;
  undefined4 local_18;
  
  local_2c = self;
  local_28 = PTR_s_HSActionAssistantPane_00350ff0;
  _objc_msgSendSuper(&local_2c,sel_viewDidLoad);
  _objc_msgSend(self->_showEffectTransitionPopup,sel_removeAllItems);
  _objc_msgSend(self->_hideEffectTransitionPopup,sel_removeAllItems);
  pvVar2 = _objc_msgSend(cls_HSTransitionEffectProvider,sel_sharedTransitionEffectProvider);
  pvVar3 = _objc_msgSend(pvVar2,sel_transitionEffectNames);
  pvVar4 = _objc_msgSend(pvVar3,sel_count);
  for (pvVar8 = (id)0x0; pvVar8 < pvVar4; pvVar8 = (id)((int)pvVar8 + 1)) {
    pvVar5 = _objc_msgSend(pvVar3,sel_objectAtIndex_,pvVar8);
    pvVar6 = _objc_msgSend(pvVar2,sel_displayNameForTransitionEffectWithName_,pvVar5);
    if (pvVar6 == (id)0x0) break;
    _objc_msgSend(self->_showEffectTransitionPopup,sel_addItemWithTitle_,pvVar6);
    _objc_msgSend(self->_hideEffectTransitionPopup,sel_addItemWithTitle_,pvVar6);
    pvVar6 = _objc_msgSend(self->_showEffectTransitionPopup,sel_itemAtIndex_,pvVar8);
    _objc_msgSend(pvVar6,sel_setRepresentedObject_,pvVar5);
    pvVar6 = _objc_msgSend(self->_hideEffectTransitionPopup,sel_itemAtIndex_,pvVar8);
    _objc_msgSend(pvVar6,sel_setRepresentedObject_,pvVar5);
  }
  pvVar2 = _objc_msgSend(cls_NSPopUpButtonCell,sel_alloc);
  pvVar3 = _objc_msgSend(cls_NSString,sel_string);
  pvVar2 = _objc_msgSend(pvVar2,sel_initTextCell_pullsDown_,pvVar3,0);
  _objc_msgSend(pvVar2,sel_setMenu_,self->_actionMenu);
  _objc_msgSend(pvVar2,sel_setBordered_,0);
  _objc_msgSend(pvVar2,sel_setWraps_,0);
  pvVar3 = _objc_msgSend(self->_objectsTableView,sel_tableColumnWithIdentifier_,
                         &cfstr_HSObjectActionTableColumnIdentifier);
  _objc_msgSend(pvVar3,sel_setDataCell_,pvVar2);
  pvVar3 = _objc_msgSend(pvVar3,sel_dataCell);
  puVar1 = cls_NSFont;
  dVar9 = _objc_msgSend_fpret(cls_NSFont,sel_smallSystemFontSize);
  pvVar4 = _objc_msgSend(puVar1,sel_systemFontOfSize_,(float)dVar9);
  _objc_msgSend(pvVar3,sel_setFont_,pvVar4);
  _objc_msgSend(pvVar2,sel_release);
  _objc_msgSend(self->_showEffectSpeedSlider,sel_setMinValue_,0,0);
  _objc_msgSend(self->_showEffectSpeedSlider,sel_setMaxValue_,0,0x3ff80000);
  _objc_msgSend(self->_hideEffectSpeedSlider,sel_setMinValue_,0,0);
  _objc_msgSend(self->_hideEffectSpeedSlider,sel_setMaxValue_,0,0x3ff80000);
  pvVar2 = _objc_msgSend(self->_objectsTableView,sel_tableColumnWithIdentifier_,
                         &cfstr_HSCheckBoxTableColumnIdentifier);
  pvVar3 = _objc_msgSend(cls_HSCheckBoxCell,sel_alloc);
  pvVar3 = _objc_msgSend(pvVar3,sel_initTextCell_,&cfstr_empty);
  pvVar3 = _objc_msgSend(pvVar3,sel_autorelease);
  _objc_msgSend(pvVar3,sel_setButtonType_,3);
  _objc_msgSend(pvVar3,sel_setControlSize_,1);
  puVar1 = cls_NSFont;
  dVar9 = _objc_msgSend_fpret(cls_NSFont,sel_smallSystemFontSize);
  pvVar4 = _objc_msgSend(puVar1,sel_systemFontOfSize_,(float)dVar9);
  _objc_msgSend(pvVar3,sel_setFont_,pvVar4);
  _objc_msgSend(pvVar3,sel_performSelector_,sel_applyDefaultSettings);
  _objc_msgSend(pvVar2,sel_setDataCell_,pvVar3);
  _objc_msgSend(self->_showEffectTransitionPreview,sel_enableOpenGLSurface);
  _objc_msgSend(self->_showEffectTransitionPreview,sel_setScalesImagesToFit_,1);
  _objc_msgSend(self->_showEffectTransitionPreview,sel_setDelegate_,self);
  _objc_msgSend(self->_hideEffectTransitionPreview,sel_enableOpenGLSurface);
  _objc_msgSend(self->_hideEffectTransitionPreview,sel_setScalesImagesToFit_,1);
  _objc_msgSend(self->_hideEffectTransitionPreview,sel_setDelegate_,self);
  puVar1 = cls_NSBundle;
  pvVar2 = _objc_msgSend(self,sel_class);
  pvVar3 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar2);
  pvVar2 = self->_showEffectTransitionPreview;
  _objc_msgSend_stret(local_24,pvVar2,sel_bounds);
  uVar12 = 0;
  pcVar7 = _objc_msgSend(pvVar2,sel_convertSize_toView_,local_1c,local_18,0);
  pcVar11 = &cfstr_png;
  pcVar10 = pcVar11;
  pvVar4 = _objc_msgSend(pvVar3,sel_hyperCoreGraphicsImageFromResource_ofType_,
                         &cfstr_Transition_start,&cfstr_png);
  pvVar2 = (id)0x0;
  if (pvVar4 != (id)0x0) {
    pcVar10 = pcVar7;
    uVar12 = extraout_EDX;
    pvVar2 = _objc_msgSend(self,sel_HSShowHideObjectsActionAssistantPane_copyImage_scalingToSize_,
                           pvVar4,pcVar7,extraout_EDX);
  }
  _objc_msgSend(self->_showEffectTransitionPreview,sel_setStartImage_,pvVar2,pcVar10,uVar12);
  _objc_msgSend(self->_hideEffectTransitionPreview,sel_setStartImage_,pvVar2);
  _CGImageRelease(pvVar2);
  pvVar3 = _objc_msgSend(pvVar3,sel_hyperCoreGraphicsImageFromResource_ofType_,&cfstr_Transition_end
                         ,&cfstr_png);
  pvVar2 = (id)0x0;
  if (pvVar3 != (id)0x0) {
    uVar12 = extraout_EDX;
    pvVar2 = _objc_msgSend(self,sel_HSShowHideObjectsActionAssistantPane_copyImage_scalingToSize_,
                           pvVar3,pcVar7,extraout_EDX);
    pcVar11 = pcVar7;
  }
  _objc_msgSend(self->_showEffectTransitionPreview,sel_setEndImage_,pvVar2,pcVar11,uVar12);
  _objc_msgSend(self->_hideEffectTransitionPreview,sel_setEndImage_,pvVar2);
  _CGImageRelease(pvVar2);
  return;
}

*/
- (void)viewDidLoad
{
    id provider;
    id names;
    NSUInteger count;
    NSUInteger i;
    NSPopUpButtonCell *actionCell;
    id column;
    HSCheckBoxCell *checkBox;
    NSBundle *bundle;
    NSSize size;
    CGImageRef source;
    CGImageRef image;
    [super viewDidLoad];
    [_showEffectTransitionPopup removeAllItems];
    [_hideEffectTransitionPopup removeAllItems];
    provider = [HSTransitionEffectProvider sharedTransitionEffectProvider];
    names = [provider transitionEffectNames];
    count = [names count];
    for (i = 0; i < count; i++) {
        id name = [names objectAtIndex:i];
        id displayName = [provider displayNameForTransitionEffectWithName:name];
        if (displayName == nil) {
            break;
        }
        [_showEffectTransitionPopup addItemWithTitle:displayName];
        [_hideEffectTransitionPopup addItemWithTitle:displayName];
        [[_showEffectTransitionPopup itemAtIndex:i] setRepresentedObject:name];
        [[_hideEffectTransitionPopup itemAtIndex:i] setRepresentedObject:name];
    }
    actionCell = [[NSPopUpButtonCell alloc] initTextCell:[NSString string] pullsDown:NO];
    [actionCell setMenu:_actionMenu];
    [actionCell setBordered:NO];
    [actionCell setWraps:NO];
    column = [_objectsTableView tableColumnWithIdentifier:@"HSObjectActionTableColumnIdentifier"];
    [column setDataCell:actionCell];
    [[column dataCell] setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
    [actionCell release];
    [_showEffectSpeedSlider setMinValue:0.0];
    [_showEffectSpeedSlider setMaxValue:1.5];
    [_hideEffectSpeedSlider setMinValue:0.0];
    [_hideEffectSpeedSlider setMaxValue:1.5];
    column = [_objectsTableView tableColumnWithIdentifier:@"HSCheckBoxTableColumnIdentifier"];
    checkBox = [[[HSCheckBoxCell alloc] initTextCell:@""] autorelease];
    [checkBox setButtonType:NSSwitchButton];
    [checkBox setControlSize:NSControlSizeSmall];
    [checkBox setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
    [checkBox performSelector:@selector(applyDefaultSettings)];
    [column setDataCell:checkBox];
    [_showEffectTransitionPreview enableOpenGLSurface];
    [_showEffectTransitionPreview setScalesImagesToFit:YES];
    [_showEffectTransitionPreview setDelegate:self];
    [_hideEffectTransitionPreview enableOpenGLSurface];
    [_hideEffectTransitionPreview setScalesImagesToFit:YES];
    [_hideEffectTransitionPreview setDelegate:self];
    bundle = [NSBundle bundleForClass:[self class]];
    size = [_showEffectTransitionPreview convertSize:[_showEffectTransitionPreview bounds].size toView:nil];
    source = [bundle hyperCoreGraphicsImageFromResource:@"Transition_start" ofType:@"png"];
    image = NULL;
    if (source != NULL) {
        image = [self HSShowHideObjectsActionAssistantPane_copyImage:source scalingToSize:size];
    }
    [_showEffectTransitionPreview setStartImage:(id)image];
    [_hideEffectTransitionPreview setStartImage:(id)image];
    CGImageRelease(image);
    source = [bundle hyperCoreGraphicsImageFromResource:@"Transition_end" ofType:@"png"];
    image = NULL;
    if (source != NULL) {
        image = [self HSShowHideObjectsActionAssistantPane_copyImage:source scalingToSize:size];
    }
    [_showEffectTransitionPreview setEndImage:(id)image];
    [_hideEffectTransitionPreview setEndImage:(id)image];
    CGImageRelease(image);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00118d7f @ 00118d7f, 478 bytes * /

CGImage * FUN_00118d7f(HSShowHideObjectsActionAssistantPane *self,SEL _cmd,
                      CGImage *HSShowHideObjectsActionAssistantPane_copyImage,NSSize scalingToSize)

{
  int iVar1;
  int iVar2;
  int iVar3;
  CGImage *pCVar4;
  undefined4 uVar5;
  uint uVar6;
  int iVar7;
  longdouble lVar8;
  
  if (0.0 < scalingToSize.width) {
    lVar8 = (longdouble)_ceilf(scalingToSize.width);
    iVar1 = _lroundf((float)lVar8);
    if ((iVar1 != 0) && (0.0 < scalingToSize.height)) {
      lVar8 = (longdouble)_ceilf(scalingToSize.height);
      iVar2 = _lroundf((float)lVar8);
      if (iVar2 != 0) {
        iVar3 = _CGImageGetWidth(HSShowHideObjectsActionAssistantPane_copyImage);
        if ((iVar3 == iVar1) &&
           (iVar3 = _CGImageGetHeight(HSShowHideObjectsActionAssistantPane_copyImage),
           iVar3 == iVar2)) {
          pCVar4 = (CGImage *)_CGImageRetain(HSShowHideObjectsActionAssistantPane_copyImage);
          return pCVar4;
        }
        uVar6 = iVar1 * 4 + 0xfU & 0xfffffff0;
        iVar7 = iVar2 * uVar6;
        iVar3 = _CFDataCreateMutable(*(undefined4 *)PTR_003363a4,iVar7);
        if (iVar3 != 0) {
          _CFDataSetLength(iVar3,iVar7);
          iVar7 = _CGColorSpaceCreateDeviceRGB();
          if (iVar7 != 0) {
            uVar5 = _CFDataGetMutableBytePtr(iVar3);
            iVar1 = _CGBitmapContextCreate
                              (uVar5,iVar1,iVar2,8,uVar6,iVar7,
                               "m/Library/Frameworks/AudioToolbox.framework/Versions/A/AudioToolbox"
                              );
            _CGColorSpaceRelease(iVar7);
            if (iVar1 != 0) {
              _CGContextDrawImage(iVar1,0,scalingToSize,
                                  HSShowHideObjectsActionAssistantPane_copyImage);
              iVar2 = _CGDataProviderCreateWithCFData(iVar3);
              if (iVar2 != 0) {
                pCVar4 = (CGImage *)_CGEImageCreateAsBitmapContext(iVar1,iVar2,0,1,0);
                _CGContextRelease(iVar1);
                _CGDataProviderRelease(iVar2);
                _CFRelease(iVar3);
                return pCVar4;
              }
              _CGContextRelease(iVar1);
            }
          }
          _CFRelease(iVar3);
        }
      }
    }
  }
  return (CGImage *)0x0;
}

*/
- (struct CGImage *)HSShowHideObjectsActionAssistantPane_copyImage:(struct CGImage *)aImage scalingToSize:(NSSize)aSize
{
    long width;
    long height;
    size_t bytesPerRow;
    CFMutableDataRef data;
    CGColorSpaceRef colorSpace;
    CGContextRef context;
    CGDataProviderRef provider;
    CGImageRef image;
    if (!(aSize.width > 0.0f) || (width = lroundf(ceilf(aSize.width))) == 0) {
        return NULL;
    }
    if (!(aSize.height > 0.0f) || (height = lroundf(ceilf(aSize.height))) == 0) {
        return NULL;
    }
    if ((long)CGImageGetWidth(aImage) == width && (long)CGImageGetHeight(aImage) == height) {
        return CGImageRetain(aImage);
    }
    bytesPerRow = (width * 4 + 15) & ~(size_t)15;
    data = CFDataCreateMutable(kCFAllocatorDefault, height * bytesPerRow);
    if (data == NULL) {
        return NULL;
    }
    CFDataSetLength(data, height * bytesPerRow);
    colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL) {
        CFRelease(data);
        return NULL;
    }
    context = CGBitmapContextCreate(CFDataGetMutableBytePtr(data), width, height, 8, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
    CGColorSpaceRelease(colorSpace);
    if (context == NULL) {
        CFRelease(data);
        return NULL;
    }
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, aSize.width, aSize.height), aImage);
    provider = CGDataProviderCreateWithCFData(data);
    if (provider == NULL) {
        CGContextRelease(context);
        CFRelease(data);
        return NULL;
    }
    image = CGEImageCreateAsBitmapContext(context, provider, NULL, true, kCGRenderingIntentDefault);
    CGContextRelease(context);
    CGDataProviderRelease(provider);
    CFRelease(data);
    return image;
}

- (id)actionType
{
    return [HSShowHideObjectAction actionType];
}

- (void)dealloc
{
    [_showEffectTransitionPreview setDelegate:0];
    [_hideEffectTransitionPreview setDelegate:0];
    [self setStack:nil];
    [_availableObjects release];
    [_actionMenu release];
    [[_objectsTableView headerView] removeAllToolTips];
    [_objectIcons release];
    [_resourceNames release];
    [_lastUserChosenShowTransitionName release];
    [_lastUserChosenHideTransitionName release];
    [super dealloc];
}

- (void)awakeFromNib
{
    [_objectsTableView setFocusRingType:1];
}

- (id)init
{
    self = [super initWithNibName:@"ShowHideObjectsAssistantPane"];
    return self;
}

@end

@implementation HSShowHideObjectsActionAssistantPaneApplier

/* i386 ivar offsets: _actionSettings=0x30, _modifiedActionSettings=0x34, _defaultTransitionName=0x38, _defaultTransitionDuration=0x3c */

- (void)HSShowHideObjectsActionAssistantPaneApplier_applySettings:(id)aSettings
{
    id self_00;
    NSEnumerator *self_01;
    id pvVar1;
    id pvVar2;
    BOOL pvVar6;
    NSInteger pvVar2_3;
    id pvVar3_2;
    id pvVar4_2;
    int pvVar5_2;

    self_00 = [self showHideActionAttributes];
    self_01 = [aSettings keyEnumerator];
    if ((self_00 != nil) && (self_01 != nil)) {
        pvVar1 = [self_01 nextObject];
        while (pvVar1 != nil) {
            pvVar2 = [aSettings objectForKey:pvVar1];
            pvVar3_2 = [self checkAndCorrectEffectSettings:[pvVar2 objectForKey:@"HSObjectShowEffectTransition"]];
            pvVar4_2 = [self checkAndCorrectEffectSettings:[pvVar2 objectForKey:@"HSObjectHideEffectTransition"]];
            pvVar5_2 = [[pvVar2 objectForKey:@"HSObjectVisibilityAction"] intValue];
            pvVar6 = [[pvVar2 objectForKey:@"HSEnableVisibility"] boolValue];
            pvVar2_3 = 0;
            if (pvVar6) {
                pvVar2_3 = pvVar5_2;
            }
            [self_00 addObjectUID:pvVar1 action:pvVar2_3 showEffectSettings:pvVar3_2 hideEffectSettings:pvVar4_2];
            pvVar1 = [self_01 nextObject];
        }
    }
}

- (void)synchronizeWithAction
{
    [self disableUndo];
    [self HSShowHideObjectsActionAssistantPaneApplier_applySettings:_modifiedActionSettings];
    [self enableUndo];
}

- (BOOL)conditionalEqualObjectSettings:(id)aSettings toOther:(id)aOther
{
    unsigned char bVar5;
    BOOL pvVar1_2;
    BOOL pvVar2_3;
    id pvVar3_2;
    BOOL pvVar3_3;
    id pvVar4_2;

    pvVar1_2 = [[aSettings objectForKey:@"HSObjectShowEffectTransition"] isEqualToDictionary:[aOther objectForKey:@"HSObjectShowEffectTransition"]];
    pvVar2_3 = [[aSettings objectForKey:@"HSObjectHideEffectTransition"] isEqualToDictionary:[aOther objectForKey:@"HSObjectHideEffectTransition"]];
    pvVar3_2 = [aSettings objectForKey:@"HSEnableVisibility"]
    ;
    pvVar3_3 = [pvVar3_2 isEqual:[aOther objectForKey:@"HSEnableVisibility"]];
    pvVar4_2 = [aSettings objectForKey:@"HSEnableVisibility"]
    ;
    bVar5 = pvVar2_3 & pvVar1_2 & pvVar3_3;
    if ([pvVar4_2 boolValue]) {
        if ([[aOther objectForKey:@"HSEnableVisibility"] boolValue]) {
            bVar5 = bVar5 & [[aSettings objectForKey:@"HSObjectVisibilityAction"] isEqual:[aOther objectForKey:@"HSObjectVisibilityAction"]];
        }
    }
    return bVar5 != 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00116c09 @ 00116c09, 383 bytes * /

BOOL FUN_00116c09(HSShowHideObjectsActionAssistantPaneApplier *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  char cVar5;
  uint uVar6;
  HSShowHideObjectsActionAssistantPaneApplier *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSActionAssistantSettingsApplier_00350fc0;
  pvVar1 = _objc_msgSendSuper(&local_1c,sel_areSettingsEqual);
  pvVar2 = self->_actionSettings;
  if ((pvVar2 == (id)0x0) || (self->_modifiedActionSettings == (id)0x0)) {
    if ((char)pvVar1 != '\0') {
      uVar6 = (uint)pvVar1 & 0xff;
LAB_00116c9a:
      pvVar2 = _objc_msgSend(pvVar2,sel_keyEnumerator);
      pvVar1 = _objc_msgSend(self->_modifiedActionSettings,sel_keyEnumerator);
      if (pvVar1 == (id)0x0) {
        return (BOOL)uVar6;
      }
      if (pvVar2 == (id)0x0) {
        return (BOOL)uVar6;
      }
LAB_00116d41:
      cVar5 = (char)uVar6;
      pvVar3 = _objc_msgSend(pvVar2,sel_nextObject);
      if (pvVar3 == (id)0x0) {
        return cVar5;
      }
      pvVar4 = _objc_msgSend(pvVar1,sel_nextObject);
      if (pvVar4 == (id)0x0) {
        return cVar5;
      }
      if (cVar5 != '\0') goto code_r0x00116ce2;
      goto LAB_00116d3f;
    }
  }
  else if ((char)pvVar1 != '\0') {
    pvVar2 = _objc_msgSend(pvVar2,sel_count);
    pvVar1 = _objc_msgSend(self->_modifiedActionSettings,sel_count);
    if (pvVar2 == pvVar1) {
      pvVar2 = self->_actionSettings;
      uVar6 = 1;
      goto LAB_00116c9a;
    }
  }
  return '\0';
code_r0x00116ce2:
  pvVar4 = _objc_msgSend(self->_modifiedActionSettings,sel_objectForKey_,pvVar4);
  pvVar3 = _objc_msgSend(self->_actionSettings,sel_objectForKey_,pvVar3);
  pvVar3 = _objc_msgSend(self,sel_conditionalEqualObjectSettings_toOther_,pvVar3,pvVar4);
  uVar6 = 1;
  if ((char)pvVar3 == '\0') {
LAB_00116d3f:
    uVar6 = 0;
  }
  goto LAB_00116d41;
}

*/
- (BOOL)areSettingsEqual
{
    BOOL equal = [super areSettingsEqual];
    NSEnumerator *keys;
    NSEnumerator *modifiedKeys;
    id key;
    id modifiedKey;
    if (_actionSettings != nil && _modifiedActionSettings != nil) {
        if (!equal || [_actionSettings count] != [_modifiedActionSettings count]) {
            return NO;
        }
    }
    else if (!equal) {
        return NO;
    }
    keys = [_actionSettings keyEnumerator];
    modifiedKeys = [_modifiedActionSettings keyEnumerator];
    if (modifiedKeys == nil || keys == nil) {
        return equal;
    }
    // Keys are paired in enumeration order, as in the original.
    while ((key = [keys nextObject]) != nil && (modifiedKey = [modifiedKeys nextObject]) != nil) {
        if (equal) {
            equal = [self conditionalEqualObjectSettings:[_actionSettings objectForKey:key] toOther:[_modifiedActionSettings objectForKey:modifiedKey]];
        }
    }
    return equal;
}

- (void)makeCurrentEqualToInitial
{
    [super makeCurrentEqualToInitial];
    [_modifiedActionSettings release];
    _modifiedActionSettings = nil;
}

- (void)makeInitialEqualToCurrent
{
    [super makeInitialEqualToCurrent];
    [_actionSettings release];
    _actionSettings = [_modifiedActionSettings mutableCopy];
}

- (void)setInitialSettingsToObject
{
    [self HSShowHideObjectsActionAssistantPaneApplier_applySettings:_actionSettings];
    [super setInitialSettingsToObject];
}

- (void)setCurrentSettingsToObject
{
    [super setCurrentSettingsToObject];
    [self HSShowHideObjectsActionAssistantPaneApplier_applySettings:_modifiedActionSettings];
}

- (id)checkAndCorrectEffectSettings:(id)aSettings
{
    if ([aSettings objectForKey:@"HSShowHideTransitionName"] == nil) {
        [aSettings setObject:_defaultTransitionName forKey:@"HSShowHideTransitionName"];
    }
    if ([aSettings objectForKey:@"HSShowHideTransitionDuration"] == nil) {
        [aSettings setObject:[NSNumber numberWithDouble:_defaultTransitionDuration] forKey:@"HSShowHideTransitionDuration"];
    }
    return aSettings;
}

- (void)setValue:(id)aValue forSettingKey:(id)aKey transitionTypeKey:(id)aKey2 objectUID:(id)aUID
{
    id pvVar1;
    id pvVar1_2;

    pvVar1 = _modifiedActionSettings;
    if (pvVar1 == nil) {
        pvVar1 = [NSMutableDictionary new];
        _modifiedActionSettings = pvVar1;
    }
    pvVar1_2 = [pvVar1 objectForKey:aUID];
    if (pvVar1_2 == nil) {
        pvVar1_2 = [[[self actionSettingsForObjectUID:aUID] NSE_mutableCopyToDepth:1 zone:[self zone]] autorelease];
        [_modifiedActionSettings setObject:pvVar1_2 forKey:aUID];
    }
    if (aKey2 != nil) {
        pvVar1_2 = [pvVar1_2 objectForKey:aKey2];
    }
    [pvVar1_2 setObject:aValue forKey:aKey];
    [self synchronizeWithAction];
}

- (id)actionSettingsForObjectUID:(id)aUID
{
    id pvVar2;
    id pvVar3_3;
    id pvVar2_2;
    NSNumber *pvVar2_6;
    id pvVar4_2;
    id pvVar5_2;

    pvVar2 = [_modifiedActionSettings objectForKey:aUID]
    ;
    if (pvVar2 == nil) {
        pvVar2_2 = _actionSettings;
        if (pvVar2_2 == nil) {
            pvVar2_2 = [NSMutableDictionary new];
            _actionSettings = pvVar2_2;
        }
        pvVar2 = [pvVar2_2 objectForKey:aUID];
    }
    if (pvVar2 == nil) {
        pvVar3_3 = [self showHideActionAttributes];
        if (pvVar3_3 != nil) {
            pvVar4_2 = [[pvVar3_3 showEffectSettingsWithUID:aUID] mutableCopy];
            if (pvVar4_2 == nil) {
                pvVar4_2 = [NSMutableDictionary new];
            }
            pvVar5_2 = [[pvVar3_3 hideEffectSettingsWithUID:aUID] mutableCopy];
            if (pvVar5_2 == nil) {
                pvVar5_2 = [NSMutableDictionary new];
            }
            pvVar2_6 = [NSNumber numberWithBool:(unsigned int)([pvVar3_3 actionForObjectWithUID:aUID] != 0)];
            pvVar2 = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[pvVar3_3 actionForObjectWithUID:aUID]], @"HSObjectVisibilityAction", pvVar2_6, @"HSEnableVisibility", pvVar4_2, @"HSObjectShowEffectTransition", pvVar5_2, @"HSObjectHideEffectTransition", nil];
            [pvVar4_2 release];
            [pvVar5_2 release];
        }
        [_actionSettings setObject:pvVar2 forKey:aUID];
    }
    return pvVar2;
}

- (void)setDefaultTransitionDuration:(double)aDuration
{
    double dVar1;
    double dVar2;
    double dVar3;

    dVar1 = _defaultTransitionDuration;
    dVar2 = aDuration != 0.0 ? fabs(aDuration) : 1.0;
    dVar3 = dVar1 != 0.0 ? fabs(dVar1) : 1.0;
    if (dVar3 <= dVar2) {
        dVar3 = dVar2;
    }
    if (dVar3 * 1e-05 < fabs(aDuration - dVar1)) {
        _defaultTransitionDuration = aDuration;
        [self synchronizeWithAction];
    }
}

- (void)setDefaultTransitionName:(id)aName
{
    if (_defaultTransitionName != aName) {
        [_defaultTransitionName release];
        _defaultTransitionName = [aName retain];
        [self synchronizeWithAction];
    }
}

- (id)showHideActionAttributes
{
    return [[self actionAttributes] queryHyperInterface:@protocol(HSShowHideObjectActionAttributes)];
}

- (void)dealloc
{
    [_actionSettings release];
    [_modifiedActionSettings release];
    [_defaultTransitionName release];
    [super dealloc];
}

@end

