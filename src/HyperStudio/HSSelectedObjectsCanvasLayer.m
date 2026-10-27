#import "HSSelectedObjectsCanvasLayer.h"

@implementation HSSelectedObjectsCanvasLayer

/* i386 ivar offsets: _selection=0x18, _tracker=0x1c, _lastMouseEvent=0x20, _trackingRectSublayer=0x24, _flickRecognizer=0x28, _flickObjects=0x2c */

+ (BOOL)isSelectionModifierKeyBeingHeld:(NSUInteger)aHeld
{
    if ((aHeld & 0x120000) != 0) {
        return (aHeld | 0xfff3ffff) == 0xfff3ffff;
    }
    return NO;
}

- (void)willUnregisterCanvasItem:(id)aItem forNode:(id)aNode
{
    [super willUnregisterCanvasItem:aItem forNode:aNode];
    if ([[aNode queryHyperInterface:@protocol(HSButtonObjectShapeBackgroundAttributes)] isAlternativeBorderActive]) {
        [[aNode queryHyperInterface:@protocol(HSButtonObjectShapeBackgroundAttributes)] activateAlternativeBorder:NO];
    }
}

- (void)didRegisterCanvasItem:(id)aItem forNode:(id)aNode
{
    [super didRegisterCanvasItem:aItem forNode:aNode];
    if ([[aNode queryHyperInterface:@protocol(HSButtonObjectAttributes)] isButtonNaturallyInvisible]) {
        if (![[[aNode queryHyperInterface:@protocol(HSButtonObjectShapeBackgroundAttributes)] shapeButtonType] isEqualToString:@"HSInvisibleShapeButtonType"]) {
            [[aNode queryHyperInterface:@protocol(HSButtonObjectShapeBackgroundAttributes)] activateAlternativeBorder:YES];
        }
    }
}

- (void)trackingRectSublayerDidHandleMouseUp:(id)aUp
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSSelectedObjectsCanvasLayerDidHandleMouseUpNotification" object:self];
}

- (void)itemWillOrDidChangeGeometry:(id)aGeometry
{
    id pvVar1_2;

    pvVar1_2 = [self canvasItemForNodeIfExists:[aGeometry object]];
    if (pvVar1_2 != nil) {
        [self invalidateDisplayForCanvasItem:pvVar1_2];
    }
}

- (void)stopObservingNotificationsFromRootRepresentedObject:(id)aObject
{
    [super stopObservingNotificationsFromRootRepresentedObject:aObject];
    [[aObject queryHyperInterface:@protocol(HSNodeContainer)] removeObserver:self selector:@selector(itemWillOrDidChangeGeometry:) ofChanges:HSActualAttributeChanges ofChildrenAttribute:@protocol(HSGeometryAttribute)];
}

- (void)observeNotificationsFromRootRepresentedObject:(id)aObject
{
    [super observeNotificationsFromRootRepresentedObject:aObject];
    [[aObject queryHyperInterface:@protocol(HSNodeContainer)] addObserver:self selector:@selector(itemWillOrDidChangeGeometry:) ofChanges:HSActualAttributeChanges ofChildrenAttribute:@protocol(HSGeometryAttribute) withPriority:-0.25];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0009b3c0 @ 0009b3c0, 331 bytes * /

BOOL FUN_0009b3c0(HSSelectedObjectsCanvasLayer *self,SEL _cmd,id validateUserInterfaceItem)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  
  puVar1 = _objc_msgSend(validateUserInterfaceItem,sel_action);
  if ((puVar1 == sel_deleteSelectedCardObjects_) || (puVar1 == sel_delete_)) {
    pvVar2 = _objc_msgSend(self,sel_canDeleteSelectedNodes);
    if ((char)pvVar2 != '\0') {
      pvVar2 = _objc_msgSend(self,sel_isSelectedOnlyTemporaryObject);
      return (char)pvVar2 == '\0';
    }
  }
  else {
    if (puVar1 == sel_copy_) {
      self = _objc_msgSend(self,sel_selection);
      op = sel_nodesCount;
LAB_0009b4f9:
      pvVar2 = _objc_msgSend(self,op);
      return pvVar2 != (id)0x0;
    }
    if (puVar1 == sel_cut_) {
      pvVar2 = _objc_msgSend(self,sel_canDeleteSelectedNodes);
      return (BOOL)pvVar2;
    }
    if (puVar1 == sel_selectAll_) {
      pvVar2 = _objc_msgSend(self,sel_rootRepresentedNode);
      pvVar2 = _objc_msgSend(pvVar2,sel_hyperCount);
      pvVar3 = _objc_msgSend(self,sel_selection);
      pvVar3 = _objc_msgSend(pvVar3,sel_nodesArray);
      pvVar3 = _objc_msgSend(pvVar3,sel_count);
      op = sel_selection;
      if (pvVar3 < pvVar2) goto LAB_0009b4f9;
    }
  }
  return '\0';
}

*/
- (BOOL)validateUserInterfaceItem:(id)aItem
{
    SEL action = [(id<NSValidatedUserInterfaceItem>)aItem action];
    if (action == @selector(deleteSelectedCardObjects:) || action == @selector(delete:)) {
        return [self canDeleteSelectedNodes] && ![self isSelectedOnlyTemporaryObject];
    }
    if (action == @selector(copy:)) {
        return [[self selection] nodesCount] != 0;
    }
    if (action == @selector(cut:)) {
        return [self canDeleteSelectedNodes];
    }
    if (action == @selector(selectAll:)) {
        if ([[[self selection] nodesArray] count] < [[self rootRepresentedNode] hyperCount]) {
            return [self selection] != nil;
        }
    }
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0009b2e6 @ 0009b2e6, 218 bytes * /

BOOL FUN_0009b2e6(HSSelectedObjectsCanvasLayer *self,SEL _cmd,
                 id *getNodesArrayForPendingDeleteOperation,BOOL isCutOperation)

{
  BOOL BVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  
  pvVar2 = _objc_msgSend(self,sel_canDeleteSelectedNodes);
  if ((char)pvVar2 == '\0') {
LAB_0009b3a6:
    pvVar2 = (id)0x0;
  }
  else {
    pvVar2 = _objc_msgSend(cls_HSSelectionOperationVerifier,sel_alloc);
    pvVar3 = _objc_msgSend(self,sel_selection);
    pvVar2 = _objc_msgSend(pvVar2,sel_initWithSelection_,pvVar3);
    pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
    op = sel_selectedNodesArrayForDeleteOperation;
    if (isCutOperation != '\0') {
      op = sel_selectedNodesArrayForCutOperation;
    }
    pvVar2 = _objc_msgSend(pvVar2,op,pvVar3);
    if (pvVar2 != (id)0x0) {
      BVar1 = '\x01';
      goto LAB_0009b3aa;
    }
    pvVar3 = _objc_msgSend((id)0x0,sel_count,pvVar3);
    if (pvVar3 == (id)0x0) goto LAB_0009b3a6;
  }
  BVar1 = '\0';
LAB_0009b3aa:
  if (getNodesArrayForPendingDeleteOperation != (id *)0x0) {
    *getNodesArrayForPendingDeleteOperation = pvVar2;
  }
  return BVar1;
}

*/
- (BOOL)getNodesArrayForPendingDeleteOperation:(id *)aOperation isCutOperation:(BOOL)aOperation2
{
    NSArray *nodes = nil;
    if ([self canDeleteSelectedNodes]) {
        HSSelectionOperationVerifier *verifier = [[[HSSelectionOperationVerifier alloc] initWithSelection:[self selection]] autorelease];
        nodes = aOperation2 ? [verifier selectedNodesArrayForCutOperation] : [verifier selectedNodesArrayForDeleteOperation];
    }
    if (aOperation != NULL) {
        *aOperation = nodes;
    }
    return nodes != nil;
}

- (BOOL)isSelectedOnlyTemporaryObject
{
    id pvVar1_2;

    pvVar1_2 = [[self selection] nodesArray];
    if ([pvVar1_2 count] == 0x1) {
        if ([[pvVar1_2 lastObject] implementsHyperInterface:@protocol(HSNodeChild)]) {
            return [[[pvVar1_2 lastObject] queryHyperInterface:@protocol(HSNodeChild)] isTemporary];
        }
    }
    return NO;
}

- (BOOL)canDeleteSelectedNodes
{
    return (BOOL)[[[self context] queryHyperInterface:@protocol(HSEditorCanvasLayerContext)] canPerformDeleteOperationWithNodesInArray:[[self selection] nodesArray]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0009b0dd @ 0009b0dd, 179 bytes * /

BOOL FUN_0009b0dd(HSSelectedObjectsCanvasLayer *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  undefined4 *puVar3;
  undefined4 uVar4;
  undefined4 local_10;
  
  local_10 = 0;
  puVar3 = &local_10;
  uVar4 = 0;
  pvVar1 = _objc_msgSend(self,sel_getNodesArrayForPendingDeleteOperation_isCutOperation_,puVar3,0);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(self,sel_context,puVar3,uVar4);
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00367a28);
    pvVar2 = _objc_msgSend(pvVar1,sel_shouldPerformDeleteOperationWithNodesInArray_,local_10);
    if ((char)pvVar2 != '\0') {
      _objc_msgSend(pvVar1,sel_performDeleteOperationWithNodesInArray_,local_10,uVar4);
      return '\x01';
    }
  }
  return '\0';
}

*/
- (BOOL)deleteSelectedNodes
{
    NSArray *nodes = nil;
    if ([self getNodesArrayForPendingDeleteOperation:&nodes isCutOperation:NO]) {
        id context = [[self context] queryHyperInterface:@protocol(HSEditorCanvasLayerContext)];
        if ([context shouldPerformDeleteOperationWithNodesInArray:nodes]) {
            [context performDeleteOperationWithNodesInArray:nodes];
            return YES;
        }
    }
    return NO;
}

- (void)insertNewline:(id)aNewline
{
    if ([[self selection] nodesCount] == 0x1) {
        if (![[[[self selection] nodesArray] lastObject] isLocked]) {
            [[HSObjectAssistantController sharedAssistantController] openDefaultEditingPaneForObject:[[self selection] selectedNode]];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0009aebf @ 0009aebf, 311 bytes * /

void FUN_0009aebf(HSSelectedObjectsCanvasLayer *self,SEL _cmd,id selectAll)

{
  id pvVar1;
  id pvVar2;
  id *ppvVar3;
  id local_14;
  
  pvVar1 = _objc_msgSend(self,sel_selection);
  if (pvVar1 != (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_rootRepresentedNode);
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperCount);
    if (pvVar1 != (id)0x0) {
      pvVar1 = _objc_msgSend(self,sel_rootRepresentedNode);
      local_14 = _objc_msgSend(pvVar1,sel_hyperChildren);
      pvVar1 = _objc_msgSend(cls_HSSelectionOperationVerifier,sel_alloc);
      pvVar2 = _objc_msgSend(self,sel_selection);
      pvVar1 = _objc_msgSend(pvVar1,sel_initWithSelection_,pvVar2);
      pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
      ppvVar3 = &local_14;
      pvVar1 = _objc_msgSend(pvVar1,sel_verifyCanSelectNodesInArray_,ppvVar3);
      if ((char)pvVar1 != '\0') {
        pvVar1 = _objc_msgSend(self,sel_selection,ppvVar3);
        pvVar2 = _objc_msgSend(local_14,sel_objectEnumerator);
        _objc_msgSend(pvVar1,sel_selectNodesInEnumerator_,pvVar2);
      }
    }
  }
  return;
}

*/
- (void)selectAll:(id)aAll
{
    if ([self selection] == nil || [[self rootRepresentedNode] hyperCount] == 0) {
        return;
    }
    NSArray *nodes = [[self rootRepresentedNode] hyperChildren];
    if ([[[[HSSelectionOperationVerifier alloc] initWithSelection:[self selection]] autorelease] verifyCanSelectNodesInArray:&nodes]) {
        [[self selection] selectNodesInEnumerator:[nodes objectEnumerator]];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0009ad3d @ 0009ad3d, 386 bytes * /

void FUN_0009ad3d(HSSelectedObjectsCanvasLayer *self,SEL _cmd,id cut)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id *ppvVar4;
  undefined4 uVar5;
  id local_10;
  
  local_10 = (id)0x0;
  ppvVar4 = &local_10;
  uVar5 = 1;
  pvVar1 = _objc_msgSend(self,sel_getNodesArrayForPendingDeleteOperation_isCutOperation_,ppvVar4,1);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(self,sel_context,ppvVar4,uVar5);
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00367a28);
    pvVar2 = _objc_msgSend(pvVar1,sel_shouldPerformDeleteOperationWithNodesInArray_,local_10);
    if ((char)pvVar2 != '\0') {
      pvVar2 = _objc_msgSend(local_10,sel_objectAtIndex_,0,uVar5);
      pvVar2 = _objc_msgSend(pvVar2,sel_undoManager);
      pvVar3 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
      pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_Cut,&cfstr_empty,
                             &cfstr_UndoManager);
      _objc_msgSend(pvVar2,sel_setMultipleActionsName_,pvVar3);
      pvVar2 = _objc_msgSend(local_10,sel_objectEnumerator);
      _objc_msgSend(pvVar1,sel_writeObjectsInEnumeratorToPasteboard_,pvVar2);
      _objc_msgSend(pvVar1,sel_performDeleteOperationWithNodesInArray_,local_10);
      _objc_msgSend(pvVar1,sel_noteDidPerformCutOperation);
    }
  }
  return;
}

*/
- (void)cut:(id)aCut
{
    NSArray *nodes = nil;
    if (![self getNodesArrayForPendingDeleteOperation:&nodes isCutOperation:YES]) {
        return;
    }
    id context = [[self context] queryHyperInterface:@protocol(HSEditorCanvasLayerContext)];
    if ([context shouldPerformDeleteOperationWithNodesInArray:nodes]) {
        [[[nodes objectAtIndex:0] undoManager] setMultipleActionsName:[[NSBundle mainBundle] localizedStringForKey:@"Cut" value:@"" table:@"UndoManager"]];
        [context writeObjectsInEnumeratorToPasteboard:[nodes objectEnumerator]];
        [context performDeleteOperationWithNodesInArray:nodes];
        [context noteDidPerformCutOperation];
    }
}

- (void)copy:(id)aCopy
{
    [[[self context] queryHyperInterface:@protocol(HSEditorCanvasLayerContext)] writeObjectsInEnumeratorToPasteboard:[[self selection] nodesEnumerator]];
}

- (void)deleteSelectedCardObjects:(id)aObjects
{
    [self delete:aObjects];
}

- (void)delete:(id)aDelete
{
    [self deleteSelectedNodes];
}

- (void)deleteBackward:(id)aBackward
{
    [self deleteSelectedNodes];
}

- (void)deleteForward:(id)aForward
{
    [self deleteSelectedNodes];
}

- (void)moveWordRightAndModifySelection:(id)aSelection
{
    [self duplicateSelectedObjectsAndMoveWithDelta:NSMakePoint(10.0, 0)];
}

- (void)moveWordRight:(id)aRight
{
    [self duplicateSelectedObjectsAndMoveWithDelta:NSMakePoint(1.0, 0)];
}

- (void)moveWordLeftAndModifySelection:(id)aSelection
{
    [self duplicateSelectedObjectsAndMoveWithDelta:NSMakePoint(-10.0, 0)];
}

- (void)moveWordLeft:(id)aLeft
{
    [self duplicateSelectedObjectsAndMoveWithDelta:NSMakePoint(-1.0, 0)];
}

- (void)moveParagraphForwardAndModifySelection:(id)aSelection
{
    [self duplicateSelectedObjectsAndMoveWithDelta:NSMakePoint(0, 10.0)];
}

- (void)moveForward:(id)aForward
{
    [self duplicateSelectedObjectsAndMoveWithDelta:NSMakePoint(0, 1.0)];
}

- (void)moveParagraphBackwardAndModifySelection:(id)aSelection
{
    [self duplicateSelectedObjectsAndMoveWithDelta:NSMakePoint(0, -10.0)];
}

- (void)moveBackward:(id)aBackward
{
    [self duplicateSelectedObjectsAndMoveWithDelta:NSMakePoint(0, -1.0)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0009a9ac @ 0009a9ac, 190 bytes * /

void FUN_0009a9ac(HSSelectedObjectsCanvasLayer *self,SEL _cmd,
                 NSPoint duplicateSelectedObjectsAndMoveWithDelta)

{
  id pvVar1;
  id pvVar2;
  undefined4 local_10;
  
  pvVar1 = _objc_msgSend(self,sel_selection);
  pvVar1 = _objc_msgSend(pvVar1,sel_nodesEnumerator);
  local_10 = 0;
  pvVar2 = _objc_msgSend(self,sel_context);
  pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_00367a28);
  _objc_msgSend(pvVar2,sel_duplicateObjectsInEnumerator_duplicatedObjects_,pvVar1,&local_10);
  _objc_msgSend(self,sel_handleArrowKeyWithDelta_,duplicateSelectedObjectsAndMoveWithDelta.x,
                duplicateSelectedObjectsAndMoveWithDelta.y);
  return;
}

*/
- (void)duplicateSelectedObjectsAndMoveWithDelta:(NSPoint)aDelta
{
    NSEnumerator *nodes = [[self selection] nodesEnumerator];
    id duplicatedObjects = nil;
    [[[self context] queryHyperInterface:@protocol(HSEditorCanvasLayerContext)] duplicateObjectsInEnumerator:nodes duplicatedObjects:&duplicatedObjects];
    [self handleArrowKeyWithDelta:aDelta];
}

- (void)moveDownAndModifySelection:(id)aSelection
{
    [self handleArrowKeyWithDelta:NSMakePoint(0, 10.0)];
}

- (void)moveUpAndModifySelection:(id)aSelection
{
    [self handleArrowKeyWithDelta:NSMakePoint(0, -10.0)];
}

- (void)moveLeftAndModifySelection:(id)aSelection
{
    [self handleArrowKeyWithDelta:NSMakePoint(-10.0, 0)];
}

- (void)moveRightAndModifySelection:(id)aSelection
{
    [self handleArrowKeyWithDelta:NSMakePoint(10.0, 0)];
}

- (void)moveDown:(id)aDown
{
    [self handleArrowKeyWithDelta:NSMakePoint(0, 1.0)];
}

- (void)moveUp:(id)aUp
{
    [self handleArrowKeyWithDelta:NSMakePoint(0, -1.0)];
}

- (void)moveLeft:(id)aLeft
{
    [self handleArrowKeyWithDelta:NSMakePoint(-1.0, 0)];
}

- (void)moveRight:(id)aRight
{
    [self handleArrowKeyWithDelta:NSMakePoint(1.0, 0)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0009a616 @ 0009a616, 486 bytes * /

void FUN_0009a616(HSSelectedObjectsCanvasLayer *self,SEL _cmd,NSPoint handleArrowKeyWithDelta)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  undefined4 uVar4;
  
  pvVar1 = _objc_msgSend(cls_HSSelectionOperationVerifier,sel_alloc);
  pvVar2 = _objc_msgSend(self,sel_selection);
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithSelection_,pvVar2);
  pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  pvVar1 = _objc_msgSend(pvVar1,sel_selectedNodesArrayForMoveOperation);
  pvVar3 = _objc_msgSend(pvVar1,sel_count);
  if (pvVar3 != (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_selection,pvVar2);
    uVar4 = 0;
    _objc_msgSend(pvVar2,sel_setShouldDisplaySelectionKnobs_,0);
    pvVar2 = _objc_msgSend(cls_HSMoveMultiSelectionTracker,sel_new);
    pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
    pvVar3 = _objc_msgSend(pvVar1,sel_count);
    op = sel_lastObject;
    if ((id)0x1 < pvVar3) {
      op = sel_hyperObjectForAllInterfaces;
    }
    pvVar1 = _objc_msgSend(pvVar1,op,uVar4);
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_003679d8);
    _objc_msgSend(self,sel_setTracker_,pvVar2);
    _objc_msgSend(pvVar2,sel_setTrackingObject_,pvVar1);
    _objc_msgSend(pvVar2,sel_prepareForTracking);
    _objc_msgSend(pvVar2,sel_moveObjectsByUserDelta_withKeyboard_,handleArrowKeyWithDelta.x,
                  handleArrowKeyWithDelta.y,1);
    _objc_msgSend(pvVar2,sel_concludeTracking);
    _objc_msgSend(self,sel_setTracker_,0);
  }
  return;
}

*/
- (void)handleArrowKeyWithDelta:(NSPoint)aDelta
{
    NSArray *nodes = [[[[HSSelectionOperationVerifier alloc] initWithSelection:[self selection]] autorelease] selectedNodesArrayForMoveOperation];
    if ([nodes count] == 0) {
        return;
    }
    [[self selection] setShouldDisplaySelectionKnobs:NO];
    HSMoveMultiSelectionTracker *tracker = [[HSMoveMultiSelectionTracker new] autorelease];
    id node = [nodes count] > 1 ? [nodes hyperObjectForAllInterfaces] : [nodes lastObject];
    node = [node queryHyperInterface:@protocol(HSNodeAttributes)];
    [self setTracker:tracker];
    [tracker setTrackingObject:node];
    [tracker prepareForTracking];
    [tracker moveObjectsByUserDelta:NSMakeSize(aDelta.x, aDelta.y) withKeyboard:YES];
    [tracker concludeTracking];
    [self setTracker:nil];
}

- (BOOL)invalidatesDisplayUponRegisterUnregister
{
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0009a452 @ 0009a452, 452 bytes * /

void FUN_0009a452(HSSelectedObjectsCanvasLayer *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id self_00;
  id local_1c;
  
  pvVar1 = _objc_msgSend(self,sel_selection);
  pvVar2 = _objc_msgSend(pvVar1,sel_nodesCount);
  if (pvVar2 == (id)0x0) {
    _objc_msgSend(self,sel_unregisterAllCanvasItems);
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_numberOfCanvasItems);
    if (pvVar2 == (id)0x0) {
      local_1c = (id)0x0;
    }
    else {
      pvVar2 = _objc_msgSend(self,sel_registeredCanvasItems);
      local_1c = _objc_msgSend(pvVar2,sel_count);
      pvVar2 = _objc_msgSend(pvVar2,sel_objectEnumerator);
      while( true ) {
        self_00 = _objc_msgSend(pvVar2,sel_nextObject);
        if (self_00 == (id)0x0) break;
        pvVar3 = _objc_msgSend(self_00,sel_queryHyperInterface_,&DAT_003679d8);
        pvVar4 = _objc_msgSend(pvVar1,sel_containsNode_,pvVar3);
        if ((char)pvVar4 == '\0') {
          _objc_msgSend(self,sel_unregisterCanvasItem_forNode_,self_00,pvVar3);
          local_1c = (id)((int)local_1c + -1);
        }
        else {
          _objc_msgSend(self,sel_invalidateDisplayForCanvasItem_,self_00);
        }
      }
    }
    pvVar2 = _objc_msgSend(pvVar1,sel_nodesCount);
    if (local_1c != pvVar2) {
      pvVar1 = _objc_msgSend(pvVar1,sel_nodesEnumerator);
      while( true ) {
        pvVar2 = _objc_msgSend(pvVar1,sel_nextObject);
        if (pvVar2 == (id)0x0) break;
        _objc_msgSend(self,sel_canvasItemForNode_,pvVar2);
      }
    }
  }
  return;
}

*/
- (void)rebuildCanvasItems
{
    id selection = [self selection];
    if ([selection nodesCount] == 0) {
        [self unregisterAllCanvasItems];
        return;
    }
    NSUInteger count = 0;
    if ([self numberOfCanvasItems] != 0) {
        id items = [self registeredCanvasItems];
        count = [items count];
        NSEnumerator *enumerator = [items objectEnumerator];
        id item;
        while ((item = [enumerator nextObject]) != nil) {
            id node = [item queryHyperInterface:@protocol(HSNodeAttributes)];
            if ([selection containsNode:node]) {
                [self invalidateDisplayForCanvasItem:item];
            } else {
                [self unregisterCanvasItem:item forNode:node];
                count--;
            }
        }
    }
    /* Make items for the newly selected nodes. */
    if (count != [selection nodesCount]) {
        NSEnumerator *enumerator = [selection nodesEnumerator];
        id node;
        while ((node = [enumerator nextObject]) != nil) {
            [self canvasItemForNode:node];
        }
    }
}

- (id)queryCanvasItemForNode:(id)aNode
{
    id pvVar1;
    id pvVar2_2;

    pvVar1 = [self selection];
    if (![pvVar1 containsNode:aNode]) {
        pvVar2_2 = nil;
    }
    else {
        pvVar2_2 = [[[HSSelectedObjectCanvasItem alloc] initWithHyperObject:aNode] autorelease];
    }
    return pvVar2_2;
}

- (void)objectsInSelectionDidChange:(id)aChange
{
    [self objectsInSelectionDidChange];
}

- (void)objectsInSelectionDidChange
{
    [self rebuildCanvasItems];
}

- (void)selectionDidChange
{
    [self objectsInSelectionDidChange];
}

- (id)trackingRectSublayer
{
    HSTrackingRectCanvasLayer *pHVar2;
    HSTrackingRectCanvasLayer *pHVar2_2;

    pHVar2 = _trackingRectSublayer;
    if (pHVar2 == nil) {
        pHVar2_2 = [[HSTrackingRectCanvasLayer alloc] init];
        _trackingRectSublayer = pHVar2_2;
        [pHVar2_2 setParentLayer:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trackingRectSublayerDidHandleMouseUp:) name:@"HSTrackingRectCanvasLayerDidHandleMouseUpNotification" object:_trackingRectSublayer];
        pHVar2 = _trackingRectSublayer;
    }
    return pHVar2;
}

- (void)setLastMouseEvent:(id)aEvent
{
    if (_lastMouseEvent != aEvent) {
        [_lastMouseEvent release];
        _lastMouseEvent = [aEvent retain];
    }
}

- (void)setTracker:(id)aTracker
{
    if (_tracker != aTracker) {
        [_tracker setLayoutGuidingContext:nil];
        [_tracker setTrackingObject:nil];
        [_tracker release];
        _tracker = [aTracker retain];
        [_tracker setLayoutGuidingContext:[[[self context] queryHyperInterface:@protocol(HSEditorCanvasLayerContext)] layoutGuidingContext]];
    }
}

- (id)sublayerAtIndex:(NSUInteger)aIndex
{
    return _trackingRectSublayer;
}

- (NSUInteger)numberOfSublayers
{
    return (unsigned int)(_trackingRectSublayer != nil);
}

- (id)rootLayer
{
    return [[self parentLayer] rootLayer];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0009a094 @ 0009a094, 157 bytes * /

void FUN_0009a094(HSSelectedObjectsCanvasLayer *self,SEL _cmd,id handleFlagsChanged,
                 id inTrackingLoop)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  
  pvVar2 = self->_lastMouseEvent;
  pvVar3 = handleFlagsChanged;
  pvVar4 = inTrackingLoop;
  pvVar1 = _objc_msgSend(self,sel_startDragWithEvent_inTrackingLoop_mouseEvent_,handleFlagsChanged,
                         inTrackingLoop,pvVar2);
  if ((char)pvVar1 == '\0') {
    pvVar2 = _objc_msgSend(inTrackingLoop,sel_view,pvVar3,pvVar4,pvVar2);
    _objc_msgSend(pvVar2,sel_beginContentChangeAccumulation);
    _objc_msgSend(self->_tracker,sel_flagsChanged_inView_,handleFlagsChanged,pvVar2);
    _objc_msgSend(pvVar2,sel_endContentChangeAccumulation);
  }
  return;
}

*/
- (void)handleFlagsChanged:(id)aChanged inTrackingLoop:(id)aLoop
{
    if ([self startDragWithEvent:aChanged inTrackingLoop:aLoop mouseEvent:_lastMouseEvent]) {
        return;
    }
    id view = [aLoop view];
    [view beginContentChangeAccumulation];
    [_tracker flagsChanged:aChanged inView:view];
    [view endContentChangeAccumulation];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00099ece @ 00099ece, 454 bytes * /

void FUN_00099ece(HSSelectedObjectsCanvasLayer *self,SEL _cmd,id handleMouseUp,id inTrackingLoop)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id self_01;
  undefined4 extraout_EDX;
  id extraout_EDX_00;
  int iVar5;
  
  self_00 = _objc_msgSend(inTrackingLoop,sel_view);
  pvVar1 = _objc_msgSend(self,sel_renderingView);
  pvVar2 = _objc_msgSend(handleMouseUp,sel_locationInWindow);
  iVar5 = 0;
  pvVar2 = _objc_msgSend(pvVar1,sel_convertPoint_fromView_,pvVar2,extraout_EDX,0);
  _objc_msgSend(self_00,sel_beginContentChangeAccumulation);
  _objc_msgSend(self->_tracker,sel_mouseUp_inView_,handleMouseUp,self_00);
  pvVar1 = _objc_msgSend(self,sel_context);
  pvVar3 = _objc_msgSend(pvVar1,sel_canvasHitTester);
  pvVar1 = extraout_EDX_00;
  pvVar3 = _objc_msgSend(pvVar3,sel_hitTestNodeAtPoint_,pvVar2,extraout_EDX_00);
  pvVar4 = _objc_msgSend(self,sel_selection);
  if (pvVar3 != (id)0x0) {
    pvVar4 = _objc_msgSend(pvVar4,sel_containsNode_,pvVar3,pvVar1);
    pvVar1 = _objc_msgSend(self,sel_context);
    self_01 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00367a28);
    pvVar1 = self->_lastMouseEvent;
    pvVar2 = _objc_msgSend(handleMouseUp,sel_modifierFlags);
    iVar5 = (int)(char)pvVar4;
    _objc_msgSend(self_01,sel_handleMouseUpWithModifiers_inNode_nodeIsSelected_previousEvent_,pvVar2
                  ,pvVar3,iVar5,pvVar1);
    pvVar1 = pvVar3;
  }
  _objc_msgSend(self_00,sel_endContentChangeAccumulation,pvVar2,pvVar1,iVar5);
  return;
}

*/
- (void)handleMouseUp:(id)aUp inTrackingLoop:(id)aLoop
{
    id view = [aLoop view];
    NSPoint point = [[self renderingView] convertPoint:[aUp locationInWindow] fromView:nil];
    [view beginContentChangeAccumulation];
    [_tracker mouseUp:aUp inView:view];
    id node = [[[self context] canvasHitTester] hitTestNodeAtPoint:point];
    id selection = [self selection];
    if (node != nil) {
        BOOL isSelected = [selection containsNode:node];
        [[[self context] queryHyperInterface:@protocol(HSEditorCanvasLayerContext)] handleMouseUpWithModifiers:[aUp modifierFlags] inNode:node nodeIsSelected:isSelected previousEvent:_lastMouseEvent];
    }
    [view endContentChangeAccumulation];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00099e1f @ 00099e1f, 175 bytes * /

void FUN_00099e1f(HSSelectedObjectsCanvasLayer *self,SEL _cmd,id handleMouseDragged,
                 id inTrackingLoop)

{
  id self_00;
  
  _objc_msgSend(self,sel_startDragWithEvent_inTrackingLoop_mouseEvent_,handleMouseDragged,
                inTrackingLoop,handleMouseDragged);
  self_00 = _objc_msgSend(inTrackingLoop,sel_view);
  _objc_msgSend(self_00,sel_beginContentChangeAccumulation);
  _objc_msgSend(self->_tracker,sel_mouseDragged_inView_,handleMouseDragged,self_00);
  _objc_msgSend(self_00,sel_endContentChangeAccumulation);
  _objc_msgSend(self,sel_setLastMouseEvent_,handleMouseDragged);
  return;
}

*/
- (void)handleMouseDragged:(id)aDragged inTrackingLoop:(id)aLoop
{
    [self startDragWithEvent:aDragged inTrackingLoop:aLoop mouseEvent:aDragged];
    id view = [aLoop view];
    [view beginContentChangeAccumulation];
    [_tracker mouseDragged:aDragged inView:view];
    [view endContentChangeAccumulation];
    [self setLastMouseEvent:aDragged];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00099d90 @ 00099d90, 143 bytes * /

void FUN_00099d90(HSSelectedObjectsCanvasLayer *self,SEL _cmd,id handleMouseDown,id inTrackingLoop)

{
  id self_00;
  
  self_00 = _objc_msgSend(inTrackingLoop,sel_view);
  _objc_msgSend(self_00,sel_beginContentChangeAccumulation);
  _objc_msgSend(self->_tracker,sel_mouseDown_inView_,handleMouseDown,self_00);
  _objc_msgSend(self_00,sel_endContentChangeAccumulation);
  _objc_msgSend(self,sel_setLastMouseEvent_,handleMouseDown);
  return;
}

*/
- (void)handleMouseDown:(id)aDown inTrackingLoop:(id)aLoop
{
    id view = [aLoop view];
    [view beginContentChangeAccumulation];
    [_tracker mouseDown:aDown inView:view];
    [view endContentChangeAccumulation];
    [self setLastMouseEvent:aDown];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00099be7 @ 00099be7, 425 bytes * /

BOOL FUN_00099be7(HSSelectedObjectsCanvasLayer *self,SEL _cmd,id startDragWithEvent,
                 id inTrackingLoop,id mouseEvent)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  SEL op;
  undefined *puVar3;
  
  pvVar1 = _objc_msgSend(startDragWithEvent,sel_modifierFlags);
  if (((mouseEvent != (id)0x0) && (((uint)pvVar1 & 0xffff0000) != 0xa0000)) &&
     (pvVar1 = _objc_msgSend(startDragWithEvent,sel_modifierFlags), ((uint)pvVar1 & 0x80000) != 0))
  {
    pvVar1 = _objc_msgSend(self,sel_context);
    puVar3 = &DAT_00367a28;
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00367a28);
    if ((pvVar1 != (id)0x0) &&
       (pvVar2 = _objc_msgSend(self,sel_selection,puVar3), pvVar2 != (id)0x0)) {
      _objc_msgSend(inTrackingLoop,sel_pause,puVar3);
      self_00 = _objc_msgSend(self->_tracker,sel_copy);
      _objc_msgSend(self,sel_setTracker_,0);
      pvVar2 = _objc_msgSend(self,sel_selection);
      pvVar2 = _objc_msgSend(pvVar2,sel_nodesArray);
      pvVar1 = _objc_msgSend(pvVar1,sel_startDragWithNodes_event_,pvVar2,mouseEvent);
      op = sel_abort;
      if ((char)pvVar1 == '\0') {
        pvVar2 = self_00;
        _objc_msgSend(self,sel_setTracker_,self_00,mouseEvent);
        op = sel_resume;
      }
      _objc_msgSend(inTrackingLoop,op,pvVar2,mouseEvent);
      _objc_msgSend(self_00,sel_release);
      return (char)pvVar1;
    }
  }
  return '\0';
}

*/
- (BOOL)startDragWithEvent:(id)aEvent inTrackingLoop:(id)aLoop mouseEvent:(id)aEvent2
{
    /* Option starts an external drag, unless Command-Shift is also down. */
    if (aEvent2 == nil || ([aEvent modifierFlags] & 0xffff0000) == 0xa0000 || ([aEvent modifierFlags] & NSEventModifierFlagOption) == 0) {
        return NO;
    }
    id context = [[self context] queryHyperInterface:@protocol(HSEditorCanvasLayerContext)];
    if (context == nil || [self selection] == nil) {
        return NO;
    }
    [(HSTrackingLoop *)aLoop pause];
    id tracker = [_tracker copy];
    [self setTracker:nil];
    BOOL started = [context startDragWithNodes:[[self selection] nodesArray] event:aEvent2];
    if (started) {
        [(HSTrackingLoop *)aLoop abort];
    } else {
        [self setTracker:tracker];
        [(HSTrackingLoop *)aLoop resume];
    }
    [tracker release];
    return started;
}

- (BOOL)handleTouchesCancelledWithEvent:(id)aEvent hitTestInfo:(id)aInfo
{
    BOOL BVar1;

    if (_flickRecognizer == nil) {
        BVar1 = NO;
    }
    else {
        BVar1 = (BOOL)[_flickRecognizer touchesCancelledWithEvent:aEvent];
        [_flickRecognizer release];
        _flickRecognizer = nil;
        [_flickObjects release];
        _flickObjects = nil;
    }
    return BVar1;
}

- (BOOL)handleTouchesEndedWithEvent:(id)aEvent hitTestInfo:(id)aInfo
{
    BOOL BVar1;

    if (_flickRecognizer == nil) {
        BVar1 = NO;
    }
    else {
        BVar1 = (BOOL)[_flickRecognizer touchesEndedWithEvent:aEvent];
        [_flickRecognizer release];
        _flickRecognizer = nil;
        [_flickObjects release];
        _flickObjects = nil;
    }
    return BVar1;
}

- (BOOL)handleTouchesMovedWithEvent:(id)aEvent hitTestInfo:(id)aInfo
{
    return (BOOL)[_flickRecognizer touchesMovedWithEvent:aEvent];
}

- (BOOL)handleTouchesBeganWithEvent:(id)aEvent hitTestInfo:(id)aInfo
{
    return (BOOL)[_flickRecognizer touchesBeganWithEvent:aEvent];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0009ba11 @ 0009ba11, 732 bytes * /

id FUN_0009ba11(HSSelectedObjectsCanvasLayer *self,SEL _cmd)

{
  int iVar1;
  int iVar2;
  int *piVar3;
  char cVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  undefined4 extraout_EDX;
  int *piVar8;
  int *piVar9;
  id pvVar10;
  int aiStack_d4 [2];
  id local_9c;
  undefined8 local_94;
  undefined8 local_8c;
  undefined4 local_84;
  undefined4 uStack_80;
  id local_7c;
  undefined4 uStack_78;
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined1 local_50 [64];
  
  piVar8 = (int *)&stack0xffffff34;
  pvVar5 = _objc_msgSend(self,sel_selection);
  if (pvVar5 != (id)0x0) {
    pvVar5 = _objc_msgSend(cls_HSSelectionOperationVerifier,sel_alloc);
    pvVar5 = _objc_msgSend(pvVar5,sel_initWithSelection_);
    pvVar5 = _objc_msgSend(pvVar5,sel_autorelease);
    pvVar5 = _objc_msgSend(pvVar5,sel_selectedNodesArrayForMoveOperation);
    pvVar6 = _objc_msgSend(pvVar5,sel_count);
    if (pvVar6 != (id)0x0) {
      pvVar6 = _objc_msgSend(pvVar5,sel_objectAtIndex_);
      pvVar6 = _objc_msgSend(pvVar6,sel_queryHyperInterface_);
      pvVar6 = _objc_msgSend(pvVar6,sel_hyperParent);
      pvVar6 = _objc_msgSend(pvVar6,sel_queryHyperInterface_);
      local_7c = _objc_msgSend(pvVar6,sel_size);
      local_84 = 0;
      uStack_80 = 0;
      uStack_78 = extraout_EDX;
      pvVar6 = _objc_msgSend(cls_NSMutableArray,sel_array);
      local_74 = 0;
      local_70 = 0;
      local_6c = (int *)0x0;
      local_68 = 0;
      local_64 = 0;
      local_60 = 0;
      local_5c = 0;
      local_58 = 0;
      local_9c = _objc_msgSend(pvVar5,sel_countByEnumeratingWithState_objects_count_);
      if (local_9c == (id)0x0) {
        return pvVar6;
      }
      iVar1 = *local_6c;
      do {
        pvVar10 = (id)0x0;
        piVar3 = piVar8;
        do {
          piVar9 = piVar3;
          if (iVar1 != *local_6c) {
            *piVar9 = (int)pvVar5;
            piVar9[-1] = 0x9bbf8;
            _objc_enumerationMutation();
          }
          iVar2 = *(int *)(local_70 + (int)pvVar10 * 4);
          piVar9[2] = (int)&DAT_00368284;
          piVar9[1] = (int)sel_queryHyperInterface_;
          *piVar9 = iVar2;
          piVar9[-1] = 0x9bc1a;
          pvVar7 = _objc_msgSend((id)*piVar9,(SEL)piVar9[1]);
          piVar9[2] = (int)sel_frameBoundingRect;
          piVar9[1] = (int)pvVar7;
          *piVar9 = (int)&local_94;
          piVar9[-1] = 0x9bc36;
          _objc_msgSend_stret((void *)*piVar9,(id)piVar9[1],(SEL)piVar9[2]);
          piVar8 = piVar9 + -1;
          *(undefined8 *)(piVar9 + 5) = local_8c;
          *(undefined8 *)(piVar9 + 3) = local_94;
          *(ulonglong *)(piVar9 + 1) = CONCAT44(uStack_78,local_7c);
          *(ulonglong *)(piVar9 + -1) = CONCAT44(uStack_80,local_84);
          piVar9[-2] = 0x9bc6f;
          cVar4 = _NSIntersectsRect();
          if (cVar4 != '\0') {
            piVar9[1] = iVar2;
            *piVar9 = (int)sel_addObject_;
            piVar9[-1] = (int)pvVar6;
            piVar9[-2] = 0x9bc8f;
            _objc_msgSend((id)piVar9[-1],(SEL)*piVar9);
          }
          pvVar10 = (id)((int)pvVar10 + 1);
          piVar3 = piVar9 + -1;
        } while (pvVar10 < local_9c);
        piVar9[2] = (int)local_50;
        piVar9[1] = (int)&local_74;
        *piVar9 = (int)sel_countByEnumeratingWithState_objects_count_;
        piVar9[-1] = (int)pvVar5;
        piVar9[3] = 0x10;
        piVar9[-2] = 0x9bcca;
        local_9c = _objc_msgSend((id)piVar9[-1],(SEL)*piVar9);
      } while (local_9c != (id)0x0);
      return pvVar6;
    }
  }
  return (id)0x0;
}

*/
- (id)flickObjects
{
    if ([self selection] == nil) {
        return nil;
    }
    NSArray *nodes = [[[[HSSelectionOperationVerifier alloc] initWithSelection:[self selection]] autorelease] selectedNodesArrayForMoveOperation];
    if ([nodes count] == 0) {
        return nil;
    }
    /* Only objects that are at least partly on the card fly away. */
    NSSize cardSize = [(id<HSSizeAttributes>)[[[[nodes objectAtIndex:0] queryHyperInterface:@protocol(HSNodeChild)] hyperParent] queryHyperInterface:@protocol(HSSizeAttributes)] size];
    NSRect cardRect = NSMakeRect(0.0, 0.0, cardSize.width, cardSize.height);
    NSMutableArray *objects = [NSMutableArray array];
    for (id node in nodes) {
        if (NSIntersectsRect([[node queryHyperInterface:@protocol(HSGeometryAttributes)] frameBoundingRect], cardRect)) {
            [objects addObject:node];
        }
    }
    return objects;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0009bced @ 0009bced, 218 bytes * /

void FUN_0009bced(HSSelectedObjectsCanvasLayer *self,SEL _cmd,id handleFlickGesture)

{
  id pvVar1;
  id pvVar2;
  undefined4 extraout_EDX;
  float fVar3;
  double dVar4;
  
  dVar4 = _objc_msgSend_fpret(handleFlickGesture,sel_velocity);
  pvVar1 = _objc_msgSend(cls_HSFlickAnimation,sel_alloc);
  pvVar2 = _objc_msgSend(handleFlickGesture,sel_direction);
  fVar3 = 1400.0;
  if (1400.0 <= (float)dVar4) {
    fVar3 = (float)dVar4;
  }
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithObjects_velocity_direction_,self->_flickObjects,fVar3,
                         pvVar2,extraout_EDX);
  _objc_msgSend(pvVar1,sel_setAnimationBlockingMode_,1);
  _objc_msgSend(pvVar1,sel_startAnimation);
  _objc_msgSend(pvVar1,sel_release);
  return;
}

*/
- (void)handleFlickGesture:(id)aGesture
{
    CGFloat velocity = (float)[(HSFlickGestureRecognizer *)aGesture velocity];
    HSFlickAnimation *animation = [[HSFlickAnimation alloc] initWithObjects:_flickObjects velocity:MAX(velocity, 1400.0) direction:[(HSFlickGestureRecognizer *)aGesture direction]];
    [animation setAnimationBlockingMode:NSAnimationBlocking];
    [animation startAnimation];
    [animation release];
}

- (BOOL)handleSwipeGesture:(id)aGesture hitTestInfo:(id)aInfo
{
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0009bdc7 @ 0009bdc7, 253 bytes * /

BOOL FUN_0009bdc7(HSSelectedObjectsCanvasLayer *self,SEL _cmd,id handleRotationGestureWithEvent,
                 id hitTestInfo)

{
  id pvVar1;
  id pvVar2;
  double dVar3;
  
  pvVar1 = _objc_msgSend(cls_HSSelectionOperationVerifier,sel_alloc);
  pvVar2 = _objc_msgSend(self,sel_selection);
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithSelection_,pvVar2);
  pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  pvVar1 = _objc_msgSend(pvVar1,sel_selectedNodesArrayForEditingOperationWithImplicitCheck_,1);
  pvVar2 = _objc_msgSend(pvVar1,sel_count);
  if (pvVar2 != (id)0x0) {
    dVar3 = _objc_msgSend_fpret(handleRotationGestureWithEvent,sel_rotation);
    _objc_msgSend(self,sel_rotateObjects_aboutCenterBy_,pvVar1,
                  (float)((dVar3 * 3.141592653589793) / -180.0));
  }
  return pvVar2 != (id)0x0;
}

*/
- (BOOL)handleRotationGestureWithEvent:(id)aEvent hitTestInfo:(id)aInfo
{
    NSArray *nodes = [[[[HSSelectionOperationVerifier alloc] initWithSelection:[self selection]] autorelease] selectedNodesArrayForEditingOperationWithImplicitCheck:YES];
    if ([nodes count] == 0) {
        return NO;
    }
    [self rotateObjects:nodes aboutCenterBy:(float)(([(NSEvent *)aEvent rotation] * M_PI) / -180.0)];
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0009bec4 @ 0009bec4, 257 bytes * /

BOOL FUN_0009bec4(HSSelectedObjectsCanvasLayer *self,SEL _cmd,id handleMagnificationGestureWithEvent
                 ,id hitTestInfo)

{
  id pvVar1;
  id pvVar2;
  longdouble lVar3;
  double dVar4;
  
  pvVar1 = _objc_msgSend(cls_HSSelectionOperationVerifier,sel_alloc);
  pvVar2 = _objc_msgSend(self,sel_selection);
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithSelection_,pvVar2);
  pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  pvVar1 = _objc_msgSend(pvVar1,sel_selectedNodesArrayForEditingOperationWithImplicitCheck_,1);
  pvVar2 = _objc_msgSend(pvVar1,sel_count);
  if (pvVar2 != (id)0x0) {
    dVar4 = _objc_msgSend_fpret(handleMagnificationGestureWithEvent,sel_magnification);
    lVar3 = (longdouble)_fmaxf((float)dVar4 + 1.0,0);
    _objc_msgSend(self,sel_scaleObjects_aboutCenterBy_,pvVar1,(float)lVar3);
  }
  return pvVar2 != (id)0x0;
}

*/
- (BOOL)handleMagnificationGestureWithEvent:(id)aEvent hitTestInfo:(id)aInfo
{
    NSArray *nodes = [[[[HSSelectionOperationVerifier alloc] initWithSelection:[self selection]] autorelease] selectedNodesArrayForEditingOperationWithImplicitCheck:YES];
    if ([nodes count] == 0) {
        return NO;
    }
    [self scaleObjects:nodes aboutCenterBy:fmaxf((float)[(NSEvent *)aEvent magnification] + 1.0f, 0.0f)];
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0009bfc5 @ 0009bfc5, 410 bytes * /

void FUN_0009bfc5(HSSelectedObjectsCanvasLayer *self,SEL _cmd,id scaleObjects,float aboutCenterBy)

{
  int iVar1;
  id pvVar2;
  id pvVar3;
  HSSelectedObjectsCanvasLayer *self_00;
  id pvVar4;
  SEL op;
  undefined1 *puVar5;
  undefined4 uVar6;
  id local_78;
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined1 local_50 [64];
  
  local_74 = 0;
  local_70 = 0;
  local_6c = (int *)0x0;
  local_68 = 0;
  local_64 = 0;
  local_60 = 0;
  local_5c = 0;
  local_58 = 0;
  puVar5 = local_50;
  uVar6 = 0x10;
  local_78 = _objc_msgSend(scaleObjects,sel_countByEnumeratingWithState_objects_count_,&local_74,
                           puVar5,0x10);
  if (local_78 != (id)0x0) {
    iVar1 = *local_6c;
    do {
      pvVar4 = (id)0x0;
      do {
        if (iVar1 != *local_6c) {
          _objc_enumerationMutation(scaleObjects);
        }
        pvVar3 = *(id *)(local_70 + (int)pvVar4 * 4);
        pvVar4 = (id)((int)pvVar4 + 1);
        pvVar2 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_00368068,puVar5,uVar6);
        self_00 = self;
        op = sel_scaleTextObject_aboutCenterBy_;
        if (pvVar2 == (id)0x0) {
          pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_00368054);
          self_00 = _objc_msgSend(pvVar3,sel_queryGeometryBehaviorApplier);
          uVar6 = 0x3f000000;
          op = sel_resizeFrameBy_aboutRelativePoint_withLayoutGuidingContext_;
          pvVar2 = (id)aboutCenterBy;
        }
        puVar5 = (undefined1 *)aboutCenterBy;
        _objc_msgSend(self_00,op,pvVar2,aboutCenterBy,uVar6);
      } while (pvVar4 < local_78);
      puVar5 = local_50;
      uVar6 = 0x10;
      local_78 = _objc_msgSend(scaleObjects,sel_countByEnumeratingWithState_objects_count_,&local_74
                               ,puVar5,0x10);
    } while (local_78 != (id)0x0);
  }
  return;
}

*/
- (void)scaleObjects:(id)aObjects aboutCenterBy:(CGFloat)aBy
{
    for (id object in aObjects) {
        id textObject = [object queryHyperInterface:@protocol(HSSystemTextViewAttributes)];
        if (textObject != nil) {
            [self scaleTextObject:textObject aboutCenterBy:aBy];
        } else {
            [[[object queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier] resizeFrameBy:NSMakeSize(aBy, aBy) aboutRelativePoint:NSMakePoint(0.5, 0.5) withLayoutGuidingContext:nil];
        }
    }
}

- (void)scaleTextObject:(id)aObject aboutCenterBy:(CGFloat)aBy
{
    id self_00;

    self_00 = [aObject queryHyperInterface:@protocol(HSGenericFontAttributes)];
    [self_00 setHyperFontSize:(float)[self_00 hyperFontSize] * aBy];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0009c1cc @ 0009c1cc, 339 bytes * /

void FUN_0009c1cc(HSSelectedObjectsCanvasLayer *self,SEL _cmd,id rotateObjects,float aboutCenterBy)

{
  int iVar1;
  id pvVar2;
  id pvVar3;
  undefined1 *puVar4;
  undefined4 uVar5;
  undefined4 uVar6;
  id local_78;
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined1 local_50 [64];
  
  local_74 = 0;
  local_70 = 0;
  local_6c = (int *)0x0;
  local_68 = 0;
  local_64 = 0;
  local_60 = 0;
  local_5c = 0;
  local_58 = 0;
  puVar4 = local_50;
  uVar5 = 0x10;
  local_78 = _objc_msgSend(rotateObjects,sel_countByEnumeratingWithState_objects_count_,&local_74,
                           puVar4,0x10);
  if (local_78 != (id)0x0) {
    iVar1 = *local_6c;
    do {
      pvVar3 = (id)0x0;
      do {
        if (iVar1 != *local_6c) {
          _objc_enumerationMutation(rotateObjects);
        }
        pvVar2 = _objc_msgSend(*(id *)(local_70 + (int)pvVar3 * 4),sel_queryHyperInterface_,
                               &DAT_00368054,puVar4,uVar5);
        pvVar2 = _objc_msgSend(pvVar2,sel_queryGeometryBehaviorApplier);
        uVar6 = 0;
        uVar5 = 0x3f000000;
        puVar4 = (undefined1 *)0x3f000000;
        _objc_msgSend(pvVar2,sel_rotateBy_aboutRelativePoint_withLayoutGuidingContext_,aboutCenterBy
                      ,0x3f000000,0x3f000000,0);
        pvVar3 = (id)((int)pvVar3 + 1);
      } while (pvVar3 < local_78);
      puVar4 = local_50;
      uVar5 = 0x10;
      local_78 = _objc_msgSend(rotateObjects,sel_countByEnumeratingWithState_objects_count_,
                               &local_74,puVar4,0x10,uVar6);
    } while (local_78 != (id)0x0);
  }
  return;
}

*/
- (void)rotateObjects:(id)aObjects aboutCenterBy:(CGFloat)aBy
{
    for (id object in aObjects) {
        [[[object queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier] rotateBy:aBy aboutRelativePoint:NSMakePoint(0.5, 0.5) withLayoutGuidingContext:nil];
    }
}

- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags hitTestInfo:(id)aInfo event:(id)aEvent
{
    return [HSCursor cursorNamed:HSDefaultCursor];
}

- (BOOL)handleScrollWheelAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo
{
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0009984a @ 0009984a, 524 bytes * /

BOOL FUN_0009984a(HSSelectedObjectsCanvasLayer *self,SEL _cmd,NSPoint handleMouseDownAtPoint,
                 id event,id hitTestInfo)

{
  bool bVar1;
  BOOL BVar2;
  id pvVar3;
  id pvVar4;
  id self_00;
  id pvVar5;
  id pvVar6;
  undefined *puVar7;
  char *pcVar8;
  char local_12;
  char local_11;
  
  pvVar3 = _objc_msgSend(self,sel_context);
  pvVar4 = _objc_msgSend(pvVar3,sel_canvasHitTester);
  puVar7 = (undefined *)handleMouseDownAtPoint.x;
  pvVar3 = (id)handleMouseDownAtPoint.y;
  pvVar4 = _objc_msgSend(pvVar4,sel_hitTestNodeAtPoint_,handleMouseDownAtPoint.x,
                         handleMouseDownAtPoint.y);
  self_00 = _objc_msgSend(self,sel_selection);
  if (pvVar4 == (id)0x0) {
    bVar1 = false;
    goto LAB_000998cb;
  }
  pvVar5 = _objc_msgSend(self_00,sel_containsNode_,pvVar4,pvVar3);
  puVar7 = &DAT_00367a64;
  pvVar6 = _objc_msgSend(pvVar4,sel_queryHyperInterface_,&DAT_00367a64);
  if ((pvVar6 == (id)0x0) ||
     (pvVar6 = _objc_msgSend(pvVar6,sel_isLocked,puVar7,pvVar3), (char)pvVar6 == '\0')) {
    local_11 = '\0';
    bVar1 = false;
LAB_000999ed:
    puVar7 = event;
    pvVar3 = pvVar4;
    pvVar5 = _objc_msgSend(self,sel_handleMouseDown_inNode_nodeIsSelected_shouldIgnoreHitNode_,event
                           ,pvVar4,(int)(char)pvVar5,&local_11);
    BVar2 = (BOOL)pvVar5;
    if (local_11 == '\0') {
      return BVar2;
    }
  }
  else {
    local_11 = '\0';
    pvVar6 = _objc_msgSend(event,sel_modifierFlags,puVar7);
    if (((uint)pvVar6 & 0x80000) != 0) {
      bVar1 = true;
      goto LAB_000999ed;
    }
    bVar1 = true;
    BVar2 = '\0';
  }
  pvVar5 = _objc_msgSend(self,sel_isMouseStillDown,puVar7,pvVar3);
  if ((char)pvVar5 == '\0') {
    return BVar2;
  }
LAB_000998cb:
  pvVar3 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController,puVar7,pvVar3
                        );
  _objc_msgSend(pvVar3,sel_setTemporaryHide_,1);
  local_12 = '\0';
  pcVar8 = &local_12;
  pvVar3 = _objc_msgSend(self,sel_handleMouseDownOutsideObjects_atPoint_hasAffectedObjects_,event,
                         handleMouseDownAtPoint.x,handleMouseDownAtPoint.y,pcVar8);
  if ((local_12 == '\0') && (bVar1)) {
    _objc_msgSend(self_00,sel_selectNode_,pvVar4,handleMouseDownAtPoint.x,handleMouseDownAtPoint.y,
                  pcVar8);
  }
  return (BOOL)pvVar3;
}

*/
- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo
{
    id node = [[[self context] canvasHitTester] hitTestNodeAtPoint:aPoint];
    id selection = [self selection];
    BOOL selectLockedNode = NO;
    BOOL result = NO;
    if (node != nil) {
        BOOL isSelected = [selection containsNode:node];
        id lockedAttribute = [node queryHyperInterface:@protocol(HSCardObjectLockedAttribute)];
        BOOL handleNode = YES;
        if (lockedAttribute != nil && [lockedAttribute isLocked]) {
            /* A locked object is only picked when Option is down. */
            selectLockedNode = YES;
            handleNode = ([aEvent modifierFlags] & NSEventModifierFlagOption) != 0;
        }
        if (handleNode) {
            BOOL ignoreHitNode = NO;
            result = [self handleMouseDown:aEvent inNode:node nodeIsSelected:isSelected shouldIgnoreHitNode:&ignoreHitNode];
            if (!ignoreHitNode) {
                return result;
            }
        }
        if (![self isMouseStillDown]) {
            return result;
        }
    }
    [[HSObjectAssistantController sharedAssistantController] setTemporaryHide:YES];
    BOOL hasAffectedObjects = NO;
    result = [self handleMouseDownOutsideObjects:aEvent atPoint:aPoint hasAffectedObjects:&hasAffectedObjects];
    if (!hasAffectedObjects && selectLockedNode) {
        [selection selectNode:node];
    }
    return result;
}

- (BOOL)handleMouseUpAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo
{
    BOOL BVar1;
    BOOL pvVar4;
    id self_00;
    id pvVar2_3;
    id pvVar3_3;

    pvVar2_3 = [[[self context] canvasHitTester] hitTestNodeAtPoint:aPoint];
    if (pvVar2_3 == nil) {
        BVar1 = NO;
    }
    else {
        pvVar4 = [[self selection] containsNode:pvVar2_3];
        self_00 = [[self context] queryHyperInterface:@protocol(HSEditorCanvasLayerContext)];
        pvVar3_3 = _lastMouseEvent;
        BVar1 = (BOOL)[self_00 handleMouseUpWithModifiers:[aEvent modifierFlags] inNode:pvVar2_3 nodeIsSelected:pvVar4 previousEvent:pvVar3_3];
    }
    return BVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0009c31f @ 0009c31f, 1247 bytes * /

BOOL FUN_0009c31f(HSSelectedObjectsCanvasLayer *self,SEL _cmd,id handleMouseDownOutsideObjects,
                 NSPoint atPoint,BOOL *hasAffectedObjects)

{
  undefined *self_00;
  id self_01;
  id pvVar1;
  id pvVar2;
  id self_02;
  id pvVar3;
  undefined8 uVar4;
  uint uVar6;
  longlong lVar5;
  undefined4 uVar7;
  id local_28;
  undefined8 local_24;
  undefined8 local_1c;
  
  self_01 = _objc_msgSend(self,sel_selection);
  pvVar1 = _objc_msgSend(self,sel_class);
  _objc_msgSend(handleMouseDownOutsideObjects,sel_modifierFlags);
  pvVar1 = _objc_msgSend(pvVar1,sel_isSelectionModifierKeyBeingHeld_);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
    _objc_msgSend(pvVar1,sel_setLocked_delegate_);
    _objc_msgSend(self_01,sel_removeAllNodes);
    pvVar1 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
    _objc_msgSend(pvVar1,sel_setLocked_delegate_);
  }
  pvVar1 = _objc_msgSend(handleMouseDownOutsideObjects,sel_clickCount);
  if (pvVar1 == (id)0x2) {
    pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    _objc_msgSend(self,sel_representedObject);
    _objc_msgSend(pvVar1,sel_postNotificationName_object_);
    pvVar1 = _objc_msgSend(self,sel_context);
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_);
    _objc_msgSend(handleMouseDownOutsideObjects,sel_modifierFlags);
    pvVar1 = _objc_msgSend(pvVar1,sel_handleDoubleClickOutsideNodesWithModifiers_);
    if (((char)pvVar1 == '\0') &&
       (pvVar1 = _objc_msgSend(handleMouseDownOutsideObjects,sel_modifierFlags),
       pvVar1 < (id)0x10000)) {
      pvVar1 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
      _objc_msgSend(self,sel_representedObject);
      _objc_msgSend(pvVar1,sel_openDefaultEditingPaneForObject_);
    }
  }
  pvVar1 = _objc_msgSend(self,sel_trackingRectSublayer);
  uVar4 = CONCAT44(handleMouseDownOutsideObjects,atPoint.y);
  uVar7 = 0;
  pvVar2 = _objc_msgSend(pvVar1,sel_handleMouseDownAtPoint_event_hitTestInfo_);
  if ((char)pvVar2 != '\0') {
    _objc_msgSend_stret(&local_24,pvVar1,sel_lastTrackingRect,uVar4,uVar7);
    pvVar1 = _objc_msgSend(self,sel_context);
    pvVar1 = _objc_msgSend(pvVar1,sel_canvasHitTester);
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0036802c);
    local_28 = _objc_msgSend(pvVar1,sel_hitTestNodesInRect_,local_24,local_1c);
    pvVar1 = _objc_msgSend(local_28,sel_count);
    if (pvVar1 != (id)0x0) {
      *hasAffectedObjects = '\x01';
      pvVar1 = _objc_msgSend(cls_HSSelectionOperationVerifier,sel_alloc,local_24,local_1c);
      uVar7 = (undefined4)((ulonglong)local_24 >> 0x20);
      pvVar2 = _objc_msgSend(self,sel_selection);
      pvVar1 = _objc_msgSend(pvVar1,sel_initWithSelection_,pvVar2);
      pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
      uVar4 = CONCAT44(uVar7,&local_28);
      pvVar1 = _objc_msgSend(pvVar1,sel_verifyCanSelectNodesInArray_,&local_28);
      self_00 = cls_NSMutableArray;
      if ((char)pvVar1 != '\0') {
        pvVar1 = _objc_msgSend(self,sel_zone,uVar4);
        uVar6 = (uint)((ulonglong)uVar4 >> 0x20);
        pvVar1 = _objc_msgSend(self_00,sel_allocWithZone_,pvVar1);
        lVar5 = (ulonglong)uVar6 << 0x20;
        pvVar2 = _objc_msgSend(pvVar1,sel_initWithObjects_,0);
        self_02 = _objc_msgSend(local_28,sel_objectEnumerator);
        pvVar1 = _objc_msgSend(self_02,sel_nextObject);
        while (pvVar1 != (id)0x0) {
          lVar5 = CONCAT44((int)((ulonglong)lVar5 >> 0x20),&DAT_00367a64);
          pvVar3 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00367a64);
          if ((pvVar3 == (id)0x0) ||
             (pvVar3 = _objc_msgSend(pvVar3,sel_isLocked,lVar5), (char)pvVar3 == '\0')) {
            lVar5 = CONCAT44((int)((ulonglong)lVar5 >> 0x20),pvVar1);
            _objc_msgSend(pvVar2,sel_addObject_,pvVar1);
          }
          pvVar1 = _objc_msgSend(self_02,sel_nextObject,lVar5);
        }
        local_28 = _objc_msgSend(cls_NSArray,sel_arrayWithArray_,pvVar2);
        _objc_msgSend(pvVar2,sel_release);
        pvVar1 = _objc_msgSend(local_28,sel_objectEnumerator);
        _objc_msgSend(self_01,sel_addNodesInEnumerator_,pvVar1);
      }
    }
  }
  return '\x01';
}

*/
- (BOOL)handleMouseDownOutsideObjects:(id)aObjects atPoint:(NSPoint)aPoint hasAffectedObjects:(BOOL *)aObjects2
{
    id selection = [self selection];
    if (![[self class] isSelectionModifierKeyBeingHeld:[aObjects modifierFlags]]) {
        [[HSObjectAssistantController sharedAssistantController] setLocked:YES delegate:nil];
        [selection removeAllNodes];
        [[HSObjectAssistantController sharedAssistantController] setLocked:NO delegate:nil];
    }
    if ([aObjects clickCount] == 2) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HSHandleDoubleClickNotification object:[self representedObject]];
        if (![[[self context] queryHyperInterface:@protocol(HSEditorCanvasLayerContext)] handleDoubleClickOutsideNodesWithModifiers:[aObjects modifierFlags]] && [aObjects modifierFlags] < 0x10000) {
            [[HSObjectAssistantController sharedAssistantController] openDefaultEditingPaneForObject:[self representedObject]];
        }
    }
    /* Rubber-band selection. */
    id trackingRectSublayer = [self trackingRectSublayer];
    if ([trackingRectSublayer handleMouseDownAtPoint:aPoint event:aObjects hitTestInfo:nil]) {
        NSRect rect = [trackingRectSublayer lastTrackingRect];
        NSArray *nodes = [[[[self context] canvasHitTester] queryHyperInterface:@protocol(HSCanvasEditorHitTesting)] hitTestNodesInRect:rect];
        if ([nodes count] != 0) {
            *aObjects2 = YES;
            if ([[[[HSSelectionOperationVerifier alloc] initWithSelection:[self selection]] autorelease] verifyCanSelectNodesInArray:&nodes]) {
                NSMutableArray *unlockedNodes = [[NSMutableArray allocWithZone:[self zone]] init];
                NSEnumerator *enumerator = [nodes objectEnumerator];
                id node;
                while ((node = [enumerator nextObject]) != nil) {
                    id lockedAttribute = [node queryHyperInterface:@protocol(HSCardObjectLockedAttribute)];
                    if (lockedAttribute == nil || ![lockedAttribute isLocked]) {
                        [unlockedNodes addObject:node];
                    }
                }
                nodes = [NSArray arrayWithArray:unlockedNodes];
                [unlockedNodes release];
                [selection addNodesInEnumerator:[nodes objectEnumerator]];
            }
        }
    }
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000993cc @ 000993cc, 862 bytes * /

BOOL FUN_000993cc(HSSelectedObjectsCanvasLayer *self,SEL _cmd,id handleMouseDown,id inNode,
                 BOOL nodeIsSelected,BOOL *shouldIgnoreHitNode)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  undefined *puVar5;
  id pvVar6;
  int iVar7;
  
  pvVar2 = _objc_msgSend(self,sel_context);
  pvVar3 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_00367a28);
  pvVar4 = _objc_msgSend(handleMouseDown,sel_clickCount);
  puVar5 = _objc_msgSend(handleMouseDown,sel_modifierFlags);
  iVar7 = (int)nodeIsSelected;
  pvVar2 = pvVar4;
  pvVar6 = inNode;
  pvVar3 = _objc_msgSend(pvVar3,sel_handleClickWithModifiers_clickCount_inNode_nodeIsSelected_,
                         puVar5,pvVar4,inNode,iVar7);
  cVar1 = (char)pvVar3;
  if (pvVar4 == (id)0x2) {
    pvVar3 = _objc_msgSend(self,sel_selection,puVar5,pvVar2,pvVar6,iVar7);
    pvVar3 = _objc_msgSend(pvVar3,sel_selectedNode);
    if (pvVar3 != (id)0x0) {
      pvVar3 = _objc_msgSend(self,sel_selection,puVar5,pvVar2,pvVar6,iVar7);
      pvVar3 = _objc_msgSend(pvVar3,sel_selectedNode);
      puVar5 = &DAT_00367a64;
      pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_00367a64);
      pvVar3 = _objc_msgSend(pvVar3,sel_isLocked);
      if ((char)pvVar3 == '\0') {
        pvVar3 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter,puVar5);
        pvVar2 = _objc_msgSend(self,sel_selection);
        pvVar2 = _objc_msgSend(pvVar2,sel_selectedNode);
        _objc_msgSend(pvVar3,sel_postNotificationName_object_,*(undefined4 *)PTR_PTR_0033643c,pvVar2
                     );
        pvVar3 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
        pvVar4 = _objc_msgSend(self,sel_selection);
        pvVar4 = _objc_msgSend(pvVar4,sel_selectedNode);
        _objc_msgSend(pvVar3,sel_openDefaultEditingPaneForObject_,pvVar4);
        pvVar3 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
        puVar5 = *(undefined **)PTR_0033602c;
        pvVar3 = _objc_msgSend(pvVar3,sel_boolForKey_,puVar5);
        if ((char)pvVar3 != '\0') {
          pvVar3 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController,
                                 puVar5);
          pvVar3 = _objc_msgSend(pvVar3,sel_objectAssistant);
          puVar5 = (undefined *)0x0;
          _objc_msgSend(pvVar3,sel_setPrefersInspectorMode_,0);
        }
      }
    }
  }
  if (cVar1 == '\0') {
    pvVar2 = _objc_msgSend(self,sel_class,puVar5,pvVar2,pvVar6,iVar7);
    pvVar6 = _objc_msgSend(handleMouseDown,sel_modifierFlags);
    pvVar2 = _objc_msgSend(pvVar2,sel_isSelectionModifierKeyBeingHeld_,pvVar6);
    pvVar6 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
    _objc_msgSend(pvVar6,sel_setTemporaryHide_,(int)(char)pvVar2);
    if (nodeIsSelected == '\0') {
      pvVar2 = _objc_msgSend(self,sel_handleMouseDown_inUnselectedNode_shouldIgnoreHitNode_,
                             handleMouseDown,inNode,shouldIgnoreHitNode);
      cVar1 = (char)pvVar2;
    }
    else {
      pvVar2 = _objc_msgSend(self,sel_handleMouseDown_inSelectedNode_shouldIgnoreHitNode_,
                             handleMouseDown,inNode,shouldIgnoreHitNode);
      cVar1 = (char)pvVar2;
    }
  }
  return cVar1;
}

*/
- (BOOL)handleMouseDown:(id)aDown inNode:(id)aNode nodeIsSelected:(BOOL)aSelected shouldIgnoreHitNode:(BOOL *)aNode2
{
    NSUInteger clickCount = [aDown clickCount];
    BOOL handled = [[[self context] queryHyperInterface:@protocol(HSEditorCanvasLayerContext)] handleClickWithModifiers:[aDown modifierFlags] clickCount:clickCount inNode:aNode nodeIsSelected:aSelected];
    if (clickCount == 2) {
        id selectedNode = [[self selection] selectedNode];
        if (selectedNode != nil && ![[selectedNode queryHyperInterface:@protocol(HSCardObjectLockedAttribute)] isLocked]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:HSHandleDoubleClickNotification object:[[self selection] selectedNode]];
            [[HSObjectAssistantController sharedAssistantController] openDefaultEditingPaneForObject:[[self selection] selectedNode]];
            if ([[NSUserDefaults standardUserDefaults] boolForKey:HSForceSOTSForObjectDoubleClickKey]) {
                [[[HSObjectAssistantController sharedAssistantController] objectAssistant] setPrefersInspectorMode:NO];
            }
        }
    }
    if (handled) {
        return YES;
    }
    [[HSObjectAssistantController sharedAssistantController] setTemporaryHide:[[self class] isSelectionModifierKeyBeingHeld:[aDown modifierFlags]]];
    if (aSelected) {
        return [self handleMouseDown:aDown inSelectedNode:aNode shouldIgnoreHitNode:aNode2];
    }
    return [self handleMouseDown:aDown inUnselectedNode:aNode shouldIgnoreHitNode:aNode2];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000991ce @ 000991ce, 510 bytes * /

BOOL FUN_000991ce(HSSelectedObjectsCanvasLayer *self,SEL _cmd,id handleMouseDown,id inUnselectedNode
                 ,BOOL *shouldIgnoreHitNode)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  SEL op;
  char cVar5;
  id local_14;
  
  pvVar1 = _objc_msgSend(self,sel_selection);
  pvVar2 = _objc_msgSend(self,sel_class);
  pvVar3 = _objc_msgSend(handleMouseDown,sel_modifierFlags);
  pvVar2 = _objc_msgSend(pvVar2,sel_isSelectionModifierKeyBeingHeld_,pvVar3);
  if (pvVar1 != (id)0x0) {
    pvVar3 = _objc_msgSend(cls_HSSelectionOperationVerifier,sel_alloc,pvVar3);
    pvVar4 = _objc_msgSend(self,sel_selection);
    pvVar3 = _objc_msgSend(pvVar3,sel_initWithSelection_,pvVar4);
    pvVar3 = _objc_msgSend(pvVar3,sel_autorelease);
    local_14 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,inUnselectedNode);
    pvVar3 = _objc_msgSend(pvVar3,sel_verifyCanSelectNodesInArray_,&local_14);
    pvVar4 = _objc_msgSend(self,sel_isMouseStillDown);
    cVar5 = (char)pvVar4;
    if ((char)pvVar3 == '\0') goto LAB_000993b4;
    op = sel_selectNode_;
    if ((char)pvVar2 != '\0') {
      op = sel_addNode_;
    }
    _objc_msgSend(pvVar1,op,inUnselectedNode);
    if (cVar5 != '\0') {
      pvVar1 = _objc_msgSend(cls_HSSelectionOperationVerifier,sel_alloc,inUnselectedNode);
      pvVar2 = _objc_msgSend(self,sel_selection);
      pvVar1 = _objc_msgSend(pvVar1,sel_initWithSelection_,pvVar2);
      pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
      pvVar1 = _objc_msgSend(pvVar1,sel_selectedNodesArrayForMoveOperation);
      if (pvVar1 != (id)0x0) {
        _objc_msgSend(self,sel_trackMouseInNodes_withEvent_,pvVar1,handleMouseDown);
      }
    }
  }
  cVar5 = '\0';
LAB_000993b4:
  if (shouldIgnoreHitNode != (BOOL *)0x0) {
    *shouldIgnoreHitNode = cVar5;
  }
  return '\x01';
}

*/
- (BOOL)handleMouseDown:(id)aDown inUnselectedNode:(id)aNode shouldIgnoreHitNode:(BOOL *)aNode2
{
    id selection = [self selection];
    BOOL addToSelection = [[self class] isSelectionModifierKeyBeingHeld:[aDown modifierFlags]];
    BOOL ignoreHitNode = NO;
    if (selection != nil) {
        NSArray *nodes = [NSArray arrayWithObject:aNode];
        BOOL canSelect = [[[[HSSelectionOperationVerifier alloc] initWithSelection:[self selection]] autorelease] verifyCanSelectNodesInArray:&nodes];
        BOOL mouseStillDown = [self isMouseStillDown];
        if (!canSelect) {
            /* As in the original, the hit node is ignored only while the mouse is still down. */
            ignoreHitNode = mouseStillDown;
        } else {
            if (addToSelection) {
                [selection addNode:aNode];
            } else {
                [selection selectNode:aNode];
            }
            if (mouseStillDown) {
                NSArray *movedNodes = [[[[HSSelectionOperationVerifier alloc] initWithSelection:[self selection]] autorelease] selectedNodesArrayForMoveOperation];
                if (movedNodes != nil) {
                    [self trackMouseInNodes:movedNodes withEvent:aDown];
                }
            }
        }
    }
    if (aNode2 != NULL) {
        *aNode2 = ignoreHitNode;
    }
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00098ff2 @ 00098ff2, 476 bytes * /

BOOL FUN_00098ff2(HSSelectedObjectsCanvasLayer *self,SEL _cmd,id handleMouseDown,id inSelectedNode,
                 BOOL *shouldIgnoreHitNode)

{
  HSSelectedObjectsCanvasLayer *self_00;
  id pvVar1;
  id pvVar2;
  SEL pcVar3;
  bool bVar4;
  id *ppvVar5;
  char *pcVar6;
  undefined4 uVar7;
  char local_15;
  id local_14;
  
  self_00 = _objc_msgSend(self,sel_selection);
  pvVar1 = _objc_msgSend(self,sel_class);
  pvVar2 = _objc_msgSend(handleMouseDown,sel_modifierFlags);
  pvVar1 = _objc_msgSend(pvVar1,sel_isSelectionModifierKeyBeingHeld_,pvVar2);
  local_14 = (id)0x0;
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(cls_HSSelectionOperationVerifier,sel_alloc,pvVar2);
    pvVar2 = _objc_msgSend(self,sel_selection);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithSelection_,pvVar2);
    pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
    local_15 = '\x01';
    pvVar2 = _objc_msgSend(handleMouseDown,sel_modifierFlags);
    pcVar3 = sel_getSelectedNodesArrayForMoveOperation_canProceed_modifySelectionIfNeeded_;
    if (((uint)pvVar2 & 0x80000) != 0) {
      pcVar3 = sel_getSelectedNodesArrayForDragOperation_canProceed_modifySelectionIfNeeded_;
    }
    pcVar6 = &local_15;
    ppvVar5 = &local_14;
    uVar7 = 0;
    _objc_msgSend(pvVar1,pcVar3,ppvVar5,pcVar6,0);
    if (local_14 == (id)0x0) {
      bVar4 = local_15 == '\0';
      goto LAB_000991b6;
    }
    pvVar1 = _objc_msgSend(self,sel_isMouseStillDown,ppvVar5,pcVar6,uVar7);
    self_00 = self;
    pcVar3 = sel_trackMouseInNodes_withEvent_;
    inSelectedNode = local_14;
    if ((char)pvVar1 != '\0') goto LAB_000991af;
  }
  else {
    pvVar1 = _objc_msgSend(handleMouseDown,sel_modifierFlags,pvVar2);
    pcVar3 = sel_removeNode_;
    if ((((uint)pvVar1 & 0xffff0000) != 0x120000) ||
       (pvVar1 = _objc_msgSend(cls_HSImageObjectRestorer,sel_canRestoreNode_,inSelectedNode),
       pcVar3 = sel_removeNode_, (char)pvVar1 == '\0')) {
LAB_000991af:
      _objc_msgSend(self_00,pcVar3,inSelectedNode);
    }
  }
  bVar4 = false;
LAB_000991b6:
  if (shouldIgnoreHitNode != (BOOL *)0x0) {
    *shouldIgnoreHitNode = bVar4;
  }
  return '\x01';
}

*/
- (BOOL)handleMouseDown:(id)aDown inSelectedNode:(id)aNode shouldIgnoreHitNode:(BOOL *)aNode2
{
    id selection = [self selection];
    BOOL ignoreHitNode = NO;
    if (![[self class] isSelectionModifierKeyBeingHeld:[aDown modifierFlags]]) {
        HSSelectionOperationVerifier *verifier = [[[HSSelectionOperationVerifier alloc] initWithSelection:[self selection]] autorelease];
        NSArray *nodes = nil;
        BOOL canProceed = YES;
        [verifier getSelectedNodesArrayForMoveOperation:&nodes canProceed:&canProceed modifySelectionIfNeeded:NO];
        if (nodes == nil) {
            ignoreHitNode = !canProceed;
        } else if ([self isMouseStillDown]) {
            [self trackMouseInNodes:nodes withEvent:aDown];
        }
    } else {
        [(HSNodeSelection *)selection removeNode:aNode];
    }
    if (aNode2 != NULL) {
        *aNode2 = ignoreHitNode;
    }
    return YES;
}

- (void)trackMouseInNodes:(id)aNodes withEvent:(id)aEvent
{
    id pvVar2;
    id pvVar1_3;
    id pvVar1_5;

    if ([aNodes count] < 0x2) {
        pvVar2 = [aNodes lastObject];
        pvVar1_3 = [[HSMoveCardObjectTracker new] autorelease];
    }
    else {
        pvVar1_3 = [[HSMoveMultiSelectionTracker new] autorelease];
        pvVar2 = [[aNodes hyperObjectForAllInterfaces] queryHyperInterface:@protocol(HSNodeAttributes)];
    }
    [pvVar1_3 setTrackingObject:pvVar2];
    [self setTracker:pvVar1_3];
    pvVar1_5 = [self renderingView];
    [pvVar1_5 acceptDrawingQualityLoss:0.1];
    [[self retain] autorelease];
    [[HSTrackingLoop trackingLoopWithView:pvVar1_5 client:self] runWithMouseDownEvent:aEvent];
    [pvVar1_5 declineDrawingQualityLoss:0.1];
    [pvVar1_5 setNeedsDisplayOpenGLSurface:YES];
    [self setTracker:nil];
    [self setLastMouseEvent:nil];
}

- (id)hitTestNextInteractiveItemAfterItem:(id)aItem atPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo
{
    return self;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0009c7fe @ 0009c7fe, 64 bytes * /

BOOL FUN_0009c7fe(HSSelectedObjectsCanvasLayer *self,SEL _cmd)

{
  char cVar1;
  id pvVar2;
  bool bVar3;
  
  pvVar2 = _objc_msgSend(*(id *)PTR_00336058,sel_isActive);
  if ((char)pvVar2 == '\0') {
    bVar3 = false;
  }
  else {
    cVar1 = _StillDown();
    bVar3 = cVar1 != '\0';
  }
  return bVar3;
}

*/
- (BOOL)isMouseStillDown
{
    if (![NSApp isActive]) {
        return NO;
    }
    /* Carbon StillDown() is gone; ask AppKit for the left button state. */
    return ([NSEvent pressedMouseButtons] & 1) != 0;
}

- (void)invalidateDisplay
{
    [super invalidateDisplay];
    [_trackingRectSublayer invalidateDisplay];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0009c88c @ 0009c88c, 165 bytes * /

void FUN_0009c88c(HSSelectedObjectsCanvasLayer *self,SEL _cmd,NSRect renderRect)

{
  id pvVar1;
  HSSelectedObjectsCanvasLayer *local_1c;
  undefined *local_18;
  
  pvVar1 = _objc_msgSend(self,sel_selection);
  pvVar1 = _objc_msgSend(pvVar1,sel_shouldDisplaySelectionKnobs);
  if ((char)pvVar1 != '\0') {
    local_1c = self;
    local_18 = PTR_s_HSObservingNodesCanvasSublayer_0034ee60;
    _objc_msgSendSuper(&local_1c,sel_renderRect_,renderRect.origin,renderRect.size);
    _objc_msgSend(self->_trackingRectSublayer,sel_renderRect_,renderRect.origin,renderRect.size);
  }
  return;
}

*/
- (void)renderRect:(NSRect)aRect
{
    if ([[self selection] shouldDisplaySelectionKnobs]) {
        [super renderRect:aRect];
        [_trackingRectSublayer renderRect:aRect];
    }
}

- (void)representedObjectDidChange
{
    [super representedObjectDidChange];
    [_trackingRectSublayer representedObjectDidChange];
}

- (void)representedObjectWillChange
{
    [_trackingRectSublayer representedObjectWillChange];
    [super representedObjectWillChange];
}

- (void)renderingViewTransformDidChange
{
    [super renderingViewTransformDidChange];
    [_trackingRectSublayer renderingViewTransformDidChange];
}

- (void)contextDidChange
{
    [self setSelection:[[[self context] queryHyperInterface:@protocol(HSEditorCanvasLayerContext)] editorSelection]];
    [_trackingRectSublayer contextDidChange];
    [super contextDidChange];
}

- (void)contextWillChange
{
    [_trackingRectSublayer contextWillChange];
    [super contextWillChange];
}

- (void)setSelection:(id)aSelection
{
    id pvVar1;
    id pvVar1_3;

    if (_selection != aSelection) {
        pvVar1 = nil;
        if (_selection != nil) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSNodeSelectionDidChangeNotification" object:_selection];
            pvVar1 = _selection;
        }
        [pvVar1 release];
        pvVar1_3 = [aSelection retain];
        _selection = pvVar1_3;
        if (pvVar1_3 != nil) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(objectsInSelectionDidChange:) name:@"HSNodeSelectionDidChangeNotification" object:_selection];
        }
        [self selectionDidChange];
    }
}

- (id)selection
{
    return _selection;
}

- (BOOL)storesStubItems
{
    return NO;
}

- (void)dealloc
{
    NSNotificationCenter *pvVar1;
    HSTrackingRectCanvasLayer *self_00;

    pvVar1 = nil;
    if (_selection != nil) {
        pvVar1 = [NSNotificationCenter defaultCenter];
        [pvVar1 removeObserver:self name:@"HSNodeSelectionDidChangeNotification" object:_selection];
        pvVar1 = _selection;
    }
    [pvVar1 release];
    self_00 = nil;
    if (_trackingRectSublayer != nil) {
        pvVar1 = [NSNotificationCenter defaultCenter];
        [pvVar1 removeObserver:self name:@"HSTrackingRectCanvasLayerDidHandleMouseUpNotification" object:_trackingRectSublayer];
        self_00 = _trackingRectSublayer;
    }
    [self_00 setParentLayer:nil];
    [_trackingRectSublayer release];
    [_tracker setTrackingObject:nil];
    [_tracker release];
    [_lastMouseEvent release];
    [_flickRecognizer release];
    [_flickObjects release];
    [super dealloc];
}

@end

