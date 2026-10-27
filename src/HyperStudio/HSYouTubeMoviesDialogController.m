#import "HSYouTubeMoviesDialogController.h"

@implementation HSYouTubeMoviesDialogController

/* i386 ivar offsets: _ratingControl=0x24, _videosTableView=0x28, _categoriesTableView=0x2c, _searchField=0x30, _favoritesSearchField=0x34, _sortByPopUpButton=0x38, _movieTitleTextField=0x3c, _daysCountTextField=0x40, _authorTextField=0x44, _viewsCountTextField=0x48, _durationTextField=0x4c, _descriptionTextField=0x50, _itemsCountTextField=0x54, _categoriesPlaceholderView=0x58, _moviesPlaceholderView=0x5c, _previewPlaceholderView=0x60, _youTubeMovieImageLoader=0x64, _todayButton=0x68, _thisWeekButton=0x6c, _thisMonthButton=0x70, _allTimeButton=0x74, _okButton=0x78, _scopeBackground=0x7c, _scopeControlButtons=0x80, _infoTemplate=0x84, _previewValidationTimer=0x88, _movieInfoValidationTimer=0x8c, _disablePreviewFetch=0x90, _currentTimeInterval=0x94, _webView=0x98, _favoritesTableView=0x9c, _tabView=0xa0, _segmentedControl=0xa4, _favoritesButton=0xa8, _lastSelectedSegment=0xac */

/* --- i386 decompilation (Ghidra) ---
/* FUN_00200f09 @ 00200f09, 266 bytes * /

ulonglong FUN_00200f09(HSYouTubeMoviesDialogController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  float fVar3;
  float local_10;
  
  pvVar1 = _objc_msgSend(self,sel_currentMoviesTableView);
  pvVar1 = _objc_msgSend(pvVar1,sel_selectedRow);
  local_10 = *(float *)PTR_0033607c;
  fVar3 = *(float *)(PTR_0033607c + 4);
  if (-1 < (int)pvVar1) {
    pvVar2 = _objc_msgSend(self,sel_currentDataProvider);
    pvVar2 = _objc_msgSend(pvVar2,sel_dataValueForIndex_valueCondition_,pvVar1,
                           *(undefined4 *)PTR_PTR_00336828);
    pvVar2 = _objc_msgSend(pvVar2,sel_intValue);
    self_00 = _objc_msgSend(self,sel_currentDataProvider);
    pvVar1 = _objc_msgSend(self_00,sel_dataValueForIndex_valueCondition_,pvVar1,
                           *(undefined4 *)PTR_PTR_00336800);
    local_10 = (float)(int)pvVar2;
    pvVar1 = _objc_msgSend(pvVar1,sel_intValue);
    fVar3 = (float)(int)pvVar1;
  }
  return CONCAT44(fVar3,local_10);
}

*/
- (NSSize)youTubeMovieSize
{
    NSInteger row = [[self currentMoviesTableView] selectedRow];
    if (row < 0) {
        return NSZeroSize;
    }
    int width = [[[self currentDataProvider] dataValueForIndex:row valueCondition:HSYouTubeDataWidthCondition] intValue];
    int height = [[[self currentDataProvider] dataValueForIndex:row valueCondition:HSYouTubeDataHeightCondition] intValue];
    return NSMakeSize(width, height);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00200e6f @ 00200e6f, 154 bytes * /

double FUN_00200e6f(HSYouTubeMoviesDialogController *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  double dVar2;
  
  pvVar1 = _objc_msgSend(self,sel_currentMoviesTableView);
  pvVar1 = _objc_msgSend(pvVar1,sel_selectedRow);
  if ((int)pvVar1 < 0) {
    dVar2 = 0.0;
  }
  else {
    self_00 = _objc_msgSend(self,sel_currentDataProvider);
    pvVar1 = _objc_msgSend(self_00,sel_dataValueForIndex_valueCondition_,pvVar1,
                           *(undefined4 *)PTR_PTR_003367fc);
    pvVar1 = _objc_msgSend(pvVar1,sel_intValue);
    dVar2 = (double)(int)pvVar1;
  }
  return dVar2;
}

*/
- (double)youTubeMovieDuration
{
    NSInteger row = [[self currentMoviesTableView] selectedRow];
    if (row < 0) {
        return 0.0;
    }
    return [[[self currentDataProvider] dataValueForIndex:row valueCondition:HSYouTubeDataDurationCondition] intValue];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00200dd3 @ 00200dd3, 156 bytes * /

id FUN_00200dd3(HSYouTubeMoviesDialogController *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  undefined4 uVar2;
  
  pvVar1 = _objc_msgSend(self,sel_currentMoviesTableView);
  pvVar1 = _objc_msgSend(pvVar1,sel_selectedRow);
  if (-1 < (int)pvVar1) {
    self_00 = _objc_msgSend(self,sel_currentDataProvider);
    uVar2 = *(undefined4 *)PTR_PTR_003367ec;
    pvVar1 = _objc_msgSend(self_00,sel_dataValueForIndex_valueCondition_,pvVar1,uVar2);
    if (pvVar1 != (id)0x0) {
      pvVar1 = _objc_msgSend(cls_NSURL,sel_URLWithString_,pvVar1,uVar2);
      return pvVar1;
    }
  }
  return (id)0x0;
}

*/
- (id)youTubeMovieAuthorURL
{
    NSInteger row = [[self currentMoviesTableView] selectedRow];
    if (row >= 0) {
        NSString *value = [[self currentDataProvider] dataValueForIndex:row valueCondition:HSYouTubeDataAuthorURLCondition];
        if (value != nil) {
            return [NSURL URLWithString:value];
        }
    }
    return nil;
}

- (id)youTubeMovieAuthor
{
    NSInteger pvVar1_2;
    id pvVar1_3;

    pvVar1_2 = [[self currentMoviesTableView] selectedRow];
    if ((int)pvVar1_2 < 0) {
        pvVar1_3 = nil;
    }
    else {
        pvVar1_3 = [self authorForMovieAtIndex:pvVar1_2];
    }
    return pvVar1_3;
}

- (id)youTubeMovieTitle
{
    NSInteger pvVar1_2;
    id pvVar1_3;

    pvVar1_2 = [[self currentMoviesTableView] selectedRow];
    if ((int)pvVar1_2 < 0) {
        pvVar1_3 = nil;
    }
    else {
        pvVar1_3 = [self titleForMovieAtIndex:pvVar1_2];
    }
    return pvVar1_3;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00200c83 @ 00200c83, 156 bytes * /

id FUN_00200c83(HSYouTubeMoviesDialogController *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  undefined4 uVar2;
  
  pvVar1 = _objc_msgSend(self,sel_currentMoviesTableView);
  pvVar1 = _objc_msgSend(pvVar1,sel_selectedRow);
  if (-1 < (int)pvVar1) {
    self_00 = _objc_msgSend(self,sel_currentDataProvider);
    uVar2 = *(undefined4 *)PTR_PTR_00336824;
    pvVar1 = _objc_msgSend(self_00,sel_dataValueForIndex_valueCondition_,pvVar1,uVar2);
    if (pvVar1 != (id)0x0) {
      pvVar1 = _objc_msgSend(cls_NSURL,sel_URLWithString_,pvVar1,uVar2);
      return pvVar1;
    }
  }
  return (id)0x0;
}

*/
- (id)youTubeMovieWatchURL
{
    NSInteger row = [[self currentMoviesTableView] selectedRow];
    if (row >= 0) {
        NSString *value = [[self currentDataProvider] dataValueForIndex:row valueCondition:HSYouTubeDataWatchURLCondition];
        if (value != nil) {
            return [NSURL URLWithString:value];
        }
    }
    return nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00200be7 @ 00200be7, 156 bytes * /

id FUN_00200be7(HSYouTubeMoviesDialogController *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  undefined4 uVar2;
  
  pvVar1 = _objc_msgSend(self,sel_currentMoviesTableView);
  pvVar1 = _objc_msgSend(pvVar1,sel_selectedRow);
  if (-1 < (int)pvVar1) {
    self_00 = _objc_msgSend(self,sel_currentDataProvider);
    uVar2 = *(undefined4 *)PTR_PTR_0033681c;
    pvVar1 = _objc_msgSend(self_00,sel_dataValueForIndex_valueCondition_,pvVar1,uVar2);
    if (pvVar1 != (id)0x0) {
      pvVar1 = _objc_msgSend(cls_NSURL,sel_URLWithString_,pvVar1,uVar2);
      return pvVar1;
    }
  }
  return (id)0x0;
}

*/
- (id)youTubeMovieURL
{
    NSInteger row = [[self currentMoviesTableView] selectedRow];
    if (row >= 0) {
        NSString *value = [[self currentDataProvider] dataValueForIndex:row valueCondition:HSYouTubeDataURLCondition];
        if (value != nil) {
            return [NSURL URLWithString:value];
        }
    }
    return nil;
}

- (id)youTubeMovieID
{
    NSInteger pvVar1_2;
    id pvVar1_3;

    pvVar1_2 = [[self currentMoviesTableView] selectedRow];
    if ((int)pvVar1_2 < 0) {
        pvVar1_3 = nil;
    }
    else {
        pvVar1_3 = [self UIDForMovieAtIndex:pvVar1_2];
    }
    return pvVar1_3;
}

- (void)youtubeMovieImageLoaded:(id)aLoaded
{
    [[self currentMoviesTableView] reloadData];
}

- (id)youTubeMovieImageLoader
{
    HSYouTubeMovieImageLoader *pHVar1;

    pHVar1 = _youTubeMovieImageLoader;
    if (pHVar1 == nil) {
        pHVar1 = [[HSYouTubeMovieImageLoader alloc] initWithDelegate:self];
        _youTubeMovieImageLoader = pHVar1;
    }
    return pHVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00201134 @ 00201134, 1227 bytes * /

void FUN_00201134(HSYouTubeMoviesDialogController *self,SEL _cmd)

{
  HSRatingControl *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  double dVar4;
  
  pvVar1 = _objc_msgSend(self,sel_currentMoviesTableView);
  pvVar1 = _objc_msgSend(pvVar1,sel_selectedRow);
  if (-1 < (int)pvVar1) {
    pvVar3 = pvVar1;
    pvVar2 = _objc_msgSend(self,sel_titleForMovieAtIndex_,pvVar1);
    if (pvVar2 == (id)0x0) {
      pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar3);
      pvVar2 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_HSEmptyField,
                             &cfstr_empty,&cfstr_Dialogs);
    }
    _objc_msgSend(self->_movieTitleTextField,sel_setStringValue_,pvVar2);
    pvVar3 = pvVar1;
    pvVar2 = _objc_msgSend(self,sel_addDateForMovieAtIndex_,pvVar1);
    if (pvVar2 == (id)0x0) {
      pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar3);
      pvVar2 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_HSEmptyField,
                             &cfstr_empty,&cfstr_Dialogs);
    }
    _objc_msgSend(self->_daysCountTextField,sel_setStringValue_,pvVar2);
    pvVar3 = pvVar1;
    pvVar2 = _objc_msgSend(self,sel_authorForMovieAtIndex_,pvVar1);
    if (pvVar2 == (id)0x0) {
      pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar3);
      pvVar2 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_HSEmptyField,
                             &cfstr_empty,&cfstr_Dialogs);
    }
    _objc_msgSend(self->_authorTextField,sel_setStringValue_,pvVar2);
    pvVar3 = pvVar1;
    pvVar2 = _objc_msgSend(self,sel_viewsCountForMovieAtIndex_,pvVar1);
    if (pvVar2 == (id)0x0) {
      pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar3);
      pvVar2 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_HSEmptyField,
                             &cfstr_empty,&cfstr_Dialogs);
    }
    _objc_msgSend(self->_viewsCountTextField,sel_setStringValue_,pvVar2);
    pvVar3 = _objc_msgSend(self,sel_ratingForMovieAtIndex_,pvVar1);
    self_00 = self->_ratingControl;
    if (pvVar3 == (id)0x0) {
      _objc_msgSend(self_00,sel_setHidden_,1);
    }
    else {
      dVar4 = _objc_msgSend_fpret(pvVar3,sel_floatValue);
      _objc_msgSend(self_00,sel_setRating_,(float)dVar4);
      _objc_msgSend(self->_ratingControl,sel_setHidden_,0);
      _objc_msgSend(self->_ratingControl,sel_setNeedsDisplay_,1);
    }
    pvVar3 = pvVar1;
    pvVar2 = _objc_msgSend(self,sel_lengthForMovieAtIndex_,pvVar1);
    if (pvVar2 == (id)0x0) {
      pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar3);
      pvVar2 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_HSEmptyField,
                             &cfstr_empty,&cfstr_Dialogs);
    }
    _objc_msgSend(self->_durationTextField,sel_setStringValue_,pvVar2);
    pvVar3 = pvVar1;
    pvVar2 = _objc_msgSend(self,sel_descriptionForMovieAtIndex_,pvVar1);
    if (pvVar2 == (id)0x0) {
      pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar3);
      pvVar2 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_HSEmptyField,
                             &cfstr_empty,&cfstr_Dialogs);
    }
    _objc_msgSend(self->_descriptionTextField,sel_setStringValue_,pvVar2);
    _objc_msgSend(self->_descriptionTextField,sel_setToolTip_,pvVar2);
    _objc_msgSend(self->_okButton,sel_setEnabled_,1);
    pvVar1 = _objc_msgSend(self,sel_UIDForMovieAtIndex_,pvVar1);
    if (pvVar1 != (id)0x0) {
      pvVar3 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,
                             &cfstr_http___www_youtube_com_embed___,pvVar1);
      if (pvVar3 != (id)0x0) {
        pvVar3 = _objc_msgSend(cls_NSURL,sel_URLWithString_,pvVar3,pvVar1);
        if (pvVar3 != (id)0x0) {
          pvVar2 = _objc_msgSend(cls_NSURLRequest,sel_requestWithURL_,pvVar3,pvVar1);
          if (pvVar2 != (id)0x0) {
            pvVar1 = _objc_msgSend(self->_webView,sel_mainFrame,pvVar3,pvVar1);
            _objc_msgSend(pvVar1,sel_loadRequest_,pvVar2);
          }
        }
      }
    }
  }
  return;
}

*/
- (void)updateCurrentMovieInfo
{
    NSInteger row = [[self currentMoviesTableView] selectedRow];
    if (row < 0) {
        return;
    }
    NSString *value = [self titleForMovieAtIndex:row];
    [_movieTitleTextField setStringValue:value != nil ? value : [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSEmptyField" value:@"" table:@"Dialogs"]];
    value = [self addDateForMovieAtIndex:row];
    [_daysCountTextField setStringValue:value != nil ? value : [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSEmptyField" value:@"" table:@"Dialogs"]];
    value = [self authorForMovieAtIndex:row];
    [_authorTextField setStringValue:value != nil ? value : [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSEmptyField" value:@"" table:@"Dialogs"]];
    value = [self viewsCountForMovieAtIndex:row];
    [_viewsCountTextField setStringValue:value != nil ? value : [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSEmptyField" value:@"" table:@"Dialogs"]];
    NSNumber *rating = [self ratingForMovieAtIndex:row];
    if (rating == nil) {
        [_ratingControl setHidden:YES];
    } else {
        [_ratingControl setRating:[rating floatValue]];
        [_ratingControl setHidden:NO];
        [_ratingControl setNeedsDisplay:YES];
    }
    value = [self lengthForMovieAtIndex:row];
    [_durationTextField setStringValue:value != nil ? value : [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSEmptyField" value:@"" table:@"Dialogs"]];
    value = [self descriptionForMovieAtIndex:row];
    if (value == nil) {
        value = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSEmptyField" value:@"" table:@"Dialogs"];
    }
    [_descriptionTextField setStringValue:value];
    [_descriptionTextField setToolTip:value];
    [_okButton setEnabled:YES];
    NSString *uid = [self UIDForMovieAtIndex:row];
    if (uid != nil) {
        NSURL *embedURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.youtube.com/embed/%@", uid]];
        if (embedURL != nil) {
            NSURLRequest *request = [NSURLRequest requestWithURL:embedURL];
            if (request != nil) {
                [[_webView mainFrame] loadRequest:request];
            }
        }
    }
}

- (void)invalidateMovieInfo
{
    [_movieTitleTextField setStringValue:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSEmptyField" value:@"" table:@"Dialogs"]];
    [_daysCountTextField setStringValue:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSEmptyField" value:@"" table:@"Dialogs"]];
    [_authorTextField setStringValue:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSEmptyField" value:@"" table:@"Dialogs"]];
    [_viewsCountTextField setStringValue:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSEmptyField" value:@"" table:@"Dialogs"]];
    [_ratingControl setHidden:YES];
    [_durationTextField setStringValue:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSEmptyField" value:@"" table:@"Dialogs"]];
    [_descriptionTextField setStringValue:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSEmptyField" value:@"" table:@"Dialogs"]];
}

- (id)currentCategoryTerm
{
    return [[HSYouTubeCategoryDataProvider sharedYouTubeCategoryDataProvider] categoryValueForIndex:[_categoriesTableView selectedRow] valueCondition:0];
}

- (void)updateMovieInfo:(id)aInfo
{
    [_movieInfoValidationTimer invalidate];
    [_movieInfoValidationTimer release];
    _movieInfoValidationTimer = nil;
    [self updateCurrentMovieInfo];
}

- (void)updateVisibleMoviesPreview:(id)aPreview
{
    _disablePreviewFetch = NO;
    [_previewValidationTimer invalidate];
    [_previewValidationTimer release];
    _previewValidationTimer = nil;
    [[self currentMoviesTableView] reloadData];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002005db @ 002005db, 339 bytes * /

void FUN_002005db(HSYouTubeMoviesDialogController *self,SEL _cmd,id tableViewDidScrolled)

{
  id pvVar1;
  
  _objc_msgSend(self->_previewValidationTimer,sel_invalidate);
  _objc_msgSend(self->_previewValidationTimer,sel_autorelease);
  self->_disablePreviewFetch = '\x01';
  pvVar1 = _objc_msgSend(cls_NSTimer,
                         sel_scheduledTimerWithTimeInterval_target_selector_userInfo_repeats_,0,
                         0x3fe00000,self,sel_updateVisibleMoviesPreview_,0,0);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_previewValidationTimer = pvVar1;
  pvVar1 = _objc_msgSend(cls_NSRunLoop,sel_currentRunLoop);
  _objc_msgSend(pvVar1,sel_addTimer_forMode_,self->_previewValidationTimer,
                *(undefined4 *)PTR_003361b4);
  _objc_msgSend(pvVar1,sel_addTimer_forMode_,self->_previewValidationTimer,
                *(undefined4 *)PTR_00336064);
  _objc_msgSend(pvVar1,sel_addTimer_forMode_,self->_previewValidationTimer,
                *(undefined4 *)PTR_003363f8);
  return;
}

*/
- (void)tableViewDidScrolled:(id)aScrolled
{
    [_previewValidationTimer invalidate];
    [_previewValidationTimer autorelease];
    // Previews are fetched only once scrolling settles.
    _disablePreviewFetch = YES;
    _previewValidationTimer = [[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateVisibleMoviesPreview:) userInfo:nil repeats:NO] retain];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:_previewValidationTimer forMode:NSDefaultRunLoopMode];
    [runLoop addTimer:_previewValidationTimer forMode:NSEventTrackingRunLoopMode];
    [runLoop addTimer:_previewValidationTimer forMode:NSModalPanelRunLoopMode];
}

- (void)webViewDidFinishLoad:(id)aLoad
{
    if (_youTubeMovieImageLoader != nil) {
        [_previewPlaceholderView setIsSpinning:NO];
        [_previewPlaceholderView setHidden:YES];
        [_webView setHidden:NO];
    }
}

- (void)webViewDidStartLoad:(id)aLoad
{
    id pvVar1_2;

    if (_youTubeMovieImageLoader != nil) {
        pvVar1_2 = [[NSAttributedString alloc] initWithString:@""];
        if (pvVar1_2 != nil) {
            [_previewPlaceholderView setTitle:pvVar1_2];
            [pvVar1_2 release];
        }
        [_previewPlaceholderView setHidden:NO];
        [_previewPlaceholderView setIsSpinning:YES];
        [_webView setHidden:YES];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002002d2 @ 002002d2, 430 bytes * /

void FUN_002002d2(HSYouTubeMoviesDialogController *self,SEL _cmd,id moviesLoadDidFail)

{
  HSProgressPlaceholderView *self_00;
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(cls_HSYouTubeDataProvider,sel_sharedYouTubeDataProvider);
  pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar2,sel_removeObserver_name_object_,pvVar1,*(undefined4 *)PTR_PTR_003367f4,pvVar1
               );
  pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar2,sel_removeObserver_name_object_,pvVar1,*(undefined4 *)PTR_PTR_00336808,pvVar1
               );
  _objc_msgSend(self->_moviesPlaceholderView,sel_setIsSpinning_,0);
  self_00 = self->_moviesPlaceholderView;
  pvVar1 = _objc_msgSend(cls_NSAttributedString,sel_alloc);
  pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_Load_did_fail,
                         &cfstr_empty,&cfstr_Dialogs);
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithString_,pvVar2);
  pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  _objc_msgSend(self_00,sel_setTitle_,pvVar1);
  _objc_msgSend(self->_moviesPlaceholderView,sel_setNeedsDisplay_,1);
  _objc_msgSend(self,sel_enableUI);
  return;
}

*/
- (void)moviesLoadDidFail:(id)aFail
{
    // The original removes the provider rather than self as the observer.
    id provider = [HSYouTubeDataProvider sharedYouTubeDataProvider];
    [[NSNotificationCenter defaultCenter] removeObserver:provider name:HSYouTubeDataDidLoadNotification object:provider];
    [[NSNotificationCenter defaultCenter] removeObserver:provider name:HSYouTubeDataLoadFailedNotification object:provider];
    [_moviesPlaceholderView setIsSpinning:NO];
    [_moviesPlaceholderView setTitle:[[[NSAttributedString alloc] initWithString:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Load did fail" value:@"" table:@"Dialogs"]] autorelease]];
    [_moviesPlaceholderView setNeedsDisplay:YES];
    [self enableUI];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00200085 @ 00200085, 589 bytes * /

void FUN_00200085(HSYouTubeMoviesDialogController *self,SEL _cmd,id moviesDidLoad)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar1 = _objc_msgSend(cls_HSYouTubeDataProvider,sel_sharedYouTubeDataProvider);
  pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar2,sel_removeObserver_name_object_,pvVar1,*(undefined4 *)PTR_PTR_003367f4,pvVar1
               );
  pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar2,sel_removeObserver_name_object_,pvVar1,*(undefined4 *)PTR_PTR_00336808,pvVar1
               );
  _objc_msgSend(self->_moviesPlaceholderView,sel_setIsSpinning_,0);
  _objc_msgSend(self->_moviesPlaceholderView,sel_setHidden_,1);
  _objc_msgSend(self->_videosTableView,sel_setDelegate_,self);
  pvVar1 = _objc_msgSend(self->_videosTableView,sel_enclosingScrollView);
  _objc_msgSend(pvVar1,sel_setHidden_,0);
  _objc_msgSend(self->_videosTableView,sel_setDataSource_,self);
  _objc_msgSend(self->_videosTableView,sel_reloadData);
  self_00 = cls_NSString;
  pvVar1 = self->_itemsCountTextField;
  pvVar2 = _objc_msgSend(self,sel_countOfMovies);
  pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr__d_items,&cfstr_empty,
                         &cfstr_Dialogs);
  pvVar2 = _objc_msgSend(self_00,sel_stringWithFormat_,pvVar3,pvVar2);
  _objc_msgSend(pvVar1,sel_setStringValue_,pvVar2);
  _objc_msgSend(self,sel_enableUI);
  pvVar1 = self->_favoritesButton;
  pvVar2 = _objc_msgSend(self,sel_countOfMovies);
  _objc_msgSend(pvVar1,sel_setEnabled_,(uint)(pvVar2 != (id)0x0));
  return;
}

*/
- (void)moviesDidLoad:(id)aLoad
{
    // The original removes the provider rather than self as the observer.
    id provider = [HSYouTubeDataProvider sharedYouTubeDataProvider];
    [[NSNotificationCenter defaultCenter] removeObserver:provider name:HSYouTubeDataDidLoadNotification object:provider];
    [[NSNotificationCenter defaultCenter] removeObserver:provider name:HSYouTubeDataLoadFailedNotification object:provider];
    [_moviesPlaceholderView setIsSpinning:NO];
    [_moviesPlaceholderView setHidden:YES];
    [_videosTableView setDelegate:self];
    [[_videosTableView enclosingScrollView] setHidden:NO];
    [_videosTableView setDataSource:self];
    [_videosTableView reloadData];
    [_itemsCountTextField setStringValue:[NSString stringWithFormat:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"%d items" value:@"" table:@"Dialogs"], (int)[self countOfMovies]]];
    [self enableUI];
    [_favoritesButton setEnabled:[self countOfMovies] != 0];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001fff64 @ 001fff64, 289 bytes * /

void FUN_001fff64(HSYouTubeMoviesDialogController *self,SEL _cmd,id moviesDidUpdated)

{
  id pvVar1;
  undefined *self_00;
  id pvVar2;
  id pvVar3;
  
  _objc_msgSend(self->_videosTableView,sel_reloadData);
  self_00 = cls_NSString;
  pvVar1 = self->_itemsCountTextField;
  pvVar2 = _objc_msgSend(self,sel_countOfMovies);
  pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr__d_items,&cfstr_empty,
                         &cfstr_Dialogs);
  pvVar2 = _objc_msgSend(self_00,sel_stringWithFormat_,pvVar3,pvVar2);
  _objc_msgSend(pvVar1,sel_setStringValue_,pvVar2);
  _objc_msgSend(self,sel_enableUI);
  pvVar1 = self->_favoritesButton;
  pvVar2 = _objc_msgSend(self,sel_countOfMovies);
  _objc_msgSend(pvVar1,sel_setEnabled_,(uint)(pvVar2 != (id)0x0));
  return;
}

*/
- (void)moviesDidUpdated:(id)aUpdated
{
    [_videosTableView reloadData];
    [_itemsCountTextField setStringValue:[NSString stringWithFormat:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"%d items" value:@"" table:@"Dialogs"], (int)[self countOfMovies]]];
    [self enableUI];
    [_favoritesButton setEnabled:[self countOfMovies] != 0];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ffc02 @ 001ffc02, 866 bytes * /

void FUN_001ffc02(HSYouTubeMoviesDialogController *self,SEL _cmd)

{
  int iVar1;
  id pvVar2;
  cfstringStruct *self_00;
  id self_01;
  id pvVar3;
  id pvVar4;
  cfstringStruct *pcVar5;
  
  _objc_msgSend(self,sel_disableUI);
  pvVar2 = _objc_msgSend(cls_NSAttributedString,sel_alloc);
  pcVar5 = &cfstr_empty;
  self_00 = _objc_msgSend(pvVar2,sel_initWithString_,&cfstr_empty);
  if (self_00 != (cfstringStruct *)0x0) {
    pcVar5 = self_00;
    _objc_msgSend(self->_moviesPlaceholderView,sel_setTitle_,self_00);
    _objc_msgSend(self_00,sel_release);
  }
  _objc_msgSend(self->_movieInfoValidationTimer,sel_invalidate,pcVar5);
  _objc_msgSend(self->_movieInfoValidationTimer,sel_release);
  self->_movieInfoValidationTimer = (id)0x0;
  _objc_msgSend(self->_previewValidationTimer,sel_invalidate);
  _objc_msgSend(self->_previewValidationTimer,sel_release);
  self->_previewValidationTimer = (id)0x0;
  self_01 = _objc_msgSend(cls_HSYouTubeDataProvider,sel_sharedYouTubeDataProvider);
  pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar2,sel_addObserver_selector_name_object_,self,sel_moviesDidLoad_,
                *(undefined4 *)PTR_PTR_003367f4,self_01);
  pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar2,sel_addObserver_selector_name_object_,self,sel_moviesLoadDidFail_,
                *(undefined4 *)PTR_PTR_00336808,self_01);
  pvVar2 = _objc_msgSend(self->_videosTableView,sel_enclosingScrollView);
  _objc_msgSend(pvVar2,sel_setHidden_,1);
  _objc_msgSend(self->_videosTableView,sel_setDelegate_,0);
  _objc_msgSend(self->_moviesPlaceholderView,sel_setHidden_,0);
  pvVar2 = self->_itemsCountTextField;
  pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_HSEmptyField,
                         &cfstr_empty,&cfstr_Dialogs);
  _objc_msgSend(pvVar2,sel_setStringValue_,pvVar3);
  _objc_msgSend(self->_moviesPlaceholderView,sel_setIsSpinning_,1);
  iVar1 = self->_currentTimeInterval;
  pvVar2 = _objc_msgSend(self->_sortByPopUpButton,sel_indexOfSelectedItem);
  pvVar3 = _objc_msgSend(self->_searchField,sel_stringValue);
  pvVar4 = _objc_msgSend(self,sel_currentCategoryTerm);
  _objc_msgSend(self_01,sel_provideYouTubeDataForCategory_keyWord_standardFeed_standardTime_,pvVar4,
                pvVar3,pvVar2,iVar1);
  _objc_msgSend(self->_videosTableView,sel_setDataSource_,0);
  return;
}

*/
- (void)updateMovies
{
    [self disableUI];
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:@""];
    if (title != nil) {
        [_moviesPlaceholderView setTitle:title];
        [title release];
    }
    [_movieInfoValidationTimer invalidate];
    [_movieInfoValidationTimer release];
    _movieInfoValidationTimer = nil;
    [_previewValidationTimer invalidate];
    [_previewValidationTimer release];
    _previewValidationTimer = nil;
    HSYouTubeDataProvider *provider = [HSYouTubeDataProvider sharedYouTubeDataProvider];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviesDidLoad:) name:HSYouTubeDataDidLoadNotification object:provider];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviesLoadDidFail:) name:HSYouTubeDataLoadFailedNotification object:provider];
    [[_videosTableView enclosingScrollView] setHidden:YES];
    [_videosTableView setDelegate:nil];
    [_moviesPlaceholderView setHidden:NO];
    [_itemsCountTextField setStringValue:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSEmptyField" value:@"" table:@"Dialogs"]];
    [_moviesPlaceholderView setIsSpinning:YES];
    [provider provideYouTubeDataForCategory:[self currentCategoryTerm]
                                    keyWord:[_searchField stringValue]
                               standardFeed:[_sortByPopUpButton indexOfSelectedItem]
                               standardTime:_currentTimeInterval];
    [_videosTableView setDataSource:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ffaa5 @ 001ffaa5, 349 bytes * /

id FUN_001ffaa5(HSYouTubeMoviesDialogController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(cls_HSAlert,sel_new);
  pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                         &cfstr_Cannot_connect_to_YouTube,&cfstr_empty,&cfstr_Alerts);
  _objc_msgSend(pvVar1,sel_setMessageText_,pvVar2);
  pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                         &cfstr_Make_sure_your_computer_is_connected_to_the_Inte,&cfstr_empty,
                         &cfstr_Alerts);
  _objc_msgSend(pvVar1,sel_setInformativeText_,pvVar2);
  pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_OK,&cfstr_empty,
                         &cfstr_Alerts);
  _objc_msgSend(pvVar1,sel_addButtonWithTitle_,pvVar2);
  pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  return pvVar1;
}

*/
- (id)noYouTubeConnectionAlert
{
    HSAlert *alert = [HSAlert new];
    [alert setMessageText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Cannot connect to YouTube" value:@"" table:@"Alerts"]];
    [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Make sure your computer is connected to the Internet and try again." value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"OK" value:@"" table:@"Alerts"]];
    return [alert autorelease];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ff895 @ 001ff895, 528 bytes * /

void FUN_001ff895(HSYouTubeMoviesDialogController *self,SEL _cmd,id categoriesLoadDidFail)

{
  HSProgressPlaceholderView *self_00;
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(cls_HSYouTubeCategoryDataProvider,sel_sharedYouTubeCategoryDataProvider);
  pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar2,sel_removeObserver_name_object_,pvVar1,*(undefined4 *)PTR_PTR_003367e0,pvVar1
               );
  pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar2,sel_removeObserver_name_object_,pvVar1,*(undefined4 *)PTR_PTR_003367e4,pvVar1
               );
  _objc_msgSend(self->_categoriesPlaceholderView,sel_setIsSpinning_,0);
  self_00 = self->_categoriesPlaceholderView;
  pvVar1 = _objc_msgSend(cls_NSAttributedString,sel_alloc);
  pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_Load_did_fail,
                         &cfstr_empty,&cfstr_Dialogs);
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithString_,pvVar2);
  pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  _objc_msgSend(self_00,sel_setTitle_,pvVar1);
  _objc_msgSend(self->_categoriesPlaceholderView,sel_setNeedsDisplay_,1);
  pvVar1 = _objc_msgSend(self,sel_parentWindow);
  _objc_msgSend(self,sel_finishDialog_,0);
  pvVar2 = _objc_msgSend(self,sel_noYouTubeConnectionAlert);
  _objc_msgSend(pvVar2,sel_beginSheetModalForWindow_modalDelegate_didEndSelector_contextInfo_,pvVar1
                ,0,0,0);
  return;
}

*/
- (void)categoriesLoadDidFail:(id)aFail
{
    // The original removes the provider rather than self as the observer.
    id provider = [HSYouTubeCategoryDataProvider sharedYouTubeCategoryDataProvider];
    [[NSNotificationCenter defaultCenter] removeObserver:provider name:HSYouTubeCategoryDidLoadNotification object:provider];
    [[NSNotificationCenter defaultCenter] removeObserver:provider name:HSYouTubeCategoryLoadFailedNotification object:provider];
    [_categoriesPlaceholderView setIsSpinning:NO];
    [_categoriesPlaceholderView setTitle:[[[NSAttributedString alloc] initWithString:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Load did fail" value:@"" table:@"Dialogs"]] autorelease]];
    [_categoriesPlaceholderView setNeedsDisplay:YES];
    NSWindow *parentWindow = [self parentWindow];
    [self finishDialog:0];
    [[self noYouTubeConnectionAlert] beginSheetModalForWindow:parentWindow modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ff706 @ 001ff706, 399 bytes * /

void FUN_001ff706(HSYouTubeMoviesDialogController *self,SEL _cmd,id categoriesDidLoad)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(cls_HSYouTubeCategoryDataProvider,sel_sharedYouTubeCategoryDataProvider);
  pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar2,sel_removeObserver_name_object_,pvVar1,*(undefined4 *)PTR_PTR_003367e0,pvVar1
               );
  pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar2,sel_removeObserver_name_object_,pvVar1,*(undefined4 *)PTR_PTR_003367e4,pvVar1
               );
  _objc_msgSend(self->_categoriesPlaceholderView,sel_setIsSpinning_,0);
  _objc_msgSend(self->_categoriesPlaceholderView,sel_setHidden_,1);
  pvVar1 = _objc_msgSend(self->_categoriesTableView,sel_enclosingScrollView);
  _objc_msgSend(pvVar1,sel_setHidden_,0);
  _objc_msgSend(self->_categoriesTableView,sel_setEnabled_,1);
  _objc_msgSend(self->_categoriesTableView,sel_setDelegate_,self);
  _objc_msgSend(self->_categoriesTableView,sel_setDataSource_,self);
  _objc_msgSend(self,sel_disableUI);
  _objc_msgSend(self->_categoriesTableView,sel_reloadData);
  return;
}

*/
- (void)categoriesDidLoad:(id)aLoad
{
    // The original removes the provider rather than self as the observer.
    id provider = [HSYouTubeCategoryDataProvider sharedYouTubeCategoryDataProvider];
    [[NSNotificationCenter defaultCenter] removeObserver:provider name:HSYouTubeCategoryDidLoadNotification object:provider];
    [[NSNotificationCenter defaultCenter] removeObserver:provider name:HSYouTubeCategoryLoadFailedNotification object:provider];
    [_categoriesPlaceholderView setIsSpinning:NO];
    [_categoriesPlaceholderView setHidden:YES];
    [[_categoriesTableView enclosingScrollView] setHidden:NO];
    [_categoriesTableView setEnabled:YES];
    [_categoriesTableView setDelegate:self];
    [_categoriesTableView setDataSource:self];
    [self disableUI];
    [_categoriesTableView reloadData];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ff43d @ 001ff43d, 713 bytes * /

void FUN_001ff43d(HSYouTubeMoviesDialogController *self,SEL _cmd)

{
  id self_00;
  id pvVar1;
  
  _objc_msgSend(self,sel_disableUI);
  _objc_msgSend(self->_movieInfoValidationTimer,sel_invalidate);
  _objc_msgSend(self->_movieInfoValidationTimer,sel_release);
  self->_movieInfoValidationTimer = (id)0x0;
  _objc_msgSend(self->_previewValidationTimer,sel_invalidate);
  _objc_msgSend(self->_previewValidationTimer,sel_release);
  self->_previewValidationTimer = (id)0x0;
  _objc_msgSend(self->_categoriesTableView,sel_setDelegate_,0);
  _objc_msgSend(self->_categoriesTableView,sel_setDataSource_,0);
  self_00 = _objc_msgSend(cls_HSYouTubeCategoryDataProvider,sel_sharedYouTubeCategoryDataProvider);
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar1,sel_addObserver_selector_name_object_,self,sel_categoriesDidLoad_,
                *(undefined4 *)PTR_PTR_003367e0,self_00);
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar1,sel_addObserver_selector_name_object_,self,sel_categoriesLoadDidFail_,
                *(undefined4 *)PTR_PTR_003367e4,self_00);
  pvVar1 = _objc_msgSend(self->_categoriesTableView,sel_enclosingScrollView);
  _objc_msgSend(pvVar1,sel_setHidden_,1);
  pvVar1 = _objc_msgSend(cls_NSAttributedString,sel_alloc);
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithString_,&cfstr_empty);
  if (pvVar1 != (id)0x0) {
    _objc_msgSend(self->_categoriesPlaceholderView,sel_setTitle_,pvVar1);
    _objc_msgSend(pvVar1,sel_release);
  }
  _objc_msgSend(self->_categoriesPlaceholderView,sel_setHidden_,0);
  _objc_msgSend(self->_categoriesPlaceholderView,sel_setIsSpinning_,1);
  _objc_msgSend(self->_moviesPlaceholderView,sel_setHidden_,0);
  _objc_msgSend(self->_moviesPlaceholderView,sel_setIsSpinning_,1);
  _objc_msgSend(self_00,sel_loadCategories);
  return;
}

*/
- (void)beginCategoriesUpdate
{
    [self disableUI];
    [_movieInfoValidationTimer invalidate];
    [_movieInfoValidationTimer release];
    _movieInfoValidationTimer = nil;
    [_previewValidationTimer invalidate];
    [_previewValidationTimer release];
    _previewValidationTimer = nil;
    [_categoriesTableView setDelegate:nil];
    [_categoriesTableView setDataSource:nil];
    HSYouTubeCategoryDataProvider *provider = [HSYouTubeCategoryDataProvider sharedYouTubeCategoryDataProvider];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(categoriesDidLoad:) name:HSYouTubeCategoryDidLoadNotification object:provider];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(categoriesLoadDidFail:) name:HSYouTubeCategoryLoadFailedNotification object:provider];
    [[_categoriesTableView enclosingScrollView] setHidden:YES];
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:@""];
    if (title != nil) {
        [_categoriesPlaceholderView setTitle:title];
        [title release];
    }
    [_categoriesPlaceholderView setHidden:NO];
    [_categoriesPlaceholderView setIsSpinning:YES];
    [_moviesPlaceholderView setHidden:NO];
    [_moviesPlaceholderView setIsSpinning:YES];
    [provider loadCategories];
}

- (void)enableUI
{
    [_categoriesTableView setEnabled:YES];
    [_sortByPopUpButton setEnabled:YES];
    [_todayButton setEnabled:YES];
    [_thisWeekButton setEnabled:YES];
    [_thisMonthButton setEnabled:YES];
    [_allTimeButton setEnabled:YES];
    [_segmentedControl setEnabled:YES];
    [_favoritesButton setEnabled:YES];
}

- (void)disableUI
{
    [_categoriesTableView setEnabled:NO];
    [_sortByPopUpButton setEnabled:NO];
    [_todayButton setEnabled:NO];
    [_thisWeekButton setEnabled:NO];
    [_thisMonthButton setEnabled:NO];
    [_allTimeButton setEnabled:NO];
    [_okButton setEnabled:NO];
    [_segmentedControl setEnabled:NO];
    [_favoritesButton setEnabled:NO];
}

- (void)validateScopeButtons
{
    NSEnumerator *self_00;
    id self_01;

    self_00 = [_scopeControlButtons objectEnumerator];
    self_01 = [self_00 nextObject];
    while (self_01 != nil) {
        [self_01 setState:(unsigned int)([self_01 tag] == _currentTimeInterval)];
        self_01 = [self_00 nextObject];
    }
}

- (NSUInteger)countOfMovies
{
    return (unsigned int)[[self currentDataProvider] numberOfDataItems];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ff0df @ 001ff0df, 77 bytes * /

id FUN_001ff0df(HSYouTubeMoviesDialogController *self,SEL _cmd,uint URLForMovieAtIndex)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_currentDataProvider);
  pvVar1 = _objc_msgSend(pvVar1,sel_dataValueForIndex_valueCondition_,URLForMovieAtIndex,
                         *(undefined4 *)PTR_PTR_00336814);
  return pvVar1;
}

*/
- (id)URLForMovieAtIndex:(NSUInteger)aIndex
{
    return [[self currentDataProvider] dataValueForIndex:aIndex valueCondition:HSYouTubeDataThumbnailURLCondition];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ff092 @ 001ff092, 77 bytes * /

id FUN_001ff092(HSYouTubeMoviesDialogController *self,SEL _cmd,uint UIDForMovieAtIndex)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_currentDataProvider);
  pvVar1 = _objc_msgSend(pvVar1,sel_dataValueForIndex_valueCondition_,UIDForMovieAtIndex,
                         *(undefined4 *)PTR_PTR_00336804);
  return pvVar1;
}

*/
- (id)UIDForMovieAtIndex:(NSUInteger)aIndex
{
    return [[self currentDataProvider] dataValueForIndex:aIndex valueCondition:HSYouTubeDataIDCondition];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ff045 @ 001ff045, 77 bytes * /

id FUN_001ff045(HSYouTubeMoviesDialogController *self,SEL _cmd,uint authorForMovieAtIndex)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_currentDataProvider);
  pvVar1 = _objc_msgSend(pvVar1,sel_dataValueForIndex_valueCondition_,authorForMovieAtIndex,
                         *(undefined4 *)PTR_PTR_003367e8);
  return pvVar1;
}

*/
- (id)authorForMovieAtIndex:(NSUInteger)aIndex
{
    return [[self currentDataProvider] dataValueForIndex:aIndex valueCondition:HSYouTubeDataAuthorCondition];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001fee2b @ 001fee2b, 538 bytes * /

id FUN_001fee2b(HSYouTubeMoviesDialogController *self,SEL _cmd,uint addDateForMovieAtIndex)

{
  id pvVar1;
  id pvVar2;
  cfstringStruct *pcVar3;
  cfstringStruct *pcVar4;
  undefined4 uVar5;
  id local_14;
  
  pvVar1 = _objc_msgSend(self,sel_currentDataProvider);
  uVar5 = *(undefined4 *)PTR_PTR_0033680c;
  local_14 = _objc_msgSend(pvVar1,sel_dataValueForIndex_valueCondition_,addDateForMovieAtIndex,uVar5
                          );
  if (local_14 == (id)0x0) {
    return (id)0x0;
  }
  pcVar3 = &cfstr_Z;
  pvVar1 = _objc_msgSend(local_14,sel_hasSuffix_,&cfstr_Z,uVar5);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(local_14,sel_length,pcVar3,uVar5);
    if (pvVar1 < (id)0x3) {
      return (id)0x0;
    }
    pcVar3 = (cfstringStruct *)((int)pvVar1 + -3);
    uVar5 = 1;
    pvVar1 = _objc_msgSend(local_14,sel_substringWithRange_,pcVar3,1);
    pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_,&cfstr__);
    if ((char)pvVar1 == '\0') {
      return (id)0x0;
    }
    local_14 = _objc_msgSend(cls_NSMutableString,sel_stringWithString_,local_14,uVar5);
    if (local_14 == (id)0x0) {
      return (id)0x0;
    }
    uVar5 = 1;
    _objc_msgSend(local_14,sel_deleteCharactersInRange_,pcVar3,1);
    pcVar4 = &cfstr__Y__m__dT_H__M__S__F_z;
  }
  else {
    pcVar4 = &cfstr__Y__m__dT_H__M__S__FZ;
  }
  pvVar1 = _objc_msgSend(cls_NSDateFormatter,sel_alloc,pcVar3,uVar5);
  uVar5 = 0;
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithDateFormat_allowNaturalLanguage_,pcVar4,0);
  pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(cls_NSDateFormatter,sel_alloc,pcVar4,uVar5);
    uVar5 = 0;
    pvVar2 = _objc_msgSend(pvVar2,sel_initWithDateFormat_allowNaturalLanguage_,
                           &cfstr__m__d__y__H__M__S,0);
    pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
    if ((pvVar2 != (id)0x0) &&
       (pvVar1 = _objc_msgSend(pvVar1,sel_dateFromString_,local_14,uVar5), pvVar1 != (id)0x0)) {
      pvVar1 = _objc_msgSend(pvVar2,sel_stringFromDate_,pvVar1,uVar5);
      return pvVar1;
    }
  }
  return (id)0x0;
}

*/
- (id)addDateForMovieAtIndex:(NSUInteger)aIndex
{
    NSString *published = [[self currentDataProvider] dataValueForIndex:aIndex valueCondition:HSYouTubeDataPublishedDateCondition];
    if (published == nil) {
        return nil;
    }
    // The original used the 10.0-style strftime formats "%Y-%m-%dT%H:%M:%S.%FZ" / "...%F%z" and
    // "%m.%d.%y %H:%M:%S"; these are their ICU equivalents.
    NSString *inputFormat;
    BOOL isUTC = [published hasSuffix:@"Z"];
    if (isUTC) {
        inputFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    } else {
        // "+01:00" -> "+0100"
        NSUInteger length = [published length];
        if (length < 3) {
            return nil;
        }
        NSRange colon = NSMakeRange(length - 3, 1);
        if (![[published substringWithRange:colon] isEqualToString:@":"]) {
            return nil;
        }
        NSMutableString *trimmed = [NSMutableString stringWithString:published];
        if (trimmed == nil) {
            return nil;
        }
        [trimmed deleteCharactersInRange:colon];
        published = trimmed;
        inputFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
    }
    NSLocale *posix = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
    NSDateFormatter *parser = [[[NSDateFormatter alloc] init] autorelease];
    [parser setLocale:posix];
    [parser setDateFormat:inputFormat];
    if (isUTC) {
        // Fix: the literal Z means UTC; the 10.0 formatter read it as local time.
        [parser setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }
    NSDateFormatter *printer = [[[NSDateFormatter alloc] init] autorelease];
    [printer setLocale:posix];
    [printer setDateFormat:@"MM.dd.yy HH:mm:ss"];
    NSDate *date = [parser dateFromString:published];
    if (date == nil) {
        return nil;
    }
    return [printer stringFromDate:date];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001fed6b @ 001fed6b, 192 bytes * /

id FUN_001fed6b(HSYouTubeMoviesDialogController *self,SEL _cmd,uint infoDictionaryForMovieAtIndex)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  self_00 = cls_NSDictionary;
  pvVar1 = _objc_msgSend(self,sel_lengthForMovieAtIndex_,infoDictionaryForMovieAtIndex);
  pvVar2 = _objc_msgSend(self,sel_viewsCountForMovieAtIndex_,infoDictionaryForMovieAtIndex);
  pvVar3 = _objc_msgSend(self,sel_ratingForMovieAtIndex_,infoDictionaryForMovieAtIndex);
  pvVar1 = _objc_msgSend(self_00,sel_dictionaryWithObjectsAndKeys_,pvVar3,
                         *(undefined4 *)PTR_PTR_003367d8,pvVar2,*(undefined4 *)PTR_PTR_003367dc,
                         pvVar1,*(undefined4 *)PTR_PTR_003367d4,0);
  return pvVar1;
}

*/
- (id)infoDictionaryForMovieAtIndex:(NSUInteger)aIndex
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [self ratingForMovieAtIndex:aIndex], HSRatingKey,
            [self viewsCountForMovieAtIndex:aIndex], HSViewsCountKey,
            [self lengthForMovieAtIndex:aIndex], HSMovieLengthKey,
            nil];
}

- (id)previewForMovieWithUid:(id)aUid URL:(id)aURL
{
    id pvVar1_2;

    pvVar1_2 = [[self youTubeMovieImageLoader] previewImageForYouTubeMovieImageUID:aUid];
    if (pvVar1_2 == nil) {
        pvVar1_2 = [HSPlayerBaseID imageNamed:@"YouTubeObjectIcon"];
        if (_disablePreviewFetch == NO) {
            [[self youTubeMovieImageLoader] requestImageForYouTubeMovieImageUID:aUid URL:[NSURL URLWithString:aURL]];
        }
    }
    return pvVar1_2;
}

- (id)previewForMovieAtIndex:(NSUInteger)aIndex
{
    return [self previewForMovieWithUid:[self UIDForMovieAtIndex:aIndex] URL:[self URLForMovieAtIndex:aIndex]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001feb33 @ 001feb33, 256 bytes * /

id FUN_001feb33(HSYouTubeMoviesDialogController *self,SEL _cmd,uint viewsCountForMovieAtIndex)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  int iVar4;
  int iVar5;
  
  pvVar1 = _objc_msgSend(self,sel_currentDataProvider);
  iVar4 = *(int *)PTR_PTR_00336820;
  pvVar1 = _objc_msgSend(pvVar1,sel_dataValueForIndex_valueCondition_,viewsCountForMovieAtIndex,
                         iVar4);
  pvVar1 = _objc_msgSend(pvVar1,sel_mutableCopy);
  pvVar2 = _objc_msgSend(pvVar1,sel_length);
  if ((id)0x3 < pvVar2) {
    pvVar2 = (id)0x3;
    iVar5 = -3;
    do {
      pvVar3 = _objc_msgSend(pvVar1,sel_length,viewsCountForMovieAtIndex,iVar4);
      iVar4 = (int)pvVar3 + iVar5;
      viewsCountForMovieAtIndex = (uint)&cfstr__;
      _objc_msgSend(pvVar1,sel_insertString_atIndex_);
      iVar5 = iVar5 + -4;
      pvVar2 = (id)((int)pvVar2 + 4);
      pvVar3 = _objc_msgSend(pvVar1,sel_length);
    } while (pvVar2 < pvVar3);
  }
  pvVar1 = _objc_msgSend(pvVar1,sel_autorelease,viewsCountForMovieAtIndex,iVar4);
  return pvVar1;
}

*/
- (id)viewsCountForMovieAtIndex:(NSUInteger)aIndex
{
    NSMutableString *views = [[[self currentDataProvider] dataValueForIndex:aIndex valueCondition:HSYouTubeDataViewCountCondition] mutableCopy];
    // Group the digits in threes from the right: 1234567 -> 1,234,567.
    NSUInteger digits = 3;
    NSInteger offset = -3;
    while (digits < [views length]) {
        [views insertString:@"," atIndex:[views length] + offset];
        offset -= 4;
        digits += 4;
    }
    return [views autorelease];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002015ff @ 002015ff, 141 bytes * /

id FUN_002015ff(HSYouTubeMoviesDialogController *self,SEL _cmd,uint ratingForMovieAtIndex)

{
  id pvVar1;
  double dVar2;
  
  pvVar1 = _objc_msgSend(self,sel_currentDataProvider);
  pvVar1 = _objc_msgSend(pvVar1,sel_dataValueForIndex_valueCondition_,ratingForMovieAtIndex,
                         *(undefined4 *)PTR_PTR_00336810);
  dVar2 = _objc_msgSend_fpret(pvVar1,sel_floatValue);
  pvVar1 = _objc_msgSend(cls_NSNumber,sel_numberWithFloat_,(float)dVar2 / 5.0);
  return pvVar1;
}

*/
- (id)ratingForMovieAtIndex:(NSUInteger)aIndex
{
    float rating = [[[self currentDataProvider] dataValueForIndex:aIndex valueCondition:HSYouTubeDataRatingCondition] floatValue];
    return [NSNumber numberWithFloat:rating / 5.0f];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001fea7a @ 001fea7a, 185 bytes * /

id FUN_001fea7a(HSYouTubeMoviesDialogController *self,SEL _cmd,uint lengthForMovieAtIndex)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_currentDataProvider);
  pvVar1 = _objc_msgSend(pvVar1,sel_dataValueForIndex_valueCondition_,lengthForMovieAtIndex,
                         *(undefined4 *)PTR_PTR_003367fc);
  pvVar1 = _objc_msgSend(pvVar1,sel_intValue);
  pvVar1 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr___2d___2d,
                         ((int)pvVar1 - (int)pvVar1 % 0x3c) / 0x3c,(int)pvVar1 % 0x3c);
  return pvVar1;
}

*/
- (id)lengthForMovieAtIndex:(NSUInteger)aIndex
{
    int seconds = [[[self currentDataProvider] dataValueForIndex:aIndex valueCondition:HSYouTubeDataDurationCondition] intValue];
    return [NSString stringWithFormat:@"%.2d:%.2d", (seconds - seconds % 60) / 60, seconds % 60];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001fe893 @ 001fe893, 487 bytes * /

id FUN_001fe893(HSYouTubeMoviesDialogController *self,SEL _cmd,uint textForMovieAtIndex)

{
  undefined *puVar1;
  id pvVar2;
  id self_00;
  id pvVar3;
  id pvVar4;
  cfstringStruct *pcVar5;
  int extraout_EDX;
  int extraout_EDX_00;
  cfstringStruct *pcVar6;
  
  pvVar2 = _objc_msgSend(self->_infoTemplate,sel_string);
  self_00 = _objc_msgSend(self->_infoTemplate,sel_mutableCopy);
  pvVar3 = _objc_msgSend(pvVar2,sel_rangeOfString_,&cfstr__HSYouTubeVideoDescription_);
  if ((pvVar3 != (id)0x7fffffff) && (extraout_EDX != 0)) {
    pvVar4 = _objc_msgSend(self,sel_descriptionForMovieAtIndex_,textForMovieAtIndex);
    _objc_msgSend(self_00,sel_replaceCharactersInRange_withString_,pvVar3,extraout_EDX,pvVar4);
  }
  pcVar6 = &cfstr__HSYouTubeVideoTitle_;
  pcVar5 = _objc_msgSend(pvVar2,sel_rangeOfString_,&cfstr__HSYouTubeVideoTitle_);
  puVar1 = PTR_00336150;
  if ((pcVar5 != (cfstringStruct *)0x7fffffff) && (extraout_EDX_00 != 0)) {
    pvVar2 = _objc_msgSend(self_00,sel_attribute_atIndex_effectiveRange_,*(undefined4 *)PTR_00336150
                           ,pcVar5,0);
    pvVar2 = _objc_msgSend(pvVar2,sel_mutableCopy);
    _objc_msgSend(pvVar2,sel_setLineBreakMode_,4);
    _objc_msgSend(self_00,sel_addAttribute_value_range_,*(undefined4 *)puVar1,pvVar2,pcVar5,
                  extraout_EDX_00);
    _objc_msgSend(pvVar2,sel_release);
    pvVar2 = _objc_msgSend(self,sel_titleForMovieAtIndex_,textForMovieAtIndex);
    _objc_msgSend(self_00,sel_replaceCharactersInRange_withString_,pcVar5,extraout_EDX_00,pvVar2);
    pcVar6 = pcVar5;
  }
  pvVar2 = _objc_msgSend(self_00,sel_autorelease,pcVar6);
  return pvVar2;
}

*/
- (id)textForMovieAtIndex:(NSUInteger)aIndex
{
    NSString *template = [_infoTemplate string];
    NSMutableAttributedString *text = [_infoTemplate mutableCopy];
    NSRange range = [template rangeOfString:@"<HSYouTubeVideoDescription>"];
    if (range.location != NSNotFound && range.length != 0) {
        [text replaceCharactersInRange:range withString:[self descriptionForMovieAtIndex:aIndex]];
    }
    // The title range comes from the unmodified template, so the title must precede the description in it.
    range = [template rangeOfString:@"<HSYouTubeVideoTitle>"];
    if (range.location != NSNotFound && range.length != 0) {
        NSMutableParagraphStyle *style = [[text attribute:NSParagraphStyleAttributeName atIndex:range.location effectiveRange:NULL] mutableCopy];
        [style setLineBreakMode:NSLineBreakByTruncatingTail];
        [text addAttribute:NSParagraphStyleAttributeName value:style range:range];
        [style release];
        [text replaceCharactersInRange:range withString:[self titleForMovieAtIndex:aIndex]];
    }
    return [text autorelease];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001fe846 @ 001fe846, 77 bytes * /

id FUN_001fe846(HSYouTubeMoviesDialogController *self,SEL _cmd,uint descriptionForMovieAtIndex)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_currentDataProvider);
  pvVar1 = _objc_msgSend(pvVar1,sel_dataValueForIndex_valueCondition_,descriptionForMovieAtIndex,
                         *(undefined4 *)PTR_PTR_003367f0);
  return pvVar1;
}

*/
- (id)descriptionForMovieAtIndex:(NSUInteger)aIndex
{
    return [[self currentDataProvider] dataValueForIndex:aIndex valueCondition:HSYouTubeDataDescriptionCondition];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001fe7f9 @ 001fe7f9, 77 bytes * /

id FUN_001fe7f9(HSYouTubeMoviesDialogController *self,SEL _cmd,uint titleForMovieAtIndex)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_currentDataProvider);
  pvVar1 = _objc_msgSend(pvVar1,sel_dataValueForIndex_valueCondition_,titleForMovieAtIndex,
                         *(undefined4 *)PTR_PTR_00336818);
  return pvVar1;
}

*/
- (id)titleForMovieAtIndex:(NSUInteger)aIndex
{
    return [[self currentDataProvider] dataValueForIndex:aIndex valueCondition:HSYouTubeDataTitleCondition];
}

- (void)searchInFavorites:(id)aFavorites
{
    [[HSYouTubeFavoritesDataProvider sharedYouTubeFavoritesDataProvider] provideDataItemsForSearchString:[aFavorites stringValue]];
    [[self currentMoviesTableView] reloadData];
}

- (void)showHelp:(id)aHelp
{
    [[HSHelpBookManager sharedHelpBookManager] openHelpTopic:@"HSYouTubeDialog"];
}

- (void)timeIntervalDidChange:(id)aChange
{
    _currentTimeInterval = (int)[aChange tag];
    [self validateScopeButtons];
    [self updateMovies];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001fe511 @ 001fe511, 457 bytes * /

void FUN_001fe511(HSYouTubeMoviesDialogController *self,SEL _cmd,id switchTo)

{
  undefined *self_00;
  id pvVar1;
  SEL op;
  id pvVar2;
  id pvVar3;
  
  pvVar1 = _objc_msgSend(self->_segmentedControl,sel_selectedSegment);
  if (pvVar1 != (id)self->_lastSelectedSegment) {
    self->_lastSelectedSegment = (int)pvVar1;
    pvVar2 = pvVar1;
    _objc_msgSend(self->_tabView,sel_selectTabViewItemAtIndex_,pvVar1);
    _objc_msgSend(self,sel_invalidateMovieInfo);
    op = sel_switchToYouTube;
    if (pvVar1 != (id)0x0) {
      _objc_msgSend(self->_favoritesSearchField,sel_setStringValue_,&cfstr_empty);
      pvVar2 = self->_favoritesSearchField;
      _objc_msgSend(self,sel_searchInFavorites_,pvVar2);
      op = sel_switchToFavorites;
    }
    _objc_msgSend(self,op,pvVar2);
    pvVar1 = _objc_msgSend(self,sel_currentMoviesTableView);
    _objc_msgSend(pvVar1,sel_reloadData);
    self_00 = cls_NSString;
    pvVar1 = self->_itemsCountTextField;
    pvVar2 = _objc_msgSend(self,sel_countOfMovies);
    pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr__d_items,
                           &cfstr_empty,&cfstr_Dialogs);
    pvVar2 = _objc_msgSend(self_00,sel_stringWithFormat_,pvVar3,pvVar2);
    _objc_msgSend(pvVar1,sel_setStringValue_,pvVar2);
    pvVar1 = self->_favoritesButton;
    pvVar2 = _objc_msgSend(self,sel_countOfMovies);
    _objc_msgSend(pvVar1,sel_setEnabled_,(uint)(pvVar2 != (id)0x0));
  }
  return;
}

*/
- (void)switchTo:(id)aTo
{
    NSInteger segment = [_segmentedControl selectedSegment];
    if (segment == _lastSelectedSegment) {
        return;
    }
    _lastSelectedSegment = (int)segment;
    [_tabView selectTabViewItemAtIndex:segment];
    [self invalidateMovieInfo];
    if (segment != 0) {
        [_favoritesSearchField setStringValue:@""];
        [self searchInFavorites:_favoritesSearchField];
        [self switchToFavorites];
    } else {
        [self switchToYouTube];
    }
    [[self currentMoviesTableView] reloadData];
    [_itemsCountTextField setStringValue:[NSString stringWithFormat:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"%d items" value:@"" table:@"Dialogs"], (int)[self countOfMovies]]];
    [_favoritesButton setEnabled:[self countOfMovies] != 0];
}

- (void)search:(id)aSearch
{
    [self updateMovies];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001fe369 @ 001fe369, 386 bytes * /

void FUN_001fe369(HSYouTubeMoviesDialogController *self,SEL _cmd,id addToFavorites)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_currentDataProvider);
  pvVar1 = _objc_msgSend(pvVar1,sel_numberOfDataItems);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(self->_segmentedControl,sel_selectedSegment);
    pvVar1 = _objc_msgSend(cls_HSYouTubeFavoritesDataProvider,sel_sharedYouTubeFavoritesDataProvider
                          );
    if (pvVar2 == (id)0x0) {
      pvVar2 = _objc_msgSend(cls_HSYouTubeDataProvider,sel_sharedYouTubeDataProvider);
      pvVar3 = _objc_msgSend(self,sel_currentMoviesTableView);
      pvVar3 = _objc_msgSend(pvVar3,sel_selectedRow);
      pvVar2 = _objc_msgSend(pvVar2,sel_allInformationForIndex_,pvVar3);
      op = sel_addItem_;
    }
    else {
      pvVar2 = _objc_msgSend(self,sel_currentMoviesTableView);
      pvVar2 = _objc_msgSend(pvVar2,sel_selectedRow);
      _objc_msgSend(pvVar1,sel_removeItemAtIndex_,pvVar2);
      pvVar1 = _objc_msgSend(self,sel_currentMoviesTableView);
      _objc_msgSend(pvVar1,sel_reloadData);
      pvVar1 = self->_favoritesButton;
      pvVar2 = _objc_msgSend(self,sel_countOfMovies);
      pvVar2 = (id)(uint)(pvVar2 != (id)0x0);
      op = sel_setEnabled_;
    }
    _objc_msgSend(pvVar1,op,pvVar2);
  }
  return;
}

*/
- (void)addToFavorites:(id)aFavorites
{
    if ([[self currentDataProvider] numberOfDataItems] == 0) {
        return;
    }
    HSYouTubeFavoritesDataProvider *favorites = [HSYouTubeFavoritesDataProvider sharedYouTubeFavoritesDataProvider];
    if ([_segmentedControl selectedSegment] == 0) {
        [favorites addItem:[[HSYouTubeDataProvider sharedYouTubeDataProvider] allInformationForIndex:[[self currentMoviesTableView] selectedRow]]];
    } else {
        // In the favorites tab the same button removes the selected movie.
        [favorites removeItemAtIndex:[[self currentMoviesTableView] selectedRow]];
        [[self currentMoviesTableView] reloadData];
        [_favoritesButton setEnabled:[self countOfMovies] != 0];
    }
}

- (void)sortTypeDidChange:(id)aChange
{
    [self updateMovies];
}

- (BOOL)selectionShouldChangeInTableView:(id)aView
{
    return (BOOL)[aView isEnabled];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001fe19d @ 001fe19d, 381 bytes * /

void FUN_001fe19d(HSYouTubeMoviesDialogController *self,SEL _cmd,id tableViewSelectionDidChange)

{
  id pvVar1;
  HSYouTubeMoviesDialogController *self_00;
  SEL op;
  
  pvVar1 = _objc_msgSend(tableViewSelectionDidChange,sel_object);
  op = sel_updateMovies;
  if (pvVar1 != self->_categoriesTableView) {
    _objc_msgSend(self->_movieInfoValidationTimer,sel_invalidate);
    _objc_msgSend(self->_movieInfoValidationTimer,sel_autorelease);
    pvVar1 = _objc_msgSend(cls_NSTimer,
                           sel_scheduledTimerWithTimeInterval_target_selector_userInfo_repeats_,0,
                           0x3fe00000,self,sel_updateMovieInfo_,0,0);
    pvVar1 = _objc_msgSend(pvVar1,sel_retain);
    self->_movieInfoValidationTimer = pvVar1;
    self_00 = _objc_msgSend(cls_NSRunLoop,sel_currentRunLoop);
    _objc_msgSend(self_00,sel_addTimer_forMode_,self->_movieInfoValidationTimer,
                  *(undefined4 *)PTR_003361b4);
    _objc_msgSend(self_00,sel_addTimer_forMode_,self->_movieInfoValidationTimer,
                  *(undefined4 *)PTR_00336064);
    self = self_00;
    op = sel_addTimer_forMode_;
  }
  _objc_msgSend(self,op);
  return;
}

*/
- (void)tableViewSelectionDidChange:(id)aChange
{
    if ([aChange object] == _categoriesTableView) {
        [self updateMovies];
        return;
    }
    [_movieInfoValidationTimer invalidate];
    [_movieInfoValidationTimer autorelease];
    _movieInfoValidationTimer = [[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateMovieInfo:) userInfo:nil repeats:NO] retain];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:_movieInfoValidationTimer forMode:NSDefaultRunLoopMode];
    [runLoop addTimer:_movieInfoValidationTimer forMode:NSEventTrackingRunLoopMode];
    [runLoop addTimer:_movieInfoValidationTimer forMode:NSModalPanelRunLoopMode];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001fe067 @ 001fe067, 310 bytes * /

id FUN_001fe067(HSYouTubeMoviesDialogController *self,SEL _cmd,id tableView,
               id objectValueForTableColumn,int row)

{
  id pvVar1;
  SEL op;
  cfstringStruct *pcVar2;
  
  if (self->_categoriesTableView == tableView) {
    self = _objc_msgSend(cls_HSYouTubeCategoryDataProvider,sel_sharedYouTubeCategoryDataProvider);
    op = sel_categoryValueForIndex_valueCondition_;
  }
  else {
    pvVar1 = _objc_msgSend(objectValueForTableColumn,sel_identifier);
    pcVar2 = &cfstr_HSYouTubePreviewIdentifier;
    pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_,&cfstr_HSYouTubePreviewIdentifier);
    op = sel_previewForMovieAtIndex_;
    if ((char)pvVar1 == '\0') {
      pvVar1 = _objc_msgSend(objectValueForTableColumn,sel_identifier,pcVar2);
      pcVar2 = &cfstr_HSYouTubeRatingIdentifier;
      pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_,&cfstr_HSYouTubeRatingIdentifier);
      op = sel_infoDictionaryForMovieAtIndex_;
      if ((char)pvVar1 == '\0') {
        pvVar1 = _objc_msgSend(objectValueForTableColumn,sel_identifier,pcVar2);
        pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_,&cfstr_HSYouTubeDescriptionIdentifier);
        op = sel_textForMovieAtIndex_;
        if ((char)pvVar1 == '\0') {
          return (id)0x0;
        }
      }
    }
  }
  pvVar1 = _objc_msgSend(self,op,row);
  return pvVar1;
}

*/
- (id)tableView:(id)aView objectValueForTableColumn:(id)aColumn row:(NSInteger)aRow
{
    if (aView == _categoriesTableView) {
        return [[HSYouTubeCategoryDataProvider sharedYouTubeCategoryDataProvider] categoryValueForIndex:aRow valueCondition:0];
    }
    NSString *identifier = [aColumn identifier];
    if ([identifier isEqualToString:@"HSYouTubePreviewIdentifier"]) {
        return [self previewForMovieAtIndex:aRow];
    }
    if ([identifier isEqualToString:@"HSYouTubeRatingIdentifier"]) {
        return [self infoDictionaryForMovieAtIndex:aRow];
    }
    if ([identifier isEqualToString:@"HSYouTubeDescriptionIdentifier"]) {
        return [self textForMovieAtIndex:aRow];
    }
    return nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001fe010 @ 001fe010, 87 bytes * /

int FUN_001fe010(HSYouTubeMoviesDialogController *self,SEL _cmd,id numberOfRowsInTableView)

{
  id pvVar1;
  SEL op;
  
  op = sel_countOfMovies;
  if (self->_categoriesTableView == numberOfRowsInTableView) {
    self = _objc_msgSend(cls_HSYouTubeCategoryDataProvider,sel_sharedYouTubeCategoryDataProvider);
    op = sel_numberOfCategories;
  }
  pvVar1 = _objc_msgSend(self,op);
  return (int)pvVar1;
}

*/
- (NSInteger)numberOfRowsInTableView:(id)aView
{
    if (aView == _categoriesTableView) {
        return [[HSYouTubeCategoryDataProvider sharedYouTubeCategoryDataProvider] numberOfCategories];
    }
    return [self countOfMovies];
}

- (void)switchToYouTube
{
    [_favoritesTableView setDataSource:0];
    [_videosTableView setDataSource:self];
    [_favoritesButton setTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Add to Favorites" value:@"" table:@"Dialogs"]];
}

- (void)switchToFavorites
{
    [_favoritesTableView setDataSource:self];
    [_videosTableView setDataSource:0];
    [_favoritesButton setTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Remove from Favorites" value:@"" table:@"Dialogs"]];
}

- (id)currentMoviesTableView
{
    id *ppvVar2;

    if ([_segmentedControl selectedSegment] == 0) {
        ppvVar2 = &_videosTableView;
    }
    else {
        ppvVar2 = &_favoritesTableView;
    }
    return *ppvVar2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001fde0b @ 001fde0b, 92 bytes * /

id FUN_001fde0b(HSYouTubeMoviesDialogController *self,SEL _cmd)

{
  id pvVar1;
  undefined *self_00;
  SEL op;
  
  pvVar1 = _objc_msgSend(self->_segmentedControl,sel_selectedSegment);
  self_00 = cls_HSYouTubeFavoritesDataProvider;
  op = sel_sharedYouTubeFavoritesDataProvider;
  if (pvVar1 == (id)0x0) {
    self_00 = cls_HSYouTubeDataProvider;
    op = sel_sharedYouTubeDataProvider;
  }
  pvVar1 = _objc_msgSend(self_00,op);
  return pvVar1;
}

*/
- (id)currentDataProvider
{
    if ([_segmentedControl selectedSegment] == 0) {
        return [HSYouTubeDataProvider sharedYouTubeDataProvider];
    }
    return [HSYouTubeFavoritesDataProvider sharedYouTubeFavoritesDataProvider];
}

- (id)nibName
{
    return @"YouTubeDialog";
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001fdcb2 @ 001fdcb2, 345 bytes * /

void FUN_001fdcb2(HSYouTubeMoviesDialogController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  
  _objc_msgSend(self->_movieInfoValidationTimer,sel_invalidate);
  _objc_msgSend(self->_movieInfoValidationTimer,sel_release);
  self->_movieInfoValidationTimer = (id)0x0;
  _objc_msgSend(self->_previewValidationTimer,sel_invalidate);
  _objc_msgSend(self->_previewValidationTimer,sel_release);
  self->_previewValidationTimer = (id)0x0;
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  pvVar2 = _objc_msgSend(cls_HSYouTubeDataProvider,sel_sharedYouTubeDataProvider);
  _objc_msgSend(pvVar1,sel_removeObserver_name_object_,self,*(undefined4 *)PTR_PTR_003367f8,pvVar2);
  _objc_msgSend(self->_youTubeMovieImageLoader,sel_cancelAllRequests);
  _objc_msgSend(self->_youTubeMovieImageLoader,sel_autorelease);
  self->_youTubeMovieImageLoader = (HSYouTubeMovieImageLoader *)0x0;
  pvVar1 = _objc_msgSend(self->_webView,sel_mainFrame);
  _objc_msgSend(pvVar1,sel_stopLoading);
  _objc_msgSend(self->_webView,sel_close);
  return;
}

*/
- (void)willCloseWindow
{
    [_movieInfoValidationTimer invalidate];
    [_movieInfoValidationTimer release];
    _movieInfoValidationTimer = nil;
    [_previewValidationTimer invalidate];
    [_previewValidationTimer release];
    _previewValidationTimer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HSYouTubeDataDidUpdatedNotification object:[HSYouTubeDataProvider sharedYouTubeDataProvider]];
    [_youTubeMovieImageLoader cancelAllRequests];
    [_youTubeMovieImageLoader autorelease];
    _youTubeMovieImageLoader = nil;
    [[_webView mainFrame] stopLoading];
    [_webView close];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001fdbbc @ 001fdbbc, 246 bytes * /

void FUN_001fdbbc(HSYouTubeMoviesDialogController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  
  _objc_msgSend(self,sel_beginCategoriesUpdate);
  _objc_msgSend(self,sel_invalidateMovieInfo);
  pvVar1 = _objc_msgSend(self->_videosTableView,sel_enclosingScrollView);
  _objc_msgSend(pvVar1,sel_setHidden_,1);
  _objc_msgSend(self->_moviesPlaceholderView,sel_setIsSpinning_,1);
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  pvVar2 = _objc_msgSend(cls_HSYouTubeDataProvider,sel_sharedYouTubeDataProvider);
  _objc_msgSend(pvVar1,sel_addObserver_selector_name_object_,self,sel_moviesDidUpdated_,
                *(undefined4 *)PTR_PTR_003367f8,pvVar2);
  return;
}

*/
- (void)willShowWindow
{
    [self beginCategoriesUpdate];
    [self invalidateMovieInfo];
    [[_videosTableView enclosingScrollView] setHidden:YES];
    [_moviesPlaceholderView setIsSpinning:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviesDidUpdated:) name:HSYouTubeDataDidUpdatedNotification object:[HSYouTubeDataProvider sharedYouTubeDataProvider]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001fd3ea @ 001fd3ea, 2002 bytes * /

void FUN_001fd3ea(HSYouTubeMoviesDialogController *self,SEL _cmd)

{
  HSRatingControl *pHVar1;
  undefined *puVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  id pvVar8;
  undefined4 uVar9;
  
  pHVar1 = self->_ratingControl;
  pvVar3 = _objc_msgSend(cls_NSImage,sel_imageNamed_,&cfstr_rating_star_off);
  _objc_msgSend(pHVar1,sel_setPointDimmedImage_,pvVar3);
  pHVar1 = self->_ratingControl;
  pvVar3 = _objc_msgSend(cls_NSImage,sel_imageNamed_,&cfstr_rating_star);
  _objc_msgSend(pHVar1,sel_setPointImage_,pvVar3);
  _objc_msgSend(self->_ratingControl,sel_setPointCount_,5);
  pvVar3 = _objc_msgSend(self->_videosTableView,sel_tableColumns);
  pvVar3 = _objc_msgSend(pvVar3,sel_objectAtIndex_,2);
  pvVar4 = _objc_msgSend(cls_HSYouTubeRatingCell,sel_alloc);
  pvVar4 = _objc_msgSend(pvVar4,sel_init);
  pvVar4 = _objc_msgSend(pvVar4,sel_autorelease);
  _objc_msgSend(pvVar3,sel_setDataCell_,pvVar4);
  pvVar3 = _objc_msgSend(self->_favoritesTableView,sel_tableColumns);
  pvVar3 = _objc_msgSend(pvVar3,sel_objectAtIndex_,2);
  _objc_msgSend(pvVar3,sel_setDataCell_,pvVar4);
  pvVar3 = _objc_msgSend(self->_videosTableView,sel_tableColumns);
  pvVar3 = _objc_msgSend(pvVar3,sel_objectAtIndex_,1);
  pvVar4 = _objc_msgSend(cls_HSYouTubeMovieDescriptionCell,sel_alloc);
  pvVar4 = _objc_msgSend(pvVar4,sel_init);
  pvVar4 = _objc_msgSend(pvVar4,sel_autorelease);
  _objc_msgSend(pvVar3,sel_setDataCell_,pvVar4);
  pvVar3 = self->_descriptionTextField;
  pvVar5 = _objc_msgSend(pvVar4,sel_copy);
  pvVar5 = _objc_msgSend(pvVar5,sel_autorelease);
  _objc_msgSend(pvVar3,sel_setCell_,pvVar5);
  pvVar3 = _objc_msgSend(self->_favoritesTableView,sel_tableColumns);
  pvVar3 = _objc_msgSend(pvVar3,sel_objectAtIndex_,1);
  _objc_msgSend(pvVar3,sel_setDataCell_,pvVar4);
  pvVar6 = _objc_msgSend(cls_NSArray,sel_alloc);
  pvVar3 = self->_todayButton;
  pvVar4 = self->_thisWeekButton;
  pvVar5 = self->_thisMonthButton;
  pvVar8 = self->_allTimeButton;
  uVar9 = 0;
  pvVar6 = _objc_msgSend(pvVar6,sel_initWithObjects_,pvVar3,pvVar4,pvVar5,pvVar8,0);
  self->_scopeControlButtons = pvVar6;
  self->_currentTimeInterval = 0;
  pvVar6 = _objc_msgSend(pvVar6,sel_objectEnumerator);
  pvVar7 = _objc_msgSend(cls_HSSystem,sel_sharedSystem);
  pvVar7 = _objc_msgSend(pvVar7,sel_isLeopardOrGreater);
  if ((char)pvVar7 == '\0') {
    pvVar4 = _objc_msgSend(pvVar6,sel_nextObject,pvVar3,pvVar4,pvVar5,pvVar8,uVar9);
    puVar2 = cls_NSCell;
    while (cls_NSCell = puVar2, pvVar4 != (id)0x0) {
      pvVar3 = _objc_msgSend(pvVar4,sel_cell,pvVar3);
      pvVar5 = _objc_msgSend(cls_HSScopeButtonCell,sel_class);
      pvVar3 = _objc_msgSend(puVar2,sel_hyperCellOfClass_withCell_,pvVar5,pvVar3);
      _objc_msgSend(pvVar3,sel_setBezelStyle_,0xd);
      _objc_msgSend(pvVar3,sel_setShowsBorderOnlyWhileMouseInside_,1);
      _objc_msgSend(pvVar4,sel_setCell_);
      pvVar4 = _objc_msgSend(pvVar6,sel_nextObject);
      puVar2 = cls_NSCell;
    }
  }
  pvVar3 = self->_scopeBackground;
  pvVar4 = _objc_msgSend(cls_NSImage,sel_imageNamed_,&cfstr_yt_scope_image);
  _objc_msgSend(pvVar3,sel_setImage_,pvVar4);
  _objc_msgSend(self,sel_validateScopeButtons);
  pvVar3 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar4 = _objc_msgSend(&cfstr_youtube_template_rtf,sel_pathExtension);
  pvVar5 = _objc_msgSend(&cfstr_youtube_template_rtf,sel_stringByDeletingPathExtension);
  pvVar3 = _objc_msgSend(pvVar3,sel_pathForResource_ofType_,pvVar5,pvVar4);
  pvVar4 = _objc_msgSend(cls_NSAttributedString,sel_alloc);
  pvVar3 = _objc_msgSend(pvVar4,sel_initWithPath_documentAttributes_,pvVar3,0);
  self->_infoTemplate = pvVar3;
  pvVar3 = _objc_msgSend(self->_videosTableView,sel_enclosingScrollView);
  pvVar3 = _objc_msgSend(pvVar3,sel_contentView);
  _objc_msgSend(pvVar3,sel_setPostsBoundsChangedNotifications_,1);
  pvVar4 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  puVar2 = PTR_00336574;
  _objc_msgSend(pvVar4,sel_addObserver_selector_name_object_,self,sel_tableViewDidScrolled_,
                *(undefined4 *)PTR_00336574,pvVar3);
  pvVar3 = _objc_msgSend(self->_favoritesTableView,sel_enclosingScrollView);
  pvVar3 = _objc_msgSend(pvVar3,sel_contentView);
  _objc_msgSend(pvVar3,sel_setPostsBoundsChangedNotifications_,1);
  pvVar4 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar4,sel_addObserver_selector_name_object_,self,sel_tableViewDidScrolled_,
                *(undefined4 *)puVar2,pvVar3);
  _objc_msgSend(self->_favoritesTableView,sel_setDelegate_,self);
  _objc_msgSend(self->_categoriesPlaceholderView,sel_setHidden_,1);
  _objc_msgSend(self->_moviesPlaceholderView,sel_setHidden_,1);
  _objc_msgSend(self->_okButton,sel_setEnabled_,0);
  _objc_msgSend(self->_videosTableView,sel_setDoubleAction_,sel_ok_);
  pvVar3 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar3,sel_addObserver_selector_name_object_,self,sel_webViewDidStartLoad_,
                *(undefined4 *)PTR_00336830,self->_webView);
  pvVar3 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar3,sel_addObserver_selector_name_object_,self,sel_webViewDidFinishLoad_,
                *(undefined4 *)PTR_0033682c,self->_webView);
  return;
}

*/
- (void)didLoadNib
{
    [_ratingControl setPointDimmedImage:[NSImage imageNamed:@"rating_star_off"]];
    [_ratingControl setPointImage:[NSImage imageNamed:@"rating_star"]];
    [_ratingControl setPointCount:5];
    // Both tables share the same cell instances.
    HSYouTubeRatingCell *ratingCell = [[[HSYouTubeRatingCell alloc] init] autorelease];
    [[[_videosTableView tableColumns] objectAtIndex:2] setDataCell:ratingCell];
    [[[_favoritesTableView tableColumns] objectAtIndex:2] setDataCell:ratingCell];
    HSYouTubeMovieDescriptionCell *descriptionCell = [[[HSYouTubeMovieDescriptionCell alloc] init] autorelease];
    [[[_videosTableView tableColumns] objectAtIndex:1] setDataCell:descriptionCell];
    [_descriptionTextField setCell:[[descriptionCell copy] autorelease]];
    [[[_favoritesTableView tableColumns] objectAtIndex:1] setDataCell:descriptionCell];
    _scopeControlButtons = [[NSArray alloc] initWithObjects:_todayButton, _thisWeekButton, _thisMonthButton, _allTimeButton, nil];
    _currentTimeInterval = 0;
    if (![[HSSystem sharedSystem] isLeopardOrGreater]) {
        // Pre-Leopard: emulate the recessed scope buttons.
        for (NSButton *button in _scopeControlButtons) {
            NSButtonCell *cell = [NSCell hyperCellOfClass:[HSScopeButtonCell class] withCell:[button cell]];
            [cell setBezelStyle:NSBezelStyleRecessed];
            [cell setShowsBorderOnlyWhileMouseInside:YES];
            [button setCell:cell];
        }
    }
    [_scopeBackground setImage:[NSImage imageNamed:@"yt_scope_image"]];
    [self validateScopeButtons];
    NSString *templateName = @"youtube_template.rtf";
    NSString *templatePath = [[NSBundle mainBundle] pathForResource:[templateName stringByDeletingPathExtension] ofType:[templateName pathExtension]];
    _infoTemplate = [[NSAttributedString alloc] initWithPath:templatePath documentAttributes:NULL];
    NSClipView *clipView = [[_videosTableView enclosingScrollView] contentView];
    [clipView setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableViewDidScrolled:) name:NSViewBoundsDidChangeNotification object:clipView];
    clipView = [[_favoritesTableView enclosingScrollView] contentView];
    [clipView setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableViewDidScrolled:) name:NSViewBoundsDidChangeNotification object:clipView];
    [_favoritesTableView setDelegate:self];
    [_categoriesPlaceholderView setHidden:YES];
    [_moviesPlaceholderView setHidden:YES];
    [_okButton setEnabled:NO];
    [_videosTableView setDoubleAction:@selector(ok:)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewDidStartLoad:) name:WebViewProgressStartedNotification object:_webView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewDidFinishLoad:) name:WebViewProgressFinishedNotification object:_webView];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_infoTemplate release];
    [_previewValidationTimer invalidate];
    [_previewValidationTimer release];
    [_movieInfoValidationTimer invalidate];
    [_movieInfoValidationTimer release];
    [_scopeControlButtons release];
    [_youTubeMovieImageLoader cancelAllRequests];
    [_youTubeMovieImageLoader release];
    [super dealloc];
}

@end

