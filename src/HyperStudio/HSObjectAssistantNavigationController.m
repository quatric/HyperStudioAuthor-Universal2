#import "HSObjectAssistantNavigationController.h"

@implementation HSObjectAssistantNavigationController

/* i386 ivar offsets: _navigationStack=0x5c, _containerView=0x60, _navigationPaneSwitcher=0x64 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_0021ba74 @ 0021ba74, 176 bytes * /

void FUN_0021ba74(HSObjectAssistantNavigationController *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(self->_navigationStack,sel_count);
  if (pvVar1 != (id)0x0) {
    pvVar2 = (id)0x0;
    do {
      self_00 = _objc_msgSend(self,sel_navigationPaneSwitcher);
      _objc_msgSend(self_00,sel_doOK_,0);
      pvVar2 = (id)((int)pvVar2 + 1);
    } while (pvVar2 < pvVar1);
  }
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar1,sel_removeObserver_name_object_,self,*(undefined4 *)PTR_PTR_0033643c,0);
  return;
}

*/
- (void)doubleClickDidDone
{
    NSUInteger count = [_navigationStack count];
    for (NSUInteger i = 0; i < count; i++) {
        [[self navigationPaneSwitcher] doOK:nil];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HSHandleDoubleClickNotification object:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0021bb24 @ 0021bb24, 186 bytes * /

BOOL FUN_0021bb24(HSObjectAssistantNavigationController *self,SEL _cmd,id isViewControllerInStack)

{
  BOOL BVar1;
  id pvVar2;
  id self_00;
  id pvVar3;
  
  if (isViewControllerInStack == (id)0x0) {
    BVar1 = '\0';
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_navigationStack);
    pvVar2 = _objc_msgSend(pvVar2,sel_copy);
    self_00 = _objc_msgSend(pvVar2,sel_objectEnumerator);
    do {
      pvVar3 = _objc_msgSend(self_00,sel_nextObject);
      if (pvVar3 == (id)0x0) {
        BVar1 = '\0';
        goto LAB_0021bbb8;
      }
      pvVar3 = _objc_msgSend(pvVar3,sel_objectForKey_,&cfstr_pane);
    } while (pvVar3 != isViewControllerInStack);
    BVar1 = '\x01';
LAB_0021bbb8:
    _objc_msgSend(pvVar2,sel_release);
  }
  return BVar1;
}

*/
- (BOOL)isViewControllerInStack:(id)aStack
{
    if (aStack == nil) {
        return NO;
    }
    NSArray *stack = [[self navigationStack] copy];
    BOOL found = NO;
    for (NSDictionary *entry in stack) {
        if ([entry objectForKey:@"pane"] == aStack) {
            found = YES;
            break;
        }
    }
    [stack release];
    return found;
}

- (id)viewControllersForPaneIdentifier:(id)aIdentifier
{
    id self_00;
    id self_01;
    NSEnumerator *self_02;
    id pvVar2;
    id pvVar1_2;

    self_00 = [NSMutableArray array];
    if (aIdentifier != nil) {
        self_01 = [[self navigationStack] copy];
        self_02 = [self_01 objectEnumerator];
        pvVar1_2 = [self_02 nextObject];
        while (pvVar1_2 != nil) {
            pvVar2 = [pvVar1_2 objectForKey:@"identifier"];
            if ([pvVar2 isEqualToString:aIdentifier]) {
                [self_00 addObject:[pvVar1_2 objectForKey:@"pane"]];
            }
            pvVar1_2 = [self_02 nextObject];
        }
        [self_01 release];
    }
    return self_00;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0021bd1a @ 0021bd1a, 482 bytes * /

void FUN_0021bd1a(HSObjectAssistantNavigationController *self,SEL _cmd,
                 id changeIdentifierForViewController,id toIdentifier)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  SEL op;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  cfstringStruct *pcVar6;
  
  if (changeIdentifierForViewController != (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_navigationStack);
    pvVar1 = _objc_msgSend(pvVar1,sel_copy);
    self_00 = _objc_msgSend(pvVar1,sel_objectEnumerator);
    while (pvVar5 = _objc_msgSend(self_00,sel_nextObject), pvVar5 != (id)0x0) {
      pvVar4 = _objc_msgSend(pvVar5,sel_objectForKey_,&cfstr_pane);
      if (pvVar4 == changeIdentifierForViewController) {
        pvVar2 = _objc_msgSend(pvVar5,sel_objectForKey_,&cfstr_identifier);
        pvVar4 = toIdentifier;
        pvVar2 = _objc_msgSend(pvVar2,sel_isEqualToString_,toIdentifier);
        if ((char)pvVar2 == '\0') {
          pvVar4 = _objc_msgSend(pvVar5,sel_mutableCopy,pvVar4);
          op = sel_setObject_forKey_;
          pcVar6 = toIdentifier;
          if (toIdentifier == (id)0x0) {
            pcVar6 = &cfstr_identifier;
            op = sel_removeObjectForKey_;
          }
          _objc_msgSend(pvVar4,op,pcVar6);
          pvVar2 = _objc_msgSend(self,sel_navigationStack);
          pvVar3 = _objc_msgSend(pvVar4,sel_copy);
          pvVar3 = _objc_msgSend(pvVar3,sel_autorelease);
          pvVar5 = _objc_msgSend(pvVar1,sel_indexOfObject_,pvVar5);
          _objc_msgSend(pvVar2,sel_replaceObjectAtIndex_withObject_,pvVar5,pvVar3);
          _objc_msgSend(pvVar4,sel_release);
        }
      }
    }
    _objc_msgSend(pvVar1,sel_release);
  }
  return;
}

*/
- (void)changeIdentifierForViewController:(id)aController toIdentifier:(id)aIdentifier
{
    if (aController == nil) {
        return;
    }
    NSArray *stack = [[self navigationStack] copy];
    for (NSDictionary *entry in stack) {
        if ([entry objectForKey:@"pane"] != aController) {
            continue;
        }
        if ([[entry objectForKey:@"identifier"] isEqualToString:aIdentifier]) {
            continue;
        }
        NSMutableDictionary *changed = [entry mutableCopy];
        if (aIdentifier != nil) {
            [changed setObject:aIdentifier forKey:@"identifier"];
        }
        else {
            [changed removeObjectForKey:@"identifier"];
        }
        [[self navigationStack] replaceObjectAtIndex:[stack indexOfObject:entry] withObject:[[changed copy] autorelease]];
        [changed release];
    }
    [stack release];
}

- (BOOL)assistantShouldBeKeyWindow
{
    return (BOOL)[[self topViewController] assistantShouldBeKeyWindow];
}

- (BOOL)canClosePane
{
    BOOL BVar1;

    if (![[self topViewController] respondsToSelector:@selector(canClosePane)]) {
        BVar1 = YES;
    }
    else {
        BVar1 = (BOOL)[[self topViewController] canClosePane];
    }
    return BVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0021bfb1 @ 0021bfb1, 600 bytes * /

void FUN_0021bfb1(HSObjectAssistantNavigationController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  HSObjectAssistantNavigationController *local_14;
  undefined *local_10;
  
  if ((self->super).super._layoutIsValid == '\0') {
    pvVar1 = _objc_msgSend(self,sel_topViewController);
    pvVar1 = _objc_msgSend(pvVar1,sel_view);
    _objc_msgSend(pvVar1,sel_setAutoresizingMask_,0);
    pvVar1 = _objc_msgSend(self,sel_topViewController);
    _objc_msgSend(pvVar1,sel_layout);
    pvVar1 = _objc_msgSend(self,sel_navigationPaneSwitcher);
    _objc_msgSend(pvVar1,sel_layout);
    pvVar1 = (self->super).super._view;
    pvVar2 = _objc_msgSend(self,sel_topViewController);
    pvVar2 = _objc_msgSend(pvVar2,sel_presentationSize);
    _objc_msgSend(pvVar1,sel_setFrameSize_,pvVar2,extraout_EDX);
    pvVar1 = _objc_msgSend(self,sel_topViewController);
    pvVar1 = _objc_msgSend(pvVar1,sel_view);
    pvVar2 = _objc_msgSend(self,sel_topViewController);
    pvVar2 = _objc_msgSend(pvVar2,sel_presentationSize);
    _objc_msgSend(pvVar1,sel_setFrameSize_,pvVar2,extraout_EDX_00);
    pvVar1 = _objc_msgSend(self,sel_topViewController);
    pvVar1 = _objc_msgSend(pvVar1,sel_view);
    _objc_msgSend(pvVar1,sel_setFrameOrigin_,*(undefined4 *)PTR_00336074,
                  *(undefined4 *)(PTR_00336074 + 4));
    pvVar1 = self->_containerView;
    pvVar2 = _objc_msgSend(self,sel_topViewController);
    pvVar2 = _objc_msgSend(pvVar2,sel_view);
    _objc_msgSend(pvVar1,sel_addSubview_,pvVar2);
    pvVar1 = _objc_msgSend(self,sel_topViewController);
    pvVar1 = _objc_msgSend(pvVar1,sel_view);
    _objc_msgSend(pvVar1,sel_setAutoresizingMask_,0x12);
    local_14 = self;
    local_10 = PTR_s_HSObjectAssistantPane_00354da0;
    _objc_msgSendSuper(&local_14,sel_layout);
  }
  return;
}

*/
- (void)layout
{
    if (_layoutIsValid) {
        return;
    }
    [(NSView *)[[self topViewController] view] setAutoresizingMask:NSViewNotSizable];
    [(HSViewController *)[self topViewController] layout];
    [(HSViewController *)[self navigationPaneSwitcher] layout];
    [_view setFrameSize:[[self topViewController] presentationSize]];
    [[[self topViewController] view] setFrameSize:[[self topViewController] presentationSize]];
    [[[self topViewController] view] setFrameOrigin:NSZeroPoint];
    [_containerView addSubview:[[self topViewController] view]];
    [(NSView *)[[self topViewController] view] setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [super layout];
}

- (void)invalidateLayout
{
    [[self topViewController] invalidateLayout];
    [[self navigationPaneSwitcher] invalidateLayout];
    [super invalidateLayout];
}

- (void)removeAllViewControllersWithIdentifier:(id)aIdentifier
{
    id self_00;
    NSEnumerator *self_01;
    id pvVar2;
    id pvVar1_2;

    self_00 = [[self navigationStack] copy];
    self_01 = [self_00 objectEnumerator];
    pvVar1_2 = [self_01 nextObject];
    while (pvVar1_2 != nil) {
        pvVar2 = [pvVar1_2 objectForKey:@"identifier"];
        if ([pvVar2 isEqualToString:aIdentifier]) {
            [[self navigationStack] removeObject:pvVar1_2];
        }
        pvVar1_2 = [self_01 nextObject];
    }
    [self_00 release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0021c390 @ 0021c390, 311 bytes * /

id FUN_0021c390(HSObjectAssistantNavigationController *self,SEL _cmd,
               id popAllTopViewControllersWithIdentifier,BOOL animate)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar1 = _objc_msgSend(self,sel_paneIdentifierForTopViewController);
  pvVar3 = popAllTopViewControllersWithIdentifier;
  pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_,popAllTopViewControllersWithIdentifier);
  if ((char)pvVar1 == '\0') {
    pvVar3 = (id)0x0;
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_navigationStack,pvVar3);
    pvVar1 = _objc_msgSend(pvVar1,sel_count);
    for (pvVar1 = (id)((int)pvVar1 + -2); -1 < (int)pvVar1; pvVar1 = (id)((int)pvVar1 + -1)) {
      pvVar3 = _objc_msgSend(self,sel_navigationStack,pvVar3);
      pvVar3 = _objc_msgSend(pvVar3,sel_objectAtIndex_,pvVar1);
      pvVar2 = _objc_msgSend(pvVar3,sel_objectForKey_,&cfstr_identifier);
      pvVar3 = popAllTopViewControllersWithIdentifier;
      pvVar2 = _objc_msgSend(pvVar2,sel_isEqualToString_,popAllTopViewControllersWithIdentifier);
      if ((char)pvVar2 == '\0') break;
      pvVar2 = _objc_msgSend(self,sel_navigationStack,pvVar3);
      pvVar3 = pvVar1;
      _objc_msgSend(pvVar2,sel_removeObjectAtIndex_,pvVar1);
    }
    pvVar3 = _objc_msgSend(self,sel_popViewControllerAnimated_,(uint)(byte)animate);
  }
  return pvVar3;
}

*/
- (id)popAllTopViewControllersWithIdentifier:(id)aIdentifier animate:(BOOL)aAnimate
{
    if (![[self paneIdentifierForTopViewController] isEqualToString:aIdentifier]) {
        return nil;
    }
    for (NSInteger index = (NSInteger)[[self navigationStack] count] - 2; index >= 0; index--) {
        if (![[[[self navigationStack] objectAtIndex:index] objectForKey:@"identifier"] isEqualToString:aIdentifier]) {
            break;
        }
        [[self navigationStack] removeObjectAtIndex:index];
    }
    return [self popViewControllerAnimated:aAnimate];
}

- (id)popViewControllerAnimated:(BOOL)aAnimated
{
    return [self popViewControllerAnimated:(unsigned int)aAnimated slide:YES];
}

- (id)initialKeyView
{
    return [[self topViewController] initialKeyView];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0021c537 @ 0021c537, 3098 bytes * /

id FUN_0021c537(HSObjectAssistantNavigationController *self,SEL _cmd,BOOL popViewControllerAnimated,
               BOOL slide)

{
  int iVar1;
  int iVar2;
  int iVar3;
  undefined *puVar4;
  undefined *puVar5;
  undefined *puVar6;
  undefined *puVar7;
  undefined *puVar8;
  char cVar9;
  id pvVar10;
  id pvVar11;
  id pvVar12;
  id pvVar13;
  id pvVar14;
  id pvVar15;
  int *piVar16;
  int *piVar17;
  longdouble lVar18;
  undefined1 local_b4 [8];
  uint local_ac;
  undefined8 local_a4;
  undefined8 local_9c;
  undefined8 local_94;
  undefined8 local_8c;
  undefined1 local_84 [8];
  int local_7c;
  undefined8 local_74;
  undefined8 local_6c;
  undefined8 local_64;
  undefined8 local_5c;
  undefined8 local_54;
  undefined8 local_4c;
  undefined8 local_44;
  undefined8 local_3c;
  undefined8 local_34;
  undefined8 local_2c;
  undefined1 local_24 [20];
  
  piVar16 = (int *)&stack0xfffffef4;
  pvVar10 = _objc_msgSend(self,sel_topViewController);
  pvVar10 = _objc_msgSend(pvVar10,sel_retain);
  pvVar10 = _objc_msgSend(pvVar10,sel_autorelease);
  pvVar11 = _objc_msgSend(self,sel_isVisible);
  cVar9 = (char)pvVar11;
  if (popViewControllerAnimated == '\0') {
    if (cVar9 != '\0') {
      pvVar11 = _objc_msgSend(self,sel_topViewController);
      _objc_msgSend(pvVar11,sel_viewWillDisappear_);
    }
    pvVar11 = _objc_msgSend(self,sel_topViewController);
    pvVar11 = _objc_msgSend(pvVar11,sel_view);
    _objc_msgSend(pvVar11,sel_removeFromSuperview);
    if (cVar9 != '\0') {
      pvVar11 = _objc_msgSend(self,sel_topViewController);
      _objc_msgSend(pvVar11,sel_viewDidDisappear_);
    }
    pvVar11 = _objc_msgSend(self,sel_navigationStack);
    pvVar11 = _objc_msgSend(pvVar11,sel_lastObject);
    pvVar11 = _objc_msgSend(pvVar11,sel_objectForKey_);
    _objc_msgSend(pvVar11,sel_setParentViewController_);
    pvVar11 = _objc_msgSend(self,sel_navigationStack);
    _objc_msgSend(pvVar11,sel_removeLastObject);
    pvVar11 = _objc_msgSend(self,sel_topViewController);
    pvVar12 = _objc_msgSend(self,sel_topViewController);
    _objc_msgSend(pvVar12,sel_navigationPaneSwitcher);
    _objc_msgSend(self,sel_setNavigationPaneSwitcher_animate_);
    if (cVar9 != '\0') {
      _objc_msgSend(pvVar11,sel_viewWillAppear_);
    }
    pvVar12 = _objc_msgSend(pvVar11,sel_view);
    _objc_msgSend_stret(local_24,self->_containerView,sel_bounds);
    _objc_msgSend(pvVar12,sel_setFrame_);
    pvVar12 = self->_containerView;
    _objc_msgSend(pvVar11,sel_view);
    _objc_msgSend(pvVar12,sel_addSubview_);
    pvVar12 = _objc_msgSend(self,sel_topViewController);
    _objc_msgSend(pvVar12,sel_setParentViewController_);
    if (cVar9 != '\0') {
      _objc_msgSend(pvVar11,sel_viewDidAppear_);
    }
  }
  else {
    if (cVar9 != '\0') {
      pvVar11 = _objc_msgSend(self,sel_topViewController);
      _objc_msgSend(pvVar11,sel_viewWillDisappear_);
      pvVar11 = _objc_msgSend(self,sel_topViewController);
      _objc_msgSend(pvVar11,sel_viewDidDisappear_);
    }
    pvVar11 = _objc_msgSend(self,sel_navigationStack);
    pvVar11 = _objc_msgSend(pvVar11,sel_lastObject);
    pvVar11 = _objc_msgSend(pvVar11,sel_objectForKey_);
    _objc_msgSend(pvVar11,sel_setParentViewController_);
    pvVar11 = _objc_msgSend(self,sel_navigationStack);
    _objc_msgSend(pvVar11,sel_removeLastObject);
    pvVar11 = _objc_msgSend(self,sel_topViewController);
    pvVar12 = _objc_msgSend(self,sel_topViewController);
    _objc_msgSend(pvVar12,sel_navigationPaneSwitcher);
    _objc_msgSend(self,sel_setNavigationPaneSwitcher_animate_);
    pvVar12 = _objc_msgSend(pvVar11,sel_view);
    if (slide == '\0') {
      local_ac = 0;
    }
    else {
      _objc_msgSend_stret(local_b4,self->_containerView,sel_bounds);
      piVar16 = (int *)&stack0xfffffef0;
      local_ac = local_ac ^ 0x80000000;
    }
    pvVar13 = self->_containerView;
    piVar16[2] = (int)sel_bounds;
    piVar16[1] = (int)pvVar13;
    *piVar16 = (int)&local_a4;
    piVar16[-1] = 0x21c785;
    _objc_msgSend_stret((void *)*piVar16,(id)piVar16[1],(SEL)piVar16[2]);
    *(undefined8 *)(piVar16 + 2) = local_9c;
    *(undefined8 *)piVar16 = local_a4;
    piVar16[4] = local_ac;
    piVar16[-1] = (int)&local_94;
    piVar16[5] = 0;
    piVar16[-2] = 0x21c7c8;
    _NSOffsetRect();
    piVar17 = piVar16 + -2;
    *(undefined8 *)(piVar16 + 2) = local_8c;
    *(undefined8 *)piVar16 = local_94;
    piVar16[-1] = (int)sel_setFrame_;
    piVar16[-2] = (int)pvVar12;
    piVar16[-3] = 0x21c7f9;
    _objc_msgSend((id)piVar16[-2],(SEL)piVar16[-1]);
    pvVar12 = self->_containerView;
    piVar16[-1] = (int)sel_view;
    piVar16[-2] = (int)pvVar11;
    piVar16[-3] = 0x21c817;
    pvVar13 = _objc_msgSend((id)piVar16[-2],(SEL)piVar16[-1]);
    *piVar16 = (int)pvVar13;
    piVar16[-1] = (int)sel_addSubview_;
    piVar16[-2] = (int)pvVar12;
    piVar16[-3] = 0x21c82d;
    _objc_msgSend((id)piVar16[-2],(SEL)piVar16[-1]);
    piVar16[-1] = (int)sel_view;
    piVar16[-2] = (int)pvVar11;
    piVar16[-3] = 0x21c83f;
    pvVar12 = _objc_msgSend((id)piVar16[-2],(SEL)piVar16[-1]);
    piVar16[-1] = (int)sel_setAutoresizingMask_;
    piVar16[-2] = (int)pvVar12;
    *piVar16 = 0x12;
    piVar16[-3] = 0x21c859;
    _objc_msgSend((id)piVar16[-2],(SEL)piVar16[-1]);
    *piVar16 = (int)self;
    piVar16[-1] = (int)sel_setObjectAssistantNavigationController_;
    piVar16[-2] = (int)pvVar11;
    piVar16[-3] = 0x21c872;
    _objc_msgSend((id)piVar16[-2],(SEL)piVar16[-1]);
    piVar16[-1] = (int)sel_topViewController;
    piVar16[-2] = (int)self;
    piVar16[-3] = 0x21c887;
    pvVar12 = _objc_msgSend((id)piVar16[-2],(SEL)piVar16[-1]);
    *piVar16 = (int)self;
    piVar16[-1] = (int)sel_setParentViewController_;
    piVar16[-2] = (int)pvVar12;
    piVar16[-3] = 0x21c8a0;
    _objc_msgSend((id)piVar16[-2],(SEL)piVar16[-1]);
    if (cVar9 != '\0') {
      *piVar16 = (int)popViewControllerAnimated;
      piVar16[-1] = (int)sel_viewWillAppear_;
      piVar16[-2] = (int)pvVar11;
      piVar16[-3] = 0x21c8c7;
      _objc_msgSend((id)piVar16[-2],(SEL)piVar16[-1]);
    }
    puVar8 = cls_NSValue;
    puVar7 = cls_NSDictionary;
    puVar6 = PTR_00336554;
    puVar5 = PTR_00336548;
    puVar4 = PTR_00336544;
    if (slide == '\0') {
      iVar1 = *(int *)PTR_00336554;
      iVar2 = *(int *)PTR_0033654c;
      iVar3 = *(int *)PTR_00336544;
      piVar16[-1] = (int)sel_view;
      piVar16[-2] = (int)pvVar10;
      piVar16[-3] = 0x21cc96;
      pvVar12 = _objc_msgSend((id)piVar16[-2],(SEL)piVar16[-1]);
      piVar16[3] = iVar3;
      piVar16[2] = iVar2;
      piVar16[1] = iVar1;
      *piVar16 = (int)pvVar12;
      piVar16[-1] = (int)sel_dictionaryWithObjectsAndKeys_;
      piVar16[-2] = (int)puVar7;
      piVar16[4] = 0;
      piVar16[-3] = 0x21ccd2;
      pvVar13 = _objc_msgSend((id)piVar16[-2],(SEL)piVar16[-1]);
      puVar5 = cls_NSDictionary;
      iVar1 = *(int *)puVar6;
      iVar2 = *(int *)PTR_003365ac;
      iVar3 = *(int *)puVar4;
      piVar16[-1] = (int)sel_view;
      piVar16[-2] = (int)pvVar11;
      piVar16[-3] = 0x21cd14;
      pvVar12 = _objc_msgSend((id)piVar16[-2],(SEL)piVar16[-1]);
      piVar16[3] = iVar3;
      piVar16[2] = iVar2;
      piVar16[1] = iVar1;
      *piVar16 = (int)pvVar12;
      piVar16[-1] = (int)sel_dictionaryWithObjectsAndKeys_;
      piVar16[-2] = (int)puVar5;
      piVar16[4] = 0;
      piVar16[-3] = 0x21cd4a;
      pvVar14 = _objc_msgSend((id)piVar16[-2],(SEL)piVar16[-1]);
      piVar16[-1] = (int)sel_alloc;
      piVar16[-2] = (int)cls_NSViewAnimation;
      piVar16[-3] = 0x21cd64;
      pvVar12 = _objc_msgSend((id)piVar16[-2],(SEL)piVar16[-1]);
      piVar16[1] = (int)pvVar14;
      *piVar16 = (int)pvVar13;
      piVar16[-1] = (int)sel_arrayWithObjects_;
      piVar16[-2] = (int)cls_NSArray;
    }
    else {
      iVar1 = *(int *)PTR_00336548;
      pvVar12 = self->_containerView;
      *piVar16 = (int)sel_frame;
      piVar16[-1] = (int)pvVar12;
      piVar16[-2] = (int)local_84;
      piVar16[-3] = 0x21c916;
      _objc_msgSend_stret((void *)piVar16[-2],(id)piVar16[-1],(SEL)*piVar16);
      piVar16[-2] = (int)sel_view;
      piVar16[-3] = (int)pvVar10;
      piVar16[-4] = 0x21c93e;
      pvVar12 = _objc_msgSend((id)piVar16[-3],(SEL)piVar16[-2]);
      piVar16[-1] = (int)sel_frame;
      piVar16[-2] = (int)pvVar12;
      piVar16[-3] = (int)&local_74;
      piVar16[-4] = 0x21c957;
      _objc_msgSend_stret((void *)piVar16[-3],(id)piVar16[-2],(SEL)piVar16[-1]);
      *(undefined8 *)(piVar16 + -1) = local_6c;
      *(undefined8 *)(piVar16 + -3) = local_74;
      piVar16[1] = local_7c;
      piVar16[-4] = (int)&local_64;
      piVar16[2] = 0;
      piVar16[-5] = 0x21c991;
      _NSOffsetRect();
      *(undefined8 *)(piVar16 + -1) = local_5c;
      *(undefined8 *)(piVar16 + -3) = local_64;
      piVar16[-4] = (int)sel_valueWithRect_;
      piVar16[-5] = (int)puVar8;
      piVar16[-6] = 0x21c9bc;
      pvVar12 = _objc_msgSend((id)piVar16[-5],(SEL)piVar16[-4]);
      puVar6 = cls_NSValue;
      puVar4 = PTR_00336550;
      iVar2 = *(int *)PTR_00336550;
      piVar16[-4] = (int)sel_view;
      piVar16[-5] = (int)pvVar10;
      piVar16[-6] = 0x21c9f4;
      pvVar13 = _objc_msgSend((id)piVar16[-5],(SEL)piVar16[-4]);
      piVar16[-3] = (int)sel_frame;
      piVar16[-4] = (int)pvVar13;
      piVar16[-5] = (int)&local_54;
      piVar16[-6] = 0x21ca0d;
      _objc_msgSend_stret((void *)piVar16[-5],(id)piVar16[-4],(SEL)piVar16[-3]);
      *(undefined8 *)(piVar16 + -2) = local_4c;
      *(undefined8 *)(piVar16 + -4) = local_54;
      piVar16[-5] = (int)sel_valueWithRect_;
      piVar16[-6] = (int)puVar6;
      piVar16[-7] = 0x21ca38;
      pvVar13 = _objc_msgSend((id)piVar16[-6],(SEL)piVar16[-5]);
      puVar6 = PTR_00336554;
      iVar3 = *(int *)PTR_00336554;
      piVar16[-5] = (int)sel_view;
      piVar16[-6] = (int)pvVar10;
      piVar16[-7] = 0x21ca64;
      pvVar14 = _objc_msgSend((id)piVar16[-6],(SEL)piVar16[-5]);
      piVar16[1] = iVar1;
      *piVar16 = (int)pvVar12;
      piVar16[-1] = iVar2;
      piVar16[-2] = (int)pvVar13;
      piVar16[-3] = iVar3;
      piVar16[-4] = (int)pvVar14;
      piVar16[-5] = (int)sel_dictionaryWithObjectsAndKeys_;
      piVar16[-6] = (int)puVar7;
      piVar16[2] = 0;
      piVar16[-7] = 0x21cab4;
      pvVar13 = _objc_msgSend((id)piVar16[-6],(SEL)piVar16[-5]);
      puVar8 = cls_NSValue;
      puVar7 = cls_NSDictionary;
      iVar1 = *(int *)puVar5;
      pvVar12 = self->_containerView;
      piVar16[-4] = (int)sel_bounds;
      piVar16[-5] = (int)pvVar12;
      piVar16[-6] = (int)&local_44;
      piVar16[-7] = 0x21caf9;
      _objc_msgSend_stret((void *)piVar16[-6],(id)piVar16[-5],(SEL)piVar16[-4]);
      *(undefined8 *)(piVar16 + -3) = local_3c;
      *(undefined8 *)(piVar16 + -5) = local_44;
      piVar16[-6] = (int)sel_valueWithRect_;
      piVar16[-7] = (int)puVar8;
      piVar16[-8] = 0x21cb24;
      pvVar12 = _objc_msgSend((id)piVar16[-7],(SEL)piVar16[-6]);
      puVar5 = cls_NSValue;
      iVar2 = *(int *)puVar4;
      piVar16[-6] = (int)sel_view;
      piVar16[-7] = (int)pvVar11;
      piVar16[-8] = 0x21cb56;
      pvVar14 = _objc_msgSend((id)piVar16[-7],(SEL)piVar16[-6]);
      piVar16[-5] = (int)sel_frame;
      piVar16[-6] = (int)pvVar14;
      piVar16[-7] = (int)&local_34;
      piVar16[-8] = 0x21cb6f;
      _objc_msgSend_stret((void *)piVar16[-7],(id)piVar16[-6],(SEL)piVar16[-5]);
      piVar17 = piVar16 + -8;
      *(undefined8 *)(piVar16 + -4) = local_2c;
      *(undefined8 *)(piVar16 + -6) = local_34;
      piVar16[-7] = (int)sel_valueWithRect_;
      piVar16[-8] = (int)puVar5;
      piVar16[-9] = 0x21cb9a;
      pvVar14 = _objc_msgSend((id)piVar16[-8],(SEL)piVar16[-7]);
      iVar3 = *(int *)puVar6;
      piVar16[-7] = (int)sel_view;
      piVar16[-8] = (int)pvVar11;
      piVar16[-9] = 0x21cbc2;
      pvVar15 = _objc_msgSend((id)piVar16[-8],(SEL)piVar16[-7]);
      piVar16[-1] = iVar1;
      piVar16[-2] = (int)pvVar12;
      piVar16[-3] = iVar2;
      piVar16[-4] = (int)pvVar14;
      piVar16[-5] = iVar3;
      piVar16[-6] = (int)pvVar15;
      piVar16[-7] = (int)sel_dictionaryWithObjectsAndKeys_;
      piVar16[-8] = (int)puVar7;
      *piVar16 = 0;
      piVar16[-9] = 0x21cc12;
      pvVar14 = _objc_msgSend((id)piVar16[-8],(SEL)piVar16[-7]);
      piVar16[-7] = (int)sel_alloc;
      piVar16[-8] = (int)cls_NSViewAnimation;
      piVar16[-9] = 0x21cc2c;
      pvVar12 = _objc_msgSend((id)piVar16[-8],(SEL)piVar16[-7]);
      piVar16[-5] = (int)pvVar14;
      piVar16[-6] = (int)pvVar13;
      piVar16[-7] = (int)sel_arrayWithObjects_;
      piVar16[-8] = (int)cls_NSArray;
    }
    piVar17[4] = 0;
    piVar17[-1] = 0x21cd94;
    pvVar13 = _objc_msgSend((id)*piVar17,(SEL)piVar17[1]);
    piVar17[2] = (int)pvVar13;
    piVar17[1] = (int)sel_initWithViewAnimations_;
    *piVar17 = (int)pvVar12;
    piVar17[-1] = 0x21cdaa;
    pvVar12 = _objc_msgSend((id)*piVar17,(SEL)piVar17[1]);
    piVar17[-1] = 0x21cdb1;
    lVar18 = (longdouble)_HSObjectAssistantAnimationDuration();
    *(double *)(piVar17 + 2) = (double)lVar18;
    piVar17[1] = (int)sel_setDuration_;
    *piVar17 = (int)pvVar12;
    piVar17[-1] = 0x21cdc7;
    _objc_msgSend((id)*piVar17,(SEL)piVar17[1]);
    piVar17[1] = (int)sel_setAnimationBlockingMode_;
    *piVar17 = (int)pvVar12;
    piVar17[2] = 0;
    piVar17[-1] = 0x21cde1;
    _objc_msgSend((id)*piVar17,(SEL)piVar17[1]);
    piVar17[1] = (int)sel_setAnimationCurve_;
    *piVar17 = (int)pvVar12;
    piVar17[2] = 0;
    piVar17[-1] = 0x21cdfb;
    _objc_msgSend((id)*piVar17,(SEL)piVar17[1]);
    piVar17[1] = (int)sel_startAnimation;
    *piVar17 = (int)pvVar12;
    piVar17[-1] = 0x21ce0d;
    _objc_msgSend((id)*piVar17,(SEL)piVar17[1]);
    piVar17[1] = (int)sel_release;
    *piVar17 = (int)pvVar12;
    piVar17[-1] = 0x21ce1f;
    _objc_msgSend((id)*piVar17,(SEL)piVar17[1]);
    piVar17[1] = (int)sel_setParentViewController_;
    *piVar17 = (int)pvVar10;
    piVar17[2] = 0;
    piVar17[-1] = 0x21ce3f;
    _objc_msgSend((id)*piVar17,(SEL)piVar17[1]);
    piVar17[1] = (int)sel_setObjectAssistantNavigationController_;
    *piVar17 = (int)pvVar10;
    piVar17[2] = 0;
    piVar17[-1] = 0x21ce59;
    _objc_msgSend((id)*piVar17,(SEL)piVar17[1]);
    piVar17[1] = (int)sel_view;
    *piVar17 = (int)pvVar10;
    piVar17[-1] = 0x21ce6b;
    pvVar12 = _objc_msgSend((id)*piVar17,(SEL)piVar17[1]);
    piVar17[1] = (int)sel_removeFromSuperview;
    *piVar17 = (int)pvVar12;
    piVar17[-1] = 0x21ce7d;
    _objc_msgSend((id)*piVar17,(SEL)piVar17[1]);
    if (cVar9 != '\0') {
      piVar17[2] = (int)popViewControllerAnimated;
      piVar17[1] = (int)sel_viewDidAppear_;
      *piVar17 = (int)pvVar11;
      piVar17[-1] = 0x21ceac;
      _objc_msgSend((id)*piVar17,(SEL)piVar17[1]);
    }
  }
  return pvVar10;
}

*/
- (id)popViewControllerAnimated:(BOOL)aAnimated slide:(BOOL)aSlide
{
    id oldController = [[[self topViewController] retain] autorelease];
    BOOL visible = [self isVisible];
    if (!aAnimated) {
        if (visible) {
            [[self topViewController] viewWillDisappear:aAnimated];
        }
        [[[self topViewController] view] removeFromSuperview];
        if (visible) {
            [[self topViewController] viewDidDisappear:aAnimated];
        }
        [[[[self navigationStack] lastObject] objectForKey:@"pane"] setParentViewController:nil];
        [[self navigationStack] removeLastObject];
        id newController = [self topViewController];
        [self setNavigationPaneSwitcher:[[self topViewController] navigationPaneSwitcher] animate:aAnimated];
        if (visible) {
            [newController viewWillAppear:aAnimated];
        }
        [[newController view] setFrame:[_containerView bounds]];
        [_containerView addSubview:[newController view]];
        [[self topViewController] setParentViewController:self];
        if (visible) {
            [newController viewDidAppear:aAnimated];
        }
        return oldController;
    }
    if (visible) {
        [[self topViewController] viewWillDisappear:aAnimated];
        [[self topViewController] viewDidDisappear:aAnimated];
    }
    [[[[self navigationStack] lastObject] objectForKey:@"pane"] setParentViewController:nil];
    [[self navigationStack] removeLastObject];
    id newController = [self topViewController];
    [self setNavigationPaneSwitcher:[[self topViewController] navigationPaneSwitcher] animate:aAnimated];
    NSView *newView = [newController view];
    CGFloat offset = aSlide ? -[_containerView bounds].size.width : 0.0;
    [newView setFrame:NSOffsetRect([_containerView bounds], offset, 0.0)];
    [_containerView addSubview:[newController view]];
    [(NSView *)[newController view] setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [newController setObjectAssistantNavigationController:self];
    [[self topViewController] setParentViewController:self];
    if (visible) {
        [newController viewWillAppear:aAnimated];
    }
    NSDictionary *oldAnimation;
    NSDictionary *newAnimation;
    if (!aSlide) {
        oldAnimation = [NSDictionary dictionaryWithObjectsAndKeys:[oldController view], NSViewAnimationTargetKey, NSViewAnimationFadeOutEffect, NSViewAnimationEffectKey, nil];
        newAnimation = [NSDictionary dictionaryWithObjectsAndKeys:[newController view], NSViewAnimationTargetKey, NSViewAnimationFadeInEffect, NSViewAnimationEffectKey, nil];
    }
    else {
        CGFloat width = [_containerView frame].size.width;
        oldAnimation = [NSDictionary dictionaryWithObjectsAndKeys:[oldController view], NSViewAnimationTargetKey, [NSValue valueWithRect:[[oldController view] frame]], NSViewAnimationStartFrameKey, [NSValue valueWithRect:NSOffsetRect([[oldController view] frame], width, 0.0)], NSViewAnimationEndFrameKey, nil];
        newAnimation = [NSDictionary dictionaryWithObjectsAndKeys:[newController view], NSViewAnimationTargetKey, [NSValue valueWithRect:[[newController view] frame]], NSViewAnimationStartFrameKey, [NSValue valueWithRect:[_containerView bounds]], NSViewAnimationEndFrameKey, nil];
    }
    NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObjects:oldAnimation, newAnimation, nil]];
    [animation setDuration:HSObjectAssistantAnimationDuration()];
    [animation setAnimationBlockingMode:NSAnimationBlocking];
    [animation setAnimationCurve:NSAnimationEaseInOut];
    [animation startAnimation];
    [animation release];
    [oldController setParentViewController:nil];
    [oldController setObjectAssistantNavigationController:nil];
    [[oldController view] removeFromSuperview];
    if (visible) {
        [newController viewDidAppear:aAnimated];
    }
    return oldController;
}

- (void)removeDisposablePanes
{
    NSEnumerator *self_00;
    id pvVar2;
    id pvVar3;
    id self_01;
    id pvVar1_2;

    pvVar1_2 = [[self navigationStack] copy];
    self_00 = [pvVar1_2 objectEnumerator];
    pvVar2 = [self topViewController];
    while (self_01 = [self_00 nextObject], self_01 != nil) {
        pvVar3 = [self_01 objectForKey:@"pane"];
        if (([pvVar3 shouldDismissWhenDisappeared]) && (pvVar3 != pvVar2)) {
            [pvVar3 setParentViewController:nil];
            [pvVar3 setObjectAssistantNavigationController:nil];
            [[self navigationStack] removeObject:self_01];
        }
    }
    [pvVar1_2 release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0021d29c @ 0021d29c, 3659 bytes * /

void FUN_0021d29c(HSObjectAssistantNavigationController *self,SEL _cmd,id pushViewController,
                 id withIdentifier,BOOL animate,BOOL replacePrevious)

{
  undefined *puVar1;
  undefined *puVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  SEL op;
  undefined4 *puVar6;
  undefined1 local_b4 [16];
  undefined1 local_a4 [32];
  undefined1 local_84 [16];
  undefined1 local_74 [32];
  undefined1 local_54 [16];
  undefined1 local_44 [16];
  undefined1 local_34 [16];
  undefined1 local_24 [20];
  
  pvVar3 = _objc_msgSend(pushViewController,sel_object);
  pvVar4 = _objc_msgSend(pushViewController,sel_isCoachingPane);
  if (((char)pvVar4 != '\0') &&
     ((pvVar4 = _objc_msgSend(pvVar3,sel_queryHyperInterface_), pvVar4 != (id)0x0 ||
      (pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_), pvVar3 != (id)0x0)))) {
    pvVar3 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    _objc_msgSend(pvVar3,sel_addObserver_selector_name_object_);
  }
  pvVar3 = _objc_msgSend((self->super).super._presentationView,sel_superview);
  pvVar4 = _objc_msgSend(cls_NSMutableDictionary,sel_dictionaryWithObject_forKey_);
  if (withIdentifier != (id)0x0) {
    _objc_msgSend(pvVar4,sel_setObject_forKey_);
  }
  if (animate == '\0') {
    pvVar4 = _objc_msgSend(self,sel_topViewController);
    if (pvVar3 == (id)0x0) {
      pvVar4 = _objc_msgSend(pvVar4,sel_view);
      op = sel_removeFromSuperview;
    }
    else {
      _objc_msgSend(pvVar4,sel_viewWillDisappear_);
      pvVar4 = _objc_msgSend(self,sel_topViewController);
      pvVar4 = _objc_msgSend(pvVar4,sel_view);
      _objc_msgSend(pvVar4,sel_removeFromSuperview);
      pvVar4 = _objc_msgSend(self,sel_topViewController);
      op = sel_viewDidDisappear_;
    }
    _objc_msgSend(pvVar4,op);
    pvVar4 = _objc_msgSend(self,sel_topViewController);
    _objc_msgSend(pvVar4,sel_setParentViewController_);
    pvVar4 = _objc_msgSend(self,sel_topViewController);
    _objc_msgSend(pvVar4,sel_setObjectAssistantNavigationController_);
    if (replacePrevious != '\0') {
      pvVar4 = _objc_msgSend(self,sel_navigationStack);
      pvVar4 = _objc_msgSend(pvVar4,sel_lastObject);
      pvVar4 = _objc_msgSend(pvVar4,sel_objectForKey_);
      _objc_msgSend(pvVar4,sel_setParentViewController_);
      pvVar4 = _objc_msgSend(self,sel_navigationStack);
      _objc_msgSend(pvVar4,sel_removeLastObject);
    }
    pvVar4 = _objc_msgSend(self,sel_navigationStack);
    _objc_msgSend(pvVar4,sel_addObject_);
    _objc_msgSend(pushViewController,sel_layout);
    pvVar4 = _objc_msgSend(self,sel_topViewController);
    _objc_msgSend(pvVar4,sel_setObjectAssistantNavigationController_);
    pvVar4 = _objc_msgSend(self,sel_topViewController);
    _objc_msgSend(pvVar4,sel_setParentViewController_);
    pvVar4 = _objc_msgSend(self,sel_topViewController);
    _objc_msgSend(pvVar4,sel_navigationPaneSwitcher);
    _objc_msgSend(self,sel_setNavigationPaneSwitcher_animate_);
    if (pvVar3 != (id)0x0) {
      pvVar4 = _objc_msgSend(self,sel_topViewController);
      _objc_msgSend(pvVar4,sel_viewWillAppear_);
    }
    pvVar4 = _objc_msgSend(self,sel_topViewController);
    pvVar4 = _objc_msgSend(pvVar4,sel_view);
    _objc_msgSend_stret(local_24,self->_containerView,sel_bounds);
    puVar6 = (undefined4 *)&stack0xfffffef0;
    _objc_msgSend(pvVar4,sel_setFrame_);
    pvVar4 = self->_containerView;
    pvVar5 = _objc_msgSend(self,sel_topViewController);
    _objc_msgSend(pvVar5,sel_view);
    _objc_msgSend(pvVar4,sel_addSubview_);
    pvVar4 = _objc_msgSend(self,sel_topViewController);
    pvVar4 = _objc_msgSend(pvVar4,sel_view);
    _objc_msgSend(pvVar4,sel_setAutoresizingMask_);
    if (pvVar3 == (id)0x0) {
      return;
    }
    _objc_msgSend(self,sel_topViewController);
  }
  else {
    if (pvVar3 != (id)0x0) {
      pvVar4 = _objc_msgSend(self,sel_topViewController);
      _objc_msgSend(pvVar4,sel_viewWillDisappear_);
      pvVar4 = _objc_msgSend(self,sel_topViewController);
      _objc_msgSend(pvVar4,sel_viewDidDisappear_);
    }
    pvVar4 = _objc_msgSend(pushViewController,sel_view);
    _objc_msgSend_stret(local_b4,self->_containerView,sel_bounds);
    _objc_msgSend_stret(local_a4,self->_containerView,sel_bounds);
    _NSOffsetRect();
    _objc_msgSend(pvVar4,sel_setFrame_);
    pvVar4 = self->_containerView;
    _objc_msgSend(pushViewController,sel_view);
    _objc_msgSend(pvVar4,sel_addSubview_);
    pvVar4 = _objc_msgSend(pushViewController,sel_view);
    _objc_msgSend(pvVar4,sel_setAutoresizingMask_);
    pvVar4 = _objc_msgSend(self,sel_topViewController);
    pvVar4 = _objc_msgSend(pvVar4,sel_retain);
    if (replacePrevious != '\0') {
      pvVar5 = _objc_msgSend(self,sel_navigationStack);
      pvVar5 = _objc_msgSend(pvVar5,sel_lastObject);
      pvVar5 = _objc_msgSend(pvVar5,sel_objectForKey_);
      _objc_msgSend(pvVar5,sel_setParentViewController_);
      pvVar5 = _objc_msgSend(self,sel_navigationStack);
      _objc_msgSend(pvVar5,sel_removeLastObject);
    }
    pvVar5 = _objc_msgSend(self,sel_navigationStack);
    _objc_msgSend(pvVar5,sel_addObject_);
    _objc_msgSend(pushViewController,sel_layout);
    _objc_msgSend(pushViewController,sel_setObjectAssistantNavigationController_);
    pvVar5 = _objc_msgSend(self,sel_topViewController);
    _objc_msgSend(pvVar5,sel_setParentViewController_);
    pvVar5 = _objc_msgSend(self,sel_topViewController);
    _objc_msgSend(pvVar5,sel_navigationPaneSwitcher);
    _objc_msgSend(self,sel_setNavigationPaneSwitcher_animate_);
    if (pvVar3 != (id)0x0) {
      _objc_msgSend(pushViewController,sel_viewWillAppear_);
    }
    puVar1 = cls_NSDictionary;
    _objc_msgSend(pushViewController,sel_view);
    _objc_msgSend(puVar1,sel_dictionaryWithObjectsAndKeys_);
    pvVar5 = _objc_msgSend(cls_NSViewAnimation,sel_alloc);
    _objc_msgSend(cls_NSArray,sel_arrayWithObject_);
    pvVar5 = _objc_msgSend(pvVar5,sel_initWithViewAnimations_);
    _objc_msgSend(pvVar5,sel_setDuration_);
    _objc_msgSend(pvVar5,sel_setAnimationBlockingMode_);
    _objc_msgSend(pvVar5,sel_startAnimation);
    _objc_msgSend(pvVar5,sel_release);
    puVar2 = cls_NSValue;
    puVar1 = cls_NSDictionary;
    _objc_msgSend_stret(local_84,self->_containerView,sel_frame);
    pvVar5 = _objc_msgSend(pvVar4,sel_view);
    _objc_msgSend_stret(local_74,pvVar5,sel_frame);
    _NSOffsetRect();
    _objc_msgSend(puVar2,sel_valueWithRect_);
    puVar2 = cls_NSValue;
    pvVar5 = _objc_msgSend(pvVar4,sel_view);
    _objc_msgSend_stret(local_54,pvVar5,sel_frame);
    _objc_msgSend(puVar2,sel_valueWithRect_);
    _objc_msgSend(pvVar4,sel_view);
    _objc_msgSend(puVar1,sel_dictionaryWithObjectsAndKeys_);
    puVar2 = cls_NSValue;
    puVar1 = cls_NSDictionary;
    _objc_msgSend_stret(local_44,self->_containerView,sel_bounds);
    _objc_msgSend(puVar2,sel_valueWithRect_);
    puVar2 = cls_NSValue;
    pvVar5 = _objc_msgSend(pushViewController,sel_view);
    _objc_msgSend_stret(local_34,pvVar5,sel_frame);
    puVar6 = (undefined4 *)&stack0xfffffed0;
    _objc_msgSend(puVar2,sel_valueWithRect_);
    _objc_msgSend(pushViewController,sel_view);
    _objc_msgSend(puVar1,sel_dictionaryWithObjectsAndKeys_);
    pvVar5 = _objc_msgSend(cls_NSViewAnimation,sel_alloc);
    _objc_msgSend(cls_NSArray,sel_arrayWithObjects_);
    pvVar5 = _objc_msgSend(pvVar5,sel_initWithViewAnimations_);
    _HSObjectAssistantAnimationDuration();
    _objc_msgSend(pvVar5,sel_setDuration_);
    _objc_msgSend(pvVar5,sel_setAnimationBlockingMode_);
    _objc_msgSend(pvVar5,sel_setAnimationCurve_);
    _objc_msgSend(pvVar5,sel_startAnimation);
    _objc_msgSend(pvVar5,sel_release);
    _objc_msgSend(pvVar4,sel_setParentViewController_);
    pvVar5 = _objc_msgSend(pvVar4,sel_view);
    _objc_msgSend(pvVar5,sel_removeFromSuperview);
    _objc_msgSend(pvVar4,sel_release);
    if (pvVar3 == (id)0x0) {
      return;
    }
  }
  puVar6[-1] = 0x21dd13;
  _objc_msgSend((id)*puVar6,(SEL)puVar6[1]);
  return;
}

*/
- (void)pushViewController:(id)aController withIdentifier:(id)aIdentifier animate:(BOOL)aAnimate replacePrevious:(BOOL)aPrevious
{
    id object = [aController object];
    if ([aController isCoachingPane] && ([object queryHyperInterface:@protocol(HSCardObjectAttributes)] != nil || [object queryHyperInterface:@protocol(HSCardAttributes)] != nil)) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doubleClickDidDone) name:HSHandleDoubleClickNotification object:object];
    }
    BOOL visible = [_presentationView superview] != nil;
    NSMutableDictionary *entry = [NSMutableDictionary dictionaryWithObject:aController forKey:@"pane"];
    if (aIdentifier != nil) {
        [entry setObject:aIdentifier forKey:@"identifier"];
    }
    if (!aAnimate) {
        if (visible) {
            [[self topViewController] viewWillDisappear:aAnimate];
            [[[self topViewController] view] removeFromSuperview];
            [[self topViewController] viewDidDisappear:aAnimate];
        }
        else {
            [[[self topViewController] view] removeFromSuperview];
        }
        [[self topViewController] setParentViewController:nil];
        [[self topViewController] setObjectAssistantNavigationController:nil];
        if (aPrevious) {
            [[[[self navigationStack] lastObject] objectForKey:@"pane"] setParentViewController:nil];
            [[self navigationStack] removeLastObject];
        }
        [[self navigationStack] addObject:entry];
        [(HSViewController *)aController layout];
        [[self topViewController] setObjectAssistantNavigationController:self];
        [[self topViewController] setParentViewController:self];
        [self setNavigationPaneSwitcher:[[self topViewController] navigationPaneSwitcher] animate:aAnimate];
        if (visible) {
            [[self topViewController] viewWillAppear:aAnimate];
        }
        [[[self topViewController] view] setFrame:[_containerView bounds]];
        [_containerView addSubview:[[self topViewController] view]];
        [(NSView *)[[self topViewController] view] setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        if (visible) {
            [[self topViewController] viewDidAppear:aAnimate];
        }
        return;
    }
    if (visible) {
        [[self topViewController] viewWillDisappear:aAnimate];
        [[self topViewController] viewDidDisappear:aAnimate];
    }
    [[aController view] setFrame:NSOffsetRect([_containerView bounds], [_containerView bounds].size.width, 0.0)];
    [_containerView addSubview:[aController view]];
    [(NSView *)[aController view] setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    id oldController = [[self topViewController] retain];
    if (aPrevious) {
        [[[[self navigationStack] lastObject] objectForKey:@"pane"] setParentViewController:nil];
        [[self navigationStack] removeLastObject];
    }
    [[self navigationStack] addObject:entry];
    [(HSViewController *)aController layout];
    [aController setObjectAssistantNavigationController:self];
    [[self topViewController] setParentViewController:self];
    [self setNavigationPaneSwitcher:[[self topViewController] navigationPaneSwitcher] animate:aAnimate];
    if (visible) {
        [aController viewWillAppear:aAnimate];
    }
    NSDictionary *fadeIn = [NSDictionary dictionaryWithObjectsAndKeys:[aController view], NSViewAnimationTargetKey, NSViewAnimationFadeInEffect, NSViewAnimationEffectKey, nil];
    NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:fadeIn]];
    [animation setDuration:0.0];
    [animation setAnimationBlockingMode:NSAnimationBlocking];
    [animation startAnimation];
    [animation release];
    CGFloat width = [_containerView frame].size.width;
    NSDictionary *oldAnimation = [NSDictionary dictionaryWithObjectsAndKeys:[oldController view], NSViewAnimationTargetKey, [NSValue valueWithRect:[[oldController view] frame]], NSViewAnimationStartFrameKey, [NSValue valueWithRect:NSOffsetRect([[oldController view] frame], -width, 0.0)], NSViewAnimationEndFrameKey, nil];
    NSDictionary *newAnimation = [NSDictionary dictionaryWithObjectsAndKeys:[aController view], NSViewAnimationTargetKey, [NSValue valueWithRect:[[aController view] frame]], NSViewAnimationStartFrameKey, [NSValue valueWithRect:[_containerView bounds]], NSViewAnimationEndFrameKey, nil];
    animation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObjects:oldAnimation, newAnimation, nil]];
    [animation setDuration:HSObjectAssistantAnimationDuration()];
    [animation setAnimationBlockingMode:NSAnimationBlocking];
    [animation setAnimationCurve:NSAnimationEaseInOut];
    [animation startAnimation];
    [animation release];
    [oldController setParentViewController:nil];
    [[oldController view] removeFromSuperview];
    [oldController release];
    if (visible) {
        [aController viewDidAppear:aAnimate];
    }
}

- (void)pushViewController:(id)aController animate:(BOOL)aAnimate
{
    [self pushViewController:aController withIdentifier:nil animate:aAnimate replacePrevious:NO];
}

- (id)assistantPaneUndoManager
{
    return [[self topViewController] assistantPaneUndoManager];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0021e166 @ 0021e166, 503 bytes * /

void FUN_0021e166(HSObjectAssistantNavigationController *self,SEL _cmd,id setNavigationPaneSwitcher,
                 BOOL animate)

{
  id pvVar1;
  HSObjectAssistantNavigationPaneSwitcher *pHVar2;
  id pvVar3;
  id pvVar4;
  HSObjectAssistantNavigationController *pHVar5;
  int iVar6;
  SEL op;
  
  if (self->_navigationPaneSwitcher != setNavigationPaneSwitcher) {
    pvVar1 = _objc_msgSend((self->super).super._presentationView,sel_superview);
    if (pvVar1 == (id)0x0) {
      _objc_msgSend(self->_navigationPaneSwitcher,sel_setParentViewController_,0);
      pHVar2 = self->_navigationPaneSwitcher;
      iVar6 = 0;
      op = sel_setNavigationController_;
    }
    else {
      iVar6 = (int)animate;
      _objc_msgSend(self->_navigationPaneSwitcher,sel_viewWillDisappear_,iVar6);
      _objc_msgSend(self->_navigationPaneSwitcher,sel_setParentViewController_,0);
      _objc_msgSend(self->_navigationPaneSwitcher,sel_setNavigationController_,0);
      pHVar2 = self->_navigationPaneSwitcher;
      op = sel_viewDidDisappear_;
    }
    _objc_msgSend(pHVar2,op,iVar6);
    _objc_msgSend(self->_navigationPaneSwitcher,sel_release);
    pHVar2 = _objc_msgSend(setNavigationPaneSwitcher,sel_retain);
    self->_navigationPaneSwitcher = pHVar2;
    _objc_msgSend(pHVar2,sel_setNavigationController_,self);
    pHVar5 = self;
    _objc_msgSend(self->_navigationPaneSwitcher,sel_setParentViewController_,self);
    if (pvVar1 != (id)0x0) {
      pHVar5 = (HSObjectAssistantNavigationController *)(int)animate;
      _objc_msgSend(self->_navigationPaneSwitcher,sel_viewWillAppear_,pHVar5);
    }
    pvVar3 = _objc_msgSend(self->_navigationPaneSwitcher,sel_view,pHVar5);
    _objc_msgSend(self,sel_setFooterView_,pvVar3);
    pvVar3 = _objc_msgSend(self,sel_assistant);
    pvVar4 = _objc_msgSend(self,sel_footerView);
    _objc_msgSend(pvVar3,sel_setHasSeparatedFooter_,(uint)(pvVar4 != (id)0x0));
    if (pvVar1 != (id)0x0) {
      _objc_msgSend(self->_navigationPaneSwitcher,sel_viewDidAppear_,(int)animate);
    }
  }
  return;
}

*/
- (void)setNavigationPaneSwitcher:(id)aSwitcher animate:(BOOL)aAnimate
{
    if (_navigationPaneSwitcher == aSwitcher) {
        return;
    }
    BOOL visible = [_presentationView superview] != nil;
    if (visible) {
        [_navigationPaneSwitcher viewWillDisappear:aAnimate];
        [_navigationPaneSwitcher setParentViewController:nil];
        [_navigationPaneSwitcher setNavigationController:nil];
        [_navigationPaneSwitcher viewDidDisappear:aAnimate];
    }
    else {
        [_navigationPaneSwitcher setParentViewController:nil];
        [_navigationPaneSwitcher setNavigationController:nil];
    }
    [_navigationPaneSwitcher release];
    _navigationPaneSwitcher = [aSwitcher retain];
    [_navigationPaneSwitcher setNavigationController:self];
    [_navigationPaneSwitcher setParentViewController:self];
    if (visible) {
        [_navigationPaneSwitcher viewWillAppear:aAnimate];
    }
    [self setFooterView:[_navigationPaneSwitcher view]];
    [[self assistant] setHasSeparatedFooter:[self footerView] != nil];
    if (visible) {
        [_navigationPaneSwitcher viewDidAppear:aAnimate];
    }
}

- (id)navigationPaneSwitcher
{
    return _navigationPaneSwitcher;
}

- (id)paneIdentifierForTopViewController
{
    id pvVar1_3;

    if ([[self navigationStack] count] == 0) {
        pvVar1_3 = nil;
    }
    else {
        pvVar1_3 = [[[self navigationStack] lastObject] objectForKey:@"identifier"];
    }
    return pvVar1_3;
}

- (id)viewControllers
{
    return _navigationStack;
}

- (id)topViewController
{
    return [[[self navigationStack] lastObject] objectForKey:@"pane"];
}

- (void)setNavigationStack:(id)aStack
{
    if (_navigationStack != aStack) {
        [_navigationStack release];
        _navigationStack = [aStack retain];
    }
}

- (id)navigationStack
{
    id pvVar1;

    pvVar1 = _navigationStack;
    if (pvVar1 == nil) {
        pvVar1 = [NSMutableArray new];
        _navigationStack = pvVar1;
    }
    return pvVar1;
}

- (id)windowTitle
{
    return [[self topViewController] windowTitle];
}

- (void)viewDidDisappear:(BOOL)aDisappear
{
    int iVar2;

    iVar2 = (int)aDisappear;
    [super viewDidDisappear:iVar2];
    [self removeDisposablePanes];
    [[self topViewController] viewDidDisappear:iVar2];
    [[self navigationPaneSwitcher] viewDidDisappear:iVar2];
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    int iVar2;

    iVar2 = (int)aDisappear;
    [super viewWillDisappear:iVar2];
    [[self topViewController] viewWillDisappear:iVar2];
    [[self navigationPaneSwitcher] viewWillDisappear:iVar2];
}

- (void)viewDidAppear:(BOOL)aAppear
{
    int iVar2;

    iVar2 = (int)aAppear;
    [super viewDidAppear:iVar2];
    [[self topViewController] viewDidAppear:iVar2];
    [[self navigationPaneSwitcher] viewDidAppear:iVar2];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    int iVar2;

    iVar2 = (int)aAppear;
    [super viewWillAppear:iVar2];
    [[self topViewController] viewWillAppear:iVar2];
    [[self navigationPaneSwitcher] viewWillAppear:iVar2];
}

- (void)setAssistant:(id)aAssistant
{
    [super setAssistant:aAssistant];
    [[self topViewController] setAssistant:aAssistant];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0021e7bc @ 0021e7bc, 110 bytes * /

ulonglong FUN_0021e7bc(HSObjectAssistantNavigationController *self,SEL _cmd)

{
  id pvVar1;
  float extraout_EDX;
  float fVar2;
  
  pvVar1 = _objc_msgSend(self,sel_topViewController);
  if (pvVar1 == (id)0x0) {
    pvVar1 = (id)(self->super).super._originalSize.width;
    fVar2 = (self->super).super._originalSize.height;
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_topViewController);
    pvVar1 = _objc_msgSend(pvVar1,sel_presentationSize);
    fVar2 = extraout_EDX;
  }
  return CONCAT44(fVar2,pvVar1);
}

*/
- (NSSize)originalSize
{
    if ([self topViewController] == nil) {
        return _originalSize;
    }
    return [[self topViewController] presentationSize];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0021e82a @ 0021e82a, 420 bytes * /

void FUN_0021e82a(HSObjectAssistantNavigationController *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  id self_01;
  HSObjectAssistantNavigationController *pHVar2;
  HSObjectAssistantNavigationController *pHVar3;
  HSObjectAssistantNavigationController *local_1c;
  undefined *local_18;
  
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  pHVar3 = self;
  _objc_msgSend(pvVar1,sel_removeObserver_,self);
  self_00 = _objc_msgSend(self->_navigationStack,sel_objectEnumerator);
  pvVar1 = _objc_msgSend(self_00,sel_nextObject);
  while (pvVar1 != (id)0x0) {
    self_01 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_pane);
    _objc_msgSend(self_01,sel_performSelector_withObject_,sel_setParentViewController_,0);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_pane);
    pHVar3 = (HSObjectAssistantNavigationController *)sel_setObjectAssistantNavigationController_;
    _objc_msgSend(pvVar1,sel_performSelector_withObject_,sel_setObjectAssistantNavigationController_
                  ,0);
    pvVar1 = _objc_msgSend(self_00,sel_nextObject);
  }
  _objc_msgSend(self->_navigationStack,sel_release,pHVar3);
  pHVar2 = _objc_msgSend(self->_navigationPaneSwitcher,sel_navigationController);
  if (pHVar2 == self) {
    pHVar3 = (HSObjectAssistantNavigationController *)0x0;
    _objc_msgSend(self->_navigationPaneSwitcher,sel_setNavigationController_,0);
  }
  _objc_msgSend(self->_navigationPaneSwitcher,sel_release,pHVar3);
  local_1c = self;
  local_18 = PTR_s_HSObjectAssistantPane_00354da0;
  _objc_msgSendSuper(&local_1c,sel_dealloc);
  return;
}

*/
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    for (NSDictionary *entry in _navigationStack) {
        [[entry objectForKey:@"pane"] performSelector:@selector(setParentViewController:) withObject:nil];
        [[entry objectForKey:@"pane"] performSelector:@selector(setObjectAssistantNavigationController:) withObject:nil];
    }
    [_navigationStack release];
    if ([_navigationPaneSwitcher navigationController] == self) {
        [_navigationPaneSwitcher setNavigationController:nil];
    }
    [_navigationPaneSwitcher release];
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)aZone
{
    id pvVar1_2;
    id pvVar2_2;

    pvVar1_2 = [[HSObjectAssistantNavigationController alloc] initWithNibName:@"InspectorNavigationController"];
    pvVar2_2 = [[self navigationStack] copy];
    [pvVar1_2 setNavigationStack:pvVar2_2];
    [pvVar2_2 release];
    return pvVar1_2;
}

- (id)initWithRootViewController:(id)aController
{
    return [self initWithRootViewController:aController identifier:nil];
}

- (id)initWithRootViewController:(id)aController identifier:(id)aIdentifier
{
    self = [super initWithNibName:@"InspectorNavigationController"];
    if ((self != nil) && (aController != nil)) {
        [self pushViewController:aController withIdentifier:aIdentifier animate:NO replacePrevious:NO];
    }
    return self;
}

@end

@implementation HSObjectAssistantPane (HSObjectAssistantNavigationControllerItem)

- (id)navigationPaneSwitcher
{
    return nil;
}

- (void)setObjectAssistantNavigationController:(id)aController
{
    _objectAssistantNavigationController = aController;
}

- (id)objectAssistantNavigationController
{
    return _objectAssistantNavigationController;
}

@end

