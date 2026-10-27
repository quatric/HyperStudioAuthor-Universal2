#import "HSShadowView.h"

@implementation HSShadowView

/* i386 ivar offsets: _shadowSubview=0x50, _backgroundColor=0x54, _shadow=0x58, _cachedShadowRect=0x5c, _cachedImage=0x6c, _cachingDisabled=0x70, _isActive=0x71 */

- (void)viewDidEndLiveResize
{
    _cachingDisabled = NO;
    [self setNeedsDisplay:YES];
}

- (void)viewWillStartLiveResize
{
    _cachingDisabled = YES;
    [self setNeedsDisplay:YES];
}

- (void)setShadow:(id)aShadow
{
    if (_shadow != aShadow) {
        [_shadow release];
        _shadow = [aShadow retain];
        [self invalidateCache];
        [self setNeedsDisplay:YES];
    }
}

- (id)shadow
{
    id pvVar1;
    id pvVar1_3;

    pvVar1 = _shadow;
    if (pvVar1 == nil) {
        pvVar1_3 = [[SMKShadow alloc] init];
        _shadow = pvVar1_3;
        [pvVar1_3 setShadowOffset:NSMakeSize(0, -1.0f)];
        [_shadow setShadowBlurRadius:5.0f];
        pvVar1 = _shadow;
    }
    return pvVar1;
}

- (void)setActive:(BOOL)aActive
{
    if ((aActive != NO) != (BOOL)_isActive) {
        _isActive = aActive != NO;
        [self setNeedsDisplay:YES];
    }
}

- (BOOL)isActive
{
    return _isActive;
}

- (id)activeBorderColor
{
    return [NSColor orangeColor];
}

- (void)setBackgroundColor:(id)aColor
{
    if (_backgroundColor != aColor) {
        [_backgroundColor release];
        _backgroundColor = [aColor retain];
        [self invalidateCache];
        [self setNeedsDisplay:YES];
    }
}

- (id)backgroundColor
{
    NSColor *pvVar1;

    pvVar1 = _backgroundColor;
    if (pvVar1 == nil) {
        pvVar1 = [NSColor whiteColor];
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00065cb7 @ 00065cb7, 256 bytes * /

id FUN_00065cb7(HSShadowView *self,SEL _cmd,NSPoint hitTest)

{
  char cVar1;
  id pvVar2;
  id *ppvVar3;
  id local_50;
  HSShadowView *local_2c;
  undefined *local_28;
  undefined1 local_24 [20];
  
  ppvVar3 = (id *)&stack0xffffffb4;
  local_50 = (id)0x65cdb;
  pvVar2 = _objc_msgSend(self,sel_superview);
  if (pvVar2 != (id)0x0) {
    local_50 = (id)0x65cf8;
    _objc_msgSend(self,sel_superview);
    local_50 = (id)0x65d27;
    pvVar2 = _objc_msgSend(self,sel_convertPoint_fromView_);
    local_50 = (id)0x65d47;
    _objc_msgSend_stret(local_24,self,sel_bounds);
    ppvVar3 = &local_50;
    local_50 = pvVar2;
    cVar1 = _NSPointInRect();
    if (cVar1 != '\0') {
      return self;
    }
  }
  local_2c = self;
  local_28 = PTR_s_NSView_0034e590;
  ppvVar3[3] = (id)hitTest.y;
  ppvVar3[2] = (id)hitTest.x;
  ppvVar3[1] = sel_hitTest_;
  *ppvVar3 = &local_2c;
  ppvVar3[-1] = (id)0x65db5;
  pvVar2 = _objc_msgSendSuper(*ppvVar3,ppvVar3[1]);
  return pvVar2;
}

*/
- (id)hitTest:(NSPoint)aTest
{
    if ([self superview] != nil) {
        NSPoint local = [self convertPoint:aTest fromView:[self superview]];
        if (NSPointInRect(local, [self bounds])) {
            return self;
        }
    }
    return [super hitTest:aTest];
}

- (BOOL)becomeFirstResponder
{
    if (![self isActive]) {
        [self setActive:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSShadowViewDidBecomeActiveNotification" object:self];
    }
    return YES;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00065882 @ 00065882, 184 bytes * /

void FUN_00065882(HSShadowView *self,SEL _cmd,NSRect drawRect)

{
  id pvVar1;
  HSShadowView *self_00;
  SEL op;
  
  if (self->_cachingDisabled == '\0') {
    self_00 = _objc_msgSend(self,sel_cachedImage);
    pvVar1 = *(id *)PTR_00336074;
    op = sel_compositeToPoint_operation_;
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_shadowRectPath);
    self_00 = self;
    op = sel_drawShadowWithPath_;
  }
  _objc_msgSend(self_00,op,pvVar1);
  if (self->_isActive != '\0') {
    pvVar1 = _objc_msgSend(self,sel_shadowRectPath,pvVar1);
    _objc_msgSend(self,sel_drawBorderWithPath_,pvVar1);
  }
  return;
}

*/
- (void)drawRect:(NSRect)aRect
{
    if (!_cachingDisabled) {
        [[self cachedImage] compositeToPoint:NSZeroPoint operation:NSCompositeSourceOver];
    } else {
        [self drawShadowWithPath:[self shadowRectPath]];
    }
    if (_isActive) {
        [self drawBorderWithPath:[self shadowRectPath]];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00065db7 @ 00065db7, 377 bytes * /

id FUN_00065db7(HSShadowView *self,SEL _cmd)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  int *piVar4;
  undefined8 local_34;
  int local_2c;
  int iStack_28;
  undefined1 local_24 [20];
  
  piVar4 = (int *)&stack0xffffffa4;
  if (self->_cachingDisabled == '\0') {
    pvVar2 = (id)0x0;
    if (self->_cachedImage != (id)0x0) {
      _objc_msgSend_stret(local_24,self,sel_shadowRect);
      piVar4 = (int *)&stack0xffffffa0;
      cVar1 = _NSEqualRects();
      if (cVar1 == '\0') {
        _objc_msgSend(self,sel_invalidateCache);
      }
      pvVar2 = self->_cachedImage;
    }
    if (pvVar2 == (id)0x0) {
      piVar4[1] = (int)sel_shadowRectPath;
      *piVar4 = (int)self;
      piVar4[-1] = 0x65e59;
      pvVar2 = _objc_msgSend((id)*piVar4,(SEL)piVar4[1]);
      if (pvVar2 != (id)0x0) {
        piVar4[2] = (int)sel_bounds;
        piVar4[1] = (int)self;
        *piVar4 = (int)&local_34;
        piVar4[-1] = 0x65e7c;
        _objc_msgSend_stret((void *)*piVar4,(id)piVar4[1],(SEL)piVar4[2]);
        *piVar4 = (int)sel_alloc;
        piVar4[-1] = (int)cls_NSImage;
        piVar4[-2] = 0x65e97;
        pvVar3 = _objc_msgSend((id)piVar4[-1],(SEL)*piVar4);
        piVar4[2] = iStack_28;
        piVar4[1] = local_2c;
        *piVar4 = (int)sel_initWithSize_;
        piVar4[-1] = (int)pvVar3;
        piVar4[-2] = 0x65ebf;
        pvVar3 = _objc_msgSend((id)piVar4[-1],(SEL)*piVar4);
        self->_cachedImage = pvVar3;
        *piVar4 = (int)sel_lockFocus;
        piVar4[-1] = (int)pvVar3;
        piVar4[-2] = 0x65ed4;
        _objc_msgSend((id)piVar4[-1],(SEL)*piVar4);
        *(ulonglong *)(piVar4 + 1) = CONCAT44(iStack_28,local_2c);
        *(undefined8 *)(piVar4 + -1) = local_34;
        piVar4[3] = 0;
        piVar4[-2] = 0x65ef6;
        _NSRectFillUsingOperation();
        piVar4[1] = (int)pvVar2;
        *piVar4 = (int)sel_drawShadowWithPath_;
        piVar4[-1] = (int)self;
        piVar4[-2] = 0x65f0c;
        _objc_msgSend((id)piVar4[-1],(SEL)*piVar4);
        pvVar2 = self->_cachedImage;
        *piVar4 = (int)sel_unlockFocus;
        piVar4[-1] = (int)pvVar2;
        piVar4[-2] = 0x65f21;
        _objc_msgSend((id)piVar4[-1],(SEL)*piVar4);
      }
    }
    pvVar2 = self->_cachedImage;
  }
  else {
    pvVar2 = (id)0x0;
  }
  return pvVar2;
}

*/
- (id)cachedImage
{
    if (_cachingDisabled) {
        return nil;
    }
    if (_cachedImage != nil) {
        /* the original never stores _cachedShadowRect, so a cached image is always dropped here */
        if (!NSEqualRects(_cachedShadowRect, [self shadowRect])) {
            [self invalidateCache];
        }
    }
    if (_cachedImage == nil) {
        id path = [self shadowRectPath];
        if (path != nil) {
            NSRect bounds = [self bounds];
            _cachedImage = [[NSImage alloc] initWithSize:bounds.size];
            [_cachedImage lockFocus];
            NSRectFillUsingOperation(bounds, NSCompositeClear);
            [self drawShadowWithPath:path];
            [_cachedImage unlockFocus];
        }
    }
    return _cachedImage;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000657dd @ 000657dd, 165 bytes * /

void FUN_000657dd(HSShadowView *self,SEL _cmd,id drawBorderWithPath)

{
  id self_00;
  
  if (drawBorderWithPath != (id)0x0) {
    _objc_msgSend(cls_NSGraphicsContext,sel_saveGraphicsState);
    self_00 = _objc_msgSend(self,sel_activeBorderColor);
    _objc_msgSend(self_00,sel_set);
    _objc_msgSend(drawBorderWithPath,sel_setLineWidth_,0x40000000);
    _objc_msgSend(drawBorderWithPath,sel_stroke);
    _objc_msgSend(cls_NSGraphicsContext,sel_restoreGraphicsState);
  }
  return;
}

*/
- (void)drawBorderWithPath:(id)aPath
{
    if (aPath != nil) {
        [NSGraphicsContext saveGraphicsState];
        [[self activeBorderColor] set];
        [aPath setLineWidth:2.0f];
        [aPath stroke];
        [NSGraphicsContext restoreGraphicsState];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0006572e @ 0006572e, 175 bytes * /

void FUN_0006572e(HSShadowView *self,SEL _cmd,id drawShadowWithPath)

{
  id pvVar1;
  
  if (drawShadowWithPath != (id)0x0) {
    _objc_msgSend(cls_NSGraphicsContext,sel_saveGraphicsState);
    pvVar1 = _objc_msgSend(self,sel_shadow);
    _objc_msgSend(pvVar1,sel_set);
    pvVar1 = _objc_msgSend(self,sel_backgroundColor);
    _objc_msgSend(pvVar1,sel_set);
    _objc_msgSend(drawShadowWithPath,sel_fill);
    _objc_msgSend(cls_NSGraphicsContext,sel_restoreGraphicsState);
  }
  return;
}

*/
- (void)drawShadowWithPath:(id)aPath
{
    if (aPath != nil) {
        [NSGraphicsContext saveGraphicsState];
        [[self shadow] set];
        [[self backgroundColor] set];
        [aPath fill];
        [NSGraphicsContext restoreGraphicsState];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00065f30 @ 00065f30, 138 bytes * /

id FUN_00065f30(HSShadowView *self,SEL _cmd)

{
  char cVar1;
  id pvVar2;
  undefined8 local_1c;
  undefined8 local_14;
  
  _objc_msgSend_stret(&local_1c,self,sel_shadowRect);
  cVar1 = _NSIsEmptyRect(local_1c,local_14);
  if (cVar1 == '\0') {
    pvVar2 = _objc_msgSend(cls_NSBezierPath,sel_smkRoundedBorderPathWithRect_cornerRadius_,local_1c,
                           local_14,0x40c00000);
  }
  else {
    pvVar2 = (id)0x0;
  }
  return pvVar2;
}

*/
- (id)shadowRectPath
{
    NSRect rect = [self shadowRect];
    if (NSIsEmptyRect(rect)) {
        return nil;
    }
    return [NSBezierPath smkRoundedBorderPathWithRect:rect cornerRadius:6.0f];
}

- (void)willRemoveSubview:(id)aSubview
{
    if (_shadowSubview == aSubview) {
        _shadowSubview = nil;
        [self invalidateCache];
    }
}

- (void)invalidateCache
{
    float fVar1;

    [_cachedImage release];
    _cachedImage = nil;
    fVar1 = NSZeroRect.origin.y;
    (_cachedShadowRect).origin.x = NSZeroRect.origin.x;
    (_cachedShadowRect).origin.y = fVar1;
    (_cachedShadowRect).size.width = NSZeroRect.size.width;
    (_cachedShadowRect).size.height = NSZeroRect.size.height;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00065fba @ 00065fba, 207 bytes * /

NSRect * FUN_00065fba(NSRect *__return_storage_ptr__,HSShadowView *self,SEL _cmd)

{
  id self_00;
  HSShadowView *extraout_EAX;
  float local_34;
  float local_30;
  float local_2c;
  float local_28;
  undefined8 local_24;
  undefined8 local_1c;
  
  local_34 = *(float *)PTR_00336078;
  local_30 = *(float *)(PTR_00336078 + 4);
  local_2c = *(float *)(PTR_00336078 + 8);
  local_28 = *(float *)(PTR_00336078 + 0xc);
  self_00 = self->_shadowSubview;
  if (self_00 != (id)0x0) {
    _objc_msgSend_stret(&local_24,self_00,sel_bounds);
    _objc_msgSend_stret(&local_34,self,sel_convertRect_fromView_,local_24,local_1c,self_00);
    self = extraout_EAX;
  }
  (__return_storage_ptr__->origin).x = local_34;
  (__return_storage_ptr__->origin).y = local_30;
  (__return_storage_ptr__->size).width = local_2c;
  (__return_storage_ptr__->size).height = local_28;
  return (NSRect *)self;
}

*/
- (NSRect)shadowRect
{
    NSRect rect = NSZeroRect;
    if (_shadowSubview != nil) {
        rect = [self convertRect:[_shadowSubview bounds] fromView:_shadowSubview];
    }
    return rect;
}

- (void)dealloc
{
    [_backgroundColor release];
    [_shadow release];
    [_cachedImage release];
    _cachedImage = nil;
    [super dealloc];
}

@end

