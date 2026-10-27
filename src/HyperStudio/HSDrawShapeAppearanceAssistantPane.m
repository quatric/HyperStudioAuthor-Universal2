#import "HSDrawShapeAppearanceAssistantPane.h"

@implementation HSDrawShapeAppearanceAssistantPane

/* i386 ivar offsets: _fillColorWell=0x5c, _nameTextField=0x60, _outlineColorWell=0x64, _shadowButton=0x68, _shadowSwitch=0x6c, _fillTypeMatrix=0x70, _outlineSizeSlider=0x74, _outlineTextField=0x78, _outlineStepper=0x7c, _opacitySlider=0x80, _opacityTextField=0x84, _opacityStepper=0x88, _oldBackgroundGraphics=0x8c, _oldLineInfo=0x90, _hyperObjectForVectorGraphics=0x94 */

- (id)shapeTypeControlFillWithOutlineImage
{
    return [NSImage imageNamed:@"Stroke_Fill_Square"];
}

- (id)shapeTypeControlFillImage
{
    return [NSImage imageNamed:@"Fill_Square"];
}

- (id)shapeTypeControlOutlineImage
{
    return [NSImage imageNamed:@"Stroke_Square"];
}

- (id)opacityAttributes
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSMutableOpacityAttributes)];
}

- (id)shadowAttributes
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSMutableShadowAttributes)];
}

- (id)backgroundAttributes
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSMutableBackgroundAttributes)];
}

- (id)objectAttributes
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSMutableObjectAttributes)];
}

- (id)vectorGraphics
{
    return [[[self assistant] object] vg];
}

- (void)validateShadowUI
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

- (void)validateOpacityUI
{
    float fVar1;

    fVar1 = (float)[[self opacityAttributes] hyperOpacity] * 100.0;
    [_opacitySlider setFloatValue:fVar1];
    [_opacityTextField setFloatValue:fVar1];
    [_opacityStepper setFloatValue:fVar1];
}

- (void)validateUI
{
    [_nameTextField setStringValue:[[self objectAttributes] hyperName]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00189d8c @ 00189d8c, 1075 bytes * /

void FUN_00189d8c(HSDrawShapeAppearanceAssistantPane *self,SEL _cmd)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  undefined *self_00;
  undefined *puVar4;
  bool bVar5;
  double dVar6;
  SEL op;
  float fVar7;
  float local_24;
  float local_20;
  undefined *local_1c;
  
  pvVar2 = _objc_msgSend(self,sel_vectorGraphics);
  dVar6 = _objc_msgSend_fpret(pvVar2,sel_hyperLineWidth);
  fVar7 = (float)dVar6;
  if ((fVar7 != 0.0) || (NAN(fVar7))) {
    local_20 = ABS(fVar7);
  }
  else {
    local_20 = 1.0;
  }
  pvVar2 = _objc_msgSend(self,sel_backgroundAttributes);
  local_24 = 0.0005;
  if (1.0 <= local_20) {
    local_24 = local_20 * 0.0005;
  }
  pvVar2 = _objc_msgSend(pvVar2,sel_backgroundGraphics);
  if (pvVar2 == (id)0x0) {
LAB_00189e9b:
    if (ABS(fVar7) <= local_24) {
LAB_00189eaf:
      local_1c = (undefined *)0x3;
    }
    else {
      local_1c = (undefined *)0x1;
    }
  }
  else {
    pvVar3 = _objc_msgSend(cls_HSGraphics,sel_class);
    pvVar2 = _objc_msgSend(pvVar2,sel_isMemberOfClass_,pvVar3);
    if ((char)pvVar2 != '\0') goto LAB_00189e9b;
    if (local_24 < ABS(fVar7)) goto LAB_00189eaf;
    local_1c = (undefined *)0x2;
  }
  bVar5 = local_1c == (undefined *)0x1 || local_1c == (undefined *)0x3;
  puVar4 = local_1c;
  _objc_msgSend(self->_fillTypeMatrix,sel_selectCellWithTag_,local_1c);
  if (local_1c + -2 < (undefined *)0x2) {
    pvVar2 = _objc_msgSend(self,sel_backgroundAttributes,puVar4);
    pvVar2 = _objc_msgSend(pvVar2,sel_backgroundGraphics);
    puVar4 = &DAT_00379ee4;
    self_00 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_00379ee4);
    pvVar2 = _objc_msgSend(self_00,sel_isHyperGradient);
    puVar1 = cls_HSGradientColor;
    op = sel_hyperSolidColor;
    if ((char)pvVar2 != '\0') {
      _objc_msgSend(self_00,sel_hyperEndColor,puVar4);
      puVar4 = _objc_msgSend(self_00,sel_hyperStartColor);
      self_00 = puVar1;
      op = sel_gradientColorWithStartColor_endColor_;
    }
    pvVar3 = _objc_msgSend(self_00,op,puVar4);
    pvVar2 = self->_fillColorWell;
    if (pvVar3 != (id)0x0) goto LAB_00189ff1;
  }
  else {
    pvVar2 = self->_fillColorWell;
  }
  pvVar3 = _objc_msgSend(cls_NSColor,sel_clearColor,puVar4);
LAB_00189ff1:
  _objc_msgSend(pvVar2,sel_setColor_,pvVar3);
  pvVar2 = _objc_msgSend(self,sel_vectorGraphics);
  dVar6 = _objc_msgSend_fpret(pvVar2,sel_hyperLineWidth);
  fVar7 = (float)dVar6;
  _objc_msgSend(self->_outlineSizeSlider,sel_setFloatValue_,fVar7);
  _objc_msgSend(self->_outlineTextField,sel_setFloatValue_,fVar7);
  _objc_msgSend(self->_outlineStepper,sel_setFloatValue_,fVar7);
  pvVar2 = _objc_msgSend(self,sel_vectorGraphics);
  pvVar3 = _objc_msgSend(pvVar2,sel_hyperStrokeColor);
  pvVar2 = self->_outlineColorWell;
  if (pvVar3 == (id)0x0) {
    pvVar3 = _objc_msgSend(cls_NSColor,sel_clearColor,fVar7);
  }
  _objc_msgSend(pvVar2,sel_setColor_,pvVar3);
  if ((local_1c != (undefined *)0x1) && (local_1c != (undefined *)0x3)) {
    pvVar2 = self->_outlineColorWell;
    pvVar3 = _objc_msgSend(cls_NSColor,sel_clearColor,pvVar3);
    _objc_msgSend(pvVar2,sel_setColor_,pvVar3);
  }
  _objc_msgSend(self->_fillColorWell,sel_setEnabled_,(uint)(-(local_1c + -2 < (undefined *)0x2) & 1)
               );
  _objc_msgSend(self->_outlineSizeSlider,sel_setEnabled_,bVar5);
  _objc_msgSend(self->_outlineStepper,sel_setEnabled_,bVar5);
  _objc_msgSend(self->_outlineTextField,sel_setEditable_,bVar5);
  _objc_msgSend(self->_outlineColorWell,sel_setEnabled_,bVar5);
  return;
}

*/
- (void)validateColorUI
{
    float lineWidth = (float)[[self vectorGraphics] hyperLineWidth];
    float tolerance = 0.0005f * MAX(1.0f, fabsf(lineWidth));
    BOOL zeroWidth = fabsf(lineWidth) <= tolerance;
    id graphics = [[self backgroundAttributes] backgroundGraphics];
    BOOL hasFill = graphics != nil && ![graphics isMemberOfClass:[HSGraphics class]];
    NSInteger fillType;
    if (hasFill) {
        fillType = zeroWidth ? 2 : 3;
    }
    else {
        fillType = zeroWidth ? 3 : 1;
    }
    BOOL hasOutline = fillType == 1 || fillType == 3;
    [_fillTypeMatrix selectCellWithTag:fillType];
    id fillColor = nil;
    if (fillType == 2 || fillType == 3) {
        id color = [[[self backgroundAttributes] backgroundGraphics] queryHyperInterface:@protocol(HSColor)];
        if ([color isHyperGradient]) {
            fillColor = [HSGradientColor gradientColorWithStartColor:[color hyperStartColor] endColor:[color hyperEndColor]];
        }
        else {
            fillColor = [color hyperSolidColor];
        }
    }
    [_fillColorWell setColor:(fillColor != nil) ? fillColor : [NSColor clearColor]];
    lineWidth = (float)[[self vectorGraphics] hyperLineWidth];
    [_outlineSizeSlider setFloatValue:lineWidth];
    [_outlineTextField setFloatValue:lineWidth];
    [_outlineStepper setFloatValue:lineWidth];
    id strokeColor = [[self vectorGraphics] hyperStrokeColor];
    [_outlineColorWell setColor:(strokeColor != nil) ? strokeColor : [NSColor clearColor]];
    if (!hasOutline) {
        [_outlineColorWell setColor:[NSColor clearColor]];
    }
    [_fillColorWell setEnabled:fillType == 2 || fillType == 3];
    [_outlineSizeSlider setEnabled:hasOutline];
    [_outlineStepper setEnabled:hasOutline];
    [_outlineTextField setEditable:hasOutline];
    [_outlineColorWell setEnabled:hasOutline];
}

- (void)validateShadowUIWithNotification:(id)aNotification
{
    [self validateShadowUI];
}

- (void)validateOpacityUIWithNotification:(id)aNotification
{
    [self validateOpacityUI];
}

- (void)validateColorUIWithNotification:(id)aNotification
{
    [self validateColorUI];
}

- (void)validateUIWithNotification:(id)aNotification
{
    [self validateUI];
}

- (void)opacityChanged:(id)aChanged
{
    double dVar1;

    dVar1 = [aChanged floatValue];
    [[self opacityAttributes] setHyperOpacity:(float)dVar1 / 100.0];
}

- (void)editShadow:(id)aShadow
{
    [self showShadowPane];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018a2e2 @ 0018a2e2, 201 bytes * /

void FUN_0018a2e2(HSDrawShapeAppearanceAssistantPane *self,SEL _cmd,id setShadow)

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
    }
    else if (state == 1) {
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

- (void)outlineSizeChanged:(id)aChanged
{
    double dVar1;

    dVar1 = [aChanged floatValue];
    [[self vectorGraphics] setHyperLineWidth:(float)dVar1];
    [self storeLineWidthAsDefault];
}

- (void)outlineColorChanged:(id)aChanged
{
    [[self vectorGraphics] setHyperStrokeColor:[aChanged color]];
    [self storeStrokeLineColorAsDefault];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018a527 @ 0018a527, 702 bytes * /

void FUN_0018a527(HSDrawShapeAppearanceAssistantPane *self,SEL _cmd,id fillColorChanged)

{
  undefined *puVar1;
  int iVar2;
  int iVar3;
  id pvVar4;
  id pvVar5;
  undefined *self_00;
  SEL op;
  id local_80;
  id local_7c;
  int local_74 [23];
  undefined *local_18;
  HSDrawShapeAppearanceAssistantPane *local_14;
  
  local_14 = self;
  local_18 = fillColorChanged;
  local_80 = (id)0x0;
  _objc_exception_try_enter(local_74);
  iVar2 = __setjmp(local_74);
  if (iVar2 == 0) {
    pvVar4 = _objc_msgSend(local_18,sel_color);
    local_80 = _objc_msgSend(pvVar4,sel_patternImage);
  }
  else {
    iVar3 = _objc_exception_extract(local_74);
    _objc_exception_try_enter(local_74);
    iVar2 = __setjmp(local_74);
    if (iVar2 == 0) {
      iVar2 = _objc_exception_match(cls_NSException,iVar3);
      if (iVar2 != 0) goto LAB_0018a5c1;
      _objc_exception_try_exit(local_74);
    }
    else {
      iVar3 = _objc_exception_extract(local_74);
    }
    if (iVar3 != 0) {
                    /* WARNING: Subroutine does not return * /
      _objc_exception_throw(iVar3);
    }
  }
LAB_0018a5c1:
  _objc_exception_try_exit(local_74);
  pvVar4 = _objc_msgSend(local_18,sel_color);
  pvVar5 = _objc_msgSend(cls_HSGradientColor,sel_class);
  pvVar4 = _objc_msgSend(pvVar4,sel_isKindOfClass_,pvVar5);
  puVar1 = cls_HSGradientColor;
  self_00 = local_18;
  op = sel_color;
  if ((char)pvVar4 == '\0') {
    if (local_80 != (id)0x0) {
      pvVar4 = _objc_msgSend(cls_HSColor,sel_new,pvVar5);
      local_7c = _objc_msgSend(pvVar4,sel_autorelease);
      _objc_msgSend(local_7c,sel_setSolid_,1);
      pvVar4 = _objc_msgSend(local_18,sel_color);
      _objc_msgSend(local_7c,sel_setStartColor_,pvVar4);
      pvVar5 = _objc_msgSend(local_18,sel_color);
      _objc_msgSend(local_7c,sel_setEndColor_,pvVar5);
      goto LAB_0018a74a;
    }
    _objc_msgSend(local_18,sel_color,pvVar5);
    pvVar5 = _objc_msgSend(local_18,sel_color);
    self_00 = puVar1;
    op = sel_gradientColorWithStartColor_endColor_;
  }
  pvVar4 = _objc_msgSend(self_00,op,pvVar5);
  local_7c = _objc_msgSend(pvVar4,sel_hyperHSColor);
LAB_0018a74a:
  pvVar4 = _objc_msgSend(local_14,sel_backgroundAttributes,pvVar5);
  pvVar5 = _objc_msgSend(local_7c,sel_queryHyperInterface_,&DAT_00379ef8);
  _objc_msgSend(pvVar4,sel_setBackgroundGraphics_,pvVar5);
  _objc_msgSend(local_14,sel_storeBackgroundGraphicsAsDefault);
  return;
}

*/
- (void)fillColorChanged:(id)aChanged
{
    NSImage *patternImage = nil;
    @try {
        patternImage = [[aChanged color] patternImage];
    }
    @catch (NSException *exception) {
    }
    id hsColor;
    if ([[aChanged color] isKindOfClass:[HSGradientColor class]]) {
        hsColor = [[aChanged color] hyperHSColor];
    }
    else if (patternImage != nil) {
        hsColor = [[HSColor new] autorelease];
        [hsColor setSolid:YES];
        [hsColor setStartColor:[aChanged color]];
        [hsColor setEndColor:[aChanged color]];
    }
    else {
        hsColor = [[HSGradientColor gradientColorWithStartColor:[aChanged color] endColor:[aChanged color]] hyperHSColor];
    }
    [[self backgroundAttributes] setBackgroundGraphics:[hsColor queryHyperInterface:@protocol(HSGraphics)]];
    [self storeBackgroundGraphicsAsDefault];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018a7e5 @ 0018a7e5, 1180 bytes * /

void FUN_0018a7e5(HSDrawShapeAppearanceAssistantPane *self,SEL _cmd,id fillTypeChanged)

{
  float fVar1;
  bool bVar2;
  id pvVar3;
  id pvVar4;
  float fVar5;
  float fVar6;
  double dVar7;
  SEL op;
  undefined4 uVar8;
  float local_24;
  float local_20;
  
  pvVar3 = _objc_msgSend(fillTypeChanged,sel_selectedCell);
  pvVar3 = _objc_msgSend(pvVar3,sel_tag);
  if (pvVar3 != (id)0x3) {
    if (pvVar3 == (id)0x2) {
      _objc_msgSend(self,sel_storeLineWidthAsDefault);
      pvVar3 = _objc_msgSend(self,sel_vectorGraphics);
      _objc_msgSend(pvVar3,sel_setHyperLineWidth_,0);
      _objc_msgSend(self,sel_storeStrokeLineColorAsDefault);
      pvVar3 = _objc_msgSend(self,sel_vectorGraphics);
      pvVar4 = (id)0x0;
      _objc_msgSend(pvVar3,sel_setHyperStrokeColor_,0);
      pvVar3 = _objc_msgSend(self,sel_backgroundAttributes);
      pvVar3 = _objc_msgSend(pvVar3,sel_backgroundGraphics);
      if (pvVar3 != (id)0x0) {
        pvVar3 = _objc_msgSend(self,sel_backgroundAttributes,pvVar4);
        pvVar3 = _objc_msgSend(pvVar3,sel_backgroundGraphics);
        pvVar4 = _objc_msgSend(cls_HSGraphics,sel_class);
        pvVar3 = _objc_msgSend(pvVar3,sel_isMemberOfClass_,pvVar4);
        if ((char)pvVar3 == '\0') {
          return;
        }
      }
      pvVar3 = _objc_msgSend(self,sel_backgroundAttributes,pvVar4);
      pvVar4 = _objc_msgSend(self,sel_defaultBackgroundGraphics);
      op = sel_setBackgroundGraphics_;
    }
    else {
      if (pvVar3 != (id)0x1) {
        return;
      }
      _objc_msgSend(self,sel_storeBackgroundGraphicsAsDefault);
      pvVar3 = _objc_msgSend(self,sel_backgroundAttributes);
      uVar8 = 0;
      _objc_msgSend(pvVar3,sel_setBackgroundGraphics_,0);
      pvVar3 = _objc_msgSend(self,sel_vectorGraphics);
      dVar7 = _objc_msgSend_fpret(pvVar3,sel_hyperLineWidth);
      fVar1 = (float)dVar7;
      if ((fVar1 != 0.0) || (NAN(fVar1))) {
        fVar5 = ABS(fVar1);
      }
      else {
        fVar5 = 1.0;
      }
      fVar6 = 0.0005;
      if (1.0 <= fVar5) {
        fVar6 = fVar5 * 0.0005;
      }
      if (fVar6 < ABS(fVar1)) {
        return;
      }
      pvVar3 = _objc_msgSend(self,sel_vectorGraphics,uVar8);
      dVar7 = _objc_msgSend_fpret(self,sel_defaultLineWidth);
      _objc_msgSend(pvVar3,sel_setHyperLineWidth_,(float)dVar7);
      pvVar3 = _objc_msgSend(self,sel_vectorGraphics);
      pvVar4 = _objc_msgSend(self,sel_defaultStrokeLineColor);
      op = sel_setHyperStrokeColor_;
    }
    goto LAB_0018aa94;
  }
  pvVar3 = _objc_msgSend(self,sel_vectorGraphics);
  dVar7 = _objc_msgSend_fpret(pvVar3,sel_hyperLineWidth);
  fVar1 = (float)dVar7;
  if ((fVar1 != 0.0) || (NAN(fVar1))) {
    local_20 = ABS(fVar1);
  }
  else {
    local_20 = 1.0;
  }
  pvVar3 = _objc_msgSend(self,sel_backgroundAttributes);
  local_24 = 0.0005;
  if (1.0 <= local_20) {
    local_24 = local_20 * 0.0005;
  }
  pvVar3 = _objc_msgSend(pvVar3,sel_backgroundGraphics);
  if (pvVar3 == (id)0x0) {
LAB_0018aba8:
    bVar2 = false;
  }
  else {
    pvVar4 = _objc_msgSend(cls_HSGraphics,sel_class);
    pvVar3 = _objc_msgSend(pvVar3,sel_isMemberOfClass_,pvVar4);
    if ((char)pvVar3 != '\0') goto LAB_0018aba8;
    bVar2 = true;
  }
  if (ABS(fVar1) <= local_24) {
    pvVar3 = _objc_msgSend(self,sel_vectorGraphics);
    dVar7 = _objc_msgSend_fpret(self,sel_defaultLineWidth);
    _objc_msgSend(pvVar3,sel_setHyperLineWidth_,(float)dVar7);
    pvVar3 = _objc_msgSend(self,sel_vectorGraphics);
    pvVar4 = _objc_msgSend(self,sel_defaultStrokeLineColor);
    _objc_msgSend(pvVar3,sel_setHyperStrokeColor_,pvVar4);
  }
  if (bVar2) {
    return;
  }
  pvVar3 = _objc_msgSend(self,sel_backgroundAttributes);
  pvVar4 = _objc_msgSend(self,sel_defaultBackgroundGraphics);
  op = sel_setBackgroundGraphics_;
LAB_0018aa94:
  _objc_msgSend(pvVar3,op,pvVar4);
  return;
}

*/
- (void)fillTypeChanged:(id)aChanged
{
    NSInteger tag = [[aChanged selectedCell] tag];
    if (tag == 2) {
        [self storeLineWidthAsDefault];
        [[self vectorGraphics] setHyperLineWidth:0.0];
        [self storeStrokeLineColorAsDefault];
        [[self vectorGraphics] setHyperStrokeColor:nil];
        id graphics = [[self backgroundAttributes] backgroundGraphics];
        if (graphics != nil && ![graphics isMemberOfClass:[HSGraphics class]]) {
            return;
        }
        [[self backgroundAttributes] setBackgroundGraphics:[self defaultBackgroundGraphics]];
        return;
    }
    if (tag == 1) {
        [self storeBackgroundGraphicsAsDefault];
        [[self backgroundAttributes] setBackgroundGraphics:nil];
        float lineWidth = (float)[[self vectorGraphics] hyperLineWidth];
        if (0.0005f * MAX(1.0f, fabsf(lineWidth)) < fabsf(lineWidth)) {
            return;
        }
        [[self vectorGraphics] setHyperLineWidth:[self defaultLineWidth]];
        [[self vectorGraphics] setHyperStrokeColor:[self defaultStrokeLineColor]];
        return;
    }
    if (tag != 3) {
        return;
    }
    float lineWidth = (float)[[self vectorGraphics] hyperLineWidth];
    float tolerance = 0.0005f * MAX(1.0f, fabsf(lineWidth));
    id graphics = [[self backgroundAttributes] backgroundGraphics];
    BOOL hasFill = graphics != nil && ![graphics isMemberOfClass:[HSGraphics class]];
    if (fabsf(lineWidth) <= tolerance) {
        [[self vectorGraphics] setHyperLineWidth:[self defaultLineWidth]];
        [[self vectorGraphics] setHyperStrokeColor:[self defaultStrokeLineColor]];
    }
    if (!hasFill) {
        [[self backgroundAttributes] setBackgroundGraphics:[self defaultBackgroundGraphics]];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018ac81 @ 0018ac81, 159 bytes * /

id FUN_0018ac81(HSDrawShapeAppearanceAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  cfstringStruct *pcVar2;
  cfstringStruct *pcVar3;
  
  pvVar1 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  pvVar1 = _objc_msgSend(pvVar1,sel_volatileDomainForName_,
                         &cfstr_HSDrawShapeDefaultSettingsVolatileDomain);
  pcVar3 = &cfstr_HSDrawShapeStrokeLineColorKey;
  pcVar2 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_HSDrawShapeStrokeLineColorKey);
  if ((pcVar2 != (cfstringStruct *)0x0) &&
     (pvVar1 = _objc_msgSend(cls_NSObject,sel_objectWithExtraDictionary_,pcVar2), pcVar3 = pcVar2,
     pvVar1 != (id)0x0)) {
    return pvVar1;
  }
  pvVar1 = _objc_msgSend(cls_NSColor,sel_blackColor,pcVar3);
  return pvVar1;
}

*/
- (id)defaultStrokeLineColor
{
    NSDictionary *domain = [[NSUserDefaults standardUserDefaults] volatileDomainForName:@"HSDrawShapeDefaultSettingsVolatileDomain"];
    id representation = [domain objectForKey:@"HSDrawShapeStrokeLineColorKey"];
    if (representation != nil) {
        id color = [NSObject objectWithExtraDictionary:representation];
        if (color != nil) {
            return color;
        }
    }
    return [NSColor blackColor];
}

- (CGFloat)defaultLineWidth
{
    float fVar1;
    id pvVar2_3;

    pvVar2_3 = [[[NSUserDefaults standardUserDefaults] volatileDomainForName:@"HSDrawShapeDefaultSettingsVolatileDomain"] objectForKey:@"HSDrawShapeLineWidthKey"];
    if (pvVar2_3 == nil) {
        fVar1 = 1.0;
    }
    else {
        fVar1 = (float)[pvVar2_3 floatValue];
    }
    return fVar1;
}

- (id)defaultBackgroundGraphics
{
    id pvVar2;
    id pvVar1_4;

    pvVar2 = [[self backgroundAttributes] queryBackgroundGraphicsInterface:@protocol(HSMutableColor)];
    pvVar1_4 = [[[NSUserDefaults standardUserDefaults] volatileDomainForName:@"HSDrawShapeDefaultSettingsVolatileDomain"] objectForKey:@"HSDrawShapeBackgroundGraphicsKey"];
    if (pvVar1_4 != nil) {
        pvVar2 = [NSObject objectWithExtraDictionary:pvVar1_4];
    }
    return pvVar2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018ae59 @ 0018ae59, 536 bytes * /

void FUN_0018ae59(HSDrawShapeAppearanceAssistantPane *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  cfstringStruct *pcVar4;
  
  pvVar1 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  pcVar4 = &cfstr_HSDrawShapeDefaultSettingsVolatileDomain;
  pvVar1 = _objc_msgSend(pvVar1,sel_volatileDomainForName_,
                         &cfstr_HSDrawShapeDefaultSettingsVolatileDomain);
  self_00 = cls_NSDictionary;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_vectorGraphics,pcVar4);
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperStrokeColor);
    pvVar1 = _objc_msgSend(pvVar1,sel_extraDictionaryRepresentation);
    pvVar1 = _objc_msgSend(self_00,sel_dictionaryWithObject_forKey_,pvVar1,
                           &cfstr_HSDrawShapeStrokeLineColorKey);
    pvVar2 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
    op = sel_setVolatileDomain_forName_;
  }
  else {
    pvVar2 = _objc_msgSend(cls_NSMutableDictionary,sel_dictionaryWithDictionary_,pvVar1);
    pvVar2 = _objc_msgSend(pvVar2,sel_retain);
    pvVar3 = _objc_msgSend(self,sel_vectorGraphics);
    pvVar3 = _objc_msgSend(pvVar3,sel_hyperStrokeColor);
    pvVar3 = _objc_msgSend(pvVar3,sel_extraDictionaryRepresentation);
    pvVar3 = _objc_msgSend(pvVar3,sel_retain);
    op = sel_release;
    if (pvVar3 != (id)0x0) {
      _objc_msgSend(pvVar2,sel_setObject_forKey_,pvVar3,&cfstr_HSDrawShapeStrokeLineColorKey);
      _objc_msgSend(pvVar3,sel_release);
      pvVar1 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
      _objc_msgSend(pvVar1,sel_removeVolatileDomainForName_,
                    &cfstr_HSDrawShapeDefaultSettingsVolatileDomain);
      pvVar3 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
      pvVar1 = pvVar2;
      _objc_msgSend(pvVar3,sel_setVolatileDomain_forName_,pvVar2,
                    &cfstr_HSDrawShapeDefaultSettingsVolatileDomain);
      op = sel_release;
    }
  }
  _objc_msgSend(pvVar2,op,pvVar1);
  return;
}

*/
- (void)storeStrokeLineColorAsDefault
{
    NSDictionary *domain = [[NSUserDefaults standardUserDefaults] volatileDomainForName:@"HSDrawShapeDefaultSettingsVolatileDomain"];
    if (domain == nil) {
        id representation = [[[self vectorGraphics] hyperStrokeColor] extraDictionaryRepresentation];
        if (representation != nil) {
            [[NSUserDefaults standardUserDefaults] setVolatileDomain:[NSDictionary dictionaryWithObject:representation forKey:@"HSDrawShapeStrokeLineColorKey"] forName:@"HSDrawShapeDefaultSettingsVolatileDomain"];
        }
        return;
    }
    NSMutableDictionary *settings = [[NSMutableDictionary dictionaryWithDictionary:domain] retain];
    id representation = [[[[self vectorGraphics] hyperStrokeColor] extraDictionaryRepresentation] retain];
    if (representation != nil) {
        [settings setObject:representation forKey:@"HSDrawShapeStrokeLineColorKey"];
        [representation release];
        [[NSUserDefaults standardUserDefaults] removeVolatileDomainForName:@"HSDrawShapeDefaultSettingsVolatileDomain"];
        [[NSUserDefaults standardUserDefaults] setVolatileDomain:settings forName:@"HSDrawShapeDefaultSettingsVolatileDomain"];
    }
    [settings release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018b071 @ 0018b071, 570 bytes * /

void FUN_0018b071(HSDrawShapeAppearanceAssistantPane *self,SEL _cmd)

{
  undefined *puVar1;
  undefined *self_00;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  double dVar5;
  SEL op;
  cfstringStruct *pcVar6;
  
  pvVar2 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  pcVar6 = &cfstr_HSDrawShapeDefaultSettingsVolatileDomain;
  pvVar2 = _objc_msgSend(pvVar2,sel_volatileDomainForName_,
                         &cfstr_HSDrawShapeDefaultSettingsVolatileDomain);
  self_00 = cls_NSNumber;
  puVar1 = cls_NSDictionary;
  if (pvVar2 == (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_vectorGraphics,pcVar6);
    dVar5 = _objc_msgSend_fpret(pvVar2,sel_hyperLineWidth);
    pvVar2 = _objc_msgSend(self_00,sel_numberWithFloat_,(float)dVar5);
    pvVar2 = _objc_msgSend(puVar1,sel_dictionaryWithObject_forKey_,pvVar2,
                           &cfstr_HSDrawShapeLineWidthKey);
    pvVar3 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
    op = sel_setVolatileDomain_forName_;
  }
  else {
    pvVar3 = _objc_msgSend(cls_NSMutableDictionary,sel_dictionaryWithDictionary_,pvVar2);
    pvVar3 = _objc_msgSend(pvVar3,sel_retain);
    pvVar4 = _objc_msgSend(self,sel_vectorGraphics);
    dVar5 = _objc_msgSend_fpret(pvVar4,sel_hyperLineWidth);
    puVar1 = cls_NSNumber;
    op = sel_release;
    if (0.0 < (float)dVar5) {
      pvVar2 = _objc_msgSend(self,sel_vectorGraphics,pvVar2);
      dVar5 = _objc_msgSend_fpret(pvVar2,sel_hyperLineWidth);
      pvVar2 = _objc_msgSend(puVar1,sel_numberWithFloat_,(float)dVar5);
      _objc_msgSend(pvVar3,sel_setObject_forKey_,pvVar2,&cfstr_HSDrawShapeLineWidthKey);
      pvVar2 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
      _objc_msgSend(pvVar2,sel_removeVolatileDomainForName_,
                    &cfstr_HSDrawShapeDefaultSettingsVolatileDomain);
      pvVar4 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
      pvVar2 = pvVar3;
      _objc_msgSend(pvVar4,sel_setVolatileDomain_forName_,pvVar3,
                    &cfstr_HSDrawShapeDefaultSettingsVolatileDomain);
      op = sel_release;
    }
  }
  _objc_msgSend(pvVar3,op,pvVar2);
  return;
}

*/
- (void)storeLineWidthAsDefault
{
    NSDictionary *domain = [[NSUserDefaults standardUserDefaults] volatileDomainForName:@"HSDrawShapeDefaultSettingsVolatileDomain"];
    if (domain == nil) {
        NSNumber *lineWidth = [NSNumber numberWithFloat:(float)[[self vectorGraphics] hyperLineWidth]];
        [[NSUserDefaults standardUserDefaults] setVolatileDomain:[NSDictionary dictionaryWithObject:lineWidth forKey:@"HSDrawShapeLineWidthKey"] forName:@"HSDrawShapeDefaultSettingsVolatileDomain"];
        return;
    }
    NSMutableDictionary *settings = [[NSMutableDictionary dictionaryWithDictionary:domain] retain];
    if (0.0f < (float)[[self vectorGraphics] hyperLineWidth]) {
        [settings setObject:[NSNumber numberWithFloat:(float)[[self vectorGraphics] hyperLineWidth]] forKey:@"HSDrawShapeLineWidthKey"];
        [[NSUserDefaults standardUserDefaults] removeVolatileDomainForName:@"HSDrawShapeDefaultSettingsVolatileDomain"];
        [[NSUserDefaults standardUserDefaults] setVolatileDomain:settings forName:@"HSDrawShapeDefaultSettingsVolatileDomain"];
    }
    [settings release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018b2ab @ 0018b2ab, 301 bytes * /

void FUN_0018b2ab(HSDrawShapeAppearanceAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  cfstringStruct *pcVar2;
  id pvVar3;
  SEL op;
  cfstringStruct *pcVar4;
  
  pvVar1 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  pcVar4 = &cfstr_HSDrawShapeDefaultSettingsVolatileDomain;
  pcVar2 = _objc_msgSend(pvVar1,sel_volatileDomainForName_,
                         &cfstr_HSDrawShapeDefaultSettingsVolatileDomain);
  op = sel_dictionary;
  if (pcVar2 != (cfstringStruct *)0x0) {
    _objc_msgSend(pvVar1,sel_removeVolatileDomainForName_,
                  &cfstr_HSDrawShapeDefaultSettingsVolatileDomain);
    op = sel_dictionaryWithDictionary_;
    pcVar4 = pcVar2;
  }
  pvVar1 = _objc_msgSend(cls_NSMutableDictionary,op,pcVar4);
  pvVar3 = _objc_msgSend(self,sel_backgroundAttributes);
  pvVar3 = _objc_msgSend(pvVar3,sel_backgroundGraphics);
  pcVar2 = _objc_msgSend(pvVar3,sel_extraDictionaryRepresentation);
  if (pcVar2 != (cfstringStruct *)0x0) {
    _objc_msgSend(pvVar1,sel_setObject_forKey_,pcVar2,&cfstr_HSDrawShapeBackgroundGraphicsKey);
    pcVar4 = pcVar2;
  }
  pvVar3 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults,pcVar4);
  _objc_msgSend(pvVar3,sel_setVolatileDomain_forName_,pvVar1,
                &cfstr_HSDrawShapeDefaultSettingsVolatileDomain);
  return;
}

*/
- (void)storeBackgroundGraphicsAsDefault
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *domain = [defaults volatileDomainForName:@"HSDrawShapeDefaultSettingsVolatileDomain"];
    NSMutableDictionary *settings;
    if (domain != nil) {
        [defaults removeVolatileDomainForName:@"HSDrawShapeDefaultSettingsVolatileDomain"];
        settings = [NSMutableDictionary dictionaryWithDictionary:domain];
    }
    else {
        settings = [NSMutableDictionary dictionary];
    }
    id representation = [[[self backgroundAttributes] backgroundGraphics] extraDictionaryRepresentation];
    if (representation != nil) {
        [settings setObject:representation forKey:@"HSDrawShapeBackgroundGraphicsKey"];
    }
    [[NSUserDefaults standardUserDefaults] setVolatileDomain:settings forName:@"HSDrawShapeDefaultSettingsVolatileDomain"];
}

- (void)setName:(id)aName
{
    [[self objectAttributes] setHyperName:[aName stringValue]];
}

- (void)dealloc
{
    [_hyperObjectForVectorGraphics release];
    [super dealloc];
}

- (id)nameTextfField
{
    return _nameTextField;
}

- (id)initialKeyView
{
    return _nameTextField;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018b480 @ 0018b480, 113 bytes * /

BOOL FUN_0018b480(HSDrawShapeAppearanceAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self->_nameTextField,sel_currentEditor);
  if ((pvVar1 == (id)0x0) &&
     (pvVar1 = _objc_msgSend(self->_outlineTextField,sel_currentEditor), pvVar1 == (id)0x0)) {
    pvVar1 = _objc_msgSend(self->_opacityTextField,sel_currentEditor);
    return pvVar1 != (id)0x0;
  }
  return '\x01';
}

*/
- (BOOL)isEditingTextAttribute
{
    if ([_nameTextField currentEditor] != nil || [_outlineTextField currentEditor] != nil) {
        return YES;
    }
    return [_opacityTextField currentEditor] != nil;
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    int uVar1;
    id pvVar2_2;

    pvVar2_2 = [[self objectAttributes] attributeObservingController];
    uVar1 = HSActualDidAttributeChanges;
    [pvVar2_2 removeObserver:self selector:@selector(validateUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSMutableObjectAttributes)];
    [[[self opacityAttributes] attributeObservingController] removeObserver:self selector:@selector(validateOpacityUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSOpacityAttributes)];
    [[[self shadowAttributes] attributeObservingController] removeObserver:self selector:@selector(validateShadowUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSShadowAttributes)];
    [[_hyperObjectForVectorGraphics attributeObservingController] removeObserver:self selector:@selector(validateColorUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSVectorGraphicsAttributes)];
    [[[self backgroundAttributes] attributeObservingController] removeObserver:self selector:@selector(validateColorUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSBackgroundAttributes)];
    [_hyperObjectForVectorGraphics release];
    _hyperObjectForVectorGraphics = nil;
    [super viewWillDisappear:aDisappear];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018b70a @ 0018b70a, 687 bytes * /

void FUN_0018b70a(HSDrawShapeAppearanceAssistantPane *self,SEL _cmd,BOOL viewWillAppear)

{
  id pvVar1;
  undefined4 uVar2;
  undefined4 uVar3;
  HSDrawShapeAppearanceAssistantPane *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSObjectAssistantPane_003527f0;
  _objc_msgSendSuper(&local_1c,sel_viewWillAppear_,(int)viewWillAppear);
  pvVar1 = _objc_msgSend(self,sel_vectorGraphics);
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperObject);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_hyperObjectForVectorGraphics = pvVar1;
  pvVar1 = _objc_msgSend(self,sel_objectAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_attributeObservingController);
  uVar2 = *(undefined4 *)PTR_0033601c;
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttributesOfHyperInterface_withPriority_
                ,self,sel_validateUIWithNotification_,uVar2,&DAT_00379b88,0xbe800000,uVar2);
  pvVar1 = _objc_msgSend(self,sel_opacityAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_attributeObservingController);
  uVar3 = uVar2;
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttributesOfHyperInterface_withPriority_
                ,self,sel_validateOpacityUIWithNotification_,uVar2,&DAT_00379ca0,0xbe800000);
  pvVar1 = _objc_msgSend(self,sel_shadowAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_attributeObservingController);
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttributesOfHyperInterface_withPriority_
                ,self,sel_validateShadowUIWithNotification_,uVar2,&DAT_00379cf0,0xbe800000);
  pvVar1 = _objc_msgSend(self->_hyperObjectForVectorGraphics,sel_attributeObservingController);
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttributesOfHyperInterface_withPriority_
                ,self,sel_validateColorUIWithNotification_,uVar3,&DAT_00379d68,0xbe800000);
  pvVar1 = _objc_msgSend(self,sel_backgroundAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_attributeObservingController);
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttributesOfHyperInterface_withPriority_
                ,self,sel_validateColorUIWithNotification_,uVar3,&DAT_00379e80,0xbe800000);
  _objc_msgSend(self,sel_validateUI);
  _objc_msgSend(self,sel_validateOpacityUI);
  _objc_msgSend(self,sel_validateShadowUI);
  _objc_msgSend(self,sel_validateColorUI);
  return;
}

*/
- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    _hyperObjectForVectorGraphics = [[[self vectorGraphics] hyperObject] retain];
    [[[self objectAttributes] attributeObservingController] addObserver:self selector:@selector(validateUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSMutableObjectAttributes) withPriority:-0.25];
    [[[self opacityAttributes] attributeObservingController] addObserver:self selector:@selector(validateOpacityUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSOpacityAttributes) withPriority:-0.25];
    [[[self shadowAttributes] attributeObservingController] addObserver:self selector:@selector(validateShadowUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSShadowAttributes) withPriority:-0.25];
    [[_hyperObjectForVectorGraphics attributeObservingController] addObserver:self selector:@selector(validateColorUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSVectorGraphicsAttributes) withPriority:-0.25];
    [[[self backgroundAttributes] attributeObservingController] addObserver:self selector:@selector(validateColorUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSBackgroundAttributes) withPriority:-0.25];
    [self validateUI];
    [self validateOpacityUI];
    [self validateShadowUI];
    [self validateColorUI];
}

- (void)viewDidLoad
{
    [_fillTypeMatrix setBackgroundRenderer:[HSAssistantPaneControlBackgroundRenderer sharedBackgroundRenderer]];
    [[_fillTypeMatrix cellWithTag:1] setImage:[self shapeTypeControlOutlineImage]];
    [[_fillTypeMatrix cellWithTag:2] setImage:[self shapeTypeControlFillImage]];
    [[_fillTypeMatrix cellWithTag:3] setImage:[self shapeTypeControlFillWithOutlineImage]];
    [_fillColorWell setShowsAlphaForPanel:YES];
    [_fillColorWell setGradientSupportEnabled:YES];
}

- (id)init
{
    self = [super initWithNibName:@"DrawShapeAppearancePane"];
    if (self != nil) {
        [self setTitle:[[NSBundle mainBundle] localizedStringForKey:@"Appearance" value:@"" table:@"AssistantPanes"]];
        [self setIcon:[NSImage imageNamed:@"general"]];
    }
    return self;
}

@end

