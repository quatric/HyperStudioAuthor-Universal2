#import "HSCardNavigatorView.h"

@implementation HSCardNavigatorView

/* i386 ivar offsets: _card=0x50, _cachedCardImage=0x54, _backgroundColor=0x58, _visibleFrameColor=0x5c, _secondVisibleFrameColor=0x60, _cardRepresentationRect=0x64, _delegate=0x74 */

+ (id)defaultSecondVisibleFrameColor
{
    return [NSColor whiteColor];
}

+ (id)defaultVisibleFrameColor
{
    return [NSColor redColor];
}

+ (id)defaultBackgroundColor
{
    return [self patternColor];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001659d7 @ 001659d7, 258 bytes * /

id FUN_001659d7(id self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  cfstringStruct *pcVar2;
  id pvVar3;
  cfstringStruct *pcVar4;
  
  pvVar1 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  pcVar2 = _objc_msgSend(pvVar1,sel_stringForKey_,*(undefined4 *)PTR_00336054);
  self_00 = cls_NSColor;
  pvVar1 = _objc_msgSend(cls_NSImage,sel_alloc);
  pvVar3 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pcVar4 = &cfstr_Denim;
  if (pcVar2 != (cfstringStruct *)0x0) {
    pcVar4 = pcVar2;
  }
  pvVar3 = _objc_msgSend(pvVar3,sel_pathForResource_ofType_inDirectory_,pcVar4,&cfstr_tiff,
                         &cfstr_WABPatterns);
  pvVar1 = _objc_msgSend(pvVar1,sel_initByReferencingFile_,pvVar3);
  pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  pvVar1 = _objc_msgSend(self_00,sel_colorWithPatternImage_,pvVar1);
  return pvVar1;
}

*/
+ (id)patternColor
{
    NSString *name = [[NSUserDefaults standardUserDefaults] stringForKey:HSWorkAreaBackgroundKey];
    NSImage *image = [[[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:(name != nil ? name : @"Denim") ofType:@"tiff" inDirectory:@"WABPatterns"]] autorelease];
    return [NSColor colorWithPatternImage:image];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00165ad9 @ 00165ad9, 105 bytes * /

void FUN_00165ad9(HSCardNavigatorView *self,SEL _cmd,id mouseDragged)

{
  id pvVar1;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  
  pvVar1 = _objc_msgSend(mouseDragged,sel_locationInWindow);
  pvVar1 = _objc_msgSend(self,sel_convertPoint_fromView_,pvVar1,extraout_EDX,0);
  _objc_msgSend(self,sel_scrollCardViewToRectWithCenterAtLocalPoint_,pvVar1,extraout_EDX_00);
  return;
}

*/
- (void)mouseDragged:(id)aDragged
{
    [self scrollCardViewToRectWithCenterAtLocalPoint:[self convertPoint:[aDragged locationInWindow] fromView:nil]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00165b42 @ 00165b42, 167 bytes * /

void FUN_00165b42(HSCardNavigatorView *self,SEL _cmd,id mouseDown)

{
  char cVar1;
  id pvVar2;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  
  pvVar2 = _objc_msgSend(mouseDown,sel_locationInWindow);
  pvVar2 = _objc_msgSend(self,sel_convertPoint_fromView_,pvVar2,extraout_EDX,0);
  cVar1 = _NSPointInRect(pvVar2,extraout_EDX_00,(self->_cardRepresentationRect).origin,
                         (self->_cardRepresentationRect).size);
  if (cVar1 != '\0') {
    _objc_msgSend(self,sel_scrollCardViewToRectWithCenterAtLocalPoint_,pvVar2,extraout_EDX_00);
  }
  return;
}

*/
- (void)mouseDown:(id)aDown
{
    NSPoint point = [self convertPoint:[aDown locationInWindow] fromView:nil];
    if (NSPointInRect(point, _cardRepresentationRect)) {
        [self scrollCardViewToRectWithCenterAtLocalPoint:point];
    }
}

- (BOOL)acceptsFirstMouse:(id)aMouse
{
    return YES;
}

- (BOOL)mouseDownCanMoveWindow
{
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00165be9 @ 00165be9, 508 bytes * /

void FUN_00165be9(HSCardNavigatorView *self,SEL _cmd,
                 NSPoint scrollCardViewToRectWithCenterAtLocalPoint)

{
  float fVar1;
  char cVar2;
  id pvVar3;
  float fVar4;
  float fVar5;
  float local_44;
  float fStack_40;
  float local_3c;
  float fStack_38;
  float local_34;
  float local_30;
  float local_2c;
  undefined1 local_24 [20];
  
  pvVar3 = _objc_msgSend(self->_delegate,sel_respondsToSelector_,
                         sel_scrollCardViewToRect_cardNavigatorView_);
  if ((char)pvVar3 != '\0') {
    pvVar3 = _objc_msgSend(self->_delegate,sel_respondsToSelector_,sel_cardViewForCardNavigatorView_
                          );
    if ((char)pvVar3 == '\0') {
      pvVar3 = (id)0x0;
    }
    else {
      pvVar3 = _objc_msgSend(self->_delegate,sel_cardViewForCardNavigatorView_,self);
    }
    _objc_msgSend_stret(local_24,self,sel_cardRect);
    _objc_msgSend_stret(&local_34,pvVar3,sel_viewBoundingRectForUserRect_,(int)local_24._0_8_,
                        SUB84(local_24._0_8_,4),(int)local_24._8_8_,SUB84(local_24._8_8_,4));
    fVar4 = scrollCardViewToRectWithCenterAtLocalPoint.y - (self->_cardRepresentationRect).origin.y;
    fVar1 = (self->_cardRepresentationRect).origin.x;
    fVar5 = local_2c / (self->_cardRepresentationRect).size.width;
    pvVar3 = _objc_msgSend(pvVar3,sel_isFlipped);
    if ((char)pvVar3 == '\0') {
      fVar4 = fVar4 * fVar5;
    }
    else {
      fVar4 = ((self->_cardRepresentationRect).size.height - fVar4) * fVar5 + local_30;
    }
    _objc_msgSend_stret(&local_44,self,sel_visibleFrame);
    cVar2 = _NSEqualRects(CONCAT44(fStack_40,local_44),CONCAT44(fStack_38,local_3c),
                          (int)*(undefined8 *)PTR_00336078,
                          (int)((ulonglong)*(undefined8 *)PTR_00336078 >> 0x20),
                          (int)*(undefined8 *)(PTR_00336078 + 8),
                          (int)((ulonglong)*(undefined8 *)(PTR_00336078 + 8) >> 0x20));
    if (cVar2 == '\0') {
      local_44 = (scrollCardViewToRectWithCenterAtLocalPoint.x - fVar1) * fVar5 + local_34 +
                 local_3c * -0.5;
      fStack_40 = fVar4 + fStack_38 * -0.5;
      _objc_msgSend(self->_delegate,sel_scrollCardViewToRect_cardNavigatorView_,
                    CONCAT44(fStack_40,local_44),local_3c,fStack_38,self);
    }
  }
  return;
}

*/
- (void)scrollCardViewToRectWithCenterAtLocalPoint:(NSPoint)aPoint
{
    if (![_delegate respondsToSelector:@selector(scrollCardViewToRect:cardNavigatorView:)]) {
        return;
    }
    id cardView = nil;
    if ([_delegate respondsToSelector:@selector(cardViewForCardNavigatorView:)]) {
        cardView = [_delegate cardViewForCardNavigatorView:self];
    }
    NSRect bounds = [cardView viewBoundingRectForUserRect:[self cardRect]];
    float relativeY = aPoint.y - _cardRepresentationRect.origin.y;
    float scale = bounds.size.width / _cardRepresentationRect.size.width;
    float centerX = (aPoint.x - _cardRepresentationRect.origin.x) * scale + bounds.origin.x;
    float centerY;
    if ([cardView isFlipped]) {
        centerY = (_cardRepresentationRect.size.height - relativeY) * scale + bounds.origin.y;
    }
    else {
        centerY = relativeY * scale;
    }
    NSRect visible = [self visibleFrame];
    if (!NSEqualRects(visible, NSZeroRect)) {
        visible.origin.x = centerX + visible.size.width * -0.5;
        visible.origin.y = centerY + visible.size.height * -0.5;
        [_delegate scrollCardViewToRect:visible cardNavigatorView:self];
    }
}

- (id)secondVisibleFrameColor
{
    id pvVar1;

    pvVar1 = _secondVisibleFrameColor;
    if (pvVar1 == nil) {
        [self setSecondVisibleFrameColor:[[self class] defaultSecondVisibleFrameColor]];
        pvVar1 = _secondVisibleFrameColor;
    }
    return pvVar1;
}

- (void)setSecondVisibleFrameColor:(id)aColor
{
    if (![_secondVisibleFrameColor isEqualTo:aColor]) {
        [_secondVisibleFrameColor release];
        _secondVisibleFrameColor = [aColor retain];
    }
}

- (id)visibleFrameColor
{
    id pvVar1;

    pvVar1 = _visibleFrameColor;
    if (pvVar1 == nil) {
        [self setVisibleFrameColor:[[self class] defaultVisibleFrameColor]];
        pvVar1 = _visibleFrameColor;
    }
    return pvVar1;
}

- (void)setVisibleFrameColor:(id)aColor
{
    if (![_visibleFrameColor isEqualTo:aColor]) {
        [_visibleFrameColor release];
        _visibleFrameColor = [aColor retain];
    }
}

- (id)backgroundColor
{
    id pvVar1;

    pvVar1 = _backgroundColor;
    if (pvVar1 == nil) {
        [self setBackgroundColor:[[self class] defaultBackgroundColor]];
        pvVar1 = _backgroundColor;
    }
    return pvVar1;
}

- (void)setBackgroundColor:(id)aColor
{
    if (![aColor isEqualTo:_backgroundColor]) {
        [_backgroundColor release];
        _backgroundColor = [aColor retain];
    }
}

- (void)deskPatternChanged:(id)aChanged
{
    [_backgroundColor release];
    _backgroundColor = nil;
    [self setNeedsDisplay:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00166073 @ 00166073, 139 bytes * /

float FUN_00166073(HSCardNavigatorView *self,SEL _cmd)

{
  longdouble lVar1;
  float fVar2;
  undefined1 local_2c [8];
  float local_24;
  undefined1 local_1c [8];
  float local_14;
  float local_10;
  
  _objc_msgSend_stret(local_2c,self,sel_frame);
  _objc_msgSend_stret(local_1c,self,sel_cardRect);
  lVar1 = (longdouble)_truncf((local_24 * local_10) / local_14);
  fVar2 = 300.0;
  if ((float)lVar1 <= 300.0) {
    fVar2 = (float)lVar1;
  }
  return fVar2;
}

*/
- (CGFloat)frameHeightAccordingToCardProporsions
{
    NSRect frame = [self frame];
    NSRect cardRect = [self cardRect];
    float height = truncf((frame.size.width * cardRect.size.height) / cardRect.size.width);
    return height <= 300.0 ? height : 300.0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001660fe @ 001660fe, 128 bytes * /

void FUN_001660fe(HSCardNavigatorView *self,SEL _cmd)

{
  double dVar1;
  undefined1 local_1c [8];
  undefined4 local_14;
  
  _objc_msgSend_stret(local_1c,self,sel_frame);
  dVar1 = _objc_msgSend_fpret(self,sel_frameHeightAccordingToCardProporsions);
  if (!NAN((float)dVar1)) {
    _objc_msgSend(self,sel_setFrameSize_,local_14,(float)dVar1);
  }
  return;
}

*/
- (void)setFrameSizeAccordingToCardProporsions
{
    NSRect frame = [self frame];
    float height = (float)[self frameHeightAccordingToCardProporsions];
    if (!isnan(height)) {
        [self setFrameSize:NSMakeSize(frame.size.width, height)];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0016617e @ 0016617e, 131 bytes * /

NSRect * FUN_0016617e(NSRect *__return_storage_ptr__,HSCardNavigatorView *self,SEL _cmd)

{
  float fVar1;
  float fVar2;
  id pvVar3;
  NSRect *pNVar4;
  float extraout_EDX;
  
  pvVar3 = _objc_msgSend(self,sel_card);
  pvVar3 = _objc_msgSend(pvVar3,sel_stack);
  fVar1 = *(float *)PTR_00336074;
  fVar2 = *(float *)(PTR_00336074 + 4);
  pNVar4 = _objc_msgSend(pvVar3,sel_hyperCardSize);
  (__return_storage_ptr__->origin).x = fVar1;
  (__return_storage_ptr__->origin).y = fVar2;
  (__return_storage_ptr__->size).width = (float)pNVar4;
  (__return_storage_ptr__->size).height = extraout_EDX;
  return pNVar4;
}

*/
- (NSRect)cardRect
{
    NSSize size = [[[self card] stack] hyperCardSize];
    return NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, size.width, size.height);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00166201 @ 00166201, 183 bytes * /

NSRect * FUN_00166201(NSRect *__return_storage_ptr__,HSCardNavigatorView *self,SEL _cmd)

{
  id pvVar1;
  float local_1c;
  float local_18;
  float local_14;
  float local_10;
  
  local_1c = *(float *)PTR_00336078;
  local_18 = *(float *)(PTR_00336078 + 4);
  local_14 = *(float *)(PTR_00336078 + 8);
  local_10 = *(float *)(PTR_00336078 + 0xc);
  pvVar1 = _objc_msgSend(self->_delegate,sel_respondsToSelector_,
                         sel_userVisibleCardRectForCardNavigatorView_);
  if ((char)pvVar1 != '\0') {
    _objc_msgSend_stret(&local_1c,self->_delegate,sel_userVisibleCardRectForCardNavigatorView_,self)
    ;
  }
  (__return_storage_ptr__->origin).x = local_1c;
  (__return_storage_ptr__->origin).y = local_18;
  (__return_storage_ptr__->size).width = local_14;
  (__return_storage_ptr__->size).height = local_10;
  return __return_storage_ptr__;
}

*/
- (NSRect)visibleFrame
{
    NSRect rect = NSZeroRect;
    if ([_delegate respondsToSelector:@selector(userVisibleCardRectForCardNavigatorView:)]) {
        rect = [_delegate userVisibleCardRectForCardNavigatorView:self];
    }
    return rect;
}

- (void)updateCachedImage
{
    [_cachedCardImage release];
    _cachedCardImage = [[[self card] image] retain];
}

- (void)invalidateCachedImage
{
    [_cachedCardImage release];
    _cachedCardImage = nil;
}

- (void)visualAttributeDidChange:(id)aChange
{
    [self invalidateCachedImage];
    [self setNeedsDisplay:YES];
}

- (id)card
{
    return _card;
}

- (void)setCard:(id)aCard
{
    if (_card != aCard) {
        [_card removeAttributeObserver:self];
        [_card release];
        _card = [aCard retain];
        [self invalidateCachedImage];
        if (_card != nil) {
            [aCard addObserver:self selector:@selector(visualAttributeDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSVisualAttribute) withPriority:-0.75];
            [self setFrameSizeAccordingToCardProporsions];
        }
        [self setNeedsDisplay:YES];
    }
}

- (id)delegate
{
    return _delegate;
}

- (void)setDelegate:(id)aDelegate
{
    if (_delegate != aDelegate) {
        _delegate = aDelegate;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00166480 @ 00166480, 1571 bytes * /

void FUN_00166480(HSCardNavigatorView *self,SEL _cmd,NSRect drawRect)

{
  NSPoint NVar1;
  NSSize NVar2;
  char cVar3;
  id pvVar4;
  id pvVar5;
  undefined4 extraout_EDX;
  float fVar6;
  float fVar7;
  float fVar8;
  float fVar9;
  float fVar10;
  float fVar11;
  float local_b4;
  float local_b0;
  float local_ac;
  float local_a8;
  float local_a4;
  float local_a0;
  float local_9c;
  float local_98;
  float local_94;
  float local_90;
  undefined4 local_8c;
  float local_88;
  float local_84;
  float local_80;
  float local_7c;
  float local_78;
  undefined4 local_74;
  undefined4 uStack_70;
  id local_6c;
  undefined4 uStack_68;
  float local_64;
  float fStack_60;
  float local_5c;
  float fStack_58;
  float local_54;
  float fStack_50;
  float local_4c;
  float fStack_48;
  undefined1 local_44 [16];
  undefined1 local_34 [16];
  undefined1 local_24 [8];
  float local_1c;
  float local_18;
  
  pvVar4 = _objc_msgSend(self,sel_backgroundColor);
  _objc_msgSend(pvVar4,sel_set);
  _objc_msgSend_stret(local_44,self,sel_bounds);
  _NSRectFill((int)local_44._0_8_,SUB84(local_44._0_8_,4),(int)local_44._8_8_,
              SUB84(local_44._8_8_,4));
  if ((self->_cachedCardImage == (id)0x0) && (self->_card != (id)0x0)) {
    _objc_msgSend(self,sel_updateCachedImage);
  }
  _objc_msgSend_stret(&local_54,self,sel_visibleFrame);
  local_64 = local_54;
  fStack_60 = fStack_50;
  local_5c = local_4c;
  fStack_58 = fStack_48;
  if (self->_cachedCardImage != (id)0x0) {
    pvVar4 = _objc_msgSend(self->_cachedCardImage,sel_size);
    pvVar5 = _objc_msgSend(self->_delegate,sel_respondsToSelector_,sel_cardViewForCardNavigatorView_
                          );
    if ((char)pvVar5 == '\0') {
      pvVar5 = (id)0x0;
    }
    else {
      pvVar5 = _objc_msgSend(self->_delegate,sel_cardViewForCardNavigatorView_,self);
    }
    _objc_msgSend_stret(local_34,self,sel_cardRect);
    _objc_msgSend_stret(&local_84,pvVar5,sel_viewBoundingRectForUserRect_,(int)local_34._0_8_,
                        SUB84(local_34._0_8_,4),(int)local_34._8_8_,SUB84(local_34._8_8_,4));
    (self->_cardRepresentationRect).origin.x = local_84;
    (self->_cardRepresentationRect).origin.y = local_80;
    (self->_cardRepresentationRect).size.width = local_7c;
    (self->_cardRepresentationRect).size.height = local_78;
    _objc_msgSend_stret(local_24,self,sel_frame);
    fVar11 = (self->_cardRepresentationRect).origin.x;
    fVar10 = (self->_cardRepresentationRect).origin.y;
    fVar7 = *(float *)(PTR_00336074 + 4);
    (self->_cardRepresentationRect).origin.x = *(float *)PTR_00336074;
    (self->_cardRepresentationRect).origin.y = fVar7;
    fVar7 = (self->_cardRepresentationRect).size.width;
    if (local_1c < fVar7) {
      fVar8 = fVar7 / local_1c;
      fVar7 = fVar7 / fVar8;
      (self->_cardRepresentationRect).size.width = fVar7;
      fVar6 = (self->_cardRepresentationRect).size.height / fVar8;
      (self->_cardRepresentationRect).size.height = fVar6;
    }
    else {
      fVar6 = (self->_cardRepresentationRect).size.height;
      fVar8 = 1.0;
    }
    if (local_18 < fVar6) {
      fVar9 = fVar6 / local_18;
      (self->_cardRepresentationRect).size.width = fVar7 / fVar9;
      (self->_cardRepresentationRect).size.height = fVar6 / fVar9;
      fVar8 = fVar8 * fVar9;
    }
    local_54 = (local_54 - fVar11) / fVar8;
    fStack_50 = (fStack_50 - fVar10) / fVar8;
    local_4c = local_4c / fVar8;
    fStack_48 = fStack_48 / fVar8;
    NVar1 = (self->_cardRepresentationRect).origin;
    NVar2 = (self->_cardRepresentationRect).size;
    _NSIntersectionRect(&local_94,local_54,fStack_50,local_4c,fStack_48,NVar1.x,NVar1.y,NVar2.width,
                        NVar2.height);
    local_4c = (float)local_8c;
    fStack_48 = local_88;
    fVar11 = (self->_cardRepresentationRect).size.height;
    local_74 = 0;
    uStack_70 = 0;
    local_54 = (local_1c - (self->_cardRepresentationRect).size.width) * 0.5;
    (self->_cardRepresentationRect).origin.x = (self->_cardRepresentationRect).origin.x + local_54;
    fVar10 = (local_18 - fVar11) * 0.5;
    (self->_cardRepresentationRect).origin.y = fVar10 + (self->_cardRepresentationRect).origin.y;
    fStack_50 = ((fVar11 - local_88) + fVar10) - local_90;
    local_54 = local_54 + local_94;
    local_6c = pvVar4;
    uStack_68 = extraout_EDX;
    _NSIntegralRect(&local_a4,local_54,fStack_50,local_8c,local_88);
    local_54 = local_a4;
    local_64 = local_a4 + 1.0;
    fStack_50 = local_a0;
    local_4c = local_9c;
    fStack_48 = local_98;
    fStack_60 = local_a0 + 1.0;
    local_5c = local_9c + -2.0;
    fStack_58 = local_98 + -2.0;
    NVar1 = (self->_cardRepresentationRect).origin;
    NVar2 = (self->_cardRepresentationRect).size;
    fVar7 = NVar2.width;
    fVar6 = NVar2.height;
    fVar11 = NVar1.x;
    fVar10 = NVar1.y;
    _NSIntegralRect();
    (self->_cardRepresentationRect).origin.x = local_b4;
    (self->_cardRepresentationRect).origin.y = local_b0;
    (self->_cardRepresentationRect).size.width = local_ac;
    (self->_cardRepresentationRect).size.height = local_a8;
    pvVar4 = _objc_msgSend(cls_NSGraphicsContext,sel_currentContext,fVar11,fVar10,fVar7,fVar6);
    _objc_msgSend(pvVar4,sel_saveGraphicsState);
    _objc_msgSend(pvVar4,sel_setImageInterpolation_,3);
    NVar1 = (self->_cardRepresentationRect).origin;
    NVar2 = (self->_cardRepresentationRect).size;
    _objc_msgSend(self->_cachedCardImage,sel_drawInRect_fromRect_operation_fraction_,NVar1.x,NVar1.y
                  ,NVar2.width,NVar2.height,local_74,uStack_70,local_6c,uStack_68,2,0x3f800000);
    cVar3 = _NSEqualRects(CONCAT44(fStack_50,local_54),local_4c,fStack_48,
                          (int)*(undefined8 *)PTR_00336078,
                          (int)((ulonglong)*(undefined8 *)PTR_00336078 >> 0x20),
                          (int)*(undefined8 *)(PTR_00336078 + 8),
                          (int)((ulonglong)*(undefined8 *)(PTR_00336078 + 8) >> 0x20));
    if ((cVar3 == '\0') && (pvVar5 != (id)0x0)) {
      pvVar5 = _objc_msgSend(self,sel_visibleFrameColor);
      _objc_msgSend(pvVar5,sel_set);
      _NSFrameRect(CONCAT44(fStack_50,local_54),local_4c,fStack_48);
      pvVar5 = _objc_msgSend(self,sel_secondVisibleFrameColor);
      _objc_msgSend(pvVar5,sel_set);
      _NSFrameRect(CONCAT44(fStack_60,local_64),local_5c,fStack_58);
    }
    _objc_msgSend(pvVar4,sel_restoreGraphicsState);
  }
  return;
}

*/
- (void)drawRect:(NSRect)aRect
{
    [[self backgroundColor] set];
    NSRectFill([self bounds]);
    if (_cachedCardImage == nil && _card != nil) {
        [self updateCachedImage];
    }
    NSRect visible = [self visibleFrame];
    NSRect secondFrame = visible;
    if (_cachedCardImage == nil) {
        return;
    }
    NSSize imageSize = [_cachedCardImage size];
    id cardView = nil;
    if ([_delegate respondsToSelector:@selector(cardViewForCardNavigatorView:)]) {
        cardView = [_delegate cardViewForCardNavigatorView:self];
    }
    _cardRepresentationRect = [cardView viewBoundingRectForUserRect:[self cardRect]];
    NSRect frame = [self frame];
    float frameWidth = frame.size.width;
    float frameHeight = frame.size.height;
    NSPoint representationOrigin = _cardRepresentationRect.origin;
    visible.origin.x = visible.origin.x - representationOrigin.x;
    visible.origin.y = visible.origin.y - representationOrigin.y;
    _cardRepresentationRect.origin = NSZeroPoint;
    float scale;
    if (frameWidth < _cardRepresentationRect.size.width) {
        scale = _cardRepresentationRect.size.width / frameWidth;
        _cardRepresentationRect.size.width = _cardRepresentationRect.size.width / scale;
        _cardRepresentationRect.size.height = _cardRepresentationRect.size.height / scale;
    }
    else {
        scale = 1.0;
    }
    if (frameHeight < _cardRepresentationRect.size.height) {
        float heightScale = _cardRepresentationRect.size.height / frameHeight;
        _cardRepresentationRect.size.width = _cardRepresentationRect.size.width / heightScale;
        _cardRepresentationRect.size.height = _cardRepresentationRect.size.height / heightScale;
        scale = scale * heightScale;
    }
    visible.origin.x = visible.origin.x / scale;
    visible.origin.y = visible.origin.y / scale;
    visible.size.width = visible.size.width / scale;
    visible.size.height = visible.size.height / scale;
    NSRect clipped = NSIntersectionRect(visible, _cardRepresentationRect);
    float paddingX = (frameWidth - _cardRepresentationRect.size.width) * 0.5;
    float paddingY = (frameHeight - _cardRepresentationRect.size.height) * 0.5;
    _cardRepresentationRect.origin.x = _cardRepresentationRect.origin.x + paddingX;
    _cardRepresentationRect.origin.y = paddingY + _cardRepresentationRect.origin.y;
    float visibleY = ((_cardRepresentationRect.size.height - clipped.size.height) + paddingY) - clipped.origin.y;
    NSRect visibleRect = NSIntegralRect(NSMakeRect(paddingX + clipped.origin.x, visibleY, clipped.size.width, clipped.size.height));
    secondFrame = NSMakeRect(visibleRect.origin.x + 1.0, visibleRect.origin.y + 1.0, visibleRect.size.width - 2.0, visibleRect.size.height - 2.0);
    _cardRepresentationRect = NSIntegralRect(_cardRepresentationRect);
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    [context saveGraphicsState];
    [context setImageInterpolation:NSImageInterpolationHigh];
    [_cachedCardImage drawInRect:_cardRepresentationRect fromRect:NSMakeRect(0, 0, imageSize.width, imageSize.height) operation:NSCompositeSourceOver fraction:1.0];
    if (!NSEqualRects(visibleRect, NSZeroRect) && cardView != nil) {
        [[self visibleFrameColor] set];
        NSFrameRect(visibleRect);
        [[self secondVisibleFrameColor] set];
        NSFrameRect(secondFrame);
    }
    [context restoreGraphicsState];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00166aa3 @ 00166aa3, 232 bytes * /

void FUN_00166aa3(HSCardNavigatorView *self,SEL _cmd)

{
  id self_00;
  HSCardNavigatorView *local_14;
  undefined *local_10;
  
  self_00 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(self_00,sel_removeObserver_name_object_,self,*(undefined4 *)PTR_0033665c,0);
  _objc_msgSend(self->_cachedCardImage,sel_release);
  _objc_msgSend(self->_card,sel_removeObserver_,self);
  _objc_msgSend(self->_card,sel_release);
  _objc_msgSend(self->_backgroundColor,sel_release);
  _objc_msgSend(self->_visibleFrameColor,sel_release);
  local_14 = self;
  local_10 = PTR_s_NSView_00351f20;
  _objc_msgSendSuper(&local_14,sel_dealloc);
  return;
}

*/
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HSDeskPatternChangedNavigation object:nil];
    [_cachedCardImage release];
    [_card removeObserver:self];
    [_card release];
    [_backgroundColor release];
    [_visibleFrameColor release];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001658bc @ 001658bc, 163 bytes * /

id FUN_001658bc(HSCardNavigatorView *self,SEL _cmd,NSRect initWithFrame)

{
  id pvVar1;
  id self_00;
  HSCardNavigatorView *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_NSView_00351f20;
  pvVar1 = _objc_msgSendSuper(&local_14,sel_initWithFrame_,initWithFrame.origin,initWithFrame.size);
  if (pvVar1 != (id)0x0) {
    self_00 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    _objc_msgSend(self_00,sel_addObserver_selector_name_object_,pvVar1,sel_deskPatternChanged_,
                  *(undefined4 *)PTR_0033665c,0);
  }
  return pvVar1;
}

*/
- (id)initWithFrame:(NSRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deskPatternChanged:) name:HSDeskPatternChangedNavigation object:nil];
    }
    return self;
}

@end

