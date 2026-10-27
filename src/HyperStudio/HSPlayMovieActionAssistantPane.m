#import "HSPlayMovieActionAssistantPane.h"

// Relative float comparison used for play range times.
static BOOL HSPlayMovieTimesAreEqual(float a, float b)
{
    float scaleA = a != 0.0f ? fabsf(a) : 1.0f;
    float scaleB = b != 0.0f ? fabsf(b) : 1.0f;
    return fabsf(a - b) <= MAX(scaleA, scaleB) * 0.0005f;
}

@implementation HSPlayMovieActionAssistantPane

/* i386 ivar offsets: _currentOptionsContentView=0x78, _playbackItemsTableView=0x7c, _optionsContainerView=0x80, _movieOptionsContentView=0x84, _eraseWhenDoneSwitch=0x88, _useMovieControllerSwitch=0x8c, _showFirstFrameSwitch=0x90, _playOverObjectsSwitch=0x94, _addMovieButton=0x98, _moviePositionButton=0x9c, _playMovieButton=0xa0, _rangeControl=0xa4, _volumeSlider=0xa8, _maxVolumeButton=0xac, _minVolumeButton=0xb0, _fadeOutSwitchButton=0xb4, _playCountTextField=0xb8, _playCountStepper=0xbc, _loopPopUpButton=0xc0, _liveVideoOptionsContentView=0xc4, _playLiveVideoButton=0xc8, _liveVideoPositionButton=0xcc, _addLiveVideoButton=0xd0, _availableCamerasPopUpButton=0xd4, _liveVideoMirrorModeSwitchButton=0xd8, _liveVideoPlayOverObjectsSwitchButton=0xdc, _previousToolTag=0xe0, _previousSelectedNodes=0xe4, _currentMovieUIItem=0xe8, _currentMoviePlaybackAttributes=0xec, _currentLiveVideoUIItem=0xf0, _currentLiveVideoPlaybackAttributes=0xf4, _previewPlayableObject=0xf8, _playableObjectIsTemporary=0xfc, _pickMovieSourceAssistantPane=0x100, _navigationPaneSwitcher=0x104, _needSearchAvailableMovies=0x108, _needSearchAvailableLiveVideos=0x109, _availableLiveVideos=0x10c, _availableMovies=0x110, _availablePlaybackItems=0x114, _captureDeviceList=0x118, _selectedCaptureDevice=0x11c, _selectedRowIndexesBeforeClosePane=0x120, _didAddPlaybackItem=0x124, _movieDisplayNameFontAttributes=0x128, _movieObjectToPostAdd=0x12c, _observedAttributes=0x130, _temporaryAddedObject=0x134, _initialMirrorMode=0x138, _initialLoopMode=0x13c, _initialPlayCount=0x140, _initialOrderIndex=0x144, _initialPlayRange=0x148, _initialVolume=0x158, _initialSoundFadeOutTime=0x15c */

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

- (void)addHyperAction:(id)aAction
{
    id pvVar1_4;

    pvVar1_4 = [[[[aAction queryHyperInterface:@protocol(HSPlayMovieActionAttributes)] movies] extraFirstObject] movieObjectForCard:nil];
    if (pvVar1_4 != nil) {
        [[pvVar1_4 queryHyperInterface:@protocol(HSNodeChild)] setSupport:nil];
        [self addMovieObject:pvVar1_4];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001a555d @ 001a555d, 298 bytes * /

void FUN_001a555d(HSPlayMovieActionAssistantPane *self,SEL _cmd,id pickMovieSourceAssistantPane,
                 id didChooseLiveObject)

{
  id pvVar1;
  HSPlayMovieActionAssistantPane *pHVar2;
  SEL op;
  undefined *puVar3;
  undefined4 uVar4;
  
  pvVar1 = _objc_msgSend(pickMovieSourceAssistantPane,sel_parentViewController);
  _objc_msgSend(self,sel_setParentViewController_,pvVar1);
  _objc_msgSend(self,sel_addTemporaryLiveObject_,didChooseLiveObject);
  pvVar1 = _objc_msgSend(self,sel_objectAssistantNavigationController);
  uVar4 = *(undefined4 *)PTR_PTR_003366cc;
  _objc_msgSend(pvVar1,sel_changeIdentifierForViewController_toIdentifier_,self,uVar4);
  puVar3 = &DAT_0037d10c;
  pvVar1 = _objc_msgSend(didChooseLiveObject,sel_queryHyperInterface_,&DAT_0037d10c);
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperParent);
  op = sel_choosePositionForTemporaryAddedObject;
  if (pvVar1 != (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_objectAssistantNavigationController,puVar3,uVar4);
    pHVar2 = _objc_msgSend(pvVar1,sel_topViewController);
    if (pHVar2 == self) {
      return;
    }
    self = _objc_msgSend(self,sel_objectAssistantNavigationController,puVar3);
    puVar3 = (undefined *)0x1;
    op = sel_popViewControllerAnimated_;
  }
  _objc_msgSend(self,op,puVar3,uVar4);
  return;
}

*/
- (void)pickMovieSourceAssistantPane:(id)aPane didChooseLiveObject:(id)aObject
{
    [self setParentViewController:[aPane parentViewController]];
    [self addTemporaryLiveObject:aObject];
    [[self objectAssistantNavigationController] changeIdentifierForViewController:self toIdentifier:HSPlayMovieActionPaneIdentifier];
    if ([[aObject queryHyperInterface:@protocol(HSNodeChild)] hyperParent] == nil) {
        // Not placed on the card yet: let the user position it first.
        [self choosePositionForTemporaryAddedObject];
    } else if ([[self objectAssistantNavigationController] topViewController] != self) {
        [[self objectAssistantNavigationController] popViewControllerAnimated:YES];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001a5687 @ 001a5687, 306 bytes * /

void FUN_001a5687(HSPlayMovieActionAssistantPane *self,SEL _cmd,id pickMovieSourceAssistantPane,
                 id didChooseMovieObject,BOOL isInUse)

{
  id pvVar1;
  HSPlayMovieActionAssistantPane *pHVar2;
  SEL op;
  undefined *puVar3;
  undefined4 uVar4;
  
  pvVar1 = _objc_msgSend(pickMovieSourceAssistantPane,sel_parentViewController);
  _objc_msgSend(self,sel_setParentViewController_,pvVar1);
  _objc_msgSend(self,sel_addTemporaryMovieObject_isInUse_,didChooseMovieObject,(int)isInUse);
  pvVar1 = _objc_msgSend(self,sel_objectAssistantNavigationController);
  uVar4 = *(undefined4 *)PTR_PTR_003366cc;
  _objc_msgSend(pvVar1,sel_changeIdentifierForViewController_toIdentifier_,self,uVar4);
  puVar3 = &DAT_0037d10c;
  pvVar1 = _objc_msgSend(didChooseMovieObject,sel_queryHyperInterface_,&DAT_0037d10c);
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperParent);
  op = sel_choosePositionForTemporaryAddedObject;
  if (pvVar1 != (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_objectAssistantNavigationController,puVar3,uVar4);
    pHVar2 = _objc_msgSend(pvVar1,sel_topViewController);
    if (pHVar2 == self) {
      return;
    }
    self = _objc_msgSend(self,sel_objectAssistantNavigationController,puVar3);
    puVar3 = (undefined *)0x1;
    op = sel_popViewControllerAnimated_;
  }
  _objc_msgSend(self,op,puVar3,uVar4);
  return;
}

*/
- (void)pickMovieSourceAssistantPane:(id)aPane didChooseMovieObject:(id)aObject isInUse:(BOOL)aUse
{
    [self setParentViewController:[aPane parentViewController]];
    [self addTemporaryMovieObject:aObject isInUse:aUse];
    [[self objectAssistantNavigationController] changeIdentifierForViewController:self toIdentifier:HSPlayMovieActionPaneIdentifier];
    if ([[aObject queryHyperInterface:@protocol(HSNodeChild)] hyperParent] == nil) {
        // Not placed on the card yet: let the user position it first.
        [self choosePositionForTemporaryAddedObject];
    } else if ([[self objectAssistantNavigationController] topViewController] != self) {
        [[self objectAssistantNavigationController] popViewControllerAnimated:YES];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001a57b9 @ 001a57b9, 147 bytes * /

void FUN_001a57b9(HSPlayMovieActionAssistantPane *self,SEL _cmd,id observeValueForKeyPath,
                 id ofObject,id change,void *context)

{
  id pvVar1;
  
  if (self->_selectedCaptureDevice == ofObject) {
    pvVar1 = _objc_msgSend(observeValueForKeyPath,sel_isEqualToString_,
                           &cfstr_inUseByAnotherApplication);
    if (((char)pvVar1 == '\0') &&
       (pvVar1 = _objc_msgSend(observeValueForKeyPath,sel_isEqualToString_,&cfstr_suspended),
       (char)pvVar1 == '\0')) {
      return;
    }
    _objc_msgSend(self,sel_performSelectorOnMainThread_withObject_waitUntilDone_,
                  sel_HSPlayMovieActionAssistantPane_captureDeviceDidChangeState_,ofObject,0);
  }
  return;
}

*/
- (void)observeValueForKeyPath:(id)aPath ofObject:(id)aObject change:(id)aChange context:(void *)aContext
{
    if (_selectedCaptureDevice == aObject
        && ([aPath isEqualToString:@"inUseByAnotherApplication"] || [aPath isEqualToString:@"suspended"])) {
        [self performSelectorOnMainThread:@selector(HSPlayMovieActionAssistantPane_captureDeviceDidChangeState:) withObject:aObject waitUntilDone:NO];
    }
}

- (void)HSPlayMovieActionAssistantPane_captureDeviceDidChangeState:(id)aState
{
    if (_selectedCaptureDevice == aState) {
        [self validateUserInterfaceInLiveVideoOptions];
    }
}

- (void)HSPlayMovieActionAssistantPane_captureDeviceListDidUpdate:(id)aUpdate
{
    [self HSPlayMovieActionAssistantPane_availableCamerasPopUpButtonDidUpdate];
    [self validateUserInterfaceInLiveVideoOptions];
}

- (void)liveVideoPlaybackAttributesDidChange:(id)aChange
{
    [self validateUserInterfaceInLiveVideoOptions];
}

- (void)moviePlaybackAttributesDidChange:(id)aChange
{
    [self validateUserInterfaceInMovieOptions];
}

- (void)moviesInActionDidChange:(id)aChange
{
    if ([self isPlaying]) {
        [self stopPlaying];
    }
    _needSearchAvailableMovies = YES;
    [_playbackItemsTableView reloadData];
    [self updateCurrentPlaybackAttributes];
    [self validateUserInterface];
}

- (void)moviesInActionWillChange:(id)aChange
{
    [self setCurrentMovieUIItem:nil];
    [self setCurrentMoviePlaybackAttributes:nil];
}

- (void)liveVideosInActionDidChange:(id)aChange
{
    if ([self isPlaying]) {
        [self stopPlaying];
    }
    _needSearchAvailableLiveVideos = YES;
    [_playbackItemsTableView reloadData];
    [self updateCurrentPlaybackAttributes];
    [self validateUserInterface];
}

- (void)liveVideosInActionWillChange:(id)aChange
{
    [self setCurrentLiveVideoUIItem:nil];
    [self setCurrentLiveVideoPlaybackAttributes:nil];
}

- (void)mountOptionsContentView:(id)aView
{
    id self_00;

    if (_currentOptionsContentView != aView) {
        [_currentOptionsContentView removeFromSuperviewWithoutNeedingDisplay];
        [_currentOptionsContentView release];
        self_00 = [aView retain];
        _currentOptionsContentView = self_00;
        [self_00 setFrame:[_optionsContainerView bounds]];
        [_optionsContainerView addSubview:_currentOptionsContentView];
    }
}

- (id)suggestedOptionsContentView
{
    id *ppvVar2;

    if ([self currentLiveVideoPlaybackAttributes] == nil) {
        ppvVar2 = &_movieOptionsContentView;
    }
    else {
        ppvVar2 = &_liveVideoOptionsContentView;
    }
    return *ppvVar2;
}

- (void)playMovieActionPlayToolDidFinish:(id)aFinish
{
    [self stopPlaying];
    [self validateUserInterface];
}

- (void)hyperPlayableObjectDidStop:(id)aStop
{
    [self cleanUpAfterPlaying];
    [self validateUserInterface];
}

- (void)stopPlaying
{
    if ([_previewPlayableObject isHyperPlaying]) {
        [_previewPlayableObject hyperStop];
        [self cleanUpAfterPlaying];
    }
}

- (void)startPlaying
{
    if ([self prepareBeforePlay]) {
        [_previewPlayableObject hyperStart:self];
    }
}

- (BOOL)isPlaying
{
    BOOL bVar2;

    if (_previewPlayableObject == nil) {
        bVar2 = NO;
    }
    else {
        bVar2 = [_previewPlayableObject isHyperPlaying];
    }
    return bVar2;
}

- (void)cleanPlaybackUIItems
{
    [self setCurrentMovieUIItem:nil];
    [self setCurrentMoviePlaybackAttributes:nil];
    [_availableMovies release];
    _availableMovies = nil;
    [self setCurrentLiveVideoUIItem:nil];
    [self setCurrentLiveVideoPlaybackAttributes:nil];
    [_availableLiveVideos release];
    _availableLiveVideos = nil;
    [_availablePlaybackItems release];
    _availablePlaybackItems = nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001a5dea @ 001a5dea, 694 bytes * /

void FUN_001a5dea(HSPlayMovieActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  double dVar3;
  undefined4 uVar5;
  ulonglong uVar4;
  undefined4 uVar6;
  
  if (self->_previewPlayableObject == (id)0x0) {
    return;
  }
  _objc_msgSend(self,sel_disableUndoRegistration);
  pvVar1 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
  dVar3 = (double)CONCAT44(self,1);
  _objc_msgSend(pvVar1,sel_setLocked_delegate_,1,self);
  if (self->_playableObjectIsTemporary != '\0') {
    uVar6 = (undefined4)((ulonglong)dVar3 >> 0x20);
    pvVar1 = _objc_msgSend(self->_previewPlayableObject,sel_queryHyperInterface_,&DAT_0037cf90);
    _objc_msgSend(pvVar1,sel_removeFromHyperParent);
    pvVar1 = _objc_msgSend(self,sel_currentMoviePlaybackAttributes);
    pvVar2 = _objc_msgSend(self,sel_card);
    dVar3 = (double)CONCAT44(uVar6,pvVar2);
    pvVar1 = _objc_msgSend(pvVar1,sel_movieObjectForCard_,pvVar2);
    if (pvVar1 != self->_previewPlayableObject) {
      dVar3 = _objc_msgSend_fpret(self->_previewPlayableObject,sel_hyperCurrentTime);
      _objc_msgSend(pvVar1,sel_setHyperCurrentTime_,dVar3);
    }
  }
  pvVar1 = _objc_msgSend(self,sel_currentLiveVideoPlaybackAttributes,dVar3);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_currentMoviePlaybackAttributes,dVar3);
    if (pvVar1 == (id)0x0) goto LAB_001a5f58;
    pvVar1 = self->_previewPlayableObject;
    op = sel_restorePlaybackAttributesForMovieObject_;
  }
  else {
    pvVar1 = self->_previewPlayableObject;
    op = sel_restorePlaybackAttributesForLiveObject_;
  }
  dVar3 = (double)CONCAT44((int)((ulonglong)dVar3 >> 0x20),pvVar1);
  _objc_msgSend(self,op,pvVar1);
LAB_001a5f58:
  pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager,dVar3);
  uVar6 = 1;
  uVar4 = (ulonglong)(uint)self->_previousToolTag;
  _objc_msgSend(pvVar1,sel_selectToolWithTag_setAsPermanent_forceSelection_,self->_previousToolTag,0
                ,1);
  pvVar1 = _objc_msgSend(self->_previousSelectedNodes,sel_count);
  if (pvVar1 != (id)0x0) {
    pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager,uVar4,uVar6);
    uVar5 = (undefined4)(uVar4 >> 0x20);
    pvVar1 = _objc_msgSend(pvVar1,sel_currentTool);
    pvVar1 = _objc_msgSend(pvVar1,sel_view);
    uVar4 = CONCAT44(uVar5,self->_previousSelectedNodes);
    _objc_msgSend(pvVar1,sel_selectHyperObjects_,self->_previousSelectedNodes);
  }
  _objc_msgSend(self->_previousSelectedNodes,sel_release,uVar4,uVar6);
  self->_previousSelectedNodes = (id)0x0;
  _objc_msgSend(self,sel_setPreviewPlayableObject_,0);
  pvVar1 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
  _objc_msgSend(pvVar1,sel_setLocked_delegate_,0,0);
  _objc_msgSend(self,sel_enableUndoRegistration);
  return;
}

*/
- (void)cleanUpAfterPlaying
{
    if (_previewPlayableObject == nil) {
        return;
    }
    [self disableUndoRegistration];
    [[HSObjectAssistantController sharedAssistantController] setLocked:YES delegate:self];
    if (_playableObjectIsTemporary) {
        [[_previewPlayableObject queryHyperInterface:@protocol(HSNodeAttributes)] removeFromHyperParent];
        // Carry the preview position over to the real movie object.
        id movie = [[self currentMoviePlaybackAttributes] movieObjectForCard:[self card]];
        if (movie != _previewPlayableObject) {
            [movie setHyperCurrentTime:[_previewPlayableObject hyperCurrentTime]];
        }
    }
    if ([self currentLiveVideoPlaybackAttributes] != nil) {
        [self restorePlaybackAttributesForLiveObject:_previewPlayableObject];
    } else if ([self currentMoviePlaybackAttributes] != nil) {
        [self restorePlaybackAttributesForMovieObject:_previewPlayableObject];
    }
    [[HSToolManager sharedToolManager] selectToolWithTag:_previousToolTag setAsPermanent:NO forceSelection:YES];
    if ([_previousSelectedNodes count] != 0) {
        [[[[HSToolManager sharedToolManager] currentTool] view] selectHyperObjects:_previousSelectedNodes];
    }
    [_previousSelectedNodes release];
    _previousSelectedNodes = nil;
    [self setPreviewPlayableObject:nil];
    [[HSObjectAssistantController sharedAssistantController] setLocked:NO delegate:nil];
    [self enableUndoRegistration];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001a60a0 @ 001a60a0, 1268 bytes * /

BOOL FUN_001a60a0(HSPlayMovieActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  SEL op;
  double dVar5;
  undefined8 uVar6;
  undefined4 uVar7;
  
  pvVar1 = self->_previewPlayableObject;
  if (pvVar1 != (id)0x0) goto LAB_001a6584;
  _objc_msgSend(self,sel_disableUndoRegistration);
  pvVar1 = _objc_msgSend(self,sel_card);
  pvVar2 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
  uVar6 = CONCAT44(self,1);
  _objc_msgSend(pvVar2,sel_setLocked_delegate_,1,self);
  _objc_msgSend(self->_previousSelectedNodes,sel_release);
  pvVar2 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar2 = _objc_msgSend(pvVar2,sel_currentTool);
  pvVar2 = _objc_msgSend(pvVar2,sel_view);
  pvVar2 = _objc_msgSend(pvVar2,sel_selection);
  pvVar2 = _objc_msgSend(pvVar2,sel_nodesArray);
  pvVar2 = _objc_msgSend(pvVar2,sel_retain);
  self->_previousSelectedNodes = pvVar2;
  pvVar2 = _objc_msgSend(self,sel_currentLiveVideoPlaybackAttributes);
  if (pvVar2 == (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_currentMoviePlaybackAttributes);
    if (pvVar2 != (id)0x0) {
      pvVar2 = _objc_msgSend(self,sel_currentMoviePlaybackAttributes);
      uVar6 = CONCAT44((int)((ulonglong)uVar6 >> 0x20),pvVar1);
      pvVar3 = _objc_msgSend(pvVar2,sel_movieObjectForCard_,pvVar1);
      if (pvVar3 != (id)0x0) {
        uVar6 = CONCAT44((int)((ulonglong)uVar6 >> 0x20),&DAT_0037d210);
        pvVar4 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_0037d210);
        pvVar4 = _objc_msgSend(pvVar4,sel_isHidden);
        if ((char)pvVar4 != '\0') {
          pvVar4 = _objc_msgSend(self,sel_stack,uVar6);
          pvVar4 = _objc_msgSend(pvVar4,sel_cardObjectsVisibility);
          if (pvVar4 == (id)0x2) {
            dVar5 = _objc_msgSend_fpret(pvVar3,sel_hyperCurrentTime);
            pvVar3 = _objc_msgSend(pvVar3,sel_localCopyIncludingNodeUnits_,1);
            pvVar3 = _objc_msgSend(pvVar3,sel_autorelease);
            pvVar4 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_0037d300);
            _objc_msgSend(pvVar4,sel_setHidden_,0);
            _objc_msgSend(pvVar3,sel_setHyperCurrentTime_,dVar5);
          }
        }
        _objc_msgSend(self,sel_setPreviewPlayableObject_,pvVar3);
        pvVar4 = _objc_msgSend(pvVar3,sel_hyperParent);
        self->_playableObjectIsTemporary = pvVar4 == (id)0x0;
        op = sel_applyPlaybackAttributes_toMovieObject_;
        if (pvVar4 == (id)0x0) {
          pvVar4 = _objc_msgSend(self->_previewPlayableObject,sel_queryHyperInterface_,&DAT_0037d10c
                                );
          _objc_msgSend(pvVar1,sel_addTemporaryHyperChild_,pvVar4);
          op = sel_applyPlaybackAttributes_toMovieObject_;
        }
        goto LAB_001a6461;
      }
    }
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_currentLiveVideoPlaybackAttributes);
    uVar6 = CONCAT44((int)((ulonglong)uVar6 >> 0x20),pvVar1);
    pvVar3 = _objc_msgSend(pvVar2,sel_liveObjectForCard_,pvVar1);
    if (pvVar3 != (id)0x0) {
      _objc_msgSend(self,sel_setPreviewPlayableObject_,pvVar3);
      pvVar4 = _objc_msgSend(pvVar3,sel_hyperParent);
      self->_playableObjectIsTemporary = pvVar4 == (id)0x0;
      op = sel_applyPlaybackAttributes_toLiveObject_;
      if (pvVar4 == (id)0x0) {
        pvVar4 = _objc_msgSend(self->_previewPlayableObject,sel_queryHyperInterface_,&DAT_0037d10c);
        _objc_msgSend(pvVar1,sel_addTemporaryHyperChild_,pvVar4);
        op = sel_applyPlaybackAttributes_toLiveObject_;
      }
LAB_001a6461:
      uVar6 = CONCAT44(pvVar3,pvVar2);
      _objc_msgSend(self,op,pvVar2,pvVar3);
    }
  }
  if (self->_previewPlayableObject == (id)0x0) {
    _objc_msgSend(self->_previousSelectedNodes,sel_release,uVar6);
    self->_previousSelectedNodes = (id)0x0;
  }
  else {
    pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager,uVar6);
    pvVar2 = _objc_msgSend(pvVar1,sel_selectedToolTag);
    self->_previousToolTag = (int)pvVar2;
    uVar7 = 0;
    _objc_msgSend(pvVar1,sel_selectToolWithTag_setAsPermanent_,0x43,0);
    pvVar1 = _objc_msgSend(pvVar1,sel_currentTool);
    uVar6 = CONCAT44(uVar7,self->_previewPlayableObject);
    _objc_msgSend(pvVar1,sel_setCardObject_,self->_previewPlayableObject);
  }
  pvVar1 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController,uVar6);
  _objc_msgSend(pvVar1,sel_setLocked_delegate_,0,0);
  _objc_msgSend(self,sel_enableUndoRegistration);
  pvVar1 = self->_previewPlayableObject;
LAB_001a6584:
  return pvVar1 != (id)0x0;
}

*/
- (BOOL)prepareBeforePlay
{
    if (_previewPlayableObject != nil) {
        return YES;
    }
    [self disableUndoRegistration];
    id card = [self card];
    [[HSObjectAssistantController sharedAssistantController] setLocked:YES delegate:self];
    [_previousSelectedNodes release];
    _previousSelectedNodes = [[[[[[HSToolManager sharedToolManager] currentTool] view] selection] nodesArray] retain];
    if ([self currentLiveVideoPlaybackAttributes] != nil) {
        id attributes = [self currentLiveVideoPlaybackAttributes];
        id liveObject = [attributes liveObjectForCard:card];
        if (liveObject != nil) {
            [self setPreviewPlayableObject:liveObject];
            _playableObjectIsTemporary = [liveObject hyperParent] == nil;
            if (_playableObjectIsTemporary) {
                [card addTemporaryHyperChild:[_previewPlayableObject queryHyperInterface:@protocol(HSNodeChild)]];
            }
            [self applyPlaybackAttributes:attributes toLiveObject:liveObject];
        }
    } else if ([self currentMoviePlaybackAttributes] != nil) {
        id attributes = [self currentMoviePlaybackAttributes];
        id movie = [attributes movieObjectForCard:card];
        if (movie != nil) {
            if ([[movie queryHyperInterface:@protocol(HSCardObjectAttributes)] isHidden]
                && [[self stack] cardObjectsVisibility] == 2) {
                // Hidden objects are not drawn in this mode: preview a visible copy.
                double currentTime = [movie hyperCurrentTime];
                movie = [[movie localCopyIncludingNodeUnits:YES] autorelease];
                [[movie queryHyperInterface:@protocol(HSMutableCardObjectAttributes)] setHidden:NO];
                [movie setHyperCurrentTime:currentTime];
            }
            [self setPreviewPlayableObject:movie];
            _playableObjectIsTemporary = [movie hyperParent] == nil;
            if (_playableObjectIsTemporary) {
                [card addTemporaryHyperChild:[_previewPlayableObject queryHyperInterface:@protocol(HSNodeChild)]];
            }
            [self applyPlaybackAttributes:attributes toMovieObject:movie];
        }
    }
    if (_previewPlayableObject == nil) {
        [_previousSelectedNodes release];
        _previousSelectedNodes = nil;
    } else {
        HSToolManager *toolManager = [HSToolManager sharedToolManager];
        _previousToolTag = (int)[toolManager selectedToolTag];
        [toolManager selectToolWithTag:67 setAsPermanent:NO];
        [[toolManager currentTool] setCardObject:_previewPlayableObject];
    }
    [[HSObjectAssistantController sharedAssistantController] setLocked:NO delegate:nil];
    [self enableUndoRegistration];
    return _previewPlayableObject != nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001a6594 @ 001a6594, 370 bytes * /

void FUN_001a6594(HSPlayMovieActionAssistantPane *self,SEL _cmd,
                 id restorePlaybackAttributesForMovieObject)

{
  id pvVar1;
  
  _objc_msgSend(self,sel_disableUndoRegistration);
  _objc_msgSend(restorePlaybackAttributesForMovieObject,sel_setHyperPlayRange_,
                (self->_initialPlayRange).location,(self->_initialPlayRange).length);
  pvVar1 = _objc_msgSend(restorePlaybackAttributesForMovieObject,sel_queryHyperInterface_,
                         &DAT_0037ce3c);
  _objc_msgSend(pvVar1,sel_setHyperPlayCount_,self->_initialPlayCount);
  pvVar1 = _objc_msgSend(restorePlaybackAttributesForMovieObject,sel_queryHyperInterface_,
                         &DAT_0037cf90);
  _objc_msgSend(pvVar1,sel_setHyperIndex_,self->_initialOrderIndex);
  pvVar1 = _objc_msgSend(restorePlaybackAttributesForMovieObject,sel_queryHyperInterface_,
                         &DAT_0037cdb0);
  _objc_msgSend(pvVar1,sel_setHyperVolume_,self->_initialVolume);
  pvVar1 = _objc_msgSend(restorePlaybackAttributesForMovieObject,sel_queryHyperInterface_,
                         &DAT_0037cdb0);
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperMovie);
  _objc_msgSend(pvVar1,sel_setSoundFadeOutTime_,(double)(int)self->_initialSoundFadeOutTime);
  _objc_msgSend(self,sel_enableUndoRegistration);
  return;
}

*/
- (void)restorePlaybackAttributesForMovieObject:(id)aObject
{
    [self disableUndoRegistration];
    [aObject setHyperPlayRange:_initialPlayRange];
    [[aObject queryHyperInterface:@protocol(HSExtendedPlayableObjectAttributes)] setHyperPlayCount:_initialPlayCount];
    [[aObject queryHyperInterface:@protocol(HSNodeAttributes)] setHyperIndex:_initialOrderIndex];
    [[aObject queryHyperInterface:@protocol(HSMovieObjectBaseAttributes)] setHyperVolume:_initialVolume];
    [[[aObject queryHyperInterface:@protocol(HSMovieObjectBaseAttributes)] hyperMovie] setSoundFadeOutTime:(double)_initialSoundFadeOutTime];
    [self enableUndoRegistration];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001a6706 @ 001a6706, 481 bytes * /

void FUN_001a6706(HSPlayMovieActionAssistantPane *self,SEL _cmd,id applyPlaybackAttributes,
                 id toMovieObject)

{
  id pvVar1;
  double dVar2;
  double local_34;
  double local_2c;
  undefined8 local_24;
  undefined8 local_1c;
  
  _objc_msgSend_stret(&local_34,toMovieObject,sel_hyperPlayRange);
  (self->_initialPlayRange).location = local_34;
  (self->_initialPlayRange).length = local_2c;
  dVar2 = _objc_msgSend_fpret(toMovieObject,sel_hyperVolume);
  self->_initialVolume = (float)dVar2;
  pvVar1 = _objc_msgSend(toMovieObject,sel_movie);
  dVar2 = _objc_msgSend_fpret(pvVar1,sel_soundFadeOutTime);
  self->_initialSoundFadeOutTime = (BOOL)(int)dVar2;
  pvVar1 = _objc_msgSend(toMovieObject,sel_hyperPlayCount);
  self->_initialPlayCount = (uint)pvVar1;
  _objc_msgSend(self,sel_disableUndoRegistration);
  _objc_msgSend(applyPlaybackAttributes,sel_playCount);
  _objc_msgSend(toMovieObject,sel_setHyperPlayCount_);
  _objc_msgSend_stret(&local_24,applyPlaybackAttributes,sel_playRange);
  _objc_msgSend(toMovieObject,sel_setHyperPlayRange_,local_24,local_1c);
  dVar2 = _objc_msgSend_fpret(applyPlaybackAttributes,sel_volume);
  _objc_msgSend(toMovieObject,sel_setHyperVolume_,(float)dVar2);
  pvVar1 = _objc_msgSend(toMovieObject,sel_movie);
  dVar2 = _objc_msgSend_fpret(applyPlaybackAttributes,sel_soundFadeOutTime);
  _objc_msgSend(pvVar1,sel_setSoundFadeOutTime_,dVar2);
  _objc_msgSend(self,sel_applyOrderFromPlaybackAttributes_toNode_,applyPlaybackAttributes,
                toMovieObject);
  _objc_msgSend(self,sel_enableUndoRegistration);
  return;
}

*/
- (void)applyPlaybackAttributes:(id)aAttributes toMovieObject:(id)aObject
{
    _initialPlayRange = [aObject hyperPlayRange];
    _initialVolume = [aObject hyperVolume];
    _initialSoundFadeOutTime = (signed char)(int)[[aObject movie] soundFadeOutTime];
    _initialPlayCount = (unsigned int)[aObject hyperPlayCount];
    [self disableUndoRegistration];
    [aObject setHyperPlayCount:[aAttributes playCount]];
    [aObject setHyperPlayRange:[aAttributes playRange]];
    [aObject setHyperVolume:[(id<HSMoviePlaybackAttributes>)aAttributes volume]];
    [[aObject movie] setSoundFadeOutTime:[aAttributes soundFadeOutTime]];
    [self applyOrderFromPlaybackAttributes:aAttributes toNode:aObject];
    [self enableUndoRegistration];
}

- (void)restorePlaybackAttributesForLiveObject:(id)aObject
{
    id pvVar1_2;

    pvVar1_2 = [[aObject queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
    [self disableUndoRegistration];
    if (pvVar1_2 != nil) {
        [pvVar1_2 setFlippedHorizontally:YES withLayoutGuidingContext:nil];
    }
    [[aObject queryHyperInterface:@protocol(HSNodeAttributes)] setHyperIndex:_initialOrderIndex];
    [self enableUndoRegistration];
}

- (void)applyPlaybackAttributes:(id)aAttributes toLiveObject:(id)aObject
{
    id pvVar1;

    pvVar1 = [aObject queryHyperInterface:@protocol(HSGeometryAttributes)];
    if (pvVar1 != nil) {
        _initialMirrorMode = (BOOL)[pvVar1 isFlippedHorizontally];
    }
    [self applyOrderFromPlaybackAttributes:aAttributes toNode:aObject];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001a6a2b @ 001a6a2b, 228 bytes * /

void FUN_001a6a2b(HSPlayMovieActionAssistantPane *self,SEL _cmd,id applyOrderFromPlaybackAttributes,
                 id toNode)

{
  char cVar1;
  id pvVar2;
  SEL op;
  undefined *puVar3;
  
  puVar3 = &DAT_0037cfb8;
  pvVar2 = _objc_msgSend(applyOrderFromPlaybackAttributes,sel_queryHyperInterface_,&DAT_0037cfb8);
  if (pvVar2 == (id)0x0) {
    puVar3 = &DAT_0037c978;
    pvVar2 = _objc_msgSend(applyOrderFromPlaybackAttributes,sel_queryHyperInterface_,&DAT_0037c978);
    if (pvVar2 == (id)0x0) {
      cVar1 = '\0';
      goto LAB_001a6a9f;
    }
  }
  pvVar2 = _objc_msgSend(pvVar2,sel_playOverObjects,puVar3);
  cVar1 = (char)pvVar2;
LAB_001a6a9f:
  pvVar2 = _objc_msgSend(toNode,sel_hyperIndex,puVar3);
  self->_initialOrderIndex = (uint)pvVar2;
  _objc_msgSend(self,sel_disableUndoRegistration);
  op = sel_moveToHyperBegin;
  if (cVar1 != '\0') {
    op = sel_moveToHyperEnd;
  }
  _objc_msgSend(toNode,op,puVar3);
  _objc_msgSend(self,sel_enableUndoRegistration);
  return;
}

*/
- (void)applyOrderFromPlaybackAttributes:(id)aAttributes toNode:(id)aNode
{
    id playback = [aAttributes queryHyperInterface:@protocol(HSLiveVideoPlaybackAttributes)];
    if (playback == nil) {
        playback = [aAttributes queryHyperInterface:@protocol(HSMoviePlaybackAttributes)];
    }
    BOOL playOverObjects = playback != nil && [playback playOverObjects];
    _initialOrderIndex = (unsigned int)[aNode hyperIndex];
    [self disableUndoRegistration];
    if (playOverObjects) {
        [aNode moveToHyperEnd];
    } else {
        [aNode moveToHyperBegin];
    }
    [self enableUndoRegistration];
}

- (void)enableUndoRegistration
{
    [[[[self card] document] undoManager] enableUndoRegistration];
}

- (void)disableUndoRegistration
{
    [[[[self card] document] undoManager] disableUndoRegistration];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001a6bcb @ 001a6bcb, 237 bytes * /

BOOL FUN_001a6bcb(HSPlayMovieActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(self,sel_actionAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_movies);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectEnumerator);
  while (pvVar2 = _objc_msgSend(pvVar1,sel_nextObject), pvVar2 != (id)0x0) {
    pvVar2 = _objc_msgSend(pvVar2,sel_isEnabled);
    if ((char)pvVar2 == '\0') {
      return '\x01';
    }
  }
  pvVar1 = _objc_msgSend(self,sel_actionAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_liveVideos);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectEnumerator);
  do {
    pvVar2 = _objc_msgSend(pvVar1,sel_nextObject);
    if (pvVar2 == (id)0x0) {
      return '\0';
    }
    pvVar2 = _objc_msgSend(pvVar2,sel_isEnabled);
  } while ((char)pvVar2 != '\0');
  return '\x01';
}

*/
- (BOOL)needToCleanUnUsedPlaybackItems
{
    for (id movie in [[self actionAttributes] movies]) {
        if (![movie isEnabled]) {
            return YES;
        }
    }
    for (id liveVideo in [[self actionAttributes] liveVideos]) {
        if (![liveVideo isEnabled]) {
            return YES;
        }
    }
    return NO;
}

- (void)stopObservingChangesOfActionAttributes
{
    int uVar1;
    id pvVar2;
    id pvVar2_3;
    int uVar1_2;

    pvVar2 = [_observedAttributes attributeObservingController];
    uVar1 = HSActualWillAttributeChanges;
    [pvVar2 removeObserver:self selector:@selector(moviesInActionWillChange:) ofChanges:uVar1 ofAttribute:@protocol(HSPlayMovieMoviesAttribute)];
    [[_observedAttributes attributeObservingController] removeObserver:self selector:@selector(liveVideosInActionWillChange:) ofChanges:uVar1 ofAttribute:@protocol(HSPlayMovieLiveVideosAttribute)];
    pvVar2_3 = [_observedAttributes attributeObservingController];
    uVar1_2 = HSActualDidAttributeChanges;
    [pvVar2_3 removeObserver:self selector:@selector(moviesInActionDidChange:) ofChanges:uVar1_2 ofAttribute:@protocol(HSPlayMovieMoviesAttribute)];
    [[_observedAttributes attributeObservingController] removeObserver:self selector:@selector(liveVideosInActionDidChange:) ofChanges:uVar1_2 ofAttribute:@protocol(HSPlayMovieLiveVideosAttribute)];
    [_observedAttributes release];
    _observedAttributes = nil;
}

- (void)startObservingChangesOfActionAttributes
{
    int uVar1;
    id pvVar2_2;
    id pvVar2_3;
    id pvVar2_5;
    int uVar1_2;

    if (_observedAttributes == nil) {
        pvVar2_2 = [[self actionAttributes] retain];
        _observedAttributes = pvVar2_2;
        pvVar2_3 = [pvVar2_2 attributeObservingController];
        uVar1 = HSActualWillAttributeChanges;
        [pvVar2_3 addObserver:self selector:@selector(moviesInActionWillChange:) ofChanges:uVar1 ofAttribute:@protocol(HSPlayMovieMoviesAttribute) withPriority:-0.25];
        [[_observedAttributes attributeObservingController] addObserver:self selector:@selector(liveVideosInActionWillChange:) ofChanges:uVar1 ofAttribute:@protocol(HSPlayMovieLiveVideosAttribute) withPriority:-0.25];
        pvVar2_5 = [_observedAttributes attributeObservingController];
        uVar1_2 = HSActualDidAttributeChanges;
        [pvVar2_5 addObserver:self selector:@selector(moviesInActionDidChange:) ofChanges:uVar1_2 ofAttribute:@protocol(HSPlayMovieMoviesAttribute) withPriority:-0.25];
        [[_observedAttributes attributeObservingController] addObserver:self selector:@selector(liveVideosInActionDidChange:) ofChanges:uVar1_2 ofAttribute:@protocol(HSPlayMovieLiveVideosAttribute) withPriority:-0.25];
    }
}

- (id)movieDisplayNameFontAttributes
{
    id pvVar1;
    id pvVar2;
    id pvVar1_3;

    pvVar1 = _movieDisplayNameFontAttributes;
    if (pvVar1 == nil) {
        pvVar1_3 = [[NSParagraphStyle defaultParagraphStyle] hyperParagraphStyleByChangingLineBreakMode:4];
        pvVar2 = [NSArray arrayWithObjects:NSFontAttributeName, NSParagraphStyleAttributeName, nil];
        pvVar1 = [[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSFont boldSystemFontOfSize:(float)[NSFont smallSystemFontSize]], pvVar1_3, nil] forKeys:pvVar2] retain];
        _movieDisplayNameFontAttributes = pvVar1;
    }
    return pvVar1;
}

- (void)processMovieObjectToPostAdd
{
    if (_movieObjectToPostAdd != nil) {
        [self addMovieObject:_movieObjectToPostAdd];
        [_movieObjectToPostAdd release];
        _movieObjectToPostAdd = nil;
    }
}

- (void)setPostAddMovieObject:(id)aObject
{
    if (_movieObjectToPostAdd != aObject) {
        [_movieObjectToPostAdd release];
        _movieObjectToPostAdd = [aObject retain];
    }
}

- (void)updateLiveVideoItemsSelection
{
    int iVar2;
    NSUInteger pvVar1_2;

    _needSearchAvailableMovies = YES;
    _needSearchAvailableLiveVideos = YES;
    pvVar1_2 = [[self availablePlaybackUIItems] count];
    if (pvVar1_2 == 0) {
        iVar2 = 0;
    }
    else {
        iVar2 = (int)pvVar1_2 + -1;
    }
    if (_selectedRowIndexesBeforeClosePane == nil) {
        [_playbackItemsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:iVar2] byExtendingSelection:NO];
        [_playbackItemsTableView scrollRowToVisible:iVar2];
    }
    else {
        [_selectedRowIndexesBeforeClosePane release];
        _selectedRowIndexesBeforeClosePane = [[NSIndexSet indexSetWithIndex:iVar2] retain];
    }
}

- (void)updateMovieItemsSelection
{
    int iVar2;
    NSUInteger pvVar1_2;

    _needSearchAvailableMovies = YES;
    pvVar1_2 = [[self availableMovieUIItems] count];
    if (pvVar1_2 == 0) {
        iVar2 = 0;
    }
    else {
        iVar2 = (int)pvVar1_2 + -1;
    }
    if (_selectedRowIndexesBeforeClosePane == nil) {
        [_playbackItemsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:iVar2] byExtendingSelection:NO];
        [_playbackItemsTableView scrollRowToVisible:iVar2];
    }
    else {
        [_selectedRowIndexesBeforeClosePane release];
        _selectedRowIndexesBeforeClosePane = [[NSIndexSet indexSetWithIndex:iVar2] retain];
    }
}

- (id)pickMovieSourceAssistantPane
{
    HSPickMovieSourceAssistantPane *pHVar1;
    HSPickMovieSourceAssistantPane *pHVar1_2;

    pHVar1 = _pickMovieSourceAssistantPane;
    if (pHVar1 == nil) {
        pHVar1_2 = [HSPickMovieSourceAssistantPane new];
        _pickMovieSourceAssistantPane = pHVar1_2;
        [pHVar1_2 setPickMovieSourcePaneDelegate:self];
        pHVar1 = _pickMovieSourceAssistantPane;
    }
    [pHVar1 setActionEvent:[self actionEvent]];
    return _pickMovieSourceAssistantPane;
}

- (void)cleanUnUsedPlaybackItemsIfNeeded
{
    NSEnumerator *pvVar2;
    id pvVar1_3;
    id pvVar1_6;
    NSEnumerator *pvVar2_2;

    pvVar2 = [[[self actionAttributes] movies] objectEnumerator];
    pvVar1_3 = [pvVar2 nextObject];
    while (pvVar1_3 != nil) {
        if (![pvVar1_3 isEnabled]) {
            [[self playMovieActionApplier] removeMovie:pvVar1_3];
        }
        pvVar1_3 = [pvVar2 nextObject];
    }
    pvVar2_2 = [[[self actionAttributes] liveVideos] objectEnumerator];
    pvVar1_6 = [pvVar2_2 nextObject];
    while (pvVar1_6 != nil) {
        if (![pvVar1_6 isEnabled]) {
            [[self playMovieActionApplier] removeLiveVideo:pvVar1_6];
        }
        pvVar1_6 = [pvVar2_2 nextObject];
    }
}

- (void)removeActionIfNeeded
{
    id pvVar1;
    id pvVar1_6;
    id pvVar2_3;

    pvVar1 = [self actionAttributes];
    if (pvVar1 != nil) {
        if ([[pvVar1 movies] count] == 0) {
            if ([[pvVar1 liveVideos] count] == 0) {
                pvVar1_6 = [[[self applier] object] queryHyperInterface:@protocol(HSActor)];
                pvVar2_3 = [self actionEvent];
                [pvVar1_6 removeHyperActionOfType:[self actionType] forEvent:pvVar2_3];
            }
        }
    }
}

- (void)setCurrentLiveVideoPlaybackAttributes:(id)aAttributes
{
    int uVar1;
    id pvVar2;
    id pvVar2_2;

    if (_currentLiveVideoPlaybackAttributes != aAttributes) {
        pvVar2 = [_currentLiveVideoPlaybackAttributes attributeObservingController];
        uVar1 = HSActualDidAttributeChanges;
        [pvVar2 removeObserver:self selector:@selector(liveVideoPlaybackAttributesDidChange:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSLiveVideoPlaybackAttributes)];
        [_currentLiveVideoPlaybackAttributes release];
        pvVar2_2 = [aAttributes retain];
        _currentLiveVideoPlaybackAttributes = pvVar2_2;
        [[pvVar2_2 attributeObservingController] addObserver:self selector:@selector(liveVideoPlaybackAttributesDidChange:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSLiveVideoPlaybackAttributes) withPriority:-0.25];
    }
}

- (id)currentLiveVideoPlaybackAttributes
{
    return _currentLiveVideoPlaybackAttributes;
}

- (void)setCurrentLiveVideoUIItem:(id)aItem
{
    if (_currentLiveVideoUIItem != aItem) {
        [_currentLiveVideoUIItem release];
        _currentLiveVideoUIItem = [aItem retain];
    }
}

- (id)currentLiveVideoUIItem
{
    return _currentLiveVideoUIItem;
}

- (void)setCurrentMoviePlaybackAttributes:(id)aAttributes
{
    int uVar1;
    id pvVar2;
    id pvVar2_2;

    if (_currentMoviePlaybackAttributes != aAttributes) {
        pvVar2 = [_currentMoviePlaybackAttributes attributeObservingController];
        uVar1 = HSActualDidAttributeChanges;
        [pvVar2 removeObserver:self selector:@selector(moviePlaybackAttributesDidChange:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSMoviePlaybackAttributes)];
        [_currentMoviePlaybackAttributes release];
        pvVar2_2 = [aAttributes retain];
        _currentMoviePlaybackAttributes = pvVar2_2;
        [[pvVar2_2 attributeObservingController] addObserver:self selector:@selector(moviePlaybackAttributesDidChange:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSMoviePlaybackAttributes) withPriority:-0.25];
    }
}

- (id)currentMoviePlaybackAttributes
{
    return _currentMoviePlaybackAttributes;
}

- (void)setCurrentMovieUIItem:(id)aItem
{
    if (_currentMovieUIItem != aItem) {
        [_currentMovieUIItem release];
        _currentMovieUIItem = [aItem retain];
    }
}

- (id)currentMovieUIItem
{
    return _currentMovieUIItem;
}

- (void)setPreviewPlayableObject:(id)aObject
{
    if (_previewPlayableObject != aObject) {
        [_previewPlayableObject release];
        _previewPlayableObject = [aObject retain];
    }
}

- (id)availablePlaybackUIItems
{
    id pvVar1;

    if ((_needSearchAvailableLiveVideos == NO) && (_needSearchAvailableMovies == NO))
    {
        pvVar1 = _availablePlaybackItems;
        if (pvVar1 == nil) {
            pvVar1 = [NSMutableArray new];
            _availablePlaybackItems = pvVar1;
        }
    }
    else {
        [_availablePlaybackItems release];
        pvVar1 = [NSMutableArray new];
        _availablePlaybackItems = pvVar1;
        [pvVar1 addObjectsFromArray:[self availableMovieUIItems]];
        pvVar1 = _availablePlaybackItems;
        [pvVar1 addObjectsFromArray:[self availableLiveVideoUIItems]];
        pvVar1 = _availablePlaybackItems;
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001a7ad3 @ 001a7ad3, 425 bytes * /

id FUN_001a7ad3(HSPlayMovieActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  undefined *puVar5;
  id pvVar6;
  
  if (self->_needSearchAvailableLiveVideos != '\0') {
    _objc_msgSend(self->_availableLiveVideos,sel_release);
    pvVar1 = _objc_msgSend(cls_NSMutableArray,sel_new);
    self->_availableLiveVideos = pvVar1;
    pvVar1 = _objc_msgSend(self,sel_actionAttributes);
    puVar5 = &DAT_0037d030;
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0037d030);
    if (pvVar1 != (id)0x0) {
      pvVar2 = _objc_msgSend(self,sel_actionAttributes,puVar5);
      pvVar2 = _objc_msgSend(pvVar2,sel_liveVideos);
      pvVar3 = _objc_msgSend(pvVar2,sel_count);
      if (pvVar3 != (id)0x0) {
        pvVar3 = _objc_msgSend(pvVar2,sel_objectEnumerator,puVar5);
        pvVar2 = _objc_msgSend(pvVar3,sel_nextObject);
        while (pvVar2 != (id)0x0) {
          pvVar4 = _objc_msgSend(cls_HSLiveVideoUIItem,sel_alloc);
          pvVar6 = pvVar1;
          pvVar4 = _objc_msgSend(pvVar4,sel_initWithLiveVideoPlaybackItem_playbackItemSupport_,
                                 pvVar2,pvVar1);
          if (pvVar4 != (id)0x0) {
            pvVar2 = pvVar4;
            _objc_msgSend(self->_availableLiveVideos,sel_addObject_,pvVar4,pvVar6);
          }
          _objc_msgSend(pvVar4,sel_release,pvVar2,pvVar6);
          pvVar2 = _objc_msgSend(pvVar3,sel_nextObject);
        }
      }
      self->_needSearchAvailableLiveVideos = '\0';
    }
  }
  return self->_availableLiveVideos;
}

*/
- (id)availableLiveVideoUIItems
{
    if (_needSearchAvailableLiveVideos) {
        [_availableLiveVideos release];
        _availableLiveVideos = [NSMutableArray new];
        id support = [[self actionAttributes] queryHyperInterface:@protocol(HSPlaybackItemSupport)];
        if (support != nil) {
            NSArray *liveVideos = [[self actionAttributes] liveVideos];
            if ([liveVideos count] != 0) {
                for (id liveVideo in liveVideos) {
                    HSLiveVideoUIItem *item = [[HSLiveVideoUIItem alloc] initWithLiveVideoPlaybackItem:liveVideo playbackItemSupport:support];
                    if (item != nil) {
                        [_availableLiveVideos addObject:item];
                    }
                    [item release];
                }
            }
            _needSearchAvailableLiveVideos = NO;
        }
    }
    return _availableLiveVideos;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001a7c7c @ 001a7c7c, 419 bytes * /

id FUN_001a7c7c(HSPlayMovieActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  undefined *self_00;
  id pvVar3;
  id self_01;
  undefined *self_02;
  undefined *puVar4;
  
  if (self->_needSearchAvailableMovies != '\0') {
    _objc_msgSend(self->_availableMovies,sel_release);
    pvVar1 = _objc_msgSend(cls_NSMutableArray,sel_new);
    self->_availableMovies = pvVar1;
    pvVar1 = _objc_msgSend(self,sel_actionAttributes);
    puVar4 = &DAT_0037d030;
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0037d030);
    if (pvVar1 != (id)0x0) {
      pvVar2 = _objc_msgSend(self,sel_actionAttributes,puVar4);
      pvVar2 = _objc_msgSend(pvVar2,sel_movies);
      pvVar2 = _objc_msgSend(pvVar2,sel_objectEnumerator);
      self_00 = _objc_msgSend(pvVar2,sel_nextObject);
      while (self_00 != (undefined *)0x0) {
        pvVar3 = _objc_msgSend(self_00,sel_movieMediaUID);
        if (pvVar3 != (id)0x0) {
          self_01 = _objc_msgSend(cls_HSMovieUIItem,sel_alloc);
          pvVar3 = pvVar1;
          self_02 = _objc_msgSend(self_01,sel_initWithMoviePlaybackItem_playbackItemSupport_,self_00
                                  ,pvVar1);
          puVar4 = self_00;
          if (self_02 != (undefined *)0x0) {
            puVar4 = self_02;
            _objc_msgSend(self->_availableMovies,sel_addObject_,self_02,pvVar3);
          }
          _objc_msgSend(self_02,sel_release,puVar4,pvVar3);
        }
        self_00 = _objc_msgSend(pvVar2,sel_nextObject,puVar4);
      }
      self->_needSearchAvailableMovies = '\0';
    }
  }
  return self->_availableMovies;
}

*/
- (id)availableMovieUIItems
{
    if (_needSearchAvailableMovies) {
        [_availableMovies release];
        _availableMovies = [NSMutableArray new];
        id support = [[self actionAttributes] queryHyperInterface:@protocol(HSPlaybackItemSupport)];
        if (support != nil) {
            for (id movie in [[self actionAttributes] movies]) {
                // Movies whose media is gone are not listed.
                if ([movie movieMediaUID] == nil) {
                    continue;
                }
                HSMovieUIItem *item = [[HSMovieUIItem alloc] initWithMoviePlaybackItem:movie playbackItemSupport:support];
                if (item != nil) {
                    [_availableMovies addObject:item];
                }
                [item release];
            }
            _needSearchAvailableMovies = NO;
        }
    }
    return _availableMovies;
}

- (id)tableView:(id)aView toolTipForCell:(id)aCell rect:(NSRect *)aRect tableColumn:(id)aColumn row:(NSInteger)aRow mouseLocation:(NSPoint)aLocation
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Select a video to be played." value:@"" table:@"AssistantPanes"];
}

- (void)tableViewSelectionDidChange:(id)aChange
{
    if ([self isPlaying]) {
        [self stopPlaying];
    }
    [self updateCurrentPlaybackAttributes];
    [self validateUserInterface];
}

- (void)tableView:(id)aView sortDescriptorsDidChange:(id)aChange
{
    id pvVar1_4;

    if ([[self availablePlaybackUIItems] count] != 0) {
        pvVar1_4 = [[self availablePlaybackUIItems] objectAtIndex:[_playbackItemsTableView selectedRow]];
        [[self availablePlaybackUIItems] sortUsingDescriptors:[aView sortDescriptors]];
        [_playbackItemsTableView reloadData];
        if (pvVar1_4 != nil) {
            [_playbackItemsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:[[self availablePlaybackUIItems] indexOfObject:pvVar1_4]] byExtendingSelection:NO];
        }
        [self validateUserInterface];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001a8067 @ 001a8067, 568 bytes * /

void FUN_001a8067(HSPlayMovieActionAssistantPane *self,SEL _cmd,id tableView,id setObjectValue,
                 id forTableColumn,int row)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  cfstringStruct *pcVar3;
  undefined4 uVar4;
  
  pvVar1 = _objc_msgSend(forTableColumn,sel_identifier);
  pcVar3 = &cfstr_HSPlayMovieActionCheckBoxTableColumn;
  pvVar1 = _objc_msgSend(pvVar1,sel_isEqual_,&cfstr_HSPlayMovieActionCheckBoxTableColumn);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(self,sel_availablePlaybackUIItems,pcVar3);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,row);
    self_00 = _objc_msgSend(pvVar1,sel_playbackItem);
    pvVar2 = _objc_msgSend(setObjectValue,sel_boolValue);
    if ((char)pvVar2 == '\0') {
      _objc_msgSend(self,sel_disableUndoRegistration,row);
      uVar4 = 0;
      _objc_msgSend(self_00,sel_setEnabled_,0);
    }
    else {
      pvVar1 = _objc_msgSend(pvVar1,sel_isInAction,row);
      if ((char)pvVar1 == '\0') {
        pvVar1 = _objc_msgSend(self_00,sel_implementsHyperInterface_,&DAT_0037c978);
        if ((char)pvVar1 == '\0') {
          row = (int)&DAT_0037cfb8;
          pvVar1 = _objc_msgSend(self_00,sel_implementsHyperInterface_,&DAT_0037cfb8);
          if ((char)pvVar1 != '\0') {
            row = (int)_objc_msgSend(self_00,sel_queryHyperInterface_,&DAT_0037cfb8);
            pvVar1 = _objc_msgSend(self,sel_playMovieActionApplier);
            _objc_msgSend(pvVar1,sel_addLiveVideo_,row);
            self->_needSearchAvailableLiveVideos = '\x01';
          }
        }
        else {
          row = (int)_objc_msgSend(self_00,sel_queryHyperInterface_,&DAT_0037c978);
          pvVar1 = _objc_msgSend(self,sel_playMovieActionApplier);
          _objc_msgSend(pvVar1,sel_addMovie_,row);
          self->_needSearchAvailableMovies = '\x01';
        }
      }
      _objc_msgSend(self,sel_disableUndoRegistration,row);
      uVar4 = 1;
      _objc_msgSend(self_00,sel_setEnabled_,1);
    }
    _objc_msgSend(self,sel_enableUndoRegistration,uVar4);
    _objc_msgSend(self,sel_validateUserInterface);
  }
  return;
}

*/
- (void)tableView:(id)aView setObjectValue:(id)aValue forTableColumn:(id)aColumn row:(NSInteger)aRow
{
    if (![[aColumn identifier] isEqual:@"HSPlayMovieActionCheckBoxTableColumn"]) {
        return;
    }
    id item = [[self availablePlaybackUIItems] objectAtIndex:aRow];
    id playbackItem = [item playbackItem];
    if ([aValue boolValue]) {
        if (![item isInAction]) {
            // Checking an item that is not in the action yet adds it.
            if ([playbackItem implementsHyperInterface:@protocol(HSMoviePlaybackAttributes)]) {
                [[self playMovieActionApplier] addMovie:[playbackItem queryHyperInterface:@protocol(HSMoviePlaybackAttributes)]];
                _needSearchAvailableMovies = YES;
            } else if ([playbackItem implementsHyperInterface:@protocol(HSLiveVideoPlaybackAttributes)]) {
                [[self playMovieActionApplier] addLiveVideo:[playbackItem queryHyperInterface:@protocol(HSLiveVideoPlaybackAttributes)]];
                _needSearchAvailableLiveVideos = YES;
            }
        }
        [self disableUndoRegistration];
        [playbackItem setEnabled:YES];
    } else {
        [self disableUndoRegistration];
        [playbackItem setEnabled:NO];
    }
    [self enableUndoRegistration];
    [self validateUserInterface];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001a829f @ 001a829f, 503 bytes * /

id FUN_001a829f(HSPlayMovieActionAssistantPane *self,SEL _cmd,id tableView,
               id objectValueForTableColumn,int row)

{
  id pvVar1;
  undefined *self_00;
  id pvVar2;
  cfstringStruct *pcVar3;
  SEL op;
  cfstringStruct *pcVar4;
  undefined *puVar5;
  
  pvVar1 = _objc_msgSend(self,sel_availablePlaybackUIItems);
  self_00 = _objc_msgSend(pvVar1,sel_objectAtIndex_,row);
  pvVar1 = _objc_msgSend(objectValueForTableColumn,sel_identifier);
  pcVar4 = &cfstr_HSPlayMovieActionCheckBoxTableColumn;
  pvVar1 = _objc_msgSend(pvVar1,sel_isEqual_,&cfstr_HSPlayMovieActionCheckBoxTableColumn);
  puVar5 = cls_NSNumber;
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(objectValueForTableColumn,sel_identifier,pcVar4);
    pcVar4 = &cfstr_HSPlayMovieActionMovieNameTableColumn;
    pvVar1 = _objc_msgSend(pvVar1,sel_isEqual_,&cfstr_HSPlayMovieActionMovieNameTableColumn);
    if ((char)pvVar1 == '\0') {
      pvVar1 = _objc_msgSend(objectValueForTableColumn,sel_identifier,pcVar4);
      pcVar3 = &cfstr_HSPlayMovieActionMovidDurationTableColumn;
      pvVar1 = _objc_msgSend(pvVar1,sel_isEqual_,&cfstr_HSPlayMovieActionMovidDurationTableColumn);
      op = sel_duration;
      if ((char)pvVar1 == '\0') {
        return (id)0x0;
      }
    }
    else {
      pvVar1 = _objc_msgSend(self_00,sel_displayName,pcVar4);
      pcVar3 = _objc_msgSend(pvVar1,sel_stringByDeletingPathExtension);
      if (pcVar3 == (cfstringStruct *)0x0) {
        return (id)0x0;
      }
      pvVar1 = _objc_msgSend(self_00,sel_isTemporary,pcVar4);
      if ((char)pvVar1 != '\0') {
        return pcVar3;
      }
      puVar5 = &DAT_0037cd60;
      pvVar1 = _objc_msgSend(self_00,sel_implementsHyperInterface_,&DAT_0037cd60);
      if ((char)pvVar1 == '\0') {
        return pcVar3;
      }
      pvVar1 = _objc_msgSend(cls_NSAttributedString,sel_alloc,puVar5);
      pvVar2 = _objc_msgSend(self,sel_movieDisplayNameFontAttributes);
      self_00 = _objc_msgSend(pvVar1,sel_initWithString_attributes_,pcVar3,pvVar2);
      op = sel_autorelease;
    }
  }
  else {
    pvVar1 = _objc_msgSend(self_00,sel_isEnabled,pcVar4);
    pcVar3 = (cfstringStruct *)((uint)pvVar1 & 0xff);
    self_00 = puVar5;
    op = sel_numberWithBool_;
  }
  pvVar1 = _objc_msgSend(self_00,op,pcVar3);
  return pvVar1;
}

*/
- (id)tableView:(id)aView objectValueForTableColumn:(id)aColumn row:(NSInteger)aRow
{
    id item = [[self availablePlaybackUIItems] objectAtIndex:aRow];
    NSString *identifier = [aColumn identifier];
    if ([identifier isEqual:@"HSPlayMovieActionCheckBoxTableColumn"]) {
        return [NSNumber numberWithBool:[item isEnabled]];
    }
    if ([identifier isEqual:@"HSPlayMovieActionMovieNameTableColumn"]) {
        NSString *name = [[item displayName] stringByDeletingPathExtension];
        if (name == nil) {
            return nil;
        }
        if ([item isTemporary] || ![item implementsHyperInterface:@protocol(HSMovieUIItemInterface)]) {
            return name;
        }
        return [[[NSAttributedString alloc] initWithString:name attributes:[self movieDisplayNameFontAttributes]] autorelease];
    }
    if ([identifier isEqual:@"HSPlayMovieActionMovidDurationTableColumn"]) {
        return [(HSMovieUIItem *)item duration];
    }
    return nil;
}

- (NSInteger)numberOfRowsInTableView:(id)aView
{
    return (int)[[self availablePlaybackUIItems] count];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001a84d0 @ 001a84d0, 335 bytes * /

void FUN_001a84d0(HSPlayMovieActionAssistantPane *self,SEL _cmd,id translateMovieObjectToCardCenter)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  float extraout_EDX;
  longdouble lVar3;
  longdouble lVar4;
  undefined *puVar5;
  undefined1 local_24 [8];
  float local_1c;
  float local_18;
  
  puVar5 = &DAT_0037cfa4;
  pvVar1 = _objc_msgSend(translateMovieObjectToCardCenter,sel_queryHyperInterface_,&DAT_0037cfa4);
  pvVar1 = _objc_msgSend(pvVar1,sel_queryGeometryBehaviorApplier);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(cls_NSDocumentController,sel_sharedDocumentController,puVar5);
    pvVar2 = _objc_msgSend(pvVar2,sel_currentDocument);
    pvVar2 = _objc_msgSend(pvVar2,sel_stack);
    pvVar2 = _objc_msgSend(pvVar2,sel_hyperCardSize);
    self_00 = _objc_msgSend(translateMovieObjectToCardCenter,sel_queryHyperInterface_,&DAT_0037cb6c)
    ;
    _objc_msgSend_stret(local_24,self_00,sel_frameBoundingRect);
    lVar3 = (longdouble)_ceilf((extraout_EDX - local_18) * 0.5);
    lVar4 = (longdouble)_ceilf(((float)pvVar2 - local_1c) * 0.5);
    _objc_msgSend(pvVar1,sel_moveFrameBoundingRectOriginTo_withLayoutGuidingContext_,(float)lVar4,
                  (float)lVar3,0);
  }
  return;
}

*/
- (void)translateMovieObjectToCardCenter:(id)aCenter
{
    id applier = [[aCenter queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
    if (applier == nil) {
        return;
    }
    NSSize cardSize = [[[[NSDocumentController sharedDocumentController] currentDocument] stack] hyperCardSize];
    NSRect frame = [[aCenter queryHyperInterface:@protocol(HSGeometryAttributes)] frameBoundingRect];
    NSPoint origin = NSMakePoint(ceilf((cardSize.width - frame.size.width) * 0.5f), ceilf((cardSize.height - frame.size.height) * 0.5f));
    [applier moveFrameBoundingRectOriginTo:origin withLayoutGuidingContext:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001a861f @ 001a861f, 364 bytes * /

void FUN_001a861f(HSPlayMovieActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  cfstringStruct *pcVar3;
  SEL op;
  undefined *puVar4;
  undefined4 uVar5;
  
  if (self->_temporaryAddedObject != (id)0x0) {
    puVar4 = &DAT_0037c978;
    pvVar1 = _objc_msgSend(self->_temporaryAddedObject,sel_implementsHyperInterface_,&DAT_0037c978);
    pcVar3 = &cfstr_MoviePosition;
    if ((char)pvVar1 == '\0') {
      pcVar3 = &cfstr_LiveVideoPosition;
    }
    pvVar1 = _objc_msgSend(cls_HSMoviePositionAssistantPane,sel_alloc,puVar4);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithCoachingKey_,pcVar3);
    self_00 = _objc_msgSend(pvVar1,sel_autorelease);
    pvVar1 = self->_temporaryAddedObject;
    _objc_msgSend(self_00,sel_setPlaybackItemAttributes_,pvVar1);
    pvVar2 = _objc_msgSend(self,sel_modalViewController);
    if (pvVar2 == (id)0x0) {
      pvVar1 = _objc_msgSend(cls_HSObjectAssistantNavigationController,sel_alloc,pvVar1);
      pvVar1 = _objc_msgSend(pvVar1,sel_initWithRootViewController_,self_00);
      uVar5 = 1;
      self_00 = pvVar1;
      _objc_msgSend(self,sel_presentModalViewController_animated_,pvVar1,1);
      op = sel_release;
    }
    else {
      pvVar2 = _objc_msgSend(self,sel_objectAssistantNavigationController,pvVar1);
      if (pvVar2 == (id)0x0) {
        return;
      }
      pvVar1 = _objc_msgSend(self,sel_objectAssistantNavigationController,pvVar1);
      uVar5 = 1;
      op = sel_pushViewController_animate_;
    }
    _objc_msgSend(pvVar1,op,self_00,uVar5);
  }
  return;
}

*/
- (void)choosePositionForTemporaryAddedObject
{
    if (_temporaryAddedObject == nil) {
        return;
    }
    NSString *coachingKey = [_temporaryAddedObject implementsHyperInterface:@protocol(HSMoviePlaybackAttributes)] ? @"MoviePosition" : @"LiveVideoPosition";
    HSMoviePositionAssistantPane *positionPane = [[[HSMoviePositionAssistantPane alloc] initWithCoachingKey:coachingKey] autorelease];
    [positionPane setPlaybackItemAttributes:_temporaryAddedObject];
    if ([self modalViewController] == nil) {
        HSObjectAssistantNavigationController *navigation = [[HSObjectAssistantNavigationController alloc] initWithRootViewController:positionPane];
        [self presentModalViewController:navigation animated:YES];
        [navigation release];
    } else if ([self objectAssistantNavigationController] != nil) {
        [[self objectAssistantNavigationController] pushViewController:positionPane animate:YES];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001a878b @ 001a878b, 144 bytes * /

void FUN_001a878b(HSPlayMovieActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  SEL op;
  undefined *puVar2;
  
  if (self->_temporaryAddedObject == (id)0x0) {
    return;
  }
  puVar2 = &DAT_0037c978;
  pvVar1 = _objc_msgSend(self->_temporaryAddedObject,sel_implementsHyperInterface_,&DAT_0037c978);
  op = sel_updateMovieItemsSelection;
  if ((char)pvVar1 == '\0') {
    puVar2 = &DAT_0037cfb8;
    pvVar1 = _objc_msgSend(self->_temporaryAddedObject,sel_implementsHyperInterface_,&DAT_0037cfb8);
    op = sel_updateLiveVideoItemsSelection;
    if ((char)pvVar1 == '\0') goto LAB_001a880a;
  }
  _objc_msgSend(self,op,puVar2);
LAB_001a880a:
  self->_temporaryAddedObject = (id)0x0;
  return;
}

*/
- (void)confirmTemporaryAddeObject
{
    if (_temporaryAddedObject == nil) {
        return;
    }
    if ([_temporaryAddedObject implementsHyperInterface:@protocol(HSMoviePlaybackAttributes)]) {
        [self updateMovieItemsSelection];
    } else if ([_temporaryAddedObject implementsHyperInterface:@protocol(HSLiveVideoPlaybackAttributes)]) {
        [self updateLiveVideoItemsSelection];
    }
    _temporaryAddedObject = nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001a881b @ 001a881b, 288 bytes * /

void FUN_001a881b(HSPlayMovieActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  SEL op;
  undefined *puVar2;
  
  if (self->_temporaryAddedObject == (id)0x0) goto LAB_001a8903;
  _objc_msgSend(self->_temporaryAddedObject,sel_setEnabled_,0);
  _objc_msgSend(self,sel_cleanPlaybackUIItems);
  puVar2 = &DAT_0037c978;
  pvVar1 = _objc_msgSend(self->_temporaryAddedObject,sel_queryHyperInterface_,&DAT_0037c978);
  if (pvVar1 == (id)0x0) {
    puVar2 = &DAT_0037cfb8;
    pvVar1 = _objc_msgSend(self->_temporaryAddedObject,sel_queryHyperInterface_,&DAT_0037cfb8);
    if (pvVar1 != (id)0x0) {
      self_00 = _objc_msgSend(self,sel_playMovieActionApplier,puVar2);
      op = sel_removeLiveVideo_;
      goto LAB_001a88e9;
    }
  }
  else {
    self_00 = _objc_msgSend(self,sel_playMovieActionApplier,puVar2);
    op = sel_removeMovie_;
LAB_001a88e9:
    _objc_msgSend(self_00,op,pvVar1);
  }
  self->_temporaryAddedObject = (id)0x0;
LAB_001a8903:
  pvVar1 = _objc_msgSend(self,sel_objectAssistantNavigationController);
  pvVar1 = _objc_msgSend(pvVar1,sel_isViewControllerInStack_,self);
  if ((char)pvVar1 == '\0') {
    (self->super).super._userMadeTheDecision = '\x01';
  }
  return;
}

*/
- (void)removeTemporaryAddedObject
{
    if (_temporaryAddedObject != nil) {
        [_temporaryAddedObject setEnabled:NO];
        [self cleanPlaybackUIItems];
        id movie = [_temporaryAddedObject queryHyperInterface:@protocol(HSMoviePlaybackAttributes)];
        if (movie != nil) {
            [[self playMovieActionApplier] removeMovie:movie];
        } else {
            id liveVideo = [_temporaryAddedObject queryHyperInterface:@protocol(HSLiveVideoPlaybackAttributes)];
            if (liveVideo != nil) {
                [[self playMovieActionApplier] removeLiveVideo:liveVideo];
            }
        }
        _temporaryAddedObject = nil;
    }
    if (![[self objectAssistantNavigationController] isViewControllerInStack:self]) {
        _userMadeTheDecision = YES;
    }
}

- (void)addTemporaryLiveObject:(id)aObject
{
    id pvVar1_2;

    [self translateMovieObjectToCardCenter:aObject];
    pvVar1_2 = [[HSLiveVideoPlaybackItem alloc] initWithLiveObject:aObject playMovieAction:[self actionAttributes]];
    [pvVar1_2 setEnabled:YES];
    [self disableUndoRegistration];
    [pvVar1_2 setPlayOverObjects:YES];
    [self enableUndoRegistration];
    [[self playMovieActionApplier] addLiveVideo:pvVar1_2];
    _temporaryAddedObject = pvVar1_2;
    [pvVar1_2 release];
}

- (void)addTemporaryMovieObject:(id)aObject isInUse:(BOOL)aUse
{
    id pvVar1_2;

    if (aUse == NO) {
        [self translateMovieObjectToCardCenter:aObject];
    }
    pvVar1_2 = [[HSMoviePlaybackItem alloc] initWithMovieObject:aObject playMovieAction:[self actionAttributes]];
    [pvVar1_2 setEnabled:YES];
    [[self playMovieActionApplier] addMovie:pvVar1_2];
    _temporaryAddedObject = pvVar1_2;
    [pvVar1_2 release];
}

- (void)addLiveObject:(id)aObject
{
    id pvVar1_2;

    pvVar1_2 = [[HSLiveVideoPlaybackItem alloc] initWithLiveObject:aObject playMovieAction:[self actionAttributes]];
    [pvVar1_2 setEnabled:YES];
    [self disableUndoRegistration];
    [pvVar1_2 setPlayOverObjects:YES];
    [self enableUndoRegistration];
    [[self playMovieActionApplier] addLiveVideo:pvVar1_2];
    [self updateLiveVideoItemsSelection];
}

- (void)addMovieObject:(id)aObject
{
    id pvVar1;
    HSPlayMovieActionAssistantPane *pHVar2;
    id pvVar1_6;
    SEL op_2;
    id pvVar3_2;

    pvVar1 = [HSObjectAssistantController sharedAssistantController];
    [[[pvVar1 objectAssistant] currentPane] modalViewController];
    if ((pvVar1 != nil) && (pHVar2 = [pvVar1 topViewController], op_2 = @selector(setPostAddMovieObject:), pHVar2 == self)) {
        pvVar1_6 = [[HSMoviePlaybackItem alloc] initWithMovieObject:aObject playMovieAction:[self actionAttributes]];
        [pvVar1_6 setEnabled:YES];
        pvVar3_2 = [self playMovieActionApplier];
        aObject = pvVar1_6;
        [pvVar3_2 addMovie:pvVar1_6];
        [pvVar1_6 release];
    }
    [self updateMovieItemsSelection];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001a8d74 @ 001a8d74, 232 bytes * /

void FUN_001a8d74(HSPlayMovieActionAssistantPane *self,SEL _cmd,id liveVideoPlayOverObjectsChanged)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  undefined *puVar3;
  
  _objc_msgSend(self,sel_disableUndoRegistration);
  pvVar1 = _objc_msgSend(self,sel_currentLiveVideoPlaybackAttributes);
  pvVar2 = _objc_msgSend(liveVideoPlayOverObjectsChanged,sel_state);
  puVar3 = (undefined *)(uint)(pvVar2 == (id)0x1);
  _objc_msgSend(pvVar1,sel_setPlayOverObjects_,puVar3);
  if (self->_previewPlayableObject != (id)0x0) {
    puVar3 = &DAT_0037cf90;
    pvVar1 = _objc_msgSend(self->_previewPlayableObject,sel_queryHyperInterface_,&DAT_0037cf90);
    pvVar2 = _objc_msgSend(liveVideoPlayOverObjectsChanged,sel_state);
    op = sel_moveToHyperBegin;
    if (pvVar2 == (id)0x1) {
      op = sel_moveToHyperEnd;
    }
    _objc_msgSend(pvVar1,op,puVar3);
  }
  _objc_msgSend(self,sel_enableUndoRegistration,puVar3);
  return;
}

*/
- (void)liveVideoPlayOverObjectsChanged:(id)aChanged
{
    [self disableUndoRegistration];
    [[self currentLiveVideoPlaybackAttributes] setPlayOverObjects:[aChanged state] == NSControlStateValueOn];
    if (_previewPlayableObject != nil) {
        id node = [_previewPlayableObject queryHyperInterface:@protocol(HSNodeAttributes)];
        if ([aChanged state] == NSControlStateValueOn) {
            [node moveToHyperEnd];
        } else {
            [node moveToHyperBegin];
        }
    }
    [self enableUndoRegistration];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001a8e5c @ 001a8e5c, 286 bytes * /

void FUN_001a8e5c(HSPlayMovieActionAssistantPane *self,SEL _cmd,id liveVideoShowInMirrorModeChanged)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined *puVar4;
  
  pvVar1 = _objc_msgSend(liveVideoShowInMirrorModeChanged,sel_state);
  pvVar2 = _objc_msgSend(self,sel_currentLiveVideoPlaybackAttributes);
  pvVar2 = _objc_msgSend(pvVar2,sel_liveObjectForCard_,0);
  puVar4 = &DAT_0037cfa4;
  pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_0037cfa4);
  pvVar2 = _objc_msgSend(pvVar2,sel_queryGeometryBehaviorApplier);
  pvVar3 = _objc_msgSend(self,sel_currentLiveVideoPlaybackAttributes);
  if (pvVar3 == (id)0x0) {
    return;
  }
  if (pvVar2 == (id)0x0) {
    return;
  }
  _objc_msgSend(self,sel_disableUndoRegistration,puVar4);
  if (pvVar1 == (id)0x0) {
    puVar4 = (undefined *)0x0;
  }
  else {
    if (pvVar1 != (id)0x1) goto LAB_001a8f5d;
    puVar4 = (undefined *)0x1;
  }
  _objc_msgSend(pvVar2,sel_setFlippedHorizontally_withLayoutGuidingContext_,puVar4,0);
LAB_001a8f5d:
  _objc_msgSend(self,sel_enableUndoRegistration,puVar4);
  return;
}

*/
- (void)liveVideoShowInMirrorModeChanged:(id)aChanged
{
    NSInteger state = [aChanged state];
    id applier = [[[[self currentLiveVideoPlaybackAttributes] liveObjectForCard:nil] queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
    if ([self currentLiveVideoPlaybackAttributes] == nil || applier == nil) {
        return;
    }
    [self disableUndoRegistration];
    if (state == NSControlStateValueOff) {
        [applier setFlippedHorizontally:NO withLayoutGuidingContext:nil];
    } else if (state == NSControlStateValueOn) {
        [applier setFlippedHorizontally:YES withLayoutGuidingContext:nil];
    }
    [self enableUndoRegistration];
}

- (void)cameraChanged:(id)aChanged
{
    id pvVar1;

    pvVar1 = [self currentLiveVideoPlaybackAttributes];
    if (pvVar1 != nil) {
        [pvVar1 setLiveVideoDeviceIndex:[_availableCamerasPopUpButton indexOfSelectedItem]];
        [self HSPlayMovieActionAssistantPane_updateSelectedCaptureDevice:[[_availableCamerasPopUpButton selectedItem] representedObject]];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001a901a @ 001a901a, 242 bytes * /

void FUN_001a901a(HSPlayMovieActionAssistantPane *self,SEL _cmd,id volumeChangedToMaximum)

{
  id pvVar1;
  id pvVar2;
  double dVar3;
  float fVar4;
  
  _objc_msgSend(self,sel_disableUndoRegistration);
  pvVar1 = _objc_msgSend(self,sel_playMovieActionApplier);
  dVar3 = _objc_msgSend_fpret(self->_volumeSlider,sel_maxValue);
  pvVar2 = _objc_msgSend(self,sel_currentMoviePlaybackAttributes);
  fVar4 = (float)dVar3;
  _objc_msgSend(pvVar1,sel_setMoviePlaybackItem_volume_,pvVar2,fVar4);
  if (self->_previewPlayableObject != (id)0x0) {
    pvVar1 = _objc_msgSend(self->_previewPlayableObject,sel_queryHyperInterface_,&DAT_0037cd88,fVar4
                          );
    dVar3 = _objc_msgSend_fpret(self->_volumeSlider,sel_maxValue);
    pvVar2 = (id)(float)dVar3;
    _objc_msgSend(pvVar1,sel_setHyperVolume_,pvVar2);
  }
  _objc_msgSend(self,sel_enableUndoRegistration,pvVar2,fVar4);
  return;
}

*/
- (void)volumeChangedToMaximum:(id)aMaximum
{
    [self disableUndoRegistration];
    [[self playMovieActionApplier] setMoviePlaybackItem:[self currentMoviePlaybackAttributes] volume:(float)[_volumeSlider maxValue]];
    if (_previewPlayableObject != nil) {
        [[_previewPlayableObject queryHyperInterface:@protocol(HSMovieObjectAttributes)] setHyperVolume:(float)[_volumeSlider maxValue]];
    }
    [self enableUndoRegistration];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001a910c @ 001a910c, 242 bytes * /

void FUN_001a910c(HSPlayMovieActionAssistantPane *self,SEL _cmd,id volumeChangedToMinimum)

{
  id pvVar1;
  id pvVar2;
  double dVar3;
  float fVar4;
  
  _objc_msgSend(self,sel_disableUndoRegistration);
  pvVar1 = _objc_msgSend(self,sel_playMovieActionApplier);
  dVar3 = _objc_msgSend_fpret(self->_volumeSlider,sel_minValue);
  pvVar2 = _objc_msgSend(self,sel_currentMoviePlaybackAttributes);
  fVar4 = (float)dVar3;
  _objc_msgSend(pvVar1,sel_setMoviePlaybackItem_volume_,pvVar2,fVar4);
  if (self->_previewPlayableObject != (id)0x0) {
    pvVar1 = _objc_msgSend(self->_previewPlayableObject,sel_queryHyperInterface_,&DAT_0037cd88,fVar4
                          );
    dVar3 = _objc_msgSend_fpret(self->_volumeSlider,sel_minValue);
    pvVar2 = (id)(float)dVar3;
    _objc_msgSend(pvVar1,sel_setHyperVolume_,pvVar2);
  }
  _objc_msgSend(self,sel_enableUndoRegistration,pvVar2,fVar4);
  return;
}

*/
- (void)volumeChangedToMinimum:(id)aMinimum
{
    [self disableUndoRegistration];
    [[self playMovieActionApplier] setMoviePlaybackItem:[self currentMoviePlaybackAttributes] volume:(float)[_volumeSlider minValue]];
    if (_previewPlayableObject != nil) {
        [[_previewPlayableObject queryHyperInterface:@protocol(HSMovieObjectAttributes)] setHyperVolume:(float)[_volumeSlider minValue]];
    }
    [self enableUndoRegistration];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001a91fe @ 001a91fe, 216 bytes * /

void FUN_001a91fe(HSPlayMovieActionAssistantPane *self,SEL _cmd,id volumeChanged)

{
  id pvVar1;
  id pvVar2;
  longdouble lVar3;
  float fVar4;
  
  _objc_msgSend(self,sel_disableUndoRegistration);
  pvVar1 = _objc_msgSend(self,sel_playMovieActionApplier);
  lVar3 = (longdouble)_HSNonLinearValueForSlider(volumeChanged);
  pvVar2 = _objc_msgSend(self,sel_currentMoviePlaybackAttributes);
  fVar4 = (float)lVar3;
  _objc_msgSend(pvVar1,sel_setMoviePlaybackItem_volume_,pvVar2,fVar4);
  if (self->_previewPlayableObject != (id)0x0) {
    pvVar1 = _objc_msgSend(self->_previewPlayableObject,sel_queryHyperInterface_,&DAT_0037cd88,fVar4
                          );
    lVar3 = (longdouble)_HSNonLinearValueForSlider(volumeChanged);
    pvVar2 = (id)(float)lVar3;
    _objc_msgSend(pvVar1,sel_setHyperVolume_,pvVar2);
  }
  _objc_msgSend(self,sel_enableUndoRegistration,pvVar2,fVar4);
  return;
}

*/
- (void)volumeChanged:(id)aChanged
{
    [self disableUndoRegistration];
    [[self playMovieActionApplier] setMoviePlaybackItem:[self currentMoviePlaybackAttributes] volume:HSNonLinearValueForSlider(aChanged)];
    if (_previewPlayableObject != nil) {
        [[_previewPlayableObject queryHyperInterface:@protocol(HSMovieObjectAttributes)] setHyperVolume:HSNonLinearValueForSlider(aChanged)];
    }
    [self enableUndoRegistration];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001a92d6 @ 001a92d6, 90 bytes * /

void FUN_001a92d6(HSPlayMovieActionAssistantPane *self,SEL _cmd,id play)

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
/* FUN_001a9330 @ 001a9330, 386 bytes * /

void FUN_001a9330(HSPlayMovieActionAssistantPane *self,SEL _cmd,id choosePosition)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  cfstringStruct *pcVar4;
  SEL pcVar5;
  undefined4 uVar6;
  
  pvVar1 = _objc_msgSend(self,sel_currentMoviePlaybackAttributes);
  if (pvVar1 == (id)0x0) {
    pcVar4 = &cfstr_LiveVideoPosition;
    pcVar5 = sel_currentLiveVideoPlaybackAttributes;
  }
  else {
    pcVar4 = &cfstr_MoviePosition;
    pcVar5 = sel_currentMoviePlaybackAttributes;
  }
  pvVar2 = _objc_msgSend(self,pcVar5);
  pvVar1 = _objc_msgSend(cls_HSMoviePositionAssistantPane,sel_alloc);
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithCoachingKey_,pcVar4);
  pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  _objc_msgSend(pvVar1,sel_setPlaybackItemAttributes_,pvVar2);
  pvVar3 = _objc_msgSend(self,sel_modalViewController);
  if (pvVar3 == (id)0x0) {
    pvVar2 = _objc_msgSend(cls_HSObjectAssistantNavigationController,sel_alloc,pvVar2);
    pvVar2 = _objc_msgSend(pvVar2,sel_initWithRootViewController_,pvVar1);
    uVar6 = 1;
    pvVar1 = pvVar2;
    _objc_msgSend(self,sel_presentModalViewController_animated_,pvVar2,1);
    pcVar5 = sel_release;
  }
  else {
    pvVar3 = _objc_msgSend(self,sel_objectAssistantNavigationController,pvVar2);
    if (pvVar3 == (id)0x0) {
      return;
    }
    pvVar2 = _objc_msgSend(self,sel_objectAssistantNavigationController,pvVar2);
    uVar6 = 1;
    pcVar5 = sel_pushViewController_animate_;
  }
  _objc_msgSend(pvVar2,pcVar5,pvVar1,uVar6);
  return;
}

*/
- (void)choosePosition:(id)aPosition
{
    NSString *coachingKey;
    id attributes;
    if ([self currentMoviePlaybackAttributes] != nil) {
        coachingKey = @"MoviePosition";
        attributes = [self currentMoviePlaybackAttributes];
    } else {
        coachingKey = @"LiveVideoPosition";
        attributes = [self currentLiveVideoPlaybackAttributes];
    }
    HSMoviePositionAssistantPane *positionPane = [[[HSMoviePositionAssistantPane alloc] initWithCoachingKey:coachingKey] autorelease];
    [positionPane setPlaybackItemAttributes:attributes];
    if ([self modalViewController] == nil) {
        HSObjectAssistantNavigationController *navigation = [[HSObjectAssistantNavigationController alloc] initWithRootViewController:positionPane];
        [self presentModalViewController:navigation animated:YES];
        [navigation release];
    } else if ([self objectAssistantNavigationController] != nil) {
        [[self objectAssistantNavigationController] pushViewController:positionPane animate:YES];
    }
}

- (void)rightRangeKnobActivated:(id)aActivated
{
    if (_rangeControl == aActivated) {
        [[[self currentMoviePlaybackAttributes] movieObjectForCard:[self card]] setHyperCurrentTime:[_rangeControl finishTime]];
    }
}

- (void)leftRangeKnobActivated:(id)aActivated
{
    if (_rangeControl == aActivated) {
        [[[self currentMoviePlaybackAttributes] movieObjectForCard:[self card]] setHyperCurrentTime:[_rangeControl startTime]];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001a95d4 @ 001a95d4, 145 bytes * /

void FUN_001a95d4(HSPlayMovieActionAssistantPane *self,SEL _cmd,id fadeOutChanged)

{
  id self_00;
  id pvVar1;
  
  _objc_msgSend(self,sel_disableUndoRegistration);
  self_00 = _objc_msgSend(self,sel_currentMoviePlaybackAttributes);
  pvVar1 = _objc_msgSend(fadeOutChanged,sel_state);
  _objc_msgSend(self_00,sel_setSoundFadeOutTime_,
                *(undefined8 *)(&DAT_00335940 + (uint)(pvVar1 == (id)0x1) * 8));
  _objc_msgSend(self,sel_enableUndoRegistration);
  return;
}

*/
- (void)fadeOutChanged:(id)aChanged
{
    [self disableUndoRegistration];
    [[self currentMoviePlaybackAttributes] setSoundFadeOutTime:[aChanged state] == NSControlStateValueOn ? 2.0 : 0.0];
    [self enableUndoRegistration];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001a9665 @ 001a9665, 631 bytes * /

void FUN_001a9665(HSPlayMovieActionAssistantPane *self,SEL _cmd,id rangeChanged)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  float fVar3;
  float fVar4;
  float fVar5;
  float fVar6;
  double dVar7;
  double dVar8;
  double dVar9;
  undefined4 uVar10;
  double local_24;
  double local_1c;
  
  dVar7 = _objc_msgSend_fpret(self->_rangeControl,sel_startTime);
  dVar8 = _objc_msgSend_fpret(self->_rangeControl,sel_finishTime);
  dVar9 = _objc_msgSend_fpret(self->_rangeControl,sel_startTime);
  pvVar1 = _objc_msgSend(self,sel_currentMoviePlaybackAttributes);
  _objc_msgSend_stret(&local_24,pvVar1,sel_playRange);
  pvVar2 = _objc_msgSend(self,sel_card);
  pvVar2 = _objc_msgSend(pvVar1,sel_movieObjectForCard_,pvVar2);
  _objc_msgSend(self,sel_disableUndoRegistration);
  self_00 = _objc_msgSend(self,sel_playMovieActionApplier);
  dVar8 = dVar8 - dVar9;
  uVar10 = (undefined4)((ulonglong)dVar7 >> 0x20);
  dVar9 = dVar8;
  _objc_msgSend(self_00,sel_setMoviePlaybackItem_playRange_,pvVar1,SUB84(dVar7,0),uVar10,dVar8);
  _objc_msgSend(self,sel_enableUndoRegistration);
  pvVar1 = _objc_msgSend(pvVar2,sel_isHyperPlaying);
  if ((char)pvVar1 == '\0') {
    fVar4 = (float)local_24;
    fVar3 = (float)dVar7;
    if ((fVar4 != 0.0) || (NAN(fVar4))) {
      fVar5 = ABS(fVar4);
    }
    else {
      fVar5 = 1.0;
    }
    if ((fVar3 != 0.0) || (NAN(fVar3))) {
      fVar6 = ABS(fVar3);
    }
    else {
      fVar6 = 1.0;
    }
    if (fVar6 <= fVar5) {
      fVar6 = fVar5;
    }
    if (ABS(fVar4 - fVar3) <= fVar6 * 0.0005) {
      fVar4 = (float)local_1c;
      fVar3 = (float)dVar8;
      if ((fVar4 != 0.0) || (NAN(fVar4))) {
        fVar5 = ABS(fVar4);
      }
      else {
        fVar5 = 1.0;
      }
      if ((fVar3 != 0.0) || (NAN(fVar3))) {
        fVar6 = ABS(fVar3);
      }
      else {
        fVar6 = 1.0;
      }
      if (fVar6 <= fVar5) {
        fVar6 = fVar5;
      }
      if (ABS(fVar4 - fVar3) <= fVar6 * 0.0005) {
        return;
      }
      dVar7 = dVar7 + dVar8;
    }
    _objc_msgSend(pvVar2,sel_setHyperCurrentTime_,SUB84(dVar7,0),(int)((ulonglong)dVar7 >> 0x20),
                  uVar10,dVar9);
  }
  return;
}

*/
- (void)rangeChanged:(id)aChanged
{
    double start = [_rangeControl startTime];
    double length = [_rangeControl finishTime] - [_rangeControl startTime];
    id attributes = [self currentMoviePlaybackAttributes];
    struct HSTimeRange oldRange = [attributes playRange];
    id movie = [attributes movieObjectForCard:[self card]];
    [self disableUndoRegistration];
    struct HSTimeRange range = { start, length };
    [[self playMovieActionApplier] setMoviePlaybackItem:attributes playRange:range];
    [self enableUndoRegistration];
    if ([movie isHyperPlaying]) {
        return;
    }
    // Show the frame at whichever knob moved.
    double time = start;
    if (HSPlayMovieTimesAreEqual((float)oldRange.location, (float)start)) {
        if (HSPlayMovieTimesAreEqual((float)oldRange.length, (float)length)) {
            return;
        }
        time = start + length;
    }
    [movie setHyperCurrentTime:time];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001a98dc @ 001a98dc, 232 bytes * /

void FUN_001a98dc(HSPlayMovieActionAssistantPane *self,SEL _cmd,id playOverObjectsChanged)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  undefined *puVar3;
  
  pvVar1 = _objc_msgSend(self,sel_currentMoviePlaybackAttributes);
  _objc_msgSend(self,sel_disableUndoRegistration);
  pvVar2 = _objc_msgSend(playOverObjectsChanged,sel_state);
  puVar3 = (undefined *)(uint)(pvVar2 == (id)0x1);
  _objc_msgSend(pvVar1,sel_setPlayOverObjects_,puVar3);
  if (self->_previewPlayableObject != (id)0x0) {
    puVar3 = &DAT_0037cf90;
    pvVar1 = _objc_msgSend(self->_previewPlayableObject,sel_queryHyperInterface_,&DAT_0037cf90);
    pvVar2 = _objc_msgSend(playOverObjectsChanged,sel_state);
    op = sel_moveToHyperBegin;
    if (pvVar2 == (id)0x1) {
      op = sel_moveToHyperEnd;
    }
    _objc_msgSend(pvVar1,op,puVar3);
  }
  _objc_msgSend(self,sel_enableUndoRegistration,puVar3);
  return;
}

*/
- (void)playOverObjectsChanged:(id)aChanged
{
    id attributes = [self currentMoviePlaybackAttributes];
    [self disableUndoRegistration];
    [attributes setPlayOverObjects:[aChanged state] == NSControlStateValueOn];
    if (_previewPlayableObject != nil) {
        id node = [_previewPlayableObject queryHyperInterface:@protocol(HSNodeAttributes)];
        if ([aChanged state] == NSControlStateValueOn) {
            [node moveToHyperEnd];
        } else {
            [node moveToHyperBegin];
        }
    }
    [self enableUndoRegistration];
}

- (void)showFirstFrameCanged:(id)aCanged
{
    [self disableUndoRegistration];
    [[self currentMoviePlaybackAttributes] setShowFirstFrame:(unsigned int)([aCanged state] == 0x1)];
    [self enableUndoRegistration];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001a9a4a @ 001a9a4a, 390 bytes * /

void FUN_001a9a4a(HSPlayMovieActionAssistantPane *self,SEL _cmd,id playCountChanged)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar1 = _objc_msgSend(self,sel_currentMoviePlaybackAttributes);
  if (pvVar1 == (id)0x0) {
    return;
  }
  _objc_msgSend(self,sel_disableUndoRegistration);
  pvVar1 = self->_playCountTextField;
  pvVar3 = self->_playCountStepper;
  if (pvVar1 == playCountChanged) {
    pvVar2 = _objc_msgSend(playCountChanged,sel_intValue);
    pvVar1 = pvVar3;
  }
  else {
    if (pvVar3 != playCountChanged) goto LAB_001a9af4;
    pvVar2 = _objc_msgSend(playCountChanged,sel_intValue);
  }
  _objc_msgSend(pvVar1,sel_setIntValue_,pvVar2);
LAB_001a9af4:
  pvVar1 = _objc_msgSend(self,sel_currentMoviePlaybackAttributes);
  pvVar3 = _objc_msgSend(playCountChanged,sel_intValue);
  _objc_msgSend(pvVar1,sel_setPlayCount_,pvVar3);
  if (self->_previewPlayableObject != (id)0x0) {
    pvVar1 = _objc_msgSend(self->_previewPlayableObject,sel_queryHyperInterface_,&DAT_0037cd88);
    pvVar3 = _objc_msgSend(playCountChanged,sel_intValue);
    _objc_msgSend(pvVar1,sel_setHyperPlayCount_,pvVar3);
  }
  _objc_msgSend(self,sel_enableUndoRegistration,pvVar3);
  pvVar1 = _objc_msgSend(self,sel_isPlaying);
  if ((char)pvVar1 != '\0') {
    _objc_msgSend(self,sel_stopPlaying,pvVar3);
  }
  return;
}

*/
- (void)playCountChanged:(id)aChanged
{
    if ([self currentMoviePlaybackAttributes] == nil) {
        return;
    }
    [self disableUndoRegistration];
    // Keep the text field and the stepper in sync.
    if (aChanged == _playCountTextField) {
        [_playCountStepper setIntValue:[aChanged intValue]];
    } else if (aChanged == _playCountStepper) {
        [_playCountTextField setIntValue:[aChanged intValue]];
    }
    [[self currentMoviePlaybackAttributes] setPlayCount:[aChanged intValue]];
    if (_previewPlayableObject != nil) {
        [[_previewPlayableObject queryHyperInterface:@protocol(HSMovieObjectAttributes)] setHyperPlayCount:[aChanged intValue]];
    }
    [self enableUndoRegistration];
    if ([self isPlaying]) {
        [self stopPlaying];
    }
}

- (void)loopModeChanged:(id)aChanged
{
    HSPopUpButton *self_00;
    id pvVar1;
    int pvVar1_8;
    int pvVar2_3;
    id pvVar2_8;

    [self disableUndoRegistration];
    pvVar1 = [self currentMoviePlaybackAttributes];
    if ([[aChanged selectedCell] tag] == 0x1) {
        pvVar2_3 = 0;
    }
    else {
        pvVar2_3 = [_playCountStepper intValue];
    }
    [pvVar1 setPlayCount:pvVar2_3];
    [_playCountStepper setEnabled:(unsigned int)([[aChanged selectedCell] tag] == 0)];
    [_playCountTextField setEnabled:(unsigned int)([[aChanged selectedCell] tag] == 0)];
    self_00 = _loopPopUpButton;
    [self_00 setToolTip:[[self_00 selectedItem] toolTip]];
    if (_previewPlayableObject != nil) {
        pvVar2_8 = [_previewPlayableObject queryHyperInterface:@protocol(HSMovieObjectAttributes)];
        if ([[aChanged selectedCell] tag] == 0x1) {
            pvVar1_8 = 0;
        }
        else {
            pvVar1_8 = [_playCountStepper intValue];
        }
        [pvVar2_8 setHyperPlayCount:pvVar1_8];
    }
    [self enableUndoRegistration];
    if ([self isPlaying]) {
        [self stopPlaying];
    }
}

- (void)useMovieControllerChanged:(id)aChanged
{
    id self_00;
    NSInteger pvVar1;

    [self disableUndoRegistration];
    self_00 = [self playMovieActionApplier];
    pvVar1 = [aChanged state];
    [self_00 setMoviePlaybackItem:[self currentMoviePlaybackAttributes] useMovieController:(unsigned int)(pvVar1 == 0x1)];
    [self enableUndoRegistration];
}

- (void)eraseWhenDoneChanged:(id)aChanged
{
    [self disableUndoRegistration];
    [[self currentMoviePlaybackAttributes] setEraseWhenDone:(unsigned int)([aChanged state] == 0x1)];
    [self enableUndoRegistration];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001a9f31 @ 001a9f31, 154 bytes * /

void FUN_001a9f31(HSPlayMovieActionAssistantPane *self,SEL _cmd,id add)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(self,sel_isPlaying);
  if ((char)pvVar1 != '\0') {
    _objc_msgSend(self,sel_stopPlaying);
  }
  pvVar1 = _objc_msgSend(self,sel_objectAssistantNavigationController);
  pvVar2 = _objc_msgSend(self,sel_pickMovieSourceAssistantPane);
  _objc_msgSend(pvVar1,sel_pushViewController_withIdentifier_animate_replacePrevious_,pvVar2,
                *(undefined4 *)PTR_PTR_003366c8,1,0);
  return;
}

*/
- (void)add:(id)aAdd
{
    if ([self isPlaying]) {
        [self stopPlaying];
    }
    [[self objectAssistantNavigationController] pushViewController:[self pickMovieSourceAssistantPane] withIdentifier:HSPickMovieSourcePaneIdentifier animate:YES replacePrevious:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001a9fcb @ 001a9fcb, 444 bytes * /

void FUN_001a9fcb(HSPlayMovieActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  undefined4 uVar3;
  undefined *puVar4;
  
  pvVar1 = _objc_msgSend(self->_playbackItemsTableView,sel_selectedRow);
  _objc_msgSend(self,sel_setCurrentLiveVideoUIItem_,0);
  _objc_msgSend(self,sel_setCurrentLiveVideoPlaybackAttributes_,0);
  _objc_msgSend(self,sel_setCurrentMovieUIItem_,0);
  uVar3 = 0;
  _objc_msgSend(self,sel_setCurrentMoviePlaybackAttributes_,0);
  if (-1 < (int)pvVar1) {
    pvVar2 = _objc_msgSend(self,sel_availablePlaybackUIItems,uVar3);
    pvVar2 = _objc_msgSend(pvVar2,sel_count);
    if ((int)pvVar1 < (int)pvVar2) {
      pvVar2 = _objc_msgSend(self,sel_availablePlaybackUIItems,uVar3);
      pvVar1 = _objc_msgSend(pvVar2,sel_objectAtIndex_,pvVar1);
      puVar4 = &DAT_0037cd60;
      pvVar2 = _objc_msgSend(pvVar1,sel_implementsHyperInterface_,&DAT_0037cd60);
      if ((char)pvVar2 == '\0') {
        puVar4 = &DAT_0037cd74;
        pvVar2 = _objc_msgSend(pvVar1,sel_implementsHyperInterface_,&DAT_0037cd74);
        if ((char)pvVar2 == '\0') {
          return;
        }
        pvVar2 = _objc_msgSend(pvVar1,sel_liveVideoPlaybackItem,puVar4);
        _objc_msgSend(self,sel_setCurrentLiveVideoUIItem_,pvVar1);
        op = sel_setCurrentLiveVideoPlaybackAttributes_;
      }
      else {
        pvVar2 = _objc_msgSend(pvVar1,sel_moviePlaybackItem,puVar4);
        _objc_msgSend(self,sel_setCurrentMovieUIItem_,pvVar1);
        op = sel_setCurrentMoviePlaybackAttributes_;
      }
      _objc_msgSend(self,op,pvVar2);
    }
  }
  return;
}

*/
- (void)updateCurrentPlaybackAttributes
{
    NSInteger row = [_playbackItemsTableView selectedRow];
    [self setCurrentLiveVideoUIItem:nil];
    [self setCurrentLiveVideoPlaybackAttributes:nil];
    [self setCurrentMovieUIItem:nil];
    [self setCurrentMoviePlaybackAttributes:nil];
    if (row < 0 || row >= (NSInteger)[[self availablePlaybackUIItems] count]) {
        return;
    }
    id item = [[self availablePlaybackUIItems] objectAtIndex:row];
    if ([item implementsHyperInterface:@protocol(HSMovieUIItemInterface)]) {
        id attributes = [item moviePlaybackItem];
        [self setCurrentMovieUIItem:item];
        [self setCurrentMoviePlaybackAttributes:attributes];
    } else if ([item implementsHyperInterface:@protocol(HSLiveVideoUIItemInterface)]) {
        id attributes = [item liveVideoPlaybackItem];
        [self setCurrentLiveVideoUIItem:item];
        [self setCurrentLiveVideoPlaybackAttributes:attributes];
    }
}

- (void)validateUserInterface
{
    [self mountOptionsContentView:[self suggestedOptionsContentView]];
    [self validateUserInterfaceInMovieOptions];
    [self validateUserInterfaceInLiveVideoOptions];
    [[self navigationPaneSwitcher] validateUserInterface];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001aa20f @ 001aa20f, 2485 bytes * /

void FUN_001aa20f(HSPlayMovieActionAssistantPane *self,SEL _cmd)

{
  bool bVar1;
  bool bVar2;
  bool bVar3;
  char cVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  id pvVar8;
  id pvVar9;
  id pvVar10;
  id pvVar11;
  SEL op;
  uint uVar12;
  uint uVar13;
  int iVar14;
  bool bVar15;
  bool bVar16;
  undefined4 uVar17;
  char local_21;
  
  pvVar5 = _objc_msgSend(self,sel_currentMoviePlaybackAttributes);
  if (pvVar5 == (id)0x0) {
    _objc_msgSend(self->_addMovieButton,sel_setEnabled_,1);
    _objc_msgSend(self->_moviePositionButton,sel_setEnabled_,0);
    _objc_msgSend(self->_volumeSlider,sel_setEnabled_,0);
    _objc_msgSend(self->_minVolumeButton,sel_setEnabled_,0);
    _objc_msgSend(self->_maxVolumeButton,sel_setEnabled_,0);
    _objc_msgSend(self->_showFirstFrameSwitch,sel_setEnabled_,0);
    _objc_msgSend(self->_playOverObjectsSwitch,sel_setEnabled_,0);
    _objc_msgSend(self->_useMovieControllerSwitch,sel_setEnabled_,0);
    _objc_msgSend(self->_eraseWhenDoneSwitch,sel_setEnabled_,0);
    _objc_msgSend(self->_fadeOutSwitchButton,sel_setEnabled_,0);
    _objc_msgSend(self->_rangeControl,sel_setEnabled_,0);
    _objc_msgSend(self->_playMovieButton,sel_setEnabled_,0);
    _objc_msgSend(self->_loopPopUpButton,sel_setEnabled_,0);
    _objc_msgSend(self->_playCountStepper,sel_setEnabled_,0);
    pvVar5 = self->_playCountTextField;
    iVar14 = 0;
    goto LAB_001aa9d4;
  }
  pvVar5 = _objc_msgSend(self,sel_class);
  _objc_msgSend(self,sel_validateMoviePlaybackAttributes);
  if (self->_selectedRowIndexesBeforeClosePane != (id)0x0) {
    pvVar6 = _objc_msgSend(self->_playbackItemsTableView,sel_dataSource);
    if (pvVar6 != (id)0x0) {
      pvVar7 = _objc_msgSend(self->_selectedRowIndexesBeforeClosePane,sel_retain);
      _objc_msgSend(self->_selectedRowIndexesBeforeClosePane,sel_release);
      self->_selectedRowIndexesBeforeClosePane = (id)0x0;
      _objc_msgSend(self->_playbackItemsTableView,sel_selectRowIndexes_byExtendingSelection_,pvVar7,
                    0);
      pvVar6 = self->_playbackItemsTableView;
      pvVar8 = _objc_msgSend(pvVar7,sel_lastIndex);
      _objc_msgSend(pvVar6,sel_scrollRowToVisible_,pvVar8);
      _objc_msgSend(pvVar7,sel_release);
    }
  }
  pvVar6 = _objc_msgSend(self,sel_currentMoviePlaybackAttributes);
  uVar17 = 0;
  pvVar6 = _objc_msgSend(pvVar6,sel_movieObjectForCard_,0);
  pvVar7 = _objc_msgSend(self,sel_currentMovieUIItem);
  pvVar8 = _objc_msgSend(pvVar7,sel_isInAction);
  bVar15 = (char)pvVar8 == '\0';
  pvVar9 = _objc_msgSend(self,sel_currentMoviePlaybackAttributes);
  bVar16 = pvVar9 == (id)0x0;
  bVar1 = bVar16 || bVar15;
  if (bVar1) {
LAB_001aa3f2:
    local_21 = '\0';
  }
  else {
    pvVar9 = _objc_msgSend(pvVar6,sel_hyperMovie,uVar17);
    pvVar9 = _objc_msgSend(pvVar9,sel_hasSound);
    if ((char)pvVar9 == '\0') goto LAB_001aa3f2;
    local_21 = '\x01';
  }
  pvVar9 = _objc_msgSend(pvVar6,sel_isHyperQTVR);
  if ((char)pvVar9 == '\0') {
    pvVar9 = _objc_msgSend(pvVar6,sel_isHyperPanoramaObject);
    if ((char)pvVar9 != '\0') goto LAB_001aa40f;
    bVar3 = false;
  }
  else {
LAB_001aa40f:
    bVar3 = true;
  }
  pvVar9 = _objc_msgSend(pvVar7,sel_isTemporary);
  if ((char)pvVar9 == '\0') {
LAB_001aa49a:
    bVar2 = false;
  }
  else {
    pvVar9 = _objc_msgSend(pvVar6,sel_hyperParent);
    if (pvVar9 == (id)0x0) goto LAB_001aa49a;
    pvVar9 = _objc_msgSend(pvVar6,sel_hyperParent);
    pvVar10 = _objc_msgSend(self,sel_card);
    if (pvVar9 == pvVar10) goto LAB_001aa49a;
    bVar2 = true;
  }
  pvVar9 = _objc_msgSend(self,sel_applier);
  pvVar9 = _objc_msgSend(pvVar9,sel_object);
  pvVar9 = _objc_msgSend(pvVar9,sel_hyperObject);
  pvVar10 = _objc_msgSend(pvVar9,sel_hyperIdentifier);
  pvVar9 = _objc_msgSend(self,sel_stack);
  pvVar9 = _objc_msgSend(pvVar9,sel_hyperObject);
  pvVar11 = _objc_msgSend(pvVar9,sel_hyperIdentifier);
  pvVar9 = self->_showFirstFrameSwitch;
  if (bVar1) {
LAB_001aa55c:
    cVar4 = '\0';
  }
  else {
    pvVar7 = _objc_msgSend(pvVar7,sel_isTemporary);
    if (((char)pvVar7 == '\0' && !bVar2) || (pvVar10 == pvVar11)) goto LAB_001aa55c;
    cVar4 = '\x01';
  }
  _objc_msgSend(pvVar9,sel_setEnabled_,(int)cVar4);
  _objc_msgSend(self->_playOverObjectsSwitch,sel_setEnabled_,(int)(!bVar16 && !bVar15));
  uVar13 = (uint)(!bVar3 && (!bVar16 && !bVar15));
  _objc_msgSend(self->_useMovieControllerSwitch,sel_setEnabled_,
                (uint)(!bVar2 && (!bVar16 && !bVar15)));
  _objc_msgSend(self->_eraseWhenDoneSwitch,sel_setEnabled_,uVar13);
  iVar14 = (int)local_21;
  _objc_msgSend(self->_fadeOutSwitchButton,sel_setEnabled_,iVar14);
  pvVar7 = self->_addMovieButton;
  pvVar9 = _objc_msgSend(self,sel_isPlaying);
  uVar12 = (uint)((char)pvVar9 == '\0');
  _objc_msgSend(pvVar7,sel_setEnabled_,uVar12);
  pvVar7 = self->_moviePositionButton;
  if (bVar1) {
LAB_001aa68d:
    cVar4 = '\0';
  }
  else {
    pvVar6 = _objc_msgSend(pvVar6,sel_hyperParent,uVar12);
    if ((pvVar6 != (id)0x0) || (bVar2)) goto LAB_001aa68d;
    cVar4 = '\x01';
  }
  _objc_msgSend(pvVar7,sel_setEnabled_,(int)cVar4);
  _objc_msgSend(self->_volumeSlider,sel_setEnabled_,iVar14);
  _objc_msgSend(self->_minVolumeButton,sel_setEnabled_,iVar14);
  _objc_msgSend(self->_maxVolumeButton,sel_setEnabled_,iVar14);
  _objc_msgSend(self->_rangeControl,sel_setEnabled_,(int)(!bVar16 && !bVar15));
  pvVar6 = _objc_msgSend(self,sel_currentMoviePlaybackAttributes);
  pvVar6 = _objc_msgSend(pvVar6,sel_playCount);
  _objc_msgSend(self->_loopPopUpButton,sel_setEnabled_,uVar13);
  pvVar7 = (id)(uint)((!bVar16 && !bVar15) && pvVar6 != (id)0x0);
  _objc_msgSend(self->_loopPopUpButton,sel_selectItemWithTag_,(uint)(pvVar6 == (id)0x0));
  _objc_msgSend(self->_playCountStepper,sel_setEnabled_,pvVar7);
  _objc_msgSend(self->_playCountTextField,sel_setEnabled_,pvVar7);
  if (pvVar6 != (id)0x0) {
    pvVar6 = self->_playCountStepper;
    pvVar7 = _objc_msgSend(self,sel_currentMoviePlaybackAttributes,pvVar7);
    pvVar7 = _objc_msgSend(pvVar7,sel_playCount);
    _objc_msgSend(pvVar6,sel_setIntValue_,pvVar7);
    pvVar6 = self->_playCountTextField;
    pvVar7 = _objc_msgSend(self,sel_currentMoviePlaybackAttributes);
    pvVar7 = _objc_msgSend(pvVar7,sel_playCount);
    _objc_msgSend(pvVar6,sel_setIntValue_,pvVar7);
  }
  pvVar9 = _objc_msgSend(self,sel_isPlaying,pvVar7);
  pvVar6 = self->_playMovieButton;
  if ((char)pvVar9 == '\0') {
    pvVar7 = _objc_msgSend(pvVar5,sel_playButtonImage,pvVar7);
    _objc_msgSend(pvVar6,sel_setImage_,pvVar7);
    pvVar6 = self->_playMovieButton;
    pvVar7 = _objc_msgSend(pvVar5,sel_playButtonAquaImage);
    _objc_msgSend(pvVar6,sel_setAquaAlternateImage_,pvVar7);
    pvVar6 = self->_playMovieButton;
    op = sel_playButtonGraphiteImage;
  }
  else {
    pvVar7 = _objc_msgSend(pvVar5,sel_stopButtonImage,pvVar7);
    _objc_msgSend(pvVar6,sel_setImage_,pvVar7);
    pvVar6 = self->_playMovieButton;
    pvVar7 = _objc_msgSend(pvVar5,sel_stopButtonAquaImage);
    _objc_msgSend(pvVar6,sel_setAquaAlternateImage_,pvVar7);
    pvVar6 = self->_playMovieButton;
    op = sel_stopButtonGraphiteImage;
  }
  pvVar5 = _objc_msgSend(pvVar5,op,pvVar7);
  _objc_msgSend(pvVar6,sel_setGraphiteAlternateImage_,pvVar5);
  pvVar5 = self->_playMovieButton;
  pvVar6 = _objc_msgSend(self,sel_currentMoviePlaybackAttributes);
  if (pvVar6 == (id)0x0) {
LAB_001aa9be:
    cVar4 = '\0';
  }
  else {
    if (bVar3 || (char)pvVar8 == '\0') goto LAB_001aa9be;
    cVar4 = '\x01';
  }
  iVar14 = (int)cVar4;
LAB_001aa9d4:
  _objc_msgSend(pvVar5,sel_setEnabled_,iVar14);
  return;
}

*/
- (void)validateUserInterfaceInMovieOptions
{
    if ([self currentMoviePlaybackAttributes] == nil) {
        [_addMovieButton setEnabled:YES];
        [_moviePositionButton setEnabled:NO];
        [_volumeSlider setEnabled:NO];
        [_minVolumeButton setEnabled:NO];
        [_maxVolumeButton setEnabled:NO];
        [_showFirstFrameSwitch setEnabled:NO];
        [_playOverObjectsSwitch setEnabled:NO];
        [_useMovieControllerSwitch setEnabled:NO];
        [_eraseWhenDoneSwitch setEnabled:NO];
        [_fadeOutSwitchButton setEnabled:NO];
        [_rangeControl setEnabled:NO];
        [_playMovieButton setEnabled:NO];
        [_loopPopUpButton setEnabled:NO];
        [_playCountStepper setEnabled:NO];
        [_playCountTextField setEnabled:NO];
        return;
    }
    [self validateMoviePlaybackAttributes];
    if (_selectedRowIndexesBeforeClosePane != nil && [_playbackItemsTableView dataSource] != nil) {
        // Restore the selection the table had before another pane was pushed.
        NSIndexSet *indexes = [_selectedRowIndexesBeforeClosePane retain];
        [_selectedRowIndexesBeforeClosePane release];
        _selectedRowIndexesBeforeClosePane = nil;
        [_playbackItemsTableView selectRowIndexes:indexes byExtendingSelection:NO];
        [_playbackItemsTableView scrollRowToVisible:[indexes lastIndex]];
        [indexes release];
    }
    id movie = [[self currentMoviePlaybackAttributes] movieObjectForCard:nil];
    id item = [self currentMovieUIItem];
    BOOL isInAction = [item isInAction];
    BOOL isUsable = [self currentMoviePlaybackAttributes] != nil && isInAction;
    BOOL hasSound = isUsable && [[movie hyperMovie] hasSound];
    BOOL isVR = [movie isHyperQTVR] || [movie isHyperPanoramaObject];
    // A temporary item whose movie lives on another card.
    BOOL isOnAnotherCard = [item isTemporary] && [movie hyperParent] != nil && [movie hyperParent] != [self card];
    NSUInteger objectIdentifier = [[[[self applier] object] hyperObject] hyperIdentifier];
    NSUInteger stackIdentifier = [[[self stack] hyperObject] hyperIdentifier];
    [_showFirstFrameSwitch setEnabled:isUsable && ([item isTemporary] || isOnAnotherCard) && objectIdentifier != stackIdentifier];
    [_playOverObjectsSwitch setEnabled:isUsable];
    [_useMovieControllerSwitch setEnabled:isUsable && !isOnAnotherCard];
    [_eraseWhenDoneSwitch setEnabled:isUsable && !isVR];
    [_fadeOutSwitchButton setEnabled:hasSound];
    [_addMovieButton setEnabled:![self isPlaying]];
    [_moviePositionButton setEnabled:isUsable && [movie hyperParent] == nil && !isOnAnotherCard];
    [_volumeSlider setEnabled:hasSound];
    [_minVolumeButton setEnabled:hasSound];
    [_maxVolumeButton setEnabled:hasSound];
    [_rangeControl setEnabled:isUsable];
    NSUInteger playCount = [[self currentMoviePlaybackAttributes] playCount];
    [_loopPopUpButton setEnabled:isUsable && !isVR];
    // Tag 1 is "loop forever" (play count 0).
    [_loopPopUpButton selectItemWithTag:playCount == 0];
    [_playCountStepper setEnabled:isUsable && playCount != 0];
    [_playCountTextField setEnabled:isUsable && playCount != 0];
    if (playCount != 0) {
        [_playCountStepper setIntValue:(int)[[self currentMoviePlaybackAttributes] playCount]];
        [_playCountTextField setIntValue:(int)[[self currentMoviePlaybackAttributes] playCount]];
    }
    if ([self isPlaying]) {
        [_playMovieButton setImage:[[self class] stopButtonImage]];
        [_playMovieButton setAquaAlternateImage:[[self class] stopButtonAquaImage]];
        [_playMovieButton setGraphiteAlternateImage:[[self class] stopButtonGraphiteImage]];
    } else {
        [_playMovieButton setImage:[[self class] playButtonImage]];
        [_playMovieButton setAquaAlternateImage:[[self class] playButtonAquaImage]];
        [_playMovieButton setGraphiteAlternateImage:[[self class] playButtonGraphiteImage]];
    }
    [_playMovieButton setEnabled:[self currentMoviePlaybackAttributes] != nil && !isVR && isInAction];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001aabc4 @ 001aabc4, 941 bytes * /

void FUN_001aabc4(HSPlayMovieActionAssistantPane *self,SEL _cmd)

{
  HSPopUpButton *self_00;
  id pvVar1;
  id pvVar2;
  undefined4 *puVar3;
  longdouble lVar4;
  double dVar5;
  undefined1 local_24 [20];
  
  puVar3 = (undefined4 *)&stack0xffffffc4;
  pvVar1 = _objc_msgSend(self,sel_currentMoviePlaybackAttributes);
  if (pvVar1 != (id)0x0) {
    pvVar1 = self->_showFirstFrameSwitch;
    pvVar2 = _objc_msgSend(self,sel_currentMoviePlaybackAttributes);
    _objc_msgSend(pvVar2,sel_showFirstFrame);
    _objc_msgSend(pvVar1,sel_setState_);
    pvVar1 = self->_playOverObjectsSwitch;
    pvVar2 = _objc_msgSend(self,sel_currentMoviePlaybackAttributes);
    _objc_msgSend(pvVar2,sel_playOverObjects);
    _objc_msgSend(pvVar1,sel_setState_);
    self_00 = self->_loopPopUpButton;
    pvVar1 = _objc_msgSend(self,sel_currentMoviePlaybackAttributes);
    _objc_msgSend(pvVar1,sel_playCount);
    _objc_msgSend(self_00,sel_selectItemWithTag_);
    pvVar1 = self->_useMovieControllerSwitch;
    pvVar2 = _objc_msgSend(self,sel_currentMoviePlaybackAttributes);
    _objc_msgSend(pvVar2,sel_useMovieController);
    _objc_msgSend(pvVar1,sel_setState_);
    pvVar1 = self->_eraseWhenDoneSwitch;
    pvVar2 = _objc_msgSend(self,sel_currentMoviePlaybackAttributes);
    _objc_msgSend(pvVar2,sel_eraseWhenDone);
    _objc_msgSend(pvVar1,sel_setState_);
    pvVar1 = self->_fadeOutSwitchButton;
    pvVar2 = _objc_msgSend(self,sel_currentMoviePlaybackAttributes);
    _objc_msgSend_fpret(pvVar2,sel_soundFadeOutTime);
    _objc_msgSend(pvVar1,sel_setState_);
    pvVar1 = _objc_msgSend(self,sel_currentMoviePlaybackAttributes);
    pvVar1 = _objc_msgSend(pvVar1,sel_movieObjectForCard_);
    if (pvVar1 == (id)0x0) {
      _objc_msgSend(self->_rangeControl,sel_setDuration_);
      _objc_msgSend(self->_rangeControl,sel_setStartTime_);
      _objc_msgSend(self->_rangeControl,sel_setFinishTime_);
    }
    else {
      pvVar2 = _objc_msgSend(self,sel_currentMoviePlaybackAttributes);
      _objc_msgSend_stret(local_24,pvVar2,sel_playRange);
      puVar3 = (undefined4 *)&stack0xffffffc0;
      pvVar2 = self->_rangeControl;
      _objc_msgSend_fpret(pvVar1,sel_hyperDuration);
      _objc_msgSend(pvVar2,sel_setDuration_);
      _objc_msgSend(self->_rangeControl,sel_setStartTime_);
      _objc_msgSend(self->_rangeControl,sel_setFinishTime_);
    }
    pvVar1 = self->_volumeSlider;
    puVar3[1] = sel_currentMoviePlaybackAttributes;
    *puVar3 = self;
    puVar3[-1] = 0x1aaf2f;
    pvVar2 = _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
    puVar3[1] = sel_volume;
    *puVar3 = pvVar2;
    puVar3[-1] = 0x1aaf41;
    dVar5 = _objc_msgSend_fpret((id)*puVar3,(SEL)puVar3[1]);
    pvVar2 = self->_volumeSlider;
    puVar3[1] = (float)dVar5;
    *puVar3 = pvVar2;
    puVar3[-1] = 0x1aaf53;
    lVar4 = (longdouble)_HSLinearValueForSliderFromNonLinear();
    puVar3[2] = (float)lVar4;
    puVar3[1] = sel_setFloatValue_;
    *puVar3 = pvVar1;
    puVar3[-1] = 0x1aaf69;
    _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
  }
  return;
}

*/
- (void)validateMoviePlaybackAttributes
{
    id attributes = [self currentMoviePlaybackAttributes];
    if (attributes == nil) {
        return;
    }
    [_showFirstFrameSwitch setState:[attributes showFirstFrame] ? NSControlStateValueOn : NSControlStateValueOff];
    [_playOverObjectsSwitch setState:[attributes playOverObjects] ? NSControlStateValueOn : NSControlStateValueOff];
    [_loopPopUpButton selectItemWithTag:[attributes playCount] == 0];
    [_useMovieControllerSwitch setState:[attributes useMovieController] ? NSControlStateValueOn : NSControlStateValueOff];
    [_eraseWhenDoneSwitch setState:[attributes eraseWhenDone] ? NSControlStateValueOn : NSControlStateValueOff];
    [_fadeOutSwitchButton setState:[attributes soundFadeOutTime] > 0.0 ? NSControlStateValueOn : NSControlStateValueOff];
    id movie = [attributes movieObjectForCard:nil];
    if (movie == nil) {
        [_rangeControl setDuration:0.0];
        [_rangeControl setStartTime:0.0];
        [_rangeControl setFinishTime:0.0];
    } else {
        struct HSTimeRange range = [attributes playRange];
        [_rangeControl setDuration:[movie hyperDuration]];
        [_rangeControl setStartTime:range.location];
        [_rangeControl setFinishTime:range.location + range.length];
    }
    [_volumeSlider setFloatValue:HSLinearValueForSliderFromNonLinear(_volumeSlider, [(id<HSMoviePlaybackAttributes>)attributes volume])];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001aaf71 @ 001aaf71, 1194 bytes * /

void FUN_001aaf71(HSPlayMovieActionAssistantPane *self,SEL _cmd)

{
  bool bVar1;
  bool bVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  uint uVar7;
  SEL op;
  undefined4 uVar8;
  
  pvVar3 = _objc_msgSend(self,sel_currentLiveVideoPlaybackAttributes);
  if (pvVar3 == (id)0x0) {
    _objc_msgSend(self->_playLiveVideoButton,sel_setEnabled_,0);
    _objc_msgSend(self->_liveVideoPositionButton,sel_setEnabled_,0);
    _objc_msgSend(self->_addLiveVideoButton,sel_setEnabled_,1);
    _objc_msgSend(self->_liveVideoMirrorModeSwitchButton,sel_setEnabled_,0);
    pvVar3 = self->_liveVideoPlayOverObjectsSwitchButton;
    uVar7 = 0;
    goto LAB_001ab40e;
  }
  pvVar3 = _objc_msgSend(self,sel_class);
  _objc_msgSend(self,sel_validateLiveVideoPlaybackAttributes);
  _objc_msgSend(self,sel_validateSelectionInDevicesPopUpButton);
  if (self->_selectedRowIndexesBeforeClosePane != (id)0x0) {
    pvVar4 = _objc_msgSend(self->_playbackItemsTableView,sel_dataSource);
    if (pvVar4 != (id)0x0) {
      pvVar5 = _objc_msgSend(self->_selectedRowIndexesBeforeClosePane,sel_retain);
      _objc_msgSend(self->_selectedRowIndexesBeforeClosePane,sel_release);
      self->_selectedRowIndexesBeforeClosePane = (id)0x0;
      _objc_msgSend(self->_playbackItemsTableView,sel_selectRowIndexes_byExtendingSelection_,pvVar5,
                    0);
      pvVar4 = self->_playbackItemsTableView;
      pvVar6 = _objc_msgSend(pvVar5,sel_lastIndex);
      _objc_msgSend(pvVar4,sel_scrollRowToVisible_,pvVar6);
      _objc_msgSend(pvVar5,sel_release);
    }
  }
  pvVar4 = _objc_msgSend(self,sel_currentLiveVideoUIItem);
  pvVar5 = _objc_msgSend(self,sel_currentLiveVideoPlaybackAttributes);
  uVar8 = 0;
  pvVar5 = _objc_msgSend(pvVar5,sel_liveObjectForCard_,0);
  pvVar6 = _objc_msgSend(self,sel_currentLiveVideoPlaybackAttributes);
  if (pvVar6 == (id)0x0) {
LAB_001ab11f:
    bVar2 = false;
  }
  else {
    pvVar6 = _objc_msgSend(pvVar4,sel_isInAction,uVar8);
    if ((char)pvVar6 == '\0') goto LAB_001ab11f;
    bVar2 = true;
  }
  pvVar4 = _objc_msgSend(pvVar4,sel_isTemporary,uVar8);
  if ((char)pvVar4 == '\0') {
LAB_001ab180:
    bVar1 = false;
  }
  else {
    pvVar4 = _objc_msgSend(pvVar5,sel_hyperParent);
    if (pvVar4 == (id)0x0) goto LAB_001ab180;
    pvVar4 = _objc_msgSend(pvVar5,sel_hyperParent);
    pvVar5 = _objc_msgSend(self,sel_card);
    if (pvVar4 == pvVar5) goto LAB_001ab180;
    bVar1 = true;
  }
  pvVar5 = _objc_msgSend(self,sel_isPlaying);
  pvVar4 = self->_playLiveVideoButton;
  if ((char)pvVar5 == '\0') {
    pvVar5 = _objc_msgSend(pvVar3,sel_playButtonImage);
    _objc_msgSend(pvVar4,sel_setImage_,pvVar5);
    pvVar4 = self->_playLiveVideoButton;
    pvVar5 = _objc_msgSend(pvVar3,sel_playButtonAquaImage);
    _objc_msgSend(pvVar4,sel_setAquaAlternateImage_,pvVar5);
    pvVar4 = self->_playLiveVideoButton;
    op = sel_playButtonGraphiteImage;
  }
  else {
    pvVar5 = _objc_msgSend(pvVar3,sel_stopButtonImage);
    _objc_msgSend(pvVar4,sel_setImage_,pvVar5);
    pvVar4 = self->_playLiveVideoButton;
    pvVar5 = _objc_msgSend(pvVar3,sel_stopButtonAquaImage);
    _objc_msgSend(pvVar4,sel_setAquaAlternateImage_,pvVar5);
    pvVar4 = self->_playLiveVideoButton;
    op = sel_stopButtonGraphiteImage;
  }
  pvVar3 = _objc_msgSend(pvVar3,op,pvVar5);
  _objc_msgSend(pvVar4,sel_setGraphiteAlternateImage_,pvVar3);
  pvVar3 = self->_liveVideoPositionButton;
  pvVar4 = _objc_msgSend(self,sel_isPlaying);
  _objc_msgSend(pvVar3,sel_setEnabled_,(uint)((char)pvVar4 == '\0' && !bVar1));
  pvVar3 = self->_addLiveVideoButton;
  pvVar4 = _objc_msgSend(self,sel_isPlaying);
  uVar7 = (uint)(bVar2 && !bVar1);
  _objc_msgSend(pvVar3,sel_setEnabled_,(uint)((char)pvVar4 == '\0'));
  _objc_msgSend(self->_liveVideoMirrorModeSwitchButton,sel_setEnabled_,uVar7);
  pvVar3 = self->_liveVideoPlayOverObjectsSwitchButton;
LAB_001ab40e:
  _objc_msgSend(pvVar3,sel_setEnabled_,uVar7);
  return;
}

*/
- (void)validateUserInterfaceInLiveVideoOptions
{
    if ([self currentLiveVideoPlaybackAttributes] == nil) {
        [_playLiveVideoButton setEnabled:NO];
        [_liveVideoPositionButton setEnabled:NO];
        [_addLiveVideoButton setEnabled:YES];
        [_liveVideoMirrorModeSwitchButton setEnabled:NO];
        [_liveVideoPlayOverObjectsSwitchButton setEnabled:NO];
        return;
    }
    [self validateLiveVideoPlaybackAttributes];
    [self validateSelectionInDevicesPopUpButton];
    if (_selectedRowIndexesBeforeClosePane != nil && [_playbackItemsTableView dataSource] != nil) {
        // Restore the selection the table had before another pane was pushed.
        NSIndexSet *indexes = [_selectedRowIndexesBeforeClosePane retain];
        [_selectedRowIndexesBeforeClosePane release];
        _selectedRowIndexesBeforeClosePane = nil;
        [_playbackItemsTableView selectRowIndexes:indexes byExtendingSelection:NO];
        [_playbackItemsTableView scrollRowToVisible:[indexes lastIndex]];
        [indexes release];
    }
    id item = [self currentLiveVideoUIItem];
    id liveObject = [[self currentLiveVideoPlaybackAttributes] liveObjectForCard:nil];
    BOOL isInAction = [self currentLiveVideoPlaybackAttributes] != nil && [item isInAction];
    BOOL isOnAnotherCard = [item isTemporary] && [liveObject hyperParent] != nil && [liveObject hyperParent] != [self card];
    if ([self isPlaying]) {
        [_playLiveVideoButton setImage:[[self class] stopButtonImage]];
        [_playLiveVideoButton setAquaAlternateImage:[[self class] stopButtonAquaImage]];
        [_playLiveVideoButton setGraphiteAlternateImage:[[self class] stopButtonGraphiteImage]];
    } else {
        [_playLiveVideoButton setImage:[[self class] playButtonImage]];
        [_playLiveVideoButton setAquaAlternateImage:[[self class] playButtonAquaImage]];
        [_playLiveVideoButton setGraphiteAlternateImage:[[self class] playButtonGraphiteImage]];
    }
    [_liveVideoPositionButton setEnabled:![self isPlaying] && !isOnAnotherCard];
    [_addLiveVideoButton setEnabled:![self isPlaying]];
    [_liveVideoMirrorModeSwitchButton setEnabled:isInAction && !isOnAnotherCard];
    [_liveVideoPlayOverObjectsSwitchButton setEnabled:isInAction && !isOnAnotherCard];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ab41b @ 001ab41b, 910 bytes * /

void FUN_001ab41b(HSPlayMovieActionAssistantPane *self,SEL _cmd)

{
  bool bVar1;
  bool bVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  undefined *puVar6;
  undefined *puVar7;
  id pvVar8;
  uint uVar9;
  undefined *puVar10;
  byte local_14;
  
  pvVar3 = _objc_msgSend(self,sel_currentLiveVideoPlaybackAttributes);
  if (pvVar3 == (id)0x0) {
    return;
  }
  pvVar3 = _objc_msgSend(self,sel_currentLiveVideoUIItem);
  pvVar4 = _objc_msgSend(self,sel_currentLiveVideoPlaybackAttributes);
  if ((pvVar4 == (id)0x0) || (pvVar3 == (id)0x0)) {
    _objc_msgSend(self->_playLiveVideoButton,sel_setEnabled_,0);
    _objc_msgSend(self->_availableCamerasPopUpButton,sel_setEnabled_,0);
    pvVar3 = self->_liveVideoPlayOverObjectsSwitchButton;
    uVar9 = 0;
    goto LAB_001ab73c;
  }
  pvVar4 = _objc_msgSend(self,sel_currentLiveVideoPlaybackAttributes);
  puVar10 = (undefined *)0x0;
  pvVar4 = _objc_msgSend(pvVar4,sel_liveObjectForCard_,0);
  if (pvVar4 == (id)0x0) {
LAB_001ab5d7:
    bVar2 = false;
  }
  else {
    puVar6 = &DAT_0037cb6c;
    pvVar5 = _objc_msgSend(pvVar4,sel_queryHyperInterface_,&DAT_0037cb6c);
    if (pvVar5 != (id)0x0) {
      pvVar8 = self->_liveVideoMirrorModeSwitchButton;
      pvVar5 = _objc_msgSend(pvVar5,sel_isFlippedHorizontally,puVar6);
      puVar6 = (undefined *)(uint)((char)pvVar5 != '\0');
      _objc_msgSend(pvVar8,sel_setState_,puVar6);
    }
    puVar10 = _objc_msgSend(pvVar4,sel_hyperDeviceIndex,puVar6);
    puVar7 = _objc_msgSend(self->_captureDeviceList,sel_captureDeviceCount);
    if (puVar10 < puVar7) {
      pvVar5 = _objc_msgSend(self->_captureDeviceList,sel_captureDeviceAtIndex_,puVar10);
    }
    else {
      pvVar5 = (id)0x0;
      puVar10 = puVar6;
    }
    pvVar8 = _objc_msgSend(pvVar5,sel_isConnected,puVar10);
    if (((char)pvVar8 == '\0') ||
       (pvVar8 = _objc_msgSend(pvVar5,sel_QTE_isInUseByAnotherApplication,puVar10),
       (char)pvVar8 != '\0')) goto LAB_001ab5d7;
    puVar10 = *(undefined **)PTR_00336400;
    pvVar5 = _objc_msgSend(pvVar5,sel_attributeForKey_,puVar10);
    pvVar5 = _objc_msgSend(pvVar5,sel_boolValue);
    if ((char)pvVar5 != '\0') goto LAB_001ab5d7;
    bVar2 = true;
  }
  pvVar5 = self->_liveVideoPlayOverObjectsSwitchButton;
  pvVar8 = _objc_msgSend(self,sel_currentLiveVideoPlaybackAttributes,puVar10);
  pvVar8 = _objc_msgSend(pvVar8,sel_playOverObjects);
  uVar9 = (uint)((char)pvVar8 != '\0');
  _objc_msgSend(pvVar5,sel_setState_,uVar9);
  pvVar5 = _objc_msgSend(pvVar3,sel_isInAction);
  if ((((char)pvVar5 == '\0') ||
      (pvVar8 = _objc_msgSend(self,sel_isPlaying,uVar9), (char)pvVar8 != '\0')) ||
     (pvVar8 = _objc_msgSend(pvVar3,sel_isEnabled,uVar9), (char)pvVar8 == '\0')) {
    bVar1 = true;
  }
  else {
    bVar1 = false;
  }
  pvVar3 = _objc_msgSend(pvVar3,sel_isTemporary,uVar9);
  if (((char)pvVar3 == '\0') || (pvVar3 = _objc_msgSend(pvVar4,sel_hyperParent), pvVar3 == (id)0x0))
  {
LAB_001ab6e0:
    local_14 = 1;
  }
  else {
    pvVar3 = _objc_msgSend(pvVar4,sel_hyperParent);
    pvVar4 = _objc_msgSend(self,sel_card);
    if (pvVar3 == pvVar4) goto LAB_001ab6e0;
    local_14 = 0;
  }
  uVar9 = (uint)((!bVar1 && bVar2) & local_14);
  _objc_msgSend(self->_playLiveVideoButton,sel_setEnabled_,(uint)(bVar2 && (char)pvVar5 != '\0'));
  pvVar3 = self->_availableCamerasPopUpButton;
LAB_001ab73c:
  _objc_msgSend(pvVar3,sel_setEnabled_,uVar9);
  return;
}

*/
- (void)validateLiveVideoPlaybackAttributes
{
    if ([self currentLiveVideoPlaybackAttributes] == nil) {
        return;
    }
    id item = [self currentLiveVideoUIItem];
    if ([self currentLiveVideoPlaybackAttributes] == nil || item == nil) {
        [_playLiveVideoButton setEnabled:NO];
        [_availableCamerasPopUpButton setEnabled:NO];
        [_liveVideoPlayOverObjectsSwitchButton setEnabled:NO];
        return;
    }
    id liveObject = [[self currentLiveVideoPlaybackAttributes] liveObjectForCard:nil];
    BOOL isDeviceUsable = NO;
    if (liveObject != nil) {
        id geometry = [liveObject queryHyperInterface:@protocol(HSGeometryAttributes)];
        if (geometry != nil) {
            [_liveVideoMirrorModeSwitchButton setState:[geometry isFlippedHorizontally] ? NSControlStateValueOn : NSControlStateValueOff];
        }
        NSUInteger deviceIndex = [liveObject hyperDeviceIndex];
        QTCaptureDevice *device = nil;
        if (deviceIndex < [_captureDeviceList captureDeviceCount]) {
            device = [_captureDeviceList captureDeviceAtIndex:deviceIndex];
        }
        isDeviceUsable = [device isConnected]
            && ![device QTE_isInUseByAnotherApplication]
            && ![[device attributeForKey:QTCaptureDeviceSuspendedAttribute] boolValue];
    }
    [_liveVideoPlayOverObjectsSwitchButton setState:[[self currentLiveVideoPlaybackAttributes] playOverObjects] ? NSControlStateValueOn : NSControlStateValueOff];
    BOOL isInAction = [item isInAction];
    BOOL isLocked = !isInAction || [self isPlaying] || ![item isEnabled];
    BOOL isOnAnotherCard = [item isTemporary] && [liveObject hyperParent] != nil && [liveObject hyperParent] != [self card];
    [_playLiveVideoButton setEnabled:isDeviceUsable && isInAction];
    [_availableCamerasPopUpButton setEnabled:!isLocked && isDeviceUsable && !isOnAnotherCard];
}

- (void)validateSelectionInDevicesPopUpButton
{
    NSInteger pvVar1_3;

    if ([self currentLiveVideoPlaybackAttributes] != nil) {
        pvVar1_3 = [[self currentLiveVideoPlaybackAttributes] liveVideoDeviceIndex];
        if ([_captureDeviceList captureDeviceCount] <= pvVar1_3) {
            [[self currentLiveVideoPlaybackAttributes] setLiveVideoDeviceIndex:0];
            pvVar1_3 = 0;
        }
        [_availableCamerasPopUpButton selectItemAtIndex:pvVar1_3];
        [self HSPlayMovieActionAssistantPane_updateSelectedCaptureDevice:[[_availableCamerasPopUpButton selectedItem] representedObject]];
    }
}

- (id)helpTopicKey
{
    return @"HSPlayMovie";
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ab8a9 @ 001ab8a9, 444 bytes * /

void FUN_001ab8a9(HSPlayMovieActionAssistantPane *self,SEL _cmd,id paneDidOK)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  undefined4 uVar5;
  undefined4 uVar6;
  HSPlayMovieActionAssistantPane *local_1c;
  undefined *local_18;
  
  pvVar1 = _objc_msgSend(self->_playCountTextField,sel_stringValue);
  self_00 = cls_NSString;
  pvVar2 = _objc_msgSend(self->_playCountTextField,sel_intValue);
  pvVar3 = _objc_msgSend(self_00,sel_stringWithFormat_,&cfstr__d,pvVar2);
  pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_,pvVar3);
  pvVar4 = _objc_msgSend(self->_loopPopUpButton,sel_selectedItem);
  pvVar4 = _objc_msgSend(pvVar4,sel_tag);
  if (pvVar4 == (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_currentMoviePlaybackAttributes,pvVar3,pvVar2);
    if ((pvVar2 != (id)0x0) && ((char)pvVar1 != '\0')) {
      pvVar3 = self->_playCountTextField;
      _objc_msgSend(self,sel_playCountChanged_,pvVar3);
    }
  }
  pvVar3 = _objc_msgSend(self,sel_objectAssistantNavigationController,pvVar3);
  uVar6 = *(undefined4 *)PTR_PTR_003364f4;
  uVar5 = uVar6;
  pvVar1 = _objc_msgSend(pvVar3,sel_viewControllersForPaneIdentifier_,uVar6);
  pvVar1 = _objc_msgSend(pvVar1,sel_count);
  if (pvVar1 != (id)0x0) {
    _objc_msgSend(pvVar3,sel_removeAllViewControllersWithIdentifier_,uVar6);
    uVar5 = uVar6;
  }
  _objc_msgSend(self,sel_stopObservingChangesOfActionAttributes,uVar5);
  _objc_msgSend(self,sel_cleanPlaybackUIItems);
  _objc_msgSend(self,sel_cleanUnUsedPlaybackItemsIfNeeded);
  local_1c = self;
  local_18 = PTR_s_HSActionAssistantPane_003534b0;
  _objc_msgSendSuper(&local_1c,sel_paneDidOK_,paneDidOK);
  return;
}

*/
- (void)paneDidOK:(id)aOK
{
    // Commit a play count typed but not yet confirmed with Return.
    BOOL isNumber = [[_playCountTextField stringValue] isEqualToString:[NSString stringWithFormat:@"%d", [_playCountTextField intValue]]];
    if ([[_loopPopUpButton selectedItem] tag] == 0 && [self currentMoviePlaybackAttributes] != nil && isNumber) {
        [self playCountChanged:_playCountTextField];
    }
    id navigation = [self objectAssistantNavigationController];
    if ([[navigation viewControllersForPaneIdentifier:HSPickMovieSourcePane_RemoveIfOkIdentifier] count] != 0) {
        [navigation removeAllViewControllersWithIdentifier:HSPickMovieSourcePane_RemoveIfOkIdentifier];
    }
    [self stopObservingChangesOfActionAttributes];
    [self cleanPlaybackUIItems];
    [self cleanUnUsedPlaybackItemsIfNeeded];
    [super paneDidOK:aOK];
}

- (void)paneDidCancel:(id)aCancel
{
    [self stopObservingChangesOfActionAttributes];
    [self cleanPlaybackUIItems];
    [super paneDidCancel:aCancel];
}

- (void)viewDidDisappear:(BOOL)aDisappear
{
    [self removeActionIfNeeded];
    [super viewDidDisappear:aDisappear];
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    id pvVar1_4;

    pvVar1_4 = [[[[self stack] document] currentWindowController] cardView];
    [pvVar1_4 setDragHelperDelegate:nil];
    if ([self isPlaying]) {
        [self stopPlaying];
    }
    [self stopObservingChangesOfActionAttributes];
    [self HSPlayMovieActionAssistantPane_updateSelectedCaptureDevice:nil];
    if (_captureDeviceList != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSCaptureDeviceListDidUpdateNotification" object:_captureDeviceList];
        [_captureDeviceList detachMenu:[_availableCamerasPopUpButton menu]];
        [_captureDeviceList release];
        _captureDeviceList = nil;
    }
    [_selectedRowIndexesBeforeClosePane release];
    _selectedRowIndexesBeforeClosePane = [[_playbackItemsTableView selectedRowIndexes] retain];
    [_playbackItemsTableView setDataSource:0];
    [_playbackItemsTableView setDelegate:0];
    [self cleanPlaybackUIItems];
    [super viewWillDisappear:aDisappear];
}

- (void)viewDidAppear:(BOOL)aAppear
{
    [super viewDidAppear:aAppear];
    [[self navigationPaneSwitcher] validateUserInterface];
    if (_didAddPlaybackItem != NO) {
        _didAddPlaybackItem = NO;
        [self choosePosition:nil];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001abddc @ 001abddc, 918 bytes * /

void FUN_001abddc(HSPlayMovieActionAssistantPane *self,SEL _cmd,BOOL viewWillAppear)

{
  HSPopUpButton *self_00;
  undefined *self_01;
  id pvVar1;
  HSPlayMovieActionAssistantPane *pHVar2;
  id pvVar3;
  HSPlayMovieActionAssistantPane *pHVar4;
  undefined4 uVar5;
  undefined4 uVar6;
  HSPlayMovieActionAssistantPane *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSActionAssistantPane_003534b0;
  _objc_msgSendSuper(&local_1c,sel_viewWillAppear_,(int)viewWillAppear);
  _objc_msgSend(self,sel_processMovieObjectToPostAdd);
  pvVar1 = _objc_msgSend(self,sel_stack);
  pvVar1 = _objc_msgSend(pvVar1,sel_document);
  pvVar1 = _objc_msgSend(pvVar1,sel_currentWindowController);
  pvVar1 = _objc_msgSend(pvVar1,sel_cardView);
  pHVar4 = self;
  _objc_msgSend(pvVar1,sel_setDragHelperDelegate_,self);
  _objc_msgSend(self,sel_startObservingChangesOfActionAttributes);
  _objc_msgSend(self->_availableCamerasPopUpButton,sel_removeAllItems);
  pvVar1 = _objc_msgSend(cls_HSSystem,sel_sharedSystem);
  pvVar1 = _objc_msgSend(pvVar1,sel_isQTKitCapturingAvailable);
  if ((char)pvVar1 != '\0') {
    uVar5 = *(undefined4 *)PTR_00336158;
    pHVar4 = *(HSPlayMovieActionAssistantPane **)PTR_0033615c;
    uVar6 = 0;
    pHVar2 = _objc_msgSend(cls_NSArray,sel_arrayWithObjects_,pHVar4,uVar5,0);
    if (pHVar2 != (HSPlayMovieActionAssistantPane *)0x0) {
      pvVar1 = _objc_msgSend(cls_HSCaptureDeviceList,sel_captureDeviceListForMediaTypes_,pHVar2,
                             uVar5,uVar6);
      pvVar1 = _objc_msgSend(pvVar1,sel_retain);
      self->_captureDeviceList = pvVar1;
      pHVar4 = pHVar2;
      if (pvVar1 != (id)0x0) {
        pvVar3 = _objc_msgSend(self->_availableCamerasPopUpButton,sel_menu,pHVar2,uVar5,uVar6);
        _objc_msgSend(pvVar1,sel_attachMenu_,pvVar3);
        pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
        pHVar4 = self;
        _objc_msgSend(pvVar1,sel_addObserver_selector_name_object_,self,
                      sel_HSPlayMovieActionAssistantPane_captureDeviceListDidUpdate_,
                      &cfstr_HSCaptureDeviceListDidUpdateNotification,self->_captureDeviceList);
      }
    }
  }
  if (self->_captureDeviceList == (id)0x0) {
    pvVar1 = _objc_msgSend(self->_availableCamerasPopUpButton,sel_menu,pHVar4);
    self_01 = cls_NSBundle;
    pvVar3 = _objc_msgSend(cls_HSCaptureDeviceList,sel_class);
    pvVar3 = _objc_msgSend(self_01,sel_bundleForClass_,pvVar3);
    pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_Not_Available,
                           &cfstr_empty,&cfstr_HyperPlayerBase);
    pvVar1 = _objc_msgSend(pvVar1,sel_addItemWithTitle_action_keyEquivalent_,pvVar3,0,&cfstr_empty);
    pHVar4 = (HSPlayMovieActionAssistantPane *)0x0;
    _objc_msgSend(pvVar1,sel_setEnabled_,0);
  }
  _objc_msgSend(self,sel_HSPlayMovieActionAssistantPane_availableCamerasPopUpButtonDidUpdate,pHVar4)
  ;
  self->_needSearchAvailableMovies = '\x01';
  self->_needSearchAvailableLiveVideos = '\x01';
  _objc_msgSend(self->_playbackItemsTableView,sel_setDataSource_,self);
  _objc_msgSend(self->_playbackItemsTableView,sel_setDelegate_,self);
  _objc_msgSend(self,sel_updateCurrentPlaybackAttributes);
  _objc_msgSend(self,sel_validateUserInterface);
  self_00 = self->_loopPopUpButton;
  pvVar1 = _objc_msgSend(self_00,sel_selectedItem);
  pvVar1 = _objc_msgSend(pvVar1,sel_toolTip);
  _objc_msgSend(self_00,sel_setToolTip_,pvVar1);
  return;
}

*/
- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [self processMovieObjectToPostAdd];
    [[[[[self stack] document] currentWindowController] cardView] setDragHelperDelegate:self];
    [self startObservingChangesOfActionAttributes];
    [_availableCamerasPopUpButton removeAllItems];
    if ([[HSSystem sharedSystem] isQTKitCapturingAvailable]) {
        NSArray *mediaTypes = [NSArray arrayWithObjects:QTMediaTypeVideo, QTMediaTypeMuxed, nil];
        if (mediaTypes != nil) {
            _captureDeviceList = [[HSCaptureDeviceList captureDeviceListForMediaTypes:mediaTypes] retain];
            if (_captureDeviceList != nil) {
                [_captureDeviceList attachMenu:[_availableCamerasPopUpButton menu]];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSPlayMovieActionAssistantPane_captureDeviceListDidUpdate:) name:@"HSCaptureDeviceListDidUpdateNotification" object:_captureDeviceList];
            }
        }
    }
    if (_captureDeviceList == nil) {
        NSString *title = [[NSBundle bundleForClass:[HSCaptureDeviceList class]] localizedStringForKey:@"Not Available" value:@"" table:@"HyperPlayerBase"];
        [[[_availableCamerasPopUpButton menu] addItemWithTitle:title action:NULL keyEquivalent:@""] setEnabled:NO];
    }
    [self HSPlayMovieActionAssistantPane_availableCamerasPopUpButtonDidUpdate];
    _needSearchAvailableMovies = YES;
    _needSearchAvailableLiveVideos = YES;
    [_playbackItemsTableView setDataSource:self];
    [_playbackItemsTableView setDelegate:self];
    [self updateCurrentPlaybackAttributes];
    [self validateUserInterface];
    [_loopPopUpButton setToolTip:[[_loopPopUpButton selectedItem] toolTip]];
}

- (void)HSPlayMovieActionAssistantPane_availableCamerasPopUpButtonDidUpdate
{
    [self HSPlayMovieActionAssistantPane_updateSelectedCaptureDevice:[[_availableCamerasPopUpButton selectedItem] representedObject]];
}

- (void)HSPlayMovieActionAssistantPane_updateSelectedCaptureDevice:(id)aDevice
{
    if (_selectedCaptureDevice != aDevice) {
        [_selectedCaptureDevice removeObserver:self forKeyPath:@"inUseByAnotherApplication"];
        [_selectedCaptureDevice removeObserver:self forKeyPath:@"suspended"]
        ;
        [aDevice retain];
        [_selectedCaptureDevice release];
        _selectedCaptureDevice = aDevice;
        [aDevice addObserver:self forKeyPath:@"inUseByAnotherApplication" options:0 context:nil];
        [_selectedCaptureDevice addObserver:self forKeyPath:@"suspended" options:0 context:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[_rangeControl cell] setControlSize:2];
    [_rangeControl setLeftKnobClickAction:@selector(leftRangeKnobActivated:)];
    [_rangeControl setRightKnobClickAction:@selector(rightRangeKnobActivated:)];
}

- (id)actionAttributes
{
    return [[self playMovieActionApplier] playMovieActionAttributes];
}

- (id)actionType
{
    return [HSPlayMovieAction actionType];
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

- (id)playMovieActionApplier
{
    return [self applier];
}

- (Class)applierClass
{
    return [HSPlayMovieActionPaneApplier class];
}

- (void)dealloc
{
    HSPlayMovieActionAssistantPane *pHVar3;
    NSNotificationCenter *pvVar1_3;

    [[_observedAttributes attributeObservingController] removeAttributeObserver:self];
    [_observedAttributes release];
    [[_currentMoviePlaybackAttributes attributeObservingController] removeObserver:self selector:@selector(moviePlaybackAttributesDidChange:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSMoviePlaybackAttributes)];
    [_currentMoviePlaybackAttributes release];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    pvVar1_3 = [NSNotificationCenter defaultCenter];
    pHVar3 = self;
    [pvVar1_3 removeObserver:self];
    [_currentOptionsContentView release];
    [_previewPlayableObject release];
    [_previousSelectedNodes release];
    [self cleanPlaybackUIItems];
    if ([_pickMovieSourceAssistantPane pickMovieSourcePaneDelegate] == self) {
        pHVar3 = nil;
        [_pickMovieSourceAssistantPane setPickMovieSourcePaneDelegate:nil];
    }
    [_pickMovieSourceAssistantPane release];
    [_navigationPaneSwitcher setDelegate:0];
    [_navigationPaneSwitcher release];
    [_selectedRowIndexesBeforeClosePane release];
    [_movieDisplayNameFontAttributes release];
    [_movieObjectToPostAdd release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"PlayMovieAssistantPane"];
    return self;
}

@end

