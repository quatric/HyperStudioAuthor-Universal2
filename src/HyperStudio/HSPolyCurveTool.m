#import "HSPolyCurveTool.h"

@implementation HSPolyCurveTool

/* i386 ivar offsets: _trackingObject=0x18, _pathCreationCanvasLayer=0x1c, _visualizationCanvasLayer=0x20, _isStraightLineMode=0x24, _isShapeTool=0x25 */

+ (Class)userObjectClass
{
    return [HSVectorGraphicsObject class];
}

- (void)didActivateExplicitly:(BOOL)aExplicitly
{
    id pvVar1_2;

    pvVar1_2 = [[self view] rootCanvasLayer];
    [[pvVar1_2 vectorToolsCanvasLayer] addSublayer:[self visualizationCanvasLayer]];
    [[pvVar1_2 vectorToolsCanvasLayer] addSublayer:[self pathCreationCanvasLayer]];
    [pvVar1_2 setEnabledSublayerIdentifiers:[pvVar1_2 vectorToolsIdentifiers]];
    [super didActivateExplicitly:aExplicitly];
}

- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly
{
    id pvVar1_2;

    [super finalizeBeforeDeactivateExplicitly:aExplicitly];
    pvVar1_2 = [[self view] rootCanvasLayer];
    [[pvVar1_2 vectorToolsCanvasLayer] removeSublayer:_visualizationCanvasLayer];
    [[pvVar1_2 vectorToolsCanvasLayer] removeSublayer:_pathCreationCanvasLayer];
    [pvVar1_2 setEnabledSublayerIdentifiers:nil];
}

- (void)bezierPathCreationLayer:(id)aLayer willCancelEditingObject:(id)aObject
{
    [self cancelObjectCreation];
}

- (void)bezierPathCreationLayer:(id)aLayer willFinishEditingObject:(id)aObject
{
    [self finalizeObjectCreationAndNotify:YES];
}

- (void)bezierPathCreationLayer:(id)aLayer didStartEditingObject:(id)aObject atUserPoint:(NSPoint)aPoint
{
    [self setTrackingObject:aObject];
}

- (BOOL)bezierPathCreationLayer:(id)aLayer shouldStartEditingObject:(id)aObject atUserPoint:(NSPoint)aPoint
{
    BOOL BVar1;
    id pvVar2_6;

    if (![aObject implementsHyperInterface:@protocol(HSNodeAttributes)]) {
        BVar1 = NO;
    }
    else {
        if (![aObject isKindOfClass:[HSVectorGraphicsObject class]]) {
            BVar1 = YES;
        }
        else {
            if ([self view] != nil) {
                [[[aObject queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier] moveFrameBoundingRectOriginTo:aPoint withLayoutGuidingContext:nil];
            }
            [aObject setShadowEnabled:NO];
            pvVar2_6 = [aObject queryHyperInterface:@protocol(HSMutableGeometryBehaviorAttributes)];
            [pvVar2_6 setPrefersToMaintainSizeAspectRatio:YES];
            [pvVar2_6 setPrefersToMaintainSizeScaleAspectRatio:YES];
            BVar1 = YES;
        }
    }
    return BVar1;
}

- (BOOL)allowsToEditPrototypeObjectInterface:(id)aInterface
{
    char cVar2_4;

    if ((protocol_conformsToProtocol(aInterface,@protocol(HSVectorGraphicsAttributes))) == NO) {
        if ((protocol_conformsToProtocol(aInterface,@protocol(HSShadowAttributes))) == NO) {
            if ((protocol_conformsToProtocol(aInterface,@protocol(HSOpacityAttributes))) == NO) {
                if (_isShapeTool != NO) {
                    cVar2_4 = protocol_conformsToProtocol(aInterface,@protocol(HSBackgroundAttributes))
                    ;
                    if (cVar2_4 != NO) {
                        return YES;
                    }
                }
                return (BOOL)[super allowsToEditPrototypeObjectInterface:aInterface];
            }
        }
    }
    return YES;
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

- (void)cancelObjectCreation
{
    [self setTrackingObject:nil];
    [self notifyManagerAtomOperationPerformedWithResult:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0004f643 @ 0004f643, 407 bytes * /

id FUN_0004f643(HSPolyCurveTool *self,SEL _cmd)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  undefined4 uVar4;
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
  
  if (self->_trackingObject != (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_vectorAttributes);
    pvVar3 = _objc_msgSend(pvVar2,sel_isHyperEmpty);
    if ((char)pvVar3 == '\0') {
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
      pvVar3 = _objc_msgSend(pvVar2,sel_hyperElementCount);
      _objc_msgSend(pvVar2,sel_hyperElementAtIndex_associatedPoints_,(int)pvVar3 + -2,&local_2c);
      _objc_msgSend(pvVar2,sel_hyperElementAtIndex_associatedPoints_,(int)pvVar3 + -1,&local_44);
      uVar4 = local_40;
      cVar1 = _HSHitTestPoint(local_2c,local_28,local_44,local_40,0x40400000,0x40400000);
      if (cVar1 != '\0') {
        if ((int)pvVar3 < 3) {
          return (id)0x0;
        }
        uVar4 = 0;
        _objc_msgSend(pvVar2,sel_deleteHyperElementAtIndex_glueWithEditingMode_,(int)pvVar3 + -1,0);
      }
      pvVar2 = self->_trackingObject;
      _objc_msgSend(pvVar2,sel_setShadowEnabled_,1,uVar4);
      return pvVar2;
    }
  }
  return (id)0x0;
}

*/
- (id)prepareTrackingObjectForAddingToCard
{
    if (_trackingObject != nil) {
        id vector = [self vectorAttributes];
        if (![vector isHyperEmpty]) {
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
            [_trackingObject setShadowEnabled:YES];
            return _trackingObject;
        }
    }
    return nil;
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

- (void)prototypeObjectDidChange
{
    [self updatePrototypeWithObjectKindName];
    [[self prototypeObject] notifyChange:2 ofAttribute:@protocol(HSVisualAttribute) withUserInfo:nil];
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
    return [[HSUserObjectDefaultAttributesProvider sharedInstance] nonLocalizedKindNameForVectorGraphicsObjectIfClosed:_isShapeTool straightLineMode:_isStraightLineMode];
}

- (BOOL)prototypeHasClosedPath
{
    return NO;
}

- (void)saveChangesAndNotify:(BOOL)aNotify
{
    [self finalizeObjectCreationAndNotify:aNotify];
}

- (BOOL)allowsActiveInPlaceEditors
{
    return NO;
}

- (NSUInteger)currentPointIndex
{
    return (int)[[self vectorAttributes] hyperElementCount] - 1;
}

- (NSInteger)editingMode
{
    return (unsigned int)(![self isStraightLineMode]);
}

- (void)setShapeTool:(BOOL)aTool
{
    _isShapeTool = aTool;
    if ([self hasCreatedPrototypeObject]) {
        [self updatePrototypeWithObjectKindName];
    }
}

- (BOOL)isShapeTool
{
    return _isShapeTool;
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

- (id)pathCreationCanvasLayer
{
    id pvVar1;
    id pvVar1_3;

    pvVar1 = _pathCreationCanvasLayer;
    if (pvVar1 == nil) {
        pvVar1_3 = [[HSBezierPathCreationCanvasLayer alloc] init];
        _pathCreationCanvasLayer = pvVar1_3;
        [pvVar1_3 setDelegate:self];
        [_pathCreationCanvasLayer setPrototypeObject:[self prototypeObject]];
        [_pathCreationCanvasLayer setStraightLineMode:[self isStraightLineMode]];
        [_pathCreationCanvasLayer setCreatesClosedPathByDefault:_isShapeTool];
        pvVar1 = _pathCreationCanvasLayer;
    }
    return pvVar1;
}

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(performIdleMouseAutoscroll) object:nil];
    [_visualizationCanvasLayer release];
    [_pathCreationCanvasLayer setDelegate:0];
    [_pathCreationCanvasLayer release];
    if (_trackingObject != nil) {
        [_trackingObject release];
    }
    [super dealloc];
}

@end

