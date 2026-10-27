#import "HSVectorGraphicsKnobsCanvasLayer.h"

@implementation HSVectorGraphicsKnobsCanvasLayer

/* i386 ivar offsets: _tangentKnobs=0x2c, _visibleTangentKnobs=0x34 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_0009dcf2 @ 0009dcf2, 138 bytes * /

id FUN_0009dcf2(id self,SEL _cmd,id knobsLayerWithHyperObject)

{
  id pvVar1;
  id pvVar2;
  undefined4 *puVar3;
  undefined4 local_14;
  
  local_14 = 0;
  puVar3 = &local_14;
  pvVar2 = knobsLayerWithHyperObject;
  pvVar1 = _objc_msgSend(self,sel_canInitWithHyperObject_knobsProvider_,knobsLayerWithHyperObject,
                         puVar3);
  if ((char)pvVar1 == '\0') {
    pvVar2 = (id)0x0;
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_alloc,pvVar2,puVar3);
    pvVar2 = _objc_msgSend(pvVar2,sel_initWithHyperObject_knobsProvider_,knobsLayerWithHyperObject,
                           local_14);
    pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
  }
  return pvVar2;
}

*/
+ (id)knobsLayerWithHyperObject:(id)aObject
{
    id provider = nil;
    if (![self canInitWithHyperObject:aObject knobsProvider:&provider]) {
        return nil;
    }
    return [[[self alloc] initWithHyperObject:aObject knobsProvider:provider] autorelease];
    return 0;
}

+ (BOOL)canInitWithHyperObject:(id)aObject
{
    return (BOOL)[self canInitWithHyperObject:aObject knobsProvider:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0009ddb4 @ 0009ddb4, 113 bytes * /

BOOL FUN_0009ddb4(id self,SEL _cmd,id canInitWithHyperObject,id *knobsProvider)

{
  BOOL BVar1;
  id pvVar2;
  
  pvVar2 = _objc_msgSend(canInitWithHyperObject,sel_implementsHyperInterface_,&DAT_003684dc);
  if (((char)pvVar2 == '\0') ||
     (pvVar2 = _objc_msgSend(canInitWithHyperObject,sel_queryHyperInterface_,&DAT_003686a8),
     pvVar2 == (id)0x0)) {
    BVar1 = '\0';
  }
  else if (knobsProvider == (id *)0x0) {
    BVar1 = '\x01';
  }
  else {
    *knobsProvider = pvVar2;
    BVar1 = '\x01';
  }
  return BVar1;
}

*/
+ (BOOL)canInitWithHyperObject:(id)aObject knobsProvider:(id *)aProvider
{
    if (![aObject implementsHyperInterface:@protocol(HSMutableVectorGraphicsAttributes)]) {
        return NO;
    }
    id provider = [aObject queryHyperInterface:@protocol(HSVectorGraphicsKnobsProvider)];
    if (provider == nil) {
        return NO;
    }
    if (aProvider != NULL) {
        *aProvider = provider;
    }
    return YES;
    return 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0009de25 @ 0009de25, 499 bytes * /

BOOL FUN_0009de25(HSVectorGraphicsKnobsCanvasLayer *self,SEL _cmd,NSPoint handleMouseDownAtPoint,
                 id event,id hitTestInfo)

{
  BOOL BVar1;
  id pvVar2;
  undefined *puVar3;
  id pvVar4;
  id pvVar5;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  undefined4 extraout_EDX_01;
  undefined *puVar6;
  float fVar7;
  HSVectorGraphicsKnobsCanvasLayer *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSObjectKnobsCanvasLayer_0034eef0;
  fVar7 = handleMouseDownAtPoint.y;
  pvVar4 = event;
  pvVar2 = _objc_msgSendSuper(&local_1c,sel_handleMouseDownAtPoint_event_hitTestInfo_,
                              handleMouseDownAtPoint.x,handleMouseDownAtPoint.y,event,hitTestInfo);
  if ((char)pvVar2 != '\0') {
    return (char)pvVar2;
  }
  _objc_msgSend(self,sel_setActiveItem_,0);
  pvVar2 = _objc_msgSend(self,sel_hyperObject);
  puVar6 = &DAT_00368680;
  puVar3 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_00368680);
  if (puVar3 != (undefined *)0x0) {
    pvVar4 = _objc_msgSend(self,sel_context,puVar6);
    pvVar4 = _objc_msgSend(pvVar4,sel_canvasHitTester);
    pvVar2 = _objc_msgSend(pvVar4,sel_hitTesterForNode_point_,puVar3,handleMouseDownAtPoint.x,
                           handleMouseDownAtPoint.y);
    puVar6 = puVar3;
    fVar7 = handleMouseDownAtPoint.x;
    pvVar4 = (id)handleMouseDownAtPoint.y;
    if (pvVar2 != (id)0x0) goto LAB_0009df5f;
  }
  handleMouseDownAtPoint.y = (float)pvVar4;
  handleMouseDownAtPoint.x = fVar7;
  pvVar4 = _objc_msgSend(self,sel_hyperObject,puVar6,handleMouseDownAtPoint.x,
                         handleMouseDownAtPoint.y);
  puVar3 = &DAT_00368694;
  pvVar2 = _objc_msgSend(pvVar4,sel_queryHyperInterface_,&DAT_00368694);
LAB_0009df5f:
  BVar1 = '\0';
  if (pvVar2 != (id)0x0) {
    pvVar4 = _objc_msgSend(self,sel_renderingView,puVar3,handleMouseDownAtPoint.x,
                           handleMouseDownAtPoint.y);
    pvVar5 = _objc_msgSend(event,sel_locationInWindow);
    pvVar4 = _objc_msgSend(pvVar4,sel_convertPoint_fromView_,pvVar5,extraout_EDX,0);
    pvVar5 = _objc_msgSend(self,sel_renderingView);
    pvVar4 = _objc_msgSend(pvVar5,sel_convertPointFromViewSpaceToUserSpace_,pvVar4,extraout_EDX_00);
    pvVar4 = _objc_msgSend(pvVar2,sel_hitTestUserPoint_,pvVar4,extraout_EDX_01);
    BVar1 = (BOOL)pvVar4;
  }
  return BVar1;
}

*/
- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo
{
    if ([super handleMouseDownAtPoint:aPoint event:aEvent hitTestInfo:aInfo]) {
        return YES;
    }
    [self setActiveItem:nil];
    id node = [[self hyperObject] queryHyperInterface:@protocol(HSNodeAttributes)];
    id hitTester = nil;
    if (node != nil) {
        hitTester = [[[self context] canvasHitTester] hitTesterForNode:node point:aPoint];
    }
    if (hitTester == nil) {
        hitTester = [[self hyperObject] queryHyperInterface:@protocol(HSUserObjectHitTesting)];
    }
    if (hitTester == nil) {
        return NO;
    }
    NSPoint viewPoint = [[self renderingView] convertPoint:[(NSEvent *)aEvent locationInWindow] fromView:nil];
    NSPoint userPoint = [[self renderingView] convertPointFromViewSpaceToUserSpace:viewPoint];
    return [hitTester hitTestUserPoint:userPoint];
    return 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0009e018 @ 0009e018, 165 bytes * /

void FUN_0009e018(HSVectorGraphicsKnobsCanvasLayer *self,SEL _cmd,uint setAssociatedElementIndex,
                 uint forTangentKnobAtIndex)

{
  id pvVar1;
  HSVectorGraphicsKnobsCanvasLayer *pHVar2;
  
  pvVar1 = _objc_msgSend(self->_tangentKnobs[forTangentKnobAtIndex],sel_associatedElementIndex);
  if (pvVar1 != (id)setAssociatedElementIndex) {
    if (self->_visibleTangentKnobs[forTangentKnobAtIndex] != '\0') {
      _objc_msgSend(self,sel_invalidateDisplayForCanvasItem_,
                    self->_tangentKnobs[forTangentKnobAtIndex]);
    }
    pHVar2 = self;
    _objc_msgSend(self->_tangentKnobs[forTangentKnobAtIndex],sel_setAssociatedElementIndex_owner_,
                  setAssociatedElementIndex,self);
    if (self->_visibleTangentKnobs[forTangentKnobAtIndex] != '\0') {
      _objc_msgSend(self,sel_invalidateDisplayForCanvasItem_,
                    self->_tangentKnobs[forTangentKnobAtIndex],pHVar2);
    }
  }
  return;
}

*/
- (void)setAssociatedElementIndex:(NSUInteger)aIndex forTangentKnobAtIndex:(NSUInteger)aIndex2
{
    if ([_tangentKnobs[aIndex2] associatedElementIndex] != aIndex) {
        if (_visibleTangentKnobs[aIndex2]) {
            [self invalidateDisplayForCanvasItem:_tangentKnobs[aIndex2]];
        }
        [_tangentKnobs[aIndex2] setAssociatedElementIndex:aIndex owner:self];
        if (_visibleTangentKnobs[aIndex2]) {
            [self invalidateDisplayForCanvasItem:_tangentKnobs[aIndex2]];
        }
    }
}

- (void)setHidden:(BOOL)aHidden forTangentKnobAtIndex:(NSUInteger)aIndex
{
    BOOL pvVar1;

    if ((BOOL)_visibleTangentKnobs[aIndex] != (aHidden == NO)) {
        if (_visibleTangentKnobs[aIndex] != NO) {
            [self invalidateDisplayForCanvasItem:_tangentKnobs[aIndex]];
        }
        if ((aHidden == NO) && (pvVar1 = [_tangentKnobs[aIndex] isVisible], pvVar1)) {
            _visibleTangentKnobs[aIndex] = YES;
            [self invalidateDisplayForCanvasItem:_tangentKnobs[aIndex]];
            return;
        }
        _visibleTangentKnobs[aIndex] = NO;
    }
}

- (void)didActivateItem:(id)aItem
{
    id pvVar1;
    NSUInteger pvVar1_2;

    [super didActivateItem:aItem];
    pvVar1 = [self pointKnobForCanvasItem:aItem];
    if (pvVar1 != nil) {
        pvVar1_2 = [pvVar1 associatedElementIndex];
        [self setAssociatedElementIndex:pvVar1_2 forTangentKnobAtIndex:0];
        [self setAssociatedElementIndex:pvVar1_2 forTangentKnobAtIndex:1];
        [self setHidden:NO forTangentKnobAtIndex:0];
        [self setHidden:NO forTangentKnobAtIndex:1];
    }
}

- (void)willDeactivateItem:(id)aItem
{
    [self setHidden:YES forTangentKnobAtIndex:0];
    [self setHidden:YES forTangentKnobAtIndex:1];
    [super willDeactivateItem:aItem];
}

- (void)willStartTrackingKnob:(id)aKnob
{
    if (![self isTangentKnob:aKnob]) {
        [self setActiveItem:aKnob];
    }
    [super willStartTrackingKnob:aKnob];
}

- (id)pointKnobForCanvasItem:(id)aItem
{
    if (![aItem isKindOfClass:[HSVectorGraphicsSelectionKnob class]]) {
        aItem = nil;
    }
    return aItem;
}

- (BOOL)isTangentKnob:(id)aKnob
{
    if (_tangentKnobs[0] != aKnob) {
        return _tangentKnobs[1] == aKnob;
    }
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0009e385 @ 0009e385, 109 bytes * /

id FUN_0009e385(HSVectorGraphicsKnobsCanvasLayer *self,SEL _cmd,uint canvasItemAtIndex)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_numberOfVisibleTangentKnobs);
  op = sel_visibleTangentKnobAtIndex_;
  if (pvVar1 <= canvasItemAtIndex) {
    pvVar1 = _objc_msgSend(self,sel_numberOfVisibleTangentKnobs);
    canvasItemAtIndex = canvasItemAtIndex - (int)pvVar1;
    op = sel_knobAtIndex_;
  }
  pvVar1 = _objc_msgSend(self,op,canvasItemAtIndex);
  return pvVar1;
}

*/
- (id)canvasItemAtIndex:(NSUInteger)aIndex
{
    if ([self numberOfVisibleTangentKnobs] <= aIndex) {
        return [self knobAtIndex:aIndex - [self numberOfVisibleTangentKnobs]];
    }
    return [self visibleTangentKnobAtIndex:aIndex];
    return 0;
}

- (NSUInteger)numberOfCanvasItems
{
    NSUInteger pvVar1;

    pvVar1 = [self numberOfVisibleTangentKnobs];
    return (int)[self numberOfKnobs] + (int)pvVar1;
}

- (id)visibleTangentKnobAtIndex:(NSUInteger)aIndex
{
    HSVectorGraphicsTangentSelectionKnob *pHVar1;

    if (_visibleTangentKnobs[0] == NO) {
        if ((aIndex == 0) && (_visibleTangentKnobs[1] != NO)) {
            pHVar1 = _tangentKnobs[1];
        }
        else {
            pHVar1 = nil;
        }
    }
    else {
        pHVar1 = _tangentKnobs[aIndex];
    }
    return pHVar1;
}

- (NSUInteger)numberOfVisibleTangentKnobs
{
    unsigned int uVar1;
    unsigned int uVar2;

    uVar2 = (unsigned int)(_visibleTangentKnobs[0] != NO);
    uVar1 = uVar2 + 1;
    if (_visibleTangentKnobs[1] == NO) {
        uVar1 = uVar2;
    }
    return uVar1;
}

- (id)vectorAttributes
{
    return [[self hyperObject] queryHyperInterface:@protocol(HSMutableVectorGraphicsAttributes)];
}

- (void)dealloc
{
    [_tangentKnobs[0] release];
    [_tangentKnobs[1] release];
    [super dealloc];
}

- (id)init
{
    return [self initWithHyperObject:nil knobsProvider:nil];
}

- (id)initWithHyperObject:(id)aObject knobsProvider:(id)aProvider
{
    HSVectorGraphicsTangentSelectionKnob *pHVar2;
    HSVectorGraphicsKnobsCanvasLayer *local_1c;
    HSVectorGraphicsTangentSelectionKnob *pHVar2_2;

    self = [super init];
    if (self != nil) {
        local_1c = self;
        [super setHyperObject:aObject];
        local_1c = self;
        [super setKnobsProvider:aProvider];
        pHVar2 = [HSVectorGraphicsTangentSelectionKnob new];
        _tangentKnobs[0] = pHVar2;
        [pHVar2 setIsFirstControlPoint:YES];
        pHVar2_2 = [HSVectorGraphicsTangentSelectionKnob new];
        _tangentKnobs[1] = pHVar2_2;
        [pHVar2_2 setIsFirstControlPoint:NO];
    }
    return self;
}

@end

