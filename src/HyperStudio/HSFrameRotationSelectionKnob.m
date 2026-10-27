#import "HSFrameRotationSelectionKnob.h"

@implementation HSFrameRotationSelectionKnob

/* i386 ivar offsets: _trackingKnobPosition=0x38, _usesTrackingKnobPosition=0x40, _boundingRegion=0x44 */

- (BOOL)canBeLocked
{
    return NO;
}

- (BOOL)overridesTrackingLoopCursor
{
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00050b56 @ 00050b56, 241 bytes * /

id FUN_00050b56(HSFrameRotationSelectionKnob *self,SEL _cmd,NSPoint cursorAtPoint,uint modifierFlags
               ,id inView,id owner)

{
  id pvVar1;
  int iVar2;
  int *piVar3;
  int iVar4;
  double dVar5;
  
  pvVar1 = _objc_msgSend(owner,sel_queryHyperInterface_,&DAT_003637d4);
  if (pvVar1 == (id)0x0) {
    dVar5 = 0.0;
  }
  else {
    dVar5 = _objc_msgSend_fpret(pvVar1,sel_rotationAngle);
  }
  iVar2 = (int)((dVar5 / 3.141592653589793 + 0.125) * 4.0);
  iVar4 = 0;
  if (iVar2 < 8) {
    iVar4 = iVar2;
  }
  switch(iVar4) {
  case 0:
    piVar3 = (int *)PTR_PTR_003362d8;
    break;
  case 1:
    piVar3 = (int *)PTR_PTR_003362cc;
    break;
  case 2:
    piVar3 = (int *)PTR_PTR_003362d0;
    break;
  case 3:
    piVar3 = (int *)PTR_PTR_003362c8;
    break;
  case 4:
    piVar3 = (int *)PTR_PTR_003362d4;
    break;
  case 5:
    piVar3 = (int *)PTR_PTR_003362dc;
    break;
  case 6:
    piVar3 = (int *)PTR_PTR_003362e4;
    break;
  case 7:
    piVar3 = (int *)PTR_PTR_003362e0;
    break;
  default:
    goto switchD_00050bdb_default;
  }
  if (*piVar3 == 0) {
switchD_00050bdb_default:
    pvVar1 = (id)0x0;
  }
  else {
    pvVar1 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*piVar3);
  }
  return pvVar1;
}

*/
- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inView:(id)aView owner:(id)aOwner
{
    id geometry = [aOwner queryHyperInterface:@protocol(HSGeometryAttributes)];
    double angle = 0.0;
    if (geometry != nil) {
        angle = [geometry rotationAngle];
    }
    int index = (int)((angle / M_PI + 0.125) * 4.0);
    if (index >= 8) {
        index = 0;
    }
    NSString *name;
    switch (index) {
        case 0: name = HSRotateRightCursor; break;
        case 1: name = HSRotateBRCursor; break;
        case 2: name = HSRotateBottomCursor; break;
        case 3: name = HSRotateBLCursor; break;
        case 4: name = HSRotateLeftCursor; break;
        case 5: name = HSRotateTLCursor; break;
        case 6: name = HSRotateTopCursor; break;
        case 7: name = HSRotateTRCursor; break;
        default: return nil;
    }
    return name != nil ? [HSCursor cursorNamed:name] : nil;
}

- (BOOL)prefersRegionInvalidation
{
    return YES;
}

- (void)invalidateCachedFrame
{
    [super invalidateCachedFrame];
    [self invalidateBoundingRegion];
}

- (void)invalidateBoundingRegion
{
    [_boundingRegion release];
    _boundingRegion = nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00050cb3 @ 00050cb3, 551 bytes * /

id FUN_00050cb3(HSFrameRotationSelectionKnob *self,SEL _cmd,id boundingRegionForOwner,NSRect frame,
               id inView)

{
  id pvVar1;
  id pvVar2;
  undefined4 *puVar3;
  HSFrameRotationSelectionKnob *local_2c;
  undefined *local_28;
  
  puVar3 = (undefined4 *)&stack0xffffff74;
  pvVar1 = self->_boundingRegion;
  if (pvVar1 == (id)0x0) {
    local_2c = self;
    local_28 = PTR_s_HSFrameManipulationSelectionKnob_0034e290;
    pvVar1 = _objc_msgSendSuper(&local_2c,sel_boundingRegionForOwner_frame_inView_);
    pvVar1 = _objc_msgSend(pvVar1,sel_mutableCopy);
    pvVar2 = _objc_msgSend(self,sel_getHandleStartPoint_endPoint_centerRect_forOwner_frame_inView_);
    if ((char)pvVar2 != '\0') {
      _objc_msgSend(cls_HSRegion,sel_regionWithLineFromPoint_toPoint_strokeThickness_);
      _objc_msgSend(pvVar1,sel_addRegion_);
      _NSInsetRect();
      puVar3 = (undefined4 *)&stack0xffffff70;
      _objc_msgSend(pvVar1,sel_addRect_);
    }
    puVar3[1] = sel_copy;
    *puVar3 = pvVar1;
    puVar3[-1] = 0x50eb7;
    pvVar2 = _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
    self->_boundingRegion = pvVar2;
    puVar3[1] = sel_release;
    *puVar3 = pvVar1;
    puVar3[-1] = 0x50ecf;
    _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
    pvVar1 = self->_boundingRegion;
  }
  return pvVar1;
}

*/
- (id)boundingRegionForOwner:(id)aOwner frame:(NSRect)aFrame inView:(id)aView
{
    if (_boundingRegion == nil) {
        id region = [[super boundingRegionForOwner:aOwner frame:aFrame inView:aView] mutableCopy];
        NSPoint start = NSZeroPoint;
        NSPoint end = NSZeroPoint;
        NSRect center = NSZeroRect;
        if ([self getHandleStartPoint:&start endPoint:&end centerRect:&center forOwner:aOwner frame:aFrame inView:aView]) {
            [region addRegion:[HSRegion regionWithLineFromPoint:start toPoint:end strokeThickness:1.0]];
            [region addRect:NSInsetRect(center, -1.0, -1.0)];
        }
        _boundingRegion = [region copy];
        [region release];
    }
    return _boundingRegion;
}

- (BOOL)usesTrackingKnobPosition
{
    return _usesTrackingKnobPosition;
}

- (void)setUsesTrackingKnobPosition:(BOOL)aPosition
{
    _usesTrackingKnobPosition = aPosition;
    [self invalidateCachedFrame];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000508a3 @ 000508a3, 14 bytes * /

ulonglong FUN_000508a3(HSFrameRotationSelectionKnob *self,SEL _cmd)

{
  ulonglong uVar1;
  
  uVar1._0_4_ = (self->_trackingKnobPosition).x;
  uVar1._4_4_ = (self->_trackingKnobPosition).y;
  return uVar1;
}

*/
- (NSPoint)trackingKnobPosition
{
    return _trackingKnobPosition;
}

- (void)setTrackingKnobPosition:(NSPoint)aPosition
{
    (_trackingKnobPosition).x = aPosition.x;
    (_trackingKnobPosition).y = aPosition.y;
    [self invalidateCachedFrame];
}

- (void)setBeingTracked:(BOOL)aTracked
{
    [super setBeingTracked:aTracked];
    if (![self isBeingTracked]) {
        _usesTrackingKnobPosition = NO;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00050f35 @ 00050f35, 253 bytes * /

void FUN_00050f35(HSFrameRotationSelectionKnob *self,SEL _cmd,NSRect drawWithFrame,id owner,
                 id inView,NSRect invalidRect)

{
  id self_00;
  id pvVar1;
  NSPoint NVar2;
  NSSize NVar3;
  id pvVar4;
  HSFrameRotationSelectionKnob *local_1c;
  undefined *local_18;
  
  NVar2 = drawWithFrame.origin;
  NVar3 = drawWithFrame.size;
  pvVar1 = owner;
  pvVar4 = inView;
  self_00 = _objc_msgSend(self,sel_rotationHandlePathWithFrame_forOwner_inView_,drawWithFrame.origin
                          ,drawWithFrame.size,owner,inView);
  if (self_00 != (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_class,NVar2,NVar3,pvVar1,pvVar4);
    pvVar1 = _objc_msgSend(pvVar1,sel_selectionFrameColor);
    _objc_msgSend(pvVar1,sel_set);
    _objc_msgSend(self_00,sel_stroke);
  }
  local_1c = self;
  local_18 = PTR_s_HSFrameManipulationSelectionKnob_0034e290;
  _objc_msgSendSuper(&local_1c,sel_drawWithFrame_owner_inView_invalidRect_,drawWithFrame.origin,
                     drawWithFrame.size,owner,inView,invalidRect.origin,invalidRect.size);
  return;
}

*/
- (void)drawWithFrame:(NSRect)aFrame owner:(id)aOwner inView:(id)aView invalidRect:(NSRect)aRect
{
    NSBezierPath *path = [self rotationHandlePathWithFrame:aFrame forOwner:aOwner inView:aView];
    if (path != nil) {
        [[[self class] selectionFrameColor] set];
        [path stroke];
    }
    [super drawWithFrame:aFrame owner:aOwner inView:aView invalidRect:aRect];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00051032 @ 00051032, 427 bytes * /

NSRect * FUN_00051032(NSRect *__return_storage_ptr__,HSFrameRotationSelectionKnob *self,SEL _cmd,
                     id boundingRectForOwner,NSRect frame,id inView)

{
  id self_00;
  NSRect *pNVar1;
  float local_5c;
  float local_58;
  float local_54;
  float local_50;
  undefined4 local_4c;
  undefined4 local_48;
  undefined4 local_44;
  undefined4 local_40;
  undefined4 local_3c;
  undefined4 uStack_38;
  undefined4 local_34;
  undefined4 uStack_30;
  HSFrameRotationSelectionKnob *local_2c;
  undefined *local_28;
  float local_24;
  float fStack_20;
  float local_1c;
  float fStack_18;
  
  local_2c = self;
  local_28 = PTR_s_HSFrameManipulationSelectionKnob_0034e290;
  _objc_msgSendSuper_stret
            (&local_24,&local_2c,sel_boundingRectForOwner_frame_inView_,boundingRectForOwner,
             frame.origin.x,frame.origin.y,frame.size,inView);
  self_00 = _objc_msgSend(self,sel_rotationHandlePathWithFrame_forOwner_inView_,frame.origin.x,
                          frame.origin.y,frame.size.width,frame.size.height,boundingRectForOwner,
                          inView);
  if (self_00 == (id)0x0) {
    pNVar1 = (NSRect *)0x0;
  }
  else {
    _objc_msgSend_stret(&local_3c,self_00,sel_bounds);
    _NSInsetRect(&local_4c,local_3c,uStack_38,local_34,uStack_30,0xbf800000,0xbf800000);
    local_3c = local_4c;
    uStack_38 = local_48;
    local_34 = local_44;
    uStack_30 = local_40;
    pNVar1 = (NSRect *)
             _NSUnionRect(&local_5c,local_4c,local_48,local_44,local_40,local_24,fStack_20,local_1c,
                          fStack_18);
    local_24 = local_5c;
    fStack_20 = local_58;
    fStack_18 = local_50;
    local_1c = local_54;
  }
  (__return_storage_ptr__->origin).x = local_24;
  (__return_storage_ptr__->origin).y = fStack_20;
  (__return_storage_ptr__->size).width = local_1c;
  (__return_storage_ptr__->size).height = fStack_18;
  return pNVar1;
}

*/
- (NSRect)boundingRectForOwner:(id)aOwner frame:(NSRect)aFrame inView:(id)aView
{
    NSRect rect = [super boundingRectForOwner:aOwner frame:aFrame inView:aView];
    NSBezierPath *path = [self rotationHandlePathWithFrame:aFrame forOwner:aOwner inView:aView];
    if (path != nil) {
        rect = NSUnionRect(NSInsetRect([path bounds], -1.0, -1.0), rect);
    }
    return rect;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00050915 @ 00050915, 347 bytes * /

id FUN_00050915(HSFrameRotationSelectionKnob *self,SEL _cmd,NSRect rotationHandlePathWithFrame,
               id forOwner,id inView)

{
  id pvVar1;
  undefined4 local_2c;
  undefined4 uStack_28;
  undefined4 local_24;
  undefined4 uStack_20;
  undefined4 local_1c;
  undefined4 local_18;
  undefined4 local_14;
  undefined4 local_10;
  
  local_1c = *(undefined4 *)PTR_00336074;
  local_18 = *(undefined4 *)(PTR_00336074 + 4);
  local_2c = *(undefined4 *)PTR_00336078;
  uStack_28 = *(undefined4 *)(PTR_00336078 + 4);
  local_24 = *(undefined4 *)(PTR_00336078 + 8);
  uStack_20 = *(undefined4 *)(PTR_00336078 + 0xc);
  local_14 = local_1c;
  local_10 = local_18;
  pvVar1 = _objc_msgSend(self,sel_getHandleStartPoint_endPoint_centerRect_forOwner_frame_inView_,
                         &local_14,&local_1c,&local_2c,forOwner,rotationHandlePathWithFrame.origin,
                         rotationHandlePathWithFrame.size,inView);
  if ((char)pvVar1 == '\0') {
    pvVar1 = (id)0x0;
  }
  else {
    pvVar1 = _objc_msgSend(cls_NSBezierPath,sel_bezierPathWithOvalInRect_,
                           CONCAT44(uStack_28,local_2c),CONCAT44(uStack_20,local_24),
                           rotationHandlePathWithFrame.origin,rotationHandlePathWithFrame.size,
                           inView);
    _objc_msgSend(pvVar1,sel_moveToPoint_,local_14,local_10);
    _objc_msgSend(pvVar1,sel_lineToPoint_,local_1c,local_18);
    _objc_msgSend(pvVar1,sel_setLineWidth_,0x3f000000);
  }
  return pvVar1;
}

*/
- (id)rotationHandlePathWithFrame:(NSRect)aFrame forOwner:(id)aOwner inView:(id)aView
{
    NSPoint start = NSZeroPoint;
    NSPoint end = NSZeroPoint;
    NSRect center = NSZeroRect;
    if (![self getHandleStartPoint:&start endPoint:&end centerRect:&center forOwner:aOwner frame:aFrame inView:aView]) {
        return nil;
    }
    NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:center];
    [path moveToPoint:start];
    [path lineToPoint:end];
    [path setLineWidth:0.5];
    return path;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000511dd @ 000511dd, 581 bytes * /

BOOL FUN_000511dd(HSFrameRotationSelectionKnob *self,SEL _cmd,NSPoint *getHandleStartPoint,
                 NSPoint *endPoint,NSRect *centerRect,id forOwner,NSRect frame,id inView)

{
  BOOL BVar1;
  id pvVar2;
  float extraout_EDX;
  float extraout_EDX_00;
  undefined8 in_stack_ffffff9c;
  undefined8 uVar3;
  id local_3c;
  float fStack_38;
  id local_34;
  float fStack_30;
  float local_2c;
  float local_28;
  float local_24;
  float local_20;
  float local_1c;
  float local_18;
  
  local_3c = *(id *)PTR_00336078;
  fStack_38 = *(float *)(PTR_00336078 + 4);
  local_34 = *(id *)(PTR_00336078 + 8);
  fStack_30 = *(float *)(PTR_00336078 + 0xc);
  uVar3 = CONCAT44((int)((ulonglong)in_stack_ffffff9c >> 0x20),&DAT_003637d4);
  pvVar2 = _objc_msgSend(forOwner,sel_queryHyperInterface_,&DAT_003637d4);
  if ((pvVar2 == (id)0x0) || (inView == (id)0x0)) {
    BVar1 = '\0';
  }
  else {
    local_34 = _objc_msgSend(pvVar2,sel_size,uVar3);
    fStack_38 = extraout_EDX * 0.5 + fStack_38;
    local_3c = (id)((float)local_34 * 0.5 + (float)local_3c);
    _objc_msgSend_stret(&local_2c,pvVar2,sel_affineTransform);
    local_24 = local_24 * fStack_38;
    fStack_38 = local_28 * (float)local_3c + local_20 * fStack_38 + local_18;
    local_3c = (id)(local_1c + local_2c * (float)local_3c + local_24);
    pvVar2 = _objc_msgSend(inView,sel_convertPointFromUserSpaceToViewSpace_);
    local_34 = *(id *)PTR_0033607c;
    fStack_30 = *(float *)(PTR_0033607c + 4);
    local_3c = pvVar2;
    fStack_38 = extraout_EDX_00;
    _NSInsetRect(&local_3c,CONCAT44(extraout_EDX_00,pvVar2),*(undefined8 *)PTR_0033607c,0xbf800000,
                 0xbf800000);
    if (getHandleStartPoint != (NSPoint *)0x0) {
      getHandleStartPoint->x = (float)pvVar2;
      getHandleStartPoint->y = extraout_EDX_00;
    }
    if (endPoint != (NSPoint *)0x0) {
      endPoint->x = frame.size.width * 0.5 + frame.origin.x;
      endPoint->y = frame.size.height * 0.5 + frame.origin.y;
    }
    if (centerRect == (NSRect *)0x0) {
      BVar1 = '\x01';
    }
    else {
      (centerRect->origin).x = (float)local_3c;
      (centerRect->origin).y = fStack_38;
      (centerRect->size).width = (float)local_34;
      (centerRect->size).height = fStack_30;
      BVar1 = '\x01';
    }
  }
  return BVar1;
}

*/
- (BOOL)getHandleStartPoint:(NSPoint *)aPoint endPoint:(NSPoint *)aPoint2 centerRect:(NSRect *)aRect forOwner:(id)aOwner frame:(NSRect)aFrame inView:(id)aView
{
    id geometry = [aOwner queryHyperInterface:@protocol(HSGeometryAttributes)];
    if (geometry == nil || aView == nil) {
        return NO;
    }
    NSSize size = [geometry size];
    CGFloat x = size.width * 0.5;
    CGFloat y = size.height * 0.5;
    CGAffineTransform transform = [geometry affineTransform];
    NSPoint point = NSMakePoint(transform.tx + transform.a * x + transform.c * y, transform.b * x + transform.d * y + transform.ty);
    point = [aView convertPointFromUserSpaceToViewSpace:point];
    NSRect center = NSInsetRect(NSMakeRect(point.x, point.y, 0.0, 0.0), -1.0, -1.0);
    if (aPoint != NULL) {
        *aPoint = point;
    }
    if (aPoint2 != NULL) {
        *aPoint2 = NSMakePoint(aFrame.size.width * 0.5 + aFrame.origin.x, aFrame.size.height * 0.5 + aFrame.origin.y);
    }
    if (aRect != NULL) {
        *aRect = center;
    }
    return YES;
}

- (id)createSelectionTrackerForModifierFlags:(NSUInteger)aFlags
{
    return [[HSFrameRotationSelectionTracker alloc] init];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00051422 @ 00051422, 291 bytes * /

NSRect * FUN_00051422(NSRect *__return_storage_ptr__,HSFrameRotationSelectionKnob *self,SEL _cmd,
                     id calculateFrameForOwner,id inView)

{
  id pvVar1;
  float local_34;
  float local_30;
  float local_2c;
  float local_28;
  HSFrameRotationSelectionKnob *local_24;
  undefined *local_20;
  float local_1c;
  float fStack_18;
  float local_14;
  float fStack_10;
  
  local_24 = self;
  local_20 = PTR_s_HSFrameManipulationSelectionKnob_0034e290;
  _objc_msgSendSuper_stret(&local_1c,&local_24,sel_calculateFrameForOwner_inView_);
  pvVar1 = _objc_msgSend(self,sel_isBeingTracked);
  if (((char)pvVar1 != '\0') && (self->_usesTrackingKnobPosition != '\0')) {
    local_1c = (self->_trackingKnobPosition).x;
    fStack_18 = (self->_trackingKnobPosition).y;
    _NSOffsetRect(&local_34,self->_trackingKnobPosition,CONCAT44(fStack_10,local_14),local_14 * -0.5
                  ,fStack_10 * -0.5);
    local_1c = local_34;
    fStack_18 = local_30;
    local_14 = local_2c;
    fStack_10 = local_28;
  }
  (__return_storage_ptr__->origin).x = local_1c;
  (__return_storage_ptr__->origin).y = fStack_18;
  (__return_storage_ptr__->size).width = local_14;
  (__return_storage_ptr__->size).height = fStack_10;
  return __return_storage_ptr__;
}

*/
- (NSRect)calculateFrameForOwner:(id)aOwner inView:(id)aView
{
    NSRect frame = [super calculateFrameForOwner:aOwner inView:aView];
    if ([self isBeingTracked] && _usesTrackingKnobPosition) {
        frame.origin = _trackingKnobPosition;
        frame = NSOffsetRect(frame, frame.size.width * -0.5, frame.size.height * -0.5);
    }
    return frame;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00050897 @ 00050897, 12 bytes * /

ulonglong FUN_00050897(HSFrameRotationSelectionKnob *self,SEL _cmd)

{
  return 0x41a00000;
}

*/
- (NSSize)framePositionOffset
{
    return NSMakeSize(20.0, 0.0);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00050888 @ 00050888, 15 bytes * /

ulonglong FUN_00050888(HSFrameRotationSelectionKnob *self,SEL _cmd)

{
  return 0x3f0000003f800000;
}

*/
- (NSSize)framePositionFactor
{
    return NSMakeSize(1.0, 0.5);
}

- (void)dealloc
{
    [_boundingRegion release];
    [super dealloc];
}

@end

