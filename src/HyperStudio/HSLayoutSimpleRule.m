#import "HSLayoutSimpleRule.h"


static CGFloat HSLayoutSimpleRuleSideCoordinate(NSRect rect, NSInteger side)
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

@implementation HSLayoutSimpleRule

/* i386 ivar offsets: _axisType=0x4, _rectSide=0x8, _layoutRuleFloatValue=0xc, _ruleType=0x10, _snapDisabled=0x14, _scalingMask=0x18 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_0004764f @ 0004764f, 965 bytes * /

ulonglong FUN_0004764f(HSLayoutSimpleRule *self,SEL _cmd,NSRect directionSnapsRectTo)

{
  id pvVar1;
  double dVar2;
  float local_30;
  float local_2c;
  
  pvVar1 = _objc_msgSend(self,sel_rectSide);
  switch(pvVar1) {
  case (id)0x0:
  case (id)0x2:
  case (id)0x4:
    dVar2 = _objc_msgSend_fpret(self,sel_layoutRuleFloatValue);
    local_2c = (float)dVar2;
    switch(pvVar1) {
    case (id)0x0:
switchD_0004796f_caseD_0:
      directionSnapsRectTo.size.height = directionSnapsRectTo.origin.x;
      break;
    case (id)0x1:
switchD_0004796f_caseD_1:
      directionSnapsRectTo.size.height = directionSnapsRectTo.origin.y;
      break;
    case (id)0x2:
switchD_0004796f_caseD_2:
      directionSnapsRectTo.size.height =
           directionSnapsRectTo.origin.x + directionSnapsRectTo.size.width;
      break;
    case (id)0x3:
switchD_0004796f_caseD_3:
      directionSnapsRectTo.size.height =
           directionSnapsRectTo.origin.y + directionSnapsRectTo.size.height;
      break;
    case (id)0x4:
switchD_0004796f_caseD_4:
      directionSnapsRectTo.size.height =
           directionSnapsRectTo.size.width * 0.5 + directionSnapsRectTo.origin.x;
      break;
    case (id)0x5:
switchD_0004796f_caseD_5:
      directionSnapsRectTo.size.height =
           directionSnapsRectTo.size.height * 0.5 + directionSnapsRectTo.origin.y;
      break;
    case (id)0x6:
switchD_0004796f_caseD_6:
      directionSnapsRectTo.size.height = directionSnapsRectTo.size.width;
      break;
    case (id)0x7:
switchD_0004796f_caseD_7:
      break;
    default:
switchD_0004796f_default:
      directionSnapsRectTo.size.height = 0.0;
    }
    local_2c = local_2c - directionSnapsRectTo.size.height;
    local_30 = 0.0;
    break;
  case (id)0x1:
  case (id)0x3:
  case (id)0x5:
    dVar2 = _objc_msgSend_fpret(self,sel_layoutRuleFloatValue);
    local_30 = (float)dVar2;
    switch(pvVar1) {
    case (id)0x0:
switchD_00047819_caseD_0:
      directionSnapsRectTo.size.height = directionSnapsRectTo.origin.x;
      break;
    case (id)0x1:
switchD_00047819_caseD_1:
      directionSnapsRectTo.size.height = directionSnapsRectTo.origin.y;
      break;
    case (id)0x2:
switchD_00047819_caseD_2:
      directionSnapsRectTo.size.height =
           directionSnapsRectTo.origin.x + directionSnapsRectTo.size.width;
      break;
    case (id)0x3:
switchD_00047819_caseD_3:
      directionSnapsRectTo.size.height =
           directionSnapsRectTo.origin.y + directionSnapsRectTo.size.height;
      break;
    case (id)0x4:
switchD_00047819_caseD_4:
      directionSnapsRectTo.size.height =
           directionSnapsRectTo.size.width * 0.5 + directionSnapsRectTo.origin.x;
      break;
    case (id)0x5:
switchD_00047819_caseD_5:
      directionSnapsRectTo.size.height =
           directionSnapsRectTo.size.height * 0.5 + directionSnapsRectTo.origin.y;
      break;
    case (id)0x6:
switchD_00047819_caseD_6:
      directionSnapsRectTo.size.height = directionSnapsRectTo.size.width;
      break;
    case (id)0x7:
switchD_00047819_caseD_7:
      break;
    default:
switchD_00047819_default:
      directionSnapsRectTo.size.height = 0.0;
    }
    local_30 = local_30 - directionSnapsRectTo.size.height;
    local_2c = 0.0;
    break;
  case (id)0x6:
    if ((self->_scalingMask & 1) != 0) {
      switch(pvVar1) {
      case (id)0x0:
        directionSnapsRectTo.size.height = directionSnapsRectTo.origin.x;
        break;
      case (id)0x1:
        directionSnapsRectTo.size.height = directionSnapsRectTo.origin.y;
        break;
      case (id)0x2:
        directionSnapsRectTo.size.height =
             directionSnapsRectTo.origin.x + directionSnapsRectTo.size.width;
        break;
      case (id)0x3:
        directionSnapsRectTo.size.height =
             directionSnapsRectTo.origin.y + directionSnapsRectTo.size.height;
        break;
      case (id)0x4:
        directionSnapsRectTo.size.height =
             directionSnapsRectTo.size.width * 0.5 + directionSnapsRectTo.origin.x;
        break;
      case (id)0x5:
        directionSnapsRectTo.size.height =
             directionSnapsRectTo.size.height * 0.5 + directionSnapsRectTo.origin.y;
        break;
      case (id)0x6:
        directionSnapsRectTo.size.height = directionSnapsRectTo.size.width;
        break;
      case (id)0x7:
        break;
      default:
        directionSnapsRectTo.size.height = 0.0;
      }
      dVar2 = _objc_msgSend_fpret(self,sel_layoutRuleFloatValue);
      local_2c = directionSnapsRectTo.size.height - (float)dVar2;
      local_30 = 0.0;
      break;
    }
    dVar2 = _objc_msgSend_fpret(self,sel_layoutRuleFloatValue);
    local_2c = (float)dVar2;
    switch(pvVar1) {
    case (id)0x0:
      goto switchD_0004796f_caseD_0;
    case (id)0x1:
      goto switchD_0004796f_caseD_1;
    case (id)0x2:
      goto switchD_0004796f_caseD_2;
    case (id)0x3:
      goto switchD_0004796f_caseD_3;
    case (id)0x4:
      goto switchD_0004796f_caseD_4;
    case (id)0x5:
      goto switchD_0004796f_caseD_5;
    case (id)0x6:
      goto switchD_0004796f_caseD_6;
    case (id)0x7:
      goto switchD_0004796f_caseD_7;
    default:
      goto switchD_0004796f_default;
    }
  case (id)0x7:
    if ((self->_scalingMask & 2) != 0) {
      switch(pvVar1) {
      case (id)0x0:
        directionSnapsRectTo.size.height = directionSnapsRectTo.origin.x;
        break;
      case (id)0x1:
        directionSnapsRectTo.size.height = directionSnapsRectTo.origin.y;
        break;
      case (id)0x2:
        directionSnapsRectTo.size.height =
             directionSnapsRectTo.origin.x + directionSnapsRectTo.size.width;
        break;
      case (id)0x3:
        directionSnapsRectTo.size.height =
             directionSnapsRectTo.origin.y + directionSnapsRectTo.size.height;
        break;
      case (id)0x4:
        directionSnapsRectTo.size.height =
             directionSnapsRectTo.size.width * 0.5 + directionSnapsRectTo.origin.x;
        break;
      case (id)0x5:
        directionSnapsRectTo.size.height =
             directionSnapsRectTo.size.height * 0.5 + directionSnapsRectTo.origin.y;
        break;
      case (id)0x6:
        directionSnapsRectTo.size.height = directionSnapsRectTo.size.width;
        break;
      case (id)0x7:
        break;
      default:
        directionSnapsRectTo.size.height = 0.0;
      }
      dVar2 = _objc_msgSend_fpret(self,sel_layoutRuleFloatValue);
      local_30 = directionSnapsRectTo.size.height - (float)dVar2;
      local_2c = 0.0;
      break;
    }
    dVar2 = _objc_msgSend_fpret(self,sel_layoutRuleFloatValue);
    local_30 = (float)dVar2;
    switch(pvVar1) {
    case (id)0x0:
      goto switchD_00047819_caseD_0;
    case (id)0x1:
      goto switchD_00047819_caseD_1;
    case (id)0x2:
      goto switchD_00047819_caseD_2;
    case (id)0x3:
      goto switchD_00047819_caseD_3;
    case (id)0x4:
      goto switchD_00047819_caseD_4;
    case (id)0x5:
      goto switchD_00047819_caseD_5;
    case (id)0x6:
      goto switchD_00047819_caseD_6;
    case (id)0x7:
      goto switchD_00047819_caseD_7;
    default:
      goto switchD_00047819_default;
    }
  default:
    local_2c = *(float *)PTR_00336074;
    local_30 = *(float *)(PTR_00336074 + 4);
  }
  return CONCAT44(local_30,local_2c);
}

*/
- (NSPoint)directionSnapsRectTo:(NSRect)aTo
{
    float x;
    float y;
    NSInteger side = [self rectSide];

    switch (side) {
    case 0:
    case 2:
    case 4:
        x = [self layoutRuleFloatValue] - HSLayoutSimpleRuleSideCoordinate(aTo, side);
        y = 0.0f;
        break;
    case 1:
    case 3:
    case 5:
        y = [self layoutRuleFloatValue] - HSLayoutSimpleRuleSideCoordinate(aTo, side);
        x = 0.0f;
        break;
    case 6:
        if ((_scalingMask & 1) != 0) {
            x = HSLayoutSimpleRuleSideCoordinate(aTo, side) - [self layoutRuleFloatValue];
        } else {
            x = [self layoutRuleFloatValue] - HSLayoutSimpleRuleSideCoordinate(aTo, side);
        }
        y = 0.0f;
        break;
    case 7:
        if ((_scalingMask & 2) != 0) {
            y = HSLayoutSimpleRuleSideCoordinate(aTo, side) - [self layoutRuleFloatValue];
        } else {
            y = [self layoutRuleFloatValue] - HSLayoutSimpleRuleSideCoordinate(aTo, side);
        }
        x = 0.0f;
        break;
    default:
        return NSZeroPoint;
    }
    return NSMakePoint(x, y);
    return (NSPoint){0};
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00047461 @ 00047461, 374 bytes * /

NSRect * FUN_00047461(NSRect *__return_storage_ptr__,HSLayoutSimpleRule *self,SEL _cmd,
                     NSRect scaleRect)

{
  float fVar1;
  float fVar2;
  float fVar3;
  
  fVar2 = scaleRect.size.height;
  fVar1 = scaleRect.size.width;
  switch(self->_rectSide) {
  case 0:
    fVar1 = self->_layoutRuleFloatValue - scaleRect.origin.x;
    scaleRect.origin.x = scaleRect.origin.x + fVar1;
    fVar1 = scaleRect.size.width - fVar1;
    break;
  case 1:
    fVar2 = self->_layoutRuleFloatValue - scaleRect.origin.y;
    scaleRect.origin.y = scaleRect.origin.y + fVar2;
    fVar2 = scaleRect.size.height - fVar2;
    break;
  case 2:
    fVar1 = scaleRect.size.width +
            (self->_layoutRuleFloatValue - (scaleRect.origin.x + scaleRect.size.width));
    break;
  case 3:
    fVar2 = scaleRect.size.height +
            (self->_layoutRuleFloatValue - (scaleRect.origin.y + scaleRect.size.height));
    break;
  case 4:
    fVar3 = self->_layoutRuleFloatValue - (scaleRect.size.width * 0.5 + scaleRect.origin.x);
    self = (HSLayoutSimpleRule *)self->_scalingMask;
    if (((uint)self & 4) == 0) {
      if (((uint)self & 1) != 0) {
        scaleRect.origin.x = scaleRect.origin.x + fVar3 + fVar3;
        fVar1 = scaleRect.size.width + fVar3 * -2.0;
      }
    }
    else {
      fVar1 = scaleRect.size.width + fVar3 + fVar3;
    }
    break;
  case 5:
    fVar3 = self->_layoutRuleFloatValue - (scaleRect.size.height * 0.5 + scaleRect.origin.y);
    self = (HSLayoutSimpleRule *)self->_scalingMask;
    if (((uint)self & 8) == 0) {
      if (((uint)self & 2) != 0) {
        scaleRect.origin.y = scaleRect.origin.y + fVar3 + fVar3;
        fVar2 = scaleRect.size.height + fVar3 * -2.0;
      }
    }
    else {
      fVar2 = scaleRect.size.height + fVar3 + fVar3;
    }
    break;
  case 6:
    fVar1 = self->_layoutRuleFloatValue;
    if ((self->_scalingMask & 1) != 0) {
      scaleRect.origin.x = (scaleRect.origin.x + scaleRect.size.width) - fVar1;
    }
    break;
  case 7:
    fVar2 = self->_layoutRuleFloatValue;
    if ((self->_scalingMask & 2) != 0) {
      scaleRect.origin.y = (scaleRect.origin.y + scaleRect.size.height) - fVar2;
    }
  }
  (__return_storage_ptr__->origin).x = scaleRect.origin.x;
  (__return_storage_ptr__->origin).y = scaleRect.origin.y;
  (__return_storage_ptr__->size).width = fVar1;
  (__return_storage_ptr__->size).height = fVar2;
  return (NSRect *)self;
}

*/
- (NSRect)scaleRect:(NSRect)aRect
{
    float x = aRect.origin.x;
    float y = aRect.origin.y;
    float width = aRect.size.width;
    float height = aRect.size.height;
    float delta;

    switch (_rectSide) {
    case 0:
        delta = _layoutRuleFloatValue - aRect.origin.x;
        x = aRect.origin.x + delta;
        width = aRect.size.width - delta;
        break;
    case 1:
        delta = _layoutRuleFloatValue - aRect.origin.y;
        y = aRect.origin.y + delta;
        height = aRect.size.height - delta;
        break;
    case 2:
        width = aRect.size.width + (_layoutRuleFloatValue - (aRect.origin.x + aRect.size.width));
        break;
    case 3:
        height = aRect.size.height + (_layoutRuleFloatValue - (aRect.origin.y + aRect.size.height));
        break;
    case 4:
        delta = _layoutRuleFloatValue - (aRect.size.width * 0.5 + aRect.origin.x);
        if ((_scalingMask & 4) != 0) {
            width = aRect.size.width + delta + delta;
        } else if ((_scalingMask & 1) != 0) {
            x = aRect.origin.x + delta + delta;
            width = aRect.size.width + delta * -2.0;
        }
        break;
    case 5:
        delta = _layoutRuleFloatValue - (aRect.size.height * 0.5 + aRect.origin.y);
        if ((_scalingMask & 8) != 0) {
            height = aRect.size.height + delta + delta;
        } else if ((_scalingMask & 2) != 0) {
            y = aRect.origin.y + delta + delta;
            height = aRect.size.height + delta * -2.0;
        }
        break;
    case 6:
        width = _layoutRuleFloatValue;
        if ((_scalingMask & 1) != 0) {
            x = (aRect.origin.x + aRect.size.width) - width;
        }
        break;
    case 7:
        height = _layoutRuleFloatValue;
        if ((_scalingMask & 2) != 0) {
            y = (aRect.origin.y + aRect.size.height) - height;
        }
        break;
    }
    return NSMakeRect(x, y, width, height);
    return (NSRect){0};
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00047af4 @ 00047af4, 53 bytes * /

NSRect * FUN_00047af4(NSRect *__return_storage_ptr__,HSLayoutSimpleRule *self,SEL _cmd,
                     NSRect translateRect)

{
  NSRect *pNVar1;
  
  pNVar1 = (NSRect *)
           FUN_0019893f(__return_storage_ptr__,self,translateRect.origin,translateRect.size);
  return pNVar1;
}

*/
- (NSRect)translateRect:(NSRect)aRect
{
    return HSLayoutRuleTranslateRect(self, aRect);
    return (NSRect){0};
}

- (id)geometryHoldersSortedByOppositeCoordinate
{
    return nil;
}

- (id)geometryHoldersUsed
{
    return nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00047b29 @ 00047b29, 9 bytes * /

uint FUN_00047b29(HSLayoutSimpleRule *self,SEL _cmd)

{
  uint uVar1;
  
  uVar1 = FUN_001988a8();
  return uVar1;
}

*/
- (NSUInteger)hash
{
    return HSLayoutRuleHash(self);
    return 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00047b32 @ 00047b32, 32 bytes * /

BOOL FUN_00047b32(HSLayoutSimpleRule *self,SEL _cmd,id isEqual)

{
  BOOL BVar1;
  
  BVar1 = FUN_00198b95(self,isEqual);
  return BVar1;
}

*/
- (BOOL)isEqual:(id)aEqual
{
    return HSLayoutRuleIsEqual(self, aEqual);
    return 0;
}

- (CGFloat)layoutRuleFloatValue
{
    return _layoutRuleFloatValue;
}

- (CGFloat)layoutRuleFloatValueForRectSide:(NSInteger)aSide
{
    return _layoutRuleFloatValue;
}

- (BOOL)affectsRectSide:(NSInteger)aSide
{
    return _rectSide == aSide;
}

- (NSInteger)affectedRectSideAtIndex:(NSUInteger)aIndex alongAxis:(NSInteger)aAxis
{
    return _rectSide;
}

- (NSUInteger)countOfAffectedRectSidesAlongAxis:(NSInteger)aAxis
{
    return (unsigned int)([self appliesToAxis:aAxis]);
}

- (NSInteger)affectedRectSideAtIndex:(NSUInteger)aIndex
{
    return _rectSide;
}

- (NSUInteger)affectedRectSidesCount
{
    return 1;
}

- (NSInteger)rectSide
{
    return _rectSide;
}

- (NSInteger)axisType
{
    return _axisType;
}

- (BOOL)appliesToAxis:(NSInteger)aAxis
{
    return _axisType == aAxis;
}

- (BOOL)appliesToYAxis
{
    return (BOOL)[self appliesToAxis:1];
}

- (BOOL)appliesToXAxis
{
    return (BOOL)[self appliesToAxis:0];
}

- (BOOL)scalesRectWithPositiveDirection:(BOOL *)aDirection
{
    if (aDirection != nil) {
        *aDirection = _scalingMask & 0xc;
    }
    return _scalingMask != 0;
}

- (void)setScalesBySide:(NSInteger)aSide
{
    _scalingMask = 1 << (aSide & 0x1f);
}

- (void)setCanSnapTo:(BOOL)aTo
{
    _snapDisabled = aTo == NO;
}

- (BOOL)canSnapTo
{
    return _snapDisabled == NO;
}

- (NSInteger)ruleType
{
    return _ruleType;
}

- (id)initWithAxisType:(NSInteger)aType rectSide:(NSInteger)aSide value:(CGFloat)aValue type:(NSInteger)aType2
{
    self = [super init];
    if (self != nil) {
        _axisType = aType;
        _rectSide = aSide;
        _layoutRuleFloatValue = aValue;
        _ruleType = aType2;
    }
    return self;
}

@end

