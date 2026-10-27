#import "HSTransparentColorAssistantPane.h"

@implementation HSTransparentColorAssistantPane

/* i386 ivar offsets: _transparentColorWell=0x68, _transparentColorPicker=0x6c, _sensitivityLabel=0x70, _hueSensitivitySlider=0x74, _chromaSensitivitySlider=0x78, _lightnessSensitivitySlider=0x7c, _linkSlidersSwitch=0x80, _paneSwitcher=0x84, _transparentColorAttributes=0x88, _isTransparentColorBeingUndoneOrRedone=0x8c, _isTransparentColorHueToleranceBeingUndoneOrRedone=0x8c, _isTransparentColorChromaToleranceBeingUndoneOrRedone=0x8c, _isTransparentColorLightnessToleranceBeingUndoneOrRedone=0x8c */

- (void)paneDidOK:(id)aOK
{
    [super paneDidOK:aOK];
    [[_delegate queryHyperInterface:@protocol(HSTransparentColorAssistantPaneDelegate)] editingFinishedForTransparentAssistantPane:self];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00284d9a @ 00284d9a, 258 bytes * /

void FUN_00284d9a(HSTransparentColorAssistantPane *self,SEL _cmd,id activateColorPickingMode)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_stack);
  pvVar1 = _objc_msgSend(pvVar1,sel_document);
  self_00 = _objc_msgSend(pvVar1,sel_cardView);
  pvVar1 = _objc_msgSend(self_00,sel_rootCanvasLayer);
  pvVar2 = _objc_msgSend(pvVar1,sel_vectorToolsIdentifiers);
  _objc_msgSend(pvVar1,sel_setEnabledSublayerIdentifiers_,pvVar2);
  pvVar1 = _objc_msgSend(self_00,sel_isColorPickingModeActive);
  op = sel_activateColorPickingModeWithDelegate_didEndSelector_;
  if ((char)pvVar1 != '\0') {
    _objc_msgSend(self_00,sel_cancelColorPicking,pvVar2);
    self_00 = _objc_msgSend(self_00,sel_rootCanvasLayer);
    self = (HSTransparentColorAssistantPane *)0x0;
    op = sel_setEnabledSublayerIdentifiers_;
  }
  _objc_msgSend(self_00,op,self);
  return;
}

*/
- (void)activateColorPickingMode:(id)aMode
{
    id cardView = [[[self stack] document] cardView];
    id rootLayer = [cardView rootCanvasLayer];
    [rootLayer setEnabledSublayerIdentifiers:[rootLayer vectorToolsIdentifiers]];
    if ([cardView isColorPickingModeActive]) {
        [cardView cancelColorPicking];
        [[cardView rootCanvasLayer] setEnabledSublayerIdentifiers:nil];
    } else {
        [cardView activateColorPickingModeWithDelegate:self didEndSelector:@selector(colorPickingDidFinishWithColor:)];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0028529a @ 0028529a, 168 bytes * /

void FUN_0028529a(HSTransparentColorAssistantPane *self,SEL _cmd,id changeLightnessSensitivity)

{
  id pvVar1;
  id self_00;
  double dVar2;
  SEL op;
  
  dVar2 = _objc_msgSend_fpret(changeLightnessSensitivity,sel_doubleValue);
  pvVar1 = _objc_msgSend(self->_linkSlidersSwitch,sel_state);
  self_00 = _objc_msgSend(self,sel_HSTransparentColorAssistantPane_applier);
  op = sel_setTransparentColorLightnessTolerance_;
  if (pvVar1 == (id)0x1) {
    op = sel_setTransparentColorAllTolerances_;
  }
  _objc_msgSend(self_00,op,dVar2 * -0.01 + 1.0);
  return;
}

*/
- (void)changeLightnessSensitivity:(id)aSensitivity
{
    double tolerance = 1.0 - [aSensitivity doubleValue] * 0.01;
    if ([_linkSlidersSwitch state] == NSControlStateValueOn) {
        [[self HSTransparentColorAssistantPane_applier] setTransparentColorAllTolerances:tolerance];
    } else {
        [[self HSTransparentColorAssistantPane_applier] setTransparentColorLightnessTolerance:tolerance];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00285342 @ 00285342, 168 bytes * /

void FUN_00285342(HSTransparentColorAssistantPane *self,SEL _cmd,id changeChromaSensitivity)

{
  id pvVar1;
  id self_00;
  double dVar2;
  SEL op;
  
  dVar2 = _objc_msgSend_fpret(changeChromaSensitivity,sel_doubleValue);
  pvVar1 = _objc_msgSend(self->_linkSlidersSwitch,sel_state);
  self_00 = _objc_msgSend(self,sel_HSTransparentColorAssistantPane_applier);
  op = sel_setTransparentColorChromaTolerance_;
  if (pvVar1 == (id)0x1) {
    op = sel_setTransparentColorAllTolerances_;
  }
  _objc_msgSend(self_00,op,dVar2 * -0.01 + 1.0);
  return;
}

*/
- (void)changeChromaSensitivity:(id)aSensitivity
{
    double tolerance = 1.0 - [aSensitivity doubleValue] * 0.01;
    if ([_linkSlidersSwitch state] == NSControlStateValueOn) {
        [[self HSTransparentColorAssistantPane_applier] setTransparentColorAllTolerances:tolerance];
    } else {
        [[self HSTransparentColorAssistantPane_applier] setTransparentColorChromaTolerance:tolerance];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002853ea @ 002853ea, 168 bytes * /

void FUN_002853ea(HSTransparentColorAssistantPane *self,SEL _cmd,id changeHueSensitivity)

{
  id pvVar1;
  id self_00;
  double dVar2;
  SEL op;
  
  dVar2 = _objc_msgSend_fpret(changeHueSensitivity,sel_doubleValue);
  pvVar1 = _objc_msgSend(self->_linkSlidersSwitch,sel_state);
  self_00 = _objc_msgSend(self,sel_HSTransparentColorAssistantPane_applier);
  op = sel_setTransparentColorHueTolerance_;
  if (pvVar1 == (id)0x1) {
    op = sel_setTransparentColorAllTolerances_;
  }
  _objc_msgSend(self_00,op,dVar2 * -0.01 + 1.0);
  return;
}

*/
- (void)changeHueSensitivity:(id)aSensitivity
{
    double tolerance = 1.0 - [aSensitivity doubleValue] * 0.01;
    if ([_linkSlidersSwitch state] == NSControlStateValueOn) {
        [[self HSTransparentColorAssistantPane_applier] setTransparentColorAllTolerances:tolerance];
    } else {
        [[self HSTransparentColorAssistantPane_applier] setTransparentColorHueTolerance:tolerance];
    }
}

- (void)changeTransparentColor:(id)aColor
{
    [[self HSTransparentColorAssistantPane_applier] setTransparentColor:[aColor color]];
}

- (void)colorPickingDidFinishWithColor:(id)aColor
{
    if (aColor != nil) {
        [[self HSTransparentColorAssistantPane_applier] setTransparentColor:aColor];
    }
    [[[[[self stack] document] cardView] rootCanvasLayer] setEnabledSublayerIdentifiers:nil];
}

- (void)HSTransparentColorAssistantPane_objectsWillChange:(id)aChange
{
    id pvVar1_4;
    id pvVar2_4;

    if ([[[aChange userInfo] objectForKey:@"HSNodeChildrenForRemoval"] containsObject:[[self assistant] object]]) {
        pvVar1_4 = [self stack];
        pvVar2_4 = [[pvVar1_4 document] cardView];
        if ([pvVar2_4 isColorPickingModeActive]) {
            [pvVar2_4 cancelColorPicking];
            [[pvVar2_4 rootCanvasLayer] setEnabledSublayerIdentifiers:nil];
        }
        [pvVar1_4 removeObserver:self selector:@selector(HSTransparentColorAssistantPane_objectsWillChange:) ofChanges:HSActualWillAttributeChanges ofChildrenAttribute:@protocol(HSNodeContainerChildrenAttribute)];
    }
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    int uVar1;
    id pvVar2;
    HSTransparentColorAssistantPane *pHVar4;

    pvVar2 = [_transparentColorAttributes attributeObservingController];
    uVar1 = HSActualDidAttributeChanges;
    [pvVar2 removeObserver:self selector:@selector(HSTransparentColorAssistantPane_transparentColorDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSTransparentColorAttribute)];
    [pvVar2 removeObserver:self selector:@selector(HSTransparentColorAssistantPane_transparentColorEnablementWillBeUndoneOrRedone:) ofChanges:0x100 ofAttribute:@protocol(HSTransparentColorEnabledAttribute)];
    [pvVar2 removeObserver:self selector:@selector(HSTransparentColorAssistantPane_transparentColorEnablementWasUndoneOrRedone:) ofChanges:0x200 ofAttribute:@protocol(HSTransparentColorEnabledAttribute)];
    [pvVar2 removeObserver:self selector:@selector(HSTransparentColorAssistantPane_transparentColorWillBeUndoneOrRedone:) ofChanges:0x100 ofAttribute:@protocol(HSTransparentColorAttribute)];
    [pvVar2 removeObserver:self selector:@selector(HSTransparentColorAssistantPane_transparentColorWasUndoneOrRedone:) ofChanges:0x200 ofAttribute:@protocol(HSTransparentColorAttribute)];
    [pvVar2 removeObserver:self selector:@selector(HSTransparentColorAssistantPane_transparentColorHueToleranceDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSTransparentColorHueToleranceAttribute)];
    [pvVar2 removeObserver:self selector:@selector(HSTransparentColorAssistantPane_transparentColorHueToleranceWillBeUndoneOrRedone:) ofChanges:0x100 ofAttribute:@protocol(HSTransparentColorHueToleranceAttribute)];
    [pvVar2 removeObserver:self selector:@selector(HSTransparentColorAssistantPane_transparentColorHueToleranceWasUndoneOrRedone:) ofChanges:0x200 ofAttribute:@protocol(HSTransparentColorHueToleranceAttribute)];
    [pvVar2 removeObserver:self selector:@selector(HSTransparentColorAssistantPane_transparentColorChromaToleranceDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSTransparentColorChromaToleranceAttribute)];
    [pvVar2 removeObserver:self selector:@selector(HSTransparentColorAssistantPane_transparentColorChromaToleranceWillBeUndoneOrRedone:) ofChanges:0x100 ofAttribute:@protocol(HSTransparentColorChromaToleranceAttribute)];
    [pvVar2 removeObserver:self selector:@selector(HSTransparentColorAssistantPane_transparentColorChromaToleranceWasUndoneOrRedone:) ofChanges:0x200 ofAttribute:@protocol(HSTransparentColorChromaToleranceAttribute)];
    [pvVar2 removeObserver:self selector:@selector(HSTransparentColorAssistantPane_transparentColorLightnessToleranceDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSTransparentColorLightnessToleranceAttribute)];
    [pvVar2 removeObserver:self selector:@selector(HSTransparentColorAssistantPane_transparentColorLightnessToleranceWillBeUndoneOrRedone:) ofChanges:0x100 ofAttribute:@protocol(HSTransparentColorLightnessToleranceAttribute)];
    pHVar4 = self;
    [pvVar2 removeObserver:self selector:@selector(HSTransparentColorAssistantPane_transparentColorLightnessToleranceWasUndoneOrRedone:) ofChanges:0x200 ofAttribute:@protocol(HSTransparentColorLightnessToleranceAttribute)];
    [_transparentColorAttributes release];
    _transparentColorAttributes = nil;
    pvVar2 = [[[self stack] document] cardView];
    if ([pvVar2 isColorPickingModeActive]) {
        [pvVar2 cancelColorPicking];
        pvVar2 = [pvVar2 rootCanvasLayer];
        pHVar4 = nil;
        [pvVar2 setEnabledSublayerIdentifiers:nil];
    }
    pvVar2 = [self stack];
    [pvVar2 removeObserver:self selector:@selector(HSTransparentColorAssistantPane_objectsWillChange:) ofChanges:HSActualWillAttributeChanges ofChildrenAttribute:@protocol(HSNodeContainerChildrenAttribute)];
    [super viewWillDisappear:aDisappear];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002858cc @ 002858cc, 1357 bytes * /

void FUN_002858cc(HSTransparentColorAssistantPane *self,SEL _cmd,BOOL viewWillAppear)

{
  id pvVar1;
  id pvVar2;
  double dVar3;
  id pvVar4;
  undefined4 uVar5;
  HSTransparentColorAssistantPane *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSObjectAssistantPaneWithApplier_00356720;
  _objc_msgSendSuper(&local_1c,sel_viewWillAppear_,(int)viewWillAppear);
  pvVar1 = _objc_msgSend(self,sel_HSTransparentColorAssistantPane_applier);
  pvVar4 = (id)0x1;
  _objc_msgSend(pvVar1,sel_setTransparentColorEnabled_,1);
  _objc_msgSend(self,sel_transparentColorAttributes);
  pvVar2 = _objc_msgSend(self->_transparentColorAttributes,sel_transparentColor);
  if (pvVar2 == (id)0x0) {
    pvVar4 = _objc_msgSend(self->_transparentColorWell,sel_color,pvVar4);
    _objc_msgSend(pvVar1,sel_setTransparentColor_,pvVar4);
  }
  pvVar1 = _objc_msgSend(self->_transparentColorAttributes,sel_attributeObservingController,pvVar4);
  uVar5 = *(undefined4 *)PTR_0033601c;
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttribute_withPriority_,self,
                sel_HSTransparentColorAssistantPane_transparentColorDidChange_,uVar5,&DAT_003884e4,
                0xbe800000,uVar5);
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttribute_withPriority_,self,
                sel_HSTransparentColorAssistantPane_transparentColorEnablementWillBeUndoneOrRedone_,
                0x100,&DAT_003884a8,0xbe800000);
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttribute_withPriority_,self,
                sel_HSTransparentColorAssistantPane_transparentColorEnablementWasUndoneOrRedone_,
                0x200,&DAT_003884a8,0xbe800000);
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttribute_withPriority_,self,
                sel_HSTransparentColorAssistantPane_transparentColorWillBeUndoneOrRedone_,0x100,
                &DAT_003884e4,0xbe800000);
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttribute_withPriority_,self,
                sel_HSTransparentColorAssistantPane_transparentColorWasUndoneOrRedone_,0x200,
                &DAT_003884e4,0xbe800000);
  _objc_msgSend(self,sel_HSTransparentColorAssistantPane_validateTransparentColorWell);
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttribute_withPriority_,self,
                sel_HSTransparentColorAssistantPane_transparentColorHueToleranceDidChange_,uVar5,
                &DAT_0038850c,0xbe800000);
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttribute_withPriority_,self,
                sel_HSTransparentColorAssistantPane_transparentColorHueToleranceWillBeUndoneOrRedone_
                ,0x100,&DAT_0038850c,0xbe800000);
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttribute_withPriority_,self,
                sel_HSTransparentColorAssistantPane_transparentColorHueToleranceWasUndoneOrRedone_,
                0x200,&DAT_0038850c,0xbe800000);
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttribute_withPriority_,self,
                sel_HSTransparentColorAssistantPane_transparentColorChromaToleranceDidChange_,uVar5,
                &DAT_00388520,0xbe800000);
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttribute_withPriority_,self,
                sel_HSTransparentColorAssistantPane_transparentColorChromaToleranceWillBeUndoneOrRedone_
                ,0x100,&DAT_00388520,0xbe800000);
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttribute_withPriority_,self,
                sel_HSTransparentColorAssistantPane_transparentColorChromaToleranceWasUndoneOrRedone_
                ,0x200,&DAT_00388520,0xbe800000);
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttribute_withPriority_,self,
                sel_HSTransparentColorAssistantPane_transparentColorLightnessToleranceDidChange_,
                uVar5,&DAT_00388534,0xbe800000);
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttribute_withPriority_,self,
                sel_HSTransparentColorAssistantPane_transparentColorLightnessToleranceWillBeUndoneOrRedone_
                ,0x100,&DAT_00388534,0xbe800000);
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttribute_withPriority_,self,
                sel_HSTransparentColorAssistantPane_transparentColorLightnessToleranceWasUndoneOrRedone_
                ,0x200,&DAT_00388534,0xbe800000);
  dVar3 = _objc_msgSend_fpret(self->_transparentColorAttributes,sel_hueTolerance);
  _objc_msgSend(self,sel_HSTransparentColorAssistantPane_validateSensitivitySlider_withTolerance_,
                self->_hueSensitivitySlider,dVar3);
  dVar3 = _objc_msgSend_fpret(self->_transparentColorAttributes,sel_chromaTolerance);
  _objc_msgSend(self,sel_HSTransparentColorAssistantPane_validateSensitivitySlider_withTolerance_,
                self->_chromaSensitivitySlider,dVar3);
  dVar3 = _objc_msgSend_fpret(self->_transparentColorAttributes,sel_lightnessTolerance);
  _objc_msgSend(self,sel_HSTransparentColorAssistantPane_validateSensitivitySlider_withTolerance_,
                self->_lightnessSensitivitySlider,dVar3);
  pvVar1 = _objc_msgSend(self,sel_stack);
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofChildrenAttribute_withPriority_,self,
                sel_HSTransparentColorAssistantPane_objectsWillChange_,*(undefined4 *)PTR_00336020,
                &DAT_00388548,0xbe800000);
  return;
}

*/
- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    id applier = [self HSTransparentColorAssistantPane_applier];
    [applier setTransparentColorEnabled:YES];
    [self transparentColorAttributes];
    if ([_transparentColorAttributes transparentColor] == nil) {
        [applier setTransparentColor:[_transparentColorWell color]];
    }
    id observing = [_transparentColorAttributes attributeObservingController];
    [observing addObserver:self selector:@selector(HSTransparentColorAssistantPane_transparentColorDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSTransparentColorAttribute) withPriority:-0.25];
    [observing addObserver:self selector:@selector(HSTransparentColorAssistantPane_transparentColorEnablementWillBeUndoneOrRedone:) ofChanges:0x100 ofAttribute:@protocol(HSTransparentColorEnabledAttribute) withPriority:-0.25];
    [observing addObserver:self selector:@selector(HSTransparentColorAssistantPane_transparentColorEnablementWasUndoneOrRedone:) ofChanges:0x200 ofAttribute:@protocol(HSTransparentColorEnabledAttribute) withPriority:-0.25];
    [observing addObserver:self selector:@selector(HSTransparentColorAssistantPane_transparentColorWillBeUndoneOrRedone:) ofChanges:0x100 ofAttribute:@protocol(HSTransparentColorAttribute) withPriority:-0.25];
    [observing addObserver:self selector:@selector(HSTransparentColorAssistantPane_transparentColorWasUndoneOrRedone:) ofChanges:0x200 ofAttribute:@protocol(HSTransparentColorAttribute) withPriority:-0.25];
    [self HSTransparentColorAssistantPane_validateTransparentColorWell];
    [observing addObserver:self selector:@selector(HSTransparentColorAssistantPane_transparentColorHueToleranceDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSTransparentColorHueToleranceAttribute) withPriority:-0.25];
    [observing addObserver:self selector:@selector(HSTransparentColorAssistantPane_transparentColorHueToleranceWillBeUndoneOrRedone:) ofChanges:0x100 ofAttribute:@protocol(HSTransparentColorHueToleranceAttribute) withPriority:-0.25];
    [observing addObserver:self selector:@selector(HSTransparentColorAssistantPane_transparentColorHueToleranceWasUndoneOrRedone:) ofChanges:0x200 ofAttribute:@protocol(HSTransparentColorHueToleranceAttribute) withPriority:-0.25];
    [observing addObserver:self selector:@selector(HSTransparentColorAssistantPane_transparentColorChromaToleranceDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSTransparentColorChromaToleranceAttribute) withPriority:-0.25];
    [observing addObserver:self selector:@selector(HSTransparentColorAssistantPane_transparentColorChromaToleranceWillBeUndoneOrRedone:) ofChanges:0x100 ofAttribute:@protocol(HSTransparentColorChromaToleranceAttribute) withPriority:-0.25];
    [observing addObserver:self selector:@selector(HSTransparentColorAssistantPane_transparentColorChromaToleranceWasUndoneOrRedone:) ofChanges:0x200 ofAttribute:@protocol(HSTransparentColorChromaToleranceAttribute) withPriority:-0.25];
    [observing addObserver:self selector:@selector(HSTransparentColorAssistantPane_transparentColorLightnessToleranceDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSTransparentColorLightnessToleranceAttribute) withPriority:-0.25];
    [observing addObserver:self selector:@selector(HSTransparentColorAssistantPane_transparentColorLightnessToleranceWillBeUndoneOrRedone:) ofChanges:0x100 ofAttribute:@protocol(HSTransparentColorLightnessToleranceAttribute) withPriority:-0.25];
    [observing addObserver:self selector:@selector(HSTransparentColorAssistantPane_transparentColorLightnessToleranceWasUndoneOrRedone:) ofChanges:0x200 ofAttribute:@protocol(HSTransparentColorLightnessToleranceAttribute) withPriority:-0.25];
    [self HSTransparentColorAssistantPane_validateSensitivitySlider:_hueSensitivitySlider withTolerance:[_transparentColorAttributes hueTolerance]];
    [self HSTransparentColorAssistantPane_validateSensitivitySlider:_chromaSensitivitySlider withTolerance:[_transparentColorAttributes chromaTolerance]];
    [self HSTransparentColorAssistantPane_validateSensitivitySlider:_lightnessSensitivitySlider withTolerance:[_transparentColorAttributes lightnessTolerance]];
    [[self stack] addObserver:self selector:@selector(HSTransparentColorAssistantPane_objectsWillChange:) ofChanges:HSActualWillAttributeChanges ofChildrenAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:-0.25];
}

- (id)transparentColorAttributes
{
    id pvVar1;
    id pvVar1_2;
    id pvVar1_5;

    pvVar1 = _transparentColorAttributes;
    if (pvVar1 == nil) {
        pvVar1_2 = [_delegate queryHyperInterface:@protocol(HSTransparentColorAssistantPaneDelegate)];
        if (pvVar1_2 == nil) {
            pvVar1_5 = [[[self assistant] object] queryHyperInterface:@protocol(HSTransparentColorAttributes)];
        }
        else {
            pvVar1_5 = [[[pvVar1_2 tryItAnimationForTransparentColorAssistantPane:self] animatedObject] queryHyperInterface:@protocol(HSTransparentColorAttributes)];
        }
        pvVar1 = [pvVar1_5 retain];
        _transparentColorAttributes = pvVar1;
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002849f1 @ 002849f1, 93 bytes * /

void FUN_002849f1(HSTransparentColorAssistantPane *self,SEL _cmd)

{
  id self_00;
  id pvVar1;
  
  self_00 = _objc_msgSend(self->_transparentColorPicker,sel_cell);
  pvVar1 = _objc_msgSend(cls_HSCardNavigationControlBackgroundRenderer,sel_sharedBackgroundRenderer)
  ;
  _objc_msgSend(self_00,sel_setBackgroundRenderer_,pvVar1);
  return;
}

*/
- (void)awakeFromNib
{
    [[_transparentColorPicker cell] setBackgroundRenderer:[HSCardNavigationControlBackgroundRenderer sharedBackgroundRenderer]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002849ae @ 002849ae, 67 bytes * /

void FUN_002849ae(HSTransparentColorAssistantPane *self,SEL _cmd,
                 id 
                 HSTransparentColorAssistantPane_transparentColorLightnessToleranceWasUndoneOrRedone
                 )

{
  id self_00;
  
  self_00 = _objc_msgSend(self,sel_HSTransparentColorAssistantPane_applier);
  _objc_msgSend(self_00,sel_resetTransparentColorLightnessTolerance);
  self->_isTransparentColorBeingUndoneOrRedone[0] =
       self->_isTransparentColorBeingUndoneOrRedone[0] & 0xf7;
  return;
}

*/
- (void)HSTransparentColorAssistantPane_transparentColorLightnessToleranceWasUndoneOrRedone:(id)aRedone
{
    [[self HSTransparentColorAssistantPane_applier] resetTransparentColorLightnessTolerance];
    _isTransparentColorLightnessToleranceBeingUndoneOrRedone = NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0028496d @ 0028496d, 65 bytes * /

void FUN_0028496d(HSTransparentColorAssistantPane *self,SEL _cmd,
                 id 
                 HSTransparentColorAssistantPane_transparentColorLightnessToleranceWillBeUndoneOrRedone
                 )

{
  id self_00;
  
  self->_isTransparentColorBeingUndoneOrRedone[0] =
       self->_isTransparentColorBeingUndoneOrRedone[0] | 8;
  self_00 = _objc_msgSend(self,sel_HSTransparentColorAssistantPane_applier);
  _objc_msgSend(self_00,sel_restoreTransparentColorLightnessTolerance);
  return;
}

*/
- (void)HSTransparentColorAssistantPane_transparentColorLightnessToleranceWillBeUndoneOrRedone:(id)aRedone
{
    _isTransparentColorLightnessToleranceBeingUndoneOrRedone = YES;
    [[self HSTransparentColorAssistantPane_applier] restoreTransparentColorLightnessTolerance];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0028492a @ 0028492a, 67 bytes * /

void FUN_0028492a(HSTransparentColorAssistantPane *self,SEL _cmd,
                 id HSTransparentColorAssistantPane_transparentColorChromaToleranceWasUndoneOrRedone
                 )

{
  id self_00;
  
  self_00 = _objc_msgSend(self,sel_HSTransparentColorAssistantPane_applier);
  _objc_msgSend(self_00,sel_resetTransparentColorChromaTolerance);
  self->_isTransparentColorBeingUndoneOrRedone[0] =
       self->_isTransparentColorBeingUndoneOrRedone[0] & 0xfb;
  return;
}

*/
- (void)HSTransparentColorAssistantPane_transparentColorChromaToleranceWasUndoneOrRedone:(id)aRedone
{
    [[self HSTransparentColorAssistantPane_applier] resetTransparentColorChromaTolerance];
    _isTransparentColorChromaToleranceBeingUndoneOrRedone = NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002848e9 @ 002848e9, 65 bytes * /

void FUN_002848e9(HSTransparentColorAssistantPane *self,SEL _cmd,
                 id 
                 HSTransparentColorAssistantPane_transparentColorChromaToleranceWillBeUndoneOrRedone
                 )

{
  id self_00;
  
  self->_isTransparentColorBeingUndoneOrRedone[0] =
       self->_isTransparentColorBeingUndoneOrRedone[0] | 4;
  self_00 = _objc_msgSend(self,sel_HSTransparentColorAssistantPane_applier);
  _objc_msgSend(self_00,sel_restoreTransparentColorChromaTolerance);
  return;
}

*/
- (void)HSTransparentColorAssistantPane_transparentColorChromaToleranceWillBeUndoneOrRedone:(id)aRedone
{
    _isTransparentColorChromaToleranceBeingUndoneOrRedone = YES;
    [[self HSTransparentColorAssistantPane_applier] restoreTransparentColorChromaTolerance];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002848a6 @ 002848a6, 67 bytes * /

void FUN_002848a6(HSTransparentColorAssistantPane *self,SEL _cmd,
                 id HSTransparentColorAssistantPane_transparentColorHueToleranceWasUndoneOrRedone)

{
  id self_00;
  
  self_00 = _objc_msgSend(self,sel_HSTransparentColorAssistantPane_applier);
  _objc_msgSend(self_00,sel_resetTransparentColorHueTolerance);
  self->_isTransparentColorBeingUndoneOrRedone[0] =
       self->_isTransparentColorBeingUndoneOrRedone[0] & 0xfd;
  return;
}

*/
- (void)HSTransparentColorAssistantPane_transparentColorHueToleranceWasUndoneOrRedone:(id)aRedone
{
    [[self HSTransparentColorAssistantPane_applier] resetTransparentColorHueTolerance];
    _isTransparentColorHueToleranceBeingUndoneOrRedone = NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00284865 @ 00284865, 65 bytes * /

void FUN_00284865(HSTransparentColorAssistantPane *self,SEL _cmd,
                 id HSTransparentColorAssistantPane_transparentColorHueToleranceWillBeUndoneOrRedone
                 )

{
  id self_00;
  
  self->_isTransparentColorBeingUndoneOrRedone[0] =
       self->_isTransparentColorBeingUndoneOrRedone[0] | 2;
  self_00 = _objc_msgSend(self,sel_HSTransparentColorAssistantPane_applier);
  _objc_msgSend(self_00,sel_restoreTransparentColorHueTolerance);
  return;
}

*/
- (void)HSTransparentColorAssistantPane_transparentColorHueToleranceWillBeUndoneOrRedone:(id)aRedone
{
    _isTransparentColorHueToleranceBeingUndoneOrRedone = YES;
    [[self HSTransparentColorAssistantPane_applier] restoreTransparentColorHueTolerance];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00284822 @ 00284822, 67 bytes * /

void FUN_00284822(HSTransparentColorAssistantPane *self,SEL _cmd,
                 id HSTransparentColorAssistantPane_transparentColorWasUndoneOrRedone)

{
  id self_00;
  
  self_00 = _objc_msgSend(self,sel_HSTransparentColorAssistantPane_applier);
  _objc_msgSend(self_00,sel_resetTransparentColor);
  self->_isTransparentColorBeingUndoneOrRedone[0] =
       self->_isTransparentColorBeingUndoneOrRedone[0] & 0xfe;
  return;
}

*/
- (void)HSTransparentColorAssistantPane_transparentColorWasUndoneOrRedone:(id)aRedone
{
    [[self HSTransparentColorAssistantPane_applier] resetTransparentColor];
    _isTransparentColorBeingUndoneOrRedone = NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002847e1 @ 002847e1, 65 bytes * /

void FUN_002847e1(HSTransparentColorAssistantPane *self,SEL _cmd,
                 id HSTransparentColorAssistantPane_transparentColorWillBeUndoneOrRedone)

{
  id self_00;
  
  self->_isTransparentColorBeingUndoneOrRedone[0] =
       self->_isTransparentColorBeingUndoneOrRedone[0] | 1;
  self_00 = _objc_msgSend(self,sel_HSTransparentColorAssistantPane_applier);
  _objc_msgSend(self_00,sel_restoreTransparentColor);
  return;
}

*/
- (void)HSTransparentColorAssistantPane_transparentColorWillBeUndoneOrRedone:(id)aRedone
{
    _isTransparentColorBeingUndoneOrRedone = YES;
    [[self HSTransparentColorAssistantPane_applier] restoreTransparentColor];
}

- (void)HSTransparentColorAssistantPane_transparentColorEnablementWasUndoneOrRedone:(id)aRedone
{
    [[self HSTransparentColorAssistantPane_applier] resetTransparentColorEnablement];
}

- (void)HSTransparentColorAssistantPane_transparentColorEnablementWillBeUndoneOrRedone:(id)aRedone
{
    [[self HSTransparentColorAssistantPane_applier] restoreTransparentColorEnablement];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00285e19 @ 00285e19, 86 bytes * /

void FUN_00285e19(HSTransparentColorAssistantPane *self,SEL _cmd,
                 id HSTransparentColorAssistantPane_transparentColorLightnessToleranceDidChange)

{
  double dVar1;
  
  if ((self->_isTransparentColorBeingUndoneOrRedone[0] & 8) == 0) {
    dVar1 = _objc_msgSend_fpret(self->_transparentColorAttributes,sel_lightnessTolerance);
    _objc_msgSend(self,sel_HSTransparentColorAssistantPane_validateSensitivitySlider_withTolerance_,
                  self->_lightnessSensitivitySlider,dVar1);
  }
  return;
}

*/
- (void)HSTransparentColorAssistantPane_transparentColorLightnessToleranceDidChange:(id)aChange
{
    if (!_isTransparentColorLightnessToleranceBeingUndoneOrRedone) {
        [self HSTransparentColorAssistantPane_validateSensitivitySlider:_lightnessSensitivitySlider withTolerance:[_transparentColorAttributes lightnessTolerance]];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00285e6f @ 00285e6f, 86 bytes * /

void FUN_00285e6f(HSTransparentColorAssistantPane *self,SEL _cmd,
                 id HSTransparentColorAssistantPane_transparentColorChromaToleranceDidChange)

{
  double dVar1;
  
  if ((self->_isTransparentColorBeingUndoneOrRedone[0] & 4) == 0) {
    dVar1 = _objc_msgSend_fpret(self->_transparentColorAttributes,sel_chromaTolerance);
    _objc_msgSend(self,sel_HSTransparentColorAssistantPane_validateSensitivitySlider_withTolerance_,
                  self->_chromaSensitivitySlider,dVar1);
  }
  return;
}

*/
- (void)HSTransparentColorAssistantPane_transparentColorChromaToleranceDidChange:(id)aChange
{
    if (!_isTransparentColorChromaToleranceBeingUndoneOrRedone) {
        [self HSTransparentColorAssistantPane_validateSensitivitySlider:_chromaSensitivitySlider withTolerance:[_transparentColorAttributes chromaTolerance]];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00285ec5 @ 00285ec5, 86 bytes * /

void FUN_00285ec5(HSTransparentColorAssistantPane *self,SEL _cmd,
                 id HSTransparentColorAssistantPane_transparentColorHueToleranceDidChange)

{
  double dVar1;
  
  if ((self->_isTransparentColorBeingUndoneOrRedone[0] & 2) == 0) {
    dVar1 = _objc_msgSend_fpret(self->_transparentColorAttributes,sel_hueTolerance);
    _objc_msgSend(self,sel_HSTransparentColorAssistantPane_validateSensitivitySlider_withTolerance_,
                  self->_hueSensitivitySlider,dVar1);
  }
  return;
}

*/
- (void)HSTransparentColorAssistantPane_transparentColorHueToleranceDidChange:(id)aChange
{
    if (!_isTransparentColorHueToleranceBeingUndoneOrRedone) {
        [self HSTransparentColorAssistantPane_validateSensitivitySlider:_hueSensitivitySlider withTolerance:[_transparentColorAttributes hueTolerance]];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0028473e @ 0028473e, 47 bytes * /

void FUN_0028473e(HSTransparentColorAssistantPane *self,SEL _cmd,
                 id HSTransparentColorAssistantPane_transparentColorDidChange)

{
  if ((self->_isTransparentColorBeingUndoneOrRedone[0] & 1) == 0) {
    _objc_msgSend(self,sel_HSTransparentColorAssistantPane_validateTransparentColorWell);
  }
  return;
}

*/
- (void)HSTransparentColorAssistantPane_transparentColorDidChange:(id)aChange
{
    if (!_isTransparentColorBeingUndoneOrRedone) {
        [self HSTransparentColorAssistantPane_validateTransparentColorWell];
    }
}

- (void)HSTransparentColorAssistantPane_validateSensitivitySlider:(id)aSlider withTolerance:(double)aTolerance
{
    [aSlider setDoubleValue:aTolerance * -100.0 + 100.0];
}

- (void)HSTransparentColorAssistantPane_validateTransparentColorWell
{
    id pvVar1;

    pvVar1 = [_transparentColorAttributes transparentColor];
    if (pvVar1 != nil) {
        [_transparentColorWell setColor:pvVar1];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00284565 @ 00284565, 331 bytes * /

id FUN_00284565(HSTransparentColorAssistantPane *self,SEL _cmd)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  undefined *self_00;
  SEL op;
  cfstringStruct *pcVar4;
  
  pvVar2 = _objc_msgSend((self->super)._delegate,sel_queryHyperInterface_,&DAT_0038837c);
  pvVar3 = _objc_msgSend(self,sel_assistant);
  pvVar3 = _objc_msgSend(pvVar3,sel_object);
  pcVar4 = (cfstringStruct *)&DAT_00388390;
  pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_00388390);
  puVar1 = cls_NSString;
  if (pvVar2 == (id)0x0) {
    if (pvVar3 == (id)0x0) {
      return (id)0x0;
    }
    _objc_msgSend(pvVar3,sel_hyperName,pcVar4);
    _objc_msgSend(pvVar3,sel_hyperKindDisplayName);
  }
  else {
    self_00 = cls_HSPlayAnimationAction;
    op = sel_localizedNameInInspector;
    if (pvVar3 == (id)0x0) goto LAB_00284648;
    _objc_msgSend(cls_HSPlayAnimationAction,sel_localizedNameInInspector,pcVar4);
    _objc_msgSend(pvVar3,sel_hyperName);
  }
  pcVar4 = &cfstr________;
  self_00 = puVar1;
  op = sel_stringWithFormat_;
LAB_00284648:
  pvVar2 = _objc_msgSend(self_00,op,pcVar4);
  return pvVar2;
}

*/
- (id)windowTitle
{
    id delegate = [_delegate queryHyperInterface:@protocol(HSTransparentColorAssistantPaneDelegate)];
    id attributes = [[[self assistant] object] queryHyperInterface:@protocol(HSObjectAttributes)];
    if (delegate == nil) {
        if (attributes == nil) {
            return nil;
        }
        return [NSString stringWithFormat:@"%@ : %@", [attributes hyperKindDisplayName], [attributes hyperName]];
    }
    if (attributes == nil) {
        return [HSPlayAnimationAction localizedNameInInspector];
    }
    return [NSString stringWithFormat:@"%@ : %@", [HSPlayAnimationAction localizedNameInInspector], [attributes hyperName]];
}

- (id)HSTransparentColorAssistantPane_applier
{
    return [self applier];
}

- (Class)applierClass
{
    return [HSTransparentColorApplier class];
}

- (id)navigationPaneSwitcher
{
    HSObjectAssistantNavigationPaneSwitcher *pHVar1;
    HSObjectAssistantNavigationPaneSwitcher *pHVar1_2;

    pHVar1 = _paneSwitcher;
    if (pHVar1 == nil) {
        pHVar1_2 = [HSObjectAssistantNavigationPaneSwitcher new];
        _paneSwitcher = pHVar1_2;
        [pHVar1_2 setDelegate:self];
        pHVar1 = _paneSwitcher;
    }
    return pHVar1;
}

- (void)dealloc
{
    [_paneSwitcher setDelegate:0];
    [_paneSwitcher release];
    [super dealloc];
}

- (id)init
{
    return [self initWithNibName:@"TransparentColorAssistantPane"];
}

@end

@implementation HSTransparentColorApplier

/* i386 ivar offsets: _transparentColorAttributes=0xc, _initialTransparentColor=0x10, _initialTransparentColorHueTolerance=0x14, _initialTransparentColorChromaTolerance=0x1c, _initialTransparentColorLightnessTolerance=0x24, _transparentColor=0x2c, _transparentColorHueTolerance=0x30, _transparentColorChromaTolerance=0x38, _transparentColorLightnessTolerance=0x40, _isTransparentColorEnabledInitially=0x48, _isTransparentColorEnabled=0x48 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_00284392 @ 00284392, 248 bytes * /

BOOL FUN_00284392(HSTransparentColorApplier *self,SEL _cmd)

{
  byte bVar1;
  id self_00;
  id pvVar2;
  
  bVar1 = self->_isTransparentColorEnabledInitially[0];
  if ((bVar1 & 2) != 0) {
    if ((bVar1 & 1) == 0) {
      return '\0';
    }
    if ((bVar1 & 2) != 0) goto LAB_002843c1;
  }
  if ((bVar1 & 1) != 0) {
    return '\0';
  }
LAB_002843c1:
  pvVar2 = self->_initialTransparentColor;
  self_00 = self->_transparentColor;
  if (self_00 != pvVar2) {
    if (pvVar2 == (id)0x0) {
      return self_00 == (id)0x0;
    }
    pvVar2 = _objc_msgSend(self_00,sel_isEqual_,pvVar2);
    if ((char)pvVar2 == '\0') {
      return '\0';
    }
  }
  if (((float)self->_initialTransparentColorHueTolerance + -0.0019607844 <=
       (float)self->_transparentColorHueTolerance) &&
     ((float)self->_transparentColorHueTolerance <=
      (float)self->_initialTransparentColorHueTolerance + 0.0019607844)) {
    if (((float)self->_initialTransparentColorChromaTolerance + -0.0019607844 <=
         (float)self->_transparentColorChromaTolerance) &&
       ((float)self->_transparentColorChromaTolerance <=
        (float)self->_initialTransparentColorChromaTolerance + 0.0019607844)) {
      return (float)self->_initialTransparentColorLightnessTolerance + -0.0019607844 <=
             (float)self->_transparentColorLightnessTolerance &&
             (float)self->_transparentColorLightnessTolerance <=
             (float)self->_initialTransparentColorLightnessTolerance + 0.0019607844;
    }
  }
  return '\0';
}

*/
- (BOOL)areSettingsEqual
{
    if (_isTransparentColorEnabledInitially != _isTransparentColorEnabled) {
        return NO;
    }
    if (_transparentColor != _initialTransparentColor) {
        if (_initialTransparentColor == nil) {
            return _transparentColor == nil;
        }
        if (![_transparentColor isEqual:_initialTransparentColor]) {
            return NO;
        }
    }
    const float epsilon = 1.0f / 510.0f;
    if (!((float)_initialTransparentColorHueTolerance - epsilon <= (float)_transparentColorHueTolerance && (float)_transparentColorHueTolerance <= (float)_initialTransparentColorHueTolerance + epsilon)) {
        return NO;
    }
    if (!((float)_initialTransparentColorChromaTolerance - epsilon <= (float)_transparentColorChromaTolerance && (float)_transparentColorChromaTolerance <= (float)_initialTransparentColorChromaTolerance + epsilon)) {
        return NO;
    }
    return (float)_initialTransparentColorLightnessTolerance - epsilon <= (float)_transparentColorLightnessTolerance && (float)_transparentColorLightnessTolerance <= (float)_initialTransparentColorLightnessTolerance + epsilon;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00284319 @ 00284319, 121 bytes * /

void FUN_00284319(HSTransparentColorApplier *self,SEL _cmd)

{
  id pvVar1;
  
  self->_isTransparentColorEnabledInitially[0] =
       self->_isTransparentColorEnabledInitially[0] * '\x02' & 2 |
       self->_isTransparentColorEnabledInitially[0] & 0xfd;
  if (self->_transparentColor != self->_initialTransparentColor) {
    _objc_msgSend(self->_transparentColor,sel_release);
    pvVar1 = _objc_msgSend(self->_initialTransparentColor,sel_retain);
    self->_transparentColor = pvVar1;
  }
  self->_transparentColorHueTolerance = self->_initialTransparentColorHueTolerance;
  self->_transparentColorChromaTolerance = self->_initialTransparentColorChromaTolerance;
  self->_transparentColorLightnessTolerance = self->_initialTransparentColorLightnessTolerance;
  return;
}

*/
- (void)makeCurrentEqualToInitial
{
    _isTransparentColorEnabled = _isTransparentColorEnabledInitially;
    if (_transparentColor != _initialTransparentColor) {
        [_transparentColor release];
        _transparentColor = [_initialTransparentColor retain];
    }
    _transparentColorHueTolerance = _initialTransparentColorHueTolerance;
    _transparentColorChromaTolerance = _initialTransparentColorChromaTolerance;
    _transparentColorLightnessTolerance = _initialTransparentColorLightnessTolerance;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002842a0 @ 002842a0, 121 bytes * /

void FUN_002842a0(HSTransparentColorApplier *self,SEL _cmd)

{
  id pvVar1;
  
  self->_isTransparentColorEnabledInitially[0] =
       self->_isTransparentColorEnabledInitially[0] >> 1 & 1 |
       self->_isTransparentColorEnabledInitially[0] & 0xfe;
  if (self->_initialTransparentColor != self->_transparentColor) {
    _objc_msgSend(self->_initialTransparentColor,sel_release);
    pvVar1 = _objc_msgSend(self->_transparentColor,sel_retain);
    self->_initialTransparentColor = pvVar1;
  }
  self->_initialTransparentColorHueTolerance = self->_transparentColorHueTolerance;
  self->_initialTransparentColorChromaTolerance = self->_transparentColorChromaTolerance;
  self->_initialTransparentColorLightnessTolerance = self->_transparentColorLightnessTolerance;
  return;
}

*/
- (void)makeInitialEqualToCurrent
{
    _isTransparentColorEnabledInitially = _isTransparentColorEnabled;
    if (_initialTransparentColor != _transparentColor) {
        [_initialTransparentColor release];
        _initialTransparentColor = [_transparentColor retain];
    }
    _initialTransparentColorHueTolerance = _transparentColorHueTolerance;
    _initialTransparentColorChromaTolerance = _transparentColorChromaTolerance;
    _initialTransparentColorLightnessTolerance = _transparentColorLightnessTolerance;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00284f14 @ 00284f14, 219 bytes * /

void FUN_00284f14(HSTransparentColorApplier *self,SEL _cmd)

{
  id pvVar1;
  double dVar2;
  
  pvVar1 = _objc_msgSend(self->_transparentColorAttributes,sel_isTransparentColorEnabled);
  self->_isTransparentColorEnabledInitially[0] =
       self->_isTransparentColorEnabledInitially[0] & 0xfe | (byte)pvVar1 & 1;
  pvVar1 = _objc_msgSend(self->_transparentColorAttributes,sel_transparentColor);
  if (self->_initialTransparentColor != pvVar1) {
    _objc_msgSend(self->_initialTransparentColor,sel_release);
    pvVar1 = _objc_msgSend(pvVar1,sel_retain);
    self->_initialTransparentColor = pvVar1;
  }
  dVar2 = _objc_msgSend_fpret(self->_transparentColorAttributes,sel_hueTolerance);
  self->_initialTransparentColorHueTolerance = dVar2;
  dVar2 = _objc_msgSend_fpret(self->_transparentColorAttributes,sel_chromaTolerance);
  self->_initialTransparentColorChromaTolerance = dVar2;
  dVar2 = _objc_msgSend_fpret(self->_transparentColorAttributes,sel_lightnessTolerance);
  self->_initialTransparentColorLightnessTolerance = dVar2;
  _objc_msgSend(self,sel_makeCurrentEqualToInitial);
  return;
}

*/
- (void)setUpInitialSettings
{
    _isTransparentColorEnabledInitially = [_transparentColorAttributes isTransparentColorEnabled];
    id color = [_transparentColorAttributes transparentColor];
    if (_initialTransparentColor != color) {
        [_initialTransparentColor release];
        _initialTransparentColor = [color retain];
    }
    _initialTransparentColorHueTolerance = [_transparentColorAttributes hueTolerance];
    _initialTransparentColorChromaTolerance = [_transparentColorAttributes chromaTolerance];
    _initialTransparentColorLightnessTolerance = [_transparentColorAttributes lightnessTolerance];
    [self makeCurrentEqualToInitial];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002841e5 @ 002841e5, 187 bytes * /

void FUN_002841e5(HSTransparentColorApplier *self,SEL _cmd)

{
  undefined4 uVar1;
  
  uVar1 = 0xffffffff;
  if ((self->_isTransparentColorEnabledInitially[0] & 2) == 0) {
    uVar1 = 0;
  }
  _objc_msgSend(self->_transparentColorAttributes,sel_setTransparentColorEnabled_,uVar1);
  _objc_msgSend(self->_transparentColorAttributes,sel_setTransparentColor_,self->_transparentColor);
  _objc_msgSend(self->_transparentColorAttributes,sel_setHueTolerance_,
                self->_transparentColorHueTolerance);
  _objc_msgSend(self->_transparentColorAttributes,sel_setChromaTolerance_,
                self->_transparentColorChromaTolerance);
  _objc_msgSend(self->_transparentColorAttributes,sel_setLightnessTolerance_,
                self->_transparentColorLightnessTolerance);
  return;
}

*/
- (void)setCurrentSettingsToObject
{
    [_transparentColorAttributes setTransparentColorEnabled:_isTransparentColorEnabled ? YES : NO];
    [_transparentColorAttributes setTransparentColor:_transparentColor];
    [_transparentColorAttributes setHueTolerance:_transparentColorHueTolerance];
    [_transparentColorAttributes setChromaTolerance:_transparentColorChromaTolerance];
    [_transparentColorAttributes setLightnessTolerance:_transparentColorLightnessTolerance];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0028412a @ 0028412a, 187 bytes * /

void FUN_0028412a(HSTransparentColorApplier *self,SEL _cmd)

{
  undefined4 uVar1;
  
  uVar1 = 0xffffffff;
  if ((self->_isTransparentColorEnabledInitially[0] & 1) == 0) {
    uVar1 = 0;
  }
  _objc_msgSend(self->_transparentColorAttributes,sel_setTransparentColorEnabled_,uVar1);
  _objc_msgSend(self->_transparentColorAttributes,sel_setTransparentColor_,
                self->_initialTransparentColor);
  _objc_msgSend(self->_transparentColorAttributes,sel_setHueTolerance_,
                self->_initialTransparentColorHueTolerance);
  _objc_msgSend(self->_transparentColorAttributes,sel_setChromaTolerance_,
                self->_initialTransparentColorChromaTolerance);
  _objc_msgSend(self->_transparentColorAttributes,sel_setLightnessTolerance_,
                self->_initialTransparentColorLightnessTolerance);
  return;
}

*/
- (void)setInitialSettingsToObject
{
    [_transparentColorAttributes setTransparentColorEnabled:_isTransparentColorEnabledInitially ? YES : NO];
    [_transparentColorAttributes setTransparentColor:_initialTransparentColor];
    [_transparentColorAttributes setHueTolerance:_initialTransparentColorHueTolerance];
    [_transparentColorAttributes setChromaTolerance:_initialTransparentColorChromaTolerance];
    [_transparentColorAttributes setLightnessTolerance:_initialTransparentColorLightnessTolerance];
}

- (void)setTransparentColorLightnessTolerance:(double)aTolerance
{
    if (_transparentColorLightnessTolerance != aTolerance) {
        _transparentColorLightnessTolerance = aTolerance;
        [self disableUndo];
        [_transparentColorAttributes setLightnessTolerance:_transparentColorLightnessTolerance];
        [self enableUndo];
    }
}

- (void)setTransparentColorChromaTolerance:(double)aTolerance
{
    if (_transparentColorChromaTolerance != aTolerance) {
        _transparentColorChromaTolerance = aTolerance;
        [self disableUndo];
        [_transparentColorAttributes setChromaTolerance:_transparentColorChromaTolerance];
        [self enableUndo];
    }
}

- (void)setTransparentColorHueTolerance:(double)aTolerance
{
    if (_transparentColorHueTolerance != aTolerance) {
        _transparentColorHueTolerance = aTolerance;
        [self disableUndo];
        [_transparentColorAttributes setHueTolerance:_transparentColorHueTolerance];
        [self enableUndo];
    }
}

- (void)setTransparentColorAllTolerances:(double)aTolerances
{
    [self setTransparentColorHueTolerance:aTolerances];
    [self setTransparentColorChromaTolerance:aTolerances];
    [self setTransparentColorLightnessTolerance:aTolerances];
}

- (void)resetTransparentColorLightnessTolerance
{
    _initialTransparentColorLightnessTolerance = [_transparentColorAttributes lightnessTolerance];
    [self disableUndo];
    [_transparentColorAttributes setLightnessTolerance:_transparentColorLightnessTolerance];
    [self enableUndo];
}

- (void)restoreTransparentColorLightnessTolerance
{
    [self disableUndo];
    [_transparentColorAttributes setLightnessTolerance:_initialTransparentColorLightnessTolerance];
    [self enableUndo];
}

- (void)resetTransparentColorChromaTolerance
{
    _initialTransparentColorChromaTolerance = [_transparentColorAttributes chromaTolerance];
    [self disableUndo];
    [_transparentColorAttributes setChromaTolerance:_transparentColorChromaTolerance];
    [self enableUndo];
}

- (void)restoreTransparentColorChromaTolerance
{
    [self disableUndo];
    [_transparentColorAttributes setChromaTolerance:_initialTransparentColorChromaTolerance];
    [self enableUndo];
}

- (void)resetTransparentColorHueTolerance
{
    _initialTransparentColorHueTolerance = [_transparentColorAttributes hueTolerance];
    [self disableUndo];
    [_transparentColorAttributes setHueTolerance:_transparentColorHueTolerance];
    [self enableUndo];
}

- (void)restoreTransparentColorHueTolerance
{
    [self disableUndo];
    [_transparentColorAttributes setHueTolerance:_initialTransparentColorHueTolerance];
    [self enableUndo];
}

- (void)setTransparentColor:(id)aColor
{
    if (_transparentColor != aColor) {
        [aColor retain];
        [_transparentColor release];
        _transparentColor = aColor;
        [self disableUndo];
        [_transparentColorAttributes setTransparentColor:_transparentColor];
        [self enableUndo];
    }
}

- (void)resetTransparentColor
{
    id pvVar1;

    pvVar1 = [_transparentColorAttributes transparentColor];
    if (_initialTransparentColor != pvVar1) {
        [_initialTransparentColor release];
        _initialTransparentColor = [pvVar1 retain];
    }
    [self disableUndo];
    [_transparentColorAttributes setTransparentColor:_transparentColor];
    [self enableUndo];
}

- (void)restoreTransparentColor
{
    [self disableUndo];
    [_transparentColorAttributes setTransparentColor:_initialTransparentColor];
    [self enableUndo];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00283c31 @ 00283c31, 136 bytes * /

void FUN_00283c31(HSTransparentColorApplier *self,SEL _cmd,BOOL setTransparentColorEnabled)

{
  byte bVar1;
  undefined4 uVar2;
  
  bVar1 = self->_isTransparentColorEnabledInitially[0] & 2;
  if (setTransparentColorEnabled == '\0') {
    if (bVar1 == 0) {
      return;
    }
  }
  else if (bVar1 != 0) {
    return;
  }
  self->_isTransparentColorEnabledInitially[0] =
       setTransparentColorEnabled * '\x02' & 2U |
       self->_isTransparentColorEnabledInitially[0] & 0xfd;
  _objc_msgSend(self,sel_disableUndo);
  uVar2 = 0xffffffff;
  if ((self->_isTransparentColorEnabledInitially[0] & 2) == 0) {
    uVar2 = 0;
  }
  _objc_msgSend(self->_transparentColorAttributes,sel_setTransparentColorEnabled_,uVar2);
  _objc_msgSend(self,sel_enableUndo);
  return;
}

*/
- (void)setTransparentColorEnabled:(BOOL)aEnabled
{
    if ((BOOL)_isTransparentColorEnabled == aEnabled) {
        return;
    }
    _isTransparentColorEnabled = aEnabled;
    [self disableUndo];
    [_transparentColorAttributes setTransparentColorEnabled:_isTransparentColorEnabled ? YES : NO];
    [self enableUndo];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00283bac @ 00283bac, 133 bytes * /

void FUN_00283bac(HSTransparentColorApplier *self,SEL _cmd)

{
  id pvVar1;
  undefined4 uVar2;
  
  pvVar1 = _objc_msgSend(self->_transparentColorAttributes,sel_isTransparentColorEnabled);
  self->_isTransparentColorEnabledInitially[0] =
       self->_isTransparentColorEnabledInitially[0] & 0xfe | (byte)pvVar1 & 1;
  _objc_msgSend(self,sel_disableUndo);
  uVar2 = 0xffffffff;
  if ((self->_isTransparentColorEnabledInitially[0] & 2) == 0) {
    uVar2 = 0;
  }
  _objc_msgSend(self->_transparentColorAttributes,sel_setTransparentColorEnabled_,uVar2);
  _objc_msgSend(self,sel_enableUndo);
  return;
}

*/
- (void)resetTransparentColorEnablement
{
    _isTransparentColorEnabledInitially = [_transparentColorAttributes isTransparentColorEnabled];
    [self disableUndo];
    [_transparentColorAttributes setTransparentColorEnabled:_isTransparentColorEnabled ? YES : NO];
    [self enableUndo];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00283b49 @ 00283b49, 99 bytes * /

void FUN_00283b49(HSTransparentColorApplier *self,SEL _cmd)

{
  undefined4 uVar1;
  
  _objc_msgSend(self,sel_disableUndo);
  uVar1 = 0xffffffff;
  if ((self->_isTransparentColorEnabledInitially[0] & 1) == 0) {
    uVar1 = 0;
  }
  _objc_msgSend(self->_transparentColorAttributes,sel_setTransparentColorEnabled_,uVar1);
  _objc_msgSend(self,sel_enableUndo);
  return;
}

*/
- (void)restoreTransparentColorEnablement
{
    [self disableUndo];
    [_transparentColorAttributes setTransparentColorEnabled:_isTransparentColorEnabledInitially ? YES : NO];
    [self enableUndo];
}

- (id)undoActionName
{
    return [[NSBundle mainBundle] localizedStringForKey:@"Change Transparent Color Settings" value:@"" table:@"UndoManager"];
}

- (void)setDelegate:(id)aDelegate
{
    [super setDelegate:aDelegate];
    _transparentColorAttributes = [[aDelegate transparentColorAttributes] retain];
}

- (void)dealloc
{
    [_initialTransparentColor release];
    [_transparentColor release];
    [_transparentColorAttributes release];
    [super dealloc];
}

@end

