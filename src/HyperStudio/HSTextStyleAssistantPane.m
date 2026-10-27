#import "HSTextStyleAssistantPane.h"

@implementation HSTextStyleAssistantPane

/* i386 ivar offsets: _fontComboBox=0x5c, _fontSizeTextField=0x60, _fontSizeStepper=0x64, _fontSizeSlider=0x68, _textStyleMatrix=0x6c, _textColorWell=0x70, _backgroundColorWell=0x74, _alignmentMatrix=0x78, _verticalAlignmentMatrix=0x7c, _characterSpaceSwitch=0x80, _characterSpaceField=0x84, _characterSpaceStepper=0x88, _outlineSwitch=0x8c, _outlineButton=0x90, _shadowButton=0x94, _shadowSwitch=0x98, _backgroundTextField=0x9c, _dataSource=0xa0, _characterSpaceValue=0xa4, _isUpdatingFontName=0xa8, _observedTextAttributes=0xac, _fontAttributes=0xb0, _genericFontAttributes=0xb4, _fontSizeSliderIsTracking=0xb8 */

+ (BOOL)canEditObject:(id)aObject
{
    return (BOOL)[aObject implementsHyperInterface:@protocol(HSSystemTextViewAttributes)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0017431f @ 0017431f, 161 bytes * /

void FUN_0017431f(HSTextStyleAssistantPane *self,SEL _cmd,id controlTextDidEndEditing)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(controlTextDidEndEditing,sel_object);
  if (pvVar1 == self->_fontComboBox) {
    pvVar1 = self->_dataSource;
    pvVar2 = _objc_msgSend(controlTextDidEndEditing,sel_object);
    pvVar2 = _objc_msgSend(pvVar2,sel_stringValue);
    pvVar1 = _objc_msgSend(pvVar1,sel_comboBox_indexOfItemWithStringValue_,self->_fontComboBox,
                           pvVar2);
    if (pvVar1 != (id)0x7fffffff) {
      _objc_msgSend(self,sel_applyFontFamilyAtIndex_,pvVar1,pvVar2);
    }
  }
  return;
}

*/
- (void)controlTextDidEndEditing:(id)aEditing
{
    if ([aEditing object] == _fontComboBox) {
        NSInteger index = [_dataSource comboBox:_fontComboBox indexOfItemWithStringValue:[[aEditing object] stringValue]];
        if (index != NSNotFound) {
            [self applyFontFamilyAtIndex:index];
        }
    }
}

- (void)comboBoxSelectionDidChange:(id)aChange
{
    if (_isUpdatingFontName == NO) {
        if ([aChange object] == _fontComboBox) {
            [self applyFontFamilyAtIndex:[[aChange object] indexOfSelectedItem]];
        }
    }
}

- (void)applyFontFamilyAtIndex:(NSUInteger)aIndex
{
    id self_00;

    if (_genericFontAttributes != nil) {
        self_00 = [_dataSource keyValueForItemAtIndex:aIndex];
        if (self_00 != nil) {
            if (![[_genericFontAttributes hyperFontFamily] isEqualToString:self_00]) {
                if ([self_00 isEqualToString:@"Apple Chancery"]) {
                    if ([_fontAttributes hyperAlignment] == 0x3) {
                        [_fontAttributes setHyperAlignment:0];
                    }
                }
                [_genericFontAttributes setHyperFontFamily:self_00];
            }
        }
    }
}

- (void)hyperCustomSliderDidFinishTracking:(id)aTracking
{
    _fontSizeSliderIsTracking = NO;
}

- (void)hyperCustomSliderDidStartTracking:(id)aTracking
{
    _fontSizeSliderIsTracking = YES;
}

- (void)validateCharacterSpacingControls
{
    float fVar1;
    unsigned int uVar2;
    float fVar3;
    float fVar4;

    fVar1 = (float)[_fontAttributes hyperSpaceBetweenCharacters];
    fVar3 = fVar1 != 0.0 ? fabs(fVar1) : 1.0;
    fVar4 = 0.0005;
    if (1.0 <= fVar3) {
        fVar4 = fVar3 * 0.0005;
    }
    uVar2 = -(unsigned int)(fVar4 < fabs(fVar1)) & 1;
    [_characterSpaceSwitch setState:uVar2];
    [self enableSpaceCharactersControls:uVar2];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001745e5 @ 001745e5, 2022 bytes * /

void FUN_001745e5(HSTextStyleAssistantPane *self,SEL _cmd)

{
  HSGradientColorWell *pHVar1;
  HSBlueCircleSlider *pHVar2;
  float fVar3;
  char cVar4;
  id pvVar5;
  id pvVar6;
  cfstringStruct *pcVar7;
  id pvVar8;
  SEL op;
  float *pfVar9;
  float *pfVar10;
  longdouble lVar11;
  float fVar12;
  double dVar13;
  float afStack_a0 [4];
  float local_70;
  float local_6c;
  float local_54;
  undefined4 uStack_50;
  float local_4c;
  float fStack_48;
  float local_44;
  undefined4 uStack_40;
  float local_3c;
  float fStack_38;
  float local_34 [2];
  float local_2c;
  float local_24 [2];
  float local_1c;
  
  pfVar10 = (float *)&stack0xffffff74;
  if (self->_observedTextAttributes != (id)0x0) {
    pHVar1 = self->_textColorWell;
    _objc_msgSend(self->_observedTextAttributes,sel_textColor);
    _objc_msgSend(pHVar1,sel_setColor_);
    pvVar5 = _objc_msgSend(self,sel_assistant);
    pvVar5 = _objc_msgSend(pvVar5,sel_object);
    pvVar5 = _objc_msgSend(pvVar5,sel_queryHyperInterface_);
    pvVar6 = _objc_msgSend(pvVar5,sel_isTransparent);
    _objc_msgSend(self->_observedTextAttributes,sel_queryHyperInterface_);
    _objc_msgSend(self,sel_validateAlignmentMatrixState);
    _objc_msgSend(self->_backgroundColorWell,sel_setEnabled_);
    pHVar1 = self->_backgroundColorWell;
    _objc_msgSend(self->_observedTextAttributes,sel_backgroundColor);
    _objc_msgSend(pHVar1,sel_setColor_);
    pvVar5 = self->_backgroundTextField;
    op = sel_blackColor;
    if ((char)pvVar6 != '\0') {
      op = sel_disabledControlTextColor;
    }
    _objc_msgSend(cls_NSColor,op);
    _objc_msgSend(pvVar5,sel_setTextColor_);
  }
  if (self->_fontAttributes != (id)0x0) {
    pvVar5 = _objc_msgSend(self->_textStyleMatrix,sel_cellWithTag_);
    _objc_msgSend(self->_fontAttributes,sel_isHyperBold);
    _objc_msgSend(pvVar5,sel_setState_);
    pvVar5 = _objc_msgSend(self->_textStyleMatrix,sel_cellWithTag_);
    _objc_msgSend(self->_fontAttributes,sel_isHyperItalic);
    _objc_msgSend(pvVar5,sel_setState_);
    pvVar5 = _objc_msgSend(self->_textStyleMatrix,sel_cellWithTag_);
    _objc_msgSend(self->_fontAttributes,sel_isHyperUnderlined);
    _objc_msgSend(pvVar5,sel_setState_);
    pvVar5 = _objc_msgSend(self->_fontAttributes,sel_isHyperOutlineEnabled);
    _objc_msgSend(self->_fontAttributes,sel_lastHyperAccessDidReturnMultipleValues);
    _objc_msgSend(self->_outlineSwitch,sel_setState_);
    _objc_msgSend(self->_outlineButton,sel_setHidden_);
    _objc_msgSend_stret(&local_44,self->_outlineSwitch,sel_frame);
    pfVar9 = (float *)&stack0xffffff70;
    local_3c = fStack_38;
    if ((char)pvVar5 == '\0') {
      afStack_a0[3] = 2.138453e-39;
      _objc_msgSend_stret(local_34,self->_outlineButton,sel_frame);
      pfVar9 = afStack_a0 + 3;
      local_3c = (local_34[0] + local_2c) - local_44;
    }
    pvVar6 = self->_outlineSwitch;
    *(ulonglong *)(pfVar9 + 4) = CONCAT44(fStack_38,local_3c);
    *(ulonglong *)(pfVar9 + 2) = CONCAT44(uStack_40,local_44);
    pfVar9[1] = (float)sel_setFrame_;
    *pfVar9 = (float)pvVar6;
    pfVar9[-1] = 2.138554e-39;
    _objc_msgSend((id)*pfVar9,(SEL)pfVar9[1]);
    if ((char)pvVar5 == '\0') {
      pvVar5 = self->_outlineButton;
      pfVar9[1] = (float)sel_title;
      *pfVar9 = (float)pvVar5;
      pfVar9[-1] = 2.138611e-39;
      pcVar7 = _objc_msgSend((id)*pfVar9,(SEL)pfVar9[1]);
    }
    else {
      pcVar7 = &cfstr_empty;
    }
    pvVar5 = self->_outlineSwitch;
    pfVar9[2] = (float)pcVar7;
    pfVar9[1] = (float)sel_setTitle_;
    *pfVar9 = (float)pvVar5;
    pfVar9[-1] = 2.138655e-39;
    _objc_msgSend((id)*pfVar9,(SEL)pfVar9[1]);
    pvVar5 = self->_fontAttributes;
    pfVar9[1] = (float)sel_isHyperShadowEnabled;
    *pfVar9 = (float)pvVar5;
    pfVar9[-1] = 2.138693e-39;
    pvVar5 = _objc_msgSend((id)*pfVar9,(SEL)pfVar9[1]);
    cVar4 = (char)pvVar5;
    pvVar5 = self->_shadowSwitch;
    pfVar9[2] = (float)(int)cVar4;
    pfVar9[1] = (float)sel_setState_;
    *pfVar9 = (float)pvVar5;
    pfVar9[-1] = 2.138743e-39;
    _objc_msgSend((id)*pfVar9,(SEL)pfVar9[1]);
    pvVar5 = self->_shadowButton;
    pfVar9[2] = (float)(uint)(cVar4 == '\0');
    pfVar9[1] = (float)sel_setHidden_;
    *pfVar9 = (float)pvVar5;
    pfVar9[-1] = 2.138798e-39;
    _objc_msgSend((id)*pfVar9,(SEL)pfVar9[1]);
    pvVar5 = self->_shadowSwitch;
    pfVar9[2] = (float)sel_frame;
    pfVar9[1] = (float)pvVar5;
    *pfVar9 = (float)&local_54;
    pfVar9[-1] = 2.138845e-39;
    _objc_msgSend_stret((void *)*pfVar9,(id)pfVar9[1],(SEL)pfVar9[2]);
    pfVar10 = pfVar9 + -1;
    local_4c = fStack_48;
    if (cVar4 == '\0') {
      pvVar5 = self->_shadowButton;
      pfVar9[1] = (float)sel_frame;
      *pfVar9 = (float)pvVar5;
      pfVar9[-1] = (float)local_24;
      pfVar9[-2] = 2.138913e-39;
      _objc_msgSend_stret((void *)pfVar9[-1],(id)*pfVar9,(SEL)pfVar9[1]);
      pfVar10 = pfVar9 + -2;
      local_4c = (local_24[0] + local_1c) - local_54;
    }
    pvVar5 = self->_shadowSwitch;
    *(ulonglong *)(pfVar10 + 4) = CONCAT44(fStack_48,local_4c);
    *(ulonglong *)(pfVar10 + 2) = CONCAT44(uStack_50,local_54);
    pfVar10[1] = (float)sel_setFrame_;
    *pfVar10 = (float)pvVar5;
    pfVar10[-1] = 2.139013e-39;
    _objc_msgSend((id)*pfVar10,(SEL)pfVar10[1]);
    if (cVar4 == '\0') {
      pvVar5 = self->_shadowButton;
      pfVar10[1] = (float)sel_title;
      *pfVar10 = (float)pvVar5;
      pfVar10[-1] = 2.139068e-39;
      pcVar7 = _objc_msgSend((id)*pfVar10,(SEL)pfVar10[1]);
    }
    else {
      pcVar7 = &cfstr_empty;
    }
    pvVar5 = self->_shadowSwitch;
    pfVar10[2] = (float)pcVar7;
    pfVar10[1] = (float)sel_setTitle_;
    *pfVar10 = (float)pvVar5;
    pfVar10[-1] = 2.139112e-39;
    _objc_msgSend((id)*pfVar10,(SEL)pfVar10[1]);
    pvVar5 = self->_alignmentMatrix;
    pvVar6 = self->_fontAttributes;
    pfVar10[1] = (float)sel_hyperAlignment;
    *pfVar10 = (float)pvVar6;
    pfVar10[-1] = 2.13915e-39;
    pvVar6 = _objc_msgSend((id)*pfVar10,(SEL)pfVar10[1]);
    pfVar10[2] = (float)pvVar6;
    pfVar10[1] = (float)sel_selectCellWithTag_;
    *pfVar10 = (float)pvVar5;
    pfVar10[-1] = 2.13918e-39;
    _objc_msgSend((id)*pfVar10,(SEL)pfVar10[1]);
    pvVar5 = self->_fontAttributes;
    pfVar10[1] = (float)sel_hyperSpaceBetweenCharacters;
    *pfVar10 = (float)pvVar5;
    pfVar10[-1] = 2.139214e-39;
    dVar13 = _objc_msgSend_fpret((id)*pfVar10,(SEL)pfVar10[1]);
    fVar3 = (float)dVar13;
    pvVar5 = self->_genericFontAttributes;
    pfVar10[1] = (float)sel_hyperFontSize;
    *pfVar10 = (float)pvVar5;
    pfVar10[-1] = 2.139252e-39;
    dVar13 = _objc_msgSend_fpret((id)*pfVar10,(SEL)pfVar10[1]);
    *pfVar10 = (fVar3 * 100.0) / (float)dVar13;
    pfVar10[-1] = 2.139308e-39;
    lVar11 = (longdouble)_roundf();
    local_6c = (float)lVar11;
    if ((fVar3 != 0.0) || (NAN(fVar3))) {
      fVar12 = ABS(fVar3);
    }
    else {
      fVar12 = 1.0;
    }
    local_70 = 0.0005;
    if (1.0 <= fVar12) {
      local_70 = fVar12 * 0.0005;
    }
    pvVar5 = self->_characterSpaceField;
    fVar12 = local_6c;
    if (ABS(fVar3) <= local_70) {
      fVar12 = self->_characterSpaceValue;
    }
    pfVar10[2] = fVar12;
    pfVar10[1] = (float)sel_setFloatValue_;
    *pfVar10 = (float)pvVar5;
    pfVar10[-1] = 2.139554e-39;
    _objc_msgSend((id)*pfVar10,(SEL)pfVar10[1]);
    pvVar5 = self->_characterSpaceStepper;
    if (ABS(fVar3) <= local_70) {
      local_6c = self->_characterSpaceValue;
    }
    pfVar10[2] = local_6c;
    pfVar10[1] = (float)sel_setFloatValue_;
    *pfVar10 = (float)pvVar5;
    pfVar10[-1] = 2.139645e-39;
    _objc_msgSend((id)*pfVar10,(SEL)pfVar10[1]);
  }
  pvVar5 = self->_genericFontAttributes;
  if (pvVar5 != (id)0x0) {
    pvVar6 = self->_dataSource;
    pfVar10[1] = (float)sel_hyperFontFamily;
    *pfVar10 = (float)pvVar5;
    pfVar10[-1] = 2.139707e-39;
    pvVar8 = _objc_msgSend((id)*pfVar10,(SEL)pfVar10[1]);
    pvVar5 = self->_fontComboBox;
    pfVar10[3] = (float)pvVar8;
    pfVar10[2] = (float)pvVar5;
    pfVar10[1] = (float)sel_comboBox_indexOfItemWithStringValue_;
    *pfVar10 = (float)pvVar6;
    pfVar10[-1] = 2.139752e-39;
    pvVar6 = _objc_msgSend((id)*pfVar10,(SEL)pfVar10[1]);
    pvVar5 = self->_dataSource;
    pfVar10[2] = (float)self->_fontComboBox;
    pfVar10[1] = (float)sel_numberOfItemsInComboBox_;
    *pfVar10 = (float)pvVar5;
    pfVar10[-1] = 2.139802e-39;
    pvVar5 = _objc_msgSend((id)*pfVar10,(SEL)pfVar10[1]);
    if (pvVar6 < pvVar5) {
      self->_isUpdatingFontName = '\x01';
      pvVar5 = self->_fontComboBox;
      pfVar10[2] = (float)pvVar6;
      pfVar10[1] = (float)sel_selectItemAtIndex_;
      *pfVar10 = (float)pvVar5;
      pfVar10[-1] = 2.139857e-39;
      _objc_msgSend((id)*pfVar10,(SEL)pfVar10[1]);
      self->_isUpdatingFontName = '\0';
    }
    pvVar5 = self->_genericFontAttributes;
    pfVar10[1] = (float)sel_hyperFontSize;
    *pfVar10 = (float)pvVar5;
    pfVar10[-1] = 2.139905e-39;
    dVar13 = _objc_msgSend_fpret((id)*pfVar10,(SEL)pfVar10[1]);
    fVar3 = (float)dVar13;
    pvVar5 = self->_fontSizeTextField;
    pfVar10[2] = fVar3;
    pfVar10[1] = (float)sel_setFloatValue_;
    *pfVar10 = (float)pvVar5;
    pfVar10[-1] = 2.139961e-39;
    _objc_msgSend((id)*pfVar10,(SEL)pfVar10[1]);
    pvVar5 = self->_fontSizeStepper;
    pfVar10[2] = fVar3;
    pfVar10[1] = (float)sel_setFloatValue_;
    *pfVar10 = (float)pvVar5;
    pfVar10[-1] = 2.140006e-39;
    _objc_msgSend((id)*pfVar10,(SEL)pfVar10[1]);
    if (self->_fontSizeSliderIsTracking == '\0') {
      pHVar2 = self->_fontSizeSlider;
      pfVar10[1] = fVar3;
      *pfVar10 = (float)pHVar2;
      pfVar10[-1] = 2.140052e-39;
      lVar11 = (longdouble)_HSLinearValueForSliderFromNonLinear();
      pfVar10[2] = (float)lVar11;
      pfVar10[1] = (float)sel_setFloatValue_;
      *pfVar10 = (float)pHVar2;
      pfVar10[-1] = 2.140083e-39;
      _objc_msgSend((id)*pfVar10,(SEL)pfVar10[1]);
    }
    pfVar10[1] = (float)sel_validateTextStyleMatrixState;
    *pfVar10 = (float)self;
    pfVar10[-1] = 2.140112e-39;
    _objc_msgSend((id)*pfVar10,(SEL)pfVar10[1]);
  }
  return;
}

*/
- (void)validateUI
{
    if (_observedTextAttributes != nil) {
        [_textColorWell setColor:[_observedTextAttributes textColor]];
        BOOL transparent = [[[[self assistant] object] queryHyperInterface:@protocol(HSSystemTextViewAttributes)] isTransparent];
        BOOL same = ([_observedTextAttributes queryHyperInterface:@protocol(HSRunTimeEditor)] == _observedTextAttributes);
        [self validateAlignmentMatrixState];
        [_backgroundColorWell setEnabled:!(same || transparent)];
        [_backgroundColorWell setColor:[_observedTextAttributes backgroundColor]];
        [_backgroundTextField setTextColor:transparent ? [NSColor disabledControlTextColor] : [NSColor blackColor]];
    }
    if (_fontAttributes != nil) {
        [[_textStyleMatrix cellWithTag:1] setState:[_fontAttributes isHyperBold]];
        [[_textStyleMatrix cellWithTag:2] setState:[_fontAttributes isHyperItalic]];
        [[_textStyleMatrix cellWithTag:3] setState:[_fontAttributes isHyperUnderlined]];
        BOOL outline = [_fontAttributes isHyperOutlineEnabled];
        BOOL outlineOn = (outline || [_fontAttributes lastHyperAccessDidReturnMultipleValues]);
        [_outlineSwitch setState:outlineOn];
        [_outlineButton setHidden:!outlineOn];
        NSRect frame = [_outlineSwitch frame];
        if (!outline) {
            NSRect buttonFrame = [_outlineButton frame];
            frame.size.width = (buttonFrame.origin.x + buttonFrame.size.width) - frame.origin.x;
        }
        [_outlineSwitch setFrame:frame];
        [_outlineSwitch setTitle:outline ? @"" : [_outlineButton title]];
        BOOL shadow = [_fontAttributes isHyperShadowEnabled];
        [_shadowSwitch setState:shadow];
        [_shadowButton setHidden:!shadow];
        frame = [_shadowSwitch frame];
        if (!shadow) {
            NSRect buttonFrame = [_shadowButton frame];
            frame.size.width = (buttonFrame.origin.x + buttonFrame.size.width) - frame.origin.x;
        }
        [_shadowSwitch setFrame:frame];
        [_shadowSwitch setTitle:shadow ? @"" : [_shadowButton title]];
        [_alignmentMatrix selectCellWithTag:[_fontAttributes hyperAlignment]];
        float spacing = [_fontAttributes hyperSpaceBetweenCharacters];
        float percent = roundf((spacing * 100.0f) / [_genericFontAttributes hyperFontSize]);
        float scale = (spacing != 0.0f) ? fabsf(spacing) : 1.0f;
        float tolerance = 0.0005f;
        if (1.0f <= scale) {
            tolerance = scale * 0.0005f;
        }
        if (fabsf(spacing) <= tolerance) {
            percent = _characterSpaceValue;
        }
        [_characterSpaceField setFloatValue:percent];
        [_characterSpaceStepper setFloatValue:percent];
    }
    if (_genericFontAttributes != nil) {
        NSInteger index = [_dataSource comboBox:_fontComboBox indexOfItemWithStringValue:[_genericFontAttributes hyperFontFamily]];
        if (index < [_dataSource numberOfItemsInComboBox:_fontComboBox]) {
            _isUpdatingFontName = YES;
            [_fontComboBox selectItemAtIndex:index];
            _isUpdatingFontName = NO;
        }
        float size = [_genericFontAttributes hyperFontSize];
        [_fontSizeTextField setFloatValue:size];
        [_fontSizeStepper setFloatValue:size];
        if (!_fontSizeSliderIsTracking) {
            [_fontSizeSlider setFloatValue:HSLinearValueForSliderFromNonLinear(_fontSizeSlider, size)];
        }
        [self validateTextStyleMatrixState];
    }
}

- (void)validateUIWithNotification:(id)aNotification
{
    [self validateUI];
}

- (void)enableSpaceCharactersControls:(BOOL)aControls
{
    [_characterSpaceStepper setEnabled:aControls];
    [_characterSpaceField setEnabled:aControls];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00174e47 @ 00174e47, 236 bytes * /

void FUN_00174e47(HSTextStyleAssistantPane *self,SEL _cmd,id characterSpacingValueChanged)

{
  float fVar1;
  bool bVar2;
  double dVar3;
  id self_00;
  
  if (self->_fontAttributes != (id)0x0) {
    dVar3 = _objc_msgSend_fpret(characterSpacingValueChanged,sel_floatValue);
    fVar1 = (float)dVar3;
    self_00 = self->_characterSpaceStepper;
    if ((self->_characterSpaceField == characterSpacingValueChanged) ||
       (bVar2 = self_00 == characterSpacingValueChanged, self_00 = self->_characterSpaceField, bVar2
       )) {
      _objc_msgSend(self_00,sel_setFloatValue_,fVar1);
    }
    self->_characterSpaceValue = fVar1;
    dVar3 = _objc_msgSend_fpret(self->_genericFontAttributes,sel_hyperFontSize);
    _objc_msgSend(self->_fontAttributes,sel_setHyperSpaceBetweenCharacters_,
                  (fVar1 * (float)dVar3) / 100.0);
  }
  return;
}

*/
- (void)characterSpacingValueChanged:(id)aChanged
{
    if (_fontAttributes != nil) {
        float value = [aChanged floatValue];
        if (_characterSpaceField == aChanged) {
            [_characterSpaceStepper setFloatValue:value];
        } else if (_characterSpaceStepper == aChanged) {
            [_characterSpaceField setFloatValue:value];
        }
        _characterSpaceValue = value;
        [_fontAttributes setHyperSpaceBetweenCharacters:(value * [_genericFontAttributes hyperFontSize]) / 100.0f];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00174f33 @ 00174f33, 339 bytes * /

void FUN_00174f33(HSTextStyleAssistantPane *self,SEL _cmd,id characterSpacingEnabled)

{
  id pvVar1;
  longdouble lVar2;
  float fVar3;
  float fVar4;
  double dVar5;
  double dVar6;
  float fVar7;
  
  pvVar1 = _objc_msgSend(characterSpacingEnabled,sel_state);
  _objc_msgSend(self,sel_enableSpaceCharactersControls_,(uint)((char)pvVar1 == '\x01'));
  dVar5 = _objc_msgSend_fpret(self->_genericFontAttributes,sel_hyperFontSize);
  if ((char)pvVar1 == '\0') {
    dVar6 = _objc_msgSend_fpret(self->_fontAttributes,sel_hyperSpaceBetweenCharacters);
    lVar2 = (longdouble)_roundf(((float)dVar6 * 100.0) / (float)dVar5);
    self->_characterSpaceValue = (float)lVar2;
    pvVar1 = self->_fontAttributes;
    fVar7 = 0.0;
  }
  else {
    fVar7 = self->_characterSpaceValue;
    if ((fVar7 != 0.0) || (NAN(fVar7))) {
      fVar3 = ABS(fVar7);
    }
    else {
      fVar3 = 1.0;
    }
    fVar4 = 0.0005;
    if (1.0 <= fVar3) {
      fVar4 = fVar3 * 0.0005;
    }
    if (ABS(fVar7) <= fVar4) {
      return;
    }
    fVar7 = ((float)dVar5 * fVar7) / 100.0;
    pvVar1 = self->_fontAttributes;
  }
  _objc_msgSend(pvVar1,sel_setHyperSpaceBetweenCharacters_,fVar7);
  return;
}

*/
- (void)characterSpacingEnabled:(id)aEnabled
{
    NSInteger state = [aEnabled state];
    [self enableSpaceCharactersControls:(state == 1)];
    float fontSize = [_genericFontAttributes hyperFontSize];
    float value;
    if (state == 0) {
        _characterSpaceValue = roundf(([_fontAttributes hyperSpaceBetweenCharacters] * 100.0f) / fontSize);
        value = 0.0f;
    } else {
        value = _characterSpaceValue;
        float scale = (value != 0.0f) ? fabsf(value) : 1.0f;
        float tolerance = 0.0005f;
        if (1.0f <= scale) {
            tolerance = scale * 0.0005f;
        }
        if (fabsf(value) <= tolerance) {
            return;
        }
        value = (fontSize * value) / 100.0f;
    }
    [_fontAttributes setHyperSpaceBetweenCharacters:value];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00175086 @ 00175086, 548 bytes * /

void FUN_00175086(HSTextStyleAssistantPane *self,SEL _cmd,id fontSizeChanged)

{
  id self_00;
  id pvVar1;
  HSBlueCircleSlider *self_01;
  longdouble lVar2;
  double dVar3;
  id pvVar4;
  
  self_00 = _objc_msgSend(cls_NSAutoreleasePool,sel_new);
  if (self->_genericFontAttributes == (id)0x0) goto LAB_0017528d;
  pvVar1 = _objc_msgSend(fontSizeChanged,sel_intValue);
  if (self->_fontSizeTextField == fontSizeChanged) {
    dVar3 = _objc_msgSend_fpret(self->_fontSizeStepper,sel_minValue);
    if (dVar3 <= (double)(int)pvVar1) {
      dVar3 = _objc_msgSend_fpret(self->_fontSizeStepper,sel_maxValue);
      if ((double)(int)pvVar1 <= dVar3) {
        _objc_msgSend(self->_fontSizeStepper,sel_setIntValue_,pvVar1);
        self_01 = self->_fontSizeSlider;
        lVar2 = (longdouble)_HSLinearValueForSliderFromNonLinear(self_01,(float)(int)pvVar1);
        goto LAB_001751d4;
      }
    }
  }
  else {
    if (self->_fontSizeStepper == fontSizeChanged) {
      _objc_msgSend(self->_fontSizeTextField,sel_setIntValue_,pvVar1);
      self_01 = self->_fontSizeSlider;
      lVar2 = (longdouble)_HSLinearValueForSliderFromNonLinear(self_01,(float)(int)pvVar1);
LAB_001751d4:
      pvVar4 = (id)(int)lVar2;
    }
    else {
      if (self->_fontSizeSlider != fontSizeChanged) goto LAB_00175228;
      lVar2 = (longdouble)_HSNonLinearValueForSlider(self->_fontSizeSlider);
      pvVar1 = (id)(int)lVar2;
      _objc_msgSend(self->_fontSizeTextField,sel_setIntValue_,pvVar1);
      self_01 = self->_fontSizeStepper;
      pvVar4 = pvVar1;
    }
    _objc_msgSend(self_01,sel_setIntValue_,pvVar4);
  }
LAB_00175228:
  dVar3 = _objc_msgSend_fpret(self->_characterSpaceField,sel_floatValue);
  _objc_msgSend(self,sel_setCharacterSpaceValue_,(float)dVar3);
  _objc_msgSend(self->_genericFontAttributes,sel_setHyperFontSize_,(float)(int)pvVar1);
  _objc_msgSend(self,sel_readjustCharacterSpacingValue);
LAB_0017528d:
  _objc_msgSend(self_00,sel_release);
  return;
}

*/
- (void)fontSizeChanged:(id)aChanged
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    if (_genericFontAttributes != nil) {
        int size = [aChanged intValue];
        if (_fontSizeTextField == aChanged) {
            if ([_fontSizeStepper minValue] <= (double)size && (double)size <= [_fontSizeStepper maxValue]) {
                [_fontSizeStepper setIntValue:size];
                [_fontSizeSlider setIntValue:(int)HSLinearValueForSliderFromNonLinear(_fontSizeSlider, (float)size)];
            }
        } else if (_fontSizeStepper == aChanged) {
            [_fontSizeTextField setIntValue:size];
            [_fontSizeSlider setIntValue:(int)HSLinearValueForSliderFromNonLinear(_fontSizeSlider, (float)size)];
        } else if (_fontSizeSlider == aChanged) {
            size = (int)HSNonLinearValueForSlider(_fontSizeSlider);
            [_fontSizeTextField setIntValue:size];
            [_fontSizeStepper setIntValue:size];
        }
        [self setCharacterSpaceValue:[_characterSpaceField floatValue]];
        [_genericFontAttributes setHyperFontSize:(float)size];
        [self readjustCharacterSpacingValue];
    }
    [pool release];
}

- (void)backgroundColorChanged:(id)aChanged
{
    id self_00;

    self_00 = _observedTextAttributes;
    if (self_00 != nil) {
        [self_00 setBackgroundColor:[aChanged color]];
    }
}

- (void)textColorChanged:(id)aChanged
{
    id self_00;

    self_00 = _observedTextAttributes;
    if (self_00 != nil) {
        [self_00 setTextColor:[aChanged color]];
    }
}

- (void)setVerticalAlignment:(id)aAlignment
{

}

- (void)setAlign:(id)aAlign
{
    NSInteger pvVar1_2;

    pvVar1_2 = [[aAlign selectedCell] tag];
    if (_fontAttributes != nil) {
        [_fontAttributes setHyperAlignment:pvVar1_2];
        if ([[[self assistant] object] queryHyperInterface:@protocol(HSButtonObjectAttributes)] != nil) {
            [_verticalAlignmentMatrix deselectAllCells];
            [aAlign deselectAllCells];
            [aAlign selectCellWithTag:[_fontAttributes hyperAlignment]];
        }
    }
}

- (void)editShadow:(id)aShadow
{
    [self showShadowPane];
}

- (void)setShadow:(id)aShadow
{
    NSInteger pvVar1;
    BOOL uVar2;
    id pvVar1_2;

    pvVar1 = [aShadow state];
    if (pvVar1 == 0) {
        pvVar1_2 = _fontAttributes;
        uVar2 = 0;
    }
    else {
        if (pvVar1 != 0x1) {
            return;
        }
        pvVar1_2 = _fontAttributes;
        uVar2 = 1;
    }
    [pvVar1_2 setHyperShadowEnabled:uVar2];
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

- (void)editOutline:(id)aOutline
{
    [self showOutlinePane];
}

- (void)setOutline:(id)aOutline
{
    NSInteger pvVar1;
    BOOL uVar2;
    id pvVar1_2;

    pvVar1 = [aOutline state];
    if (pvVar1 == 0) {
        pvVar1_2 = _fontAttributes;
        uVar2 = 0;
    }
    else {
        if (pvVar1 != 0x1) {
            return;
        }
        pvVar1_2 = _fontAttributes;
        uVar2 = 1;
    }
    [pvVar1_2 setHyperOutlineEnabled:uVar2];
}

- (void)showOutlinePane
{
    id self_00;
    id pvVar1_2;

    self_00 = [HSTextOutlineAssistantPane new];
    pvVar1_2 = [[HSObjectAssistantNavigationController alloc] initWithRootViewController:self_00];
    [self presentModalViewController:pvVar1_2 animated:YES];
    [pvVar1_2 release];
    [self_00 release];
}

- (void)setUnderline:(id)aUnderline
{
    id self_00;

    self_00 = _fontAttributes;
    if (self_00 != nil) {
        [self_00 setHyperUnderlined:(unsigned int)([[aUnderline cellWithTag:3] state] == 0x1)];
    }
}

- (void)setItalic:(id)aItalic
{
    id self_00;

    self_00 = _genericFontAttributes;
    if (self_00 != nil) {
        [self_00 setHyperItalic:(unsigned int)([[aItalic cellWithTag:2] state] == 0x1)];
    }
}

- (void)setBold:(id)aBold
{
    id self_00;

    self_00 = _genericFontAttributes;
    if (self_00 != nil) {
        [self_00 setHyperBold:(unsigned int)([[aBold cellWithTag:1] state] == 0x1)];
    }
}

- (void)setCharacterSpaceValue:(CGFloat)aValue
{
    _characterSpaceValue = aValue;
}

- (CGFloat)characterSpaceValue
{
    return _characterSpaceValue;
}

- (void)readjustCharacterSpacingValue
{
    if (0.0 < (float)[_fontAttributes hyperSpaceBetweenCharacters]) {
        [_fontAttributes setHyperSpaceBetweenCharacters:((float)[_genericFontAttributes hyperFontSize] * (float)[self characterSpaceValue]) / 100.0]
        ;
    }
}

- (void)validateAlignmentMatrixState
{
    id pvVar1;

    pvVar1 = [_observedTextAttributes hyperFontFamily];
    if (pvVar1 != nil) {
        [[_alignmentMatrix cellWithTag:3] setEnabled:(unsigned int)(![pvVar1 isEqualToString:@"Apple Chancery"])];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00175941 @ 00175941, 487 bytes * /

void FUN_00175941(HSTextStyleAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  undefined4 uVar3;
  char local_12;
  char local_11;
  
  pvVar1 = _objc_msgSend(self->_genericFontAttributes,sel_hyperFontFamily);
  if (pvVar1 == (id)0x0) {
    return;
  }
  pvVar2 = _objc_msgSend(cls_NSFontManager,sel_sharedFontManager);
  pvVar1 = _objc_msgSend(pvVar2,sel_availableMembersOfFontFamily_,pvVar1);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectEnumerator);
  pvVar2 = _objc_msgSend(pvVar1,sel_nextObject);
  if (pvVar2 == (id)0x0) {
    local_12 = '\0';
    local_11 = '\0';
  }
  else {
    local_11 = '\0';
    local_12 = '\0';
    do {
      uVar3 = 3;
      pvVar2 = _objc_msgSend(pvVar2,sel_objectAtIndex_,3);
      pvVar2 = _objc_msgSend(pvVar2,sel_unsignedIntValue);
      if (((uint)pvVar2 & 2) != 0) {
        local_11 = '\x01';
      }
      if (((uint)pvVar2 & 1) != 0) {
        local_12 = '\x01';
      }
      pvVar2 = _objc_msgSend(pvVar1,sel_nextObject,uVar3);
    } while (pvVar2 != (id)0x0);
    if (local_12 != '\0') goto LAB_00175a68;
  }
  pvVar1 = _objc_msgSend(self->_textStyleMatrix,sel_cellWithTag_,2);
  _objc_msgSend(pvVar1,sel_setState_,0);
LAB_00175a68:
  pvVar1 = _objc_msgSend(self->_textStyleMatrix,sel_cellWithTag_,2);
  _objc_msgSend(pvVar1,sel_setEnabled_,(int)local_12);
  if (local_11 == '\0') {
    pvVar1 = _objc_msgSend(self->_textStyleMatrix,sel_cellWithTag_,1);
    _objc_msgSend(pvVar1,sel_setState_,0);
  }
  pvVar1 = _objc_msgSend(self->_textStyleMatrix,sel_cellWithTag_,1);
  _objc_msgSend(pvVar1,sel_setEnabled_,(int)local_11);
  return;
}

*/
- (void)validateTextStyleMatrixState
{
    NSString *family = [_genericFontAttributes hyperFontFamily];
    if (family == nil) {
        return;
    }
    NSEnumerator *enumerator = [[[NSFontManager sharedFontManager] availableMembersOfFontFamily:family] objectEnumerator];
    id member;
    BOOL italic = NO;
    BOOL bold = NO;
    while ((member = [enumerator nextObject]) != nil) {
        NSUInteger traits = [[member objectAtIndex:3] unsignedIntValue];
        if (traits & 2) {
            bold = YES;
        }
        if (traits & 1) {
            italic = YES;
        }
    }
    if (!italic) {
        [[_textStyleMatrix cellWithTag:2] setState:0];
    }
    [[_textStyleMatrix cellWithTag:2] setEnabled:italic];
    if (!bold) {
        [[_textStyleMatrix cellWithTag:1] setState:0];
    }
    [[_textStyleMatrix cellWithTag:1] setEnabled:bold];
}

- (void)loadFontComboBox
{
    id pvVar1_3;
    id pvVar1_4;

    pvVar1_3 = [[[HSComboBoxCell alloc] init] autorelease];
    [pvVar1_3 setUsesDataSource:YES];
    [pvVar1_3 setControlSize:[[_fontComboBox cell] controlSize]];
    [_fontComboBox setCell:pvVar1_3];
    if ([pvVar1_3 respondsToSelector:@selector(setDelegate:)]) {
        [pvVar1_3 performSelector:@selector(setDelegate:) withObject:_fontComboBox];
    }
    [_fontComboBox setEditable:YES];
    pvVar1_4 = [HSFontComboboxDataSource sharedFontDataSource];
    _dataSource = pvVar1_4;
    [_fontComboBox setDataSource:pvVar1_4];
    [_fontComboBox setCompletes:YES];
}

- (BOOL)isEditingTextAttribute
{
    BOOL bVar2;

    if ([_fontSizeTextField currentEditor] == nil) {
        bVar2 = [_characterSpaceField currentEditor] != nil;
    }
    else {
        bVar2 = YES;
    }
    return bVar2;
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [super viewWillDisappear:aDisappear];
    [self setObservedTextAttributes:nil];
    [_fontAttributes release];
    _fontAttributes = nil;
    [_genericFontAttributes release];
    _genericFontAttributes = nil;
}

- (void)viewWillAppear:(BOOL)aAppear
{
    id pvVar2;
    id pvVar1_7;

    [super viewWillAppear:aAppear];
    pvVar2 = [[[self assistant] object] queryHyperInterface:@protocol(HSTextAttributes)];
    _fontAttributes = [[[[self assistant] object] queryHyperInterface:@protocol(HSSystemTextViewFontTraitsAttributes)] retain];
    pvVar1_7 = pvVar2;
    if (pvVar2 == nil) {
        pvVar1_7 = [[[self assistant] object] queryHyperInterface:@protocol(HSGenericFontAttributes)];
    }
    _genericFontAttributes = [pvVar1_7 retain];
    [self setObservedTextAttributes:pvVar2];
    [self validateUI];
    [self validateCharacterSpacingControls];
}

- (void)setObservedTextAttributes:(id)aAttributes
{
    int uVar1;
    id pvVar2;

    if (_observedTextAttributes != aAttributes) {
        pvVar2 = [_observedTextAttributes attributeObservingController];
        uVar1 = HSActualDidAttributeChanges;
        [pvVar2 removeObserver:self selector:@selector(validateUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSTextAttributes)];
        [aAttributes retain];
        [_observedTextAttributes release];
        _observedTextAttributes = aAttributes;
        [[aAttributes attributeObservingController] addObserver:self selector:@selector(validateUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSTextAttributes) withPriority:-0.25];
    }
}

- (id)lastKeyView
{
    return _backgroundColorWell;
}

- (id)firstKeyView
{
    return _fontComboBox;
}

- (void)viewDidLoad
{
    [self loadFontComboBox];
    [_textStyleMatrix setBackgroundRenderer:[HSAssistantPaneControlBackgroundRenderer sharedBackgroundRenderer]];
    [_alignmentMatrix setBackgroundRenderer:[HSAssistantPaneControlBackgroundRenderer sharedBackgroundRenderer]];
    [_verticalAlignmentMatrix setBackgroundRenderer:[HSAssistantPaneControlBackgroundRenderer sharedBackgroundRenderer]];
    [_textColorWell setPatternSupportEnabled:YES];
    [_textColorWell setGradientSupportEnabled:YES];
    [_backgroundColorWell setPatternSupportEnabled:YES];
    [_backgroundColorWell setGradientSupportEnabled:NO];
    [_fontSizeSlider setDelegate:self];
}

- (BOOL)isEnabled
{
    if ([[self object] implementsHyperInterface:@protocol(HSCardObjectAttributes)]) {
        if ([[[self object] queryHyperInterface:@protocol(HSCardObjectAttributes)] isLocked]) {
            return [[self object] implementsHyperInterface:@protocol(HSEmbeddedEditor)];
        }
    }
    return YES;
}

- (void)dealloc
{
    [_fontSizeSlider setDelegate:0];
    [_dataSource release];
    [[_observedTextAttributes attributeObservingController] removeObserver:self selector:@selector(validateUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSTextAttributes)];
    [_observedTextAttributes release];
    [_fontAttributes release];
    [_genericFontAttributes release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"TextStyleAssistantPane"];
    if (self != nil) {
        [self setTitle:[[NSBundle mainBundle] localizedStringForKey:@"Style" value:@"" table:@"AssistantPanes"]];
        [self setIcon:[NSImage imageNamed:@"style"]];
    }
    return self;
}

- (void)validateBackgroundColorControls
{
    BOOL transparent = ((BOOL (*)(id, SEL))objc_msgSend)([[[self assistant] object] queryHyperInterface:@protocol(HSSystemTextViewAttributes)], @selector(isTransparent));
    id runTimeEditor = [_observedTextAttributes queryHyperInterface:@protocol(HSRunTimeEditor)];
    BOOL enabled = NO;
    if (!transparent)
        enabled = _observedTextAttributes != runTimeEditor;
    [_backgroundColorWell setEnabled:enabled];
    [_backgroundColorWell setColor:[_observedTextAttributes backgroundColor]];
    [_backgroundTextField setTextColor:transparent ? [NSColor disabledControlTextColor] : [NSColor blackColor]];
}

@end

