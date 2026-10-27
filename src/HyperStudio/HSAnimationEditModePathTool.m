#import "HSAnimationEditModePathTool.h"

@implementation HSAnimationEditModePathTool

/* i386 ivar offsets: _dataSource=0x10, _creating=0x14, _objectToAnimate=0x18, _originalObjectToAnimate=0x1c, _prototypeObject=0x20, _creationObject=0x24, _pathObject=0x28, _visualizationCanvasLayer=0x2c, _pathCanvasItem=0x30, _creationCanvasLayer=0x34, _selectionCanvasLayer=0x38 */

- (void)startTrackingWithMouseDownEvent:(id)aEvent
{
    [[self creationCanvasLayer] handleMouseDownAtPoint:NSZeroPoint event:aEvent hitTestInfo:nil];
}

- (void)setSelectedSegments:(NSRange)aSegments
{
    [[self pathCanvasItem] setSelectedSegments:aSegments];
}

- (BOOL)isCreatingTrajectory
{
    return _creating;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000b170e @ 000b170e, 331 bytes * /

void FUN_000b170e(HSAnimationEditModePathTool *self,SEL _cmd)

{
  id pvVar1;
  undefined4 *puVar2;
  undefined1 local_24 [20];
  
  puVar2 = (undefined4 *)&stack0xffffffc4;
  _objc_msgSend(self,sel_cleanUpSelectionCanvasLayer);
  _objc_msgSend(self,sel_cleanUpCreationCanvasLayer);
  _objc_msgSend(self,sel_setPathObject_);
  pvVar1 = _objc_msgSend(self,sel_dataSource);
  pvVar1 = _objc_msgSend(pvVar1,sel_pathToolHasPath_);
  if ((char)pvVar1 == '\0') {
    self->_creating = '\x01';
  }
  else {
    self->_creating = '\0';
    pvVar1 = _objc_msgSend(self,sel_dataSource);
    pvVar1 = _objc_msgSend(pvVar1,sel_pathToolPath_);
    _objc_msgSend_stret(local_24,pvVar1,sel_bounds);
    puVar2 = (undefined4 *)&stack0xffffffc0;
    _objc_msgSend(pvVar1,sel_hyperBasePointOfElementAtIndex_);
    _objc_msgSend(self,sel_dataSource);
  }
  puVar2[-1] = 0xb182d;
  _objc_msgSend((id)*puVar2,(SEL)puVar2[1]);
  puVar2[1] = sel_view;
  *puVar2 = self;
  puVar2[-1] = 0xb183f;
  pvVar1 = _objc_msgSend((id)*puVar2,(SEL)puVar2[1]);
  puVar2[1] = sel_reflectObjectsDidRelayout;
  *puVar2 = pvVar1;
  puVar2[-1] = 0xb1851;
  _objc_msgSend((id)*puVar2,(SEL)puVar2[1]);
  return;
}

*/
- (void)pathDidChange
{
    [self cleanUpSelectionCanvasLayer];
    [self cleanUpCreationCanvasLayer];
    [self setPathObject:nil];
    if (![[self dataSource] pathToolHasPath:self]) {
        _creating = YES;
        [self setUpCreationCanvasLayer];
    } else {
        _creating = NO;
        [[self dataSource] pathToolObjectPositionAtZeroTime:self];
    }
    [[self view] reflectObjectsDidRelayout];
}

- (void)objectToAnimateDidChangeTo:(id)aTo original:(id)aOriginal
{
    if (_objectToAnimate != nil) {
        [[self visualizationCanvasLayer] removeItemForNode:_objectToAnimate];
    }
    if (_originalObjectToAnimate != nil) {
        [[self view] reenableVisualizationForNode:_originalObjectToAnimate];
    }
    _objectToAnimate = aTo;
    _originalObjectToAnimate = aOriginal;
    if (aTo != nil) {
        [[self visualizationCanvasLayer] addItemForNode:_objectToAnimate];
        [[self view] disableVisualizationForNode:_objectToAnimate];
        aOriginal = _originalObjectToAnimate;
    }
    if (aOriginal != nil) {
        [[self view] disableVisualizationForNode:_originalObjectToAnimate];
    }
    if (_objectToAnimate != nil) {
        [self pathDidChange];
    }
}

- (id)originalObjectToAnimate
{
    return _originalObjectToAnimate;
}

- (id)objectToAnimate
{
    return _objectToAnimate;
}

- (void)setDataSource:(id)aSource
{
    _dataSource = aSource;
}

- (id)dataSource
{
    return _dataSource;
}

- (void)objectKnobsCanvasLayerDidFinishTrackingKnob:(id)aKnob
{
    id pvVar1_2;

    pvVar1_2 = [[self pathObject] bezierPath];
    [[self dataSource] pathTool:self stopChangingPath:pvVar1_2 changeObjectPosition:0];
    [[self view] reflectObjectsDidRelayout];
}

- (void)objectKnobsCanvasLayerWillStartTrackingKnob:(id)aKnob
{
    id pvVar1_2;

    pvVar1_2 = [[self pathObject] bezierPath];
    [[self dataSource] pathTool:self startChangingPath:pvVar1_2 changeObjectPosition:0];
    [[self view] reflectObjectsDidRelayout];
}

- (void)bezierPathCreationLayer:(id)aLayer willCancelEditingObject:(id)aObject
{

}

- (void)bezierPathCreationLayer:(id)aLayer willFinishEditingObject:(id)aObject
{
    [self setCreationObject:nil];
    [self setPathObject:aObject];
    [self cleanUpCreationCanvasLayer];
    _creating = NO;
    [self setUpSelectionCanvasLayer];
    [[self dataSource] pathToolDidFinishCreation:self restart:0];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000b1b56 @ 000b1b56, 198 bytes * /

void FUN_000b1b56(HSAnimationEditModePathTool *self,SEL _cmd,id bezierPathCreationLayer,
                 id didStartEditingObject,NSPoint atUserPoint)

{
  id self_00;
  id self_01;
  id local_2c [2];
  undefined4 local_24;
  undefined4 local_20;
  undefined4 local_1c;
  undefined4 local_18;
  
  self_00 = _objc_msgSend(didStartEditingObject,sel_queryHyperInterface_,&DAT_00369f30);
  self_01 = _objc_msgSend(self,sel_dataSource);
  local_2c[0] = _objc_msgSend(self_01,sel_pathToolObjectPositionAtZeroTime_,self);
  local_24 = *(undefined4 *)PTR_00336074;
  local_20 = *(undefined4 *)(PTR_00336074 + 4);
  local_1c = local_24;
  local_18 = local_20;
  _objc_msgSend(self_00,sel_setHyperElementAtIndex_associatedPoints_,0,local_2c);
  _objc_msgSend(self,sel_setCreationObject_,didStartEditingObject);
  return;
}

*/
- (void)bezierPathCreationLayer:(id)aLayer didStartEditingObject:(id)aObject atUserPoint:(NSPoint)aPoint
{
    id<HSMutableVectorGraphicsAttributes> attributes = [aObject queryHyperInterface:@protocol(HSMutableVectorGraphicsAttributes)];
    NSPoint points[3];
    points[0] = ((NSPoint (*)(id, SEL, id))objc_msgSend)([self dataSource], @selector(pathToolObjectPositionAtZeroTime:), self);
    points[1] = NSZeroPoint;
    points[2] = NSZeroPoint;
    [attributes setHyperElementAtIndex:0 associatedPoints:points];
    [self setCreationObject:aObject];
}

- (BOOL)bezierPathCreationLayer:(id)aLayer shouldStartEditingObject:(id)aObject atUserPoint:(NSPoint)aPoint
{
    return YES;
}

- (void)freehandPathCreationLayer:(id)aLayer willCancelEditingObject:(id)aObject
{

}

- (void)freehandPathCreationLayer:(id)aLayer willFinishEditingObject:(id)aObject restart:(BOOL)aRestart
{
    [self setCreationObject:nil];
    [self setPathObject:aObject];
    [self cleanUpCreationCanvasLayer];
    _creating = NO;
    [self setUpSelectionCanvasLayer];
    [[self dataSource] pathToolDidFinishCreation:self restart:(int)aRestart];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000b1cbf @ 000b1cbf, 86 bytes * /

void FUN_000b1cbf(HSAnimationEditModePathTool *self,SEL _cmd,id freehandPathCreationLayer,
                 id continueEditingObject,NSPoint atUserPoint)

{
  id self_00;
  
  self_00 = _objc_msgSend(self,sel_dataSource);
  _objc_msgSend(self_00,sel_pathTool_setObjectPosition_,self,atUserPoint.x,atUserPoint.y);
  return;
}

*/
- (void)freehandPathCreationLayer:(id)aLayer continueEditingObject:(id)aObject atUserPoint:(NSPoint)aPoint
{
    [[self dataSource] pathTool:self setObjectPosition:aPoint];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000b1d15 @ 000b1d15, 173 bytes * /

void FUN_000b1d15(HSAnimationEditModePathTool *self,SEL _cmd,id freehandPathCreationLayer,
                 id didStartEditingObject,NSPoint atUserPoint)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_dataSource);
  _objc_msgSend(pvVar1,sel_pathTool_setObjectPosition_,self,atUserPoint.x,atUserPoint.y);
  pvVar1 = _objc_msgSend(self,sel_dataSource);
  _objc_msgSend(pvVar1,sel_pathTool_startPathAtPosition_,self,atUserPoint.x,atUserPoint.y);
  _objc_msgSend(self,sel_setCreationObject_,didStartEditingObject);
  return;
}

*/
- (void)freehandPathCreationLayer:(id)aLayer didStartEditingObject:(id)aObject atUserPoint:(NSPoint)aPoint
{
    [[self dataSource] pathTool:self setObjectPosition:aPoint];
    [[self dataSource] pathTool:self startPathAtPosition:aPoint];
    [self setCreationObject:aObject];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000b1dc2 @ 000b1dc2, 86 bytes * /

void FUN_000b1dc2(HSAnimationEditModePathTool *self,SEL _cmd,id freehandPathCreationLayer,
                 NSPoint setObjectPosition)

{
  id self_00;
  
  self_00 = _objc_msgSend(self,sel_dataSource);
  _objc_msgSend(self_00,sel_pathTool_setObjectPosition_,self,setObjectPosition.x,setObjectPosition.y
               );
  return;
}

*/
- (void)freehandPathCreationLayer:(id)aLayer setObjectPosition:(NSPoint)aPosition
{
    [[self dataSource] pathTool:self setObjectPosition:aPosition];
}

- (void)cleanUpSelectionCanvasLayer
{
    if (_selectionCanvasLayer != nil) {
        [[[[self view] rootCanvasLayer] vectorToolsCanvasLayer] removeSublayer:_selectionCanvasLayer];
        [_selectionCanvasLayer setDelegate:0];
        [_selectionCanvasLayer release];
        _selectionCanvasLayer = nil;
    }
}

- (void)setUpSelectionCanvasLayer
{
    [[[[self view] rootCanvasLayer] vectorToolsCanvasLayer] addSublayer:[self selectionCanvasLayer]];
}

- (id)selectionCanvasLayer
{
    id pvVar1;
    id pvVar1_4;

    pvVar1 = _selectionCanvasLayer;
    if (pvVar1 == nil) {
        pvVar1_4 = [[HSVectorGraphicsKnobsCanvasLayer knobsLayerWithHyperObject:[self pathObject]] retain];
        _selectionCanvasLayer = pvVar1_4;
        [pvVar1_4 setDelegate:self];
        pvVar1 = _selectionCanvasLayer;
    }
    return pvVar1;
}

- (void)cleanUpCreationCanvasLayer
{
    if (_creationCanvasLayer != nil) {
        [[[[self view] rootCanvasLayer] vectorToolsCanvasLayer] removeSublayer:_creationCanvasLayer];
        [_creationCanvasLayer setDelegate:0];
        [_creationCanvasLayer autorelease];
        _creationCanvasLayer = nil;
    }
}

- (void)setUpCreationCanvasLayer
{
    [[[[self view] rootCanvasLayer] vectorToolsCanvasLayer] addSublayer:[self creationCanvasLayer]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000b20dd @ 000b20dd, 259 bytes * /

id FUN_000b20dd(HSAnimationEditModePathTool *self,SEL _cmd)

{
  id pvVar1;
  undefined *self_00;
  id pvVar2;
  
  if (self->_creationCanvasLayer == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_useFreehand);
    self_00 = cls_HSBezierPathCreationCanvasLayer;
    if ((char)pvVar1 != '\0') {
      self_00 = cls_HSFreehandPathCreationCanvasLayer;
    }
    pvVar1 = _objc_msgSend(self_00,sel_alloc);
    pvVar1 = _objc_msgSend(pvVar1,sel_init);
    self->_creationCanvasLayer = pvVar1;
    _objc_msgSend(pvVar1,sel_setDelegate_,self);
    pvVar1 = self->_creationCanvasLayer;
    pvVar2 = _objc_msgSend(self,sel_prototypeObject);
    _objc_msgSend(pvVar1,sel_setPrototypeObject_,pvVar2);
    pvVar1 = _objc_msgSend(self,sel_useFreehand);
    if ((char)pvVar1 == '\0') {
      _objc_msgSend(self->_creationCanvasLayer,sel_setStraightLineMode_,0);
      _objc_msgSend(self->_creationCanvasLayer,sel_setCreatesClosedPathByDefault_,0);
    }
  }
  return self->_creationCanvasLayer;
}

*/
- (id)creationCanvasLayer
{
    if (_creationCanvasLayer == nil) {
        Class layerClass = [self useFreehand] ? [HSFreehandPathCreationCanvasLayer class] : [HSBezierPathCreationCanvasLayer class];
        _creationCanvasLayer = [[layerClass alloc] init];
        [_creationCanvasLayer setDelegate:self];
        [_creationCanvasLayer setPrototypeObject:[self prototypeObject]];
        if (![self useFreehand]) {
            [_creationCanvasLayer setStraightLineMode:NO];
            [_creationCanvasLayer setCreatesClosedPathByDefault:NO];
        }
    }
    return _creationCanvasLayer;
    return 0;
}

- (id)pathCanvasItem
{
    id pvVar1;

    pvVar1 = _pathCanvasItem;
    if (pvVar1 == nil) {
        pvVar1 = [[HSAnimationPathCanvasItem alloc] init];
        _pathCanvasItem = pvVar1;
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

- (void)pathObjectPathDidChange:(id)aChange
{
    id pvVar1_2;

    pvVar1_2 = [[aChange object] bezierPath];
    [[self dataSource] pathTool:self continueChangingPath:pvVar1_2 changeObjectPosition:0];
    [[self view] reflectObjectsDidRelayout];
}

- (void)setPathObject:(id)aObject
{
    id self_00;
    id pvVar1;
    id pvVar1_2;

    pvVar1 = _pathObject;
    if (pvVar1 != aObject) {
        self_00 = nil;
        if (pvVar1 != nil) {
            [pvVar1 removeObserver:self selector:@selector(pathObjectPathDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSGeometryAttribute)];
            self_00 = _pathObject;
        }
        [self_00 release];
        pvVar1_2 = [aObject copy];
        _pathObject = pvVar1_2;
        if (pvVar1_2 != nil) {
            [pvVar1_2 addObserver:self selector:@selector(pathObjectPathDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSGeometryAttribute) withPriority:0];
        }
    }
    [[self pathCanvasItem] setPathObject:_pathObject];
}

- (id)pathObject
{
    return _pathObject;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000b2421 @ 000b2421, 236 bytes * /

void FUN_000b2421(HSAnimationEditModePathTool *self,SEL _cmd,id creationObjectPathDidChange)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  SEL op;
  
  pvVar1 = _objc_msgSend(creationObjectPathDidChange,sel_object);
  pvVar1 = _objc_msgSend(pvVar1,sel_bezierPath);
  pvVar2 = _objc_msgSend(pvVar1,sel_elementCount);
  if (1 < (int)pvVar2) {
    pvVar2 = _objc_msgSend(self,sel_useFreehand);
    self_00 = _objc_msgSend(self,sel_dataSource);
    op = sel_pathTool_setBezierPathAndGenerateKeyFrames_;
    if ((char)pvVar2 != '\0') {
      pvVar2 = _objc_msgSend(self,sel_creationCanvasLayer);
      _objc_msgSend(pvVar2,sel_keyFrames);
      op = sel_pathTool_setFreehandPath_keyFrames_;
    }
    _objc_msgSend(self_00,op,self,pvVar1);
  }
  return;
}

*/
- (void)creationObjectPathDidChange:(id)aChange
{
    id path = [[aChange object] bezierPath];
    if ([path elementCount] > 1) {
        if ([self useFreehand]) {
            [[self dataSource] pathTool:self setFreehandPath:path keyFrames:[[self creationCanvasLayer] keyFrames]];
        } else {
            [[self dataSource] pathTool:self setBezierPathAndGenerateKeyFrames:path];
        }
    }
}

- (void)setCreationObject:(id)aObject
{
    id self_00;
    id pvVar1;
    id pvVar1_2;

    pvVar1 = _creationObject;
    if (pvVar1 != aObject) {
        self_00 = nil;
        if (pvVar1 != nil) {
            [pvVar1 removeObserver:self selector:@selector(creationObjectPathDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSGeometryAttribute)];
            self_00 = _creationObject;
        }
        [self_00 release];
        pvVar1_2 = [aObject retain];
        _creationObject = pvVar1_2;
        if (pvVar1_2 != nil) {
            [pvVar1_2 addObserver:self selector:@selector(creationObjectPathDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSGeometryAttribute) withPriority:0];
        }
    }
    [[self pathCanvasItem] setPathObject:_creationObject];
}

- (id)creationObject
{
    return _creationObject;
}

- (id)prototypeObject
{
    id pvVar1;

    pvVar1 = _prototypeObject;
    if (pvVar1 == nil) {
        pvVar1 = [[HSAnimationEditModePathObject alloc] init];
        _prototypeObject = pvVar1;
    }
    return pvVar1;
}

- (BOOL)useFreehand
{
    return [[self dataSource] pathToolPathCreationMode:self] == nil;
}

- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly
{
    id pvVar1_2;

    [self objectToAnimateDidChangeTo:nil original:nil];
    [self setDataSource:0];
    pvVar1_2 = [[self view] rootCanvasLayer];
    [[pvVar1_2 vectorToolsCanvasLayer] removeAllSublayers];
    [pvVar1_2 setEnabledSublayerIdentifiers:nil];
    [super finalizeBeforeDeactivateExplicitly:aExplicitly];
}

- (void)didActivateExplicitly:(BOOL)aExplicitly
{
    id pvVar1_3;
    id pvVar2_3;

    [super didActivateExplicitly:aExplicitly];
    pvVar1_3 = [[[HSGenericItemsCanvasSublayer alloc] init] autorelease];
    [pvVar1_3 addCanvasItem:[self pathCanvasItem]];
    pvVar2_3 = [[self view] rootCanvasLayer];
    [[pvVar2_3 vectorToolsCanvasLayer] addSublayer:[[[HSDisablingCanvasLayer alloc] init] autorelease]];
    [[pvVar2_3 vectorToolsCanvasLayer] addSublayer:[self visualizationCanvasLayer]];
    [[pvVar2_3 vectorToolsCanvasLayer] addSublayer:pvVar1_3];
    [pvVar2_3 setEnabledSublayerIdentifiers:[pvVar2_3 vectorToolsIdentifiers]];
}

- (BOOL)allowsActiveInPlaceEditors
{
    return NO;
}

- (void)dealloc
{
    [_selectionCanvasLayer setDelegate:0];
    [_selectionCanvasLayer release];
    [_creationCanvasLayer setDelegate:0];
    [_creationCanvasLayer release];
    [_pathCanvasItem release];
    [_visualizationCanvasLayer release];
    [_pathObject release];
    [_creationObject release];
    [_prototypeObject release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _creating = 0;
    }
    return self;
}

@end

