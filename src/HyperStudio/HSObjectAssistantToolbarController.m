#import "HSObjectAssistantToolbarController.h"

@implementation HSObjectAssistantToolbarController

/* i386 ivar offsets: _viewControllers=0x5c, _identifiers=0x60, _selectedViewController=0x64, _defaultPaneIdentifier=0x68, _isVisible=0x6c, _animation=0x70, _containerView=0x74, _toolbarMatrix=0x78 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_0021378e @ 0021378e, 87 bytes * /

void FUN_0021378e(HSObjectAssistantToolbarController *self,SEL _cmd,
                 id objectAssistantPaneAvailabilityDidChange)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_modalViewController);
  op = sel_validatePanesAvailability;
  if (pvVar1 != (id)0x0) {
    op = sel_dismissModalViewControllerAnimated_;
  }
  _objc_msgSend(self,op);
  return;
}

*/
- (void)objectAssistantPaneAvailabilityDidChange:(id)aChange
{
    if ([self modalViewController] != nil) {
        [self dismissModalViewControllerAnimated:YES];
    } else {
        [self validatePanesAvailability];
    }
}

- (void)openPreviousPane:(id)aPane
{
    int iVar2;
    id pvVar1_4;

    iVar2 = (int)[_toolbarMatrix selectedColumn] + -1;
    if (iVar2 < 0) {
        iVar2 = (int)[_toolbarMatrix numberOfColumns] + -1;
    }
    pvVar1_4 = [_viewControllers objectForKey:[_identifiers objectAtIndex:iVar2]];
    if ([pvVar1_4 isEnabled]) {
        [self selectViewController:pvVar1_4 animate:YES];
        return;
    }
    NSBeep();
}

- (void)openNextPane:(id)aPane
{
    NSInteger pvVar1;
    NSInteger pvVar2;
    int iVar3;
    id pvVar1_3;

    pvVar1 = [_toolbarMatrix selectedColumn];
    pvVar2 = [_toolbarMatrix numberOfColumns];
    iVar3 = 0;
    if ((int)pvVar1 + 1 < (int)pvVar2) {
        iVar3 = (int)pvVar1 + 1;
    }
    pvVar1_3 = [_viewControllers objectForKey:[_identifiers objectAtIndex:iVar3]];
    if ([pvVar1_3 isEnabled]) {
        [self selectViewController:pvVar1_3 animate:YES];
        return;
    }
    NSBeep();
}

- (void)switchPane:(id)aPane
{
    [self selectViewController:[[_toolbarMatrix selectedCell] representedObject] animate:YES];
}

- (void)animationDidEnd:(id)aEnd
{
    if (_animation == aEnd) {
        [self invalidateAnimation];
    }
}

- (void)animationDidStop:(id)aStop
{
    if (_animation == aStop) {
        [self invalidateAnimation];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00213a1e @ 00213a1e, 1205 bytes * /

void FUN_00213a1e(HSObjectAssistantToolbarController *self,SEL _cmd,id selectViewController,
                 BOOL animate)

{
  undefined4 uVar1;
  undefined4 uVar2;
  undefined *puVar3;
  undefined *puVar4;
  undefined *self_00;
  id pvVar5;
  id pvVar6;
  HSObjectAssistantPane *pHVar7;
  id pvVar8;
  id self_01;
  longdouble lVar9;
  undefined4 uVar12;
  undefined8 uVar10;
  double dVar11;
  undefined8 local_24;
  undefined8 local_1c;
  
  pHVar7 = self->_selectedViewController;
  if (pHVar7 != selectViewController) {
    if (self->_isVisible != '\0') {
      _objc_msgSend(pHVar7,sel_viewWillDisappear_);
      pHVar7 = self->_selectedViewController;
    }
    _objc_msgSend(pHVar7,sel_setParentViewController_);
    if (self->_isVisible != '\0') {
      _objc_msgSend(self->_selectedViewController,sel_viewDidDisappear_);
    }
    if (animate == '\0') {
      pvVar5 = _objc_msgSend(self->_selectedViewController,sel_view);
      _objc_msgSend(pvVar5,sel_removeFromSuperview);
    }
    _objc_msgSend(self->_selectedViewController,sel_setAssistant_);
    pvVar6 = _objc_msgSend(self->_selectedViewController,sel_view);
    _objc_msgSend(self->_selectedViewController,sel_release);
    pHVar7 = _objc_msgSend(selectViewController,sel_retain);
    self->_selectedViewController = pHVar7;
    _objc_msgSend(self,sel_assistant);
    _objc_msgSend(pHVar7,sel_setAssistant_);
    pvVar5 = _objc_msgSend(self->_selectedViewController,sel_view);
    _objc_msgSend_stret(&local_24,self->_containerView,sel_bounds);
    _objc_msgSend(pvVar5,sel_setFrame_,local_24,local_1c);
    uVar12 = (undefined4)((ulonglong)local_24 >> 0x20);
    pvVar5 = self->_containerView;
    pvVar8 = _objc_msgSend(self->_selectedViewController,sel_view);
    _objc_msgSend(pvVar5,sel_addSubview_,pvVar8);
    pvVar5 = _objc_msgSend(self->_selectedViewController,sel_view);
    uVar10 = CONCAT44(uVar12,0x12);
    _objc_msgSend(pvVar5,sel_setAutoresizingMask_,0x12);
    if (self->_isVisible != '\0') {
      uVar10 = CONCAT44((int)((ulonglong)uVar10 >> 0x20),(int)animate);
      _objc_msgSend(self->_selectedViewController,sel_viewWillAppear_,(int)animate);
    }
    if (animate != '\0') {
      if (self->_animation != (id)0x0) {
        _objc_msgSend(self,sel_invalidateAnimation,uVar10);
      }
      puVar4 = PTR_00336554;
      puVar3 = PTR_00336544;
      pvVar5 = _objc_msgSend(cls_NSDictionary,sel_dictionaryWithObjectsAndKeys_,pvVar6,
                             *(undefined4 *)PTR_00336554,*(undefined4 *)PTR_0033654c,
                             *(undefined4 *)PTR_00336544,0);
      self_00 = cls_NSDictionary;
      uVar12 = *(undefined4 *)puVar4;
      uVar1 = *(undefined4 *)PTR_003365ac;
      uVar2 = *(undefined4 *)puVar3;
      pvVar8 = _objc_msgSend(self->_selectedViewController,sel_view);
      pvVar8 = _objc_msgSend(self_00,sel_dictionaryWithObjectsAndKeys_,pvVar8,uVar12,uVar1,uVar2,0);
      self_01 = _objc_msgSend(cls_NSViewAnimation,sel_alloc);
      pvVar5 = _objc_msgSend(cls_NSArray,sel_arrayWithObjects_,pvVar8,pvVar5,0);
      pvVar5 = _objc_msgSend(self_01,sel_initWithViewAnimations_,pvVar5);
      self->_animation = pvVar5;
      _objc_msgSend(pvVar5,sel_setAnimationBlockingMode_,1);
      pvVar5 = self->_animation;
      lVar9 = (longdouble)_HSObjectAssistantAnimationDuration();
      dVar11 = (double)lVar9;
      _objc_msgSend(pvVar5,sel_setDuration_,dVar11);
      uVar10 = CONCAT44((int)((ulonglong)dVar11 >> 0x20),self);
      _objc_msgSend(self->_animation,sel_setDelegate_,self);
      _objc_msgSend(self->_animation,sel_startAnimation);
      _objc_msgSend(pvVar6,sel_removeFromSuperview);
    }
    uVar10 = CONCAT44((int)((ulonglong)uVar10 >> 0x20),self);
    _objc_msgSend(self->_selectedViewController,sel_setParentViewController_,self);
    if (self->_isVisible != '\0') {
      uVar10 = CONCAT44((int)((ulonglong)uVar10 >> 0x20),(int)animate);
      _objc_msgSend(self->_selectedViewController,sel_viewDidAppear_,(int)animate);
    }
    pvVar5 = _objc_msgSend(self->_toolbarMatrix,sel_cells,uVar10);
    pvVar5 = _objc_msgSend(pvVar5,sel_objectEnumerator);
    do {
      pvVar6 = _objc_msgSend(pvVar5,sel_nextObject);
      if (pvVar6 == (id)0x0) {
        return;
      }
      pHVar7 = _objc_msgSend(pvVar6,sel_representedObject);
    } while (pHVar7 != self->_selectedViewController);
    _objc_msgSend(self->_toolbarMatrix,sel_selectCell_,pvVar6);
  }
  return;
}

*/
- (void)selectViewController:(id)aController animate:(BOOL)aAnimate
{
    if (_selectedViewController == aController) {
        return;
    }
    if (_isVisible) {
        [_selectedViewController viewWillDisappear:aAnimate];
    }
    [_selectedViewController setParentViewController:nil];
    if (_isVisible) {
        [_selectedViewController viewDidDisappear:aAnimate];
    }
    if (!aAnimate) {
        [[_selectedViewController view] removeFromSuperview];
    }
    [_selectedViewController setAssistant:nil];
    NSView *oldView = [_selectedViewController view];
    [_selectedViewController release];
    _selectedViewController = [aController retain];
    [_selectedViewController setAssistant:[self assistant]];
    [[_selectedViewController view] setFrame:[_containerView bounds]];
    [_containerView addSubview:[_selectedViewController view]];
    [[_selectedViewController view] setAutoresizingMask:0x12];
    if (_isVisible) {
        [_selectedViewController viewWillAppear:aAnimate];
    }
    if (aAnimate) {
        if (_animation != nil) {
            [self invalidateAnimation];
        }
        NSDictionary *fadeOut = [NSDictionary dictionaryWithObjectsAndKeys:oldView, NSViewAnimationTargetKey, NSViewAnimationFadeOutEffect, NSViewAnimationEffectKey, nil];
        NSDictionary *fadeIn = [NSDictionary dictionaryWithObjectsAndKeys:[_selectedViewController view], NSViewAnimationTargetKey, NSViewAnimationFadeInEffect, NSViewAnimationEffectKey, nil];
        _animation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObjects:fadeIn, fadeOut, nil]];
        [_animation setAnimationBlockingMode:NSAnimationBlocking];
        [_animation setDuration:HSObjectAssistantAnimationDuration()];
        [_animation setDelegate:self];
        [_animation startAnimation];
        [oldView removeFromSuperview];
    }
    [_selectedViewController setParentViewController:self];
    if (_isVisible) {
        [_selectedViewController viewDidAppear:aAnimate];
    }
    NSEnumerator *enumerator = [[_toolbarMatrix cells] objectEnumerator];
    id cell;
    while ((cell = [enumerator nextObject]) != nil) {
        if ([cell representedObject] == _selectedViewController) {
            [_toolbarMatrix selectCell:cell];
            return;
        }
    }
}

- (id)assistantPaneUndoManager
{
    return [[self modalViewController] assistantPaneUndoManager];
}

- (void)invalidateAnimation
{
    [_animation setDelegate:0];
    [_animation release];
    _animation = nil;
}

- (id)selectedViewController
{
    return _selectedViewController;
}

- (void)openPaneWithIdentifier:(id)aIdentifier
{
    id pvVar1;

    pvVar1 = [_viewControllers objectForKey:aIdentifier];
    if (pvVar1 == nil) {
        pvVar1 = [_viewControllers objectForKey:_defaultPaneIdentifier];
    }
    [self selectViewController:pvVar1 animate:YES];
}

- (id)identifierForSelectedViewController
{
    return [_identifiers objectAtIndex:[_toolbarMatrix selectedColumn]];
}

- (BOOL)isEditingTextAttribute
{
    return (BOOL)[_selectedViewController isEditingTextAttribute];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00213ed3 @ 00213ed3, 308 bytes * /

void FUN_00213ed3(HSObjectAssistantToolbarController *self,SEL _cmd)

{
  id pvVar1;
  HSObjectAssistantToolbarController *local_14;
  undefined *local_10;
  
  if ((self->super).super._layoutIsValid == '\0') {
    pvVar1 = _objc_msgSend(self,sel_selectedViewController);
    pvVar1 = _objc_msgSend(pvVar1,sel_view);
    _objc_msgSend(pvVar1,sel_setAutoresizingMask_,0);
    pvVar1 = _objc_msgSend(self,sel_selectedViewController);
    _objc_msgSend(pvVar1,sel_layout);
    pvVar1 = _objc_msgSend(self,sel_selectedViewController);
    pvVar1 = _objc_msgSend(pvVar1,sel_view);
    _objc_msgSend(pvVar1,sel_setFrameOrigin_,*(undefined4 *)PTR_00336074,
                  *(undefined4 *)(PTR_00336074 + 4));
    pvVar1 = _objc_msgSend(self,sel_selectedViewController);
    pvVar1 = _objc_msgSend(pvVar1,sel_view);
    _objc_msgSend(pvVar1,sel_setAutoresizingMask_,0x12);
    local_14 = self;
    local_10 = PTR_s_HSObjectAssistantPane_00354bc0;
    _objc_msgSendSuper(&local_14,sel_layout);
  }
  return;
}

*/
- (void)layout
{
    if (!_layoutIsValid) {
        [[[self selectedViewController] view] setAutoresizingMask:0];
        [[self selectedViewController] layout];
        [[[self selectedViewController] view] setFrameOrigin:NSZeroPoint];
        [[[self selectedViewController] view] setAutoresizingMask:0x12];
        [super layout];
    }
}

- (BOOL)needToRelayoutAssistant
{
    BOOL BVar1;

    if ([self selectedViewController] == nil) {
        BVar1 = (BOOL)[super needToRelayoutAssistant];
    }
    else {
        BVar1 = (BOOL)[[self selectedViewController] needToRelayoutAssistant];
    }
    return BVar1;
}

- (void)removeDisposablePanes
{

}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002134db @ 002134db, 139 bytes * /

BOOL FUN_002134db(HSObjectAssistantToolbarController *self,SEL _cmd)

{
  BOOL BVar1;
  id pvVar2;
  undefined *puVar3;
  
  puVar3 = sel_topViewController;
  pvVar2 = _objc_msgSend((self->super).super._modalViewController,sel_respondsToSelector_,
                         sel_topViewController);
  if ((char)pvVar2 == '\0') {
    pvVar2 = _objc_msgSend(self->_selectedViewController,sel_assistantShouldBeKeyWindow,puVar3);
    BVar1 = (BOOL)pvVar2;
  }
  else {
    pvVar2 = _objc_msgSend((self->super).super._modalViewController,sel_performSelector_,
                           sel_topViewController);
    pvVar2 = _objc_msgSend(pvVar2,sel_assistantShouldBeKeyWindow);
    BVar1 = (BOOL)pvVar2;
  }
  return BVar1;
}

*/
- (BOOL)assistantShouldBeKeyWindow
{
    if ([_modalViewController respondsToSelector:@selector(topViewController)]) {
        return [[_modalViewController performSelector:@selector(topViewController)] assistantShouldBeKeyWindow];
    }
    return [[(HSObjectAssistantToolbarController *)_modalViewController selectedViewController] assistantShouldBeKeyWindow];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00213472 @ 00213472, 105 bytes * /

id FUN_00213472(HSObjectAssistantToolbarController *self,SEL _cmd)

{
  id pvVar1;
  undefined *puVar2;
  
  puVar2 = sel_windowTitle;
  pvVar1 = _objc_msgSend((self->super).super._modalViewController,sel_respondsToSelector_,
                         sel_windowTitle);
  if (((char)pvVar1 != '\0') &&
     (pvVar1 = _objc_msgSend((self->super).super._modalViewController,sel_windowTitle,puVar2),
     pvVar1 != (id)0x0)) {
    return pvVar1;
  }
  pvVar1 = _objc_msgSend(self->_selectedViewController,sel_windowTitle,puVar2);
  return pvVar1;
}

*/
- (id)windowTitle
{
    id title = nil;
    if ([_modalViewController respondsToSelector:@selector(windowTitle)]) {
        title = [_modalViewController windowTitle];
    }
    if (title == nil) {
        title = [_selectedViewController windowTitle];
    }
    return title;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00213449 @ 00213449, 41 bytes * /

id FUN_00213449(HSObjectAssistantToolbarController *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend((self->super).super._modalViewController,sel_initialKeyView);
  return pvVar1;
}

*/
- (id)initialKeyView
{
    return [_modalViewController initialKeyView];
}

- (void)viewDidDisappear:(BOOL)aDisappear
{
    [super viewDidDisappear:aDisappear];
    [self removeDisposablePanes];
    [_selectedViewController viewDidDisappear:aDisappear];
    _isVisible = NO;
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [super viewWillDisappear:aDisappear];
    [_selectedViewController viewWillDisappear:aDisappear];
}

- (void)viewDidAppear:(BOOL)aAppear
{
    [super viewDidAppear:aAppear];
    [_selectedViewController viewDidAppear:aAppear];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    _isVisible = YES;
    [super viewWillAppear:aAppear];
    if (![self validatePanesAvailability]) {
        [_selectedViewController viewWillAppear:aAppear];
    }
}

- (void)setAssistant:(id)aAssistant
{
    [super setAssistant:aAssistant];
    [[self selectedViewController] setAssistant:aAssistant];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00214291 @ 00214291, 1053 bytes * /

void FUN_00214291(HSObjectAssistantToolbarController *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id self_01;
  id self_02;
  longdouble lVar5;
  double dVar6;
  int local_40;
  undefined1 local_34 [12];
  undefined4 local_28;
  undefined1 local_24 [8];
  float local_1c;
  
  pvVar1 = self->_toolbarMatrix;
  while( true ) {
    pvVar1 = _objc_msgSend(pvVar1,sel_numberOfColumns);
    if ((int)pvVar1 < 1) break;
    _objc_msgSend(self->_toolbarMatrix,sel_removeColumn_,0);
    pvVar1 = self->_toolbarMatrix;
  }
  pvVar2 = _objc_msgSend(cls_NSArray,sel_arrayWithObjects_,*(undefined4 *)PTR_PTR_00336094,
                         *(undefined4 *)PTR_PTR_00336018,*(undefined4 *)PTR_PTR_003360c0,
                         *(undefined4 *)PTR_PTR_00336504,*(undefined4 *)PTR_PTR_00336508,
                         *(undefined4 *)PTR_PTR_0033650c,0);
  pvVar1 = self->_defaultPaneIdentifier;
  pvVar3 = _objc_msgSend(self->_viewControllers,sel_objectForKey_,pvVar1);
  pvVar4 = _objc_msgSend(cls_NSMutableArray,sel_new);
  self->_identifiers = pvVar4;
  local_40 = 0;
  pvVar2 = _objc_msgSend(pvVar2,sel_objectEnumerator);
  while( true ) {
    pvVar4 = _objc_msgSend(pvVar2,sel_nextObject,pvVar1);
    if (pvVar4 == (id)0x0) break;
    pvVar1 = pvVar4;
    self_01 = _objc_msgSend(self->_viewControllers,sel_objectForKey_,pvVar4);
    if (self_01 != (id)0x0) {
      _objc_msgSend(self->_identifiers,sel_addObject_,pvVar4);
      pvVar1 = _objc_msgSend(cls_SMKBackgroundButtonCell,sel_alloc);
      pvVar4 = _objc_msgSend(self_01,sel_icon);
      self_02 = _objc_msgSend(pvVar1,sel_initImageCell_,pvVar4);
      _objc_msgSend(self_02,sel_setButtonType_,6);
      _objc_msgSend(self_02,sel_setBezelStyle_,2);
      _objc_msgSend(self_02,sel_setBordered_,0);
      _objc_msgSend(self_02,sel_setImagePosition_,5);
      _objc_msgSend(self_02,sel_setAlignment_,2);
      self_00 = cls_NSFont;
      dVar6 = _objc_msgSend_fpret(cls_NSFont,sel_smallSystemFontSize);
      pvVar1 = _objc_msgSend(self_00,sel_systemFontOfSize_,(float)dVar6);
      _objc_msgSend(self_02,sel_setFont_,pvVar1);
      pvVar1 = _objc_msgSend(self_01,sel_title);
      _objc_msgSend(self_02,sel_setTitle_,pvVar1);
      _objc_msgSend(self_02,sel_setRepresentedObject_,self_01);
      pvVar4 = self->_toolbarMatrix;
      pvVar1 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,self_02);
      _objc_msgSend(pvVar4,sel_addColumnWithCells_,pvVar1);
      _objc_msgSend(self_02,sel_release);
      local_40 = local_40 + 1;
    }
  }
  pvVar1 = self->_toolbarMatrix;
  _objc_msgSend_stret(local_34,pvVar1,sel_frame);
  _objc_msgSend_stret(local_24,self->_toolbarMatrix,sel_frame);
  lVar5 = (longdouble)_ceilf(local_1c / (float)local_40);
  _objc_msgSend(pvVar1,sel_setCellSize_,(float)lVar5,local_28);
  pvVar1 = _objc_msgSend(self->_toolbarMatrix,sel_cells);
  pvVar2 = _objc_msgSend(cls_HSObjectAssistantsToolbarControlBackgroundRenderer,
                         sel_sharedBackgroundRenderer);
  _objc_msgSend(pvVar1,sel_makeObjectsPerformSelector_withObject_,sel_setBackgroundRenderer_,pvVar2)
  ;
  _objc_msgSend(self,sel_selectViewController_animate_,pvVar3,0);
  return;
}

*/
- (void)viewDidLoad
{
    while ([_toolbarMatrix numberOfColumns] > 0) {
        [_toolbarMatrix removeColumn:0];
    }
    NSArray *paneNames = [NSArray arrayWithObjects:HSAppearanceObjectAssistantRootPaneName, @"HSActionsAssistantPane", @"HSGenericObjectFeaturesAssistantPane", @"HSTextStyleAssistantPane", @"HSGraphicObjectsAssistantPane", HSStartingAssistantRootPaneName, nil];
    id defaultPane = [_viewControllers objectForKey:_defaultPaneIdentifier];
    _identifiers = [NSMutableArray new];
    NSInteger count = 0;
    NSEnumerator *enumerator = [paneNames objectEnumerator];
    id name;
    while ((name = [enumerator nextObject]) != nil) {
        id pane = [_viewControllers objectForKey:name];
        if (pane != nil) {
            [_identifiers addObject:name];
            SMKBackgroundButtonCell *cell = [[SMKBackgroundButtonCell alloc] initImageCell:[pane icon]];
            [cell setButtonType:6];
            [cell setBezelStyle:2];
            [cell setBordered:NO];
            [cell setImagePosition:5];
            [cell setAlignment:2];
            [cell setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
            [cell setTitle:[pane title]];
            [cell setRepresentedObject:pane];
            [_toolbarMatrix addColumnWithCells:[NSArray arrayWithObject:cell]];
            [cell release];
            count++;
        }
    }
    NSRect frame = [_toolbarMatrix frame];
    [_toolbarMatrix setCellSize:NSMakeSize(ceilf(frame.size.width / (float)count), frame.size.height)];
    [[_toolbarMatrix cells] makeObjectsPerformSelector:@selector(setBackgroundRenderer:) withObject:[HSObjectAssistantsToolbarControlBackgroundRenderer sharedBackgroundRenderer]];
    [self selectViewController:defaultPane animate:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00213327 @ 00213327, 290 bytes * /

BOOL FUN_00213327(HSObjectAssistantToolbarController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  id pvVar3;
  int iVar4;
  id pvVar5;
  
  pvVar1 = _objc_msgSend(self,sel_selectedViewController);
  pvVar1 = _objc_msgSend(pvVar1,sel_isEnabled);
  pvVar2 = _objc_msgSend(self->_toolbarMatrix,sel_cells);
  pvVar2 = _objc_msgSend(pvVar2,sel_objectEnumerator);
  while (pvVar5 = _objc_msgSend(pvVar2,sel_nextObject), pvVar5 != (id)0x0) {
    self_00 = _objc_msgSend(pvVar5,sel_representedObject);
    pvVar3 = _objc_msgSend(self_00,sel_isEnabled);
    iVar4 = (int)(char)pvVar3;
    _objc_msgSend(pvVar5,sel_setEnabled_,iVar4);
    if (((char)pvVar1 == '\0') &&
       (pvVar5 = _objc_msgSend(self_00,sel_isEnabled,iVar4), (char)pvVar5 != '\0')) {
      _objc_msgSend(self,sel_selectViewController_animate_,self_00,1);
    }
  }
  return (char)pvVar1 == '\0';
}

*/
- (BOOL)validatePanesAvailability
{
    BOOL selectedEnabled = [[self selectedViewController] isEnabled];
    NSEnumerator *enumerator = [[_toolbarMatrix cells] objectEnumerator];
    id cell;
    while ((cell = [enumerator nextObject]) != nil) {
        id pane = [cell representedObject];
        [cell setEnabled:[pane isEnabled]];
        if (!selectedEnabled && [pane isEnabled]) {
            [self selectViewController:pane animate:YES];
        }
    }
    return !selectedEnabled;
}

- (void)setObject:(id)aObject
{
    id pvVar1;

    pvVar1 = [self object];
    if (pvVar1 != aObject) {
        [super setObject:aObject];
        pvVar1 = [_viewControllers allValues];
        [pvVar1 makeObjectsPerformSelector:@selector(setObject:) withObject:[self object]];
    }
}

- (void)dealloc
{
    [[_viewControllers allValues] makeObjectsPerformSelector:@selector(setObjectAssistantPaneDelegate:) withObject:nil];
    [_viewControllers release];
    [_identifiers release];
    [_selectedViewController release];
    [_defaultPaneIdentifier release];
    [_animation setDelegate:0];
    [_animation release];
    [super dealloc];
}

- (id)initWithViewControllers:(id)aControllers withDefaultPaneIdentifier:(id)aIdentifier
{
    id pvVar2_2;

    self = [super initWithNibName:@"InspectorToolbarController"];
    if (self != nil) {
        _defaultPaneIdentifier = [aIdentifier retain];
        pvVar2_2 = [aControllers retain];
        _viewControllers = pvVar2_2;
        [[pvVar2_2 allValues] makeObjectsPerformSelector:@selector(setObjectAssistantPaneDelegate:) withObject:self];
    }
    return self;
}

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end

