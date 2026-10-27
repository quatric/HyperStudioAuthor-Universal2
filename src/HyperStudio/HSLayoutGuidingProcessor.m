#import "HSLayoutGuidingProcessor.h"

static NSArray *sRuleBuckets;

static CGFloat HSLayoutGuidingSideCoordinate(NSRect rect, NSInteger side)
{
    switch (side) {
    case 0:
        return rect.origin.x;
    case 1:
        return rect.origin.y;
    case 2:
        return rect.origin.x + rect.size.width;
    case 3:
        return rect.origin.y + rect.size.height;
    case 4:
        return rect.size.width * 0.5 + rect.origin.x;
    case 5:
        return rect.size.height * 0.5 + rect.origin.y;
    case 6:
        return rect.size.width;
    case 7:
        return rect.size.height;
    }
    return 0.0;
}

// FUN_00046ce2: sorts every rule into the bucket of each rect side it affects.
static void HSLayoutGuidingFillBuckets(NSArray *rules, NSArray *buckets)
{
    NSEnumerator *enumerator = [rules objectEnumerator];
    id rule;
    while ((rule = [enumerator nextObject]) != nil) {
        for (NSInteger side = 0; side != 8; side++) {
            if ([rule affectsRectSide:side]) {
                if ([[buckets objectAtIndex:side] indexOfObjectIdenticalTo:rule] == NSNotFound) {
                    [[buckets objectAtIndex:side] addObject:rule];
                }
            }
        }
    }
}

// FUN_00046dca: moves the rules left in the buckets of one axis (x: even sides, y: odd sides) into the given array.
static void HSLayoutGuidingCollectBuckets(NSArray *buckets, NSMutableArray *rules, NSInteger axis)
{
    NSUInteger count = [buckets count];
    [rules removeAllObjects];
    for (NSUInteger side = 0; side < count; side++) {
        NSInteger sideAxis = (side < 7 && ((0x55U >> (side & 0x1f)) & 1) != 0) ? 0 : 1;
        if (sideAxis == axis) {
            NSMutableArray *bucket = [buckets objectAtIndex:side];
            [rules addObjectsFromArray:bucket];
            [bucket removeAllObjects];
        }
    }
}

@implementation HSLayoutGuidingProcessor

/* i386 ivar offsets: _geometryHoldersProvider=0x4, _xAxisRules=0x8, _yAxisRules=0xc, _snapDelta=0x10, _snappers=0x14, _disabledRuleTypes=0x18 */

- (id)objectInHyperGeometryHoldersForInterface:(id)aInterface atIndex:(NSUInteger)aIndex
{
    id pvVar1;

    if (_geometryHoldersProvider == nil) {
        pvVar1 = nil;
    }
    else {
        pvVar1 = [_geometryHoldersProvider objectInHyperGeometryHoldersForInterface:aInterface atIndex:aIndex];
    }
    return pvVar1;
}

- (NSUInteger)countOfHyperGeometryHoldersForInterface:(id)aInterface
{
    NSUInteger pvVar1;

    if (_geometryHoldersProvider == nil) {
        pvVar1 = 0;
    }
    else {
        pvVar1 = [_geometryHoldersProvider countOfHyperGeometryHoldersForInterface:aInterface];
    }
    return (unsigned int)pvVar1;
}

- (id)createGridCornerRuleWithCorner:(NSPoint)aCorner rectEdgeMask:(NSInteger)aMask
{
    id pvVar1_2;

    pvVar1_2 = [[HSLayoutGridCornerAlignmentRule alloc] initWithGridCorner:aCorner rectEdgeMask:aMask];
    [self addRule:pvVar1_2];
    return pvVar1_2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000456c7 @ 000456c7, 217 bytes * /

id FUN_000456c7(HSLayoutGuidingProcessor *self,SEL _cmd,int createLayoutRuleWithType,int rectSide,
               float value)

{
  id pvVar1;
  int iVar2;
  SEL pcVar3;
  
  if ((createLayoutRuleWithType == 1) || (createLayoutRuleWithType == 3)) {
    pvVar1 = _objc_msgSend(cls_HSLayoutObjectsRule,sel_alloc);
    pcVar3 = sel_initWithRectSide_value_type_;
    iVar2 = rectSide;
    rectSide = (int)value;
  }
  else {
    pvVar1 = _objc_msgSend(cls_HSLayoutSimpleRule,sel_alloc);
    pcVar3 = sel_initWithAxisType_rectSide_value_type_;
    createLayoutRuleWithType = (int)value;
    if (((uint)rectSide < 7) && ((0x55U >> (rectSide & 0x1fU) & 1) != 0)) {
      iVar2 = 0;
    }
    else {
      iVar2 = 1;
    }
  }
  pvVar1 = _objc_msgSend(pvVar1,pcVar3,iVar2,rectSide,createLayoutRuleWithType);
  _objc_msgSend(self,sel_addRule_,pvVar1);
  return pvVar1;
}

*/
- (id)createLayoutRuleWithType:(NSInteger)aType rectSide:(NSInteger)aSide value:(CGFloat)aValue
{
    id rule;
    if (aType == 1 || aType == 3) {
        rule = [[HSLayoutObjectsRule alloc] initWithRectSide:aSide value:aValue type:aType];
    } else {
        NSInteger axis = (aSide < 7 && ((0x55U >> (aSide & 0x1f)) & 1) != 0) ? 0 : 1;
        rule = [[HSLayoutSimpleRule alloc] initWithAxisType:axis rectSide:aSide value:aValue type:aType];
    }
    [self addRule:rule];
    return [rule autorelease];
    return 0;
}

- (void)addRule:(id)aRule
{
    if ([aRule appliesToXAxis]) {
        [_xAxisRules addObject:aRule];
    }
    if ([aRule appliesToYAxis]) {
        [_yAxisRules addObject:aRule];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0004581b @ 0004581b, 1235 bytes * /

BOOL FUN_0004581b(HSLayoutGuidingProcessor *self,SEL _cmd,NSRect *snapRect,int edges,
                 NSSize transformationDirectionHint,id *appliedRules)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  double dVar3;
  id pvVar4;
  float fVar5;
  float fVar6;
  float fVar7;
  int iVar8;
  byte local_66;
  byte local_65;
  id local_64;
  float local_60;
  float local_5c;
  float local_58;
  id local_54;
  undefined4 local_50;
  undefined4 local_4c;
  undefined4 local_48;
  id local_44;
  float local_40;
  float local_3c;
  float local_38;
  id local_34;
  float fStack_30;
  float local_2c;
  float fStack_28;
  id local_24;
  float fStack_20;
  float local_1c;
  float fStack_18;
  
  local_34 = (id)(snapRect->origin).x;
  fStack_30 = (snapRect->origin).y;
  local_2c = (snapRect->size).width;
  fStack_28 = (snapRect->size).height;
  if (((edges & 5U) == 0) || ((edges & 5U) == 5)) {
    local_66 = 0;
  }
  else {
    local_66 = 1;
  }
  if (((edges & 10U) == 0) || ((edges & 10U) == 10)) {
    local_65 = 0;
  }
  else {
    local_65 = 1;
  }
  local_24 = local_34;
  fStack_20 = fStack_30;
  local_1c = local_2c;
  fStack_18 = fStack_28;
  _objc_msgSend(self->_xAxisRules,sel_removeAllObjects);
  _objc_msgSend(self->_yAxisRules,sel_removeAllObjects);
  self_00 = _objc_msgSend(self->_snappers,sel_objectEnumerator);
  pvVar1 = _objc_msgSend(self_00,sel_nextObject);
  pvVar4 = local_24;
  fVar5 = fStack_20;
  fVar6 = local_1c;
  fVar7 = fStack_18;
  while (local_24 = pvVar4, fStack_20 = fVar5, local_1c = fVar6, fStack_18 = fVar7,
        pvVar1 != (id)0x0) {
    pvVar4 = pvVar1;
    pvVar2 = _objc_msgSend(self,sel_shouldUseSnapper_,pvVar1);
    if ((char)pvVar2 != '\0') {
      dVar3 = _objc_msgSend_fpret(self,sel_snapDelta);
      pvVar4 = local_24;
      _objc_msgSend(pvVar1,sel_calculateSuggestedRulesForSnappingRect_snapDelta_edges_processor_,
                    local_24,fStack_20,local_1c,fStack_18,(float)dVar3,edges,self);
    }
    pvVar1 = _objc_msgSend(self_00,sel_nextObject,pvVar4);
    pvVar4 = local_24;
    fVar5 = fStack_20;
    fVar6 = local_1c;
    fVar7 = fStack_18;
  }
  iVar8 = edges;
  _objc_msgSend(self,sel_filterRulesForSnappingRect_edges_transformationDirectionHint_,pvVar4,fVar5,
                fVar6,fVar7,edges,transformationDirectionHint.width,
                transformationDirectionHint.height);
  pvVar1 = _objc_msgSend(self->_xAxisRules,sel_count);
  if ((pvVar1 == (id)0x0) &&
     (pvVar1 = _objc_msgSend(self->_yAxisRules,sel_count,pvVar4,fVar5,fVar6,fVar7,iVar8,
                             transformationDirectionHint.width,transformationDirectionHint.height),
     pvVar1 == (id)0x0)) {
    if (appliedRules != (id *)0x0) {
      *appliedRules = (id)0x0;
    }
    return '\0';
  }
  local_65 = local_65 | local_66;
  pvVar1 = _objc_msgSend(self->_xAxisRules,sel_count,pvVar4,fVar5,fVar6,fVar7,iVar8,
                         transformationDirectionHint.width,transformationDirectionHint.height);
  if (pvVar1 != (id)0x0) {
    pvVar1 = _objc_msgSend(self->_xAxisRules,sel_objectAtIndex_,0,fVar5,fVar6,fVar7,iVar8,
                           transformationDirectionHint.width,transformationDirectionHint.height);
    pvVar1 = _objc_msgSend(pvVar1,sel_ruleType);
    if (pvVar1 == (id)0x1) {
      _objc_msgSend_stret(&local_34,self,sel_applyRules_toRect_changingSize_directionIsPositive_,
                          self->_yAxisRules,local_34,fStack_30,local_2c,fStack_28,
                          (int)(char)local_65,edges & 8);
      _objc_msgSend_stret(&local_44,self,sel_applyRules_toRect_changingSize_directionIsPositive_,
                          self->_xAxisRules,local_34,fStack_30,local_2c,fStack_28,
                          (int)(char)local_65,edges & 4);
      local_2c = local_3c;
      fStack_28 = local_38;
      local_34 = local_44;
      fStack_30 = local_40;
      goto LAB_00045c1a;
    }
  }
  _objc_msgSend_stret(&local_54,self,sel_applyRules_toRect_changingSize_directionIsPositive_,
                      self->_xAxisRules,local_34,fStack_30,local_2c,fStack_28,(int)(char)local_65,
                      edges & 4);
  local_34 = local_54;
  fStack_30 = (float)local_50;
  local_2c = (float)local_4c;
  fStack_28 = (float)local_48;
  _objc_msgSend_stret(&local_64,self,sel_applyRules_toRect_changingSize_directionIsPositive_,
                      self->_yAxisRules,local_54,local_50,local_4c,local_48,(int)(char)local_65,
                      edges & 8);
  local_2c = local_5c;
  fStack_28 = local_58;
  local_34 = local_64;
  fStack_30 = local_60;
LAB_00045c1a:
  if (appliedRules != (id *)0x0) {
    pvVar1 = _objc_msgSend(cls_NSMutableSet,sel_new);
    pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
    _objc_msgSend(pvVar1,sel_addObjectsFromArray_,self->_xAxisRules);
    _objc_msgSend(pvVar1,sel_addObjectsFromArray_,self->_yAxisRules);
    pvVar1 = _objc_msgSend(pvVar1,sel_allObjects);
    *appliedRules = pvVar1;
  }
  (snapRect->origin).x = (float)local_34;
  (snapRect->origin).y = fStack_30;
  (snapRect->size).width = local_2c;
  (snapRect->size).height = fStack_28;
  return '\x01';
}

*/
- (BOOL)snapRect:(NSRect *)aRect edges:(NSInteger)aEdges transformationDirectionHint:(NSSize)aHint appliedRules:(id *)aRules
{
    NSRect rect = *aRect;
    BOOL changesX = ((aEdges & 5) != 0 && (aEdges & 5) != 5);
    BOOL changesY = ((aEdges & 10) != 0 && (aEdges & 10) != 10);
    [_xAxisRules removeAllObjects];
    [_yAxisRules removeAllObjects];
    NSEnumerator *enumerator = [_snappers objectEnumerator];
    id snapper;
    while ((snapper = [enumerator nextObject]) != nil) {
        if ([self shouldUseSnapper:snapper]) {
            [snapper calculateSuggestedRulesForSnappingRect:rect snapDelta:[self snapDelta] edges:aEdges processor:self];
        }
    }
    [self filterRulesForSnappingRect:rect edges:aEdges transformationDirectionHint:aHint];
    if ([_xAxisRules count] == 0 && [_yAxisRules count] == 0) {
        if (aRules != NULL) {
            *aRules = nil;
        }
        return NO;
    }
    BOOL changingSize = changesX || changesY;
    if ([_xAxisRules count] != 0 && [[_xAxisRules objectAtIndex:0] ruleType] == 1) {
        rect = [self applyRules:_yAxisRules toRect:rect changingSize:changingSize directionIsPositive:(aEdges & 8)];
        rect = [self applyRules:_xAxisRules toRect:rect changingSize:changingSize directionIsPositive:(aEdges & 4)];
    } else {
        rect = [self applyRules:_xAxisRules toRect:rect changingSize:changingSize directionIsPositive:(aEdges & 4)];
        rect = [self applyRules:_yAxisRules toRect:rect changingSize:changingSize directionIsPositive:(aEdges & 8)];
    }
    if (aRules != NULL) {
        NSMutableSet *rules = [[NSMutableSet new] autorelease];
        [rules addObjectsFromArray:_xAxisRules];
        [rules addObjectsFromArray:_yAxisRules];
        *aRules = [rules allObjects];
    }
    *aRect = rect;
    return YES;
    return 0;
}

- (void)setLayoutRulesEnabled:(BOOL)aEnabled forType:(NSInteger)aType
{
    unsigned int uVar1;
    unsigned int uVar2;
    unsigned int uVar2_2;

    uVar1 = 1 << (aType & 0x1f);
    uVar2 = _disabledRuleTypes;
    if (((uVar2 >> (aType & 0x1fU) & 1) == 0) != (BOOL)aEnabled) {
        if (aEnabled == NO) {
            uVar2_2 = uVar2 | uVar1;
        }
        else {
            uVar2_2 = uVar2 & ~uVar1;
        }
        _disabledRuleTypes = uVar2_2;
    }
}

- (BOOL)areLayoutRulesEnabledForType:(NSInteger)aType
{
    return (_disabledRuleTypes >> (aType & 0x1fU) & 1) == 0;
}

- (void)setGeometryHoldersProvider:(id)aProvider
{
    _geometryHoldersProvider = aProvider;
}

- (id)geometryHoldersProvider
{
    return _geometryHoldersProvider;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00045cee @ 00045cee, 652 bytes * /

NSRect * FUN_00045cee(NSRect *__return_storage_ptr__,HSLayoutGuidingProcessor *self,SEL _cmd,
                     id applyRules,NSRect toRect,BOOL changingSize,BOOL directionIsPositive)

{
  float fVar1;
  id self_00;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  int *piVar6;
  float fVar7;
  float fVar8;
  float fVar9;
  double dVar10;
  int local_70;
  float local_60 [11];
  float local_34;
  float local_30;
  float local_2c;
  float local_28;
  float local_24;
  float fStack_20;
  float local_1c;
  float fStack_18;
  
  piVar6 = (int *)&stack0xffffff94;
  local_24 = toRect.origin.x;
  fStack_20 = toRect.origin.y;
  local_1c = toRect.size.width;
  fStack_18 = toRect.size.height;
  self_00 = _objc_msgSend(applyRules,sel_objectEnumerator);
  pvVar2 = _objc_msgSend(self_00,sel_nextObject);
  while (pvVar2 != (id)0x0) {
    piVar6[1] = (int)sel_affectedRectSidesCount;
    *piVar6 = (int)pvVar2;
    piVar6[-1] = 0x45d6b;
    pvVar3 = _objc_msgSend((id)*piVar6,(SEL)piVar6[1]);
    if (pvVar3 != (id)0x0) {
      pvVar5 = (id)0x0;
      do {
        piVar6[2] = (int)pvVar5;
        piVar6[1] = (int)sel_affectedRectSideAtIndex_;
        *piVar6 = (int)pvVar2;
        piVar6[-1] = 0x45d8e;
        pvVar4 = _objc_msgSend((id)*piVar6,(SEL)piVar6[1]);
        switch(pvVar4) {
        case (id)0x0:
          fVar7 = local_24;
          break;
        case (id)0x1:
          fVar7 = fStack_20;
          break;
        case (id)0x2:
          fVar7 = local_24 + local_1c;
          break;
        case (id)0x3:
          fVar7 = fStack_20 + fStack_18;
          break;
        case (id)0x4:
          fVar7 = local_1c * 0.5 + local_24;
          break;
        case (id)0x5:
          fVar7 = fStack_18 * 0.5 + fStack_20;
          break;
        case (id)0x6:
          fVar7 = local_1c;
          break;
        case (id)0x7:
          fVar7 = fStack_18;
          break;
        default:
          fVar7 = 0.0;
        }
        piVar6[2] = (int)pvVar4;
        piVar6[1] = (int)sel_layoutRuleFloatValueForRectSide_;
        *piVar6 = (int)pvVar2;
        piVar6[-1] = 0x45e1b;
        dVar10 = _objc_msgSend_fpret((id)*piVar6,(SEL)piVar6[1]);
        fVar1 = (float)dVar10;
        if ((fVar1 != 0.0) || (NAN(fVar1))) {
          fVar8 = ABS(fVar1);
        }
        else {
          fVar8 = 1.0;
        }
        if ((fVar7 != 0.0) || (NAN(fVar7))) {
          fVar9 = ABS(fVar7);
        }
        else {
          fVar9 = 1.0;
        }
        if (fVar9 <= fVar8) {
          fVar9 = fVar8;
        }
        if (fVar9 * 0.0005 < ABS(fVar1 - fVar7)) {
          if (changingSize == '\0') {
            piVar6[5] = (int)local_1c;
            piVar6[6] = (int)fStack_18;
            *(ulonglong *)(piVar6 + 3) = CONCAT44(fStack_20,local_24);
            piVar6[2] = (int)sel_translateRect_;
            piVar6[1] = (int)pvVar2;
            *piVar6 = (int)&local_34;
            piVar6[-1] = 0x45ef2;
            _objc_msgSend_stret((void *)*piVar6,(id)piVar6[1],(SEL)piVar6[2]);
            piVar6 = piVar6 + -1;
            local_24 = local_34;
            fStack_20 = local_30;
            local_1c = local_2c;
            fStack_18 = local_28;
          }
          else {
            piVar6[5] = (int)local_1c;
            piVar6[6] = (int)fStack_18;
            piVar6[3] = (int)local_24;
            piVar6[4] = (int)fStack_20;
            piVar6[2] = (int)sel_scaleRect_;
            piVar6[1] = (int)pvVar2;
            *piVar6 = (int)&local_24;
            piVar6[-1] = 0x45ebe;
            _objc_msgSend_stret((void *)*piVar6,(id)piVar6[1],(SEL)piVar6[2]);
            piVar6 = piVar6 + -1;
          }
        }
        pvVar5 = (id)((int)pvVar5 + 1);
      } while (pvVar5 < pvVar3);
    }
    piVar6[1] = (int)sel_nextObject;
    *piVar6 = (int)self_00;
    piVar6[-1] = 0x45f3c;
    pvVar2 = _objc_msgSend((id)*piVar6,(SEL)piVar6[1]);
  }
  (__return_storage_ptr__->origin).x = local_24;
  (__return_storage_ptr__->origin).y = fStack_20;
  (__return_storage_ptr__->size).width = local_1c;
  (__return_storage_ptr__->size).height = fStack_18;
  return __return_storage_ptr__;
}

*/
- (NSRect)applyRules:(id)aRules toRect:(NSRect)aRect changingSize:(BOOL)aSize directionIsPositive:(BOOL)aPositive
{
    NSRect rect = aRect;
    NSEnumerator *enumerator = [aRules objectEnumerator];
    id rule;
    while ((rule = [enumerator nextObject]) != nil) {
        NSUInteger count = [rule affectedRectSidesCount];
        for (NSUInteger index = 0; index < count; index++) {
            NSInteger side = [rule affectedRectSideAtIndex:index];
            float current = HSLayoutGuidingSideCoordinate(rect, side);
            float value = [rule layoutRuleFloatValueForRectSide:side];
            float valueScale = (value != 0.0f) ? fabsf(value) : 1.0f;
            float currentScale = (current != 0.0f) ? fabsf(current) : 1.0f;
            float scale = (currentScale <= valueScale) ? valueScale : currentScale;
            if (scale * 0.0005 < fabsf(value - current)) {
                if (!aSize) {
                    rect = [rule translateRect:rect];
                } else {
                    rect = [rule scaleRect:rect];
                }
            }
        }
    }
    return rect;
    return (NSRect){0};
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00045f9c @ 00045f9c, 1417 bytes * /

void FUN_00045f9c(HSLayoutGuidingProcessor *self,SEL _cmd,NSRect filterRulesForSnappingRect,
                 int edges,NSSize transformationDirectionHint)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  HSLayoutGuidingProcessor *pHVar8;
  SEL pcVar9;
  id local_34;
  id local_30;
  id local_2c;
  id local_28;
  id local_24;
  id local_20;
  id local_1c;
  id local_18;
  id local_14;
  
  pvVar1 = _objc_msgSend(self->_xAxisRules,sel_count);
  if (pvVar1 < (id)0x2) {
    pvVar1 = _objc_msgSend(self->_xAxisRules,sel_lastObject);
    pvVar1 = _objc_msgSend(pvVar1,sel_canSnapTo);
    if ((char)pvVar1 == '\0') {
      pHVar8 = self->_xAxisRules;
      pcVar9 = sel_removeAllObjects;
      goto LAB_00046092;
    }
  }
  else {
    _objc_msgSend(self->_xAxisRules,sel_count);
    _objc_msgSend(self->_yAxisRules,sel_count);
    pHVar8 = self;
    pcVar9 = sel_filterRules_alongSameAxis_forRect_transformationDirectionHint_otherAxisRules_;
LAB_00046092:
    _objc_msgSend(pHVar8,pcVar9);
  }
  pvVar1 = _objc_msgSend(self->_yAxisRules,sel_count);
  if (pvVar1 < (id)0x2) {
    pvVar1 = _objc_msgSend(self->_yAxisRules,sel_lastObject);
    pvVar1 = _objc_msgSend(pvVar1,sel_canSnapTo);
    if ((char)pvVar1 != '\0') goto LAB_00046183;
    pHVar8 = self->_yAxisRules;
    pcVar9 = sel_removeAllObjects;
  }
  else {
    _objc_msgSend(self->_xAxisRules,sel_count);
    _objc_msgSend(self->_yAxisRules,sel_count);
    pHVar8 = self;
    pcVar9 = sel_filterRules_alongSameAxis_forRect_transformationDirectionHint_otherAxisRules_;
  }
  _objc_msgSend(pHVar8,pcVar9);
LAB_00046183:
  if (DAT_003427a4 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSMutableArray,sel_array);
    pvVar2 = _objc_msgSend(cls_NSMutableArray,sel_array);
    pvVar3 = _objc_msgSend(cls_NSMutableArray,sel_array);
    pvVar4 = _objc_msgSend(cls_NSMutableArray,sel_array);
    pvVar5 = _objc_msgSend(cls_NSMutableArray,sel_array);
    pvVar6 = _objc_msgSend(cls_NSMutableArray,sel_array);
    pvVar7 = _objc_msgSend(cls_NSMutableArray,sel_array);
    local_14 = _objc_msgSend(cls_NSMutableArray,sel_array);
    local_30 = pvVar1;
    local_2c = pvVar2;
    local_28 = pvVar3;
    local_24 = pvVar4;
    local_20 = pvVar5;
    local_1c = pvVar6;
    local_18 = pvVar7;
    pvVar1 = _objc_msgSend(cls_NSArray,sel_alloc);
    DAT_003427a4 = _objc_msgSend(pvVar1,sel_initWithObjects_count_,&local_30,8);
  }
  else {
    pvVar1 = _objc_msgSend(DAT_003427a4,sel_count);
    if (pvVar1 != (id)0x0) {
      pvVar2 = (id)0x0;
      do {
        pvVar3 = _objc_msgSend(DAT_003427a4,sel_objectAtIndex_,pvVar2);
        _objc_msgSend(pvVar3,sel_removeAllObjects);
        pvVar2 = (id)((int)pvVar2 + 1);
      } while (pvVar2 < pvVar1);
    }
  }
  FUN_00046ce2();
  FUN_00046ce2();
  local_34 = (id)0x0;
  do {
    pvVar1 = local_34;
    pvVar2 = _objc_msgSend(DAT_003427a4,sel_objectAtIndex_,local_34);
    pvVar3 = _objc_msgSend(pvVar2,sel_count);
    while ((id)0x1 < pvVar3) {
      pvVar1 = _objc_msgSend(pvVar2,sel_objectAtIndex_,0);
      pvVar3 = _objc_msgSend(pvVar2,sel_objectAtIndex_,1);
      pvVar3 = _objc_msgSend(self,sel_prioritizeByTypeRule_vsRule_,pvVar1,pvVar3);
      pvVar1 = (id)(uint)(pvVar3 == pvVar1);
      _objc_msgSend(pvVar2,sel_removeObjectAtIndex_,pvVar1);
      pvVar3 = _objc_msgSend(pvVar2,sel_count);
    }
    local_34 = (id)((int)local_34 + 1);
  } while (local_34 != (id)0x8);
  FUN_00046dca(DAT_003427a4);
  FUN_00046dca(DAT_003427a4);
  pvVar2 = _objc_msgSend(self->_xAxisRules,sel_count);
  if ((id)0x1 < pvVar2) {
    pvVar1 = self->_xAxisRules;
    _objc_msgSend(self,
                  sel_filterRules_alongSameAxis_forRect_transformationDirectionHint_otherAxisRules_,
                  pvVar1,0,filterRulesForSnappingRect.origin,filterRulesForSnappingRect.size,
                  transformationDirectionHint.width,0);
  }
  pvVar1 = _objc_msgSend(self->_yAxisRules,sel_count,pvVar1);
  if ((id)0x1 < pvVar1) {
    _objc_msgSend(self,
                  sel_filterRules_alongSameAxis_forRect_transformationDirectionHint_otherAxisRules_,
                  self->_yAxisRules,1,filterRulesForSnappingRect.origin,
                  filterRulesForSnappingRect.size,transformationDirectionHint.height,0);
  }
  return;
}

*/
- (void)filterRulesForSnappingRect:(NSRect)aRect edges:(NSInteger)aEdges transformationDirectionHint:(NSSize)aHint
{
    if ([_xAxisRules count] < 2) {
        if (![[_xAxisRules lastObject] canSnapTo]) {
            [_xAxisRules removeAllObjects];
        }
    } else {
        [self filterRules:_xAxisRules alongSameAxis:0 forRect:aRect transformationDirectionHint:aHint.width otherAxisRules:([_xAxisRules count] <= [_yAxisRules count]) ? _yAxisRules : nil];
    }
    if ([_yAxisRules count] < 2) {
        if (![[_yAxisRules lastObject] canSnapTo]) {
            [_yAxisRules removeAllObjects];
        }
    } else {
        [self filterRules:_yAxisRules alongSameAxis:1 forRect:aRect transformationDirectionHint:aHint.height otherAxisRules:([_xAxisRules count] >= [_yAxisRules count]) ? _xAxisRules : nil];
    }
    if (sRuleBuckets == nil) {
        NSMutableArray *buckets[8];
        for (int i = 0; i < 8; i++) {
            buckets[i] = [NSMutableArray array];
        }
        sRuleBuckets = [[NSArray alloc] initWithObjects:buckets count:8];
    } else {
        NSUInteger count = [sRuleBuckets count];
        for (NSUInteger i = 0; i < count; i++) {
            [[sRuleBuckets objectAtIndex:i] removeAllObjects];
        }
    }
    HSLayoutGuidingFillBuckets(_xAxisRules, sRuleBuckets);
    HSLayoutGuidingFillBuckets(_yAxisRules, sRuleBuckets);
    for (NSUInteger side = 0; side != 8; side++) {
        NSMutableArray *bucket = [sRuleBuckets objectAtIndex:side];
        while ([bucket count] > 1) {
            id first = [bucket objectAtIndex:0];
            id second = [bucket objectAtIndex:1];
            id winner = [self prioritizeByTypeRule:first vsRule:second];
            [bucket removeObjectAtIndex:(winner == first) ? 1 : 0];
        }
    }
    HSLayoutGuidingCollectBuckets(sRuleBuckets, _xAxisRules, 0);
    HSLayoutGuidingCollectBuckets(sRuleBuckets, _yAxisRules, 1);
    if ([_xAxisRules count] > 1) {
        [self filterRules:_xAxisRules alongSameAxis:0 forRect:aRect transformationDirectionHint:aHint.width otherAxisRules:nil];
    }
    if ([_yAxisRules count] > 1) {
        [self filterRules:_yAxisRules alongSameAxis:1 forRect:aRect transformationDirectionHint:aHint.height otherAxisRules:nil];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00046525 @ 00046525, 1151 bytes * /

void FUN_00046525(HSLayoutGuidingProcessor *self,SEL _cmd,id filterRules,int alongSameAxis,
                 NSRect forRect,float transformationDirectionHint,id otherAxisRules)

{
  bool bVar1;
  bool bVar2;
  bool bVar3;
  char *pcVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  id pvVar8;
  id pvVar9;
  char *pcVar10;
  float fVar11;
  float fVar12;
  double dVar13;
  char *pcVar14;
  undefined4 uVar15;
  NSPoint NVar16;
  NSSize NVar17;
  int iVar18;
  float local_24;
  char *local_20;
  char local_15;
  float local_14;
  
  pcVar4 = _objc_msgSend(filterRules,sel_count);
  pvVar5 = _objc_msgSend(cls_NSMutableData,sel_alloc);
  pcVar14 = (char *)((int)pcVar4 * 4);
  pvVar5 = _objc_msgSend(pvVar5,sel_initWithLength_,pcVar14);
  pvVar6 = _objc_msgSend(pvVar5,sel_mutableBytes);
  dVar13 = _objc_msgSend_fpret(self,sel_snapDelta);
  local_24 = ABS((float)dVar13);
  fVar11 = local_24;
  if ((local_24 == 0.0) && (!NAN(local_24))) {
    fVar11 = 1.0;
  }
  fVar12 = 0.0005;
  if (1.0 <= fVar11) {
    fVar12 = fVar11 * 0.0005;
  }
  local_24 = local_24 + fVar12;
  local_14 = 0.0;
  if (pcVar4 == (char *)0x0) {
    bVar2 = false;
    bVar3 = false;
    bVar1 = false;
  }
  else {
    pcVar10 = (char *)0x0;
    bVar2 = false;
    bVar3 = false;
    bVar1 = false;
    do {
      pvVar7 = _objc_msgSend(filterRules,sel_objectAtIndex_,pcVar10);
      uVar15 = 0;
      pvVar9 = pvVar7;
      NVar16 = forRect.origin;
      NVar17 = forRect.size;
      iVar18 = alongSameAxis;
      _objc_msgSend(self,sel_calculateClosestDelta_rectSide_forRule_fromRect_alongAxis_,&local_14,0,
                    pvVar7,forRect.origin,forRect.size,alongSameAxis);
      fVar11 = local_14;
      pvVar8 = _objc_msgSend(pvVar7,sel_affectsRectSide_,6);
      fVar11 = ABS(fVar11);
      if ((char)pvVar8 == '\0') {
        pcVar14 = (char *)0x7;
        pvVar8 = _objc_msgSend(pvVar7,sel_affectsRectSide_,7,uVar15,pvVar9,NVar16,NVar17,iVar18);
        if ((char)pvVar8 != '\0') goto LAB_000466ec;
      }
      else {
LAB_000466ec:
        local_15 = '\0';
        pcVar14 = &local_15;
        pvVar8 = _objc_msgSend(pvVar7,sel_scalesRectWithPositiveDirection_,pcVar14,uVar15,pvVar9,
                               NVar16,NVar17,iVar18);
        if (((char)pvVar8 != '\0') && (local_15 == '\0')) {
          local_14 = -local_14;
        }
      }
      if (!bVar2) {
        if (0.0005 < ABS(fVar11)) {
          pvVar9 = _objc_msgSend(pvVar7,sel_canSnapTo,pcVar14,uVar15,pvVar9,NVar16,NVar17,iVar18);
          if ((char)pvVar9 != '\0') {
            if ((!bVar3 && !bVar1) || (0.0005 < ABS(fVar11 - local_24))) {
              if ((fVar11 < local_24) || (!bVar3 && !bVar1)) {
                bVar1 = 0.0 <= local_14;
                bVar3 = !bVar1;
                local_24 = fVar11;
              }
            }
            else if (0.0 <= local_14) {
              bVar1 = true;
            }
            else {
              bVar3 = true;
            }
          }
        }
        else {
          bVar2 = true;
          local_24 = 0.0;
        }
      }
      *(float *)((int)pvVar6 + (int)pcVar10 * 4) = local_14;
      pcVar10 = pcVar10 + 1;
    } while (pcVar10 < pcVar4);
  }
  if ((!bVar3 && !bVar1) && !bVar2) {
    _objc_msgSend(filterRules,sel_removeAllObjects,pcVar14);
    goto LAB_00046977;
  }
  if ((bVar3) && (bVar1)) {
    if ((transformationDirectionHint != 0.0) || (NAN(transformationDirectionHint))) {
      fVar11 = ABS(transformationDirectionHint);
    }
    else {
      fVar11 = 1.0;
    }
    fVar12 = 0.0005;
    if (1.0 <= fVar11) {
      fVar12 = fVar11 * 0.0005;
    }
    if (transformationDirectionHint < 0.0 - fVar12) {
LAB_0004686b:
      local_24 = -local_24;
    }
  }
  else if (bVar3) goto LAB_0004686b;
  if (pcVar4 != (char *)0x0) {
    local_20 = (char *)0x0;
    pcVar10 = pcVar4;
    do {
      pcVar10 = pcVar10 + -1;
      if (0.0005 < ABS(*(float *)((int)pvVar6 + (int)pcVar10 * 4) - local_24)) {
        pvVar9 = _objc_msgSend(filterRules,sel_objectAtIndex_,pcVar10);
        pvVar7 = _objc_msgSend(pvVar9,sel_appliesToAxis_,(uint)(alongSameAxis == 0));
        if (((char)pvVar7 != '\0') &&
           (pvVar9 = _objc_msgSend(otherAxisRules,sel_indexOfObject_,pvVar9),
           pvVar9 != (id)0x7fffffff)) {
          _objc_msgSend(otherAxisRules,sel_removeObjectAtIndex_,pvVar9);
        }
        pcVar14 = pcVar10;
        _objc_msgSend(filterRules,sel_removeObjectAtIndex_,pcVar10);
      }
      local_20 = local_20 + 1;
    } while (local_20 < pcVar4);
  }
LAB_00046977:
  _objc_msgSend(pvVar5,sel_release,pcVar14);
  return;
}

*/
- (void)filterRules:(id)aRules alongSameAxis:(NSInteger)aAxis forRect:(NSRect)aRect transformationDirectionHint:(CGFloat)aHint otherAxisRules:(id)aRules2
{
    NSUInteger count = [aRules count];
    NSMutableData *deltaData = [[NSMutableData alloc] initWithLength:count * sizeof(float)];
    float *deltas = [deltaData mutableBytes];
    float snapDelta = fabsf([self snapDelta]);
    float snapScale = snapDelta;
    if (snapDelta == 0.0f) {
        snapScale = 1.0f;
    }
    float tolerance = 0.0005f;
    if (1.0f <= snapScale) {
        tolerance = snapScale * 0.0005f;
    }
    float best = snapDelta + tolerance;
    float delta = 0.0f;
    BOOL foundZero = NO;
    BOOL foundNegative = NO;
    BOOL foundPositive = NO;
    for (NSUInteger index = 0; index < count; index++) {
        id rule = [aRules objectAtIndex:index];
        [self calculateClosestDelta:&delta rectSide:NULL forRule:rule fromRect:aRect alongAxis:aAxis];
        float absDelta = fabsf(delta);
        if ([rule affectsRectSide:6] || [rule affectsRectSide:7]) {
            BOOL positive = NO;
            if ([rule scalesRectWithPositiveDirection:&positive] && !positive) {
                delta = -delta;
            }
        }
        if (!foundZero) {
            if (0.0005 < fabsf(absDelta)) {
                if ([rule canSnapTo]) {
                    if ((!foundNegative && !foundPositive) || 0.0005 < fabsf(absDelta - best)) {
                        if (absDelta < best || (!foundNegative && !foundPositive)) {
                            foundPositive = (0.0f <= delta);
                            foundNegative = !foundPositive;
                            best = absDelta;
                        }
                    } else if (0.0f <= delta) {
                        foundPositive = YES;
                    } else {
                        foundNegative = YES;
                    }
                }
            } else {
                foundZero = YES;
                best = 0.0f;
            }
        }
        deltas[index] = delta;
    }
    if (!foundNegative && !foundPositive && !foundZero) {
        [aRules removeAllObjects];
        [deltaData release];
        return;
    }
    if (foundNegative && foundPositive) {
        float hintScale = (aHint != 0.0f) ? fabsf(aHint) : 1.0f;
        float hintTolerance = 0.0005f;
        if (1.0f <= hintScale) {
            hintTolerance = hintScale * 0.0005f;
        }
        if (aHint < 0.0f - hintTolerance) {
            best = -best;
        }
    } else if (foundNegative) {
        best = -best;
    }
    for (NSUInteger index = count; index > 0; ) {
        index--;
        if (0.0005 < fabsf(deltas[index] - best)) {
            id rule = [aRules objectAtIndex:index];
            if ([rule appliesToAxis:(aAxis == 0)]) {
                NSUInteger otherIndex = [aRules2 indexOfObject:rule];
                if (otherIndex != NSNotFound) {
                    [aRules2 removeObjectAtIndex:otherIndex];
                }
            }
            [aRules removeObjectAtIndex:index];
        }
    }
    [deltaData release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000469a4 @ 000469a4, 501 bytes * /

void FUN_000469a4(HSLayoutGuidingProcessor *self,SEL _cmd,float *calculateClosestDelta,int *rectSide
                 ,id forRule,NSRect fromRect,int alongAxis)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  float fVar4;
  float fVar5;
  float fVar6;
  float fVar7;
  float fVar8;
  double dVar9;
  id local_28;
  float local_1c;
  
  pvVar1 = _objc_msgSend(forRule,sel_countOfAffectedRectSidesAlongAxis_,alongAxis);
  if (pvVar1 == (id)0x0) {
    fVar5 = 0.0;
    pvVar3 = (id)0x0;
  }
  else {
    pvVar2 = (id)0x0;
    local_28 = (id)0x0;
    local_1c = 0.0;
    fVar4 = 0.0;
    do {
      pvVar3 = _objc_msgSend(forRule,sel_affectedRectSideAtIndex_alongAxis_,pvVar2,alongAxis);
      dVar9 = _objc_msgSend_fpret(forRule,sel_layoutRuleFloatValueForRectSide_,pvVar3);
      switch(pvVar3) {
      case (id)0x0:
        fVar5 = fromRect.origin.x;
        break;
      case (id)0x1:
        fVar5 = fromRect.origin.y;
        break;
      case (id)0x2:
        fVar5 = fromRect.origin.x + fromRect.size.width;
        break;
      case (id)0x3:
        fVar5 = fromRect.origin.y + fromRect.size.height;
        break;
      case (id)0x4:
        fVar5 = fromRect.size.width * 0.5 + fromRect.origin.x;
        break;
      case (id)0x5:
        fVar5 = fromRect.size.height * 0.5 + fromRect.origin.y;
        break;
      case (id)0x6:
        fVar5 = fromRect.size.width;
        break;
      case (id)0x7:
        fVar5 = fromRect.size.height;
        break;
      default:
        fVar5 = 0.0;
      }
      fVar5 = (float)dVar9 - fVar5;
      fVar6 = ABS(fVar5);
      if (pvVar2 != (id)0x0) {
        if ((fVar6 != 0.0) || (NAN(fVar6))) {
          fVar7 = ABS(fVar6);
        }
        else {
          fVar7 = 1.0;
        }
        fVar8 = local_1c;
        if ((local_1c == 0.0) && (!NAN(local_1c))) {
          fVar8 = 1.0;
        }
        if (fVar8 <= fVar7) {
          fVar8 = fVar7;
        }
        if (fVar8 * -0.0005 + local_1c <= fVar6) {
          pvVar3 = local_28;
          fVar6 = local_1c;
          fVar5 = fVar4;
        }
      }
      pvVar2 = (id)((int)pvVar2 + 1);
      fVar4 = fVar5;
      local_28 = pvVar3;
      local_1c = fVar6;
    } while (pvVar2 < pvVar1);
  }
  if (calculateClosestDelta != (float *)0x0) {
    *calculateClosestDelta = fVar5;
  }
  if (rectSide != (int *)0x0) {
    *rectSide = (int)pvVar3;
  }
  return;
}

*/
- (void)calculateClosestDelta:(float *)aDelta rectSide:(int *)aSide forRule:(id)aRule fromRect:(NSRect)aRect alongAxis:(NSInteger)aAxis
{
    NSUInteger count = [aRule countOfAffectedRectSidesAlongAxis:aAxis];
    float delta = 0.0f;
    NSInteger side = 0;
    if (count != 0) {
        NSInteger savedSide = 0;
        float savedAbs = 0.0f;
        float savedDelta = 0.0f;
        for (NSUInteger index = 0; index < count; index++) {
            side = [aRule affectedRectSideAtIndex:index alongAxis:aAxis];
            float value = [aRule layoutRuleFloatValueForRectSide:side];
            delta = value - HSLayoutGuidingSideCoordinate(aRect, side);
            float absDelta = fabsf(delta);
            if (index != 0) {
                float currentScale = (absDelta != 0.0f) ? fabsf(absDelta) : 1.0f;
                float savedScale = (savedAbs != 0.0f) ? savedAbs : 1.0f;
                float scale = (savedScale <= currentScale) ? currentScale : savedScale;
                if (scale * -0.0005 + savedAbs <= absDelta) {
                    side = savedSide;
                    absDelta = savedAbs;
                    delta = savedDelta;
                }
            }
            savedDelta = delta;
            savedSide = side;
            savedAbs = absDelta;
        }
    }
    if (aDelta != NULL) {
        *aDelta = delta;
    }
    if (aSide != NULL) {
        *aSide = (int)side;
    }
}

- (void)setSnapDelta:(CGFloat)aDelta
{
    _snapDelta = aDelta;
}

- (CGFloat)snapDelta
{
    return _snapDelta;
}

- (id)prioritizeByTypeRule:(id)aRule vsRule:(id)aRule2
{
    NSInteger pvVar1;

    pvVar1 = [aRule2 ruleType];
    if ([aRule ruleType] < pvVar1) {
        aRule = aRule2;
    }
    return aRule;
}

- (BOOL)shouldUseSnapper:(id)aSnapper
{
    BOOL pvVar1;
    unsigned int uVar2;

    uVar2 = 0;
    while( YES ) {
        if (3 < uVar2) {
            return NO;
        }
        pvVar1 = [self areLayoutRulesEnabledForType:uVar2];
        if ((pvVar1) && (pvVar1 = [aSnapper supportsRulesOfType:uVar2], pvVar1)) break;
        uVar2 = uVar2 + 1;
    }
    return YES;
}

- (void)dealloc
{
    [_xAxisRules release];
    [_yAxisRules release];
    [_snappers release];
    [super dealloc];
}

- (id)init
{
    id pvVar2_3;
    id pvVar3_2;
    id pvVar4_2;

    self = [super init];
    if (self != nil) {
        _xAxisRules = [NSMutableArray new];
        _yAxisRules = [NSMutableArray new];
        pvVar2_3 = [NSArray alloc];
        pvVar3_2 = [[HSLayoutGridSnapper new] autorelease];
        pvVar4_2 = [[HSLayoutObjectsSnapper new] autorelease];
        _snappers = [pvVar2_3 initWithObjects:[[HSLayoutGuideSnapper new] autorelease], pvVar4_2, pvVar3_2, nil];
        _snapDelta = 1.5;
    }
    return self;
}

@end

