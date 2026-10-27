#import "HSDropOffOptionsAssistansPane.h"

@implementation HSDropOffOptionsAssistansPane

/* i386 ivar offsets: _navigationController=0x5c, _placeObjectAssisantPane=0x60, _paneSwitcher=0x64, _cardView=0x68, _undoManager=0x6c, _undoHelper=0x70, _dropOffTarget=0x74, _initialDropOffTarget=0x78, _previewSoundObject=0x7c, _importSoundObjectDialogController=0x80, _snappingRangeRenderingLayer=0x84, _helpIsActive=0x88, _helpDrawer=0x8c, _actionHelpView=0x90, _helpTextView=0x94, _slider=0x98, _snapRangeTextField=0x9c, _snapRangeStepper=0xa0, _snapCheckBox=0xa4, _snapLabel=0xa8, _dropOffTargetMenu=0xac, _menuButton=0xb0, _createTargetButton=0xb4, _playAudioCheckBox=0xb8, _chooseAudioMediaButton=0xbc, _audioMediaNameTextField=0xc0, _audioMediaNameBox=0xc4, _playButtonCell=0xc8, _currentSnappingRange=0xcc, _initialInspectorSupportsSOTSMode=0xd0, _snappingRangeSliderIsTracking=0xd1 */

+ (id)stopButtonGraphiteImage
{
    return [[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Stop" state:@"P" size:@"S" tint:@"G"];
}

+ (id)stopButtonAquaImage
{
    return [[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Stop" state:@"P" size:@"S" tint:@"A"];
}

+ (id)stopButtonImage
{
    return [[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Stop" state:@"N" size:@"S" tint:@"A"];
}

+ (id)playButtonGraphiteImage
{
    return [[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Play" state:@"P" size:@"S" tint:@"G"];
}

+ (id)playButtonAquaImage
{
    return [[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Play" state:@"P" size:@"S" tint:@"A"];
}

+ (id)playButtonImage
{
    return [[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Play" state:@"N" size:@"S" tint:@"A"];
}

- (BOOL)control:(id)aControl didFailToFormatString:(id)aString errorDescription:(id)aDescription
{
    BOOL bVar3;

    bVar3 = [aControl isEqual:_snapRangeTextField];
    if (bVar3) {
        [aControl setIntegerValue:[self snappingRange]];
    }
    return bVar3;
}

- (void)hyperCustomStepperDidFinishTracking:(id)aTracking
{
    [self snappingRangeAction:aTracking];
}

- (void)hyperCustomSliderDidStartTracking:(id)aTracking
{
    _snappingRangeSliderIsTracking = YES;
}

- (void)hyperCustomSliderDidFinishTracking:(id)aTracking
{
    [self snappingRangeAction:aTracking];
    _snappingRangeSliderIsTracking = NO;
}

- (id)itemPrototypeObject
{
    return [self dropOffTarget];
}

- (NSUInteger)snappingRange
{
    return _currentSnappingRange;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a546f @ 002a546f, 189 bytes * /

void FUN_002a546f(HSDropOffOptionsAssistansPane *self,SEL _cmd,BOOL hideHelpNeedsRelayout)

{
  id self_00;
  id self_01;
  undefined4 uVar1;
  undefined1 local_24 [8];
  undefined4 local_1c;
  undefined4 local_18;
  
  uVar1 = 0;
  _objc_msgSend(self,sel_setFooterView_,0);
  if (hideHelpNeedsRelayout != '\0') {
    _objc_msgSend(self,sel_layoutIfNeeded,uVar1);
  }
  self->_helpIsActive = '\0';
  self_00 = _objc_msgSend(self,sel_assistant,uVar1);
  self_01 = _objc_msgSend(self,sel_actionHelpView);
  _objc_msgSend_stret(local_24,self_01,sel_frame);
  _objc_msgSend(self_00,sel_toggleDrawerModeWithDrawerSize_,local_1c,local_18);
  return;
}

*/
- (void)hideHelpNeedsRelayout:(BOOL)aRelayout
{
    [self setFooterView:nil];
    if (aRelayout) {
        [self layoutIfNeeded];
    }
    _helpIsActive = NO;
    [[self assistant] toggleDrawerModeWithDrawerSize:[[self actionHelpView] frame].size];
}

- (id)helpDrawer
{
    id pvVar1;
    id pvVar2;
    HSObjectAssistantDrawer *pHVar4;

    pHVar4 = _helpDrawer;
    if (pHVar4 == nil) {
        pvVar1 = [HSObjectAssistantDrawer alloc];
        pvVar2 = [self assistant];
        _helpDrawer = [pvVar1 initWithContentView:[self actionHelpView] objectAssistant:pvVar2];
        [[_helpTextView textStorage] setAttributedString:[[HSNBAHelpProvider sharedNBAHelpProvider] localizedHelpForActionOfType:@"HSDropOffSnappingAction"]];
        pHVar4 = _helpDrawer;
    }
    return pHVar4;
}

- (id)actionHelpView
{
    id pvVar1;

    pvVar1 = _actionHelpView;
    if (pvVar1 == nil) {
        [NSBundle loadNibNamed:@"NBAHelpView" owner:self];
        pvVar1 = _actionHelpView;
    }
    return pvVar1;
}

- (BOOL)isHelpVisible
{
    return _helpIsActive;
}

- (void)movieDidStop:(id)aStop
{
    [self movieDidEnd:aStop];
}

- (void)movieDidPlayOnce:(id)aOnce
{

}

- (void)movieDidChangeImage:(id)aImage
{

}

- (void)movieDidEnd:(id)aEnd
{
    [aEnd gotoBeginning];
    [self updateUI];
}

- (void)prepareToolAndCardViewAfterSwitchForPlaceObjectAssistantPane:(id)aPane
{
    [self unlockAssistantIfNeeded];
    [self resetToolToDefault];
    [self restoreSelectonAfterExit];
    [_cardView ignoreNextMouseDown];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a5743 @ 002a5743, 159 bytes * /

void FUN_002a5743(HSDropOffOptionsAssistansPane *self,SEL _cmd,
                 id prepareToolAndCardViewForPlaceObjectAssistantPane)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar1 = _objc_msgSend(pvVar1,sel_selectedToolTag);
  if (pvVar1 != (id)0x36) {
    _objc_msgSend(self,sel_lockAssistantIfNeeded);
    pvVar1 = _objc_msgSend(self,sel_selectToolWithTag_,0x36);
    _objc_msgSend(pvVar1,sel_setDelegate_,self);
    _objc_msgSend(pvVar1,sel_run);
  }
  return;
}

*/
- (void)prepareToolAndCardViewForPlaceObjectAssistantPane:(id)aPane
{
    id tool;

    // Tag 54 is the place-object tool.
    if ([[HSToolManager sharedToolManager] selectedToolTag] != 54) {
        [self lockAssistantIfNeeded];
        tool = [self selectToolWithTag:54];
        [tool setDelegate:self];
        [(HSPlaceObjectTool *)tool run];
    }
}

- (void)placeObjectShouldCancelFromPlaceObjectAssistantPane:(id)aPane
{
    [[[HSToolManager sharedToolManager] currentTool] cancelPlacingObjectForPlaceObjectCanvasLayer:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a5839 @ 002a5839, 247 bytes * /

void FUN_002a5839(HSDropOffOptionsAssistansPane *self,SEL _cmd,BOOL finishAndApplyChanges)

{
  SEL op;
  id pvVar1;
  int iVar2;
  
  op = sel_applyChanges;
  if (finishAndApplyChanges == '\0') {
    _objc_msgSend(self,sel_revertChanges);
    op = sel_restoreSelectonAfterExit;
  }
  _objc_msgSend(self,op);
  pvVar1 = _objc_msgSend(self,sel_undoHelper);
  iVar2 = (int)finishAndApplyChanges;
  _objc_msgSend(pvVar1,sel_finishDuplicating_,iVar2);
  pvVar1 = _objc_msgSend(self->_navigationController,sel_viewControllers);
  pvVar1 = _objc_msgSend(pvVar1,sel_count);
  if (pvVar1 == (id)0x1) {
    pvVar1 = _objc_msgSend(self->_navigationController,sel_topViewController,iVar2);
    iVar2 = 1;
    _objc_msgSend(pvVar1,sel_dismissModalViewControllerAnimated_,1);
  }
  _objc_msgSend(self,sel_resetToolToDefault,iVar2);
  _objc_msgSend(self,sel_unlockAssistantIfNeeded);
  return;
}

*/
- (void)finishAndApplyChanges:(BOOL)aChanges
{
    if (aChanges) {
        [self applyChanges];
    }
    else {
        [self revertChanges];
        [self restoreSelectonAfterExit];
    }
    [[self undoHelper] finishDuplicating:aChanges];
    if ([[_navigationController viewControllers] count] == 1) {
        [[_navigationController topViewController] dismissModalViewControllerAnimated:YES];
    }
    [self resetToolToDefault];
    [self unlockAssistantIfNeeded];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a5930 @ 002a5930, 633 bytes * /

void FUN_002a5930(HSDropOffOptionsAssistansPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  
  if (self->_dropOffTarget == (id)0x0) {
    return;
  }
  pvVar1 = _objc_msgSend(self,sel_object);
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_003898a8);
  pvVar2 = _objc_msgSend(self->_dropOffTarget,sel_hyperUID);
  _objc_msgSend(pvVar1,sel_setDropOffTargetUID_,pvVar2);
  pvVar1 = _objc_msgSend(self,sel_card);
  pvVar2 = _objc_msgSend(pvVar1,sel_children);
  pvVar1 = self->_dropOffTarget;
  pvVar2 = _objc_msgSend(pvVar2,sel_containsObject_,pvVar1);
  if ((char)pvVar2 == '\0') {
    return;
  }
  pvVar2 = _objc_msgSend(self->_dropOffTarget,sel_isTemporary,pvVar1);
  if ((char)pvVar2 != '\0') {
    pvVar1 = (id)0x0;
    _objc_msgSend(self->_dropOffTarget,sel_setTemporary_,0);
  }
  pvVar2 = _objc_msgSend(self,sel_object,pvVar1);
  pvVar2 = _objc_msgSend(pvVar2,sel_isGroupObject);
  if (((char)pvVar2 == '\0') ||
     (pvVar1 = _objc_msgSend(self->_dropOffTarget,sel_isGroupObject,pvVar1), (char)pvVar1 != '\0'))
  {
    pvVar1 = _objc_msgSend(self,sel_object);
    pvVar1 = _objc_msgSend(pvVar1,sel_isGroupObject);
    if (((char)pvVar1 != '\0') ||
       (pvVar1 = _objc_msgSend(self->_dropOffTarget,sel_isGroupObject), (char)pvVar1 == '\0'))
    goto LAB_002a5ade;
    pvVar1 = self->_dropOffTarget;
    op = sel_makeNonGroupObject;
  }
  else {
    pvVar1 = self->_dropOffTarget;
    op = sel_makeGroupObject;
  }
  _objc_msgSend(pvVar1,op);
LAB_002a5ade:
  pvVar1 = _objc_msgSend(self,sel_card);
  pvVar1 = _objc_msgSend(pvVar1,sel_children);
  pvVar2 = _objc_msgSend(self,sel_object);
  pvVar2 = _objc_msgSend(pvVar1,sel_indexOfObject_,pvVar2);
  pvVar1 = _objc_msgSend(self,sel_card);
  pvVar3 = _objc_msgSend(pvVar1,sel_children);
  pvVar1 = self->_dropOffTarget;
  pvVar3 = _objc_msgSend(pvVar3,sel_indexOfObject_,pvVar1);
  if (pvVar2 < pvVar3) {
    pvVar1 = _objc_msgSend(self,sel_card,pvVar1);
    _objc_msgSend(pvVar1,sel_moveChild_toIndex_,self->_dropOffTarget,pvVar2);
  }
  return;
}

*/
- (void)applyChanges
{
    BOOL objectIsGroup;
    BOOL targetIsGroup;
    NSUInteger objectIndex;
    NSUInteger targetIndex;

    if (_dropOffTarget == nil) {
        return;
    }
    [[[self object] queryHyperInterface:@protocol(HSMutableSnappingTargetUIDIdentification)] setDropOffTargetUID:[_dropOffTarget hyperUID]];
    if (![[[self card] children] containsObject:_dropOffTarget]) {
        return;
    }
    if ([_dropOffTarget isTemporary]) {
        [_dropOffTarget setTemporary:NO];
    }
    // The target follows the object's group membership.
    objectIsGroup = [[self object] isGroupObject];
    targetIsGroup = [_dropOffTarget isGroupObject];
    if (objectIsGroup && !targetIsGroup) {
        [_dropOffTarget makeGroupObject];
    }
    else if (!objectIsGroup && targetIsGroup) {
        [_dropOffTarget makeNonGroupObject];
    }
    // Keep the target below the object in the card's stacking order.
    objectIndex = [[[self card] children] indexOfObject:[self object]];
    targetIndex = [[[self card] children] indexOfObject:_dropOffTarget];
    if (objectIndex < targetIndex) {
        [[self card] moveChild:_dropOffTarget toIndex:objectIndex];
    }
}

- (void)revertChanges
{
    if ([self dropOffTarget] != nil) {
        [[[self card] undoManager] disableUndoRegistration];
        [[[self dropOffTarget] queryHyperInterface:@protocol(HSNodeChild)] removeFromHyperParent];
        [[[self card] undoManager] enableUndoRegistration];
        [_dropOffTarget release];
        _dropOffTarget = nil;
    }
    [self invalidatePreviewSoundObject];
    if (_initialDropOffTarget != nil) {
        [[[self card] undoManager] disableUndoRegistration];
        [[[self object] queryHyperInterface:@protocol(HSMutableSnappingTargetUIDIdentification)] setDropOffTargetUID:[_initialDropOffTarget hyperUID]];
        [[self card] addHyperChild:_initialDropOffTarget];
        [[[self card] undoManager] enableUndoRegistration];
    }
}

- (void)paneDidCancel:(id)aCancel
{
    [self finishAndApplyChanges:NO];
}

- (void)paneDidOK:(id)aOK
{
    [self finishAndApplyChanges:YES];
    [self restoreSelectonAfterExit];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a5e25 @ 002a5e25, 449 bytes * /

void FUN_002a5e25(HSDropOffOptionsAssistansPane *self,SEL _cmd,id placingFinishedForPlaceObjectTool,
                 NSPoint atPoint)

{
  id pvVar1;
  id pvVar2;
  undefined4 uVar3;
  undefined4 uVar4;
  
  pvVar1 = _objc_msgSend(self->_placeObjectAssisantPane,sel_object);
  _objc_msgSend(self,sel_endAtomicMovingOfObject_,pvVar1);
  _objc_msgSend(placingFinishedForPlaceObjectTool,sel_setDelegate_,0);
  pvVar1 = _objc_msgSend(self->_placeObjectAssisantPane,sel_object);
  _objc_msgSend(self,sel_setDropOffTarget_,pvVar1);
  pvVar2 = _objc_msgSend(self,sel_object);
  pvVar2 = _objc_msgSend(pvVar2,sel_isGroupObject);
  if ((char)pvVar2 != '\0') {
    pvVar1 = _objc_msgSend(self,sel_dropOffTarget,pvVar1);
    _objc_msgSend(pvVar1,sel_makeGroupObject);
  }
  _objc_msgSend(self->_dropOffTarget,sel_setTemporary_,0);
  _objc_msgSend(self->_cardView,sel_setOccupiedByTool_,0);
  _objc_msgSend(self,sel_resetToolToDefault);
  _objc_msgSend(self,sel_restoreSelectonAfterExit);
  uVar4 = 1;
  _objc_msgSend(self->_navigationController,sel_popAllTopViewControllersWithIdentifier_animate_,
                &cfstr_HSDropOffTemporaryPaneIdentifier,1);
  _objc_msgSend(self,sel_unlockAssistantIfNeeded);
  pvVar1 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
  uVar3 = 0xffffffff;
  if ((self->_initialInspectorSupportsSOTSMode[0] & 1) == 0) {
    uVar3 = 0;
  }
  _objc_msgSend(pvVar1,sel_setSupportsSettingsOnTheSpotMode_,uVar3,uVar4);
  _objc_msgSend(self,sel_updateUI);
  return;
}

*/
- (void)placingFinishedForPlaceObjectTool:(id)aTool atPoint:(NSPoint)aPoint
{
    [self endAtomicMovingOfObject:[_placeObjectAssisantPane object]];
    [aTool setDelegate:nil];
    [self setDropOffTarget:[_placeObjectAssisantPane object]];
    if ([[self object] isGroupObject]) {
        [[self dropOffTarget] makeGroupObject];
    }
    [_dropOffTarget setTemporary:NO];
    [_cardView setOccupiedByTool:NO];
    [self resetToolToDefault];
    [self restoreSelectonAfterExit];
    [_navigationController popAllTopViewControllersWithIdentifier:@"HSDropOffTemporaryPaneIdentifier" animate:YES];
    [self unlockAssistantIfNeeded];
    [[HSObjectAssistantController sharedAssistantController] setSupportsSettingsOnTheSpotMode:_initialInspectorSupportsSOTSMode];
    [self updateUI];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a5fe6 @ 002a5fe6, 461 bytes * /

void FUN_002a5fe6(HSDropOffOptionsAssistansPane *self,SEL _cmd,id placingCanceledForPlaceObjectTool)

{
  id pvVar1;
  id self_00;
  undefined4 uVar2;
  
  pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar1 = _objc_msgSend(pvVar1,sel_currentTool);
  _objc_msgSend(pvVar1,sel_setDelegate_,0);
  pvVar1 = _objc_msgSend(self->_placeObjectAssisantPane,sel_object);
  _objc_msgSend(self,sel_removeDropOffObjectFromCard_,pvVar1);
  pvVar1 = _objc_msgSend(self->_placeObjectAssisantPane,sel_object);
  _objc_msgSend(self,sel_endAtomicMovingOfObject_,pvVar1);
  if (self->_dropOffTarget != (id)0x0) {
    self_00 = _objc_msgSend(self,sel_card,pvVar1);
    pvVar1 = self->_dropOffTarget;
    _objc_msgSend(self_00,sel_addHyperChild_,pvVar1);
  }
  _objc_msgSend(self,sel_resetToolToDefault,pvVar1);
  _objc_msgSend(self,sel_restoreSelectonAfterExit);
  _objc_msgSend(self,sel_unlockAssistantIfNeeded);
  _objc_msgSend(self->_cardView,sel_setOccupiedByTool_,0);
  _objc_msgSend(self->_placeObjectAssisantPane,sel_dismiss_,1);
  _objc_msgSend(self->_placeObjectAssisantPane,sel_setDelegate_,0);
  _objc_msgSend(self->_placeObjectAssisantPane,sel_release);
  self->_placeObjectAssisantPane = (id)0x0;
  pvVar1 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
  uVar2 = 0xffffffff;
  if ((self->_initialInspectorSupportsSOTSMode[0] & 1) == 0) {
    uVar2 = 0;
  }
  _objc_msgSend(pvVar1,sel_setSupportsSettingsOnTheSpotMode_,uVar2);
  return;
}

*/
- (void)placingCanceledForPlaceObjectTool:(id)aTool
{
    [[[HSToolManager sharedToolManager] currentTool] setDelegate:nil];
    [self removeDropOffObjectFromCard:[_placeObjectAssisantPane object]];
    [self endAtomicMovingOfObject:[_placeObjectAssisantPane object]];
    if (_dropOffTarget != nil) {
        [[self card] addHyperChild:_dropOffTarget];
    }
    [self resetToolToDefault];
    [self restoreSelectonAfterExit];
    [self unlockAssistantIfNeeded];
    [_cardView setOccupiedByTool:NO];
    [_placeObjectAssisantPane dismiss:YES];
    [_placeObjectAssisantPane setDelegate:nil];
    [_placeObjectAssisantPane release];
    _placeObjectAssisantPane = nil;
    [[HSObjectAssistantController sharedAssistantController] setSupportsSettingsOnTheSpotMode:_initialInspectorSupportsSOTSMode];
}

- (void)placeObjectTool:(id)aTool setObjectPosition:(NSPoint)aPosition
{
    [[[_placeObjectAssisantPane object] undoManager] disableUndoRegistration];
    [self setObjectPosition:aPosition ofObject:[_placeObjectAssisantPane object]]
    ;
    [[[_placeObjectAssisantPane object] undoManager] enableUndoRegistration];
}

- (void)removeObjectFromCardForPlaceObjectTool:(id)aTool
{
    [self removeDropOffObjectFromCard:[_placeObjectAssisantPane object]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a62c1 @ 002a62c1, 221 bytes * /

void FUN_002a62c1(HSDropOffOptionsAssistansPane *self,SEL _cmd,id addObjectToCardForPlaceObjectTool)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
  pvVar1 = _objc_msgSend(pvVar1,sel_supportsSettingsOnTheSpotMode);
  self->_initialInspectorSupportsSOTSMode[0] =
       self->_initialInspectorSupportsSOTSMode[0] & 0xfe | (byte)pvVar1 & 1;
  pvVar1 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
  _objc_msgSend(pvVar1,sel_setSupportsSettingsOnTheSpotMode_,0);
  pvVar1 = _objc_msgSend(self->_placeObjectAssisantPane,sel_object);
  _objc_msgSend(self,sel_addDropOffObjectToCard_,pvVar1);
  pvVar1 = _objc_msgSend(self->_placeObjectAssisantPane,sel_object);
  _objc_msgSend(self,sel_beginAtomicMovingOfObject_,pvVar1);
  return;
}

*/
- (void)addObjectToCardForPlaceObjectTool:(id)aTool
{
    _initialInspectorSupportsSOTSMode = [[HSObjectAssistantController sharedAssistantController] supportsSettingsOnTheSpotMode];
    [[HSObjectAssistantController sharedAssistantController] setSupportsSettingsOnTheSpotMode:NO];
    [self addDropOffObjectToCard:[_placeObjectAssisantPane object]];
    [self beginAtomicMovingOfObject:[_placeObjectAssisantPane object]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a639e @ 002a639e, 146 bytes * /

void FUN_002a639e(HSDropOffOptionsAssistansPane *self,SEL _cmd,id endAtomicMovingOfObject)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(endAtomicMovingOfObject,sel_queryHyperInterface_,&DAT_00389ad8);
  pvVar1 = _objc_msgSend(pvVar1,sel_attributeObservingController);
  pvVar2 = _objc_msgSend(cls_NSEProtocolSet,sel_protocolSetWithProtocols_,&DAT_00389c68,
                         &DAT_00389c90,0);
  _objc_msgSend(pvVar1,sel_endContinuousChangeOfAttributeSet_,pvVar2);
  return;
}

*/
- (void)endAtomicMovingOfObject:(id)aObject
{
    [[[aObject queryHyperInterface:@protocol(HSGeometryAttributes)] attributeObservingController] endContinuousChangeOfAttributeSet:[NSEProtocolSet protocolSetWithProtocols:@protocol(HSHorizontalOffsetAttribute), @protocol(HSVerticalOffsetAttribute), nil]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a6430 @ 002a6430, 146 bytes * /

void FUN_002a6430(HSDropOffOptionsAssistansPane *self,SEL _cmd,id beginAtomicMovingOfObject)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(beginAtomicMovingOfObject,sel_queryHyperInterface_,&DAT_00389ad8);
  pvVar1 = _objc_msgSend(pvVar1,sel_attributeObservingController);
  pvVar2 = _objc_msgSend(cls_NSEProtocolSet,sel_protocolSetWithProtocols_,&DAT_00389c68,
                         &DAT_00389c90,0);
  _objc_msgSend(pvVar1,sel_beginContinuousChangeOfAttributeSet_,pvVar2);
  return;
}

*/
- (void)beginAtomicMovingOfObject:(id)aObject
{
    [[[aObject queryHyperInterface:@protocol(HSGeometryAttributes)] attributeObservingController] beginContinuousChangeOfAttributeSet:[NSEProtocolSet protocolSetWithProtocols:@protocol(HSHorizontalOffsetAttribute), @protocol(HSVerticalOffsetAttribute), nil]];
}

- (void)invalidatePreviewSoundObject
{
    if ([_previewSoundObject isPlaying]) {
        [_previewSoundObject stop];
    }
    if ([_previewSoundObject delegate] == self) {
        [_previewSoundObject setDelegate:0];
    }
    [_previewSoundObject release];
    _previewSoundObject = nil;
}

- (id)previewSoundObject
{
    id pvVar1;
    id pvVar1_2;

    if (_previewSoundObject == nil) {
        pvVar1 = [self actionAttributesAudioMediaFileURL];
        if (pvVar1 != nil) {
            pvVar1_2 = [[HSMovie alloc] initWithURL:pvVar1 error:0];
            _previewSoundObject = pvVar1_2;
            [pvVar1_2 setDelegate:self];
        }
    }
    return _previewSoundObject;
}

- (id)actionAttributesAudioMediaFileURL
{
    id pvVar1_3;
    NSURL *pvVar1_4;

    pvVar1_3 = [[[self mutableSnappingAttributes] dropOffRewardSoundMedia] fullPathToMediaFileCreateIfNeeded:YES];
    if (pvVar1_3 == nil) {
        pvVar1_4 = nil;
    }
    else {
        pvVar1_4 = [NSURL fileURLWithPath:pvVar1_3];
    }
    return pvVar1_4;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a665c @ 002a665c, 94 bytes * /

id FUN_002a665c(HSDropOffOptionsAssistansPane *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = self->_importSoundObjectDialogController;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_HSImportDialogController,sel_alloc);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithDialogType_,*(undefined4 *)PTR_PTR_003360dc);
    self->_importSoundObjectDialogController = pvVar1;
  }
  return pvVar1;
}

*/
- (id)importSoundObjectDialogController
{
    if (_importSoundObjectDialogController == nil) {
        _importSoundObjectDialogController = [[HSImportDialogController alloc] initWithDialogType:HSImportDialogControllerTypeSound];
    }
    return _importSoundObjectDialogController;
}

- (void)stopPlaying
{
    [_previewSoundObject stop];
    [_previewSoundObject gotoBeginning];
}

- (BOOL)isPlaying
{
    return (BOOL)[_previewSoundObject isPlaying];
}

- (void)resetToolToDefault
{
    [self selectToolWithTag:0];
}

- (void)hideHelp:(id)aHelp
{
    [self hideHelpNeedsRelayout:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a6784 @ 002a6784, 313 bytes * /

void FUN_002a6784(HSDropOffOptionsAssistansPane *self,SEL _cmd,id showHelp)

{
  id pvVar1;
  id pvVar2;
  undefined1 local_1c [8];
  undefined4 local_14;
  undefined4 local_10;
  
  pvVar1 = _objc_msgSend(self,sel_assistant);
  pvVar2 = _objc_msgSend(self,sel_actionHelpView);
  _objc_msgSend_stret(local_1c,pvVar2,sel_frame);
  _objc_msgSend(pvVar1,sel_toggleDrawerModeWithDrawerSize_,local_14,local_10);
  pvVar1 = _objc_msgSend(self,sel_actionHelpView);
  _objc_msgSend(self,sel_setFooterView_,pvVar1);
  pvVar1 = _objc_msgSend(self->_helpTextView,sel_textStorage);
  pvVar2 = _objc_msgSend(cls_HSNBAHelpProvider,sel_sharedNBAHelpProvider);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedHelpForActionOfType_,&cfstr_HSDropOffSnappingAction);
  _objc_msgSend(pvVar1,sel_setAttributedString_,pvVar2);
  _objc_msgSend(self,sel_layoutIfNeeded);
  self->_helpIsActive = '\x01';
  return;
}

*/
- (void)showHelp:(id)aHelp
{
    [[self assistant] toggleDrawerModeWithDrawerSize:[[self actionHelpView] frame].size];
    [self setFooterView:[self actionHelpView]];
    [[_helpTextView textStorage] setAttributedString:[[HSNBAHelpProvider sharedNBAHelpProvider] localizedHelpForActionOfType:@"HSDropOffSnappingAction"]];
    [self layoutIfNeeded];
    _helpIsActive = YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a68bd @ 002a68bd, 147 bytes * /

void FUN_002a68bd(HSDropOffOptionsAssistansPane *self,SEL _cmd,id playAudioMedia)

{
  id pvVar1;
  HSDropOffOptionsAssistansPane *self_00;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_isPlaying);
  self_00 = self;
  op = sel_stopPlaying;
  if ((char)pvVar1 == '\0') {
    self_00 = _objc_msgSend(cls_HSMediaPlaySynchronizer,sel_sharedSynchronizer);
    _objc_msgSend(self,sel_previewSoundObject);
    op = sel_playMediaSingle_;
  }
  _objc_msgSend(self_00,op);
  _objc_msgSend(self,sel_updateUI);
  return;
}

*/
- (void)playAudioMedia:(id)aMedia
{
    if ([self isPlaying]) {
        [self stopPlaying];
    }
    else {
        [[HSMediaPlaySynchronizer sharedSynchronizer] playMediaSingle:[self previewSoundObject]];
    }
    [self updateUI];
}

- (void)chooseMedia:(id)aMedia
{
    id pvVar1;

    pvVar1 = [self importSound];
    if (pvVar1 != nil) {
        [self setDropOffTargetRewardSoundMedia:pvVar1];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a6994 @ 002a6994, 194 bytes * /

void FUN_002a6994(HSDropOffOptionsAssistansPane *self,SEL _cmd,id enablePlayRewardSoundAction)

{
  id pvVar1;
  SEL pcVar2;
  SEL op;
  
  pvVar1 = _objc_msgSend(enablePlayRewardSoundAction,sel_state);
  if (pvVar1 == (id)0x0) {
    _objc_msgSend(self->_previewSoundObject,sel_stop);
    enablePlayRewardSoundAction = self;
    pcVar2 = sel_setDropOffTargetRewardSoundMedia_;
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_mutableSnappingAttributes);
    pvVar1 = _objc_msgSend(pvVar1,sel_dropOffRewardSoundMedia);
    if (pvVar1 == (id)0x0) {
      pvVar1 = _objc_msgSend(self,sel_importSound);
    }
    pcVar2 = sel_setState_;
    op = sel_setDropOffTargetRewardSoundMedia_;
    if (pvVar1 != (id)0x0) goto LAB_002a6a49;
  }
  pvVar1 = (id)0x0;
  self = enablePlayRewardSoundAction;
  op = pcVar2;
LAB_002a6a49:
  _objc_msgSend(self,op,pvVar1);
  return;
}

*/
- (void)enablePlayRewardSoundAction:(id)aAction
{
    id media;

    if ([aAction state] == NSControlStateValueOff) {
        [_previewSoundObject stop];
        [self setDropOffTargetRewardSoundMedia:nil];
        return;
    }
    media = [[self mutableSnappingAttributes] dropOffRewardSoundMedia];
    if (media == nil) {
        media = [self importSound];
    }
    if (media != nil) {
        [self setDropOffTargetRewardSoundMedia:media];
    }
    else {
        // The import was cancelled, so the check box goes back off.
        [aAction setState:NSControlStateValueOff];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a6a56 @ 002a6a56, 421 bytes * /

id FUN_002a6a56(HSDropOffOptionsAssistansPane *self,SEL _cmd)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  undefined4 uVar6;
  undefined4 uVar7;
  undefined4 uVar8;
  
  pvVar2 = _objc_msgSend(self,sel_importSoundObjectDialogController);
  pvVar3 = _objc_msgSend(self,sel_stack);
  pvVar3 = _objc_msgSend(pvVar3,sel_document);
  _objc_msgSend(pvVar2,sel_setHyperDocument_,pvVar3);
  puVar1 = cls_HSImportDialogController;
  pvVar3 = _objc_msgSend(self,sel_assistant);
  pvVar3 = _objc_msgSend(pvVar3,sel_object);
  pvVar3 = _objc_msgSend(puVar1,sel_defaultButtonTitleForObject_,pvVar3);
  _objc_msgSend(pvVar2,sel_setDefaultButtonTitle_,pvVar3);
  puVar1 = cls_NSDictionary;
  pvVar3 = _objc_msgSend(cls_NSNumber,sel_numberWithBool_,1);
  uVar7 = *(undefined4 *)PTR_PTR_00336784;
  uVar6 = *(undefined4 *)PTR_PTR_00336788;
  uVar8 = 0;
  pvVar4 = _objc_msgSend(puVar1,sel_dictionaryWithObjectsAndKeys_,&cfstr_TotalTime,uVar6,pvVar3,
                         uVar7,0);
  _objc_msgSend(pvVar2,sel_setupDialogInterfaceWithOptions_,pvVar4);
  pvVar5 = _objc_msgSend(pvVar2,sel_runModal);
  if ((pvVar5 == (id)0x1) &&
     (pvVar5 = _objc_msgSend(pvVar2,sel_fileName,pvVar4,uVar6,pvVar3,uVar7,uVar8), pvVar5 != (id)0x0
     )) {
    pvVar2 = _objc_msgSend(pvVar2,sel_fileName,pvVar4,uVar6,pvVar3,uVar7,uVar8);
    pvVar2 = _objc_msgSend(cls_HSNewMedia,sel_mediaWithPath_,pvVar2);
    return pvVar2;
  }
  return (id)0x0;
}

*/
- (id)importSound
{
    HSImportDialogController *dialog;
    NSDictionary *options;

    dialog = [self importSoundObjectDialogController];
    [dialog setHyperDocument:[[self stack] document]];
    [dialog setDefaultButtonTitle:[HSImportDialogController defaultButtonTitleForObject:[[self assistant] object]]];
    options = [NSDictionary dictionaryWithObjectsAndKeys:
               @"TotalTime", HSImportDialogSoundSortIdentifierKey,
               [NSNumber numberWithBool:YES], HSImportDialogSoundSortAscendingKey,
               nil];
    [dialog setupDialogInterfaceWithOptions:options];
    if ([dialog runModal] == NSModalResponseOK && [dialog fileName] != nil) {
        return [HSNewMedia mediaWithPath:[dialog fileName]];
    }
    return nil;
}

- (void)setTargetAction:(id)aAction
{
    [self unlockAssistantIfNeeded];
    [self resetToolToDefault];
    [[self objectAssistantPaneDelegate] openPaneWithIdentifier:@"HSActionsAssistantPane"];
    [[_cardView selection] selectNode:[self dropOffTarget]];
}

- (void)snappingRangeAction:(id)aAction
{
    NSUInteger pvVar1;
    NSUInteger pvVar2;
    id self_00;
    NSInteger pvVar2_2;

    pvVar1 = [self currentSnappingRange];
    pvVar2 = [self maxSnappingRange];
    self_00 = [self mutableSnappingAttributes];
    if (pvVar2 < pvVar1) {
        pvVar1 = pvVar2;
    }
    pvVar2_2 = 0xa;
    if (0x9 < pvVar1) {
        pvVar2_2 = pvVar1;
    }
    if ([self_00 dropOffSnappingRange] != pvVar2_2) {
        [self setDropOffSnappingRange:[NSNumber numberWithInteger:pvVar2_2]];
    }
}

- (void)setSnapEnabledAction:(id)aAction
{
    [self setDropOffTargetSnapEnablingState:[NSNumber numberWithBool:(unsigned int)([aAction state] == 0x1)]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a6f93 @ 002a6f93, 529 bytes * /

void FUN_002a6f93(HSDropOffOptionsAssistansPane *self,SEL _cmd,id createNewTargetAction)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined4 uVar4;
  
  _objc_msgSend(self,sel_lockAssistantIfNeeded);
  _objc_msgSend(self->_cardView,sel_setOccupiedByTool_,1);
  uVar4 = 0x36;
  pvVar1 = _objc_msgSend(self,sel_selectToolWithTag_,0x36);
  self_00 = cls_NSArray;
  if (self->_dropOffTarget != (id)0x0) {
    pvVar3 = self->_cardView;
    pvVar2 = _objc_msgSend(self,sel_dropOffTarget,uVar4);
    pvVar2 = _objc_msgSend(self_00,sel_arrayWithObject_,pvVar2);
    _objc_msgSend(pvVar3,sel_performDeleteOperationWithNodesInArray_,pvVar2);
    pvVar3 = _objc_msgSend(self,sel_card);
    pvVar3 = _objc_msgSend(pvVar3,sel_undoManager);
    _objc_msgSend(pvVar3,sel_disableUndoRegistration);
    pvVar3 = _objc_msgSend(self,sel_dropOffTarget);
    pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_00389a74);
    _objc_msgSend(pvVar3,sel_removeFromHyperParent);
    pvVar3 = _objc_msgSend(self,sel_card);
    pvVar3 = _objc_msgSend(pvVar3,sel_undoManager);
    _objc_msgSend(pvVar3,sel_enableUndoRegistration);
  }
  _objc_msgSend(pvVar1,sel_setDelegate_,self);
  _objc_msgSend(pvVar1,sel_run);
  _objc_msgSend(self,sel_recreatePlaceObjectAssistantPaneWithKey_,&cfstr_DropOffTargetCoaching);
  pvVar1 = self->_placeObjectAssisantPane;
  pvVar3 = _objc_msgSend(self,sel_createDropOffObject);
  _objc_msgSend(pvVar1,sel_setObject_,pvVar3);
  _objc_msgSend(self->_navigationController,
                sel_pushViewController_withIdentifier_animate_replacePrevious_,
                self->_placeObjectAssisantPane,&cfstr_HSDropOffTemporaryPaneIdentifier,1,0);
  return;
}

*/
- (void)createNewTargetAction:(id)aAction
{
    id tool;

    [self lockAssistantIfNeeded];
    [_cardView setOccupiedByTool:YES];
    tool = [self selectToolWithTag:54];
    if (_dropOffTarget != nil) {
        [_cardView performDeleteOperationWithNodesInArray:[NSArray arrayWithObject:[self dropOffTarget]]];
        [[[self card] undoManager] disableUndoRegistration];
        [[[self dropOffTarget] queryHyperInterface:@protocol(HSNodeChild)] removeFromHyperParent];
        [[[self card] undoManager] enableUndoRegistration];
    }
    [tool setDelegate:self];
    [(HSPlaceObjectTool *)tool run];
    [self recreatePlaceObjectAssistantPaneWithKey:@"DropOffTargetCoaching"];
    [_placeObjectAssisantPane setObject:[self createDropOffObject]];
    [_navigationController pushViewController:_placeObjectAssisantPane withIdentifier:@"HSDropOffTemporaryPaneIdentifier" animate:YES replacePrevious:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a71a4 @ 002a71a4, 158 bytes * /

uint FUN_002a71a4(HSDropOffOptionsAssistansPane *self,SEL _cmd)

{
  id pvVar1;
  uint uVar2;
  uint uVar3;
  undefined1 local_1c [8];
  float local_14;
  float local_10;
  
  pvVar1 = _objc_msgSend(self,sel_dropOffTarget);
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00389ad8);
  _objc_msgSend_stret(local_1c,pvVar1,sel_boundingRect);
  if (local_14 <= local_10) {
    local_14 = local_10;
  }
  local_14 = local_14 + local_14;
  uVar3 = (int)local_14;
  if (2.1474836e+09 <= local_14) {
    uVar3 = (int)(local_14 - 2.1474836e+09) ^ 0x80000000;
  }
  uVar2 = 999;
  if (uVar3 < 1000) {
    uVar2 = uVar3;
  }
  return uVar2;
}

*/
- (NSUInteger)maxSnappingRange
{
    NSRect bounds;
    CGFloat extent;
    NSUInteger range;

    bounds = [[[self dropOffTarget] queryHyperInterface:@protocol(HSGeometryAttributes)] boundingRect];
    extent = bounds.size.width;
    if (extent <= bounds.size.height) {
        extent = bounds.size.height;
    }
    range = (NSUInteger)(extent + extent);
    if (range < 1000) {
        return range;
    }
    return 999;
}

- (id)dropOffTarget
{
    id pvVar1;

    pvVar1 = [_dropOffTarget hyperUID];
    return [[[[[self object] card] queryHyperInterface:@protocol(HSUserObjectUIDBasedAccess)] childInTreeWithUID:pvVar1] queryHyperInterface:@protocol(HSMutableCardObjectAttributes)];
}

- (id)mutableSnappingAttributes
{
    return [[self dropOffTarget] queryHyperInterface:@protocol(HSMutableSnapOptionsAttributes)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a7329 @ 002a7329, 278 bytes * /

void FUN_002a7329(HSDropOffOptionsAssistansPane *self,SEL _cmd,id setDropOffSnappingRange)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(self,sel_undoManager);
  self_00 = cls_NSNumber;
  pvVar2 = _objc_msgSend(self,sel_mutableSnappingAttributes);
  pvVar2 = _objc_msgSend(pvVar2,sel_dropOffSnappingRange);
  pvVar2 = _objc_msgSend(self_00,sel_numberWithInteger_,pvVar2);
  _objc_msgSend(pvVar1,sel_registerUndoWithTarget_selector_object_,self,sel_setDropOffSnappingRange_
                ,pvVar2);
  pvVar1 = _objc_msgSend(self,sel_undoHelper);
  _objc_msgSend(pvVar1,sel_duplicateAction);
  pvVar1 = _objc_msgSend(self,sel_mutableSnappingAttributes);
  pvVar2 = _objc_msgSend(setDropOffSnappingRange,sel_integerValue);
  _objc_msgSend(pvVar1,sel_setDropOffSnappingRange_,pvVar2);
  _objc_msgSend(self,sel_updateUI);
  return;
}

*/
- (void)setDropOffSnappingRange:(id)aRange
{
    [[self undoManager] registerUndoWithTarget:self selector:@selector(setDropOffSnappingRange:) object:[NSNumber numberWithInteger:[[self mutableSnappingAttributes] dropOffSnappingRange]]];
    [[self undoHelper] duplicateAction];
    [(id<HSMutableSnapOptionsAttributes>)[self mutableSnappingAttributes] setDropOffSnappingRange:[aRange integerValue]];
    [self updateUI];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a743f @ 002a743f, 129 bytes * /

uint FUN_002a743f(HSDropOffOptionsAssistansPane *self,SEL _cmd)

{
  id pvVar1;
  uint uVar2;
  longdouble lVar3;
  
  pvVar1 = _objc_msgSend(self,sel_currentSnappingRange);
  lVar3 = (longdouble)
          _HSLinearValueForSliderFromNonLinear
                    (self->_slider,
                     (float)((double)(ZEXT48(pvVar1) | 0x4330000000000000) - 4503599627370496.0));
  uVar2 = (int)lVar3;
  if (2.1474836e+09 <= (float)lVar3) {
    uVar2 = (int)((float)lVar3 - 2.1474836e+09) ^ 0x80000000;
  }
  return uVar2;
}

*/
- (NSUInteger)transformedBySliderSnappingRange
{
    return (NSUInteger)HSLinearValueForSliderFromNonLinear(_slider, (float)[self currentSnappingRange]);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a74c0 @ 002a74c0, 102 bytes * /

void FUN_002a74c0(HSDropOffOptionsAssistansPane *self,SEL _cmd,
                 id setTransformedBySliderSnappingRange)

{
  id pvVar1;
  longdouble lVar2;
  
  if (setTransformedBySliderSnappingRange != (id)0x0) {
    lVar2 = (longdouble)_HSNonLinearValueForSlider(self->_slider);
    pvVar1 = _objc_msgSend(cls_NSNumber,sel_numberWithInteger_,(int)lVar2);
    _objc_msgSend(self,sel_setCurrentSnappingRange_,pvVar1);
  }
  return;
}

*/
- (void)setTransformedBySliderSnappingRange:(id)aRange
{
    if (aRange != nil) {
        [self setCurrentSnappingRange:[NSNumber numberWithInteger:(NSInteger)HSNonLinearValueForSlider(_slider)]];
    }
}

- (NSUInteger)currentSnappingRange
{
    return _currentSnappingRange;
}

- (void)setCurrentSnappingRange:(id)aRange
{
    _currentSnappingRange = (unsigned int)[aRange integerValue];
    if (_snappingRangeSliderIsTracking == NO) {
        [self setTransformedBySliderSnappingRange:nil];
    }
    [_cardView reflectObjectsDidRelayout];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a7591 @ 002a7591, 348 bytes * /

void FUN_002a7591(HSDropOffOptionsAssistansPane *self,SEL _cmd,id setDropOffTargetRewardSoundMedia)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  undefined *puVar3;
  
  pvVar1 = _objc_msgSend(self,sel_undoManager);
  pvVar2 = _objc_msgSend(self,sel_mutableSnappingAttributes);
  pvVar2 = _objc_msgSend(pvVar2,sel_playDropOffRewardSound);
  if ((char)pvVar2 == '\0') {
    pvVar2 = (id)0x0;
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_mutableSnappingAttributes);
    pvVar2 = _objc_msgSend(pvVar2,sel_dropOffRewardSoundMedia);
  }
  puVar3 = sel_setDropOffTargetRewardSoundMedia_;
  _objc_msgSend(pvVar1,sel_registerUndoWithTarget_selector_object_,self,
                sel_setDropOffTargetRewardSoundMedia_,pvVar2);
  pvVar1 = _objc_msgSend(self,sel_undoHelper);
  _objc_msgSend(pvVar1,sel_duplicateAction);
  pvVar1 = _objc_msgSend(self,sel_mutableSnappingAttributes);
  if (setDropOffTargetRewardSoundMedia == (id)0x0) {
    setDropOffTargetRewardSoundMedia = (id)0x0;
    op = sel_setPlayDropOffRewardSound_;
  }
  else {
    _objc_msgSend(pvVar1,sel_setPlayDropOffRewardSound_,1,puVar3,pvVar2);
    pvVar1 = _objc_msgSend(self,sel_mutableSnappingAttributes);
    op = sel_setDropOffRewardSoundMedia_;
  }
  _objc_msgSend(pvVar1,op,setDropOffTargetRewardSoundMedia);
  _objc_msgSend(self,sel_invalidatePreviewSoundObject);
  _objc_msgSend(self,sel_updateUI);
  return;
}

*/
- (void)setDropOffTargetRewardSoundMedia:(id)aMedia
{
    id previousMedia;

    if ([[self mutableSnappingAttributes] playDropOffRewardSound]) {
        previousMedia = [[self mutableSnappingAttributes] dropOffRewardSoundMedia];
    }
    else {
        previousMedia = nil;
    }
    [[self undoManager] registerUndoWithTarget:self selector:@selector(setDropOffTargetRewardSoundMedia:) object:previousMedia];
    [[self undoHelper] duplicateAction];
    if (aMedia == nil) {
        [[self mutableSnappingAttributes] setPlayDropOffRewardSound:NO];
    }
    else {
        [[self mutableSnappingAttributes] setPlayDropOffRewardSound:YES];
        [[self mutableSnappingAttributes] setDropOffRewardSoundMedia:aMedia];
    }
    [self invalidatePreviewSoundObject];
    [self updateUI];
}

- (void)setDropOffTargetSnapEnablingState:(id)aState
{
    id pvVar1;
    NSNumber *pvVar2_3;

    pvVar1 = [self undoManager];
    pvVar2_3 = [NSNumber numberWithBool:(unsigned int)[[self mutableSnappingAttributes] isDropOffSnappingEnabled] & 0xff];
    [pvVar1 registerUndoWithTarget:self selector:@selector(setDropOffTargetSnapEnablingState:) object:pvVar2_3];
    [[self undoHelper] duplicateAction];
    if (![aState boolValue]) {
        [_previewSoundObject stop];
    }
    [[self mutableSnappingAttributes] setIsDropOffSnappingEnabled:[aState boolValue]];
    [self updateUI];
}

- (void)lockAssistantIfNeeded
{
    id self_00;

    self_00 = [HSObjectAssistantController sharedAssistantController];
    if (![self_00 isLocked]) {
        [self_00 setLocked:YES delegate:self];
    }
}

- (void)unlockAssistantIfNeeded
{
    id self_00;

    self_00 = [HSObjectAssistantController sharedAssistantController];
    if ([self_00 isLocked]) {
        [self_00 setLocked:NO delegate:nil];
    }
}

- (id)lockedObjectAssistantController:(id)aController paneHistoryForObject:(id)aObject
{
    [self recreatePlaceObjectAssistantPaneWithKey:@"DropOffTargetCoaching"];
    return [NSArray arrayWithObject:_placeObjectAssisantPane];
}

- (void)recreatePlaceObjectAssistantPaneWithKey:(id)aKey
{
    id pvVar1_2;

    [_placeObjectAssisantPane setDelegate:0];
    [_placeObjectAssisantPane release];
    pvVar1_2 = [[HSDropOffPlaceObjectAssistantPane alloc] initWithCoachingKey:aKey];
    _placeObjectAssisantPane = pvVar1_2;
    [pvVar1_2 setDelegate:self];
    [_placeObjectAssisantPane setWindowTitle:[self windowTitle]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a7a18 @ 002a7a18, 715 bytes * /

id FUN_002a7a18(HSDropOffOptionsAssistansPane *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined4 *puVar4;
  undefined1 local_2c [28];
  
  puVar4 = (undefined4 *)&stack0xffffffa4;
  pvVar1 = _objc_msgSend(self,sel_imageMediaForAssistantObject);
  if (pvVar1 == (id)0x0) {
    pvVar1 = (id)0x0;
  }
  else {
    pvVar1 = _objc_msgSend(cls_HSImageObject,sel_alloc);
    _objc_msgSend(self,sel_imageMediaForAssistantObject);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithMedia_);
    _objc_msgSend(pvVar1,sel_setMedia_);
    self_00 = cls_NSString;
    pvVar2 = _objc_msgSend(self,sel_object);
    _objc_msgSend(pvVar2,sel_hyperName);
    pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_);
    _objc_msgSend(self_00,sel_stringWithFormat_);
    _objc_msgSend(pvVar1,sel_setHyperName_);
    _objc_msgSend(pvVar1,sel_setHyperOpacity_);
    pvVar2 = _objc_msgSend(pvVar1,sel_queryHyperInterface_);
    pvVar3 = _objc_msgSend(self,sel_object);
    pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_);
    _objc_msgSend_stret(local_2c,pvVar3,sel_affineTransform);
    puVar4 = (undefined4 *)&stack0xffffffa0;
    _objc_msgSend(pvVar3,sel_size);
    _objc_msgSend(pvVar2,sel_setSize_affineTransform_);
    _objc_msgSend(pvVar1,sel_setHidden_);
    _objc_msgSend(pvVar1,sel_setDropOffOnly_);
    pvVar2 = _objc_msgSend(pvVar1,sel_queryHyperInterface_);
    _objc_msgSend(pvVar2,sel_setIsDropOffTarget_);
    _objc_msgSend(pvVar2,sel_setIsDropOffSnappingEnabled_);
    _objc_msgSend(pvVar2,sel_setDropOffSnappingRange_);
  }
  puVar4[1] = sel_autorelease;
  *puVar4 = pvVar1;
  puVar4[-1] = 0x2a7cdb;
  pvVar1 = _objc_msgSend((id)*puVar4,(SEL)puVar4[1]);
  return pvVar1;
}

*/
- (id)createDropOffObject
{
    HSImageObject *target;
    id targetGeometry;
    id objectGeometry;
    id snapOptions;

    if ([self imageMediaForAssistantObject] == nil) {
        return nil;
    }
    target = [[HSImageObject alloc] initWithMedia:[self imageMediaForAssistantObject]];
    [target setMedia:[self imageMediaForAssistantObject]];
    [target setHyperName:[NSString stringWithFormat:[[NSBundle mainBundle] localizedStringForKey:@"Drop-off target name" value:@"" table:@"AssistantPanes"], [[self object] hyperName]]];
    [target setHyperOpacity:0.5];
    targetGeometry = [target queryHyperInterface:@protocol(HSGeometryAttributes)];
    objectGeometry = [[self object] queryHyperInterface:@protocol(HSGeometryAttributes)];
    [targetGeometry setSize:[(id<HSGeometryAttributes>)objectGeometry size] affineTransform:[objectGeometry affineTransform]];
    [target setHidden:YES];
    [target setDropOffOnly:YES];
    snapOptions = [target queryHyperInterface:@protocol(HSMutableSnapOptionsAttributes)];
    [snapOptions setIsDropOffTarget:YES];
    [snapOptions setIsDropOffSnappingEnabled:YES];
    [(id<HSMutableSnapOptionsAttributes>)snapOptions setDropOffSnappingRange:22];
    return [target autorelease];
}

- (id)imageMediaForAssistantObject
{
    return [HSNewMedia mediaWithImage:[[self object] imageForIPadExport]];
}

- (id)selectToolWithTag:(NSInteger)aTag
{
    [[HSToolManager sharedToolManager] selectToolWithTag:aTag setAsPermanent:YES forceSelection:YES];
    return [[HSToolManager sharedToolManager] currentTool];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a7db7 @ 002a7db7, 254 bytes * /

void FUN_002a7db7(HSDropOffOptionsAssistansPane *self,SEL _cmd,NSPoint setObjectPosition,id ofObject
                 )

{
  id pvVar1;
  id self_00;
  longdouble lVar2;
  longdouble lVar3;
  undefined4 local_1c;
  undefined4 local_18;
  
  pvVar1 = _objc_msgSend(ofObject,sel_queryHyperInterface_,&DAT_00389ccc);
  pvVar1 = _objc_msgSend(pvVar1,sel_queryGeometryBehaviorApplier);
  if (pvVar1 != (id)0x0) {
    _objc_msgSend(pvVar1,sel_moveCenterTo_withLayoutGuidingContext_,setObjectPosition.x,
                  setObjectPosition.y,0);
    self_00 = _objc_msgSend(pvVar1,sel_mutableGeometryAttributes);
    _objc_msgSend_stret(&local_1c,self_00,sel_frameBoundingRect);
    lVar2 = (longdouble)_roundf(local_1c);
    lVar3 = (longdouble)_roundf(local_18);
    _objc_msgSend(pvVar1,sel_moveFrameBoundingRectOriginTo_withLayoutGuidingContext_,(float)lVar2,
                  (float)lVar3,0);
  }
  return;
}

*/
- (void)setObjectPosition:(NSPoint)aPosition ofObject:(id)aObject
{
    id applier;
    NSRect frame;

    applier = [[aObject queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
    if (applier != nil) {
        [applier moveCenterTo:aPosition withLayoutGuidingContext:nil];
        frame = [[applier mutableGeometryAttributes] frameBoundingRect];
        [applier moveFrameBoundingRectOriginTo:NSMakePoint(roundf(frame.origin.x), roundf(frame.origin.y)) withLayoutGuidingContext:nil];
    }
}

- (void)updateUI
{
    BOOL bVar1;
    char cVar2;
    char cVar3;
    id pvVar4;
    NSUInteger pvVar6;
    id pcVar8;
    unsigned int uVar9;
    unsigned int uVar10;
    BOOL bVar11;
    id pvVar4_2;
    id pvVar4_5;
    id pvVar4_7;
    id pvVar5_2;
    id pvVar5_5;
    NSBundle *pvVar5_6;
    Class pvVar5_9;
    id pvVar5_10;
    BOOL pvVar6_3;
    unsigned int uVar9_2;

    pvVar4 = [self mutableSnappingAttributes];
    cVar2 = [pvVar4 isDropOffSnappingEnabled];
    pvVar5_2 = [self dropOffTarget];
    pvVar6 = [pvVar4 dropOffSnappingRange];
    [self setCurrentSnappingRange:[NSNumber numberWithInteger:pvVar6]];
    [_snapRangeStepper setIntValue:pvVar6];
    bVar11 = cVar2 != NO;
    [_snapCheckBox setState:(unsigned int)bVar11];
    bVar1 = pvVar5_2 != nil;
    uVar10 = (unsigned int)bVar1;
    [_snapCheckBox setEnabled:uVar10];
    uVar9 = (unsigned int)(bVar1 && bVar11);
    [_playAudioCheckBox setEnabled:uVar9];
    [self enableSnapRangeControls:uVar9];
    [_menuButton setHidden:pvVar5_2 == nil];
    [_createTargetButton setHidden:uVar10];
    cVar3 = [pvVar4 playDropOffRewardSound];
    uVar9_2 = (unsigned int)(cVar3 != NO && bVar11);
    [_playAudioCheckBox setState:cVar3 != NO];
    [_audioMediaNameBox setHyperEnabled:uVar9_2];
    pvVar5_5 = [[pvVar4 dropOffRewardSoundMedia] mediaName];
    if (pvVar5_5 == nil) {
        pvVar5_5 = [NSString string];
    }
    [_audioMediaNameTextField setStringValue:pvVar5_5];
    [_chooseAudioMediaButton setEnabled:(unsigned int)(pvVar5_5 != nil && (cVar3 != NO && cVar2 != NO))];
    pvVar5_6 = [NSBundle mainBundle];
    pvVar4_2 = [pvVar4 dropOffRewardSoundMedia];
    pcVar8 = @"Change";
    if (pvVar4_2 == nil) {
        pcVar8 = @"Choose";
    }
    [_chooseAudioMediaButton setTitle:[[pvVar5_6 localizedStringForKey:pcVar8 value:@"" table:@"AssistantPanes"] hyperStringByAddingEllipsis]];
    pvVar5_9 = [self class];
    [_playButtonCell setEnabled:((unsigned int)([self previewSoundObject] != nil && (cVar3 != NO && cVar2 != NO)))];
    pvVar6_3 = [self isPlaying];
    pvVar4_5 = _playButtonCell;
    if (!pvVar6_3) {
        [pvVar4_5 setImage:[pvVar5_9 playButtonImage]];
        [_playButtonCell setAquaAlternateImage:[pvVar5_9 playButtonAquaImage]];
        pvVar4_7 = _playButtonCell;
        pvVar5_10 = [pvVar5_9 playButtonGraphiteImage];
    }
    else {
        [pvVar4_5 setImage:[pvVar5_9 stopButtonImage]];
        [_playButtonCell setAquaAlternateImage:[pvVar5_9 stopButtonAquaImage]];
        pvVar4_7 = _playButtonCell;
        pvVar5_10 = [pvVar5_9 stopButtonGraphiteImage];
    }
    [pvVar4_7 setGraphiteAlternateImage:pvVar5_10];
}

- (void)setNilValueForKey:(id)aKey
{
    if (![aKey isEqualToString:@"currentSnapingRange"]) {
        [super setNilValueForKey:aKey];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a83ea @ 002a83ea, 178 bytes * /

void FUN_002a83ea(HSDropOffOptionsAssistansPane *self,SEL _cmd,BOOL enableSnapRangeControls)

{
  id self_00;
  id pvVar1;
  SEL op;
  int iVar2;
  int iVar3;
  
  iVar2 = (int)enableSnapRangeControls;
  _objc_msgSend(self->_slider,sel_setEnabled_,iVar2);
  _objc_msgSend(self->_snapRangeTextField,sel_setEnabled_,iVar2);
  iVar3 = iVar2;
  _objc_msgSend(self->_snapRangeStepper,sel_setEnabled_,iVar2);
  self_00 = self->_snapLabel;
  op = sel_disabledControlTextColor;
  if (iVar2 != 0) {
    op = sel_blackColor;
  }
  pvVar1 = _objc_msgSend(cls_NSColor,op,iVar3);
  _objc_msgSend(self_00,sel_setTextColor_,pvVar1);
  return;
}

*/
- (void)enableSnapRangeControls:(BOOL)aControls
{
    [_slider setEnabled:aControls];
    [_snapRangeTextField setEnabled:aControls];
    [_snapRangeStepper setEnabled:aControls];
    [_snapLabel setTextColor:aControls ? [NSColor blackColor] : [NSColor disabledControlTextColor]];
}

- (void)addDropOffObjectToCard:(id)aCard
{
    id self_00;

    self_00 = [self card];
    [aCard setTemporary:YES];
    [self_00 addHyperChild:aCard];
}

- (void)removeDropOffObjectFromCard:(id)aCard
{
    if (aCard != nil) {
        [[[self card] undoManager] disableUndoRegistration];
        [[self card] removeHyperChild:aCard];
        [[[self card] undoManager] enableUndoRegistration];
        [_cardView reflectObjectsDidRelayout];
    }
}

- (BOOL)assistantShouldBeKeyWindow
{
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a86a4 @ 002a86a4, 225 bytes * /

void FUN_002a86a4(HSDropOffOptionsAssistansPane *self,SEL _cmd,
                 id HSDropOffOptionsAssistantPane_cardsWillChange)

{
  id pvVar1;
  id pvVar2;
  cfstringStruct *pcVar3;
  
  pvVar1 = _objc_msgSend(HSDropOffOptionsAssistantPane_cardsWillChange,sel_userInfo);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_HSNodeChildrenForRemoval);
  pvVar2 = _objc_msgSend(HSDropOffOptionsAssistantPane_cardsWillChange,sel_userInfo);
  pcVar3 = &cfstr_HSNodeChildrenForAddition;
  pvVar2 = _objc_msgSend(pvVar2,sel_objectForKey_,&cfstr_HSNodeChildrenForAddition);
  pvVar2 = _objc_msgSend(pvVar2,sel_count);
  if (pvVar2 == (id)0x0) {
    pcVar3 = _objc_msgSend(self,sel_card,pcVar3);
    pvVar1 = _objc_msgSend(pvVar1,sel_containsObject_,pcVar3);
    if ((char)pvVar1 == '\0') {
      return;
    }
  }
  _objc_msgSend(self,sel_unlockAssistantIfNeeded,pcVar3);
  _objc_msgSend(self,sel_resetToolToDefault);
  return;
}

*/
- (void)HSDropOffOptionsAssistantPane_cardsWillChange:(id)aChange
{
    id removed;

    removed = [[aChange userInfo] objectForKey:@"HSNodeChildrenForRemoval"];
    if ([[[aChange userInfo] objectForKey:@"HSNodeChildrenForAddition"] count] == 0
        && ![removed containsObject:[self card]]) {
        return;
    }
    [self unlockAssistantIfNeeded];
    [self resetToolToDefault];
}

- (void)HSDropOffOptionsAssistantPane_currentCardWillChange:(id)aChange
{
    [self unlockAssistantIfNeeded];
    [self resetToolToDefault];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a87c1 @ 002a87c1, 449 bytes * /

void FUN_002a87c1(HSDropOffOptionsAssistansPane *self,SEL _cmd,
                 id HSDropOffOptionsAssistantPane_objectsWillChange)

{
  int iVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  undefined4 *puVar6;
  id pvVar7;
  undefined1 *puVar8;
  undefined4 uVar9;
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined1 local_50 [64];
  
  pvVar2 = _objc_msgSend(HSDropOffOptionsAssistantPane_objectsWillChange,sel_userInfo);
  pvVar2 = _objc_msgSend(pvVar2,sel_objectForKey_,&cfstr_HSNodeChildrenForRemoval);
  pvVar3 = _objc_msgSend(HSDropOffOptionsAssistantPane_objectsWillChange,sel_userInfo);
  pvVar3 = _objc_msgSend(pvVar3,sel_objectForKey_,&cfstr_HSNodeChildrenForAddition);
  local_74 = 0;
  local_70 = 0;
  local_6c = (int *)0x0;
  local_68 = 0;
  local_64 = 0;
  local_60 = 0;
  local_5c = 0;
  local_58 = 0;
  puVar8 = local_50;
  puVar6 = &local_74;
  uVar9 = 0x10;
  pvVar4 = _objc_msgSend(pvVar3,sel_countByEnumeratingWithState_objects_count_,puVar6,puVar8,0x10);
  if (pvVar4 != (id)0x0) {
    iVar1 = *local_6c;
    do {
      pvVar7 = (id)0x0;
      do {
        if (iVar1 != *local_6c) {
          _objc_enumerationMutation(pvVar3);
        }
        pvVar5 = _objc_msgSend(*(id *)(local_70 + (int)pvVar7 * 4),sel_isTemporary,puVar6,puVar8,
                               uVar9);
        if ((char)pvVar5 == '\0') goto LAB_002a894d;
        pvVar7 = (id)((int)pvVar7 + 1);
      } while (pvVar7 < pvVar4);
      puVar8 = local_50;
      puVar6 = &local_74;
      uVar9 = 0x10;
      pvVar4 = _objc_msgSend(pvVar3,sel_countByEnumeratingWithState_objects_count_,puVar6,puVar8,
                             0x10);
    } while (pvVar4 != (id)0x0);
  }
  puVar6 = _objc_msgSend(self,sel_object,puVar6,puVar8,uVar9);
  pvVar2 = _objc_msgSend(pvVar2,sel_containsObject_,puVar6);
  if ((char)pvVar2 != '\0') {
LAB_002a894d:
    _objc_msgSend(self,sel_unlockAssistantIfNeeded,puVar6);
    _objc_msgSend(self,sel_resetToolToDefault);
  }
  return;
}

*/
- (void)HSDropOffOptionsAssistantPane_objectsWillChange:(id)aChange
{
    id removed;
    id added;
    id child;

    removed = [[aChange userInfo] objectForKey:@"HSNodeChildrenForRemoval"];
    added = [[aChange userInfo] objectForKey:@"HSNodeChildrenForAddition"];
    for (child in added) {
        if (![child isTemporary]) {
            [self unlockAssistantIfNeeded];
            [self resetToolToDefault];
            return;
        }
    }
    if ([removed containsObject:[self object]]) {
        [self unlockAssistantIfNeeded];
        [self resetToolToDefault];
    }
}

- (void)HSDropOffOptionsAssistantPane_toolDidChange:(id)aChange
{
    if ([[HSToolManager sharedToolManager] selectedToolTag] != 0x36) {
        [self unlockAssistantIfNeeded];
        [[_cardView selection] removeAllNodes];
    }
}

- (void)HSDropOffOptionsAssistantPane_windowDidResignMain:(id)aMain
{
    NSDocument *pvVar1_2;

    pvVar1_2 = [[HSEditorController sharedDocumentController] currentDocument];
    if (pvVar1_2 != nil) {
        if (pvVar1_2 != [self document]) {
            [self unlockAssistantIfNeeded];
            [self resetToolToDefault];
            [self restoreSelectonAfterExit];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a8a98 @ 002a8a98, 369 bytes * /

void FUN_002a8a98(HSDropOffOptionsAssistansPane *self,SEL _cmd,id containerAttributeDidChange)

{
  id pvVar1;
  id pvVar2;
  cfstringStruct *pcVar3;
  id pvVar4;
  cfstringStruct *pcVar5;
  
  pvVar1 = _objc_msgSend(containerAttributeDidChange,sel_userInfo);
  pcVar3 = &cfstr_HSNodeChildrenForRemoval;
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_HSNodeChildrenForRemoval);
  pvVar1 = _objc_msgSend(pvVar1,sel_allObjects);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectEnumerator);
  while( true ) {
    pvVar4 = _objc_msgSend(pvVar1,sel_nextObject,pcVar3);
    if (pvVar4 == (id)0x0) break;
    pvVar2 = _objc_msgSend(self,sel_object);
    pvVar2 = _objc_msgSend(pvVar2,sel_hyperUID);
    pcVar3 = _objc_msgSend(pvVar4,sel_hyperUID);
    pvVar4 = _objc_msgSend(pvVar2,sel_isEqual_,pcVar3);
    if ((char)pvVar4 != '\0') {
      pvVar4 = _objc_msgSend(self,sel_object,pcVar3);
      pcVar3 = (cfstringStruct *)&DAT_003898a8;
      pvVar4 = _objc_msgSend(pvVar4,sel_queryHyperInterface_,&DAT_003898a8);
      pvVar4 = _objc_msgSend(pvVar4,sel_dropOffTargetUID);
      if ((pvVar4 == (id)0x0) && (pcVar5 = self->_dropOffTarget, pcVar5 != (cfstringStruct *)0x0)) {
        _objc_msgSend(self,sel_removeDropOffObjectFromCard_,pcVar5);
        pcVar3 = pcVar5;
      }
    }
    _objc_msgSend(self,sel_updateUI,pcVar3);
  }
  return;
}

*/
- (void)containerAttributeDidChange:(id)aChange
{
    NSEnumerator *enumerator;
    id child;

    enumerator = [[[[aChange userInfo] objectForKey:@"HSNodeChildrenForRemoval"] allObjects] objectEnumerator];
    while ((child = [enumerator nextObject]) != nil) {
        if ([[[self object] hyperUID] isEqual:[child hyperUID]]) {
            if ([[[self object] queryHyperInterface:@protocol(HSMutableSnappingTargetUIDIdentification)] dropOffTargetUID] == nil
                && _dropOffTarget != nil) {
                [self removeDropOffObjectFromCard:_dropOffTarget];
            }
        }
        [self updateUI];
    }
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    int uVar1;
    NSNotificationCenter *pvVar2_4;
    id pvVar2_6;

    [self applyChanges];
    [[self undoHelper] finishDuplicating:YES];
    [[self undoManager] removeAllActions];
    if ([self isHelpVisible]) {
        [self hideHelpNeedsRelayout:YES];
    }
    [super viewWillDisappear:aDisappear];
    [self invalidatePreviewSoundObject];
    pvVar2_4 = [NSNotificationCenter defaultCenter];
    [pvVar2_4 removeObserver:self name:@"HSActiveToolDidSelectionNotification" object:[HSToolManager sharedToolManager]];
    [pvVar2_4 removeObserver:self name:HSCurrentCardInCardViewWillChange object:_cardView];
    [pvVar2_4 removeObserver:self name:NSWindowDidResignMainNotification object:[_cardView window]];
    pvVar2_6 = [[self document] stack];
    uVar1 = HSActualWillAttributeChanges;
    [pvVar2_6 removeObserver:self selector:@selector(HSDropOffOptionsAssistantPane_cardsWillChange:) ofChanges:uVar1 ofAttribute:@protocol(HSNodeContainerChildrenAttribute)];
    [pvVar2_6 removeObserver:self selector:@selector(HSDropOffOptionsAssistantPane_objectsWillChange:) ofChanges:uVar1 ofChildrenAttribute:@protocol(HSNodeContainerChildrenAttribute)];
    [pvVar2_6 removeObserver:self selector:@selector(containerAttributeDidChange:) ofChanges:2 ofChildrenAttribute:@protocol(HSNodeContainerChildrenAttribute)];
    [self disableSnappingRangeRendererLayer];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a8ea3 @ 002a8ea3, 713 bytes * /

void FUN_002a8ea3(HSDropOffOptionsAssistansPane *self,SEL _cmd,BOOL viewWillAppear)

{
  undefined4 uVar1;
  id pvVar2;
  id pvVar3;
  double dVar4;
  HSDropOffOptionsAssistansPane *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSObjectAssistantPane_00356c60;
  _objc_msgSendSuper(&local_1c,sel_viewWillAppear_,(int)viewWillAppear);
  _objc_msgSend(self,sel_updateDropOffTarget);
  pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  pvVar3 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  _objc_msgSend(pvVar2,sel_addObserver_selector_name_object_,self,
                sel_HSDropOffOptionsAssistantPane_toolDidChange_,
                &cfstr_HSActiveToolDidSelectionNotification,pvVar3);
  _objc_msgSend(pvVar2,sel_addObserver_selector_name_object_,self,
                sel_HSDropOffOptionsAssistantPane_currentCardWillChange_,*(undefined4 *)PTR_00336a20
                ,self->_cardView);
  pvVar3 = _objc_msgSend(self->_cardView,sel_window);
  _objc_msgSend(pvVar2,sel_addObserver_selector_name_object_,self,
                sel_HSDropOffOptionsAssistantPane_windowDidResignMain_,*(undefined4 *)PTR_00336070,
                pvVar3);
  pvVar2 = _objc_msgSend(self,sel_document);
  pvVar2 = _objc_msgSend(pvVar2,sel_stack);
  uVar1 = *(undefined4 *)PTR_00336020;
  _objc_msgSend(pvVar2,sel_addObserver_selector_ofChanges_ofAttribute_withPriority_,self,
                sel_HSDropOffOptionsAssistantPane_cardsWillChange_,uVar1,&DAT_00389a4c,0xbe800000);
  _objc_msgSend(pvVar2,sel_addObserver_selector_ofChanges_ofChildrenAttribute_withPriority_,self,
                sel_HSDropOffOptionsAssistantPane_objectsWillChange_,uVar1,&DAT_00389a4c,0xbe800000)
  ;
  _objc_msgSend(pvVar2,sel_addObserver_selector_ofChanges_ofChildrenAttribute_withPriority_,self,
                sel_containerAttributeDidChange_,2,&DAT_00389a4c,0xbe800000);
  pvVar2 = _objc_msgSend(self,sel_maxSnappingRange);
  dVar4 = (double)(ZEXT48(pvVar2) | 0x4330000000000000) - 4503599627370496.0;
  _objc_msgSend(self->_slider,sel_setMaxValue_,dVar4);
  _objc_msgSend(self->_snapRangeStepper,sel_setMaxValue_,dVar4);
  _objc_msgSend(self,sel_enableSnappingRangeRendererLayer);
  _objc_msgSend(self,sel_updateUI);
  return;
}

*/
- (void)viewWillAppear:(BOOL)aAppear
{
    NSNotificationCenter *center;
    id stack;
    double maxRange;

    [super viewWillAppear:aAppear];
    [self updateDropOffTarget];
    center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(HSDropOffOptionsAssistantPane_toolDidChange:) name:@"HSActiveToolDidSelectionNotification" object:[HSToolManager sharedToolManager]];
    [center addObserver:self selector:@selector(HSDropOffOptionsAssistantPane_currentCardWillChange:) name:HSCurrentCardInCardViewWillChange object:_cardView];
    [center addObserver:self selector:@selector(HSDropOffOptionsAssistantPane_windowDidResignMain:) name:NSWindowDidResignMainNotification object:[_cardView window]];
    stack = [[self document] stack];
    [stack addObserver:self selector:@selector(HSDropOffOptionsAssistantPane_cardsWillChange:) ofChanges:HSActualWillAttributeChanges ofAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:-0.25];
    [stack addObserver:self selector:@selector(HSDropOffOptionsAssistantPane_objectsWillChange:) ofChanges:HSActualWillAttributeChanges ofChildrenAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:-0.25];
    [stack addObserver:self selector:@selector(containerAttributeDidChange:) ofChanges:2 ofChildrenAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:-0.25];
    maxRange = (double)[self maxSnappingRange];
    [_slider setMaxValue:maxRange];
    [_snapRangeStepper setMaxValue:maxRange];
    [self enableSnappingRangeRendererLayer];
    [self updateUI];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a916c @ 002a916c, 104 bytes * /

void FUN_002a916c(HSDropOffOptionsAssistansPane *self,SEL _cmd)

{
  _objc_msgSend(cls_NSObject,sel_cancelPreviousPerformRequestsWithTarget_,self);
  _objc_msgSend(self,sel_performSelector_withObject_afterDelay_,
                sel_disableSnappingRangeRendererLayerAndSetNeedsDisplay,0,0,0x3fe00000);
  return;
}

*/
- (void)disableSnappingRangeRendererLayerDelayed
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(disableSnappingRangeRendererLayerAndSetNeedsDisplay) withObject:nil afterDelay:0.5];
}

- (void)disableSnappingRangeRendererLayerAndSetNeedsDisplay
{
    [self disableSnappingRangeRendererLayer];
    [_cardView reflectObjectsDidRelayout];
}

- (void)disableSnappingRangeRendererLayer
{
    if (_snappingRangeRenderingLayer != nil) {
        [[[_cardView rootCanvasLayer] arrowToolCanvasLayer] removeSublayer:_snappingRangeRenderingLayer];
        [_snappingRangeRenderingLayer release];
        _snappingRangeRenderingLayer = nil;
    }
    [_cardView reflectObjectsDidRelayout];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a92ae @ 002a92ae, 365 bytes * /

void FUN_002a92ae(HSDropOffOptionsAssistansPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  undefined *puVar3;
  
  pvVar1 = _objc_msgSend(self,sel_dropOffTarget);
  puVar3 = &DAT_00389a38;
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00389a38);
  pvVar1 = _objc_msgSend(pvVar1,sel_isDropOffSnappingEnabled);
  if (((char)pvVar1 != '\0') && (self->_snappingRangeRenderingLayer == (id)0x0)) {
    pvVar1 = _objc_msgSend(self->_cardView,sel_rootCanvasLayer,puVar3);
    pvVar1 = _objc_msgSend(pvVar1,sel_arrowToolCanvasLayer);
    pvVar2 = _objc_msgSend(cls_HSGenericItemsCanvasSublayer,sel_alloc);
    pvVar2 = _objc_msgSend(pvVar2,sel_init);
    self->_snappingRangeRenderingLayer = pvVar2;
    pvVar2 = _objc_msgSend(cls_HSSnappingRangeCanvasItem,sel_alloc);
    pvVar2 = _objc_msgSend(pvVar2,sel_init);
    pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
    _objc_msgSend(pvVar2,sel_setDelegate_,self);
    _objc_msgSend(self->_snappingRangeRenderingLayer,sel_addCanvasItem_,pvVar2);
    puVar3 = self->_snappingRangeRenderingLayer;
    _objc_msgSend(pvVar1,sel_addSublayer_,puVar3);
  }
  _objc_msgSend(self->_cardView,sel_reflectObjectsDidRelayout,puVar3);
  return;
}

*/
- (void)enableSnappingRangeRendererLayer
{
    id arrowToolLayer;
    HSSnappingRangeCanvasItem *item;

    if ([[[self dropOffTarget] queryHyperInterface:@protocol(HSMutableSnapOptionsAttributes)] isDropOffSnappingEnabled]
        && _snappingRangeRenderingLayer == nil) {
        arrowToolLayer = [[_cardView rootCanvasLayer] arrowToolCanvasLayer];
        _snappingRangeRenderingLayer = [[HSGenericItemsCanvasSublayer alloc] init];
        item = [[[HSSnappingRangeCanvasItem alloc] init] autorelease];
        [item setDelegate:self];
        [_snappingRangeRenderingLayer addCanvasItem:item];
        [arrowToolLayer addSublayer:_snappingRangeRenderingLayer];
    }
    [_cardView reflectObjectsDidRelayout];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a941b @ 002a941b, 371 bytes * /

void FUN_002a941b(HSDropOffOptionsAssistansPane *self,SEL _cmd)

{
  id pvVar1;
  HSDropOffOptionsAssistansPane *self_00;
  id pvVar2;
  id pvVar3;
  HSDropOffOptionsAssistansPane *self_01;
  SEL op;
  undefined *puVar4;
  
  pvVar1 = _objc_msgSend(self,sel_object);
  self_00 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_003898a8);
  pvVar1 = _objc_msgSend(self_00,sel_dropOffTargetUID);
  pvVar2 = _objc_msgSend(self,sel_object);
  pvVar2 = _objc_msgSend(pvVar2,sel_card);
  pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_003898d0);
  pvVar1 = _objc_msgSend(pvVar2,sel_childInTreeWithUID_,pvVar1);
  puVar4 = &DAT_003898f8;
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_003898f8);
  self_01 = self;
  op = sel_setDropOffTarget_;
  if (pvVar1 == (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_card,puVar4);
    pvVar3 = _objc_msgSend(pvVar2,sel_children);
    pvVar2 = self->_dropOffTarget;
    pvVar3 = _objc_msgSend(pvVar3,sel_containsObject_,pvVar2);
    op = sel_setDropOffTarget_;
    if ((char)pvVar3 != '\0') {
      pvVar1 = _objc_msgSend(self->_dropOffTarget,sel_hyperUID,pvVar2);
      self_01 = self_00;
      op = sel_setDropOffTargetUID_;
    }
  }
  _objc_msgSend(self_01,op,pvVar1);
  _objc_msgSend(self,sel_updateUI);
  return;
}

*/
- (BOOL)shouldEnableOKButtonInNavigationPaneSwitcher:(id)aSwitcher
{
    return YES;
}

- (void)HSDropOffOptionsAssistantPane_windowWillClose:(id)aClose
{
    if ([aClose object] == [_cardView window]) {
        [self unlockAssistantIfNeeded];
        if ([[HSToolManager sharedToolManager] selectedToolTag] == 0x36) {
            [self resetToolToDefault];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002a962b @ 002a962b, 504 bytes * /

void FUN_002a962b(HSDropOffOptionsAssistansPane *self,SEL _cmd,id setCardView)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  HSDropOffOptionsAssistansPane *pHVar6;
  undefined4 uVar7;
  
  if (self->_cardView != setCardView) {
    pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    pvVar3 = _objc_msgSend(self->_cardView,sel_window);
    puVar1 = PTR_00336584;
    uVar7 = *(undefined4 *)PTR_00336584;
    pHVar6 = self;
    _objc_msgSend(pvVar2,sel_removeObserver_name_object_,self,uVar7,pvVar3);
    _objc_msgSend(self->_cardView,sel_release);
    pvVar2 = _objc_msgSend(setCardView,sel_retain);
    self->_cardView = pvVar2;
    if (pvVar2 != (id)0x0) {
      pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter,pHVar6,uVar7,pvVar3);
      pvVar3 = _objc_msgSend(self->_cardView,sel_window);
      _objc_msgSend(pvVar2,sel_addObserver_selector_name_object_,self,
                    sel_HSDropOffOptionsAssistantPane_windowWillClose_,*(undefined4 *)puVar1,pvVar3)
      ;
      _objc_msgSend(self->_undoHelper,sel_finishDuplicating_,0);
      _objc_msgSend(self->_undoHelper,sel_release);
      pvVar2 = _objc_msgSend(cls_HSEditModeUndoHelper,sel_alloc);
      pvVar3 = _objc_msgSend(self,sel_undoManager);
      pvVar4 = _objc_msgSend(self,sel_document);
      pvVar4 = _objc_msgSend(pvVar4,sel_undoManager);
      pvVar5 = _objc_msgSend(self,sel_document);
      pvVar2 = _objc_msgSend(pvVar2,
                             sel_initWithDocument_documentUndoManager_editModeUndoManager_delegate_,
                             pvVar5,pvVar4,pvVar3,self);
      self->_undoHelper = pvVar2;
    }
  }
  return;
}

*/
- (void)setCardView:(id)aView
{
    if (_cardView != aView) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillCloseNotification object:[_cardView window]];
        [_cardView release];
        _cardView = [aView retain];
        if (_cardView != nil) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSDropOffOptionsAssistantPane_windowWillClose:) name:NSWindowWillCloseNotification object:[_cardView window]];
            [_undoHelper finishDuplicating:NO];
            [_undoHelper release];
            _undoHelper = [[HSEditModeUndoHelper alloc] initWithDocument:[self document] documentUndoManager:[[self document] undoManager] editModeUndoManager:[self undoManager] delegate:self];
        }
    }
}

- (id)undoManager
{
    id pvVar1;

    pvVar1 = _undoManager;
    if (pvVar1 == nil) {
        pvVar1 = [HSUndoManager new];
        _undoManager = pvVar1;
    }
    return pvVar1;
}

- (void)setNavigationController:(id)aController
{
    _navigationController = aController;
}

- (id)document
{
    return [[self card] document];
}

- (id)card
{
    return [_cardView card];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_menuButton setMenu:_dropOffTargetMenu];
    [_menuButton setTitle:@"Drop-Off Target 1"];
    [_slider setDelegate:self];
    [_snapRangeStepper setDelegate:self];
}

- (id)navigationPaneSwitcher
{
    HSObjectAssistantNavigationPaneSwitcher *pHVar1;
    HSObjectAssistantNavigationPaneSwitcher *pHVar1_2;

    pHVar1 = _paneSwitcher;
    if (pHVar1 == nil) {
        pHVar1_2 = [HSNBAAssistantNavigationPaneSwitcher new];
        _paneSwitcher = pHVar1_2;
        [pHVar1_2 setDelegate:self];
        pHVar1 = _paneSwitcher;
    }
    return pHVar1;
}

- (void)setObject:(id)aObject
{
    id pvVar1;

    [super setObject:aObject];
    if (aObject != nil) {
        [self updateDropOffTarget];
        [_initialDropOffTarget release];
        _initialDropOffTarget = nil;
        pvVar1 = [self dropOffTarget];
        if (pvVar1 != nil) {
            pvVar1 = [[self dropOffTarget] copy];
            _initialDropOffTarget = pvVar1;
        }
    }
}

- (id)assistantPaneUndoManager
{
    return [self undoManager];
}

- (void)dealloc
{
    [self resetToolToDefault];
    [self disableSnappingRangeRendererLayer];
    [_slider setDelegate:0];
    [_snapRangeStepper setDelegate:0];
    [_paneSwitcher release];
    [_placeObjectAssisantPane setDelegate:0];
    [_placeObjectAssisantPane release];
    [_undoHelper finishDuplicating:NO];
    [_undoHelper release];
    [_undoManager release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_dropOffTarget release];
    [_initialDropOffTarget release];
    [_cardView release];
    [self invalidatePreviewSoundObject];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"DropOffOptionsAssistantPane"];
    return self;
}

- (void)deleteDropOffTargetAction:(id)aAction
{
    [self deleteDropOffTargetActionWithObject:[self dropOffTarget]];
}

@end

