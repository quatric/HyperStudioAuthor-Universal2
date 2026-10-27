#import "HSAEditorApplication.h"
static BOOL sMouseMovedPending;
static id sValidateActionItem;


@implementation HSEditorApplication

/* i386 ivar offsets: _colorPickerMode=0x4c, _keyEventsConsumer=0x50 */

+ (id)sharedHyperApplication
{
    NSApplication *self_00;
    BOOL pvVar2;
    id pvVar1_2;

    self_00 = [self sharedApplication];
    pvVar2 = [self_00 isKindOfClass:[HSEditorApplication class]];
    pvVar1_2 = nil;
    if (pvVar2) {
        pvVar1_2 = self_00;
    }
    return pvVar1_2;
}

- (void)hide:(id)aHide
{
    if (![[[[NSDocumentController sharedDocumentController] currentDocument] modeSwitcher] switching]) {
        [super hide:aHide];
    }
}

- (void)setColorPickerMode:(NSInteger)aMode
{
    _colorPickerMode = aMode;
}

- (void)toggleColorPanel:(id)aPanel
{
    if (![[NSColorPanel sharedColorPanel] isVisible]) {
        [NSColorPanel setPickerMode:_colorPickerMode];
        _colorPickerMode = 7;
    }
    [NSApp orderFrontColorPanel:aPanel];
}

- (void)orderFrontFontPanel:(id)aPanel
{
    [[NSFontManager sharedFontManager] orderFrontFontPanel:aPanel];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001a24f8 @ 001a24f8, 587 bytes * /

BOOL FUN_001a24f8(HSEditorApplication *self,SEL _cmd,id validateUserInterfaceItem)

{
  char cVar1;
  undefined *puVar2;
  id pvVar3;
  
  puVar2 = _objc_msgSend(validateUserInterfaceItem,sel_action);
  pvVar3 = _objc_msgSend(cls_NSDocumentController,sel_sharedDocumentController);
  pvVar3 = _objc_msgSend(pvVar3,sel_currentDocument);
  if (pvVar3 == (id)0x0) {
    pvVar3 = _objc_msgSend(cls_NSDocumentController,sel_sharedDocumentController);
    pvVar3 = _objc_msgSend(pvVar3,sel_documents);
    pvVar3 = _objc_msgSend(pvVar3,sel_lastObject);
  }
  pvVar3 = _objc_msgSend(pvVar3,sel_actionExecutionContext);
  pvVar3 = _objc_msgSend(pvVar3,sel_waitingForMouseDownEvent);
  if ((char)pvVar3 != '\0') {
    return puVar2 == sel_showHelp_;
  }
  if (puVar2 == sel_runPageLayout_) {
    pvVar3 = _objc_msgSend(cls_NSDocumentController,sel_sharedDocumentController);
    pvVar3 = _objc_msgSend(pvVar3,sel_currentDocument);
    if (pvVar3 == (id)0x0) {
      return '\0';
    }
    pvVar3 = _objc_msgSend(pvVar3,sel_currentWindowController);
    pvVar3 = _objc_msgSend(pvVar3,sel_isSheetRunning);
    return (char)pvVar3 == '\0';
  }
  if (puVar2 != sel_terminate_) {
    if (puVar2 == sel_orderFrontFontPanel_) {
      puVar2 = sel_setState_;
      pvVar3 = _objc_msgSend(validateUserInterfaceItem,sel_respondsToSelector_,sel_setState_);
      if ((char)pvVar3 == '\0') {
        return '\x01';
      }
      pvVar3 = _objc_msgSend(cls_NSFontPanel,sel_sharedFontPanel,puVar2);
      pvVar3 = _objc_msgSend(pvVar3,sel_isVisible);
      cVar1 = (char)pvVar3;
    }
    else {
      if (puVar2 != sel_toggleColorPanel_) {
        return '\x01';
      }
      puVar2 = sel_setState_;
      pvVar3 = _objc_msgSend(validateUserInterfaceItem,sel_respondsToSelector_,sel_setState_);
      if ((char)pvVar3 == '\0') {
        return '\x01';
      }
      pvVar3 = _objc_msgSend(cls_NSColorPanel,sel_sharedColorPanel,puVar2);
      pvVar3 = _objc_msgSend(pvVar3,sel_isVisible);
      cVar1 = (char)pvVar3;
    }
    _objc_msgSend(validateUserInterfaceItem,sel_setState_,(uint)(cVar1 != '\0'));
    return '\x01';
  }
  pvVar3 = _objc_msgSend(cls_NSApplication,sel_sharedApplication);
  pvVar3 = _objc_msgSend(pvVar3,sel_modalWindow);
  return pvVar3 == (id)0x0;
}

*/
- (BOOL)validateUserInterfaceItem:(id)aItem
{
    SEL action = [aItem action];
    id document = [[NSDocumentController sharedDocumentController] currentDocument];
    if (document == nil) {
        document = [[[NSDocumentController sharedDocumentController] documents] lastObject];
    }
    if ([[document actionExecutionContext] waitingForMouseDownEvent]) {
        return action == @selector(showHelp:);
    }
    if (action == @selector(runPageLayout:)) {
        document = [[NSDocumentController sharedDocumentController] currentDocument];
        if (document == nil) {
            return NO;
        }
        return ![[document currentWindowController] isSheetRunning];
    }
    if (action != @selector(terminate:)) {
        BOOL visible;
        if (action == @selector(orderFrontFontPanel:)) {
            if (![aItem respondsToSelector:@selector(setState:)]) {
                return YES;
            }
            visible = [[NSFontPanel sharedFontPanel] isVisible];
        } else {
            if (action != @selector(toggleColorPanel:)) {
                return YES;
            }
            if (![aItem respondsToSelector:@selector(setState:)]) {
                return YES;
            }
            visible = [[NSColorPanel sharedColorPanel] isVisible];
        }
        [aItem setState:visible];
        return YES;
    }
    return [[NSApplication sharedApplication] modalWindow] == nil;
    return 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001a2743 @ 001a2743, 2794 bytes * /

void FUN_001a2743(HSEditorApplication *self,SEL _cmd,id sendEvent)

{
  short sVar1;
  short sVar2;
  id pvVar3;
  HSEditorApplication *self_00;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  id pvVar8;
  id pvVar9;
  id pvVar10;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  undefined4 extraout_EDX_01;
  uint uVar11;
  undefined *puVar12;
  double dVar13;
  double dVar14;
  SEL op;
  undefined4 uVar15;
  undefined *puVar16;
  id local_2c;
  HSEditorApplication *local_1c;
  undefined *local_18;
  
  local_2c = sendEvent;
  pvVar3 = _objc_msgSend(sendEvent,sel_type);
  switch(pvVar3) {
  case (id)0x5:
    DAT_003429d4 = '\x01';
    break;
  case (id)0x8:
  case (id)0x9:
    pvVar4 = _objc_msgSend(cls_NSDocumentController,sel_sharedDocumentController);
    pvVar4 = _objc_msgSend(pvVar4,sel_currentDocument);
    self_00 = _objc_msgSend(pvVar4,sel_modeSwitcher);
    op = sel_switching;
LAB_001a2f35:
    pvVar4 = _objc_msgSend(self_00,op);
    if ((char)pvVar4 == '\0') goto LAB_001a2f42;
    goto LAB_001a3029;
  case (id)0xa:
    pvVar4 = _objc_msgSend(sendEvent,sel_characters);
    pvVar4 = _objc_msgSend(pvVar4,sel_length);
    if (pvVar4 != (id)0x0) {
      _objc_msgSend(self->_keyEventsConsumer,sel_processKeyDownEvent_,sendEvent);
      pvVar4 = _objc_msgSend(sendEvent,sel_modifierFlags);
      pvVar5 = _objc_msgSend(sendEvent,sel_characters);
      uVar15 = 0;
      pvVar5 = _objc_msgSend(pvVar5,sel_characterAtIndex_,0);
      pvVar6 = _objc_msgSend(sendEvent,sel_charactersIgnoringModifiers);
      uVar11 = (uint)pvVar4 & 0xffff0000;
      pvVar6 = _objc_msgSend(pvVar6,sel_length);
      if (pvVar6 == (id)0x0) {
        sVar1 = 0;
      }
      else {
        pvVar6 = _objc_msgSend(sendEvent,sel_charactersIgnoringModifiers,uVar15);
        uVar15 = 0;
        pvVar6 = _objc_msgSend(pvVar6,sel_characterAtIndex_,0);
        sVar1 = (short)pvVar6;
      }
      pvVar6 = _objc_msgSend(sendEvent,sel_characters,uVar15);
      pvVar6 = _objc_msgSend(pvVar6,sel_length);
      sVar2 = (short)pvVar5;
      if ((pvVar6 == (id)0x1) && (sVar2 == 9)) {
        puVar12 = sel_togglePlayEditViaGlobalShortcut_;
        puVar16 = sel_togglePlayEdit_;
        if ((uVar11 != 0x40000) && (uVar11 != 0x50000)) break;
        goto LAB_001a2e92;
      }
      pvVar6 = _objc_msgSend(sendEvent,sel_characters,uVar15);
      pvVar6 = _objc_msgSend(pvVar6,sel_length);
      if ((pvVar6 == (id)0x1) && (sVar2 == 0x19)) {
        puVar12 = sel_switchToRectSelectionToolViaGlobalShortcut_;
        puVar16 = sel_switchToRectSelectionToolViaGlobalShortcut_;
        if ((uVar11 == 0x60000) || (uVar11 == 0x70000)) goto LAB_001a2e92;
      }
      else {
        pvVar6 = _objc_msgSend(sendEvent,sel_characters);
        pvVar6 = _objc_msgSend(pvVar6,sel_length);
        if ((pvVar6 == (id)0x1) && ((sVar2 == 0x5b || (sVar2 == 0x5d)))) {
          if ((uVar11 == 0x100000) || (uVar11 == 0x110000)) {
            puVar12 = sel_switchToPreviousObjectAssistantPaneViaGlobalShortcut_;
            puVar16 = sel_switchToPreviousObjectAssistantPaneViaGlobalShortcut_;
            if (sVar2 == 0x5d) {
              puVar12 = sel_switchToNextObjectAssistantPaneViaGlobalShortcut_;
              puVar16 = sel_switchToNextObjectAssistantPaneViaGlobalShortcut_;
            }
            goto LAB_001a2e92;
          }
        }
        else {
          pvVar6 = _objc_msgSend(sendEvent,sel_characters);
          pvVar6 = _objc_msgSend(pvVar6,sel_length);
          if ((pvVar6 == (id)0x1) && ((sVar1 == 0x2b || (sVar1 == 0x3d)))) {
            puVar12 = sel_zoomIn_;
            puVar16 = sel_zoomIn_;
            if (((uVar11 == 0x80000) || (uVar11 == 0x280000)) || (uVar11 == 0x2a0000))
            goto LAB_001a2e92;
          }
          else {
            pvVar6 = _objc_msgSend(sendEvent,sel_characters);
            pvVar6 = _objc_msgSend(pvVar6,sel_length);
            if ((pvVar6 == (id)0x1) && ((sVar1 == 0x2d || (sVar1 == 0x5f)))) {
              puVar12 = sel_zoomOut_;
              puVar16 = sel_zoomOut_;
              if (uVar11 == 0xa0000) goto LAB_001a2e92;
            }
            else {
              pvVar6 = _objc_msgSend(sendEvent,sel_characters);
              pvVar6 = _objc_msgSend(pvVar6,sel_length);
              if ((pvVar6 == (id)0x1) && ((sVar1 == 0x2c || (sVar1 == 0x3c)))) {
                pvVar6 = _objc_msgSend(cls_NSDocumentController,sel_sharedDocumentController);
                pvVar6 = _objc_msgSend(pvVar6,sel_currentDocument);
                pvVar6 = _objc_msgSend(pvVar6,sel_actionExecutionContext);
                pvVar6 = _objc_msgSend(pvVar6,sel_waitingForMouseDownEvent);
                if ((char)pvVar6 != '\0') goto LAB_001a2ba5;
                pvVar5 = _objc_msgSend(cls_NSDocumentController,sel_sharedDocumentController);
                pvVar5 = _objc_msgSend(pvVar5,sel_currentDocument);
                pvVar5 = _objc_msgSend(pvVar5,sel_actionExecutionContext);
                pvVar5 = _objc_msgSend(pvVar5,sel_document);
                pvVar5 = _objc_msgSend(pvVar5,sel_isInAnimationMode);
                if ((char)pvVar5 == '\0') {
                  if (((uint)pvVar4 & 0x100000) == 0) break;
                  goto switchD_001a2e41_caseD_0;
                }
                goto LAB_001a3029;
              }
LAB_001a2ba5:
              pvVar6 = _objc_msgSend(sendEvent,sel_characters);
              pvVar6 = _objc_msgSend(pvVar6,sel_length);
              if ((pvVar6 == (id)0x1) && ((sVar1 == 0x2e || (sVar1 == 0x3e)))) {
                pvVar6 = _objc_msgSend(cls_NSDocumentController,sel_sharedDocumentController);
                pvVar6 = _objc_msgSend(pvVar6,sel_currentDocument);
                pvVar6 = _objc_msgSend(pvVar6,sel_actionExecutionContext);
                pvVar6 = _objc_msgSend(pvVar6,sel_waitingForMouseDownEvent);
                if ((char)pvVar6 != '\0') goto LAB_001a2cf4;
                pvVar5 = _objc_msgSend(cls_NSDocumentController,sel_sharedDocumentController);
                pvVar5 = _objc_msgSend(pvVar5,sel_currentDocument);
                pvVar5 = _objc_msgSend(pvVar5,sel_actionExecutionContext);
                pvVar5 = _objc_msgSend(pvVar5,sel_document);
                pvVar5 = _objc_msgSend(pvVar5,sel_isInAnimationMode);
                if ((char)pvVar5 != '\0') goto LAB_001a3029;
                if ((((uint)pvVar4 & 0x180000) != 0x180000) &&
                   (((uint)pvVar4 & 0x1a0000) != 0x1a0000)) {
                  puVar12 = sel_goToNextCardWithoutLeaveActions_;
                  puVar16 = sel_goToNextCardWithoutLeaveActions_;
                  if (((uint)pvVar4 & 0x100000) != 0) goto LAB_001a2e92;
                  break;
                }
                goto switchD_001a2e41_caseD_1;
              }
LAB_001a2cf4:
              pvVar4 = _objc_msgSend(sendEvent,sel_characters);
              pvVar4 = _objc_msgSend(pvVar4,sel_length);
              if (pvVar4 == (id)0x1) {
                pvVar4 = _objc_msgSend(cls_HSEditorController,sel_sharedDocumentController);
                pvVar4 = _objc_msgSend(pvVar4,sel_currentDocument);
                pvVar4 = _objc_msgSend(pvVar4,sel_isInPurePlayerMode);
                if ((char)pvVar4 == '\0') {
                  pvVar4 = _objc_msgSend(cls_HSEditorController,sel_sharedDocumentController);
                  pvVar4 = _objc_msgSend(pvVar4,sel_currentDocument);
                  pvVar4 = _objc_msgSend(pvVar4,sel_isInPresentationMode);
                  if ((char)pvVar4 == '\0') break;
                }
                pvVar4 = _objc_msgSend(cls_HSApplicationController,sel_sharedDocumentController);
                pvVar4 = _objc_msgSend(pvVar4,sel_currentDocument);
                pvVar4 = _objc_msgSend(pvVar4,sel_cardView);
                pvVar4 = _objc_msgSend(pvVar4,sel_queryHyperInterface_,&DAT_0037c1a8);
                pvVar4 = _objc_msgSend(pvVar4,sel_isTextObjectSelected);
                if ((char)pvVar4 == '\0') {
                  if (sVar2 < -0x8d7) {
                    switch((int)pvVar5 + 0x900U & 0xffff) {
                    case 0:
                    case 2:
                      goto switchD_001a2e41_caseD_0;
                    case 1:
                    case 3:
                      goto switchD_001a2e41_caseD_1;
                    }
                  }
                  else {
                    switch((int)pvVar5 + 0x8d7U & 0xffff) {
                    case 0:
                      puVar12 = sel_goToFirstCardWithoutLeaveActions_;
                      puVar16 = sel_goToFirstCardWithoutLeaveActions_;
                      break;
                    default:
                      goto switchD_001a2782_caseD_6;
                    case 2:
                      puVar12 = sel_goToLastCardWithoutLeaveActions_;
                      puVar16 = sel_goToLastCardWithoutLeaveActions_;
                      break;
                    case 3:
switchD_001a2e41_caseD_0:
                      puVar12 = sel_goToPreviousCardWithoutLeaveActions_;
                      puVar16 = sel_goToPreviousCardWithoutLeaveActions_;
                      break;
                    case 4:
switchD_001a2e41_caseD_1:
                      puVar12 = sel_advanceToNextCardWithoutLeaveActions_;
                      puVar16 = sel_advanceToNextCardWithoutLeaveActions_;
                    }
LAB_001a2e92:
                    pvVar4 = _objc_msgSend(self,sel_targetForAction_to_from_,puVar16,0,self);
                    if ((pvVar4 != (id)0x0) &&
                       (self_00 = self, op = sel_performAction_target_validate_,
                       puVar12 != (undefined *)0x0)) goto LAB_001a2f35;
                  }
                }
              }
            }
          }
        }
      }
    }
    break;
  case (id)0xb:
    _objc_msgSend(self->_keyEventsConsumer,sel_processKeyUpEvent_,sendEvent);
  }
switchD_001a2782_caseD_6:
LAB_001a2f42:
  if (((*(double *)PTR_0033605c <= 1138.0 && *(double *)PTR_0033605c != 1138.0) ||
      (pvVar3 != (id)0x16)) ||
     (pvVar4 = _objc_msgSend(sendEvent,sel_momentumPhase), pvVar4 == (id)0x0)) {
    local_1c = self;
    local_18 = PTR_s_HSApplication_00353330;
    _objc_msgSendSuper(&local_1c,sel_sendEvent_,sendEvent);
  }
  else {
    pvVar4 = _objc_msgSend(sendEvent,sel_window);
    _objc_msgSend(pvVar4,sel_sendEvent_,sendEvent);
  }
  if (pvVar3 != (id)0x5) {
    if (pvVar3 != (id)0xc) {
      return;
    }
    pvVar4 = _objc_msgSend(self,sel_mainWindow);
    pvVar5 = _objc_msgSend(self,sel_keyWindow);
    if (pvVar4 != pvVar5) {
      _objc_msgSend(pvVar4,sel_sendEvent_,sendEvent);
    }
LAB_001a3029:
    if (pvVar3 != (id)0x5) {
      return;
    }
  }
  if (DAT_003429d4 == '\x01') {
    pvVar4 = _objc_msgSend(self,sel_mainWindow);
    pvVar5 = _objc_msgSend(pvVar4,sel_acceptsMouseMovedEvents);
    if ((char)pvVar5 == '\0') {
      DAT_003429d4 = '\0';
    }
    else {
      pvVar5 = _objc_msgSend(sendEvent,sel_window);
      if (pvVar4 != pvVar5) {
        pvVar6 = _objc_msgSend(sendEvent,sel_locationInWindow);
        uVar15 = extraout_EDX;
        if (pvVar5 != (id)0x0) {
          pvVar6 = _objc_msgSend(pvVar5,sel_convertBaseToScreen_,pvVar6,extraout_EDX);
          uVar15 = extraout_EDX_00;
        }
        pvVar5 = _objc_msgSend(pvVar4,sel_convertScreenToBase_,pvVar6,uVar15);
        puVar12 = cls_NSEvent;
        dVar13 = _objc_msgSend_fpret(sendEvent,sel_pressure);
        pvVar6 = _objc_msgSend(sendEvent,sel_clickCount);
        pvVar7 = _objc_msgSend(sendEvent,sel_eventNumber);
        pvVar8 = _objc_msgSend(pvVar4,sel_graphicsContext);
        pvVar9 = _objc_msgSend(pvVar4,sel_windowNumber);
        dVar14 = _objc_msgSend_fpret(sendEvent,sel_timestamp);
        pvVar10 = _objc_msgSend(sendEvent,sel_modifierFlags);
        local_2c = _objc_msgSend(puVar12,
                                 sel_mouseEventWithType_location_modifierFlags_timestamp_windowNumber_context_eventNumber_clickCount_pressure_
                                 ,pvVar3,pvVar5,extraout_EDX_01,pvVar10,dVar14,pvVar9,pvVar8,pvVar7,
                                 pvVar6,(float)dVar13);
      }
      _objc_msgSend(pvVar4,sel_mouseMoved_,local_2c);
    }
  }
  return;
}

*/
- (void)sendEvent:(id)aEvent
{
    NSUInteger type = [(NSEvent *)aEvent type];
    SEL performSelector = NULL;
    SEL targetSelector = NULL;
    switch (type) {
    case 5:
        sMouseMovedPending = YES;
        break;
    case 8:
    case 9:
        if ([[[[NSDocumentController sharedDocumentController] currentDocument] modeSwitcher] switching]) {
            return;
        }
        break;
    case 10:
        if ([[aEvent characters] length] != 0) {
            [_keyEventsConsumer processKeyDownEvent:aEvent];
            NSUInteger flags = [(NSEvent *)aEvent modifierFlags];
            short character = (short)[[aEvent characters] characterAtIndex:0];
            short unmodified = 0;
            if ([[aEvent charactersIgnoringModifiers] length] != 0) {
                unmodified = (short)[[aEvent charactersIgnoringModifiers] characterAtIndex:0];
            }
            NSUInteger modifiers = flags & 0xffff0000;
            if ([[aEvent characters] length] == 1 && character == 9) {
                performSelector = @selector(togglePlayEditViaGlobalShortcut:);
                targetSelector = @selector(togglePlayEdit:);
                if (modifiers != 0x40000 && modifiers != 0x50000) {
                    break;
                }
                goto dispatch;
            }
            if ([[aEvent characters] length] == 1 && character == 0x19) {
                performSelector = targetSelector = @selector(switchToRectSelectionToolViaGlobalShortcut:);
                if (modifiers == 0x60000 || modifiers == 0x70000) {
                    goto dispatch;
                }
                break;
            }
            if ([[aEvent characters] length] == 1 && (character == 0x5b || character == 0x5d)) {
                if (modifiers == 0x100000 || modifiers == 0x110000) {
                    performSelector = targetSelector = @selector(switchToPreviousObjectAssistantPaneViaGlobalShortcut:);
                    if (character == 0x5d) {
                        performSelector = targetSelector = @selector(switchToNextObjectAssistantPaneViaGlobalShortcut:);
                    }
                    goto dispatch;
                }
                break;
            }
            if ([[aEvent characters] length] == 1 && (unmodified == 0x2b || unmodified == 0x3d)) {
                performSelector = targetSelector = @selector(zoomIn:);
                if (modifiers == 0x80000 || modifiers == 0x280000 || modifiers == 0x2a0000) {
                    goto dispatch;
                }
                break;
            }
            if ([[aEvent characters] length] == 1 && (unmodified == 0x2d || unmodified == 0x5f)) {
                performSelector = targetSelector = @selector(zoomOut:);
                if (modifiers == 0xa0000) {
                    goto dispatch;
                }
                break;
            }
            if ([[aEvent characters] length] == 1 && (unmodified == 0x2c || unmodified == 0x3c)) {
                if (![[[[NSDocumentController sharedDocumentController] currentDocument] actionExecutionContext] waitingForMouseDownEvent]) {
                    if ([[[[[NSDocumentController sharedDocumentController] currentDocument] actionExecutionContext] document] isInAnimationMode]) {
                        return;
                    }
                    if ((flags & 0x100000) == 0) {
                        break;
                    }
                    goto previousCard;
                }
            }
            if ([[aEvent characters] length] == 1 && (unmodified == 0x2e || unmodified == 0x3e)) {
                if (![[[[NSDocumentController sharedDocumentController] currentDocument] actionExecutionContext] waitingForMouseDownEvent]) {
                    if ([[[[[NSDocumentController sharedDocumentController] currentDocument] actionExecutionContext] document] isInAnimationMode]) {
                        return;
                    }
                    if ((flags & 0x180000) != 0x180000 && (flags & 0x1a0000) != 0x1a0000) {
                        performSelector = targetSelector = @selector(goToNextCardWithoutLeaveActions:);
                        if ((flags & 0x100000) != 0) {
                            goto dispatch;
                        }
                        break;
                    }
                    goto nextCard;
                }
            }
            if ([[aEvent characters] length] == 1) {
                if (![[[HSEditorController sharedDocumentController] currentDocument] isInPurePlayerMode]
                    && ![[[HSEditorController sharedDocumentController] currentDocument] isInPresentationMode]) {
                    break;
                }
                if (![[[[[HSApplicationController sharedDocumentController] currentDocument] cardView] queryHyperInterface:@protocol(HSInteractiveCanvasLayerContext)] isTextObjectSelected]) {
                    if (character < -0x8d7) {
                        switch ((character + 0x900) & 0xffff) {
                        case 0:
                        case 2:
                            goto previousCard;
                        case 1:
                        case 3:
                            goto nextCard;
                        }
                    } else {
                        switch ((character + 0x8d7) & 0xffff) {
                        case 0:
                            performSelector = targetSelector = @selector(goToFirstCardWithoutLeaveActions:);
                            break;
                        case 2:
                            performSelector = targetSelector = @selector(goToLastCardWithoutLeaveActions:);
                            break;
                        case 3:
                        previousCard:
                            performSelector = targetSelector = @selector(goToPreviousCardWithoutLeaveActions:);
                            break;
                        case 4:
                        nextCard:
                            performSelector = targetSelector = @selector(advanceToNextCardWithoutLeaveActions:);
                            break;
                        default:
                            goto sendToSuper;
                        }
                    dispatch:
                        if ([self targetForAction:targetSelector to:nil from:self] != nil && performSelector != NULL) {
                            if ([self performAction:performSelector target:[self targetForAction:targetSelector to:nil from:self] validate:YES]) {
                                return;
                            }
                        }
                    }
                }
            }
        }
        break;
    case 11:
        [_keyEventsConsumer processKeyUpEvent:aEvent];
        break;
    }
sendToSuper:
    if (NSAppKitVersionNumber < 1138.0 || type != 0x16 || [aEvent momentumPhase] == 0) {
        [super sendEvent:aEvent];
    } else {
        [[(NSEvent *)aEvent window] sendEvent:aEvent];
    }
    if (type != 5) {
        if (type != 0xc) {
            return;
        }
        id mainWindow = [self mainWindow];
        if (mainWindow != [self keyWindow]) {
            [(NSWindow *)mainWindow sendEvent:aEvent];
        }
        return;
    }
    if (sMouseMovedPending == YES) {
        NSWindow *mainWindow = [self mainWindow];
        if (![mainWindow acceptsMouseMovedEvents]) {
            sMouseMovedPending = NO;
        } else {
            NSWindow *eventWindow = [aEvent window];
            if (mainWindow != eventWindow) {
                NSPoint location = [(NSEvent *)aEvent locationInWindow];
                if (eventWindow != nil) {
                    location = [eventWindow convertBaseToScreen:location];
                }
                location = [mainWindow convertScreenToBase:location];
                aEvent = [NSEvent mouseEventWithType:type location:location modifierFlags:[(NSEvent *)aEvent modifierFlags] timestamp:[(NSEvent *)aEvent timestamp] windowNumber:[mainWindow windowNumber] context:[mainWindow graphicsContext] eventNumber:[(NSEvent *)aEvent eventNumber] clickCount:[(NSEvent *)aEvent clickCount] pressure:[(NSEvent *)aEvent pressure]];
            }
            [mainWindow mouseMoved:aEvent];
        }
    }
}

- (BOOL)sendAction:(SEL)aAction to:(id)aTo from:(id)aFrom
{
    [[[HSEditorController sharedDocumentController] currentDocument] finalizeBitmapToolIfNeededForAction:aAction to:aTo from:aFrom];
    return (BOOL)[super sendAction:aAction to:aTo from:aFrom];
}

- (void)noteMainWindowDidHandleMouseMovedEvent
{
    sMouseMovedPending = NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001a330e @ 001a330e, 208 bytes * /

BOOL FUN_001a330e(HSEditorApplication *self,SEL _cmd,SEL performAction,id target,BOOL validate)

{
  BOOL BVar1;
  id pvVar2;
  
  if (target == (id)0x0) {
LAB_001a33d4:
    BVar1 = '\0';
  }
  else {
    if (validate != '\0') {
      if (DAT_003429d8 == (id)0x0) {
        DAT_003429d8 = _objc_msgSend(cls_HSValidateActionItem,sel_new);
      }
      _objc_msgSend(DAT_003429d8,sel_setAction_,performAction);
      pvVar2 = _objc_msgSend(target,sel_conformsToProtocol_,&DAT_0037c194);
      if ((char)pvVar2 != '\0') {
        pvVar2 = _objc_msgSend(target,sel_validateUserInterfaceItem_,DAT_003429d8);
        if ((char)pvVar2 == '\0') goto LAB_001a33d4;
      }
    }
    _objc_msgSend(target,sel_performSelector_withObject_,performAction,self);
    BVar1 = '\x01';
  }
  return BVar1;
}

*/
- (BOOL)performAction:(SEL)aAction target:(id)aTarget validate:(BOOL)aValidate
{
    if (aTarget == nil) {
        return NO;
    }
    if (aValidate) {
        if (sValidateActionItem == nil) {
            sValidateActionItem = [HSValidateActionItem new];
        }
        [sValidateActionItem setAction:aAction];
        if ([aTarget conformsToProtocol:@protocol(NSUserInterfaceValidations)]) {
            if (![aTarget validateUserInterfaceItem:sValidateActionItem]) {
                return NO;
            }
        }
    }
    [aTarget performSelector:aAction withObject:self];
    return YES;
    return 0;
}

- (void)hideSplashWindow
{
    [[HSSplashScreenWindowController sharedSplashWindow] hideSplashWaitUntilTimeout:NO];
}

- (void)beginSheet:(id)aSheet modalForWindow:(id)aWindow modalDelegate:(id)aDelegate didEndSelector:(SEL)aSelector contextInfo:(void *)aInfo
{
    [self hideSplashWindow];
    [super beginSheet:aSheet modalForWindow:aWindow modalDelegate:aDelegate didEndSelector:aSelector contextInfo:aInfo];
}

- (struct _NSModalSession *)beginModalSessionForWindow:(id)aWindow relativeToWindow:(id)aWindow2
{
    [self hideSplashWindow];
    return [super beginModalSessionForWindow:aWindow relativeToWindow:aWindow2];
}

- (struct _NSModalSession *)beginModalSessionForWindow:(id)aWindow
{
    [self hideSplashWindow];
    return [super beginModalSessionForWindow:aWindow];
}

- (NSInteger)runModalForWindow:(id)aWindow relativeToWindow:(id)aWindow2
{
    [self hideSplashWindow];
    return (int)[super runModalForWindow:aWindow relativeToWindow:aWindow2];
}

- (NSInteger)runModalForWindow:(id)aWindow
{
    [self hideSplashWindow];
    return (int)[super runModalForWindow:aWindow];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _colorPickerMode = 7;
        _keyEventsConsumer = [HSKeysRegistry sharedRegistry];
    }
    return self;
}

@end

@implementation HSValidateActionItem

/* i386 ivar offsets: _action=0x4 */

- (void)setAction:(SEL)aAction
{
    _action = aAction;
}

- (SEL)action
{
    return _action;
}

- (NSInteger)tag
{
    return 0;
}

@end

