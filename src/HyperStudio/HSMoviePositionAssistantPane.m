#import "HSMoviePositionAssistantPane.h"

@implementation HSMoviePositionAssistantPane

/* i386 ivar offsets: _previousToolTag=0x88, _positionallyNode=0x8c, _playMovieActionTool=0x90, _applier=0x94, _playbackItemAttributes=0x98, _selectedObject=0x9c, _navigationPaneSwitcher=0xa0, _oldPlaybackItemSupport=0xa4, _paneUndoManager=0xa8 */

- (void)toolWillChange:(id)aChange
{
    [self dismiss:YES];
}

- (BOOL)isAttributesNotificationPostingDisabled
{
    return NO;
}

- (id)cardGroupController
{
    return nil;
}

- (id)delegate
{
    return nil;
}

- (id)scriptController
{
    return nil;
}

- (id)undoManager
{
    return [self paneUndoManager];
}

- (id)objectForAction
{
    return [[self assistant] object];
}

- (void)moviePlaybackDidFinish:(id)aFinish
{

}

- (id)nodeSupportForMovie
{
    return self;
}

- (id)itemAttributeNotificationCenter
{
    return nil;
}

- (id)stackForAction
{
    return [self stack];
}

- (id)cardForAction
{
    return [self card];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ace29 @ 001ace29, 68 bytes * /

void FUN_001ace29(HSMoviePositionAssistantPane *self,SEL _cmd,
                 id userDidFinishPlayMovieActionSetupTool)

{
  _objc_msgSend(self,sel_performSelector_withObject_afterDelay_,sel_paneDidOK_,self,0,0);
  return;
}

*/
- (void)userDidFinishPlayMovieActionSetupTool:(id)aTool
{
    [self performSelector:@selector(paneDidOK:) withObject:self afterDelay:0.0];
}

- (void)playMovieActionPositionToolDidFinish:(id)aFinish
{
    if (_paneUndoManager != nil) {
        [_paneUndoManager removeAllActions];
        [_paneUndoManager release];
        _paneUndoManager = nil;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001acec3 @ 001acec3, 734 bytes * /

void FUN_001acec3(HSMoviePositionAssistantPane *self,SEL _cmd,id paneDidCancel)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined4 uVar4;
  undefined *puVar5;
  undefined4 uVar6;
  undefined *puVar7;
  
  pvVar1 = _objc_msgSend(self->_positionallyNode,sel_attributeObservingController);
  puVar7 = &DAT_0037d5bc;
  uVar6 = 2;
  puVar5 = sel_positionallyNodeGeometryDidChage_;
  _objc_msgSend(pvVar1,sel_removeObserver_selector_ofChanges_ofAttributesOfHyperInterface_,self,
                sel_positionallyNodeGeometryDidChage_,2,&DAT_0037d5bc);
  pvVar1 = _objc_msgSend(self,sel_objectAssistantNavigationController);
  uVar4 = *(undefined4 *)PTR_PTR_003366d0;
  pvVar2 = _objc_msgSend(pvVar1,sel_viewControllersForPaneIdentifier_,uVar4);
  pvVar2 = _objc_msgSend(pvVar2,sel_count);
  if (pvVar2 == (id)0x0) {
    pvVar2 = *(id *)PTR_PTR_003366cc;
    pvVar3 = _objc_msgSend(pvVar1,sel_viewControllersForPaneIdentifier_,pvVar2,puVar5,uVar6,puVar7);
    pvVar3 = _objc_msgSend(pvVar3,sel_count);
    if (pvVar3 == (id)0x0) goto LAB_001ad158;
  }
  pvVar2 = _objc_msgSend(pvVar1,sel_viewControllersForPaneIdentifier_,uVar4);
  pvVar2 = _objc_msgSend(pvVar2,sel_lastObject);
  _objc_msgSend(pvVar1,sel_removeAllViewControllersWithIdentifier_,uVar4);
  if (pvVar2 == (id)0x0) {
    uVar4 = *(undefined4 *)PTR_PTR_003366cc;
    pvVar2 = _objc_msgSend(pvVar1,sel_viewControllersForPaneIdentifier_,uVar4);
    pvVar2 = _objc_msgSend(pvVar2,sel_lastObject);
  }
  pvVar3 = _objc_msgSend(self,sel_card,uVar4);
  pvVar3 = _objc_msgSend(pvVar3,sel_document);
  pvVar3 = _objc_msgSend(pvVar3,sel_undoManager);
  _objc_msgSend(pvVar3,sel_disableUndoRegistration);
  _objc_msgSend(self->_playbackItemAttributes,sel_setPlaybackItemSupport_,
                self->_oldPlaybackItemSupport);
  _objc_msgSend(pvVar2,sel_removeTemporaryAddedObject);
  _objc_msgSend(pvVar2,sel_removeActionIfNeeded);
  pvVar2 = _objc_msgSend(self,sel_card);
  pvVar2 = _objc_msgSend(pvVar2,sel_document);
  pvVar2 = _objc_msgSend(pvVar2,sel_undoManager);
  _objc_msgSend(pvVar2,sel_enableUndoRegistration);
  pvVar2 = _objc_msgSend(pvVar1,sel_viewControllersForPaneIdentifier_,
                         *(undefined4 *)PTR_PTR_003364f4);
  pvVar2 = _objc_msgSend(pvVar2,sel_lastObject);
  puVar5 = (undefined *)0x0;
  _objc_msgSend(pvVar1,sel_changeIdentifierForViewController_toIdentifier_,pvVar2,0);
LAB_001ad158:
  pvVar1 = _objc_msgSend(self,sel_applier,pvVar2,puVar5);
  _objc_msgSend(pvVar1,sel_revertChanges);
  _objc_msgSend(self,sel_dismiss_,1);
  return;
}

*/
- (void)paneDidCancel:(id)aCancel
{
    [[_positionallyNode attributeObservingController] removeObserver:self selector:@selector(positionallyNodeGeometryDidChage:) ofChanges:2 ofAttributesOfHyperInterface:@protocol(HSGeometryAttributes)];
    id navigation = [self objectAssistantNavigationController];
    if ([[navigation viewControllersForPaneIdentifier:HSPlayMovieActionPane_RemoveIfCancelIdentifier] count] != 0 || [[navigation viewControllersForPaneIdentifier:HSPlayMovieActionPaneIdentifier] count] != 0) {
        id pane = [[navigation viewControllersForPaneIdentifier:HSPlayMovieActionPane_RemoveIfCancelIdentifier] lastObject];
        [navigation removeAllViewControllersWithIdentifier:HSPlayMovieActionPane_RemoveIfCancelIdentifier];
        if (pane == nil) {
            pane = [[navigation viewControllersForPaneIdentifier:HSPlayMovieActionPaneIdentifier] lastObject];
        }
        [[[[self card] document] undoManager] disableUndoRegistration];
        [_playbackItemAttributes setPlaybackItemSupport:_oldPlaybackItemSupport];
        [pane removeTemporaryAddedObject];
        [pane removeActionIfNeeded];
        [[[[self card] document] undoManager] enableUndoRegistration];
        [navigation changeIdentifierForViewController:[[navigation viewControllersForPaneIdentifier:HSPickMovieSourcePane_RemoveIfOkIdentifier] lastObject] toIdentifier:nil];
    }
    [[self applier] revertChanges];
    [self dismiss:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ad1a1 @ 001ad1a1, 465 bytes * /

void FUN_001ad1a1(HSMoviePositionAssistantPane *self,SEL _cmd,id paneDidOK)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  id pvVar3;
  undefined4 uVar4;
  undefined *puVar5;
  undefined4 uVar6;
  undefined *puVar7;
  
  pvVar1 = _objc_msgSend(self->_positionallyNode,sel_attributeObservingController);
  puVar7 = &DAT_0037d5bc;
  uVar6 = 2;
  puVar5 = sel_positionallyNodeGeometryDidChage_;
  _objc_msgSend(pvVar1,sel_removeObserver_selector_ofChanges_ofAttributesOfHyperInterface_,self,
                sel_positionallyNodeGeometryDidChage_,2,&DAT_0037d5bc);
  self_00 = _objc_msgSend(self,sel_objectAssistantNavigationController);
  pvVar1 = *(id *)PTR_PTR_003364f4;
  pvVar3 = pvVar1;
  pvVar2 = _objc_msgSend(self_00,sel_viewControllersForPaneIdentifier_,pvVar1);
  pvVar2 = _objc_msgSend(pvVar2,sel_count);
  if (pvVar2 != (id)0x0) {
    _objc_msgSend(self_00,sel_removeAllViewControllersWithIdentifier_,pvVar1,puVar5,uVar6,puVar7);
    uVar6 = *(undefined4 *)PTR_PTR_003366d0;
    uVar4 = uVar6;
    pvVar1 = _objc_msgSend(self_00,sel_viewControllersForPaneIdentifier_,uVar6);
    pvVar1 = _objc_msgSend(pvVar1,sel_lastObject);
    if (pvVar1 == (id)0x0) {
      uVar4 = *(undefined4 *)PTR_PTR_003366cc;
      pvVar1 = _objc_msgSend(self_00,sel_viewControllersForPaneIdentifier_,uVar4);
      pvVar1 = _objc_msgSend(pvVar1,sel_lastObject);
    }
    _objc_msgSend(pvVar1,sel_confirmTemporaryAddeObject,uVar4);
    pvVar1 = _objc_msgSend(self_00,sel_viewControllersForPaneIdentifier_,uVar6);
    pvVar3 = _objc_msgSend(pvVar1,sel_lastObject);
    puVar5 = (undefined *)0x0;
    _objc_msgSend(self_00,sel_changeIdentifierForViewController_toIdentifier_,pvVar3,0);
  }
  pvVar1 = _objc_msgSend(self,sel_applier,pvVar3,puVar5);
  _objc_msgSend(pvVar1,sel_applyChanges);
  _objc_msgSend(self,sel_dismiss_slide_,1,0);
  return;
}

*/
- (void)paneDidOK:(id)aOK
{
    [[_positionallyNode attributeObservingController] removeObserver:self selector:@selector(positionallyNodeGeometryDidChage:) ofChanges:2 ofAttributesOfHyperInterface:@protocol(HSGeometryAttributes)];
    id navigation = [self objectAssistantNavigationController];
    if ([[navigation viewControllersForPaneIdentifier:HSPickMovieSourcePane_RemoveIfOkIdentifier] count] != 0) {
        [navigation removeAllViewControllersWithIdentifier:HSPickMovieSourcePane_RemoveIfOkIdentifier];
        id pane = [[navigation viewControllersForPaneIdentifier:HSPlayMovieActionPane_RemoveIfCancelIdentifier] lastObject];
        if (pane == nil) {
            pane = [[navigation viewControllersForPaneIdentifier:HSPlayMovieActionPaneIdentifier] lastObject];
        }
        [pane confirmTemporaryAddeObject];
        [navigation changeIdentifierForViewController:[[navigation viewControllersForPaneIdentifier:HSPlayMovieActionPane_RemoveIfCancelIdentifier] lastObject] toIdentifier:nil];
    }
    [[self applier] applyChanges];
    [self dismiss:YES slide:NO];
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    id pvVar1_6;

    if ([_positionallyNode implementsHyperInterface:@protocol(HSLiveObjectAttributes)]) {
        [[_positionallyNode queryHyperInterface:@protocol(HSPlayableObjectAttributes)] hyperStop];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSActiveToolWillChangeNotification" object:[HSToolManager sharedToolManager]];
    [[_positionallyNode attributeObservingController] removeObserver:self selector:@selector(positionallyNodeGeometryDidChage:) ofChanges:2 ofAttributesOfHyperInterface:@protocol(HSGeometryAttributes)];
    [self switchToPreviousTool];
    pvVar1_6 = [[self stack] undoManager];
    [pvVar1_6 disableUndoRegistration];
    if ([_playbackItemAttributes isTemporary]) {
        [[self card] removeHyperChild:_positionallyNode];
    }
    [_playbackItemAttributes setPlaybackItemSupport:_oldPlaybackItemSupport];
    [_oldPlaybackItemSupport release];
    _oldPlaybackItemSupport = nil;
    [[[[[self stack] document] currentWindowController] cardView] selectObject:_selectedObject];
    [_selectedObject release];
    _selectedObject = nil;
    [[HSObjectAssistantController sharedAssistantController] setLocked:NO delegate:nil];
    [[self assistant] setSupportsSettingsOnTheSpotMode:YES];
    [pvVar1_6 enableUndoRegistration];
    [self setPositionallyNode:nil];
    [super viewWillDisappear:aDisappear];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ad6d2 @ 001ad6d2, 1380 bytes * /

void FUN_001ad6d2(HSMoviePositionAssistantPane *self,SEL _cmd,BOOL viewWillAppear)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  id pvVar3;
  id pvVar4;
  HSMoviePositionAssistantPane *self_01;
  HSMoviePositionAssistantPane *pHVar5;
  HSMoviePositionAssistantPane *pHVar6;
  SEL op;
  undefined *puVar7;
  undefined4 uVar8;
  undefined *puVar9;
  undefined4 uVar10;
  HSMoviePositionAssistantPane *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSHelpAssistantPane_00353510;
  pHVar6 = (HSMoviePositionAssistantPane *)(int)viewWillAppear;
  _objc_msgSendSuper(&local_1c,sel_viewWillAppear_,pHVar6);
  if (self->_playbackItemAttributes == (id)0x0) goto LAB_001adc07;
  pvVar1 = _objc_msgSend(self,sel_stack);
  pvVar1 = _objc_msgSend(pvVar1,sel_undoManager);
  pvVar2 = _objc_msgSend(self,sel_stack);
  pvVar2 = _objc_msgSend(pvVar2,sel_document);
  pvVar2 = _objc_msgSend(pvVar2,sel_currentWindowController);
  pvVar2 = _objc_msgSend(pvVar2,sel_cardView);
  self_00 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  _objc_msgSend(self,sel_paneUndoManager);
  _objc_msgSend(pvVar1,sel_disableUndoRegistration);
  pvVar3 = _objc_msgSend(self,sel_assistant);
  _objc_msgSend(pvVar3,sel_setSupportsSettingsOnTheSpotMode_,0);
  pvVar3 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
  _objc_msgSend(pvVar3,sel_setLocked_delegate_,1,self);
  pvVar3 = _objc_msgSend(self_00,sel_selectedToolTag);
  self->_previousToolTag = (int)pvVar3;
  pvVar3 = _objc_msgSend(pvVar2,sel_selectedHyperObject);
  pvVar3 = _objc_msgSend(pvVar3,sel_retain);
  self->_selectedObject = pvVar3;
  pvVar3 = _objc_msgSend(self->_playbackItemAttributes,sel_playbackItemSupport);
  pvVar3 = _objc_msgSend(pvVar3,sel_retain);
  self->_oldPlaybackItemSupport = pvVar3;
  _objc_msgSend(self->_playbackItemAttributes,sel_setPlaybackItemSupport_,self);
  pHVar6 = (HSMoviePositionAssistantPane *)&DAT_0037d350;
  pvVar3 = _objc_msgSend(self->_playbackItemAttributes,sel_implementsHyperInterface_,&DAT_0037d350);
  if ((char)pvVar3 == '\0') {
    pHVar5 = (HSMoviePositionAssistantPane *)&DAT_0037d544;
    pHVar6 = pHVar5;
    pvVar3 = _objc_msgSend(self->_playbackItemAttributes,sel_implementsHyperInterface_,&DAT_0037d544
                          );
    if (((char)pvVar3 != '\0') &&
       (pvVar3 = _objc_msgSend(self->_playbackItemAttributes,sel_queryHyperInterface_,&DAT_0037d544)
       , pHVar6 = pHVar5, pvVar3 != (id)0x0)) {
      pvVar4 = _objc_msgSend(self,sel_card,pHVar5);
      pHVar5 = _objc_msgSend(pvVar3,sel_liveObjectForCard_,pvVar4);
      pHVar6 = pHVar5;
      _objc_msgSend(self,sel_setPositionallyNode_,pHVar5);
      if (pHVar5 != (HSMoviePositionAssistantPane *)0x0) {
        pvVar3 = _objc_msgSend(pHVar5,sel_hyperParent,pHVar6);
        op = sel_hyperStart_;
        self_01 = self;
        if (pvVar3 == (id)0x0) {
          pvVar3 = _objc_msgSend(self,sel_card,pHVar6);
          _objc_msgSend(pvVar3,sel_addTemporaryHyperChild_,pHVar5);
          op = sel_hyperStart_;
        }
        goto LAB_001ada8a;
      }
    }
  }
  else {
    pvVar3 = _objc_msgSend(self->_playbackItemAttributes,sel_queryHyperInterface_,&DAT_0037d350);
    if (pvVar3 != (id)0x0) {
      pvVar4 = _objc_msgSend(self,sel_card,pHVar6);
      self_01 = _objc_msgSend(pvVar3,sel_movieObjectForCard_,pvVar4);
      pHVar6 = self_01;
      _objc_msgSend(self,sel_setPositionallyNode_,self_01);
      if ((self_01 != (HSMoviePositionAssistantPane *)0x0) &&
         (pvVar3 = _objc_msgSend(self_01,sel_hyperParent,pHVar6), pvVar3 == (id)0x0)) {
        pHVar5 = _objc_msgSend(self,sel_card,pHVar6);
        op = sel_addTemporaryHyperChild_;
LAB_001ada8a:
        _objc_msgSend(pHVar5,op,self_01);
        pHVar6 = self_01;
      }
    }
  }
  _objc_msgSend(pvVar1,sel_enableUndoRegistration,pHVar6);
  if (self->_positionallyNode != (id)0x0) {
    pvVar1 = _objc_msgSend(self->_positionallyNode,sel_attributeObservingController,pHVar6);
    puVar9 = &DAT_0037d5bc;
    uVar10 = 0x3e800000;
    uVar8 = 2;
    puVar7 = sel_positionallyNodeGeometryDidChage_;
    _objc_msgSend(pvVar1,
                  sel_addObserver_selector_ofChanges_ofAttributesOfHyperInterface_withPriority_,self
                  ,sel_positionallyNodeGeometryDidChage_,2,&DAT_0037d5bc,0x3e800000);
    if (self->_selectedObject != self->_positionallyNode) {
      _objc_msgSend(pvVar2,sel_selectNode_,self->_positionallyNode,puVar7,uVar8,puVar9,uVar10);
    }
    _objc_msgSend(self_00,sel_selectToolWithTag_setAsPermanent_,0x42,0,uVar8,puVar9,uVar10);
    pvVar1 = _objc_msgSend(self_00,sel_currentTool);
    pvVar1 = _objc_msgSend(pvVar1,sel_retain);
    self->_playMovieActionTool = pvVar1;
    _objc_msgSend(pvVar1,sel_setDelegate_,self);
    _objc_msgSend(self->_playMovieActionTool,sel_setCardObject_,self->_positionallyNode);
    pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    pHVar6 = self;
    _objc_msgSend(pvVar1,sel_addObserver_selector_name_object_,self,sel_toolWillChange_,
                  &cfstr_HSActiveToolWillChangeNotification,self_00);
  }
LAB_001adc07:
  pvVar1 = _objc_msgSend(self,sel_applier,pHVar6);
  _objc_msgSend(pvVar1,sel_updateObject);
  return;
}

*/
- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    if (_playbackItemAttributes != nil) {
        id undoManager = [[self stack] undoManager];
        id cardView = [[[[self stack] document] currentWindowController] cardView];
        id toolManager = [HSToolManager sharedToolManager];
        [self paneUndoManager];
        [undoManager disableUndoRegistration];
        [[self assistant] setSupportsSettingsOnTheSpotMode:NO];
        [[HSObjectAssistantController sharedAssistantController] setLocked:YES delegate:self];
        _previousToolTag = [toolManager selectedToolTag];
        _selectedObject = [[cardView selectedHyperObject] retain];
        _oldPlaybackItemSupport = [[_playbackItemAttributes playbackItemSupport] retain];
        [_playbackItemAttributes setPlaybackItemSupport:self];
        if ([_playbackItemAttributes implementsHyperInterface:@protocol(HSMoviePlaybackAttributes)]) {
            id movieAttributes = [_playbackItemAttributes queryHyperInterface:@protocol(HSMoviePlaybackAttributes)];
            if (movieAttributes != nil) {
                id node = [movieAttributes movieObjectForCard:[self card]];
                [self setPositionallyNode:node];
                if (node != nil && [node hyperParent] == nil) {
                    [[self card] addTemporaryHyperChild:node];
                }
            }
        } else if ([_playbackItemAttributes implementsHyperInterface:@protocol(HSLiveVideoPlaybackAttributes)]) {
            id liveAttributes = [_playbackItemAttributes queryHyperInterface:@protocol(HSLiveVideoPlaybackAttributes)];
            if (liveAttributes != nil) {
                id node = [liveAttributes liveObjectForCard:[self card]];
                [self setPositionallyNode:node];
                if (node != nil) {
                    if ([node hyperParent] == nil) {
                        [[self card] addTemporaryHyperChild:node];
                    }
                    [node hyperStart:self];
                }
            }
        }
        [undoManager enableUndoRegistration];
        if (_positionallyNode != nil) {
            [[_positionallyNode attributeObservingController] addObserver:self selector:@selector(positionallyNodeGeometryDidChage:) ofChanges:2 ofAttributesOfHyperInterface:@protocol(HSGeometryAttributes) withPriority:0.25];
            if (_selectedObject != _positionallyNode) {
                [cardView selectNode:_positionallyNode];
            }
            [toolManager selectToolWithTag:0x42 setAsPermanent:NO];
            _playMovieActionTool = [[toolManager currentTool] retain];
            [_playMovieActionTool setDelegate:self];
            [_playMovieActionTool setCardObject:_positionallyNode];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toolWillChange:) name:@"HSActiveToolWillChangeNotification" object:toolManager];
        }
    }
    [[self applier] updateObject];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001adc36 @ 001adc36, 224 bytes * /

void FUN_001adc36(HSMoviePositionAssistantPane *self,SEL _cmd,id positionallyNodeGeometryDidChage)

{
  id pvVar1;
  id self_00;
  undefined4 extraout_EDX;
  undefined8 local_2c;
  undefined8 local_24;
  undefined8 local_1c;
  
  pvVar1 = _objc_msgSend(positionallyNodeGeometryDidChage,sel_object);
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_);
  self_00 = _objc_msgSend(self,sel_applier);
  if (pvVar1 != (id)0x0) {
    _objc_msgSend_stret(&local_2c,pvVar1,sel_affineTransform);
    _objc_msgSend(self_00,sel_setAffineTransform_,local_2c,local_24,local_1c);
    pvVar1 = _objc_msgSend(pvVar1,sel_size);
    _objc_msgSend(self_00,sel_setSize_,pvVar1,extraout_EDX);
  }
  return;
}

*/
- (void)positionallyNodeGeometryDidChage:(id)aChage
{
    id geometry = [[aChage object] queryHyperInterface:@protocol(HSGeometryAttributes)];
    id applier = [self applier];
    if (geometry != nil) {
        [applier setAffineTransform:[geometry affineTransform]];
        [applier setSize:[geometry size]];
    }
}

- (id)paneUndoManager
{
    id pvVar1;

    pvVar1 = _paneUndoManager;
    if (pvVar1 == nil) {
        pvVar1 = [NSUndoManager new];
        _paneUndoManager = pvVar1;
    }
    return pvVar1;
}

- (void)switchToPreviousTool
{
    [[HSToolManager sharedToolManager] selectToolWithTag:_previousToolTag setAsPermanent:YES forceSelection:YES];
}

- (id)applier
{
    id pvVar1;
    id pvVar2;
    id pvVar1_2;

    pvVar1 = _applier;
    if (pvVar1 == nil) {
        pvVar1_2 = [HSMoviePositionApplier alloc];
        pvVar2 = [self playbackItemAttributes];
        [self setApplier:[[pvVar1_2 initWithNode:[self positionallyNode] playbackItemAttributes:pvVar2] autorelease]];
        pvVar1 = _applier;
    }
    return pvVar1;
}

- (void)setApplier:(id)aApplier
{
    id self_00;

    if (_applier != aApplier) {
        if ([_applier delegate] == self) {
            [_applier setDelegate:0];
        }
        [_applier autorelease];
        self_00 = [aApplier retain];
        _applier = self_00;
        [self_00 setDelegate:self];
    }
}

- (id)undoManagerForApplier:(id)aApplier
{
    return [[self stack] undoManager];
}

- (void)setPositionallyNode:(id)aNode
{
    if (_positionallyNode != aNode) {
        [_positionallyNode release];
        _positionallyNode = [aNode retain];
    }
}

- (id)positionallyNode
{
    return _positionallyNode;
}

- (void)setPlaybackItemAttributes:(id)aAttributes
{
    if (_playbackItemAttributes != aAttributes) {
        [_playbackItemAttributes release];
        _playbackItemAttributes = [aAttributes retain];
    }
}

- (id)playbackItemAttributes
{
    return _playbackItemAttributes;
}

- (id)assistantPaneUndoManager
{
    return _paneUndoManager;
}

- (BOOL)needsToBeSavedInHistory
{
    return NO;
}

- (BOOL)shouldShowCancelButtonInNavigationPaneSwitcher:(id)aSwitcher
{
    return YES;
}

- (BOOL)shouldDismissWhenDisappearedByDefault
{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setDontShowThisMessageAgainSwitchVisible:NO];
}

- (id)navigationPaneSwitcher
{
    HSObjectAssistantNavigationPaneSwitcher *pHVar1;
    HSObjectAssistantNavigationPaneSwitcher *pHVar1_2;

    pHVar1 = _navigationPaneSwitcher;
    if (pHVar1 == nil) {
        pHVar1_2 = [HSObjectAssistantNavigationPaneSwitcher new];
        _navigationPaneSwitcher = pHVar1_2;
        [pHVar1_2 setDelegate:self];
        pHVar1 = _navigationPaneSwitcher;
    }
    return pHVar1;
}

- (void)dealloc
{
    [_positionallyNode release];
    [_playbackItemAttributes release];
    [_applier release];
    [_selectedObject release];
    if ([_playMovieActionTool delegate] == self) {
        [_playMovieActionTool setDelegate:0];
    }
    [_playMovieActionTool release];
    [_navigationPaneSwitcher setDelegate:0];
    [_navigationPaneSwitcher release];
    [_paneUndoManager release];
    [_oldPlaybackItemSupport release];
    [super dealloc];
}

- (void)HSMoviePositionAssistantPane_windowDidResignMain:(id)aResign
{
    id current = [[HSEditorController sharedDocumentController] currentDocument];

    if (current != nil && current != [[self card] document])
        [self dismiss:YES];
}

@end

@implementation HSMoviePositionApplier

/* i386 ivar offsets: _playbackItemAttributes=0xc, _initialTransform=0x10, _currentTransform=0x28, _initialSize=0x40, _currentSize=0x48 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ac8ff @ 001ac8ff, 150 bytes * /

BOOL FUN_001ac8ff(HSMoviePositionApplier *self,SEL _cmd)

{
  undefined8 uVar1;
  undefined8 uVar2;
  undefined8 uVar3;
  undefined8 uVar4;
  undefined8 uVar5;
  undefined8 uVar6;
  char cVar7;
  bool bVar8;
  
  uVar1._0_4_ = (self->_initialTransform).tx;
  uVar1._4_4_ = (self->_initialTransform).ty;
  uVar2._0_4_ = (self->_initialTransform).a;
  uVar2._4_4_ = (self->_initialTransform).b;
  uVar3._0_4_ = (self->_initialTransform).c;
  uVar3._4_4_ = (self->_initialTransform).d;
  uVar4._0_4_ = (self->_currentTransform).tx;
  uVar4._4_4_ = (self->_currentTransform).ty;
  uVar5._0_4_ = (self->_currentTransform).c;
  uVar5._4_4_ = (self->_currentTransform).d;
  uVar6._0_4_ = (self->_currentTransform).a;
  uVar6._4_4_ = (self->_currentTransform).b;
  cVar7 = _CGAffineTransformEqualToTransform(uVar6,uVar5,uVar4,uVar2,uVar3,uVar1);
  if (cVar7 == '\0') {
    bVar8 = false;
  }
  else {
    cVar7 = _NSEqualSizes((self->_currentSize).width,(self->_currentSize).height,
                          (self->_initialSize).width,(self->_initialSize).height);
    bVar8 = cVar7 != '\0';
  }
  return bVar8;
}

*/
- (BOOL)areSettingsEqual
{
    return CGAffineTransformEqualToTransform(_currentTransform, _initialTransform) && NSEqualSizes(_currentSize, _initialSize);
}

- (void)setSize:(NSSize)aSize
{
    (_currentSize).width = aSize.width;
    (_currentSize).height = aSize.height;
}

- (void)setAffineTransform:(CGAffineTransform)aTransform
{
    (_currentTransform).a = aTransform.a;
    (_currentTransform).b = aTransform.b;
    (_currentTransform).c = aTransform.c;
    (_currentTransform).d = aTransform.d;
    (_currentTransform).tx = aTransform.tx;
    (_currentTransform).ty = aTransform.ty;
}

- (void)makeCurrentEqualToInitial
{
    float fVar1;

    (_currentTransform).a = (_initialTransform).a;
    (_currentTransform).b = (_initialTransform).b;
    (_currentTransform).c = (_initialTransform).c;
    (_currentTransform).d = (_initialTransform).d;
    (_currentTransform).tx = (_initialTransform).tx;
    (_currentTransform).ty = (_initialTransform).ty;
    fVar1 = (_initialSize).height;
    (_currentSize).width = (_initialSize).width;
    (_currentSize).height = fVar1;
}

- (void)makeInitialEqualToCurrent
{
    float fVar1;

    (_initialTransform).a = (_currentTransform).a;
    (_initialTransform).b = (_currentTransform).b;
    (_initialTransform).c = (_currentTransform).c;
    (_initialTransform).d = (_currentTransform).d;
    (_initialTransform).tx = (_currentTransform).tx;
    (_initialTransform).ty = (_currentTransform).ty;
    fVar1 = (_currentSize).height;
    (_initialSize).width = (_currentSize).width;
    (_initialSize).height = fVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ac995 @ 001ac995, 121 bytes * /

void FUN_001ac995(HSMoviePositionApplier *self,SEL _cmd)

{
  undefined8 uVar1;
  undefined8 uVar2;
  undefined8 uVar3;
  
  uVar1._0_4_ = (self->_initialTransform).tx;
  uVar1._4_4_ = (self->_initialTransform).ty;
  uVar2._0_4_ = (self->_initialTransform).a;
  uVar2._4_4_ = (self->_initialTransform).b;
  uVar3._0_4_ = (self->_initialTransform).c;
  uVar3._4_4_ = (self->_initialTransform).d;
  _objc_msgSend(self->_playbackItemAttributes,sel_setAffineTransform_,uVar2,uVar3,uVar1);
  _objc_msgSend(self->_playbackItemAttributes,sel_setSize_,(self->_initialSize).width,
                (self->_initialSize).height);
  return;
}

*/
- (void)setInitialSettingsToObject
{
    [_playbackItemAttributes setAffineTransform:_initialTransform];
    [_playbackItemAttributes setSize:_initialSize];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001aca0e @ 001aca0e, 121 bytes * /

void FUN_001aca0e(HSMoviePositionApplier *self,SEL _cmd)

{
  undefined8 uVar1;
  undefined8 uVar2;
  undefined8 uVar3;
  
  uVar1._0_4_ = (self->_currentTransform).tx;
  uVar1._4_4_ = (self->_currentTransform).ty;
  uVar2._0_4_ = (self->_currentTransform).a;
  uVar2._4_4_ = (self->_currentTransform).b;
  uVar3._0_4_ = (self->_currentTransform).c;
  uVar3._4_4_ = (self->_currentTransform).d;
  _objc_msgSend(self->_playbackItemAttributes,sel_setAffineTransform_,uVar2,uVar3,uVar1);
  _objc_msgSend(self->_playbackItemAttributes,sel_setSize_,(self->_currentSize).width,
                (self->_currentSize).height);
  return;
}

*/
- (void)setCurrentSettingsToObject
{
    [_playbackItemAttributes setAffineTransform:_currentTransform];
    [_playbackItemAttributes setSize:_currentSize];
}

- (id)undoActionName
{
    return [[NSBundle mainBundle] localizedStringForKey:@"Set Movie Position" value:@"" table:@"UndoManager"];
}

- (id)playbackItemAttributes
{
    return _playbackItemAttributes;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_playbackItemAttributes release];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001acae2 @ 001acae2, 280 bytes * /

id FUN_001acae2(HSMoviePositionApplier *self,SEL _cmd,id initWithNode,id playbackItemAttributes)

{
  id self_00;
  id pvVar1;
  undefined4 extraout_EDX;
  undefined4 local_34;
  undefined4 local_30;
  undefined4 local_2c;
  undefined4 local_28;
  undefined4 local_24;
  undefined4 local_20;
  HSMoviePositionApplier *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSAssistantPaneApplier_003534e0;
  self_00 = _objc_msgSendSuper(&local_1c,sel_initWithObject_,initWithNode);
  if (self_00 != (id)0x0) {
    if (playbackItemAttributes == (id)0x0) {
      _objc_msgSend(self_00,sel_release);
      self_00 = (id)0x0;
    }
    else {
      pvVar1 = _objc_msgSend(playbackItemAttributes,sel_retain);
      *(id *)((int)self_00 + 0xc) = pvVar1;
      _objc_msgSend_stret(&local_34,playbackItemAttributes,sel_affineTransform);
      *(undefined4 *)((int)self_00 + 0x28) = local_34;
      *(undefined4 *)((int)self_00 + 0x2c) = local_30;
      *(undefined4 *)((int)self_00 + 0x30) = local_2c;
      *(undefined4 *)((int)self_00 + 0x34) = local_28;
      *(undefined4 *)((int)self_00 + 0x38) = local_24;
      *(undefined4 *)((int)self_00 + 0x3c) = local_20;
      *(undefined4 *)((int)self_00 + 0x10) = local_34;
      *(undefined4 *)((int)self_00 + 0x14) = local_30;
      *(undefined4 *)((int)self_00 + 0x18) = local_2c;
      *(undefined4 *)((int)self_00 + 0x1c) = local_28;
      *(undefined4 *)((int)self_00 + 0x20) = local_24;
      *(undefined4 *)((int)self_00 + 0x24) = local_20;
      pvVar1 = _objc_msgSend(playbackItemAttributes,sel_size);
      *(id *)((int)self_00 + 0x48) = pvVar1;
      *(undefined4 *)((int)self_00 + 0x4c) = extraout_EDX;
      *(id *)((int)self_00 + 0x40) = pvVar1;
      *(undefined4 *)((int)self_00 + 0x44) = extraout_EDX;
    }
  }
  return self_00;
}

*/
- (id)initWithNode:(id)aNode playbackItemAttributes:(id)aAttributes
{
    self = [super initWithObject:aNode];
    if (self != nil) {
        if (aAttributes == nil) {
            [self release];
            return nil;
        }
        _playbackItemAttributes = [aAttributes retain];
        _currentTransform = _initialTransform = [aAttributes affineTransform];
        _currentSize = _initialSize = [aAttributes size];
    }
    return self;
}

@end

