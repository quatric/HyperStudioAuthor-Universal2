#import "HSMovieObjectAppearanceAssistantPane.h"

static float HSMovieAppearanceTolerance(float aValue, float aValue2)
{
    return MAX(aValue != 0.0f ? fabsf(aValue) : 1.0f, aValue2 != 0.0f ? fabsf(aValue2) : 1.0f) * 0.0005f;
}

/* Clamps a value to [min, max] with the usual float tolerance. */
static float HSMovieAppearanceClamp(float aValue, float aMin, float aMax)
{
    if (aValue < aMin - HSMovieAppearanceTolerance(aValue, aMin)) {
        return aMin;
    }
    if (aValue > aMax + HSMovieAppearanceTolerance(aValue, aMax)) {
        return aMax;
    }
    return aValue;
}

@implementation HSMovieObjectAppearanceAssistantPane

/* i386 ivar offsets: _nameTextField=0x5c, _rangeControl=0x60, _volumeSlider=0x64, _volumeInButton=0x68, _volumeOutButton=0x6c, _volumeStepper=0x70, _volumeTextField=0x74, _opacitySlider=0x78, _opacityStepper=0x7c, _opacityTextField=0x80, _shadowButton=0x84, _shadowSwitch=0x88, _movieControlSwitch=0x8c, _playButton=0x90, _transparentColorButton=0x94, _transparentColorSwitch=0x98, _movieTypeTabView=0x9c, _movieTopControlBarView=0xa0, _movieBottomControlBarView=0xa4, _simpleMovieTopControlBox=0xa8, _simpleMovieBottomControlBox=0xac, _QTVRMovieTopControlBox=0xb0, _QTVRMovieBottomControlBox=0xb4, _zoomInButton=0xb8, _zoomOutButton=0xbc, _spinButton=0xc0, _playImage=0xc4, _stopImage=0xc8, _pressedPlayImage=0xcc, _pressedStopImage=0xd0, _importMoviesDialogController=0xd4, _tiltAngle=0xd8, _tiltAngleMin=0xdc, _tiltAngleMax=0xe0, _panAngle=0xe4, _panAngleMin=0xe8, _panAngleMax=0xec, _fieldOfView=0xf0, _fieldOfViewMin=0xf4, _fieldOfViewMax=0xf8, _transparentColorAttributes=0xfc, _volumeSliderIsTracking=0x100 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_001835cb @ 001835cb, 2247 bytes * /

void FUN_001835cb(HSMovieObjectAppearanceAssistantPane *self,SEL _cmd)

{
  float fVar1;
  float fVar2;
  id pvVar3;
  id pvVar4;
  id self_00;
  float fVar5;
  float fVar6;
  double dVar7;
  cfstringStruct *pcVar8;
  undefined *puVar9;
  undefined4 uVar10;
  undefined4 uVar11;
  undefined1 local_54 [16];
  undefined1 local_44 [16];
  undefined1 local_34 [16];
  undefined1 local_24 [20];
  
  pvVar3 = _objc_msgSend(self,sel_movieObjectAttributes);
  pvVar4 = _objc_msgSend(pvVar3,sel_hyperConstraintValue_forAttribute_,&cfstr_Min,sel_hyperVolume);
  pvVar3 = _objc_msgSend(self,sel_movieObjectAttributes);
  self_00 = _objc_msgSend(pvVar3,sel_hyperConstraintValue_forAttribute_,&cfstr_Max,sel_hyperVolume);
  pvVar3 = self->_volumeSlider;
  dVar7 = _objc_msgSend_fpret(pvVar4,sel_floatValue);
  _objc_msgSend(pvVar3,sel_setMinValue_,SUB84(dVar7,0),(int)((ulonglong)dVar7 >> 0x20));
  pvVar3 = self->_volumeSlider;
  dVar7 = _objc_msgSend_fpret(self_00,sel_floatValue);
  uVar10 = SUB84(dVar7,0);
  uVar11 = (undefined4)((ulonglong)dVar7 >> 0x20);
  _objc_msgSend(pvVar3,sel_setMaxValue_,uVar10,uVar11);
  pvVar3 = _objc_msgSend(self,sel_movieObjectAttributes);
  pvVar4 = _objc_msgSend(self,sel_movieObjectAttributes);
  pvVar4 = _objc_msgSend(pvVar4,sel_isHyperQTVR);
  if ((char)pvVar4 == '\0') {
    pvVar4 = _objc_msgSend(self,sel_movieObjectAttributes,uVar10,uVar11);
    pvVar4 = _objc_msgSend(pvVar4,sel_isHyperPanoramaObject);
    if ((char)pvVar4 == '\0') {
      _objc_msgSend(self->_movieTypeTabView,sel_selectTabViewItemWithIdentifier_,&cfstr_simpleMovie)
      ;
      _objc_msgSend(self->_movieTopControlBarView,sel_removeFromSuperview);
      pvVar3 = self->_movieTopControlBarView;
      _objc_msgSend_stret(local_34,self->_simpleMovieTopControlBox,sel_bounds);
      _objc_msgSend(pvVar3,sel_setFrame_,(int)local_34._0_8_,SUB84(local_34._0_8_,4),
                    (int)local_34._8_8_,SUB84(local_34._8_8_,4));
      _objc_msgSend(self->_simpleMovieTopControlBox,sel_addSubview_,self->_movieTopControlBarView);
      _objc_msgSend(self->_movieBottomControlBarView,sel_removeFromSuperview);
      pvVar3 = self->_movieBottomControlBarView;
      _objc_msgSend_stret(local_24,self->_simpleMovieBottomControlBox,sel_bounds);
      _objc_msgSend(pvVar3,sel_setFrame_,(int)local_24._0_8_,SUB84(local_24._0_8_,4),
                    (int)local_24._8_8_,SUB84(local_24._8_8_,4));
      _objc_msgSend(self->_simpleMovieBottomControlBox,sel_addSubview_,
                    self->_movieBottomControlBarView);
      return;
    }
  }
  _objc_msgSend(self->_movieTypeTabView,sel_selectTabViewItemWithIdentifier_,&cfstr_QTVRMovie);
  _objc_msgSend(self->_movieTopControlBarView,sel_removeFromSuperview);
  pvVar4 = self->_movieTopControlBarView;
  _objc_msgSend_stret(local_54,self->_QTVRMovieTopControlBox,sel_bounds);
  _objc_msgSend(pvVar4,sel_setFrame_,(int)local_54._0_8_,SUB84(local_54._0_8_,4),(int)local_54._8_8_
                ,SUB84(local_54._8_8_,4));
  _objc_msgSend(self->_QTVRMovieTopControlBox,sel_addSubview_,self->_movieTopControlBarView);
  _objc_msgSend(self->_movieBottomControlBarView,sel_removeFromSuperview);
  pvVar4 = self->_movieBottomControlBarView;
  _objc_msgSend_stret(local_44,self->_QTVRMovieBottomControlBox,sel_bounds);
  _objc_msgSend(pvVar4,sel_setFrame_,(int)local_44._0_8_,SUB84(local_44._0_8_,4),(int)local_44._8_8_
                ,SUB84(local_44._8_8_,4));
  _objc_msgSend(self->_QTVRMovieBottomControlBox,sel_addSubview_,self->_movieBottomControlBarView);
  pvVar4 = _objc_msgSend(self,sel_movieObjectAttributes);
  pvVar4 = _objc_msgSend(pvVar4,sel_hyperConstraintValue_forAttribute_,&cfstr_Min,sel_hyperTiltAngle
                        );
  dVar7 = _objc_msgSend_fpret(pvVar4,sel_floatValue);
  self->_tiltAngleMin = (float)dVar7;
  pvVar4 = _objc_msgSend(self,sel_movieObjectAttributes);
  pcVar8 = &cfstr_Max;
  puVar9 = sel_hyperTiltAngle;
  pvVar4 = _objc_msgSend(pvVar4,sel_hyperConstraintValue_forAttribute_,&cfstr_Max,sel_hyperTiltAngle
                        );
  dVar7 = _objc_msgSend_fpret(pvVar4,sel_floatValue);
  self->_tiltAngleMax = (float)dVar7;
  dVar7 = _objc_msgSend_fpret(pvVar3,sel_hyperTiltAngle);
  fVar2 = (float)dVar7;
  self->_tiltAngle = fVar2;
  fVar1 = self->_tiltAngleMin;
  if ((fVar2 != 0.0) || (NAN(fVar2))) {
    fVar5 = ABS(fVar2);
  }
  else {
    fVar5 = 1.0;
  }
  if ((fVar1 != 0.0) || (NAN(fVar1))) {
    fVar6 = ABS(fVar1);
  }
  else {
    fVar6 = 1.0;
  }
  if (fVar6 <= fVar5) {
    fVar6 = fVar5;
  }
  if (fVar6 * -0.0005 + fVar1 <= fVar2) {
    fVar1 = self->_tiltAngleMax;
    if ((fVar2 != 0.0) || (NAN(fVar2))) {
      fVar5 = ABS(fVar2);
    }
    else {
      fVar5 = 1.0;
    }
    if ((fVar1 != 0.0) || (NAN(fVar1))) {
      fVar6 = ABS(fVar1);
    }
    else {
      fVar6 = 1.0;
    }
    if (fVar6 <= fVar5) {
      fVar6 = fVar5;
    }
    if (fVar2 <= fVar6 * 0.0005 + fVar1) goto LAB_00183a06;
  }
  self->_tiltAngle = fVar1;
LAB_00183a06:
  pvVar4 = _objc_msgSend(self,sel_movieObjectAttributes,pcVar8,puVar9);
  pvVar4 = _objc_msgSend(pvVar4,sel_hyperConstraintValue_forAttribute_,&cfstr_Min,sel_hyperPanAngle)
  ;
  dVar7 = _objc_msgSend_fpret(pvVar4,sel_floatValue);
  self->_panAngleMin = (float)dVar7;
  pvVar4 = _objc_msgSend(self,sel_movieObjectAttributes);
  pcVar8 = &cfstr_Max;
  puVar9 = sel_hyperPanAngle;
  pvVar4 = _objc_msgSend(pvVar4,sel_hyperConstraintValue_forAttribute_,&cfstr_Max,sel_hyperPanAngle)
  ;
  dVar7 = _objc_msgSend_fpret(pvVar4,sel_floatValue);
  self->_panAngleMax = (float)dVar7;
  dVar7 = _objc_msgSend_fpret(pvVar3,sel_hyperPanAngle);
  fVar2 = (float)dVar7;
  self->_panAngle = fVar2;
  fVar1 = self->_panAngleMin;
  if ((fVar2 != 0.0) || (NAN(fVar2))) {
    fVar5 = ABS(fVar2);
  }
  else {
    fVar5 = 1.0;
  }
  if ((fVar1 != 0.0) || (NAN(fVar1))) {
    fVar6 = ABS(fVar1);
  }
  else {
    fVar6 = 1.0;
  }
  if (fVar6 <= fVar5) {
    fVar6 = fVar5;
  }
  if (fVar6 * -0.0005 + fVar1 <= fVar2) {
    fVar1 = self->_panAngleMax;
    fVar2 = self->_fieldOfView;
    if ((fVar2 != 0.0) || (NAN(fVar2))) {
      fVar5 = ABS(fVar2);
    }
    else {
      fVar5 = 1.0;
    }
    if ((fVar1 != 0.0) || (NAN(fVar1))) {
      fVar6 = ABS(fVar1);
    }
    else {
      fVar6 = 1.0;
    }
    if (fVar6 <= fVar5) {
      fVar6 = fVar5;
    }
    if (fVar6 * 0.0005 + fVar1 < fVar2) {
      self->_panAngle = fVar1;
    }
  }
  else {
    self->_panAngle = fVar1;
  }
  pvVar4 = _objc_msgSend(self,sel_movieObjectAttributes,pcVar8,puVar9);
  pvVar4 = _objc_msgSend(pvVar4,sel_hyperConstraintValue_forAttribute_,&cfstr_Min,
                         sel_hyperFieldOfView);
  dVar7 = _objc_msgSend_fpret(pvVar4,sel_floatValue);
  self->_fieldOfViewMin = (float)dVar7;
  pvVar4 = _objc_msgSend(self,sel_movieObjectAttributes);
  pvVar4 = _objc_msgSend(pvVar4,sel_hyperConstraintValue_forAttribute_,&cfstr_Max,
                         sel_hyperFieldOfView);
  dVar7 = _objc_msgSend_fpret(pvVar4,sel_floatValue);
  self->_fieldOfViewMax = (float)dVar7;
  dVar7 = _objc_msgSend_fpret(pvVar3,sel_hyperFieldOfView);
  fVar2 = (float)dVar7;
  self->_fieldOfView = fVar2;
  fVar1 = self->_fieldOfViewMin;
  if ((fVar2 != 0.0) || (NAN(fVar2))) {
    fVar5 = ABS(fVar2);
  }
  else {
    fVar5 = 1.0;
  }
  if ((fVar1 != 0.0) || (NAN(fVar1))) {
    fVar6 = ABS(fVar1);
  }
  else {
    fVar6 = 1.0;
  }
  if (fVar6 <= fVar5) {
    fVar6 = fVar5;
  }
  if (fVar6 * -0.0005 + fVar1 <= fVar2) {
    fVar1 = self->_fieldOfViewMax;
    if ((fVar2 != 0.0) || (NAN(fVar2))) {
      fVar5 = ABS(fVar2);
    }
    else {
      fVar5 = 1.0;
    }
    if ((fVar1 != 0.0) || (NAN(fVar1))) {
      fVar6 = ABS(fVar1);
    }
    else {
      fVar6 = 1.0;
    }
    if (fVar6 <= fVar5) {
      fVar6 = fVar5;
    }
    if (fVar2 <= fVar6 * 0.0005 + fVar1) {
      return;
    }
  }
  self->_fieldOfView = fVar1;
  return;
}

*/
- (void)setupMovieUIConstrains
{
    id minVolume = [[self movieObjectAttributes] hyperConstraintValue:@"Min" forAttribute:@selector(hyperVolume)];
    id maxVolume = [[self movieObjectAttributes] hyperConstraintValue:@"Max" forAttribute:@selector(hyperVolume)];
    [_volumeSlider setMinValue:[minVolume floatValue]];
    [_volumeSlider setMaxValue:[maxVolume floatValue]];
    id attributes = [self movieObjectAttributes];
    if (![[self movieObjectAttributes] isHyperQTVR] && ![[self movieObjectAttributes] isHyperPanoramaObject]) {
        [_movieTypeTabView selectTabViewItemWithIdentifier:@"simpleMovie"];
        [_movieTopControlBarView removeFromSuperview];
        [_movieTopControlBarView setFrame:[_simpleMovieTopControlBox bounds]];
        [_simpleMovieTopControlBox addSubview:_movieTopControlBarView];
        [_movieBottomControlBarView removeFromSuperview];
        [_movieBottomControlBarView setFrame:[_simpleMovieBottomControlBox bounds]];
        [_simpleMovieBottomControlBox addSubview:_movieBottomControlBarView];
        return;
    }
    [_movieTypeTabView selectTabViewItemWithIdentifier:@"QTVRMovie"];
    [_movieTopControlBarView removeFromSuperview];
    [_movieTopControlBarView setFrame:[_QTVRMovieTopControlBox bounds]];
    [_QTVRMovieTopControlBox addSubview:_movieTopControlBarView];
    [_movieBottomControlBarView removeFromSuperview];
    [_movieBottomControlBarView setFrame:[_QTVRMovieBottomControlBox bounds]];
    [_QTVRMovieBottomControlBox addSubview:_movieBottomControlBarView];
    _tiltAngleMin = [[[self movieObjectAttributes] hyperConstraintValue:@"Min" forAttribute:@selector(hyperTiltAngle)] floatValue];
    _tiltAngleMax = [[[self movieObjectAttributes] hyperConstraintValue:@"Max" forAttribute:@selector(hyperTiltAngle)] floatValue];
    _tiltAngle = HSMovieAppearanceClamp([attributes hyperTiltAngle], _tiltAngleMin, _tiltAngleMax);
    _panAngleMin = [[[self movieObjectAttributes] hyperConstraintValue:@"Min" forAttribute:@selector(hyperPanAngle)] floatValue];
    _panAngleMax = [[[self movieObjectAttributes] hyperConstraintValue:@"Max" forAttribute:@selector(hyperPanAngle)] floatValue];
    /* The original compared the field of view against the pan maximum; clamp the pan angle itself. */
    _panAngle = HSMovieAppearanceClamp([attributes hyperPanAngle], _panAngleMin, _panAngleMax);
    _fieldOfViewMin = [[[self movieObjectAttributes] hyperConstraintValue:@"Min" forAttribute:@selector(hyperFieldOfView)] floatValue];
    _fieldOfViewMax = [[[self movieObjectAttributes] hyperConstraintValue:@"Max" forAttribute:@selector(hyperFieldOfView)] floatValue];
    _fieldOfView = HSMovieAppearanceClamp([attributes hyperFieldOfView], _fieldOfViewMin, _fieldOfViewMax);
}

- (void)stopObservingOfChangesInMovieObject
{
    int uVar1;
    id pvVar2_4;

    pvVar2_4 = [[[[self assistant] object] queryHyperInterface:@protocol(HSMutableObjectAttributes)] attributeObservingController];
    uVar1 = HSActualDidAttributeChanges;
    [pvVar2_4 removeObserver:self selector:@selector(validateUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSMutableObjectAttributes)];
    [pvVar2_4 removeObserver:self selector:@selector(validateMovieUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSMovieObjectAttributes)];
    [pvVar2_4 removeObserver:self selector:@selector(validateOpacityUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSMutableOpacityAttributes)];
    [pvVar2_4 removeObserver:self selector:@selector(validateShadowAttributesWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSShadowAttributes)];
    [pvVar2_4 removeObserver:self selector:@selector(HSMovieObjectAppearanceAssistantPane_transparentColorEnablementDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSTransparentColorEnabledAttribute)];
    [_transparentColorAttributes release];
    _transparentColorAttributes = nil;
}

- (void)startObservingOfChangesInMovieObject
{
    int uVar1;
    id pvVar2_2;
    id pvVar3_2;

    pvVar2_2 = [[self assistant] object];
    pvVar3_2 = [[pvVar2_2 queryHyperInterface:@protocol(HSMutableObjectAttributes)] attributeObservingController];
    _transparentColorAttributes = [[pvVar2_2 queryHyperInterface:@protocol(HSTransparentColorAttributes)] retain];
    uVar1 = HSActualDidAttributeChanges;
    [pvVar3_2 addObserver:self selector:@selector(validateUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSMutableObjectAttributes) withPriority:-0.25];
    [pvVar3_2 addObserver:self selector:@selector(validateMovieUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSMovieObjectAttributes) withPriority:-0.25];
    [pvVar3_2 addObserver:self selector:@selector(validateOpacityUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSMutableOpacityAttributes) withPriority:-0.25];
    [pvVar3_2 addObserver:self selector:@selector(validateShadowAttributesWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSShadowAttributes) withPriority:-0.25];
    [pvVar3_2 addObserver:self selector:@selector(HSMovieObjectAppearanceAssistantPane_transparentColorEnablementDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSTransparentColorEnabledAttribute) withPriority:-0.25];
}

- (void)hyperCustomSliderDidFinishTracking:(id)aTracking
{
    _volumeSliderIsTracking = NO;
}

- (void)hyperCustomSliderDidStartTracking:(id)aTracking
{
    _volumeSliderIsTracking = YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00183068 @ 00183068, 237 bytes * /

id FUN_00183068(HSMovieObjectAppearanceAssistantPane *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  
  pvVar1 = self->_importMoviesDialogController;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_HSImportDialogController,sel_alloc);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithDialogType_,*(undefined4 *)PTR_PTR_00336670);
    self->_importMoviesDialogController = pvVar1;
    self_00 = cls_HSImportDialogController;
    pvVar2 = _objc_msgSend(self,sel_assistant);
    pvVar2 = _objc_msgSend(pvVar2,sel_object);
    pvVar2 = _objc_msgSend(self_00,sel_defaultButtonTitleForObject_,pvVar2);
    _objc_msgSend(pvVar1,sel_setDefaultButtonTitle_,pvVar2);
    _objc_msgSend(self->_importMoviesDialogController,sel_setHelpTopicKey_,&cfstr_HSMovieSettings);
    pvVar1 = self->_importMoviesDialogController;
  }
  return pvVar1;
}

*/
- (id)importMoviesDialogController
{
    if (_importMoviesDialogController == nil) {
        _importMoviesDialogController = [[HSImportDialogController alloc] initWithDialogType:HSImportDialogControllerTypeMovies];
        [_importMoviesDialogController setDefaultButtonTitle:[HSImportDialogController defaultButtonTitleForObject:[[self assistant] object]]];
        [_importMoviesDialogController setHelpTopicKey:@"HSMovieSettings"];
    }
    return _importMoviesDialogController;
}

- (void)validateQTRVController
{
    float fVar1;
    float fVar2;
    float fVar3;
    float fVar4;
    float fVar1_2;
    float fVar2_2;
    float fVar3_2;
    float fVar4_2;

    fVar1 = _fieldOfView;
    fVar2 = _fieldOfViewMax;
    fVar3 = fVar1 != 0.0 ? fabs(fVar1) : 1.0;
    fVar4 = fVar2 != 0.0 ? fabs(fVar2) : 1.0;
    if (fVar4 <= fVar3) {
        fVar4 = fVar3;
    }
    [_zoomOutButton setEnabled:(unsigned int)(fVar1 < fVar2 + fVar4 * -0.0005)];
    fVar1_2 = _fieldOfView;
    fVar2_2 = _fieldOfViewMin;
    fVar3_2 = fVar1_2 != 0.0 ? fabs(fVar1_2) : 1.0;
    fVar4_2 = fVar2_2 != 0.0 ? fabs(fVar2_2) : 1.0;
    if (fVar4_2 <= fVar3_2) {
        fVar4_2 = fVar3_2;
    }
    [_zoomInButton setEnabled:(unsigned int)(fVar4_2 * 0.0005 + fVar2_2 < fVar1_2)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00182ee8 @ 00182ee8, 94 bytes * /

void FUN_00182ee8(HSMovieObjectAppearanceAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_playableObjectAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_isHyperPlaying);
  op = sel_setUpPlayButton;
  if ((char)pvVar1 != '\0') {
    op = sel_setUpPauseButton;
  }
  _objc_msgSend(self,op);
  return;
}

*/
- (void)validatePlayButtonState
{
    if ([[self playableObjectAttributes] isHyperPlaying]) {
        [self setUpPauseButton];
    } else {
        [self setUpPlayButton];
    }
}

- (void)updateShadow
{
    char cVar1;
    NSString *pcVar3;

    cVar1 = [[self shadowAttributes] isHyperShadowEnabled];
    [_shadowSwitch setState:cVar1];
    [_shadowButton setHidden:((unsigned int)(cVar1 == NO))];
    if (cVar1 == NO) {
        pcVar3 = [_shadowButton title];
    }
    else {
        pcVar3 = @"";
    }
    [_shadowSwitch setTitle:pcVar3];
}

- (void)validateOpacityUI
{
    float fVar1;

    fVar1 = (float)[[self opacityAttributes] hyperOpacity] * 100.0;
    [_opacitySlider setFloatValue:fVar1];
    [_opacityTextField setFloatValue:fVar1];
    [_opacityStepper setFloatValue:fVar1];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00183f41 @ 00183f41, 808 bytes * /

void FUN_00183f41(HSMovieObjectAppearanceAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  uint uVar2;
  int iVar3;
  bool bVar4;
  double dVar5;
  double local_24;
  double local_1c;
  
  pvVar1 = _objc_msgSend(self,sel_movieObjectAttributes);
  dVar5 = _objc_msgSend_fpret(pvVar1,sel_hyperVolume);
  if (self->_volumeSliderIsTracking == '\0') {
    pvVar1 = self->_volumeSlider;
    _HSLinearValueForSliderFromNonLinear(pvVar1,(float)dVar5 * 100.0);
    _objc_msgSend(pvVar1,sel_setFloatValue_);
  }
  _objc_msgSend(self->_volumeTextField,sel_setFloatValue_);
  _objc_msgSend(self->_volumeStepper,sel_setFloatValue_);
  _objc_msgSend(self,sel_validatePlayButtonState);
  pvVar1 = _objc_msgSend(self,sel_assistant);
  pvVar1 = _objc_msgSend(pvVar1,sel_object);
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_);
  pvVar1 = _objc_msgSend(pvVar1,sel_isHyperEmpty);
  bVar4 = (char)pvVar1 == '\0';
  if (bVar4) {
    pvVar1 = _objc_msgSend(self,sel_movieObjectAttributes);
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperMovie);
    pvVar1 = _objc_msgSend(pvVar1,sel_hasSound);
    if ((char)pvVar1 != '\0') {
      uVar2 = 0x101;
      goto LAB_001840ae;
    }
  }
  uVar2 = (uint)bVar4;
LAB_001840ae:
  pvVar1 = _objc_msgSend(self,sel_playableObjectAttributes);
  _objc_msgSend_stret(&local_24,pvVar1,sel_hyperPlayRange);
  pvVar1 = self->_rangeControl;
  self_00 = _objc_msgSend(self,sel_playableObjectAttributes);
  dVar5 = _objc_msgSend_fpret(self_00,sel_hyperDuration);
  _objc_msgSend(pvVar1,sel_setDuration_,dVar5);
  _objc_msgSend(self->_rangeControl,sel_setStartTime_,local_24);
  _objc_msgSend(self->_rangeControl,sel_setFinishTime_,local_24 + local_1c);
  _objc_msgSend(self->_rangeControl,sel_setEnabled_,uVar2 & 0xff);
  _objc_msgSend(self->_playButton,sel_setEnabled_,uVar2 & 0xff);
  iVar3 = (int)(char)(uVar2 >> 8);
  _objc_msgSend(self->_volumeSlider,sel_setEnabled_,iVar3);
  _objc_msgSend(self->_volumeInButton,sel_setEnabled_,iVar3);
  _objc_msgSend(self->_volumeOutButton,sel_setEnabled_,iVar3);
  _objc_msgSend(self->_volumeStepper,sel_setEnabled_,iVar3);
  _objc_msgSend(self->_volumeTextField,sel_setEnabled_,iVar3);
  _objc_msgSend(self,sel_validateMovieControllerState);
  _objc_msgSend(self,sel_validateQTRVController);
  return;
}

*/
- (void)validateMovieUI
{
    float volume = [[self movieObjectAttributes] hyperVolume] * 100.0f;
    if (!_volumeSliderIsTracking) {
        [_volumeSlider setFloatValue:HSLinearValueForSliderFromNonLinear(_volumeSlider, volume)];
    }
    [_volumeTextField setFloatValue:volume];
    [_volumeStepper setFloatValue:volume];
    [self validatePlayButtonState];
    BOOL hasMovie = ![[[[self assistant] object] queryHyperInterface:@protocol(HSMovieObjectBaseIsEmptyAttribute)] isHyperEmpty];
    BOOL hasSound = hasMovie && [[[self movieObjectAttributes] hyperMovie] hasSound];
    struct HSTimeRange playRange = [[self playableObjectAttributes] hyperPlayRange];
    [_rangeControl setDuration:[[self playableObjectAttributes] hyperDuration]];
    [_rangeControl setStartTime:playRange.location];
    [_rangeControl setFinishTime:playRange.location + playRange.length];
    [_rangeControl setEnabled:hasMovie];
    [_playButton setEnabled:hasMovie];
    [_volumeSlider setEnabled:hasSound];
    [_volumeInButton setEnabled:hasSound];
    [_volumeOutButton setEnabled:hasSound];
    [_volumeStepper setEnabled:hasSound];
    [_volumeTextField setEnabled:hasSound];
    [self validateMovieControllerState];
    [self validateQTRVController];
}

- (void)validateMovieControllerState
{
    [_movieControlSwitch setState:(unsigned int)([[self movieObjectAttributes] hyperHasController])];
}

- (void)validateObjectAttributesUI
{
    id pvVar1_3;

    pvVar1_3 = [[[self assistant] object] queryHyperInterface:@protocol(HSMutableObjectAttributes)];
    if (pvVar1_3 != nil) {
        [_nameTextField setStringValue:[pvVar1_3 hyperName]];
    }
}

- (void)validateUserInterface
{
    [self validateObjectAttributesUI];
    [self validateOpacityUI];
    [self updateShadow];
    [self validateMovieUI];
}

- (void)validateMovieUIWithNotification:(id)aNotification
{
    if ([[aNotification attributeProtocolSet] containsProtocol:@protocol(HSMediaAttribute)]) {
        [self setupMovieUIConstrains];
    }
    [self validateMovieUI];
}

- (void)validateOpacityUIWithNotification:(id)aNotification
{
    [self validateOpacityUI];
}

- (void)validateShadowAttributesWithNotification:(id)aNotification
{
    [self updateShadow];
}

- (void)validateUIWithNotification:(id)aNotification
{
    [self validateObjectAttributesUI];
}

- (void)HSMovieObjectAppearanceAssistantPane_transparentColorEnablementDidChange:(id)aChange
{
    [self HSMovieObjectAppearanceAssistantPane_validatetransparentColorSwitchAndButton];
}

- (void)hyperPlayableObjectDidStop:(id)aStop
{
    [self setUpPlayButton];
}

- (void)stopMovie
{
    [[self playableObjectAttributes] hyperStop];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00182a00 @ 00182a00, 361 bytes * /

void FUN_00182a00(HSMovieObjectAppearanceAssistantPane *self,SEL _cmd,id setMovieWithPathOrAlert)

{
  id pvVar1;
  id pvVar2;
  id *ppvVar3;
  SEL op;
  undefined4 uVar4;
  undefined4 uVar5;
  id local_10;
  
  pvVar1 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
  pvVar2 = setMovieWithPathOrAlert;
  pvVar1 = _objc_msgSend(pvVar1,sel_fileExistsAtPath_,setMovieWithPathOrAlert);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(cls_NSFileManager,sel_defaultManager,pvVar2);
    uVar5 = 0;
    uVar4 = 1;
    pvVar2 = setMovieWithPathOrAlert;
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperIsReadableFileAtPath_showAlert_error_,
                           setMovieWithPathOrAlert,1,0);
    if ((char)pvVar1 != '\0') {
      local_10 = (id)0x0;
      _objc_msgSend(self,sel_stopMovie,pvVar2,uVar4,uVar5);
      _objc_msgSend(self,sel_stopObservingOfChangesInMovieObject);
      pvVar2 = _objc_msgSend(self,sel_movieObjectAttributes);
      ppvVar3 = &local_10;
      _objc_msgSend(pvVar2,sel_setHyperMovieWithPath_error_,setMovieWithPathOrAlert,ppvVar3);
      if (local_10 == (id)0x0) {
        _objc_msgSend(self,sel_startObservingOfChangesInMovieObject,setMovieWithPathOrAlert,ppvVar3)
        ;
        op = sel_setupMovieUIConstrains;
      }
      else {
        self = _objc_msgSend(cls_HSErrorManager,sel_sharedErrorManager,setMovieWithPathOrAlert,
                             ppvVar3);
        ppvVar3 = _objc_msgSend(*(id *)PTR_00336058,sel_keyWindow);
        op = sel_presentError_inWindow_;
        setMovieWithPathOrAlert = local_10;
      }
      _objc_msgSend(self,op,setMovieWithPathOrAlert,ppvVar3);
    }
  }
  return;
}

*/
- (void)setMovieWithPathOrAlert:(id)aAlert
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:aAlert]) {
        return;
    }
    if (![[NSFileManager defaultManager] hyperIsReadableFileAtPath:aAlert showAlert:YES error:NULL]) {
        return;
    }
    id error = nil;
    [self stopMovie];
    [self stopObservingOfChangesInMovieObject];
    [[self movieObjectAttributes] setHyperMovieWithPath:aAlert error:&error];
    if (error == nil) {
        [self startObservingOfChangesInMovieObject];
        [self setupMovieUIConstrains];
    } else {
        [[HSErrorManager sharedErrorManager] presentError:error inWindow:[NSApp keyWindow]];
    }
}

- (void)setUpPauseButton
{
    [_playButton setImage:_stopImage];
    [_playButton setAlternateImage:_pressedStopImage];
}

- (void)setUpPlayButton
{
    [_playButton setImage:_playImage];
    [_playButton setAlternateImage:_pressedPlayImage];
}

- (void)zoomOut:(id)aOut
{
    float fVar1;
    float fVar2;
    float fVar4;
    float fVar5;

    fVar1 = _fieldOfView;
    fVar2 = _fieldOfViewMax;
    fVar4 = fVar1 != 0.0 ? fabs(fVar1) : 1.0;
    fVar5 = fVar2 != 0.0 ? fabs(fVar2) : 1.0;
    if (fVar5 <= fVar4) {
        fVar5 = fVar4;
    }
    if (fVar1 < fVar2 + fVar5 * -0.0005) {
        _fieldOfView = fVar1 + 5.0;
        [[self movieObjectAttributes] setHyperFieldOfView:_fieldOfView];
        _fieldOfView = (float)[[self movieObjectAttributes] hyperFieldOfView];
        _panAngle = (float)[[self movieObjectAttributes] hyperPanAngle];
        _tiltAngle = (float)[[self movieObjectAttributes] hyperTiltAngle];
        [self validateQTRVController];
    }
}

- (void)zoomIn:(id)aIn
{
    float fVar1;
    float fVar2;
    float fVar4;
    float fVar5;

    fVar1 = _fieldOfView;
    fVar2 = _fieldOfViewMin;
    fVar4 = fVar1 != 0.0 ? fabs(fVar1) : 1.0;
    fVar5 = fVar2 != 0.0 ? fabs(fVar2) : 1.0;
    if (fVar5 <= fVar4) {
        fVar5 = fVar4;
    }
    if (fVar5 * 0.0005 + fVar2 < fVar1) {
        _fieldOfView = fVar1 + -5.0;
        [[self movieObjectAttributes] setHyperFieldOfView:_fieldOfView];
        _fieldOfView = (float)[[self movieObjectAttributes] hyperFieldOfView];
        _panAngle = (float)[[self movieObjectAttributes] hyperPanAngle];
        _tiltAngle = (float)[[self movieObjectAttributes] hyperTiltAngle];
        [self validateQTRVController];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018450f @ 0018450f, 607 bytes * /

void FUN_0018450f(HSMovieObjectAppearanceAssistantPane *self,SEL _cmd,id moveRight)

{
  float fVar1;
  id pvVar2;
  float fVar3;
  float fVar4;
  float fVar5;
  double dVar6;
  
  fVar3 = self->_panAngleMax;
  if ((fVar3 != 0.0) || (NAN(fVar3))) {
    fVar4 = ABS(fVar3);
  }
  else {
    fVar4 = 1.0;
  }
  if (fVar4 <= 360.0) {
    fVar4 = 360.0;
  }
  fVar1 = self->_panAngleMin;
  if (ABS(360.0 - fVar3) <= fVar4 * 0.0005) {
    if ((fVar1 != 0.0) || (NAN(fVar1))) {
      fVar3 = ABS(fVar1);
    }
    else {
      fVar3 = 1.0;
    }
    fVar4 = fVar3 * 0.0005;
    if (fVar3 <= 1.0) {
      fVar4 = 0.0005;
    }
    if (ABS(0.0 - fVar1) <= fVar4) {
      fVar3 = self->_panAngle + -5.0;
      self->_panAngle = fVar3;
      if ((fVar3 != 0.0) || (NAN(fVar3))) {
        fVar4 = ABS(fVar3);
      }
      else {
        fVar4 = 1.0;
      }
      if ((fVar1 != 0.0) || (NAN(fVar1))) {
        fVar5 = ABS(fVar1);
      }
      else {
        fVar5 = 1.0;
      }
      if (fVar5 <= fVar4) {
        fVar5 = fVar4;
      }
      if (fVar3 < fVar1 + fVar5 * -0.0005) {
        self->_panAngle = 360.0 - ABS(fVar3);
      }
      pvVar2 = _objc_msgSend(self,sel_movieObjectAttributes);
      _objc_msgSend(pvVar2,sel_setHyperPanAngle_,self->_panAngle);
      pvVar2 = _objc_msgSend(self,sel_movieObjectAttributes);
      goto LAB_00184699;
    }
  }
  fVar3 = self->_panAngle;
  if ((fVar3 != 0.0) || (NAN(fVar3))) {
    fVar4 = ABS(fVar3);
  }
  else {
    fVar4 = 1.0;
  }
  if ((fVar1 != 0.0) || (NAN(fVar1))) {
    fVar5 = ABS(fVar1);
  }
  else {
    fVar5 = 1.0;
  }
  if (fVar5 <= fVar4) {
    fVar5 = fVar4;
  }
  if (fVar3 <= fVar5 * 0.0005 + fVar1) {
    return;
  }
  self->_panAngle = fVar3 + -5.0;
  pvVar2 = _objc_msgSend(self,sel_movieObjectAttributes);
  _objc_msgSend(pvVar2,sel_setHyperPanAngle_,self->_panAngle);
  pvVar2 = _objc_msgSend(self,sel_movieObjectAttributes);
LAB_00184699:
  dVar6 = _objc_msgSend_fpret(pvVar2,sel_hyperPanAngle);
  self->_panAngle = (float)dVar6;
  return;
}

*/
- (void)moveRight:(id)aRight
{
    float panMax = _panAngleMax;
    float panMin = _panAngleMin;
    BOOL isFullCircle = fabsf(360.0f - panMax) <= MAX(panMax != 0.0f ? fabsf(panMax) : 1.0f, 360.0f) * 0.0005f
        && fabsf(0.0f - panMin) <= MAX(panMin != 0.0f ? fabsf(panMin) : 1.0f, 1.0f) * 0.0005f;
    if (isFullCircle) {
        /* A full panorama wraps around. */
        _panAngle = _panAngle + -5.0f;
        if (_panAngle < panMin - HSMovieAppearanceTolerance(_panAngle, panMin)) {
            _panAngle = 360.0f - fabsf(_panAngle);
        }
    } else {
        if (_panAngle <= panMin + HSMovieAppearanceTolerance(_panAngle, panMin)) {
            return;
        }
        _panAngle = _panAngle + -5.0f;
    }
    [[self movieObjectAttributes] setHyperPanAngle:_panAngle];
    _panAngle = [[self movieObjectAttributes] hyperPanAngle];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018476e @ 0018476e, 492 bytes * /

void FUN_0018476e(HSMovieObjectAppearanceAssistantPane *self,SEL _cmd,id moveLeft)

{
  id pvVar1;
  float fVar2;
  float fVar3;
  float fVar4;
  float fVar5;
  double dVar6;
  
  fVar5 = self->_panAngleMax;
  if ((fVar5 != 0.0) || (NAN(fVar5))) {
    fVar2 = ABS(fVar5);
  }
  else {
    fVar2 = 1.0;
  }
  if (fVar2 <= 360.0) {
    fVar2 = 360.0;
  }
  fVar3 = self->_panAngle;
  if (fVar2 * 0.0005 < ABS(360.0 - fVar5)) {
    if ((fVar3 != 0.0) || (NAN(fVar3))) {
      fVar2 = ABS(fVar3);
    }
    else {
      fVar2 = 1.0;
    }
    if ((fVar5 != 0.0) || (NAN(fVar5))) {
      fVar4 = ABS(fVar5);
    }
    else {
      fVar4 = 1.0;
    }
    if (fVar4 <= fVar2) {
      fVar4 = fVar2;
    }
    if (fVar5 + fVar4 * -0.0005 <= fVar3) {
      return;
    }
    self->_panAngle = fVar3 + 5.0;
    pvVar1 = _objc_msgSend(self,sel_movieObjectAttributes);
    _objc_msgSend(pvVar1,sel_setHyperPanAngle_,self->_panAngle);
    pvVar1 = _objc_msgSend(self,sel_movieObjectAttributes);
  }
  else {
    fVar3 = fVar3 + 5.0;
    self->_panAngle = fVar3;
    while( true ) {
      if ((fVar3 != 0.0) || (NAN(fVar3))) {
        fVar5 = ABS(fVar3);
      }
      else {
        fVar5 = 1.0;
      }
      fVar2 = 360.0;
      if (360.0 <= fVar5) {
        fVar2 = fVar5;
      }
      if (fVar3 <= fVar2 * 0.0005 + 360.0) break;
      fVar3 = fVar3 + -360.0;
    }
    self->_panAngle = fVar3;
    pvVar1 = _objc_msgSend(self,sel_movieObjectAttributes);
    _objc_msgSend(pvVar1,sel_setHyperPanAngle_,self->_panAngle);
    pvVar1 = _objc_msgSend(self,sel_movieObjectAttributes);
  }
  dVar6 = _objc_msgSend_fpret(pvVar1,sel_hyperPanAngle);
  self->_panAngle = (float)dVar6;
  return;
}

*/
- (void)moveLeft:(id)aLeft
{
    float panMax = _panAngleMax;
    if (MAX(panMax != 0.0f ? fabsf(panMax) : 1.0f, 360.0f) * 0.0005f < fabsf(360.0f - panMax)) {
        if (_panAngle >= panMax - HSMovieAppearanceTolerance(_panAngle, panMax)) {
            return;
        }
        _panAngle = _panAngle + 5.0f;
    } else {
        /* A full panorama wraps around. */
        float angle = _panAngle + 5.0f;
        while (angle > MAX(angle != 0.0f ? fabsf(angle) : 1.0f, 360.0f) * 0.0005f + 360.0f) {
            angle = angle + -360.0f;
        }
        _panAngle = angle;
    }
    [[self movieObjectAttributes] setHyperPanAngle:_panAngle];
    _panAngle = [[self movieObjectAttributes] hyperPanAngle];
}

- (void)moveDown:(id)aDown
{
    float fVar1;
    float fVar2;
    float fVar4;
    float fVar5;

    fVar1 = _tiltAngle;
    fVar2 = _tiltAngleMin;
    fVar4 = fVar1 != 0.0 ? fabs(fVar1) : 1.0;
    fVar5 = fVar2 != 0.0 ? fabs(fVar2) : 1.0;
    if (fVar5 <= fVar4) {
        fVar5 = fVar4;
    }
    if (fVar5 * 0.0005 + fVar2 < fVar1) {
        _tiltAngle = fVar1 + -5.0;
        [[self movieObjectAttributes] setHyperTiltAngle:_tiltAngle];
        _tiltAngle = (float)[[self movieObjectAttributes] hyperTiltAngle];
    }
}

- (void)moveUp:(id)aUp
{
    float fVar1;
    float fVar2;
    float fVar4;
    float fVar5;

    fVar1 = _tiltAngle;
    fVar2 = _tiltAngleMax;
    fVar4 = fVar1 != 0.0 ? fabs(fVar1) : 1.0;
    fVar5 = fVar2 != 0.0 ? fabs(fVar2) : 1.0;
    if (fVar5 <= fVar4) {
        fVar5 = fVar4;
    }
    if (fVar1 < fVar2 + fVar5 * -0.0005) {
        _tiltAngle = fVar1 + 5.0;
        [[self movieObjectAttributes] setHyperTiltAngle:_tiltAngle];
        _tiltAngle = (float)[[self movieObjectAttributes] hyperTiltAngle];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001828c1 @ 001828c1, 116 bytes * /

void FUN_001828c1(HSMovieObjectAppearanceAssistantPane *self,SEL _cmd,id move)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(move,sel_intValue);
  switch(pvVar1) {
  case (id)0x1:
    op = sel_moveLeft_;
    break;
  case (id)0x2:
    op = sel_moveRight_;
    break;
  case (id)0x3:
    op = sel_moveUp_;
    break;
  case (id)0x4:
    op = sel_moveDown_;
    break;
  default:
    goto switchD_001828f6_default;
  }
  _objc_msgSend(self,op,move);
switchD_001828f6_default:
  return;
}

*/
- (void)move:(id)aMove
{
    switch ([aMove intValue]) {
    case 1:
        [self moveLeft:aMove];
        break;
    case 2:
        [self moveRight:aMove];
        break;
    case 3:
        [self moveUp:aMove];
        break;
    case 4:
        [self moveDown:aMove];
        break;
    }
}

- (void)editTransparentColor:(id)aColor
{
    id pvVar1_2;
    id pvVar2_2;

    pvVar1_2 = [[HSTransparentColorAssistantPane alloc] init];
    if (pvVar1_2 != nil) {
        pvVar2_2 = [[HSObjectAssistantNavigationController alloc] initWithRootViewController:pvVar1_2];
        [pvVar1_2 release];
        if (pvVar2_2 != nil) {
            [self presentModalViewController:pvVar2_2 animated:YES];
            [pvVar2_2 release];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018275d @ 0018275d, 164 bytes * /

void FUN_0018275d(HSMovieObjectAppearanceAssistantPane *self,SEL _cmd,id setTransparentColor)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(setTransparentColor,sel_state);
  if (pvVar1 == (id)0x0) {
    self = self->_transparentColorAttributes;
    setTransparentColor = (id)0x0;
    op = sel_setTransparentColorEnabled_;
  }
  else {
    if (pvVar1 != (id)0x1) {
      return;
    }
    pvVar1 = _objc_msgSend(self->_transparentColorAttributes,sel_transparentColor);
    op = sel_editTransparentColor_;
    if (pvVar1 != (id)0x0) {
      self = self->_transparentColorAttributes;
      setTransparentColor = (id)0x1;
      op = sel_setTransparentColorEnabled_;
    }
  }
  _objc_msgSend(self,op,setTransparentColor);
  return;
}

*/
- (void)setTransparentColor:(id)aColor
{
    NSInteger state = [aColor state];
    if (state == NSControlStateValueOff) {
        [_transparentColorAttributes setTransparentColorEnabled:NO];
    } else if (state == NSControlStateValueOn) {
        if ([_transparentColorAttributes transparentColor] != nil) {
            [_transparentColorAttributes setTransparentColorEnabled:YES];
        } else {
            [self editTransparentColor:aColor];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00182510 @ 00182510, 589 bytes * /

void FUN_00182510(HSMovieObjectAppearanceAssistantPane *self,SEL _cmd,id getFile)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  undefined *puVar3;
  id pvVar4;
  undefined *self_01;
  undefined4 uVar5;
  undefined4 uVar6;
  
  self_00 = _objc_msgSend(self,sel_importMoviesDialogController);
  if (self_00 != (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSDocumentController,sel_sharedDocumentController);
    pvVar1 = _objc_msgSend(pvVar1,sel_currentDocument);
    _objc_msgSend(self_00,sel_setHyperDocument_,pvVar1);
    pvVar2 = _objc_msgSend(self_00,sel_runModal);
    if (pvVar2 == (id)0x1) {
      pvVar2 = _objc_msgSend(self_00,sel_fileName,pvVar1);
      if (pvVar2 != (id)0x0) {
        pvVar1 = _objc_msgSend(cls_HSMovieVerifier,sel_new,pvVar1);
        puVar3 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_,pvVar2);
        uVar6 = 0;
        uVar5 = 0;
        pvVar2 = _objc_msgSend(pvVar1,sel_verifyMovieAtURL_withOptions_error_,puVar3,0,0);
        if (pvVar2 != (id)0x0) {
          pvVar4 = _objc_msgSend(pvVar2,sel_path,puVar3,uVar5,uVar6);
          _objc_msgSend(self,sel_setMovieWithPathOrAlert_,pvVar4);
          self_01 = _objc_msgSend(cls_HSEditorCardViewDragHelper,
                                  sel_commentsForDroppedObjectWithURL_,pvVar2);
          pvVar2 = _objc_msgSend(self,sel_assistant);
          pvVar2 = _objc_msgSend(pvVar2,sel_object);
          puVar3 = &DAT_00379534;
          pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_00379534);
          if (self_01 != (undefined *)0x0) {
            pvVar4 = _objc_msgSend(self_01,sel_length,puVar3);
            if (pvVar4 != (id)0x0) {
              pvVar4 = _objc_msgSend(pvVar2,sel_hyperComments,puVar3);
              puVar3 = self_01;
              pvVar4 = _objc_msgSend(pvVar4,sel_hasHyperSubstring_,self_01);
              if (pvVar4 == (id)0x0) {
                _objc_msgSend(pvVar2,sel_appendHyperComments_,self_01);
                puVar3 = self_01;
              }
            }
          }
        }
        _objc_msgSend(pvVar1,sel_release,puVar3,uVar5,uVar6);
      }
    }
    _objc_msgSend(self_00,sel_setHyperDocument_,0);
  }
  _objc_msgSend(self,sel_validateUserInterface);
  return;
}

*/
- (void)getFile:(id)aFile
{
    HSImportDialogController *dialog = [self importMoviesDialogController];
    if (dialog != nil) {
        [dialog setHyperDocument:[[NSDocumentController sharedDocumentController] currentDocument]];
        if ([dialog runModal] == 1) {
            NSString *fileName = [dialog fileName];
            if (fileName != nil) {
                HSMovieVerifier *verifier = [HSMovieVerifier new];
                NSURL *movieURL = [verifier verifyMovieAtURL:[NSURL fileURLWithPath:fileName] withOptions:0 error:NULL];
                if (movieURL != nil) {
                    [self setMovieWithPathOrAlert:[movieURL path]];
                    NSString *comments = [HSEditorCardViewDragHelper commentsForDroppedObjectWithURL:movieURL];
                    id commentsAttributes = [[[self assistant] object] queryHyperInterface:@protocol(HSCommentsAttributes)];
                    if (comments != nil && [comments length] != 0 && ![[commentsAttributes hyperComments] hasHyperSubstring:comments]) {
                        [commentsAttributes appendHyperComments:comments];
                    }
                }
                [verifier release];
            }
        }
        [dialog setHyperDocument:nil];
    }
    [self validateUserInterface];
}

- (void)useMovieControl:(id)aControl
{
    [[self movieObjectAttributes] setHyperHasController:(unsigned int)([aControl state] == 0x1)];
}

- (void)editShadow:(id)aShadow
{
    [self showShadowPane];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001823bb @ 001823bb, 207 bytes * /

void FUN_001823bb(HSMovieObjectAppearanceAssistantPane *self,SEL _cmd,id setShadow)

{
  id pvVar1;
  SEL op;
  undefined4 uVar2;
  
  pvVar1 = _objc_msgSend(setShadow,sel_state);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_shadowAttributes);
    uVar2 = 0;
    op = sel_setHyperShadowEnabled_;
  }
  else {
    if (pvVar1 != (id)0x1) {
      return;
    }
    pvVar1 = _objc_msgSend(self,sel_shadowAttributes);
    _objc_msgSend(pvVar1,sel_setHyperShadowEnabled_,1);
    _objc_msgSend(self->_shadowButton,sel_setHidden_,0);
    pvVar1 = self->_shadowButton;
    uVar2 = 1;
    op = sel_setEnabled_;
  }
  _objc_msgSend(pvVar1,op,uVar2);
  return;
}

*/
- (void)setShadow:(id)aShadow
{
    NSInteger state = [aShadow state];
    if (state == NSControlStateValueOff) {
        [[self shadowAttributes] setHyperShadowEnabled:NO];
    } else if (state == NSControlStateValueOn) {
        [[self shadowAttributes] setHyperShadowEnabled:YES];
        [_shadowButton setHidden:NO];
        [_shadowButton setEnabled:YES];
    }
}

- (void)showShadowPane
{
    id pvVar1_2;
    id pvVar1_3;

    pvVar1_2 = [[HSTextShadowAssistantPane new] autorelease];
    pvVar1_3 = [[HSObjectAssistantNavigationController alloc] initWithRootViewController:pvVar1_2];
    [self presentModalViewController:pvVar1_3 animated:YES];
    [pvVar1_3 release];
}

- (void)opacityChanged:(id)aChanged
{
    double dVar1;

    dVar1 = [aChanged floatValue];
    [[self opacityAttributes] setHyperOpacity:(float)dVar1 / 100.0];
}

- (void)rightRangeKnobActivated:(id)aActivated
{
    if (_rangeControl == aActivated) {
        if (![[self playableObjectAttributes] isHyperPlaying]) {
            [[self playableObjectAttributes] setHyperCurrentTime:[_rangeControl finishTime]];
        }
    }
}

- (void)leftRangeKnobActivated:(id)aActivated
{
    if (_rangeControl == aActivated) {
        if (![[self playableObjectAttributes] isHyperPlaying]) {
            [[self playableObjectAttributes] setHyperCurrentTime:[_rangeControl startTime]];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00184ca3 @ 00184ca3, 561 bytes * /

void FUN_00184ca3(HSMovieObjectAppearanceAssistantPane *self,SEL _cmd,id rangeChanged)

{
  id self_00;
  id pvVar1;
  float fVar2;
  float fVar3;
  float fVar4;
  float fVar5;
  double dVar6;
  double dVar7;
  double dVar8;
  double local_24;
  double local_1c;
  
  self_00 = _objc_msgSend(self,sel_playableObjectAttributes);
  dVar6 = _objc_msgSend_fpret(self->_rangeControl,sel_startTime);
  dVar7 = _objc_msgSend_fpret(self->_rangeControl,sel_finishTime);
  dVar8 = _objc_msgSend_fpret(self->_rangeControl,sel_startTime);
  _objc_msgSend_stret(&local_24,self_00,sel_hyperPlayRange);
  dVar7 = dVar7 - dVar8;
  _objc_msgSend(self_00,sel_setHyperPlayRange_,dVar6,dVar7);
  pvVar1 = _objc_msgSend(self,
                         sel_HSMovieObjectAppearanceAssistantPane_playMovieActionItemForCurrentObject
                        );
  dVar8 = dVar7;
  _objc_msgSend(pvVar1,sel_setPlayRange_,dVar6,dVar7);
  pvVar1 = _objc_msgSend(self_00,sel_isHyperPlaying);
  if ((char)pvVar1 == '\0') {
    fVar3 = (float)local_24;
    fVar2 = (float)dVar6;
    if ((fVar3 != 0.0) || (NAN(fVar3))) {
      fVar4 = ABS(fVar3);
    }
    else {
      fVar4 = 1.0;
    }
    if ((fVar2 != 0.0) || (NAN(fVar2))) {
      fVar5 = ABS(fVar2);
    }
    else {
      fVar5 = 1.0;
    }
    if (fVar5 <= fVar4) {
      fVar5 = fVar4;
    }
    if (ABS(fVar3 - fVar2) <= fVar5 * 0.0005) {
      fVar3 = (float)local_1c;
      fVar2 = (float)dVar7;
      if ((fVar3 != 0.0) || (NAN(fVar3))) {
        fVar4 = ABS(fVar3);
      }
      else {
        fVar4 = 1.0;
      }
      if ((fVar2 != 0.0) || (NAN(fVar2))) {
        fVar5 = ABS(fVar2);
      }
      else {
        fVar5 = 1.0;
      }
      if (fVar5 <= fVar4) {
        fVar5 = fVar4;
      }
      if (ABS(fVar3 - fVar2) <= fVar5 * 0.0005) {
        return;
      }
      dVar6 = dVar6 + dVar7;
    }
    _objc_msgSend(self_00,sel_setHyperCurrentTime_,dVar6,dVar8);
  }
  return;
}

*/
- (void)rangeChanged:(id)aChanged
{
    id playable = [self playableObjectAttributes];
    double startTime = [_rangeControl startTime];
    double length = [_rangeControl finishTime] - [_rangeControl startTime];
    struct HSTimeRange oldRange = [playable hyperPlayRange];
    struct HSTimeRange range = {startTime, length};
    [playable setHyperPlayRange:range];
    [[self HSMovieObjectAppearanceAssistantPane_playMovieActionItemForCurrentObject] setPlayRange:range];
    if ([playable isHyperPlaying]) {
        return;
    }
    /* Show the frame at whichever end of the range moved. */
    double currentTime = startTime;
    float oldStart = (float)oldRange.location;
    float newStart = (float)startTime;
    if (fabsf(oldStart - newStart) <= HSMovieAppearanceTolerance(oldStart, newStart)) {
        float oldLength = (float)oldRange.length;
        float newLength = (float)length;
        if (fabsf(oldLength - newLength) <= HSMovieAppearanceTolerance(oldLength, newLength)) {
            return;
        }
        currentTime = startTime + length;
    }
    [playable setHyperCurrentTime:currentTime];
}

- (void)volumeOutChanged:(id)aChanged
{
    [[self movieObjectAttributes] setHyperVolume:(float)([_volumeSlider minValue] / 100.0)];
}

- (void)volumeInChanged:(id)aChanged
{
    [[self movieObjectAttributes] setHyperVolume:(float)([_volumeSlider maxValue] / 100.0)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00184fb2 @ 00184fb2, 159 bytes * /

void FUN_00184fb2(HSMovieObjectAppearanceAssistantPane *self,SEL _cmd,id volumeChanged)

{
  float fVar1;
  id pvVar2;
  id self_00;
  longdouble lVar3;
  double dVar4;
  
  pvVar2 = self->_volumeSlider;
  self_00 = _objc_msgSend(self,sel_movieObjectAttributes);
  if (pvVar2 == volumeChanged) {
    lVar3 = (longdouble)_HSNonLinearValueForSlider(self->_volumeSlider);
    fVar1 = (float)lVar3;
  }
  else {
    dVar4 = _objc_msgSend_fpret(volumeChanged,sel_floatValue);
    fVar1 = (float)dVar4;
  }
  _objc_msgSend(self_00,sel_setHyperVolume_,fVar1 / 100.0);
  return;
}

*/
- (void)volumeChanged:(id)aChanged
{
    id attributes = [self movieObjectAttributes];
    float volume;
    if (_volumeSlider == aChanged) {
        volume = HSNonLinearValueForSlider(_volumeSlider);
    } else {
        volume = [aChanged floatValue];
    }
    [attributes setHyperVolume:volume / 100.0f];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018228d @ 0018228d, 138 bytes * /

void FUN_0018228d(HSMovieObjectAppearanceAssistantPane *self,SEL _cmd,id playMovie)

{
  id self_00;
  id pvVar1;
  SEL op;
  
  self_00 = _objc_msgSend(self,sel_playableObjectAttributes);
  pvVar1 = _objc_msgSend(self_00,sel_isHyperPlaying);
  if ((char)pvVar1 == '\0') {
    _objc_msgSend(self,sel_setUpPauseButton);
    op = sel_hyperStart_;
  }
  else {
    _objc_msgSend(self,sel_setUpPlayButton);
    op = sel_hyperStop;
  }
  _objc_msgSend(self_00,op);
  return;
}

*/
- (void)playMovie:(id)aMovie
{
    id playable = [self playableObjectAttributes];
    if (![playable isHyperPlaying]) {
        [self setUpPauseButton];
        [playable hyperStart:self];
    } else {
        [self setUpPlayButton];
        [playable hyperStop];
    }
}

- (void)setName:(id)aName
{
    [[[[self assistant] object] queryHyperInterface:@protocol(HSMutableObjectAttributes)] setHyperName:[aName stringValue]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00185051 @ 00185051, 860 bytes * /

id FUN_00185051(HSMovieObjectAppearanceAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  int iVar3;
  int iVar4;
  id pvVar5;
  undefined4 *puVar6;
  id pvVar7;
  id pvVar8;
  id pvVar9;
  id pvVar10;
  bool bVar11;
  undefined4 *puVar12;
  undefined1 *puVar13;
  undefined4 uVar14;
  id local_f8;
  id local_dc;
  undefined4 local_d4;
  int local_d0;
  int *local_cc;
  undefined4 local_c8;
  undefined4 local_c4;
  undefined4 local_c0;
  undefined4 local_bc;
  undefined4 local_b8;
  undefined1 local_b4 [64];
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined1 local_50 [64];
  
  pvVar5 = _objc_msgSend(self,sel_assistant);
  pvVar5 = _objc_msgSend(pvVar5,sel_object);
  pvVar5 = _objc_msgSend(pvVar5,sel_queryHyperInterface_,&DAT_00379480);
  puVar6 = _objc_msgSend(pvVar5,sel_hyperUID);
  pvVar5 = _objc_msgSend(self,sel_stack);
  pvVar5 = _objc_msgSend(pvVar5,sel_allActionsOfType_,&DAT_003795e8);
  local_d4 = 0;
  local_d0 = 0;
  local_cc = (int *)0x0;
  local_c8 = 0;
  local_c4 = 0;
  local_c0 = 0;
  local_bc = 0;
  local_b8 = 0;
  puVar13 = local_b4;
  puVar12 = &local_d4;
  uVar14 = 0x10;
  local_f8 = _objc_msgSend(pvVar5,sel_countByEnumeratingWithState_objects_count_,puVar12,puVar13,
                           0x10);
  if (local_f8 == (id)0x0) {
LAB_0018517a:
    local_dc = (id)0x0;
  }
  else {
    iVar3 = *local_cc;
    local_dc = (id)0x0;
    do {
      pvVar8 = (id)0x0;
      do {
        if (iVar3 != *local_cc) {
          _objc_enumerationMutation(pvVar5);
        }
        pvVar2 = (id)((int)pvVar8 + 1);
        pvVar8 = _objc_msgSend(*(id *)(local_d0 + (int)pvVar8 * 4),sel_movies,puVar12,puVar13,uVar14
                              );
        local_74 = 0;
        local_70 = 0;
        local_6c = (int *)0x0;
        local_68 = 0;
        local_64 = 0;
        local_60 = 0;
        local_5c = 0;
        local_58 = 0;
        puVar13 = local_50;
        puVar12 = &local_74;
        uVar14 = 0x10;
        pvVar9 = _objc_msgSend(pvVar8,sel_countByEnumeratingWithState_objects_count_);
        if (pvVar9 != (id)0x0) {
          iVar4 = *local_6c;
          do {
            pvVar10 = (id)0x0;
            do {
              if (iVar4 != *local_6c) {
                _objc_enumerationMutation(pvVar8);
              }
              pvVar1 = (id)((int)pvVar10 + 1);
              pvVar10 = *(id *)(local_70 + (int)pvVar10 * 4);
              pvVar7 = _objc_msgSend(pvVar10,sel_movieObjectUID,puVar12,puVar13,uVar14);
              puVar12 = puVar6;
              pvVar7 = _objc_msgSend(pvVar7,sel_isEqual_);
              if (((char)pvVar7 != '\0') &&
                 (bVar11 = local_dc != (id)0x0, local_dc = pvVar10, bVar11)) goto LAB_0018517a;
              pvVar10 = pvVar1;
            } while (pvVar1 < pvVar9);
            puVar13 = local_50;
            puVar12 = &local_74;
            uVar14 = 0x10;
            pvVar9 = _objc_msgSend(pvVar8,sel_countByEnumeratingWithState_objects_count_,puVar12,
                                   puVar13,0x10);
          } while (pvVar9 != (id)0x0);
        }
        pvVar8 = pvVar2;
      } while (pvVar2 < local_f8);
      puVar13 = local_b4;
      puVar12 = &local_d4;
      uVar14 = 0x10;
      local_f8 = _objc_msgSend(pvVar5,sel_countByEnumeratingWithState_objects_count_,puVar12,puVar13
                               ,0x10);
    } while (local_f8 != (id)0x0);
  }
  return local_dc;
}

*/
- (id)HSMovieObjectAppearanceAssistantPane_playMovieActionItemForCurrentObject
{
    id uid = [[[[self assistant] object] queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID];
    id found = nil;
    for (id action in [[self stack] allActionsOfType:@protocol(HSPlayMovieActionAttributes)]) {
        for (id item in [action movies]) {
            if ([[item movieObjectUID] isEqual:uid]) {
                /* More than one action plays this movie: no single item to update. */
                if (found != nil) {
                    return nil;
                }
                found = item;
            }
        }
    }
    return found;
}

- (id)shadowAttributes
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSMutableShadowAttributes)];
}

- (id)opacityAttributes
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSMutableOpacityAttributes)];
}

- (id)playableObjectAttributes
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSPlayableObjectAttributes)];
}

- (id)movieObjectAttributes
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSMovieObjectAttributes)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018203f @ 0018203f, 113 bytes * /

BOOL FUN_0018203f(HSMovieObjectAppearanceAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self->_nameTextField,sel_currentEditor);
  if ((pvVar1 == (id)0x0) &&
     (pvVar1 = _objc_msgSend(self->_volumeTextField,sel_currentEditor), pvVar1 == (id)0x0)) {
    pvVar1 = _objc_msgSend(self->_opacityTextField,sel_currentEditor);
    return pvVar1 != (id)0x0;
  }
  return '\x01';
}

*/
- (BOOL)isEditingTextAttribute
{
    return [_nameTextField currentEditor] != nil || [_volumeTextField currentEditor] != nil || [_opacityTextField currentEditor] != nil;
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [self stopMovie];
    [self stopObservingOfChangesInMovieObject];
    [super viewWillDisappear:aDisappear];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00185412 @ 00185412, 398 bytes * /

void FUN_00185412(HSMovieObjectAppearanceAssistantPane *self,SEL _cmd,BOOL viewWillAppear)

{
  id self_00;
  id pvVar1;
  HSMovieObjectAppearanceAssistantPane *self_01;
  SEL op;
  undefined4 uVar2;
  HSMovieObjectAppearanceAssistantPane *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSObjectAssistantPane_00352730;
  _objc_msgSendSuper(&local_1c,sel_viewWillAppear_,(int)viewWillAppear);
  _objc_msgSend(self,sel_stopMovie);
  _objc_msgSend(self,sel_startObservingOfChangesInMovieObject);
  _objc_msgSend(self,sel_setupMovieUIConstrains);
  if (self->_transparentColorAttributes == (id)0x0) {
    _objc_msgSend(self->_transparentColorSwitch,sel_setEnabled_,0);
    _objc_msgSend(self->_transparentColorButton,sel_setEnabled_,0);
    _objc_msgSend(self->_transparentColorSwitch,sel_setState_,0);
    self_00 = self->_transparentColorSwitch;
    pvVar1 = _objc_msgSend(self->_transparentColorButton,sel_title);
    _objc_msgSend(self_00,sel_setTitle_,pvVar1);
    self_01 = self->_transparentColorButton;
    uVar2 = 1;
    op = sel_setHidden_;
  }
  else {
    _objc_msgSend(self->_transparentColorSwitch,sel_setEnabled_,1);
    uVar2 = 1;
    _objc_msgSend(self->_transparentColorButton,sel_setEnabled_,1);
    self_01 = self;
    op = sel_HSMovieObjectAppearanceAssistantPane_validatetransparentColorSwitchAndButton;
  }
  _objc_msgSend(self_01,op,uVar2);
  _objc_msgSend(self,sel_validateUserInterface);
  return;
}

*/
- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [self stopMovie];
    [self startObservingOfChangesInMovieObject];
    [self setupMovieUIConstrains];
    if (_transparentColorAttributes == nil) {
        [_transparentColorSwitch setEnabled:NO];
        [_transparentColorButton setEnabled:NO];
        [_transparentColorSwitch setState:NSControlStateValueOff];
        [_transparentColorSwitch setTitle:[_transparentColorButton title]];
        [_transparentColorButton setHidden:YES];
    } else {
        [_transparentColorSwitch setEnabled:YES];
        [_transparentColorButton setEnabled:YES];
        [self HSMovieObjectAppearanceAssistantPane_validatetransparentColorSwitchAndButton];
    }
    [self validateUserInterface];
}

- (void)HSMovieObjectAppearanceAssistantPane_validatetransparentColorSwitchAndButton
{
    BOOL bVar3;
    id pvVar1_3;

    bVar3 = ![_transparentColorAttributes isTransparentColorEnabled];
    if (bVar3) {
        [_transparentColorSwitch setState:0];
        [_transparentColorSwitch setTitle:[_transparentColorButton title]];
        pvVar1_3 = _transparentColorButton;
    }
    else {
        [_transparentColorSwitch setState:1];
        [_transparentColorSwitch setTitle:@""];
        pvVar1_3 = _transparentColorButton;
    }
    [pvVar1_3 setHidden:(unsigned int)bVar3];
}

- (void)dealloc
{
    [_volumeSlider setDelegate:0];
    [_playImage release];
    [_stopImage release];
    [_pressedPlayImage release];
    [_pressedStopImage release];
    [_importMoviesDialogController release];
    [_movieTopControlBarView release];
    [_movieBottomControlBarView release];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00181aba @ 00181aba, 1160 bytes * /

void FUN_00181aba(HSMovieObjectAppearanceAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  undefined *puVar2;
  id pvVar3;
  cfstringStruct *pcVar4;
  cfstringStruct *pcVar5;
  cfstringStruct *pcVar6;
  
  pvVar1 = _objc_msgSend(cls_HSPlaybackControlImagesProvider,
                         sel_sharedPlaybackControlsImagesProvider);
  pvVar1 = _objc_msgSend(pvVar1,sel_playbackImageOfType_state_size_tint_,&cfstr_Play,&cfstr_N,
                         &cfstr_L,&cfstr_A);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_playImage = pvVar1;
  pvVar1 = _objc_msgSend(cls_HSPlaybackControlImagesProvider,
                         sel_sharedPlaybackControlsImagesProvider);
  pcVar6 = &cfstr_A;
  pcVar5 = &cfstr_L;
  pcVar4 = &cfstr_N;
  pvVar1 = _objc_msgSend(pvVar1,sel_playbackImageOfType_state_size_tint_,&cfstr_Pause,&cfstr_N,
                         &cfstr_L,&cfstr_A);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_stopImage = pvVar1;
  puVar2 = sel_currentControlTint;
  pvVar1 = _objc_msgSend(cls_NSColor,sel_respondsToSelector_,sel_currentControlTint);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(cls_NSColor,sel_currentControlTint,puVar2,pcVar4,pcVar5,pcVar6);
    if (pvVar1 == (id)0x6) {
      pvVar1 = _objc_msgSend(cls_HSPlaybackControlImagesProvider,
                             sel_sharedPlaybackControlsImagesProvider,puVar2,pcVar4,pcVar5,pcVar6);
      pvVar1 = _objc_msgSend(pvVar1,sel_playbackImageOfType_state_size_tint_,&cfstr_Play,&cfstr_P,
                             &cfstr_L,&cfstr_G);
      pvVar1 = _objc_msgSend(pvVar1,sel_retain);
      self->_pressedPlayImage = pvVar1;
      pvVar1 = _objc_msgSend(cls_HSPlaybackControlImagesProvider,
                             sel_sharedPlaybackControlsImagesProvider);
      pcVar6 = &cfstr_G;
      goto LAB_00181d14;
    }
  }
  pvVar1 = _objc_msgSend(cls_HSPlaybackControlImagesProvider,
                         sel_sharedPlaybackControlsImagesProvider,puVar2,pcVar4,pcVar5,pcVar6);
  pvVar1 = _objc_msgSend(pvVar1,sel_playbackImageOfType_state_size_tint_,&cfstr_Play,&cfstr_P,
                         &cfstr_L,&cfstr_A);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_pressedPlayImage = pvVar1;
  pvVar1 = _objc_msgSend(cls_HSPlaybackControlImagesProvider,
                         sel_sharedPlaybackControlsImagesProvider);
  pcVar6 = &cfstr_A;
LAB_00181d14:
  pvVar1 = _objc_msgSend(pvVar1,sel_playbackImageOfType_state_size_tint_,&cfstr_Pause,&cfstr_P,
                         &cfstr_L,pcVar6);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_pressedStopImage = pvVar1;
  pvVar1 = _objc_msgSend(self->_rangeControl,sel_cell);
  _objc_msgSend(pvVar1,sel_setControlSize_,2);
  _objc_msgSend(self->_spinButton,sel_setContinuous_,1);
  _objc_msgSend(self->_spinButton,sel_setTarget_,self);
  _objc_msgSend(self->_spinButton,sel_setAction_,sel_move_);
  pvVar1 = _objc_msgSend(self->_zoomInButton,sel_cell);
  puVar2 = sel_setBackgroundRenderer_;
  pvVar1 = _objc_msgSend(pvVar1,sel_respondsToSelector_,sel_setBackgroundRenderer_);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(self->_zoomInButton,sel_cell,puVar2);
    puVar2 = _objc_msgSend(cls_HSToolSettingsBigControlBackgroundRenderer,
                           sel_sharedBackgroundRenderer);
    _objc_msgSend(pvVar1,sel_setBackgroundRenderer_,puVar2);
  }
  pvVar1 = _objc_msgSend(self->_zoomOutButton,sel_cell,puVar2);
  puVar2 = sel_setBackgroundRenderer_;
  pvVar1 = _objc_msgSend(pvVar1,sel_respondsToSelector_,sel_setBackgroundRenderer_);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(self->_zoomOutButton,sel_cell,puVar2);
    pvVar3 = _objc_msgSend(cls_HSToolSettingsBigControlBackgroundRenderer,
                           sel_sharedBackgroundRenderer);
    _objc_msgSend(pvVar1,sel_setBackgroundRenderer_,pvVar3);
  }
  _objc_msgSend(self->_volumeSlider,sel_setDelegate_,self);
  _objc_msgSend(self->_rangeControl,sel_setLeftKnobClickAction_,sel_leftRangeKnobActivated_);
  _objc_msgSend(self->_rangeControl,sel_setRightKnobClickAction_,sel_rightRangeKnobActivated_);
  return;
}

*/
- (void)viewDidLoad
{
    HSPlaybackControlImagesProvider *provider = [HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider];
    _playImage = [[provider playbackImageOfType:@"Play" state:@"N" size:@"L" tint:@"A"] retain];
    _stopImage = [[provider playbackImageOfType:@"Pause" state:@"N" size:@"L" tint:@"A"] retain];
    NSString *tint = @"A";
    if ([NSColor respondsToSelector:@selector(currentControlTint)] && [NSColor currentControlTint] == NSGraphiteControlTint) {
        tint = @"G";
    }
    _pressedPlayImage = [[[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Play" state:@"P" size:@"L" tint:tint] retain];
    _pressedStopImage = [[[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Pause" state:@"P" size:@"L" tint:tint] retain];
    [[_rangeControl cell] setControlSize:NSControlSizeMini];
    [_spinButton setContinuous:YES];
    [_spinButton setTarget:self];
    [_spinButton setAction:@selector(move:)];
    if ([[_zoomInButton cell] respondsToSelector:@selector(setBackgroundRenderer:)]) {
        [[_zoomInButton cell] setBackgroundRenderer:[HSToolSettingsBigControlBackgroundRenderer sharedBackgroundRenderer]];
    }
    if ([[_zoomOutButton cell] respondsToSelector:@selector(setBackgroundRenderer:)]) {
        [[_zoomOutButton cell] setBackgroundRenderer:[HSToolSettingsBigControlBackgroundRenderer sharedBackgroundRenderer]];
    }
    [_volumeSlider setDelegate:self];
    [_rangeControl setLeftKnobClickAction:@selector(leftRangeKnobActivated:)];
    [_rangeControl setRightKnobClickAction:@selector(rightRangeKnobActivated:)];
}

- (id)init
{
    id self_00;

    self_00 = [self initWithNibName:@"MovieObjectAppearancePane"];
    if (self_00 != nil) {
        [self_00 setTitle:[[NSBundle mainBundle] localizedStringForKey:@"Appearance" value:@"" table:@"AssistantPanes"]];
        [self_00 setIcon:[NSImage imageNamed:@"general"]];
    }
    return self_00;
}

@end

