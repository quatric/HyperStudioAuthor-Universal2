#import "HSLineTool.h"

@implementation HSLineTool

/* i386 ivar offsets: _trackingObject=0x1c, _visualizationCanvasLayer=0x20 */

+ (Class)userObjectClass
{
    return [HSVectorGraphicsObject class];
}

- (BOOL)worksInBitmapLayer
{
    return YES;
}

- (void)setupToolLayer
{
    [super setupToolLayer];
    [[[[self view] rootCanvasLayer] bitmapToolsCanvasLayer] addSublayer:[self visualizationCanvasLayer]];
}

- (void)cleanupToolLayer
{
    [super cleanupToolLayer];
    [[[[self view] rootCanvasLayer] bitmapToolsCanvasLayer] removeSublayer:_visualizationCanvasLayer];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000411ad @ 000411ad, 19 bytes * /

id FUN_000411ad(HSLineTool *self,SEL _cmd)

{
  return *(id *)PTR_PTR_0033633c;
}

*/
- (id)defaultToolCursorName
{
    return HSCrossCursor;
    return 0;
}

- (BOOL)allowsToEditPrototypeObjectInterface:(id)aInterface
{
    if ((protocol_conformsToProtocol(aInterface,@protocol(HSVectorGraphicsAttributes))) == NO) {
        if ((protocol_conformsToProtocol(aInterface,@protocol(HSShadowAttributes))) == NO) {
            if ((protocol_conformsToProtocol(aInterface,@protocol(HSOpacityAttributes))) == NO) {
                return (BOOL)[super allowsToEditPrototypeObjectInterface:aInterface];
            }
        }
    }
    return YES;
}

- (BOOL)allowsActiveInPlaceEditors
{
    return NO;
}

- (void)insertNewline:(id)aNewline
{
    if ([self trackingObject] != nil) {
        [self leaveTrackingObjectAndNotify:YES registerInCard:YES forceSwitchTool:YES];
    }
}

- (void)cancelOperation:(id)aOperation
{
    if ([self trackingObject] != nil) {
        [self leaveTrackingObjectAndNotify:YES registerInCard:NO forceSwitchTool:YES];
    }
}

- (void)flagsChanged:(id)aChanged
{

}

- (void)handleMouseUp:(id)aUp
{
    if (_trackingObject != nil) {
        [self leaveTrackingObjectAndNotify:YES];
    }
}

- (void)handleAutoscrollingWithMouseEvent:(id)aEvent
{
    [super handleAutoscrollingWithMouseEvent:aEvent];
    [self handleMouseDragged:aEvent];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00041768 @ 00041768, 198 bytes * /

void FUN_00041768(HSLineTool *self,SEL _cmd,id handleMouseDragged)

{
  id pvVar1;
  id pvVar2;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  id local_14 [2];
  
  if (self->_trackingObject != (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_view);
    pvVar2 = _objc_msgSend(handleMouseDragged,sel_locationInWindow);
    pvVar2 = _objc_msgSend(pvVar1,sel_convertPoint_fromView_,pvVar2,extraout_EDX,0);
    local_14[0] = _objc_msgSend(pvVar1,sel_convertPointFromViewSpaceToUserSpace_,pvVar2,
                                extraout_EDX_00);
    pvVar1 = _objc_msgSend(self,sel_vectorAttributes);
    _objc_msgSend(pvVar1,sel_setHyperElementAtIndex_associatedPoints_,1,local_14);
  }
  return;
}

*/
- (void)handleMouseDragged:(id)aDragged
{
    if (_trackingObject != nil) {
        id view = [self view];
        NSPoint point = [view convertPoint:[(NSEvent *)aDragged locationInWindow] fromView:nil];
        point = [view convertPointFromViewSpaceToUserSpace:point];
        [[self vectorAttributes] setHyperElementAtIndex:1 associatedPoints:&point];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00041651 @ 00041651, 279 bytes * /

void FUN_00041651(HSLineTool *self,SEL _cmd,id handleMouseDown)

{
  id pvVar1;
  id pvVar2;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  undefined4 extraout_EDX_01;
  SEL op;
  
  op = sel_leaveTrackingObjectAndNotify_;
  if (self->_trackingObject == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_view);
    pvVar2 = _objc_msgSend(handleMouseDown,sel_locationInWindow);
    pvVar2 = _objc_msgSend(pvVar1,sel_convertPoint_fromView_,pvVar2,extraout_EDX,0);
    pvVar1 = _objc_msgSend(pvVar1,sel_convertPointFromViewSpaceToUserSpace_,pvVar2,extraout_EDX_00);
    _objc_msgSend(self,sel_createTrackingObjectAtPoint_,pvVar1,extraout_EDX_01);
    self = _objc_msgSend(self,sel_vectorAttributes);
    op = sel_appendHyperElement_associatedPoints_;
  }
  _objc_msgSend(self,op,1);
  return;
}

*/
- (void)handleMouseDown:(id)aDown
{
    if (_trackingObject == nil) {
        id view = [self view];
        NSPoint point = [view convertPoint:[(NSEvent *)aDown locationInWindow] fromView:nil];
        NSPoint points[3];
        points[0] = [view convertPointFromViewSpaceToUserSpace:point];
        points[1] = NSZeroPoint;
        points[2] = NSZeroPoint;
        [self createTrackingObjectAtPoint:points[0]];
        [[self vectorAttributes] appendHyperElement:1 associatedPoints:points];
    } else {
        [self leaveTrackingObjectAndNotify:YES];
    }
}

- (void)setView:(id)aView
{
    if ([self view] != aView) {
        [super setView:aView];
    }
}

- (id)defaultPath
{
    return [NSBezierPath hyperBezierPathWithString:@"M 0 0"];
}

- (BOOL)isObjectResizedScaledProportionally
{
    return NO;
}

- (BOOL)updatePrototypeWithDictionary:(id)aDictionary
{
    BOOL pvVar1;
    id pvVar2;

    pvVar1 = [super updatePrototypeWithDictionary:aDictionary];
    if ((pvVar1) && (pvVar2 = [self trackingObject], pvVar2 != nil) ) {
        pvVar2 = [self trackingObject];
        [pvVar2 loadExtraDictionaryRepresentation:aDictionary];
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000413b8 @ 000413b8, 614 bytes * /

void FUN_000413b8(HSLineTool *self,SEL _cmd,NSPoint createTrackingObjectAtPoint)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  float local_2c;
  float local_28;
  undefined4 local_24;
  undefined4 local_20;
  undefined4 local_1c;
  undefined4 local_18;
  
  if (self->_trackingObject != (id)0x0) {
    _objc_msgSend(self,sel_leaveTrackingObjectAndNotify_,1);
  }
  local_2c = createTrackingObjectAtPoint.x;
  local_28 = createTrackingObjectAtPoint.y;
  local_24 = *(undefined4 *)PTR_00336074;
  local_20 = *(undefined4 *)(PTR_00336074 + 4);
  local_1c = local_24;
  local_18 = local_20;
  pvVar1 = _objc_msgSend(self,sel_prototypeObject);
  pvVar1 = _objc_msgSend(pvVar1,sel_copy);
  pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  pvVar2 = _objc_msgSend(self,sel_defaultPath);
  pvVar3 = _objc_msgSend(pvVar1,sel_vg);
  pvVar3 = _objc_msgSend(pvVar3,sel_bezierPath);
  _objc_msgSend(pvVar2,sel_hyperCopyVisualAttributesFrom_,pvVar3);
  pvVar3 = _objc_msgSend(pvVar1,sel_vg);
  _objc_msgSend(pvVar3,sel_setBezierPath_,pvVar2);
  pvVar2 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00362dac);
  pvVar2 = _objc_msgSend(pvVar2,sel_queryGeometryBehaviorApplier);
  _objc_msgSend(pvVar2,sel_moveFrameBoundingRectOriginTo_withLayoutGuidingContext_,
                createTrackingObjectAtPoint.x,createTrackingObjectAtPoint.y,0);
  _objc_msgSend(pvVar1,sel_setShadowEnabled_,0);
  pvVar2 = _objc_msgSend(self,sel_isObjectResizedScaledProportionally);
  pvVar3 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00362dc0);
  _objc_msgSend(pvVar3,sel_setPrefersToMaintainSizeAspectRatio_,(int)(char)pvVar2);
  _objc_msgSend(pvVar3,sel_setPrefersToMaintainSizeScaleAspectRatio_,(int)(char)pvVar2);
  pvVar2 = _objc_msgSend(pvVar1,sel_vg);
  _objc_msgSend(pvVar2,sel_appendElement_associatedPoints_,0,&local_2c);
  _objc_msgSend(self,sel_setTrackingObject_,pvVar1);
  return;
}

*/
- (void)createTrackingObjectAtPoint:(NSPoint)aPoint
{
    if (_trackingObject != nil) {
        [self leaveTrackingObjectAndNotify:YES];
    }
    NSPoint points[3] = { aPoint, NSZeroPoint, NSZeroPoint };
    id object = [[[self prototypeObject] copy] autorelease];
    id path = [self defaultPath];
    [path hyperCopyVisualAttributesFrom:[[object vg] bezierPath]];
    [[object vg] setBezierPath:path];
    id geometry = [[object queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
    [geometry moveFrameBoundingRectOriginTo:aPoint withLayoutGuidingContext:nil];
    [object setShadowEnabled:NO];
    BOOL proportional = [self isObjectResizedScaledProportionally];
    id attributes = [object queryHyperInterface:@protocol(HSMutableGeometryBehaviorAttributes)];
    [attributes setPrefersToMaintainSizeAspectRatio:proportional];
    [attributes setPrefersToMaintainSizeScaleAspectRatio:proportional];
    [[object vg] appendElement:0 associatedPoints:points];
    [self setTrackingObject:object];
}

- (BOOL)leaveTrackingObjectAndNotify:(BOOL)aNotify
{
    return (BOOL)[self leaveTrackingObjectAndNotify:aNotify registerInCard:(unsigned int)(_trackingObject != nil) forceSwitchTool:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00041d20 @ 00041d20, 650 bytes * /

BOOL FUN_00041d20(HSLineTool *self,SEL _cmd,BOOL leaveTrackingObjectAndNotify,BOOL registerInCard,
                 BOOL forceSwitchTool)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  undefined4 uVar5;
  char local_45;
  undefined4 local_44;
  undefined4 local_40;
  undefined4 local_3c;
  undefined4 local_38;
  undefined4 local_34;
  undefined4 local_30;
  undefined4 local_2c;
  undefined4 local_28;
  undefined4 local_24;
  undefined4 local_20;
  undefined4 local_1c;
  undefined4 local_18;
  
  local_45 = registerInCard;
  if (self->_trackingObject != (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_view);
    pvVar2 = _objc_msgSend(pvVar2,sel_hyperObject);
    pvVar3 = _objc_msgSend(self,sel_vectorAttributes);
    pvVar4 = _objc_msgSend(pvVar3,sel_isHyperEmpty);
    if ((char)pvVar4 == '\0') {
      local_24 = 0;
      local_20 = 0;
      local_1c = 0;
      local_18 = 0;
      local_44 = *(undefined4 *)PTR_00336074;
      local_40 = *(undefined4 *)(PTR_00336074 + 4);
      local_3c = 0;
      local_38 = 0;
      local_34 = 0;
      local_30 = 0;
      local_2c = local_44;
      local_28 = local_40;
      pvVar4 = _objc_msgSend(pvVar3,sel_hyperElementCount);
      _objc_msgSend(pvVar3,sel_hyperElementAtIndex_associatedPoints_,(int)pvVar4 + -2,&local_2c);
      _objc_msgSend(pvVar3,sel_hyperElementAtIndex_associatedPoints_,(int)pvVar4 + -1,&local_44);
      uVar5 = local_40;
      cVar1 = _HSHitTestPoint(local_2c,local_28,local_44,local_40,0x40400000,0x40400000);
      if (cVar1 != '\0') {
        if ((int)pvVar4 < 3) {
          local_45 = '\0';
        }
        else {
          uVar5 = 0;
          _objc_msgSend(pvVar3,sel_deleteHyperElementAtIndex_glueWithEditingMode_,(int)pvVar4 + -1,0
                       );
        }
      }
      _objc_msgSend(self->_trackingObject,sel_setShadowEnabled_,1,uVar5);
      pvVar4 = _objc_msgSend(self->_trackingObject,sel_retain);
      pvVar3 = (id)0x0;
      _objc_msgSend(self,sel_setTrackingObject_,0);
      if (local_45 != '\0') {
        uVar5 = 0;
        pvVar3 = pvVar4;
        _objc_msgSend(pvVar2,sel_insertHyperChild_atIndex_,pvVar4,0);
      }
      _objc_msgSend(pvVar4,sel_release,pvVar3,uVar5);
    }
    else {
      local_45 = '\0';
    }
    _objc_msgSend(self,sel_setTrackingObject_,0);
    if (leaveTrackingObjectAndNotify != '\0' || forceSwitchTool != '\0') {
      _objc_msgSend(self,sel_notifyManagerAtomOperationPerformedWithResult_,
                    (uint)(forceSwitchTool != '\0' || local_45 != '\0'));
    }
  }
  return local_45;
}

*/
- (BOOL)leaveTrackingObjectAndNotify:(BOOL)aNotify registerInCard:(BOOL)aCard forceSwitchTool:(BOOL)aTool
{
    BOOL registered = aCard;
    if (_trackingObject != nil) {
        id card = [[self view] hyperObject];
        id vector = [self vectorAttributes];
        if (![vector isHyperEmpty]) {
            NSPoint previous[3] = { NSZeroPoint, NSZeroPoint, NSZeroPoint };
            NSPoint last[3] = { NSZeroPoint, NSZeroPoint, NSZeroPoint };
            NSUInteger count = [vector hyperElementCount];
            [vector hyperElementAtIndex:count - 2 associatedPoints:previous];
            [vector hyperElementAtIndex:count - 1 associatedPoints:last];
            if (HSHitTestPoint(previous[0], last[0], NSMakeSize(3.0, 3.0))) {
                if ((int)count < 3) {
                    registered = NO;
                } else {
                    [vector deleteHyperElementAtIndex:count - 1 glueWithEditingMode:0];
                }
            }
            [_trackingObject setShadowEnabled:YES];
            id object = [_trackingObject retain];
            [self setTrackingObject:nil];
            if (registered) {
                [card insertHyperChild:object atIndex:0];
            }
            [object release];
        } else {
            registered = NO;
        }
        [self setTrackingObject:nil];
        if (aNotify || aTool) {
            [self notifyManagerAtomOperationPerformedWithResult:(aTool || registered)];
        }
    }
    return registered;
    return 0;
}

- (void)objectDidChangeGeometry:(id)aGeometry
{
    [[self view] reflectObjectsDidRelayout];
}

- (id)vectorAttributes
{
    return [_trackingObject queryHyperInterface:@protocol(HSMutableVectorGraphicsAttributes)];
}

- (void)setTrackingObject:(id)aObject
{
    id self_00;
    id pvVar1;
    id pvVar1_2;

    pvVar1 = _trackingObject;
    if (pvVar1 != aObject) {
        self_00 = nil;
        if (pvVar1 != nil) {
            [self removeObjectFromPrototypeNodeSupport:pvVar1];
            [_visualizationCanvasLayer removeItemForNode:_trackingObject];
            self_00 = _trackingObject;
        }
        [self_00 release];
        _trackingObject = nil;
        if (aObject != nil) {
            pvVar1_2 = [aObject retain];
            _trackingObject = pvVar1_2;
            [self addObjectToPrototypeNodeSupport:pvVar1_2];
            [_visualizationCanvasLayer addItemForNode:_trackingObject];
        }
    }
}

- (id)trackingObject
{
    return _trackingObject;
}

- (id)visualizationCanvasLayer
{
    id pvVar1;

    pvVar1 = _visualizationCanvasLayer;
    if (pvVar1 == nil) {
        pvVar1 = [[HSAuxiliaryVisualizationCanvasLayer alloc] initForRenderingCardNodes:NO];
        _visualizationCanvasLayer = pvVar1;
        if (_trackingObject != nil) {
            [pvVar1 addItemForNode:_trackingObject];
            pvVar1 = _visualizationCanvasLayer;
        }
    }
    return pvVar1;
}

- (void)dealloc
{
    [_visualizationCanvasLayer release];
    [_trackingObject release];
    [super dealloc];
}

@end

