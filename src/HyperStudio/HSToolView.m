#import "HSToolView.h"

@implementation HSToolView

/* i386 ivar offsets: _selection=0x1a4, _selectionChangeDelegate=0x1a8, _isNotEditable=0x1ac, _isUpdatingSelection=0x1ad, _canvasLayersRunningDisabledByToolManager=0x1ae, _isOccupiedByTool=0x1af, _isSynchronizingWithSelectionHost=0x1b0, _runTimeEditorController=0x1b4, _documentSelectionHolder=0x1b8 */

+ (id)visualizationProtocol
{
    return (id)@protocol(HSEditorVisualization);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00011e93 @ 00011e93, 593 bytes * /

void FUN_00011e93(HSToolView *self,SEL _cmd,id endGestureWithEvent)

{
  int iVar1;
  id pvVar2;
  id pvVar3;
  id self_00;
  undefined4 *puVar4;
  id pvVar5;
  id pvVar6;
  undefined *puVar7;
  undefined *puVar8;
  undefined *puVar9;
  undefined *puVar10;
  undefined *puVar11;
  undefined4 uVar12;
  id local_8c;
  HSToolView *local_7c;
  undefined *local_78;
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined local_50 [64];
  
  pvVar2 = _objc_msgSend(*(id *)(self->super_HSCardView + 0x170),sel_isEqual_,&cfstr_zoom);
  pvVar3 = _objc_msgSend(self,sel_selection);
  pvVar3 = _objc_msgSend(pvVar3,sel_nodesArray);
  local_74 = 0;
  local_70 = 0;
  local_6c = (int *)0x0;
  local_68 = 0;
  local_64 = 0;
  local_60 = 0;
  local_5c = 0;
  local_58 = 0;
  puVar7 = local_50;
  puVar4 = &local_74;
  puVar8 = (undefined *)0x10;
  local_8c = _objc_msgSend(pvVar3,sel_countByEnumeratingWithState_objects_count_,puVar4,puVar7,0x10)
  ;
  if (local_8c != (id)0x0) {
    iVar1 = *local_6c;
    do {
      pvVar6 = (id)0x0;
      do {
        if (iVar1 != *local_6c) {
          _objc_enumerationMutation(pvVar3);
        }
        pvVar5 = *(id *)(local_70 + (int)pvVar6 * 4);
        self_00 = _objc_msgSend(pvVar5,sel_attributeObservingController,puVar4,puVar7,puVar8);
        puVar11 = &DAT_003610ec;
        puVar10 = &DAT_00361150;
        puVar9 = &DAT_00361164;
        puVar8 = &DAT_0036118c;
        puVar7 = &DAT_003611a0;
        uVar12 = 0;
        puVar4 = _objc_msgSend(cls_NSEProtocolSet,sel_protocolSetWithProtocols_,&DAT_003611c8,
                               &DAT_003611a0,&DAT_0036118c,&DAT_00361164,&DAT_00361150,&DAT_003610ec
                               ,0);
        _objc_msgSend(self_00,sel_endContinuousChangeOfAttributeSet_);
        if ((char)pvVar2 != '\0') {
          pvVar5 = _objc_msgSend(pvVar5,sel_queryHyperInterface_,&DAT_003611dc,puVar7,puVar8,puVar9,
                                 puVar10,puVar11,uVar12);
          puVar4 = (undefined4 *)0x0;
          _objc_msgSend(pvVar5,sel_forceRecacheIfNeededForGroupObjectsOnly_,0);
        }
        pvVar6 = (id)((int)pvVar6 + 1);
      } while (pvVar6 < local_8c);
      puVar7 = local_50;
      puVar4 = &local_74;
      puVar8 = (undefined *)0x10;
      local_8c = _objc_msgSend(pvVar3,sel_countByEnumeratingWithState_objects_count_,puVar4,puVar7,
                               0x10,puVar9,puVar10,puVar11,uVar12);
    } while (local_8c != (id)0x0);
  }
  local_7c = self;
  local_78 = PTR_s_HSCardView_0034dba0;
  _objc_msgSendSuper(&local_7c,sel_endGestureWithEvent_,endGestureWithEvent);
  return;
}

*/
- (void)endGestureWithEvent:(id)aEvent
{
    BOOL zooming = [_gestureBeingHandled isEqual:@"zoom"];
    for (id node in [[self selection] nodesArray]) {
        [[node attributeObservingController] endContinuousChangeOfAttributeSet:[NSEProtocolSet protocolSetWithProtocols:@protocol(HSWidthAttribute), @protocol(HSHeightAttribute), @protocol(HSWidthScaleAttribute), @protocol(HSHeightScaleAttribute), @protocol(HSHorizontalScaleAttribute), @protocol(HSVerticalScaleAttribute), nil]];
        if (zooming) {
            [[node queryHyperInterface:@protocol(HSImageCacheAttributes)] forceRecacheIfNeededForGroupObjectsOnly:NO];
        }
    }
    [super endGestureWithEvent:aEvent];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000120e4 @ 000120e4, 472 bytes * /

void FUN_000120e4(HSToolView *self,SEL _cmd,id beginGestureWithEvent)

{
  int iVar1;
  id pvVar2;
  id self_00;
  undefined4 *puVar3;
  id pvVar4;
  undefined *puVar5;
  undefined *puVar6;
  undefined *puVar7;
  undefined *puVar8;
  undefined *puVar9;
  undefined4 uVar10;
  id local_88;
  HSToolView *local_7c;
  undefined *local_78;
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined local_50 [64];
  
  local_7c = self;
  local_78 = PTR_s_HSCardView_0034dba0;
  _objc_msgSendSuper(&local_7c,sel_beginGestureWithEvent_,beginGestureWithEvent);
  pvVar2 = _objc_msgSend(self,sel_selection);
  pvVar2 = _objc_msgSend(pvVar2,sel_nodesArray);
  local_74 = 0;
  local_70 = 0;
  local_6c = (int *)0x0;
  local_68 = 0;
  local_64 = 0;
  local_60 = 0;
  local_5c = 0;
  local_58 = 0;
  puVar5 = local_50;
  puVar3 = &local_74;
  puVar6 = (undefined *)0x10;
  local_88 = _objc_msgSend(pvVar2,sel_countByEnumeratingWithState_objects_count_,puVar3,puVar5,0x10)
  ;
  if (local_88 != (id)0x0) {
    iVar1 = *local_6c;
    do {
      pvVar4 = (id)0x0;
      do {
        if (iVar1 != *local_6c) {
          _objc_enumerationMutation(pvVar2);
        }
        self_00 = _objc_msgSend(*(id *)(local_70 + (int)pvVar4 * 4),sel_attributeObservingController
                                ,puVar3,puVar5,puVar6);
        puVar9 = &DAT_003610ec;
        puVar8 = &DAT_00361150;
        puVar7 = &DAT_00361164;
        puVar6 = &DAT_0036118c;
        puVar5 = &DAT_003611a0;
        uVar10 = 0;
        puVar3 = _objc_msgSend(cls_NSEProtocolSet,sel_protocolSetWithProtocols_,&DAT_003611c8,
                               &DAT_003611a0,&DAT_0036118c,&DAT_00361164,&DAT_00361150,&DAT_003610ec
                               ,0);
        _objc_msgSend(self_00,sel_beginContinuousChangeOfAttributeSet_);
        pvVar4 = (id)((int)pvVar4 + 1);
      } while (pvVar4 < local_88);
      puVar5 = local_50;
      puVar3 = &local_74;
      puVar6 = (undefined *)0x10;
      local_88 = _objc_msgSend(pvVar2,sel_countByEnumeratingWithState_objects_count_,puVar3,puVar5,
                               0x10,puVar7,puVar8,puVar9,uVar10);
    } while (local_88 != (id)0x0);
  }
  return;
}

*/
- (void)beginGestureWithEvent:(id)aEvent
{
    [super beginGestureWithEvent:aEvent];
    for (id node in [[self selection] nodesArray]) {
        [[node attributeObservingController] beginContinuousChangeOfAttributeSet:[NSEProtocolSet protocolSetWithProtocols:@protocol(HSWidthAttribute), @protocol(HSHeightAttribute), @protocol(HSWidthScaleAttribute), @protocol(HSHeightScaleAttribute), @protocol(HSHorizontalScaleAttribute), @protocol(HSVerticalScaleAttribute), nil]];
    }
}

- (id)helperForTracker
{
    return nil;
}

- (void)setOccupiedByTool:(BOOL)aTool
{
    _isOccupiedByTool = aTool;
}

- (BOOL)isOccupiedByTool
{
    return _isOccupiedByTool;
}

- (void)setEditable:(BOOL)aEditable
{
    if ((aEditable == NO) != (BOOL)_isNotEditable) {
        _isNotEditable = aEditable == NO;
    }
}

- (BOOL)isEditable
{
    return _isNotEditable == NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000122bc @ 000122bc, 123 bytes * /

void FUN_000122bc(HSToolView *self,SEL _cmd,NSRect drawQuartzRect)

{
  id self_00;
  HSToolView *local_14;
  undefined *local_10;
  
  self_00 = _objc_msgSend(cls_NSAutoreleasePool,sel_new);
  local_14 = self;
  local_10 = PTR_s_HSCardView_0034dba0;
  _objc_msgSendSuper(&local_14,sel_drawQuartzRect_,drawQuartzRect.origin,drawQuartzRect.size);
  _objc_msgSend(self_00,sel_release);
  return;
}

*/
- (void)drawQuartzRect:(NSRect)aRect
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    [super drawQuartzRect:aRect];
    [pool release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00012337 @ 00012337, 137 bytes * /

void FUN_00012337(HSToolView *self,SEL _cmd,NSRect postDrawContentRect)

{
  id self_00;
  HSToolView *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_HSCardView_0034dba0;
  _objc_msgSendSuper(&local_14,sel_postDrawContentRect_,postDrawContentRect.origin,
                     postDrawContentRect.size);
  self_00 = _objc_msgSend(self,sel_runTimeEditorController);
  _objc_msgSend(self_00,sel_hyperRenderRect_,postDrawContentRect.origin,postDrawContentRect.size);
  return;
}

*/
- (void)postDrawContentRect:(NSRect)aRect
{
    [super postDrawContentRect:aRect];
    [[self runTimeEditorController] hyperRenderRect:aRect];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000123c0 @ 000123c0, 433 bytes * /

BOOL FUN_000123c0(HSToolView *self,SEL _cmd,SEL handleKeyEventSelector)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  undefined *puVar3;
  undefined4 uVar4;
  HSToolView *local_1c;
  undefined *local_18;
  
  pvVar1 = _objc_msgSend(self,sel_runTimeEditorController);
  pvVar1 = _objc_msgSend(pvVar1,sel_runtimeEditorsHandleKeyEventSelector_,handleKeyEventSelector);
  if ((char)pvVar1 == '\0') {
    local_1c = self;
    local_18 = PTR_s_HSCardView_0034dba0;
    pvVar1 = _objc_msgSendSuper(&local_1c,sel_handleKeyEventSelector_,handleKeyEventSelector);
    if ((char)pvVar1 == '\0') {
      if (sel_cancelOperation_ != handleKeyEventSelector) {
        return '\0';
      }
      pvVar1 = _objc_msgSend(self,sel_selectedHyperObject);
      puVar3 = &DAT_00360e80;
      pvVar2 = _objc_msgSend(pvVar1,sel_implementsHyperInterface_,&DAT_00360e80);
      if ((char)pvVar2 == '\0') {
        puVar3 = &DAT_00360ffc;
        pvVar2 = _objc_msgSend(pvVar1,sel_implementsHyperInterface_,&DAT_00360ffc);
        if ((char)pvVar2 == '\0') {
          puVar3 = &DAT_0036104c;
          pvVar1 = _objc_msgSend(pvVar1,sel_implementsHyperInterface_,&DAT_0036104c);
          if ((char)pvVar1 == '\0') {
            return '\0';
          }
        }
        pvVar1 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController,puVar3)
        ;
        pvVar2 = _objc_msgSend(pvVar1,sel_isActive);
        if ((char)pvVar2 == '\0') {
          return '\0';
        }
        uVar4 = 0;
        op = sel_setActive_explicitlyByUser_;
      }
      else {
        pvVar1 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController,puVar3)
        ;
        uVar4 = 1;
        _objc_msgSend(pvVar1,sel_setTemporaryHide_,1);
        pvVar1 = _objc_msgSend(self,sel_selectionObject);
        op = sel_removeAllNodes;
      }
      _objc_msgSend(pvVar1,op,uVar4);
      return '\x01';
    }
  }
  return '\x01';
}

*/
- (BOOL)handleKeyEventSelector:(SEL)aSelector
{
    if ([[self runTimeEditorController] runtimeEditorsHandleKeyEventSelector:aSelector]) {
        return YES;
    }
    if ([super handleKeyEventSelector:aSelector]) {
        return YES;
    }
    if (aSelector != @selector(cancelOperation:)) {
        return NO;
    }
    id object = [self selectedHyperObject];
    if ([object implementsHyperInterface:@protocol(HSCardObjectAttributes)]) {
        [[HSObjectAssistantController sharedAssistantController] setTemporaryHide:YES];
        [[self selectionObject] removeAllNodes];
    }
    else {
        if (![object implementsHyperInterface:@protocol(HSCardAttributes)] && ![object implementsHyperInterface:@protocol(HSStackAttributes)]) {
            return NO;
        }
        id assistant = [HSObjectAssistantController sharedAssistantController];
        if (![assistant isActive]) {
            return NO;
        }
        [assistant setActive:NO explicitlyByUser:NO];
    }
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00012571 @ 00012571, 206 bytes * /

void FUN_00012571(HSToolView *self,SEL _cmd,NSPoint updateCursorAtPoint,BOOL inside,
                 uint modifierFlags,id event)

{
  id pvVar1;
  uint uVar2;
  float fVar3;
  float fVar4;
  uint uVar5;
  id pvVar6;
  HSToolView *local_1c;
  undefined *local_18;
  
  pvVar1 = _objc_msgSend(self,sel_runTimeEditorController);
  uVar2 = (uint)(byte)inside;
  fVar3 = updateCursorAtPoint.x;
  fVar4 = updateCursorAtPoint.y;
  uVar5 = modifierFlags;
  pvVar6 = event;
  pvVar1 = _objc_msgSend(pvVar1,sel_runtimeEditorsCursorAtPoint_inside_modifierFlags_event_,
                         updateCursorAtPoint.x,updateCursorAtPoint.y,uVar2,modifierFlags,event);
  if (pvVar1 == (id)0x0) {
    local_1c = self;
    local_18 = PTR_s_HSCardView_0034dba0;
    _objc_msgSendSuper(&local_1c,sel_updateCursorAtPoint_inside_modifierFlags_event_,
                       updateCursorAtPoint.x,updateCursorAtPoint.y,(int)inside,modifierFlags,event);
  }
  else {
    _objc_msgSend(pvVar1,sel_set,fVar3,fVar4,uVar2,uVar5,pvVar6);
  }
  return;
}

*/
- (void)updateCursorAtPoint:(NSPoint)aPoint inside:(BOOL)aInside modifierFlags:(NSUInteger)aFlags event:(id)aEvent
{
    NSCursor *cursor = [[self runTimeEditorController] runtimeEditorsCursorAtPoint:aPoint inside:aInside modifierFlags:aFlags event:aEvent];
    if (cursor == nil) {
        [super updateCursorAtPoint:aPoint inside:aInside modifierFlags:aFlags event:aEvent];
    }
    else {
        [cursor set];
    }
}

- (void)handleMouseMoved:(id)aMoved
{
    if (![[self runTimeEditorController] runtimeEditorsHandleMouseMoved:aMoved]) {
        [super handleMouseMoved:aMoved];
    }
    else {
        [self updateCursorWithMouseEvent:aMoved];
    }
}

- (void)mouseDown:(id)aDown
{
    if ([[self userObject] isInDocument]) {
        if ([self selection] != nil) {
            [self makeCurrentSelectionHost];
        }
    }
    if (![[self runTimeEditorController] runtimeEditorsHandleMouseDown:aDown]) {
        [super mouseDown:aDown];
    }
}

- (void)endEditorForObject:(id)aObject
{
    [[self runTimeEditorController] deactivateEditorForObject:aObject];
}

- (BOOL)startEditor:(id)aEditor forObject:(id)aObject creationMode:(BOOL)aMode
{
    return (BOOL)[[self runTimeEditorController] startEditor:aEditor forObject:aObject creationMode:aMode];
}

- (BOOL)startEditorForObject:(id)aObject creationMode:(BOOL)aMode
{
    return (BOOL)[[self runTimeEditorController] startEditorForObject:aObject creationMode:aMode];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00011baa @ 00011baa, 352 bytes * /

void FUN_00011baa(HSToolView *self,SEL _cmd,id cardWillChangeChildren)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  cfstringStruct *pcVar4;
  
  pvVar1 = _objc_msgSend(cardWillChangeChildren,sel_userInfo);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_HSNodeChildrenForRemoval);
  pvVar2 = _objc_msgSend(cardWillChangeChildren,sel_userInfo);
  pcVar4 = &cfstr_HSNodeChildrenForAddition;
  pvVar2 = _objc_msgSend(pvVar2,sel_objectForKey_,&cfstr_HSNodeChildrenForAddition);
  pvVar3 = _objc_msgSend(pvVar1,sel_count);
  if (pvVar3 == (id)0x0) {
    pvVar1 = _objc_msgSend(pvVar2,sel_count,pcVar4);
    if (pvVar1 == (id)0x0) {
      return;
    }
    pvVar1 = _objc_msgSend(self,sel_isAnyGroupObjectInChildren_,pvVar2);
    if ((char)pvVar1 != '\0') {
      return;
    }
    pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager,pvVar2);
    pvVar1 = _objc_msgSend(pvVar1,sel_currentTool);
    pvVar1 = _objc_msgSend(pvVar1,sel_shouldResetToolOnAddObjects);
    if ((char)pvVar1 == '\0') {
      return;
    }
    pvVar2 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager,pvVar2);
    pvVar1 = (id)0x0;
    op = sel_selectToolWithTag_;
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_selectionObject,pcVar4);
    op = sel_removeNodesIfExist_;
  }
  _objc_msgSend(pvVar2,op,pvVar1);
  return;
}

*/
- (void)cardWillChangeChildren:(id)aChildren
{
    id removal = [[aChildren userInfo] objectForKey:@"HSNodeChildrenForRemoval"];
    id addition = [[aChildren userInfo] objectForKey:@"HSNodeChildrenForAddition"];
    if ([removal count] != 0) {
        [[self selectionObject] removeNodesIfExist:removal];
        return;
    }
    if ([addition count] == 0) {
        return;
    }
    if ([self isAnyGroupObjectInChildren:addition]) {
        return;
    }
    if (![[[HSToolManager sharedToolManager] currentTool] shouldResetToolOnAddObjects]) {
        return;
    }
    [[HSToolManager sharedToolManager] selectToolWithTag:0];
}

- (BOOL)isAnyGroupObjectInChildren:(id)aChildren
{
    id pvVar1;
    BOOL BVar3;

    pvVar1 = [aChildren queryHyperInterfaceForAnyObjects:@protocol(HSCardObjectGroupAttribute)];
    BVar3 = (BOOL)[pvVar1 isGroupObject];
    if ([pvVar1 lastHyperAccessDidReturnMultipleValues]) {
        BVar3 = YES;
    }
    return BVar3;
}

- (void)registerObservingUserObjectAttributesChange
{
    [super registerObservingUserObjectAttributesChange];
    [[self card] addObserver:self selector:@selector(cardWillChangeChildren:) ofChanges:HSActualWillAttributeChanges ofAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:-0.25];
}

- (void)unregisterObservingUserObjectAttributesChange
{
    [super unregisterObservingUserObjectAttributesChange];
    [[self card] removeObserver:self selector:@selector(cardWillChangeChildren:) ofChanges:HSActualWillAttributeChanges ofAttribute:@protocol(HSNodeContainerChildrenAttribute)];
}

- (void)setUserObject:(id)aObject
{
    id pvVar1;

    pvVar1 = [self userObject];
    if (pvVar1 != aObject) {
        [self saveEditingState];
        [_runTimeEditorController deactivateAllEditors];
        pvVar1 = [self selectionObject];
        [pvVar1 beginSelectionChanging];
        pvVar1 = [self selectionObject];
        [pvVar1 removeAllNodes];
        [super setUserObject:aObject];
        pvVar1 = [self selectionObject];
        [pvVar1 endSelectionChanging];
    }
}

- (void)updateSelectionWithSelectedObject:(id)aObject
{
    id pvVar1;
    id pvVar2;
    id pvVar1_3;

    if ((aObject != nil) && (pvVar1 = [aObject queryHyperInterface:@protocol(HSCardObjectAttributes)], pvVar1 == nil)) {
        return;
    }
    if (![aObject isHyperProxy]) {
        pvVar2 = nil;
    }
    else {
        pvVar1_3 = [aObject allHyperInterfaces];
        if ([pvVar1_3 count] < 0x2) {
            pvVar2 = nil;
            aObject = [pvVar1_3 lastObject];
        }
        else {
            aObject = nil;
            pvVar2 = pvVar1_3;
        }
    }
    [self updateSelectionWithSelectedCardObject:aObject orObjects:pvVar2 synchronizingWithAnotherSelectionHost:YES];
}

- (id)documentSelectionHolder
{
    return _documentSelectionHolder;
}

- (void)setDocumentSelectionHolder:(id)aHolder
{
    _documentSelectionHolder = aHolder;
}

- (id)ownSelectedObject
{
    return [self selectedHyperObject];
}

- (BOOL)supportsCanvasLayersRunningInCurrentActiveState
{
    BOOL bVar2;

    if (![super supportsCanvasLayersRunningInCurrentActiveState]) {
        bVar2 = NO;
    }
    else {
        bVar2 = _canvasLayersRunningDisabledByToolManager == NO;
    }
    return bVar2;
}

- (void)toolManagerEnableCanvasLayersRunning
{
    _canvasLayersRunningDisabledByToolManager = NO;
    [self refreshCanvasLayersRunningInCurrentActiveState];
}

- (void)toolManagerDisableCanvasLayersRunning
{
    _canvasLayersRunningDisabledByToolManager = YES;
    [self refreshCanvasLayersRunningInCurrentActiveState];
}

- (BOOL)isPrimarySelectionAccessorForCurrentlyHeldSelection
{
    return [self selectedHyperObject] != [self userObject];
}

- (BOOL)updateSelectionWithInactiveCardViewSelectionAccessor:(id)aAccessor
{
    return NO;
}

- (BOOL)isInterestedToBeSynchronizedWithInactiveCardViewSelectionAccessor:(id)aAccessor
{
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0001189e @ 0001189e, 279 bytes * /

BOOL FUN_0001189e(HSToolView *self,SEL _cmd,id updateSelectionWithSelectionAccessor)

{
  BOOL BVar1;
  id pvVar2;
  undefined4 local_20;
  undefined4 local_1c;
  undefined4 local_18;
  undefined4 local_14;
  
  pvVar2 = _objc_msgSend(updateSelectionWithSelectionAccessor,sel_implementsHyperInterface_,
                         &DAT_00360e44);
  if ((char)pvVar2 == '\0') {
    pvVar2 = _objc_msgSend(updateSelectionWithSelectionAccessor,sel_implementsHyperInterface_,
                           &DAT_00360e6c);
    if ((char)pvVar2 == '\0') {
      BVar1 = '\0';
    }
    else {
      local_1c = 0;
      local_20 = 0;
      _objc_msgSend(updateSelectionWithSelectionAccessor,sel_getSelectedHyperObject_orObjects_,
                    &local_20,&local_1c);
      pvVar2 = _objc_msgSend(self,
                             sel_updateSelectionWithSelectedCard_orCards_synchronizingWithAnotherSelectionHost_
                             ,local_20,local_1c,0);
      BVar1 = (BOOL)pvVar2;
    }
  }
  else {
    local_14 = 0;
    local_18 = 0;
    _objc_msgSend(updateSelectionWithSelectionAccessor,sel_getSelectedHyperObject_orObjects_,
                  &local_18,&local_14);
    pvVar2 = _objc_msgSend(self,
                           sel_updateSelectionWithSelectedCardObject_orObjects_synchronizingWithAnotherSelectionHost_
                           ,local_18,local_14,0);
    BVar1 = (BOOL)pvVar2;
  }
  return BVar1;
}

*/
- (BOOL)updateSelectionWithSelectionAccessor:(id)aAccessor
{
    id object = nil;
    id objects = nil;
    if ([aAccessor implementsHyperInterface:@protocol(HSCardObjectSelectionAccessor)]) {
        [aAccessor getSelectedHyperObject:&object orObjects:&objects];
        return [self updateSelectionWithSelectedCardObject:object orObjects:objects synchronizingWithAnotherSelectionHost:NO];
    }
    if ([aAccessor implementsHyperInterface:@protocol(HSCardSelectionAccessor)]) {
        [aAccessor getSelectedHyperObject:&object orObjects:&objects];
        return [self updateSelectionWithSelectedCard:object orCards:objects synchronizingWithAnotherSelectionHost:NO];
    }
    return NO;
}

- (BOOL)updateSelectionWithSelectedCard:(id)aCard orCards:(id)aCards synchronizingWithAnotherSelectionHost:(BOOL)aHost
{
    id pvVar1;

    if (((aCard != nil) && (aCards == nil)) && (pvVar1 = [self card], pvVar1 == aCard)) {
        _isUpdatingSelection = YES;
        _isSynchronizingWithSelectionHost = aHost;
        [self selectObject:nil];
        _isUpdatingSelection = NO;
        _isSynchronizingWithSelectionHost = NO;
        return YES;
    }
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000116f9 @ 000116f9, 294 bytes * /

BOOL FUN_000116f9(HSToolView *self,SEL _cmd,id updateSelectionWithSelectedCardObject,id orObjects,
                 BOOL synchronizingWithAnotherSelectionHost)

{
  id pvVar1;
  HSToolView *self_00;
  SEL op;
  
  self->_isUpdatingSelection = '\x01';
  self->_isSynchronizingWithSelectionHost = synchronizingWithAnotherSelectionHost;
  if ((orObjects != (id)0x0) ||
     ((updateSelectionWithSelectedCardObject != (id)0x0 &&
      (pvVar1 = _objc_msgSend(updateSelectionWithSelectedCardObject,sel_isGroupObject),
      (char)pvVar1 == '\0')))) {
    pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
    pvVar1 = _objc_msgSend(pvVar1,sel_currentTool);
    pvVar1 = _objc_msgSend(pvVar1,sel_shouldResetToolOnSelectObjects);
    if ((char)pvVar1 != '\0') {
      pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
      _objc_msgSend(pvVar1,sel_selectToolWithTag_,0);
    }
  }
  self_00 = self;
  op = sel_selectObjects_;
  if ((orObjects == (id)0x0) &&
     (op = sel_selectObject_, updateSelectionWithSelectedCardObject == (id)0x0)) {
    self_00 = _objc_msgSend(self,sel_selection);
    op = sel_removeAllNodes;
  }
  _objc_msgSend(self_00,op);
  self->_isUpdatingSelection = '\0';
  self->_isSynchronizingWithSelectionHost = '\0';
  return '\x01';
}

*/
- (BOOL)updateSelectionWithSelectedCardObject:(id)aObject orObjects:(id)aObjects synchronizingWithAnotherSelectionHost:(BOOL)aHost
{
    _isUpdatingSelection = YES;
    _isSynchronizingWithSelectionHost = aHost;
    if (aObjects != nil || (aObject != nil && ![aObject isGroupObject])) {
        if ([[[HSToolManager sharedToolManager] currentTool] shouldResetToolOnSelectObjects]) {
            [[HSToolManager sharedToolManager] selectToolWithTag:0];
        }
    }
    if (aObjects != nil) {
        [self selectObjects:aObjects];
    }
    else if (aObject != nil) {
        [self selectObject:aObject];
    }
    else {
        [[self selection] removeAllNodes];
    }
    _isUpdatingSelection = NO;
    _isSynchronizingWithSelectionHost = NO;
    return YES;
}

- (void)selectHyperObjects:(id)aObjects
{
    [self selectObjects:aObjects];
    if ([self selection] != nil) {
        [self localNotifyHyperSelectionDidChangeAndActivate:YES];
    }
}

- (void)selectHyperObject:(id)aObject
{
    [self selectObject:aObject];
    if ([self selection] != nil) {
        [self localNotifyHyperSelectionDidChangeAndActivate:YES];
    }
}

- (void)selectObjects:(id)aObjects
{
    [self selectObjects:aObjects objectsAreNodes:NO];
}

- (void)selectObject:(id)aObject
{
    [self selectNode:[aObject queryHyperInterface:@protocol(HSNodeChild)]];
}

- (void)addObjectToSelection:(id)aSelection
{
    [self addNodeToSelection:[aSelection queryHyperInterface:@protocol(HSNodeChild)]];
}

- (void)selectNodes:(id)aNodes
{
    [self selectObjects:aNodes objectsAreNodes:YES];
}

- (void)selectObjects:(id)aObjects objectsAreNodes:(BOOL)aNodes
{
    id pvVar1;
    id pvVar2;
    id pvVar4;

    pvVar1 = [self selectionObject];
    [pvVar1 beginSelectionChanging];
    [[self selectionObject] removeAllNodes];
    [aObjects objectEnumerator];
    while (pvVar4 = [pvVar1 nextObject], pvVar4 != nil) {
        pvVar2 = pvVar4;
        if (aNodes == NO) {
            pvVar2 = [pvVar4 queryHyperInterface:@protocol(HSNodeAttributes)];
        }
        pvVar4 = [pvVar4 queryHyperInterface:@protocol(HSNodeChild)];
        if (pvVar2 != nil) {
            pvVar4 = [pvVar4 hyperParent];
            if (pvVar4 == [self userObject]) {
                pvVar4 = [self selectionObject];
                [pvVar4 addNode:pvVar2];
            }
        }
    }
    [[self selectionObject] endSelectionChanging];
}

- (void)selectNode:(id)aNode
{
    if (aNode != nil) {
        if ([[aNode queryHyperInterface:@protocol(HSNodeChild)] hyperParent] == [self userObject]) {
            [[self selectionObject] selectNode:aNode];
        }
    }
}

- (void)addNodeToSelection:(id)aSelection
{
    if (aSelection != nil) {
        if ([[aSelection queryHyperInterface:@protocol(HSNodeChild)] hyperParent] == [self userObject]) {
            [[self selectionObject] addNode:aSelection];
        }
    }
}

- (id)createCanvasHitTester
{
    return [[HSEditorCanvasHitTester alloc] initWithHitTestingInterface:[HSProtocolIdentifier identifierForProtocol:@protocol(HSUserObjectEditorHitTesting)]];
}

- (id)createRootCanvasLayer
{
    return [[HSEditorRootCanvasLayer alloc] init];
}

- (void)deactivateRunTimeEditor
{
    [[self runTimeEditorController] deactivateInPlaceEditor];
}

- (void)saveEditingState
{
    [[[HSToolManager sharedToolManager] currentTool] saveChanges];
    [self saveRunTimeEditors];
}

- (void)saveRunTimeEditors
{
    [_runTimeEditorController saveAllEditors];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00010f17 @ 00010f17, 541 bytes * /

void FUN_00010f17(HSToolView *self,SEL _cmd,id toolManagerDidSelectTool,id oldTool,BOOL explicitly)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  
  pvVar2 = _objc_msgSend(self,sel_allowsSelectionWithTool_,oldTool);
  pvVar3 = _objc_msgSend(toolManagerDidSelectTool,sel_allowsEditingToolView);
  _objc_msgSend(self,sel_setEditable_,(int)(char)pvVar3);
  pvVar3 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar3 = _objc_msgSend(pvVar3,sel_currentTool);
  pvVar4 = _objc_msgSend(self,sel_allowsSelectionWithTool_,pvVar3);
  cVar1 = (char)pvVar4;
  pvVar4 = _objc_msgSend(self,sel_userObject);
  pvVar4 = _objc_msgSend(pvVar4,sel_isInDocument);
  if (((char)pvVar4 != '\0') && ((char)pvVar2 != cVar1)) {
    if (cVar1 != '\0') {
      pvVar2 = _objc_msgSend(self,sel_selection,pvVar3);
      _objc_msgSend(pvVar2,sel_objectsCount);
    }
    pvVar3 = (id)(int)cVar1;
    _objc_msgSend(self,sel_localNotifyHyperSelectionDidChangeAndActivate_,pvVar3);
  }
  pvVar2 = self->_runTimeEditorController;
  pvVar3 = _objc_msgSend(toolManagerDidSelectTool,sel_allowsActiveInPlaceEditors,pvVar3);
  _objc_msgSend(pvVar2,sel_setAllowsInPlaceEditors_,(int)(char)pvVar3);
  pvVar2 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar2 = _objc_msgSend(pvVar2,sel_buttonShapeCreationToolIdentifiers);
  pvVar3 = _objc_msgSend(toolManagerDidSelectTool,sel_toolIdentifier);
  pvVar2 = _objc_msgSend(pvVar2,sel_containsObject_,pvVar3);
  if ((char)pvVar2 == '\0') {
    pvVar2 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager,pvVar3);
    pvVar2 = _objc_msgSend(pvVar2,sel_buttonShapeCreationToolIdentifiers);
    pvVar3 = _objc_msgSend(oldTool,sel_toolIdentifier);
    pvVar2 = _objc_msgSend(pvVar2,sel_containsObject_,pvVar3);
    if ((char)pvVar2 == '\0') {
      return;
    }
  }
  _objc_msgSend(self,sel_updateCursor,pvVar3);
  return;
}

*/
- (void)toolManagerDidSelectTool:(id)aTool oldTool:(id)aTool2 explicitly:(BOOL)aExplicitly
{
    BOOL allowedBefore = [self allowsSelectionWithTool:aTool2];
    [self setEditable:[aTool allowsEditingToolView]];
    BOOL allowedNow = [self allowsSelectionWithTool:[[HSToolManager sharedToolManager] currentTool]];
    if ([[self userObject] isInDocument] && allowedBefore != allowedNow) {
        if (allowedNow) {
            [[self selection] objectsCount];
        }
        [self localNotifyHyperSelectionDidChangeAndActivate:allowedNow];
    }
    [_runTimeEditorController setAllowsInPlaceEditors:[aTool allowsActiveInPlaceEditors]];
    if ([[[HSToolManager sharedToolManager] buttonShapeCreationToolIdentifiers] containsObject:[aTool toolIdentifier]]
        || [[[HSToolManager sharedToolManager] buttonShapeCreationToolIdentifiers] containsObject:[aTool2 toolIdentifier]]) {
        [self updateCursor];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00010eb1 @ 00010eb1, 102 bytes * /

void FUN_00010eb1(HSToolView *self,SEL _cmd,id toolManagerWillSelectTool,BOOL explicitly)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(toolManagerWillSelectTool,sel_allowsActiveInPlaceEditors);
  if ((((char)pvVar1 != '\0') &&
      (pvVar1 = _objc_msgSend(toolManagerWillSelectTool,sel_preservesActiveInPlaceEditors),
      (char)pvVar1 != '\0')) && (explicitly == '\0')) {
    return;
  }
  _objc_msgSend(self->_runTimeEditorController,sel_deactivateInPlaceEditor);
  return;
}

*/
- (void)toolManagerWillSelectTool:(id)aTool explicitly:(BOOL)aExplicitly
{
    if ([aTool allowsActiveInPlaceEditors] && [aTool preservesActiveInPlaceEditors] && !aExplicitly) {
        return;
    }
    [_runTimeEditorController deactivateInPlaceEditor];
}

- (BOOL)becomeFirstResponder
{
    if ([[self userObject] isInDocument]) {
        [self localNotifyHyperSelectionDidChangeAndActivate:(unsigned int)([self selection] != nil)]
        ;
    }
    return YES;
}

- (void)displaySelectionHolderInactiveState
{

}

- (void)displaySelectionHolderActiveStateAndBecomeFirstResponder:(BOOL)aResponder
{
    if (aResponder != NO) {
        if ([[self window] firstResponder] != self) {
            [[self window] makeFirstResponder:self];
        }
    }
}

- (void)setSelectionChangeDelegate:(id)aDelegate
{
    _selectionChangeDelegate = aDelegate;
}

- (id)selectedHyperObject
{
    id pvVar1;
    id pvVar2;

    pvVar1 = [_runTimeEditorController selectedRunTimeEditorObject];
    if (pvVar1 == nil) {
        pvVar1 = [[self selection] selectedObject];
    }
    if ((pvVar1 == nil) && (pvVar2 = [self selection], pvVar2 != nil)) {
        pvVar1 = [self userObject];
    }
    return pvVar1;
}

- (id)selectionChangeDelegate
{
    return _selectionChangeDelegate;
}

- (void)didChangeHitTestingInterface
{
    [_selection ensureSelectionContainsOnlyAllowedNodes];
}

- (BOOL)selection:(id)aSelection shouldIncludeNode:(id)aNode
{
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00010c1b @ 00010c1b, 251 bytes * /

void FUN_00010c1b(HSToolView *self,SEL _cmd,id selectionDidChange,BOOL wasExpanded)

{
  char cVar1;
  id pvVar2;
  HSToolView *pHVar3;
  char cVar4;
  
  pvVar2 = _objc_msgSend(self,sel_userObject);
  pvVar2 = _objc_msgSend(pvVar2,sel_isInDocument);
  if ((char)pvVar2 != '\0') {
    pvVar2 = _objc_msgSend(self,sel_selection);
    if (pvVar2 != (id)0x0) {
      pvVar2 = _objc_msgSend(self,sel_window);
      pHVar3 = _objc_msgSend(pvVar2,sel_firstResponder);
      if ((pHVar3 == self) || (wasExpanded != '\0')) {
        cVar1 = '\x01';
      }
      else {
        cVar1 = '\0';
      }
      if ((self->_isUpdatingSelection == '\0') || (self->_isSynchronizingWithSelectionHost == '\0'))
      {
        cVar4 = '\0';
      }
      else {
        cVar4 = '\x01';
      }
      _objc_msgSend(self,
                    sel_localNotifyHyperSelectionDidChangeAndActivate_suppressLegacySelectionSynchronization_
                    ,(int)cVar1,(int)cVar4);
    }
  }
  pvVar2 = _objc_msgSend(self->_runTimeEditorController,sel_selectedRunTimeEditorObject);
  if (pvVar2 != (id)0x0) {
    _objc_msgSend(self->_runTimeEditorController,sel_deactivateInPlaceEditor);
  }
  return;
}

*/
- (void)selectionDidChange:(id)aChange wasExpanded:(BOOL)aExpanded
{
    if ([[self userObject] isInDocument] && [self selection] != nil) {
        BOOL activate = [[self window] firstResponder] == self || aExpanded;
        BOOL suppress = _isUpdatingSelection && _isSynchronizingWithSelectionHost;
        [self localNotifyHyperSelectionDidChangeAndActivate:activate suppressLegacySelectionSynchronization:suppress];
    }
    if ([_runTimeEditorController selectedRunTimeEditorObject] != nil) {
        [_runTimeEditorController deactivateInPlaceEditor];
    }
}

- (void)localNotifyHyperSelectionDidChangeAndActivate:(BOOL)aActivate
{
    [self localNotifyHyperSelectionDidChangeAndActivate:aActivate suppressLegacySelectionSynchronization:NO];
}

- (void)localNotifyHyperSelectionDidChangeAndActivate:(BOOL)aActivate suppressLegacySelectionSynchronization:(BOOL)aSynchronization
{
    id pvVar1;

    if (aSynchronization == NO) {
        [self notifyHyperSelectionDidChangeAndActivate:aActivate];
    }
    pvVar1 = [_documentSelectionHolder currentSelectionHost];
    if (aSynchronization == NO) {
        [_documentSelectionHolder selectionHostDidChangeSelectedObject:self];
    }
    if ((aActivate != NO) || (pvVar1 == nil)) {
        [self makeCurrentSelectionHost];
    }
}

- (void)makeCurrentSelectionHost
{
    [_documentSelectionHolder makeCurrentSelectionHost:self];
}

- (id)selectionObject
{
    HSNodeSelection *pHVar1;
    HSNodeSelection *pHVar1_2;

    pHVar1 = _selection;
    if (pHVar1 == nil) {
        pHVar1_2 = [[HSNodeSelection alloc] init];
        _selection = pHVar1_2;
        [pHVar1_2 setOwner:self];
        pHVar1 = _selection;
    }
    return pHVar1;
}

- (id)selection
{
    id pvVar1_3;

    if (![self allowsSelectionWithTool:[[HSToolManager sharedToolManager] currentTool]]) {
        pvVar1_3 = nil;
    }
    else {
        pvVar1_3 = [self selectionObject];
    }
    return pvVar1_3;
}

- (BOOL)allowsSelectionWithTool:(id)aTool
{
    BOOL bVar2;

    if (![aTool allowsSelection]) {
        bVar2 = NO;
    }
    else {
        bVar2 = [self isEditable];
    }
    return bVar2;
}

- (void)reflectObjectsDidRelayout
{
    [self setNeedsDisplayOpenGLSurface:YES];
}

- (NSRect)auxiliaryObjectsBoundingRect
{
    NSRect result;

    result = [[self rootCanvasLayer] boundingRectOccupiedByLayer];
    return result;
}

- (id)runTimeEditorController
{
    id pvVar1_2;
    id pvVar1_5;

    if (_runTimeEditorController == nil) {
        pvVar1_2 = [[HSRunTimeEditorController alloc] init];
        _runTimeEditorController = pvVar1_2;
        [pvVar1_2 setParentToolView:self];
        [_runTimeEditorController setAllowsInPlaceEditors:[[[HSToolManager sharedToolManager] currentTool] allowsActiveInPlaceEditors]];
    }
    if (![self isEditable]) {
        pvVar1_5 = nil;
    }
    else {
        pvVar1_5 = _runTimeEditorController;
    }
    return pvVar1_5;
}

- (BOOL)acceptsFirstMouse:(id)aMouse
{
    return (BOOL)[[[HSToolManager sharedToolManager] currentTool] acceptsFirstMouse];
}

- (void)dealloc
{
    [_runTimeEditorController setParentToolView:nil];
    [_runTimeEditorController release];
    [_selection setOwner:nil];
    [_selection release];
    [super dealloc];
}

@end

