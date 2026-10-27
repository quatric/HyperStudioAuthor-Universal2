#import "HSSegmentAttributesView.h"
static id sDAT_003428bc;
static id sDAT_003428c0;

static id sDAT_003428bc;
static id sDAT_003428c0;


@implementation HSSegmentAttributesView

/* i386 ivar offsets: _segmentView=0x50, _graphicObjects=0x54, _knobs=0x58 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_000acc66 @ 000acc66, 554 bytes * /

void FUN_000acc66(HSSegmentAttributesView *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  id self_01;
  id pvVar2;
  id self_02;
  id pvVar3;
  int iVar4;
  double dVar5;
  undefined8 in_stack_ffffffcc;
  undefined4 uVar7;
  undefined8 uVar6;
  
  uVar7 = (undefined4)((ulonglong)in_stack_ffffffcc >> 0x20);
  _objc_msgSend(self->_knobs,sel_removeAllObjects);
  pvVar1 = _objc_msgSend(self->_segmentView,sel_dataSource);
  uVar6 = CONCAT44(uVar7,self->_segmentView);
  self_00 = _objc_msgSend(pvVar1,sel_attributesForHyperSegmentView_,self->_segmentView);
  pvVar1 = _objc_msgSend(self_00,sel_allKeys);
  self_01 = _objc_msgSend(pvVar1,sel_objectEnumerator);
  pvVar1 = _objc_msgSend(self_01,sel_nextObject);
  while (pvVar1 != (id)0x0) {
    uVar6 = CONCAT44((int)((ulonglong)uVar6 >> 0x20),pvVar1);
    pvVar2 = _objc_msgSend(self_00,sel_objectForKey_,pvVar1);
    pvVar2 = _objc_msgSend(pvVar2,sel_keyFrames);
    pvVar2 = _objc_msgSend(pvVar2,sel_objectEnumerator);
    self_02 = _objc_msgSend(pvVar2,sel_nextObject);
    if (self_02 != (id)0x0) {
      iVar4 = 0;
      do {
        pvVar3 = _objc_msgSend(cls_HSSegmentAttributesKnob,sel_alloc,uVar6);
        pvVar3 = _objc_msgSend(pvVar3,sel_initWithName_,pvVar1);
        pvVar3 = _objc_msgSend(pvVar3,sel_autorelease);
        _objc_msgSend(pvVar3,sel_setIndex_,iVar4);
        dVar5 = _objc_msgSend_fpret(self_02,sel_doubleValue);
        _objc_msgSend(pvVar3,sel_setKeyFrame_,dVar5);
        uVar6 = CONCAT44((int)((ulonglong)dVar5 >> 0x20),pvVar3);
        _objc_msgSend(self->_knobs,sel_addObject_);
        iVar4 = iVar4 + 1;
        self_02 = _objc_msgSend(pvVar2,sel_nextObject);
      } while (self_02 != (id)0x0);
    }
    pvVar1 = _objc_msgSend(self_01,sel_nextObject,uVar6);
  }
  _objc_msgSend(self->_knobs,sel_sortUsingSelector_,sel_compareTo_);
  return;
}

*/
- (void)rebuildKnobs
{
    [_knobs removeAllObjects];
    NSDictionary *attributes = [[_segmentView dataSource] attributesForHyperSegmentView:_segmentView];
    NSEnumerator *keys = [[attributes allKeys] objectEnumerator];
    id key;
    while ((key = [keys nextObject]) != nil) {
        NSEnumerator *keyFrames = [[[attributes objectForKey:key] keyFrames] objectEnumerator];
        id keyFrame;
        NSInteger index = 0;
        while ((keyFrame = [keyFrames nextObject]) != nil) {
            HSSegmentAttributesKnob *knob = [[[HSSegmentAttributesKnob alloc] initWithName:key] autorelease];
            [knob setIndex:index];
            [knob setKeyFrame:[keyFrame doubleValue]];
            [_knobs addObject:knob];
            index++;
        }
    }
    [_knobs sortUsingSelector:@selector(compareTo:)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ace90 @ 000ace90, 1131 bytes * /

int FUN_000ace90(HSSegmentAttributesView *self,SEL _cmd,int updateKnobAtIndex,double toKeyFrame)

{
  int iVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  int iVar6;
  double dVar7;
  double dVar8;
  double dVar9;
  undefined8 in_stack_ffffffac;
  undefined8 uVar10;
  
  uVar10 = CONCAT44((int)((ulonglong)in_stack_ffffffac >> 0x20),updateKnobAtIndex);
  pvVar2 = _objc_msgSend(self->_knobs,sel_objectAtIndex_,updateKnobAtIndex);
  pvVar2 = _objc_msgSend(pvVar2,sel_retain);
  dVar9 = _objc_msgSend_fpret(pvVar2,sel_keyFrame);
  if ((toKeyFrame != 0.0) || (NAN(toKeyFrame))) {
    dVar7 = ABS(toKeyFrame);
  }
  else {
    dVar7 = 1.0;
  }
  if ((dVar9 != 0.0) || (NAN(dVar9))) {
    dVar8 = ABS(dVar9);
  }
  else {
    dVar8 = 1.0;
  }
  if (dVar8 <= dVar7) {
    dVar8 = dVar7;
  }
  iVar1 = updateKnobAtIndex;
  if (dVar9 + dVar8 * -1e-05 <= toKeyFrame) {
    dVar9 = _objc_msgSend_fpret(pvVar2,sel_keyFrame);
    if ((toKeyFrame != 0.0) || (NAN(toKeyFrame))) {
      dVar7 = ABS(toKeyFrame);
    }
    else {
      dVar7 = 1.0;
    }
    if ((dVar9 != 0.0) || (NAN(dVar9))) {
      dVar8 = ABS(dVar9);
    }
    else {
      dVar8 = 1.0;
    }
    if (dVar8 <= dVar7) {
      dVar8 = dVar7;
    }
    dVar9 = dVar8 * 1e-05 + dVar9;
    iVar6 = updateKnobAtIndex;
    while ((dVar9 < toKeyFrame &&
           (pvVar3 = _objc_msgSend(self->_knobs,sel_count,uVar10), iVar6 = iVar1,
           iVar1 < (int)pvVar3 + -1))) {
      iVar1 = iVar1 + 1;
      uVar10 = CONCAT44((int)((ulonglong)uVar10 >> 0x20),iVar1);
      pvVar3 = _objc_msgSend(self->_knobs,sel_objectAtIndex_,iVar1);
      dVar9 = _objc_msgSend_fpret(pvVar3,sel_keyFrame);
      if ((toKeyFrame != 0.0) || (NAN(toKeyFrame))) {
        dVar7 = ABS(toKeyFrame);
      }
      else {
        dVar7 = 1.0;
      }
      if ((dVar9 != 0.0) || (NAN(dVar9))) {
        dVar8 = ABS(dVar9);
      }
      else {
        dVar8 = 1.0;
      }
      if (dVar8 <= dVar7) {
        dVar8 = dVar7;
      }
      dVar9 = dVar8 * 1e-05 + dVar9;
    }
  }
  else {
    do {
      iVar6 = iVar1;
      if (iVar6 < 1) break;
      iVar1 = iVar6 + -1;
      uVar10 = CONCAT44((int)((ulonglong)uVar10 >> 0x20),iVar1);
      pvVar3 = _objc_msgSend(self->_knobs,sel_objectAtIndex_,iVar1);
      dVar9 = _objc_msgSend_fpret(pvVar3,sel_keyFrame);
      if ((toKeyFrame != 0.0) || (NAN(toKeyFrame))) {
        dVar7 = ABS(toKeyFrame);
      }
      else {
        dVar7 = 1.0;
      }
      if ((dVar9 != 0.0) || (NAN(dVar9))) {
        dVar8 = ABS(dVar9);
      }
      else {
        dVar8 = 1.0;
      }
      if (dVar8 <= dVar7) {
        dVar8 = dVar7;
      }
    } while (toKeyFrame < dVar9 + dVar8 * -1e-05);
  }
  pvVar3 = _objc_msgSend(self,sel_attributes,uVar10);
  pvVar4 = _objc_msgSend(pvVar2,sel_name);
  pvVar4 = _objc_msgSend(pvVar3,sel_objectForKey_,pvVar4);
  pvVar3 = _objc_msgSend(pvVar2,sel_index);
  pvVar5 = _objc_msgSend(pvVar4,sel_values);
  pvVar5 = _objc_msgSend(pvVar5,sel_objectAtIndex_,pvVar3);
  pvVar5 = _objc_msgSend(pvVar5,sel_retain);
  _objc_msgSend(pvVar4,sel_deleteKeyFrameAtIndex_,pvVar3);
  pvVar3 = pvVar5;
  pvVar4 = _objc_msgSend(pvVar4,sel_insertKeyFrameAtTime_withValue_,toKeyFrame,pvVar5);
  _objc_msgSend(pvVar5,sel_release);
  _objc_msgSend(pvVar2,sel_setKeyFrame_,toKeyFrame);
  uVar10 = CONCAT44((int)((ulonglong)toKeyFrame >> 0x20),pvVar4);
  _objc_msgSend(pvVar2,sel_setIndex_,pvVar4);
  if (iVar6 != updateKnobAtIndex) {
    _objc_msgSend(self->_knobs,sel_removeObjectAtIndex_,updateKnobAtIndex,
                  (int)((ulonglong)uVar10 >> 0x20),pvVar3);
    uVar10 = CONCAT44(iVar6,pvVar2);
    _objc_msgSend(self->_knobs,sel_insertObject_atIndex_,pvVar2,iVar6);
  }
  _objc_msgSend(pvVar2,sel_release,uVar10);
  return iVar6;
}

*/
- (NSInteger)updateKnobAtIndex:(NSInteger)aIndex toKeyFrame:(double)aFrame
{
    HSSegmentAttributesKnob *knob = [[_knobs objectAtIndex:aIndex] retain];
    double current = [knob keyFrame];
    #define HSSegTol(a, b) ({ double _a = (a) != 0.0 ? fabs(a) : 1.0; double _b = (b) != 0.0 ? fabs(b) : 1.0; (_b <= _a ? _a : _b) * 1e-05; })
    NSInteger scan = aIndex;
    NSInteger target = aIndex;
    if (current + HSSegTol(aFrame, current) * -1.0 <= aFrame) {
        double c = [knob keyFrame];
        double limit = HSSegTol(aFrame, c) + c;
        target = aIndex;
        while (limit < aFrame && (target = scan, scan < (NSInteger)[_knobs count] - 1)) {
            scan++;
            double next = [[_knobs objectAtIndex:scan] keyFrame];
            limit = HSSegTol(aFrame, next) + next;
        }
    }
    else {
        double previous;
        do {
            target = scan;
            if (target < 1) {
                break;
            }
            scan = target - 1;
            previous = [[_knobs objectAtIndex:scan] keyFrame];
        } while (aFrame < previous + HSSegTol(aFrame, previous) * -1.0);
    }
    #undef HSSegTol
    id attribute = [[self attributes] objectForKey:[knob name]];
    NSInteger knobIndex = [knob index];
    id value = [[[attribute values] objectAtIndex:knobIndex] retain];
    [attribute deleteKeyFrameAtIndex:knobIndex];
    NSInteger newIndex = (NSInteger)[attribute insertKeyFrameAtTime:aFrame withValue:value];
    [value release];
    [knob setKeyFrame:aFrame];
    [knob setIndex:newIndex];
    if (target != aIndex) {
        [_knobs removeObjectAtIndex:aIndex];
        [_knobs insertObject:knob atIndex:target];
    }
    [knob release];
    return target;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ad2fb @ 000ad2fb, 397 bytes * /

int FUN_000ad2fb(HSSegmentAttributesView *self,SEL _cmd,NSPoint knobIndexAtPoint)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  float extraout_EDX;
  int iVar4;
  longdouble lVar5;
  double dVar6;
  undefined1 local_24 [4];
  float local_20;
  float local_18;
  
  pvVar2 = _objc_msgSend(self,sel_attributesKnobImage);
  pvVar2 = _objc_msgSend(pvVar2,sel_size);
  _objc_msgSend_stret(local_24,self,sel_bounds);
  lVar5 = (longdouble)_floorf(local_18 * 0.5 + local_20);
  iVar4 = 0;
  while( true ) {
    pvVar3 = _objc_msgSend(self->_knobs,sel_count);
    if ((int)pvVar3 <= iVar4) {
      return -1;
    }
    pvVar3 = _objc_msgSend(self->_knobs,sel_objectAtIndex_,iVar4);
    dVar6 = _objc_msgSend_fpret(pvVar3,sel_keyFrame);
    dVar6 = _objc_msgSend_fpret(self,sel_xForTime_,dVar6);
    cVar1 = _NSPointInRect(knobIndexAtPoint.x,knobIndexAtPoint.y,
                           CONCAT44((float)lVar5 + 0.5 + extraout_EDX * -0.5,
                                    (float)dVar6 + (float)pvVar2 * -0.5),
                           CONCAT44(extraout_EDX,pvVar2));
    if (cVar1 != '\0') break;
    iVar4 = iVar4 + 1;
  }
  return iVar4;
}

*/
- (NSInteger)knobIndexAtPoint:(NSPoint)aPoint
{
    NSSize size = [[self attributesKnobImage] size];
    NSRect bounds = [self bounds];
    float y = floorf(bounds.size.height * 0.5 + bounds.origin.y);
    for (NSInteger i = 0; i < (NSInteger)[_knobs count]; i++) {
        double keyFrame = [[_knobs objectAtIndex:i] keyFrame];
        float x = [self xForTime:keyFrame];
        NSRect rect = NSMakeRect(x + size.width * -0.5, (y + 0.5) + size.height * -0.5, size.width, size.height);
        if (NSPointInRect(aPoint, rect)) {
            return i;
        }
    }
    return -1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ad488 @ 000ad488, 216 bytes * /

void FUN_000ad488(HSSegmentAttributesView *self,SEL _cmd,id mouseDown)

{
  id pvVar1;
  id pvVar2;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  undefined4 uVar3;
  undefined4 uVar4;
  
  pvVar1 = _objc_msgSend(mouseDown,sel_locationInWindow);
  uVar4 = 0;
  pvVar1 = _objc_msgSend(self,sel_convertPoint_fromView_,pvVar1,extraout_EDX,0);
  uVar3 = extraout_EDX_00;
  pvVar2 = _objc_msgSend(self,sel_knobIndexAtPoint_,pvVar1,extraout_EDX_00);
  if (-1 < (int)pvVar2) {
    pvVar1 = _objc_msgSend(mouseDown,sel_window,pvVar1,uVar3,uVar4);
    while( true ) {
      pvVar2 = _objc_msgSend(pvVar1,sel_nextEventMatchingMask_,0x44,uVar3,uVar4);
      pvVar2 = _objc_msgSend(pvVar2,sel_type);
      if (pvVar2 == (id)0x2) break;
      if (pvVar2 == (id)0x6) {
        _objc_msgSend(self,sel_setNeedsDisplay_,1);
      }
    }
  }
  return;
}

*/
- (void)mouseDown:(id)aDown
{
    NSPoint point = [self convertPoint:[aDown locationInWindow] fromView:nil];
    if ([self knobIndexAtPoint:point] >= 0) {
        NSWindow *window = [aDown window];
        while (YES) {
            NSInteger type = [[window nextEventMatchingMask:0x44] type];
            if (type == 2) {
                break;
            }
            if (type == 6) {
                [self setNeedsDisplay:YES];
            }
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ad560 @ 000ad560, 441 bytes * /

void FUN_000ad560(HSSegmentAttributesView *self,SEL _cmd,NSRect drawKnobs)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  float extraout_EDX;
  longdouble lVar3;
  double dVar4;
  undefined1 local_24 [4];
  float local_20;
  float local_18;
  
  _objc_msgSend_stret(local_24,self,sel_bounds);
  pvVar1 = _objc_msgSend(self,sel_attributesKnobImage);
  _objc_msgSend(pvVar1,sel_size);
  pvVar1 = _objc_msgSend(self,sel_attributesKnobImage);
  pvVar1 = _objc_msgSend(pvVar1,sel_size);
  self_00 = _objc_msgSend(self->_knobs,sel_objectEnumerator);
  pvVar2 = _objc_msgSend(self_00,sel_nextObject);
  if (pvVar2 != (id)0x0) {
    lVar3 = (longdouble)_floorf(local_20 + local_18 * 0.5);
    do {
      dVar4 = _objc_msgSend_fpret(pvVar2,sel_keyFrame);
      dVar4 = _objc_msgSend_fpret(self,sel_xForTime_,dVar4);
      pvVar2 = _objc_msgSend(self,sel_attributesKnobImage);
      _objc_msgSend(pvVar2,sel_compositeToPoint_operation_,(float)dVar4 + (float)pvVar1 * -0.5,
                    (float)lVar3 + 0.5 + extraout_EDX * -0.5,2);
      pvVar2 = _objc_msgSend(self_00,sel_nextObject);
    } while (pvVar2 != (id)0x0);
  }
  return;
}

*/
- (void)drawKnobs:(NSRect)aKnobs
{
    NSRect bounds = [self bounds];
    NSSize size = [[self attributesKnobImage] size];
    NSEnumerator *enumerator = [_knobs objectEnumerator];
    id knob = [enumerator nextObject];
    if (knob != nil) {
        float y = floorf(bounds.origin.y + bounds.size.height * 0.5);
        do {
            float x = [self xForTime:[knob keyFrame]];
            [[self attributesKnobImage] compositeToPoint:NSMakePoint(x + size.width * -0.5, y + 0.5 + size.height * -0.5) operation:NSCompositeSourceOver];
            knob = [enumerator nextObject];
        } while (knob != nil);
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ad719 @ 000ad719, 649 bytes * /

void FUN_000ad719(HSSegmentAttributesView *self,SEL _cmd,NSRect drawMidLine)

{
  id pvVar1;
  id pvVar2;
  float extraout_EDX;
  longdouble lVar3;
  float fVar4;
  double dVar5;
  double dVar6;
  undefined1 local_24 [4];
  float local_20;
  float local_18;
  
  _objc_msgSend_stret(local_24,self,sel_bounds);
  lVar3 = (longdouble)_floorf(local_18 * 0.5 + local_20);
  dVar5 = _objc_msgSend_fpret(self,sel_xForTime_,0,0);
  dVar6 = _objc_msgSend_fpret(self,sel_duration);
  dVar6 = _objc_msgSend_fpret(self,sel_xForTime_,dVar6);
  pvVar1 = _objc_msgSend(cls_NSBezierPath,sel_bezierPath);
  fVar4 = (float)lVar3 + 0.5;
  _objc_msgSend(pvVar1,sel_moveToPoint_,(float)dVar5,fVar4);
  _objc_msgSend(pvVar1,sel_lineToPoint_,(float)dVar6,fVar4);
  pvVar2 = _objc_msgSend(cls_NSColor,sel_blueColor);
  _objc_msgSend(pvVar2,sel_set);
  _objc_msgSend(pvVar1,sel_stroke);
  pvVar1 = _objc_msgSend(self,sel_attributesEdgeKnobImage);
  _objc_msgSend(pvVar1,sel_size);
  pvVar1 = _objc_msgSend(self,sel_attributesEdgeKnobImage);
  pvVar1 = _objc_msgSend(pvVar1,sel_size);
  fVar4 = extraout_EDX * -0.5 + fVar4;
  pvVar2 = _objc_msgSend(self,sel_attributesEdgeKnobImage);
  _objc_msgSend(pvVar2,sel_compositeToPoint_operation_,(float)dVar5 + (float)pvVar1 * -0.5,fVar4,2);
  pvVar2 = _objc_msgSend(self,sel_attributesEdgeKnobImage);
  _objc_msgSend(pvVar2,sel_compositeToPoint_operation_,(float)pvVar1 * -0.5 + (float)dVar6,fVar4,2);
  return;
}

*/
- (void)drawMidLine:(NSRect)aLine
{
    NSRect bounds = [self bounds];
    float y = floorf(bounds.size.height * 0.5 + bounds.origin.y);
    float startX = [self xForTime:0.0];
    float endX = [self xForTime:[self duration]];
    NSBezierPath *path = [NSBezierPath bezierPath];
    float lineY = y + 0.5;
    [path moveToPoint:NSMakePoint(startX, lineY)];
    [path lineToPoint:NSMakePoint(endX, lineY)];
    [[NSColor blueColor] set];
    [path stroke];
    NSSize size = [[self attributesEdgeKnobImage] size];
    float edgeY = size.height * -0.5 + lineY;
    [[self attributesEdgeKnobImage] compositeToPoint:NSMakePoint(startX + size.width * -0.5, edgeY) operation:NSCompositeSourceOver];
    [[self attributesEdgeKnobImage] compositeToPoint:NSMakePoint(size.width * -0.5 + endX, edgeY) operation:NSCompositeSourceOver];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ad9a2 @ 000ad9a2, 463 bytes * /

void FUN_000ad9a2(HSSegmentAttributesView *self,SEL _cmd,NSRect drawBackground)

{
  int *piVar1;
  float fVar2;
  char cVar3;
  id pvVar4;
  id pvVar5;
  int *piVar6;
  longdouble lVar7;
  int local_64 [2];
  float local_34;
  undefined4 local_30;
  float local_2c;
  undefined8 local_24;
  undefined8 local_1c;
  
  piVar6 = (int *)&stack0xffffffa4;
  pvVar4 = _objc_msgSend(self->_graphicObjects,sel_objectEnumerator);
  pvVar5 = _objc_msgSend(pvVar4,sel_nextObject);
  piVar1 = (int *)&stack0xffffffa4;
  while (pvVar5 != (id)0x0) {
    piVar1[2] = (int)sel_bounds;
    piVar1[1] = (int)pvVar5;
    *piVar1 = (int)&local_24;
    piVar1[-1] = 0xada04;
    _objc_msgSend_stret((void *)*piVar1,(id)piVar1[1],(SEL)piVar1[2]);
    piVar6 = piVar1 + -1;
    *(NSSize *)(piVar1 + 5) = drawBackground.size;
    *(NSPoint *)(piVar1 + 3) = drawBackground.origin;
    *(undefined8 *)(piVar1 + 1) = local_1c;
    *(undefined8 *)(piVar1 + -1) = local_24;
    piVar1[-2] = 0xada36;
    cVar3 = _NSIntersectsRect();
    if (cVar3 != '\0') {
      *(NSSize *)(piVar1 + 3) = drawBackground.size;
      *(NSPoint *)(piVar1 + 1) = drawBackground.origin;
      *piVar1 = (int)sel_drawInRect_;
      piVar1[-1] = (int)pvVar5;
      piVar1[-2] = 0xada61;
      _objc_msgSend((id)piVar1[-1],(SEL)*piVar1);
    }
    *piVar1 = (int)sel_nextObject;
    piVar1[-1] = (int)pvVar4;
    piVar1[-2] = 0xada76;
    pvVar5 = _objc_msgSend((id)piVar1[-1],(SEL)*piVar1);
    piVar1 = piVar1 + -1;
  }
  piVar6[1] = (int)sel_bezierPath;
  *piVar6 = (int)cls_NSBezierPath;
  piVar6[-1] = 0xada98;
  pvVar5 = _objc_msgSend((id)*piVar6,(SEL)piVar6[1]);
  piVar6[2] = (int)sel_bounds;
  piVar6[1] = (int)self;
  *piVar6 = (int)&local_34;
  piVar6[-1] = 0xadab6;
  _objc_msgSend_stret((void *)*piVar6,(id)piVar6[1],(SEL)piVar6[2]);
  piVar6[-1] = local_30;
  piVar6[-2] = 0xadac8;
  lVar7 = (longdouble)_floorf();
  fVar2 = local_34;
  piVar6[2] = (int)((float)lVar7 + 0.5);
  piVar6[1] = (int)fVar2;
  *piVar6 = (int)sel_moveToPoint_;
  piVar6[-1] = (int)pvVar5;
  piVar6[-2] = 0xadb00;
  _objc_msgSend((id)piVar6[-1],(SEL)*piVar6);
  piVar6[2] = (int)((float)lVar7 + 0.5);
  piVar6[1] = (int)(local_34 + local_2c);
  *piVar6 = (int)sel_lineToPoint_;
  piVar6[-1] = (int)pvVar5;
  piVar6[-2] = 0xadb2d;
  _objc_msgSend((id)piVar6[-1],(SEL)*piVar6);
  *piVar6 = (int)sel_darkGrayColor;
  piVar6[-1] = (int)cls_NSColor;
  piVar6[-2] = 0xadb45;
  pvVar4 = _objc_msgSend((id)piVar6[-1],(SEL)*piVar6);
  *piVar6 = (int)sel_set;
  piVar6[-1] = (int)pvVar4;
  piVar6[-2] = 0xadb57;
  _objc_msgSend((id)piVar6[-1],(SEL)*piVar6);
  *piVar6 = (int)sel_stroke;
  piVar6[-1] = (int)pvVar5;
  piVar6[-2] = 0xadb69;
  _objc_msgSend((id)piVar6[-1],(SEL)*piVar6);
  return;
}

*/
- (void)drawBackground:(NSRect)aBackground
{
    NSEnumerator *enumerator = [_graphicObjects objectEnumerator];
    id object;
    while ((object = [enumerator nextObject]) != nil) {
        if (NSIntersectsRect([object bounds], aBackground)) {
            [object drawInRect:aBackground];
        }
    }
    NSBezierPath *path = [NSBezierPath bezierPath];
    NSRect bounds = [self bounds];
    float y = floorf(bounds.origin.y);
    [path moveToPoint:NSMakePoint(bounds.origin.x, y + 0.5)];
    [path lineToPoint:NSMakePoint(bounds.origin.x + bounds.size.width, y + 0.5)];
    [[NSColor darkGrayColor] set];
    [path stroke];
}

- (id)attributesKnobImage
{
    if (sDAT_003428c0 == nil) {
        sDAT_003428c0 = [[NSImage imageNamed:@"AttributesKnob"] retain];
    }
    return sDAT_003428c0;
}

- (id)attributesEdgeKnobImage
{
    if (sDAT_003428bc == nil) {
        sDAT_003428bc = [[NSImage imageNamed:@"AttributesEdgeKnob"] retain];
    }
    return sDAT_003428bc;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000adc1f @ 000adc1f, 238 bytes * /

void FUN_000adc1f(HSSegmentAttributesView *self,SEL _cmd,NSRect drawRect)

{
  _objc_msgSend(cls_NSGraphicsContext,sel_saveGraphicsState);
  _objc_msgSend(cls_NSBezierPath,sel_clipRect_,drawRect.origin,drawRect.size);
  _objc_msgSend(self,sel_drawBackground_,drawRect.origin,drawRect.size);
  _objc_msgSend(self,sel_drawMidLine_,drawRect.origin,drawRect.size);
  _objc_msgSend(self,sel_drawKnobs_,drawRect.origin,drawRect.size);
  _objc_msgSend(cls_NSGraphicsContext,sel_restoreGraphicsState);
  return;
}

*/
- (void)drawRect:(NSRect)aRect
{
    [NSGraphicsContext saveGraphicsState];
    [NSBezierPath clipRect:aRect];
    [self drawBackground:aRect];
    [self drawMidLine:aRect];
    [self drawKnobs:aRect];
    [NSGraphicsContext restoreGraphicsState];
}

- (double)duration
{
    return [_segmentView totalDuration];
}

- (double)timeForX:(CGFloat)aX
{
    return [_segmentView valueForX:aX];
}

- (CGFloat)xForTime:(double)aTime
{
    return (float)[_segmentView xForValue:aTime];
}

- (id)attributes
{
    return [[_segmentView dataSource] attributesForHyperSegmentView:_segmentView];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000adde4 @ 000adde4, 326 bytes * /

void FUN_000adde4(HSSegmentAttributesView *self,SEL _cmd)

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

- (void)refresh
{
    [_graphicObjects removeAllObjects];
    [self setupBackground];
    [self rebuildKnobs];
}

- (void)dealloc
{
    [_knobs release];
    [_graphicObjects release];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000acbd3 @ 000acbd3, 147 bytes * /

id FUN_000acbd3(HSSegmentAttributesView *self,SEL _cmd,NSRect initWithFrame,id segmentView)

{
  id pvVar1;
  id pvVar2;
  HSSegmentAttributesView *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_NSView_0034f4c0;
  pvVar1 = _objc_msgSendSuper(&local_14,sel_initWithFrame_,initWithFrame.origin,initWithFrame.size);
  if (pvVar1 != (id)0x0) {
    *(id *)((int)pvVar1 + 0x50) = segmentView;
    pvVar2 = _objc_msgSend(cls_NSMutableArray,sel_new);
    *(id *)((int)pvVar1 + 0x54) = pvVar2;
    pvVar2 = _objc_msgSend(cls_NSMutableArray,sel_new);
    *(id *)((int)pvVar1 + 0x58) = pvVar2;
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
        _knobs = [NSMutableArray new];
    }
    return self;
}

@end

@implementation HSSegmentAttributesKnob

/* i386 ivar offsets: _name=0x4, _index=0x8, _keyFrame=0xc */

- (NSInteger)compareTo:(id)aTo
{
    double dVar1;
    unsigned int uVar2;
    double dVar3;
    double dVar4;
    double dVar5;
    double dVar3_2;
    double dVar4_2;

    dVar5 = [aTo keyFrame];
    dVar1 = _keyFrame;
    dVar3 = dVar1 != 0.0 ? fabs(dVar1) : 1.0;
    dVar4 = dVar5 != 0.0 ? fabs(dVar5) : 1.0;
    if (dVar4 <= dVar3) {
        dVar4 = dVar3;
    }
    if (dVar1 < dVar4 * -1e-05 + dVar5) {
        uVar2 = 0xffffffff;
    }
    else {
        dVar3_2 = dVar1 != 0.0 ? fabs(dVar1) : 1.0;
        dVar4_2 = dVar5 != 0.0 ? fabs(dVar5) : 1.0;
        if (dVar4_2 <= dVar3_2) {
            dVar4_2 = dVar3_2;
        }
        uVar2 = (unsigned int)(dVar4_2 * 1e-05 + dVar5 < dVar1);
    }
    return uVar2;
}

- (void)setKeyFrame:(double)aFrame
{
    _keyFrame = aFrame;
}

- (double)keyFrame
{
    return _keyFrame;
}

- (void)setIndex:(NSInteger)aIndex
{
    _index = aIndex;
}

- (NSInteger)index
{
    return _index;
}

- (id)name
{
    return _name;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000aca6e @ 000aca6e, 110 bytes * /

id FUN_000aca6e(HSSegmentAttributesKnob *self,SEL _cmd,id initWithName)

{
  id pvVar1;
  id pvVar2;
  HSSegmentAttributesKnob *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_NSObject_0034f490;
  pvVar1 = _objc_msgSendSuper(&local_14,sel_init);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(initWithName,sel_retain);
    *(id *)((int)pvVar1 + 4) = pvVar2;
    *(undefined4 *)((int)pvVar1 + 8) = 0xffffffff;
    *(undefined4 *)((int)pvVar1 + 0x10) = 0;
    *(undefined4 *)((int)pvVar1 + 0xc) = 0;
  }
  return pvVar1;
}

*/
- (id)initWithName:(id)aName
{
    self = [super init];
    if (self != nil) {
        _name = [aName retain];
        _index = -1;
        _keyFrame = 0.0;
    }
    return self;
}

@end

