#import "HSStackAssistantPane.h"

@implementation HSStackAssistantPane

/* i386 ivar offsets: _stackNameTextField=0x5c, _stackSizeTextField=0x60, _numberOfCardsField=0x64, _commentsTextView=0x68, _cursorImageView=0x6c, _cursorButton=0x70, _lockStackButton=0x74, _presentationModeButton=0x78, _arriveThisStackSwitch=0x7c, _leaveThisStackSwitch=0x80, _clickThisStackSwitch=0x84, _arriveThisStackButton=0x88, _leaveThisStackButton=0x8c, _clickThisStackButton=0x90 */

+ (BOOL)canEditObject:(id)aObject
{
    return (BOOL)[aObject implementsHyperInterface:@protocol(HSMutableStackAttributes)];
}

- (void)openActionsPaneForClickEvent:(id)aEvent
{
    [self openActionsAssistantForActionEvent:[HSActionEvent actionEventOfType:kHSClickActionEventType] animate:NO];
}

- (void)editClickThisStack:(id)aStack
{
    [self openActionsAssistantForActionEvent:[HSActionEvent actionEventOfType:kHSClickActionEventType] animate:YES];
}

- (void)editLeaveThisStack:(id)aStack
{
    [self openActionsAssistantForActionEvent:[HSActionEvent actionEventOfType:kHSLeaveActionEventType] animate:YES];
}

- (void)editArriveThisStack:(id)aStack
{
    [self openActionsAssistantForActionEvent:[HSActionEvent actionEventOfType:kHSArriveActionEventType] animate:YES];
}

- (void)editPresentationMode:(id)aMode
{
    id self_00;
    id pvVar1_2;

    self_00 = [HSPresentationAssistantPane new];
    pvVar1_2 = [[HSObjectAssistantNavigationController alloc] initWithRootViewController:self_00];
    [self presentModalViewController:pvVar1_2 animated:YES];
    [pvVar1_2 release];
    [self_00 release];
}

- (void)editLockStackState:(id)aState
{
    id self_00;
    id pvVar1_2;

    self_00 = [HSLockStackAssistantPane new];
    pvVar1_2 = [[HSObjectAssistantNavigationController alloc] initWithRootViewController:self_00];
    [self presentModalViewController:pvVar1_2 animated:YES];
    [pvVar1_2 release];
    [self_00 release];
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

- (void)editCardSize:(id)aSize
{
    id pvVar1_2;
    id pvVar1_3;

    pvVar1_2 = [[HSStackSizesAssistantPane new] autorelease];
    pvVar1_3 = [[HSObjectAssistantNavigationController alloc] initWithRootViewController:pvVar1_2];
    [self presentModalViewController:pvVar1_3 animated:YES];
    [pvVar1_3 release];
}

- (void)clickingThisStackChanged:(id)aChanged
{
    [self handleActionsAssistantForActionEvent:[HSActionEvent actionEventOfType:kHSClickActionEventType]];
}

- (void)leaveThisStackChanged:(id)aChanged
{
    [self handleActionsAssistantForActionEvent:[HSActionEvent actionEventOfType:kHSLeaveActionEventType]];
}

- (void)arriveThisStackChanged:(id)aChanged
{
    [self handleActionsAssistantForActionEvent:[HSActionEvent actionEventOfType:kHSArriveActionEventType]];
}

- (void)commentsChanged:(id)aChanged
{
    id pvVar1_2;

    pvVar1_2 = [[_commentsTextView string] copy];
    [[[[self assistant] object] queryHyperInterface:@protocol(HSCommentsAttributes)] setHyperComments:pvVar1_2];
    [pvVar1_2 release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0011e4b4 @ 0011e4b4, 286 bytes * /

void FUN_0011e4b4(HSStackAssistantPane *self,SEL _cmd,id setPresentationMode)

{
  id pvVar1;
  id self_00;
  id self_01;
  SEL op;
  
  pvVar1 = _objc_msgSend(setPresentationMode,sel_state);
  if (pvVar1 == (id)0x1) {
    self_00 = _objc_msgSend(cls_HSPresentationAssistantPane,sel_new);
    pvVar1 = _objc_msgSend(cls_HSObjectAssistantNavigationController,sel_alloc);
    self_01 = _objc_msgSend(pvVar1,sel_initWithRootViewController_,self_00);
    pvVar1 = self_01;
    _objc_msgSend(self,sel_presentModalViewController_animated_,self_01,1);
    _objc_msgSend(self_01,sel_release);
    op = sel_release;
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_assistant);
    pvVar1 = _objc_msgSend(pvVar1,sel_object);
    self_00 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00371bcc);
    pvVar1 = (id)0x0;
    op = sel_setBackgroundGraphics_;
  }
  _objc_msgSend(self_00,op,pvVar1);
  return;
}

*/
- (void)setPresentationMode:(id)aMode
{
    if ([aMode state] == 1) {
        id pane = [HSPresentationAssistantPane new];
        id navigation = [[HSObjectAssistantNavigationController alloc] initWithRootViewController:pane];
        [self presentModalViewController:navigation animated:YES];
        [navigation release];
        [pane release];
    } else {
        [[[[self assistant] object] queryHyperInterface:@protocol(HSMutableBackgroundAttributes)] setBackgroundGraphics:nil];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0011e36f @ 0011e36f, 325 bytes * /

void FUN_0011e36f(HSStackAssistantPane *self,SEL _cmd,id textDidChange)

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
    NSAttributedString *links = [[_commentsTextView string] hyperAttributedStringWithRecognizedLinks];
    NSRange selection = [_commentsTextView selectedRange];
    [[_commentsTextView textStorage] replaceCharactersInRange:NSMakeRange(0, [[_commentsTextView textStorage] length]) withAttributedString:links];
    if (selection.location + selection.length < [[_commentsTextView string] length]) {
        [_commentsTextView setSelectedRange:selection];
    }
    [self commentsChanged:nil];
}

- (void)documentTitleChanged:(id)aChanged
{
    [self validateStackName];
}

- (void)HSStackAssistantPane_automaticTimerDidChange:(id)aChange
{
    [self validateActionSwitches];
}

- (void)HSStackAssistantPane_actorDidChange:(id)aChange
{
    [self validateActionSwitches];
}

- (void)stackCursorAttributesDidChange:(id)aChange
{
    [self validateCursorView];
}

- (void)stackCommentsAttributesDidChange:(id)aChange
{
    [self validateCommentsView];
}

- (void)textDidEndEditing:(id)aEditing
{
    [self commentsChanged:[aEditing object]];
}

- (void)stackContainerAttributesDidChange:(id)aChange
{
    [self validateNumberOfCards];
}

- (void)stackAttributesDidChange:(id)aChange
{
    [self validateStackName];
    [self validateStackSizeField];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0011ed3f @ 0011ed3f, 1446 bytes * /

void FUN_0011ed3f(HSStackAssistantPane *self,SEL _cmd)

{
  bool bVar1;
  id pvVar2;
  id self_00;
  id pvVar3;
  id pvVar4;
  cfstringStruct *pcVar5;
  int *piVar6;
  int *piVar7;
  int *piVar8;
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
  self_00 = _objc_msgSend(pvVar2,sel_automaticTimerForActionEvent_);
  _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_);
  pvVar3 = _objc_msgSend(pvVar2,sel_hyperActionsForEvent_);
  pvVar3 = _objc_msgSend(pvVar3,sel_count);
  _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_);
  pvVar4 = _objc_msgSend(pvVar2,sel_hyperActionsForEvent_);
  pvVar4 = _objc_msgSend(pvVar4,sel_count);
  _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_);
  pvVar2 = _objc_msgSend(pvVar2,sel_hyperActionsForEvent_);
  pvVar2 = _objc_msgSend(pvVar2,sel_count);
  if ((pvVar2 == (id)0x0) &&
     (pvVar2 = _objc_msgSend(self_00,sel_runActionsAutomatically), (char)pvVar2 == '\0')) {
    bVar1 = false;
  }
  else {
    bVar1 = true;
  }
  _objc_msgSend(self->_arriveThisStackSwitch,sel_setState_);
  _objc_msgSend(self->_leaveThisStackSwitch,sel_setState_);
  _objc_msgSend(self->_clickThisStackSwitch,sel_setState_);
  _objc_msgSend(self->_arriveThisStackButton,sel_setHidden_);
  _objc_msgSend(self->_leaveThisStackButton,sel_setHidden_);
  _objc_msgSend(self->_clickThisStackButton,sel_setHidden_);
  _objc_msgSend(self->_arriveThisStackButton,sel_setEnabled_);
  _objc_msgSend(self->_leaveThisStackButton,sel_setEnabled_);
  _objc_msgSend(self->_clickThisStackButton,sel_setEnabled_);
  _objc_msgSend_stret(&local_54,self->_arriveThisStackSwitch,sel_frame);
  piVar6 = (int *)&stack0xffffff60;
  local_4c = fStack_48;
  if (pvVar3 == (id)0x0) {
    aiStack_b8[5] = 0x11f08f;
    _objc_msgSend_stret(local_44,self->_arriveThisStackButton,sel_frame);
    piVar6 = aiStack_b8 + 5;
    local_4c = (local_44[0] + local_3c) - local_54;
  }
  pvVar2 = self->_arriveThisStackSwitch;
  *(ulonglong *)(piVar6 + 4) = CONCAT44(fStack_48,local_4c);
  *(ulonglong *)(piVar6 + 2) = CONCAT44(uStack_50,local_54);
  piVar6[1] = (int)sel_setFrame_;
  *piVar6 = (int)pvVar2;
  piVar6[-1] = 0x11f0d4;
  _objc_msgSend((id)*piVar6,(SEL)piVar6[1]);
  pvVar2 = self->_leaveThisStackSwitch;
  piVar6[2] = (int)sel_frame;
  piVar6[1] = (int)pvVar2;
  *piVar6 = (int)&local_64;
  piVar6[-1] = 0x11f0f3;
  _objc_msgSend_stret((void *)*piVar6,(id)piVar6[1],(SEL)piVar6[2]);
  piVar7 = piVar6 + -1;
  local_5c = fStack_58;
  if (pvVar4 == (id)0x0) {
    pvVar2 = self->_leaveThisStackButton;
    piVar6[1] = (int)sel_frame;
    *piVar6 = (int)pvVar2;
    piVar6[-1] = (int)local_34;
    piVar6[-2] = 0x11f125;
    _objc_msgSend_stret((void *)piVar6[-1],(id)*piVar6,(SEL)piVar6[1]);
    piVar7 = piVar6 + -2;
    local_5c = (local_34[0] + local_2c) - local_64;
  }
  pvVar2 = self->_leaveThisStackSwitch;
  *(ulonglong *)(piVar7 + 4) = CONCAT44(fStack_58,local_5c);
  *(ulonglong *)(piVar7 + 2) = CONCAT44(uStack_60,local_64);
  piVar7[1] = (int)sel_setFrame_;
  *piVar7 = (int)pvVar2;
  piVar7[-1] = 0x11f16d;
  _objc_msgSend((id)*piVar7,(SEL)piVar7[1]);
  pvVar2 = self->_clickThisStackSwitch;
  piVar7[2] = (int)sel_frame;
  piVar7[1] = (int)pvVar2;
  *piVar7 = (int)&local_74;
  piVar7[-1] = 0x11f18c;
  _objc_msgSend_stret((void *)*piVar7,(id)piVar7[1],(SEL)piVar7[2]);
  piVar8 = piVar7 + -1;
  local_6c = fStack_68;
  if (!bVar1) {
    pvVar2 = self->_clickThisStackButton;
    piVar7[1] = (int)sel_frame;
    *piVar7 = (int)pvVar2;
    piVar7[-1] = (int)local_24;
    piVar7[-2] = 0x11f1bd;
    _objc_msgSend_stret((void *)piVar7[-1],(id)*piVar7,(SEL)piVar7[1]);
    piVar8 = piVar7 + -2;
    local_6c = (local_24[0] + local_1c) - local_74;
  }
  pvVar2 = self->_clickThisStackSwitch;
  *(ulonglong *)(piVar8 + 4) = CONCAT44(fStack_68,local_6c);
  *(ulonglong *)(piVar8 + 2) = CONCAT44(uStack_70,local_74);
  piVar8[1] = (int)sel_setFrame_;
  *piVar8 = (int)pvVar2;
  piVar8[-1] = 0x11f205;
  _objc_msgSend((id)*piVar8,(SEL)piVar8[1]);
  if (pvVar3 == (id)0x0) {
    pvVar2 = self->_arriveThisStackButton;
    piVar8[1] = (int)sel_title;
    *piVar8 = (int)pvVar2;
    piVar8[-1] = 0x11f22e;
    pcVar5 = _objc_msgSend((id)*piVar8,(SEL)piVar8[1]);
  }
  else {
    pcVar5 = &cfstr_empty;
  }
  pvVar2 = self->_arriveThisStackSwitch;
  piVar8[2] = (int)pcVar5;
  piVar8[1] = (int)sel_setTitle_;
  *piVar8 = (int)pvVar2;
  piVar8[-1] = 0x11f24a;
  _objc_msgSend((id)*piVar8,(SEL)piVar8[1]);
  if (pvVar4 == (id)0x0) {
    pvVar2 = self->_leaveThisStackButton;
    piVar8[1] = (int)sel_title;
    *piVar8 = (int)pvVar2;
    piVar8[-1] = 0x11f273;
    pcVar5 = _objc_msgSend((id)*piVar8,(SEL)piVar8[1]);
  }
  else {
    pcVar5 = &cfstr_empty;
  }
  pvVar2 = self->_leaveThisStackSwitch;
  piVar8[2] = (int)pcVar5;
  piVar8[1] = (int)sel_setTitle_;
  *piVar8 = (int)pvVar2;
  piVar8[-1] = 0x11f292;
  _objc_msgSend((id)*piVar8,(SEL)piVar8[1]);
  if (bVar1) {
    pcVar5 = &cfstr_empty;
  }
  else {
    pvVar2 = self->_clickThisStackButton;
    piVar8[1] = (int)sel_title;
    *piVar8 = (int)pvVar2;
    piVar8[-1] = 0x11f2bb;
    pcVar5 = _objc_msgSend((id)*piVar8,(SEL)piVar8[1]);
  }
  pvVar2 = self->_clickThisStackSwitch;
  piVar8[2] = (int)pcVar5;
  piVar8[1] = (int)sel_setTitle_;
  *piVar8 = (int)pvVar2;
  piVar8[-1] = 0x11f2da;
  _objc_msgSend((id)*piVar8,(SEL)piVar8[1]);
  return;
}

*/
- (void)validateActionSwitches
{
    id actor = [[[self assistant] object] queryHyperInterface:@protocol(HSActor)];
    id timer = [actor automaticTimerForActionEvent:[HSActionEvent actionEventOfType:kHSDefaultActionEventType]];
    BOOL arrive = [[actor hyperActionsForEvent:[HSActionEvent actionEventOfType:kHSArriveActionEventType]] count] != 0;
    BOOL leave = [[actor hyperActionsForEvent:[HSActionEvent actionEventOfType:kHSLeaveActionEventType]] count] != 0;
    BOOL click = [[actor hyperActionsForEvent:[HSActionEvent actionEventOfType:kHSClickActionEventType]] count] != 0 || [timer runActionsAutomatically];
    [_arriveThisStackSwitch setState:arrive];
    [_leaveThisStackSwitch setState:leave];
    [_clickThisStackSwitch setState:click];
    [_arriveThisStackButton setHidden:!arrive];
    [_leaveThisStackButton setHidden:!leave];
    [_clickThisStackButton setHidden:!click];
    [_arriveThisStackButton setEnabled:arrive];
    [_leaveThisStackButton setEnabled:leave];
    [_clickThisStackButton setEnabled:click];
    /* a switch without actions stretches over its (hidden) button and takes its title */
    NSRect frame = [_arriveThisStackSwitch frame];
    if (!arrive) {
        NSRect buttonFrame = [_arriveThisStackButton frame];
        frame.size.width = (buttonFrame.origin.x + buttonFrame.size.width) - frame.origin.x;
    }
    [_arriveThisStackSwitch setFrame:frame];
    frame = [_leaveThisStackSwitch frame];
    if (!leave) {
        NSRect buttonFrame = [_leaveThisStackButton frame];
        frame.size.width = (buttonFrame.origin.x + buttonFrame.size.width) - frame.origin.x;
    }
    [_leaveThisStackSwitch setFrame:frame];
    frame = [_clickThisStackSwitch frame];
    if (!click) {
        NSRect buttonFrame = [_clickThisStackButton frame];
        frame.size.width = (buttonFrame.origin.x + buttonFrame.size.width) - frame.origin.x;
    }
    [_clickThisStackSwitch setFrame:frame];
    [_arriveThisStackSwitch setTitle:arrive ? @"" : [_arriveThisStackButton title]];
    [_leaveThisStackSwitch setTitle:leave ? @"" : [_leaveThisStackButton title]];
    [_clickThisStackSwitch setTitle:click ? @"" : [_clickThisStackButton title]];
}

- (void)validateCursorView
{
    id pvVar1_4;

    pvVar1_4 = [[[[self assistant] object] queryHyperInterface:@protocol(HSCursorAttributes)] hyperCursor];
    if (pvVar1_4 == nil) {
        pvVar1_4 = [HSCursor defaultPlayerCursor];
    }
    [_cursorImageView setImage:[pvVar1_4 image]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0011dff0 @ 0011dff0, 365 bytes * /

void FUN_0011dff0(HSStackAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  int extraout_EDX;
  undefined *puVar5;
  
  pvVar1 = _objc_msgSend(self,sel_assistant);
  pvVar1 = _objc_msgSend(pvVar1,sel_object);
  puVar5 = &DAT_00371a8c;
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00371a8c);
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
    NSAttributedString *comments = [[[[[self assistant] object] queryHyperInterface:@protocol(HSCommentsAttributes)] hyperComments] hyperAttributedStringWithRecognizedLinks];
    if (comments != nil) {
        NSRange selection = [_commentsTextView selectedRange];
        [[_commentsTextView textStorage] replaceCharactersInRange:NSMakeRange(0, [[_commentsTextView textStorage] length]) withAttributedString:comments];
        if (selection.location + selection.length < [[_commentsTextView string] length]) {
            [_commentsTextView setSelectedRange:selection];
        }
    }
}

- (void)validateNumberOfCards
{
    NSBundle *pvVar2;
    id pcVar4;
    NSUInteger pvVar1_4;

    pvVar1_4 = [[[[self assistant] object] queryHyperInterface:@protocol(HSNodeContainer)] hyperCount];
    pvVar2 = [NSBundle mainBundle];
    if ((int)pvVar1_4 < 2) {
        pcVar4 = @"%d card";
    }
    else {
        pcVar4 = @"%d cards";
    }
    [_numberOfCardsField setStringValue:[NSString stringWithFormat:[pvVar2 localizedStringForKey:pcVar4 value:@"" table:0], pvVar1_4]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0011de4a @ 0011de4a, 149 bytes * /

void FUN_0011de4a(HSStackAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  float extraout_EDX;
  
  pvVar1 = _objc_msgSend(self,sel_stackAttributes);
  pvVar2 = _objc_msgSend(pvVar1,sel_hyperCardSize);
  pvVar1 = self->_stackSizeTextField;
  pvVar2 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr__0_0f_x__0_0f,
                         (double)(float)pvVar2,(double)extraout_EDX);
  _objc_msgSend(pvVar1,sel_setStringValue_,pvVar2);
  return;
}

*/
- (void)validateStackSizeField
{
    NSSize size = [[self stackAttributes] hyperCardSize];
    [_stackSizeTextField setStringValue:[NSString stringWithFormat:@"%0.0f x %0.0f", (double)size.width, (double)size.height]];
}

- (void)validateStackName
{
    id pcVar2;

    pcVar2 = [[[self stackAttributes] document] displayName];
    if (pcVar2 == NULL) {
        pcVar2 = @"";
    }
    [_stackNameTextField setStringValue:pcVar2];
}

- (void)validateUI
{
    [self validateStackName];
    [self validateStackSizeField];
    [self validateNumberOfCards];
    [self validateCommentsView];
    [self validateCursorView];
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
/* FUN_0011dabf @ 0011dabf, 441 bytes * /

void FUN_0011dabf(HSStackAssistantPane *self,SEL _cmd,id handleActionsAssistantForActionEvent)

{
  id pvVar1;
  HSStackAssistantPane *self_00;
  id pvVar2;
  HSStackAssistantPane *self_01;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_assistant);
  pvVar1 = _objc_msgSend(pvVar1,sel_object);
  self_00 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00371adc);
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
    id actor = [[[self assistant] object] queryHyperInterface:@protocol(HSActor)];
    NSUInteger count = [[actor hyperActionsForEvent:aEvent] count];
    if ([aEvent isEqual:[HSActionEvent actionEventOfType:kHSArriveActionEventType]]) {
        if (count != 0) {
            [actor removeActions:[actor hyperActionsForEvent:aEvent]];
        } else {
            [self openActionsAssistantForActionEvent:aEvent animate:YES];
        }
    } else {
        id timer = [actor automaticTimerForActionEvent:aEvent];
        BOOL automatic = [timer runActionsAutomatically];
        if (count == 0 && !automatic) {
            [self openActionsAssistantForActionEvent:aEvent animate:YES];
        } else {
            if (count != 0) {
                [actor removeActions:[actor hyperActionsForEvent:aEvent]];
            }
            if (automatic) {
                [timer setRunActionsAutomatically:NO];
            }
        }
    }
}

- (void)unsubscribeFromNotifications
{
    int uVar1;
    id pvVar2_2;
    id pvVar3_2;
    id pvVar3_9;

    pvVar2_2 = [[self assistant] object];
    pvVar3_2 = [[pvVar2_2 queryHyperInterface:@protocol(HSMutableStackAttributes)] attributeObservingController];
    uVar1 = HSActualDidAttributeChanges;
    [pvVar3_2 removeObserver:self selector:@selector(stackAttributesDidChange:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSMutableStackAttributes)];
    [[[pvVar2_2 queryHyperInterface:@protocol(HSNodeContainer)] attributeObservingController] removeObserver:self selector:@selector(stackContainerAttributesDidChange:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSNodeContainer)];
    [[[pvVar2_2 queryHyperInterface:@protocol(HSCommentsAttributes)] attributeObservingController] removeObserver:self selector:@selector(stackCommentsAttributesDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSCommentsAttribute)];
    [[[pvVar2_2 queryHyperInterface:@protocol(HSCursorAttributes)] attributeObservingController] removeObserver:self selector:@selector(stackCursorAttributesDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSCursorAttribute)];
    pvVar3_9 = [pvVar2_2 queryHyperInterface:@protocol(HSActor)];
    [[pvVar3_9 attributeObservingController] removeObserver:self selector:@selector(HSStackAssistantPane_actorDidChange:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSActor)];
    [[[pvVar3_9 automaticTimerForActionEvent:[HSActionEvent actionEventOfType:kHSDefaultActionEventType]] attributeObservingController] removeObserver:self selector:@selector(HSStackAssistantPane_automaticTimerDidChange:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSAutomaticTimerAttributes)];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HSDocumentTitleHasChangedNotification object:pvVar2_2];
}

- (void)subscribeToNotifications
{
    int uVar1;
    id pvVar2_2;
    id pvVar3_2;
    id pvVar3_9;

    pvVar2_2 = [[self assistant] object];
    pvVar3_2 = [[pvVar2_2 queryHyperInterface:@protocol(HSMutableStackAttributes)] attributeObservingController];
    uVar1 = HSActualDidAttributeChanges;
    [pvVar3_2 addObserver:self selector:@selector(stackAttributesDidChange:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSMutableStackAttributes) withPriority:-0.25];
    [[[pvVar2_2 queryHyperInterface:@protocol(HSNodeContainer)] attributeObservingController] addObserver:self selector:@selector(stackContainerAttributesDidChange:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSNodeContainer) withPriority:-0.25];
    [[[pvVar2_2 queryHyperInterface:@protocol(HSCommentsAttributes)] attributeObservingController] addObserver:self selector:@selector(stackCommentsAttributesDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSCommentsAttribute) withPriority:-0.25];
    [[[pvVar2_2 queryHyperInterface:@protocol(HSCursorAttributes)] attributeObservingController] addObserver:self selector:@selector(stackCursorAttributesDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSCursorAttribute) withPriority:-0.25];
    pvVar3_9 = [pvVar2_2 queryHyperInterface:@protocol(HSActor)];
    [[pvVar3_9 attributeObservingController] addObserver:self selector:@selector(HSStackAssistantPane_actorDidChange:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSActor) withPriority:-0.25];
    [[[pvVar3_9 automaticTimerForActionEvent:[HSActionEvent actionEventOfType:kHSDefaultActionEventType]] attributeObservingController] addObserver:self selector:@selector(HSStackAssistantPane_automaticTimerDidChange:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSAutomaticTimerAttributes) withPriority:-0.25];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentTitleChanged:) name:HSDocumentTitleHasChangedNotification object:pvVar2_2];
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
    [self unsubscribeFromNotifications];
}

- (void)viewDidAppear:(BOOL)aAppear
{
    id pvVar1_5;
    id pvVar1_6;

    if ([[[self stackAttributes] document] isStackProtected]) {
        pvVar1_5 = [[HSUnlockStackAssistantPane new] autorelease];
        pvVar1_6 = [[HSObjectAssistantNavigationController alloc] initWithRootViewController:pvVar1_5];
        [self presentModalViewController:pvVar1_6 animated:NO];
        [pvVar1_6 release];
    }
    [super viewDidAppear:aAppear];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [self validateUI];
    [_commentsTextView setDelegate:self];
    [_commentsTextView setUsesFontPanel:NO];
    [_commentsTextView setAllowsUndo:NO];
    if (![[[self stackAttributes] document] isStackProtected]) {
        [self subscribeToNotifications];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0011d3ad @ 0011d3ad, 237 bytes * /

id FUN_0011d3ad(HSStackAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  undefined *puVar3;
  
  pvVar1 = _objc_msgSend(self,sel_assistant);
  pvVar1 = _objc_msgSend(pvVar1,sel_object);
  puVar3 = &DAT_003719b0;
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_003719b0);
  pvVar2 = _objc_msgSend(self,sel_stackAttributes);
  pvVar2 = _objc_msgSend(pvVar2,sel_document);
  pvVar2 = _objc_msgSend(pvVar2,sel_displayName);
  if (pvVar2 == (id)0x0) {
    pvVar2 = _objc_msgSend(pvVar1,sel_hyperName,puVar3);
  }
  puVar3 = cls_NSString;
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperKindDisplayName);
  pvVar1 = _objc_msgSend(puVar3,sel_stringWithFormat_,&cfstr________,pvVar1,pvVar2);
  return pvVar1;
}

*/
- (id)windowTitle
{
    id object = [[[self assistant] object] queryHyperInterface:@protocol(HSObjectAttributes)];
    NSString *name = [[[self stackAttributes] document] displayName];
    if (name == nil) {
        name = [object hyperName];
    }
    return [NSString stringWithFormat:@"%@ : %@", [object hyperKindDisplayName], name];
}

- (id)stackAttributes
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSMutableStackAttributes)];
}

- (id)init
{
    return [self initWithNibName:@"StackAssistantPane"];
}

- (id)assistantPaneUndoManager
{
    return [[self modalViewController] assistantPaneUndoManager];
}

@end

