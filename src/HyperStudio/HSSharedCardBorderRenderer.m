#import "HSSharedCardBorderRenderer.h"
static id sDAT_00342834;
static id sDAT_00342838;

static BOOL HSCardBorderFloatsAreEqual(float a, float b)
{
    float ma = a != 0.0f ? fabsf(a) : 1.0f;
    float mb = b != 0.0f ? fabsf(b) : 1.0f;
    return fabsf(a - b) <= MAX(ma, mb) * 0.0005f;
}


@implementation HSSharedCardBorderRenderer

/* i386 ivar offsets: _topBorder=0x4, _rightBorder=0x8, _bottomBorder=0xc, _leftBorder=0x10, _topLeftCorner=0x14, _topRightCorner=0x18, _bottomLeftCorner=0x1c, _bottomRightCorner=0x20, _borderInset=0x24 */

+ (id)selectedBorderRenderer
{
    if (sDAT_00342834 == nil) {
        sDAT_00342834 = [[HSSharedCardBorderRenderer alloc] initSelectedRenderer];
    }
    return sDAT_00342834;
}

+ (id)borderRenderer
{
    if (sDAT_00342838 == nil) {
        sDAT_00342838 = [[HSSharedCardBorderRenderer alloc] init];
    }
    return sDAT_00342838;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008d55c @ 0008d55c, 171 bytes * /

id FUN_0008d55c(id self,SEL _cmd,id imageNamed,id prefix,id suffix,NSSize *size)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  float extraout_EDX;
  float fVar3;
  
  pvVar1 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr_______,prefix,imageNamed,suffix);
  self_00 = _objc_msgSend(cls_NSImage,sel_imageNamed_,pvVar1);
  pvVar2 = *(id *)PTR_0033607c;
  fVar3 = *(float *)(PTR_0033607c + 4);
  if (self_00 != (id)0x0) {
    pvVar2 = _objc_msgSend(self_00,sel_size,pvVar1,prefix,imageNamed,suffix);
    fVar3 = extraout_EDX;
  }
  if (size != (NSSize *)0x0) {
    size->width = (float)pvVar2;
    size->height = fVar3;
  }
  return self_00;
}

*/
+ (id)imageNamed:(id)aNamed prefix:(id)aPrefix suffix:(id)aSuffix size:(NSSize *)aSize
{
    NSImage *image = [NSImage imageNamed:[NSString stringWithFormat:@"%@%@%@", aPrefix, aNamed, aSuffix]];
    NSSize size = NSZeroSize;
    if (image != nil) {
        size = [image size];
    }
    if (aSize != NULL) {
        *aSize = size;
    }
    return image;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008c3eb @ 0008c3eb, 14 bytes * /

ulonglong FUN_0008c3eb(HSSharedCardBorderRenderer *self,SEL _cmd)

{
  ulonglong uVar1;
  
  uVar1._0_4_ = (self->_borderInset).x;
  uVar1._4_4_ = (self->_borderInset).y;
  return uVar1;
}

*/
- (NSPoint)inset
{
    return _borderInset;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008d607 @ 0008d607, 1335 bytes * /

void FUN_0008d607(HSSharedCardBorderRenderer *self,SEL _cmd,NSRect renderAroundRect)

{
  undefined8 uVar1;
  undefined8 uVar2;
  undefined8 uVar3;
  undefined8 uVar4;
  undefined8 uVar5;
  undefined8 uVar6;
  undefined8 uVar7;
  undefined8 uVar8;
  char cVar9;
  id pvVar10;
  undefined4 extraout_EDX;
  float extraout_EDX_00;
  undefined4 extraout_EDX_01;
  undefined4 extraout_EDX_02;
  undefined4 extraout_EDX_03;
  undefined4 extraout_EDX_04;
  float extraout_EDX_05;
  float extraout_EDX_06;
  NSSize NVar11;
  
  uVar8 = *(undefined8 *)PTR_00336078;
  uVar7 = *(undefined8 *)PTR_00336078;
  uVar6 = *(undefined8 *)PTR_00336078;
  uVar5 = *(undefined8 *)PTR_00336078;
  uVar4 = *(undefined8 *)PTR_00336078;
  uVar3 = *(undefined8 *)PTR_00336078;
  uVar2 = *(undefined8 *)PTR_00336078;
  uVar1 = *(undefined8 *)PTR_00336078;
  NVar11 = renderAroundRect.size;
  cVar9 = _NSIsEmptyRect(renderAroundRect.origin,NVar11);
  if (cVar9 == '\0') {
    if (self->_topBorder != (id)0x0) {
      pvVar10 = _objc_msgSend(self->_topBorder,sel_size);
      NVar11.height = renderAroundRect.origin.y + renderAroundRect.size.height;
      NVar11.width = renderAroundRect.origin.x;
      _objc_msgSend(self->_topBorder,sel_drawInRect_fromRect_operation_fraction_,NVar11,
                    CONCAT44(extraout_EDX,renderAroundRect.size.width),uVar1,
                    CONCAT44(extraout_EDX,pvVar10),1,0x3f800000);
    }
    if (self->_bottomBorder != (id)0x0) {
      pvVar10 = _objc_msgSend(self->_bottomBorder,sel_size,NVar11);
      NVar11.height = renderAroundRect.origin.y - extraout_EDX_00;
      NVar11.width = renderAroundRect.origin.x;
      _objc_msgSend(self->_bottomBorder,sel_drawInRect_fromRect_operation_fraction_,NVar11,
                    CONCAT44(extraout_EDX_00,renderAroundRect.size.width),uVar2,
                    CONCAT44(extraout_EDX_00,pvVar10),1,0x3f800000);
    }
    if (self->_rightBorder != (id)0x0) {
      pvVar10 = _objc_msgSend(self->_rightBorder,sel_size,NVar11);
      NVar11.height = renderAroundRect.origin.y;
      NVar11.width = renderAroundRect.origin.x + renderAroundRect.size.width;
      _objc_msgSend(self->_rightBorder,sel_drawInRect_fromRect_operation_fraction_,NVar11,
                    CONCAT44(renderAroundRect.size.height,pvVar10),uVar3,
                    CONCAT44(extraout_EDX_01,pvVar10),1,0x3f800000);
    }
    if (self->_leftBorder != (id)0x0) {
      pvVar10 = _objc_msgSend(self->_leftBorder,sel_size,NVar11);
      NVar11.height = renderAroundRect.origin.y;
      NVar11.width = renderAroundRect.origin.x - (float)pvVar10;
      _objc_msgSend(self->_leftBorder,sel_drawInRect_fromRect_operation_fraction_,NVar11,
                    CONCAT44(renderAroundRect.size.height,pvVar10),uVar4,
                    CONCAT44(extraout_EDX_02,pvVar10),1,0x3f800000);
    }
  }
  if (self->_topLeftCorner != (id)0x0) {
    pvVar10 = _objc_msgSend(self->_topLeftCorner,sel_size,NVar11);
    NVar11.height = renderAroundRect.origin.y + renderAroundRect.size.height;
    NVar11.width = renderAroundRect.origin.x - (float)pvVar10;
    _objc_msgSend(self->_topLeftCorner,sel_drawAtPoint_fromRect_operation_fraction_,
                  renderAroundRect.origin.x - (float)pvVar10,
                  renderAroundRect.origin.y + renderAroundRect.size.height,uVar5,
                  CONCAT44(extraout_EDX_03,pvVar10),1,0x3f800000);
  }
  if (self->_topRightCorner != (id)0x0) {
    pvVar10 = _objc_msgSend(self->_topRightCorner,sel_size,NVar11);
    NVar11.height = renderAroundRect.origin.y + renderAroundRect.size.height;
    NVar11.width = renderAroundRect.origin.x + renderAroundRect.size.width;
    _objc_msgSend(self->_topRightCorner,sel_drawAtPoint_fromRect_operation_fraction_,
                  renderAroundRect.origin.x + renderAroundRect.size.width,
                  renderAroundRect.origin.y + renderAroundRect.size.height,uVar6,
                  CONCAT44(extraout_EDX_04,pvVar10),1,0x3f800000);
  }
  if (self->_bottomLeftCorner != (id)0x0) {
    pvVar10 = _objc_msgSend(self->_bottomLeftCorner,sel_size,NVar11);
    NVar11.height = renderAroundRect.origin.y - extraout_EDX_05;
    NVar11.width = renderAroundRect.origin.x - (float)pvVar10;
    _objc_msgSend(self->_bottomLeftCorner,sel_drawAtPoint_fromRect_operation_fraction_,
                  renderAroundRect.origin.x - (float)pvVar10,
                  renderAroundRect.origin.y - extraout_EDX_05,uVar7,
                  CONCAT44(extraout_EDX_05,pvVar10),1,0x3f800000);
  }
  if (self->_bottomRightCorner != (id)0x0) {
    pvVar10 = _objc_msgSend(self->_bottomRightCorner,sel_size,NVar11);
    _objc_msgSend(self->_bottomRightCorner,sel_drawAtPoint_fromRect_operation_fraction_,
                  renderAroundRect.origin.x + renderAroundRect.size.width,
                  renderAroundRect.origin.y - extraout_EDX_06,uVar8,
                  CONCAT44(extraout_EDX_06,pvVar10),1,0x3f800000);
  }
  return;
}

*/
- (void)renderAroundRect:(NSRect)aRect
{
    NSPoint origin = NSZeroRect.origin;
    NSSize size;
    if (!NSIsEmptyRect(aRect)) {
        if (_topBorder != nil) {
            size = [_topBorder size];
            [_topBorder drawInRect:NSMakeRect(aRect.origin.x, aRect.origin.y + aRect.size.height, aRect.size.width, size.height) fromRect:NSMakeRect(origin.x, origin.y, size.width, size.height) operation:NSCompositeCopy fraction:1.0f];
        }
        if (_bottomBorder != nil) {
            size = [_bottomBorder size];
            [_bottomBorder drawInRect:NSMakeRect(aRect.origin.x, aRect.origin.y - size.height, aRect.size.width, size.height) fromRect:NSMakeRect(origin.x, origin.y, size.width, size.height) operation:NSCompositeCopy fraction:1.0f];
        }
        if (_rightBorder != nil) {
            size = [_rightBorder size];
            [_rightBorder drawInRect:NSMakeRect(aRect.origin.x + aRect.size.width, aRect.origin.y, size.width, aRect.size.height) fromRect:NSMakeRect(origin.x, origin.y, size.width, size.height) operation:NSCompositeCopy fraction:1.0f];
        }
        if (_leftBorder != nil) {
            size = [_leftBorder size];
            [_leftBorder drawInRect:NSMakeRect(aRect.origin.x - size.width, aRect.origin.y, size.width, aRect.size.height) fromRect:NSMakeRect(origin.x, origin.y, size.width, size.height) operation:NSCompositeCopy fraction:1.0f];
        }
    }
    // Corners are drawn even around an empty rect.
    if (_topLeftCorner != nil) {
        size = [_topLeftCorner size];
        [_topLeftCorner drawAtPoint:NSMakePoint(aRect.origin.x - size.width, aRect.origin.y + aRect.size.height) fromRect:NSMakeRect(origin.x, origin.y, size.width, size.height) operation:NSCompositeCopy fraction:1.0f];
    }
    if (_topRightCorner != nil) {
        size = [_topRightCorner size];
        [_topRightCorner drawAtPoint:NSMakePoint(aRect.origin.x + aRect.size.width, aRect.origin.y + aRect.size.height) fromRect:NSMakeRect(origin.x, origin.y, size.width, size.height) operation:NSCompositeCopy fraction:1.0f];
    }
    if (_bottomLeftCorner != nil) {
        size = [_bottomLeftCorner size];
        [_bottomLeftCorner drawAtPoint:NSMakePoint(aRect.origin.x - size.width, aRect.origin.y - size.height) fromRect:NSMakeRect(origin.x, origin.y, size.width, size.height) operation:NSCompositeCopy fraction:1.0f];
    }
    if (_bottomRightCorner != nil) {
        size = [_bottomRightCorner size];
        [_bottomRightCorner drawAtPoint:NSMakePoint(aRect.origin.x + aRect.size.width, aRect.origin.y - size.height) fromRect:NSMakeRect(origin.x, origin.y, size.width, size.height) operation:NSCompositeCopy fraction:1.0f];
    }
}

- (void)setImagePrefix:(id)aPrefix
{
    [sDAT_00342834 release];
    [sDAT_00342838 release];
    sDAT_00342834 = [[HSSharedCardBorderRenderer alloc] initRendererWithImagePrefix:aPrefix suffix:@"_on"];
    sDAT_00342838 = [[HSSharedCardBorderRenderer alloc] initRendererWithImagePrefix:aPrefix suffix:@""];
}

- (id)initSelectedRenderer
{
    return [self initRendererWithImagePrefix:@"nav_Card_" suffix:@"_on"];
}

- (id)init
{
    id pvVar1;

    pvVar1 = [self initRendererWithImagePrefix:@"nav_Card_" suffix:@""]
    ;
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008dc76 @ 0008dc76, 1076 bytes * /

id FUN_0008dc76(HSSharedCardBorderRenderer *self,SEL _cmd,id initRendererWithImagePrefix,id suffix)

{
  undefined *puVar1;
  id self_00;
  id pvVar2;
  float fVar3;
  float fVar4;
  float fVar5;
  float fVar6;
  float fVar7;
  float fVar8;
  float fVar9;
  float fVar10;
  float fVar11;
  float fVar12;
  float local_24;
  float local_20;
  HSSharedCardBorderRenderer *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_NSObject_0034ec20;
  self_00 = _objc_msgSendSuper(&local_1c,sel_init);
  if (self_00 != (id)0x0) {
    local_24 = *(float *)PTR_0033607c;
    local_20 = *(float *)(PTR_0033607c + 4);
    pvVar2 = _objc_msgSend(self_00,sel_class);
    pvVar2 = _objc_msgSend(pvVar2,sel_imageNamed_prefix_suffix_size_,&cfstr_TopCenter,
                           initRendererWithImagePrefix,suffix,&local_24);
    pvVar2 = _objc_msgSend(pvVar2,sel_retain);
    fVar4 = local_20;
    *(id *)((int)self_00 + 4) = pvVar2;
    pvVar2 = _objc_msgSend(self_00,sel_class);
    pvVar2 = _objc_msgSend(pvVar2,sel_imageNamed_prefix_suffix_size_,&cfstr_CenterRight,
                           initRendererWithImagePrefix,suffix,&local_24);
    pvVar2 = _objc_msgSend(pvVar2,sel_retain);
    fVar6 = local_24;
    *(id *)((int)self_00 + 8) = pvVar2;
    pvVar2 = _objc_msgSend(self_00,sel_class);
    pvVar2 = _objc_msgSend(pvVar2,sel_imageNamed_prefix_suffix_size_,&cfstr_BottomCenter,
                           initRendererWithImagePrefix,suffix,&local_24);
    pvVar2 = _objc_msgSend(pvVar2,sel_retain);
    fVar7 = local_20;
    *(id *)((int)self_00 + 0xc) = pvVar2;
    pvVar2 = _objc_msgSend(self_00,sel_class);
    pvVar2 = _objc_msgSend(pvVar2,sel_imageNamed_prefix_suffix_size_,&cfstr_CenterLeft,
                           initRendererWithImagePrefix,suffix,&local_24);
    pvVar2 = _objc_msgSend(pvVar2,sel_retain);
    fVar8 = local_24;
    *(id *)((int)self_00 + 0x10) = pvVar2;
    pvVar2 = _objc_msgSend(self_00,sel_class);
    pvVar2 = _objc_msgSend(pvVar2,sel_imageNamed_prefix_suffix_size_,&cfstr_TopLeft,
                           initRendererWithImagePrefix,suffix,&local_24);
    pvVar2 = _objc_msgSend(pvVar2,sel_retain);
    fVar10 = local_20;
    fVar9 = local_24;
    *(id *)((int)self_00 + 0x14) = pvVar2;
    pvVar2 = _objc_msgSend(self_00,sel_class);
    pvVar2 = _objc_msgSend(pvVar2,sel_imageNamed_prefix_suffix_size_,&cfstr_TopRight,
                           initRendererWithImagePrefix,suffix,&local_24);
    pvVar2 = _objc_msgSend(pvVar2,sel_retain);
    fVar12 = local_20;
    fVar11 = local_24;
    *(id *)((int)self_00 + 0x18) = pvVar2;
    pvVar2 = _objc_msgSend(self_00,sel_class);
    pvVar2 = _objc_msgSend(pvVar2,sel_imageNamed_prefix_suffix_size_,&cfstr_BottomLeft,
                           initRendererWithImagePrefix,suffix,&local_24);
    pvVar2 = _objc_msgSend(pvVar2,sel_retain);
    fVar5 = local_20;
    fVar3 = local_24;
    *(id *)((int)self_00 + 0x1c) = pvVar2;
    pvVar2 = _objc_msgSend(self_00,sel_class);
    pvVar2 = _objc_msgSend(pvVar2,sel_imageNamed_prefix_suffix_size_,&cfstr_BottomRight,
                           initRendererWithImagePrefix,suffix,&local_24);
    pvVar2 = _objc_msgSend(pvVar2,sel_retain);
    *(id *)((int)self_00 + 0x20) = pvVar2;
    puVar1 = PTR_00336074;
    if (fVar6 <= *(float *)PTR_00336074) {
      fVar6 = *(float *)PTR_00336074;
    }
    if (fVar8 <= fVar6) {
      fVar8 = fVar6;
    }
    if (fVar9 <= fVar8) {
      fVar9 = fVar8;
    }
    if (fVar11 <= fVar9) {
      fVar11 = fVar9;
    }
    if (fVar3 <= fVar11) {
      fVar3 = fVar11;
    }
    if (local_24 <= fVar3) {
      local_24 = fVar3;
    }
    *(float *)((int)self_00 + 0x24) = local_24;
    if (fVar4 <= *(float *)(puVar1 + 4)) {
      fVar4 = *(float *)(puVar1 + 4);
    }
    if (fVar7 <= fVar4) {
      fVar7 = fVar4;
    }
    if (fVar10 <= fVar7) {
      fVar10 = fVar7;
    }
    if (fVar12 <= fVar10) {
      fVar12 = fVar10;
    }
    if (fVar5 <= fVar12) {
      fVar5 = fVar12;
    }
    if (local_20 <= fVar5) {
      local_20 = fVar5;
    }
    *(float *)((int)self_00 + 0x28) = local_20;
  }
  return self_00;
}

*/
- (id)initRendererWithImagePrefix:(id)aPrefix suffix:(id)aSuffix
{
    NSSize size = NSZeroSize;
    CGFloat maxWidth = NSZeroPoint.x;
    CGFloat maxHeight = NSZeroPoint.y;
    self = [super init];
    if (self != nil) {
        // A missing image leaves the previous size in place, as in the original.
        _topBorder = [[[self class] imageNamed:@"TopCenter" prefix:aPrefix suffix:aSuffix size:&size] retain];
        maxHeight = MAX(maxHeight, size.height);
        _rightBorder = [[[self class] imageNamed:@"CenterRight" prefix:aPrefix suffix:aSuffix size:&size] retain];
        maxWidth = MAX(maxWidth, size.width);
        _bottomBorder = [[[self class] imageNamed:@"BottomCenter" prefix:aPrefix suffix:aSuffix size:&size] retain];
        maxHeight = MAX(maxHeight, size.height);
        _leftBorder = [[[self class] imageNamed:@"CenterLeft" prefix:aPrefix suffix:aSuffix size:&size] retain];
        maxWidth = MAX(maxWidth, size.width);
        _topLeftCorner = [[[self class] imageNamed:@"TopLeft" prefix:aPrefix suffix:aSuffix size:&size] retain];
        maxWidth = MAX(maxWidth, size.width);
        maxHeight = MAX(maxHeight, size.height);
        _topRightCorner = [[[self class] imageNamed:@"TopRight" prefix:aPrefix suffix:aSuffix size:&size] retain];
        maxWidth = MAX(maxWidth, size.width);
        maxHeight = MAX(maxHeight, size.height);
        _bottomLeftCorner = [[[self class] imageNamed:@"BottomLeft" prefix:aPrefix suffix:aSuffix size:&size] retain];
        maxWidth = MAX(maxWidth, size.width);
        maxHeight = MAX(maxHeight, size.height);
        _bottomRightCorner = [[[self class] imageNamed:@"BottomRight" prefix:aPrefix suffix:aSuffix size:&size] retain];
        maxWidth = MAX(maxWidth, size.width);
        maxHeight = MAX(maxHeight, size.height);
        _borderInset = NSMakePoint(maxWidth, maxHeight);
    }
    return self;
}

- (void)dealloc
{
    [_topBorder release];
    [_rightBorder release];
    [_bottomBorder release];
    [_leftBorder release];
    [_topLeftCorner release];
    [_topRightCorner release];
    [_bottomLeftCorner release];
    [_bottomRightCorner release];
    [super dealloc];
}

@end

@implementation HSCardBorderRenderer

/* i386 ivar offsets: _thumbnailSize=0x4, _borderImage=0xc, _selectedBorderImage=0x10, _fillColor=0x14 */

+ (id)defaultFillColor
{
    return [NSColor orangeColor];
}

+ (NSPoint)selectedBorderInsetForCardThumbnailSize:(NSSize)aSize
{
    return [[[[HSCardBorderRenderer alloc] initWithThumbnailSize:aSize] autorelease] selectedBorderInset];
}

+ (NSPoint)borderInsetForCardThumbnailSize:(NSSize)aSize
{
    return [[[[HSCardBorderRenderer alloc] initWithThumbnailSize:aSize] autorelease] borderInset];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008c55d @ 0008c55d, 152 bytes * /

id FUN_0008c55d(id self,SEL _cmd,id selectedBorderedThumbnailWithCardThumbnail,NSPoint *inset)

{
  id pvVar1;
  id pvVar2;
  undefined4 extraout_EDX;
  
  pvVar1 = _objc_msgSend(cls_HSCardBorderRenderer,sel_alloc);
  pvVar2 = _objc_msgSend(selectedBorderedThumbnailWithCardThumbnail,sel_size);
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithThumbnailSize_,pvVar2,extraout_EDX);
  pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  pvVar1 = _objc_msgSend(pvVar1,sel_selectedBorderedThumbnailWithCardThumbnail_isHighlighted_inset_,
                         selectedBorderedThumbnailWithCardThumbnail,0,inset);
  return pvVar1;
}

*/
+ (id)selectedBorderedThumbnailWithCardThumbnail:(id)aThumbnail inset:(NSPoint *)aInset
{
    return [[[[HSCardBorderRenderer alloc] initWithThumbnailSize:[(NSImage *)aThumbnail size]] autorelease] selectedBorderedThumbnailWithCardThumbnail:aThumbnail isHighlighted:NO inset:aInset];
}

+ (id)selectedBorderedThumbnailWithCardThumbnail:(id)aThumbnail
{
    return [self selectedBorderedThumbnailWithCardThumbnail:aThumbnail inset:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008c62a @ 0008c62a, 152 bytes * /

id FUN_0008c62a(id self,SEL _cmd,id borderedThumbnailWithCardThumbnail,NSPoint *inset)

{
  id pvVar1;
  id pvVar2;
  undefined4 extraout_EDX;
  
  pvVar1 = _objc_msgSend(cls_HSCardBorderRenderer,sel_alloc);
  pvVar2 = _objc_msgSend(borderedThumbnailWithCardThumbnail,sel_size);
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithThumbnailSize_,pvVar2,extraout_EDX);
  pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  pvVar1 = _objc_msgSend(pvVar1,sel_borderedThumbnailWithCardThumbnail_isHighlighted_inset_,
                         borderedThumbnailWithCardThumbnail,0,inset);
  return pvVar1;
}

*/
+ (id)borderedThumbnailWithCardThumbnail:(id)aThumbnail inset:(NSPoint *)aInset
{
    return [[[[HSCardBorderRenderer alloc] initWithThumbnailSize:[(NSImage *)aThumbnail size]] autorelease] borderedThumbnailWithCardThumbnail:aThumbnail isHighlighted:NO inset:aInset];
}

+ (id)borderedThumbnailWithCardThumbnail:(id)aThumbnail
{
    return [self borderedThumbnailWithCardThumbnail:aThumbnail inset:nil];
}

- (void)setFillColor:(id)aColor
{
    if (_fillColor != aColor) {
        [_fillColor release];
        _fillColor = [aColor retain];
    }
}

- (id)fillColor
{
    id pvVar1;

    pvVar1 = _fillColor;
    if (pvVar1 == nil) {
        [self setFillColor:[[self class] defaultFillColor]];
        pvVar1 = _fillColor;
    }
    return pvVar1;
}

- (id)selectedBorderedThumbnailWithCardThumbnail:(id)aThumbnail isHighlighted:(BOOL)aHighlighted inset:(NSPoint *)aInset
{
    id pvVar1;

    pvVar1 = [HSSharedCardBorderRenderer selectedBorderRenderer];
    return [self borderedThumbnailWithBorderImage:[self selectedBorderImage] cardImage:aThumbnail renderer:pvVar1 isHighlighted:(unsigned int)aHighlighted inset:aInset];
}

- (id)borderedThumbnailWithCardThumbnail:(id)aThumbnail isHighlighted:(BOOL)aHighlighted inset:(NSPoint *)aInset
{
    id pvVar1;

    pvVar1 = [HSSharedCardBorderRenderer borderRenderer];
    return [self borderedThumbnailWithBorderImage:[self borderImage] cardImage:aThumbnail renderer:pvVar1 isHighlighted:(unsigned int)aHighlighted inset:aInset];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008c88a @ 0008c88a, 680 bytes * /

id FUN_0008c88a(HSCardBorderRenderer *self,SEL _cmd,id borderedThumbnailWithBorderImage,id cardImage
               ,id renderer,BOOL isHighlighted,NSPoint *inset)

{
  float fVar1;
  float fVar2;
  undefined8 uVar3;
  undefined *puVar4;
  undefined *puVar5;
  char cVar6;
  id pvVar7;
  id pvVar8;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  undefined4 extraout_EDX_01;
  undefined8 uVar9;
  undefined8 uVar10;
  undefined8 local_3c;
  undefined8 local_34;
  
  puVar5 = PTR_00336078;
  puVar4 = PTR_00336074;
  uVar3 = *(undefined8 *)PTR_00336078;
  fVar1 = *(float *)PTR_00336074;
  fVar2 = *(float *)(PTR_00336074 + 4);
  uVar10 = *(undefined8 *)PTR_00336074;
  pvVar7 = _objc_msgSend(self,sel_imageSizeWithBorderRenderer_thumbnailInset_);
  uVar9 = CONCAT44(extraout_EDX,pvVar7);
  _NSInsetRect();
  cVar6 = _NSIsEmptyRect(uVar3,CONCAT44(extraout_EDX,pvVar7),uVar9,uVar10);
  if (cVar6 == '\0') {
    pvVar8 = _objc_msgSend(cls_NSImage,sel_alloc);
    pvVar7 = _objc_msgSend(pvVar8,sel_initWithSize_,pvVar7,extraout_EDX);
    uVar10 = *(undefined8 *)puVar5;
    uVar9 = *(undefined8 *)puVar5;
    pvVar7 = _objc_msgSend(pvVar7,sel_autorelease);
    _objc_msgSend(pvVar7,sel_lockFocus);
    pvVar8 = _objc_msgSend(cardImage,sel_size);
    _objc_msgSend(cardImage,sel_drawInRect_fromRect_operation_fraction_,local_3c,local_34,uVar9,
                  CONCAT44(extraout_EDX_00,pvVar8),1,
                  *(undefined4 *)(&DAT_00334ed0 + (uint)(isHighlighted == '\0') * 4));
    pvVar8 = _objc_msgSend(borderedThumbnailWithBorderImage,sel_size);
    _objc_msgSend(borderedThumbnailWithBorderImage,sel_drawAtPoint_fromRect_operation_fraction_,
                  *(undefined4 *)puVar4,*(undefined4 *)(puVar4 + 4),uVar10,
                  CONCAT44(extraout_EDX_01,pvVar8),2,0x3f800000);
    _objc_msgSend(pvVar7,sel_unlockFocus);
  }
  else {
    pvVar7 = (id)0x0;
  }
  if (inset != (NSPoint *)0x0) {
    inset->x = fVar1;
    inset->y = fVar2;
  }
  return pvVar7;
}

*/
- (id)borderedThumbnailWithBorderImage:(id)aImage cardImage:(id)aImage2 renderer:(id)aRenderer isHighlighted:(BOOL)aHighlighted inset:(NSPoint *)aInset
{
    NSPoint origin = NSZeroRect.origin;
    NSPoint inset = NSZeroPoint;
    NSSize imageSize = [self imageSizeWithBorderRenderer:aRenderer thumbnailInset:&inset];
    NSRect imageRect = NSMakeRect(origin.x, origin.y, imageSize.width, imageSize.height);
    NSRect cardRect = NSInsetRect(imageRect, inset.x, inset.y);
    NSImage *image = nil;
    NSSize size;
    if (!NSIsEmptyRect(imageRect)) {
        image = [[[NSImage alloc] initWithSize:imageSize] autorelease];
        [image lockFocus];
        size = [(NSImage *)aImage2 size];
        [aImage2 drawInRect:cardRect fromRect:NSMakeRect(origin.x, origin.y, size.width, size.height) operation:NSCompositeCopy fraction:aHighlighted ? 0.7f : 1.0f];
        size = [(NSImage *)aImage size];
        [aImage drawAtPoint:NSZeroPoint fromRect:NSMakeRect(origin.x, origin.y, size.width, size.height) operation:NSCompositeSourceOver fraction:1.0f];
        [image unlockFocus];
    }
    if (aInset != NULL) {
        *aInset = inset;
    }
    return image;
}

- (id)selectedBorderImage
{
    id pvVar1;

    pvVar1 = _selectedBorderImage;
    if (pvVar1 == nil) {
        pvVar1 = [[self imageWithBorderRenderer:[HSSharedCardBorderRenderer selectedBorderRenderer]] retain];
        _selectedBorderImage = pvVar1;
    }
    return pvVar1;
}

- (id)borderImage
{
    id pvVar1;

    pvVar1 = _borderImage;
    if (pvVar1 == nil) {
        pvVar1 = [[self imageWithBorderRenderer:[HSSharedCardBorderRenderer borderRenderer]] retain];
        _borderImage = pvVar1;
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008cbf6 @ 0008cbf6, 453 bytes * /

id FUN_0008cbf6(HSCardBorderRenderer *self,SEL _cmd,id imageWithBorderRenderer)

{
  char cVar1;
  id pvVar2;
  undefined4 extraout_EDX;
  undefined4 local_34;
  undefined4 uStack_30;
  float local_2c;
  float fStack_28;
  undefined4 local_24;
  undefined4 uStack_20;
  id local_1c;
  undefined4 uStack_18;
  
  local_24 = *(undefined4 *)PTR_00336078;
  uStack_20 = *(undefined4 *)(PTR_00336078 + 4);
  local_1c = *(id *)(PTR_00336078 + 8);
  uStack_18 = *(undefined4 *)(PTR_00336078 + 0xc);
  local_2c = (self->_thumbnailSize).width;
  fStack_28 = (self->_thumbnailSize).height;
  local_34 = *(undefined4 *)PTR_00336074;
  uStack_30 = *(undefined4 *)(PTR_00336074 + 4);
  local_1c = _objc_msgSend(self,sel_imageSizeWithBorderRenderer_thumbnailInset_,
                           imageWithBorderRenderer,&local_34);
  uStack_18 = extraout_EDX;
  cVar1 = _NSIsEmptyRect(CONCAT44(uStack_20,local_24),CONCAT44(extraout_EDX,local_1c));
  if (cVar1 == '\0') {
    pvVar2 = _objc_msgSend(cls_NSImage,sel_alloc);
    pvVar2 = _objc_msgSend(pvVar2,sel_initWithSize_,local_1c,uStack_18);
    pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
    _objc_msgSend(pvVar2,sel_lockFocus);
    _NSRectFillUsingOperation(CONCAT44(uStack_20,local_24),CONCAT44(uStack_18,local_1c),0);
    _objc_msgSend(self,sel_drawSemiTransparentCardBorderInRect_wholeImageRect_,
                  CONCAT44(uStack_30,local_34),CONCAT44(fStack_28,local_2c),
                  CONCAT44(uStack_20,local_24),CONCAT44(uStack_18,local_1c));
    _objc_msgSend(imageWithBorderRenderer,sel_renderAroundRect_,CONCAT44(uStack_30,local_34),
                  CONCAT44(fStack_28,local_2c));
    _objc_msgSend(pvVar2,sel_unlockFocus);
  }
  else {
    pvVar2 = (id)0x0;
  }
  return pvVar2;
}

*/
- (id)imageWithBorderRenderer:(id)aRenderer
{
    NSPoint origin = NSZeroRect.origin;
    NSRect thumbnailRect;
    NSSize imageSize;
    NSRect imageRect;
    NSImage *image;
    thumbnailRect.origin = NSZeroPoint;
    thumbnailRect.size = _thumbnailSize;
    imageSize = [self imageSizeWithBorderRenderer:aRenderer thumbnailInset:&thumbnailRect.origin];
    imageRect = NSMakeRect(origin.x, origin.y, imageSize.width, imageSize.height);
    if (NSIsEmptyRect(imageRect)) {
        return nil;
    }
    image = [[[NSImage alloc] initWithSize:imageSize] autorelease];
    [image lockFocus];
    NSRectFillUsingOperation(imageRect, NSCompositeClear);
    [self drawSemiTransparentCardBorderInRect:thumbnailRect wholeImageRect:imageRect];
    [aRenderer renderAroundRect:thumbnailRect];
    [image unlockFocus];
    return image;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008cdbb @ 0008cdbb, 705 bytes * /

void FUN_0008cdbb(HSCardBorderRenderer *self,SEL _cmd,NSRect drawSemiTransparentCardBorderInRect,
                 NSRect wholeImageRect)

{
  char cVar1;
  id pvVar2;
  
  cVar1 = _NSIsEmptyRect(drawSemiTransparentCardBorderInRect.origin.x,
                         drawSemiTransparentCardBorderInRect.origin.y,
                         drawSemiTransparentCardBorderInRect.size.width,
                         drawSemiTransparentCardBorderInRect.size.height);
  if (cVar1 == '\0') {
    _objc_msgSend(cls_NSGraphicsContext,sel_saveGraphicsState);
    _objc_msgSend(cls_NSBezierPath,sel_clipRect_,drawSemiTransparentCardBorderInRect.origin.x,
                  drawSemiTransparentCardBorderInRect.origin.y,
                  drawSemiTransparentCardBorderInRect.size.width,
                  drawSemiTransparentCardBorderInRect.size.height);
    _NSInsetRect(&drawSemiTransparentCardBorderInRect,drawSemiTransparentCardBorderInRect.origin.x,
                 drawSemiTransparentCardBorderInRect.origin.y,
                 drawSemiTransparentCardBorderInRect.size.width,
                 drawSemiTransparentCardBorderInRect.size.height,0x3f800000,0x3f800000);
    pvVar2 = _objc_msgSend(cls_NSBezierPath,sel_bezierPathWithRect_,wholeImageRect.origin.x,
                           wholeImageRect.origin.y,
                           drawSemiTransparentCardBorderInRect.origin.x - wholeImageRect.origin.x,
                           wholeImageRect.size.height);
    _objc_msgSend(pvVar2,sel_appendBezierPathWithRect_,
                  drawSemiTransparentCardBorderInRect.origin.x +
                  drawSemiTransparentCardBorderInRect.size.width,wholeImageRect.origin.y,
                  (wholeImageRect.origin.x + wholeImageRect.size.width) -
                  (drawSemiTransparentCardBorderInRect.origin.x +
                  drawSemiTransparentCardBorderInRect.size.width),wholeImageRect.size.height);
    _objc_msgSend(pvVar2,sel_appendBezierPathWithRect_,wholeImageRect.origin.x,
                  wholeImageRect.origin.y,wholeImageRect.size.width,
                  drawSemiTransparentCardBorderInRect.origin.y - wholeImageRect.origin.y);
    _objc_msgSend(pvVar2,sel_appendBezierPathWithRect_,wholeImageRect.origin.x,
                  drawSemiTransparentCardBorderInRect.origin.y +
                  drawSemiTransparentCardBorderInRect.size.height,wholeImageRect.size.width,
                  (wholeImageRect.origin.y + wholeImageRect.size.height) -
                  (drawSemiTransparentCardBorderInRect.origin.y +
                  drawSemiTransparentCardBorderInRect.size.height));
    _objc_msgSend(pvVar2,sel_addClip);
    pvVar2 = _objc_msgSend(cls_NSColor,sel_blackColor);
    pvVar2 = _objc_msgSend(pvVar2,sel_colorWithAlphaComponent_,0x3e800000);
    _objc_msgSend(pvVar2,sel_set);
    _objc_msgSend(cls_NSBezierPath,sel_fillRect_,wholeImageRect.origin.x,wholeImageRect.origin.y,
                  wholeImageRect.size.width,wholeImageRect.size.height);
    _objc_msgSend(cls_NSGraphicsContext,sel_restoreGraphicsState);
  }
  return;
}

*/
- (void)drawSemiTransparentCardBorderInRect:(NSRect)aRect wholeImageRect:(NSRect)aRect2
{
    NSBezierPath *path;
    if (NSIsEmptyRect(aRect)) {
        return;
    }
    [NSGraphicsContext saveGraphicsState];
    [NSBezierPath clipRect:aRect];
    aRect = NSInsetRect(aRect, 1.0f, 1.0f);
    path = [NSBezierPath bezierPathWithRect:NSMakeRect(aRect2.origin.x, aRect2.origin.y, aRect.origin.x - aRect2.origin.x, aRect2.size.height)];
    [path appendBezierPathWithRect:NSMakeRect(aRect.origin.x + aRect.size.width, aRect2.origin.y, (aRect2.origin.x + aRect2.size.width) - (aRect.origin.x + aRect.size.width), aRect2.size.height)];
    [path appendBezierPathWithRect:NSMakeRect(aRect2.origin.x, aRect2.origin.y, aRect2.size.width, aRect.origin.y - aRect2.origin.y)];
    [path appendBezierPathWithRect:NSMakeRect(aRect2.origin.x, aRect.origin.y + aRect.size.height, aRect2.size.width, (aRect2.origin.y + aRect2.size.height) - (aRect.origin.y + aRect.size.height))];
    [path addClip];
    [[[NSColor blackColor] colorWithAlphaComponent:0.25f] set];
    [NSBezierPath fillRect:aRect2];
    [NSGraphicsContext restoreGraphicsState];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008d07c @ 0008d07c, 200 bytes * /

ulonglong FUN_0008d07c(HSCardBorderRenderer *self,SEL _cmd,id imageSizeWithBorderRenderer,
                      NSPoint *thumbnailInset)

{
  id pvVar1;
  float extraout_EDX;
  undefined4 local_1c;
  undefined4 uStack_18;
  float local_14;
  float fStack_10;
  
  local_14 = (self->_thumbnailSize).width;
  fStack_10 = (self->_thumbnailSize).height;
  local_1c = *(undefined4 *)PTR_00336074;
  uStack_18 = *(undefined4 *)(PTR_00336074 + 4);
  pvVar1 = _objc_msgSend(imageSizeWithBorderRenderer,sel_inset);
  _NSInsetRect(&local_1c,CONCAT44(uStack_18,local_1c),CONCAT44(fStack_10,local_14),
               (uint)pvVar1 ^ 0x80000000,-extraout_EDX);
  if (thumbnailInset != (NSPoint *)0x0) {
    thumbnailInset->x = (float)pvVar1;
    thumbnailInset->y = extraout_EDX;
  }
  return CONCAT44(fStack_10,local_14);
}

*/
- (NSSize)imageSizeWithBorderRenderer:(id)aRenderer thumbnailInset:(NSPoint *)aInset
{
    NSRect rect;
    NSPoint inset;
    rect.origin = NSZeroPoint;
    rect.size = _thumbnailSize;
    inset = [(HSSharedCardBorderRenderer *)aRenderer inset];
    rect = NSInsetRect(rect, -inset.x, -inset.y);
    if (aInset != NULL) {
        *aInset = inset;
    }
    return rect.size;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008d144 @ 0008d144, 61 bytes * /

ulonglong FUN_0008d144(HSCardBorderRenderer *self,SEL _cmd)

{
  id pvVar1;
  undefined4 extraout_EDX;
  
  pvVar1 = _objc_msgSend(cls_HSSharedCardBorderRenderer,sel_selectedBorderRenderer);
  pvVar1 = _objc_msgSend(pvVar1,sel_inset);
  return CONCAT44(extraout_EDX,pvVar1);
}

*/
- (NSPoint)selectedBorderInset
{
    return [(HSSharedCardBorderRenderer *)[HSSharedCardBorderRenderer selectedBorderRenderer] inset];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008d181 @ 0008d181, 61 bytes * /

ulonglong FUN_0008d181(HSCardBorderRenderer *self,SEL _cmd)

{
  id pvVar1;
  undefined4 extraout_EDX;
  
  pvVar1 = _objc_msgSend(cls_HSSharedCardBorderRenderer,sel_borderRenderer);
  pvVar1 = _objc_msgSend(pvVar1,sel_inset);
  return CONCAT44(extraout_EDX,pvVar1);
}

*/
- (NSPoint)borderInset
{
    return [(HSSharedCardBorderRenderer *)[HSSharedCardBorderRenderer borderRenderer] inset];
}

- (void)setCardBorderRendererType:(id)aType
{
    [[HSSharedCardBorderRenderer borderRenderer] setImagePrefix:aType];
}

- (void)setBorderedThumbnailSize:(NSSize)aSize
{

}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008c3d8 @ 0008c3d8, 14 bytes * /

ulonglong FUN_0008c3d8(HSCardBorderRenderer *self,SEL _cmd)

{
  ulonglong uVar1;
  
  uVar1._0_4_ = (self->_thumbnailSize).width;
  uVar1._4_4_ = (self->_thumbnailSize).height;
  return uVar1;
}

*/
- (NSSize)thumbnailSize
{
    return _thumbnailSize;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008d202 @ 0008d202, 294 bytes * /

void FUN_0008d202(HSCardBorderRenderer *self,SEL _cmd,NSSize setThumbnailSize)

{
  float fVar1;
  float fVar2;
  float fVar3;
  float fVar4;
  
  fVar2 = (self->_thumbnailSize).width;
  fVar1 = (self->_thumbnailSize).height;
  if ((fVar2 != 0.0) || (NAN(fVar2))) {
    fVar3 = ABS(fVar2);
  }
  else {
    fVar3 = 1.0;
  }
  if ((setThumbnailSize.width != 0.0) || (NAN(setThumbnailSize.width))) {
    fVar4 = ABS(setThumbnailSize.width);
  }
  else {
    fVar4 = 1.0;
  }
  if (fVar4 <= fVar3) {
    fVar4 = fVar3;
  }
  if (ABS(fVar2 - setThumbnailSize.width) <= fVar4 * 0.0005) {
    if ((fVar1 != 0.0) || (NAN(fVar1))) {
      fVar2 = ABS(fVar1);
    }
    else {
      fVar2 = 1.0;
    }
    if ((setThumbnailSize.height != 0.0) || (NAN(setThumbnailSize.height))) {
      fVar3 = ABS(setThumbnailSize.height);
    }
    else {
      fVar3 = 1.0;
    }
    if (fVar3 <= fVar2) {
      fVar3 = fVar2;
    }
    if (ABS(fVar1 - setThumbnailSize.height) <= fVar3 * 0.0005) {
      return;
    }
  }
  (self->_thumbnailSize).width = setThumbnailSize.width;
  (self->_thumbnailSize).height = setThumbnailSize.height;
  _objc_msgSend(self->_borderImage,sel_release);
  self->_borderImage = (id)0x0;
  _objc_msgSend(self->_selectedBorderImage,sel_release);
  self->_selectedBorderImage = (id)0x0;
  return;
}

*/
- (void)setThumbnailSize:(NSSize)aSize
{
    if (HSCardBorderFloatsAreEqual(_thumbnailSize.width, aSize.width) && HSCardBorderFloatsAreEqual(_thumbnailSize.height, aSize.height)) {
        return;
    }
    _thumbnailSize = aSize;
    [_borderImage release];
    _borderImage = nil;
    [_selectedBorderImage release];
    _selectedBorderImage = nil;
}

- (void)dealloc
{
    [_borderImage release];
    [_selectedBorderImage release];
    [_fillColor release];
    [super dealloc];
}

- (id)init
{
    return [self initWithThumbnailSize:NSZeroSize];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008c3f9 @ 0008c3f9, 77 bytes * /

id FUN_0008c3f9(HSCardBorderRenderer *self,SEL _cmd,NSSize initWithThumbnailSize)

{
  id pvVar1;
  HSCardBorderRenderer *local_c;
  undefined *local_8;
  
  local_c = self;
  local_8 = PTR_s_NSObject_0034ebf0;
  pvVar1 = _objc_msgSendSuper(&local_c,sel_init);
  if (pvVar1 != (id)0x0) {
    *(float *)((int)pvVar1 + 4) = initWithThumbnailSize.width;
    *(float *)((int)pvVar1 + 8) = initWithThumbnailSize.height;
  }
  return pvVar1;
}

*/
- (id)initWithThumbnailSize:(NSSize)aSize
{
    self = [super init];
    if (self != nil) {
        _thumbnailSize = aSize;
    }
    return self;
}

@end

