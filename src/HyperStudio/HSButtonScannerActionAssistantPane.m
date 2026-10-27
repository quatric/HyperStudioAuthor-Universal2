#import "HSButtonScannerActionAssistantPane.h"

@implementation HSButtonScannerActionAssistantPane

/* i386 ivar offsets: _scanDelayTextField=0x88, _scanDelayStepper=0x8c, _resetDelayTextField=0x90, _resetDelayStepper=0x94, _scanCyclesTextField=0x98, _scanCyclesStepper=0x9c, _scanCyclesMatrix=0xa0, _audioCueTypeMatrix=0xa4, _audioMediaNameTextField=0xa8, _chooseAudioMediaButton=0xac, _hideCursorCheckBox=0xb0, _playButtonCell=0xb4, _audioMediaNameContainer=0xb8, _previewSoundObject=0xbc, _importSoundObjectDialogController=0xc0 */

+ (id)stopButtonGraphiteImage
{
    return [[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Stop" state:@"P" size:@"S" tint:@"G"];
}

+ (id)stopButtonAquaImage
{
    return [[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Stop" state:@"P" size:@"S" tint:@"A"];
}

+ (id)stopButtonImage
{
    return [[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Stop" state:@"N" size:@"S" tint:@"A"];
}

+ (id)playButtonGraphiteImage
{
    return [[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Play" state:@"P" size:@"S" tint:@"G"];
}

+ (id)playButtonAquaImage
{
    return [[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Play" state:@"P" size:@"S" tint:@"A"];
}

+ (id)playButtonImage
{
    return [[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Play" state:@"N" size:@"S" tint:@"A"];
}

- (void)hideCursorChanged:(id)aChanged
{
    [[self buttonScannerActionAssistantPaneApplier] setHidesCursor:(unsigned int)([aChanged intValue] != 0)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00237fb8 @ 00237fb8, 147 bytes * /

void FUN_00237fb8(HSButtonScannerActionAssistantPane *self,SEL _cmd,id playAudioMedia)

{
  id pvVar1;
  HSButtonScannerActionAssistantPane *self_00;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_isPlaying);
  self_00 = self;
  op = sel_stopPlaying;
  if ((char)pvVar1 == '\0') {
    self_00 = _objc_msgSend(cls_HSMediaPlaySynchronizer,sel_sharedSynchronizer);
    _objc_msgSend(self,sel_previewSoundObject);
    op = sel_playMediaSingle_;
  }
  _objc_msgSend(self_00,op);
  _objc_msgSend(self,sel_validateUserInterface);
  return;
}

*/
- (void)playAudioMedia:(id)aMedia
{
    if ([self isPlaying]) {
        [self stopPlaying];
    } else {
        [[HSMediaPlaySynchronizer sharedSynchronizer] playMediaSingle:[self previewSoundObject]];
    }
    [self validateUserInterface];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00237e3c @ 00237e3c, 380 bytes * /

void FUN_00237e3c(HSButtonScannerActionAssistantPane *self,SEL _cmd,id audioMediaChanged)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar1 = _objc_msgSend(self,sel_importSoundObjectDialogController);
  pvVar2 = _objc_msgSend(self,sel_stack);
  pvVar2 = _objc_msgSend(pvVar2,sel_document);
  _objc_msgSend(pvVar1,sel_setHyperDocument_,pvVar2);
  self_00 = cls_HSImportDialogController;
  pvVar2 = _objc_msgSend(self,sel_assistant);
  pvVar2 = _objc_msgSend(pvVar2,sel_object);
  pvVar2 = _objc_msgSend(self_00,sel_defaultButtonTitleForObject_,pvVar2);
  _objc_msgSend(pvVar1,sel_setDefaultButtonTitle_,pvVar2);
  pvVar3 = _objc_msgSend(pvVar1,sel_runModal);
  if (pvVar3 == (id)0x1) {
    pvVar3 = _objc_msgSend(pvVar1,sel_fileName,pvVar2);
    if (pvVar3 != (id)0x0) {
      pvVar1 = _objc_msgSend(pvVar1,sel_fileName,pvVar2);
      pvVar2 = _objc_msgSend(cls_HSNewMedia,sel_mediaWithPath_,pvVar1);
      if (pvVar2 != (id)0x0) {
        pvVar1 = _objc_msgSend(self,sel_buttonScannerActionAssistantPaneApplier,pvVar1);
        _objc_msgSend(pvVar1,sel_setAudioMedia_,pvVar2);
        _objc_msgSend(self,sel_invalidatePreviewSoundObject);
        _objc_msgSend(self,sel_validateUserInterface);
      }
    }
  }
  return;
}

*/
- (void)audioMediaChanged:(id)aChanged
{
    id dialog = [self importSoundObjectDialogController];
    [dialog setHyperDocument:[[self stack] document]];
    [dialog setDefaultButtonTitle:[HSImportDialogController defaultButtonTitleForObject:[[self assistant] object]]];
    if ([dialog runModal] == NSOKButton) {
        if ([dialog fileName] != nil) {
            id media = [HSNewMedia mediaWithPath:[dialog fileName]];
            if (media != nil) {
                [[self buttonScannerActionAssistantPaneApplier] setAudioMedia:media];
                [self invalidatePreviewSoundObject];
                [self validateUserInterface];
            }
        }
    }
}

- (void)audioCueTypeChanged:(id)aChanged
{
    [[self buttonScannerActionAssistantPaneApplier] setAudioCueType:[aChanged selectedTag]];
    if ([self isPlaying]) {
        [self stopPlaying];
    }
    [self validateUserInterface];
}

- (void)scanCyclesCountChanged:(id)aChanged
{
    NSInteger pvVar1;
    id self_00;
    int pvVar1_2;

    if (_scanCyclesMatrix == aChanged) {
        pvVar1 = [_scanCyclesMatrix selectedTag];
        self_00 = [self buttonScannerActionAssistantPaneApplier];
        if (pvVar1 == 0) {
            pvVar1_2 = 0;
        }
        else {
            pvVar1_2 = [_scanCyclesTextField intValue];
        }
    }
    else {
        self_00 = [self buttonScannerActionAssistantPaneApplier];
        pvVar1_2 = [aChanged intValue];
    }
    [self_00 setScanCyclesCount:pvVar1_2];
    [self validateUserInterface];
}

- (void)resetDelayChanged:(id)aChanged
{
    [[self buttonScannerActionAssistantPaneApplier] setResetDelay:(float)[aChanged floatValue]];
    [self validateUserInterface];
}

- (void)scanDelayChanged:(id)aChanged
{
    [[self buttonScannerActionAssistantPaneApplier] setScanDelay:(float)[aChanged floatValue]];
    [self validateUserInterface];
}

- (void)movieDidStop:(id)aStop
{
    [self movieDidEnd:aStop];
}

- (void)movieDidPlayOnce:(id)aOnce
{

}

- (void)movieDidChangeImage:(id)aImage
{

}

- (void)movieDidEnd:(id)aEnd
{
    [aEnd gotoBeginning];
    [self validateUserInterface];
}

- (id)actionAttributesAudioMediaFileURL
{
    id pvVar1_3;
    NSURL *pvVar1_4;

    pvVar1_3 = [[[self actionAttributes] audioMedia] fullPathToMediaFileCreateIfNeeded:YES];
    if (pvVar1_3 == nil) {
        pvVar1_4 = nil;
    }
    else {
        pvVar1_4 = [NSURL fileURLWithPath:pvVar1_3];
    }
    return pvVar1_4;
}

- (void)invalidatePreviewSoundObject
{
    if ([_previewSoundObject isPlaying]) {
        [_previewSoundObject stop];
    }
    if ([_previewSoundObject delegate] == self) {
        [_previewSoundObject setDelegate:0];
    }
    [_previewSoundObject release];
    _previewSoundObject = nil;
}

- (id)previewSoundObject
{
    id pvVar1;
    id pvVar1_2;

    if (_previewSoundObject == nil) {
        pvVar1 = [self actionAttributesAudioMediaFileURL];
        if (pvVar1 != nil) {
            pvVar1_2 = [[HSMovie alloc] initWithURL:pvVar1 error:0];
            _previewSoundObject = pvVar1_2;
            [pvVar1_2 setDelegate:self];
        }
    }
    return _previewSoundObject;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00237a3d @ 00237a3d, 94 bytes * /

id FUN_00237a3d(HSButtonScannerActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = self->_importSoundObjectDialogController;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_HSImportDialogController,sel_alloc);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithDialogType_,*(undefined4 *)PTR_PTR_003360dc);
    self->_importSoundObjectDialogController = pvVar1;
  }
  return pvVar1;
}

*/
- (id)importSoundObjectDialogController
{
    if (_importSoundObjectDialogController == nil) {
        _importSoundObjectDialogController = [[HSImportDialogController alloc] initWithDialogType:HSImportDialogControllerTypeSound];
    }
    return _importSoundObjectDialogController;
    return 0;
}

- (void)validateUIWithNotification:(id)aNotification
{
    [self validateUserInterface];
}

- (void)stopPlaying
{
    [_previewSoundObject stop];
    [_previewSoundObject gotoBeginning];
}

- (BOOL)isPlaying
{
    return (BOOL)[_previewSoundObject isPlaying];
}

- (void)validateUserInterface
{
    id pvVar1;
    id pvVar3;
    BOOL uVar6;
    id pcVar7;
    NSUInteger pvVar2_5;
    NSInteger pvVar2_7;
    id pvVar2_8;
    id pvVar2_10;
    id pvVar3_5;
    NSBundle *pvVar3_6;
    BOOL pvVar3_9;
    id pvVar3_12;
    id pvVar4_2;
    Class pvVar4_5;

    pvVar1 = [self actionAttributes];
    [_scanDelayTextField setFloatValue:(float)[pvVar1 scanDelay]];
    [_scanDelayStepper setFloatValue:(float)[pvVar1 scanDelay]];
    [_resetDelayTextField setFloatValue:(float)[pvVar1 resetDelay]];
    [_resetDelayStepper setFloatValue:(float)[pvVar1 resetDelay]];
    pvVar2_5 = [pvVar1 scanCyclesCount];
    if (pvVar2_5 != 0) {
        [_scanCyclesMatrix selectCellWithTag:1];
        [_scanCyclesTextField setIntValue:pvVar2_5];
        [_scanCyclesStepper setIntValue:pvVar2_5];
        [_scanCyclesTextField setEnabled:YES];
        pvVar3 = _scanCyclesStepper;
    }
    else {
        [_scanCyclesMatrix selectCellWithTag:0];
        [_scanCyclesTextField setEnabled:NO];
        pvVar3 = _scanCyclesStepper;
    }
    [pvVar3 setEnabled:(unsigned int)(pvVar2_5 != 0)];
    [_audioCueTypeMatrix selectCellWithTag:[pvVar1 audioCueType]];
    pvVar2_7 = [_audioCueTypeMatrix selectedTag];
    uVar6 = (unsigned int)(pvVar2_7 == 0x2);
    [_chooseAudioMediaButton setEnabled:uVar6];
    [_audioMediaNameContainer setHyperEnabled:uVar6];
    pvVar3_5 = [[[self actionAttributes] audioMedia] mediaName];
    if (pvVar3_5 == nil) {
        pvVar3_5 = [NSString string];
    }
    [_audioMediaNameTextField setStringValue:pvVar3_5];
    pvVar3_6 = [NSBundle mainBundle];
    pvVar4_2 = [[self actionAttributes] audioMediaUID];
    pcVar7 = @"Change";
    if (pvVar4_2 == nil) {
        pcVar7 = @"Choose";
    }
    [_chooseAudioMediaButton setTitle:[[pvVar3_6 localizedStringForKey:pcVar7 value:@"" table:@"AssistantPanes"] hyperStringByAddingEllipsis]];
    pvVar4_5 = [self class];
    [_playButtonCell setEnabled:((unsigned int)([self previewSoundObject] != nil && pvVar2_7 == 0x2))];
    pvVar3_9 = [self isPlaying];
    pvVar2_8 = _playButtonCell;
    if (!pvVar3_9) {
        [pvVar2_8 setImage:[pvVar4_5 playButtonImage]];
        [_playButtonCell setAquaAlternateImage:[pvVar4_5 playButtonAquaImage]];
        pvVar2_10 = _playButtonCell;
        pvVar3_12 = [pvVar4_5 playButtonGraphiteImage];
    }
    else {
        [pvVar2_8 setImage:[pvVar4_5 stopButtonImage]];
        [_playButtonCell setAquaAlternateImage:[pvVar4_5 stopButtonAquaImage]];
        pvVar2_10 = _playButtonCell;
        pvVar3_12 = [pvVar4_5 stopButtonGraphiteImage];
    }
    [pvVar2_10 setGraphiteAlternateImage:pvVar3_12];
    [_hideCursorCheckBox setState:(unsigned int)([pvVar1 hidesCursor])];
}

- (id)initialKeyView
{
    return _scanDelayTextField;
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [self removeActionAssistantPaneObserver];
    [super viewWillDisappear:aDisappear];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [self validateUserInterface];
    [self addActionAssistantPaneObserver];
}

- (id)actionAttribute
{
    return (id)@protocol(HSButtonScannerActionAttributes);
}

- (id)actionAttributes
{
    return [[self buttonScannerActionAssistantPaneApplier] buttonScannerActionAttributes];
}

- (id)buttonScannerActionAssistantPaneApplier
{
    return [self applier];
}

- (Class)applierClass
{
    return [HSButtonScannerActionAssistantPaneApplier class];
}

- (id)actionType
{
    return [HSButtonScannerAction actionType];
}

- (void)dealloc
{
    [_importSoundObjectDialogController release];
    [self invalidatePreviewSoundObject];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"ButtonScannerAssistantPane"];
    return self;
}

@end

@implementation HSButtonScannerActionAssistantPaneApplier

/* i386 ivar offsets: _initialScanDelay=0x30, _scanDelay=0x34, _initialResetDelay=0x38, _resetDelay=0x3c, _initialScanCyclesCount=0x40, _scanCyclesCount=0x44, _initialAudioCueType=0x48, _audioCueType=0x4c, _initialAudioMedia=0x50, _audioMedia=0x54, _hidesCursor=0x58, _initialHidesCursor=0x59 */

- (void)setHidesCursor:(BOOL)aCursor
{
    if (_hidesCursor != aCursor) {
        _hidesCursor = aCursor;
        [self disableUndo];
        [[self buttonScannerActionAttributes] setHidesCursor:aCursor];
        [self enableUndo];
    }
}

- (void)setAudioMedia:(id)aMedia
{
    if (_audioMedia != aMedia) {
        [_audioMedia release];
        _audioMedia = [aMedia retain];
        [self disableUndo];
        [[self buttonScannerActionAttributes] setAudioMedia:_audioMedia];
        [self enableUndo];
    }
}

- (void)setAudioCueType:(NSInteger)aType
{
    if (_audioCueType != aType) {
        _audioCueType = aType;
        [self disableUndo];
        [[self buttonScannerActionAttributes] setAudioCueType:_audioCueType];
        [self enableUndo];
    }
}

- (void)setScanCyclesCount:(NSUInteger)aCount
{
    if (_scanCyclesCount != aCount) {
        _scanCyclesCount = aCount;
        [self disableUndo];
        [[self buttonScannerActionAttributes] setScanCyclesCount:_scanCyclesCount];
        [self enableUndo];
    }
}

- (void)setResetDelay:(CGFloat)aDelay
{
    if (_resetDelay != aDelay) {
        _resetDelay = aDelay;
        [self disableUndo];
        [[self buttonScannerActionAttributes] setResetDelay:_resetDelay];
        [self enableUndo];
    }
}

- (void)setScanDelay:(CGFloat)aDelay
{
    if (_scanDelay != aDelay) {
        _scanDelay = aDelay;
        [self disableUndo];
        [[self buttonScannerActionAttributes] setScanDelay:_scanDelay];
        [self enableUndo];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0023836b @ 0023836b, 364 bytes * /

BOOL FUN_0023836b(HSButtonScannerActionAssistantPaneApplier *self,SEL _cmd)

{
  float fVar1;
  float fVar2;
  id pvVar3;
  bool bVar4;
  float fVar5;
  float fVar6;
  HSButtonScannerActionAssistantPaneApplier *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_HSActionAssistantSettingsApplier_00355670;
  pvVar3 = _objc_msgSendSuper(&local_14,sel_areSettingsEqual);
  if ((char)pvVar3 != '\0') {
    fVar1 = self->_initialScanDelay;
    fVar2 = self->_scanDelay;
    if ((fVar1 != 0.0) || (NAN(fVar1))) {
      fVar5 = ABS(fVar1);
    }
    else {
      fVar5 = 1.0;
    }
    if ((fVar2 != 0.0) || (NAN(fVar2))) {
      fVar6 = ABS(fVar2);
    }
    else {
      fVar6 = 1.0;
    }
    if (fVar6 <= fVar5) {
      fVar6 = fVar5;
    }
    if (ABS(fVar1 - fVar2) <= fVar6 * 0.0005) {
      fVar1 = self->_initialResetDelay;
      fVar2 = self->_resetDelay;
      if ((fVar1 != 0.0) || (NAN(fVar1))) {
        fVar5 = ABS(fVar1);
      }
      else {
        fVar5 = 1.0;
      }
      if ((fVar2 != 0.0) || (NAN(fVar2))) {
        fVar6 = ABS(fVar2);
      }
      else {
        fVar6 = 1.0;
      }
      if (fVar6 <= fVar5) {
        fVar6 = fVar5;
      }
      if ((((ABS(fVar1 - fVar2) <= fVar6 * 0.0005) &&
           (self->_initialScanCyclesCount == self->_scanCyclesCount)) &&
          (self->_initialAudioCueType == self->_audioCueType)) &&
         (self->_initialHidesCursor = self->_hidesCursor, self->_hidesCursor != '\0')) {
        bVar4 = true;
        goto LAB_00238495;
      }
    }
  }
  bVar4 = false;
LAB_00238495:
  if ((self->_initialAudioMedia != (id)0x0) || (self->_audioMedia != (id)0x0)) {
    if (bVar4 == false) {
      bVar4 = false;
    }
    else {
      pvVar3 = _objc_msgSend(self->_initialAudioMedia,sel_isEqual_,self->_audioMedia);
      bVar4 = (char)pvVar3 != '\0';
    }
  }
  return bVar4;
}

*/
- (BOOL)areSettingsEqual
{
    BOOL equal = NO;
    if ([super areSettingsEqual]) {
        float a = _initialScanDelay;
        float b = _scanDelay;
        float scaleA = (a != 0.0f || a != a) ? fabsf(a) : 1.0f;
        float scaleB = (b != 0.0f || b != b) ? fabsf(b) : 1.0f;
        if (scaleB <= scaleA) {
            scaleB = scaleA;
        }
        if (fabsf(a - b) <= scaleB * 0.0005f) {
            a = _initialResetDelay;
            b = _resetDelay;
            scaleA = (a != 0.0f || a != a) ? fabsf(a) : 1.0f;
            scaleB = (b != 0.0f || b != b) ? fabsf(b) : 1.0f;
            if (scaleB <= scaleA) {
                scaleB = scaleA;
            }
            if (fabsf(a - b) <= scaleB * 0.0005f && _initialScanCyclesCount == _scanCyclesCount && _initialAudioCueType == _audioCueType) {
                /* the original assigns the initial value here instead of comparing it */
                _initialHidesCursor = _hidesCursor;
                if (_hidesCursor) {
                    equal = YES;
                }
            }
        }
    }
    if (_initialAudioMedia != nil || _audioMedia != nil) {
        equal = equal ? [_initialAudioMedia isEqual:_audioMedia] : NO;
    }
    return equal;
    return 0;
}

- (void)makeCurrentEqualToInitial
{
    _scanDelay = _initialScanDelay;
    _resetDelay = _initialResetDelay;
    _scanCyclesCount = _initialScanCyclesCount;
    _audioCueType = _initialAudioCueType;
    _hidesCursor = _initialHidesCursor;
    [_audioMedia autorelease];
    _audioMedia = [_initialAudioMedia retain];
    [super makeCurrentEqualToInitial];
}

- (void)makeInitialEqualToCurrent
{
    _initialScanDelay = _scanDelay;
    _initialResetDelay = _resetDelay;
    _initialScanCyclesCount = _scanCyclesCount;
    _initialAudioCueType = _audioCueType;
    _initialHidesCursor = _hidesCursor;
    [_initialAudioMedia autorelease];
    _initialAudioMedia = [_audioMedia retain];
    [super makeInitialEqualToCurrent];
}

- (void)setInitialSettingsToObject
{
    id self_00;
    id pvVar1;

    self_00 = [self buttonScannerActionAttributes];
    [self_00 setScanDelay:_initialScanDelay];
    [self_00 setResetDelay:_initialResetDelay];
    [self_00 setScanCyclesCount:_initialScanCyclesCount];
    [self_00 setAudioCueType:_initialAudioCueType];
    if (_initialAudioCueType == 2) {
        pvVar1 = _initialAudioMedia;
    }
    else {
        pvVar1 = nil;
    }
    [self_00 setAudioMedia:pvVar1];
    [self_00 setHidesCursor:_initialHidesCursor];
    [super setInitialSettingsToObject];
}

- (void)setCurrentSettingsToObject
{
    id self_00;
    id pvVar1;

    self_00 = [self buttonScannerActionAttributes];
    [self_00 setScanDelay:_scanDelay];
    [self_00 setResetDelay:_resetDelay];
    [self_00 setScanCyclesCount:_scanCyclesCount];
    [self_00 setAudioCueType:_audioCueType];
    if (_audioCueType == 2) {
        pvVar1 = _audioMedia;
    }
    else {
        pvVar1 = nil;
    }
    [self_00 setAudioMedia:pvVar1];
    [self_00 setHidesCursor:_hidesCursor];
    [super setCurrentSettingsToObject];
}

- (void)setUpInitialSettings
{
    id pvVar1;
    NSUInteger pvVar2;
    double dVar3;
    id pvVar1_3;
    NSInteger pvVar2_2;
    BOOL pvVar2_3;
    double dVar3_2;

    pvVar1 = [self buttonScannerActionAttributes];
    dVar3 = [pvVar1 scanDelay];
    _scanDelay = (float)dVar3;
    _initialScanDelay = (float)dVar3;
    dVar3_2 = [pvVar1 resetDelay];
    _resetDelay = (float)dVar3_2;
    _initialResetDelay = (float)dVar3_2;
    pvVar2 = [pvVar1 scanCyclesCount];
    _scanCyclesCount = (unsigned int)pvVar2;
    _initialScanCyclesCount = (unsigned int)pvVar2;
    pvVar2_2 = [pvVar1 audioCueType];
    _audioCueType = (int)pvVar2_2;
    _initialAudioCueType = (int)pvVar2_2;
    pvVar2_3 = [pvVar1 hidesCursor];
    _hidesCursor = (BOOL)pvVar2_3;
    _initialHidesCursor = (BOOL)pvVar2_3;
    pvVar1_3 = [[pvVar1 audioMedia] retain];
    _initialAudioMedia = pvVar1_3;
    _audioMedia = [pvVar1_3 retain];
    [super setUpInitialSettings];
}

- (id)buttonScannerActionAttributes
{
    return [[self actionAttributes] queryHyperInterface:@protocol(HSButtonScannerActionAttributes)];
}

- (void)dealloc
{
    [_initialAudioMedia release];
    [_audioMedia release];
    [super dealloc];
}

@end

