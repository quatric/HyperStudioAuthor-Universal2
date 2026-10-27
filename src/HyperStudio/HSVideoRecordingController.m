#import "HSVideoRecordingController.h"

@implementation HSVideoRecordingController

/* i386 ivar offsets: _delegate=0x4, _captureVideoDevice=0x8, _captureAudioDevice=0xc, _captureAudioInput=0x10, _captureMovieFileOutput=0x14, _captureDeviceSession=0x18, _captureDeviceSessionError=0x1c, _timerForMeasurementRecordTime=0x20, _videoCaptureDeviceList=0x24, _audioCaptureDeviceList=0x28, _playImage=0x2c, _stopImage=0x30, _playPressedImageAqua=0x34, _playPressedImageGraphite=0x38, _stopPressedImageAqua=0x3c, _stopPressedImageGraphite=0x40, _recordImage=0x44, _onRecordImage=0x48, _recordPressedImageAqua=0x4c, _recordPressedImageGraphite=0x50, _onRecordPressedImage=0x54, _movieFilePath=0x58, _countDownViewController=0x5c, _parentWindow=0x60, _playbackMatrix=0x64, _recordingPanel=0x68, _recordedTimeView=0x6c, _playbackTimeView=0x70, _playbackRecordViewContainer=0x74, _playbackPreviewView=0x78, _recordPreviewView=0x7c, _recordedTimeTextField=0x80, _currentPlaybackTimeTextField=0x84, _totalPlaybackTimeTextField=0x88, _recordProgressBox=0x8c, _recordProgressIndicator=0x90, _addToCardButton=0x94, _imageView=0x98, _exportProgressPanel=0x9c, _exportProgressBar=0xa0, _exportCancelButton=0xa4, _videoCaptureDevicesPopUp=0xa8, _audioCaptureDevicesPopUp=0xac, _didCaptureMovieFileOutputStartRecording=0xb0, _didCaptureMovieFileOutputFinishRecording=0xb0, _isWaitingForCaptureMovieFileOutputToFinishRecording=0xb0, _isFirstPreviewFrameCaptured=0xb0 */

- (void)HSVideoRecordingController_firstPreviewFrameCaptured
{
    id self_00;

    self_00 = _captureDeviceSession;
    if (self_00 != nil) {
        [self_00 deactivateForClient:self withFrameProcessorClass:[HSNativeVideoFrameProcessor class]];
    }
    [self updateUI];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0015bcc6 @ 0015bcc6, 92 bytes * /

void FUN_0015bcc6(HSVideoRecordingController *self,SEL _cmd,id captureDeviceSession,
                 id didReceiveFrame,Class fromFrameProcessorOfClass)

{
  if ((self->_captureDeviceSession == captureDeviceSession) &&
     ((self->_didCaptureMovieFileOutputStartRecording[0] & 8) == 0)) {
    self->_didCaptureMovieFileOutputStartRecording[0] =
         self->_didCaptureMovieFileOutputStartRecording[0] | 8;
    _objc_msgSend(self,sel_performSelectorOnMainThread_withObject_waitUntilDone_,
                  sel_HSVideoRecordingController_firstPreviewFrameCaptured,0,0);
  }
  return;
}

*/
- (void)captureDeviceSession:(id)aSession didReceiveFrame:(id)aFrame fromFrameProcessorOfClass:(Class)aClass
{
    if (_captureDeviceSession == aSession && !_isFirstPreviewFrameCaptured) {
        _isFirstPreviewFrameCaptured = 1;
        [self performSelectorOnMainThread:@selector(HSVideoRecordingController_firstPreviewFrameCaptured) withObject:nil waitUntilDone:NO];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001591f5 @ 001591f5, 15 bytes * /

void FUN_001591f5(HSVideoRecordingController *self,SEL _cmd,id captureOutput,
                 id didFinishRecordingToOutputFileAtURL,id forConnections,id dueToError)

{
  self->_didCaptureMovieFileOutputStartRecording[0] =
       self->_didCaptureMovieFileOutputStartRecording[0] | 2;
  return;
}

*/
- (void)captureOutput:(id)aOutput didFinishRecordingToOutputFileAtURL:(id)aURL forConnections:(id)aConnections dueToError:(id)aError
{
    _didCaptureMovieFileOutputFinishRecording = 1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001591e6 @ 001591e6, 15 bytes * /

void FUN_001591e6(HSVideoRecordingController *self,SEL _cmd,id captureOutput,
                 id didStartRecordingToOutputFileAtURL,id forConnections)

{
  self->_didCaptureMovieFileOutputStartRecording[0] =
       self->_didCaptureMovieFileOutputStartRecording[0] | 1;
  return;
}

*/
- (void)captureOutput:(id)aOutput didStartRecordingToOutputFileAtURL:(id)aURL forConnections:(id)aConnections
{
    _didCaptureMovieFileOutputStartRecording = 1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0015c083 @ 0015c083, 279 bytes * /

void FUN_0015c083(HSVideoRecordingController *self,SEL _cmd,
                 id HSVideoRecordingController_informAboutRecordError)

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
- (void)HSVideoRecordingController_informAboutRecordError:(id)aError
{
    NSString *ok = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"OK" value:@"" table:@"Alerts"];
    NSString *message = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Your hard disk may not have enough room or may have some other problem. Free some disk space or reopen the Record Video dialog and try again." value:@"" table:@"Alerts"];
    NSString *title = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Cannot record video" value:@"" table:@"Alerts"];
    NSRunCriticalAlertPanel(title, @"%@", ok, nil, nil, message);
}

- (void)audioDeviceDidChange:(id)aChange
{
    [self HSVideoRecordingController_setCaptureAudioDevice:[[_audioCaptureDevicesPopUp selectedItem] representedObject]];
}

- (void)videoDeviceDidChange:(id)aChange
{
    [self HSVideoRecordingController_setCaptureVideoDevice:[[_videoCaptureDevicesPopUp selectedItem] representedObject]];
    if (_captureVideoDevice != nil) {
        [self HSVideoRecordingController_changeVideoDeviceInRecordPreviewTo:_captureVideoDevice];
    }
}

- (void)onExportCancel:(id)aCancel
{
    [self movie:0 shouldContinueOperation:0 withPhase:2 atPercent:0 withAttributes:0];
    [self cleanTemporaryFile];
}

- (void)onHelp:(id)aHelp
{
    [[HSHelpBookManager sharedHelpBookManager] openHelpTopic:@"HSVideoRecording"];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0015ba8c @ 0015ba8c, 194 bytes * /

void FUN_0015ba8c(HSVideoRecordingController *self,SEL _cmd,id onCloseSheet)

{
  undefined *puVar1;
  id pvVar2;
  SEL op;
  
  pvVar2 = _objc_msgSend(self,sel_isRecording);
  if ((char)pvVar2 != '\0') {
    _objc_msgSend(self,sel_stopRecord);
  }
  pvVar2 = _objc_msgSend(self,sel_isPlaying);
  if ((char)pvVar2 != '\0') {
    _objc_msgSend(self,sel_stopPlayback);
  }
  puVar1 = PTR_00336058;
  pvVar2 = _objc_msgSend(*(id *)PTR_00336058,sel_modalWindow);
  if (pvVar2 == (id)0x0) {
    pvVar2 = self->_recordingPanel;
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
    if ([self isRecording]) {
        [self stopRecord];
    }
    if ([self isPlaying]) {
        [self stopPlayback];
    }
    if ([NSApp modalWindow] != nil) {
        [NSApp stopModalWithCode:0];
    } else {
        [NSApp endSheet:_recordingPanel returnCode:0];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0015b9b8 @ 0015b9b8, 212 bytes * /

void FUN_0015b9b8(HSVideoRecordingController *self,SEL _cmd,id addToCardVideo)

{
  undefined *puVar1;
  id pvVar2;
  SEL op;
  
  pvVar2 = _objc_msgSend(self,sel_isRecording);
  if ((char)pvVar2 != '\0') {
    _objc_msgSend(self,sel_stopRecord);
  }
  pvVar2 = _objc_msgSend(self,sel_isPlaying);
  if ((char)pvVar2 != '\0') {
    _objc_msgSend(self,sel_stopPlayback);
  }
  _objc_msgSend(self,sel_storeSelectedDevicesInUserDefaults);
  puVar1 = PTR_00336058;
  pvVar2 = _objc_msgSend(*(id *)PTR_00336058,sel_modalWindow);
  if (pvVar2 == (id)0x0) {
    pvVar2 = self->_recordingPanel;
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
- (void)addToCardVideo:(id)aVideo
{
    if ([self isRecording]) {
        [self stopRecord];
    }
    if ([self isPlaying]) {
        [self stopPlayback];
    }
    [self storeSelectedDevicesInUserDefaults];
    if ([NSApp modalWindow] != nil) {
        [NSApp stopModalWithCode:1];
    } else {
        [NSApp endSheet:_recordingPanel returnCode:1];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0015b92f @ 0015b92f, 137 bytes * /

BOOL FUN_0015b92f(HSVideoRecordingController *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self->_captureVideoDevice,sel_isConnected);
  if (((char)pvVar1 != '\0') &&
     (pvVar1 = _objc_msgSend(self->_captureVideoDevice,sel_QTE_isInUseByAnotherApplication),
     (char)pvVar1 == '\0')) {
    pvVar1 = _objc_msgSend(self->_captureVideoDevice,sel_attributeForKey_,
                           *(undefined4 *)PTR_00336400);
    pvVar1 = _objc_msgSend(pvVar1,sel_boolValue);
    return (char)pvVar1 == '\0';
  }
  return '\0';
}

*/
- (BOOL)isInputDeviceValid
{
    return [_captureVideoDevice isConnected] && ![_captureVideoDevice QTE_isInUseByAnotherApplication] && ![[_captureVideoDevice attributeForKey:QTCaptureDeviceSuspendedAttribute] boolValue];
}

- (BOOL)isPlaying
{
    BOOL bVar2;

    if ([_playbackPreviewView superview] == nil) {
        bVar2 = NO;
    }
    else {
        bVar2 = [_playbackPreviewView isPlaying];
    }
    return bVar2;
}

- (BOOL)isRecording
{
    return _captureMovieFileOutput != nil;
}

- (id)fileName
{
    id pvVar1;

    pvVar1 = _movieFilePath;
    if (pvVar1 == nil) {
        pvVar1 = [[NSString extraCreateUniqueFilename:[[[HSPathsProvider sharedPathsProvider] temporaryFolder] stringByAppendingPathComponent:[[HSUID UID] stringValue]] extension:@"mov"] retain];
        _movieFilePath = pvVar1;
    }
    return pvVar1;
}

- (void)runModalForWindow:(id)aWindow
{
    _parentWindow = aWindow;
    [self prepareRecordingPanel];
    [NSApp beginSheet:_recordingPanel modalForWindow:aWindow modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:0];
}

- (NSInteger)runModal
{
    NSModalResponse pvVar1_2;

    [self prepareRecordingPanel];
    pvVar1_2 = [[NSApplication sharedApplication] runModalForWindow:_recordingPanel];
    [_recordingPanel orderOut:self];
    [self prepareRecordingPanelToClose];
    return (int)pvVar1_2;
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

/* --- i386 decompilation (Ghidra) ---
/* FUN_0015b676 @ 0015b676, 156 bytes * /

void FUN_0015b676(HSVideoRecordingController *self,SEL _cmd,id sheetDidEnd,int returnCode,
                 void *contextInfo)

{
  id pvVar1;
  SEL op;
  undefined *puVar2;
  
  _objc_msgSend(sheetDidEnd,sel_orderOut_,self);
  _objc_msgSend(self,sel_prepareRecordingPanelToClose);
  puVar2 = sel_videoRecordingSheetDidEnd_returnCode_contextInfo_;
  pvVar1 = _objc_msgSend(self->_delegate,sel_respondsToSelector_,
                         sel_videoRecordingSheetDidEnd_returnCode_contextInfo_);
  op = sel_cleanTemporaryFile;
  if ((char)pvVar1 != '\0') {
    self = self->_delegate;
    op = sel_videoRecordingSheetDidEnd_returnCode_contextInfo_;
    puVar2 = sheetDidEnd;
  }
  _objc_msgSend(self,op,puVar2);
  return;
}

*/
- (void)sheetDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    [aEnd orderOut:self];
    [self prepareRecordingPanelToClose];
    /* The delegate takes the recorded file; without one it is thrown away. */
    if ([_delegate respondsToSelector:@selector(videoRecordingSheetDidEnd:returnCode:contextInfo:)]) {
        [_delegate videoRecordingSheetDidEnd:aEnd returnCode:aCode contextInfo:aInfo];
    } else {
        [self cleanTemporaryFile];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0015b4d1 @ 0015b4d1, 421 bytes * /

void FUN_0015b4d1(HSVideoRecordingController *self,SEL _cmd,
                 id HSVideoRecordingController_changeVideoDeviceInRecordPreviewTo)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(self->_captureDeviceSession,sel_captureDeviceSet);
  pvVar1 = _objc_msgSend(pvVar1,sel_containsObject_,
                         HSVideoRecordingController_changeVideoDeviceInRecordPreviewTo);
  if ((char)pvVar1 == '\0') {
    if (self->_captureDeviceSession != (id)0x0) {
      _objc_msgSend(self->_recordPreviewView,sel_stopPreviewing,
                    HSVideoRecordingController_changeVideoDeviceInRecordPreviewTo);
      _objc_msgSend(self->_recordPreviewView,sel_setCaptureDeviceSession_,0);
      pvVar1 = self->_captureDeviceSession;
      pvVar2 = _objc_msgSend(cls_HSNativeVideoFrameProcessor,sel_class);
      _objc_msgSend(pvVar1,sel_deactivateForClient_withFrameProcessorClass_,self,pvVar2);
      _objc_msgSend(self->_captureDeviceSession,sel_release);
      self->_captureDeviceSession = (id)0x0;
      self->_didCaptureMovieFileOutputStartRecording[0] =
           self->_didCaptureMovieFileOutputStartRecording[0] & 0xf7;
    }
    pvVar1 = self->_captureVideoDevice;
    pvVar2 = _objc_msgSend(cls_HSCaptureDeviceSession,sel_captureDeviceSessionForDevice_,pvVar1);
    pvVar2 = _objc_msgSend(pvVar2,sel_retain);
    self->_captureDeviceSession = pvVar2;
    if ((pvVar2 != (id)0x0) && (self->_recordPreviewView != (id)0x0)) {
      pvVar1 = _objc_msgSend(self->_playbackRecordViewContainer,sel_contentView,pvVar1);
      if (pvVar1 == self->_recordPreviewView) {
        _objc_msgSend(self->_recordPreviewView,sel_setCaptureDeviceSession_,
                      self->_captureDeviceSession);
        _objc_msgSend(self->_recordPreviewView,sel_startPreviewing);
        pvVar1 = self->_captureDeviceSession;
        pvVar2 = _objc_msgSend(cls_HSNativeVideoFrameProcessor,sel_class);
        _objc_msgSend(pvVar1,sel_activateForClient_withFrameProcessorClass_,self,pvVar2);
      }
    }
  }
  return;
}

*/
- (void)HSVideoRecordingController_changeVideoDeviceInRecordPreviewTo:(id)aTo
{
    if ([[_captureDeviceSession captureDeviceSet] containsObject:aTo]) {
        return;
    }
    if (_captureDeviceSession != nil) {
        [_recordPreviewView stopPreviewing];
        [_recordPreviewView setCaptureDeviceSession:nil];
        [_captureDeviceSession deactivateForClient:self withFrameProcessorClass:[HSNativeVideoFrameProcessor class]];
        [_captureDeviceSession release];
        _captureDeviceSession = nil;
        _isFirstPreviewFrameCaptured = 0;
    }
    /* As in the original, the session is made for the current device, not aTo. */
    _captureDeviceSession = [[HSCaptureDeviceSession captureDeviceSessionForDevice:_captureVideoDevice] retain];
    if (_captureDeviceSession != nil && _recordPreviewView != nil && [_playbackRecordViewContainer contentView] == _recordPreviewView) {
        [_recordPreviewView setCaptureDeviceSession:_captureDeviceSession];
        [_recordPreviewView startPreviewing];
        [_captureDeviceSession activateForClient:self withFrameProcessorClass:[HSNativeVideoFrameProcessor class]];
    }
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

- (id)videoCaptureDeviceList
{
    id pvVar1;
    id pvVar1_3;

    pvVar1 = _videoCaptureDeviceList;
    if (pvVar1 == nil) {
        pvVar1_3 = [[NSArray alloc] initWithObjects:QTMediaTypeVideo, QTMediaTypeMuxed, nil];
        _videoCaptureDeviceList = [[HSCaptureDeviceList captureDeviceListForMediaTypes:pvVar1_3] retain];
        [pvVar1_3 release];
        pvVar1 = _videoCaptureDeviceList;
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0015c19a @ 0015c19a, 467 bytes * /

void FUN_0015c19a(HSVideoRecordingController *self,SEL _cmd,id updateRecordDuration)

{
  id pvVar1;
  double dVar2;
  double dVar3;
  SEL op;
  undefined8 in_stack_ffffffbc;
  undefined4 uVar4;
  
  uVar4 = (undefined4)((ulonglong)in_stack_ffffffbc >> 0x20);
  pvVar1 = _objc_msgSend(self,sel_isRecording);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(self,sel_isPlaying);
    if ((char)pvVar1 == '\0') {
      return;
    }
    dVar2 = _objc_msgSend_fpret(self,sel_recordDurationForTextField_,
                                self->_currentPlaybackTimeTextField);
    dVar3 = _objc_msgSend_fpret(self,sel_recordDurationForTextField_,
                                self->_totalPlaybackTimeTextField);
    dVar2 = dVar2 + 1.0;
    op = sel_setRecordDuration_forTextField_;
    if (dVar3 < dVar2) {
      _objc_msgSend(self,sel_togglePlay);
      self = (HSVideoRecordingController *)self->_playbackPreviewView;
      dVar2 = (double)CONCAT44(uVar4,sel_gotoBeginning_);
      op = sel_performSelector_;
    }
  }
  else if (self->_captureDeviceSessionError == (id)0x0) {
    dVar2 = _objc_msgSend_fpret(self,sel_recordDurationForTextField_,self->_recordedTimeTextField);
    dVar2 = dVar2 + 1.0;
    op = sel_setRecordDuration_forTextField_;
  }
  else {
    pvVar1 = _objc_msgSend(self->_captureDeviceSessionError,sel_retain);
    _objc_msgSend(self,sel_stopRecord);
    _objc_msgSend(self,sel_cleanTemporaryFile);
    _objc_msgSend(self,sel_HSVideoRecordingController_informAboutRecordError_,pvVar1);
    _objc_msgSend(pvVar1,sel_release);
    _objc_msgSend(self,sel_updateUI);
    dVar2 = 0.0;
    op = sel_setRecordDuration_forTextField_;
  }
  _objc_msgSend(self,op,dVar2);
  return;
}

*/
- (void)updateRecordDuration:(id)aDuration
{
    if ([self isRecording]) {
        if (_captureDeviceSessionError == nil) {
            [self setRecordDuration:[self recordDurationForTextField:_recordedTimeTextField] + 1.0 forTextField:_recordedTimeTextField];
            return;
        }
        /* The capture session failed while recording. */
        NSError *error = [_captureDeviceSessionError retain];
        [self stopRecord];
        [self cleanTemporaryFile];
        [self HSVideoRecordingController_informAboutRecordError:error];
        [error release];
        [self updateUI];
        [self setRecordDuration:0.0 forTextField:_recordedTimeTextField];
        return;
    }
    if (![self isPlaying]) {
        return;
    }
    double time = [self recordDurationForTextField:_currentPlaybackTimeTextField] + 1.0;
    if ([self recordDurationForTextField:_totalPlaybackTimeTextField] < time) {
        [self togglePlay];
        [_playbackPreviewView performSelector:@selector(gotoBeginning:)];
    } else {
        [self setRecordDuration:time forTextField:_currentPlaybackTimeTextField];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0015b2e4 @ 0015b2e4, 127 bytes * /

double FUN_0015b2e4(HSVideoRecordingController *self,SEL _cmd,id recordDurationForTextField)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar1 = _objc_msgSend(recordDurationForTextField,sel_objectValue);
  pvVar2 = _objc_msgSend(pvVar1,sel_hourOfDay);
  pvVar3 = _objc_msgSend(pvVar1,sel_minuteOfHour);
  pvVar1 = _objc_msgSend(pvVar1,sel_secondOfMinute);
  return (double)((int)pvVar1 + (int)pvVar3 * 0x3c + (int)pvVar2 * 0xe10);
}

*/
- (double)recordDurationForTextField:(id)aField
{
    id date = [aField objectValue];
    return (double)([date secondOfMinute] + [date minuteOfHour] * 60 + [date hourOfDay] * 3600);
}

- (void)setRecordDuration:(double)aDuration forTextField:(id)aField
{
    unsigned int uVar2;

    uVar2 = (int)aDuration;
    if (2147483648.0 <= aDuration) {
        uVar2 = (int)(aDuration - 2147483648.0) ^ 0x80000000;
    }
    [aField setObjectValue:[NSCalendarDate dateWithYear:0 month:0 day:0 hour:0 minute:0 second:uVar2 timeZone:nil]];
}

- (void)removeTimerForMeasurementRecordDuration
{
    if (_timerForMeasurementRecordTime != nil) {
        [_timerForMeasurementRecordTime invalidate];
        [_timerForMeasurementRecordTime release];
        _timerForMeasurementRecordTime = nil;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0015b0db @ 0015b0db, 283 bytes * /

void FUN_0015b0db(HSVideoRecordingController *self,SEL _cmd)

{
  undefined *puVar1;
  undefined *self_00;
  id pvVar2;
  
  _objc_msgSend(self,sel_removeTimerForMeasurementRecordDuration);
  self_00 = cls_NSTimer;
  puVar1 = sel_updateRecordDuration_;
  pvVar2 = _objc_msgSend(self,sel_NSE_newWeakProxy);
  pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
  pvVar2 = _objc_msgSend(self_00,
                         sel_scheduledTimerWithTimeInterval_target_selector_userInfo_repeats_,0,
                         0x3ff00000,pvVar2,puVar1,0,1);
  pvVar2 = _objc_msgSend(pvVar2,sel_retain);
  self->_timerForMeasurementRecordTime = pvVar2;
  pvVar2 = _objc_msgSend(cls_NSRunLoop,sel_currentRunLoop);
  _objc_msgSend(pvVar2,sel_addTimer_forMode_,self->_timerForMeasurementRecordTime,
                *(undefined4 *)PTR_003363f8);
  _objc_msgSend(pvVar2,sel_addTimer_forMode_,self->_timerForMeasurementRecordTime,
                *(undefined4 *)PTR_00336064);
  return;
}

*/
- (void)installTimerForMeasurementRecordDuration
{
    [self removeTimerForMeasurementRecordDuration];
    _timerForMeasurementRecordTime = [[NSTimer scheduledTimerWithTimeInterval:1.0 target:[[self NSE_newWeakProxy] autorelease] selector:@selector(updateRecordDuration:) userInfo:nil repeats:YES] retain];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:_timerForMeasurementRecordTime forMode:NSModalPanelRunLoopMode];
    [runLoop addTimer:_timerForMeasurementRecordTime forMode:NSEventTrackingRunLoopMode];
}

- (void)cleanTemporaryFile
{
    id pvVar1;
    NSFileManager *self_00;

    pvVar1 = [self fileName];
    self_00 = [NSFileManager defaultManager];
    if ([self_00 isDeletableFileAtPath:pvVar1]) {
        [self_00 removeFileAtPath:pvVar1 handler:nil];
    }
}

- (void)setUpOnRecordButton
{
    [[_playbackMatrix cellAtRow:0 column:0] setImage:_onRecordImage];
    [[_playbackMatrix cellAtRow:0 column:0] setGraphiteAlternateImage:_onRecordPressedImage];
}

- (void)setUpRecordButton
{
    [[_playbackMatrix cellAtRow:0 column:0] setImage:_recordImage];
    [[_playbackMatrix cellAtRow:0 column:0] setGraphiteAlternateImage:_recordPressedImageGraphite];
}

- (void)setUpPauseButton
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
/* FUN_0015acec @ 0015acec, 163 bytes * /

void FUN_0015acec(HSVideoRecordingController *self,SEL _cmd,id trackingButtonCell,BOOL isTracking,
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
/* FUN_0015a9e1 @ 0015a9e1, 687 bytes * /

void FUN_0015a9e1(HSVideoRecordingController *self,SEL _cmd)

{
  bool bVar1;
  char cVar2;
  char cVar3;
  char cVar4;
  id pvVar5;
  SEL pcVar6;
  id pvVar7;
  uint uVar8;
  undefined4 uVar9;
  undefined4 uVar10;
  
  if (self->_movieFilePath == (id)0x0) {
    cVar2 = '\0';
  }
  else {
    pvVar5 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
    pvVar5 = _objc_msgSend(pvVar5,sel_isReadableFileAtPath_,self->_movieFilePath);
    cVar2 = (char)pvVar5;
  }
  pvVar5 = _objc_msgSend(self,sel_isRecording);
  if (((char)pvVar5 == '\0') &&
     (pvVar5 = _objc_msgSend(self->_countDownViewController,sel_isRunning), (char)pvVar5 == '\0')) {
    bVar1 = false;
  }
  else {
    bVar1 = true;
  }
  pvVar5 = _objc_msgSend(self,sel_isPlaying);
  cVar3 = (char)pvVar5;
  pcVar6 = sel_setUpPlayButton;
  if (cVar3 != '\0') {
    pcVar6 = sel_setUpPauseButton;
  }
  _objc_msgSend(self,pcVar6);
  pcVar6 = sel_setUpRecordButton;
  if (bVar1) {
    pcVar6 = sel_setUpOnRecordButton;
  }
  _objc_msgSend(self,pcVar6);
  uVar8 = (uint)(cVar3 == '\0' && !bVar1);
  _objc_msgSend(self->_videoCaptureDevicesPopUp,sel_setEnabled_,uVar8);
  _objc_msgSend(self->_audioCaptureDevicesPopUp,sel_setEnabled_,uVar8);
  uVar10 = 0;
  uVar9 = 0;
  pvVar5 = _objc_msgSend(self->_playbackMatrix,sel_cellAtRow_column_,0,0);
  if ((((cVar3 == '\0') &&
       (pvVar7 = _objc_msgSend(self,sel_isInputDeviceValid,uVar9,uVar10), (char)pvVar7 != '\0')) &&
      (pvVar7 = _objc_msgSend(self->_countDownViewController,sel_isRunning,uVar9,uVar10),
      (char)pvVar7 == '\0')) && ((self->_didCaptureMovieFileOutputStartRecording[0] & 8) != 0)) {
    cVar4 = '\x01';
  }
  else {
    cVar4 = '\0';
  }
  _objc_msgSend(pvVar5,sel_setEnabled_,(int)cVar4,uVar10);
  uVar8 = (uint)(!bVar1 && cVar2 != '\0');
  pvVar5 = _objc_msgSend(self->_playbackMatrix,sel_cellAtRow_column_,0,1);
  _objc_msgSend(pvVar5,sel_setEnabled_,uVar8);
  _objc_msgSend(self->_addToCardButton,sel_setEnabled_,uVar8);
  pvVar5 = _objc_msgSend(self->_imageView,sel_subviews);
  pvVar5 = _objc_msgSend(pvVar5,sel_objectAtIndex_,0);
  if ((cVar3 == '\0') || (pvVar7 = self->_playbackTimeView, pvVar5 == pvVar7)) {
    pvVar7 = self->_recordedTimeView;
    if (pvVar5 == pvVar7) {
      return;
    }
    pvVar5 = self->_playbackTimeView;
  }
  else {
    pvVar5 = self->_recordedTimeView;
  }
  _objc_msgSend(self->_imageView,sel_replaceSubview_with_,pvVar5,pvVar7);
  return;
}

*/
- (void)updateUI
{
    BOOL hasMovie = _movieFilePath != nil && [[NSFileManager defaultManager] isReadableFileAtPath:_movieFilePath];
    BOOL isRecording = [self isRecording] || [_countDownViewController isRunning];
    BOOL isPlaying = [self isPlaying];
    if (isPlaying) {
        [self setUpPauseButton];
    } else {
        [self setUpPlayButton];
    }
    if (isRecording) {
        [self setUpOnRecordButton];
    } else {
        [self setUpRecordButton];
    }
    [_videoCaptureDevicesPopUp setEnabled:!isPlaying && !isRecording];
    [_audioCaptureDevicesPopUp setEnabled:!isPlaying && !isRecording];
    /* Recording waits for the first preview frame. */
    [[_playbackMatrix cellAtRow:0 column:0] setEnabled:!isPlaying && [self isInputDeviceValid] && ![_countDownViewController isRunning] && _isFirstPreviewFrameCaptured];
    BOOL canUseMovie = !isRecording && hasMovie;
    [[_playbackMatrix cellAtRow:0 column:1] setEnabled:canUseMovie];
    [_addToCardButton setEnabled:canUseMovie];
    NSView *shownView = [[_imageView subviews] objectAtIndex:0];
    if (isPlaying && shownView != _playbackTimeView) {
        [_imageView replaceSubview:_recordedTimeView with:_playbackTimeView];
    } else if (!isPlaying && shownView != _recordedTimeView) {
        [_imageView replaceSubview:_playbackTimeView with:_recordedTimeView];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0015a7f7 @ 0015a7f7, 490 bytes * /

void FUN_0015a7f7(HSVideoRecordingController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  HSVideoRecordingController *pHVar3;
  
  if (self->_recordPreviewView != (id)0x0) {
    pvVar1 = _objc_msgSend(self->_playbackRecordViewContainer,sel_contentView);
    if (pvVar1 == self->_recordPreviewView) {
      _objc_msgSend(self->_recordPreviewView,sel_stopPreviewing);
      _objc_msgSend(self->_recordPreviewView,sel_setCaptureDeviceSession_,0);
    }
  }
  pvVar1 = self->_captureDeviceSession;
  pvVar2 = _objc_msgSend(cls_HSNativeVideoFrameProcessor,sel_class);
  pHVar3 = self;
  _objc_msgSend(pvVar1,sel_deactivateForClient_withFrameProcessorClass_,self,pvVar2);
  _objc_msgSend(self->_captureDeviceSession,sel_release);
  self->_captureDeviceSession = (id)0x0;
  self->_didCaptureMovieFileOutputStartRecording[0] =
       self->_didCaptureMovieFileOutputStartRecording[0] & 0xf7;
  _objc_msgSend(self->_countDownViewController,sel_stopRun);
  pvVar1 = _objc_msgSend(self->_playbackPreviewView,sel_isPlaying);
  if ((char)pvVar1 != '\0') {
    _objc_msgSend(self->_playbackPreviewView,sel_stopPlaying,pHVar3,pvVar2);
  }
  _objc_msgSend(self,sel_setRecordDuration_forTextField_,0,0,self->_recordedTimeTextField);
  pvVar1 = _objc_msgSend(self,sel_videoCaptureDeviceList);
  pvVar2 = _objc_msgSend(self->_videoCaptureDevicesPopUp,sel_menu);
  _objc_msgSend(pvVar1,sel_detachMenu_,pvVar2);
  pvVar1 = _objc_msgSend(self,sel_audioCaptureDeviceList);
  pvVar2 = _objc_msgSend(self->_audioCaptureDevicesPopUp,sel_menu);
  _objc_msgSend(pvVar1,sel_detachMenu_,pvVar2);
  _objc_msgSend(self,sel_HSVideoRecordingController_setCaptureVideoDevice_,0);
  _objc_msgSend(self,sel_HSVideoRecordingController_setCaptureAudioDevice_,0);
  return;
}

*/
- (void)prepareRecordingPanelToClose
{
    if (_recordPreviewView != nil && [_playbackRecordViewContainer contentView] == _recordPreviewView) {
        [_recordPreviewView stopPreviewing];
        [_recordPreviewView setCaptureDeviceSession:nil];
    }
    [_captureDeviceSession deactivateForClient:self withFrameProcessorClass:[HSNativeVideoFrameProcessor class]];
    [_captureDeviceSession release];
    _captureDeviceSession = nil;
    _isFirstPreviewFrameCaptured = 0;
    [_countDownViewController stopRun];
    if ([_playbackPreviewView isPlaying]) {
        [_playbackPreviewView stopPlaying];
    }
    [self setRecordDuration:0.0 forTextField:_recordedTimeTextField];
    [[self videoCaptureDeviceList] detachMenu:[_videoCaptureDevicesPopUp menu]];
    [[self audioCaptureDeviceList] detachMenu:[_audioCaptureDevicesPopUp menu]];
    [self HSVideoRecordingController_setCaptureVideoDevice:nil];
    [self HSVideoRecordingController_setCaptureAudioDevice:nil];
}

- (void)prepareRecordingPanel
{
    if (_recordingPanel == nil) {
        [NSBundle loadNibNamed:@"VideoRecordingPanel" owner:self];
    }
    [_movieFilePath release];
    _movieFilePath = nil;
    if (0 < (int)[_videoCaptureDevicesPopUp numberOfItems]) {
        if (![self selectVideoDeviceFromUserDefaults]) {
            [self selectDefaultVideoDevice];
        }
    }
    if (0 < (int)[_audioCaptureDevicesPopUp numberOfItems]) {
        if (![self selectAudioDeviceFromUserDefaults]) {
            [self selectDefaultAudioDevice];
        }
    }
    [self updateUI];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0015a642 @ 0015a642, 185 bytes * /

void FUN_0015a642(HSVideoRecordingController *self,SEL _cmd,id observeValueForKeyPath,id ofObject,
                 id change,void *context)

{
  id pvVar1;
  
  if ((self->_captureVideoDevice == ofObject) || (self->_captureAudioDevice == ofObject)) {
    pvVar1 = _objc_msgSend(observeValueForKeyPath,sel_isEqualToString_,
                           &cfstr_inUseByAnotherApplication);
    if (((char)pvVar1 == '\0') &&
       ((pvVar1 = _objc_msgSend(observeValueForKeyPath,sel_isEqualToString_,&cfstr_suspended),
        (char)pvVar1 == '\0' &&
        (pvVar1 = _objc_msgSend(observeValueForKeyPath,sel_isEqualToString_,&cfstr_connected),
        (char)pvVar1 == '\0')))) {
      return;
    }
    _objc_msgSend(self,sel_performSelectorOnMainThread_withObject_waitUntilDone_,
                  sel_HSVideoRecordingController_captureDeviceDidChangeState_,ofObject,0);
  }
  return;
}

*/
- (void)observeValueForKeyPath:(id)aPath ofObject:(id)aObject change:(id)aChange context:(void *)aContext
{
    if (_captureVideoDevice != aObject && _captureAudioDevice != aObject) {
        return;
    }
    if ([aPath isEqualToString:@"inUseByAnotherApplication"] || [aPath isEqualToString:@"suspended"] || [aPath isEqualToString:@"connected"]) {
        [self performSelectorOnMainThread:@selector(HSVideoRecordingController_captureDeviceDidChangeState:) withObject:aObject waitUntilDone:NO];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0015a556 @ 0015a556, 236 bytes * /

void FUN_0015a556(HSVideoRecordingController *self,SEL _cmd,
                 id HSVideoRecordingController_captureDeviceDidChangeState)

{
  id pvVar1;
  
  if ((self->_captureVideoDevice != HSVideoRecordingController_captureDeviceDidChangeState) &&
     (self->_captureAudioDevice != HSVideoRecordingController_captureDeviceDidChangeState)) {
    return;
  }
  pvVar1 = _objc_msgSend(HSVideoRecordingController_captureDeviceDidChangeState,sel_isConnected);
  if (((char)pvVar1 != '\0') &&
     (pvVar1 = _objc_msgSend(HSVideoRecordingController_captureDeviceDidChangeState,
                             sel_QTE_isInUseByAnotherApplication), (char)pvVar1 == '\0')) {
    pvVar1 = _objc_msgSend(HSVideoRecordingController_captureDeviceDidChangeState,
                           sel_attributeForKey_,*(undefined4 *)PTR_00336400);
    pvVar1 = _objc_msgSend(pvVar1,sel_boolValue);
    if ((char)pvVar1 == '\0') goto LAB_0015a628;
  }
  _objc_msgSend(self->_countDownViewController,sel_stopRun);
  pvVar1 = _objc_msgSend(self,sel_isRecording);
  if ((char)pvVar1 != '\0') {
    _objc_msgSend(self,sel_removeTimerForMeasurementRecordDuration);
    _objc_msgSend(self,sel_stopRecord);
  }
LAB_0015a628:
  _objc_msgSend(self,sel_updateUI);
  return;
}

*/
- (void)HSVideoRecordingController_captureDeviceDidChangeState:(id)aState
{
    if (_captureVideoDevice != aState && _captureAudioDevice != aState) {
        return;
    }
    if (![aState isConnected] || [aState QTE_isInUseByAnotherApplication] || [[aState attributeForKey:QTCaptureDeviceSuspendedAttribute] boolValue]) {
        [_countDownViewController stopRun];
        if ([self isRecording]) {
            [self removeTimerForMeasurementRecordDuration];
            [self stopRecord];
        }
    }
    [self updateUI];
}

- (void)HSVideoRecordingController_captureDeviceSessionRuntimeErrorNotification:(id)aNotification
{
    if (_captureDeviceSessionError == nil) {
        _captureDeviceSessionError = [[[aNotification userInfo] objectForKey:@"HSCaptureDeviceSessionErrorKey"] copy];
    }
}

- (void)stopPlayback
{
    [_recordPreviewView startPreviewing];
    [[_playbackRecordViewContainer window] disableScreenUpdatesUntilFlush];
    [_playbackRecordViewContainer setContentView:_recordPreviewView];
    [_playbackPreviewView stopPlaying];
    [_playbackPreviewView setMoviePath:nil];
    [self updateUI];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0015a2d5 @ 0015a2d5, 361 bytes * /

void FUN_0015a2d5(HSVideoRecordingController *self,SEL _cmd)

{
  HSUIVideoMovieView *self_00;
  id pvVar1;
  id pvVar2;
  HSUIVideoMovieView *pHVar3;
  id pvVar4;
  HSUIVideoMovieView *pHVar5;
  undefined4 uVar6;
  undefined4 uVar7;
  
  pvVar1 = _objc_msgSend(self,sel_fileName);
  pvVar2 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
  pvVar4 = pvVar1;
  pvVar2 = _objc_msgSend(pvVar2,sel_fileExistsAtPath_,pvVar1);
  if ((char)pvVar2 != '\0') {
    pvVar2 = _objc_msgSend(cls_NSFileManager,sel_defaultManager,pvVar4);
    uVar7 = 0;
    uVar6 = 0;
    pvVar4 = pvVar1;
    pvVar2 = _objc_msgSend(pvVar2,sel_hyperIsReadableFileAtPath_showAlert_error_,pvVar1,0,0);
    if ((char)pvVar2 != '\0') {
      pHVar3 = _objc_msgSend(self->_playbackRecordViewContainer,sel_contentView,pvVar4,uVar6,uVar7);
      if (pHVar3 != self->_playbackPreviewView) {
        pvVar4 = _objc_msgSend(self->_playbackRecordViewContainer,sel_window,pvVar4,uVar6,uVar7);
        _objc_msgSend(pvVar4,sel_disableScreenUpdatesUntilFlush);
        pHVar5 = self->_playbackPreviewView;
        _objc_msgSend(self->_playbackRecordViewContainer,sel_setContentView_,pHVar5);
        self_00 = self->_recordPreviewView;
        if ((self_00 != (HSUIVideoMovieView *)0x0) && (pHVar3 == self_00)) {
          _objc_msgSend(self_00,sel_stopPreviewing,pHVar5);
        }
      }
      _objc_msgSend(self->_playbackPreviewView,sel_setMoviePath_,pvVar1,uVar6,uVar7);
      _objc_msgSend(self->_playbackPreviewView,sel_startPlaying);
    }
  }
  return;
}

*/
- (void)startPlayback
{
    NSString *path = [self fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path] || ![[NSFileManager defaultManager] hyperIsReadableFileAtPath:path showAlert:NO error:NULL]) {
        return;
    }
    NSView *contentView = [_playbackRecordViewContainer contentView];
    if (contentView != _playbackPreviewView) {
        [[_playbackRecordViewContainer window] disableScreenUpdatesUntilFlush];
        [_playbackRecordViewContainer setContentView:_playbackPreviewView];
        if (_recordPreviewView != nil && contentView == _recordPreviewView) {
            [_recordPreviewView stopPreviewing];
        }
    }
    [_playbackPreviewView setMoviePath:path];
    [_playbackPreviewView startPlaying];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0015a174 @ 0015a174, 353 bytes * /

void FUN_0015a174(HSVideoRecordingController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  undefined *puVar3;
  undefined4 uVar4;
  
  pvVar1 = _objc_msgSend(self,sel_isPlaying);
  if ((char)pvVar1 == '\0') {
    pvVar1 = self->_totalPlaybackTimeTextField;
    pvVar2 = _objc_msgSend(self->_recordedTimeTextField,sel_objectValue);
    _objc_msgSend(pvVar1,sel_setObjectValue_,pvVar2);
    pvVar1 = self->_currentPlaybackTimeTextField;
    uVar4 = 0;
    puVar3 = (undefined *)0x0;
    _objc_msgSend(self,sel_setRecordDuration_forTextField_,0,0,pvVar1);
    _objc_msgSend(self,sel_installTimerForMeasurementRecordDuration);
    _objc_msgSend(self,sel_startPlayback);
    op = sel_updateUI;
  }
  else {
    _objc_msgSend(self,sel_removeTimerForMeasurementRecordDuration);
    _objc_msgSend(cls_NSArray,sel_arrayWithObjects_,*(undefined4 *)PTR_003361b4,
                  *(undefined4 *)PTR_003363f8,*(undefined4 *)PTR_00336064,0);
    pvVar1 = (id)0x0;
    uVar4 = 0;
    op = sel_performSelector_withObject_afterDelay_inModes_;
    puVar3 = sel_stopPlayback;
  }
  _objc_msgSend(self,op,puVar3,uVar4,pvVar1);
  return;
}

*/
- (void)togglePlay
{
    if ([self isPlaying]) {
        [self removeTimerForMeasurementRecordDuration];
        [self performSelector:@selector(stopPlayback) withObject:nil afterDelay:0.0 inModes:[NSArray arrayWithObjects:NSDefaultRunLoopMode, NSModalPanelRunLoopMode, NSEventTrackingRunLoopMode, nil]];
        return;
    }
    [_totalPlaybackTimeTextField setObjectValue:[_recordedTimeTextField objectValue]];
    [self setRecordDuration:0.0 forTextField:_currentPlaybackTimeTextField];
    [self installTimerForMeasurementRecordDuration];
    [self startPlayback];
    [self updateUI];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0015a0a2 @ 0015a0a2, 210 bytes * /

void FUN_0015a0a2(HSVideoRecordingController *self,SEL _cmd,id countDownDidEnd)

{
  id pvVar1;
  id pvVar2;
  
  self->_didCaptureMovieFileOutputStartRecording[0] =
       self->_didCaptureMovieFileOutputStartRecording[0] & 0xfc;
  pvVar1 = _objc_msgSend(cls_NSURL,sel_alloc);
  pvVar2 = _objc_msgSend(self,sel_fileName);
  pvVar1 = _objc_msgSend(pvVar1,sel_initFileURLWithPath_,pvVar2);
  if (pvVar1 != (id)0x0) {
    _objc_msgSend(self->_captureMovieFileOutput,sel_recordToOutputFileURL_,pvVar1);
    _objc_msgSend(pvVar1,sel_release);
    pvVar2 = (id)0x0;
    _objc_msgSend(self,sel_setRecordDuration_forTextField_,0,0,self->_recordedTimeTextField);
  }
  _objc_msgSend(self,sel_updateUI,pvVar2);
  return;
}

*/
- (void)countDownDidEnd:(id)aEnd
{
    _didCaptureMovieFileOutputStartRecording = 0;
    _didCaptureMovieFileOutputFinishRecording = 0;
    NSURL *url = [[NSURL alloc] initFileURLWithPath:[self fileName]];
    if (url != nil) {
        [_captureMovieFileOutput recordToOutputFileURL:url];
        [url release];
        [self setRecordDuration:0.0 forTextField:_recordedTimeTextField];
    }
    [self updateUI];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00159ff8 @ 00159ff8, 170 bytes * /

void FUN_00159ff8(HSVideoRecordingController *self,SEL _cmd)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_isRecording);
  if ((char)pvVar1 == '\0') {
    _objc_msgSend(self,sel_setRecordDuration_forTextField_,0,0,self->_recordedTimeTextField);
    _objc_msgSend(self,sel_installTimerForMeasurementRecordDuration);
    op = sel_startRecord;
  }
  else {
    _objc_msgSend(self,sel_removeTimerForMeasurementRecordDuration);
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
        [self removeTimerForMeasurementRecordDuration];
        [self stopRecord];
    } else {
        [self setRecordDuration:0.0 forTextField:_recordedTimeTextField];
        [self installTimerForMeasurementRecordDuration];
        [self startRecord];
    }
    [self updateUI];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0015c36d @ 0015c36d, 593 bytes * /

void FUN_0015c36d(HSVideoRecordingController *self,SEL _cmd)

{
  undefined4 uVar1;
  byte bVar2;
  id pvVar3;
  undefined4 uVar4;
  undefined4 uVar5;
  
  if ((self->_didCaptureMovieFileOutputStartRecording[0] & 4) == 0) {
    _objc_msgSend(self->_recordProgressBox,sel_setHidden_,0);
    _objc_msgSend(self->_recordProgressIndicator,sel_startAnimation_,0);
    _objc_msgSend(self->_recordProgressBox,sel_displayIfNeeded);
    _objc_msgSend(self->_recordPreviewView,sel_stopPreviewing);
    uVar5 = 2;
    uVar4 = 0;
    _objc_msgSend(self->_captureMovieFileOutput,sel_recordToOutputFileURL_bufferDestination_,0,2);
    bVar2 = self->_didCaptureMovieFileOutputStartRecording[0] | 4;
    self->_didCaptureMovieFileOutputStartRecording[0] = bVar2;
    uVar1 = *(undefined4 *)PTR_00336408;
    while (((bVar2 & 1) != 0 && ((bVar2 & 2) == 0))) {
      uVar4 = 0x3fb99999;
      uVar5 = 1;
      _CFRunLoopRunInMode(uVar1,0x9999999a,0x3fb99999,1);
      bVar2 = self->_didCaptureMovieFileOutputStartRecording[0];
    }
    self->_didCaptureMovieFileOutputStartRecording[0] = bVar2 & 0xfb;
    _objc_msgSend(self->_recordPreviewView,sel_startPreviewing,uVar4,uVar5);
    if (self->_recordPreviewView == (id)0x0) {
      _objc_msgSend(self->_captureDeviceSession,sel_deactivate,uVar4,uVar5);
    }
    if (self->_captureAudioInput != (id)0x0) {
      _objc_msgSend(self,sel_HSVideoRecordingController_removeAudioInput,uVar4,uVar5);
    }
    pvVar3 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    _objc_msgSend(pvVar3,sel_removeObserver_name_object_,self,
                  &cfstr_HSCaptureDeviceSessionRuntimeErrorNotification,self->_captureDeviceSession)
    ;
    _objc_msgSend(self->_captureDeviceSessionError,sel_release);
    self->_captureDeviceSessionError = (id)0x0;
    pvVar3 = _objc_msgSend(self->_captureDeviceSession,sel_captureSession);
    _objc_msgSend(pvVar3,sel_removeOutput_,self->_captureMovieFileOutput);
    _objc_msgSend(self->_captureMovieFileOutput,sel_setDelegate_,0);
    _objc_msgSend(self->_captureMovieFileOutput,sel_release);
    self->_captureMovieFileOutput = (id)0x0;
    _objc_msgSend(self->_recordProgressIndicator,sel_stopAnimation_,0);
    _objc_msgSend(self->_recordProgressBox,sel_setHidden_,1);
  }
  return;
}

*/
- (void)stopRecord
{
    if (_isWaitingForCaptureMovieFileOutputToFinishRecording) {
        return;
    }
    [_recordProgressBox setHidden:NO];
    [_recordProgressIndicator startAnimation:nil];
    [_recordProgressBox displayIfNeeded];
    [_recordPreviewView stopPreviewing];
    [_captureMovieFileOutput recordToOutputFileURL:nil bufferDestination:QTCaptureFileOutputBufferDestinationOldFile];
    _isWaitingForCaptureMovieFileOutputToFinishRecording = 1;
    /* Wait for the file to be finished. */
    while (_didCaptureMovieFileOutputStartRecording && !_didCaptureMovieFileOutputFinishRecording) {
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, true);
    }
    _isWaitingForCaptureMovieFileOutputToFinishRecording = 0;
    [_recordPreviewView startPreviewing];
    if (_recordPreviewView == nil) {
        [_captureDeviceSession deactivate];
    }
    if (_captureAudioInput != nil) {
        [self HSVideoRecordingController_removeAudioInput];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSCaptureDeviceSessionRuntimeErrorNotification" object:_captureDeviceSession];
    [_captureDeviceSessionError release];
    _captureDeviceSessionError = nil;
    [[_captureDeviceSession captureSession] removeOutput:_captureMovieFileOutput];
    [_captureMovieFileOutput setDelegate:nil];
    [_captureMovieFileOutput release];
    _captureMovieFileOutput = nil;
    [_recordProgressIndicator stopAnimation:nil];
    [_recordProgressBox setHidden:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00159bf4 @ 00159bf4, 1028 bytes * /

void FUN_00159bf4(HSVideoRecordingController *self,SEL _cmd)

{
  undefined4 uVar1;
  undefined4 uVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id self_00;
  id pvVar6;
  id pvVar7;
  id pvVar8;
  HSVideoRecordingController *pHVar9;
  cfstringStruct *pcVar10;
  
  pvVar3 = _objc_msgSend(self,sel_HSVideoRecordingController_prepareToRecord);
  if ((char)pvVar3 == '\0') {
    if (self->_captureDeviceSession != (id)0x0) {
      pvVar4 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
      pvVar3 = self->_captureDeviceSession;
      pcVar10 = &cfstr_HSCaptureDeviceSessionRuntimeErrorNotification;
      pHVar9 = self;
      _objc_msgSend(pvVar4,sel_removeObserver_name_object_,self,
                    &cfstr_HSCaptureDeviceSessionRuntimeErrorNotification,pvVar3);
      if (self->_recordPreviewView == (id)0x0) {
        _objc_msgSend(self->_captureDeviceSession,sel_deactivate,pHVar9,pcVar10,pvVar3);
      }
      if (self->_captureAudioInput != (id)0x0) {
        _objc_msgSend(self,sel_HSVideoRecordingController_removeAudioInput,pHVar9,pcVar10,pvVar3);
      }
    }
    _objc_msgSend(self,sel_HSVideoRecordingController_informAboutRecordError_,
                  self->_captureDeviceSessionError);
    _objc_msgSend(self->_captureDeviceSessionError,sel_release);
    self->_captureDeviceSessionError = (id)0x0;
  }
  else {
    _objc_msgSend(self->_captureDeviceSessionError,sel_release);
    self->_captureDeviceSessionError = (id)0x0;
    _objc_msgSend(self,sel_cleanTemporaryFile);
    _objc_msgSend(self->_movieFilePath,sel_release);
    self->_movieFilePath = (id)0x0;
    pvVar3 = _objc_msgSend(cls_QTCaptureMovieFileOutput,sel_new);
    self->_captureMovieFileOutput = pvVar3;
    if (pvVar3 != (id)0x0) {
      if (self->_countDownViewController == (id)0x0) {
        pvVar3 = _objc_msgSend(cls_HSCountDownViewController,sel_new);
        self->_countDownViewController = pvVar3;
        _objc_msgSend(pvVar3,sel_setDelegate_,self);
      }
      pvVar3 = _objc_msgSend(self->_playbackMatrix,sel_cellAtRow_column_,0,0);
      _objc_msgSend(pvVar3,sel_setEnabled_,0);
      pvVar3 = _objc_msgSend(self->_playbackMatrix,sel_cellAtRow_column_,0,1);
      _objc_msgSend(pvVar3,sel_setEnabled_,0);
      _objc_msgSend(self->_captureMovieFileOutput,sel_setDelegate_,self);
      pvVar5 = _objc_msgSend(self->_captureDeviceSession,sel_captureSession);
      pvVar3 = self->_captureMovieFileOutput;
      pvVar4 = (id)0x0;
      pvVar5 = _objc_msgSend(pvVar5,sel_addOutput_error_,pvVar3,0);
      if ((char)pvVar5 == '\0') {
        _objc_msgSend(self->_captureMovieFileOutput,sel_setDelegate_,0,pvVar4);
        _objc_msgSend(self->_captureMovieFileOutput,sel_release);
        self->_captureMovieFileOutput = (id)0x0;
      }
      else {
        pvVar3 = _objc_msgSend(self->_captureMovieFileOutput,sel_connections,pvVar3,pvVar4);
        pvVar5 = _objc_msgSend(pvVar3,sel_count);
        if (pvVar5 != (id)0x0) {
          uVar1 = *(undefined4 *)PTR_00336404;
          uVar2 = *(undefined4 *)PTR_0033615c;
          pvVar8 = (id)0x0;
          do {
            self_00 = _objc_msgSend(pvVar3,sel_objectAtIndex_,pvVar8,pvVar4);
            pvVar6 = _objc_msgSend(self_00,sel_mediaType);
            pvVar7 = _objc_msgSend(pvVar6,sel_isEqualToString_,uVar2);
            if ((char)pvVar7 == '\0') {
              pvVar6 = _objc_msgSend(pvVar6,sel_isEqualToString_,uVar1);
              if ((char)pvVar6 != '\0') {
                pcVar10 = &cfstr_QTCompressionOptionsHighQualityAACAudio;
                goto LAB_00159f92;
              }
            }
            else {
              pcVar10 = &cfstr_QTCompressionOptionsSD480SizeH264Video;
LAB_00159f92:
              pvVar6 = _objc_msgSend(cls_QTCompressionOptions,sel_compressionOptionsWithIdentifier_,
                                     pcVar10);
              if (pvVar6 != (id)0x0) {
                _objc_msgSend(self->_captureMovieFileOutput,sel_setCompressionOptions_forConnection_
                              ,pvVar6,self_00);
                pvVar4 = self_00;
              }
            }
            pvVar8 = (id)((int)pvVar8 + 1);
          } while (pvVar8 < pvVar5);
        }
        _objc_msgSend(self->_countDownViewController,sel_runInView_,self->_imageView,pvVar4);
      }
    }
  }
  return;
}

*/
- (void)startRecord
{
    if (![self HSVideoRecordingController_prepareToRecord]) {
        if (_captureDeviceSession != nil) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSCaptureDeviceSessionRuntimeErrorNotification" object:_captureDeviceSession];
            if (_recordPreviewView == nil) {
                [_captureDeviceSession deactivate];
            }
            if (_captureAudioInput != nil) {
                [self HSVideoRecordingController_removeAudioInput];
            }
        }
        [self HSVideoRecordingController_informAboutRecordError:_captureDeviceSessionError];
        [_captureDeviceSessionError release];
        _captureDeviceSessionError = nil;
        return;
    }
    [_captureDeviceSessionError release];
    _captureDeviceSessionError = nil;
    [self cleanTemporaryFile];
    [_movieFilePath release];
    _movieFilePath = nil;
    _captureMovieFileOutput = [QTCaptureMovieFileOutput new];
    if (_captureMovieFileOutput == nil) {
        return;
    }
    if (_countDownViewController == nil) {
        _countDownViewController = [HSCountDownViewController new];
        [_countDownViewController setDelegate:self];
    }
    [[_playbackMatrix cellAtRow:0 column:0] setEnabled:NO];
    [[_playbackMatrix cellAtRow:0 column:1] setEnabled:NO];
    [_captureMovieFileOutput setDelegate:self];
    if (![[_captureDeviceSession captureSession] addOutput:_captureMovieFileOutput error:NULL]) {
        [_captureMovieFileOutput setDelegate:nil];
        [_captureMovieFileOutput release];
        _captureMovieFileOutput = nil;
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
    [_countDownViewController runInView:_imageView];
}

- (BOOL)HSVideoRecordingController_prepareToRecord
{
    NSNotificationCenter *pvVar1;
    id pvVar2;
    BOOL pvVar1_4;
    id pvVar1_6;
    QTCaptureSession *pvVar2_2;

    if (_captureDeviceSession != nil) {
        pvVar1 = [NSNotificationCenter defaultCenter];
        pvVar2 = _captureDeviceSession;
        [pvVar1 addObserver:self selector:@selector(HSVideoRecordingController_captureDeviceSessionRuntimeErrorNotification:) name:@"HSCaptureDeviceSessionRuntimeErrorNotification" object:pvVar2];
        if (_recordPreviewView == nil) {
            [_captureDeviceSession activate];
        }
        if ([_captureVideoDevice isOpen]) {
            pvVar2_2 = [_captureDeviceSession captureSession];
            if ([pvVar2_2 isRunning]) {
                if ((_captureAudioDevice != nil) && (pvVar1_4 = [_captureAudioDevice open:0], pvVar1_4)) {
                    pvVar1_6 = [[QTCaptureDeviceInput deviceInputWithDevice:_captureAudioDevice] retain];
                    _captureAudioInput = pvVar1_6;
                    if (pvVar1_6 != nil) {
                        [pvVar2_2 addInput:pvVar1_6 error:nil];
                        return YES;
                    }
                }
                return YES;
            }
        }
    }
    return NO;
}

- (void)HSVideoRecordingController_removeAudioInput
{
    [[_captureDeviceSession captureSession] removeInput:_captureAudioInput];
    [_captureAudioInput release];
    _captureAudioInput = nil;
    if ([_captureAudioDevice isOpen]) {
        [_captureAudioDevice close];
    }
}

- (void)selectDefaultAudioDevice
{
    QTCaptureDevice *self_01;

    self_01 = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeSound];
    if (self_01 != nil) {
        [_audioCaptureDevicesPopUp selectItemWithTitle:[self_01 localizedDisplayName]];
        [self HSVideoRecordingController_setCaptureAudioDevice:self_01];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00159830 @ 00159830, 302 bytes * /

void FUN_00159830(HSVideoRecordingController *self,SEL _cmd)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  undefined4 uVar5;
  
  uVar5 = *(undefined4 *)PTR_0033615c;
  self_00 = _objc_msgSend(cls_QTCaptureDevice,sel_defaultInputDeviceWithMediaType_,uVar5);
  if (self_00 != (id)0x0) {
    pvVar1 = _objc_msgSend(self->_videoCaptureDeviceList,sel_captureDeviceCount,uVar5);
    for (pvVar4 = (id)0x0; pvVar4 < pvVar1; pvVar4 = (id)((int)pvVar4 + 1)) {
      pvVar2 = _objc_msgSend(self->_videoCaptureDeviceList,sel_captureDeviceAtIndex_,pvVar4);
      pvVar2 = _objc_msgSend(pvVar2,sel_uniqueID);
      pvVar3 = _objc_msgSend(self_00,sel_uniqueID);
      pvVar2 = _objc_msgSend(pvVar2,sel_isEqualToString_,pvVar3);
      if ((char)pvVar2 != '\0') {
        _objc_msgSend(self->_videoCaptureDevicesPopUp,sel_selectItemAtIndex_,pvVar4);
        _objc_msgSend(self,sel_HSVideoRecordingController_setCaptureVideoDevice_,self_00);
        if (self->_captureVideoDevice == (id)0x0) {
          return;
        }
        _objc_msgSend(self,sel_HSVideoRecordingController_changeVideoDeviceInRecordPreviewTo_,
                      self->_captureVideoDevice);
        return;
      }
    }
  }
  return;
}

*/
- (void)selectDefaultVideoDevice
{
    QTCaptureDevice *device = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeVideo];
    if (device == nil) {
        return;
    }
    NSUInteger count = [_videoCaptureDeviceList captureDeviceCount];
    for (NSUInteger i = 0; i < count; i++) {
        if ([[(QTCaptureDevice *)[_videoCaptureDeviceList captureDeviceAtIndex:i] uniqueID] isEqualToString:[device uniqueID]]) {
            [_videoCaptureDevicesPopUp selectItemAtIndex:i];
            [self HSVideoRecordingController_setCaptureVideoDevice:device];
            if (_captureVideoDevice != nil) {
                [self HSVideoRecordingController_changeVideoDeviceInRecordPreviewTo:_captureVideoDevice];
            }
            return;
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00159705 @ 00159705, 299 bytes * /

BOOL FUN_00159705(HSVideoRecordingController *self,SEL _cmd)

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
       (pvVar1 = _objc_msgSend(self->_audioCaptureDevicesPopUp,sel_itemWithTitle_,pvVar1,pcVar4,
                               pcVar5), pvVar1 != (id)0x0)) {
      _objc_msgSend(self->_audioCaptureDevicesPopUp,sel_selectItem_,pvVar1,pcVar4,pcVar5);
      pvVar1 = _objc_msgSend(pvVar1,sel_representedObject);
      _objc_msgSend(self,sel_HSVideoRecordingController_setCaptureAudioDevice_,pvVar1);
      return '\x01';
    }
  }
  return '\0';
}

*/
- (BOOL)selectAudioDeviceFromUserDefaults
{
    NSString *deviceName = [[NSUserDefaults standardUserDefaults] stringForKey:HSAudioInputDeviceNameKey];
    if (deviceName == nil || [deviceName isEqualToString:[[NSBundle mainBundle] localizedStringForKey:@"NoneDeviceMenuItemName" value:@"" table:@"AssistantPanes"]]) {
        return NO;
    }
    NSMenuItem *item = [_audioCaptureDevicesPopUp itemWithTitle:deviceName];
    if (item == nil) {
        return NO;
    }
    [_audioCaptureDevicesPopUp selectItem:item];
    [self HSVideoRecordingController_setCaptureAudioDevice:[item representedObject]];
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001595b3 @ 001595b3, 338 bytes * /

BOOL FUN_001595b3(HSVideoRecordingController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  
  pvVar1 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  pvVar2 = _objc_msgSend(pvVar1,sel_stringForKey_,*(undefined4 *)PTR_00336618);
  pvVar1 = pvVar2;
  pvVar3 = _objc_msgSend(cls_QTCaptureDevice,sel_deviceWithUniqueID_,pvVar2);
  if (pvVar3 != (id)0x0) {
    pvVar1 = _objc_msgSend(self->_videoCaptureDeviceList,sel_captureDeviceCount,pvVar1);
    for (pvVar5 = (id)0x0; pvVar5 < pvVar1; pvVar5 = (id)((int)pvVar5 + 1)) {
      pvVar4 = _objc_msgSend(self->_videoCaptureDeviceList,sel_captureDeviceAtIndex_,pvVar5);
      pvVar4 = _objc_msgSend(pvVar4,sel_uniqueID);
      pvVar4 = _objc_msgSend(pvVar4,sel_isEqualToString_,pvVar2);
      if ((char)pvVar4 != '\0') {
        _objc_msgSend(self->_videoCaptureDevicesPopUp,sel_selectItemAtIndex_,pvVar5);
        _objc_msgSend(self,sel_HSVideoRecordingController_setCaptureVideoDevice_,pvVar3);
        if (self->_captureVideoDevice != (id)0x0) {
          _objc_msgSend(self,sel_HSVideoRecordingController_changeVideoDeviceInRecordPreviewTo_,
                        self->_captureVideoDevice);
          return '\x01';
        }
        return '\x01';
      }
    }
  }
  return '\0';
}

*/
- (BOOL)selectVideoDeviceFromUserDefaults
{
    NSString *uniqueID = [[NSUserDefaults standardUserDefaults] stringForKey:HSVideoDeviceUniqueIDKey];
    QTCaptureDevice *device = [QTCaptureDevice deviceWithUniqueID:uniqueID];
    if (device == nil) {
        return NO;
    }
    NSUInteger count = [_videoCaptureDeviceList captureDeviceCount];
    for (NSUInteger i = 0; i < count; i++) {
        if ([[(QTCaptureDevice *)[_videoCaptureDeviceList captureDeviceAtIndex:i] uniqueID] isEqualToString:uniqueID]) {
            [_videoCaptureDevicesPopUp selectItemAtIndex:i];
            [self HSVideoRecordingController_setCaptureVideoDevice:device];
            if (_captureVideoDevice != nil) {
                [self HSVideoRecordingController_changeVideoDeviceInRecordPreviewTo:_captureVideoDevice];
            }
            return YES;
        }
    }
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001594b6 @ 001594b6, 253 bytes * /

void FUN_001594b6(HSVideoRecordingController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  pvVar2 = _objc_msgSend(self->_audioCaptureDevicesPopUp,sel_selectedItem);
  pvVar2 = _objc_msgSend(pvVar2,sel_title);
  _objc_msgSend(pvVar1,sel_setObject_forKey_,pvVar2,*(undefined4 *)PTR_003363f0);
  pvVar1 = _objc_msgSend(self->_videoCaptureDevicesPopUp,sel_selectedItem);
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
    QTCaptureDevice *device = [[_videoCaptureDevicesPopUp selectedItem] representedObject];
    [[NSUserDefaults standardUserDefaults] setObject:[device uniqueID] forKey:HSVideoDeviceUniqueIDKey];
}

- (void)HSVideoRecordingController_setCaptureAudioDevice:(id)aDevice
{
    id self_00;
    id pvVar1;
    id pvVar1_2;

    pvVar1 = _captureAudioDevice;
    if (pvVar1 != aDevice) {
        self_00 = nil;
        if (pvVar1 != nil) {
            [pvVar1 removeObserver:self forKeyPath:@"inUseByAnotherApplication"];
            [_captureAudioDevice removeObserver:self forKeyPath:@"suspended"];
            [_captureAudioDevice removeObserver:self forKeyPath:@"connected"];
            self_00 = _captureAudioDevice;
        }
        [self_00 release];
        pvVar1_2 = [aDevice retain];
        _captureAudioDevice = pvVar1_2;
        if (pvVar1_2 != nil) {
            [pvVar1_2 addObserver:self forKeyPath:@"inUseByAnotherApplication" options:0 context:nil];
            [_captureAudioDevice addObserver:self forKeyPath:@"suspended" options:0 context:nil];
            [_captureAudioDevice addObserver:self forKeyPath:@"connected" options:0 context:nil];
        }
    }
}

- (void)HSVideoRecordingController_setCaptureVideoDevice:(id)aDevice
{
    id self_00;
    id pvVar1;
    id pvVar1_2;

    pvVar1 = _captureVideoDevice;
    if (pvVar1 != aDevice) {
        self_00 = nil;
        if (pvVar1 != nil) {
            [pvVar1 removeObserver:self forKeyPath:@"inUseByAnotherApplication"];
            [_captureVideoDevice removeObserver:self forKeyPath:@"suspended"];
            [_captureVideoDevice removeObserver:self forKeyPath:@"connected"];
            self_00 = _captureVideoDevice;
        }
        [self_00 release];
        pvVar1_2 = [aDevice retain];
        _captureVideoDevice = pvVar1_2;
        if (pvVar1_2 != nil) {
            [pvVar1_2 addObserver:self forKeyPath:@"inUseByAnotherApplication" options:0 context:nil];
            [_captureVideoDevice addObserver:self forKeyPath:@"suspended" options:0 context:nil];
            [_captureVideoDevice addObserver:self forKeyPath:@"connected" options:0 context:nil];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0015c5be @ 0015c5be, 2147 bytes * /

void FUN_0015c5be(HSVideoRecordingController *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined8 local_24;
  undefined8 local_1c;
  
  pvVar1 = _objc_msgSend(cls_HSCaptureView,sel_alloc);
  pvVar2 = _objc_msgSend(self->_playbackRecordViewContainer,sel_contentView);
  _objc_msgSend_stret(&local_24,pvVar2,sel_bounds);
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithFrame_,local_24,local_1c);
  self->_recordPreviewView = pvVar1;
  _objc_msgSend(pvVar1,sel_enableOpenGLSurface);
  _objc_msgSend(self->_playbackRecordViewContainer,sel_setContentView_,self->_recordPreviewView);
  _objc_msgSend(self->_imageView,sel_addSubview_positioned_relativeTo_,self->_recordedTimeView,
                0xffffffff,self->_playbackMatrix);
  pvVar1 = self->_imageView;
  pvVar2 = _objc_msgSend(cls_NSImage,sel_alloc);
  self_00 = cls_NSBundle;
  pvVar3 = _objc_msgSend(self,sel_class);
  pvVar3 = _objc_msgSend(self_00,sel_bundleForClass_,pvVar3);
  pvVar3 = _objc_msgSend(pvVar3,sel_pathForResource_ofType_,&cfstr_Countdown,&cfstr_pdf);
  pvVar2 = _objc_msgSend(pvVar2,sel_initWithContentsOfFile_,pvVar3);
  pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
  _objc_msgSend(pvVar1,sel_setImage_,pvVar2);
  pvVar1 = _objc_msgSend(cls_HSPlaybackControlImagesProvider,
                         sel_sharedPlaybackControlsImagesProvider);
  pvVar1 = _objc_msgSend(pvVar1,sel_playbackImageOfType_state_size_tint_,&cfstr_Play,&cfstr_N,
                         &cfstr_L,&cfstr_A);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_playImage = pvVar1;
  pvVar1 = _objc_msgSend(cls_HSPlaybackControlImagesProvider,
                         sel_sharedPlaybackControlsImagesProvider);
  pvVar1 = _objc_msgSend(pvVar1,sel_playbackImageOfType_state_size_tint_,&cfstr_Stop,&cfstr_N,
                         &cfstr_L,&cfstr_A);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_stopImage = pvVar1;
  pvVar1 = _objc_msgSend(cls_HSPlaybackControlImagesProvider,
                         sel_sharedPlaybackControlsImagesProvider);
  pvVar1 = _objc_msgSend(pvVar1,sel_playbackImageOfType_state_size_tint_,&cfstr_Play,&cfstr_P,
                         &cfstr_L,&cfstr_A);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_playPressedImageAqua = pvVar1;
  pvVar1 = _objc_msgSend(cls_HSPlaybackControlImagesProvider,
                         sel_sharedPlaybackControlsImagesProvider);
  pvVar1 = _objc_msgSend(pvVar1,sel_playbackImageOfType_state_size_tint_,&cfstr_Stop,&cfstr_P,
                         &cfstr_L,&cfstr_A);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_stopPressedImageAqua = pvVar1;
  pvVar1 = _objc_msgSend(cls_HSPlaybackControlImagesProvider,
                         sel_sharedPlaybackControlsImagesProvider);
  pvVar1 = _objc_msgSend(pvVar1,sel_playbackImageOfType_state_size_tint_,&cfstr_Play,&cfstr_P,
                         &cfstr_L,&cfstr_G);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_playPressedImageGraphite = pvVar1;
  pvVar1 = _objc_msgSend(cls_HSPlaybackControlImagesProvider,
                         sel_sharedPlaybackControlsImagesProvider);
  pvVar1 = _objc_msgSend(pvVar1,sel_playbackImageOfType_state_size_tint_,&cfstr_Stop,&cfstr_P,
                         &cfstr_L,&cfstr_G);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_stopPressedImageGraphite = pvVar1;
  pvVar1 = _objc_msgSend(cls_HSPlaybackControlImagesProvider,
                         sel_sharedPlaybackControlsImagesProvider);
  pvVar1 = _objc_msgSend(pvVar1,sel_playbackImageOfType_state_size_tint_,&cfstr_Record,&cfstr_N,
                         &cfstr_L,&cfstr_A);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_recordImage = pvVar1;
  pvVar1 = _objc_msgSend(cls_HSPlaybackControlImagesProvider,
                         sel_sharedPlaybackControlsImagesProvider);
  pvVar1 = _objc_msgSend(pvVar1,sel_playbackImageOfType_state_size_tint_,&cfstr_Record,&cfstr_P,
                         &cfstr_L,&cfstr_A);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_recordPressedImageAqua = pvVar1;
  pvVar1 = _objc_msgSend(cls_HSPlaybackControlImagesProvider,
                         sel_sharedPlaybackControlsImagesProvider);
  pvVar1 = _objc_msgSend(pvVar1,sel_playbackImageOfType_state_size_tint_,&cfstr_Record,&cfstr_P,
                         &cfstr_L,&cfstr_G);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_recordPressedImageGraphite = pvVar1;
  pvVar1 = _objc_msgSend(cls_HSPlaybackControlImagesProvider,
                         sel_sharedPlaybackControlsImagesProvider);
  pvVar1 = _objc_msgSend(pvVar1,sel_playbackImageOfType_state_size_tint_,&cfstr_RecordOn,&cfstr_N,
                         &cfstr_L,&cfstr_A);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_onRecordImage = pvVar1;
  pvVar1 = _objc_msgSend(cls_HSPlaybackControlImagesProvider,
                         sel_sharedPlaybackControlsImagesProvider);
  pvVar1 = _objc_msgSend(pvVar1,sel_playbackImageOfType_state_size_tint_,&cfstr_RecordOn,&cfstr_P,
                         &cfstr_L,&cfstr_A);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_onRecordPressedImage = pvVar1;
  pvVar1 = _objc_msgSend(self->_playbackMatrix,sel_cellAtRow_column_,0,0);
  _objc_msgSend(pvVar1,sel_setAquaAlternateImage_,self->_recordPressedImageAqua);
  pvVar1 = _objc_msgSend(self->_playbackMatrix,sel_cellAtRow_column_,0,0);
  _objc_msgSend(pvVar1,sel_setGraphiteAlternateImage_,self->_recordPressedImageGraphite);
  pvVar1 = _objc_msgSend(self->_playbackMatrix,sel_cellAtRow_column_,0,1);
  _objc_msgSend(pvVar1,sel_setAquaAlternateImage_,self->_playPressedImageAqua);
  pvVar1 = _objc_msgSend(self->_playbackMatrix,sel_cellAtRow_column_,0,1);
  _objc_msgSend(pvVar1,sel_setGraphiteAlternateImage_,self->_playPressedImageGraphite);
  _objc_msgSend(self,sel_setPlaybackButtonsDelegate_,self);
  pvVar1 = _objc_msgSend(self,sel_videoCaptureDeviceList);
  pvVar2 = _objc_msgSend(self->_videoCaptureDevicesPopUp,sel_menu);
  _objc_msgSend(pvVar1,sel_attachMenu_,pvVar2);
  pvVar1 = _objc_msgSend(self,sel_audioCaptureDeviceList);
  pvVar2 = _objc_msgSend(self->_audioCaptureDevicesPopUp,sel_menu);
  _objc_msgSend(pvVar1,sel_attachMenu_,pvVar2);
  _objc_msgSend(self->_recordProgressBox,sel_setHidden_,1);
  _objc_msgSend(self->_recordProgressIndicator,sel_setUsesThreadedAnimation_,1);
  _objc_msgSend(self,sel_setRecordDuration_forTextField_,0,0,self->_recordedTimeTextField);
  _objc_msgSend(self,sel_updateUI);
  return;
}

*/
- (void)awakeFromNib
{
    _recordPreviewView = [[HSCaptureView alloc] initWithFrame:[[_playbackRecordViewContainer contentView] bounds]];
    [_recordPreviewView enableOpenGLSurface];
    [_playbackRecordViewContainer setContentView:_recordPreviewView];
    [_imageView addSubview:_recordedTimeView positioned:NSWindowBelow relativeTo:_playbackMatrix];
    [_imageView setImage:[[[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"Countdown" ofType:@"pdf"]] autorelease]];
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
    _onRecordPressedImage = [[[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"RecordOn" state:@"P" size:@"L" tint:@"A"] retain];
    [(HSAppearanceButtonCell *)[_playbackMatrix cellAtRow:0 column:0] setAquaAlternateImage:_recordPressedImageAqua];
    [(HSAppearanceButtonCell *)[_playbackMatrix cellAtRow:0 column:0] setGraphiteAlternateImage:_recordPressedImageGraphite];
    [(HSAppearanceButtonCell *)[_playbackMatrix cellAtRow:0 column:1] setAquaAlternateImage:_playPressedImageAqua];
    [(HSAppearanceButtonCell *)[_playbackMatrix cellAtRow:0 column:1] setGraphiteAlternateImage:_playPressedImageGraphite];
    [self setPlaybackButtonsDelegate:self];
    [[self videoCaptureDeviceList] attachMenu:[_videoCaptureDevicesPopUp menu]];
    [[self audioCaptureDeviceList] attachMenu:[_audioCaptureDevicesPopUp menu]];
    [_recordProgressBox setHidden:YES];
    [_recordProgressIndicator setUsesThreadedAnimation:YES];
    [self setRecordDuration:0.0 forTextField:_recordedTimeTextField];
    [self updateUI];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0015bd87 @ 0015bd87, 764 bytes * /

void FUN_0015bd87(HSVideoRecordingController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  HSVideoRecordingController *pHVar3;
  HSVideoRecordingController *local_1c;
  undefined *local_18;
  
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  pHVar3 = self;
  _objc_msgSend(pvVar1,sel_removeObserver_,self);
  _objc_msgSend(self,sel_removeTimerForMeasurementRecordDuration);
  _objc_msgSend(self->_captureVideoDevice,sel_release);
  self->_captureVideoDevice = (id)0x0;
  _objc_msgSend(self->_captureAudioDevice,sel_release);
  self->_captureAudioDevice = (id)0x0;
  if (self->_movieFilePath != (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_isRecording,pHVar3);
    if ((char)pvVar1 != '\0') {
      _objc_msgSend(self,sel_stopRecord);
    }
    _objc_msgSend(self->_movieFilePath,sel_release);
  }
  _objc_msgSend(self->_captureDeviceSessionError,sel_release);
  _objc_msgSend(self->_countDownViewController,sel_release);
  _objc_msgSend(self->_recordedTimeView,sel_release);
  _objc_msgSend(self->_playbackTimeView,sel_release);
  _objc_msgSend(self->_playbackPreviewView,sel_release);
  _objc_msgSend(self->_recordPreviewView,sel_release);
  _objc_msgSend(self->_playImage,sel_release);
  _objc_msgSend(self->_stopImage,sel_release);
  _objc_msgSend(self->_playPressedImageAqua,sel_release);
  _objc_msgSend(self->_playPressedImageGraphite,sel_release);
  _objc_msgSend(self->_stopPressedImageAqua,sel_release);
  _objc_msgSend(self->_stopPressedImageGraphite,sel_release);
  _objc_msgSend(self->_recordImage,sel_release);
  _objc_msgSend(self->_recordPressedImageAqua,sel_release);
  _objc_msgSend(self->_recordPressedImageGraphite,sel_release);
  _objc_msgSend(self->_onRecordImage,sel_release);
  _objc_msgSend(self->_onRecordPressedImage,sel_release);
  _objc_msgSend(self->_recordingPanel,sel_release);
  pvVar1 = self->_videoCaptureDeviceList;
  pvVar2 = _objc_msgSend(self->_videoCaptureDevicesPopUp,sel_menu);
  _objc_msgSend(pvVar1,sel_detachMenu_,pvVar2);
  _objc_msgSend(self->_videoCaptureDeviceList,sel_release);
  pvVar1 = self->_audioCaptureDeviceList;
  pvVar2 = _objc_msgSend(self->_audioCaptureDevicesPopUp,sel_menu);
  _objc_msgSend(pvVar1,sel_detachMenu_,pvVar2);
  _objc_msgSend(self->_audioCaptureDeviceList,sel_release);
  local_1c = self;
  local_18 = PTR_s_NSObject_00351ce0;
  _objc_msgSendSuper(&local_1c,sel_dealloc);
  return;
}

*/
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeTimerForMeasurementRecordDuration];
    [_captureVideoDevice release];
    _captureVideoDevice = nil;
    [_captureAudioDevice release];
    _captureAudioDevice = nil;
    if (_movieFilePath != nil) {
        if ([self isRecording]) {
            [self stopRecord];
        }
        [_movieFilePath release];
    }
    [_captureDeviceSessionError release];
    [_countDownViewController release];
    [_recordedTimeView release];
    [_playbackTimeView release];
    [_playbackPreviewView release];
    [_recordPreviewView release];
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
    [_onRecordPressedImage release];
    [_recordingPanel release];
    [_videoCaptureDeviceList detachMenu:[_videoCaptureDevicesPopUp menu]];
    [_videoCaptureDeviceList release];
    [_audioCaptureDeviceList detachMenu:[_audioCaptureDevicesPopUp menu]];
    [_audioCaptureDeviceList release];
    [super dealloc];
}

@end

