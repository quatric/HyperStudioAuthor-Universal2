#import "HSCelAnimationFrameCroppingContext.h"

// Draws the part of an image inside a clip path into a new image of the destination size.
static NSImage *HSCelAnimationCroppedImage(NSImage *aImage, NSRect aFromRect, NSRect aDestinationRect, NSBezierPath *aClipPath, NSAffineTransform *aTransform)
{
    NSImage *image = [[NSImage alloc] initWithSize:aDestinationRect.size];
    [image lockFocus];
    [aTransform concat];
    [[NSGraphicsContext currentContext] setShouldAntialias:NO];
    [[NSColor clearColor] set];
    [NSBezierPath fillRect:aDestinationRect];
    [aClipPath setClip];
    [aImage compositeToPoint:NSIntegralRect(aDestinationRect).origin fromRect:NSIntegralRect(aFromRect) operation:NSCompositingOperationSourceOver];
    [image unlockFocus];
    return [image autorelease];
}

@implementation HSCelAnimationFrameCroppingContext

/* i386 ivar offsets: _croppingPath=0x4, _originalFrameSize=0x8, _selectedFrameSize=0x10, _requestedFrameRect=0x18, _contextTransform=0x28 */

- (id)contextTransform
{
    return _contextTransform;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001245a6 @ 001245a6, 52 bytes * /

NSRect * FUN_001245a6(NSRect *__return_storage_ptr__,HSCelAnimationFrameCroppingContext *self,
                     SEL _cmd)

{
  (__return_storage_ptr__->origin).x = (self->_requestedFrameRect).origin.x;
  (__return_storage_ptr__->origin).y = (self->_requestedFrameRect).origin.y;
  (__return_storage_ptr__->size).width = (self->_requestedFrameRect).size.width;
  (__return_storage_ptr__->size).height = (self->_requestedFrameRect).size.height;
  return (NSRect *)self;
}

*/
- (NSRect)requestedFrameRect
{
    return _requestedFrameRect;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00124598 @ 00124598, 14 bytes * /

ulonglong FUN_00124598(HSCelAnimationFrameCroppingContext *self,SEL _cmd)

{
  ulonglong uVar1;
  
  uVar1._0_4_ = (self->_selectedFrameSize).width;
  uVar1._4_4_ = (self->_selectedFrameSize).height;
  return uVar1;
}

*/
- (NSSize)selectedFrameSize
{
    return _selectedFrameSize;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0012458a @ 0012458a, 14 bytes * /

ulonglong FUN_0012458a(HSCelAnimationFrameCroppingContext *self,SEL _cmd)

{
  ulonglong uVar1;
  
  uVar1._0_4_ = (self->_originalFrameSize).width;
  uVar1._4_4_ = (self->_originalFrameSize).height;
  return uVar1;
}

*/
- (NSSize)originalFrameSize
{
    return _originalFrameSize;
}

- (id)croppingPath
{
    return _croppingPath;
}

- (void)dealloc
{
    [_croppingPath release];
    [_contextTransform release];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00127605 @ 00127605, 201 bytes * /

id FUN_00127605(HSCelAnimationFrameCroppingContext *self,SEL _cmd,id initWithCroppingPath,
               NSSize originalFrameSize,NSSize selectedFrameSize,NSRect requestedFrameRect,
               id contextTransform)

{
  id pvVar1;
  id pvVar2;
  HSCelAnimationFrameCroppingContext *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_NSObject_003512f0;
  pvVar1 = _objc_msgSendSuper(&local_1c,sel_init);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(initWithCroppingPath,sel_retain);
    *(id *)((int)pvVar1 + 4) = pvVar2;
    *(float *)((int)pvVar1 + 8) = originalFrameSize.width;
    *(float *)((int)pvVar1 + 0xc) = originalFrameSize.height;
    *(float *)((int)pvVar1 + 0x10) = selectedFrameSize.width;
    *(float *)((int)pvVar1 + 0x14) = selectedFrameSize.height;
    *(float *)((int)pvVar1 + 0x18) = requestedFrameRect.origin.x;
    *(float *)((int)pvVar1 + 0x1c) = requestedFrameRect.origin.y;
    *(float *)((int)pvVar1 + 0x20) = requestedFrameRect.size.width;
    *(float *)((int)pvVar1 + 0x24) = requestedFrameRect.size.height;
    pvVar2 = _objc_msgSend(contextTransform,sel_retain);
    *(id *)((int)pvVar1 + 0x28) = pvVar2;
  }
  return pvVar1;
}

*/
- (id)initWithCroppingPath:(id)aPath originalFrameSize:(NSSize)aSize selectedFrameSize:(NSSize)aSize2 requestedFrameRect:(NSRect)aRect contextTransform:(id)aTransform
{
    self = [super init];
    if (self != nil) {
        _croppingPath = [aPath retain];
        _originalFrameSize = aSize;
        _selectedFrameSize = aSize2;
        _requestedFrameRect = aRect;
        _contextTransform = [aTransform retain];
    }
    return self;
}

@end

@implementation HSAnimationSetupPickImageAssistantPane

/* i386 ivar offsets: _animationModeController=0x5c, _delegate=0x60, _selectPartOfCardButton=0x64, _selectGraphicButton=0x68, _selectSequenceButton=0x6c, _selectMovieButton=0x70, _selectPartOfCardTextButton=0x74, _selectGraphicTextButton=0x78, _selectSequenceTextButton=0x7c, _selectMovieTextButton=0x80, _importGraphicDialogController=0x84, _importMovieDialogController=0x88, _navigationPaneSwitcher=0x8c, _paneOpenedAsModalViewController=0x90, _tolerance=0x94 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_00124624 @ 00124624, 602 bytes * /

id FUN_00124624(id self,SEL _cmd,id applySmartCroppingToImageMedia,id context)

{
  char cVar1;
  id pvVar2;
  id self_00;
  id pvVar3;
  id pvVar4;
  float extraout_EDX;
  undefined4 extraout_EDX_00;
  float extraout_EDX_01;
  float local_34;
  float fStack_30;
  id local_2c;
  float fStack_28;
  float local_24;
  float fStack_20;
  id local_1c;
  float fStack_18;
  
  pvVar2 = _objc_msgSend(context,sel_croppingPath);
  self_00 = _objc_msgSend(applySmartCroppingToImageMedia,sel_image);
  pvVar3 = _objc_msgSend(self_00,sel_size);
  pvVar4 = _objc_msgSend(context,sel_originalFrameSize);
  _objc_msgSend_stret(&local_24,context,sel_requestedFrameRect);
  local_34 = local_24;
  fStack_30 = fStack_20;
  local_2c = local_1c;
  fStack_28 = fStack_18;
  cVar1 = _NSEqualSizes(pvVar3,extraout_EDX,pvVar4,extraout_EDX_00);
  if (cVar1 == '\0') {
    local_34 = *(float *)PTR_00336074;
    fStack_30 = *(float *)(PTR_00336074 + 4);
    local_2c = _objc_msgSend(context,sel_selectedFrameSize);
    if ((float)local_2c < (float)pvVar3) {
      local_34 = ((float)pvVar3 - (float)local_2c) * 0.5;
    }
    else {
      local_24 = local_24 + ((float)local_2c - (float)pvVar3) * 0.5;
    }
    fStack_28 = extraout_EDX_01;
    if (extraout_EDX_01 < extraout_EDX) {
      fStack_30 = (extraout_EDX - extraout_EDX_01) * 0.5;
    }
    else {
      fStack_20 = fStack_20 + (extraout_EDX_01 - extraout_EDX) * 0.5;
    }
  }
  else if (pvVar2 == (id)0x0) goto LAB_00124871;
  pvVar2 = _objc_msgSend(context,sel_contextTransform);
  pvVar3 = _objc_msgSend(context,sel_croppingPath);
  FUN_00127731(self_00,CONCAT44(fStack_30,local_34),CONCAT44(fStack_28,local_2c),
               CONCAT44(fStack_20,local_24),CONCAT44(fStack_18,local_1c),pvVar3,pvVar2);
LAB_00124871:
  pvVar2 = _objc_msgSend(cls_HSNewMedia,sel_mediaWithImage_);
  return pvVar2;
}

*/
+ (id)applySmartCroppingToImageMedia:(id)aMedia context:(id)aContext
{
    id croppingPath = [aContext croppingPath];
    NSImage *image = [aMedia image];
    NSSize imageSize = [image size];
    NSSize originalSize = [aContext originalFrameSize];
    NSRect requestedRect = [aContext requestedFrameRect];
    NSRect fromRect = requestedRect;
    NSSize selectedSize;
    if (!NSEqualSizes(imageSize, originalSize)) {
        // Frames of a different size are centred in the selected frame.
        fromRect.origin = NSZeroPoint;
        selectedSize = [aContext selectedFrameSize];
        fromRect.size = selectedSize;
        if (selectedSize.width < imageSize.width) {
            fromRect.origin.x = (imageSize.width - selectedSize.width) * 0.5f;
        }
        else {
            requestedRect.origin.x = requestedRect.origin.x + (selectedSize.width - imageSize.width) * 0.5f;
        }
        if (selectedSize.height < imageSize.height) {
            fromRect.origin.y = (imageSize.height - selectedSize.height) * 0.5f;
        }
        else {
            requestedRect.origin.y = requestedRect.origin.y + (selectedSize.height - imageSize.height) * 0.5f;
        }
    }
    else if (croppingPath == nil) {
        return [HSNewMedia mediaWithImage:image];
    }
    return [HSNewMedia mediaWithImage:HSCelAnimationCroppedImage(image, fromRect, requestedRect, [aContext croppingPath], [aContext contextTransform])];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0012487e @ 0012487e, 224 bytes * /

id FUN_0012487e(id self,SEL _cmd,id applyCroppingToImageMedia,id context)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined8 local_24;
  undefined8 local_1c;
  
  pvVar1 = _objc_msgSend(context,sel_croppingPath);
  if (pvVar1 != (id)0x0) {
    _objc_msgSend_stret(&local_24,context,sel_requestedFrameRect);
    pvVar1 = _objc_msgSend(context,sel_contextTransform);
    pvVar2 = _objc_msgSend(context,sel_croppingPath);
    pvVar3 = _objc_msgSend(applyCroppingToImageMedia,sel_image);
    FUN_00127731(pvVar3,local_24,local_1c,local_24,local_1c,pvVar2,pvVar1);
    applyCroppingToImageMedia = _objc_msgSend(cls_HSNewMedia,sel_mediaWithImage_);
  }
  return applyCroppingToImageMedia;
}

*/
+ (id)applyCroppingToImageMedia:(id)aMedia context:(id)aContext
{
    NSRect requestedRect;
    if ([aContext croppingPath] == nil) {
        return aMedia;
    }
    requestedRect = [aContext requestedFrameRect];
    return [HSNewMedia mediaWithImage:HSCelAnimationCroppedImage([aMedia image], requestedRect, requestedRect, [aContext croppingPath], [aContext contextTransform])];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0012495e @ 0012495e, 708 bytes * /

id FUN_0012495e(id self,SEL _cmd,id celAnimationMovieWithGIF,id croppingPath,
               NSSize selectedFrameSize)

{
  undefined *self_00;
  char cVar1;
  id pvVar2;
  int iVar3;
  int *piVar4;
  id pvVar5;
  int aiStack_88 [3];
  float fStack_70;
  int local_6c [8];
  id local_4c;
  undefined4 local_44;
  undefined4 local_40;
  float local_3c;
  float local_38;
  undefined4 local_34;
  undefined4 uStack_30;
  float local_2c;
  float fStack_28;
  undefined4 local_24;
  undefined4 uStack_20;
  float local_1c;
  float fStack_18;
  
  local_24 = *(undefined4 *)PTR_00336074;
  uStack_20 = *(undefined4 *)(PTR_00336074 + 4);
  local_1c = selectedFrameSize.width;
  fStack_18 = selectedFrameSize.height;
  aiStack_88[2] = 0x1249b4;
  cVar1 = _NSIsEmptyRect();
  piVar4 = (int *)&stack0xffffff84;
  if (cVar1 == '\0') {
    aiStack_88[2] = 0x1249de;
    pvVar5 = _objc_msgSend(cls_NSData,sel_dataWithContentsOfFile_);
    piVar4 = (int *)&stack0xffffff84;
    if (pvVar5 != (id)0x0) {
      aiStack_88[2] = 0x1249f7;
      pvVar2 = _objc_msgSend(pvVar5,sel_length);
      self_00 = cls_HSNewMedia;
      piVar4 = (int *)&stack0xffffff84;
      if (pvVar2 != (id)0x0) {
        aiStack_88[2] = 0x124a13;
        pvVar2 = _objc_msgSend(celAnimationMovieWithGIF,sel_lastPathComponent);
        aiStack_88[2] = 0x124a25;
        _objc_msgSend(pvVar2,sel_stringByDeletingPathExtension);
        aiStack_88[2] = 0x124a4c;
        pvVar2 = _objc_msgSend(self_00,sel_mediaWithData_name_type_);
        piVar4 = (int *)&stack0xffffff84;
        if (pvVar2 != (id)0x0) {
          local_4c = croppingPath;
          local_34 = *(undefined4 *)PTR_00336078;
          uStack_30 = *(undefined4 *)(PTR_00336078 + 4);
          local_2c = *(float *)(PTR_00336078 + 8);
          fStack_28 = *(float *)(PTR_00336078 + 0xc);
          piVar4 = (int *)&stack0xffffff84;
          if (croppingPath != (id)0x0) {
            aiStack_88[2] = 0x124aaa;
            _objc_msgSend_stret(&local_34,croppingPath,sel_bounds);
            piVar4 = aiStack_88 + 2;
          }
          *(ulonglong *)(piVar4 + 2) = CONCAT44(fStack_28,local_2c);
          *(ulonglong *)piVar4 = CONCAT44(uStack_30,local_34);
          piVar4[-1] = 0x124ac7;
          cVar1 = _NSIsEmptyRect();
          if (cVar1 == '\0') {
            *(ulonglong *)(piVar4 + 7) = CONCAT44(fStack_18,local_1c);
            *(ulonglong *)(piVar4 + 5) = CONCAT44(uStack_20,local_24);
            *(ulonglong *)(piVar4 + 3) = CONCAT44(fStack_28,local_2c);
            *(ulonglong *)(piVar4 + 1) = CONCAT44(uStack_30,local_34);
            *piVar4 = (int)&local_44;
            piVar4[-1] = 0x124b02;
            _NSIntersectionRect();
            piVar4 = piVar4 + -1;
            local_34 = local_44;
            uStack_30 = local_40;
            local_2c = local_3c;
          }
          else {
            local_34 = local_24;
            uStack_30 = uStack_20;
            local_2c = local_1c;
            local_4c = (id)0x0;
            local_38 = fStack_18;
          }
          *(ulonglong *)(piVar4 + 2) = CONCAT44(local_38,local_2c);
          *(ulonglong *)piVar4 = CONCAT44(uStack_30,local_34);
          piVar4[-1] = 0x124b73;
          fStack_28 = local_38;
          cVar1 = _NSIsEmptyRect();
          if (cVar1 == '\0') {
            *piVar4 = (int)pvVar5;
            piVar4[1] = 0;
            piVar4[-1] = 0x124b8e;
            iVar3 = _CGImageSourceCreateWithData();
            piVar4[1] = (int)sel_alloc;
            *piVar4 = (int)cls_HSGIFMovieObject;
            piVar4[-1] = 0x124ba8;
            pvVar5 = _objc_msgSend((id)*piVar4,(SEL)piVar4[1]);
            piVar4[1] = (int)sel_mediaUID;
            *piVar4 = (int)pvVar2;
            piVar4[-1] = 0x124bc0;
            pvVar2 = _objc_msgSend((id)*piVar4,(SEL)piVar4[1]);
            piVar4[6] = iVar3;
            piVar4[5] = (int)fStack_28;
            piVar4[4] = (int)local_2c;
            piVar4[3] = (int)local_4c;
            piVar4[2] = (int)pvVar2;
            piVar4[1] = (int)sel_initWithFramesMedia_croppingPath_frameSize_precachedSource_;
            *piVar4 = (int)pvVar5;
            piVar4[-1] = 0x124bfa;
            pvVar5 = _objc_msgSend((id)*piVar4,(SEL)piVar4[1]);
            if (iVar3 != 0) {
              *piVar4 = iVar3;
              piVar4[-1] = 0x124c08;
              _CFRelease();
            }
            goto LAB_00124c08;
          }
        }
      }
    }
  }
  pvVar5 = (id)0x0;
LAB_00124c08:
  piVar4[1] = (int)sel_autorelease;
  *piVar4 = (int)pvVar5;
  piVar4[-1] = 0x124c1a;
  pvVar5 = _objc_msgSend((id)*piVar4,(SEL)piVar4[1]);
  return pvVar5;
}

*/
+ (id)celAnimationMovieWithGIF:(id)aGIF croppingPath:(id)aPath selectedFrameSize:(NSSize)aSize
{
    NSRect frameRect = NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, aSize.width, aSize.height);
    NSData *data;
    id media;
    id croppingPath;
    NSRect bounds;
    CGImageSourceRef source;
    id movie;
    if (NSIsEmptyRect(frameRect)) {
        return nil;
    }
    data = [NSData dataWithContentsOfFile:aGIF];
    if (data == nil || [data length] == 0) {
        return nil;
    }
    media = [HSNewMedia mediaWithData:data name:[[aGIF lastPathComponent] stringByDeletingPathExtension] type:@"GIFAnimatonData"];
    if (media == nil) {
        return nil;
    }
    croppingPath = aPath;
    bounds = NSZeroRect;
    if (aPath != nil) {
        bounds = [aPath bounds];
    }
    if (!NSIsEmptyRect(bounds)) {
        bounds = NSIntersectionRect(bounds, frameRect);
    }
    else {
        bounds = frameRect;
        croppingPath = nil;
    }
    if (NSIsEmptyRect(bounds)) {
        return nil;
    }
    source = CGImageSourceCreateWithData((CFDataRef)data, NULL);
    movie = [[HSGIFMovieObject alloc] initWithFramesMedia:[media mediaUID] croppingPath:croppingPath frameSize:bounds.size precachedSource:source];
    if (source != NULL) {
        CFRelease(source);
    }
    return [movie autorelease];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00124c22 @ 00124c22, 3080 bytes * /

id FUN_00124c22(id self,SEL _cmd,id celAnimationMovieWithFrameFormat,int firstFrame,uint count,
               id croppingPath,NSSize selectedFrameSize)

{
  undefined4 uVar1;
  undefined4 uVar2;
  undefined *puVar3;
  bool bVar4;
  char cVar5;
  id pvVar6;
  id pvVar7;
  int iVar8;
  id pvVar9;
  float *pfVar10;
  id pvVar11;
  id pvVar12;
  float extraout_EDX;
  float extraout_EDX_00;
  undefined4 extraout_EDX_01;
  undefined **ppuVar13;
  float *pfVar14;
  longdouble lVar15;
  longdouble lVar16;
  float fVar17;
  float fVar18;
  float afStack_110 [5];
  id local_bc;
  id local_a0;
  id local_94;
  id local_90;
  undefined4 local_8c;
  undefined4 local_88;
  undefined4 local_84;
  undefined4 local_80;
  float local_7c;
  float local_78;
  id local_74;
  float local_70;
  float local_6c;
  float local_68;
  id local_64;
  float local_60;
  float local_5c;
  float fStack_58;
  float local_54;
  float fStack_50;
  float local_4c;
  float fStack_48;
  id local_44;
  float fStack_40;
  undefined4 local_3c;
  undefined4 uStack_38;
  id local_34;
  float fStack_30;
  id local_28;
  float local_24;
  float local_20;
  
  pfVar14 = (float *)&stack0xffffff04;
  afStack_110[4] = 1.680409e-39;
  pvVar6 = _objc_msgSend(cls_NSMutableArray,sel_alloc);
  afStack_110[4] = 1.680444e-39;
  local_94 = _objc_msgSend(pvVar6,sel_initWithCapacity_);
  afStack_110[4] = 1.680486e-39;
  pvVar6 = _objc_msgSend(cls_NSMutableArray,sel_alloc);
  afStack_110[4] = 1.680517e-39;
  pvVar7 = _objc_msgSend(pvVar6,sel_initWithCapacity_);
  afStack_110[4] = 1.680579e-39;
  _objc_msgSend(cls_NSString,sel_stringWithFormat_);
  puVar3 = PTR_00336078;
  local_28 = (id)0x0;
  uVar1 = *(undefined4 *)PTR_00336078;
  uVar2 = *(undefined4 *)(PTR_00336078 + 4);
  afStack_110[4] = 1.680685e-39;
  _objc_msgSend(self,sel_frameMediaWithPath_frameImage_);
  local_3c = uVar1;
  uStack_38 = uVar2;
  pvVar6 = *(id *)(puVar3 + 8);
  local_34 = pvVar6;
  fVar17 = *(float *)(puVar3 + 0xc);
  fStack_30 = fVar17;
  local_90 = pvVar7;
  if (local_28 == (id)0x0) {
    local_a0 = (id)0x0;
    goto LAB_001257d7;
  }
  afStack_110[4] = 1.680879e-39;
  local_34 = _objc_msgSend(local_28,sel_size);
  fStack_30 = extraout_EDX;
  if (((float)local_34 != 0.0) && (extraout_EDX != 0.0)) {
    afStack_110[4] = 1.680984e-39;
    _objc_msgSend(local_94,sel_addObject_);
    afStack_110[4] = 1.681031e-39;
    _objc_msgSend(pvVar7,sel_addObject_);
  }
  local_bc = croppingPath;
  iVar8 = count + firstFrame;
  bVar4 = true;
  while (firstFrame = firstFrame + 1, firstFrame < iVar8) {
    local_28 = (id)0x0;
    afStack_110[4] = 1.681135e-39;
    _objc_msgSend(cls_NSString,sel_stringWithFormat_);
    afStack_110[4] = 1.68118e-39;
    _objc_msgSend(self,sel_frameMediaWithPath_frameImage_);
    if (local_28 != (id)0x0) {
      afStack_110[4] = 1.681223e-39;
      pvVar9 = _objc_msgSend(local_28,sel_size);
      if (((float)pvVar9 != 0.0) && ((extraout_EDX_00 != 0.0 || (NAN(extraout_EDX_00))))) {
        afStack_110[4] = 1.681377e-39;
        cVar5 = _NSEqualSizes();
        if (cVar5 == '\0') {
          afStack_110[4] = 1.681424e-39;
          lVar15 = (longdouble)_fmaxf();
          local_34 = (id)(float)lVar15;
          afStack_110[4] = 1.681468e-39;
          lVar15 = (longdouble)_fmaxf();
          fStack_30 = (float)lVar15;
          bVar4 = false;
        }
        afStack_110[4] = 1.681526e-39;
        _objc_msgSend(local_94,sel_addObject_);
        afStack_110[4] = 1.681565e-39;
        _objc_msgSend(pvVar7,sel_addObject_);
      }
    }
  }
  afStack_110[4] = 1.681617e-39;
  pvVar9 = _objc_msgSend(pvVar7,sel_count);
  pfVar14 = (float *)&stack0xffffff04;
  if ((id)0x1 < pvVar9) {
    afStack_110[4] = 1.681701e-39;
    cVar5 = _NSIsEmptyRect();
    pfVar14 = (float *)&stack0xffffff04;
    if (cVar5 == '\0') {
      local_4c = *(float *)puVar3;
      fStack_48 = *(float *)(puVar3 + 4);
      pfVar14 = (float *)&stack0xffffff04;
      local_44 = pvVar6;
      fStack_40 = fVar17;
      if (croppingPath != (id)0x0) {
        afStack_110[4] = 1.681826e-39;
        _objc_msgSend_stret(&local_4c,croppingPath,sel_bounds);
        pfVar14 = afStack_110 + 4;
      }
      *(ulonglong *)(pfVar14 + 2) = CONCAT44(fStack_40,local_44);
      *(ulonglong *)pfVar14 = CONCAT44(fStack_48,local_4c);
      pfVar14[-1] = 1.681866e-39;
      cVar5 = _NSIsEmptyRect();
      if (cVar5 == '\0') {
        if (!bVar4) {
          fVar17 = *(float *)PTR_00336074;
          pfVar14[3] = *(float *)(PTR_00336074 + 4);
          pfVar14[2] = fVar17;
          fVar18 = (fStack_30 - selectedFrameSize.height) * 0.5;
          pfVar14[1] = fVar18;
          fVar17 = ((float)local_34 - selectedFrameSize.width) * 0.5;
          *pfVar14 = fVar17;
          pfVar14[-1] = 1.682323e-39;
          cVar5 = _NSEqualPoints();
          if (cVar5 == '\0') {
            *(ulonglong *)(pfVar14 + 3) = CONCAT44(fStack_40,local_44);
            *(ulonglong *)(pfVar14 + 1) = CONCAT44(fVar18,fVar17);
            *pfVar14 = (float)&local_24;
            pfVar14[-1] = 1.682417e-39;
            local_4c = fVar17;
            fStack_48 = fVar18;
            _NSIntegralRect();
            *pfVar14 = (float)sel_transform;
            pfVar14[-1] = (float)cls_NSAffineTransform;
            pfVar14[-2] = 1.682491e-39;
            pvVar6 = _objc_msgSend((id)pfVar14[-1],(SEL)*pfVar14);
            pfVar14[2] = local_20;
            pfVar14[1] = local_24;
            *pfVar14 = (float)sel_translateXBy_yBy_;
            pfVar14[-1] = (float)pvVar6;
            pfVar14[-2] = 1.682559e-39;
            _objc_msgSend((id)pfVar14[-1],(SEL)*pfVar14);
            pfVar14[1] = (float)pvVar6;
            *pfVar14 = (float)sel_transformUsingAffineTransform_;
            pfVar14[-1] = (float)croppingPath;
            pfVar14[-2] = 1.682594e-39;
            _objc_msgSend((id)pfVar14[-1],(SEL)*pfVar14);
            pfVar14[1] = (float)sel_bounds;
            *pfVar14 = (float)croppingPath;
            pfVar14[-1] = (float)&local_7c;
            pfVar14[-2] = 1.682629e-39;
            _objc_msgSend_stret((void *)pfVar14[-1],(id)*pfVar14,(SEL)pfVar14[1]);
            pfVar14 = pfVar14 + -2;
            local_4c = local_7c;
            fStack_48 = local_78;
            local_44 = local_74;
            fStack_40 = local_70;
          }
        }
      }
      else {
        if (bVar4) goto LAB_0012565c;
        local_4c = ((float)local_34 - selectedFrameSize.width) * 0.5;
        fStack_48 = (fStack_30 - selectedFrameSize.height) * 0.5;
        local_44 = (id)selectedFrameSize.width;
        fStack_40 = selectedFrameSize.height;
        *(NSSize *)(pfVar14 + 3) = selectedFrameSize;
        *(ulonglong *)(pfVar14 + 1) = CONCAT44(fStack_48,local_4c);
        *pfVar14 = (float)&local_6c;
        pfVar14[-1] = 1.682032e-39;
        _NSIntegralRect();
        local_4c = local_6c;
        fStack_48 = local_68;
        local_44 = local_64;
        fStack_40 = local_60;
        *(ulonglong *)(pfVar14 + 3) = CONCAT44(local_60,local_64);
        *(ulonglong *)(pfVar14 + 1) = CONCAT44(local_68,local_6c);
        *pfVar14 = (float)sel_bezierPathWithRect_;
        pfVar14[-1] = (float)cls_NSBezierPath;
        pfVar14[-2] = 1.682157e-39;
        local_bc = _objc_msgSend((id)pfVar14[-1],(SEL)*pfVar14);
        pfVar14 = pfVar14 + -1;
      }
      fVar17 = fStack_48;
      puVar3 = PTR_00336074;
      local_90 = (id)fStack_48;
      pfVar10 = &local_4c;
      if (local_4c <= 0.0) {
        pfVar10 = (float *)PTR_00336074;
      }
      fVar18 = *pfVar10;
      pfVar14[1] = fStack_30;
      *pfVar14 = fStack_40;
      pfVar14[-1] = 1.682794e-39;
      lVar15 = (longdouble)_fminf();
      pfVar14[1] = (float)local_34;
      *pfVar14 = (float)local_44;
      pfVar14[-1] = 1.682839e-39;
      lVar16 = (longdouble)_fminf();
      if (fVar17 <= 0.0) {
        local_90 = *(id *)(puVar3 + 4);
      }
      fStack_58 = (float)local_90;
      local_54 = (float)lVar16;
      fStack_50 = (float)lVar15;
      *(ulonglong *)(pfVar14 + 3) = CONCAT44(fStack_50,local_54);
      *(ulonglong *)(pfVar14 + 1) = CONCAT44(local_90,fVar18);
      *pfVar14 = (float)&local_8c;
      pfVar14[-1] = 1.683001e-39;
      local_5c = fVar18;
      _NSIntegralRect();
      local_5c = (float)local_8c;
      fStack_58 = (float)local_88;
      local_54 = (float)local_84;
      fStack_50 = (float)local_80;
      *pfVar14 = (float)sel_transform;
      pfVar14[-1] = (float)cls_NSAffineTransform;
      pfVar14[-2] = 1.683136e-39;
      pvVar6 = _objc_msgSend((id)pfVar14[-1],(SEL)*pfVar14);
      pfVar14[2] = -(float)local_90;
      pfVar14[1] = -fVar18;
      *pfVar14 = (float)sel_translateXBy_yBy_;
      pfVar14[-1] = (float)pvVar6;
      ppuVar13 = &sel_applyCroppingToImageMedia_context_;
      if (!bVar4) {
        ppuVar13 = &sel_applySmartCroppingToImageMedia_context_;
      }
      pfVar14[-2] = 1.683244e-39;
      _objc_msgSend((id)pfVar14[-1],(SEL)*pfVar14);
      puVar3 = *ppuVar13;
      *pfVar14 = (float)sel_alloc;
      pfVar14[-1] = (float)cls_HSCelAnimationFrameCroppingContext;
      pfVar14[-2] = 1.683289e-39;
      pvVar9 = _objc_msgSend((id)pfVar14[-1],(SEL)*pfVar14);
      *(ulonglong *)(pfVar14 + 8) = CONCAT44(fStack_50,local_54);
      *(ulonglong *)(pfVar14 + 6) = CONCAT44(fStack_58,local_5c);
      pfVar14[10] = (float)pvVar6;
      pfVar14[5] = selectedFrameSize.height;
      pfVar14[4] = selectedFrameSize.width;
      pfVar14[3] = fStack_30;
      pfVar14[2] = (float)local_34;
      pfVar14[1] = (float)local_bc;
      *pfVar14 = (float)
                 sel_initWithCroppingPath_originalFrameSize_selectedFrameSize_requestedFrameRect_contextTransform_
      ;
      pfVar14[-1] = (float)pvVar9;
      pfVar14[-2] = 1.683426e-39;
      pvVar6 = _objc_msgSend((id)pfVar14[-1],(SEL)*pfVar14);
      *pfVar14 = (float)sel_alloc;
      pfVar14[-1] = (float)cls_NSMutableArray;
      pfVar14[-2] = 1.683468e-39;
      pvVar9 = _objc_msgSend((id)pfVar14[-1],(SEL)*pfVar14);
      *pfVar14 = (float)sel_count;
      pfVar14[-1] = (float)pvVar7;
      pfVar14[-2] = 1.683505e-39;
      pvVar12 = _objc_msgSend((id)pfVar14[-1],(SEL)*pfVar14);
      pfVar14[1] = (float)pvVar12;
      *pfVar14 = (float)sel_initWithCapacity_;
      pfVar14[-1] = (float)pvVar9;
      pfVar14[-2] = 1.683535e-39;
      local_90 = _objc_msgSend((id)pfVar14[-1],(SEL)*pfVar14);
      *pfVar14 = (float)sel_alloc;
      pfVar14[-1] = (float)cls_NSMutableArray;
      pfVar14[-2] = 1.683577e-39;
      pvVar9 = _objc_msgSend((id)pfVar14[-1],(SEL)*pfVar14);
      *pfVar14 = (float)sel_count;
      pfVar14[-1] = (float)pvVar7;
      pfVar14[-2] = 1.68362e-39;
      pvVar12 = _objc_msgSend((id)pfVar14[-1],(SEL)*pfVar14);
      pfVar14[1] = (float)pvVar12;
      *pfVar14 = (float)sel_initWithCapacity_;
      pfVar14[-1] = (float)pvVar9;
      pfVar14[-2] = 1.683659e-39;
      pvVar9 = _objc_msgSend((id)pfVar14[-1],(SEL)*pfVar14);
      *pfVar14 = (float)sel_objectEnumerator;
      pfVar14[-1] = (float)pvVar7;
      pfVar14[-2] = 1.683701e-39;
      pvVar12 = _objc_msgSend((id)pfVar14[-1],(SEL)*pfVar14);
      while( true ) {
        *pfVar14 = (float)sel_nextObject;
        pfVar14[-1] = (float)pvVar12;
        pfVar14[-2] = 1.683907e-39;
        pvVar11 = _objc_msgSend((id)pfVar14[-1],(SEL)*pfVar14);
        if (pvVar11 == (id)0x0) break;
        pfVar14[3] = (float)pvVar6;
        pfVar14[2] = (float)pvVar11;
        pfVar14[1] = (float)puVar3;
        *pfVar14 = (float)sel_performSelector_withObject_withObject_;
        pfVar14[-1] = (float)self;
        pfVar14[-2] = 1.68377e-39;
        pvVar11 = _objc_msgSend((id)pfVar14[-1],(SEL)*pfVar14);
        if (pvVar11 != (id)0x0) {
          pfVar14[1] = (float)pvVar11;
          *pfVar14 = (float)sel_addObject_;
          pfVar14[-1] = (float)local_90;
          pfVar14[-2] = 1.683817e-39;
          _objc_msgSend((id)pfVar14[-1],(SEL)*pfVar14);
          *pfVar14 = (float)sel_image;
          pfVar14[-1] = (float)pvVar11;
          pfVar14[-2] = 1.683842e-39;
          pvVar11 = _objc_msgSend((id)pfVar14[-1],(SEL)*pfVar14);
          pfVar14[1] = (float)pvVar11;
          *pfVar14 = (float)sel_addObject_;
          pfVar14[-1] = (float)pvVar9;
          pfVar14[-2] = 1.683882e-39;
          _objc_msgSend((id)pfVar14[-1],(SEL)*pfVar14);
        }
      }
      *pfVar14 = (float)sel_release;
      pfVar14[-1] = (float)pvVar6;
      pfVar14[-2] = 1.683952e-39;
      _objc_msgSend((id)pfVar14[-1],(SEL)*pfVar14);
      *pfVar14 = (float)sel_release;
      pfVar14[-1] = (float)pvVar7;
      pfVar14[-2] = 1.683985e-39;
      _objc_msgSend((id)pfVar14[-1],(SEL)*pfVar14);
      *pfVar14 = (float)sel_release;
      pfVar14[-1] = (float)local_94;
      pfVar14[-2] = 1.684019e-39;
      _objc_msgSend((id)pfVar14[-1],(SEL)*pfVar14);
      pfVar14 = pfVar14 + -1;
      local_94 = pvVar9;
    }
  }
LAB_0012565c:
  if (local_90 != (id)0x0) {
    pfVar14[1] = (float)sel_count;
    *pfVar14 = (float)local_90;
    pfVar14[-1] = 1.684086e-39;
    pvVar6 = _objc_msgSend((id)*pfVar14,(SEL)pfVar14[1]);
    if ((id)0x1 < pvVar6) {
      pfVar14[1] = (float)sel_lastObject;
      *pfVar14 = (float)local_94;
      pfVar14[-1] = 1.684127e-39;
      pvVar6 = _objc_msgSend((id)*pfVar14,(SEL)pfVar14[1]);
      pfVar14[1] = (float)sel_size;
      *pfVar14 = (float)pvVar6;
      pfVar14[-1] = 1.684152e-39;
      pvVar6 = _objc_msgSend((id)*pfVar14,(SEL)pfVar14[1]);
      pfVar14[1] = (float)sel_new;
      *pfVar14 = (float)cls_NSMutableArray;
      pfVar14[-1] = 1.684202e-39;
      pvVar7 = _objc_msgSend((id)*pfVar14,(SEL)pfVar14[1]);
      pfVar14[1] = (float)sel_objectEnumerator;
      *pfVar14 = (float)local_90;
      pfVar14[-1] = 1.684239e-39;
      pvVar9 = _objc_msgSend((id)*pfVar14,(SEL)pfVar14[1]);
      while( true ) {
        pfVar14[1] = (float)sel_nextObject;
        *pfVar14 = (float)pvVar9;
        pfVar14[-1] = 1.684326e-39;
        pvVar12 = _objc_msgSend((id)*pfVar14,(SEL)pfVar14[1]);
        if (pvVar12 == (id)0x0) break;
        pfVar14[1] = (float)sel_mediaUID;
        *pfVar14 = (float)pvVar12;
        pfVar14[-1] = 1.68427e-39;
        pvVar12 = _objc_msgSend((id)*pfVar14,(SEL)pfVar14[1]);
        pfVar14[2] = (float)pvVar12;
        pfVar14[1] = (float)sel_addObject_;
        *pfVar14 = (float)pvVar7;
        pfVar14[-1] = 1.6843e-39;
        _objc_msgSend((id)*pfVar14,(SEL)pfVar14[1]);
      }
      pfVar14[1] = (float)sel_alloc;
      *pfVar14 = (float)cls_HSCelMovieObject;
      pfVar14[-1] = 1.68441e-39;
      pvVar9 = _objc_msgSend((id)*pfVar14,(SEL)pfVar14[1]);
      pfVar14[7] = (float)extraout_EDX_01;
      pfVar14[6] = (float)pvVar6;
      pfVar14[3] = (float)local_94;
      pfVar14[2] = (float)pvVar7;
      pfVar14[1] = (float)sel_initWithFramesMedia_precachedFrames_frameTimeLength_frameSize_;
      *pfVar14 = (float)pvVar9;
      pfVar14[5] = 0.0;
      pfVar14[4] = 7.00649e-44;
      pfVar14[-1] = 1.684516e-39;
      local_a0 = _objc_msgSend((id)*pfVar14,(SEL)pfVar14[1]);
      pfVar14[1] = (float)sel_release;
      *pfVar14 = (float)pvVar7;
      pfVar14[-1] = 1.68455e-39;
      _objc_msgSend((id)*pfVar14,(SEL)pfVar14[1]);
      goto LAB_001257d7;
    }
  }
  local_a0 = (id)0x0;
LAB_001257d7:
  pfVar14[1] = (float)sel_release;
  *pfVar14 = (float)local_90;
  pfVar14[-1] = 1.684584e-39;
  _objc_msgSend((id)*pfVar14,(SEL)pfVar14[1]);
  pfVar14[1] = (float)sel_release;
  *pfVar14 = (float)local_94;
  pfVar14[-1] = 1.684617e-39;
  _objc_msgSend((id)*pfVar14,(SEL)pfVar14[1]);
  pfVar14[1] = (float)sel_autorelease;
  *pfVar14 = (float)local_a0;
  pfVar14[-1] = 1.684651e-39;
  pvVar6 = _objc_msgSend((id)*pfVar14,(SEL)pfVar14[1]);
  return pvVar6;
}

*/
+ (id)celAnimationMovieWithFrameFormat:(id)aFormat firstFrame:(NSInteger)aFrame count:(NSUInteger)aCount croppingPath:(id)aPath selectedFrameSize:(NSSize)aSize
{
    NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:aCount];
    NSMutableArray *medias = [[NSMutableArray alloc] initWithCapacity:aCount];
    NSMutableArray *croppedImages;
    NSMutableArray *croppedMedias;
    NSMutableArray *mediaUIDs;
    NSImage *image = nil;
    id media;
    NSSize size;
    NSRect maxRect;
    NSRect bounds;
    NSRect integral;
    NSPoint offset;
    NSInteger frame;
    NSInteger end;
    BOOL sameSizes = YES;
    id croppingPath = aPath;
    float x;
    float y;
    NSAffineTransform *transform;
    SEL cropSelector;
    id context;
    NSEnumerator *enumerator;
    id movie = nil;
    media = [self frameMediaWithPath:[NSString stringWithFormat:aFormat, (int)aFrame] frameImage:&image];
    maxRect.origin = NSZeroRect.origin;
    maxRect.size = NSZeroRect.size;
    if (image == nil) {
        goto done;
    }
    maxRect.size = [image size];
    if (maxRect.size.width != 0.0 && maxRect.size.height != 0.0) {
        [images addObject:image];
        [medias addObject:media];
    }
    end = aCount + aFrame;
    for (frame = aFrame + 1; frame < end; frame++) {
        image = nil;
        media = [self frameMediaWithPath:[NSString stringWithFormat:aFormat, (int)frame] frameImage:&image];
        if (image == nil) {
            continue;
        }
        size = [image size];
        if (size.width == 0.0 || size.height == 0.0) {
            continue;
        }
        if (!NSEqualSizes(size, maxRect.size)) {
            maxRect.size.width = fmaxf((float)size.width, (float)maxRect.size.width);
            maxRect.size.height = fmaxf((float)size.height, (float)maxRect.size.height);
            sameSizes = NO;
        }
        [images addObject:image];
        [medias addObject:media];
    }
    if ([medias count] > 1 && !NSIsEmptyRect(maxRect)) {
        bounds.origin = NSZeroRect.origin;
        bounds.size = NSZeroRect.size;
        if (aPath != nil) {
            bounds = [aPath bounds];
        }
        if (NSIsEmptyRect(bounds)) {
            if (sameSizes) {
                goto done;
            }
            // No cropping path: crop every frame to the selected size, centred.
            bounds = NSIntegralRect(NSMakeRect((maxRect.size.width - aSize.width) * 0.5f, (maxRect.size.height - aSize.height) * 0.5f, aSize.width, aSize.height));
            croppingPath = [NSBezierPath bezierPathWithRect:bounds];
        }
        else if (!sameSizes) {
            offset = NSMakePoint((maxRect.size.width - aSize.width) * 0.5f, (maxRect.size.height - aSize.height) * 0.5f);
            if (!NSEqualPoints(NSZeroPoint, offset)) {
                integral = NSIntegralRect(NSMakeRect(offset.x, offset.y, bounds.size.width, bounds.size.height));
                transform = [NSAffineTransform transform];
                [transform translateXBy:integral.origin.x yBy:integral.origin.y];
                [aPath transformUsingAffineTransform:transform];
                bounds = [aPath bounds];
            }
        }
        x = bounds.origin.x <= 0.0 ? NSZeroPoint.x : bounds.origin.x;
        y = bounds.origin.y <= 0.0 ? NSZeroPoint.y : bounds.origin.y;
        integral = NSIntegralRect(NSMakeRect(x, y, fminf((float)bounds.size.width, (float)maxRect.size.width), fminf((float)bounds.size.height, (float)maxRect.size.height)));
        transform = [NSAffineTransform transform];
        [transform translateXBy:-x yBy:-y];
        cropSelector = sameSizes ? @selector(applyCroppingToImageMedia:context:) : @selector(applySmartCroppingToImageMedia:context:);
        context = [[HSCelAnimationFrameCroppingContext alloc] initWithCroppingPath:croppingPath originalFrameSize:maxRect.size selectedFrameSize:aSize requestedFrameRect:integral contextTransform:transform];
        croppedMedias = [[NSMutableArray alloc] initWithCapacity:[medias count]];
        croppedImages = [[NSMutableArray alloc] initWithCapacity:[medias count]];
        enumerator = [medias objectEnumerator];
        while ((media = [enumerator nextObject]) != nil) {
            media = [self performSelector:cropSelector withObject:media withObject:context];
            if (media != nil) {
                [croppedMedias addObject:media];
                [croppedImages addObject:[media image]];
            }
        }
        [context release];
        [medias release];
        [images release];
        medias = croppedMedias;
        images = croppedImages;
    }
    if (medias != nil && [medias count] > 1) {
        size = [(NSImage *)[images lastObject] size];
        mediaUIDs = [NSMutableArray new];
        enumerator = [medias objectEnumerator];
        while ((media = [enumerator nextObject]) != nil) {
            [mediaUIDs addObject:[media mediaUID]];
        }
        movie = [[HSCelMovieObject alloc] initWithFramesMedia:mediaUIDs precachedFrames:images frameTimeLength:50 frameSize:size];
        [mediaUIDs release];
    }
done:
    [medias release];
    [images release];
    return [movie autorelease];
}

+ (id)frameMediaWithPath:(id)aPath frameImage:(id *)aImage
{
    id self_00;

    self_00 = [HSNewMedia mediaWithPath:aPath];
    if ((self_00 != nil) && (aImage != NULL)) {
        *aImage = [self_00 image];
    }
    return self_00;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00125883 @ 00125883, 589 bytes * /

id FUN_00125883(id self,SEL _cmd,id movieForCelAnimationWithOptions)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id extraout_EDX;
  SEL op;
  cfstringStruct *pcVar5;
  
  if (movieForCelAnimationWithOptions != (id)0x0) {
    pvVar1 = _objc_msgSend(movieForCelAnimationWithOptions,sel_objectForKey_,&cfstr_graphicType);
    pvVar1 = _objc_msgSend(pvVar1,sel_unsignedLongValue);
    if (pvVar1 == (id)0x43454c6d) {
      pcVar5 = &cfstr_frameFormat;
      pvVar1 = _objc_msgSend(movieForCelAnimationWithOptions,sel_objectForKey_,&cfstr_frameFormat);
      if ((pvVar1 != (id)0x0) &&
         (pvVar2 = _objc_msgSend(pvVar1,sel_length,pcVar5), pvVar2 != (id)0x0)) {
        pvVar2 = _objc_msgSend(movieForCelAnimationWithOptions,sel_objectForKey_,&cfstr_isGIFSource)
        ;
        pvVar2 = _objc_msgSend(pvVar2,sel_boolValue);
        if ((char)pvVar2 == '\0') {
          pvVar2 = _objc_msgSend(movieForCelAnimationWithOptions,sel_objectForKey_,&cfstr_firstFrame
                                );
          pvVar3 = _objc_msgSend(pvVar2,sel_intValue);
          pvVar2 = _objc_msgSend(movieForCelAnimationWithOptions,sel_objectForKey_,
                                 &cfstr_framesCount);
          pvVar4 = _objc_msgSend(pvVar2,sel_intValue);
          if ((int)pvVar3 < 0) {
            return (id)0x0;
          }
          if (pvVar4 < (id)0x2) {
            return (id)0x0;
          }
          pvVar2 = _objc_msgSend(movieForCelAnimationWithOptions,sel_objectForKey_,&cfstr_frameSize)
          ;
          _objc_msgSend(pvVar2,sel_sizeValue);
          pvVar2 = _objc_msgSend(movieForCelAnimationWithOptions,sel_objectForKey_,
                                 &cfstr_cropping_path);
          op = sel_celAnimationMovieWithFrameFormat_firstFrame_count_croppingPath_selectedFrameSize_
          ;
        }
        else {
          pvVar2 = _objc_msgSend(movieForCelAnimationWithOptions,sel_objectForKey_,&cfstr_frameSize)
          ;
          pvVar4 = _objc_msgSend(pvVar2,sel_sizeValue);
          pvVar3 = _objc_msgSend(movieForCelAnimationWithOptions,sel_objectForKey_,
                                 &cfstr_cropping_path);
          op = sel_celAnimationMovieWithGIF_croppingPath_selectedFrameSize_;
          pvVar2 = extraout_EDX;
        }
        pvVar1 = _objc_msgSend(self,op,pvVar1,pvVar3,pvVar4,pvVar2);
        return pvVar1;
      }
    }
  }
  return (id)0x0;
}

*/
+ (id)movieForCelAnimationWithOptions:(id)aOptions
{
    id frameFormat;
    int firstFrame;
    int framesCount;
    if (aOptions == nil) {
        return nil;
    }
    if ([[aOptions objectForKey:@"graphicType"] unsignedLongValue] != 'CELm') {
        return nil;
    }
    frameFormat = [aOptions objectForKey:@"frameFormat"];
    if (frameFormat == nil || [frameFormat length] == 0) {
        return nil;
    }
    if ([[aOptions objectForKey:@"isGIFSource"] boolValue]) {
        return [self celAnimationMovieWithGIF:frameFormat croppingPath:[aOptions objectForKey:@"cropping path"] selectedFrameSize:[[aOptions objectForKey:@"frameSize"] sizeValue]];
    }
    firstFrame = [[aOptions objectForKey:@"firstFrame"] intValue];
    framesCount = [[aOptions objectForKey:@"framesCount"] intValue];
    if (firstFrame < 0 || (unsigned int)framesCount < 2) {
        return nil;
    }
    return [self celAnimationMovieWithFrameFormat:frameFormat firstFrame:firstFrame count:framesCount croppingPath:[aOptions objectForKey:@"cropping path"] selectedFrameSize:[[aOptions objectForKey:@"frameSize"] sizeValue]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00125ad0 @ 00125ad0, 2826 bytes * /

void FUN_00125ad0(HSAnimationSetupPickImageAssistantPane *self,SEL _cmd,id createAnimationFromImage,
                 id dialogOptions,BOOL isAnimatedGif)

{
  undefined4 uVar1;
  undefined4 uVar2;
  float fVar3;
  undefined *puVar4;
  char cVar5;
  id pvVar6;
  id pvVar7;
  id pvVar8;
  id pvVar9;
  float extraout_EDX;
  float extraout_EDX_00;
  float extraout_EDX_01;
  undefined4 *puVar10;
  undefined4 *puVar11;
  undefined4 uStack_d0;
  id local_a0;
  id local_9c;
  undefined4 local_90;
  undefined4 local_8c;
  undefined4 local_88;
  undefined4 local_84;
  undefined4 local_80;
  undefined4 local_7c;
  undefined4 local_78;
  undefined4 local_74;
  undefined4 local_70;
  undefined4 local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined4 local_54;
  undefined4 uStack_50;
  id local_4c;
  float fStack_48;
  undefined4 local_44;
  undefined4 uStack_40;
  undefined4 local_3c;
  undefined4 uStack_38;
  undefined4 local_34;
  float fStack_30;
  undefined4 local_2c;
  undefined4 uStack_28;
  undefined4 local_24;
  undefined4 uStack_20;
  undefined4 local_1c;
  float fStack_18;
  
  puVar10 = (undefined4 *)&stack0xffffff34;
  puVar11 = (undefined4 *)&stack0xffffff34;
  uStack_d0 = 0x125afa;
  pvVar6 = _objc_msgSend(cls_NSImage,sel_alloc);
  uStack_d0 = 0x125b13;
  local_9c = _objc_msgSend(pvVar6,sel_initWithContentsOfFile_);
  if (local_9c == (id)0x0) {
    uStack_d0 = 0x125b35;
    _objc_msgSend(cls_HSErrorManager,sel_sharedErrorManager);
    uStack_d0 = 0x125b5e;
    _objc_msgSend(cls_HSError,sel_fileErrorWithHSCode_filePath_);
    puVar10 = (undefined4 *)&stack0xffffff34;
    goto LAB_001265a3;
  }
  uVar1 = *(undefined4 *)PTR_00336074;
  uVar2 = *(undefined4 *)(PTR_00336074 + 4);
  uStack_d0 = 0x125bab;
  local_4c = _objc_msgSend(local_9c,sel_hyperPixelsSize);
  uStack_d0 = 0x125be5;
  local_54 = uVar1;
  uStack_50 = uVar2;
  fStack_48 = extraout_EDX;
  cVar5 = _NSIsEmptyRect();
  if (cVar5 != '\0') goto LAB_001265a8;
  local_6c = *(undefined4 *)PTR_00336088;
  local_68 = *(undefined4 *)(PTR_00336088 + 4);
  local_64 = *(undefined4 *)(PTR_00336088 + 8);
  local_60 = *(undefined4 *)(PTR_00336088 + 0xc);
  local_5c = *(undefined4 *)(PTR_00336088 + 0x10);
  local_58 = *(undefined4 *)(PTR_00336088 + 0x14);
  if (dialogOptions == (id)0x0) {
    local_a0 = (id)0x0;
  }
  else {
    uStack_d0 = 0x125c64;
    pvVar6 = _objc_msgSend(dialogOptions,sel_valueForKey_);
    uStack_d0 = 0x125c76;
    pvVar7 = _objc_msgSend(pvVar6,sel_intValue);
    uStack_d0 = 0x125c96;
    local_a0 = _objc_msgSend(dialogOptions,sel_valueForKey_);
    uStack_d0 = 0x125cb6;
    pvVar6 = _objc_msgSend(self->_animationModeController,sel_document);
    uStack_d0 = 0x125cc8;
    pvVar6 = _objc_msgSend(pvVar6,sel_stack);
    uStack_d0 = 0x125cda;
    pvVar8 = _objc_msgSend(pvVar6,sel_hyperCardSize);
    pvVar6 = local_4c;
    fVar3 = fStack_48;
    if ((local_a0 != (id)0x0) && (isAnimatedGif == '\0')) {
      uStack_d0 = 0x125d1c;
      pvVar6 = _objc_msgSend(local_a0,sel_hyperPixelsSize);
      fVar3 = extraout_EDX_01;
    }
    switch(pvVar7) {
    case (id)0x1:
      break;
    case (id)0x2:
      break;
    case (id)0x3:
      break;
    case (id)0x4:
switchD_00125d46_caseD_4:
      break;
    case (id)0x6:
      if (((float)pvVar6 <= (float)pvVar8) && (fVar3 <= extraout_EDX_00))
      goto switchD_00125d46_caseD_4;
    case (id)0x0:
    }
    uStack_d0 = 0x125e55;
    _CGAffineTransformMakeScale();
    puVar10 = &uStack_d0;
    local_6c = local_84;
    local_68 = local_80;
    local_64 = local_7c;
    local_60 = local_78;
    local_5c = local_74;
    local_58 = local_70;
  }
  puVar10[1] = sel_alloc;
  *puVar10 = cls_NSMutableDictionary;
  puVar10[-1] = 0x125eac;
  pvVar6 = _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
  puVar10[2] = (uint)(byte)isAnimatedGif;
  puVar10[1] = sel_numberWithBool_;
  *puVar10 = cls_NSNumber;
  puVar10[-1] = 0x125ed2;
  pvVar7 = _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
  puVar10[3] = fStack_48;
  puVar10[2] = local_4c;
  puVar10[1] = sel_valueWithSize_;
  *puVar10 = cls_NSValue;
  puVar10[-1] = 0x125f06;
  pvVar8 = _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
  puVar10[3] = "{CGAffineTransform=ffffff}";
  puVar10[2] = &local_6c;
  puVar10[1] = sel_valueWithBytes_objCType_;
  *puVar10 = cls_NSValue;
  puVar10[-1] = 0x125f31;
  pvVar9 = _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
  puVar10[9] = &cfstr_sourcePath;
  puVar10[8] = createAnimationFromImage;
  puVar10[7] = &cfstr_isGIFSource;
  puVar10[6] = pvVar7;
  puVar10[5] = &cfstr_frameSize;
  puVar10[4] = pvVar8;
  puVar10[3] = &cfstr_affineTransform;
  puVar10[2] = pvVar9;
  puVar10[1] = sel_initWithObjectsAndKeys_;
  *puVar10 = pvVar6;
  puVar10[10] = 0;
  puVar10[-1] = 0x125f92;
  pvVar6 = _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
  if (isAnimatedGif == '\0') {
    local_88 = 0;
    local_8c = 0xffffffff;
    local_90 = 0;
    cVar5 = '\0';
    if (dialogOptions == (id)0x0) {
      puVar10[5] = &local_90;
      puVar10[4] = &local_8c;
      puVar10[3] = &local_88;
      puVar10[2] = createAnimationFromImage;
      puVar10[1] = sel_isCelAnimationCanBeCreatedAtPath_frameFormat_firstFrame_framesCount_;
      *puVar10 = cls_HSCelMovieObject;
      puVar10[-1] = 0x126097;
      pvVar7 = _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
      cVar5 = (char)pvVar7;
    }
    if (cVar5 == '\0') {
      puVar10[2] = *(undefined4 *)PTR_PTR_003360e0;
      puVar10[1] = sel_valueForKey_;
      *puVar10 = dialogOptions;
      puVar10[-1] = 0x1263b3;
      pvVar7 = _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
      if (pvVar7 == (id)0x0) {
LAB_001263b7:
        pvVar7 = (id)0x0;
      }
      else {
        puVar10[3] = &cfstr_clipPaths;
        puVar10[2] = pvVar7;
        puVar10[1] = sel_setObject_forKey_;
        *puVar10 = pvVar6;
        puVar10[-1] = 0x1263e6;
        _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
        puVar10[1] = sel_count;
        *puVar10 = pvVar7;
        puVar10[-1] = 0x1263f8;
        pvVar8 = _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
        puVar4 = cls_NSBezierPath;
        if (pvVar8 == (id)0x0) goto LAB_001263b7;
        local_2c = 0x3f800000;
        uStack_28 = 0;
        local_24 = 0;
        uStack_20 = 0xbf800000;
        local_1c = 0;
        fStack_18 = fStack_48;
        puVar10[1] = sel_extraFirstObject;
        *puVar10 = pvVar7;
        puVar10[-1] = 0x126441;
        pvVar7 = _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
        *(ulonglong *)(puVar10 + 7) = CONCAT44(fStack_18,local_1c);
        *(ulonglong *)(puVar10 + 5) = CONCAT44(uStack_20,local_24);
        *(ulonglong *)(puVar10 + 3) = CONCAT44(uStack_28,local_2c);
        puVar10[2] = pvVar7;
        puVar10[1] = sel_hyperBezierPathWithCGPath_affineTransform_;
        *puVar10 = puVar4;
        puVar10[-1] = 0x126478;
        pvVar7 = _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
      }
      puVar10[1] = sel_numberWithUnsignedLong_;
      *puVar10 = cls_NSNumber;
      puVar10[2] = 0x20696d67;
      puVar10[-1] = 0x12649a;
      pvVar8 = _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
      puVar10[3] = &cfstr_graphicType;
      puVar10[2] = pvVar8;
      puVar10[1] = sel_setObject_forKey_;
      *puVar10 = pvVar6;
      puVar10[-1] = 0x1264c0;
      _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
      if (pvVar7 != (id)0x0) {
        if (local_a0 == (id)0x0) {
          *(ulonglong *)(puVar10 + 7) = CONCAT44(fStack_48,local_4c);
          *(ulonglong *)(puVar10 + 5) = CONCAT44(uStack_50,local_54);
          *(ulonglong *)(puVar10 + 3) = CONCAT44(fStack_48,local_4c);
          *(ulonglong *)(puVar10 + 1) = CONCAT44(uStack_50,local_54);
          puVar10[9] = pvVar7;
          *puVar10 = local_9c;
          puVar10[10] = 0;
          puVar10[-1] = 0x12650d;
          local_a0 = (id)FUN_00127731();
        }
        if ((local_a0 != (id)0x0) && (local_a0 != local_9c)) {
          puVar10[1] = sel_release;
          *puVar10 = local_9c;
          puVar10[-1] = 0x126542;
          _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
          puVar10[1] = sel_retain;
          *puVar10 = local_a0;
          puVar10[-1] = 0x12655a;
          local_9c = _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
        }
      }
    }
    else {
      puVar10[1] = sel_new;
      *puVar10 = cls_HSCropImageDialogController;
      puVar10[-1] = 0x1260b7;
      pvVar7 = _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
      puVar10[1] = sel_alloc;
      *puVar10 = cls_NSImage;
      puVar10[-1] = 0x1260d1;
      pvVar8 = _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
      puVar10[2] = createAnimationFromImage;
      puVar10[1] = sel_initWithContentsOfFile_;
      *puVar10 = pvVar8;
      puVar10[-1] = 0x1260ea;
      pvVar8 = _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
      puVar10[1] = sel_autorelease;
      *puVar10 = pvVar8;
      puVar10[-1] = 0x1260fc;
      pvVar8 = _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
      puVar10[2] = pvVar8;
      puVar10[1] = sel_setSourceNSImage_;
      *puVar10 = pvVar7;
      puVar10[-1] = 0x126112;
      _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
      puVar10[1] = sel_mainBundle;
      *puVar10 = cls_NSBundle;
      puVar10[-1] = 0x12612a;
      pvVar8 = _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
      puVar10[3] = &cfstr_empty;
      puVar10[2] = &cfstr_Crop;
      puVar10[1] = sel_localizedStringForKey_value_table_;
      *puVar10 = pvVar8;
      puVar10[4] = 0;
      puVar10[-1] = 0x126158;
      pvVar8 = _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
      puVar10[2] = pvVar8;
      puVar10[1] = sel_setOKButtonTitle_;
      *puVar10 = pvVar7;
      puVar10[-1] = 0x12616e;
      _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
      puVar10[1] = sel_sharedApplication;
      *puVar10 = cls_NSApplication;
      puVar10[-1] = 0x126186;
      pvVar8 = _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
      puVar10[1] = sel_window;
      *puVar10 = pvVar7;
      puVar10[-1] = 0x12619a;
      pvVar9 = _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
      puVar10[2] = pvVar9;
      puVar10[1] = sel_runModalForWindow_;
      *puVar10 = pvVar8;
      puVar10[-1] = 0x1261b0;
      pvVar8 = _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
      if (pvVar8 != (id)0x1) {
        puVar10[1] = sel_release;
        *puVar10 = pvVar7;
        goto LAB_0012658b;
      }
      puVar10[1] = sel_hasValidCropPath;
      *puVar10 = pvVar7;
      puVar10[-1] = 0x1261cb;
      pvVar8 = _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
      puVar4 = cls_NSBezierPath;
      if ((char)pvVar8 != '\0') {
        local_44 = 0x3f800000;
        uStack_40 = 0;
        local_3c = 0;
        uStack_38 = 0xbf800000;
        local_34 = 0;
        fStack_30 = fStack_48;
        puVar10[1] = sel_borderPath;
        *puVar10 = pvVar7;
        puVar10[-1] = 0x126218;
        pvVar8 = _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
        *(ulonglong *)(puVar10 + 7) = CONCAT44(fStack_30,local_34);
        *(ulonglong *)(puVar10 + 5) = CONCAT44(uStack_38,local_3c);
        *(ulonglong *)(puVar10 + 3) = CONCAT44(uStack_40,local_44);
        puVar10[2] = pvVar8;
        puVar10[1] = sel_hyperBezierPathWithCGPath_affineTransform_;
        *puVar10 = puVar4;
        puVar10[-1] = 0x12624f;
        pvVar8 = _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
        if (pvVar8 != (id)0x0) {
          puVar10[3] = &cfstr_cropping_path;
          puVar10[2] = pvVar8;
          puVar10[1] = sel_setObject_forKey_;
          *puVar10 = pvVar6;
          puVar10[-1] = 0x126279;
          _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
        }
      }
      puVar10[1] = sel_numberWithUnsignedLong_;
      *puVar10 = cls_NSNumber;
      puVar10[2] = 0x43454c6d;
      puVar10[-1] = 0x126299;
      pvVar8 = _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
      puVar10[3] = &cfstr_graphicType;
      puVar10[2] = pvVar8;
      puVar10[1] = sel_setObject_forKey_;
      *puVar10 = pvVar6;
      puVar10[-1] = 0x1262bf;
      _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
      puVar10[2] = local_90;
      puVar10[1] = sel_numberWithUnsignedInt_;
      *puVar10 = cls_NSNumber;
      puVar10[-1] = 0x1262e1;
      pvVar8 = _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
      puVar10[3] = &cfstr_framesCount;
      puVar10[2] = pvVar8;
      puVar10[1] = sel_setObject_forKey_;
      *puVar10 = pvVar6;
      puVar10[-1] = 0x126307;
      _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
      puVar10[2] = local_8c;
      puVar10[1] = sel_numberWithInt_;
      *puVar10 = cls_NSNumber;
      puVar10[-1] = 0x126329;
      pvVar8 = _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
      puVar10[3] = &cfstr_firstFrame;
      puVar10[2] = pvVar8;
      puVar10[1] = sel_setObject_forKey_;
      *puVar10 = pvVar6;
      puVar10[-1] = 0x12634f;
      _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
      puVar10[3] = &cfstr_frameFormat;
      puVar10[2] = local_88;
      puVar10[1] = sel_setObject_forKey_;
      *puVar10 = pvVar6;
      puVar10[-1] = 0x12637b;
      _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
      puVar10[1] = sel_release;
      *puVar10 = pvVar7;
      puVar10[-1] = 0x12638d;
      _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
    }
    pvVar7 = self->_animationModeController;
    puVar10[4] = self;
    puVar10[3] = pvVar6;
    puVar10[2] = local_9c;
    puVar10[1] = sel_runWithImage_options_fromPane_;
    *puVar10 = pvVar7;
  }
  else {
    puVar10[1] = sel_numberWithUnsignedLong_;
    *puVar10 = cls_NSNumber;
    puVar10[2] = 0x43454c6d;
    puVar10[-1] = 0x125fc2;
    pvVar7 = _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
    puVar10[3] = &cfstr_graphicType;
    puVar10[2] = pvVar7;
    puVar10[1] = sel_setObject_forKey_;
    *puVar10 = pvVar6;
    puVar10[-1] = 0x125fe8;
    _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
    puVar10[3] = &cfstr_frameFormat;
    puVar10[2] = createAnimationFromImage;
    puVar10[1] = sel_setObject_forKey_;
    *puVar10 = pvVar6;
    puVar10[-1] = 0x12600b;
    _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
    pvVar7 = self->_animationModeController;
    puVar10[4] = self;
    puVar10[2] = pvVar6;
    puVar10[1] = sel_createCelAnimationWithOptions_croppingPath_assistantPane_;
    *puVar10 = pvVar7;
    puVar10[3] = 0;
  }
LAB_0012658b:
  puVar10[-1] = 0x126590;
  _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
  puVar10[1] = sel_release;
  *puVar10 = pvVar6;
LAB_001265a3:
  puVar10[-1] = 0x1265a8;
  _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
  puVar11 = puVar10;
LAB_001265a8:
  puVar11[1] = sel_release;
  *puVar11 = local_9c;
  puVar11[-1] = 0x1265c0;
  _objc_msgSend((id)*puVar11,(SEL)puVar11[1]);
  return;
}

*/
- (void)createAnimationFromImage:(id)aImage dialogOptions:(id)aOptions isAnimatedGif:(BOOL)aGif
{
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:aImage];
    NSSize pixelsSize;
    CGAffineTransform transform;
    int layout;
    NSImage *croppedImage;
    NSSize cardSize;
    NSSize sourceSize;
    NSSize targetSize;
    float cardRatio;
    float imageRatio;
    NSMutableDictionary *options;
    id frameFormat = nil;
    int firstFrame = -1;
    unsigned int framesCount = 0;
    BOOL isCelAnimation;
    id cropController;
    id clipPaths;
    id path;
    if (image == nil) {
        [[HSErrorManager sharedErrorManager] presentError:[HSError fileErrorWithHSCode:0x103 filePath:aImage]];
        return;
    }
    pixelsSize = [image hyperPixelsSize];
    if (NSIsEmptyRect(NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, pixelsSize.width, pixelsSize.height))) {
        [image release];
        return;
    }
    transform = CGAffineTransformIdentity;
    if (aOptions == nil) {
        croppedImage = nil;
    }
    else {
        layout = [[aOptions valueForKey:HSImportDialogGraphicsOptionKeyLayout] intValue];
        croppedImage = [aOptions valueForKey:HSImportDialogGraphicsOptionKeyCroppedImage];
        cardSize = [[[_animationModeController document] stack] hyperCardSize];
        sourceSize = (croppedImage != nil && !aGif) ? [croppedImage hyperPixelsSize] : pixelsSize;
        targetSize = NSZeroRect.size;
        cardRatio = cardSize.width / cardSize.height;
        imageRatio = sourceSize.width / sourceSize.height;
        switch (layout) {
        case 6:
            // Shrink to fit only when larger than the card.
            if (!(sourceSize.width > cardSize.width) && !(sourceSize.height > cardSize.height)) {
                targetSize = sourceSize;
                break;
            }
        case 0:
            if (imageRatio > cardRatio) {
                targetSize = NSMakeSize(cardSize.width, cardSize.width / imageRatio);
            }
            else {
                targetSize = NSMakeSize(imageRatio * cardSize.height, cardSize.height);
            }
            break;
        case 1:
            if (imageRatio > cardRatio) {
                cardSize.height = cardSize.width / imageRatio;
            }
            else {
                cardSize.width = imageRatio * cardSize.height;
            }
            targetSize = NSMakeSize(cardSize.width * 0.57735026f, cardSize.height * 0.57735026f);
            break;
        case 2:
            if (cardRatio > imageRatio) {
                targetSize = NSMakeSize(cardSize.width, cardSize.width / imageRatio);
            }
            else {
                targetSize = NSMakeSize(imageRatio * cardSize.height, cardSize.height);
            }
            break;
        case 3:
            targetSize = cardSize;
            break;
        case 4:
            targetSize = sourceSize;
            break;
        default:
            break;
        }
        transform = CGAffineTransformMakeScale(targetSize.width / sourceSize.width, targetSize.height / sourceSize.height);
    }
    options = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)], @"affineTransform", [NSValue valueWithSize:pixelsSize], @"frameSize", [NSNumber numberWithBool:aGif], @"isGIFSource", aImage, @"sourcePath", nil];
    if (aGif) {
        [options setObject:[NSNumber numberWithUnsignedLong:'CELm'] forKey:@"graphicType"];
        [options setObject:aImage forKey:@"frameFormat"];
        [_animationModeController createCelAnimationWithOptions:options croppingPath:NULL assistantPane:self];
    }
    else {
        isCelAnimation = NO;
        if (aOptions == nil) {
            isCelAnimation = [HSCelMovieObject isCelAnimationCanBeCreatedAtPath:aImage frameFormat:&frameFormat firstFrame:&firstFrame framesCount:&framesCount];
        }
        if (isCelAnimation) {
            // A numbered image sequence: let the user crop the frames first.
            cropController = [HSCropImageDialogController new];
            [cropController setSourceNSImage:[[[NSImage alloc] initWithContentsOfFile:aImage] autorelease]];
            [cropController setOKButtonTitle:[[NSBundle mainBundle] localizedStringForKey:@"Crop" value:@"" table:nil]];
            if ([NSApp runModalForWindow:[cropController window]] != NSModalResponseOK) {
                [cropController release];
                [options release];
                [image release];
                return;
            }
            if ([cropController hasValidCropPath]) {
                path = [NSBezierPath hyperBezierPathWithCGPath:(struct CGPath *)[cropController borderPath] affineTransform:CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, pixelsSize.height)];
                if (path != nil) {
                    [options setObject:path forKey:@"cropping path"];
                }
            }
            [options setObject:[NSNumber numberWithUnsignedLong:'CELm'] forKey:@"graphicType"];
            [options setObject:[NSNumber numberWithUnsignedInt:framesCount] forKey:@"framesCount"];
            [options setObject:[NSNumber numberWithInt:firstFrame] forKey:@"firstFrame"];
            [options setObject:frameFormat forKey:@"frameFormat"];
            [cropController release];
        }
        else {
            clipPaths = [aOptions valueForKey:HSImportDialogGraphicsOptionKeyClipPaths];
            path = nil;
            if (clipPaths != nil) {
                [options setObject:clipPaths forKey:@"clipPaths"];
                if ([clipPaths count] != 0) {
                    path = [NSBezierPath hyperBezierPathWithCGPath:(struct CGPath *)[clipPaths extraFirstObject] affineTransform:CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, pixelsSize.height)];
                }
            }
            [options setObject:[NSNumber numberWithUnsignedLong:'img '] forKey:@"graphicType"];
            if (path != nil) {
                if (croppedImage == nil) {
                    croppedImage = HSCelAnimationCroppedImage(image, NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, pixelsSize.width, pixelsSize.height), NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, pixelsSize.width, pixelsSize.height), path, nil);
                }
                if (croppedImage != nil && croppedImage != image) {
                    [image release];
                    image = [croppedImage retain];
                }
            }
        }
        [_animationModeController runWithImage:image options:options fromPane:self];
    }
    [options release];
    [image release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001265f8 @ 001265f8, 520 bytes * /

void FUN_001265f8(HSAnimationSetupPickImageAssistantPane *self,SEL _cmd,
                 id selectMovieObjectFromDialog,int returnCode,void *contextInfo)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  id pvVar3;
  SEL op;
  id *ppvVar4;
  id local_14;
  
  if (returnCode == 1) {
    pvVar1 = _objc_msgSend(selectMovieObjectFromDialog,sel_fileName);
    pvVar2 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
    pvVar2 = _objc_msgSend(pvVar2,sel_hyperFileTypeAtPath_,pvVar1);
    self_00 = _objc_msgSend(cls_HSNewMediaAccessor,sel_fullPathForMediaPath_mediaType_,pvVar1,pvVar2
                           );
    if (self_00 != (id)0x0) {
      pvVar1 = _objc_msgSend(cls_NSFileManager,sel_defaultManager,pvVar1,pvVar2);
      pvVar1 = _objc_msgSend(pvVar1,sel_hyperFileTypeAtPath_,self_00);
      if (pvVar1 != (id)0x0) {
        pvVar1 = _objc_msgSend(cls_HSMovieObject,sel_isMediaTypeSupported_,pvVar1,pvVar2);
        if ((char)pvVar1 != '\0') {
          pvVar1 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_,self_00,pvVar2);
          if (pvVar1 != (id)0x0) {
            local_14 = (id)0x0;
            ppvVar4 = &local_14;
            pvVar2 = _objc_msgSend(cls_HSMovie,sel_movieWithURL_error_,pvVar1,ppvVar4);
            if (pvVar2 == (id)0x0) {
              self = _objc_msgSend(cls_HSErrorManager,sel_sharedErrorManager,pvVar1,ppvVar4);
              op = sel_presentError_;
              pvVar2 = local_14;
            }
            else {
              pvVar3 = _objc_msgSend(pvVar2,sel_isGifMovie,pvVar1,ppvVar4);
              if ((char)pvVar3 == '\0') {
                self = self->_delegate;
                pvVar1 = _objc_msgSend(self_00,sel_lastPathComponent,pvVar1,ppvVar4);
                ppvVar4 = _objc_msgSend(pvVar1,sel_stringByDeletingPathExtension);
                op = sel_pickMovie_name_forPickImageAssistantPane_;
              }
              else {
                _objc_msgSend(pvVar2,sel_hasMultiplySamples,pvVar1,ppvVar4);
                ppvVar4 = (id *)0x0;
                op = sel_createAnimationFromImage_dialogOptions_isAnimatedGif_;
                pvVar2 = self_00;
              }
            }
            _objc_msgSend(self,op,pvVar2,ppvVar4);
          }
        }
      }
    }
  }
  return;
}

*/
- (void)selectMovieObjectFromDialog:(id)aDialog returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    id fileName;
    id fullPath;
    id type;
    NSURL *url;
    NSError *error = nil;
    id movie;
    if (aCode != 1) {
        return;
    }
    fileName = [aDialog fileName];
    fullPath = [HSNewMediaAccessor fullPathForMediaPath:fileName mediaType:[[NSFileManager defaultManager] hyperFileTypeAtPath:fileName]];
    if (fullPath == nil) {
        return;
    }
    type = [[NSFileManager defaultManager] hyperFileTypeAtPath:fullPath];
    if (type == nil || ![HSMovieObject isMediaTypeSupported:type]) {
        return;
    }
    url = [NSURL fileURLWithPath:fullPath];
    if (url == nil) {
        return;
    }
    movie = [HSMovie movieWithURL:url error:&error];
    if (movie == nil) {
        [[HSErrorManager sharedErrorManager] presentError:error];
    }
    else if ([movie isGifMovie]) {
        [self createAnimationFromImage:fullPath dialogOptions:nil isAnimatedGif:[movie hasMultiplySamples]];
    }
    else {
        [_delegate pickMovie:movie name:[[fullPath lastPathComponent] stringByDeletingPathExtension] forPickImageAssistantPane:self];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00126800 @ 00126800, 311 bytes * /

void FUN_00126800(HSAnimationSetupPickImageAssistantPane *self,SEL _cmd,
                 id selectGraphicObjectFromDialog,int returnCode,void *contextInfo)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  char cVar4;
  undefined4 uVar5;
  
  if (returnCode != 1) {
    return;
  }
  pvVar1 = _objc_msgSend(selectGraphicObjectFromDialog,sel_fileName);
  if (pvVar1 == (id)0x0) {
    return;
  }
  pvVar2 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
  pvVar2 = _objc_msgSend(pvVar2,sel_hyperFileTypeAtPath_,pvVar1);
  if (pvVar2 == (id)0x0) {
    return;
  }
  pvVar2 = _objc_msgSend(cls_HSImageObject,sel_isMediaTypeSupported_,pvVar2);
  if ((char)pvVar2 != '\0') {
    pvVar2 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_,pvVar1);
    if (pvVar2 != (id)0x0) {
      uVar5 = 0;
      pvVar3 = _objc_msgSend(cls_HSMovie,sel_movieWithURL_error_,pvVar2,0);
      if ((pvVar3 == (id)0x0) ||
         (pvVar3 = _objc_msgSend(pvVar3,sel_isAnimatedGifMovie,pvVar2,uVar5), (char)pvVar3 == '\0'))
      {
        cVar4 = '\0';
      }
      else {
        cVar4 = '\x01';
      }
      pvVar2 = _objc_msgSend(selectGraphicObjectFromDialog,sel_dialogUserOptions,pvVar2,uVar5);
      _objc_msgSend(self,sel_createAnimationFromImage_dialogOptions_isAnimatedGif_,pvVar1,pvVar2,
                    (int)cVar4);
      return;
    }
    return;
  }
  return;
}

*/
- (void)selectGraphicObjectFromDialog:(id)aDialog returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    id fileName;
    id type;
    NSURL *url;
    id movie;
    BOOL isAnimatedGif;
    if (aCode != 1) {
        return;
    }
    fileName = [aDialog fileName];
    if (fileName == nil) {
        return;
    }
    type = [[NSFileManager defaultManager] hyperFileTypeAtPath:fileName];
    if (type == nil || ![HSImageObject isMediaTypeSupported:type]) {
        return;
    }
    url = [NSURL fileURLWithPath:fileName];
    if (url == nil) {
        return;
    }
    movie = [HSMovie movieWithURL:url error:NULL];
    isAnimatedGif = movie != nil && [movie isAnimatedGifMovie];
    [self createAnimationFromImage:fileName dialogOptions:[aDialog dialogUserOptions] isAnimatedGif:isAnimatedGif];
}

- (void)setTolerance:(CGFloat)aTolerance
{
    _tolerance = aTolerance;
}

- (CGFloat)tolerance
{
    return _tolerance;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00126937 @ 00126937, 206 bytes * /

id FUN_00126937(HSAnimationSetupPickImageAssistantPane *self,SEL _cmd)

{
  undefined *puVar1;
  id pvVar2;
  undefined *self_00;
  SEL op;
  cfstringStruct *pcVar3;
  
  pvVar2 = _objc_msgSend(self,sel_assistant);
  pvVar2 = _objc_msgSend(pvVar2,sel_object);
  pcVar3 = (cfstringStruct *)&DAT_00372234;
  pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_00372234);
  puVar1 = cls_NSString;
  self_00 = cls_HSPlayAnimationAction;
  op = sel_localizedNameInInspector;
  if (pvVar2 != (id)0x0) {
    _objc_msgSend(cls_HSPlayAnimationAction,sel_localizedNameInInspector,pcVar3);
    _objc_msgSend(pvVar2,sel_hyperName);
    pcVar3 = &cfstr________;
    self_00 = puVar1;
    op = sel_stringWithFormat_;
  }
  pvVar2 = _objc_msgSend(self_00,op,pcVar3);
  return pvVar2;
}

*/
- (id)windowTitle
{
    id object = [[[self assistant] object] queryHyperInterface:@protocol(HSObjectAttributes)];
    if (object == nil) {
        return [HSPlayAnimationAction localizedNameInInspector];
    }
    return [NSString stringWithFormat:@"%@ : %@", [HSPlayAnimationAction localizedNameInInspector], [object hyperName]];
}

- (id)helpTopicKey
{
    return @"HSPlayAnimation";
}

- (void)paneWillGoBack:(id)aBack
{
    [_delegate cancelFromPickImageAssistantPane:self];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00126a32 @ 00126a32, 628 bytes * /

id FUN_00126a32(HSAnimationSetupPickImageAssistantPane *self,SEL _cmd,
               id findFileForCelAnimationForPath)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  char *pcVar6;
  undefined4 *puVar7;
  undefined4 *puVar8;
  undefined4 *puVar9;
  id local_28;
  undefined4 local_20;
  undefined4 local_1c;
  undefined4 local_18;
  char local_11;
  
  pvVar1 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
  local_11 = '\0';
  pcVar6 = &local_11;
  pvVar5 = findFileForCelAnimationForPath;
  pvVar2 = _objc_msgSend(pvVar1,sel_fileExistsAtPath_isDirectory_,findFileForCelAnimationForPath,
                         pcVar6);
  if ((char)pvVar2 != '\0') {
    if (local_11 != '\0') {
      pvVar5 = findFileForCelAnimationForPath;
      pvVar2 = _objc_msgSend(pvVar1,sel_directoryContentsAtPath_,findFileForCelAnimationForPath,
                             pcVar6);
      local_28 = (id)0x0;
      pvVar2 = _objc_msgSend(pvVar2,sel_objectEnumerator);
      do {
        do {
          pvVar5 = _objc_msgSend(pvVar2,sel_nextObject,pvVar5,pcVar6);
          if (pvVar5 == (id)0x0) {
            return local_28;
          }
          pvVar3 = _objc_msgSend(findFileForCelAnimationForPath,sel_stringByAppendingPathComponent_,
                                 pvVar5,pcVar6);
          pvVar5 = pvVar3;
          pvVar4 = _objc_msgSend(pvVar1,sel_hyperIsFileInvisibleAtPath_,pvVar3);
        } while ((char)pvVar4 != '\0');
        pcVar6 = &local_11;
        pvVar5 = pvVar3;
        pvVar4 = _objc_msgSend(pvVar1,sel_fileExistsAtPath_isDirectory_,pvVar3,pcVar6);
      } while ((((char)pvVar4 != '\0') && (local_11 != '\0')) ||
              (local_28 = _objc_msgSend(self,sel_findFileForCelAnimationForPath_,pvVar3,pcVar6),
              pvVar5 = pvVar3, local_28 == (id)0x0));
      return local_28;
    }
    if (findFileForCelAnimationForPath != (id)0x0) {
      pvVar5 = _objc_msgSend(cls_NSFileManager,sel_defaultManager,pvVar5,pcVar6);
      pvVar5 = _objc_msgSend(pvVar5,sel_hyperFileTypeAtPath_,findFileForCelAnimationForPath);
      if (((pvVar5 != (id)0x0) &&
          (pvVar5 = _objc_msgSend(cls_HSImageObject,sel_isMediaTypeSupported_,pvVar5,pcVar6),
          (char)pvVar5 != '\0')) &&
         (pvVar5 = findFileForCelAnimationForPath,
         pvVar1 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_,findFileForCelAnimationForPath,pcVar6
                               ), pvVar1 != (id)0x0)) {
        local_18 = 0;
        local_1c = 0xffffffff;
        local_20 = 0;
        pvVar5 = _objc_msgSend(cls_NSImage,sel_alloc,pvVar5);
        pvVar5 = _objc_msgSend(pvVar5,sel_initWithContentsOfFile_,findFileForCelAnimationForPath);
        if (pvVar5 != (id)0x0) {
          puVar9 = &local_20;
          puVar8 = &local_1c;
          puVar7 = &local_18;
          pvVar2 = findFileForCelAnimationForPath;
          pvVar3 = _objc_msgSend(cls_HSCelMovieObject,
                                 sel_isCelAnimationCanBeCreatedAtPath_frameFormat_firstFrame_framesCount_
                                 ,findFileForCelAnimationForPath,puVar7,puVar8,puVar9);
          pvVar1 = (id)0x0;
          if ((char)pvVar3 != '\0') {
            pvVar1 = findFileForCelAnimationForPath;
          }
          _objc_msgSend(pvVar5,sel_release,pvVar2,puVar7,puVar8,puVar9);
          return pvVar1;
        }
      }
    }
  }
  return (id)0x0;
}

*/
- (id)findFileForCelAnimationForPath:(id)aPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    NSEnumerator *enumerator;
    id name;
    id subpath;
    id found;
    id type;
    NSImage *image;
    id frameFormat = nil;
    int firstFrame = -1;
    unsigned int framesCount = 0;
    BOOL canCreate;
    if (![fileManager fileExistsAtPath:aPath isDirectory:&isDirectory]) {
        return nil;
    }
    if (isDirectory) {
        // Depth-first search for the first image that starts a numbered sequence.
        found = nil;
        // -directoryContentsAtPath: in the original.
        enumerator = [[fileManager contentsOfDirectoryAtPath:aPath error:NULL] objectEnumerator];
        while ((name = [enumerator nextObject]) != nil) {
            subpath = [aPath stringByAppendingPathComponent:name];
            if ([fileManager hyperIsFileInvisibleAtPath:subpath]) {
                continue;
            }
            if ([fileManager fileExistsAtPath:subpath isDirectory:&isDirectory] && isDirectory) {
                continue;
            }
            found = [self findFileForCelAnimationForPath:subpath];
            if (found != nil) {
                return found;
            }
        }
        return found;
    }
    if (aPath == nil) {
        return nil;
    }
    type = [[NSFileManager defaultManager] hyperFileTypeAtPath:aPath];
    if (type == nil || ![HSImageObject isMediaTypeSupported:type] || [NSURL fileURLWithPath:aPath] == nil) {
        return nil;
    }
    image = [[NSImage alloc] initWithContentsOfFile:aPath];
    if (image == nil) {
        return nil;
    }
    canCreate = [HSCelMovieObject isCelAnimationCanBeCreatedAtPath:aPath frameFormat:&frameFormat firstFrame:&firstFrame framesCount:&framesCount];
    [image release];
    return canCreate ? aPath : nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00126ca6 @ 00126ca6, 1889 bytes * /

void FUN_00126ca6(HSAnimationSetupPickImageAssistantPane *self,SEL _cmd,id proceed)

{
  undefined *puVar1;
  undefined *self_00;
  id pvVar2;
  HSAnimationSetupPickImageAssistantPane *pHVar3;
  cfstringStruct *pcVar4;
  id pvVar5;
  id pvVar6;
  HSAnimationSetupPickImageAssistantPane *pHVar7;
  double dVar8;
  SEL op;
  id pvVar9;
  undefined4 uVar10;
  cfstringStruct *pcVar11;
  
  if (self->_paneOpenedAsModalViewController != '\0') {
    _objc_msgSend(self->_animationModeController,sel_noteShouldDismissModalViewControllerOnFinish);
  }
  self->_paneOpenedAsModalViewController = '\0';
  _objc_msgSend(self->_delegate,sel_hideAnimationObjectForAssistantPane_,self);
  pvVar2 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
  uVar10 = 0;
  pvVar9 = (id)0x1;
  _objc_msgSend(pvVar2,sel_setActive_explicitlyByUser_,1,0);
  if ((self->_selectPartOfCardButton == proceed) || (self->_selectPartOfCardTextButton == proceed))
  {
    pvVar9 = _objc_msgSend(cls_HSAnimationSetupPickPartOfCardAssistantPane,sel_alloc,pvVar9,uVar10);
    puVar1 = cls_NSMutableDictionary;
    pvVar2 = _objc_msgSend(cls_NSNumber,sel_numberWithUnsignedLong_,0x20696d67);
    pvVar2 = _objc_msgSend(puVar1,sel_dictionaryWithObjectsAndKeys_,pvVar2,&cfstr_graphicType,0);
    pHVar3 = _objc_msgSend(pvVar9,sel_initWithOptions_,pvVar2);
    _objc_msgSend(pHVar3,sel_setDelegate_,self->_animationModeController);
    pvVar9 = _objc_msgSend(self,sel_objectAssistantNavigationController);
    pcVar4 = *(cfstringStruct **)PTR_PTR_003364f0;
    pcVar11 = (cfstringStruct *)0x1;
    pHVar7 = pHVar3;
    _objc_msgSend(pvVar9,sel_pushViewController_withIdentifier_animate_replacePrevious_,pHVar3,
                  pcVar4,1,0);
    op = sel_release;
  }
  else {
    pHVar3 = self;
    if ((self->_selectGraphicButton == proceed) || (self->_selectGraphicTextButton == proceed)) {
      pvVar2 = self->_importGraphicDialogController;
      if (pvVar2 == (id)0x0) {
        pvVar9 = _objc_msgSend(cls_HSImportDialogController,sel_alloc,pvVar9,uVar10);
        pvVar9 = _objc_msgSend(pvVar9,sel_initWithDialogType_,*(undefined4 *)PTR_PTR_003360d8);
        self->_importGraphicDialogController = pvVar9;
        puVar1 = cls_NSDictionary;
        pvVar2 = _objc_msgSend(cls_NSNumber,sel_numberWithInt_,4);
        pvVar2 = _objc_msgSend(puVar1,sel_dictionaryWithObjectsAndKeys_,pvVar2,
                               *(undefined4 *)PTR_PTR_00336598,0);
        _objc_msgSend(pvVar9,sel_setupDialogInterfaceWithOptions_,pvVar2);
        self_00 = cls_NSNumber;
        puVar1 = cls_NSDictionary;
        pvVar9 = self->_importGraphicDialogController;
        dVar8 = _objc_msgSend_fpret(self,sel_tolerance);
        pvVar2 = _objc_msgSend(self_00,sel_numberWithFloat_,(float)dVar8);
        uVar10 = *(undefined4 *)PTR_PTR_003360f8;
        pvVar2 = _objc_msgSend(puVar1,sel_dictionaryWithObject_forKey_,pvVar2,uVar10);
        _objc_msgSend(pvVar9,sel_setOptions_,pvVar2);
        pvVar2 = self->_importGraphicDialogController;
        pvVar9 = _objc_msgSend(self->_animationModeController,sel_document);
        _objc_msgSend(pvVar2,sel_setHyperDocument_,pvVar9);
        pvVar2 = self->_importGraphicDialogController;
      }
      puVar1 = cls_HSImportDialogController;
      pvVar9 = _objc_msgSend(self,sel_assistant,pvVar9,uVar10);
      pvVar9 = _objc_msgSend(pvVar9,sel_object);
      pvVar9 = _objc_msgSend(puVar1,sel_defaultButtonTitleForObject_,pvVar9);
      _objc_msgSend(pvVar2,sel_setDefaultButtonTitle_,pvVar9);
      pcVar4 = _objc_msgSend(self->_importGraphicDialogController,sel_runModal);
      pHVar7 = self->_importGraphicDialogController;
      op = sel_selectGraphicObjectFromDialog_returnCode_contextInfo_;
    }
    else {
      if ((self->_selectSequenceButton == proceed) || (self->_selectSequenceTextButton == proceed))
      {
        pvVar9 = _objc_msgSend(cls_NSOpenPanel,sel_openPanel,pvVar9,uVar10);
        _objc_msgSend(pvVar9,sel_setCanChooseDirectories_,1);
        _objc_msgSend(pvVar9,sel_setAllowsMultipleSelection_,0);
        pvVar2 = _objc_msgSend(cls_NSImage,sel_imageFileTypes);
        pvVar5 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider);
        pvVar5 = _objc_msgSend(pvVar5,sel_imageSequencesFolder);
        uVar10 = 0;
        pvVar6 = _objc_msgSend(pvVar9,sel_runModalForDirectory_file_types_,pvVar5,0,pvVar2);
        if (pvVar6 != (id)0x1) {
          return;
        }
        pvVar9 = _objc_msgSend(pvVar9,sel_filenames,pvVar5,uVar10,pvVar2);
        pvVar9 = _objc_msgSend(pvVar9,sel_lastObject);
        pvVar2 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider);
        _objc_msgSend(pvVar2,sel_setImageSequencesFolder_,pvVar9);
        pHVar7 = _objc_msgSend(self,sel_findFileForCelAnimationForPath_,pvVar9);
        if (pHVar7 == (HSAnimationSetupPickImageAssistantPane *)0x0) {
          pvVar9 = _objc_msgSend(cls_HSAlert,sel_new,pvVar9);
          pHVar3 = _objc_msgSend(pvVar9,sel_autorelease);
          _objc_msgSend(pHVar3,sel_setAlertStyle_,5);
          pvVar9 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
          pvVar9 = _objc_msgSend(pvVar9,sel_localizedStringForKey_value_table_,
                                 &cfstr_There_are_no_images_to_animate,&cfstr_empty,&cfstr_Alerts);
          _objc_msgSend(pHVar3,sel_setMessageText_,pvVar9);
          pvVar9 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
          pcVar11 = &cfstr_Alerts;
          pcVar4 = &cfstr_empty;
          pHVar7 = _objc_msgSend(pvVar9,sel_localizedStringForKey_value_table_,
                                 &cfstr_The_folder_you_have_chosen_does_not_contain_imag,
                                 &cfstr_empty,&cfstr_Alerts);
          _objc_msgSend(pHVar3,sel_setInformativeText_,pHVar7);
          op = sel_runModal;
        }
        else {
          pcVar11 = (cfstringStruct *)0x0;
          pcVar4 = (cfstringStruct *)0x0;
          op = sel_createAnimationFromImage_dialogOptions_isAnimatedGif_;
        }
        goto LAB_0012705a;
      }
      if ((self->_selectMovieButton != proceed) && (self->_selectMovieTextButton != proceed)) {
        return;
      }
      pvVar2 = self->_importMovieDialogController;
      if (pvVar2 == (id)0x0) {
        pvVar2 = _objc_msgSend(cls_HSImportDialogController,sel_alloc,pvVar9,uVar10);
        pvVar9 = *(id *)PTR_PTR_003360cc;
        pvVar2 = _objc_msgSend(pvVar2,sel_initWithDialogType_,pvVar9);
        self->_importMovieDialogController = pvVar2;
      }
      pvVar9 = _objc_msgSend(self->_animationModeController,sel_document,pvVar9,uVar10);
      _objc_msgSend(pvVar2,sel_setHyperDocument_,pvVar9);
      puVar1 = cls_HSImportDialogController;
      pvVar9 = self->_importMovieDialogController;
      pvVar2 = _objc_msgSend(self,sel_assistant);
      pvVar2 = _objc_msgSend(pvVar2,sel_object);
      pvVar2 = _objc_msgSend(puVar1,sel_defaultButtonTitleForObject_,pvVar2);
      _objc_msgSend(pvVar9,sel_setDefaultButtonTitle_,pvVar2);
      pcVar4 = _objc_msgSend(self->_importMovieDialogController,sel_runModal);
      pHVar7 = self->_importMovieDialogController;
      op = sel_selectMovieObjectFromDialog_returnCode_contextInfo_;
    }
    pcVar11 = (cfstringStruct *)0x0;
  }
LAB_0012705a:
  _objc_msgSend(pHVar3,op,pHVar7,pcVar4,pcVar11);
  return;
}

*/
- (void)proceed:(id)aProceed
{
    id pane;
    NSOpenPanel *panel;
    id folder;
    id file;
    HSAlert *alert;
    if (_paneOpenedAsModalViewController) {
        [_animationModeController noteShouldDismissModalViewControllerOnFinish];
    }
    _paneOpenedAsModalViewController = NO;
    [_delegate hideAnimationObjectForAssistantPane:self];
    [[HSObjectAssistantController sharedAssistantController] setActive:YES explicitlyByUser:NO];
    if (_selectPartOfCardButton == aProceed || _selectPartOfCardTextButton == aProceed) {
        pane = [[HSAnimationSetupPickPartOfCardAssistantPane alloc] initWithOptions:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedLong:'img '], @"graphicType", nil]];
        [pane setDelegate:_animationModeController];
        [[self objectAssistantNavigationController] pushViewController:pane withIdentifier:HSAnimationModePane animate:YES replacePrevious:NO];
        [pane release];
    }
    else if (_selectGraphicButton == aProceed || _selectGraphicTextButton == aProceed) {
        if (_importGraphicDialogController == nil) {
            _importGraphicDialogController = [[HSImportDialogController alloc] initWithDialogType:HSImportDialogControllerTypeGraphicObject];
            [_importGraphicDialogController setupDialogInterfaceWithOptions:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:4], HSImportDialogGraphicsObjectLayout, nil]];
            [_importGraphicDialogController setOptions:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:(float)[self tolerance]] forKey:@"selectionTolerance"]];
            [_importGraphicDialogController setHyperDocument:[_animationModeController document]];
        }
        [_importGraphicDialogController setDefaultButtonTitle:[HSImportDialogController defaultButtonTitleForObject:[[self assistant] object]]];
        [self selectGraphicObjectFromDialog:_importGraphicDialogController returnCode:[_importGraphicDialogController runModal] contextInfo:NULL];
    }
    else if (_selectSequenceButton == aProceed || _selectSequenceTextButton == aProceed) {
        panel = [NSOpenPanel openPanel];
        [panel setCanChooseDirectories:YES];
        [panel setAllowsMultipleSelection:NO];
        if ([panel runModalForDirectory:[[HSPathsProvider sharedPathsProvider] imageSequencesFolder] file:nil types:[NSImage imageFileTypes]] != NSModalResponseOK) {
            return;
        }
        folder = [[panel filenames] lastObject];
        [[HSPathsProvider sharedPathsProvider] setImageSequencesFolder:folder];
        file = [self findFileForCelAnimationForPath:folder];
        if (file != nil) {
            [self createAnimationFromImage:file dialogOptions:nil isAnimatedGif:NO];
        }
        else {
            alert = [[HSAlert new] autorelease];
            [alert setAlertStyle:5];
            [alert setMessageText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"There are no images to animate" value:@"" table:@"Alerts"]];
            [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"The folder you have chosen does not contain images or contains one image only. To create a cel animation, you need to choose a folder containing multiple images. Choose another folder and try again." value:@"" table:@"Alerts"]];
            [alert runModal];
        }
    }
    else if (_selectMovieButton == aProceed || _selectMovieTextButton == aProceed) {
        if (_importMovieDialogController == nil) {
            _importMovieDialogController = [[HSImportDialogController alloc] initWithDialogType:HSImportDialogControllerTypeAnimations];
        }
        [_importMovieDialogController setHyperDocument:[_animationModeController document]];
        [_importMovieDialogController setDefaultButtonTitle:[HSImportDialogController defaultButtonTitleForObject:[[self assistant] object]]];
        [self selectMovieObjectFromDialog:_importMovieDialogController returnCode:[_importMovieDialogController runModal] contextInfo:NULL];
    }
}

- (void)notePaneOpenedAsModalViewController
{
    _paneOpenedAsModalViewController = YES;
}

- (void)setAnimationModeController:(id)aController
{
    _animationModeController = aController;
}

- (id)animationModeController
{
    return _animationModeController;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (void)viewDidLoad
{
    id pvVar1;

    [super viewDidLoad];
    pvVar1 = [HSAssistantButtonBackgroundRenderer sharedBackgroundRenderer];
    [[_selectPartOfCardButton cell] setBackgroundRenderer:pvVar1];
    [[_selectGraphicButton cell] setBackgroundRenderer:pvVar1];
    [[_selectSequenceButton cell] setBackgroundRenderer:pvVar1];
    [[_selectMovieButton cell] setBackgroundRenderer:pvVar1];
}

- (id)navigationPaneSwitcher
{
    HSObjectAssistantNavigationPaneSwitcher *pHVar1;
    HSObjectAssistantNavigationPaneSwitcher *pHVar1_2;

    pHVar1 = _navigationPaneSwitcher;
    if (pHVar1 == nil) {
        pHVar1_2 = [HSNavigationPaneSwitcherWithCancelButton new];
        _navigationPaneSwitcher = pHVar1_2;
        [pHVar1_2 setDelegate:self];
        pHVar1 = _navigationPaneSwitcher;
    }
    return pHVar1;
}

- (BOOL)requiresDarkBottomArea
{
    return YES;
}

- (void)dealloc
{
    [_importGraphicDialogController release];
    [_importMovieDialogController release];
    [_navigationPaneSwitcher setDelegate:0];
    [_navigationPaneSwitcher release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"AnimationPickImagePane"];
    return self;
}

- (void)HSAnimationSetupPickImageAssistantPane_cardsWillChange:(id)aChange
{
    NSSet *removed = [[aChange userInfo] objectForKey:@"HSNodeChildrenForRemoval"];
    if ([[[aChange userInfo] objectForKey:@"HSNodeChildrenForAddition"] count] == 0 && ![removed containsObject:[self card]]) {
        return;
    }
    [[HSToolManager sharedToolManager] selectToolWithTag:0];
}

- (void)HSAnimationSetupPickImageAssistantPane_currentCardWillChange:(id)aChange
{
    [[HSToolManager sharedToolManager] selectToolWithTag:0];
}

- (void)HSAnimationSetupPickImageAssistantPane_objectsWillChange:(id)aChange
{
    NSSet *removed = [[aChange userInfo] objectForKey:@"HSNodeChildrenForRemoval"];
    if ([[[aChange userInfo] objectForKey:@"HSNodeChildrenForAddition"] count] == 0 && ![removed containsObject:[[self assistant] object]]) {
        return;
    }
    [[HSToolManager sharedToolManager] selectToolWithTag:0];
}

- (void)HSAnimationSetupPickImageAssistantPane_toolDidChange:(id)aChange
{
    [[[self cardView] selection] removeAllNodes];
}

- (void)HSAnimationSetupPickImageAssistantPane_windowDidResignMain:(id)aChange
{
    id current = [[HSEditorController sharedDocumentController] currentDocument];
    if (current != nil && current != [self document]) {
        [[HSToolManager sharedToolManager] selectToolWithTag:0];
    }
}

- (id)assistantPaneUndoManager
{
    return [_delegate undoManagerForPickImageAssistantPane:self];
}

- (id)cardView
{
    return [_delegate cardViewForPickImageAssistantPane:self];
}

- (id)document
{
    return [_delegate documentForPickImageAssistantPane:self];
}

- (void)cropImageDialogDidEnd:(id)aDialog returnedCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    [aDialog orderOut:nil];
    NSDictionary *context = aInfo;
    NSMutableDictionary *options = [context objectForKey:@"optionsKey"];
    NSRect imageRect = [[context objectForKey:@"imageRectKey"] rectValue];
    id sourceImage = [context objectForKey:@"sourceImageKey"];
    id controller = [aDialog delegate];
    if (aCode == 1) {
        if ([controller hasValidCropPath]) {
            NSBezierPath *path = [NSBezierPath hyperBezierPathWithCGPath:[controller borderPath] affineTransform:CGAffineTransformMake(1, 0, 0, -1, 0, imageRect.size.height)];
            if (path != nil) {
                [options setObject:path forKey:@"cropping path"];
            }
        }
        [controller autorelease];
        [_delegate runWithImage:sourceImage options:options fromPane:self];
    } else {
        [controller autorelease];
    }
    [options release];
    [sourceImage release];
    [context release];
}

- (void)openPanelDidFinish:(id)aPanel returnedCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    [aPanel orderOut:nil];
    if (aCode == 1) {
        NSString *path = [[[aPanel URLs] lastObject] path];
        [[HSPathsProvider sharedPathsProvider] setImageSequencesFolder:path];
        id file = [self findFileForCelAnimationForPath:path];
        if (file == nil) {
            HSAlert *alert = [[HSAlert new] autorelease];
            [alert setAlertStyle:NSCriticalAlertStyle];
            [alert setMessageText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"There are no images to animate" value:@"" table:@"Alerts"]];
            [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"The folder you have chosen does not contain images that can be animated." value:@"" table:@"Alerts"]];
            [alert runModal];
        } else {
            [self createAnimationFromImage:file dialogOptions:nil isAnimatedGif:NO];
        }
    }
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    if ([_delegate needObserveStackChangesForPickImageAssistantPane:self]) {
        [_delegate runEditPathIfNeededForPickImageAssistantPane:self];
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(HSAnimationSetupPickImageAssistantPane_currentCardWillChange:) name:HSCurrentCardInCardViewWillChange object:[self cardView]];
        [center addObserver:self selector:@selector(HSAnimationSetupPickImageAssistantPane_windowDidResignMain:) name:NSWindowDidResignMainNotification object:[[self cardView] window]];
        [center addObserver:self selector:@selector(HSAnimationSetupPickImageAssistantPane_toolDidChange:) name:@"HSActiveToolDidSelectionNotification" object:[HSToolManager sharedToolManager]];
        id stack = [[self document] stack];
        [stack addObserver:self selector:@selector(HSAnimationSetupPickImageAssistantPane_cardsWillChange:) ofChanges:HSActualWillAttributeChanges ofAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:-0.25];
        [stack addObserver:self selector:@selector(HSAnimationSetupPickImageAssistantPane_objectsWillChange:) ofChanges:HSActualWillAttributeChanges ofChildrenAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:-0.25];
    }
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [super viewWillDisappear:aDisappear];
    if ([_delegate needObserveStackChangesForPickImageAssistantPane:self]) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self name:HSCurrentCardInCardViewWillChange object:[self cardView]];
        [center removeObserver:self name:NSWindowDidResignMainNotification object:[[self cardView] window]];
        [center removeObserver:self name:@"HSActiveToolDidSelectionNotification" object:[HSToolManager sharedToolManager]];
        id stack = [[self document] stack];
        [stack removeObserver:self selector:@selector(HSAnimationSetupPickImageAssistantPane_cardsWillChange:) ofChanges:HSActualWillAttributeChanges ofAttribute:@protocol(HSNodeContainerChildrenAttribute)];
        [stack removeObserver:self selector:@selector(HSAnimationSetupPickImageAssistantPane_objectsWillChange:) ofChanges:HSActualWillAttributeChanges ofChildrenAttribute:@protocol(HSNodeContainerChildrenAttribute)];
    }
}

@end

