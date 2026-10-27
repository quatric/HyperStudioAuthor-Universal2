#import "HSStackSizesAssistantPane.h"

static BOOL HSStackSizesFloatsAreEqual(float a, float b)
{
    float ma = a != 0.0f ? fabsf(a) : 1.0f;
    float mb = b != 0.0f ? fabsf(b) : 1.0f;
    return fabsf(a - b) <= MAX(ma, mb) * 0.0005f;
}

@implementation HSStackSizesAssistantPane

/* i386 ivar offsets: _chooseSizeMatrix=0x5c, _standartSizesPopupButton=0x60, _widthTextField=0x64, _widthStepper=0x68, _heightTextField=0x6c, _heightStepper=0x70, _paneSwitcher=0x74, _applier=0x78, _cardSizesInfo=0x7c, _useDefaultCardSize=0x80 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ca8f3 @ 001ca8f3, 286 bytes * /

void FUN_001ca8f3(HSStackSizesAssistantPane *self,SEL _cmd,id stackWidthChanged)

{
  float fVar1;
  HSStackSizesAssistantPane *pHVar2;
  id pvVar3;
  undefined4 extraout_EDX;
  double dVar4;
  SEL op;
  
  pvVar3 = _objc_msgSend(self,sel_applier);
  _objc_msgSend(pvVar3,sel_hyperCardSize);
  dVar4 = _objc_msgSend_fpret(stackWidthChanged,sel_floatValue);
  op = sel_showAlert;
  if (40.0 <= (float)dVar4) {
    dVar4 = _objc_msgSend_fpret(stackWidthChanged,sel_floatValue);
    pvVar3 = _objc_msgSend(self,sel_applier);
    fVar1 = (float)dVar4;
    _objc_msgSend(pvVar3,sel_setHyperCardSize_,fVar1,extraout_EDX);
    pHVar2 = self->_widthTextField;
    if (pHVar2 == stackWidthChanged) {
      self = self->_widthStepper;
      _roundf(fVar1);
      op = sel_setFloatValue_;
    }
    else {
      _roundf(fVar1);
      self = pHVar2;
      op = sel_setFloatValue_;
    }
  }
  _objc_msgSend(self,op);
  return;
}

*/
- (void)stackWidthChanged:(id)aChanged
{
    NSSize size = [[self applier] hyperCardSize];
    float width;
    if ([aChanged floatValue] < 40.0f) {
        [self showAlert];
        return;
    }
    width = [aChanged floatValue];
    [[self applier] setHyperCardSize:NSMakeSize(width, size.height)];
    if (_widthTextField == aChanged) {
        [_widthStepper setFloatValue:roundf(width)];
    }
    else {
        [_widthTextField setFloatValue:roundf(width)];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001caa11 @ 001caa11, 280 bytes * /

void FUN_001caa11(HSStackSizesAssistantPane *self,SEL _cmd,id stackHeightChanged)

{
  HSStackSizesAssistantPane *pHVar1;
  id pvVar2;
  id self_00;
  double dVar3;
  SEL op;
  float fVar4;
  
  pvVar2 = _objc_msgSend(self,sel_applier);
  pvVar2 = _objc_msgSend(pvVar2,sel_hyperCardSize);
  dVar3 = _objc_msgSend_fpret(stackHeightChanged,sel_floatValue);
  op = sel_showAlert;
  if (40.0 <= (float)dVar3) {
    dVar3 = _objc_msgSend_fpret(stackHeightChanged,sel_floatValue);
    fVar4 = (float)dVar3;
    self_00 = _objc_msgSend(self,sel_applier);
    _objc_msgSend(self_00,sel_setHyperCardSize_,pvVar2,fVar4,fVar4);
    pHVar1 = self->_heightTextField;
    if (pHVar1 == stackHeightChanged) {
      self = self->_heightStepper;
      _roundf(fVar4);
      op = sel_setFloatValue_;
    }
    else {
      _roundf(fVar4);
      self = pHVar1;
      op = sel_setFloatValue_;
    }
  }
  _objc_msgSend(self,op);
  return;
}

*/
- (void)stackHeightChanged:(id)aChanged
{
    NSSize size = [[self applier] hyperCardSize];
    float height;
    if ([aChanged floatValue] < 40.0f) {
        [self showAlert];
        return;
    }
    height = [aChanged floatValue];
    [[self applier] setHyperCardSize:NSMakeSize(size.width, height)];
    if (_heightTextField == aChanged) {
        [_heightStepper setFloatValue:roundf(height)];
    }
    else {
        [_heightTextField setFloatValue:roundf(height)];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001cab29 @ 001cab29, 330 bytes * /

void FUN_001cab29(HSStackSizesAssistantPane *self,SEL _cmd,id standartSizeChanged)

{
  id pvVar1;
  id pvVar2;
  undefined8 uVar3;
  undefined4 local_18;
  undefined4 local_14;
  
  pvVar1 = _objc_msgSend(standartSizeChanged,sel_indexOfSelectedItem);
  pvVar2 = _objc_msgSend(self,sel_cardSizesInfo);
  pvVar2 = _objc_msgSend(pvVar2,sel_count);
  uVar3 = *(undefined8 *)PTR_0033607c;
  if (pvVar1 < pvVar2) {
    pvVar2 = _objc_msgSend(self,sel_cardSizesInfo);
    pvVar2 = _objc_msgSend(pvVar2,sel_objectAtIndex_,pvVar1);
    pvVar2 = _objc_msgSend(pvVar2,sel_objectForKey_,&cfstr_size);
    uVar3 = _NSSizeFromString(pvVar2);
  }
  local_18 = (undefined4)((ulonglong)uVar3 >> 0x20);
  local_14 = (undefined4)uVar3;
  pvVar2 = _objc_msgSend(self,sel_applier);
  _objc_msgSend(pvVar2,sel_setHyperCardSize_,local_14,local_18);
  pvVar2 = _objc_msgSend(self,sel_applier);
  _objc_msgSend(pvVar2,sel_setSelectedStandartSizeIndex_,pvVar1);
  _objc_msgSend(self,sel_validateCardSizeControls);
  return;
}

*/
- (void)standartSizeChanged:(id)aChanged
{
    NSInteger index = [aChanged indexOfSelectedItem];
    NSSize size = NSZeroSize;
    if ((NSUInteger)index < [[self cardSizesInfo] count]) {
        size = NSSizeFromString([[[self cardSizesInfo] objectAtIndex:index] objectForKey:@"size"]);
    }
    [[self applier] setHyperCardSize:size];
    [[self applier] setSelectedStandartSizeIndex:index];
    [self validateCardSizeControls];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001cac73 @ 001cac73, 534 bytes * /

void FUN_001cac73(HSStackSizesAssistantPane *self,SEL _cmd,id sizeTypeChanged)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  undefined8 uVar3;
  double dVar4;
  double dVar5;
  undefined4 uVar6;
  undefined4 local_30;
  undefined4 local_24;
  
  pvVar1 = _objc_msgSend(sizeTypeChanged,sel_selectedCell);
  pvVar1 = _objc_msgSend(pvVar1,sel_tag);
  uVar3 = *(undefined8 *)PTR_0033607c;
  if (pvVar1 == (id)0x0) {
    uVar6 = 0;
    _objc_msgSend(self,sel_enableCustomSizeControls_,0);
    pvVar2 = _objc_msgSend(self->_standartSizesPopupButton,sel_indexOfSelectedItem);
    if (pvVar2 != (id)0xffffffff) {
      self_00 = _objc_msgSend(self,sel_cardSizesInfo,uVar6);
      pvVar2 = _objc_msgSend(self_00,sel_objectAtIndex_,pvVar2);
      pvVar2 = _objc_msgSend(pvVar2,sel_objectForKey_,&cfstr_size);
      uVar3 = _NSSizeFromString(pvVar2);
    }
  }
  else {
    uVar3 = *(undefined8 *)PTR_0033607c;
    if (pvVar1 == (id)0x1) {
      dVar4 = _objc_msgSend_fpret(self->_widthTextField,sel_floatValue);
      dVar5 = _objc_msgSend_fpret(self->_heightTextField,sel_floatValue);
      _objc_msgSend(self,sel_enableCustomSizeControls_,1);
      pvVar2 = _objc_msgSend(self->_widthTextField,sel_window);
      uVar3 = CONCAT44((float)dVar5,(float)dVar4);
      _objc_msgSend(pvVar2,sel_makeFirstResponder_,self->_widthTextField);
    }
  }
  local_30 = (undefined4)((ulonglong)uVar3 >> 0x20);
  local_24 = (undefined4)uVar3;
  pvVar2 = _objc_msgSend(self,sel_applier);
  _objc_msgSend(pvVar2,sel_setHyperCardSize_,local_24,local_30);
  pvVar2 = _objc_msgSend(self,sel_applier);
  _objc_msgSend(pvVar2,sel_setSelectedSizeMatrixIndex_,pvVar1);
  _objc_msgSend(self,sel_validateCardSizeControls);
  return;
}

*/
- (void)sizeTypeChanged:(id)aChanged
{
    NSInteger tag = [[aChanged selectedCell] tag];
    NSSize size = NSZeroSize;
    NSInteger index;
    if (tag == 0) {
        [self enableCustomSizeControls:NO];
        index = [_standartSizesPopupButton indexOfSelectedItem];
        if (index != -1) {
            size = NSSizeFromString([[[self cardSizesInfo] objectAtIndex:index] objectForKey:@"size"]);
        }
    }
    else if (tag == 1) {
        size.width = [_widthTextField floatValue];
        size.height = [_heightTextField floatValue];
        [self enableCustomSizeControls:YES];
        [[_widthTextField window] makeFirstResponder:_widthTextField];
    }
    [[self applier] setHyperCardSize:size];
    [[self applier] setSelectedSizeMatrixIndex:tag];
    [self validateCardSizeControls];
}

- (void)setUseDefaultCardSize:(BOOL)aSize
{
    _useDefaultCardSize = aSize;
}

- (id)helpTopicKey
{
    return @"HSCardSizeTopic";
}

- (void)paneDidCancel:(id)aCancel
{
    [_widthTextField abortEditing];
    [_heightTextField abortEditing];
    [[self applier] revertChanges];
    [self dismiss:YES];
}

- (void)paneDidOK:(id)aOK
{
    if ([[self window] makeFirstResponder:[self window]]) {
        [[self applier] applyChanges];
        [[self applier] makeInitialEqualToCurrent];
        [self dismiss:YES slide:NO];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ca5cc @ 001ca5cc, 208 bytes * /

BOOL FUN_001ca5cc(HSStackSizesAssistantPane *self,SEL _cmd,id control,id didFailToFormatString,
                 id errorDescription)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(didFailToFormatString,sel_intValue);
  if (self->_widthTextField == control) {
    if ((float)(int)pvVar1 < 40.0) {
      _objc_msgSend(self,sel_showAlert);
    }
    if ((float)(int)pvVar1 <= 5120.0) goto LAB_001ca680;
  }
  else {
    if (self->_heightTextField != control) goto LAB_001ca680;
    if ((float)(int)pvVar1 < 40.0) {
      _objc_msgSend(self,sel_showAlert);
    }
    if ((float)(int)pvVar1 <= 3200.0) goto LAB_001ca680;
  }
  _objc_msgSend(self,sel_showMaximumExceededSizeAlert);
LAB_001ca680:
  _objc_msgSend(control,sel_abortEditing);
  return '\0';
}

*/
- (BOOL)control:(id)aControl didFailToFormatString:(id)aString errorDescription:(id)aDescription
{
    float value = (float)[aString intValue];
    if (_widthTextField == aControl) {
        if (value < 40.0f) {
            [self showAlert];
        }
        if (value > 5120.0f) {
            [self showMaximumExceededSizeAlert];
        }
    }
    else if (_heightTextField == aControl) {
        if (value < 40.0f) {
            [self showAlert];
        }
        if (value > 3200.0f) {
            [self showMaximumExceededSizeAlert];
        }
    }
    [aControl abortEditing];
    return NO;
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [[self applier] restoreIfNotApplied];
    [[self navigationPaneSwitcher] setApplier:nil];
    [super viewWillDisappear:aDisappear];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001caf1a @ 001caf1a, 727 bytes * /

void FUN_001caf1a(HSStackSizesAssistantPane *self,SEL _cmd,BOOL viewWillAppear)

{
  id pvVar1;
  cfstringStruct *pcVar2;
  cfstringStruct *pcVar3;
  id pvVar4;
  float extraout_EDX;
  float fVar5;
  cfstringStruct *pcVar6;
  undefined4 uVar7;
  float fVar8;
  float fVar9;
  float fVar10;
  undefined8 uVar11;
  HSStackSizesAssistantPane *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSObjectAssistantPane_00353ab0;
  _objc_msgSendSuper(&local_1c,sel_viewWillAppear_,(int)viewWillAppear);
  pvVar1 = _objc_msgSend(self,sel_applier);
  _objc_msgSend(pvVar1,sel_updateObject);
  pvVar1 = _objc_msgSend(self,sel_navigationPaneSwitcher);
  pcVar2 = _objc_msgSend(self,sel_applier);
  _objc_msgSend(pvVar1,sel_setApplier_,pcVar2);
  pvVar1 = _objc_msgSend(self,sel_cardSizesInfo);
  pcVar3 = _objc_msgSend(pvVar1,sel_count);
  pvVar1 = _objc_msgSend(self,sel_applier);
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperCardSize);
  pcVar6 = (cfstringStruct *)0x0;
  do {
    if (pcVar3 <= pcVar6) {
      uVar7 = 1;
      pcVar6 = pcVar2;
LAB_001cb17e:
      pvVar1 = _objc_msgSend(self,sel_applier,pcVar6);
      _objc_msgSend(pvVar1,sel_setSelectedSizeMatrixIndex_,uVar7);
      pvVar1 = _objc_msgSend(self->_chooseSizeMatrix,sel_window);
      _objc_msgSend(pvVar1,sel_makeFirstResponder_,self->_chooseSizeMatrix);
      _objc_msgSend(self,sel_validateUI);
      return;
    }
    pvVar4 = _objc_msgSend(self,sel_cardSizesInfo,pcVar2);
    pvVar4 = _objc_msgSend(pvVar4,sel_objectAtIndex_,pcVar6);
    pcVar2 = &cfstr_size;
    pvVar4 = _objc_msgSend(pvVar4,sel_objectForKey_);
    uVar11 = _NSSizeFromString(pvVar4);
    fVar5 = (float)((ulonglong)uVar11 >> 0x20);
    fVar8 = (float)uVar11;
    if (((float)pvVar1 != 0.0) || (NAN((float)pvVar1))) {
      fVar9 = ABS((float)pvVar1);
    }
    else {
      fVar9 = 1.0;
    }
    if ((fVar8 != 0.0) || (NAN(fVar8))) {
      fVar10 = ABS(fVar8);
    }
    else {
      fVar10 = 1.0;
    }
    if (fVar10 <= fVar9) {
      fVar10 = fVar9;
    }
    if (ABS((float)pvVar1 - fVar8) <= fVar10 * 0.0005) {
      if ((extraout_EDX != 0.0) || (NAN(extraout_EDX))) {
        fVar8 = ABS(extraout_EDX);
      }
      else {
        fVar8 = 1.0;
      }
      if ((fVar5 != 0.0) || (NAN(fVar5))) {
        fVar9 = ABS(fVar5);
      }
      else {
        fVar9 = 1.0;
      }
      if (fVar9 <= fVar8) {
        fVar9 = fVar8;
      }
      if (ABS(extraout_EDX - fVar5) <= fVar9 * 0.0005) {
        pvVar1 = _objc_msgSend(self,sel_applier,pcVar2);
        _objc_msgSend(pvVar1,sel_setSelectedStandartSizeIndex_,pcVar6);
        uVar7 = 0;
        goto LAB_001cb17e;
      }
    }
    pcVar6 = (cfstringStruct *)((int)&pcVar6->field0_0x0 + 1);
  } while( true );
}

*/
- (void)viewWillAppear:(BOOL)aAppear
{
    NSUInteger count;
    NSSize size;
    NSUInteger i;
    NSInteger matrixIndex = 1;
    [super viewWillAppear:aAppear];
    [[self applier] updateObject];
    [[self navigationPaneSwitcher] setApplier:[self applier]];
    count = [[self cardSizesInfo] count];
    size = [[self applier] hyperCardSize];
    for (i = 0; i < count; i++) {
        NSSize standardSize = NSSizeFromString([[[self cardSizesInfo] objectAtIndex:i] objectForKey:@"size"]);
        if (HSStackSizesFloatsAreEqual(size.width, standardSize.width) && HSStackSizesFloatsAreEqual(size.height, standardSize.height)) {
            [[self applier] setSelectedStandartSizeIndex:i];
            matrixIndex = 0;
            break;
        }
    }
    [[self applier] setSelectedSizeMatrixIndex:matrixIndex];
    [[_chooseSizeMatrix window] makeFirstResponder:_chooseSizeMatrix];
    [self validateUI];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ca4eb @ 001ca4eb, 225 bytes * /

id FUN_001ca4eb(HSStackSizesAssistantPane *self,SEL _cmd)

{
  HSStackAssistantPaneApplier *self_00;
  id pvVar1;
  id pvVar2;
  undefined4 extraout_EDX;
  
  if (self->_applier == (HSStackAssistantPaneApplier *)0x0) {
    pvVar1 = _objc_msgSend(cls_HSStackAssistantPaneApplier,sel_alloc);
    pvVar2 = _objc_msgSend(self,sel_assistant);
    pvVar2 = _objc_msgSend(pvVar2,sel_object);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithObject_,pvVar2);
    pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
    _objc_msgSend(self,sel_setApplier_,pvVar1);
    if (self->_useDefaultCardSize != '\0') {
      self_00 = self->_applier;
      pvVar1 = _objc_msgSend(cls_HSUserObjectDefaultAttributesProvider,sel_defaultCardSize,pvVar1);
      _objc_msgSend(self_00,sel_setHyperCardSize_,pvVar1,extraout_EDX);
    }
  }
  return self->_applier;
}

*/
- (id)applier
{
    if (_applier == nil) {
        [self setApplier:[[[HSStackAssistantPaneApplier alloc] initWithObject:[[self assistant] object]] autorelease]];
        if (_useDefaultCardSize) {
            [_applier setHyperCardSize:[HSUserObjectDefaultAttributesProvider defaultCardSize]];
        }
    }
    return _applier;
}

- (void)setApplier:(id)aApplier
{
    if (_applier != aApplier) {
        [_applier autorelease];
        _applier = [aApplier retain];
    }
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

- (void)enableCustomSizeControls:(BOOL)aControls
{
    int iVar1;

    iVar1 = (int)aControls;
    [_widthTextField setEnabled:iVar1];
    [_widthStepper setEnabled:iVar1];
    [_heightTextField setEnabled:iVar1];
    [_heightStepper setEnabled:iVar1];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ca25c @ 001ca25c, 367 bytes * /

void FUN_001ca25c(HSStackSizesAssistantPane *self,SEL _cmd)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  
  puVar1 = cls_NSString;
  pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                         &cfstr_Cards_must_be_at_least__d_points_wide_and__d_poi,&cfstr_empty,
                         &cfstr_Alerts);
  pvVar2 = _objc_msgSend(puVar1,sel_stringWithFormat_,pvVar2,0x28,0x28);
  puVar1 = cls_NSAlert;
  pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_OK,&cfstr_empty,
                         &cfstr_Alerts);
  pvVar4 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,&cfstr_Card_size_too_small,
                         &cfstr_empty,&cfstr_Alerts);
  pvVar2 = _objc_msgSend(puVar1,
                         sel_alertWithMessageText_defaultButton_alternateButton_otherButton_informativeTextWithFormat_
                         ,pvVar4,pvVar3,0,0,pvVar2);
  _objc_msgSend(pvVar2,sel_runModal);
  return;
}

*/
- (void)showAlert
{
    NSString *message = [NSString stringWithFormat:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Cards must be at least %d points wide and %d points high. Increase the dimensions and try again." value:@"" table:@"Alerts"], 40, 40];
    [[NSAlert alertWithMessageText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Card size too small" value:@"" table:@"Alerts"] defaultButton:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"OK" value:@"" table:@"Alerts"] alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", message] runModal];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ca0ed @ 001ca0ed, 367 bytes * /

void FUN_001ca0ed(HSStackSizesAssistantPane *self,SEL _cmd)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  
  puVar1 = cls_NSString;
  pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                         &cfstr_Cards_cannot_be_larger_than__d_by__d_pixels__Ent,&cfstr_empty,
                         &cfstr_Alerts);
  pvVar2 = _objc_msgSend(puVar1,sel_stringWithFormat_,pvVar2,0x1400,0xc80);
  puVar1 = cls_NSAlert;
  pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_OK,&cfstr_empty,
                         &cfstr_Alerts);
  pvVar4 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,
                         &cfstr_Cannot_change_card_size,&cfstr_empty,&cfstr_Alerts);
  pvVar2 = _objc_msgSend(puVar1,
                         sel_alertWithMessageText_defaultButton_alternateButton_otherButton_informativeTextWithFormat_
                         ,pvVar4,pvVar3,0,0,pvVar2);
  _objc_msgSend(pvVar2,sel_runModal);
  return;
}

*/
- (void)showMaximumExceededSizeAlert
{
    NSString *message = [NSString stringWithFormat:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Cards cannot be larger than %d by %d pixels. Enter a different width and height and try again." value:@"" table:@"Alerts"], 5120, 3200];
    [[NSAlert alertWithMessageText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Cannot change card size" value:@"" table:@"Alerts"] defaultButton:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"OK" value:@"" table:@"Alerts"] alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", message] runModal];
}

- (void)validateUI
{
    [_chooseSizeMatrix selectCellWithTag:[[self applier] selectedSizeMatrixIndex]];
    [_standartSizesPopupButton selectItemAtIndex:[[self applier] selectedStandartSizeIndex]];
    [self validateCardSizeControls];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001cb1f1 @ 001cb1f1, 428 bytes * /

id FUN_001cb1f1(HSStackSizesAssistantPane *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  undefined4 uVar3;
  undefined1 local_24 [8];
  undefined4 local_1c;
  undefined4 local_18;
  
  self_00 = cls_NSBundle;
  pvVar1 = self->_cardSizesInfo;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_HSEditorBaseID,sel_class);
    pvVar1 = _objc_msgSend(self_00,sel_bundleForClass_,pvVar1);
    pvVar1 = _objc_msgSend(pvVar1,sel_pathForResource_ofType_,&cfstr_CardSizes,&cfstr_plist);
    pvVar2 = _objc_msgSend(cls_NSMutableArray,sel_alloc);
    pvVar1 = _objc_msgSend(pvVar2,sel_initWithContentsOfFile_,pvVar1);
    pvVar2 = _objc_msgSend(cls_NSScreen,sel_mainScreen);
    _objc_msgSend_stret(local_24,pvVar2,sel_frame);
    uVar3 = _NSStringFromSize(local_1c,local_18);
    pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_Current_resolution,
                           &cfstr_empty,&cfstr_AssistantPanes);
    pvVar2 = _objc_msgSend(cls_NSDictionary,sel_dictionaryWithObjectsAndKeys_,pvVar2,&cfstr_name,
                           uVar3,&cfstr_size,0);
    _objc_msgSend(pvVar1,sel_addObject_,pvVar2);
    self->_cardSizesInfo = pvVar1;
  }
  return pvVar1;
}

*/
- (id)cardSizesInfo
{
    NSMutableArray *sizes;
    NSString *screenSize;
    if (_cardSizesInfo == nil) {
        sizes = [[NSMutableArray alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[HSEditorBaseID class]] pathForResource:@"CardSizes" ofType:@"plist"]];
        screenSize = NSStringFromSize([[NSScreen mainScreen] frame].size);
        [sizes addObject:[NSDictionary dictionaryWithObjectsAndKeys:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Current_resolution" value:@"" table:@"AssistantPanes"], @"name", screenSize, @"size", nil]];
        _cardSizesInfo = sizes;
    }
    return _cardSizesInfo;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001cb39d @ 001cb39d, 312 bytes * /

void FUN_001cb39d(HSStackSizesAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  undefined4 extraout_EDX;
  longdouble lVar3;
  longdouble lVar4;
  float fVar5;
  
  pvVar1 = _objc_msgSend(self,sel_applier);
  pvVar2 = _objc_msgSend(pvVar1,sel_hyperCardSize);
  pvVar1 = self->_widthTextField;
  lVar3 = (longdouble)_roundf(pvVar2);
  _objc_msgSend(pvVar1,sel_setFloatValue_,(float)lVar3);
  pvVar1 = self->_heightTextField;
  lVar4 = (longdouble)_roundf(extraout_EDX);
  fVar5 = (float)lVar4;
  _objc_msgSend(pvVar1,sel_setFloatValue_,fVar5,fVar5);
  _objc_msgSend(self->_widthStepper,sel_setFloatValue_,(float)lVar3);
  _objc_msgSend(self->_heightStepper,sel_setFloatValue_,fVar5);
  pvVar1 = _objc_msgSend(self->_chooseSizeMatrix,sel_selectedCell);
  pvVar1 = _objc_msgSend(pvVar1,sel_tag);
  _objc_msgSend(self,sel_enableCustomSizeControls_,(uint)(pvVar1 == (id)0x1));
  return;
}

*/
- (void)validateCardSizeControls
{
    NSSize size = [[self applier] hyperCardSize];
    float width = roundf(size.width);
    float height = roundf(size.height);
    [_widthTextField setFloatValue:width];
    [_heightTextField setFloatValue:height];
    [_widthStepper setFloatValue:width];
    [_heightStepper setFloatValue:height];
    [self enableCustomSizeControls:[[_chooseSizeMatrix selectedCell] tag] == 1];
}

- (id)stackAttributes
{
    return [[self applier] queryHyperInterface:@protocol(HSMutableStackAttributes)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001cb4d5 @ 001cb4d5, 826 bytes * /

void FUN_001cb4d5(HSStackSizesAssistantPane *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined8 uVar4;
  
  _objc_msgSend(self->_standartSizesPopupButton,sel_removeAllItems);
  pvVar1 = _objc_msgSend(self,sel_cardSizesInfo);
  pvVar2 = _objc_msgSend(pvVar1,sel_objectEnumerator);
  pvVar1 = _objc_msgSend(pvVar2,sel_nextObject);
  while (pvVar1 != (id)0x0) {
    pvVar3 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_size);
    uVar4 = _NSSizeFromString(pvVar3);
    self_00 = cls_NSString;
    pvVar3 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_name);
    pvVar3 = _objc_msgSend(self_00,sel_stringWithFormat_,&cfstr__0_0f_x__0_0f___,
                           (double)(float)uVar4,(double)(float)((ulonglong)uVar4 >> 0x20),pvVar3);
    _objc_msgSend(self->_standartSizesPopupButton,sel_addItemWithTitle_,pvVar3);
    pvVar3 = _objc_msgSend(self->_standartSizesPopupButton,sel_itemWithTitle_,pvVar3);
    _objc_msgSend(pvVar3,sel_setRepresentedObject_,pvVar1);
    pvVar1 = _objc_msgSend(pvVar2,sel_nextObject);
  }
  pvVar1 = _objc_msgSend(self->_widthTextField,sel_formatter);
  pvVar2 = _objc_msgSend(cls_NSNumber,sel_numberWithFloat_,0x42200000);
  _objc_msgSend(pvVar1,sel_setMinimum_,pvVar2);
  _objc_msgSend(self->_widthStepper,sel_setMinValue_,0,0x40440000);
  pvVar1 = _objc_msgSend(self->_heightTextField,sel_formatter);
  pvVar2 = _objc_msgSend(cls_NSNumber,sel_numberWithFloat_,0x42200000);
  _objc_msgSend(pvVar1,sel_setMinimum_,pvVar2);
  _objc_msgSend(self->_heightStepper,sel_setMinValue_,0,0x40440000);
  pvVar1 = _objc_msgSend(self->_widthTextField,sel_formatter);
  pvVar2 = _objc_msgSend(cls_NSNumber,sel_numberWithFloat_,0x45a00000);
  _objc_msgSend(pvVar1,sel_setMaximum_,pvVar2);
  _objc_msgSend(self->_widthStepper,sel_setMaxValue_,0,0x40b40000);
  pvVar1 = _objc_msgSend(self->_heightTextField,sel_formatter);
  pvVar2 = _objc_msgSend(cls_NSNumber,sel_numberWithFloat_,0x45480000);
  _objc_msgSend(pvVar1,sel_setMaximum_,pvVar2);
  _objc_msgSend(self->_heightStepper,sel_setMaxValue_,0,0x40a90000);
  return;
}

*/
- (void)viewDidLoad
{
    NSEnumerator *sizes;
    id info;
    [_standartSizesPopupButton removeAllItems];
    sizes = [[self cardSizesInfo] objectEnumerator];
    while ((info = [sizes nextObject]) != nil) {
        NSSize size = NSSizeFromString([info objectForKey:@"size"]);
        NSString *title = [NSString stringWithFormat:@"%0.0f x %0.0f %@", (double)size.width, (double)size.height, [info objectForKey:@"name"]];
        [_standartSizesPopupButton addItemWithTitle:title];
        [[_standartSizesPopupButton itemWithTitle:title] setRepresentedObject:info];
    }
    [(NSNumberFormatter *)[_widthTextField formatter] setMinimum:[NSNumber numberWithFloat:40.0f]];
    [_widthStepper setMinValue:40.0];
    [(NSNumberFormatter *)[_heightTextField formatter] setMinimum:[NSNumber numberWithFloat:40.0f]];
    [_heightStepper setMinValue:40.0];
    [(NSNumberFormatter *)[_widthTextField formatter] setMaximum:[NSNumber numberWithFloat:5120.0f]];
    [_widthStepper setMaxValue:5120.0];
    [(NSNumberFormatter *)[_heightTextField formatter] setMaximum:[NSNumber numberWithFloat:3200.0f]];
    [_heightStepper setMaxValue:3200.0];
}

- (void)dealloc
{
    [_paneSwitcher release];
    [_applier release];
    [_cardSizesInfo release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"StackSizesAssistantPane"];
    return self;
}

@end

@implementation HSStackAssistantPaneApplier

/* i386 ivar offsets: _initialCardSize=0xc, _initialSelectedSizeMatrixIndex=0x14, _initialSelectedStandartSizeIndex=0x18, _currentCardSize=0x1c, _currentSelectedSizeMatrixIndex=0x24, _currentSelectedStandartSizeIndex=0x28 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ca858 @ 001ca858, 92 bytes * /

BOOL FUN_001ca858(HSStackAssistantPaneApplier *self,SEL _cmd)

{
  char cVar1;
  bool bVar2;
  
  cVar1 = _NSEqualSizes((self->_initialCardSize).width,(self->_initialCardSize).height,
                        (self->_currentCardSize).width,(self->_currentCardSize).height);
  if ((cVar1 == '\0') ||
     (self->_initialSelectedSizeMatrixIndex != self->_currentSelectedSizeMatrixIndex)) {
    bVar2 = false;
  }
  else {
    bVar2 = self->_initialSelectedStandartSizeIndex == self->_currentSelectedStandartSizeIndex;
  }
  return bVar2;
}

*/
- (BOOL)areSettingsEqual
{
    return NSEqualSizes(_initialCardSize, _currentCardSize)
        && _initialSelectedSizeMatrixIndex == _currentSelectedSizeMatrixIndex
        && _initialSelectedStandartSizeIndex == _currentSelectedStandartSizeIndex;
}

- (void)setSelectedStandartSizeIndex:(NSInteger)aIndex
{
    _currentSelectedStandartSizeIndex = aIndex;
}

- (NSInteger)selectedStandartSizeIndex
{
    return _currentSelectedStandartSizeIndex;
}

- (void)setSelectedSizeMatrixIndex:(NSInteger)aIndex
{
    _currentSelectedSizeMatrixIndex = aIndex;
}

- (NSInteger)selectedSizeMatrixIndex
{
    return _currentSelectedSizeMatrixIndex;
}

- (void)setHyperCardSize:(NSSize)aSize
{
    (_currentCardSize).width = aSize.width;
    (_currentCardSize).height = aSize.height;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c9e96 @ 001c9e96, 14 bytes * /

ulonglong FUN_001c9e96(HSStackAssistantPaneApplier *self,SEL _cmd)

{
  ulonglong uVar1;
  
  uVar1._0_4_ = (self->_currentCardSize).width;
  uVar1._4_4_ = (self->_currentCardSize).height;
  return uVar1;
}

*/
- (NSSize)hyperCardSize
{
    return _currentCardSize;
}

- (void)makeCurrentEqualToInitial
{
    float fVar1;

    fVar1 = (_initialCardSize).height;
    (_currentCardSize).width = (_initialCardSize).width;
    (_currentCardSize).height = fVar1;
    _currentSelectedSizeMatrixIndex = _initialSelectedSizeMatrixIndex;
    _currentSelectedStandartSizeIndex = _initialSelectedStandartSizeIndex;
}

- (void)makeInitialEqualToCurrent
{
    float fVar1;

    fVar1 = (_currentCardSize).height;
    (_initialCardSize).width = (_currentCardSize).width;
    (_initialCardSize).height = fVar1;
    _initialSelectedSizeMatrixIndex = _currentSelectedSizeMatrixIndex;
    _initialSelectedStandartSizeIndex = _currentSelectedStandartSizeIndex;
}

- (void)setInitialSettingsToObject
{

}

- (void)setCurrentSettingsToObject
{

}

- (void)applyChanges
{
    [[self stackAttributes] setHyperCardSize:(_currentCardSize)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ca7e0 @ 001ca7e0, 120 bytes * /

id FUN_001ca7e0(HSStackAssistantPaneApplier *self,SEL _cmd,id initWithObject)

{
  id self_00;
  id pvVar1;
  undefined4 extraout_EDX;
  HSStackAssistantPaneApplier *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_HSAssistantPaneApplier_00353a80;
  self_00 = _objc_msgSendSuper(&local_14,sel_initWithObject_,initWithObject);
  if (self_00 != (id)0x0) {
    pvVar1 = _objc_msgSend(self_00,sel_stackAttributes);
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperCardSize);
    *(id *)((int)self_00 + 0x1c) = pvVar1;
    *(undefined4 *)((int)self_00 + 0x20) = extraout_EDX;
    *(id *)((int)self_00 + 0xc) = pvVar1;
    *(undefined4 *)((int)self_00 + 0x10) = extraout_EDX;
  }
  return self_00;
}

*/
- (id)initWithObject:(id)aObject
{
    self = [super initWithObject:aObject];
    if (self != nil) {
        _currentCardSize = [[self stackAttributes] hyperCardSize];
        _initialCardSize = _currentCardSize;
    }
    return self;
}

- (id)undoActionName
{
    return [[NSBundle mainBundle] localizedStringForKey:@"Change Card Size" value:@"" table:@"UndoManager"];
}

- (id)stackAttributes
{
    return [[self object] queryHyperInterface:@protocol(HSMutableStackAttributes)];
}

@end

