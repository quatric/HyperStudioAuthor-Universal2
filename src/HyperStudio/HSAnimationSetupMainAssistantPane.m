#import "HSAnimationSetupMainAssistantPane.h"

// Speed multipliers offered by the move value pop-up, indexed by item tag.
static const float HSAnimationSetupSpeedMultipliers[5] = { 0.25f, 0.5f, 1.0f, 2.0f, 3.0f };
static id sDAT_00342930;
static id sDAT_00342934;
static id sDAT_00342938;
static id sDAT_0034293c;
static id sDAT_00342940;
static id sDAT_00342944;
static id sDAT_00342948;
static id sDAT_0034294c;

static id sDAT_00342930;
static id sDAT_00342934;
static id sDAT_00342938;
static id sDAT_0034293c;
static id sDAT_00342940;
static id sDAT_00342944;
static id sDAT_00342948;
static id sDAT_0034294c;


@implementation HSAnimationSetupMainAssistantPane

/* i386 ivar offsets: _delegate=0x5c, _navigationPaneSwitcher=0x60, _isMovieAnimation=0x64, _segmentedControl=0x68, _optionsView=0x6c, _mainOptionsView=0x70, _pathOptionsView=0x74, _showFirstFrameButton=0x78, _eraseWhenDoneButton=0x7c, _matchToMovementMatrix=0x80, _allowClonesButton=0x84, _movieSpeedTextField=0x88, _movieSpeedStepper=0x8c, _playForPopUpButton=0x90, _playForValueTextField=0x94, _playForValueStepper=0x98, _horizontalFlipButton=0x9c, _verticalFlipButton=0xa0, _transparentColorPickerButton=0xa4, _transparentColorButton=0xa8, _mainPlayStopButton=0xac, _newPathButton=0xb0, _getNewSourceButton=0xb4, _beginArrowButton=0xb8, _endArrowButton=0xbc, _horizontalFlipAtStartButton=0xc0, _verticalFlipAtStartButton=0xc4, _horizontalFlipAtFinishButton=0xc8, _verticalFlipAtFinishButton=0xcc, _startFromBeginButton=0xd0, _startFromEndButton=0xd4, _goingImageView=0xd8, _returningImageView=0xdc, _floatOverGoingButton=0xe0, _floatOverReturningButton=0xe4, _dontEraseGoingButton=0xe8, _dontEraseReturningButton=0xec, _movePopUpButton=0xf0, _moveValueTextField=0xf4, _moveValueStepper=0xf8, _secondsLabel=0xfc, _moveValuePopUpButton=0x100, _layerPopUpButton=0x104, _pathPlayStopButton=0x108, _helpIsActive=0x10c, _helpDrawer=0x110, _actionHelpView=0x114, _helpTextView=0x118 */

+ (id)noFloatOverImage
{
    if (sDAT_0034294c == nil) {
        sDAT_0034294c = [NSImage imageNamed:@"PassOptions_ObjectOver"];
    }
    return sDAT_0034294c;
}

+ (id)floatOverImage
{
    if (sDAT_00342948 == nil) {
        sDAT_00342948 = [NSImage imageNamed:@"PassOptions_ObjectUnder"];
    }
    return sDAT_00342948;
}

+ (id)rightTurnImage
{
    if (sDAT_00342944 == nil) {
        sDAT_00342944 = [NSImage imageNamed:@"AnimationLeftEndButton"];
    }
    return sDAT_00342944;
}

+ (id)leftTurnImage
{
    if (sDAT_00342940 == nil) {
        sDAT_00342940 = [NSImage imageNamed:@"AnimationRightEndButton"];
    }
    return sDAT_00342940;
}

+ (id)rightEndImage
{
    if (sDAT_0034293c == nil) {
        sDAT_0034293c = [NSImage imageNamed:@"AnimationRightEndButton"];
    }
    return sDAT_0034293c;
}

+ (id)leftEndImage
{
    if (sDAT_00342938 == nil) {
        sDAT_00342938 = [NSImage imageNamed:@"AnimationLeftEndButton"];
    }
    return sDAT_00342938;
}

+ (id)rightStartImage
{
    if (sDAT_00342934 == nil) {
        sDAT_00342934 = [NSImage imageNamed:@"AnimationRightStartButton"];
    }
    return sDAT_00342934;
}

+ (id)leftStartImage
{
    if (sDAT_00342930 == nil) {
        sDAT_00342930 = [NSImage imageNamed:@"AnimationLeftStartButton"];
    }
    return sDAT_00342930;
}

+ (id)stopAnimationImage
{
    return [[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Stop" state:@"N" size:@"M" tint:@"A"];
}

+ (id)playAnimationImage
{
    return [[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Play" state:@"N" size:@"M" tint:@"A"];
}

- (void)updateUI
{
    [self updateMainOptionsUI];
    [self updatePathOptionsUI];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0012d509 @ 0012d509, 124 bytes * /

void FUN_0012d509(HSAnimationSetupMainAssistantPane *self,SEL _cmd,BOOL setPlayTryItAnimation)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_class);
  op = sel_stopAnimationImage;
  if (setPlayTryItAnimation != '\0') {
    op = sel_playAnimationImage;
  }
  pvVar1 = _objc_msgSend(pvVar1,op);
  _objc_msgSend(self,sel_setPlayStopImage_,pvVar1);
  _objc_msgSend(self,sel_setOptionsEnabled_,(int)setPlayTryItAnimation);
  return;
}

*/
- (void)setPlayTryItAnimation:(BOOL)aAnimation
{
    [self setPlayStopImage:(aAnimation ? [[self class] playAnimationImage] : [[self class] stopAnimationImage])];
    [self setOptionsEnabled:aAnimation];
}

- (void)setPlayStopImage:(id)aImage
{
    [_mainPlayStopButton setImage:aImage];
    [_pathPlayStopButton setImage:aImage];
}

- (void)setOptionsEnabled:(BOOL)aEnabled
{
    int iVar1;

    iVar1 = (int)aEnabled;
    [_segmentedControl setEnabled:iVar1];
    [_showFirstFrameButton setEnabled:iVar1];
    [_eraseWhenDoneButton setEnabled:iVar1];
    [_matchToMovementMatrix setEnabled:iVar1];
    [_allowClonesButton setEnabled:iVar1];
    [_movieSpeedTextField setEnabled:iVar1];
    [_movieSpeedStepper setEnabled:iVar1];
    [_playForPopUpButton setEnabled:iVar1];
    [_playForValueTextField setEnabled:iVar1];
    [_playForValueStepper setEnabled:iVar1];
    [_horizontalFlipButton setEnabled:iVar1];
    [_verticalFlipButton setEnabled:iVar1];
    [_transparentColorPickerButton setEnabled:iVar1];
    [_transparentColorButton setEnabled:iVar1];
    [_beginArrowButton setEnabled:iVar1];
    [_endArrowButton setEnabled:iVar1];
    [_horizontalFlipAtStartButton setEnabled:iVar1];
    [_verticalFlipAtStartButton setEnabled:iVar1];
    [_horizontalFlipAtFinishButton setEnabled:iVar1];
    [_verticalFlipAtFinishButton setEnabled:iVar1];
    [_startFromBeginButton setEnabled:iVar1];
    [_startFromEndButton setEnabled:iVar1];
    [_goingImageView setEnabled:iVar1];
    [_returningImageView setEnabled:iVar1];
    [_floatOverGoingButton setEnabled:iVar1];
    [_floatOverReturningButton setEnabled:iVar1];
    [_dontEraseGoingButton setEnabled:iVar1];
    [_dontEraseReturningButton setEnabled:iVar1];
    [_movePopUpButton setEnabled:iVar1];
    [_moveValueTextField setEnabled:iVar1];
    [_moveValueStepper setEnabled:iVar1];
    [_moveValuePopUpButton setEnabled:iVar1];
    [_layerPopUpButton setEnabled:iVar1];
    [_newPathButton setEnabled:iVar1];
    [_getNewSourceButton setEnabled:iVar1];
}

- (void)hideHelp:(id)aHelp
{
    [self hideHelpNeedsRelayout:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0012d940 @ 0012d940, 335 bytes * /

void FUN_0012d940(HSAnimationSetupMainAssistantPane *self,SEL _cmd,id showHelp)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined1 local_24 [8];
  undefined4 local_1c;
  undefined4 local_18;
  
  pvVar1 = _objc_msgSend(self,sel_assistant);
  pvVar2 = _objc_msgSend(self,sel_actionHelpView);
  _objc_msgSend_stret(local_24,pvVar2,sel_frame);
  _objc_msgSend(pvVar1,sel_toggleDrawerModeWithDrawerSize_,local_1c,local_18);
  pvVar1 = _objc_msgSend(self,sel_actionHelpView);
  _objc_msgSend(self,sel_setFooterView_,pvVar1);
  pvVar1 = _objc_msgSend(self->_helpTextView,sel_textStorage);
  pvVar2 = _objc_msgSend(cls_HSNBAHelpProvider,sel_sharedNBAHelpProvider);
  pvVar3 = _objc_msgSend(cls_HSPlayAnimationAction,sel_actionType);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedHelpForActionOfType_,pvVar3);
  _objc_msgSend(pvVar1,sel_setAttributedString_,pvVar2);
  _objc_msgSend(self,sel_layoutIfNeeded);
  self->_helpIsActive = '\x01';
  return;
}

*/
- (void)showHelp:(id)aHelp
{
    [[self assistant] toggleDrawerModeWithDrawerSize:[[self actionHelpView] frame].size];
    [self setFooterView:[self actionHelpView]];
    [[_helpTextView textStorage] setAttributedString:[[HSNBAHelpProvider sharedNBAHelpProvider] localizedHelpForActionOfType:[HSPlayAnimationAction actionType]]];
    [self layoutIfNeeded];
    _helpIsActive = YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0012da8f @ 0012da8f, 189 bytes * /

void FUN_0012da8f(HSAnimationSetupMainAssistantPane *self,SEL _cmd,BOOL hideHelpNeedsRelayout)

{
  id self_00;
  id self_01;
  undefined4 uVar1;
  undefined1 local_24 [8];
  undefined4 local_1c;
  undefined4 local_18;
  
  uVar1 = 0;
  _objc_msgSend(self,sel_setFooterView_,0);
  if (hideHelpNeedsRelayout != '\0') {
    _objc_msgSend(self,sel_layoutIfNeeded,uVar1);
  }
  self->_helpIsActive = '\0';
  self_00 = _objc_msgSend(self,sel_assistant,uVar1);
  self_01 = _objc_msgSend(self,sel_actionHelpView);
  _objc_msgSend_stret(local_24,self_01,sel_frame);
  _objc_msgSend(self_00,sel_toggleDrawerModeWithDrawerSize_,local_1c,local_18);
  return;
}

*/
- (void)hideHelpNeedsRelayout:(BOOL)aRelayout
{
    [self setFooterView:nil];
    if (aRelayout) {
        [self layoutIfNeeded];
    }
    _helpIsActive = NO;
    [[self assistant] toggleDrawerModeWithDrawerSize:[[self actionHelpView] frame].size];
}

- (id)helpDrawer
{
    id pvVar1;
    id pvVar2;
    HSObjectAssistantDrawer *pHVar4;

    pHVar4 = _helpDrawer;
    if (pHVar4 == nil) {
        pvVar1 = [HSObjectAssistantDrawer alloc];
        pvVar2 = [self assistant];
        _helpDrawer = [pvVar1 initWithContentView:[self actionHelpView] objectAssistant:pvVar2];
        [[_helpTextView textStorage] setAttributedString:[[HSNBAHelpProvider sharedNBAHelpProvider] localizedHelpForActionOfType:[HSPlayAnimationAction actionType]]];
        pHVar4 = _helpDrawer;
    }
    return pHVar4;
}

- (id)actionHelpView
{
    return _actionHelpView;
}

- (BOOL)isHelpVisible
{
    return _helpIsActive;
}

- (void)paneDidCancel:(id)aCancel
{
    [_delegate cancelFromAnimationSetupMainAssistantPane:self];
}

- (void)paneDidOK:(id)aOK
{
    [_delegate doneFromAnimationSetupMainAssistantPane:self];
}

- (void)playStop:(id)aStop
{
    [_delegate playStopFromAnimationSetupMainAssistantPane:self];
}

- (void)getNewSource:(id)aSource
{
    [_delegate getNewSourceFromAnimationSetupMainAssistantPane:self];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0012cc7a @ 0012cc7a, 605 bytes * /

void FUN_0012cc7a(HSAnimationSetupMainAssistantPane *self,SEL _cmd,id newPath)

{
  undefined4 uVar1;
  id pvVar2;
  id pvVar3;
  undefined4 uVar4;
  
  pvVar2 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  uVar1 = *(undefined4 *)PTR_003365b4;
  uVar4 = uVar1;
  pvVar2 = _objc_msgSend(pvVar2,sel_objectForKey_,uVar1);
  if ((pvVar2 == (id)0x0) || (pvVar2 = _objc_msgSend(pvVar2,sel_intValue,uVar4), pvVar2 != (id)0x0))
  {
    pvVar2 = _objc_msgSend(cls_HSDontShowAgainAlert,sel_new,uVar4);
    _objc_msgSend(pvVar2,sel_setShowAlertKey_,uVar1);
    pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,
                           &cfstr_HSNewAnimationPathMessageText,&cfstr_empty,&cfstr_Alerts);
    _objc_msgSend(pvVar2,sel_setMessageText_,pvVar3);
    pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,
                           &cfstr_HSNewAnimationPathInformativeText,&cfstr_empty,&cfstr_Alerts);
    _objc_msgSend(pvVar2,sel_setInformativeText_,pvVar3);
    pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,
                           &cfstr_HSNewAnimationPathCreateButtonTitle,&cfstr_empty,&cfstr_Alerts);
    _objc_msgSend(pvVar2,sel_addButtonWithTitle_,pvVar3);
    pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_Cancel,&cfstr_empty,
                           &cfstr_Alerts);
    _objc_msgSend(pvVar2,sel_addButtonWithTitle_,pvVar3);
    pvVar3 = _objc_msgSend(pvVar2,sel_runModal);
    _objc_msgSend(pvVar2,sel_release);
    if (pvVar3 == (id)0x3e9) {
      return;
    }
  }
  _objc_msgSend(self->_delegate,sel_newPathFromAnimationSetupMainAssistantPane_,self);
  return;
}

*/
- (void)newPath:(id)aPath
{
    id showAlert = [[NSUserDefaults standardUserDefaults] objectForKey:HSShowNewPathAlertKey];
    if (showAlert == nil || [showAlert intValue] != 0) {
        HSDontShowAgainAlert *alert = [HSDontShowAgainAlert new];
        [alert setShowAlertKey:HSShowNewPathAlertKey];
        [alert setMessageText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSNewAnimationPathMessageText" value:@"" table:@"Alerts"]];
        [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSNewAnimationPathInformativeText" value:@"" table:@"Alerts"]];
        [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSNewAnimationPathCreateButtonTitle" value:@"" table:@"Alerts"]];
        [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Cancel" value:@"" table:@"Alerts"]];
        NSInteger result = [alert runModal];
        [alert release];
        if (result == NSAlertSecondButtonReturn) {
            return;
        }
    }
    [_delegate newPathFromAnimationSetupMainAssistantPane:self];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0012db4c @ 0012db4c, 1768 bytes * /

void FUN_0012db4c(HSAnimationSetupMainAssistantPane *self,SEL _cmd)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  float *pfVar3;
  undefined *puVar4;
  double dVar5;
  SEL op;
  undefined4 uVar6;
  
  _objc_msgSend(self,sel_updateBeginAndEndArrows);
  _objc_msgSend(self,sel_updateFlipsUI);
  self_00 = _objc_msgSend(self,sel_animation);
  pvVar1 = _objc_msgSend(self_00,sel_animatedObject);
  _objc_msgSend(self->_pathPlayStopButton,sel_setEnabled_,(uint)(pvVar1 != (id)0x0));
  pvVar1 = _objc_msgSend(self_00,sel_playbackDirection);
  _objc_msgSend(self->_startFromBeginButton,sel_setState_,pvVar1 == (id)0x1 ^ 1);
  _objc_msgSend(self->_startFromEndButton,sel_setState_,(uint)(pvVar1 == (id)0x1));
  _objc_msgSend(self,sel_HSAnimationSetupMainAssistantPane_validateGoingAbsoluteLayerGUI);
  _objc_msgSend(self,sel_HSAnimationSetupMainAssistantPane_validateReturningAbsoluteLayerGUI);
  pvVar1 = self->_floatOverReturningButton;
  pvVar2 = _objc_msgSend(self_00,sel_playBackAndForth);
  _objc_msgSend(pvVar1,sel_setEnabled_,(int)(char)pvVar2);
  pvVar1 = self->_dontEraseReturningButton;
  pvVar2 = _objc_msgSend(self_00,sel_playBackAndForth);
  _objc_msgSend(pvVar1,sel_setEnabled_,(int)(char)pvVar2);
  pvVar1 = self->_dontEraseGoingButton;
  pvVar2 = _objc_msgSend(self_00,sel_dontEraseGoing);
  _objc_msgSend(pvVar1,sel_setState_,(uint)((char)pvVar2 != '\0'));
  pvVar1 = self->_dontEraseReturningButton;
  pvVar2 = _objc_msgSend(self_00,sel_dontEraseReturning);
  _objc_msgSend(pvVar1,sel_setState_,(uint)((char)pvVar2 != '\0'));
  pvVar1 = self->_layerPopUpButton;
  pvVar2 = _objc_msgSend(self_00,sel_layer);
  _objc_msgSend(pvVar1,sel_selectItemWithTag_,pvVar2);
  pvVar1 = _objc_msgSend(self_00,sel_speedMode);
  _objc_msgSend(self,sel_movePopUpButtonSelectItemWithTag_,pvVar1);
  if (pvVar1 == (id)0x0) {
    _objc_msgSend(self->_moveValueTextField,sel_setHidden_,1);
    _objc_msgSend(self->_moveValueStepper,sel_setHidden_,1);
    _objc_msgSend(self->_moveValuePopUpButton,sel_setHidden_,0);
    _objc_msgSend(self->_secondsLabel,sel_setHidden_,1);
    puVar4 = (undefined *)0x0;
    pfVar3 = (float *)&DAT_00335300;
    while( true ) {
      if ((undefined *)0x4 < puVar4) {
        return;
      }
      dVar5 = _objc_msgSend_fpret(self_00,sel_speedMultiplier);
      if (((float)dVar5 == *pfVar3) && (!NAN((float)dVar5) && !NAN(*pfVar3))) break;
      pfVar3 = pfVar3 + 1;
      puVar4 = puVar4 + 1;
    }
    pvVar1 = self->_moveValuePopUpButton;
    op = sel_selectItemWithTag_;
    goto LAB_0012e21c;
  }
  if (pvVar1 == (id)0x2) {
    _objc_msgSend(self->_moveValueTextField,sel_setHidden_,0);
    _objc_msgSend(self->_moveValueStepper,sel_setHidden_,0);
    _objc_msgSend(self->_moveValuePopUpButton,sel_setHidden_,1);
    _objc_msgSend(self->_secondsLabel,sel_setHidden_,1);
    pvVar1 = _objc_msgSend(self->_moveValueTextField,sel_formatter);
    pvVar2 = _objc_msgSend(cls_NSNumber,sel_numberWithInt_,1);
    _objc_msgSend(pvVar1,sel_setMinimum_,pvVar2);
    pvVar1 = _objc_msgSend(self->_moveValueTextField,sel_formatter);
    pvVar2 = _objc_msgSend(cls_NSNumber,sel_numberWithInt_,99);
    _objc_msgSend(pvVar1,sel_setMaximum_,pvVar2);
    _objc_msgSend(self->_moveValueStepper,sel_setMaxValue_,0,0x4058c000);
    uVar6 = 0x3ff00000;
    _objc_msgSend(self->_moveValueStepper,sel_setMinValue_,0,0x3ff00000);
    puVar4 = _objc_msgSend(self_00,sel_timesPerSecond);
    if ((int)puVar4 < 100) goto joined_r0x0012e144;
    puVar4 = (undefined *)0x63;
  }
  else {
    if (pvVar1 != (id)0x1) {
      return;
    }
    _objc_msgSend(self->_moveValueTextField,sel_setHidden_,0);
    _objc_msgSend(self->_moveValueStepper,sel_setHidden_,0);
    _objc_msgSend(self->_moveValuePopUpButton,sel_setHidden_,1);
    _objc_msgSend(self->_secondsLabel,sel_setHidden_,0);
    pvVar1 = _objc_msgSend(self->_moveValueTextField,sel_formatter);
    pvVar2 = _objc_msgSend(cls_NSNumber,sel_numberWithInt_,1);
    _objc_msgSend(pvVar1,sel_setMinimum_,pvVar2);
    pvVar1 = _objc_msgSend(self->_moveValueTextField,sel_formatter);
    pvVar2 = _objc_msgSend(cls_NSNumber,sel_numberWithInt_,&DAT_0000270f);
    _objc_msgSend(pvVar1,sel_setMaximum_,pvVar2);
    _objc_msgSend(self->_moveValueStepper,sel_setMinValue_,0,0x3ff00000);
    uVar6 = 0x40c38780;
    _objc_msgSend(self->_moveValueStepper,sel_setMaxValue_,0,0x40c38780);
    dVar5 = _objc_msgSend_fpret(self_00,sel_clampedDuration);
    puVar4 = (undefined *)(int)dVar5;
    if ((int)puVar4 < 10000) {
joined_r0x0012e144:
      if ((int)puVar4 < 1) {
        puVar4 = (undefined *)0x1;
      }
    }
    else {
      puVar4 = &DAT_0000270f;
    }
  }
  _objc_msgSend(self->_moveValueTextField,sel_setIntValue_,puVar4,uVar6);
  pvVar1 = self->_moveValueStepper;
  op = sel_setIntValue_;
LAB_0012e21c:
  _objc_msgSend(pvVar1,op,puVar4);
  return;
}

*/
- (void)updatePathOptionsUI
{
    [self updateBeginAndEndArrows];
    [self updateFlipsUI];
    id animation = [self animation];
    [_pathPlayStopButton setEnabled:[animation animatedObject] != nil];
    BOOL fromEnd = [animation playbackDirection] == 1;
    [_startFromBeginButton setState:!fromEnd];
    [_startFromEndButton setState:fromEnd];
    [self HSAnimationSetupMainAssistantPane_validateGoingAbsoluteLayerGUI];
    [self HSAnimationSetupMainAssistantPane_validateReturningAbsoluteLayerGUI];
    [_floatOverReturningButton setEnabled:[animation playBackAndForth]];
    [_dontEraseReturningButton setEnabled:[animation playBackAndForth]];
    [_dontEraseGoingButton setState:[animation dontEraseGoing] ? 1 : 0];
    [_dontEraseReturningButton setState:[animation dontEraseReturning] ? 1 : 0];
    [_layerPopUpButton selectItemWithTag:[(HSAnimation *)animation layer]];
    NSInteger speedMode = [animation speedMode];
    [self movePopUpButtonSelectItemWithTag:speedMode];
    int value;
    if (speedMode == 0) {
        [_moveValueTextField setHidden:YES];
        [_moveValueStepper setHidden:YES];
        [_moveValuePopUpButton setHidden:NO];
        [_secondsLabel setHidden:YES];
        for (NSInteger tag = 0; tag < 5; tag++) {
            if ((float)[animation speedMultiplier] == HSAnimationSetupSpeedMultipliers[tag]) {
                [_moveValuePopUpButton selectItemWithTag:tag];
                return;
            }
        }
        return;
    }
    if (speedMode == 2) {
        [_moveValueTextField setHidden:NO];
        [_moveValueStepper setHidden:NO];
        [_moveValuePopUpButton setHidden:YES];
        [_secondsLabel setHidden:YES];
        [[_moveValueTextField formatter] setMinimum:[NSNumber numberWithInt:1]];
        [[_moveValueTextField formatter] setMaximum:[NSNumber numberWithInt:99]];
        [_moveValueStepper setMaxValue:99.0];
        [_moveValueStepper setMinValue:1.0];
        value = (int)[animation timesPerSecond];
        if (value >= 100) {
            value = 99;
        }
    }
    else if (speedMode == 1) {
        [_moveValueTextField setHidden:NO];
        [_moveValueStepper setHidden:NO];
        [_moveValuePopUpButton setHidden:YES];
        [_secondsLabel setHidden:NO];
        [[_moveValueTextField formatter] setMinimum:[NSNumber numberWithInt:1]];
        [[_moveValueTextField formatter] setMaximum:[NSNumber numberWithInt:9999]];
        [_moveValueStepper setMinValue:1.0];
        [_moveValueStepper setMaxValue:9999.0];
        value = (int)[animation clampedDuration];
        if (value >= 10000) {
            value = 9999;
        }
    }
    else {
        return;
    }
    if (value < 1) {
        value = 1;
    }
    [_moveValueTextField setIntValue:value];
    [_moveValueStepper setIntValue:value];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0012c918 @ 0012c918, 866 bytes * /

void FUN_0012c918(HSAnimationSetupMainAssistantPane *self,SEL _cmd)

{
  bool bVar1;
  bool bVar2;
  char cVar3;
  id pvVar4;
  id pvVar5;
  undefined4 uVar6;
  bool bVar7;
  uint uVar8;
  
  pvVar4 = _objc_msgSend(self,sel_animation);
  pvVar4 = _objc_msgSend(pvVar4,sel_animatedObject);
  pvVar4 = _objc_msgSend(pvVar4,sel_queryHyperInterface_,&DAT_003726f8);
  pvVar5 = _objc_msgSend(pvVar4,sel_canFlipHorizontally);
  pvVar4 = _objc_msgSend(pvVar4,sel_canFlipVertically);
  cVar3 = (char)pvVar4;
  pvVar4 = _objc_msgSend(self,sel_animation);
  pvVar4 = _objc_msgSend(pvVar4,sel_playBackAndForth);
  if ((char)pvVar4 == '\0') {
LAB_0012c9ef:
    bVar1 = false;
  }
  else {
    pvVar4 = _objc_msgSend(self,sel_animation);
    pvVar4 = _objc_msgSend(pvVar4,sel_playbackDirection);
    if (pvVar4 != (id)0x1) goto LAB_0012c9ef;
    bVar1 = true;
  }
  pvVar4 = _objc_msgSend(self,sel_animation);
  pvVar4 = _objc_msgSend(pvVar4,sel_playBackAndForth);
  if ((char)pvVar4 == '\0') {
LAB_0012ca4f:
    bVar2 = false;
  }
  else {
    pvVar4 = _objc_msgSend(self,sel_animation);
    pvVar4 = _objc_msgSend(pvVar4,sel_playbackDirection);
    if (pvVar4 != (id)0x0) goto LAB_0012ca4f;
    bVar2 = true;
  }
  bVar7 = (char)pvVar5 == '\0';
  _objc_msgSend(self->_horizontalFlipAtStartButton,sel_setEnabled_,(uint)(bVar1 && !bVar7));
  _objc_msgSend(self->_verticalFlipAtStartButton,sel_setEnabled_,bVar1 && cVar3 != '\0');
  _objc_msgSend(self->_horizontalFlipAtFinishButton,sel_setEnabled_,
                CONCAT11(bVar2,!bVar7 && bVar2) & 0xff);
  uVar8 = (uint)(bVar2 && cVar3 != '\0');
  _objc_msgSend(self->_verticalFlipAtFinishButton,sel_setEnabled_,uVar8);
  pvVar4 = self->_horizontalFlipAtStartButton;
  if ((bool)(bVar1 ^ 1U) || bVar7) {
LAB_0012cb43:
    uVar6 = 0;
  }
  else {
    pvVar5 = _objc_msgSend(self,sel_animation,uVar8);
    pvVar5 = _objc_msgSend(pvVar5,sel_horizontalFlipAtStart);
    if ((char)pvVar5 == '\0') goto LAB_0012cb43;
    uVar6 = 1;
  }
  _objc_msgSend(pvVar4,sel_setState_,uVar6);
  pvVar4 = self->_verticalFlipAtStartButton;
  if ((bool)(bVar1 ^ 1U) || cVar3 == '\0') {
LAB_0012cba2:
    uVar6 = 0;
  }
  else {
    pvVar5 = _objc_msgSend(self,sel_animation,uVar6);
    pvVar5 = _objc_msgSend(pvVar5,sel_verticalFlipAtStart);
    if ((char)pvVar5 == '\0') goto LAB_0012cba2;
    uVar6 = 1;
  }
  _objc_msgSend(pvVar4,sel_setState_,uVar6);
  pvVar4 = self->_horizontalFlipAtFinishButton;
  if (bVar7 || (bool)(bVar2 ^ 1U)) {
LAB_0012cc02:
    uVar6 = 0;
  }
  else {
    pvVar5 = _objc_msgSend(self,sel_animation,uVar6);
    pvVar5 = _objc_msgSend(pvVar5,sel_horizontalFlipAtFinish);
    if ((char)pvVar5 == '\0') goto LAB_0012cc02;
    uVar6 = 1;
  }
  _objc_msgSend(pvVar4,sel_setState_,uVar6);
  pvVar4 = self->_verticalFlipAtFinishButton;
  if (!(bool)(bVar2 ^ 1U) && cVar3 != '\0') {
    pvVar5 = _objc_msgSend(self,sel_animation,uVar6);
    pvVar5 = _objc_msgSend(pvVar5,sel_verticalFlipAtFinish);
    if ((char)pvVar5 != '\0') {
      uVar6 = 1;
      goto LAB_0012cc5c;
    }
  }
  uVar6 = 0;
LAB_0012cc5c:
  _objc_msgSend(pvVar4,sel_setState_,uVar6);
  return;
}

*/
- (void)updateFlipsUI
{
    id geometry = [[[self animation] animatedObject] queryHyperInterface:@protocol(HSGeometryBehaviorAttributes)];
    BOOL canFlipHorizontally = [geometry canFlipHorizontally];
    BOOL canFlipVertically = [geometry canFlipVertically];
    // Start flips apply when going back and forth from the end, finish flips from the beginning.
    BOOL atStart = [[self animation] playBackAndForth] && [[self animation] playbackDirection] == 1;
    BOOL atFinish = [[self animation] playBackAndForth] && [[self animation] playbackDirection] == 0;
    [_horizontalFlipAtStartButton setEnabled:atStart && canFlipHorizontally];
    [_verticalFlipAtStartButton setEnabled:atStart && canFlipVertically];
    [_horizontalFlipAtFinishButton setEnabled:atFinish && canFlipHorizontally];
    [_verticalFlipAtFinishButton setEnabled:atFinish && canFlipVertically];
    [_horizontalFlipAtStartButton setState:(atStart && canFlipHorizontally && [[self animation] horizontalFlipAtStart]) ? 1 : 0];
    [_verticalFlipAtStartButton setState:(atStart && canFlipVertically && [[self animation] verticalFlipAtStart]) ? 1 : 0];
    [_horizontalFlipAtFinishButton setState:(atFinish && canFlipHorizontally && [[self animation] horizontalFlipAtFinish]) ? 1 : 0];
    [_verticalFlipAtFinishButton setState:(atFinish && canFlipVertically && [[self animation] verticalFlipAtFinish]) ? 1 : 0];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0012c5ad @ 0012c5ad, 875 bytes * /

void FUN_0012c5ad(HSAnimationSetupMainAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id self_00;
  SEL pcVar6;
  cfstringStruct *pcVar7;
  cfstringStruct *pcVar8;
  cfstringStruct *pcVar9;
  
  pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pcVar8 = &cfstr_empty;
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                         &cfstr_HSAnimationBeginPathToolTip,&cfstr_empty,&cfstr_AssistantPanes);
  pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pcVar9 = &cfstr_AssistantPanes;
  pcVar7 = &cfstr_HSAnimationEndPathToolTip;
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                         &cfstr_HSAnimationEndPathToolTip,&cfstr_empty,&cfstr_AssistantPanes);
  pvVar3 = _objc_msgSend(self,sel_animation);
  pvVar3 = _objc_msgSend(pvVar3,sel_playbackDirection);
  if (pvVar3 == (id)0x0) {
    pvVar3 = self->_beginArrowButton;
    pvVar4 = _objc_msgSend(self,sel_class,pcVar7,pcVar8,pcVar9);
    pvVar4 = _objc_msgSend(pvVar4,sel_leftStartImage);
    _objc_msgSend(pvVar3,sel_setImage_,pvVar4);
    pvVar3 = self->_endArrowButton;
    pvVar5 = _objc_msgSend(self,sel_animation);
    pvVar5 = _objc_msgSend(pvVar5,sel_playBackAndForth);
    self_00 = _objc_msgSend(self,sel_class);
    pcVar6 = sel_rightEndImage;
    if ((char)pvVar5 != '\0') {
      pcVar6 = sel_rightTurnImage;
    }
    pvVar4 = _objc_msgSend(self_00,pcVar6,pvVar4);
    _objc_msgSend(pvVar3,sel_setImage_,pvVar4);
    _objc_msgSend(self->_beginArrowButton,sel_setEnabled_,0);
    _objc_msgSend(self->_endArrowButton,sel_setEnabled_,1);
    _objc_msgSend(self->_beginArrowButton,sel_setToolTip_,pvVar1);
    pvVar3 = self->_endArrowButton;
    pvVar1 = pvVar2;
  }
  else {
    pvVar3 = _objc_msgSend(self,sel_animation,pcVar7,pcVar8,pcVar9);
    pvVar3 = _objc_msgSend(pvVar3,sel_playbackDirection);
    if (pvVar3 != (id)0x1) {
      return;
    }
    pvVar3 = self->_beginArrowButton;
    pvVar4 = _objc_msgSend(self,sel_animation);
    pvVar4 = _objc_msgSend(pvVar4,sel_playBackAndForth);
    pvVar5 = _objc_msgSend(self,sel_class);
    pcVar6 = sel_leftEndImage;
    if ((char)pvVar4 != '\0') {
      pcVar6 = sel_leftTurnImage;
    }
    pvVar4 = _objc_msgSend(pvVar5,pcVar6);
    _objc_msgSend(pvVar3,sel_setImage_,pvVar4);
    pvVar3 = self->_endArrowButton;
    pvVar4 = _objc_msgSend(self,sel_class);
    pvVar4 = _objc_msgSend(pvVar4,sel_rightStartImage);
    _objc_msgSend(pvVar3,sel_setImage_,pvVar4);
    _objc_msgSend(self->_beginArrowButton,sel_setEnabled_,1);
    _objc_msgSend(self->_endArrowButton,sel_setEnabled_,0);
    _objc_msgSend(self->_beginArrowButton,sel_setToolTip_,pvVar2);
    pvVar3 = self->_endArrowButton;
  }
  _objc_msgSend(pvVar3,sel_setToolTip_,pvVar1);
  return;
}

*/
- (void)updateBeginAndEndArrows
{
    NSString *beginToolTip = [[NSBundle mainBundle] localizedStringForKey:@"HSAnimationBeginPathToolTip" value:@"" table:@"AssistantPanes"];
    NSString *endToolTip = [[NSBundle mainBundle] localizedStringForKey:@"HSAnimationEndPathToolTip" value:@"" table:@"AssistantPanes"];
    if ([[self animation] playbackDirection] == 0) {
        [_beginArrowButton setImage:[[self class] leftStartImage]];
        [_endArrowButton setImage:([[self animation] playBackAndForth] ? [[self class] rightTurnImage] : [[self class] rightEndImage])];
        [_beginArrowButton setEnabled:NO];
        [_endArrowButton setEnabled:YES];
        [_beginArrowButton setToolTip:beginToolTip];
        [_endArrowButton setToolTip:endToolTip];
    }
    else if ([[self animation] playbackDirection] == 1) {
        [_beginArrowButton setImage:([[self animation] playBackAndForth] ? [[self class] leftTurnImage] : [[self class] leftEndImage])];
        [_endArrowButton setImage:[[self class] rightStartImage]];
        [_beginArrowButton setEnabled:YES];
        [_endArrowButton setEnabled:NO];
        // With the direction reversed the two tooltips swap buttons.
        [_beginArrowButton setToolTip:endToolTip];
        [_endArrowButton setToolTip:beginToolTip];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0012c456 @ 0012c456, 343 bytes * /

void FUN_0012c456(HSAnimationSetupMainAssistantPane *self,SEL _cmd,int setLayer)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(self,sel_undoManager);
  pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_Change_Options,
                         &cfstr_empty,&cfstr_UndoManager);
  _objc_msgSend(pvVar1,sel_setActionName_,pvVar2);
  pvVar1 = _objc_msgSend(self,sel_undoManager);
  pvVar1 = _objc_msgSend(pvVar1,sel_prepareWithInvocationTarget_,self);
  pvVar2 = _objc_msgSend(self,sel_animation);
  pvVar2 = _objc_msgSend(pvVar2,sel_layer);
  _objc_msgSend(pvVar1,sel_setLayer_,pvVar2);
  pvVar1 = _objc_msgSend(self,sel_undoHelper);
  _objc_msgSend(pvVar1,sel_duplicateAction);
  pvVar1 = _objc_msgSend(self,sel_allAnimations);
  _objc_msgSend(pvVar1,sel_setLayer_,setLayer);
  _objc_msgSend(self,sel_updatePathOptionsUI);
  return;
}

*/
- (void)setLayer:(NSInteger)aLayer
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [(HSAnimationSetupMainAssistantPane *)[[self undoManager] prepareWithInvocationTarget:self] setLayer:[(HSAnimation *)[self animation] layer]];
    [[self undoHelper] duplicateAction];
    [(HSAnimation *)[self allAnimations] setLayer:aLayer];
    [self updatePathOptionsUI];
}

- (void)changeLayer:(id)aLayer
{
    id pvVar1_3;

    [self setLayer:[[aLayer selectedItem] tag]];
    pvVar1_3 = _layerPopUpButton;
    [pvVar1_3 setToolTip:[[pvVar1_3 selectedItem] toolTip]];
}

- (void)setSpeedMultiplier:(CGFloat)aMultiplier
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setSpeedMultiplier:(float)[[self animation] speedMultiplier]];
    [[self undoHelper] duplicateAction];
    [[self allAnimations] setSpeedMultiplier:aMultiplier];
    [self updatePathOptionsUI];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0012c363 @ 0012c363, 94 bytes * /

void FUN_0012c363(HSAnimationSetupMainAssistantPane *self,SEL _cmd,id changeMoveValueFromPopUpButton
                 )

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(changeMoveValueFromPopUpButton,sel_selectedItem);
  pvVar1 = _objc_msgSend(pvVar1,sel_tag);
  _objc_msgSend(self,sel_setSpeedMultiplier_,(&DAT_00335300)[(int)pvVar1]);
  return;
}

*/
- (void)changeMoveValueFromPopUpButton:(id)aButton
{
    [self setSpeedMultiplier:HSAnimationSetupSpeedMultipliers[[[aButton selectedItem] tag]]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0012e38f @ 0012e38f, 499 bytes * /

void FUN_0012e38f(HSAnimationSetupMainAssistantPane *self,SEL _cmd,int setClampedDuration,
                 int timesPerSecond)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  double dVar3;
  undefined8 uVar4;
  
  pvVar1 = _objc_msgSend(self,sel_undoManager);
  pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_Change_Options,
                         &cfstr_empty,&cfstr_UndoManager);
  _objc_msgSend(pvVar1,sel_setActionName_,pvVar2);
  pvVar1 = _objc_msgSend(self,sel_undoManager);
  pvVar1 = _objc_msgSend(pvVar1,sel_prepareWithInvocationTarget_,self);
  pvVar2 = _objc_msgSend(self,sel_animation);
  pvVar2 = _objc_msgSend(pvVar2,sel_timesPerSecond);
  self_00 = _objc_msgSend(self,sel_animation);
  dVar3 = _objc_msgSend_fpret(self_00,sel_clampedDuration);
  uVar4 = CONCAT44(pvVar2,(int)dVar3);
  _objc_msgSend(pvVar1,sel_setClampedDuration_timesPerSecond_,(int)dVar3,pvVar2);
  pvVar1 = _objc_msgSend(self,sel_undoHelper);
  _objc_msgSend(pvVar1,sel_duplicateAction);
  if (setClampedDuration < 10000) {
    if (setClampedDuration < 1) {
      setClampedDuration = 1;
    }
  }
  else {
    setClampedDuration = (int)&DAT_0000270f;
  }
  pvVar1 = _objc_msgSend(self,sel_allAnimations,uVar4);
  dVar3 = (double)setClampedDuration;
  _objc_msgSend(pvVar1,sel_setClampedDuration_,dVar3);
  if (timesPerSecond < 100) {
    if (timesPerSecond < 1) {
      timesPerSecond = 1;
    }
  }
  else {
    timesPerSecond = 99;
  }
  pvVar1 = _objc_msgSend(self,sel_allAnimations,dVar3);
  _objc_msgSend(pvVar1,sel_setTimesPerSecond_,timesPerSecond);
  _objc_msgSend(self,sel_updatePathOptionsUI);
  return;
}

*/
- (void)setClampedDuration:(NSInteger)aDuration timesPerSecond:(NSInteger)aSecond
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setClampedDuration:(int)[[self animation] clampedDuration] timesPerSecond:[[self animation] timesPerSecond]];
    [[self undoHelper] duplicateAction];
    NSInteger duration = aDuration;
    if (duration >= 10000) {
        duration = 9999;
    }
    else if (duration < 1) {
        duration = 1;
    }
    [[self allAnimations] setClampedDuration:(double)duration];
    NSInteger timesPerSecond = aSecond;
    if (timesPerSecond >= 100) {
        timesPerSecond = 99;
    }
    else if (timesPerSecond < 1) {
        timesPerSecond = 1;
    }
    [[self allAnimations] setTimesPerSecond:timesPerSecond];
    [self updatePathOptionsUI];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0012e582 @ 0012e582, 328 bytes * /

void FUN_0012e582(HSAnimationSetupMainAssistantPane *self,SEL _cmd,id changeMoveValue)

{
  id pvVar1;
  id pvVar2;
  double dVar3;
  id local_28;
  
  pvVar1 = _objc_msgSend(self,sel_animation);
  dVar3 = _objc_msgSend_fpret(pvVar1,sel_clampedDuration);
  pvVar1 = _objc_msgSend(self,sel_animation);
  local_28 = _objc_msgSend(pvVar1,sel_timesPerSecond);
  pvVar1 = (id)(int)dVar3;
  if (self->_moveValueStepper != changeMoveValue) {
    _objc_msgSend(self->_moveValuePopUpButton,sel_takeIntValueFrom_,changeMoveValue);
  }
  if (self->_moveValueTextField != changeMoveValue) {
    _objc_msgSend(self->_moveValueTextField,sel_takeIntValueFrom_,changeMoveValue);
  }
  pvVar2 = _objc_msgSend(self->_movePopUpButton,sel_selectedCell);
  pvVar2 = _objc_msgSend(pvVar2,sel_tag);
  if (pvVar2 == (id)0x1) {
    pvVar1 = _objc_msgSend(changeMoveValue,sel_intValue);
  }
  else if (pvVar2 == (id)0x2) {
    local_28 = _objc_msgSend(changeMoveValue,sel_intValue);
  }
  _objc_msgSend(self,sel_setClampedDuration_timesPerSecond_,pvVar1,local_28);
  return;
}

*/
- (void)changeMoveValue:(id)aValue
{
    NSInteger duration = (int)[[self animation] clampedDuration];
    NSInteger timesPerSecond = [[self animation] timesPerSecond];
    // The original fed the pop-up, not the stepper, when the value came from elsewhere.
    if (_moveValueStepper != aValue) {
        [_moveValuePopUpButton takeIntValueFrom:aValue];
    }
    if (_moveValueTextField != aValue) {
        [_moveValueTextField takeIntValueFrom:aValue];
    }
    NSInteger mode = [[_movePopUpButton selectedCell] tag];
    if (mode == 1) {
        duration = [aValue intValue];
    }
    else if (mode == 2) {
        timesPerSecond = [aValue intValue];
    }
    [self setClampedDuration:duration timesPerSecond:timesPerSecond];
}

- (void)setSpeedMode:(NSInteger)aMode
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setSpeedMode:[[self animation] speedMode]];
    [[self undoHelper] duplicateAction];
    [[self allAnimations] setSpeedMode:aMode];
    [self updatePathOptionsUI];
}

- (void)changeMove:(id)aMove
{
    [self setSpeedMode:[[aMove selectedCell] tag]];
}

- (void)setDontEraseReturning:(BOOL)aReturning
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setDontEraseReturning:(unsigned int)(aReturning == 0)];
    [[self undoHelper] duplicateAction];
    [[self allAnimations] setDontEraseReturning:aReturning];
    [self updatePathOptionsUI];
}

- (void)toggleDontEraseReturning:(id)aReturning
{
    [self setDontEraseReturning:(unsigned int)(![[self animation] dontEraseReturning])];
}

- (void)setDontEraseGoing:(BOOL)aGoing
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setDontEraseGoing:(unsigned int)(aGoing == 0)];
    [[self undoHelper] duplicateAction];
    [[self allAnimations] setDontEraseGoing:aGoing];
    [self updatePathOptionsUI];
}

- (void)toggleDontEraseGoing:(id)aGoing
{
    [self setDontEraseGoing:(unsigned int)(![[self animation] dontEraseGoing])];
}

- (void)changeReturningAbsoluteLayer:(id)aLayer
{
    [self HSAnimationSetupMainAssistantPane_setReturningAbsoluteLayer:[[aLayer selectedItem] tag]];
}

- (void)HSAnimationSetupMainAssistantPane_setReturningAbsoluteLayer:(NSInteger)aLayer
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] HSAnimationSetupMainAssistantPane_setReturningAbsoluteLayer:[[self animation] returningAbsoluteLayer]];
    [[self undoHelper] duplicateAction];
    [[self allAnimations] setReturningAbsoluteLayer:aLayer];
    [self HSAnimationSetupMainAssistantPane_validateReturningAbsoluteLayerGUI];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0012bbf9 @ 0012bbf9, 238 bytes * /

void FUN_0012bbf9(HSAnimationSetupMainAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_animation);
  pvVar2 = _objc_msgSend(pvVar1,sel_returningAbsoluteLayer);
  pvVar1 = self->_returningImageView;
  pvVar3 = _objc_msgSend(self,sel_class);
  op = sel_noFloatOverImage;
  if (pvVar2 != (id)0x0) {
    op = sel_floatOverImage;
  }
  pvVar3 = _objc_msgSend(pvVar3,op);
  _objc_msgSend(pvVar1,sel_setImage_,pvVar3);
  _objc_msgSend(self->_floatOverReturningButton,sel_selectItemWithTag_,pvVar2);
  pvVar1 = self->_floatOverReturningButton;
  pvVar2 = _objc_msgSend(pvVar1,sel_selectedItem);
  pvVar2 = _objc_msgSend(pvVar2,sel_toolTip);
  _objc_msgSend(pvVar1,sel_setToolTip_,pvVar2);
  return;
}

*/
- (void)HSAnimationSetupMainAssistantPane_validateReturningAbsoluteLayerGUI
{
    NSInteger layer = [[self animation] returningAbsoluteLayer];
    [_returningImageView setImage:(layer != 0 ? [[self class] floatOverImage] : [[self class] noFloatOverImage])];
    [_floatOverReturningButton selectItemWithTag:layer];
    [_floatOverReturningButton setToolTip:[[_floatOverReturningButton selectedItem] toolTip]];
}

- (void)changeGoingAbsoluteLayer:(id)aLayer
{
    [self HSAnimationSetupMainAssistantPane_setGoingAbsoluteLayer:[[aLayer selectedItem] tag]];
}

- (void)HSAnimationSetupMainAssistantPane_setGoingAbsoluteLayer:(NSInteger)aLayer
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] HSAnimationSetupMainAssistantPane_setGoingAbsoluteLayer:[[self animation] goingAbsoluteLayer]];
    [[self undoHelper] duplicateAction];
    [[self allAnimations] setGoingAbsoluteLayer:aLayer];
    [self HSAnimationSetupMainAssistantPane_validateGoingAbsoluteLayerGUI];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0012b961 @ 0012b961, 238 bytes * /

void FUN_0012b961(HSAnimationSetupMainAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_animation);
  pvVar2 = _objc_msgSend(pvVar1,sel_goingAbsoluteLayer);
  pvVar1 = self->_goingImageView;
  pvVar3 = _objc_msgSend(self,sel_class);
  op = sel_noFloatOverImage;
  if (pvVar2 != (id)0x0) {
    op = sel_floatOverImage;
  }
  pvVar3 = _objc_msgSend(pvVar3,op);
  _objc_msgSend(pvVar1,sel_setImage_,pvVar3);
  _objc_msgSend(self->_floatOverGoingButton,sel_selectItemWithTag_,pvVar2);
  pvVar1 = self->_floatOverGoingButton;
  pvVar2 = _objc_msgSend(pvVar1,sel_selectedItem);
  pvVar2 = _objc_msgSend(pvVar2,sel_toolTip);
  _objc_msgSend(pvVar1,sel_setToolTip_,pvVar2);
  return;
}

*/
- (void)HSAnimationSetupMainAssistantPane_validateGoingAbsoluteLayerGUI
{
    NSInteger layer = [[self animation] goingAbsoluteLayer];
    [_goingImageView setImage:(layer != 0 ? [[self class] floatOverImage] : [[self class] noFloatOverImage])];
    [_floatOverGoingButton selectItemWithTag:layer];
    [_floatOverGoingButton setToolTip:[[_floatOverGoingButton selectedItem] toolTip]];
}

- (void)framesPerSecondChanged:(id)aChanged
{
    [self changeMovieSpeeed:aChanged];
}

- (void)setPlaybackDirection:(NSInteger)aDirection
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setPlaybackDirection:[[self animation] playbackDirection]];
    [[self undoHelper] duplicateAction];
    [[self allAnimations] setPlaybackDirection:aDirection];
    [self updatePathOptionsUI];
    [_delegate updatePathInEditPathTool];
}

- (void)toggleStartHere:(id)aHere
{
    [self setPlaybackDirection:(unsigned int)(_startFromEndButton == aHere)]
    ;
}

- (void)setVerticalFlipAtFinish:(BOOL)aFinish
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setVerticalFlipAtFinish:(unsigned int)(aFinish == 0)];
    [[self undoHelper] duplicateAction];
    [[self allAnimations] setVerticalFlipAtFinish:aFinish];
    [self updatePathOptionsUI];
}

- (void)toggleVerticalFlipAtFinish:(id)aFinish
{
    [self setVerticalFlipAtFinish:(unsigned int)(![[self animation] verticalFlipAtFinish])];
}

- (void)setHorizontalFlipAtFinish:(BOOL)aFinish
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHorizontalFlipAtFinish:(unsigned int)(aFinish == 0)];
    [[self undoHelper] duplicateAction];
    [[self allAnimations] setHorizontalFlipAtFinish:aFinish];
    [self updatePathOptionsUI];
}

- (void)toggleHorizontalFlipAtFinish:(id)aFinish
{
    [self setHorizontalFlipAtFinish:(unsigned int)(![[self animation] horizontalFlipAtFinish])];
}

- (void)setVerticalFlipAtStart:(BOOL)aStart
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setVerticalFlipAtStart:(unsigned int)(aStart == 0)];
    [[self undoHelper] duplicateAction];
    [[self allAnimations] setVerticalFlipAtStart:aStart];
    [self updatePathOptionsUI];
}

- (void)toggleVerticalFlipAtStart:(id)aStart
{
    [self setVerticalFlipAtStart:(unsigned int)(![[self animation] verticalFlipAtStart])];
}

- (void)setHorizontalFlipAtStart:(BOOL)aStart
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHorizontalFlipAtStart:(unsigned int)(aStart == 0)];
    [[self undoHelper] duplicateAction];
    [[self allAnimations] setHorizontalFlipAtStart:aStart];
    [self updatePathOptionsUI];
}

- (void)toggleHorizontalFlipAtStart:(id)aStart
{
    [self setHorizontalFlipAtStart:(unsigned int)(![[self animation] horizontalFlipAtStart])];
}

- (void)setPlayBackAndForth:(BOOL)aForth
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setPlayBackAndForth:(unsigned int)(aForth == 0)];
    [[self undoHelper] duplicateAction];
    [[self allAnimations] setPlayBackAndForth:aForth];
    [self updatePathOptionsUI];
}

- (void)toggleEndArrow:(id)aArrow
{
    if ([[self animation] playbackDirection] == 0) {
        [self setPlayBackAndForth:(unsigned int)(![[self animation] playBackAndForth])];
    }
}

- (void)toggleBeginArrow:(id)aArrow
{
    if ([[self animation] playbackDirection] == 0x1) {
        [self setPlayBackAndForth:(unsigned int)(![[self animation] playBackAndForth])];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0012e6ca @ 0012e6ca, 2455 bytes * /

void FUN_0012e6ca(HSAnimationSetupMainAssistantPane *self,SEL _cmd)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  undefined4 uVar4;
  id pvVar5;
  int iVar6;
  uint uVar7;
  char cVar8;
  uint uVar9;
  int iVar10;
  double dVar11;
  SEL op;
  undefined8 in_stack_ffffffbc;
  longlong lVar12;
  undefined8 uVar13;
  ulonglong uVar14;
  undefined4 uVar15;
  
  uVar15 = (undefined4)((ulonglong)in_stack_ffffffbc >> 0x20);
  pvVar2 = _objc_msgSend(self,sel_animation);
  pvVar2 = _objc_msgSend(pvVar2,sel_playMovie);
  cVar8 = (char)pvVar2;
  pvVar2 = _objc_msgSend(self,sel_animation);
  pvVar2 = _objc_msgSend(pvVar2,sel_isOnePointPathAnimation);
  cVar1 = (char)pvVar2;
  uVar7 = (uint)(cVar1 == '\0');
  lVar12 = CONCAT44(uVar15,uVar7);
  _objc_msgSend(self->_segmentedControl,sel_setEnabled_,uVar7);
  if (cVar1 != '\0') {
    pvVar2 = self->_mainOptionsView;
    _objc_msgSend(self->_optionsView,sel_replaceSubview_with_,self->_pathOptionsView,pvVar2);
    lVar12 = ZEXT48(pvVar2) << 0x20;
    _objc_msgSend(self->_segmentedControl,sel_selectCellWithTag_,0);
  }
  pvVar2 = _objc_msgSend(self,sel_animation,lVar12);
  uVar15 = (undefined4)((ulonglong)lVar12 >> 0x20);
  pvVar2 = _objc_msgSend(pvVar2,sel_animatedObject);
  uVar9 = (uint)(pvVar2 != (id)0x0);
  _objc_msgSend(self->_mainPlayStopButton,sel_setEnabled_,uVar9);
  uVar13 = CONCAT44(uVar15,uVar9);
  _objc_msgSend(self->_newPathButton,sel_setEnabled_,uVar9);
  if (pvVar2 == (id)0x0) {
LAB_0012e841:
    uVar15 = (undefined4)((ulonglong)uVar13 >> 0x20);
    uVar4 = 1;
  }
  else {
    pvVar3 = _objc_msgSend(self,sel_animation,uVar13);
    pvVar3 = _objc_msgSend(pvVar3,sel_hideOnFirstFrame);
    uVar15 = (undefined4)((ulonglong)uVar13 >> 0x20);
    if ((char)pvVar3 == '\0') goto LAB_0012e841;
    uVar4 = 0;
  }
  _objc_msgSend(self->_showFirstFrameButton,sel_setState_,uVar4);
  uVar13 = CONCAT44(uVar15,uVar9);
  _objc_msgSend(self->_showFirstFrameButton,sel_setEnabled_,uVar9);
  if (pvVar2 == (id)0x0) {
LAB_0012e8b6:
    uVar15 = (undefined4)((ulonglong)uVar13 >> 0x20);
    uVar4 = 0;
  }
  else {
    pvVar3 = _objc_msgSend(self,sel_animation,uVar13);
    pvVar3 = _objc_msgSend(pvVar3,sel_hideOnLastFrame);
    uVar15 = (undefined4)((ulonglong)uVar13 >> 0x20);
    if ((char)pvVar3 == '\0') goto LAB_0012e8b6;
    uVar4 = 1;
  }
  _objc_msgSend(self->_eraseWhenDoneButton,sel_setState_,uVar4);
  _objc_msgSend(self->_eraseWhenDoneButton,sel_setEnabled_,uVar9);
  pvVar3 = _objc_msgSend(self->_matchToMovementMatrix,sel_cellWithTag_,0);
  _objc_msgSend(pvVar3,sel_setEnabled_,(uint)(cVar1 == '\0' && (pvVar2 != (id)0x0 && cVar8 != '\0'))
               );
  pvVar3 = _objc_msgSend(self->_matchToMovementMatrix,sel_cellWithTag_,1);
  iVar6 = (int)cVar8;
  uVar13 = CONCAT44(uVar15,iVar6);
  _objc_msgSend(pvVar3,sel_setEnabled_,iVar6,uVar15,iVar6);
  pvVar3 = self->_matchToMovementMatrix;
  if (cVar8 == '\0') {
LAB_0012e992:
    uVar9 = 1;
  }
  else {
    pvVar5 = _objc_msgSend(self,sel_animation,uVar13);
    pvVar5 = _objc_msgSend(pvVar5,sel_matchToMovement);
    if ((char)pvVar5 == '\0') goto LAB_0012e992;
    uVar9 = 0;
  }
  uVar14 = (ulonglong)uVar9;
  _objc_msgSend(pvVar3,sel_selectCellAtRow_column_,uVar9,0);
  if ((pvVar2 == (id)0x0) || (cVar1 != '\0')) {
LAB_0012ea0d:
    uVar15 = (undefined4)(uVar14 >> 0x20);
    cVar1 = '\0';
  }
  else {
    pvVar3 = _objc_msgSend(self,sel_isMovieAnimation,uVar14);
    uVar15 = (undefined4)(uVar14 >> 0x20);
    if ((char)pvVar3 != '\0') goto LAB_0012ea0d;
    cVar1 = '\x01';
  }
  _objc_msgSend(self->_allowClonesButton,sel_setEnabled_,(int)cVar1);
  pvVar3 = self->_allowClonesButton;
  pvVar5 = _objc_msgSend(self,sel_animation);
  pvVar5 = _objc_msgSend(pvVar5,sel_useClones);
  uVar9 = (uint)((char)pvVar5 != '\0');
  uVar13 = CONCAT44(uVar15,uVar9);
  _objc_msgSend(pvVar3,sel_setState_,uVar9);
  if (pvVar2 != (id)0x0 && cVar8 != '\0') {
    pvVar3 = _objc_msgSend(self,sel_animation,uVar13);
    pvVar3 = _objc_msgSend(pvVar3,sel_matchToMovement);
    uVar15 = (undefined4)((ulonglong)uVar13 >> 0x20);
    if ((char)pvVar3 != '\0') goto LAB_0012eab0;
    cVar8 = '\x01';
  }
  else {
LAB_0012eab0:
    uVar15 = (undefined4)((ulonglong)uVar13 >> 0x20);
    cVar8 = '\0';
  }
  iVar10 = (int)cVar8;
  _objc_msgSend(self->_movieSpeedTextField,sel_setEnabled_,iVar10);
  uVar13 = CONCAT44(uVar15,iVar10);
  _objc_msgSend(self->_movieSpeedStepper,sel_setEnabled_,iVar10);
  if (cVar8 == '\0') {
    uVar15 = (undefined4)((ulonglong)uVar13 >> 0x20);
    _objc_msgSend(self->_movieSpeedTextField,sel_setStringValue_,&cfstr_empty);
  }
  else {
    pvVar3 = _objc_msgSend(self,sel_animation,uVar13);
    dVar11 = _objc_msgSend_fpret(pvVar3,sel_movieSpeed);
    _objc_msgSend(self->_movieSpeedTextField,sel_setDoubleValue_,dVar11);
    _objc_msgSend(self->_movieSpeedStepper,sel_setDoubleValue_,dVar11);
    uVar15 = (undefined4)((ulonglong)dVar11 >> 0x20);
  }
  pvVar3 = self->_playForPopUpButton;
  pvVar5 = _objc_msgSend(pvVar3,sel_indexOfItemWithTag_,2);
  pvVar3 = _objc_msgSend(pvVar3,sel_itemAtIndex_,pvVar5);
  _objc_msgSend(pvVar3,sel_setEnabled_,iVar6);
  pvVar3 = self->_playForPopUpButton;
  pvVar5 = _objc_msgSend(pvVar3,sel_indexOfItemWithTag_,1);
  pvVar3 = _objc_msgSend(pvVar3,sel_itemAtIndex_,pvVar5);
  uVar13 = CONCAT44(uVar15,uVar7);
  _objc_msgSend(pvVar3,sel_setEnabled_,uVar7);
  if (pvVar2 == (id)0x0) {
LAB_0012ec6a:
    uVar15 = (undefined4)((ulonglong)uVar13 >> 0x20);
    cVar8 = '\0';
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_animation,uVar13);
    pvVar2 = _objc_msgSend(pvVar2,sel_loopMode);
    uVar15 = (undefined4)((ulonglong)uVar13 >> 0x20);
    if (pvVar2 == (id)0x1) goto LAB_0012ec6a;
    cVar8 = '\x01';
  }
  iVar6 = (int)cVar8;
  _objc_msgSend(self->_playForValueTextField,sel_setEnabled_,iVar6);
  uVar13 = CONCAT44(uVar15,iVar6);
  _objc_msgSend(self->_playForValueStepper,sel_setEnabled_,iVar6);
  pvVar2 = _objc_msgSend(self,sel_animation);
  pvVar2 = _objc_msgSend(pvVar2,sel_loopMode);
  if (pvVar2 == (id)0x3) {
    uVar15 = (undefined4)((ulonglong)uVar13 >> 0x20);
    _objc_msgSend(self,sel_playForPopUpButtonSelectItemWithTag_,0);
    pvVar2 = self->_playForValueTextField;
    pvVar3 = _objc_msgSend(self,sel_animation);
    dVar11 = _objc_msgSend_fpret(pvVar3,sel_loopSeconds);
    uVar13 = CONCAT44(uVar15,(int)dVar11);
    _objc_msgSend(pvVar2,sel_setIntValue_,(int)dVar11);
    goto LAB_0012ef60;
  }
  pvVar2 = _objc_msgSend(self,sel_animation,uVar13);
  pvVar2 = _objc_msgSend(pvVar2,sel_loopMode);
  if (pvVar2 == (id)0x0) {
LAB_0012ed95:
    uVar13 = CONCAT44((int)((ulonglong)uVar13 >> 0x20),1);
    _objc_msgSend(self,sel_playForPopUpButtonSelectItemWithTag_,1);
    pvVar2 = _objc_msgSend(self,sel_animation);
    pvVar2 = _objc_msgSend(pvVar2,sel_loopMode);
    if (pvVar2 == (id)0x0) {
      pvVar2 = self->_playForValueTextField;
      uVar13 = CONCAT44((int)((ulonglong)uVar13 >> 0x20),1);
      op = sel_setIntValue_;
    }
    else {
      pvVar2 = _objc_msgSend(self,sel_animation,uVar13);
      pvVar2 = _objc_msgSend(pvVar2,sel_loopMode);
      if (pvVar2 != (id)0x2) goto LAB_0012ef60;
      pvVar2 = self->_playForValueTextField;
      pvVar3 = _objc_msgSend(self,sel_animation);
      uVar15 = (undefined4)((ulonglong)uVar13 >> 0x20);
      pvVar3 = _objc_msgSend(pvVar3,sel_loopPathRepeats);
      uVar13 = CONCAT44(uVar15,pvVar3);
      op = sel_setIntValue_;
    }
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_animation);
    pvVar2 = _objc_msgSend(pvVar2,sel_loopMode);
    if (pvVar2 == (id)0x2) goto LAB_0012ed95;
    pvVar2 = _objc_msgSend(self,sel_animation);
    pvVar2 = _objc_msgSend(pvVar2,sel_loopMode);
    if (pvVar2 == (id)0x4) {
      uVar15 = (undefined4)((ulonglong)uVar13 >> 0x20);
      _objc_msgSend(self,sel_playForPopUpButtonSelectItemWithTag_,2);
      pvVar2 = self->_playForValueTextField;
      pvVar3 = _objc_msgSend(self,sel_animation);
      pvVar3 = _objc_msgSend(pvVar3,sel_loopFrameRepeats);
      uVar13 = CONCAT44(uVar15,pvVar3);
      op = sel_setIntValue_;
    }
    else {
      pvVar2 = _objc_msgSend(self,sel_animation);
      pvVar2 = _objc_msgSend(pvVar2,sel_loopMode);
      if (pvVar2 != (id)0x1) goto LAB_0012ef60;
      uVar15 = (undefined4)((ulonglong)uVar13 >> 0x20);
      _objc_msgSend(self,sel_playForPopUpButtonSelectItemWithTag_,3);
      pvVar2 = self->_playForValueTextField;
      uVar13 = CONCAT44(uVar15,&cfstr_empty);
      op = sel_setStringValue_;
    }
  }
  _objc_msgSend(pvVar2,op,uVar13);
LAB_0012ef60:
  pvVar2 = self->_playForValueStepper;
  pvVar3 = _objc_msgSend(self->_playForValueTextField,sel_intValue,uVar13);
  _objc_msgSend(pvVar2,sel_setIntValue_,pvVar3);
  _objc_msgSend(self,sel_transparentColorValidate);
  pvVar2 = _objc_msgSend(self,sel_animation);
  pvVar2 = _objc_msgSend(pvVar2,sel_animatedObject);
  pvVar3 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_003726f8);
  pvVar2 = self->_horizontalFlipButton;
  pvVar5 = _objc_msgSend(pvVar3,sel_canFlipHorizontally);
  _objc_msgSend(pvVar2,sel_setEnabled_,(int)(char)pvVar5);
  pvVar2 = self->_verticalFlipButton;
  pvVar3 = _objc_msgSend(pvVar3,sel_canFlipVertically);
  _objc_msgSend(pvVar2,sel_setEnabled_,(int)(char)pvVar3);
  return;
}

*/
- (void)updateMainOptionsUI
{
    BOOL playMovie = [[self animation] playMovie];
    BOOL onePoint = [[self animation] isOnePointPathAnimation];
    [_segmentedControl setEnabled:!onePoint];
    if (onePoint) {
        [_optionsView replaceSubview:_pathOptionsView with:_mainOptionsView];
        [_segmentedControl selectCellWithTag:0];
    }
    id animatedObject = [[self animation] animatedObject];
    BOOL hasObject = animatedObject != nil;
    [_mainPlayStopButton setEnabled:hasObject];
    [_newPathButton setEnabled:hasObject];
    [_showFirstFrameButton setState:(hasObject && [[self animation] hideOnFirstFrame]) ? 0 : 1];
    [_showFirstFrameButton setEnabled:hasObject];
    [_eraseWhenDoneButton setState:(hasObject && [[self animation] hideOnLastFrame]) ? 1 : 0];
    [_eraseWhenDoneButton setEnabled:hasObject];
    [[_matchToMovementMatrix cellWithTag:0] setEnabled:!onePoint && hasObject && playMovie];
    [[_matchToMovementMatrix cellWithTag:1] setEnabled:playMovie];
    [_matchToMovementMatrix selectCellAtRow:(playMovie && [[self animation] matchToMovement]) ? 0 : 1 column:0];
    [_allowClonesButton setEnabled:hasObject && !onePoint && ![self isMovieAnimation]];
    [_allowClonesButton setState:[[self animation] useClones] ? 1 : 0];
    BOOL editsSpeed = hasObject && playMovie && ![[self animation] matchToMovement];
    [_movieSpeedTextField setEnabled:editsSpeed];
    [_movieSpeedStepper setEnabled:editsSpeed];
    if (editsSpeed) {
        double speed = [[self animation] movieSpeed];
        [_movieSpeedTextField setDoubleValue:speed];
        [_movieSpeedStepper setDoubleValue:speed];
    }
    else {
        [_movieSpeedTextField setStringValue:@""];
    }
    [[_playForPopUpButton itemAtIndex:[_playForPopUpButton indexOfItemWithTag:2]] setEnabled:playMovie];
    [[_playForPopUpButton itemAtIndex:[_playForPopUpButton indexOfItemWithTag:1]] setEnabled:!onePoint];
    BOOL editsPlayFor = hasObject && [[self animation] loopMode] != 1;
    [_playForValueTextField setEnabled:editsPlayFor];
    [_playForValueStepper setEnabled:editsPlayFor];
    // Loop modes: 0 none, 1 forever, 2 path repeats, 3 seconds, 4 frame repeats.
    NSInteger loopMode = [[self animation] loopMode];
    if (loopMode == 3) {
        [self playForPopUpButtonSelectItemWithTag:0];
        [_playForValueTextField setIntValue:(int)[[self animation] loopSeconds]];
    }
    else if (loopMode == 0 || loopMode == 2) {
        [self playForPopUpButtonSelectItemWithTag:1];
        if ([[self animation] loopMode] == 0) {
            [_playForValueTextField setIntValue:1];
        }
        else if ([[self animation] loopMode] == 2) {
            [_playForValueTextField setIntValue:(int)[[self animation] loopPathRepeats]];
        }
    }
    else if (loopMode == 4) {
        [self playForPopUpButtonSelectItemWithTag:2];
        [_playForValueTextField setIntValue:(int)[[self animation] loopFrameRepeats]];
    }
    else if (loopMode == 1) {
        [self playForPopUpButtonSelectItemWithTag:3];
        [_playForValueTextField setStringValue:@""];
    }
    [_playForValueStepper setIntValue:[_playForValueTextField intValue]];
    [self transparentColorValidate];
    id geometry = [[[self animation] animatedObject] queryHyperInterface:@protocol(HSGeometryBehaviorAttributes)];
    [_horizontalFlipButton setEnabled:[geometry canFlipHorizontally]];
    [_verticalFlipButton setEnabled:[geometry canFlipVertically]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0012ac83 @ 0012ac83, 637 bytes * /

void FUN_0012ac83(HSAnimationSetupMainAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  undefined *puVar3;
  undefined4 uVar4;
  
  pvVar1 = _objc_msgSend(self,sel_animation);
  pvVar1 = _objc_msgSend(pvVar1,sel_animatedObject);
  pvVar2 = _objc_msgSend(pvVar1,sel_implementsHyperInterface_,&DAT_0037243c);
  if ((char)pvVar2 == '\0') {
LAB_0012ae5c:
    _objc_msgSend(self->_transparentColorPickerButton,sel_setEnabled_,0);
    _objc_msgSend(self->_transparentColorPickerButton,sel_setState_,0);
    pvVar1 = self->_transparentColorPickerButton;
    pvVar2 = _objc_msgSend(self->_transparentColorButton,sel_title);
    _objc_msgSend(pvVar1,sel_setTitle_,pvVar2);
    _objc_msgSend(self->_transparentColorPickerButton,sel_sizeToFit);
    pvVar1 = self->_transparentColorButton;
  }
  else {
    puVar3 = &DAT_003724f0;
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_003724f0);
    if (pvVar1 != (id)0x0) {
      pvVar2 = _objc_msgSend(pvVar1,sel_isHyperQTVR,puVar3);
      if ((char)pvVar2 == '\0') {
        pvVar1 = _objc_msgSend(pvVar1,sel_isHyperPanoramaObject,puVar3);
        if ((char)pvVar1 == '\0') goto LAB_0012ad35;
      }
      goto LAB_0012ae5c;
    }
LAB_0012ad35:
    pvVar1 = _objc_msgSend(self,sel_allAnimations,puVar3);
    pvVar1 = _objc_msgSend(pvVar1,sel_usesTransparentColor);
    if ((char)pvVar1 != '\0') {
      _objc_msgSend(self->_transparentColorPickerButton,sel_setState_,1);
      _objc_msgSend(self->_transparentColorPickerButton,sel_setTitle_,&cfstr_empty);
      _objc_msgSend(self->_transparentColorPickerButton,sel_sizeToFit);
      pvVar1 = self->_transparentColorButton;
      uVar4 = 0;
      goto LAB_0012ae4f;
    }
    _objc_msgSend(self->_transparentColorPickerButton,sel_setState_,0);
    pvVar1 = self->_transparentColorPickerButton;
    pvVar2 = _objc_msgSend(self->_transparentColorButton,sel_title);
    _objc_msgSend(pvVar1,sel_setTitle_,pvVar2);
    _objc_msgSend(self->_transparentColorPickerButton,sel_sizeToFit);
    pvVar1 = self->_transparentColorButton;
  }
  uVar4 = 1;
LAB_0012ae4f:
  _objc_msgSend(pvVar1,sel_setHidden_,uVar4);
  return;
}

*/
- (void)transparentColorValidate
{
    id animatedObject = [[self animation] animatedObject];
    BOOL supported = [animatedObject implementsHyperInterface:@protocol(HSTransparentColorAttributes)];
    if (supported) {
        id movie = [animatedObject queryHyperInterface:@protocol(HSMovieObjectAttributes)];
        if (movie != nil && ([movie isHyperQTVR] || [movie isHyperPanoramaObject])) {
            supported = NO;
        }
    }
    if (!supported) {
        [_transparentColorPickerButton setEnabled:NO];
        [_transparentColorPickerButton setState:0];
        [_transparentColorPickerButton setTitle:[_transparentColorButton title]];
        [_transparentColorPickerButton sizeToFit];
        [_transparentColorButton setHidden:YES];
        return;
    }
    if ([[self allAnimations] usesTransparentColor]) {
        [_transparentColorPickerButton setState:1];
        [_transparentColorPickerButton setTitle:@""];
        [_transparentColorPickerButton sizeToFit];
        [_transparentColorButton setHidden:NO];
    }
    else {
        [_transparentColorPickerButton setState:0];
        [_transparentColorPickerButton setTitle:[_transparentColorButton title]];
        [_transparentColorPickerButton sizeToFit];
        [_transparentColorButton setHidden:YES];
    }
}

- (void)toggleTransparentColor:(id)aColor
{
    [self toggleTransparentColorToValue:(unsigned int)([aColor state] == 0x1)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0012aa38 @ 0012aa38, 513 bytes * /

void FUN_0012aa38(HSAnimationSetupMainAssistantPane *self,SEL _cmd,
                 BOOL toggleTransparentColorToValue)

{
  bool bVar1;
  id pvVar2;
  id pvVar3;
  HSAnimationSetupMainAssistantPane *self_00;
  SEL op;
  undefined4 uVar4;
  
  if (toggleTransparentColorToValue != '\0') {
    pvVar2 = _objc_msgSend(self,sel_allAnimations);
    pvVar2 = _objc_msgSend(pvVar2,sel_transparentColor);
    if (pvVar2 == (id)0x0) {
      bVar1 = false;
      goto LAB_0012ab7a;
    }
  }
  pvVar2 = _objc_msgSend(self,sel_undoManager);
  pvVar3 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_Change_Options,
                         &cfstr_empty,&cfstr_UndoManager);
  _objc_msgSend(pvVar2,sel_setActionName_,pvVar3);
  pvVar2 = _objc_msgSend(self,sel_undoManager);
  pvVar2 = _objc_msgSend(pvVar2,sel_prepareWithInvocationTarget_,self);
  _objc_msgSend(pvVar2,sel_toggleTransparentColorToValue_,
                (uint)(toggleTransparentColorToValue == '\0'));
  pvVar2 = _objc_msgSend(self,sel_undoHelper);
  _objc_msgSend(pvVar2,sel_duplicateAction);
  _objc_msgSend(self,sel_disableAnimationsUndo);
  bVar1 = true;
LAB_0012ab7a:
  self_00 = _objc_msgSend(self,sel_allAnimations);
  op = sel_setUsesTransparentColor_;
  if ((toggleTransparentColorToValue == '\0') ||
     (pvVar2 = _objc_msgSend(self_00,sel_transparentColor), self_00 = self,
     op = sel_changeTransparentColor_, pvVar2 == (id)0x0)) {
    uVar4 = 0;
  }
  else {
    self_00 = _objc_msgSend(self,sel_allAnimations);
    uVar4 = 1;
    op = sel_setUsesTransparentColor_;
  }
  _objc_msgSend(self_00,op,uVar4);
  if (bVar1) {
    _objc_msgSend(self,sel_enableAnimationsUndo,uVar4);
  }
  _objc_msgSend(self,sel_transparentColorValidate,uVar4);
  return;
}

*/
- (void)toggleTransparentColorToValue:(BOOL)aValue
{
    BOOL registeredUndo = NO;
    if (!aValue || [[self allAnimations] transparentColor] != nil) {
        [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
        [[[self undoManager] prepareWithInvocationTarget:self] toggleTransparentColorToValue:!aValue];
        [[self undoHelper] duplicateAction];
        [self disableAnimationsUndo];
        registeredUndo = YES;
    }
    if (!aValue) {
        [[self allAnimations] setUsesTransparentColor:NO];
    }
    else if ([[self allAnimations] transparentColor] != nil) {
        [[self allAnimations] setUsesTransparentColor:YES];
    }
    else {
        [self changeTransparentColor:nil];
    }
    if (registeredUndo) {
        [self enableAnimationsUndo];
    }
    [self transparentColorValidate];
}

- (void)changeTransparentColor:(id)aColor
{
    [_delegate transparentColorFromAnimationSetupMainAssistantPane:self];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0012a843 @ 0012a843, 456 bytes * /

void FUN_0012a843(HSAnimationSetupMainAssistantPane *self,SEL _cmd,id flipVertically)

{
  id pvVar1;
  id pvVar2;
  int iVar3;
  id local_14;
  
  pvVar1 = _objc_msgSend(self,sel_undoManager);
  pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_Change_Options,
                         &cfstr_empty,&cfstr_UndoManager);
  _objc_msgSend(pvVar1,sel_setActionName_,pvVar2);
  pvVar1 = _objc_msgSend(self,sel_undoManager);
  pvVar1 = _objc_msgSend(pvVar1,sel_prepareWithInvocationTarget_,self);
  _objc_msgSend(pvVar1,sel_flipVertically_,flipVertically);
  pvVar1 = _objc_msgSend(self,sel_undoHelper);
  _objc_msgSend(pvVar1,sel_duplicateAction);
  pvVar1 = _objc_msgSend(self,sel_animation);
  local_14 = _objc_msgSend(self,sel_tryItAnimation);
  iVar3 = 0;
  while( true ) {
    pvVar2 = _objc_msgSend(pvVar1,sel_animatedObject);
    pvVar2 = _objc_msgSend(pvVar2,sel_undoManager);
    _objc_msgSend(pvVar2,sel_disableUndoRegistration);
    _objc_msgSend(pvVar1,sel_flipAnimatedObjectVertically);
    pvVar1 = _objc_msgSend(pvVar1,sel_animatedObject);
    pvVar1 = _objc_msgSend(pvVar1,sel_undoManager);
    _objc_msgSend(pvVar1,sel_enableUndoRegistration);
    if (iVar3 == 1) break;
    pvVar1 = (&local_14)[iVar3];
    iVar3 = iVar3 + 1;
  }
  _objc_msgSend(self,sel_updateMainOptionsUI);
  return;
}

*/
- (void)flipVertically:(id)aVertically
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] flipVertically:aVertically];
    [[self undoHelper] duplicateAction];
    id animations[2] = { [self animation], [self tryItAnimation] };
    for (int i = 0; i < 2; i++) {
        [[[animations[i] animatedObject] undoManager] disableUndoRegistration];
        [animations[i] flipAnimatedObjectVertically];
        [[[animations[i] animatedObject] undoManager] enableUndoRegistration];
    }
    [self updateMainOptionsUI];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0012a67b @ 0012a67b, 456 bytes * /

void FUN_0012a67b(HSAnimationSetupMainAssistantPane *self,SEL _cmd,id flipHorizontally)

{
  id pvVar1;
  id pvVar2;
  int iVar3;
  id local_14;
  
  pvVar1 = _objc_msgSend(self,sel_undoManager);
  pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_Change_Options,
                         &cfstr_empty,&cfstr_UndoManager);
  _objc_msgSend(pvVar1,sel_setActionName_,pvVar2);
  pvVar1 = _objc_msgSend(self,sel_undoManager);
  pvVar1 = _objc_msgSend(pvVar1,sel_prepareWithInvocationTarget_,self);
  _objc_msgSend(pvVar1,sel_flipHorizontally_,flipHorizontally);
  pvVar1 = _objc_msgSend(self,sel_undoHelper);
  _objc_msgSend(pvVar1,sel_duplicateAction);
  pvVar1 = _objc_msgSend(self,sel_animation);
  local_14 = _objc_msgSend(self,sel_tryItAnimation);
  iVar3 = 0;
  while( true ) {
    pvVar2 = _objc_msgSend(pvVar1,sel_animatedObject);
    pvVar2 = _objc_msgSend(pvVar2,sel_undoManager);
    _objc_msgSend(pvVar2,sel_disableUndoRegistration);
    _objc_msgSend(pvVar1,sel_flipAnimatedObjectHorizntally);
    pvVar1 = _objc_msgSend(pvVar1,sel_animatedObject);
    pvVar1 = _objc_msgSend(pvVar1,sel_undoManager);
    _objc_msgSend(pvVar1,sel_enableUndoRegistration);
    if (iVar3 == 1) break;
    pvVar1 = (&local_14)[iVar3];
    iVar3 = iVar3 + 1;
  }
  _objc_msgSend(self,sel_updateMainOptionsUI);
  return;
}

*/
- (void)flipHorizontally:(id)aHorizontally
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] flipHorizontally:aHorizontally];
    [[self undoHelper] duplicateAction];
    id animations[2] = { [self animation], [self tryItAnimation] };
    for (int i = 0; i < 2; i++) {
        [[[animations[i] animatedObject] undoManager] disableUndoRegistration];
        [animations[i] flipAnimatedObjectHorizntally];
        [[[animations[i] animatedObject] undoManager] enableUndoRegistration];
    }
    [self updateMainOptionsUI];
}

- (void)changePlayForTypeOptionsFrom:(id)aFrom to:(id)aTo
{
    int pvVar1_6;
    int pvVar2_4;

    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] changePlayForTypeOptionsFrom:aTo to:aFrom];
    [[self undoHelper] duplicateAction];
    pvVar1_6 = [[aTo objectAtIndex:0] intValue];
    pvVar2_4 = [[aTo objectAtIndex:1] intValue];
    [[self allAnimations] setLoopMode:pvVar1_6];
    [[self allAnimations] setLoopSeconds:(double)(int)pvVar2_4];
    [[self allAnimations] setLoopPathRepeats:pvVar2_4];
    [[self allAnimations] setLoopFrameRepeats:pvVar2_4];
    [self updateMainOptionsUI];
}

- (BOOL)optionsDiffer:(id)aDiffer :(id)aArg
{
    int iVar3;

    iVar3 = 0;
    while( YES ) {
        if (1 < iVar3) {
            return NO;
        }
        if ([[aDiffer objectAtIndex:iVar3] intValue] != [[aArg objectAtIndex:iVar3] intValue]) break;
        iVar3 = iVar3 + 1;
    }
    return YES;
}

- (void)movePopUpButtonSelectItemWithTag:(NSInteger)aTag
{
    id pvVar1;

    [_movePopUpButton selectItemWithTag:aTag];
    pvVar1 = _movePopUpButton;
    [pvVar1 setToolTip:[[pvVar1 selectedItem] toolTip]];
    [_moveValueTextField setToolTip:[[_movePopUpButton selectedItem] toolTip]];
}

- (void)playForPopUpButtonSelectItemWithTag:(NSInteger)aTag
{
    id pvVar1;

    [_playForPopUpButton selectItemWithTag:aTag];
    pvVar1 = _playForPopUpButton;
    [pvVar1 setToolTip:[[pvVar1 selectedItem] toolTip]];
    [_playForValueTextField setToolTip:[[_playForPopUpButton selectedItem] toolTip]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0012a0bd @ 0012a0bd, 406 bytes * /

void FUN_0012a0bd(HSAnimationSetupMainAssistantPane *self,SEL _cmd,id changePlayForValue)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar1 = _objc_msgSend(self->_playForPopUpButton,sel_selectedItem);
  pvVar1 = _objc_msgSend(pvVar1,sel_tag);
  pvVar2 = _objc_msgSend(changePlayForValue,sel_intValue);
  if ((int)pvVar2 < 1) {
    _objc_msgSend(self->_playForValueTextField,sel_setIntValue_,1);
  }
  pvVar2 = _objc_msgSend(self,sel_oldOptions);
  pvVar3 = _objc_msgSend(pvVar2,sel_mutableCopy);
  pvVar3 = _objc_msgSend(pvVar3,sel_autorelease);
  if (pvVar1 == (id)0x1) {
    pvVar1 = _objc_msgSend(cls_NSNumber,sel_numberWithInt_,2);
    _objc_msgSend(pvVar3,sel_replaceObjectAtIndex_withObject_,0,pvVar1);
  }
  self_00 = cls_NSNumber;
  pvVar1 = _objc_msgSend(changePlayForValue,sel_intValue);
  pvVar1 = _objc_msgSend(self_00,sel_numberWithInt_,pvVar1);
  _objc_msgSend(pvVar3,sel_replaceObjectAtIndex_withObject_,1,pvVar1);
  pvVar1 = _objc_msgSend(self,sel_optionsDiffer__,pvVar2,pvVar3);
  if ((char)pvVar1 != '\0') {
    _objc_msgSend(self,sel_changePlayForTypeOptionsFrom_to_,pvVar2,pvVar3);
  }
  return;
}

*/
- (void)changePlayForValue:(id)aValue
{
    NSInteger type = [[_playForPopUpButton selectedItem] tag];
    if ([aValue intValue] < 1) {
        [_playForValueTextField setIntValue:1];
    }
    NSArray *oldOptions = [self oldOptions];
    NSMutableArray *newOptions = [[oldOptions mutableCopy] autorelease];
    if (type == 1) {
        [newOptions replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:2]];
    }
    [newOptions replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:[aValue intValue]]];
    if ([self optionsDiffer:oldOptions :newOptions]) {
        [self changePlayForTypeOptionsFrom:oldOptions to:newOptions];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00129f8a @ 00129f8a, 307 bytes * /

void FUN_00129f8a(HSAnimationSetupMainAssistantPane *self,SEL _cmd,id changePlayForType)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  undefined4 uVar3;
  
  pvVar1 = _objc_msgSend(self->_playForPopUpButton,sel_selectedItem);
  pvVar1 = _objc_msgSend(pvVar1,sel_tag);
  self_00 = _objc_msgSend(self,sel_oldOptions);
  pvVar2 = _objc_msgSend(self_00,sel_mutableCopy);
  pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
  if (pvVar1 == (id)0x2) {
    uVar3 = 4;
  }
  else if (pvVar1 == (id)0x1) {
    uVar3 = 2;
  }
  else if (pvVar1 == (id)0x0) {
    uVar3 = 3;
  }
  else if (pvVar1 == (id)0x3) {
    uVar3 = 1;
  }
  else {
    uVar3 = 0xffffffff;
  }
  pvVar1 = _objc_msgSend(cls_NSNumber,sel_numberWithInt_,uVar3);
  _objc_msgSend(pvVar2,sel_replaceObjectAtIndex_withObject_,0,pvVar1);
  pvVar1 = _objc_msgSend(self,sel_optionsDiffer__,self_00,pvVar2);
  if ((char)pvVar1 != '\0') {
    _objc_msgSend(self,sel_changePlayForTypeOptionsFrom_to_,self_00,pvVar2);
  }
  return;
}

*/
- (void)changePlayForType:(id)aType
{
    NSInteger type = [[_playForPopUpButton selectedItem] tag];
    NSArray *oldOptions = [self oldOptions];
    NSMutableArray *newOptions = [[oldOptions mutableCopy] autorelease];
    int loopMode;
    switch (type) {
        case 0: loopMode = 3; break;
        case 1: loopMode = 2; break;
        case 2: loopMode = 4; break;
        case 3: loopMode = 1; break;
        default: loopMode = -1; break;
    }
    [newOptions replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:loopMode]];
    if ([self optionsDiffer:oldOptions :newOptions]) {
        [self changePlayForTypeOptionsFrom:oldOptions to:newOptions];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0012f061 @ 0012f061, 315 bytes * /

id FUN_0012f061(HSAnimationSetupMainAssistantPane *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  double dVar4;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_animation);
  pvVar1 = _objc_msgSend(pvVar1,sel_loopMode);
  if (pvVar1 == (id)0x3) {
    pvVar2 = _objc_msgSend(self,sel_animation);
    dVar4 = _objc_msgSend_fpret(pvVar2,sel_loopSeconds);
    pvVar2 = (id)(int)dVar4;
  }
  else {
    if ((int)pvVar1 - 1U < 2) {
      pvVar2 = _objc_msgSend(self,sel_animation);
      op = sel_loopPathRepeats;
    }
    else {
      if (pvVar1 != (id)0x4) {
        pvVar2 = (id)0x1;
        goto LAB_0012f122;
      }
      pvVar2 = _objc_msgSend(self,sel_animation);
      op = sel_loopFrameRepeats;
    }
    pvVar2 = _objc_msgSend(pvVar2,op);
  }
LAB_0012f122:
  self_00 = cls_NSArray;
  pvVar3 = (id)0x2;
  if (pvVar1 != (id)0x0) {
    pvVar3 = pvVar1;
  }
  pvVar1 = _objc_msgSend(cls_NSNumber,sel_numberWithInt_,pvVar2);
  pvVar2 = _objc_msgSend(cls_NSNumber,sel_numberWithInt_,pvVar3);
  pvVar1 = _objc_msgSend(self_00,sel_arrayWithObjects_,pvVar2,pvVar1,0);
  return pvVar1;
}

*/
- (id)oldOptions
{
    NSInteger loopMode = [[self animation] loopMode];
    int value;
    if (loopMode == 3) {
        value = (int)[[self animation] loopSeconds];
    }
    else if (loopMode == 1 || loopMode == 2) {
        value = (int)[[self animation] loopPathRepeats];
    }
    else if (loopMode == 4) {
        value = (int)[[self animation] loopFrameRepeats];
    }
    else {
        value = 1;
    }
    // A loop mode of 0 is reported as path repeats.
    return [NSArray arrayWithObjects:[NSNumber numberWithInt:(int)(loopMode != 0 ? loopMode : 2)], [NSNumber numberWithInt:value], nil];
}

- (void)setMovieSpeed:(double)aSpeed
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setMovieSpeed:[[self animation] movieSpeed]];
    [[self undoHelper] duplicateAction];
    [[self allAnimations] setMovieSpeed:aSpeed];
    [self updateMainOptionsUI];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0012f2f7 @ 0012f2f7, 133 bytes * /

void FUN_0012f2f7(HSAnimationSetupMainAssistantPane *self,SEL _cmd,id changeMovieSpeeed)

{
  double dVar1;
  double dVar2;
  
  dVar2 = _objc_msgSend_fpret(changeMovieSpeeed,sel_doubleValue);
  dVar1 = 1.0;
  if ((1.0 <= dVar2) && (dVar1 = dVar2, 100.0 < dVar2)) {
    dVar1 = 100.0;
  }
  _objc_msgSend(self,sel_setMovieSpeed_,dVar1);
  _objc_msgSend(self,sel_updateMainOptionsUI);
  return;
}

*/
- (void)changeMovieSpeeed:(id)aSpeeed
{
    double speed = [aSpeeed doubleValue];
    if (!(speed >= 1.0)) {
        speed = 1.0;
    }
    else if (speed > 100.0) {
        speed = 100.0;
    }
    [self setMovieSpeed:speed];
    [self updateMainOptionsUI];
}

- (void)setUseClones:(BOOL)aClones
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setUseClones:(unsigned int)(aClones == 0)];
    [[self undoHelper] duplicateAction];
    [[self allAnimations] setUseClones:aClones];
    [self updateMainOptionsUI];
}

- (void)toggleAllowClones:(id)aClones
{
    [self setUseClones:(unsigned int)([aClones state] == 0x1)];
}

- (void)setMatchToMovement:(BOOL)aMovement
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setMatchToMovement:(unsigned int)(aMovement == 0)];
    [[self undoHelper] duplicateAction];
    [[self allAnimations] setMatchToMovement:aMovement];
    [self updateMainOptionsUI];
}

- (void)toggleMatchToMovement:(id)aMovement
{
    [self setMatchToMovement:(unsigned int)([aMovement selectedRow] == 0)];
}

- (void)setHideOnLastFrame:(BOOL)aFrame
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHideOnLastFrame:(unsigned int)(aFrame == 0)];
    [[self undoHelper] duplicateAction];
    [[self allAnimations] setHideOnLastFrame:aFrame];
    [self updateMainOptionsUI];
}

- (void)toggleEraseWhenDone:(id)aDone
{
    [self setHideOnLastFrame:(unsigned int)([aDone state] == 0x1)];
}

- (void)setHideOnFirstFrame:(BOOL)aFrame
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Options" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHideOnFirstFrame:(unsigned int)(aFrame == 0)];
    [[self undoHelper] duplicateAction];
    [[self allAnimations] setHideOnFirstFrame:aFrame];
    [self updateMainOptionsUI];
}

- (void)toggleShowFirstFrame:(id)aFrame
{
    [self setHideOnFirstFrame:(unsigned int)([aFrame state] != 0x1)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001298f1 @ 001298f1, 138 bytes * /

void FUN_001298f1(HSAnimationSetupMainAssistantPane *self,SEL _cmd,int switchToOptionView)

{
  SEL op;
  id pvVar1;
  id pvVar2;
  
  if (switchToOptionView == 1) {
    pvVar1 = self->_mainOptionsView;
    pvVar2 = self->_pathOptionsView;
    _objc_msgSend(self->_optionsView,sel_replaceSubview_with_,pvVar1,pvVar2);
    op = sel_updatePathOptionsUI;
  }
  else {
    if (switchToOptionView != 0) {
      return;
    }
    pvVar1 = self->_pathOptionsView;
    pvVar2 = self->_mainOptionsView;
    _objc_msgSend(self->_optionsView,sel_replaceSubview_with_,pvVar1,pvVar2);
    op = sel_updateMainOptionsUI;
  }
  _objc_msgSend(self,op,pvVar1,pvVar2);
  return;
}

*/
- (void)switchToOptionView:(NSInteger)aView
{
    if (aView == 1) {
        [_optionsView replaceSubview:_mainOptionsView with:_pathOptionsView];
        [self updatePathOptionsUI];
    }
    else if (aView == 0) {
        [_optionsView replaceSubview:_pathOptionsView with:_mainOptionsView];
        [self updateMainOptionsUI];
    }
}

- (void)switchOptionView:(id)aView
{
    [self switchToOptionView:[[aView selectedCell] tag]];
}

- (void)enableAnimationsUndo
{
    [[[[self animation] animatedObject] undoManager] enableUndoRegistration];
    [[[[self tryItAnimation] animatedObject] undoManager] enableUndoRegistration];
}

- (void)disableAnimationsUndo
{
    [[[[self animation] animatedObject] undoManager] disableUndoRegistration];
    [[[[self tryItAnimation] animatedObject] undoManager] disableUndoRegistration];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00129680 @ 00129680, 206 bytes * /

id FUN_00129680(HSAnimationSetupMainAssistantPane *self,SEL _cmd)

{
  undefined *puVar1;
  id pvVar2;
  undefined *self_00;
  SEL op;
  cfstringStruct *pcVar3;
  
  pvVar2 = _objc_msgSend(self,sel_assistant);
  pvVar2 = _objc_msgSend(pvVar2,sel_object);
  pcVar3 = (cfstringStruct *)&DAT_00372338;
  pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_00372338);
  puVar1 = cls_NSString;
  self_00 = cls_HSPlayAnimationAction;
  op = sel_localizedNameInInspector;
  if (pvVar2 != (id)0x0) {
    _objc_msgSend(cls_HSPlayAnimationAction,sel_localizedNameInInspector,pcVar3);
    _objc_msgSend(pvVar2,sel_hyperName);
    pcVar3 = &cfstr________;
    self_00 = puVar1;
    op = sel_stringWithFormat_;
  }
  pvVar2 = _objc_msgSend(self_00,op,pcVar3);
  return pvVar2;
}

*/
- (id)windowTitle
{
    id object = [[[self assistant] object] queryHyperInterface:@protocol(HSObjectAttributes)];
    if (object == nil) {
        return [HSPlayAnimationAction localizedNameInInspector];
    }
    return [NSString stringWithFormat:@"%@ : %@", [object hyperName], [HSPlayAnimationAction localizedNameInInspector]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00129609 @ 00129609, 119 bytes * /

void FUN_00129609(HSAnimationSetupMainAssistantPane *self,SEL _cmd,id controlTextDidChange)

{
  id pvVar1;
  SEL op;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(controlTextDidChange,sel_object);
  pvVar2 = self->_movieSpeedTextField;
  op = sel_framesPerSecondChanged_;
  if (((pvVar1 == pvVar2) ||
      (pvVar2 = self->_playForValueTextField, op = sel_changePlayForValue_, pvVar1 == pvVar2)) ||
     (pvVar2 = self->_moveValueTextField, op = sel_changeMoveValue_, pvVar1 == pvVar2)) {
    _objc_msgSend(self,op,pvVar2);
  }
  return;
}

*/
- (void)controlTextDidChange:(id)aChange
{
    id field = [aChange object];
    if (field == _movieSpeedTextField) {
        [self framesPerSecondChanged:_movieSpeedTextField];
    }
    else if (field == _playForValueTextField) {
        [self changePlayForValue:_playForValueTextField];
    }
    else if (field == _moveValueTextField) {
        [self changeMoveValue:_moveValueTextField];
    }
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    if ([self isHelpVisible]) {
        [self hideHelpNeedsRelayout:YES];
    }
    [super viewWillDisappear:aDisappear];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSControlTextDidChangeNotification object:_playForValueTextField];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSControlTextDidChangeNotification object:_movieSpeedTextField];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSControlTextDidChangeNotification object:_moveValueTextField];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    id pvVar2_4;

    [super viewWillAppear:aAppear];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controlTextDidChange:) name:NSControlTextDidChangeNotification object:_movieSpeedTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controlTextDidChange:) name:NSControlTextDidChangeNotification object:_playForValueTextField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controlTextDidChange:) name:NSControlTextDidChangeNotification object:_moveValueTextField];
    pvVar2_4 = _layerPopUpButton;
    [pvVar2_4 setToolTip:[[pvVar2_4 selectedItem] toolTip]];
    [self transparentColorValidate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_segmentedControl setBackgroundRenderer:[HSAnimationOptionsControlBackgroundRenderer sharedBackgroundRenderer]];
    [_segmentedControl setPrototype:[_segmentedControl cellAtRow:0 column:1]];
    [_optionsView addSubview:_mainOptionsView];
    [self setPlayStopImage:[[self class] playAnimationImage]];
    [[_beginArrowButton cell] setBackgroundRenderer:[HSAssistantPaneControlBackgroundRenderer sharedBackgroundRenderer]];
    [[_endArrowButton cell] setBackgroundRenderer:[HSAssistantPaneControlBackgroundRenderer sharedBackgroundRenderer]];
    [[_startFromBeginButton cell] setBackgroundRenderer:[HSAssistantPaneControlBackgroundRenderer sharedBackgroundRenderer]];
    [[_startFromEndButton cell] setBackgroundRenderer:[HSAssistantPaneControlBackgroundRenderer sharedBackgroundRenderer]];
    [_playForPopUpButton setAutoenablesItems:NO];
}

- (id)navigationPaneSwitcher
{
    HSNBAAssistantNavigationPaneSwitcher *pHVar1;
    HSNBAAssistantNavigationPaneSwitcher *pHVar1_2;

    pHVar1 = _navigationPaneSwitcher;
    if (pHVar1 == nil) {
        pHVar1_2 = [HSNBAAssistantNavigationPaneSwitcher new];
        _navigationPaneSwitcher = pHVar1_2;
        [pHVar1_2 setDelegate:self];
        pHVar1 = _navigationPaneSwitcher;
    }
    return pHVar1;
}

- (BOOL)assistantShouldBeKeyWindow
{
    return YES;
}

- (id)undoHelper
{
    return [_delegate undoHelperForAnimationSetupMainAssistantPane:self];
}

- (id)undoManager
{
    return [_delegate undoManagerForAnimationSetupMainAssistantPane:self];
}

- (id)allAnimations
{
    id pvVar1;

    pvVar1 = [self tryItAnimation];
    return [_HSAnimationsProxy proxyWithObjects:[NSArray arrayWithObjects:[self animation], pvVar1, nil]];
}

- (id)tryItAnimation
{
    id pvVar1;

    pvVar1 = [_delegate tryItAnimationForAnimationSetupMainAssistantPane:self]
    ;
    return pvVar1;
}

- (id)animation
{
    return [_delegate animationForAnimationSetupMainAssistantPane:self];
}

- (void)setIsMovieAnimation:(BOOL)aAnimation
{
    _isMovieAnimation = aAnimation;
}

- (BOOL)isMovieAnimation
{
    return _isMovieAnimation;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (BOOL)requiresDarkBottomArea
{
    return YES;
}

- (void)dealloc
{
    [_navigationPaneSwitcher release];
    [_helpDrawer release];
    [_actionHelpView release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"AnimationSetupMainPane"];
    return self;
}

@end

@implementation _HSAnimationsProxy

/* i386 ivar offsets: _objects=0x4 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_0012941f @ 0012941f, 83 bytes * /

id FUN_0012941f(id self,SEL _cmd,id proxyWithObjects)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_alloc);
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithObjects_,proxyWithObjects);
  pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  return pvVar1;
}

*/
+ (id)proxyWithObjects:(id)aObjects
{
    return [[(_HSAnimationsProxy *)[self alloc] initWithObjects:aObjects] autorelease];
}

- (void)forwardInvocation:(id)aInvocation
{
    NSEnumerator *self_00;
    id pvVar1;

    self_00 = [_objects objectEnumerator];
    pvVar1 = [self_00 nextObject];
    while (pvVar1 != nil) {
        [aInvocation invokeWithTarget:pvVar1];
        pvVar1 = [self_00 nextObject];
    }
}

- (id)methodSignatureForSelector:(SEL)aSelector
{
    return [[_objects objectAtIndex:0] methodSignatureForSelector:aSelector];
}

- (void)dealloc
{
    [_objects release];
    [super dealloc];
}

- (id)initWithObjects:(id)aObjects
{
    _objects = [aObjects copy];
    return self;
}

@end

