#import "HSTextShadowAssistantPane.h"

/* FUN_001802d7: a >= b within a relative tolerance of 0.0005 */
static BOOL HSFloatIsApproximatelyGreaterOrEqual(float a, float b)
{
    float scaleA = (a != 0.0f || a != a) ? fabsf(a) : 1.0f;
    float scaleB = (b != 0.0f || b != b) ? fabsf(b) : 1.0f;
    float scale = scaleB > scaleA ? scaleB : scaleA;
    return a >= b + scale * -0.0005f;
}

static BOOL HSFloatIsApproximatelyZero(float value)
{
    float scale = (value != 0.0f || value != value) ? fabsf(value) : 1.0f;
    float tolerance = 1.0f <= scale ? scale * 0.0005f : 0.0005f;
    return fabsf(value) <= tolerance;
}

@implementation HSTextShadowAssistantPane

/* i386 ivar offsets: _offsetSlider=0x68, _offsetTextField=0x6c, _offsetStepper=0x70, _blurSlider=0x74, _blurTextField=0x78, _blurStepper=0x7c, _angleSlider=0x80, _angleTextField=0x84, _angleStepper=0x88, _paneSwitcher=0x8c, _observedTextViewAttributes=0x90, _observedMutableShadowAttributes=0x94, _observedButtonObjectAttributes=0x98 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_00180f67 @ 00180f67, 960 bytes * /

void FUN_00180f67(HSTextShadowAssistantPane *self,SEL _cmd)

{
  char cVar1;
  id pvVar2;
  longdouble lVar3;
  float fVar4;
  float fVar5;
  float fVar6;
  double dVar7;
  double dVar8;
  double dVar9;
  float local_48;
  float local_3c;
  
  pvVar2 = _objc_msgSend(self,sel_applier);
  pvVar2 = _objc_msgSend(pvVar2,sel_shadowAttributes);
  if (pvVar2 != (id)0x0) {
    dVar8 = _objc_msgSend_fpret(pvVar2,sel_hyperShadowDistance);
    fVar6 = (float)dVar8;
    _objc_msgSend(self->_offsetSlider,sel_setFloatValue_,fVar6);
    _objc_msgSend(self->_offsetStepper,sel_setFloatValue_,fVar6);
    _objc_msgSend(self->_offsetTextField,sel_setFloatValue_,fVar6);
    if ((fVar6 != 0.0) || (NAN(fVar6))) {
      fVar4 = ABS(fVar6);
    }
    else {
      fVar4 = 1.0;
    }
    local_48 = 1.0;
    fVar5 = 0.0005;
    if (1.0 <= fVar4) {
      fVar5 = fVar4 * 0.0005;
    }
    if (fVar5 + 0.0 < fVar6) {
      dVar9 = _objc_msgSend_fpret(pvVar2,sel_hyperShadowAngle);
      dVar8 = *(double *)PTR_0033616c;
      dVar7 = dVar8 + dVar8;
      local_3c = (float)(-1.5707963267948966 - dVar9);
      cVar1 = FUN_001802d7();
      if (cVar1 == '\0') {
        if (local_3c < 0.0) {
          lVar3 = (longdouble)_floorf((float)((double)ABS(local_3c) / dVar7));
          local_3c = (float)((double)local_3c + ((double)lVar3 + 1.0) * dVar7);
          cVar1 = FUN_001802d7();
          if (cVar1 != '\0') {
            local_3c = (float)((double)local_3c + dVar8 * -2.0);
          }
        }
      }
      else {
        lVar3 = (longdouble)_floorf((float)((double)local_3c / dVar7));
        local_3c = (float)(dVar8 * -2.0 * (double)lVar3 + (double)local_3c);
      }
      fVar6 = ((6.2831855 - local_3c) / 3.1415927) * 180.0;
      if ((fVar6 != 0.0) || (NAN(fVar6))) {
        local_48 = ABS(fVar6);
      }
      fVar4 = 360.0;
      if (360.0 <= local_48) {
        fVar4 = local_48;
      }
      if (fVar4 * -0.0005 + 360.0 <= fVar6) {
        fVar6 = fVar6 + -360.0;
      }
      for (; 359.5 <= fVar6; fVar6 = fVar6 + -360.0) {
      }
      lVar3 = (longdouble)_roundf(fVar6);
      fVar6 = (float)lVar3;
      _objc_msgSend(self->_angleTextField,sel_setFloatValue_,fVar6);
      _objc_msgSend(self->_angleSlider,sel_setFloatValue_,fVar6);
      _objc_msgSend(self->_angleStepper,sel_setFloatValue_,fVar6);
    }
    dVar8 = _objc_msgSend_fpret(pvVar2,sel_hyperShadowBlurRadius);
    fVar6 = (float)dVar8;
    _objc_msgSend(self->_blurSlider,sel_setFloatValue_,fVar6);
    _objc_msgSend(self->_blurStepper,sel_setFloatValue_,fVar6);
    _objc_msgSend(self->_blurTextField,sel_setFloatValue_,fVar6);
  }
  return;
}

*/
- (void)validateUI
{
    id shadow = [[self applier] shadowAttributes];
    if (shadow != nil) {
        float distance = [shadow hyperShadowDistance];
        [_offsetSlider setFloatValue:distance];
        [_offsetStepper setFloatValue:distance];
        [_offsetTextField setFloatValue:distance];
        if (!HSFloatIsApproximatelyZero(distance) && distance > 0.0f) {
            double twoPiDouble = M_PI + M_PI;
            float twoPi = (float)twoPiDouble;
            float radians = (float)(-1.5707963267948966 - [shadow hyperShadowAngle]);
    if (!HSFloatIsApproximatelyGreaterOrEqual(radians, twoPi)) {
        if (radians < 0.0f) {
            radians = (float)((double)radians + ((double)floorf((float)(fabs(radians) / twoPiDouble)) + 1.0) * twoPiDouble);
            if (HSFloatIsApproximatelyGreaterOrEqual(radians, twoPi)) {
                radians = (float)((double)radians + M_PI * -2.0);
            }
        }
    } else {
        radians = (float)(M_PI * -2.0 * (double)floorf((float)((double)radians / twoPiDouble)) + (double)radians);
    }
            float degrees = ((6.2831855f - radians) / 3.1415927f) * 180.0f;
            float scale = (degrees != 0.0f || degrees != degrees) ? fabsf(degrees) : 1.0f;
            float limit = 360.0f;
            if (360.0f <= scale) {
                limit = scale;
            }
            if (limit * -0.0005f + 360.0f <= degrees) {
                degrees -= 360.0f;
            }
            for (; 359.5f <= degrees; degrees -= 360.0f) {
            }
            degrees = roundf(degrees);
            [_angleTextField setFloatValue:degrees];
            [_angleSlider setFloatValue:degrees];
            [_angleStepper setFloatValue:degrees];
        }
        float blur = [shadow hyperShadowBlurRadius];
        [_blurSlider setFloatValue:blur];
        [_blurStepper setFloatValue:blur];
        [_blurTextField setFloatValue:blur];
    }
}

- (void)validateUIWithNotification:(id)aNotification
{
    [self validateUI];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00181327 @ 00181327, 665 bytes * /

void FUN_00181327(HSTextShadowAssistantPane *self,SEL _cmd,id angleChanged)

{
  char cVar1;
  id pvVar2;
  longdouble lVar3;
  float fVar4;
  double dVar5;
  float fVar6;
  float fVar7;
  double dVar8;
  double dVar9;
  float local_3c;
  
  dVar8 = _objc_msgSend_fpret(angleChanged,sel_floatValue);
  dVar9 = *(double *)PTR_0033616c;
  dVar5 = dVar9 + dVar9;
  fVar6 = (float)dVar5;
  local_3c = (float)((dVar8 * -3.141592653589793) / -180.0 + 6.283185307179586);
  cVar1 = FUN_001802d7();
  if (cVar1 == '\0') {
    if (local_3c < 0.0) {
      lVar3 = (longdouble)_floorf((float)((double)ABS(local_3c) / dVar5));
      local_3c = (float)((double)local_3c + ((double)lVar3 + 1.0) * dVar5);
      cVar1 = FUN_001802d7();
      if (cVar1 != '\0') {
        local_3c = (float)((double)local_3c + dVar9 * -2.0);
      }
    }
  }
  else {
    lVar3 = (longdouble)_floorf((float)((double)local_3c / dVar5));
    local_3c = (float)(dVar9 * -2.0 * (double)lVar3 + (double)local_3c);
  }
  pvVar2 = _objc_msgSend(self,sel_applier);
  _objc_msgSend(pvVar2,sel_setAngle_,local_3c + -1.5707964,fVar6);
  pvVar2 = _objc_msgSend(self,sel_applier);
  pvVar2 = _objc_msgSend(pvVar2,sel_shadowAttributes);
  dVar9 = _objc_msgSend_fpret(pvVar2,sel_hyperShadowDistance);
  fVar6 = (float)dVar9;
  if ((fVar6 != 0.0) || (NAN(fVar6))) {
    fVar4 = ABS(fVar6);
  }
  else {
    fVar4 = 1.0;
  }
  fVar7 = 0.0005;
  if (1.0 <= fVar4) {
    fVar7 = fVar4 * 0.0005;
  }
  if (ABS(fVar6) <= fVar7) {
    dVar9 = _objc_msgSend_fpret(angleChanged,sel_floatValue);
    lVar3 = (longdouble)_roundf((float)dVar9);
    fVar6 = (float)lVar3;
    _objc_msgSend(self->_angleTextField,sel_setFloatValue_,fVar6);
    _objc_msgSend(self->_angleSlider,sel_setFloatValue_,fVar6);
    _objc_msgSend(self->_angleStepper,sel_setFloatValue_,fVar6);
  }
  return;
}

*/
- (void)angleChanged:(id)aChanged
{
    double twoPiDouble = M_PI + M_PI;
    float twoPi = (float)twoPiDouble;
    float radians = (float)(([aChanged floatValue] * -3.141592653589793) / -180.0 + 6.283185307179586);
    if (!HSFloatIsApproximatelyGreaterOrEqual(radians, twoPi)) {
        if (radians < 0.0f) {
            radians = (float)((double)radians + ((double)floorf((float)(fabs(radians) / twoPiDouble)) + 1.0) * twoPiDouble);
            if (HSFloatIsApproximatelyGreaterOrEqual(radians, twoPi)) {
                radians = (float)((double)radians + M_PI * -2.0);
            }
        }
    } else {
        radians = (float)(M_PI * -2.0 * (double)floorf((float)((double)radians / twoPiDouble)) + (double)radians);
    }
    [[self applier] setAngle:radians + -1.5707964f];
    float distance = [[[self applier] shadowAttributes] hyperShadowDistance];
    if (HSFloatIsApproximatelyZero(distance)) {
        float degrees = roundf([aChanged floatValue]);
        [_angleTextField setFloatValue:degrees];
        [_angleSlider setFloatValue:degrees];
        [_angleStepper setFloatValue:degrees];
    }
}

- (void)blurChanged:(id)aChanged
{
    [[self applier] setBlur:(float)[aChanged floatValue]];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-multiple-method-names"
- (void)offsetChanged:(id)aChanged
{
    [[self applier] setOffset:(float)[aChanged floatValue]];
}
#pragma clang diagnostic pop

- (id)helpTopicKey
{
    return @"HSShadowPane";
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [self setObservedMutableShadowAttributes:nil];
    [self setObservedTextViewAttributes:nil];
    [self setObservedButtonObjectAttributes:nil];
    [super viewWillDisappear:aDisappear];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [self setObservedMutableShadowAttributes:[[[self assistant] object] queryHyperInterface:@protocol(HSMutableShadowAttributes)]];
    [self setObservedTextViewAttributes:[[[self assistant] object] queryHyperInterface:@protocol(HSSystemTextViewAttributes)]];
    [self setObservedButtonObjectAttributes:[[[self assistant] object] queryHyperInterface:@protocol(HSButtonObjectAttributes)]];
    [[self applier] setShadowEnabled:YES];
    [self validateUI];
}

- (void)setObservedMutableShadowAttributes:(id)aAttributes
{
    int uVar1;
    id pvVar2;
    id pvVar2_2;

    if (_observedMutableShadowAttributes != aAttributes) {
        pvVar2 = [_observedMutableShadowAttributes attributeObservingController];
        uVar1 = HSActualDidAttributeChanges;
        [pvVar2 removeObserver:self selector:@selector(validateUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSMutableShadowAttributes)];
        [_observedMutableShadowAttributes release];
        pvVar2_2 = [aAttributes retain];
        _observedMutableShadowAttributes = pvVar2_2;
        [[pvVar2_2 attributeObservingController] addObserver:self selector:@selector(validateUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSMutableShadowAttributes) withPriority:-0.25];
    }
}

- (void)setObservedButtonObjectAttributes:(id)aAttributes
{
    int uVar1;
    id pvVar2;
    id pvVar2_2;

    if (_observedButtonObjectAttributes != aAttributes) {
        pvVar2 = [_observedButtonObjectAttributes attributeObservingController];
        uVar1 = HSActualDidAttributeChanges;
        [pvVar2 removeObserver:self selector:@selector(validateUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSButtonObjectAttributes)];
        [_observedButtonObjectAttributes release];
        pvVar2_2 = [aAttributes retain];
        _observedButtonObjectAttributes = pvVar2_2;
        [[pvVar2_2 attributeObservingController] addObserver:self selector:@selector(validateUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSButtonObjectAttributes) withPriority:-0.25];
    }
}

- (void)setObservedTextViewAttributes:(id)aAttributes
{
    int uVar1;
    id pvVar2;
    id pvVar2_2;

    if (_observedTextViewAttributes != aAttributes) {
        pvVar2 = [_observedTextViewAttributes attributeObservingController];
        uVar1 = HSActualDidAttributeChanges;
        [pvVar2 removeObserver:self selector:@selector(validateUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSSystemTextViewAttributes)];
        [_observedTextViewAttributes release];
        pvVar2_2 = [aAttributes retain];
        _observedTextViewAttributes = pvVar2_2;
        [[pvVar2_2 attributeObservingController] addObserver:self selector:@selector(validateUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSSystemTextViewAttributes) withPriority:-0.25];
    }
}

- (id)applier
{
    return [super applier];
}

- (Class)applierClass
{
    return [HSShadowApplier class];
}

- (id)navigationPaneSwitcher
{
    HSObjectAssistantNavigationPaneSwitcher *pHVar1;
    HSObjectAssistantNavigationPaneSwitcher *pHVar1_2;

    pHVar1 = _paneSwitcher;
    if (pHVar1 == nil) {
        pHVar1_2 = [HSObjectAssistantNavigationPaneSwitcher new];
        _paneSwitcher = pHVar1_2;
        [pHVar1_2 setDelegate:self];
        pHVar1 = _paneSwitcher;
    }
    return pHVar1;
}

- (void)dealloc
{
    int uVar1;
    id pvVar2;

    pvVar2 = [_observedTextViewAttributes attributeObservingController];
    uVar1 = HSActualDidAttributeChanges;
    [pvVar2 removeObserver:self selector:@selector(validateUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSSystemTextViewAttributes)];
    [_observedTextViewAttributes release];
    [[_observedMutableShadowAttributes attributeObservingController] removeObserver:self selector:@selector(validateUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSMutableShadowAttributes)];
    [_observedMutableShadowAttributes release];
    [[_observedButtonObjectAttributes attributeObservingController] removeObserver:self selector:@selector(validateUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSButtonObjectAttributes)];
    [_observedButtonObjectAttributes release];
    [_paneSwitcher setDelegate:0];
    [_paneSwitcher release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"ShadowAssistantPane"];
    return self;
}

@end

@implementation HSShadowApplier

/* i386 ivar offsets: _initialShadowEnabled=0xc, _initialOffset=0x10, _initialBlur=0x14, _initialAngle=0x18, _shadowEnabled=0x1c, _offset=0x20, _blur=0x24, _angle=0x28 */

- (BOOL)areSettingsEqual
{
    float fVar1;
    float fVar2;
    float fVar3;
    float fVar4;
    float fVar1_2;
    float fVar1_3;
    float fVar2_2;
    float fVar2_3;
    float fVar3_2;
    float fVar3_3;
    float fVar4_2;
    float fVar4_3;

    if (_initialShadowEnabled == _shadowEnabled) {
        fVar1 = _initialOffset;
        fVar2 = _offset;
        fVar3 = fVar1 != 0.0 ? fabs(fVar1) : 1.0;
        fVar4 = fVar2 != 0.0 ? fabs(fVar2) : 1.0;
        if (fVar4 <= fVar3) {
            fVar4 = fVar3;
        }
        if (fabs(fVar1 - fVar2) <= fVar4 * 0.0005) {
            fVar1_2 = _initialBlur;
            fVar2_2 = _blur;
            fVar3_2 = fVar1_2 != 0.0 ? fabs(fVar1_2) : 1.0;
            fVar4_2 = fVar2_2 != 0.0 ? fabs(fVar2_2) : 1.0;
            if (fVar4_2 <= fVar3_2) {
                fVar4_2 = fVar3_2;
            }
            if (fabs(fVar1_2 - fVar2_2) <= fVar4_2 * 0.0005) {
                fVar1_3 = _initialAngle;
                fVar2_3 = _angle;
                fVar3_3 = fVar1_3 != 0.0 ? fabs(fVar1_3) : 1.0;
                fVar4_3 = fVar2_3 != 0.0 ? fabs(fVar2_3) : 1.0;
                if (fVar4_3 <= fVar3_3) {
                    fVar4_3 = fVar3_3;
                }
                return fabs(fVar1_3 - fVar2_3) <= fVar4_3 * 0.0005;
            }
        }
    }
    return NO;
}

- (void)makeCurrentEqualToInitial
{
    _shadowEnabled = _initialShadowEnabled;
    _offset = _initialOffset;
    _blur = _initialBlur;
    _angle = _initialAngle;
}

- (void)makeInitialEqualToCurrent
{
    _initialShadowEnabled = _shadowEnabled;
    _initialOffset = _offset;
    _initialBlur = _blur;
    _initialAngle = _angle;
}

- (void)setUpInitialSettings
{
    id self_00;
    BOOL pvVar1;
    double dVar2;
    double dVar2_2;
    double dVar2_3;

    self_00 = [self shadowAttributes];
    pvVar1 = [self_00 isHyperShadowEnabled];
    _shadowEnabled = (BOOL)pvVar1;
    _initialShadowEnabled = (BOOL)pvVar1;
    dVar2 = [self_00 hyperShadowDistance];
    _offset = (float)dVar2;
    _initialOffset = (float)dVar2;
    dVar2_2 = [self_00 hyperShadowBlurRadius];
    _blur = (float)dVar2_2;
    _initialBlur = (float)dVar2_2;
    dVar2_3 = [self_00 hyperShadowAngle];
    _angle = (float)dVar2_3;
    _initialAngle = (float)dVar2_3;
}

- (void)setCurrentSettingsToObject
{
    [[self shadowAttributes] setHyperShadowEnabled:_shadowEnabled];
    [[self shadowAttributes] setHyperShadowDistance:_offset];
    [[self shadowAttributes] setHyperShadowBlurRadius:_blur];
    [[self shadowAttributes] setHyperShadowAngle:_angle];
}

- (void)setInitialSettingsToObject
{
    [[self shadowAttributes] setHyperShadowEnabled:_initialShadowEnabled];
    [[self shadowAttributes] setHyperShadowDistance:_initialOffset];
    [[self shadowAttributes] setHyperShadowBlurRadius:_initialBlur];
    [[self shadowAttributes] setHyperShadowAngle:_initialAngle];
}

- (void)setAngle:(CGFloat)aAngle
{
    if (_angle != aAngle) {
        _angle = aAngle;
        [self disableUndo];
        [[self shadowAttributes] setHyperShadowAngle:_angle];
        [self enableUndo];
    }
}

- (void)setBlur:(CGFloat)aBlur
{
    if (_blur != aBlur) {
        _blur = aBlur;
        [self disableUndo];
        [[self shadowAttributes] setHyperShadowBlurRadius:_blur];
        [self enableUndo];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00180642 @ 00180642, 329 bytes * /

void FUN_00180642(HSShadowApplier *self,SEL _cmd,float setOffset)

{
  id pvVar1;
  float fVar2;
  float fVar3;
  float fVar4;
  float fVar5;
  
  if (self->_offset != setOffset) {
    _objc_msgSend(self,sel_disableUndo);
    pvVar1 = _objc_msgSend(self,sel_shadowAttributes);
    fVar5 = setOffset;
    _objc_msgSend(pvVar1,sel_setHyperShadowDistance_,setOffset);
    if ((setOffset != 0.0) || (NAN(setOffset))) {
      fVar2 = ABS(setOffset);
    }
    else {
      fVar2 = 1.0;
    }
    fVar3 = 1.0;
    fVar4 = 0.0005;
    if (1.0 <= fVar2) {
      fVar4 = fVar2 * 0.0005;
    }
    if (fVar4 + 0.0 < setOffset) {
      fVar2 = self->_offset;
      if ((fVar2 != 0.0) || (NAN(fVar2))) {
        fVar3 = ABS(fVar2);
      }
      fVar4 = 0.0005;
      if (1.0 <= fVar3) {
        fVar4 = fVar3 * 0.0005;
      }
      if (ABS(fVar2) <= fVar4) {
        pvVar1 = _objc_msgSend(self,sel_shadowAttributes,fVar5);
        fVar5 = self->_angle;
        _objc_msgSend(pvVar1,sel_setHyperShadowAngle_,fVar5);
      }
    }
    _objc_msgSend(self,sel_enableUndo,fVar5);
    self->_offset = setOffset;
  }
  return;
}

*/
- (void)setOffset:(CGFloat)aOffset
{
    if (_offset != aOffset) {
        [self disableUndo];
        [[self shadowAttributes] setHyperShadowDistance:aOffset];
        if (!HSFloatIsApproximatelyZero(aOffset) && aOffset > 0.0f) {
            if (HSFloatIsApproximatelyZero(_offset)) {
                [[self shadowAttributes] setHyperShadowAngle:_angle];
            }
        }
        [self enableUndo];
        _offset = aOffset;
    }
}

- (void)setShadowEnabled:(BOOL)aEnabled
{
    if (_shadowEnabled != aEnabled) {
        _shadowEnabled = aEnabled;
        [self disableUndo];
        [[self shadowAttributes] setHyperShadowEnabled:_shadowEnabled];
        [self enableUndo];
    }
}

- (id)undoActionName
{
    return [[NSBundle mainBundle] localizedStringForKey:@"Change Shadow" value:@"" table:@"UndoManager"];
}

- (id)shadowAttributes
{
    id pvVar1_2;

    pvVar1_2 = [[self object] queryHyperInterface:@protocol(HSMutableShadowAttributes)];
    if (pvVar1_2 == nil) {
        pvVar1_2 = [[self object] queryHyperInterface:@protocol(HSSystemTextViewFontTraitsAttributes)];
    }
    return pvVar1_2;
}

@end

