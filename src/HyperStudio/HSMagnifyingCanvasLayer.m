#import "HSMagnifyingCanvasLayer.h"

@implementation HSMagnifyingCanvasLayer

/* i386 ivar offsets: _selectionRect=0x1c, _owner=0x2c, _layerContext=0x30 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_000d9471 @ 000d9471, 211 bytes * /

void FUN_000d9471(HSMagnifyingCanvasLayer *self,SEL _cmd,NSRect renderRect)

{
  char cVar1;
  id pvVar2;
  
  cVar1 = _NSIsEmptyRect((self->_selectionRect).origin,(self->_selectionRect).size);
  if (cVar1 == '\0') {
    pvVar2 = _objc_msgSend(cls_HSTrackingRectCanvasItem,sel_trackingRectFillColor);
    _objc_msgSend(pvVar2,sel_set);
    _NSRectFillUsingOperation((self->_selectionRect).origin,(self->_selectionRect).size,2);
    pvVar2 = _objc_msgSend(cls_HSTrackingRectCanvasItem,sel_trackingRectColor);
    _objc_msgSend(pvVar2,sel_set);
    _NSFrameRectWithWidth((self->_selectionRect).origin,(self->_selectionRect).size,0x3f800000);
  }
  return;
}

*/
- (void)renderRect:(NSRect)aRect
{
    if (!NSIsEmptyRect(_selectionRect)) {
        [[HSTrackingRectCanvasItem trackingRectFillColor] set];
        NSRectFillUsingOperation(_selectionRect, NSCompositeSourceOver);
        [[HSTrackingRectCanvasItem trackingRectColor] set];
        NSFrameRectWithWidth(_selectionRect, 1.0f);
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000d9544 @ 000d9544, 114 bytes * /

void FUN_000d9544(HSMagnifyingCanvasLayer *self,SEL _cmd)

{
  char cVar1;
  id self_00;
  
  cVar1 = _NSIsEmptyRect((self->_selectionRect).origin,(self->_selectionRect).size);
  if (cVar1 == '\0') {
    self_00 = _objc_msgSend(self,sel_renderingView);
    _objc_msgSend(self_00,sel_setNeedsDisplayOpenGLSurfaceInRect_,(self->_selectionRect).origin,
                  (self->_selectionRect).size);
  }
  return;
}

*/
- (void)invalidateDisplay
{
    if (!NSIsEmptyRect(_selectionRect)) {
        [[self renderingView] setNeedsDisplayOpenGLSurfaceInRect:_selectionRect];
    }
}

- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo
{
    if (aView != NO) {
        *aInfo = _owner;
        return self;
    }
    return nil;
}

- (void)handleFlagsChanged:(id)aChanged inTrackingLoop:(id)aLoop
{
    [self resetCurrentCursor];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000d95b6 @ 000d95b6, 984 bytes * /

void FUN_000d95b6(HSMagnifyingCanvasLayer *self,SEL _cmd,id handleMouseUp,id inTrackingLoop)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  float extraout_EDX;
  undefined4 *puVar4;
  undefined4 *puVar5;
  undefined *puVar6;
  longdouble lVar7;
  float fVar8;
  float fVar9;
  double dVar10;
  double dVar11;
  undefined1 local_34 [8];
  float local_2c;
  float local_28;
  HSMagnifyingCanvasLayer *local_24;
  undefined *local_20;
  undefined1 local_1c [16];
  
  puVar6 = PTR_00336078;
  puVar4 = (undefined4 *)&stack0xffffff74;
  puVar5 = (undefined4 *)&stack0xffffff74;
  fVar9 = *(float *)(PTR_00336078 + 4);
  (self->_selectionRect).origin.x = *(float *)PTR_00336078;
  (self->_selectionRect).origin.y = fVar9;
  (self->_selectionRect).size.width = *(float *)(puVar6 + 8);
  (self->_selectionRect).size.height = *(float *)(puVar6 + 0xc);
  pvVar2 = _objc_msgSend(self,sel_activeLayerMode);
  if (pvVar2 == (id)0x2) {
    local_24 = self;
    local_20 = PTR_s_HSDragCardViewCanvasLayer_00350390;
    _objc_msgSendSuper(&local_24,sel_handleMouseUp_inTrackingLoop_);
    return;
  }
  _objc_msgSend(self,sel_invalidateDisplay);
  pvVar3 = _objc_msgSend(self,sel_renderingView);
  _objc_msgSend(handleMouseUp,sel_locationInWindow);
  pvVar2 = _objc_msgSend(pvVar3,sel_convertPoint_fromView_);
  if (self->_layerContext == (id)0x0) {
    return;
  }
  cVar1 = _NSEqualPoints();
  if (cVar1 == '\0') {
    if (self->_owner == (id)0x0) {
      return;
    }
    _objc_msgSend_stret(local_1c,pvVar3,sel_visibleRect);
    _objc_msgSend_stret(local_34,pvVar3,sel_viewBoundingRectForUserRect_);
    puVar4 = (undefined4 *)&stack0xffffff6c;
    fVar8 = ABS((self->super)._startPoint.y - extraout_EDX);
    fVar9 = ABS((self->super)._startPoint.x - (float)pvVar2);
    if (fVar9 < fVar8) {
      fVar9 = local_28 / fVar8;
    }
    else {
      fVar9 = local_2c / fVar9;
    }
    dVar10 = _objc_msgSend_fpret(self->_layerContext,sel_zoomFactor);
    fVar8 = (float)dVar10;
    dVar10 = _objc_msgSend_fpret(cls_HSEditorZoomController,sel_maxZoomFactor);
    if (((fVar8 == (float)dVar10) && (fVar8 < fVar9)) ||
       ((dVar10 = _objc_msgSend_fpret(cls_HSEditorZoomController,sel_minZoomFactor),
        fVar8 == (float)dVar10 && (fVar9 < fVar8)))) {
      pvVar2 = (id)0x3f800000;
    }
    else {
      _objc_msgSend_fpret(cls_HSEditorZoomController,sel_minZoomFactor);
      _fmaxf();
      _objc_msgSend_fpret(cls_HSEditorZoomController,sel_maxZoomFactor);
      lVar7 = (longdouble)_fminf();
      pvVar2 = (id)(float)lVar7;
    }
    pvVar3 = self->_layerContext;
    puVar6 = sel_zoomToFactor_aboutPoint_;
  }
  else {
    dVar10 = _objc_msgSend_fpret(self->_layerContext,sel_zoomFactor);
    dVar11 = _objc_msgSend_fpret(cls_HSEditorZoomController,sel_maxZoomFactor);
    pvVar3 = self->_layerContext;
    puVar6 = sel_zoomInAboutPoint_;
    if ((float)dVar11 <= (float)dVar10) goto LAB_000d9952;
  }
  puVar4[2] = pvVar2;
  puVar4[1] = puVar6;
  *puVar4 = pvVar3;
  puVar5 = puVar4;
LAB_000d9952:
  puVar5[-1] = 0xd9957;
  _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
  return;
}

*/
- (void)handleMouseUp:(id)aUp inTrackingLoop:(id)aLoop
{
    _selectionRect = NSZeroRect;
    if ([self activeLayerMode] == 2) {
        [super handleMouseUp:aUp inTrackingLoop:aLoop];
        return;
    }
    [self invalidateDisplay];
    id view = [self renderingView];
    NSPoint point = [view convertPoint:[aUp locationInWindow] fromView:nil];
    if (_layerContext == nil) {
        return;
    }
    if (!NSEqualPoints(point, _startPoint)) {
        if (_owner == nil) {
            return;
        }
        NSRect visibleRect = [view visibleRect];
        NSRect boundingRect = [view viewBoundingRectForUserRect:visibleRect];
        CGFloat dx = fabsf(_startPoint.x - point.x);
        CGFloat dy = fabsf(_startPoint.y - point.y);
        NSPoint center = NSMakePoint(dx * 0.5f + MIN(_startPoint.x, point.x), dy * 0.5f + MIN(_startPoint.y, point.y));
        CGFloat factor;
        if (dx < dy) {
            factor = boundingRect.size.height / dy;
        } else {
            factor = boundingRect.size.width / dx;
        }
        CGFloat zoom = [_layerContext zoomFactor];
        if ((zoom == [HSEditorZoomController maxZoomFactor] && factor > zoom)
            || (zoom == [HSEditorZoomController minZoomFactor] && zoom > factor)) {
            factor = 1.0f;
        } else {
            factor = fminf(fmaxf(factor, [HSEditorZoomController minZoomFactor]), [HSEditorZoomController maxZoomFactor]);
        }
        [_layerContext zoomToFactor:factor aboutPoint:center];
    } else if ([HSEditorZoomController maxZoomFactor] > [_layerContext zoomFactor]) {
        [_layerContext zoomInAboutPoint:point];
    } else {
        [_layerContext zoomToFactor:1.0f aboutPoint:point];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000d998e @ 000d998e, 288 bytes * /

void FUN_000d998e(HSMagnifyingCanvasLayer *self,SEL _cmd,id handleMouseDragged,id inTrackingLoop)

{
  float fVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  undefined4 extraout_EDX;
  float extraout_EDX_00;
  float fVar6;
  undefined4 uVar7;
  undefined4 uVar8;
  HSMagnifyingCanvasLayer *local_14;
  undefined *local_10;
  
  pvVar3 = _objc_msgSend(self,sel_activeLayerMode);
  if (pvVar3 == (id)0x2) {
    local_14 = self;
    local_10 = PTR_s_HSDragCardViewCanvasLayer_00350390;
    _objc_msgSendSuper(&local_14,sel_handleMouseDragged_inTrackingLoop_,handleMouseDragged,
                       inTrackingLoop);
  }
  else {
    _objc_msgSend(self,sel_invalidateDisplay);
    pvVar3 = _objc_msgSend(self,sel_renderingView);
    pvVar4 = _objc_msgSend(handleMouseDragged,sel_locationInWindow);
    uVar8 = 0;
    uVar7 = extraout_EDX;
    pvVar5 = _objc_msgSend(pvVar3,sel_convertPoint_fromView_,pvVar4,extraout_EDX,0);
    pvVar3 = (id)(self->super)._startPoint.x;
    fVar1 = (self->super)._startPoint.y;
    pvVar2 = pvVar3;
    if ((float)pvVar5 <= (float)pvVar3) {
      pvVar2 = pvVar5;
    }
    (self->_selectionRect).origin.x = (float)pvVar2;
    fVar6 = fVar1;
    if (extraout_EDX_00 <= fVar1) {
      fVar6 = extraout_EDX_00;
    }
    (self->_selectionRect).origin.y = fVar6;
    (self->_selectionRect).size.width = ABS((float)pvVar3 - (float)pvVar5);
    (self->_selectionRect).size.height = ABS(fVar1 - extraout_EDX_00);
    _objc_msgSend(self,sel_invalidateDisplay,pvVar4,uVar7,uVar8);
  }
  return;
}

*/
- (void)handleMouseDragged:(id)aDragged inTrackingLoop:(id)aLoop
{
    if ([self activeLayerMode] == 2) {
        [super handleMouseDragged:aDragged inTrackingLoop:aLoop];
        return;
    }
    [self invalidateDisplay];
    NSPoint point = [[self renderingView] convertPoint:[aDragged locationInWindow] fromView:nil];
    _selectionRect.origin.x = MIN(_startPoint.x, point.x);
    _selectionRect.origin.y = MIN(_startPoint.y, point.y);
    _selectionRect.size.width = fabsf(_startPoint.x - point.x);
    _selectionRect.size.height = fabsf(_startPoint.y - point.y);
    [self invalidateDisplay];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000d9aae @ 000d9aae, 220 bytes * /

void FUN_000d9aae(HSMagnifyingCanvasLayer *self,SEL _cmd,id handleMouseDown,id inTrackingLoop)

{
  id pvVar1;
  id pvVar2;
  undefined4 extraout_EDX;
  float extraout_EDX_00;
  HSMagnifyingCanvasLayer *local_1c;
  undefined *local_18;
  
  pvVar1 = _objc_msgSend(self,sel_activeLayerMode);
  if (pvVar1 == (id)0x2) {
    local_1c = self;
    local_18 = PTR_s_HSDragCardViewCanvasLayer_00350390;
    _objc_msgSendSuper(&local_1c,sel_handleMouseDown_inTrackingLoop_,handleMouseDown,inTrackingLoop)
    ;
  }
  else {
    _objc_msgSend(self,sel_resetCurrentCursor);
    pvVar1 = _objc_msgSend(self,sel_renderingView);
    pvVar2 = _objc_msgSend(handleMouseDown,sel_locationInWindow);
    pvVar1 = _objc_msgSend(pvVar1,sel_convertPoint_fromView_,pvVar2,extraout_EDX,0);
    (self->super)._startPoint.x = (float)pvVar1;
    (self->super)._startPoint.y = extraout_EDX_00;
    (self->_selectionRect).origin.x = (float)pvVar1;
    (self->_selectionRect).origin.y = extraout_EDX_00;
    (self->_selectionRect).size.width = 0.0;
    (self->_selectionRect).size.height = 0.0;
  }
  return;
}

*/
- (void)handleMouseDown:(id)aDown inTrackingLoop:(id)aLoop
{
    if ([self activeLayerMode] == 2) {
        [super handleMouseDown:aDown inTrackingLoop:aLoop];
        return;
    }
    [self resetCurrentCursor];
    NSPoint point = [[self renderingView] convertPoint:[aDown locationInWindow] fromView:nil];
    _startPoint = point;
    _selectionRect = NSMakeRect(point.x, point.y, 0.0f, 0.0f);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000d9b8a @ 000d9b8a, 248 bytes * /

BOOL FUN_000d9b8a(HSMagnifyingCanvasLayer *self,SEL _cmd,id handleRawKeyDownEvent)

{
  id pvVar1;
  HSMagnifyingCanvasLayer *local_2c;
  undefined *local_28;
  float local_24;
  float local_20;
  float local_1c;
  float local_18;
  
  pvVar1 = _objc_msgSend(handleRawKeyDownEvent,sel_keyCode);
  if (((short)pvVar1 == 0x35) &&
     (pvVar1 = _objc_msgSend(handleRawKeyDownEvent,sel_modifierFlags), pvVar1 < (id)0x10000)) {
    pvVar1 = _objc_msgSend(self,sel_renderingView);
    _objc_msgSend_stret(&local_24,pvVar1,sel_frame);
    _objc_msgSend(self->_layerContext,sel_zoomToFactor_aboutPoint_,0x3f800000,
                  local_1c * 0.5 + local_24,local_18 * 0.5 + local_20);
    return '\x01';
  }
  local_2c = self;
  local_28 = PTR_s_HSDragCardViewCanvasLayer_00350390;
  pvVar1 = _objc_msgSendSuper(&local_2c,sel_handleRawKeyDownEvent_,handleRawKeyDownEvent);
  return (BOOL)pvVar1;
}

*/
- (BOOL)handleRawKeyDownEvent:(id)aEvent
{
    if ([aEvent keyCode] == 0x35 && ([aEvent modifierFlags] & 0xffffffff) <= 0xffff) {
        NSRect frame = [[self renderingView] frame];
        [_layerContext zoomToFactor:1.0f aboutPoint:NSMakePoint(frame.size.width * 0.5f + frame.origin.x, 0.5f * frame.size.height + frame.origin.y)];
        return YES;
    }
    return [super handleRawKeyDownEvent:aEvent];
}

- (BOOL)handleFlagsChanged:(id)aChanged atPoint:(NSPoint)aPoint
{
    [self resetCurrentCursor];
    [[self renderingView] updateCursor];
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000d9c82 @ 000d9c82, 740 bytes * /

BOOL FUN_000d9c82(HSMagnifyingCanvasLayer *self,SEL _cmd,NSPoint handleMouseDownAtPoint,id event,
                 id hitTestInfo)

{
  undefined *self_00;
  id pvVar1;
  double dVar2;
  double dVar3;
  SEL op;
  float fVar4;
  HSMagnifyingCanvasLayer *local_24;
  undefined *local_20;
  HSMagnifyingCanvasLayer *local_1c;
  undefined *local_18;
  
  pvVar1 = _objc_msgSend(event,sel_modifierFlags);
  if (((uint)pvVar1 & 0x180000) == 0x180000) {
    pvVar1 = self->_layerContext;
    fVar4 = 1.0;
    op = sel_zoomToFactor_;
  }
  else {
    if (((uint)pvVar1 & 0x180000) != 0x100000) {
      if ((*(uint *)PTR_DAT_003364b4 & (uint)pvVar1) == 0) {
        local_1c = self;
        local_18 = PTR_s_HSDragCardViewCanvasLayer_00350390;
        pvVar1 = _objc_msgSendSuper(&local_1c,sel_handleMouseDownAtPoint_event_hitTestInfo_,
                                    handleMouseDownAtPoint.x,handleMouseDownAtPoint.y,event,
                                    hitTestInfo);
        if ((char)pvVar1 != '\0') {
          return (char)pvVar1;
        }
      }
      self_00 = cls_HSTrackingLoop;
      if (self->_owner == hitTestInfo) {
        pvVar1 = _objc_msgSend(self,sel_renderingView);
        pvVar1 = _objc_msgSend(self_00,sel_trackingLoopWithView_client_,pvVar1,self);
        _objc_msgSend(pvVar1,sel_runWithMouseDownEvent_,event);
        return '\0';
      }
      local_24 = self;
      local_20 = PTR_s_HSDragCardViewCanvasLayer_00350390;
      pvVar1 = _objc_msgSendSuper(&local_24,sel_handleMouseDownAtPoint_event_hitTestInfo_,
                                  handleMouseDownAtPoint.x,handleMouseDownAtPoint.y,event,
                                  hitTestInfo);
      return (BOOL)pvVar1;
    }
    dVar2 = _objc_msgSend_fpret(self->_layerContext,sel_zoomFactor);
    dVar3 = _objc_msgSend_fpret(cls_HSEditorZoomController,sel_minZoomFactor);
    if ((float)dVar2 <= (float)dVar3) {
      fVar4 = 1.0;
      _objc_msgSend(self->_layerContext,sel_zoomToFactor_aboutPoint_,0x3f800000,
                    handleMouseDownAtPoint.x,handleMouseDownAtPoint.y);
      handleMouseDownAtPoint.y = handleMouseDownAtPoint.x;
    }
    else {
      _objc_msgSend(self->_layerContext,sel_zoomOutAboutPoint_,handleMouseDownAtPoint.x,
                    handleMouseDownAtPoint.y);
      dVar2 = _objc_msgSend_fpret(self->_layerContext,sel_zoomFactor);
      dVar3 = _objc_msgSend_fpret(cls_HSEditorZoomController,sel_minZoomFactor);
      fVar4 = handleMouseDownAtPoint.x;
      if (((float)dVar3 != (float)dVar2) &&
         (dVar3 = _objc_msgSend_fpret(cls_HSEditorZoomController,sel_maxZoomFactor),
         fVar4 = handleMouseDownAtPoint.x, (float)dVar3 != (float)dVar2)) {
        return '\x01';
      }
    }
    _objc_msgSend(self,sel_resetCurrentCursor,fVar4,handleMouseDownAtPoint.y);
    pvVar1 = _objc_msgSend(self,sel_renderingView);
    op = sel_updateCursor;
  }
  _objc_msgSend(pvVar1,op,fVar4);
  return '\x01';
}

*/
- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo
{
    NSUInteger flags = [aEvent modifierFlags];
    if ((flags & 0x180000) == 0x180000) {
        [_layerContext zoomToFactor:1.0f];
        return YES;
    }
    if ((flags & 0x180000) == 0x100000) {
        CGFloat zoom = [_layerContext zoomFactor];
        if (zoom <= [HSEditorZoomController minZoomFactor]) {
            [_layerContext zoomToFactor:1.0f aboutPoint:aPoint];
        } else {
            [_layerContext zoomOutAboutPoint:aPoint];
            zoom = [_layerContext zoomFactor];
            if ([HSEditorZoomController minZoomFactor] != zoom && [HSEditorZoomController maxZoomFactor] != zoom) {
                return YES;
            }
        }
        [self resetCurrentCursor];
        [[self renderingView] updateCursor];
        return YES;
    }
    if ((flags & 0x9e0000) == 0) {
        BOOL handled = [super handleMouseDownAtPoint:aPoint event:aEvent hitTestInfo:aInfo];
        if (handled) {
            return handled;
        }
    }
    if (_owner == aInfo) {
        [[HSTrackingLoop trackingLoopWithView:[self renderingView] client:self] runWithMouseDownEvent:aEvent];
        return NO;
    }
    return [super handleMouseDownAtPoint:aPoint event:aEvent hitTestInfo:aInfo];
}

- (void)willStopRunningInWindow
{
    BOOL pvVar1;

    pvVar1 = [self isLayerStarted];
    [super willStopRunningInWindow];
    if (pvVar1) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:HSViewDidChangeUserSpaceToViewSpaceTransformNotification object:[self renderingView]];
    }
}

- (void)willStopRunning
{
    BOOL pvVar1;

    pvVar1 = [self isLayerStarted];
    [super willStopRunning];
    if (pvVar1) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:HSViewDidChangeUserSpaceToViewSpaceTransformNotification object:[self renderingView]];
    }
}

- (void)HSMagnifyingCanvasLayerAuxiliary_magnifyingCanvasLayeViewDidChangeUserSpaceToViewSpaceTransform:(id)aTransform
{
    [self resetCurrentCursor];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000da0b0 @ 000da0b0, 272 bytes * /

id FUN_000da0b0(HSMagnifyingCanvasLayer *self,SEL _cmd,
               int HSMagnifyingCanvasLayerAuxiliary_cursorForLayerMode,uint modifierFlags,
               float zoomFactor)

{
  id pvVar1;
  uint uVar2;
  undefined4 *puVar3;
  double dVar4;
  HSMagnifyingCanvasLayer *local_14;
  undefined *local_10;
  
  if (HSMagnifyingCanvasLayerAuxiliary_cursorForLayerMode != 0) {
    local_14 = self;
    local_10 = PTR_s_HSDragCardViewCanvasLayer_00350390;
    pvVar1 = _objc_msgSendSuper(&local_14,sel_cursorForLayerMode_modifierFlags_,
                                HSMagnifyingCanvasLayerAuxiliary_cursorForLayerMode,modifierFlags);
    if (pvVar1 != (id)0x0) {
      return pvVar1;
    }
  }
  uVar2 = modifierFlags & 0x180000;
  puVar3 = (undefined4 *)PTR_PTR_003364b8;
  if (uVar2 != 0x180000) {
    dVar4 = _objc_msgSend_fpret(cls_HSEditorZoomController,sel_minZoomFactor);
    if (((float)dVar4 != zoomFactor) || (NAN((float)dVar4) || NAN(zoomFactor))) {
      dVar4 = _objc_msgSend_fpret(cls_HSEditorZoomController,sel_maxZoomFactor);
      puVar3 = (undefined4 *)PTR_PTR_003364bc;
      if (((float)dVar4 == zoomFactor) && (!NAN((float)dVar4) && !NAN(zoomFactor))) {
        puVar3 = (undefined4 *)PTR_PTR_003364b8;
      }
      if (uVar2 == 0x100000) {
        puVar3 = (undefined4 *)PTR_PTR_003364c0;
      }
    }
    else {
      puVar3 = (undefined4 *)PTR_PTR_003364bc;
      if (uVar2 == 0x100000) {
        puVar3 = (undefined4 *)PTR_PTR_003364b8;
      }
    }
  }
  pvVar1 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*puVar3);
  return pvVar1;
}

*/
- (id)HSMagnifyingCanvasLayerAuxiliary_cursorForLayerMode:(NSInteger)aMode modifierFlags:(NSUInteger)aFlags zoomFactor:(CGFloat)aFactor
{
    if (aMode != 0) {
        id cursor = [super cursorForLayerMode:aMode modifierFlags:aFlags];
        if (cursor != nil) {
            return cursor;
        }
    }
    NSUInteger mask = aFlags & 0x180000;
    NSString *name = HSZoomActualCursor;
    if (mask != 0x180000) {
        if ([HSEditorZoomController minZoomFactor] != aFactor) {
            name = ([HSEditorZoomController maxZoomFactor] == aFactor) ? HSZoomActualCursor : HSZoomInCursor;
            if (mask == 0x100000) {
                name = HSZoomOutCursor;
            }
        } else {
            name = HSZoomInCursor;
            if (mask == 0x100000) {
                name = HSZoomActualCursor;
            }
        }
    }
    return [HSCursor cursorNamed:name];
}

- (id)cursorForLayerMode:(NSInteger)aMode modifierFlags:(NSUInteger)aFlags
{
    return [self HSMagnifyingCanvasLayerAuxiliary_cursorForLayerMode:aMode modifierFlags:aFlags zoomFactor:(float)[_layerContext zoomFactor]];
}

- (void)initialzeCanvasLayer
{
    id pvVar1;

    pvVar1 = [[[self context] queryHyperInterface:@protocol(HSEditorCanvasLayerContext)] retain];
    _layerContext = pvVar1;
    if (pvVar1 != nil) {
        [super initialzeCanvasLayer];
        pvVar1 = [NSNotificationCenter defaultCenter];
        [pvVar1 addObserver:self selector:@selector(HSMagnifyingCanvasLayerAuxiliary_magnifyingCanvasLayeViewDidChangeUserSpaceToViewSpaceTransform:) name:HSViewDidChangeUserSpaceToViewSpaceTransformNotification object:[self renderingView]];
    }
}

- (id)owner
{
    return _owner;
}

- (void)setOwner:(id)aOwner
{
    _owner = aOwner;
}

- (void)dealloc
{
    [_layerContext release];
    [super dealloc];
}

@end

