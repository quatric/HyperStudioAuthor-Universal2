#import "HSSoundRecordingAssistantPane.h"

@implementation HSSoundRecordingAssistantPane

/* i386 ivar offsets: _levelIndicator=0x78, _soundRecordBackgroundView=0x7c, _audioTimeTextField=0x80, _recordButton=0x84, _playButton=0x88, _soundNameTextField=0x8c, _soundCaptureDevicePopUp=0x90, _countDownViewController=0x94, _soundCaptureDeviceList=0x98, _soundCaptureSession=0x9c, _soundCaptureInput=0xa0, _soundCaptureOutput=0xa4, _timerForObservingInputAudioLevel=0xa8, _timerForMeasurementRecordAudioTime=0xac, _windowLevel=0xb0, _previewSoundObject=0xb4, _recordedSoundFilePath=0xb8, _navigationPaneSwitcher=0xbc, _soundRecordingAssistantPaneDelegate=0xc0, _isRecording=0xc4, _didCaptureMovieFileOutputStartRecording=0xc4, _didCaptureMovieFileOutputFinishRecording=0xc4, _supportSettingsOnTheSpotMode=0xc4 */

+ (id)stopRecordButtonAquaImage
{
    return [self stopButtonAquaImage];
}

+ (id)stopRecordButtonGraphiteImage
{
    return [self stopButtonGraphiteImage];
}

+ (id)stopRecordButtonImage
{
    return [self stopButtonImage];
}

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

/* --- i386 decompilation (Ghidra) ---
/* FUN_00221ddb @ 00221ddb, 82 bytes * /

void FUN_00221ddb(HSSoundRecordingAssistantPane *self,SEL _cmd,id captureOutput,
                 id didFinishRecordingToOutputFileAtURL,id forConnections,id dueToError)

{
  id self_00;
  
  if (dueToError != (id)0x0) {
    self_00 = _objc_msgSend(cls_NSAlert,sel_alertWithError_,dueToError);
    _objc_msgSend(self_00,sel_runModal);
  }
  self->_isRecording[0] = self->_isRecording[0] | 4;
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
/* FUN_0022198e @ 0022198e, 15 bytes * /

void FUN_0022198e(HSSoundRecordingAssistantPane *self,SEL _cmd,id captureOutput,
                 id didStartRecordingToOutputFileAtURL,id forConnections)

{
  self->_isRecording[0] = self->_isRecording[0] | 2;
  return;
}

*/
- (void)captureOutput:(id)aOutput didStartRecordingToOutputFileAtURL:(id)aURL forConnections:(id)aConnections
{
    _didCaptureMovieFileOutputStartRecording = 1;
}

- (id)localizedUniqueRecordName
{
    int iVar3;
    NSString *local_14;
    NSString *pvVar1_2;
    id pvVar2_5;
    BOOL pvVar2_6;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"MySoundRecord" value:@"" table:@"AssistantPanes"];
    local_14 = [pvVar1_2 stringByAppendingFormat:@" %d", 1];
    if ([[[self stack] queryHyperInterface:@protocol(HSStackSoundStorage)] stackContainsSoundMediaWithName:local_14]) {
        iVar3 = 2;
        do {
            local_14 = [pvVar1_2 stringByAppendingFormat:@" %d", iVar3];
            pvVar2_5 = [[self stack] queryHyperInterface:@protocol(HSStackSoundStorage)];
            iVar3 = iVar3 + 1;
            pvVar2_6 = [pvVar2_5 stackContainsSoundMediaWithName:local_14];
        } while (pvVar2_6);
    }
    return local_14;
}

- (void)removeRecorderSoundFile
{
    id pvVar1;
    NSFileManager *pvVar2;

    pvVar1 = [self recordedSoundFilePath];
    pvVar2 = [NSFileManager defaultManager];
    if ([pvVar2 fileExistsAtPath:pvVar1]) {
        [[NSFileManager defaultManager] removeFileAtPath:pvVar1 handler:nil];
    }
}

- (void)invalidatePreviewSoundObject
{
    if (_previewSoundObject != nil) {
        if ([_previewSoundObject isPlaying]) {
            [_previewSoundObject stop];
        }
        [_previewSoundObject setDelegate:0];
        [_previewSoundObject release];
        _previewSoundObject = nil;
    }
}

- (id)previewSoundObject
{
    id pvVar1;
    NSFileManager *pvVar2;
    id pvVar3;
    id pvVar3_3;

    pvVar3 = _previewSoundObject;
    if (pvVar3 == nil) {
        pvVar1 = [self recordedSoundFilePath];
        pvVar2 = [NSFileManager defaultManager];
        if (![pvVar2 fileExistsAtPath:pvVar1]) {
            pvVar3_3 = _previewSoundObject;
        }
        else {
            pvVar3_3 = [[HSMovie alloc] initWithURL:[NSURL fileURLWithPath:pvVar1] error:0];
            _previewSoundObject = pvVar3_3;
        }
        [pvVar3_3 setDelegate:self];
        pvVar3 = _previewSoundObject;
    }
    return pvVar3;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-multiple-method-names"
- (void)restoreWindowLevel:(id)aLevel
{
    [aLevel setLevel:_windowLevel];
    [aLevel release];
}
#pragma clang diagnostic pop

/* --- i386 decompilation (Ghidra) ---
/* FUN_002221e7 @ 002221e7, 298 bytes * /

void FUN_002221e7(HSSoundRecordingAssistantPane *self,SEL _cmd)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  
  pvVar2 = _objc_msgSend(self,sel_window);
  pvVar2 = _objc_msgSend(pvVar2,sel_level);
  self->_windowLevel = (uint)pvVar2;
  pvVar2 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
  _objc_msgSend(pvVar2,sel_setIsRecordingSound_,1);
  pvVar2 = _objc_msgSend(self,sel_window);
  pvVar2 = _objc_msgSend(pvVar2,sel_retain);
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
- (void)runSoundRecordingModalSession
{
    NSModalSession session;
    id window;

    _windowLevel = (unsigned int)[(NSWindow *)[self window] level];
    [[HSObjectAssistantController sharedAssistantController] setIsRecordingSound:YES];
    // The window stays retained until restoreWindowLevel: runs.
    window = [[self window] retain];
    session = [NSApp beginModalSessionForWindow:window];
    while ([NSApp runModalSession:session] == NSModalResponseContinue) {
    }
    [NSApp endModalSession:session];
    [self performSelector:@selector(restoreWindowLevel:) withObject:window afterDelay:0.0];
}

- (void)movieDidStop:(id)aStop
{
    [self movieDidEnd:aStop];
}

- (void)movieDidPlayOnce:(id)aOnce
{

}

- (void)movieDidEnd:(id)aEnd
{
    [self removeTimerForMeasurementSoundDuration];
    [aEnd gotoBeginning];
    [self validateUserInterface];
}

- (void)movieDidChangeImage:(id)aImage
{

}

- (void)soundCaptureDeviceDidChange:(id)aChange
{
    [self setSoundCaptureDevice:[[_soundCaptureDevicePopUp selectedItem] representedObject]];
    [self validateUserInterface];
}

- (void)updateSoundDuration:(id)aDuration
{
    BOOL pvVar1;
    id pvVar1_2;

    pvVar1 = [self isRecording];
    if ((!pvVar1) && (pvVar1 = [self isPlaying], !pvVar1))
    {
        return;
    }
    pvVar1_2 = _audioTimeTextField;
    [self setSoundDuration:[self soundDurationForTextField:pvVar1_2] + 1.0 forTextField:pvVar1_2];
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

/* --- i386 decompilation (Ghidra) ---
/* FUN_00222528 @ 00222528, 152 bytes * /

double FUN_00222528(HSSoundRecordingAssistantPane *self,SEL _cmd,id soundDurationForTextField)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar1 = _objc_msgSend(soundDurationForTextField,sel_objectValue);
  pvVar2 = _objc_msgSend(pvVar1,sel_hourOfDay);
  pvVar3 = _objc_msgSend(pvVar1,sel_minuteOfHour);
  pvVar1 = _objc_msgSend(pvVar1,sel_secondOfMinute);
  return (double)(int)pvVar1 + (double)(int)pvVar3 * 60.0 + (double)(int)pvVar2 * 3600.0;
}

*/
- (double)soundDurationForTextField:(id)aField
{
    id value = [aField objectValue];
    return (double)(int)[value secondOfMinute] + (double)(int)[value minuteOfHour] * 60.0 + (double)(int)[value hourOfDay] * 3600.0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002225c0 @ 002225c0, 381 bytes * /

void FUN_002225c0(HSSoundRecordingAssistantPane *self,SEL _cmd)

{
  undefined *puVar1;
  undefined *self_00;
  id pvVar2;
  
  _objc_msgSend(self,sel_removeTimerForMeasurementSoundDuration);
  self_00 = cls_NSTimer;
  puVar1 = sel_updateSoundDuration_;
  pvVar2 = _objc_msgSend(self,sel_NSE_newWeakProxy);
  pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
  pvVar2 = _objc_msgSend(self_00,sel_timerWithTimeInterval_target_selector_userInfo_repeats_,0,
                         0x3ff00000,pvVar2,puVar1,0,1);
  pvVar2 = _objc_msgSend(pvVar2,sel_retain);
  self->_timerForMeasurementRecordAudioTime = pvVar2;
  pvVar2 = _objc_msgSend(cls_NSRunLoop,sel_currentRunLoop);
  _objc_msgSend(pvVar2,sel_addTimer_forMode_,self->_timerForMeasurementRecordAudioTime,
                *(undefined4 *)PTR_003361b4);
  pvVar2 = _objc_msgSend(cls_NSRunLoop,sel_currentRunLoop);
  _objc_msgSend(pvVar2,sel_addTimer_forMode_,self->_timerForMeasurementRecordAudioTime,
                *(undefined4 *)PTR_00336064);
  pvVar2 = _objc_msgSend(cls_NSRunLoop,sel_currentRunLoop);
  _objc_msgSend(pvVar2,sel_addTimer_forMode_,self->_timerForMeasurementRecordAudioTime,
                *(undefined4 *)PTR_003363f8);
  return;
}

*/
- (void)installTimerForMeasurementSoundDuration
{
    [self removeTimerForMeasurementSoundDuration];
    _timerForMeasurementRecordAudioTime = [[NSTimer timerWithTimeInterval:1.0 target:[[self NSE_newWeakProxy] autorelease] selector:@selector(updateSoundDuration:) userInfo:nil repeats:YES] retain];
    [[NSRunLoop currentRunLoop] addTimer:_timerForMeasurementRecordAudioTime forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:_timerForMeasurementRecordAudioTime forMode:NSEventTrackingRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:_timerForMeasurementRecordAudioTime forMode:NSModalPanelRunLoopMode];
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
/* FUN_00222793 @ 00222793, 548 bytes * /

void FUN_00222793(HSSoundRecordingAssistantPane *self,SEL _cmd,id updateIndicatorState)

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
  id pvVar7;
  longdouble lVar8;
  double dVar9;
  undefined8 in_stack_ffffffac;
  uint uVar11;
  longlong lVar10;
  undefined4 uVar12;
  uint local_30;
  float local_24;
  
  if (self->_soundCaptureOutput == (id)0x0) {
    return;
  }
  self_00 = _objc_msgSend(self->_soundCaptureOutput,sel_connections);
  pvVar3 = _objc_msgSend(self_00,sel_count);
  uVar11 = (uint)((ulonglong)in_stack_ffffffac >> 0x20);
  if (pvVar3 == (id)0x0) {
    self_02 = self->_levelIndicator;
  }
  else {
    uVar1 = *(undefined4 *)PTR_00336404;
    local_24 = 0.0;
    local_30 = 0;
    uVar2 = *(undefined4 *)PTR_003363fc;
    pvVar7 = (id)0x0;
    do {
      uVar12 = (undefined4)((ulonglong)in_stack_ffffffac >> 0x20);
      pvVar4 = _objc_msgSend(self_00,sel_objectAtIndex_,pvVar7);
      pvVar5 = _objc_msgSend(pvVar4,sel_mediaType);
      in_stack_ffffffac = CONCAT44(uVar12,uVar1);
      pvVar5 = _objc_msgSend(pvVar5,sel_isEqualToString_,uVar1);
      if ((char)pvVar5 != '\0') {
        in_stack_ffffffac = CONCAT44((int)((ulonglong)in_stack_ffffffac >> 0x20),uVar2);
        pvVar4 = _objc_msgSend(pvVar4,sel_attributeForKey_,uVar2);
        pvVar5 = _objc_msgSend(pvVar4,sel_count);
        if (pvVar5 != (id)0x0) {
          if (pvVar5 < (id)0x2) {
            pvVar5 = (id)0x1;
          }
          pvVar6 = (id)0x0;
          do {
            in_stack_ffffffac = CONCAT44((int)((ulonglong)in_stack_ffffffac >> 0x20),pvVar6);
            self_01 = _objc_msgSend(pvVar4,sel_objectAtIndex_,pvVar6);
            dVar9 = _objc_msgSend_fpret(self_01,sel_floatValue);
            pvVar6 = (id)((int)pvVar6 + 1);
            local_24 = local_24 + (float)dVar9;
          } while (pvVar5 != pvVar6);
          local_30 = local_30 + (int)pvVar5;
        }
      }
      uVar11 = (uint)((ulonglong)in_stack_ffffffac >> 0x20);
      pvVar7 = (id)((int)pvVar7 + 1);
    } while (pvVar7 < pvVar3);
    self_02 = self->_levelIndicator;
    if (local_30 != 0) {
      dVar9 = (double)(local_24 /
                      (float)((double)((ulonglong)local_30 | 0x4330000000000000) -
                             4503599627370496.0)) * 0.05;
      lVar8 = (longdouble)_pow(0x4024000000000000,dVar9);
      lVar10 = CONCAT44((int)((ulonglong)dVar9 >> 0x20),(float)((double)lVar8 * 10.0));
      goto LAB_002229aa;
    }
  }
  lVar10 = (ulonglong)uVar11 << 0x20;
LAB_002229aa:
  _objc_msgSend(self_02,sel_setValue_,lVar10);
  return;
}

*/
- (void)updateIndicatorState:(id)aState
{
    if (_soundCaptureOutput == nil) {
        return;
    }
    NSArray *connections = [_soundCaptureOutput connections];
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
            value = (float)(pow(10.0, (double)(totalLevel / (float)levelCount) * 0.05) * 10.0);
        }
    }
    [_levelIndicator setValue:value];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002229b7 @ 002229b7, 381 bytes * /

void FUN_002229b7(HSSoundRecordingAssistantPane *self,SEL _cmd)

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
    [[NSRunLoop currentRunLoop] addTimer:_timerForObservingInputAudioLevel forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:_timerForObservingInputAudioLevel forMode:NSEventTrackingRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:_timerForObservingInputAudioLevel forMode:NSModalPanelRunLoopMode];
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
/* FUN_00222b8a @ 00222b8a, 203 bytes * /

void FUN_00222b8a(HSSoundRecordingAssistantPane *self,SEL _cmd,id observeValueForKeyPath,id ofObject
                 ,id change,void *context)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self->_soundCaptureInput,sel_device);
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
                  sel_soundCaptureDeviceDidChangeState_,ofObject,0);
  }
  return;
}

*/
- (void)observeValueForKeyPath:(id)aPath ofObject:(id)aObject change:(id)aChange context:(void *)aContext
{
    if ([_soundCaptureInput device] != aObject) {
        return;
    }
    if ([aPath isEqualToString:@"inUseByAnotherApplication"] || [aPath isEqualToString:@"suspended"] || [aPath isEqualToString:@"connected"]) {
        [self performSelectorOnMainThread:@selector(soundCaptureDeviceDidChangeState:) withObject:aObject waitUntilDone:NO];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00222c55 @ 00222c55, 239 bytes * /

void FUN_00222c55(HSSoundRecordingAssistantPane *self,SEL _cmd,id soundCaptureDeviceDidChangeState)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self->_soundCaptureInput,sel_device);
  if (pvVar1 != soundCaptureDeviceDidChangeState) {
    return;
  }
  pvVar1 = _objc_msgSend(soundCaptureDeviceDidChangeState,sel_isConnected);
  if (((char)pvVar1 != '\0') &&
     (pvVar1 = _objc_msgSend(soundCaptureDeviceDidChangeState,sel_QTE_isInUseByAnotherApplication),
     (char)pvVar1 == '\0')) {
    pvVar1 = _objc_msgSend(soundCaptureDeviceDidChangeState,sel_attributeForKey_,
                           *(undefined4 *)PTR_00336400);
    pvVar1 = _objc_msgSend(pvVar1,sel_boolValue);
    if ((char)pvVar1 == '\0') goto LAB_00222d2a;
  }
  _objc_msgSend(self->_countDownViewController,sel_stopRun);
  pvVar1 = _objc_msgSend(self,sel_isRecording);
  if ((char)pvVar1 != '\0') {
    _objc_msgSend(self,sel_stopRecording);
  }
LAB_00222d2a:
  _objc_msgSend(self,sel_validateUserInterface);
  return;
}

*/
- (void)soundCaptureDeviceDidChangeState:(id)aState
{
    if ([_soundCaptureInput device] != aState) {
        return;
    }
    if (![aState isConnected] || [aState QTE_isInUseByAnotherApplication] || [[aState attributeForKey:QTCaptureDeviceSuspendedAttribute] boolValue]) {
        [_countDownViewController stopRun];
        if ([self isRecording]) {
            [self stopRecording];
        }
    }
    [self validateUserInterface];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00222d44 @ 00222d44, 300 bytes * /

void FUN_00222d44(HSSoundRecordingAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  _objc_msgSend(self,sel_validateUserInterface);
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
    NSString *ok;
    NSString *message;
    NSString *title;

    [self validateUserInterface];
    ok = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"OK" value:@"" table:@"Alerts"];
    message = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Free some disk space and try recording again." value:@"" table:@"Alerts"];
    title = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Not enough disk space to save sound being recorded" value:@"" table:@"Alerts"];
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert setAlertStyle:NSAlertStyleCritical];
    [alert setMessageText:title];
    [alert setInformativeText:message];
    [alert addButtonWithTitle:ok];
    [alert runModal];
}

- (void)controlTextDidChange:(id)aChange
{
    id pvVar2;

    pvVar2 = _soundNameTextField;
    [pvVar2 setStringValue:[pvVar2 stringValue]];
    [[self navigationPaneSwitcher] validateUserInterface];
}

- (BOOL)isPlaying
{
    return (BOOL)[_previewSoundObject isPlaying];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00222f0b @ 00222f0b, 160 bytes * /

void FUN_00222f0b(HSSoundRecordingAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  double dVar2;
  
  _objc_msgSend(self->_previewSoundObject,sel_stop);
  _objc_msgSend(self->_previewSoundObject,sel_gotoBeginning);
  _objc_msgSend(self,sel_removeTimerForMeasurementSoundDuration);
  pvVar1 = self->_audioTimeTextField;
  self_00 = _objc_msgSend(self,sel_previewSoundObject);
  dVar2 = _objc_msgSend_fpret(self_00,sel_duration);
  _objc_msgSend(self,sel_setSoundDuration_forTextField_,dVar2,pvVar1);
  return;
}

*/
- (void)stopPlaying
{
    [_previewSoundObject stop];
    [_previewSoundObject gotoBeginning];
    [self removeTimerForMeasurementSoundDuration];
    [self setSoundDuration:[(HSMovie *)[self previewSoundObject] duration] forTextField:_audioTimeTextField];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00222fab @ 00222fab, 202 bytes * /

void FUN_00222fab(HSSoundRecordingAssistantPane *self,SEL _cmd,id play)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_isPlaying);
  op = sel_stopPlaying;
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(cls_HSMediaPlaySynchronizer,sel_sharedSynchronizer);
    pvVar2 = _objc_msgSend(self,sel_previewSoundObject);
    _objc_msgSend(pvVar1,sel_playMediaSingle_,pvVar2);
    _objc_msgSend(self,sel_setSoundDuration_forTextField_,0,0,self->_audioTimeTextField);
    op = sel_installTimerForMeasurementSoundDuration;
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
    }
    else {
        [[HSMediaPlaySynchronizer sharedSynchronizer] playMediaSingle:[self previewSoundObject]];
        [self setSoundDuration:0.0 forTextField:_audioTimeTextField];
        [self installTimerForMeasurementSoundDuration];
    }
    [self validateUserInterface];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00223075 @ 00223075, 712 bytes * /

void FUN_00223075(HSSoundRecordingAssistantPane *self,SEL _cmd,id countDownDidEnd)

{
  HSSoundRecordingAssistantPane *pHVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id self_00;
  id pvVar5;
  HSSoundRecordingAssistantPane *pHVar6;
  int extraout_EDX;
  id pvVar7;
  
  pvVar2 = _objc_msgSend(self,sel_recordedSoundFilePath);
  pvVar3 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
  pvVar4 = _objc_msgSend(pvVar2,sel_stringByDeletingLastPathComponent);
  pvVar4 = _objc_msgSend(pvVar3,sel_fileSystemAttributesAtPath_,pvVar4);
  pvVar3 = *(id *)PTR_003363f4;
  pvVar4 = _objc_msgSend(pvVar4,sel_objectForKey_,pvVar3);
  pvVar4 = _objc_msgSend(pvVar4,sel_unsignedLongLongValue);
  if (extraout_EDX == 0 && pvVar4 < (id)0x6400000) {
    _objc_msgSend(self,sel_informAboutDiskSpaceError,pvVar3);
  }
  else {
    pvVar4 = _objc_msgSend(self,sel_soundCaptureSession,pvVar3);
    if ((pvVar4 != (id)0x0) &&
       (pvVar4 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_,pvVar2), pvVar3 = pvVar2,
       pvVar4 != (id)0x0)) {
      pHVar6 = self;
      _objc_msgSend(self->_soundCaptureOutput,sel_setDelegate_,self);
      pvVar3 = _objc_msgSend(self->_soundCaptureOutput,sel_connections);
      pvVar2 = _objc_msgSend(pvVar3,sel_count);
      if (pvVar2 != (id)0x0) {
        pHVar1 = *(HSSoundRecordingAssistantPane **)PTR_00336404;
        pvVar7 = (id)0x0;
        do {
          self_00 = _objc_msgSend(pvVar3,sel_objectAtIndex_,pvVar7);
          pvVar5 = _objc_msgSend(self_00,sel_mediaType);
          pHVar6 = pHVar1;
          pvVar5 = _objc_msgSend(pvVar5,sel_isEqualToString_,pHVar1);
          if ((char)pvVar5 != '\0') {
            pHVar6 = _objc_msgSend(cls_QTCompressionOptions,sel_compressionOptionsWithIdentifier_,
                                   &cfstr_QTCompressionOptionsVoiceQualityAACAudio);
            _objc_msgSend(self->_soundCaptureOutput,sel_setCompressionOptions_forConnection_,pHVar6,
                          self_00);
          }
          pvVar7 = (id)((int)pvVar7 + 1);
        } while (pvVar7 < pvVar2);
      }
      _objc_msgSend(self,sel_invalidatePreviewSoundObject,pHVar6);
      _objc_msgSend(self,sel_removeRecorderSoundFile);
      _objc_msgSend(self,sel_setSoundDuration_forTextField_,0,0,self->_audioTimeTextField);
      _objc_msgSend(self,sel_installTimerForMeasurementSoundDuration);
      self->_isRecording[0] = self->_isRecording[0] & 0xf9;
      _objc_msgSend(self->_soundCaptureOutput,sel_recordToOutputFileURL_,pvVar4);
      self->_isRecording[0] = self->_isRecording[0] | 1;
      pvVar3 = pvVar4;
    }
  }
  _objc_msgSend(self,sel_validateUserInterface,pvVar3);
  return;
}

*/
- (void)countDownDidEnd:(id)aEnd
{
    NSString *path = [self recordedSoundFilePath];
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[path stringByDeletingLastPathComponent] error:NULL];
    if ([[attributes objectForKey:NSFileSystemFreeSize] unsignedLongLongValue] < 0x6400000ULL) {
        [self informAboutDiskSpaceError];
    }
    else if ([self soundCaptureSession] != nil) {
        NSURL *url = [NSURL fileURLWithPath:path];
        if (url != nil) {
            [_soundCaptureOutput setDelegate:self];
            NSArray *connections = [_soundCaptureOutput connections];
            NSUInteger count = [connections count];
            for (NSUInteger i = 0; i < count; i++) {
                QTCaptureConnection *connection = [connections objectAtIndex:i];
                if ([[connection mediaType] isEqualToString:QTMediaTypeSound]) {
                    [_soundCaptureOutput setCompressionOptions:[QTCompressionOptions compressionOptionsWithIdentifier:@"QTCompressionOptionsVoiceQualityAACAudio"] forConnection:connection];
                }
            }
            [self invalidatePreviewSoundObject];
            [self removeRecorderSoundFile];
            [self setSoundDuration:0.0 forTextField:_audioTimeTextField];
            [self installTimerForMeasurementSoundDuration];
            _didCaptureMovieFileOutputStartRecording = 0;
            _didCaptureMovieFileOutputFinishRecording = 0;
            [_soundCaptureOutput recordToOutputFileURL:url];
            _isRecording = 1;
        }
    }
    [self validateUserInterface];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0022333d @ 0022333d, 352 bytes * /

void FUN_0022333d(HSSoundRecordingAssistantPane *self,SEL _cmd)

{
  undefined4 uVar1;
  id self_00;
  id pvVar2;
  double dVar3;
  
  if ((self->_isRecording[0] & 1) != 0) {
    _objc_msgSend(self,sel_removeTimerForMeasurementSoundDuration);
    self->_isRecording[0] = self->_isRecording[0] & 0xfe;
    _objc_msgSend(self->_soundCaptureOutput,sel_recordToOutputFileURL_bufferDestination_,0,2);
    uVar1 = *(undefined4 *)PTR_00336408;
    while (((self->_isRecording[0] & 2) != 0 && ((self->_isRecording[0] & 4) == 0))) {
      _CFRunLoopRunInMode(uVar1,0x9999999a,0x3fb99999);
    }
    _objc_msgSend(self->_soundCaptureOutput,sel_setDelegate_,0);
    pvVar2 = self->_audioTimeTextField;
    self_00 = _objc_msgSend(self,sel_previewSoundObject);
    dVar3 = _objc_msgSend_fpret(self_00,sel_duration);
    _objc_msgSend(self,sel_setSoundDuration_forTextField_,dVar3,pvVar2);
    _objc_msgSend(*(id *)PTR_00336058,sel_stopModalWithCode_,0);
  }
  pvVar2 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
  _objc_msgSend(pvVar2,sel_setLocked_delegate_,0,0);
  return;
}

*/
- (void)stopRecording
{
    if (_isRecording) {
        [self removeTimerForMeasurementSoundDuration];
        _isRecording = 0;
        [_soundCaptureOutput recordToOutputFileURL:nil bufferDestination:QTCaptureFileOutputBufferDestinationOldFile];
        while (_didCaptureMovieFileOutputStartRecording && !_didCaptureMovieFileOutputFinishRecording) {
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, false);
        }
        [_soundCaptureOutput setDelegate:nil];
        [self setSoundDuration:[(HSMovie *)[self previewSoundObject] duration] forTextField:_audioTimeTextField];
        [NSApp stopModalWithCode:0];
    }
    [[HSObjectAssistantController sharedAssistantController] setLocked:NO delegate:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0022196b @ 0022196b, 25 bytes * /

BOOL FUN_0022196b(HSSoundRecordingAssistantPane *self,SEL _cmd)

{
  BOOL BVar1;
  
  BVar1 = -1;
  if ((self->_isRecording[0] & 1) == 0) {
    BVar1 = '\0';
  }
  return BVar1;
}

*/
- (BOOL)isRecording
{
    return _isRecording;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0022349d @ 0022349d, 275 bytes * /

void FUN_0022349d(HSSoundRecordingAssistantPane *self,SEL _cmd,id record)

{
  id pvVar1;
  HSSoundRecordingAssistantPane *self_00;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_isRecording);
  self_00 = self;
  op = sel_stopRecording;
  if ((char)pvVar1 == '\0') {
    _objc_msgSend(self,sel_setSoundDuration_forTextField_,0,0,self->_audioTimeTextField);
    pvVar1 = _objc_msgSend(self,sel_countDownViewController);
    _objc_msgSend(pvVar1,sel_runInView_,self->_soundRecordBackgroundView);
    _objc_msgSend(self,sel_performSelector_withObject_afterDelay_,sel_runSoundRecordingModalSession,
                  0,0,0);
    self_00 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
    op = sel_setLocked_delegate_;
  }
  _objc_msgSend(self_00,op);
  _objc_msgSend(self,sel_validateUserInterface);
  return;
}

*/
- (void)record:(id)aRecord
{
    if ([self isRecording]) {
        [self stopRecording];
    }
    else {
        [self setSoundDuration:0.0 forTextField:_audioTimeTextField];
        [[self countDownViewController] runInView:_soundRecordBackgroundView];
        [self performSelector:@selector(runSoundRecordingModalSession) withObject:nil afterDelay:0.0];
        [[HSObjectAssistantController sharedAssistantController] setLocked:YES delegate:self];
    }
    [self validateUserInterface];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002235b0 @ 002235b0, 977 bytes * /

void FUN_002235b0(HSSoundRecordingAssistantPane *self,SEL _cmd)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  id pvVar4;
  id pvVar5;
  int iVar6;
  byte bVar7;
  
  pvVar2 = _objc_msgSend(self,sel_class);
  pvVar3 = _objc_msgSend(self,sel_isPlaying);
  pvVar5 = self->_playButton;
  if ((char)pvVar3 == '\0') {
    pvVar3 = _objc_msgSend(pvVar2,sel_playButtonImage);
    _objc_msgSend(pvVar5,sel_setImage_,pvVar3);
    pvVar5 = self->_playButton;
    pvVar3 = _objc_msgSend(pvVar2,sel_playButtonAquaImage);
    _objc_msgSend(pvVar5,sel_setAquaAlternateImage_,pvVar3);
    pvVar5 = self->_playButton;
    op = sel_playButtonGraphiteImage;
  }
  else {
    pvVar3 = _objc_msgSend(pvVar2,sel_stopButtonImage);
    _objc_msgSend(pvVar5,sel_setImage_,pvVar3);
    pvVar5 = self->_playButton;
    pvVar3 = _objc_msgSend(pvVar2,sel_stopButtonAquaImage);
    _objc_msgSend(pvVar5,sel_setAquaAlternateImage_,pvVar3);
    pvVar5 = self->_playButton;
    op = sel_stopButtonGraphiteImage;
  }
  pvVar3 = _objc_msgSend(pvVar2,op,pvVar3);
  _objc_msgSend(pvVar5,sel_setGraphiteAlternateImage_,pvVar3);
  pvVar4 = _objc_msgSend(self,sel_isRecording);
  pvVar5 = self->_recordButton;
  if ((char)pvVar4 == '\0') {
    pvVar3 = _objc_msgSend(pvVar2,sel_recordButtonImage,pvVar3);
    _objc_msgSend(pvVar5,sel_setImage_,pvVar3);
    pvVar5 = self->_recordButton;
    pvVar3 = _objc_msgSend(pvVar2,sel_recordButtonAquaImage);
    _objc_msgSend(pvVar5,sel_setAquaAlternateImage_,pvVar3);
    pvVar5 = self->_recordButton;
    pvVar2 = _objc_msgSend(pvVar2,sel_recordButtonGraphiteImage);
  }
  else {
    pvVar3 = _objc_msgSend(pvVar2,sel_stopRecordButtonImage,pvVar3);
    _objc_msgSend(pvVar5,sel_setImage_,pvVar3);
    pvVar5 = self->_recordButton;
    pvVar3 = _objc_msgSend(pvVar2,sel_stopRecordButtonAquaImage);
    _objc_msgSend(pvVar5,sel_setAquaAlternateImage_,pvVar3);
    pvVar5 = self->_recordButton;
    pvVar2 = _objc_msgSend(pvVar2,sel_stopRecordButtonGraphiteImage);
  }
  _objc_msgSend(pvVar5,sel_setGraphiteAlternateImage_,pvVar2);
  pvVar5 = _objc_msgSend(self,sel_isRecording);
  if ((char)pvVar5 == '\0') {
    pvVar5 = _objc_msgSend(self->_countDownViewController,sel_isRunning,pvVar2);
    if ((char)pvVar5 != '\0') goto LAB_00223833;
    bVar7 = 0;
  }
  else {
LAB_00223833:
    bVar7 = 1;
  }
  pvVar2 = _objc_msgSend(self,sel_isPlaying);
  pvVar5 = self->_playButton;
  if (bVar7 == 0) {
    pvVar3 = _objc_msgSend(self,sel_previewSoundObject);
    if (pvVar3 == (id)0x0) goto LAB_00223896;
    cVar1 = '\x01';
  }
  else {
LAB_00223896:
    cVar1 = '\0';
  }
  iVar6 = (int)cVar1;
  _objc_msgSend(pvVar5,sel_setEnabled_,iVar6);
  pvVar5 = self->_recordButton;
  if (((char)pvVar2 == '\0') && (self->_soundCaptureInput != (id)0x0)) {
    pvVar3 = _objc_msgSend(self->_countDownViewController,sel_isRunning,iVar6);
    if ((char)pvVar3 == '\0') {
      cVar1 = '\x01';
      goto LAB_002238ed;
    }
  }
  cVar1 = '\0';
LAB_002238ed:
  _objc_msgSend(pvVar5,sel_setEnabled_,(int)cVar1);
  _objc_msgSend(self->_soundNameTextField,sel_setEnabled_,(uint)((char)pvVar2 == '\0' && bVar7 == 0)
               );
  _objc_msgSend(self->_soundCaptureDevicePopUp,sel_setEnabled_,(int)(char)(bVar7 ^ 1));
  pvVar5 = _objc_msgSend(self,sel_navigationPaneSwitcher);
  _objc_msgSend(pvVar5,sel_validateUserInterface);
  return;
}

*/
- (void)validateUserInterface
{
    Class cls = [self class];
    BOOL busy;
    BOOL playing;

    if ([self isPlaying]) {
        [_playButton setImage:[cls stopButtonImage]];
        [_playButton setAquaAlternateImage:[cls stopButtonAquaImage]];
        [_playButton setGraphiteAlternateImage:[cls stopButtonGraphiteImage]];
    }
    else {
        [_playButton setImage:[cls playButtonImage]];
        [_playButton setAquaAlternateImage:[cls playButtonAquaImage]];
        [_playButton setGraphiteAlternateImage:[cls playButtonGraphiteImage]];
    }
    if ([self isRecording]) {
        [_recordButton setImage:[cls stopRecordButtonImage]];
        [_recordButton setAquaAlternateImage:[cls stopRecordButtonAquaImage]];
        [_recordButton setGraphiteAlternateImage:[cls stopRecordButtonGraphiteImage]];
    }
    else {
        [_recordButton setImage:[cls recordButtonImage]];
        [_recordButton setAquaAlternateImage:[cls recordButtonAquaImage]];
        [_recordButton setGraphiteAlternateImage:[cls recordButtonGraphiteImage]];
    }
    busy = [self isRecording] || [_countDownViewController isRunning];
    playing = [self isPlaying];
    [_playButton setEnabled:!busy && [self previewSoundObject] != nil];
    [_recordButton setEnabled:!playing && _soundCaptureInput != nil && ![_countDownViewController isRunning]];
    [_soundNameTextField setEnabled:!playing && !busy];
    [_soundCaptureDevicePopUp setEnabled:!busy];
    [[self navigationPaneSwitcher] validateUserInterface];
}

- (id)recordedSoundFilePath
{
    id pvVar1;

    pvVar1 = _recordedSoundFilePath;
    if (pvVar1 == nil) {
        pvVar1 = [[NSString extraCreateUniqueFilename:[[[HSPathsProvider sharedPathsProvider] temporaryFolder] stringByAppendingPathComponent:[[HSUID UID] stringValue]] extension:@"aac"] retain];
        _recordedSoundFilePath = pvVar1;
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00223a56 @ 00223a56, 836 bytes * /

void FUN_00223a56(HSSoundRecordingAssistantPane *self,SEL _cmd,id setSoundCaptureDevice)

{
  id pvVar1;
  id pvVar2;
  HSSoundRecordingAssistantPane *pHVar3;
  HSSoundRecordingAssistantPane *pHVar4;
  undefined4 uVar5;
  cfstringStruct *pcVar6;
  undefined4 uVar7;
  
  pvVar1 = _objc_msgSend(self->_soundCaptureInput,sel_device);
  pvVar1 = _objc_msgSend(pvVar1,sel_uniqueID);
  pvVar2 = _objc_msgSend(setSoundCaptureDevice,sel_uniqueID);
  pvVar1 = _objc_msgSend(pvVar1,sel_isEqual_,pvVar2);
  if ((char)pvVar1 != '\0') {
    return;
  }
  pvVar1 = _objc_msgSend(self,sel_soundCaptureSession,pvVar2);
  if (self->_soundCaptureInput != (id)0x0) {
    pvVar2 = _objc_msgSend(self->_soundCaptureInput,sel_device,pvVar2);
    _objc_msgSend(pvVar2,sel_removeObserver_forKeyPath_,self,&cfstr_inUseByAnotherApplication);
    _objc_msgSend(pvVar2,sel_removeObserver_forKeyPath_,self,&cfstr_suspended);
    _objc_msgSend(pvVar2,sel_removeObserver_forKeyPath_,self,&cfstr_connected);
    _objc_msgSend(pvVar1,sel_removeInput_,self->_soundCaptureInput);
    pvVar2 = _objc_msgSend(self->_soundCaptureInput,sel_device);
    _objc_msgSend(pvVar2,sel_close);
    _objc_msgSend(self->_soundCaptureInput,sel_release);
    self->_soundCaptureInput = (id)0x0;
  }
  pHVar4 = (HSSoundRecordingAssistantPane *)0x0;
  pvVar2 = _objc_msgSend(setSoundCaptureDevice,sel_open_,0);
  if ((char)pvVar2 == '\0') {
LAB_00223d61:
    pvVar2 = self->_soundCaptureInput;
  }
  else {
    pvVar2 = _objc_msgSend(cls_QTCaptureDeviceInput,sel_alloc,pHVar4);
    pHVar4 = setSoundCaptureDevice;
    pHVar3 = _objc_msgSend(pvVar2,sel_initWithDevice_,setSoundCaptureDevice);
    self->_soundCaptureInput = pHVar3;
    pvVar2 = (id)0x0;
    if (pHVar3 != (HSSoundRecordingAssistantPane *)0x0) {
      uVar5 = 0;
      pvVar2 = _objc_msgSend(pvVar1,sel_addInput_error_,pHVar3,0);
      if ((char)pvVar2 == '\0') {
        _objc_msgSend(setSoundCaptureDevice,sel_close,pHVar3,uVar5);
        _objc_msgSend(self->_soundCaptureInput,sel_release);
        self->_soundCaptureInput = (id)0x0;
        goto LAB_00223d6b;
      }
      _objc_msgSend(setSoundCaptureDevice,sel_addObserver_forKeyPath_options_context_,self,
                    &cfstr_inUseByAnotherApplication,0,0);
      _objc_msgSend(setSoundCaptureDevice,sel_addObserver_forKeyPath_options_context_,self,
                    &cfstr_suspended,0,0);
      pcVar6 = &cfstr_connected;
      uVar7 = 0;
      uVar5 = 0;
      pHVar4 = self;
      _objc_msgSend(setSoundCaptureDevice,sel_addObserver_forKeyPath_options_context_,self,
                    &cfstr_connected,0,0);
      pvVar2 = _objc_msgSend(pvVar1,sel_isRunning);
      if ((char)pvVar2 == '\0') {
        _objc_msgSend(pvVar1,sel_startRunning,pHVar4,pcVar6,uVar5,uVar7);
      }
      _objc_msgSend(self,sel_installTimerForObservingInputAudioLevel,pHVar4,pcVar6,uVar5,uVar7);
      goto LAB_00223d61;
    }
  }
  pHVar3 = pHVar4;
  if (pvVar2 != (id)0x0) {
    return;
  }
LAB_00223d6b:
  _objc_msgSend(pvVar1,sel_stopRunning,pHVar3);
  _objc_msgSend(self,sel_removeTimerForObservingInputAudioLevel);
  return;
}

*/
- (void)setSoundCaptureDevice:(id)aDevice
{
    QTCaptureSession *session;
    QTCaptureDevice *device;

    if ([[[_soundCaptureInput device] uniqueID] isEqual:[(QTCaptureDevice *)aDevice uniqueID]]) {
        return;
    }
    session = [self soundCaptureSession];
    if (_soundCaptureInput != nil) {
        device = [_soundCaptureInput device];
        [device removeObserver:self forKeyPath:@"inUseByAnotherApplication"];
        [device removeObserver:self forKeyPath:@"suspended"];
        [device removeObserver:self forKeyPath:@"connected"];
        [session removeInput:_soundCaptureInput];
        [[_soundCaptureInput device] close];
        [_soundCaptureInput release];
        _soundCaptureInput = nil;
    }
    if ([(QTCaptureDevice *)aDevice open:NULL]) {
        _soundCaptureInput = [[QTCaptureDeviceInput alloc] initWithDevice:aDevice];
        if (_soundCaptureInput != nil) {
            if (![session addInput:_soundCaptureInput error:NULL]) {
                [aDevice close];
                [_soundCaptureInput release];
                _soundCaptureInput = nil;
            }
            else {
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
    if (_soundCaptureInput == nil) {
        [session stopRunning];
        [self removeTimerForObservingInputAudioLevel];
    }
}

- (void)destroySoundCaptureSession
{
    if ([_soundCaptureSession isRunning]) {
        [_soundCaptureSession stopRunning];
    }
    [_soundCaptureSession removeOutput:_soundCaptureOutput];
    [_soundCaptureOutput release];
    _soundCaptureOutput = nil;
    [_soundCaptureSession release];
    _soundCaptureSession = nil;
}

- (id)soundCaptureSession
{
    id pvVar1;
    id pvVar1_3;

    pvVar1 = _soundCaptureSession;
    if (pvVar1 == nil) {
        _soundCaptureSession = [QTCaptureSession new];
        pvVar1_3 = [QTCaptureMovieFileOutput new];
        _soundCaptureOutput = pvVar1_3;
        if (![_soundCaptureSession addOutput:pvVar1_3 error:nil]) {
            [_soundCaptureOutput release];
            _soundCaptureOutput = nil;
            [_soundCaptureSession release];
            _soundCaptureSession = nil;
            pvVar1 = nil;
        }
        else {
            pvVar1 = _soundCaptureSession;
        }
    }
    return pvVar1;
}

- (id)soundCaptureDeviceList
{
    id pvVar1;
    id pvVar1_3;

    pvVar1 = _soundCaptureDeviceList;
    if (pvVar1 == nil) {
        pvVar1_3 = [[NSArray alloc] initWithObjects:QTMediaTypeSound, QTMediaTypeMuxed, nil];
        _soundCaptureDeviceList = [[HSCaptureDeviceList captureDeviceListForMediaTypes:pvVar1_3] retain];
        [pvVar1_3 release];
        pvVar1 = _soundCaptureDeviceList;
    }
    return pvVar1;
}

- (void)selectDefaultDevice
{
    QTCaptureDevice *self_01;

    self_01 = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeSound];
    if (self_01 == nil) {
        self_01 = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeMuxed];
    }
    if (self_01 != nil) {
        [_soundCaptureDevicePopUp selectItemWithTitle:[self_01 localizedDisplayName]];
        [self setSoundCaptureDevice:self_01];
    }
}

- (id)countDownViewController
{
    HSCountDownViewController *pHVar1;
    HSCountDownViewController *pHVar1_2;

    pHVar1 = _countDownViewController;
    if (pHVar1 == nil) {
        pHVar1_2 = [HSCountDownViewController new];
        _countDownViewController = pHVar1_2;
        [pHVar1_2 setDelegate:self];
        pHVar1 = _countDownViewController;
    }
    return pHVar1;
}

- (void)storeSelectedDeviceInUserDefaults
{
    [[NSUserDefaults standardUserDefaults] setObject:[[_soundCaptureDevicePopUp selectedItem] title] forKey:HSAudioInputDeviceNameKey];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00224171 @ 00224171, 494 bytes * /

BOOL FUN_00224171(HSSoundRecordingAssistantPane *self,SEL _cmd)

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
      pvVar3 = _objc_msgSend(self->_soundCaptureDevicePopUp,sel_indexOfSelectedItem,pvVar2,pcVar7,
                             pcVar8);
      pvVar2 = pvVar1;
      _objc_msgSend(self->_soundCaptureDevicePopUp,sel_selectItemWithTitle_,pvVar1);
      pvVar4 = _objc_msgSend(self->_soundCaptureDevicePopUp,sel_indexOfSelectedItem);
      if (pvVar4 == (id)0xffffffff) {
        _objc_msgSend(self->_soundCaptureDevicePopUp,sel_selectItemAtIndex_,pvVar3);
        return '\0';
      }
      pvVar2 = _objc_msgSend(self,sel_soundCaptureDeviceList,pvVar2);
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
      _objc_msgSend(self,sel_setSoundCaptureDevice_,pvVar1);
      return '\x01';
    }
  }
  return '\0';
}

*/
- (BOOL)selectDeviceFromUserDefaults
{
    NSString *name = [[NSUserDefaults standardUserDefaults] stringForKey:HSAudioInputDeviceNameKey];
    if (name == nil || [name isEqualToString:[[NSBundle mainBundle] localizedStringForKey:@"NoneDeviceMenuItemName" value:@"" table:@"AssistantPanes"]]) {
        return NO;
    }
    NSInteger previousIndex = [_soundCaptureDevicePopUp indexOfSelectedItem];
    [_soundCaptureDevicePopUp selectItemWithTitle:name];
    if ([_soundCaptureDevicePopUp indexOfSelectedItem] == -1) {
        [_soundCaptureDevicePopUp selectItemAtIndex:previousIndex];
        return NO;
    }
    HSCaptureDeviceList *list = [self soundCaptureDeviceList];
    NSUInteger count = [list captureDeviceCount];
    for (NSUInteger i = 0; i < count; i++) {
        if ([name isEqualToString:[list localizedDisplayNameForCaptureDeviceAtIndex:i]]) {
            [self setSoundCaptureDevice:[list captureDeviceAtIndex:i]];
            break;
        }
    }
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0022435f @ 0022435f, 1465 bytes * /

void FUN_0022435f(HSSoundRecordingAssistantPane *self,SEL _cmd,id paneDidOK)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  HSSoundRecordingAssistantPane *pHVar4;
  id pvVar5;
  HSSoundRecordingAssistantPane *pHVar6;
  id self_00;
  SEL op;
  HSSoundRecordingAssistantPane *pHVar7;
  undefined4 uVar8;
  
  pvVar2 = _objc_msgSend(self->_soundNameTextField,sel_stringValue);
  pvVar2 = _objc_msgSend(pvVar2,sel_length);
  if ((pvVar2 == (id)0x0) ||
     (pvVar2 = _objc_msgSend(self,sel_previewSoundObject), pvVar2 == (id)0x0)) goto LAB_002248c3;
  pvVar2 = _objc_msgSend(self,sel_stack);
  pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_0038369c);
  pvVar3 = _objc_msgSend(self->_soundNameTextField,sel_stringValue);
  pvVar2 = _objc_msgSend(pvVar2,sel_stackContainsSoundMediaWithName_,pvVar3);
  if ((char)pvVar2 != '\0') {
    pvVar2 = _objc_msgSend(cls_HSAlert,sel_alloc,pvVar3);
    pvVar2 = _objc_msgSend(pvVar2,sel_init);
    pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
    pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_SoundExistsBody,
                           &cfstr_empty,&cfstr_Alerts);
    _objc_msgSend(pvVar2,sel_setInformativeText_,pvVar3);
    pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_SoundExistsTitle,
                           &cfstr_empty,&cfstr_Alerts);
    _objc_msgSend(pvVar2,sel_setMessageText_,pvVar3);
    pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_Replace,&cfstr_empty
                           ,&cfstr_Localizable);
    _objc_msgSend(pvVar2,sel_addButtonWithTitle_,pvVar3);
    pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_Cancel,&cfstr_empty,
                           &cfstr_Localizable);
    _objc_msgSend(pvVar2,sel_addButtonWithTitle_,pvVar3);
    pvVar2 = _objc_msgSend(pvVar2,sel_runModal);
    if (pvVar2 != (id)0x3e8) {
      return;
    }
  }
  pHVar4 = _objc_msgSend(self,sel_recordedSoundFilePath,pvVar3);
  pvVar2 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
  pHVar7 = pHVar4;
  pvVar3 = _objc_msgSend(pvVar2,sel_fileExistsAtPath_,pHVar4);
  if ((char)pvVar3 != '\0') {
    pvVar3 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider,pHVar7);
    pvVar3 = _objc_msgSend(pvVar3,sel_temporaryFolder);
    pvVar5 = _objc_msgSend(cls_HSUID,sel_UID);
    pvVar5 = _objc_msgSend(pvVar5,sel_stringValue);
    pHVar6 = _objc_msgSend(pvVar3,sel_stringByAppendingPathComponent_,pvVar5);
    _objc_msgSend(pvVar2,sel_copyPath_toPath_handler_,pHVar4,pHVar6,0);
    puVar1 = cls_HSNewMedia;
    pvVar3 = _objc_msgSend(self->_soundNameTextField,sel_stringValue);
    uVar8 = 1;
    pHVar7 = pHVar6;
    pvVar5 = _objc_msgSend(puVar1,sel_mediaWithPath_name_removeWhenDone_,pHVar6,pvVar3,1);
    if (pvVar5 == (id)0x0) {
      pHVar7 = pHVar6;
      pvVar3 = _objc_msgSend(pvVar2,sel_isDeletableFileAtPath_,pHVar6,pvVar3,uVar8);
      if ((char)pvVar3 == '\0') goto LAB_00224891;
      pvVar3 = (id)0x0;
      op = sel_removeFileAtPath_handler_;
    }
    else {
      pvVar2 = _objc_msgSend(cls_HSMovie,sel_alloc,pHVar7,pvVar3,uVar8);
      puVar1 = cls_NSURL;
      pvVar3 = _objc_msgSend(pvVar5,sel_fullPathToMediaFileCreateIfNeeded_,1);
      pHVar6 = _objc_msgSend(puVar1,sel_fileURLWithPath_,pvVar3);
      pvVar3 = (id)0x0;
      pvVar2 = _objc_msgSend(pvVar2,sel_initWithURL_error_,pHVar6,0);
      op = sel_release;
      if (pvVar2 != (id)0x0) {
        pvVar3 = _objc_msgSend(cls_HSSoundItem,sel_alloc,pHVar6,pvVar3);
        pvVar5 = _objc_msgSend(pvVar5,sel_mediaUID);
        pvVar5 = _objc_msgSend(pvVar3,sel_initWithMediaUID_andApplyOptionsFromSound_,pvVar5,pvVar2);
        self_00 = _objc_msgSend(self,sel_soundRecordingAssistantPaneDelegate);
        pHVar6 = self;
        pvVar3 = pvVar5;
        _objc_msgSend(self_00,sel_soundRecordingAssistantPane_didRecordSoundItem_,self,pvVar5);
        _objc_msgSend(pvVar5,sel_release);
        op = sel_release;
      }
    }
    _objc_msgSend(pvVar2,op,pHVar6,pvVar3,uVar8);
    pHVar7 = pHVar6;
  }
LAB_00224891:
  pvVar2 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController,pHVar7);
  _objc_msgSend(pvVar2,sel_setIsRecordingSound_,0);
LAB_002248c3:
  _objc_msgSend(self,sel_storeSelectedDeviceInUserDefaults);
  pvVar2 = _objc_msgSend(self,sel_objectAssistantNavigationController);
  _objc_msgSend(pvVar2,sel_popAllTopViewControllersWithIdentifier_animate_,
                *(undefined4 *)PTR_PTR_00342680,1);
  return;
}

*/
- (void)paneDidOK:(id)aOK
{
    if ([[_soundNameTextField stringValue] length] != 0 && [self previewSoundObject] != nil) {
        if ([[[self stack] queryHyperInterface:@protocol(HSStackSoundStorage)] stackContainsSoundMediaWithName:[_soundNameTextField stringValue]]) {
            HSAlert *alert = [[[HSAlert alloc] init] autorelease];
            [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"SoundExistsBody" value:@"" table:@"Alerts"]];
            [alert setMessageText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"SoundExistsTitle" value:@"" table:@"Alerts"]];
            [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Replace" value:@"" table:@"Localizable"]];
            [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Cancel" value:@"" table:@"Localizable"]];
            if ([alert runModal] != NSAlertFirstButtonReturn) {
                return;
            }
        }
        NSString *recordedPath = [self recordedSoundFilePath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:recordedPath]) {
            NSString *copyPath = [[[HSPathsProvider sharedPathsProvider] temporaryFolder] stringByAppendingPathComponent:[[HSUID UID] stringValue]];
            [fileManager copyItemAtPath:recordedPath toPath:copyPath error:NULL];
            id media = [HSNewMedia mediaWithPath:copyPath name:[_soundNameTextField stringValue] removeWhenDone:YES];
            if (media == nil) {
                if ([fileManager isDeletableFileAtPath:copyPath]) {
                    [fileManager removeItemAtPath:copyPath error:NULL];
                }
            }
            else {
                HSMovie *movie = [[HSMovie alloc] initWithURL:[NSURL fileURLWithPath:[media fullPathToMediaFileCreateIfNeeded:YES]] error:NULL];
                if (movie != nil) {
                    HSSoundItem *item = [[HSSoundItem alloc] initWithMediaUID:[media mediaUID] andApplyOptionsFromSound:movie];
                    [[self soundRecordingAssistantPaneDelegate] soundRecordingAssistantPane:self didRecordSoundItem:item];
                    [item release];
                }
                [movie release];
            }
        }
        [[HSObjectAssistantController sharedAssistantController] setIsRecordingSound:NO];
    }
    [self storeSelectedDeviceInUserDefaults];
    [[self objectAssistantNavigationController] popAllTopViewControllersWithIdentifier:HSPickSoundSourcePaneIdentifier animate:YES];
}

- (void)paneDidCancel:(id)aCancel
{
    [[HSObjectAssistantController sharedAssistantController] setIsRecordingSound:NO];
    [self dismiss:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0022497a @ 0022497a, 122 bytes * /

BOOL FUN_0022497a(HSSoundRecordingAssistantPane *self,SEL _cmd,
                 id shouldEnableOKButtonInNavigationPaneSwitcher)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_previewSoundObject);
  if (pvVar1 != (id)0x0) {
    pvVar1 = _objc_msgSend(self->_soundNameTextField,sel_stringValue);
    pvVar1 = _objc_msgSend(pvVar1,sel_length);
    if (pvVar1 != (id)0x0) {
      pvVar1 = _objc_msgSend(self,sel_isRecording);
      return (char)pvVar1 == '\0';
    }
  }
  return '\0';
}

*/
- (BOOL)shouldEnableOKButtonInNavigationPaneSwitcher:(id)aSwitcher
{
    return [self previewSoundObject] != nil && [[_soundNameTextField stringValue] length] != 0 && ![self isRecording];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002249f4 @ 002249f4, 502 bytes * /

void FUN_002249f4(HSSoundRecordingAssistantPane *self,SEL _cmd,BOOL viewWillDisappear)

{
  id pvVar1;
  id pvVar2;
  undefined4 uVar3;
  HSSoundRecordingAssistantPane *local_1c;
  undefined *local_18;
  
  pvVar1 = _objc_msgSend(self,sel_countDownViewController);
  pvVar1 = _objc_msgSend(pvVar1,sel_isRunning);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(self,sel_countDownViewController);
    _objc_msgSend(pvVar1,sel_stopRun);
  }
  pvVar1 = _objc_msgSend(self,sel_isRecording);
  if ((char)pvVar1 != '\0') {
    _objc_msgSend(self,sel_stopRecording);
  }
  pvVar1 = _objc_msgSend(self,sel_isPlaying);
  if ((char)pvVar1 != '\0') {
    _objc_msgSend(self,sel_stopPlaying);
  }
  _objc_msgSend(self,sel_removeTimerForObservingInputAudioLevel);
  _objc_msgSend(self,sel_removeTimerForMeasurementSoundDuration);
  _objc_msgSend(*(id *)PTR_00336058,sel_stopModalWithCode_,0);
  pvVar1 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
  _objc_msgSend(pvVar1,sel_setLocked_delegate_,0,0);
  pvVar1 = _objc_msgSend(self,sel_soundCaptureDeviceList);
  pvVar2 = _objc_msgSend(self->_soundCaptureDevicePopUp,sel_menu);
  _objc_msgSend(pvVar1,sel_detachMenu_,pvVar2);
  _objc_msgSend(self,sel_setSoundCaptureDevice_,0);
  pvVar1 = _objc_msgSend(self,sel_assistant);
  uVar3 = 0xffffffff;
  if ((self->_isRecording[0] & 8) == 0) {
    uVar3 = 0;
  }
  _objc_msgSend(pvVar1,sel_setSupportsSettingsOnTheSpotMode_,uVar3);
  local_1c = self;
  local_18 = PTR_s_HSActionAssistantPane_00354e90;
  _objc_msgSendSuper(&local_1c,sel_viewWillDisappear_,(int)viewWillDisappear);
  return;
}

*/
- (void)viewWillDisappear:(BOOL)aDisappear
{
    if ([[self countDownViewController] isRunning]) {
        [[self countDownViewController] stopRun];
    }
    if ([self isRecording]) {
        [self stopRecording];
    }
    if ([self isPlaying]) {
        [self stopPlaying];
    }
    [self removeTimerForObservingInputAudioLevel];
    [self removeTimerForMeasurementSoundDuration];
    [NSApp stopModalWithCode:0];
    [[HSObjectAssistantController sharedAssistantController] setLocked:NO delegate:nil];
    [[self soundCaptureDeviceList] detachMenu:[_soundCaptureDevicePopUp menu]];
    [self setSoundCaptureDevice:nil];
    [[self assistant] setSupportsSettingsOnTheSpotMode:_supportSettingsOnTheSpotMode];
    [super viewWillDisappear:aDisappear];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00224bea @ 00224bea, 367 bytes * /

void FUN_00224bea(HSSoundRecordingAssistantPane *self,SEL _cmd,BOOL viewWillAppear)

{
  id pvVar1;
  id pvVar2;
  HSSoundRecordingAssistantPane *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSActionAssistantPane_00354e90;
  _objc_msgSendSuper(&local_1c,sel_viewWillAppear_,(int)viewWillAppear);
  pvVar2 = self->_soundNameTextField;
  pvVar1 = _objc_msgSend(self,sel_localizedUniqueRecordName);
  _objc_msgSend(pvVar2,sel_setStringValue_,pvVar1);
  pvVar2 = _objc_msgSend(self,sel_soundCaptureDeviceList);
  pvVar1 = _objc_msgSend(self->_soundCaptureDevicePopUp,sel_menu);
  _objc_msgSend(pvVar2,sel_attachMenu_,pvVar1);
  pvVar2 = _objc_msgSend(self->_soundCaptureDevicePopUp,sel_numberOfItems);
  if (0 < (int)pvVar2) {
    pvVar2 = _objc_msgSend(self,sel_selectDeviceFromUserDefaults,pvVar1);
    if ((char)pvVar2 == '\0') {
      _objc_msgSend(self,sel_selectDefaultDevice,pvVar1);
    }
  }
  pvVar2 = _objc_msgSend(self,sel_assistant,pvVar1);
  pvVar2 = _objc_msgSend(pvVar2,sel_supportsSettingsOnTheSpotMode);
  self->_isRecording[0] = self->_isRecording[0] & 0xf7 | ((byte)pvVar2 & 1) << 3;
  pvVar2 = _objc_msgSend(self,sel_assistant);
  _objc_msgSend(pvVar2,sel_setSupportsSettingsOnTheSpotMode_,0);
  _objc_msgSend(self,sel_validateUserInterface);
  return;
}

*/
- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [_soundNameTextField setStringValue:[self localizedUniqueRecordName]];
    [[self soundCaptureDeviceList] attachMenu:[_soundCaptureDevicePopUp menu]];
    if ([_soundCaptureDevicePopUp numberOfItems] > 0 && ![self selectDeviceFromUserDefaults]) {
        [self selectDefaultDevice];
    }
    _supportSettingsOnTheSpotMode = [[self assistant] supportsSettingsOnTheSpotMode] ? 1 : 0;
    [[self assistant] setSupportsSettingsOnTheSpotMode:NO];
    [self validateUserInterface];
}

- (void)viewDidLoad
{
    [_levelIndicator setMaxValue:10.0];
    [_levelIndicator setWarningValue:5.0];
    [_levelIndicator setCriticalValue:9.0];
    [_soundRecordBackgroundView setImage:[NSImage imageNamed:@"Countdown"]];
    [_soundNameTextField setDelegate:self];
    [super viewDidLoad];
}

- (id)helpTopicKey
{
    return @"HSPlaySound";
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
    return [HSPlaySoundAction actionType];
}

- (Class)applierClass
{
    return Nil;
}

- (void)setSoundRecordingAssistantPaneDelegate:(id)aDelegate
{
    _soundRecordingAssistantPaneDelegate = aDelegate;
}

- (id)soundRecordingAssistantPaneDelegate
{
    return _soundRecordingAssistantPaneDelegate;
}

- (BOOL)requiresDarkBottomArea
{
    return YES;
}

- (void)dealloc
{
    id self_00;
    int uVar2;

    self_00 = [HSObjectAssistantController sharedAssistantController];
    uVar2 = 0;
    [self_00 setIsRecordingSound:NO];
    [self removeTimerForMeasurementSoundDuration];
    [self removeTimerForObservingInputAudioLevel];
    if ([_soundNameTextField delegate] == self) {
        uVar2 = 0;
        [_soundNameTextField setDelegate:0];
    }
    if ([_countDownViewController delegate] == self) {
        uVar2 = 0;
        [_countDownViewController setDelegate:0];
    }
    [_countDownViewController release];
    if ([_navigationPaneSwitcher delegate] == self) {
        uVar2 = 0;
        [_navigationPaneSwitcher setDelegate:0];
    }
    [_navigationPaneSwitcher release];
    [self setSoundCaptureDevice:nil];
    [self destroySoundCaptureSession];
    [self invalidatePreviewSoundObject];
    [self removeRecorderSoundFile];
    [_soundCaptureDeviceList release];
    [_recordedSoundFilePath release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"SoundRecordingAssistantPane"];
    return self;
}

@end

