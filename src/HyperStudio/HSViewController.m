#import "HSViewController.h"

@implementation HSViewController

/* i386 ivar offsets: _nibName=0x4, _nibBundle=0x8, _title=0xc, _icon=0x10, _originalSize=0x14, _presentationSize=0x1c, _layoutIsValid=0x24, _view=0x28, _parentViewController=0x2c, _modalViewController=0x30, _presentationView=0x34, _headerView=0x38, _footerView=0x3c */

- (id)nameTextfField
{
    return nil;
}

- (id)initialKeyView
{
    return nil;
}

- (void)viewDidDisappear:(BOOL)aDisappear
{

}

- (void)viewWillDisappear:(BOOL)aDisappear
{

}

- (void)viewDidAppear:(BOOL)aAppear
{

}

- (void)viewWillAppear:(BOOL)aAppear
{
    [self loadViewIfNeeded];
}

- (void)viewDidLoad
{

}

- (void)notifyViewDidDisappear:(BOOL)aDisappear
{
    if ([self modalViewController] != nil) {
        self = [self modalViewController];
    }
    [self viewDidDisappear:aDisappear];
}

- (void)notifyViewWillDisappear:(BOOL)aDisappear
{
    if ([self modalViewController] != nil) {
        self = [self modalViewController];
    }
    [self viewWillDisappear:aDisappear];
}

- (void)notifyViewDidAppear:(BOOL)aAppear
{
    if ([self modalViewController] != nil) {
        self = [self modalViewController];
    }
    [self viewDidAppear:aAppear];
}

- (void)notifyViewWillAppear:(BOOL)aAppear
{
    if ([self modalViewController] != nil) {
        self = [self modalViewController];
    }
    [self viewWillAppear:aAppear];
}

- (void)setFooterView:(id)aView
{
    id pvVar1;

    if (_footerView != aView) {
        [_footerView removeFromSuperview];
        [_footerView release];
        pvVar1 = [aView retain];
        _footerView = pvVar1;
        if (pvVar1 != nil) {
            [pvVar1 setFrameOrigin:NSZeroPoint];
            [[self view] addSubview:_footerView];
        }
        [self invalidateLayout];
    }
}

- (id)footerView
{
    return _footerView;
}

- (void)setHeaderView:(id)aView
{
    id pvVar1;

    if (_headerView != aView) {
        [_headerView removeFromSuperview];
        [_headerView release];
        pvVar1 = [aView retain];
        _headerView = pvVar1;
        if (pvVar1 != nil) {
            [pvVar1 setFrameOrigin:NSZeroPoint];
            [[self view] addSubview:_headerView];
        }
        [self invalidateLayout];
    }
}

- (id)headerView
{
    return _headerView;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0020f417 @ 0020f417, 1778 bytes * /

void FUN_0020f417(HSViewController *self,SEL _cmd,BOOL dismissModalViewControllerAnimated)

{
  HSViewController *pHVar1;
  undefined *puVar2;
  id pvVar3;
  id pvVar4;
  id self_00;
  undefined4 *puVar5;
  undefined1 local_24 [20];
  
  puVar5 = (undefined4 *)&stack0xffffffa4;
  if (self->_parentViewController == (HSViewController *)0x0) {
    pvVar3 = _objc_msgSend(self->_presentationView,sel_superview);
    if (pvVar3 != (id)0x0) {
      _objc_msgSend(self->_modalViewController,sel_viewWillDisappear_);
      _objc_msgSend(self,sel_viewWillAppear_);
    }
    _objc_msgSend(self,sel_invalidateLayout);
    if (dismissModalViewControllerAnimated == '\0') {
      pvVar4 = _objc_msgSend(self->_modalViewController,sel_view);
      _objc_msgSend(pvVar4,sel_removeFromSuperviewWithoutNeedingDisplay);
      pvVar4 = _objc_msgSend(self,sel_view);
      _objc_msgSend(self,sel_contentView);
      _objc_msgSend(pvVar4,sel_addSubview_);
      pvVar4 = _objc_msgSend(self,sel_view);
      _objc_msgSend(self,sel_headerView);
      _objc_msgSend(pvVar4,sel_addSubview_);
      pvVar4 = _objc_msgSend(self,sel_view);
      _objc_msgSend(self,sel_footerView);
      _objc_msgSend(pvVar4,sel_addSubview_);
      puVar2 = cls_NSDictionary;
      _objc_msgSend(self,sel_contentView);
      _objc_msgSend(puVar2,sel_dictionaryWithObjectsAndKeys_);
      pvVar4 = _objc_msgSend(cls_NSViewAnimation,sel_alloc);
      _objc_msgSend(cls_NSArray,sel_arrayWithObjects_);
      pvVar4 = _objc_msgSend(pvVar4,sel_initWithViewAnimations_);
      _objc_msgSend(pvVar4,sel_setDuration_);
      _objc_msgSend(pvVar4,sel_setAnimationBlockingMode_);
      _objc_msgSend(self,sel_startAnimationWithoutHeartBeating_);
      _objc_msgSend(pvVar4,sel_release);
    }
    else {
      pvVar4 = _objc_msgSend(self,sel_contentView);
      self_00 = _objc_msgSend(self,sel_view);
      _objc_msgSend_stret(local_24,self_00,sel_bounds);
      puVar5 = (undefined4 *)&stack0xffffffa0;
      _objc_msgSend(pvVar4,sel_setFrame_);
      pvVar4 = _objc_msgSend(self,sel_view);
      _objc_msgSend(self,sel_contentView);
      _objc_msgSend(pvVar4,sel_addSubview_);
      pvVar4 = _objc_msgSend(self,sel_view);
      _objc_msgSend(self,sel_headerView);
      _objc_msgSend(pvVar4,sel_addSubview_);
      pvVar4 = _objc_msgSend(self,sel_view);
      _objc_msgSend(self,sel_footerView);
      _objc_msgSend(pvVar4,sel_addSubview_);
      pvVar4 = _objc_msgSend(self,sel_contentView);
      _objc_msgSend(pvVar4,sel_setAutoresizingMask_);
      puVar2 = cls_NSDictionary;
      _objc_msgSend(self->_modalViewController,sel_view);
      _objc_msgSend(puVar2,sel_dictionaryWithObjectsAndKeys_);
      puVar2 = cls_NSDictionary;
      _objc_msgSend(self,sel_contentView);
      _objc_msgSend(puVar2,sel_dictionaryWithObjectsAndKeys_);
      pvVar4 = _objc_msgSend(cls_NSViewAnimation,sel_alloc);
      _objc_msgSend(cls_NSArray,sel_arrayWithObjects_);
      pvVar4 = _objc_msgSend(pvVar4,sel_initWithViewAnimations_);
      _HSObjectAssistantAnimationDuration();
      _objc_msgSend(pvVar4,sel_setDuration_);
      _objc_msgSend(pvVar4,sel_setAnimationCurve_);
      _objc_msgSend(pvVar4,sel_setAnimationBlockingMode_);
      _objc_msgSend(self,sel_startAnimationWithoutHeartBeating_);
      _objc_msgSend(pvVar4,sel_release);
      pvVar4 = _objc_msgSend(self->_modalViewController,sel_view);
      _objc_msgSend(pvVar4,sel_removeFromSuperviewWithoutNeedingDisplay);
    }
    pvVar4 = self->_view;
    puVar5[1] = sel_setAutoresizingMask_;
    *puVar5 = pvVar4;
    puVar5[2] = 0x12;
    puVar5[-1] = 0x20fa55;
    _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
    pvVar4 = self->_headerView;
    puVar5[1] = sel_setAutoresizingMask_;
    *puVar5 = pvVar4;
    puVar5[2] = 10;
    puVar5[-1] = 0x20fa72;
    _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
    pvVar4 = self->_footerView;
    puVar5[1] = sel_setAutoresizingMask_;
    *puVar5 = pvVar4;
    puVar5[2] = 0x22;
    puVar5[-1] = 0x20fa8f;
    _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
    pHVar1 = self->_modalViewController;
    puVar5[1] = sel_setParentViewController_;
    *puVar5 = pHVar1;
    puVar5[2] = 0;
    puVar5[-1] = 0x20faac;
    _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
    if (pvVar3 != (id)0x0) {
      pHVar1 = self->_modalViewController;
      puVar5[2] = (int)dismissModalViewControllerAnimated;
      puVar5[1] = sel_viewDidDisappear_;
      *puVar5 = pHVar1;
      puVar5[-1] = 0x20facf;
      _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
      puVar5[2] = (int)dismissModalViewControllerAnimated;
      puVar5[1] = sel_viewDidAppear_;
      *puVar5 = self;
      puVar5[-1] = 0x20fae5;
      _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
    }
    pHVar1 = self->_modalViewController;
    puVar5[1] = sel_autorelease;
    *puVar5 = pHVar1;
    puVar5[-1] = 0x20fafd;
    _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
    self->_modalViewController = (HSViewController *)0x0;
  }
  else {
    _objc_msgSend(self->_parentViewController,sel_dismissModalViewControllerAnimated_);
  }
  return;
}

*/
- (void)dismissModalViewControllerAnimated:(BOOL)aAnimated
{
    if (_parentViewController != nil) {
        [_parentViewController dismissModalViewControllerAnimated:aAnimated];
        return;
    }
    BOOL visible = [_presentationView superview] != nil;
    if (visible) {
        [_modalViewController viewWillDisappear:aAnimated];
        [self viewWillAppear:aAnimated];
    }
    [self invalidateLayout];
    if (!aAnimated) {
        [[_modalViewController view] removeFromSuperviewWithoutNeedingDisplay];
        [[self view] addSubview:[self contentView]];
        [[self view] addSubview:[self headerView]];
        [[self view] addSubview:[self footerView]];
        NSDictionary *fadeIn = [NSDictionary dictionaryWithObjectsAndKeys:[self contentView], NSViewAnimationTargetKey, NSViewAnimationFadeInEffect, NSViewAnimationEffectKey, nil];
        NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObjects:fadeIn, nil]];
        [animation setDuration:0.0];
        [animation setAnimationBlockingMode:NSAnimationBlocking];
        [self startAnimationWithoutHeartBeating:animation];
        [animation release];
    } else {
        [[self contentView] setFrame:[[self view] bounds]];
        [[self view] addSubview:[self contentView]];
        [[self view] addSubview:[self headerView]];
        [[self view] addSubview:[self footerView]];
        [[self contentView] setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        NSDictionary *fadeOut = [NSDictionary dictionaryWithObjectsAndKeys:[_modalViewController view], NSViewAnimationTargetKey, NSViewAnimationFadeOutEffect, NSViewAnimationEffectKey, nil];
        NSDictionary *fadeIn = [NSDictionary dictionaryWithObjectsAndKeys:[self contentView], NSViewAnimationTargetKey, NSViewAnimationFadeInEffect, NSViewAnimationEffectKey, nil];
        NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObjects:fadeOut, fadeIn, nil]];
        [animation setDuration:HSObjectAssistantAnimationDuration()];
        [animation setAnimationCurve:NSAnimationEaseIn];
        [animation setAnimationBlockingMode:NSAnimationNonblocking];
        [self startAnimationWithoutHeartBeating:animation];
        [animation release];
        [[_modalViewController view] removeFromSuperviewWithoutNeedingDisplay];
    }
    [_view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [_headerView setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
    [_footerView setAutoresizingMask:NSViewWidthSizable | NSViewMaxYMargin];
    [_modalViewController setParentViewController:nil];
    if (visible) {
        [_modalViewController viewDidDisappear:aAnimated];
        [self viewDidAppear:aAnimated];
    }
    [_modalViewController autorelease];
    _modalViewController = nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0020fb09 @ 0020fb09, 1396 bytes * /

void FUN_0020fb09(HSViewController *self,SEL _cmd,id presentModalViewController,BOOL animated)

{
  undefined *puVar1;
  id pvVar2;
  HSViewController *pHVar3;
  id pvVar4;
  id pvVar5;
  int *piVar6;
  int iStack_78;
  undefined1 local_34 [16];
  undefined1 local_24 [20];
  
  piVar6 = (int *)&stack0xffffff94;
  pHVar3 = self->_parentViewController;
  if (pHVar3 == (HSViewController *)0x0) {
    pvVar2 = _objc_msgSend(self->_presentationView,sel_superview);
    pHVar3 = _objc_msgSend(presentModalViewController,sel_retain);
    self->_modalViewController = pHVar3;
    _objc_msgSend(pHVar3,sel_layout);
    _objc_msgSend(self->_modalViewController,sel_setParentViewController_);
    pvVar4 = _objc_msgSend(self->_modalViewController,sel_view);
    pvVar5 = _objc_msgSend(self,sel_view);
    _objc_msgSend_stret(local_34,pvVar5,sel_bounds);
    piVar6 = (int *)&stack0xffffff90;
    _objc_msgSend(pvVar4,sel_setFrame_);
    if (pvVar2 != (id)0x0) {
      _objc_msgSend(self,sel_viewWillDisappear_);
      _objc_msgSend(self->_modalViewController,sel_viewWillAppear_);
    }
    _objc_msgSend(self,sel_invalidateLayout);
    if (animated == '\0') {
      pvVar4 = _objc_msgSend(self,sel_contentView);
      _objc_msgSend(pvVar4,sel_removeFromSuperviewWithoutNeedingDisplay);
      pvVar4 = _objc_msgSend(self,sel_footerView);
      _objc_msgSend(pvVar4,sel_removeFromSuperviewWithoutNeedingDisplay);
      pvVar4 = _objc_msgSend(self,sel_headerView);
      _objc_msgSend(pvVar4,sel_removeFromSuperviewWithoutNeedingDisplay);
      pvVar4 = _objc_msgSend(self,sel_view);
      _objc_msgSend(self->_modalViewController,sel_view);
      _objc_msgSend(pvVar4,sel_addSubview_);
    }
    else {
      pvVar4 = _objc_msgSend(self->_modalViewController,sel_view);
      pvVar5 = _objc_msgSend(self,sel_view);
      _objc_msgSend_stret(local_24,pvVar5,sel_bounds);
      piVar6 = (int *)&stack0xffffff8c;
      _objc_msgSend(pvVar4,sel_setFrame_);
      pvVar4 = _objc_msgSend(self,sel_view);
      _objc_msgSend(self->_modalViewController,sel_view);
      _objc_msgSend(pvVar4,sel_addSubview_);
      pvVar4 = _objc_msgSend(self->_modalViewController,sel_view);
      _objc_msgSend(pvVar4,sel_setAutoresizingMask_);
      puVar1 = cls_NSDictionary;
      _objc_msgSend(self,sel_contentView);
      _objc_msgSend(puVar1,sel_dictionaryWithObjectsAndKeys_);
      puVar1 = cls_NSDictionary;
      _objc_msgSend(self->_modalViewController,sel_view);
      _objc_msgSend(puVar1,sel_dictionaryWithObjectsAndKeys_);
      pvVar4 = _objc_msgSend(cls_NSViewAnimation,sel_alloc);
      _objc_msgSend(cls_NSArray,sel_arrayWithObjects_);
      pvVar4 = _objc_msgSend(pvVar4,sel_initWithViewAnimations_);
      _HSObjectAssistantAnimationDuration();
      _objc_msgSend(pvVar4,sel_setDuration_);
      _objc_msgSend(pvVar4,sel_setAnimationCurve_);
      _objc_msgSend(pvVar4,sel_setAnimationBlockingMode_);
      _objc_msgSend(self,sel_startAnimationWithoutHeartBeating_);
      _objc_msgSend(pvVar4,sel_release);
      pvVar4 = _objc_msgSend(self,sel_contentView);
      _objc_msgSend(pvVar4,sel_removeFromSuperviewWithoutNeedingDisplay);
      pvVar4 = _objc_msgSend(self,sel_footerView);
      _objc_msgSend(pvVar4,sel_removeFromSuperviewWithoutNeedingDisplay);
      pvVar4 = _objc_msgSend(self,sel_headerView);
      _objc_msgSend(pvVar4,sel_removeFromSuperviewWithoutNeedingDisplay);
    }
    if (pvVar2 == (id)0x0) {
      return;
    }
    piVar6[2] = (int)animated;
    piVar6[1] = (int)sel_viewDidDisappear_;
    *piVar6 = (int)self;
    piVar6[-1] = 0x210067;
    _objc_msgSend((id)*piVar6,(SEL)piVar6[1]);
    pHVar3 = self->_modalViewController;
    piVar6[2] = (int)animated;
    piVar6[1] = (int)sel_viewDidAppear_;
  }
  *piVar6 = (int)pHVar3;
  piVar6[-1] = 0x20fb43;
  _objc_msgSend((id)*piVar6,(SEL)piVar6[1]);
  return;
}

*/
- (void)presentModalViewController:(id)aController animated:(BOOL)aAnimated
{
    if (_parentViewController != nil) {
        [_parentViewController presentModalViewController:aController animated:aAnimated];
        return;
    }
    BOOL visible = [_presentationView superview] != nil;
    _modalViewController = [aController retain];
    [_modalViewController layout];
    [_modalViewController setParentViewController:self];
    [[_modalViewController view] setFrame:[[self view] bounds]];
    if (visible) {
        [self viewWillDisappear:aAnimated];
        [_modalViewController viewWillAppear:aAnimated];
    }
    [self invalidateLayout];
    if (!aAnimated) {
        [[self contentView] removeFromSuperviewWithoutNeedingDisplay];
        [[self footerView] removeFromSuperviewWithoutNeedingDisplay];
        [[self headerView] removeFromSuperviewWithoutNeedingDisplay];
        [[self view] addSubview:[_modalViewController view]];
    } else {
        [[_modalViewController view] setFrame:[[self view] bounds]];
        [[self view] addSubview:[_modalViewController view]];
        [[_modalViewController view] setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        NSDictionary *fadeOut = [NSDictionary dictionaryWithObjectsAndKeys:[self contentView], NSViewAnimationTargetKey, NSViewAnimationFadeOutEffect, NSViewAnimationEffectKey, nil];
        NSDictionary *fadeIn = [NSDictionary dictionaryWithObjectsAndKeys:[_modalViewController view], NSViewAnimationTargetKey, NSViewAnimationFadeInEffect, NSViewAnimationEffectKey, nil];
        NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObjects:fadeOut, fadeIn, nil]];
        [animation setDuration:HSObjectAssistantAnimationDuration()];
        [animation setAnimationCurve:NSAnimationEaseIn];
        [animation setAnimationBlockingMode:NSAnimationNonblocking];
        [self startAnimationWithoutHeartBeating:animation];
        [animation release];
        [[self contentView] removeFromSuperviewWithoutNeedingDisplay];
        [[self footerView] removeFromSuperviewWithoutNeedingDisplay];
        [[self headerView] removeFromSuperviewWithoutNeedingDisplay];
    }
    if (visible) {
        [self viewDidDisappear:aAnimated];
        [_modalViewController viewDidAppear:aAnimated];
    }
}

- (void)startAnimationWithoutHeartBeating:(id)aBeating
{
    if (![[HSSystem sharedSystem] isLeopardOrGreater]) {
        [[(NSClassFromString(@"NSUIHeartBeat")) sharedHeartBeat] disableHeartBeating];
    }
    [aBeating startAnimation];
    if (![[HSSystem sharedSystem] isLeopardOrGreater]) {
        [[(NSClassFromString(@"NSUIHeartBeat")) sharedHeartBeat] reenableHeartBeating:1];
    }
}

- (id)modalViewController
{
    HSViewController *pHVar1;

    pHVar1 = [[self parentViewController] modalViewController];
    if (pHVar1 == nil) {
        pHVar1 = _modalViewController;
    }
    return pHVar1;
}

- (BOOL)isModalViewController
{
    return [self modalViewController] == self;
}

- (id)assistantPaneUndoManager
{
    return nil;
}

- (BOOL)isVisible
{
    return [[self view] window] != nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0021016d @ 0021016d, 1641 bytes * /

void FUN_0021016d(HSViewController *self,SEL _cmd)

{
  undefined4 uVar1;
  undefined4 uVar2;
  undefined4 uVar3;
  float fVar4;
  undefined4 uVar5;
  float fVar6;
  float fVar7;
  undefined *puVar8;
  undefined4 uVar9;
  char cVar10;
  id pvVar11;
  id pvVar12;
  undefined4 *puVar13;
  undefined4 *puVar14;
  id pvVar15;
  float extraout_EDX;
  float extraout_EDX_00;
  float extraout_EDX_01;
  float *pfVar16;
  float *pfVar17;
  float afStack_e0 [3];
  float local_b0;
  undefined4 local_ac;
  float local_a8;
  float fStack_90;
  float fStack_80;
  undefined1 local_74 [16];
  undefined1 local_64 [12];
  float local_58;
  undefined1 local_54 [8];
  undefined4 local_4c;
  undefined4 local_48;
  undefined1 local_44 [8];
  undefined4 local_3c;
  float local_38;
  undefined1 local_34 [12];
  float local_28;
  undefined1 local_24 [12];
  float local_18;
  
  pfVar17 = (float *)&stack0xffffff34;
  if (self->_layoutIsValid != '\0') {
    return;
  }
  if (self->_modalViewController == (HSViewController *)0x0) {
    pvVar11 = _objc_msgSend(self,sel_originalSize);
    puVar8 = PTR_00336074;
    uVar1 = *(undefined4 *)PTR_00336074;
    fStack_80 = *(float *)(PTR_00336074 + 4);
    pvVar12 = _objc_msgSend(self,sel_originalSize);
    if (self->_headerView == (id)0x0) {
      puVar14 = (undefined4 *)(PTR_0033607c + 4);
      puVar13 = (undefined4 *)PTR_0033607c;
      local_b0 = fStack_80;
      local_ac = uVar1;
    }
    else {
      _objc_msgSend_stret(local_54,self->_headerView,sel_frame);
      pfVar17 = (float *)&stack0xffffff30;
      local_ac = *(undefined4 *)puVar8;
      local_b0 = *(float *)(puVar8 + 4);
      puVar14 = &local_48;
      puVar13 = &local_4c;
    }
    uVar9 = local_ac;
    fStack_90 = local_b0;
    uVar2 = *puVar14;
    uVar3 = *puVar13;
    pvVar15 = self->_footerView;
    if (pvVar15 == (id)0x0) {
      pfVar16 = (float *)(PTR_0033607c + 4);
      puVar14 = (undefined4 *)PTR_0033607c;
    }
    else {
      pfVar17[2] = (float)sel_frame;
      pfVar17[1] = (float)pvVar15;
      *pfVar17 = (float)local_44;
      pfVar17[-1] = 3.032302e-39;
      _objc_msgSend_stret((void *)*pfVar17,(id)pfVar17[1],(SEL)pfVar17[2]);
      pfVar17 = pfVar17 + -1;
      local_ac = *(undefined4 *)puVar8;
      local_b0 = *(float *)(puVar8 + 4);
      pfVar16 = &local_38;
      puVar14 = &local_3c;
    }
    fVar4 = *pfVar16;
    uVar5 = *puVar14;
    pvVar15 = self->_headerView;
    local_a8 = extraout_EDX_00;
    if (pvVar15 != (id)0x0) {
      pfVar17[2] = (float)sel_frame;
      pfVar17[1] = (float)pvVar15;
      *pfVar17 = (float)local_34;
      pfVar17[-1] = 3.032477e-39;
      _objc_msgSend_stret((void *)*pfVar17,(id)pfVar17[1],(SEL)pfVar17[2]);
      pfVar17 = pfVar17 + -1;
      local_a8 = extraout_EDX_00 + local_28;
      fStack_90 = fStack_90 + extraout_EDX_01;
    }
    pvVar15 = self->_footerView;
    if (pvVar15 != (id)0x0) {
      pfVar17[2] = (float)sel_frame;
      pfVar17[1] = (float)pvVar15;
      *pfVar17 = (float)local_24;
      pfVar17[-1] = 3.032589e-39;
      _objc_msgSend_stret((void *)*pfVar17,(id)pfVar17[1],(SEL)pfVar17[2]);
      pfVar17 = pfVar17 + -1;
      local_a8 = local_a8 + local_18;
      fStack_90 = fStack_90 + fVar4;
      fStack_80 = fVar4 + fStack_80;
    }
    fVar6 = (self->_presentationSize).width;
    fVar7 = (self->_presentationSize).height;
    pfVar17[3] = local_a8;
    pfVar17[2] = (float)pvVar11;
    pfVar17[1] = fVar7;
    *pfVar17 = fVar6;
    pfVar17[-1] = 3.032756e-39;
    cVar10 = _NSEqualSizes();
    if (cVar10 == '\0') {
      (self->_presentationSize).width = (float)pvVar11;
      (self->_presentationSize).height = local_a8;
    }
    pvVar15 = self->_view;
    pfVar17[1] = (float)sel_setAutoresizingMask_;
    *pfVar17 = (float)pvVar15;
    pfVar17[2] = 0.0;
    pfVar17[-1] = 3.032847e-39;
    _objc_msgSend((id)*pfVar17,(SEL)pfVar17[1]);
    pvVar15 = self->_headerView;
    pfVar17[1] = (float)sel_setAutoresizingMask_;
    *pfVar17 = (float)pvVar15;
    pfVar17[2] = 0.0;
    pfVar17[-1] = 3.032888e-39;
    _objc_msgSend((id)*pfVar17,(SEL)pfVar17[1]);
    pvVar15 = self->_footerView;
    pfVar17[1] = (float)sel_setAutoresizingMask_;
    *pfVar17 = (float)pvVar15;
    pfVar17[2] = 0.0;
    pfVar17[-1] = 3.032928e-39;
    _objc_msgSend((id)*pfVar17,(SEL)pfVar17[1]);
    pfVar17[1] = (float)sel_view;
    *pfVar17 = (float)self;
    pfVar17[-1] = 3.032954e-39;
    pvVar15 = _objc_msgSend((id)*pfVar17,(SEL)pfVar17[1]);
    pfVar17[3] = local_a8;
    pfVar17[2] = (float)pvVar11;
    pfVar17[1] = (float)sel_setFrameSize_;
    *pfVar17 = (float)pvVar15;
    pfVar17[-1] = 3.033018e-39;
    _objc_msgSend((id)*pfVar17,(SEL)pfVar17[1]);
    pvVar11 = self->_view;
    *(ulonglong *)(pfVar17 + 4) = CONCAT44(extraout_EDX_01,pvVar12);
    *(ulonglong *)(pfVar17 + 2) = CONCAT44(fStack_80,uVar1);
    pfVar17[1] = (float)sel_setFrame_;
    *pfVar17 = (float)pvVar11;
    pfVar17[-1] = 3.033078e-39;
    _objc_msgSend((id)*pfVar17,(SEL)pfVar17[1]);
    pvVar11 = self->_headerView;
    if (pvVar11 != (id)0x0) {
      *(ulonglong *)(pfVar17 + 4) = CONCAT44(uVar2,uVar3);
      *(ulonglong *)(pfVar17 + 2) = CONCAT44(fStack_90,uVar9);
      pfVar17[1] = (float)sel_setFrame_;
      *pfVar17 = (float)pvVar11;
      pfVar17[-1] = 3.033153e-39;
      _objc_msgSend((id)*pfVar17,(SEL)pfVar17[1]);
    }
    pvVar11 = self->_footerView;
    if (pvVar11 != (id)0x0) {
      *(ulonglong *)(pfVar17 + 4) = CONCAT44(fVar4,uVar5);
      *(ulonglong *)(pfVar17 + 2) = CONCAT44(local_b0,local_ac);
      pfVar17[1] = (float)sel_setFrame_;
      *pfVar17 = (float)pvVar11;
      pfVar17[-1] = 3.033231e-39;
      _objc_msgSend((id)*pfVar17,(SEL)pfVar17[1]);
    }
    pvVar11 = self->_view;
    pfVar17[1] = (float)sel_setAutoresizingMask_;
    *pfVar17 = (float)pvVar11;
    pfVar17[2] = 2.52234e-44;
    pfVar17[-1] = 3.033276e-39;
    _objc_msgSend((id)*pfVar17,(SEL)pfVar17[1]);
    pvVar11 = self->_headerView;
    pfVar17[1] = (float)sel_setAutoresizingMask_;
    *pfVar17 = (float)pvVar11;
    pfVar17[2] = 1.4013e-44;
    pfVar17[-1] = 3.033317e-39;
    _objc_msgSend((id)*pfVar17,(SEL)pfVar17[1]);
    pvVar11 = self->_footerView;
    pfVar17[1] = (float)sel_setAutoresizingMask_;
    *pfVar17 = (float)pvVar11;
    pfVar17[2] = 4.76441e-44;
  }
  else {
    _objc_msgSend(self->_modalViewController,sel_layout);
    pvVar11 = _objc_msgSend(self->_modalViewController,sel_view);
    _objc_msgSend(pvVar11,sel_setAutoresizingMask_);
    pvVar11 = _objc_msgSend(self,sel_view);
    _objc_msgSend(self->_modalViewController,sel_view);
    _objc_msgSend(pvVar11,sel_addSubview_);
    pvVar11 = _objc_msgSend(self->_modalViewController,sel_view);
    pvVar12 = _objc_msgSend(self,sel_view);
    _objc_msgSend_stret(local_74,pvVar12,sel_bounds);
    _objc_msgSend(pvVar11,sel_setFrame_);
    pvVar11 = _objc_msgSend(self->_modalViewController,sel_view);
    _objc_msgSend(pvVar11,sel_setAutoresizingMask_);
    pvVar11 = _objc_msgSend(self->_modalViewController,sel_presentationSize);
    (self->_presentationSize).width = (float)pvVar11;
    (self->_presentationSize).height = extraout_EDX;
    pvVar11 = _objc_msgSend(self,sel_view);
    _objc_msgSend_stret(local_64,pvVar11,sel_frame);
    pfVar17 = (float *)&stack0xffffff2c;
    if (local_58 < extraout_EDX) goto LAB_002107c4;
    pvVar11 = _objc_msgSend(self,sel_view);
    pvVar11 = _objc_msgSend(pvVar11,sel_window);
    pvVar11 = _objc_msgSend(pvVar11,sel_isVisible);
    if ((char)pvVar11 == '\0') goto LAB_002107c4;
    _objc_msgSend(self,sel_view);
  }
  pfVar17[-1] = 3.033357e-39;
  _objc_msgSend((id)*pfVar17,(SEL)pfVar17[1]);
LAB_002107c4:
  self->_layoutIsValid = '\x01';
  return;
}

*/
- (void)layout
{
    if (_layoutIsValid) {
        return;
    }
    if (_modalViewController == nil) {
        NSSize original = [self originalSize];
        NSSize totalSize = original;
        NSRect contentRect = NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, original.width, original.height);
        NSRect headerRect = NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, 0, 0);
        NSRect footerRect = NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, 0, 0);
        if (_headerView != nil) {
            headerRect.size = [_headerView frame].size;
        }
        if (_footerView != nil) {
            footerRect.size = [_footerView frame].size;
        }
        if (_headerView != nil) {
            totalSize.height += [_headerView frame].size.height;
            headerRect.origin.y += contentRect.size.height;
        }
        if (_footerView != nil) {
            totalSize.height += [_footerView frame].size.height;
            headerRect.origin.y += footerRect.size.height;
            contentRect.origin.y += footerRect.size.height;
        }
        if (!NSEqualSizes(_presentationSize, totalSize)) {
            _presentationSize = totalSize;
        }
        [_view setAutoresizingMask:NSViewNotSizable];
        [_headerView setAutoresizingMask:NSViewNotSizable];
        [_footerView setAutoresizingMask:NSViewNotSizable];
        [[self view] setFrameSize:totalSize];
        [_view setFrame:contentRect];
        if (_headerView != nil) {
            [_headerView setFrame:headerRect];
        }
        if (_footerView != nil) {
            [_footerView setFrame:footerRect];
        }
        [_view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [_headerView setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
        [_footerView setAutoresizingMask:NSViewWidthSizable | NSViewMaxYMargin];
    } else {
        [_modalViewController layout];
        [[_modalViewController view] setAutoresizingMask:NSViewNotSizable];
        [[self view] addSubview:[_modalViewController view]];
        [[_modalViewController view] setFrame:[[self view] bounds]];
        [[_modalViewController view] setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        _presentationSize = [_modalViewController presentationSize];
        if ([[self view] frame].size.height >= _presentationSize.height && [[[self view] window] isVisible]) {
            [[self view] setFrameSize:_presentationSize];
        }
    }
    _layoutIsValid = YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0020eef4 @ 0020eef4, 97 bytes * /

void FUN_0020eef4(HSViewController *self,SEL _cmd)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_parentViewController);
  op = sel_layout;
  if (pvVar1 != (id)0x0) {
    self = _objc_msgSend(self,sel_parentViewController);
    op = sel_layoutIfNeeded;
  }
  _objc_msgSend(self,op);
  return;
}

*/
- (void)layoutIfNeeded
{
    if ([self parentViewController] != nil) {
        [[self parentViewController] layoutIfNeeded];
    } else {
        [self layout];
    }
}

- (void)invalidateLayout
{
    if (_layoutIsValid != NO) {
        _layoutIsValid = NO;
        [[self parentViewController] invalidateLayout];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0020ee6e @ 0020ee6e, 66 bytes * /

ulonglong FUN_0020ee6e(HSViewController *self,SEL _cmd)

{
  ulonglong uVar1;
  
  _objc_msgSend(self,sel_loadViewIfNeeded);
  _objc_msgSend(self,sel_layout);
  uVar1._0_4_ = (self->_presentationSize).width;
  uVar1._4_4_ = (self->_presentationSize).height;
  return uVar1;
}

*/
- (NSSize)presentationSize
{
    [self loadViewIfNeeded];
    [self layout];
    return _presentationSize;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0020ee11 @ 0020ee11, 93 bytes * /

ulonglong FUN_0020ee11(HSViewController *self,SEL _cmd)

{
  id pvVar1;
  float extraout_EDX;
  float fVar2;
  
  _objc_msgSend(self,sel_loadViewIfNeeded);
  pvVar1 = (id)(self->_originalSize).width;
  fVar2 = (self->_originalSize).height;
  if (self->_modalViewController != (HSViewController *)0x0) {
    pvVar1 = _objc_msgSend(self->_modalViewController,sel_presentationSize);
    fVar2 = extraout_EDX;
  }
  return CONCAT44(fVar2,pvVar1);
}

*/
- (NSSize)originalSize
{
    [self loadViewIfNeeded];
    NSSize size = _originalSize;
    if (_modalViewController != nil) {
        size = [_modalViewController presentationSize];
    }
    return size;
}

- (id)view
{
    [self loadViewIfNeeded];
    return _presentationView;
}

- (id)contentView
{
    [self loadViewIfNeeded];
    return _view;
}

- (void)loadViewIfNeeded
{
    if (_view == nil) {
        [self loadView];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002107d6 @ 002107d6, 295 bytes * /

void FUN_002107d6(HSViewController *self,SEL _cmd)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined1 local_24 [8];
  float local_1c;
  float local_18;
  
  self_00 = _objc_msgSend(self,sel_nibBundle);
  if (self_00 == (id)0x0) {
    self_00 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  }
  pvVar1 = _objc_msgSend(self,sel_zone);
  pvVar2 = _objc_msgSend(cls_NSDictionary,sel_dictionaryWithObject_forKey_,self,&cfstr_NSOwner);
  pvVar3 = _objc_msgSend(self,sel_nibName);
  _objc_msgSend(self_00,sel_loadNibFile_externalNameTable_withZone_,pvVar3,pvVar2,pvVar1);
  _objc_msgSend_stret(local_24,self->_view,sel_frame);
  (self->_originalSize).width = local_1c;
  (self->_originalSize).height = local_18;
  _objc_msgSend(self,sel_createPresentationView);
  _objc_msgSend(self,sel_viewDidLoad);
  return;
}

*/
- (void)loadView
{
    NSBundle *bundle = [self nibBundle];
    if (bundle == nil) {
        bundle = [NSBundle mainBundle];
    }
    [bundle loadNibFile:[self nibName] externalNameTable:[NSDictionary dictionaryWithObject:self forKey:@"NSOwner"] withZone:[self zone]];
    _originalSize = [_view frame].size;
    [self createPresentationView];
    [self viewDidLoad];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-multiple-method-names"
- (void)createPresentationView
{
    id pvVar1_2;

    pvVar1_2 = [[HSImageView alloc] initWithFrame:[_view bounds]];
    _presentationView = pvVar1_2;
    [pvVar1_2 setAutoresizingMask:[_view autoresizingMask]];
    [_view setAutoresizingMask:0x12];
    [_presentationView addSubview:_view];
    [self layout];
}
#pragma clang diagnostic pop

- (void)setIcon:(id)aIcon
{
    if (_icon != aIcon) {
        [_icon release];
        _icon = [aIcon retain];
    }
}

- (id)icon
{
    return _icon;
}

- (void)setTitle:(id)aTitle
{
    if (![_title isEqual:aTitle]) {
        [_title release];
        _title = [aTitle retain];
    }
}

- (id)title
{
    return _title;
}

- (id)nibBundle
{
    return _nibBundle;
}

- (id)nibName
{
    return _nibName;
}

- (void)setParentViewController:(id)aController
{
    if (_parentViewController != aController) {
        _parentViewController = aController;
    }
}

- (id)parentViewController
{
    return _parentViewController;
}

- (id)rootViewController
{
    if ([self parentViewController] != nil) {
        self = [[self parentViewController] rootViewController];
    }
    return self;
}

- (void)dealloc
{
    [_nibName release];
    [_nibBundle release];
    [_view release];
    [_title release];
    [_icon release];
    [_presentationView release];
    [_headerView release];
    [_footerView release];
    [_modalViewController release];
    [super dealloc];
}

- (id)initWithNibName:(id)aName bundle:(id)aBundle
{
    self = [super init];
    if (self != nil) {
        _nibName = [aName retain];
        _nibBundle = [aBundle retain];
    }
    return self;
}

- (id)initWithNibName:(id)aName
{
    return [self initWithNibName:aName bundle:0];
}

@end

