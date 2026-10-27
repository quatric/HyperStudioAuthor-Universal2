#import "HSVectorDrawingTool.h"

@implementation HSVectorDrawingTool

/* i386 ivar offsets: _visualizationCanvasLayer=0x28, _prototypeObject=0x2c, _prototypeNodeSupport=0x30, _trackingObject=0x34, _isTrackingObjectActive=0x38 */

+ (id)layerIdentifiersWithRootLayer:(id)aLayer
{
    return [aLayer vectorToolsIdentifiers];
}

+ (id)toolsCanvasLayerWithRootLayer:(id)aLayer
{
    return [aLayer vectorToolsCanvasLayer];
}

+ (Class)toolCanvasLayerClass
{
    return [HSVectorDrawingToolCanvasLayer class];
}

- (BOOL)tool:(id)aTool didFinalizeStage:(id)aStage withEvent:(id)aEvent nextStage:(id)aStage2
{
    BOOL pvVar1;

    pvVar1 = [super tool:aTool didFinalizeStage:aStage withEvent:aEvent nextStage:aStage2];
    if (aStage2 == nil) {
        [self finalizeObjectCreationAndNotify:YES];
    }
    return (BOOL)pvVar1;
}

- (void)finalizeObjectCreationAndNotify:(BOOL)aNotify
{
    id pvVar1_2;

    pvVar1_2 = [[self prepareTrackingObjectForAddingToCard] retain];
    if (_trackingObject != nil) {
        [self deactivateTrackingObjectIfNeeded];
        [_trackingObject release];
        _trackingObject = nil;
    }
    if (pvVar1_2 != nil) {
        [self addObjectToCard:pvVar1_2];
        [pvVar1_2 release];
    }
    if (aNotify != NO) {
        [self notifyManagerAtomOperationPerformedWithResult:(pvVar1_2 != nil)];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001f8384 @ 001f8384, 477 bytes * /

id FUN_001f8384(HSVectorDrawingTool *self,SEL _cmd)

{
  char cVar1;
  id self_00;
  id pvVar2;
  undefined4 local_4c;
  undefined4 local_48;
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
  undefined1 local_1c [8];
  float local_14;
  float local_10;
  
  if ((self->_trackingObject != (id)0x0) && (self->_isTrackingObjectActive != '\0')) {
    self_00 = _objc_msgSend(self,sel_vectorAttributes);
    pvVar2 = _objc_msgSend(self_00,sel_hyperBezierPath);
    _objc_msgSend_stret(local_1c,pvVar2,sel_hyperVisualBounds);
    pvVar2 = _objc_msgSend(self_00,sel_isHyperEmpty);
    if (((char)pvVar2 == '\0') && ((0.0 < local_14 && (0.0 < local_10)))) {
      local_2c = 0;
      local_28 = 0;
      local_24 = 0;
      local_20 = 0;
      local_4c = *(undefined4 *)PTR_00336074;
      local_48 = *(undefined4 *)(PTR_00336074 + 4);
      local_44 = 0;
      local_40 = 0;
      local_3c = 0;
      local_38 = 0;
      local_34 = local_4c;
      local_30 = local_48;
      pvVar2 = _objc_msgSend(self_00,sel_hyperElementCount);
      _objc_msgSend(self_00,sel_hyperElementAtIndex_associatedPoints_,(int)pvVar2 + -2,&local_34);
      _objc_msgSend(self_00,sel_hyperElementAtIndex_associatedPoints_,(int)pvVar2 + -1,&local_4c);
      cVar1 = _HSHitTestPoint(local_34,local_30,local_4c,local_48,0x40400000,0x40400000);
      if (cVar1 != '\0') {
        if ((int)pvVar2 < 3) {
          return (id)0x0;
        }
        _objc_msgSend(self_00,sel_deleteHyperElementAtIndex_glueWithEditingMode_,(int)pvVar2 + -1,0)
        ;
      }
      return self->_trackingObject;
    }
  }
  return (id)0x0;
}

*/
- (id)prepareTrackingObjectForAddingToCard
{
    if (_trackingObject != nil && _isTrackingObjectActive) {
        id vector = [self vectorAttributes];
        NSRect bounds = [[vector hyperBezierPath] hyperVisualBounds];
        if (![vector isHyperEmpty] && bounds.size.width > 0.0 && bounds.size.height > 0.0) {
            NSPoint last[3] = { NSZeroPoint, NSZeroPoint, NSZeroPoint };
            NSPoint previous[3] = { NSZeroPoint, NSZeroPoint, NSZeroPoint };
            NSUInteger count = [vector hyperElementCount];
            [vector hyperElementAtIndex:count - 2 associatedPoints:previous];
            [vector hyperElementAtIndex:count - 1 associatedPoints:last];
            if (HSHitTestPoint(previous[0], last[0], NSMakeSize(3.0, 3.0))) {
                if ((int)count < 3) {
                    return nil;
                }
                [vector deleteHyperElementAtIndex:count - 1 glueWithEditingMode:0];
            }
            return _trackingObject;
        }
    }
    return nil;
    return 0;
}

- (id)geometryAttributes
{
    return [_trackingObject queryHyperInterface:@protocol(HSMutableGeometryAttributes)];
}

- (id)vectorAttributes
{
    return [_trackingObject queryHyperInterface:@protocol(HSMutableVectorGraphicsAttributes)];
}

- (void)deactivateTrackingObjectIfNeeded
{
    if ((_trackingObject != nil) && (_isTrackingObjectActive != NO)) {
        _isTrackingObjectActive = NO;
        [_visualizationCanvasLayer removeItemForNode:_trackingObject];
    }
}

- (BOOL)createIfNeededAndActivateTrackingObject
{
    BOOL bVar2;

    bVar2 = _trackingObject == nil;
    if (bVar2) {
        _trackingObject = [[self prototypeObject] localCopyIncludingNodeUnits:YES];
    }
    if (_isTrackingObjectActive == NO) {
        _isTrackingObjectActive = YES;
        [[self visualizationCanvasLayer] addItemForNode:_trackingObject];
    }
    return bVar2;
}

- (id)trackingObject
{
    return _trackingObject;
}

- (id)prototypeObject
{
    id pvVar1;

    pvVar1 = _prototypeObject;
    if (pvVar1 == nil) {
        pvVar1 = [[[HSCreationToolSettingsProvider sharedInstance] userObjectPrototypeForToolIdentifier:[self primarySettingsIdentifier]] retain];
        _prototypeObject = pvVar1;
    }
    return pvVar1;
}

- (id)prototypeNodeSupport
{
    id pvVar1;

    pvVar1 = _prototypeNodeSupport;
    if (pvVar1 == nil) {
        pvVar1 = [[HSGenericNodeSupport nodeSupport] retain];
        _prototypeNodeSupport = pvVar1;
    }
    return pvVar1;
}

- (id)visualizationCanvasLayer
{
    id pvVar1;

    pvVar1 = _visualizationCanvasLayer;
    if (pvVar1 == nil) {
        pvVar1 = [[HSAuxiliaryVisualizationCanvasLayer alloc] initForRenderingCardNodes:NO];
        _visualizationCanvasLayer = pvVar1;
    }
    return pvVar1;
}

- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext
{
    id pvVar3;
    float fVar5;
    id pvVar1_2;
    id pvVar1_3;
    id pvVar2_2;

    [super loadExtraDictionaryRepresentation:aRepresentation withCodingContext:aContext];
    pvVar1_2 = [[self toolSettingsWrapper] settings];
    pvVar2_2 = [[self prototypeObject] queryHyperInterface:@protocol(HSVectorGraphicsAttributes)];
    pvVar3 = [pvVar1_2 objectForKey:@"drawColor"];
    if (pvVar3 != nil) {
        if (pvVar3 == [NSNull null]) {
            pvVar3 = nil;
        }
        [pvVar2_2 setHyperStrokeColor:pvVar3];
    }
    pvVar1_3 = [pvVar1_2 objectForKey:@"strokeWidth"];
    if (pvVar1_3 != nil) {
        pvVar3 = [NSNull null];
        if (pvVar1_3 == pvVar3) {
            fVar5 = 0.0;
        }
        else {
            fVar5 = (float)[pvVar1_3 floatValue];
        }
        [pvVar2_2 setHyperLineWidth:fVar5];
    }
}

- (void)didActivateExplicitly:(BOOL)aExplicitly
{
    id pvVar1_2;

    pvVar1_2 = [[self view] rootCanvasLayer];
    [[[self class] toolsCanvasLayerWithRootLayer:pvVar1_2] addSublayer:[self visualizationCanvasLayer]];
    [super didActivateExplicitly:aExplicitly];
}

- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly
{
    id pvVar1_2;

    pvVar1_2 = [[self view] rootCanvasLayer];
    [[[self class] toolsCanvasLayerWithRootLayer:pvVar1_2] removeSublayer:_visualizationCanvasLayer];
    [super finalizeBeforeDeactivateExplicitly:aExplicitly];
}

- (void)dealloc
{
    [_visualizationCanvasLayer release];
    [_prototypeNodeSupport release];
    [_prototypeObject release];
    [_trackingObject release];
    [super dealloc];
}

- (id)initWithBTTool:(id)aTool
{
    self = [super initWithBTTool:aTool];
    if (self == nil) {
        self = nil;
    }
    else {
        [aTool setViewInvalidationEnabled:NO];
    }
    return self;
}

@end

