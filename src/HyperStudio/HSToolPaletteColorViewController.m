#import "HSToolPaletteColorViewController.h"
static id sDAT_0034296c;
static id sDAT_00342970;
static id sDAT_00342974;
static id sDAT_00342978;

static id sDAT_0034296c;
static id sDAT_00342970;
static id sDAT_00342974;


@implementation HSToolPaletteColorViewController

/* i386 ivar offsets: _colorView=0x4, _containerView=0x8, _previewView=0xc, _delegate=0x10, _crayonsColorWell=0x14, _gradientsColorWell=0x18, _texturesColorWell=0x1c, _tabView=0x20, _crayonsView=0x24, _crayonsContainerView=0x28, _gradientsView=0x2c, _texturesView=0x30, _crayonsPreview=0x34, _gradientPreview=0x38, _texturePreview=0x3c, _gradientsGridControl=0x40, _texturesGridControl=0x44, _colorPickingActivateButton=0x48, _eraserColorView=0x4c, _eraserButton=0x50, _eraserPreviewView=0x54, _eraserContainerView=0x58, _eraserSuperContainerView=0x5c, _workColorWell=0x60, _toolPaletteColorViewControllerFlags=0x64, _color=0x68, _isInLiveChanging=0x6c */

/* --- i386 decompilation (Ghidra) ---
/* FUN_0014ef5d @ 0014ef5d, 707 bytes * /

void FUN_0014ef5d(HSToolPaletteColorViewController *self,SEL _cmd,
                 id selectedTabDidChangeInCustomTabView)

{
  HSColorWell *pHVar1;
  HSColorWell *self_00;
  id pvVar2;
  id pvVar3;
  HSColorWell *pHVar4;
  undefined4 *puVar5;
  double dVar6;
  undefined1 local_44 [16];
  undefined1 local_34 [16];
  undefined1 local_24 [20];
  
  puVar5 = (undefined4 *)&stack0xffffff84;
  pvVar2 = _objc_msgSend(self->_previewView,sel_subviews);
  pvVar2 = _objc_msgSend(pvVar2,sel_objectAtIndex_);
  _objc_msgSend(pvVar2,sel_removeFromSuperviewWithoutNeedingDisplay);
  pvVar2 = _objc_msgSend(self->_workColorWell,sel_isActive);
  pHVar1 = self->_texturesColorWell;
  self_00 = self->_workColorWell;
  pvVar3 = _objc_msgSend(self_00,sel_color);
  dVar6 = _objc_msgSend_fpret(pvVar3,sel_alphaComponent);
  pvVar3 = _objc_msgSend(selectedTabDidChangeInCustomTabView,sel_indexOfSelectedTab);
  if (pvVar3 == (id)0x2) {
    pvVar3 = self->_texturePreview;
    _objc_msgSend_stret(local_24,self->_previewView,sel_bounds);
    _objc_msgSend(pvVar3,sel_setFrame_);
    _objc_msgSend(self->_previewView,sel_addSubview_);
    pHVar4 = self->_texturesColorWell;
  }
  else if (pvVar3 == (id)0x1) {
    pvVar3 = self->_gradientPreview;
    _objc_msgSend_stret(local_34,self->_previewView,sel_bounds);
    _objc_msgSend(pvVar3,sel_setFrame_);
    _objc_msgSend(self->_previewView,sel_addSubview_);
    pHVar4 = self->_gradientsColorWell;
  }
  else {
    if (pvVar3 != (id)0x0) goto LAB_0014f175;
    pvVar3 = self->_crayonsPreview;
    _objc_msgSend_stret(local_44,self->_previewView,sel_bounds);
    _objc_msgSend(pvVar3,sel_setFrame_);
    _objc_msgSend(self->_previewView,sel_addSubview_);
    pHVar4 = self->_crayonsColorWell;
  }
  puVar5 = (undefined4 *)&stack0xffffff80;
  self->_workColorWell = pHVar4;
LAB_0014f175:
  if ((char)pvVar2 != '\0') {
    pHVar4 = self->_workColorWell;
    puVar5[1] = sel_activate_;
    *puVar5 = pHVar4;
    puVar5[2] = 1;
    puVar5[-1] = 0x14f198;
    _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
  }
  if (self_00 == pHVar1) {
    pHVar1 = self->_workColorWell;
    puVar5[1] = sel_color;
    *puVar5 = pHVar1;
  }
  else {
    pHVar1 = self->_workColorWell;
    puVar5[1] = sel_color;
    *puVar5 = pHVar1;
    puVar5[-1] = 0x14f1b5;
    pvVar2 = _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
    puVar5[3] = (float)dVar6;
    puVar5[2] = pvVar2;
    puVar5[1] = sel_newColorFromColor_withAlphaComponent_;
    *puVar5 = self;
  }
  puVar5[-1] = 0x14f1e8;
  pvVar2 = _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
  puVar5[1] = sel_delegate;
  *puVar5 = self;
  puVar5[-1] = 0x14f1fe;
  pvVar3 = _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
  puVar5[3] = pvVar2;
  puVar5[2] = self;
  puVar5[1] = sel_colorViewController_changedColorTo_;
  *puVar5 = pvVar3;
  puVar5[-1] = 0x14f218;
  _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
  return;
}

*/
- (void)selectedTabDidChangeInCustomTabView:(id)aView
{
    BOOL wasActive;
    HSGradientColorWell *previousWell;
    float alpha;
    id color;
    [[[_previewView subviews] objectAtIndex:0] removeFromSuperviewWithoutNeedingDisplay];
    wasActive = [_workColorWell isActive];
    previousWell = (HSGradientColorWell *)_workColorWell;
    alpha = (float)[[previousWell color] alphaComponent];
    switch ([aView indexOfSelectedTab]) {
    case 2:
        [_texturePreview setFrame:[_previewView bounds]];
        [_previewView addSubview:_texturePreview];
        _workColorWell = _texturesColorWell;
        break;
    case 1:
        [_gradientPreview setFrame:[_previewView bounds]];
        [_previewView addSubview:_gradientPreview];
        _workColorWell = _gradientsColorWell;
        break;
    case 0:
        [_crayonsPreview setFrame:[_previewView bounds]];
        [_previewView addSubview:_crayonsPreview];
        _workColorWell = _crayonsColorWell;
        break;
    default:
        break;
    }
    if (wasActive) {
        [_workColorWell activate:YES];
    }
    if (previousWell == _texturesColorWell) {
        color = [_workColorWell color];
    }
    else {
        color = [_workColorWell color];
    }
    [[self delegate] colorViewController:self changedColorTo:color];
}

- (void)selectionDidChangeInGridControl:(id)aControl
{
    id pvVar2;
    double dVar3;

    _isInLiveChanging = YES;
    dVar3 = [[_workColorWell color] alphaComponent];
    [self synchronizeColorWellColorWithSelectedInGridControl:aControl];
    pvVar2 = [self newColorFromColor:[_workColorWell color] withAlphaComponent:((float)dVar3)];
    if ((_gradientsColorWell == _workColorWell) || (_texturesColorWell == _workColorWell)) {
        [[self delegate] colorViewController:self changedColorTo:pvVar2];
    }
    _isInLiveChanging = NO;
}

- (void)synchronizeColorWellColorWithSelectedInGridControl:(id)aControl
{
    id pvVar1;
    NSUInteger pvVar2;
    NSUInteger pvVar3;
    id pvVar1_4;
    id pvVar1_5;
    NSUInteger pvVar1_6;
    id pvVar1_7;
    id pvVar2_2;
    id pvVar2_7;
    NSUInteger pvVar2_10;

    if (_gradientsGridControl == aControl) {
        pvVar1 = [HSToolPaletteColorViewController gradientPresets];
        pvVar2 = [aControl selectedItemIndex]
        ;
        pvVar1_4 = [[[pvVar1 objectAtIndex:pvVar2] objectForKey:@"StartColor"] extraColorValue];
        pvVar2_2 = [HSToolPaletteColorViewController gradientPresets];
        pvVar3 = [aControl selectedItemIndex]
        ;
        pvVar1_5 = [HSGradientColor gradientColorWithStartColor:pvVar1_4 endColor:[[[pvVar2_2 objectAtIndex:pvVar3] objectForKey:@"EndColor"] extraColorValue]];
        if ([_gradientsColorWell color] == pvVar1_5) {
            return;
        }
        pvVar2_7 = _gradientsColorWell;
    }
    else {
        [aControl selectedItemIndex];
        pvVar1_6 = [aControl selectedItemIndex]
        ;
        if ([[HSToolPaletteColorViewController texturePresets] count] <= pvVar1_6) {
            return;
        }
        pvVar1_7 = [HSToolPaletteColorViewController texturePresets];
        pvVar2_10 = [aControl selectedItemIndex]
        ;
        pvVar1_5 = [NSColor colorWithPatternImage:[[pvVar1_7 objectAtIndex:pvVar2_10] objectForKey:@"Image"]];
        if ([_texturesColorWell color] == pvVar1_5) {
            return;
        }
        pvVar2_7 = _texturesColorWell;
    }
    [pvVar2_7 setColor:pvVar1_5];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0014f2f2 @ 0014f2f2, 1415 bytes * /

id FUN_0014f2f2(HSToolPaletteColorViewController *self,SEL _cmd,id gridControl,int imageForItemAt)

{
  float fVar1;
  float fVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  cfstringStruct *pcVar6;
  cfstringStruct *pcVar7;
  uint uVar8;
  cfstringStruct *extraout_EDX;
  SEL op;
  cfstringStruct *pcVar9;
  cfstringStruct *pcVar10;
  cfstringStruct *pcVar11;
  cfstringStruct *pcVar12;
  cfstringStruct *pcVar13;
  cfstringStruct *local_4c;
  cfstringStruct *pcStack_48;
  cfstringStruct *local_44;
  cfstringStruct *local_40;
  float local_3c;
  float local_38;
  undefined4 local_34;
  cfstringStruct *local_30;
  cfstringStruct *local_2c;
  cfstringStruct *local_28;
  cfstringStruct *local_24;
  cfstringStruct *pcStack_20;
  cfstringStruct *local_1c;
  cfstringStruct *pcStack_18;
  
  uVar8 = (uint)(self->_gradientsGridControl != gridControl);
  fVar1 = (float)(&DAT_003354e8)[uVar8 * 2];
  local_24 = (cfstringStruct *)0x0;
  pcStack_20 = (cfstringStruct *)0x0;
  fVar2 = (float)(&DAT_003354ec)[uVar8 * 2];
  local_1c = (cfstringStruct *)fVar1;
  pcStack_18 = (cfstringStruct *)fVar2;
  pvVar3 = _objc_msgSend(cls_NSImage,sel_alloc);
  pvVar3 = _objc_msgSend(pvVar3,sel_initWithSize_,fVar1,fVar2);
  _objc_msgSend(pvVar3,sel_lockFocus);
  pvVar4 = _objc_msgSend(cls_NSGraphicsContext,sel_currentContext);
  _objc_msgSend(pvVar4,sel_setShouldAntialias_,0);
  pvVar4 = _objc_msgSend(cls_NSColor,sel_colorWithDeviceRed_green_blue_alpha_,0x3f48c8c9,0x3f48c8c9,
                         0x3f48c8c9,0x3f800000);
  _objc_msgSend(pvVar4,sel_set);
  local_1c = (cfstringStruct *)((float)local_1c + -1.0);
  pcStack_18 = (cfstringStruct *)((float)pcStack_18 + -1.0);
  pvVar4 = _objc_msgSend(cls_NSBezierPath,sel_bezierPathWithRect_,local_24,pcStack_20,local_1c,
                         pcStack_18);
  _objc_msgSend(pvVar4,sel_setLineWidth_,0x3f800000);
  _objc_msgSend(pvVar4,sel_stroke);
  pvVar4 = _objc_msgSend(cls_NSColor,sel_whiteColor);
  _objc_msgSend(pvVar4,sel_set);
  local_4c = (cfstringStruct *)0x3f800000;
  _NSInsetRect(&local_34,local_24,pcStack_20,local_1c,pcStack_18,0x3f800000,0x3f800000);
  local_24 = (cfstringStruct *)local_34;
  pcStack_20 = local_30;
  local_1c = local_2c;
  pcStack_18 = local_28;
  pvVar4 = _objc_msgSend(cls_NSBezierPath,sel_bezierPathWithRect_,local_34,local_30,local_2c,
                         local_28);
  _objc_msgSend(pvVar4,sel_setLineWidth_,0x3f800000);
  _objc_msgSend(pvVar4,sel_stroke);
  pcVar12 = (cfstringStruct *)0x3f800000;
  pcVar11 = (cfstringStruct *)0x3f800000;
  pcVar7 = pcStack_20;
  _NSInsetRect(&local_44,local_24,pcStack_20,local_1c,pcStack_18,0x3f800000,0x3f800000);
  local_24 = local_44;
  pcStack_20 = local_40;
  if (self->_gradientsGridControl == gridControl) {
    local_1c = (cfstringStruct *)(local_3c + 1.0);
    pcStack_18 = (cfstringStruct *)(local_38 + 1.0);
    pvVar4 = _objc_msgSend(cls_HSColor,sel_new);
    pvVar5 = _objc_msgSend(cls_HSToolPaletteColorViewController,sel_gradientPresets);
    pvVar5 = _objc_msgSend(pvVar5,sel_objectAtIndex_,imageForItemAt);
    pvVar5 = _objc_msgSend(pvVar5,sel_objectForKey_,&cfstr_StartColor);
    pvVar5 = _objc_msgSend(pvVar5,sel_extraColorValue);
    _objc_msgSend(pvVar4,sel_setStartColor_,pvVar5);
    pvVar5 = _objc_msgSend(cls_HSToolPaletteColorViewController,sel_gradientPresets);
    pvVar5 = _objc_msgSend(pvVar5,sel_objectAtIndex_,imageForItemAt);
    pvVar5 = _objc_msgSend(pvVar5,sel_objectForKey_,&cfstr_EndColor);
    pvVar5 = _objc_msgSend(pvVar5,sel_extraColorValue);
    _objc_msgSend(pvVar4,sel_setEndColor_,pvVar5);
    pcVar6 = _objc_msgSend(cls_NSGraphicsContext,sel_currentContext);
    pcVar7 = local_24;
    pcVar9 = pcStack_20;
    pcVar10 = local_1c;
    pcVar11 = pcStack_18;
    pcVar12 = local_24;
    local_4c = pcStack_20;
    pcStack_48 = local_1c;
    pcVar13 = pcStack_18;
    _objc_msgSend(pvVar4,sel_drawGradientInCocoaContext_rect_ofBounds_,pcVar6,local_24,pcStack_20,
                  local_1c,pcStack_18,local_24,pcStack_20,local_1c,pcStack_18);
    op = sel_release;
  }
  else {
    pcVar9 = local_1c;
    pcVar10 = pcStack_18;
    local_1c = (cfstringStruct *)(local_3c + 1.0);
    pcStack_18 = (cfstringStruct *)(local_38 + 1.0);
    pvVar4 = _objc_msgSend(cls_HSToolPaletteColorViewController,sel_texturePresets);
    pvVar4 = _objc_msgSend(pvVar4,sel_objectAtIndex_,imageForItemAt);
    pcVar6 = &cfstr_Image;
    pvVar4 = _objc_msgSend(pvVar4,sel_objectForKey_,&cfstr_Image);
    if (pvVar4 == (id)0x0) goto LAB_0014f84a;
    pcVar7 = _objc_msgSend(pvVar4,sel_size,pcVar6);
    pcStack_48 = (cfstringStruct *)((float)pcStack_18 + (float)pcStack_18);
    local_4c = (cfstringStruct *)((float)local_1c + (float)local_1c);
    if ((float)pcVar7 < (float)local_1c + (float)local_1c) {
      local_4c = pcVar7;
    }
    if ((float)extraout_EDX < (float)pcStack_48) {
      pcStack_48 = extraout_EDX;
    }
    pcVar11 = (cfstringStruct *)0x0;
    pcVar12 = (cfstringStruct *)0x0;
    pcVar13 = (cfstringStruct *)0x1;
    op = sel_drawInRect_fromRect_operation_fraction_;
    pcVar6 = local_24;
    pcVar7 = pcStack_20;
    pcVar9 = local_1c;
    pcVar10 = pcStack_18;
  }
  _objc_msgSend(pvVar4,op,pcVar6,pcVar7,pcVar9,pcVar10,pcVar11,pcVar12,local_4c,pcStack_48,pcVar13);
LAB_0014f84a:
  _objc_msgSend(pvVar3,sel_unlockFocus,pcVar6,pcVar7,pcVar9,pcVar10,pcVar11,pcVar12,local_4c);
  pvVar3 = _objc_msgSend(pvVar3,sel_autorelease);
  return pvVar3;
}

*/
- (id)gridControl:(id)aControl imageForItemAt:(NSInteger)aAt
{
    BOOL isGradients = _gradientsGridControl == aControl;
    NSSize size = isGradients ? NSMakeSize(31.0, 15.0) : NSMakeSize(29.0, 20.0);
    NSRect rect = NSMakeRect(0.0, 0.0, size.width, size.height);
    NSImage *image = [[NSImage alloc] initWithSize:size];
    NSBezierPath *path;
    HSColor *gradient;
    NSImage *texture;
    NSSize textureSize;
    NSRect fromRect;
    [image lockFocus];
    [[NSGraphicsContext currentContext] setShouldAntialias:NO];
    [[NSColor colorWithDeviceRed:0.784 green:0.784 blue:0.784 alpha:1.0] set];
    rect.size.width = rect.size.width - 1.0;
    rect.size.height = rect.size.height - 1.0;
    path = [NSBezierPath bezierPathWithRect:rect];
    [path setLineWidth:1.0];
    [path stroke];
    [[NSColor whiteColor] set];
    rect = NSInsetRect(rect, 1.0, 1.0);
    path = [NSBezierPath bezierPathWithRect:rect];
    [path setLineWidth:1.0];
    [path stroke];
    rect = NSInsetRect(rect, 1.0, 1.0);
    rect.size.width = rect.size.width + 1.0;
    rect.size.height = rect.size.height + 1.0;
    if (isGradients) {
        gradient = [HSColor new];
        [gradient setStartColor:[[[[HSToolPaletteColorViewController gradientPresets] objectAtIndex:aAt] objectForKey:@"StartColor"] extraColorValue]];
        [gradient setEndColor:[[[[HSToolPaletteColorViewController gradientPresets] objectAtIndex:aAt] objectForKey:@"EndColor"] extraColorValue]];
        [gradient drawGradientInCocoaContext:[NSGraphicsContext currentContext] rect:rect ofBounds:rect];
        [gradient release];
    }
    else {
        texture = [[[HSToolPaletteColorViewController texturePresets] objectAtIndex:aAt] objectForKey:@"Image"];
        if (texture != nil) {
            textureSize = [texture size];
            fromRect = NSMakeRect(0.0, 0.0, MIN(textureSize.width, rect.size.width + rect.size.width), MIN(textureSize.height, rect.size.height + rect.size.height));
            [texture drawInRect:rect fromRect:fromRect operation:NSCompositingOperationCopy fraction:1.0];
        }
    }
    [image unlockFocus];
    return [image autorelease];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0014dcf8 @ 0014dcf8, 497 bytes * /

id FUN_0014dcf8(HSToolPaletteColorViewController *self,SEL _cmd,id gridControl,
               int additionalInfoForItemAt)

{
  id pvVar1;
  cfstringStruct *pcVar2;
  undefined4 uVar3;
  cfstringStruct *pcVar4;
  undefined *local_10;
  
  if (self->_gradientsGridControl == gridControl) {
    pvVar1 = _objc_msgSend(cls_HSToolPaletteColorViewController,sel_gradientPresets);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,additionalInfoForItemAt);
    pcVar2 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_Name);
    local_10 = cls_NSDictionary;
    pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    uVar3 = *(undefined4 *)PTR_003365bc;
    if (pcVar2 == (cfstringStruct *)0x0) {
      pcVar2 = &cfstr_Gradient_color;
      pcVar4 = (cfstringStruct *)0x0;
    }
    else {
      pcVar4 = &cfstr_ColorViewPresets;
    }
    pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,pcVar2,&cfstr_empty,pcVar4)
    ;
  }
  else {
    pvVar1 = _objc_msgSend(cls_HSToolPaletteColorViewController,sel_texturePresets);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,additionalInfoForItemAt);
    pcVar2 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_Name);
    local_10 = cls_NSDictionary;
    pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    uVar3 = *(undefined4 *)PTR_003365bc;
    if (pcVar2 == (cfstringStruct *)0x0) {
      pcVar2 = &cfstr_Texture_color;
      pcVar4 = (cfstringStruct *)0x0;
    }
    else {
      pcVar4 = &cfstr_ColorViewPresets;
    }
    pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,pcVar2,&cfstr_empty,pcVar4)
    ;
  }
  pvVar1 = _objc_msgSend(local_10,sel_dictionaryWithObject_forKey_,pvVar1,uVar3,pcVar4);
  return pvVar1;
}

*/
- (id)gridControl:(id)aControl additionalInfoForItemAt:(NSInteger)aAt
{
    id name;
    NSString *table;
    if (_gradientsGridControl == aControl) {
        name = [[[HSToolPaletteColorViewController gradientPresets] objectAtIndex:aAt] objectForKey:@"Name"];
        if (name == nil) {
            name = @"Gradient color";
            table = nil;
        }
        else {
            table = @"ColorViewPresets";
        }
    }
    else {
        name = [[[HSToolPaletteColorViewController texturePresets] objectAtIndex:aAt] objectForKey:@"Name"];
        if (name == nil) {
            name = @"Texture color";
            table = nil;
        }
        else {
            table = @"ColorViewPresets";
        }
    }
    return [NSDictionary dictionaryWithObject:[[NSBundle mainBundle] localizedStringForKey:name value:@"" table:table] forKey:SMKGridAttributeVoiceOverItemTypeKey];
}

- (id)gridControl:(id)aControl titleForItemAt:(NSInteger)aAt
{
    return nil;
}

- (NSInteger)numberOfItemsInGridControl:(id)aControl
{
    Class self_00;
    id pvVar1;
    NSUInteger pvVar1_3;

    pvVar1 = _gradientsGridControl;
    self_00 = [self class];
    if (pvVar1 == aControl) {
        pvVar1_3 = [[self_00 gradientPresets] count];
        if (0xc < (int)pvVar1_3) {
            pvVar1_3 = 0xc;
        }
    }
    else {
        pvVar1_3 = [[self_00 texturePresets] count];
        if (9 < (int)pvVar1_3) {
            pvVar1_3 = 0x9;
        }
    }
    return (int)pvVar1_3;
}

- (Class)cellClass
{
    return [SMKGridBaseCell class];
}

- (void)colorPickingDidFinishWithColor:(id)aColor
{
    if (aColor != nil) {
        [_workColorWell setColor:aColor];
        [[self delegate] colorViewController:self changedColorTo:aColor];
    }
}

- (void)validateUserInterface
{
    id pvVar1_2;

    pvVar1_2 = [[self delegate] colorPickingController];
    if (pvVar1_2 != nil) {
        [_colorPickingActivateButton setState:(unsigned int)([pvVar1_2 isColorPickingModeActive])];
    }
}

- (void)eraseBackground:(id)aBackground
{
    [[self delegate] actionEraseBackground:aBackground];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0014da9f @ 0014da9f, 130 bytes * /

void FUN_0014da9f(HSToolPaletteColorViewController *self,SEL _cmd,id activateColorPickingMode)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_delegate);
  pvVar1 = _objc_msgSend(pvVar1,sel_colorPickingController);
  pvVar2 = _objc_msgSend(pvVar1,sel_isColorPickingModeActive);
  op = sel_activateColorPickingModeWithDelegate_didEndSelector_;
  if ((char)pvVar2 != '\0') {
    op = sel_cancelColorPicking;
  }
  _objc_msgSend(pvVar1,op);
  return;
}

*/
- (void)activateColorPickingMode:(id)aMode
{
    id controller = [[self delegate] colorPickingController];
    if ([controller isColorPickingModeActive]) {
        [controller cancelColorPicking];
    }
    else {
        [controller activateColorPickingModeWithDelegate:self didEndSelector:@selector(colorPickingDidFinishWithColor:)];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0014f879 @ 0014f879, 386 bytes * /

void FUN_0014f879(HSToolPaletteColorViewController *self,SEL _cmd,id colorChanged)

{
  HSColorWell *self_00;
  HSToolPaletteColorViewController *self_01;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  double dVar4;
  HSToolPaletteColorViewController *pHVar5;
  
  _objc_msgSend(self->_colorPickingActivateButton,sel_setState_,0);
  self_00 = self->_workColorWell;
  self_01 = _objc_msgSend(self->_color,sel_retain);
  pvVar1 = _objc_msgSend(self->_workColorWell,sel_color);
  dVar4 = _objc_msgSend_fpret(pvVar1,sel_alphaComponent);
  pvVar2 = _objc_msgSend(colorChanged,sel_color);
  pvVar1 = (id)(float)dVar4;
  pvVar2 = _objc_msgSend(self,sel_newColorFromColor_withAlphaComponent_,pvVar2,pvVar1);
  pvVar3 = _objc_msgSend(self,sel_delegate);
  pHVar5 = (HSToolPaletteColorViewController *)sel_colorViewController_changedColorTo_;
  pvVar3 = _objc_msgSend(pvVar3,sel_respondsToSelector_,sel_colorViewController_changedColorTo_);
  if ((char)pvVar3 != '\0') {
    pvVar1 = _objc_msgSend(self,sel_delegate,pHVar5,pvVar1);
    pHVar5 = self;
    _objc_msgSend(pvVar1,sel_colorViewController_changedColorTo_,self,pvVar2);
    pvVar1 = pvVar2;
  }
  if ((self_00 != self->_workColorWell) && (self->_color != (id)0x0)) {
    pvVar2 = _objc_msgSend(self_00,sel_isActive,pHVar5,pvVar1);
    if ((char)pvVar2 != '\0') {
      _objc_msgSend(self_00,sel_deactivate,pHVar5,pvVar1);
    }
    pHVar5 = self_01;
    _objc_msgSend(self_00,sel_setColor_,self_01,pvVar1);
  }
  _objc_msgSend(self_01,sel_release,pHVar5,pvVar1);
  return;
}

*/
- (void)colorChanged:(id)aChanged
{
    id previousWell;
    id previousColor;
    id color;
    [_colorPickingActivateButton setState:NSControlStateValueOff];
    previousWell = _workColorWell;
    previousColor = [_color retain];
    color = [aChanged color];
    [_workColorWell setColor:color];
    [[self delegate] colorViewController:self changedColorTo:color];
    if (previousWell != _workColorWell && _color != nil) {
        if ([previousWell isActive]) {
            [previousWell deactivate];
        }
        [previousWell setColor:previousColor];
    }
    [previousColor release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0014f9fb @ 0014f9fb, 133 bytes * /

id FUN_0014f9fb(HSToolPaletteColorViewController *self,SEL _cmd,id newColorFromColor,
               float withAlphaComponent)

{
  id pvVar1;
  double dVar2;
  
  dVar2 = _objc_msgSend_fpret(newColorFromColor,sel_alphaComponent);
  if ((((float)dVar2 != withAlphaComponent) ||
      (pvVar1 = newColorFromColor, NAN((float)dVar2) || NAN(withAlphaComponent))) &&
     (pvVar1 = _objc_msgSend(newColorFromColor,sel_colorWithAlphaComponent_,withAlphaComponent),
     pvVar1 != (id)0x0)) {
    _objc_msgSend(self->_workColorWell,sel_setColor_,pvVar1);
  }
  if (pvVar1 != (id)0x0) {
    newColorFromColor = pvVar1;
  }
  return newColorFromColor;
}

*/
/* --- i386 decompilation (Ghidra) ---
/* FUN_0014d9ba @ 0014d9ba, 229 bytes * /

void FUN_0014d9ba(HSToolPaletteColorViewController *self,SEL _cmd,id orderFrontColorPanel)

{
  HSColorWell *self_00;
  id pvVar1;
  SEL op;
  undefined4 uVar2;
  
  self_00 = _objc_msgSend(cls_NSColorPanel,sel_sharedColorPanel);
  pvVar1 = _objc_msgSend(self_00,sel_isVisible);
  op = sel_close;
  if ((char)pvVar1 != '\0') goto LAB_0014da05;
  if (self->_workColorWell == self->_gradientsColorWell) {
    pvVar1 = _objc_msgSend(cls_HSAEditorApplication,sel_sharedHyperApplication);
    uVar2 = 8;
LAB_0014da7d:
    _objc_msgSend(pvVar1,sel_setColorPickerMode_,uVar2);
  }
  else if (self->_workColorWell == self->_texturesColorWell) {
    pvVar1 = _objc_msgSend(cls_HSAEditorApplication,sel_sharedHyperApplication);
    uVar2 = 9;
    goto LAB_0014da7d;
  }
  self_00 = self->_workColorWell;
  op = sel_activate_;
LAB_0014da05:
  _objc_msgSend(self_00,op);
  return;
}

*/
- (void)orderFrontColorPanel:(id)aPanel
{
    NSColorPanel *panel = [NSColorPanel sharedColorPanel];
    if ([panel isVisible]) {
        [panel close];
        return;
    }
    if (_workColorWell == _gradientsColorWell) {
        [[HSAEditorApplication sharedHyperApplication] setColorPickerMode:8];
    }
    else if (_workColorWell == _texturesColorWell) {
        [[HSAEditorApplication sharedHyperApplication] setColorPickerMode:9];
    }
    [_workColorWell activate:YES];
}

- (BOOL)isPatternSupportEnabled
{
    return (BOOL)[_workColorWell isPatternSupportEnabled];
}

- (void)setPatternSupportEnabled:(BOOL)aEnabled
{
    int iVar1;

    iVar1 = (int)aEnabled;
    [_crayonsColorWell setPatternSupportEnabled:iVar1];
    [_gradientsColorWell setPatternSupportEnabled:iVar1];
    [_texturesColorWell setPatternSupportEnabled:iVar1];
}

- (BOOL)isGradientSupportEnabled
{
    return (BOOL)[_workColorWell isGradientSupportEnabled];
}

- (void)setGradientSupportEnabled:(BOOL)aEnabled
{
    int iVar1;

    iVar1 = (int)aEnabled;
    [_crayonsColorWell setGradientSupportEnabled:iVar1];
    [_gradientsColorWell setGradientSupportEnabled:iVar1];
    [_texturesColorWell setGradientSupportEnabled:iVar1];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0014d7e8 @ 0014d7e8, 168 bytes * /

void FUN_0014d7e8(HSToolPaletteColorViewController *self,SEL _cmd,
                 BOOL setShouldShowsAlphaInActivePanel)

{
  byte bVar1;
  id pvVar2;
  int iVar3;
  
  pvVar2 = _objc_msgSend(self,sel_shouldShowsAlphaInActivePanel);
  if ((char)pvVar2 != setShouldShowsAlphaInActivePanel) {
    bVar1 = *(byte *)&self->_toolPaletteColorViewControllerFlags;
    (self->_toolPaletteColorViewControllerFlags).shouldShowsAlphaInActivePanel =
         setShouldShowsAlphaInActivePanel;
    if ((self->_colorView == (id)0x0) && (self->_eraserColorView == (id)0x0)) {
      *(byte *)&self->_toolPaletteColorViewControllerFlags =
           bVar1 & 0xfe | setShouldShowsAlphaInActivePanel & 1U | 2;
    }
    else {
      iVar3 = (int)setShouldShowsAlphaInActivePanel;
      _objc_msgSend(self->_crayonsColorWell,sel_setShowsAlphaForPanel_,iVar3);
      _objc_msgSend(self->_gradientsColorWell,sel_setShowsAlphaForPanel_,iVar3);
      _objc_msgSend(self->_texturesColorWell,sel_setShowsAlphaForPanel_,iVar3);
      (self->_toolPaletteColorViewControllerFlags).shouldShowsAlphaFlagBeAppliedToWells = 0;
    }
  }
  return;
}

*/
- (void)setShouldShowsAlphaInActivePanel:(BOOL)aPanel
{
    if ([self shouldShowsAlphaInActivePanel] != aPanel) {
        _toolPaletteColorViewControllerFlags.shouldShowsAlphaInActivePanel = aPanel;
        if (_colorView == nil && _eraserColorView == nil) {
            // Applied to the wells once the views are set up.
            _toolPaletteColorViewControllerFlags.shouldShowsAlphaFlagBeAppliedToWells = 1;
        }
        else {
            [_crayonsColorWell setShowsAlphaForPanel:aPanel];
            [_gradientsColorWell setShowsAlphaForPanel:aPanel];
            [_texturesColorWell setShowsAlphaForPanel:aPanel];
            _toolPaletteColorViewControllerFlags.shouldShowsAlphaFlagBeAppliedToWells = 0;
        }
    }
}

- (BOOL)shouldShowsAlphaInActivePanel
{
    if ((_colorView != nil) && (_eraserColorView != nil)) {
        return (_toolPaletteColorViewControllerFlags).shouldShowsAlphaInActivePanel;
    }
    return YES;
}

- (id)color
{
    return [_workColorWell color];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0014fa80 @ 0014fa80, 1745 bytes * /

void FUN_0014fa80(HSToolPaletteColorViewController *self,SEL _cmd,id setColor)

{
  HSColorWell *pHVar1;
  HSToolPaletteColorViewController *pHVar2;
  id pvVar3;
  id pvVar4;
  int iVar5;
  int iVar6;
  id pvVar7;
  id pvVar8;
  id pvVar9;
  undefined4 *puVar10;
  id pvVar11;
  int local_b0;
  id local_ac;
  undefined1 local_a4 [16];
  undefined1 local_94 [16];
  undefined1 local_84 [16];
  int local_74 [23];
  id local_18;
  HSToolPaletteColorViewController *local_14;
  
  local_14 = self;
  local_18 = setColor;
  if (self->_isInLiveChanging != '\0') {
    return;
  }
  pvVar3 = _objc_msgSend(self->_workColorWell,sel_isActive);
  pvVar4 = _objc_msgSend(local_14->_tabView,sel_numberOfTabs);
  puVar10 = (undefined4 *)&stack0xffffff24;
  if ((int)pvVar4 < 1) goto LAB_0015008f;
  local_ac = (id)0x0;
  _objc_exception_try_enter();
  iVar5 = __setjmp(local_74);
  if (iVar5 == 0) {
    local_ac = _objc_msgSend(local_18,sel_patternImage);
  }
  else {
    iVar6 = _objc_exception_extract();
    _objc_exception_try_enter();
    iVar5 = __setjmp(local_74);
    if (iVar5 == 0) {
      iVar5 = _objc_exception_match();
      if (iVar5 != 0) goto LAB_0014fb5a;
      _objc_exception_try_exit();
    }
    else {
      iVar6 = _objc_exception_extract();
    }
    if (iVar6 != 0) {
                    /* WARNING: Subroutine does not return * /
      _objc_exception_throw();
    }
  }
LAB_0014fb5a:
  _objc_exception_try_exit();
  pvVar4 = _objc_msgSend(local_18,sel_hyperGradientColor);
  pvVar7 = _objc_msgSend(local_14->_previewView,sel_subviews);
  pvVar7 = _objc_msgSend(pvVar7,sel_objectAtIndex_);
  _objc_msgSend(pvVar7,sel_removeFromSuperviewWithoutNeedingDisplay);
  if (local_ac == (id)0x0) {
    if (pvVar4 == (id)0x0) {
      _objc_msgSend(local_14->_tabView,sel_selectTabAtIndex_);
      pvVar4 = local_14->_crayonsPreview;
      _objc_msgSend_stret(local_84,local_14->_previewView,sel_bounds);
      puVar10 = (undefined4 *)&stack0xffffff20;
      _objc_msgSend(pvVar4,sel_setFrame_);
      _objc_msgSend(local_14->_previewView,sel_addSubview_);
      local_14->_workColorWell = local_14->_crayonsColorWell;
    }
    else {
      _objc_msgSend(local_14->_tabView,sel_selectTabAtIndex_);
      pvVar7 = local_14->_gradientPreview;
      _objc_msgSend_stret(local_94,local_14->_previewView,sel_bounds);
      _objc_msgSend(pvVar7,sel_setFrame_);
      _objc_msgSend(local_14->_previewView,sel_addSubview_);
      local_14->_workColorWell = local_14->_gradientsColorWell;
      pvVar7 = _objc_msgSend(cls_HSToolPaletteColorViewController,sel_gradientPresets);
      local_b0 = 0;
      pvVar11 = _objc_msgSend(pvVar7,sel_count);
      for (; puVar10 = (undefined4 *)&stack0xffffff20, local_b0 < (int)pvVar11;
          local_b0 = local_b0 + 1) {
        pvVar8 = _objc_msgSend(pvVar4,sel_hyperHSColor);
        pvVar8 = _objc_msgSend(pvVar8,sel_hyperStartColor);
        pvVar9 = _objc_msgSend(pvVar7,sel_objectAtIndex_);
        pvVar9 = _objc_msgSend(pvVar9,sel_objectForKey_);
        _objc_msgSend(pvVar9,sel_extraColorValue);
        pvVar8 = _objc_msgSend(pvVar8,sel_isEqual_);
        if ((char)pvVar8 != '\0') {
          pvVar8 = _objc_msgSend(pvVar4,sel_hyperHSColor);
          pvVar8 = _objc_msgSend(pvVar8,sel_hyperEndColor);
          pvVar9 = _objc_msgSend(pvVar7,sel_objectAtIndex_);
          pvVar9 = _objc_msgSend(pvVar9,sel_objectForKey_);
          _objc_msgSend(pvVar9,sel_extraColorValue);
          pvVar8 = _objc_msgSend(pvVar8,sel_isEqual_);
          if ((char)pvVar8 != '\0') {
            _objc_msgSend(local_14->_gradientsGridControl,
                          sel_selectItemAtIndex_byExtendingSelection_);
            puVar10 = (undefined4 *)&stack0xffffff20;
            break;
          }
        }
      }
    }
  }
  else {
    _objc_msgSend(local_14->_tabView,sel_selectTabAtIndex_);
    pvVar4 = local_14->_texturePreview;
    _objc_msgSend_stret(local_a4,local_14->_previewView,sel_bounds);
    _objc_msgSend(pvVar4,sel_setFrame_);
    _objc_msgSend(local_14->_previewView,sel_addSubview_);
    local_14->_workColorWell = local_14->_texturesColorWell;
    pvVar4 = _objc_msgSend(cls_HSToolPaletteColorViewController,sel_texturePresets);
    pvVar7 = _objc_msgSend(pvVar4,sel_count);
    for (pvVar11 = (id)0x0; (int)pvVar11 < (int)pvVar7; pvVar11 = (id)((int)pvVar11 + 1)) {
      pvVar8 = _objc_msgSend(pvVar4,sel_objectAtIndex_);
      _objc_msgSend(pvVar8,sel_objectForKey_);
      pvVar8 = _objc_msgSend(local_ac,sel_isEqualTo_);
      if ((char)pvVar8 != '\0') {
        _objc_msgSend(local_14->_texturesGridControl,sel_selectItemAtIndex_byExtendingSelection_);
        break;
      }
    }
    puVar10 = (undefined4 *)&stack0xffffff20;
    if (pvVar7 == pvVar11) {
      _objc_msgSend(local_14->_texturesGridControl,sel_selectItemAtIndex_byExtendingSelection_);
      puVar10 = (undefined4 *)&stack0xffffff20;
    }
  }
LAB_0015008f:
  pHVar1 = local_14->_workColorWell;
  puVar10[2] = local_18;
  puVar10[1] = sel_setColor_;
  *puVar10 = pHVar1;
  puVar10[-1] = 0x1500ae;
  _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
  if ((char)pvVar3 != '\0') {
    pHVar1 = local_14->_workColorWell;
    puVar10[1] = sel_isActive;
    *puVar10 = pHVar1;
    puVar10[-1] = 0x1500cf;
    pvVar3 = _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
    if ((char)pvVar3 == '\0') {
      pHVar1 = local_14->_workColorWell;
      puVar10[1] = sel_activate_;
      *puVar10 = pHVar1;
      puVar10[2] = 1;
      puVar10[-1] = 0x1500f3;
      _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
    }
  }
  pvVar3 = local_14->_color;
  puVar10[1] = sel_release;
  *puVar10 = pvVar3;
  puVar10[-1] = 0x15010b;
  _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
  pHVar2 = local_14;
  puVar10[1] = sel_retain;
  *puVar10 = local_18;
  puVar10[-1] = 0x150123;
  pvVar3 = _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
  pHVar2->_color = pvVar3;
  return;
}

*/
- (void)setColor:(id)aColor
{
    BOOL wasActive;
    id patternImage = nil;
    id gradient;
    NSArray *presets;
    NSInteger count;
    NSInteger i;
    if (_isInLiveChanging) {
        return;
    }
    wasActive = [_workColorWell isActive];
    if ((NSInteger)[_tabView numberOfTabs] >= 1) {
        @try {
            patternImage = [aColor patternImage];
        }
        @catch (NSException *exception) {
        }
        gradient = [aColor hyperGradientColor];
        [[[_previewView subviews] objectAtIndex:0] removeFromSuperviewWithoutNeedingDisplay];
        if (patternImage != nil) {
            [_tabView selectTabAtIndex:2];
            [_texturePreview setFrame:[_previewView bounds]];
            [_previewView addSubview:_texturePreview];
            _workColorWell = _texturesColorWell;
            presets = [HSToolPaletteColorViewController texturePresets];
            count = [presets count];
            for (i = 0; i < count; i++) {
                if ([patternImage isEqualTo:[[presets objectAtIndex:i] objectForKey:@"Image"]]) {
                    [_texturesGridControl selectItemAtIndex:i byExtendingSelection:NO];
                    break;
                }
            }
            if (count == i) {
                [_texturesGridControl selectItemAtIndex:-1 byExtendingSelection:NO];
            }
        }
        else if (gradient != nil) {
            [_tabView selectTabAtIndex:1];
            [_gradientPreview setFrame:[_previewView bounds]];
            [_previewView addSubview:_gradientPreview];
            _workColorWell = _gradientsColorWell;
            presets = [HSToolPaletteColorViewController gradientPresets];
            count = [presets count];
            for (i = 0; i < count; i++) {
                if ([[[gradient hyperHSColor] hyperStartColor] isEqual:[[[presets objectAtIndex:i] objectForKey:@"StartColor"] extraColorValue]]
                    && [[[gradient hyperHSColor] hyperEndColor] isEqual:[[[presets objectAtIndex:i] objectForKey:@"EndColor"] extraColorValue]]) {
                    [_gradientsGridControl selectItemAtIndex:i byExtendingSelection:NO];
                    break;
                }
            }
        }
        else {
            [_tabView selectTabAtIndex:0];
            [_crayonsPreview setFrame:[_previewView bounds]];
            [_previewView addSubview:_crayonsPreview];
            _workColorWell = _crayonsColorWell;
        }
    }
    [_workColorWell setColor:aColor];
    if (wasActive && ![_workColorWell isActive]) {
        [_workColorWell activate:YES];
    }
    [_color release];
    _color = [aColor retain];
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
    if (_eraserColorView != nil) {
        [_eraserButton setEnabled:[[self delegate] respondsToSelector:@selector(actionEraseBackground:)]];
    }
}

- (id)delegate
{
    return _delegate;
}

- (id)crayonsView
{
    return _crayonsView;
}

- (id)eraserColorView
{
    id pvVar2;

    pvVar2 = _eraserColorView;
    if (pvVar2 == nil) {
        [NSBundle loadNibNamed:@"ColorView" owner:self];
        [self HSToolPaletteColorViewController_setupColorViewWithColorsContainer:_eraserContainerView previewContainer:_eraserPreviewView];
        [_eraserButton setEnabled:[[self delegate] respondsToSelector:@selector(actionEraseBackground:)]];
        pvVar2 = _eraserColorView;
    }
    return pvVar2;
}

- (id)colorView
{
    id pvVar1;

    pvVar1 = _colorView;
    if (pvVar1 == nil) {
        [NSBundle loadNibNamed:@"ColorView" owner:self];
        [self HSToolPaletteColorViewController_setupColorViewWithColorsContainer:_containerView previewContainer:_previewView];
        pvVar1 = _colorView;
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00150151 @ 00150151, 357 bytes * /

void FUN_00150151(HSToolPaletteColorViewController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  undefined4 uVar3;
  
  pvVar1 = _objc_msgSend(self->_colorPickingActivateButton,sel_cell);
  pvVar2 = _objc_msgSend(cls_HSToolSettingsBigControlBackgroundRenderer,sel_sharedBackgroundRenderer
                        );
  _objc_msgSend(pvVar1,sel_setBackgroundRenderer_,pvVar2);
  pvVar1 = _objc_msgSend(self->_colorPickingActivateButton,sel_cell);
  uVar3 = *(undefined4 *)PTR_00336354;
  _objc_msgSend(pvVar1,sel_accessibilitySetOverrideValue_forAttribute_,uVar3,
                *(undefined4 *)PTR_00336370);
  pvVar1 = _objc_msgSend(self->_colorPickingActivateButton,sel_cell);
  uVar3 = _NSAccessibilityRoleDescription(uVar3,0);
  _objc_msgSend(pvVar1,sel_accessibilitySetOverrideValue_forAttribute_,uVar3,
                *(undefined4 *)PTR_00336374);
  pvVar1 = _objc_msgSend(self->_eraserButton,sel_cell);
  pvVar2 = _objc_msgSend(cls_HSToolSettingsBigControlBackgroundRenderer,sel_sharedBackgroundRenderer
                        );
  _objc_msgSend(pvVar1,sel_setBackgroundRenderer_,pvVar2);
  pvVar1 = _objc_msgSend(self->_workColorWell,sel_color);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_color = pvVar1;
  return;
}

*/
- (void)awakeFromNib
{
    [[_colorPickingActivateButton cell] setBackgroundRenderer:[HSToolSettingsBigControlBackgroundRenderer sharedBackgroundRenderer]];
    [[_colorPickingActivateButton cell] accessibilitySetOverrideValue:NSAccessibilityButtonRole forAttribute:NSAccessibilityRoleAttribute];
    [[_colorPickingActivateButton cell] accessibilitySetOverrideValue:NSAccessibilityRoleDescription(NSAccessibilityButtonRole, nil) forAttribute:NSAccessibilityRoleDescriptionAttribute];
    [[_eraserButton cell] setBackgroundRenderer:[HSToolSettingsBigControlBackgroundRenderer sharedBackgroundRenderer]];
    _color = [[_workColorWell color] retain];
}

- (void)dealloc
{
    [_colorView release];
    [_crayonsContainerView release];
    [_tabView release];
    [_gradientsView release];
    [_texturesView release];
    [_crayonsPreview release];
    [_texturePreview release];
    [_gradientPreview release];
    [_eraserColorView release];
    [_color release];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0014ec1b @ 0014ec1b, 567 bytes * /

void FUN_0014ec1b(HSToolPaletteColorViewController *self,SEL _cmd,
                 id HSToolPaletteColorViewController_setupColorViewWithColorsContainer,
                 id previewContainer)

{
  id pvVar1;
  id pvVar2;
  int iVar3;
  int *piVar4;
  undefined1 local_44 [12];
  float fStack_38;
  undefined1 local_34 [16];
  undefined8 local_24;
  undefined8 local_1c;
  
  piVar4 = (int *)&stack0xffffffa4;
  pvVar1 = _objc_msgSend(self,sel_delegate);
  pvVar1 = _objc_msgSend(pvVar1,sel_shouldDisplayGradientsAndPattersForColorViewController_);
  if ((char)pvVar1 == '\0') {
    _objc_msgSend_stret(local_44,HSToolPaletteColorViewController_setupColorViewWithColorsContainer,
                        sel_frame);
    fStack_38 = fStack_38 + 4.0;
    _objc_msgSend(HSToolPaletteColorViewController_setupColorViewWithColorsContainer,sel_setFrame_);
    pvVar1 = self->_crayonsContainerView;
    _objc_msgSend_stret(local_34,HSToolPaletteColorViewController_setupColorViewWithColorsContainer,
                        sel_bounds);
    piVar4 = (int *)&stack0xffffff9c;
    _objc_msgSend(pvVar1,sel_setFrame_);
  }
  piVar4[-1] = 0x14ed34;
  _objc_msgSend((id)*piVar4,(SEL)piVar4[1]);
  pvVar1 = self->_crayonsPreview;
  piVar4[2] = (int)sel_bounds;
  piVar4[1] = (int)previewContainer;
  *piVar4 = (int)&local_24;
  piVar4[-1] = 0x14ed53;
  _objc_msgSend_stret((void *)*piVar4,(id)piVar4[1],(SEL)piVar4[2]);
  *(undefined8 *)(piVar4 + 3) = local_1c;
  *(undefined8 *)(piVar4 + 1) = local_24;
  *piVar4 = (int)sel_setFrame_;
  piVar4[-1] = (int)pvVar1;
  piVar4[-2] = 0x14ed7e;
  _objc_msgSend((id)piVar4[-1],(SEL)*piVar4);
  piVar4[1] = (int)self->_crayonsPreview;
  *piVar4 = (int)sel_addSubview_;
  piVar4[-1] = (int)previewContainer;
  piVar4[-2] = 0x14ed9a;
  _objc_msgSend((id)piVar4[-1],(SEL)*piVar4);
  self->_workColorWell = self->_crayonsColorWell;
  pvVar1 = self->_crayonsView;
  piVar4[1] = (int)self;
  *piVar4 = (int)sel_setTarget_;
  piVar4[-1] = (int)pvVar1;
  piVar4[-2] = 0x14edb9;
  _objc_msgSend((id)piVar4[-1],(SEL)*piVar4);
  pvVar1 = self->_crayonsView;
  piVar4[1] = (int)sel_colorChanged_;
  *piVar4 = (int)sel_setAction_;
  piVar4[-1] = (int)pvVar1;
  piVar4[-2] = 0x14edd8;
  _objc_msgSend((id)piVar4[-1],(SEL)*piVar4);
  if (((undefined1 *)&self->_toolPaletteColorViewControllerFlags)->
      shouldShowsAlphaFlagBeAppliedToWells == 0) {
    *(byte *)&self->_toolPaletteColorViewControllerFlags =
         *(undefined1 *)&self->_toolPaletteColorViewControllerFlags | 1;
  }
  else {
    *piVar4 = (int)sel_shouldShowsAlphaInActivePanel;
    piVar4[-1] = (int)self;
    piVar4[-2] = 0x14edf1;
    pvVar2 = _objc_msgSend((id)piVar4[-1],(SEL)*piVar4);
    pvVar1 = self->_crayonsColorWell;
    iVar3 = (int)(char)pvVar2;
    piVar4[1] = iVar3;
    *piVar4 = (int)sel_setShowsAlphaForPanel_;
    piVar4[-1] = (int)pvVar1;
    piVar4[-2] = 0x14ee0d;
    _objc_msgSend((id)piVar4[-1],(SEL)*piVar4);
    pvVar1 = self->_gradientsColorWell;
    piVar4[1] = iVar3;
    *piVar4 = (int)sel_setShowsAlphaForPanel_;
    piVar4[-1] = (int)pvVar1;
    piVar4[-2] = 0x14ee26;
    _objc_msgSend((id)piVar4[-1],(SEL)*piVar4);
    pvVar1 = self->_texturesColorWell;
    piVar4[1] = iVar3;
    *piVar4 = (int)sel_setShowsAlphaForPanel_;
    piVar4[-1] = (int)pvVar1;
    piVar4[-2] = 0x14ee3f;
    _objc_msgSend((id)piVar4[-1],(SEL)*piVar4);
    (self->_toolPaletteColorViewControllerFlags).shouldShowsAlphaFlagBeAppliedToWells = 0;
  }
  return;
}

*/
- (void)HSToolPaletteColorViewController_setupColorViewWithColorsContainer:(id)aContainer previewContainer:(id)aContainer2
{
    NSRect frame;
    BOOL alpha;
    if (![[self delegate] shouldDisplayGradientsAndPattersForColorViewController:self]) {
        frame = [aContainer frame];
        frame.size.height = frame.size.height + 4.0;
        [aContainer setFrame:frame];
        [_crayonsContainerView setFrame:[aContainer bounds]];
    }
    [aContainer addSubview:_crayonsContainerView];
    [_crayonsPreview setFrame:[aContainer2 bounds]];
    [aContainer2 addSubview:_crayonsPreview];
    _workColorWell = _crayonsColorWell;
    [_crayonsView setTarget:self];
    [_crayonsView setAction:@selector(colorChanged:)];
    if (_toolPaletteColorViewControllerFlags.shouldShowsAlphaFlagBeAppliedToWells) {
        alpha = [self shouldShowsAlphaInActivePanel];
        [_crayonsColorWell setShowsAlphaForPanel:alpha];
        [_gradientsColorWell setShowsAlphaForPanel:alpha];
        [_texturesColorWell setShowsAlphaForPanel:alpha];
        _toolPaletteColorViewControllerFlags.shouldShowsAlphaFlagBeAppliedToWells = 0;
    }
    else {
        // The original sets the alpha flag itself here, not the pending-apply flag.
        _toolPaletteColorViewControllerFlags.shouldShowsAlphaInActivePanel = 1;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0014e160 @ 0014e160, 2747 bytes * /

void FUN_0014e160(HSToolPaletteColorViewController *self,SEL _cmd,
                 id 
                 HSToolPaletteColorViewController_setupGradientsAndPattersViewsWithColorsContainer)

{
  undefined *puVar1;
  undefined *puVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  id self_00;
  int iVar8;
  undefined4 uVar9;
  undefined8 uVar10;
  id local_48;
  undefined4 *local_44;
  id local_40;
  id local_34 [4];
  undefined8 local_24;
  undefined8 local_1c;
  
  puVar2 = cls_NSDictionary;
  pvVar3 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_);
  puVar1 = cls_NSBundle;
  _objc_msgSend(self,sel_class);
  pvVar3 = _objc_msgSend(puVar1,sel_bundleForClass_);
  _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_);
  _objc_msgSend(puVar2,sel_dictionaryWithObjectsAndKeys_);
  puVar1 = cls_NSBundle;
  pvVar3 = self->_tabView;
  _objc_msgSend(self,sel_class);
  pvVar4 = _objc_msgSend(puVar1,sel_bundleForClass_);
  _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_);
  _objc_msgSend(cls_NSImage,sel_imageNamed_);
  puVar1 = cls_NSBundle;
  _objc_msgSend(self,sel_class);
  pvVar4 = _objc_msgSend(puVar1,sel_bundleForClass_);
  _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_);
  _objc_msgSend(pvVar3,sel_addTabWithTitle_image_toolTip_accessibilityValues_contentView_);
  puVar2 = cls_NSDictionary;
  pvVar3 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_);
  puVar1 = cls_NSBundle;
  _objc_msgSend(self,sel_class);
  pvVar3 = _objc_msgSend(puVar1,sel_bundleForClass_);
  _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_);
  _objc_msgSend(puVar2,sel_dictionaryWithObjectsAndKeys_);
  puVar1 = cls_NSBundle;
  pvVar3 = self->_tabView;
  _objc_msgSend(self,sel_class);
  pvVar4 = _objc_msgSend(puVar1,sel_bundleForClass_);
  _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_);
  _objc_msgSend(cls_NSImage,sel_imageNamed_);
  puVar1 = cls_NSBundle;
  _objc_msgSend(self,sel_class);
  pvVar4 = _objc_msgSend(puVar1,sel_bundleForClass_);
  _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_);
  _objc_msgSend(pvVar3,sel_addTabWithTitle_image_toolTip_accessibilityValues_contentView_);
  puVar2 = cls_NSDictionary;
  pvVar3 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_);
  puVar1 = cls_NSBundle;
  _objc_msgSend(self,sel_class);
  pvVar3 = _objc_msgSend(puVar1,sel_bundleForClass_);
  _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_);
  pvVar5 = _objc_msgSend(puVar2,sel_dictionaryWithObjectsAndKeys_);
  puVar1 = cls_NSBundle;
  pvVar3 = self->_tabView;
  pvVar4 = self->_texturesView;
  _objc_msgSend(self,sel_class);
  pvVar6 = _objc_msgSend(puVar1,sel_bundleForClass_);
  pvVar6 = _objc_msgSend(pvVar6,sel_localizedStringForKey_value_table_);
  pvVar7 = _objc_msgSend(cls_NSImage,sel_imageNamed_);
  puVar1 = cls_NSBundle;
  _objc_msgSend(self,sel_class);
  self_00 = _objc_msgSend(puVar1,sel_bundleForClass_);
  _objc_msgSend(self_00,sel_localizedStringForKey_value_table_);
  uVar10 = CONCAT44(pvVar6,pvVar7);
  _objc_msgSend(pvVar3,sel_addTabWithTitle_image_toolTip_accessibilityValues_contentView_);
  pvVar3 = self->_tabView;
  _objc_msgSend_stret(&local_24,
                      HSToolPaletteColorViewController_setupGradientsAndPattersViewsWithColorsContainer
                      ,sel_bounds,uVar10,pvVar5,pvVar4);
  _objc_msgSend(pvVar3,sel_setFrame_,local_24,local_1c);
  uVar9 = (undefined4)((ulonglong)local_24 >> 0x20);
  _objc_msgSend(HSToolPaletteColorViewController_setupGradientsAndPattersViewsWithColorsContainer,
                sel_addSubview_,self->_tabView);
  pvVar3 = self->_gradientsGridControl;
  local_34[3] = self->_texturesGridControl;
  local_34[0] = (id)0x3f800000;
  local_34[1] = (id)0x3f800000;
  local_48 = (id)0x3f000000;
  local_44 = &DAT_003354ec;
  iVar8 = 0;
  local_40 = local_48;
  local_34[2] = pvVar3;
  while( true ) {
    _objc_msgSend(pvVar3,sel_setMode_,0,uVar9,local_1c);
    _objc_msgSend(pvVar3,sel_setScrollerControlSize_,1);
    _objc_msgSend(pvVar3,sel_setSelectionStyle_,3);
    _objc_msgSend(pvVar3,sel_setThreadedPreloadingEnabled_,0);
    _objc_msgSend(pvVar3,sel_setAllowsMultipleSelection_,0);
    _objc_msgSend(pvVar3,sel_setThumbnailCachingEnabled_,0);
    _objc_msgSend(pvVar3,sel_setThumbnailHyphenationEnabled_,1);
    _objc_msgSend(pvVar3,sel_setGraphicContentShadowEnabled_,0);
    _objc_msgSend(pvVar3,sel_setExtraPasteboardDataProvidingAllowed_,0);
    _objc_msgSend(pvVar3,sel_setDataSource_,self);
    _objc_msgSend(pvVar3,sel_setDelegate_,self);
    _objc_msgSend(pvVar3,sel_setTarget_,self);
    uVar9 = *local_44;
    local_1c = CONCAT44(local_40,local_48);
    _objc_msgSend(pvVar3,sel_setThumbnailSize_andBorderOffset_,local_44[-1]);
    pvVar4 = _objc_msgSend(pvVar3,sel_scrollView);
    _objc_msgSend(pvVar4,sel_setHasVerticalScroller_,0);
    pvVar4 = _objc_msgSend(pvVar3,sel_scrollView);
    _objc_msgSend(pvVar4,sel_setHasHorizontalScroller_,0);
    pvVar4 = _objc_msgSend(pvVar3,sel_scrollView);
    _objc_msgSend(pvVar4,sel_setBorderType_,0);
    pvVar4 = _objc_msgSend(pvVar3,sel_gridMatrix);
    _objc_msgSend(pvVar4,sel_setAcceptsFirstMouse_,1);
    pvVar4 = _objc_msgSend(pvVar3,sel_gridMatrix);
    _objc_msgSend(pvVar4,sel_setNeedsPanelToBecomeKey_);
    _objc_msgSend(pvVar3,sel_reloadData);
    if (iVar8 == 1) break;
    local_44 = local_44 + 2;
    local_40 = local_34[iVar8 * 2 + 1];
    local_48 = local_34[iVar8 * 2];
    pvVar3 = local_34[iVar8 + 3];
    iVar8 = iVar8 + 1;
  }
  pvVar3 = _objc_msgSend(self->_texturesGridControl,sel_gridMatrix);
  _objc_msgSend(pvVar3,sel_setAllowsEmptySelection_,1);
  _objc_msgSend(self->_tabView,sel_setDelegate_,self);
  _objc_msgSend(self->_crayonsColorWell,sel_setGradientSupportEnabled_,1);
  _objc_msgSend(self->_crayonsColorWell,sel_setPatternSupportEnabled_,1);
  _objc_msgSend(self->_gradientsColorWell,sel_setGradientSupportEnabled_,1);
  _objc_msgSend(self->_gradientsColorWell,sel_setPatternSupportEnabled_,1);
  _objc_msgSend(self->_texturesColorWell,sel_setGradientSupportEnabled_,1);
  _objc_msgSend(self->_texturesColorWell,sel_setPatternSupportEnabled_,1);
  _objc_msgSend(self,sel_synchronizeColorWellColorWithSelectedInGridControl_,
                self->_gradientsGridControl);
  _objc_msgSend(self,sel_synchronizeColorWellColorWithSelectedInGridControl_,
                self->_texturesGridControl);
  return;
}

*/
- (void)HSToolPaletteColorViewController_setupGradientsAndPattersViewsWithColorsContainer:(id)aContainer
{
    NSString *tabNames[3] = { @"Color", @"Gradient", @"Texture" };
    NSString *settingsNames[3] = { @"Color settings", @"Gradient settings", @"Texture settings" };
    NSString *imageNames[3] = { @"tab_swatches", @"tab_gradient", @"tab_texture" };
    NSString *toolTips[3] = { @"Color ToolTip", @"Gradient ToolTip", @"Textures ToolTip" };
    NSView *contentViews[3] = { _crayonsContainerView, _gradientsView, _texturesView };
    SMKGridControl *gridControls[2] = { _gradientsGridControl, _texturesGridControl };
    NSSize thumbnailSizes[2] = { { 31.0, 15.0 }, { 29.0, 20.0 } };
    NSSize borderOffsets[2] = { { 0.5, 0.5 }, { 1.0, 1.0 } };
    NSDictionary *accessibilityValues;
    NSBundle *bundle;
    SMKGridControl *gridControl;
    int i;
    for (i = 0; i < 3; i++) {
        bundle = [NSBundle bundleForClass:[self class]];
        accessibilityValues = [NSDictionary dictionaryWithObjectsAndKeys:[[NSBundle mainBundle] localizedStringForKey:@"tab" value:@"" table:nil], NSAccessibilityRoleDescriptionAttribute, [bundle localizedStringForKey:settingsNames[i] value:@"" table:@"ToolPalette"], NSAccessibilityDescriptionAttribute, nil];
        [_tabView addTabWithTitle:[bundle localizedStringForKey:tabNames[i] value:@"" table:@"ToolPalette"] image:[NSImage imageNamed:imageNames[i]] toolTip:[bundle localizedStringForKey:toolTips[i] value:@"" table:@"ToolPalette"] accessibilityValues:accessibilityValues contentView:contentViews[i]];
    }
    [_tabView setFrame:[aContainer bounds]];
    [aContainer addSubview:_tabView];
    for (i = 0; i < 2; i++) {
        gridControl = gridControls[i];
        [gridControl setMode:0];
        [gridControl setScrollerControlSize:NSControlSizeSmall];
        [gridControl setSelectionStyle:3];
        [gridControl setThreadedPreloadingEnabled:NO];
        [gridControl setAllowsMultipleSelection:NO];
        [gridControl setThumbnailCachingEnabled:NO];
        [gridControl setThumbnailHyphenationEnabled:YES];
        [gridControl setGraphicContentShadowEnabled:NO];
        [gridControl setExtraPasteboardDataProvidingAllowed:NO];
        [gridControl setDataSource:self];
        [gridControl setDelegate:self];
        [gridControl setTarget:self];
        [gridControl setThumbnailSize:thumbnailSizes[i] andBorderOffset:borderOffsets[i]];
        [[gridControl scrollView] setHasVerticalScroller:NO];
        [[gridControl scrollView] setHasHorizontalScroller:NO];
        [[gridControl scrollView] setBorderType:NSNoBorder];
        [[gridControl gridMatrix] setAcceptsFirstMouse:YES];
        [[gridControl gridMatrix] setNeedsPanelToBecomeKey:NO];
        [gridControl reloadData];
    }
    [[_texturesGridControl gridMatrix] setAllowsEmptySelection:YES];
    [_tabView setDelegate:self];
    [_crayonsColorWell setGradientSupportEnabled:YES];
    [_crayonsColorWell setPatternSupportEnabled:YES];
    [_gradientsColorWell setGradientSupportEnabled:YES];
    [_gradientsColorWell setPatternSupportEnabled:YES];
    [_texturesColorWell setGradientSupportEnabled:YES];
    [_texturesColorWell setPatternSupportEnabled:YES];
    [self synchronizeColorWellColorWithSelectedInGridControl:_gradientsGridControl];
    [self synchronizeColorWellColorWithSelectedInGridControl:_texturesGridControl];
}

@end

@implementation HSToolPaletteColorViewController (PresetsLoading)

/* --- i386 decompilation (Ghidra) ---
/* FUN_0014d372 @ 0014d372, 695 bytes * /

id FUN_0014d372(id self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  cfstringStruct *pcVar2;
  id pvVar3;
  id self_01;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  cfstringStruct *pcVar7;
  cfstringStruct *pcVar8;
  cfstringStruct *local_1c;
  
  if (DAT_00342978 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_colorViewPresets);
    pcVar7 = &cfstr_TexturePresets;
    pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_TexturePresets);
    self_00 = _objc_msgSend(self,sel_allTexturePaths);
    DAT_00342978 = _objc_msgSend(cls_NSMutableArray,sel_new);
    pcVar2 = _objc_msgSend(self_00,sel_count);
    if ((self_00 != (id)0x0) && (pcVar2 != (cfstringStruct *)0x0)) {
      pvVar1 = _objc_msgSend(pvVar1,sel_objectEnumerator,pcVar7);
      pvVar3 = _objc_msgSend(pvVar1,sel_nextObject);
      if (pvVar3 != (id)0x0) {
        local_1c = (cfstringStruct *)0x0;
        do {
          self_01 = _objc_msgSend(cls_NSAutoreleasePool,sel_new);
          pvVar4 = _objc_msgSend(self_00,sel_objectEnumerator);
          do {
            pvVar6 = _objc_msgSend(pvVar4,sel_nextObject,pcVar7);
            if (pvVar6 == (id)0x0) {
              pcVar8 = (cfstringStruct *)((int)&local_1c->field0_0x0 + 1);
              pcVar7 = local_1c;
              pvVar6 = _objc_msgSend(self_00,sel_objectAtIndex_,local_1c);
              local_1c = pcVar8;
              if (pcVar2 <= pcVar8) {
                local_1c = (cfstringStruct *)0x0;
              }
              break;
            }
            pvVar5 = _objc_msgSend(pvVar6,sel_lastPathComponent,pcVar7);
            pcVar7 = _objc_msgSend(pvVar3,sel_objectForKey_,&cfstr_Image);
            pvVar5 = _objc_msgSend(pvVar5,sel_isEqualToString_);
          } while ((char)pvVar5 == '\0');
          pvVar4 = _objc_msgSend(cls_NSImage,sel_alloc,pcVar7);
          pvVar4 = _objc_msgSend(pvVar4,sel_initWithContentsOfFile_,pvVar6);
          pvVar6 = _objc_msgSend(pvVar3,sel_objectForKey_,&cfstr_Name);
          pvVar3 = DAT_00342978;
          pcVar7 = _objc_msgSend(cls_NSDictionary,sel_dictionaryWithObjectsAndKeys_,pvVar4,
                                 &cfstr_Image,pvVar6,&cfstr_Name,0);
          _objc_msgSend(pvVar3,sel_addObject_,pcVar7);
          _objc_msgSend(pvVar4,sel_release);
          _objc_msgSend(self_01,sel_release);
          pvVar3 = _objc_msgSend(pvVar1,sel_nextObject);
        } while (pvVar3 != (id)0x0);
      }
    }
  }
  return DAT_00342978;
}

*/
+ (id)texturePresets
{
    id presets;
    id paths;
    NSUInteger pathCount;
    NSUInteger fallbackIndex;
    NSEnumerator *presetEnumerator;
    NSEnumerator *pathEnumerator;
    id preset;
    id path;
    NSAutoreleasePool *pool;
    NSImage *image;
    if (sDAT_00342978 == nil) {
        presets = [[self colorViewPresets] objectForKey:@"TexturePresets"];
        paths = [self allTexturePaths];
        sDAT_00342978 = [NSMutableArray new];
        pathCount = [paths count];
        if (paths != nil && pathCount != 0) {
            presetEnumerator = [presets objectEnumerator];
            fallbackIndex = 0;
            while ((preset = [presetEnumerator nextObject]) != nil) {
                pool = [NSAutoreleasePool new];
                pathEnumerator = [paths objectEnumerator];
                while (YES) {
                    path = [pathEnumerator nextObject];
                    if (path == nil) {
                        // No library texture with that name: cycle through the available ones.
                        path = [paths objectAtIndex:fallbackIndex];
                        fallbackIndex = fallbackIndex + 1;
                        if (pathCount <= fallbackIndex) {
                            fallbackIndex = 0;
                        }
                        break;
                    }
                    if ([[path lastPathComponent] isEqualToString:[preset objectForKey:@"Image"]]) {
                        break;
                    }
                }
                image = [[NSImage alloc] initWithContentsOfFile:path];
                [sDAT_00342978 addObject:[NSDictionary dictionaryWithObjectsAndKeys:image, @"Image", [preset objectForKey:@"Name"], @"Name", nil]];
                [image release];
                [pool release];
            }
        }
    }
    return sDAT_00342978;
}

+ (id)gradientPresets
{
    if (sDAT_00342974 == nil) {
        sDAT_00342974 = [[self colorViewPresets] objectForKey:@"GradientPresets"];
    }
    return sDAT_00342974;
}

+ (void)addItemsFromFolder:(id)aFolder to:(id)aTo
{
    NSUInteger pvVar1;
    int iVar3;
    NSUInteger pvVar1_2;
    int iVar3_2;

    pvVar1 = [aFolder numberOfDataItems];
    if (0 < (int)pvVar1) {
        iVar3 = 0;
        do {
            [aTo addObject:[[[aFolder dataItemAtIndex:iVar3] dataURL] path]];
            iVar3 = iVar3 + 1;
        } while (iVar3 < (int)pvVar1);
    }
    pvVar1_2 = [aFolder numberOfDataFolders];
    if (0 < (int)pvVar1_2) {
        iVar3_2 = 0;
        do {
            [self addItemsFromFolder:[aFolder dataFolderAtIndex:iVar3_2] to:aTo];
            iVar3_2 = iVar3_2 + 1;
        } while (iVar3_2 < (int)pvVar1_2);
    }
}

+ (id)allTexturePaths
{
    id pvVar1_3;

    if (sDAT_00342970 == nil) {
        pvVar1_3 = [[[HSLibraryManager sharedLibraryManager] providerForMediaType:@"pattern"] queryInterface:@protocol(HSLibraryMediaData)];
        if (pvVar1_3 != nil) {
            sDAT_00342970 = [NSMutableArray new];
            [self addItemsFromFolder:[pvVar1_3 rootDataFolder] to:sDAT_00342970];
        }
    }
    return sDAT_00342970;
}

+ (id)colorViewPresets
{
    NSString *pvVar1_2;

    if (sDAT_0034296c == nil) {
        pvVar1_2 = [[NSBundle bundleForClass:self] pathForResource:@"ColorViewPresets" ofType:@"plist"];
        if (pvVar1_2 != nil) {
            sDAT_0034296c = [[NSDictionary alloc] initWithContentsOfFile:pvVar1_2];
        }
    }
    return sDAT_0034296c;
}

@end

