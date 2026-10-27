#import "HSSelectionKnob.h"
static id sDAT_00342794;

static id sDAT_00342794;

static id sDAT_00342794;


@implementation HSSelectionKnob

/* i386 ivar offsets: _normalStateImage=0x4, _hitTestOffset=0x8, _cachedFrame=0x10, _hash=0x20, _flags=0x24 */

+ (id)affectingAttributes
{
    if (sDAT_00342794 == nil) {
        sDAT_00342794 = [[NSEProtocolSet alloc] init];
    }
    return sDAT_00342794;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00043b6d @ 00043b6d, 15 bytes * /

ulonglong FUN_00043b6d(id self,SEL _cmd)

{
  return 0x4040000040400000;
}

*/
+ (NSSize)hitTestOffset
{
    return NSMakeSize(3.0f, 3.0f);
}

+ (id)selectionFrameColor
{
    return [NSColor darkGrayColor];
}

+ (id)normalStateImage
{
    return nil;
}

- (void)invalidateParentCanvasLayer
{

}

- (void)deactivate
{
    [self setActive:NO];
}

- (void)activateInCanvasLayer:(id)aLayer
{
    [self setActive:YES];
}

- (BOOL)overridesTrackingLoopCursor
{
    return NO;
}

- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inView:(id)aView owner:(id)aOwner
{
    return nil;
}

- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inCanvasLayer:(id)aLayer
{
    return [self cursorAtPoint:aPoint modifierFlags:aFlags inView:[[aLayer context] renderingView] owner:aLayer];
}

- (NSUInteger)hash
{
    NSUInteger pvVar1;

    pvVar1 = _hash;
    if (pvVar1 == 0) {
        pvVar1 = [self calculateHash];
        _hash = (unsigned int)pvVar1;
    }
    return (unsigned int)pvVar1;
}

- (NSUInteger)calculateHash
{
    return (unsigned int)[(NSStringFromClass([self class])) hash];
}

- (BOOL)isEqual:(id)aEqual
{
    BOOL BVar1;
    BOOL pvVar2;

    pvVar2 = [aEqual isKindOfClass:[HSSelectionKnob class]];
    if (!pvVar2) {
        pvVar2 = [super isEqual:aEqual];
        BVar1 = (BOOL)pvVar2;
    }
    else {
        pvVar2 = [self isEqualToKnob:aEqual];
        BVar1 = (BOOL)pvVar2;
    }
    return BVar1;
}

- (BOOL)isEqualToKnob:(id)aKnob
{
    return [self class] == [aKnob class];
}

- (id)affectingAttributes
{
    return [[self class] affectingAttributes];
}

- (id)affectingAttribute
{
    return nil;
}

- (BOOL)updateIfNeededInCanvasLayer:(id)aLayer
{
    return (BOOL)[self updateCachedFrameWithOwner:aLayer inView:[[aLayer context] renderingView]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00044064 @ 00044064, 185 bytes * /

id FUN_00044064(HSSelectionKnob *self,SEL _cmd,id renderingRegionInCanvasLayer)

{
  id pvVar1;
  undefined8 local_24;
  undefined8 local_1c;
  
  pvVar1 = _objc_msgSend(renderingRegionInCanvasLayer,sel_context);
  _objc_msgSend(pvVar1,sel_renderingView);
  _objc_msgSend_stret(&local_24,self,sel_frameForOwner_inView_);
  pvVar1 = _objc_msgSend(renderingRegionInCanvasLayer,sel_context);
  pvVar1 = _objc_msgSend(pvVar1,sel_renderingView);
  pvVar1 = _objc_msgSend(self,sel_boundingRegionForOwner_frame_inView_,renderingRegionInCanvasLayer,
                         local_24,local_1c,pvVar1);
  return pvVar1;
}

*/
- (id)renderingRegionInCanvasLayer:(id)aLayer
{
    id view = [[aLayer context] renderingView];
    NSRect frame = [self frameForOwner:aLayer inView:view];
    return [self boundingRegionForOwner:aLayer frame:frame inView:[[aLayer context] renderingView]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0004411d @ 0004411d, 267 bytes * /

NSRect * FUN_0004411d(NSRect *__return_storage_ptr__,HSSelectionKnob *self,SEL _cmd,
                     id renderingBoundsInCanvasLayer)

{
  id pvVar1;
  NSRect *extraout_EAX;
  NSRect *pNVar2;
  NSRect *extraout_EAX_00;
  float local_24;
  float local_20;
  float local_1c;
  float local_18;
  
  local_24 = *(float *)PTR_00336078;
  local_20 = *(float *)(PTR_00336078 + 4);
  local_1c = *(float *)(PTR_00336078 + 8);
  local_18 = *(float *)(PTR_00336078 + 0xc);
  pvVar1 = _objc_msgSend(self,sel_prefersRegionInvalidation);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(renderingBoundsInCanvasLayer,sel_context);
    pvVar1 = _objc_msgSend(pvVar1,sel_renderingView);
    _objc_msgSend_stret(__return_storage_ptr__,self,sel_boundingRectForOwner_inView_,
                        renderingBoundsInCanvasLayer,pvVar1);
    pNVar2 = extraout_EAX_00;
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_renderingRegionInCanvasLayer_,renderingBoundsInCanvasLayer);
    _objc_msgSend_stret(&local_24,pvVar1,sel_boundingRect);
    (__return_storage_ptr__->origin).x = local_24;
    (__return_storage_ptr__->origin).y = local_20;
    (__return_storage_ptr__->size).width = local_1c;
    (__return_storage_ptr__->size).height = local_18;
    pNVar2 = extraout_EAX;
  }
  return pNVar2;
}

*/
- (NSRect)renderingBoundsInCanvasLayer:(id)aLayer
{
    if ([self prefersRegionInvalidation]) {
        return [[self renderingRegionInCanvasLayer:aLayer] boundingRect];
    }
    return [self boundingRectForOwner:self inView:[[aLayer context] renderingView]];
}

- (BOOL)prefersRegionInvalidation
{
    return NO;
}

- (BOOL)hitTestPoint:(NSPoint)aPoint inCanvasLayer:(id)aLayer
{
    return (BOOL)[self hitTest:aPoint forOwner:aLayer inView:[[aLayer context] renderingView]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0004429a @ 0004429a, 179 bytes * /

void FUN_0004429a(HSSelectionKnob *self,SEL _cmd,NSRect renderRect,id inCanvasLayer,BOOL isActive)

{
  id pvVar1;
  undefined8 local_24;
  undefined8 local_1c;
  
  pvVar1 = _objc_msgSend(inCanvasLayer,sel_context);
  pvVar1 = _objc_msgSend(pvVar1,sel_renderingView);
  _objc_msgSend_stret(&local_24,self,sel_frameForOwner_inView_,inCanvasLayer,pvVar1);
  _objc_msgSend(self,sel_drawWithFrame_owner_inView_invalidRect_,local_24,local_1c,inCanvasLayer,
                pvVar1,renderRect.origin,renderRect.size);
  return;
}

*/
- (void)renderRect:(NSRect)aRect inCanvasLayer:(id)aLayer isActive:(BOOL)aActive
{
    id view = [[aLayer context] renderingView];
    NSRect frame = [self frameForOwner:aLayer inView:view];
    [self drawWithFrame:frame owner:aLayer inView:view invalidRect:aRect];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0004434d @ 0004434d, 342 bytes * /

void FUN_0004434d(HSSelectionKnob *self,SEL _cmd,NSRect drawWithFrame,id owner,id inView,
                 NSRect invalidRect)

{
  id pvVar1;
  longdouble lVar2;
  longdouble lVar3;
  
  _objc_msgSend(cls_NSGraphicsContext,sel_saveGraphicsState);
  lVar2 = (longdouble)_roundf(drawWithFrame.origin.y);
  lVar3 = (longdouble)_roundf(drawWithFrame.origin.x);
  pvVar1 = _objc_msgSend(inView,sel_isFlipped);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(cls_NSAffineTransform,sel_hyperYFlipInRect_,
                           CONCAT44((float)lVar2,(float)lVar3),drawWithFrame.size);
    _objc_msgSend(pvVar1,sel_concat);
  }
  pvVar1 = _objc_msgSend(self,sel_image);
  _objc_msgSend(pvVar1,sel_drawInRect_fromRect_operation_fraction_,
                CONCAT44((float)lVar2,(float)lVar3),drawWithFrame.size,*(undefined8 *)PTR_00336078,
                *(undefined8 *)(PTR_00336078 + 8),2,0x3f800000);
  _objc_msgSend(cls_NSGraphicsContext,sel_restoreGraphicsState);
  return;
}

*/
- (void)drawWithFrame:(NSRect)aFrame owner:(id)aOwner inView:(id)aView invalidRect:(NSRect)aRect
{
    [NSGraphicsContext saveGraphicsState];
    aFrame.origin.x = roundf(aFrame.origin.x);
    aFrame.origin.y = roundf(aFrame.origin.y);
    if ([aView isFlipped]) {
        [[NSAffineTransform hyperYFlipInRect:aFrame] concat];
    }
    [[self image] drawInRect:aFrame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
    [NSGraphicsContext restoreGraphicsState];
}

- (id)createSelectionTrackerForModifierFlags:(NSUInteger)aFlags
{
    return nil;
}

- (id)querySelectionTrackerForModifierFlags:(NSUInteger)aFlags
{
    id pvVar1;

    pvVar1 = [self createSelectionTrackerForModifierFlags:aFlags];
    [pvVar1 setSelectionKnob:self];
    return [pvVar1 autorelease];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00044500 @ 00044500, 170 bytes * /

BOOL FUN_00044500(HSSelectionKnob *self,SEL _cmd,NSPoint hitTest,id forOwner,id inView)

{
  char cVar1;
  id pvVar2;
  bool bVar3;
  undefined8 local_1c;
  undefined8 local_14;
  
  pvVar2 = _objc_msgSend(self,sel_isVisible);
  if ((char)pvVar2 == '\0') {
    bVar3 = false;
  }
  else {
    _objc_msgSend_stret(&local_1c,self,sel_frameForOwner_inView_,forOwner,inView);
    cVar1 = _HSHitTestRectangle(local_1c,local_14,hitTest.x,hitTest.y,(self->_hitTestOffset).width,
                                (self->_hitTestOffset).height);
    bVar3 = cVar1 != '\0';
  }
  return bVar3;
}

*/
- (BOOL)hitTest:(NSPoint)aTest forOwner:(id)aOwner inView:(id)aView
{
    if (![self isVisible]) {
        return NO;
    }
    return HSHitTestRectangle([self frameForOwner:aOwner inView:aView], aTest, _hitTestOffset);
}

- (void)setHitTestOffset:(NSSize)aOffset
{
    (_hitTestOffset).width = aOffset.width;
    (_hitTestOffset).height = aOffset.height;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00043c7f @ 00043c7f, 14 bytes * /

ulonglong FUN_00043c7f(HSSelectionKnob *self,SEL _cmd)

{
  ulonglong uVar1;
  
  uVar1._0_4_ = (self->_hitTestOffset).width;
  uVar1._4_4_ = (self->_hitTestOffset).height;
  return uVar1;
}

*/
- (NSSize)hitTestOffset
{
    return _hitTestOffset;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000445aa @ 000445aa, 243 bytes * /

NSRect * FUN_000445aa(NSRect *__return_storage_ptr__,HSSelectionKnob *self,SEL _cmd,id frameForOwner
                     ,id inView)

{
  float local_1c;
  float fStack_18;
  float local_14;
  float fStack_10;
  
  local_1c = *(float *)PTR_00336078;
  fStack_18 = *(float *)(PTR_00336078 + 4);
  local_14 = *(float *)(PTR_00336078 + 8);
  fStack_10 = *(float *)(PTR_00336078 + 0xc);
  if ((self->_flags).cachedFrameIsValid == 0) {
    _objc_msgSend_stret(&local_1c,self,sel_calculateFrameForOwner_inView_,frameForOwner,inView);
    _objc_msgSend(self,sel_updateCachedFrame_,CONCAT44(fStack_18,local_1c),
                  CONCAT44(fStack_10,local_14));
  }
  else {
    local_1c = (self->_cachedFrame).origin.x;
    fStack_18 = (self->_cachedFrame).origin.y;
    local_14 = (self->_cachedFrame).size.width;
    fStack_10 = (self->_cachedFrame).size.height;
  }
  (__return_storage_ptr__->origin).x = local_1c;
  (__return_storage_ptr__->origin).y = fStack_18;
  (__return_storage_ptr__->size).width = local_14;
  (__return_storage_ptr__->size).height = fStack_10;
  return __return_storage_ptr__;
}

*/
- (NSRect)frameForOwner:(id)aOwner inView:(id)aView
{
    NSRect frame = NSZeroRect;
    if (!_flags.cachedFrameIsValid) {
        frame = [self calculateFrameForOwner:aOwner inView:aView];
        [self updateCachedFrame:frame];
    } else {
        frame = _cachedFrame;
    }
    return frame;
}

- (BOOL)updateCachedFrameWithOwner:(id)aOwner inView:(id)aView
{
    return (BOOL)[self updateCachedFrame:[self calculateFrameForOwner:aOwner inView:aView]];
}

- (void)invalidateCachedFrame
{
    (_flags).cachedFrameIsValid = 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0004470a @ 0004470a, 446 bytes * /

BOOL FUN_0004470a(HSSelectionKnob *self,SEL _cmd,NSRect updateCachedFrame)

{
  float fVar1;
  float fVar2;
  float fVar3;
  float fVar4;
  anon_4987da1a_2 aVar5;
  byte bVar6;
  float fVar7;
  float fVar8;
  float fVar9;
  float fVar10;
  
  fVar1 = (self->_cachedFrame).origin.y;
  fVar2 = (self->_cachedFrame).size.height;
  fVar9 = ABS(fVar1) + fVar2;
  fVar7 = ABS(updateCachedFrame.origin.y) + updateCachedFrame.size.height;
  aVar5 = self->_flags;
  bVar6 = (self->_flags).cachedFrameIsValid ^ 1;
  if ((fVar7 != 0.0) || (NAN(fVar7))) {
    fVar7 = ABS(fVar7);
  }
  else {
    fVar7 = 1.0;
  }
  if ((fVar9 != 0.0) || (NAN(fVar9))) {
    fVar9 = ABS(fVar9);
  }
  else {
    fVar9 = 1.0;
  }
  fVar3 = (self->_cachedFrame).origin.x;
  fVar4 = (self->_cachedFrame).size.width;
  fVar10 = ABS(fVar3) + fVar4;
  fVar8 = ABS(updateCachedFrame.origin.x) + updateCachedFrame.size.width;
  if (fVar9 <= fVar7) {
    fVar9 = fVar7;
  }
  if ((fVar8 != 0.0) || (NAN(fVar8))) {
    fVar8 = ABS(fVar8);
  }
  else {
    fVar8 = 1.0;
  }
  if ((fVar10 != 0.0) || (NAN(fVar10))) {
    fVar10 = ABS(fVar10);
  }
  else {
    fVar10 = 1.0;
  }
  if (fVar10 <= fVar8) {
    fVar10 = fVar8;
  }
  if ((((fVar10 * 0.0005 < ABS(updateCachedFrame.origin.x - fVar3)) ||
       (fVar9 * 0.0005 < ABS(updateCachedFrame.origin.y - fVar1))) ||
      (fVar10 * 0.0005 < ABS(updateCachedFrame.size.width - fVar4))) ||
     (fVar9 * 0.0005 < ABS(updateCachedFrame.size.height - fVar2))) {
    _objc_msgSend(self,sel_invalidateCachedFrame);
    (self->_cachedFrame).origin.x = updateCachedFrame.origin.x;
    (self->_cachedFrame).origin.y = updateCachedFrame.origin.y;
    (self->_cachedFrame).size.width = updateCachedFrame.size.width;
    (self->_cachedFrame).size.height = updateCachedFrame.size.height;
    aVar5 = self->_flags;
    bVar6 = 1;
  }
  self->_flags = (anon_4987da1a_2)((uint)aVar5 | 0x10);
  return bVar6;
}

*/
- (BOOL)updateCachedFrame:(NSRect)aFrame
{
    BOOL changed = !_flags.cachedFrameIsValid;
    float x = _cachedFrame.origin.x;
    float y = _cachedFrame.origin.y;
    float w = _cachedFrame.size.width;
    float h = _cachedFrame.size.height;
    float magnitudeY = fabsf(y) + h;
    float newMagnitudeY = fabsf(aFrame.origin.y) + aFrame.size.height;
    float magnitudeX = fabsf(x) + w;
    float newMagnitudeX = fabsf(aFrame.origin.x) + aFrame.size.width;
    newMagnitudeY = (newMagnitudeY != 0.0f || isnan(newMagnitudeY)) ? fabsf(newMagnitudeY) : 1.0f;
    magnitudeY = (magnitudeY != 0.0f || isnan(magnitudeY)) ? fabsf(magnitudeY) : 1.0f;
    newMagnitudeX = (newMagnitudeX != 0.0f || isnan(newMagnitudeX)) ? fabsf(newMagnitudeX) : 1.0f;
    magnitudeX = (magnitudeX != 0.0f || isnan(magnitudeX)) ? fabsf(magnitudeX) : 1.0f;
    float scaleY = MAX(magnitudeY, newMagnitudeY);
    float scaleX = MAX(magnitudeX, newMagnitudeX);
    if (scaleX * 0.0005f < fabsf(aFrame.origin.x - x)
        || scaleY * 0.0005f < fabsf(aFrame.origin.y - y)
        || scaleX * 0.0005f < fabsf(aFrame.size.width - w)
        || scaleY * 0.0005f < fabsf(aFrame.size.height - h)) {
        [self invalidateCachedFrame];
        _cachedFrame = aFrame;
        changed = YES;
    }
    _flags.cachedFrameIsValid = 1;
    return changed;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000448c8 @ 000448c8, 62 bytes * /

NSRect * FUN_000448c8(NSRect *__return_storage_ptr__,HSSelectionKnob *self,SEL _cmd,
                     id calculateFrameForOwner,id inView)

{
  NSRect *pNVar1;
  float extraout_EDX;
  
  pNVar1 = _objc_msgSend(self,sel_imageSize);
  (__return_storage_ptr__->origin).x = 0.0;
  (__return_storage_ptr__->origin).y = 0.0;
  (__return_storage_ptr__->size).width = (float)pNVar1;
  (__return_storage_ptr__->size).height = extraout_EDX;
  return pNVar1;
}

*/
- (NSRect)calculateFrameForOwner:(id)aOwner inView:(id)aView
{
    NSSize size = [self imageSize];
    return NSMakeRect(0.0f, 0.0f, size.width, size.height);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00044906 @ 00044906, 134 bytes * /

id FUN_00044906(HSSelectionKnob *self,SEL _cmd,id boundingRegionForOwner,NSRect frame,id inView)

{
  undefined *self_00;
  id pvVar1;
  undefined8 local_1c [2];
  
  self_00 = cls_HSRegion;
  _objc_msgSend_stret(local_1c,self,sel_boundingRectForOwner_frame_inView_,boundingRegionForOwner,
                      frame.origin.x,frame.origin.y,frame.size,inView);
  pvVar1 = _objc_msgSend(self_00,sel_regionWithRect_,local_1c[0],(int)local_1c[1],
                         (int)((ulonglong)local_1c[1] >> 0x20));
  return pvVar1;
}

*/
- (id)boundingRegionForOwner:(id)aOwner frame:(NSRect)aFrame inView:(id)aView
{
    return [HSRegion regionWithRect:[self boundingRectForOwner:aOwner frame:aFrame inView:aView]];
}

- (NSRect)boundingRectForOwner:(id)aOwner frame:(NSRect)aFrame inView:(id)aView
{
    NSRect result;

    result.origin.x = aFrame.origin.x;
    result.origin.y = aFrame.origin.y;
    result.size.width = aFrame.size.width;
    result.size.height = aFrame.size.height;
    return result;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0004498c @ 0004498c, 128 bytes * /

NSRect * FUN_0004498c(NSRect *__return_storage_ptr__,HSSelectionKnob *self,SEL _cmd,
                     id boundingRectForOwner,id inView)

{
  NSRect *extraout_EAX;
  undefined8 local_24;
  undefined8 local_1c;
  
  _objc_msgSend_stret(&local_24,self,sel_frameForOwner_inView_,boundingRectForOwner,inView);
  _objc_msgSend_stret(__return_storage_ptr__,self,sel_boundingRectForOwner_frame_inView_,
                      boundingRectForOwner,local_24,local_1c,inView);
  return extraout_EAX;
}

*/
- (NSRect)boundingRectForOwner:(id)aOwner inView:(id)aView
{
    return [self boundingRectForOwner:aOwner frame:[self frameForOwner:aOwner inView:aView] inView:aView];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00044a0c @ 00044a0c, 58 bytes * /

ulonglong FUN_00044a0c(HSSelectionKnob *self,SEL _cmd)

{
  id pvVar1;
  undefined4 extraout_EDX;
  
  pvVar1 = _objc_msgSend(self,sel_image);
  pvVar1 = _objc_msgSend(pvVar1,sel_size);
  return CONCAT44(extraout_EDX,pvVar1);
}

*/
- (NSSize)imageSize
{
    return [[self image] size];
}

- (BOOL)canBeLocked
{
    return YES;
}

- (void)setVisible:(BOOL)aVisible
{
    (_flags).isInvisible = aVisible == NO;
}

- (BOOL)isVisible
{
    return (_flags).isInvisible ^ 1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00043bd0 @ 00043bd0, 52 bytes * /

void FUN_00043bd0(HSSelectionKnob *self,SEL _cmd,BOOL setBeingTracked)

{
  anon_4987da1a_2 aVar1;
  
  aVar1 = self->_flags;
  if ((((self->_flags).isBeingTracked != 0) && (setBeingTracked == '\0')) ||
     (((self->_flags).isBeingTracked == 0 && (setBeingTracked != '\0')))) {
    self->_flags = (anon_4987da1a_2)(((byte)setBeingTracked & 1) * 4 + ((uint)aVar1 & 0xfffffffb));
  }
  return;
}

*/
- (void)setBeingTracked:(BOOL)aTracked
{
    if ((_flags.isBeingTracked != 0 && !aTracked) || (_flags.isBeingTracked == 0 && aTracked)) {
        _flags.isBeingTracked = aTracked ? 1 : 0;
    }
}

- (BOOL)isBeingTracked
{
    return (_flags).isBeingTracked;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00043b8c @ 00043b8c, 51 bytes * /

void FUN_00043b8c(HSSelectionKnob *self,SEL _cmd,BOOL setActive)

{
  anon_4987da1a_2 aVar1;
  
  aVar1 = self->_flags;
  if ((((self->_flags).isActive != 0) && (setActive == '\0')) ||
     (((self->_flags).isActive == 0 && (setActive != '\0')))) {
    self->_flags = (anon_4987da1a_2)(((uint)(byte)setActive * 2 & 2) + ((uint)aVar1 & 0xfffffffd));
  }
  return;
}

*/
- (void)setActive:(BOOL)aActive
{
    if ((_flags.isActive != 0 && !aActive) || (_flags.isActive == 0 && aActive)) {
        _flags.isActive = aActive ? 1 : 0;
    }
}

- (BOOL)isActive
{
    return (_flags).isActive;
}

- (id)image
{
    return [self normalStateImage];
}

- (void)setNormalStateImage:(id)aImage
{
    if (_normalStateImage != aImage) {
        [_normalStateImage release];
        _normalStateImage = [aImage retain];
    }
    (_flags).isNormalStateImageSet = 1;
}

- (id)normalStateImage
{
    id pvVar1_3;

    if ((_flags).isNormalStateImageSet == 0) {
        pvVar1_3 = [[[self class] normalStateImage] retain];
        _normalStateImage = pvVar1_3;
        (_flags).isNormalStateImageSet = 1;
    }
    else {
        pvVar1_3 = _normalStateImage;
    }
    return pvVar1_3;
}

- (void)dealloc
{
    [_normalStateImage release];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00043cd1 @ 00043cd1, 107 bytes * /

id FUN_00043cd1(HSSelectionKnob *self,SEL _cmd)

{
  id self_00;
  id pvVar1;
  undefined4 extraout_EDX;
  HSSelectionKnob *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_NSObject_0034de10;
  self_00 = _objc_msgSendSuper(&local_14,sel_init);
  if (self_00 != (id)0x0) {
    pvVar1 = _objc_msgSend(self_00,sel_class);
    pvVar1 = _objc_msgSend(pvVar1,sel_hitTestOffset);
    *(id *)((int)self_00 + 8) = pvVar1;
    *(undefined4 *)((int)self_00 + 0xc) = extraout_EDX;
  }
  return self_00;
}

*/
- (id)init
{
    self = [super init];
    if (self != nil) {
        _hitTestOffset = [[self class] hitTestOffset];
    }
    return self;
}

@end

