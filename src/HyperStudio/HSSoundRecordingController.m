#import "HSSoundRecordingController.h"

@implementation HSSoundRecordingController

/* i386 ivar offsets: _delegate=0x4, _timerForObservingInputAudioLevel=0x8, _timerForMeasurementRecordAudioTime=0xc, _playImage=0x10, _stopImage=0x14, _playPressedImageAqua=0x18, _playPressedImageGraphite=0x1c, _stopPressedImageAqua=0x20, _stopPressedImageGraphite=0x24, _recordImage=0x28, _onRecordImage=0x2c, _recordPressedImageAqua=0x30, _recordPressedImageGraphite=0x34, _onRecordPressedImageGraphite=0x38, _sound=0x3c, _audioOutputFilePath=0x40, _audioCaptureSession=0x44, _audioDeviceInput=0x48, _audioFileOutput=0x4c, _audioCaptureDeviceList=0x50, _countDownViewController=0x54, _playbackMatrix=0x58, _soundRecordingPanel=0x5c, _levelIndicator=0x60, _viewContainer=0x64, _recordedAudioTimeView=0x68, _playbackAudioTimeView=0x6c, _recordedAudioTimeTextField=0x70, _currentPlaybackAudioTimeTextField=0x74, _totalPlaybackAudioTimeTextField=0x78, _addToCardButton=0x7c, _audioCaptureDevicesPopUp=0x80, _isPlaying=0x84, _isRecording=0x84, _isChangeSoundRecord=0x84, _didCaptureMovieFileOutputStartRecording=0x84, _didCaptureMovieFileOutputFinishRecording=0x84 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007cb84 @ 0007cb84, 82 bytes * /

void FUN_0007cb84(HSSoundRecordingController *self,SEL _cmd,id captureOutput,
                 id didFinishRecordingToOutputFileAtURL,id forConnections,id dueToError)

{
  id self_00;
  
  if (dueToError != (id)0x0) {
    self_00 = _objc_msgSend(cls_NSAlert,sel_alertWithError_,dueToError);
    _objc_msgSend(self_00,sel_runModal);
  }
  self->_isPlaying[0] = self->_isPlaying[0] | 0x10;
  return;
}

*/
- (void)captureOutput:(id)aOutput didFinishRecordingToOutputFileAtURL:(id)aURL forConnections:(id)aConnections dueToError:(id)aError
{
    if (aError != nil) {
        [[NSAlert alertWithError:aError] runModal];
    }
    _didCaptureMovieFileOutputFinishRecording = 1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007a1c2 @ 0007a1c2, 15 bytes * /

void FUN_0007a1c2(HSSoundRecordingController *self,SEL _cmd,id captureOutput,
                 id didStartRecordingToOutputFileAtURL,id forConnections)

{
  self->_isPlaying[0] = self->_isPlaying[0] | 8;
  return;
}

*/
- (void)captureOutput:(id)aOutput didStartRecordingToOutputFileAtURL:(id)aURL forConnections:(id)aConnections
{
    _didCaptureMovieFileOutputStartRecording = 1;
}

- (BOOL)isInputSoundValid
{
    return [[self audioCaptureDeviceList] captureDeviceCount] != 0;
}

- (void)runModalForWindow:(id)aWindow
{
    [self prepareRecordingPanel];
    [NSApp beginSheet:_soundRecordingPanel modalForWindow:aWindow modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:0];
}

- (NSInteger)runModal
{
    NSModalResponse pvVar1_2;

    [self prepareRecordingPanel];
    pvVar1_2 = [[NSApplication sharedApplication] runModalForWindow:_soundRecordingPanel];
    [_soundRecordingPanel orderOut:self];
    [self prepareRecordingPanelToClose];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeSound];
    return (int)pvVar1_2;
}

- (void)invalidateFileName
{
    [_audioOutputFilePath release];
    _audioOutputFilePath = nil;
}

- (id)fileName
{
    id pvVar1;

    pvVar1 = _audioOutputFilePath;
    if (pvVar1 == nil) {
        pvVar1 = [[NSString extraCreateUniqueFilename:[[[HSPathsProvider sharedPathsProvider] temporaryFolder] stringByAppendingPathComponent:[[HSUID UID] stringValue]] extension:@"aac"] retain];
        _audioOutputFilePath = pvVar1;
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007a1a9 @ 0007a1a9, 25 bytes * /

BOOL FUN_0007a1a9(HSSoundRecordingController *self,SEL _cmd)

{
  BOOL BVar1;
  
  BVar1 = -1;
  if ((self->_isPlaying[0] & 1) == 0) {
    BVar1 = '\0';
  }
  return BVar1;
}

*/
- (BOOL)isPlaying
{
    return _isPlaying != 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007a190 @ 0007a190, 25 bytes * /

BOOL FUN_0007a190(HSSoundRecordingController *self,SEL _cmd)

{
  BOOL BVar1;
  
  BVar1 = -1;
  if ((self->_isPlaying[0] & 2) == 0) {
    BVar1 = '\0';
  }
  return BVar1;
}

*/
- (BOOL)isRecording
{
    return _isRecording != 0;
}

- (void)setDelegate:(id)aDelegate
{
    if (_delegate != aDelegate) {
        _delegate = aDelegate;
    }
}

- (id)delegate
{
    return _delegate;
}

- (void)audioDeviceDidChange:(id)aChange
{
    [self HSSoundRecordingController_setAudioCaptureDevice:[[_audioCaptureDevicesPopUp selectedItem] representedObject]];
}

- (void)onHelp:(id)aHelp
{
    [[HSHelpBookManager sharedHelpBookManager] openHelpTopic:@"HSSoundRecording"];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007c7fe @ 0007c7fe, 112 bytes * /

void FUN_0007c7fe(HSSoundRecordingController *self,SEL _cmd,id onCloseSheet)

{
  undefined *puVar1;
  id pvVar2;
  SEL op;
  
  puVar1 = PTR_00336058;
  pvVar2 = _objc_msgSend(*(id *)PTR_00336058,sel_modalWindow);
  if (pvVar2 == (id)0x0) {
    pvVar2 = self->_soundRecordingPanel;
    op = sel_endSheet_returnCode_;
  }
  else {
    pvVar2 = (id)0x0;
    op = sel_stopModalWithCode_;
  }
  _objc_msgSend(*(id *)puVar1,op,pvVar2);
  return;
}

*/
- (void)onCloseSheet:(id)aSheet
{
    if ([NSApp modalWindow] != nil) {
        [NSApp stopModalWithCode:0];
    } else {
        [NSApp endSheet:_soundRecordingPanel returnCode:0];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007c77a @ 0007c77a, 132 bytes * /

void FUN_0007c77a(HSSoundRecordingController *self,SEL _cmd,id addToCardSound)

{
  undefined *puVar1;
  id pvVar2;
  SEL op;
  
  _objc_msgSend(self,sel_storeSelectedDeviceInUserDefaults);
  puVar1 = PTR_00336058;
  pvVar2 = _objc_msgSend(*(id *)PTR_00336058,sel_modalWindow);
  if (pvVar2 == (id)0x0) {
    pvVar2 = self->_soundRecordingPanel;
    op = sel_endSheet_returnCode_;
  }
  else {
    pvVar2 = (id)0x1;
    op = sel_stopModalWithCode_;
  }
  _objc_msgSend(*(id *)puVar1,op,pvVar2);
  return;
}

*/
- (void)addToCardSound:(id)aSound
{
    [self storeSelectedDeviceInUserDefaults];
    if ([NSApp modalWindow] != nil) {
        [NSApp stopModalWithCode:1];
    } else {
        [NSApp endSheet:_soundRecordingPanel returnCode:1];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007c6b2 @ 0007c6b2, 200 bytes * /

void FUN_0007c6b2(HSSoundRecordingController *self,SEL _cmd,id observeValueForKeyPath,id ofObject,
                 id change,void *context)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self->_audioDeviceInput,sel_device);
  if (pvVar1 == ofObject) {
    pvVar1 = _objc_msgSend(observeValueForKeyPath,sel_isEqualToString_,
                           &cfstr_inUseByAnotherApplication);
    if ((((char)pvVar1 == '\0') &&
        (pvVar1 = _objc_msgSend(observeValueForKeyPath,sel_isEqualToString_,&cfstr_suspended),
        (char)pvVar1 == '\0')) &&
       (pvVar1 = _objc_msgSend(observeValueForKeyPath,sel_isEqualToString_,&cfstr_connected),
       (char)pvVar1 == '\0')) {
      return;
    }
    _objc_msgSend(self,sel_performSelectorOnMainThread_withObject_waitUntilDone_,
                  sel_HSSoundRecordingController_captureDeviceDidChangeState_,ofObject,0);
  }
  return;
}

*/
- (void)observeValueForKeyPath:(id)aPath ofObject:(id)aObject change:(id)aChange context:(void *)aContext
{
    if ([_audioDeviceInput device] != aObject) {
        return;
    }
    if ([aPath isEqualToString:@"inUseByAnotherApplication"] || [aPath isEqualToString:@"suspended"] || [aPath isEqualToString:@"connected"]) {
        [self performSelectorOnMainThread:@selector(HSSoundRecordingController_captureDeviceDidChangeState:) withObject:aObject waitUntilDone:NO];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007c5c9 @ 0007c5c9, 233 bytes * /

void FUN_0007c5c9(HSSoundRecordingController *self,SEL _cmd,
                 id HSSoundRecordingController_captureDeviceDidChangeState)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self->_audioDeviceInput,sel_device);
  if (pvVar1 != HSSoundRecordingController_captureDeviceDidChangeState) {
    return;
  }
  pvVar1 = _objc_msgSend(HSSoundRecordingController_captureDeviceDidChangeState,sel_isConnected);
  if (((char)pvVar1 != '\0') &&
     (pvVar1 = _objc_msgSend(HSSoundRecordingController_captureDeviceDidChangeState,
                             sel_QTE_isInUseByAnotherApplication), (char)pvVar1 == '\0')) {
    pvVar1 = _objc_msgSend(HSSoundRecordingController_captureDeviceDidChangeState,
                           sel_attributeForKey_,*(undefined4 *)PTR_00336400);
    pvVar1 = _objc_msgSend(pvVar1,sel_boolValue);
    if ((char)pvVar1 == '\0') goto LAB_0007c698;
  }
  _objc_msgSend(self->_countDownViewController,sel_stopRun);
  pvVar1 = _objc_msgSend(self,sel_isRecording);
  if ((char)pvVar1 != '\0') {
    _objc_msgSend(self,sel_stopRecord);
  }
LAB_0007c698:
  _objc_msgSend(self,sel_updateUI);
  return;
}

*/
- (void)HSSoundRecordingController_captureDeviceDidChangeState:(id)aState
{
    if ([_audioDeviceInput device] != aState) {
        return;
    }
    if (![aState isConnected] || [aState QTE_isInUseByAnotherApplication] || [[aState attributeForKey:QTCaptureDeviceSuspendedAttribute] boolValue]) {
        /* The device went away: stop the countdown and any recording. */
        [_countDownViewController stopRun];
        if ([self isRecording]) {
            [self stopRecord];
        }
    }
    [self updateUI];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007ce02 @ 0007ce02, 300 bytes * /

void FUN_0007ce02(HSSoundRecordingController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  _objc_msgSend(self,sel_updateUI);
  pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,&cfstr_OK,&cfstr_empty,
                         &cfstr_Alerts);
  pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                         &cfstr_Free_some_disk_space_and_try_recording_again_,&cfstr_empty,
                         &cfstr_Alerts);
  pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,
                         &cfstr_Not_enough_disk_space_to_save_sound_being_record,&cfstr_empty,
                         &cfstr_Alerts);
  _NSRunCriticalAlertPanel(pvVar3,pvVar2,pvVar1,0,0);
  return;
}

*/
- (void)informAboutDiskSpaceError
{
    [self updateUI];
    NSString *ok = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"OK" value:@"" table:@"Alerts"];
    NSString *message = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Free some disk space and try recording again." value:@"" table:@"Alerts"];
    NSString *title = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Not enough disk space to save sound being recorded" value:@"" table:@"Alerts"];
    NSRunCriticalAlertPanel(title, @"%@", ok, nil, nil, message);
}

- (id)audioCaptureDeviceList
{
    id pvVar1;
    id pvVar1_3;

    pvVar1 = _audioCaptureDeviceList;
    if (pvVar1 == nil) {
        pvVar1_3 = [[NSArray alloc] initWithObjects:QTMediaTypeSound, QTMediaTypeMuxed, nil];
        _audioCaptureDeviceList = [[HSCaptureDeviceList captureDeviceListForMediaTypes:pvVar1_3] retain];
        [pvVar1_3 release];
        pvVar1 = _audioCaptureDeviceList;
    }
    return pvVar1;
}

- (void)setUpOnRecordButton
{
    [[_playbackMatrix cellAtRow:0 column:0] setImage:_onRecordImage];
    [[_playbackMatrix cellAtRow:0 column:0] setGraphiteAlternateImage:_onRecordPressedImageGraphite];
}

- (void)setUpRecordButton
{
    [[_playbackMatrix cellAtRow:0 column:0] setImage:_recordImage];
    [[_playbackMatrix cellAtRow:0 column:0] setGraphiteAlternateImage:_recordPressedImageGraphite];
}

- (void)setUpStopButton
{
    [[_playbackMatrix cellAtRow:0 column:1] setImage:_stopImage];
    [[_playbackMatrix cellAtRow:0 column:1] setAquaAlternateImage:_stopPressedImageAqua];
    [[_playbackMatrix cellAtRow:0 column:1] setGraphiteAlternateImage:_stopPressedImageGraphite];
}

- (void)setUpPlayButton
{
    [[_playbackMatrix cellAtRow:0 column:1] setImage:_playImage];
    [[_playbackMatrix cellAtRow:0 column:1] setAquaAlternateImage:_playPressedImageAqua];
    [[_playbackMatrix cellAtRow:0 column:1] setGraphiteAlternateImage:_playPressedImageGraphite];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007c1a3 @ 0007c1a3, 163 bytes * /

void FUN_0007c1a3(HSSoundRecordingController *self,SEL _cmd,id trackingButtonCell,BOOL isTracking,
                 BOOL wasTracking,BOOL isInside,BOOL wasInside)

{
  SEL op;
  id pvVar1;
  undefined4 uVar2;
  undefined4 uVar3;
  
  uVar3 = 1;
  uVar2 = 0;
  pvVar1 = _objc_msgSend(self->_playbackMatrix,sel_cellAtRow_column_,0,1);
  op = sel_togglePlay;
  if (pvVar1 != trackingButtonCell) {
    uVar3 = 0;
    uVar2 = 0;
    pvVar1 = _objc_msgSend(self->_playbackMatrix,sel_cellAtRow_column_,0,0);
    op = sel_toggleRecord;
    if (pvVar1 != trackingButtonCell) {
      return;
    }
  }
  if ((isTracking == '\0') && (isInside != '\0')) {
    _objc_msgSend(self,op,uVar2,uVar3);
  }
  return;
}

*/
- (void)trackingButtonCell:(id)aCell isTracking:(BOOL)aTracking wasTracking:(BOOL)aTracking2 isInside:(BOOL)aInside wasInside:(BOOL)aInside2
{
    SEL action;
    if ([_playbackMatrix cellAtRow:0 column:1] == aCell) {
        action = @selector(togglePlay);
    } else if ([_playbackMatrix cellAtRow:0 column:0] == aCell) {
        action = @selector(toggleRecord);
    } else {
        return;
    }
    /* Act when the mouse goes up inside the button. */
    if (!aTracking && aInside) {
        [self performSelector:action];
    }
}

- (void)setPlaybackButtonsDelegate:(id)aDelegate
{
    int iVar1;

    iVar1 = 0;
    do {
        [[_playbackMatrix cellAtRow:0 column:iVar1] setDelegate:aDelegate];
        iVar1 = iVar1 + 1;
    } while (iVar1 != 2);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007cf2e @ 0007cf2e, 538 bytes * /

void FUN_0007cf2e(HSSoundRecordingController *self,SEL _cmd,id updateIndicatorState)

{
  undefined4 uVar1;
  undefined4 uVar2;
  id self_00;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id self_01;
  id pvVar6;
  HSDiscreteIndicatorView *self_02;
  longdouble lVar7;
  double dVar8;
  undefined8 in_stack_ffffffbc;
  uint uVar10;
  longlong lVar9;
  undefined4 uVar11;
  uint local_2c;
  id local_28;
  float local_24;
  
  if (self->_audioFileOutput == (id)0x0) {
    return;
  }
  self_00 = _objc_msgSend(self->_audioFileOutput,sel_connections);
  pvVar3 = _objc_msgSend(self_00,sel_count);
  uVar10 = (uint)((ulonglong)in_stack_ffffffbc >> 0x20);
  if (pvVar3 == (id)0x0) {
    self_02 = self->_levelIndicator;
  }
  else {
    uVar1 = *(undefined4 *)PTR_00336404;
    local_24 = 0.0;
    local_2c = 0;
    uVar2 = *(undefined4 *)PTR_003363fc;
    local_28 = (id)0x0;
    do {
      uVar11 = (undefined4)((ulonglong)in_stack_ffffffbc >> 0x20);
      pvVar4 = _objc_msgSend(self_00,sel_objectAtIndex_,local_28);
      pvVar5 = _objc_msgSend(pvVar4,sel_mediaType);
      in_stack_ffffffbc = CONCAT44(uVar11,uVar1);
      pvVar5 = _objc_msgSend(pvVar5,sel_isEqualToString_,uVar1);
      if ((char)pvVar5 != '\0') {
        in_stack_ffffffbc = CONCAT44((int)((ulonglong)in_stack_ffffffbc >> 0x20),uVar2);
        pvVar4 = _objc_msgSend(pvVar4,sel_attributeForKey_,uVar2);
        pvVar5 = _objc_msgSend(pvVar4,sel_count);
        if (pvVar5 != (id)0x0) {
          if (pvVar5 < (id)0x2) {
            pvVar5 = (id)0x1;
          }
          pvVar6 = (id)0x0;
          do {
            in_stack_ffffffbc = CONCAT44((int)((ulonglong)in_stack_ffffffbc >> 0x20),pvVar6);
            self_01 = _objc_msgSend(pvVar4,sel_objectAtIndex_,pvVar6);
            dVar8 = _objc_msgSend_fpret(self_01,sel_floatValue);
            pvVar6 = (id)((int)pvVar6 + 1);
            local_24 = local_24 + (float)dVar8;
          } while (pvVar5 != pvVar6);
          local_2c = local_2c + (int)pvVar5;
        }
      }
      uVar10 = (uint)((ulonglong)in_stack_ffffffbc >> 0x20);
      local_28 = (id)((int)local_28 + 1);
    } while (local_28 < pvVar3);
    self_02 = self->_levelIndicator;
    if (local_2c != 0) {
      dVar8 = (double)(local_24 /
                      (float)((double)((ulonglong)local_2c | 0x4330000000000000) -
                             4503599627370496.0)) * 0.05;
      lVar7 = (longdouble)_pow(0x4024000000000000,dVar8);
      lVar9 = CONCAT44((int)((ulonglong)dVar8 >> 0x20),(float)((double)lVar7 * 17.0));
      goto LAB_0007d13b;
    }
  }
  lVar9 = (ulonglong)uVar10 << 0x20;
LAB_0007d13b:
  _objc_msgSend(self_02,sel_setValue_,lVar9);
  return;
}

*/
- (void)updateIndicatorState:(id)aState
{
    if (_audioFileOutput == nil) {
        return;
    }
    NSArray *connections = [_audioFileOutput connections];
    NSUInteger count = [connections count];
    float value = 0.0f;
    if (count != 0) {
        float totalLevel = 0.0f;
        unsigned int levelCount = 0;
        for (NSUInteger i = 0; i < count; i++) {
            QTCaptureConnection *connection = [connections objectAtIndex:i];
            if (![[connection mediaType] isEqualToString:QTMediaTypeSound]) {
                continue;
            }
            NSArray *levels = [connection attributeForKey:QTCaptureConnectionAudioAveragePowerLevelsAttribute];
            NSUInteger levelsCount = [levels count];
            if (levelsCount != 0) {
                for (NSUInteger j = 0; j < levelsCount; j++) {
                    totalLevel += [[levels objectAtIndex:j] floatValue];
                }
                levelCount += (unsigned int)levelsCount;
            }
        }
        if (levelCount != 0) {
            /* Average dB to amplitude, on the indicator's 0..17 scale. */
            value = (float)(pow(10.0, (double)(totalLevel / (float)levelCount) * 0.05) * 17.0);
        }
    }
    [_levelIndicator setValue:value];
}

- (void)removeTimerForObservingInputAudioLevel
{
    if (_timerForObservingInputAudioLevel != nil) {
        [_timerForObservingInputAudioLevel invalidate];
        [_timerForObservingInputAudioLevel release];
        _timerForObservingInputAudioLevel = nil;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007bfdf @ 0007bfdf, 283 bytes * /

void FUN_0007bfdf(HSSoundRecordingController *self,SEL _cmd)

{
  undefined *puVar1;
  undefined *self_00;
  id pvVar2;
  
  _objc_msgSend(self,sel_removeTimerForObservingInputAudioLevel);
  self_00 = cls_NSTimer;
  puVar1 = sel_updateIndicatorState_;
  pvVar2 = _objc_msgSend(self,sel_NSE_newWeakProxy);
  pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
  pvVar2 = _objc_msgSend(self_00,
                         sel_scheduledTimerWithTimeInterval_target_selector_userInfo_repeats_,
                         0x9999999a,0x3fb99999,pvVar2,puVar1,0,1);
  pvVar2 = _objc_msgSend(pvVar2,sel_retain);
  self->_timerForObservingInputAudioLevel = pvVar2;
  pvVar2 = _objc_msgSend(cls_NSRunLoop,sel_currentRunLoop);
  _objc_msgSend(pvVar2,sel_addTimer_forMode_,self->_timerForObservingInputAudioLevel,
                *(undefined4 *)PTR_003363f8);
  _objc_msgSend(pvVar2,sel_addTimer_forMode_,self->_timerForObservingInputAudioLevel,
                *(undefined4 *)PTR_00336064);
  return;
}

*/
- (void)installTimerForObservingInputAudioLevel
{
    [self removeTimerForObservingInputAudioLevel];
    _timerForObservingInputAudioLevel = [[NSTimer scheduledTimerWithTimeInterval:0.1 target:[[self NSE_newWeakProxy] autorelease] selector:@selector(updateIndicatorState:) userInfo:nil repeats:YES] retain];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:_timerForObservingInputAudioLevel forMode:NSModalPanelRunLoopMode];
    [runLoop addTimer:_timerForObservingInputAudioLevel forMode:NSEventTrackingRunLoopMode];
}

- (void)updateSoundDuration:(id)aDuration
{
    double dVar2;
    id pvVar1_3;

    if (![self isRecording]) {
        if (![self isPlaying]) {
            return;
        }
        pvVar1_3 = _currentPlaybackAudioTimeTextField;
        dVar2 = [self soundDurationForTextField:pvVar1_3];
    }
    else {
        pvVar1_3 = _recordedAudioTimeTextField;
        dVar2 = [self soundDurationForTextField:pvVar1_3];
    }
    [self setSoundDuration:dVar2 + 1.0 forTextField:pvVar1_3];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007bf60 @ 0007bf60, 127 bytes * /

double FUN_0007bf60(HSSoundRecordingController *self,SEL _cmd,id soundDurationForTextField)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar1 = _objc_msgSend(soundDurationForTextField,sel_objectValue);
  pvVar2 = _objc_msgSend(pvVar1,sel_hourOfDay);
  pvVar3 = _objc_msgSend(pvVar1,sel_minuteOfHour);
  pvVar1 = _objc_msgSend(pvVar1,sel_secondOfMinute);
  return (double)((int)pvVar1 + (int)pvVar3 * 0x3c + (int)pvVar2 * 0xe10);
}

*/
- (double)soundDurationForTextField:(id)aField
{
    id date = [aField objectValue];
    return (double)([date secondOfMinute] + [date minuteOfHour] * 60 + [date hourOfDay] * 3600);
}

- (void)setSoundDuration:(double)aDuration forTextField:(id)aField
{
    unsigned int uVar2;

    uVar2 = (int)aDuration;
    if (2147483648.0 <= aDuration) {
        uVar2 = (int)(aDuration - 2147483648.0) ^ 0x80000000;
    }
    [aField setObjectValue:[NSCalendarDate dateWithYear:0 month:0 day:0 hour:0 minute:0 second:uVar2 timeZone:nil]];
}

- (void)removeTimerForMeasurementSoundDuration
{
    if (_timerForMeasurementRecordAudioTime != nil) {
        [_timerForMeasurementRecordAudioTime invalidate];
        [_timerForMeasurementRecordAudioTime release];
        _timerForMeasurementRecordAudioTime = nil;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007bd57 @ 0007bd57, 283 bytes * /

void FUN_0007bd57(HSSoundRecordingController *self,SEL _cmd)

{
  undefined *puVar1;
  undefined *self_00;
  id pvVar2;
  
  _objc_msgSend(self,sel_removeTimerForMeasurementSoundDuration);
  self_00 = cls_NSTimer;
  puVar1 = sel_updateSoundDuration_;
  pvVar2 = _objc_msgSend(self,sel_NSE_newWeakProxy);
  pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
  pvVar2 = _objc_msgSend(self_00,
                         sel_scheduledTimerWithTimeInterval_target_selector_userInfo_repeats_,0,
                         0x3ff00000,pvVar2,puVar1,0,1);
  pvVar2 = _objc_msgSend(pvVar2,sel_retain);
  self->_timerForMeasurementRecordAudioTime = pvVar2;
  pvVar2 = _objc_msgSend(cls_NSRunLoop,sel_currentRunLoop);
  _objc_msgSend(pvVar2,sel_addTimer_forMode_,self->_timerForMeasurementRecordAudioTime,
                *(undefined4 *)PTR_003363f8);
  _objc_msgSend(pvVar2,sel_addTimer_forMode_,self->_timerForMeasurementRecordAudioTime,
                *(undefined4 *)PTR_00336064);
  return;
}

*/
- (void)installTimerForMeasurementSoundDuration
{
    [self removeTimerForMeasurementSoundDuration];
    _timerForMeasurementRecordAudioTime = [[NSTimer scheduledTimerWithTimeInterval:1.0 target:[[self NSE_newWeakProxy] autorelease] selector:@selector(updateSoundDuration:) userInfo:nil repeats:YES] retain];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:_timerForMeasurementRecordAudioTime forMode:NSModalPanelRunLoopMode];
    [runLoop addTimer:_timerForMeasurementRecordAudioTime forMode:NSEventTrackingRunLoopMode];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007baf6 @ 0007baf6, 609 bytes * /

void FUN_0007baf6(HSSoundRecordingController *self,SEL _cmd)

{
  char cVar1;
  char cVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  SEL pcVar6;
  byte bVar7;
  uint uVar8;
  undefined4 uVar9;
  undefined4 uVar10;
  
  pvVar3 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
  pvVar4 = _objc_msgSend(self,sel_fileName);
  pvVar3 = _objc_msgSend(pvVar3,sel_fileExistsAtPath_,pvVar4);
  pvVar5 = _objc_msgSend(self,sel_isRecording);
  if (((char)pvVar5 == '\0') &&
     (pvVar5 = _objc_msgSend(self->_countDownViewController,sel_isRunning,pvVar4),
     (char)pvVar5 == '\0')) {
    bVar7 = 0;
  }
  else {
    bVar7 = 1;
  }
  pvVar4 = _objc_msgSend(self,sel_isPlaying,pvVar4);
  cVar1 = (char)pvVar4;
  pcVar6 = sel_setUpPlayButton;
  if (cVar1 != '\0') {
    pcVar6 = sel_setUpStopButton;
  }
  _objc_msgSend(self,pcVar6);
  pcVar6 = sel_setUpRecordButton;
  if (bVar7 != 0) {
    pcVar6 = sel_setUpOnRecordButton;
  }
  _objc_msgSend(self,pcVar6);
  _objc_msgSend(self->_audioCaptureDevicesPopUp,sel_setEnabled_,(int)(char)(bVar7 ^ 1));
  uVar8 = (uint)(bVar7 != 1 && (char)pvVar3 != '\0');
  pvVar3 = _objc_msgSend(self->_playbackMatrix,sel_cellAtRow_column_,0,1);
  _objc_msgSend(pvVar3,sel_setEnabled_,uVar8);
  uVar10 = 0;
  uVar9 = 0;
  pvVar3 = _objc_msgSend(self->_playbackMatrix,sel_cellAtRow_column_,0,0);
  if ((cVar1 == '\0') &&
     (pvVar4 = _objc_msgSend(self,sel_isInputSoundValid,uVar9,uVar10), (char)pvVar4 != '\0')) {
    cVar2 = '\x01';
  }
  else {
    cVar2 = '\0';
  }
  _objc_msgSend(pvVar3,sel_setEnabled_,(int)cVar2,uVar10);
  _objc_msgSend(self->_addToCardButton,sel_setEnabled_,uVar8);
  pvVar3 = _objc_msgSend(self->_viewContainer,sel_subviews);
  pvVar3 = _objc_msgSend(pvVar3,sel_objectAtIndex_,0);
  if ((cVar1 == '\0') || (pvVar4 = self->_playbackAudioTimeView, pvVar3 == pvVar4)) {
    pvVar4 = self->_recordedAudioTimeView;
    if (pvVar3 == pvVar4) {
      return;
    }
    pvVar3 = self->_viewContainer;
    pvVar5 = self->_playbackAudioTimeView;
  }
  else {
    pvVar3 = self->_viewContainer;
    pvVar5 = self->_recordedAudioTimeView;
  }
  _objc_msgSend(pvVar3,sel_replaceSubview_with_,pvVar5,pvVar4);
  return;
}

*/
- (void)updateUI
{
    BOOL hasSound = [[NSFileManager defaultManager] fileExistsAtPath:[self fileName]];
    BOOL isRecording = [self isRecording] || [_countDownViewController isRunning];
    BOOL isPlaying = [self isPlaying];
    if (isPlaying) {
        [self setUpStopButton];
    } else {
        [self setUpPlayButton];
    }
    if (isRecording) {
        [self setUpOnRecordButton];
    } else {
        [self setUpRecordButton];
    }
    [_audioCaptureDevicesPopUp setEnabled:!isRecording];
    BOOL canUseSound = !isRecording && hasSound;
    [[_playbackMatrix cellAtRow:0 column:1] setEnabled:canUseSound];
    [[_playbackMatrix cellAtRow:0 column:0] setEnabled:!isPlaying && [self isInputSoundValid]];
    [_addToCardButton setEnabled:canUseSound];
    /* Show the playback time while playing, the recorded time otherwise. */
    NSView *shownView = [[_viewContainer subviews] objectAtIndex:0];
    if (isPlaying && shownView != _playbackAudioTimeView) {
        [_viewContainer replaceSubview:_recordedAudioTimeView with:_playbackAudioTimeView];
    } else if (!isPlaying && shownView != _recordedAudioTimeView) {
        [_viewContainer replaceSubview:_playbackAudioTimeView with:_recordedAudioTimeView];
    }
}

- (void)removeSound
{
    if (_sound != nil) {
        if ([self isPlaying]) {
            [self stopPlayback];
        }
        [_sound setDelegate:0];
        [_sound release];
        _sound = nil;
    }
}

- (void)removeSoundFileAtPath:(id)aPath
{
    NSFileManager *pvVar1;

    if (aPath != nil) {
        pvVar1 = [NSFileManager defaultManager];
        if ([pvVar1 fileExistsAtPath:aPath]) {
            [[NSFileManager defaultManager] removeFileAtPath:aPath handler:nil];
        }
    }
}

- (void)invalidateSoundRecord
{
    id pvVar1;
    NSFileManager *pvVar2;
    id pvVar1_2;

    [self removeSound];
    pvVar1 = [self fileName];
    if (pvVar1 != nil) {
        pvVar2 = [NSFileManager defaultManager];
        if ([pvVar2 fileExistsAtPath:pvVar1]) {
            pvVar1_2 = [[NSSound alloc] initWithContentsOfFile:pvVar1 byReference:YES];
            _sound = pvVar1_2;
            [pvVar1_2 setDelegate:self];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007b853 @ 0007b853, 215 bytes * /

void FUN_0007b853(HSSoundRecordingController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_isPlaying);
  if ((char)pvVar1 == '\0') {
    pvVar1 = self->_totalPlaybackAudioTimeTextField;
    pvVar2 = _objc_msgSend(self->_recordedAudioTimeTextField,sel_objectValue);
    _objc_msgSend(pvVar1,sel_setObjectValue_,pvVar2);
    _objc_msgSend(self,sel_setSoundDuration_forTextField_,0,0,
                  self->_currentPlaybackAudioTimeTextField);
    _objc_msgSend(self,sel_installTimerForMeasurementSoundDuration);
    op = sel_startPlayback;
  }
  else {
    _objc_msgSend(self,sel_removeTimerForMeasurementSoundDuration);
    op = sel_stopPlayback;
  }
  _objc_msgSend(self,op);
  _objc_msgSend(self,sel_updateUI);
  return;
}

*/
- (void)togglePlay
{
    if ([self isPlaying]) {
        [self removeTimerForMeasurementSoundDuration];
        [self stopPlayback];
    } else {
        [_totalPlaybackAudioTimeTextField setObjectValue:[_recordedAudioTimeTextField objectValue]];
        [self setSoundDuration:0.0 forTextField:_currentPlaybackAudioTimeTextField];
        [self installTimerForMeasurementSoundDuration];
        [self startPlayback];
    }
    [self updateUI];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007b81d @ 0007b81d, 54 bytes * /

void FUN_0007b81d(HSSoundRecordingController *self,SEL _cmd)

{
  if (self->_sound != (id)0x0) {
    _objc_msgSend(self->_sound,sel_stop);
    self->_isPlaying[0] = self->_isPlaying[0] & 0xfe;
  }
  return;
}

*/
- (void)stopPlayback
{
    if (_sound != nil) {
        [_sound stop];
        _isPlaying = 0;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007b7c3 @ 0007b7c3, 90 bytes * /

void FUN_0007b7c3(HSSoundRecordingController *self,SEL _cmd)

{
  if ((self->_isPlaying[0] & 4) != 0) {
    _objc_msgSend(self,sel_invalidateSoundRecord);
    self->_isPlaying[0] = self->_isPlaying[0] & 0xfb;
  }
  if (self->_sound != (id)0x0) {
    _objc_msgSend(self->_sound,sel_play);
    self->_isPlaying[0] = self->_isPlaying[0] | 1;
  }
  return;
}

*/
- (void)startPlayback
{
    if (_isChangeSoundRecord) {
        [self invalidateSoundRecord];
        _isChangeSoundRecord = 0;
    }
    if (_sound != nil) {
        [_sound play];
        _isPlaying = 1;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007b796 @ 0007b796, 45 bytes * /

void FUN_0007b796(HSSoundRecordingController *self,SEL _cmd,id sound,BOOL didFinishPlaying)

{
  self->_isPlaying[0] = self->_isPlaying[0] & 0xfe;
  _objc_msgSend(self,sel_updateUI);
  return;
}

*/
- (void)sound:(id)aSound didFinishPlaying:(BOOL)aPlaying
{
    _isPlaying = 0;
    [self updateUI];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007b4ef @ 0007b4ef, 679 bytes * /

void FUN_0007b4ef(HSSoundRecordingController *self,SEL _cmd,id countDownDidEnd)

{
  HSSoundRecordingController *pHVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id self_00;
  id pvVar5;
  HSSoundRecordingController *pHVar6;
  int extraout_EDX;
  id pvVar7;
  SEL op;
  
  pvVar2 = _objc_msgSend(self,sel_fileName);
  pvVar3 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
  pvVar4 = _objc_msgSend(pvVar2,sel_stringByDeletingLastPathComponent);
  pvVar4 = _objc_msgSend(pvVar3,sel_fileSystemAttributesAtPath_,pvVar4);
  pvVar3 = *(id *)PTR_003363f4;
  pvVar4 = _objc_msgSend(pvVar4,sel_objectForKey_,pvVar3);
  pvVar4 = _objc_msgSend(pvVar4,sel_unsignedLongLongValue);
  pHVar6 = self;
  op = sel_informAboutDiskSpaceError;
  if (extraout_EDX != 0 || (id)0x63fffff < pvVar4) {
    self->_isPlaying[0] = self->_isPlaying[0] | 4;
    pvVar3 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_,pvVar2);
    if (pvVar3 == (id)0x0) goto LAB_0007b779;
    _objc_msgSend(self->_audioFileOutput,sel_setDelegate_,self);
    pvVar2 = _objc_msgSend(self->_audioFileOutput,sel_connections);
    pvVar4 = _objc_msgSend(pvVar2,sel_count);
    if (pvVar4 != (id)0x0) {
      pHVar1 = *(HSSoundRecordingController **)PTR_00336404;
      pvVar7 = (id)0x0;
      do {
        self_00 = _objc_msgSend(pvVar2,sel_objectAtIndex_,pvVar7);
        pvVar5 = _objc_msgSend(self_00,sel_mediaType);
        pHVar6 = pHVar1;
        pvVar5 = _objc_msgSend(pvVar5,sel_isEqualToString_,pHVar1);
        if ((char)pvVar5 != '\0') {
          pHVar6 = _objc_msgSend(cls_QTCompressionOptions,sel_compressionOptionsWithIdentifier_,
                                 &cfstr_QTCompressionOptionsVoiceQualityAACAudio);
          _objc_msgSend(self->_audioFileOutput,sel_setCompressionOptions_forConnection_,pHVar6,
                        self_00);
        }
        pvVar7 = (id)((int)pvVar7 + 1);
      } while (pvVar7 < pvVar4);
    }
    _objc_msgSend(self,sel_removeSound,pHVar6);
    _objc_msgSend(self,sel_removeSoundFileAtPath_,self->_audioOutputFilePath);
    _objc_msgSend(self,sel_setSoundDuration_forTextField_,0,0,self->_recordedAudioTimeTextField);
    _objc_msgSend(self,sel_installTimerForMeasurementSoundDuration);
    self->_isPlaying[0] = self->_isPlaying[0] & 0xe5 | 2;
    pHVar6 = self->_audioFileOutput;
    op = sel_recordToOutputFileURL_;
  }
  _objc_msgSend(pHVar6,op,pvVar3);
  pvVar2 = pvVar3;
LAB_0007b779:
  _objc_msgSend(self,sel_updateUI,pvVar2);
  return;
}

*/
- (void)countDownDidEnd:(id)aEnd
{
    NSString *path = [self fileName];
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[path stringByDeletingLastPathComponent] error:NULL];
    /* Recording needs 100 MB free. */
    if ([[attributes objectForKey:NSFileSystemFreeSize] unsignedLongLongValue] < 0x6400000ULL) {
        [self informAboutDiskSpaceError];
    } else {
        _isChangeSoundRecord = 1;
        NSURL *url = [NSURL fileURLWithPath:path];
        if (url != nil) {
            [_audioFileOutput setDelegate:self];
            NSArray *connections = [_audioFileOutput connections];
            NSUInteger count = [connections count];
            for (NSUInteger i = 0; i < count; i++) {
                QTCaptureConnection *connection = [connections objectAtIndex:i];
                if ([[connection mediaType] isEqualToString:QTMediaTypeSound]) {
                    [_audioFileOutput setCompressionOptions:[QTCompressionOptions compressionOptionsWithIdentifier:@"QTCompressionOptionsVoiceQualityAACAudio"] forConnection:connection];
                }
            }
            [self removeSound];
            [self removeSoundFileAtPath:_audioOutputFilePath];
            [self setSoundDuration:0.0 forTextField:_recordedAudioTimeTextField];
            [self installTimerForMeasurementSoundDuration];
            _didCaptureMovieFileOutputStartRecording = 0;
            _didCaptureMovieFileOutputFinishRecording = 0;
            _isRecording = 1;
            [_audioFileOutput recordToOutputFileURL:url];
        }
    }
    [self updateUI];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007b495 @ 0007b495, 90 bytes * /

void FUN_0007b495(HSSoundRecordingController *self,SEL _cmd)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_isRecording);
  op = sel_startRecord;
  if ((char)pvVar1 != '\0') {
    op = sel_stopRecord;
  }
  _objc_msgSend(self,op);
  _objc_msgSend(self,sel_updateUI);
  return;
}

*/
- (void)toggleRecord
{
    if ([self isRecording]) {
        [self stopRecord];
    } else {
        [self startRecord];
    }
    [self updateUI];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007d200 @ 0007d200, 186 bytes * /

void FUN_0007d200(HSSoundRecordingController *self,SEL _cmd)

{
  undefined4 uVar1;
  undefined4 uVar2;
  
  if ((self->_isPlaying[0] & 2) != 0) {
    _objc_msgSend(self,sel_removeTimerForMeasurementSoundDuration);
    self->_isPlaying[0] = self->_isPlaying[0] & 0xfd;
    uVar2 = 1;
    _objc_msgSend(self->_audioFileOutput,sel_recordToOutputFileURL_bufferDestination_,0,1);
    uVar1 = *(undefined4 *)PTR_00336408;
    while (((self->_isPlaying[0] & 8) != 0 && ((self->_isPlaying[0] & 0x10) == 0))) {
      uVar2 = 1;
      _CFRunLoopRunInMode(uVar1,0x9999999a,0x3fb99999,1);
    }
    _objc_msgSend(self->_audioFileOutput,sel_setDelegate_,0,uVar2);
  }
  return;
}

*/
- (void)stopRecord
{
    if (!_isRecording) {
        return;
    }
    [self removeTimerForMeasurementSoundDuration];
    _isRecording = 0;
    [_audioFileOutput recordToOutputFileURL:nil bufferDestination:QTCaptureFileOutputBufferDestinationNewFile];
    /* Wait for the file to be finished. */
    while (_didCaptureMovieFileOutputStartRecording && !_didCaptureMovieFileOutputFinishRecording) {
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, true);
    }
    [_audioFileOutput setDelegate:nil];
}

- (void)startRecord
{
    id pvVar1;

    if (_countDownViewController == nil) {
        pvVar1 = [HSCountDownViewController new];
        _countDownViewController = pvVar1;
        [pvVar1 setDelegate:self];
    }
    [[_playbackMatrix cellAtRow:0 column:0] setEnabled:NO];
    [[_playbackMatrix cellAtRow:0 column:1] setEnabled:NO];
    [_countDownViewController runInView:_viewContainer];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007b2c1 @ 0007b2c1, 235 bytes * /

void FUN_0007b2c1(HSSoundRecordingController *self,SEL _cmd,id didEndSheet,int returnCode,
                 void *contextInfo)

{
  id pvVar1;
  undefined *puVar2;
  
  _objc_msgSend(self,sel_prepareRecordingPanelToClose);
  _objc_msgSend(didEndSheet,sel_orderOut_,self);
  puVar2 = sel_soundRecordingDidEndSheet_returnCode_contextInfo_;
  pvVar1 = _objc_msgSend(self->_delegate,sel_respondsToSelector_,
                         sel_soundRecordingDidEndSheet_returnCode_contextInfo_);
  if ((char)pvVar1 != '\0') {
    _objc_msgSend(self->_delegate,sel_soundRecordingDidEndSheet_returnCode_contextInfo_,didEndSheet,
                  returnCode,contextInfo);
    puVar2 = didEndSheet;
  }
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter,puVar2);
  _objc_msgSend(pvVar1,sel_removeObserver_,self);
  _objc_msgSend(self,sel_removeSound);
  _objc_msgSend(self,sel_removeSoundFileAtPath_,self->_audioOutputFilePath);
  return;
}

*/
- (void)didEndSheet:(id)aSheet returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    [self prepareRecordingPanelToClose];
    [aSheet orderOut:self];
    if ([_delegate respondsToSelector:@selector(soundRecordingDidEndSheet:returnCode:contextInfo:)]) {
        [_delegate soundRecordingDidEndSheet:aSheet returnCode:aCode contextInfo:aInfo];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeSound];
    [self removeSoundFileAtPath:_audioOutputFilePath];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007b164 @ 0007b164, 349 bytes * /

void FUN_0007b164(HSSoundRecordingController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  
  _objc_msgSend(self->_countDownViewController,sel_stopRun);
  pvVar1 = _objc_msgSend(self,sel_isRecording);
  if ((char)pvVar1 != '\0') {
    _objc_msgSend(self,sel_stopRecord);
  }
  _objc_msgSend(self,sel_removeTimerForObservingInputAudioLevel);
  _objc_msgSend(self,sel_removeTimerForMeasurementSoundDuration);
  pvVar1 = _objc_msgSend(self->_audioCaptureSession,sel_isRunning);
  if ((char)pvVar1 != '\0') {
    _objc_msgSend(self->_audioCaptureSession,sel_stopRunning);
  }
  _objc_msgSend(self,sel_HSSoundRecordingController_setAudioCaptureDevice_,0);
  _objc_msgSend(self,sel_HSSoundRecordingController_destroyAudioCaptureSession);
  pvVar1 = _objc_msgSend(self,sel_audioCaptureDeviceList);
  pvVar2 = _objc_msgSend(self->_audioCaptureDevicesPopUp,sel_menu);
  _objc_msgSend(pvVar1,sel_detachMenu_,pvVar2);
  _objc_msgSend(self->_levelIndicator,sel_setValue_,0);
  _objc_msgSend(self,sel_setSoundDuration_forTextField_,0,0,self->_recordedAudioTimeTextField);
  return;
}

*/
- (void)prepareRecordingPanelToClose
{
    [_countDownViewController stopRun];
    if ([self isRecording]) {
        [self stopRecord];
    }
    [self removeTimerForObservingInputAudioLevel];
    [self removeTimerForMeasurementSoundDuration];
    if ([_audioCaptureSession isRunning]) {
        [_audioCaptureSession stopRunning];
    }
    [self HSSoundRecordingController_setAudioCaptureDevice:nil];
    [self HSSoundRecordingController_destroyAudioCaptureSession];
    [[self audioCaptureDeviceList] detachMenu:[_audioCaptureDevicesPopUp menu]];
    [_levelIndicator setValue:0.0];
    [self setSoundDuration:0.0 forTextField:_recordedAudioTimeTextField];
}

- (void)prepareRecordingPanel
{
    if (_soundRecordingPanel == nil) {
        [NSBundle loadNibNamed:@"SoundRecordingPanel" owner:self];
    }
    if (0 < (int)[_audioCaptureDevicesPopUp numberOfItems]) {
        if (![self selectDeviceFromUserDefaults]) {
            [self selectDefaultDevice];
        }
    }
    [self updateUI];
}

- (void)selectDefaultDevice
{
    QTCaptureDevice *self_01;

    self_01 = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeSound];
    if (self_01 != nil) {
        [_audioCaptureDevicesPopUp selectItemWithTitle:[self_01 localizedDisplayName]];
        [self HSSoundRecordingController_setAudioCaptureDevice:self_01];
    }
}

- (void)storeSelectedDeviceInUserDefaults
{
    [[NSUserDefaults standardUserDefaults] setObject:[[_audioCaptureDevicesPopUp selectedItem] title] forKey:HSAudioInputDeviceNameKey];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007add1 @ 0007add1, 494 bytes * /

BOOL FUN_0007add1(HSSoundRecordingController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  undefined4 uVar6;
  cfstringStruct *pcVar7;
  cfstringStruct *pcVar8;
  
  pvVar1 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  uVar6 = *(undefined4 *)PTR_003363f0;
  pvVar1 = _objc_msgSend(pvVar1,sel_stringForKey_,uVar6);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle,uVar6);
    pcVar8 = &cfstr_AssistantPanes;
    pcVar7 = &cfstr_empty;
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                           &cfstr_NoneDeviceMenuItemName,&cfstr_empty,&cfstr_AssistantPanes);
    pvVar3 = _objc_msgSend(pvVar1,sel_isEqualToString_,pvVar2);
    if ((char)pvVar3 == '\0') {
      pvVar3 = _objc_msgSend(self->_audioCaptureDevicesPopUp,sel_indexOfSelectedItem,pvVar2,pcVar7,
                             pcVar8);
      pvVar2 = pvVar1;
      _objc_msgSend(self->_audioCaptureDevicesPopUp,sel_selectItemWithTitle_,pvVar1);
      pvVar4 = _objc_msgSend(self->_audioCaptureDevicesPopUp,sel_indexOfSelectedItem);
      if (pvVar4 == (id)0xffffffff) {
        _objc_msgSend(self->_audioCaptureDevicesPopUp,sel_selectItemAtIndex_,pvVar3);
        return '\0';
      }
      pvVar2 = _objc_msgSend(self,sel_audioCaptureDeviceList,pvVar2);
      pvVar4 = (id)0x0;
      pvVar3 = _objc_msgSend(pvVar2,sel_captureDeviceCount);
      while( true ) {
        if (pvVar3 <= pvVar4) {
          return '\x01';
        }
        pvVar5 = _objc_msgSend(pvVar2,sel_localizedDisplayNameForCaptureDeviceAtIndex_,pvVar4);
        pvVar5 = _objc_msgSend(pvVar1,sel_isEqualToString_,pvVar5);
        if ((char)pvVar5 != '\0') break;
        pvVar4 = (id)((int)pvVar4 + 1);
      }
      pvVar1 = _objc_msgSend(pvVar2,sel_captureDeviceAtIndex_,pvVar4);
      _objc_msgSend(self,sel_HSSoundRecordingController_setAudioCaptureDevice_,pvVar1);
      return '\x01';
    }
  }
  return '\0';
}

*/
- (BOOL)selectDeviceFromUserDefaults
{
    NSString *deviceName = [[NSUserDefaults standardUserDefaults] stringForKey:HSAudioInputDeviceNameKey];
    if (deviceName == nil || [deviceName isEqualToString:[[NSBundle mainBundle] localizedStringForKey:@"NoneDeviceMenuItemName" value:@"" table:@"AssistantPanes"]]) {
        return NO;
    }
    NSInteger previousIndex = [_audioCaptureDevicesPopUp indexOfSelectedItem];
    [_audioCaptureDevicesPopUp selectItemWithTitle:deviceName];
    if ([_audioCaptureDevicesPopUp indexOfSelectedItem] == -1) {
        [_audioCaptureDevicesPopUp selectItemAtIndex:previousIndex];
        return NO;
    }
    HSCaptureDeviceList *deviceList = [self audioCaptureDeviceList];
    NSUInteger count = [deviceList captureDeviceCount];
    for (NSUInteger i = 0; i < count; i++) {
        if ([deviceName isEqualToString:[deviceList localizedDisplayNameForCaptureDeviceAtIndex:i]]) {
            [self HSSoundRecordingController_setAudioCaptureDevice:[deviceList captureDeviceAtIndex:i]];
            break;
        }
    }
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007aaab @ 0007aaab, 806 bytes * /

void FUN_0007aaab(HSSoundRecordingController *self,SEL _cmd,
                 id HSSoundRecordingController_setAudioCaptureDevice)

{
  id pvVar1;
  id pvVar2;
  HSSoundRecordingController *pHVar3;
  HSSoundRecordingController *pHVar4;
  undefined4 uVar5;
  cfstringStruct *pcVar6;
  undefined4 uVar7;
  
  pvVar1 = _objc_msgSend(self->_audioDeviceInput,sel_device);
  pvVar1 = _objc_msgSend(pvVar1,sel_uniqueID);
  pvVar2 = _objc_msgSend(HSSoundRecordingController_setAudioCaptureDevice,sel_uniqueID);
  pvVar1 = _objc_msgSend(pvVar1,sel_isEqual_,pvVar2);
  if ((char)pvVar1 != '\0') {
    return;
  }
  pvVar1 = _objc_msgSend(self,sel_HSSoundRecordingController_audioCaptureSession,pvVar2);
  if (self->_audioDeviceInput != (id)0x0) {
    pvVar2 = _objc_msgSend(self->_audioDeviceInput,sel_device,pvVar2);
    _objc_msgSend(pvVar2,sel_removeObserver_forKeyPath_,self,&cfstr_inUseByAnotherApplication);
    _objc_msgSend(pvVar2,sel_removeObserver_forKeyPath_,self,&cfstr_suspended);
    _objc_msgSend(pvVar2,sel_removeObserver_forKeyPath_,self,&cfstr_connected);
    _objc_msgSend(pvVar1,sel_removeInput_,self->_audioDeviceInput);
    pvVar2 = _objc_msgSend(self->_audioDeviceInput,sel_device);
    _objc_msgSend(pvVar2,sel_close);
    _objc_msgSend(self->_audioDeviceInput,sel_release);
    self->_audioDeviceInput = (id)0x0;
  }
  pHVar4 = (HSSoundRecordingController *)0x0;
  pvVar2 = _objc_msgSend(HSSoundRecordingController_setAudioCaptureDevice,sel_open_,0);
  if ((char)pvVar2 == '\0') {
LAB_0007ad9b:
    pvVar2 = self->_audioDeviceInput;
  }
  else {
    pvVar2 = _objc_msgSend(cls_QTCaptureDeviceInput,sel_alloc,pHVar4);
    pHVar4 = HSSoundRecordingController_setAudioCaptureDevice;
    pHVar3 = _objc_msgSend(pvVar2,sel_initWithDevice_,
                           HSSoundRecordingController_setAudioCaptureDevice);
    self->_audioDeviceInput = pHVar3;
    pvVar2 = (id)0x0;
    if (pHVar3 != (HSSoundRecordingController *)0x0) {
      uVar5 = 0;
      pvVar2 = _objc_msgSend(pvVar1,sel_addInput_error_,pHVar3,0);
      if ((char)pvVar2 == '\0') {
        _objc_msgSend(HSSoundRecordingController_setAudioCaptureDevice,sel_close,pHVar3,uVar5);
        _objc_msgSend(self->_audioDeviceInput,sel_release);
        self->_audioDeviceInput = (id)0x0;
        goto LAB_0007ada2;
      }
      _objc_msgSend(HSSoundRecordingController_setAudioCaptureDevice,
                    sel_addObserver_forKeyPath_options_context_,self,
                    &cfstr_inUseByAnotherApplication,0,0);
      _objc_msgSend(HSSoundRecordingController_setAudioCaptureDevice,
                    sel_addObserver_forKeyPath_options_context_,self,&cfstr_suspended,0,0);
      pcVar6 = &cfstr_connected;
      uVar7 = 0;
      uVar5 = 0;
      pHVar4 = self;
      _objc_msgSend(HSSoundRecordingController_setAudioCaptureDevice,
                    sel_addObserver_forKeyPath_options_context_,self,&cfstr_connected,0,0);
      pvVar2 = _objc_msgSend(pvVar1,sel_isRunning);
      if ((char)pvVar2 == '\0') {
        _objc_msgSend(pvVar1,sel_startRunning,pHVar4,pcVar6,uVar5,uVar7);
      }
      _objc_msgSend(self,sel_installTimerForObservingInputAudioLevel,pHVar4,pcVar6,uVar5,uVar7);
      goto LAB_0007ad9b;
    }
  }
  pHVar3 = pHVar4;
  if (pvVar2 != (id)0x0) {
    return;
  }
LAB_0007ada2:
  _objc_msgSend(pvVar1,sel_stopRunning,pHVar3);
  _objc_msgSend(self,sel_removeTimerForObservingInputAudioLevel);
  return;
}

*/
- (void)HSSoundRecordingController_setAudioCaptureDevice:(id)aDevice
{
    if ([[[_audioDeviceInput device] uniqueID] isEqual:[(QTCaptureDevice *)aDevice uniqueID]]) {
        return;
    }
    QTCaptureSession *session = [self HSSoundRecordingController_audioCaptureSession];
    if (_audioDeviceInput != nil) {
        QTCaptureDevice *device = [_audioDeviceInput device];
        [device removeObserver:self forKeyPath:@"inUseByAnotherApplication"];
        [device removeObserver:self forKeyPath:@"suspended"];
        [device removeObserver:self forKeyPath:@"connected"];
        [session removeInput:_audioDeviceInput];
        [[_audioDeviceInput device] close];
        [_audioDeviceInput release];
        _audioDeviceInput = nil;
    }
    if ([(QTCaptureDevice *)aDevice open:NULL]) {
        _audioDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:aDevice];
        if (_audioDeviceInput != nil) {
            if (![session addInput:_audioDeviceInput error:NULL]) {
                [aDevice close];
                [_audioDeviceInput release];
                _audioDeviceInput = nil;
            } else {
                [aDevice addObserver:self forKeyPath:@"inUseByAnotherApplication" options:0 context:NULL];
                [aDevice addObserver:self forKeyPath:@"suspended" options:0 context:NULL];
                [aDevice addObserver:self forKeyPath:@"connected" options:0 context:NULL];
                if (![session isRunning]) {
                    [session startRunning];
                }
                [self installTimerForObservingInputAudioLevel];
            }
        }
    }
    if (_audioDeviceInput == nil) {
        [session stopRunning];
        [self removeTimerForObservingInputAudioLevel];
    }
}

- (void)HSSoundRecordingController_destroyAudioCaptureSession
{
    id pvVar1_2;

    if ([_audioCaptureSession isRunning]) {
        [_audioCaptureSession stopRunning];
    }
    pvVar1_2 = nil;
    if (_audioFileOutput != nil) {
        [_audioCaptureSession removeOutput:_audioFileOutput];
        pvVar1_2 = _audioFileOutput;
    }
    [pvVar1_2 release];
    _audioFileOutput = nil;
    [_audioCaptureSession release];
    _audioCaptureSession = nil;
}

- (id)HSSoundRecordingController_audioCaptureSession
{
    id pvVar1;
    id pvVar1_3;

    pvVar1 = _audioCaptureSession;
    if (pvVar1 == nil) {
        _audioCaptureSession = [QTCaptureSession new];
        pvVar1_3 = [QTCaptureMovieFileOutput new];
        _audioFileOutput = pvVar1_3;
        if (![_audioCaptureSession addOutput:pvVar1_3 error:nil]) {
            [_audioFileOutput release];
            _audioFileOutput = nil;
            [_audioCaptureSession release];
            _audioCaptureSession = nil;
            pvVar1 = nil;
        }
        else {
            pvVar1 = _audioCaptureSession;
        }
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007a1d1 @ 0007a1d1, 1919 bytes * /

void FUN_0007a1d1(HSSoundRecordingController *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  _objc_msgSend(self->_levelIndicator,sel_setMaxValue_,0x41880000);
  _objc_msgSend(self->_levelIndicator,sel_setWarningValue_,0x41100000);
  _objc_msgSend(self->_levelIndicator,sel_setCriticalValue_,0x41700000);
  _objc_msgSend(self->_viewContainer,sel_addSubview_positioned_relativeTo_,
                self->_recordedAudioTimeView,0xffffffff,self->_playbackMatrix);
  pvVar3 = self->_viewContainer;
  pvVar1 = _objc_msgSend(cls_NSImage,sel_alloc);
  self_00 = cls_NSBundle;
  pvVar2 = _objc_msgSend(self,sel_class);
  pvVar2 = _objc_msgSend(self_00,sel_bundleForClass_,pvVar2);
  pvVar2 = _objc_msgSend(pvVar2,sel_pathForResource_ofType_,&cfstr_Countdown,&cfstr_pdf);
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithContentsOfFile_,pvVar2);
  pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  _objc_msgSend(pvVar3,sel_setImage_,pvVar1);
  pvVar3 = _objc_msgSend(cls_HSPlaybackControlImagesProvider,
                         sel_sharedPlaybackControlsImagesProvider);
  pvVar3 = _objc_msgSend(pvVar3,sel_playbackImageOfType_state_size_tint_,&cfstr_Play,&cfstr_N,
                         &cfstr_L,&cfstr_A);
  pvVar3 = _objc_msgSend(pvVar3,sel_retain);
  self->_playImage = pvVar3;
  pvVar3 = _objc_msgSend(cls_HSPlaybackControlImagesProvider,
                         sel_sharedPlaybackControlsImagesProvider);
  pvVar3 = _objc_msgSend(pvVar3,sel_playbackImageOfType_state_size_tint_,&cfstr_Stop,&cfstr_N,
                         &cfstr_L,&cfstr_A);
  pvVar3 = _objc_msgSend(pvVar3,sel_retain);
  self->_stopImage = pvVar3;
  pvVar3 = _objc_msgSend(cls_HSPlaybackControlImagesProvider,
                         sel_sharedPlaybackControlsImagesProvider);
  pvVar3 = _objc_msgSend(pvVar3,sel_playbackImageOfType_state_size_tint_,&cfstr_Play,&cfstr_P,
                         &cfstr_L,&cfstr_A);
  pvVar3 = _objc_msgSend(pvVar3,sel_retain);
  self->_playPressedImageAqua = pvVar3;
  pvVar3 = _objc_msgSend(cls_HSPlaybackControlImagesProvider,
                         sel_sharedPlaybackControlsImagesProvider);
  pvVar3 = _objc_msgSend(pvVar3,sel_playbackImageOfType_state_size_tint_,&cfstr_Stop,&cfstr_P,
                         &cfstr_L,&cfstr_A);
  pvVar3 = _objc_msgSend(pvVar3,sel_retain);
  self->_stopPressedImageAqua = pvVar3;
  pvVar3 = _objc_msgSend(cls_HSPlaybackControlImagesProvider,
                         sel_sharedPlaybackControlsImagesProvider);
  pvVar3 = _objc_msgSend(pvVar3,sel_playbackImageOfType_state_size_tint_,&cfstr_Play,&cfstr_P,
                         &cfstr_L,&cfstr_G);
  pvVar3 = _objc_msgSend(pvVar3,sel_retain);
  self->_playPressedImageGraphite = pvVar3;
  pvVar3 = _objc_msgSend(cls_HSPlaybackControlImagesProvider,
                         sel_sharedPlaybackControlsImagesProvider);
  pvVar3 = _objc_msgSend(pvVar3,sel_playbackImageOfType_state_size_tint_,&cfstr_Stop,&cfstr_P,
                         &cfstr_L,&cfstr_G);
  pvVar3 = _objc_msgSend(pvVar3,sel_retain);
  self->_stopPressedImageGraphite = pvVar3;
  pvVar3 = _objc_msgSend(cls_HSPlaybackControlImagesProvider,
                         sel_sharedPlaybackControlsImagesProvider);
  pvVar3 = _objc_msgSend(pvVar3,sel_playbackImageOfType_state_size_tint_,&cfstr_Record,&cfstr_N,
                         &cfstr_L,&cfstr_A);
  pvVar3 = _objc_msgSend(pvVar3,sel_retain);
  self->_recordImage = pvVar3;
  pvVar3 = _objc_msgSend(cls_HSPlaybackControlImagesProvider,
                         sel_sharedPlaybackControlsImagesProvider);
  pvVar3 = _objc_msgSend(pvVar3,sel_playbackImageOfType_state_size_tint_,&cfstr_Record,&cfstr_P,
                         &cfstr_L,&cfstr_A);
  pvVar3 = _objc_msgSend(pvVar3,sel_retain);
  self->_recordPressedImageAqua = pvVar3;
  pvVar3 = _objc_msgSend(cls_HSPlaybackControlImagesProvider,
                         sel_sharedPlaybackControlsImagesProvider);
  pvVar3 = _objc_msgSend(pvVar3,sel_playbackImageOfType_state_size_tint_,&cfstr_Record,&cfstr_P,
                         &cfstr_L,&cfstr_G);
  pvVar3 = _objc_msgSend(pvVar3,sel_retain);
  self->_recordPressedImageGraphite = pvVar3;
  pvVar3 = _objc_msgSend(cls_HSPlaybackControlImagesProvider,
                         sel_sharedPlaybackControlsImagesProvider);
  pvVar3 = _objc_msgSend(pvVar3,sel_playbackImageOfType_state_size_tint_,&cfstr_RecordOn,&cfstr_N,
                         &cfstr_L,&cfstr_A);
  pvVar3 = _objc_msgSend(pvVar3,sel_retain);
  self->_onRecordImage = pvVar3;
  pvVar3 = _objc_msgSend(cls_HSPlaybackControlImagesProvider,
                         sel_sharedPlaybackControlsImagesProvider);
  pvVar3 = _objc_msgSend(pvVar3,sel_playbackImageOfType_state_size_tint_,&cfstr_RecordOn,&cfstr_P,
                         &cfstr_L,&cfstr_A);
  pvVar3 = _objc_msgSend(pvVar3,sel_retain);
  self->_onRecordPressedImageGraphite = pvVar3;
  pvVar3 = _objc_msgSend(self->_playbackMatrix,sel_cellAtRow_column_,0,1);
  _objc_msgSend(pvVar3,sel_setAquaAlternateImage_,self->_playPressedImageAqua);
  pvVar3 = _objc_msgSend(self->_playbackMatrix,sel_cellAtRow_column_,0,1);
  _objc_msgSend(pvVar3,sel_setGraphiteAlternateImage_,self->_playPressedImageGraphite);
  pvVar3 = _objc_msgSend(self->_playbackMatrix,sel_cellAtRow_column_,0,0);
  _objc_msgSend(pvVar3,sel_setAquaAlternateImage_,self->_recordPressedImageAqua);
  pvVar3 = _objc_msgSend(self->_playbackMatrix,sel_cellAtRow_column_,0,0);
  _objc_msgSend(pvVar3,sel_setGraphiteAlternateImage_,self->_recordPressedImageGraphite);
  _objc_msgSend(self,sel_setPlaybackButtonsDelegate_,self);
  pvVar3 = _objc_msgSend(self,sel_audioCaptureDeviceList);
  pvVar1 = _objc_msgSend(self->_audioCaptureDevicesPopUp,sel_menu);
  _objc_msgSend(pvVar3,sel_attachMenu_,pvVar1);
  _objc_msgSend(self,sel_setSoundDuration_forTextField_,0,0,self->_recordedAudioTimeTextField);
  _objc_msgSend(self,sel_updateUI);
  return;
}

*/
- (void)awakeFromNib
{
    [_levelIndicator setMaxValue:17.0];
    [_levelIndicator setWarningValue:9.0];
    [_levelIndicator setCriticalValue:15.0];
    [_viewContainer addSubview:_recordedAudioTimeView positioned:NSWindowBelow relativeTo:_playbackMatrix];
    [(id)_viewContainer setImage:[[[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"Countdown" ofType:@"pdf"]] autorelease]];
    _playImage = [[[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Play" state:@"N" size:@"L" tint:@"A"] retain];
    _stopImage = [[[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Stop" state:@"N" size:@"L" tint:@"A"] retain];
    _playPressedImageAqua = [[[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Play" state:@"P" size:@"L" tint:@"A"] retain];
    _stopPressedImageAqua = [[[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Stop" state:@"P" size:@"L" tint:@"A"] retain];
    _playPressedImageGraphite = [[[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Play" state:@"P" size:@"L" tint:@"G"] retain];
    _stopPressedImageGraphite = [[[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Stop" state:@"P" size:@"L" tint:@"G"] retain];
    _recordImage = [[[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Record" state:@"N" size:@"L" tint:@"A"] retain];
    _recordPressedImageAqua = [[[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Record" state:@"P" size:@"L" tint:@"A"] retain];
    _recordPressedImageGraphite = [[[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Record" state:@"P" size:@"L" tint:@"G"] retain];
    _onRecordImage = [[[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"RecordOn" state:@"N" size:@"L" tint:@"A"] retain];
    _onRecordPressedImageGraphite = [[[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"RecordOn" state:@"P" size:@"L" tint:@"A"] retain];
    [(HSAppearanceButtonCell *)[_playbackMatrix cellAtRow:0 column:1] setAquaAlternateImage:_playPressedImageAqua];
    [(HSAppearanceButtonCell *)[_playbackMatrix cellAtRow:0 column:1] setGraphiteAlternateImage:_playPressedImageGraphite];
    [(HSAppearanceButtonCell *)[_playbackMatrix cellAtRow:0 column:0] setAquaAlternateImage:_recordPressedImageAqua];
    [(HSAppearanceButtonCell *)[_playbackMatrix cellAtRow:0 column:0] setGraphiteAlternateImage:_recordPressedImageGraphite];
    [self setPlaybackButtonsDelegate:self];
    [[self audioCaptureDeviceList] attachMenu:[_audioCaptureDevicesPopUp menu]];
    [self setSoundDuration:0.0 forTextField:_recordedAudioTimeTextField];
    [self updateUI];
}

- (void)dealloc
{
    [self removeTimerForObservingInputAudioLevel];
    [self removeTimerForMeasurementSoundDuration];
    [self removeSound];
    [self removeSoundFileAtPath:_audioOutputFilePath];
    [_countDownViewController release];
    [_recordedAudioTimeView release];
    [_playbackAudioTimeView release];
    [_playImage release];
    [_stopImage release];
    [_playPressedImageAqua release];
    [_playPressedImageGraphite release];
    [_stopPressedImageAqua release];
    [_stopPressedImageGraphite release];
    [_recordImage release];
    [_recordPressedImageAqua release];
    [_recordPressedImageGraphite release];
    [_onRecordImage release];
    [_onRecordPressedImageGraphite release];
    [_soundRecordingPanel release];
    [_audioFileOutput release];
    [_audioDeviceInput release];
    [_audioCaptureSession release];
    [_audioCaptureDeviceList release];
    [_audioOutputFilePath release];
    [super dealloc];
}

@end

