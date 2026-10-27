#import "HSMediaStripScroller.h"
static id sDAT_003427cc;
static id sDAT_003427d0;
static id sDAT_003427d4;
static id sDAT_003427d8;
static id sDAT_003427dc;
static id sDAT_003427e0;

static id sDAT_003427cc;
static id sDAT_003427d0;
static id sDAT_003427d4;
static id sDAT_003427d8;
static id sDAT_003427dc;
static id sDAT_003427e0;


@implementation HSMediaStripScroller

/* i386 ivar offsets: _partRects=0x78, _partActions=0xa8, _partsEnabled=0xb4, _trackingPart=0xb8, _sizeForCachedGeometry=0xbc, _showsStopButton=0xc4, _geometryValid=0xc5, _rendererCell=0xc8, _trackingCell=0xcc */

/* --- i386 decompilation (Ghidra) ---
/* FUN_000544d9 @ 000544d9, 91 bytes * /

id FUN_000544d9(id self,SEL _cmd,int alternateImageForMediaStripScrollerPart)

{
  SEL op;
  id pvVar1;
  
  op = sel_mediaStripStopAlternateImage;
  if (((alternateImageForMediaStripScrollerPart == 3) ||
      (op = sel_mediaStripUpAlternateImage, alternateImageForMediaStripScrollerPart == 2)) ||
     (op = sel_mediaStripDownAlternateImage, alternateImageForMediaStripScrollerPart == 1)) {
    pvVar1 = _objc_msgSend(cls_HSMediaStripScroller,op);
  }
  else {
    pvVar1 = (id)0x0;
  }
  return pvVar1;
}

*/
+ (id)alternateImageForMediaStripScrollerPart:(NSInteger)aPart
{
    if (aPart == 3) {
        return [HSMediaStripScroller mediaStripStopAlternateImage];
    }
    if (aPart == 2) {
        return [HSMediaStripScroller mediaStripUpAlternateImage];
    }
    if (aPart == 1) {
        return [HSMediaStripScroller mediaStripDownAlternateImage];
    }
    return nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005447e @ 0005447e, 91 bytes * /

id FUN_0005447e(id self,SEL _cmd,int imageForMediaStripScrollerPart)

{
  SEL op;
  id pvVar1;
  
  op = sel_mediaStripStopImage;
  if (((imageForMediaStripScrollerPart == 3) ||
      (op = sel_mediaStripUpImage, imageForMediaStripScrollerPart == 2)) ||
     (op = sel_mediaStripDownImage, imageForMediaStripScrollerPart == 1)) {
    pvVar1 = _objc_msgSend(cls_HSMediaStripScroller,op);
  }
  else {
    pvVar1 = (id)0x0;
  }
  return pvVar1;
}

*/
+ (id)imageForMediaStripScrollerPart:(NSInteger)aPart
{
    if (aPart == 3) {
        return [HSMediaStripScroller mediaStripStopImage];
    }
    if (aPart == 2) {
        return [HSMediaStripScroller mediaStripUpImage];
    }
    if (aPart == 1) {
        return [HSMediaStripScroller mediaStripDownImage];
    }
    return nil;
}

+ (id)mediaStripStopAlternateImage
{
    if (sDAT_003427e0 == nil) {
        sDAT_003427e0 = [[NSImage imageNamed:@"mediaStrip_stop_selected"] retain];
    }
    return sDAT_003427e0;
}

+ (id)mediaStripStopImage
{
    if (sDAT_003427dc == nil) {
        sDAT_003427dc = [[NSImage imageNamed:@"mediaStrip_stop"] retain];
    }
    return sDAT_003427dc;
}

+ (id)mediaStripUpAlternateImage
{
    if (sDAT_003427d8 == nil) {
        sDAT_003427d8 = [[NSImage imageNamed:@"mediaStrip_up_selected"] retain];
    }
    return sDAT_003427d8;
}

+ (id)mediaStripUpImage
{
    if (sDAT_003427d4 == nil) {
        sDAT_003427d4 = [[NSImage imageNamed:@"mediaStrip_up"] retain];
    }
    return sDAT_003427d4;
}

+ (id)mediaStripDownAlternateImage
{
    if (sDAT_003427d0 == nil) {
        sDAT_003427d0 = [[NSImage imageNamed:@"mediaStrip_down_selected"] retain];
    }
    return sDAT_003427d0;
}

+ (id)mediaStripDownImage
{
    if (sDAT_003427cc == nil) {
        sDAT_003427cc = [[NSImage imageNamed:@"mediaStrip_down"] retain];
    }
    return sDAT_003427cc;
}

+ (CGFloat)scrollerWidthForControlSize:(NSUInteger)aSize
{
    return 14.0;
}

+ (CGFloat)scrollerWidth
{
    return 14.0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005421e @ 0005421e, 86 bytes * /

void FUN_0005421e(HSMediaStripScroller *self,SEL _cmd,id updateCell)

{
  int iVar1;
  
  if ((self->_trackingCell == updateCell) && (iVar1 = self->_trackingPart, iVar1 != 0)) {
    _objc_msgSend(self,sel_setNeedsDisplayInRect_,self->_partRects[iVar1 + -1].origin,
                  self->_partRects[iVar1 + -1].size);
  }
  return;
}

*/
- (void)updateCell:(id)aCell
{
    if (_trackingCell == aCell && _trackingPart != 0) {
        [self setNeedsDisplayInRect:_partRects[_trackingPart - 1]];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00054013 @ 00054013, 523 bytes * /

void FUN_00054013(HSMediaStripScroller *self,SEL _cmd,id mouseDown)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  undefined4 uVar5;
  undefined8 uVar4;
  
  pvVar1 = _objc_msgSend(mouseDown,sel_locationInWindow);
  uVar5 = 0;
  pvVar1 = _objc_msgSend(self,sel_convertPoint_fromView_,pvVar1,extraout_EDX,0);
  uVar4 = CONCAT44(uVar5,extraout_EDX_00);
  pvVar1 = _objc_msgSend(self,sel_hitTestPart_,pvVar1,extraout_EDX_00);
  if (pvVar1 != (id)0x0) {
    pvVar3 = pvVar1;
    pvVar2 = _objc_msgSend(self,sel_isEnabledForPart_,pvVar1,uVar4);
    if ((char)pvVar2 != '\0') {
      pvVar3 = _objc_msgSend(self,sel_trackingCell,pvVar3,uVar4);
      pvVar2 = _objc_msgSend(self,sel_target);
      _objc_msgSend(pvVar3,sel_setTarget_,pvVar2);
      _objc_msgSend(pvVar3,sel_setAction_,self->_partActions[(int)pvVar1 + -1]);
      _objc_msgSend(pvVar3,sel_setContinuous_,(uint)(pvVar1 != (id)0x3));
      pvVar2 = _objc_msgSend(cls_HSMediaStripScroller,sel_imageForMediaStripScrollerPart_,pvVar1);
      _objc_msgSend(pvVar3,sel_setImage_,pvVar2);
      pvVar2 = _objc_msgSend(cls_HSMediaStripScroller,sel_alternateImageForMediaStripScrollerPart_,
                             pvVar1);
      _objc_msgSend(pvVar3,sel_setAlternateImage_,pvVar2);
      self->_trackingPart = (int)pvVar1;
      _objc_msgSend(self,sel_setNeedsDisplay_,1);
      _objc_msgSend(pvVar3,sel_trackMouse_inRect_ofView_untilMouseUp_,mouseDown,
                    self->_partRects[(int)pvVar1 + -1].origin,
                    self->_partRects[(int)pvVar1 + -1].size,self,1);
      self->_trackingPart = 0;
      _objc_msgSend(self,sel_setNeedsDisplay_,1);
    }
  }
  return;
}

*/
- (void)mouseDown:(id)aDown
{
    NSPoint point = [self convertPoint:[aDown locationInWindow] fromView:nil];
    NSInteger part = [self hitTestPart:point];
    if (part != 0 && [self isEnabledForPart:part]) {
        NSButtonCell *cell = [self trackingCell];
        [cell setTarget:[self target]];
        [cell setAction:_partActions[part - 1]];
        [cell setContinuous:part != 3];
        [cell setImage:[HSMediaStripScroller imageForMediaStripScrollerPart:part]];
        [cell setAlternateImage:[HSMediaStripScroller alternateImageForMediaStripScrollerPart:part]];
        _trackingPart = (int)part;
        [self setNeedsDisplay:YES];
        [cell trackMouse:aDown inRect:_partRects[part - 1] ofView:self untilMouseUp:YES];
        _trackingPart = 0;
        [self setNeedsDisplay:YES];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00053f96 @ 00053f96, 125 bytes * /

void FUN_00053f96(HSMediaStripScroller *self,SEL _cmd,NSRect drawRect)

{
  char cVar1;
  uint uVar2;
  
  _objc_msgSend(self,sel_ensureGeometryIsValid);
  cVar1 = self->_showsStopButton;
  uVar2 = 1;
  do {
    _objc_msgSend(self,sel_drawPart_clipRect_,uVar2,drawRect.origin,drawRect.size);
    uVar2 = uVar2 + 1;
  } while (uVar2 <= (cVar1 != '\0') + 2);
  return;
}

*/
- (void)drawRect:(NSRect)aRect
{
    [self ensureGeometryIsValid];
    NSInteger lastPart = (_showsStopButton ? 1 : 0) + 2;
    for (NSInteger part = 1; part <= lastPart; part++) {
        [self drawPart:part clipRect:aRect];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00053e5e @ 00053e5e, 312 bytes * /

void FUN_00053e5e(HSMediaStripScroller *self,SEL _cmd,int drawPart,NSRect clipRect)

{
  id self_00;
  id pvVar1;
  NSPoint NVar2;
  NSSize NVar3;
  
  self_00 = _objc_msgSend(self,sel_rendererCell);
  pvVar1 = _objc_msgSend(cls_HSMediaStripScroller,sel_imageForMediaStripScrollerPart_,drawPart);
  _objc_msgSend(self_00,sel_setImage_,pvVar1);
  if (self->_trackingPart == drawPart) {
    _objc_msgSend(self->_trackingCell,sel_setHighlighted_,1);
    self_00 = self->_trackingCell;
    NVar2 = self->_partRects[drawPart + -1].origin;
    NVar3 = self->_partRects[drawPart + -1].size;
  }
  else {
    _objc_msgSend(self_00,sel_setHighlighted_,0);
    _objc_msgSend(self_00,sel_setEnabled_,(int)*(char *)((int)self->_partActions + drawPart + 0xb));
    NVar2 = self->_partRects[drawPart + -1].origin;
    NVar3 = self->_partRects[drawPart + -1].size;
  }
  _objc_msgSend(self_00,sel_drawWithFrame_inView_,NVar2,NVar3,self);
  return;
}

*/
- (void)drawPart:(NSInteger)aPart clipRect:(NSRect)aRect
{
    NSButtonCell *cell = [self rendererCell];
    [cell setImage:[HSMediaStripScroller imageForMediaStripScrollerPart:aPart]];
    if (_trackingPart == aPart) {
        [_trackingCell setHighlighted:YES];
        cell = _trackingCell;
    } else {
        [cell setHighlighted:NO];
        [cell setEnabled:_partsEnabled[aPart - 1]];
    }
    [cell drawWithFrame:_partRects[aPart - 1] inView:self];
}

- (NSUInteger)testPart:(NSPoint)aPart
{
    return 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00053b59 @ 00053b59, 60 bytes * /

NSRect * FUN_00053b59(NSRect *__return_storage_ptr__,HSMediaStripScroller *self,SEL _cmd,
                     uint rectForPart)

{
  float fVar1;
  undefined *puVar2;
  NSRect *pNVar3;
  
  puVar2 = PTR_00336078;
  pNVar3 = (NSRect *)PTR_00336078;
  fVar1 = *(float *)(PTR_00336078 + 4);
  (__return_storage_ptr__->origin).x = *(float *)PTR_00336078;
  (__return_storage_ptr__->origin).y = fVar1;
  (__return_storage_ptr__->size).width = *(float *)(puVar2 + 8);
  (__return_storage_ptr__->size).height = *(float *)(puVar2 + 0xc);
  return pNVar3;
}

*/
- (NSRect)rectForPart:(NSUInteger)aPart
{
    return NSZeroRect;
}

- (NSUInteger)usableParts
{
    return 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00053dbb @ 00053dbb, 163 bytes * /

int FUN_00053dbb(HSMediaStripScroller *self,SEL _cmd,NSPoint hitTestPart)

{
  char cVar1;
  id pvVar2;
  int iVar3;
  NSRect *pNVar4;
  uint uVar5;
  int local_14;
  
  pNVar4 = self->_partRects;
  cVar1 = self->_showsStopButton;
  local_14 = 0;
  uVar5 = 2;
  iVar3 = 1;
  while( true ) {
    pvVar2 = _objc_msgSend(self,sel_mouse_inRect_,hitTestPart.x,hitTestPart.y,pNVar4->origin,
                           pNVar4->size);
    if ((char)pvVar2 != '\0') {
      local_14 = iVar3;
    }
    if ((cVar1 != '\0') + 2 < uVar5) break;
    uVar5 = uVar5 + 1;
    pNVar4 = pNVar4 + 1;
    iVar3 = iVar3 + 1;
    if (local_14 != 0) {
      return local_14;
    }
  }
  return local_14;
}

*/
- (NSInteger)hitTestPart:(NSPoint)aPart
{
    NSInteger result = 0;
    NSInteger lastPart = (_showsStopButton ? 1 : 0) + 2;
    for (NSInteger part = 1; part <= lastPart; part++) {
        if ([self mouse:aPart inRect:_partRects[part - 1]]) {
            result = part;
        }
    }
    return result;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005459d @ 0005459d, 752 bytes * /

void FUN_0005459d(HSMediaStripScroller *self,SEL _cmd)

{
  undefined *puVar1;
  char cVar2;
  longdouble lVar3;
  float local_70;
  float local_6c;
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
  float fStack_30;
  float local_2c;
  float fStack_28;
  float local_24;
  float local_20;
  float local_1c;
  float local_18;
  
  _objc_msgSend_stret(&local_24,self,sel_bounds);
  cVar2 = '\0';
  if (self->_geometryValid != '\0') {
    cVar2 = _NSEqualSizes((self->_sizeForCachedGeometry).width,(self->_sizeForCachedGeometry).height
                          ,local_1c,local_18);
    if (cVar2 == '\0') {
      self->_geometryValid = '\0';
      goto LAB_00054624;
    }
    cVar2 = self->_geometryValid;
  }
  if (cVar2 != '\0') {
    return;
  }
LAB_00054624:
  puVar1 = PTR_00336078;
  local_34 = local_24;
  fStack_30 = local_20;
  local_2c = local_1c;
  fStack_28 = local_18;
  local_64 = *(float *)PTR_00336078;
  local_60 = *(float *)(PTR_00336078 + 4);
  local_6c = *(float *)(PTR_00336078 + 8);
  local_70 = *(float *)(PTR_00336078 + 0xc);
  local_5c = local_6c;
  local_58 = local_70;
  local_54 = local_64;
  local_50 = local_60;
  local_4c = local_6c;
  local_48 = local_70;
  local_44 = local_64;
  local_40 = local_60;
  local_3c = local_6c;
  local_38 = local_70;
  lVar3 = (longdouble)
          _roundf((float)((double)local_18 /
                         *(double *)(&DAT_00334d18 + (uint)(self->_showsStopButton == '\0') * 8)));
  _NSDivideRect(CONCAT44(fStack_30,local_34),CONCAT44(fStack_28,local_2c),&local_44,&local_34,
                (float)lVar3,1);
  if (self->_showsStopButton == '\0') {
    local_64 = *(float *)puVar1;
    local_60 = *(float *)(puVar1 + 4);
    local_48 = fStack_28;
    local_4c = local_2c;
    local_54 = local_34;
    local_50 = fStack_30;
  }
  else {
    _NSDivideRect(CONCAT44(fStack_30,local_34),CONCAT44(fStack_28,local_2c),&local_64,&local_54,
                  (float)lVar3,1);
    local_70 = local_58;
    local_6c = local_5c;
  }
  self->_partRects[0].origin.x = local_54;
  self->_partRects[0].origin.y = local_50;
  self->_partRects[0].size.width = local_4c;
  self->_partRects[0].size.height = local_48;
  self->_partRects[1].origin.x = local_44;
  self->_partRects[1].origin.y = local_40;
  self->_partRects[1].size.width = local_3c;
  self->_partRects[1].size.height = local_38;
  self->_partRects[2].origin.x = local_64;
  self->_partRects[2].origin.y = local_60;
  self->_partRects[2].size.width = local_6c;
  self->_partRects[2].size.height = local_70;
  self->_geometryValid = '\x01';
  (self->_sizeForCachedGeometry).width = local_1c;
  (self->_sizeForCachedGeometry).height = local_18;
  return;
}

*/
- (void)ensureGeometryIsValid
{
    NSRect bounds = [self bounds];
    BOOL valid = NO;
    if (_geometryValid) {
        if (!NSEqualSizes(_sizeForCachedGeometry, bounds.size)) {
            _geometryValid = NO;
        }
        valid = _geometryValid;
    }
    if (valid) {
        return;
    }
    NSRect slice = NSZeroRect;
    NSRect remainder = NSZeroRect;
    CGFloat height = roundf(bounds.size.height / (_showsStopButton ? 3.0 : 2.0));
    NSDivideRect(bounds, &slice, &remainder, height, NSMinYEdge);
    NSRect stopRect = NSZeroRect;
    NSRect downRect;
    if (!_showsStopButton) {
        downRect = remainder;
    } else {
        NSRect stopSlice = NSZeroRect;
        NSRect stopRemainder = NSZeroRect;
        NSDivideRect(remainder, &stopSlice, &stopRemainder, height, NSMinYEdge);
        stopRect = stopSlice;
        downRect = stopRemainder;
    }
    _partRects[0] = downRect;
    _partRects[1] = slice;
    _partRects[2] = stopRect;
    _geometryValid = YES;
    _sizeForCachedGeometry = bounds.size;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00053cfd @ 00053cfd, 190 bytes * /

id FUN_00053cfd(HSMediaStripScroller *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = self->_trackingCell;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSButtonCell,sel_alloc);
    pvVar1 = _objc_msgSend(pvVar1,sel_initImageCell_,0);
    self->_trackingCell = pvVar1;
    _objc_msgSend(pvVar1,sel_setBezelStyle_,6);
    _objc_msgSend(self->_trackingCell,sel_setButtonType_,5);
    _objc_msgSend(self->_trackingCell,sel_setBordered_,0);
    pvVar1 = self->_trackingCell;
  }
  return pvVar1;
}

*/
- (id)trackingCell
{
    if (_trackingCell == nil) {
        _trackingCell = [[NSButtonCell alloc] initImageCell:nil];
        [_trackingCell setBezelStyle:6];
        [_trackingCell setButtonType:5];
        [_trackingCell setBordered:NO];
    }
    return _trackingCell;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00053c3f @ 00053c3f, 190 bytes * /

id FUN_00053c3f(HSMediaStripScroller *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = self->_rendererCell;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSButtonCell,sel_alloc);
    pvVar1 = _objc_msgSend(pvVar1,sel_initImageCell_,0);
    self->_rendererCell = pvVar1;
    _objc_msgSend(pvVar1,sel_setBezelStyle_,6);
    _objc_msgSend(self->_rendererCell,sel_setButtonType_,5);
    _objc_msgSend(self->_rendererCell,sel_setBordered_,0);
    pvVar1 = self->_rendererCell;
  }
  return pvVar1;
}

*/
- (id)rendererCell
{
    if (_rendererCell == nil) {
        _rendererCell = [[NSButtonCell alloc] initImageCell:nil];
        [_rendererCell setBezelStyle:6];
        [_rendererCell setButtonType:5];
        [_rendererCell setBordered:NO];
    }
    return _rendererCell;
}

- (BOOL)isEnabledForPart:(NSInteger)aPart
{
    return _partsEnabled[aPart - 1];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00053be2 @ 00053be2, 93 bytes * /

void FUN_00053be2(HSMediaStripScroller *self,SEL _cmd,BOOL setEnabled,int forPart)

{
  if (*(char *)((int)self->_partActions + forPart + 0xb) != setEnabled) {
    *(BOOL *)((int)self->_partActions + forPart + 0xb) = setEnabled;
    _objc_msgSend(self,sel_setNeedsDisplayInRect_,self->_partRects[forPart + -1].origin,
                  self->_partRects[forPart + -1].size);
  }
  return;
}

*/
- (void)setEnabled:(BOOL)aEnabled forPart:(NSInteger)aPart
{
    if (_partsEnabled[aPart - 1] != aEnabled) {
        _partsEnabled[aPart - 1] = aEnabled;
        [self setNeedsDisplayInRect:_partRects[aPart - 1]];
    }
}

- (SEL)actionForPart:(NSInteger)aPart
{
    return _partActions[aPart + -1];
}

- (void)setAction:(SEL)aAction forPart:(NSInteger)aPart
{
    _partActions[aPart + -1] = aAction;
}

- (void)setShowsStopButton:(BOOL)aButton
{
    if (_showsStopButton != aButton) {
        _geometryValid = NO;
        _showsStopButton = aButton;
        [self setNeedsDisplay:YES];
    }
}

- (BOOL)showsStopButton
{
    return _showsStopButton;
}

- (BOOL)isOpaque
{
    return NO;
}

- (void)dealloc
{
    [_rendererCell release];
    [_trackingCell release];
    [super dealloc];
}

@end

