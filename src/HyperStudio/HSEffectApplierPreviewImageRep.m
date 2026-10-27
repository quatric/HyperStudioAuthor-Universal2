#import "HSEffectApplierPreviewImageRep.h"

@implementation HSEffectApplierPreviewImageRep

/* i386 ivar offsets: _image=0x1c */

/* --- i386 decompilation (Ghidra) ---
/* FUN_0019e531 @ 0019e531, 167 bytes * /

BOOL FUN_0019e531(HSEffectApplierPreviewImageRep *self,SEL _cmd)

{
  undefined8 uVar1;
  id pvVar2;
  id self_00;
  undefined4 extraout_EDX;
  
  uVar1 = *(undefined8 *)PTR_00336074;
  pvVar2 = _objc_msgSend(self,sel_size);
  self_00 = _objc_msgSend(self->_image,sel_bestRepresentationForDevice_,0);
  _objc_msgSend(self_00,sel_drawInRect_,uVar1,CONCAT44(extraout_EDX,pvVar2));
  return '\x01';
}

*/
- (BOOL)draw
{
    NSSize size = [self size];
    [[_image bestRepresentationForDevice:nil] drawInRect:NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, size.width, size.height)];
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0019e5d8 @ 0019e5d8, 122 bytes * /

id FUN_0019e5d8(HSEffectApplierPreviewImageRep *self,SEL _cmd,NSZone *copyWithZone)

{
  id pvVar1;
  id pvVar2;
  undefined4 extraout_EDX;
  
  pvVar1 = _objc_msgSend(self,sel_class);
  pvVar1 = _objc_msgSend(pvVar1,sel_allocWithZone_,copyWithZone);
  pvVar2 = _objc_msgSend(self,sel_size);
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithImage_size_,self->_image,pvVar2,extraout_EDX);
  return pvVar1;
}

*/
- (id)copyWithZone:(NSZone *)aZone
{
    return [[[self class] allocWithZone:aZone] initWithImage:_image size:[self size]];
}

- (void)dealloc
{
    [_image release];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0019e652 @ 0019e652, 566 bytes * /

id FUN_0019e652(HSEffectApplierPreviewImageRep *self,SEL _cmd,id initWithImage,NSSize size)

{
  char cVar1;
  id self_00;
  id pvVar2;
  id pvVar3;
  float extraout_EDX;
  undefined4 uVar4;
  id local_24;
  float local_20;
  HSEffectApplierPreviewImageRep *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_NSImageRep_00352f70;
  self_00 = _objc_msgSendSuper(&local_1c,sel_init);
  if ((self_00 == (id)0x0) || (initWithImage == (id)0x0)) {
    _objc_msgSend(self_00,sel_release);
    self_00 = (id)0x0;
  }
  else {
    local_20 = size.height;
    local_24 = (id)size.width;
    pvVar2 = _objc_msgSend(initWithImage,sel_retain);
    *(id *)((int)self_00 + 0x1c) = pvVar2;
    cVar1 = _NSEqualSizes(*(undefined4 *)PTR_0033607c,*(undefined4 *)(PTR_0033607c + 4),size.width,
                          size.height);
    if (cVar1 != '\0') {
      local_24 = _objc_msgSend(*(id *)((int)self_00 + 0x1c),sel_size);
      local_20 = extraout_EDX;
    }
    _objc_msgSend(self_00,sel_setSize_,local_24,local_20);
    uVar4 = 0;
    pvVar2 = _objc_msgSend(*(id *)((int)self_00 + 0x1c),sel_bestRepresentationForDevice_,0);
    if (pvVar2 != (id)0x0) {
      pvVar3 = _objc_msgSend(pvVar2,sel_hasAlpha,uVar4,local_20);
      _objc_msgSend(self_00,sel_setAlpha_,(int)(char)pvVar3);
      pvVar3 = _objc_msgSend(pvVar2,sel_isOpaque);
      _objc_msgSend(self_00,sel_setOpaque_,(int)(char)pvVar3);
      pvVar3 = _objc_msgSend(pvVar2,sel_colorSpaceName);
      _objc_msgSend(self_00,sel_setColorSpaceName_,pvVar3);
      pvVar3 = _objc_msgSend(pvVar2,sel_bitsPerSample);
      _objc_msgSend(self_00,sel_setBitsPerSample_,pvVar3);
      pvVar3 = _objc_msgSend(pvVar2,sel_pixelsWide);
      _objc_msgSend(self_00,sel_setPixelsWide_,pvVar3);
      pvVar2 = _objc_msgSend(pvVar2,sel_pixelsHigh);
      _objc_msgSend(self_00,sel_setPixelsHigh_,pvVar2);
    }
  }
  return self_00;
}

*/
- (id)initWithImage:(id)aImage size:(NSSize)aSize
{
    self = [super init];
    if (self == nil || aImage == nil) {
        [self release];
        return nil;
    }
    _image = [aImage retain];
    if (NSEqualSizes(NSZeroSize, aSize)) {
        aSize = [_image size];
    }
    [self setSize:aSize];
    NSImageRep *rep = [_image bestRepresentationForDevice:nil];
    if (rep != nil) {
        [self setAlpha:[rep hasAlpha]];
        [self setOpaque:[rep isOpaque]];
        [self setColorSpaceName:[rep colorSpaceName]];
        [self setBitsPerSample:[rep bitsPerSample]];
        [self setPixelsWide:[rep pixelsWide]];
        [self setPixelsHigh:[rep pixelsHigh]];
    }
    return self;
}

@end

@implementation HSHyperObjectEffectApplier

/* i386 ivar offsets: _originalObject=0x4, _undoActionName=0x8 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_0019c89f @ 0019c89f, 298 bytes * /

id FUN_0019c89f(id self,SEL _cmd,id effectApplierForHyperObject)

{
  id pvVar1;
  undefined *puVar2;
  undefined *self_00;
  undefined *puVar3;
  
  puVar3 = effectApplierForHyperObject;
  pvVar1 = _objc_msgSend(cls_HSEditorWindowController,sel_isValidSelectionTool_,
                         effectApplierForHyperObject);
  self_00 = cls_HSGraphicSelectionToolEffectApplier;
  puVar2 = effectApplierForHyperObject;
  if ((char)pvVar1 == '\0') {
    puVar3 = &DAT_0037b348;
    puVar2 = _objc_msgSend(effectApplierForHyperObject,sel_queryHyperInterface_,&DAT_0037b348);
    self_00 = cls_HSImageObjectAttributesEffectApplier;
    if (puVar2 == (undefined *)0x0) {
      puVar3 = &DAT_0037b53c;
      puVar2 = _objc_msgSend(effectApplierForHyperObject,sel_queryHyperInterface_,&DAT_0037b53c);
      self_00 = cls_HSImageMutableAttributesEffectApplier;
      if (puVar2 == (undefined *)0x0) {
        puVar3 = &DAT_0037b550;
        puVar2 = _objc_msgSend(effectApplierForHyperObject,sel_queryHyperInterface_,&DAT_0037b550);
        self_00 = cls_HSButtonObjectAttributesEffectApplier;
        if (puVar2 == (undefined *)0x0) {
          puVar3 = &DAT_0037b848;
          puVar2 = _objc_msgSend(effectApplierForHyperObject,sel_queryHyperInterface_,&DAT_0037b848)
          ;
          self_00 = cls_HSEditableImageAttributesEffectApplier;
          if (puVar2 == (undefined *)0x0) {
            pvVar1 = (id)0x0;
            goto LAB_0019c9b0;
          }
        }
      }
    }
  }
  pvVar1 = _objc_msgSend(self_00,sel_alloc,puVar3);
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithHyperObject_,puVar2);
  puVar3 = puVar2;
LAB_0019c9b0:
  pvVar1 = _objc_msgSend(pvVar1,sel_autorelease,puVar3);
  return pvVar1;
}

*/
+ (id)effectApplierForHyperObject:(id)aObject
{
    Class applierClass;
    id object;
    if ([HSEditorWindowController isValidSelectionTool:aObject]) {
        applierClass = [HSGraphicSelectionToolEffectApplier class];
        object = aObject;
    } else if ((object = [aObject queryHyperInterface:@protocol(HSImageObjectAttributes)]) != nil) {
        applierClass = [HSImageObjectAttributesEffectApplier class];
    } else if ((object = [aObject queryHyperInterface:@protocol(HSImageMutableAttributes)]) != nil) {
        applierClass = [HSImageMutableAttributesEffectApplier class];
    } else if ((object = [aObject queryHyperInterface:@protocol(HSButtonObjectAttributes)]) != nil) {
        applierClass = [HSButtonObjectAttributesEffectApplier class];
    } else if ((object = [aObject queryHyperInterface:@protocol(HSEditableImageAttributes)]) != nil) {
        applierClass = [HSEditableImageAttributesEffectApplier class];
    } else {
        return nil;
    }
    return [[[applierClass alloc] initWithHyperObject:object] autorelease];
}

- (void)setUndoActionName:(id)aName
{
    if (_undoActionName != aName) {
        [_undoActionName release];
        _undoActionName = [aName retain];
    }
}

- (id)undoActionName
{
    return _undoActionName;
}

- (void)applyHyperEffect:(id)aEffect
{

}

- (void)applyEffectWithDelegate:(id)aDelegate userInfo:(void *)aInfo
{

}

- (id)originalObject
{
    return _originalObject;
}

- (id)previewObject
{
    return _originalObject;
}

- (id)previewImageForImage:(id)aImage
{
    return aImage;
}

- (id)previewImage
{
    return nil;
}

- (void)dealloc
{
    [_originalObject release];
    [_undoActionName release];
    [super dealloc];
}

- (id)initWithHyperObject:(id)aObject
{
    [super release];
    return nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0019ca77 @ 0019ca77, 115 bytes * /

id FUN_0019ca77(HSHyperObjectEffectApplier *self,SEL _cmd,
               id HSHyperObjectEffectApplier_initWithHyperObject)

{
  id self_00;
  id pvVar1;
  HSHyperObjectEffectApplier *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_NSObject_00352eb0;
  self_00 = _objc_msgSendSuper(&local_14,sel_init);
  if (self_00 != (id)0x0) {
    pvVar1 = _objc_msgSend(HSHyperObjectEffectApplier_initWithHyperObject,sel_retain);
    *(id *)((int)self_00 + 4) = pvVar1;
    if (pvVar1 != (id)0x0) {
      return self_00;
    }
  }
  _objc_msgSend(self_00,sel_release);
  return (id)0x0;
}

*/
- (id)HSHyperObjectEffectApplier_initWithHyperObject:(id)aObject
{
    self = [super init];
    if (self != nil) {
        _originalObject = [aObject retain];
        if (_originalObject != nil) {
            return self;
        }
    }
    [self release];
    return nil;
}

@end

@implementation HSHyperProxyEffectApplier

/* i386 ivar offsets: _previewObject=0xc, _allHyperInterfaces=0x10, _coreImageEffect=0x14, _quickTimeEffect=0x18, _preEffectApplyingTransform=0x1c, _postEffectApplyingTransform=0x34 */

+ (SEL)delegateSelector
{
    return (SEL)0x0;
}

- (void)applyHyperEffect:(id)aEffect
{
    if (aEffect != nil) {
        [self applyEffectWithDelegate:self userInfo:aEffect];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0019cbf3 @ 0019cbf3, 850 bytes * /

void FUN_0019cbf3(HSHyperProxyEffectApplier *self,SEL _cmd,id applyEffectWithDelegate,void *userInfo
                 )

{
  id pvVar1;
  undefined *puVar2;
  undefined *puVar3;
  id self_00;
  id self_01;
  id pvVar4;
  int iVar5;
  int iVar6;
  char local_7d;
  id local_7c;
  int local_74 [22];
  void *local_1c;
  id local_18;
  HSHyperProxyEffectApplier *local_14;
  
  local_14 = self;
  local_18 = applyEffectWithDelegate;
  local_1c = userInfo;
  pvVar1 = _objc_msgSend(self,sel_class);
  puVar2 = _objc_msgSend(pvVar1,sel_delegateSelector);
  puVar3 = puVar2;
  pvVar1 = _objc_msgSend(local_18,sel_respondsToSelector_,puVar2);
  if ((char)pvVar1 != '\0') {
    local_7c = (id)0x0;
    local_7d = '\0';
    pvVar1 = _objc_msgSend(local_14,sel_undoActionName,puVar3);
    if (pvVar1 != (id)0x0) {
      pvVar1 = _objc_msgSend(local_14,sel_previewObject,puVar3);
      pvVar1 = _objc_msgSend(pvVar1,sel_hyperObject);
      puVar3 = sel_undoManager;
      pvVar1 = _objc_msgSend(pvVar1,sel_respondsToSelector_,sel_undoManager);
      if ((char)pvVar1 != '\0') {
        pvVar1 = _objc_msgSend(local_14,sel_previewObject,puVar3);
        pvVar1 = _objc_msgSend(pvVar1,sel_hyperObject);
        local_7c = _objc_msgSend(pvVar1,sel_undoManager);
      }
    }
    if (local_7c != (id)0x0) {
      pvVar1 = _objc_msgSend(local_7c,sel_groupsByEvent,puVar3);
      local_7d = (char)pvVar1;
      _objc_msgSend(local_7c,sel_setGroupsByEvent_,0);
      _objc_msgSend(local_7c,sel_beginUndoGrouping);
      puVar3 = _objc_msgSend(local_14,sel_undoActionName);
      _objc_msgSend(local_7c,sel_setMultipleActionsName_,puVar3);
    }
    pvVar1 = _objc_msgSend(cls_NSAutoreleasePool,sel_new,puVar3);
    self_00 = _objc_msgSend(local_14->_allHyperInterfaces,sel_objectEnumerator);
    while( true ) {
      self_01 = _objc_msgSend(self_00,sel_nextObject,puVar3);
      if (self_01 == (id)0x0) break;
      puVar3 = &DAT_0037baf0;
      pvVar4 = _objc_msgSend(self_01,sel_queryHyperInterface_,&DAT_0037baf0);
      pvVar4 = _objc_msgSend(pvVar4,sel_isLocked);
      if ((char)pvVar4 == '\0') {
        _objc_exception_try_enter(local_74);
        iVar5 = __setjmp(local_74);
        if (iVar5 == 0) {
          puVar3 = puVar2;
          _objc_msgSend(local_18,sel_performSelector_withObject_withObject_,puVar2,self_01,local_1c)
          ;
        }
        else {
          iVar6 = _objc_exception_extract(local_74);
          _objc_exception_try_enter(local_74);
          iVar5 = __setjmp(local_74);
          if (iVar5 == 0) {
            iVar5 = _objc_exception_match(cls_NSException,iVar6);
            if (iVar5 != 0) goto LAB_0019ce00;
            _objc_exception_try_exit(local_74);
          }
          else {
            iVar6 = _objc_exception_extract(local_74);
          }
          if (iVar6 != 0) {
                    /* WARNING: Subroutine does not return * /
            _objc_exception_throw(iVar6);
          }
        }
LAB_0019ce00:
        _objc_exception_try_exit(local_74);
      }
    }
    _objc_msgSend(pvVar1,sel_release,puVar3);
    if (local_7c != (id)0x0) {
      _objc_msgSend(local_7c,sel_endUndoGrouping);
      _objc_msgSend(local_7c,sel_setGroupsByEvent_,(int)local_7d);
    }
  }
  return;
}

*/
- (void)applyEffectWithDelegate:(id)aDelegate userInfo:(void *)aInfo
{
    SEL selector = [[self class] delegateSelector];
    if (![aDelegate respondsToSelector:selector]) {
        return;
    }
    NSUndoManager *undoManager = nil;
    BOOL groupsByEvent = NO;
    if ([self undoActionName] != nil && [[[self previewObject] hyperObject] respondsToSelector:@selector(undoManager)]) {
        undoManager = [[[self previewObject] hyperObject] undoManager];
    }
    if (undoManager != nil) {
        groupsByEvent = [undoManager groupsByEvent];
        [undoManager setGroupsByEvent:NO];
        [undoManager beginUndoGrouping];
        [undoManager setActionName:[self undoActionName]];
    }
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    for (id object in _allHyperInterfaces) {
        if ([[object queryHyperInterface:@protocol(HSCardObjectAttributes)] isLocked]) {
            continue;
        }
        @try {
            [aDelegate performSelector:selector withObject:object withObject:(id)aInfo];
        } @catch (NSException *exception) {
        }
    }
    [pool release];
    if (undoManager != nil) {
        [undoManager endUndoGrouping];
        [undoManager setGroupsByEvent:groupsByEvent];
    }
}

- (BOOL)doesObjectHaveEffect
{
    if (_coreImageEffect == nil) {
        return _quickTimeEffect != nil;
    }
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0019cf4a @ 0019cf4a, 854 bytes * /

void FUN_0019cf4a(HSHyperProxyEffectApplier *self,SEL _cmd,id collectEffectSettingsForPreviewObject)

{
  float fVar1;
  float fVar2;
  float fVar3;
  float fVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  float extraout_EDX;
  float extraout_EDX_00;
  float fVar8;
  float fVar9;
  undefined *puVar10;
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
  
  if (collectEffectSettingsForPreviewObject != (id)0x0) {
    puVar10 = &DAT_0037b938;
    pvVar5 = _objc_msgSend(collectEffectSettingsForPreviewObject,sel_queryHyperInterface_,
                           &DAT_0037b938);
    if (pvVar5 != (id)0x0) {
      pvVar6 = _objc_msgSend(pvVar5,sel_affineFrameSize,puVar10);
      pvVar7 = _objc_msgSend(collectEffectSettingsForPreviewObject,sel_queryHyperInterface_,
                             &DAT_0037bac8);
      pvVar5 = pvVar6;
      fVar9 = extraout_EDX;
      if (pvVar7 == (id)0x0) {
        pvVar7 = _objc_msgSend(collectEffectSettingsForPreviewObject,sel_queryHyperInterface_,
                               &DAT_0037badc);
        puVar10 = PTR_00336088;
        if (pvVar7 == (id)0x0) {
          fVar9 = *(float *)PTR_00336088;
          fVar8 = *(float *)(PTR_00336088 + 4);
          (self->_preEffectApplyingTransform).a = fVar9;
          (self->_preEffectApplyingTransform).b = fVar8;
          fVar1 = *(float *)(puVar10 + 8);
          (self->_preEffectApplyingTransform).c = fVar1;
          fVar2 = *(float *)(puVar10 + 0xc);
          (self->_preEffectApplyingTransform).d = fVar2;
          fVar3 = *(float *)(puVar10 + 0x10);
          (self->_preEffectApplyingTransform).tx = fVar3;
          fVar4 = *(float *)(puVar10 + 0x14);
          (self->_preEffectApplyingTransform).ty = fVar4;
          (self->_postEffectApplyingTransform).a = fVar9;
          (self->_postEffectApplyingTransform).b = fVar8;
          (self->_postEffectApplyingTransform).c = fVar1;
          (self->_postEffectApplyingTransform).d = fVar2;
          (self->_postEffectApplyingTransform).tx = fVar3;
          (self->_postEffectApplyingTransform).ty = fVar4;
          return;
        }
        pvVar7 = _objc_msgSend(pvVar7,sel_quickTimeEffectAdjustedToSize_,pvVar6,extraout_EDX);
        pvVar7 = _objc_msgSend(pvVar7,sel_retain);
        self->_quickTimeEffect = pvVar7;
      }
      else {
        pvVar7 = _objc_msgSend(pvVar7,sel_coreImageEffectAdjustedToSize_,pvVar6,extraout_EDX);
        pvVar7 = _objc_msgSend(pvVar7,sel_retain);
        self->_coreImageEffect = pvVar7;
      }
      pvVar5 = _objc_msgSend(self,sel_previewImage,pvVar5,fVar9);
      pvVar5 = _objc_msgSend(pvVar5,sel_size);
      puVar10 = PTR_00336088;
      fVar9 = 0.0;
      if (((float)pvVar5 != 0.0) || (NAN((float)pvVar5))) {
        fVar9 = (float)pvVar6 / (float)pvVar5;
      }
      fVar8 = 0.0;
      if ((extraout_EDX_00 != 0.0) || (NAN(extraout_EDX_00))) {
        fVar8 = extraout_EDX / extraout_EDX_00;
      }
      if (self->_coreImageEffect == (id)0x0) {
        fVar1 = *(float *)(PTR_00336088 + 4);
        (self->_preEffectApplyingTransform).a = *(float *)PTR_00336088;
        (self->_preEffectApplyingTransform).b = fVar1;
        (self->_preEffectApplyingTransform).c = *(float *)(puVar10 + 8);
        (self->_preEffectApplyingTransform).d = *(float *)(puVar10 + 0xc);
        (self->_preEffectApplyingTransform).tx = *(float *)(puVar10 + 0x10);
        (self->_preEffectApplyingTransform).ty = *(float *)(puVar10 + 0x14);
        _CGAffineTransformMakeScale(&local_44,fVar9,fVar8);
        (self->_postEffectApplyingTransform).a = local_44;
        (self->_postEffectApplyingTransform).b = local_40;
        (self->_postEffectApplyingTransform).c = local_3c;
        (self->_postEffectApplyingTransform).d = local_38;
        (self->_postEffectApplyingTransform).tx = local_34;
      }
      else {
        fVar1 = *(float *)(PTR_00336074 + 4) + *(float *)(PTR_00336074 + 4) + extraout_EDX_00;
        _CGAffineTransformMakeScale(&local_2c,fVar9,fVar8);
        (self->_preEffectApplyingTransform).a = local_2c;
        (self->_preEffectApplyingTransform).b = local_28;
        (self->_preEffectApplyingTransform).c = -local_24;
        (self->_preEffectApplyingTransform).d = -local_20;
        (self->_preEffectApplyingTransform).tx = local_24 * fVar1 + local_1c;
        (self->_preEffectApplyingTransform).ty = local_20 * fVar1 + local_18;
        (self->_postEffectApplyingTransform).a = 1.0;
        (self->_postEffectApplyingTransform).b = 0.0;
        (self->_postEffectApplyingTransform).c = 0.0;
        (self->_postEffectApplyingTransform).d = -1.0;
        (self->_postEffectApplyingTransform).tx = 0.0;
        local_30 = fVar1;
      }
      (self->_postEffectApplyingTransform).ty = local_30;
    }
  }
  return;
}

*/
- (void)collectEffectSettingsForPreviewObject:(id)aObject
{
    if (aObject == nil) {
        return;
    }
    id geometry = [aObject queryHyperInterface:@protocol(HSGeometryAttributes)];
    if (geometry == nil) {
        return;
    }
    NSSize frameSize = [geometry affineFrameSize];
    id coreImageAccess = [aObject queryHyperInterface:@protocol(HSCoreImageEffectAccessing)];
    if (coreImageAccess != nil) {
        _coreImageEffect = [[coreImageAccess coreImageEffectAdjustedToSize:frameSize] retain];
    } else {
        id quickTimeAccess = [aObject queryHyperInterface:@protocol(HSQuickTimeEffectAccessing)];
        if (quickTimeAccess == nil) {
            _preEffectApplyingTransform = CGAffineTransformIdentity;
            _postEffectApplyingTransform = CGAffineTransformIdentity;
            return;
        }
        _quickTimeEffect = [[quickTimeAccess quickTimeEffectAdjustedToSize:frameSize] retain];
    }
    NSSize previewSize = [(NSImage *)[self previewImage] size];
    float scaleX = previewSize.width != 0 ? (float)(frameSize.width / previewSize.width) : 0;
    float scaleY = previewSize.height != 0 ? (float)(frameSize.height / previewSize.height) : 0;
    if (_coreImageEffect != nil) {
        /* Core Image works bottom-up: scale to the frame and flip around the preview height. */
        float height = (float)(NSZeroPoint.y + NSZeroPoint.y + previewSize.height);
        CGAffineTransform scale = CGAffineTransformMakeScale(scaleX, scaleY);
        _preEffectApplyingTransform = CGAffineTransformMake(scale.a, scale.b, -scale.c, -scale.d, scale.c * height + scale.tx, scale.d * height + scale.ty);
        _postEffectApplyingTransform = CGAffineTransformMake(1, 0, 0, -1, 0, height);
    } else {
        _preEffectApplyingTransform = CGAffineTransformIdentity;
        _postEffectApplyingTransform = CGAffineTransformMakeScale(scaleX, scaleY);
    }
}

- (id)previewObject
{
    id pvVar1;
    id pvVar1_3;

    pvVar1 = _previewObject;
    if (pvVar1 == nil) {
        pvVar1_3 = [[self previewObjectFromInterfacesArray:_allHyperInterfaces] retain];
        _previewObject = pvVar1_3;
        [self collectEffectSettingsForPreviewObject:pvVar1_3];
        pvVar1 = _previewObject;
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0019d306 @ 0019d306, 1047 bytes * /

id FUN_0019d306(HSHyperProxyEffectApplier *self,SEL _cmd,id previewImageForImage)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  void *pvVar5;
  int iVar6;
  int iVar7;
  size_t sVar8;
  undefined4 *puVar9;
  longdouble lVar10;
  longdouble lVar11;
  id local_48;
  undefined1 local_24 [20];
  
  puVar9 = (undefined4 *)&stack0xffffff84;
  local_48 = previewImageForImage;
  if ((previewImageForImage == (id)0x0) &&
     (local_48 = _objc_msgSend(self,sel_previewImage), local_48 == (id)0x0)) {
    local_48 = (id)0x0;
  }
  else if (self->_coreImageEffect == (id)0x0) {
    if (self->_quickTimeEffect != (id)0x0) {
      _objc_msgSend(local_48,sel_size);
      lVar10 = (longdouble)_ceilf();
      lVar11 = (longdouble)_ceilf();
      sVar8 = ((((int)lVar11 << 0x10) >> 0xe) + 0xfU & 0xfffffff0) * (int)(short)(int)lVar10;
      pvVar5 = _malloc(sVar8);
      if (pvVar5 != (void *)0x0) {
        iVar6 = _CGDataProviderCreateWithData();
        if (iVar6 == 0) {
          _free(pvVar5);
        }
        else {
          _memset(pvVar5,0,sVar8);
          iVar7 = _CGColorSpaceCreateDeviceRGB();
          if (iVar7 != 0) {
            iVar7 = _CGBitmapContextCreate();
            if (iVar7 != 0) {
              _CGContextRelease();
            }
            _CGColorSpaceRelease();
          }
        }
        if (iVar6 != 0) {
          _CGDataProviderRelease();
        }
      }
    }
  }
  else {
    pvVar2 = _objc_msgSend(local_48,sel_representations);
    pvVar2 = _objc_msgSend(pvVar2,sel_objectEnumerator);
    do {
      pvVar3 = _objc_msgSend(pvVar2,sel_nextObject);
      puVar1 = cls_NSBitmapImageRep;
      if (pvVar3 == (id)0x0) {
        _objc_msgSend(local_48,sel_bestRepresentationForDevice_);
        pvVar3 = _objc_msgSend(puVar1,sel_hyperRGBA8888BitmapRepresentationFromImageRepresentation_)
        ;
        break;
      }
      _objc_msgSend(cls_NSBitmapImageRep,sel_class);
      pvVar4 = _objc_msgSend(pvVar3,sel_isKindOfClass_);
    } while ((char)pvVar4 == '\0');
    if (pvVar3 != (id)0x0) {
      pvVar2 = _objc_msgSend(cls_CIImage,sel_alloc);
      pvVar2 = _objc_msgSend(pvVar2,sel_initWithBitmapImageRep_);
      if (pvVar2 != (id)0x0) {
        pvVar3 = self->_coreImageEffect;
        _objc_msgSend(pvVar2,sel_imageByApplyingTransform_);
        pvVar3 = _objc_msgSend(pvVar3,sel_effectImageForContextImage_);
        pvVar3 = _objc_msgSend(pvVar3,sel_imageByApplyingTransform_);
        if (pvVar3 != (id)0x0) {
          _objc_msgSend_stret(local_24,pvVar3,sel_extent);
          _CGAffineTransformMakeTranslation();
          puVar9 = (undefined4 *)&stack0xffffff7c;
          pvVar4 = _objc_msgSend(cls_NSImage,sel_alloc);
          local_48 = _objc_msgSend(pvVar4,sel_initWithSize_);
          puVar1 = cls_NSCIImageRep;
          _objc_msgSend(pvVar3,sel_imageByApplyingTransform_);
          _objc_msgSend(puVar1,sel_imageRepWithCIImage_);
          _objc_msgSend(local_48,sel_addRepresentation_);
          _objc_msgSend(local_48,sel_autorelease);
        }
        puVar9[1] = sel_release;
        *puVar9 = pvVar2;
        puVar9[-1] = 0x19d5ed;
        _objc_msgSend((id)*puVar9,(SEL)puVar9[1]);
      }
    }
  }
  return local_48;
}

*/
- (id)previewImageForImage:(id)aImage
{
    NSImage *image = aImage;
    if (image == nil) {
        image = [self previewImage];
        if (image == nil) {
            return nil;
        }
    }
    if (_coreImageEffect == nil) {
        /* The QuickTime path only allocated and released an empty bitmap context
           without drawing into it; the image is returned unchanged. */
        return image;
    }
    NSBitmapImageRep *bitmap = nil;
    for (NSImageRep *rep in [image representations]) {
        if ([rep isKindOfClass:[NSBitmapImageRep class]]) {
            bitmap = (NSBitmapImageRep *)rep;
            break;
        }
    }
    if (bitmap == nil) {
        bitmap = [NSBitmapImageRep hyperRGBA8888BitmapRepresentationFromImageRepresentation:[image bestRepresentationForDevice:nil]];
    }
    if (bitmap == nil) {
        return image;
    }
    CIImage *contextImage = [[CIImage alloc] initWithBitmapImageRep:bitmap];
    if (contextImage == nil) {
        return image;
    }
    CIImage *effectImage = [[(HSCIEffect *)_coreImageEffect effectImageForContextImage:[contextImage imageByApplyingTransform:_preEffectApplyingTransform]] imageByApplyingTransform:_postEffectApplyingTransform];
    if (effectImage != nil) {
        CGRect extent = [effectImage extent];
        CGAffineTransform translation = CGAffineTransformMakeTranslation(-extent.origin.x, -extent.origin.y);
        image = [[NSImage alloc] initWithSize:NSMakeSize(extent.size.width, extent.size.height)];
        [image addRepresentation:[NSCIImageRep imageRepWithCIImage:[effectImage imageByApplyingTransform:translation]]];
        [image autorelease];
    }
    [contextImage release];
    return image;
}

- (id)originalObject
{
    return [[super originalObject] hyperObject];
}

- (id)previewObjectFromInterfacesArray:(id)aArray
{
    return [aArray objectAtIndex:0];
}

- (id)allHyperInterfaces
{
    return _allHyperInterfaces;
}

- (void)dealloc
{
    [_allHyperInterfaces release];
    [_previewObject release];
    [_coreImageEffect release];
    [_quickTimeEffect release];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0019caea @ 0019caea, 212 bytes * /

id FUN_0019caea(HSHyperProxyEffectApplier *self,SEL _cmd,id initWithHyperObject)

{
  undefined4 uVar1;
  undefined4 uVar2;
  undefined4 uVar3;
  undefined4 uVar4;
  undefined4 uVar5;
  undefined4 uVar6;
  undefined *puVar7;
  id pvVar8;
  id pvVar9;
  HSHyperProxyEffectApplier *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSHyperObjectEffectApplier_00352ee0;
  pvVar8 = _objc_msgSendSuper(&local_1c,sel_HSHyperObjectEffectApplier_initWithHyperObject_,
                              initWithHyperObject);
  if (pvVar8 != (id)0x0) {
    pvVar9 = _objc_msgSend(initWithHyperObject,sel_allHyperInterfaces);
    pvVar9 = _objc_msgSend(pvVar9,sel_retain);
    *(id *)((int)pvVar8 + 0x10) = pvVar9;
    puVar7 = PTR_00336088;
    uVar1 = *(undefined4 *)PTR_00336088;
    uVar2 = *(undefined4 *)(PTR_00336088 + 4);
    *(undefined4 *)((int)pvVar8 + 0x1c) = uVar1;
    *(undefined4 *)((int)pvVar8 + 0x20) = uVar2;
    uVar3 = *(undefined4 *)(puVar7 + 8);
    *(undefined4 *)((int)pvVar8 + 0x24) = uVar3;
    uVar4 = *(undefined4 *)(puVar7 + 0xc);
    *(undefined4 *)((int)pvVar8 + 0x28) = uVar4;
    uVar5 = *(undefined4 *)(puVar7 + 0x10);
    *(undefined4 *)((int)pvVar8 + 0x2c) = uVar5;
    uVar6 = *(undefined4 *)(puVar7 + 0x14);
    *(undefined4 *)((int)pvVar8 + 0x30) = uVar6;
    *(undefined4 *)((int)pvVar8 + 0x34) = uVar1;
    *(undefined4 *)((int)pvVar8 + 0x38) = uVar2;
    *(undefined4 *)((int)pvVar8 + 0x3c) = uVar3;
    *(undefined4 *)((int)pvVar8 + 0x40) = uVar4;
    *(undefined4 *)((int)pvVar8 + 0x44) = uVar5;
    *(undefined4 *)((int)pvVar8 + 0x48) = uVar6;
  }
  return pvVar8;
}

*/
- (id)initWithHyperObject:(id)aObject
{
    self = [super HSHyperObjectEffectApplier_initWithHyperObject:aObject];
    if (self != nil) {
        _allHyperInterfaces = [[aObject allHyperInterfaces] retain];
        _preEffectApplyingTransform = CGAffineTransformIdentity;
        _postEffectApplyingTransform = CGAffineTransformIdentity;
    }
    return self;
}

@end

@implementation HSEditableImageAttributesEffectApplier

+ (SEL)delegateSelector
{
    return @selector(applyEffectForHSEditableImageAttributes:userInfo:);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0019e466 @ 0019e466, 125 bytes * /

id FUN_0019e466(HSEditableImageAttributesEffectApplier *self,SEL _cmd)

{
  id pvVar1;
  undefined4 uVar2;
  undefined *local_10;
  undefined4 local_c;
  
  local_10 = &DAT_0037b8e8;
  local_c = 0;
  pvVar1 = _objc_msgSend(self,sel_previewObject);
  uVar2 = 0;
  pvVar1 = _objc_msgSend(pvVar1,sel_queryImageWithRequiredProtocols_optionalProtocols_,&local_10,0);
  if (pvVar1 == (id)0x0) {
    pvVar1 = (id)0x0;
  }
  else {
    pvVar1 = _objc_msgSend(cls_NSImage,sel_BT_imageWithBTCocoaImage_,pvVar1,uVar2);
  }
  return pvVar1;
}

*/
- (id)previewImage
{
    Protocol *required[] = {@protocol(BTCocoaImage), nil};
    id image = [[self previewObject] queryImageWithRequiredProtocols:required optionalProtocols:NULL];
    if (image == nil) {
        return nil;
    }
    return [NSImage BT_imageWithBTCocoaImage:image];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0019e2e5 @ 0019e2e5, 385 bytes * /

void FUN_0019e2e5(HSEditableImageAttributesEffectApplier *self,SEL _cmd,
                 id applyEffectForHSEditableImageAttributes,void *userInfo)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  undefined4 extraout_EDX;
  ulonglong uVar3;
  undefined *local_30;
  undefined *local_2c;
  undefined4 local_28;
  undefined4 local_24;
  undefined4 uStack_20;
  id local_1c;
  
  local_30 = &DAT_0037b8e8;
  local_2c = &DAT_0037b910;
  local_28 = 0;
  uVar3 = ZEXT48(&local_30);
  self_00 = _objc_msgSend(applyEffectForHSEditableImageAttributes,
                          sel_queryImageWithRequiredProtocols_optionalProtocols_,&local_30,0);
  if (self_00 != (id)0x0) {
    pvVar1 = _objc_msgSend(self_00,sel_imageSize,uVar3);
    pvVar2 = _objc_msgSend(cls_NSImage,sel_BT_imageWithBTCocoaImage_,self_00);
    _objc_msgSend(userInfo,sel_setInputImage_,pvVar2);
    pvVar2 = _objc_msgSend(userInfo,sel_outputImage);
    _objc_msgSend(applyEffectForHSEditableImageAttributes,sel_beginEditImage_,self_00);
    _objc_msgSend(self_00,sel_beginCocoaEditing);
    local_24 = 0;
    uStack_20 = 0;
    local_1c = pvVar1;
    _objc_msgSend(pvVar2,sel_drawInRect_fromRect_operation_fraction_,0,CONCAT44(extraout_EDX,pvVar1)
                  ,*(undefined8 *)PTR_00336078,*(undefined8 *)(PTR_00336078 + 8),2,0x3f800000);
    _objc_msgSend(self_00,sel_endCocoaEditing);
    _objc_msgSend(applyEffectForHSEditableImageAttributes,sel_endEditImage);
  }
  return;
}

*/
- (void)applyEffectForHSEditableImageAttributes:(id)aAttributes userInfo:(void *)aInfo
{
    Protocol *required[] = {@protocol(BTCocoaImage), @protocol(BTCocoaMutableImage), nil};
    id image = [aAttributes queryImageWithRequiredProtocols:required optionalProtocols:NULL];
    if (image == nil) {
        return;
    }
    NSSize size = [image imageSize];
    id effect = (id)aInfo;
    [effect setInputImage:[NSImage BT_imageWithBTCocoaImage:image]];
    NSImage *output = [effect outputImage];
    [aAttributes beginEditImage:image];
    [image beginCocoaEditing];
    [output drawInRect:NSMakeRect(0, 0, size.width, size.height) fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];
    [image endCocoaEditing];
    [aAttributes endEditImage];
}

@end

@implementation HSButtonObjectAttributesEffectApplier

+ (SEL)delegateSelector
{
    return @selector(applyEffectForHSButtonObjectAttributes:userInfo:);
}

- (id)previewImage
{
    return [[self previewObject] icon];
}

- (id)previewObjectFromInterfacesArray:(id)aArray
{
    id pvVar1;
    NSEnumerator *self_00;
    BOOL pvVar2;
    id self_01;

    pvVar1 = [aArray objectAtIndex:0];
    self_00 = [aArray objectEnumerator];
    do {
        self_01 = [self_00 nextObject];
        if (self_01 == nil) {
            return pvVar1;
        }
        pvVar2 = [self_01 isIconVisible];
    } while (!pvVar2);
    return self_01;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0019e1a8 @ 0019e1a8, 131 bytes * /

void FUN_0019e1a8(HSButtonObjectAttributesEffectApplier *self,SEL _cmd,
                 id applyEffectForHSButtonObjectAttributes,void *userInfo)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(applyEffectForHSButtonObjectAttributes,sel_isIconVisible);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(applyEffectForHSButtonObjectAttributes,sel_icon);
    _objc_msgSend(userInfo,sel_setInputImage_,pvVar1);
    pvVar1 = _objc_msgSend(userInfo,sel_outputImage);
    _objc_msgSend(applyEffectForHSButtonObjectAttributes,sel_setIcon_,pvVar1);
  }
  return;
}

*/
- (void)applyEffectForHSButtonObjectAttributes:(id)aAttributes userInfo:(void *)aInfo
{
    if ([aAttributes isIconVisible]) {
        id effect = (id)aInfo;
        [effect setInputImage:[aAttributes icon]];
        [aAttributes setIcon:[effect outputImage]];
    }
}

@end

@implementation HSImageMutableAttributesEffectApplier

+ (SEL)delegateSelector
{
    return @selector(applyEffectForHSImageMutableAttributes:userInfo:);
}

- (id)previewImage
{
    return [[self previewObject] image];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0019e101 @ 0019e101, 109 bytes * /

void FUN_0019e101(HSImageMutableAttributesEffectApplier *self,SEL _cmd,
                 id applyEffectForHSImageMutableAttributes,void *userInfo)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(applyEffectForHSImageMutableAttributes,sel_image);
  _objc_msgSend(userInfo,sel_setInputImage_,pvVar1);
  pvVar1 = _objc_msgSend(userInfo,sel_outputImage);
  _objc_msgSend(applyEffectForHSImageMutableAttributes,sel_setImage_,pvVar1);
  return;
}

*/
- (void)applyEffectForHSImageMutableAttributes:(id)aAttributes userInfo:(void *)aInfo
{
    id effect = (id)aInfo;
    [effect setInputImage:[aAttributes image]];
    [aAttributes setImage:[effect outputImage]];
}

@end

@implementation HSImageObjectAttributesEffectApplier

/* i386 ivar offsets: _previewImage=0x4c */

+ (SEL)delegateSelector
{
    return @selector(applyEffectForHSImageObjectAttributes:userInfo:);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0019dc8d @ 0019dc8d, 432 bytes * /

id FUN_0019dc8d(HSImageObjectAttributesEffectApplier *self,SEL _cmd,id previewImageForImage)

{
  id pvVar1;
  id pvVar2;
  float extraout_EDX;
  float extraout_EDX_00;
  float fVar3;
  undefined *puVar4;
  id pvVar5;
  float fVar6;
  id local_18;
  
  if ((previewImageForImage == (id)0x0) &&
     (previewImageForImage = _objc_msgSend(self,sel_previewImage), previewImageForImage == (id)0x0))
  {
    previewImageForImage = (id)0x0;
  }
  else {
    local_18 = _objc_msgSend(previewImageForImage,sel_size);
    pvVar1 = _objc_msgSend(self,sel_previewObject);
    puVar4 = &DAT_0037b884;
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0037b884);
    pvVar1 = _objc_msgSend(pvVar1,sel_size);
    if ((float)pvVar1 <= extraout_EDX_00) {
      local_18 = (id)((float)pvVar1 / (extraout_EDX_00 / extraout_EDX));
      fVar3 = extraout_EDX;
    }
    else {
      fVar3 = extraout_EDX_00 / ((float)pvVar1 / (float)local_18);
    }
    pvVar2 = _objc_msgSend(cls_HSEffectApplierPreviewImageRep,sel_alloc,puVar4);
    pvVar1 = previewImageForImage;
    pvVar5 = local_18;
    fVar6 = fVar3;
    pvVar2 = _objc_msgSend(pvVar2,sel_initWithImage_size_,previewImageForImage,local_18,fVar3);
    if (pvVar2 != (id)0x0) {
      pvVar1 = _objc_msgSend(cls_NSImage,sel_alloc,pvVar1,pvVar5,fVar6);
      previewImageForImage = _objc_msgSend(pvVar1,sel_initWithSize_,local_18,fVar3);
      _objc_msgSend(previewImageForImage,sel_addRepresentation_,pvVar2);
      _objc_msgSend(pvVar2,sel_release);
      _objc_msgSend(previewImageForImage,sel_autorelease);
    }
  }
  return previewImageForImage;
}

*/
- (id)previewImageForImage:(id)aImage
{
    NSImage *image = aImage;
    if (image == nil) {
        image = [self previewImage];
        if (image == nil) {
            return nil;
        }
    }
    NSSize size = [image size];
    NSSize objectSize = [(id<HSSizeAttributes>)[[self previewObject] queryHyperInterface:@protocol(HSSizeAttributes)] size];
    /* Match the preview's aspect ratio to the object's. */
    if (objectSize.width <= objectSize.height) {
        size.width = (float)(objectSize.width / (objectSize.height / size.height));
    } else {
        size.height = (float)(objectSize.height / (objectSize.width / size.width));
    }
    HSEffectApplierPreviewImageRep *rep = [[HSEffectApplierPreviewImageRep alloc] initWithImage:image size:size];
    if (rep != nil) {
        image = [[NSImage alloc] initWithSize:size];
        [image addRepresentation:rep];
        [rep release];
        [image autorelease];
    }
    return image;
}

- (id)previewImage
{
    id pvVar1;

    pvVar1 = _previewImage;
    if (pvVar1 == nil) {
        pvVar1 = [[NSImage hyperImageWithCGImage:[[HSCurrentImageDrawing drawingForImageObject:[self previewObject]] currentCGImageOfSize:nil]] retain];
        _previewImage = pvVar1;
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0019dedd @ 0019dedd, 548 bytes * /

void FUN_0019dedd(HSImageObjectAttributesEffectApplier *self,SEL _cmd,
                 id applyEffectForHSImageObjectAttributes,void *userInfo)

{
  undefined *puVar1;
  id self_00;
  id self_01;
  id self_02;
  id pvVar2;
  id pvVar3;
  undefined8 in_stack_ffffffbc;
  undefined8 uVar4;
  undefined4 uVar5;
  
  uVar4 = CONCAT44((int)((ulonglong)in_stack_ffffffbc >> 0x20),&DAT_0037b348);
  self_00 = _objc_msgSend(applyEffectForHSImageObjectAttributes,sel_queryHyperInterface_,
                          &DAT_0037b348);
  if (self_00 != (id)0x0) {
    self_01 = _objc_msgSend(cls_NSAutoreleasePool,sel_new,uVar4);
    self_02 = _objc_msgSend(cls_HSImageCropApplier,sel_cropApplierForImageObject_,self_00);
    _objc_msgSend(self_02,sel_updateEffectedImageObject);
    puVar1 = cls_NSImage;
    pvVar2 = _objc_msgSend(self_02,sel_croppedImageDrawing);
    pvVar2 = _objc_msgSend(pvVar2,sel_currentCGImageOfSize_,0);
    pvVar2 = _objc_msgSend(puVar1,sel_hyperImageWithCGImage_,pvVar2);
    _objc_msgSend(userInfo,sel_setInputImage_,pvVar2);
    puVar1 = cls_HSNewMedia;
    pvVar2 = _objc_msgSend(applyEffectForHSImageObjectAttributes,sel_name);
    pvVar3 = _objc_msgSend(userInfo,sel_outputImage);
    uVar4 = CONCAT44(pvVar2,pvVar3);
    pvVar2 = _objc_msgSend(puVar1,sel_mediaWithImage_name_,pvVar3,pvVar2);
    if (pvVar2 != (id)0x0) {
      _objc_msgSend(self_00,sel_setHyperEffectedMedia_refreshName_,pvVar2,0);
      pvVar2 = _objc_msgSend(applyEffectForHSImageObjectAttributes,sel_queryHyperInterface_,
                             &DAT_0037b85c);
      _objc_msgSend(pvVar2,sel_removeAllClipPaths);
      uVar5 = 0;
      _objc_msgSend(self_00,sel_setRelativeImageRect_,0,0x3f8000003f800000);
      uVar4 = CONCAT44(uVar5,1);
      _objc_msgSend(self_00,sel_setCurrentClipPathsAreInitial_,1);
      _objc_msgSend(self_02,sel_updateCurrentBorderPath);
    }
    _objc_msgSend(self_01,sel_release,uVar4);
  }
  return;
}

*/
- (void)applyEffectForHSImageObjectAttributes:(id)aAttributes userInfo:(void *)aInfo
{
    id imageObject = [aAttributes queryHyperInterface:@protocol(HSImageObjectAttributes)];
    if (imageObject == nil) {
        return;
    }
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    id cropApplier = [HSImageCropApplier cropApplierForImageObject:imageObject];
    [cropApplier updateEffectedImageObject];
    id effect = (id)aInfo;
    [effect setInputImage:[NSImage hyperImageWithCGImage:[[cropApplier croppedImageDrawing] currentCGImageOfSize:NULL]]];
    id media = [HSNewMedia mediaWithImage:[effect outputImage] name:[(HSUserObject *)aAttributes name]];
    if (media != nil) {
        [imageObject setHyperEffectedMedia:media refreshName:NO];
        [[aAttributes queryHyperInterface:@protocol(HSMutableClipPathsAttributes)] removeAllClipPaths];
        [imageObject setRelativeImageRect:NSMakeRect(0, 0, 1, 1)];
        [imageObject setCurrentClipPathsAreInitial:YES];
        [cropApplier updateCurrentBorderPath];
    }
    [pool release];
}

- (void)dealloc
{
    [_previewImage release];
    [super dealloc];
}

@end

@implementation HSGraphicSelectionToolEffectApplier

+ (SEL)delegateSelector
{
    return @selector(applyEffectForGraphicSelectionToolObject:userInfo:);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0019d871 @ 0019d871, 477 bytes * /

void FUN_0019d871(HSGraphicSelectionToolEffectApplier *self,SEL _cmd,id applyHyperEffect)

{
  int iVar1;
  int iVar2;
  id pvVar3;
  id pvVar4;
  id local_78;
  int local_74 [23];
  id local_18;
  HSGraphicSelectionToolEffectApplier *local_14;
  
  local_14 = self;
  local_18 = applyHyperEffect;
  local_78 = (id)0x0;
  _objc_exception_try_enter(local_74);
  iVar1 = __setjmp(local_74);
  if (iVar1 == 0) {
    pvVar3 = _objc_msgSend(local_14,sel_originalObject);
    pvVar4 = _objc_msgSend(pvVar3,sel_imageSelection);
    if (pvVar4 == (id)0x0) {
      _objc_msgSend(pvVar3,sel_finalizeSelection_,0);
      pvVar4 = _objc_msgSend(pvVar3,sel_imageSelection);
    }
    pvVar3 = local_18;
    pvVar4 = _objc_msgSend(cls_NSImage,sel_BT_imageWithBTCGImage_,pvVar4);
    _objc_msgSend(pvVar3,sel_setInputImage_,pvVar4);
    pvVar3 = _objc_msgSend(cls_BTCGImage,sel_alloc);
    pvVar4 = _objc_msgSend(local_18,sel_valueForKey_,&cfstr_outputCGImage);
    local_78 = _objc_msgSend(pvVar3,sel_initWithCGImage_,pvVar4);
    pvVar3 = _objc_msgSend(local_14,sel_originalObject);
    _objc_msgSend(pvVar3,sel_setValue_forKey_,local_78,&cfstr_imageSelection);
  }
  else {
    iVar2 = _objc_exception_extract(local_74);
    _objc_exception_try_enter(local_74);
    iVar1 = __setjmp(local_74);
    if (iVar1 == 0) {
      iVar1 = _objc_exception_match(cls_NSException,iVar2);
      if (iVar1 != 0) goto LAB_0019da2b;
      _objc_exception_try_exit(local_74);
    }
    else {
      iVar2 = _objc_exception_extract(local_74);
    }
    if (iVar2 != 0) {
                    /* WARNING: Subroutine does not return * /
      _objc_exception_throw(iVar2);
    }
  }
LAB_0019da2b:
  _objc_exception_try_exit(local_74);
  _objc_msgSend(local_78,sel_release);
  return;
}

*/
- (void)applyHyperEffect:(id)aEffect
{
    BTCGImage *selection = nil;
    @try {
        id tool = [self originalObject];
        id image = [tool imageSelection];
        if (image == nil) {
            [tool finalizeSelection:nil];
            image = [tool imageSelection];
        }
        [aEffect setInputImage:[NSImage BT_imageWithBTCGImage:image]];
        selection = [[BTCGImage alloc] initWithCGImage:(CGImageRef)[aEffect valueForKey:@"outputCGImage"]];
        [[self originalObject] setValue:selection forKey:@"imageSelection"];
    } @catch (NSException *exception) {
    }
    [selection release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0019da53 @ 0019da53, 309 bytes * /

void FUN_0019da53(HSGraphicSelectionToolEffectApplier *self,SEL _cmd,id applyEffectWithDelegate,
                 void *userInfo)

{
  void *pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  int iVar5;
  int iVar6;
  int local_74 [22];
  void *local_1c;
  id local_18;
  HSGraphicSelectionToolEffectApplier *local_14;
  
  local_14 = self;
  local_18 = applyEffectWithDelegate;
  local_1c = userInfo;
  pvVar2 = _objc_msgSend(self,sel_class);
  pvVar3 = _objc_msgSend(pvVar2,sel_delegateSelector);
  pvVar2 = pvVar3;
  pvVar4 = _objc_msgSend(local_18,sel_respondsToSelector_,pvVar3);
  if ((char)pvVar4 == '\0') {
    return;
  }
  _objc_exception_try_enter(local_74);
  iVar5 = __setjmp(local_74);
  pvVar4 = local_18;
  pvVar1 = local_1c;
  if (iVar5 == 0) {
    pvVar2 = _objc_msgSend(local_14,sel_originalObject,pvVar2);
    _objc_msgSend(pvVar4,sel_performSelector_withObject_withObject_,pvVar3,pvVar2,pvVar1);
  }
  else {
    iVar6 = _objc_exception_extract(local_74);
    _objc_exception_try_enter(local_74);
    iVar5 = __setjmp(local_74);
    if (iVar5 == 0) {
      iVar5 = _objc_exception_match(cls_NSException,iVar6);
      if (iVar5 != 0) goto LAB_0019db2d;
      _objc_exception_try_exit(local_74);
    }
    else {
      iVar6 = _objc_exception_extract(local_74);
    }
    if (iVar6 != 0) {
                    /* WARNING: Subroutine does not return * /
      _objc_exception_throw(iVar6);
    }
  }
LAB_0019db2d:
  _objc_exception_try_exit(local_74);
  return;
}

*/
- (void)applyEffectWithDelegate:(id)aDelegate userInfo:(void *)aInfo
{
    SEL selector = [[self class] delegateSelector];
    if (![aDelegate respondsToSelector:selector]) {
        return;
    }
    @try {
        [aDelegate performSelector:selector withObject:[self originalObject] withObject:(id)aInfo];
    } @catch (NSException *exception) {
    }
}

- (id)previewImageForImage:(id)aImage
{
    if (aImage == nil) {
        aImage = [self previewImage];
    }
    return aImage;
}

- (id)previewImage
{
    id pvVar1;
    id pvVar2;

    pvVar1 = [self previewObject];
    pvVar2 = [pvVar1 imageSelection];
    if (pvVar2 == nil) {
        [pvVar1 finalizeSelection:nil];
        pvVar2 = [pvVar1 imageSelection];
    }
    return [NSImage BT_imageWithBTCGImage:pvVar2];
}

- (id)initWithHyperObject:(id)aObject
{
    return [super HSHyperObjectEffectApplier_initWithHyperObject:[aObject bitmapTool]];
}

@end

