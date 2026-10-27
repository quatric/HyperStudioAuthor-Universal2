#import "HSAuxiliaryIconsCanvasLayer.h"

@implementation HSAuxiliaryIconsCanvasLayer

- (void)animationDidChange:(id)aChange
{
    id pvVar1_3;

    pvVar1_3 = [self canvasItemForNodeIfExists:[[aChange object] queryHyperInterface:@protocol(HSNodeAttributes)]];
    if (pvVar1_3 != nil) {
        [self updateCanvasItemIfNeeded:pvVar1_3];
    }
}

- (void)HSAuxiliaryIconsCanvasLayer_actorDidChange:(id)aChange
{
    id pvVar1_3;

    pvVar1_3 = [self canvasItemForNodeIfExists:[[aChange object] queryHyperInterface:@protocol(HSNodeAttributes)]];
    if (pvVar1_3 != nil) {
        [self updateCanvasItemIfNeeded:pvVar1_3];
    }
}

- (void)hiddedAttributeDidChange:(id)aChange
{
    id pvVar1_2;

    pvVar1_2 = [self canvasItemForNodeIfExists:[aChange object]];
    if (pvVar1_2 != nil) {
        [self updateCanvasItemIfNeeded:pvVar1_2];
    }
}

- (void)masterAttributeDidChange:(id)aChange
{
    id pvVar1_2;

    pvVar1_2 = [self canvasItemForNodeIfExists:[aChange object]];
    if (pvVar1_2 != nil) {
        [self updateCanvasItemIfNeeded:pvVar1_2];
    }
}

- (void)rootNodeAuxiliaryIconAffectingAttributeDidChange:(id)aChange
{
    [self updateRootRepresentedNodeCanvasItem];
}

- (void)cardSizeDidChange:(id)aChange
{
    [self updateRootRepresentedNodeCanvasItem];
}

- (void)updateRootRepresentedNodeCanvasItem
{
    id pvVar1_2;

    pvVar1_2 = [self canvasItemForNodeIfExists:[self rootRepresentedNode]];
    if (pvVar1_2 != nil) {
        [self updateCanvasItemIfNeeded:pvVar1_2];
    }
}

- (void)itemDidChangeGeometry:(id)aGeometry
{
    id pvVar1_2;

    pvVar1_2 = [self canvasItemForNodeIfExists:[aGeometry object]];
    if (pvVar1_2 != nil) {
        [self updateCanvasItemIfNeeded:pvVar1_2];
    }
}

- (void)handleTraitsMightChangeForAllItems
{
    [self updateRegisteredCanvasItemsIfNeeded];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00095336 @ 00095336, 670 bytes * /

void FUN_00095336(HSAuxiliaryIconsCanvasLayer *self,SEL _cmd,
                 id stopObservingNotificationsFromRootRepresentedObject)

{
  undefined4 uVar1;
  id pvVar2;
  id self_00;
  undefined *local_28;
  undefined *local_24;
  undefined4 local_20;
  HSAuxiliaryIconsCanvasLayer *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSObservingNodesCanvasSublayer_0034ed70;
  _objc_msgSendSuper(&local_1c,sel_stopObservingNotificationsFromRootRepresentedObject_,
                     stopObservingNotificationsFromRootRepresentedObject);
  pvVar2 = _objc_msgSend(stopObservingNotificationsFromRootRepresentedObject,
                         sel_queryHyperInterface_,&DAT_003670f0);
  self_00 = _objc_msgSend(pvVar2,sel_attributeObservingController);
  uVar1 = *(undefined4 *)PTR_0033601c;
  _objc_msgSend(pvVar2,sel_removeObserver_selector_ofChanges_ofChildrenAttribute_,self,
                sel_itemDidChangeGeometry_,uVar1,&DAT_00367118);
  _objc_msgSend(pvVar2,sel_removeObserver_selector_ofChanges_ofChildrenAttribute_,self,
                sel_masterAttributeDidChange_,uVar1,&DAT_0036712c);
  local_28 = &DAT_00367140;
  local_24 = &DAT_00367154;
  local_20 = 0;
  _objc_msgSend(pvVar2,sel_removeObserver_selector_ofChanges_ofChildrenAttributes_,self,
                sel_HSAuxiliaryIconsCanvasLayer_actorDidChange_,uVar1,&local_28);
  _objc_msgSend(pvVar2,sel_removeObserver_selector_ofChanges_ofChildrenAttribute_,self,
                sel_hiddedAttributeDidChange_,uVar1,&DAT_00367168);
  _objc_msgSend(self_00,sel_removeObserver_selector_ofChanges_ofAttribute_,self,
                sel_rootNodeAuxiliaryIconAffectingAttributeDidChange_,uVar1,&DAT_0036717c);
  _objc_msgSend(self_00,sel_removeObserver_selector_ofChanges_ofAttribute_,self,
                sel_rootNodeAuxiliaryIconAffectingAttributeDidChange_,uVar1,&DAT_00367140);
  pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_00366fd8);
  pvVar2 = _objc_msgSend(pvVar2,sel_hyperParent);
  pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_0036703c);
  _objc_msgSend(self,sel_stopObservingNotificationsFromStack_,pvVar2);
  _objc_msgSend(self_00,sel_removeObserver_selector_ofChanges_ofAttribute_,self,
                sel_rootNodeParentWillChange_,*(undefined4 *)PTR_00336020,&DAT_00366fec);
  _objc_msgSend(self_00,sel_removeObserver_selector_ofChanges_ofAttribute_,self,
                sel_rootNodeParentDidChange_,uVar1,&DAT_00366fec);
  return;
}

*/
- (void)stopObservingNotificationsFromRootRepresentedObject:(id)aObject
{
    [super stopObservingNotificationsFromRootRepresentedObject:aObject];
    id container = [aObject queryHyperInterface:@protocol(HSNodeContainer)];
    id controller = [container attributeObservingController];
    id attributes[3] = { @protocol(HSActionsAttribute), @protocol(HSAutomaticTimerActionsEnabledAttribute), nil };
    [container removeObserver:self selector:@selector(itemDidChangeGeometry:) ofChanges:HSActualDidAttributeChanges ofChildrenAttribute:@protocol(HSGeometryAttribute)];
    [container removeObserver:self selector:@selector(masterAttributeDidChange:) ofChanges:HSActualDidAttributeChanges ofChildrenAttribute:@protocol(HSCardObjectGroupAttribute)];
    [container removeObserver:self selector:@selector(HSAuxiliaryIconsCanvasLayer_actorDidChange:) ofChanges:HSActualDidAttributeChanges ofChildrenAttributes:attributes];
    [container removeObserver:self selector:@selector(hiddedAttributeDidChange:) ofChanges:HSActualDidAttributeChanges ofChildrenAttribute:@protocol(HSCardObjectHiddenAttribute)];
    [controller removeObserver:self selector:@selector(rootNodeAuxiliaryIconAffectingAttributeDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSCardGroupAttribute)];
    [controller removeObserver:self selector:@selector(rootNodeAuxiliaryIconAffectingAttributeDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSActionsAttribute)];
    id stack = [[[container queryHyperInterface:@protocol(HSNodeChild)] hyperParent] queryHyperInterface:@protocol(HSStackAttributes)];
    [self stopObservingNotificationsFromStack:stack];
    [controller removeObserver:self selector:@selector(rootNodeParentWillChange:) ofChanges:HSActualWillAttributeChanges ofAttribute:@protocol(HSNodeParentAttribute)];
    [controller removeObserver:self selector:@selector(rootNodeParentDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSNodeParentAttribute)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000955d4 @ 000955d4, 734 bytes * /

void FUN_000955d4(HSAuxiliaryIconsCanvasLayer *self,SEL _cmd,
                 id observeNotificationsFromRootRepresentedObject)

{
  id pvVar1;
  id self_00;
  undefined4 uVar2;
  undefined4 uVar3;
  undefined *local_28;
  undefined *local_24;
  undefined4 local_20;
  HSAuxiliaryIconsCanvasLayer *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSObservingNodesCanvasSublayer_0034ed70;
  _objc_msgSendSuper(&local_1c,sel_observeNotificationsFromRootRepresentedObject_,
                     observeNotificationsFromRootRepresentedObject);
  pvVar1 = _objc_msgSend(observeNotificationsFromRootRepresentedObject,sel_queryHyperInterface_,
                         &DAT_003670f0);
  self_00 = _objc_msgSend(pvVar1,sel_attributeObservingController);
  uVar2 = *(undefined4 *)PTR_0033601c;
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofChildrenAttribute_withPriority_,self,
                sel_itemDidChangeGeometry_,uVar2,&DAT_00367118,0xbe800000,self_00,uVar2);
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofChildrenAttribute_withPriority_,self,
                sel_masterAttributeDidChange_,uVar2,&DAT_0036712c,0xbe800000);
  local_28 = &DAT_00367140;
  local_24 = &DAT_00367154;
  local_20 = 0;
  uVar3 = uVar2;
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofChildrenAttributes_withPriority_,self,
                sel_HSAuxiliaryIconsCanvasLayer_actorDidChange_,uVar2,&local_28,0xbe800000);
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofChildrenAttribute_withPriority_,self,
                sel_hiddedAttributeDidChange_,uVar2,&DAT_00367168,0xbe800000);
  _objc_msgSend(self_00,sel_addObserver_selector_ofChanges_ofAttribute_withPriority_,self,
                sel_rootNodeAuxiliaryIconAffectingAttributeDidChange_,uVar3,&DAT_0036717c,0xbe800000
               );
  _objc_msgSend(self_00,sel_addObserver_selector_ofChanges_ofAttribute_withPriority_,self,
                sel_rootNodeAuxiliaryIconAffectingAttributeDidChange_,uVar3,&DAT_00367140,0xbe800000
               );
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00366fd8);
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperParent);
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0036703c);
  _objc_msgSend(self,sel_observeNotificationsFromStack_,pvVar1);
  _objc_msgSend(self_00,sel_addObserver_selector_ofChanges_ofAttribute_withPriority_,self,
                sel_rootNodeParentWillChange_,*(undefined4 *)PTR_00336020,&DAT_00366fec,0xbe800000);
  _objc_msgSend(self_00,sel_addObserver_selector_ofChanges_ofAttribute_withPriority_,self,
                sel_rootNodeParentDidChange_,uVar3,&DAT_00366fec,0xbe800000);
  return;
}

*/
- (void)observeNotificationsFromRootRepresentedObject:(id)aObject
{
    [super observeNotificationsFromRootRepresentedObject:aObject];
    id container = [aObject queryHyperInterface:@protocol(HSNodeContainer)];
    id controller = [container attributeObservingController];
    id attributes[3] = { @protocol(HSActionsAttribute), @protocol(HSAutomaticTimerActionsEnabledAttribute), nil };
    [container addObserver:self selector:@selector(itemDidChangeGeometry:) ofChanges:HSActualDidAttributeChanges ofChildrenAttribute:@protocol(HSGeometryAttribute) withPriority:-0.25];
    [container addObserver:self selector:@selector(masterAttributeDidChange:) ofChanges:HSActualDidAttributeChanges ofChildrenAttribute:@protocol(HSCardObjectGroupAttribute) withPriority:-0.25];
    [container addObserver:self selector:@selector(HSAuxiliaryIconsCanvasLayer_actorDidChange:) ofChanges:HSActualDidAttributeChanges ofChildrenAttributes:attributes withPriority:-0.25];
    [container addObserver:self selector:@selector(hiddedAttributeDidChange:) ofChanges:HSActualDidAttributeChanges ofChildrenAttribute:@protocol(HSCardObjectHiddenAttribute) withPriority:-0.25];
    [controller addObserver:self selector:@selector(rootNodeAuxiliaryIconAffectingAttributeDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSCardGroupAttribute) withPriority:-0.25];
    [controller addObserver:self selector:@selector(rootNodeAuxiliaryIconAffectingAttributeDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSActionsAttribute) withPriority:-0.25];
    id stack = [[[container queryHyperInterface:@protocol(HSNodeChild)] hyperParent] queryHyperInterface:@protocol(HSStackAttributes)];
    [self observeNotificationsFromStack:stack];
    [controller addObserver:self selector:@selector(rootNodeParentWillChange:) ofChanges:HSActualWillAttributeChanges ofAttribute:@protocol(HSNodeParentAttribute) withPriority:-0.25];
    [controller addObserver:self selector:@selector(rootNodeParentDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSNodeParentAttribute) withPriority:-0.25];
}

- (void)rootNodeParentDidChange:(id)aChange
{
    [self observeNotificationsFromStack:[[[[self rootRepresentedNode] queryHyperInterface:@protocol(HSNodeChild)] hyperParent] queryHyperInterface:@protocol(HSStackAttributes)]];
    [self updateRootRepresentedNodeCanvasItem];
}

- (void)representedObjectDidChange
{
    NSUInteger pvVar1;
    id pvVar2;
    NSUInteger pvVar4;
    id pvVar2_2;

    [super representedObjectDidChange];
    pvVar1 = [self countOfRepresentedObjects];
    if (pvVar1 != 0) {
        pvVar4 = 0;
        do {
            pvVar2 = [self objectInRepresentedObjectsAtIndex:pvVar4];
            if ([pvVar2 sharedNodeDataUID] != nil) {
                pvVar2_2 = [self canvasItemForNodeIfExists:pvVar2];
                if (pvVar2_2 != nil) {
                    [self updateCanvasItemIfNeeded:pvVar2_2];
                }
            }
            pvVar4 = (pvVar4 + 1);
        } while (pvVar4 < pvVar1);
    }
}

- (void)rootNodeParentWillChange:(id)aChange
{
    [self stopObservingNotificationsFromStack:[[[[self rootRepresentedNode] queryHyperInterface:@protocol(HSNodeChild)] hyperParent] queryHyperInterface:@protocol(HSStackAttributes)]];
}

- (void)stopObservingNotificationsFromStack:(id)aStack
{
    if (aStack != nil) {
        [[aStack attributeObservingController] removeObserver:self selector:@selector(cardSizeDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSStackCardSizeAttribute)];
    }
}

- (void)observeNotificationsFromStack:(id)aStack
{
    if (aStack != nil) {
        [[aStack attributeObservingController] addObserver:self selector:@selector(cardSizeDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSStackCardSizeAttribute) withPriority:-0.25];
    }
}

- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo
{
    id pvVar1;
    id pvVar2;
    id pvVar3;
    id pvVar1_3;

    if (aInfo != nil) {
        pvVar1 = [self context];
        pvVar1_3 = [[pvVar1 queryHyperInterface:@protocol(HSEditorCanvasLayerContext)] editorSelection];
        if (pvVar1_3 != nil) {
            pvVar2 = [aInfo queryHyperInterface:@protocol(HSNodeAttributes)];
            if (((pvVar1 != nil) && (pvVar2 != nil)) && (pvVar3 = [self rootRepresentedNode], pvVar2 != pvVar3)) {
                [pvVar1_3 selectNode:pvVar2];
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)hasRepresentationForRootNode
{
    return YES;
}

- (id)queryCanvasItemForNode:(id)aNode
{
    id pvVar1_3;

    if ([self rootRepresentedNode] == aNode) {
        pvVar1_3 = [[HSAuxiliaryIconsCardCanvasItem alloc] initWithNode:aNode];
    }
    else {
        pvVar1_3 = [[HSAuxiliaryIconsCardObjectCanvasItem alloc] initWithNode:aNode];
    }
    return [pvVar1_3 autorelease];
}

- (BOOL)supportsHitTesting
{
    return YES;
}

- (void)dealloc
{
    [super dealloc];
}

@end

