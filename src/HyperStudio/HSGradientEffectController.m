#import "HSGradientEffectController.h"

@implementation HSGradientEffectController

/* i386 ivar offsets: _preview=0x18, _styleMatrix=0x1c, _topColorWell=0x20, _bottomColorWell=0x24, _topCrayonsView=0x28, _bottomCrayonsView=0x2c, _leftTextField=0x30, _rightTextField=0x34, _color=0x38, _originalImage=0x3c */

+ (id)defaultEndColor
{
    return [NSColor blackColor];
}

+ (id)defaultStartColor
{
    return [NSColor blueColor];
}

+ (id)createEffect
{
    return nil;
}

- (void)bottomColorDidChange:(id)aChange
{
    if (_bottomCrayonsView == aChange) {
        [_bottomColorWell setColor:[aChange color]];
    }
    [_color setStartColor:[_bottomColorWell color]];
    [self update];
}

- (void)topColorDidChange:(id)aChange
{
    if (_topCrayonsView == aChange) {
        [_topColorWell setColor:[aChange color]];
    }
    [_color setEndColor:[_topColorWell color]];
    [self update];
}

- (void)styleDidChange:(id)aChange
{
    [self setGradientKindFromInterface:_styleMatrix];
    [self update];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001d177f @ 001d177f, 602 bytes * /

void FUN_001d177f(HSGradientEffectController *self,SEL _cmd,id setGradientKindFromInterface)

{
  id pvVar1;
  id pvVar2;
  undefined **ppuVar3;
  undefined4 uVar4;
  
  pvVar1 = _objc_msgSend(setGradientKindFromInterface,sel_selectedRow);
  switch(pvVar1) {
  case (id)0x0:
    _objc_msgSend(self->_color,sel_setKind_,0);
    pvVar1 = self->_color;
    pvVar2 = _objc_msgSend(self,sel_objectGeometryAttributes);
    pvVar2 = _objc_msgSend(pvVar2,sel_isFlippedVertically);
    _objc_msgSend(pvVar1,sel_setAngle_,
                  *(undefined4 *)(&DAT_00335a90 + (uint)((char)pvVar2 == '\0') * 4));
    ppuVar3 = &PTR_cfstr_Top_003373c4;
    goto LAB_001d190a;
  case (id)0x1:
    _objc_msgSend(self->_color,sel_setKind_,0);
    pvVar1 = self->_color;
    pvVar2 = _objc_msgSend(self,sel_objectGeometryAttributes);
    pvVar2 = _objc_msgSend(pvVar2,sel_isFlippedHorizontally);
    _objc_msgSend(pvVar1,sel_setAngle_,
                  *(undefined4 *)(&DAT_00335a98 + (uint)((char)pvVar2 == '\0') * 4));
    ppuVar3 = &PTR_cfstr_Left_003373cc;
    goto LAB_001d190a;
  case (id)0x2:
    pvVar1 = self->_color;
    uVar4 = 1;
    break;
  case (id)0x3:
    pvVar1 = self->_color;
    uVar4 = 2;
    break;
  default:
    goto switchD_001d17b5_default;
  }
  _objc_msgSend(pvVar1,sel_setKind_,uVar4);
  _objc_msgSend(self->_color,sel_setAngle_,0);
switchD_001d17b5_default:
  ppuVar3 = &PTR_cfstr_Outside_003373bc;
LAB_001d190a:
  pvVar1 = self->_leftTextField;
  pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,*ppuVar3,*ppuVar3,
                         &cfstr_Dialogs);
  _objc_msgSend(pvVar1,sel_setStringValue_,pvVar2);
  pvVar1 = self->_rightTextField;
  pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,ppuVar3[1],ppuVar3[1],
                         &cfstr_Dialogs);
  _objc_msgSend(pvVar1,sel_setStringValue_,pvVar2);
  return;
}

*/
- (void)setGradientKindFromInterface:(id)aInterface
{
    NSString *leftKey;
    NSString *rightKey;
    switch ([aInterface selectedRow]) {
    case 0:
        [_color setKind:0];
        [_color setAngle:[[self objectGeometryAttributes] isFlippedVertically] ? 270.0f : 90.0f];
        leftKey = @"Top";
        rightKey = @"Bottom";
        break;
    case 1:
        [_color setKind:0];
        [_color setAngle:[[self objectGeometryAttributes] isFlippedHorizontally] ? 0.0f : 180.0f];
        leftKey = @"Left";
        rightKey = @"Right";
        break;
    case 2:
        [_color setKind:1];
        [_color setAngle:0.0f];
        leftKey = @"Outside";
        rightKey = @"Inside";
        break;
    case 3:
        [_color setKind:2];
        [_color setAngle:0.0f];
        leftKey = @"Outside";
        rightKey = @"Inside";
        break;
    default:
        leftKey = @"Outside";
        rightKey = @"Inside";
        break;
    }
    [_leftTextField setStringValue:[[NSBundle mainBundle] localizedStringForKey:leftKey value:leftKey table:@"Dialogs"]];
    [_rightTextField setStringValue:[[NSBundle mainBundle] localizedStringForKey:rightKey value:rightKey table:@"Dialogs"]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001d164c @ 001d164c, 307 bytes * /

void FUN_001d164c(HSGradientEffectController *self,SEL _cmd,
                 id applyEffectForHSEditableImageAttributes,void *userInfo)

{
  id self_00;
  id self_01;
  id pvVar1;
  id pvVar2;
  undefined4 extraout_EDX;
  undefined **ppuVar3;
  ulonglong in_stack_ffffffb0;
  ulonglong uVar4;
  undefined *local_18;
  undefined4 local_14;
  
  local_18 = &DAT_0037f308;
  local_14 = 0;
  ppuVar3 = &local_18;
  uVar4 = in_stack_ffffffb0 & 0xffffffff00000000;
  self_01 = _objc_msgSend(applyEffectForHSEditableImageAttributes,
                          sel_queryImageWithRequiredProtocols_optionalProtocols_,ppuVar3,0);
  if (self_01 != (id)0x0) {
    pvVar1 = _objc_msgSend(self_01,sel_imageSize,ppuVar3,uVar4);
    _objc_msgSend(applyEffectForHSEditableImageAttributes,sel_beginEditImage_inRect_,self_01,0,
                  CONCAT44(extraout_EDX,pvVar1));
    _objc_msgSend(self_01,sel_beginCGEditing);
    self_00 = self->_color;
    pvVar2 = _objc_msgSend(self_01,sel_imageCGContext);
    _objc_msgSend(self_00,sel_drawGradientInCGContext_rect_ofBounds_,pvVar2,0,
                  CONCAT44(extraout_EDX,pvVar1),0,CONCAT44(extraout_EDX,pvVar1));
    _objc_msgSend(self_01,sel_endCGEditing);
    _objc_msgSend(applyEffectForHSEditableImageAttributes,sel_endEditImage);
  }
  return;
}

*/
- (void)applyEffectForHSEditableImageAttributes:(id)aAttributes userInfo:(void *)aInfo
{
    id required[] = { @protocol(BTCGMutableImage), nil };
    id image = [aAttributes queryImageWithRequiredProtocols:required optionalProtocols:nil];
    if (image != nil) {
        NSSize size = [image imageSize];
        NSRect rect = NSMakeRect(0.0f, 0.0f, size.width, size.height);
        [aAttributes beginEditImage:image inRect:rect];
        [image beginCGEditing];
        [_color drawGradientInCGContext:[image imageCGContext] rect:rect ofBounds:rect];
        [image endCGEditing];
        [aAttributes endEditImage];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001d1bfe @ 001d1bfe, 386 bytes * /

void FUN_001d1bfe(HSGradientEffectController *self,SEL _cmd,
                 id applyEffectForHSButtonObjectAttributes,void *userInfo)

{
  undefined4 uVar1;
  undefined4 uVar2;
  undefined8 uVar3;
  undefined8 uVar4;
  char cVar5;
  id pvVar6;
  id pvVar7;
  id pvVar8;
  undefined4 extraout_EDX;
  id pvVar9;
  undefined4 uVar10;
  
  uVar1 = *(undefined4 *)PTR_00336078;
  uVar2 = *(undefined4 *)(PTR_00336078 + 4);
  uVar4 = *(undefined8 *)PTR_00336078;
  uVar3 = *(undefined8 *)PTR_00336078;
  pvVar6 = _objc_msgSend(applyEffectForHSButtonObjectAttributes,sel_icon);
  pvVar6 = _objc_msgSend(pvVar6,sel_size);
  cVar5 = _NSIsEmptyRect(uVar3,pvVar6,extraout_EDX);
  if (cVar5 == '\0') {
    pvVar7 = _objc_msgSend(cls_NSImage,sel_alloc);
    pvVar9 = pvVar6;
    uVar10 = extraout_EDX;
    pvVar7 = _objc_msgSend(pvVar7,sel_initWithSize_,pvVar6,extraout_EDX);
    if (pvVar7 != (id)0x0) {
      _objc_msgSend(pvVar7,sel_lockFocus,pvVar9,uVar10);
      pvVar9 = self->_color;
      pvVar8 = _objc_msgSend(cls_NSGraphicsContext,sel_currentContext);
      _objc_msgSend(pvVar9,sel_drawGradientInCocoaContext_rect_ofBounds_,pvVar8,uVar1,uVar2,
                    CONCAT44(extraout_EDX,pvVar6),uVar4,CONCAT44(extraout_EDX,pvVar6));
      _objc_msgSend(pvVar7,sel_unlockFocus);
      _objc_msgSend(applyEffectForHSButtonObjectAttributes,sel_setIcon_,pvVar7);
      _objc_msgSend(pvVar7,sel_release);
    }
  }
  return;
}

*/
- (void)applyEffectForHSButtonObjectAttributes:(id)aAttributes userInfo:(void *)aInfo
{
    NSSize size = [[aAttributes icon] size];
    NSRect rect = NSMakeRect(0.0f, 0.0f, size.width, size.height);
    if (!NSIsEmptyRect(rect)) {
        NSImage *image = [[NSImage alloc] initWithSize:size];
        if (image != nil) {
            [image lockFocus];
            [_color drawGradientInCocoaContext:[NSGraphicsContext currentContext] rect:rect ofBounds:rect];
            [image unlockFocus];
            [aAttributes setIcon:image];
            [image release];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001d1d80 @ 001d1d80, 386 bytes * /

void FUN_001d1d80(HSGradientEffectController *self,SEL _cmd,
                 id applyEffectForHSImageMutableAttributes,void *userInfo)

{
  undefined4 uVar1;
  undefined4 uVar2;
  undefined8 uVar3;
  undefined8 uVar4;
  char cVar5;
  id pvVar6;
  id pvVar7;
  id pvVar8;
  undefined4 extraout_EDX;
  id pvVar9;
  undefined4 uVar10;
  
  uVar1 = *(undefined4 *)PTR_00336078;
  uVar2 = *(undefined4 *)(PTR_00336078 + 4);
  uVar4 = *(undefined8 *)PTR_00336078;
  uVar3 = *(undefined8 *)PTR_00336078;
  pvVar6 = _objc_msgSend(applyEffectForHSImageMutableAttributes,sel_image);
  pvVar6 = _objc_msgSend(pvVar6,sel_size);
  cVar5 = _NSIsEmptyRect(uVar3,pvVar6,extraout_EDX);
  if (cVar5 == '\0') {
    pvVar7 = _objc_msgSend(cls_NSImage,sel_alloc);
    pvVar9 = pvVar6;
    uVar10 = extraout_EDX;
    pvVar7 = _objc_msgSend(pvVar7,sel_initWithSize_,pvVar6,extraout_EDX);
    if (pvVar7 != (id)0x0) {
      _objc_msgSend(pvVar7,sel_lockFocus,pvVar9,uVar10);
      pvVar9 = self->_color;
      pvVar8 = _objc_msgSend(cls_NSGraphicsContext,sel_currentContext);
      _objc_msgSend(pvVar9,sel_drawGradientInCocoaContext_rect_ofBounds_,pvVar8,uVar1,uVar2,
                    CONCAT44(extraout_EDX,pvVar6),uVar4,CONCAT44(extraout_EDX,pvVar6));
      _objc_msgSend(pvVar7,sel_unlockFocus);
      _objc_msgSend(applyEffectForHSImageMutableAttributes,sel_setImage_,pvVar7);
      _objc_msgSend(pvVar7,sel_release);
    }
  }
  return;
}

*/
- (void)applyEffectForHSImageMutableAttributes:(id)aAttributes userInfo:(void *)aInfo
{
    NSSize size = [[aAttributes image] size];
    NSRect rect = NSMakeRect(0.0f, 0.0f, size.width, size.height);
    if (!NSIsEmptyRect(rect)) {
        NSImage *image = [[NSImage alloc] initWithSize:size];
        if (image != nil) {
            [image lockFocus];
            [_color drawGradientInCocoaContext:[NSGraphicsContext currentContext] rect:rect ofBounds:rect];
            [image unlockFocus];
            [aAttributes setImage:image];
            [image release];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001d137a @ 001d137a, 722 bytes * /

void FUN_001d137a(HSGradientEffectController *self,SEL _cmd,id applyEffectForHSImageObjectAttributes
                 ,void *userInfo)

{
  undefined *puVar1;
  id self_00;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  id extraout_EDX;
  undefined4 uVar8;
  id pvVar9;
  undefined4 uVar10;
  id pvVar11;
  id pvVar12;
  
  self_00 = _objc_msgSend(cls_NSAutoreleasePool,sel_new);
  pvVar2 = _objc_msgSend(cls_HSImageCropApplier,sel_cropApplierForImageObject_,
                         applyEffectForHSImageObjectAttributes);
  _objc_msgSend(pvVar2,sel_updateEffectedImageObject);
  puVar1 = cls_NSImage;
  pvVar2 = _objc_msgSend(pvVar2,sel_croppedImageDrawing);
  pvVar2 = _objc_msgSend(pvVar2,sel_currentCGImageOfSize_,0);
  pvVar3 = _objc_msgSend(puVar1,sel_hyperImageWithCGImage_,pvVar2);
  pvVar2 = *(id *)PTR_00336074;
  uVar8 = *(undefined4 *)(PTR_00336074 + 4);
  pvVar4 = _objc_msgSend(pvVar3,sel_size);
  pvVar5 = _objc_msgSend(cls_NSImage,sel_alloc);
  pvVar6 = pvVar4;
  pvVar7 = extraout_EDX;
  pvVar5 = _objc_msgSend(pvVar5,sel_initWithSize_,pvVar4,extraout_EDX);
  if (pvVar5 != (id)0x0) {
    _objc_msgSend(pvVar5,sel_lockFocus,pvVar6,pvVar7);
    _objc_msgSend(pvVar3,sel_drawInRect_fromRect_operation_fraction_,pvVar2,uVar8,pvVar4,
                  extraout_EDX,(int)*(undefined8 *)PTR_00336078,
                  (int)((ulonglong)*(undefined8 *)PTR_00336078 >> 0x20),
                  (int)*(undefined8 *)(PTR_00336078 + 8),
                  (int)((ulonglong)*(undefined8 *)(PTR_00336078 + 8) >> 0x20),2,0x3f800000);
    pvVar7 = self->_color;
    pvVar6 = _objc_msgSend(cls_NSGraphicsContext,sel_currentContext);
    pvVar3 = extraout_EDX;
    pvVar9 = pvVar2;
    uVar10 = uVar8;
    pvVar11 = pvVar4;
    pvVar12 = extraout_EDX;
    _objc_msgSend(pvVar7,sel_drawGradientInCocoaContext_rect_ofBounds_,pvVar6,pvVar2,uVar8,pvVar4,
                  extraout_EDX,pvVar2,uVar8,pvVar4,extraout_EDX);
    _objc_msgSend(pvVar5,sel_unlockFocus);
    pvVar7 = _objc_msgSend(applyEffectForHSImageObjectAttributes,sel_hyperImageObject);
    puVar1 = cls_HSNewMedia;
    if (pvVar7 != (id)0x0) {
      pvVar2 = _objc_msgSend(pvVar7,sel_media,pvVar6,pvVar2,uVar8,pvVar4,pvVar3,pvVar9,uVar10,
                             pvVar11,pvVar12);
      pvVar2 = _objc_msgSend(pvVar2,sel_mediaName);
      pvVar6 = pvVar5;
      pvVar7 = _objc_msgSend(puVar1,sel_mediaWithImage_name_,pvVar5,pvVar2);
      if (pvVar7 != (id)0x0) {
        pvVar2 = (id)0x0;
        _objc_msgSend(applyEffectForHSImageObjectAttributes,sel_setHyperEffectedMedia_refreshName_,
                      pvVar7,0);
        pvVar6 = (id)0x1;
        _objc_msgSend(applyEffectForHSImageObjectAttributes,sel_setCurrentClipPathsAreInitial_,1);
      }
    }
    _objc_msgSend(pvVar5,sel_release,pvVar6,pvVar2,uVar8,pvVar4,pvVar3,pvVar9,uVar10,pvVar11,pvVar12
                 );
    pvVar7 = pvVar2;
  }
  _objc_msgSend(self_00,sel_release,pvVar6,pvVar7);
  return;
}

*/
- (void)applyEffectForHSImageObjectAttributes:(id)aAttributes userInfo:(void *)aInfo
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    id cropApplier = [HSImageCropApplier cropApplierForImageObject:aAttributes];
    [cropApplier updateEffectedImageObject];
    CGImageRef cgImage = [[cropApplier croppedImageDrawing] currentCGImageOfSize:NULL];
    NSImage *source = [NSImage hyperImageWithCGImage:cgImage];
    NSSize size = [source size];
    NSRect rect = NSMakeRect(0.0f, 0.0f, size.width, size.height);
    NSImage *image = [[NSImage alloc] initWithSize:size];
    if (image != nil) {
        [image lockFocus];
        [source drawInRect:rect fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0f];
        [_color drawGradientInCocoaContext:[NSGraphicsContext currentContext] rect:rect ofBounds:rect];
        [image unlockFocus];
        if ([aAttributes hyperImageObject] != nil) {
            id media = [HSNewMedia mediaWithImage:image name:[[[aAttributes hyperImageObject] media] mediaName]];
            if (media != nil) {
                [aAttributes setHyperEffectedMedia:media refreshName:NO];
                [aAttributes setCurrentClipPathsAreInitial:YES];
            }
        }
        [image release];
    }
    [pool release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001d1f02 @ 001d1f02, 853 bytes * /

void FUN_001d1f02(HSGradientEffectController *self,SEL _cmd,
                 id applyEffectForGraphicSelectionToolObject,void *userInfo)

{
  id pvVar1;
  int iVar2;
  int iVar3;
  int iVar4;
  undefined4 *puVar5;
  id local_28;
  float local_1c;
  float fStack_18;
  
  pvVar1 = _objc_msgSend(applyEffectForGraphicSelectionToolObject,sel_valueForKey_);
  if (pvVar1 == (id)0x0) {
    local_28 = (id)0x0;
    puVar5 = (undefined4 *)&stack0xffffff94;
  }
  else {
    _CGPathGetBoundingBox();
    if (0.0 < local_1c) {
      _ceilf();
      _lroundf();
    }
    if (0.0 < fStack_18) {
      _ceilf();
      _lroundf();
    }
    pvVar1 = _objc_msgSend(cls_NSMutableData,sel_alloc);
    local_28 = _objc_msgSend(pvVar1,sel_initWithLength_);
    puVar5 = (undefined4 *)&stack0xffffff90;
    if (local_28 != (id)0x0) {
      _objc_msgSend(local_28,sel_bytes);
      iVar2 = _CGDataProviderCreateWithData();
      puVar5 = (undefined4 *)&stack0xffffff90;
      if (iVar2 != 0) {
        _objc_msgSend(local_28,sel_retain);
        iVar2 = _CGColorSpaceCreateDeviceRGB();
        if (iVar2 == 0) {
          _CGDataProviderRelease();
          puVar5 = (undefined4 *)&stack0xffffff90;
        }
        else {
          _objc_msgSend(local_28,sel_mutableBytes);
          iVar3 = _CGBitmapContextCreate();
          if (iVar3 != 0) {
            _CGContextSaveGState();
            _CGContextTranslateCTM();
            _CGContextBeginPath();
            _CGContextAddPath();
            _CGContextEOClip();
            _objc_msgSend(self->_color,sel_drawGradientInCGContext_rect_ofBounds_);
            _CGContextRestoreGState();
            iVar4 = _CGImageCreate();
            if (iVar4 != 0) {
              pvVar1 = _objc_msgSend(cls_BTCGImage,sel_alloc);
              pvVar1 = _objc_msgSend(pvVar1,sel_initWithCGImage_);
              _objc_msgSend(applyEffectForGraphicSelectionToolObject,sel_performSelector_withObject_
                           );
              _objc_msgSend(pvVar1,sel_release);
              _CGImageRelease();
            }
          }
          _CGDataProviderRelease();
          if (iVar2 != 0) {
            _CGColorSpaceRelease();
          }
          puVar5 = (undefined4 *)&stack0xffffff90;
          if (iVar3 != 0) {
            _CGContextRelease();
            puVar5 = (undefined4 *)&stack0xffffff90;
          }
        }
      }
    }
  }
  puVar5[1] = sel_release;
  *puVar5 = local_28;
  puVar5[-1] = 0x1d224f;
  _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
  return;
}

*/
- (void)applyEffectForGraphicSelectionToolObject:(id)aObject userInfo:(void *)aInfo
{
    CGPathRef path = (CGPathRef)[aObject valueForKey:@"selectionPath"];
    NSMutableData *data = nil;
    if (path != NULL) {
        CGRect box = CGPathGetBoundingBox(path);
        size_t width = (box.size.width > 0.0f) ? (size_t)lroundf(ceilf(box.size.width)) : 0;
        size_t height = (box.size.height > 0.0f) ? (size_t)lroundf(ceilf(box.size.height)) : 0;
        data = [[NSMutableData alloc] initWithLength:width * height * 4];
        if (data != nil) {
            CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, [data bytes], [data length], NULL);
            if (provider != NULL) {
                [data retain];
                CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
                if (colorSpace == NULL) {
                    CGDataProviderRelease(provider);
                } else {
                    CGContextRef context = CGBitmapContextCreate([data mutableBytes], width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedFirst);
                    if (context != NULL) {
                        CGContextSaveGState(context);
                        CGContextTranslateCTM(context, -box.origin.x, -box.origin.y);
                        CGContextBeginPath(context);
                        CGContextAddPath(context, path);
                        CGContextEOClip(context);
                        [_color drawGradientInCGContext:context rect:NSRectFromCGRect(box) ofBounds:NSRectFromCGRect(box)];
                        CGContextRestoreGState(context);
                        CGImageRef cgImage = CGImageCreate(width, height, 8, 32, width * 4, colorSpace, kCGImageAlphaPremultipliedFirst, provider, NULL, true, kCGRenderingIntentDefault);
                        if (cgImage != NULL) {
                            id btImage = [[BTCGImage alloc] initWithCGImage:cgImage];
                            [aObject performSelector:@selector(setImageSelection:) withObject:btImage];
                            [btImage release];
                            CGImageRelease(cgImage);
                        }
                    }
                    CGDataProviderRelease(provider);
                    CGColorSpaceRelease(colorSpace);
                    if (context != NULL) {
                        CGContextRelease(context);
                    }
                }
            }
        }
    }
    [data release];
}

- (void)applyChanges
{
    [[self effectApplier] setUndoActionName:[self undoActionName]];
    [[self effectApplier] applyEffectWithDelegate:self userInfo:_color];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001d1068 @ 001d1068, 653 bytes * /

void FUN_001d1068(HSGradientEffectController *self,SEL _cmd)

{
  undefined4 uVar1;
  undefined4 uVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  undefined4 extraout_EDX;
  
  pvVar3 = self->_originalImage;
  if (pvVar3 == (id)0x0) {
    pvVar3 = _objc_msgSend(self,sel_effectApplier);
    pvVar3 = _objc_msgSend(pvVar3,sel_previewImage);
    pvVar3 = _objc_msgSend(pvVar3,sel_retain);
    self->_originalImage = pvVar3;
  }
  uVar1 = *(undefined4 *)PTR_00336074;
  uVar2 = *(undefined4 *)(PTR_00336074 + 4);
  pvVar4 = _objc_msgSend(pvVar3,sel_size);
  pvVar3 = _objc_msgSend(cls_NSImage,sel_alloc);
  pvVar5 = _objc_msgSend(pvVar3,sel_initWithSize_,pvVar4,extraout_EDX);
  _objc_msgSend(pvVar5,sel_lockFocus);
  pvVar3 = self->_color;
  pvVar6 = _objc_msgSend(cls_NSGraphicsContext,sel_currentContext);
  _objc_msgSend(pvVar3,sel_drawGradientInCocoaContext_rect_ofBounds_,pvVar6,uVar1,uVar2,pvVar4,
                extraout_EDX,uVar1,uVar2,pvVar4,extraout_EDX);
  _objc_msgSend(self->_originalImage,sel_drawInRect_fromRect_operation_fraction_,uVar1,uVar2,pvVar4,
                extraout_EDX,(int)*(undefined8 *)PTR_00336078,
                (int)((ulonglong)*(undefined8 *)PTR_00336078 >> 0x20),
                (int)*(undefined8 *)(PTR_00336078 + 8),
                (int)((ulonglong)*(undefined8 *)(PTR_00336078 + 8) >> 0x20),7,0x3f800000);
  _objc_msgSend(pvVar5,sel_unlockFocus);
  pvVar3 = self->_preview;
  pvVar4 = _objc_msgSend(self,sel_objectGeometryAttributes);
  pvVar4 = _objc_msgSend(pvVar4,sel_isFlippedVertically);
  _objc_msgSend(pvVar3,sel_setFlippedVertically_,(int)(char)pvVar4);
  pvVar3 = self->_preview;
  pvVar4 = _objc_msgSend(self,sel_objectGeometryAttributes);
  pvVar4 = _objc_msgSend(pvVar4,sel_isFlippedHorizontally);
  _objc_msgSend(pvVar3,sel_setFlippedHorizontally_,(int)(char)pvVar4);
  pvVar3 = self->_preview;
  pvVar4 = _objc_msgSend(self,sel_effectApplier);
  pvVar5 = _objc_msgSend(pvVar5,sel_autorelease);
  pvVar4 = _objc_msgSend(pvVar4,sel_previewImageForImage_,pvVar5);
  _objc_msgSend(pvVar3,sel_setImage_,pvVar4);
  return;
}

*/
- (void)update
{
    if (_originalImage == nil) {
        _originalImage = [[[self effectApplier] previewImage] retain];
    }
    NSSize size = [_originalImage size];
    NSRect rect = NSMakeRect(0.0f, 0.0f, size.width, size.height);
    NSImage *image = [[NSImage alloc] initWithSize:size];
    [image lockFocus];
    [_color drawGradientInCocoaContext:[NSGraphicsContext currentContext] rect:rect ofBounds:rect];
    [_originalImage drawInRect:rect fromRect:NSZeroRect operation:NSCompositingOperationDestinationIn fraction:1.0f];
    [image unlockFocus];
    [_preview setFlippedVertically:[[self objectGeometryAttributes] isFlippedVertically]];
    [_preview setFlippedHorizontally:[[self objectGeometryAttributes] isFlippedHorizontally]];
    [_preview setImage:[[self effectApplier] previewImageForImage:[image autorelease]]];
}

- (void)didMount
{
    id pvVar1_2;

    [_color release];
    pvVar1_2 = [[HSColor alloc] initWithOwner:nil];
    _color = pvVar1_2;
    [pvVar1_2 setStartColor:[_bottomColorWell color]];
    [_color setEndColor:[_topColorWell color]];
    [self setGradientKindFromInterface:_styleMatrix];
    [self update];
}

- (void)didUnmount
{
    [_originalImage release];
    _originalImage = nil;
}

- (void)didLoadNib
{
    [super didLoadNib];
    [self revertSettingsToDefault];
    [_topColorWell setPatternSupportEnabled:NO];
    [_topColorWell setGradientSupportEnabled:NO];
    [_bottomColorWell setPatternSupportEnabled:NO];
    [_bottomColorWell setGradientSupportEnabled:NO];
}

- (void)revertSettingsToDefault
{
    [_bottomColorWell setColor:[[self class] defaultStartColor]];
    [_topColorWell setColor:[[self class] defaultEndColor]];
    [_color setStartColor:[_bottomColorWell color]];
    [_color setEndColor:[_topColorWell color]];
    [_styleMatrix selectCellAtRow:0 column:0];
    [self setGradientKindFromInterface:_styleMatrix];
    [self update];
}

- (id)undoActionName
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Gradients" value:@"" table:@"UndoManager"];
    return [NSString stringWithFormat:[[NSBundle mainBundle] localizedStringForKey:@"ApplyGraphicEffect" value:@"" table:@"UndoManager"], pvVar1_2];
}

- (id)nibName
{
    return @"GradientEffectController";
}

- (id)effect
{
    return nil;
}

- (void)dealloc
{
    [_originalImage release];
    [_color release];
    [super dealloc];
}

@end

