#import "HSBezierPathCreationCanvasLayer.h"

@implementation HSBezierPathCreationCanvasLayer

/* i386 ivar offsets: _creatingObject=0x14, _delegate=0x18, _prototypeObject=0x1c, _isStraightLineMode=0x20, _isAppendPending=0x21, _isAppendPendingWithCurrentPoint=0x22, _createsClosedPathByDefault=0x23, _pendingPoint=0x24 */

- (void)cancelCreatingVectorGraphicsObject
{
    if ([_delegate respondsToSelector:@selector(bezierPathCreationLayer:willCancelEditingObject:)]) {
        [_delegate bezierPathCreationLayer:self willCancelEditingObject:_creatingObject];
    }
    [self setCreatingObject:nil];
    _isAppendPending = NO;
    _isAppendPendingWithCurrentPoint = NO;
}

- (void)finishCreatingVectorGraphicsObject
{
    if ([_delegate respondsToSelector:@selector(bezierPathCreationLayer:willFinishEditingObject:)]) {
        [_delegate bezierPathCreationLayer:self willFinishEditingObject:_creatingObject];
    }
    [self setCreatingObject:nil];
    _isAppendPending = NO;
    _isAppendPendingWithCurrentPoint = NO;
}

- (void)finishCreatingVectorGraphicsObjectWithMouseEvent:(id)aEvent
{
    [self finishCreatingVectorGraphicsObject];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a574c @ 000a574c, 715 bytes * /

void FUN_000a574c(HSBezierPathCreationCanvasLayer *self,SEL _cmd,
                 id startCreatingVectorGraphicsObjectWithMouseEvent)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id self_00;
  id pvVar4;
  id pvVar5;
  undefined4 extraout_EDX;
  id extraout_EDX_00;
  float extraout_EDX_01;
  id pvVar6;
  id local_2c [2];
  undefined4 local_24;
  undefined4 local_20;
  undefined4 local_1c;
  undefined4 local_18;
  
  pvVar1 = _objc_msgSend(self,sel_renderingView);
  pvVar2 = _objc_msgSend(startCreatingVectorGraphicsObjectWithMouseEvent,sel_locationInWindow);
  pvVar6 = (id)0x0;
  pvVar2 = _objc_msgSend(pvVar1,sel_convertPoint_fromView_,pvVar2,extraout_EDX,0);
  pvVar3 = _objc_msgSend(self,sel_renderingView);
  pvVar1 = extraout_EDX_00;
  pvVar2 = _objc_msgSend(pvVar3,sel_convertPointFromViewSpaceToUserSpace_,pvVar2,extraout_EDX_00);
  local_24 = *(undefined4 *)PTR_00336074;
  local_20 = *(undefined4 *)(PTR_00336074 + 4);
  local_2c[0] = pvVar2;
  local_1c = local_24;
  local_18 = local_20;
  pvVar3 = _objc_msgSend(self,sel_prototypeObject);
  pvVar3 = _objc_msgSend(pvVar3,sel_copy);
  pvVar3 = _objc_msgSend(pvVar3,sel_autorelease);
  self_00 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_003692c4);
  pvVar4 = _objc_msgSend(self,sel_defaultBezierPath);
  pvVar4 = _objc_msgSend(pvVar4,sel_copy);
  pvVar4 = _objc_msgSend(pvVar4,sel_autorelease);
  pvVar5 = _objc_msgSend(self_00,sel_hyperBezierPath);
  _objc_msgSend(pvVar4,sel_hyperCopyVisualAttributesFrom_,pvVar5);
  _objc_msgSend(self_00,sel_setHyperBezierPath_,pvVar4);
  pvVar4 = _objc_msgSend(self->_delegate,sel_respondsToSelector_,
                         sel_bezierPathCreationLayer_shouldStartEditingObject_atUserPoint_);
  if (((char)pvVar4 != '\0') &&
     (pvVar1 = pvVar3, pvVar6 = pvVar2,
     pvVar4 = _objc_msgSend(self->_delegate,
                            sel_bezierPathCreationLayer_shouldStartEditingObject_atUserPoint_,self,
                            pvVar3,pvVar2,extraout_EDX_01), (char)pvVar4 == '\0')) {
    return;
  }
  _objc_msgSend(self,sel_setCreatingObject_,pvVar3,pvVar1,pvVar6);
  _objc_msgSend(self_00,sel_appendHyperElement_associatedPoints_,0,local_2c);
  pvVar1 = _objc_msgSend(self->_delegate,sel_respondsToSelector_,
                         sel_bezierPathCreationLayer_didStartEditingObject_atUserPoint_);
  if ((char)pvVar1 != '\0') {
    _objc_msgSend(self->_delegate,sel_bezierPathCreationLayer_didStartEditingObject_atUserPoint_,
                  self,pvVar3,pvVar2,extraout_EDX_01);
  }
  self->_isAppendPending = '\x01';
  (self->_pendingPoint).x = (float)pvVar2;
  (self->_pendingPoint).y = extraout_EDX_01;
  return;
}

*/
- (void)startCreatingVectorGraphicsObjectWithMouseEvent:(id)aEvent
{
    NSPoint viewPoint = [[self renderingView] convertPoint:[aEvent locationInWindow] fromView:nil];
    NSPoint userPoint = [[self renderingView] convertPointFromViewSpaceToUserSpace:viewPoint];
    NSPoint points[3] = { userPoint, NSZeroPoint, NSZeroPoint };
    id object = [[[[self prototypeObject] copy] autorelease] retain];
    object = [object autorelease];
    id<HSMutableVectorGraphicsAttributes> attributes = [object queryHyperInterface:@protocol(HSMutableVectorGraphicsAttributes)];
    id path = [[[[self defaultBezierPath] copy] autorelease] retain];
    path = [path autorelease];
    [path hyperCopyVisualAttributesFrom:[attributes hyperBezierPath]];
    [attributes setHyperBezierPath:path];
    if ([_delegate respondsToSelector:@selector(bezierPathCreationLayer:shouldStartEditingObject:atUserPoint:)] &&
        ![_delegate bezierPathCreationLayer:self shouldStartEditingObject:object atUserPoint:userPoint]) {
        return;
    }
    [self setCreatingObject:object];
    [attributes appendHyperElement:0 associatedPoints:points];
    if ([_delegate respondsToSelector:@selector(bezierPathCreationLayer:didStartEditingObject:atUserPoint:)]) {
        [_delegate bezierPathCreationLayer:self didStartEditingObject:object atUserPoint:userPoint];
    }
    _isAppendPending = YES;
    _pendingPoint = userPoint;
}

- (void)removeTemporaryPointIfAnyWithMouseEvent:(id)aEvent
{
    NSInteger pvVar2;
    id pvVar1_2;

    if (_isAppendPendingWithCurrentPoint == NO) {
        if ([self currentPointIndex] != 0) {
            pvVar1_2 = [self vectorAttributes];
            pvVar2 = [self editingMode];
            [pvVar1_2 deleteHyperElementAtIndex:[self currentPointIndex] glueWithEditingMode:pvVar2];
            _isAppendPendingWithCurrentPoint = YES;
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a54e9 @ 000a54e9, 465 bytes * /

void FUN_000a54e9(HSBezierPathCreationCanvasLayer *self,SEL _cmd,id addTemporaryPointWithMouseEvent)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  char cVar4;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  float extraout_EDX_01;
  SEL op;
  float local_18;
  id local_14;
  
  cVar4 = self->_isAppendPending;
  if (cVar4 == '\0') {
    pvVar1 = _objc_msgSend(self,sel_renderingView);
    pvVar2 = _objc_msgSend(self,sel_renderingView);
    pvVar3 = _objc_msgSend(addTemporaryPointWithMouseEvent,sel_locationInWindow);
    pvVar2 = _objc_msgSend(pvVar2,sel_convertPoint_fromView_,pvVar3,extraout_EDX,0);
    local_14 = _objc_msgSend(pvVar1,sel_convertPointFromViewSpaceToUserSpace_,pvVar2,extraout_EDX_00
                            );
    cVar4 = self->_isAppendPending;
    local_18 = extraout_EDX_01;
  }
  else {
    local_14 = (id)(self->_pendingPoint).x;
    local_18 = (self->_pendingPoint).y;
  }
  if ((cVar4 == '\0') && (self->_isAppendPendingWithCurrentPoint == '\0')) {
    pvVar1 = _objc_msgSend(self,sel_vectorAttributes);
    pvVar2 = _objc_msgSend(self,sel_editingMode);
    pvVar3 = _objc_msgSend(self,sel_currentPointIndex);
    op = sel_setHyperPoint_atIndex_editingMode_;
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_vectorAttributes);
    pvVar2 = _objc_msgSend(self,sel_editingMode);
    pvVar3 = _objc_msgSend(self,sel_currentPointIndex);
    pvVar3 = (id)((int)pvVar3 + 1);
    op = sel_insertHyperPoint_atIndex_editingMode_;
  }
  _objc_msgSend(pvVar1,op,local_14,local_18,pvVar3,pvVar2);
  self->_isAppendPending = '\0';
  self->_isAppendPendingWithCurrentPoint = '\0';
  return;
}

*/
- (void)addTemporaryPointWithMouseEvent:(id)aEvent
{
    NSPoint point;
    if (!_isAppendPending) {
        NSPoint viewPoint = [[self renderingView] convertPoint:[aEvent locationInWindow] fromView:nil];
        point = [[self renderingView] convertPointFromViewSpaceToUserSpace:viewPoint];
    } else {
        point = _pendingPoint;
    }
    if (!_isAppendPending && !_isAppendPendingWithCurrentPoint) {
        [[self vectorAttributes] setHyperPoint:point atIndex:[self currentPointIndex] editingMode:[self editingMode]];
    } else {
        [[self vectorAttributes] insertHyperPoint:point atIndex:[self currentPointIndex] + 1 editingMode:[self editingMode]];
    }
    _isAppendPending = NO;
    _isAppendPendingWithCurrentPoint = NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a5444 @ 000a5444, 165 bytes * /

void FUN_000a5444(HSBezierPathCreationCanvasLayer *self,SEL _cmd,id addPointWithMouseEvent)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  float extraout_EDX_01;
  
  self->_isAppendPending = '\x01';
  pvVar1 = _objc_msgSend(self,sel_renderingView);
  pvVar2 = _objc_msgSend(self,sel_renderingView);
  pvVar3 = _objc_msgSend(addPointWithMouseEvent,sel_locationInWindow);
  pvVar2 = _objc_msgSend(pvVar2,sel_convertPoint_fromView_,pvVar3,extraout_EDX,0);
  pvVar1 = _objc_msgSend(pvVar1,sel_convertPointFromViewSpaceToUserSpace_,pvVar2,extraout_EDX_00);
  (self->_pendingPoint).x = (float)pvVar1;
  (self->_pendingPoint).y = extraout_EDX_01;
  return;
}

*/
- (void)addPointWithMouseEvent:(id)aEvent
{
    _isAppendPending = YES;
    NSPoint viewPoint = [[self renderingView] convertPoint:[aEvent locationInWindow] fromView:nil];
    _pendingPoint = [[self renderingView] convertPointFromViewSpaceToUserSpace:viewPoint];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a5b9a @ 000a5b9a, 674 bytes * /

BOOL FUN_000a5b9a(HSBezierPathCreationCanvasLayer *self,SEL _cmd,id shouldIgnoreMouseMovedEvent)

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
  bool bVar7;
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
  
  pvVar4 = _objc_msgSend(self,sel_context);
  pvVar4 = _objc_msgSend(pvVar4,sel_renderingView);
  if (pvVar4 == (id)0x0) {
    bVar7 = true;
  }
  else {
    pvVar5 = _objc_msgSend(pvVar4,sel_window);
    pvVar5 = _objc_msgSend(pvVar5,sel_contentView);
    pvVar6 = _objc_msgSend(shouldIgnoreMouseMovedEvent,sel_locationInWindow);
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
                          SUB84(local_24._0_8_,4),(int)local_24._8_8_,SUB84(local_24._8_8_,4),pvVar4
                         );
      local_44 = local_54;
      uStack_40 = local_50;
      local_3c = local_4c;
      uStack_38 = local_48;
    }
    else {
      _objc_msgSend_stret(local_34,self_00,sel_bounds);
      _objc_msgSend_stret(&local_44,pvVar5,sel_convertRect_fromView_,(int)local_34._0_8_,
                          SUB84(local_34._0_8_,4),(int)local_34._8_8_,SUB84(local_34._8_8_,4),
                          self_00);
    }
    _NSInsetRect(&local_64,CONCAT44(uStack_40,local_44),local_3c,uStack_38,0xc1200000,0xc1200000);
    local_44 = local_64;
    uStack_40 = local_60;
    local_3c = local_5c;
    uStack_38 = local_58;
    pvVar4 = _objc_msgSend(pvVar5,sel_mouse_inRect_,pvVar6,extraout_EDX_00,local_64,local_60,
                           local_5c,local_58);
    bVar7 = (char)pvVar4 == '\0';
  }
  return bVar7;
}

*/
- (BOOL)shouldIgnoreMouseMovedEvent:(id)aEvent
{
    NSView *view = [[self context] renderingView];
    if (view == nil) {
        return YES;
    }
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
    return ![contentView mouse:point inRect:rect];
    return 0;
}

- (NSInteger)editingMode
{
    return (unsigned int)(![self isStraightLineMode]);
}

- (NSUInteger)currentPointIndex
{
    char cVar1;

    cVar1 = _createsClosedPathByDefault;
    return (int)[[self vectorAttributes] hyperElementCount] + (unsigned int)(cVar1 == NO) * 3 + -4;
}

- (void)handleFlagsChanged:(id)aChanged inTrackingLoop:(id)aLoop
{

}

- (void)handleMouseUp:(id)aUp inTrackingLoop:(id)aLoop
{

}

- (void)handleMouseDragged:(id)aDragged inTrackingLoop:(id)aLoop
{
    if ([self vectorAttributes] != nil) {
        [self addTemporaryPointWithMouseEvent:aDragged];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a5306 @ 000a5306, 124 bytes * /

void FUN_000a5306(HSBezierPathCreationCanvasLayer *self,SEL _cmd,id handleMouseDown,
                 id inTrackingLoop)

{
  id pvVar1;
  SEL pcVar2;
  SEL op;
  
  pvVar1 = _objc_msgSend(handleMouseDown,sel_clickCount);
  pcVar2 = sel_finishCreatingVectorGraphicsObjectWithMouseEvent_;
  if ((pvVar1 == (id)0x2) ||
     (pvVar1 = _objc_msgSend(self,sel_vectorAttributes), pcVar2 = sel_addPointWithMouseEvent_,
     op = sel_startCreatingVectorGraphicsObjectWithMouseEvent_, pvVar1 != (id)0x0)) {
    op = pcVar2;
  }
  _objc_msgSend(self,op,handleMouseDown);
  self->_isAppendPendingWithCurrentPoint = '\0';
  return;
}

*/
- (void)handleMouseDown:(id)aDown inTrackingLoop:(id)aLoop
{
    SEL selector = @selector(finishCreatingVectorGraphicsObjectWithMouseEvent:);
    if ([aDown clickCount] != 2) {
        if ([self vectorAttributes] == nil) {
            selector = @selector(startCreatingVectorGraphicsObjectWithMouseEvent:);
        } else {
            selector = @selector(addPointWithMouseEvent:);
        }
    }
    [self performSelector:selector withObject:aDown];
    _isAppendPendingWithCurrentPoint = NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a5284 @ 000a5284, 130 bytes * /

BOOL FUN_000a5284(HSBezierPathCreationCanvasLayer *self,SEL _cmd,NSPoint handleMouseMovedAtPoint,
                 BOOL insideView,id event)

{
  BOOL BVar1;
  id pvVar2;
  SEL op;
  
  pvVar2 = _objc_msgSend(self,sel_vectorAttributes);
  if (pvVar2 == (id)0x0) {
    BVar1 = '\0';
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_shouldIgnoreMouseMovedEvent_,event);
    op = sel_addTemporaryPointWithMouseEvent_;
    if (((char)pvVar2 != '\0') && (self->_isAppendPending == '\0')) {
      op = sel_removeTemporaryPointIfAnyWithMouseEvent_;
    }
    _objc_msgSend(self,op,event);
    BVar1 = '\x01';
  }
  return BVar1;
}

*/
- (BOOL)handleMouseMovedAtPoint:(NSPoint)aPoint insideView:(BOOL)aView event:(id)aEvent
{
    if ([self vectorAttributes] == nil) {
        return NO;
    }
    SEL selector = @selector(addTemporaryPointWithMouseEvent:);
    if ([self shouldIgnoreMouseMovedEvent:aEvent] && !_isAppendPending) {
        selector = @selector(removeTemporaryPointIfAnyWithMouseEvent:);
    }
    [self performSelector:selector withObject:aEvent];
    return YES;
    return 0;
}

- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo
{
    [[HSTrackingLoop trackingLoopWithView:[self renderingView] client:self] runWithMouseDownEvent:aEvent];
    return YES;
}

- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo
{
    return self;
}

- (id)vectorAttributes
{
    return [_creatingObject queryHyperInterface:@protocol(HSMutableVectorGraphicsAttributes)];
}

- (void)setCreatingObject:(id)aObject
{
    if (_creatingObject != aObject) {
        [_creatingObject release];
        _creatingObject = [aObject retain];
    }
}

- (id)creatingObject
{
    return _creatingObject;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a5e3c @ 000a5e3c, 154 bytes * /

id FUN_000a5e3c(HSBezierPathCreationCanvasLayer *self,SEL _cmd,NSPoint cursorForPoint,
               BOOL insideView,uint modifierFlags,id hitTestInfo,id event)

{
  id pvVar1;
  HSBezierPathCreationCanvasLayer *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_HSCompositeCanvasLayer_0034f1c0;
  pvVar1 = _objc_msgSendSuper(&local_14,
                              sel_cursorForPoint_insideView_modifierFlags_hitTestInfo_event_,
                              cursorForPoint.x,cursorForPoint.y,(uint)(byte)insideView,modifierFlags
                              ,hitTestInfo,event);
  if ((pvVar1 == (id)0x0) && (insideView != '\0')) {
    pvVar1 = _objc_msgSend(cls_HSCursor,sel_cursorNamed_,*(undefined4 *)PTR_PTR_0033633c);
  }
  return pvVar1;
}

*/
- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags hitTestInfo:(id)aInfo event:(id)aEvent
{
    id cursor = [super cursorForPoint:aPoint insideView:aView modifierFlags:aFlags hitTestInfo:aInfo event:aEvent];
    if (cursor == nil && aView) {
        cursor = [HSCursor cursorNamed:@"HSCrossCursor"];
    }
    return cursor;
    return 0;
}

- (BOOL)supportsDynamicPathClosing
{
    return _createsClosedPathByDefault == NO;
}

- (void)setCreatesClosedPathByDefault:(BOOL)aDefault
{
    if ((BOOL)_createsClosedPathByDefault != (aDefault != NO)) {
        _createsClosedPathByDefault = aDefault != NO;
    }
}

- (BOOL)createsClosedPathByDefault
{
    return _createsClosedPathByDefault;
}

- (void)setStraightLineMode:(BOOL)aMode
{
    _isStraightLineMode = aMode;
}

- (BOOL)isStraightLineMode
{
    return _isStraightLineMode;
}

- (id)defaultBezierPath
{
    id pcVar1;

    if (_createsClosedPathByDefault == NO) {
        pcVar1 = @"M 0 0";
    }
    else {
        pcVar1 = @"M 0 0 C 0 0 0 0 0 0 Z M 0 0";
    }
    return [NSBezierPath hyperBezierPathWithString:pcVar1];
}

- (void)setPrototypeObject:(id)aObject
{
    if (_prototypeObject != aObject) {
        [_prototypeObject release];
        _prototypeObject = [aObject retain];
    }
}

- (id)prototypeObject
{
    return _prototypeObject;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (void)dealloc
{
    [_prototypeObject release];
    [_creatingObject release];
    [super dealloc];
}

@end

