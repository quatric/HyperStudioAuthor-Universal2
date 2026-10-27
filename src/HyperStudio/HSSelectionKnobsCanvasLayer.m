#import "HSSelectionKnobsCanvasLayer.h"

static NSInteger HSSelectionKnobSublayerCompare(id a, id b, void *context)
{
    NSUInteger indexA = [[a node] hyperIndex];
    NSUInteger indexB = [[b node] hyperIndex];
    if (indexA < indexB) {
        return NSOrderedAscending;
    }
    return (indexB < indexA) ? NSOrderedDescending : NSOrderedSame;
}

@implementation HSSelectionKnobsCanvasLayer

/* i386 ivar offsets: _sublayers=0x10, _sublayersOrderIsValid=0x14, _sublayersByNodes=0x18, _selection=0x1c */

/* --- i386 decompilation (Ghidra) ---
/* FUN_0009d509 @ 0009d509, 164 bytes * /

void FUN_0009d509(HSSelectionKnobsCanvasLayer *self,SEL _cmd)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_selection);
  pvVar1 = _objc_msgSend(pvVar1,sel_nodesCount);
  op = sel_removeAllKnobLayers;
  if (pvVar1 != (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_selection);
    pvVar1 = _objc_msgSend(pvVar1,sel_shouldDisplaySelectionKnobs);
    op = sel_removeAllKnobLayers;
    if (((char)pvVar1 != '\0') &&
       (pvVar1 = _objc_msgSend(self,sel_numberOfSublayers), op = sel_rebuildKnobLayers,
       pvVar1 == (id)0x0)) {
      op = sel_buildKnobLayers;
    }
  }
  _objc_msgSend(self,op);
  return;
}

*/
- (void)updateKnobLayers
{
    if ([[self selection] nodesCount] != 0) {
        if ([[self selection] shouldDisplaySelectionKnobs]) {
            if ([self numberOfSublayers] == 0) {
                [self buildKnobLayers];
            } else {
                [self rebuildKnobLayers];
            }
            return;
        }
    }
    [self removeAllKnobLayers];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0009d68b @ 0009d68b, 753 bytes * /

void FUN_0009d68b(HSSelectionKnobsCanvasLayer *self,SEL _cmd)

{
  char cVar1;
  id pvVar2;
  undefined4 uVar3;
  int iVar4;
  id pvVar5;
  int iVar6;
  int *piVar7;
  int *piVar8;
  int aiStack_6c [2];
  undefined1 local_3c [28];
  undefined4 local_20;
  
  pvVar2 = _objc_msgSend(self,sel_rootLayer);
  _objc_msgSend(pvVar2,sel_beginSublayerTreeChanging);
  uVar3 = _NSCreateHashTable();
  _objc_msgSend(self,sel_sublayersByNodes);
  _NSEnumerateMapTable();
  piVar7 = (int *)&stack0xffffffa0;
  local_20 = 0;
  while (cVar1 = _NSNextMapEnumeratorPair(), cVar1 != '\0') {
    _NSHashInsertKnownAbsent();
  }
  _NSEndMapTableEnumeration();
  iVar4 = _NSCreateHashTable();
  pvVar2 = _objc_msgSend(self,sel_selection);
  pvVar2 = _objc_msgSend(pvVar2,sel_nodesCount);
  piVar8 = (int *)&stack0xffffffa0;
  if (pvVar2 != (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_selection);
    pvVar2 = _objc_msgSend(pvVar2,sel_nodesEnumerator);
    pvVar5 = _objc_msgSend(pvVar2,sel_nextObject);
    while (pvVar5 != (id)0x0) {
      iVar6 = _NSHashGet();
      if (iVar6 == 0) {
        _NSHashInsertKnownAbsent();
      }
      else {
        _NSHashRemove();
      }
      pvVar5 = _objc_msgSend(pvVar2,sel_nextObject);
    }
    iVar6 = _NSCountHashTable();
    if (iVar6 != 0) {
      _NSEnumerateHashTable();
      piVar7 = (int *)&stack0xffffff9c;
      iVar6 = _NSNextHashEnumeratorItem();
      while (iVar6 != 0) {
        _objc_msgSend(self,sel_sublayersByNodes);
        _NSMapGet();
        _objc_msgSend(self,sel_removeSublayer_);
        iVar6 = _NSNextHashEnumeratorItem();
      }
      _NSEndHashTableEnumeration();
    }
    *piVar7 = iVar4;
    piVar7[-1] = 0x9d8d2;
    iVar6 = _NSCountHashTable();
    piVar8 = piVar7;
    if (iVar6 != 0) {
      piVar7[1] = iVar4;
      *piVar7 = (int)local_3c;
      piVar7[-1] = 0x9d8e8;
      _NSEnumerateHashTable();
      piVar8 = piVar7 + -1;
      while( true ) {
        piVar7[-1] = (int)local_3c;
        piVar7[-2] = 0x9d92b;
        iVar6 = _NSNextHashEnumeratorItem();
        if (iVar6 == 0) break;
        piVar7[1] = iVar6;
        *piVar7 = (int)sel_queryCanvasSublayerForNode_;
        piVar7[-1] = (int)self;
        piVar7[-2] = 0x9d906;
        pvVar2 = _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
        if (pvVar2 != (id)0x0) {
          piVar7[1] = (int)pvVar2;
          *piVar7 = (int)sel_addSublayer_;
          piVar7[-1] = (int)self;
          piVar7[-2] = 0x9d923;
          _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
        }
      }
      piVar7[-1] = (int)local_3c;
      piVar7[-2] = 0x9d937;
      _NSEndHashTableEnumeration();
    }
  }
  *piVar8 = uVar3;
  piVar8[-1] = 0x9d942;
  _NSFreeHashTable();
  *piVar8 = iVar4;
  piVar8[-1] = 0x9d94d;
  _NSFreeHashTable();
  piVar8[1] = (int)sel_rootLayer;
  *piVar8 = (int)self;
  piVar8[-1] = 0x9d962;
  pvVar2 = _objc_msgSend((id)*piVar8,(SEL)piVar8[1]);
  piVar8[1] = (int)sel_endSublayerTreeChanging;
  *piVar8 = (int)pvVar2;
  piVar8[-1] = 0x9d974;
  _objc_msgSend((id)*piVar8,(SEL)piVar8[1]);
  return;
}

*/
- (void)rebuildKnobLayers
{
    [[self rootLayer] beginSublayerTreeChanging];
    NSHashTable *staleNodes = NSCreateHashTable(NSNonOwnedPointerHashCallBacks, 0);
    NSMapEnumerator mapEnumerator = NSEnumerateMapTable([self sublayersByNodes]);
    void *key;
    void *value;
    while (NSNextMapEnumeratorPair(&mapEnumerator, &key, &value)) {
        NSHashInsertKnownAbsent(staleNodes, key);
    }
    NSEndMapTableEnumeration(&mapEnumerator);
    NSHashTable *newNodes = NSCreateHashTable(NSNonOwnedPointerHashCallBacks, 0);
    if ([[self selection] nodesCount] != 0) {
        NSEnumerator *nodes = [[self selection] nodesEnumerator];
        id node;
        while ((node = [nodes nextObject]) != nil) {
            if (NSHashGet(staleNodes, node) == NULL) {
                NSHashInsertKnownAbsent(newNodes, node);
            } else {
                NSHashRemove(staleNodes, node);
            }
        }
        if (NSCountHashTable(staleNodes) != 0) {
            NSHashEnumerator hashEnumerator = NSEnumerateHashTable(staleNodes);
            void *item;
            while ((item = NSNextHashEnumeratorItem(&hashEnumerator)) != NULL) {
                [self removeSublayer:(id)NSMapGet([self sublayersByNodes], item)];
            }
            NSEndHashTableEnumeration(&hashEnumerator);
        }
        if (NSCountHashTable(newNodes) != 0) {
            NSHashEnumerator hashEnumerator = NSEnumerateHashTable(newNodes);
            void *item;
            while ((item = NSNextHashEnumeratorItem(&hashEnumerator)) != NULL) {
                id sublayer = [self queryCanvasSublayerForNode:(id)item];
                if (sublayer != nil) {
                    [self addSublayer:sublayer];
                }
            }
            NSEndHashTableEnumeration(&hashEnumerator);
        }
    }
    NSFreeHashTable(staleNodes);
    NSFreeHashTable(newNodes);
    [[self rootLayer] endSublayerTreeChanging];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0009d47c @ 0009d47c, 141 bytes * /

void FUN_0009d47c(HSSelectionKnobsCanvasLayer *self,SEL _cmd)

{
  HSSelectionKnobsCanvasLayer *self_00;
  id pvVar1;
  SEL op;
  
  self_00 = _objc_msgSend(self,sel_rootLayer);
  op = sel_beginSublayerTreeChanging;
  do {
    _objc_msgSend(self_00,op);
    pvVar1 = _objc_msgSend(self,sel_numberOfSublayers);
    self_00 = self;
    op = sel_removeSublayerAtIndex_;
  } while (pvVar1 != (id)0x0);
  pvVar1 = _objc_msgSend(self,sel_rootLayer);
  _objc_msgSend(pvVar1,sel_endSublayerTreeChanging);
  return;
}

*/
- (void)removeAllKnobLayers
{
    [[self rootLayer] beginSublayerTreeChanging];
    while ([self numberOfSublayers] != 0) {
        [self removeSublayerAtIndex:0];
    }
    [[self rootLayer] endSublayerTreeChanging];
}

- (void)buildKnobLayers
{
    id pvVar2;
    id pvVar1_5;
    id pvVar2_2;

    [[self rootLayer] beginSublayerTreeChanging];
    if ([[self selection] nodesCount] != 0) {
        pvVar1_5 = [[self selection] nodesEnumerator];
        while( YES ) {
            pvVar2 = [pvVar1_5 nextObject];
            if (pvVar2 == nil) break;
            pvVar2_2 = [self queryCanvasSublayerForNode:pvVar2];
            if (pvVar2_2 != nil) {
                [self addSublayer:pvVar2_2];
            }
        }
    }
    [[self rootLayer] endSublayerTreeChanging];
}

- (id)queryCanvasSublayerForNode:(id)aNode
{
    id pvVar1;
    id pvVar2_2;

    pvVar1 = [self selection];
    if (![pvVar1 containsNode:aNode]) {
        pvVar2_2 = nil;
    }
    else {
        pvVar2_2 = [[[HSObjectKnobsCanvasLayer alloc] init] autorelease];
        [pvVar2_2 setNode:aNode];
    }
    return pvVar2_2;
}

- (void)objectsInSelectionDidChange:(id)aChange
{
    [self objectsInSelectionDidChange];
}

- (void)objectsInSelectionDidChange
{
    [self updateKnobLayers];
}

- (void)selectionDidChange
{
    [self objectsInSelectionDidChange];
}

- (void)updateWithSelection:(id)aSelection
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

- (void)contextDidChange
{
    [self updateWithSelection:[[[self context] queryHyperInterface:@protocol(HSEditorCanvasLayerContext)] editorSelection]];
    [super contextDidChange];
}

- (void)removeSublayerFromStorage:(id)aStorage atIndex:(NSUInteger)aIndex
{
    id pvVar1_2;

    [self invalidateSublayersOrder];
    [[self unorderedSublayers] removeObject:aStorage];
    pvVar1_2 = [aStorage node];
    NSMapRemove([self sublayersByNodes],pvVar1_2);
}

- (void)insertSublayerInStorage:(id)aStorage atIndex:(NSUInteger)aIndex
{
    id pvVar1_2;

    [self invalidateSublayersOrder];
    [[self unorderedSublayers] addObject:aStorage];
    pvVar1_2 = [aStorage node];
    NSMapInsertKnownAbsent([self sublayersByNodes],pvVar1_2,aStorage);
}

- (NSUInteger)indexOfSublayer:(id)aSublayer
{
    return (unsigned int)[[self orderedSublayers] indexOfObject:aSublayer];
}

- (id)sublayerAtIndex:(NSUInteger)aIndex
{
    return [[self orderedSublayers] objectAtIndex:aIndex];
}

- (NSUInteger)numberOfSublayers
{
    return (unsigned int)[[self unorderedSublayers] count];
}

- (void)invalidateSublayersOrder
{
    _sublayersOrderIsValid = NO;
}

- (id)allSublayers
{
    return [self orderedSublayers];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0009cf9f @ 0009cf9f, 117 bytes * /

id FUN_0009cf9f(HSSelectionKnobsCanvasLayer *self,SEL _cmd)

{
  id self_00;
  id pvVar1;
  
  self_00 = _objc_msgSend(self,sel_unorderedSublayers);
  if (self->_sublayersOrderIsValid == '\0') {
    pvVar1 = _objc_msgSend(self_00,sel_count);
    if ((id)0x1 < pvVar1) {
      _objc_msgSend(self_00,sel_sortUsingFunction_context_,FUN_0009d014,0);
    }
    self->_sublayersOrderIsValid = '\x01';
  }
  return self_00;
}

*/
- (id)orderedSublayers
{
    NSMutableArray *sublayers = [self unorderedSublayers];
    if (!_sublayersOrderIsValid) {
        if ([sublayers count] > 1) {
            [sublayers sortUsingFunction:HSSelectionKnobSublayerCompare context:NULL];
        }
        _sublayersOrderIsValid = YES;
    }
    return sublayers;
    return 0;
}

- (id)unorderedSublayers
{
    id pvVar1;

    pvVar1 = _sublayers;
    if (pvVar1 == nil) {
        pvVar1 = [NSMutableArray new];
        _sublayers = pvVar1;
        _sublayersOrderIsValid = YES;
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0009db27 @ 0009db27, 108 bytes * /

id FUN_0009db27(HSSelectionKnobsCanvasLayer *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = self->_sublayersByNodes;
  if (pvVar1 == (id)0x0) {
    pvVar1 = (id)_NSCreateMapTable(*(undefined8 *)PTR_00336398,*(undefined8 *)(PTR_00336398 + 8),
                                   *(undefined8 *)(PTR_00336398 + 0x10),*(undefined4 *)PTR_0033639c,
                                   *(undefined4 *)(PTR_0033639c + 4),
                                   *(undefined4 *)(PTR_0033639c + 8),0);
    self->_sublayersByNodes = pvVar1;
  }
  return pvVar1;
}

*/
- (id)sublayersByNodes
{
    if (_sublayersByNodes == nil) {
        _sublayersByNodes = NSCreateMapTable(NSNonOwnedPointerMapKeyCallBacks, NSObjectMapValueCallBacks, 0);
    }
    return _sublayersByNodes;
    return 0;
}

- (void)dealloc
{
    if (_selection != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSNodeSelectionDidChangeNotification" object:_selection];
    }
    [_sublayers makeObjectsPerformSelector:@selector(setParentLayer:) withObject:nil];
    [_sublayers release];
    [_selection release];
    if (_sublayersByNodes != nil) {
        NSFreeMapTable(_sublayersByNodes);
    }
    [super dealloc];
}

@end

