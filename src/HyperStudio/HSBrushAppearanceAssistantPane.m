#import "HSBrushAppearanceAssistantPane.h"

@implementation HSBrushAppearanceAssistantPane

/* i386 ivar offsets: _brushColorWell=0x5c, _nameTextField=0x60, _brushSizeSlider=0x64, _brushSizeTextField=0x68, _brushSizeStepper=0x6c, _opacitySlider=0x70, _opacityTextField=0x74, _opacityStepper=0x78, _shadowSwitch=0x7c, _shadowButton=0x80 */

- (id)shadowAttributes
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSMutableShadowAttributes)];
}

- (id)opacityAttributes
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSMutableOpacityAttributes)];
}

- (id)vectorGraphicsAttributes
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSMutableVectorGraphicsAttributes)];
}

- (id)brushAttributes
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSBrushMutableAttributes)];
}

- (id)objectAttributes
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSMutableObjectAttributes)];
}

- (void)validateShadowUI
{
    char cVar1;
    id pvVar2;
    NSString *pcVar3;

    pvVar2 = [self shadowAttributes];
    if (pvVar2 != nil) {
        cVar1 = [pvVar2 isHyperShadowEnabled];
        [_shadowSwitch setEnabled:YES];
        [_shadowSwitch setState:cVar1 != NO];
        [_shadowButton setHidden:((unsigned int)(cVar1 == NO))];
        if (cVar1 == NO) {
            pcVar3 = [_shadowButton title];
        }
        else {
            pcVar3 = @"";
        }
        [_shadowSwitch setTitle:pcVar3];
    }
}

- (void)validateOpacityUI
{
    id self_00;
    float fVar1;

    self_00 = [self opacityAttributes];
    if (self_00 != nil) {
        fVar1 = (float)[self_00 hyperOpacity] * 100.0;
        [_opacitySlider setFloatValue:fVar1];
        [_opacityTextField setFloatValue:fVar1];
        [_opacityStepper setFloatValue:fVar1];
    }
}

- (void)validateColorUI
{
    float fVar1;
    id pvVar2_3;

    fVar1 = (float)[[self vectorGraphicsAttributes] hyperLineWidth];
    [_brushSizeSlider setFloatValue:fVar1];
    [_brushSizeTextField setFloatValue:fVar1];
    [_brushSizeStepper setFloatValue:fVar1];
    pvVar2_3 = [[self vectorGraphicsAttributes] hyperStrokeColor];
    if (pvVar2_3 != nil) {
        [_brushColorWell setColor:pvVar2_3];
    }
}

- (void)validateBrushUI
{
    id pvVar1;
    float fVar4;

    pvVar1 = [self brushAttributes];
    if (pvVar1 != nil) {
        fVar4 = (float)[pvVar1 brushThickness];
        [_brushSizeSlider setFloatValue:fVar4];
        [_brushSizeTextField setFloatValue:fVar4];
        [_brushSizeStepper setFloatValue:fVar4];
        if ([pvVar1 brushColor] != nil) {
            [_brushColorWell setColor:[pvVar1 brushColor]];
        }
    }
}

- (void)validateUI
{
    id pvVar1;

    pvVar1 = [self objectAttributes];
    if (pvVar1 != nil) {
        [_nameTextField setStringValue:[pvVar1 hyperName]];
    }
}

- (void)validateColorUIWithNotification:(id)aNotification
{
    [self validateColorUI];
}

- (void)validateShadowUIWithNotification:(id)aNotification
{
    [self validateShadowUI];
}

- (void)validateOpacityUIWithNotification:(id)aNotification
{
    [self validateOpacityUI];
}

- (void)validateBrushUIWithNotification:(id)aNotification
{
    [self validateBrushUI];
}

- (void)validateUIWithNotification:(id)aNotification
{
    [self validateUI];
}

- (void)editShadow:(id)aShadow
{
    [self showShadowPane];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00188af3 @ 00188af3, 207 bytes * /

void FUN_00188af3(HSBrushAppearanceAssistantPane *self,SEL _cmd,id setShadow)

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

- (void)opacityChanged:(id)aChanged
{
    double dVar1;

    dVar1 = [aChanged floatValue];
    [[self opacityAttributes] setHyperOpacity:(float)dVar1 / 100.0];
}

- (void)brushSizeTextFieldValueChanged:(id)aChanged
{
    float fVar1;

    fVar1 = (float)[aChanged floatValue];
    if (_brushSizeTextField == aChanged) {
        if ((float)[[[aChanged formatter] minimum] floatValue] <= fVar1) {
            if (fVar1 <= (float)[[[aChanged formatter] maximum] floatValue]) {
                [self setBrushSize:fVar1];
            }
        }
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-multiple-method-names"
- (void)sizeChanged:(id)aChanged
{
    double dVar1;
    double dVar2;
    double dVar3;

    dVar2 = [aChanged floatValue];
    if (aChanged != nil) {
        dVar3 = [aChanged minValue];
        dVar1 = (double)(float)dVar2;
        if (dVar3 <= dVar1) {
            if (dVar1 <= [aChanged maxValue]) {
                [self setBrushSize:(float)dVar2];
            }
        }
    }
}
#pragma clang diagnostic pop

/* --- i386 decompilation (Ghidra) ---
/* FUN_00188e57 @ 00188e57, 216 bytes * /

void FUN_00188e57(HSBrushAppearanceAssistantPane *self,SEL _cmd,float setBrushSize)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  SEL op;
  
  self_00 = _objc_msgSend(self,sel_assistant);
  pvVar1 = _objc_msgSend(self_00,sel_isCurrentlyWorkingInSOTSMode);
  if ((char)pvVar1 != '\0') {
    _objc_msgSend(self_00,sel_toggleInspectorMode_,self);
  }
  pvVar2 = _objc_msgSend(self,sel_brushAttributes);
  if (pvVar2 == (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_vectorGraphicsAttributes);
    op = sel_setHyperLineWidth_;
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_brushAttributes);
    op = sel_setBrushThickness_;
  }
  _objc_msgSend(pvVar2,op,setBrushSize);
  if ((char)pvVar1 != '\0') {
    _objc_msgSend(self_00,sel_toggleInspectorMode_,self);
  }
  return;
}

*/
- (void)setBrushSize:(CGFloat)aSize
{
    id assistant = [self assistant];
    BOOL sotsMode = [assistant isCurrentlyWorkingInSOTSMode];
    if (sotsMode) {
        [assistant toggleInspectorMode:self];
    }
    if ([self brushAttributes] == nil) {
        [[self vectorGraphicsAttributes] setHyperLineWidth:aSize];
    } else {
        [[self brushAttributes] setBrushThickness:aSize];
    }
    if (sotsMode) {
        [assistant toggleInspectorMode:self];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00188f2f @ 00188f2f, 147 bytes * /

void FUN_00188f2f(HSBrushAppearanceAssistantPane *self,SEL _cmd,id colorChanged)

{
  id self_00;
  id pvVar1;
  SEL op;
  
  self_00 = _objc_msgSend(self,sel_brushAttributes);
  if (self_00 == (id)0x0) {
    self_00 = _objc_msgSend(self,sel_vectorGraphicsAttributes);
    pvVar1 = _objc_msgSend(colorChanged,sel_color);
    op = sel_setHyperStrokeColor_;
  }
  else {
    pvVar1 = _objc_msgSend(colorChanged,sel_color);
    op = sel_setBrushColor_;
  }
  _objc_msgSend(self_00,op,pvVar1);
  return;
}

*/
- (void)colorChanged:(id)aChanged
{
    if ([self brushAttributes] == nil) {
        [[self vectorGraphicsAttributes] setHyperStrokeColor:[aChanged color]];
    } else {
        [[self brushAttributes] setBrushColor:[aChanged color]];
    }
}

- (void)setName:(id)aName
{
    [[self objectAttributes] setHyperName:[aName stringValue]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00189019 @ 00189019, 110 bytes * /

BOOL FUN_00189019(HSBrushAppearanceAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self->_nameTextField,sel_currentEditor);
  if ((pvVar1 == (id)0x0) &&
     (pvVar1 = _objc_msgSend(self->_brushSizeTextField,sel_currentEditor), pvVar1 == (id)0x0)) {
    pvVar1 = _objc_msgSend(self->_opacityTextField,sel_currentEditor);
    return pvVar1 != (id)0x0;
  }
  return '\x01';
}

*/
- (BOOL)isEditingTextAttribute
{
    return [_nameTextField currentEditor] != nil || [_brushSizeTextField currentEditor] != nil || [_opacityTextField currentEditor] != nil;
    return 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00189087 @ 00189087, 545 bytes * /

void FUN_00189087(HSBrushAppearanceAssistantPane *self,SEL _cmd,BOOL viewWillDisappear)

{
  undefined4 uVar1;
  id pvVar2;
  id pvVar3;
  undefined *puVar4;
  undefined *puVar5;
  HSBrushAppearanceAssistantPane *pHVar6;
  undefined4 uVar7;
  HSBrushAppearanceAssistantPane *local_1c;
  undefined *local_18;
  
  pvVar2 = _objc_msgSend(self,sel_objectAttributes);
  pvVar2 = _objc_msgSend(pvVar2,sel_attributeObservingController);
  puVar5 = &DAT_003797dc;
  uVar1 = *(undefined4 *)PTR_0033601c;
  pHVar6 = self;
  puVar4 = sel_validateUIWithNotification_;
  uVar7 = uVar1;
  _objc_msgSend(pvVar2,sel_removeObserver_selector_ofChanges_ofAttributesOfHyperInterface_,self,
                sel_validateUIWithNotification_,uVar1,&DAT_003797dc);
  pvVar2 = _objc_msgSend(self,sel_brushAttributes);
  if (pvVar2 == (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_assistant,pHVar6,puVar4,uVar7,puVar5);
    pvVar2 = _objc_msgSend(pvVar2,sel_object);
    pHVar6 = (HSBrushAppearanceAssistantPane *)&DAT_00379994;
    pvVar3 = _objc_msgSend(pvVar2,sel_implementsHyperInterface_,&DAT_00379994);
    if ((char)pvVar3 == '\0') goto LAB_001891c7;
    pvVar2 = _objc_msgSend(pvVar2,sel_attributeObservingController,pHVar6);
    puVar5 = &DAT_003799a8;
    puVar4 = sel_validateColorUIWithNotification_;
  }
  else {
    pvVar2 = _objc_msgSend(pvVar2,sel_attributeObservingController,pHVar6,puVar4,uVar7,puVar5);
    puVar5 = &DAT_003798f4;
    puVar4 = sel_validateBrushUIWithNotification_;
  }
  pHVar6 = self;
  uVar7 = uVar1;
  _objc_msgSend(pvVar2,sel_removeObserver_selector_ofChanges_ofAttributesOfHyperInterface_,self,
                puVar4,uVar1,puVar5);
LAB_001891c7:
  pvVar2 = _objc_msgSend(self,sel_opacityAttributes,pHVar6,puVar4,uVar7,puVar5);
  pvVar2 = _objc_msgSend(pvVar2,sel_attributeObservingController);
  _objc_msgSend(pvVar2,sel_removeObserver_selector_ofChanges_ofAttributesOfHyperInterface_,self,
                sel_validateOpacityUIWithNotification_,uVar1,&DAT_00379ac0);
  pvVar2 = _objc_msgSend(self,sel_shadowAttributes);
  pvVar2 = _objc_msgSend(pvVar2,sel_attributeObservingController);
  _objc_msgSend(pvVar2,sel_removeObserver_selector_ofChanges_ofAttributesOfHyperInterface_,self,
                sel_validateShadowUIWithNotification_,uVar1,&DAT_00379afc);
  local_1c = self;
  local_18 = PTR_s_HSObjectAssistantPane_00352790;
  _objc_msgSendSuper(&local_1c,sel_viewWillDisappear_,(int)viewWillDisappear);
  return;
}

*/
- (void)viewWillDisappear:(BOOL)aDisappear
{
    [[[self objectAttributes] attributeObservingController] removeObserver:self selector:@selector(validateUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSMutableObjectAttributes)];
    if ([self brushAttributes] == nil) {
        id object = [[self assistant] object];
        if ([object implementsHyperInterface:@protocol(HSMutableVectorGraphicsAttributes)]) {
            [[object attributeObservingController] removeObserver:self selector:@selector(validateColorUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSVectorGraphicsAttributes)];
        }
    } else {
        [[[self brushAttributes] attributeObservingController] removeObserver:self selector:@selector(validateBrushUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSBrushMutableAttributes)];
    }
    [[[self opacityAttributes] attributeObservingController] removeObserver:self selector:@selector(validateOpacityUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSMutableOpacityAttributes)];
    [[[self shadowAttributes] attributeObservingController] removeObserver:self selector:@selector(validateShadowUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSMutableShadowAttributes)];
    [super viewWillDisappear:aDisappear];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001892a8 @ 001892a8, 716 bytes * /

void FUN_001892a8(HSBrushAppearanceAssistantPane *self,SEL _cmd,BOOL viewWillAppear)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  HSBrushAppearanceAssistantPane *pHVar3;
  undefined *puVar4;
  undefined4 uVar5;
  undefined *puVar6;
  undefined4 uVar7;
  undefined4 uVar8;
  HSBrushAppearanceAssistantPane *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSObjectAssistantPane_00352790;
  _objc_msgSendSuper(&local_1c,sel_viewWillAppear_,(int)viewWillAppear);
  pvVar1 = _objc_msgSend(self,sel_objectAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_attributeObservingController);
  puVar6 = &DAT_003797dc;
  uVar5 = *(undefined4 *)PTR_0033601c;
  uVar7 = 0xbe800000;
  pHVar3 = self;
  puVar4 = sel_validateUIWithNotification_;
  uVar8 = uVar5;
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttributesOfHyperInterface_withPriority_
                ,self,sel_validateUIWithNotification_,uVar5,&DAT_003797dc,0xbe800000,uVar5);
  _objc_msgSend(self,sel_validateUI);
  pvVar1 = _objc_msgSend(self,sel_brushAttributes);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_assistant,pHVar3,puVar4,uVar5,puVar6,uVar7);
    pvVar1 = _objc_msgSend(pvVar1,sel_object);
    pHVar3 = (HSBrushAppearanceAssistantPane *)&DAT_00379994;
    pvVar2 = _objc_msgSend(pvVar1,sel_implementsHyperInterface_,&DAT_00379994);
    op = sel_validateColorUI;
    if ((char)pvVar2 != '\0') {
      uVar5 = uVar8;
      pvVar1 = _objc_msgSend(pvVar1,sel_attributeObservingController,pHVar3);
      puVar6 = &DAT_003799a8;
      uVar7 = 0xbe800000;
      pHVar3 = self;
      puVar4 = sel_validateColorUIWithNotification_;
      uVar8 = uVar5;
      _objc_msgSend(pvVar1,
                    sel_addObserver_selector_ofChanges_ofAttributesOfHyperInterface_withPriority_,
                    self,sel_validateColorUIWithNotification_,uVar5,&DAT_003799a8,0xbe800000);
      op = sel_validateColorUI;
    }
  }
  else {
    pvVar1 = _objc_msgSend(pvVar1,sel_attributeObservingController,pHVar3,puVar4,uVar5,puVar6,uVar7)
    ;
    uVar5 = uVar8;
    puVar6 = &DAT_003798f4;
    uVar7 = 0xbe800000;
    pHVar3 = self;
    puVar4 = sel_validateBrushUIWithNotification_;
    uVar8 = uVar5;
    _objc_msgSend(pvVar1,
                  sel_addObserver_selector_ofChanges_ofAttributesOfHyperInterface_withPriority_,self
                  ,sel_validateBrushUIWithNotification_,uVar5,&DAT_003798f4,0xbe800000);
    op = sel_validateBrushUI;
  }
  _objc_msgSend(self,op,pHVar3,puVar4,uVar5,puVar6,uVar7);
  pvVar1 = _objc_msgSend(self,sel_opacityAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_attributeObservingController);
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttributesOfHyperInterface_withPriority_
                ,self,sel_validateOpacityUIWithNotification_,uVar8,&DAT_00379ac0,0xbe800000);
  pvVar1 = _objc_msgSend(self,sel_shadowAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_attributeObservingController);
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttributesOfHyperInterface_withPriority_
                ,self,sel_validateShadowUIWithNotification_,uVar8,&DAT_00379afc,0xbe800000);
  _objc_msgSend(self,sel_validateOpacityUI);
  _objc_msgSend(self,sel_validateShadowUI);
  return;
}

*/
- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [[[self objectAttributes] attributeObservingController] addObserver:self selector:@selector(validateUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSMutableObjectAttributes) withPriority:-0.25];
    [self validateUI];
    if ([self brushAttributes] == nil) {
        id object = [[self assistant] object];
        if ([object implementsHyperInterface:@protocol(HSMutableVectorGraphicsAttributes)]) {
            [[object attributeObservingController] addObserver:self selector:@selector(validateColorUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSVectorGraphicsAttributes) withPriority:-0.25];
        }
        [self validateColorUI];
    } else {
        [[[self brushAttributes] attributeObservingController] addObserver:self selector:@selector(validateBrushUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSBrushMutableAttributes) withPriority:-0.25];
        [self validateBrushUI];
    }
    [[[self opacityAttributes] attributeObservingController] addObserver:self selector:@selector(validateOpacityUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSMutableOpacityAttributes) withPriority:-0.25];
    [[[self shadowAttributes] attributeObservingController] addObserver:self selector:@selector(validateShadowUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSMutableShadowAttributes) withPriority:-0.25];
    [self validateOpacityUI];
    [self validateShadowUI];
}

- (id)init
{
    self = [super initWithNibName:@"BrushAppearanceAssistantPane"];
    if (self != nil) {
        [self setTitle:[[NSBundle mainBundle] localizedStringForKey:@"Appearance" value:@"" table:@"AssistantPanes"]];
        [self setIcon:[NSImage imageNamed:@"general"]];
    }
    return self;
}

@end

