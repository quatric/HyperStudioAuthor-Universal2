#import "HSHyperCastingWindowController.h"

@implementation HSHyperCastingWindowController

/* i386 ivar offsets: _stackRecorder=0x78, _isRecording=0x7c, _recordingPath=0x80, _recordedMovieFormat=0x84, _exportProgressSheetController=0x88, _hyperCastingModePane=0x8c, _hyperCastingWindowControllerDelegate=0x90, _roundedCornersForMovie=0x94, _movieSize=0x98 */

- (void)windowWillClose:(id)aClose
{
    [_stackRecorder cancelRecording];
    [super windowWillClose:aClose];
}

- (BOOL)canInNavigationController:(id)aController performNavigationOperation:(id)aOperation
{
    if ([aOperation destinationStackURL] != nil) {
        if (![[aOperation destinationStackURL] isEqual:[[self document] fileURL]]) {
            return NO;
        }
    }
    return ![aOperation shouldOpenUntitledDocument];
}

- (BOOL)canGoInNavigationController:(id)aController toCardAtIndex:(NSInteger)aIndex inStackAtURL:(id)aURL
{
    BOOL bVar2;

    if (aURL == nil) {
        bVar2 = YES;
    }
    else {
        bVar2 = [aURL isEqual:[[self document] fileURL]];
    }
    return bVar2;
}

- (BOOL)canGoToHomeInNavigationController:(id)aController
{
    return NO;
}

- (void)cancelExport:(id)aExport
{
    [self cancelRecording];
    [self endExportProgressSheet];
}

- (void)operationsAfterFinishRecordingFileAtPath:(id)aPath
{
    [self endExportProgressSheet];
    if ([_hyperCastingWindowControllerDelegate respondsToSelector:@selector(didConfirmHyperCastingWindowController:)]) {
        [_hyperCastingWindowControllerDelegate didConfirmHyperCastingWindowController:self];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00240b81 @ 00240b81, 541 bytes * /

void FUN_00240b81(HSHyperCastingWindowController *self,SEL _cmd,
                 id operationsAfterCancelRecordingWithError)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  SEL op;
  undefined4 uVar3;
  
  _objc_msgSend(self,sel_endExportProgressSheet);
  self_00 = cls_NSAlert;
  if (operationsAfterCancelRecordingWithError != (id)0x0) {
    pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                           &cfstr_HSInternalQuickTimeErrorString_RecoverySuggestio,&cfstr_empty,
                           &cfstr_Alerts);
    pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                           &cfstr_HSInternalQuickTimeErrorString_Description,&cfstr_empty,
                           &cfstr_Alerts);
    pvVar1 = _objc_msgSend(self_00,
                           sel_alertWithMessageText_defaultButton_alternateButton_otherButton_informativeTextWithFormat_
                           ,pvVar2,&cfstr_OK,0,0,pvVar1);
    pvVar1 = _objc_msgSend(pvVar1,sel_retain);
    _objc_msgSend(pvVar1,sel_runModal);
    _objc_msgSend(pvVar1,sel_release);
  }
  pvVar1 = _objc_msgSend(operationsAfterCancelRecordingWithError,sel_domain);
  uVar3 = *(undefined4 *)PTR_003368a0;
  pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_,uVar3);
  if (((char)pvVar1 == '\0') ||
     (pvVar1 = _objc_msgSend(operationsAfterCancelRecordingWithError,sel_code,uVar3),
     pvVar1 != (id)0x4b0)) {
    pvVar1 = _objc_msgSend(self->_hyperCastingWindowControllerDelegate,sel_respondsToSelector_,
                           sel_didCancelHyperCastingWindowController_);
    if ((char)pvVar1 == '\0') {
      return;
    }
    pvVar1 = self->_hyperCastingWindowControllerDelegate;
    op = sel_didCancelHyperCastingWindowController_;
  }
  else {
    pvVar1 = _objc_msgSend(self->_hyperCastingWindowControllerDelegate,sel_respondsToSelector_,
                           sel_didConfirmHyperCastingWindowController_);
    if ((char)pvVar1 == '\0') {
      return;
    }
    pvVar1 = self->_hyperCastingWindowControllerDelegate;
    op = sel_didConfirmHyperCastingWindowController_;
  }
  _objc_msgSend(pvVar1,op,self);
  return;
}

*/
- (void)operationsAfterCancelRecordingWithError:(id)aError
{
    [self endExportProgressSheet];
    if (aError != nil) {
        HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
        NSString *informativeText = [provider localizedStringForKey:@"HSInternalQuickTimeErrorString-RecoverySuggestion" value:@"" table:@"Alerts"];
        NSString *messageText = [provider localizedStringForKey:@"HSInternalQuickTimeErrorString-Description" value:@"" table:@"Alerts"];
        NSAlert *alert = [[NSAlert alertWithMessageText:messageText defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", informativeText] retain];
        [alert runModal];
        [alert release];
    }
    if ([[aError domain] isEqualToString:QTKitErrorDomain] && [aError code] == 0x4b0) {
        if ([_hyperCastingWindowControllerDelegate respondsToSelector:@selector(didConfirmHyperCastingWindowController:)]) {
            [_hyperCastingWindowControllerDelegate didConfirmHyperCastingWindowController:self];
        }
    } else if ([_hyperCastingWindowControllerDelegate respondsToSelector:@selector(didCancelHyperCastingWindowController:)]) {
        [_hyperCastingWindowControllerDelegate didCancelHyperCastingWindowController:self];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00240d9e @ 00240d9e, 86 bytes * /

void FUN_00240d9e(HSHyperCastingWindowController *self,SEL _cmd,id recorder,
                 id didFinishRecordingToOutputFileAtPath,id dueToError)

{
  undefined *puVar1;
  
  puVar1 = sel_operationsAfterFinishRecordingFileAtPath_;
  if (dueToError != (id)0x0) {
    puVar1 = sel_operationsAfterCancelRecordingWithError_;
    didFinishRecordingToOutputFileAtPath = dueToError;
  }
  _objc_msgSend(self,sel_performSelectorOnMainThread_withObject_waitUntilDone_,puVar1,
                didFinishRecordingToOutputFileAtPath,0);
  return;
}

*/
- (void)recorder:(id)aRecorder didFinishRecordingToOutputFileAtPath:(id)aPath dueToError:(id)aError
{
    SEL selector = @selector(operationsAfterFinishRecordingFileAtPath:);
    id argument = aPath;
    if (aError != nil) {
        selector = @selector(operationsAfterCancelRecordingWithError:);
        argument = aError;
    }
    [self performSelectorOnMainThread:selector withObject:argument waitUntilDone:NO];
}

- (void)confirmHyperCastingModePane:(id)aPane
{
    id pvVar1_6;

    [self endHyperCastingModePane];
    [[HSObjectAssistantController sharedAssistantController] setLocked:NO delegate:nil];
    [[HSObjectAssistantController sharedAssistantController] setSelectedInModelObjectAndBringAssistantToFront:nil];
    [[[[self document] navigationController] presentationSync] endPresentation];
    pvVar1_6 = [self exportProgressSheetController];
    [pvVar1_6 setProgressIndicatorIndeterminate:YES];
    [pvVar1_6 setDelegate:self];
    [pvVar1_6 beginSheetForWindow:[self window]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00240f40 @ 00240f40, 166 bytes * /

void FUN_00240f40(HSHyperCastingWindowController *self,SEL _cmd,id cancelHyperCastingModePane)

{
  id pvVar1;
  HSHyperCastingWindowController *pHVar2;
  
  self->_isRecording = '\0';
  pHVar2 = (HSHyperCastingWindowController *)sel_didCancelHyperCastingWindowController_;
  pvVar1 = _objc_msgSend(self->_hyperCastingWindowControllerDelegate,sel_respondsToSelector_,
                         sel_didCancelHyperCastingWindowController_);
  if ((char)pvVar1 != '\0') {
    pHVar2 = self;
    _objc_msgSend(self->_hyperCastingWindowControllerDelegate,
                  sel_didCancelHyperCastingWindowController_,self);
  }
  pvVar1 = _objc_msgSend(self,sel_document,pHVar2);
  pvVar1 = _objc_msgSend(pvVar1,sel_navigationController);
  pvVar1 = _objc_msgSend(pvVar1,sel_presentationSync);
  _objc_msgSend(pvVar1,sel_endPresentation);
  return;
}

*/
- (void)cancelHyperCastingModePane:(id)aPane
{
    _isRecording = NO;
    if ([_hyperCastingWindowControllerDelegate respondsToSelector:@selector(didCancelHyperCastingWindowController:)]) {
        [_hyperCastingWindowControllerDelegate didCancelHyperCastingWindowController:self];
    }
    [[[[self document] navigationController] presentationSync] endPresentation];
}

- (void)setOutputToInputDevice:(id)aDevice
{
    if (_isRecording == NO) {
        [[self stackRecorder] setAudioOutToInCaptureDevice:aDevice];
    }
}

- (void)setVoiceInputDevice:(id)aDevice
{
    if (_isRecording == NO) {
        [[self stackRecorder] setAudioVoiceCaptureDevice:aDevice];
    }
}

- (void)cancelRecording
{
    [[self stackRecorder] cancelRecording];
    _isRecording = NO;
    if ([_hyperCastingWindowControllerDelegate respondsToSelector:@selector(didCancelHyperCastingWindowController:)]) {
        [_hyperCastingWindowControllerDelegate didCancelHyperCastingWindowController:self];
    }
}

- (void)stopRecording
{
    [[self stackRecorder] stopRecording];
    _isRecording = NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024113a @ 0024113a, 214 bytes * /

BOOL FUN_0024113a(HSHyperCastingWindowController *self,SEL _cmd)

{
  BOOL BVar1;
  id pvVar2;
  id pvVar3;
  undefined4 extraout_EDX;
  
  pvVar2 = _objc_msgSend(self,sel_stackRecorder);
  if ((pvVar2 == (id)0x0) || (self->_recordingPath == (id)0x0)) {
    BVar1 = '\0';
  }
  else {
    _objc_msgSend(self,sel_runAutomaticTimersAndArrivingActions);
    _objc_msgSend(pvVar2,sel_setRoundedCornersForMovie_,(int)self->_roundedCornersForMovie);
    pvVar3 = _objc_msgSend(self,sel_movieSize);
    _objc_msgSend(pvVar2,sel_setMovieSize_,pvVar3,extraout_EDX);
    pvVar2 = _objc_msgSend(pvVar2,sel_startRecordingToOutputFilePath_,self->_recordingPath);
    BVar1 = (BOOL)pvVar2;
    self->_isRecording = BVar1;
  }
  return BVar1;
}

*/
- (BOOL)startRecording
{
    HSRecorder *recorder = [self stackRecorder];
    if (recorder == nil || _recordingPath == nil) {
        return NO;
    }
    [self runAutomaticTimersAndArrivingActions];
    [recorder setRoundedCornersForMovie:_roundedCornersForMovie];
    [recorder setMovieSize:[self movieSize]];
    _isRecording = [recorder startRecordingToOutputFilePath:_recordingPath];
    return _isRecording;
    return 0;
}

- (BOOL)prepareToStart
{
    return (BOOL)[[self stackRecorder] prepareToRecordWithAttributes:nil];
}

- (BOOL)isRecording
{
    return _isRecording;
}

- (id)outputFileName
{
    NSString *pcVar1;

    if (_recordingPath == nil) {
        pcVar1 = @"";
    }
    else {
        pcVar1 = [_recordingPath lastPathComponent];
    }
    return pcVar1;
}

- (id)documentName
{
    return [[self document] displayName];
}

- (void)endHyperCastingModePane
{
    [_hyperCastingModePane dismiss:YES];
}

- (void)endExportProgressSheet
{
    id self_00;

    self_00 = [self exportProgressSheetController];
    [self_00 endSheet];
    [self_00 setDelegate:0];
}

- (id)exportProgressSheetController
{
    HSExportProgressSheetController *pHVar1;

    pHVar1 = _exportProgressSheetController;
    if (pHVar1 == nil) {
        pHVar1 = [HSExportProgressSheetController new];
        _exportProgressSheetController = pHVar1;
    }
    return pHVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00241391 @ 00241391, 198 bytes * /

id FUN_00241391(HSHyperCastingWindowController *self,SEL _cmd)

{
  HSRecorder *pHVar1;
  id pvVar2;
  
  pHVar1 = self->_stackRecorder;
  if (pHVar1 == (HSRecorder *)0x0) {
    pHVar1 = _objc_msgSend(cls_HSRecorder,sel_new);
    self->_stackRecorder = pHVar1;
    _objc_msgSend(pHVar1,sel_setDelegate_,self);
    pHVar1 = self->_stackRecorder;
    pvVar2 = _objc_msgSend(self,sel_playerView);
    _objc_msgSend(pHVar1,sel_setDataSource_,pvVar2);
    _objc_msgSend(self->_stackRecorder,sel_setFramesPerSecondLimit_,0,0x40240000);
    _objc_msgSend(self->_stackRecorder,sel_setLazyMovieCreation_,0);
    pHVar1 = self->_stackRecorder;
  }
  return pHVar1;
}

*/
- (id)stackRecorder
{
    if (_stackRecorder == nil) {
        _stackRecorder = [HSRecorder new];
        [_stackRecorder setDelegate:self];
        [_stackRecorder setDataSource:[self playerView]];
        [_stackRecorder setFramesPerSecondLimit:10.0];
        [_stackRecorder setLazyMovieCreation:NO];
    }
    return _stackRecorder;
    return 0;
}

- (void)setHyperCastingWindowControllerDelegate:(id)aDelegate
{
    _hyperCastingWindowControllerDelegate = aDelegate;
}

- (id)hyperCastingWindowControllerDelegate
{
    return _hyperCastingWindowControllerDelegate;
}

- (double)framesPerSecondLimit
{
    return [[self stackRecorder] framesPerSecondLimit];
}

- (void)setFramesPerSecondLimit:(double)aLimit
{
    [[self stackRecorder] setFramesPerSecondLimit:aLimit];
}

- (void)setMovieSize:(NSSize)aSize
{
    (_movieSize).width = aSize.width;
    (_movieSize).height = aSize.height;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002408ce @ 002408ce, 20 bytes * /

ulonglong FUN_002408ce(HSHyperCastingWindowController *self,SEL _cmd)

{
  ulonglong uVar1;
  
  uVar1._0_4_ = (self->_movieSize).width;
  uVar1._4_4_ = (self->_movieSize).height;
  return uVar1;
}

*/
- (NSSize)movieSize
{
    return _movieSize;
    return (NSSize){0};
}

- (void)setRoundedCornersForMovie:(BOOL)aMovie
{
    _roundedCornersForMovie = aMovie;
}

- (BOOL)roundedCornersForMovie
{
    return _roundedCornersForMovie;
}

- (void)setRecordedMovieFormat:(NSInteger)aFormat
{
    _recordedMovieFormat = aFormat;
}

- (NSInteger)recordedMovieFormat
{
    return _recordedMovieFormat;
}

- (void)setRecordingPath:(id)aPath
{
    if (![_recordingPath isEqualToString:aPath]) {
        [_recordingPath release];
        _recordingPath = [aPath retain];
    }
}

- (id)recordingPath
{
    return _recordingPath;
}

- (BOOL)validateUserInterfaceItem:(id)aItem
{
    return NO;
}

- (id)windowWillReturnUndoManager:(id)aManager
{
    return nil;
}

- (void)willBecameNonWorkingInModeSwitcher:(id)aSwitcher
{
    if ([self isRecording]) {
        [self cancelRecording];
    }
    [[[self document] actionExecutionContext] decreaseHyperCastingMode];
    [[[self window] toolbar] setAllowsUserCustomization:YES];
    [[[self document] navigationController] setDelegate:0];
    [_hyperCastingModePane setRecordingProvider:nil];
    [_hyperCastingModePane setHyperCastingModePaneDelegate:nil];
    [_hyperCastingModePane release];
    _hyperCastingModePane = nil;
    [[HSObjectAssistantController sharedAssistantController] setLocked:NO delegate:nil];
    [[HSObjectAssistantController sharedAssistantController] setSelectedInModelObjectAndBringAssistantToFront:nil];
    [_stackRecorder setDelegate:0];
    [_stackRecorder setDataSource:0];
    [_stackRecorder release];
    _stackRecorder = nil;
    [super willBecameNonWorkingInModeSwitcher:aSwitcher];
}

- (void)didBecomeWorkingInModeSwitcher:(id)aSwitcher
{
    HSHyperCastingModePane *self_00;
    id pvVar1_13;
    id pvVar2_4;

    [super didBecomeWorkingInModeSwitcher:aSwitcher];
    [[[self document] actionExecutionContext] increaseHyperCastingMode];
    [[[self document] undoManager] disableUndoRegistration];
    [[[self document] stack] removeAllTemporaryObjects];
    [[[self document] undoManager] enableUndoRegistration];
    [[[self window] toolbar] setAllowsUserCustomization:NO];
    [[[self document] navigationController] setDelegate:self];
    pvVar1_13 = [HSObjectAssistantController sharedAssistantController];
    [pvVar1_13 setSelectedInModelObjectAndBringAssistantToFront:[[self document] stack]];
    [pvVar1_13 setActive:YES explicitlyByUser:NO];
    [pvVar1_13 setLocked:YES delegate:nil];
    self_00 = [HSHyperCastingModePane new];
    _hyperCastingModePane = self_00;
    [self_00 setRecordingProvider:self];
    [_hyperCastingModePane setHyperCastingModePaneDelegate:self];
    pvVar2_4 = [[HSObjectAssistantNavigationController alloc] initWithRootViewController:_hyperCastingModePane identifier:nil];
    [[pvVar1_13 objectAssistant] openAssistantPane:pvVar2_4];
    [pvVar2_4 release];
}

- (BOOL)needRunArrivingActions
{
    return NO;
}

- (id)modeSwitcherView:(id)aView
{
    return [self cardView];
}

- (BOOL)ownsScrollViewForModeSwitcherViewEmbedding
{
    return YES;
}

- (void)dealloc
{
    if ([self isRecording]) {
        [self stopRecording];
    }
    [_stackRecorder setDelegate:0];
    [_stackRecorder setDataSource:0];
    [_stackRecorder release];
    [_recordingPath release];
    [_exportProgressSheetController release];
    [_hyperCastingModePane setRecordingProvider:nil];
    [_hyperCastingModePane setHyperCastingModePaneDelegate:nil];
    [_hyperCastingModePane release];
    _hyperCastingModePane = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _recordedMovieFormat = 0;
    }
    return self;
}

@end

