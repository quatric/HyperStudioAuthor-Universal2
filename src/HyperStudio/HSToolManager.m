#import "HSToolManager.h"

static NSDictionary *sToolTagsByIdentifier;

static NSString * const HSToolIdentifiersByTag[0x45] = {
    nil,
    @"HSArrowTool", @"HSTextTool", @"HSPolyLineTool", @"HSPolyCurveTool",
    @"HSShapeTool", @"HSPolygonTool", @"HSBrushTool", @"HSPencilTool",
    @"HSHeadlineTool", @"HSLineTool", @"HSDragRectTool", @"HSDragCircleTool",
    @"HSDragRoundedRectTool", @"HSRectSelectionTool", @"HSCircularSelectionTool", @"HSLassoSelectionTool",
    @"HSMagicWandSelectionTool", @"HSPaintBucketTool", @"HSSprayCanTool", @"HSEraserTool",
    @"HSEyedropperTool", @"HSZoomInTool", @"HSZoomOutTool", @"HSPlayTool",
    @"HSVectorGraphicObjectSelectionTool", @"HSTextObjectSelectionTool", @"HSButtonObjectSelectionTool", @"HSEffectObjectSelectionTool",
    @"HSMovieObjectSelectionTool", @"HSImageObjectSelectionTool", @"HSTextViewObjectSelectionTool", @"HSCameraObjectSelectionTool",
    @"HSWebObjectSelectionTool", @"HSImageWellObjectSelectionTool", @"HSGroupBoxObjectSelectionTool", @"HSColorPickingTool",
    @"HSEffectPerObjectTool", @"HSEffectTool", @"HSVectorBrushTool", @"HS3DBoxMakerTool",
    @"HSVectorSprayCanTool", @"HSVectorPencilTool", @"HSVectorLineTool", @"HSVectorDragRectTool",
    @"HSVectorDragCircleTool", @"HSVectorDragRoundedRectTool", @"HSScriptModeTool", @"HSAnimationEditModePathTool",
    @"HSAnimationSetupPickObjectTool", @"HSAnimationSetupRectGrabTool", @"HSAnimationSetupCircleGrabTool", @"HSAnimationSetupLassoGrabTool",
    @"HSAnimationSetupDrawPathTool", @"HSPlaceObjectToolIdentifier", @"HSAnimationSetupEditPathTool", @"HSAnimationSetupTryItTool",
    @"HSDisabledTool", @"HSButtonRectShapeCreationTool", @"HSButtonFreeHandShapeCreationTool", @"HSButtonLassoShapeCreationTool",
    @"HSButtonMagicWandShapeCreationTool", @"HSImagePartRectSelectionTool", @"HSImagePartLassoSelectionTool", @"HSImagePartCircularSelectionTool",
    @"HSDragSelectedObjectTool", @"HSPlayMovieActionPositionToolIdentifier", @"HSPlayMovieActionPlayToolIdentifier", @"HSPointSelectionToolIdentifier",
};

static id HSToolManagerCursorNamed(NSString *aName)
{
    return [[HSCursor cursorNamed:aName] cursor];
}

static id HSToolManagerUnitCirclePath(void)
{
    CGMutablePathRef path = CGPathCreateMutable();
    if (path != NULL) {
        [(id)path autorelease];
        CGPathAddEllipseInRect(path, NULL, CGRectMake(0, 0, 1, 1));
    }
    return (id)path;
}
static id sDAT_00342784;
static id sDAT_0034278c;

static id sDAT_00342784;
static id sDAT_0034278c;


@implementation HSToolManager

/* i386 ivar offsets: _previousToolTag=0x4, _selectedToolTag=0x8, _currentTool=0xc, _toolView=0x10, _isToolSetAsPermanent=0x14, _currentToolSet=0x18, _buttonShapeCreationToolIdentifiers=0x1c */

+ (NSInteger)defaultToolTag
{
    return 1;
}

+ (id)sharedToolManager
{
    if (sDAT_0034278c == nil) {
        sDAT_0034278c = [[self alloc] init];
        [sDAT_0034278c setupInitial];
    }
    return sDAT_0034278c;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003fd13 @ 0003fd13, 319 bytes * /

id FUN_0003fd13(id self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(cls_NSDictionary,sel_dictionaryWithObjectsAndKeys_,
                         *(undefined4 *)PTR_PTR_00336218,*(undefined4 *)PTR_PTR_00336320,
                         *(undefined4 *)PTR_PTR_00336300,*(undefined4 *)PTR_PTR_0033632c,
                         *(undefined4 *)PTR_PTR_00336298,*(undefined4 *)PTR_PTR_00336328,
                         *(undefined4 *)PTR_PTR_003360fc,*(undefined4 *)PTR_PTR_00336140,
                         *(undefined4 *)PTR_PTR_003360b0,*(undefined4 *)PTR_PTR_00336138,
                         *(undefined4 *)PTR_PTR_003360ac,*(undefined4 *)PTR_PTR_00336134,
                         *(undefined4 *)PTR_PTR_003360b4,*(undefined4 *)PTR_PTR_0033613c,
                         *(undefined4 *)PTR_PTR_0033624c,*(undefined4 *)PTR_PTR_00336248,0);
  return pvVar1;
}

*/
+ (id)vectorToBitmapToolMap
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"HSBrushTool", @"HSVectorBrushTool",
            @"HSSprayCanTool", @"HSVectorSprayCanTool",
            @"HSPencilTool", @"HSVectorPencilTool",
            @"HSLineTool", @"HSVectorLineTool",
            @"HSDragRectTool", @"HSVectorDragRectTool",
            @"HSDragCircleTool", @"HSVectorDragCircleTool",
            @"HSDragRoundedRectTool", @"HSVectorDragRoundedRectTool",
            @"HSEffectTool", @"HSEffectPerObjectTool", nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003fbd4 @ 0003fbd4, 319 bytes * /

id FUN_0003fbd4(id self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(cls_NSDictionary,sel_dictionaryWithObjectsAndKeys_,
                         *(undefined4 *)PTR_PTR_00336320,*(undefined4 *)PTR_PTR_00336218,
                         *(undefined4 *)PTR_PTR_0033632c,*(undefined4 *)PTR_PTR_00336300,
                         *(undefined4 *)PTR_PTR_00336328,*(undefined4 *)PTR_PTR_00336298,
                         *(undefined4 *)PTR_PTR_00336140,*(undefined4 *)PTR_PTR_003360fc,
                         *(undefined4 *)PTR_PTR_00336138,*(undefined4 *)PTR_PTR_003360b0,
                         *(undefined4 *)PTR_PTR_00336134,*(undefined4 *)PTR_PTR_003360ac,
                         *(undefined4 *)PTR_PTR_0033613c,*(undefined4 *)PTR_PTR_003360b4,
                         *(undefined4 *)PTR_PTR_00336248,*(undefined4 *)PTR_PTR_0033624c,0);
  return pvVar1;
}

*/
+ (id)bitmapToVectorToolMap
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"HSVectorBrushTool", @"HSBrushTool",
            @"HSVectorSprayCanTool", @"HSSprayCanTool",
            @"HSVectorPencilTool", @"HSPencilTool",
            @"HSVectorLineTool", @"HSLineTool",
            @"HSVectorDragRectTool", @"HSDragRectTool",
            @"HSVectorDragCircleTool", @"HSDragCircleTool",
            @"HSVectorDragRoundedRectTool", @"HSDragRoundedRectTool",
            @"HSEffectPerObjectTool", @"HSEffectTool", nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003ff62 @ 0003ff62, 4265 bytes * /

id FUN_0003ff62(id self,SEL _cmd,int bitmapToolForTag)

{
  SEL pcVar1;
  id pvVar2;
  id pvVar3;
  cfstringStruct *pcVar4;
  undefined4 *puVar5;
  undefined *self_00;
  undefined8 in_stack_ffffff9c;
  undefined8 uVar6;
  undefined4 uVar7;
  
  uVar7 = (undefined4)((ulonglong)in_stack_ffffff9c >> 0x20);
  switch(bitmapToolForTag) {
  case 7:
  case 0x27:
    pvVar2 = _objc_msgSend(cls_BTBrushTool,sel_alloc);
    pvVar2 = _objc_msgSend(pvVar2,sel_init);
    pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
    uVar6 = CONCAT44(uVar7,0x3f800000);
    _objc_msgSend(pvVar2,sel_setSpacing_,0x3f800000);
    pvVar3 = (id)_CGPathCreateMutable();
    if (pvVar3 != (id)0x0) {
      _objc_msgSend(pvVar3,sel_autorelease,uVar6);
      uVar7 = 0;
      _CGPathAddEllipseInRect(pvVar3,0,0,0x3f8000003f800000);
      uVar6 = CONCAT44(uVar7,pvVar3);
      _objc_msgSend(pvVar2,sel_setShapePrototypePath_,pvVar3);
    }
    uVar7 = (undefined4)((ulonglong)uVar6 >> 0x20);
    puVar5 = (undefined4 *)PTR_PTR_00336214;
    break;
  case 8:
  case 0x2a:
    pvVar2 = _objc_msgSend(cls_BTPencilTool,sel_alloc);
    pvVar2 = _objc_msgSend(pvVar2,sel_init);
    pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
    puVar5 = (undefined4 *)PTR_PTR_00336290;
    break;
  default:
    return (id)0x0;
  case 10:
    self_00 = cls_BTDrawLineTool;
    goto LAB_00040312;
  case 0xb:
  case 0xd:
    pvVar2 = _objc_msgSend(cls_BTDrawShapeTool,sel_alloc);
    pvVar2 = _objc_msgSend(pvVar2,sel_init);
    pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
    uVar6 = CONCAT44(uVar7,&cfstr_BTLineJoinMiter);
    pcVar1 = sel_setLineJoin_;
    goto LAB_00040028;
  case 0xc:
    self_00 = cls_BTDrawShapeTool;
    goto LAB_00040312;
  case 0xe:
    pvVar2 = _objc_msgSend(cls_BTRegionEditingTool,sel_alloc);
    pvVar2 = _objc_msgSend(pvVar2,sel_init);
    pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
    _objc_msgSend(self,sel_HSToolManager_setSelectionEditingCursorsForTool_,pvVar2);
    pcVar4 = &cfstr_BTShapeCreateSelectionMode;
    goto LAB_000403b2;
  case 0xf:
    pvVar2 = _objc_msgSend(cls_BTRegionEditingTool,sel_alloc);
    pvVar2 = _objc_msgSend(pvVar2,sel_init);
    pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
    _objc_msgSend(self,sel_HSToolManager_setSelectionEditingCursorsForTool_,pvVar2);
    _objc_msgSend(pvVar2,sel_setInitialCreateSelectionMode_,&cfstr_BTShapeCreateSelectionMode);
    _objc_msgSend(pvVar2,sel_setProportionalModePrimaryForCorners_,1);
    uVar6 = CONCAT44(uVar7,pvVar2);
    _objc_msgSend(self,sel_HSToolManager_setBackgroundModeForRegionEditingTool_,pvVar2);
    pvVar3 = (id)_CGPathCreateMutable();
    if (pvVar3 == (id)0x0) {
      return pvVar2;
    }
    _objc_msgSend(pvVar3,sel_autorelease,uVar6);
    goto LAB_000404dc;
  case 0x10:
    pvVar2 = _objc_msgSend(cls_BTRegionEditingTool,sel_alloc);
    pvVar2 = _objc_msgSend(pvVar2,sel_init);
    pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
    _objc_msgSend(self,sel_HSToolManager_setSelectionEditingCursorsForTool_,pvVar2);
    _objc_msgSend(pvVar2,sel_setInitialCreateSelectionMode_,&cfstr_BTMagicLassoCreateSelectionMode);
    _objc_msgSend(pvVar2,sel_setProportionalModePrimaryForCorners_,1);
    _objc_msgSend(self,sel_HSToolManager_setBackgroundModeForRegionEditingTool_,pvVar2);
    pvVar3 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_00336280);
    pvVar3 = _objc_msgSend(pvVar3,sel_cursor);
    if (pvVar3 != (id)0x0) {
      _objc_msgSend(pvVar2,sel_setWillCreateMagicLassoSelectionCursor_,pvVar3);
      _objc_msgSend(pvVar2,sel_setDoCreateMagicLassoSelectionCursor_,pvVar3);
    }
    pvVar3 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_003362c4);
    pvVar3 = _objc_msgSend(pvVar3,sel_cursor);
    if (pvVar3 != (id)0x0) {
      _objc_msgSend(pvVar2,sel_setWillCreateMagicWandSelectionCursor_,pvVar3);
    }
    pvVar3 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_00336294);
    pvVar3 = _objc_msgSend(pvVar3,sel_cursor);
    pcVar1 = sel_setWillCreateFreeHandSelectionCursor_;
    goto joined_r0x00040d52;
  case 0x11:
    pvVar2 = _objc_msgSend(cls_BTRegionEditingTool,sel_alloc);
    pvVar2 = _objc_msgSend(pvVar2,sel_init);
    pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
    _objc_msgSend(self,sel_HSToolManager_setSelectionEditingCursorsForTool_,pvVar2);
    pcVar4 = &cfstr_BTMagicWandCreateSelectionMode;
LAB_000403b2:
    _objc_msgSend(pvVar2,sel_setInitialCreateSelectionMode_,pcVar4);
    _objc_msgSend(pvVar2,sel_setProportionalModePrimaryForCorners_,1);
    uVar6 = CONCAT44(uVar7,pvVar2);
    pcVar1 = sel_HSToolManager_setBackgroundModeForRegionEditingTool_;
    goto LAB_00040ffc;
  case 0x12:
    pvVar2 = _objc_msgSend(cls_BTDrawSelectionTool,sel_alloc);
    pvVar2 = _objc_msgSend(pvVar2,sel_init);
    pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
    pvVar3 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_00336260);
    pvVar3 = _objc_msgSend(pvVar3,sel_cursor);
    if (pvVar3 != (id)0x0) {
      _objc_msgSend(pvVar2,sel_setWillCreateMagicWandSelectionCursor_,pvVar3);
    }
    pvVar3 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_00336250);
    pvVar3 = _objc_msgSend(pvVar3,sel_cursor);
    if (pvVar3 != (id)0x0) {
      uVar6 = CONCAT44(uVar7,pvVar3);
      pcVar1 = sel_setAlternateWillCreateMagicWandSelectionCursor_;
      goto LAB_00040094;
    }
    goto LAB_0004009c;
  case 0x13:
  case 0x29:
    pvVar2 = _objc_msgSend(cls_BTBrushTool,sel_alloc);
    pvVar2 = _objc_msgSend(pvVar2,sel_init);
    pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
    puVar5 = (undefined4 *)PTR_PTR_003362fc;
    break;
  case 0x14:
    pvVar2 = _objc_msgSend(cls_BTBrushTool,sel_alloc);
    pvVar2 = _objc_msgSend(pvVar2,sel_init);
    pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
    _objc_msgSend(pvVar2,sel_setSpacing_,0x3f800000);
    _objc_msgSend(pvVar2,sel_setPadding_,0);
    pvVar3 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_00336250);
    pvVar3 = _objc_msgSend(pvVar3,sel_cursor);
    if (pvVar3 == (id)0x0) goto LAB_0004009c;
    _objc_msgSend(pvVar2,sel_setWillDrawCursor_,pvVar3);
    _objc_msgSend(pvVar2,sel_setDoDrawCursor_,pvVar3);
    goto LAB_00040070;
  case 0x28:
    self_00 = cls_BTDraw3DShapeTool;
LAB_00040312:
    pvVar2 = _objc_msgSend(self_00,sel_alloc);
    pvVar2 = _objc_msgSend(pvVar2,sel_init);
    pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
    goto LAB_00040034;
  case 0x2b:
    pvVar2 = _objc_msgSend(cls_BTPointsCreationTool,sel_alloc);
    pvVar2 = _objc_msgSend(pvVar2,sel_init);
    pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
    _objc_msgSend(pvVar2,sel_setMaxPointsCount_,2);
    _objc_msgSend(pvVar2,sel_setCollectingMode_,*(undefined4 *)PTR_003361e8);
    _objc_msgSend(pvVar2,sel_setIsLastPointDynamic_,0);
    uVar6 = CONCAT44(uVar7,&cfstr_BTCorrectionModeHorizontalVerticalDiagonal);
    self = pvVar2;
    pcVar1 = sel_setCorrectionMode_;
    goto LAB_00040ffc;
  case 0x2c:
  case 0x2d:
  case 0x2e:
  case 0x3a:
    pvVar2 = _objc_msgSend(cls_BTCreateShapeSelectionTool,sel_alloc);
    pvVar2 = _objc_msgSend(pvVar2,sel_init);
    pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
    return pvVar2;
  case 0x32:
  case 0x3e:
    pvVar2 = _objc_msgSend(cls_BTSelectionTool,sel_new);
    pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
    _objc_msgSend(self,sel_HSToolManager_setSelectionEditingCursorsForTool_,pvVar2);
    pcVar4 = &cfstr_BTShapeCreateSelectionMode;
    goto LAB_00040cbd;
  case 0x33:
    pvVar2 = _objc_msgSend(cls_BTSelectionTool,sel_new);
    pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
    _objc_msgSend(self,sel_HSToolManager_setSelectionEditingCursorsForTool_,pvVar2);
    uVar6 = CONCAT44(uVar7,&cfstr_BTShapeCreateSelectionMode);
    _objc_msgSend(pvVar2,sel_setInitialCreateSelectionMode_,&cfstr_BTShapeCreateSelectionMode);
    pvVar3 = (id)_CGPathCreateMutable();
    if (pvVar3 == (id)0x0) {
      return pvVar2;
    }
    _objc_msgSend(pvVar3,sel_autorelease,uVar6);
    goto LAB_000404dc;
  case 0x34:
    pvVar2 = _objc_msgSend(cls_BTSelectionTool,sel_new);
    pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
    pvVar3 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_00336280);
    pvVar3 = _objc_msgSend(pvVar3,sel_cursor);
    if (pvVar3 != (id)0x0) {
      _objc_msgSend(pvVar2,sel_setWillCreateMagicLassoSelectionCursor_,pvVar3);
      _objc_msgSend(pvVar2,sel_setDoCreateMagicLassoSelectionCursor_,pvVar3);
    }
    pvVar3 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_003362c4);
    pvVar3 = _objc_msgSend(pvVar3,sel_cursor);
    if (pvVar3 != (id)0x0) {
      _objc_msgSend(pvVar2,sel_setWillCreateMagicWandSelectionCursor_,pvVar3);
    }
    pvVar3 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_00336294);
    pvVar3 = _objc_msgSend(pvVar3,sel_cursor);
    if (pvVar3 != (id)0x0) {
      _objc_msgSend(pvVar2,sel_setWillCreateFreeHandSelectionCursor_,pvVar3);
      _objc_msgSend(pvVar2,sel_setDoCreateFreeHandSelectionCursor_,pvVar3);
    }
    _objc_msgSend(self,sel_HSToolManager_setSelectionEditingCursorsForTool_,pvVar2);
    _objc_msgSend(pvVar2,sel_setInitialCreateSelectionMode_,&cfstr_BTMagicLassoCreateSelectionMode);
    goto LAB_00040ff1;
  case 0x3b:
    pvVar2 = _objc_msgSend(cls_BTCreateFreeHandSelectionTool,sel_alloc);
    pvVar2 = _objc_msgSend(pvVar2,sel_init);
    pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
    pvVar3 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_00336290);
    pvVar3 = _objc_msgSend(pvVar3,sel_cursor);
    if (pvVar3 == (id)0x0) {
      return pvVar2;
    }
    _objc_msgSend(pvVar2,sel_setWillCreateSelectionCursor_,pvVar3);
    pcVar1 = sel_setDoCreateSelectionCursor_;
    goto LAB_000404fe;
  case 0x3c:
    pvVar2 = _objc_msgSend(cls_BTCreateLassoSelectionTool,sel_alloc);
    pvVar2 = _objc_msgSend(pvVar2,sel_init);
    pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
    pvVar3 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_00336280);
    pvVar3 = _objc_msgSend(pvVar3,sel_cursor);
    if (pvVar3 == (id)0x0) {
      return pvVar2;
    }
    _objc_msgSend(pvVar2,sel_setWillCreateMagicLassoSelectionCursor_,pvVar3);
    pcVar1 = sel_setDoCreateMagicLassoSelectionCursor_;
    goto LAB_000404fe;
  case 0x3d:
    pvVar2 = _objc_msgSend(cls_BTCreateMagicWandSelectionTool,sel_alloc);
    pvVar2 = _objc_msgSend(pvVar2,sel_init);
    pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
    pvVar3 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_003362c4);
    pvVar3 = _objc_msgSend(pvVar3,sel_cursor);
    pcVar1 = sel_setWillCreateSelectionCursor_;
joined_r0x00040d52:
    if (pvVar3 == (id)0x0) {
      return pvVar2;
    }
    goto LAB_000400e0;
  case 0x3f:
    pvVar2 = _objc_msgSend(cls_BTSelectionTool,sel_new);
    pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
    pvVar3 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_00336280);
    pvVar3 = _objc_msgSend(pvVar3,sel_cursor);
    if (pvVar3 != (id)0x0) {
      _objc_msgSend(pvVar2,sel_setWillCreateMagicLassoSelectionCursor_,pvVar3);
      _objc_msgSend(pvVar2,sel_setDoCreateMagicLassoSelectionCursor_,pvVar3);
    }
    pvVar3 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_003362c4);
    pvVar3 = _objc_msgSend(pvVar3,sel_cursor);
    if (pvVar3 != (id)0x0) {
      _objc_msgSend(pvVar2,sel_setWillCreateMagicWandSelectionCursor_,pvVar3);
    }
    pvVar3 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_00336294);
    pvVar3 = _objc_msgSend(pvVar3,sel_cursor);
    if (pvVar3 != (id)0x0) {
      _objc_msgSend(pvVar2,sel_setWillCreateFreeHandSelectionCursor_,pvVar3);
      _objc_msgSend(pvVar2,sel_setDoCreateFreeHandSelectionCursor_,pvVar3);
    }
    _objc_msgSend(self,sel_HSToolManager_setSelectionEditingCursorsForTool_,pvVar2);
    pcVar4 = &cfstr_BTMagicLassoCreateSelectionMode;
LAB_00040cbd:
    _objc_msgSend(pvVar2,sel_setInitialCreateSelectionMode_,pcVar4);
LAB_00040ff1:
    uVar6 = CONCAT44(uVar7,1);
    self = pvVar2;
    pcVar1 = sel_setProportionalModePrimaryForCorners_;
    goto LAB_00040ffc;
  case 0x40:
    pvVar2 = _objc_msgSend(cls_BTSelectionTool,sel_new);
    pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
    _objc_msgSend(self,sel_HSToolManager_setSelectionEditingCursorsForTool_,pvVar2);
    _objc_msgSend(pvVar2,sel_setInitialCreateSelectionMode_,&cfstr_BTShapeCreateSelectionMode);
    uVar6 = CONCAT44(uVar7,1);
    _objc_msgSend(pvVar2,sel_setProportionalModePrimaryForCorners_,1);
    pvVar3 = (id)_CGPathCreateMutable();
    if (pvVar3 == (id)0x0) {
      return pvVar2;
    }
    _objc_msgSend(pvVar3,sel_autorelease,uVar6);
LAB_000404dc:
    uVar7 = 0;
    _CGPathAddEllipseInRect(pvVar3,0,0,0x3f8000003f800000);
    pcVar1 = sel_setSelectionShapePrototypePath_;
LAB_000404fe:
    uVar6 = CONCAT44(uVar7,pvVar3);
    self = pvVar2;
    goto LAB_00040ffc;
  }
  pvVar3 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*puVar5);
  pvVar3 = _objc_msgSend(pvVar3,sel_cursor);
  if (pvVar3 != (id)0x0) {
    _objc_msgSend(pvVar2,sel_setWillDrawCursor_,pvVar3);
    uVar6 = CONCAT44(uVar7,pvVar3);
    pcVar1 = sel_setDoDrawCursor_;
LAB_00040028:
    _objc_msgSend(pvVar2,pcVar1,uVar6);
    uVar7 = (undefined4)((ulonglong)uVar6 >> 0x20);
  }
LAB_00040034:
  pvVar3 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_00336250);
  pvVar3 = _objc_msgSend(pvVar3,sel_cursor);
  if (pvVar3 != (id)0x0) {
LAB_00040070:
    _objc_msgSend(pvVar2,sel_setWillAlternateDrawCursor_,pvVar3);
    uVar6 = CONCAT44(uVar7,pvVar3);
    pcVar1 = sel_setDoAlternateDrawCursor_;
LAB_00040094:
    _objc_msgSend(pvVar2,pcVar1,uVar6);
    uVar7 = (undefined4)((ulonglong)uVar6 >> 0x20);
  }
LAB_0004009c:
  pvVar3 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_00336258);
  pvVar3 = _objc_msgSend(pvVar3,sel_cursor);
  pcVar1 = sel_setPickColorCursor_;
  if (pvVar3 != (id)0x0) {
LAB_000400e0:
    uVar6 = CONCAT44(uVar7,pvVar3);
    self = pvVar2;
LAB_00040ffc:
    _objc_msgSend(self,pcVar1,uVar6);
  }
  return pvVar2;
}

*/
+ (id)bitmapToolForTag:(NSInteger)aTag
{
    id tool = nil;
    id cursor = nil;
    NSString *drawCursorName = nil;

    switch (aTag) {
    case 7:
    case 0x27:
        tool = [[[BTBrushTool alloc] init] autorelease];
        [tool setSpacing:1.0];
        {
            id path = HSToolManagerUnitCirclePath();
            if (path != nil) {
                [tool setShapePrototypePath:path];
            }
        }
        drawCursorName = HSBrushCursor;
        break;
    case 8:
    case 0x2a:
        tool = [[[BTPencilTool alloc] init] autorelease];
        drawCursorName = HSPencilCursor;
        break;
    case 0x13:
    case 0x29:
        tool = [[[BTBrushTool alloc] init] autorelease];
        drawCursorName = HSSprayCanCursor;
        break;
    case 10:
        tool = [[[BTDrawLineTool alloc] init] autorelease];
        break;
    case 0xb:
    case 0xd:
        tool = [[[BTDrawShapeTool alloc] init] autorelease];
        [tool setLineJoin:@"BTLineJoinMiter"];
        break;
    case 0xc:
        tool = [[[BTDrawShapeTool alloc] init] autorelease];
        break;
    case 0x28:
        tool = [[[BTDraw3DShapeTool alloc] init] autorelease];
        break;
    case 0x14:
        tool = [[[BTBrushTool alloc] init] autorelease];
        [tool setSpacing:1.0];
        [(BTBrushTool *)tool setPadding:NO];
        cursor = HSToolManagerCursorNamed(HSEraserCursor);
        if (cursor != nil) {
            [tool setWillDrawCursor:cursor];
            [tool setDoDrawCursor:cursor];
            [tool setWillAlternateDrawCursor:cursor];
            [tool setDoAlternateDrawCursor:cursor];
        }
        goto pickColorCursor;
    case 0x12:
        tool = [[[BTDrawSelectionTool alloc] init] autorelease];
        cursor = HSToolManagerCursorNamed(HSFillBucketCursor);
        if (cursor != nil) {
            [tool setWillCreateMagicWandSelectionCursor:cursor];
        }
        cursor = HSToolManagerCursorNamed(HSEraserCursor);
        if (cursor != nil) {
            [tool setAlternateWillCreateMagicWandSelectionCursor:cursor];
        }
        goto pickColorCursor;
    case 0xe:
    case 0xf:
    case 0x11:
        tool = [[[BTRegionEditingTool alloc] init] autorelease];
        [self HSToolManager_setSelectionEditingCursorsForTool:tool];
        [tool setInitialCreateSelectionMode:(aTag == 0x11 ? @"BTMagicWandCreateSelectionMode" : @"BTShapeCreateSelectionMode")];
        [tool setProportionalModePrimaryForCorners:YES];
        [self HSToolManager_setBackgroundModeForRegionEditingTool:tool];
        if (aTag == 0xf) {
            id path = HSToolManagerUnitCirclePath();
            if (path != nil) {
                [tool setSelectionShapePrototypePath:path];
            }
        }
        return tool;
    case 0x10:
        tool = [[[BTRegionEditingTool alloc] init] autorelease];
        [self HSToolManager_setSelectionEditingCursorsForTool:tool];
        [tool setInitialCreateSelectionMode:@"BTMagicLassoCreateSelectionMode"];
        [tool setProportionalModePrimaryForCorners:YES];
        [self HSToolManager_setBackgroundModeForRegionEditingTool:tool];
        cursor = HSToolManagerCursorNamed(HSLassoCursor);
        if (cursor != nil) {
            [tool setWillCreateMagicLassoSelectionCursor:cursor];
            [tool setDoCreateMagicLassoSelectionCursor:cursor];
        }
        cursor = HSToolManagerCursorNamed(HSReverseToolCursor);
        if (cursor != nil) {
            [tool setWillCreateMagicWandSelectionCursor:cursor];
        }
        cursor = HSToolManagerCursorNamed(HSPencilLassoCursor);
        if (cursor != nil) {
            [tool setWillCreateFreeHandSelectionCursor:cursor];
        }
        return tool;
    case 0x2b:
        tool = [[[BTPointsCreationTool alloc] init] autorelease];
        [tool setMaxPointsCount:2];
        [tool setCollectingMode:BTCollectingDragPointsMode];
        [tool setIsLastPointDynamic:NO];
        [tool setCorrectionMode:@"BTCorrectionModeHorizontalVerticalDiagonal"];
        return tool;
    case 0x2c:
    case 0x2d:
    case 0x2e:
    case 0x3a:
        return [[[BTCreateShapeSelectionTool alloc] init] autorelease];
    case 0x32:
    case 0x3e:
        tool = [[BTSelectionTool new] autorelease];
        [self HSToolManager_setSelectionEditingCursorsForTool:tool];
        [tool setInitialCreateSelectionMode:@"BTShapeCreateSelectionMode"];
        [tool setProportionalModePrimaryForCorners:YES];
        return tool;
    case 0x33:
    case 0x40:
        tool = [[BTSelectionTool new] autorelease];
        [self HSToolManager_setSelectionEditingCursorsForTool:tool];
        [tool setInitialCreateSelectionMode:@"BTShapeCreateSelectionMode"];
        if (aTag == 0x40) {
            [tool setProportionalModePrimaryForCorners:YES];
        }
        {
            id path = HSToolManagerUnitCirclePath();
            if (path != nil) {
                [tool setSelectionShapePrototypePath:path];
            }
        }
        return tool;
    case 0x34:
    case 0x3f:
        tool = [[BTSelectionTool new] autorelease];
        cursor = HSToolManagerCursorNamed(HSLassoCursor);
        if (cursor != nil) {
            [tool setWillCreateMagicLassoSelectionCursor:cursor];
            [tool setDoCreateMagicLassoSelectionCursor:cursor];
        }
        cursor = HSToolManagerCursorNamed(HSReverseToolCursor);
        if (cursor != nil) {
            [tool setWillCreateMagicWandSelectionCursor:cursor];
        }
        cursor = HSToolManagerCursorNamed(HSPencilLassoCursor);
        if (cursor != nil) {
            [tool setWillCreateFreeHandSelectionCursor:cursor];
            [tool setDoCreateFreeHandSelectionCursor:cursor];
        }
        [self HSToolManager_setSelectionEditingCursorsForTool:tool];
        [tool setInitialCreateSelectionMode:@"BTMagicLassoCreateSelectionMode"];
        [tool setProportionalModePrimaryForCorners:YES];
        return tool;
    case 0x3b:
        tool = [[[BTCreateFreeHandSelectionTool alloc] init] autorelease];
        cursor = HSToolManagerCursorNamed(HSPencilCursor);
        if (cursor != nil) {
            [tool setWillCreateSelectionCursor:cursor];
            [tool setDoCreateSelectionCursor:cursor];
        }
        return tool;
    case 0x3c:
        tool = [[[BTCreateLassoSelectionTool alloc] init] autorelease];
        cursor = HSToolManagerCursorNamed(HSLassoCursor);
        if (cursor != nil) {
            [tool setWillCreateMagicLassoSelectionCursor:cursor];
            [tool setDoCreateMagicLassoSelectionCursor:cursor];
        }
        return tool;
    case 0x3d:
        tool = [[[BTCreateMagicWandSelectionTool alloc] init] autorelease];
        cursor = HSToolManagerCursorNamed(HSReverseToolCursor);
        if (cursor != nil) {
            [tool setWillCreateSelectionCursor:cursor];
        }
        return tool;
    default:
        return nil;
    }

    if (drawCursorName != nil) {
        cursor = HSToolManagerCursorNamed(drawCursorName);
        if (cursor != nil) {
            [tool setWillDrawCursor:cursor];
            [tool setDoDrawCursor:cursor];
        }
    }
    cursor = HSToolManagerCursorNamed(HSEraserCursor);
    if (cursor != nil) {
        [tool setWillAlternateDrawCursor:cursor];
        [tool setDoAlternateDrawCursor:cursor];
    }
pickColorCursor:
    cursor = HSToolManagerCursorNamed(HSEyeDropperCursor);
    if (cursor != nil) {
        [tool setPickColorCursor:cursor];
    }
    return tool;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000410f4 @ 000410f4, 155 bytes * /

void FUN_000410f4(id self,SEL _cmd,id HSToolManager_setBackgroundModeForRegionEditingTool)

{
  int iVar1;
  int iVar2;
  undefined4 local_20;
  undefined4 local_1c;
  undefined4 local_18;
  undefined4 local_14;
  
  _objc_msgSend(HSToolManager_setBackgroundModeForRegionEditingTool,sel_setBackgroundMode_,
                &cfstr_BTStartPointColorBackgroundMode);
  iVar1 = _CGColorSpaceCreateDeviceRGB();
  if (iVar1 != 0) {
    local_20 = 0x3f800000;
    local_1c = 0x3f800000;
    local_18 = 0x3f800000;
    local_14 = 0x3f800000;
    iVar2 = _CGColorCreate(iVar1,&local_20);
    _CGColorSpaceRelease(iVar1);
    if (iVar2 != 0) {
      _objc_msgSend(HSToolManager_setBackgroundModeForRegionEditingTool,sel_setBackgroundColor_,
                    iVar2);
      _CGColorRelease(iVar2);
    }
  }
  return;
}

*/
+ (void)HSToolManager_setBackgroundModeForRegionEditingTool:(id)aTool
{
    [aTool setBackgroundMode:@"BTStartPointColorBackgroundMode"];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace != NULL) {
        CGFloat components[4] = {1.0, 1.0, 1.0, 1.0};
        CGColorRef color = CGColorCreate(colorSpace, components);
        CGColorSpaceRelease(colorSpace);
        if (color != NULL) {
            [aTool setBackgroundColor:(id)color];
            CGColorRelease(color);
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003f62a @ 0003f62a, 1450 bytes * /

void FUN_0003f62a(id self,SEL _cmd,id HSToolManager_setSelectionEditingCursorsForTool)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_00336308);
  pvVar1 = _objc_msgSend(pvVar1,sel_cursor);
  if (pvVar1 != (id)0x0) {
    _objc_msgSend(HSToolManager_setSelectionEditingCursorsForTool,
                  sel_setWillResizeBottomLeftSelectionCursor_,pvVar1);
    _objc_msgSend(HSToolManager_setSelectionEditingCursorsForTool,
                  sel_setDoResizeBottomLeftSelectionCursor_,pvVar1);
    _objc_msgSend(HSToolManager_setSelectionEditingCursorsForTool,
                  sel_setWillResizeTopRightSelectionCursor_,pvVar1);
    _objc_msgSend(HSToolManager_setSelectionEditingCursorsForTool,
                  sel_setDoResizeTopRightSelectionCursor_,pvVar1);
  }
  pvVar1 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_003362e8);
  pvVar1 = _objc_msgSend(pvVar1,sel_cursor);
  if (pvVar1 != (id)0x0) {
    _objc_msgSend(HSToolManager_setSelectionEditingCursorsForTool,
                  sel_setWillResizeCenterLeftSelectionCursor_,pvVar1);
    _objc_msgSend(HSToolManager_setSelectionEditingCursorsForTool,
                  sel_setDoResizeCenterLeftSelectionCursor_,pvVar1);
    _objc_msgSend(HSToolManager_setSelectionEditingCursorsForTool,
                  sel_setWillResizeCenterRightSelectionCursor_,pvVar1);
    _objc_msgSend(HSToolManager_setSelectionEditingCursorsForTool,
                  sel_setDoResizeCenterRightSelectionCursor_,pvVar1);
  }
  pvVar1 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_00336304);
  pvVar1 = _objc_msgSend(pvVar1,sel_cursor);
  if (pvVar1 != (id)0x0) {
    _objc_msgSend(HSToolManager_setSelectionEditingCursorsForTool,
                  sel_setWillResizeTopLeftSelectionCursor_,pvVar1);
    _objc_msgSend(HSToolManager_setSelectionEditingCursorsForTool,
                  sel_setDoResizeTopLeftSelectionCursor_,pvVar1);
    _objc_msgSend(HSToolManager_setSelectionEditingCursorsForTool,
                  sel_setWillResizeBottomRightSelectionCursor_,pvVar1);
    _objc_msgSend(HSToolManager_setSelectionEditingCursorsForTool,
                  sel_setDoResizeBottomRightSelectionCursor_,pvVar1);
  }
  pvVar1 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_003362ec);
  pvVar1 = _objc_msgSend(pvVar1,sel_cursor);
  if (pvVar1 != (id)0x0) {
    _objc_msgSend(HSToolManager_setSelectionEditingCursorsForTool,
                  sel_setWillResizeTopCenterSelectionCursor_,pvVar1);
    _objc_msgSend(HSToolManager_setSelectionEditingCursorsForTool,
                  sel_setDoResizeTopCenterSelectionCursor_,pvVar1);
    _objc_msgSend(HSToolManager_setSelectionEditingCursorsForTool,
                  sel_setWillResizeBottomCenterSelectionCursor_,pvVar1);
    _objc_msgSend(HSToolManager_setSelectionEditingCursorsForTool,
                  sel_setDoResizeBottomCenterSelectionCursor_,pvVar1);
  }
  pvVar1 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_003362c8);
  pvVar1 = _objc_msgSend(pvVar1,sel_cursor);
  if (pvVar1 != (id)0x0) {
    _objc_msgSend(HSToolManager_setSelectionEditingCursorsForTool,
                  sel_setWillRotateBottomLeftSelectionCursor_,pvVar1);
    _objc_msgSend(HSToolManager_setSelectionEditingCursorsForTool,
                  sel_setDoRotateBottomLeftSelectionCursor_,pvVar1);
  }
  pvVar1 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_003362d4);
  pvVar1 = _objc_msgSend(pvVar1,sel_cursor);
  if (pvVar1 != (id)0x0) {
    _objc_msgSend(HSToolManager_setSelectionEditingCursorsForTool,
                  sel_setWillRotateCenterLeftSelectionCursor_,pvVar1);
    _objc_msgSend(HSToolManager_setSelectionEditingCursorsForTool,
                  sel_setDoRotateCenterLeftSelectionCursor_,pvVar1);
  }
  pvVar1 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_003362dc);
  pvVar1 = _objc_msgSend(pvVar1,sel_cursor);
  if (pvVar1 != (id)0x0) {
    _objc_msgSend(HSToolManager_setSelectionEditingCursorsForTool,
                  sel_setWillRotateTopLeftSelectionCursor_,pvVar1);
    _objc_msgSend(HSToolManager_setSelectionEditingCursorsForTool,
                  sel_setDoRotateTopLeftSelectionCursor_,pvVar1);
  }
  pvVar1 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_003362e4);
  pvVar1 = _objc_msgSend(pvVar1,sel_cursor);
  if (pvVar1 != (id)0x0) {
    _objc_msgSend(HSToolManager_setSelectionEditingCursorsForTool,
                  sel_setWillRotateTopCenterSelectionCursor_,pvVar1);
    _objc_msgSend(HSToolManager_setSelectionEditingCursorsForTool,
                  sel_setDoRotateTopCenterSelectionCursor_,pvVar1);
  }
  pvVar1 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_003362e0);
  pvVar1 = _objc_msgSend(pvVar1,sel_cursor);
  if (pvVar1 != (id)0x0) {
    _objc_msgSend(HSToolManager_setSelectionEditingCursorsForTool,
                  sel_setWillRotateTopRightSelectionCursor_,pvVar1);
    _objc_msgSend(HSToolManager_setSelectionEditingCursorsForTool,
                  sel_setDoRotateTopRightSelectionCursor_,pvVar1);
  }
  pvVar1 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_003362d8);
  pvVar1 = _objc_msgSend(pvVar1,sel_cursor);
  if (pvVar1 != (id)0x0) {
    _objc_msgSend(HSToolManager_setSelectionEditingCursorsForTool,
                  sel_setWillRotateCenterRightSelectionCursor_,pvVar1);
    _objc_msgSend(HSToolManager_setSelectionEditingCursorsForTool,
                  sel_setDoRotateCenterRightSelectionCursor_,pvVar1);
  }
  pvVar1 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_003362cc);
  pvVar1 = _objc_msgSend(pvVar1,sel_cursor);
  if (pvVar1 != (id)0x0) {
    _objc_msgSend(HSToolManager_setSelectionEditingCursorsForTool,
                  sel_setWillRotateBottomRightSelectionCursor_,pvVar1);
    _objc_msgSend(HSToolManager_setSelectionEditingCursorsForTool,
                  sel_setDoRotateBottomRightSelectionCursor_,pvVar1);
  }
  pvVar1 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_003362d0);
  pvVar1 = _objc_msgSend(pvVar1,sel_cursor);
  if (pvVar1 != (id)0x0) {
    _objc_msgSend(HSToolManager_setSelectionEditingCursorsForTool,
                  sel_setWillRotateBottomCenterSelectionCursor_,pvVar1);
    _objc_msgSend(HSToolManager_setSelectionEditingCursorsForTool,
                  sel_setDoRotateBottomCenterSelectionCursor_,pvVar1);
  }
  return;
}

*/
+ (void)HSToolManager_setSelectionEditingCursorsForTool:(id)aTool
{
    id cursor;

    cursor = HSToolManagerCursorNamed(HSTRBLCursor);
    if (cursor != nil) {
        [aTool setWillResizeBottomLeftSelectionCursor:cursor];
        [aTool setDoResizeBottomLeftSelectionCursor:cursor];
        [aTool setWillResizeTopRightSelectionCursor:cursor];
        [aTool setDoResizeTopRightSelectionCursor:cursor];
    }
    cursor = HSToolManagerCursorNamed(HSScaleHorCursor);
    if (cursor != nil) {
        [aTool setWillResizeCenterLeftSelectionCursor:cursor];
        [aTool setDoResizeCenterLeftSelectionCursor:cursor];
        [aTool setWillResizeCenterRightSelectionCursor:cursor];
        [aTool setDoResizeCenterRightSelectionCursor:cursor];
    }
    cursor = HSToolManagerCursorNamed(HSTLBRCursor);
    if (cursor != nil) {
        [aTool setWillResizeTopLeftSelectionCursor:cursor];
        [aTool setDoResizeTopLeftSelectionCursor:cursor];
        [aTool setWillResizeBottomRightSelectionCursor:cursor];
        [aTool setDoResizeBottomRightSelectionCursor:cursor];
    }
    cursor = HSToolManagerCursorNamed(HSScaleVertCursor);
    if (cursor != nil) {
        [aTool setWillResizeTopCenterSelectionCursor:cursor];
        [aTool setDoResizeTopCenterSelectionCursor:cursor];
        [aTool setWillResizeBottomCenterSelectionCursor:cursor];
        [aTool setDoResizeBottomCenterSelectionCursor:cursor];
    }
    cursor = HSToolManagerCursorNamed(HSRotateBLCursor);
    if (cursor != nil) {
        [aTool setWillRotateBottomLeftSelectionCursor:cursor];
        [aTool setDoRotateBottomLeftSelectionCursor:cursor];
    }
    cursor = HSToolManagerCursorNamed(HSRotateLeftCursor);
    if (cursor != nil) {
        [aTool setWillRotateCenterLeftSelectionCursor:cursor];
        [aTool setDoRotateCenterLeftSelectionCursor:cursor];
    }
    cursor = HSToolManagerCursorNamed(HSRotateTLCursor);
    if (cursor != nil) {
        [aTool setWillRotateTopLeftSelectionCursor:cursor];
        [aTool setDoRotateTopLeftSelectionCursor:cursor];
    }
    cursor = HSToolManagerCursorNamed(HSRotateTopCursor);
    if (cursor != nil) {
        [aTool setWillRotateTopCenterSelectionCursor:cursor];
        [aTool setDoRotateTopCenterSelectionCursor:cursor];
    }
    cursor = HSToolManagerCursorNamed(HSRotateTRCursor);
    if (cursor != nil) {
        [aTool setWillRotateTopRightSelectionCursor:cursor];
        [aTool setDoRotateTopRightSelectionCursor:cursor];
    }
    cursor = HSToolManagerCursorNamed(HSRotateRightCursor);
    if (cursor != nil) {
        [aTool setWillRotateCenterRightSelectionCursor:cursor];
        [aTool setDoRotateCenterRightSelectionCursor:cursor];
    }
    cursor = HSToolManagerCursorNamed(HSRotateBRCursor);
    if (cursor != nil) {
        [aTool setWillRotateBottomRightSelectionCursor:cursor];
        [aTool setDoRotateBottomRightSelectionCursor:cursor];
    }
    cursor = HSToolManagerCursorNamed(HSRotateBottomCursor);
    if (cursor != nil) {
        [aTool setWillRotateBottomCenterSelectionCursor:cursor];
        [aTool setDoRotateBottomCenterSelectionCursor:cursor];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003f5ec @ 0003f5ec, 62 bytes * /

id FUN_0003f5ec(id self,SEL _cmd,int toolIdentifiersForToolSet)

{
  SEL op;
  id pvVar1;
  
  op = sel_bitmapToolIdentifiers;
  if ((toolIdentifiersForToolSet == 0) ||
     (op = sel_vectorToolIdentifiers, toolIdentifiersForToolSet == 1)) {
    pvVar1 = _objc_msgSend(self,op);
  }
  else {
    pvVar1 = (id)0x0;
  }
  return pvVar1;
}

*/
+ (id)toolIdentifiersForToolSet:(NSInteger)aSet
{
    if (aSet == 0) {
        return [self bitmapToolIdentifiers];
    }
    if (aSet == 1) {
        return [self vectorToolIdentifiers];
    }
    return nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003f39a @ 0003f39a, 320 bytes * /

Class FUN_0003f39a(id self,SEL _cmd,int toolClassForTag)

{
  undefined *self_00;
  id pvVar1;
  
  switch(toolClassForTag) {
  case 1:
  case 0x19:
  case 0x1a:
  case 0x1b:
  case 0x1c:
  case 0x1d:
  case 0x1e:
  case 0x1f:
  case 0x20:
  case 0x21:
  case 0x22:
  case 0x23:
    self_00 = cls_HSArrowTool;
    break;
  case 2:
    self_00 = cls_HSTextTool;
    break;
  case 3:
  case 4:
  case 5:
  case 6:
    self_00 = cls_HSPolyCurveTool;
    break;
  default:
    return (Class)0x0;
  case 9:
    self_00 = cls_HSHeadlineTool;
    break;
  case 0x16:
  case 0x17:
    self_00 = cls_HSMagnifyingTool;
    break;
  case 0x18:
    _objc_msgSend(cls_HSTool,sel_class);
  case 0x30:
    self_00 = cls_HSAnimationEditModePathTool;
    break;
  case 0x24:
    self_00 = cls_HSColorPickingTool;
    break;
  case 0x25:
    self_00 = cls_HSEffectPerObjectTool;
    break;
  case 0x26:
    self_00 = cls_HSEffectTool;
    break;
  case 0x28:
  case 0x2b:
  case 0x2c:
  case 0x2d:
  case 0x2e:
    self_00 = cls_HSVectorDrawShapeTool;
    break;
  case 0x2a:
    self_00 = cls_HSVectorPencilTool;
    break;
  case 0x31:
    self_00 = cls_HSAnimationSetupPickObjectTool;
    break;
  case 0x32:
  case 0x33:
  case 0x34:
    self_00 = cls_HSImagePartSelectionTool;
    break;
  case 0x35:
    self_00 = cls_HSAnimationSetupDrawPathTool;
    break;
  case 0x36:
    self_00 = cls_HSPlaceObjectTool;
    break;
  case 0x37:
    self_00 = cls_HSAnimationSetupEditPathTool;
    break;
  case 0x38:
    self_00 = cls_HSAnimationSetupTryItTool;
    break;
  case 0x39:
    self_00 = cls_HSDisabledTool;
    break;
  case 0x3a:
  case 0x3b:
  case 0x3c:
  case 0x3d:
    self_00 = cls_HSButtonShapeCreationTool;
    break;
  case 0x3e:
  case 0x3f:
  case 0x40:
  case 0x41:
    self_00 = cls_HSDragSelectedObjectTool;
    break;
  case 0x42:
    self_00 = cls_HSPlayMovieActionPositionTool;
    break;
  case 0x43:
    self_00 = cls_HSPlayMovieActionPlayTool;
    break;
  case 0x44:
    self_00 = cls_HSPointSelectionTool;
  }
  pvVar1 = _objc_msgSend(self_00,sel_class);
  return pvVar1;
}

*/
+ (Class)toolClassForTag:(NSInteger)aTag
{
    Class toolClass;

    switch (aTag) {
    case 1:
    case 0x19: case 0x1a: case 0x1b: case 0x1c: case 0x1d: case 0x1e:
    case 0x1f: case 0x20: case 0x21: case 0x22: case 0x23:
        toolClass = [HSArrowTool class];
        break;
    case 2:
        toolClass = [HSTextTool class];
        break;
    case 3: case 4: case 5: case 6:
        toolClass = [HSPolyCurveTool class];
        break;
    case 9:
        toolClass = [HSHeadlineTool class];
        break;
    case 0x16:
    case 0x17:
        toolClass = [HSMagnifyingTool class];
        break;
    case 0x18:
        // The original computes [HSTool class] here and then falls through, so the play tool tag
        // resolves to the animation path tool.
        [HSTool class];
    case 0x30:
        toolClass = [HSAnimationEditModePathTool class];
        break;
    case 0x24:
        toolClass = [HSColorPickingTool class];
        break;
    case 0x25:
        toolClass = [HSEffectPerObjectTool class];
        break;
    case 0x26:
        toolClass = [HSEffectTool class];
        break;
    case 0x28: case 0x2b: case 0x2c: case 0x2d: case 0x2e:
        toolClass = [HSVectorDrawShapeTool class];
        break;
    case 0x2a:
        toolClass = [HSVectorPencilTool class];
        break;
    case 0x31:
        toolClass = [HSAnimationSetupPickObjectTool class];
        break;
    case 0x32: case 0x33: case 0x34:
        toolClass = [HSImagePartSelectionTool class];
        break;
    case 0x35:
        toolClass = [HSAnimationSetupDrawPathTool class];
        break;
    case 0x36:
        toolClass = [HSPlaceObjectTool class];
        break;
    case 0x37:
        toolClass = [HSAnimationSetupEditPathTool class];
        break;
    case 0x38:
        toolClass = [HSAnimationSetupTryItTool class];
        break;
    case 0x39:
        toolClass = [HSDisabledTool class];
        break;
    case 0x3a: case 0x3b: case 0x3c: case 0x3d:
        toolClass = [HSButtonShapeCreationTool class];
        break;
    case 0x3e: case 0x3f: case 0x40: case 0x41:
        toolClass = [HSDragSelectedObjectTool class];
        break;
    case 0x42:
        toolClass = [HSPlayMovieActionPositionTool class];
        break;
    case 0x43:
        toolClass = [HSPlayMovieActionPlayTool class];
        break;
    case 0x44:
        toolClass = [HSPointSelectionTool class];
        break;
    default:
        return Nil;
    }
    return [toolClass class];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003f291 @ 0003f291, 265 bytes * /

id FUN_0003f291(id self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(cls_NSArray,sel_arrayWithObjects_,*(undefined4 *)PTR_PTR_003362c0,
                         *(undefined4 *)PTR_PTR_00336234,*(undefined4 *)PTR_PTR_003360f4,
                         *(undefined4 *)PTR_PTR_00336218,*(undefined4 *)PTR_PTR_00336300,
                         *(undefined4 *)PTR_PTR_0033628c,*(undefined4 *)PTR_PTR_00336254,
                         *(undefined4 *)PTR_PTR_003360fc,*(undefined4 *)PTR_PTR_00336298,
                         *(undefined4 *)PTR_PTR_003360b0,*(undefined4 *)PTR_PTR_003360ac,
                         *(undefined4 *)PTR_PTR_003360b4,*(undefined4 *)PTR_PTR_0033624c,0);
  return pvVar1;
}

*/
+ (id)bitmapToolIdentifiers
{
    return [NSArray arrayWithObjects:@"HSRectSelectionTool", @"HSCircularSelectionTool", @"HSLassoSelectionTool",
            @"HSBrushTool", @"HSSprayCanTool", @"HSPaintBucketTool", @"HSEraserTool", @"HSLineTool",
            @"HSPencilTool", @"HSDragRectTool", @"HSDragCircleTool", @"HSDragRoundedRectTool",
            @"HSEffectTool", nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003f1e2 @ 0003f1e2, 175 bytes * /

id FUN_0003f1e2(id self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(cls_NSArray,sel_arrayWithObjects_,*(undefined4 *)PTR_PTR_00336320,
                         *(undefined4 *)PTR_PTR_0033632c,*(undefined4 *)PTR_PTR_00336328,
                         *(undefined4 *)PTR_PTR_00336140,*(undefined4 *)PTR_PTR_00336138,
                         *(undefined4 *)PTR_PTR_00336134,*(undefined4 *)PTR_PTR_0033613c,
                         *(undefined4 *)PTR_PTR_00336248,0);
  return pvVar1;
}

*/
+ (id)vectorToolIdentifiers
{
    return [NSArray arrayWithObjects:@"HSVectorBrushTool", @"HSVectorSprayCanTool", @"HSVectorPencilTool",
            @"HSVectorLineTool", @"HSVectorDragRectTool", @"HSVectorDragCircleTool",
            @"HSVectorDragRoundedRectTool", @"HSEffectPerObjectTool", nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003f0c6 @ 0003f0c6, 284 bytes * /

int FUN_0003f0c6(id self,SEL _cmd,id toolTagForIdentifier)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id self_00;
  id pvVar4;
  
  if (DAT_00342788 == (id)0x0) {
    pvVar4 = (id)0x0;
    pvVar1 = _objc_msgSend(cls_NSMutableDictionary,sel_dictionary);
    do {
      pvVar3 = pvVar4;
      pvVar2 = _objc_msgSend(self,sel_toolIdentifierForTag_,pvVar4);
      if (pvVar2 != (id)0x0) {
        pvVar3 = _objc_msgSend(cls_NSNumber,sel_alloc,pvVar3);
        self_00 = _objc_msgSend(pvVar3,sel_initWithInt_,pvVar4);
        pvVar3 = self_00;
        _objc_msgSend(pvVar1,sel_setObject_forKey_,self_00,pvVar2);
        _objc_msgSend(self_00,sel_release);
      }
      pvVar4 = (id)((int)pvVar4 + 1);
    } while (pvVar4 != (id)0x45);
    DAT_00342788 = _objc_msgSend(pvVar1,sel_copy,pvVar3);
  }
  pvVar1 = _objc_msgSend(DAT_00342788,sel_objectForKey_,toolTagForIdentifier);
  if (pvVar1 == (id)0x0) {
    pvVar1 = (id)0x0;
  }
  else {
    pvVar1 = _objc_msgSend(pvVar1,sel_intValue,toolTagForIdentifier);
  }
  return (int)pvVar1;
}

*/
+ (NSInteger)toolTagForIdentifier:(id)aIdentifier
{
    if (sToolTagsByIdentifier == nil) {
        NSMutableDictionary *tags = [NSMutableDictionary dictionary];
        NSInteger tag;
        for (tag = 0; tag < 0x45; tag++) {
            id identifier = [self toolIdentifierForTag:tag];
            if (identifier != nil) {
                NSNumber *number = [[NSNumber alloc] initWithInt:(int)tag];
                [tags setObject:number forKey:identifier];
                [number release];
            }
        }
        sToolTagsByIdentifier = [tags copy];
    }
    id number = [sToolTagsByIdentifier objectForKey:aIdentifier];
    if (number == nil) {
        return 0;
    }
    return [number intValue];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003f01a @ 0003f01a, 172 bytes * /

BOOL FUN_0003f01a(id self,SEL _cmd,int canSelectToolWithTag)

{
  id pvVar1;
  
  if (((((0x14 < (uint)canSelectToolWithTag) ||
        ((0x180180U >> (canSelectToolWithTag & 0x1fU) & 1) == 0)) &&
       (1 < canSelectToolWithTag - 0xeU)) &&
      ((1 < canSelectToolWithTag - 0x10U && (canSelectToolWithTag != 10)))) &&
     ((canSelectToolWithTag != 0x12 &&
      ((1 < canSelectToolWithTag - 0xbU && (canSelectToolWithTag != 0xd)))))) {
    if (canSelectToolWithTag < 0x18) {
      if (canSelectToolWithTag != 0) {
LAB_0003f086:
        if ((uint)canSelectToolWithTag < 0x45) {
          pvVar1 = _objc_msgSend(self,sel_class);
          pvVar1 = _objc_msgSend(pvVar1,sel_toolClassForTag_,canSelectToolWithTag);
          return pvVar1 != (id)0x0;
        }
        return '\0';
      }
    }
    else if ((0x11 < canSelectToolWithTag - 0x18U) ||
            ((0x28001U >> (canSelectToolWithTag - 0x18U & 0x1f) & 1) == 0)) goto LAB_0003f086;
  }
  return '\x01';
}

*/
+ (BOOL)canSelectToolWithTag:(NSInteger)aTag
{
    switch (aTag) {
    case 0:
    case 7: case 8: case 10: case 0xb: case 0xc: case 0xd:
    case 0xe: case 0xf: case 0x10: case 0x11: case 0x12: case 0x13: case 0x14:
    case 0x18: case 0x27: case 0x29:
        return YES;
    default:
        break;
    }
    if ((NSUInteger)aTag < 0x45) {
        return [[self class] toolClassForTag:aTag] != Nil;
    }
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003da90 @ 0003da90, 738 bytes * /

id FUN_0003da90(id self,SEL _cmd,int toolIdentifierForTag)

{
  undefined4 *puVar1;
  
  switch(toolIdentifierForTag) {
  case 1:
    puVar1 = (undefined4 *)PTR_PTR_00336210;
    break;
  case 2:
    puVar1 = (undefined4 *)PTR_PTR_00336310;
    break;
  case 3:
    puVar1 = (undefined4 *)PTR_PTR_003362b4;
    break;
  case 4:
    puVar1 = (undefined4 *)PTR_PTR_003362b0;
    break;
  case 5:
    puVar1 = (undefined4 *)PTR_PTR_003362f4;
    break;
  case 6:
    puVar1 = (undefined4 *)PTR_PTR_003362b8;
    break;
  case 7:
    puVar1 = (undefined4 *)PTR_PTR_00336218;
    break;
  case 8:
    puVar1 = (undefined4 *)PTR_PTR_00336298;
    break;
  case 9:
    puVar1 = (undefined4 *)PTR_PTR_00336268;
    break;
  case 10:
    puVar1 = (undefined4 *)PTR_PTR_003360fc;
    break;
  case 0xb:
    puVar1 = (undefined4 *)PTR_PTR_003360b0;
    break;
  case 0xc:
    puVar1 = (undefined4 *)PTR_PTR_003360ac;
    break;
  case 0xd:
    puVar1 = (undefined4 *)PTR_PTR_003360b4;
    break;
  case 0xe:
    puVar1 = (undefined4 *)PTR_PTR_003362c0;
    break;
  case 0xf:
    puVar1 = (undefined4 *)PTR_PTR_00336234;
    break;
  case 0x10:
    puVar1 = (undefined4 *)PTR_PTR_003360f4;
    break;
  case 0x11:
    puVar1 = (undefined4 *)PTR_PTR_00336284;
    break;
  case 0x12:
    puVar1 = (undefined4 *)PTR_PTR_0033628c;
    break;
  case 0x13:
    puVar1 = (undefined4 *)PTR_PTR_00336300;
    break;
  case 0x14:
    puVar1 = (undefined4 *)PTR_PTR_00336254;
    break;
  case 0x15:
    puVar1 = (undefined4 *)PTR_PTR_0033625c;
    break;
  case 0x16:
    puVar1 = (undefined4 *)PTR_PTR_00336334;
    break;
  case 0x17:
    puVar1 = (undefined4 *)PTR_PTR_00336338;
    break;
  case 0x18:
    puVar1 = (undefined4 *)PTR_PTR_003362a8;
    break;
  case 0x19:
    puVar1 = (undefined4 *)PTR_PTR_00336324;
    break;
  case 0x1a:
    puVar1 = (undefined4 *)PTR_PTR_0033630c;
    break;
  case 0x1b:
    puVar1 = (undefined4 *)PTR_PTR_00336228;
    break;
  case 0x1c:
    puVar1 = (undefined4 *)PTR_PTR_00336244;
    break;
  case 0x1d:
    puVar1 = (undefined4 *)PTR_PTR_00336288;
    break;
  case 0x1e:
    puVar1 = (undefined4 *)PTR_PTR_0033626c;
    break;
  case 0x1f:
    puVar1 = (undefined4 *)PTR_PTR_00336314;
    break;
  case 0x20:
    puVar1 = (undefined4 *)PTR_PTR_00336230;
    break;
  case 0x21:
    puVar1 = (undefined4 *)PTR_PTR_00336330;
    break;
  case 0x22:
    puVar1 = (undefined4 *)PTR_PTR_0033627c;
    break;
  case 0x23:
    puVar1 = (undefined4 *)PTR_PTR_00336264;
    break;
  case 0x24:
    puVar1 = (undefined4 *)PTR_PTR_00336238;
    break;
  case 0x25:
    puVar1 = (undefined4 *)PTR_PTR_00336248;
    break;
  case 0x26:
    puVar1 = (undefined4 *)PTR_PTR_0033624c;
    break;
  case 0x27:
    puVar1 = (undefined4 *)PTR_PTR_00336320;
    break;
  case 0x28:
    puVar1 = (undefined4 *)PTR_PTR_003361ec;
    break;
  case 0x29:
    puVar1 = (undefined4 *)PTR_PTR_0033632c;
    break;
  case 0x2a:
    puVar1 = (undefined4 *)PTR_PTR_00336328;
    break;
  case 0x2b:
    puVar1 = (undefined4 *)PTR_PTR_00336140;
    break;
  case 0x2c:
    puVar1 = (undefined4 *)PTR_PTR_00336138;
    break;
  case 0x2d:
    puVar1 = (undefined4 *)PTR_PTR_00336134;
    break;
  case 0x2e:
    puVar1 = (undefined4 *)PTR_PTR_0033613c;
    break;
  case 0x2f:
    puVar1 = (undefined4 *)PTR_PTR_003362f0;
    break;
  case 0x30:
    puVar1 = (undefined4 *)PTR_PTR_003361f0;
    break;
  case 0x31:
    puVar1 = (undefined4 *)PTR_PTR_00336204;
    break;
  case 0x32:
    puVar1 = (undefined4 *)PTR_PTR_00336208;
    break;
  case 0x33:
    puVar1 = (undefined4 *)PTR_PTR_003361f4;
    break;
  case 0x34:
    puVar1 = (undefined4 *)PTR_PTR_00336200;
    break;
  case 0x35:
    puVar1 = (undefined4 *)PTR_PTR_003361f8;
    break;
  case 0x36:
    puVar1 = (undefined4 *)PTR_PTR_0033629c;
    break;
  case 0x37:
    puVar1 = (undefined4 *)PTR_PTR_003361fc;
    break;
  case 0x38:
    puVar1 = (undefined4 *)PTR_PTR_0033620c;
    break;
  case 0x39:
    puVar1 = (undefined4 *)PTR_PTR_0033623c;
    break;
  case 0x3a:
    puVar1 = (undefined4 *)PTR_PTR_0033622c;
    break;
  case 0x3b:
    puVar1 = (undefined4 *)PTR_PTR_0033621c;
    break;
  case 0x3c:
    puVar1 = (undefined4 *)PTR_PTR_00336220;
    break;
  case 0x3d:
    puVar1 = (undefined4 *)PTR_PTR_00336224;
    break;
  case 0x3e:
    puVar1 = (undefined4 *)PTR_PTR_00336278;
    break;
  case 0x3f:
    puVar1 = (undefined4 *)PTR_PTR_00336274;
    break;
  case 0x40:
    puVar1 = (undefined4 *)PTR_PTR_00336270;
    break;
  case 0x41:
    puVar1 = (undefined4 *)PTR_PTR_00336240;
    break;
  case 0x42:
    puVar1 = (undefined4 *)PTR_PTR_003362a4;
    break;
  case 0x43:
    puVar1 = (undefined4 *)PTR_PTR_003362a0;
    break;
  case 0x44:
    return *(id *)PTR_PTR_003362ac;
  default:
    return (id)0x0;
  }
  return (id)*puVar1;
}

*/
+ (id)toolIdentifierForTag:(NSInteger)aTag
{
    if (aTag < 1 || aTag >= 0x45) {
        return nil;
    }
    return HSToolIdentifiersByTag[aTag];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003ee95 @ 0003ee95, 389 bytes * /

int FUN_0003ee95(HSToolManager *self,SEL _cmd,id toolForPastingPasteboardContents)

{
  id pvVar1;
  id pvVar2;
  int iVar3;
  cfstringStruct *pcVar4;
  cfstringStruct *pcVar5;
  cfstringStruct *pcVar6;
  cfstringStruct *pcVar7;
  cfstringStruct *pcVar8;
  undefined4 uVar9;
  
  pvVar1 = _objc_msgSend(toolForPastingPasteboardContents,sel_types);
  pvVar2 = _objc_msgSend(self,sel_currentToolSet);
  if (pvVar2 == (id)0x0) {
    pvVar2 = _objc_msgSend(pvVar1,sel_containsObject_,&cfstr_BTSelectionRectPrototypePboardType);
    if ((char)pvVar2 == '\0') {
      pcVar4 = &cfstr_BTCreateSelectionModePboardType;
      pvVar2 = _objc_msgSend(pvVar1,sel_containsObject_,&cfstr_BTCreateSelectionModePboardType);
      if ((char)pvVar2 != '\0') {
        pvVar1 = _objc_msgSend(self,sel_selectedToolTag,pcVar4);
        return (pvVar1 != (id)0xf) + 0xf;
      }
      pvVar2 = _objc_msgSend(pvVar1,sel_containsObject_,&cfstr_BTArchivedImageRegionPboardType);
      if ((char)pvVar2 == '\0') {
        pcVar4 = &cfstr_HSObjectClassNamePasteboardType;
        pcVar8 = &cfstr_HSCardsIndexPasteboardType;
        pcVar7 = &cfstr_HSSerializedFontAttributesPasteboardType;
        pcVar6 = &cfstr_HSSerializedRichTextPasteboardType;
        pcVar5 = &cfstr_HSLibraryObjectsPasteboardType;
        uVar9 = 0;
        pvVar2 = _objc_msgSend(cls_NSArray,sel_arrayWithObjects_,&cfstr_HSObjectsPasteboardType,
                               &cfstr_HSLibraryObjectsPasteboardType,
                               &cfstr_HSSerializedRichTextPasteboardType,
                               &cfstr_HSSerializedFontAttributesPasteboardType,
                               &cfstr_HSCardsIndexPasteboardType,
                               &cfstr_HSObjectClassNamePasteboardType,0);
        pvVar1 = _objc_msgSend(pvVar1,sel_firstObjectCommonWithArray_,pvVar2);
        if (pvVar1 == (id)0x0) {
          pvVar1 = _objc_msgSend(cls_NSImage,sel_canInitWithPasteboard_,
                                 toolForPastingPasteboardContents,pcVar5,pcVar6,pcVar7,pcVar8,pcVar4
                                 ,uVar9);
          if ((char)pvVar1 != '\0') {
            return 0xe;
          }
          return 0;
        }
        goto LAB_0003eed4;
      }
    }
    iVar3 = 0xe;
  }
  else {
LAB_0003eed4:
    iVar3 = 0;
  }
  return iVar3;
}

*/
- (NSInteger)toolForPastingPasteboardContents:(id)aContents
{
    NSArray *types = [aContents types];

    if ([self currentToolSet] != 0) {
        return 0;
    }
    if ([types containsObject:@"BTSelectionRectPrototypePboardType"]) {
        return 0xe;
    }
    if ([types containsObject:@"BTCreateSelectionModePboardType"]) {
        return [self selectedToolTag] == 0xf ? 0xf : 0x10;
    }
    if ([types containsObject:@"BTArchivedImageRegionPboardType"]) {
        return 0xe;
    }
    NSArray *objectTypes = [NSArray arrayWithObjects:@"HSObjectsPasteboardType", @"HSLibraryObjectsPasteboardType",
                            @"HSSerializedRichTextPasteboardType", @"HSSerializedFontAttributesPasteboardType",
                            @"HSCardsIndexPasteboardType", @"HSObjectClassNamePasteboardType", nil];
    if ([types firstObjectCommonWithArray:objectTypes] != nil) {
        return 0;
    }
    return [NSImage canInitWithPasteboard:aContents] ? 0xe : 0;
}

- (void)preferencesDidChange:(id)aChange
{
    BOOL pvVar1_3;

    pvVar1_3 = [[[NSUserDefaults standardUserDefaults] objectForKey:HSShowCoachingMarks] boolValue];
    [[self toolSettings] setShouldUseCursorContours:(float)(int)pvVar1_3];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003ed33 @ 0003ed33, 207 bytes * /

void FUN_0003ed33(HSToolManager *self,SEL _cmd,id toolSettingsDidChange)

{
  id pvVar1;
  id pvVar2;
  undefined4 uVar3;
  
  pvVar1 = _objc_msgSend(toolSettingsDidChange,sel_userInfo);
  uVar3 = *(undefined4 *)PTR_PTR_0033631c;
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,uVar3);
  pvVar2 = _objc_msgSend(self,sel_currentTool);
  if (pvVar2 != (id)0x0) {
    if (pvVar1 != (id)0x0) {
      pvVar1 = _objc_msgSend(pvVar1,sel_intValue,uVar3);
      pvVar2 = _objc_msgSend(self,sel_selectedToolTag);
      if (pvVar1 != pvVar2) {
        return;
      }
    }
    pvVar1 = _objc_msgSend(self,sel_toolSettings,uVar3);
    pvVar2 = _objc_msgSend(self,sel_currentTool);
    _objc_msgSend(pvVar1,sel_applySettingsForTool_,pvVar2);
  }
  return;
}

*/
- (void)toolSettingsDidChange:(id)aChange
{
    id tag = [[aChange userInfo] objectForKey:HSToolTagKey];
    if ([self currentTool] != nil) {
        if (tag != nil && [tag intValue] != [self selectedToolTag]) {
            return;
        }
        [[self toolSettings] applySettingsForTool:[self currentTool]];
    }
}

- (id)toolSettings
{
    if (sDAT_00342784 == nil) {
        sDAT_00342784 = [HSToolSettings new];
    }
    return sDAT_00342784;
}

- (void)atomOperationPerformedWithResult:(BOOL)aResult
{
    BOOL iVar2;
    NSInteger pvVar1_2;

    if (aResult != NO) {
        if ([self selectedToolTag] == 0x28) {
            pvVar1_2 = _previousToolTag;
            iVar2 = _isToolSetAsPermanent;
        }
        else {
            if (_isToolSetAsPermanent != NO) {
                return;
            }
            pvVar1_2 = [[self class] defaultToolTag];
            iVar2 = 0;
        }
        [self selectToolWithTag:pvVar1_2 setAsPermanent:iVar2 forceSelection:NO explicitly:NO];
    }
}

- (BOOL)canSelectToolWithTag:(NSInteger)aTag
{
    return (BOOL)[[self class] canSelectToolWithTag:aTag];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003e8fd @ 0003e8fd, 764 bytes * /

void FUN_0003e8fd(HSToolManager *self,SEL _cmd,int selectToolWithTag,BOOL setAsPermanent,
                 BOOL forceSelection,BOOL explicitly)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  HSTool *pHVar4;
  int iVar5;
  cfstringStruct *pcVar6;
  HSToolManager *pHVar7;
  id local_14;
  
  if (selectToolWithTag == 0) {
    pvVar2 = _objc_msgSend(self,sel_class);
    selectToolWithTag = (int)_objc_msgSend(pvVar2,sel_defaultToolTag);
  }
  pvVar2 = (id)selectToolWithTag;
  pvVar3 = _objc_msgSend(self,sel_canSelectToolWithTag_,selectToolWithTag);
  if ((char)pvVar3 != '\0') {
    if ((self->_currentTool != (HSTool *)0x0) &&
       (pvVar3 = _objc_msgSend(self->_currentTool,sel_allowsEditingToolView,pvVar2),
       forceSelection == '\0' && (char)pvVar3 == '\0')) {
      return;
    }
    cVar1 = self->_isToolSetAsPermanent;
    self->_isToolSetAsPermanent = setAsPermanent;
    if ((id)selectToolWithTag != (id)self->_selectedToolTag) {
      pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter,pvVar2);
      pcVar6 = &cfstr_HSActiveToolWillChangeNotification;
      pHVar7 = self;
      _objc_msgSend(pvVar2,sel_postNotificationName_object_,
                    &cfstr_HSActiveToolWillChangeNotification,self);
      local_14 = (id)selectToolWithTag;
      if ((id)selectToolWithTag == (id)0x0) {
        pvVar2 = _objc_msgSend(self,sel_class,pcVar6,pHVar7);
        local_14 = _objc_msgSend(pvVar2,sel_defaultToolTag);
      }
      pvVar2 = _objc_msgSend(self,sel_toolWithTag_,local_14,pHVar7);
      pvVar3 = _objc_msgSend(self->_currentTool,sel_retain);
      pvVar3 = _objc_msgSend(pvVar3,sel_autorelease);
      _objc_msgSend(self->_toolView,sel_toolManagerDisableCanvasLayersRunning);
      iVar5 = (int)explicitly;
      _objc_msgSend(self->_toolView,sel_toolManagerWillSelectTool_explicitly_,pvVar2,iVar5);
      _objc_msgSend(self->_currentTool,sel_finalizeBeforeDeactivateExplicitly_,iVar5);
      _objc_msgSend(self->_currentTool,sel_setupWithView_beingRestored_,0,0);
      _objc_msgSend(self->_currentTool,sel_autorelease);
      pHVar4 = _objc_msgSend(pvVar2,sel_retain);
      self->_currentTool = pHVar4;
      self->_previousToolTag = self->_selectedToolTag;
      self->_selectedToolTag = (int)local_14;
      _objc_msgSend(self,sel_validateCurrentToolSet);
      _objc_msgSend(self->_currentTool,sel_setupWithView_beingRestored_,self->_toolView,
                    (uint)(cVar1 == '\0'));
      _objc_msgSend(self->_currentTool,sel_didActivateExplicitly_,iVar5);
      _objc_msgSend(self->_toolView,sel_toolManagerEnableCanvasLayersRunning);
      _objc_msgSend(self->_toolView,sel_toolManagerDidSelectTool_oldTool_explicitly_,pvVar2,pvVar3,
                    iVar5);
      pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
      _objc_msgSend(pvVar2,sel_postNotificationName_object_,
                    &cfstr_HSActiveToolDidSelectionNotification,self);
    }
  }
  return;
}

*/
- (void)selectToolWithTag:(NSInteger)aTag setAsPermanent:(BOOL)aPermanent forceSelection:(BOOL)aSelection explicitly:(BOOL)aExplicitly
{
    if (aTag == 0) {
        aTag = [[self class] defaultToolTag];
    }
    if (![self canSelectToolWithTag:aTag]) {
        return;
    }
    if (_currentTool != nil && ![_currentTool allowsEditingToolView] && !aSelection) {
        return;
    }
    BOOL wasPermanent = _isToolSetAsPermanent;
    _isToolSetAsPermanent = aPermanent;
    if (aTag == _selectedToolTag) {
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSActiveToolWillChangeNotification" object:self];
    NSInteger tag = aTag;
    if (tag == 0) {
        tag = [[self class] defaultToolTag];
    }
    id newTool = [self toolWithTag:tag];
    id oldTool = [[_currentTool retain] autorelease];
    [_toolView toolManagerDisableCanvasLayersRunning];
    [_toolView toolManagerWillSelectTool:newTool explicitly:aExplicitly];
    [_currentTool finalizeBeforeDeactivateExplicitly:aExplicitly];
    [_currentTool setupWithView:nil beingRestored:NO];
    [_currentTool autorelease];
    _currentTool = [newTool retain];
    _previousToolTag = _selectedToolTag;
    _selectedToolTag = (int)tag;
    [self validateCurrentToolSet];
    [_currentTool setupWithView:_toolView beingRestored:!wasPermanent];
    [_currentTool didActivateExplicitly:aExplicitly];
    [_toolView toolManagerEnableCanvasLayersRunning];
    [_toolView toolManagerDidSelectTool:newTool oldTool:oldTool explicitly:aExplicitly];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSActiveToolDidSelectionNotification" object:self];
}

- (void)selectToolWithTag:(NSInteger)aTag setAsPermanent:(BOOL)aPermanent forceSelection:(BOOL)aSelection
{
    [self selectToolWithTag:aTag setAsPermanent:aPermanent forceSelection:aSelection explicitly:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003e47e @ 0003e47e, 849 bytes * /

id FUN_0003e47e(HSToolManager *self,SEL _cmd,int toolWithTag)

{
  id pvVar1;
  id pvVar2;
  undefined *puVar3;
  SEL pcVar4;
  id self_00;
  int iVar5;
  
  pvVar1 = _objc_msgSend(self,sel_class);
  iVar5 = toolWithTag;
  pvVar1 = _objc_msgSend(pvVar1,sel_bitmapToolForTag_,toolWithTag);
  if (pvVar1 == (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_class,iVar5);
    pvVar1 = (id)toolWithTag;
    pvVar2 = _objc_msgSend(pvVar2,sel_toolClassForTag_,toolWithTag);
    if (pvVar2 == (id)0x0) {
      pvVar2 = (id)0x0;
      goto LAB_0003e7aa;
    }
    pvVar2 = _objc_msgSend(pvVar2,sel_alloc,pvVar1);
    pvVar2 = _objc_msgSend(pvVar2,sel_init);
    if (pvVar2 != (id)0x0) {
      pcVar4 = sel_setStraightLineMode_;
      if ((toolWithTag != 3) && (pcVar4 = sel_setShapeTool_, toolWithTag != 5)) {
        if (toolWithTag != 6) goto LAB_0003e73a;
        _objc_msgSend(pvVar2,sel_setStraightLineMode_,1);
        pcVar4 = sel_setShapeTool_;
      }
      pvVar1 = (id)0x1;
      _objc_msgSend(pvVar2,pcVar4,1);
    }
    goto LAB_0003e73a;
  }
  switch(toolWithTag) {
  case 7:
    puVar3 = cls_HSBitmapBrushToolWrapper;
    break;
  case 8:
    puVar3 = cls_HSBitmapPencilToolWrapper;
    break;
  default:
    puVar3 = cls_HSBitmapTool;
    break;
  case 10:
    puVar3 = cls_HSBitmapDrawLineToolWrapper;
    break;
  case 0xb:
  case 0xc:
  case 0x28:
    puVar3 = cls_HSBitmapDrawShapeToolWrapper;
    break;
  case 0xd:
    puVar3 = cls_HSBitmapDrawRoundedRectToolWrapper;
    break;
  case 0xe:
  case 0xf:
  case 0x11:
    puVar3 = cls_HSBitmapTool;
    goto LAB_0003e546;
  case 0x10:
    pvVar2 = _objc_msgSend(cls_HSBitmapTool,sel_alloc,iVar5);
    pcVar4 = sel_initWithBTTool_obeyLayoutGuiding_resetOnSave_;
    goto LAB_0003e67c;
  case 0x12:
    puVar3 = cls_HSBitmapFillToolWrapper;
    break;
  case 0x13:
    puVar3 = cls_HSBitmapBrushToolWrapper;
    goto LAB_0003e510;
  case 0x14:
    puVar3 = cls_HSBitmapEraserToolWrapper;
    break;
  case 0x27:
  case 0x29:
    puVar3 = cls_HSVectorBrushTool;
    break;
  case 0x2a:
    puVar3 = cls_HSVectorPencilTool;
    break;
  case 0x2b:
  case 0x2c:
  case 0x2d:
    puVar3 = cls_HSVectorDrawShapeTool;
    break;
  case 0x2e:
    puVar3 = cls_HSVectorDrawRoundedRectTool;
    break;
  case 0x32:
  case 0x33:
    puVar3 = cls_HSImagePartSelectionTool;
LAB_0003e546:
    pvVar2 = _objc_msgSend(puVar3,sel_alloc,iVar5);
    pcVar4 = sel_initWithBTTool_obeyLayoutGuiding_resetOnSave_;
    goto LAB_0003e67c;
  case 0x34:
  case 0x3e:
  case 0x3f:
  case 0x40:
    pvVar2 = _objc_msgSend(cls_HSImagePartSelectionTool,sel_alloc,iVar5);
    pcVar4 = sel_initWithBTTool_obeyLayoutGuiding_resetOnSave_createWorkImage_;
    goto LAB_0003e67c;
  case 0x3a:
    puVar3 = cls_HSButtonShapeCreationTool;
    break;
  case 0x3b:
  case 0x3c:
  case 0x3d:
    puVar3 = cls_HSButtonShapeCreationTool;
LAB_0003e510:
    pvVar2 = _objc_msgSend(puVar3,sel_alloc,iVar5);
    pcVar4 = sel_initWithBTTool_obeyLayoutGuiding_resetOnSave_;
    goto LAB_0003e67c;
  }
  pvVar2 = _objc_msgSend(puVar3,sel_alloc,iVar5);
  pcVar4 = sel_initWithBTTool_;
LAB_0003e67c:
  pvVar2 = _objc_msgSend(pvVar2,pcVar4,pvVar1);
LAB_0003e73a:
  if (pvVar2 != (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_class,pvVar1);
    pvVar1 = _objc_msgSend(pvVar1,sel_toolIdentifierForTag_,toolWithTag);
    _objc_msgSend(pvVar2,sel_setToolIdentifier_,pvVar1);
    self_00 = _objc_msgSend(self,sel_toolSettings);
    pvVar1 = pvVar2;
    _objc_msgSend(self_00,sel_applySettingsForTool_,pvVar2);
  }
LAB_0003e7aa:
  pvVar1 = _objc_msgSend(pvVar2,sel_autorelease,pvVar1);
  return pvVar1;
}

*/
- (id)toolWithTag:(NSInteger)aTag
{
    id tool;
    id btTool = [[self class] bitmapToolForTag:aTag];

    if (btTool == nil) {
        Class toolClass = [[self class] toolClassForTag:aTag];
        if (toolClass == Nil) {
            return nil;
        }
        tool = [[toolClass alloc] init];
        if (tool != nil) {
            if (aTag == 3 || aTag == 6) {
                [tool setStraightLineMode:YES];
            }
            if (aTag == 3 || aTag == 5 || aTag == 6) {
                [tool setShapeTool:YES];
            }
        }
    }
    else {
        switch (aTag) {
        case 7:
            tool = [[HSBitmapBrushToolWrapper alloc] initWithBTTool:btTool];
            break;
        case 8:
            tool = [[HSBitmapPencilToolWrapper alloc] initWithBTTool:btTool];
            break;
        case 10:
            tool = [[HSBitmapDrawLineToolWrapper alloc] initWithBTTool:btTool];
            break;
        case 0xb:
        case 0xc:
        case 0x28:
            tool = [[HSBitmapDrawShapeToolWrapper alloc] initWithBTTool:btTool];
            break;
        case 0xd:
            tool = [[HSBitmapDrawRoundedRectToolWrapper alloc] initWithBTTool:btTool];
            break;
        case 0xe:
        case 0xf:
        case 0x11:
            tool = [[HSBitmapTool alloc] initWithBTTool:btTool obeyLayoutGuiding:YES resetOnSave:NO];
            break;
        case 0x10:
            tool = [[HSBitmapTool alloc] initWithBTTool:btTool obeyLayoutGuiding:NO resetOnSave:NO];
            break;
        case 0x12:
            tool = [[HSBitmapFillToolWrapper alloc] initWithBTTool:btTool];
            break;
        case 0x13:
            tool = [[HSBitmapBrushToolWrapper alloc] initWithBTTool:btTool obeyLayoutGuiding:NO resetOnSave:YES];
            break;
        case 0x14:
            tool = [[HSBitmapEraserToolWrapper alloc] initWithBTTool:btTool];
            break;
        case 0x27:
        case 0x29:
            tool = [[HSVectorBrushTool alloc] initWithBTTool:btTool];
            break;
        case 0x2a:
            tool = [[HSVectorPencilTool alloc] initWithBTTool:btTool];
            break;
        case 0x2b:
        case 0x2c:
        case 0x2d:
            tool = [[HSVectorDrawShapeTool alloc] initWithBTTool:btTool];
            break;
        case 0x2e:
            tool = [[HSVectorDrawRoundedRectTool alloc] initWithBTTool:btTool];
            break;
        case 0x32:
        case 0x33:
            tool = [[HSImagePartSelectionTool alloc] initWithBTTool:btTool obeyLayoutGuiding:YES resetOnSave:NO];
            break;
        case 0x34:
        case 0x3e:
        case 0x3f:
        case 0x40:
            tool = [[HSImagePartSelectionTool alloc] initWithBTTool:btTool obeyLayoutGuiding:NO resetOnSave:NO createWorkImage:YES];
            break;
        case 0x3a:
            tool = [[HSButtonShapeCreationTool alloc] initWithBTTool:btTool];
            break;
        case 0x3b:
        case 0x3c:
        case 0x3d:
            tool = [[HSButtonShapeCreationTool alloc] initWithBTTool:btTool obeyLayoutGuiding:NO resetOnSave:YES];
            break;
        default:
            tool = [[HSBitmapTool alloc] initWithBTTool:btTool];
            break;
        }
    }
    if (tool != nil) {
        [tool setToolIdentifier:[[self class] toolIdentifierForTag:aTag]];
        [[self toolSettings] applySettingsForTool:tool];
    }
    return [tool autorelease];
}

- (void)selectToolWithTag:(NSInteger)aTag setAsPermanent:(BOOL)aPermanent
{
    [self selectToolWithTag:aTag setAsPermanent:aPermanent forceSelection:NO];
}

- (void)selectToolWithTag:(NSInteger)aTag
{
    [self selectToolWithTag:aTag setAsPermanent:YES];
}

- (NSInteger)selectedToolTag
{
    return _selectedToolTag;
}

- (id)currentTool
{
    return _currentTool;
}

- (void)validateCurrentToolSet
{
    int iVar1;
    id pvVar3;
    id pvVar4;
    unsigned int uVar5;
    Class pvVar2_4;

    pvVar3 = [[self class] toolIdentifiersForToolSet:_currentToolSet];
    pvVar4 = [[self class] toolIdentifierForTag:_selectedToolTag];
    if (![pvVar3 containsObject:pvVar4]) {
        iVar1 = _currentToolSet;
        pvVar2_4 = [self class];
        uVar5 = (unsigned int)(iVar1 == 0);
        if ([[pvVar2_4 toolIdentifiersForToolSet:uVar5] containsObject:pvVar4]) {
            _currentToolSet = uVar5;
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003e15f @ 0003e15f, 458 bytes * /

void FUN_0003e15f(HSToolManager *self,SEL _cmd,int setCurrentToolSet)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  SEL pcVar4;
  
  if (self->_currentToolSet == setCurrentToolSet) {
    return;
  }
  pvVar1 = _objc_msgSend(self,sel_class);
  pvVar2 = _objc_msgSend(pvVar1,sel_toolIdentifierForTag_,self->_selectedToolTag);
  pvVar1 = _objc_msgSend(self,sel_class);
  pvVar3 = _objc_msgSend(pvVar1,sel_toolIdentifiersForToolSet_,self->_currentToolSet);
  pvVar1 = pvVar2;
  pvVar3 = _objc_msgSend(pvVar3,sel_containsObject_,pvVar2);
  if ((char)pvVar3 == '\0') {
    self->_currentToolSet = setCurrentToolSet;
    pvVar2 = pvVar1;
  }
  else {
    pvVar3 = _objc_msgSend(self,sel_class,pvVar1);
    pcVar4 = sel_bitmapToVectorToolMap;
    if (setCurrentToolSet == 0) {
      pcVar4 = sel_vectorToBitmapToolMap;
    }
    pvVar1 = _objc_msgSend(pvVar3,pcVar4,pvVar1);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,pvVar2);
    if (pvVar1 == (id)0x0) {
      pvVar1 = _objc_msgSend(self,sel_class,pvVar2);
      pvVar2 = _objc_msgSend(self,sel_class);
      pvVar2 = _objc_msgSend(pvVar2,sel_defaultToolTag);
      pvVar1 = _objc_msgSend(pvVar1,sel_toolIdentifierForTag_,pvVar2);
    }
    self->_currentToolSet = setCurrentToolSet;
    if (pvVar1 != (id)0x0) {
      pvVar2 = _objc_msgSend(self,sel_class,pvVar2);
      pvVar2 = _objc_msgSend(pvVar2,sel_toolTagForIdentifier_,pvVar1);
      pcVar4 = sel_selectToolWithTag_setAsPermanent_forceSelection_explicitly_;
      goto LAB_0003e31c;
    }
  }
  self = (HSToolManager *)self->_currentTool;
  pcVar4 = sel_noteCurrentToolSetDidChange;
LAB_0003e31c:
  _objc_msgSend(self,pcVar4,pvVar2);
  return;
}

*/
- (void)setCurrentToolSet:(NSInteger)aSet
{
    if (_currentToolSet == aSet) {
        return;
    }
    id identifier = [[self class] toolIdentifierForTag:_selectedToolTag];
    if (![[[self class] toolIdentifiersForToolSet:_currentToolSet] containsObject:identifier]) {
        _currentToolSet = (int)aSet;
        [_currentTool noteCurrentToolSetDidChange];
        return;
    }
    NSDictionary *map = aSet == 0 ? [[self class] vectorToBitmapToolMap] : [[self class] bitmapToVectorToolMap];
    id newIdentifier = [map objectForKey:identifier];
    if (newIdentifier == nil) {
        newIdentifier = [[self class] toolIdentifierForTag:[[self class] defaultToolTag]];
    }
    _currentToolSet = (int)aSet;
    if (newIdentifier != nil) {
        [self selectToolWithTag:[[self class] toolTagForIdentifier:newIdentifier] setAsPermanent:_isToolSetAsPermanent forceSelection:NO explicitly:YES];
    }
    else {
        [_currentTool noteCurrentToolSetDidChange];
    }
}

- (NSInteger)currentToolSet
{
    return _currentToolSet;
}

- (void)setToolView:(id)aView
{
    if (_toolView != aView) {
        [_currentTool finalizeBeforeDeactivateExplicitly:YES];
        [_currentTool setupWithView:nil beingRestored:NO];
        [_toolView toolManagerWillSelectTool:nil explicitly:YES];
        _toolView = aView;
        [aView toolManagerWillSelectTool:_currentTool explicitly:YES];
        [_currentTool setupWithView:_toolView beingRestored:YES];
        [_currentTool didActivateExplicitly:YES];
    }
}

- (id)toolView
{
    return _toolView;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_currentTool setView:0];
    [_currentTool release];
    [_buttonShapeCreationToolIdentifiers release];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003df47 @ 0003df47, 294 bytes * /

void FUN_0003df47(HSToolManager *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  
  self->_selectedToolTag = -1;
  self->_previousToolTag = -1;
  _objc_msgSend(self,sel_preferencesDidChange_,0);
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  pvVar2 = _objc_msgSend(self,sel_toolSettings);
  _objc_msgSend(pvVar1,sel_addObserver_selector_name_object_,self,sel_toolSettingsDidChange_,
                *(undefined4 *)PTR_PTR_00336318,pvVar2);
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar1,sel_addObserver_selector_name_object_,self,sel_preferencesDidChange_,
                *(undefined4 *)PTR_003362bc,0);
  _objc_msgSend(self,sel_selectToolWithTag_setAsPermanent_forceSelection_explicitly_,1,1,0,0);
  return;
}

*/
- (void)setupInitial
{
    _selectedToolTag = -1;
    _previousToolTag = -1;
    [self preferencesDidChange:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toolSettingsDidChange:) name:HSToolSettingsDidChangeNotification object:[self toolSettings]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferencesDidChange:) name:HSPreferencesDidChangeNotification object:nil];
    [self selectToolWithTag:1 setAsPermanent:YES forceSelection:NO explicitly:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0003deba @ 0003deba, 141 bytes * /

id FUN_0003deba(HSToolManager *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = self->_buttonShapeCreationToolIdentifiers;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSSet,sel_alloc);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithObjects_,*(undefined4 *)PTR_PTR_0033622c,
                           *(undefined4 *)PTR_PTR_0033621c,*(undefined4 *)PTR_PTR_00336220,
                           *(undefined4 *)PTR_PTR_00336224,0);
    self->_buttonShapeCreationToolIdentifiers = pvVar1;
  }
  return pvVar1;
}

*/
- (id)buttonShapeCreationToolIdentifiers
{
    if (_buttonShapeCreationToolIdentifiers == nil) {
        _buttonShapeCreationToolIdentifiers = [[NSSet alloc] initWithObjects:@"HSButtonRectShapeCreationTool",
                                               @"HSButtonFreeHandShapeCreationTool", @"HSButtonLassoShapeCreationTool",
                                               @"HSButtonMagicWandShapeCreationTool", nil];
    }
    return _buttonShapeCreationToolIdentifiers;
}

@end

