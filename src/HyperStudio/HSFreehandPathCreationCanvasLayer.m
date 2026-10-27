#import "HSFreehandPathCreationCanvasLayer.h"

@implementation HSFreehandPathCreationCanvasLayer

/* i386 ivar offsets: _delegate=0x14, _prototypeObject=0x18, _creatingObject=0x1c, _keyFrames=0x20, _lastEventTimestamp=0x24, _didDrag=0x2c */

- (void)finishCreatingPathWithEvent:(id)aEvent
{
    char cVar1;
    id pvVar2_2;

    if ([_delegate respondsToSelector:@selector(freehandPathCreationLayer:willFinishEditingObject:restart:)]) {
        pvVar2_2 = _delegate;
        cVar1 = _didDrag;
        [pvVar2_2 freehandPathCreationLayer:self willFinishEditingObject:[self creatingObject] restart:(unsigned int)(cVar1 == NO)];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ab9f7 @ 000ab9f7, 608 bytes * /

void FUN_000ab9f7(HSFreehandPathCreationCanvasLayer *self,SEL _cmd,id continueCreatingPathWithEvent)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  undefined4 extraout_EDX_01;
  double dVar4;
  double dVar5;
  double dVar6;
  double dVar7;
  double dVar8;
  double local_34;
  
  dVar7 = _objc_msgSend_fpret(continueCreatingPathWithEvent,sel_timestamp);
  dVar4 = dVar7 - self->_lastEventTimestamp;
  if ((dVar4 != 0.0) || (NAN(dVar4))) {
    local_34 = ABS(dVar4);
  }
  else {
    local_34 = 1.0;
  }
  pvVar1 = _objc_msgSend(self->_keyFrames,sel_lastObject);
  dVar8 = _objc_msgSend_fpret(pvVar1,sel_doubleValue);
  dVar5 = 1e-05;
  if (1.0 <= local_34) {
    dVar5 = local_34 * 1e-05;
  }
  dVar6 = 0.0;
  if (0.0 - dVar5 <= dVar4) {
    dVar6 = dVar4;
  }
  pvVar1 = self->_keyFrames;
  pvVar2 = _objc_msgSend(cls_NSNumber,sel_numberWithDouble_,dVar6 + dVar8);
  _objc_msgSend(pvVar1,sel_addObject_,pvVar2);
  self->_lastEventTimestamp = dVar7;
  pvVar1 = _objc_msgSend(self,sel_renderingView);
  pvVar2 = _objc_msgSend(continueCreatingPathWithEvent,sel_locationInWindow);
  pvVar1 = _objc_msgSend(pvVar1,sel_convertPoint_fromView_,pvVar2,extraout_EDX,0);
  pvVar2 = _objc_msgSend(self,sel_renderingView);
  pvVar2 = _objc_msgSend(pvVar2,sel_convertPointFromViewSpaceToUserSpace_,pvVar1,extraout_EDX_00);
  pvVar1 = _objc_msgSend(self,sel_vectorAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperBezierPath);
  pvVar1 = _objc_msgSend(pvVar1,sel_elementCount);
  pvVar3 = _objc_msgSend(self,sel_vectorAttributes);
  _objc_msgSend(pvVar3,sel_insertHyperPoint_atIndex_editingMode_,pvVar2,extraout_EDX_01,pvVar1,1);
  pvVar1 = self->_delegate;
  pvVar3 = _objc_msgSend(self,sel_creatingObject);
  _objc_msgSend(pvVar1,sel_freehandPathCreationLayer_continueEditingObject_atUserPoint_,self,pvVar3,
                pvVar2,extraout_EDX_01);
  return;
}

*/
- (void)continueCreatingPathWithEvent:(id)aEvent
{
    double timestamp = [(NSEvent *)aEvent timestamp];
    double delta = timestamp - _lastEventTimestamp;
    double scale = (delta != 0.0 || delta != delta) ? fabs(delta) : 1.0;
    double last = [[_keyFrames lastObject] doubleValue];
    double tolerance = 1e-05;
    if (1.0 <= scale) {
        tolerance = scale * 1e-05;
    }
    double increment = 0.0;
    if (0.0 - tolerance <= delta) {
        increment = delta;
    }
    [_keyFrames addObject:[NSNumber numberWithDouble:increment + last]];
    _lastEventTimestamp = timestamp;
    NSPoint viewPoint = [[self renderingView] convertPoint:[(NSEvent *)aEvent locationInWindow] fromView:nil];
    NSPoint userPoint = [[self renderingView] convertPointFromViewSpaceToUserSpace:viewPoint];
    [[self vectorAttributes] insertHyperPoint:userPoint atIndex:[[[self vectorAttributes] hyperBezierPath] elementCount] editingMode:1];
    [_delegate freehandPathCreationLayer:self continueEditingObject:[self creatingObject] atUserPoint:userPoint];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000abc57 @ 000abc57, 734 bytes * /

void FUN_000abc57(HSFreehandPathCreationCanvasLayer *self,SEL _cmd,id startCreatingPathWithEvent)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id self_00;
  id pvVar4;
  id pvVar5;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  undefined4 extraout_EDX_01;
  double dVar6;
  undefined *puVar7;
  id local_2c [2];
  undefined4 local_24;
  undefined4 local_20;
  undefined4 local_1c;
  undefined4 local_18;
  
  puVar7 = cls_NSMutableArray;
  pvVar1 = _objc_msgSend(cls_NSNumber,sel_numberWithDouble_,0,0);
  pvVar1 = _objc_msgSend(puVar7,sel_arrayWithObject_,pvVar1);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_keyFrames = pvVar1;
  dVar6 = _objc_msgSend_fpret(startCreatingPathWithEvent,sel_timestamp);
  self->_lastEventTimestamp = dVar6;
  pvVar2 = _objc_msgSend(self,sel_renderingView);
  pvVar3 = _objc_msgSend(startCreatingPathWithEvent,sel_locationInWindow);
  pvVar1 = (id)0x0;
  pvVar2 = _objc_msgSend(pvVar2,sel_convertPoint_fromView_,pvVar3,extraout_EDX,0);
  pvVar3 = _objc_msgSend(self,sel_renderingView);
  pvVar2 = _objc_msgSend(pvVar3,sel_convertPointFromViewSpaceToUserSpace_,pvVar2,extraout_EDX_00);
  pvVar3 = _objc_msgSend(self,sel_prototypeObject);
  pvVar3 = _objc_msgSend(pvVar3,sel_copy);
  pvVar3 = _objc_msgSend(pvVar3,sel_autorelease);
  self_00 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_00369c9c);
  pvVar4 = _objc_msgSend(self,sel_defaultBezierPath);
  pvVar4 = _objc_msgSend(pvVar4,sel_copy);
  pvVar4 = _objc_msgSend(pvVar4,sel_autorelease);
  pvVar5 = _objc_msgSend(self_00,sel_hyperBezierPath);
  _objc_msgSend(pvVar4,sel_hyperCopyVisualAttributesFrom_,pvVar5);
  _objc_msgSend(self_00,sel_setHyperBezierPath_,pvVar4);
  _objc_msgSend(self,sel_setCreatingObject_,pvVar3);
  puVar7 = sel_freehandPathCreationLayer_didStartEditingObject_atUserPoint_;
  pvVar3 = _objc_msgSend(self->_delegate,sel_respondsToSelector_,
                         sel_freehandPathCreationLayer_didStartEditingObject_atUserPoint_);
  if ((char)pvVar3 != '\0') {
    pvVar3 = self->_delegate;
    pvVar4 = _objc_msgSend(self,sel_creatingObject,puVar7);
    pvVar1 = pvVar2;
    _objc_msgSend(pvVar3,sel_freehandPathCreationLayer_didStartEditingObject_atUserPoint_,self,
                  pvVar4,pvVar2,extraout_EDX_01);
  }
  local_24 = *(undefined4 *)PTR_00336074;
  local_20 = *(undefined4 *)(PTR_00336074 + 4);
  local_2c[0] = pvVar2;
  local_1c = local_24;
  local_18 = local_20;
  _objc_msgSend(self_00,sel_appendHyperElement_associatedPoints_,0,local_2c,pvVar1);
  return;
}

*/
- (void)startCreatingPathWithEvent:(id)aEvent
{
    _keyFrames = [[NSMutableArray arrayWithObject:[NSNumber numberWithDouble:0.0]] retain];
    _lastEventTimestamp = [(NSEvent *)aEvent timestamp];
    NSPoint viewPoint = [[self renderingView] convertPoint:[(NSEvent *)aEvent locationInWindow] fromView:nil];
    NSPoint userPoint = [[self renderingView] convertPointFromViewSpaceToUserSpace:viewPoint];
    id object = [[[self prototypeObject] copy] autorelease];
    id vectorAttributes = [object queryHyperInterface:@protocol(HSMutableVectorGraphicsAttributes)];
    id path = [[[self defaultBezierPath] copy] autorelease];
    [path hyperCopyVisualAttributesFrom:[vectorAttributes hyperBezierPath]];
    [vectorAttributes setHyperBezierPath:path];
    [self setCreatingObject:object];
    if ([_delegate respondsToSelector:@selector(freehandPathCreationLayer:didStartEditingObject:atUserPoint:)]) {
        [_delegate freehandPathCreationLayer:self didStartEditingObject:[self creatingObject] atUserPoint:userPoint];
    }
    NSPoint points[3] = { userPoint, NSZeroPoint, NSZeroPoint };
    [vectorAttributes appendHyperElement:0 associatedPoints:points];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000abf35 @ 000abf35, 188 bytes * /

void FUN_000abf35(HSFreehandPathCreationCanvasLayer *self,SEL _cmd,
                 id setObjectPositionAccordingToMouseMovedEvent)

{
  id pvVar1;
  id pvVar2;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  undefined4 extraout_EDX_01;
  
  pvVar1 = _objc_msgSend(self,sel_renderingView);
  pvVar2 = _objc_msgSend(setObjectPositionAccordingToMouseMovedEvent,sel_locationInWindow);
  pvVar1 = _objc_msgSend(pvVar1,sel_convertPoint_fromView_,pvVar2,extraout_EDX,0);
  pvVar2 = _objc_msgSend(self,sel_renderingView);
  pvVar1 = _objc_msgSend(pvVar2,sel_convertPointFromViewSpaceToUserSpace_,pvVar1,extraout_EDX_00);
  _objc_msgSend(self->_delegate,sel_freehandPathCreationLayer_setObjectPosition_,self,pvVar1,
                extraout_EDX_01);
  return;
}

*/
- (void)setObjectPositionAccordingToMouseMovedEvent:(id)aEvent
{
    NSPoint viewPoint = [[self renderingView] convertPoint:[(NSEvent *)aEvent locationInWindow] fromView:nil];
    [_delegate freehandPathCreationLayer:self setObjectPosition:[[self renderingView] convertPointFromViewSpaceToUserSpace:viewPoint]];
}

- (BOOL)isCreatingPath
{
    return _keyFrames != nil;
}

- (void)handleFlagsChanged:(id)aChanged inTrackingLoop:(id)aLoop
{

}

- (void)handleMouseUp:(id)aUp inTrackingLoop:(id)aLoop
{
    if ([self isCreatingPath]) {
        [self finishCreatingPathWithEvent:aUp];
    }
}

- (void)handleMouseDragged:(id)aDragged inTrackingLoop:(id)aLoop
{
    _didDrag = YES;
    if ([self isCreatingPath]) {
        [self continueCreatingPathWithEvent:aDragged];
    }
}

- (void)handleMouseDown:(id)aDown inTrackingLoop:(id)aLoop
{
    if (![self isCreatingPath]) {
        [self startCreatingPathWithEvent:aDown];
    }
}

- (BOOL)handleMouseMovedAtPoint:(NSPoint)aPoint insideView:(BOOL)aView event:(id)aEvent
{
    BOOL bVar2;

    bVar2 = ![self isCreatingPath];
    if (bVar2) {
        [self setObjectPositionAccordingToMouseMovedEvent:aEvent];
    }
    return bVar2;
}

- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo
{
    _didDrag = NO;
    [[HSTrackingLoop trackingLoopWithView:[self renderingView] client:self] runWithMouseDownEvent:aEvent];
    return YES;
}

- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo
{
    return self;
}

- (id)defaultBezierPath
{
    return [NSBezierPath hyperBezierPathWithString:@"M 0 0"];
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

- (id)keyFrames
{
    return _keyFrames;
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
    [_keyFrames release];
    [_creatingObject release];
    [_prototypeObject release];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ab92c @ 000ab92c, 75 bytes * /

id FUN_000ab92c(HSFreehandPathCreationCanvasLayer *self,SEL _cmd)

{
  id pvVar1;
  HSFreehandPathCreationCanvasLayer *local_c;
  undefined *local_8;
  
  local_c = self;
  local_8 = PTR_s_HSCompositeCanvasLayer_0034f430;
  pvVar1 = _objc_msgSendSuper(&local_c,sel_init);
  if (pvVar1 != (id)0x0) {
    *(undefined4 *)((int)pvVar1 + 0x28) = 0;
    *(undefined4 *)((int)pvVar1 + 0x24) = 0;
    *(undefined1 *)((int)pvVar1 + 0x2c) = 0;
  }
  return pvVar1;
}

*/
- (id)init
{
    self = [super init];
    if (self != nil) {
        _lastEventTimestamp = 0.0;
        _didDrag = NO;
    }
    return self;
    return 0;
}

@end

