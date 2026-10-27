#import "HSMovieRecordingAssistantPane.h"

@implementation HSMovieRecordingAssistantPane

/* i386 ivar offsets: _levelIndicator=0x78, _movieRecordBackgroundView=0x7c, _movieTimeTextField=0x80, _recordMovieButton=0x84, _playMovieButton=0x88, _recordProgressIndicator=0x8c, _camerasPopUpButton=0x90, _audioCaptureDevicesPopUp=0x94, _movieNameTextField=0x98, _cameraDescriptionTextField=0x9c, _nameDescriptionTextField=0xa0, _captureVideoDeviceList=0xa4, _captureAudioDeviceList=0xa8, _captureVideoDevice=0xac, _captureAudioDevice=0xb0, _captureAudioInput=0xb4, _captureMovieFileOutput=0xb8, _soundCaptureOutput=0xbc, _captureDeviceSession=0xc0, _captureDeviceSessionError=0xc4, _liveVideoForPreview=0xc8, _timerForMeasurementTime=0xcc, _timerForObservingInputAudioLevel=0xd0, _recordedMovieFilePath=0xd4, _previewMovieObject=0xd8, _recordedMovieMedia=0xdc, _windowLevel=0xe0, _navigationPaneSwitcher=0xe4, _previousToolTag=0xe8, _previousSelectedNodes=0xec, _countDownViewController=0xf0, _movieRecordingPaneDelegate=0xf4, _countDownVisible=0xf8, _isRecording=0xf8, _didCaptureMovieFileOutputStartRecording=0xf8, _didCaptureMovieFileOutputFinishRecording=0xf8, _supportSettingsOnTheSpotMode=0xf8 */

+ (id)recordButtonGraphiteImage
{
    return [[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Record" state:@"P" size:@"L" tint:@"G"];
}

+ (id)recordButtonAquaImage
{
    return [[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Record" state:@"P" size:@"L" tint:@"A"];
}

+ (id)recordButtonImage
{
    return [[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Record" state:@"N" size:@"L" tint:@"A"];
}

+ (id)stopButtonGraphiteImage
{
    return [[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Stop" state:@"P" size:@"L" tint:@"G"];
}

+ (id)stopButtonAquaImage
{
    return [[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Stop" state:@"P" size:@"L" tint:@"A"];
}

+ (id)stopButtonImage
{
    return [[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Stop" state:@"N" size:@"L" tint:@"A"];
}

+ (id)playButtonGraphiteImage
{
    return [[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Play" state:@"P" size:@"L" tint:@"G"];
}

+ (id)playButtonAquaImage
{
    return [[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Play" state:@"P" size:@"L" tint:@"A"];
}

+ (id)playButtonImage
{
    return [[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Play" state:@"N" size:@"L" tint:@"A"];
}

- (void)removeMovieCaptureOutput
{
    if (_captureMovieFileOutput != nil) {
        [[_captureDeviceSession captureSession] removeOutput:_captureMovieFileOutput];
        [_captureMovieFileOutput setDelegate:0];
        [_captureMovieFileOutput release];
        _captureMovieFileOutput = nil;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00216b1c @ 00216b1c, 502 bytes * /

void FUN_00216b1c(HSMovieRecordingAssistantPane *self,SEL _cmd)

{
  undefined4 uVar1;
  undefined4 uVar2;
  id pvVar3;
  id pvVar4;
  id self_00;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  cfstringStruct *pcVar8;
  id pvVar9;
  
  if (self->_captureMovieFileOutput == (id)0x0) {
    pvVar3 = _objc_msgSend(cls_QTCaptureMovieFileOutput,sel_alloc);
    pvVar3 = _objc_msgSend(pvVar3,sel_init);
    self->_captureMovieFileOutput = pvVar3;
    if (pvVar3 != (id)0x0) {
      _objc_msgSend(pvVar3,sel_setDelegate_,self);
      pvVar4 = _objc_msgSend(self->_captureDeviceSession,sel_captureSession);
      pvVar3 = self->_captureMovieFileOutput;
      pvVar9 = (id)0x0;
      pvVar4 = _objc_msgSend(pvVar4,sel_addOutput_error_,pvVar3,0);
      if ((char)pvVar4 != '\0') {
        pvVar3 = _objc_msgSend(self->_captureMovieFileOutput,sel_connections,pvVar3,pvVar9);
        pvVar4 = _objc_msgSend(pvVar3,sel_count);
        if (pvVar4 != (id)0x0) {
          uVar1 = *(undefined4 *)PTR_00336404;
          uVar2 = *(undefined4 *)PTR_0033615c;
          pvVar7 = (id)0x0;
          do {
            self_00 = _objc_msgSend(pvVar3,sel_objectAtIndex_,pvVar7,pvVar9);
            pvVar5 = _objc_msgSend(self_00,sel_mediaType);
            pvVar6 = _objc_msgSend(pvVar5,sel_isEqualToString_,uVar2);
            if ((char)pvVar6 == '\0') {
              pvVar5 = _objc_msgSend(pvVar5,sel_isEqualToString_,uVar1);
              if ((char)pvVar5 != '\0') {
                pcVar8 = &cfstr_QTCompressionOptionsHighQualityAACAudio;
                goto LAB_00216ccb;
              }
            }
            else {
              pcVar8 = &cfstr_QTCompressionOptionsSD480SizeH264Video;
LAB_00216ccb:
              pvVar5 = _objc_msgSend(cls_QTCompressionOptions,sel_compressionOptionsWithIdentifier_,
                                     pcVar8);
              if (pvVar5 != (id)0x0) {
                _objc_msgSend(self->_captureMovieFileOutput,sel_setCompressionOptions_forConnection_
                              ,pvVar5,self_00);
                pvVar9 = self_00;
              }
            }
            pvVar7 = (id)((int)pvVar7 + 1);
          } while (pvVar7 < pvVar4);
        }
      }
    }
  }
  return;
}

*/
- (void)installMovieCaptureOutput
{
    if (_captureMovieFileOutput != nil) {
        return;
    }
    _captureMovieFileOutput = [[QTCaptureMovieFileOutput alloc] init];
    if (_captureMovieFileOutput == nil) {
        return;
    }
    [_captureMovieFileOutput setDelegate:self];
    if (![[_captureDeviceSession captureSession] addOutput:_captureMovieFileOutput error:NULL]) {
        return;
    }
    NSArray *connections = [_captureMovieFileOutput connections];
    NSUInteger count = [connections count];
    for (NSUInteger i = 0; i < count; i++) {
        QTCaptureConnection *connection = [connections objectAtIndex:i];
        NSString *mediaType = [connection mediaType];
        NSString *identifier = nil;
        if ([mediaType isEqualToString:QTMediaTypeVideo]) {
            identifier = @"QTCompressionOptionsSD480SizeH264Video";
        } else if ([mediaType isEqualToString:QTMediaTypeSound]) {
            identifier = @"QTCompressionOptionsHighQualityAACAudio";
        }
        if (identifier != nil) {
            QTCompressionOptions *options = [QTCompressionOptions compressionOptionsWithIdentifier:identifier];
            if (options != nil) {
                [_captureMovieFileOutput setCompressionOptions:options forConnection:connection];
            }
        }
    }
}

- (void)removeSoundCaptureOutput
{
    if (_soundCaptureOutput != nil) {
        [[_captureDeviceSession captureSession] removeOutput:_soundCaptureOutput];
        [_soundCaptureOutput release];
        _soundCaptureOutput = nil;
    }
}

- (void)installSoundCaptureOutput
{
    id pvVar1_2;

    if (_soundCaptureOutput == nil) {
        pvVar1_2 = [[QTCaptureAudioPreviewOutput alloc] init];
        _soundCaptureOutput = pvVar1_2;
        if (pvVar1_2 != nil) {
            [[_captureDeviceSession captureSession] addOutput:_soundCaptureOutput error:nil];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00216e1a @ 00216e1a, 615 bytes * /

void FUN_00216e1a(HSMovieRecordingAssistantPane *self,SEL _cmd,id updateIndicatorState)

{
  undefined4 uVar1;
  undefined4 uVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id self_00;
  id pvVar7;
  id pvVar8;
  longdouble lVar9;
  double dVar10;
  ulonglong in_stack_ffffffac;
  undefined4 uVar11;
  id *local_4c;
  uint local_38;
  float local_28;
  
  if (self->_captureAudioInput == (id)0x0) {
    return;
  }
  pvVar3 = _objc_msgSend(self->_captureAudioInput,sel_connections);
  pvVar4 = _objc_msgSend(pvVar3,sel_count);
  if (pvVar4 == (id)0x0) {
    pvVar3 = self->_levelIndicator;
  }
  else {
    uVar1 = *(undefined4 *)PTR_00336404;
    local_28 = 0.0;
    local_38 = 0;
    uVar2 = *(undefined4 *)PTR_003363fc;
    pvVar8 = (id)0x0;
    do {
      uVar11 = (undefined4)(in_stack_ffffffac >> 0x20);
      pvVar5 = _objc_msgSend(pvVar3,sel_objectAtIndex_,pvVar8);
      pvVar6 = _objc_msgSend(pvVar5,sel_mediaType);
      in_stack_ffffffac = CONCAT44(uVar11,uVar1);
      pvVar6 = _objc_msgSend(pvVar6,sel_isEqualToString_,uVar1);
      if ((char)pvVar6 != '\0') {
        in_stack_ffffffac = CONCAT44((int)(in_stack_ffffffac >> 0x20),uVar2);
        pvVar5 = _objc_msgSend(pvVar5,sel_attributeForKey_,uVar2);
        pvVar6 = _objc_msgSend(pvVar5,sel_count);
        if (pvVar6 != (id)0x0) {
          if (pvVar6 < (id)0x2) {
            pvVar6 = (id)0x1;
          }
          pvVar7 = (id)0x0;
          do {
            in_stack_ffffffac = CONCAT44((int)(in_stack_ffffffac >> 0x20),pvVar7);
            self_00 = _objc_msgSend(pvVar5,sel_objectAtIndex_,pvVar7);
            dVar10 = _objc_msgSend_fpret(self_00,sel_floatValue);
            pvVar7 = (id)((int)pvVar7 + 1);
            local_28 = local_28 + (float)dVar10;
          } while (pvVar6 != pvVar7);
          local_38 = local_38 + (int)pvVar6;
        }
      }
      pvVar8 = (id)((int)pvVar8 + 1);
    } while (pvVar8 < pvVar4);
    pvVar3 = self->_levelIndicator;
    if (local_38 != 0) {
      dVar10 = (double)(local_28 /
                       (float)((double)((ulonglong)local_38 | 0x4330000000000000) -
                              4503599627370496.0)) * 0.05;
      lVar9 = (longdouble)_pow(0x4024000000000000,dVar10);
      in_stack_ffffffac = CONCAT44((int)((ulonglong)dVar10 >> 0x20),(float)((double)lVar9 * 10.0));
      goto LAB_00216ff8;
    }
  }
  local_4c = &self->_levelIndicator;
  dVar10 = _objc_msgSend_fpret(pvVar3,sel_value);
  if ((float)dVar10 == 0.0) {
    return;
  }
  pvVar3 = *local_4c;
  in_stack_ffffffac = in_stack_ffffffac & 0xffffffff00000000;
LAB_00216ff8:
  _objc_msgSend(pvVar3,sel_setValue_,in_stack_ffffffac);
  return;
}

*/
- (void)updateIndicatorState:(id)aState
{
    if (_captureAudioInput == nil) {
        return;
    }
    NSArray *connections = [_captureAudioInput connections];
    NSUInteger count = [connections count];
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
        [_levelIndicator setValue:(float)(pow(10.0, (double)(totalLevel / (float)levelCount) * 0.05) * 10.0)];
    } else if ((float)[_levelIndicator value] != 0.0f) {
        [_levelIndicator setValue:0.0];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00217081 @ 00217081, 381 bytes * /

void FUN_00217081(HSMovieRecordingAssistantPane *self,SEL _cmd)

{
  undefined *puVar1;
  undefined *self_00;
  id pvVar2;
  
  _objc_msgSend(self,sel_removeTimerForObservingInputAudioLevel);
  self_00 = cls_NSTimer;
  puVar1 = sel_updateIndicatorState_;
  pvVar2 = _objc_msgSend(self,sel_NSE_newWeakProxy);
  pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
  pvVar2 = _objc_msgSend(self_00,sel_timerWithTimeInterval_target_selector_userInfo_repeats_,
                         0x47ae147b,0x3f947ae1,pvVar2,puVar1,0,1);
  pvVar2 = _objc_msgSend(pvVar2,sel_retain);
  self->_timerForObservingInputAudioLevel = pvVar2;
  pvVar2 = _objc_msgSend(cls_NSRunLoop,sel_currentRunLoop);
  _objc_msgSend(pvVar2,sel_addTimer_forMode_,self->_timerForObservingInputAudioLevel,
                *(undefined4 *)PTR_003361b4);
  pvVar2 = _objc_msgSend(cls_NSRunLoop,sel_currentRunLoop);
  _objc_msgSend(pvVar2,sel_addTimer_forMode_,self->_timerForObservingInputAudioLevel,
                *(undefined4 *)PTR_00336064);
  pvVar2 = _objc_msgSend(cls_NSRunLoop,sel_currentRunLoop);
  _objc_msgSend(pvVar2,sel_addTimer_forMode_,self->_timerForObservingInputAudioLevel,
                *(undefined4 *)PTR_003363f8);
  return;
}

*/
- (void)installTimerForObservingInputAudioLevel
{
    [self removeTimerForObservingInputAudioLevel];
    _timerForObservingInputAudioLevel = [[NSTimer timerWithTimeInterval:0.02 target:[[self NSE_newWeakProxy] autorelease] selector:@selector(updateIndicatorState:) userInfo:nil repeats:YES] retain];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:_timerForObservingInputAudioLevel forMode:NSDefaultRunLoopMode];
    [runLoop addTimer:_timerForObservingInputAudioLevel forMode:NSEventTrackingRunLoopMode];
    [runLoop addTimer:_timerForObservingInputAudioLevel forMode:NSModalPanelRunLoopMode];
}

- (void)removeTimerForObservingInputAudioLevel
{
    if (_timerForObservingInputAudioLevel != nil) {
        [_timerForObservingInputAudioLevel invalidate];
        [_timerForObservingInputAudioLevel release];
        _timerForObservingInputAudioLevel = nil;
    }
}

- (void)destroyCaptureDeviceSession
{
    [self removeTimerForObservingInputAudioLevel];
    if (![[_captureDeviceSession captureSession] isRunning]) {
        [self HSMovieRecordingAssistantPane_releaseAudio];
        if (_captureDeviceSession == nil) {
            return;
        }
    }
    else {
        [_captureDeviceSession deactivate];
        [self HSMovieRecordingAssistantPane_releaseAudio];
    }
    [self HSMovieRecordingAssistantPane_releaseCaptureDeviceSession];
}

- (void)activateCaptureDeviceSession
{
    if (![[[self captureDeviceSession] captureSession] isRunning]) {
        [[self captureDeviceSession] activate];
        [self installTimerForObservingInputAudioLevel];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00217397 @ 00217397, 399 bytes * /

id FUN_00217397(HSMovieRecordingAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  undefined *puVar5;
  cfstringStruct *pcVar6;
  
  if ((self->_captureDeviceSession == (id)0x0) &&
     (pvVar3 = self->_captureVideoDevice, pvVar3 != (id)0x0)) {
    pvVar1 = _objc_msgSend(cls_HSCaptureDeviceSession,sel_captureDeviceSessionForDevice_,pvVar3);
    pvVar1 = _objc_msgSend(pvVar1,sel_retain);
    self->_captureDeviceSession = pvVar1;
    if (pvVar1 != (id)0x0) {
      pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter,pvVar3);
      pvVar3 = self->_captureDeviceSession;
      pcVar6 = &cfstr_HSCaptureDeviceSessionRuntimeErrorNotification;
      puVar5 = sel_HSMovieRecordingAssistantPane_captureDeviceSessionRuntimeErrorNotification_;
      _objc_msgSend(pvVar1,sel_addObserver_selector_name_object_,self,
                    sel_HSMovieRecordingAssistantPane_captureDeviceSessionRuntimeErrorNotification_,
                    &cfstr_HSCaptureDeviceSessionRuntimeErrorNotification,pvVar3);
      pvVar1 = _objc_msgSend(self->_captureDeviceSession,sel_captureSession);
      if (pvVar1 != (id)0x0) {
        pvVar4 = (id)0x0;
        pvVar2 = _objc_msgSend(self->_captureAudioDevice,sel_open_,0,puVar5,pcVar6,pvVar3);
        if ((char)pvVar2 != '\0') {
          pvVar4 = self->_captureAudioDevice;
          pvVar2 = _objc_msgSend(cls_QTCaptureDeviceInput,sel_deviceInputWithDevice_,pvVar4,puVar5,
                                 pcVar6,pvVar3);
          pvVar2 = _objc_msgSend(pvVar2,sel_retain);
          self->_captureAudioInput = pvVar2;
          if (pvVar2 != (id)0x0) {
            puVar5 = (undefined *)0x0;
            _objc_msgSend(pvVar1,sel_addInput_error_,pvVar2,0);
            pvVar4 = pvVar2;
          }
        }
        _objc_msgSend(self,sel_installSoundCaptureOutput,pvVar4,puVar5,pcVar6,pvVar3);
      }
    }
  }
  return self->_captureDeviceSession;
}

*/
- (id)captureDeviceSession
{
    if (_captureDeviceSession == nil && _captureVideoDevice != nil) {
        _captureDeviceSession = [[HSCaptureDeviceSession captureDeviceSessionForDevice:_captureVideoDevice] retain];
        if (_captureDeviceSession != nil) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSMovieRecordingAssistantPane_captureDeviceSessionRuntimeErrorNotification:) name:@"HSCaptureDeviceSessionRuntimeErrorNotification" object:_captureDeviceSession];
            QTCaptureSession *session = [_captureDeviceSession captureSession];
            if (session != nil) {
                /* Add the microphone to the camera's session. */
                if ([_captureAudioDevice open:NULL]) {
                    _captureAudioInput = [[QTCaptureDeviceInput deviceInputWithDevice:_captureAudioDevice] retain];
                    if (_captureAudioInput != nil) {
                        [session addInput:_captureAudioInput error:NULL];
                    }
                }
                [self installSoundCaptureOutput];
            }
        }
    }
    return _captureDeviceSession;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00217526 @ 00217526, 279 bytes * /

void FUN_00217526(HSMovieRecordingAssistantPane *self,SEL _cmd,
                 id HSMovieRecordingAssistantPane_informAboutRecordError)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,&cfstr_OK,&cfstr_empty,
                         &cfstr_Alerts);
  pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                         &cfstr_Your_hard_disk_may_not_have_enough_room_or_may_h,&cfstr_empty,
                         &cfstr_Alerts);
  pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_Cannot_record_video,
                         &cfstr_empty,&cfstr_Alerts);
  _NSRunCriticalAlertPanel(pvVar3,pvVar2,pvVar1,0,0);
  return;
}

*/
- (void)HSMovieRecordingAssistantPane_informAboutRecordError:(id)aError
{
    NSString *ok = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"OK" value:@"" table:@"Alerts"];
    NSString *message = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Your hard disk may not have enough room or may have some other problem. Free some disk space or reopen the Record Video dialog and try again." value:@"" table:@"Alerts"];
    NSString *title = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Cannot record video" value:@"" table:@"Alerts"];
    NSRunCriticalAlertPanel(title, @"%@", ok, nil, nil, message);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0021763d @ 0021763d, 155 bytes * /

void FUN_0021763d(HSMovieRecordingAssistantPane *self,SEL _cmd,id observeValueForKeyPath,id ofObject
                 ,id change,void *context)

{
  id pvVar1;
  
  if ((self->_captureVideoDevice == ofObject) || (self->_captureAudioDevice == ofObject)) {
    pvVar1 = _objc_msgSend(observeValueForKeyPath,sel_isEqualToString_,
                           &cfstr_inUseByAnotherApplication);
    if (((char)pvVar1 == '\0') &&
       (pvVar1 = _objc_msgSend(observeValueForKeyPath,sel_isEqualToString_,&cfstr_suspended),
       (char)pvVar1 == '\0')) {
      return;
    }
    _objc_msgSend(self,sel_performSelectorOnMainThread_withObject_waitUntilDone_,
                  sel_HSMovieRecordingAssistantPane_captureDeviceDidChangeState_,ofObject,0);
  }
  return;
}

*/
- (void)observeValueForKeyPath:(id)aPath ofObject:(id)aObject change:(id)aChange context:(void *)aContext
{
    if (_captureVideoDevice != aObject && _captureAudioDevice != aObject) {
        return;
    }
    if ([aPath isEqualToString:@"inUseByAnotherApplication"] || [aPath isEqualToString:@"suspended"]) {
        [self performSelectorOnMainThread:@selector(HSMovieRecordingAssistantPane_captureDeviceDidChangeState:) withObject:aObject waitUntilDone:NO];
    }
}

- (void)HSMovieRecordingAssistantPane_captureDeviceDidChangeState:(id)aState
{
    if ((_captureVideoDevice == aState) || (_captureAudioDevice == aState)) {
        [self validateUserInterface];
    }
}

- (void)deviceControllerDidChangeAudioDeviceList:(id)aList
{
    [self HSMovieRecordingAssistantPane_audioPopUpButtonDidUpdate];
    [self validateUserInterface];
}

- (void)deviceControllerDidChangeVideoDeviceList:(id)aList
{
    [self HSMovieRecordingAssistantPane_camerasPopUpButtonDidUpdate];
    [self validateUserInterface];
}

- (id)nibNameForCountDownViewController:(id)aController
{
    return @"AssistantCountDownView";
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00217789 @ 00217789, 320 bytes * /

void FUN_00217789(HSMovieRecordingAssistantPane *self,SEL _cmd,id countDownDidEnd)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  
  if (self->_captureVideoDevice == (id)0x0) {
    return;
  }
  pvVar2 = self->_recordedMovieFilePath;
  if ((pvVar2 != (id)0x0) &&
     (pvVar1 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_,pvVar2), pvVar1 != (id)0x0)) {
    pvVar2 = _objc_msgSend(self->_captureDeviceSession,sel_captureSession,pvVar2);
    pvVar2 = _objc_msgSend(pvVar2,sel_isRunning);
    if ((char)pvVar2 != '\0') {
      self->_countDownVisible[0] = self->_countDownVisible[0] & 0xf3;
      _objc_msgSend(self->_captureMovieFileOutput,sel_recordToOutputFileURL_,pvVar1);
      pvVar2 = (id)0x0;
      _objc_msgSend(self,sel_setDuration_forTextField_,0,0,self->_movieTimeTextField);
      op = sel_installTimerForMeasurementDuration;
      goto LAB_00217883;
    }
  }
  _objc_msgSend(self,sel_stopRecording);
  pvVar2 = self->_captureDeviceSessionError;
  op = sel_HSMovieRecordingAssistantPane_informAboutRecordError_;
LAB_00217883:
  _objc_msgSend(self,op,pvVar2);
  _objc_msgSend(self->_captureDeviceSessionError,sel_release);
  self->_captureDeviceSessionError = (id)0x0;
  _objc_msgSend(self,sel_validateUserInterface);
  return;
}

*/
- (void)countDownDidEnd:(id)aEnd
{
    if (_captureVideoDevice == nil) {
        return;
    }
    NSURL *url = _recordedMovieFilePath != nil ? [NSURL fileURLWithPath:_recordedMovieFilePath] : nil;
    if (url != nil && [[_captureDeviceSession captureSession] isRunning]) {
        _didCaptureMovieFileOutputStartRecording = 0;
        _didCaptureMovieFileOutputFinishRecording = 0;
        [_captureMovieFileOutput recordToOutputFileURL:url];
        [self setDuration:0.0 forTextField:_movieTimeTextField];
        [self installTimerForMeasurementDuration];
    } else {
        [self stopRecording];
        [self HSMovieRecordingAssistantPane_informAboutRecordError:_captureDeviceSessionError];
    }
    [_captureDeviceSessionError release];
    _captureDeviceSessionError = nil;
    [self validateUserInterface];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002178c9 @ 002178c9, 127 bytes * /

double FUN_002178c9(HSMovieRecordingAssistantPane *self,SEL _cmd,id durationForTextField)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar1 = _objc_msgSend(durationForTextField,sel_objectValue);
  pvVar2 = _objc_msgSend(pvVar1,sel_hourOfDay);
  pvVar3 = _objc_msgSend(pvVar1,sel_minuteOfHour);
  pvVar1 = _objc_msgSend(pvVar1,sel_secondOfMinute);
  return (double)((int)pvVar1 + (int)pvVar3 * 0x3c + (int)pvVar2 * 0xe10);
}

*/
- (double)durationForTextField:(id)aField
{
    id date = [aField objectValue];
    return (double)([date secondOfMinute] + [date minuteOfHour] * 60 + [date hourOfDay] * 3600);
}

- (void)setDuration:(double)aDuration forTextField:(id)aField
{
    unsigned int uVar2;

    uVar2 = (int)aDuration;
    if (2147483648.0 <= aDuration) {
        uVar2 = (int)(aDuration - 2147483648.0) ^ 0x80000000;
    }
    [aField setObjectValue:[NSCalendarDate dateWithYear:0 month:0 day:0 hour:0 minute:0 second:uVar2 timeZone:nil]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002179e9 @ 002179e9, 389 bytes * /

void FUN_002179e9(HSMovieRecordingAssistantPane *self,SEL _cmd,id updateDuration)

{
  id pvVar1;
  HSMovieRecordingAssistantPane *pHVar2;
  double dVar3;
  SEL op;
  undefined4 uVar4;
  
  pvVar1 = _objc_msgSend(self,sel_isRecording);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(self,sel_isPlaying);
    if ((char)pvVar1 == '\0') {
      return;
    }
    pvVar1 = self->_movieTimeTextField;
    dVar3 = _objc_msgSend_fpret(self,sel_durationForTextField_,pvVar1);
  }
  else {
    if (self->_captureDeviceSessionError != (id)0x0) {
      pHVar2 = _objc_msgSend(self->_captureDeviceSessionError,sel_retain);
      _objc_msgSend(self,sel_cleanPreviousRecorderMovieWithPath_,self->_recordedMovieFilePath);
      _objc_msgSend(self->_recordedMovieFilePath,sel_release);
      self->_recordedMovieFilePath = (id)0x0;
      _objc_msgSend(self,sel_stopRecording);
      pvVar1 = self->_movieTimeTextField;
      uVar4 = 0;
      _objc_msgSend(self,sel_setDuration_forTextField_,0,0,pvVar1);
      dVar3 = (double)CONCAT44(uVar4,pHVar2);
      _objc_msgSend(self,sel_HSMovieRecordingAssistantPane_informAboutRecordError_,pHVar2);
      self = pHVar2;
      op = sel_release;
      goto LAB_00217b1b;
    }
    pvVar1 = self->_movieTimeTextField;
    dVar3 = _objc_msgSend_fpret(self,sel_durationForTextField_,pvVar1);
  }
  dVar3 = dVar3 + 1.0;
  op = sel_setDuration_forTextField_;
LAB_00217b1b:
  _objc_msgSend(self,op,dVar3,pvVar1);
  return;
}

*/
- (void)updateDuration:(id)aDuration
{
    if ([self isRecording]) {
        if (_captureDeviceSessionError != nil) {
            /* The capture session failed while recording. */
            NSError *error = [_captureDeviceSessionError retain];
            [self cleanPreviousRecorderMovieWithPath:_recordedMovieFilePath];
            [_recordedMovieFilePath release];
            _recordedMovieFilePath = nil;
            [self stopRecording];
            [self setDuration:0.0 forTextField:_movieTimeTextField];
            [self HSMovieRecordingAssistantPane_informAboutRecordError:error];
            [error release];
            return;
        }
    } else if (![self isPlaying]) {
        return;
    }
    [self setDuration:[self durationForTextField:_movieTimeTextField] + 1.0 forTextField:_movieTimeTextField];
}

- (void)removeTimerForMeasurementDuration
{
    if (_timerForMeasurementTime != nil) {
        [_timerForMeasurementTime invalidate];
        [_timerForMeasurementTime release];
        _timerForMeasurementTime = nil;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00217bc4 @ 00217bc4, 335 bytes * /

void FUN_00217bc4(HSMovieRecordingAssistantPane *self,SEL _cmd)

{
  undefined *puVar1;
  undefined *self_00;
  id pvVar2;
  
  _objc_msgSend(self,sel_removeTimerForMeasurementDuration);
  self_00 = cls_NSTimer;
  puVar1 = sel_updateDuration_;
  pvVar2 = _objc_msgSend(self,sel_NSE_newWeakProxy);
  pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
  pvVar2 = _objc_msgSend(self_00,
                         sel_scheduledTimerWithTimeInterval_target_selector_userInfo_repeats_,0,
                         0x3ff00000,pvVar2,puVar1,0,1);
  pvVar2 = _objc_msgSend(pvVar2,sel_retain);
  self->_timerForMeasurementTime = pvVar2;
  pvVar2 = _objc_msgSend(cls_NSRunLoop,sel_currentRunLoop);
  _objc_msgSend(pvVar2,sel_addTimer_forMode_,self->_timerForMeasurementTime,
                *(undefined4 *)PTR_003361b4);
  _objc_msgSend(pvVar2,sel_addTimer_forMode_,self->_timerForMeasurementTime,
                *(undefined4 *)PTR_00336064);
  _objc_msgSend(pvVar2,sel_addTimer_forMode_,self->_timerForMeasurementTime,
                *(undefined4 *)PTR_003363f8);
  return;
}

*/
- (void)installTimerForMeasurementDuration
{
    [self removeTimerForMeasurementDuration];
    _timerForMeasurementTime = [[NSTimer scheduledTimerWithTimeInterval:1.0 target:[[self NSE_newWeakProxy] autorelease] selector:@selector(updateDuration:) userInfo:nil repeats:YES] retain];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:_timerForMeasurementTime forMode:NSDefaultRunLoopMode];
    [runLoop addTimer:_timerForMeasurementTime forMode:NSEventTrackingRunLoopMode];
    [runLoop addTimer:_timerForMeasurementTime forMode:NSModalPanelRunLoopMode];
}

- (id)countDownViewController
{
    id pvVar1;
    id pvVar1_2;

    pvVar1 = _countDownViewController;
    if (pvVar1 == nil) {
        pvVar1_2 = [HSCountDownViewController new];
        _countDownViewController = pvVar1_2;
        [pvVar1_2 setDelegate:self];
        pvVar1 = _countDownViewController;
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00217d6f @ 00217d6f, 434 bytes * /

void FUN_00217d6f(HSMovieRecordingAssistantPane *self,SEL _cmd)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  double dVar3;
  undefined4 uVar4;
  
  if (self->_previewMovieObject != (id)0x0) {
    _objc_msgSend(self,sel_disableUndoRegistration);
    _objc_msgSend(self,sel_removeTimerForMeasurementDuration);
    pvVar2 = self->_movieTimeTextField;
    dVar3 = _objc_msgSend_fpret(self->_previewMovieObject,sel_hyperDuration);
    _objc_msgSend(self,sel_setDuration_forTextField_,dVar3,pvVar2);
    _objc_msgSend(self->_previewMovieObject,sel_removeFromHyperParent);
    self_00 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
    pvVar1 = _objc_msgSend(self->_previousSelectedNodes,sel_count);
    if (pvVar1 != (id)0x0) {
      pvVar2 = _objc_msgSend(self_00,sel_currentTool,dVar3,pvVar2);
      uVar4 = (undefined4)((ulonglong)dVar3 >> 0x20);
      pvVar2 = _objc_msgSend(pvVar2,sel_view);
      dVar3 = (double)CONCAT44(uVar4,self->_previousSelectedNodes);
      _objc_msgSend(pvVar2,sel_selectHyperObjects_,self->_previousSelectedNodes);
    }
    _objc_msgSend(self->_previousSelectedNodes,sel_release,dVar3);
    self->_previousSelectedNodes = (id)0x0;
    _objc_msgSend(self_00,sel_selectToolWithTag_setAsPermanent_forceSelection_,
                  self->_previousToolTag,0,1);
    pvVar2 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
    _objc_msgSend(pvVar2,sel_setLocked_delegate_,0,0);
    _objc_msgSend(self,sel_enableUndoRegistration);
  }
  return;
}

*/
- (void)cleanUpAfterPlaying
{
    if (_previewMovieObject == nil) {
        return;
    }
    [self disableUndoRegistration];
    [self removeTimerForMeasurementDuration];
    [self setDuration:[_previewMovieObject hyperDuration] forTextField:_movieTimeTextField];
    [_previewMovieObject removeFromHyperParent];
    HSToolManager *toolManager = [HSToolManager sharedToolManager];
    if ([_previousSelectedNodes count] != 0) {
        [[[toolManager currentTool] view] selectHyperObjects:_previousSelectedNodes];
    }
    [_previousSelectedNodes release];
    _previousSelectedNodes = nil;
    [toolManager selectToolWithTag:_previousToolTag setAsPermanent:NO forceSelection:YES];
    [[HSObjectAssistantController sharedAssistantController] setLocked:NO delegate:nil];
    [self enableUndoRegistration];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00217f21 @ 00217f21, 513 bytes * /

BOOL FUN_00217f21(HSMovieRecordingAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar1 = _objc_msgSend(self,sel_previewMovieObject);
  if (pvVar1 != (id)0x0) {
    _objc_msgSend(self,sel_disableUndoRegistration);
    pvVar2 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
    _objc_msgSend(pvVar2,sel_setLocked_delegate_,1,self);
    pvVar2 = _objc_msgSend(self,sel_card);
    _objc_msgSend(pvVar2,sel_addTemporaryHyperChild_,self->_previewMovieObject);
    pvVar2 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
    pvVar3 = _objc_msgSend(pvVar2,sel_selectedToolTag);
    self->_previousToolTag = (int)pvVar3;
    _objc_msgSend(self->_previousSelectedNodes,sel_release);
    pvVar3 = _objc_msgSend(pvVar2,sel_currentTool);
    pvVar3 = _objc_msgSend(pvVar3,sel_view);
    pvVar3 = _objc_msgSend(pvVar3,sel_selection);
    pvVar3 = _objc_msgSend(pvVar3,sel_nodesArray);
    pvVar3 = _objc_msgSend(pvVar3,sel_retain);
    self->_previousSelectedNodes = pvVar3;
    _objc_msgSend(pvVar2,sel_selectToolWithTag_setAsPermanent_,0x43,0);
    pvVar2 = _objc_msgSend(pvVar2,sel_currentTool);
    _objc_msgSend(pvVar2,sel_setCardObject_,self->_previewMovieObject);
    _objc_msgSend(self,sel_setDuration_forTextField_,0,0,self->_movieTimeTextField);
    _objc_msgSend(self,sel_installTimerForMeasurementDuration);
    _objc_msgSend(self,sel_enableUndoRegistration);
  }
  return pvVar1 != (id)0x0;
}

*/
- (BOOL)prepareBeforePlay
{
    if ([self previewMovieObject] == nil) {
        return NO;
    }
    [self disableUndoRegistration];
    [[HSObjectAssistantController sharedAssistantController] setLocked:YES delegate:self];
    [[self card] addTemporaryHyperChild:_previewMovieObject];
    HSToolManager *toolManager = [HSToolManager sharedToolManager];
    _previousToolTag = (int)[toolManager selectedToolTag];
    [_previousSelectedNodes release];
    _previousSelectedNodes = [[[[[toolManager currentTool] view] selection] nodesArray] retain];
    /* Tag 0x43 is the media playing tool. */
    [toolManager selectToolWithTag:0x43 setAsPermanent:NO];
    [[toolManager currentTool] setCardObject:_previewMovieObject];
    [self setDuration:0.0 forTextField:_movieTimeTextField];
    [self installTimerForMeasurementDuration];
    [self enableUndoRegistration];
    return YES;
}

- (void)hyperPlayableObjectDidStop:(id)aStop
{
    if ([aStop queryHyperInterface:@protocol(HSMovieObjectAttributes)] != nil) {
        [self cleanUpAfterPlaying];
    }
    [self validateUserInterface];
}

- (void)stopPlaying
{
    if (_previewMovieObject != nil) {
        [_previewMovieObject hyperStop];
        [self cleanUpAfterPlaying];
    }
}

- (void)startPlaying
{
    if ([self prepareBeforePlay]) {
        [_previewMovieObject hyperStart:self];
    }
}

- (BOOL)isPlaying
{
    BOOL bVar2;

    if (_previewMovieObject == nil) {
        bVar2 = NO;
    }
    else {
        bVar2 = [_previewMovieObject isHyperPlaying];
    }
    return bVar2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00216699 @ 00216699, 15 bytes * /

void FUN_00216699(HSMovieRecordingAssistantPane *self,SEL _cmd,id captureOutput,
                 id didFinishRecordingToOutputFileAtURL,id forConnections,id dueToError)

{
  self->_countDownVisible[0] = self->_countDownVisible[0] | 8;
  return;
}

*/
- (void)captureOutput:(id)aOutput didFinishRecordingToOutputFileAtURL:(id)aURL forConnections:(id)aConnections dueToError:(id)aError
{
    _didCaptureMovieFileOutputFinishRecording = 1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0021668a @ 0021668a, 15 bytes * /

void FUN_0021668a(HSMovieRecordingAssistantPane *self,SEL _cmd,id captureOutput,
                 id didStartRecordingToOutputFileAtURL,id forConnections)

{
  self->_countDownVisible[0] = self->_countDownVisible[0] | 4;
  return;
}

*/
- (void)captureOutput:(id)aOutput didStartRecordingToOutputFileAtURL:(id)aURL forConnections:(id)aConnections
{
    _didCaptureMovieFileOutputStartRecording = 1;
}

- (void)HSMovieRecordingAssistantPane_captureDeviceSessionRuntimeErrorNotification:(id)aNotification
{
    if (_captureDeviceSessionError == nil) {
        _captureDeviceSessionError = [[[aNotification userInfo] objectForKey:@"HSCaptureDeviceSessionErrorKey"] copy];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002182b7 @ 002182b7, 1557 bytes * /

void FUN_002182b7(HSMovieRecordingAssistantPane *self,SEL _cmd)

{
  HSMovieRecordingAssistantPane *pHVar1;
  id pvVar2;
  int iVar3;
  int iVar4;
  id pvVar5;
  double dVar6;
  SEL op;
  ulonglong uVar7;
  undefined4 uVar8;
  undefined4 uVar9;
  int local_6c [22];
  HSMovieRecordingAssistantPane *local_14;
  
  local_14 = self;
  if (self->_captureVideoDevice == (id)0x0) {
    return;
  }
  _objc_msgSend(self,sel_removeTimerForMeasurementDuration);
  pvVar2 = _objc_msgSend(local_14,sel_countDownViewController);
  pvVar2 = _objc_msgSend(pvVar2,sel_isRunning);
  if ((char)pvVar2 == '\0') {
    pvVar2 = _objc_msgSend(local_14->_captureDeviceSession,sel_captureSession);
    pvVar2 = _objc_msgSend(pvVar2,sel_isRunning);
    if ((char)pvVar2 == '\0') goto LAB_0021869b;
    _objc_msgSend(local_14->_recordProgressIndicator,sel_setHidden_,0);
    _objc_msgSend(local_14->_recordProgressIndicator,sel_startAnimation_,0);
    _objc_msgSend(local_14,sel_removeTimerForObservingInputAudioLevel);
    pvVar2 = _objc_msgSend(local_14,sel_liveVideoForPreview);
    _objc_msgSend(pvVar2,sel_hyperStop);
    uVar7 = 0x200000000;
    _objc_msgSend(local_14->_captureMovieFileOutput,sel_recordToOutputFileURL_bufferDestination_,0,2
                 );
    uVar9 = *(undefined4 *)PTR_00336408;
    while (((local_14->_countDownVisible[0] & 4) != 0 && ((local_14->_countDownVisible[0] & 8) == 0)
           )) {
      uVar7 = 0x13fb99999;
      _CFRunLoopRunInMode(uVar9,0x9999999a,0x3fb99999);
    }
    _objc_msgSend(local_14,sel_installTimerForObservingInputAudioLevel,uVar7);
    _objc_exception_try_enter(local_6c);
    iVar3 = __setjmp(local_6c);
    if (iVar3 == 0) {
      if (local_14->_recordedMovieFilePath != (id)0x0) {
        pvVar2 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
        uVar7 = CONCAT44((int)(uVar7 >> 0x20),local_14->_recordedMovieFilePath);
        pvVar2 = _objc_msgSend(pvVar2,sel_fileExistsAtPath_,local_14->_recordedMovieFilePath);
        if ((char)pvVar2 != '\0') {
          pvVar2 = _objc_msgSend(cls_NSFileManager,sel_defaultManager,uVar7);
          uVar9 = 0;
          uVar7 = ZEXT48(local_14->_recordedMovieFilePath);
          pvVar2 = _objc_msgSend(pvVar2,sel_hyperIsReadableFileAtPath_showAlert_error_,
                                 local_14->_recordedMovieFilePath,0,0);
          pHVar1 = local_14;
          if ((char)pvVar2 != '\0') {
            uVar8 = (undefined4)(uVar7 >> 0x20);
            pvVar2 = _objc_msgSend(cls_HSNewMedia,sel_mediaWithPath_,
                                   local_14->_recordedMovieFilePath,uVar8,uVar9);
            uVar7 = CONCAT44(uVar8,pvVar2);
            _objc_msgSend(pHVar1,sel_setRecordedMovieMedia_,pvVar2);
          }
        }
      }
      pvVar5 = _objc_msgSend(local_14,sel_previewMovieObject,uVar7);
      pHVar1 = local_14;
      pvVar2 = local_14->_movieTimeTextField;
      if (pvVar5 == (id)0x0) {
        _objc_msgSend(local_14,sel_setDuration_forTextField_,0,0,pvVar2);
      }
      else {
        dVar6 = _objc_msgSend_fpret(pvVar5,sel_hyperDuration);
        _objc_msgSend(pHVar1,sel_setDuration_forTextField_,dVar6,pvVar2);
      }
    }
    else {
      iVar4 = _objc_exception_extract(local_6c);
      _objc_exception_try_enter(local_6c);
      iVar3 = __setjmp(local_6c);
      if (iVar3 == 0) {
        iVar3 = _objc_exception_match(cls_NSException,iVar4);
        if (iVar3 != 0) goto LAB_0021864a;
        _objc_exception_try_exit(local_6c);
      }
      else {
        iVar4 = _objc_exception_extract(local_6c);
      }
      if (iVar4 != 0) {
                    /* WARNING: Subroutine does not return * /
        _objc_exception_throw(iVar4);
      }
    }
LAB_0021864a:
    _objc_exception_try_exit(local_6c);
    _objc_msgSend(local_14->_recordProgressIndicator,sel_stopAnimation_,0);
    pvVar2 = local_14->_recordProgressIndicator;
    op = sel_setHidden_;
  }
  else {
    pvVar2 = _objc_msgSend(local_14,sel_countDownViewController);
    op = sel_stopRun;
  }
  _objc_msgSend(pvVar2,op);
LAB_0021869b:
  _objc_msgSend(local_14,sel_installSoundCaptureOutput);
  _objc_msgSend(local_14,sel_removeMovieCaptureOutput);
  _objc_msgSend(local_14->_captureDeviceSessionError,sel_release);
  local_14->_captureDeviceSessionError = (id)0x0;
  pvVar2 = _objc_msgSend(local_14,sel_liveVideoForPreview);
  _objc_msgSend(pvVar2,sel_hyperStop);
  _objc_msgSend(pvVar2,sel_removeFromHyperParent);
  pvVar2 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar5 = _objc_msgSend(local_14->_previousSelectedNodes,sel_count);
  if (pvVar5 != (id)0x0) {
    pvVar5 = _objc_msgSend(pvVar2,sel_currentTool);
    pvVar5 = _objc_msgSend(pvVar5,sel_view);
    _objc_msgSend(pvVar5,sel_selectHyperObjects_,local_14->_previousSelectedNodes);
  }
  _objc_msgSend(local_14->_previousSelectedNodes,sel_release);
  local_14->_previousSelectedNodes = (id)0x0;
  _objc_msgSend(pvVar2,sel_selectToolWithTag_setAsPermanent_forceSelection_,
                local_14->_previousToolTag,0,1);
  pvVar2 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
  _objc_msgSend(pvVar2,sel_setLocked_delegate_,0,0);
  _objc_msgSend(local_14,sel_enableUndoRegistration);
  pvVar2 = _objc_msgSend(local_14,sel_stack);
  pvVar2 = _objc_msgSend(pvVar2,sel_undoManager);
  while (pvVar5 = _objc_msgSend(pvVar2,sel_groupingLevel), pvVar5 != (id)0x0) {
    _objc_msgSend(pvVar2,sel_endUndoGrouping);
  }
  local_14->_countDownVisible[0] = local_14->_countDownVisible[0] & 0xfd;
  _objc_msgSend(*(id *)PTR_00336058,sel_stopModalWithCode_,0);
  return;
}

*/
- (void)stopRecording
{
    if (_captureVideoDevice == nil) {
        return;
    }
    [self removeTimerForMeasurementDuration];
    if ([[self countDownViewController] isRunning]) {
        [[self countDownViewController] stopRun];
    } else if ([[_captureDeviceSession captureSession] isRunning]) {
        [_recordProgressIndicator setHidden:NO];
        [_recordProgressIndicator startAnimation:nil];
        [self removeTimerForObservingInputAudioLevel];
        [[self liveVideoForPreview] hyperStop];
        [_captureMovieFileOutput recordToOutputFileURL:nil bufferDestination:QTCaptureFileOutputBufferDestinationOldFile];
        /* Wait for the file to be finished. */
        while (_didCaptureMovieFileOutputStartRecording && !_didCaptureMovieFileOutputFinishRecording) {
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, true);
        }
        [self installTimerForObservingInputAudioLevel];
        @try {
            if (_recordedMovieFilePath != nil && [[NSFileManager defaultManager] fileExistsAtPath:_recordedMovieFilePath] && [[NSFileManager defaultManager] hyperIsReadableFileAtPath:_recordedMovieFilePath showAlert:NO error:NULL]) {
                [self setRecordedMovieMedia:[HSNewMedia mediaWithPath:_recordedMovieFilePath]];
            }
            id movieObject = [self previewMovieObject];
            [self setDuration:movieObject == nil ? 0.0 : [movieObject hyperDuration] forTextField:_movieTimeTextField];
        }
        @catch (NSException *exception) {
        }
        [_recordProgressIndicator stopAnimation:nil];
        [_recordProgressIndicator setHidden:YES];
    }
    [self installSoundCaptureOutput];
    [self removeMovieCaptureOutput];
    [_captureDeviceSessionError release];
    _captureDeviceSessionError = nil;
    id liveVideo = [self liveVideoForPreview];
    [liveVideo hyperStop];
    [liveVideo removeFromHyperParent];
    HSToolManager *toolManager = [HSToolManager sharedToolManager];
    if ([_previousSelectedNodes count] != 0) {
        [[[toolManager currentTool] view] selectHyperObjects:_previousSelectedNodes];
    }
    [_previousSelectedNodes release];
    _previousSelectedNodes = nil;
    [toolManager selectToolWithTag:_previousToolTag setAsPermanent:NO forceSelection:YES];
    [[HSObjectAssistantController sharedAssistantController] setLocked:NO delegate:nil];
    [self enableUndoRegistration];
    /* Close every undo group left open while recording. */
    NSUndoManager *undoManager = [[self stack] undoManager];
    while ([undoManager groupingLevel] != 0) {
        [undoManager endUndoGrouping];
    }
    _isRecording = 0;
    /* Ends runMovieRecordingModalSession. */
    [NSApp stopModalWithCode:0];
}

- (void)HSMovieRecordingAssistantPane_releaseCaptureDeviceSession
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSCaptureDeviceSessionRuntimeErrorNotification" object:_captureDeviceSession];
    [self removeMovieCaptureOutput];
    [self removeSoundCaptureOutput];
    [_captureDeviceSession release];
    _captureDeviceSession = nil;
}

- (void)HSMovieRecordingAssistantPane_releaseAudio
{
    if (_captureAudioInput != nil) {
        [[_captureDeviceSession captureSession] removeInput:_captureAudioInput];
        [_captureAudioInput release];
        _captureAudioInput = nil;
        if ([_captureAudioDevice isOpen]) {
            [_captureAudioDevice close];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00218a20 @ 00218a20, 764 bytes * /

void FUN_00218a20(HSMovieRecordingAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  
  pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  if (self->_captureVideoDevice != (id)0x0) {
    _objc_msgSend(self->_previewMovieObject,sel_release);
    self->_previewMovieObject = (id)0x0;
    if (self->_recordedMovieMedia != (id)0x0) {
      pvVar2 = _objc_msgSend(self->_recordedMovieMedia,sel_fullPathToMediaFile);
      _objc_msgSend(self,sel_cleanPreviousRecorderMovieWithPath_,pvVar2);
      _objc_msgSend(self,sel_setRecordedMovieMedia_,0);
    }
    _objc_msgSend(self->_recordedMovieFilePath,sel_release);
    pvVar2 = _objc_msgSend(self,sel_pathForRecordingWithMovieName);
    pvVar2 = _objc_msgSend(pvVar2,sel_retain);
    self->_recordedMovieFilePath = pvVar2;
    _objc_msgSend(self,sel_installMovieCaptureOutput);
    _objc_msgSend(self,sel_removeSoundCaptureOutput);
    pvVar2 = _objc_msgSend(self,sel_countDownViewController);
    _objc_msgSend(pvVar2,sel_runInView_,self->_movieRecordBackgroundView);
    _objc_msgSend(self,sel_performSelector_withObject_afterDelay_,sel_runMovieRecordingModalSession,
                  0,0,0);
    _objc_msgSend(self,sel_disableUndoRegistration);
    pvVar2 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
    _objc_msgSend(pvVar2,sel_setLocked_delegate_,1,self);
    pvVar2 = _objc_msgSend(pvVar1,sel_selectedToolTag);
    self->_previousToolTag = (int)pvVar2;
    _objc_msgSend(self->_previousSelectedNodes,sel_release);
    pvVar2 = _objc_msgSend(pvVar1,sel_currentTool);
    pvVar2 = _objc_msgSend(pvVar2,sel_view);
    pvVar2 = _objc_msgSend(pvVar2,sel_selection);
    pvVar2 = _objc_msgSend(pvVar2,sel_nodesArray);
    pvVar2 = _objc_msgSend(pvVar2,sel_retain);
    self->_previousSelectedNodes = pvVar2;
    pvVar2 = _objc_msgSend(self,sel_liveVideoForPreview);
    self_00 = _objc_msgSend(self,sel_card);
    _objc_msgSend(self_00,sel_addTemporaryHyperChild_,pvVar2);
    _objc_msgSend(pvVar1,sel_selectToolWithTag_setAsPermanent_,0x43,0);
    pvVar1 = _objc_msgSend(pvVar1,sel_currentTool);
    _objc_msgSend(pvVar1,sel_setCardObject_,pvVar2);
    _objc_msgSend(pvVar2,sel_hyperStart_,self);
    self->_countDownVisible[0] = self->_countDownVisible[0] | 2;
  }
  return;
}

*/
- (void)startRecording
{
    HSToolManager *toolManager = [HSToolManager sharedToolManager];
    if (_captureVideoDevice == nil) {
        return;
    }
    [_previewMovieObject release];
    _previewMovieObject = nil;
    if (_recordedMovieMedia != nil) {
        [self cleanPreviousRecorderMovieWithPath:[_recordedMovieMedia fullPathToMediaFile]];
        [self setRecordedMovieMedia:nil];
    }
    [_recordedMovieFilePath release];
    _recordedMovieFilePath = [[self pathForRecordingWithMovieName] retain];
    [self installMovieCaptureOutput];
    [self removeSoundCaptureOutput];
    [[self countDownViewController] runInView:_movieRecordBackgroundView];
    [self performSelector:@selector(runMovieRecordingModalSession) withObject:nil afterDelay:0.0];
    [self disableUndoRegistration];
    [[HSObjectAssistantController sharedAssistantController] setLocked:YES delegate:self];
    _previousToolTag = (int)[toolManager selectedToolTag];
    [_previousSelectedNodes release];
    _previousSelectedNodes = [[[[[toolManager currentTool] view] selection] nodesArray] retain];
    /* Show the live camera on the card while recording. */
    id liveVideo = [self liveVideoForPreview];
    [[self card] addTemporaryHyperChild:liveVideo];
    [toolManager selectToolWithTag:0x43 setAsPermanent:NO];
    [[toolManager currentTool] setCardObject:liveVideo];
    [liveVideo hyperStart:self];
    _isRecording = 1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00216671 @ 00216671, 25 bytes * /

BOOL FUN_00216671(HSMovieRecordingAssistantPane *self,SEL _cmd)

{
  BOOL BVar1;
  
  BVar1 = -1;
  if ((self->_countDownVisible[0] & 2) == 0) {
    BVar1 = '\0';
  }
  return BVar1;
}

*/
- (BOOL)isRecording
{
    return _isRecording != 0;
}

- (void)setMovieRecordingPaneDelegate:(id)aDelegate
{
    _movieRecordingPaneDelegate = aDelegate;
}

- (id)movieRecordingPaneDelegate
{
    return _movieRecordingPaneDelegate;
}

- (void)audioCaptureDeviceDidChange:(id)aChange
{
    [self HSMovieRecordingAssistantPane_updateCaptureAudioDevice:[[_audioCaptureDevicesPopUp selectedItem] representedObject]];
    [self activateCaptureDeviceSession];
    [self validateUserInterface];
}

- (void)cameraChanged:(id)aChanged
{
    NSInteger pvVar1;

    pvVar1 = [_camerasPopUpButton indexOfSelectedItem];
    [self HSMovieRecordingAssistantPane_updateCaptureVideoDevice:[[_camerasPopUpButton selectedItem] representedObject]];
    [[self liveVideoForPreview] setHyperDeviceIndex:pvVar1];
    [self activateCaptureDeviceSession];
    [self validateUserInterface];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00218e58 @ 00218e58, 90 bytes * /

void FUN_00218e58(HSMovieRecordingAssistantPane *self,SEL _cmd,id play)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_isPlaying);
  op = sel_stopPlaying;
  if ((char)pvVar1 == '\0') {
    op = sel_startPlaying;
  }
  _objc_msgSend(self,op);
  _objc_msgSend(self,sel_validateUserInterface);
  return;
}

*/
- (void)play:(id)aPlay
{
    if ([self isPlaying]) {
        [self stopPlaying];
    } else {
        [self startPlaying];
    }
    [self validateUserInterface];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00218eb2 @ 00218eb2, 90 bytes * /

void FUN_00218eb2(HSMovieRecordingAssistantPane *self,SEL _cmd,id record)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_isRecording);
  op = sel_stopRecording;
  if ((char)pvVar1 == '\0') {
    op = sel_startRecording;
  }
  _objc_msgSend(self,op);
  _objc_msgSend(self,sel_validateUserInterface);
  return;
}

*/
- (void)record:(id)aRecord
{
    if ([self isRecording]) {
        [self stopRecording];
    } else {
        [self startRecording];
    }
    [self validateUserInterface];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00218f0c @ 00218f0c, 218 bytes * /

id FUN_00218f0c(HSMovieRecordingAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  undefined4 uVar2;
  
  if ((self->_previewMovieObject == (id)0x0) && (self->_recordedMovieMedia != (id)0x0)) {
    pvVar1 = _objc_msgSend(cls_HSMovieObject,sel_alloc);
    uVar2 = 0;
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithMedia_error_,self->_recordedMovieMedia,0);
    self->_previewMovieObject = pvVar1;
    if (pvVar1 != (id)0x0) {
      pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00383020,uVar2);
      pvVar1 = _objc_msgSend(pvVar1,sel_queryGeometryBehaviorApplier);
      if (pvVar1 != (id)0x0) {
        _objc_msgSend(pvVar1,sel_setSize_withLayoutGuidingContext_,0x43a00000,0x43700000,0);
      }
    }
  }
  return self->_previewMovieObject;
}

*/
- (id)previewMovieObject
{
    if (_previewMovieObject == nil && _recordedMovieMedia != nil) {
        _previewMovieObject = [[HSMovieObject alloc] initWithMedia:_recordedMovieMedia error:NULL];
        if (_previewMovieObject != nil) {
            [[[_previewMovieObject queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier] setSize:NSMakeSize(320.0, 240.0) withLayoutGuidingContext:nil];
        }
    }
    return _previewMovieObject;
}

- (void)cleanPreviousRecorderMovieWithPath:(id)aPath
{
    if (aPath != nil) {
        [[NSFileManager defaultManager] removeItemAtURL:[NSURL URLWithString:aPath] error:nil];
    }
}

- (id)pathForRecordingWithMovieName
{
    return [[[HSPathsProvider sharedPathsProvider] temporaryFolder] stringByAppendingPathComponent:[[[HSUID UID] stringValue] stringByAppendingPathExtension:@"mov"]];
}

- (void)setLiveVideoForPreview:(id)aPreview
{
    if (_liveVideoForPreview != aPreview) {
        [_liveVideoForPreview release];
        _liveVideoForPreview = [aPreview retain];
    }
}

- (id)liveVideoForPreview
{
    id pvVar1;
    id pvVar1_2;
    id pvVar2_2;

    pvVar1 = _liveVideoForPreview;
    if (pvVar1 == nil) {
        pvVar1_2 = [HSLiveObject defaultObject];
        pvVar2_2 = [[pvVar1_2 queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
        if (pvVar2_2 != nil) {
            [pvVar2_2 setSize:NSMakeSize(320.0, 240.0) withLayoutGuidingContext:nil];
        }
        [self setLiveVideoForPreview:pvVar1_2];
        pvVar1 = _liveVideoForPreview;
    }
    return pvVar1;
}

- (void)enableUndoRegistration
{
    [[[[self card] document] undoManager] enableUndoRegistration];
}

- (void)disableUndoRegistration
{
    [[[[self card] document] undoManager] disableUndoRegistration];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-multiple-method-names"
#pragma clang diagnostic pop

/* --- i386 decompilation (Ghidra) ---
/* FUN_00219305 @ 00219305, 282 bytes * /

void FUN_00219305(HSMovieRecordingAssistantPane *self,SEL _cmd)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  
  pvVar2 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
  _objc_msgSend(pvVar2,sel_setIsRecordingMovie_,1);
  pvVar2 = _objc_msgSend(self,sel_window);
  pvVar2 = _objc_msgSend(pvVar2,sel_retain);
  pvVar3 = _objc_msgSend(pvVar2,sel_level);
  self->_windowLevel = (uint)pvVar3;
  puVar1 = PTR_00336058;
  pvVar3 = _objc_msgSend(*(id *)PTR_00336058,sel_beginModalSessionForWindow_,pvVar2);
  do {
    pvVar4 = _objc_msgSend(*(id *)puVar1,sel_runModalSession_,pvVar3);
  } while (pvVar4 == (id)0xfffffc16);
  _objc_msgSend(*(id *)puVar1,sel_endModalSession_,pvVar3);
  _objc_msgSend(self,sel_performSelector_withObject_afterDelay_,sel_restoreWindowLevel_,pvVar2,0,0);
  return;
}

*/
- (void)setRecordedMovieMedia:(id)aMedia
{
    if (![[_recordedMovieMedia mediaUID] isEqual:[aMedia mediaUID]]) {
        [_recordedMovieMedia release];
        _recordedMovieMedia = [aMedia retain];
    }
}

- (id)recordedMovieMedia
{
    return _recordedMovieMedia;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002194b5 @ 002194b5, 1108 bytes * /

void FUN_002194b5(HSMovieRecordingAssistantPane *self,SEL _cmd)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  id pvVar4;
  id pvVar5;
  char cVar6;
  char cVar7;
  int iVar8;
  
  pvVar2 = _objc_msgSend(self,sel_class);
  pvVar3 = _objc_msgSend(self,sel_isRecording);
  pvVar5 = self->_recordMovieButton;
  if ((char)pvVar3 == '\0') {
    pvVar3 = _objc_msgSend(pvVar2,sel_recordButtonImage);
    _objc_msgSend(pvVar5,sel_setImage_,pvVar3);
    pvVar5 = self->_recordMovieButton;
    pvVar3 = _objc_msgSend(pvVar2,sel_recordButtonAquaImage);
    _objc_msgSend(pvVar5,sel_setAquaAlternateImage_,pvVar3);
    pvVar5 = self->_recordMovieButton;
    op = sel_recordButtonGraphiteImage;
  }
  else {
    pvVar3 = _objc_msgSend(pvVar2,sel_stopButtonImage);
    _objc_msgSend(pvVar5,sel_setImage_,pvVar3);
    pvVar5 = self->_recordMovieButton;
    pvVar3 = _objc_msgSend(pvVar2,sel_stopButtonAquaImage);
    _objc_msgSend(pvVar5,sel_setAquaAlternateImage_,pvVar3);
    pvVar5 = self->_recordMovieButton;
    op = sel_stopButtonGraphiteImage;
  }
  pvVar3 = _objc_msgSend(pvVar2,op,pvVar3);
  _objc_msgSend(pvVar5,sel_setGraphiteAlternateImage_,pvVar3);
  pvVar4 = _objc_msgSend(self,sel_isPlaying);
  pvVar5 = self->_playMovieButton;
  if ((char)pvVar4 == '\0') {
    pvVar3 = _objc_msgSend(pvVar2,sel_playButtonImage,pvVar3);
    _objc_msgSend(pvVar5,sel_setImage_,pvVar3);
    pvVar5 = self->_playMovieButton;
    pvVar3 = _objc_msgSend(pvVar2,sel_playButtonAquaImage);
    _objc_msgSend(pvVar5,sel_setAquaAlternateImage_,pvVar3);
    pvVar5 = self->_playMovieButton;
    pvVar2 = _objc_msgSend(pvVar2,sel_playButtonGraphiteImage);
  }
  else {
    pvVar3 = _objc_msgSend(pvVar2,sel_stopButtonImage,pvVar3);
    _objc_msgSend(pvVar5,sel_setImage_,pvVar3);
    pvVar5 = self->_playMovieButton;
    pvVar3 = _objc_msgSend(pvVar2,sel_stopButtonAquaImage);
    _objc_msgSend(pvVar5,sel_setAquaAlternateImage_,pvVar3);
    pvVar5 = self->_playMovieButton;
    pvVar2 = _objc_msgSend(pvVar2,sel_stopButtonGraphiteImage);
  }
  _objc_msgSend(pvVar5,sel_setGraphiteAlternateImage_,pvVar2);
  pvVar5 = _objc_msgSend(self,sel_isRecording);
  if ((char)pvVar5 == '\0') {
    pvVar5 = _objc_msgSend(self->_camerasPopUpButton,sel_selectedItem,pvVar2);
    pvVar5 = _objc_msgSend(pvVar5,sel_isEnabled);
    if ((char)pvVar5 == '\0') goto LAB_0021976d;
    cVar6 = '\x01';
  }
  else {
LAB_0021976d:
    cVar6 = '\0';
  }
  pvVar5 = _objc_msgSend(self,sel_isPlaying);
  if (((char)pvVar5 == '\0') && (self->_captureVideoDevice != (id)0x0)) {
    pvVar5 = _objc_msgSend(self->_captureVideoDevice,sel_QTE_isInUseByAnotherApplication);
    if ((char)pvVar5 != '\0') goto LAB_002197af;
    cVar7 = '\x01';
  }
  else {
LAB_002197af:
    cVar7 = '\0';
  }
  pvVar5 = self->_playMovieButton;
  if (self->_recordedMovieMedia != (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_isRecording);
    if ((char)pvVar2 == '\0') {
      cVar1 = '\x01';
      goto LAB_002197e2;
    }
  }
  cVar1 = '\0';
LAB_002197e2:
  _objc_msgSend(pvVar5,sel_setEnabled_,(int)cVar1);
  _objc_msgSend(self->_recordMovieButton,sel_setEnabled_,(int)cVar7);
  iVar8 = (int)cVar6;
  _objc_msgSend(self->_camerasPopUpButton,sel_setEnabled_,iVar8);
  _objc_msgSend(self->_audioCaptureDevicesPopUp,sel_setEnabled_,iVar8);
  _objc_msgSend(self->_movieNameTextField,sel_setEditable_,iVar8);
  _objc_msgSend(self->_movieNameTextField,sel_setEnabled_,iVar8);
  _objc_msgSend(self->_cameraDescriptionTextField,sel_setEnabled_,iVar8);
  _objc_msgSend(self->_nameDescriptionTextField,sel_setEnabled_,iVar8);
  pvVar5 = _objc_msgSend(self,sel_navigationPaneSwitcher);
  _objc_msgSend(pvVar5,sel_validateUserInterface);
  return;
}

*/
- (void)validateUserInterface
{
    Class paneClass = [self class];
    if ([self isRecording]) {
        [_recordMovieButton setImage:[paneClass stopButtonImage]];
        [_recordMovieButton setAquaAlternateImage:[paneClass stopButtonAquaImage]];
        [_recordMovieButton setGraphiteAlternateImage:[paneClass stopButtonGraphiteImage]];
    } else {
        [_recordMovieButton setImage:[paneClass recordButtonImage]];
        [_recordMovieButton setAquaAlternateImage:[paneClass recordButtonAquaImage]];
        [_recordMovieButton setGraphiteAlternateImage:[paneClass recordButtonGraphiteImage]];
    }
    if ([self isPlaying]) {
        [_playMovieButton setImage:[paneClass stopButtonImage]];
        [_playMovieButton setAquaAlternateImage:[paneClass stopButtonAquaImage]];
        [_playMovieButton setGraphiteAlternateImage:[paneClass stopButtonGraphiteImage]];
    } else {
        [_playMovieButton setImage:[paneClass playButtonImage]];
        [_playMovieButton setAquaAlternateImage:[paneClass playButtonAquaImage]];
        [_playMovieButton setGraphiteAlternateImage:[paneClass playButtonGraphiteImage]];
    }
    BOOL canEditSettings = ![self isRecording] && [[_camerasPopUpButton selectedItem] isEnabled];
    BOOL canRecord = ![self isPlaying] && _captureVideoDevice != nil && ![_captureVideoDevice QTE_isInUseByAnotherApplication];
    [_playMovieButton setEnabled:_recordedMovieMedia != nil && ![self isRecording]];
    [_recordMovieButton setEnabled:canRecord];
    [_camerasPopUpButton setEnabled:canEditSettings];
    [_audioCaptureDevicesPopUp setEnabled:canEditSettings];
    [_movieNameTextField setEditable:canEditSettings];
    [_movieNameTextField setEnabled:canEditSettings];
    [_cameraDescriptionTextField setEnabled:canEditSettings];
    [_nameDescriptionTextField setEnabled:canEditSettings];
    [[self navigationPaneSwitcher] validateUserInterface];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00219909 @ 00219909, 634 bytes * /

void FUN_00219909(HSMovieRecordingAssistantPane *self,SEL _cmd,id paneDidOK)

{
  undefined *self_00;
  cfstringStruct *pcVar1;
  id pvVar2;
  id pvVar3;
  HSMovieRecordingAssistantPane *pHVar4;
  HSMovieRecordingAssistantPane **self_01;
  HSMovieRecordingAssistantPane **ppHVar5;
  HSMovieRecordingAssistantPane *local_14;
  
  _objc_msgSend(self,sel_destroyCaptureDeviceSession);
  if (self->_recordedMovieMedia != (id)0x0) {
    pcVar1 = _objc_msgSend(self->_movieNameTextField,sel_stringValue);
    self_00 = cls_HSNewMedia;
    if ((pcVar1 == (cfstringStruct *)0x0) || (pcVar1 == &cfstr_empty)) {
      pcVar1 = &cfstr_My_Movie;
    }
    pvVar2 = _objc_msgSend(self->_recordedMovieMedia,sel_mediaType);
    pvVar3 = _objc_msgSend(self->_recordedMovieMedia,sel_mediaData);
    pHVar4 = _objc_msgSend(self_00,sel_mediaWithData_name_type_,pvVar3,pcVar1,pvVar2);
    if (pHVar4 != (HSMovieRecordingAssistantPane *)0x0) {
      local_14 = (HSMovieRecordingAssistantPane *)0x0;
      pvVar3 = _objc_msgSend(cls_HSMovieObject,sel_alloc,pvVar3,pcVar1,pvVar2);
      ppHVar5 = &local_14;
      self_01 = _objc_msgSend(pvVar3,sel_initWithMedia_error_,pHVar4,ppHVar5);
      if (self_01 != (HSMovieRecordingAssistantPane **)0x0) {
        pvVar3 = _objc_msgSend(self_01,sel_queryHyperInterface_,&DAT_00383020,ppHVar5,pvVar2);
        pvVar3 = _objc_msgSend(pvVar3,sel_queryGeometryBehaviorApplier);
        if (pvVar3 != (id)0x0) {
          pvVar2 = (id)0x0;
          _objc_msgSend(pvVar3,sel_setSize_withLayoutGuidingContext_,0x43a00000,0x43700000,0);
        }
        pHVar4 = self;
        _objc_msgSend(self->_movieRecordingPaneDelegate,
                      sel_movieRecordingAssistantPane_didChooseMovieObject_,self,self_01,pvVar2);
        ppHVar5 = self_01;
      }
      if (local_14 != (HSMovieRecordingAssistantPane *)0x0) {
        pvVar2 = _objc_msgSend(cls_HSErrorManager,sel_sharedErrorManager,pHVar4,ppHVar5,pvVar2);
        ppHVar5 = _objc_msgSend(*(id *)PTR_00336058,sel_keyWindow);
        pHVar4 = local_14;
        _objc_msgSend(pvVar2,sel_presentError_inWindow_,local_14,ppHVar5);
      }
      pvVar2 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController,pHVar4,
                             ppHVar5);
      _objc_msgSend(pvVar2,sel_setIsRecordingMovie_,0);
    }
  }
  _objc_msgSend(self,sel_storeSelectedDevicesInUserDefaults);
  pvVar2 = _objc_msgSend(self,sel_movieRecordingPaneDelegate);
  pvVar2 = _objc_msgSend(pvVar2,sel_objectAssistantNavigationController);
  _objc_msgSend(pvVar2,sel_removeAllViewControllersWithIdentifier_,*(undefined4 *)PTR_PTR_003366c8);
  return;
}

*/
- (void)paneDidOK:(id)aOK
{
    [self destroyCaptureDeviceSession];
    if (_recordedMovieMedia != nil) {
        NSString *name = [_movieNameTextField stringValue];
        if ([name length] == 0) {
            name = @"My Movie";
        }
        HSNewMedia *media = [HSNewMedia mediaWithData:[_recordedMovieMedia mediaData] name:name type:[_recordedMovieMedia mediaType]];
        if (media != nil) {
            NSError *error = nil;
            HSMovieObject *movieObject = [[HSMovieObject alloc] initWithMedia:media error:&error];
            if (movieObject != nil) {
                [[[movieObject queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier] setSize:NSMakeSize(320.0, 240.0) withLayoutGuidingContext:nil];
                /* The delegate takes ownership of the new movie object, as in the original. */
                [_movieRecordingPaneDelegate movieRecordingAssistantPane:self didChooseMovieObject:movieObject];
            }
            if (error != nil) {
                [[HSErrorManager sharedErrorManager] presentError:error inWindow:[NSApp keyWindow]];
            }
            [[HSObjectAssistantController sharedAssistantController] setIsRecordingMovie:NO];
        }
    }
    [self storeSelectedDevicesInUserDefaults];
    [[[self movieRecordingPaneDelegate] objectAssistantNavigationController] removeAllViewControllersWithIdentifier:HSPickMovieSourcePaneIdentifier];
}

- (void)paneDidCancel:(id)aCancel
{
    [[HSObjectAssistantController sharedAssistantController] setIsRecordingMovie:NO];
    [self destroyCaptureDeviceSession];
    [self dismiss:YES];
}

- (BOOL)shouldEnableOKButtonInNavigationPaneSwitcher:(id)aSwitcher
{
    BOOL pvVar1;

    if ((_recordedMovieMedia != nil) && (pvVar1 = [self isPlaying], !pvVar1)) {
        return ![self isRecording];
    }
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00219c4e @ 00219c4e, 578 bytes * /

void FUN_00219c4e(HSMovieRecordingAssistantPane *self,SEL _cmd,BOOL viewWillDisappear)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined4 uVar4;
  HSMovieRecordingAssistantPane *local_1c;
  undefined *local_18;
  
  pvVar1 = _objc_msgSend(self,sel_isPlaying);
  if ((char)pvVar1 != '\0') {
    _objc_msgSend(self,sel_stopPlaying);
  }
  pvVar1 = _objc_msgSend(self,sel_isRecording);
  if ((char)pvVar1 != '\0') {
    _objc_msgSend(self,sel_stopRecording);
  }
  _objc_msgSend(self,sel_destroyCaptureDeviceSession);
  _objc_msgSend(self,sel_HSMovieRecordingAssistantPane_updateCaptureVideoDevice_,0);
  pvVar1 = (id)0x0;
  _objc_msgSend(self,sel_HSMovieRecordingAssistantPane_updateCaptureAudioDevice_,0);
  if (self->_captureVideoDeviceList != (id)0x0) {
    pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter,pvVar1);
    _objc_msgSend(pvVar2,sel_removeObserver_name_object_,self,
                  &cfstr_HSCaptureDeviceListDidUpdateNotification,self->_captureVideoDeviceList);
    pvVar1 = self->_captureVideoDeviceList;
    pvVar3 = _objc_msgSend(self->_camerasPopUpButton,sel_menu);
    _objc_msgSend(pvVar1,sel_detachMenu_,pvVar3);
    _objc_msgSend(self->_captureVideoDeviceList,sel_release);
    self->_captureVideoDeviceList = (id)0x0;
    _objc_msgSend(pvVar2,sel_removeObserver_name_object_,self,
                  &cfstr_HSCaptureDeviceListDidUpdateNotification,self->_captureAudioDeviceList);
    pvVar2 = self->_captureAudioDeviceList;
    pvVar1 = _objc_msgSend(self->_audioCaptureDevicesPopUp,sel_menu);
    _objc_msgSend(pvVar2,sel_detachMenu_,pvVar1);
    _objc_msgSend(self->_captureAudioDeviceList,sel_release);
    self->_captureAudioDeviceList = (id)0x0;
  }
  pvVar1 = _objc_msgSend(self,sel_assistant,pvVar1);
  uVar4 = 0xffffffff;
  if ((self->_countDownVisible[0] & 0x10) == 0) {
    uVar4 = 0;
  }
  _objc_msgSend(pvVar1,sel_setSupportsSettingsOnTheSpotMode_,uVar4);
  local_1c = self;
  local_18 = PTR_s_HSActionAssistantPane_00354cb0;
  _objc_msgSendSuper(&local_1c,sel_viewWillDisappear_,(int)viewWillDisappear);
  return;
}

*/
- (void)viewWillDisappear:(BOOL)aDisappear
{
    if ([self isPlaying]) {
        [self stopPlaying];
    }
    if ([self isRecording]) {
        [self stopRecording];
    }
    [self destroyCaptureDeviceSession];
    [self HSMovieRecordingAssistantPane_updateCaptureVideoDevice:nil];
    [self HSMovieRecordingAssistantPane_updateCaptureAudioDevice:nil];
    if (_captureVideoDeviceList != nil) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self name:@"HSCaptureDeviceListDidUpdateNotification" object:_captureVideoDeviceList];
        [_captureVideoDeviceList detachMenu:[_camerasPopUpButton menu]];
        [_captureVideoDeviceList release];
        _captureVideoDeviceList = nil;
        [center removeObserver:self name:@"HSCaptureDeviceListDidUpdateNotification" object:_captureAudioDeviceList];
        [_captureAudioDeviceList detachMenu:[_audioCaptureDevicesPopUp menu]];
        [_captureAudioDeviceList release];
        _captureAudioDeviceList = nil;
    }
    [[self assistant] setSupportsSettingsOnTheSpotMode:_supportSettingsOnTheSpotMode != 0];
    [super viewWillDisappear:aDisappear];
}

- (void)viewDidAppear:(BOOL)aAppear
{
    [super viewDidAppear:aAppear];
    [[self navigationPaneSwitcher] validateUserInterface];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00219ef5 @ 00219ef5, 1163 bytes * /

void FUN_00219ef5(HSMovieRecordingAssistantPane *self,SEL _cmd,BOOL viewWillAppear)

{
  undefined *self_00;
  id pvVar1;
  HSMovieRecordingAssistantPane *pHVar2;
  id pvVar3;
  id pvVar4;
  HSMovieRecordingAssistantPane *pHVar5;
  undefined4 uVar6;
  undefined4 uVar7;
  undefined4 uVar8;
  HSMovieRecordingAssistantPane *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSActionAssistantPane_00354cb0;
  pHVar5 = (HSMovieRecordingAssistantPane *)(int)viewWillAppear;
  _objc_msgSendSuper(&local_1c,sel_viewWillAppear_,pHVar5);
  _objc_msgSend(self->_camerasPopUpButton,sel_removeAllItems);
  pvVar1 = _objc_msgSend(cls_HSSystem,sel_sharedSystem);
  pvVar1 = _objc_msgSend(pvVar1,sel_isQTKitCapturingAvailable);
  if ((char)pvVar1 != '\0') {
    uVar6 = *(undefined4 *)PTR_00336158;
    pHVar5 = *(HSMovieRecordingAssistantPane **)PTR_0033615c;
    uVar7 = 0;
    uVar8 = uVar6;
    pHVar2 = _objc_msgSend(cls_NSArray,sel_arrayWithObjects_,pHVar5,uVar6,0);
    if (pHVar2 != (HSMovieRecordingAssistantPane *)0x0) {
      pvVar1 = _objc_msgSend(cls_HSCaptureDeviceList,sel_captureDeviceListForMediaTypes_,pHVar2,
                             uVar8,uVar7);
      pvVar1 = _objc_msgSend(pvVar1,sel_retain);
      self->_captureVideoDeviceList = pvVar1;
      pHVar5 = pHVar2;
      if (pvVar1 != (id)0x0) {
        pvVar3 = _objc_msgSend(self->_camerasPopUpButton,sel_menu,pHVar2,uVar8,uVar7);
        _objc_msgSend(pvVar1,sel_attachMenu_,pvVar3);
        pvVar3 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
        pvVar1 = self->_captureVideoDeviceList;
        _objc_msgSend(pvVar3,sel_addObserver_selector_name_object_,self,
                      sel_deviceControllerDidChangeVideoDeviceList_,
                      &cfstr_HSCaptureDeviceListDidUpdateNotification,pvVar1);
        pHVar5 = *(HSMovieRecordingAssistantPane **)PTR_00336404;
        uVar8 = 0;
        pHVar2 = _objc_msgSend(cls_NSArray,sel_arrayWithObjects_,pHVar5,uVar6,0);
        if (pHVar2 != (HSMovieRecordingAssistantPane *)0x0) {
          pvVar4 = _objc_msgSend(cls_HSCaptureDeviceList,sel_captureDeviceListForMediaTypes_,pHVar2,
                                 uVar6,uVar8,pvVar1);
          pvVar4 = _objc_msgSend(pvVar4,sel_retain);
          self->_captureAudioDeviceList = pvVar4;
          pHVar5 = pHVar2;
          if (pvVar4 != (id)0x0) {
            pvVar1 = _objc_msgSend(self->_audioCaptureDevicesPopUp,sel_menu,pHVar2,uVar6,uVar8,
                                   pvVar1);
            _objc_msgSend(pvVar4,sel_attachMenu_,pvVar1);
            pHVar5 = self;
            _objc_msgSend(pvVar3,sel_addObserver_selector_name_object_,self,
                          sel_deviceControllerDidChangeAudioDeviceList_,
                          &cfstr_HSCaptureDeviceListDidUpdateNotification,
                          self->_captureAudioDeviceList);
          }
        }
      }
    }
  }
  if (self->_captureVideoDeviceList == (id)0x0) {
    pvVar1 = _objc_msgSend(self->_camerasPopUpButton,sel_menu,pHVar5);
    self_00 = cls_NSBundle;
    pvVar3 = _objc_msgSend(cls_HSCaptureDeviceList,sel_class);
    pvVar3 = _objc_msgSend(self_00,sel_bundleForClass_,pvVar3);
    pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_Not_Available,
                           &cfstr_empty,&cfstr_HyperPlayerBase);
    pvVar1 = _objc_msgSend(pvVar1,sel_addItemWithTitle_action_keyEquivalent_,pvVar3,0,&cfstr_empty);
    pHVar5 = (HSMovieRecordingAssistantPane *)0x0;
    _objc_msgSend(pvVar1,sel_setEnabled_,0);
  }
  pvVar1 = _objc_msgSend(self,sel_selectInPopUpVideoDeviceFromUserDefaults,pHVar5);
  if ((char)pvVar1 == '\0') {
    _objc_msgSend(self,sel_selectInPopUpDefaultVideoDevice,pHVar5);
  }
  pvVar1 = _objc_msgSend(self,sel_selectInPopUpAudioDeviceFromUserDefaults,pHVar5);
  if ((char)pvVar1 == '\0') {
    _objc_msgSend(self,sel_selectInPopUpDefaultAudioDevice);
  }
  _objc_msgSend(self,sel_HSMovieRecordingAssistantPane_camerasPopUpButtonDidUpdate);
  _objc_msgSend(self,sel_HSMovieRecordingAssistantPane_audioPopUpButtonDidUpdate);
  _objc_msgSend(self->_recordProgressIndicator,sel_setUsesThreadedAnimation_,1);
  _objc_msgSend(self->_recordProgressIndicator,sel_setHidden_,1);
  _objc_msgSend(self,sel_activateCaptureDeviceSession);
  pvVar1 = _objc_msgSend(self,sel_assistant);
  pvVar1 = _objc_msgSend(pvVar1,sel_supportsSettingsOnTheSpotMode);
  self->_countDownVisible[0] = self->_countDownVisible[0] & 0xef | ((byte)pvVar1 & 1) << 4;
  pvVar1 = _objc_msgSend(self,sel_assistant);
  _objc_msgSend(pvVar1,sel_setSupportsSettingsOnTheSpotMode_,0);
  _objc_msgSend(self,sel_validateUserInterface);
  return;
}

*/
- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [_camerasPopUpButton removeAllItems];
    if ([[HSSystem sharedSystem] isQTKitCapturingAvailable]) {
        NSArray *videoTypes = [NSArray arrayWithObjects:QTMediaTypeVideo, QTMediaTypeMuxed, nil];
        if (videoTypes != nil) {
            _captureVideoDeviceList = [[HSCaptureDeviceList captureDeviceListForMediaTypes:videoTypes] retain];
            if (_captureVideoDeviceList != nil) {
                [_captureVideoDeviceList attachMenu:[_camerasPopUpButton menu]];
                NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
                [center addObserver:self selector:@selector(deviceControllerDidChangeVideoDeviceList:) name:@"HSCaptureDeviceListDidUpdateNotification" object:_captureVideoDeviceList];
                NSArray *audioTypes = [NSArray arrayWithObjects:QTMediaTypeSound, QTMediaTypeMuxed, nil];
                if (audioTypes != nil) {
                    _captureAudioDeviceList = [[HSCaptureDeviceList captureDeviceListForMediaTypes:audioTypes] retain];
                    if (_captureAudioDeviceList != nil) {
                        [_captureAudioDeviceList attachMenu:[_audioCaptureDevicesPopUp menu]];
                        [center addObserver:self selector:@selector(deviceControllerDidChangeAudioDeviceList:) name:@"HSCaptureDeviceListDidUpdateNotification" object:_captureAudioDeviceList];
                    }
                }
            }
        }
    }
    if (_captureVideoDeviceList == nil) {
        NSString *title = [[NSBundle bundleForClass:[HSCaptureDeviceList class]] localizedStringForKey:@"Not Available" value:@"" table:@"HyperPlayerBase"];
        [[[_camerasPopUpButton menu] addItemWithTitle:title action:NULL keyEquivalent:@""] setEnabled:NO];
    }
    if (![self selectInPopUpVideoDeviceFromUserDefaults]) {
        [self selectInPopUpDefaultVideoDevice];
    }
    if (![self selectInPopUpAudioDeviceFromUserDefaults]) {
        [self selectInPopUpDefaultAudioDevice];
    }
    [self HSMovieRecordingAssistantPane_camerasPopUpButtonDidUpdate];
    [self HSMovieRecordingAssistantPane_audioPopUpButtonDidUpdate];
    [_recordProgressIndicator setUsesThreadedAnimation:YES];
    [_recordProgressIndicator setHidden:YES];
    [self activateCaptureDeviceSession];
    /* Settings-on-the-spot mode is off while this pane shows. */
    _supportSettingsOnTheSpotMode = [[self assistant] supportsSettingsOnTheSpotMode] ? 1 : 0;
    [[self assistant] setSupportsSettingsOnTheSpotMode:NO];
    [self validateUserInterface];
}

- (void)viewDidLoad
{
    [_levelIndicator setMaxValue:10.0];
    [_levelIndicator setWarningValue:5.0];
    [_levelIndicator setCriticalValue:9.0];
    [_movieRecordBackgroundView setImage:[NSImage imageNamed:@"Countdown"]];
}

- (void)HSMovieRecordingAssistantPane_audioPopUpButtonDidUpdate
{
    NSInteger pvVar2;
    NSInteger pvVar1_2;

    if ([_captureAudioDeviceList captureDeviceCount] == 0) {
        pvVar1_2 = 0;
    }
    if (_captureAudioDevice == nil) {
        pvVar1_2 = [_audioCaptureDevicesPopUp indexOfSelectedItem];
    }
    else {
        pvVar2 = [_audioCaptureDevicesPopUp indexOfItemWithRepresentedObject:_captureAudioDevice];
        pvVar1_2 = 0;
        if (pvVar2 != NSNotFound) {
            pvVar1_2 = pvVar2;
        }
        [_audioCaptureDevicesPopUp selectItemAtIndex:pvVar1_2];
    }
    if ((-1 < (int)pvVar1_2) && (pvVar1_2 != NSNotFound)) {
        [self HSMovieRecordingAssistantPane_updateCaptureAudioDevice:[[_audioCaptureDevicesPopUp selectedItem] representedObject]];
    }
}

- (void)HSMovieRecordingAssistantPane_camerasPopUpButtonDidUpdate
{
    NSInteger pvVar2;
    NSInteger pvVar1_2;

    if ([_captureVideoDeviceList captureDeviceCount] == 0) {
        pvVar1_2 = 0;
    }
    if (_captureVideoDevice == nil) {
        pvVar1_2 = [_camerasPopUpButton indexOfSelectedItem];
    }
    else {
        pvVar2 = [_camerasPopUpButton indexOfItemWithRepresentedObject:_captureVideoDevice];
        pvVar1_2 = 0;
        if (pvVar2 != NSNotFound) {
            pvVar1_2 = pvVar2;
        }
        [_camerasPopUpButton selectItemAtIndex:pvVar1_2];
    }
    if ((-1 < (int)pvVar1_2) && (pvVar1_2 != NSNotFound)) {
        [self HSMovieRecordingAssistantPane_updateCaptureVideoDevice:[[_camerasPopUpButton selectedItem] representedObject]];
        [[self liveVideoForPreview] setHyperDeviceIndex:pvVar1_2];
    }
}

- (void)HSMovieRecordingAssistantPane_updateCaptureAudioDevice:(id)aDevice
{
    if (_captureAudioDevice != aDevice) {
        if ([self isRecording]) {
            [self stopRecording];
        }
        [self destroyCaptureDeviceSession];
        [_captureAudioDevice removeObserver:self forKeyPath:@"inUseByAnotherApplication"];
        [_captureAudioDevice removeObserver:self forKeyPath:@"suspended"];
        [aDevice retain];
        [_captureAudioDevice release];
        _captureAudioDevice = aDevice;
        [aDevice addObserver:self forKeyPath:@"inUseByAnotherApplication" options:0 context:nil];
        [_captureAudioDevice addObserver:self forKeyPath:@"suspended" options:0 context:nil];
    }
}

- (void)HSMovieRecordingAssistantPane_updateCaptureVideoDevice:(id)aDevice
{
    if (_captureVideoDevice != aDevice) {
        if ([self isRecording]) {
            [self stopRecording];
        }
        [self destroyCaptureDeviceSession];
        [_captureVideoDevice removeObserver:self forKeyPath:@"inUseByAnotherApplication"];
        [_captureVideoDevice removeObserver:self forKeyPath:@"suspended"];
        [aDevice retain];
        [_captureVideoDevice release];
        _captureVideoDevice = aDevice;
        [aDevice addObserver:self forKeyPath:@"inUseByAnotherApplication" options:0 context:nil];
        [_captureVideoDevice addObserver:self forKeyPath:@"suspended" options:0 context:nil];
    }
}

- (BOOL)needsToBeSavedInHistory
{
    return NO;
}

- (id)navigationPaneSwitcher
{
    HSObjectAssistantNavigationPaneSwitcher *pHVar1;
    HSObjectAssistantNavigationPaneSwitcher *pHVar1_2;

    pHVar1 = _navigationPaneSwitcher;
    if (pHVar1 == nil) {
        pHVar1_2 = [HSObjectAssistantNavigationPaneSwitcher new];
        _navigationPaneSwitcher = pHVar1_2;
        [pHVar1_2 setDelegate:self];
        pHVar1 = _navigationPaneSwitcher;
    }
    return pHVar1;
}

- (BOOL)requiresDarkBottomArea
{
    return YES;
}

- (id)actionAttributes
{
    id pvVar2;
    id pvVar1_3;

    pvVar1_3 = [[[self assistant] object] queryHyperInterface:@protocol(HSActor)];
    pvVar2 = [self actionEvent];
    return [pvVar1_3 hyperActionOfType:[self actionType] forEvent:pvVar2];
}

- (id)actionType
{
    return [HSPlayMovieAction actionType];
}

- (Class)applierClass
{
    return [HSActionAssistantSettingsApplier class];
}

- (void)selectInPopUpDefaultAudioDevice
{
    QTCaptureDevice *pvVar1;

    pvVar1 = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeSound];
    if (pvVar1 != nil) {
        [_audioCaptureDevicesPopUp selectItemWithTitle:[pvVar1 localizedDisplayName]];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0021aa76 @ 0021aa76, 239 bytes * /

void FUN_0021aa76(HSMovieRecordingAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  undefined4 uVar5;
  
  uVar5 = *(undefined4 *)PTR_0033615c;
  pvVar1 = _objc_msgSend(cls_QTCaptureDevice,sel_defaultInputDeviceWithMediaType_,uVar5);
  pvVar1 = _objc_msgSend(pvVar1,sel_uniqueID);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(self->_captureVideoDeviceList,sel_captureDeviceCount,uVar5);
    if (pvVar2 != (id)0x0) {
      pvVar4 = (id)0x0;
      do {
        pvVar3 = _objc_msgSend(self->_captureVideoDeviceList,sel_captureDeviceAtIndex_,pvVar4);
        pvVar3 = _objc_msgSend(pvVar3,sel_uniqueID);
        pvVar3 = _objc_msgSend(pvVar3,sel_isEqualToString_,pvVar1);
        if ((char)pvVar3 != '\0') {
          _objc_msgSend(self->_camerasPopUpButton,sel_selectItemAtIndex_,pvVar4);
        }
        pvVar4 = (id)((int)pvVar4 + 1);
      } while (pvVar4 < pvVar2);
    }
  }
  return;
}

*/
- (void)selectInPopUpDefaultVideoDevice
{
    NSString *uniqueID = [[QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeVideo] uniqueID];
    if (uniqueID == nil) {
        return;
    }
    NSUInteger count = [_captureVideoDeviceList captureDeviceCount];
    for (NSUInteger i = 0; i < count; i++) {
        if ([[(QTCaptureDevice *)[_captureVideoDeviceList captureDeviceAtIndex:i] uniqueID] isEqualToString:uniqueID]) {
            [_camerasPopUpButton selectItemAtIndex:i];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0021ab65 @ 0021ab65, 258 bytes * /

BOOL FUN_0021ab65(HSMovieRecordingAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  undefined4 uVar3;
  cfstringStruct *pcVar4;
  cfstringStruct *pcVar5;
  
  pvVar1 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  uVar3 = *(undefined4 *)PTR_003363f0;
  pvVar1 = _objc_msgSend(pvVar1,sel_stringForKey_,uVar3);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle,uVar3);
    pcVar5 = &cfstr_AssistantPanes;
    pcVar4 = &cfstr_empty;
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                           &cfstr_NoneDeviceMenuItemName,&cfstr_empty,&cfstr_AssistantPanes);
    pvVar2 = _objc_msgSend(pvVar1,sel_isEqualToString_,pvVar2);
    if (((char)pvVar2 == '\0') &&
       (pvVar2 = _objc_msgSend(self->_audioCaptureDevicesPopUp,sel_indexOfItemWithTitle_,pvVar1,
                               pcVar4,pcVar5), pvVar2 != (id)0xffffffff)) {
      _objc_msgSend(self->_audioCaptureDevicesPopUp,sel_selectItemWithTitle_,pvVar1,pcVar4,pcVar5);
      return '\x01';
    }
  }
  return '\0';
}

*/
- (BOOL)selectInPopUpAudioDeviceFromUserDefaults
{
    NSString *deviceName = [[NSUserDefaults standardUserDefaults] stringForKey:HSAudioInputDeviceNameKey];
    if (deviceName == nil || [deviceName isEqualToString:[[NSBundle mainBundle] localizedStringForKey:@"NoneDeviceMenuItemName" value:@"" table:@"AssistantPanes"]]) {
        return NO;
    }
    if ([_audioCaptureDevicesPopUp indexOfItemWithTitle:deviceName] == -1) {
        return NO;
    }
    [_audioCaptureDevicesPopUp selectItemWithTitle:deviceName];
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0021ac67 @ 0021ac67, 246 bytes * /

BOOL FUN_0021ac67(HSMovieRecordingAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  undefined4 uVar5;
  
  pvVar1 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  uVar5 = *(undefined4 *)PTR_00336618;
  pvVar1 = _objc_msgSend(pvVar1,sel_stringForKey_,uVar5);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(self->_captureVideoDeviceList,sel_captureDeviceCount,uVar5);
    for (pvVar4 = (id)0x0; pvVar4 < pvVar2; pvVar4 = (id)((int)pvVar4 + 1)) {
      pvVar3 = _objc_msgSend(self->_captureVideoDeviceList,sel_captureDeviceAtIndex_,pvVar4);
      pvVar3 = _objc_msgSend(pvVar3,sel_uniqueID);
      pvVar3 = _objc_msgSend(pvVar3,sel_isEqualToString_,pvVar1);
      if ((char)pvVar3 != '\0') {
        _objc_msgSend(self->_camerasPopUpButton,sel_selectItemAtIndex_,pvVar4);
        return '\x01';
      }
    }
  }
  return '\0';
}

*/
- (BOOL)selectInPopUpVideoDeviceFromUserDefaults
{
    NSString *uniqueID = [[NSUserDefaults standardUserDefaults] stringForKey:HSVideoDeviceUniqueIDKey];
    if (uniqueID == nil) {
        return NO;
    }
    NSUInteger count = [_captureVideoDeviceList captureDeviceCount];
    for (NSUInteger i = 0; i < count; i++) {
        if ([[(QTCaptureDevice *)[_captureVideoDeviceList captureDeviceAtIndex:i] uniqueID] isEqualToString:uniqueID]) {
            [_camerasPopUpButton selectItemAtIndex:i];
            return YES;
        }
    }
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0021ad5d @ 0021ad5d, 253 bytes * /

void FUN_0021ad5d(HSMovieRecordingAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  pvVar2 = _objc_msgSend(self->_audioCaptureDevicesPopUp,sel_selectedItem);
  pvVar2 = _objc_msgSend(pvVar2,sel_title);
  _objc_msgSend(pvVar1,sel_setObject_forKey_,pvVar2,*(undefined4 *)PTR_003363f0);
  pvVar1 = _objc_msgSend(self->_camerasPopUpButton,sel_selectedItem);
  pvVar1 = _objc_msgSend(pvVar1,sel_representedObject);
  pvVar2 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  pvVar1 = _objc_msgSend(pvVar1,sel_uniqueID);
  _objc_msgSend(pvVar2,sel_setObject_forKey_,pvVar1,*(undefined4 *)PTR_00336618);
  return;
}

*/
- (void)storeSelectedDevicesInUserDefaults
{
    [[NSUserDefaults standardUserDefaults] setObject:[[_audioCaptureDevicesPopUp selectedItem] title] forKey:HSAudioInputDeviceNameKey];
    QTCaptureDevice *device = [[_camerasPopUpButton selectedItem] representedObject];
    [[NSUserDefaults standardUserDefaults] setObject:[device uniqueID] forKey:HSVideoDeviceUniqueIDKey];
}

- (void)dealloc
{
    id pvVar1;

    pvVar1 = [HSObjectAssistantController sharedAssistantController];
    [pvVar1 setIsRecordingMovie:NO];
    [self destroyCaptureDeviceSession];
    [_captureDeviceSessionError release];
    pvVar1 = [NSNotificationCenter defaultCenter];
    [pvVar1 removeObserver:self];
    [self removeTimerForMeasurementDuration];
    [_countDownViewController release];
    if (_recordedMovieMedia != nil) {
        pvVar1 = [_recordedMovieMedia fullPathToMediaFile];
        [self cleanPreviousRecorderMovieWithPath:pvVar1];
        [self setRecordedMovieMedia:nil];
    }
    [self setLiveVideoForPreview:nil];
    [_previewMovieObject release];
    [_recordedMovieFilePath release];
    [_navigationPaneSwitcher setDelegate:0];
    [_navigationPaneSwitcher release];
    [_previousSelectedNodes release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"MovieRecordingAssistantPane"];
    return self;
}

- (void)adjustLiveObjectAspectRatio
{
    NSSize size = NSZeroSize;
    id format = [[[_captureVideoDevice formatDescriptions] lastObject] attributeForKey:@"videoEncodedPixelsSize"];
    [format getValue:&size];
    id applier = [[[self liveVideoForPreview] queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
    if (applier != nil && !NSEqualSizes(size, NSZeroSize))
        [applier resizeToHeight:(size.height * 320.0) / size.width maintainAspectRatio:2 withLayoutGuidingContext:nil];
}

@end

