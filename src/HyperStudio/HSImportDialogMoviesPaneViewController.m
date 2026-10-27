#import "HSImportDialogMoviesPaneViewController.h"

static float HSMoviesPaneScale(float aValue)
{
    return aValue != 0 ? fabsf(aValue) : 1.0f;
}

@implementation HSImportDialogMoviesPaneViewController

/* i386 ivar offsets: _paneView=0x1c, _paneAccessoryView=0x20, _searchField=0x24, _imageGrid=0x28, _playButtonImage=0x2c, _playButtonAquaImage=0x30, _playButtonGraphiteImage=0x34, _stopButtonImage=0x38, _stopButtonAquaImage=0x3c, _stopButtonGraphiteImage=0x40, _playButtonCell=0x44, _previewMovieTimer=0x48, _panAngle=0x4c, _panAngleMin=0x50, _panAngleMax=0x54, _currentMovieProgressField=0x58, _playButton=0x5c, _movie=0x60, _playableItemIndex=0x64, _currentFrameImage=0x68, _storedGridSelection=0x6c, _volumeSlider=0x70, _volumeMin=0x74, _volumeMax=0x78, _itemsCountTextField=0x7c, _thumbnailSizeSlider=0x80, _thumbnailSizeMin=0x84, _thumbnailSizeMax=0x88, _filterString=0x8c, _concreteMediaTypesDictionary=0x90, _mainThreadImage=0x94, _invalidMoviePreviewImage=0x98, _browseTableView=0x9c, _itemsFilterPopUp=0xa0 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_001d74c4 @ 001d74c4, 330 bytes * /

void FUN_001d74c4(HSImportDialogMoviesPaneViewController *self,SEL _cmd,
                 id generateMovieThumbnailInMainThread)

{
  int *piVar1;
  id pvVar2;
  id pvVar3;
  int *piVar4;
  int *piVar5;
  int *piVar6;
  int local_14;
  
  piVar1 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_,generateMovieThumbnailInMainThread);
  _objc_msgSend(self->_mainThreadImage,sel_release);
  self->_mainThreadImage = (id)0x0;
  local_14 = 0;
  piVar5 = &local_14;
  piVar4 = piVar1;
  piVar6 = piVar5;
  pvVar2 = _objc_msgSend(cls_HSMovie,sel_canInitWithURL_error_,piVar1,piVar5);
  if (((char)pvVar2 != '\0') && (local_14 == 0)) {
    piVar6 = piVar5;
    pvVar2 = _objc_msgSend(cls_HSMovie,sel_movieWithURL_error_,piVar1,piVar5);
    piVar4 = piVar1;
    if ((pvVar2 != (id)0x0) && (local_14 == 0)) {
      pvVar3 = _objc_msgSend(pvVar2,sel_checkExistingForCodecs_,piVar5,piVar6);
      piVar4 = piVar5;
      if (((char)pvVar3 != '\0') && (local_14 == 0)) {
        pvVar2 = _objc_msgSend(pvVar2,sel_posterImage,piVar5,piVar6);
        pvVar2 = _objc_msgSend(pvVar2,sel_retain);
        self->_mainThreadImage = pvVar2;
        goto LAB_001d75d5;
      }
    }
  }
  piVar5 = piVar4;
  pvVar2 = self->_mainThreadImage;
LAB_001d75d5:
  if (pvVar2 == (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_invalidMoviePreviewImage,piVar5,piVar6);
    pvVar2 = _objc_msgSend(pvVar2,sel_retain);
    self->_mainThreadImage = pvVar2;
  }
  return;
}

*/
- (void)generateMovieThumbnailInMainThread:(id)aThread
{
    NSURL *url = [NSURL fileURLWithPath:aThread];
    NSError *error = nil;

    [_mainThreadImage release];
    _mainThreadImage = nil;
    if ([HSMovie canInitWithURL:url error:&error] && error == nil) {
        HSMovie *movie = [HSMovie movieWithURL:url error:&error];
        if (movie != nil && error == nil && [movie checkExistingForCodecs:&error] && error == nil) {
            _mainThreadImage = [[movie posterImage] retain];
        }
    }
    if (_mainThreadImage == nil) {
        _mainThreadImage = [[self invalidMoviePreviewImage] retain];
    }
}

- (id)concreteMediaTypesDictionary
{
    id pvVar2;

    pvVar2 = _concreteMediaTypesDictionary;
    if (pvVar2 == nil) {
        pvVar2 = [[NSDictionary allocWithZone:[self zone]] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"ImportedMoviesMediaTypes" ofType:@"plist"]];
        _concreteMediaTypesDictionary = pvVar2;
    }
    return pvVar2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001d76df @ 001d76df, 124 bytes * /

void FUN_001d76df(HSImportDialogMoviesPaneViewController *self,SEL _cmd,int setMode,
                 id forGridControl)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(forGridControl,sel_mode);
  if (pvVar1 != (id)setMode) {
    pvVar1 = _objc_msgSend(forGridControl,sel_selectedItemIndex);
    _objc_msgSend(forGridControl,sel_setMode_,setMode);
    _objc_msgSend(forGridControl,sel_selectItemAtIndex_byExtendingSelection_,pvVar1,0);
  }
  return;
}

*/
- (void)setMode:(NSInteger)aMode forGridControl:(id)aControl
{
    if ([(SMKGridControl *)aControl mode] != aMode) {
        NSInteger index = [aControl selectedItemIndex];
        [aControl setMode:aMode];
        [aControl selectItemAtIndex:index byExtendingSelection:NO];
    }
}

- (id)invalidMoviePreviewImage
{
    id pvVar1;

    pvVar1 = _invalidMoviePreviewImage;
    if (pvVar1 == nil) {
        pvVar1 = [[[HSImagesProvider sharedImagesProvider] imageForName:@"InvalidMoviePreview" ofType:@"tiff"] retain];
        _invalidMoviePreviewImage = pvVar1;
    }
    return pvVar1;
}

- (void)invalidateSearch
{
    [_searchField setStringValue:@""];
    [_filterString release];
    _filterString = nil;
    [self invalidateMediaPaths];
}

- (void)generateCurrentFrameImageInMainThread
{
    [_currentFrameImage release];
    _currentFrameImage = [[_movie currentFrameImage] retain];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001d7895 @ 001d7895, 100 bytes * /

void FUN_001d7895(HSImportDialogMoviesPaneViewController *self,SEL _cmd)

{
  _objc_msgSend(self,sel_invalidatePreviewMovieTimer);
  _objc_msgSend(self,sel_invalidateCellAtIndex_,self->_playableItemIndex);
  self->_playableItemIndex = 0x7fffffff;
  _objc_msgSend(self,sel_setImagesForPlayButton_,0);
  return;
}

*/
- (void)stopPlayingQTVR
{
    [self invalidatePreviewMovieTimer];
    [self invalidateCellAtIndex:_playableItemIndex];
    _playableItemIndex = NSNotFound;
    [self setImagesForPlayButton:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001d78f9 @ 001d78f9, 483 bytes * /

void FUN_001d78f9(HSImportDialogMoviesPaneViewController *self,SEL _cmd,
                 id playQTVRSelectionFireMethod)

{
  float fVar1;
  id self_00;
  float fVar2;
  float fVar3;
  float fVar4;
  
  fVar2 = self->_panAngleMax;
  if ((fVar2 != 0.0) || (NAN(fVar2))) {
    fVar3 = ABS(fVar2);
  }
  else {
    fVar3 = 1.0;
  }
  if (fVar3 <= 360.0) {
    fVar3 = 360.0;
  }
  fVar1 = self->_panAngleMin;
  if (fVar3 * 0.0005 < ABS(360.0 - fVar2)) {
LAB_001d7a3a:
    fVar2 = self->_panAngle;
    if ((fVar2 != 0.0) || (NAN(fVar2))) {
      fVar3 = ABS(fVar2);
    }
    else {
      fVar3 = 1.0;
    }
    if ((fVar1 != 0.0) || (NAN(fVar1))) {
      fVar4 = ABS(fVar1);
    }
    else {
      fVar4 = 1.0;
    }
    if (fVar4 <= fVar3) {
      fVar4 = fVar3;
    }
    if (fVar2 <= fVar4 * 0.0005 + fVar1) goto LAB_001d7abc;
    fVar2 = fVar2 + -1.5;
    self->_panAngle = fVar2;
    self_00 = self->_movie;
  }
  else {
    if ((fVar1 != 0.0) || (NAN(fVar1))) {
      fVar2 = ABS(fVar1);
    }
    else {
      fVar2 = 1.0;
    }
    fVar3 = fVar2 * 0.0005;
    if (fVar2 <= 1.0) {
      fVar3 = 0.0005;
    }
    if (fVar3 < ABS(0.0 - fVar1)) goto LAB_001d7a3a;
    fVar2 = self->_panAngle + -1.5;
    self->_panAngle = fVar2;
    if ((fVar2 != 0.0) || (NAN(fVar2))) {
      fVar3 = ABS(fVar2);
    }
    else {
      fVar3 = 1.0;
    }
    if ((fVar1 != 0.0) || (NAN(fVar1))) {
      fVar4 = ABS(fVar1);
    }
    else {
      fVar4 = 1.0;
    }
    if (fVar4 <= fVar3) {
      fVar4 = fVar3;
    }
    if (fVar2 < fVar1 + fVar4 * -0.0005) {
      fVar2 = 360.0 - ABS(fVar2);
      self->_panAngle = fVar2;
    }
    self_00 = self->_movie;
  }
  _objc_msgSend(self_00,sel_setPanAngle_,fVar2);
LAB_001d7abc:
  _objc_msgSend(self,sel_invalidateCellAtIndex_,self->_playableItemIndex);
  return;
}

*/
- (void)playQTVRSelectionFireMethod:(id)aMethod
{
    float minAngle = _panAngleMin;
    float maxAngle = _panAngleMax;
    BOOL isFullCircle = fabsf(360.0f - maxAngle) <= MAX(HSMoviesPaneScale(maxAngle), 360.0f) * 0.0005f &&
                        fabsf(0.0f - minAngle) <= MAX(HSMoviesPaneScale(minAngle), 1.0f) * 0.0005f;

    if (isFullCircle) {
        _panAngle -= 1.5f;
        if (_panAngle < minAngle - MAX(HSMoviesPaneScale(minAngle), HSMoviesPaneScale(_panAngle)) * 0.0005f) {
            _panAngle = 360.0f - fabsf(_panAngle);
        }
        [_movie setPanAngle:_panAngle];
    }
    else if (minAngle + MAX(HSMoviesPaneScale(minAngle), HSMoviesPaneScale(_panAngle)) * 0.0005f < _panAngle) {
        _panAngle -= 1.5f;
        [_movie setPanAngle:_panAngle];
    }
    [self invalidateCellAtIndex:_playableItemIndex];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001d7adc @ 001d7adc, 1522 bytes * /

void FUN_001d7adc(HSImportDialogMoviesPaneViewController *self,SEL _cmd)

{
  undefined *puVar1;
  undefined *puVar2;
  HSImportDialogMoviesPaneViewController *pHVar3;
  HSImportDialogMoviesPaneViewController *pHVar4;
  id pvVar5;
  int iVar6;
  int iVar7;
  id pvVar8;
  id pvVar9;
  longdouble lVar10;
  double dVar11;
  undefined4 uVar12;
  int local_6c [22];
  HSImportDialogMoviesPaneViewController *local_14;
  
  local_14 = self;
  pvVar5 = _objc_msgSend(self,sel_isPlaying);
  if ((char)pvVar5 != '\0') {
    _objc_msgSend(local_14,sel_stopPlaying);
  }
  pvVar5 = _objc_msgSend(local_14->_imageGrid,sel_selectedItemIndex);
  _objc_exception_try_enter(local_6c);
  iVar6 = __setjmp(local_6c);
  pHVar3 = local_14;
  if (iVar6 != 0) {
    iVar7 = _objc_exception_extract(local_6c);
    _objc_exception_try_enter(local_6c);
    iVar6 = __setjmp(local_6c);
    if (iVar6 == 0) {
      iVar6 = _objc_exception_match(cls_NSException,iVar7);
      if (iVar6 != 0) goto LAB_001d80bd;
      _objc_exception_try_exit(local_6c);
    }
    else {
      iVar7 = _objc_exception_extract(local_6c);
    }
    if (iVar7 != 0) {
                    /* WARNING: Subroutine does not return * /
      _objc_exception_throw(iVar7);
    }
    goto LAB_001d80bd;
  }
  if (local_14->_movie == (id)0x0) {
    pvVar8 = _objc_msgSend(local_14,sel_movieAtIndex_,pvVar5);
    pvVar8 = _objc_msgSend(pvVar8,sel_retain);
    pHVar3->_movie = pvVar8;
  }
  if (local_14->_movie == (id)0x0) goto LAB_001d80bd;
  pvVar8 = _objc_msgSend(local_14->_movie,sel_isQTVRMovie);
  if ((char)pvVar8 == '\0') {
    pvVar8 = _objc_msgSend(local_14->_movie,sel_isPanoramaObject);
    if ((char)pvVar8 != '\0') goto LAB_001d7f20;
    pvVar8 = _objc_msgSend(local_14->_movie,sel_isInteractiveMovie);
    if ((char)pvVar8 != '\0') goto LAB_001d7f20;
    pvVar8 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    _objc_msgSend(pvVar8,sel_addObserver_selector_name_object_,local_14,sel_changedMovieTime_,
                  *(undefined4 *)PTR_00336754,local_14->_movie);
    pvVar8 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    _objc_msgSend(pvVar8,sel_addObserver_selector_name_object_,local_14,sel_endMoviePlayback_,
                  *(undefined4 *)PTR_00336750,local_14->_movie);
    _objc_msgSend(local_14->_movie,sel_gotoBeginning);
    pHVar3 = local_14;
    lVar10 = (longdouble)_HSNonLinearValueForSlider(local_14->_volumeSlider);
    _objc_msgSend(pHVar3,sel_setPreviewMovieVolume_,(float)lVar10);
    _objc_msgSend(local_14->_movie,sel_play);
    pHVar3 = local_14;
    puVar2 = cls_NSTimer;
    pvVar8 = _objc_msgSend(cls_NSDate,sel_date);
    puVar1 = sel_previewMovieTimerFireMethod_;
    pvVar9 = _objc_msgSend(local_14,sel_NSE_newWeakProxy);
    pvVar9 = _objc_msgSend(pvVar9,sel_autorelease);
    pvVar8 = _objc_msgSend(puVar2,sel_timerWithTimeInterval_target_selector_userInfo_repeats_,0,
                           0x3ff00000,pvVar9,puVar1,pvVar8,1);
    pvVar8 = _objc_msgSend(pvVar8,sel_retain);
    pHVar3->_previewMovieTimer = pvVar8;
    pvVar8 = _objc_msgSend(cls_NSRunLoop,sel_currentRunLoop);
    _objc_msgSend(pvVar8,sel_addTimer_forMode_,local_14->_previewMovieTimer,
                  *(undefined4 *)PTR_003361b4);
    _objc_msgSend(pvVar8,sel_addTimer_forMode_,local_14->_previewMovieTimer,
                  *(undefined4 *)PTR_003363f8);
    _objc_msgSend(pvVar8,sel_addTimer_forMode_,local_14->_previewMovieTimer,
                  *(undefined4 *)PTR_00336064);
    local_14->_playableItemIndex = (uint)pvVar5;
    _objc_msgSend(local_14,sel_invalidateCellAtIndex_,pvVar5);
    pvVar5 = local_14->_currentMovieProgressField;
    uVar12 = 0;
    pvVar8 = _objc_msgSend(cls_NSDate,sel_dateWithTimeIntervalSinceReferenceDate_,0,0);
    _objc_msgSend(pvVar5,sel_setObjectValue_,pvVar8);
  }
  else {
LAB_001d7f20:
    pHVar3 = local_14;
    dVar11 = _objc_msgSend_fpret(local_14->_movie,sel_panAngle);
    pHVar4 = local_14;
    pHVar3->_panAngle = (float)dVar11;
    dVar11 = _objc_msgSend_fpret(local_14->_movie,sel_minPanAngle);
    pHVar3 = local_14;
    pHVar4->_panAngleMin = (float)dVar11;
    dVar11 = _objc_msgSend_fpret(local_14->_movie,sel_maxPanAngle);
    pHVar4 = local_14;
    pHVar3->_panAngleMax = (float)dVar11;
    puVar2 = cls_NSTimer;
    puVar1 = sel_playQTVRSelectionFireMethod_;
    pvVar8 = _objc_msgSend(local_14,sel_NSE_newWeakProxy);
    pvVar8 = _objc_msgSend(pvVar8,sel_autorelease);
    pvVar8 = _objc_msgSend(puVar2,sel_timerWithTimeInterval_target_selector_userInfo_repeats_,
                           0xa0000000,0x3fb99999,pvVar8,puVar1,0,1);
    pvVar8 = _objc_msgSend(pvVar8,sel_retain);
    pHVar4->_previewMovieTimer = pvVar8;
    pvVar8 = _objc_msgSend(cls_NSRunLoop,sel_currentRunLoop);
    _objc_msgSend(pvVar8,sel_addTimer_forMode_,local_14->_previewMovieTimer,
                  *(undefined4 *)PTR_003361b4);
    _objc_msgSend(pvVar8,sel_addTimer_forMode_,local_14->_previewMovieTimer,
                  *(undefined4 *)PTR_003363f8);
    uVar12 = *(undefined4 *)PTR_00336064;
    _objc_msgSend(pvVar8,sel_addTimer_forMode_,local_14->_previewMovieTimer,uVar12);
    local_14->_playableItemIndex = (uint)pvVar5;
  }
  _objc_msgSend(local_14,sel_setImagesForPlayButton_,1,uVar12);
LAB_001d80bd:
  _objc_exception_try_exit(local_6c);
  return;
}

*/
- (void)playSelection
{
    if ([self isPlaying]) {
        [self stopPlaying];
    }
    NSInteger index = [_imageGrid selectedItemIndex];
    @try {
        if (_movie == nil) {
            _movie = [[self movieAtIndex:index] retain];
        }
        if (_movie == nil) {
            return;
        }
        if ([_movie isQTVRMovie] || [_movie isPanoramaObject] || [_movie isInteractiveMovie]) {
            _panAngle = [_movie panAngle];
            _panAngleMin = [_movie minPanAngle];
            _panAngleMax = [_movie maxPanAngle];
            _previewMovieTimer = [[NSTimer timerWithTimeInterval:0.1 target:[[self NSE_newWeakProxy] autorelease] selector:@selector(playQTVRSelectionFireMethod:) userInfo:nil repeats:YES] retain];
            NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
            [runLoop addTimer:_previewMovieTimer forMode:NSDefaultRunLoopMode];
            [runLoop addTimer:_previewMovieTimer forMode:NSModalPanelRunLoopMode];
            [runLoop addTimer:_previewMovieTimer forMode:NSEventTrackingRunLoopMode];
            _playableItemIndex = index;
        }
        else {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changedMovieTime:) name:HSMovieImageDidChangeNotification object:_movie];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endMoviePlayback:) name:HSMovieDidEndNotification object:_movie];
            [_movie gotoBeginning];
            [self setPreviewMovieVolume:HSNonLinearValueForSlider(_volumeSlider)];
            [_movie play];
        _previewMovieTimer = [[NSTimer timerWithTimeInterval:1.0 target:[[self NSE_newWeakProxy] autorelease] selector:@selector(previewMovieTimerFireMethod:) userInfo:[NSDate date] repeats:YES] retain];
            NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
            [runLoop addTimer:_previewMovieTimer forMode:NSDefaultRunLoopMode];
            [runLoop addTimer:_previewMovieTimer forMode:NSModalPanelRunLoopMode];
            [runLoop addTimer:_previewMovieTimer forMode:NSEventTrackingRunLoopMode];
            _playableItemIndex = index;
            [self invalidateCellAtIndex:index];
            [_currentMovieProgressField setObjectValue:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
        }
        [self setImagesForPlayButton:YES];
    }
    @catch (NSException *exception) {
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001d80d3 @ 001d80d3, 508 bytes * /

id FUN_001d80d3(HSImportDialogMoviesPaneViewController *self,SEL _cmd,uint movieAtIndex)

{
  undefined *self_00;
  HSImportDialogMoviesPaneViewController *pHVar1;
  int iVar2;
  int iVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  undefined4 uVar7;
  id local_78;
  int local_74 [23];
  id local_18;
  HSImportDialogMoviesPaneViewController *local_14;
  
  local_14 = self;
  local_18 = (id)movieAtIndex;
  local_78 = (id)0x0;
  _objc_exception_try_enter(local_74);
  iVar2 = __setjmp(local_74);
  pHVar1 = local_14;
  pvVar6 = local_18;
  if (iVar2 == 0) {
    if (local_18 != (id)0x7fffffff) {
      pvVar4 = _objc_msgSend(local_14,sel_currentMediaPathsLocation);
      pvVar5 = _objc_msgSend(pHVar1,sel_filteredMediaPathsForKey_,pvVar4);
      pvVar5 = _objc_msgSend(pvVar5,sel_count);
      pHVar1 = local_14;
      if (pvVar6 < pvVar5) {
        pvVar6 = _objc_msgSend(local_14,sel_currentMediaPathsLocation,pvVar4);
        pvVar6 = _objc_msgSend(pHVar1,sel_filteredMediaPathsForKey_,pvVar6);
        pvVar6 = _objc_msgSend(pvVar6,sel_objectAtIndex_,local_18);
        pvVar4 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_,pvVar6);
        uVar7 = 0;
        pvVar6 = pvVar4;
        pvVar5 = _objc_msgSend(cls_HSMovie,sel_canInitWithURL_error_,pvVar4,0);
        self_00 = cls_HSMovie;
        if ((char)pvVar5 != '\0') {
          pvVar6 = _objc_msgSend(local_14,sel_zone,pvVar6,uVar7);
          pvVar6 = _objc_msgSend(self_00,sel_allocWithZone_,pvVar6);
          pvVar6 = _objc_msgSend(pvVar6,sel_initWithURL_error_,pvVar4,0);
          local_78 = _objc_msgSend(pvVar6,sel_autorelease);
        }
      }
    }
  }
  else {
    iVar3 = _objc_exception_extract(local_74);
    _objc_exception_try_enter(local_74);
    iVar2 = __setjmp(local_74);
    if (iVar2 == 0) {
      iVar2 = _objc_exception_match(cls_NSException,iVar3);
      if (iVar2 != 0) goto LAB_001d82be;
      _objc_exception_try_exit(local_74);
    }
    else {
      iVar3 = _objc_exception_extract(local_74);
    }
    if (iVar3 != 0) {
                    /* WARNING: Subroutine does not return * /
      _objc_exception_throw(iVar3);
    }
  }
LAB_001d82be:
  _objc_exception_try_exit(local_74);
  return local_78;
}

*/
- (id)movieAtIndex:(NSUInteger)aIndex
{
    id movie = nil;
    @try {
        if (aIndex != NSNotFound) {
            NSArray *paths = [self filteredMediaPathsForKey:[self currentMediaPathsLocation]];
            if (aIndex < [paths count]) {
                NSURL *url = [NSURL fileURLWithPath:[paths objectAtIndex:aIndex]];
                if ([HSMovie canInitWithURL:url error:NULL]) {
                    movie = [[[HSMovie allocWithZone:[self zone]] initWithURL:url error:NULL] autorelease];
                }
            }
        }
    }
    @catch (NSException *exception) {
    }
    return movie;
}

- (double)displayDurationForMovie:(id)aMovie
{
    double dVar1_2;

    if ([_movie duration] < 1.0) {
        dVar1_2 = 1.0;
    }
    else {
        dVar1_2 = [_movie duration];
    }
    return dVar1_2;
}

- (BOOL)isPlaying
{
    return _playableItemIndex != NSNotFound;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001d832c @ 001d832c, 582 bytes * /

void FUN_001d832c(HSImportDialogMoviesPaneViewController *self,SEL _cmd)

{
  id pvVar1;
  int iVar2;
  int iVar3;
  int local_6c [22];
  HSImportDialogMoviesPaneViewController *local_14;
  
  local_14 = self;
  pvVar1 = _objc_msgSend(self,sel_isPlaying);
  if ((char)pvVar1 == '\0') {
    return;
  }
  pvVar1 = _objc_msgSend(local_14->_movie,sel_isQTVRMovie);
  if ((((char)pvVar1 != '\0') ||
      (pvVar1 = _objc_msgSend(local_14->_movie,sel_isPanoramaObject), (char)pvVar1 != '\0')) ||
     (pvVar1 = _objc_msgSend(local_14->_movie,sel_isInteractiveMovie), (char)pvVar1 != '\0')) {
    _objc_msgSend(local_14,sel_stopPlayingQTVR);
    return;
  }
  _objc_exception_try_enter(local_6c);
  iVar2 = __setjmp(local_6c);
  if (iVar2 == 0) {
    pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    _objc_msgSend(pvVar1,sel_removeObserver_name_object_,local_14,*(undefined4 *)PTR_00336754,
                  local_14->_movie);
    pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    _objc_msgSend(pvVar1,sel_removeObserver_name_object_,local_14,*(undefined4 *)PTR_00336750,
                  local_14->_movie);
    _objc_msgSend(local_14->_movie,sel_stop);
    _objc_msgSend(local_14->_movie,sel_gotoBeginning);
    _objc_msgSend(local_14,sel_invalidateCellAtIndex_,local_14->_playableItemIndex);
    local_14->_playableItemIndex = 0x7fffffff;
    _objc_msgSend(local_14,sel_setImagesForPlayButton_,0);
    _objc_msgSend(local_14,sel_stopPreviewMovieTimer);
  }
  else {
    iVar3 = _objc_exception_extract(local_6c);
    _objc_exception_try_enter(local_6c);
    iVar2 = __setjmp(local_6c);
    if (iVar2 == 0) {
      iVar2 = _objc_exception_match(cls_NSException,iVar3);
      if (iVar2 != 0) goto LAB_001d8437;
      _objc_exception_try_exit(local_6c);
    }
    else {
      iVar3 = _objc_exception_extract(local_6c);
    }
    if (iVar3 != 0) {
                    /* WARNING: Subroutine does not return * /
      _objc_exception_throw(iVar3);
    }
  }
LAB_001d8437:
  _objc_exception_try_exit(local_6c);
  return;
}

*/
- (void)stopPlaying
{
    if (![self isPlaying]) {
        return;
    }
    if ([_movie isQTVRMovie] || [_movie isPanoramaObject] || [_movie isInteractiveMovie]) {
        [self stopPlayingQTVR];
        return;
    }
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:HSMovieImageDidChangeNotification object:_movie];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:HSMovieDidEndNotification object:_movie];
        [_movie stop];
        [_movie gotoBeginning];
        [self invalidateCellAtIndex:_playableItemIndex];
        _playableItemIndex = NSNotFound;
        [self setImagesForPlayButton:NO];
        [self stopPreviewMovieTimer];
    }
    @catch (NSException *exception) {
    }
}

- (void)invalidateCellAtIndex:(NSUInteger)aIndex
{
    id cell = [_imageGrid cellAtIndex:aIndex];
    [cell setNeedsUpdateAsItem:aIndex];
    id matrix = [_imageGrid gridMatrix];
    NSInteger row = 0;
    NSInteger column = 0;
    if ([matrix getRow:&row column:&column ofCell:cell]) {
        [matrix setNeedsDisplayInRect:[matrix cellFrameAtRow:row column:column]];
    }
}

- (void)endMoviePlayback:(id)aPlayback
{
    [self stopPlaying];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001d8688 @ 001d8688, 91 bytes * /

void FUN_001d8688(HSImportDialogMoviesPaneViewController *self,SEL _cmd,id changedMovieTime)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  
  pvVar1 = (id)self->_playableItemIndex;
  pvVar2 = _objc_msgSend(self->_imageGrid,sel_selectedItemIndex);
  op = sel_invalidateCellAtIndex_;
  if (pvVar1 != pvVar2) {
    op = sel_stopPlaying;
  }
  _objc_msgSend(self,op);
  return;
}

*/
- (void)changedMovieTime:(id)aTime
{
    if ((NSInteger)_playableItemIndex != [_imageGrid selectedItemIndex]) {
        [self stopPlaying];
    }
    else {
        [self invalidateCellAtIndex:_playableItemIndex];
    }
}

- (void)previewMovieTimerFireMethod:(id)aMethod
{
    [_currentMovieProgressField setObjectValue:[NSDate dateWithTimeIntervalSinceReferenceDate:[[NSDate date] timeIntervalSinceDate:[aMethod userInfo]]]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001d8775 @ 001d8775, 330 bytes * /

void FUN_001d8775(HSImportDialogMoviesPaneViewController *self,SEL _cmd)

{
  undefined *puVar1;
  undefined *self_00;
  id pvVar2;
  id pvVar3;
  
  self_00 = cls_NSTimer;
  pvVar2 = _objc_msgSend(cls_NSDate,sel_date);
  puVar1 = sel_previewMovieTimerFireMethod_;
  pvVar3 = _objc_msgSend(self,sel_NSE_newWeakProxy);
  pvVar3 = _objc_msgSend(pvVar3,sel_autorelease);
  pvVar2 = _objc_msgSend(self_00,sel_timerWithTimeInterval_target_selector_userInfo_repeats_,0,
                         0x3ff00000,pvVar3,puVar1,pvVar2,1);
  pvVar2 = _objc_msgSend(pvVar2,sel_retain);
  self->_previewMovieTimer = pvVar2;
  pvVar2 = _objc_msgSend(cls_NSRunLoop,sel_currentRunLoop);
  _objc_msgSend(pvVar2,sel_addTimer_forMode_,self->_previewMovieTimer,*(undefined4 *)PTR_003361b4);
  _objc_msgSend(pvVar2,sel_addTimer_forMode_,self->_previewMovieTimer,*(undefined4 *)PTR_003363f8);
  _objc_msgSend(pvVar2,sel_addTimer_forMode_,self->_previewMovieTimer,*(undefined4 *)PTR_00336064);
  return;
}

*/
- (void)startPreviewMovieTimer
{
    _previewMovieTimer = [[NSTimer timerWithTimeInterval:1.0 target:[[self NSE_newWeakProxy] autorelease] selector:@selector(previewMovieTimerFireMethod:) userInfo:[NSDate date] repeats:YES] retain];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:_previewMovieTimer forMode:NSDefaultRunLoopMode];
    [runLoop addTimer:_previewMovieTimer forMode:NSModalPanelRunLoopMode];
    [runLoop addTimer:_previewMovieTimer forMode:NSEventTrackingRunLoopMode];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001d88bf @ 001d88bf, 193 bytes * /

void FUN_001d88bf(HSImportDialogMoviesPaneViewController *self,SEL _cmd)

{
  id self_00;
  undefined *self_01;
  id pvVar1;
  double dVar2;
  undefined8 uVar3;
  undefined4 uVar4;
  
  self_01 = cls_NSDate;
  self_00 = self->_currentMovieProgressField;
  if (self->_movie == (id)0x0) {
    uVar4 = 0;
    pvVar1 = _objc_msgSend(cls_NSDate,sel_dateWithTimeIntervalSinceReferenceDate_,0,0);
    uVar3 = CONCAT44(uVar4,pvVar1);
    _objc_msgSend(self_00,sel_setObjectValue_,pvVar1);
  }
  else {
    dVar2 = _objc_msgSend_fpret(self,sel_displayDurationForMovie_,self->_movie);
    pvVar1 = _objc_msgSend(self_01,sel_dateWithTimeIntervalSinceReferenceDate_,dVar2);
    uVar3 = CONCAT44((int)((ulonglong)dVar2 >> 0x20),pvVar1);
    _objc_msgSend(self_00,sel_setObjectValue_,pvVar1);
  }
  _objc_msgSend(self,sel_invalidatePreviewMovieTimer,uVar3);
  return;
}

*/
- (void)stopPreviewMovieTimer
{
    if (_movie == nil) {
        [_currentMovieProgressField setObjectValue:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
    }
    else {
        [_currentMovieProgressField setObjectValue:[NSDate dateWithTimeIntervalSinceReferenceDate:[self displayDurationForMovie:_movie]]];
    }
    [self invalidatePreviewMovieTimer];
}

- (void)invalidatePreviewMovieTimer
{
    if (_previewMovieTimer != nil) {
        [_previewMovieTimer invalidate];
        [_previewMovieTimer release];
        _previewMovieTimer = nil;
    }
}

- (void)setImagesForPlayButton:(BOOL)aButton
{
    id self_00;
    id pvVar1;

    if (aButton == NO) {
        [_playButton setImage:_playButtonImage];
        [_playButtonCell setAquaAlternateImage:_playButtonAquaImage];
        pvVar1 = _playButtonGraphiteImage;
        self_00 = _playButtonCell;
    }
    else {
        [_playButton setImage:_stopButtonImage];
        [_playButtonCell setAquaAlternateImage:_stopButtonAquaImage];
        pvVar1 = _stopButtonGraphiteImage;
        self_00 = _playButtonCell;
    }
    [self_00 setGraphiteAlternateImage:pvVar1];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-multiple-method-names"
- (void)volumeChangedToMaximum:(id)aMaximum
{
    id self_00;

    self_00 = _volumeSlider;
    [self_00 setFloatValue:(float)[self_00 maxValue]];
    [self setPreviewMovieVolume:(float)[_volumeSlider maxValue]];
}
#pragma clang diagnostic pop

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-multiple-method-names"
- (void)volumeChangedToMinimum:(id)aMinimum
{
    id self_00;

    self_00 = _volumeSlider;
    [self_00 setFloatValue:(float)[self_00 minValue]];
    [self setPreviewMovieVolume:(float)[_volumeSlider minValue]];
}
#pragma clang diagnostic pop

/* --- i386 decompilation (Ghidra) ---
/* FUN_001d8b6d @ 001d8b6d, 55 bytes * /

void FUN_001d8b6d(HSImportDialogMoviesPaneViewController *self,SEL _cmd,id volumeChanged)

{
  longdouble lVar1;
  
  lVar1 = (longdouble)_HSNonLinearValueForSlider(volumeChanged);
  _objc_msgSend(self,sel_setPreviewMovieVolume_,(float)lVar1);
  return;
}

*/
- (void)volumeChanged:(id)aChanged
{
    [self setPreviewMovieVolume:HSNonLinearValueForSlider(aChanged)];
}

- (void)setPreviewMovieVolume:(CGFloat)aVolume
{
    [_movie setVolume:aVolume * aVolume];
}

- (void)zoomMax:(id)aMax
{
    [self zoomThumbnailSizeSliderToValue:[_thumbnailSizeSlider maxValue]];
}

- (void)zoomMin:(id)aMin
{
    [self zoomThumbnailSizeSliderToValue:[_thumbnailSizeSlider minValue]];
}

- (void)zoomThumbnailSizeSliderToValue:(double)aValue
{
    [_thumbnailSizeSlider setDoubleValue:aValue];
    [self sliderMoved:_thumbnailSizeSlider];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001d8cbf @ 001d8cbf, 280 bytes * /

void FUN_001d8cbf(HSImportDialogMoviesPaneViewController *self,SEL _cmd,id sliderMoved)

{
  id pvVar1;
  longdouble lVar2;
  double dVar3;
  HSImportDialogMoviesPaneViewController *self_00;
  SEL op;
  id pvVar4;
  
  lVar2 = (longdouble)_HSNonLinearValueForSlider(self->_thumbnailSizeSlider);
  dVar3 = _objc_msgSend_fpret(sliderMoved,sel_maxValue);
  pvVar4 = (id)(float)lVar2;
  if ((float)pvVar4 <= (float)dVar3 * 0.98) {
    if ((float)dVar3 * 0.98 < (float)pvVar4) goto LAB_001d8d87;
    _objc_msgSend(self,sel_setMode_forGridControl_,0,self->_imageGrid);
    self_00 = self->_imageGrid;
    op = sel_setThumbnailSize_;
    pvVar1 = pvVar4;
  }
  else {
    pvVar4 = (id)0x1;
    self_00 = self;
    op = sel_setMode_forGridControl_;
    pvVar1 = self->_imageGrid;
  }
  _objc_msgSend(self_00,op,pvVar4,pvVar1);
LAB_001d8d87:
  pvVar4 = self->_imageGrid;
  pvVar1 = _objc_msgSend(pvVar4,sel_selectedItemIndex);
  _objc_msgSend(pvVar4,sel_scrollToVisibleAtIndex_,pvVar1);
  _objc_msgSend(self->_imageGrid,sel_setNeedsDisplay_,1);
  return;
}

*/
- (void)sliderMoved:(id)aMoved
{
    float size = HSNonLinearValueForSlider(_thumbnailSizeSlider);
    float maxValue = (float)[(NSSlider *)aMoved maxValue];

    if (maxValue * 0.98f < size) {
        [self setMode:1 forGridControl:_imageGrid];
    }
    else {
        [self setMode:0 forGridControl:_imageGrid];
        [_imageGrid setThumbnailSize:NSMakeSize(size, size)];
    }
    [_imageGrid scrollToVisibleAtIndex:[_imageGrid selectedItemIndex]];
    [_imageGrid setNeedsDisplay:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001d8dd7 @ 001d8dd7, 76 bytes * /

void FUN_001d8dd7(HSImportDialogMoviesPaneViewController *self,SEL _cmd,id playSelection)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_isPlaying);
  op = sel_playSelection;
  if ((char)pvVar1 != '\0') {
    op = sel_stopPlaying;
  }
  _objc_msgSend(self,op);
  return;
}

*/
- (void)playSelection:(id)aSelection
{
    if ([self isPlaying]) {
        [self stopPlaying];
    }
    else {
        [self playSelection];
    }
}

- (void)onDoubleClick:(id)aClick
{
    [_dialogController addToCard:aClick];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001d8e53 @ 001d8e53, 201 bytes * /

BOOL FUN_001d8e53(HSImportDialogMoviesPaneViewController *self,SEL _cmd,id mediaPathConformsToFilter
                 )

{
  id pvVar1;
  char cVar2;
  HSImportDialogMoviesPaneViewController *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSImportDialogBasePaneViewContro_00353fc0;
  pvVar1 = _objc_msgSendSuper(&local_1c,sel_mediaPathConformsToFilter_,mediaPathConformsToFilter);
  cVar2 = (char)pvVar1;
  if ((cVar2 != '\0') && (pvVar1 = _objc_msgSend(self->_filterString,sel_length), pvVar1 != (id)0x0)
     ) {
    pvVar1 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
    pvVar1 = _objc_msgSend(pvVar1,sel_displayNameAtPath_,mediaPathConformsToFilter);
    pvVar1 = _objc_msgSend(pvVar1,sel_rangeOfString_options_,self->_filterString,1);
    cVar2 = pvVar1 != (id)0x7fffffff;
  }
  return cVar2;
}

*/
- (BOOL)mediaPathConformsToFilter:(id)aFilter
{
    BOOL conforms = [super mediaPathConformsToFilter:aFilter];
    if (conforms && [_filterString length] != 0) {
        conforms = [[[NSFileManager defaultManager] displayNameAtPath:aFilter] rangeOfString:_filterString options:NSCaseInsensitiveSearch].location != NSNotFound;
    }
    return conforms;
}

- (void)itemsFilterPopUpDidChange:(id)aChange
{
    [_itemsFilterPopUp synchronizeTitleAndSelectedItem];
    [self invalidateMediaPaths];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001d8f5e @ 001d8f5e, 340 bytes * /

void FUN_001d8f5e(HSImportDialogMoviesPaneViewController *self,SEL _cmd,id controlTextDidChange)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  cfstringStruct *pcVar4;
  
  pvVar1 = _objc_msgSend(controlTextDidChange,sel_object);
  pvVar2 = _objc_msgSend(pvVar1,sel_stringValue);
  pvVar1 = pvVar2;
  pvVar3 = _objc_msgSend(self->_filterString,sel_isEqualToString_,pvVar2);
  if ((char)pvVar3 == '\0') {
    _objc_msgSend(self->_filterString,sel_release,pvVar1);
    pvVar1 = _objc_msgSend(pvVar2,sel_copy);
    self->_filterString = pvVar1;
    self_00 = cls_NSBundle;
    pvVar1 = _objc_msgSend(self,sel_class);
    pvVar1 = _objc_msgSend(self_00,sel_bundleForClass_,pvVar1);
    pvVar2 = _objc_msgSend(self->_filterString,sel_length);
    pcVar4 = &cfstr_NotFound_placeholderString;
    if (pvVar2 == (id)0x0) {
      pcVar4 = &cfstr_Empty_placeholderString;
    }
    pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,pcVar4,&cfstr_empty,
                           &cfstr_ImportDialogs);
    _objc_msgSend(self->_imageGrid,sel_setPlaceholderString_,pvVar1);
  }
  _objc_msgSend(self,sel_invalidateMediaPaths,pvVar1);
  return;
}

*/
- (void)controlTextDidChange:(id)aChange
{
    id string = [[aChange object] stringValue];
    if (![_filterString isEqualToString:string]) {
        [_filterString release];
        _filterString = [string copy];
        [_imageGrid setPlaceholderString:[[NSBundle bundleForClass:[self class]] localizedStringForKey:([_filterString length] == 0 ? @"Empty_placeholderString" : @"NotFound_placeholderString") value:@"" table:@"ImportDialogs"]];
    }
    [self invalidateMediaPaths];
}

- (void)selectionDidChangeInGridControl:(id)aControl
{
    if (_imageGrid == aControl) {
        if ([aControl selectedItemIndex] != _playableItemIndex) {
            if ([self isPlaying]) {
                [self stopPlaying];
            }
            [_movie release];
            _movie = nil;
        }
    }
    [self validatePreviewMovieControls];
    [_dialogController validateUIElements];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001d9154 @ 001d9154, 980 bytes * /

void FUN_001d9154(HSImportDialogMoviesPaneViewController *self,SEL _cmd)

{
  undefined *puVar1;
  char cVar2;
  id pvVar3;
  id pvVar4;
  int iVar5;
  uint uVar6;
  double dVar7;
  double dVar8;
  double dVar9;
  undefined4 uVar11;
  ulonglong uVar10;
  cfstringStruct *pcVar12;
  
  pvVar3 = self->_movie;
  if (pvVar3 == (id)0x0) {
    pvVar3 = _objc_msgSend(self->_imageGrid,sel_selectedItemIndex);
    pvVar3 = _objc_msgSend(self,sel_movieAtIndex_,pvVar3);
    pvVar3 = _objc_msgSend(pvVar3,sel_retain);
    self->_movie = pvVar3;
  }
  if (pvVar3 == (id)0x0) {
LAB_001d92e8:
    pvVar3 = _objc_msgSend(self->_movie,sel_isQTVRMovie);
    if ((char)pvVar3 == '\0') {
      pvVar3 = _objc_msgSend(self->_movie,sel_isPanoramaObject);
      if ((char)pvVar3 == '\0') {
        pvVar3 = _objc_msgSend(self->_movie,sel_isInteractiveMovie);
        if ((char)pvVar3 == '\0') {
          pvVar3 = self->_currentMovieProgressField;
          uVar6 = 0;
          pvVar4 = _objc_msgSend(cls_NSDate,sel_dateWithTimeIntervalSinceReferenceDate_,0,0);
          _objc_msgSend(pvVar3,sel_setObjectValue_,pvVar4);
          pvVar3 = self->_playButton;
          uVar10 = (ulonglong)uVar6 << 0x20;
          goto LAB_001d9433;
        }
      }
    }
    puVar1 = cls_NSBundle;
    pvVar3 = self->_currentMovieProgressField;
    pvVar4 = _objc_msgSend(self,sel_class);
    pvVar4 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar4);
    pcVar12 = &cfstr_empty;
    pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,&cfstr_QTVR,&cfstr_empty,
                           &cfstr_ImportDialogs);
    _objc_msgSend(pvVar3,sel_setStringValue_,pvVar4);
    pvVar3 = self->_playButton;
    uVar10 = CONCAT44(pcVar12,1);
  }
  else {
    pvVar3 = _objc_msgSend(pvVar3,sel_isQTVRMovie);
    if ((char)pvVar3 != '\0') goto LAB_001d92e8;
    pvVar3 = _objc_msgSend(self->_movie,sel_isPanoramaObject);
    if ((char)pvVar3 != '\0') goto LAB_001d92e8;
    pvVar3 = _objc_msgSend(self->_movie,sel_isInteractiveMovie);
    puVar1 = cls_NSDate;
    if ((char)pvVar3 != '\0') goto LAB_001d92e8;
    pvVar3 = self->_currentMovieProgressField;
    dVar9 = _objc_msgSend_fpret(self,sel_displayDurationForMovie_,self->_movie);
    pvVar4 = _objc_msgSend(puVar1,sel_dateWithTimeIntervalSinceReferenceDate_,dVar9);
    uVar11 = (undefined4)((ulonglong)dVar9 >> 0x20);
    _objc_msgSend(pvVar3,sel_setObjectValue_,pvVar4);
    pvVar3 = self->_playButton;
    dVar9 = _objc_msgSend_fpret(self->_movie,sel_duration);
    if ((dVar9 != 0.0) || (NAN(dVar9))) {
      dVar7 = ABS(dVar9);
    }
    else {
      dVar7 = 1.0;
    }
    dVar8 = 1e-05;
    if (1.0 <= dVar7) {
      dVar8 = dVar7 * 1e-05;
    }
    uVar10 = CONCAT44(uVar11,-(uint)(dVar8 < ABS(dVar9))) & 0xffffffff00000001;
  }
LAB_001d9433:
  _objc_msgSend(pvVar3,sel_setEnabled_,uVar10);
  if (self->_movie != (id)0x0) {
    pvVar3 = _objc_msgSend(self->_movie,sel_hasSound,uVar10);
    if ((char)pvVar3 != '\0') {
      cVar2 = '\x01';
      goto LAB_001d945e;
    }
  }
  cVar2 = '\0';
LAB_001d945e:
  iVar5 = (int)cVar2;
  _objc_msgSend(self->_volumeSlider,sel_setEnabled_,iVar5);
  _objc_msgSend(self->_volumeMin,sel_setEnabled_,iVar5);
  _objc_msgSend(self->_volumeMax,sel_setEnabled_,iVar5);
  pvVar3 = _objc_msgSend(self->_imageGrid,sel_count);
  uVar6 = (uint)(pvVar3 != (id)0x0);
  _objc_msgSend(self->_thumbnailSizeSlider,sel_setEnabled_,uVar6);
  _objc_msgSend(self->_thumbnailSizeMin,sel_setEnabled_,uVar6);
  _objc_msgSend(self->_thumbnailSizeMax,sel_setEnabled_,uVar6);
  return;
}

*/
- (void)validatePreviewMovieControls
{
    if (_movie == nil) {
        _movie = [[self movieAtIndex:[_imageGrid selectedItemIndex]] retain];
    }
    if (_movie != nil && ![_movie isQTVRMovie] && ![_movie isPanoramaObject] && ![_movie isInteractiveMovie]) {
        [_currentMovieProgressField setObjectValue:[NSDate dateWithTimeIntervalSinceReferenceDate:[self displayDurationForMovie:_movie]]];
        double duration = [_movie duration];
        double scale = duration != 0 ? fabs(duration) : 1.0;
        double tolerance = scale < 1.0 ? 1e-05 : scale * 1e-05;
        [_playButton setEnabled:tolerance < fabs(duration)];
    }
    else if ([_movie isQTVRMovie] || [_movie isPanoramaObject] || [_movie isInteractiveMovie]) {
        [_currentMovieProgressField setStringValue:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"QTVR" value:@"" table:@"ImportDialogs"]];
        [_playButton setEnabled:YES];
    }
    else {
        [_currentMovieProgressField setObjectValue:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
        [_playButton setEnabled:NO];
    }
    BOOL hasSound = _movie != nil && [_movie hasSound];
    [_volumeSlider setEnabled:hasSound];
    [_volumeMin setEnabled:hasSound];
    [_volumeMax setEnabled:hasSound];
    BOOL hasItems = [_imageGrid count] != 0;
    [_thumbnailSizeSlider setEnabled:hasItems];
    [_thumbnailSizeMin setEnabled:hasItems];
    [_thumbnailSizeMax setEnabled:hasItems];
}

- (id)gridControl:(id)aControl additionalInfoForItemAt:(NSInteger)aAt
{
    id pvVar1;
    id pvVar1_2;

    pvVar1 = [self gridControl:aControl titleForItemAt:aAt];
    if (pvVar1 == nil) {
        pvVar1_2 = nil;
    }
    else {
        pvVar1_2 = [NSDictionary dictionaryWithObject:pvVar1 forKey:SMKGridAttributeVoiceOverItemTypeKey];
    }
    return pvVar1_2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001d958e @ 001d958e, 934 bytes * /

id FUN_001d958e(HSImportDialogMoviesPaneViewController *self,SEL _cmd,id gridControl,
               int imageForItemAt)

{
  id pvVar1;
  undefined *puVar2;
  id pvVar3;
  undefined *puVar4;
  char *pcVar5;
  char local_11;
  
  if (self->_playableItemIndex == imageForItemAt) {
    pvVar1 = _objc_msgSend(cls_NSArray,sel_arrayWithObjects_,*(undefined4 *)PTR_003361b4,
                           *(undefined4 *)PTR_003363f8,*(undefined4 *)PTR_00336064,
                           *(undefined4 *)PTR_00336758,0);
    _objc_msgSend(self,sel_performSelectorOnMainThread_withObject_waitUntilDone_modes_,
                  sel_generateCurrentFrameImageInMainThread,0,1,pvVar1);
    if (self->_currentFrameImage != (id)0x0) {
      return self->_currentFrameImage;
    }
  }
  pvVar1 = _objc_msgSend(self,sel_currentMediaPathsLocation);
  pvVar1 = _objc_msgSend(self,sel_filteredMediaPathsForKey_,pvVar1);
  puVar2 = _objc_msgSend(pvVar1,sel_objectAtIndex_,imageForItemAt);
  pvVar1 = _objc_msgSend(self->_imageGrid,sel_mode);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_HSThumbnailManager,sel_sharedThumbnailManager,imageForItemAt);
    imageForItemAt = (int)_objc_msgSend(cls_NSURL,sel_fileURLWithPath_,puVar2);
    pvVar1 = _objc_msgSend(pvVar1,sel_thumbnailForURL_,imageForItemAt);
  }
  else {
    pvVar1 = (id)0x0;
  }
  local_11 = '\0';
  pvVar3 = _objc_msgSend(cls_NSFileManager,sel_defaultManager,imageForItemAt);
  pcVar5 = &local_11;
  puVar4 = puVar2;
  _objc_msgSend(pvVar3,sel_fileExistsAtPath_isDirectory_,puVar2,pcVar5);
  if (pvVar1 == (id)0x0) {
    if (local_11 != '\0') {
      pvVar3 = _objc_msgSend(cls_NSWorkspace,sel_sharedWorkspace,puVar4,pcVar5);
      puVar4 = puVar2;
      pvVar3 = _objc_msgSend(pvVar3,sel_isFilePackageAtPath_,puVar2);
      if ((char)pvVar3 == '\0') {
        pvVar1 = _objc_msgSend(cls_NSWorkspace,sel_sharedWorkspace,puVar4,pcVar5);
        pvVar1 = _objc_msgSend(pvVar1,sel_iconForFile_,puVar2);
        pvVar3 = _objc_msgSend(cls_HSSystem,sel_sharedSystem);
        pvVar3 = _objc_msgSend(pvVar3,sel_isLeopardOrGreater);
        if ((char)pvVar3 != '\0') {
          _objc_msgSend(pvVar1,sel_setSize_,0x44000000,0x44000000);
          return pvVar1;
        }
        _objc_msgSend(pvVar1,sel_setSize_,0x43000000,0x43000000);
        return pvVar1;
      }
    }
    pvVar3 = _objc_msgSend(cls_NSFileManager,sel_defaultManager,puVar4,pcVar5);
    pvVar3 = _objc_msgSend(pvVar3,sel_hyperFileTypeAtPath_,puVar2);
    if (pvVar3 != (id)0x0) {
      pvVar1 = _objc_msgSend(cls_HSNewMediaAccessor,sel_fullPathForMediaPath_mediaType_,puVar2,
                             pvVar3);
      if (pvVar1 != (id)0x0) {
        pvVar3 = _objc_msgSend(cls_NSArray,sel_arrayWithObjects_,*(undefined4 *)PTR_003361b4,
                               *(undefined4 *)PTR_003363f8,*(undefined4 *)PTR_00336064,
                               *(undefined4 *)PTR_00336758,0);
        puVar2 = sel_generateMovieThumbnailInMainThread_;
        _objc_msgSend(self,sel_performSelectorOnMainThread_withObject_waitUntilDone_modes_,
                      sel_generateMovieThumbnailInMainThread_,pvVar1,1,pvVar3);
        pvVar3 = pvVar1;
      }
      pvVar1 = _objc_msgSend(self->_mainThreadImage,sel_autorelease,puVar2,pvVar3);
      self->_mainThreadImage = (id)0x0;
    }
  }
  return pvVar1;
}

*/
- (id)gridControl:(id)aControl imageForItemAt:(NSInteger)aAt
{
    NSArray *modes = [NSArray arrayWithObjects:NSDefaultRunLoopMode, NSModalPanelRunLoopMode, NSEventTrackingRunLoopMode, HSThumbnailGenerationRunLoopMode, nil];

    if ((NSInteger)_playableItemIndex == aAt) {
        [self performSelectorOnMainThread:@selector(generateCurrentFrameImageInMainThread) withObject:nil waitUntilDone:YES modes:modes];
        if (_currentFrameImage != nil) {
            return _currentFrameImage;
        }
    }
    NSString *path = [[self filteredMediaPathsForKey:[self currentMediaPathsLocation]] objectAtIndex:aAt];
    id image = nil;
    if ([_imageGrid mode] == 0) {
        image = [[HSThumbnailManager sharedThumbnailManager] thumbnailForURL:[NSURL fileURLWithPath:path]];
    }
    BOOL isDirectory = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
    if (image == nil) {
        if (isDirectory && ![[NSWorkspace sharedWorkspace] isFilePackageAtPath:path]) {
            image = [[NSWorkspace sharedWorkspace] iconForFile:path];
            if ([[HSSystem sharedSystem] isLeopardOrGreater]) {
                [(NSImage *)image setSize:NSMakeSize(512, 512)];
            }
            else {
                [(NSImage *)image setSize:NSMakeSize(128, 128)];
            }
            return image;
        }
        id type = [[NSFileManager defaultManager] hyperFileTypeAtPath:path];
        if (type != nil) {
            id fullPath = [HSNewMediaAccessor fullPathForMediaPath:path mediaType:type];
            if (fullPath != nil) {
                [self performSelectorOnMainThread:@selector(generateMovieThumbnailInMainThread:) withObject:fullPath waitUntilDone:YES modes:modes];
            }
            image = [_mainThreadImage autorelease];
            _mainThreadImage = nil;
        }
    }
    return image;
}

- (id)gridControl:(id)aControl titleForItemAt:(NSInteger)aAt
{
    return [[[[self filteredMediaPathsForKey:[self currentMediaPathsLocation]] extraObjectAtIndex:aAt] lastPathComponent] stringByDeletingPathExtension];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001d99b1 @ 001d99b1, 255 bytes * /

int FUN_001d99b1(HSImportDialogMoviesPaneViewController *self,SEL _cmd,id numberOfItemsInGridControl
                )

{
  undefined *self_00;
  undefined *self_01;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar1 = _objc_msgSend(self,sel_currentMediaPathsLocation);
  pvVar1 = _objc_msgSend(self,sel_filteredMediaPathsForKey_,pvVar1);
  pvVar2 = _objc_msgSend(pvVar1,sel_count);
  self_01 = cls_NSString;
  self_00 = cls_NSBundle;
  pvVar1 = self->_itemsCountTextField;
  pvVar3 = _objc_msgSend(self,sel_class);
  pvVar3 = _objc_msgSend(self_00,sel_bundleForClass_,pvVar3);
  pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr__dItems,&cfstr_empty,
                         &cfstr_ImportDialogs);
  pvVar3 = _objc_msgSend(self_01,sel_stringWithFormat_,pvVar3,pvVar2);
  _objc_msgSend(pvVar1,sel_setStringValue_,pvVar3);
  return (int)pvVar2;
}

*/
- (NSInteger)numberOfItemsInGridControl:(id)aControl
{
    NSUInteger count = [[self filteredMediaPathsForKey:[self currentMediaPathsLocation]] count];
    NSString *format = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"%dItems" value:@"" table:@"ImportDialogs"];
    [_itemsCountTextField setStringValue:[NSString stringWithFormat:format, (int)count]];
    return (NSInteger)count;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001d9ab0 @ 001d9ab0, 387 bytes * /

void FUN_001d9ab0(HSImportDialogMoviesPaneViewController *self,SEL _cmd)

{
  undefined4 uVar1;
  id self_00;
  id pvVar2;
  id self_01;
  id pvVar3;
  undefined4 uVar4;
  HSImportDialogMoviesPaneViewController *local_1c;
  undefined *local_18;
  
  _objc_msgSend(self,sel_storeSelection);
  if (self->_imageGrid != (id)0x0) {
    self_00 = _objc_msgSend(cls_NSRunLoop,sel_currentRunLoop);
    pvVar2 = _objc_msgSend(self->_imageGrid,sel_tryLockBeforeReloadingData);
    if ((char)pvVar2 == '\0') {
      uVar1 = *(undefined4 *)PTR_00336758;
      do {
        pvVar2 = _objc_msgSend(cls_NSAutoreleasePool,sel_alloc);
        self_01 = _objc_msgSend(pvVar2,sel_init);
        pvVar2 = (id)0x3f847ae1;
        uVar4 = 0x47ae147b;
        pvVar3 = _objc_msgSend(cls_NSDate,sel_dateWithTimeIntervalSinceNow_,0x47ae147b,0x3f847ae1);
        if (pvVar3 != (id)0x0) {
          uVar4 = uVar1;
          _objc_msgSend(self_00,sel_runMode_beforeDate_,uVar1,pvVar3);
          pvVar2 = pvVar3;
        }
        _objc_msgSend(self_01,sel_release,uVar4,pvVar2);
        pvVar2 = _objc_msgSend(self->_imageGrid,sel_tryLockBeforeReloadingData);
      } while ((char)pvVar2 == '\0');
    }
  }
  local_1c = self;
  local_18 = PTR_s_HSImportDialogBasePaneViewContro_00353fc0;
  _objc_msgSendSuper(&local_1c,sel_invalidateMediaPaths);
  _objc_msgSend(self->_imageGrid,sel_reloadDataAndUnlock);
  _objc_msgSend(self,sel_restoreSelection);
  _objc_msgSend(self,sel_selectionDidChangeInGridControl_,self->_imageGrid);
  return;
}

*/
- (void)invalidateMediaPaths
{
    [self storeSelection];
    if (_imageGrid != nil) {
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        while (![_imageGrid tryLockBeforeReloadingData]) {
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0.01];
            if (date != nil) {
                [runLoop runMode:HSThumbnailGenerationRunLoopMode beforeDate:date];
            }
            [pool release];
        }
    }
    [super invalidateMediaPaths];
    [_imageGrid reloadDataAndUnlock];
    [self restoreSelection];
    [self selectionDidChangeInGridControl:_imageGrid];
}

- (void)willMountToDialogController:(id)aController
{
    [self invalidateSearch];
    [super willMountToDialogController:aController];
}

- (id)helpTopicKey
{
    return @"HSAddMovie";
}

- (id)currentMediaPathsLocation
{
    return nil;
}

- (void)restoreSelection
{
    NSUInteger pvVar1;
    NSUInteger pvVar2;
    NSUInteger pvVar3;

    pvVar2 = [_imageGrid count];
    pvVar1 = _storedGridSelection;
    if (pvVar1 != NSNotFound) {
        pvVar3 = (pvVar2 - 1);
        if (pvVar1 < pvVar2) {
            pvVar3 = pvVar1;
        }
        [_imageGrid selectItemAtIndex:pvVar3 byExtendingSelection:NO];
    }
}

- (void)storeSelection
{
    _storedGridSelection = (unsigned int)[_imageGrid selectedItemIndex];
}

- (id)paneFilePath
{
    id pvVar1_5;
    id pvVar2_3;

    if ([_imageGrid selectedItemIndex] < [[self filteredMediaPathsForKey:[self currentMediaPathsLocation]] count]) {
        pvVar2_3 = [[self filteredMediaPathsForKey:[self currentMediaPathsLocation]] objectAtIndex:[_imageGrid selectedItemIndex]];
        pvVar1_5 = [[NSFileManager defaultManager] hyperFileTypeAtPath:pvVar2_3];
        if ((pvVar2_3 != nil) && (pvVar1_5 != nil)) {
            pvVar2_3 = [HSNewMediaAccessor fullPathForMediaPath:pvVar2_3 mediaType:pvVar1_5];
        }
    }
    else {
        pvVar2_3 = nil;
    }
    return pvVar2_3;
}

- (id)supportedMediaTypes
{
    return [HSNewMediaAccessor supportedMediaTypesForClass:@"HSMovieObject"];
}

- (id)filterString
{
    return _filterString;
}

- (id)concreteMediaTypeForMovie:(id)aMovie
{
    return [[self concreteMediaTypesDictionary] objectForKey:[[NSFileManager defaultManager] hyperFileTypeAtPath:aMovie]];
}

- (void)paneDialogWillOpen
{
    [self invalidateSearch];
    [self validatePreviewMovieControls];
    [super paneDialogWillOpen];
}

- (void)paneDialogWillClose
{
    if ([self isPlaying]) {
        [self stopPreviewMovieTimer];
        [self stopPlaying];
    }
    [self setImagesForPlayButton:[self isPlaying]];
    [super paneDialogWillClose];
}

- (id)paneViewNibName
{
    return @"IDMoviesImportedPaneView";
}

- (id)paneAccessoryView
{
    [self paneView];
    return _paneAccessoryView;
}

- (id)paneView
{
    id pvVar1;

    pvVar1 = _paneView;
    if (pvVar1 == nil) {
        [NSBundle loadNibNamed:[self paneViewNibName] owner:self];
        pvVar1 = _paneView;
    }
    return pvVar1;
}

- (id)paneIdentifier
{
    return @"HSImportDialogBaseMovies";
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001da063 @ 001da063, 1260 bytes * /

void FUN_001da063(HSImportDialogMoviesPaneViewController *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  longdouble lVar3;
  float fVar4;
  double dVar5;
  double dVar6;
  
  _objc_msgSend(self->_searchField,sel_setDelegate_,self);
  _objc_msgSend(self->_imageGrid,sel_setDataSource_,self);
  _objc_msgSend(self->_imageGrid,sel_setDelegate_,self);
  _objc_msgSend(self->_imageGrid,sel_setTarget_,self);
  _objc_msgSend(self->_imageGrid,sel_setCellControlSize_,1);
  _objc_msgSend(self->_imageGrid,sel_setSelectionStyle_,3);
  _objc_msgSend(self->_imageGrid,sel_setAllowsMultipleSelection_,0);
  _objc_msgSend(self->_imageGrid,sel_setThumbnailCachingEnabled_,0);
  _objc_msgSend(self->_imageGrid,sel_setThumbnailHyphenationEnabled_,1);
  _objc_msgSend(self->_imageGrid,sel_setThreadedPreloadingEnabled_,1);
  _objc_msgSend(self->_imageGrid,sel_setExtraPasteboardDataProvidingAllowed_,0);
  pvVar1 = _objc_msgSend(self->_imageGrid,sel_scrollView);
  _objc_msgSend(pvVar1,sel_setBorderType_,0);
  _objc_msgSend(self->_imageGrid,sel_setMode_,0);
  _objc_msgSend(self->_imageGrid,sel_setThumbnailMaxTitleHeight_,0x41880000);
  _objc_msgSend(self->_imageGrid,sel_setGraphicContentShadowEnabled_,0);
  pvVar1 = _objc_msgSend(self->_imageGrid,sel_gridMatrix);
  pvVar2 = _objc_msgSend(cls_SMKGridAttributedCell,sel_class);
  _objc_msgSend(pvVar1,sel_setCellClass_,pvVar2);
  pvVar1 = _objc_msgSend(self->_imageGrid,sel_gridMatrix);
  _objc_msgSend(pvVar1,sel_setAcceptsFirstMouse_,1);
  pvVar1 = _objc_msgSend(cls_HSThumbnailManager,sel_sharedThumbnailManager);
  dVar5 = _objc_msgSend_fpret(pvVar1,sel_thumbnailSize);
  dVar6 = _objc_msgSend_fpret(self->_thumbnailSizeSlider,sel_minValue);
  fVar4 = (float)((dVar6 + dVar5) * 0.5);
  _objc_msgSend(self->_imageGrid,sel_setThumbnailSize_,fVar4,fVar4);
  _objc_msgSend(self->_imageGrid,sel_setDoubleAction_,sel_onDoubleClick_);
  self_00 = cls_NSBundle;
  pvVar1 = self->_imageGrid;
  pvVar2 = _objc_msgSend(self,sel_class);
  pvVar2 = _objc_msgSend(self_00,sel_bundleForClass_,pvVar2);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                         &cfstr_Empty_placeholderString,&cfstr_empty,&cfstr_ImportDialogs);
  _objc_msgSend(pvVar1,sel_setPlaceholderString_,pvVar2);
  _objc_msgSend(self,sel_configurePlayButton);
  pvVar2 = _objc_msgSend(self->_imageGrid,sel_thumbnailSize);
  _objc_msgSend(self->_thumbnailSizeSlider,sel_setMaxValue_,dVar5);
  pvVar1 = self->_thumbnailSizeSlider;
  lVar3 = (longdouble)_HSLinearValueForSliderFromNonLinear(pvVar1,pvVar2);
  _objc_msgSend(pvVar1,sel_setFloatValue_,(float)lVar3);
  _objc_msgSend(self->_volumeSlider,sel_setEnabled_,0);
  _objc_msgSend(self->_volumeMin,sel_setEnabled_,0);
  _objc_msgSend(self->_volumeMax,sel_setEnabled_,0);
  _objc_msgSend(self->_thumbnailSizeSlider,sel_setEnabled_,0);
  _objc_msgSend(self->_thumbnailSizeMin,sel_setEnabled_,0);
  _objc_msgSend(self->_thumbnailSizeMax,sel_setEnabled_,0);
  return;
}

*/
- (void)awakeFromNib
{
    [_searchField setDelegate:(id)self];
    [_imageGrid setDataSource:self];
    [_imageGrid setDelegate:self];
    [_imageGrid setTarget:self];
    [_imageGrid setCellControlSize:NSControlSizeSmall];
    [_imageGrid setSelectionStyle:3];
    [_imageGrid setAllowsMultipleSelection:NO];
    [_imageGrid setThumbnailCachingEnabled:NO];
    [_imageGrid setThumbnailHyphenationEnabled:YES];
    [_imageGrid setThreadedPreloadingEnabled:YES];
    [_imageGrid setExtraPasteboardDataProvidingAllowed:NO];
    [[_imageGrid scrollView] setBorderType:NSNoBorder];
    [_imageGrid setMode:0];
    [_imageGrid setThumbnailMaxTitleHeight:17.0];
    [_imageGrid setGraphicContentShadowEnabled:NO];
    [[_imageGrid gridMatrix] setCellClass:[SMKGridAttributedCell class]];
    [[_imageGrid gridMatrix] setAcceptsFirstMouse:YES];
    double thumbnailSize = [(HSThumbnailManager *)[HSThumbnailManager sharedThumbnailManager] thumbnailSize];
    float size = (float)(([_thumbnailSizeSlider minValue] + thumbnailSize) * 0.5);
    [_imageGrid setThumbnailSize:NSMakeSize(size, size)];
    [_imageGrid setDoubleAction:@selector(onDoubleClick:)];
    [_imageGrid setPlaceholderString:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Empty_placeholderString" value:@"" table:@"ImportDialogs"]];
    [self configurePlayButton];
    NSSize gridSize = [_imageGrid thumbnailSize];
    [_thumbnailSizeSlider setMaxValue:thumbnailSize];
    [_thumbnailSizeSlider setFloatValue:HSLinearValueForSliderFromNonLinear(_thumbnailSizeSlider, (float)gridSize.width)];
    [_volumeSlider setEnabled:NO];
    [_volumeMin setEnabled:NO];
    [_volumeMax setEnabled:NO];
    [_thumbnailSizeSlider setEnabled:NO];
    [_thumbnailSizeMin setEnabled:NO];
    [_thumbnailSizeMax setEnabled:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001da54f @ 001da54f, 1548 bytes * /

void FUN_001da54f(HSImportDialogMoviesPaneViewController *self,SEL _cmd)

{
  undefined *puVar1;
  id pvVar2;
  cfstringStruct *pcVar3;
  id pvVar4;
  cfstringStruct *pcVar5;
  cfstringStruct *pcVar6;
  
  puVar1 = cls_NSBundle;
  pvVar2 = _objc_msgSend(self,sel_class);
  pvVar2 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar2);
  pcVar6 = &cfstr_tiff;
  pcVar5 = &cfstr_LibraryPlayButton;
  pcVar3 = _objc_msgSend(pvVar2,sel_pathForResource_ofType_,&cfstr_LibraryPlayButton,&cfstr_tiff);
  puVar1 = cls_NSImage;
  if (pcVar3 != (cfstringStruct *)0x0) {
    pvVar2 = _objc_msgSend(self,sel_zone,pcVar5,pcVar6);
    pvVar2 = _objc_msgSend(puVar1,sel_allocWithZone_,pvVar2);
    pvVar2 = _objc_msgSend(pvVar2,sel_initWithContentsOfFile_,pcVar3);
    self->_playButtonImage = pvVar2;
    pcVar5 = pcVar3;
  }
  puVar1 = cls_NSBundle;
  pvVar2 = _objc_msgSend(self,sel_class,pcVar5,pcVar6);
  pvVar2 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar2);
  pcVar6 = &cfstr_tiff;
  pcVar5 = &cfstr_LibraryPlayButton_Aqua;
  pcVar3 = _objc_msgSend(pvVar2,sel_pathForResource_ofType_,&cfstr_LibraryPlayButton_Aqua,
                         &cfstr_tiff);
  puVar1 = cls_NSImage;
  if (pcVar3 != (cfstringStruct *)0x0) {
    pvVar2 = _objc_msgSend(self,sel_zone,pcVar5,pcVar6);
    pvVar2 = _objc_msgSend(puVar1,sel_allocWithZone_,pvVar2);
    pvVar2 = _objc_msgSend(pvVar2,sel_initWithContentsOfFile_,pcVar3);
    self->_playButtonAquaImage = pvVar2;
    pcVar5 = pcVar3;
  }
  puVar1 = cls_NSBundle;
  pvVar2 = _objc_msgSend(self,sel_class,pcVar5,pcVar6);
  pvVar2 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar2);
  pcVar6 = &cfstr_tiff;
  pcVar5 = &cfstr_LibraryPlayButton_Graphite;
  pcVar3 = _objc_msgSend(pvVar2,sel_pathForResource_ofType_,&cfstr_LibraryPlayButton_Graphite,
                         &cfstr_tiff);
  puVar1 = cls_NSImage;
  if (pcVar3 != (cfstringStruct *)0x0) {
    pvVar2 = _objc_msgSend(self,sel_zone,pcVar5,pcVar6);
    pvVar2 = _objc_msgSend(puVar1,sel_allocWithZone_,pvVar2);
    pvVar2 = _objc_msgSend(pvVar2,sel_initWithContentsOfFile_,pcVar3);
    self->_playButtonGraphiteImage = pvVar2;
    pcVar5 = pcVar3;
  }
  puVar1 = cls_NSBundle;
  pvVar2 = _objc_msgSend(self,sel_class,pcVar5,pcVar6);
  pvVar2 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar2);
  pcVar6 = &cfstr_tiff;
  pcVar5 = &cfstr_LibraryStopButton;
  pcVar3 = _objc_msgSend(pvVar2,sel_pathForResource_ofType_,&cfstr_LibraryStopButton,&cfstr_tiff);
  puVar1 = cls_NSImage;
  if (pcVar3 != (cfstringStruct *)0x0) {
    pvVar2 = _objc_msgSend(self,sel_zone,pcVar5,pcVar6);
    pvVar2 = _objc_msgSend(puVar1,sel_allocWithZone_,pvVar2);
    pvVar2 = _objc_msgSend(pvVar2,sel_initWithContentsOfFile_,pcVar3);
    self->_stopButtonImage = pvVar2;
    pcVar5 = pcVar3;
  }
  puVar1 = cls_NSBundle;
  pvVar2 = _objc_msgSend(self,sel_class,pcVar5,pcVar6);
  pvVar2 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar2);
  pcVar6 = &cfstr_tiff;
  pcVar5 = &cfstr_LibraryStopButton_Aqua;
  pcVar3 = _objc_msgSend(pvVar2,sel_pathForResource_ofType_,&cfstr_LibraryStopButton_Aqua,
                         &cfstr_tiff);
  puVar1 = cls_NSImage;
  if (pcVar3 != (cfstringStruct *)0x0) {
    pvVar2 = _objc_msgSend(self,sel_zone,pcVar5,pcVar6);
    pvVar2 = _objc_msgSend(puVar1,sel_allocWithZone_,pvVar2);
    pvVar2 = _objc_msgSend(pvVar2,sel_initWithContentsOfFile_,pcVar3);
    self->_stopButtonAquaImage = pvVar2;
    pcVar5 = pcVar3;
  }
  puVar1 = cls_NSBundle;
  pvVar2 = _objc_msgSend(self,sel_class,pcVar5,pcVar6);
  pvVar2 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar2);
  pcVar6 = &cfstr_tiff;
  pcVar5 = &cfstr_LibraryStopButton_Graphite;
  pcVar3 = _objc_msgSend(pvVar2,sel_pathForResource_ofType_,&cfstr_LibraryStopButton_Graphite,
                         &cfstr_tiff);
  puVar1 = cls_NSImage;
  if (pcVar3 != (cfstringStruct *)0x0) {
    pvVar2 = _objc_msgSend(self,sel_zone,pcVar5,pcVar6);
    pvVar2 = _objc_msgSend(puVar1,sel_allocWithZone_,pvVar2);
    pvVar2 = _objc_msgSend(pvVar2,sel_initWithContentsOfFile_,pcVar3);
    self->_stopButtonGraphiteImage = pvVar2;
    pcVar5 = pcVar3;
  }
  puVar1 = cls_HSAppearanceButtonCell;
  pvVar2 = _objc_msgSend(self,sel_zone,pcVar5,pcVar6);
  pvVar2 = _objc_msgSend(puVar1,sel_allocWithZone_,pvVar2);
  pvVar2 = _objc_msgSend(pvVar2,sel_initImageCell_,self->_playButtonImage);
  self->_playButtonCell = pvVar2;
  pvVar2 = _objc_msgSend(self->_playButton,sel_action);
  pvVar4 = _objc_msgSend(self->_playButton,sel_target);
  _objc_msgSend(self->_playButton,sel_setCell_,self->_playButtonCell);
  _objc_msgSend(self->_playButton,sel_setButtonType_,5);
  _objc_msgSend(self->_playButton,sel_setBordered_,0);
  _objc_msgSend(self->_playButton,sel_setImagePosition_,1);
  _objc_msgSend(self->_playButton,sel_setAction_,pvVar2);
  _objc_msgSend(self->_playButton,sel_setTarget_,pvVar4);
  pvVar2 = _objc_msgSend(self->_playButton,sel_cell);
  puVar1 = cls_NSBundle;
  pvVar4 = _objc_msgSend(self,sel_class);
  pvVar4 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar4);
  pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,&cfstr_Play,&cfstr_empty,
                         &cfstr_ImportDialogs);
  _objc_msgSend(pvVar2,sel_accessibilitySetOverrideValue_forAttribute_,pvVar4,
                *(undefined4 *)PTR_0033653c);
  _objc_msgSend(self,sel_setImagesForPlayButton_,0);
  return;
}

*/
- (void)configurePlayButton
{
    NSString *path;

    path = [[NSBundle bundleForClass:[self class]] pathForResource:@"LibraryPlayButton" ofType:@"tiff"];
    if (path != nil) {
        _playButtonImage = [[NSImage allocWithZone:[self zone]] initWithContentsOfFile:path];
    }
    path = [[NSBundle bundleForClass:[self class]] pathForResource:@"LibraryPlayButton_Aqua" ofType:@"tiff"];
    if (path != nil) {
        _playButtonAquaImage = [[NSImage allocWithZone:[self zone]] initWithContentsOfFile:path];
    }
    path = [[NSBundle bundleForClass:[self class]] pathForResource:@"LibraryPlayButton_Graphite" ofType:@"tiff"];
    if (path != nil) {
        _playButtonGraphiteImage = [[NSImage allocWithZone:[self zone]] initWithContentsOfFile:path];
    }
    path = [[NSBundle bundleForClass:[self class]] pathForResource:@"LibraryStopButton" ofType:@"tiff"];
    if (path != nil) {
        _stopButtonImage = [[NSImage allocWithZone:[self zone]] initWithContentsOfFile:path];
    }
    path = [[NSBundle bundleForClass:[self class]] pathForResource:@"LibraryStopButton_Aqua" ofType:@"tiff"];
    if (path != nil) {
        _stopButtonAquaImage = [[NSImage allocWithZone:[self zone]] initWithContentsOfFile:path];
    }
    path = [[NSBundle bundleForClass:[self class]] pathForResource:@"LibraryStopButton_Graphite" ofType:@"tiff"];
    if (path != nil) {
        _stopButtonGraphiteImage = [[NSImage allocWithZone:[self zone]] initWithContentsOfFile:path];
    }
    _playButtonCell = [[HSAppearanceButtonCell allocWithZone:[self zone]] initImageCell:_playButtonImage];
    SEL action = [_playButton action];
    id target = [_playButton target];
    [_playButton setCell:_playButtonCell];
    [_playButton setButtonType:NSMomentaryChangeButton];
    [_playButton setBordered:NO];
    [_playButton setImagePosition:NSImageOnly];
    [_playButton setAction:action];
    [_playButton setTarget:target];
    [[_playButton cell] accessibilitySetOverrideValue:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Play" value:@"" table:@"ImportDialogs"] forAttribute:NSAccessibilityDescriptionAttribute];
    [self setImagesForPlayButton:NO];
}

- (void)dealloc
{
    if ([_imageGrid delegate] == self) {
        [_imageGrid setDelegate:0];
    }
    if ([_imageGrid dataSource] == self) {
        [_imageGrid setDataSource:0];
    }
    [_searchField setDelegate:0];
    [_paneView release];
    [_paneAccessoryView release];
    [_filterString release];
    [_concreteMediaTypesDictionary release];
    [_invalidMoviePreviewImage release];
    [_mainThreadImage release];
    [_previewMovieTimer invalidate];
    [_previewMovieTimer release];
    [_movie stop];
    [_movie release];
    [_currentFrameImage release];
    [_playButtonImage release];
    [_playButtonAquaImage release];
    [_playButtonGraphiteImage release];
    [_stopButtonImage release];
    [_stopButtonAquaImage release];
    [_stopButtonGraphiteImage release];
    [_playButtonCell release];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001d7484 @ 001d7484, 64 bytes * /

id FUN_001d7484(HSImportDialogMoviesPaneViewController *self,SEL _cmd)

{
  id pvVar1;
  HSImportDialogMoviesPaneViewController *local_c;
  undefined *local_8;
  
  local_c = self;
  local_8 = PTR_s_HSImportDialogBasePaneViewContro_00353fc0;
  pvVar1 = _objc_msgSendSuper(&local_c,sel_init);
  if (pvVar1 != (id)0x0) {
    *(undefined4 *)((int)pvVar1 + 100) = 0x7fffffff;
  }
  return pvVar1;
}

*/
- (id)init
{
    self = [super init];
    if (self != nil) {
        _playableItemIndex = NSNotFound;
    }
    return self;
}

@end

