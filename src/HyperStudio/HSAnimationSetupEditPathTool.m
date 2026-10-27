#import "HSAnimationSetupEditPathTool.h"

@implementation HSAnimationSetupEditPathTool

/* i386 ivar offsets: _delegate=0x10, _editPathCanvasLayer=0x14, _editPathCanvasItem=0x18, _trackingCanvasLayer=0x1c, _dragCardCanvasLayer=0x20, _selection=0x24 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_000cba14 @ 000cba14, 476 bytes * /

void FUN_000cba14(HSAnimationSetupEditPathTool *self,SEL _cmd,id trackingRectCanvasLayer,
                 NSRect didFinishTrackingWithRect,id event)

{
  HSAnimationSetupEditPathCanvasLayer *self_00;
  char cVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  undefined4 extraout_EDX;
  undefined8 local_34 [2];
  undefined8 local_24 [2];
  
  pvVar2 = _objc_msgSend(event,sel_modifierFlags);
  pvVar3 = _objc_msgSend(trackingRectCanvasLayer,sel_renderingView);
  _objc_msgSend_stret(local_24,pvVar3,sel_userBoundingRectForViewRect_,
                      didFinishTrackingWithRect.origin.x,didFinishTrackingWithRect.origin.y,
                      didFinishTrackingWithRect.size);
  _NSIntegralRect(local_34,local_24[0],(int)local_24[1],(int)((ulonglong)local_24[1] >> 0x20));
  if (((uint)pvVar2 & 0x100000) == 0) {
    _objc_msgSend(self,sel_resetSelection);
  }
  pvVar2 = _objc_msgSend(self->_selection,sel_count);
  if (pvVar2 != (id)0x0) {
    pvVar2 = (id)0x0;
    do {
      self_00 = self->_editPathCanvasLayer;
      pvVar3 = _objc_msgSend(self,sel_animation);
      pvVar3 = _objc_msgSend(pvVar3,sel_path);
      pvVar3 = _objc_msgSend(self_00,sel_pointAtIndex_forPath_,pvVar2,pvVar3);
      cVar1 = _NSPointInRect(pvVar3,extraout_EDX,local_34[0],(int)local_34[1],
                             (int)((ulonglong)local_34[1] >> 0x20));
      if (cVar1 != '\0') {
        pvVar3 = self->_selection;
        pvVar4 = _objc_msgSend(cls_NSNumber,sel_numberWithBool_,1);
        _objc_msgSend(pvVar3,sel_replaceObjectAtIndex_withObject_,pvVar2,pvVar4);
      }
      pvVar2 = (id)((int)pvVar2 + 1);
      pvVar3 = _objc_msgSend(self->_selection,sel_count);
    } while (pvVar2 < pvVar3);
  }
  pvVar2 = _objc_msgSend(trackingRectCanvasLayer,sel_parentLayer);
  pvVar2 = _objc_msgSend(pvVar2,sel_rootLayer);
  _objc_msgSend(pvVar2,sel_invalidateDisplay);
  return;
}

*/
- (void)trackingRectCanvasLayer:(id)aLayer didFinishTrackingWithRect:(NSRect)aRect event:(id)aEvent
{
    NSUInteger modifierFlags = [(NSEvent *)aEvent modifierFlags];
    NSRect rect = NSIntegralRect([[aLayer renderingView] userBoundingRectForViewRect:aRect]);
    if ((modifierFlags & NSEventModifierFlagCommand) == 0) {
        [self resetSelection];
    }
    if ([_selection count] != 0) {
        NSUInteger index = 0;
        do {
            NSPoint point = [_editPathCanvasLayer pointAtIndex:index forPath:[[self animation] path]];
            if (NSPointInRect(point, rect)) {
                [_selection replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:YES]];
            }
            index++;
        } while (index < [_selection count]);
    }
    [[[aLayer parentLayer] rootLayer] invalidateDisplay];
}

- (id)layerForEditPathCanvasItem:(id)aItem
{
    return _editPathCanvasLayer;
}

- (BOOL)editPathCanvasItem:(id)aItem isSelectedKnob:(NSUInteger)aKnob
{
    return (BOOL)[[_selection objectAtIndex:aKnob] boolValue];
}

- (NSInteger)lastKnobIndexForEditPathCanvasItem:(id)aItem
{
    int iVar2;

    if ([[self animation] playbackDirection] == 0) {
        iVar2 = (int)[[[self animation] pathKeyFrames] count] + -1;
    }
    else {
        iVar2 = 0;
    }
    return iVar2;
}

- (NSInteger)firstKnobIndexForEditPathCanvasItem:(id)aItem
{
    int iVar2;

    if ([[self animation] playbackDirection] == 0) {
        iVar2 = 0;
    }
    else {
        iVar2 = (int)[[[self animation] pathKeyFrames] count] + -1;
    }
    return iVar2;
}

- (NSUInteger)knobCountForEditPathCanvasItem:(id)aItem
{
    return (unsigned int)[[[self animation] pathKeyFrames] count];
}

- (id)pathForEditPathCanvasItem:(id)aItem
{
    return [[self animation] path];
}

- (id)canvasItemForEditPathCanvasLayer:(id)aLayer
{
    return _editPathCanvasItem;
}

- (void)didEndEditingFromEditPathCanvasLayer:(id)aLayer
{
    [_delegate editingDidEndForEditPathTool:self];
}

- (void)willBeginEditingFromEditPathCanvasLayer:(id)aLayer
{
    [_delegate editingWillBeginForEditPathTool:self];
}

- (void)editPathCanvasLayer:(id)aLayer firstPathPointWillChangeTo:(NSPoint)aTo
{
    id pvVar1_2;

    pvVar1_2 = [[HSAnimationFixation new] autorelease];
    [pvVar1_2 setObjectPositionAtZeroTime:aTo];
    [[[self animation] positioning] replaceFixationWith:pvVar1_2];
    [[[self tryItAnimation] positioning] replaceFixationWith:pvVar1_2];
}

- (void)updateTryItAnimatedObjectFromEditPathCanvasLayer:(id)aLayer
{
    [[self tryItAnimation] updateObject];
    [self updateAnimationPath];
}

- (void)updateAnimationPath
{
    [_delegate updateAnimationPathBounds:[_editPathCanvasItem contentPathBounds] forEditPathTool:self];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000cbff2 @ 000cbff2, 74 bytes * /

void FUN_000cbff2(HSAnimationSetupEditPathTool *self,SEL _cmd)

{
  _objc_msgSend(self->_delegate,sel_updateAnimationPathBounds_forEditPathTool_,
                *(undefined8 *)PTR_00336078,*(undefined8 *)(PTR_00336078 + 8),self);
  return;
}

*/
- (void)cleanupAnimationPath
{
    [_delegate updateAnimationPathBounds:NSZeroRect forEditPathTool:self];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000cc03c @ 000cc03c, 1266 bytes * /

void FUN_000cc03c(HSAnimationSetupEditPathTool *self,SEL _cmd,id editPathCanvasLayer,
                 int addPointAfterPoint,float relativeDistance)

{
  float fVar1;
  float fVar2;
  undefined4 uVar3;
  undefined *puVar4;
  float fVar5;
  float fVar6;
  id pvVar7;
  id pvVar8;
  id pvVar9;
  id pvVar10;
  id pvVar11;
  id pvVar12;
  id self_00;
  double dVar13;
  double dVar14;
  double dVar15;
  double dVar16;
  undefined8 in_stack_ffffff6c;
  undefined4 uVar19;
  undefined8 uVar17;
  longlong lVar18;
  undefined4 local_3c;
  undefined4 local_38;
  undefined4 local_34;
  undefined4 local_30;
  undefined4 local_2c;
  undefined4 local_28;
  float local_24;
  float local_20;
  float local_1c;
  float local_18;
  
  uVar19 = (undefined4)((ulonglong)in_stack_ffffff6c >> 0x20);
  _objc_msgSend(self,sel_willBeginEditingFromEditPathCanvasLayer_,editPathCanvasLayer);
  pvVar7 = _objc_msgSend(self,sel_animation);
  pvVar8 = _objc_msgSend(pvVar7,sel_pathKeyFrames);
  pvVar9 = _objc_msgSend(pvVar8,sel_objectAtIndex_,addPointAfterPoint);
  dVar15 = _objc_msgSend_fpret(pvVar9,sel_doubleValue);
  pvVar9 = (id)(addPointAfterPoint + 1);
  uVar17 = CONCAT44(uVar19,pvVar9);
  pvVar10 = _objc_msgSend(pvVar8,sel_objectAtIndex_,pvVar9);
  dVar16 = _objc_msgSend_fpret(pvVar10,sel_doubleValue);
  dVar13 = dVar16 - dVar15;
  dVar14 = (double)relativeDistance * dVar13 + dVar15;
  if (dVar14 <= dVar15) {
    dVar14 = dVar15 + dVar13 * 0.009999999776482582;
  }
  if (dVar16 <= dVar14) {
    dVar14 = dVar16 + dVar13 * -0.009999999776482582;
  }
  pvVar10 = _objc_msgSend(pvVar8,sel_count,uVar17);
  pvVar11 = _objc_msgSend(pvVar8,sel_subarrayWithRange_,0,pvVar9);
  pvVar8 = _objc_msgSend(pvVar8,sel_subarrayWithRange_,pvVar9,
                         (int)pvVar10 + (-1 - addPointAfterPoint));
  pvVar11 = _objc_msgSend(cls_NSMutableArray,sel_arrayWithArray_,pvVar11);
  pvVar12 = _objc_msgSend(cls_NSNumber,sel_numberWithDouble_,dVar14);
  _objc_msgSend(pvVar11,sel_addObject_,pvVar12);
  _objc_msgSend(pvVar11,sel_addObjectsFromArray_,pvVar8);
  puVar4 = PTR_00336074;
  fVar1 = *(float *)PTR_00336074;
  fVar2 = *(float *)(PTR_00336074 + 4);
  pvVar8 = _objc_msgSend(pvVar7,sel_path);
  local_1c = fVar1;
  local_18 = fVar2;
  _objc_msgSend(pvVar8,sel_elementAtIndex_associatedPoints_,addPointAfterPoint,&local_1c);
  local_24 = fVar1;
  local_20 = fVar2;
  _objc_msgSend(pvVar8,sel_elementAtIndex_associatedPoints_,pvVar9,&local_24);
  fVar6 = local_18;
  fVar5 = local_1c;
  fVar2 = local_20;
  fVar1 = local_24;
  lVar18 = ZEXT48(pvVar9) << 0x20;
  pvVar12 = _objc_msgSend(pvVar8,sel_hyperSubpathForElementRange_,0,pvVar9);
  self_00 = _objc_msgSend(cls_NSBezierPath,sel_bezierPath,lVar18,pvVar12);
  _objc_msgSend(self_00,sel_appendBezierPath_,pvVar12);
  _objc_msgSend(self_00,sel_lineToPoint_,(fVar1 - fVar5) * relativeDistance + fVar5,
                (fVar2 - fVar6) * relativeDistance + fVar6);
  if (pvVar9 < (id)((int)pvVar10 + (-1 - addPointAfterPoint) + (int)pvVar9)) {
    uVar19 = *(undefined4 *)puVar4;
    uVar3 = *(undefined4 *)(puVar4 + 4);
    pvVar12 = pvVar9;
    do {
      local_3c = uVar19;
      local_38 = uVar3;
      local_34 = uVar19;
      local_30 = uVar3;
      local_2c = uVar19;
      local_28 = uVar3;
      _objc_msgSend(pvVar8,sel_hyperElementAtIndex_associatedPoints_,pvVar12,&local_3c);
      _objc_msgSend(self_00,sel_hyperAppendElement_associatedPoints_);
      pvVar12 = (id)((int)pvVar12 + 1);
    } while (pvVar10 != pvVar12);
  }
  _objc_msgSend(pvVar7,sel_setPath_keyFrames_,self_00,pvVar11);
  pvVar7 = _objc_msgSend(self,sel_tryItAnimation);
  _objc_msgSend(pvVar7,sel_setPath_keyFrames_,self_00,pvVar11);
  _objc_msgSend(self,sel_resetSelection);
  pvVar7 = self->_selection;
  pvVar8 = _objc_msgSend(cls_NSNumber,sel_numberWithBool_,1);
  _objc_msgSend(pvVar7,sel_insertObject_atIndex_,pvVar8,pvVar9);
  _objc_msgSend(self,sel_didEndEditingFromEditPathCanvasLayer_,editPathCanvasLayer);
  return;
}

*/
- (void)editPathCanvasLayer:(id)aLayer addPointAfterPoint:(NSInteger)aPoint relativeDistance:(CGFloat)aDistance
{
    [self willBeginEditingFromEditPathCanvasLayer:aLayer];
    id animation = [self animation];
    NSArray *keyFrames = [animation pathKeyFrames];
    double previousTime = [[keyFrames objectAtIndex:aPoint] doubleValue];
    NSUInteger next = aPoint + 1;
    double nextTime = [[keyFrames objectAtIndex:next] doubleValue];
    double span = nextTime - previousTime;
    double time = (double)aDistance * span + previousTime;
    if (time <= previousTime) {
        time = previousTime + span * 0.009999999776482582;
    }
    if (nextTime <= time) {
        time = nextTime + span * -0.009999999776482582;
    }
    NSUInteger count = [keyFrames count];
    NSArray *head = [keyFrames subarrayWithRange:NSMakeRange(0, next)];
    NSArray *tail = [keyFrames subarrayWithRange:NSMakeRange(next, count + (-1 - aPoint))];
    NSMutableArray *newKeyFrames = [NSMutableArray arrayWithArray:head];
    [newKeyFrames addObject:[NSNumber numberWithDouble:time]];
    [newKeyFrames addObjectsFromArray:tail];
    id path = [animation path];
    NSPoint previousPoints[3] = { NSZeroPoint, NSZeroPoint, NSZeroPoint };
    NSPoint nextPoints[3] = { NSZeroPoint, NSZeroPoint, NSZeroPoint };
    [path elementAtIndex:aPoint associatedPoints:previousPoints];
    [path elementAtIndex:next associatedPoints:nextPoints];
    id prefix = [path hyperSubpathForElementRange:NSMakeRange(0, next)];
    NSBezierPath *newPath = [NSBezierPath bezierPath];
    [newPath appendBezierPath:prefix];
    [newPath lineToPoint:NSMakePoint((nextPoints[0].x - previousPoints[0].x) * aDistance + previousPoints[0].x, (nextPoints[0].y - previousPoints[0].y) * aDistance + previousPoints[0].y)];
    if ((NSInteger)count + (-1 - aPoint) > 0) {
        NSUInteger index = next;
        do {
            NSPoint points[3] = { NSZeroPoint, NSZeroPoint, NSZeroPoint };
            NSInteger element = [path hyperElementAtIndex:index associatedPoints:points];
            [newPath hyperAppendElement:element associatedPoints:points];
            index++;
        } while (count != index);
    }
    [animation setPath:newPath keyFrames:newKeyFrames];
    [[self tryItAnimation] setPath:newPath keyFrames:newKeyFrames];
    [self resetSelection];
    [_selection insertObject:[NSNumber numberWithBool:YES] atIndex:next];
    [self didEndEditingFromEditPathCanvasLayer:aLayer];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000cc52e @ 000cc52e, 2653 bytes * /

void FUN_000cc52e(HSAnimationSetupEditPathTool *self,SEL _cmd,
                 id removeSelectedKnobsForEditPathCanvasLayer)

{
  int iVar1;
  bool bVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  undefined4 extraout_EDX;
  int iVar7;
  id pvVar8;
  double dVar9;
  double dVar10;
  double dVar11;
  double dVar12;
  undefined8 in_stack_ffffff2c;
  longlong lVar13;
  uint uVar14;
  undefined4 uVar15;
  id local_94;
  undefined1 local_84 [104];
  undefined4 local_1c;
  undefined4 local_18;
  
  lVar13 = CONCAT44((int)((ulonglong)in_stack_ffffff2c >> 0x20),
                    removeSelectedKnobsForEditPathCanvasLayer);
  _objc_msgSend(self,sel_willBeginEditingFromEditPathCanvasLayer_,
                removeSelectedKnobsForEditPathCanvasLayer);
  pvVar3 = _objc_msgSend(self->_selection,sel_count);
  if (pvVar3 != (id)0x0) {
    pvVar3 = (id)0x0;
    pvVar8 = (id)0x0;
    do {
      lVar13 = CONCAT44((int)((ulonglong)lVar13 >> 0x20),pvVar3);
      pvVar4 = _objc_msgSend(self->_selection,sel_objectAtIndex_,pvVar3);
      pvVar4 = _objc_msgSend(pvVar4,sel_boolValue);
      pvVar8 = (id)((int)pvVar8 + (uint)((char)pvVar4 != '\0'));
      pvVar3 = (id)((int)pvVar3 + 1);
      pvVar4 = _objc_msgSend(self->_selection,sel_count);
    } while (pvVar3 < pvVar4);
    if (pvVar8 != (id)0x0) {
      pvVar3 = _objc_msgSend(self->_selection,sel_count,lVar13);
      if (pvVar3 == pvVar8) {
        pvVar3 = self->_selection;
        pvVar8 = _objc_msgSend(cls_NSNumber,sel_numberWithBool_,0);
        lVar13 = ZEXT48(pvVar8) << 0x20;
        _objc_msgSend(pvVar3,sel_replaceObjectAtIndex_withObject_,0,pvVar8);
      }
      pvVar3 = _objc_msgSend(cls_NSMutableArray,sel_new,lVar13);
      pvVar8 = _objc_msgSend(self->_selection,sel_count);
      if (pvVar8 != (id)0x0) {
        local_84._0_10_ = (unkuint10)(ushort)local_84._8_2_ << 0x40;
        pvVar8 = (id)0x7fffffff;
        local_94 = (id)0x0;
        do {
          lVar13 = CONCAT44((int)((ulonglong)lVar13 >> 0x20),local_94);
          pvVar5 = _objc_msgSend(self->_selection,sel_objectAtIndex_,local_94);
          pvVar4 = (id)((int)local_94 + 1);
          pvVar5 = _objc_msgSend(pvVar5,sel_boolValue);
          if ((char)pvVar5 == '\0') {
            if (pvVar8 != (id)0x7fffffff) {
              pvVar5 = _objc_msgSend(self,sel_animation,lVar13);
              uVar15 = (undefined4)((ulonglong)lVar13 >> 0x20);
              pvVar5 = _objc_msgSend(pvVar5,sel_pathKeyFrames);
              if (pvVar8 == (id)0x0) {
                lVar13 = CONCAT44(uVar15,local_94);
                pvVar8 = _objc_msgSend(pvVar5,sel_objectAtIndex_,local_94);
                local_84._0_8_ = _objc_msgSend_fpret(pvVar8,sel_doubleValue);
                pvVar8 = (id)0x7fffffff;
              }
              else {
                pvVar5 = _objc_msgSend(pvVar5,sel_objectAtIndex_,(int)pvVar8 - 1);
                dVar12 = _objc_msgSend_fpret(pvVar5,sel_doubleValue);
                pvVar5 = _objc_msgSend(self,sel_animation);
                pvVar5 = _objc_msgSend(pvVar5,sel_pathKeyFrames);
                pvVar8 = _objc_msgSend(pvVar5,sel_objectAtIndex_,pvVar8);
                dVar10 = _objc_msgSend_fpret(pvVar8,sel_doubleValue);
                pvVar8 = _objc_msgSend(self,sel_animation);
                pvVar8 = _objc_msgSend(pvVar8,sel_pathKeyFrames);
                pvVar8 = _objc_msgSend(pvVar8,sel_objectAtIndex_,(int)local_94 - 1);
                dVar11 = _objc_msgSend_fpret(pvVar8,sel_doubleValue);
                pvVar8 = _objc_msgSend(self,sel_animation);
                pvVar8 = _objc_msgSend(pvVar8,sel_pathKeyFrames);
                lVar13 = CONCAT44(uVar15,local_94);
                pvVar8 = _objc_msgSend(pvVar8,sel_objectAtIndex_,local_94);
                dVar9 = _objc_msgSend_fpret(pvVar8,sel_doubleValue);
                local_84._0_8_ =
                     (double)local_84._0_8_ +
                     ((dVar9 - dVar11) + (dVar10 - dVar12)) * -0.5 + (dVar9 - dVar12);
                pvVar8 = (id)0x7fffffff;
              }
            }
            pvVar5 = _objc_msgSend(self,sel_animation,lVar13);
            pvVar5 = _objc_msgSend(pvVar5,sel_pathKeyFrames);
            pvVar5 = _objc_msgSend(pvVar5,sel_objectAtIndex_,local_94);
            dVar12 = _objc_msgSend_fpret(pvVar5,sel_doubleValue);
            dVar12 = dVar12 - (double)local_84._0_8_;
            pvVar5 = _objc_msgSend(cls_NSNumber,sel_numberWithDouble_,dVar12);
            lVar13 = CONCAT44((int)((ulonglong)dVar12 >> 0x20),pvVar5);
            _objc_msgSend(pvVar3,sel_addObject_,pvVar5);
          }
          else if (pvVar8 == (id)0x7fffffff) {
            pvVar8 = local_94;
          }
          pvVar5 = _objc_msgSend(self->_selection,sel_count,lVar13);
          local_94 = pvVar4;
        } while (pvVar4 < pvVar5);
      }
      pvVar8 = _objc_msgSend(cls_NSNumber,sel_numberWithDouble_,0,0);
      lVar13 = ZEXT48(pvVar8) << 0x20;
      _objc_msgSend(pvVar3,sel_replaceObjectAtIndex_withObject_,0,pvVar8);
      pvVar8 = _objc_msgSend(pvVar3,sel_count);
      uVar14 = (uint)((ulonglong)lVar13 >> 0x20);
      if ((id)0x1 < pvVar8) {
        dVar12 = *(double *)PTR_003361e4;
        iVar7 = 0;
        do {
          iVar1 = iVar7 + 1;
          uVar15 = (undefined4)((ulonglong)lVar13 >> 0x20);
          pvVar8 = _objc_msgSend(pvVar3,sel_objectAtIndex_,iVar1);
          dVar10 = _objc_msgSend_fpret(pvVar8,sel_doubleValue);
          lVar13 = CONCAT44(uVar15,iVar7);
          pvVar8 = _objc_msgSend(pvVar3,sel_objectAtIndex_,iVar7);
          dVar11 = _objc_msgSend_fpret(pvVar8,sel_doubleValue);
          if (dVar10 < dVar11 + dVar12) {
            pvVar8 = _objc_msgSend(cls_NSNumber,sel_numberWithDouble_,dVar11 + dVar12);
            lVar13 = CONCAT44(pvVar8,iVar1);
            _objc_msgSend(pvVar3,sel_replaceObjectAtIndex_withObject_,iVar1,pvVar8);
          }
          pvVar8 = (id)(iVar7 + 2);
          pvVar4 = _objc_msgSend(pvVar3,sel_count,lVar13);
          uVar14 = (uint)((ulonglong)lVar13 >> 0x20);
          iVar7 = iVar1;
        } while (pvVar8 < pvVar4);
      }
      lVar13 = (ulonglong)uVar14 << 0x20;
      pvVar8 = _objc_msgSend(cls_NSBezierPath,sel_hyperBezierPathWithString_,&cfstr_M_0_0);
      pvVar8 = _objc_msgSend(pvVar8,sel_retain);
      pvVar4 = _objc_msgSend(self->_selection,sel_count);
      if (pvVar4 != (id)0x0) {
        bVar2 = false;
        pvVar4 = (id)0x0;
        do {
          lVar13 = CONCAT44((int)((ulonglong)lVar13 >> 0x20),pvVar4);
          pvVar6 = _objc_msgSend(self->_selection,sel_objectAtIndex_,pvVar4);
          pvVar5 = (id)((int)pvVar4 + 1);
          pvVar6 = _objc_msgSend(pvVar6,sel_boolValue);
          if ((char)pvVar6 == '\0') {
            pvVar4 = _objc_msgSend(self,sel_pointAtIndex_,pvVar4);
            if (bVar2) {
              lVar13 = CONCAT44(extraout_EDX,pvVar4);
              _objc_msgSend(pvVar8,sel_lineToPoint_,pvVar4,extraout_EDX);
            }
            else {
              lVar13 = CONCAT44(extraout_EDX,pvVar4);
              _objc_msgSend(pvVar8,sel_moveToPoint_,pvVar4,extraout_EDX);
              bVar2 = true;
            }
          }
          pvVar6 = _objc_msgSend(self->_selection,sel_count,lVar13);
          pvVar4 = pvVar5;
        } while (pvVar5 < pvVar6);
      }
      pvVar4 = _objc_msgSend(self,sel_animation);
      _objc_msgSend(pvVar4,sel_setPath_keyFrames_,pvVar8,pvVar3);
      pvVar4 = _objc_msgSend(self,sel_tryItAnimation);
      _objc_msgSend(pvVar4,sel_setPath_keyFrames_,pvVar8,pvVar3);
      _objc_msgSend(pvVar8,sel_elementAtIndex_associatedPoints_,0,&local_1c);
      pvVar4 = _objc_msgSend(cls_HSAnimationFixation,sel_new);
      pvVar4 = _objc_msgSend(pvVar4,sel_autorelease);
      _objc_msgSend(pvVar4,sel_setObjectPositionAtZeroTime_,local_1c,local_18);
      pvVar5 = _objc_msgSend(self,sel_animation);
      pvVar5 = _objc_msgSend(pvVar5,sel_positioning);
      _objc_msgSend(pvVar5,sel_replaceFixationWith_,pvVar4);
      pvVar5 = _objc_msgSend(self,sel_tryItAnimation);
      pvVar5 = _objc_msgSend(pvVar5,sel_positioning);
      _objc_msgSend(pvVar5,sel_replaceFixationWith_,pvVar4);
      pvVar4 = _objc_msgSend(self,sel_tryItAnimation);
      dVar10 = _objc_msgSend_fpret(pvVar4,sel_pathTime);
      pvVar4 = _objc_msgSend(self,sel_tryItAnimation);
      dVar11 = _objc_msgSend_fpret(pvVar4,sel_duration);
      dVar12 = 0.0;
      if (0.0 <= dVar10) {
        dVar12 = dVar10;
      }
      if (dVar11 < dVar12) {
        pvVar4 = _objc_msgSend(self,sel_tryItAnimation);
        dVar12 = _objc_msgSend_fpret(pvVar4,sel_duration);
      }
      pvVar4 = _objc_msgSend(self,sel_tryItAnimation);
      _objc_msgSend(pvVar4,sel_setPathTime_,dVar12);
      _objc_msgSend(self,sel_resetSelection);
      _objc_msgSend(self,sel_updateAnimationPath);
      pvVar4 = _objc_msgSend(removeSelectedKnobsForEditPathCanvasLayer,sel_renderingView);
      _objc_msgSend(pvVar4,sel_setNeedsDisplayOpenGLSurface_,1);
      _objc_msgSend(pvVar8,sel_release);
      _objc_msgSend(pvVar3,sel_release);
      _objc_msgSend(self,sel_didEndEditingFromEditPathCanvasLayer_,
                    removeSelectedKnobsForEditPathCanvasLayer);
    }
  }
  return;
}

*/
- (void)removeSelectedKnobsForEditPathCanvasLayer:(id)aLayer
{
    [self willBeginEditingFromEditPathCanvasLayer:aLayer];
    if ([_selection count] == 0) {
        return;
    }
    NSUInteger selected = 0;
    NSUInteger index = 0;
    do {
        if ([[_selection objectAtIndex:index] boolValue]) {
            selected++;
        }
        index++;
    } while (index < [_selection count]);
    if (selected == 0) {
        return;
    }
    if ([_selection count] == selected) {
        [_selection replaceObjectAtIndex:0 withObject:[NSNumber numberWithBool:NO]];
    }
    NSMutableArray *newKeyFrames = [NSMutableArray new];
    if ([_selection count] != 0) {
        double offset = 0.0;
        NSUInteger firstRemoved = NSNotFound;
        for (index = 0; index < [_selection count]; index++) {
            if (![[_selection objectAtIndex:index] boolValue]) {
                if (firstRemoved != NSNotFound) {
                    NSArray *times = [[self animation] pathKeyFrames];
                    if (firstRemoved == 0) {
                        offset = [[times objectAtIndex:index] doubleValue];
                    } else {
                        double previousStart = [[times objectAtIndex:firstRemoved - 1] doubleValue];
                        double firstTime = [[[[self animation] pathKeyFrames] objectAtIndex:firstRemoved] doubleValue];
                        double previousTime = [[[[self animation] pathKeyFrames] objectAtIndex:index - 1] doubleValue];
                        double currentTime = [[[[self animation] pathKeyFrames] objectAtIndex:index] doubleValue];
                        offset = offset + ((currentTime - previousTime) + (firstTime - previousStart)) * -0.5 + (currentTime - previousStart);
                    }
                    firstRemoved = NSNotFound;
                }
                double time = [[[[self animation] pathKeyFrames] objectAtIndex:index] doubleValue] - offset;
                [newKeyFrames addObject:[NSNumber numberWithDouble:time]];
            } else if (firstRemoved == NSNotFound) {
                firstRemoved = index;
            }
        }
    }
    [newKeyFrames replaceObjectAtIndex:0 withObject:[NSNumber numberWithDouble:0.0]];
    if ([newKeyFrames count] > 1) {
        double minimumInterval = kAnimationMinTimeIntervalBetweenKeyFrames;
        NSUInteger frame = 0;
        do {
            double nextTime = [[newKeyFrames objectAtIndex:frame + 1] doubleValue];
            double currentTime = [[newKeyFrames objectAtIndex:frame] doubleValue];
            if (nextTime < currentTime + minimumInterval) {
                [newKeyFrames replaceObjectAtIndex:frame + 1 withObject:[NSNumber numberWithDouble:currentTime + minimumInterval]];
            }
            frame++;
        } while (frame + 1 < [newKeyFrames count]);
    }
    NSBezierPath *newPath = [[NSBezierPath hyperBezierPathWithString:@"M 0 0"] retain];
    if ([_selection count] != 0) {
        BOOL started = NO;
        for (index = 0; index < [_selection count]; index++) {
            if (![[_selection objectAtIndex:index] boolValue]) {
                NSPoint point = [self pointAtIndex:index];
                if (started) {
                    [newPath lineToPoint:point];
                } else {
                    [newPath moveToPoint:point];
                    started = YES;
                }
            }
        }
    }
    [[self animation] setPath:newPath keyFrames:newKeyFrames];
    [[self tryItAnimation] setPath:newPath keyFrames:newKeyFrames];
    NSPoint startPoints[3] = { NSZeroPoint, NSZeroPoint, NSZeroPoint };
    [newPath elementAtIndex:0 associatedPoints:startPoints];
    HSAnimationFixation *fixation = [[HSAnimationFixation new] autorelease];
    [fixation setObjectPositionAtZeroTime:startPoints[0]];
    [[[self animation] positioning] replaceFixationWith:fixation];
    [[[self tryItAnimation] positioning] replaceFixationWith:fixation];
    HSAnimation *tryIt = (HSAnimation *)[self tryItAnimation];
    double pathTime = [tryIt pathTime];
    double duration = [tryIt duration];
    double clamped = 0.0;
    if (0.0 <= pathTime) {
        clamped = pathTime;
    }
    if (duration < clamped) {
        clamped = [tryIt duration];
    }
    [[self tryItAnimation] setPathTime:clamped];
    [self resetSelection];
    [self updateAnimationPath];
    [[aLayer renderingView] setNeedsDisplayOpenGLSurface:YES];
    [newPath release];
    [newKeyFrames release];
    [self didEndEditingFromEditPathCanvasLayer:aLayer];
}

- (id)transformedPathForEditPathCanvasLayer:(id)aLayer
{
    return [[self editPathCanvasItem] pathForLayer:aLayer];
}

- (id)tryItPathForEditPathCanvasLayer:(id)aLayer
{
    return [[self tryItAnimation] path];
}

- (id)pathForEditPathCanvasLayer:(id)aLayer
{
    return [[self animation] path];
}

- (void)deselectAllKnobsForEditPathCanvasLayer:(id)aLayer
{
    [self resetSelection];
    [[aLayer renderingView] setNeedsDisplayOpenGLSurface:YES];
}

- (void)editPathCanvasLayer:(id)aLayer setSelected:(BOOL)aSelected knob:(NSUInteger)aKnob
{
    [_selection replaceObjectAtIndex:aKnob withObject:[NSNumber numberWithBool:(unsigned int)aSelected]];
    [[aLayer renderingView] setNeedsDisplayOpenGLSurface:YES];
}

- (BOOL)editPathCanvasLayer:(id)aLayer isKnobSelected:(NSUInteger)aSelected
{
    return (BOOL)[[_selection objectAtIndex:aSelected] boolValue];
}

- (NSUInteger)editPathCanvasLayer:(id)aLayer knobAtViewPoint:(NSPoint)aPoint
{
    return (unsigned int)[[self editPathCanvasItem] knobAtViewPoint:aPoint];
}

- (NSUInteger)knobCountForEditPathCanvasLayer:(id)aLayer
{
    return (unsigned int)[[[self animation] pathKeyFrames] count];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000cd201 @ 000cd201, 96 bytes * /

ulonglong FUN_000cd201(HSAnimationSetupEditPathTool *self,SEL _cmd,uint pointAtIndex)

{
  id pvVar1;
  ulonglong local_14;
  
  pvVar1 = _objc_msgSend(self,sel_animation);
  pvVar1 = _objc_msgSend(pvVar1,sel_path);
  _objc_msgSend(pvVar1,sel_elementAtIndex_associatedPoints_,pointAtIndex,&local_14);
  return local_14;
}

*/
- (NSPoint)pointAtIndex:(NSUInteger)aIndex
{
    NSPoint points[3] = { NSZeroPoint, NSZeroPoint, NSZeroPoint };
    [[[self animation] path] elementAtIndex:aIndex associatedPoints:points];
    return points[0];
    return (NSPoint){0};
}

- (id)tryItAnimation
{
    return [_delegate tryItAnimationForEditPathTool:self];
}

- (id)animation
{
    return [_delegate animationForEditPathTool:self];
}

- (void)resetSelection
{
    NSUInteger pvVar1_4;
    id pvVar3_3;
    NSUInteger pvVar3_4;

    [_selection removeAllObjects];
    if ([[[self animation] pathKeyFrames] count] != 0) {
        pvVar1_4 = 0;
        do {
            [_selection addObject:[NSNumber numberWithBool:NO]];
            pvVar3_3 = [[self animation] pathKeyFrames];
            pvVar1_4 = (pvVar1_4 + 1);
            pvVar3_4 = [pvVar3_3 count];
        } while (pvVar1_4 < pvVar3_4);
    }
}

- (void)updatePath
{
    [self resetSelection];
    [self updateAnimationPath];
    [[[self editPathCanvasLayer] renderingView] setNeedsDisplayOpenGLSurface:YES];
}

- (void)run
{
    [self resetSelection];
    [self updateAnimationPath];
}

- (id)trackingCanvasLayer
{
    HSTrackingRectCanvasLayer *pHVar1;
    HSTrackingRectCanvasLayer *pHVar1_2;

    pHVar1 = _trackingCanvasLayer;
    if (pHVar1 == nil) {
        pHVar1_2 = [HSTrackingRectCanvasLayer new];
        _trackingCanvasLayer = pHVar1_2;
        [pHVar1_2 setDelegate:self];
        pHVar1 = _trackingCanvasLayer;
    }
    return pHVar1;
}

- (id)editPathCanvasItem
{
    HSAnimationSetupEditPathCanvasItem *pHVar1;
    HSAnimationSetupEditPathCanvasItem *pHVar1_2;

    pHVar1 = _editPathCanvasItem;
    if (pHVar1 == nil) {
        pHVar1_2 = [[HSAnimationSetupEditPathCanvasItem alloc] init];
        _editPathCanvasItem = pHVar1_2;
        [pHVar1_2 setDelegate:self];
        pHVar1 = _editPathCanvasItem;
    }
    return pHVar1;
}

- (id)editPathCanvasLayer
{
    HSAnimationSetupEditPathCanvasLayer *pHVar1;
    HSAnimationSetupEditPathCanvasLayer *pHVar1_2;

    pHVar1 = _editPathCanvasLayer;
    if (pHVar1 == nil) {
        pHVar1_2 = [HSAnimationSetupEditPathCanvasLayer new];
        _editPathCanvasLayer = pHVar1_2;
        [pHVar1_2 setOwner:self];
        pHVar1 = _editPathCanvasLayer;
    }
    return pHVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000cd561 @ 000cd561, 262 bytes * /

void FUN_000cd561(HSAnimationSetupEditPathTool *self,SEL _cmd,
                 BOOL finalizeBeforeDeactivateExplicitly)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  id pvVar3;
  HSAnimationSetupEditPathTool *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSTool_0034feb0;
  pvVar3 = (id)(int)finalizeBeforeDeactivateExplicitly;
  _objc_msgSendSuper(&local_1c,sel_finalizeBeforeDeactivateExplicitly_,pvVar3);
  _objc_msgSend(self,sel_cleanupAnimationPath);
  pvVar1 = _objc_msgSend(self,sel_view);
  pvVar1 = _objc_msgSend(pvVar1,sel_rootCanvasLayer);
  self_00 = _objc_msgSend(pvVar1,sel_vectorToolsCanvasLayer);
  if (self->_dragCardCanvasLayer != (id)0x0) {
    pvVar2 = _objc_msgSend(self->_dragCardCanvasLayer,sel_parentLayer);
    if (pvVar2 == self_00) {
      pvVar3 = self->_dragCardCanvasLayer;
      _objc_msgSend(self_00,sel_removeSublayer_,pvVar3);
    }
  }
  pvVar3 = _objc_msgSend(pvVar1,sel_vectorToolsCanvasLayer,pvVar3);
  _objc_msgSend(pvVar3,sel_removeAllSublayers);
  _objc_msgSend(pvVar1,sel_setEnabledSublayerIdentifiers_,0);
  return;
}

*/
- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly
{
    [super finalizeBeforeDeactivateExplicitly:aExplicitly];
    [self cleanupAnimationPath];
    id rootLayer = [[self view] rootCanvasLayer];
    id toolsLayer = [rootLayer vectorToolsCanvasLayer];
    if (_dragCardCanvasLayer != nil && [_dragCardCanvasLayer parentLayer] == toolsLayer) {
        [toolsLayer removeSublayer:_dragCardCanvasLayer];
    }
    [[rootLayer vectorToolsCanvasLayer] removeAllSublayers];
    [rootLayer setEnabledSublayerIdentifiers:nil];
}

- (void)didActivateExplicitly:(BOOL)aExplicitly
{
    id pvVar1;
    id pvVar2;
    id self_00;
    id self_01;

    pvVar1 = [[[HSGenericItemsCanvasSublayer alloc] init] autorelease];
    pvVar2 = [self editPathCanvasItem];
    [pvVar1 addCanvasItem:pvVar2];
    pvVar2 = [self view];
    self_00 = [pvVar2 rootCanvasLayer];
    self_01 = [self_00 vectorToolsCanvasLayer];
    [self_01 addSublayer:pvVar1];
    pvVar1 = [self trackingCanvasLayer];
    [self_01 addSublayer:pvVar1];
    pvVar1 = [self editPathCanvasLayer];
    [self_01 addSublayer:pvVar1];
    pvVar1 = [HSSelectionKnobsCanvasLayer new];
    pvVar2 = [pvVar1 autorelease];
    [self_01 addSublayer:pvVar2];
    pvVar1 = _dragCardCanvasLayer;
    if (pvVar1 == nil) {
        pvVar1 = [HSDragCardViewCanvasLayer new];
        _dragCardCanvasLayer = pvVar1;
    }
    if (pvVar1 != nil) {
        [self_01 addSublayer:pvVar1];
        pvVar2 = pvVar1;
    }
    pvVar1 = [self_00 vectorToolsIdentifiers];
    [self_00 setEnabledSublayerIdentifiers:pvVar1];
    [super didActivateExplicitly:aExplicitly];
}

- (BOOL)allowsActiveInPlaceEditors
{
    return NO;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (BOOL)shouldResetToolOnAddObjects
{
    return NO;
}

- (void)dealloc
{
    [_selection release];
    [_trackingCanvasLayer setDelegate:0];
    [_trackingCanvasLayer release];
    [_editPathCanvasItem setDelegate:0];
    [_editPathCanvasItem release];
    [_editPathCanvasLayer setOwner:nil];
    [_editPathCanvasLayer release];
    [_dragCardCanvasLayer release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _selection = [NSMutableArray new];
    }
    return self;
}

- (BOOL)shouldResetToolOnSelectObjects
{
    return NO;
}

- (void)userSelectAnotherObject:(id)aObject withEditPathCanvasLayer:(id)aLayer
{
    [_delegate userSelectAnotherObject:aObject withEditPathTool:self];
}

@end

