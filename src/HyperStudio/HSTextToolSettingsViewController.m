#import "HSTextToolSettingsViewController.h"

static NSArray *sAvailableFontSizes = nil;

static float HSTextToolToleranceScale(float aValue)
{
    return aValue != 0.0f ? fabsf(aValue) : 1.0f;
}

static BOOL HSTextToolIsGreaterOrEqual(float aValue, float aValue2)
{
    return aValue >= aValue2 - MAX(HSTextToolToleranceScale(aValue), HSTextToolToleranceScale(aValue2)) * 0.0005f;
}

// An angle (in radians) brought into [0, 2pi).
static float HSTextToolNormalizedAngle(float aAngle)
{
    double fullTurn = M_PI + M_PI;
    if (HSTextToolIsGreaterOrEqual(aAngle, fullTurn))
        return (float)(floorf((float)(aAngle / fullTurn)) * M_PI * -2.0 + aAngle);
    if (aAngle < 0.0f) {
        float angle = (float)((floorf((float)(fabsf(aAngle) / fullTurn)) + 1.0) * fullTurn + aAngle);
        if (HSTextToolIsGreaterOrEqual(angle, fullTurn))
            angle = (float)(angle + M_PI * -2.0);
        return angle;
    }
    return aAngle;
}

@implementation HSTextToolSettingsViewController

/* i386 ivar offsets: _fontComboBox=0xc, _fontSizeComboBox=0x10, _fontStyleMatrix=0x14, _alignmentMatrix=0x18, _characterSpaceField=0x1c, _characterSpaceStepper=0x20, _formatPreview=0x24, _colorContainerView=0x28, _colorViewController=0x2c, _outlinePreview=0x30, _outlineColorContainerView=0x34, _outlineColorViewController=0x38, _outlineMatrix=0x3c, _shadowSwitch=0x40, _offsetSlider=0x44, _blurSlider=0x48, _angleSlider=0x4c, _angleField=0x50, _shadowPreview=0x54, _tabView=0x58, _formatView=0x5c, _outlineView=0x60, _shadowView=0x64, _characterSpaceValue=0x68, _tabHeights=0x6c, _dataSource=0x78, _fontSizeApplierTimer=0x7c, _previewTextObject=0x80 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_001480d6 @ 001480d6, 186 bytes * /

id FUN_001480d6(id self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  cfstringStruct *pcVar2;
  
  self_00 = cls_NSBundle;
  if (DAT_00342968 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_class);
    pvVar1 = _objc_msgSend(self_00,sel_bundleForClass_,pvVar1);
    pcVar2 = &cfstr_plist;
    pvVar1 = _objc_msgSend(pvVar1,sel_pathForResource_ofType_,&cfstr_FontSize,&cfstr_plist);
    if (pvVar1 != (id)0x0) {
      pvVar1 = _objc_msgSend(cls_NSArray,sel_arrayWithContentsOfFile_,pvVar1,pcVar2);
      DAT_00342968 = _objc_msgSend(pvVar1,sel_retain);
    }
  }
  return DAT_00342968;
}

*/
+ (id)availableFontSizes
{
    if (sAvailableFontSizes == nil) {
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"FontSize" ofType:@"plist"];
        if (path != nil) {
            sAvailableFontSizes = [[NSArray arrayWithContentsOfFile:path] retain];
        }
    }
    return sAvailableFontSizes;
}

- (void)selectedTabDidChangeInCustomTabView:(id)aView
{
    [[self parent] changeDrawerHeightTo:_tabHeights[(int)[aView indexOfSelectedTab]] + 6.0];
}

- (void)comboBoxDataChanged:(id)aChanged
{
    [_fontComboBox reloadData];
}

- (void)comboBoxWillDismiss:(id)aDismiss
{
    [[NSApp mainWindow] makeKeyWindow];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001482e0 @ 001482e0, 618 bytes * /

void FUN_001482e0(HSTextToolSettingsViewController *self,SEL _cmd,id controlTextDidEndEditing)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  SEL op;
  double dVar6;
  
  pvVar1 = _objc_msgSend(self,sel_textObjectAttributes);
  pvVar2 = _objc_msgSend(cls_NSFontManager,sel_sharedFontManager);
  if (pvVar1 == (id)0x0) {
    return;
  }
  pvVar3 = _objc_msgSend(controlTextDidEndEditing,sel_object);
  if (pvVar3 == self->_fontSizeComboBox) {
    pvVar1 = _objc_msgSend(controlTextDidEndEditing,sel_object);
    dVar6 = _objc_msgSend_fpret(pvVar1,sel_floatValue);
    pvVar3 = (id)(float)dVar6;
    _objc_msgSend(self,sel_setFontSize_,pvVar3);
    _objc_msgSend(self,sel_invalidateFontSizeApplierTimer);
  }
  else {
    pvVar3 = self->_dataSource;
    pvVar4 = _objc_msgSend(controlTextDidEndEditing,sel_object);
    pvVar5 = _objc_msgSend(pvVar4,sel_stringValue);
    pvVar4 = self->_fontComboBox;
    pvVar3 = _objc_msgSend(pvVar3,sel_comboBox_indexOfItemWithStringValue_,pvVar4,pvVar5);
    op = sel_validateUI;
    if (pvVar3 != (id)0x7fffffff) {
      pvVar5 = _objc_msgSend(self->_dataSource,sel_keyValueForItemAtIndex_,pvVar3,pvVar5);
      pvVar3 = _objc_msgSend(pvVar1,sel_hyperFont);
      pvVar4 = _objc_msgSend(pvVar2,sel_convertFont_toFamily_,pvVar3,pvVar5);
      if (pvVar4 == (id)0x0) goto LAB_0014847d;
      _objc_msgSend(pvVar1,sel_setHyperFont_,pvVar4,pvVar5);
      op = sel_validateTextStyleMatrixState;
    }
    _objc_msgSend(self,op,pvVar4,pvVar5);
    pvVar3 = pvVar4;
  }
LAB_0014847d:
  pvVar1 = _objc_msgSend(controlTextDidEndEditing,sel_object,pvVar3);
  pvVar1 = _objc_msgSend(pvVar1,sel_window);
  pvVar1 = _objc_msgSend(pvVar1,sel_currentEvent);
  pvVar2 = _objc_msgSend(pvVar1,sel_type);
  if ((pvVar2 == (id)0xa) &&
     (((pvVar2 = _objc_msgSend(pvVar1,sel_keyCode), (short)pvVar2 == 0x4c ||
       (pvVar2 = _objc_msgSend(pvVar1,sel_keyCode), (short)pvVar2 == 0x24)) ||
      (pvVar1 = _objc_msgSend(pvVar1,sel_keyCode), (short)pvVar1 == 0x34)))) {
    pvVar1 = _objc_msgSend(*(id *)PTR_00336058,sel_mainWindow);
    _objc_msgSend(pvVar1,sel_makeKeyWindow);
  }
  return;
}

*/
- (void)controlTextDidEndEditing:(id)aEditing
{
    id attributes = [self textObjectAttributes];
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    if (attributes == nil) {
        return;
    }
    if ([aEditing object] == _fontSizeComboBox) {
        [self setFontSize:[[aEditing object] floatValue]];
        [self invalidateFontSizeApplierTimer];
    } else {
        NSInteger index = [_dataSource comboBox:_fontComboBox indexOfItemWithStringValue:[[aEditing object] stringValue]];
        if (index == NSNotFound) {
            [self validateUI];
        } else {
            NSFont *font = [fontManager convertFont:[attributes hyperFont] toFamily:[_dataSource keyValueForItemAtIndex:index]];
            if (font != nil) {
                [attributes setHyperFont:font];
                [self validateTextStyleMatrixState];
            }
        }
    }
    NSEvent *event = [[[aEditing object] window] currentEvent];
    /* Enter, Return or the keypad Enter hand the focus back to the main window. */
    if ([event type] == NSEventTypeKeyDown && ([event keyCode] == 0x4c || [event keyCode] == 0x24 || [event keyCode] == 0x34)) {
        [[NSApp mainWindow] makeKeyWindow];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0014854a @ 0014854a, 420 bytes * /

void FUN_0014854a(HSTextToolSettingsViewController *self,SEL _cmd,id comboBoxSelectionDidChange)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  double dVar5;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_textObjectAttributes);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(cls_NSFontManager,sel_sharedFontManager);
    pvVar3 = _objc_msgSend(comboBoxSelectionDidChange,sel_object);
    if (pvVar3 == self->_fontSizeComboBox) {
      pvVar1 = _objc_msgSend(comboBoxSelectionDidChange,sel_object);
      pvVar1 = _objc_msgSend(pvVar1,sel_objectValueOfSelectedItem);
      dVar5 = _objc_msgSend_fpret(pvVar1,sel_floatValue);
      _objc_msgSend(self,sel_setFontSize_,(float)dVar5);
      pvVar1 = self->_fontSizeComboBox;
      pvVar2 = _objc_msgSend(pvVar1,sel_objectValueOfSelectedItem);
      _objc_msgSend(pvVar1,sel_setObjectValue_,pvVar2);
      op = sel_invalidateFontSizeApplierTimer;
    }
    else {
      pvVar3 = self->_dataSource;
      pvVar4 = _objc_msgSend(comboBoxSelectionDidChange,sel_object);
      pvVar4 = _objc_msgSend(pvVar4,sel_indexOfSelectedItem);
      pvVar3 = _objc_msgSend(pvVar3,sel_keyValueForItemAtIndex_,pvVar4);
      pvVar4 = _objc_msgSend(pvVar1,sel_hyperFont);
      pvVar2 = _objc_msgSend(pvVar2,sel_convertFont_toFamily_,pvVar4,pvVar3);
      if (pvVar2 == (id)0x0) {
        return;
      }
      _objc_msgSend(pvVar1,sel_setHyperFont_,pvVar2,pvVar3);
      op = sel_validateTextStyleMatrixState;
    }
    _objc_msgSend(self,op,pvVar2);
  }
  return;
}

*/
- (void)comboBoxSelectionDidChange:(id)aChange
{
    id attributes = [self textObjectAttributes];
    if (attributes == nil) {
        return;
    }
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    if ([aChange object] == _fontSizeComboBox) {
        [self setFontSize:[[[aChange object] objectValueOfSelectedItem] floatValue]];
        [_fontSizeComboBox setObjectValue:[_fontSizeComboBox objectValueOfSelectedItem]];
        [self invalidateFontSizeApplierTimer];
    } else {
        id family = [_dataSource keyValueForItemAtIndex:[[aChange object] indexOfSelectedItem]];
        NSFont *font = [fontManager convertFont:[attributes hyperFont] toFamily:family];
        if (font == nil) {
            return;
        }
        [attributes setHyperFont:font];
        [self validateTextStyleMatrixState];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00147e54 @ 00147e54, 433 bytes * /

void FUN_00147e54(HSTextToolSettingsViewController *self,SEL _cmd,id controlTextDidChange)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  
  pvVar1 = _objc_msgSend(controlTextDidChange,sel_object);
  if (pvVar1 != self->_fontSizeComboBox) {
    return;
  }
  pvVar1 = _objc_msgSend(controlTextDidChange,sel_object);
  pvVar1 = _objc_msgSend(pvVar1,sel_stringValue);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  pvVar2 = _objc_msgSend(pvVar1,sel_length);
  if (pvVar2 < (id)0x4) {
    pvVar4 = _objc_msgSend(pvVar1,sel_intValue);
    pvVar3 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr__d,pvVar4);
    pvVar2 = pvVar1;
    pvVar3 = _objc_msgSend(pvVar3,sel_isEqualToString_,pvVar1);
    if (((char)pvVar3 != '\0') ||
       (pvVar3 = _objc_msgSend(pvVar1,sel_length,pvVar2,pvVar4), pvVar3 == (id)0x0))
    goto LAB_00147fa8;
    pvVar3 = self->_fontSizeComboBox;
    pvVar4 = _objc_msgSend(pvVar1,sel_length,pvVar2,pvVar4);
    pvVar4 = (id)((int)pvVar4 + -1);
  }
  else {
    pvVar3 = self->_fontSizeComboBox;
    pvVar4 = (id)0x3;
  }
  pvVar2 = _objc_msgSend(pvVar1,sel_substringWithRange_,0,pvVar4);
  _objc_msgSend(pvVar3,sel_setStringValue_,pvVar2);
LAB_00147fa8:
  _objc_msgSend(pvVar1,sel_release,pvVar2,pvVar4);
  pvVar1 = _objc_msgSend(self->_fontSizeComboBox,sel_stringValue);
  pvVar1 = _objc_msgSend(pvVar1,sel_length);
  if (pvVar1 != (id)0x0) {
    _objc_msgSend(self,sel_setFontSizeApplierTimer);
  }
  return;
}

*/
- (void)controlTextDidChange:(id)aChange
{
    if ([aChange object] != _fontSizeComboBox) {
        return;
    }
    NSString *text = [[[aChange object] stringValue] retain];
    /* Keep only up to three digits. */
    if ([text length] < 4) {
        if (![[NSString stringWithFormat:@"%d", [text intValue]] isEqualToString:text] && [text length] != 0) {
            [_fontSizeComboBox setStringValue:[text substringWithRange:NSMakeRange(0, [text length] - 1)]];
        }
    } else {
        [_fontSizeComboBox setStringValue:[text substringWithRange:NSMakeRange(0, 3)]];
    }
    [text release];
    if ([[_fontSizeComboBox stringValue] length] != 0) {
        [self setFontSizeApplierTimer];
    }
}

- (void)setFontSize:(CGFloat)aSize
{
    [[self textObjectAttributes] setHyperFontSize:aSize];
    [self readjustCharacterSpacingValue];
}

- (void)applyFontSizeValue
{
    [self setFontSize:(float)[_fontSizeComboBox floatValue]];
}

- (void)invalidateFontSizeApplierTimer
{
    if (_fontSizeApplierTimer != nil) {
        if ([_fontSizeApplierTimer isValid]) {
            [_fontSizeApplierTimer invalidate];
            [_fontSizeApplierTimer autorelease];
            _fontSizeApplierTimer = nil;
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00147c5b @ 00147c5b, 314 bytes * /

void FUN_00147c5b(HSTextToolSettingsViewController *self,SEL _cmd)

{
  id pvVar1;
  
  _objc_msgSend(self->_fontSizeApplierTimer,sel_invalidate);
  _objc_msgSend(self->_fontSizeApplierTimer,sel_autorelease);
  pvVar1 = _objc_msgSend(cls_NSTimer,
                         sel_scheduledTimerWithTimeInterval_target_selector_userInfo_repeats_,0,
                         0x40000000,self,sel_applyFontSizeValue,0,0);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_fontSizeApplierTimer = pvVar1;
  pvVar1 = _objc_msgSend(cls_NSRunLoop,sel_currentRunLoop);
  _objc_msgSend(pvVar1,sel_addTimer_forMode_,self->_fontSizeApplierTimer,*(undefined4 *)PTR_003361b4
               );
  _objc_msgSend(pvVar1,sel_addTimer_forMode_,self->_fontSizeApplierTimer,*(undefined4 *)PTR_00336064
               );
  _objc_msgSend(pvVar1,sel_addTimer_forMode_,self->_fontSizeApplierTimer,*(undefined4 *)PTR_003363f8
               );
  return;
}

*/
- (void)setFontSizeApplierTimer
{
    [_fontSizeApplierTimer invalidate];
    [_fontSizeApplierTimer autorelease];
    _fontSizeApplierTimer = [[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(applyFontSizeValue) userInfo:nil repeats:NO] retain];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:_fontSizeApplierTimer forMode:NSDefaultRunLoopMode];
    [runLoop addTimer:_fontSizeApplierTimer forMode:NSEventTrackingRunLoopMode];
    [runLoop addTimer:_fontSizeApplierTimer forMode:NSModalPanelRunLoopMode];
}

- (id)colorPickingController
{
    return [[self toolView] queryHyperInterface:@protocol(HSColorPickingController)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00147ba9 @ 00147ba9, 110 bytes * /

void FUN_00147ba9(HSTextToolSettingsViewController *self,SEL _cmd,id colorViewController,
                 id changedColorTo)

{
  id self_00;
  SEL op;
  
  self_00 = _objc_msgSend(self,sel_textObjectAttributes);
  if ((self_00 != (id)0x0) &&
     ((op = sel_setHyperTextColor_, self->_colorViewController == colorViewController ||
      (op = sel_setHyperOutlineColor_, self->_outlineColorViewController == colorViewController))))
  {
    _objc_msgSend(self_00,op,changedColorTo);
  }
  _objc_msgSend(self,sel_validateBackgroundColor);
  return;
}

*/
- (void)colorViewController:(id)aController changedColorTo:(id)aTo
{
    id attributes = [self textObjectAttributes];
    if (attributes != nil) {
        if (_colorViewController == aController) {
            [attributes setHyperTextColor:aTo];
        } else if (_outlineColorViewController == aController) {
            [attributes setHyperOutlineColor:aTo];
        }
    }
    [self validateBackgroundColor];
}

- (BOOL)shouldDisplayGradientsAndPattersForColorViewController:(id)aController
{
    return _colorViewController == aController;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00148731 @ 00148731, 477 bytes * /

void FUN_00148731(HSTextToolSettingsViewController *self,SEL _cmd,id shadowAngleChanged)

{
  double dVar1;
  char cVar2;
  id self_00;
  longdouble lVar3;
  double dVar4;
  double dVar5;
  id self_01;
  SEL op;
  float fVar6;
  float local_2c;
  
  self_00 = _objc_msgSend(self,sel_shadowAttributes);
  if (self_00 == (id)0x0) {
    return;
  }
  dVar5 = _objc_msgSend_fpret(shadowAngleChanged,sel_floatValue);
  self_01 = self->_angleSlider;
  op = sel_setFloatValue_;
  fVar6 = (float)dVar5;
  if (self->_angleField != shadowAngleChanged) {
    if (self_01 != shadowAngleChanged) goto LAB_001487c0;
    self_01 = self->_angleField;
    op = sel_setIntValue_;
    fVar6 = (float)(int)dVar5;
  }
  _objc_msgSend(self_01,op,fVar6);
LAB_001487c0:
  dVar1 = *(double *)PTR_0033616c;
  dVar4 = dVar1 + dVar1;
  local_2c = ((float)dVar5 * -3.1415927) / -180.0 + 6.2831855;
  cVar2 = FUN_001469f8();
  if (cVar2 == '\0') {
    if (local_2c < 0.0) {
      lVar3 = (longdouble)_floorf((float)((double)ABS(local_2c) / dVar4));
      local_2c = (float)((double)local_2c + ((double)lVar3 + 1.0) * dVar4);
      cVar2 = FUN_001469f8();
      if (cVar2 != '\0') {
        local_2c = (float)((double)local_2c + dVar1 * -2.0);
      }
    }
  }
  else {
    lVar3 = (longdouble)_floorf((float)((double)local_2c / dVar4));
    local_2c = (float)(dVar1 * -2.0 * (double)lVar3 + (double)local_2c);
  }
  _objc_msgSend(self_00,sel_setHyperShadowAngle_,local_2c + -1.5707964);
  return;
}

*/
- (void)shadowAngleChanged:(id)aChanged
{
    id attributes = [self shadowAttributes];
    if (attributes == nil) {
        return;
    }
    float degrees = [aChanged floatValue];
    if (_angleField == aChanged) {
        [_angleSlider setFloatValue:degrees];
    } else if (_angleSlider == aChanged) {
        [_angleField setIntValue:(int)degrees];
    }
    /* The UI angle runs clockwise in degrees; the attribute is radians offset by a quarter turn. */
    float angle = HSTextToolNormalizedAngle((float)((degrees * -M_PI) / -180.0 + (M_PI + M_PI)));
    [attributes setHyperShadowAngle:(float)(angle + -M_PI_2)];
}

- (void)blurChanged:(id)aChanged
{
    id self_00;

    self_00 = [self shadowAttributes];
    if (self_00 != nil) {
        [self_00 setHyperShadowBlurRadius:(float)[aChanged floatValue]];
    }
}

- (void)offsetChanged:(id)aChanged
{
    id self_00;

    self_00 = [self shadowAttributes];
    if (self_00 != nil) {
        [self_00 setHyperShadowDistance:(float)[aChanged floatValue]];
    }
}

- (void)enableShadowControls:(BOOL)aControls
{
    int iVar1;

    iVar1 = (int)aControls;
    [_offsetSlider setEnabled:iVar1];
    [_blurSlider setEnabled:iVar1];
    [_angleSlider setEnabled:iVar1];
    [_angleField setEnabled:iVar1];
    [_angleField setEditable:iVar1];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001479d8 @ 001479d8, 310 bytes * /

void FUN_001479d8(HSTextToolSettingsViewController *self,SEL _cmd,id shadowEnabled)

{
  id pvVar1;
  uint uVar2;
  id pvVar3;
  id pvVar4;
  SEL op;
  
  pvVar1 = _objc_msgSend(shadowEnabled,sel_state);
  uVar2 = (uint)(pvVar1 == (id)0x1);
  _objc_msgSend(self,sel_enableShadowControls_,uVar2);
  pvVar1 = _objc_msgSend(self,sel_shadowAttributes);
  if (pvVar1 != (id)0x0) {
    pvVar3 = _objc_msgSend(shadowEnabled,sel_intValue,uVar2);
    _objc_msgSend(pvVar1,sel_setHyperShadowEnabled_,(int)(char)pvVar3);
    pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
    pvVar1 = _objc_msgSend(pvVar1,sel_currentToolSet);
    pvVar3 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
    pvVar3 = _objc_msgSend(pvVar3,sel_toolSettings);
    pvVar4 = _objc_msgSend(shadowEnabled,sel_intValue);
    op = sel_setFlatTextShadowEnabled_;
    if (pvVar1 == (id)0x1) {
      op = sel_setTextShadowEnabled_;
    }
    _objc_msgSend(pvVar3,op,(int)(char)pvVar4);
  }
  return;
}

*/
- (void)shadowEnabled:(id)aEnabled
{
    [self enableShadowControls:[aEnabled state] == NSControlStateValueOn];
    id attributes = [self shadowAttributes];
    if (attributes == nil) {
        return;
    }
    [attributes setHyperShadowEnabled:(BOOL)[aEnabled intValue]];
    id toolSettings = [[HSToolManager sharedToolManager] toolSettings];
    if ([[HSToolManager sharedToolManager] currentToolSet] == 1) {
        [toolSettings setTextShadowEnabled:(BOOL)[aEnabled intValue]];
    } else {
        [toolSettings setFlatTextShadowEnabled:(BOOL)[aEnabled intValue]];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001478fb @ 001478fb, 205 bytes * /

void FUN_001478fb(HSTextToolSettingsViewController *self,SEL _cmd,id outlineChanged)

{
  id self_00;
  id pvVar1;
  SEL pcVar2;
  undefined4 uVar3;
  
  self_00 = _objc_msgSend(self,sel_textObjectAttributes);
  pvVar1 = _objc_msgSend(outlineChanged,sel_selectedTag);
  pcVar2 = sel_setHyperOutlineWidth_;
  switch(pvVar1) {
  case (id)0x0:
    uVar3 = 0;
    pcVar2 = sel_setHyperOutlineEnabled_;
    break;
  case (id)0x1:
    uVar3 = 0xc0400000;
    break;
  case (id)0x2:
    uVar3 = 0xc0a00000;
    break;
  case (id)0x3:
    uVar3 = 0xc0e00000;
    break;
  default:
    goto switchD_00147946_default;
  }
  _objc_msgSend(self_00,pcVar2,uVar3);
switchD_00147946_default:
  _objc_msgSend(outlineChanged,sel_selectCellWithTag_,pvVar1);
  return;
}

*/
- (void)outlineChanged:(id)aChanged
{
    id attributes = [self textObjectAttributes];
    NSInteger tag = [aChanged selectedTag];
    /* Negative widths stroke and fill the glyphs. */
    switch (tag) {
    case 0:
        [attributes setHyperOutlineEnabled:NO];
        break;
    case 1:
        [attributes setHyperOutlineWidth:-3.0];
        break;
    case 2:
        [attributes setHyperOutlineWidth:-5.0];
        break;
    case 3:
        [attributes setHyperOutlineWidth:-7.0];
        break;
    }
    [aChanged selectCellWithTag:tag];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001489c4 @ 001489c4, 322 bytes * /

void FUN_001489c4(HSTextToolSettingsViewController *self,SEL _cmd,id characterSpacingValueChanged)

{
  float fVar1;
  id self_00;
  id pvVar2;
  double dVar3;
  
  self_00 = _objc_msgSend(self,sel_textObjectAttributes);
  if (self_00 == (id)0x0) {
    return;
  }
  dVar3 = _objc_msgSend_fpret(characterSpacingValueChanged,sel_floatValue);
  fVar1 = (float)dVar3;
  pvVar2 = self->_characterSpaceField;
  if (pvVar2 == characterSpacingValueChanged) {
    dVar3 = _objc_msgSend_fpret(self->_characterSpaceStepper,sel_minValue);
    if (((double)fVar1 < dVar3) ||
       (dVar3 = _objc_msgSend_fpret(self->_characterSpaceStepper,sel_maxValue),
       dVar3 < (double)fVar1)) goto LAB_00148aa5;
    pvVar2 = self->_characterSpaceStepper;
  }
  else if (self->_characterSpaceStepper != characterSpacingValueChanged) goto LAB_00148aa5;
  _objc_msgSend(pvVar2,sel_setFloatValue_,fVar1);
LAB_00148aa5:
  pvVar2 = _objc_msgSend(self,sel_genericFontAttributes);
  dVar3 = _objc_msgSend_fpret(pvVar2,sel_hyperFontSize);
  self->_characterSpaceValue = fVar1;
  _objc_msgSend(self_00,sel_setHyperSpaceBetweenCharacters_,(fVar1 * (float)dVar3) / 100.0);
  return;
}

*/
- (void)characterSpacingValueChanged:(id)aChanged
{
    id attributes = [self textObjectAttributes];
    if (attributes == nil) {
        return;
    }
    float value = [aChanged floatValue];
    if (_characterSpaceField == aChanged) {
        if (value >= [_characterSpaceStepper minValue] && value <= [_characterSpaceStepper maxValue]) {
            [_characterSpaceStepper setFloatValue:value];
        }
    } else if (_characterSpaceStepper == aChanged) {
        [_characterSpaceField setFloatValue:value];
    }
    float fontSize = [[self genericFontAttributes] hyperFontSize];
    _characterSpaceValue = value;
    /* The UI value is a percentage of the font size. */
    [attributes setHyperSpaceBetweenCharacters:(value * fontSize) / 100.0f];
}

- (void)setUnderline:(id)aUnderline
{
    id self_00;

    self_00 = [self textObjectAttributes];
    if (self_00 != nil) {
        [self_00 setHyperUnderlined:(unsigned int)([[aUnderline cellWithTag:3] state] == 0x1)];
    }
}

- (void)setItalic:(id)aItalic
{
    id self_00;

    self_00 = [self textObjectAttributes];
    if (self_00 != nil) {
        [self_00 setHyperItalic:(unsigned int)([[aItalic cellWithTag:2] state] == 0x1)];
    }
}

- (void)setBold:(id)aBold
{
    id self_00;

    self_00 = [self textObjectAttributes];
    if (self_00 != nil) {
        [self_00 setHyperBold:(unsigned int)([[aBold cellWithTag:1] state] == 0x1)];
    }
}

- (void)alignmentChanged:(id)aChanged
{
    id self_00;
    NSInteger pvVar1_2;
    NSInteger pvVar2_3;

    self_00 = [self textObjectAttributes];
    if (self_00 != nil) {
        pvVar1_2 = [[aChanged selectedCell] tag];
        if ([[aChanged cellWithTag:pvVar1_2] state]) {
            pvVar2_3 = 0;
            do {
                if (pvVar1_2 != pvVar2_3) {
                    [[aChanged cellWithTag:pvVar2_3] setState:0];
                }
                pvVar2_3 = (pvVar2_3 + 1);
            } while (pvVar2_3 != 0x4);
        }
        else {
            [[aChanged cellWithTag:0] setState:1];
            pvVar1_2 = 0;
        }
        [self_00 setHyperTextAlignment:pvVar1_2];
    }
}

- (void)readjustCharacterSpacingValue
{
    id self_00;

    self_00 = [self textObjectAttributes];
    if (0.0 < (float)[self_00 hyperSpaceBetweenCharacters]) {
        [self_00 setHyperSpaceBetweenCharacters:((float)[[self genericFontAttributes] hyperFontSize] * _characterSpaceValue) / 100.0];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00147518 @ 00147518, 330 bytes * /

void FUN_00147518(HSTextToolSettingsViewController *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_textObjectAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_isHyperOutlineEnabled);
  pvVar2 = _objc_msgSend(self,sel_textObjectAttributes);
  op = sel_hyperTextColor;
  if ((char)pvVar1 != '\0') {
    op = sel_hyperOutlineColor;
  }
  pvVar1 = _objc_msgSend(pvVar2,op);
  pvVar1 = _objc_msgSend(self,sel_backgroundColorForPreviewColor_,pvVar1);
  self_00 = cls_NSArray;
  pvVar2 = _objc_msgSend(self->_shadowPreview,sel_superview);
  pvVar3 = _objc_msgSend(self->_outlinePreview,sel_superview);
  pvVar4 = _objc_msgSend(self->_formatPreview,sel_superview);
  pvVar2 = _objc_msgSend(self_00,sel_arrayWithObjects_,self->_formatPreview,self->_outlinePreview,
                         self->_shadowPreview,pvVar4,pvVar3,pvVar2,0);
  _objc_msgSend(pvVar2,sel_makeObjectsPerformSelector_withObject_,sel_setBackgroundColor_,pvVar1);
  return;
}

*/
- (void)validateBackgroundColor
{
    id attributes = [self textObjectAttributes];
    BOOL isOutlined = [attributes isHyperOutlineEnabled];
    NSColor *previewColor = isOutlined ? [[self textObjectAttributes] hyperOutlineColor] : [[self textObjectAttributes] hyperTextColor];
    NSColor *backgroundColor = [self backgroundColorForPreviewColor:previewColor];
    NSArray *views = [NSArray arrayWithObjects:_formatPreview, _outlinePreview, _shadowPreview, [_formatPreview superview], [_outlinePreview superview], [_shadowPreview superview], nil];
    [views makeObjectsPerformSelector:@selector(setBackgroundColor:) withObject:backgroundColor];
}

- (void)validateTextStyleMatrixState
{
    NSFontManager *pvVar1;
    NSInteger pvVar2;
    id pvVar4;
    int pvVar5;
    int pvVar6;
    char local_16;
    char local_15;
    id pvVar2_7;
    NSEnumerator *pvVar3_2;
    NSFont *pvVar3_5;

    pvVar1 = [NSFontManager sharedFontManager];
    pvVar2 = [_fontComboBox indexOfSelectedItem];
    if (pvVar2 != 0xffffffff) {
        pvVar3_2 = [[pvVar1 availableMembersOfFontFamily:[_dataSource keyValueForItemAtIndex:pvVar2]] objectEnumerator];
        pvVar4 = [pvVar3_2 nextObject];
        if (pvVar4 == nil) {
            local_15 = NO;
            local_16 = NO;
        }
        else {
            local_15 = NO;
            local_16 = NO;
            do {
                pvVar5 = [[pvVar4 objectAtIndex:3] intValue];
                pvVar6 = [[pvVar4 objectAtIndex:3] intValue];
                [[pvVar4 objectAtIndex:3] intValue];
                [[pvVar4 objectAtIndex:3] intValue];
                if (((unsigned int)pvVar5 & 1) != 0) {
                    local_16 = YES;
                }
                if (((unsigned int)pvVar6 & 2) != 0) {
                    local_15 = YES;
                }
                pvVar4 = [pvVar3_2 nextObject];
            } while (pvVar4 != nil);
        }
        pvVar2_7 = [self textObjectAttributes];
        if (local_16 == NO) {
            [[_fontStyleMatrix cellWithTag:2] setState:0];
            pvVar3_5 = [pvVar1 convertFont:[pvVar2_7 hyperFont] toNotHaveTrait:1];
        }
        else {
            pvVar3_5 = nil;
        }
        [[_fontStyleMatrix cellWithTag:2] setEnabled:local_16];
        if (local_15 == NO) {
            [[_fontStyleMatrix cellWithTag:1] setState:0];
            pvVar3_5 = [pvVar1 convertFont:[pvVar2_7 hyperFont] toNotHaveTrait:2];
        }
        [[_fontStyleMatrix cellWithTag:1] setEnabled:local_15];
        if (pvVar3_5 != nil) {
            [pvVar2_7 setHyperFont:pvVar3_5];
        }
    }
}

- (void)validateOutlineMatrix
{
    float fVar1;
    id pvVar2;
    float fVar3;
    float fVar4;
    int uVar6;
    id pvVar2_2;
    float fVar3_2;
    float fVar3_3;
    float fVar4_2;
    float fVar4_3;

    pvVar2 = [self textObjectAttributes];
    if (pvVar2 != nil) {
        fVar1 = (float)[pvVar2 hyperOutlineWidth];
        fVar3 = fVar1 != 0.0 ? fabs(fVar1) : 1.0;
        fVar4 = 3.0;
        if (3.0 <= fVar3) {
            fVar4 = fVar3;
        }
        if (fVar4 * 0.0005 < fabs(fVar1 + 3.0)) {
            fVar3_2 = fVar1 != 0.0 ? fabs(fVar1) : 1.0;
            fVar4_2 = 5.0;
            if (5.0 <= fVar3_2) {
                fVar4_2 = fVar3_2;
            }
            if (fVar4_2 * 0.0005 < fabs(fVar1 + 5.0)) {
                fVar3_3 = fVar1 != 0.0 ? fabs(fVar1) : 1.0;
                fVar4_3 = 7.0;
                if (7.0 <= fVar3_3) {
                    fVar4_3 = fVar3_3;
                }
                pvVar2_2 = _outlineMatrix;
                if (fVar4_3 * 0.0005 < fabs(fVar1 + 7.0)) {
                    uVar6 = 0;
                }
                else {
                    uVar6 = 3;
                }
            }
            else {
                pvVar2_2 = _outlineMatrix;
                uVar6 = 2;
            }
        }
        else {
            pvVar2_2 = _outlineMatrix;
            uVar6 = 1;
        }
        [pvVar2_2 selectCellWithTag:uVar6];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00148d2b @ 00148d2b, 1269 bytes * /

void FUN_00148d2b(HSTextToolSettingsViewController *self,SEL _cmd)

{
  float fVar1;
  undefined *self_00;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  longdouble lVar6;
  float fVar7;
  double dVar8;
  undefined8 in_stack_ffffffc0;
  undefined4 uVar10;
  undefined8 uVar9;
  float local_30;
  float local_2c;
  
  uVar10 = (undefined4)((ulonglong)in_stack_ffffffc0 >> 0x20);
  pvVar2 = _objc_msgSend(self,sel_textObjectAttributes);
  if (pvVar2 != (id)0x0) {
    pvVar3 = _objc_msgSend(self->_fontStyleMatrix,sel_cellWithTag_,1);
    pvVar4 = _objc_msgSend(pvVar2,sel_isHyperBold);
    _objc_msgSend(pvVar3,sel_setState_,(uint)((char)pvVar4 != '\0'));
    pvVar3 = _objc_msgSend(self->_fontStyleMatrix,sel_cellWithTag_,2);
    pvVar4 = _objc_msgSend(pvVar2,sel_isHyperItalic);
    _objc_msgSend(pvVar3,sel_setState_,(uint)((char)pvVar4 != '\0'));
    pvVar3 = _objc_msgSend(self->_fontStyleMatrix,sel_cellWithTag_,3);
    pvVar4 = _objc_msgSend(pvVar2,sel_isHyperUnderlined);
    _objc_msgSend(pvVar3,sel_setState_,(uint)((char)pvVar4 != '\0'));
    pvVar3 = self->_colorViewController;
    pvVar4 = _objc_msgSend(pvVar2,sel_hyperTextColor);
    _objc_msgSend(pvVar3,sel_setColor_,pvVar4);
    dVar8 = _objc_msgSend_fpret(pvVar2,sel_hyperSpaceBetweenCharacters);
    pvVar3 = _objc_msgSend(self,sel_genericFontAttributes);
    fVar1 = (float)dVar8;
    dVar8 = _objc_msgSend_fpret(pvVar3,sel_hyperFontSize);
    lVar6 = (longdouble)_roundf((fVar1 * 100.0) / (float)dVar8);
    local_2c = (float)lVar6;
    if ((fVar1 != 0.0) || (NAN(fVar1))) {
      fVar7 = ABS(fVar1);
    }
    else {
      fVar7 = 1.0;
    }
    local_30 = 0.0005;
    if (1.0 <= fVar7) {
      local_30 = fVar7 * 0.0005;
    }
    fVar7 = local_2c;
    if (ABS(fVar1) <= local_30) {
      fVar7 = self->_characterSpaceValue;
    }
    _objc_msgSend(self->_characterSpaceField,sel_setFloatValue_,fVar7);
    if (ABS(fVar1) <= local_30) {
      local_2c = self->_characterSpaceValue;
    }
    _objc_msgSend(self->_characterSpaceStepper,sel_setFloatValue_,local_2c);
    pvVar3 = self->_alignmentMatrix;
    pvVar4 = _objc_msgSend(pvVar2,sel_hyperTextAlignment);
    _objc_msgSend(pvVar3,sel_selectCellWithTag_,pvVar4);
    pvVar3 = self->_outlineColorViewController;
    pvVar2 = _objc_msgSend(pvVar2,sel_hyperOutlineColor);
    _objc_msgSend(pvVar3,sel_setColor_,pvVar2);
    _objc_msgSend(self,sel_validateOutlineMatrix);
  }
  _objc_msgSend(self,sel_validateShadowUI);
  pvVar2 = _objc_msgSend(self,sel_genericFontAttributes);
  if (pvVar2 != (id)0x0) {
    pvVar3 = _objc_msgSend(pvVar2,sel_hyperFont);
    pvVar2 = self->_dataSource;
    pvVar4 = _objc_msgSend(pvVar3,sel_familyName);
    uVar9 = CONCAT44(uVar10,pvVar4);
    pvVar2 = _objc_msgSend(pvVar2,sel_comboBox_indexOfItemWithStringValue_,self->_fontComboBox,
                           pvVar4);
    pvVar4 = _objc_msgSend(self->_dataSource,sel_numberOfItemsInComboBox_,self->_fontComboBox);
    if (pvVar2 < pvVar4) {
      _objc_msgSend(self->_fontComboBox,sel_selectItemAtIndex_,pvVar2,uVar9);
    }
    self_00 = cls_NSString;
    dVar8 = _objc_msgSend_fpret(pvVar3,sel_pointSize);
    pvVar5 = _objc_msgSend(self_00,sel_stringWithFormat_,&cfstr___f,dVar8);
    pvVar2 = _objc_msgSend(self,sel_class);
    pvVar2 = _objc_msgSend(pvVar2,sel_availableFontSizes);
    pvVar3 = _objc_msgSend(pvVar2,sel_indexOfObject_,pvVar5);
    pvVar4 = _objc_msgSend(pvVar2,sel_count);
    pvVar2 = self->_fontSizeComboBox;
    if (pvVar3 <= pvVar4) {
      _objc_msgSend(pvVar2,sel_selectItemAtIndex_,pvVar3);
      pvVar2 = self->_fontSizeComboBox;
      pvVar5 = _objc_msgSend(pvVar2,sel_objectValueOfSelectedItem);
    }
    _objc_msgSend(pvVar2,sel_setObjectValue_,pvVar5);
  }
  _objc_msgSend(self,sel_rebuildPreview);
  _objc_msgSend(self,sel_validateBackgroundColor);
  return;
}

*/
- (void)validateUI
{
    id attributes = [self textObjectAttributes];
    if (attributes != nil) {
        [[_fontStyleMatrix cellWithTag:1] setState:[attributes isHyperBold] ? NSControlStateValueOn : NSControlStateValueOff];
        [[_fontStyleMatrix cellWithTag:2] setState:[attributes isHyperItalic] ? NSControlStateValueOn : NSControlStateValueOff];
        [[_fontStyleMatrix cellWithTag:3] setState:[attributes isHyperUnderlined] ? NSControlStateValueOn : NSControlStateValueOff];
        [_colorViewController setColor:[attributes hyperTextColor]];
        float spacing = [attributes hyperSpaceBetweenCharacters];
        float fontSize = [[self genericFontAttributes] hyperFontSize];
        float percentage = roundf((spacing * 100.0f) / fontSize);
        /* With no spacing keep showing the last value the user picked. */
        BOOL isZero = fabsf(spacing) <= MAX(HSTextToolToleranceScale(spacing), 1.0f) * 0.0005f;
        [_characterSpaceField setFloatValue:isZero ? _characterSpaceValue : percentage];
        [_characterSpaceStepper setFloatValue:isZero ? _characterSpaceValue : percentage];
        [_alignmentMatrix selectCellWithTag:[attributes hyperTextAlignment]];
        [_outlineColorViewController setColor:[attributes hyperOutlineColor]];
        [self validateOutlineMatrix];
    }
    [self validateShadowUI];
    id fontAttributes = [self genericFontAttributes];
    if (fontAttributes != nil) {
        NSFont *font = [fontAttributes hyperFont];
        NSInteger index = [_dataSource comboBox:_fontComboBox indexOfItemWithStringValue:[font familyName]];
        if (index < [_dataSource numberOfItemsInComboBox:_fontComboBox]) {
            [_fontComboBox selectItemAtIndex:index];
        }
        id sizeValue = [NSString stringWithFormat:@"%.f", (double)[font pointSize]];
        NSArray *sizes = [[self class] availableFontSizes];
        NSUInteger sizeIndex = [sizes indexOfObject:sizeValue];
        if (sizeIndex <= [sizes count]) {
            [_fontSizeComboBox selectItemAtIndex:sizeIndex];
            sizeValue = [_fontSizeComboBox objectValueOfSelectedItem];
        }
        [_fontSizeComboBox setObjectValue:sizeValue];
    }
    [self rebuildPreview];
    [self validateBackgroundColor];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00149220 @ 00149220, 731 bytes * /

void FUN_00149220(HSTextToolSettingsViewController *self,SEL _cmd)

{
  char cVar1;
  id self_00;
  id pvVar2;
  int iVar3;
  longdouble lVar4;
  float fVar5;
  double dVar6;
  float fVar7;
  float fVar8;
  double dVar9;
  double dVar10;
  undefined *puVar11;
  float local_34;
  
  self_00 = _objc_msgSend(self,sel_shadowAttributes);
  if (self_00 != (id)0x0) {
    pvVar2 = _objc_msgSend(self_00,sel_isHyperShadowEnabled);
    _objc_msgSend(self->_shadowSwitch,sel_setState_,(char)pvVar2 != '\0');
    iVar3 = (int)(char)pvVar2;
    _objc_msgSend(self,sel_enableShadowControls_,iVar3);
    puVar11 = sel_hyperShadowAngle;
    dVar9 = _objc_msgSend_fpret(self_00,sel_hyperShadowAngle);
    dVar10 = *(double *)PTR_0033616c;
    dVar6 = dVar10 + dVar10;
    fVar7 = (float)dVar6;
    local_34 = (float)(-1.5707963267948966 - dVar9);
    cVar1 = FUN_001469f8();
    if (cVar1 == '\0') {
      if (local_34 < 0.0) {
        lVar4 = (longdouble)_floorf((float)((double)ABS(local_34) / dVar6),puVar11,iVar3,fVar7);
        local_34 = (float)((double)local_34 + ((double)lVar4 + 1.0) * dVar6);
        cVar1 = FUN_001469f8();
        if (cVar1 != '\0') {
          local_34 = (float)((double)local_34 + dVar10 * -2.0);
        }
      }
    }
    else {
      lVar4 = (longdouble)_floorf((float)((double)local_34 / dVar6),puVar11,iVar3,fVar7);
      local_34 = (float)(dVar10 * -2.0 * (double)lVar4 + (double)local_34);
    }
    fVar7 = ((6.2831855 - local_34) / 3.1415927) * 180.0;
    if ((fVar7 != 0.0) || (NAN(fVar7))) {
      fVar5 = ABS(fVar7);
    }
    else {
      fVar5 = 1.0;
    }
    fVar8 = 360.0;
    if (360.0 <= fVar5) {
      fVar8 = fVar5;
    }
    if (fVar8 * -0.0005 + 360.0 <= fVar7) {
      fVar7 = fVar7 + -360.0;
    }
    _objc_msgSend(self->_angleField,sel_setFloatValue_,fVar7);
    _objc_msgSend(self->_angleSlider,sel_setFloatValue_,fVar7);
    pvVar2 = self->_blurSlider;
    dVar10 = _objc_msgSend_fpret(self_00,sel_hyperShadowBlurRadius);
    _objc_msgSend(pvVar2,sel_setFloatValue_,(float)dVar10);
    pvVar2 = self->_offsetSlider;
    dVar10 = _objc_msgSend_fpret(self_00,sel_hyperShadowDistance);
    _objc_msgSend(pvVar2,sel_setFloatValue_,(float)dVar10);
  }
  return;
}

*/
- (void)validateShadowUI
{
    id attributes = [self shadowAttributes];
    if (attributes == nil) {
        return;
    }
    BOOL isEnabled = [attributes isHyperShadowEnabled];
    [_shadowSwitch setState:isEnabled ? NSControlStateValueOn : NSControlStateValueOff];
    [self enableShadowControls:isEnabled];
    float angle = HSTextToolNormalizedAngle((float)(-M_PI_2 - [attributes hyperShadowAngle]));
    float degrees = ((6.2831855f - angle) / 3.1415927f) * 180.0f;
    if (HSTextToolIsGreaterOrEqual(degrees, 360.0f)) {
        degrees = degrees + -360.0f;
    }
    [_angleField setFloatValue:degrees];
    [_angleSlider setFloatValue:degrees];
    [_blurSlider setFloatValue:[attributes hyperShadowBlurRadius]];
    [_offsetSlider setFloatValue:[attributes hyperShadowDistance]];
}

- (void)validateShadowUIWithNotification:(id)aNotification
{
    [self validateShadowUI];
    [[self previewTextObject] updateWithTextObject:[self primaryPrototypeObject]];
}

- (void)validateUIWithNotification:(id)aNotification
{
    [self validateUI];
    [[self previewTextObject] updateWithTextObject:[self primaryPrototypeObject]];
}

- (void)rebuildPreview
{
    id pvVar1;

    pvVar1 = [self previewTextObject];
    if (pvVar1 != nil) {
        [_formatPreview removeAllUserObjects];
        [_formatPreview addUserObject:pvVar1];
        [_outlinePreview removeAllUserObjects];
        [_outlinePreview addUserObject:pvVar1];
        [_shadowPreview removeAllUserObjects];
        [_shadowPreview addUserObject:pvVar1];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001494fb @ 001494fb, 318 bytes * /

void FUN_001494fb(HSTextToolSettingsViewController *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  double dVar5;
  
  pvVar1 = _objc_msgSend(self,sel_textObjectAttributes);
  self_00 = cls_NSNumber;
  dVar5 = _objc_msgSend_fpret(pvVar1,sel_hyperFontSize);
  pvVar1 = (id)(int)dVar5;
  pvVar2 = _objc_msgSend(self_00,sel_numberWithInt_,pvVar1);
  pvVar3 = _objc_msgSend(self,sel_class);
  pvVar3 = _objc_msgSend(pvVar3,sel_availableFontSizes);
  _objc_msgSend(self->_fontSizeComboBox,sel_removeAllItems);
  pvVar4 = _objc_msgSend(pvVar3,sel_count);
  if (pvVar4 != (id)0x0) {
    pvVar1 = pvVar3;
    _objc_msgSend(self->_fontSizeComboBox,sel_addItemsWithObjectValues_,pvVar3);
  }
  pvVar1 = _objc_msgSend(pvVar2,sel_stringValue,pvVar1);
  pvVar1 = _objc_msgSend(pvVar3,sel_indexOfObject_,pvVar1);
  _objc_msgSend(self->_fontSizeComboBox,sel_selectItemAtIndex_,pvVar1);
  pvVar1 = self->_fontSizeComboBox;
  pvVar2 = _objc_msgSend(pvVar1,sel_objectValueOfSelectedItem);
  _objc_msgSend(pvVar1,sel_setObjectValue_,pvVar2);
  return;
}

*/
- (void)loadFontSizeComboBox
{
    NSNumber *fontSize = [NSNumber numberWithInt:(int)[[self textObjectAttributes] hyperFontSize]];
    NSArray *sizes = [[self class] availableFontSizes];
    [_fontSizeComboBox removeAllItems];
    if ([sizes count] != 0) {
        [_fontSizeComboBox addItemsWithObjectValues:sizes];
    }
    [_fontSizeComboBox selectItemAtIndex:[sizes indexOfObject:[fontSize stringValue]]];
    [_fontSizeComboBox setObjectValue:[_fontSizeComboBox objectValueOfSelectedItem]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00146df8 @ 00146df8, 566 bytes * /

void FUN_00146df8(HSTextToolSettingsViewController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar1 = _objc_msgSend(cls_HSComboBoxCell,sel_alloc);
  pvVar1 = _objc_msgSend(pvVar1,sel_init);
  pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  _objc_msgSend(pvVar1,sel_setUsesDataSource_,1);
  pvVar2 = _objc_msgSend(self->_fontComboBox,sel_cell);
  pvVar2 = _objc_msgSend(pvVar2,sel_controlSize);
  _objc_msgSend(pvVar1,sel_setControlSize_,pvVar2);
  pvVar2 = _objc_msgSend(pvVar1,sel_respondsToSelector_,sel_setDelegate_);
  if ((char)pvVar2 != '\0') {
    _objc_msgSend(pvVar1,sel_performSelector_withObject_,sel_setDelegate_,self->_fontComboBox);
  }
  _objc_msgSend(self->_fontComboBox,sel_setCell_,pvVar1);
  _objc_msgSend(self->_fontComboBox,sel_setNumberOfVisibleItems_,7);
  _objc_msgSend(self->_fontComboBox,sel_setEditable_,1);
  pvVar1 = _objc_msgSend(cls_HSFontComboboxDataSource,sel_sharedFontDataSource);
  self->_dataSource = pvVar1;
  _objc_msgSend(self->_fontComboBox,sel_setDataSource_,pvVar1);
  _objc_msgSend(self->_fontComboBox,sel_setCompletes_,1);
  pvVar2 = _objc_msgSend(self,sel_textObjectAttributes);
  pvVar1 = self->_dataSource;
  pvVar2 = _objc_msgSend(pvVar2,sel_hyperFontFamily);
  pvVar1 = _objc_msgSend(pvVar1,sel_comboBox_indexOfItemWithStringValue_,self->_fontComboBox,pvVar2)
  ;
  pvVar3 = _objc_msgSend(self->_dataSource,sel_numberOfItemsInComboBox_,self->_fontComboBox);
  if (pvVar1 < pvVar3) {
    _objc_msgSend(self->_fontComboBox,sel_selectItemAtIndex_,pvVar1,pvVar2);
  }
  return;
}

*/
- (void)loadFontComboBox
{
    HSComboBoxCell *cell = [[[HSComboBoxCell alloc] init] autorelease];
    [cell setUsesDataSource:YES];
    [cell setControlSize:[[_fontComboBox cell] controlSize]];
    if ([cell respondsToSelector:@selector(setDelegate:)]) {
        [cell performSelector:@selector(setDelegate:) withObject:_fontComboBox];
    }
    [_fontComboBox setCell:cell];
    [_fontComboBox setNumberOfVisibleItems:7];
    [_fontComboBox setEditable:YES];
    _dataSource = [HSFontComboboxDataSource sharedFontDataSource];
    [_fontComboBox setDataSource:(id)_dataSource];
    [_fontComboBox setCompletes:YES];
    NSInteger index = [_dataSource comboBox:_fontComboBox indexOfItemWithStringValue:[[self textObjectAttributes] hyperFontFamily]];
    if (index < [_dataSource numberOfItemsInComboBox:_fontComboBox]) {
        [_fontComboBox selectItemAtIndex:index];
    }
}

- (id)genericFontAttributes
{
    return [[self prototypeObject] queryHyperInterface:@protocol(HSGenericFontAttributes)];
}

- (id)shadowAttributes
{
    return [[self prototypeObject] queryHyperInterface:@protocol(HSMutableShadowAttributes)];
}

- (id)textObjectAttributes
{
    return [[self prototypeObject] queryHyperInterface:@protocol(HSTextObjectAttributes)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00149639 @ 00149639, 161 bytes * /

id FUN_00149639(HSTextToolSettingsViewController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  undefined1 local_24 [8];
  undefined4 local_1c;
  undefined4 local_18;
  
  pvVar1 = self->_previewTextObject;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_HSPreviewTextObject,sel_alloc);
    _objc_msgSend_stret(local_24,self->_outlinePreview,sel_bounds);
    pvVar2 = _objc_msgSend(self,sel_primaryPrototypeObject);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithTextObject_sizeOfOwnerView_,pvVar2,local_1c,local_18);
    self->_previewTextObject = pvVar1;
  }
  return pvVar1;
}

*/
- (id)previewTextObject
{
    if (_previewTextObject == nil) {
        _previewTextObject = [[HSPreviewTextObject alloc] initWithTextObject:[self primaryPrototypeObject] sizeOfOwnerView:[_outlinePreview bounds].size];
    }
    return _previewTextObject;
}

- (id)primaryPrototypeObject
{
    return [[[HSToolManager sharedToolManager] toolSettings] primaryUserObjectPrototypeForTool:[[HSToolManager sharedToolManager] currentTool]];
}

- (id)prototypeObject
{
    return [[[HSToolManager sharedToolManager] toolSettings] userObjectPrototypeForTool:[[HSToolManager sharedToolManager] currentTool]];
}

- (void)validateUserInterface
{
    [super validateUserInterface];
    [_colorViewController validateUserInterface];
    [_outlineColorViewController validateUserInterface];
}

- (void)willUnMount
{
    int uVar1;
    id pvVar2;
    id self_00;

    pvVar2 = [self textObjectAttributes];
    self_00 = [pvVar2 attributeObservingController];
    uVar1 = HSActualDidAttributeChanges;
    [self_00 removeObserver:self selector:@selector(validateUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSTextObjectAttributes)];
    [[pvVar2 attributeObservingController] removeObserver:self selector:@selector(validateShadowUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSShadowAttributes)];
}

- (void)didMount
{
    int uVar1;
    id pvVar2;
    id self_00;

    pvVar2 = [self textObjectAttributes];
    self_00 = [pvVar2 attributeObservingController];
    uVar1 = HSActualDidAttributeChanges;
    [self_00 addObserver:self selector:@selector(validateUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSTextObjectAttributes) withPriority:-0.25];
    [[pvVar2 attributeObservingController] addObserver:self selector:@selector(validateShadowUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSShadowAttributes) withPriority:-0.25];
    [self validateUI];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0014973d @ 0014973d, 2627 bytes * /

void FUN_0014973d(HSTextToolSettingsViewController *self,SEL _cmd)

{
  undefined4 uVar1;
  undefined4 uVar2;
  undefined *puVar3;
  undefined *puVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  id pvVar8;
  id pvVar9;
  id pvVar10;
  float extraout_EDX;
  float extraout_EDX_00;
  float extraout_EDX_01;
  undefined1 local_34 [16];
  undefined1 local_24 [20];
  
  _objc_msgSend(self->_tabView,sel_tabViewSizeForContentView_,self->_formatView);
  self->_tabHeights[0] = extraout_EDX;
  _objc_msgSend(self->_tabView,sel_tabViewSizeForContentView_,self->_outlineView);
  self->_tabHeights[1] = extraout_EDX_00;
  _objc_msgSend(self->_tabView,sel_tabViewSizeForContentView_,self->_shadowView);
  self->_tabHeights[2] = extraout_EDX_01;
  _objc_msgSend(self->_tabView,sel_setDelegate_,self);
  puVar4 = cls_NSDictionary;
  pvVar5 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar5 = _objc_msgSend(pvVar5,sel_localizedStringForKey_value_table_,&cfstr_tab,&cfstr_empty,0);
  puVar3 = cls_NSBundle;
  pvVar6 = _objc_msgSend(self,sel_class);
  pvVar6 = _objc_msgSend(puVar3,sel_bundleForClass_,pvVar6);
  pvVar6 = _objc_msgSend(pvVar6,sel_localizedStringForKey_value_table_,&cfstr_Format_settings,
                         &cfstr_empty,&cfstr_ToolPalette);
  uVar1 = *(undefined4 *)PTR_00336374;
  uVar2 = *(undefined4 *)PTR_0033653c;
  pvVar7 = _objc_msgSend(puVar4,sel_dictionaryWithObjectsAndKeys_,pvVar6,uVar2,pvVar5,uVar1,0);
  puVar3 = cls_NSBundle;
  pvVar5 = self->_tabView;
  pvVar6 = self->_formatView;
  pvVar8 = _objc_msgSend(self,sel_class);
  pvVar8 = _objc_msgSend(puVar3,sel_bundleForClass_,pvVar8);
  pvVar8 = _objc_msgSend(pvVar8,sel_localizedStringForKey_value_table_,&cfstr_Format_ToolTip,
                         &cfstr_empty,&cfstr_ToolPalette);
  pvVar9 = _objc_msgSend(cls_NSImage,sel_imageNamed_,&cfstr_TextFormat);
  puVar3 = cls_NSBundle;
  pvVar10 = _objc_msgSend(self,sel_class);
  pvVar10 = _objc_msgSend(puVar3,sel_bundleForClass_,pvVar10);
  pvVar10 = _objc_msgSend(pvVar10,sel_localizedStringForKey_value_table_,&cfstr_Format,&cfstr_empty,
                          &cfstr_ToolPalette);
  _objc_msgSend(pvVar5,sel_addTabWithTitle_image_toolTip_accessibilityValues_contentView_,pvVar10,
                pvVar9,pvVar8,pvVar7,pvVar6);
  puVar4 = cls_NSDictionary;
  pvVar5 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar5 = _objc_msgSend(pvVar5,sel_localizedStringForKey_value_table_,&cfstr_tab,&cfstr_empty,0);
  puVar3 = cls_NSBundle;
  pvVar6 = _objc_msgSend(self,sel_class);
  pvVar6 = _objc_msgSend(puVar3,sel_bundleForClass_,pvVar6);
  pvVar6 = _objc_msgSend(pvVar6,sel_localizedStringForKey_value_table_,&cfstr_Outline_settings,
                         &cfstr_empty,&cfstr_ToolPalette);
  pvVar7 = _objc_msgSend(puVar4,sel_dictionaryWithObjectsAndKeys_,pvVar6,uVar2,pvVar5,uVar1,0);
  puVar3 = cls_NSBundle;
  pvVar5 = self->_tabView;
  pvVar6 = self->_outlineView;
  pvVar8 = _objc_msgSend(self,sel_class);
  pvVar8 = _objc_msgSend(puVar3,sel_bundleForClass_,pvVar8);
  pvVar8 = _objc_msgSend(pvVar8,sel_localizedStringForKey_value_table_,&cfstr_Outline_ToolTip,
                         &cfstr_empty,&cfstr_ToolPalette);
  pvVar9 = _objc_msgSend(cls_NSImage,sel_imageNamed_,&cfstr_TextOutline);
  puVar3 = cls_NSBundle;
  pvVar10 = _objc_msgSend(self,sel_class);
  pvVar10 = _objc_msgSend(puVar3,sel_bundleForClass_,pvVar10);
  pvVar10 = _objc_msgSend(pvVar10,sel_localizedStringForKey_value_table_,&cfstr_Outline,&cfstr_empty
                          ,&cfstr_ToolPalette);
  _objc_msgSend(pvVar5,sel_addTabWithTitle_image_toolTip_accessibilityValues_contentView_,pvVar10,
                pvVar9,pvVar8,pvVar7,pvVar6);
  puVar4 = cls_NSDictionary;
  pvVar5 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar5 = _objc_msgSend(pvVar5,sel_localizedStringForKey_value_table_,&cfstr_tab,&cfstr_empty,0);
  puVar3 = cls_NSBundle;
  pvVar6 = _objc_msgSend(self,sel_class);
  pvVar6 = _objc_msgSend(puVar3,sel_bundleForClass_,pvVar6);
  pvVar6 = _objc_msgSend(pvVar6,sel_localizedStringForKey_value_table_,&cfstr_Shadow_settings,
                         &cfstr_empty,&cfstr_ToolPalette);
  pvVar7 = _objc_msgSend(puVar4,sel_dictionaryWithObjectsAndKeys_,pvVar6,uVar2,pvVar5,uVar1,0);
  puVar3 = cls_NSBundle;
  pvVar5 = self->_tabView;
  pvVar6 = self->_shadowView;
  pvVar8 = _objc_msgSend(self,sel_class);
  pvVar8 = _objc_msgSend(puVar3,sel_bundleForClass_,pvVar8);
  pvVar8 = _objc_msgSend(pvVar8,sel_localizedStringForKey_value_table_,&cfstr_Shadow_ToolTip,
                         &cfstr_empty,&cfstr_ToolPalette);
  pvVar9 = _objc_msgSend(cls_NSImage,sel_imageNamed_,&cfstr_TextShadow);
  puVar3 = cls_NSBundle;
  pvVar10 = _objc_msgSend(self,sel_class);
  pvVar10 = _objc_msgSend(puVar3,sel_bundleForClass_,pvVar10);
  pvVar10 = _objc_msgSend(pvVar10,sel_localizedStringForKey_value_table_,&cfstr_Shadow,&cfstr_empty,
                          &cfstr_ToolPalette);
  _objc_msgSend(pvVar5,sel_addTabWithTitle_image_toolTip_accessibilityValues_contentView_,pvVar10,
                pvVar9,pvVar8,pvVar7,pvVar6);
  _objc_msgSend(self,sel_loadFontSizeComboBox);
  _objc_msgSend(self,sel_loadFontComboBox);
  _objc_msgSend(self,sel_enableShadowControls_,0);
  pvVar5 = self->_alignmentMatrix;
  pvVar6 = _objc_msgSend(cls_HSToolSettingsControlBackgroundRenderer,sel_sharedBackgroundRenderer);
  _objc_msgSend(pvVar5,sel_setBackgroundRenderer_,pvVar6);
  pvVar5 = self->_fontStyleMatrix;
  pvVar6 = _objc_msgSend(cls_HSToolSettingsControlBackgroundRenderer,sel_sharedBackgroundRenderer);
  _objc_msgSend(pvVar5,sel_setBackgroundRenderer_,pvVar6);
  pvVar5 = self->_outlineMatrix;
  pvVar6 = _objc_msgSend(cls_HSToolSettingsBigControlBackgroundRenderer,sel_sharedBackgroundRenderer
                        );
  _objc_msgSend(pvVar5,sel_setBackgroundRenderer_,pvVar6);
  _objc_msgSend(self->_formatPreview,sel_setOpaque_,0);
  _objc_msgSend(self->_outlinePreview,sel_setOpaque_,0);
  _objc_msgSend(self->_shadowPreview,sel_setOpaque_,0);
  _objc_msgSend(self->_formatPreview,sel_setShouldPreserveOrigins_,0);
  _objc_msgSend(self->_outlinePreview,sel_setShouldPreserveOrigins_,0);
  _objc_msgSend(self->_shadowPreview,sel_setShouldPreserveOrigins_,0);
  _objc_msgSend(self->_formatPreview,sel_setShouldBeCentered_,1);
  _objc_msgSend(self->_outlinePreview,sel_setShouldBeCentered_,1);
  _objc_msgSend(self->_shadowPreview,sel_setShouldBeCentered_,1);
  _objc_msgSend(self->_colorViewController,sel_setDelegate_,self);
  pvVar5 = _objc_msgSend(self->_colorViewController,sel_colorView);
  _objc_msgSend_stret(local_34,self->_colorContainerView,sel_bounds);
  _objc_msgSend(pvVar5,sel_setFrame_,(int)local_34._0_8_,SUB84(local_34._0_8_,4),(int)local_34._8_8_
                ,SUB84(local_34._8_8_,4));
  _objc_msgSend(self->_colorContainerView,sel_addSubview_,pvVar5);
  pvVar5 = _objc_msgSend(self->_colorViewController,sel_crayonsView);
  _objc_msgSend(pvVar5,sel_setNeedsForceLayout_,1);
  _objc_msgSend(self->_outlineColorViewController,sel_setDelegate_,self);
  pvVar5 = _objc_msgSend(self->_outlineColorViewController,sel_colorView);
  _objc_msgSend_stret(local_24,self->_outlineColorContainerView,sel_bounds);
  _objc_msgSend(pvVar5,sel_setFrame_,(int)local_24._0_8_,SUB84(local_24._0_8_,4),(int)local_24._8_8_
                ,SUB84(local_24._8_8_,4));
  _objc_msgSend(self->_outlineColorContainerView,sel_addSubview_,pvVar5);
  self->_characterSpaceValue = 0.0;
  return;
}

*/
- (void)didLoadNib
{
    _tabHeights[0] = [_tabView tabViewSizeForContentView:_formatView].height;
    _tabHeights[1] = [_tabView tabViewSizeForContentView:_outlineView].height;
    _tabHeights[2] = [_tabView tabViewSizeForContentView:_shadowView].height;
    [_tabView setDelegate:self];
    NSDictionary *accessibility;
    accessibility = [NSDictionary dictionaryWithObjectsAndKeys:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Format settings" value:@"" table:@"ToolPalette"], NSAccessibilityDescriptionAttribute, [[NSBundle mainBundle] localizedStringForKey:@"tab" value:@"" table:nil], NSAccessibilityRoleDescriptionAttribute, nil];
    [_tabView addTabWithTitle:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Format" value:@"" table:@"ToolPalette"] image:[NSImage imageNamed:@"TextFormat"] toolTip:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Format ToolTip" value:@"" table:@"ToolPalette"] accessibilityValues:accessibility contentView:_formatView];
    accessibility = [NSDictionary dictionaryWithObjectsAndKeys:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Outline settings" value:@"" table:@"ToolPalette"], NSAccessibilityDescriptionAttribute, [[NSBundle mainBundle] localizedStringForKey:@"tab" value:@"" table:nil], NSAccessibilityRoleDescriptionAttribute, nil];
    [_tabView addTabWithTitle:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Outline" value:@"" table:@"ToolPalette"] image:[NSImage imageNamed:@"TextOutline"] toolTip:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Outline ToolTip" value:@"" table:@"ToolPalette"] accessibilityValues:accessibility contentView:_outlineView];
    accessibility = [NSDictionary dictionaryWithObjectsAndKeys:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Shadow settings" value:@"" table:@"ToolPalette"], NSAccessibilityDescriptionAttribute, [[NSBundle mainBundle] localizedStringForKey:@"tab" value:@"" table:nil], NSAccessibilityRoleDescriptionAttribute, nil];
    [_tabView addTabWithTitle:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Shadow" value:@"" table:@"ToolPalette"] image:[NSImage imageNamed:@"TextShadow"] toolTip:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Shadow ToolTip" value:@"" table:@"ToolPalette"] accessibilityValues:accessibility contentView:_shadowView];
    [self loadFontSizeComboBox];
    [self loadFontComboBox];
    [self enableShadowControls:NO];
    [_alignmentMatrix setBackgroundRenderer:[HSToolSettingsControlBackgroundRenderer sharedBackgroundRenderer]];
    [_fontStyleMatrix setBackgroundRenderer:[HSToolSettingsControlBackgroundRenderer sharedBackgroundRenderer]];
    [_outlineMatrix setBackgroundRenderer:[HSToolSettingsBigControlBackgroundRenderer sharedBackgroundRenderer]];
    [_formatPreview setOpaque:NO];
    [_outlinePreview setOpaque:NO];
    [_shadowPreview setOpaque:NO];
    [_formatPreview setShouldPreserveOrigins:NO];
    [_outlinePreview setShouldPreserveOrigins:NO];
    [_shadowPreview setShouldPreserveOrigins:NO];
    [_formatPreview setShouldBeCentered:YES];
    [_outlinePreview setShouldBeCentered:YES];
    [_shadowPreview setShouldBeCentered:YES];
    [_colorViewController setDelegate:self];
    NSView *colorView = [_colorViewController colorView];
    [colorView setFrame:[_colorContainerView bounds]];
    [_colorContainerView addSubview:colorView];
    [[_colorViewController crayonsView] setNeedsForceLayout:YES];
    [_outlineColorViewController setDelegate:self];
    colorView = [_outlineColorViewController colorView];
    [colorView setFrame:[_outlineColorContainerView bounds]];
    [_outlineColorContainerView addSubview:colorView];
    _characterSpaceValue = 0.0f;
}

- (id)nibName
{
    return @"TextToolSettings";
}

- (void)dealloc
{
    [_colorViewController release];
    [_outlineColorViewController release];
    [_fontComboBox setDataSource:0];
    [_dataSource release];
    [[[self textObjectAttributes] attributeObservingController] removeAttributeObserver:self];
    [_formatView release];
    [_outlineView release];
    [_shadowView release];
    [_fontSizeApplierTimer invalidate];
    [_fontSizeApplierTimer release];
    [_previewTextObject release];
    [super dealloc];
}

@end

