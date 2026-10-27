#import "HSLegacyPolyCurveTool.h"

@implementation HSLegacyPolyCurveTool

/* i386 ivar offsets: _savedWindowAcceptsMouseMovedEventsFlag=0x20, _isStraightLineMode=0x21, _isAppendPending=0x22, _isAppendPendingWithCurrentPoint=0x23, _pendingPoint=0x24, _autoscrollEvent=0x2c */

+ (Class)userObjectClass
{
    return [HSVectorGraphicsObject class];
}

- (void)prototypeObjectDidChange
{
    [self updatePrototypeWithObjectKindName];
    [super prototypeObjectDidChange];
}

- (void)updatePrototypeWithObjectKindName
{
    id pvVar1;

    pvVar1 = [self nonLocalizedObjectKindName];
    [[self prototypeObject] setObjectKindName:pvVar1];
}

- (id)localizedObjectKindName
{
    id pvVar1;

    pvVar1 = [self nonLocalizedObjectKindName];
    return [[HSUserObjectDefaultAttributesProvider sharedInstance] localizedKindNameForUserObjectClass:[[self class] userObjectClass] key:pvVar1];
}

- (id)nonLocalizedObjectKindName
{
    return [[HSUserObjectDefaultAttributesProvider sharedInstance] nonLocalizedKindNameForVectorGraphicsObjectIfClosed:NO straightLineMode:_isStraightLineMode];
}

- (BOOL)prototypeHasClosedPath
{
    return NO;
}

- (void)performIdleMouseAutoscroll
{
    [self handleIdleMouseAutoscroll:_autoscrollEvent];
    [self launchIdleMouseAutoscroll];
}

- (void)resetIdleMouseAutoscrollingWithMouseMovedEvent:(id)aEvent
{
    [self stopIdleMouseAutoscrolling];
    [self startIdleMouseAutoscrollingWithMouseMovedEvent:aEvent];
}

- (void)stopIdleMouseAutoscrolling
{
    if (_autoscrollEvent != nil) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(performIdleMouseAutoscroll) object:nil];
        [_autoscrollEvent release];
        _autoscrollEvent = nil;
    }
}

- (void)startIdleMouseAutoscrollingWithMouseMovedEvent:(id)aEvent
{
    _autoscrollEvent = [aEvent retain];
    [self launchIdleMouseAutoscroll];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a758f @ 000a758f, 72 bytes * /

void FUN_000a758f(HSLegacyPolyCurveTool *self,SEL _cmd)

{
  _objc_msgSend(self,sel_performSelector_withObject_afterDelay_,sel_performIdleMouseAutoscroll,0,
                0xa0000000,0x3fb99999);
  return;
}

*/
- (void)launchIdleMouseAutoscroll
{
    [self performSelector:@selector(performIdleMouseAutoscroll) withObject:nil afterDelay:0.1];
}

- (void)handleIdleMouseAutoscroll:(id)aAutoscroll
{
    [self autoscrollWithMouseEvent:aAutoscroll];
    [self mouseEvent:aAutoscroll];
}

- (void)autoscrollWithMouseEvent:(id)aEvent
{
    [[self view] autoscroll:aEvent];
    [self handleAutoscrollingWithMouseEvent:aEvent];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a7926 @ 000a7926, 781 bytes * /

BOOL FUN_000a7926(HSLegacyPolyCurveTool *self,SEL _cmd,id needsAutoscrollForMouseEvent)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  undefined4 extraout_EDX_01;
  float fVar5;
  float fVar6;
  float fVar7;
  float fVar8;
  float local_5c;
  float local_58;
  float local_54;
  float local_50;
  undefined8 local_4c;
  undefined8 local_44;
  undefined1 local_3c [16];
  float local_2c;
  float local_28;
  float local_24;
  float local_20;
  undefined1 local_1c [16];
  
  pvVar2 = _objc_msgSend(self,sel_trackingObject);
  if (pvVar2 != (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_view);
    pvVar3 = _objc_msgSend(pvVar2,sel_enclosingScrollView);
    pvVar3 = _objc_msgSend(pvVar3,sel_contentView);
    pvVar4 = _objc_msgSend(needsAutoscrollForMouseEvent,sel_locationInWindow);
    pvVar4 = _objc_msgSend(pvVar2,sel_convertPoint_fromView_,pvVar4,extraout_EDX,0);
    if (pvVar3 != (id)0x0) {
      _objc_msgSend_stret(&local_5c,pvVar2,sel_bounds);
      _objc_msgSend_stret(&local_4c,pvVar2,sel_bounds);
      _objc_msgSend_stret(local_3c,pvVar3,sel_documentVisibleRect);
      _NSIntersectionRect(&local_2c,(int)local_3c._0_8_,SUB84(local_3c._0_8_,4),(int)local_3c._8_8_,
                          SUB84(local_3c._8_8_,4),local_4c,local_44);
      fVar6 = ABS(local_58) + local_50;
      fVar8 = ABS(local_28) + local_20;
      if ((fVar8 != 0.0) || (NAN(fVar8))) {
        fVar8 = ABS(fVar8);
      }
      else {
        fVar8 = 1.0;
      }
      if ((fVar6 != 0.0) || (NAN(fVar6))) {
        fVar6 = ABS(fVar6);
      }
      else {
        fVar6 = 1.0;
      }
      fVar7 = ABS(local_5c) + local_54;
      fVar5 = ABS(local_2c) + local_24;
      if (fVar6 <= fVar8) {
        fVar6 = fVar8;
      }
      if ((fVar5 != 0.0) || (NAN(fVar5))) {
        fVar5 = ABS(fVar5);
      }
      else {
        fVar5 = 1.0;
      }
      if ((fVar7 != 0.0) || (NAN(fVar7))) {
        fVar7 = ABS(fVar7);
      }
      else {
        fVar7 = 1.0;
      }
      if (fVar7 <= fVar5) {
        fVar7 = fVar5;
      }
      if ((((fVar7 * 0.0005 < ABS(local_2c - local_5c)) ||
           (fVar6 * 0.0005 < ABS(local_28 - local_58))) ||
          (fVar7 * 0.0005 < ABS(local_24 - local_54))) ||
         (fVar6 * 0.0005 < ABS(local_20 - local_50))) {
        _objc_msgSend_stret(local_1c,pvVar3,sel_bounds);
        pvVar2 = _objc_msgSend(pvVar3,sel_convertPoint_fromView_,pvVar4,extraout_EDX_00,0);
        cVar1 = _NSPointInRect(pvVar2,extraout_EDX_01,(int)local_1c._0_8_,SUB84(local_1c._0_8_,4),
                               (int)local_1c._8_8_,SUB84(local_1c._8_8_,4));
        return cVar1 == '\0';
      }
    }
  }
  return '\0';
}

*/
- (BOOL)needsAutoscrollForMouseEvent:(id)aEvent
{
    if ([self trackingObject] == nil) {
        return NO;
    }
    NSView *view = [self view];
    NSClipView *clipView = [[view enclosingScrollView] contentView];
    NSPoint point = [view convertPoint:[aEvent locationInWindow] fromView:nil];
    if (clipView == nil) {
        return NO;
    }
    NSRect bounds = [view bounds];
    NSRect visible = NSIntersectionRect([clipView documentVisibleRect], [view bounds]);
    float boundsX = fabsf(bounds.origin.x) + bounds.size.width;
    float boundsY = fabsf(bounds.origin.y) + bounds.size.height;
    float visibleX = fabsf(visible.origin.x) + visible.size.width;
    float visibleY = fabsf(visible.origin.y) + visible.size.height;
    float scaleY = MAX((boundsY != 0.0f) ? fabsf(boundsY) : 1.0f, (visibleY != 0.0f) ? fabsf(visibleY) : 1.0f);
    float scaleX = MAX((boundsX != 0.0f) ? fabsf(boundsX) : 1.0f, (visibleX != 0.0f) ? fabsf(visibleX) : 1.0f);
    if (scaleX * 0.0005f < fabsf(visible.origin.x - bounds.origin.x) ||
        scaleY * 0.0005f < fabsf(visible.origin.y - bounds.origin.y) ||
        scaleX * 0.0005f < fabsf(visible.size.width - bounds.size.width) ||
        scaleY * 0.0005f < fabsf(visible.size.height - bounds.size.height)) {
        NSRect clipBounds = [clipView bounds];
        NSPoint clipPoint = [clipView convertPoint:point fromView:nil];
        return !NSPointInRect(clipPoint, clipBounds);
    }
    return NO;
    return 0;
}

- (void)saveChangesAndNotify:(BOOL)aNotify
{
    [self leaveTrackingObjectAndNotify:aNotify registerInCard:YES forceSwitchTool:aNotify];
}

- (void)cancelOperation:(id)aOperation
{
    if ([self trackingObject] != nil) {
        [self leaveTrackingObjectAndNotify:YES registerInCard:NO forceSwitchTool:YES];
    }
}

- (void)handleMouseUp:(id)aUp
{

}

- (void)handleAutoscrollingWithMouseEvent:(id)aEvent
{
    [super handleAutoscrollingWithMouseEvent:aEvent];
    [self mouseEvent:aEvent];
}

- (void)handleMouseDragged:(id)aDragged
{
    [self mouseEvent:aDragged];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a7c8b @ 000a7c8b, 346 bytes * /

void FUN_000a7c8b(HSLegacyPolyCurveTool *self,SEL _cmd,id mouseMoved)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  SEL pcVar4;
  HSLegacyPolyCurveTool *local_1c;
  undefined *local_18;
  
  pvVar3 = mouseMoved;
  pvVar1 = _objc_msgSend(self,sel_shouldHandleMouseMovedEvent_,mouseMoved);
  if (((char)pvVar1 == '\0') && (self->_isAppendPending == '\0')) {
    pcVar4 = sel_stopIdleMouseAutoscrolling;
    if ((self->_isAppendPendingWithCurrentPoint == '\0') &&
       (pvVar1 = _objc_msgSend(self,sel_currentPointIndex,pvVar3),
       pcVar4 = sel_stopIdleMouseAutoscrolling, pvVar1 != (id)0x0)) {
      pvVar1 = _objc_msgSend(self,sel_vectorAttributes,pvVar3);
      pvVar2 = _objc_msgSend(self,sel_editingMode);
      pvVar3 = _objc_msgSend(self,sel_currentPointIndex);
      _objc_msgSend(pvVar1,sel_deleteHyperElementAtIndex_glueWithEditingMode_,pvVar3,pvVar2);
      self->_isAppendPendingWithCurrentPoint = '\x01';
      pcVar4 = sel_stopIdleMouseAutoscrolling;
    }
  }
  else {
    pvVar3 = mouseMoved;
    pvVar1 = _objc_msgSend(self,sel_needsAutoscrollForMouseEvent_,mouseMoved);
    pcVar4 = sel_stopIdleMouseAutoscrolling;
    if ((char)pvVar1 != '\0') {
      _objc_msgSend(self,sel_autoscrollWithMouseEvent_,mouseMoved);
      pcVar4 = sel_resetIdleMouseAutoscrollingWithMouseMovedEvent_;
      pvVar3 = mouseMoved;
    }
    _objc_msgSend(self,pcVar4,pvVar3);
    pcVar4 = sel_mouseEvent_;
    pvVar3 = mouseMoved;
  }
  _objc_msgSend(self,pcVar4,pvVar3);
  local_1c = self;
  local_18 = PTR_s_HSLegacyLineTool_0034f280;
  _objc_msgSendSuper(&local_1c,sel_mouseMoved_,mouseMoved);
  return;
}

*/
- (void)mouseMoved:(id)aMoved
{
    SEL selector;
    id argument = aMoved;
    if (![self shouldHandleMouseMovedEvent:aMoved] && !_isAppendPending) {
        selector = @selector(stopIdleMouseAutoscrolling);
        if (!_isAppendPendingWithCurrentPoint && [self currentPointIndex] != 0) {
            [[self vectorAttributes] deleteHyperElementAtIndex:[self currentPointIndex] glueWithEditingMode:[self editingMode]];
            _isAppendPendingWithCurrentPoint = YES;
        }
    } else {
        selector = @selector(stopIdleMouseAutoscrolling);
        if ([self needsAutoscrollForMouseEvent:aMoved]) {
            [self autoscrollWithMouseEvent:aMoved];
            selector = @selector(resetIdleMouseAutoscrollingWithMouseMovedEvent:);
        }
        [self performSelector:selector withObject:aMoved];
        selector = @selector(mouseEvent:);
    }
    [self performSelector:selector withObject:argument];
    [super mouseMoved:aMoved];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a7de5 @ 000a7de5, 652 bytes * /

BOOL FUN_000a7de5(HSLegacyPolyCurveTool *self,SEL _cmd,id shouldHandleMouseMovedEvent)

{
  undefined4 uVar1;
  undefined4 uVar2;
  undefined *puVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id self_00;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined4 local_54;
  undefined4 local_50;
  undefined4 local_4c;
  undefined4 local_48;
  undefined4 local_44;
  undefined4 uStack_40;
  undefined4 local_3c;
  undefined4 uStack_38;
  undefined1 local_34 [16];
  undefined1 local_24 [20];
  
  pvVar4 = _objc_msgSend(self,sel_view);
  pvVar5 = _objc_msgSend(pvVar4,sel_window);
  pvVar5 = _objc_msgSend(pvVar5,sel_contentView);
  pvVar6 = _objc_msgSend(shouldHandleMouseMovedEvent,sel_locationInWindow);
  puVar3 = PTR_00336078;
  uVar1 = *(undefined4 *)PTR_00336078;
  uVar2 = *(undefined4 *)(PTR_00336078 + 4);
  pvVar6 = _objc_msgSend(pvVar5,sel_convertPoint_fromView_,pvVar6,extraout_EDX,0);
  local_3c = *(undefined4 *)(puVar3 + 8);
  uStack_38 = *(undefined4 *)(puVar3 + 0xc);
  local_44 = uVar1;
  uStack_40 = uVar2;
  self_00 = _objc_msgSend(pvVar4,sel_enclosingScrollView);
  if (self_00 == (id)0x0) {
    _objc_msgSend_stret(local_24,pvVar4,sel_visibleRect);
    _objc_msgSend_stret(&local_54,pvVar5,sel_convertRect_fromView_,(int)local_24._0_8_,
                        SUB84(local_24._0_8_,4),(int)local_24._8_8_,SUB84(local_24._8_8_,4),pvVar4);
    local_44 = local_54;
    uStack_40 = local_50;
    local_3c = local_4c;
    uStack_38 = local_48;
  }
  else {
    _objc_msgSend_stret(local_34,self_00,sel_bounds);
    _objc_msgSend_stret(&local_44,pvVar5,sel_convertRect_fromView_,(int)local_34._0_8_,
                        SUB84(local_34._0_8_,4),(int)local_34._8_8_,SUB84(local_34._8_8_,4),self_00)
    ;
  }
  _NSInsetRect(&local_64,CONCAT44(uStack_40,local_44),local_3c,uStack_38,0xc1200000,0xc1200000);
  local_44 = local_64;
  uStack_40 = local_60;
  local_3c = local_5c;
  uStack_38 = local_58;
  pvVar4 = _objc_msgSend(pvVar5,sel_mouse_inRect_,pvVar6,extraout_EDX_00,local_64,local_60,local_5c,
                         local_58);
  return (char)pvVar4 != '\0';
}

*/
- (BOOL)shouldHandleMouseMovedEvent:(id)aEvent
{
    NSView *view = [self view];
    NSView *contentView = [[view window] contentView];
    NSPoint point = [contentView convertPoint:[aEvent locationInWindow] fromView:nil];
    NSRect rect = NSZeroRect;
    NSScrollView *scrollView = [view enclosingScrollView];
    if (scrollView == nil) {
        rect = [contentView convertRect:[view visibleRect] fromView:view];
    } else {
        rect = [contentView convertRect:[scrollView bounds] fromView:scrollView];
    }
    rect = NSInsetRect(rect, -10.0f, -10.0f);
    return [contentView mouse:point inRect:rect];
    return 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a8071 @ 000a8071, 1075 bytes * /

void FUN_000a8071(HSLegacyPolyCurveTool *self,SEL _cmd,id mouseEvent)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  HSLegacyPolyCurveTool *self_00;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  float extraout_EDX_01;
  SEL op;
  undefined4 uVar6;
  undefined4 *puVar7;
  float local_34;
  id local_30;
  undefined4 local_2c;
  undefined4 *local_28;
  undefined4 local_24;
  undefined4 *local_20;
  undefined4 local_1c;
  undefined4 *local_18;
  
  pvVar2 = _objc_msgSend(self,sel_view);
  if (self->_isAppendPending == '\0') {
    pvVar3 = _objc_msgSend(mouseEvent,sel_locationInWindow);
    pvVar3 = _objc_msgSend(pvVar2,sel_convertPoint_fromView_,pvVar3,extraout_EDX,0);
    local_30 = _objc_msgSend(pvVar2,sel_convertPointFromViewSpaceToUserSpace_,pvVar3,extraout_EDX_00
                            );
    local_34 = extraout_EDX_01;
  }
  else {
    local_30 = (id)(self->_pendingPoint).x;
    local_34 = (self->_pendingPoint).y;
  }
  pvVar2 = _objc_msgSend(self,sel_trackingObject);
  if ((pvVar2 == (id)0x0) && (self->_isAppendPending != '\0')) {
    _objc_msgSend(self,sel_createTrackingObjectAtPoint_,local_30,local_34);
  }
  pvVar2 = _objc_msgSend(self,sel_trackingObject);
  if (pvVar2 != (id)0x0) {
    if ((self->_isAppendPending == '\0') && (self->_isAppendPendingWithCurrentPoint == '\0')) {
      self_00 = _objc_msgSend(self,sel_vectorAttributes);
      pvVar2 = _objc_msgSend(self,sel_editingMode);
      pvVar3 = _objc_msgSend(self,sel_currentPointIndex);
      op = sel_setHyperPoint_atIndex_editingMode_;
    }
    else {
      local_2c = *(undefined4 *)PTR_00336074;
      local_28 = *(undefined4 **)(PTR_00336074 + 4);
      local_24 = local_2c;
      local_20 = local_28;
      local_1c = local_2c;
      local_18 = local_28;
      pvVar2 = _objc_msgSend(self,sel_vectorAttributes);
      puVar7 = &local_2c;
      uVar6 = 0;
      _objc_msgSend(pvVar2,sel_hyperElementAtIndex_associatedPoints_,0,puVar7);
      pvVar2 = _objc_msgSend(self,sel_currentPointIndex);
      if ((pvVar2 < (id)0x2) ||
         (uVar6 = local_2c, puVar7 = local_28,
         cVar1 = _HSHitTestPoint(local_30,local_34,local_2c,local_28,0x40400000,0x40400000),
         cVar1 == '\0')) {
        self_00 = _objc_msgSend(self,sel_vectorAttributes,uVar6,puVar7);
        pvVar2 = _objc_msgSend(self,sel_editingMode);
        pvVar3 = _objc_msgSend(self,sel_currentPointIndex);
        pvVar3 = (id)((int)pvVar3 + 1);
        op = sel_insertHyperPoint_atIndex_editingMode_;
      }
      else {
        pvVar3 = _objc_msgSend(self,sel_vectorAttributes);
        pvVar2 = _objc_msgSend(self,sel_editingMode);
        pvVar4 = _objc_msgSend(self,sel_currentPointIndex);
        _objc_msgSend(pvVar3,sel_insertHyperPoint_atIndex_editingMode_,local_2c,local_28,
                      (int)pvVar4 + 1,pvVar2);
        pvVar3 = _objc_msgSend(self,sel_vectorAttributes);
        pvVar3 = _objc_msgSend(pvVar3,sel_hyperBezierPath);
        _objc_msgSend(pvVar3,sel_closePath);
        pvVar3 = _objc_msgSend(self,sel_trackingObject);
        pvVar3 = _objc_msgSend(pvVar3,sel_vg);
        pvVar4 = _objc_msgSend(self,sel_currentPointIndex);
        pvVar5 = _objc_msgSend(self,sel_editingMode);
        _objc_msgSend(pvVar3,sel_applyEditingMode_toElementsInRange_,pvVar5,(int)pvVar4 + -5,4);
        pvVar3 = (id)0x1;
        local_34 = 1.4013e-45;
        local_30 = (id)0x1;
        self_00 = self;
        op = sel_leaveTrackingObjectAndNotify_registerInCard_forceSwitchTool_;
      }
    }
    _objc_msgSend(self_00,op,local_30,local_34,pvVar3,pvVar2);
  }
  self->_isAppendPending = '\0';
  self->_isAppendPendingWithCurrentPoint = '\0';
  return;
}

*/
- (void)mouseEvent:(id)aEvent
{
    NSView *view = [self view];
    NSPoint point;
    if (!_isAppendPending) {
        NSPoint viewPoint = [view convertPoint:[aEvent locationInWindow] fromView:nil];
        point = [view convertPointFromViewSpaceToUserSpace:viewPoint];
    } else {
        point = _pendingPoint;
    }
    if ([self trackingObject] == nil && _isAppendPending) {
        [self createTrackingObjectAtPoint:point];
    }
    if ([self trackingObject] != nil) {
        if (!_isAppendPending && !_isAppendPendingWithCurrentPoint) {
            [[self vectorAttributes] setHyperPoint:point atIndex:[self currentPointIndex] editingMode:[self editingMode]];
        } else {
            NSPoint points[3] = { NSZeroPoint, NSZeroPoint, NSZeroPoint };
            [[self vectorAttributes] hyperElementAtIndex:0 associatedPoints:points];
            if ([self currentPointIndex] < 2 || !HSHitTestPoint(point, points[0], NSMakeSize(3.0f, 3.0f))) {
                [[self vectorAttributes] insertHyperPoint:point atIndex:[self currentPointIndex] + 1 editingMode:[self editingMode]];
            } else {
                [[self vectorAttributes] insertHyperPoint:points[0] atIndex:[self currentPointIndex] + 1 editingMode:[self editingMode]];
                [[[self vectorAttributes] hyperBezierPath] closePath];
                [[[self trackingObject] vg] applyEditingMode:[self editingMode] toElementsInRange:NSMakeRange([self currentPointIndex] - 5, 4)];
                [self leaveTrackingObjectAndNotify:YES registerInCard:YES forceSwitchTool:YES];
            }
        }
    }
    _isAppendPending = NO;
    _isAppendPendingWithCurrentPoint = NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a84a4 @ 000a84a4, 185 bytes * /

BOOL FUN_000a84a4(HSLegacyPolyCurveTool *self,SEL _cmd,NSPoint isPointCloseToClosePath)

{
  BOOL BVar1;
  id self_00;
  undefined4 local_24;
  undefined4 local_20;
  undefined4 local_1c;
  undefined4 local_18;
  undefined4 local_14;
  undefined4 local_10;
  
  local_24 = *(undefined4 *)PTR_00336074;
  local_20 = *(undefined4 *)(PTR_00336074 + 4);
  local_1c = local_24;
  local_18 = local_20;
  local_14 = local_24;
  local_10 = local_20;
  self_00 = _objc_msgSend(self,sel_vectorAttributes);
  _objc_msgSend(self_00,sel_hyperElementAtIndex_associatedPoints_,0,&local_24);
  BVar1 = _HSHitTestPoint(isPointCloseToClosePath.x,isPointCloseToClosePath.y,local_24,local_20,
                          0x40400000,0x40400000);
  return BVar1;
}

*/
- (BOOL)isPointCloseToClosePath:(NSPoint)aPath
{
    NSPoint points[3] = { NSZeroPoint, NSZeroPoint, NSZeroPoint };
    [[self vectorAttributes] hyperElementAtIndex:0 associatedPoints:points];
    return HSHitTestPoint(aPath, points[0], NSMakeSize(3.0f, 3.0f));
    return 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a732b @ 000a732b, 257 bytes * /

void FUN_000a732b(HSLegacyPolyCurveTool *self,SEL _cmd,id handleMouseDown)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  float extraout_EDX_01;
  
  _objc_msgSend(self,sel_stopIdleMouseAutoscrolling);
  pvVar1 = _objc_msgSend(handleMouseDown,sel_clickCount);
  if ((int)pvVar1 < 2) {
    self->_isAppendPending = '\x01';
    pvVar1 = _objc_msgSend(self,sel_view);
    pvVar2 = _objc_msgSend(self,sel_view);
    pvVar3 = _objc_msgSend(handleMouseDown,sel_locationInWindow);
    pvVar2 = _objc_msgSend(pvVar2,sel_convertPoint_fromView_,pvVar3,extraout_EDX,0);
    pvVar1 = _objc_msgSend(pvVar1,sel_convertPointFromViewSpaceToUserSpace_,pvVar2,extraout_EDX_00);
    (self->_pendingPoint).x = (float)pvVar1;
    (self->_pendingPoint).y = extraout_EDX_01;
  }
  else {
    self->_isAppendPending = '\0';
    _objc_msgSend(self,sel_leaveTrackingObjectAndNotify_,1);
  }
  self->_isAppendPendingWithCurrentPoint = '\0';
  return;
}

*/
- (void)handleMouseDown:(id)aDown
{
    [self stopIdleMouseAutoscrolling];
    if ([aDown clickCount] < 2) {
        _isAppendPending = YES;
        NSPoint viewPoint = [[self view] convertPoint:[aDown locationInWindow] fromView:nil];
        _pendingPoint = [[self view] convertPointFromViewSpaceToUserSpace:viewPoint];
    } else {
        _isAppendPending = NO;
        [self leaveTrackingObjectAndNotify:YES];
    }
    _isAppendPendingWithCurrentPoint = NO;
}

- (NSUInteger)currentPointIndex
{
    return (int)[[self vectorAttributes] hyperElementCount] - 1;
}

- (NSInteger)editingMode
{
    return (unsigned int)(![self isStraightLineMode]);
}

- (void)setStraightLineMode:(BOOL)aMode
{
    _isStraightLineMode = aMode;
    if ([self hasCreatedPrototypeObject]) {
        [self updatePrototypeWithObjectKindName];
    }
}

- (BOOL)isStraightLineMode
{
    return _isStraightLineMode;
}

- (BOOL)isObjectResizedScaledProportionally
{
    return YES;
}

- (BOOL)leaveTrackingObjectAndNotify:(BOOL)aNotify registerInCard:(BOOL)aCard forceSwitchTool:(BOOL)aTool
{
    _isAppendPending = NO;
    return (BOOL)[super leaveTrackingObjectAndNotify:aNotify registerInCard:aCard forceSwitchTool:aTool];
}

- (void)setView:(id)aView
{
    if ([self view] != aView) {
        [self stopIdleMouseAutoscrolling];
        if (aView != nil) {
            _savedWindowAcceptsMouseMovedEventsFlag = (BOOL)[[aView window] acceptsMouseMovedEvents];
            [[aView window] setAcceptsMouseMovedEvents:YES];
        }
        [[[self view] window] setAcceptsMouseMovedEvents:_savedWindowAcceptsMouseMovedEventsFlag];
        [super setView:aView];
    }
}

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(performIdleMouseAutoscroll) object:nil];
    [_autoscrollEvent release];
    [super dealloc];
}

@end

