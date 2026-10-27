#import "HSHyperCastingModePane.h"

@implementation HSHyperCastingModePane

/* i386 ivar offsets: _contentView=0x5c, _userInformationContentView=0x60, _currentModeInformationTextField=0x64, _recordedTimeTextField=0x68, _volumeLevelIndicator=0x6c, _audioDevicePopUpButton=0x70, _timerForObservingInputAudioLevel=0x74, _timerForMeasurementRecordMovieTime=0x78, _countDownViewController=0x7c, _navigationPaneSwitcher=0x80, _audioDeviceList=0x84, _noneAudioDeviceMenuItem=0x88, _recordingProvider=0x8c, _hyperCastingModePaneDelegate=0x90, _soundCaptureSession=0x94, _soundCaptureInput=0x98, _soundCaptureOutput=0x9c */

- (void)captureDeviceListDidUpdate:(id)aUpdate
{
    [self addNoneAudioDeviceMenuItem];
}

- (void)currentAudioDeviceDidChange:(id)aChange
{
    id pvVar1_2;

    pvVar1_2 = [[_audioDevicePopUpButton selectedItem] representedObject];
    [_recordingProvider setVoiceInputDevice:pvVar1_2];
    [self setSoundCaptureDevice:pvVar1_2];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0023e9e0 @ 0023e9e0, 136 bytes * /

void FUN_0023e9e0(HSHyperCastingModePane *self,SEL _cmd)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_countDownViewController);
  pvVar1 = _objc_msgSend(pvVar1,sel_isRunning);
  if ((char)pvVar1 == '\0') {
    _objc_msgSend(self,sel_removeTimerForMeasurementMovieDuration);
    pvVar1 = self->_recordingProvider;
    op = sel_cancelRecording;
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_countDownViewController);
    op = sel_stopRun;
  }
  _objc_msgSend(pvVar1,op);
  return;
}

*/
- (void)cancelRecording
{
    if ([[self countDownViewController] isRunning]) {
        [[self countDownViewController] stopRun];
    }
    else {
        [self removeTimerForMeasurementMovieDuration];
        [_recordingProvider cancelRecording];
    }
}

- (void)stopRecording
{
    id pvVar1_4;

    if (![[self countDownViewController] isRunning]) {
        if (![_recordingProvider isRecording]) {
            return;
        }
        [self removeTimerForMeasurementMovieDuration];
        [_recordingProvider stopRecording];
        pvVar1_4 = _currentModeInformationTextField;
    }
    else {
        [[self countDownViewController] stopRun];
        pvVar1_4 = _currentModeInformationTextField;
    }
    [pvVar1_4 setHidden:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0023eb41 @ 0023eb41, 174 bytes * /

BOOL FUN_0023eb41(HSHyperCastingModePane *self,SEL _cmd)

{
  id pvVar1;
  bool bVar2;
  
  pvVar1 = _objc_msgSend(self->_recordingProvider,sel_prepareToStart);
  bVar2 = (char)pvVar1 != '\0';
  if (bVar2) {
    _objc_msgSend(self,sel_setMovieDuration_forTextField_,0,0,self->_recordedTimeTextField);
    pvVar1 = _objc_msgSend(self,sel_countDownViewController);
    _objc_msgSend(pvVar1,sel_runInView_,self->_userInformationContentView);
    _objc_msgSend(self->_currentModeInformationTextField,sel_setHidden_,0);
  }
  return bVar2;
}

*/
- (BOOL)startRecording
{
    BOOL prepared = [_recordingProvider prepareToStart];
    if (prepared) {
        [self setMovieDuration:0.0 forTextField:_recordedTimeTextField];
        [[self countDownViewController] runInView:_userInformationContentView];
        [_currentModeInformationTextField setHidden:NO];
    }
    return prepared;
}

- (BOOL)isRecording
{
    BOOL bVar2;

    if (![_recordingProvider isRecording]) {
        bVar2 = [[self countDownViewController] isRunning];
    }
    else {
        bVar2 = YES;
    }
    return bVar2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0023ec56 @ 0023ec56, 548 bytes * /

void FUN_0023ec56(HSHyperCastingModePane *self,SEL _cmd,id updateIndicatorState)

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
  undefined8 in_stack_ffffffac;
  uint uVar12;
  longlong lVar11;
  undefined4 uVar13;
  uint local_30;
  float local_24;
  
  if (self->_soundCaptureOutput == (id)0x0) {
    return;
  }
  pvVar3 = _objc_msgSend(self->_soundCaptureOutput,sel_connections);
  pvVar4 = _objc_msgSend(pvVar3,sel_count);
  uVar12 = (uint)((ulonglong)in_stack_ffffffac >> 0x20);
  if (pvVar4 == (id)0x0) {
    pvVar3 = self->_volumeLevelIndicator;
  }
  else {
    uVar1 = *(undefined4 *)PTR_00336404;
    local_24 = 0.0;
    local_30 = 0;
    uVar2 = *(undefined4 *)PTR_003363fc;
    pvVar8 = (id)0x0;
    do {
      uVar13 = (undefined4)((ulonglong)in_stack_ffffffac >> 0x20);
      pvVar5 = _objc_msgSend(pvVar3,sel_objectAtIndex_,pvVar8);
      pvVar6 = _objc_msgSend(pvVar5,sel_mediaType);
      in_stack_ffffffac = CONCAT44(uVar13,uVar1);
      pvVar6 = _objc_msgSend(pvVar6,sel_isEqualToString_,uVar1);
      if ((char)pvVar6 != '\0') {
        in_stack_ffffffac = CONCAT44((int)((ulonglong)in_stack_ffffffac >> 0x20),uVar2);
        pvVar5 = _objc_msgSend(pvVar5,sel_attributeForKey_,uVar2);
        pvVar6 = _objc_msgSend(pvVar5,sel_count);
        if (pvVar6 != (id)0x0) {
          if (pvVar6 < (id)0x2) {
            pvVar6 = (id)0x1;
          }
          pvVar7 = (id)0x0;
          do {
            in_stack_ffffffac = CONCAT44((int)((ulonglong)in_stack_ffffffac >> 0x20),pvVar7);
            self_00 = _objc_msgSend(pvVar5,sel_objectAtIndex_,pvVar7);
            dVar10 = _objc_msgSend_fpret(self_00,sel_floatValue);
            pvVar7 = (id)((int)pvVar7 + 1);
            local_24 = local_24 + (float)dVar10;
          } while (pvVar6 != pvVar7);
          local_30 = local_30 + (int)pvVar6;
        }
      }
      uVar12 = (uint)((ulonglong)in_stack_ffffffac >> 0x20);
      pvVar8 = (id)((int)pvVar8 + 1);
    } while (pvVar8 < pvVar4);
    pvVar3 = self->_volumeLevelIndicator;
    if (local_30 != 0) {
      dVar10 = (double)(local_24 /
                       (float)((double)((ulonglong)local_30 | 0x4330000000000000) -
                              4503599627370496.0)) * 0.05;
      lVar9 = (longdouble)_pow(0x4024000000000000,dVar10);
      lVar11 = CONCAT44((int)((ulonglong)dVar10 >> 0x20),(float)((double)lVar9 * 10.0));
      goto LAB_0023ee6d;
    }
  }
  lVar11 = (ulonglong)uVar12 << 0x20;
LAB_0023ee6d:
  _objc_msgSend(pvVar3,sel_setValue_,lVar11);
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
    [_volumeLevelIndicator setValue:value];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0023ee7a @ 0023ee7a, 369 bytes * /

void FUN_0023ee7a(HSHyperCastingModePane *self,SEL _cmd)

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
/* FUN_0023f038 @ 0023f038, 565 bytes * /

void FUN_0023f038(HSHyperCastingModePane *self,SEL _cmd,id setSoundCaptureDevice)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  undefined4 uVar5;
  
  pvVar1 = _objc_msgSend(self->_soundCaptureInput,sel_device);
  pvVar1 = _objc_msgSend(pvVar1,sel_uniqueID);
  pvVar2 = _objc_msgSend(setSoundCaptureDevice,sel_uniqueID);
  pvVar1 = _objc_msgSend(pvVar1,sel_isEqual_,pvVar2);
  if ((char)pvVar1 != '\0') {
    return;
  }
  pvVar1 = _objc_msgSend(self,sel_soundCaptureSession,pvVar2);
  if (self->_soundCaptureInput != (id)0x0) {
    _objc_msgSend(pvVar1,sel_removeInput_,self->_soundCaptureInput);
    pvVar2 = _objc_msgSend(self->_soundCaptureInput,sel_device);
    _objc_msgSend(pvVar2,sel_close);
    _objc_msgSend(self->_soundCaptureInput,sel_release);
    self->_soundCaptureInput = (id)0x0;
  }
  pvVar3 = (id)0x0;
  pvVar2 = _objc_msgSend(setSoundCaptureDevice,sel_open_,0);
  if ((char)pvVar2 == '\0') {
LAB_0023f231:
    pvVar2 = self->_soundCaptureInput;
    pvVar4 = pvVar3;
  }
  else {
    pvVar2 = _objc_msgSend(cls_QTCaptureDeviceInput,sel_alloc,pvVar3);
    pvVar4 = setSoundCaptureDevice;
    pvVar3 = _objc_msgSend(pvVar2,sel_initWithDevice_,setSoundCaptureDevice);
    self->_soundCaptureInput = pvVar3;
    pvVar2 = (id)0x0;
    if (pvVar3 != (id)0x0) {
      uVar5 = 0;
      pvVar2 = _objc_msgSend(pvVar1,sel_addInput_error_,pvVar3,0);
      if ((char)pvVar2 == '\0') {
        _objc_msgSend(setSoundCaptureDevice,sel_close,pvVar3,uVar5);
        _objc_msgSend(self->_soundCaptureInput,sel_release);
        self->_soundCaptureInput = (id)0x0;
        goto LAB_0023f23e;
      }
      pvVar2 = _objc_msgSend(pvVar1,sel_isRunning,pvVar3,uVar5);
      if ((char)pvVar2 == '\0') {
        _objc_msgSend(pvVar1,sel_startRunning,pvVar3,uVar5);
      }
      _objc_msgSend(self,sel_installTimerForObservingInputAudioLevel,pvVar3,uVar5);
      goto LAB_0023f231;
    }
  }
  pvVar3 = pvVar4;
  if (pvVar2 != (id)0x0) {
    return;
  }
LAB_0023f23e:
  _objc_msgSend(pvVar1,sel_stopRunning,pvVar3);
  _objc_msgSend(self,sel_removeTimerForObservingInputAudioLevel);
  return;
}

*/
- (void)setSoundCaptureDevice:(id)aDevice
{
    if ([[[_soundCaptureInput device] uniqueID] isEqual:[(QTCaptureDevice *)aDevice uniqueID]]) {
        return;
    }
    QTCaptureSession *session = [self soundCaptureSession];
    if (_soundCaptureInput != nil) {
        [session removeInput:_soundCaptureInput];
        [[_soundCaptureInput device] close];
        [_soundCaptureInput release];
        _soundCaptureInput = nil;
    }
    if ([(QTCaptureDevice *)aDevice open:nil]) {
        _soundCaptureInput = [[QTCaptureDeviceInput alloc] initWithDevice:aDevice];
        if (_soundCaptureInput != nil) {
            if (![session addInput:_soundCaptureInput error:nil]) {
                [(QTCaptureDevice *)aDevice close];
                [_soundCaptureInput release];
                _soundCaptureInput = nil;
            }
            else {
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

- (void)storeSelectedDeviceInUserDefaults
{
    [[NSUserDefaults standardUserDefaults] setObject:[[_audioDevicePopUpButton selectedItem] title] forKey:HSAudioInputDeviceNameKey];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0023f472 @ 0023f472, 329 bytes * /

void FUN_0023f472(HSHyperCastingModePane *self,SEL _cmd)

{
  undefined4 uVar1;
  id pvVar2;
  id pvVar3;
  id self_00;
  
  uVar1 = *(undefined4 *)PTR_0033689c;
  pvVar2 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr____Description,uVar1);
  pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar2 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,pvVar2,&cfstr_empty,
                         &cfstr_Alerts);
  pvVar3 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr____RecoverySuggestion,uVar1);
  self_00 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar3 = _objc_msgSend(self_00,sel_localizedStringForKey_value_table_,pvVar3,&cfstr_empty,
                         &cfstr_Alerts);
  pvVar2 = _objc_msgSend(cls_NSAlert,
                         sel_alertWithMessageText_defaultButton_alternateButton_otherButton_informativeTextWithFormat_
                         ,pvVar2,&cfstr_OK,0,0,pvVar3);
  _objc_msgSend(pvVar2,sel_runModal);
  return;
}

*/
- (void)warnUserDeviceNotFound
{
    NSString *message = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:[NSString stringWithFormat:@"%@-Description", HSCantFindHSDeviceErrorString] value:@"" table:@"Alerts"];
    NSString *suggestion = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:[NSString stringWithFormat:@"%@-RecoverySuggestion", HSCantFindHSDeviceErrorString] value:@"" table:@"Alerts"];
    [[NSAlert alertWithMessageText:message defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", suggestion] runModal];
}

- (void)addNoneAudioDeviceMenuItem
{
    NSString *pvVar1_4;

    if ([[self audioDeviceList] captureDeviceCount] != 0) {
        if (_noneAudioDeviceMenuItem == nil) {
            pvVar1_4 = [[NSBundle mainBundle] localizedStringForKey:@"NoneDeviceMenuItemName" value:@"" table:@"AssistantPanes"];
            _noneAudioDeviceMenuItem = [[NSMenuItem alloc] initWithTitle:pvVar1_4 action:0 keyEquivalent:@""];
        }
        [[_audioDevicePopUpButton menu] insertItem:_noneAudioDeviceMenuItem atIndex:0];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0023f6da @ 0023f6da, 1023 bytes * /

BOOL FUN_0023f6da(HSHyperCastingModePane *self,SEL _cmd)

{
  int iVar1;
  undefined *self_00;
  id pvVar2;
  cfstringStruct *pcVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  cfstringStruct *pcVar7;
  cfstringStruct *pcVar8;
  cfstringStruct *pcVar9;
  undefined1 *puVar10;
  undefined4 uVar11;
  id local_8c;
  id local_88;
  id local_7c;
  cfstringStruct local_74;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined1 local_50 [64];
  
  uVar11 = *(undefined4 *)PTR_00336404;
  pvVar2 = _objc_msgSend(cls_QTCaptureDevice,sel_defaultInputDeviceWithMediaType_,uVar11);
  local_88 = _objc_msgSend(pvVar2,sel_localizedDisplayName);
  self_00 = cls_NSBundle;
  pvVar2 = _objc_msgSend(cls_HSCaptureDeviceList,sel_class);
  pvVar2 = _objc_msgSend(self_00,sel_bundleForClass_,pvVar2);
  pcVar8 = &cfstr_HyperPlayerBase;
  pcVar9 = &cfstr_empty;
  pcVar3 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_HSDeviceName,
                         &cfstr_empty,&cfstr_HyperPlayerBase);
  pvVar2 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  pvVar2 = _objc_msgSend(pvVar2,sel_stringForKey_,*(undefined4 *)PTR_003363f0);
  pcVar7 = pcVar3;
  pvVar4 = _objc_msgSend(pvVar2,sel_isEqualToString_,pcVar3);
  if ((char)pvVar4 == '\0') {
    if (pvVar2 != (id)0x0) {
      local_88 = pvVar2;
    }
  }
  else {
    pcVar7 = pcVar3;
    pvVar2 = _objc_msgSend(local_88,sel_isEqualToString_,pcVar3,pcVar9,pcVar8);
    if ((char)pvVar2 != '\0') {
      pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle,pcVar7);
      pcVar8 = &cfstr_AssistantPanes;
      pcVar9 = &cfstr_empty;
      pcVar7 = &cfstr_NoneDeviceMenuItemName;
      local_88 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                               &cfstr_NoneDeviceMenuItemName,&cfstr_empty,&cfstr_AssistantPanes);
    }
  }
  if (local_88 == (id)0x0) {
    pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle,pcVar7,pcVar9,pcVar8);
    pcVar8 = &cfstr_AssistantPanes;
    pcVar9 = &cfstr_empty;
    pcVar7 = &cfstr_NoneDeviceMenuItemName;
    local_88 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                             &cfstr_NoneDeviceMenuItemName,&cfstr_empty,&cfstr_AssistantPanes);
  }
  pvVar2 = _objc_msgSend(self,sel_audioDeviceList,pcVar7,pcVar9,pcVar8);
  pvVar6 = (id)0x0;
  pvVar4 = _objc_msgSend(pvVar2,sel_captureDeviceCount);
  do {
    if (pvVar4 <= pvVar6) {
      local_8c = (id)0x0;
LAB_0023f955:
      pvVar2 = _objc_msgSend(cls_QTCaptureDevice,sel_inputDevicesWithMediaType_,uVar11);
      local_74.field0_0x0 = 0;
      local_74.field1_0x4 = 0;
      local_74.field2_0x8 = (undefined *)0x0;
      local_74.field3_0xc = 0;
      local_64 = 0;
      local_60 = 0;
      local_5c = 0;
      local_58 = 0;
      puVar10 = local_50;
      pcVar8 = &local_74;
      uVar11 = 0x10;
      local_7c = _objc_msgSend(pvVar2,sel_countByEnumeratingWithState_objects_count_,pcVar8,puVar10,
                               0x10);
      if (local_7c != (id)0x0) {
        iVar1 = *(int *)local_74.field2_0x8;
        do {
          pvVar4 = (id)0x0;
          do {
            if (iVar1 != *(int *)local_74.field2_0x8) {
              _objc_enumerationMutation(pvVar2);
            }
            pvVar6 = _objc_msgSend(*(id *)(local_74.field1_0x4 + (int)pvVar4 * 4),
                                   sel_localizedDisplayName,pcVar8,puVar10,uVar11);
            pcVar8 = pcVar3;
            pvVar6 = _objc_msgSend(pvVar6,sel_isEqualToString_);
            if ((char)pvVar6 != '\0') goto LAB_0023fa72;
            pvVar4 = (id)((int)pvVar4 + 1);
          } while (pvVar4 < local_7c);
          puVar10 = local_50;
          pcVar8 = &local_74;
          uVar11 = 0x10;
          local_7c = _objc_msgSend(pvVar2,sel_countByEnumeratingWithState_objects_count_,pcVar8,
                                   puVar10,0x10);
        } while (local_7c != (id)0x0);
      }
LAB_0023fa72:
      _objc_msgSend(self->_audioDevicePopUpButton,sel_selectItemWithTitle_,local_88,puVar10,uVar11);
      _objc_msgSend(self->_recordingProvider,sel_setVoiceInputDevice_,local_8c);
      _objc_msgSend(self,sel_setSoundCaptureDevice_,local_8c);
      return '\0';
    }
    pvVar5 = _objc_msgSend(pvVar2,sel_localizedTitleForCaptureDeviceAtIndex_,pvVar6);
    pvVar5 = _objc_msgSend(pvVar5,sel_isEqualToString_,local_88);
    if ((char)pvVar5 != '\0') {
      local_8c = _objc_msgSend(pvVar2,sel_captureDeviceAtIndex_,pvVar6);
      goto LAB_0023f955;
    }
    pvVar6 = (id)((int)pvVar6 + 1);
  } while( true );
}

*/
- (BOOL)findInDefaultsAndSetupInputDevices
{
    NSString *deviceName = [[QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeSound] localizedDisplayName];
    NSString *defaultDeviceTitle = [[NSBundle bundleForClass:[HSCaptureDeviceList class]] localizedStringForKey:@"HSDeviceName" value:@"" table:@"HyperPlayerBase"];
    NSString *storedName = [[NSUserDefaults standardUserDefaults] stringForKey:HSAudioInputDeviceNameKey];
    if (![storedName isEqualToString:defaultDeviceTitle]) {
        if (storedName != nil) {
            deviceName = storedName;
        }
    }
    else if ([deviceName isEqualToString:defaultDeviceTitle]) {
        deviceName = [[NSBundle mainBundle] localizedStringForKey:@"NoneDeviceMenuItemName" value:@"" table:@"AssistantPanes"];
    }
    if (deviceName == nil) {
        deviceName = [[NSBundle mainBundle] localizedStringForKey:@"NoneDeviceMenuItemName" value:@"" table:@"AssistantPanes"];
    }
    HSCaptureDeviceList *deviceList = [self audioDeviceList];
    id device = nil;
    NSUInteger count = [deviceList captureDeviceCount];
    for (NSUInteger i = 0; i < count; i++) {
        if ([[deviceList localizedTitleForCaptureDeviceAtIndex:i] isEqualToString:deviceName]) {
            device = [deviceList captureDeviceAtIndex:i];
            break;
        }
    }
    /* the original then walks the sound input devices looking for the default device title without using the match */
    [_audioDevicePopUpButton selectItemWithTitle:deviceName];
    [_recordingProvider setVoiceInputDevice:device];
    [self setSoundCaptureDevice:device];
    return NO;
}

- (id)audioDeviceList
{
    id pvVar1;
    id pvVar1_3;

    pvVar1 = _audioDeviceList;
    if (pvVar1 == nil) {
        pvVar1_3 = [[NSArray alloc] initWithObjects:QTMediaTypeSound, QTMediaTypeMuxed, nil];
        _audioDeviceList = [[HSCaptureDeviceList captureDeviceListForMediaTypes:pvVar1_3] retain];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(captureDeviceListDidUpdate:) name:@"HSCaptureDeviceListDidUpdateNotification" object:_audioDeviceList];
        [pvVar1_3 release];
        pvVar1 = _audioDeviceList;
    }
    return pvVar1;
}

- (void)updateSoundDuration:(id)aDuration
{
    id pvVar1_2;

    if ([self isRecording]) {
        pvVar1_2 = _recordedTimeTextField;
        [self setMovieDuration:[self movieDurationForTextField:pvVar1_2] + 1.0 forTextField:pvVar1_2];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0023fc6a @ 0023fc6a, 129 bytes * /

void FUN_0023fc6a(HSHyperCastingModePane *self,SEL _cmd,id countDownDidEnd)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self->_recordingProvider,sel_startRecording);
  if ((char)pvVar1 != '\0') {
    _objc_msgSend(self,sel_setMovieDuration_forTextField_,0,0,self->_recordedTimeTextField);
    _objc_msgSend(self,sel_installTimerForMeasurementMovieDuration);
  }
  _objc_msgSend(self,sel_validateUserInterface);
  return;
}

*/
- (void)countDownDidEnd:(id)aEnd
{
    if ([_recordingProvider startRecording]) {
        [self setMovieDuration:0.0 forTextField:_recordedTimeTextField];
        [self installTimerForMeasurementMovieDuration];
    }
    [self validateUserInterface];
}

- (void)setMovieDuration:(double)aDuration forTextField:(id)aField
{
    unsigned int uVar2;

    uVar2 = (int)aDuration;
    if (2147483648.0 <= aDuration) {
        uVar2 = (int)(aDuration - 2147483648.0) ^ 0x80000000;
    }
    [aField setObjectValue:[NSCalendarDate dateWithYear:0 month:0 day:0 hour:0 minute:0 second:uVar2 timeZone:nil]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0023fd8c @ 0023fd8c, 152 bytes * /

double FUN_0023fd8c(HSHyperCastingModePane *self,SEL _cmd,id movieDurationForTextField)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar1 = _objc_msgSend(movieDurationForTextField,sel_objectValue);
  pvVar2 = _objc_msgSend(pvVar1,sel_hourOfDay);
  pvVar3 = _objc_msgSend(pvVar1,sel_minuteOfHour);
  pvVar1 = _objc_msgSend(pvVar1,sel_secondOfMinute);
  return (double)(int)pvVar1 + (double)(int)pvVar3 * 60.0 + (double)(int)pvVar2 * 3600.0;
}

*/
- (double)movieDurationForTextField:(id)aField
{
    NSCalendarDate *date = [aField objectValue];
    NSInteger hours = [date hourOfDay];
    NSInteger minutes = [date minuteOfHour];
    NSInteger seconds = [date secondOfMinute];
    return (double)(int)seconds + (double)(int)minutes * 60.0 + (double)(int)hours * 3600.0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0023fe24 @ 0023fe24, 369 bytes * /

void FUN_0023fe24(HSHyperCastingModePane *self,SEL _cmd)

{
  undefined *puVar1;
  undefined *self_00;
  id pvVar2;
  
  _objc_msgSend(self,sel_removeTimerForMeasurementMovieDuration);
  self_00 = cls_NSTimer;
  puVar1 = sel_updateSoundDuration_;
  pvVar2 = _objc_msgSend(self,sel_NSE_newWeakProxy);
  pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
  pvVar2 = _objc_msgSend(self_00,sel_timerWithTimeInterval_target_selector_userInfo_repeats_,0,
                         0x3ff00000,pvVar2,puVar1,0,1);
  pvVar2 = _objc_msgSend(pvVar2,sel_retain);
  self->_timerForMeasurementRecordMovieTime = pvVar2;
  pvVar2 = _objc_msgSend(cls_NSRunLoop,sel_currentRunLoop);
  _objc_msgSend(pvVar2,sel_addTimer_forMode_,self->_timerForMeasurementRecordMovieTime,
                *(undefined4 *)PTR_003361b4);
  pvVar2 = _objc_msgSend(cls_NSRunLoop,sel_currentRunLoop);
  _objc_msgSend(pvVar2,sel_addTimer_forMode_,self->_timerForMeasurementRecordMovieTime,
                *(undefined4 *)PTR_00336064);
  pvVar2 = _objc_msgSend(cls_NSRunLoop,sel_currentRunLoop);
  _objc_msgSend(pvVar2,sel_addTimer_forMode_,self->_timerForMeasurementRecordMovieTime,
                *(undefined4 *)PTR_003363f8);
  return;
}

*/
- (void)installTimerForMeasurementMovieDuration
{
    [self removeTimerForMeasurementMovieDuration];
    _timerForMeasurementRecordMovieTime = [[NSTimer timerWithTimeInterval:1.0 target:[[self NSE_newWeakProxy] autorelease] selector:@selector(updateSoundDuration:) userInfo:nil repeats:YES] retain];
    [[NSRunLoop currentRunLoop] addTimer:_timerForMeasurementRecordMovieTime forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:_timerForMeasurementRecordMovieTime forMode:NSEventTrackingRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:_timerForMeasurementRecordMovieTime forMode:NSModalPanelRunLoopMode];
}

- (void)removeTimerForMeasurementMovieDuration
{
    if (_timerForMeasurementRecordMovieTime != nil) {
        [_timerForMeasurementRecordMovieTime invalidate];
        [_timerForMeasurementRecordMovieTime release];
        _timerForMeasurementRecordMovieTime = nil;
    }
}

- (void)validateUserInterface
{
    [_audioDevicePopUpButton setEnabled:(unsigned int)(![self isRecording])];
    [[self navigationPaneSwitcher] validateUserInterface];
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

- (void)setHyperCastingModePaneDelegate:(id)aDelegate
{
    if (_hyperCastingModePaneDelegate != aDelegate) {
        _hyperCastingModePaneDelegate = aDelegate;
    }
}

- (id)hyperCastingModePaneDelegate
{
    return _hyperCastingModePaneDelegate;
}

- (void)setRecordingProvider:(id)aProvider
{
    if (_recordingProvider != aProvider) {
        if (_recordingProvider != nil) {
            if ([self isRecording]) {
                [_recordingProvider stopRecording];
            }
        }
        [_recordingProvider release];
        _recordingProvider = [aProvider retain];
        [self validateUserInterface];
    }
}

- (id)recordingProvider
{
    return _recordingProvider;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00240141 @ 00240141, 308 bytes * /

void FUN_00240141(HSHyperCastingModePane *self,SEL _cmd,id paneDidOK)

{
  id pvVar1;
  id self_00;
  HSHyperCastingModePane *pHVar2;
  HSHyperCastingModePane *self_01;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_isRecording);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(self,sel_startRecording);
    if ((char)pvVar1 == '\0') {
      return;
    }
    pvVar1 = _objc_msgSend(self,sel_hyperCastingNavigationPaneSwitcher);
    self_00 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    pHVar2 = _objc_msgSend(self_00,sel_localizedStringForKey_value_table_,&cfstr_HCMP_Done,
                           &cfstr_empty,&cfstr_AssistantPanes);
    _objc_msgSend(pvVar1,sel_setDefaultButtonTitle_,pHVar2);
    self_01 = self;
    op = sel_validateUserInterface;
  }
  else {
    _objc_msgSend(self,sel_stopRecording);
    _objc_msgSend(self,sel_storeSelectedDeviceInUserDefaults);
    pvVar1 = _objc_msgSend(self->_hyperCastingModePaneDelegate,sel_respondsToSelector_,
                           sel_confirmHyperCastingModePane_);
    if ((char)pvVar1 == '\0') {
      return;
    }
    self_01 = self->_hyperCastingModePaneDelegate;
    op = sel_confirmHyperCastingModePane_;
    pHVar2 = self;
  }
  _objc_msgSend(self_01,op,pHVar2);
  return;
}

*/
- (void)paneDidOK:(id)aOK
{
    if (![self isRecording]) {
        if (![self startRecording]) {
            return;
        }
        [[self hyperCastingNavigationPaneSwitcher] setDefaultButtonTitle:[[NSBundle mainBundle] localizedStringForKey:@"HCMP_Done" value:@"" table:@"AssistantPanes"]];
        [self validateUserInterface];
        return;
    }
    [self stopRecording];
    [self storeSelectedDeviceInUserDefaults];
    if ([_hyperCastingModePaneDelegate respondsToSelector:@selector(confirmHyperCastingModePane:)]) {
        [_hyperCastingModePaneDelegate confirmHyperCastingModePane:self];
    }
}

- (void)paneDidCancel:(id)aCancel
{
    [super paneDidCancel:aCancel];
    if ([self isRecording]) {
        [self cancelRecording];
    }
    if ([_hyperCastingModePaneDelegate respondsToSelector:@selector(cancelHyperCastingModePane:)]) {
        [_hyperCastingModePaneDelegate cancelHyperCastingModePane:self];
    }
}

- (BOOL)shouldEnableOKButtonInNavigationPaneSwitcher:(id)aSwitcher
{
    BOOL BVar1;
    BOOL pvVar2;

    pvVar2 = [_recordingProvider isRecording];
    if (![[self countDownViewController] isRunning]) {
        BVar1 = YES;
        if (pvVar2) {
            BVar1 = pvVar2;
        }
    }
    else {
        BVar1 = NO;
    }
    return BVar1;
}

- (void)viewDidDisappear:(BOOL)aDisappear
{
    [[self audioDeviceList] detachMenu:[_audioDevicePopUpButton menu]];
    [self setSoundCaptureDevice:nil];
    [super viewDidDisappear:aDisappear];
}

- (void)viewDidAppear:(BOOL)aAppear
{
    [super viewDidAppear:aAppear];
    [self validateUserInterface];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [[self audioDeviceList] attachMenu:[_audioDevicePopUpButton menu]];
    [self addNoneAudioDeviceMenuItem];
    [self findInDefaultsAndSetupInputDevices];
}

- (void)viewDidLoad
{
    [_volumeLevelIndicator setMaxValue:10.0];
    [_volumeLevelIndicator setWarningValue:5.0];
    [_volumeLevelIndicator setCriticalValue:9.0];
    [super viewDidLoad];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002405af @ 002405af, 127 bytes * /

void FUN_002405af(HSHyperCastingModePane *self,SEL _cmd)

{
  id self_00;
  id pvVar1;
  
  self_00 = self->_contentView;
  pvVar1 = _objc_msgSend(cls_NSImage,sel_imageNamed_,&cfstr_Background_Medium);
  _objc_msgSend(self_00,sel_setImage_,pvVar1);
  _objc_msgSend(self,sel_setMovieDuration_forTextField_,0,0,self->_recordedTimeTextField);
  return;
}

*/
- (void)awakeFromNib
{
    [_contentView setImage:[NSImage imageNamed:@"Background_Medium"]];
    [self setMovieDuration:0.0 forTextField:_recordedTimeTextField];
}

- (BOOL)needsToBeSavedInHistory
{
    return NO;
}

- (id)hyperCastingNavigationPaneSwitcher
{
    return [self navigationPaneSwitcher];
}

- (id)navigationPaneSwitcher
{
    id pvVar1;
    id pvVar1_2;

    pvVar1 = _navigationPaneSwitcher;
    if (pvVar1 == nil) {
        pvVar1_2 = [HSHyperCastingModePaneSwitcher new];
        _navigationPaneSwitcher = pvVar1_2;
        [pvVar1_2 setDelegate:self];
        pvVar1 = _navigationPaneSwitcher;
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002406b0 @ 002406b0, 163 bytes * /

id FUN_002406b0(HSHyperCastingModePane *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  HSHyperCastingModePane *local_1c;
  undefined *local_18;
  
  self_00 = cls_NSString;
  if (self->_recordingProvider == (id)0x0) {
    local_1c = self;
    local_18 = PTR_s_HSObjectAssistantPane_00355850;
    pvVar1 = _objc_msgSendSuper(&local_1c,sel_windowTitle);
  }
  else {
    pvVar1 = _objc_msgSend(self->_recordingProvider,sel_outputFileName);
    pvVar2 = _objc_msgSend(self->_recordingProvider,sel_documentName);
    pvVar1 = _objc_msgSend(self_00,sel_stringWithFormat_,&cfstr________,pvVar2,pvVar1);
  }
  return pvVar1;
}

*/
- (id)windowTitle
{
    if (_recordingProvider == nil) {
        return [super windowTitle];
    }
    return [NSString stringWithFormat:@"%@ : %@", [_recordingProvider documentName], [_recordingProvider outputFileName]];
}

- (BOOL)requiresDarkBottomArea
{
    return YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setSoundCaptureDevice:nil];
    [self destroySoundCaptureSession];
    [self removeTimerForMeasurementMovieDuration];
    _hyperCastingModePaneDelegate = nil;
    [_navigationPaneSwitcher release];
    [_recordingProvider release];
    [_audioDeviceList release];
    [_noneAudioDeviceMenuItem release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"HyperCastingModePane"];
    return self;
}

@end

