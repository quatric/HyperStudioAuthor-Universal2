#import "HSNodeSelection.h"

@implementation HSNodeSelection

/* i386 ivar offsets: _owner=0x4, _nodes=0x8, _selectedObject=0xc, _anySelectedObject=0x10, _selectionChangeNotificationDelayCount=0x14, _ownerValidatesNodes=0x18, _selectionChangeNotificationsPending=0x19, _hadAnyChangesOtherThanRemovingObjectsSinceLastNotification=0x1a, _shouldDisplaySelectionKnobs=0x1b */

- (void)setShouldDisplaySelectionKnobs:(BOOL)aKnobs
{
    if ((BOOL)_shouldDisplaySelectionKnobs != (aKnobs != NO)) {
        _shouldDisplaySelectionKnobs = aKnobs != NO;
        [self notifySelectionDidChange];
    }
}

- (BOOL)shouldDisplaySelectionKnobs
{
    return _shouldDisplaySelectionKnobs;
}

- (void)selectionDidChange
{
    [self setSelectedObject:nil];
    [self setAnySelectedObject:nil];
    if (_selectionChangeNotificationDelayCount == 0) {
        [self notifySelectionDidChange];
    }
    else {
        _selectionChangeNotificationsPending = YES;
    }
}

- (void)setAnySelectedObject:(id)aObject
{
    if (_anySelectedObject != aObject) {
        [_anySelectedObject release];
        _anySelectedObject = [aObject retain];
    }
}

- (void)setSelectedObject:(id)aObject
{
    if (_selectedObject != aObject) {
        [_selectedObject release];
        _selectedObject = [aObject retain];
    }
}

- (void)ensureSelectionContainsOnlyAllowedNodes
{
    id self_00;
    id pvVar1;

    if (_ownerValidatesNodes != NO) {
        self_00 = [self nodesEnumerator];
        pvVar1 = [self_00 nextObject];
        while (pvVar1 != nil) {
            if (![self shouldIncludeNode:pvVar1]) {
                [self removeNode:pvVar1];
            }
            pvVar1 = [self_00 nextObject];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0009f56f @ 0009f56f, 240 bytes * /

id FUN_0009f56f(HSNodeSelection *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  cfstringStruct *pcVar2;
  SEL op;
  cfstringStruct *pcVar3;
  
  pvVar1 = _objc_msgSend(self,sel_nodesCount);
  if (pvVar1 < (id)0x2) {
    pvVar1 = _objc_msgSend(self,sel_nodesCount);
    if (pvVar1 != (id)0x1) {
      return (id)0x0;
    }
    pvVar1 = _objc_msgSend(cls_HSUserObjectDefaultAttributesProvider,sel_sharedInstance);
    self_00 = _objc_msgSend(self->_nodes,sel_anyObject);
    pcVar2 = _objc_msgSend(self_00,sel_class);
    pcVar3 = (cfstringStruct *)0x0;
    op = sel_localizedKindNameForUserObjectClass_key_;
  }
  else {
    pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pcVar3 = &cfstr_empty;
    pcVar2 = &cfstr_HSSelectedObjects;
    op = sel_localizedStringForKey_value_table_;
  }
  pvVar1 = _objc_msgSend(pvVar1,op,pcVar2,pcVar3);
  return pvVar1;
}

*/
- (id)localizedSelectionName
{
    if ([self nodesCount] >= 2) {
        return [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSSelectedObjects" value:@"" table:@"Editor"];
    }
    if ([self nodesCount] != 1) {
        return nil;
    }
    return [[HSUserObjectDefaultAttributesProvider sharedInstance] localizedKindNameForUserObjectClass:[[_nodes anyObject] class] key:nil];
    return 0;
}

- (void)endSelectionChanging
{
    unsigned int uVar1;

    uVar1 = _selectionChangeNotificationDelayCount - 1;
    _selectionChangeNotificationDelayCount = uVar1;
    if ((uVar1 == 0) && (_selectionChangeNotificationsPending != NO)) {
        _selectionChangeNotificationsPending = NO;
        [self notifySelectionDidChange];
    }
}

- (void)beginSelectionChanging
{
    _selectionChangeNotificationDelayCount = _selectionChangeNotificationDelayCount + 1;
}

- (void)selectNodesInEnumerator:(id)aEnumerator
{
    [self beginSelectionChanging];
    [self removeAllNodes];
    [self addNodesInEnumerator:aEnumerator];
    [self endSelectionChanging];
}

- (void)selectNode:(id)aNode
{
    [self beginSelectionChanging];
    [self removeAllNodes];
    [self addNode:aNode];
    [self endSelectionChanging];
}

- (void)removeAllNodes
{
    [self removeObserverForNodes:[self nodes]];
    [_nodes removeAllObjects];
    [self selectionDidChange];
}

- (void)removeAllNodesExcept:(id)aExcept
{
    id self_00;
    id pvVar1;

    [self beginSelectionChanging];
    self_00 = [self nodesEnumerator];
    pvVar1 = [self_00 nextObject];
    while (pvVar1 != nil) {
        if (pvVar1 != aExcept) {
            [self removeNode:pvVar1];
        }
        pvVar1 = [self_00 nextObject];
    }
    [self endSelectionChanging];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0009f870 @ 0009f870, 93 bytes * /

void FUN_0009f870(HSNodeSelection *self,SEL _cmd,id toggleNode)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_containsNode_,toggleNode);
  op = sel_addNode_;
  if ((char)pvVar1 != '\0') {
    op = sel_removeNode_;
  }
  _objc_msgSend(self,op,toggleNode);
  return;
}

*/
- (void)toggleNode:(id)aNode
{
    if ([self containsNode:aNode]) {
        [self removeNode:aNode];
    } else {
        [self addNode:aNode];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0009f8cd @ 0009f8cd, 429 bytes * /

void FUN_0009f8cd(HSNodeSelection *self,SEL _cmd,id removeNodesIfExist)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  SEL op;
  
  pvVar1 = _objc_msgSend(removeNodesIfExist,sel_count);
  if (pvVar1 == (id)0x1) {
    removeNodesIfExist = _objc_msgSend(removeNodesIfExist,sel_anyObject);
    pvVar1 = _objc_msgSend(self,sel_containsNode_,removeNodesIfExist);
    op = sel_removeNode_;
    if ((char)pvVar1 == '\0') {
      return;
    }
  }
  else {
    pvVar1 = _objc_msgSend(removeNodesIfExist,sel_count);
    if (pvVar1 < (id)0x2) {
      return;
    }
    pvVar1 = _objc_msgSend(self->_nodes,sel_count);
    if (pvVar1 == (id)0x0) {
      return;
    }
    pvVar1 = self->_nodes;
    pvVar2 = _objc_msgSend(removeNodesIfExist,sel_isSubsetOfSet_,pvVar1);
    if ((char)pvVar2 == '\0') {
      _objc_msgSend(self,sel_beginSelectionChanging,pvVar1);
      self_00 = _objc_msgSend(removeNodesIfExist,sel_objectEnumerator);
      pvVar2 = _objc_msgSend(self_00,sel_nextObject);
      removeNodesIfExist = pvVar1;
      op = sel_endSelectionChanging;
      while (sel_endSelectionChanging = op, pvVar2 != (id)0x0) {
        removeNodesIfExist = pvVar2;
        pvVar1 = _objc_msgSend(self,sel_containsNode_,pvVar2);
        if ((char)pvVar1 != '\0') {
          _objc_msgSend(self,sel_removeNode_,pvVar2);
          removeNodesIfExist = pvVar2;
        }
        pvVar2 = _objc_msgSend(self_00,sel_nextObject,removeNodesIfExist);
        op = sel_endSelectionChanging;
      }
    }
    else {
      _objc_msgSend(self,sel_removeObserverForNodes_,removeNodesIfExist);
      self = self->_nodes;
      op = sel_minusSet_;
    }
  }
  _objc_msgSend(self,op,removeNodesIfExist);
  return;
}

*/
- (void)removeNodesIfExist:(id)aExist
{
    if ([aExist count] == 1) {
        id node = [aExist anyObject];
        if ([self containsNode:node]) {
            [self removeNode:node];
        }
        return;
    }
    if ([aExist count] < 2 || [_nodes count] == 0) {
        return;
    }
    if ([aExist isSubsetOfSet:_nodes]) {
        [self removeObserverForNodes:aExist];
        [_nodes minusSet:aExist];
    } else {
        [self beginSelectionChanging];
        NSEnumerator *enumerator = [aExist objectEnumerator];
        id node;
        while ((node = [enumerator nextObject]) != nil) {
            if ([self containsNode:node]) {
                [self removeNode:node];
            }
        }
        [self endSelectionChanging];
    }
}

- (void)removeNode:(id)aNode
{
    [self removeObserverForNode:[aNode queryHyperInterface:@protocol(HSAttributeObserving)]];
    [_nodes removeObject:aNode];
    [self selectionDidChange];
}

- (void)addNodesInEnumerator:(id)aEnumerator
{
    id pvVar1;

    [self beginSelectionChanging];
    while( YES ) {
        pvVar1 = [aEnumerator nextObject];
        if (pvVar1 == nil) break;
        [self addNode:pvVar1];
    }
    [self endSelectionChanging];
}

- (void)objectParentDidChange:(id)aChange
{
    id self_00;

    self_00 = [aChange object];
    if ([_nodes containsObject:self_00]) {
        if ([[self_00 queryHyperInterface:@protocol(HSNodeParentAttribute)] hyperParent] == nil) {
            [self removeNode:self_00];
        }
    }
}

- (void)removeObserverForNodes:(id)aNodes
{
    NSEnumerator *self_00;
    id pvVar1;

    self_00 = [aNodes objectEnumerator];
    pvVar1 = [self_00 nextObject];
    while (pvVar1 != nil) {
        [self removeObserverForNode:[pvVar1 queryHyperInterface:@protocol(HSAttributeObserving)]];
        pvVar1 = [self_00 nextObject];
    }
}

- (void)removeObserverForNode:(id)aNode
{
    [aNode removeObserver:self selector:@selector(objectParentDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSNodeParentAttribute)];
}

- (void)addNode:(id)aNode
{
    if ([self shouldIncludeNode:aNode]) {
        if (![_nodes containsObject:aNode]) {
            [[aNode queryHyperInterface:@protocol(HSAttributeObserving)] addObserver:self selector:@selector(objectParentDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSNodeParentAttribute) withPriority:-0.25]
            ;
            [_nodes addObject:aNode];
            _hadAnyChangesOtherThanRemovingObjectsSinceLastNotification = YES;
            [self selectionDidChange];
        }
    }
}

- (BOOL)containsNode:(id)aNode
{
    return (BOOL)[_nodes containsObject:aNode];
}

- (id)anySelectedNode
{
    return [[self anySelectedObject] queryHyperInterface:@protocol(HSNodeAttributes)];
}

- (id)selectedNode
{
    return [[self selectedObject] queryHyperInterface:@protocol(HSNodeAttributes)];
}

- (id)nodesEnumerator
{
    return [[_nodes allObjects] objectEnumerator];
}

- (id)nodes
{
    return [NSSet setWithSet:_nodes];
}

- (id)nodesArray
{
    return [_nodes allObjects];
}

- (NSUInteger)nodesCount
{
    return (unsigned int)[_nodes count];
}

- (BOOL)containsObject:(id)aObject
{
    BOOL BVar1;
    id pvVar2;

    pvVar2 = [aObject queryHyperInterface:@protocol(HSNodeAttributes)];
    if (pvVar2 == nil) {
        BVar1 = NO;
    }
    else {
        BVar1 = (BOOL)[self containsNode:pvVar2];
    }
    return BVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0009ffa8 @ 0009ffa8, 127 bytes * /

id FUN_0009ffa8(HSNodeSelection *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  
  pvVar1 = self->_anySelectedObject;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_nodesArray);
    pvVar2 = _objc_msgSend(pvVar1,sel_count);
    op = sel_lastObject;
    if ((id)0x1 < pvVar2) {
      op = sel_hyperObjectForAnyInterfaces;
    }
    pvVar1 = _objc_msgSend(pvVar1,op);
    _objc_msgSend(self,sel_setAnySelectedObject_,pvVar1);
    pvVar1 = self->_anySelectedObject;
  }
  return pvVar1;
}

*/
- (id)anySelectedObject
{
    if (_anySelectedObject == nil) {
        NSArray *nodes = [self nodesArray];
        id object = ([nodes count] > 1) ? [nodes hyperObjectForAnyInterfaces] : [nodes lastObject];
        [self setAnySelectedObject:object];
    }
    return _anySelectedObject;
    return 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a0027 @ 000a0027, 123 bytes * /

id FUN_000a0027(HSNodeSelection *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  
  pvVar1 = self->_selectedObject;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_nodesArray);
    pvVar2 = _objc_msgSend(pvVar1,sel_count);
    op = sel_lastObject;
    if ((id)0x1 < pvVar2) {
      op = sel_hyperObjectForAllInterfaces;
    }
    pvVar1 = _objc_msgSend(pvVar1,op);
    pvVar1 = _objc_msgSend(pvVar1,sel_retain);
    self->_selectedObject = pvVar1;
  }
  return pvVar1;
}

*/
- (id)selectedObject
{
    if (_selectedObject == nil) {
        NSArray *nodes = [self nodesArray];
        id object = ([nodes count] > 1) ? [nodes hyperObjectForAllInterfaces] : [nodes lastObject];
        _selectedObject = [object retain];
    }
    return _selectedObject;
    return 0;
}

- (id)objectEnumerator
{
    return [self nodesEnumerator];
}

- (id)objectsArray
{
    return [self nodesArray];
}

- (NSUInteger)objectsCount
{
    return (unsigned int)[self nodesCount];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a0114 @ 000a0114, 70 bytes * /

BOOL FUN_000a0114(HSNodeSelection *self,SEL _cmd,id shouldIncludeNode)

{
  BOOL BVar1;
  id pvVar2;
  
  if (self->_ownerValidatesNodes == '\0') {
    BVar1 = '\x01';
  }
  else {
    pvVar2 = _objc_msgSend(self->_owner,sel_selection_shouldIncludeNode_,self,shouldIncludeNode);
    BVar1 = (BOOL)pvVar2;
  }
  return BVar1;
}

*/
- (BOOL)shouldIncludeNode:(id)aNode
{
    if (!_ownerValidatesNodes) {
        return YES;
    }
    return ((BOOL (*)(id, SEL, id, id))objc_msgSend)(_owner, @selector(selection:shouldIncludeNode:), self, aNode);
    return 0;
}

- (void)notifySelectionDidChangeOwnerAndNotificationCenterWasExpanded:(BOOL)aExpanded
{
    [_owner selectionDidChange:self wasExpanded:aExpanded];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSNodeSelectionDidChangeNotification" object:self];
}

- (void)notifySelectionDidChange
{
    char cVar1;

    cVar1 = _hadAnyChangesOtherThanRemovingObjectsSinceLastNotification;
    _hadAnyChangesOtherThanRemovingObjectsSinceLastNotification = NO;
    [self notifySelectionDidChangeOwnerAndNotificationCenterWasExpanded:cVar1];
}

- (void)setOwner:(id)aOwner
{
    if (_owner != aOwner) {
        _owner = aOwner;
        _ownerValidatesNodes = (BOOL)[aOwner respondsToSelector:@selector(selection:shouldIncludeNode:)];
    }
}

- (id)owner
{
    return _owner;
}

- (void)dealloc
{
    [_nodes release];
    [_selectedObject release];
    [_anySelectedObject release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _nodes = [[NSMutableSet alloc] init];
        _shouldDisplaySelectionKnobs = 1;
    }
    return self;
}

- (void)toggleNodesInEnumerator:(id)aEnumerator
{
    [self beginSelectionChanging];
    id node;
    while ((node = [aEnumerator nextObject]) != nil)
        [self toggleNode:node];
    [self endSelectionChanging];
}

@end

