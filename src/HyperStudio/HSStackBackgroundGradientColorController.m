#import "HSStackBackgroundGradientColorController.h"
static id sDAT_003429f4;

static id sDAT_003429f4;


@implementation HSStackBackgroundGradientColorController

/* i386 ivar offsets: _controlledView=0x4, _gradientColor=0x8, _gradientsGridControl=0xc, _delegate=0x10, _applier=0x14, _didInitOnce=0x18, _shouldActivateColorWell=0x19 */

+ (id)gradientPresets
{
    if (sDAT_003429f4 == nil) {
        sDAT_003429f4 = [[NSArray alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"GradientMatrixPreset" ofType:@"plist"]];
    }
    return sDAT_003429f4;
}

- (void)selectionDidChangeInGridControl:(id)aControl
{
    [aControl selectedItemIndex];
    if ((int)[aControl selectedItemIndex] < (int)[self numberOfItemsInGridControl:aControl]) {
        [self synchronizeColorWellColorWithSelectedInGridControl:aControl];
    }
}

- (void)synchronizeColorWellColorWithSelectedInGridControl:(id)aControl
{
    id pvVar2;
    id pvVar2_3;
    id pvVar3_3;
    id pvVar3_5;
    double dVar5_3;
    HSPresentationAssistantPaneApplier *pHVar1_5;

    pvVar2 = [HSColor new];
    pvVar3_3 = [[[self class] gradientPresets] objectAtIndex:[aControl selectedItemIndex]];
    [pvVar2 setStartColor:[[pvVar3_3 objectForKey:@"StartColor"] extraColorValue]];
    [pvVar2 setEndColor:[[pvVar3_3 objectForKey:@"EndColor"] extraColorValue]];
    [pvVar2 setHyperKind:[[pvVar3_3 objectForKey:@"Kind"] intValue]];
    [pvVar2 setHyperAngle:(float)[[pvVar3_3 objectForKey:@"Angle"] floatValue]];
    pvVar3_5 = [HSGradientColor gradientColorWithHSColor:pvVar2];
    if ([_gradientColor color] != pvVar3_5) {
        [_gradientColor setColor:pvVar3_5];
    }
    pvVar2_3 = [pvVar3_5 hyperHSColor];
    if (pvVar2_3 != nil) {
        [_applier setFillType:2];
        [_applier setHyperClear:[pvVar2_3 isHyperClear]];
        [_applier setHyperKind:[pvVar2_3 hyperKind]];
        [_applier setHyperCacheEnabled:[pvVar2_3 isHyperCacheEnabled]];
        [_applier setHyperAngle:(float)[pvVar2_3 hyperAngle]];
        pHVar1_5 = _applier;
        dVar5_3 = [pvVar2_3 hyperCenterX];
        [pHVar1_5 setHyperCenterX:(float)[pvVar2_3 hyperCenterX] andY:(float)dVar5_3];
        [_applier setHyperStartColor:[pvVar2_3 hyperStartColor]];
        [_applier setHyperEndColor:[pvVar2_3 hyperEndColor]];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001f3e37 @ 001f3e37, 274 bytes * /

id FUN_001f3e37(HSStackBackgroundGradientColorController *self,SEL _cmd,id gridControl,
               int additionalInfoForItemAt)

{
  undefined4 uVar1;
  undefined *self_00;
  id pvVar2;
  cfstringStruct *pcVar3;
  cfstringStruct *pcVar4;
  
  pvVar2 = _objc_msgSend(self,sel_class);
  pvVar2 = _objc_msgSend(pvVar2,sel_gradientPresets);
  pvVar2 = _objc_msgSend(pvVar2,sel_objectAtIndex_,additionalInfoForItemAt);
  pcVar3 = _objc_msgSend(pvVar2,sel_objectForKey_,&cfstr_Name);
  self_00 = cls_NSDictionary;
  pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  uVar1 = *(undefined4 *)PTR_003365bc;
  if (pcVar3 == (cfstringStruct *)0x0) {
    pcVar3 = &cfstr_Gradient_color;
    pcVar4 = (cfstringStruct *)0x0;
  }
  else {
    pcVar4 = &cfstr_GradientMatrixPreset;
  }
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,pcVar3,&cfstr_empty,pcVar4);
  pvVar2 = _objc_msgSend(self_00,sel_dictionaryWithObject_forKey_,pvVar2,uVar1);
  return pvVar2;
}

*/
- (id)gridControl:(id)aControl additionalInfoForItemAt:(NSInteger)aAt
{
    NSString *name = [[[[self class] gradientPresets] objectAtIndex:aAt] objectForKey:@"Name"];
    NSString *localized = [[NSBundle mainBundle] localizedStringForKey:(name == nil ? @"Gradient color" : name) value:@"" table:(name == nil ? nil : @"GradientMatrixPreset")];
    return [NSDictionary dictionaryWithObject:localized forKey:SMKGridAttributeVoiceOverItemTypeKey];
    return 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001f4461 @ 001f4461, 1221 bytes * /

id FUN_001f4461(HSStackBackgroundGradientColorController *self,SEL _cmd,id gridControl,
               int imageForItemAt)

{
  id pvVar1;
  id self_00;
  id self_01;
  id pvVar2;
  double dVar3;
  undefined4 uVar4;
  float fVar5;
  float fVar6;
  id pvVar7;
  undefined4 uVar8;
  undefined4 local_44;
  undefined4 local_40;
  float local_3c;
  float local_38;
  id local_34;
  undefined4 local_30;
  undefined4 local_2c;
  float local_28;
  id local_24;
  undefined4 uStack_20;
  float local_1c;
  float fStack_18;
  
  local_24 = (id)0x0;
  uStack_20 = 0;
  local_1c = 31.0;
  fStack_18 = 15.0;
  pvVar1 = _objc_msgSend(cls_NSImage,sel_alloc);
  self_00 = _objc_msgSend(pvVar1,sel_initWithSize_,0x41f80000,0x41700000);
  _objc_msgSend(self_00,sel_lockFocus);
  pvVar1 = _objc_msgSend(cls_NSGraphicsContext,sel_currentContext);
  _objc_msgSend(pvVar1,sel_setShouldAntialias_,0);
  pvVar1 = _objc_msgSend(cls_NSColor,sel_colorWithDeviceRed_green_blue_alpha_,0x3f48c8c9,0x3f48c8c9,
                         0x3f48c8c9,0x3f800000);
  _objc_msgSend(pvVar1,sel_set);
  local_1c = local_1c + -1.0;
  fStack_18 = fStack_18 + -1.0;
  pvVar1 = _objc_msgSend(cls_NSBezierPath,sel_bezierPathWithRect_,local_24,uStack_20,local_1c,
                         fStack_18);
  _objc_msgSend(pvVar1,sel_setLineWidth_,0x3f800000);
  _objc_msgSend(pvVar1,sel_stroke);
  pvVar1 = _objc_msgSend(cls_NSColor,sel_whiteColor);
  _objc_msgSend(pvVar1,sel_set);
  uVar8 = 0x3f800000;
  _NSInsetRect(&local_34,local_24,uStack_20,local_1c,fStack_18,0x3f800000,0x3f800000);
  local_24 = local_34;
  uStack_20 = local_30;
  local_1c = (float)local_2c;
  fStack_18 = local_28;
  pvVar1 = _objc_msgSend(cls_NSBezierPath,sel_bezierPathWithRect_,local_34,local_30,local_2c,
                         local_28);
  _objc_msgSend(pvVar1,sel_setLineWidth_,0x3f800000);
  _objc_msgSend(pvVar1,sel_stroke);
  pvVar7 = (id)0x3f800000;
  fVar6 = 1.0;
  pvVar1 = local_24;
  pvVar2 = (id)uStack_20;
  _NSInsetRect(&local_44,local_24,uStack_20,local_1c,fStack_18,0x3f800000,0x3f800000);
  local_24 = (id)local_44;
  uStack_20 = local_40;
  uVar4 = local_1c;
  fVar5 = fStack_18;
  local_1c = local_3c + 1.0;
  fStack_18 = local_38 + 1.0;
  if (self->_gradientsGridControl == gridControl) {
    self_01 = _objc_msgSend(cls_HSColor,sel_new);
    pvVar1 = _objc_msgSend(self,sel_class);
    pvVar1 = _objc_msgSend(pvVar1,sel_gradientPresets);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,imageForItemAt);
    pvVar2 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_StartColor);
    pvVar2 = _objc_msgSend(pvVar2,sel_extraColorValue);
    _objc_msgSend(self_01,sel_setStartColor_,pvVar2);
    pvVar2 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_EndColor);
    pvVar2 = _objc_msgSend(pvVar2,sel_extraColorValue);
    _objc_msgSend(self_01,sel_setEndColor_,pvVar2);
    pvVar2 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_Kind);
    pvVar2 = _objc_msgSend(pvVar2,sel_intValue);
    _objc_msgSend(self_01,sel_setHyperKind_,pvVar2);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_Angle);
    dVar3 = _objc_msgSend_fpret(pvVar1,sel_floatValue);
    _objc_msgSend(self_01,sel_setHyperAngle_,(float)dVar3);
    pvVar1 = _objc_msgSend(cls_NSGraphicsContext,sel_currentContext);
    pvVar2 = local_24;
    uVar4 = uStack_20;
    fVar5 = local_1c;
    fVar6 = fStack_18;
    pvVar7 = local_24;
    uVar8 = uStack_20;
    _objc_msgSend(self_01,sel_drawGradientInCocoaContext_rect_ofBounds_,pvVar1,local_24,uStack_20,
                  local_1c,fStack_18,local_24,uStack_20,CONCAT44(fStack_18,local_1c));
    _objc_msgSend(self_01,sel_release);
  }
  _objc_msgSend(self_00,sel_unlockFocus,pvVar1,pvVar2,uVar4,fVar5,fVar6,pvVar7,uVar8);
  pvVar1 = _objc_msgSend(self_00,sel_autorelease);
  return pvVar1;
}

*/
- (id)gridControl:(id)aControl imageForItemAt:(NSInteger)aAt
{
    NSRect rect = NSMakeRect(0.0, 0.0, 31.0, 15.0);
    NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(31.0, 15.0)];
    [image lockFocus];
    [[NSGraphicsContext currentContext] setShouldAntialias:NO];
    [[NSColor colorWithDeviceRed:0.78431374 green:0.78431374 blue:0.78431374 alpha:1.0] set];
    rect.size.width -= 1.0;
    rect.size.height -= 1.0;
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:rect];
    [path setLineWidth:1.0];
    [path stroke];
    [[NSColor whiteColor] set];
    rect = NSInsetRect(rect, 1.0, 1.0);
    path = [NSBezierPath bezierPathWithRect:rect];
    [path setLineWidth:1.0];
    [path stroke];
    rect = NSInsetRect(rect, 1.0, 1.0);
    rect.size.width += 1.0;
    rect.size.height += 1.0;
    if (_gradientsGridControl == aControl) {
        HSColor *color = [HSColor new];
        NSDictionary *preset = [[[self class] gradientPresets] objectAtIndex:aAt];
        [color setStartColor:[[preset objectForKey:@"StartColor"] extraColorValue]];
        [color setEndColor:[[preset objectForKey:@"EndColor"] extraColorValue]];
        [color setHyperKind:[[preset objectForKey:@"Kind"] intValue]];
        [color setHyperAngle:[[preset objectForKey:@"Angle"] floatValue]];
        [color drawGradientInCocoaContext:[NSGraphicsContext currentContext] rect:rect ofBounds:rect];
        [color release];
    }
    [image unlockFocus];
    return [image autorelease];
    return 0;
}

- (id)gridControl:(id)aControl titleForItemAt:(NSInteger)aAt
{
    return nil;
}

- (NSInteger)numberOfItemsInGridControl:(id)aControl
{
    NSUInteger pvVar1_3;

    if (_gradientsGridControl == aControl) {
        pvVar1_3 = [[[self class] gradientPresets] count];
        if (0xc < (int)pvVar1_3) {
            pvVar1_3 = 0xc;
        }
    }
    else {
        pvVar1_3 = 0;
    }
    return (int)pvVar1_3;
}

- (Class)cellClass
{
    return [SMKGridBaseCell class];
}

- (void)gradientColorChanged:(id)aChanged
{
    id pvVar2_3;
    HSPresentationAssistantPaneApplier *pHVar1_6;
    double dVar4_2;

    pvVar2_3 = [[[aChanged color] hyperGradientColor] hyperHSColor];
    if (pvVar2_3 == nil) {
        [_applier setFillType:1];
        [_applier setHyperSolidColor:[aChanged color]];
        [[self delegate] validateFillTypeController];
    }
    else {
        [_applier setFillType:2];
        [_applier setHyperClear:[pvVar2_3 isHyperClear]];
        [_applier setHyperKind:[pvVar2_3 hyperKind]];
        [_applier setHyperCacheEnabled:[pvVar2_3 isHyperCacheEnabled]];
        [_applier setHyperAngle:(float)[pvVar2_3 hyperAngle]];
        pHVar1_6 = _applier;
        dVar4_2 = [pvVar2_3 hyperCenterX];
        [pHVar1_6 setHyperCenterX:(float)[pvVar2_3 hyperCenterX] andY:(float)dVar4_2];
        [_applier setHyperStartColor:[pvVar2_3 hyperStartColor]];
        [_applier setHyperEndColor:[pvVar2_3 hyperEndColor]];
    }
    [_gradientsGridControl selectItemAtIndex:0xffffffff byExtendingSelection:NO];
}

- (id)defaultGradientColor
{
    id pvVar1_3;
    id pvVar2_2;

    pvVar1_3 = [[[self class] gradientPresets] objectAtIndex:0];
    pvVar2_2 = [[pvVar1_3 objectForKey:@"EndColor"] extraColorValue];
    return [HSGradientColor gradientColorWithStartColor:[[pvVar1_3 objectForKey:@"StartColor"] extraColorValue] endColor:pvVar2_2];
}

- (void)setupLinearGradientControl
{
    [_gradientsGridControl setMode:0];
    [_gradientsGridControl setScrollerControlSize:1];
    [_gradientsGridControl setSelectionStyle:3];
    [_gradientsGridControl setThreadedPreloadingEnabled:NO];
    [_gradientsGridControl setAllowsMultipleSelection:NO];
    [_gradientsGridControl setThumbnailCachingEnabled:NO];
    [_gradientsGridControl setThumbnailHyphenationEnabled:YES];
    [_gradientsGridControl setGraphicContentShadowEnabled:NO];
    [_gradientsGridControl setExtraPasteboardDataProvidingAllowed:NO];
    [_gradientsGridControl setDataSource:self];
    [_gradientsGridControl setDelegate:self];
    [_gradientsGridControl setTarget:self];
    [_gradientsGridControl setThumbnailSize:NSMakeSize(31.0, 15.0) andBorderOffset:NSMakeSize(0.5, 0.5)];
    [[_gradientsGridControl scrollView] setHasVerticalScroller:NO];
    [[_gradientsGridControl scrollView] setHasHorizontalScroller:NO];
    [[_gradientsGridControl scrollView] setBorderType:0];
    [[_gradientsGridControl gridMatrix] setAcceptsFirstMouse:YES];
    [[_gradientsGridControl gridMatrix] setNeedsPanelToBecomeKey:NO];
    [[_gradientsGridControl gridMatrix] setAllowsEmptySelection:YES];
}

- (void)setShouldActivateColorWellOnMount:(BOOL)aMount
{
    _shouldActivateColorWell = aMount;
}

- (BOOL)deactivatedColorWellOnUnmount
{
    BOOL pvVar1;

    pvVar1 = [_gradientColor isActive];
    if (pvVar1) {
        [_gradientColor deactivate];
    }
    return pvVar1;
}

- (void)setDelegate:(id)aDelegate
{
    if (_delegate != aDelegate) {
        _delegate = aDelegate;
    }
}

- (id)delegate
{
    return _delegate;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001f4b97 @ 001f4b97, 911 bytes * /

void FUN_001f4b97(HSStackBackgroundGradientColorController *self,SEL _cmd)

{
  float fVar1;
  id pvVar2;
  id self_00;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  double dVar8;
  SEL op;
  float fVar9;
  id local_18;
  
  _objc_msgSend(self->_gradientsGridControl,sel_reloadData);
  pvVar2 = _objc_msgSend(self->_applier,sel_hyperStartColor);
  self_00 = _objc_msgSend(self->_applier,sel_hyperEndColor);
  pvVar3 = _objc_msgSend(self->_applier,sel_hyperKind);
  dVar8 = _objc_msgSend_fpret(self->_applier,sel_hyperAngle);
  fVar1 = (float)dVar8;
  if ((pvVar2 == (id)0x0) || (self_00 == (id)0x0)) {
    pvVar7 = (id)0x0;
  }
  else {
    pvVar7 = _objc_msgSend(cls_HSGradientColor,sel_gradientColorWithStartColor_endColor_,pvVar2,
                           self_00);
  }
  pvVar4 = _objc_msgSend(pvVar7,sel_hyperHSColor);
  _objc_msgSend(pvVar4,sel_setHyperKind_,pvVar3);
  pvVar4 = _objc_msgSend(pvVar7,sel_hyperHSColor);
  fVar9 = fVar1;
  _objc_msgSend(pvVar4,sel_setHyperAngle_,fVar1);
  if (self->_shouldActivateColorWell != '\0') {
    fVar9 = 0.0;
    _objc_msgSend(self->_gradientColor,sel_activate_,0);
  }
  pvVar4 = self->_gradientColor;
  if (pvVar7 == (id)0x0) {
    local_18 = _objc_msgSend(self,sel_defaultGradientColor,fVar9);
    op = sel_setColor_;
  }
  else {
    _objc_msgSend(pvVar4,sel_setColor_,pvVar7);
    pvVar7 = _objc_msgSend(self,sel_class);
    pvVar7 = _objc_msgSend(pvVar7,sel_gradientPresets);
    local_18 = (id)0x0;
    pvVar4 = _objc_msgSend(self,sel_numberOfItemsInGridControl_,self->_gradientsGridControl);
    for (; local_18 < pvVar4; local_18 = (id)((int)local_18 + 1)) {
      pvVar5 = _objc_msgSend(pvVar7,sel_objectAtIndex_,local_18);
      pvVar5 = _objc_msgSend(pvVar5,sel_objectForKey_,&cfstr_StartColor);
      pvVar5 = _objc_msgSend(pvVar5,sel_extraColorValue);
      pvVar6 = _objc_msgSend(pvVar7,sel_objectAtIndex_,local_18);
      pvVar6 = _objc_msgSend(pvVar6,sel_objectForKey_,&cfstr_EndColor);
      pvVar6 = _objc_msgSend(pvVar6,sel_extraColorValue);
      pvVar5 = _objc_msgSend(pvVar2,sel_isEqualTo_,pvVar5);
      if ((char)pvVar5 != '\0') {
        pvVar5 = _objc_msgSend(self_00,sel_isEqualTo_,pvVar6);
        if ((char)pvVar5 != '\0') {
          pvVar2 = _objc_msgSend(pvVar7,sel_objectAtIndex_,local_18);
          pvVar2 = _objc_msgSend(pvVar2,sel_objectForKey_,&cfstr_Kind);
          pvVar2 = _objc_msgSend(pvVar2,sel_unsignedIntValue);
          if (((pvVar3 == pvVar2) && (fVar1 == 0.0)) && (!NAN(fVar1))) {
            pvVar4 = self->_gradientsGridControl;
            op = sel_selectItemAtIndex_byExtendingSelection_;
            goto LAB_001f4ef1;
          }
          break;
        }
      }
    }
    pvVar4 = self->_gradientsGridControl;
    local_18 = (id)0xffffffff;
    op = sel_selectItemAtIndex_byExtendingSelection_;
  }
LAB_001f4ef1:
  _objc_msgSend(pvVar4,op,local_18);
  return;
}

*/
- (void)validateUIElements
{
    [_gradientsGridControl reloadData];
    id startColor = [_applier hyperStartColor];
    id endColor = [_applier hyperEndColor];
    NSInteger kind = [_applier hyperKind];
    float angle = [_applier hyperAngle];
    id gradient = nil;
    if (startColor != nil && endColor != nil) {
        gradient = [HSGradientColor gradientColorWithStartColor:startColor endColor:endColor];
    }
    [[gradient hyperHSColor] setHyperKind:kind];
    [[gradient hyperHSColor] setHyperAngle:angle];
    if (_shouldActivateColorWell) {
        [_gradientColor activate:NO];
    }
    if (gradient == nil) {
        [_gradientColor setColor:[self defaultGradientColor]];
        return;
    }
    [_gradientColor setColor:gradient];
    NSArray *presets = [[self class] gradientPresets];
    NSInteger selectedIndex = -1;
    NSUInteger count = [self numberOfItemsInGridControl:_gradientsGridControl];
    for (NSUInteger index = 0; index < count; index++) {
        id presetStart = [[[presets objectAtIndex:index] objectForKey:@"StartColor"] extraColorValue];
        id presetEnd = [[[presets objectAtIndex:index] objectForKey:@"EndColor"] extraColorValue];
        if ([startColor isEqualTo:presetStart] && [endColor isEqualTo:presetEnd]) {
            NSUInteger presetKind = [[[presets objectAtIndex:index] objectForKey:@"Kind"] unsignedIntValue];
            if ((NSUInteger)kind == presetKind && angle == 0.0f) {
                selectedIndex = index;
            }
            break;
        }
    }
    [_gradientsGridControl selectItemAtIndex:selectedIndex byExtendingSelection:NO];
}

- (void)apply
{
    if (_didInitOnce == NO) {
        [_gradientColor setGradientSupportEnabled:YES];
        [_gradientColor setPatternSupportEnabled:YES];
        [self setupLinearGradientControl];
        _didInitOnce = YES;
        [self validateUIElements];
    }
}

- (id)contentView
{
    return _controlledView;
}

- (void)setApplier:(id)aApplier
{
    if (_applier != aApplier) {
        _applier = aApplier;
    }
}

- (void)dealloc
{
    [_gradientColor deactivate];
    [_controlledView release];
    [super dealloc];
}

@end

