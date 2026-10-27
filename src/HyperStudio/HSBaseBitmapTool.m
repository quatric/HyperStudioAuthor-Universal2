#import "HSBaseBitmapTool.h"

@implementation HSBaseBitmapTool

/* i386 ivar offsets: _bitmapToolViewProxy=0x10, _bitmapTool=0x14, _toolSettingsWrapper=0x18, _toolCanvasLayer=0x1c, _dragCardCanvasLayer=0x20, _obeysLayoutGuiding=0x24, _resetOnSave=0x24 */

+ (Class)settingsSerializationClass
{
    return [BTToolSettingsSerialization class];
}

+ (id)layerIdentifiersWithRootLayer:(id)aLayer
{
    return [aLayer bitmapToolsIdentifiers];
}

+ (id)toolsCanvasLayerWithRootLayer:(id)aLayer
{
    return [aLayer bitmapToolsCanvasLayer];
}

+ (Class)toolCanvasLayerClass
{
    return [HSBaseBitmapToolCanvasLayer class];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018d393 @ 0018d393, 198 bytes * /

void FUN_0018d393(HSBaseBitmapTool *self,SEL _cmd,NSSize setToolSize)

{
  undefined4 uVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar2 = _objc_msgSend(cls_NSDictionary,sel_extraDictionaryWithSize_,setToolSize.width,
                         setToolSize.height);
  pvVar3 = _objc_msgSend(self,sel_toolSettingsWrapper);
  uVar1 = *(undefined4 *)PTR_003366a0;
  _objc_msgSend(pvVar3,sel_setSetting_forKey_,pvVar2,uVar1);
  pvVar2 = self->_bitmapTool;
  pvVar3 = _objc_msgSend(self,sel_toolSettingsWrapper);
  pvVar3 = _objc_msgSend(pvVar3,sel_toolInputForKey_,uVar1);
  _objc_msgSend(pvVar2,sel_setValue_forInputKey_,pvVar3,uVar1);
  return;
}

*/
- (void)setToolSize:(NSSize)aSize
{
    [[self toolSettingsWrapper] setSetting:[NSDictionary extraDictionaryWithSize:aSize] forKey:kToolSizeKey];
    [_bitmapTool setValue:[[self toolSettingsWrapper] toolInputForKey:kToolSizeKey] forInputKey:kToolSizeKey];
}

- (id)toolSettings
{
    return [_toolSettingsWrapper settings];
}

- (id)toolSettingsWrapper
{
    id pvVar1;
    id pvVar1_5;

    pvVar1 = _toolSettingsWrapper;
    if (pvVar1 == nil) {
        pvVar1_5 = [[[[self class] settingsSerializationClass] alloc] init];
        _toolSettingsWrapper = pvVar1_5;
        [pvVar1_5 setDelegate:self];
        pvVar1 = _toolSettingsWrapper;
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018d56c @ 0018d56c, 67 bytes * /

CGAffineTransform *
FUN_0018d56c(CGAffineTransform *__return_storage_ptr__,HSBaseBitmapTool *self,SEL _cmd)

{
  id self_00;
  CGAffineTransform *extraout_EAX;
  
  self_00 = _objc_msgSend(self,sel_view);
  _objc_msgSend_stret(__return_storage_ptr__,self_00,sel_userSpaceToViewSpaceCGAffineTransform);
  return extraout_EAX;
}

*/
- (CGAffineTransform)imageToViewTransform
{
    return [[self view] userSpaceToViewSpaceCGAffineTransform];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018d5af @ 0018d5af, 161 bytes * /

NSRect * FUN_0018d5af(NSRect *__return_storage_ptr__,HSBaseBitmapTool *self,SEL _cmd,
                     NSRect convertImageRectToViewRect)

{
  float local_2c;
  float local_28;
  float local_24;
  float local_20;
  undefined8 local_1c;
  undefined8 local_14;
  undefined8 local_c;
  
  _objc_msgSend_stret(&local_1c,self,sel_imageToViewTransform);
  _CGRectApplyAffineTransform
            (&local_2c,convertImageRectToViewRect.origin,convertImageRectToViewRect.size,local_1c,
             local_14,local_c);
  (__return_storage_ptr__->origin).x = local_2c;
  (__return_storage_ptr__->origin).y = local_28;
  (__return_storage_ptr__->size).width = local_24;
  (__return_storage_ptr__->size).height = local_20;
  return __return_storage_ptr__;
}

*/
- (NSRect)convertImageRectToViewRect:(NSRect)aRect
{
    return NSRectFromCGRect(CGRectApplyAffineTransform(NSRectToCGRect(aRect), [self imageToViewTransform]));
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018d650 @ 0018d650, 136 bytes * /

ulonglong FUN_0018d650(HSBaseBitmapTool *self,SEL _cmd,NSPoint convertImagePointToViewPoint)

{
  float local_1c;
  float local_18;
  float local_14;
  float local_10;
  float local_c;
  float local_8;
  
  _objc_msgSend_stret(&local_1c,self,sel_imageToViewTransform);
  return CONCAT44(local_8 + local_18 * convertImagePointToViewPoint.x +
                            local_10 * convertImagePointToViewPoint.y,
                  local_c + local_1c * convertImagePointToViewPoint.x +
                            local_14 * convertImagePointToViewPoint.y);
}

*/
- (NSPoint)convertImagePointToViewPoint:(NSPoint)aPoint
{
    return NSPointFromCGPoint(CGPointApplyAffineTransform(NSPointToCGPoint(aPoint), [self imageToViewTransform]));
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018d6d8 @ 0018d6d8, 161 bytes * /

NSRect * FUN_0018d6d8(NSRect *__return_storage_ptr__,HSBaseBitmapTool *self,SEL _cmd,
                     NSRect convertViewRectToImageRect)

{
  float local_2c;
  float local_28;
  float local_24;
  float local_20;
  undefined8 local_1c;
  undefined8 local_14;
  undefined8 local_c;
  
  _objc_msgSend_stret(&local_1c,self,sel_viewToImageTransform);
  _CGRectApplyAffineTransform
            (&local_2c,convertViewRectToImageRect.origin,convertViewRectToImageRect.size,local_1c,
             local_14,local_c);
  (__return_storage_ptr__->origin).x = local_2c;
  (__return_storage_ptr__->origin).y = local_28;
  (__return_storage_ptr__->size).width = local_24;
  (__return_storage_ptr__->size).height = local_20;
  return __return_storage_ptr__;
}

*/
- (NSRect)convertViewRectToImageRect:(NSRect)aRect
{
    return NSRectFromCGRect(CGRectApplyAffineTransform(NSRectToCGRect(aRect), [self viewToImageTransform]));
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018d779 @ 0018d779, 136 bytes * /

ulonglong FUN_0018d779(HSBaseBitmapTool *self,SEL _cmd,NSPoint convertViewPointToImagePoint)

{
  float local_1c;
  float local_18;
  float local_14;
  float local_10;
  float local_c;
  float local_8;
  
  _objc_msgSend_stret(&local_1c,self,sel_viewToImageTransform);
  return CONCAT44(local_8 + local_18 * convertViewPointToImagePoint.x +
                            local_10 * convertViewPointToImagePoint.y,
                  local_c + local_1c * convertViewPointToImagePoint.x +
                            local_14 * convertViewPointToImagePoint.y);
}

*/
- (NSPoint)convertViewPointToImagePoint:(NSPoint)aPoint
{
    return NSPointFromCGPoint(CGPointApplyAffineTransform(NSPointToCGPoint(aPoint), [self viewToImageTransform]));
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018d801 @ 0018d801, 94 bytes * /

CGAffineTransform *
FUN_0018d801(CGAffineTransform *__return_storage_ptr__,HSBaseBitmapTool *self,SEL _cmd)

{
  CGAffineTransform *pCVar1;
  undefined8 local_1c;
  undefined8 local_14;
  undefined8 local_c;
  
  _objc_msgSend_stret(&local_1c,self,sel_imageToViewTransform);
  pCVar1 = (CGAffineTransform *)
           _CGAffineTransformInvert(__return_storage_ptr__,local_1c,local_14,local_c);
  return pCVar1;
}

*/
- (CGAffineTransform)viewToImageTransform
{
    return CGAffineTransformInvert([self imageToViewTransform]);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018d0fb @ 0018d0fb, 492 bytes * /

void FUN_0018d0fb(HSBaseBitmapTool *self,SEL _cmd,id SMKBitmapTools_showAppliedRules,
                 CGEParallelogram forSnappedParallelogram)

{
  float fVar1;
  id pvVar2;
  int iVar3;
  float fVar4;
  float fVar5;
  float fVar6;
  float fVar7;
  float fVar8;
  float local_2c [8];
  
  pvVar2 = _objc_msgSend(self->_toolCanvasLayer,sel_context);
  pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_00379f84);
  pvVar2 = _objc_msgSend(pvVar2,sel_layoutGuidingContext);
  local_2c[0] = 0.0;
  local_2c[1] = 0.0;
  local_2c[4] = forSnappedParallelogram.f0.width + 0.0;
  local_2c[5] = forSnappedParallelogram.f0.height + 0.0;
  local_2c[2] = forSnappedParallelogram.f0.width + 0.0;
  local_2c[3] = 0.0;
  local_2c[6] = 0.0;
  local_2c[7] = forSnappedParallelogram.f0.height + 0.0;
  fVar6 = 0.0;
  fVar7 = 0.0;
  iVar3 = 0;
  while( true ) {
    local_2c[iVar3 * 2] =
         forSnappedParallelogram.f1.a * fVar7 + forSnappedParallelogram.f1.c * fVar6 +
         forSnappedParallelogram.f1.tx;
    local_2c[iVar3 * 2 + 1] =
         fVar7 * forSnappedParallelogram.f1.b + fVar6 * forSnappedParallelogram.f1.d +
         forSnappedParallelogram.f1.ty;
    if (iVar3 == 3) break;
    fVar6 = local_2c[iVar3 * 2 + 3];
    fVar7 = local_2c[iVar3 * 2 + 2];
    iVar3 = iVar3 + 1;
  }
  fVar6 = local_2c[3];
  if (local_2c[1] <= local_2c[3]) {
    fVar6 = local_2c[1];
  }
  fVar7 = local_2c[2];
  fVar8 = local_2c[0];
  if (local_2c[0] <= local_2c[2]) {
    fVar7 = local_2c[0];
    fVar8 = local_2c[2];
  }
  fVar5 = local_2c[1];
  if (local_2c[1] <= local_2c[3]) {
    fVar5 = local_2c[3];
  }
  iVar3 = 0;
  do {
    fVar1 = local_2c[iVar3 * 2 + 4];
    fVar4 = fVar1;
    if ((fVar7 <= fVar1) && (fVar4 = fVar7, fVar8 < fVar1)) {
      fVar8 = fVar1;
    }
    fVar7 = local_2c[iVar3 * 2 + 5];
    fVar1 = fVar7;
    if ((fVar6 <= fVar7) && (fVar1 = fVar6, fVar5 < fVar7)) {
      fVar5 = fVar7;
    }
    fVar6 = fVar1;
    iVar3 = iVar3 + 1;
    fVar7 = fVar4;
  } while (iVar3 != 2);
  _objc_msgSend(pvVar2,sel_setAppliedLayoutGuidingRules_forSnappingRect_,
                SMKBitmapTools_showAppliedRules,CONCAT44(fVar6,fVar4),
                CONCAT44(fVar5 - fVar6,fVar8 - fVar4));
  _objc_msgSend(pvVar2,sel_showAppliedLayoutGuidingRules);
  return;
}

*/
- (void)SMKBitmapTools_showAppliedRules:(id)aRules forSnappedParallelogram:(struct CGEParallelogram)aParallelogram
{
    id context = [[[_toolCanvasLayer context] queryHyperInterface:@protocol(HSEditorCanvasLayerContext)] layoutGuidingContext];
    // Bounding box of the parallelogram's four transformed corners.
    CGRect bounds = CGRectApplyAffineTransform(CGRectMake(0.0, 0.0, aParallelogram.f0.width, aParallelogram.f0.height), aParallelogram.f1);
    [context setAppliedLayoutGuidingRules:aRules forSnappingRect:NSRectFromCGRect(bounds)];
    [context showAppliedLayoutGuidingRules];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018d03b @ 0018d03b, 192 bytes * /

void FUN_0018d03b(HSBaseBitmapTool *self,SEL _cmd,id SMKBitmapTools_showAppliedRules,
                 CGPoint forSnappedPoint)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self->_toolCanvasLayer,sel_context);
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00379f84);
  pvVar1 = _objc_msgSend(pvVar1,sel_layoutGuidingContext);
  _objc_msgSend(pvVar1,sel_setAppliedLayoutGuidingRules_forSnappingRect_,
                SMKBitmapTools_showAppliedRules,forSnappedPoint,0);
  _objc_msgSend(pvVar1,sel_showAppliedLayoutGuidingRules);
  return;
}

*/
- (void)SMKBitmapTools_showAppliedRules:(id)aRules forSnappedPoint:(CGPoint)aPoint
{
    id context = [[[_toolCanvasLayer context] queryHyperInterface:@protocol(HSEditorCanvasLayerContext)] layoutGuidingContext];
    [context setAppliedLayoutGuidingRules:aRules forSnappingRect:NSMakeRect(aPoint.x, aPoint.y, 0.0, 0.0)];
    [context showAppliedLayoutGuidingRules];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018cf98 @ 0018cf98, 163 bytes * /

void FUN_0018cf98(HSBaseBitmapTool *self,SEL _cmd,id showAppliedRules)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self->_toolCanvasLayer,sel_context);
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00379f84);
  pvVar1 = _objc_msgSend(pvVar1,sel_layoutGuidingContext);
  _objc_msgSend(pvVar1,sel_setAppliedLayoutGuidingRules_forSnappingRect_,showAppliedRules,
                *(undefined8 *)PTR_00336078,*(undefined8 *)(PTR_00336078 + 8));
  _objc_msgSend(pvVar1,sel_showAppliedLayoutGuidingRules);
  return;
}

*/
- (void)showAppliedRules:(id)aRules
{
    id context = [[[_toolCanvasLayer context] queryHyperInterface:@protocol(HSEditorCanvasLayerContext)] layoutGuidingContext];
    [context setAppliedLayoutGuidingRules:aRules forSnappingRect:NSZeroRect];
    [context showAppliedLayoutGuidingRules];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018d85f @ 0018d85f, 2197 bytes * /

BOOL FUN_0018d85f(HSBaseBitmapTool *self,SEL _cmd,id snapPoints,id sizes,id withEvent,id options,
                 CGPoint *snappedReflectedPoint,float *snapDistance,id *appliedRules)

{
  float fVar1;
  float fVar2;
  float fVar3;
  float fVar4;
  bool bVar5;
  bool bVar6;
  undefined *puVar7;
  id pvVar8;
  id pvVar9;
  id self_00;
  id pvVar10;
  id pvVar11;
  id pvVar12;
  float extraout_EDX;
  float extraout_EDX_00;
  float extraout_EDX_01;
  float extraout_EDX_02;
  float extraout_EDX_03;
  float extraout_EDX_04;
  id extraout_EDX_05;
  float *pfVar13;
  float *pfVar14;
  longdouble lVar15;
  float fVar16;
  double dVar17;
  double dVar18;
  double dVar19;
  double dVar20;
  float afStack_e4 [2];
  id local_98;
  id local_94;
  float local_8c;
  float local_88;
  id local_50;
  float local_30;
  id local_2c;
  float local_28;
  undefined4 local_24;
  undefined4 local_20;
  float local_1c;
  float local_18;
  float local_14;
  
  pfVar14 = (float *)&stack0xffffff24;
  pvVar8 = _objc_msgSend(self->_toolCanvasLayer,sel_context);
  pvVar8 = _objc_msgSend(pvVar8,sel_queryHyperInterface_);
  pvVar8 = _objc_msgSend(pvVar8,sel_layoutGuidingContext);
  pvVar9 = _objc_msgSend(pvVar8,sel_isSnappingEnabled);
  if ((char)pvVar9 != '\0') {
    pvVar9 = _objc_msgSend(cls_NSMutableArray,sel_array);
    self_00 = _objc_msgSend(snapPoints,sel_objectEnumerator);
    local_50 = _objc_msgSend(self_00,sel_nextObject);
    puVar7 = PTR_0033607c;
    if (local_50 == (id)0x0) {
      local_8c = INFINITY;
      local_98 = (id)0x7fc00000;
      local_94 = local_98;
    }
    else {
      local_98 = (id)0x7fc00000;
      local_8c = INFINITY;
      pfVar13 = (float *)&stack0xffffff24;
      local_94 = local_98;
      do {
        pfVar13[1] = (float)sel_minXBound;
        *pfVar13 = (float)local_50;
        pfVar13[-1] = 2.282233e-39;
        dVar17 = _objc_msgSend_fpret((id)*pfVar13,(SEL)pfVar13[1]);
        pfVar13[1] = (float)sel_minYBound;
        *pfVar13 = (float)local_50;
        pfVar13[-1] = 2.282267e-39;
        dVar18 = _objc_msgSend_fpret((id)*pfVar13,(SEL)pfVar13[1]);
        pfVar13[1] = (float)sel_maxXBound;
        *pfVar13 = (float)local_50;
        pfVar13[-1] = 2.2823e-39;
        dVar19 = _objc_msgSend_fpret((id)*pfVar13,(SEL)pfVar13[1]);
        pfVar13[1] = (float)sel_maxYBound;
        *pfVar13 = (float)local_50;
        pfVar13[-1] = 2.282334e-39;
        dVar20 = _objc_msgSend_fpret((id)*pfVar13,(SEL)pfVar13[1]);
        pfVar13[1] = (float)sel_point;
        *pfVar13 = (float)local_50;
        pfVar13[-1] = 2.282368e-39;
        pvVar10 = _objc_msgSend((id)*pfVar13,(SEL)pfVar13[1]);
        pfVar13[2] = (float)sel_trajectoryLine;
        pfVar13[1] = (float)local_50;
        *pfVar13 = (float)&local_1c;
        fVar1 = (float)dVar17;
        fVar2 = (float)dVar19;
        fVar3 = (float)dVar18;
        fVar4 = (float)dVar20;
        bVar5 = fVar1 < fVar2;
        bVar6 = fVar3 < fVar4;
        pfVar13[-1] = 2.282539e-39;
        _objc_msgSend_stret((void *)*pfVar13,(id)pfVar13[1],(SEL)pfVar13[2]);
        pfVar14 = pfVar13 + -1;
        local_88 = extraout_EDX;
        pvVar12 = pvVar10;
        if ((((local_1c != 0.0) || (NAN(local_1c))) || (local_18 != 0.0)) || (NAN(local_18))) {
          if (fVar1 < fVar2) {
            if (local_1c == 0.0) {
              local_88 = -(local_1c * 0.0 + local_14) / local_18;
              bVar5 = true;
            }
            else {
              bVar5 = false;
            }
          }
          if (fVar3 < fVar4) {
            if (local_18 == 0.0) {
              bVar6 = true;
              pvVar12 = (id)(-(local_18 * 0.0 + local_14) / local_1c);
            }
            else {
              bVar6 = false;
            }
          }
          if (bVar6 || bVar5) goto LAB_0018db30;
        }
        else {
LAB_0018db30:
          *pfVar13 = (float)sel_view;
          pfVar13[-1] = (float)self;
          pfVar13[-2] = 2.282711e-39;
          pvVar11 = _objc_msgSend((id)pfVar13[-1],(SEL)*pfVar13);
          pfVar13[2] = local_88;
          pfVar13[1] = (float)pvVar12;
          *pfVar13 = (float)sel_convertPointFromViewSpaceToUserSpace_;
          pfVar13[-1] = (float)pvVar11;
          pfVar13[-2] = 2.28278e-39;
          local_2c = _objc_msgSend((id)pfVar13[-1],(SEL)*pfVar13);
          local_28 = extraout_EDX_00;
          local_24 = *(undefined4 *)puVar7;
          local_20 = *(undefined4 *)(puVar7 + 4);
          local_30 = 0.0;
          *pfVar13 = (float)sel_layoutGuidingProcessor;
          pfVar13[-1] = (float)pvVar8;
          pfVar13[-2] = 2.282867e-39;
          pvVar12 = _objc_msgSend((id)pfVar13[-1],(SEL)*pfVar13);
          pfVar13[5] = (float)&local_30;
          fVar16 = (float)(bVar5 + 2);
          if (!bVar6) {
            fVar16 = (float)(uint)bVar5;
          }
          pfVar13[2] = fVar16;
          pfVar13[1] = (float)&local_2c;
          *pfVar13 = (float)sel_snapRect_edges_transformationDirectionHint_appliedRules_;
          pfVar13[-1] = (float)pvVar12;
          pfVar13[4] = 0.0;
          pfVar13[3] = 0.0;
          pfVar13[-2] = 2.282967e-39;
          pvVar12 = _objc_msgSend((id)pfVar13[-1],(SEL)*pfVar13);
          if ((char)pvVar12 != '\0') {
            pfVar13[2] = local_28;
            pfVar13[1] = (float)local_2c;
            *pfVar13 = (float)sel_convertPointFromUserSpaceToViewSpace_;
            pfVar13[-1] = (float)pvVar11;
            pfVar13[-2] = 2.283043e-39;
            local_2c = _objc_msgSend((id)pfVar13[-1],(SEL)*pfVar13);
            local_28 = extraout_EDX_01;
            *pfVar13 = (float)sel_options;
            pfVar13[-1] = (float)local_50;
            pfVar13[-2] = 2.283081e-39;
            pvVar12 = _objc_msgSend((id)pfVar13[-1],(SEL)*pfVar13);
            pfVar13[1] = (float)&cfstr_BTPointSnapSourceOptionSnapAsDevicePixelCenter;
            *pfVar13 = (float)sel_objectForKey_;
            pfVar13[-1] = (float)pvVar12;
            pfVar13[-2] = 2.28312e-39;
            pvVar12 = _objc_msgSend((id)pfVar13[-1],(SEL)*pfVar13);
            *pfVar13 = (float)sel_boolValue;
            pfVar13[-1] = (float)pvVar12;
            pfVar13[-2] = 2.283145e-39;
            pvVar12 = _objc_msgSend((id)pfVar13[-1],(SEL)*pfVar13);
            if ((char)pvVar12 != '\0') {
              pfVar13[2] = local_28;
              pfVar13[1] = (float)local_2c;
              *pfVar13 = (float)sel_convertPoint_toView_;
              pfVar13[-1] = (float)pvVar11;
              pfVar13[3] = 0.0;
              pfVar13[-2] = 2.283232e-39;
              pvVar12 = _objc_msgSend((id)pfVar13[-1],(SEL)*pfVar13);
              pfVar13[-1] = (float)pvVar12;
              pfVar13[-2] = 2.283249e-39;
              lVar15 = (longdouble)_roundf();
              fVar16 = (float)lVar15;
              if (((float)pvVar12 < fVar16 + -0.01) || (fVar16 + 0.01 < (float)pvVar12)) {
                bVar5 = false;
              }
              else {
                pvVar12 = (id)(fVar16 + 0.5);
                bVar5 = true;
              }
              pfVar13[-1] = extraout_EDX_02;
              pfVar13[-2] = 2.283618e-39;
              lVar15 = (longdouble)_roundf();
              fVar16 = (float)lVar15;
              if ((extraout_EDX_02 < fVar16 + -0.01) || (fVar16 + 0.01 < extraout_EDX_02)) {
                fVar16 = extraout_EDX_02;
                if (!bVar5) goto LAB_0018de44;
              }
              else {
                fVar16 = fVar16 + -0.5;
              }
              pfVar13[2] = fVar16;
              pfVar13[1] = (float)pvVar12;
              *pfVar13 = (float)sel_convertPoint_fromView_;
              pfVar13[-1] = (float)pvVar11;
              pfVar13[3] = 0.0;
              pfVar13[-2] = 2.283777e-39;
              local_2c = _objc_msgSend((id)pfVar13[-1],(SEL)*pfVar13);
              local_28 = extraout_EDX_03;
            }
LAB_0018de44:
            if ((((fVar1 <= (float)local_2c) && (fVar3 <= local_28)) && ((float)local_2c <= fVar2))
               && (local_28 <= fVar4)) {
              pfVar13[2] = extraout_EDX;
              pfVar13[1] = (float)pvVar10;
              *pfVar13 = (float)sel_reflectedPointForPoint_;
              pfVar13[-1] = (float)local_50;
              pfVar13[-2] = 2.283944e-39;
              pvVar12 = _objc_msgSend((id)pfVar13[-1],(SEL)*pfVar13);
              pfVar13[2] = local_28;
              pfVar13[1] = (float)local_2c;
              *pfVar13 = (float)sel_reflectedPointForPoint_;
              pfVar13[-1] = (float)local_50;
              pfVar13[-2] = 2.284016e-39;
              pvVar10 = _objc_msgSend((id)pfVar13[-1],(SEL)*pfVar13);
              *pfVar13 = extraout_EDX_04 - (float)extraout_EDX_05;
              pfVar13[-1] = (float)pvVar12 - (float)pvVar10;
              pfVar13[-2] = 2.284087e-39;
              lVar15 = (longdouble)_hypotf();
              fVar1 = (float)lVar15;
              if (local_8c <= fVar1 + 0.001) {
                if ((((fVar1 + -0.001 <= local_8c) && ((float)pvVar10 + -0.001 <= (float)local_94))
                    && (((float)local_94 <= (float)pvVar10 + 0.001 &&
                        (((float)extraout_EDX_05 + -0.001 <= (float)local_98 &&
                         ((float)local_98 <= (float)extraout_EDX_05 + 0.001)))))) &&
                   (local_30 != 0.0)) {
                  pfVar13[1] = local_30;
                  *pfVar13 = (float)sel_addObjectsFromArray_;
                  pfVar13[-1] = (float)pvVar9;
                  pfVar13[-2] = 2.28449e-39;
                  _objc_msgSend((id)pfVar13[-1],(SEL)*pfVar13);
                }
              }
              else {
                local_98 = extraout_EDX_05;
                local_94 = pvVar10;
                local_8c = fVar1;
                if (local_30 != 0.0) {
                  pfVar13[1] = local_30;
                  *pfVar13 = (float)sel_setArray_;
                  pfVar13[-1] = (float)pvVar9;
                  pfVar13[-2] = 2.284245e-39;
                  _objc_msgSend((id)pfVar13[-1],(SEL)*pfVar13);
                }
              }
            }
          }
        }
        *pfVar13 = (float)sel_nextObject;
        pfVar13[-1] = (float)self_00;
        pfVar13[-2] = 2.282188e-39;
        local_50 = _objc_msgSend((id)pfVar13[-1],(SEL)*pfVar13);
        pfVar13 = pfVar13 + -1;
      } while (local_50 != (id)0x0);
      if (NAN(local_8c)) {
        return '\0';
      }
    }
    if (ABS(local_8c) < INFINITY) {
      if (snappedReflectedPoint != (CGPoint *)0x0) {
        snappedReflectedPoint->x = (float)local_94;
        snappedReflectedPoint->y = (float)local_98;
      }
      if (snapDistance != (float *)0x0) {
        *snapDistance = local_8c;
      }
      if (appliedRules != (id *)0x0) {
        pfVar14[1] = (float)sel_copy;
        *pfVar14 = (float)pvVar9;
        pfVar14[-1] = 2.284708e-39;
        pvVar8 = _objc_msgSend((id)*pfVar14,(SEL)pfVar14[1]);
        pfVar14[1] = (float)sel_autorelease;
        *pfVar14 = (float)pvVar8;
        pfVar14[-1] = 2.284733e-39;
        pvVar8 = _objc_msgSend((id)*pfVar14,(SEL)pfVar14[1]);
        *appliedRules = pvVar8;
        return '\x01';
      }
      return '\x01';
    }
  }
  return '\0';
}

*/
- (BOOL)snapPoints:(id)aPoints sizes:(id)aSizes withEvent:(id)aEvent options:(id)aOptions snappedReflectedPoint:(CGPoint *)aPoint snapDistance:(float *)aDistance appliedRules:(id *)aRules
{
    id context = [[[_toolCanvasLayer context] queryHyperInterface:@protocol(HSEditorCanvasLayerContext)] layoutGuidingContext];
    if (![context isSnappingEnabled]) {
        return NO;
    }
    NSMutableArray *allRules = [NSMutableArray array];
    NSEnumerator *enumerator = [aPoints objectEnumerator];
    float bestDistance = INFINITY;
    CGPoint bestPoint = CGPointMake(NAN, NAN);
    id<BTPointSnapSource, BTPointToPointReflecting> source;

    while ((source = [enumerator nextObject]) != nil) {
        float minX = (float)[source minXBound];
        float minY = (float)[source minYBound];
        float maxX = (float)[source maxXBound];
        float maxY = (float)[source maxYBound];
        CGPoint point = [source point];
        CGELine line = [source trajectoryLine];
        BOOL snapX = minX < maxX;
        BOOL snapY = minY < maxY;
        CGPoint start = point;

        if (line.a != 0.0 || line.b != 0.0) {
            // Along a trajectory only axis-aligned lines can be snapped: a horizontal
            // line frees x, a vertical one frees y.
            if (snapX) {
                if (line.a == 0.0) {
                    start.y = -(line.a * 0.0 + line.c) / line.b;
                }
                else {
                    snapX = NO;
                }
            }
            if (snapY) {
                if (line.b == 0.0) {
                    start.x = -(line.b * 0.0 + line.c) / line.a;
                }
                else {
                    snapY = NO;
                }
            }
            if (!snapX && !snapY) {
                continue;
            }
        }
        id view = [self view];
        NSRect rect;
        rect.origin = [view convertPointFromViewSpaceToUserSpace:NSPointFromCGPoint(start)];
        rect.size = NSZeroSize;
        id rules = nil;
        if (![[context layoutGuidingProcessor] snapRect:&rect edges:(snapY ? snapX + 2 : snapX) transformationDirectionHint:NSZeroSize appliedRules:&rules]) {
            continue;
        }
        NSPoint snapped = [view convertPointFromUserSpaceToViewSpace:rect.origin];
        if ([[[source options] objectForKey:@"BTPointSnapSourceOptionSnapAsDevicePixelCenter"] boolValue]) {
            NSPoint device = [view convertPoint:snapped toView:nil];
            BOOL adjusted = NO;
            float x = (float)device.x;
            float y = (float)device.y;
            float rounded = roundf(x);
            if (x >= rounded - 0.01f && x <= rounded + 0.01f) {
                x = rounded + 0.5f;
                adjusted = YES;
            }
            rounded = roundf(y);
            if (y >= rounded - 0.01f && y <= rounded + 0.01f) {
                y = rounded - 0.5f;
                adjusted = YES;
            }
            if (adjusted) {
                snapped = [view convertPoint:NSMakePoint(x, y) fromView:nil];
            }
        }
        if (minX > snapped.x || minY > snapped.y || snapped.x > maxX || snapped.y > maxY) {
            continue;
        }
        CGPoint originalReflected = [source reflectedPointForPoint:point];
        CGPoint snappedReflected = [source reflectedPointForPoint:NSPointToCGPoint(snapped)];
        float distance = hypotf((float)(originalReflected.x - snappedReflected.x), (float)(originalReflected.y - snappedReflected.y));
        if (bestDistance > distance + 0.001f) {
            if (rules != nil) {
                [allRules setArray:rules];
            }
            bestPoint = snappedReflected;
            bestDistance = distance;
        }
        else if (bestDistance >= distance - 0.001f
                 && bestPoint.x >= snappedReflected.x - 0.001f && bestPoint.x <= snappedReflected.x + 0.001f
                 && bestPoint.y >= snappedReflected.y - 0.001f && bestPoint.y <= snappedReflected.y + 0.001f
                 && rules != nil) {
            [allRules addObjectsFromArray:rules];
        }
    }
    if (isnan(bestDistance) || fabsf(bestDistance) >= INFINITY) {
        return NO;
    }
    if (aPoint != NULL) {
        *aPoint = bestPoint;
    }
    if (aDistance != NULL) {
        *aDistance = bestDistance;
    }
    if (aRules != NULL) {
        *aRules = [[allRules copy] autorelease];
    }
    return YES;
}

- (id)layoutGuidingContextForTool:(id)aTool
{
    BOOL pvVar1;
    HSBaseBitmapTool *pHVar2;

    if (_bitmapTool == aTool) {
        pvVar1 = [self obeysLayoutGuiding];
        pHVar2 = nil;
        if (pvVar1) {
            pHVar2 = self;
        }
    }
    else {
        pHVar2 = nil;
    }
    return pHVar2;
}

- (id)mouseTrackingDelegateForTool:(id)aTool
{
    return nil;
}

- (id)imageViewTransformerForTool:(id)aTool
{
    if (_bitmapTool != aTool) {
        self = nil;
    }
    return self;
}

- (id)tool:(id)aTool willSetUndoActionName:(id)aName
{
    return nil;
}

- (void)tool:(id)aTool willRegisterUndoInManager:(id)aManager category:(id)aCategory
{

}

- (id)undoManagerForTool:(id)aTool category:(id)aCategory
{
    return nil;
}

- (BOOL)tool:(id)aTool didFinalizeStage:(id)aStage withEvent:(id)aEvent nextStage:(id)aStage2
{
    return NO;
}

- (void)tool:(id)aTool didFinalizeOutputForKey:(id)aKey
{

}

- (void)tool:(id)aTool didUpdateOutputForKey:(id)aKey
{

}

- (void)tool:(id)aTool willUpdateOutputForKey:(id)aKey
{

}

- (void)tool:(id)aTool didReplaceImageWithEffectiveChangeInRect:(NSRect)aRect
{

}

- (void)tool:(id)aTool willReplaceImageWithEffectiveChangeInRect:(NSRect)aRect
{

}

- (void)tool:(id)aTool didChangeImageInRect:(NSRect)aRect
{

}

- (void)tool:(id)aTool willChangeImageInRect:(NSRect)aRect
{

}

- (void)toolDidEndChangingImageContinuously:(id)aContinuously
{

}

- (void)toolWillBeginChangingImageContinuously:(id)aContinuously
{

}

- (void)tool:(id)aTool didUpdateCursorWithEvent:(id)aEvent
{
    if (_bitmapTool == aTool) {
        [self HSBitmapTool_updateCursorWithEvent:aEvent];
    }
}

- (id)extraDictionaryRepresentationWithCodingContext:(id)aContext
{
    return [[self toolSettingsWrapper] extraDictionaryRepresentationWithCodingContext:aContext];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018cdaf @ 0018cdaf, 309 bytes * /

void FUN_0018cdaf(HSBaseBitmapTool *self,SEL _cmd,id loadExtraDictionaryRepresentation,
                 id withCodingContext)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  
  pvVar1 = _objc_msgSend(self,sel_toolSettingsWrapper);
  _objc_msgSend(pvVar1,sel_loadExtraDictionaryRepresentation_withCodingContext_,
                loadExtraDictionaryRepresentation,withCodingContext);
  pvVar1 = _objc_msgSend(self,sel_toolSettingsWrapper);
  pvVar1 = _objc_msgSend(pvVar1,sel_toolInputs);
  self_00 = _objc_msgSend(pvVar1,sel_keyEnumerator);
  pvVar1 = _objc_msgSend(self_00,sel_nextObject);
  while (pvVar4 = pvVar1, pvVar4 != (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_toolSettingsWrapper,loadExtraDictionaryRepresentation,
                           withCodingContext);
    pvVar2 = _objc_msgSend(pvVar1,sel_toolInputForKey_,pvVar4);
    pvVar1 = self->_bitmapTool;
    pvVar3 = _objc_msgSend(cls_NSNull,sel_null);
    loadExtraDictionaryRepresentation = (id)0x0;
    if (pvVar2 != pvVar3) {
      loadExtraDictionaryRepresentation = pvVar2;
    }
    _objc_msgSend(pvVar1,sel_setValue_forInputKey_,loadExtraDictionaryRepresentation,pvVar4);
    pvVar1 = _objc_msgSend(self_00,sel_nextObject);
    withCodingContext = pvVar4;
  }
  return;
}

*/
- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext
{
    [[self toolSettingsWrapper] loadExtraDictionaryRepresentation:aRepresentation withCodingContext:aContext];
    NSEnumerator *enumerator = [[[self toolSettingsWrapper] toolInputs] keyEnumerator];
    id key;
    while ((key = [enumerator nextObject]) != nil) {
        id value = [[self toolSettingsWrapper] toolInputForKey:key];
        [_bitmapTool setValue:(value != [NSNull null] ? value : nil) forInputKey:key];
    }
}

- (void)didActivateExplicitly:(BOOL)aExplicitly
{
    id pvVar1_3;
    id pvVar1_4;
    id pvVar1_7;
    id pvVar2_2;

    [super didActivateExplicitly:aExplicitly];
    if ([self activateBitmapTool]) {
        pvVar1_3 = [[self view] rootCanvasLayer];
        pvVar2_2 = [[self class] toolsCanvasLayerWithRootLayer:pvVar1_3];
        [pvVar1_3 setEnabledSublayerIdentifiers:[[self class] layerIdentifiersWithRootLayer:pvVar1_3]];
        [pvVar1_3 fixOnionSkinCanvasLayerIfNeeded];
        pvVar1_4 = _toolCanvasLayer;
        if (pvVar1_4 == nil) {
            pvVar1_4 = [[[self class] toolCanvasLayerClass] new];
            _toolCanvasLayer = pvVar1_4;
            if (pvVar1_4 == nil) {
                return;
            }
        }
        if (_dragCardCanvasLayer == nil) {
            pvVar1_7 = [HSDragCardViewCanvasLayer new];
            _dragCardCanvasLayer = pvVar1_7;
            if (pvVar1_7 == nil) {
                return;
            }
            pvVar1_4 = _toolCanvasLayer;
        }
        [pvVar2_2 addSublayer:pvVar1_4];
        [pvVar2_2 addSublayer:_dragCardCanvasLayer];
        [_toolCanvasLayer setTool:self];
        [self HSBitmapTool_updateCursorWithEvent:nil];
    }
}

- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly
{
    id pvVar1;
    id self_00;
    id pvVar2;

    [self deactivateBitmapTool];
    pvVar1 = [self view];
    self_00 = [pvVar1 rootCanvasLayer];
    [self_00 setEnabledSublayerIdentifiers:nil];
    [self_00 fixOnionSkinCanvasLayerIfNeeded];
    pvVar1 = [self_00 vectorToolsCanvasLayer];
    [pvVar1 setTool:nil];
    pvVar2 = [self_00 bitmapToolsCanvasLayer];
    pvVar1 = nil;
    [pvVar2 setTool:nil];
    if (_toolCanvasLayer != nil) {
        pvVar1 = nil;
        [_toolCanvasLayer setTool:nil];
        pvVar2 = [_toolCanvasLayer parentLayer];
        if (pvVar2 != nil) {
            pvVar1 = [self class];
            pvVar2 = [pvVar1 toolsCanvasLayerWithRootLayer:self_00];
            pvVar1 = _toolCanvasLayer;
            [pvVar2 removeSublayer:pvVar1];
        }
    }
    if (_dragCardCanvasLayer != nil) {
        pvVar2 = [_dragCardCanvasLayer parentLayer];
        if (pvVar2 != nil) {
            pvVar1 = [[self class] toolsCanvasLayerWithRootLayer:self_00];
            [pvVar1 removeSublayer:_dragCardCanvasLayer];
        }
    }
    [super finalizeBeforeDeactivateExplicitly:aExplicitly];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018cd41 @ 0018cd41, 110 bytes * /

void FUN_0018cd41(HSBaseBitmapTool *self,SEL _cmd)

{
  id self_00;
  id pvVar1;
  
  if ((self->_obeysLayoutGuiding[0] & 2) != 0) {
    _objc_msgSend(self,sel_deactivateBitmapTool);
    self_00 = _objc_msgSend(self,sel_view);
    pvVar1 = _objc_msgSend(self,sel_activateBitmapTool);
    if ((char)pvVar1 != '\0') {
      _objc_msgSend(self_00,sel_updateCursor);
    }
  }
  return;
}

*/
- (void)saveChanges
{
    if (_resetOnSave) {
        [self deactivateBitmapTool];
        id view = [self view];
        if ([self activateBitmapTool]) {
            [view updateCursor];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018cc80 @ 0018cc80, 193 bytes * /

void FUN_0018cc80(HSBaseBitmapTool *self,SEL _cmd,id HSBitmapTool_updateCursorWithEvent)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  
  self_00 = _objc_msgSend(self,sel_view);
  pvVar1 = _objc_msgSend(self_00,sel_window);
  pvVar2 = _objc_msgSend(pvVar1,sel_BT_effectiveModifierFlagsWithEvent_,
                         HSBitmapTool_updateCursorWithEvent);
  pvVar1 = _objc_msgSend(pvVar1,sel_BT_effectiveMouseLocationWithEvent_,
                         HSBitmapTool_updateCursorWithEvent);
  pvVar1 = _objc_msgSend(self_00,sel_convertPoint_fromView_,pvVar1,extraout_EDX,0);
  _objc_msgSend(self_00,sel_updateCursorAtPoint_modifierFlags_event_,pvVar1,extraout_EDX_00,pvVar2,
                HSBitmapTool_updateCursorWithEvent);
  return;
}

*/
- (void)HSBitmapTool_updateCursorWithEvent:(id)aEvent
{
    id view = [self view];
    id window = [view window];
    NSUInteger flags = [window BT_effectiveModifierFlagsWithEvent:aEvent];
    NSPoint location = [view convertPoint:[window BT_effectiveMouseLocationWithEvent:aEvent] fromView:nil];
    [view updateCursorAtPoint:location modifierFlags:flags event:aEvent];
}

- (void)deactivateBitmapTool
{
    [_bitmapTool deactivate];
}

- (BOOL)isActiveAtPoint:(NSPoint)aPoint
{
    return YES;
}

- (BOOL)activateBitmapTool
{
    return (BOOL)[_bitmapTool activateWithDelegate:self inView:[self HSBaseBitmapTool_bitmapToolView]];
}

- (void)reactivate
{
    [_bitmapTool deactivate];
    [_bitmapTool activateWithDelegate:self inView:[self HSBaseBitmapTool_bitmapToolView]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018c648 @ 0018c648, 22 bytes * /

BOOL FUN_0018c648(HSBaseBitmapTool *self,SEL _cmd)

{
  BOOL BVar1;
  
  BVar1 = -1;
  if ((self->_obeysLayoutGuiding[0] & 1) == 0) {
    BVar1 = '\0';
  }
  return BVar1;
}

*/
- (BOOL)obeysLayoutGuiding
{
    return _obeysLayoutGuiding;
}

- (id)bitmapTool
{
    return _bitmapTool;
}

- (id)HSBaseBitmapTool_bitmapToolView
{
    id pvVar1;

    pvVar1 = _bitmapToolViewProxy;
    if (pvVar1 == nil) {
        pvVar1 = [[HSBitmapToolViewProxy alloc] initWithToolView:[self view]];
        _bitmapToolViewProxy = pvVar1;
    }
    return pvVar1;
}

- (void)setView:(id)aView
{
    [super setView:aView];
    [_bitmapToolViewProxy setToolView:aView];
}

- (BOOL)allowsSelection
{
    return YES;
}

- (void)dealloc
{
    [_toolCanvasLayer setTool:nil];
    [_toolCanvasLayer release];
    [_dragCardCanvasLayer release];
    [_bitmapTool deactivate];
    [_bitmapTool release];
    [_bitmapToolViewProxy setToolView:nil];
    [_bitmapToolViewProxy release];
    [_toolSettingsWrapper release];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018d4f7 @ 0018d4f7, 117 bytes * /

id FUN_0018d4f7(HSBaseBitmapTool *self,SEL _cmd,id initWithBTTool,BOOL obeyLayoutGuiding,
               BOOL resetOnSave)

{
  id pvVar1;
  id pvVar2;
  ushort uVar3;
  HSBaseBitmapTool *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSTool_00352880;
  pvVar1 = _objc_msgSendSuper(&local_1c,sel_init);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(initWithBTTool,sel_retain);
    *(id *)((int)pvVar1 + 0x14) = pvVar2;
    uVar3 = CONCAT11(obeyLayoutGuiding,resetOnSave) & 0x1ff;
    *(byte *)((int)pvVar1 + 0x24) =
         (char)uVar3 * '\x02' & 2U | *(byte *)((int)pvVar1 + 0x24) & 0xfc | (byte)(uVar3 >> 8);
  }
  return pvVar1;
}

*/
- (id)initWithBTTool:(id)aTool obeyLayoutGuiding:(BOOL)aGuiding resetOnSave:(BOOL)aSave
{
    self = [super init];
    if (self != nil) {
        _bitmapTool = [aTool retain];
        _obeysLayoutGuiding = aGuiding ? 1 : 0;
        _resetOnSave = aSave ? 1 : 0;
    }
    return self;
}

- (id)initWithBTTool:(id)aTool
{
    return [self initWithBTTool:aTool obeyLayoutGuiding:YES resetOnSave:YES];
}

@end

@implementation HSBitmapToolViewProxy

/* i386 ivar offsets: _toolView=0x4, _mouseTracker=0x8 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018ca9b @ 0018ca9b, 111 bytes * /

void FUN_0018ca9b(HSBitmapToolViewProxy *self,SEL _cmd,id trackingView,BOOL didAutoscroll,
                 id withMouseEvent)

{
  HSToolView *self_00;
  
  self_00 = self->_toolView;
  if ((self->_mouseTracker != (HSToolView *)0x0) && (self_00 == trackingView)) {
    self_00 = self->_mouseTracker;
    trackingView = self;
  }
  _objc_msgSend(self_00,sel_trackingView_didAutoscroll_withMouseEvent_,trackingView,
                (int)didAutoscroll,withMouseEvent);
  return;
}

*/
- (void)trackingView:(id)aView didAutoscroll:(BOOL)aAutoscroll withMouseEvent:(id)aEvent
{
    id target = _toolView;
    id view = aView;
    // Events from the tool view go to the mouse tracker, with the proxy standing in as the view.
    if (_mouseTracker != nil && _toolView == aView) {
        target = _mouseTracker;
        view = self;
    }
    [target trackingView:view didAutoscroll:aAutoscroll withMouseEvent:aEvent];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018ca39 @ 0018ca39, 98 bytes * /

BOOL FUN_0018ca39(HSBitmapToolViewProxy *self,SEL _cmd,id trackingView,
                 id shouldAutoscrollWithMouseEvent)

{
  id pvVar1;
  HSToolView *self_00;
  
  self_00 = self->_toolView;
  if ((self->_mouseTracker != (HSToolView *)0x0) && (self_00 == trackingView)) {
    self_00 = self->_mouseTracker;
    trackingView = self;
  }
  pvVar1 = _objc_msgSend(self_00,sel_trackingView_shouldAutoscrollWithMouseEvent_,trackingView,
                         shouldAutoscrollWithMouseEvent);
  return (BOOL)pvVar1;
}

*/
- (BOOL)trackingView:(id)aView shouldAutoscrollWithMouseEvent:(id)aEvent
{
    id target = _toolView;
    id view = aView;
    // Events from the tool view go to the mouse tracker, with the proxy standing in as the view.
    if (_mouseTracker != nil && _toolView == aView) {
        target = _mouseTracker;
        view = self;
    }
    return [target trackingView:view shouldAutoscrollWithMouseEvent:aEvent];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018c9da @ 0018c9da, 95 bytes * /

void FUN_0018c9da(HSBitmapToolViewProxy *self,SEL _cmd,id haltWithMouseUp,id inView)

{
  HSToolView *self_00;
  
  self_00 = self->_toolView;
  if ((self->_mouseTracker != (HSToolView *)0x0) && (self_00 == inView)) {
    self_00 = self->_mouseTracker;
    inView = self;
  }
  _objc_msgSend(self_00,sel_haltWithMouseUp_inView_,haltWithMouseUp,inView);
  return;
}

*/
- (void)haltWithMouseUp:(id)aUp inView:(id)aView
{
    id target = _toolView;
    id view = aView;
    // Events from the tool view go to the mouse tracker, with the proxy standing in as the view.
    if (_mouseTracker != nil && _toolView == aView) {
        target = _mouseTracker;
        view = self;
    }
    [target haltWithMouseUp:aUp inView:view];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018c97b @ 0018c97b, 95 bytes * /

void FUN_0018c97b(HSBitmapToolViewProxy *self,SEL _cmd,id trackFlagsChanged,id inView)

{
  HSToolView *self_00;
  
  self_00 = self->_toolView;
  if ((self->_mouseTracker != (HSToolView *)0x0) && (self_00 == inView)) {
    self_00 = self->_mouseTracker;
    inView = self;
  }
  _objc_msgSend(self_00,sel_trackFlagsChanged_inView_,trackFlagsChanged,inView);
  return;
}

*/
- (void)trackFlagsChanged:(id)aChanged inView:(id)aView
{
    id target = _toolView;
    id view = aView;
    // Events from the tool view go to the mouse tracker, with the proxy standing in as the view.
    if (_mouseTracker != nil && _toolView == aView) {
        target = _mouseTracker;
        view = self;
    }
    [target trackFlagsChanged:aChanged inView:view];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018c91c @ 0018c91c, 95 bytes * /

void FUN_0018c91c(HSBitmapToolViewProxy *self,SEL _cmd,id trackMouseUp,id inView)

{
  HSToolView *self_00;
  
  self_00 = self->_toolView;
  if ((self->_mouseTracker != (HSToolView *)0x0) && (self_00 == inView)) {
    self_00 = self->_mouseTracker;
    inView = self;
  }
  _objc_msgSend(self_00,sel_trackMouseUp_inView_,trackMouseUp,inView);
  return;
}

*/
- (void)trackMouseUp:(id)aUp inView:(id)aView
{
    id target = _toolView;
    id view = aView;
    // Events from the tool view go to the mouse tracker, with the proxy standing in as the view.
    if (_mouseTracker != nil && _toolView == aView) {
        target = _mouseTracker;
        view = self;
    }
    [target trackMouseUp:aUp inView:view];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018c8bd @ 0018c8bd, 95 bytes * /

void FUN_0018c8bd(HSBitmapToolViewProxy *self,SEL _cmd,id trackMouseDragged,id inView)

{
  HSToolView *self_00;
  
  self_00 = self->_toolView;
  if ((self->_mouseTracker != (HSToolView *)0x0) && (self_00 == inView)) {
    self_00 = self->_mouseTracker;
    inView = self;
  }
  _objc_msgSend(self_00,sel_trackMouseDragged_inView_,trackMouseDragged,inView);
  return;
}

*/
- (void)trackMouseDragged:(id)aDragged inView:(id)aView
{
    id target = _toolView;
    id view = aView;
    // Events from the tool view go to the mouse tracker, with the proxy standing in as the view.
    if (_mouseTracker != nil && _toolView == aView) {
        target = _mouseTracker;
        view = self;
    }
    [target trackMouseDragged:aDragged inView:view];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018c85e @ 0018c85e, 95 bytes * /

void FUN_0018c85e(HSBitmapToolViewProxy *self,SEL _cmd,id trackMouseDown,id inView)

{
  HSToolView *self_00;
  
  self_00 = self->_toolView;
  if ((self->_mouseTracker != (HSToolView *)0x0) && (self_00 == inView)) {
    self_00 = self->_mouseTracker;
    inView = self;
  }
  _objc_msgSend(self_00,sel_trackMouseDown_inView_,trackMouseDown,inView);
  return;
}

*/
- (void)trackMouseDown:(id)aDown inView:(id)aView
{
    id target = _toolView;
    id view = aView;
    // Events from the tool view go to the mouse tracker, with the proxy standing in as the view.
    if (_mouseTracker != nil && _toolView == aView) {
        target = _mouseTracker;
        view = self;
    }
    [target trackMouseDown:aDown inView:view];
}

- (id)BT_trackMouseWithEvent:(id)aEvent tracker:(id)aTracker
{
    return [self BT_trackMouseWithEvent:aEvent tracker:aTracker startDelay:0.3];
}

- (id)BT_trackMouseWithEvent:(id)aEvent tracker:(id)aTracker startDelay:(double)aDelay
{
    id pvVar1;

    _mouseTracker = aTracker;
    pvVar1 = [_toolView BT_trackMouseWithEvent:aEvent tracker:self startDelay:aDelay];
    _mouseTracker = nil;
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018c78b @ 0018c78b, 63 bytes * /

void FUN_0018c78b(HSBitmapToolViewProxy *self,SEL _cmd,NSRect setNeedsDisplayInRect)

{
  _objc_msgSend(self->_toolView,sel_setNeedsDisplayOpenGLSurfaceInRect_,setNeedsDisplayInRect.origin
                ,setNeedsDisplayInRect.size);
  return;
}

*/
- (void)setNeedsDisplayInRect:(NSRect)aRect
{
    [_toolView setNeedsDisplayOpenGLSurfaceInRect:aRect];
}

- (void)setNeedsDisplay:(BOOL)aDisplay
{
    [_toolView setNeedsDisplayOpenGLSurface:aDisplay];
}

- (void)setToolView:(id)aView
{
    _toolView = aView;
}

- (id)toolView
{
    return _toolView;
}

- (void)forwardInvocation:(id)aInvocation
{
    if (_toolView != nil) {
        [aInvocation invokeWithTarget:_toolView];
    }
}

- (id)methodSignatureForSelector:(SEL)aSelector
{
    id pvVar1;

    pvVar1 = [_toolView methodSignatureForSelector:aSelector]
    ;
    return pvVar1;
}

- (id)initWithToolView:(id)aView
{
    _toolView = aView;
    return self;
}

- (id)init
{
    return [self initWithToolView:nil];
}

@end

