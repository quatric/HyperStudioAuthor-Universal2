#import "HSSegmentBodyView.h"

@implementation HSSegmentBodyView

/* i386 ivar offsets: _segmentView=0x50, _graphicObjects=0x54, _guider=0x58, _isTracking=0x5c, _isTrackingCurrentTime=0x5d, _trackingPegIndex=0x60 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_0004b63c @ 0004b63c, 701 bytes * /

BOOL FUN_0004b63c(HSSegmentBodyView *self,SEL _cmd,id needsAutoscrollForMouseEvent)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  float fVar4;
  float fVar5;
  float fVar6;
  float fVar7;
  float local_64;
  float local_60;
  float local_5c;
  float local_58;
  undefined8 local_54;
  undefined8 local_4c;
  undefined1 local_44 [16];
  float local_34;
  float local_30;
  float local_2c;
  float local_28;
  undefined1 local_24 [20];
  
  pvVar2 = _objc_msgSend(needsAutoscrollForMouseEvent,sel_locationInWindow);
  pvVar3 = _objc_msgSend(self,sel_enclosingScrollView);
  pvVar3 = _objc_msgSend(pvVar3,sel_contentView);
  if (pvVar3 != (id)0x0) {
    _objc_msgSend_stret(&local_64,self,sel_bounds);
    _objc_msgSend_stret(&local_54,self,sel_bounds);
    _objc_msgSend_stret(local_44,pvVar3,sel_documentVisibleRect);
    _NSIntersectionRect(&local_34,(int)local_44._0_8_,SUB84(local_44._0_8_,4),(int)local_44._8_8_,
                        SUB84(local_44._8_8_,4),local_54,local_4c);
    fVar5 = ABS(local_60) + local_58;
    fVar7 = ABS(local_30) + local_28;
    if ((fVar7 != 0.0) || (NAN(fVar7))) {
      fVar7 = ABS(fVar7);
    }
    else {
      fVar7 = 1.0;
    }
    if ((fVar5 != 0.0) || (NAN(fVar5))) {
      fVar5 = ABS(fVar5);
    }
    else {
      fVar5 = 1.0;
    }
    fVar6 = ABS(local_64) + local_5c;
    fVar4 = ABS(local_34) + local_2c;
    if (fVar5 <= fVar7) {
      fVar5 = fVar7;
    }
    if ((fVar4 != 0.0) || (NAN(fVar4))) {
      fVar4 = ABS(fVar4);
    }
    else {
      fVar4 = 1.0;
    }
    if ((fVar6 != 0.0) || (NAN(fVar6))) {
      fVar6 = ABS(fVar6);
    }
    else {
      fVar6 = 1.0;
    }
    if (fVar6 <= fVar4) {
      fVar6 = fVar4;
    }
    if ((((fVar6 * 0.0005 < ABS(local_34 - local_64)) || (fVar5 * 0.0005 < ABS(local_30 - local_60))
         ) || (fVar6 * 0.0005 < ABS(local_2c - local_5c))) ||
       (fVar5 * 0.0005 < ABS(local_28 - local_58))) {
      _objc_msgSend_stret(local_24,pvVar3,sel_bounds);
      pvVar2 = _objc_msgSend(pvVar3,sel_convertPoint_fromView_,pvVar2,extraout_EDX,0);
      cVar1 = _NSPointInRect(pvVar2,extraout_EDX_00,(int)local_24._0_8_,SUB84(local_24._0_8_,4),
                             (int)local_24._8_8_,SUB84(local_24._8_8_,4));
      return cVar1 == '\0';
    }
  }
  return '\0';
}

*/
- (BOOL)needsAutoscrollForMouseEvent:(id)aEvent
{
    NSPoint location = [aEvent locationInWindow];
    NSClipView *content = [[self enclosingScrollView] contentView];
    if (content != nil) {
        NSRect bounds = [self bounds];
        NSRect visibleBounds = [self bounds];
        NSRect visible = [content documentVisibleRect];
        NSRect clipped = NSIntersectionRect(visible, visibleBounds);
        float yA = fabsf(bounds.origin.y) + bounds.size.height;
        float yB = fabsf(clipped.origin.y) + clipped.size.height;
        yB = yB != 0.0 ? fabsf(yB) : 1.0;
        yA = yA != 0.0 ? fabsf(yA) : 1.0;
        float xA = fabsf(bounds.origin.x) + bounds.size.width;
        float xB = fabsf(clipped.origin.x) + clipped.size.width;
        float yTol = (yA <= yB ? yB : yA);
        xB = xB != 0.0 ? fabsf(xB) : 1.0;
        xA = xA != 0.0 ? fabsf(xA) : 1.0;
        float xTol = (xA <= xB ? xB : xA);
        if (xTol * 0.0005 < fabsf(clipped.origin.x - bounds.origin.x)
            || yTol * 0.0005 < fabsf(clipped.origin.y - bounds.origin.y)
            || xTol * 0.0005 < fabsf(clipped.size.width - bounds.size.width)
            || yTol * 0.0005 < fabsf(clipped.size.height - bounds.size.height)) {
            NSRect contentBounds = [content bounds];
            NSPoint point = [content convertPoint:location fromView:nil];
            return !NSPointInRect(point, contentBounds);
        }
    }
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0004b8f9 @ 0004b8f9, 702 bytes * /

void FUN_0004b8f9(HSSegmentBodyView *self,SEL _cmd,id startTrackingWithEvent)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  undefined4 extraout_EDX;
  id pvVar3;
  double dVar4;
  id pvVar5;
  undefined4 uVar6;
  
  pvVar3 = (id)0x0;
  pvVar1 = _objc_msgSend(self,sel_window);
  do {
    pvVar5 = (id)0x10044;
    self_00 = _objc_msgSend(pvVar1,sel_nextEventMatchingMask_,0x10044);
    if (self_00 == (id)0x0) {
      if (pvVar3 != (id)0x0) {
        _objc_msgSend(pvVar3,sel_release,pvVar5);
        _objc_msgSend(cls_NSEvent,sel_stopPeriodicEvents);
      }
      return;
    }
    pvVar2 = _objc_msgSend(self_00,sel_type,pvVar5);
    if (pvVar2 == (id)0x2) {
      if (0 < self->_trackingPegIndex) {
        pvVar3 = _objc_msgSend(self,sel_segmentView,pvVar5);
        _objc_msgSend(pvVar3,sel_stopBodyEditing);
      }
      if (self->_isTracking == '\0') {
        return;
      }
      uVar6 = 0xffffffff;
      pvVar3 = self_00;
      _objc_msgSend(pvVar1,sel_discardEventsMatchingMask_beforeEvent_,0xffffffff,self_00);
      if (self->_isTrackingCurrentTime != '\0') {
        pvVar1 = _objc_msgSend(self_00,sel_locationInWindow,uVar6,pvVar3);
        pvVar1 = _objc_msgSend(self,sel_convertPoint_fromView_,pvVar1,extraout_EDX,0);
        dVar4 = _objc_msgSend_fpret(self->_segmentView,sel_valueForX_,pvVar1);
        pvVar1 = _objc_msgSend(self,sel_segmentView);
        _objc_msgSend(pvVar1,sel_stopChangingCurrentValue_,(float)dVar4);
      }
      self->_isTracking = '\0';
      self->_isTrackingCurrentTime = '\0';
      return;
    }
    if (pvVar2 == (id)0x6) {
      self->_isTracking = '\x01';
      if (pvVar3 != (id)0x0) {
        _objc_msgSend(pvVar3,sel_release,pvVar5);
        _objc_msgSend(cls_NSEvent,sel_stopPeriodicEvents);
        pvVar3 = (id)0x0;
      }
      _objc_msgSend(self,sel_handleMouseDragged_,self_00);
      pvVar5 = self_00;
      pvVar2 = _objc_msgSend(self,sel_needsAutoscrollForMouseEvent_,self_00);
      if ((char)pvVar2 != '\0') {
        pvVar3 = _objc_msgSend(self_00,sel_retain,pvVar5);
        _objc_msgSend(cls_NSEvent,sel_startPeriodicEventsAfterDelay_withPeriod_,0xa0000000,
                      0x3fb99999,0xa0000000,0x3fb99999);
        pvVar5 = self_00;
LAB_0004b954:
        _objc_msgSend(self,sel_autoscroll_,pvVar5);
      }
    }
    else if ((pvVar2 == (id)0x10) && (pvVar3 != (id)0x0)) {
      _objc_msgSend(self,sel_handleMouseDragged_,self_00);
      pvVar5 = pvVar3;
      goto LAB_0004b954;
    }
    _objc_msgSend(self,sel_displayIfNeeded,pvVar5);
  } while( true );
}

*/
- (void)startTrackingWithEvent:(id)aEvent
{
    NSEvent *autoscrollEvent = nil;
    NSWindow *window = [self window];
    while (YES) {
        NSEvent *event = [window nextEventMatchingMask:0x10044];
        if (event == nil) {
            if (autoscrollEvent != nil) {
                [autoscrollEvent release];
                [NSEvent stopPeriodicEvents];
            }
            return;
        }
        NSInteger type = [event type];
        if (type == 2) {
            if (_trackingPegIndex > 0) {
                [[self segmentView] stopBodyEditing];
            }
            if (autoscrollEvent != nil) {
                [autoscrollEvent release];
                [NSEvent stopPeriodicEvents];
            }
            if (!_isTracking) {
                return;
            }
            [window discardEventsMatchingMask:0xffffffff beforeEvent:event];
            if (_isTrackingCurrentTime) {
                NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
                double value = [_segmentView valueForX:point.x];
                [[self segmentView] stopChangingCurrentValue:(float)value];
            }
            _isTracking = NO;
            _isTrackingCurrentTime = NO;
            return;
        }
        if (type == 6) {
            _isTracking = YES;
            if (autoscrollEvent != nil) {
                [autoscrollEvent release];
                [NSEvent stopPeriodicEvents];
                autoscrollEvent = nil;
            }
            [self handleMouseDragged:event];
            if ([self needsAutoscrollForMouseEvent:event]) {
                autoscrollEvent = [event retain];
                [NSEvent startPeriodicEventsAfterDelay:0.1 withPeriod:0.1];
                [self autoscroll:event];
            }
        }
        else if (type == 0x10 && autoscrollEvent != nil) {
            [self handleMouseDragged:autoscrollEvent];
            [self autoscroll:autoscrollEvent];
        }
        [self displayIfNeeded];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0004bbb7 @ 0004bbb7, 121 bytes * /

id FUN_0004bbb7(HSSegmentBodyView *self,SEL _cmd,NSPoint objectHitTest)

{
  id self_00;
  id pvVar1;
  id self_01;
  
  self_00 = _objc_msgSend(self->_graphicObjects,sel_reverseObjectEnumerator);
  do {
    self_01 = _objc_msgSend(self_00,sel_nextObject);
    if (self_01 == (id)0x0) {
      return (id)0x0;
    }
    pvVar1 = _objc_msgSend(self_01,sel_hitTest_,objectHitTest.x,objectHitTest.y);
  } while ((char)pvVar1 == '\0');
  return self_01;
}

*/
- (id)objectHitTest:(NSPoint)aTest
{
    NSEnumerator *enumerator = [_graphicObjects reverseObjectEnumerator];
    id object;
    while ((object = [enumerator nextObject]) != nil) {
        if ([object hitTest:aTest]) {
            return object;
        }
    }
    return nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0004bc30 @ 0004bc30, 1029 bytes * /

void FUN_0004bc30(HSSegmentBodyView *self,SEL _cmd,id handleMouseDragged)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  HSSegmentView *self_00;
  int iVar4;
  undefined4 extraout_EDX;
  float fVar5;
  float fVar6;
  float fVar7;
  float fVar8;
  double dVar9;
  double dVar10;
  SEL op;
  undefined4 uVar12;
  undefined8 uVar11;
  double local_4c;
  
  pvVar1 = _objc_msgSend(self,sel_segmentView);
  pvVar1 = _objc_msgSend(pvVar1,sel_dataSource);
  pvVar1 = _objc_msgSend(pvVar1,sel_shouldAllowInteraction);
  if ((char)pvVar1 == '\0') {
    return;
  }
  if (self->_isTracking == '\0') {
    return;
  }
  pvVar2 = _objc_msgSend(handleMouseDragged,sel_locationInWindow);
  pvVar1 = (id)0x0;
  uVar12 = extraout_EDX;
  pvVar2 = _objc_msgSend(self,sel_convertPoint_fromView_,pvVar2,extraout_EDX,0);
  local_4c = _objc_msgSend_fpret(self->_segmentView,sel_valueForX_,pvVar2);
  self_00 = self->_segmentView;
  if (self->_isTrackingCurrentTime == '\0') {
    iVar4 = self->_trackingPegIndex + -1;
    uVar11 = CONCAT44(uVar12,iVar4);
    dVar9 = _objc_msgSend_fpret(self_00,sel_pegValueAtIndex_,iVar4);
    pvVar2 = _objc_msgSend(self->_segmentView,sel_class,uVar11,pvVar1);
    uVar12 = (undefined4)((ulonglong)uVar11 >> 0x20);
    dVar10 = _objc_msgSend_fpret(pvVar2,sel_minSegmentDuration);
    fVar6 = (float)dVar10;
    fVar5 = (float)(local_4c - (double)(float)dVar9);
    if ((fVar5 != 0.0) || (NAN(fVar5))) {
      fVar8 = ABS(fVar5);
    }
    else {
      fVar8 = 1.0;
    }
    if ((fVar6 != 0.0) || (NAN(fVar6))) {
      fVar7 = ABS(fVar6);
    }
    else {
      fVar7 = 1.0;
    }
    if (fVar7 <= fVar8) {
      fVar7 = fVar8;
    }
    if (fVar5 < fVar6 + fVar7 * -0.0005) {
      pvVar2 = _objc_msgSend(self->_segmentView,sel_class);
      dVar10 = _objc_msgSend_fpret(pvVar2,sel_minSegmentDuration);
      local_4c = (double)((float)dVar9 + (float)dVar10);
    }
    dVar9 = (double)CONCAT44(uVar12,self->_trackingPegIndex);
    dVar10 = _objc_msgSend_fpret(self->_segmentView,sel_pegValueAtIndex_,self->_trackingPegIndex);
    fVar6 = (float)(local_4c - dVar10);
    if ((fVar6 != 0.0) || (NAN(fVar6))) {
      fVar5 = ABS(fVar6);
    }
    else {
      fVar5 = 1.0;
    }
    fVar8 = 1.0;
    fVar7 = 0.0005;
    if (1.0 <= fVar5) {
      fVar7 = fVar5 * 0.0005;
    }
    if (fVar7 + 0.0 < fVar6) {
      pvVar2 = _objc_msgSend(self->_segmentView,sel_pegCount);
      self_00 = self->_segmentView;
      op = sel_continueBodyEditing;
      if (self->_trackingPegIndex <= (int)pvVar2 + -1) {
        pvVar2 = (id)((int)pvVar2 - 1);
        do {
          dVar9 = _objc_msgSend_fpret(self_00,sel_pegValueAtIndex_,pvVar2);
          dVar9 = dVar9 + (double)fVar6;
          pvVar1 = pvVar2;
          _objc_msgSend(self_00,sel_setPegValue_atIndex_,dVar9,pvVar2);
          pvVar2 = (id)((int)pvVar2 - 1);
          self_00 = self->_segmentView;
          op = sel_continueBodyEditing;
        } while (self->_trackingPegIndex <= (int)pvVar2);
      }
    }
    else {
      if ((fVar6 != 0.0) || (NAN(fVar6))) {
        fVar8 = ABS(fVar6);
      }
      fVar5 = 0.0005;
      if (1.0 <= fVar8) {
        fVar5 = fVar8 * 0.0005;
      }
      if (0.0 - fVar5 <= fVar6) goto LAB_0004c015;
      pvVar2 = (id)self->_trackingPegIndex;
      pvVar3 = _objc_msgSend(self->_segmentView,sel_pegCount);
      self_00 = self->_segmentView;
      op = sel_continueBodyEditing;
      if (pvVar2 < pvVar3) {
        do {
          dVar9 = _objc_msgSend_fpret(self_00,sel_pegValueAtIndex_,pvVar2);
          dVar9 = dVar9 + (double)fVar6;
          pvVar1 = pvVar2;
          _objc_msgSend(self_00,sel_setPegValue_atIndex_,dVar9,pvVar2);
          pvVar2 = (id)((int)pvVar2 + 1);
          pvVar3 = _objc_msgSend(self->_segmentView,sel_pegCount);
          self_00 = self->_segmentView;
          op = sel_continueBodyEditing;
        } while (pvVar2 < pvVar3);
      }
    }
  }
  else {
    dVar9 = (double)CONCAT44(uVar12,(float)local_4c);
    op = sel_continueChangingCurrentValue_;
  }
  _objc_msgSend(self_00,op,dVar9,pvVar1);
LAB_0004c015:
  _objc_msgSend(self->_segmentView,sel_refresh);
  return;
}

*/
- (void)handleMouseDragged:(id)aDragged
{
    if (![[[self segmentView] dataSource] shouldAllowInteraction]) {
        return;
    }
    if (!_isTracking) {
        return;
    }
    NSPoint point = [self convertPoint:[aDragged locationInWindow] fromView:nil];
    double value = [_segmentView valueForX:point.x];
    if (_isTrackingCurrentTime) {
        [_segmentView continueChangingCurrentValue:(float)value];
    }
    else {
        double previous = [_segmentView pegValueAtIndex:_trackingPegIndex - 1];
        float minimum = (float)[[_segmentView class] minSegmentDuration];
        float gap = (float)(value - (double)(float)previous);
        float a = gap != 0.0 ? fabsf(gap) : 1.0;
        float b = minimum != 0.0 ? fabsf(minimum) : 1.0;
        float m = b <= a ? a : b;
        if (gap < minimum + m * -0.0005) {
            value = (double)((float)previous + (float)[[_segmentView class] minSegmentDuration]);
        }
        double current = [_segmentView pegValueAtIndex:_trackingPegIndex];
        float delta = (float)(value - current);
        float magnitude = delta != 0.0 ? fabsf(delta) : 1.0;
        float tolerance = 0.0005;
        if (1.0 <= magnitude) {
            tolerance = magnitude * 0.0005;
        }
        if (tolerance + 0.0 < delta) {
            for (NSInteger i = (NSInteger)[_segmentView pegCount] - 1; _trackingPegIndex <= i; i--) {
                [_segmentView setPegValue:[_segmentView pegValueAtIndex:i] + (double)delta atIndex:i];
            }
            [_segmentView continueBodyEditing];
        }
        else {
            if (0.0 - tolerance <= delta) {
                goto refresh;
            }
            for (NSInteger i = _trackingPegIndex; i < (NSInteger)[_segmentView pegCount]; i++) {
                [_segmentView setPegValue:[_segmentView pegValueAtIndex:i] + (double)delta atIndex:i];
            }
            [_segmentView continueBodyEditing];
        }
    }
refresh:
    [_segmentView refresh];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0004c035 @ 0004c035, 935 bytes * /

void FUN_0004c035(HSSegmentBodyView *self,SEL _cmd,id mouseDown)

{
  HSSegmentView *pHVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  int extraout_EDX_01;
  undefined4 extraout_EDX_02;
  undefined8 uVar5;
  double dVar6;
  SEL op;
  undefined4 uVar7;
  undefined4 uVar8;
  
  pvVar2 = _objc_msgSend(self,sel_segmentView);
  pvVar2 = _objc_msgSend(pvVar2,sel_dataSource);
  pvVar2 = _objc_msgSend(pvVar2,sel_shouldAllowInteraction);
  if ((char)pvVar2 != '\0') {
    pvVar2 = _objc_msgSend(mouseDown,sel_locationInWindow);
    uVar8 = 0;
    pvVar2 = _objc_msgSend(self,sel_convertPoint_fromView_,pvVar2,extraout_EDX,0);
    uVar7 = extraout_EDX_00;
    pvVar3 = _objc_msgSend(self,sel_objectHitTest_,pvVar2,extraout_EDX_00);
    self->_trackingPegIndex = -1;
    pvVar4 = _objc_msgSend(cls_HSSegmentGuiderGraphicObject,sel_class);
    uVar5 = CONCAT44(uVar7,pvVar4);
    pvVar4 = _objc_msgSend(pvVar3,sel_isKindOfClass_,pvVar4);
    if ((char)pvVar4 == '\0') {
      pvVar4 = _objc_msgSend(cls_HSSegmentPegGraphicObject,sel_class,uVar5,uVar8);
      uVar5 = CONCAT44((int)((ulonglong)uVar5 >> 0x20),pvVar4);
      pvVar4 = _objc_msgSend(pvVar3,sel_isKindOfClass_,pvVar4);
      if ((char)pvVar4 == '\0') {
        pvVar4 = _objc_msgSend(cls_HSSegmentSelectionGraphicObject,sel_class,uVar5);
        uVar5 = CONCAT44((int)((ulonglong)uVar5 >> 0x20),pvVar4);
        pvVar4 = _objc_msgSend(pvVar3,sel_isKindOfClass_,pvVar4);
        if ((char)pvVar4 == '\0') {
          pvVar4 = _objc_msgSend(cls_HSSegmentBodyGraphicObject,sel_class,uVar5);
          uVar5 = CONCAT44((int)((ulonglong)uVar5 >> 0x20),pvVar4);
          pvVar4 = _objc_msgSend(pvVar3,sel_isKindOfClass_,pvVar4);
          if ((char)pvVar4 == '\0') {
            pvVar4 = _objc_msgSend(cls_HSSegmentBackgroundGraphicObject,sel_class,uVar5);
            uVar5 = CONCAT44((int)((ulonglong)uVar5 >> 0x20),pvVar4);
            pvVar3 = _objc_msgSend(pvVar3,sel_isKindOfClass_,pvVar4);
            if ((char)pvVar3 == '\0') {
              return;
            }
          }
          uVar5 = CONCAT44((int)((ulonglong)uVar5 >> 0x20),pvVar2);
          pvVar2 = _objc_msgSend(self->_segmentView,sel_segmentAtX_,pvVar2);
          if (pvVar2 == (id)0xffffffff) {
            uVar5 = 0;
          }
          else {
            _objc_msgSend(self->_segmentView,sel_selectedSegments,uVar5);
            if ((extraout_EDX_01 == 0) ||
               (pvVar3 = _objc_msgSend(mouseDown,sel_modifierFlags,uVar5),
               ((uint)pvVar3 & 0x1e0000) != 0x20000)) {
              uVar5 = CONCAT44(1,pvVar2);
            }
            else {
              pvVar3 = _objc_msgSend(self->_segmentView,sel_selectedSegments,uVar5);
              uVar5 = _NSUnionRange(pvVar2,1,pvVar3,extraout_EDX_02);
            }
          }
          _objc_msgSend(self->_segmentView,sel_setSelectedSegments_,(int)uVar5,
                        (int)((ulonglong)uVar5 >> 0x20));
          self = (HSSegmentBodyView *)self->_segmentView;
          op = sel_refresh;
        }
        else {
          pvVar2 = _objc_msgSend(mouseDown,sel_modifierFlags,uVar5);
          if (((uint)pvVar2 & 0x1e0000) != 0x100000) {
            return;
          }
          uVar5 = 0;
          _objc_msgSend(self->_segmentView,sel_setSelectedSegments_,0,0);
          self = (HSSegmentBodyView *)self->_segmentView;
          op = sel_refresh;
        }
      }
      else {
        pHVar1 = self->_segmentView;
        dVar6 = _objc_msgSend_fpret(pvVar3,sel_time);
        pvVar2 = _objc_msgSend(pHVar1,sel_pegIndexAtValue_,dVar6);
        self->_trackingPegIndex = (int)pvVar2;
        if ((int)pvVar2 < 1) {
          return;
        }
        _objc_msgSend(self->_segmentView,sel_startBodyEditing,dVar6);
        uVar5 = CONCAT44((int)((ulonglong)dVar6 >> 0x20),mouseDown);
        op = sel_startTrackingWithEvent_;
      }
    }
    else {
      self->_isTrackingCurrentTime = '\x01';
      pHVar1 = self->_segmentView;
      dVar6 = _objc_msgSend_fpret(pvVar3,sel_time);
      uVar7 = (undefined4)((ulonglong)uVar5 >> 0x20);
      _objc_msgSend(pHVar1,sel_startChangingCurrentValue_,(float)dVar6);
      uVar5 = CONCAT44(uVar7,mouseDown);
      op = sel_startTrackingWithEvent_;
    }
    _objc_msgSend(self,op,uVar5);
  }
  return;
}

*/
- (void)mouseDown:(id)aDown
{
    if (![[[self segmentView] dataSource] shouldAllowInteraction]) {
        return;
    }
    NSPoint point = [self convertPoint:[aDown locationInWindow] fromView:nil];
    id object = [self objectHitTest:point];
    _trackingPegIndex = -1;
    if ([object isKindOfClass:[HSSegmentGuiderGraphicObject class]]) {
        _isTrackingCurrentTime = YES;
        [_segmentView startChangingCurrentValue:(float)[(HSSegmentGuiderGraphicObject *)object time]];
        [self startTrackingWithEvent:aDown];
    }
    else if ([object isKindOfClass:[HSSegmentPegGraphicObject class]]) {
        _trackingPegIndex = (int)[_segmentView pegIndexAtValue:[(HSSegmentPegGraphicObject *)object time]];
        if (_trackingPegIndex < 1) {
            return;
        }
        [_segmentView startBodyEditing];
        [self startTrackingWithEvent:aDown];
    }
    else if ([object isKindOfClass:[HSSegmentSelectionGraphicObject class]]) {
        if (([aDown modifierFlags] & 0x1e0000) != 0x100000) {
            return;
        }
        [_segmentView setSelectedSegments:NSMakeRange(0, 0)];
        [_segmentView refresh];
    }
    else if ([object isKindOfClass:[HSSegmentBodyGraphicObject class]] || [object isKindOfClass:[HSSegmentBackgroundGraphicObject class]]) {
        NSInteger segment = [_segmentView segmentAtX:point.x];
        NSRange selection;
        if (segment == -1) {
            selection = NSMakeRange(0, 0);
        }
        else {
            NSRange current = [_segmentView selectedSegments];
            if (current.length == 0 || ([aDown modifierFlags] & 0x1e0000) != 0x20000) {
                selection = NSMakeRange(segment, 1);
            }
            else {
                selection = NSUnionRange(NSMakeRange(segment, 1), current);
            }
        }
        [_segmentView setSelectedSegments:selection];
        [_segmentView refresh];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0004c3dc @ 0004c3dc, 689 bytes * /

void FUN_0004c3dc(HSSegmentBodyView *self,SEL _cmd,NSRect drawRect)

{
  int *piVar1;
  char cVar2;
  id pvVar3;
  id pvVar4;
  int *piVar5;
  longdouble lVar6;
  longdouble lVar7;
  float fVar8;
  int local_74 [2];
  float local_34;
  float local_30;
  float local_2c;
  float local_28;
  undefined8 local_24;
  undefined8 local_1c;
  
  piVar5 = (int *)&stack0xffffff94;
  _objc_msgSend(cls_NSGraphicsContext,sel_saveGraphicsState);
  _objc_msgSend(cls_NSBezierPath,sel_clipRect_);
  pvVar3 = _objc_msgSend(self->_graphicObjects,sel_objectEnumerator);
  pvVar4 = _objc_msgSend(pvVar3,sel_nextObject);
  piVar1 = (int *)&stack0xffffff94;
  while (pvVar4 != (id)0x0) {
    piVar1[2] = (int)sel_bounds;
    piVar1[1] = (int)pvVar4;
    *piVar1 = (int)&local_24;
    piVar1[-1] = 0x4c484;
    _objc_msgSend_stret((void *)*piVar1,(id)piVar1[1],(SEL)piVar1[2]);
    piVar5 = piVar1 + -1;
    *(NSSize *)(piVar1 + 5) = drawRect.size;
    *(NSPoint *)(piVar1 + 3) = drawRect.origin;
    *(undefined8 *)(piVar1 + 1) = local_1c;
    *(undefined8 *)(piVar1 + -1) = local_24;
    piVar1[-2] = 0x4c4b6;
    cVar2 = _NSIntersectsRect();
    if (cVar2 != '\0') {
      *(NSSize *)(piVar1 + 3) = drawRect.size;
      *(NSPoint *)(piVar1 + 1) = drawRect.origin;
      *piVar1 = (int)sel_drawInRect_;
      piVar1[-1] = (int)pvVar4;
      piVar1[-2] = 0x4c4e1;
      _objc_msgSend((id)piVar1[-1],(SEL)*piVar1);
    }
    *piVar1 = (int)sel_nextObject;
    piVar1[-1] = (int)pvVar3;
    piVar1[-2] = 0x4c4f6;
    pvVar4 = _objc_msgSend((id)piVar1[-1],(SEL)*piVar1);
    piVar1 = piVar1 + -1;
  }
  piVar5[1] = (int)sel_bezierPath;
  *piVar5 = (int)cls_NSBezierPath;
  piVar5[-1] = 0x4c518;
  pvVar4 = _objc_msgSend((id)*piVar5,(SEL)piVar5[1]);
  piVar5[2] = (int)sel_bounds;
  piVar5[1] = (int)self;
  *piVar5 = (int)&local_34;
  piVar5[-1] = 0x4c536;
  _objc_msgSend_stret((void *)*piVar5,(id)piVar5[1],(SEL)piVar5[2]);
  piVar5[-1] = (int)local_30;
  piVar5[-2] = 0x4c54d;
  lVar6 = (longdouble)_floorf();
  piVar5[-1] = (int)(local_30 + local_28);
  piVar5[-2] = 0x4c564;
  lVar7 = (longdouble)_floorf();
  fVar8 = local_34;
  piVar5[2] = (int)((float)lVar6 + 0.5);
  piVar5[1] = (int)fVar8;
  *piVar5 = (int)sel_moveToPoint_;
  piVar5[-1] = (int)pvVar4;
  piVar5[-2] = 0x4c59c;
  _objc_msgSend((id)piVar5[-1],(SEL)*piVar5);
  fVar8 = local_34 + local_2c;
  piVar5[2] = (int)((float)lVar6 + 0.5);
  piVar5[1] = (int)fVar8;
  *piVar5 = (int)sel_lineToPoint_;
  piVar5[-1] = (int)pvVar4;
  piVar5[-2] = 0x4c5cf;
  _objc_msgSend((id)piVar5[-1],(SEL)*piVar5);
  fVar8 = local_34;
  piVar5[2] = (int)((float)lVar7 + -0.5);
  piVar5[1] = (int)fVar8;
  *piVar5 = (int)sel_moveToPoint_;
  piVar5[-1] = (int)pvVar4;
  piVar5[-2] = 0x4c604;
  _objc_msgSend((id)piVar5[-1],(SEL)*piVar5);
  piVar5[2] = (int)((float)lVar7 + -0.5);
  piVar5[1] = (int)(local_34 + local_2c);
  *piVar5 = (int)sel_lineToPoint_;
  piVar5[-1] = (int)pvVar4;
  piVar5[-2] = 0x4c631;
  _objc_msgSend((id)piVar5[-1],(SEL)*piVar5);
  *piVar5 = (int)sel_darkGrayColor;
  piVar5[-1] = (int)cls_NSColor;
  piVar5[-2] = 0x4c649;
  pvVar3 = _objc_msgSend((id)piVar5[-1],(SEL)*piVar5);
  *piVar5 = (int)sel_set;
  piVar5[-1] = (int)pvVar3;
  piVar5[-2] = 0x4c65b;
  _objc_msgSend((id)piVar5[-1],(SEL)*piVar5);
  *piVar5 = (int)sel_stroke;
  piVar5[-1] = (int)pvVar4;
  piVar5[-2] = 0x4c66d;
  _objc_msgSend((id)piVar5[-1],(SEL)*piVar5);
  *piVar5 = (int)sel_restoreGraphicsState;
  piVar5[-1] = (int)cls_NSGraphicsContext;
  piVar5[-2] = 0x4c685;
  _objc_msgSend((id)piVar5[-1],(SEL)*piVar5);
  return;
}

*/
- (void)drawRect:(NSRect)aRect
{
    [NSGraphicsContext saveGraphicsState];
    [NSBezierPath clipRect:aRect];
    NSEnumerator *enumerator = [_graphicObjects objectEnumerator];
    id object;
    while ((object = [enumerator nextObject]) != nil) {
        if (NSIntersectsRect([object bounds], aRect)) {
            [object drawInRect:aRect];
        }
    }
    NSBezierPath *path = [NSBezierPath bezierPath];
    NSRect bounds = [self bounds];
    float bottom = floorf(bounds.origin.y);
    float top = floorf(bounds.origin.y + bounds.size.height);
    [path moveToPoint:NSMakePoint(bounds.origin.x, bottom + 0.5)];
    [path lineToPoint:NSMakePoint(bounds.origin.x + bounds.size.width, bottom + 0.5)];
    [path moveToPoint:NSMakePoint(bounds.origin.x, top + -0.5)];
    [path lineToPoint:NSMakePoint(bounds.origin.x + bounds.size.width, top + -0.5)];
    [[NSColor darkGrayColor] set];
    [path stroke];
    [NSGraphicsContext restoreGraphicsState];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0004c68d @ 0004c68d, 464 bytes * /

void FUN_0004c68d(HSSegmentBodyView *self,SEL _cmd)

{
  int *piVar1;
  char cVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  int *piVar7;
  undefined8 local_44;
  undefined8 local_3c;
  undefined8 local_34;
  undefined8 local_2c;
  undefined8 local_24;
  undefined8 local_1c;
  
  pvVar3 = _objc_msgSend(self,sel_segmentView);
  pvVar3 = _objc_msgSend(pvVar3,sel_dataSource);
  pvVar3 = _objc_msgSend(pvVar3,sel_shouldAllowInteraction);
  if ((char)pvVar3 == '\0') {
    return;
  }
  _objc_msgSend_stret(&local_44,self,sel_visibleRect);
  pvVar3 = _objc_msgSend(self->_graphicObjects,sel_objectEnumerator);
  pvVar4 = _objc_msgSend(cls_NSCursor,sel_resizeLeftRightCursor);
  piVar1 = (int *)&stack0xffffff90;
LAB_0004c83b:
  do {
    piVar7 = piVar1;
    piVar7[1] = (int)sel_nextObject;
    *piVar7 = (int)pvVar3;
    piVar7[-1] = 0x4c84d;
    pvVar6 = _objc_msgSend((id)*piVar7,(SEL)piVar7[1]);
    if (pvVar6 == (id)0x0) {
      return;
    }
    piVar7[2] = (int)sel_bounds;
    piVar7[1] = (int)pvVar6;
    *piVar7 = (int)&local_34;
    piVar7[-1] = 0x4c74e;
    _objc_msgSend_stret((void *)*piVar7,(id)piVar7[1],(SEL)piVar7[2]);
    *(undefined8 *)(piVar7 + 5) = local_3c;
    *(undefined8 *)(piVar7 + 3) = local_44;
    *(undefined8 *)(piVar7 + 1) = local_2c;
    *(undefined8 *)(piVar7 + -1) = local_34;
    piVar7[-2] = 0x4c781;
    cVar2 = _NSIntersectsRect();
    piVar1 = piVar7 + -1;
  } while (cVar2 == '\0');
  *piVar7 = (int)sel_class;
  piVar7[-1] = (int)cls_HSSegmentPegGraphicObject;
  piVar7[-2] = 0x4c7a1;
  pvVar5 = _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
  piVar7[1] = (int)pvVar5;
  *piVar7 = (int)sel_isKindOfClass_;
  piVar7[-1] = (int)pvVar6;
  piVar7[-2] = 0x4c7b7;
  pvVar5 = _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
  if ((char)pvVar5 == '\0') goto code_r0x0004c7bb;
  goto LAB_0004c7ed;
code_r0x0004c7bb:
  *piVar7 = (int)sel_class;
  piVar7[-1] = (int)cls_HSSegmentGuiderGraphicObject;
  piVar7[-2] = 0x4c7d3;
  pvVar5 = _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
  piVar7[1] = (int)pvVar5;
  *piVar7 = (int)sel_isKindOfClass_;
  piVar7[-1] = (int)pvVar6;
  piVar7[-2] = 0x4c7e9;
  pvVar5 = _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
  piVar1 = piVar7 + -1;
  if ((char)pvVar5 != '\0') {
LAB_0004c7ed:
    piVar7[1] = (int)sel_bounds;
    *piVar7 = (int)pvVar6;
    piVar7[-1] = (int)&local_24;
    piVar7[-2] = 0x4c806;
    _objc_msgSend_stret((void *)piVar7[-1],(id)*piVar7,(SEL)piVar7[1]);
    *(undefined8 *)(piVar7 + 2) = local_1c;
    *(undefined8 *)piVar7 = local_24;
    piVar7[4] = (int)pvVar4;
    piVar7[-1] = (int)sel_addCursorRect_cursor_;
    piVar7[-2] = (int)self;
    piVar7[-3] = 0x4c83b;
    _objc_msgSend((id)piVar7[-2],(SEL)piVar7[-1]);
    piVar1 = piVar7 + -2;
  }
  goto LAB_0004c83b;
}

*/
- (void)resetCursorRects
{
    if (![[[self segmentView] dataSource] shouldAllowInteraction]) {
        return;
    }
    NSRect visible = [self visibleRect];
    NSEnumerator *enumerator = [_graphicObjects objectEnumerator];
    NSCursor *cursor = [NSCursor resizeLeftRightCursor];
    id object;
    while ((object = [enumerator nextObject]) != nil) {
        if (!NSIntersectsRect([object bounds], visible)) {
            continue;
        }
        if ([object isKindOfClass:[HSSegmentPegGraphicObject class]] || [object isKindOfClass:[HSSegmentGuiderGraphicObject class]]) {
            [self addCursorRect:[object bounds] cursor:cursor];
        }
    }
}

- (BOOL)isOpaque
{
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0004c85d @ 0004c85d, 360 bytes * /

void FUN_0004c85d(HSSegmentBodyView *self,SEL _cmd)

{
  HSSegmentView *self_00;
  id self_01;
  HSSegmentGuiderGraphicObject *pHVar1;
  double dVar2;
  undefined1 local_44 [12];
  undefined4 local_38;
  undefined1 local_34 [4];
  undefined4 local_30;
  float local_24;
  undefined4 uStack_20;
  undefined4 local_1c;
  undefined4 uStack_18;
  
  self_01 = _objc_msgSend(cls_HSSegmentGuiderGraphicObject,sel_new);
  pHVar1 = _objc_msgSend(self_01,sel_autorelease);
  self->_guider = pHVar1;
  dVar2 = _objc_msgSend_fpret(self->_segmentView,sel_currentValue);
  _objc_msgSend(pHVar1,sel_setTime_,dVar2);
  pHVar1 = self->_guider;
  _objc_msgSend_stret(local_44,self,sel_bounds);
  _objc_msgSend_stret(local_34,self,sel_bounds);
  self_00 = self->_segmentView;
  dVar2 = _objc_msgSend_fpret(self_00,sel_currentValue);
  dVar2 = _objc_msgSend_fpret(self_00,sel_xForValue_,dVar2);
  local_24 = (float)dVar2 + -0.5;
  uStack_20 = local_30;
  local_1c = 0x3f800000;
  uStack_18 = local_38;
  _objc_msgSend(pHVar1,sel_setBounds_,CONCAT44(local_30,local_24),CONCAT44(local_38,0x3f800000));
  _objc_msgSend(self->_graphicObjects,sel_addObject_,self->_guider);
  return;
}

*/
- (void)setupGuider
{
    _guider = [[HSSegmentGuiderGraphicObject new] autorelease];
    [_guider setTime:[_segmentView currentValue]];
    NSRect bounds = [self bounds];
    float x = (float)[_segmentView xForValue:[_segmentView currentValue]] + -0.5;
    [_guider setBounds:NSMakeRect(x, bounds.origin.y, 1.0, bounds.size.height)];
    [_graphicObjects addObject:_guider];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0004c9c5 @ 0004c9c5, 466 bytes * /

void FUN_0004c9c5(HSSegmentBodyView *self,SEL _cmd)

{
  HSSegmentView *pHVar1;
  id pvVar2;
  undefined4 uVar3;
  undefined4 uVar4;
  id pvVar5;
  id pvVar6;
  double *pdVar7;
  int iVar8;
  double dVar9;
  int aiStack_88 [3];
  double local_74 [6];
  undefined1 local_44 [12];
  undefined4 local_38;
  undefined1 local_34 [4];
  undefined4 local_30;
  float local_24;
  undefined4 uStack_20;
  undefined4 local_1c;
  undefined4 uStack_18;
  
  pvVar5 = _objc_msgSend(self->_segmentView,sel_pegCount);
  if (0 < (int)pvVar5) {
    iVar8 = 0;
    pdVar7 = (double *)&stack0xffffff84;
    do {
      *(undefined **)((int)pdVar7 + 4) = sel_new;
      *(undefined **)pdVar7 = cls_HSSegmentPegGraphicObject;
      *(undefined4 *)((int)pdVar7 + -4) = 0x4ca17;
      pvVar6 = _objc_msgSend(*(id *)pdVar7,*(SEL *)((int)pdVar7 + 4));
      *(undefined **)((int)pdVar7 + 4) = sel_autorelease;
      *(id *)pdVar7 = pvVar6;
      *(undefined4 *)((int)pdVar7 + -4) = 0x4ca29;
      pvVar6 = _objc_msgSend(*(id *)pdVar7,*(SEL *)((int)pdVar7 + 4));
      pHVar1 = self->_segmentView;
      *(int *)(pdVar7 + 1) = iVar8;
      *(undefined **)((int)pdVar7 + 4) = sel_pegValueAtIndex_;
      *(HSSegmentView **)pdVar7 = pHVar1;
      *(undefined4 *)((int)pdVar7 + -4) = 0x4ca48;
      dVar9 = _objc_msgSend_fpret(*(id *)pdVar7,*(SEL *)((int)pdVar7 + 4));
      pdVar7[1] = dVar9;
      *(undefined **)((int)pdVar7 + 4) = sel_setTime_;
      *(id *)pdVar7 = pvVar6;
      *(undefined4 *)((int)pdVar7 + -4) = 0x4ca61;
      _objc_msgSend(*(id *)pdVar7,*(SEL *)((int)pdVar7 + 4));
      *(undefined **)(pdVar7 + 1) = sel_bounds;
      *(HSSegmentBodyView **)((int)pdVar7 + 4) = self;
      *(undefined1 **)pdVar7 = local_44;
      *(undefined4 *)((int)pdVar7 + -4) = 0x4ca7d;
      _objc_msgSend_stret(*(void **)pdVar7,*(id *)((int)pdVar7 + 4),*(SEL *)(pdVar7 + 1));
      uVar3 = local_38;
      *(undefined **)((int)pdVar7 + 4) = sel_bounds;
      *(HSSegmentBodyView **)pdVar7 = self;
      *(undefined1 **)((int)pdVar7 + -4) = local_34;
      *(undefined4 *)(pdVar7 + -1) = 0x4caa6;
      _objc_msgSend_stret(*(void **)((int)pdVar7 + -4),*(id *)pdVar7,*(SEL *)((int)pdVar7 + 4));
      uVar4 = local_30;
      pHVar1 = self->_segmentView;
      *(int *)pdVar7 = iVar8;
      *(undefined **)((int)pdVar7 + -4) = sel_pegValueAtIndex_;
      *(HSSegmentView **)(pdVar7 + -1) = pHVar1;
      *(undefined4 *)((int)pdVar7 + -0xc) = 0x4cacf;
      dVar9 = _objc_msgSend_fpret(*(id *)(pdVar7 + -1),*(SEL *)((int)pdVar7 + -4));
      *pdVar7 = dVar9;
      *(undefined **)((int)pdVar7 + -4) = sel_xForValue_;
      *(HSSegmentView **)(pdVar7 + -1) = pHVar1;
      *(undefined4 *)((int)pdVar7 + -0xc) = 0x4cae5;
      dVar9 = _objc_msgSend_fpret(*(id *)(pdVar7 + -1),*(SEL *)((int)pdVar7 + -4));
      local_24 = (float)dVar9 + -0.5;
      uStack_20 = uVar4;
      local_1c = 0x3f800000;
      uStack_18 = uVar3;
      pdVar7[1] = (double)CONCAT44(uVar3,0x3f800000);
      *pdVar7 = (double)CONCAT44(uVar4,local_24);
      *(undefined **)((int)pdVar7 + -4) = sel_setBounds_;
      *(id *)(pdVar7 + -1) = pvVar6;
      *(undefined4 *)((int)pdVar7 + -0xc) = 0x4cb40;
      _objc_msgSend(*(id *)(pdVar7 + -1),*(SEL *)((int)pdVar7 + -4));
      if ((iVar8 == 0) || ((int)pvVar5 + -1 == iVar8)) {
        *(undefined **)((int)pdVar7 + -4) = sel_setHidden_;
        *(id *)(pdVar7 + -1) = pvVar6;
        *(undefined4 *)pdVar7 = 1;
        *(undefined4 *)((int)pdVar7 + -0xc) = 0x4cb66;
        _objc_msgSend(*(id *)(pdVar7 + -1),*(SEL *)((int)pdVar7 + -4));
      }
      pvVar2 = self->_graphicObjects;
      *(id *)pdVar7 = pvVar6;
      *(undefined **)((int)pdVar7 + -4) = sel_addObject_;
      *(id *)(pdVar7 + -1) = pvVar2;
      *(undefined4 *)((int)pdVar7 + -0xc) = 0x4cb85;
      _objc_msgSend(*(id *)(pdVar7 + -1),*(SEL *)((int)pdVar7 + -4));
      iVar8 = iVar8 + 1;
      pdVar7 = pdVar7 + -1;
    } while (iVar8 < (int)pvVar5);
  }
  return;
}

*/
- (void)setupPegs
{
    NSInteger count = [_segmentView pegCount];
    for (NSInteger i = 0; i < count; i++) {
        HSSegmentPegGraphicObject *peg = [[HSSegmentPegGraphicObject new] autorelease];
        [peg setTime:[_segmentView pegValueAtIndex:i]];
        NSRect bounds = [self bounds];
        float x = (float)[_segmentView xForValue:[_segmentView pegValueAtIndex:i]] + -0.5;
        [peg setBounds:NSMakeRect(x, bounds.origin.y, 1.0, bounds.size.height)];
        if (i == 0 || count - 1 == i) {
            [peg setHidden:YES];
        }
        [_graphicObjects addObject:peg];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0004cb97 @ 0004cb97, 510 bytes * /

void FUN_0004cb97(HSSegmentBodyView *self,SEL _cmd)

{
  float fVar1;
  HSSegmentView *pHVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  int extraout_EDX;
  double dVar6;
  double dVar7;
  undefined1 local_44 [12];
  undefined4 local_38;
  undefined1 local_34 [4];
  undefined4 local_30;
  float local_24;
  undefined4 uStack_20;
  float local_1c;
  undefined4 uStack_18;
  
  pvVar3 = _objc_msgSend(self->_segmentView,sel_selectedSegments);
  if (extraout_EDX != 0) {
    pvVar4 = _objc_msgSend(cls_HSSegmentSelectionGraphicObject,sel_new);
    pvVar4 = _objc_msgSend(pvVar4,sel_autorelease);
    pHVar2 = self->_segmentView;
    dVar6 = _objc_msgSend_fpret(pHVar2,sel_pegValueAtIndex_,pvVar3);
    dVar6 = _objc_msgSend_fpret(pHVar2,sel_xForValue_,dVar6);
    pHVar2 = self->_segmentView;
    dVar7 = _objc_msgSend_fpret(pHVar2,sel_pegValueAtIndex_,extraout_EDX + (int)pvVar3);
    dVar7 = _objc_msgSend_fpret(pHVar2,sel_xForValue_,dVar7);
    _objc_msgSend_stret(local_44,self,sel_bounds);
    fVar1 = (float)dVar6;
    _objc_msgSend_stret(local_34,self,sel_bounds);
    uStack_20 = local_30;
    local_1c = (float)dVar7 - fVar1;
    uStack_18 = local_38;
    local_24 = fVar1;
    _objc_msgSend(pvVar4,sel_setBounds_,CONCAT44(local_30,fVar1),CONCAT44(local_38,local_1c));
    _objc_msgSend(pvVar4,sel_setLeftEdgeRounded_,(uint)(pvVar3 == (id)0x0));
    pvVar5 = _objc_msgSend(self->_segmentView,sel_pegCount);
    _objc_msgSend(pvVar4,sel_setRightEdgeRounded_,
                  (uint)(extraout_EDX + (int)pvVar3 == (int)pvVar5 + -1));
    _objc_msgSend(self->_graphicObjects,sel_addObject_,pvVar4);
  }
  return;
}

*/
- (void)setupSelection
{
    NSRange selection = [_segmentView selectedSegments];
    if (selection.length != 0) {
        HSSegmentSelectionGraphicObject *object = [[HSSegmentSelectionGraphicObject new] autorelease];
        float left = (float)[_segmentView xForValue:[_segmentView pegValueAtIndex:selection.location]];
        float right = (float)[_segmentView xForValue:[_segmentView pegValueAtIndex:selection.location + selection.length]];
        NSRect bounds = [self bounds];
        [object setBounds:NSMakeRect(left, bounds.origin.y, right - left, bounds.size.height)];
        [object setLeftEdgeRounded:selection.location == 0];
        [object setRightEdgeRounded:selection.location + selection.length == [_segmentView pegCount] - 1];
        [_graphicObjects addObject:object];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0004cd95 @ 0004cd95, 589 bytes * /

void FUN_0004cd95(HSSegmentBodyView *self,SEL _cmd)

{
  HSSegmentView *pHVar1;
  id pvVar2;
  id pvVar3;
  double dVar4;
  double dVar5;
  double dVar6;
  undefined1 local_44 [12];
  undefined4 local_38;
  undefined1 local_34 [4];
  undefined4 local_30;
  float local_24;
  undefined4 uStack_20;
  float local_1c;
  undefined4 uStack_18;
  
  pvVar2 = _objc_msgSend(cls_HSSegmentBodyGraphicObject,sel_new);
  pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
  pvVar3 = _objc_msgSend(self->_segmentView,sel_pegCount);
  if (pvVar3 == (id)0x0) {
    _objc_msgSend(pvVar2,sel_setStartValue_,0);
    _objc_msgSend(pvVar2,sel_setEndValue_,0);
  }
  else {
    dVar4 = _objc_msgSend_fpret(self->_segmentView,sel_pegValueAtIndex_,0);
    _objc_msgSend(pvVar2,sel_setStartValue_,dVar4);
    pHVar1 = self->_segmentView;
    pvVar3 = _objc_msgSend(pHVar1,sel_pegCount);
    dVar4 = _objc_msgSend_fpret(pHVar1,sel_pegValueAtIndex_,(int)pvVar3 + -1);
    _objc_msgSend(pvVar2,sel_setEndValue_,dVar4);
  }
  _objc_msgSend_stret(local_44,self,sel_bounds);
  dVar4 = _objc_msgSend_fpret(self->_segmentView,sel_totalDuration);
  dVar5 = _objc_msgSend_fpret(self->_segmentView,sel_scale);
  _objc_msgSend_stret(local_34,self,sel_bounds);
  pHVar1 = self->_segmentView;
  dVar6 = _objc_msgSend_fpret(pvVar2,sel_startValue);
  dVar6 = _objc_msgSend_fpret(pHVar1,sel_xForValue_,dVar6);
  local_24 = (float)dVar6;
  uStack_20 = local_30;
  local_1c = (float)(dVar4 * dVar5);
  uStack_18 = local_38;
  _objc_msgSend(pvVar2,sel_setBounds_,CONCAT44(local_30,local_24),CONCAT44(local_38,local_1c));
  _objc_msgSend(self->_graphicObjects,sel_addObject_,pvVar2);
  return;
}

*/
- (void)setupBody
{
    HSSegmentBodyGraphicObject *object = [[HSSegmentBodyGraphicObject new] autorelease];
    if ([_segmentView pegCount] == 0) {
        [object setStartValue:0];
        [object setEndValue:0];
    }
    else {
        [object setStartValue:[_segmentView pegValueAtIndex:0]];
        [object setEndValue:[_segmentView pegValueAtIndex:[_segmentView pegCount] - 1]];
    }
    NSRect bounds = [self bounds];
    double total = [_segmentView totalDuration];
    double scale = [_segmentView scale];
    float x = (float)[_segmentView xForValue:[object startValue]];
    [object setBounds:NSMakeRect(x, bounds.origin.y, (float)(total * scale), bounds.size.height)];
    [_graphicObjects addObject:object];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0004cfe2 @ 0004cfe2, 326 bytes * /

void FUN_0004cfe2(HSSegmentBodyView *self,SEL _cmd)

{
  HSSegmentView *self_00;
  id pvVar1;
  double dVar2;
  double dVar3;
  undefined8 local_24;
  undefined8 local_1c;
  
  pvVar1 = _objc_msgSend(cls_HSSegmentBackgroundGraphicObject,sel_new);
  pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  _objc_msgSend_stret(&local_24,self,sel_bounds);
  _objc_msgSend(pvVar1,sel_setBounds_,local_24,local_1c);
  self_00 = self->_segmentView;
  dVar2 = _objc_msgSend_fpret(self_00,sel_firstPrimaryValue);
  dVar2 = _objc_msgSend_fpret(self_00,sel_xForValue_,dVar2);
  _objc_msgSend(pvVar1,sel_setFirstGuider_,(float)dVar2);
  dVar2 = _objc_msgSend_fpret(self->_segmentView,sel_primaryInterval);
  dVar3 = _objc_msgSend_fpret(self->_segmentView,sel_scale);
  _objc_msgSend(pvVar1,sel_setGuiderInterval_,(float)(dVar2 * dVar3));
  _objc_msgSend(self->_graphicObjects,sel_addObject_,pvVar1);
  return;
}

*/
- (void)setupBackground
{
    HSSegmentBackgroundGraphicObject *object = [[HSSegmentBackgroundGraphicObject new] autorelease];
    [object setBounds:[self bounds]];
    [object setFirstGuider:(float)[_segmentView xForValue:[_segmentView firstPrimaryValue]]];
    [object setGuiderInterval:(float)([_segmentView primaryInterval] * [_segmentView scale])];
    [_graphicObjects addObject:object];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0004d128 @ 0004d128, 252 bytes * /

void FUN_0004d128(HSSegmentBodyView *self,SEL _cmd)

{
  id self_00;
  undefined1 local_2c [16];
  undefined1 local_1c [16];
  
  _objc_msgSend_stret(local_2c,self->_guider,sel_bounds);
  _objc_msgSend(self,sel_setNeedsDisplayInRect_,(int)local_2c._0_8_,SUB84(local_2c._0_8_,4),
                (int)local_2c._8_8_,SUB84(local_2c._8_8_,4));
  _objc_msgSend(self->_graphicObjects,sel_removeObject_,self->_guider);
  _objc_msgSend(self,sel_setupGuider);
  _objc_msgSend_stret(local_1c,self->_guider,sel_bounds);
  _objc_msgSend(self,sel_setNeedsDisplayInRect_,(int)local_1c._0_8_,SUB84(local_1c._0_8_,4),
                (int)local_1c._8_8_,SUB84(local_1c._8_8_,4));
  self_00 = _objc_msgSend(self,sel_window);
  _objc_msgSend(self_00,sel_invalidateCursorRectsForView_,self);
  return;
}

*/
- (void)refreshCurrentValue
{
    [self setNeedsDisplayInRect:[_guider bounds]];
    [_graphicObjects removeObject:_guider];
    [self setupGuider];
    [self setNeedsDisplayInRect:[_guider bounds]];
    [[self window] invalidateCursorRectsForView:self];
}

- (void)refresh
{
    [_graphicObjects removeAllObjects];
    [self setupBackground];
    [self setupBody];
    [self setupSelection];
    [self setupPegs];
    [self setupGuider];
    [[self window] invalidateCursorRectsForView:self];
}

- (id)segmentView
{
    return _segmentView;
}

- (void)dealloc
{
    [_graphicObjects release];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0004b5c4 @ 0004b5c4, 120 bytes * /

id FUN_0004b5c4(HSSegmentBodyView *self,SEL _cmd,NSRect initWithFrame,id segmentView)

{
  id pvVar1;
  id pvVar2;
  HSSegmentBodyView *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_NSView_0034e110;
  pvVar1 = _objc_msgSendSuper(&local_14,sel_initWithFrame_,initWithFrame.origin,initWithFrame.size);
  if (pvVar1 != (id)0x0) {
    *(id *)((int)pvVar1 + 0x50) = segmentView;
    pvVar2 = _objc_msgSend(cls_NSMutableArray,sel_new);
    *(id *)((int)pvVar1 + 0x54) = pvVar2;
  }
  return pvVar1;
}

*/
- (id)initWithFrame:(NSRect)aFrame segmentView:(id)aView
{
    self = [super initWithFrame:aFrame];
    if (self) {
        _segmentView = aView;
        _graphicObjects = [NSMutableArray new];
    }
    return self;
}

@end

