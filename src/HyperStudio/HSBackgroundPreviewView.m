#import "HSBackgroundPreviewView.h"

static BOOL HSBackgroundPreviewSizeEqual(NSSize a, NSSize b)
{
    float scaleW = MAX((a.width != 0.0) ? fabs(a.width) : 1.0, (b.width != 0.0) ? fabs(b.width) : 1.0);
    if (fabs(a.width - b.width) > scaleW * 0.0005) {
        return NO;
    }
    float scaleH = MAX((a.height != 0.0) ? fabs(a.height) : 1.0, (b.height != 0.0) ? fabs(b.height) : 1.0);
    return fabs(a.height - b.height) <= scaleH * 0.0005;
}

@implementation HSBackgroundPreviewView

/* i386 ivar offsets: _image=0x50, _imageScaling=0x54, _relativeClipPaths=0x58, _relativeClipPathsTransform=0x5c, _imageSize=0x74, _previewImage=0x7c */

- (void)invalidatePreviewImage
{
    [_previewImage release];
    _previewImage = nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c19ff @ 001c19ff, 360 bytes * /

id FUN_001c19ff(HSBackgroundPreviewView *self,SEL _cmd)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  undefined4 uVar5;
  
  puVar1 = cls_HSBackgroundPreviewImageRep;
  if (self->_previewImage == (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_zone);
    pvVar2 = _objc_msgSend(puVar1,sel_allocWithZone_,pvVar2);
    pvVar3 = _objc_msgSend(self,sel_imageSize);
    pvVar4 = _objc_msgSend(self,sel_image);
    uVar5 = extraout_EDX;
    pvVar2 = _objc_msgSend(pvVar2,sel_initWithPreviewImage_imageSize_,pvVar4,pvVar3,extraout_EDX);
    puVar1 = cls_NSImage;
    if (pvVar2 != (id)0x0) {
      pvVar3 = _objc_msgSend(self,sel_zone,pvVar4,pvVar3,uVar5);
      pvVar3 = _objc_msgSend(puVar1,sel_allocWithZone_,pvVar3);
      pvVar4 = _objc_msgSend(pvVar2,sel_size);
      pvVar3 = _objc_msgSend(pvVar3,sel_initWithSize_,pvVar4,extraout_EDX_00);
      self->_previewImage = pvVar3;
      _objc_msgSend(pvVar3,sel_addRepresentation_,pvVar2);
      _objc_msgSend(pvVar2,sel_release);
      _objc_msgSend(self->_previewImage,sel_setCacheMode_,3);
    }
  }
  return self->_previewImage;
}

*/
- (id)previewImage
{
    if (_previewImage == nil) {
        HSBackgroundPreviewImageRep *rep = [[HSBackgroundPreviewImageRep allocWithZone:[self zone]] initWithPreviewImage:[self image] imageSize:[self imageSize]];
        if (rep != nil) {
            _previewImage = [[NSImage allocWithZone:[self zone]] initWithSize:[rep size]];
            [_previewImage addRepresentation:rep];
            [rep release];
            [_previewImage setCacheMode:3];
        }
    }
    return _previewImage;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c1b67 @ 001c1b67, 1654 bytes * /

void FUN_001c1b67(HSBackgroundPreviewView *self,SEL _cmd,NSRect drawRect)

{
  float fVar1;
  undefined *self_00;
  id pvVar2;
  id pvVar3;
  float extraout_EDX;
  float extraout_EDX_00;
  bool bVar4;
  bool bVar5;
  float fVar6;
  float fVar7;
  float fVar8;
  float fVar9;
  float fVar10;
  float fVar11;
  float fVar12;
  id local_50;
  float local_4c;
  id local_48;
  float local_44;
  float fStack_40;
  id local_3c;
  float fStack_38;
  
  _objc_msgSend(cls_NSGraphicsContext,sel_saveGraphicsState);
  pvVar2 = _objc_msgSend(cls_NSColor,sel_whiteColor);
  _objc_msgSend(pvVar2,sel_set);
  _NSRectFill(drawRect.origin.x,drawRect.origin.y,drawRect.size.width,drawRect.size.height);
  fVar9 = drawRect.origin.x;
  fVar10 = drawRect.origin.y;
  fVar11 = drawRect.size.width;
  fVar12 = drawRect.size.height;
  _objc_msgSend(self,sel_applyClipPathsInRect_,drawRect.origin.x,drawRect.origin.y,
                drawRect.size.width,drawRect.size.height);
  local_44 = drawRect.origin.x;
  fStack_40 = drawRect.origin.y;
  local_3c = (id)drawRect.size.width;
  fStack_38 = drawRect.size.height;
  local_48 = _objc_msgSend(self,sel_imageSize);
  fVar6 = *(float *)PTR_0033607c;
  fVar1 = *(float *)(PTR_0033607c + 4);
  if (((float)local_48 != 0.0) || (NAN((float)local_48))) {
    fVar7 = ABS((float)local_48);
  }
  else {
    fVar7 = 1.0;
  }
  if ((fVar6 != 0.0) || (NAN(fVar6))) {
    fVar8 = ABS(fVar6);
  }
  else {
    fVar8 = 1.0;
  }
  if (fVar8 <= fVar7) {
    fVar8 = fVar7;
  }
  local_4c = extraout_EDX;
  if (ABS((float)local_48 - fVar6) <= fVar8 * 0.0005) {
    if ((extraout_EDX != 0.0) || (NAN(extraout_EDX))) {
      fVar6 = ABS(extraout_EDX);
    }
    else {
      fVar6 = 1.0;
    }
    if ((fVar1 != 0.0) || (NAN(fVar1))) {
      fVar7 = ABS(fVar1);
    }
    else {
      fVar7 = 1.0;
    }
    if (fVar7 <= fVar6) {
      fVar7 = fVar6;
    }
    if (ABS(extraout_EDX - fVar1) <= fVar7 * 0.0005) {
      pvVar2 = _objc_msgSend(self,sel_image,fVar9,fVar10,fVar11,fVar12);
      local_48 = _objc_msgSend(pvVar2,sel_hyperPixelsSize);
      local_4c = extraout_EDX_00;
    }
  }
  local_50 = _objc_msgSend(self,sel_image,fVar9,fVar10,fVar11,fVar12);
  pvVar2 = _objc_msgSend(self,sel_imageScaling);
  switch(pvVar2) {
  case (id)0x0:
    bVar5 = (float)local_48 / local_4c == drawRect.size.width / drawRect.size.height;
    bVar4 = (float)local_48 / local_4c < drawRect.size.width / drawRect.size.height;
    goto LAB_001c1e93;
  case (id)0x1:
    local_4c = (float)local_48 / local_4c;
    if (local_4c <= drawRect.size.width / drawRect.size.height) {
      local_48 = (id)(local_4c * drawRect.size.height);
    }
    else {
      local_48 = (id)drawRect.size.width;
      fStack_38 = drawRect.size.width / local_4c;
    }
    local_3c = (id)((float)local_48 * 0.57735026);
    local_44 = ((drawRect.size.width * 0.5 + drawRect.origin.x) -
               ((float)local_3c * 0.5 + drawRect.origin.x)) + drawRect.origin.x;
    fStack_38 = fStack_38 * 0.57735026;
    fStack_40 = ((drawRect.size.height * 0.5 + drawRect.origin.y) -
                (fStack_38 * 0.5 + drawRect.origin.y)) + drawRect.origin.y;
    break;
  case (id)0x2:
    bVar5 = drawRect.size.width / drawRect.size.height == (float)local_48 / local_4c;
    bVar4 = drawRect.size.width / drawRect.size.height < (float)local_48 / local_4c;
LAB_001c1e93:
    local_48 = (id)((float)local_48 / local_4c);
    local_44 = *(float *)PTR_00336078;
    fStack_40 = *(float *)(PTR_00336078 + 4);
    if (bVar4 || bVar5) {
      local_48 = (id)((float)local_48 * drawRect.size.height);
    }
    else {
      fStack_38 = drawRect.size.width / (float)local_48;
      local_48 = (id)drawRect.size.width;
    }
    local_44 = ((drawRect.size.width * 0.5 + local_44) - ((float)local_48 * 0.5 + local_44)) +
               local_44;
    fStack_40 = ((drawRect.size.height * 0.5 + fStack_40) - (fStack_38 * 0.5 + fStack_40)) +
                fStack_40;
    local_3c = local_48;
    break;
  case (id)0x4:
    local_44 = ((drawRect.size.width * 0.5 + drawRect.origin.x) - ((float)local_48 * 0.5 + 0.0)) +
               0.0;
    fStack_40 = ((drawRect.size.height * 0.5 + drawRect.origin.y) - (local_4c * 0.5 + 0.0)) + 0.0;
    local_3c = local_48;
    fStack_38 = local_4c;
    break;
  case (id)0x5:
    pvVar2 = _objc_msgSend(cls_NSGraphicsContext,sel_currentContext);
    pvVar2 = _objc_msgSend(pvVar2,sel_graphicsPort);
    _CGContextBeginPath(pvVar2);
    _CGContextAddRect(pvVar2,drawRect.origin.x,drawRect.origin.y,drawRect.size.width,
                      drawRect.size.height);
    self_00 = cls_NSColor;
    pvVar3 = _objc_msgSend(self,sel_previewImage);
    pvVar3 = _objc_msgSend(self_00,sel_colorWithPatternImage_,pvVar3);
    pvVar3 = _objc_msgSend(pvVar3,sel_BT_coreGraphicsExtendedColor);
    _CGEContextFillPathWithColor
              (pvVar2,0,drawRect.origin.x,drawRect.origin.y,drawRect.size.width,drawRect.size.height
               ,pvVar3);
    local_50 = (id)0x0;
  }
  pvVar2 = _objc_msgSend(cls_NSGraphicsContext,sel_currentContext);
  pvVar2 = _objc_msgSend(pvVar2,sel_imageInterpolation);
  pvVar3 = _objc_msgSend(cls_NSGraphicsContext,sel_currentContext);
  _objc_msgSend(pvVar3,sel_setImageInterpolation_,3);
  _objc_msgSend(local_50,sel_drawInRect_fromRect_operation_fraction_,local_44,fStack_40,local_3c,
                fStack_38,*(undefined8 *)PTR_00336078,*(undefined8 *)(PTR_00336078 + 8),2,0x3f800000
               );
  pvVar3 = _objc_msgSend(cls_NSGraphicsContext,sel_currentContext);
  _objc_msgSend(pvVar3,sel_setImageInterpolation_,pvVar2);
  _objc_msgSend(cls_NSGraphicsContext,sel_restoreGraphicsState);
  return;
}

*/
- (void)drawRect:(NSRect)aRect
{
    [NSGraphicsContext saveGraphicsState];
    [[NSColor whiteColor] set];
    NSRectFill(aRect);
    [self applyClipPathsInRect:aRect];
    NSRect destination = aRect;
    NSSize size = [self imageSize];
    if (HSBackgroundPreviewSizeEqual(size, NSZeroSize)) {
        size = [[self image] hyperPixelsSize];
    }
    NSImage *image = [self image];
    float imageRatio = size.width / size.height;
    float rectRatio = aRect.size.width / aRect.size.height;
    float width;
    float height;
    switch ([self imageScaling]) {
    case 0:
    case 2:
        if ([self imageScaling] == 0 ? (imageRatio <= rectRatio) : (rectRatio <= imageRatio)) {
            width = imageRatio * aRect.size.height;
            height = aRect.size.height;
        }
        else {
            width = aRect.size.width;
            height = aRect.size.width / imageRatio;
        }
        destination = NSMakeRect((aRect.size.width - width) * 0.5f, (aRect.size.height - height) * 0.5f, width, height);
        break;
    case 1:
        if (imageRatio <= rectRatio) {
            width = imageRatio * aRect.size.height;
            height = aRect.size.height;
        }
        else {
            width = aRect.size.width;
            height = aRect.size.width / imageRatio;
        }
        width *= 0.57735026f;
        height *= 0.57735026f;
        destination = NSMakeRect(aRect.origin.x + aRect.size.width * 0.5f - width * 0.5f, aRect.origin.y + aRect.size.height * 0.5f - height * 0.5f, width, height);
        break;
    case 4:
        destination = NSMakeRect(aRect.size.width * 0.5f + aRect.origin.x - size.width * 0.5f, aRect.size.height * 0.5f + aRect.origin.y - size.height * 0.5f, size.width, size.height);
        break;
    case 5: {
        CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
        CGContextBeginPath(context);
        CGContextAddRect(context, NSRectToCGRect(aRect));
        CGEContextFillPathWithColor(context, NULL, NSRectToCGRect(aRect), [[NSColor colorWithPatternImage:[self previewImage]] BT_coreGraphicsExtendedColor]);
        image = nil;
        break;
    }
    default:
        break;
    }
    NSImageInterpolation interpolation = [[NSGraphicsContext currentContext] imageInterpolation];
    [[NSGraphicsContext currentContext] setImageInterpolation:3];
    [image drawInRect:destination fromRect:NSZeroRect operation:2 fraction:1.0];
    [[NSGraphicsContext currentContext] setImageInterpolation:interpolation];
    [NSGraphicsContext restoreGraphicsState];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c21f8 @ 001c21f8, 721 bytes * /

void FUN_001c21f8(HSBackgroundPreviewView *self,SEL _cmd,NSRect applyClipPathsInRect)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  float fVar4;
  float fVar5;
  float fVar6;
  float fVar7;
  float fVar8;
  float fVar9;
  float fVar10;
  float fVar11;
  float fVar12;
  float local_4c;
  float local_48;
  
  pvVar1 = _objc_msgSend(self,sel_relativeClipPaths);
  pvVar2 = _objc_msgSend(pvVar1,sel_count);
  if (pvVar2 != (id)0x0) {
    pvVar2 = _objc_msgSend(cls_NSGraphicsContext,sel_currentContext);
    pvVar2 = _objc_msgSend(pvVar2,sel_graphicsPort);
    fVar8 = (self->_relativeClipPathsTransform).a;
    fVar4 = (self->_relativeClipPathsTransform).b;
    fVar7 = applyClipPathsInRect.size.width / 1.0;
    fVar5 = fVar8 * fVar7 + fVar4 * 0.0;
    fVar9 = (self->_relativeClipPathsTransform).tx;
    fVar6 = (self->_relativeClipPathsTransform).ty;
    fVar12 = (self->_relativeClipPathsTransform).c;
    fVar10 = (self->_relativeClipPathsTransform).d;
    fVar11 = applyClipPathsInRect.size.height / 1.0;
    local_4c = fVar4 * fVar11 + fVar8 * 0.0;
    local_48 = fVar12 * fVar7 + fVar10 * 0.0;
    fVar8 = fVar10 * fVar11 + fVar12 * 0.0;
    fVar4 = (applyClipPathsInRect.origin.x - fVar7 * 0.0) + fVar9 * fVar7 + fVar6 * 0.0;
    fVar9 = (applyClipPathsInRect.origin.y - fVar11 * 0.0) + fVar6 * fVar11 + fVar9 * 0.0;
    _CGContextConcatCTM(pvVar2,CONCAT44(local_4c,fVar5),CONCAT44(fVar8,local_48),
                        CONCAT44(fVar9,fVar4));
    pvVar1 = _objc_msgSend(pvVar1,sel_objectEnumerator);
    while( true ) {
      pvVar3 = _objc_msgSend(pvVar1,sel_nextObject);
      if (pvVar3 == (id)0x0) break;
      _CGContextAddPath(pvVar2,pvVar3);
      _CGContextClip(pvVar2);
    }
    fVar6 = fVar5 * fVar8 - local_4c * local_48;
    if ((fVar6 != 0.0) || (fVar10 = fVar5, fVar12 = fVar9, NAN(fVar6))) {
      fVar10 = fVar8 / fVar6;
      fVar8 = fVar5 / fVar6;
      local_4c = local_4c / -fVar6;
      fVar12 = -(local_4c * fVar4 + fVar8 * fVar9);
      local_48 = local_48 / -fVar6;
      fVar4 = -(fVar4 * fVar10 + fVar9 * local_48);
    }
    _CGContextConcatCTM(pvVar2,CONCAT44(local_4c,fVar10),CONCAT44(fVar8,local_48),
                        CONCAT44(fVar12,fVar4));
  }
  return;
}

*/
- (void)applyClipPathsInRect:(NSRect)aRect
{
    NSArray *paths = [self relativeClipPaths];
    if ([paths count] != 0) {
        CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
        CGAffineTransform transform = CGAffineTransformConcat(_relativeClipPathsTransform, CGAffineTransformMake(aRect.size.width, 0.0, 0.0, aRect.size.height, aRect.origin.x, aRect.origin.y));
        CGContextConcatCTM(context, transform);
        for (id path in paths) {
            CGContextAddPath(context, (CGPathRef)path);
            CGContextClip(context);
        }
        CGContextConcatCTM(context, CGAffineTransformInvert(transform));
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c193c @ 001c193c, 14 bytes * /

ulonglong FUN_001c193c(HSBackgroundPreviewView *self,SEL _cmd)

{
  ulonglong uVar1;
  
  uVar1._0_4_ = (self->_imageSize).width;
  uVar1._4_4_ = (self->_imageSize).height;
  return uVar1;
}

*/
- (NSSize)imageSize
{
    return _imageSize;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c24c9 @ 001c24c9, 258 bytes * /

void FUN_001c24c9(HSBackgroundPreviewView *self,SEL _cmd,NSSize setImageSize)

{
  float fVar1;
  float fVar2;
  float fVar3;
  float fVar4;
  
  fVar2 = (self->_imageSize).width;
  fVar1 = (self->_imageSize).height;
  if ((setImageSize.width != 0.0) || (NAN(setImageSize.width))) {
    fVar3 = ABS(setImageSize.width);
  }
  else {
    fVar3 = 1.0;
  }
  if ((fVar2 != 0.0) || (NAN(fVar2))) {
    fVar4 = ABS(fVar2);
  }
  else {
    fVar4 = 1.0;
  }
  if (fVar4 <= fVar3) {
    fVar4 = fVar3;
  }
  if (ABS(setImageSize.width - fVar2) <= fVar4 * 0.0005) {
    if ((setImageSize.height != 0.0) || (NAN(setImageSize.height))) {
      fVar2 = ABS(setImageSize.height);
    }
    else {
      fVar2 = 1.0;
    }
    if ((fVar1 != 0.0) || (NAN(fVar1))) {
      fVar3 = ABS(fVar1);
    }
    else {
      fVar3 = 1.0;
    }
    if (fVar3 <= fVar2) {
      fVar3 = fVar2;
    }
    if (ABS(setImageSize.height - fVar1) <= fVar3 * 0.0005) {
      return;
    }
  }
  (self->_imageSize).width = setImageSize.width;
  (self->_imageSize).height = setImageSize.height;
  _objc_msgSend(self,sel_invalidatePreviewImage);
  return;
}

*/
- (void)setImageSize:(NSSize)aSize
{
    if (!HSBackgroundPreviewSizeEqual(aSize, _imageSize)) {
        _imageSize = aSize;
        [self invalidatePreviewImage];
    }
}

- (void)setImage:(id)aImage scaling:(NSInteger)aScaling
{
    [self setImage:aImage];
    [self setImageScaling:aScaling];
}

- (void)setRelativeClipPaths:(id)aPaths affineTransform:(CGAffineTransform *)aTransform
{
    [self setRelativeClipPaths:aPaths];
    if (aTransform != nil) {
        (_relativeClipPathsTransform).a = aTransform->a;
        (_relativeClipPathsTransform).b = aTransform->b;
        (_relativeClipPathsTransform).c = aTransform->c;
        (_relativeClipPathsTransform).d = aTransform->d;
        (_relativeClipPathsTransform).tx = aTransform->tx;
        (_relativeClipPathsTransform).ty = aTransform->ty;
    }
}

- (void)setRelativeClipPaths:(id)aPaths
{
    if (_relativeClipPaths != aPaths) {
        [_relativeClipPaths release];
        _relativeClipPaths = [aPaths retain];
    }
}

- (id)relativeClipPaths
{
    return _relativeClipPaths;
}

- (void)setImageScaling:(NSInteger)aScaling
{
    if (_imageScaling != aScaling) {
        _imageScaling = aScaling;
    }
}

- (NSInteger)imageScaling
{
    return _imageScaling;
}

- (void)setImage:(id)aImage
{
    id self_00;

    if (_image != aImage) {
        [_image release];
        self_00 = [aImage retain];
        _image = self_00;
        [self_00 setCacheMode:3];
        [self invalidatePreviewImage];
    }
}

- (id)image
{
    return _image;
}

- (void)dealloc
{
    [_image release];
    [_previewImage release];
    [_relativeClipPaths release];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c194a @ 001c194a, 131 bytes * /

id FUN_001c194a(HSBackgroundPreviewView *self,SEL _cmd)

{
  undefined4 uVar1;
  undefined *puVar2;
  id pvVar3;
  HSBackgroundPreviewView *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_NSView_00353870;
  pvVar3 = _objc_msgSendSuper(&local_14,sel_init);
  if (pvVar3 != (id)0x0) {
    *(undefined4 *)((int)pvVar3 + 0x54) = 4;
    puVar2 = PTR_00336088;
    uVar1 = *(undefined4 *)(PTR_00336088 + 4);
    *(undefined4 *)((int)pvVar3 + 0x5c) = *(undefined4 *)PTR_00336088;
    *(undefined4 *)((int)pvVar3 + 0x60) = uVar1;
    *(undefined4 *)((int)pvVar3 + 100) = *(undefined4 *)(puVar2 + 8);
    *(undefined4 *)((int)pvVar3 + 0x68) = *(undefined4 *)(puVar2 + 0xc);
    *(undefined4 *)((int)pvVar3 + 0x6c) = *(undefined4 *)(puVar2 + 0x10);
    *(undefined4 *)((int)pvVar3 + 0x70) = *(undefined4 *)(puVar2 + 0x14);
  }
  return pvVar3;
}

*/
- (id)init
{
    self = [super init];
    if (self != nil) {
        _imageScaling = 4;
        _relativeClipPathsTransform = CGAffineTransformIdentity;
    }
    return self;
}

@end

@implementation HSBackgroundPreviewImageRep

/* i386 ivar offsets: _image=0x1c */

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c2a89 @ 001c2a89, 198 bytes * /

BOOL FUN_001c2a89(HSBackgroundPreviewImageRep *self,SEL _cmd,NSRect drawInRect)

{
  id self_00;
  undefined8 uVar1;
  id pvVar2;
  undefined4 extraout_EDX;
  
  self_00 = self->_image;
  if (self_00 != (id)0x0) {
    uVar1 = *(undefined8 *)PTR_00336074;
    pvVar2 = _objc_msgSend(self_00,sel_size);
    _objc_msgSend(self->_image,sel_drawInRect_fromRect_operation_fraction_,drawInRect.origin,
                  drawInRect.size,uVar1,CONCAT44(extraout_EDX,pvVar2),2,0x3f800000);
  }
  return self_00 != (id)0x0;
}

*/
- (BOOL)drawInRect:(NSRect)aRect
{
    if (_image == nil) {
        return NO;
    }
    NSSize size = [_image size];
    [_image drawInRect:aRect fromRect:NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, size.width, size.height) operation:2 fraction:1.0];
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c2b4f @ 001c2b4f, 111 bytes * /

BOOL FUN_001c2b4f(HSBackgroundPreviewImageRep *self,SEL _cmd,NSPoint drawAtPoint)

{
  id pvVar1;
  undefined4 extraout_EDX;
  
  pvVar1 = _objc_msgSend(self,sel_size);
  pvVar1 = _objc_msgSend(self,sel_drawInRect_,drawAtPoint,CONCAT44(extraout_EDX,pvVar1));
  return (BOOL)pvVar1;
}

*/
- (BOOL)drawAtPoint:(NSPoint)aPoint
{
    NSSize size = [self size];
    return [self drawInRect:NSMakeRect(aPoint.x, aPoint.y, size.width, size.height)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c2bbe @ 001c2bbe, 122 bytes * /

id FUN_001c2bbe(HSBackgroundPreviewImageRep *self,SEL _cmd,NSZone *copyWithZone)

{
  id pvVar1;
  id pvVar2;
  undefined4 extraout_EDX;
  
  pvVar1 = _objc_msgSend(self,sel_class);
  pvVar1 = _objc_msgSend(pvVar1,sel_allocWithZone_,copyWithZone);
  pvVar2 = _objc_msgSend(self,sel_size);
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithPreviewImage_imageSize_,self->_image,pvVar2,extraout_EDX
                        );
  return pvVar1;
}

*/
- (id)copyWithZone:(NSZone *)aZone
{
    return [[[self class] allocWithZone:aZone] initWithPreviewImage:_image imageSize:[self size]];
}

- (void)dealloc
{
    [_image release];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c27c0 @ 001c27c0, 713 bytes * /

id FUN_001c27c0(HSBackgroundPreviewImageRep *self,SEL _cmd,id initWithPreviewImage,NSSize imageSize)

{
  float fVar1;
  id self_00;
  id pvVar2;
  id pvVar3;
  float extraout_EDX;
  float fVar4;
  float fVar5;
  float fVar6;
  undefined4 uVar7;
  id local_24;
  float local_20;
  HSBackgroundPreviewImageRep *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_NSImageRep_003538a0;
  self_00 = _objc_msgSendSuper(&local_1c,sel_init);
  if (self_00 != (id)0x0) {
    local_20 = imageSize.height;
    local_24 = (id)imageSize.width;
    pvVar2 = _objc_msgSend(initWithPreviewImage,sel_retain);
    *(id *)((int)self_00 + 0x1c) = pvVar2;
    fVar4 = *(float *)PTR_0033607c;
    fVar1 = *(float *)(PTR_0033607c + 4);
    if ((imageSize.width != 0.0) || (NAN(imageSize.width))) {
      fVar5 = ABS(imageSize.width);
    }
    else {
      fVar5 = 1.0;
    }
    if ((fVar4 != 0.0) || (NAN(fVar4))) {
      fVar6 = ABS(fVar4);
    }
    else {
      fVar6 = 1.0;
    }
    if (fVar6 <= fVar5) {
      fVar6 = fVar5;
    }
    if (ABS(imageSize.width - fVar4) <= fVar6 * 0.0005) {
      if ((imageSize.height != 0.0) || (NAN(imageSize.height))) {
        fVar4 = ABS(imageSize.height);
      }
      else {
        fVar4 = 1.0;
      }
      if ((fVar1 != 0.0) || (NAN(fVar1))) {
        fVar5 = ABS(fVar1);
      }
      else {
        fVar5 = 1.0;
      }
      if (fVar5 <= fVar4) {
        fVar5 = fVar4;
      }
      if ((ABS(imageSize.height - fVar1) <= fVar5 * 0.0005) && (pvVar2 != (id)0x0)) {
        local_24 = _objc_msgSend(pvVar2,sel_hyperPixelsSize);
        local_20 = extraout_EDX;
      }
    }
    _objc_msgSend(self_00,sel_setSize_,local_24,local_20);
    uVar7 = 0;
    pvVar2 = _objc_msgSend(*(id *)((int)self_00 + 0x1c),sel_bestRepresentationForDevice_,0);
    if (pvVar2 != (id)0x0) {
      pvVar3 = _objc_msgSend(pvVar2,sel_hasAlpha,uVar7,local_20);
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
- (id)initWithPreviewImage:(id)aImage imageSize:(NSSize)aSize
{
    self = [super init];
    if (self != nil) {
        NSSize size = aSize;
        _image = [aImage retain];
        if (HSBackgroundPreviewSizeEqual(aSize, NSZeroSize) && _image != nil) {
            size = [_image hyperPixelsSize];
        }
        [self setSize:size];
        NSImageRep *bestRep = [_image bestRepresentationForDevice:nil];
        if (bestRep != nil) {
            [self setAlpha:[bestRep hasAlpha]];
            [self setOpaque:[bestRep isOpaque]];
            [self setColorSpaceName:[bestRep colorSpaceName]];
            [self setBitsPerSample:[bestRep bitsPerSample]];
            [self setPixelsWide:[bestRep pixelsWide]];
            [self setPixelsHigh:[bestRep pixelsHigh]];
        }
    }
    return self;
}

@end

