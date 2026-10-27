#import "HSScrollCardActionAssistantPane.h"

@implementation HSScrollCardActionAssistantPane

/* i386 ivar offsets: _setScrollPositionButton=0x88, _scrollCardPositionAssistantPane=0x8c */

- (void)setScrollCardPositionAssistantPane:(id)aPane closeWithPosition:(NSPoint)aPosition
{
    [[self scrollCardActionAssistantPaneApplier] setScrollPoint:aPosition];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024cdb8 @ 0024cdb8, 253 bytes * /

void FUN_0024cdb8(HSScrollCardActionAssistantPane *self,SEL _cmd,id chooseScrollPosition)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  HSScrollCardActionAssistantPane *pHVar3;
  
  pvVar1 = _objc_msgSend(self,sel_isHelpVisible);
  if ((char)pvVar1 != '\0') {
    _objc_msgSend(self,sel_hideHelpNeedsRelayout_,1);
  }
  pvVar1 = _objc_msgSend(self,sel_scrollCardPositionAssistantPane);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_actionAttributes);
    _objc_msgSend(pvVar1,sel_setPositionAttributes_,pvVar2);
    pHVar3 = self;
    _objc_msgSend(pvVar1,sel_setDelegate_,self);
    pvVar2 = _objc_msgSend(self,sel_objectAssistantNavigationController);
    op = sel_presentModalViewControllerAsRootViewController_;
    if (pvVar2 != (id)0x0) {
      self = _objc_msgSend(self,sel_objectAssistantNavigationController,pHVar3);
      op = sel_pushViewController_animate_;
    }
    _objc_msgSend(self,op,pvVar1);
  }
  return;
}

*/
- (void)chooseScrollPosition:(id)aPosition
{
    if ([self isHelpVisible]) {
        [self hideHelpNeedsRelayout:YES];
    }
    id pane = [self scrollCardPositionAssistantPane];
    if (pane != nil) {
        [pane setPositionAttributes:[self actionAttributes]];
        [pane setDelegate:self];
        if ([self objectAssistantNavigationController] != nil) {
            [[self objectAssistantNavigationController] pushViewController:pane animate:YES];
        } else {
            [self presentModalViewControllerAsRootViewController:pane];
        }
    }
}

- (id)scrollCardPositionAssistantPane
{
    HSScrollCardPositionAssistantPane *pHVar2;
    HSScrollCardPositionAssistantPane *pHVar2_2;

    pHVar2 = _scrollCardPositionAssistantPane;
    if (pHVar2 == nil) {
        pHVar2_2 = [[HSScrollCardPositionAssistantPane alloc] initWithCoachingKey:@"SetScrollCardPosition"];
        _scrollCardPositionAssistantPane = pHVar2_2;
        [pHVar2_2 setWindowTitle:[self windowTitle]];
        pHVar2 = _scrollCardPositionAssistantPane;
    }
    return pHVar2;
}

- (id)initialKeyView
{
    return _setScrollPositionButton;
}

- (id)helpTopicKey
{
    return @"HSScrollCard";
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    if ([_scrollCardPositionAssistantPane delegate] == self) {
        [_scrollCardPositionAssistantPane setDelegate:0];
    }
}

- (id)actionAttributes
{
    return [[self scrollCardActionAssistantPaneApplier] scrollCardActionAttributes];
}

- (id)scrollCardActionAssistantPaneApplier
{
    return [self applier];
}

- (Class)applierClass
{
    return [HSScrollCardActionAssistantPaneApplier class];
}

- (id)actionAttribute
{
    return (id)@protocol(HSScrollCardActionAttributes);
}

- (id)actionType
{
    return [HSScrollCardAction actionType];
}

- (void)dealloc
{
    if ([_scrollCardPositionAssistantPane delegate] == self) {
        [_scrollCardPositionAssistantPane setDelegate:0];
    }
    [_scrollCardPositionAssistantPane release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"ScrollCardAssistantPane"];
    return self;
}

@end

@implementation HSScrollCardActionAssistantPaneApplier

/* i386 ivar offsets: _initialScrollPoint=0x30, _scrollPoint=0x38 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024d012 @ 0024d012, 115 bytes * /

BOOL FUN_0024d012(HSScrollCardActionAssistantPaneApplier *self,SEL _cmd)

{
  byte bVar1;
  id pvVar2;
  HSScrollCardActionAssistantPaneApplier *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_HSActionAssistantSettingsApplier_00355cd0;
  pvVar2 = _objc_msgSendSuper(&local_14,sel_areSettingsEqual);
  bVar1 = _NSEqualPoints((self->_initialScrollPoint).x,(self->_initialScrollPoint).y,
                         (self->_scrollPoint).x,(self->_scrollPoint).y);
  return (char)pvVar2 != '\0' & bVar1;
}

*/
- (BOOL)areSettingsEqual
{
    BOOL equal = [super areSettingsEqual];
    return equal & NSEqualPoints(_initialScrollPoint, _scrollPoint);
    return 0;
}

- (void)makeCurrentEqualToInitial
{
    float fVar1;

    [super makeCurrentEqualToInitial];
    fVar1 = (_initialScrollPoint).y;
    (_scrollPoint).x = (_initialScrollPoint).x;
    (_scrollPoint).y = fVar1;
}

- (void)makeInitialEqualToCurrent
{
    float fVar1;

    [super makeInitialEqualToCurrent];
    fVar1 = (_scrollPoint).y;
    (_initialScrollPoint).x = (_scrollPoint).x;
    (_initialScrollPoint).y = fVar1;
}

- (void)setInitialSettingsToObject
{
    [[self scrollCardActionAttributes] setScrollPoint:(_initialScrollPoint)];
    [super setInitialSettingsToObject];
}

- (void)setCurrentSettingsToObject
{
    [super setCurrentSettingsToObject];
    [[self scrollCardActionAttributes] setScrollPoint:(_scrollPoint)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024cc30 @ 0024cc30, 72 bytes * /

void FUN_0024cc30(HSScrollCardActionAssistantPaneApplier *self,SEL _cmd)

{
  id pvVar1;
  float extraout_EDX;
  
  pvVar1 = _objc_msgSend(self,sel_scrollCardActionAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_scrollPoint);
  (self->_scrollPoint).x = (float)pvVar1;
  (self->_scrollPoint).y = extraout_EDX;
  (self->_initialScrollPoint).x = (float)pvVar1;
  (self->_initialScrollPoint).y = extraout_EDX;
  return;
}

*/
- (void)setUpInitialSettings
{
    _scrollPoint = [[self scrollCardActionAttributes] scrollPoint];
    _initialScrollPoint = _scrollPoint;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024cf05 @ 0024cf05, 154 bytes * /

void FUN_0024cf05(HSScrollCardActionAssistantPaneApplier *self,SEL _cmd,NSPoint setScrollPoint)

{
  char cVar1;
  id self_00;
  
  cVar1 = _NSEqualPoints(setScrollPoint.x,setScrollPoint.y,(self->_scrollPoint).x,
                         (self->_scrollPoint).y);
  if (cVar1 == '\0') {
    (self->_scrollPoint).x = setScrollPoint.x;
    (self->_scrollPoint).y = setScrollPoint.y;
    self_00 = _objc_msgSend(self,sel_scrollCardActionAttributes);
    _objc_msgSend(self_00,sel_setScrollPoint_,(self->_scrollPoint).x,(self->_scrollPoint).y);
  }
  return;
}

*/
- (void)setScrollPoint:(NSPoint)aPoint
{
    if (!NSEqualPoints(aPoint, _scrollPoint)) {
        _scrollPoint = aPoint;
        [[self scrollCardActionAttributes] setScrollPoint:_scrollPoint];
    }
}

- (id)scrollCardActionAttributes
{
    return [[self actionAttributes] queryHyperInterface:@protocol(HSScrollCardActionAttributes)];
}

@end

