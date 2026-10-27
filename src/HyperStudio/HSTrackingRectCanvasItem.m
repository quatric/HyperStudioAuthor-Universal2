#import "HSTrackingRectCanvasItem.h"
static id sDAT_0034289c;
static id sDAT_003428a4;

static id sDAT_0034289c;
static id sDAT_003428a4;


@implementation HSTrackingRectCanvasItem

/* i386 ivar offsets: _rect=0x4, _startingPoint=0x14, _cachedRegion=0x1c, _drawsOutlineOnly=0x20 */

+ (void)systemColorsDidChange:(id)aChange
{
    [sDAT_0034289c release];
    sDAT_0034289c = nil;
    [sDAT_003428a4 release];
    sDAT_003428a4 = nil;
}

+ (id)trackingRectFillColor
{
    if (sDAT_003428a4 == nil) {
        sDAT_003428a4 = [[[self trackingRectColor] colorWithAlphaComponent:0.2] retain];
    }
    return sDAT_003428a4;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00095ebc @ 00095ebc, 215 bytes * /

id FUN_00095ebc(id self,SEL _cmd)

{
  id pvVar1;
  undefined4 uVar2;
  
  if (DAT_0034289c == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSColor,sel_selectedControlColor);
    uVar2 = *(undefined4 *)PTR_00336350;
    pvVar1 = _objc_msgSend(pvVar1,sel_colorUsingColorSpaceName_,uVar2);
    DAT_0034289c = _objc_msgSend(pvVar1,sel_retain);
    if (DAT_003428a0 == '\0') {
      pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter,uVar2);
      _objc_msgSend(pvVar1,sel_addObserver_selector_name_object_,self,sel_systemColorsDidChange_,
                    *(undefined4 *)PTR_00336434,0);
      DAT_003428a0 = '\x01';
    }
  }
  return DAT_0034289c;
}

*/
+ (id)trackingRectColor
{
    if (sDAT_0034289c == nil) {
        sDAT_0034289c = [[[NSColor selectedControlColor] colorUsingColorSpaceName:NSCalibratedRGBColorSpace] retain];
        static BOOL sObserving = NO;
        if (!sObserving) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(systemColorsDidChange:) name:NSSystemColorsDidChangeNotification object:nil];
            sObserving = YES;
        }
    }
    return sDAT_0034289c;
}

+ (id)trackingRectCanvasItemWithStartingPoint:(NSPoint)aPoint
{
    return [[[self alloc] initWithStartingPoint:aPoint] autorelease];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00095ff5 @ 00095ff5, 205 bytes * /

id FUN_00095ff5(HSTrackingRectCanvasItem *self,SEL _cmd)

{
  NSRect *pNVar1;
  char cVar2;
  id pvVar3;
  SEL op;
  NSSize NVar4;
  
  pvVar3 = self->_cachedRegion;
  if (pvVar3 == (id)0x0) {
    NVar4 = (self->_rect).size;
    cVar2 = _NSIsEmptyRect((self->_rect).origin,NVar4);
    op = sel_region;
    if (cVar2 == '\0') {
      pNVar1 = &self->_rect;
      if (self->_drawsOutlineOnly == '\0') {
        NVar4.width = (pNVar1->origin).x;
        NVar4.height = (pNVar1->origin).y;
        op = sel_regionWithRect_;
      }
      else {
        NVar4.width = (pNVar1->origin).x;
        NVar4.height = (pNVar1->origin).y;
        op = sel_regionWithRectOutline_strokeThickness_;
      }
    }
    pvVar3 = _objc_msgSend(cls_HSRegion,op,NVar4);
    pvVar3 = _objc_msgSend(pvVar3,sel_retain);
    self->_cachedRegion = pvVar3;
  }
  return pvVar3;
}

*/
- (id)cachedRegion
{
    if (_cachedRegion == nil) {
        if (NSIsEmptyRect(_rect)) {
            _cachedRegion = [[HSRegion region] retain];
        } else if (_drawsOutlineOnly) {
            _cachedRegion = [[HSRegion regionWithRectOutline:_rect strokeThickness:1.0] retain];
        } else {
            _cachedRegion = [[HSRegion regionWithRect:_rect] retain];
        }
    }
    return _cachedRegion;
}

- (BOOL)updateIfNeededInCanvasLayer:(id)aLayer
{
    return NO;
}

- (id)renderingRegionInCanvasLayer:(id)aLayer
{
    return [self cachedRegion];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000960e8 @ 000960e8, 195 bytes * /

NSRect * FUN_000960e8(NSRect *__return_storage_ptr__,HSTrackingRectCanvasItem *self,SEL _cmd,
                     id renderingBoundsInCanvasLayer)

{
  NSPoint NVar1;
  NSSize NVar2;
  char cVar3;
  float local_1c;
  float local_18;
  float local_14;
  float local_10;
  
  local_1c = *(float *)PTR_00336078;
  local_18 = *(float *)(PTR_00336078 + 4);
  local_14 = *(float *)(PTR_00336078 + 8);
  local_10 = *(float *)(PTR_00336078 + 0xc);
  NVar1 = (self->_rect).origin;
  NVar2 = (self->_rect).size;
  cVar3 = _NSIsEmptyRect(NVar1.x,NVar1.y,NVar2.width,NVar2.height);
  if (cVar3 == '\0') {
    NVar1 = (self->_rect).origin;
    NVar2 = (self->_rect).size;
    _NSInsetRect(&local_1c,NVar1.x,NVar1.y,NVar2.width,NVar2.height,0xbf800000,0xbf800000);
  }
  (__return_storage_ptr__->origin).x = local_1c;
  (__return_storage_ptr__->origin).y = local_18;
  (__return_storage_ptr__->size).width = local_14;
  (__return_storage_ptr__->size).height = local_10;
  return __return_storage_ptr__;
}

*/
- (NSRect)renderingBoundsInCanvasLayer:(id)aLayer
{
    NSRect bounds = NSZeroRect;
    if (!NSIsEmptyRect(_rect)) {
        bounds = NSInsetRect(_rect, -1.0, -1.0);
    }
    return bounds;
}

- (BOOL)prefersRegionInvalidation
{
    return _drawsOutlineOnly != NO;
}

- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inCanvasLayer:(id)aLayer
{
    return nil;
}

- (BOOL)hitTestPoint:(NSPoint)aPoint inCanvasLayer:(id)aLayer
{
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000961ab @ 000961ab, 243 bytes * /

void FUN_000961ab(HSTrackingRectCanvasItem *self,SEL _cmd,NSRect renderRect,id inCanvasLayer,
                 BOOL isActive)

{
  char cVar1;
  id pvVar2;
  
  cVar1 = _NSIsEmptyRect((self->_rect).origin,(self->_rect).size);
  if (cVar1 == '\0') {
    if (self->_drawsOutlineOnly == '\0') {
      pvVar2 = _objc_msgSend(self,sel_class);
      pvVar2 = _objc_msgSend(pvVar2,sel_trackingRectFillColor);
      _objc_msgSend(pvVar2,sel_set);
      _NSRectFillUsingOperation((self->_rect).origin,(self->_rect).size,2);
    }
    pvVar2 = _objc_msgSend(self,sel_class);
    pvVar2 = _objc_msgSend(pvVar2,sel_trackingRectColor);
    _objc_msgSend(pvVar2,sel_set);
    _NSFrameRectWithWidth((self->_rect).origin,(self->_rect).size,0x3f800000);
  }
  return;
}

*/
- (void)renderRect:(NSRect)aRect inCanvasLayer:(id)aLayer isActive:(BOOL)aActive
{
    if (!NSIsEmptyRect(_rect)) {
        if (!_drawsOutlineOnly) {
            [[[self class] trackingRectFillColor] set];
            NSRectFillUsingOperation(_rect, NSCompositingOperationSourceOver);
        }
        [[[self class] trackingRectColor] set];
        NSFrameRectWithWidth(_rect, 1.0);
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0009629e @ 0009629e, 97 bytes * /

void FUN_0009629e(HSTrackingRectCanvasItem *self,SEL _cmd,BOOL setDrawsOutlineOnly)

{
  char cVar1;
  
  if ((bool)self->_drawsOutlineOnly != (setDrawsOutlineOnly != '\0')) {
    self->_drawsOutlineOnly = setDrawsOutlineOnly != '\0';
    cVar1 = _NSIsEmptyRect((self->_rect).origin,(self->_rect).size);
    if (cVar1 == '\0') {
      _objc_msgSend(self->_cachedRegion,sel_release);
      self->_cachedRegion = (id)0x0;
    }
  }
  return;
}

*/
- (void)setDrawsOutlineOnly:(BOOL)aOnly
{
    if (_drawsOutlineOnly != (aOnly != NO)) {
        _drawsOutlineOnly = aOnly != NO;
        if (!NSIsEmptyRect(_rect)) {
            [_cachedRegion release];
            _cachedRegion = nil;
        }
    }
}

- (BOOL)drawsOutlineOnly
{
    return _drawsOutlineOnly;
}

- (void)updateWithEndPoint:(NSPoint)aPoint inParentLayer:(id)aLayer
{
    [self setRect:[self rectForUpdatingWithEndPoint:aPoint inParentLayer:aLayer] inParentLayer:aLayer];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0009637e @ 0009637e, 67 bytes * /

void FUN_0009637e(HSTrackingRectCanvasItem *self,SEL _cmd,NSRect updateWithRect,id inParentLayer)

{
  _objc_msgSend(self,sel_setRect_inParentLayer_,updateWithRect.origin,updateWithRect.size,
                inParentLayer);
  return;
}

*/
- (void)updateWithRect:(NSRect)aRect inParentLayer:(id)aLayer
{
    [self setRect:aRect inParentLayer:aLayer];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00095d19 @ 00095d19, 94 bytes * /

NSRect * FUN_00095d19(NSRect *__return_storage_ptr__,HSTrackingRectCanvasItem *self,SEL _cmd,
                     NSPoint rectForUpdatingWithEndPoint,id inParentLayer)

{
  float fVar1;
  float fVar2;
  float fVar3;
  
  fVar1 = (self->_startingPoint).x;
  fVar2 = (self->_startingPoint).y;
  fVar3 = fVar1;
  if (rectForUpdatingWithEndPoint.x <= fVar1) {
    fVar3 = rectForUpdatingWithEndPoint.x;
  }
  (__return_storage_ptr__->origin).x = fVar3;
  fVar3 = fVar2;
  if (rectForUpdatingWithEndPoint.y <= fVar2) {
    fVar3 = rectForUpdatingWithEndPoint.y;
  }
  (__return_storage_ptr__->origin).y = fVar3;
  (__return_storage_ptr__->size).width = ABS(fVar1 - rectForUpdatingWithEndPoint.x);
  (__return_storage_ptr__->size).height = ABS(fVar2 - rectForUpdatingWithEndPoint.y);
  return (NSRect *)0x95d21;
}

*/
- (NSRect)rectForUpdatingWithEndPoint:(NSPoint)aPoint inParentLayer:(id)aLayer
{
    return NSMakeRect(MIN(_startingPoint.x, aPoint.x), MIN(_startingPoint.y, aPoint.y), fabs(_startingPoint.x - aPoint.x), fabs(_startingPoint.y - aPoint.y));
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000963c1 @ 000963c1, 562 bytes * /

void FUN_000963c1(HSTrackingRectCanvasItem *self,SEL _cmd,NSRect setRect,id inParentLayer)

{
  float fVar1;
  float fVar2;
  float fVar3;
  float fVar4;
  char cVar5;
  float fVar6;
  float fVar7;
  float fVar8;
  float fVar9;
  
  fVar1 = (self->_rect).origin.y;
  fVar2 = (self->_rect).size.height;
  fVar6 = ABS(fVar1) + fVar2;
  fVar9 = ABS(setRect.origin.y) + setRect.size.height;
  if ((fVar9 != 0.0) || (NAN(fVar9))) {
    fVar9 = ABS(fVar9);
  }
  else {
    fVar9 = 1.0;
  }
  if ((fVar6 != 0.0) || (NAN(fVar6))) {
    fVar6 = ABS(fVar6);
  }
  else {
    fVar6 = 1.0;
  }
  fVar3 = (self->_rect).origin.x;
  fVar4 = (self->_rect).size.width;
  fVar8 = ABS(fVar3) + fVar4;
  fVar7 = ABS(setRect.origin.x) + setRect.size.width;
  if (fVar6 <= fVar9) {
    fVar6 = fVar9;
  }
  if ((fVar7 != 0.0) || (NAN(fVar7))) {
    fVar7 = ABS(fVar7);
  }
  else {
    fVar7 = 1.0;
  }
  if ((fVar8 != 0.0) || (NAN(fVar8))) {
    fVar8 = ABS(fVar8);
  }
  else {
    fVar8 = 1.0;
  }
  if (fVar8 <= fVar7) {
    fVar8 = fVar7;
  }
  if ((((fVar8 * 0.0005 < ABS(setRect.origin.x - fVar3)) ||
       (fVar6 * 0.0005 < ABS(setRect.origin.y - fVar1))) ||
      (fVar8 * 0.0005 < ABS(setRect.size.width - fVar4))) ||
     (fVar6 * 0.0005 < ABS(setRect.size.height - fVar2))) {
    cVar5 = _NSIsEmptyRect(setRect.origin,setRect.size);
    if ((cVar5 != '\0') &&
       (cVar5 = _NSIsEmptyRect((self->_rect).origin,(self->_rect).size), cVar5 != '\0')) {
      (self->_rect).origin.x = setRect.origin.x;
      (self->_rect).origin.y = setRect.origin.y;
      (self->_rect).size.width = setRect.size.width;
      (self->_rect).size.height = setRect.size.height;
      return;
    }
    _objc_msgSend(inParentLayer,sel_invalidateDisplayForCanvasItem_,self);
    (self->_rect).origin.x = setRect.origin.x;
    (self->_rect).origin.y = setRect.origin.y;
    (self->_rect).size.width = setRect.size.width;
    (self->_rect).size.height = setRect.size.height;
    _objc_msgSend(self->_cachedRegion,sel_release);
    self->_cachedRegion = (id)0x0;
    _objc_msgSend(inParentLayer,sel_invalidateDisplayForCanvasItem_,self);
  }
  return;
}

*/
- (void)setRect:(NSRect)aRect inParentLayer:(id)aLayer
{
    CGFloat oldY = ABS(_rect.origin.y) + _rect.size.height;
    CGFloat newY = ABS(aRect.origin.y) + aRect.size.height;
    CGFloat scaleY = MAX(newY != 0.0 ? ABS(newY) : 1.0, oldY != 0.0 ? ABS(oldY) : 1.0);
    CGFloat oldX = ABS(_rect.origin.x) + _rect.size.width;
    CGFloat newX = ABS(aRect.origin.x) + aRect.size.width;
    CGFloat scaleX = MAX(newX != 0.0 ? ABS(newX) : 1.0, oldX != 0.0 ? ABS(oldX) : 1.0);
    if (scaleX * 0.0005 < ABS(aRect.origin.x - _rect.origin.x) ||
        scaleY * 0.0005 < ABS(aRect.origin.y - _rect.origin.y) ||
        scaleX * 0.0005 < ABS(aRect.size.width - _rect.size.width) ||
        scaleY * 0.0005 < ABS(aRect.size.height - _rect.size.height)) {
        if (NSIsEmptyRect(aRect) && NSIsEmptyRect(_rect)) {
            _rect = aRect;
            return;
        }
        [aLayer invalidateDisplayForCanvasItem:self];
        _rect = aRect;
        [_cachedRegion release];
        _cachedRegion = nil;
        [aLayer invalidateDisplayForCanvasItem:self];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00095ce5 @ 00095ce5, 52 bytes * /

NSRect * FUN_00095ce5(NSRect *__return_storage_ptr__,HSTrackingRectCanvasItem *self,SEL _cmd)

{
  (__return_storage_ptr__->origin).x = (self->_rect).origin.x;
  (__return_storage_ptr__->origin).y = (self->_rect).origin.y;
  (__return_storage_ptr__->size).width = (self->_rect).size.width;
  (__return_storage_ptr__->size).height = (self->_rect).size.height;
  return (NSRect *)self;
}

*/
- (NSRect)rect
{
    return _rect;
}

- (void)dealloc
{
    [_cachedRegion release];
    [super dealloc];
}

- (id)init
{
    return [self initWithStartingPoint:NSZeroPoint];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00095daa @ 00095daa, 87 bytes * /

id FUN_00095daa(HSTrackingRectCanvasItem *self,SEL _cmd,NSPoint initWithStartingPoint)

{
  id pvVar1;
  HSTrackingRectCanvasItem *local_c;
  undefined *local_8;
  
  local_c = self;
  local_8 = PTR_s_NSObject_0034eda0;
  pvVar1 = _objc_msgSendSuper(&local_c,sel_init);
  if (pvVar1 != (id)0x0) {
    *(float *)((int)pvVar1 + 0x14) = initWithStartingPoint.x;
    *(float *)((int)pvVar1 + 0x18) = initWithStartingPoint.y;
    *(float *)((int)pvVar1 + 4) = initWithStartingPoint.x;
    *(float *)((int)pvVar1 + 8) = initWithStartingPoint.y;
  }
  return pvVar1;
}

*/
- (id)initWithStartingPoint:(NSPoint)aPoint
{
    self = [super init];
    if (self != nil) {
        _startingPoint = aPoint;
        _rect.origin = aPoint;
    }
    return self;
}

@end

