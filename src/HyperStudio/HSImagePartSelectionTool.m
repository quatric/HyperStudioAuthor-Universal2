#import "HSImagePartSelectionTool.h"

@implementation HSImagePartSelectionTool

/* i386 ivar offsets: _workObject=0x28, _visualizationCanvasLayer=0x2c, _createsWorkImage=0x30, _userInfo=0x34, _delegate=0x38 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_001426fb @ 001426fb, 131 bytes * /

void FUN_001426fb(HSImagePartSelectionTool *self,SEL _cmd,id handleCancelOperationFromCanvasLayer)

{
  id pvVar1;
  SEL op;
  undefined *puVar2;
  
  puVar2 = sel_handleCancelOperationForImagePartSelectionTool_;
  pvVar1 = _objc_msgSend(self->_delegate,sel_respondsToSelector_,
                         sel_handleCancelOperationForImagePartSelectionTool_);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager,puVar2);
    self = (HSImagePartSelectionTool *)0x1;
    op = sel_selectToolWithTag_;
  }
  else {
    pvVar1 = self->_delegate;
    op = sel_handleCancelOperationForImagePartSelectionTool_;
  }
  _objc_msgSend(pvVar1,op,self);
  return;
}

*/
- (void)handleCancelOperationFromCanvasLayer:(id)aLayer
{
    if ([_delegate respondsToSelector:@selector(handleCancelOperationForImagePartSelectionTool:)]) {
        [_delegate handleCancelOperationForImagePartSelectionTool:self];
    }
    else {
        [(HSToolManager *)[HSToolManager sharedToolManager] selectToolWithTag:1];
    }
}

- (void)handleInsertNewlineFromCanvasLayer:(id)aLayer
{
    if ([_delegate respondsToSelector:@selector(handleInsertNewlineForImagePartSelectionTool:)]) {
        [_delegate handleInsertNewlineForImagePartSelectionTool:self];
    }
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (void *)userInfo
{
    return _userInfo;
}

- (void)setUserInfo:(void *)aInfo
{
    _userInfo = aInfo;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001427d4 @ 001427d4, 456 bytes * /

CGAffineTransform *
FUN_001427d4(CGAffineTransform *__return_storage_ptr__,HSImagePartSelectionTool *self,SEL _cmd)

{
  ulonglong uVar1;
  id self_00;
  CGAffineTransform *extraout_EAX;
  CGAffineTransform *pCVar2;
  float local_5c;
  float local_58;
  float local_54;
  float local_50;
  float local_4c;
  float local_48;
  float local_44;
  float local_40;
  float local_38;
  HSImagePartSelectionTool *local_34;
  undefined *local_30;
  float local_2c;
  float fStack_28;
  float local_24;
  float fStack_20;
  float local_1c;
  float fStack_18;
  
  local_34 = self;
  local_30 = PTR_s_HSBaseBitmapTool_00351680;
  _objc_msgSendSuper_stret(&local_2c,&local_34,sel_imageToViewTransform);
  self_00 = _objc_msgSend(self,sel_geometryAttributes);
  if (self_00 == (id)0x0) {
    pCVar2 = (CGAffineTransform *)0x0;
  }
  else {
    _objc_msgSend_stret(&local_44,self_00,sel_frameBoundingRect);
    local_1c = local_44 * local_2c + local_40 * local_24 + local_1c + local_24 * local_38;
    fStack_18 = fStack_28 * local_44 + fStack_20 * local_40 + fStack_18 + fStack_20 * local_38;
    uVar1 = CONCAT44(fStack_20,local_24);
    local_24 = -local_24;
    fStack_20 = -fStack_20;
    _objc_msgSend_stret(&local_5c,self,sel_transformForHiResolution_,CONCAT44(fStack_28,local_2c),
                        uVar1 ^ 0x8000000080000000,CONCAT44(fStack_18,local_1c));
    pCVar2 = extraout_EAX;
    fStack_20 = local_50;
    local_24 = local_54;
    local_2c = local_5c;
    fStack_28 = local_58;
    fStack_18 = local_48;
    local_1c = local_4c;
  }
  __return_storage_ptr__->a = local_2c;
  __return_storage_ptr__->b = fStack_28;
  __return_storage_ptr__->c = local_24;
  __return_storage_ptr__->d = fStack_20;
  __return_storage_ptr__->tx = local_1c;
  __return_storage_ptr__->ty = fStack_18;
  return pCVar2;
}

*/
- (CGAffineTransform)imageToViewTransform
{
    CGAffineTransform transform = [super imageToViewTransform];
    id geometry = [self geometryAttributes];
    if (geometry != nil) {
        NSRect frame = [geometry frameBoundingRect];
        transform = CGAffineTransformTranslate(transform, frame.origin.x, frame.origin.y + frame.size.height);
        transform = CGAffineTransformScale(transform, 1.0, -1.0);
        transform = [self transformForHiResolution:transform];
    }
    return transform;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0014299c @ 0014299c, 301 bytes * /

CGAffineTransform *
FUN_0014299c(CGAffineTransform *__return_storage_ptr__,HSImagePartSelectionTool *self,SEL _cmd,
            CGAffineTransform transformForHiResolution)

{
  id pvVar1;
  CGAffineTransform *pCVar2;
  double dVar3;
  float local_24;
  float fStack_20;
  float local_1c;
  float fStack_18;
  float local_14;
  float fStack_10;
  
  local_24 = transformForHiResolution.a;
  fStack_20 = transformForHiResolution.b;
  local_1c = transformForHiResolution.c;
  fStack_18 = transformForHiResolution.d;
  local_14 = transformForHiResolution.tx;
  fStack_10 = transformForHiResolution.ty;
  pCVar2 = (CGAffineTransform *)PTR_0033605c;
  if (1138.0 < *(double *)PTR_0033605c || *(double *)PTR_0033605c == 1138.0) {
    pvVar1 = _objc_msgSend(self,sel_view);
    pvVar1 = _objc_msgSend(pvVar1,sel_window);
    dVar3 = _objc_msgSend_fpret(pvVar1,sel_backingScaleFactor);
    pCVar2 = (CGAffineTransform *)
             _CGAffineTransformScale
                       (&local_24,CONCAT44(fStack_20,local_24),CONCAT44(fStack_18,local_1c),
                        CONCAT44(fStack_10,local_14),1.0 / (float)dVar3,1.0 / (float)dVar3);
    transformForHiResolution.c = local_1c;
    transformForHiResolution.d = fStack_18;
    transformForHiResolution.tx = local_14;
    transformForHiResolution.ty = fStack_10;
    transformForHiResolution.a = local_24;
    transformForHiResolution.b = fStack_20;
  }
  __return_storage_ptr__->a = transformForHiResolution.a;
  __return_storage_ptr__->b = transformForHiResolution.b;
  __return_storage_ptr__->c = transformForHiResolution.c;
  __return_storage_ptr__->d = transformForHiResolution.d;
  __return_storage_ptr__->tx = transformForHiResolution.tx;
  __return_storage_ptr__->ty = transformForHiResolution.ty;
  return pCVar2;
}

*/
- (CGAffineTransform)transformForHiResolution:(CGAffineTransform)aResolution
{
    if (NSAppKitVersionNumber >= 1138.0) {
        CGFloat scale = 1.0 / (float)[[[self view] window] backingScaleFactor];
        aResolution = CGAffineTransformScale(aResolution, scale, scale);
    }
    return aResolution;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00142ac9 @ 00142ac9, 298 bytes * /

void FUN_00142ac9(HSImagePartSelectionTool *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  undefined4 local_34;
  undefined4 local_30;
  undefined8 local_2c;
  undefined8 local_24;
  undefined8 local_1c;
  
  if ((self->_createsWorkImage != '\0') && (self->_workObject != (id)0x0)) {
    local_34 = *(undefined4 *)PTR_0033607c;
    local_30 = *(undefined4 *)(PTR_0033607c + 4);
    pvVar1 = _objc_msgSend(self,sel_workImageOfSize_,&local_34);
    pvVar2 = _objc_msgSend(cls_HSImagePartSelectionToolWorkImage,sel_alloc);
    _objc_msgSend_stret(&local_2c,self,sel_workImageTransformForImageSize_);
    pvVar1 = _objc_msgSend(pvVar2,sel_initWithCGImage_affineTransform_,pvVar1,local_2c,local_24,
                           local_1c);
    pvVar2 = _objc_msgSend(self,sel_bitmapTool);
    _objc_msgSend(pvVar2,sel_setWorkImage_,pvVar1);
    _objc_msgSend(pvVar1,sel_release);
  }
  return;
}

*/
- (void)createWorkImageIfNeeded
{
    if (!_createsWorkImage || _workObject == nil) {
        return;
    }
    NSSize size = NSZeroSize;
    CGImageRef image = [self workImageOfSize:&size];
    HSImagePartSelectionToolWorkImage *workImage = [[HSImagePartSelectionToolWorkImage alloc] initWithCGImage:image affineTransform:[self workImageTransformForImageSize:size]];
    [[self bitmapTool] setWorkImage:workImage];
    [workImage release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00142bf3 @ 00142bf3, 623 bytes * /

CGAffineTransform *
FUN_00142bf3(CGAffineTransform *__return_storage_ptr__,HSImagePartSelectionTool *self,SEL _cmd,
            NSSize workImageTransformForImageSize)

{
  id self_00;
  id pvVar1;
  float extraout_EDX;
  longdouble lVar2;
  longdouble lVar3;
  float fVar4;
  float fVar5;
  float fVar6;
  ulonglong uVar7;
  ulonglong uVar8;
  ulonglong uVar9;
  undefined8 local_4c;
  undefined8 local_44;
  float local_3c;
  float fStack_38;
  float local_34;
  float fStack_30;
  float local_2c;
  float fStack_28;
  undefined4 local_24;
  undefined4 uStack_20;
  float local_1c;
  float fStack_18;
  
  local_3c = *(float *)PTR_00336088;
  fStack_38 = *(float *)(PTR_00336088 + 4);
  local_34 = *(float *)(PTR_00336088 + 8);
  fStack_30 = *(float *)(PTR_00336088 + 0xc);
  local_2c = *(float *)(PTR_00336088 + 0x10);
  fStack_28 = *(float *)(PTR_00336088 + 0x14);
  self_00 = _objc_msgSend(self,sel_geometryAttributes);
  if (self_00 != (id)0x0) {
    pvVar1 = _objc_msgSend(self->_workObject,sel_image);
    if (pvVar1 != (id)0x0) {
      pvVar1 = _objc_msgSend(self_00,sel_size);
      _objc_msgSend_stret(&local_3c,self_00,sel_affineTransform);
      if ((workImageTransformForImageSize.height != 0.0) ||
         (NAN(workImageTransformForImageSize.height))) {
        fVar6 = -extraout_EDX / workImageTransformForImageSize.height;
      }
      else {
        fVar6 = -1.0;
      }
      if ((workImageTransformForImageSize.width != 0.0) ||
         (NAN(workImageTransformForImageSize.width))) {
        fVar4 = (float)pvVar1 / workImageTransformForImageSize.width;
      }
      else {
        fVar4 = 1.0;
      }
      fVar5 = fStack_30 * fVar6;
      local_34 = fVar6 * local_34;
      fVar6 = fStack_38 * fVar4;
      local_3c = fVar4 * local_3c;
      fStack_38 = -fVar6;
      fStack_30 = -fVar5;
      local_24 = *(undefined4 *)PTR_0033608c;
      uStack_20 = *(undefined4 *)(PTR_0033608c + 4);
      local_1c = workImageTransformForImageSize.width;
      fStack_18 = workImageTransformForImageSize.height;
      uVar9 = CONCAT44(fStack_28,local_2c) ^ 0x8000000000000000;
      uVar7 = CONCAT44(fVar6,local_3c) ^ 0x8000000000000000;
      uVar8 = CONCAT44(fVar5,local_34) ^ 0x8000000000000000;
      fStack_28 = -fStack_28;
      _CGRectApplyAffineTransform();
      lVar2 = (longdouble)
              _CGRectGetMinY(local_4c,local_44,workImageTransformForImageSize,uVar7,uVar8,uVar9);
      lVar3 = (longdouble)_CGRectGetMinX(local_4c,local_44);
      local_2c = local_2c - (float)lVar3;
      fStack_28 = fStack_28 - (float)lVar2;
    }
  }
  __return_storage_ptr__->a = local_3c;
  __return_storage_ptr__->b = fStack_38;
  __return_storage_ptr__->c = local_34;
  __return_storage_ptr__->d = fStack_30;
  __return_storage_ptr__->tx = local_2c;
  __return_storage_ptr__->ty = fStack_28;
  return __return_storage_ptr__;
}

*/
- (CGAffineTransform)workImageTransformForImageSize:(NSSize)aSize
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    id geometry = [self geometryAttributes];
    if (geometry != nil && [_workObject image] != nil) {
        NSSize size = [(id<HSGeometryAttributes>)geometry size];
        transform = [geometry affineTransform];
        CGFloat scaleY = (aSize.height != 0.0) ? -size.height / aSize.height : -1.0;
        CGFloat scaleX = (aSize.width != 0.0) ? size.width / aSize.width : 1.0;
        transform = CGAffineTransformConcat(CGAffineTransformMakeScale(scaleX, scaleY), transform);
        transform = CGAffineTransformConcat(transform, CGAffineTransformMakeScale(1.0, -1.0));
        CGRect bounds = CGRectApplyAffineTransform(CGRectMake(CGPointZero.x, CGPointZero.y, aSize.width, aSize.height), transform);
        CGFloat minY = CGRectGetMinY(bounds);
        CGFloat minX = CGRectGetMinX(bounds);
        transform.tx -= minX;
        transform.ty -= minY;
    }
    return transform;
}

- (struct CGImage *)workImageOfSize:(NSSize *)aSize
{
    return [[HSCurrentImageDrawing drawingForImageObject:_workObject] currentCGImageOfSize:aSize];
}

- (BOOL)isActiveAtPoint:(NSPoint)aPoint
{
    return [_visualizationCanvasLayer hitTestItem:aPoint] != nil;
}

- (id)geometryAttributes
{
    return [_workObject queryHyperInterface:@protocol(HSGeometryAttributes)];
}

- (id)workObject
{
    return _workObject;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0014244c @ 0014244c, 403 bytes * /

void FUN_0014244c(HSImagePartSelectionTool *self,SEL _cmd,id setWorkObject)

{
  undefined *puVar1;
  undefined *puVar2;
  id pvVar3;
  id pvVar4;
  undefined *puVar5;
  
  if (self->_workObject != setWorkObject) {
    puVar5 = &DAT_00373954;
    puVar1 = _objc_msgSend(self->_workObject,sel_queryHyperInterface_,&DAT_00373954);
    if (puVar1 != (undefined *)0x0) {
      puVar5 = &DAT_003739a4;
      puVar2 = _objc_msgSend(self->_workObject,sel_queryHyperInterface_,&DAT_003739a4);
      if (puVar2 != (undefined *)0x0) {
        pvVar3 = _objc_msgSend(self,sel_view,puVar5);
        pvVar3 = _objc_msgSend(pvVar3,sel_ignoredChildren);
        pvVar3 = _objc_msgSend(pvVar3,sel_containsObject_,puVar2);
        puVar5 = puVar2;
        if ((char)pvVar3 != '\0') {
          pvVar3 = _objc_msgSend(self,sel_view,puVar2);
          puVar5 = puVar1;
          _objc_msgSend(pvVar3,sel_reenableVisualizationForNode_,puVar1);
        }
      }
      pvVar3 = _objc_msgSend(self,sel_visualizationCanvasLayer,puVar5);
      _objc_msgSend(pvVar3,sel_removeItemForNode_,puVar1);
      puVar5 = puVar1;
    }
    self->_workObject = setWorkObject;
    _objc_msgSend(self,sel_createWorkImageIfNeeded,puVar5);
    puVar5 = &DAT_00373954;
    pvVar3 = _objc_msgSend(self->_workObject,sel_queryHyperInterface_,&DAT_00373954);
    if (pvVar3 != (id)0x0) {
      pvVar4 = _objc_msgSend(self,sel_visualizationCanvasLayer,puVar5);
      _objc_msgSend(pvVar4,sel_addItemForNode_,pvVar3);
      pvVar4 = _objc_msgSend(self,sel_view);
      _objc_msgSend(pvVar4,sel_disableVisualizationForNode_,pvVar3);
    }
  }
  return;
}

*/
- (void)setWorkObject:(id)aObject
{
    if (_workObject == aObject) {
        return;
    }
    id oldNode = [_workObject queryHyperInterface:@protocol(HSNodeAttributes)];
    if (oldNode != nil) {
        id oldChild = [_workObject queryHyperInterface:@protocol(HSNodeChild)];
        if (oldChild != nil && [[(HSUserObjectView *)[self view] ignoredChildren] containsObject:oldChild]) {
            [(HSUserObjectView *)[self view] reenableVisualizationForNode:oldNode];
        }
        [[self visualizationCanvasLayer] removeItemForNode:oldNode];
    }
    _workObject = aObject;
    [self createWorkImageIfNeeded];
    id newNode = [_workObject queryHyperInterface:@protocol(HSNodeAttributes)];
    if (newNode != nil) {
        [[self visualizationCanvasLayer] addItemForNode:newNode];
        [(HSUserObjectView *)[self view] disableVisualizationForNode:newNode];
    }
}

- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly
{
    id pvVar1_2;

    [self setWorkObject:nil];
    pvVar1_2 = [[self view] rootCanvasLayer];
    [[pvVar1_2 vectorToolsCanvasLayer] removeAllSublayers];
    [pvVar1_2 setEnabledSublayerIdentifiers:nil];
    [super finalizeBeforeDeactivateExplicitly:aExplicitly];
}

- (void)didActivateExplicitly:(BOOL)aExplicitly
{
    id pvVar1_2;
    id pvVar2_2;

    [super didActivateExplicitly:aExplicitly];
    pvVar1_2 = [[self view] rootCanvasLayer];
    pvVar2_2 = [[HSBaseBitmapToolCanvasLayer new] autorelease];
    [pvVar2_2 setTool:self];
    [[pvVar1_2 vectorToolsCanvasLayer] addSublayer:[[HSDisablingCanvasLayer new] autorelease]];
    [[pvVar1_2 vectorToolsCanvasLayer] addSublayer:[self visualizationCanvasLayer]];
    [[pvVar1_2 vectorToolsCanvasLayer] addSublayer:pvVar2_2];
    [[pvVar1_2 vectorToolsCanvasLayer] addSublayer:[[[HSHandleInsertNewlineCanvasLayer alloc] initWithOwner:self] autorelease]];
    [[pvVar1_2 vectorToolsCanvasLayer] addSublayer:[[[HSHandleCancelOperationCanvasLayer alloc] initWithOwner:self] autorelease]];
    [pvVar1_2 setEnabledSublayerIdentifiers:[pvVar1_2 vectorToolsIdentifiers]];
}

- (id)visualizationCanvasLayer
{
    id pvVar1;

    pvVar1 = _visualizationCanvasLayer;
    if (pvVar1 == nil) {
        pvVar1 = [[HSAuxiliaryVisualizationCanvasLayer alloc] initForRenderingCardNodes:NO];
        _visualizationCanvasLayer = pvVar1;
    }
    return pvVar1;
}

- (BOOL)allowsSelection
{
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0014319d @ 0014319d, 1375 bytes * /

CGPath * FUN_0014319d(HSImagePartSelectionTool *self,SEL _cmd)

{
  undefined *puVar1;
  CGPath *pCVar2;
  id pvVar3;
  float fVar4;
  float fVar5;
  float fVar6;
  float fVar7;
  float fVar8;
  float fVar9;
  float local_b4;
  float local_b0;
  float local_ac;
  float local_9c;
  float local_94;
  float local_90;
  float local_8c;
  float local_88;
  float local_84;
  float local_80;
  float local_7c;
  float local_78;
  float local_74;
  float local_70;
  float local_6c;
  float local_68;
  float local_64;
  float local_60;
  float local_5c;
  float local_58;
  float local_54;
  float local_50;
  float local_4c;
  float local_48;
  float local_44;
  float local_40;
  float local_3c;
  float local_38;
  float local_34;
  float local_30;
  float local_2c;
  float local_28;
  float local_24;
  float local_20;
  float local_1c;
  float local_18;
  
  pCVar2 = (CGPath *)_CGPathCreateMutable();
  pvVar3 = _objc_msgSend(self,sel_bitmapTool);
  puVar1 = PTR_00336088;
  fVar4 = *(float *)PTR_00336088;
  fVar5 = *(float *)(PTR_00336088 + 4);
  pvVar3 = _objc_msgSend(pvVar3,sel_valueForKey_,&cfstr_selectionAffineTransform);
  local_6c = *(float *)(puVar1 + 8);
  local_68 = *(float *)(puVar1 + 0xc);
  local_64 = *(float *)(puVar1 + 0x10);
  local_60 = *(float *)(puVar1 + 0x14);
  local_74 = fVar4;
  local_70 = fVar5;
  _objc_msgSend(pvVar3,sel_getValue_,&local_74);
  pvVar3 = _objc_msgSend(self,sel_geometryAttributes);
  _objc_msgSend_stret(&local_5c,pvVar3,sel_affineTransform);
  local_90 = local_54;
  local_94 = local_5c;
  local_9c = local_58;
  local_ac = local_50;
  fVar4 = local_5c * local_50 - local_58 * local_54;
  local_b0 = local_48;
  local_b4 = local_4c;
  if ((fVar4 != 0.0) || (NAN(fVar4))) {
    local_94 = local_50 / fVar4;
    local_ac = local_5c / fVar4;
    local_9c = local_58 / -fVar4;
    local_b0 = -(local_9c * local_4c + local_ac * local_48);
    local_90 = local_54 / -fVar4;
    local_b4 = -(local_4c * local_94 + local_48 * local_90);
  }
  pvVar3 = _objc_msgSend(self,sel_view);
  _objc_msgSend_stret(&local_44,pvVar3,sel_viewSpaceToUserSpaceCGAffineTransform);
  _objc_msgSend_stret(&local_2c,self,sel_imageToViewTransform);
  fVar5 = local_24 * local_40 + local_20 * local_38;
  fVar9 = local_2c * local_40 + local_28 * local_38;
  fVar8 = local_74 * fVar9 + local_70 * fVar5;
  fVar6 = local_24 * local_44 + local_20 * local_3c;
  fVar7 = local_2c * local_44 + local_28 * local_3c;
  fVar4 = local_74 * fVar7 + local_70 * fVar6;
  local_8c = fVar4 * local_94 + fVar8 * local_90;
  local_88 = fVar4 * local_9c + fVar8 * local_ac;
  fVar8 = local_6c * fVar9 + local_68 * fVar5;
  fVar4 = local_6c * fVar7 + local_68 * fVar6;
  local_84 = fVar4 * local_94 + fVar8 * local_90;
  local_80 = fVar4 * local_9c + fVar8 * local_ac;
  fVar5 = fVar9 * local_64 + fVar5 * local_60 + local_1c * local_40 + local_18 * local_38 + local_30
  ;
  fVar4 = fVar7 * local_64 + fVar6 * local_60 + local_44 * local_1c + local_3c * local_18 + local_34
  ;
  local_7c = local_94 * fVar4 + local_90 * fVar5 + local_b4;
  local_78 = fVar4 * local_9c + fVar5 * local_ac + local_b0;
  pvVar3 = _objc_msgSend(self,sel_bitmapTool);
  pvVar3 = _objc_msgSend(pvVar3,sel_valueForKey_,&cfstr_selectionPath);
  _CGPathAddPath(pCVar2,&local_8c,pvVar3);
  return pCVar2;
}

*/
- (struct CGPath *)copiedCGPath
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGAffineTransform selectionTransform = CGAffineTransformIdentity;
    [[[self bitmapTool] valueForKey:@"selectionAffineTransform"] getValue:&selectionTransform];
    CGAffineTransform objectTransform = CGAffineTransformInvert([[self geometryAttributes] affineTransform]);
    CGAffineTransform viewToUser = [(HSUserObjectView *)[self view] viewSpaceToUserSpaceCGAffineTransform];
    CGAffineTransform imageToView = [self imageToViewTransform];
    CGAffineTransform transform = CGAffineTransformConcat(selectionTransform, CGAffineTransformConcat(imageToView, viewToUser));
    transform = CGAffineTransformConcat(transform, objectTransform);
    CGPathAddPath(path, &transform, (CGPathRef)[[self bitmapTool] valueForKey:@"selectionPath"]);
    return path;
}

- (void)dealloc
{
    [_visualizationCanvasLayer release];
    [super dealloc];
}

- (id)initWithBTTool:(id)aTool obeyLayoutGuiding:(BOOL)aGuiding resetOnSave:(BOOL)aSave createWorkImage:(BOOL)aImage
{
    self = [super initWithBTTool:aTool obeyLayoutGuiding:(unsigned int)aGuiding resetOnSave:(unsigned int)aSave];
    if (self != nil) {
        _createsWorkImage = aImage;
    }
    return self;
}

@end

@implementation HSImagePartSelectionToolWorkImage

/* i386 ivar offsets: _image=0x4, _affineTransform=0x8 */

- (struct CGColor *)colorAtPoint:(CGPoint)aPoint
{
    return nil;
}

- (struct CGImage *)coreGraphicsImage
{
    return nil;
}

- (struct CGColorSpace *)coreGraphicsColorSpace
{
    return nil;
}

- (struct CGPDFDocument *)coreGraphicsPDFDocument
{
    return nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001437d7 @ 001437d7, 281 bytes * /

void FUN_001437d7(HSImagePartSelectionToolWorkImage *self,SEL _cmd,CGContext *drawInCGContext,
                 CGPoint atPoint)

{
  CGImage *pCVar1;
  undefined8 uVar2;
  undefined8 uVar3;
  uint uVar4;
  uint uVar5;
  
  uVar3._0_4_ = (self->_affineTransform).c;
  uVar3._4_4_ = (self->_affineTransform).d;
  uVar2._0_4_ = (self->_affineTransform).a;
  uVar2._4_4_ = (self->_affineTransform).b;
  _CGContextConcatCTM(drawInCGContext,uVar2,uVar3,
                      CONCAT44((self->_affineTransform).ty + atPoint.y,
                               (self->_affineTransform).tx + atPoint.x));
  pCVar1 = self->_image;
  uVar4 = _CGImageGetHeight(pCVar1);
  uVar5 = _CGImageGetWidth(self->_image);
  _CGContextDrawImage(drawInCGContext,0,
                      CONCAT44((float)((double)((ulonglong)uVar4 | 0x4330000000000000) -
                                      4503599627370496.0),
                               (float)((double)((ulonglong)uVar5 | 0x4330000000000000) -
                                      4503599627370496.0)),pCVar1);
  return;
}

*/
- (void)drawInCGContext:(struct CGContext *)aContext atPoint:(CGPoint)aPoint
{
    CGAffineTransform transform = _affineTransform;
    transform.tx += aPoint.x;
    transform.ty += aPoint.y;
    CGContextConcatCTM(aContext, transform);
    CGContextDrawImage(aContext, CGRectMake(0.0, 0.0, CGImageGetWidth(_image), CGImageGetHeight(_image)), _image);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001438f0 @ 001438f0, 574 bytes * /

void FUN_001438f0(HSImagePartSelectionToolWorkImage *self,SEL _cmd,CGContext *drawInCGContext,
                 CGRect inRect)

{
  float fVar1;
  float fVar2;
  float fVar3;
  float fVar4;
  float fVar5;
  float fVar6;
  CGImage *pCVar7;
  id pvVar8;
  uint uVar9;
  uint uVar10;
  float extraout_EDX;
  float fVar11;
  float local_4c;
  
  pvVar8 = _objc_msgSend(self,sel_imageSize);
  if (((float)pvVar8 != 0.0) || (NAN((float)pvVar8))) {
    fVar11 = inRect.size.width / (float)pvVar8;
  }
  else {
    fVar11 = 1.0;
  }
  if ((extraout_EDX != 0.0) || (NAN(extraout_EDX))) {
    local_4c = inRect.size.height / extraout_EDX;
  }
  else {
    local_4c = 1.0;
  }
  fVar1 = (self->_affineTransform).a;
  fVar2 = (self->_affineTransform).b;
  fVar3 = (self->_affineTransform).tx;
  fVar4 = (self->_affineTransform).ty;
  fVar5 = (self->_affineTransform).c;
  fVar6 = (self->_affineTransform).d;
  _CGContextConcatCTM(drawInCGContext,
                      CONCAT44(fVar1 * 0.0 + fVar2 * local_4c,fVar1 * fVar11 + fVar2 * 0.0),
                      CONCAT44(fVar5 * 0.0 + fVar6 * local_4c,fVar5 * fVar11 + fVar6 * 0.0),
                      CONCAT44((inRect.origin.y - *(float *)(PTR_0033608c + 4) * local_4c) +
                               fVar3 * 0.0 + fVar4 * local_4c,
                               (inRect.origin.x - *(float *)PTR_0033608c * fVar11) +
                               fVar3 * fVar11 + fVar4 * 0.0));
  pCVar7 = self->_image;
  uVar9 = _CGImageGetHeight(pCVar7);
  uVar10 = _CGImageGetWidth(self->_image);
  _CGContextDrawImage(drawInCGContext,0,
                      CONCAT44((float)((double)((ulonglong)uVar9 | 0x4330000000000000) -
                                      4503599627370496.0),
                               (float)((double)((ulonglong)uVar10 | 0x4330000000000000) -
                                      4503599627370496.0)),pCVar7);
  return;
}

*/
- (void)drawInCGContext:(struct CGContext *)aContext inRect:(CGRect)aRect
{
    CGSize size = [self imageSize];
    CGFloat scaleX = (size.width != 0.0) ? aRect.size.width / size.width : 1.0;
    CGFloat scaleY = (size.height != 0.0) ? aRect.size.height / size.height : 1.0;
    CGAffineTransform placement = CGAffineTransformMake(scaleX, 0.0, 0.0, scaleY, aRect.origin.x - CGPointZero.x * scaleX, aRect.origin.y - CGPointZero.y * scaleY);
    CGContextConcatCTM(aContext, CGAffineTransformConcat(_affineTransform, placement));
    CGContextDrawImage(aContext, CGRectMake(0.0, 0.0, CGImageGetWidth(_image), CGImageGetHeight(_image)), _image);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00143b2e @ 00143b2e, 180 bytes * /

ulonglong FUN_00143b2e(HSImagePartSelectionToolWorkImage *self,SEL _cmd)

{
  uint uVar1;
  uint uVar2;
  longdouble lVar3;
  longdouble lVar4;
  
  uVar1 = _CGImageGetHeight(self->_image);
  lVar3 = (longdouble)_hypotf((self->_affineTransform).c,(self->_affineTransform).d);
  uVar2 = _CGImageGetWidth(self->_image);
  lVar4 = (longdouble)_hypotf((self->_affineTransform).a,(self->_affineTransform).b);
  return CONCAT44((float)((double)((ulonglong)uVar1 | 0x4330000000000000) - 4503599627370496.0) *
                  (float)lVar3,
                  (float)((double)((ulonglong)uVar2 | 0x4330000000000000) - 4503599627370496.0) *
                  (float)lVar4);
}

*/
- (CGSize)imageSize
{
    return CGSizeMake((CGFloat)CGImageGetWidth(_image) * hypot(_affineTransform.a, _affineTransform.b), (CGFloat)CGImageGetHeight(_image) * hypot(_affineTransform.c, _affineTransform.d));
}

- (void)dealloc
{
    CGImageRelease(_image);
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0014374a @ 0014374a, 141 bytes * /

id FUN_0014374a(HSImagePartSelectionToolWorkImage *self,SEL _cmd,CGImage *initWithCGImage,
               CGAffineTransform affineTransform)

{
  id pvVar1;
  undefined4 uVar2;
  HSImagePartSelectionToolWorkImage *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_NSObject_003516b0;
  pvVar1 = _objc_msgSendSuper(&local_14,sel_init);
  if (pvVar1 != (id)0x0) {
    uVar2 = _CGImageRetain(initWithCGImage);
    *(undefined4 *)((int)pvVar1 + 4) = uVar2;
    *(float *)((int)pvVar1 + 8) = affineTransform.a;
    *(float *)((int)pvVar1 + 0xc) = affineTransform.b;
    *(float *)((int)pvVar1 + 0x10) = affineTransform.c;
    *(float *)((int)pvVar1 + 0x14) = affineTransform.d;
    *(float *)((int)pvVar1 + 0x18) = affineTransform.tx;
    *(float *)((int)pvVar1 + 0x1c) = affineTransform.ty;
  }
  return pvVar1;
}

*/
- (id)initWithCGImage:(struct CGImage *)aImage affineTransform:(CGAffineTransform)aTransform
{
    self = [super init];
    if (self != nil) {
        _image = CGImageRetain(aImage);
        _affineTransform = aTransform;
    }
    return self;
}

- (id)init
{
    [self release];
    return nil;
}

@end

