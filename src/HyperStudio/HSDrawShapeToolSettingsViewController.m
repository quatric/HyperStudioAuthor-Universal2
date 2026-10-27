#import "HSDrawShapeToolSettingsViewController.h"

@implementation HSDrawShapeToolSettingsViewController

/* i386 ivar offsets: _shapeTypeControl=0xc, _outlineSettingsView=0x10, _fillSettingsView=0x14, _fillAndOutlineSettingsTabView=0x18, _fillSettingsTabSubView=0x1c, _outlineSettingsTabSubView=0x20, _tabHeights=0x24, _currentSettingsView=0x2c, _isUIValidationDisabled=0x30, _outlineColorViewController=0x34, _outlineColorContainerView=0x38, _fillColorViewController=0x3c, _fillColorContainerView=0x40, _outlinWithFillColorViewController=0x44, _outlineWithFillColorContainerView=0x48, _fillWithOutlineColorViewController=0x4c, _fillWithOutlineColorContainerView=0x50, _outlineWidthSlider=0x54, _outlineWithFillWidthSlider=0x58, _outlinePreview=0x5c, _fillWithOutlinePreview=0x60, _outlineWithFillPreview=0x64, _cornerSettingsView=0x68, _cornerRadiusSlider=0x6c, _containerView=0x70 */

- (id)colorPickingController
{
    return [[self toolView] queryHyperInterface:@protocol(HSColorPickingController)];
}

- (NSUInteger)tagForSettingsView:(id)aView
{
    unsigned int uVar1;

    if (_outlineSettingsView == aView) {
        uVar1 = 1;
    }
    else if (_fillSettingsView == aView) {
        uVar1 = 2;
    }
    else {
        uVar1 = (unsigned int)(_fillAndOutlineSettingsTabView == aView) * 3;
    }
    return uVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00155c99 @ 00155c99, 423 bytes * /

id FUN_00155c99(HSDrawShapeToolSettingsViewController *self,SEL _cmd,
               NSRect prototypePathForPreviewWithFrame)

{
  float fVar1;
  float fVar2;
  undefined *self_00;
  id pvVar3;
  id pvVar4;
  float fVar5;
  float fVar6;
  undefined8 local_24;
  undefined8 local_1c;
  
  fVar5 = prototypePathForPreviewWithFrame.size.width * 0.5;
  fVar1 = *(float *)PTR_00336074;
  fVar2 = *(float *)(PTR_00336074 + 4);
  fVar6 = prototypePathForPreviewWithFrame.size.height * 0.5;
  pvVar3 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar3 = _objc_msgSend(pvVar3,sel_toolSettings);
  pvVar4 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  _objc_msgSend(pvVar4,sel_currentTool);
  pvVar3 = _objc_msgSend(pvVar3,sel_settingsForTool_);
  _objc_msgSend(pvVar3,sel_objectForKey_);
  pvVar3 = _objc_msgSend(cls_NSObject,sel_objectWithExtraDictionary_);
  self_00 = cls_NSAffineTransform;
  if (pvVar3 != (id)0x0) {
    _objc_msgSend_stret(&local_24,pvVar3,sel_bounds);
    pvVar4 = _objc_msgSend(self_00,sel_hyperTransitionFromRect_toRect_,local_24,local_1c,
                           CONCAT44(((fVar2 + fVar6) - (fVar6 * 0.5 + fVar2)) + fVar2,
                                    ((fVar1 + fVar5) - (fVar5 * 0.5 + fVar1)) + fVar1),
                           CONCAT44(fVar6,fVar5));
    _objc_msgSend(pvVar3,sel_transformUsingAffineTransform_,pvVar4);
  }
  return pvVar3;
}

*/
- (id)prototypePathForPreviewWithFrame:(NSRect)aFrame
{
    float halfWidth = aFrame.size.width * 0.5f;
    float halfHeight = aFrame.size.height * 0.5f;
    id settings = [[HSToolManager sharedToolManager] toolSettings];
    id toolSettings = [settings settingsForTool:[[HSToolManager sharedToolManager] currentTool]];
    NSBezierPath *path = [NSObject objectWithExtraDictionary:[toolSettings objectForKey:@"path"]];
    if (path != nil) {
        NSRect destination = NSMakeRect(NSZeroPoint.x + halfWidth - (halfWidth * 0.5f + NSZeroPoint.x) + NSZeroPoint.x, NSZeroPoint.y + halfHeight - (halfHeight * 0.5f + NSZeroPoint.y) + NSZeroPoint.y, halfWidth, halfHeight);
        [path transformUsingAffineTransform:[NSAffineTransform hyperTransitionFromRect:[path bounds] toRect:destination]];
    }
    return path;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001559f8 @ 001559f8, 239 bytes * /

void FUN_001559f8(HSDrawShapeToolSettingsViewController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar1 = _objc_msgSend(pvVar1,sel_toolSettings);
  pvVar1 = _objc_msgSend(pvVar1,sel_drawColor);
  pvVar1 = _objc_msgSend(self,sel_backgroundColorForPreviewColor_,pvVar1);
  pvVar2 = _objc_msgSend(self->_outlinePreview,sel_superview);
  _objc_msgSend(pvVar2,sel_setBackgroundColor_,pvVar1);
  pvVar2 = _objc_msgSend(self->_fillWithOutlinePreview,sel_superview);
  _objc_msgSend(pvVar2,sel_setBackgroundColor_,pvVar1);
  pvVar2 = _objc_msgSend(self->_outlineWithFillPreview,sel_superview);
  _objc_msgSend(pvVar2,sel_setBackgroundColor_,pvVar1);
  return;
}

*/
- (void)validateBackgroundColor
{
    id color = [self backgroundColorForPreviewColor:[[[HSToolManager sharedToolManager] toolSettings] drawColor]];
    [(id)[_outlinePreview superview] setBackgroundColor:color];
    [(id)[_fillWithOutlinePreview superview] setBackgroundColor:color];
    [(id)[_outlineWithFillPreview superview] setBackgroundColor:color];
}

- (void)refreshPreviews
{
    [self refreshToolPreview:_outlinePreview];
    [self refreshToolPreview:_outlineWithFillPreview];
    [self refreshToolPreview:_fillWithOutlinePreview];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00155e40 @ 00155e40, 1611 bytes * /

void FUN_00155e40(HSDrawShapeToolSettingsViewController *self,SEL _cmd,id refreshToolPreview)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  int *piVar7;
  float *pfVar8;
  float *pfVar9;
  longdouble lVar10;
  double dVar11;
  float afStack_f8 [4];
  undefined8 local_e8;
  float local_9c;
  undefined4 local_7c;
  undefined4 local_78;
  undefined4 local_74;
  undefined4 local_70;
  undefined8 local_6c;
  undefined8 local_64;
  undefined1 local_5c [16];
  undefined4 local_4c;
  int local_48;
  undefined4 local_44;
  undefined4 uStack_40;
  undefined4 local_3c;
  undefined4 uStack_38;
  undefined1 local_34 [8];
  int local_2c;
  int iStack_28;
  undefined8 local_24 [2];
  
  _objc_msgSend_stret(local_34,refreshToolPreview,sel_frame);
  pfVar9 = (float *)&stack0xffffff20;
  local_e8 = CONCAT44(0x155e9c,(undefined4)local_e8);
  pvVar2 = _objc_msgSend(self,sel_prototypePathForPreviewWithFrame_);
  if (pvVar2 == (id)0x0) {
    pvVar3 = (id)0x0;
  }
  else {
    local_e8 = CONCAT44(0x155ecd,(undefined4)local_e8);
    pvVar3 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
    local_e8 = CONCAT44(0x155ee1,(undefined4)local_e8);
    pvVar4 = _objc_msgSend(pvVar3,sel_toolSettings);
    local_e8 = CONCAT44(0x155ef5,(undefined4)local_e8);
    dVar11 = _objc_msgSend_fpret(pvVar4,sel_strokeWidth);
    local_e8 = CONCAT44(0x155f0d,(undefined4)local_e8);
    _objc_msgSend(pvVar3,sel_currentTool);
    local_e8 = CONCAT44(0x155f23,(undefined4)local_e8);
    pvVar3 = _objc_msgSend(pvVar4,sel_settingsForTool_);
    local_e8 = CONCAT44(0x155f3f,(undefined4)local_e8);
    pvVar3 = _objc_msgSend(pvVar3,sel_objectForKey_);
    local_e8 = CONCAT44(0x155f51,(undefined4)local_e8);
    pvVar3 = _objc_msgSend(pvVar3,sel_unsignedIntegerValue);
    local_9c = (float)dVar11;
    local_e8 = CONCAT44(0x155f7b,(undefined4)local_e8);
    _objc_msgSend_stret(&local_44,pvVar2,sel_bounds);
    piVar7 = (int *)((int)&local_e8 + 4);
    if (pvVar3 != (id)0x0) {
      local_e8 = CONCAT44(local_24,0x155ffb);
      _NSInsetRect();
      local_e8 = local_24[0];
      cVar1 = _NSIsEmptyRect();
      piVar7 = (int *)&local_e8;
      if (cVar1 != '\0') {
        local_e8 = CONCAT44(uStack_38,local_3c);
        lVar10 = (longdouble)_fminf();
        local_9c = (float)(((double)lVar10 + (double)lVar10) /
                           ((double)(ZEXT48(pvVar3) | 0x4330000000000000) - 4503599627370496.0) +
                          -0.0001);
        piVar7 = (int *)&local_e8;
      }
    }
    piVar7[2] = (int)local_9c;
    piVar7[1] = (int)sel_setLineWidth_;
    *piVar7 = (int)pvVar2;
    piVar7[-1] = 0x15608d;
    _objc_msgSend((id)*piVar7,(SEL)piVar7[1]);
    piVar7[1] = (int)sel_alloc;
    *piVar7 = (int)cls_NSImage;
    piVar7[-1] = 0x1560a5;
    pvVar3 = _objc_msgSend((id)*piVar7,(SEL)piVar7[1]);
    piVar7[3] = iStack_28;
    piVar7[2] = local_2c;
    piVar7[1] = (int)sel_initWithSize_;
    *piVar7 = (int)pvVar3;
    piVar7[-1] = 0x1560cd;
    pvVar3 = _objc_msgSend((id)*piVar7,(SEL)piVar7[1]);
    piVar7[1] = (int)sel_lockFocus;
    *piVar7 = (int)pvVar3;
    piVar7[-1] = 0x1560e5;
    _objc_msgSend((id)*piVar7,(SEL)piVar7[1]);
    piVar7[1] = (int)sel_currentContext;
    *piVar7 = (int)cls_NSGraphicsContext;
    piVar7[-1] = 0x1560fd;
    pvVar5 = _objc_msgSend((id)*piVar7,(SEL)piVar7[1]);
    piVar7[1] = (int)sel_graphicsPort;
    *piVar7 = (int)pvVar5;
    piVar7[-1] = 0x15610f;
    pvVar5 = _objc_msgSend((id)*piVar7,(SEL)piVar7[1]);
    piVar7[1] = (int)pvVar5;
    *piVar7 = (int)local_5c;
    piVar7[-1] = 0x156120;
    _CGContextGetCTM();
    pfVar8 = (float *)(piVar7 + -1);
    piVar7[1] = local_48;
    *piVar7 = local_4c;
    piVar7[-1] = (int)pvVar5;
    piVar7[-2] = 0x156141;
    _CGContextSetPatternPhase();
    *piVar7 = (int)sel_shouldFillShapes;
    piVar7[-1] = (int)pvVar4;
    piVar7[-2] = 0x156153;
    pvVar5 = _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    if ((char)pvVar5 != '\0') {
      *piVar7 = (int)sel_fillColor;
      piVar7[-1] = (int)pvVar4;
      piVar7[-2] = 0x15616d;
      pvVar5 = _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
      *piVar7 = (int)sel_hyperGradientColor;
      piVar7[-1] = (int)pvVar5;
      piVar7[-2] = 0x156181;
      pvVar6 = _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
      if (pvVar6 == (id)0x0) {
        *piVar7 = (int)sel_set;
        piVar7[-1] = (int)pvVar5;
        piVar7[-2] = 0x156197;
        _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
        *piVar7 = (int)sel_fill;
        pvVar5 = pvVar2;
        pfVar8 = (float *)(piVar7 + -1);
      }
      else {
        *piVar7 = (int)sel_currentContext;
        piVar7[-1] = (int)cls_NSGraphicsContext;
        piVar7[-2] = 0x1561c6;
        pvVar5 = _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
        *piVar7 = (int)sel_saveGraphicsState;
        piVar7[-1] = (int)pvVar5;
        piVar7[-2] = 0x1561d8;
        _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
        piVar7[1] = (int)sel_bounds;
        *piVar7 = (int)pvVar2;
        piVar7[-1] = (int)&local_6c;
        piVar7[-2] = 0x1561f7;
        _objc_msgSend_stret((void *)piVar7[-1],(id)*piVar7,(SEL)piVar7[1]);
        pfVar8 = (float *)(piVar7 + -2);
        piVar7[-1] = (int)sel_addClip;
        piVar7[-2] = (int)pvVar2;
        piVar7[-3] = 0x156212;
        _objc_msgSend((id)piVar7[-2],(SEL)piVar7[-1]);
        piVar7[-1] = (int)sel_hyperHSColor;
        piVar7[-2] = (int)pvVar6;
        piVar7[-3] = 0x156224;
        pvVar5 = _objc_msgSend((id)piVar7[-2],(SEL)piVar7[-1]);
        *(undefined8 *)(piVar7 + 6) = local_64;
        *(undefined8 *)(piVar7 + 4) = local_6c;
        *(undefined8 *)(piVar7 + 2) = local_64;
        *(undefined8 *)piVar7 = local_6c;
        piVar7[-1] = (int)sel_hyperDrawInRect_ofBounds_;
        piVar7[-2] = (int)pvVar5;
        piVar7[-3] = 0x156258;
        _objc_msgSend((id)piVar7[-2],(SEL)piVar7[-1]);
        piVar7[-1] = (int)sel_currentContext;
        piVar7[-2] = (int)cls_NSGraphicsContext;
        piVar7[-3] = 0x156270;
        pvVar5 = _objc_msgSend((id)piVar7[-2],(SEL)piVar7[-1]);
        piVar7[-1] = (int)sel_restoreGraphicsState;
      }
      *pfVar8 = (float)pvVar5;
      pfVar8[-1] = 1.963883e-39;
      _objc_msgSend((id)*pfVar8,(SEL)pfVar8[1]);
    }
    pfVar8[1] = (float)sel_shouldStrokeShapes;
    *pfVar8 = (float)pvVar4;
    pfVar8[-1] = 1.963909e-39;
    pvVar5 = _objc_msgSend((id)*pfVar8,(SEL)pfVar8[1]);
    pfVar9 = pfVar8;
    if ((char)pvVar5 != '\0') {
      pfVar8[1] = (float)sel_drawColor;
      *pfVar8 = (float)pvVar4;
      pfVar8[-1] = 1.963945e-39;
      pvVar4 = _objc_msgSend((id)*pfVar8,(SEL)pfVar8[1]);
      pfVar8[1] = (float)sel_hyperGradientColor;
      *pfVar8 = (float)pvVar4;
      pfVar8[-1] = 1.963973e-39;
      pvVar5 = _objc_msgSend((id)*pfVar8,(SEL)pfVar8[1]);
      if (pvVar5 == (id)0x0) {
        pfVar8[1] = (float)sel_set;
        *pfVar8 = (float)pvVar4;
        pfVar8[-1] = 1.964012e-39;
        _objc_msgSend((id)*pfVar8,(SEL)pfVar8[1]);
        pfVar8[1] = (float)sel_stroke;
      }
      else {
        pfVar8[1] = (float)sel_currentContext;
        *pfVar8 = (float)cls_NSGraphicsContext;
        pfVar8[-1] = 1.964075e-39;
        pvVar4 = _objc_msgSend((id)*pfVar8,(SEL)pfVar8[1]);
        pfVar8[1] = (float)sel_graphicsPort;
        *pfVar8 = (float)pvVar4;
        pfVar8[-1] = 1.9641e-39;
        pvVar4 = _objc_msgSend((id)*pfVar8,(SEL)pfVar8[1]);
        pfVar8[1] = (float)sel_hyperCGPath;
        *pfVar8 = (float)pvVar2;
        pfVar8[-1] = 1.964137e-39;
        pvVar2 = _objc_msgSend((id)*pfVar8,(SEL)pfVar8[1]);
        *(ulonglong *)(pfVar8 + 3) = CONCAT44(uStack_38,local_3c);
        *(ulonglong *)(pfVar8 + 1) = CONCAT44(uStack_40,local_44);
        pfVar8[6] = local_9c * -0.5;
        pfVar8[5] = local_9c * -0.5;
        *pfVar8 = (float)&local_7c;
        pfVar8[-1] = 1.964225e-39;
        _NSInsetRect();
        pfVar9 = pfVar8 + -1;
        local_44 = local_7c;
        uStack_40 = local_78;
        local_3c = local_74;
        uStack_38 = local_70;
        pfVar8[-1] = (float)pvVar4;
        pfVar8[-2] = 1.964297e-39;
        _CGContextBeginPath();
        if (pvVar2 != (id)0x0) {
          *pfVar8 = (float)pvVar2;
          pfVar8[-1] = (float)pvVar4;
          pfVar8[-2] = 1.964319e-39;
          _CGContextAddPath();
          pfVar8[-1] = (float)pvVar2;
          pfVar8[-2] = 1.96433e-39;
          _CGPathRelease();
        }
        *pfVar8 = local_9c;
        pfVar8[-1] = (float)pvVar4;
        pfVar8[-2] = 1.964361e-39;
        _CGContextSetLineWidth();
        pfVar8[-1] = (float)pvVar4;
        pfVar8[-2] = 1.964372e-39;
        _CGContextReplacePathWithStrokedPath();
        pfVar8[-1] = (float)pvVar4;
        pfVar8[-2] = 1.964384e-39;
        _CGContextClip();
        *pfVar8 = (float)sel_hyperHSColor;
        pfVar8[-1] = (float)pvVar5;
        pfVar8[-2] = 1.964417e-39;
        pvVar2 = _objc_msgSend((id)pfVar8[-1],(SEL)*pfVar8);
        *(ulonglong *)(pfVar8 + 8) = CONCAT44(uStack_38,local_3c);
        *(ulonglong *)(pfVar8 + 6) = CONCAT44(uStack_40,local_44);
        *(ulonglong *)(pfVar8 + 4) = CONCAT44(uStack_38,local_3c);
        *(ulonglong *)(pfVar8 + 2) = CONCAT44(uStack_40,local_44);
        pfVar8[1] = (float)pvVar4;
        *pfVar8 = (float)sel_drawGradientInCGContext_rect_ofBounds_;
      }
      *pfVar9 = (float)pvVar2;
      pfVar9[-1] = 1.964496e-39;
      _objc_msgSend((id)*pfVar9,(SEL)pfVar9[1]);
    }
    pfVar9[1] = (float)sel_unlockFocus;
    *pfVar9 = (float)pvVar3;
    pfVar9[-1] = 1.96453e-39;
    _objc_msgSend((id)*pfVar9,(SEL)pfVar9[1]);
  }
  pfVar9[2] = (float)pvVar3;
  pfVar9[1] = (float)sel_setImage_;
  *pfVar9 = (float)refreshToolPreview;
  pfVar9[-1] = 1.964573e-39;
  _objc_msgSend((id)*pfVar9,(SEL)pfVar9[1]);
  pfVar9[1] = (float)sel_release;
  *pfVar9 = (float)pvVar3;
  pfVar9[-1] = 1.964598e-39;
  _objc_msgSend((id)*pfVar9,(SEL)pfVar9[1]);
  return;
}

*/
- (void)refreshToolPreview:(id)aPreview
{
    NSRect frame = [aPreview frame];
    NSBezierPath *path = [self prototypePathForPreviewWithFrame:frame];
    NSImage *image = nil;
    if (path != nil) {
        id toolManager = [HSToolManager sharedToolManager];
        id settings = [toolManager toolSettings];
        float lineWidth = (float)[settings strokeWidth];
        NSUInteger adjustmentFactor = [[[settings settingsForTool:[toolManager currentTool]] objectForKey:@"dynamicStrokeWidthAdjustmentFactor"] unsignedIntegerValue];
        NSRect bounds = [path bounds];
        if (adjustmentFactor != 0) {
            float inset = (float)((double)lineWidth * 0.5 * (double)adjustmentFactor * 0.5);
            if (NSIsEmptyRect(NSInsetRect(bounds, inset, inset))) {
                lineWidth = (float)((double)fminf((float)bounds.size.width, (float)bounds.size.height) * 2.0 / (double)adjustmentFactor - 0.0001);
            }
        }
        [path setLineWidth:lineWidth];
        image = [[NSImage alloc] initWithSize:frame.size];
        [image lockFocus];
        CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
        CGAffineTransform ctm = CGContextGetCTM(context);
        CGContextSetPatternPhase(context, CGSizeMake(ctm.tx, ctm.ty));
        if ([settings shouldFillShapes]) {
            NSColor *fillColor = [settings fillColor];
            id gradient = [fillColor hyperGradientColor];
            if (gradient == nil) {
                [fillColor set];
                [path fill];
            }
            else {
                [[NSGraphicsContext currentContext] saveGraphicsState];
                NSRect pathBounds = [path bounds];
                [path addClip];
                [(HSColor *)[gradient hyperHSColor] hyperDrawInRect:pathBounds ofBounds:pathBounds];
                [[NSGraphicsContext currentContext] restoreGraphicsState];
            }
        }
        if ([settings shouldStrokeShapes]) {
            NSColor *drawColor = [settings drawColor];
            id gradient = [drawColor hyperGradientColor];
            if (gradient == nil) {
                [drawColor set];
                [path stroke];
            }
            else {
                CGContextRef strokeContext = [[NSGraphicsContext currentContext] graphicsPort];
                CGPathRef cgPath = [path hyperCGPath];
                NSRect strokeBounds = NSInsetRect(bounds, lineWidth * -0.5f, lineWidth * -0.5f);
                CGContextBeginPath(strokeContext);
                if (cgPath != NULL) {
                    CGContextAddPath(strokeContext, cgPath);
                    CGPathRelease(cgPath);
                }
                CGContextSetLineWidth(strokeContext, lineWidth);
                CGContextReplacePathWithStrokedPath(strokeContext);
                CGContextClip(strokeContext);
                [(HSColor *)[gradient hyperHSColor] drawGradientInCGContext:strokeContext rect:strokeBounds ofBounds:strokeBounds];
            }
        }
        [image unlockFocus];
    }
    [aPreview setImage:image];
    [image release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0015648b @ 0015648b, 362 bytes * /

void FUN_0015648b(HSDrawShapeToolSettingsViewController *self,SEL _cmd)

{
  undefined4 uVar1;
  id pvVar2;
  id pvVar3;
  longdouble lVar4;
  double dVar5;
  float fVar6;
  
  pvVar2 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar2 = _objc_msgSend(pvVar2,sel_toolSettings);
  dVar5 = _objc_msgSend_fpret(pvVar2,sel_strokeWidth);
  pvVar2 = self->_outlineWidthSlider;
  lVar4 = (longdouble)_HSLinearValueForSliderFromNonLinear(pvVar2,(float)dVar5);
  _objc_msgSend(pvVar2,sel_setFloatValue_,(float)lVar4);
  pvVar2 = self->_outlineWithFillWidthSlider;
  lVar4 = (longdouble)_HSLinearValueForSliderFromNonLinear(pvVar2,(float)dVar5);
  fVar6 = (float)lVar4;
  _objc_msgSend(pvVar2,sel_setFloatValue_,fVar6);
  pvVar2 = _objc_msgSend(self,sel_accessibilitySliderDescriptionValue);
  if (pvVar2 != (id)0x0) {
    pvVar2 = _objc_msgSend(self->_outlineWidthSlider,sel_cell,fVar6);
    pvVar3 = _objc_msgSend(self,sel_accessibilitySliderDescriptionValue);
    uVar1 = *(undefined4 *)PTR_0033653c;
    _objc_msgSend(pvVar2,sel_accessibilitySetOverrideValue_forAttribute_,pvVar3,uVar1);
    pvVar2 = _objc_msgSend(self->_outlineWithFillWidthSlider,sel_cell);
    pvVar3 = _objc_msgSend(self,sel_accessibilitySliderDescriptionValue);
    _objc_msgSend(pvVar2,sel_accessibilitySetOverrideValue_forAttribute_,pvVar3,uVar1);
  }
  return;
}

*/
- (void)updateLineWidthUIElements
{
    float strokeWidth = (float)[[[HSToolManager sharedToolManager] toolSettings] strokeWidth];
    [_outlineWidthSlider setFloatValue:HSLinearValueForSliderFromNonLinear(_outlineWidthSlider, strokeWidth)];
    [_outlineWithFillWidthSlider setFloatValue:HSLinearValueForSliderFromNonLinear(_outlineWithFillWidthSlider, strokeWidth)];
    if ([self accessibilitySliderDescriptionValue] != nil) {
        [[_outlineWidthSlider cell] accessibilitySetOverrideValue:[self accessibilitySliderDescriptionValue] forAttribute:NSAccessibilityDescriptionAttribute];
        [[_outlineWithFillWidthSlider cell] accessibilitySetOverrideValue:[self accessibilitySliderDescriptionValue] forAttribute:NSAccessibilityDescriptionAttribute];
    }
}

- (void)updateFillColorUIElements
{
    id pvVar1_3;

    pvVar1_3 = [[[HSToolManager sharedToolManager] toolSettings] fillColor];
    [_fillColorViewController setColor:pvVar1_3];
    [_fillWithOutlineColorViewController setColor:pvVar1_3];
}

- (void)updateOutlineColorUIElements
{
    id pvVar1_3;

    pvVar1_3 = [[[HSToolManager sharedToolManager] toolSettings] drawColor];
    [_outlineColorViewController setColor:pvVar1_3];
    [_outlinWithFillColorViewController setColor:pvVar1_3];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001565f5 @ 001565f5, 1028 bytes * /

void FUN_001565f5(HSDrawShapeToolSettingsViewController *self,SEL _cmd,
                 BOOL updateCurrentSettingsViewWithParentResize)

{
  id pvVar1;
  id pvVar2;
  undefined *puVar3;
  int *piVar4;
  int *piVar5;
  float fVar6;
  float afStack_b8 [6];
  undefined1 local_74 [16];
  undefined1 local_64 [12];
  float local_58;
  undefined1 local_54 [12];
  float local_48;
  undefined1 local_44 [12];
  float local_38;
  undefined8 local_34;
  undefined8 local_2c;
  undefined1 local_24 [8];
  float local_1c;
  
  piVar4 = (int *)&stack0xffffff64;
  pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar1 = _objc_msgSend(pvVar1,sel_toolSettings);
  pvVar1 = _objc_msgSend(pvVar1,sel_shouldStrokeShapes);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
    pvVar1 = _objc_msgSend(pvVar1,sel_toolSettings);
    pvVar1 = _objc_msgSend(pvVar1,sel_shouldFillShapes);
    if ((char)pvVar1 == '\0') {
      pvVar1 = self->_outlineSettingsView;
      piVar4 = (int *)&stack0xffffff64;
      goto LAB_0015680b;
    }
  }
  pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar1 = _objc_msgSend(pvVar1,sel_toolSettings);
  pvVar1 = _objc_msgSend(pvVar1,sel_shouldStrokeShapes);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
    pvVar1 = _objc_msgSend(pvVar1,sel_toolSettings);
    pvVar1 = _objc_msgSend(pvVar1,sel_shouldFillShapes);
    if ((char)pvVar1 != '\0') {
      pvVar1 = self->_fillSettingsView;
      piVar4 = (int *)&stack0xffffff64;
      goto LAB_0015680b;
    }
  }
  pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar1 = _objc_msgSend(pvVar1,sel_toolSettings);
  pvVar1 = _objc_msgSend(pvVar1,sel_shouldStrokeShapes);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
    pvVar1 = _objc_msgSend(pvVar1,sel_toolSettings);
    pvVar1 = _objc_msgSend(pvVar1,sel_shouldFillShapes);
    if ((char)pvVar1 != '\0') {
      pvVar1 = self->_fillAndOutlineSettingsTabView;
      _objc_msgSend_stret(local_74,pvVar1,sel_frame);
      piVar4 = (int *)&stack0xffffff60;
      _objc_msgSend(self->_fillAndOutlineSettingsTabView,sel_indexOfSelectedTab);
      _objc_msgSend(self->_fillAndOutlineSettingsTabView,sel_setFrameSize_);
      goto LAB_0015680b;
    }
  }
  pvVar1 = (id)0x0;
LAB_0015680b:
  pvVar2 = self->_currentSettingsView;
  if (pvVar2 != pvVar1) {
    piVar4[1] = (int)sel_removeFromSuperview;
    *piVar4 = (int)pvVar2;
    piVar4[-1] = 0x156828;
    _objc_msgSend((id)*piVar4,(SEL)piVar4[1]);
    self->_currentSettingsView = pvVar1;
    piVar4[1] = (int)sel_toolSettingsView;
    *piVar4 = (int)self;
    piVar4[-1] = 0x15683d;
    pvVar1 = _objc_msgSend((id)*piVar4,(SEL)piVar4[1]);
    piVar4[2] = (int)sel_frame;
    piVar4[1] = (int)pvVar1;
    *piVar4 = (int)local_64;
    piVar4[-1] = 0x156856;
    _objc_msgSend_stret((void *)*piVar4,(id)piVar4[1],(SEL)piVar4[2]);
    pvVar1 = self->_containerView;
    piVar4[1] = (int)sel_frame;
    *piVar4 = (int)pvVar1;
    piVar4[-1] = (int)local_54;
    piVar4[-2] = 0x15687f;
    _objc_msgSend_stret((void *)piVar4[-1],(id)*piVar4,(SEL)piVar4[1]);
    pvVar1 = self->_currentSettingsView;
    *piVar4 = (int)sel_frame;
    piVar4[-1] = (int)pvVar1;
    piVar4[-2] = (int)local_44;
    piVar4[-3] = 0x1568ad;
    _objc_msgSend_stret((void *)piVar4[-2],(id)piVar4[-1],(SEL)*piVar4);
    fVar6 = (local_58 - local_48) + local_38;
    pvVar1 = self->_currentSettingsView;
    pvVar2 = self->_containerView;
    piVar4[-1] = (int)sel_bounds;
    piVar4[-2] = (int)pvVar2;
    piVar4[-3] = (int)&local_34;
    piVar4[-4] = 0x1568de;
    _objc_msgSend_stret((void *)piVar4[-3],(id)piVar4[-2],(SEL)piVar4[-1]);
    piVar5 = piVar4 + -4;
    *(undefined8 *)piVar4 = local_2c;
    *(undefined8 *)(piVar4 + -2) = local_34;
    piVar4[-3] = (int)sel_setFrame_;
    piVar4[-4] = (int)pvVar1;
    piVar4[-5] = 0x156909;
    _objc_msgSend((id)piVar4[-4],(SEL)piVar4[-3]);
    pvVar1 = self->_containerView;
    piVar4[-2] = (int)self->_currentSettingsView;
    piVar4[-3] = (int)sel_addSubview_;
    piVar4[-4] = (int)pvVar1;
    piVar4[-5] = 0x156925;
    _objc_msgSend((id)piVar4[-4],(SEL)piVar4[-3]);
    if (updateCurrentSettingsViewWithParentResize == '\0') {
      piVar4[-3] = (int)sel_toolSettingsView;
      piVar4[-4] = (int)self;
      piVar4[-5] = 0x15695c;
      pvVar1 = _objc_msgSend((id)piVar4[-4],(SEL)piVar4[-3]);
      piVar4[-2] = (int)sel_frame;
      piVar4[-3] = (int)pvVar1;
      piVar4[-4] = (int)local_24;
      piVar4[-5] = 0x156975;
      _objc_msgSend_stret((void *)piVar4[-4],(id)piVar4[-3],(SEL)piVar4[-2]);
      piVar5 = piVar4 + -5;
      piVar4[-4] = (int)sel_toolSettingsView;
      piVar4[-5] = (int)self;
      piVar4[-6] = 0x156994;
      pvVar1 = _objc_msgSend((id)piVar4[-5],(SEL)piVar4[-4]);
      piVar4[-2] = (int)fVar6;
      puVar3 = sel_setFrameSize_;
    }
    else {
      piVar4[-3] = (int)sel_parent;
      piVar4[-4] = (int)self;
      piVar4[-5] = 0x15693d;
      pvVar1 = _objc_msgSend((id)piVar4[-4],(SEL)piVar4[-3]);
      puVar3 = sel_changeDrawerHeightTo_;
      local_1c = fVar6;
    }
    piVar5[2] = (int)local_1c;
    piVar5[1] = (int)puVar3;
    *piVar5 = (int)pvVar1;
    piVar5[-1] = 0x1569bc;
    _objc_msgSend((id)*piVar5,(SEL)piVar5[1]);
    pvVar1 = self->_shapeTypeControl;
    piVar5[2] = (int)self->_currentSettingsView;
    piVar5[1] = (int)sel_tagForSettingsView_;
    *piVar5 = (int)self;
    piVar5[-1] = 0x1569d8;
    pvVar2 = _objc_msgSend((id)*piVar5,(SEL)piVar5[1]);
    piVar5[2] = (int)pvVar2;
    piVar5[1] = (int)sel_selectCellWithTag_;
    *piVar5 = (int)pvVar1;
    piVar5[-1] = 0x1569ee;
    _objc_msgSend((id)*piVar5,(SEL)piVar5[1]);
  }
  return;
}

*/
- (void)updateCurrentSettingsViewWithParentResize:(BOOL)aResize
{
    id settings = [[HSToolManager sharedToolManager] toolSettings];
    BOOL stroke = [settings shouldStrokeShapes];
    BOOL fill = [settings shouldFillShapes];
    NSView *settingsView = nil;
    if (stroke && !fill) {
        settingsView = _outlineSettingsView;
    }
    else if (!stroke && fill) {
        settingsView = _fillSettingsView;
    }
    else if (stroke && fill) {
        NSRect tabFrame = [_fillAndOutlineSettingsTabView frame];
        NSInteger selectedTab = [_fillAndOutlineSettingsTabView indexOfSelectedTab];
        [_fillAndOutlineSettingsTabView setFrameSize:NSMakeSize(tabFrame.size.width, _tabHeights[selectedTab])];
        settingsView = _fillAndOutlineSettingsTabView;
    }
    if (_currentSettingsView == settingsView) {
        return;
    }
    [_currentSettingsView removeFromSuperview];
    _currentSettingsView = settingsView;
    NSRect toolSettingsFrame = [[self toolSettingsView] frame];
    NSRect containerFrame = [_containerView frame];
    NSRect currentFrame = [_currentSettingsView frame];
    float height = (toolSettingsFrame.size.height - containerFrame.size.height) + currentFrame.size.height;
    [_currentSettingsView setFrame:[_containerView bounds]];
    [_containerView addSubview:_currentSettingsView];
    if (aResize) {
        [[self parent] changeDrawerHeightTo:height];
    }
    else {
        NSRect frame = [[self toolSettingsView] frame];
        [[self toolSettingsView] setFrameSize:NSMakeSize(frame.size.width, height)];
    }
    [_shapeTypeControl selectCellWithTag:[self tagForSettingsView:_currentSettingsView]];
}

- (void)toolSettingsDidChange:(id)aChange
{
    [self updateLineWidthUIElements];
    [self refreshPreviews];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001569f9 @ 001569f9, 210 bytes * /

void FUN_001569f9(HSDrawShapeToolSettingsViewController *self,SEL _cmd,
                 id selectedTabDidChangeInCustomTabView)

{
  id pvVar1;
  float fVar2;
  undefined *puVar3;
  undefined1 local_2c [12];
  float local_20;
  undefined1 local_1c [12];
  float local_10;
  
  pvVar1 = _objc_msgSend(self,sel_toolSettingsView);
  puVar3 = sel_frame;
  _objc_msgSend_stret(local_2c,pvVar1,sel_frame);
  _objc_msgSend_stret(local_1c,self->_containerView,sel_frame,puVar3,local_20);
  fVar2 = local_20 - local_10;
  pvVar1 = _objc_msgSend(selectedTabDidChangeInCustomTabView,sel_indexOfSelectedTab);
  fVar2 = fVar2 + self->_tabHeights[(int)pvVar1];
  pvVar1 = _objc_msgSend(self,sel_parent);
  _objc_msgSend(pvVar1,sel_changeDrawerHeightTo_,fVar2);
  return;
}

*/
- (void)selectedTabDidChangeInCustomTabView:(id)aView
{
    NSRect toolSettingsFrame = [[self toolSettingsView] frame];
    NSRect containerFrame = [_containerView frame];
    float height = toolSettingsFrame.size.height - containerFrame.size.height;
    height += _tabHeights[[aView indexOfSelectedTab]];
    [[self parent] changeDrawerHeightTo:height];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00155753 @ 00155753, 242 bytes * /

void FUN_00155753(HSDrawShapeToolSettingsViewController *self,SEL _cmd,id colorViewController,
                 id changedColorTo)

{
  id pvVar1;
  SEL op;
  
  if ((self->_outlineColorViewController == colorViewController) ||
     (self->_outlinWithFillColorViewController == colorViewController)) {
    pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
    pvVar1 = _objc_msgSend(pvVar1,sel_toolSettings);
    _objc_msgSend(pvVar1,sel_setDrawColor_,changedColorTo);
    op = sel_updateOutlineColorUIElements;
  }
  else {
    if ((self->_fillColorViewController != colorViewController) &&
       (self->_fillWithOutlineColorViewController != colorViewController)) goto LAB_00155819;
    pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
    pvVar1 = _objc_msgSend(pvVar1,sel_toolSettings);
    _objc_msgSend(pvVar1,sel_setFillColor_,changedColorTo);
    op = sel_updateFillColorUIElements;
  }
  _objc_msgSend(self,op,changedColorTo);
LAB_00155819:
  _objc_msgSend(self,sel_refreshPreviews);
  _objc_msgSend(self,sel_validateBackgroundColor);
  return;
}

*/
- (void)colorViewController:(id)aController changedColorTo:(id)aTo
{
    if (_outlineColorViewController == aController || _outlinWithFillColorViewController == aController) {
        [[[HSToolManager sharedToolManager] toolSettings] setDrawColor:aTo];
        [self updateOutlineColorUIElements];
    }
    else if (_fillColorViewController == aController || _fillWithOutlineColorViewController == aController) {
        [[[HSToolManager sharedToolManager] toolSettings] setFillColor:aTo];
        [self updateFillColorUIElements];
    }
    [self refreshPreviews];
    [self validateBackgroundColor];
}

- (BOOL)shouldDisplayGradientsAndPattersForColorViewController:(id)aController
{
    return YES;
}

- (void)cornerRadiusChanged:(id)aChanged
{
    [self cornerRadiusSliderChangedValueTo:(float)[aChanged floatValue]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00156b0c @ 00156b0c, 112 bytes * /

void FUN_00156b0c(HSDrawShapeToolSettingsViewController *self,SEL _cmd,id lineWidthChanged)

{
  id pvVar1;
  longdouble lVar2;
  
  pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar1 = _objc_msgSend(pvVar1,sel_toolSettings);
  lVar2 = (longdouble)_HSNonLinearValueForSlider(lineWidthChanged);
  _objc_msgSend(pvVar1,sel_setStrokeWidth_,(float)(int)lVar2);
  return;
}

*/
- (void)lineWidthChanged:(id)aChanged
{
    [[[HSToolManager sharedToolManager] toolSettings] setStrokeWidth:(float)(int)HSNonLinearValueForSlider(aChanged)];
}

- (void)fillAndOutlineShapeTypeChosen:(id)aChosen
{
    _isUIValidationDisabled = YES;
    [[[HSToolManager sharedToolManager] toolSettings] setShouldFillShapes:YES];
    [[[HSToolManager sharedToolManager] toolSettings] setShouldStrokeShapes:YES];
    _isUIValidationDisabled = NO;
    [self updateCurrentSettingsViewWithParentResize:YES];
    [self updateLineWidthUIElements];
    [self updateUI];
}

- (void)fillShapeTypeChosen:(id)aChosen
{
    _isUIValidationDisabled = YES;
    [[[HSToolManager sharedToolManager] toolSettings] setShouldFillShapes:YES];
    [[[HSToolManager sharedToolManager] toolSettings] setShouldStrokeShapes:NO];
    _isUIValidationDisabled = NO;
    [self updateCurrentSettingsViewWithParentResize:YES];
    [self updateUI];
}

- (void)outlineShapeTypeChosen:(id)aChosen
{
    _isUIValidationDisabled = YES;
    [[[HSToolManager sharedToolManager] toolSettings] setShouldFillShapes:NO];
    [[[HSToolManager sharedToolManager] toolSettings] setShouldStrokeShapes:YES];
    _isUIValidationDisabled = NO;
    [self updateCurrentSettingsViewWithParentResize:YES];
    [self updateLineWidthUIElements];
    [self updateUI];
}

- (void)validateUserInterface
{
    [super validateUserInterface];
    [_outlineColorViewController validateUserInterface];
    [_fillColorViewController validateUserInterface];
    [_outlinWithFillColorViewController validateUserInterface];
    [_fillWithOutlineColorViewController validateUserInterface];
}

- (void)updateUI
{
    if (_isUIValidationDisabled == NO) {
        [self updateOutlineColorUIElements];
        [self updateFillColorUIElements];
        [self refreshPreviews];
        [_shapeTypeControl selectCellWithTag:[self tagForSettingsView:_currentSettingsView]];
        [self validateBackgroundColor];
    }
}

- (void)didMount
{
    [super didMount];
    [self updateLineWidthUIElements];
    [self updateUI];
}

- (void)willMount
{
    [self updateCurrentSettingsViewWithParentResize:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00156c66 @ 00156c66, 2200 bytes * /

void FUN_00156c66(HSDrawShapeToolSettingsViewController *self,SEL _cmd)

{
  undefined4 uVar1;
  undefined4 uVar2;
  undefined *puVar3;
  undefined *puVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  id pvVar8;
  float extraout_EDX;
  float extraout_EDX_00;
  undefined1 local_64 [8];
  undefined8 local_5c;
  undefined1 local_54 [8];
  undefined4 local_4c;
  undefined4 local_48;
  undefined1 local_44 [16];
  undefined1 local_34 [16];
  undefined1 local_24 [20];
  
  pvVar6 = self->_shapeTypeControl;
  pvVar5 = _objc_msgSend(cls_HSAssistantPaneControlBackgroundRenderer,sel_sharedBackgroundRenderer);
  _objc_msgSend(pvVar6,sel_setBackgroundRenderer_,pvVar5);
  pvVar6 = _objc_msgSend(self->_shapeTypeControl,sel_cellWithTag_,1);
  pvVar5 = _objc_msgSend(self,sel_shapeTypeControlOutlineImage);
  _objc_msgSend(pvVar6,sel_setImage_,pvVar5);
  pvVar6 = _objc_msgSend(self->_shapeTypeControl,sel_cellWithTag_,2);
  pvVar5 = _objc_msgSend(self,sel_shapeTypeControlFillImage);
  _objc_msgSend(pvVar6,sel_setImage_,pvVar5);
  pvVar6 = _objc_msgSend(self->_shapeTypeControl,sel_cellWithTag_,3);
  pvVar5 = _objc_msgSend(self,sel_shapeTypeControlFillWithOutlineImage);
  _objc_msgSend(pvVar6,sel_setImage_,pvVar5);
  _objc_msgSend(self->_outlineColorViewController,sel_setDelegate_,self);
  pvVar6 = _objc_msgSend(self->_outlineColorViewController,sel_colorView);
  _objc_msgSend_stret(local_64,self->_outlineColorContainerView,sel_bounds);
  _objc_msgSend(pvVar6,sel_setFrame_,local_64._0_4_,local_64._4_4_,local_5c);
  pvVar6 = self->_outlineColorContainerView;
  pvVar5 = _objc_msgSend(self->_outlineColorViewController,sel_colorView);
  _objc_msgSend(pvVar6,sel_addSubview_,pvVar5);
  pvVar6 = _objc_msgSend(self->_outlineColorViewController,sel_colorView);
  _objc_msgSend_stret(local_54,self->_outlineColorContainerView,sel_frame);
  _objc_msgSend(pvVar6,sel_setFrameSize_,local_4c,local_48);
  pvVar6 = _objc_msgSend(self->_outlineColorViewController,sel_crayonsView);
  _objc_msgSend(pvVar6,sel_setNeedsForceLayout_,1);
  _objc_msgSend(self->_fillColorViewController,sel_setDelegate_,self);
  pvVar6 = _objc_msgSend(self->_fillColorViewController,sel_colorView);
  _objc_msgSend(pvVar6,sel_setAutoresizingMask_,10);
  pvVar6 = _objc_msgSend(self->_fillColorViewController,sel_colorView);
  _objc_msgSend_stret(local_44,self->_fillColorContainerView,sel_bounds);
  _objc_msgSend(pvVar6,sel_setFrame_,(int)local_44._0_8_,SUB84(local_44._0_8_,4),(int)local_44._8_8_
                ,SUB84(local_44._8_8_,4));
  pvVar6 = self->_fillColorContainerView;
  pvVar5 = _objc_msgSend(self->_fillColorViewController,sel_colorView);
  _objc_msgSend(pvVar6,sel_addSubview_,pvVar5);
  pvVar6 = _objc_msgSend(self->_fillColorViewController,sel_crayonsView);
  _objc_msgSend(pvVar6,sel_setNeedsForceLayout_,1);
  _objc_msgSend(self->_outlinWithFillColorViewController,sel_setDelegate_,self);
  pvVar6 = _objc_msgSend(self->_outlinWithFillColorViewController,sel_colorView);
  _objc_msgSend_stret(local_34,self->_outlineWithFillColorContainerView,sel_bounds);
  _objc_msgSend(pvVar6,sel_setFrame_,(int)local_34._0_8_,SUB84(local_34._0_8_,4),(int)local_34._8_8_
                ,SUB84(local_34._8_8_,4));
  pvVar6 = self->_outlineWithFillColorContainerView;
  pvVar5 = _objc_msgSend(self->_outlinWithFillColorViewController,sel_colorView);
  _objc_msgSend(pvVar6,sel_addSubview_,pvVar5);
  pvVar6 = _objc_msgSend(self->_outlinWithFillColorViewController,sel_crayonsView);
  _objc_msgSend(pvVar6,sel_setNeedsForceLayout_,1);
  _objc_msgSend(self->_fillWithOutlineColorViewController,sel_setDelegate_,self);
  pvVar6 = _objc_msgSend(self->_fillWithOutlineColorViewController,sel_colorView);
  _objc_msgSend_stret(local_24,self->_fillWithOutlineColorContainerView,sel_bounds);
  _objc_msgSend(pvVar6,sel_setFrame_,(int)local_24._0_8_,SUB84(local_24._0_8_,4),(int)local_24._8_8_
                ,SUB84(local_24._8_8_,4));
  pvVar6 = self->_fillWithOutlineColorContainerView;
  pvVar5 = _objc_msgSend(self->_fillWithOutlineColorViewController,sel_colorView);
  _objc_msgSend(pvVar6,sel_addSubview_,pvVar5);
  pvVar6 = _objc_msgSend(self->_fillWithOutlineColorViewController,sel_crayonsView);
  _objc_msgSend(pvVar6,sel_setNeedsForceLayout_,1);
  _objc_msgSend(self->_fillAndOutlineSettingsTabView,sel_tabViewSizeForContentView_,
                self->_fillSettingsTabSubView);
  self->_tabHeights[0] = extraout_EDX;
  _objc_msgSend(self->_fillAndOutlineSettingsTabView,sel_tabViewSizeForContentView_,
                self->_outlineSettingsTabSubView);
  self->_tabHeights[1] = extraout_EDX_00;
  puVar4 = cls_NSDictionary;
  pvVar6 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar6 = _objc_msgSend(pvVar6,sel_localizedStringForKey_value_table_,&cfstr_tab,&cfstr_empty,0);
  puVar3 = cls_NSBundle;
  pvVar5 = _objc_msgSend(self,sel_class);
  pvVar5 = _objc_msgSend(puVar3,sel_bundleForClass_,pvVar5);
  pvVar5 = _objc_msgSend(pvVar5,sel_localizedStringForKey_value_table_,&cfstr_Fill_settings,
                         &cfstr_empty,&cfstr_ToolPalette);
  uVar1 = *(undefined4 *)PTR_00336374;
  uVar2 = *(undefined4 *)PTR_0033653c;
  pvVar7 = _objc_msgSend(puVar4,sel_dictionaryWithObjectsAndKeys_,pvVar5,uVar2,pvVar6,uVar1,0);
  puVar3 = cls_NSBundle;
  pvVar6 = self->_fillAndOutlineSettingsTabView;
  pvVar5 = self->_fillSettingsTabSubView;
  pvVar8 = _objc_msgSend(self,sel_class);
  pvVar8 = _objc_msgSend(puVar3,sel_bundleForClass_,pvVar8);
  pvVar8 = _objc_msgSend(pvVar8,sel_localizedStringForKey_value_table_,&cfstr_Fill,&cfstr_empty,
                         &cfstr_ToolPalette);
  _objc_msgSend(pvVar6,sel_addTabWithTitle_image_toolTip_accessibilityValues_contentView_,pvVar8,0,0
                ,pvVar7,pvVar5);
  puVar4 = cls_NSDictionary;
  pvVar6 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar6 = _objc_msgSend(pvVar6,sel_localizedStringForKey_value_table_,&cfstr_tab,&cfstr_empty,0);
  puVar3 = cls_NSBundle;
  pvVar5 = _objc_msgSend(self,sel_class);
  pvVar5 = _objc_msgSend(puVar3,sel_bundleForClass_,pvVar5);
  pvVar5 = _objc_msgSend(pvVar5,sel_localizedStringForKey_value_table_,&cfstr_Outline_settings,
                         &cfstr_empty,&cfstr_ToolPalette);
  pvVar7 = _objc_msgSend(puVar4,sel_dictionaryWithObjectsAndKeys_,pvVar5,uVar2,pvVar6,uVar1,0);
  puVar3 = cls_NSBundle;
  pvVar6 = self->_fillAndOutlineSettingsTabView;
  pvVar5 = self->_outlineSettingsTabSubView;
  pvVar8 = _objc_msgSend(self,sel_class);
  pvVar8 = _objc_msgSend(puVar3,sel_bundleForClass_,pvVar8);
  pvVar8 = _objc_msgSend(pvVar8,sel_localizedStringForKey_value_table_,&cfstr_Outline,&cfstr_empty,
                         &cfstr_ToolPalette);
  _objc_msgSend(pvVar6,sel_addTabWithTitle_image_toolTip_accessibilityValues_contentView_,pvVar8,0,0
                ,pvVar7,pvVar5);
  _objc_msgSend(self->_fillAndOutlineSettingsTabView,sel_setDelegate_,self);
  _objc_msgSend(self,sel_updateCurrentSettingsViewWithParentResize_,0);
  return;
}

*/
- (void)didLoadNib
{
    [_shapeTypeControl setBackgroundRenderer:[HSAssistantPaneControlBackgroundRenderer sharedBackgroundRenderer]];
    [[_shapeTypeControl cellWithTag:1] setImage:[self shapeTypeControlOutlineImage]];
    [[_shapeTypeControl cellWithTag:2] setImage:[self shapeTypeControlFillImage]];
    [[_shapeTypeControl cellWithTag:3] setImage:[self shapeTypeControlFillWithOutlineImage]];
    [_outlineColorViewController setDelegate:self];
    [[_outlineColorViewController colorView] setFrame:[_outlineColorContainerView bounds]];
    [_outlineColorContainerView addSubview:[_outlineColorViewController colorView]];
    [[_outlineColorViewController colorView] setFrameSize:[_outlineColorContainerView frame].size];
    [[_outlineColorViewController crayonsView] setNeedsForceLayout:YES];
    [_fillColorViewController setDelegate:self];
    [(NSView *)[_fillColorViewController colorView] setAutoresizingMask:10];
    [[_fillColorViewController colorView] setFrame:[_fillColorContainerView bounds]];
    [_fillColorContainerView addSubview:[_fillColorViewController colorView]];
    [[_fillColorViewController crayonsView] setNeedsForceLayout:YES];
    [_outlinWithFillColorViewController setDelegate:self];
    [[_outlinWithFillColorViewController colorView] setFrame:[_outlineWithFillColorContainerView bounds]];
    [_outlineWithFillColorContainerView addSubview:[_outlinWithFillColorViewController colorView]];
    [[_outlinWithFillColorViewController crayonsView] setNeedsForceLayout:YES];
    [_fillWithOutlineColorViewController setDelegate:self];
    [[_fillWithOutlineColorViewController colorView] setFrame:[_fillWithOutlineColorContainerView bounds]];
    [_fillWithOutlineColorContainerView addSubview:[_fillWithOutlineColorViewController colorView]];
    [[_fillWithOutlineColorViewController crayonsView] setNeedsForceLayout:YES];
    _tabHeights[0] = (float)[_fillAndOutlineSettingsTabView tabViewSizeForContentView:_fillSettingsTabSubView].height;
    _tabHeights[1] = (float)[_fillAndOutlineSettingsTabView tabViewSizeForContentView:_outlineSettingsTabSubView].height;
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *tabRole = [[NSBundle mainBundle] localizedStringForKey:@"tab" value:@"" table:nil];
    NSDictionary *fillValues = [NSDictionary dictionaryWithObjectsAndKeys:[bundle localizedStringForKey:@"Fill settings" value:@"" table:@"ToolPalette"], NSAccessibilityDescriptionAttribute, tabRole, NSAccessibilityRoleDescriptionAttribute, nil];
    [_fillAndOutlineSettingsTabView addTabWithTitle:[bundle localizedStringForKey:@"Fill" value:@"" table:@"ToolPalette"] image:nil toolTip:nil accessibilityValues:fillValues contentView:_fillSettingsTabSubView];
    tabRole = [[NSBundle mainBundle] localizedStringForKey:@"tab" value:@"" table:nil];
    NSDictionary *outlineValues = [NSDictionary dictionaryWithObjectsAndKeys:[bundle localizedStringForKey:@"Outline settings" value:@"" table:@"ToolPalette"], NSAccessibilityDescriptionAttribute, tabRole, NSAccessibilityRoleDescriptionAttribute, nil];
    [_fillAndOutlineSettingsTabView addTabWithTitle:[bundle localizedStringForKey:@"Outline" value:@"" table:@"ToolPalette"] image:nil toolTip:nil accessibilityValues:outlineValues contentView:_outlineSettingsTabSubView];
    [_fillAndOutlineSettingsTabView setDelegate:self];
    [self updateCurrentSettingsViewWithParentResize:NO];
}

- (id)nibName
{
    return @"DrawShapeToolSettings";
}

- (void)cornerRadiusSliderChangedValueTo:(CGFloat)aTo
{

}

- (id)accessibilitySliderDescriptionValue
{
    return nil;
}

- (id)shapeTypeControlFillWithOutlineImage
{
    return nil;
}

- (id)shapeTypeControlFillImage
{
    return nil;
}

- (id)shapeTypeControlOutlineImage
{
    return nil;
}

- (void)dealloc
{
    _currentSettingsView = nil;
    [_outlineColorContainerView release];
    [_fillColorContainerView release];
    [_outlineSettingsView release];
    [_cornerSettingsView release];
    [_fillAndOutlineSettingsTabView setDelegate:0];
    [_fillAndOutlineSettingsTabView release];
    [_fillSettingsTabSubView release];
    [_outlineSettingsTabSubView release];
    [_outlineColorViewController release];
    [_fillColorViewController release];
    [_outlineColorViewController release];
    [_fillColorViewController release];
    [_fillWithOutlineColorViewController release];
    [_outlinWithFillColorViewController release];
    [super dealloc];
}

@end

