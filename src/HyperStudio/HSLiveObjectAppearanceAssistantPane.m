#import "HSLiveObjectAppearanceAssistantPane.h"

@implementation HSLiveObjectAppearanceAssistantPane

/* i386 ivar offsets: _nameTextField=0x5c, _playButton=0x60, _cameraListPopUp=0x64, _groupView=0x68, _shadowSwitch=0x6c, _shadowButton=0x70, _opacitySlider=0x74, _opacityTextField=0x78, _opacityStepper=0x7c, _mirrorSwitch=0x80, _playImage=0x84, _stopImage=0x88, _pressedPlayImage=0x8c, _pressedStopImage=0x90, _captureDeviceList=0x94, _selectedCaptureDevice=0x98 */

- (void)setOriginalObjectOpacity:(CGFloat)aOpacity
{
    [[self opacityAttributes] setHyperOpacity:aOpacity];
}

- (void)updateOpacity:(CGFloat)aOpacity
{
    float fVar1;

    fVar1 = aOpacity * 100.0;
    [_opacitySlider setFloatValue:fVar1];
    [_opacityTextField setFloatValue:fVar1];
    [_opacityStepper setFloatValue:fVar1];
}

- (void)updateMirror
{
    [_mirrorSwitch setState:[[self geometryAttributes] isFlippedHorizontally]];
}

- (void)updateShadow
{
    char cVar1;
    NSString *pcVar3;

    cVar1 = [[self shadowAttributes] isHyperShadowEnabled];
    [_shadowSwitch setState:cVar1];
    [_shadowButton setHidden:((unsigned int)(cVar1 == NO))];
    if (cVar1 == NO) {
        pcVar3 = [_shadowButton title];
    }
    else {
        pcVar3 = @"";
    }
    [_shadowSwitch setTitle:pcVar3];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0016fdb6 @ 0016fdb6, 544 bytes * /

void FUN_0016fdb6(HSLiveObjectAppearanceAssistantPane *self,SEL _cmd)

{
  char cVar1;
  id pvVar2;
  undefined *puVar3;
  undefined *puVar4;
  id self_00;
  id pvVar5;
  id pvVar6;
  SEL op;
  
  pvVar2 = _objc_msgSend(self,sel_assistant);
  pvVar2 = _objc_msgSend(pvVar2,sel_object);
  puVar3 = &DAT_003755d8;
  pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_003755d8);
  if (pvVar2 != (id)0x0) {
    pvVar6 = self->_nameTextField;
    puVar3 = _objc_msgSend(pvVar2,sel_hyperName,puVar3);
    _objc_msgSend(pvVar6,sel_setStringValue_,puVar3);
  }
  pvVar2 = _objc_msgSend(self->_captureDeviceList,sel_captureDeviceCount,puVar3);
  if (pvVar2 == (id)0x0) goto LAB_0016ff7a;
  pvVar2 = _objc_msgSend(self,sel_liveObjectAttributes,puVar3);
  puVar4 = _objc_msgSend(pvVar2,sel_hyperDeviceIndex);
  pvVar2 = _objc_msgSend(self->_cameraListPopUp,sel_numberOfItems);
  if ((int)puVar4 < (int)pvVar2) {
    _objc_msgSend(self->_cameraListPopUp,sel_selectItemAtIndex_,puVar4);
    puVar3 = puVar4;
  }
  pvVar2 = _objc_msgSend(self->_cameraListPopUp,sel_selectedItem,puVar3);
  self_00 = _objc_msgSend(pvVar2,sel_representedObject);
  pvVar6 = self_00;
  _objc_msgSend(self,sel_HSLiveObjectAppearanceAssistantPane_updateSelectedCaptureDevice_,self_00);
  pvVar2 = self->_playButton;
  pvVar5 = _objc_msgSend(self,sel_playableObjectAttributes);
  if (((pvVar5 == (id)0x0) || (self_00 == (id)0x0)) ||
     (pvVar6 = _objc_msgSend(self_00,sel_QTE_isInUseByAnotherApplication,pvVar6),
     (char)pvVar6 != '\0')) {
LAB_0016ff5c:
    cVar1 = '\0';
  }
  else {
    pvVar6 = _objc_msgSend(self_00,sel_attributeForKey_,*(undefined4 *)PTR_00336400);
    pvVar6 = _objc_msgSend(pvVar6,sel_boolValue);
    if ((char)pvVar6 != '\0') goto LAB_0016ff5c;
    cVar1 = '\x01';
  }
  puVar3 = (undefined *)(int)cVar1;
  _objc_msgSend(pvVar2,sel_setEnabled_,puVar3);
LAB_0016ff7a:
  pvVar2 = _objc_msgSend(self,sel_playableObjectAttributes,puVar3);
  pvVar2 = _objc_msgSend(pvVar2,sel_isHyperPlaying);
  op = sel_setUpPlayButton;
  if ((char)pvVar2 != '\0') {
    op = sel_setUpStopButton;
  }
  _objc_msgSend(self,op,puVar3);
  _objc_msgSend(self,sel_updateMirror);
  return;
}

*/
- (void)validateUI
{
    id objectAttributes = [[[self assistant] object] queryHyperInterface:@protocol(HSMutableObjectAttributes)];
    if (objectAttributes != nil) {
        [_nameTextField setStringValue:[objectAttributes hyperName]];
    }
    if ([_captureDeviceList captureDeviceCount] != 0) {
        NSInteger deviceIndex = [[self liveObjectAttributes] hyperDeviceIndex];
        if (deviceIndex < [_cameraListPopUp numberOfItems]) {
            [_cameraListPopUp selectItemAtIndex:deviceIndex];
        }
        id device = [[_cameraListPopUp selectedItem] representedObject];
        [self HSLiveObjectAppearanceAssistantPane_updateSelectedCaptureDevice:device];
        BOOL enabled = NO;
        if ([self playableObjectAttributes] != nil && device != nil
            && ![device QTE_isInUseByAnotherApplication]
            && ![[device attributeForKey:QTCaptureDeviceSuspendedAttribute] boolValue]) {
            enabled = YES;
        }
        [_playButton setEnabled:enabled];
    }
    if ([[self playableObjectAttributes] isHyperPlaying]) {
        [self setUpStopButton];
    } else {
        [self setUpPlayButton];
    }
    [self updateMirror];
}

- (void)validateMirrorWithNotification:(id)aNotification
{
    [self updateMirror];
}

- (void)validateOpacityAttributesWithNotification:(id)aNotification
{
    [self updateOpacity:(float)[[self opacityAttributes] hyperOpacity]];
}

- (void)validateShadowAttributesWithNotification:(id)aNotification
{
    [self updateShadow];
}

- (void)validateUIWithNotification:(id)aNotification
{
    [self validateUI];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0016fcb1 @ 0016fcb1, 147 bytes * /

void FUN_0016fcb1(HSLiveObjectAppearanceAssistantPane *self,SEL _cmd,id observeValueForKeyPath,
                 id ofObject,id change,void *context)

{
  id pvVar1;
  
  if (self->_selectedCaptureDevice == ofObject) {
    pvVar1 = _objc_msgSend(observeValueForKeyPath,sel_isEqualToString_,
                           &cfstr_inUseByAnotherApplication);
    if (((char)pvVar1 == '\0') &&
       (pvVar1 = _objc_msgSend(observeValueForKeyPath,sel_isEqualToString_,&cfstr_suspended),
       (char)pvVar1 == '\0')) {
      return;
    }
    _objc_msgSend(self,sel_performSelectorOnMainThread_withObject_waitUntilDone_,
                  sel_HSLiveObjectAppearanceAssistantPane_captureDeviceDidChangeState_,ofObject,0);
  }
  return;
}

*/
- (void)observeValueForKeyPath:(id)aPath ofObject:(id)aObject change:(id)aChange context:(void *)aContext
{
    if (_selectedCaptureDevice == aObject) {
        if ([aPath isEqualToString:@"inUseByAnotherApplication"] || [aPath isEqualToString:@"suspended"]) {
            [self performSelectorOnMainThread:@selector(HSLiveObjectAppearanceAssistantPane_captureDeviceDidChangeState:) withObject:aObject waitUntilDone:NO];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0016fc06 @ 0016fc06, 171 bytes * /

void FUN_0016fc06(HSLiveObjectAppearanceAssistantPane *self,SEL _cmd,
                 id HSLiveObjectAppearanceAssistantPane_captureDeviceDidChangeState)

{
  id self_00;
  char cVar1;
  id pvVar2;
  
  if (self->_selectedCaptureDevice !=
      HSLiveObjectAppearanceAssistantPane_captureDeviceDidChangeState) {
    return;
  }
  self_00 = self->_playButton;
  pvVar2 = _objc_msgSend(self,sel_playableObjectAttributes);
  if ((pvVar2 != (id)0x0) &&
     (pvVar2 = _objc_msgSend(HSLiveObjectAppearanceAssistantPane_captureDeviceDidChangeState,
                             sel_QTE_isInUseByAnotherApplication), (char)pvVar2 == '\0')) {
    pvVar2 = _objc_msgSend(HSLiveObjectAppearanceAssistantPane_captureDeviceDidChangeState,
                           sel_attributeForKey_,*(undefined4 *)PTR_00336400);
    pvVar2 = _objc_msgSend(pvVar2,sel_boolValue);
    if ((char)pvVar2 == '\0') {
      cVar1 = '\x01';
      goto LAB_0016fc90;
    }
  }
  cVar1 = '\0';
LAB_0016fc90:
  _objc_msgSend(self_00,sel_setEnabled_,(int)cVar1);
  return;
}

*/
- (void)HSLiveObjectAppearanceAssistantPane_captureDeviceDidChangeState:(id)aState
{
    if (_selectedCaptureDevice != aState) {
        return;
    }
    BOOL enabled = NO;
    if ([self playableObjectAttributes] != nil && ![aState QTE_isInUseByAnotherApplication]
        && ![[aState attributeForKey:QTCaptureDeviceSuspendedAttribute] boolValue]) {
        enabled = YES;
    }
    [_playButton setEnabled:enabled];
}

- (void)setMirror:(id)aMirror
{
    NSInteger pvVar1;
    BOOL uVar3;
    id pvVar2_4;

    pvVar1 = [aMirror state];
    pvVar2_4 = [[[[self assistant] object] queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
    if (pvVar1 == 0) {
        uVar3 = 0;
    }
    else {
        if (pvVar1 != 0x1) {
            return;
        }
        uVar3 = 1;
    }
    [pvVar2_4 setFlippedHorizontally:uVar3 withLayoutGuidingContext:nil];
}

- (void)opacityChanged:(id)aChanged
{
    [self setOriginalObjectOpacity:(float)[aChanged floatValue] / 100.0];
}

- (void)editShadow:(id)aShadow
{
    [self showShadowPane];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0016fa4c @ 0016fa4c, 201 bytes * /

void FUN_0016fa4c(HSLiveObjectAppearanceAssistantPane *self,SEL _cmd,id setShadow)

{
  id pvVar1;
  SEL op;
  undefined4 uVar2;
  
  pvVar1 = _objc_msgSend(setShadow,sel_state);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_shadowAttributes);
    uVar2 = 0;
    op = sel_setHyperShadowEnabled_;
  }
  else {
    if (pvVar1 != (id)0x1) {
      return;
    }
    pvVar1 = _objc_msgSend(self,sel_shadowAttributes);
    _objc_msgSend(pvVar1,sel_setHyperShadowEnabled_,1);
    _objc_msgSend(self->_shadowButton,sel_setHidden_,0);
    pvVar1 = self->_shadowButton;
    uVar2 = 1;
    op = sel_setEnabled_;
  }
  _objc_msgSend(pvVar1,op,uVar2);
  return;
}

*/
- (void)setShadow:(id)aShadow
{
    NSInteger state = [aShadow state];
    if (state == 0) {
        [[self shadowAttributes] setHyperShadowEnabled:NO];
    } else if (state == 1) {
        [[self shadowAttributes] setHyperShadowEnabled:YES];
        [_shadowButton setHidden:NO];
        [_shadowButton setEnabled:YES];
    }
}

- (void)showShadowPane
{
    id pvVar1_2;
    id pvVar1_3;

    pvVar1_2 = [[HSTextShadowAssistantPane new] autorelease];
    pvVar1_3 = [[HSObjectAssistantNavigationController alloc] initWithRootViewController:pvVar1_2];
    [self presentModalViewController:pvVar1_3 animated:YES];
    [pvVar1_3 release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0016f91e @ 0016f91e, 138 bytes * /

void FUN_0016f91e(HSLiveObjectAppearanceAssistantPane *self,SEL _cmd,id playInEditor)

{
  id self_00;
  id pvVar1;
  SEL op;
  
  self_00 = _objc_msgSend(self,sel_playableObjectAttributes);
  pvVar1 = _objc_msgSend(self_00,sel_isHyperPlaying);
  if ((char)pvVar1 == '\0') {
    _objc_msgSend(self,sel_setUpStopButton);
    op = sel_hyperStart_;
  }
  else {
    _objc_msgSend(self,sel_setUpPlayButton);
    op = sel_hyperStop;
  }
  _objc_msgSend(self_00,op);
  return;
}

*/
- (void)playInEditor:(id)aEditor
{
    id playable = [self playableObjectAttributes];
    if ([playable isHyperPlaying]) {
        [self setUpPlayButton];
        [playable hyperStop];
    } else {
        [self setUpStopButton];
        [playable hyperStart:self];
    }
}

- (void)cameraListChanged:(id)aChanged
{
    NSMenuItem *pvVar1;

    pvVar1 = [aChanged selectedItem];
    [[self liveObjectAttributes] setHyperDeviceIndex:[aChanged indexOfItem:pvVar1]];
    [self HSLiveObjectAppearanceAssistantPane_updateSelectedCaptureDevice:[pvVar1 representedObject]];
}

- (void)setName:(id)aName
{
    [[[[self assistant] object] queryHyperInterface:@protocol(HSMutableObjectAttributes)] setHyperName:[aName stringValue]];
}

- (void)setUpStopButton
{
    [_playButton setImage:_stopImage];
    [_playButton setAlternateImage:_pressedStopImage];
}

- (void)setUpPlayButton
{
    [_playButton setImage:_playImage];
    [_playButton setAlternateImage:_pressedPlayImage];
}

- (void)HSLiveObjectAppearanceAssistantPane_captureDeviceListDidUpdate:(id)aUpdate
{
    [self HSLiveObjectAppearanceAssistantPane_cameraListPopUpDidUpdate];
    [self validateUI];
}

- (id)opacityAttributes
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSMutableOpacityAttributes)];
}

- (id)geometryAttributes
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSGeometryAttributes)];
}

- (id)shadowAttributes
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSMutableShadowAttributes)];
}

- (id)playableObjectAttributes
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSPlayableObjectAttributes)];
}

- (id)liveObjectAttributes
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSLiveObjectAttributes)];
}

- (id)nameTextfField
{
    return _nameTextField;
}

- (id)initialKeyView
{
    return _nameTextField;
}

- (BOOL)isEditingTextAttribute
{
    BOOL bVar2;

    if ([_nameTextField currentEditor] == nil) {
        bVar2 = [_opacityTextField currentEditor] != nil;
    }
    else {
        bVar2 = YES;
    }
    return bVar2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00170350 @ 00170350, 928 bytes * /

void FUN_00170350(HSLiveObjectAppearanceAssistantPane *self,SEL _cmd,BOOL viewWillDisappear)

{
  id pvVar1;
  id pvVar2;
  undefined4 uVar3;
  undefined4 uVar4;
  HSLiveObjectAppearanceAssistantPane *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSObjectAssistantPane_00352370;
  _objc_msgSendSuper(&local_1c,sel_viewWillDisappear_,(int)viewWillDisappear);
  pvVar1 = _objc_msgSend(self,sel_playableObjectAttributes);
  _objc_msgSend(pvVar1,sel_hyperStop);
  pvVar1 = (id)0x0;
  _objc_msgSend(self,sel_HSLiveObjectAppearanceAssistantPane_updateSelectedCaptureDevice_,0);
  if (self->_captureDeviceList != (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter,pvVar1);
    _objc_msgSend(pvVar1,sel_removeObserver_name_object_,self,
                  &cfstr_HSCaptureDeviceListDidUpdateNotification,self->_captureDeviceList);
    pvVar2 = self->_captureDeviceList;
    pvVar1 = _objc_msgSend(self->_cameraListPopUp,sel_menu);
    _objc_msgSend(pvVar2,sel_detachMenu_,pvVar1);
    _objc_msgSend(self->_captureDeviceList,sel_release);
    self->_captureDeviceList = (id)0x0;
  }
  pvVar1 = _objc_msgSend(self,sel_assistant,pvVar1);
  pvVar1 = _objc_msgSend(pvVar1,sel_object);
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_003755d8);
  pvVar2 = _objc_msgSend(self,sel_opacityAttributes);
  pvVar2 = _objc_msgSend(pvVar2,sel_attributeObservingController);
  uVar3 = *(undefined4 *)PTR_0033601c;
  _objc_msgSend(pvVar2,sel_removeObserver_selector_ofChanges_ofAttributesOfHyperInterface_,self,
                sel_validateOpacityAttributesWithNotification_,uVar3,&DAT_003755b0,pvVar1,uVar3);
  pvVar2 = _objc_msgSend(self,sel_geometryAttributes);
  pvVar2 = _objc_msgSend(pvVar2,sel_attributeObservingController);
  _objc_msgSend(pvVar2,sel_removeObserver_selector_ofChanges_ofAttributesOfHyperInterface_,self,
                sel_validateMirrorWithNotification_,uVar3,&DAT_003753a8);
  pvVar1 = _objc_msgSend(pvVar1,sel_attributeObservingController);
  uVar4 = uVar3;
  _objc_msgSend(pvVar1,sel_removeObserver_selector_ofChanges_ofAttributesOfHyperInterface_,self,
                sel_validateUIWithNotification_,uVar3,&DAT_003755d8);
  pvVar1 = _objc_msgSend(self,sel_liveObjectAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_attributeObservingController);
  _objc_msgSend(pvVar1,sel_removeObserver_selector_ofChanges_ofAttributesOfHyperInterface_,self,
                sel_validateUIWithNotification_,uVar3,&DAT_003751f0);
  pvVar1 = _objc_msgSend(self,sel_playableObjectAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_attributeObservingController);
  _objc_msgSend(pvVar1,sel_removeObserver_selector_ofChanges_ofAttribute_,self,
                sel_validateUIWithNotification_,uVar4,&DAT_003756b4);
  pvVar1 = _objc_msgSend(self,sel_shadowAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_attributeObservingController);
  _objc_msgSend(pvVar1,sel_removeObserver_selector_ofChanges_ofAttributesOfHyperInterface_,self,
                sel_validateShadowAttributesWithNotification_,uVar4,&DAT_00375308);
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar1,sel_removeObserver_,self);
  return;
}

*/
- (void)viewWillDisappear:(BOOL)aDisappear
{
    [super viewWillDisappear:aDisappear];
    [[self playableObjectAttributes] hyperStop];
    [self HSLiveObjectAppearanceAssistantPane_updateSelectedCaptureDevice:nil];
    if (_captureDeviceList != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSCaptureDeviceListDidUpdateNotification" object:_captureDeviceList];
        [_captureDeviceList detachMenu:[_cameraListPopUp menu]];
        [_captureDeviceList release];
        _captureDeviceList = nil;
    }
    id objectAttributes = [[[self assistant] object] queryHyperInterface:@protocol(HSMutableObjectAttributes)];
    [[[self opacityAttributes] attributeObservingController] removeObserver:self selector:@selector(validateOpacityAttributesWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSOpacityAttributes)];
    [[[self geometryAttributes] attributeObservingController] removeObserver:self selector:@selector(validateMirrorWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSGeometryAttributes)];
    [[objectAttributes attributeObservingController] removeObserver:self selector:@selector(validateUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSMutableObjectAttributes)];
    [[[self liveObjectAttributes] attributeObservingController] removeObserver:self selector:@selector(validateUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSLiveObjectAttributes)];
    [[[self playableObjectAttributes] attributeObservingController] removeObserver:self selector:@selector(validateUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSPlayingVideoStateAttribute)];
    [[[self shadowAttributes] attributeObservingController] removeObserver:self selector:@selector(validateShadowAttributesWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSShadowAttributes)];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001706f0 @ 001706f0, 1332 bytes * /

void FUN_001706f0(HSLiveObjectAppearanceAssistantPane *self,SEL _cmd,BOOL viewWillAppear)

{
  id pvVar1;
  id pvVar2;
  HSLiveObjectAppearanceAssistantPane *pHVar3;
  double dVar4;
  HSLiveObjectAppearanceAssistantPane *pHVar5;
  undefined *puVar6;
  cfstringStruct *pcVar7;
  undefined *puVar8;
  undefined4 uVar9;
  
  pvVar1 = _objc_msgSend(self,sel_assistant);
  pvVar1 = _objc_msgSend(pvVar1,sel_object);
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_003755d8);
  pvVar2 = _objc_msgSend(self,sel_opacityAttributes);
  dVar4 = _objc_msgSend_fpret(pvVar2,sel_hyperOpacity);
  _objc_msgSend(self,sel_updateOpacity_,(float)dVar4);
  pvVar1 = _objc_msgSend(pvVar1,sel_attributeObservingController);
  pcVar7 = *(cfstringStruct **)PTR_0033601c;
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttributesOfHyperInterface_withPriority_
                ,self,sel_validateUIWithNotification_,pcVar7,&DAT_003755d8,0xbe800000);
  pvVar1 = _objc_msgSend(self,sel_liveObjectAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_attributeObservingController);
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttributesOfHyperInterface_withPriority_
                ,self,sel_validateUIWithNotification_,pcVar7,&DAT_003751f0,0xbe800000);
  pvVar1 = _objc_msgSend(self,sel_playableObjectAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_attributeObservingController);
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttribute_withPriority_,self,
                sel_validateUIWithNotification_,pcVar7,&DAT_003756b4,0xbe800000);
  pvVar1 = _objc_msgSend(self,sel_shadowAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_attributeObservingController);
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttributesOfHyperInterface_withPriority_
                ,self,sel_validateShadowAttributesWithNotification_,pcVar7,&DAT_00375308,0xbe800000)
  ;
  pvVar1 = _objc_msgSend(pvVar2,sel_attributeObservingController);
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttributesOfHyperInterface_withPriority_
                ,self,sel_validateOpacityAttributesWithNotification_,pcVar7,&DAT_003755b0,0xbe800000
               );
  pvVar1 = _objc_msgSend(self,sel_geometryAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_attributeObservingController);
  puVar8 = &DAT_003753a8;
  uVar9 = 0xbe800000;
  pHVar5 = self;
  puVar6 = sel_validateMirrorWithNotification_;
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttributesOfHyperInterface_withPriority_
                ,self,sel_validateMirrorWithNotification_,pcVar7,&DAT_003753a8,0xbe800000);
  _objc_msgSend(self->_cameraListPopUp,sel_removeAllItems);
  pvVar1 = _objc_msgSend(cls_HSSystem,sel_sharedSystem);
  pvVar1 = _objc_msgSend(pvVar1,sel_isQTKitCapturingAvailable);
  if ((char)pvVar1 != '\0') {
    puVar6 = *(undefined **)PTR_00336158;
    pHVar5 = *(HSLiveObjectAppearanceAssistantPane **)PTR_0033615c;
    pcVar7 = (cfstringStruct *)0x0;
    pHVar3 = _objc_msgSend(cls_NSArray,sel_arrayWithObjects_,pHVar5,puVar6,0,puVar8,uVar9);
    if (pHVar3 != (HSLiveObjectAppearanceAssistantPane *)0x0) {
      pvVar1 = _objc_msgSend(cls_HSCaptureDeviceList,sel_captureDeviceListForMediaTypes_,pHVar3,
                             puVar6,pcVar7);
      pvVar1 = _objc_msgSend(pvVar1,sel_retain);
      self->_captureDeviceList = pvVar1;
      pHVar5 = pHVar3;
      if (pvVar1 != (id)0x0) {
        pvVar2 = _objc_msgSend(self->_cameraListPopUp,sel_menu,pHVar3,puVar6,pcVar7);
        _objc_msgSend(pvVar1,sel_attachMenu_,pvVar2);
        pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
        puVar8 = self->_captureDeviceList;
        pcVar7 = &cfstr_HSCaptureDeviceListDidUpdateNotification;
        pHVar5 = self;
        puVar6 = sel_HSLiveObjectAppearanceAssistantPane_captureDeviceListDidUpdate_;
        _objc_msgSend(pvVar1,sel_addObserver_selector_name_object_,self,
                      sel_HSLiveObjectAppearanceAssistantPane_captureDeviceListDidUpdate_,
                      &cfstr_HSCaptureDeviceListDidUpdateNotification,puVar8);
      }
    }
  }
  if (self->_captureDeviceList == (id)0x0) {
    pvVar1 = _objc_msgSend(self->_cameraListPopUp,sel_menu,pHVar5,puVar6,pcVar7,puVar8);
    puVar6 = cls_NSBundle;
    pvVar2 = _objc_msgSend(cls_HSCaptureDeviceList,sel_class);
    pvVar2 = _objc_msgSend(puVar6,sel_bundleForClass_,pvVar2);
    pcVar7 = &cfstr_empty;
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_Not_Available,
                           &cfstr_empty,&cfstr_HyperPlayerBase);
    puVar6 = (undefined *)0x0;
    pvVar1 = _objc_msgSend(pvVar1,sel_addItemWithTitle_action_keyEquivalent_,pvVar2,0,&cfstr_empty);
    _objc_msgSend(pvVar1,sel_setEnabled_,0);
    pHVar5 = (HSLiveObjectAppearanceAssistantPane *)0x0;
    _objc_msgSend(self->_groupView,sel_setHyperEnabled_,0);
  }
  _objc_msgSend(self,sel_HSLiveObjectAppearanceAssistantPane_cameraListPopUpDidUpdate,pHVar5,puVar6,
                pcVar7,puVar8);
  _objc_msgSend(self,sel_validateUI);
  _objc_msgSend(self,sel_updateShadow);
  _objc_msgSend(self,sel_updateMirror);
  return;
}

*/
- (void)viewWillAppear:(BOOL)aAppear
{
    id objectAttributes = [[[self assistant] object] queryHyperInterface:@protocol(HSMutableObjectAttributes)];
    id opacityAttributes = [self opacityAttributes];
    [self updateOpacity:[opacityAttributes hyperOpacity]];
    [[objectAttributes attributeObservingController] addObserver:self selector:@selector(validateUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSMutableObjectAttributes) withPriority:-0.25];
    [[[self liveObjectAttributes] attributeObservingController] addObserver:self selector:@selector(validateUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSLiveObjectAttributes) withPriority:-0.25];
    [[[self playableObjectAttributes] attributeObservingController] addObserver:self selector:@selector(validateUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSPlayingVideoStateAttribute) withPriority:-0.25];
    [[[self shadowAttributes] attributeObservingController] addObserver:self selector:@selector(validateShadowAttributesWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSShadowAttributes) withPriority:-0.25];
    [[opacityAttributes attributeObservingController] addObserver:self selector:@selector(validateOpacityAttributesWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSOpacityAttributes) withPriority:-0.25];
    [[[self geometryAttributes] attributeObservingController] addObserver:self selector:@selector(validateMirrorWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSGeometryAttributes) withPriority:-0.25];
    [_cameraListPopUp removeAllItems];
    if ([[HSSystem sharedSystem] isQTKitCapturingAvailable]) {
        NSArray *mediaTypes = [NSArray arrayWithObjects:QTMediaTypeVideo, QTMediaTypeMuxed, nil];
        if (mediaTypes != nil) {
            _captureDeviceList = [[HSCaptureDeviceList captureDeviceListForMediaTypes:mediaTypes] retain];
            if (_captureDeviceList != nil) {
                [_captureDeviceList attachMenu:[_cameraListPopUp menu]];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSLiveObjectAppearanceAssistantPane_captureDeviceListDidUpdate:) name:@"HSCaptureDeviceListDidUpdateNotification" object:_captureDeviceList];
            }
        }
    }
    if (_captureDeviceList == nil) {
        NSMenuItem *item = [[_cameraListPopUp menu] addItemWithTitle:[[NSBundle bundleForClass:[HSCaptureDeviceList class]] localizedStringForKey:@"Not Available" value:@"" table:@"HyperPlayerBase"] action:NULL keyEquivalent:@""];
        [item setEnabled:NO];
        [_groupView setHyperEnabled:NO];
    }
    [self HSLiveObjectAppearanceAssistantPane_cameraListPopUpDidUpdate];
    [self validateUI];
    [self updateShadow];
    [self updateMirror];
}

- (void)dealloc
{
    [_playImage release];
    [_stopImage release];
    [_pressedPlayImage release];
    [_pressedStopImage release];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0016f23d @ 0016f23d, 722 bytes * /

void FUN_0016f23d(HSLiveObjectAppearanceAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  undefined *puVar2;
  cfstringStruct *pcVar3;
  cfstringStruct *pcVar4;
  cfstringStruct *pcVar5;
  cfstringStruct *pcVar6;
  
  pvVar1 = _objc_msgSend(cls_HSPlaybackControlImagesProvider,
                         sel_sharedPlaybackControlsImagesProvider);
  pcVar4 = &cfstr_N;
  pvVar1 = _objc_msgSend(pvVar1,sel_playbackImageOfType_state_size_tint_,&cfstr_Play,&cfstr_N,
                         &cfstr_L,&cfstr_A);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_playImage = pvVar1;
  pvVar1 = _objc_msgSend(cls_HSPlaybackControlImagesProvider,
                         sel_sharedPlaybackControlsImagesProvider);
  pcVar6 = &cfstr_A;
  pcVar5 = &cfstr_L;
  pvVar1 = _objc_msgSend(pvVar1,sel_playbackImageOfType_state_size_tint_,&cfstr_Stop,&cfstr_N,
                         &cfstr_L,&cfstr_A);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_stopImage = pvVar1;
  puVar2 = sel_currentControlTint;
  pvVar1 = _objc_msgSend(cls_NSColor,sel_respondsToSelector_,sel_currentControlTint);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(cls_NSColor,sel_currentControlTint,puVar2,pcVar4,pcVar5,pcVar6);
    if (pvVar1 == (id)0x6) {
      pvVar1 = _objc_msgSend(cls_HSPlaybackControlImagesProvider,
                             sel_sharedPlaybackControlsImagesProvider,puVar2,pcVar4,pcVar5,pcVar6);
      pcVar4 = &cfstr_P;
      pvVar1 = _objc_msgSend(pvVar1,sel_playbackImageOfType_state_size_tint_,&cfstr_Play,&cfstr_P,
                             &cfstr_L,&cfstr_G);
      pvVar1 = _objc_msgSend(pvVar1,sel_retain);
      self->_pressedPlayImage = pvVar1;
      pvVar1 = _objc_msgSend(cls_HSPlaybackControlImagesProvider,
                             sel_sharedPlaybackControlsImagesProvider);
      pcVar6 = &cfstr_G;
      pcVar5 = &cfstr_L;
      pcVar3 = &cfstr_Stop;
      pvVar1 = _objc_msgSend(pvVar1,sel_playbackImageOfType_state_size_tint_,&cfstr_Stop,&cfstr_P,
                             &cfstr_L,&cfstr_G);
      goto LAB_0016f42e;
    }
  }
  pvVar1 = _objc_msgSend(cls_HSPlaybackControlImagesProvider,
                         sel_sharedPlaybackControlsImagesProvider,puVar2,pcVar4,pcVar5,pcVar6);
  pcVar4 = &cfstr_P;
  pvVar1 = _objc_msgSend(pvVar1,sel_playbackImageOfType_state_size_tint_,&cfstr_Play,&cfstr_P,
                         &cfstr_L,&cfstr_A);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_pressedPlayImage = pvVar1;
  pvVar1 = _objc_msgSend(cls_HSPlaybackControlImagesProvider,
                         sel_sharedPlaybackControlsImagesProvider);
  pcVar6 = &cfstr_A;
  pcVar5 = &cfstr_L;
  pcVar3 = &cfstr_Stop;
  pvVar1 = _objc_msgSend(pvVar1,sel_playbackImageOfType_state_size_tint_,&cfstr_Stop,&cfstr_P,
                         &cfstr_L,&cfstr_A);
LAB_0016f42e:
  pvVar1 = _objc_msgSend(pvVar1,sel_retain,pcVar3,pcVar4,pcVar5,pcVar6);
  self->_pressedStopImage = pvVar1;
  return;
}

*/
- (void)viewDidLoad
{
    HSPlaybackControlImagesProvider *provider = [HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider];
    _playImage = [[provider playbackImageOfType:@"Play" state:@"N" size:@"L" tint:@"A"] retain];
    _stopImage = [[provider playbackImageOfType:@"Stop" state:@"N" size:@"L" tint:@"A"] retain];
    if ([NSColor respondsToSelector:@selector(currentControlTint)] && [NSColor currentControlTint] == 6) {
        _pressedPlayImage = [[provider playbackImageOfType:@"Play" state:@"P" size:@"L" tint:@"G"] retain];
        _pressedStopImage = [[provider playbackImageOfType:@"Stop" state:@"P" size:@"L" tint:@"G"] retain];
    } else {
        _pressedPlayImage = [[provider playbackImageOfType:@"Play" state:@"P" size:@"L" tint:@"A"] retain];
        _pressedStopImage = [[provider playbackImageOfType:@"Stop" state:@"P" size:@"L" tint:@"A"] retain];
    }
}

- (id)init
{
    self = [super initWithNibName:@"LiveObjectAppearancePane" bundle:0];
    if (self != nil) {
        [self setTitle:[[NSBundle mainBundle] localizedStringForKey:@"Appearance" value:@"" table:@"AssistantPanes"]];
        [self setIcon:[NSImage imageNamed:@"general"]];
    }
    return self;
}

- (void)HSLiveObjectAppearanceAssistantPane_cameraListPopUpDidUpdate
{
    [_groupView setHyperEnabled:[[_cameraListPopUp selectedItem] isEnabled]];
    [self HSLiveObjectAppearanceAssistantPane_updateSelectedCaptureDevice:[[_cameraListPopUp selectedItem] representedObject]];
}

- (void)HSLiveObjectAppearanceAssistantPane_updateSelectedCaptureDevice:(id)aDevice
{
    if (_selectedCaptureDevice != aDevice) {
        [_selectedCaptureDevice removeObserver:self forKeyPath:@"inUseByAnotherApplication"];
        [_selectedCaptureDevice removeObserver:self forKeyPath:@"suspended"]
        ;
        [aDevice retain];
        [_selectedCaptureDevice release];
        _selectedCaptureDevice = aDevice;
        [aDevice addObserver:self forKeyPath:@"inUseByAnotherApplication" options:0 context:nil];
        [_selectedCaptureDevice addObserver:self forKeyPath:@"suspended" options:0 context:nil];
    }
}

@end

