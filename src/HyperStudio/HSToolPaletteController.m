#import "HSToolPaletteController.h"

@implementation HSToolPaletteController

/* i386 ivar offsets: _playerEditorButtonsView=0x10, _contentView=0x14, _closeButton=0x18, _buttonsView=0x1c, _arrowButton=0x20, _collapseExpandDrawerButton=0x24, _flatLiveSlider=0x28, _flatToolButtonsView=0x2c, _liveToolButtonsView=0x30, _currentToolButtonsView=0x34, _toolSettingsViewContainers=0x38, _activeToolSettingsViewController=0x3c, _lastClickDidChangeTool=0x40, _drawerPrefersToBeOpen=0x41 */

- (void)assignDoubleActions
{
    NSEnumerator *pvVar2;
    id pvVar1_2;
    id pvVar1_4;
    NSEnumerator *pvVar2_2;

    pvVar2 = [[_flatToolButtonsView subviews] objectEnumerator];
    pvVar1_2 = [pvVar2 nextObject];
    while (pvVar1_2 != nil) {
        if ([pvVar1_2 respondsToSelector:@selector(setDoubleAction:)]) {
            [pvVar1_2 setDoubleAction:@selector(switchToolAndShowDrawer:)];
        }
        if ([pvVar1_2 respondsToSelector:@selector(setDoubleAction:forModifier:)]) {
            [pvVar1_2 setDoubleAction:@selector(switchToolAndSelectAllArea:) forModifier:0x40000]
            ;
        }
        pvVar1_2 = [pvVar2 nextObject];
    }
    pvVar2_2 = [[_liveToolButtonsView subviews] objectEnumerator];
    pvVar1_4 = [pvVar2_2 nextObject];
    while (pvVar1_4 != nil) {
        if ([pvVar1_4 respondsToSelector:@selector(setDoubleAction:)]) {
            [pvVar1_4 setDoubleAction:@selector(switchToolAndShowDrawer:)];
        }
        if ([pvVar1_4 respondsToSelector:@selector(setDoubleAction:forModifier:)]) {
            [pvVar1_4 setDoubleAction:@selector(switchToolAndSelectAllArea:) forModifier:0x40000]
            ;
        }
        pvVar1_4 = [pvVar2_2 nextObject];
    }
    if ([_arrowButton respondsToSelector:@selector(setDoubleAction:)]) {
        [_arrowButton setDoubleAction:@selector(activateSelectedObject:)];
    }
}

- (id)activeToolSettingsViewController
{
    return _activeToolSettingsViewController;
}

- (void)closeDrawer:(id)aDrawer
{
    _drawerPrefersToBeOpen = NO;
    [_contentView hideDrawer:aDrawer];
    [self validateShowHideDrawerButton];
}

- (void)openDrawer:(id)aDrawer
{
    _drawerPrefersToBeOpen = YES;
    [_contentView showDrawer:aDrawer];
    [self validateShowHideDrawerButton];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000d60ef @ 000d60ef, 479 bytes * /

void FUN_000d60ef(HSToolPaletteController *self,SEL _cmd,id switchToolTypes)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  cfstringStruct *pcVar4;
  id *ppvVar5;
  undefined4 uVar6;
  cfstringStruct *pcVar7;
  cfstringStruct *pcVar8;
  
  pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  if (pvVar1 != (id)0x0) {
    pvVar1 = self->_flatLiveSlider;
    pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    pvVar3 = _objc_msgSend(switchToolTypes,sel_state);
    pcVar8 = &cfstr_Tools;
    pcVar7 = &cfstr_empty;
    pcVar4 = &cfstr_Slider_LiveMode_ToolTip;
    if (pvVar3 == (id)0x0) {
      pcVar4 = &cfstr_Slider_FlatMode_ToolTip;
    }
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,pcVar4,&cfstr_empty,
                           &cfstr_Tools);
    _objc_msgSend(pvVar1,sel_setToolTip_,pvVar2);
    pvVar1 = _objc_msgSend(switchToolTypes,sel_state);
    if (pvVar1 == (id)0x0) {
      ppvVar5 = &self->_flatToolButtonsView;
    }
    else {
      ppvVar5 = &self->_liveToolButtonsView;
    }
    _objc_msgSend(self,sel_mountToolButtonsView_,*ppvVar5,pcVar7,pcVar8);
    pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
    pvVar2 = _objc_msgSend(switchToolTypes,sel_state);
    _objc_msgSend(pvVar1,sel_setCurrentToolSet_,(uint)(pvVar2 != (id)0x0));
    _objc_msgSend(self,sel_validateUserInterface);
    pvVar1 = _objc_msgSend(switchToolTypes,sel_cell);
    pvVar1 = _objc_msgSend(pvVar1,sel_representedObject);
    uVar6 = _NSSelectorFromString(pvVar1);
    pvVar1 = _objc_msgSend(*(id *)PTR_00336058,sel_targetForAction_to_from_,uVar6,0,switchToolTypes)
    ;
    _objc_msgSend(pvVar1,sel_performSelector_withObject_,uVar6,switchToolTypes);
  }
  return;
}

*/
- (void)switchToolTypes:(id)aTypes
{
    if ([HSToolManager sharedToolManager] == nil) {
        return;
    }
    NSString *toolTipKey = ([aTypes state] == NSOffState) ? @"Slider_FlatMode_ToolTip" : @"Slider_LiveMode_ToolTip";
    [_flatLiveSlider setToolTip:[[NSBundle mainBundle] localizedStringForKey:toolTipKey value:@"" table:@"Tools"]];
    [self mountToolButtonsView:([aTypes state] == NSOffState) ? _flatToolButtonsView : _liveToolButtonsView];
    [(HSToolManager *)[HSToolManager sharedToolManager] setCurrentToolSet:[aTypes state] != NSOffState];
    [self validateUserInterface];
    SEL action = NSSelectorFromString([[aTypes cell] representedObject]);
    [[NSApp targetForAction:action to:nil from:aTypes] performSelector:action withObject:aTypes];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000d5d22 @ 000d5d22, 108 bytes * /

void FUN_000d5d22(HSToolPaletteController *self,SEL _cmd,id switchToolAndSelectAllArea)

{
  id self_00;
  id pvVar1;
  
  pvVar1 = switchToolAndSelectAllArea;
  self_00 = _objc_msgSend(*(id *)PTR_00336058,sel_targetForAction_to_from_,sel_selectAllArea_,0,
                          switchToolAndSelectAllArea);
  if (self_00 != (id)0x0) {
    _objc_msgSend(self_00,sel_performSelector_withObject_,sel_selectAllArea_,
                  switchToolAndSelectAllArea,pvVar1);
  }
  return;
}

*/
- (void)switchToolAndSelectAllArea:(id)aArea
{
    id target = [NSApp targetForAction:@selector(selectAllArea:) to:nil from:aArea];
    if (target != nil) {
        [target performSelector:@selector(selectAllArea:) withObject:aArea];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000d5c4f @ 000d5c4f, 211 bytes * /

void FUN_000d5c4f(HSToolPaletteController *self,SEL _cmd,id switchToolAndShowDrawer)

{
  id pvVar1;
  HSToolsPaletteContentView *self_00;
  SEL pcVar2;
  undefined *puVar3;
  
  if (self->_activeToolSettingsViewController == (HSToolSettingsViewController *)0x0) {
    self = _objc_msgSend(*(id *)PTR_00336058,sel_targetForAction_to_from_,sel_selectAllArea_,0,
                         switchToolAndShowDrawer);
    pcVar2 = sel_performSelector_withObject_;
    puVar3 = sel_selectAllArea_;
    if (self == (HSToolPaletteController *)0x0) {
      return;
    }
  }
  else {
    if ((self->_lastClickDidChangeTool == '\0') &&
       (pvVar1 = _objc_msgSend(self->_contentView,sel_drawerIsOpen), (char)pvVar1 != '\0')) {
      self->_drawerPrefersToBeOpen = '\0';
      self_00 = self->_contentView;
      pcVar2 = sel_hideDrawer_;
    }
    else {
      self->_drawerPrefersToBeOpen = '\x01';
      self_00 = self->_contentView;
      pcVar2 = sel_showDrawer_;
    }
    puVar3 = (undefined *)0x0;
    _objc_msgSend(self_00,pcVar2,0);
    pcVar2 = sel_validateShowHideDrawerButton;
  }
  _objc_msgSend(self,pcVar2,puVar3);
  return;
}

*/
- (void)switchToolAndShowDrawer:(id)aDrawer
{
    if (_activeToolSettingsViewController == nil) {
        id target = [NSApp targetForAction:@selector(selectAllArea:) to:nil from:aDrawer];
        if (target != nil) {
            [target performSelector:@selector(selectAllArea:) withObject:aDrawer];
        }
        return;
    }
    if (!_lastClickDidChangeTool && [_contentView drawerIsOpen]) {
        _drawerPrefersToBeOpen = NO;
        [_contentView hideDrawer:nil];
    }
    else {
        _drawerPrefersToBeOpen = YES;
        [_contentView showDrawer:nil];
    }
    [self validateShowHideDrawerButton];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000d62ce @ 000d62ce, 187 bytes * /

void FUN_000d62ce(HSToolPaletteController *self,SEL _cmd,id switchTool)

{
  id pvVar1;
  undefined4 uVar2;
  
  self->_lastClickDidChangeTool = '\0';
  pvVar1 = _objc_msgSend(switchTool,sel_cell);
  pvVar1 = _objc_msgSend(pvVar1,sel_representedObject);
  if (pvVar1 != (id)0x0) {
    pvVar1 = _objc_msgSend(switchTool,sel_cell);
    pvVar1 = _objc_msgSend(pvVar1,sel_representedObject);
    uVar2 = _NSSelectorFromString(pvVar1);
    pvVar1 = _objc_msgSend(*(id *)PTR_00336058,sel_targetForAction_to_from_,uVar2,0,switchTool);
    _objc_msgSend(pvVar1,sel_performSelector_withObject_,uVar2,switchTool);
  }
  return;
}

*/
- (void)switchTool:(id)aTool
{
    _lastClickDidChangeTool = NO;
    if ([[aTool cell] representedObject] == nil) {
        return;
    }
    SEL action = NSSelectorFromString([[aTool cell] representedObject]);
    [[NSApp targetForAction:action to:nil from:aTool] performSelector:action withObject:aTool];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000d6389 @ 000d6389, 291 bytes * /

void FUN_000d6389(HSToolPaletteController *self,SEL _cmd,id validatePaletteItem)

{
  id pvVar1;
  undefined4 uVar2;
  id pvVar3;
  
  pvVar1 = _objc_msgSend(validatePaletteItem,sel_cell);
  pvVar1 = _objc_msgSend(pvVar1,sel_representedObject);
  if (pvVar1 != (id)0x0) {
    pvVar1 = _objc_msgSend(validatePaletteItem,sel_cell);
    pvVar1 = _objc_msgSend(pvVar1,sel_representedObject);
    uVar2 = _NSSelectorFromString(pvVar1);
    pvVar1 = _objc_msgSend(self,sel_findValidatorForAction_target_from_,uVar2,0,validatePaletteItem)
    ;
    pvVar3 = _objc_msgSend(validatePaletteItem,sel_action);
    _objc_msgSend(validatePaletteItem,sel_setAction_,uVar2);
    pvVar1 = _objc_msgSend(pvVar1,sel_validateUserInterfaceItem_,validatePaletteItem);
    _objc_msgSend(validatePaletteItem,sel_setEnabled_,(int)(char)pvVar1);
    _objc_msgSend(validatePaletteItem,sel_setAction_,pvVar3);
  }
  return;
}

*/
- (void)validatePaletteItem:(id)aItem
{
    if ([[aItem cell] representedObject] == nil) {
        return;
    }
    SEL action = NSSelectorFromString([[aItem cell] representedObject]);
    id validator = [self findValidatorForAction:action target:nil from:aItem];
    SEL savedAction = [(NSControl *)aItem action];
    [aItem setAction:action];
    [aItem setEnabled:[validator validateUserInterfaceItem:aItem]];
    [aItem setAction:savedAction];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000d64ac @ 000d64ac, 118 bytes * /

void FUN_000d64ac(HSToolPaletteController *self,SEL _cmd,float changeDrawerHeightTo)

{
  HSToolsPaletteContentView *self_00;
  id self_01;
  undefined1 local_1c [12];
  float local_10;
  
  self_00 = self->_contentView;
  self_01 = _objc_msgSend(self->_activeToolSettingsViewController,sel_toolSettingsView);
  _objc_msgSend_stret(local_1c,self_01,sel_frame);
  _objc_msgSend(self_00,sel_resizeDrawerBy_withAutoresizingMask_,local_10 - changeDrawerHeightTo,
                0x12);
  return;
}

*/
- (void)changeDrawerHeightTo:(CGFloat)aTo
{
    NSRect frame = [[_activeToolSettingsViewController toolSettingsView] frame];
    [_contentView resizeDrawerBy:frame.size.height - aTo withAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
}

- (void)activeToolDidChange:(id)aChange
{
    [self validateUserInterface];
}

- (void)activeToolWillChange:(id)aChange
{
    [self unmountActiveToolSettingsViewController];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000d5a0e @ 000d5a0e, 501 bytes * /

void FUN_000d5a0e(HSToolPaletteController *self,SEL _cmd)

{
  cfstringStruct *self_00;
  id pvVar1;
  id pvVar2;
  cfstringStruct *pcVar3;
  id pvVar4;
  id *ppvVar5;
  HSToolPaletteController *pHVar6;
  cfstringStruct *pcVar7;
  cfstringStruct *pcVar8;
  
  self_00 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar4 = self->_flatLiveSlider;
  pvVar1 = _objc_msgSend(self_00,sel_currentToolSet);
  _objc_msgSend(pvVar4,sel_setState_animate_,(uint)(pvVar1 != (id)0x0),0);
  pvVar4 = self->_flatLiveSlider;
  pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar2 = _objc_msgSend(self_00,sel_currentToolSet);
  pcVar8 = &cfstr_ToolPalette;
  pcVar7 = &cfstr_empty;
  pcVar3 = &cfstr_Slider_LiveMode_ToolTip;
  if (pvVar2 == (id)0x0) {
    pcVar3 = &cfstr_Slider_FlatMode_ToolTip;
  }
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,pcVar3,&cfstr_empty,
                         &cfstr_ToolPalette);
  _objc_msgSend(pvVar4,sel_setToolTip_,pvVar1);
  pvVar4 = _objc_msgSend(self_00,sel_currentToolSet);
  if (pvVar4 == (id)0x0) {
    ppvVar5 = &self->_flatToolButtonsView;
  }
  else {
    ppvVar5 = &self->_liveToolButtonsView;
  }
  pvVar4 = *ppvVar5;
  _objc_msgSend(self,sel_mountToolButtonsView_,pvVar4,pcVar7,pcVar8);
  if (self_00 != (cfstringStruct *)0x0) {
    pvVar4 = _objc_msgSend(self_00,sel_selectedToolTag,pvVar4,pcVar7,pcVar8);
    pHVar6 = _objc_msgSend(self,sel_toolSettingsViewControllerForToolTag_,pvVar4);
    if (pHVar6 != (HSToolPaletteController *)0x0) {
      _objc_msgSend(self,sel_mountToolSettingsViewController_withToolManager_,pHVar6,self_00);
      if (self->_drawerPrefersToBeOpen != '\0') {
        pHVar6 = self;
        _objc_msgSend(self->_contentView,sel_showDrawer_,self,self_00);
      }
      goto LAB_000d5be6;
    }
  }
  self_00 = pcVar7;
  _objc_msgSend(self,sel_unmountActiveToolSettingsViewController,pvVar4);
  pHVar6 = self;
  _objc_msgSend(self->_contentView,sel_hideDrawer_,self);
  self->_drawerPrefersToBeOpen = '\0';
LAB_000d5be6:
  _objc_msgSend(self,sel_validateShowHideDrawerButton,pHVar6,self_00);
  return;
}

*/
- (void)validateToolPalette
{
    HSToolManager *toolManager = [HSToolManager sharedToolManager];
    [_flatLiveSlider setState:[toolManager currentToolSet] != 0 animate:NO];
    NSString *toolTipKey = ([toolManager currentToolSet] == 0) ? @"Slider_FlatMode_ToolTip" : @"Slider_LiveMode_ToolTip";
    [_flatLiveSlider setToolTip:[[NSBundle mainBundle] localizedStringForKey:toolTipKey value:@"" table:@"ToolPalette"]];
    [self mountToolButtonsView:([toolManager currentToolSet] == 0) ? _flatToolButtonsView : _liveToolButtonsView];
    if (toolManager != nil) {
        id controller = [self toolSettingsViewControllerForToolTag:[toolManager selectedToolTag]];
        if (controller != nil) {
            [self mountToolSettingsViewController:controller withToolManager:toolManager];
            if (_drawerPrefersToBeOpen) {
                [_contentView showDrawer:self];
            }
            [self validateShowHideDrawerButton];
            return;
        }
    }
    [self unmountActiveToolSettingsViewController];
    [_contentView hideDrawer:self];
    _drawerPrefersToBeOpen = NO;
    [self validateShowHideDrawerButton];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000d58fb @ 000d58fb, 275 bytes * /

void FUN_000d58fb(HSToolPaletteController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  undefined *puVar3;
  
  _objc_msgSend(self->_collapseExpandDrawerButton,sel_setTarget_,self);
  pvVar1 = _objc_msgSend(self->_contentView,sel_drawerIsOpen);
  pvVar2 = self->_collapseExpandDrawerButton;
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(cls_NSImage,sel_imageNamed_,&cfstr_WhiteArrowDown);
    _objc_msgSend(pvVar2,sel_setImage_,pvVar1);
    pvVar2 = self->_collapseExpandDrawerButton;
    puVar3 = sel_openDrawer_;
  }
  else {
    pvVar1 = _objc_msgSend(cls_NSImage,sel_imageNamed_,&cfstr_WhiteArrowUp);
    _objc_msgSend(pvVar2,sel_setImage_,pvVar1);
    pvVar2 = self->_collapseExpandDrawerButton;
    puVar3 = sel_closeDrawer_;
  }
  _objc_msgSend(pvVar2,sel_setAction_,puVar3);
  _objc_msgSend(self->_collapseExpandDrawerButton,sel_setEnabled_,
                (uint)(self->_activeToolSettingsViewController !=
                      (HSToolSettingsViewController *)0x0));
  return;
}

*/
- (void)validateShowHideDrawerButton
{
    [_collapseExpandDrawerButton setTarget:self];
    if (![_contentView drawerIsOpen]) {
        [_collapseExpandDrawerButton setImage:[NSImage imageNamed:@"WhiteArrowDown"]];
        [_collapseExpandDrawerButton setAction:@selector(openDrawer:)];
    }
    else {
        [_collapseExpandDrawerButton setImage:[NSImage imageNamed:@"WhiteArrowUp"]];
        [_collapseExpandDrawerButton setAction:@selector(closeDrawer:)];
    }
    [_collapseExpandDrawerButton setEnabled:_activeToolSettingsViewController != nil];
}

- (void)mountToolSettingsViewController:(id)aController withToolManager:(id)aManager
{
    HSToolSettingsViewController *self_00;
    id pvVar1;

    if (_activeToolSettingsViewController != aController) {
        [_activeToolSettingsViewController release];
        self_00 = [aController retain];
        _activeToolSettingsViewController = self_00;
        [self_00 setParent:self];
        pvVar1 = [_activeToolSettingsViewController toolSettingsView];
        [_activeToolSettingsViewController willMount];
        [_contentView setDrawerContentView:pvVar1];
        [_activeToolSettingsViewController didMount];
        _lastClickDidChangeTool = YES;
    }
}

- (void)unmountActiveToolSettingsViewController
{
    [_activeToolSettingsViewController willUnMount];
    [_activeToolSettingsViewController setParent:nil];
    [_activeToolSettingsViewController release];
    _activeToolSettingsViewController = nil;
}

- (id)toolSettingsViewControllerForToolTag:(NSInteger)aTag
{
    return [[self toolSettingsViewContainerToToolIdentifierMap] objectForKey:[HSToolManager toolIdentifierForTag:aTag]];
}

- (id)toolSettingsViewContainerToToolIdentifierMap
{
    id pvVar1;
    id pvVar2;
    id pvVar4;
    id pvVar6;
    id pvVar8;
    id pvVar10;
    id pvVar12;
    id pvVar14;
    id pvVar16;
    id pvVar18;
    id pvVar20;
    id pvVar22;
    id pvVar24;
    id pvVar26;
    id pvVar28;
    id pvVar30;
    id pvVar32;
    id pvVar34;
    id pvVar36;
    id pvVar38;
    id pvVar40;
    id pvVar42;
    id pvVar1_2;
    id pvVar3_3;
    id pvVar5_3;
    id pvVar7_3;
    id pvVar9_3;
    id pvVar11_3;
    id pvVar13_3;
    id pvVar15_3;
    id pvVar17_3;
    id pvVar19_3;
    id pvVar21_3;
    id pvVar23_3;
    id pvVar25_3;
    id pvVar27_3;
    id pvVar29_3;
    id pvVar31_3;
    id pvVar33_3;
    id pvVar35_3;
    id pvVar37_3;
    id pvVar39_3;
    id pvVar41_3;

    pvVar1 = _toolSettingsViewContainers;
    if (pvVar1 == nil) {
        pvVar1_2 = [NSDictionary alloc];
        pvVar2 = [HSToolManager toolIdentifierForTag:0x10];
        pvVar3_3 = [[[HSLassoSettingsViewController alloc] init] autorelease];
        pvVar4 = [HSToolManager toolIdentifierForTag:0x16];
        pvVar5_3 = [[[HSMagnifyingToolSettingsViewController alloc] init] autorelease];
        pvVar6 = [HSToolManager toolIdentifierForTag:0x2a];
        pvVar7_3 = [[[HSPencilToolSettingsViewController alloc] init] autorelease];
        pvVar8 = [HSToolManager toolIdentifierForTag:8];
        pvVar9_3 = [[[HSPencilToolSettingsViewController alloc] init] autorelease];
        pvVar10 = [HSToolManager toolIdentifierForTag:0x2e];
        pvVar11_3 = [[[HSDrawRoundedRectToolSettingsViewController alloc] init] autorelease];
        pvVar12 = [HSToolManager toolIdentifierForTag:0x2d];
        pvVar13_3 = [[[HSDrawCircleToolSettingsViewController alloc] init] autorelease];
        pvVar14 = [HSToolManager toolIdentifierForTag:0x2c];
        pvVar15_3 = [[[HSDrawRectToolSettingsViewController alloc] init] autorelease];
        pvVar16 = [HSToolManager toolIdentifierForTag:0xd];
        pvVar17_3 = [[[HSDrawRoundedRectToolSettingsViewController alloc] init] autorelease];
        pvVar18 = [HSToolManager toolIdentifierForTag:0xc];
        pvVar19_3 = [[[HSDrawCircleToolSettingsViewController alloc] init] autorelease];
        pvVar20 = [HSToolManager toolIdentifierForTag:0xb];
        pvVar21_3 = [[[HSDrawRectToolSettingsViewController alloc] init] autorelease];
        pvVar22 = [HSToolManager toolIdentifierForTag:0x29];
        pvVar23_3 = [[[HSBrushToolSettingsViewController alloc] init] autorelease];
        pvVar24 = [HSToolManager toolIdentifierForTag:0x13];
        pvVar25_3 = [[[HSBrushToolSettingsViewController alloc] init] autorelease];
        pvVar26 = [HSToolManager toolIdentifierForTag:0x25];
        pvVar27_3 = [[[HSEffectToolSettingsViewController alloc] init] autorelease];
        pvVar28 = [HSToolManager toolIdentifierForTag:0x26];
        pvVar29_3 = [[[HSEffectToolSettingsViewController alloc] init] autorelease];
        pvVar30 = [HSToolManager toolIdentifierForTag:0x12];
        pvVar31_3 = [[[HSPaintBucketSettingsViewController alloc] init] autorelease];
        pvVar32 = [HSToolManager toolIdentifierForTag:2];
        pvVar33_3 = [[[HSTextToolSettingsViewController alloc] init] autorelease];
        pvVar34 = [HSToolManager toolIdentifierForTag:0x14];
        pvVar35_3 = [[[HSEraserToolSettingsViewController alloc] init] autorelease];
        pvVar36 = [HSToolManager toolIdentifierForTag:0x2b];
        pvVar37_3 = [[[HSLineToolSettingsViewController alloc] init] autorelease];
        pvVar38 = [HSToolManager toolIdentifierForTag:10];
        pvVar39_3 = [[[HSLineToolSettingsViewController alloc] init] autorelease];
        pvVar40 = [HSToolManager toolIdentifierForTag:0x27];
        pvVar41_3 = [[[HSBrushToolSettingsViewController alloc] init] autorelease];
        pvVar42 = [HSToolManager toolIdentifierForTag:7];
        pvVar1 = [pvVar1_2 initWithObjectsAndKeys:[[[HSBrushToolSettingsViewController alloc] init] autorelease], pvVar42, pvVar41_3, pvVar40, pvVar39_3, pvVar38, pvVar37_3, pvVar36, pvVar35_3, pvVar34, pvVar33_3, pvVar32, pvVar31_3, pvVar30, pvVar29_3, pvVar28, pvVar27_3, pvVar26, pvVar25_3, pvVar24, pvVar23_3, pvVar22, pvVar21_3, pvVar20, pvVar19_3, pvVar18, pvVar17_3, pvVar16, pvVar15_3, pvVar14, pvVar13_3, pvVar12, pvVar11_3, pvVar10, pvVar9_3, pvVar8, pvVar7_3, pvVar6, pvVar5_3, pvVar4, pvVar3_3, pvVar2, nil];
        _toolSettingsViewContainers = pvVar1;
    }
    return pvVar1;
}

- (void)didLoadNib
{
    [super didLoadNib];
    [self assignDoubleActions];
    [[_flatLiveSlider cell] setRepresentedObject:(NSStringFromSelector(@selector(toolPaletteSwitchToolTypes:)))];
    [_flatLiveSlider setToolTip:[[NSBundle mainBundle] localizedStringForKey:@"Slider FlatMode ToolTip" value:@"" table:@"Tools"]];
    [self mountToolButtonsView:_flatToolButtonsView];
    [[HSToolManager sharedToolManager] setCurrentToolSet:0];
    [self validateUserInterface];
    [self validateShowHideDrawerButton];
    [_buttonsView setImage:[NSImage imageNamed:@"Tools_Background"]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activeToolDidChange:) name:@"HSActiveToolDidSelectionNotification" object:0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activeToolWillChange:) name:@"HSActiveToolWillChangeNotification" object:0];
}

- (void)mountToolButtonsView:(id)aView
{
    id pvVar1_2;

    if (_currentToolButtonsView != aView) {
        [_currentToolButtonsView removeFromSuperview];
        [[_currentToolButtonsView subviews] makeObjectsPerformSelector:@selector(setState:) withObject:nil];
        [_currentToolButtonsView release];
        pvVar1_2 = [aView retain];
        _currentToolButtonsView = pvVar1_2;
        [_buttonsView addSubview:pvVar1_2];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000d6764 @ 000d6764, 1168 bytes * /

id FUN_000d6764(HSToolPaletteController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  undefined1 local_54 [16];
  undefined1 local_44 [16];
  float local_34;
  float local_30;
  float local_2c;
  float local_28;
  float local_24;
  float fStack_20;
  float local_1c;
  float fStack_18;
  
  pvVar1 = *(id *)(self->super_HSValidatedUserInterfacePaletteController + 4);
  if (pvVar1 == (id)0x0) {
    _objc_msgSend(self,sel_loadNibIfNeeded);
    pvVar1 = _objc_msgSend(cls_HSToolPaletteWindow,sel_alloc);
    _objc_msgSend_stret(local_54,self->_contentView,sel_frame);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithContentRect_styleMask_backing_defer_,
                           (int)local_54._0_8_,SUB84(local_54._0_8_,4),(int)local_54._8_8_,
                           SUB84(local_54._8_8_,4),0,2,1);
    *(id *)(self->super_HSValidatedUserInterfacePaletteController + 4) = pvVar1;
    _objc_msgSend(pvVar1,sel_setDelegate_,self);
    pvVar1 = *(id *)(self->super_HSValidatedUserInterfacePaletteController + 4);
    pvVar2 = _objc_msgSend(self,sel_class);
    pvVar2 = _objc_msgSend(pvVar2,sel_frameAutosaveName);
    _objc_msgSend(pvVar1,sel_setFrameAutosaveName_,pvVar2);
    pvVar1 = _objc_msgSend(cls_NSView,sel_alloc);
    _objc_msgSend_stret(local_44,self->_contentView,sel_frame);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithFrame_,(int)local_44._0_8_,SUB84(local_44._0_8_,4),
                           (int)local_44._8_8_,SUB84(local_44._8_8_,4));
    pvVar2 = _objc_msgSend(cls_HSOpaqueView,sel_alloc);
    _objc_msgSend_stret(&local_34,pvVar1,sel_frame);
    fStack_20 = local_30 + 3.0;
    local_24 = local_34 + 3.0;
    local_1c = 0.0;
    if (0.0 <= local_2c + -6.0) {
      local_1c = local_2c + -6.0;
    }
    fStack_18 = 0.0;
    if (0.0 <= local_28 + -6.0) {
      fStack_18 = local_28 + -6.0;
    }
    pvVar2 = _objc_msgSend(pvVar2,sel_initWithFrame_,local_24,fStack_20,local_1c,fStack_18);
    _objc_msgSend(pvVar1,sel_addSubview_,pvVar2);
    _objc_msgSend(pvVar2,sel_setAutoresizingMask_,0x12);
    _objc_msgSend(pvVar2,sel_release);
    _objc_msgSend(pvVar1,sel_addSubview_,self->_contentView);
    _objc_msgSend(self->_contentView,sel_setAutoresizingMask_,0x12);
    _objc_msgSend(*(id *)(self->super_HSValidatedUserInterfacePaletteController + 4),
                  sel_setContentView_,pvVar1);
    _objc_msgSend(pvVar1,sel_release);
    _objc_msgSend(*(id *)(self->super_HSValidatedUserInterfacePaletteController + 4),
                  sel_setFloatingPanel_,1);
    _objc_msgSend(*(id *)(self->super_HSValidatedUserInterfacePaletteController + 4),sel_setOpaque_,
                  0);
    _objc_msgSend(*(id *)(self->super_HSValidatedUserInterfacePaletteController + 4),
                  sel_setIgnoresMouseEvents_,0);
    _objc_msgSend(*(id *)(self->super_HSValidatedUserInterfacePaletteController + 4),
                  sel_setBecomesKeyOnlyIfNeeded_,1);
    _objc_msgSend(*(id *)(self->super_HSValidatedUserInterfacePaletteController + 4),
                  sel_setReleasedWhenClosed_,0);
    _objc_msgSend(*(id *)(self->super_HSValidatedUserInterfacePaletteController + 4),
                  sel_setHasShadow_,1);
    pvVar1 = *(id *)(self->super_HSValidatedUserInterfacePaletteController + 4);
    pvVar2 = _objc_msgSend(cls_NSColor,sel_clearColor);
    _objc_msgSend(pvVar1,sel_setBackgroundColor_,pvVar2);
    _objc_msgSend(*(id *)(self->super_HSValidatedUserInterfacePaletteController + 4),
                  sel_setMovableByWindowBackground_,1);
    _objc_msgSend(self->_closeButton,sel_setTarget_,
                  *(undefined4 *)(self->super_HSValidatedUserInterfacePaletteController + 4));
    _objc_msgSend(self->_closeButton,sel_setAction_,sel_performClose_);
    _objc_msgSend(self->_flatLiveSlider,sel_setAction_,sel_switchToolTypes_);
    _objc_msgSend(self->_flatLiveSlider,sel_setTarget_,self);
    _objc_msgSend(self->_collapseExpandDrawerButton,sel_setTarget_,self->_contentView);
    pvVar1 = *(id *)(self->super_HSValidatedUserInterfacePaletteController + 4);
  }
  return pvVar1;
}

*/
- (id)window
{
    if (_window == nil) {
        [self loadNibIfNeeded];
        _window = [[HSToolPaletteWindow alloc] initWithContentRect:[_contentView frame] styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES];
        [_window setDelegate:self];
        [_window setFrameAutosaveName:[[self class] frameAutosaveName]];
        NSView *rootView = [[NSView alloc] initWithFrame:[_contentView frame]];
        NSRect frame = [rootView frame];
        NSRect opaqueFrame = NSMakeRect(frame.origin.x + 3.0, frame.origin.y + 3.0, MAX(frame.size.width - 6.0, 0.0), MAX(frame.size.height - 6.0, 0.0));
        HSOpaqueView *opaqueView = [[HSOpaqueView alloc] initWithFrame:opaqueFrame];
        [rootView addSubview:opaqueView];
        [opaqueView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [opaqueView release];
        [rootView addSubview:_contentView];
        [_contentView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [_window setContentView:rootView];
        [rootView release];
        [_window setFloatingPanel:YES];
        [_window setOpaque:NO];
        [_window setIgnoresMouseEvents:NO];
        [_window setBecomesKeyOnlyIfNeeded:YES];
        [_window setReleasedWhenClosed:NO];
        [_window setHasShadow:YES];
        [_window setBackgroundColor:[NSColor clearColor]];
        [_window setMovableByWindowBackground:YES];
        [_closeButton setTarget:_window];
        [_closeButton setAction:@selector(performClose:)];
        [_flatLiveSlider setAction:@selector(switchToolTypes:)];
        [_flatLiveSlider setTarget:self];
        [_collapseExpandDrawerButton setTarget:_contentView];
    }
    return _window;
}

- (void)validateUserInterfaceWithView:(id)aView
{
    [[HSToolManager sharedToolManager] setToolView:aView];
    [self validateUserInterface];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000d6bf4 @ 000d6bf4, 320 bytes * /

void FUN_000d6bf4(HSToolPaletteController *self,SEL _cmd)

{
  char cVar1;
  id pvVar2;
  undefined4 uVar3;
  id pvVar4;
  undefined4 uVar5;
  undefined4 uVar6;
  
  pvVar2 = _objc_msgSend(self->_flatLiveSlider,sel_isAnimationInProgress);
  if ((char)pvVar2 == '\0') {
    _objc_msgSend(self,sel_validateView_,self->_buttonsView);
    _objc_msgSend(self,sel_validateView_,self->_playerEditorButtonsView);
    _objc_msgSend(self,sel_validateToolPalette);
    _objc_msgSend(self->_activeToolSettingsViewController,sel_validateUserInterface);
    pvVar2 = _objc_msgSend(self->_flatLiveSlider,sel_cell);
    pvVar2 = _objc_msgSend(pvVar2,sel_representedObject);
    uVar3 = _NSSelectorFromString(pvVar2);
    uVar6 = 0;
    uVar5 = 0;
    pvVar2 = _objc_msgSend(self,sel_findValidatorForAction_target_from_,uVar3,0,0);
    pvVar4 = _objc_msgSend(pvVar2,sel_respondsToSelector_,sel_validateUserInterfaceItem_);
    if ((char)pvVar4 == '\0') {
      cVar1 = '\0';
    }
    else {
      pvVar2 = _objc_msgSend(pvVar2,sel_validateUserInterfaceItem_,self->_flatLiveSlider,uVar5,uVar6
                            );
      cVar1 = (char)pvVar2;
    }
    _objc_msgSend(self->_flatLiveSlider,sel_setEnabled_,(int)cVar1,uVar5,uVar6);
  }
  return;
}

*/
- (void)validateUserInterface
{
    if ([_flatLiveSlider isAnimationInProgress]) {
        return;
    }
    [self validateView:_buttonsView];
    [self validateView:_playerEditorButtonsView];
    [self validateToolPalette];
    [_activeToolSettingsViewController validateUserInterface];
    SEL action = NSSelectorFromString([[_flatLiveSlider cell] representedObject]);
    id validator = [self findValidatorForAction:action target:nil from:nil];
    BOOL enabled = NO;
    if ([validator respondsToSelector:@selector(validateUserInterfaceItem:)]) {
        enabled = [validator validateUserInterfaceItem:_flatLiveSlider];
    }
    [_flatLiveSlider setEnabled:enabled];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000d6d34 @ 000d6d34, 297 bytes * /

void FUN_000d6d34(HSToolPaletteController *self,SEL _cmd,id validateView)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  undefined4 uVar3;
  SEL op;
  
  pvVar1 = _objc_msgSend(self->_flatLiveSlider,sel_isAnimationInProgress);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(validateView,sel_subviews);
    self_00 = _objc_msgSend(pvVar1,sel_objectEnumerator);
    pvVar1 = _objc_msgSend(self_00,sel_nextObject);
    while (pvVar1 != (id)0x0) {
      pvVar2 = _objc_msgSend(pvVar1,sel_subviews);
      pvVar2 = _objc_msgSend(pvVar2,sel_count);
      op = sel_validateView_;
      if (pvVar2 == (id)0x0) {
        pvVar2 = _objc_msgSend(pvVar1,sel_cell);
        uVar3 = _NSStringFromSelector(sel_toolPaletteSwitchTool_);
        _objc_msgSend(pvVar2,sel_setRepresentedObject_,uVar3);
        op = sel_validatePaletteItem_;
      }
      _objc_msgSend(self,op,pvVar1);
      pvVar1 = _objc_msgSend(self_00,sel_nextObject);
    }
  }
  return;
}

*/
- (void)validateView:(id)aView
{
    if ([_flatLiveSlider isAnimationInProgress]) {
        return;
    }
    for (NSView *subview in [aView subviews]) {
        if ([[subview subviews] count] != 0) {
            [self validateView:subview];
        }
        else {
            [[(NSControl *)subview cell] setRepresentedObject:NSStringFromSelector(@selector(toolPaletteSwitchTool:))];
            [self validatePaletteItem:subview];
        }
    }
}

- (id)nibName
{
    return @"ToolPalette";
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_toolSettingsViewContainers release];
    [_contentView release];
    [_currentToolButtonsView release];
    [super dealloc];
}

- (void)appWillOpenModalWindow:(id)aWindow
{
    [self performSelector:@selector(validateUserInterfaceForced:) withObject:[NSNumber numberWithBool:YES] afterDelay:0 inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
}

@end

