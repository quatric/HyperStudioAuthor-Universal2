#import "HSDragShapeTool.h"

@implementation HSDragShapeTool

/* i386 ivar offsets: _trackingObject=0x18, _shapeCreationCanvasLayer=0x1c, _visualizationCanvasLayer=0x20 */

+ (Class)userObjectClass
{
    return [HSVectorGraphicsObject class];
}

- (void)didActivateExplicitly:(BOOL)aExplicitly
{
    id pvVar1_2;

    pvVar1_2 = [[self view] rootCanvasLayer];
    [[pvVar1_2 vectorToolsCanvasLayer] addSublayer:[self visualizationCanvasLayer]];
    [[pvVar1_2 vectorToolsCanvasLayer] addSublayer:[self shapeCreationCanvasLayer]];
    [pvVar1_2 setEnabledSublayerIdentifiers:[pvVar1_2 vectorToolsIdentifiers]];
    [super didActivateExplicitly:aExplicitly];
}

- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly
{
    id pvVar1_2;

    [super finalizeBeforeDeactivateExplicitly:aExplicitly];
    pvVar1_2 = [[self view] rootCanvasLayer];
    [[pvVar1_2 vectorToolsCanvasLayer] removeSublayer:_visualizationCanvasLayer];
    [[pvVar1_2 vectorToolsCanvasLayer] removeSublayer:_shapeCreationCanvasLayer];
    [pvVar1_2 setEnabledSublayerIdentifiers:nil];
}

- (void)dragShapeCreationLayer:(id)aLayer willCancelEditingObject:(id)aObject
{
    [self cancelObjectCreation];
}

- (void)dragShapeCreationLayer:(id)aLayer willFinishEditingObject:(id)aObject
{
    [self finalizeObjectCreationAndNotify:YES];
}

- (void)dragShapeCreationLayer:(id)aLayer didStartEditingObject:(id)aObject atUserPoint:(NSPoint)aPoint
{
    [self setTrackingObject:aObject];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000c0bd3 @ 000c0bd3, 244 bytes * /

BOOL FUN_000c0bd3(HSDragShapeTool *self,SEL _cmd,id dragShapeCreationLayer,
                 id shouldStartEditingObject,NSPoint atUserPoint)

{
  BOOL BVar1;
  id pvVar2;
  id pvVar3;
  undefined *puVar4;
  
  puVar4 = &DAT_0036b614;
  pvVar2 = _objc_msgSend(shouldStartEditingObject,sel_implementsHyperInterface_,&DAT_0036b614);
  if ((char)pvVar2 == '\0') {
    BVar1 = '\0';
  }
  else {
    pvVar2 = _objc_msgSend(cls_HSVectorGraphicsObject,sel_class,puVar4);
    pvVar3 = _objc_msgSend(shouldStartEditingObject,sel_isKindOfClass_,pvVar2);
    if (((char)pvVar3 == '\0') || (pvVar2 = _objc_msgSend(self,sel_view,pvVar2), pvVar2 == (id)0x0))
    {
      BVar1 = '\x01';
    }
    else {
      pvVar2 = _objc_msgSend(shouldStartEditingObject,sel_queryHyperInterface_,&DAT_0036b628);
      pvVar2 = _objc_msgSend(pvVar2,sel_queryGeometryBehaviorApplier);
      _objc_msgSend(pvVar2,sel_moveFrameBoundingRectOriginTo_withLayoutGuidingContext_,atUserPoint.x
                    ,atUserPoint.y,0);
      BVar1 = '\x01';
    }
  }
  return BVar1;
}

*/
- (BOOL)dragShapeCreationLayer:(id)aLayer shouldStartEditingObject:(id)aObject atUserPoint:(NSPoint)aPoint
{
    if (![aObject implementsHyperInterface:@protocol(HSNodeAttributes)]) {
        return NO;
    }
    if ([aObject isKindOfClass:[HSVectorGraphicsObject class]] && [self view] != nil) {
        [[[aObject queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier] moveFrameBoundingRectOriginTo:aPoint withLayoutGuidingContext:nil];
    }
    return YES;
    return 0;
}

- (BOOL)allowsToEditPrototypeObjectInterface:(id)aInterface
{
    if ((protocol_conformsToProtocol(aInterface,@protocol(HSVectorGraphicsAttributes))) == NO) {
        if ((protocol_conformsToProtocol(aInterface,@protocol(HSShadowAttributes))) == NO) {
            if ((protocol_conformsToProtocol(aInterface,@protocol(HSOpacityAttributes))) == NO) {
                if ((protocol_conformsToProtocol(aInterface,@protocol(HSBackgroundAttributes))) == NO) {
                    return (BOOL)[super allowsToEditPrototypeObjectInterface:aInterface];
                }
            }
        }
    }
    return YES;
}

- (void)finalizeObjectCreationAndNotify:(BOOL)aNotify
{
    id pvVar1_2;

    pvVar1_2 = [[self prepareTrackingObjectForAddingToCard] retain];
    [self setTrackingObject:nil];
    if (pvVar1_2 != nil) {
        [self addObjectToCard:pvVar1_2];
        [pvVar1_2 release];
    }
    if (aNotify != NO) {
        [self notifyManagerAtomOperationPerformedWithResult:(pvVar1_2 != nil)];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000c09e1 @ 000c09e1, 327 bytes * /

id FUN_000c09e1(HSDragShapeTool *self,SEL _cmd)

{
  float fVar1;
  id pvVar2;
  id pvVar3;
  float extraout_EDX;
  float fVar4;
  float fVar5;
  undefined *puVar6;
  
  if (self->_trackingObject != (id)0x0) {
    puVar6 = &DAT_0036b5b0;
    pvVar2 = _objc_msgSend(self->_trackingObject,sel_queryHyperInterface_,&DAT_0036b5b0);
    if (pvVar2 == (id)0x0) {
      return (id)0x0;
    }
    pvVar2 = _objc_msgSend(pvVar2,sel_size,puVar6);
    pvVar3 = _objc_msgSend(self,sel_toolIdentifier);
    if (((float)pvVar2 != 0.0) || (NAN((float)pvVar2))) {
      fVar5 = ABS((float)pvVar2);
    }
    else {
      fVar5 = 1.0;
    }
    fVar4 = 2.0;
    fVar1 = fVar4;
    if (2.0 <= fVar5) {
      fVar1 = fVar5;
    }
    fVar5 = fVar1 * -0.0005 + 2.0;
    if (pvVar3 == *(id *)PTR_PTR_00336140) {
      if (fVar5 <= (float)pvVar2) goto LAB_000c0ae9;
      if ((extraout_EDX != 0.0) || (NAN(extraout_EDX))) {
        fVar5 = ABS(extraout_EDX);
      }
      else {
        fVar5 = 1.0;
      }
      if (2.0 <= fVar5) {
        fVar4 = fVar5;
      }
    }
    else {
      if ((float)pvVar2 < fVar5) {
        return (id)0x0;
      }
      if ((extraout_EDX != 0.0) || (NAN(extraout_EDX))) {
        fVar5 = ABS(extraout_EDX);
      }
      else {
        fVar5 = 1.0;
      }
      if (2.0 <= fVar5) {
        fVar4 = fVar5;
      }
    }
    if (fVar4 * -0.0005 + 2.0 <= extraout_EDX) {
LAB_000c0ae9:
      return self->_trackingObject;
    }
  }
  return (id)0x0;
}

*/
- (id)prepareTrackingObjectForAddingToCard
{
    if (_trackingObject == nil) {
        return nil;
    }
    id sizeAttributes = [_trackingObject queryHyperInterface:@protocol(HSSizeAttributes)];
    if (sizeAttributes == nil) {
        return nil;
    }
    NSSize size = [sizeAttributes size];
    float scale = (size.width != 0.0f || size.width != size.width) ? fabsf(size.width) : 1.0f;
    float limit = 2.0f <= scale ? scale : 2.0f;
    float minimum = limit * -0.0005f + 2.0f;
    float heightScale;
    if ([[self toolIdentifier] isEqual:@"HSVectorLineTool"]) {
        if (minimum <= size.width) {
            return _trackingObject;
        }
    } else if (size.width < minimum) {
        return nil;
    }
    heightScale = (size.height != 0.0f || size.height != size.height) ? fabsf(size.height) : 1.0f;
    limit = 2.0f <= heightScale ? heightScale : 2.0f;
    if (limit * -0.0005f + 2.0f <= size.height) {
        return _trackingObject;
    }
    return nil;
    return 0;
}

- (void)cancelObjectCreation
{
    [self setTrackingObject:nil];
    [self notifyManagerAtomOperationPerformedWithResult:NO];
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

- (void)setPath:(id)aPath
{
    [[[self prototypeObject] queryHyperInterface:@protocol(HSMutableVectorGraphicsAttributes)] setHyperBezierPath:aPath];
}

- (id)path
{
    return [[[self prototypeObject] queryHyperInterface:@protocol(HSVectorGraphicsAttributes)] hyperBezierPath];
}

- (void)setFillColor:(id)aColor
{
    id self_00;
    id pvVar1_2;

    pvVar1_2 = [[self prototypeObject] queryHyperInterface:@protocol(HSMutableBackgroundAttributes)];
    if (aColor == nil) {
        self_00 = nil;
    }
    else {
        self_00 = [pvVar1_2 queryBackgroundGraphicsInterface:@protocol(HSMutableColor)];
    }
    [self_00 setHyperSolidColor:aColor];
    [pvVar1_2 setBackgroundGraphics:self_00];
}

- (id)fillColor
{
    return [[[[self prototypeObject] queryHyperInterface:@protocol(HSBackgroundGraphicsAttribute)] queryHyperInterface:@protocol(HSColor)] hyperSolidColor];
}

- (void)setStrokeWidth:(CGFloat)aWidth
{
    [[[self prototypeObject] queryHyperInterface:@protocol(HSMutableVectorGraphicsAttributes)] setHyperLineWidth:aWidth];
}

- (CGFloat)strokeWidth
{
    return (float)[[[self prototypeObject] queryHyperInterface:@protocol(HSVectorGraphicsAttributes)] hyperLineWidth];
}

- (void)setDrawColor:(id)aColor
{
    [[[self prototypeObject] queryHyperInterface:@protocol(HSMutableVectorGraphicsAttributes)] setHyperStrokeColor:aColor];
}

- (id)drawColor
{
    return [[[self prototypeObject] queryHyperInterface:@protocol(HSVectorGraphicsAttributes)] hyperStrokeColor];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000c11b6 @ 000c11b6, 238 bytes * /

id FUN_000c11b6(HSDragShapeTool *self,SEL _cmd)

{
  undefined *puVar1;
  id pvVar2;
  id self_00;
  undefined4 uVar3;
  undefined4 uVar4;
  undefined4 uVar5;
  HSDragShapeTool *local_1c;
  undefined *local_18;
  
  puVar1 = PTR_PTR_003360fc;
  pvVar2 = _objc_msgSend(self,sel_primarySettingsIdentifier);
  if (pvVar2 == *(id *)puVar1) {
    uVar4 = *(undefined4 *)PTR_0033647c;
    uVar3 = *(undefined4 *)PTR_00336470;
    uVar5 = 0;
  }
  else {
    uVar5 = *(undefined4 *)PTR_00336474;
    uVar4 = *(undefined4 *)PTR_0033647c;
    uVar3 = *(undefined4 *)PTR_00336470;
  }
  pvVar2 = _objc_msgSend(cls_NSArray,sel_arrayWithObjects_,uVar3,uVar4,uVar5);
  local_1c = self;
  local_18 = PTR_s_HSCreationTool_0034faf0;
  self_00 = _objc_msgSendSuper(&local_1c,sel_settingsIdentifiers);
  pvVar2 = _objc_msgSend(self_00,sel_arrayByAddingObjectsFromArray_,pvVar2);
  return pvVar2;
}

*/
- (id)settingsIdentifiers
{
    NSArray *own;
    if ([[self primarySettingsIdentifier] isEqual:@"HSLineTool"]) {
        own = [NSArray arrayWithObjects:HSToolDrawColorAttributeKey, HSToolStrokeWidthAttributeKey, nil];
    } else {
        own = [NSArray arrayWithObjects:HSToolDrawColorAttributeKey, HSToolStrokeWidthAttributeKey, HSToolFillColorAttributeKey, nil];
    }
    return [[super settingsIdentifiers] arrayByAddingObjectsFromArray:own];
    return 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000c12a4 @ 000c12a4, 208 bytes * /

id FUN_000c12a4(HSDragShapeTool *self,SEL _cmd)

{
  undefined *puVar1;
  undefined *puVar2;
  id pvVar3;
  undefined4 *puVar4;
  HSDragShapeTool *local_1c;
  undefined *local_18;
  
  puVar1 = PTR_PTR_00336140;
  pvVar3 = _objc_msgSend(self,sel_toolIdentifier);
  puVar2 = PTR_PTR_00336138;
  puVar4 = (undefined4 *)PTR_PTR_003360fc;
  if ((((pvVar3 == *(id *)puVar1) ||
       (pvVar3 = _objc_msgSend(self,sel_toolIdentifier), puVar1 = PTR_PTR_00336134,
       puVar4 = (undefined4 *)PTR_PTR_003360b0, pvVar3 == *(id *)puVar2)) ||
      (pvVar3 = _objc_msgSend(self,sel_toolIdentifier), puVar2 = PTR_PTR_0033613c,
      puVar4 = (undefined4 *)PTR_PTR_003360ac, pvVar3 == *(id *)puVar1)) ||
     (pvVar3 = _objc_msgSend(self,sel_toolIdentifier), puVar4 = (undefined4 *)PTR_PTR_003360b4,
     pvVar3 == *(id *)puVar2)) {
    pvVar3 = (id)*puVar4;
  }
  else {
    local_1c = self;
    local_18 = PTR_s_HSCreationTool_0034faf0;
    pvVar3 = _objc_msgSendSuper(&local_1c,sel_primarySettingsIdentifier);
  }
  return pvVar3;
}

*/
- (id)primarySettingsIdentifier
{
    if ([[self toolIdentifier] isEqual:@"HSVectorLineTool"]) {
        return @"HSLineTool";
    }
    if ([[self toolIdentifier] isEqual:@"HSVectorDragRectTool"]) {
        return @"HSDragRectTool";
    }
    if ([[self toolIdentifier] isEqual:@"HSVectorDragCircleTool"]) {
        return @"HSDragCircleTool";
    }
    if ([[self toolIdentifier] isEqual:@"HSVectorDragRoundedRectTool"]) {
        return @"HSDragRoundedRectTool";
    }
    return [super primarySettingsIdentifier];
    return 0;
}

- (id)localizedObjectKindName
{
    return [[self prototypeObject] objectKindName];
}

- (void)saveChangesAndNotify:(BOOL)aNotify
{
    [self finalizeObjectCreationAndNotify:aNotify];
}

- (BOOL)allowsActiveInPlaceEditors
{
    return NO;
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

- (id)shapeCreationCanvasLayer
{
    id pvVar1;
    id pvVar1_3;

    pvVar1 = _shapeCreationCanvasLayer;
    if (pvVar1 == nil) {
        pvVar1_3 = [[HSDragShapeCreationCanvasLayer alloc] init];
        _shapeCreationCanvasLayer = pvVar1_3;
        [pvVar1_3 setDelegate:self];
        [_shapeCreationCanvasLayer setPrototypeObject:[self prototypeObject]];
        pvVar1 = _shapeCreationCanvasLayer;
    }
    return pvVar1;
}

- (void)dealloc
{
    [_visualizationCanvasLayer release];
    [_shapeCreationCanvasLayer setDelegate:0];
    [_shapeCreationCanvasLayer release];
    if (_trackingObject != nil) {
        [_trackingObject release];
    }
    [super dealloc];
}

@end

