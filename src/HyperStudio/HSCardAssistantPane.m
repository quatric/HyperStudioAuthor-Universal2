#import "HSCardAssistantPane.h"

@implementation HSCardAssistantPane

/* i386 ivar offsets: _cardTitleField=0x5c, _commentsTextView=0x60, _cursorImageView=0x64, _cursorButton=0x68, _groupCardSwitch=0x6c, _markedCardSwitch=0x70, _arriveThisCardSwitch=0x74, _leaveThisCardSwitch=0x78, _clickThisCardSwitch=0x7c, _arriveThisCardButton=0x80, _leaveThisCardButton=0x84, _clickThisCardButton=0x88, _objectParentObserver=0x8c, _cardTitleFieldChanged=0x90 */

+ (BOOL)canEditObject:(id)aObject
{
    return (BOOL)[aObject implementsHyperInterface:@protocol(HSCardAttributes)];
}

- (void)openActionsPaneForClickEvent:(id)aEvent
{
    [self openActionsAssistantForActionEvent:[HSActionEvent actionEventOfType:kHSClickActionEventType] animate:NO];
}

- (void)editClickingThisCard:(id)aCard
{
    [self openActionsAssistantForActionEvent:[HSActionEvent actionEventOfType:kHSClickActionEventType] animate:YES];
}

- (void)editLeaveThisCard:(id)aCard
{
    [self openActionsAssistantForActionEvent:[HSActionEvent actionEventOfType:kHSLeaveActionEventType] animate:YES];
}

- (void)editArriveThisCard:(id)aCard
{
    [self openActionsAssistantForActionEvent:[HSActionEvent actionEventOfType:kHSArriveActionEventType] animate:YES];
}

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

- (void)clickingThisCardChanged:(id)aChanged
{
    [self handleActionsAssistantForActionEvent:[HSActionEvent actionEventOfType:kHSClickActionEventType]];
}

- (void)leaveThisCardChanged:(id)aChanged
{
    [self handleActionsAssistantForActionEvent:[HSActionEvent actionEventOfType:kHSLeaveActionEventType]];
}

- (void)arriveThisCardChanged:(id)aChanged
{
    [self handleActionsAssistantForActionEvent:[HSActionEvent actionEventOfType:kHSArriveActionEventType]];
}

- (void)markedCardChanged:(id)aChanged
{
    [[[[self assistant] object] queryHyperInterface:@protocol(HSCardAttributes)] setMarkedCard:(unsigned int)([aChanged state] == 0x1)];
}

- (void)groupCardChanged:(id)aChanged
{
    id pvVar1_3;

    pvVar1_3 = [[[self assistant] object] queryHyperInterface:@protocol(HSCardAttributes)];
    [self unsubscribeFromNotifications];
    [pvVar1_3 makeNonGroupCard];
    [self subscribeToNotifications];
    [self validateGroupCardSwitch];
    [self validateActionSwitches];
}

- (void)commentsChanged:(id)aChanged
{
    id pvVar1_2;

    pvVar1_2 = [[_commentsTextView string] copy];
    [[[[self assistant] object] queryHyperInterface:@protocol(HSCommentsAttributes)] setHyperComments:pvVar1_2];
    [pvVar1_2 release];
}

- (void)cardTitleChanged:(id)aChanged
{
    _cardTitleFieldChanged = NO;
    [[[[self assistant] object] queryHyperInterface:@protocol(HSCardAttributes)] setHyperTitle:[aChanged stringValue]];
    [[[[NSDocumentController sharedDocumentController] currentDocument] currentWindowController] synchronizeWindowTitleWithDocumentName];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000eb5a5 @ 000eb5a5, 325 bytes * /

void FUN_000eb5a5(HSCardAssistantPane *self,SEL _cmd,id textDidChange)

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
    NSAttributedString *attributed = [[_commentsTextView string] hyperAttributedStringWithRecognizedLinks];
    NSRange selection = [_commentsTextView selectedRange];
    [[_commentsTextView textStorage] replaceCharactersInRange:NSMakeRange(0, [[_commentsTextView textStorage] length]) withAttributedString:attributed];
    if (selection.location + selection.length < [[_commentsTextView string] length]) {
        [_commentsTextView setSelectedRange:selection];
    }
    [self commentsChanged:nil];
}

- (void)HSCardAssistantPane_automaticTimerDidChange:(id)aChange
{
    [self validateActionSwitches];
}

- (void)HSCardAssistantPane_actorDidChange:(id)aChange
{
    [self validateActionSwitches];
}

- (void)cardCursorAttributesDidChange:(id)aChange
{
    [self validateCursorView];
}

- (void)cardCommentsAttributesDidChange:(id)aChange
{
    [self validateCommentsView];
}

- (void)controlTextDidChange:(id)aChange
{
    if (([aChange object] == _cardTitleField) && (_cardTitleFieldChanged == NO)) {
        _cardTitleFieldChanged = YES;
    }
}

- (void)textDidEndEditing:(id)aEditing
{
    [self commentsChanged:[aEditing object]];
}

- (void)cardAttributesDidChange:(id)aChange
{
    [self validateTitleField];
    [self validateMarkedCardSwitch];
    [self validateGroupCardSwitch];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ebebc @ 000ebebc, 1404 bytes * /

void FUN_000ebebc(HSCardAssistantPane *self,SEL _cmd)

{
  bool bVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  cfstringStruct *pcVar6;
  int *piVar7;
  int *piVar8;
  int *piVar9;
  int aiStack_b8 [6];
  float local_74;
  undefined4 uStack_70;
  float local_6c;
  float fStack_68;
  float local_64;
  undefined4 uStack_60;
  float local_5c;
  float fStack_58;
  float local_54;
  undefined4 uStack_50;
  float local_4c;
  float fStack_48;
  float local_44 [2];
  float local_3c;
  float local_34 [2];
  float local_2c;
  float local_24 [2];
  float local_1c;
  
  pvVar2 = _objc_msgSend(self,sel_assistant);
  pvVar2 = _objc_msgSend(pvVar2,sel_object);
  pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_);
  _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_);
  pvVar3 = _objc_msgSend(pvVar2,sel_hyperActionsForEvent_);
  pvVar3 = _objc_msgSend(pvVar3,sel_count);
  _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_);
  pvVar4 = _objc_msgSend(pvVar2,sel_hyperActionsForEvent_);
  pvVar4 = _objc_msgSend(pvVar4,sel_count);
  _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_);
  pvVar5 = _objc_msgSend(pvVar2,sel_hyperActionsForEvent_);
  pvVar5 = _objc_msgSend(pvVar5,sel_count);
  if (pvVar5 == (id)0x0) {
    _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_);
    pvVar2 = _objc_msgSend(pvVar2,sel_automaticTimerForActionEvent_);
    pvVar2 = _objc_msgSend(pvVar2,sel_runActionsAutomatically);
    if ((char)pvVar2 == '\0') {
      bVar1 = false;
      goto LAB_000ec05f;
    }
  }
  bVar1 = true;
LAB_000ec05f:
  _objc_msgSend(self->_arriveThisCardSwitch,sel_setState_);
  _objc_msgSend(self->_leaveThisCardSwitch,sel_setState_);
  _objc_msgSend(self->_clickThisCardSwitch,sel_setState_);
  _objc_msgSend(self->_arriveThisCardButton,sel_setHidden_);
  _objc_msgSend(self->_leaveThisCardButton,sel_setHidden_);
  _objc_msgSend(self->_clickThisCardButton,sel_setHidden_);
  _objc_msgSend(self->_arriveThisCardButton,sel_setEnabled_);
  _objc_msgSend(self->_leaveThisCardButton,sel_setEnabled_);
  _objc_msgSend(self->_clickThisCardButton,sel_setEnabled_);
  _objc_msgSend_stret(&local_54,self->_arriveThisCardSwitch,sel_frame);
  piVar7 = (int *)&stack0xffffff60;
  local_4c = fStack_48;
  if (pvVar3 == (id)0x0) {
    aiStack_b8[5] = 0xec1f8;
    _objc_msgSend_stret(local_44,self->_arriveThisCardButton,sel_frame);
    piVar7 = aiStack_b8 + 5;
    local_4c = (local_44[0] + local_3c) - local_54;
  }
  pvVar2 = self->_arriveThisCardSwitch;
  *(ulonglong *)(piVar7 + 4) = CONCAT44(fStack_48,local_4c);
  *(ulonglong *)(piVar7 + 2) = CONCAT44(uStack_50,local_54);
  piVar7[1] = (int)sel_setFrame_;
  *piVar7 = (int)pvVar2;
  piVar7[-1] = 0xec23d;
  _objc_msgSend((id)*piVar7,(SEL)piVar7[1]);
  pvVar2 = self->_leaveThisCardSwitch;
  piVar7[2] = (int)sel_frame;
  piVar7[1] = (int)pvVar2;
  *piVar7 = (int)&local_64;
  piVar7[-1] = 0xec259;
  _objc_msgSend_stret((void *)*piVar7,(id)piVar7[1],(SEL)piVar7[2]);
  piVar8 = piVar7 + -1;
  local_5c = fStack_58;
  if (pvVar4 == (id)0x0) {
    pvVar2 = self->_leaveThisCardButton;
    piVar7[1] = (int)sel_frame;
    *piVar7 = (int)pvVar2;
    piVar7[-1] = (int)local_34;
    piVar7[-2] = 0xec28b;
    _objc_msgSend_stret((void *)piVar7[-1],(id)*piVar7,(SEL)piVar7[1]);
    piVar8 = piVar7 + -2;
    local_5c = (local_34[0] + local_2c) - local_64;
  }
  pvVar2 = self->_leaveThisCardSwitch;
  *(ulonglong *)(piVar8 + 4) = CONCAT44(fStack_58,local_5c);
  *(ulonglong *)(piVar8 + 2) = CONCAT44(uStack_60,local_64);
  piVar8[1] = (int)sel_setFrame_;
  *piVar8 = (int)pvVar2;
  piVar8[-1] = 0xec2d0;
  _objc_msgSend((id)*piVar8,(SEL)piVar8[1]);
  pvVar2 = self->_clickThisCardSwitch;
  piVar8[2] = (int)sel_frame;
  piVar8[1] = (int)pvVar2;
  *piVar8 = (int)&local_74;
  piVar8[-1] = 0xec2ec;
  _objc_msgSend_stret((void *)*piVar8,(id)piVar8[1],(SEL)piVar8[2]);
  piVar9 = piVar8 + -1;
  local_6c = fStack_68;
  if (!bVar1) {
    pvVar2 = self->_clickThisCardButton;
    piVar8[1] = (int)sel_frame;
    *piVar8 = (int)pvVar2;
    piVar8[-1] = (int)local_24;
    piVar8[-2] = 0xec31b;
    _objc_msgSend_stret((void *)piVar8[-1],(id)*piVar8,(SEL)piVar8[1]);
    piVar9 = piVar8 + -2;
    local_6c = (local_24[0] + local_1c) - local_74;
  }
  pvVar2 = self->_clickThisCardSwitch;
  *(ulonglong *)(piVar9 + 4) = CONCAT44(fStack_68,local_6c);
  *(ulonglong *)(piVar9 + 2) = CONCAT44(uStack_70,local_74);
  piVar9[1] = (int)sel_setFrame_;
  *piVar9 = (int)pvVar2;
  piVar9[-1] = 0xec360;
  _objc_msgSend((id)*piVar9,(SEL)piVar9[1]);
  if (pvVar3 == (id)0x0) {
    pvVar2 = self->_arriveThisCardButton;
    piVar9[1] = (int)sel_title;
    *piVar9 = (int)pvVar2;
    piVar9[-1] = 0xec389;
    pcVar6 = _objc_msgSend((id)*piVar9,(SEL)piVar9[1]);
  }
  else {
    pcVar6 = &cfstr_empty;
  }
  pvVar2 = self->_arriveThisCardSwitch;
  piVar9[2] = (int)pcVar6;
  piVar9[1] = (int)sel_setTitle_;
  *piVar9 = (int)pvVar2;
  piVar9[-1] = 0xec3a5;
  _objc_msgSend((id)*piVar9,(SEL)piVar9[1]);
  if (pvVar4 == (id)0x0) {
    pvVar2 = self->_leaveThisCardButton;
    piVar9[1] = (int)sel_title;
    *piVar9 = (int)pvVar2;
    piVar9[-1] = 0xec3ce;
    pcVar6 = _objc_msgSend((id)*piVar9,(SEL)piVar9[1]);
  }
  else {
    pcVar6 = &cfstr_empty;
  }
  pvVar2 = self->_leaveThisCardSwitch;
  piVar9[2] = (int)pcVar6;
  piVar9[1] = (int)sel_setTitle_;
  *piVar9 = (int)pvVar2;
  piVar9[-1] = 0xec3ea;
  _objc_msgSend((id)*piVar9,(SEL)piVar9[1]);
  if (bVar1) {
    pcVar6 = &cfstr_empty;
  }
  else {
    pvVar2 = self->_clickThisCardButton;
    piVar9[1] = (int)sel_title;
    *piVar9 = (int)pvVar2;
    piVar9[-1] = 0xec411;
    pcVar6 = _objc_msgSend((id)*piVar9,(SEL)piVar9[1]);
  }
  pvVar2 = self->_clickThisCardSwitch;
  piVar9[2] = (int)pcVar6;
  piVar9[1] = (int)sel_setTitle_;
  *piVar9 = (int)pvVar2;
  piVar9[-1] = 0xec42d;
  _objc_msgSend((id)*piVar9,(SEL)piVar9[1]);
  return;
}

*/
- (void)validateActionSwitches
{
    id<HSActor> actor = [[[self assistant] object] queryHyperInterface:@protocol(HSActor)];
    NSUInteger arriveCount = [[actor hyperActionsForEvent:[HSActionEvent actionEventOfType:kHSArriveActionEventType]] count];
    NSUInteger leaveCount = [[actor hyperActionsForEvent:[HSActionEvent actionEventOfType:kHSLeaveActionEventType]] count];
    id clickType = kHSClickActionEventType;
    BOOL click;
    if ([[actor hyperActionsForEvent:[HSActionEvent actionEventOfType:clickType]] count] != 0 ||
        [[actor automaticTimerForActionEvent:[HSActionEvent actionEventOfType:clickType]] runActionsAutomatically]) {
        click = YES;
    } else {
        click = NO;
    }
    [_arriveThisCardSwitch setState:(arriveCount != 0)];
    [_leaveThisCardSwitch setState:(leaveCount != 0)];
    [_clickThisCardSwitch setState:click];
    [_arriveThisCardButton setHidden:!(arriveCount != 0)];
    [_leaveThisCardButton setHidden:!(leaveCount != 0)];
    [_clickThisCardButton setHidden:!click];
    [_arriveThisCardButton setEnabled:(arriveCount != 0)];
    [_leaveThisCardButton setEnabled:(leaveCount != 0)];
    [_clickThisCardButton setEnabled:click];
    NSRect frame = [_arriveThisCardSwitch frame];
    if (arriveCount == 0) {
        NSRect buttonFrame = [_arriveThisCardButton frame];
        frame.size.width = (buttonFrame.origin.x + buttonFrame.size.width) - frame.origin.x;
    }
    [_arriveThisCardSwitch setFrame:frame];
    frame = [_leaveThisCardSwitch frame];
    if (leaveCount == 0) {
        NSRect buttonFrame = [_leaveThisCardButton frame];
        frame.size.width = (buttonFrame.origin.x + buttonFrame.size.width) - frame.origin.x;
    }
    [_leaveThisCardSwitch setFrame:frame];
    frame = [_clickThisCardSwitch frame];
    if (!click) {
        NSRect buttonFrame = [_clickThisCardButton frame];
        frame.size.width = (buttonFrame.origin.x + buttonFrame.size.width) - frame.origin.x;
    }
    [_clickThisCardSwitch setFrame:frame];
    [_arriveThisCardSwitch setTitle:(arriveCount == 0) ? [_arriveThisCardButton title] : @""];
    [_leaveThisCardSwitch setTitle:(leaveCount == 0) ? [_leaveThisCardButton title] : @""];
    [_clickThisCardSwitch setTitle:click ? @"" : [_clickThisCardButton title]];
}

- (void)validateGroupCardSwitch
{
    BOOL pvVar1_4;

    pvVar1_4 = [[[[self assistant] object] queryHyperInterface:@protocol(HSCardAttributes)] isGroupCard];
    [_groupCardSwitch setEnabled:pvVar1_4];
    [_groupCardSwitch setState:(unsigned int)(pvVar1_4)];
}

- (void)validateMarkedCardSwitch
{
    [_markedCardSwitch setState:(unsigned int)([[[[self assistant] object] queryHyperInterface:@protocol(HSCardAttributes)] isMarkedCard])];
}

- (void)validateCursorView
{
    id pvVar1_4;
    id pvVar2_4;

    pvVar1_4 = [[[[self assistant] object] queryHyperInterface:@protocol(HSCursorAttributes)] hyperCursor];
    if (pvVar1_4 == nil) {
        pvVar2_4 = [[[[self assistant] object] queryHyperInterface:@protocol(HSNodeChild)] hyperParent];
        if (pvVar2_4 != nil) {
            pvVar1_4 = [[pvVar2_4 queryHyperInterface:@protocol(HSCursorAttributes)] hyperCursor];
        }
        if (pvVar1_4 == nil) {
            pvVar1_4 = [HSCursor defaultPlayerCursor];
        }
    }
    [_cursorImageView setImage:[pvVar1_4 image]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000eb01b @ 000eb01b, 412 bytes * /

void FUN_000eb01b(HSCardAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  int extraout_EDX;
  undefined *puVar5;
  
  pvVar1 = _objc_msgSend(self,sel_assistant);
  pvVar1 = _objc_msgSend(pvVar1,sel_object);
  if (pvVar1 != (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_assistant);
    pvVar1 = _objc_msgSend(pvVar1,sel_object);
    puVar5 = &DAT_0036d8d8;
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0036d8d8);
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
  }
  return;
}

*/
- (void)validateCommentsView
{
    if ([[self assistant] object] != nil) {
        id comments = [[[[self assistant] object] queryHyperInterface:@protocol(HSCommentsAttributes)] hyperComments];
        NSAttributedString *attributed = [comments hyperAttributedStringWithRecognizedLinks];
        if (attributed != nil) {
            NSRange selection = [_commentsTextView selectedRange];
            [[_commentsTextView textStorage] replaceCharactersInRange:NSMakeRange(0, [[_commentsTextView textStorage] length]) withAttributedString:attributed];
            if (selection.location + selection.length < [[_commentsTextView string] length]) {
                [_commentsTextView setSelectedRange:selection];
            }
        }
    }
}

- (void)validateTitleField
{
    if (_cardTitleFieldChanged == NO) {
        [_cardTitleField setStringValue:[[[[self assistant] object] queryHyperInterface:@protocol(HSCardAttributes)] hyperTitle]];
    }
}

- (void)validateUI
{
    [self validateTitleField];
    [self validateCommentsView];
    [self validateCursorView];
    [self validateMarkedCardSwitch];
    [self validateGroupCardSwitch];
    [self validateActionSwitches];
}

- (void)openActionsAssistantForActionEvent:(id)aEvent animate:(BOOL)aAnimate
{
    id pvVar1_2;
    id pvVar2_3;

    pvVar1_2 = [[HSActionsAssistantPane alloc] initWithActionEvent:aEvent navigationSwitcherClass:[HSActionsPaneGoBackSwitcher class]];
    pvVar2_3 = [[HSObjectAssistantNavigationController alloc] initWithRootViewController:pvVar1_2];
    [self presentModalViewController:pvVar2_3 animated:aAnimate];
    [pvVar2_3 release];
    [pvVar1_2 release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000eac75 @ 000eac75, 441 bytes * /

void FUN_000eac75(HSCardAssistantPane *self,SEL _cmd,id handleActionsAssistantForActionEvent)

{
  id pvVar1;
  HSCardAssistantPane *self_00;
  id pvVar2;
  HSCardAssistantPane *self_01;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_assistant);
  pvVar1 = _objc_msgSend(pvVar1,sel_object);
  self_00 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0036d98c);
  pvVar1 = _objc_msgSend(self_00,sel_hyperActionsForEvent_,handleActionsAssistantForActionEvent);
  pvVar1 = _objc_msgSend(pvVar1,sel_count);
  pvVar2 = _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_,*(undefined4 *)PTR_00336080);
  pvVar2 = _objc_msgSend(handleActionsAssistantForActionEvent,sel_isEqual_,pvVar2);
  if ((char)pvVar2 == '\0') {
    self_01 = _objc_msgSend(self_00,sel_automaticTimerForActionEvent_,
                            handleActionsAssistantForActionEvent);
    pvVar2 = _objc_msgSend(self_01,sel_runActionsAutomatically);
    op = sel_openActionsAssistantForActionEvent_animate_;
    if (pvVar1 != (id)0x0 || (char)pvVar2 != '\0') {
      if (pvVar1 != (id)0x0) {
        pvVar1 = _objc_msgSend(self_00,sel_hyperActionsForEvent_,
                               handleActionsAssistantForActionEvent);
        _objc_msgSend(self_00,sel_removeActions_,pvVar1);
      }
      if ((char)pvVar2 == '\0') {
        return;
      }
      handleActionsAssistantForActionEvent = (id)0x0;
      self = self_01;
      op = sel_setRunActionsAutomatically_;
    }
  }
  else {
    op = sel_openActionsAssistantForActionEvent_animate_;
    if (pvVar1 != (id)0x0) {
      handleActionsAssistantForActionEvent =
           _objc_msgSend(self_00,sel_hyperActionsForEvent_,handleActionsAssistantForActionEvent);
      self = self_00;
      op = sel_removeActions_;
    }
  }
  _objc_msgSend(self,op,handleActionsAssistantForActionEvent);
  return;
}

*/
- (void)handleActionsAssistantForActionEvent:(id)aEvent
{
    id<HSActor> actor = [[[self assistant] object] queryHyperInterface:@protocol(HSActor)];
    NSUInteger actionCount = [[actor hyperActionsForEvent:aEvent] count];
    if ([aEvent isEqual:[HSActionEvent actionEventOfType:kHSArriveActionEventType]]) {
        if (actionCount != 0) {
            [actor removeActions:[actor hyperActionsForEvent:aEvent]];
        } else {
            [self openActionsAssistantForActionEvent:aEvent animate:YES];
        }
        return;
    }
    id timer = [actor automaticTimerForActionEvent:aEvent];
    BOOL runsAutomatically = [timer runActionsAutomatically];
    if (actionCount == 0 && !runsAutomatically) {
        [self openActionsAssistantForActionEvent:aEvent animate:YES];
        return;
    }
    if (actionCount != 0) {
        [actor removeActions:[actor hyperActionsForEvent:aEvent]];
    }
    if (runsAutomatically) {
        [timer setRunActionsAutomatically:NO];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ea98c @ 000ea98c, 745 bytes * /

void FUN_000ea98c(HSCardAssistantPane *self,SEL _cmd)

{
  undefined4 uVar1;
  id pvVar2;
  id pvVar3;
  undefined *puVar4;
  undefined4 uVar5;
  undefined *puVar6;
  
  pvVar2 = _objc_msgSend(self,sel_assistant);
  pvVar2 = _objc_msgSend(pvVar2,sel_object);
  pvVar3 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_0036d838);
  pvVar3 = _objc_msgSend(pvVar3,sel_attributeObservingController);
  uVar1 = *(undefined4 *)PTR_0033601c;
  _objc_msgSend(pvVar3,sel_removeObserver_selector_ofChanges_ofAttributesOfHyperInterface_,self,
                sel_cardAttributesDidChange_,uVar1,&DAT_0036d838);
  pvVar3 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_0036d8d8);
  pvVar3 = _objc_msgSend(pvVar3,sel_attributeObservingController);
  _objc_msgSend(pvVar3,sel_removeObserver_selector_ofChanges_ofAttribute_,self,
                sel_cardCommentsAttributesDidChange_,uVar1,&DAT_0036d8ec);
  pvVar3 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_0036d900);
  pvVar3 = _objc_msgSend(pvVar3,sel_attributeObservingController);
  puVar6 = &DAT_0036d914;
  puVar4 = sel_cardCursorAttributesDidChange_;
  uVar5 = uVar1;
  _objc_msgSend(pvVar3,sel_removeObserver_selector_ofChanges_ofAttribute_,self,
                sel_cardCursorAttributesDidChange_,uVar1,&DAT_0036d914);
  if (self->_objectParentObserver != (id)0x0) {
    pvVar3 = _objc_msgSend(self->_objectParentObserver,sel_queryHyperInterface_,&DAT_0036d900,puVar4
                           ,uVar5,puVar6);
    pvVar3 = _objc_msgSend(pvVar3,sel_attributeObservingController);
    puVar6 = &DAT_0036d914;
    puVar4 = sel_cardCursorAttributesDidChange_;
    uVar5 = uVar1;
    _objc_msgSend(pvVar3,sel_removeObserver_selector_ofChanges_ofAttribute_,self,
                  sel_cardCursorAttributesDidChange_,uVar1,&DAT_0036d914);
    _objc_msgSend(self->_objectParentObserver,sel_release);
    self->_objectParentObserver = (id)0x0;
  }
  pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_0036d98c,puVar4,uVar5,puVar6);
  pvVar3 = _objc_msgSend(pvVar2,sel_attributeObservingController);
  _objc_msgSend(pvVar3,sel_removeObserver_selector_ofChanges_ofAttributesOfHyperInterface_,self,
                sel_HSCardAssistantPane_actorDidChange_,uVar1,&DAT_0036d98c);
  pvVar3 = _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_,*(undefined4 *)PTR_003363a8);
  pvVar2 = _objc_msgSend(pvVar2,sel_automaticTimerForActionEvent_,pvVar3);
  pvVar2 = _objc_msgSend(pvVar2,sel_attributeObservingController);
  _objc_msgSend(pvVar2,sel_removeObserver_selector_ofChanges_ofAttributesOfHyperInterface_,self,
                sel_HSCardAssistantPane_automaticTimerDidChange_,uVar1,&DAT_0036da40);
  return;
}

*/
- (void)unsubscribeFromNotifications
{
    id object = [[self assistant] object];
    NSUInteger changes = HSActualDidAttributeChanges;
    [[[object queryHyperInterface:@protocol(HSCardAttributes)] attributeObservingController] removeObserver:self selector:@selector(cardAttributesDidChange:) ofChanges:changes ofAttributesOfHyperInterface:@protocol(HSCardAttributes)];
    [[[object queryHyperInterface:@protocol(HSCommentsAttributes)] attributeObservingController] removeObserver:self selector:@selector(cardCommentsAttributesDidChange:) ofChanges:changes ofAttribute:@protocol(HSCommentsAttribute)];
    [[[object queryHyperInterface:@protocol(HSCursorAttributes)] attributeObservingController] removeObserver:self selector:@selector(cardCursorAttributesDidChange:) ofChanges:changes ofAttribute:@protocol(HSCursorAttribute)];
    if (_objectParentObserver != nil) {
        [[[_objectParentObserver queryHyperInterface:@protocol(HSCursorAttributes)] attributeObservingController] removeObserver:self selector:@selector(cardCursorAttributesDidChange:) ofChanges:changes ofAttribute:@protocol(HSCursorAttribute)];
        [_objectParentObserver release];
        _objectParentObserver = nil;
    }
    id<HSActor> actor = [object queryHyperInterface:@protocol(HSActor)];
    [[actor attributeObservingController] removeObserver:self selector:@selector(HSCardAssistantPane_actorDidChange:) ofChanges:changes ofAttributesOfHyperInterface:@protocol(HSActor)];
    id timer = [actor automaticTimerForActionEvent:[HSActionEvent actionEventOfType:kHSDefaultActionEventType]];
    [[timer attributeObservingController] removeObserver:self selector:@selector(HSCardAssistantPane_automaticTimerDidChange:) ofChanges:changes ofAttributesOfHyperInterface:@protocol(HSAutomaticTimerAttributes)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ea64a @ 000ea64a, 834 bytes * /

void FUN_000ea64a(HSCardAssistantPane *self,SEL _cmd)

{
  undefined4 uVar1;
  id pvVar2;
  id pvVar3;
  undefined *puVar4;
  undefined4 uVar5;
  undefined *puVar6;
  undefined4 uVar7;
  
  pvVar2 = _objc_msgSend(self,sel_assistant);
  pvVar2 = _objc_msgSend(pvVar2,sel_object);
  pvVar3 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_0036d838);
  pvVar3 = _objc_msgSend(pvVar3,sel_attributeObservingController);
  uVar1 = *(undefined4 *)PTR_0033601c;
  _objc_msgSend(pvVar3,sel_addObserver_selector_ofChanges_ofAttributesOfHyperInterface_withPriority_
                ,self,sel_cardAttributesDidChange_,uVar1,&DAT_0036d838,0xbe800000);
  pvVar3 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_0036d8d8);
  pvVar3 = _objc_msgSend(pvVar3,sel_attributeObservingController);
  _objc_msgSend(pvVar3,sel_addObserver_selector_ofChanges_ofAttribute_withPriority_,self,
                sel_cardCommentsAttributesDidChange_,uVar1,&DAT_0036d8ec,0xbe800000);
  pvVar3 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_0036d900);
  pvVar3 = _objc_msgSend(pvVar3,sel_attributeObservingController);
  puVar6 = &DAT_0036d914;
  uVar7 = 0xbe800000;
  puVar4 = sel_cardCursorAttributesDidChange_;
  uVar5 = uVar1;
  _objc_msgSend(pvVar3,sel_addObserver_selector_ofChanges_ofAttribute_withPriority_,self,
                sel_cardCursorAttributesDidChange_,uVar1,&DAT_0036d914,0xbe800000);
  if (self->_objectParentObserver == (id)0x0) {
    pvVar3 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_0036d928,puVar4,uVar5,puVar6,uVar7);
    pvVar3 = _objc_msgSend(pvVar3,sel_hyperParent);
    pvVar3 = _objc_msgSend(pvVar3,sel_retain);
    self->_objectParentObserver = pvVar3;
    pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_0036d900);
    pvVar3 = _objc_msgSend(pvVar3,sel_attributeObservingController);
    puVar6 = &DAT_0036d914;
    uVar7 = 0xbe800000;
    puVar4 = sel_cardCursorAttributesDidChange_;
    uVar5 = uVar1;
    _objc_msgSend(pvVar3,sel_addObserver_selector_ofChanges_ofAttribute_withPriority_,self,
                  sel_cardCursorAttributesDidChange_,uVar1,&DAT_0036d914,0xbe800000);
  }
  pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_0036d98c,puVar4,uVar5,puVar6,uVar7);
  pvVar3 = _objc_msgSend(pvVar2,sel_attributeObservingController);
  _objc_msgSend(pvVar3,sel_addObserver_selector_ofChanges_ofAttributesOfHyperInterface_withPriority_
                ,self,sel_HSCardAssistantPane_actorDidChange_,uVar1,&DAT_0036d98c,0xbe800000);
  pvVar3 = _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_,*(undefined4 *)PTR_003363a8);
  pvVar2 = _objc_msgSend(pvVar2,sel_automaticTimerForActionEvent_,pvVar3);
  pvVar2 = _objc_msgSend(pvVar2,sel_attributeObservingController);
  _objc_msgSend(pvVar2,sel_addObserver_selector_ofChanges_ofAttributesOfHyperInterface_withPriority_
                ,self,sel_HSCardAssistantPane_automaticTimerDidChange_,uVar1,&DAT_0036da40,
                0xbe800000);
  return;
}

*/
- (void)subscribeToNotifications
{
    id object = [[self assistant] object];
    NSUInteger changes = HSActualDidAttributeChanges;
    [[[object queryHyperInterface:@protocol(HSCardAttributes)] attributeObservingController] addObserver:self selector:@selector(cardAttributesDidChange:) ofChanges:changes ofAttributesOfHyperInterface:@protocol(HSCardAttributes) withPriority:-0.25];
    [[[object queryHyperInterface:@protocol(HSCommentsAttributes)] attributeObservingController] addObserver:self selector:@selector(cardCommentsAttributesDidChange:) ofChanges:changes ofAttribute:@protocol(HSCommentsAttribute) withPriority:-0.25];
    [[[object queryHyperInterface:@protocol(HSCursorAttributes)] attributeObservingController] addObserver:self selector:@selector(cardCursorAttributesDidChange:) ofChanges:changes ofAttribute:@protocol(HSCursorAttribute) withPriority:-0.25];
    if (_objectParentObserver == nil) {
        _objectParentObserver = [[[object queryHyperInterface:@protocol(HSNodeChild)] hyperParent] retain];
        [[[_objectParentObserver queryHyperInterface:@protocol(HSCursorAttributes)] attributeObservingController] addObserver:self selector:@selector(cardCursorAttributesDidChange:) ofChanges:changes ofAttribute:@protocol(HSCursorAttribute) withPriority:-0.25];
    }
    id<HSActor> actor = [object queryHyperInterface:@protocol(HSActor)];
    [[actor attributeObservingController] addObserver:self selector:@selector(HSCardAssistantPane_actorDidChange:) ofChanges:changes ofAttributesOfHyperInterface:@protocol(HSActor) withPriority:-0.25];
    id timer = [actor automaticTimerForActionEvent:[HSActionEvent actionEventOfType:kHSDefaultActionEventType]];
    [[timer attributeObservingController] addObserver:self selector:@selector(HSCardAssistantPane_automaticTimerDidChange:) ofChanges:changes ofAttributesOfHyperInterface:@protocol(HSAutomaticTimerAttributes) withPriority:-0.25];
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    id pvVar2;

    [super viewWillDisappear:aDisappear];
    pvVar2 = _commentsTextView;
    [self commentsChanged:pvVar2];
    if ([_commentsTextView delegate] == self) {
        pvVar2 = nil;
        [_commentsTextView setDelegate:0];
    }
    if ([_cardTitleField delegate] == self) {
        pvVar2 = nil;
        [_cardTitleField setDelegate:0];
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
    [_cardTitleField setDelegate:self];
    [self subscribeToNotifications];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ea5f5 @ 000ea5f5, 85 bytes * /

void FUN_000ea5f5(HSCardAssistantPane *self,SEL _cmd,id openPaneWithIdentifier)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(openPaneWithIdentifier,sel_isEqualToString_,*(undefined4 *)PTR_PTR_00336018
                        );
  if ((char)pvVar1 != '\0') {
    _objc_msgSend(self,sel_editClickingThisCard_,0);
  }
  return;
}

*/
- (void)openPaneWithIdentifier:(id)aIdentifier
{
    if ([aIdentifier isEqualToString:@"HSActionsAssistantPane"]) {
        [self editClickingThisCard:nil];
    }
}

- (id)init
{
    return [self initWithNibName:@"CardAssistantPane"];
}

- (id)assistantPaneUndoManager
{
    return [[self modalViewController] assistantPaneUndoManager];
}

@end

