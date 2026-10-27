#import "HSLayoutGuidingTrackerHelper.h"

@implementation HSLayoutGuidingTrackerHelper

/* i386 ivar offsets: _hostView=0x4, _card=0x8, _layoutGuidingRulesRenderer=0xc, _layoutGuidingProcessor=0x10, _appliedRules=0x14, _rectRulesApplyTo=0x18, _isSnapToObjectsEnabled=0x28, _gridSnapDelta=0x2c, _gridSnapDeltaIsSet=0x30 */

+ (id)helperWithHostView:(id)aView
{
    return [[[self alloc] initWithHostView:aView] autorelease];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a037a @ 000a037a, 311 bytes * /

id FUN_000a037a(HSLayoutGuidingTrackerHelper *self,SEL _cmd,id filterSnapRules,NSRect madeForRect,
               NSPoint byMoveDirection)

{
  id self_00;
  id self_01;
  id pvVar1;
  id pvVar2;
  float extraout_EDX;
  NSPoint NVar3;
  NSSize NVar4;
  
  self_00 = _objc_msgSend(cls_NSMutableArray,sel_array);
  self_01 = _objc_msgSend(filterSnapRules,sel_objectEnumerator);
  pvVar1 = _objc_msgSend(self_01,sel_nextObject);
  while (pvVar1 != (id)0x0) {
    NVar3 = madeForRect.origin;
    NVar4 = madeForRect.size;
    pvVar2 = _objc_msgSend(pvVar1,sel_directionSnapsRectTo_,madeForRect.origin,madeForRect.size);
    if ((0.0 < (float)pvVar2 * byMoveDirection.x) ||
       (NVar3 = madeForRect.origin, NVar4 = madeForRect.size,
       _objc_msgSend(pvVar1,sel_directionSnapsRectTo_,madeForRect.origin,madeForRect.size),
       0.0 < extraout_EDX * byMoveDirection.y)) {
      NVar3.x = (float)pvVar1;
      _objc_msgSend(self_00,sel_addObject_,pvVar1,NVar3.y,NVar4);
    }
    pvVar1 = _objc_msgSend(self_01,sel_nextObject,NVar3,NVar4);
  }
  pvVar1 = _objc_msgSend(self_00,sel_count);
  if (pvVar1 == (id)0x0) {
    self_00 = (id)0x0;
  }
  return self_00;
}

*/
- (id)filterSnapRules:(id)aRules madeForRect:(NSRect)aRect byMoveDirection:(NSPoint)aDirection
{
    NSMutableArray *filtered = [NSMutableArray array];
    NSEnumerator *enumerator = [aRules objectEnumerator];
    id rule;
    while ((rule = [enumerator nextObject]) != nil) {
        NSPoint direction = [rule directionSnapsRectTo:aRect];
        if (direction.x * aDirection.x > 0.0f || direction.y * aDirection.y > 0.0f) {
            [filtered addObject:rule];
        }
    }
    return [filtered count] != 0 ? filtered : nil;
}

- (void)setGridSnapDelta:(CGFloat)aDelta
{
    double dVar1;

    _gridSnapDeltaIsSet = YES;
    _gridSnapDelta = aDelta;
    dVar1 = [self commonSnapDelta];
    if (aDelta <= (float)dVar1) {
        aDelta = (float)dVar1;
    }
    [self setCommonSnapDelta:aDelta];
}

- (CGFloat)gridSnapDelta
{
    return (float)[self commonSnapDelta];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a0534 @ 000a0534, 100 bytes * /

void FUN_000a0534(HSLayoutGuidingTrackerHelper *self,SEL _cmd,float setCommonSnapDelta)

{
  id self_00;
  float local_c;
  
  local_c = setCommonSnapDelta;
  if ((self->_gridSnapDeltaIsSet != '\0') &&
     (local_c = setCommonSnapDelta, setCommonSnapDelta <= self->_gridSnapDelta)) {
    local_c = self->_gridSnapDelta;
  }
  self_00 = _objc_msgSend(self,sel_layoutGuidingProcessor);
  _objc_msgSend(self_00,sel_setSnapDelta_,local_c);
  return;
}

*/
- (void)setCommonSnapDelta:(CGFloat)aDelta
{
    float delta = aDelta;
    if (_gridSnapDeltaIsSet && delta <= _gridSnapDelta) {
        delta = _gridSnapDelta;
    }
    [[self layoutGuidingProcessor] setSnapDelta:delta];
}

- (CGFloat)commonSnapDelta
{
    return (float)[[self layoutGuidingProcessor] snapDelta];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a05d2 @ 000a05d2, 61 bytes * /

void FUN_000a05d2(HSLayoutGuidingTrackerHelper *self,SEL _cmd)

{
  id self_00;
  
  self_00 = _objc_msgSend(cls_HSInfoTag,sel_sharedInstance);
  _objc_msgSend(self_00,sel_hide);
  return;
}

*/
- (void)hideInfoTag
{
    [[HSInfoTag sharedInstance] hide];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a060f @ 000a060f, 164 bytes * /

void FUN_000a060f(HSLayoutGuidingTrackerHelper *self,SEL _cmd,float showInfoTagWithCoordinate,
                 BOOL horizontal)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  undefined4 extraout_EDX;
  cfstringStruct *pcVar3;
  
  self_00 = _objc_msgSend(cls_HSInfoTag,sel_sharedInstance);
  pcVar3 = &cfstr_y____2f;
  if (horizontal == '\0') {
    pcVar3 = &cfstr_x____2f;
  }
  pvVar1 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,pcVar3,(double)showInfoTagWithCoordinate
                        );
  pvVar2 = _objc_msgSend(self,sel_topLeftForInfoTag);
  _objc_msgSend(self_00,sel_showWithTopLeft_title_,pvVar2,extraout_EDX,pvVar1);
  return;
}

*/
- (void)showInfoTagWithCoordinate:(CGFloat)aCoordinate horizontal:(BOOL)aHorizontal
{
    HSInfoTag *tag = [HSInfoTag sharedInstance];
    NSString *title = [NSString stringWithFormat:aHorizontal ? @"y: %.2f" : @"x: %.2f", (double)aCoordinate];
    [tag showWithTopLeft:[self topLeftForInfoTag] title:title];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a06b3 @ 000a06b3, 158 bytes * /

void FUN_000a06b3(HSLayoutGuidingTrackerHelper *self,SEL _cmd,NSPoint showInfoTagWithPoint)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  undefined4 extraout_EDX;
  
  self_00 = _objc_msgSend(cls_HSInfoTag,sel_sharedInstance);
  pvVar1 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr_x____2f_y____2f,
                         (double)showInfoTagWithPoint.x,(double)showInfoTagWithPoint.y);
  pvVar2 = _objc_msgSend(self,sel_topLeftForInfoTag);
  _objc_msgSend(self_00,sel_showWithTopLeft_title_,pvVar2,extraout_EDX,pvVar1);
  return;
}

*/
- (void)showInfoTagWithPoint:(NSPoint)aPoint
{
    HSInfoTag *tag = [HSInfoTag sharedInstance];
    NSString *title = [NSString stringWithFormat:@"x: %.2f y: %.2f", (double)aPoint.x, (double)aPoint.y];
    [tag showWithTopLeft:[self topLeftForInfoTag] title:title];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a0751 @ 000a0751, 158 bytes * /

void FUN_000a0751(HSLayoutGuidingTrackerHelper *self,SEL _cmd,NSSize showInfoTagWithSize)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  undefined4 extraout_EDX;
  
  self_00 = _objc_msgSend(cls_HSInfoTag,sel_sharedInstance);
  pvVar1 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr_w____2f_h____2f,
                         (double)showInfoTagWithSize.width,(double)showInfoTagWithSize.height);
  pvVar2 = _objc_msgSend(self,sel_topLeftForInfoTag);
  _objc_msgSend(self_00,sel_showWithTopLeft_title_,pvVar2,extraout_EDX,pvVar1);
  return;
}

*/
- (void)showInfoTagWithSize:(NSSize)aSize
{
    HSInfoTag *tag = [HSInfoTag sharedInstance];
    NSString *title = [NSString stringWithFormat:@"w: %.2f h: %.2f", (double)aSize.width, (double)aSize.height];
    [tag showWithTopLeft:[self topLeftForInfoTag] title:title];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a07ef @ 000a07ef, 101 bytes * /

void FUN_000a07ef(HSLayoutGuidingTrackerHelper *self,SEL _cmd,id showInfoTagWithString)

{
  id self_00;
  id pvVar1;
  undefined4 extraout_EDX;
  
  self_00 = _objc_msgSend(cls_HSInfoTag,sel_sharedInstance);
  pvVar1 = _objc_msgSend(self,sel_topLeftForInfoTag);
  _objc_msgSend(self_00,sel_showWithTopLeft_title_,pvVar1,extraout_EDX,showInfoTagWithString);
  return;
}

*/
- (void)showInfoTagWithString:(id)aString
{
    [[HSInfoTag sharedInstance] showWithTopLeft:[self topLeftForInfoTag] title:aString];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a0854 @ 000a0854, 141 bytes * /

ulonglong FUN_000a0854(HSLayoutGuidingTrackerHelper *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  float extraout_EDX;
  float extraout_EDX_00;
  
  pvVar1 = _objc_msgSend(cls_NSEvent,sel_mouseLocation);
  self_00 = _objc_msgSend(cls_HSInfoTag,sel_sharedInstance);
  _objc_msgSend(self_00,sel_size);
  return CONCAT44(extraout_EDX + extraout_EDX_00 + 5.0,(float)pvVar1 + 5.0);
}

*/
- (NSPoint)topLeftForInfoTag
{
    NSPoint location = [NSEvent mouseLocation];
    NSSize size = [[HSInfoTag sharedInstance] size];
    return NSMakePoint(location.x + 5.0f, location.y + size.height + 5.0f);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a08e1 @ 000a08e1, 41 bytes * /

void FUN_000a08e1(HSLayoutGuidingTrackerHelper *self,SEL _cmd)

{
  _objc_msgSend(self->_hostView,sel_cancelAppliedLayoutGuidingRulesClearing);
  return;
}

*/
- (void)cancelAppliedLayoutGuidingRulesClearing
{
    [_hostView cancelAppliedLayoutGuidingRulesClearing];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a090a @ 000a090a, 76 bytes * /

void FUN_000a090a(HSLayoutGuidingTrackerHelper *self,SEL _cmd)

{
  if (self->_layoutGuidingRulesRenderer != (id)0x0) {
    _objc_msgSend(self->_layoutGuidingRulesRenderer,sel_setAppliedLayoutRules_forSnappingRect_,
                  self->_appliedRules,(self->_rectRulesApplyTo).origin,
                  (self->_rectRulesApplyTo).size);
  }
  return;
}

*/
- (void)showAppliedLayoutGuidingRules
{
    if (_layoutGuidingRulesRenderer != nil) {
        [_layoutGuidingRulesRenderer setAppliedLayoutRules:_appliedRules forSnappingRect:_rectRulesApplyTo];
    }
}

- (void)clearAppliedLayoutGuidingRules
{
    float fVar1;

    [_appliedRules release];
    _appliedRules = nil;
    fVar1 = NSZeroRect.origin.y;
    (_rectRulesApplyTo).origin.x = NSZeroRect.origin.x;
    (_rectRulesApplyTo).origin.y = fVar1;
    (_rectRulesApplyTo).size.width = NSZeroRect.size.width;
    (_rectRulesApplyTo).size.height = NSZeroRect.size.height;
}

- (void)setAppliedLayoutGuidingRules:(id)aRules forSnappingRect:(NSRect)aRect
{
    float fVar1;
    float fVar2;
    float fVar4;
    float fVar5;
    float fVar6;
    float fVar7;
    float fVar8;
    float fVar9;
    float fVar10;
    float fVar4_2;
    float fVar8_2;
    float fVar8_3;
    float fVar10_2;
    float fVar10_3;
    float fVar5_2;
    float fVar5_3;
    float fVar9_2;
    float fVar6_2;

    if (_appliedRules != aRules) {
        [_appliedRules release];
        _appliedRules = [aRules retain];
    }
    fVar4 = fabs(aRect.origin.y) + aRect.size.height;
    fVar8 = (_rectRulesApplyTo).origin.y;
    fVar10 = (_rectRulesApplyTo).size.height;
    fVar5 = fabs(fVar8) + fVar10;
    fVar5_2 = fVar5 != 0.0 ? fabs(fVar5) : 1.0;
    fVar7 = fVar4 != 0.0 ? fabs(fVar4) : 1.0;
    fVar9 = fabs(aRect.origin.x) + aRect.size.width;
    fVar1 = (_rectRulesApplyTo).origin.x;
    fVar2 = (_rectRulesApplyTo).size.width;
    fVar6 = fabs(fVar1) + fVar2;
    if (fVar7 <= fVar5_2) {
        fVar7 = fVar5_2;
    }
    fVar6_2 = fVar6 != 0.0 ? fabs(fVar6) : 1.0;
    fVar5_3 = fVar9 != 0.0 ? fabs(fVar9) : 1.0;
    if (fVar5_3 <= fVar6_2) {
        fVar5_3 = fVar6_2;
    }
    if ((((fVar5_3 * 0.0005 < fabs(fVar1 - aRect.origin.x)) || (fVar7 * 0.0005 < fabs(fVar8 - aRect.origin.y))) || (fVar5_3 * 0.0005 < fabs(fVar2 - aRect.size.width))) || (fVar7 * 0.0005 < fabs(fVar10 - aRect.size.height))) {
        fVar8_2 = fabs(NSZeroRect.origin.y) + NSZeroRect.size.height;
        fVar8_3 = fVar8_2 != 0.0 ? fabs(fVar8_2) : 1.0;
        fVar4_2 = fVar4 != 0.0 ? fabs(fVar4) : 1.0;
        fVar10_2 = fabs(NSZeroRect.origin.x) + NSZeroRect.size.width;
        if (fVar4_2 <= fVar8_3) {
            fVar4_2 = fVar8_3;
        }
        fVar10_3 = fVar10_2 != 0.0 ? fabs(fVar10_2) : 1.0;
        fVar9_2 = fVar9 != 0.0 ? fabs(fVar9) : 1.0;
        if (fVar9_2 <= fVar10_3) {
            fVar9_2 = fVar10_3;
        }
        if ((((fVar9_2 * 0.0005 < fabs(NSZeroRect.origin.x - aRect.origin.x)) || (fVar4_2 * 0.0005 < fabs(NSZeroRect.origin.y - aRect.origin.y))) || (fVar9_2 * 0.0005 < fabs(NSZeroRect.size.width - aRect.size.width))) || (fVar4_2 * 0.0005 < fabs(NSZeroRect.size.height - aRect.size.height))) {
            (_rectRulesApplyTo).origin.x = aRect.origin.x;
            (_rectRulesApplyTo).origin.y = aRect.origin.y;
            (_rectRulesApplyTo).size.width = aRect.size.width;
            (_rectRulesApplyTo).size.height = aRect.size.height;
        }
    }
}

- (id)appliedLayoutGuidingRules
{
    return _appliedRules;
}

- (void)setRulesRenderer:(id)aRenderer
{
    if (_layoutGuidingRulesRenderer != aRenderer) {
        [_layoutGuidingRulesRenderer release];
        _layoutGuidingRulesRenderer = [aRenderer retain];
    }
}

- (void)setCard:(id)aCard
{
    if (_card != aCard) {
        [_card release];
        _card = [aCard retain];
    }
}

- (BOOL)isSnapToGridEnabled
{
    return (BOOL)[[[_card stack] gridSettings] isSnapToGridEnabled];
}

- (BOOL)isSnappingEnabled
{
    BOOL bVar2;

    if (![self isSnapToGridEnabled]) {
        bVar2 = _isSnapToObjectsEnabled != NO;
    }
    else {
        bVar2 = YES;
    }
    return bVar2;
}

- (void)setSnapToObjectsEnabled:(BOOL)aEnabled
{
    _isSnapToObjectsEnabled = aEnabled;
}

- (void)setSnapToGridEnabled:(BOOL)aEnabled
{
    [[[_card stack] gridSettings] setIsSnapToGridEnabled:aEnabled];
}

- (id)layoutGuidingProcessor
{
    id pvVar1;
    id pvVar1_3;

    pvVar1 = _layoutGuidingProcessor;
    if (pvVar1 == nil) {
        pvVar1_3 = [[HSLayoutGuidingProcessor alloc] init];
        _layoutGuidingProcessor = pvVar1_3;
        [pvVar1_3 setGeometryHoldersProvider:_card];
        [_layoutGuidingProcessor setLayoutRulesEnabled:[self isSnapToGridEnabled] forType:0];
        [_layoutGuidingProcessor setLayoutRulesEnabled:NO forType:2];
        [_layoutGuidingProcessor setLayoutRulesEnabled:_isSnapToObjectsEnabled forType:1];
        [_layoutGuidingProcessor setLayoutRulesEnabled:_isSnapToObjectsEnabled forType:3];
        pvVar1 = _layoutGuidingProcessor;
    }
    return pvVar1;
}

- (void)dealloc
{
    [_hostView release];
    [_card release];
    [_layoutGuidingRulesRenderer release];
    [_layoutGuidingProcessor release];
    [_appliedRules release];
    [super dealloc];
}

- (id)initWithHostView:(id)aView
{
    self = [super init];
    if (self != nil) {
        _hostView = [aView retain];
    }
    return self;
}

@end

