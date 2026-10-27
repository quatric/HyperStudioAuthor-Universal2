#import "HSObjectKnobsCanvasLayer.h"

@implementation HSObjectKnobsCanvasLayer

/* i386 ivar offsets: _hyperObject=0x10, _node=0x14, _knobsProvider=0x18, _knobs=0x1c, _observedAttributes=0x20, _trackingKnob=0x24, _delegate=0x28 */

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags hitTestInfo:(id)aInfo event:(id)aEvent
{
    id pvVar1;

    if (_trackingKnob == nil) {
        pvVar1 = [super cursorForPoint:aPoint insideView:(unsigned int)aView modifierFlags:aFlags hitTestInfo:aInfo event:aEvent];
    }
    else {
        pvVar1 = [_trackingKnob cursorAtPoint:aPoint modifierFlags:aFlags inCanvasLayer:self];
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000984ac @ 000984ac, 324 bytes * /

id FUN_000984ac(HSObjectKnobsCanvasLayer *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  undefined *self_00;
  id pvVar6;
  SEL op;
  id local_18;
  id local_14;
  
  pvVar2 = _objc_msgSend(self,sel_numberOfCanvasItems);
  self_00 = cls_NSEProtocolSet;
  op = sel_protocolSet;
  if (pvVar2 != (id)0x0) {
    pvVar6 = (id)0x0;
    local_18 = (id)0x0;
    local_14 = (id)0x0;
    do {
      pvVar5 = pvVar6;
      pvVar3 = _objc_msgSend(self,sel_canvasItemAtIndex_,pvVar6);
      pvVar3 = _objc_msgSend(pvVar3,sel_affectingAttributes);
      if (local_18 == (id)0x0) {
        pvVar1 = pvVar3;
        if ((local_14 != (id)0x0) &&
           (pvVar5 = local_14, pvVar4 = _objc_msgSend(pvVar3,sel_isSubsetOfProtocolSet_,local_14),
           pvVar1 = local_14, (char)pvVar4 == '\0')) {
          pvVar5 = _objc_msgSend(local_14,sel_mutableCopy,pvVar5);
          local_18 = _objc_msgSend(pvVar5,sel_autorelease);
          goto LAB_0009858f;
        }
      }
      else {
LAB_0009858f:
        _objc_msgSend(local_18,sel_unionProtocolSet_,pvVar3);
        pvVar5 = pvVar3;
        pvVar1 = local_14;
      }
      local_14 = pvVar1;
      pvVar6 = (id)((int)pvVar6 + 1);
    } while (pvVar6 < pvVar2);
    if (local_18 == (id)0x0) {
      self_00 = cls_NSEProtocolSet;
      op = sel_protocolSet;
      if (local_14 != (id)0x0) {
        return local_14;
      }
    }
    else {
      self_00 = _objc_msgSend(local_18,sel_copy,pvVar5);
      op = sel_autorelease;
    }
  }
  pvVar2 = _objc_msgSend(self_00,op);
  return pvVar2;
}

*/
- (id)allAttributesAffectingKnobs
{
    NSUInteger count = [self numberOfCanvasItems];
    if (count != 0) {
        id union_ = nil;
        id first = nil;
        for (NSUInteger index = 0; index < count; index++) {
            id attributes = [[self canvasItemAtIndex:index] affectingAttributes];
            if (union_ == nil) {
                if (first == nil) {
                    first = attributes;
                    continue;
                }
                if ([attributes isSubsetOfProtocolSet:first]) {
                    continue;
                }
                union_ = [[first mutableCopy] autorelease];
            }
            [union_ unionProtocolSet:attributes];
        }
        if (union_ != nil) {
            return [[union_ copy] autorelease];
        }
        if (first != nil) {
            return first;
        }
    }
    return [NSEProtocolSet protocolSet];
    return 0;
}

- (void)updateObservedAttributesWithSet:(id)aSet
{
    id pvVar1_2;
    id pvVar1_3;

    if (![_observedAttributes isEqualToProtocolSet:aSet]) {
        pvVar1_2 = _observedAttributes;
        [self updateNotificationsObservingWithOldAttributes:pvVar1_2 newAttributes:aSet];
        [_observedAttributes release];
        if ([aSet count] == 0) {
            pvVar1_3 = nil;
        }
        else {
            pvVar1_3 = [aSet copy];
        }
        _observedAttributes = pvVar1_3;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000987e0 @ 000987e0, 1124 bytes * /

void FUN_000987e0(HSObjectKnobsCanvasLayer *self,SEL _cmd,
                 id updateNotificationsObservingWithOldAttributes,id newAttributes)

{
  undefined4 uVar1;
  int iVar2;
  undefined4 uVar3;
  id self_00;
  id pvVar4;
  id pvVar5;
  SEL op;
  undefined4 *puVar6;
  undefined *puVar7;
  undefined4 uVar8;
  id local_e0;
  id local_dc;
  undefined4 local_d4;
  int local_d0;
  int *local_cc;
  undefined4 local_c8;
  undefined4 local_c4;
  undefined4 local_c0;
  undefined4 local_bc;
  undefined4 local_b8;
  undefined local_b4 [64];
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined local_50 [64];
  
  if (self->_hyperObject != (id)0x0) {
    self_00 = _objc_msgSend(self->_hyperObject,sel_attributeObservingController);
    pvVar4 = _objc_msgSend(newAttributes,sel_count);
    if ((pvVar4 == (id)0x0) &&
       (pvVar4 = _objc_msgSend(updateNotificationsObservingWithOldAttributes,sel_count),
       pvVar4 != (id)0x0)) {
      uVar8 = *(undefined4 *)PTR_0033601c;
      op = sel_removeObserver_selector_ofChanges_ofAttributesFromSet_;
    }
    else {
      pvVar4 = _objc_msgSend(updateNotificationsObservingWithOldAttributes,sel_count);
      if ((pvVar4 != (id)0x0) ||
         (pvVar4 = _objc_msgSend(newAttributes,sel_count), pvVar4 == (id)0x0)) {
        pvVar4 = _objc_msgSend(updateNotificationsObservingWithOldAttributes,sel_count);
        if (pvVar4 == (id)0x0) {
          return;
        }
        pvVar4 = _objc_msgSend(newAttributes,sel_count);
        if (pvVar4 == (id)0x0) {
          return;
        }
        local_d4 = 0;
        local_d0 = 0;
        local_cc = (int *)0x0;
        local_c8 = 0;
        local_c4 = 0;
        local_c0 = 0;
        local_bc = 0;
        local_b8 = 0;
        puVar7 = local_b4;
        puVar6 = &local_d4;
        uVar8 = 0x10;
        local_dc = _objc_msgSend(updateNotificationsObservingWithOldAttributes,
                                 sel_countByEnumeratingWithState_objects_count_,puVar6,puVar7,0x10);
        if (local_dc == (id)0x0) {
          local_e0 = (id)0x0;
        }
        else {
          uVar1 = *(undefined4 *)PTR_0033601c;
          iVar2 = *local_cc;
          local_e0 = (id)0x0;
          do {
            pvVar4 = (id)0x0;
            do {
              if (iVar2 != *local_cc) {
                _objc_enumerationMutation(updateNotificationsObservingWithOldAttributes);
              }
              uVar3 = *(undefined4 *)(local_d0 + (int)pvVar4 * 4);
              pvVar4 = (id)((int)pvVar4 + 1);
              pvVar5 = _objc_msgSend(newAttributes,sel_containsProtocol_,uVar3,puVar7,uVar8);
              if ((char)pvVar5 == '\0') {
                puVar7 = sel_nodeAttributesDidChange_;
                uVar8 = uVar1;
                _objc_msgSend(self_00,sel_removeObserver_selector_ofChanges_ofAttribute_,self,
                              sel_nodeAttributesDidChange_,uVar1,uVar3);
              }
              else {
                local_e0 = (id)((int)local_e0 + 1);
              }
            } while (pvVar4 < local_dc);
            puVar7 = local_b4;
            puVar6 = &local_d4;
            uVar8 = 0x10;
            local_dc = _objc_msgSend(updateNotificationsObservingWithOldAttributes,
                                     sel_countByEnumeratingWithState_objects_count_,puVar6,puVar7,
                                     0x10);
          } while (local_dc != (id)0x0);
        }
        pvVar4 = _objc_msgSend(newAttributes,sel_count,puVar6,puVar7,uVar8);
        if (pvVar4 <= local_e0) {
          return;
        }
        local_74 = 0;
        local_70 = 0;
        local_6c = (int *)0x0;
        local_68 = 0;
        local_64 = 0;
        local_60 = 0;
        local_5c = 0;
        local_58 = 0;
        puVar7 = local_50;
        uVar8 = 0x10;
        local_dc = _objc_msgSend(newAttributes,sel_countByEnumeratingWithState_objects_count_,
                                 &local_74,puVar7,0x10);
        if (local_dc == (id)0x0) {
          return;
        }
        uVar1 = *(undefined4 *)PTR_0033601c;
        iVar2 = *local_6c;
        do {
          pvVar4 = (id)0x0;
          do {
            if (iVar2 != *local_6c) {
              _objc_enumerationMutation(newAttributes);
            }
            uVar3 = *(undefined4 *)(local_70 + (int)pvVar4 * 4);
            pvVar5 = _objc_msgSend(updateNotificationsObservingWithOldAttributes,
                                   sel_containsProtocol_,uVar3,puVar7,uVar8);
            if ((char)pvVar5 == '\0') {
              puVar7 = sel_nodeAttributesDidChange_;
              uVar8 = uVar1;
              _objc_msgSend(self_00,sel_addObserver_selector_ofChanges_ofAttribute_withPriority_,
                            self,sel_nodeAttributesDidChange_,uVar1,uVar3,0xbe800000);
            }
            pvVar4 = (id)((int)pvVar4 + 1);
          } while (pvVar4 < local_dc);
          puVar7 = local_50;
          uVar8 = 0x10;
          local_dc = _objc_msgSend(newAttributes,sel_countByEnumeratingWithState_objects_count_,
                                   &local_74,puVar7,0x10);
        } while (local_dc != (id)0x0);
        return;
      }
      uVar8 = *(undefined4 *)PTR_0033601c;
      op = sel_addObserver_selector_ofChanges_ofAttributesFromSet_withPriority_;
      updateNotificationsObservingWithOldAttributes = newAttributes;
    }
    _objc_msgSend(self_00,op,self,sel_nodeAttributesDidChange_,uVar8,
                  updateNotificationsObservingWithOldAttributes);
  }
  return;
}

*/
- (void)updateNotificationsObservingWithOldAttributes:(id)aAttributes newAttributes:(id)aAttributes2
{
    if (_hyperObject == nil) {
        return;
    }
    id controller = [_hyperObject attributeObservingController];
    if ([aAttributes2 count] == 0 && [aAttributes count] != 0) {
        [controller removeObserver:self selector:@selector(nodeAttributesDidChange:) ofChanges:HSActualDidAttributeChanges ofAttributesFromSet:aAttributes];
    } else if ([aAttributes count] == 0 && [aAttributes2 count] != 0) {
        [controller addObserver:self selector:@selector(nodeAttributesDidChange:) ofChanges:HSActualDidAttributeChanges ofAttributesFromSet:aAttributes2 withPriority:-0.25];
    } else {
        if ([aAttributes count] == 0 || [aAttributes2 count] == 0) {
            return;
        }
        NSUInteger kept = 0;
        for (id protocol in aAttributes) {
            if (![aAttributes2 containsProtocol:protocol]) {
                [controller removeObserver:self selector:@selector(nodeAttributesDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:protocol];
            } else {
                kept++;
            }
        }
        if ([aAttributes2 count] <= kept) {
            return;
        }
        for (id protocol in aAttributes2) {
            if (![aAttributes containsProtocol:protocol]) {
                [controller addObserver:self selector:@selector(nodeAttributesDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:protocol withPriority:-0.25];
            }
        }
    }
}

- (void)didFinishTrackingKnob:(id)aKnob
{
    [self invalidateDisplayForCanvasItem:aKnob];
    [aKnob setBeingTracked:NO];
    [_trackingKnob release];
    _trackingKnob = nil;
    [self invalidateDisplayForCanvasItem:aKnob];
    if (_delegate != nil) {
        if ([_delegate respondsToSelector:@selector(objectKnobsCanvasLayerDidFinishTrackingKnob:)]) {
            [_delegate performSelector:@selector(objectKnobsCanvasLayerDidFinishTrackingKnob:) withObject:self];
        }
    }
}

- (void)willStartTrackingKnob:(id)aKnob
{
    if (_delegate != nil) {
        if ([_delegate respondsToSelector:@selector(objectKnobsCanvasLayerWillStartTrackingKnob:)]) {
            [_delegate performSelector:@selector(objectKnobsCanvasLayerWillStartTrackingKnob:) withObject:self];
        }
    }
    [self invalidateDisplayForCanvasItem:aKnob];
    [aKnob setBeingTracked:YES];
    _trackingKnob = [aKnob retain];
    [self invalidateDisplayForCanvasItem:aKnob];
}

- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo
{
    BOOL BVar1;
    id self_00;
    id self_01;
    id pvVar2_3;

    if (aInfo == nil) {
        BVar1 = NO;
    }
    else {
        self_00 = [aInfo querySelectionTrackerForModifierFlags:[aEvent modifierFlags]];
        if (self_00 == nil) {
            BVar1 = YES;
        }
        else {
            pvVar2_3 = [[self context] queryHyperInterface:@protocol(HSEditorCanvasLayerContext)];
            self_01 = [self renderingView];
            [self_00 setLayoutGuidingContext:[pvVar2_3 layoutGuidingContext]];
            [self_00 setTrackingObject:self];
            [self willStartTrackingKnob:aInfo];
            [self_01 acceptDrawingQualityLoss:0.1];
            [[HSTrackingLoop trackingLoopWithView:self_01 client:self_00] runWithMouseDownEvent:aEvent];
            [self_01 declineDrawingQualityLoss:0.1];
            [self_01 setNeedsDisplayOpenGLSurface:YES];
            [self_00 setTrackingObject:nil];
            [self_00 setLayoutGuidingContext:nil];
            [self didFinishTrackingKnob:aInfo];
            BVar1 = YES;
        }
    }
    return BVar1;
}

- (id)knobs
{
    id pvVar1;

    pvVar1 = _knobs;
    if (pvVar1 == nil) {
        _knobs = [NSMutableArray new];
        [self rebuildKnobs];
        pvVar1 = _knobs;
    }
    return pvVar1;
}

- (void)updateKnobs
{
    if (_knobs != nil) {
        [self setActiveItem:nil];
        [self invalidateDisplay];
        [self rebuildKnobs];
        [self invalidateDisplay];
    }
}

- (void)rebuildKnobs
{
    if (_knobs != nil) {
        [_knobs removeAllObjects];
        [_knobs addObjectsFromArray:[_knobsProvider buildSelectionKnobs]];
        [self updateObservedAttributesWithSet:[self allAttributesAffectingKnobs]];
    }
}

- (NSUInteger)indexOfKnob:(id)aKnob
{
    return (unsigned int)[[self knobs] indexOfObject:aKnob];
}

- (id)knobAtIndex:(NSUInteger)aIndex
{
    return [[self knobs] objectAtIndex:aIndex];
}

- (NSUInteger)numberOfKnobs
{
    return (unsigned int)[[self knobs] count];
}

- (BOOL)supportsHitTesting
{
    return YES;
}

- (id)canvasItemAtIndex:(NSUInteger)aIndex
{
    return [[self knobs] objectAtIndex:aIndex];
}

- (NSUInteger)numberOfCanvasItems
{
    return (unsigned int)[[self knobs] count];
}

- (id)knobsProvider
{
    return _knobsProvider;
}

- (void)refreshKnobsProvider
{
    [self setKnobsProvider:[_hyperObject queryHyperInterface:@protocol(HSSelectionKnobsProvider)]];
}

- (void)setKnobsProvider:(id)aProvider
{
    if (_knobsProvider != aProvider) {
        [_knobsProvider release];
        _knobsProvider = [aProvider retain];
        [self updateKnobs];
    }
}

- (void)knobProviderDidChange:(id)aChange
{
    [self refreshKnobsProvider];
}

- (void)nodeAttributesDidChange:(id)aChange
{
    [self updateCanvasItemsIfNeeded];
}

- (id)node
{
    return _node;
}

- (void)setNode:(id)aNode
{
    [self setHyperObject:aNode nodeAttributes:aNode];
}

- (id)hyperObject
{
    return _hyperObject;
}

- (void)setHyperObject:(id)aObject
{
    [self setHyperObject:aObject nodeAttributes:[aObject queryHyperInterface:@protocol(HSNodeAttributes)]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00097ad5 @ 00097ad5, 458 bytes * /

void FUN_00097ad5(HSObjectKnobsCanvasLayer *self,SEL _cmd,id setHyperObject,id nodeAttributes)

{
  id pvVar1;
  HSObjectKnobsCanvasLayer *pHVar2;
  undefined *puVar3;
  undefined4 uVar4;
  undefined4 uVar5;
  undefined *puVar6;
  undefined *puVar7;
  
  pvVar1 = self->_hyperObject;
  if (pvVar1 != setHyperObject) {
    if (pvVar1 != (id)0x0) {
      pvVar1 = _objc_msgSend(pvVar1,sel_attributeObservingController);
      puVar6 = &DAT_003678fc;
      uVar5 = *(undefined4 *)PTR_0033601c;
      pHVar2 = self;
      puVar3 = sel_knobProviderDidChange_;
      uVar4 = uVar5;
      _objc_msgSend(pvVar1,sel_removeObserver_selector_ofChanges_ofAttribute_,self,
                    sel_knobProviderDidChange_,uVar5,&DAT_003678fc);
      puVar7 = self->_observedAttributes;
      if (puVar7 != (undefined *)0x0) {
        pHVar2 = self;
        puVar3 = sel_nodeAttributesDidChange_;
        _objc_msgSend(pvVar1,sel_removeObserver_selector_ofChanges_ofAttributesFromSet_,self,
                      sel_nodeAttributesDidChange_,uVar5,puVar7);
        uVar4 = uVar5;
        puVar6 = puVar7;
      }
      _objc_msgSend(self->_hyperObject,sel_release,pHVar2,puVar3,uVar4,puVar6);
    }
    pvVar1 = _objc_msgSend(setHyperObject,sel_retain);
    self->_hyperObject = pvVar1;
    _objc_msgSend(self->_node,sel_autorelease);
    pvVar1 = _objc_msgSend(nodeAttributes,sel_retain);
    self->_node = pvVar1;
    _objc_msgSend(self,sel_refreshKnobsProvider);
    if (self->_hyperObject != (id)0x0) {
      pvVar1 = _objc_msgSend(self->_hyperObject,sel_attributeObservingController);
      if (self->_observedAttributes != (id)0x0) {
        _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttributesFromSet_withPriority_,
                      self,sel_nodeAttributesDidChange_,*(undefined4 *)PTR_0033601c,
                      self->_observedAttributes,0xbe800000);
      }
      _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttribute_withPriority_,self,
                    sel_knobProviderDidChange_,*(undefined4 *)PTR_0033601c,&DAT_003678fc,0xbe800000)
      ;
    }
  }
  return;
}

*/
- (void)setHyperObject:(id)aObject nodeAttributes:(id)aAttributes
{
    if (_hyperObject != aObject) {
        if (_hyperObject != nil) {
            id controller = [_hyperObject attributeObservingController];
            [controller removeObserver:self selector:@selector(knobProviderDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSSelectionKnobsProviderAttribute)];
            if (_observedAttributes != nil) {
                [controller removeObserver:self selector:@selector(nodeAttributesDidChange:) ofChanges:HSActualDidAttributeChanges ofAttributesFromSet:_observedAttributes];
            }
            [_hyperObject release];
        }
        _hyperObject = [aObject retain];
        [_node autorelease];
        _node = [aAttributes retain];
        [self refreshKnobsProvider];
        if (_hyperObject != nil) {
            id controller = [_hyperObject attributeObservingController];
            if (_observedAttributes != nil) {
                [controller addObserver:self selector:@selector(nodeAttributesDidChange:) ofChanges:HSActualDidAttributeChanges ofAttributesFromSet:_observedAttributes withPriority:-0.25];
            }
            [controller addObserver:self selector:@selector(knobProviderDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSSelectionKnobsProviderAttribute) withPriority:-0.25];
        }
    }
}

- (void)dealloc
{
    id self_00;

    [_knobs release];
    [_knobsProvider release];
    if (_hyperObject != nil) {
        self_00 = [_hyperObject attributeObservingController];
        if (_observedAttributes != nil) {
            [self_00 removeObserver:self selector:@selector(nodeAttributesDidChange:) ofChanges:HSActualDidAttributeChanges ofAttributesFromSet:_observedAttributes];
        }
        [self_00 removeObserver:self selector:@selector(knobProviderDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSSelectionKnobsProviderAttribute)];
        [_hyperObject release];
    }
    [_node release];
    [_observedAttributes release];
    [_trackingKnob release];
    [super dealloc];
}

@end

