#import "HSScaleAndRotateAssistantPane.h"

static BOOL HSTolEq(float a, float b)
{
    float sa = (a != 0.0f) ? fabsf(a) : 1.0f;
    float sb = (b != 0.0f) ? fabsf(b) : 1.0f;
    float scale = (sb <= sa) ? sa : sb;
    return fabsf(a - b) <= scale * 0.0005f;
}

@implementation HSScaleAndRotateAssistantPane

/* i386 ivar offsets: _rotationSlider=0x5c, _rotationStepper=0x60, _rotationTextField=0x64, _scaleFactorSlider=0x68, _scaleFactorStepper=0x6c, _scaleFactorTextField=0x70, _flipHorizontalButton=0x74, _flipVerticalButton=0x78, _userMadeTheDecision=0x7c, _isApplayed=0x7d, _applier=0x80, _paneSwitcher=0x84 */

+ (CGFloat)angleInRadiansFromClockwiseDegrees:(CGFloat)aDegrees
{
    return (aDegrees * 3.1415927) / -180.0 + 6.2831855;
}

+ (CGFloat)angleInClockwiseDegreesFromRadians:(CGFloat)aRadians
{
    float fVar1;

    for (fVar1 = ((6.2831855 - aRadians) / 3.1415927) * 180.0; 359.55 <= fVar1; fVar1 = fVar1 + -360.0) {
    }
    return fVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0017dee2 @ 0017dee2, 430 bytes * /

void FUN_0017dee2(HSScaleAndRotateAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  float fVar2;
  double dVar3;
  double dVar4;
  
  pvVar1 = _objc_msgSend(self,sel_applier);
  _objc_msgSend(pvVar1,sel_getCurrentSettingsFromObject);
  pvVar1 = _objc_msgSend(self,sel_applier);
  dVar3 = _objc_msgSend_fpret(pvVar1,sel_angle);
  dVar3 = _objc_msgSend_fpret(cls_HSScaleAndRotateAssistantPane,
                              sel_angleInClockwiseDegreesFromRadians_,(float)dVar3);
  fVar2 = (float)dVar3;
  _objc_msgSend(self->_rotationTextField,sel_setFloatValue_,fVar2);
  _objc_msgSend(self->_rotationSlider,sel_setFloatValue_,fVar2);
  _objc_msgSend(self->_rotationStepper,sel_setFloatValue_,fVar2);
  pvVar1 = _objc_msgSend(self,sel_applier);
  dVar3 = _objc_msgSend_fpret(pvVar1,sel_widthScale);
  pvVar1 = _objc_msgSend(self,sel_applier);
  dVar4 = _objc_msgSend_fpret(pvVar1,sel_heightScale);
  fVar2 = SQRT((float)dVar3 * (float)dVar4) * 100.0;
  _objc_msgSend(self->_scaleFactorTextField,sel_setFloatValue_,fVar2);
  _objc_msgSend(self->_scaleFactorSlider,sel_setFloatValue_,fVar2);
  _objc_msgSend(self->_scaleFactorStepper,sel_setFloatValue_,fVar2);
  return;
}

*/
- (void)validateUI
{
    [[self applier] getCurrentSettingsFromObject];
    float degrees = [HSScaleAndRotateAssistantPane angleInClockwiseDegreesFromRadians:[[self applier] angle]];
    [_rotationTextField setFloatValue:degrees];
    [_rotationSlider setFloatValue:degrees];
    [_rotationStepper setFloatValue:degrees];
    float scale = sqrtf([[self applier] widthScale] * [[self applier] heightScale]) * 100.0f;
    [_scaleFactorTextField setFloatValue:scale];
    [_scaleFactorSlider setFloatValue:scale];
    [_scaleFactorStepper setFloatValue:scale];
}

- (void)validateUIWithNotification:(id)aNotification
{
    if (_userMadeTheDecision == NO) {
        [self validateUI];
    }
}

- (void)flipVertical:(id)aVertical
{
    [_applier setIsFlippedVertically:(unsigned int)(![[[[self assistant] object] queryHyperInterface:@protocol(HSGeometryAttributes)] isFlippedVertically])];
}

- (void)flipHorizontal:(id)aHorizontal
{
    [_applier setIsFlippedHorizontally:(unsigned int)(![[[[self assistant] object] queryHyperInterface:@protocol(HSGeometryAttributes)] isFlippedHorizontally])];
}

- (void)scaleFactorChanged:(id)aChanged
{
    [_applier setScale:(float)[aChanged floatValue] / 100.0];
    [self validateUI];
}

- (void)rotationChanged:(id)aChanged
{
    [_applier setAngle:(float)[HSScaleAndRotateAssistantPane angleInRadiansFromClockwiseDegrees:(float)[aChanged floatValue]]];
}

- (id)helpTopicKey
{
    return @"HSScaleAndRotatePane";
}

- (id)imageObjectAttributes
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSImageObjectAttributes)];
}

- (id)geometryAttributes
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSGeometryAttributes)];
}

- (void)paneDidCancel:(id)aCancel
{
    id pvVar1;

    pvVar1 = [self applier];
    _userMadeTheDecision = YES;
    [pvVar1 setUserMadeTheDecision:YES];
    [[self applier] revertChanges];
    [self dismiss:YES];
}

- (void)paneDidOK:(id)aOK
{
    id pvVar1;

    if (_userMadeTheDecision == NO) {
        [_applier setAngle:(float)[HSScaleAndRotateAssistantPane angleInRadiansFromClockwiseDegrees:(float)[_rotationTextField floatValue]]];
        if (0.0 < (float)[_scaleFactorTextField floatValue]) {
            [_applier setScale:(float)[_scaleFactorTextField floatValue] / 100.0];
        }
    }
    pvVar1 = [self applier];
    _userMadeTheDecision = YES;
    [pvVar1 setUserMadeTheDecision:YES];
    if (_isApplayed == NO) {
        [[self applier] applyChanges];
        _isApplayed = YES;
    }
    [self dismiss:YES slide:NO];
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [[self assistant] setSupportsSettingsOnTheSpotMode:YES];
    [[[self geometryAttributes] attributeObservingController] removeObserver:self selector:@selector(validateUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSGeometryAttributes)];
    [[self navigationPaneSwitcher] setApplier:nil];
    [super viewWillDisappear:aDisappear];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    _isApplayed = NO;
    _userMadeTheDecision = NO;
    [[self assistant] setSupportsSettingsOnTheSpotMode:NO];
    [[[self geometryAttributes] attributeObservingController] addObserver:self selector:@selector(validateUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSGeometryAttributes) withPriority:-0.25];
    [[self navigationPaneSwitcher] setApplier:[self applier]];
    [[self applier] setUserMadeTheDecision:NO];
    [self validateUI];
}

- (void)viewDidLoad
{
    NSCell *pvVar1;

    [super viewDidLoad];
    pvVar1 = [_flipVerticalButton cell];
    [[NSArray arrayWithObjects:[_flipHorizontalButton cell], pvVar1, nil] makeObjectsPerformSelector:@selector(setBackgroundRenderer:) withObject:[HSLayoutPaletteButtonBackgroundRenderer sharedBackgroundRenderer]]
    ;
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

- (id)applier
{
    id pvVar1;

    pvVar1 = _applier;
    if (pvVar1 == nil) {
        [self setApplier:[[[HSScaleAndRotateApplier alloc] initWithObject:[[self assistant] object]] autorelease]];
        pvVar1 = _applier;
    }
    return pvVar1;
}

- (void)setApplier:(id)aApplier
{
    if (_applier != aApplier) {
        [_applier autorelease];
        _applier = [aApplier retain];
    }
}

- (void)dealloc
{
    [_applier release];
    [_paneSwitcher setDelegate:0];
    [_paneSwitcher release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"ScaleAndRotateAssistantPane"];
    return self;
}

@end

@implementation HSScaleAndRotateApplier

/* i386 ivar offsets: _initialAffineTransform=0xc, _initialWidthScale=0x24, _initialHeightScale=0x28, _initialAngle=0x2c, _initialIsFlippedHorizontally=0x30, _initialIsFlippedVertically=0x31, _affineTransform=0x34, _widthScale=0x4c, _heightScale=0x50, _angle=0x54, _isFlippedHorizontally=0x58, _isFlippedVertically=0x59, _userMadeTheDecision=0x5a, _geometryApplier=0x5c */

- (BOOL)userMadeTheDecision
{
    return _userMadeTheDecision;
}

- (void)setUserMadeTheDecision:(BOOL)aDecision
{
    _userMadeTheDecision = aDecision;
}

- (id)imageObjectAttributes
{
    return [[self object] queryHyperInterface:@protocol(HSImageObjectAttributes)];
}

- (id)geometryAttributes
{
    return [[self object] queryHyperInterface:@protocol(HSGeometryAttributes)];
}

- (BOOL)isFlippedVertically
{
    return _isFlippedVertically;
}

- (void)setIsFlippedVertically:(BOOL)aVertically
{
    if (_isFlippedVertically != aVertically) {
        _isFlippedVertically = aVertically;
        [self disableUndo];
        [_geometryApplier setFlippedVertically:_isFlippedVertically withLayoutGuidingContext:nil];
        [self enableUndo];
    }
}

- (BOOL)isFlippedHorizontally
{
    return _isFlippedHorizontally;
}

- (void)setIsFlippedHorizontally:(BOOL)aHorizontally
{
    if (_isFlippedHorizontally != aHorizontally) {
        _isFlippedHorizontally = aHorizontally;
        [self disableUndo];
        [_geometryApplier setFlippedHorizontally:_isFlippedHorizontally withLayoutGuidingContext:nil];
        [self enableUndo];
    }
}

- (CGFloat)angle
{
    return _angle;
}

- (void)setAngle:(CGFloat)aAngle
{
    if ((_userMadeTheDecision == NO) && (_angle != aAngle)) {
        _angle = aAngle;
        [self disableUndo];
        [_geometryApplier rotateTo:_angle aboutRelativePoint:NSMakePoint(0.5, 0.5) withLayoutGuidingContext:nil];
        [self enableUndo];
    }
}

- (BOOL)hasUniformScale
{
    float fVar1;
    float fVar2;
    float fVar3;
    float fVar4;

    fVar1 = _widthScale;
    fVar2 = _heightScale;
    fVar3 = fVar1 != 0.0 ? fabs(fVar1) : 1.0;
    fVar4 = fVar2 != 0.0 ? fabs(fVar2) : 1.0;
    if (fVar4 <= fVar3) {
        fVar4 = fVar3;
    }
    return fabs(fVar1 - fVar2) <= fVar4 * 0.0005;
}

- (CGFloat)heightScale
{
    return _heightScale;
}

- (CGFloat)widthScale
{
    return _widthScale;
}

- (CGFloat)scale
{
    float fVar1;

    if (![self hasUniformScale]) {
        fVar1 = 0.0;
    }
    else {
        fVar1 = _widthScale;
    }
    return fVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0017ed35 @ 0017ed35, 520 bytes * /

void FUN_0017ed35(HSScaleAndRotateApplier *self,SEL _cmd,float setScale)

{
  id pvVar1;
  id self_00;
  float extraout_EDX;
  float fVar2;
  float fVar3;
  float fVar4;
  undefined1 local_2c [12];
  float local_20;
  undefined1 local_1c [8];
  float local_14;
  
  if (self->_userMadeTheDecision == '\0') {
    fVar2 = SQRT(self->_widthScale * self->_heightScale);
    if ((fVar2 != 0.0) || (NAN(fVar2))) {
      fVar3 = ABS(fVar2);
    }
    else {
      fVar3 = 1.0;
    }
    if ((setScale != 0.0) || (NAN(setScale))) {
      fVar4 = ABS(setScale);
    }
    else {
      fVar4 = 1.0;
    }
    if (fVar4 <= fVar3) {
      fVar4 = fVar3;
    }
    if (fVar4 * 0.0005 < ABS(fVar2 - setScale)) {
      self->_widthScale = self->_widthScale * (setScale / fVar2);
      self->_heightScale = self->_heightScale * (setScale / fVar2);
      _objc_msgSend(self,sel_disableUndo);
      pvVar1 = _objc_msgSend(self,sel_geometryAttributes);
      _objc_msgSend(pvVar1,sel_defaultSize);
      fVar2 = self->_heightScale;
      pvVar1 = _objc_msgSend(self,sel_imageObjectAttributes);
      _objc_msgSend_stret(local_2c,pvVar1,sel_relativeImageRect);
      pvVar1 = _objc_msgSend(self,sel_geometryAttributes);
      pvVar1 = _objc_msgSend(pvVar1,sel_defaultSize);
      fVar3 = self->_widthScale;
      self_00 = _objc_msgSend(self,sel_imageObjectAttributes);
      _objc_msgSend_stret(local_1c,self_00,sel_relativeImageRect);
      _objc_msgSend(self->_geometryApplier,
                    sel_resizeFrameTo_aboutRelativePoint_followResizingScalingPreference_maintainAspectRatio_byAspectRatioMaintainingRule_withLayoutGuidingContext_
                    ,((float)pvVar1 * fVar3) / local_14,(extraout_EDX * fVar2) / local_20,0x3f000000
                    ,0x3f000000,1,2,0,0);
      _objc_msgSend(self,sel_enableUndo);
    }
  }
  return;
}

*/
- (void)setScale:(CGFloat)aScale
{
    if (!_userMadeTheDecision) {
        float current = sqrtf(_widthScale * _heightScale);
        float sc = (current != 0.0f) ? fabsf(current) : 1.0f;
        float sa = (aScale != 0.0f) ? fabsf(aScale) : 1.0f;
        float scale = MAX(sa, sc);
        if (scale * 0.0005f < fabsf(current - aScale)) {
            _widthScale = _widthScale * (aScale / current);
            _heightScale = _heightScale * (aScale / current);
            [self disableUndo];
            NSSize defaultSize = [[self geometryAttributes] defaultSize];
            NSRect rect = [[self imageObjectAttributes] relativeImageRect];
            [_geometryApplier resizeFrameTo:NSMakeSize((defaultSize.width * _widthScale) / rect.size.width, (defaultSize.height * _heightScale) / rect.size.height) aboutRelativePoint:NSMakePoint(0.5f, 0.5f) followResizingScalingPreference:YES maintainAspectRatio:2 byAspectRatioMaintainingRule:0 withLayoutGuidingContext:nil];
            [self enableUndo];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0017ef3d @ 0017ef3d, 436 bytes * /

BOOL FUN_0017ef3d(HSScaleAndRotateApplier *self,SEL _cmd)

{
  float fVar1;
  float fVar2;
  undefined8 uVar3;
  undefined8 uVar4;
  undefined8 uVar5;
  undefined8 uVar6;
  undefined8 uVar7;
  undefined8 uVar8;
  char cVar9;
  float fVar10;
  float fVar11;
  
  uVar3._0_4_ = (self->_affineTransform).tx;
  uVar3._4_4_ = (self->_affineTransform).ty;
  uVar4._0_4_ = (self->_affineTransform).c;
  uVar4._4_4_ = (self->_affineTransform).d;
  uVar5._0_4_ = (self->_affineTransform).a;
  uVar5._4_4_ = (self->_affineTransform).b;
  uVar6._0_4_ = (self->_initialAffineTransform).tx;
  uVar6._4_4_ = (self->_initialAffineTransform).ty;
  uVar7._0_4_ = (self->_initialAffineTransform).a;
  uVar7._4_4_ = (self->_initialAffineTransform).b;
  uVar8._0_4_ = (self->_initialAffineTransform).c;
  uVar8._4_4_ = (self->_initialAffineTransform).d;
  cVar9 = _CGAffineTransformEqualToTransform(uVar7,uVar8,uVar6,uVar5,uVar4,uVar3);
  if (cVar9 != '\0') {
    fVar1 = self->_initialWidthScale;
    fVar2 = self->_widthScale;
    if ((fVar1 != 0.0) || (NAN(fVar1))) {
      fVar10 = ABS(fVar1);
    }
    else {
      fVar10 = 1.0;
    }
    if ((fVar2 != 0.0) || (NAN(fVar2))) {
      fVar11 = ABS(fVar2);
    }
    else {
      fVar11 = 1.0;
    }
    if (fVar11 <= fVar10) {
      fVar11 = fVar10;
    }
    if (ABS(fVar1 - fVar2) <= fVar11 * 0.0005) {
      fVar1 = self->_initialHeightScale;
      fVar2 = self->_heightScale;
      if ((fVar1 != 0.0) || (NAN(fVar1))) {
        fVar10 = ABS(fVar1);
      }
      else {
        fVar10 = 1.0;
      }
      if ((fVar2 != 0.0) || (NAN(fVar2))) {
        fVar11 = ABS(fVar2);
      }
      else {
        fVar11 = 1.0;
      }
      if (fVar11 <= fVar10) {
        fVar11 = fVar10;
      }
      if (ABS(fVar1 - fVar2) <= fVar11 * 0.0005) {
        fVar1 = self->_initialAngle;
        fVar2 = self->_angle;
        if ((fVar1 != 0.0) || (NAN(fVar1))) {
          fVar10 = ABS(fVar1);
        }
        else {
          fVar10 = 1.0;
        }
        if ((fVar2 != 0.0) || (NAN(fVar2))) {
          fVar11 = ABS(fVar2);
        }
        else {
          fVar11 = 1.0;
        }
        if (fVar11 <= fVar10) {
          fVar11 = fVar10;
        }
        if ((ABS(fVar1 - fVar2) <= fVar11 * 0.0005) &&
           (self->_initialIsFlippedHorizontally == self->_isFlippedHorizontally)) {
          return self->_initialIsFlippedVertically == self->_isFlippedVertically;
        }
      }
    }
  }
  return '\0';
}

*/
- (BOOL)areSettingsEqual
{
    if (CGAffineTransformEqualToTransform(_initialAffineTransform, _affineTransform) &&
        HSTolEq(_initialWidthScale, _widthScale) &&
        HSTolEq(_initialHeightScale, _heightScale) &&
        HSTolEq(_initialAngle, _angle) &&
        _initialIsFlippedHorizontally == _isFlippedHorizontally) {
        return _initialIsFlippedVertically == _isFlippedVertically;
    }
    return NO;
    return 0;
}

- (void)makeCurrentEqualToInitial
{
    _widthScale = _initialWidthScale;
    _heightScale = _initialHeightScale;
    _angle = _initialAngle;
    _isFlippedHorizontally = _initialIsFlippedHorizontally;
    _isFlippedVertically = _initialIsFlippedVertically;
    (_affineTransform).a = (_initialAffineTransform).a;
    (_affineTransform).b = (_initialAffineTransform).b;
    (_affineTransform).c = (_initialAffineTransform).c;
    (_affineTransform).d = (_initialAffineTransform).d;
    (_affineTransform).tx = (_initialAffineTransform).tx;
    (_affineTransform).ty = (_initialAffineTransform).ty;
}

- (void)makeInitialEqualToCurrent
{
    _initialWidthScale = _widthScale;
    _initialHeightScale = _heightScale;
    _initialAngle = _angle;
    _initialIsFlippedHorizontally = _isFlippedHorizontally;
    _initialIsFlippedVertically = _isFlippedVertically;
    (_initialAffineTransform).a = (_affineTransform).a;
    (_initialAffineTransform).b = (_affineTransform).b;
    (_initialAffineTransform).c = (_affineTransform).c;
    (_initialAffineTransform).d = (_affineTransform).d;
    (_initialAffineTransform).tx = (_affineTransform).tx;
    (_initialAffineTransform).ty = (_affineTransform).ty;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0017f0f1 @ 0017f0f1, 408 bytes * /

void FUN_0017f0f1(HSScaleAndRotateApplier *self,SEL _cmd)

{
  float fVar1;
  float fVar2;
  undefined8 uVar3;
  undefined8 uVar4;
  undefined8 uVar5;
  id pvVar6;
  id self_00;
  float extraout_EDX;
  undefined1 local_2c [12];
  float local_20;
  undefined1 local_1c [8];
  float local_14;
  
  pvVar6 = _objc_msgSend(self,sel_geometryAttributes);
  _objc_msgSend(pvVar6,sel_defaultSize);
  fVar1 = self->_initialHeightScale;
  pvVar6 = _objc_msgSend(self,sel_imageObjectAttributes);
  _objc_msgSend_stret(local_2c,pvVar6,sel_relativeImageRect);
  pvVar6 = _objc_msgSend(self,sel_geometryAttributes);
  pvVar6 = _objc_msgSend(pvVar6,sel_defaultSize);
  fVar2 = self->_initialWidthScale;
  self_00 = _objc_msgSend(self,sel_imageObjectAttributes);
  _objc_msgSend_stret(local_1c,self_00,sel_relativeImageRect);
  _objc_msgSend(self->_geometryApplier,
                sel_resizeFrameTo_aboutRelativePoint_followResizingScalingPreference_maintainAspectRatio_byAspectRatioMaintainingRule_withLayoutGuidingContext_
                ,((float)pvVar6 * fVar2) / local_14,(extraout_EDX * fVar1) / local_20,
                *(undefined4 *)PTR_00336074,*(undefined4 *)(PTR_00336074 + 4),1,2,0,0);
  uVar3._0_4_ = (self->_initialAffineTransform).tx;
  uVar3._4_4_ = (self->_initialAffineTransform).ty;
  uVar4._0_4_ = (self->_initialAffineTransform).a;
  uVar4._4_4_ = (self->_initialAffineTransform).b;
  uVar5._0_4_ = (self->_initialAffineTransform).c;
  uVar5._4_4_ = (self->_initialAffineTransform).d;
  _objc_msgSend(self->_geometryApplier,
                sel_setAffineTransform_flippedHorizontally_withLayoutGuidingContext_,uVar4,uVar5,
                uVar3,(int)self->_initialIsFlippedHorizontally,0);
  return;
}

*/
- (void)setInitialSettingsToObject
{
    NSSize defaultSize = [[self geometryAttributes] defaultSize];
    NSRect rect = [[self imageObjectAttributes] relativeImageRect];
    [_geometryApplier resizeFrameTo:NSMakeSize((defaultSize.width * _initialWidthScale) / rect.size.width, (defaultSize.height * _initialHeightScale) / rect.size.height) aboutRelativePoint:NSZeroPoint followResizingScalingPreference:YES maintainAspectRatio:2 byAspectRatioMaintainingRule:0 withLayoutGuidingContext:nil];
    [_geometryApplier setAffineTransform:_initialAffineTransform flippedHorizontally:_initialIsFlippedHorizontally withLayoutGuidingContext:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0017f289 @ 0017f289, 408 bytes * /

void FUN_0017f289(HSScaleAndRotateApplier *self,SEL _cmd)

{
  float fVar1;
  float fVar2;
  undefined8 uVar3;
  undefined8 uVar4;
  undefined8 uVar5;
  id pvVar6;
  id self_00;
  float extraout_EDX;
  undefined1 local_2c [12];
  float local_20;
  undefined1 local_1c [8];
  float local_14;
  
  pvVar6 = _objc_msgSend(self,sel_geometryAttributes);
  _objc_msgSend(pvVar6,sel_defaultSize);
  fVar1 = self->_heightScale;
  pvVar6 = _objc_msgSend(self,sel_imageObjectAttributes);
  _objc_msgSend_stret(local_2c,pvVar6,sel_relativeImageRect);
  pvVar6 = _objc_msgSend(self,sel_geometryAttributes);
  pvVar6 = _objc_msgSend(pvVar6,sel_defaultSize);
  fVar2 = self->_widthScale;
  self_00 = _objc_msgSend(self,sel_imageObjectAttributes);
  _objc_msgSend_stret(local_1c,self_00,sel_relativeImageRect);
  _objc_msgSend(self->_geometryApplier,
                sel_resizeFrameTo_aboutRelativePoint_followResizingScalingPreference_maintainAspectRatio_byAspectRatioMaintainingRule_withLayoutGuidingContext_
                ,((float)pvVar6 * fVar2) / local_14,(extraout_EDX * fVar1) / local_20,
                *(undefined4 *)PTR_00336074,*(undefined4 *)(PTR_00336074 + 4),1,2,0,0);
  uVar3._0_4_ = (self->_affineTransform).tx;
  uVar3._4_4_ = (self->_affineTransform).ty;
  uVar4._0_4_ = (self->_affineTransform).a;
  uVar4._4_4_ = (self->_affineTransform).b;
  uVar5._0_4_ = (self->_affineTransform).c;
  uVar5._4_4_ = (self->_affineTransform).d;
  _objc_msgSend(self->_geometryApplier,
                sel_setAffineTransform_flippedHorizontally_withLayoutGuidingContext_,uVar4,uVar5,
                uVar3,(int)self->_isFlippedHorizontally,0);
  return;
}

*/
- (void)setCurrentSettingsToObject
{
    NSSize defaultSize = [[self geometryAttributes] defaultSize];
    NSRect rect = [[self imageObjectAttributes] relativeImageRect];
    [_geometryApplier resizeFrameTo:NSMakeSize((defaultSize.width * _widthScale) / rect.size.width, (defaultSize.height * _heightScale) / rect.size.height) aboutRelativePoint:NSZeroPoint followResizingScalingPreference:YES maintainAspectRatio:2 byAspectRatioMaintainingRule:0 withLayoutGuidingContext:nil];
    [_geometryApplier setAffineTransform:_affineTransform flippedHorizontally:_isFlippedHorizontally withLayoutGuidingContext:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0017f421 @ 0017f421, 426 bytes * /

void FUN_0017f421(HSScaleAndRotateApplier *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  float extraout_EDX;
  double dVar3;
  float local_3c;
  float local_38;
  float local_34;
  float local_30;
  float local_2c;
  float local_28;
  undefined1 local_24 [8];
  float local_1c;
  float local_18;
  
  if (self->_geometryApplier == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_object);
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00378800);
    pvVar1 = _objc_msgSend(pvVar1,sel_queryGeometryBehaviorApplier);
    pvVar1 = _objc_msgSend(pvVar1,sel_retain);
    self->_geometryApplier = pvVar1;
  }
  pvVar1 = _objc_msgSend(self,sel_geometryAttributes);
  pvVar2 = _objc_msgSend(self,sel_imageObjectAttributes);
  _objc_msgSend_stret(local_24,pvVar2,sel_imageRect);
  pvVar2 = _objc_msgSend(pvVar1,sel_defaultSize);
  self->_widthScale = local_1c / (float)pvVar2;
  _objc_msgSend(pvVar1,sel_defaultSize);
  self->_heightScale = local_18 / extraout_EDX;
  dVar3 = _objc_msgSend_fpret(pvVar1,sel_rotationAngle);
  self->_angle = (float)dVar3;
  pvVar2 = _objc_msgSend(pvVar1,sel_isFlippedHorizontally);
  self->_isFlippedHorizontally = (BOOL)pvVar2;
  pvVar2 = _objc_msgSend(pvVar1,sel_isFlippedVertically);
  self->_isFlippedVertically = (BOOL)pvVar2;
  _objc_msgSend_stret(&local_3c,pvVar1,sel_affineTransform);
  (self->_affineTransform).a = local_3c;
  (self->_affineTransform).b = local_38;
  (self->_affineTransform).c = local_34;
  (self->_affineTransform).d = local_30;
  (self->_affineTransform).tx = local_2c;
  (self->_affineTransform).ty = local_28;
  return;
}

*/
- (void)getCurrentSettingsFromObject
{
    if (_geometryApplier == nil) {
        _geometryApplier = [[[[self object] queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier] retain];
    }
    id geometry = [self geometryAttributes];
    NSRect imageRect = [[self imageObjectAttributes] imageRect];
    NSSize defaultSize = [geometry defaultSize];
    _widthScale = imageRect.size.width / defaultSize.width;
    defaultSize = [geometry defaultSize];
    _heightScale = imageRect.size.height / defaultSize.height;
    _angle = [geometry rotationAngle];
    _isFlippedHorizontally = [geometry isFlippedHorizontally];
    _isFlippedVertically = [geometry isFlippedVertically];
    _affineTransform = [geometry affineTransform];
}

- (id)undoActionName
{
    return [[NSBundle mainBundle] localizedStringForKey:@"Change Scale and Rotate Attributes" value:@"" table:@"UndoManager"];
}

- (void)dealloc
{
    [_geometryApplier release];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0017ea4c @ 0017ea4c, 192 bytes * /

id FUN_0017ea4c(HSScaleAndRotateApplier *self,SEL _cmd,id initWithObject)

{
  id self_00;
  HSScaleAndRotateApplier *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_HSAssistantPaneApplier_00352670;
  self_00 = _objc_msgSendSuper(&local_14,sel_initWithObject_,initWithObject);
  if (self_00 != (id)0x0) {
    _objc_msgSend(self_00,sel_getCurrentSettingsFromObject);
    *(undefined4 *)((int)self_00 + 0x24) = *(undefined4 *)((int)self_00 + 0x4c);
    *(undefined4 *)((int)self_00 + 0x28) = *(undefined4 *)((int)self_00 + 0x50);
    *(undefined4 *)((int)self_00 + 0x2c) = *(undefined4 *)((int)self_00 + 0x54);
    *(undefined1 *)((int)self_00 + 0x30) = *(undefined1 *)((int)self_00 + 0x58);
    *(undefined1 *)((int)self_00 + 0x31) = *(undefined1 *)((int)self_00 + 0x59);
    *(undefined4 *)((int)self_00 + 0xc) = *(undefined4 *)((int)self_00 + 0x34);
    *(undefined4 *)((int)self_00 + 0x10) = *(undefined4 *)((int)self_00 + 0x38);
    *(undefined4 *)((int)self_00 + 0x14) = *(undefined4 *)((int)self_00 + 0x3c);
    *(undefined4 *)((int)self_00 + 0x18) = *(undefined4 *)((int)self_00 + 0x40);
    *(undefined4 *)((int)self_00 + 0x1c) = *(undefined4 *)((int)self_00 + 0x44);
    *(undefined4 *)((int)self_00 + 0x20) = *(undefined4 *)((int)self_00 + 0x48);
  }
  return self_00;
}

*/
- (id)initWithObject:(id)aObject
{
    self = [super initWithObject:aObject];
    if (self != nil) {
        [self getCurrentSettingsFromObject];
        _initialWidthScale = _widthScale;
        _initialHeightScale = _heightScale;
        _initialAngle = _angle;
        _initialIsFlippedHorizontally = _isFlippedHorizontally;
        _initialIsFlippedVertically = _isFlippedVertically;
        _initialAffineTransform = _affineTransform;
    }
    return self;
    return 0;
}

@end

