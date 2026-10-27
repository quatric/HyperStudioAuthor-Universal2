#import "HSWebcamWorkshopController.h"

static NSString *sPixelSizeFormat;
static NSString *sOneSecondString;
static NSString *sSecondsFormat;
static NSString *sOneMinuteString;
static NSString *sMinutesFormat;
static NSString *sImmediatelyString;

static id HSWebcamWorkshopRootItem(NSDictionary *aCache)
{
    NSArray *keys = [aCache allKeys];
    NSUInteger index = [keys indexOfObjectIdenticalTo:@"0"];
    return index != NSNotFound ? [keys objectAtIndex:index] : nil;
}

static NSTimer *HSWebcamWorkshopScheduleTimer(NSTimeInterval anInterval, id aTarget, SEL aSelector)
{
    NSTimer *timer = [[NSTimer scheduledTimerWithTimeInterval:anInterval target:aTarget selector:aSelector userInfo:nil repeats:NO] retain];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
    [runLoop addTimer:timer forMode:NSEventTrackingRunLoopMode];
    [runLoop addTimer:timer forMode:NSModalPanelRunLoopMode];
    return timer;
}

@implementation HSWebcamWorkshopController

/* i386 ivar offsets: _delegate=0x4, _sheetPanel=0x8, _segmentedControl=0xc, _confirmButton=0x10, _cancelButton=0x14, _filterField=0x18, _filterRulesMenu=0x1c, _sheetPanelTitleTextField=0x20, _splitView=0x24, _outlineView=0x28, _webCamContainerView=0x2c, _webCamContainerViewCounterTextField=0x30, _webCamInfoNameTextField=0x34, _webCamInfoExactLocationTextField=0x38, _webCamInfoGeneralLocationTextField=0x3c, _webCamInfoFrameRateTextField=0x40, _webCamInfoSizeTextField=0x44, _webCamInfoTimeTextField=0x48, _webCamInfoCopyrightTextField=0x4c, _webCamPreviewView=0x50, _addToFavouritesButton=0x54, _categoryItemsCache=0x58, _selectedCamIDs=0x5c, _shortInfoTemplate=0x60, _webCamContainerViewFrame=0x64, _outlineSelectionChangeTimer=0x74, _webCamViewSelectionChangeTimer=0x78, _webCamViewScrollTimer=0x7c, _webCamViewVisibleCams=0x80, _webCamImageLoader=0x84, _placeholderView=0x88, _currentFilterRuleTag=0x8c */

- (void)performReportError:(id)aError
{
    if (_sheetPanel != nil) {
        if ([_sheetPanel isVisible]) {
            [NSApp endSheet:_sheetPanel returnCode:0];
        }
    }
    [[HSErrorManager sharedErrorManager] presentError:aError];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00162e9d @ 00162e9d, 71 bytes * /

void FUN_00162e9d(HSWebcamWorkshopController *self,SEL _cmd,id reportError)

{
  _objc_msgSend(self,sel_performSelector_withObject_afterDelay_,sel_performReportError_,reportError,
                0,0x3fe00000);
  return;
}

*/
- (void)reportError:(id)aError
{
    [self performSelector:@selector(performReportError:) withObject:aError afterDelay:0.5];
}

- (id)applicationSupportFolder
{
    id pvVar1;
    id pvVar1_2;

    pvVar1 = NSSearchPathForDirectoriesInDomains(0xe,2,1);
    if ([pvVar1 count] == 0) {
        pvVar1_2 = NSTemporaryDirectory();
    }
    else {
        pvVar1_2 = [pvVar1 objectAtIndex:0];
    }
    return [pvVar1_2 stringByAppendingPathComponent:@"Software MacKiev/WebCam Collection"];
}

- (void)webcamImageLoaded:(id)aLoaded
{
    [_webCamContainerView reloadData];
}

- (id)webCamImageLoader
{
    id pvVar1;

    pvVar1 = _webCamImageLoader;
    if (pvVar1 == nil) {
        pvVar1 = [[HSWebCamImageLoader alloc] initWithDelegate:self];
        _webCamImageLoader = pvVar1;
    }
    return pvVar1;
}

- (id)tableView:(id)aView toolTipForCell:(id)aCell rect:(NSRect *)aRect tableColumn:(id)aColumn row:(NSInteger)aRow mouseLocation:(NSPoint)aLocation
{
    if ([[aColumn identifier] isEqualToString:@"info"]) {
        if (![[HSSystem sharedSystem] isLeopardOrGreater]) {
            return [[self tableView:_webCamContainerView objectValueForTableColumn:aColumn row:aRow] string];
        }
    }
    return nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00163234 @ 00163234, 1377 bytes * /

id FUN_00163234(HSWebcamWorkshopController *self,SEL _cmd,id tableView,id objectValueForTableColumn,
               int row)

{
  id pvVar1;
  id pvVar2;
  HSWebcamWorkshopController *self_00;
  int iVar3;
  int iVar4;
  undefined *extraout_EDX;
  undefined *extraout_EDX_00;
  SEL op;
  cfstringStruct *pcVar5;
  cfstringStruct *pcVar6;
  cfstringStruct *pcVar7;
  cfstringStruct local_f8;
  id local_e8;
  id local_e4;
  cfstringStruct *local_e0;
  cfstringStruct *local_dc;
  cfstringStruct *local_d8;
  cfstringStruct *local_d4;
  cfstringStruct *local_d0;
  int local_cc [22];
  int local_74 [22];
  int local_1c;
  id local_18;
  HSWebcamWorkshopController *local_14;
  
  local_14 = self;
  local_18 = objectValueForTableColumn;
  local_1c = row;
  local_d0 = _objc_msgSend(self->_selectedCamIDs,sel_objectAtIndex_,row);
  pvVar1 = _objc_msgSend(local_18,sel_identifier);
  pcVar5 = &cfstr_preview;
  pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_,&cfstr_preview);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(local_14,sel_webCamImageLoader,pcVar5);
    pvVar1 = _objc_msgSend(pvVar1,sel_previewImageForWebCamUID_,local_d0);
    return pvVar1;
  }
  local_d4 = (cfstringStruct *)0x0;
  local_d8 = (cfstringStruct *)0x0;
  local_dc = local_d0;
  if (local_d0 == (cfstringStruct *)0x0) {
    local_dc = &cfstr_0;
  }
  pcVar5 = local_dc;
  local_e0 = _objc_msgSend(local_14->_categoryItemsCache,sel_objectForKey_,local_dc);
  if (local_e0 == (cfstringStruct *)0x0) {
    pvVar1 = _objc_msgSend(cls_HSWebCamDataProvider,sel_sharedWebCamDataProvider,pcVar5);
    pvVar2 = _objc_msgSend(cls_NSArray,sel_arrayWithObjects_,&cfstr_camDescriptionString,&cfstr_name
                           ,0);
    local_f8.field0_0x0 = 0;
    pcVar7 = &local_f8;
    pcVar6 = local_d0;
    pvVar1 = _objc_msgSend(pvVar1,sel_attributes_forWebCam_error_,pvVar2,local_d0,pcVar7);
    self_00 = local_14;
    op = sel_reportError_;
    pcVar5 = (cfstringStruct *)local_f8.field0_0x0;
    if ((cfstringStruct *)local_f8.field0_0x0 == (cfstringStruct *)0x0) {
      local_d4 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_camDescriptionString,pcVar6,pcVar7);
      local_d8 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_name);
      pcVar7 = local_d4;
      local_e0 = _objc_msgSend(cls_NSDictionary,sel_dictionaryWithObjectsAndKeys_,local_d8,
                               &cfstr_HSWCCacheCategoryItemName,local_d4,
                               &cfstr_HSWCCacheCategoryItemDescription,0);
      self_00 = local_14->_categoryItemsCache;
      op = sel_setObject_forKey_;
      pcVar5 = local_e0;
      pcVar6 = local_d0;
    }
    _objc_msgSend(self_00,op,pcVar5,pcVar6,pcVar7);
  }
  else {
    local_d8 = _objc_msgSend(local_e0,sel_objectForKey_,&cfstr_HSWCCacheCategoryItemName);
    pcVar5 = &cfstr_HSWCCacheCategoryItemDescription;
    local_d4 = _objc_msgSend(local_e0,sel_objectForKey_,&cfstr_HSWCCacheCategoryItemDescription);
  }
  if (local_d4 == (cfstringStruct *)0x0) {
    local_d4 = &cfstr_empty;
  }
  if (local_d8 == (cfstringStruct *)0x0) {
    local_d8 = &cfstr_empty;
  }
  pvVar1 = _objc_msgSend(local_14->_shortInfoTemplate,sel_mutableCopy,pcVar5);
  local_e4 = _objc_msgSend(pvVar1,sel_autorelease);
  local_e8 = _objc_msgSend(local_e4,sel_string);
  local_f8.field1_0x4 = 0x7fffffff;
  local_f8.field2_0x8 = (undefined *)0x0;
  _objc_exception_try_enter(local_cc);
  iVar3 = __setjmp(local_cc);
  if (iVar3 == 0) {
    local_f8.field1_0x4 = (dword)_objc_msgSend(local_e8,sel_rangeOfString_,&cfstr__cam_name_);
    local_f8.field2_0x8 = extraout_EDX;
  }
  else {
    iVar4 = _objc_exception_extract(local_cc);
    _objc_exception_try_enter(local_cc);
    iVar3 = __setjmp(local_cc);
    if (iVar3 == 0) {
      iVar3 = _objc_exception_match(cls_NSException,iVar4);
      if (iVar3 != 0) goto LAB_00163611;
      _objc_exception_try_exit(local_cc);
    }
    else {
      iVar4 = _objc_exception_extract(local_cc);
    }
    if (iVar4 != 0) {
                    /* WARNING: Subroutine does not return * /
      _objc_exception_throw(iVar4);
    }
  }
LAB_00163611:
  _objc_exception_try_exit(local_cc);
  if (((id)local_f8.field1_0x4 != (id)0x7fffffff) && (local_f8.field2_0x8 != (undefined *)0x0)) {
    _objc_msgSend(local_e4,sel_replaceCharactersInRange_withString_,local_f8.field1_0x4,
                  local_f8.field2_0x8,local_d8);
  }
  _objc_exception_try_enter(local_74);
  iVar3 = __setjmp(local_74);
  if (iVar3 == 0) {
    local_f8.field1_0x4 =
         (dword)_objc_msgSend(local_e8,sel_rangeOfString_,&cfstr__cam_rich_text_description_);
    local_f8.field2_0x8 = extraout_EDX_00;
  }
  else {
    iVar4 = _objc_exception_extract(local_74);
    _objc_exception_try_enter(local_74);
    iVar3 = __setjmp(local_74);
    if (iVar3 == 0) {
      iVar3 = _objc_exception_match(cls_NSException,iVar4);
      if (iVar3 != 0) goto LAB_001636cb;
      _objc_exception_try_exit(local_74);
    }
    else {
      iVar4 = _objc_exception_extract(local_74);
    }
    if (iVar4 != 0) {
                    /* WARNING: Subroutine does not return * /
      _objc_exception_throw(iVar4);
    }
  }
LAB_001636cb:
  _objc_exception_try_exit(local_74);
  if (((id)local_f8.field1_0x4 != (id)0x7fffffff) && (local_f8.field2_0x8 != (undefined *)0x0)) {
    _objc_msgSend(local_e4,sel_replaceCharactersInRange_withString_,local_f8.field1_0x4,
                  local_f8.field2_0x8,local_d4);
  }
  return local_e4;
}

*/
- (id)tableView:(id)aView objectValueForTableColumn:(id)aColumn row:(NSInteger)aRow
{
    id camID = [_selectedCamIDs objectAtIndex:aRow];
    id description = nil;
    id name = nil;

    if ([[aColumn identifier] isEqualToString:@"preview"]) {
        return [[self webCamImageLoader] previewImageForWebCamUID:camID];
    }
    id key = camID != nil ? camID : @"0";
    id cached = [_categoryItemsCache objectForKey:key];
    if (cached == nil) {
        NSError *error = nil;
        id attributes = [[HSWebCamDataProvider sharedWebCamDataProvider] attributes:[NSArray arrayWithObjects:@"camDescriptionString", @"name", nil] forWebCam:camID error:&error];
        if (error == nil) {
            description = [attributes objectForKey:@"camDescriptionString"];
            name = [attributes objectForKey:@"name"];
            cached = [NSDictionary dictionaryWithObjectsAndKeys:name, @"HSWCCacheCategoryItemName", description, @"HSWCCacheCategoryItemDescription", nil];
            [_categoryItemsCache setObject:cached forKey:camID];
        }
        else {
            [self reportError:error];
        }
    }
    else {
        name = [cached objectForKey:@"HSWCCacheCategoryItemName"];
        description = [cached objectForKey:@"HSWCCacheCategoryItemDescription"];
    }
    if (description == nil) {
        description = @"";
    }
    if (name == nil) {
        name = @"";
    }
    NSMutableAttributedString *info = [[_shortInfoTemplate mutableCopy] autorelease];
    NSRange range = [[info string] rangeOfString:@"<cam name>"];
    if (range.location != NSNotFound && range.length != 0) {
        [info replaceCharactersInRange:range withString:name];
    }
    range = [[info string] rangeOfString:@"<cam rich text description>"];
    if (range.location != NSNotFound && range.length != 0) {
        [info replaceCharactersInRange:range withString:description];
    }
    return info;
}

- (NSInteger)numberOfRowsInTableView:(id)aView
{
    NSUInteger pvVar1;

    if (_selectedCamIDs == nil) {
        pvVar1 = 0;
    }
    else {
        pvVar1 = [_selectedCamIDs count];
    }
    return (int)pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00162bfb @ 00162bfb, 314 bytes * /

void FUN_00162bfb(HSWebcamWorkshopController *self,SEL _cmd,id tableViewDidScrolled)

{
  id pvVar1;
  
  _objc_msgSend(self->_webCamViewScrollTimer,sel_invalidate);
  _objc_msgSend(self->_webCamViewScrollTimer,sel_autorelease);
  pvVar1 = _objc_msgSend(cls_NSTimer,
                         sel_scheduledTimerWithTimeInterval_target_selector_userInfo_repeats_,0,
                         0x3fe00000,self,sel_updatePreviewImagesForVisibleWebCams_,0,0);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_webCamViewScrollTimer = pvVar1;
  pvVar1 = _objc_msgSend(cls_NSRunLoop,sel_currentRunLoop);
  _objc_msgSend(pvVar1,sel_addTimer_forMode_,self->_webCamViewScrollTimer,
                *(undefined4 *)PTR_003361b4);
  _objc_msgSend(pvVar1,sel_addTimer_forMode_,self->_webCamViewScrollTimer,
                *(undefined4 *)PTR_00336064);
  _objc_msgSend(pvVar1,sel_addTimer_forMode_,self->_webCamViewScrollTimer,
                *(undefined4 *)PTR_003363f8);
  return;
}

*/
- (void)tableViewDidScrolled:(id)aScrolled
{
    [_webCamViewScrollTimer invalidate];
    [_webCamViewScrollTimer autorelease];
    _webCamViewScrollTimer = HSWebcamWorkshopScheduleTimer(1.0, self, @selector(updatePreviewImagesForVisibleWebCams:));
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00162ac1 @ 00162ac1, 314 bytes * /

void FUN_00162ac1(HSWebcamWorkshopController *self,SEL _cmd,id tableViewSelectionDidChange)

{
  id pvVar1;
  
  _objc_msgSend(self->_webCamViewSelectionChangeTimer,sel_invalidate);
  _objc_msgSend(self->_webCamViewSelectionChangeTimer,sel_autorelease);
  pvVar1 = _objc_msgSend(cls_NSTimer,
                         sel_scheduledTimerWithTimeInterval_target_selector_userInfo_repeats_,
                         0x33333333,0x3fd33333,self,sel_redisplayInfo_,0,0);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_webCamViewSelectionChangeTimer = pvVar1;
  pvVar1 = _objc_msgSend(cls_NSRunLoop,sel_currentRunLoop);
  _objc_msgSend(pvVar1,sel_addTimer_forMode_,self->_webCamViewSelectionChangeTimer,
                *(undefined4 *)PTR_003361b4);
  _objc_msgSend(pvVar1,sel_addTimer_forMode_,self->_webCamViewSelectionChangeTimer,
                *(undefined4 *)PTR_00336064);
  _objc_msgSend(pvVar1,sel_addTimer_forMode_,self->_webCamViewSelectionChangeTimer,
                *(undefined4 *)PTR_003363f8);
  return;
}

*/
- (void)tableViewSelectionDidChange:(id)aChange
{
    [_webCamViewSelectionChangeTimer invalidate];
    [_webCamViewSelectionChangeTimer autorelease];
    _webCamViewSelectionChangeTimer = HSWebcamWorkshopScheduleTimer(0.3, self, @selector(redisplayInfo:));
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00163795 @ 00163795, 797 bytes * /

void FUN_00163795(HSWebcamWorkshopController *self,SEL _cmd,id updatePreviewImagesForVisibleWebCams)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id self_00;
  HSWebcamWorkshopController *pHVar5;
  int extraout_EDX;
  int iVar6;
  SEL op;
  undefined4 uVar8;
  undefined8 uVar7;
  ulonglong uVar9;
  id local_28;
  undefined8 local_24;
  ulonglong local_1c;
  
  if (self->_selectedCamIDs != (id)0x0) {
    pvVar1 = self->_webCamContainerView;
    _objc_msgSend_stret(&local_24,pvVar1,sel_visibleRect);
    pvVar1 = _objc_msgSend(pvVar1,sel_rowsInRect_,local_24,local_1c);
    pvVar2 = _objc_msgSend(cls_NSMutableSet,sel_set);
    iVar6 = extraout_EDX;
    uVar7 = local_24;
    uVar9 = local_1c;
    if (pvVar1 < (id)(extraout_EDX + (int)pvVar1)) {
      do {
        uVar8 = (undefined4)((ulonglong)uVar7 >> 0x20);
        pvVar3 = _objc_msgSend(self->_selectedCamIDs,sel_objectAtIndex_,pvVar1,uVar8,uVar9);
        uVar7 = CONCAT44(uVar8,pvVar3);
        _objc_msgSend(pvVar2,sel_addObject_);
        pvVar1 = (id)((int)pvVar1 + 1);
        iVar6 = iVar6 + -1;
      } while (iVar6 != 0);
    }
    pvVar1 = _objc_msgSend(pvVar2,sel_copy,uVar7,uVar9);
    pvVar3 = _objc_msgSend(self->_webCamViewVisibleCams,sel_count);
    if (pvVar3 != (id)0x0) {
      uVar7 = CONCAT44((int)((ulonglong)uVar7 >> 0x20),self->_webCamViewVisibleCams);
      _objc_msgSend(pvVar2,sel_minusSet_,self->_webCamViewVisibleCams);
    }
    _objc_msgSend(self->_webCamViewVisibleCams,sel_autorelease,uVar7);
    self->_webCamViewVisibleCams = pvVar1;
    pvVar1 = _objc_msgSend(pvVar2,sel_objectEnumerator);
LAB_00163a9e:
    pvVar2 = _objc_msgSend(pvVar1,sel_nextObject,uVar7);
    uVar8 = (undefined4)((ulonglong)uVar7 >> 0x20);
    if (pvVar2 != (id)0x0) {
      pvVar3 = _objc_msgSend(cls_HSThumbnailManager,sel_sharedThumbnailManager);
      uVar7 = CONCAT44(uVar8,pvVar2);
      pvVar3 = _objc_msgSend(pvVar3,sel_thumbnailExistForUID_,pvVar2);
      uVar8 = (undefined4)(uVar9 >> 0x20);
      if ((char)pvVar3 == '\0') {
        local_28 = (id)0x0;
        pvVar4 = _objc_msgSend(cls_NSArray,sel_arrayWithObjects_,&cfstr_sourcePageURL);
        self_00 = _objc_msgSend(cls_HSWebCamDataProvider,sel_sharedWebCamDataProvider);
        uVar9 = CONCAT44(uVar8,&local_28);
        pvVar3 = pvVar2;
        pvVar4 = _objc_msgSend(self_00,sel_attributes_forWebCam_error_,pvVar4,pvVar2,&local_28);
        pHVar5 = self;
        if (local_28 == (id)0x0) {
          pvVar4 = _objc_msgSend(pvVar4,sel_objectForKey_,&cfstr_sourcePageURL,pvVar3,uVar9);
          if (pvVar4 == (id)0x0) {
            uVar9 = uVar9 & 0xffffffff00000000;
            uVar8 = 0x900ca;
            local_28 = _objc_msgSend(cls_NSError,sel_errorWithDomain_code_userInfo_,
                                     &cfstr_WebCamDataProviderErrorDomain,0x900ca,0);
            uVar7 = CONCAT44(uVar8,local_28);
            op = sel_reportError_;
          }
          else {
            uVar7 = CONCAT44(pvVar3,pvVar4);
            pvVar3 = _objc_msgSend(cls_NSURL,sel_URLWithString_,pvVar4,pvVar3,uVar9);
            if ((pvVar2 == (id)0x0) || (pvVar3 == (id)0x0)) goto LAB_00163a9e;
            pHVar5 = _objc_msgSend(self,sel_webCamImageLoader,uVar7,uVar9);
            uVar7 = CONCAT44(pvVar3,pvVar2);
            op = sel_requestImageForWebCamUID_URL_;
          }
        }
        else {
          uVar7 = CONCAT44(pvVar3,local_28);
          op = sel_reportError_;
        }
        _objc_msgSend(pHVar5,op,uVar7,uVar9);
      }
      goto LAB_00163a9e;
    }
  }
  return;
}

*/
- (void)updatePreviewImagesForVisibleWebCams:(id)aCams
{
    if (_selectedCamIDs == nil) {
        return;
    }
    NSRange rows = [_webCamContainerView rowsInRect:[_webCamContainerView visibleRect]];
    NSMutableSet *cams = [NSMutableSet set];
    NSUInteger row;
    for (row = rows.location; row < NSMaxRange(rows); row++) {
        [cams addObject:[_selectedCamIDs objectAtIndex:row]];
    }
    NSSet *visible = [cams copy];
    if ([_webCamViewVisibleCams count] != 0) {
        [cams minusSet:_webCamViewVisibleCams];
    }
    [_webCamViewVisibleCams autorelease];
    _webCamViewVisibleCams = visible;
    for (id camID in cams) {
        if ([[HSThumbnailManager sharedThumbnailManager] thumbnailExistForUID:camID]) {
            continue;
        }
        NSError *error = nil;
        id attributes = [[HSWebCamDataProvider sharedWebCamDataProvider] attributes:[NSArray arrayWithObjects:@"sourcePageURL", nil] forWebCam:camID error:&error];
        if (error != nil) {
            [self reportError:error];
            continue;
        }
        id urlString = [attributes objectForKey:@"sourcePageURL"];
        if (urlString == nil) {
            [self reportError:[NSError errorWithDomain:@"WebCamDataProviderErrorDomain" code:0x900ca userInfo:nil]];
            continue;
        }
        NSURL *url = [NSURL URLWithString:urlString];
        if (url != nil) {
            [[self webCamImageLoader] requestImageForWebCamUID:camID URL:url];
        }
    }
}

- (void)newPreviewIsDoneForWebCamView:(id)aView
{
    id self_00;
    id pvVar1;

    if (_webCamPreviewView == aView) {
        self_00 = [HSThumbnailManager sharedThumbnailManager];
        pvVar1 = [_webCamPreviewView previewImage];
        [self_00 thumbnailForUID:[_webCamPreviewView identifier] originalImage:pvVar1];
        [_webCamContainerView reloadData];
    }
}

- (void)redisplayInfo:(id)aInfo
{
    NSIndexSet *pvVar1;
    id pvVar4_5;

    pvVar1 = [_webCamContainerView selectedRowIndexes];
    [_confirmButton setEnabled:(unsigned int)([pvVar1 count] != 0)];
    [_addToFavouritesButton setEnabled:((unsigned int)([pvVar1 count] != 0))];
    if ([pvVar1 count] == 0x1) {
        pvVar4_5 = [_selectedCamIDs objectAtIndex:[pvVar1 firstIndex]];
    }
    else {
        pvVar4_5 = nil;
    }
    [self displayInfoForCam:pvVar4_5];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00163ab2 @ 00163ab2, 2255 bytes * /

void FUN_00163ab2(HSWebcamWorkshopController *self,SEL _cmd,id displayInfoForCam)

{
  char cVar1;
  uint uVar2;
  int *piVar3;
  cfstringStruct *pcVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  id pvVar8;
  id pvVar9;
  SEL op;
  float extraout_EDX;
  int iVar10;
  int iVar11;
  double dVar12;
  undefined8 uVar13;
  longlong lVar14;
  cfstringStruct *pcVar15;
  cfstringStruct *pcVar16;
  cfstringStruct *pcVar17;
  undefined4 uVar18;
  cfstringStruct *local_34;
  cfstringStruct *local_30;
  cfstringStruct *local_28;
  id local_24;
  cfstringStruct *local_20;
  cfstringStruct *local_1c;
  cfstringStruct *local_18;
  int local_14;
  
  if (displayInfoForCam == (id)0x0) {
    local_24 = (id)0x0;
    local_1c = &cfstr_empty;
    pcVar4 = &cfstr___;
    local_34 = pcVar4;
    local_30 = pcVar4;
    local_28 = pcVar4;
    local_20 = pcVar4;
    local_18 = pcVar4;
    goto LAB_001640f6;
  }
  local_14 = 0;
  pcVar4 = &cfstr_framerate;
  pcVar17 = &cfstr_copyright;
  pcVar16 = &cfstr_timeZoneName;
  pcVar15 = &cfstr_sourcePageURL;
  uVar18 = 0;
  pvVar6 = _objc_msgSend(cls_NSArray,sel_arrayWithObjects_,&cfstr_name,&cfstr_location,
                         &cfstr_originalSize,&cfstr_sourcePageURL,&cfstr_timeZoneName,
                         &cfstr_copyright,&cfstr_framerate,0);
  pvVar7 = _objc_msgSend(cls_HSWebCamDataProvider,sel_sharedWebCamDataProvider);
  piVar3 = &local_14;
  pvVar5 = displayInfoForCam;
  pvVar6 = _objc_msgSend(pvVar7,sel_attributes_forWebCam_error_,pvVar6,displayInfoForCam,piVar3);
  if (local_14 != 0) {
    _objc_msgSend(self,sel_reportError_,local_14,pvVar5,piVar3,pcVar15,pcVar16,pcVar17,pcVar4,uVar18
                 );
    local_24 = (id)0x0;
    local_1c = &cfstr_empty;
    pcVar4 = &cfstr___;
    local_34 = &cfstr___;
    local_20 = &cfstr___;
    local_28 = &cfstr___;
    local_30 = &cfstr___;
    local_18 = &cfstr___;
    goto LAB_001640f6;
  }
  local_34 = _objc_msgSend(pvVar6,sel_objectForKey_,&cfstr_name,pvVar5,piVar3,pcVar15,pcVar16,
                           pcVar17,pcVar4,uVar18);
  local_20 = _objc_msgSend(pvVar6,sel_objectForKey_,&cfstr_location);
  if (local_20 == (cfstringStruct *)0x0) {
    local_1c = &cfstr_empty;
    local_20 = &cfstr___;
  }
  else {
    pvVar7 = _objc_msgSend(local_20,sel_componentsSeparatedByString_,&cfstr__,pvVar5,piVar3);
    pvVar8 = _objc_msgSend(pvVar7,sel_count);
    if (pvVar8 == (id)0x2) {
      pvVar8 = _objc_msgSend(pvVar7,sel_objectAtIndex_,0);
      pvVar9 = _objc_msgSend(cls_NSCharacterSet,sel_whitespaceCharacterSet);
      local_1c = _objc_msgSend(pvVar8,sel_stringByTrimmingCharactersInSet_,pvVar9);
      pvVar7 = _objc_msgSend(pvVar7,sel_objectAtIndex_,1);
      pvVar8 = _objc_msgSend(cls_NSCharacterSet,sel_whitespaceCharacterSet);
      local_20 = _objc_msgSend(pvVar7,sel_stringByTrimmingCharactersInSet_,pvVar8);
    }
    else {
      local_1c = &cfstr_empty;
    }
  }
  uVar13 = CONCAT44(pvVar5,&cfstr_originalSize);
  pvVar5 = _objc_msgSend(pvVar6,sel_objectForKey_,&cfstr_originalSize,pvVar5,piVar3);
  if (pvVar5 == (id)0x0) {
LAB_00163d48:
    uVar2 = (uint)((ulonglong)uVar13 >> 0x20);
    local_28 = &cfstr___;
  }
  else {
    pvVar5 = _objc_msgSend(pvVar5,sel_sizeValue,uVar13);
    uVar13 = *(undefined8 *)PTR_0033607c;
    cVar1 = _NSEqualSizes(pvVar5,extraout_EDX,*(undefined4 *)PTR_0033607c,
                          *(undefined4 *)(PTR_0033607c + 4));
    if (cVar1 != '\0') goto LAB_00163d48;
    if (DAT_003429ac == (id)0x0) {
      pvVar7 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
      DAT_003429ac = _objc_msgSend(pvVar7,sel_localizedStringForKey_value_table_,
                                   &cfstr__u_x__u_pixels,&cfstr_empty,0);
    }
    piVar3 = (int *)(int)extraout_EDX;
    if (2.1474836e+09 <= extraout_EDX) {
      piVar3 = (int *)((int)(extraout_EDX - 2.1474836e+09) ^ 0x80000000);
    }
    uVar2 = (int)(float)pvVar5;
    if (2.1474836e+09 <= (float)pvVar5) {
      uVar2 = (int)((float)pvVar5 - 2.1474836e+09) ^ 0x80000000;
    }
    pcVar15 = (cfstringStruct *)0x0;
    local_28 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,DAT_003429ac,uVar2,piVar3,0);
  }
  local_18 = _objc_msgSend(pvVar6,sel_objectForKey_,&cfstr_sourcePageURL,uVar2,piVar3,pcVar15);
  if (local_18 == (cfstringStruct *)0x0) {
    local_24 = (id)0x0;
  }
  else {
    local_24 = _objc_msgSend(cls_NSURL,sel_URLWithString_,local_18,uVar2,piVar3,pcVar15);
  }
  lVar14 = CONCAT44(uVar2,&cfstr_timeZoneName);
  pvVar5 = _objc_msgSend(pvVar6,sel_objectForKey_,&cfstr_timeZoneName,uVar2,piVar3,pcVar15);
  if (pvVar5 == (id)0x0) {
    local_30 = &cfstr___;
  }
  else {
    pvVar7 = _objc_msgSend(cls_NSCalendarDate,sel_calendarDate,lVar14);
    pvVar5 = _objc_msgSend(cls_NSTimeZone,sel_timeZoneWithName_,pvVar5);
    _objc_msgSend(pvVar7,sel_setTimeZone_,pvVar5);
    pvVar7 = _objc_msgSend(pvVar7,sel_descriptionWithCalendarFormat_,&cfstr__I__M__p);
    pvVar5 = _objc_msgSend(pvVar5,sel_secondsFromGMT);
    iVar11 = (int)pvVar5 % 0xe10;
    if ((int)pvVar5 < 0) {
      iVar11 = (int)((ulonglong)((longlong)iVar11 * 0x77777777) >> 0x20) - iVar11;
      iVar11 = (iVar11 >> 5) - (iVar11 >> 0x1f);
      iVar10 = (int)((ulonglong)((longlong)(int)pvVar5 * 0x6e5d4c3b) >> 0x20) - (int)pvVar5;
    }
    else {
      iVar11 = iVar11 / 0x3c;
      iVar10 = (int)((ulonglong)((longlong)(int)pvVar5 * 0x91a2b3c5) >> 0x20);
    }
    pcVar4 = &cfstr__;
    if (-1 < (int)pvVar5) {
      pcVar4 = &cfstr__;
    }
    pcVar16 = (cfstringStruct *)0x0;
    piVar3 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr_GMT____02d__02d,pcVar4,
                           (iVar10 >> 0xb) - (iVar10 >> 0x1f),iVar11,0);
    lVar14 = ZEXT48(pvVar7) << 0x20;
    pcVar15 = (cfstringStruct *)0x0;
    local_30 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr________,pvVar7,piVar3,0);
  }
  uVar18 = (undefined4)((ulonglong)lVar14 >> 0x20);
  pcVar4 = _objc_msgSend(pvVar6,sel_objectForKey_,&cfstr_copyright,uVar18,piVar3,pcVar15,pcVar16);
  if (pcVar4 != (cfstringStruct *)0x0) {
    local_18 = pcVar4;
  }
  pvVar5 = _objc_msgSend(pvVar6,sel_objectForKey_,&cfstr_framerate,uVar18,piVar3,pcVar15,pcVar16);
  if (pvVar5 == (id)0x0) {
    pcVar4 = &cfstr___;
  }
  else {
    dVar12 = _objc_msgSend_fpret(pvVar5,sel_floatValue);
    pcVar4 = _objc_msgSend(cls_HSWebPageObject,sel_localizedRefreshRateStringForRate_,dVar12);
  }
LAB_001640f6:
  _objc_msgSend(self->_webCamInfoNameTextField,sel_setStringValue_,local_34);
  _objc_msgSend(self->_webCamInfoExactLocationTextField,sel_setStringValue_,local_1c);
  _objc_msgSend(self->_webCamInfoGeneralLocationTextField,sel_setStringValue_,local_20);
  _objc_msgSend(self->_webCamInfoFrameRateTextField,sel_setStringValue_,pcVar4);
  _objc_msgSend(self->_webCamInfoSizeTextField,sel_setStringValue_,local_28);
  _objc_msgSend(self->_webCamInfoTimeTextField,sel_setStringValue_,local_30);
  _objc_msgSend(self->_webCamInfoCopyrightTextField,sel_setStringValue_,local_18);
  _objc_msgSend(self->_webCamInfoCopyrightTextField,sel_setToolTip_,local_18);
  _objc_msgSend(self->_webCamPreviewView,sel_setIdentifier_,displayInfoForCam);
  _objc_msgSend(self->_webCamPreviewView,sel_setURL_,local_24);
  pvVar5 = _objc_msgSend(cls_HSThumbnailManager,sel_sharedThumbnailManager);
  uVar18 = 0;
  pvVar5 = _objc_msgSend(pvVar5,sel_thumbnailForUID_originalImage_,displayInfoForCam,0);
  uVar13 = CONCAT44(uVar18,pvVar5);
  _objc_msgSend(self->_webCamPreviewView,sel_setPreviewImage_,pvVar5);
  op = sel_disabledControlTextColor;
  if (displayInfoForCam != (id)0x0) {
    op = sel_blackColor;
  }
  pvVar5 = _objc_msgSend(cls_NSColor,op,uVar13);
  pvVar6 = _objc_msgSend(self->_webCamPreviewView,sel_superview);
  pvVar6 = _objc_msgSend(pvVar6,sel_subviews);
  pvVar7 = _objc_msgSend(pvVar6,sel_count);
  if (0 < (int)pvVar7) {
    iVar11 = 0;
    do {
      pvVar8 = _objc_msgSend(pvVar6,sel_objectAtIndex_,iVar11);
      pvVar9 = _objc_msgSend(cls_NSTextField,sel_class);
      pvVar9 = _objc_msgSend(pvVar8,sel_isKindOfClass_,pvVar9);
      if ((char)pvVar9 != '\0') {
        _objc_msgSend(pvVar8,sel_setTextColor_,pvVar5);
      }
      iVar11 = iVar11 + 1;
    } while (iVar11 < (int)pvVar7);
  }
  _objc_msgSend(self->_webCamPreviewView,sel_setEnabled_,(uint)(displayInfoForCam != (id)0x0));
  return;
}

*/
- (void)displayInfoForCam:(id)aCam
{
    NSString *name = @"--";
    NSString *exactLocation = @"";
    NSString *generalLocation = @"--";
    NSString *size = @"--";
    NSString *time = @"--";
    NSString *copyright = @"--";
    NSString *frameRate = @"--";
    NSURL *url = nil;

    if (aCam != nil) {
        NSError *error = nil;
        NSArray *keys = [NSArray arrayWithObjects:@"name", @"location", @"originalSize", @"sourcePageURL", @"timeZoneName", @"copyright", @"framerate", nil];
        id attributes = [[HSWebCamDataProvider sharedWebCamDataProvider] attributes:keys forWebCam:aCam error:&error];
        if (error != nil) {
            [self reportError:error];
        }
        else {
            name = [attributes objectForKey:@"name"];
            id location = [attributes objectForKey:@"location"];
            if (location != nil) {
                NSArray *parts = [location componentsSeparatedByString:@";"];
                generalLocation = location;
                if ([parts count] == 2) {
                    exactLocation = [[parts objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    generalLocation = [[parts objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                }
            }
            id sizeValue = [attributes objectForKey:@"originalSize"];
            if (sizeValue != nil && !NSEqualSizes([sizeValue sizeValue], NSZeroSize)) {
                NSSize originalSize = [sizeValue sizeValue];
                if (sPixelSizeFormat == nil) {
                    sPixelSizeFormat = [[[NSBundle mainBundle] localizedStringForKey:@"%u x %u pixels" value:@"" table:nil] retain];
                }
                size = [NSString stringWithFormat:sPixelSizeFormat, (unsigned int)originalSize.width, (unsigned int)originalSize.height];
            }
            id sourcePage = [attributes objectForKey:@"sourcePageURL"];
            if (sourcePage != nil) {
                url = [NSURL URLWithString:sourcePage];
            }
            id timeZoneName = [attributes objectForKey:@"timeZoneName"];
            if (timeZoneName != nil) {
                NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:timeZoneName];
                NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
                [formatter setTimeZone:timeZone];
                [formatter setDateFormat:@"hh:mm a"];
                NSString *localTime = [formatter stringFromDate:[NSDate date]];
                NSInteger seconds = [timeZone secondsFromGMT];
                NSInteger absSeconds = seconds < 0 ? -seconds : seconds;
                NSString *offset = [NSString stringWithFormat:@"GMT %@%02d:%02d", (seconds < 0 ? @"-" : @"+"), (int)(absSeconds / 3600), (int)((absSeconds % 3600) / 60)];
                time = [NSString stringWithFormat:@"%@ (%@)", localTime, offset];
            }
            // Without a copyright entry the field shows the source page address, as the original did.
            copyright = sourcePage;
            id copyrightValue = [attributes objectForKey:@"copyright"];
            if (copyrightValue != nil) {
                copyright = copyrightValue;
            }
            id rate = [attributes objectForKey:@"framerate"];
            if (rate != nil) {
                frameRate = [HSWebPageObject localizedRefreshRateStringForRate:[rate floatValue]];
            }
        }
    }
    [_webCamInfoNameTextField setStringValue:(name != nil ? name : @"")];
    [_webCamInfoExactLocationTextField setStringValue:exactLocation];
    [_webCamInfoGeneralLocationTextField setStringValue:generalLocation];
    [_webCamInfoFrameRateTextField setStringValue:frameRate];
    [_webCamInfoSizeTextField setStringValue:size];
    [_webCamInfoTimeTextField setStringValue:time];
    [_webCamInfoCopyrightTextField setStringValue:(copyright != nil ? copyright : @"")];
    [_webCamInfoCopyrightTextField setToolTip:copyright];
    [_webCamPreviewView setIdentifier:aCam];
    [_webCamPreviewView setURL:url];
    [_webCamPreviewView setPreviewImage:[[HSThumbnailManager sharedThumbnailManager] thumbnailForUID:aCam originalImage:nil]];
    NSColor *color = aCam != nil ? [NSColor blackColor] : [NSColor disabledControlTextColor];
    NSArray *subviews = [[_webCamPreviewView superview] subviews];
    int count = (int)[subviews count];
    int index;
    for (index = 0; index < count; index++) {
        id view = [subviews objectAtIndex:index];
        if ([view isKindOfClass:[NSTextField class]]) {
            [view setTextColor:color];
        }
    }
    [_webCamPreviewView setEnabled:aCam != nil];
}

- (void)webCamsFilterRequestDidExecute:(id)aExecute
{
    id pvVar2;
    id pvVar1_2;
    id pvVar1_4;
    id pvVar1_9;
    id pvVar3_5;
    id pvVar3_8;

    pvVar1_2 = [[aExecute userInfo] objectForKey:WCDPFilteredWebCamsKey];
    if (pvVar1_2 == nil) {
        pvVar1_4 = [[aExecute userInfo] objectForKey:WCDPErrorDataKey];
        if (pvVar1_4 != nil) {
            pvVar2 = [NSKeyedUnarchiver unarchiveObjectWithData:pvVar1_4];
            if (pvVar2 != nil) {
                [self reportError:pvVar2];
            }
        }
    }
    else {
        _selectedCamIDs = [pvVar1_2 retain];
    }
    if ([_segmentedControl selectedSegment] != 0) {
        pvVar3_5 = [NSSet setWithArray:_selectedCamIDs];
        pvVar1_9 = [NSMutableSet setWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"HSWebCamWorkshopFavouriteWebCamIDs"]];
        [pvVar1_9 intersectSet:pvVar3_5];
        pvVar3_8 = [[[NSSortDescriptor alloc] initWithKey:@"description" ascending:YES] autorelease];
        _selectedCamIDs = [[[pvVar1_9 allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:pvVar3_8]] retain];
    }
    [self hideLoading];
    [self tableViewDidScrolled:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001623bf @ 001623bf, 747 bytes * /

void FUN_001623bf(HSWebcamWorkshopController *self,SEL _cmd,id cacheWebcamsWithRootItem,
                 id filterString)

{
  undefined *self_00;
  id pvVar1;
  cfstringStruct *pcVar2;
  id pvVar3;
  id pvVar4;
  id self_01;
  cfstringStruct *pcVar5;
  cfstringStruct *pcVar6;
  int *piVar7;
  int local_14;
  
  _objc_msgSend(self->_selectedCamIDs,sel_autorelease);
  self->_selectedCamIDs = (id)0x0;
  pvVar1 = _objc_msgSend(filterString,sel_length);
  if (pvVar1 == (id)0x0) {
    pcVar2 = &cfstr_TRUEPREDICATE;
    goto LAB_0016256d;
  }
  pcVar2 = filterString;
  switch(self->_currentFilterRuleTag) {
  case 0:
    pcVar6 = &cfstr_name;
    pcVar5 = &cfstr_____CONTAINS_c________OR_____CONTAINS_c________O;
    filterString = &cfstr_camDescriptionString;
    goto LAB_00162568;
  case 1:
    pcVar6 = &cfstr_name;
    break;
  case 2:
    pcVar6 = &cfstr_camDescriptionString;
    break;
  case 3:
    pcVar6 = &cfstr_location;
    break;
  case 4:
    pcVar6 = &cfstr_keyword;
    pcVar5 = &cfstr_ANY_______LIKE_c________;
    pcVar2 = &cfstr_keyString;
    goto LAB_00162568;
  case 5:
    pcVar6 = &cfstr_copyright;
    break;
  default:
    pcVar2 = (cfstringStruct *)0x0;
    goto LAB_0016256d;
  }
  pcVar5 = &cfstr____CONTAINS_c______;
  filterString = (cfstringStruct *)0x0;
LAB_00162568:
  pcVar2 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,pcVar5,pcVar6,pcVar2,filterString);
LAB_0016256d:
  self_00 = cls_NSArray;
  pvVar1 = _objc_msgSend(cls_NSSortDescriptor,sel_alloc);
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithKey_ascending_,&cfstr_name,1);
  pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  pvVar3 = _objc_msgSend(self_00,sel_arrayWithObject_,pvVar1);
  local_14 = 0;
  pvVar1 = _objc_msgSend(self->_categoryItemsCache,sel_allKeys);
  pvVar4 = _objc_msgSend(pvVar1,sel_indexOfObjectIdenticalTo_,&cfstr_0);
  pvVar4 = _objc_msgSend(pvVar1,sel_objectAtIndex_,pvVar4);
  self_01 = _objc_msgSend(cls_HSWebCamDataProvider,sel_sharedWebCamDataProvider);
  piVar7 = &local_14;
  pvVar1 = (id)0x0;
  if (pvVar4 != cacheWebcamsWithRootItem) {
    pvVar1 = cacheWebcamsWithRootItem;
  }
  _objc_msgSend(self_01,sel_webCamsForFilterPredicate_sortDescriptors_category_error_,pcVar2,pvVar3,
                pvVar1,piVar7);
  if (local_14 != 0) {
    _objc_msgSend(self,sel_reportError_,local_14,pvVar3,pvVar1,piVar7);
  }
  return;
}

*/
- (void)cacheWebcamsWithRootItem:(id)aItem filterString:(id)aString
{
    NSString *predicate;

    if ([aString length] == 0) {
        predicate = @"TRUEPREDICATE";
    }
    else {
        switch (_currentFilterRuleTag) {
        case 0:
            predicate = [NSString stringWithFormat:@"(%@ CONTAINS[c] \"%@\") OR (%@ CONTAINS[c] \"%@\") OR (%@ CONTAINS[c] \"%@\") OR (ANY %@.%@ LIKE[c] \"*%@*\") OR (%@ CONTAINS[c] \"%@\")",
                         @"name", aString, @"camDescriptionString", aString, @"location", aString, @"keyword", @"keyString", aString, @"copyright", aString];
            break;
        case 1:
            predicate = [NSString stringWithFormat:@"%@ CONTAINS[c] \"%@\"", @"name", aString];
            break;
        case 2:
            predicate = [NSString stringWithFormat:@"%@ CONTAINS[c] \"%@\"", @"camDescriptionString", aString];
            break;
        case 3:
            predicate = [NSString stringWithFormat:@"%@ CONTAINS[c] \"%@\"", @"location", aString];
            break;
        case 4:
            predicate = [NSString stringWithFormat:@"ANY %@.%@ LIKE[c] \"*%@*\"", @"keyword", @"keyString", aString];
            break;
        case 5:
            predicate = [NSString stringWithFormat:@"%@ CONTAINS[c] \"%@\"", @"copyright", aString];
            break;
        default:
            predicate = nil;
            break;
        }
    }
    NSArray *sortDescriptors = [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease]];
    NSError *error = nil;
    id category = HSWebcamWorkshopRootItem(_categoryItemsCache) != aItem ? aItem : nil;
    [[HSWebCamDataProvider sharedWebCamDataProvider] webCamsForFilterPredicate:predicate sortDescriptors:sortDescriptors category:category error:&error];
    if (error != nil) {
        [self reportError:error];
    }
}

- (void)reloadWebCams:(id)aCams
{
    id pvVar2;

    [self showLoading];
    pvVar2 = _outlineView;
    [self cacheWebcamsWithRootItem:[pvVar2 itemAtRow:[pvVar2 selectedRow]] filterString:[_filterField stringValue]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00164381 @ 00164381, 549 bytes * /

void FUN_00164381(HSWebcamWorkshopController *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined8 uVar4;
  undefined4 uVar5;
  undefined8 local_24;
  undefined8 local_1c;
  
  _objc_msgSend(self->_webCamContainerView,sel_reloadData);
  _objc_msgSend(self->_webCamContainerView,sel_deselectAll_);
  pvVar1 = _objc_msgSend(self->_webCamContainerView,sel_numberOfRows);
  if (pvVar1 != (id)0x0) {
    pvVar1 = self->_webCamContainerView;
    _objc_msgSend(cls_NSIndexSet,sel_indexSetWithIndex_);
    _objc_msgSend(pvVar1,sel_selectRowIndexes_byExtendingSelection_);
  }
  self_00 = cls_NSString;
  pvVar1 = self->_webCamContainerViewCounterTextField;
  pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_);
  pvVar3 = _objc_msgSend(self->_selectedCamIDs,sel_count);
  uVar4 = CONCAT44(pvVar2,pvVar3);
  uVar5 = 0;
  _objc_msgSend(self_00,sel_stringWithFormat_);
  _objc_msgSend(pvVar1,sel_setStringValue_);
  _objc_msgSend(self->_webCamContainerViewCounterTextField,sel_setHidden_);
  pvVar1 = _objc_msgSend(self->_webCamContainerView,sel_enclosingScrollView);
  _objc_msgSend_stret(&local_24,self->_placeholderView,sel_frame,uVar4,uVar5);
  _objc_msgSend(pvVar1,sel_setFrame_,local_24,local_1c);
  _objc_msgSend(self->_placeholderView,sel_setIsSpinning_,0);
  _objc_msgSend(self->_placeholderView,sel_removeFromSuperviewWithoutNeedingDisplay);
  _objc_msgSend(self->_splitView,sel_addSubview_,pvVar1);
  return;
}

*/
- (void)hideLoading
{
    [_webCamContainerView reloadData];
    [_webCamContainerView deselectAll:nil];
    if ([_webCamContainerView numberOfRows] != 0) {
        [_webCamContainerView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    }
    NSString *items = [[NSBundle mainBundle] localizedStringForKey:@"items" value:@"" table:nil];
    [_webCamContainerViewCounterTextField setStringValue:[NSString stringWithFormat:@"%d %@", (int)[_selectedCamIDs count], items]];
    [_webCamContainerViewCounterTextField setHidden:NO];
    NSScrollView *scrollView = [_webCamContainerView enclosingScrollView];
    [scrollView setFrame:[_placeholderView frame]];
    [_placeholderView setIsSpinning:NO];
    [_placeholderView removeFromSuperviewWithoutNeedingDisplay];
    [_splitView addSubview:scrollView];
}

- (void)showLoading
{
    [_confirmButton setEnabled:NO];
    [_webCamContainerViewCounterTextField setHidden:YES];
    NSScrollView *scroll = [_webCamContainerView enclosingScrollView];
    [_placeholderView setFrame:[scroll frame]];
    [scroll removeFromSuperviewWithoutNeedingDisplay];
    [_splitView addSubview:_placeholderView];
    [_splitView display];
    [_placeholderView setIsSpinning:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00162284 @ 00162284, 179 bytes * /

void FUN_00162284(HSWebcamWorkshopController *self,SEL _cmd,id outlineViewSelectionDidChange)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  
  pvVar2 = self->_outlineView;
  pvVar1 = _objc_msgSend(pvVar2,sel_selectedRow);
  pvVar2 = _objc_msgSend(pvVar2,sel_itemAtRow_,pvVar1);
  op = sel_setNeedToReloadCams;
  if (pvVar2 == (id)0x0) {
    pvVar2 = self->_outlineView;
    pvVar1 = _objc_msgSend(cls_NSIndexSet,sel_indexSetWithIndex_,0);
    _objc_msgSend(pvVar2,sel_selectRowIndexes_byExtendingSelection_,pvVar1,0);
    pvVar1 = (id)0x0;
    op = sel_tableViewDidScrolled_;
  }
  _objc_msgSend(self,op,pvVar1);
  return;
}

*/
- (void)outlineViewSelectionDidChange:(id)aChange
{
    if ([_outlineView itemAtRow:[_outlineView selectedRow]] == nil) {
        [_outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
        [self tableViewDidScrolled:nil];
    }
    else {
        [self setNeedToReloadCams];
    }
}

- (void)outlineView:(id)aView willDisplayCell:(id)aCell forTableColumn:(id)aColumn item:(id)aItem
{
    id pcVar2;
    NSImage *pvVar1_3;

    if ([aView levelForItem:aItem] == 0) {
        if ([aView rowForItem:aItem] == 0) {
            pcVar2 = @"WebCamRootCategory";
        }
        else {
            pcVar2 = @"WebCamSupercategory";
        }
    }
    else {
        pcVar2 = @"WebCamCategory";
    }
    pvVar1_3 = [NSImage imageNamed:pcVar2];
    if (pvVar1_3 != nil) {
        [aCell setRepresentedObject:pvVar1_3];
    }
}

- (id)outlineView:(id)aView toolTipForCell:(id)aCell rect:(NSRect *)aRect tableColumn:(id)aColumn item:(id)aItem mouseLocation:(NSPoint)aLocation
{
    return nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00161ffb @ 00161ffb, 466 bytes * /

id FUN_00161ffb(HSWebcamWorkshopController *self,SEL _cmd,id outlineView,
               id objectValueForTableColumn,id byItem)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  cfstringStruct *pcVar4;
  int *piVar5;
  int local_14;
  
  pvVar1 = _objc_msgSend(self->_categoryItemsCache,sel_allKeys);
  pcVar4 = &cfstr_0;
  pvVar2 = _objc_msgSend(pvVar1,sel_indexOfObjectIdenticalTo_,&cfstr_0);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,pvVar2);
  if (pvVar1 == byItem) {
    pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle,pvVar2);
    pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,&cfstr_All_Categories,
                           &cfstr_empty,0);
  }
  else {
    if (byItem != (id)0x0) {
      pcVar4 = byItem;
    }
    pvVar2 = _objc_msgSend(self->_categoryItemsCache,sel_objectForKey_,pcVar4);
    pcVar4 = &cfstr_HSWCCacheCategoryItemName;
    pvVar1 = _objc_msgSend(pvVar2,sel_objectForKey_,&cfstr_HSWCCacheCategoryItemName);
    if (pvVar1 == (id)0x0) {
      pvVar1 = _objc_msgSend(cls_HSWebCamDataProvider,sel_sharedWebCamDataProvider,pcVar4);
      pvVar3 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,&cfstr_name);
      local_14 = 0;
      piVar5 = &local_14;
      pvVar1 = _objc_msgSend(pvVar1,sel_attributes_forCategory_error_,pvVar3,byItem,piVar5);
      if (local_14 == 0) {
        pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_name,byItem,piVar5);
        if (pvVar1 != (id)0x0) {
          _objc_msgSend(pvVar2,sel_setObject_forKey_,pvVar1,&cfstr_HSWCCacheCategoryItemName,piVar5)
          ;
        }
      }
      else {
        _objc_msgSend(self,sel_reportError_,local_14,byItem,piVar5);
        pvVar1 = (id)0x0;
      }
    }
  }
  return pvVar1;
}

*/
- (id)outlineView:(id)aView objectValueForTableColumn:(id)aColumn byItem:(id)aItem
{
    if (HSWebcamWorkshopRootItem(_categoryItemsCache) == aItem) {
        return [[NSBundle mainBundle] localizedStringForKey:@"All Categories" value:@"" table:nil];
    }
    NSMutableDictionary *entry = [_categoryItemsCache objectForKey:(aItem != nil ? aItem : @"0")];
    id name = [entry objectForKey:@"HSWCCacheCategoryItemName"];
    if (name == nil) {
        NSError *error = nil;
        id attributes = [[HSWebCamDataProvider sharedWebCamDataProvider] attributes:[NSArray arrayWithObject:@"name"] forCategory:aItem error:&error];
        if (error == nil) {
            name = [attributes objectForKey:@"name"];
            if (name != nil) {
                [entry setObject:name forKey:@"HSWCCacheCategoryItemName"];
            }
        }
        else {
            [self reportError:error];
            name = nil;
        }
    }
    return name;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00161ded @ 00161ded, 526 bytes * /

int FUN_00161ded(HSWebcamWorkshopController *self,SEL _cmd,id outlineView,id numberOfChildrenOfItem)

{
  id pvVar1;
  id pvVar2;
  cfstringStruct *pcVar3;
  id pvVar4;
  id pvVar5;
  cfstringStruct *pcVar6;
  int iVar7;
  cfstringStruct *pcVar8;
  int *piVar9;
  int local_14;
  
  local_14 = 0;
  pvVar1 = _objc_msgSend(self->_categoryItemsCache,sel_allKeys);
  pcVar6 = &cfstr_0;
  pvVar2 = _objc_msgSend(pvVar1,sel_indexOfObjectIdenticalTo_,&cfstr_0);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,pvVar2);
  if (pvVar1 == numberOfChildrenOfItem) {
    pvVar1 = (id)0x0;
  }
  else {
    if (numberOfChildrenOfItem != (id)0x0) {
      pcVar6 = numberOfChildrenOfItem;
    }
    pvVar1 = _objc_msgSend(self->_categoryItemsCache,sel_objectForKey_,pcVar6);
    pcVar6 = &cfstr_HSWCCacheCategorySubitems;
    pvVar2 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_HSWCCacheCategorySubitems);
    if (pvVar2 == (id)0x0) {
      pvVar2 = _objc_msgSend(cls_HSWebCamDataProvider,sel_sharedWebCamDataProvider,pcVar6);
      piVar9 = &local_14;
      pvVar2 = _objc_msgSend(pvVar2,sel_childrenOfWebCamCategory_error_,numberOfChildrenOfItem,
                             piVar9);
      if (local_14 == 0) {
        pcVar6 = &cfstr_HSWCCacheCategorySubitems;
        _objc_msgSend(pvVar1,sel_setObject_forKey_,pvVar2,&cfstr_HSWCCacheCategorySubitems);
        pvVar1 = _objc_msgSend(pvVar2,sel_count);
        if (0 < (int)pvVar1) {
          iVar7 = 0;
          do {
            pcVar3 = _objc_msgSend(pvVar2,sel_objectAtIndex_,iVar7,pcVar6);
            pcVar8 = pcVar3;
            pvVar4 = _objc_msgSend(self->_categoryItemsCache,sel_objectForKey_,pcVar3);
            if (pvVar4 == (id)0x0) {
              pvVar4 = self->_categoryItemsCache;
              pvVar5 = _objc_msgSend(cls_NSMutableDictionary,sel_dictionary,pcVar8);
              _objc_msgSend(pvVar4,sel_setObject_forKey_,pvVar5,pcVar3);
              pcVar6 = pcVar3;
            }
            iVar7 = iVar7 + 1;
          } while (iVar7 < (int)pvVar1);
        }
      }
      else {
        _objc_msgSend(self,sel_reportError_,local_14,piVar9);
        pvVar1 = (id)0x0;
      }
    }
    else {
      pvVar1 = _objc_msgSend(pvVar2,sel_count,pcVar6);
    }
    if ((local_14 == 0) && (numberOfChildrenOfItem == (id)0x0)) {
      pvVar1 = (id)((int)pvVar1 + 1);
    }
  }
  return (int)pvVar1;
}

*/
- (NSInteger)outlineView:(id)aView numberOfChildrenOfItem:(id)aItem
{
    NSError *error = nil;
    NSInteger count;

    if (HSWebcamWorkshopRootItem(_categoryItemsCache) == aItem) {
        return 0;
    }
    NSMutableDictionary *entry = [_categoryItemsCache objectForKey:(aItem != nil ? aItem : @"0")];
    NSArray *subitems = [entry objectForKey:@"HSWCCacheCategorySubitems"];
    if (subitems == nil) {
        subitems = [[HSWebCamDataProvider sharedWebCamDataProvider] childrenOfWebCamCategory:aItem error:&error];
        if (error == nil) {
            [entry setObject:subitems forKey:@"HSWCCacheCategorySubitems"];
            count = (NSInteger)[subitems count];
            NSInteger index;
            for (index = 0; index < count; index++) {
                id subitem = [subitems objectAtIndex:index];
                if ([_categoryItemsCache objectForKey:subitem] == nil) {
                    [_categoryItemsCache setObject:[NSMutableDictionary dictionary] forKey:subitem];
                }
            }
        }
        else {
            [self reportError:error];
            count = 0;
        }
    }
    else {
        count = (NSInteger)[subitems count];
    }
    // The root level also lists the "All Categories" item.
    if (error == nil && aItem == nil) {
        count++;
    }
    return count;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00161c7a @ 00161c7a, 371 bytes * /

BOOL FUN_00161c7a(HSWebcamWorkshopController *self,SEL _cmd,id outlineView,id isItemExpandable)

{
  BOOL BVar1;
  id pvVar2;
  id pvVar3;
  HSWebcamWorkshopController *self_00;
  cfstringStruct *pcVar4;
  SEL op;
  id local_14;
  
  pvVar2 = _objc_msgSend(self->_categoryItemsCache,sel_allKeys);
  pcVar4 = &cfstr_0;
  pvVar3 = _objc_msgSend(pvVar2,sel_indexOfObjectIdenticalTo_,&cfstr_0);
  pvVar2 = _objc_msgSend(pvVar2,sel_objectAtIndex_,pvVar3);
  if (pvVar2 == isItemExpandable) {
    BVar1 = '\0';
  }
  else {
    if (isItemExpandable != (id)0x0) {
      pcVar4 = isItemExpandable;
    }
    self_00 = _objc_msgSend(self->_categoryItemsCache,sel_objectForKey_,pcVar4);
    pcVar4 = &cfstr_HSWCCacheCategoryExpandable;
    pvVar2 = _objc_msgSend(self_00,sel_objectForKey_,&cfstr_HSWCCacheCategoryExpandable);
    if (pvVar2 == (id)0x0) {
      local_14 = (id)0x0;
      pvVar2 = _objc_msgSend(cls_HSWebCamDataProvider,sel_sharedWebCamDataProvider,pcVar4);
      pcVar4 = (cfstringStruct *)&local_14;
      pvVar3 = _objc_msgSend(pvVar2,sel_isWebCamCategoryExpandable_error_,isItemExpandable,pcVar4);
      BVar1 = (BOOL)pvVar3;
      op = sel_reportError_;
      pvVar2 = local_14;
      if (local_14 == (id)0x0) {
        pvVar2 = _objc_msgSend(cls_NSNumber,sel_numberWithBool_,(uint)pvVar3 & 0xff,pcVar4);
        self = self_00;
        op = sel_setObject_forKey_;
        pcVar4 = &cfstr_HSWCCacheCategoryExpandable;
      }
      _objc_msgSend(self,op,pvVar2,pcVar4);
    }
    else {
      pvVar2 = _objc_msgSend(pvVar2,sel_boolValue,pcVar4);
      BVar1 = (BOOL)pvVar2;
    }
  }
  return BVar1;
}

*/
- (BOOL)outlineView:(id)aView isItemExpandable:(id)aExpandable
{
    if (HSWebcamWorkshopRootItem(_categoryItemsCache) == aExpandable) {
        return NO;
    }
    NSMutableDictionary *entry = [_categoryItemsCache objectForKey:(aExpandable != nil ? aExpandable : @"0")];
    id expandable = [entry objectForKey:@"HSWCCacheCategoryExpandable"];
    if (expandable != nil) {
        return [expandable boolValue];
    }
    NSError *error = nil;
    BOOL result = [[HSWebCamDataProvider sharedWebCamDataProvider] isWebCamCategoryExpandable:aExpandable error:&error];
    if (error == nil) {
        [entry setObject:[NSNumber numberWithBool:result] forKey:@"HSWCCacheCategoryExpandable"];
    }
    else {
        [self reportError:error];
    }
    return result;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00161b55 @ 00161b55, 293 bytes * /

id FUN_00161b55(HSWebcamWorkshopController *self,SEL _cmd,id outlineView,int child,id ofItem)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  cfstringStruct *pcVar4;
  
  if ((ofItem == (id)0x0) && (child == 0)) {
    pvVar1 = _objc_msgSend(self->_categoryItemsCache,sel_allKeys);
    pvVar3 = _objc_msgSend(pvVar1,sel_indexOfObjectIdenticalTo_,&cfstr_0);
LAB_00161c23:
    pvVar3 = _objc_msgSend(pvVar1,sel_objectAtIndex_,pvVar3);
  }
  else {
    pcVar4 = &cfstr_0;
    pvVar3 = (id)(child + -1);
    if (ofItem != (id)0x0) {
      pvVar3 = (id)child;
      pcVar4 = ofItem;
    }
    pvVar1 = _objc_msgSend(self->_categoryItemsCache,sel_objectForKey_,pcVar4);
    pcVar4 = &cfstr_HSWCCacheCategorySubitems;
    pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_HSWCCacheCategorySubitems);
    if ((pvVar1 != (id)0x0) && (pvVar2 = _objc_msgSend(pvVar1,sel_count,pcVar4), pvVar3 < pvVar2)) {
      pvVar2 = _objc_msgSend(pvVar1,sel_objectAtIndex_,pvVar3);
      pvVar2 = _objc_msgSend(pvVar2,sel_length);
      if (pvVar2 != (id)0x0) goto LAB_00161c23;
    }
    pvVar3 = (id)0x0;
  }
  return pvVar3;
}

*/
- (id)outlineView:(id)aView child:(NSInteger)aChild ofItem:(id)aItem
{
    if (aItem == nil && aChild == 0) {
        return HSWebcamWorkshopRootItem(_categoryItemsCache);
    }
    NSInteger index = aItem != nil ? aChild : aChild - 1;
    NSArray *subitems = [[_categoryItemsCache objectForKey:(aItem != nil ? aItem : @"0")] objectForKey:@"HSWCCacheCategorySubitems"];
    if (subitems != nil && (NSUInteger)index < [subitems count] && [[subitems objectAtIndex:index] length] != 0) {
        return [subitems objectAtIndex:index];
    }
    return nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00161a1b @ 00161a1b, 314 bytes * /

void FUN_00161a1b(HSWebcamWorkshopController *self,SEL _cmd)

{
  id pvVar1;
  
  _objc_msgSend(self->_outlineSelectionChangeTimer,sel_invalidate);
  _objc_msgSend(self->_outlineSelectionChangeTimer,sel_autorelease);
  pvVar1 = _objc_msgSend(cls_NSTimer,
                         sel_scheduledTimerWithTimeInterval_target_selector_userInfo_repeats_,0,
                         0x3ff00000,self,sel_reloadWebCams_,0,0);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_outlineSelectionChangeTimer = pvVar1;
  pvVar1 = _objc_msgSend(cls_NSRunLoop,sel_currentRunLoop);
  _objc_msgSend(pvVar1,sel_addTimer_forMode_,self->_outlineSelectionChangeTimer,
                *(undefined4 *)PTR_003361b4);
  _objc_msgSend(pvVar1,sel_addTimer_forMode_,self->_outlineSelectionChangeTimer,
                *(undefined4 *)PTR_00336064);
  _objc_msgSend(pvVar1,sel_addTimer_forMode_,self->_outlineSelectionChangeTimer,
                *(undefined4 *)PTR_003363f8);
  return;
}

*/
- (void)setNeedToReloadCams
{
    [_outlineSelectionChangeTimer invalidate];
    [_outlineSelectionChangeTimer autorelease];
    _outlineSelectionChangeTimer = HSWebcamWorkshopScheduleTimer(1.0, self, @selector(reloadWebCams:));
}

- (void)onFilter:(id)aFilter
{
    id pvVar2;

    pvVar2 = _outlineView;
    if ([pvVar2 itemAtRow:[pvVar2 selectedRow]] != nil) {
        [self setNeedToReloadCams];
    }
}

- (void)onHelp:(id)aHelp
{
    [[HSHelpBookManager sharedHelpBookManager] openHelpTopic:@"HSWebcamWorkshop"];
}

- (void)onCloseSheet:(id)aSheet
{
    [_filterField setStringValue:@""];
    [NSApp endSheet:_sheetPanel returnCode:0];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001617d8 @ 001617d8, 321 bytes * /

void FUN_001617d8(HSWebcamWorkshopController *self,SEL _cmd,id removeFromFavouriteWebCams)

{
  undefined *self_00;
  id self_01;
  id self_02;
  id pvVar1;
  id self_03;
  id pvVar2;
  
  self_01 = _objc_msgSend(self->_webCamContainerView,sel_selectedRowIndexes);
  self_02 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  self_00 = cls_NSMutableArray;
  pvVar1 = _objc_msgSend(self_02,sel_objectForKey_,&cfstr_HSWebCamWorkshopFavouriteWebCamIDs);
  self_03 = _objc_msgSend(self_00,sel_arrayWithArray_,pvVar1);
  for (pvVar1 = _objc_msgSend(self_01,sel_firstIndex); pvVar1 != (id)0x7fffffff;
      pvVar1 = _objc_msgSend(self_01,sel_indexGreaterThanIndex_,pvVar1)) {
    pvVar2 = _objc_msgSend(self->_selectedCamIDs,sel_objectAtIndex_,pvVar1);
    _objc_msgSend(self_03,sel_removeObject_,pvVar2);
  }
  _objc_msgSend(self_02,sel_setObject_forKey_,self_03,&cfstr_HSWebCamWorkshopFavouriteWebCamIDs);
  _objc_msgSend(self,sel_reloadWebCams_,0);
  return;
}

*/
- (void)removeFromFavouriteWebCams:(id)aCams
{
    NSIndexSet *rows = [_webCamContainerView selectedRowIndexes];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favourites = [NSMutableArray arrayWithArray:[defaults objectForKey:@"HSWebCamWorkshopFavouriteWebCamIDs"]];
    NSUInteger index;

    for (index = [rows firstIndex]; index != NSNotFound; index = [rows indexGreaterThanIndex:index]) {
        [favourites removeObject:[_selectedCamIDs objectAtIndex:index]];
    }
    [defaults setObject:favourites forKey:@"HSWebCamWorkshopFavouriteWebCamIDs"];
    [self reloadWebCams:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0016168e @ 0016168e, 330 bytes * /

void FUN_0016168e(HSWebcamWorkshopController *self,SEL _cmd,id addToFavouritesWebcam)

{
  undefined *self_00;
  id self_01;
  id self_02;
  id pvVar1;
  id self_03;
  id pvVar2;
  id pvVar3;
  
  self_01 = _objc_msgSend(self->_webCamContainerView,sel_selectedRowIndexes);
  self_02 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  self_00 = cls_NSMutableArray;
  pvVar1 = _objc_msgSend(self_02,sel_objectForKey_,&cfstr_HSWebCamWorkshopFavouriteWebCamIDs);
  self_03 = _objc_msgSend(self_00,sel_arrayWithArray_,pvVar1);
  for (pvVar1 = _objc_msgSend(self_01,sel_firstIndex); pvVar1 != (id)0x7fffffff;
      pvVar1 = _objc_msgSend(self_01,sel_indexGreaterThanIndex_,pvVar1)) {
    pvVar2 = _objc_msgSend(self->_selectedCamIDs,sel_objectAtIndex_,pvVar1);
    pvVar3 = _objc_msgSend(self_03,sel_containsObject_,pvVar2);
    if ((char)pvVar3 == '\0') {
      _objc_msgSend(self_03,sel_addObject_,pvVar2);
    }
  }
  _objc_msgSend(self_02,sel_setObject_forKey_,self_03,&cfstr_HSWebCamWorkshopFavouriteWebCamIDs);
  return;
}

*/
- (void)addToFavouritesWebcam:(id)aWebcam
{
    NSIndexSet *rows = [_webCamContainerView selectedRowIndexes];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favourites = [NSMutableArray arrayWithArray:[defaults objectForKey:@"HSWebCamWorkshopFavouriteWebCamIDs"]];
    NSUInteger index;

    for (index = [rows firstIndex]; index != NSNotFound; index = [rows indexGreaterThanIndex:index]) {
        id camID = [_selectedCamIDs objectAtIndex:index];
        if (![favourites containsObject:camID]) {
            [favourites addObject:camID];
        }
    }
    [defaults setObject:favourites forKey:@"HSWebCamWorkshopFavouriteWebCamIDs"];
}

- (void)addToCardWebcam:(id)aWebcam
{
    [_filterField setStringValue:@""];
    [NSApp endSheet:_sheetPanel returnCode:1];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001646d3 @ 001646d3, 851 bytes * /

void FUN_001646d3(HSWebcamWorkshopController *self,SEL _cmd,id changeTab)

{
  id pvVar1;
  id pvVar2;
  undefined4 *puVar3;
  float local_24;
  float local_20;
  float local_1c;
  float local_18;
  
  puVar3 = (undefined4 *)&stack0xffffffb4;
  pvVar1 = _objc_msgSend(self->_sheetPanelTitleTextField,sel_isHidden);
  pvVar2 = _objc_msgSend(self->_segmentedControl,sel_selectedSegment);
  if ((id)(uint)((char)pvVar1 != '\0') != pvVar2) {
    pvVar1 = _objc_msgSend(self->_webCamContainerView,sel_enclosingScrollView);
    if (pvVar2 == (id)0x0) {
      _objc_msgSend(pvVar1,sel_removeFromSuperview);
      pvVar1 = _objc_msgSend(self->_webCamContainerView,sel_enclosingScrollView);
      _objc_msgSend(pvVar1,sel_setFrame_);
      pvVar1 = self->_splitView;
      _objc_msgSend(self->_outlineView,sel_enclosingScrollView);
      _objc_msgSend(pvVar1,sel_addSubview_);
      pvVar1 = self->_splitView;
      _objc_msgSend(self->_webCamContainerView,sel_enclosingScrollView);
      _objc_msgSend(pvVar1,sel_addSubview_);
      _objc_msgSend(self->_sheetPanel,sel_makeFirstResponder_);
      _objc_msgSend(self->_addToFavouritesButton,sel_setAction_);
      pvVar1 = self->_addToFavouritesButton;
      pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
      _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_);
      _objc_msgSend(pvVar1,sel_setTitle_);
    }
    else {
      _objc_msgSend_stret(&local_24,pvVar1,sel_frame);
      puVar3 = (undefined4 *)&stack0xffffffb0;
      (self->_webCamContainerViewFrame).origin.x = local_24;
      (self->_webCamContainerViewFrame).origin.y = local_20;
      (self->_webCamContainerViewFrame).size.width = local_1c;
      (self->_webCamContainerViewFrame).size.height = local_18;
      pvVar1 = _objc_msgSend(self->_outlineView,sel_enclosingScrollView);
      _objc_msgSend(pvVar1,sel_removeFromSuperview);
      _objc_msgSend(self->_sheetPanel,sel_makeFirstResponder_);
      _objc_msgSend(self->_addToFavouritesButton,sel_setAction_);
      pvVar1 = self->_addToFavouritesButton;
      pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
      _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_);
      _objc_msgSend(pvVar1,sel_setTitle_);
    }
    puVar3[-1] = 0x1649ce;
    _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
    pvVar1 = self->_splitView;
    puVar3[1] = sel_adjustSubviews;
    *puVar3 = pvVar1;
    puVar3[-1] = 0x1649e5;
    _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
    pvVar1 = self->_filterField;
    puVar3[2] = &cfstr_empty;
    puVar3[1] = sel_setStringValue_;
    *puVar3 = pvVar1;
    puVar3[-1] = 0x164a04;
    _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
    puVar3[1] = sel_reloadWebCams_;
    *puVar3 = self;
    puVar3[2] = 0;
    puVar3[-1] = 0x164a1e;
    _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
  }
  return;
}

*/
- (void)changeTab:(id)aTab
{
    NSInteger segment = [_segmentedControl selectedSegment];

    if ((NSInteger)([_sheetPanelTitleTextField isHidden] ? 1 : 0) == segment) {
        return;
    }
    NSScrollView *containerScrollView = [_webCamContainerView enclosingScrollView];
    if (segment == 0) {
        [containerScrollView removeFromSuperview];
        [[_webCamContainerView enclosingScrollView] setFrame:_webCamContainerViewFrame];
        [_splitView addSubview:[_outlineView enclosingScrollView]];
        [_splitView addSubview:[_webCamContainerView enclosingScrollView]];
        [_sheetPanel makeFirstResponder:_webCamContainerView];
        [_addToFavouritesButton setAction:@selector(addToFavouritesWebcam:)];
        [_addToFavouritesButton setTitle:[[NSBundle mainBundle] localizedStringForKey:@"Add to Favorites" value:@"" table:nil]];
        [_sheetPanelTitleTextField setHidden:NO];
    }
    else {
        _webCamContainerViewFrame = [containerScrollView frame];
        [[_outlineView enclosingScrollView] removeFromSuperview];
        [_sheetPanel makeFirstResponder:_webCamContainerView];
        [_addToFavouritesButton setAction:@selector(removeFromFavouriteWebCams:)];
        [_addToFavouritesButton setTitle:[[NSBundle mainBundle] localizedStringForKey:@"Remove from Favorites" value:@"" table:nil]];
        [_sheetPanelTitleTextField setHidden:YES];
    }
    [_splitView adjustSubviews];
    [_filterField setStringValue:@""];
    [self reloadWebCams:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00164a26 @ 00164a26, 1587 bytes * /

void FUN_00164a26(HSWebcamWorkshopController *self,SEL _cmd,id panelDidEnd,int returnCode,
                 void *contextInfo)

{
  undefined *self_00;
  char cVar1;
  id pvVar2;
  id self_01;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id self_02;
  id pvVar6;
  id pvVar7;
  HSWebcamWorkshopController *self_03;
  float extraout_EDX;
  float extraout_EDX_00;
  float extraout_EDX_01;
  float extraout_EDX_02;
  double dVar8;
  SEL op;
  undefined *puVar9;
  float fVar10;
  id *ppvVar11;
  cfstringStruct *pcVar12;
  cfstringStruct *pcVar13;
  cfstringStruct *pcVar14;
  cfstringStruct *pcVar15;
  undefined4 uVar16;
  HSWebcamWorkshopController *local_34;
  id local_14;
  
  _objc_msgSend(self->_webCamImageLoader,sel_cancelAllRequests);
  _objc_msgSend(self->_webCamImageLoader,sel_autorelease);
  self->_webCamImageLoader = (id)0x0;
  _objc_msgSend(self->_webCamPreviewView,sel_stopPlaying);
  _objc_msgSend(panelDidEnd,sel_orderOut_,self);
  puVar9 = sel_webcamWorkshopSheetDidEnd_returnCode_contextInfo_invalidWebCamsWasPresent_;
  pvVar2 = _objc_msgSend(self->_delegate,sel_respondsToSelector_,
                         sel_webcamWorkshopSheetDidEnd_returnCode_contextInfo_invalidWebCamsWasPresent_
                        );
  if ((char)pvVar2 != '\0') {
    if (returnCode == 1) {
      self_01 = _objc_msgSend(self->_webCamContainerView,sel_selectedRowIndexes,puVar9);
      pvVar2 = _objc_msgSend(self_01,sel_count);
      local_34 = _objc_msgSend(cls_NSMutableArray,sel_arrayWithCapacity_,pvVar2);
      pvVar2 = _objc_msgSend(self_01,sel_firstIndex);
      puVar9 = PTR_0033607c;
      for (; pvVar2 != (id)0x7fffffff;
          pvVar2 = _objc_msgSend(self_01,sel_indexGreaterThanIndex_,pvVar2)) {
        pvVar3 = _objc_msgSend(self->_selectedCamIDs,sel_objectAtIndex_,pvVar2);
        pcVar15 = &cfstr_sourcePageURL;
        pcVar14 = &cfstr_copyright;
        pcVar13 = &cfstr_timeZoneName;
        pcVar12 = &cfstr_originalSize;
        uVar16 = 0;
        pvVar4 = _objc_msgSend(cls_NSArray,sel_arrayWithObjects_,&cfstr_name,&cfstr_location,
                               &cfstr_framerate,&cfstr_originalSize,&cfstr_timeZoneName,
                               &cfstr_copyright,&cfstr_sourcePageURL,0);
        local_14 = (id)0x0;
        pvVar5 = _objc_msgSend(cls_HSWebCamDataProvider,sel_sharedWebCamDataProvider);
        ppvVar11 = &local_14;
        pvVar6 = pvVar3;
        self_02 = _objc_msgSend(pvVar5,sel_attributes_forWebCam_error_,pvVar4,pvVar3,ppvVar11);
        self_03 = self;
        op = sel_reportError_;
        pvVar5 = local_14;
        if (local_14 == (id)0x0) {
          pvVar5 = _objc_msgSend(cls_HSWebPageObject,sel_alloc,pvVar4,pvVar6,ppvVar11,pcVar12,
                                 pcVar13,pcVar14,pcVar15,uVar16);
          pvVar5 = _objc_msgSend(pvVar5,sel_init);
          pvVar5 = _objc_msgSend(pvVar5,sel_autorelease);
          pvVar6 = _objc_msgSend(self_02,sel_objectForKey_,&cfstr_originalSize);
          pvVar4 = _objc_msgSend(pvVar6,sel_sizeValue);
          pvVar6 = _objc_msgSend(pvVar5,sel_queryHyperInterface_,&DAT_00374a98);
          cVar1 = _NSEqualSizes(pvVar4,extraout_EDX,*(undefined4 *)puVar9,
                                *(undefined4 *)(puVar9 + 4));
          fVar10 = extraout_EDX;
          if (cVar1 != '\0') {
            pvVar4 = _objc_msgSend(pvVar6,sel_defaultSize);
            fVar10 = extraout_EDX_00;
          }
          _objc_msgSend(pvVar6,sel_setSize_,pvVar4,fVar10);
          pvVar4 = _objc_msgSend(pvVar6,sel_size);
          pvVar7 = _objc_msgSend(cls_NSDocumentController,sel_sharedDocumentController);
          pvVar7 = _objc_msgSend(pvVar7,sel_currentDocument);
          pvVar7 = _objc_msgSend(pvVar7,sel_stack);
          pvVar7 = _objc_msgSend(pvVar7,sel_hyperCardSize);
          if (((float)pvVar7 < (float)pvVar4) || (extraout_EDX_02 < extraout_EDX_01)) {
            fVar10 = extraout_EDX_02;
            _objc_msgSend(pvVar6,sel_setSize_,pvVar7,extraout_EDX_02);
          }
          _objc_msgSend(pvVar5,sel_setPageCameraID_,pvVar3,fVar10);
          _objc_msgSend(pvVar5,sel_setHyperOpacity_,0x3f800000);
          pvVar3 = _objc_msgSend(self_02,sel_objectForKey_,&cfstr_name);
          pvVar6 = (id)0x0;
          _objc_msgSend(pvVar5,sel_setHyperName_usingTemplateName_,pvVar3,0);
          _objc_msgSend(pvVar5,sel_setPageTitle_,pvVar3);
          pvVar3 = _objc_msgSend(self_02,sel_objectForKey_,&cfstr_location);
          _objc_msgSend(pvVar5,sel_setPageLocation_,pvVar3);
          pvVar3 = _objc_msgSend(self_02,sel_objectForKey_,&cfstr_framerate);
          dVar8 = _objc_msgSend_fpret(pvVar3,sel_floatValue);
          if (0.0 < (float)dVar8) {
            _objc_msgSend(pvVar5,sel_setPageRefreshRate_,(float)dVar8);
          }
          pvVar3 = _objc_msgSend(self_02,sel_objectForKey_,&cfstr_timeZoneName);
          _objc_msgSend(pvVar5,sel_setPageTimeZone_,pvVar3);
          pvVar3 = _objc_msgSend(self_02,sel_objectForKey_,&cfstr_copyright);
          _objc_msgSend(pvVar5,sel_setPageCopyright_,pvVar3);
          self_00 = cls_NSURL;
          pvVar3 = _objc_msgSend(self_02,sel_objectForKey_,&cfstr_sourcePageURL);
          pvVar3 = _objc_msgSend(self_00,sel_URLWithString_,pvVar3);
          _objc_msgSend(pvVar5,sel_setPageURL_,pvVar3);
          self_03 = local_34;
          op = sel_addObject_;
        }
        _objc_msgSend(self_03,op,pvVar5,pvVar6,ppvVar11,pcVar12,pcVar13,pcVar14,pcVar15,uVar16);
      }
    }
    else {
      local_34 = (HSWebcamWorkshopController *)0x0;
    }
    _objc_msgSend(self->_delegate,
                  sel_webcamWorkshopSheetDidEnd_returnCode_contextInfo_invalidWebCamsWasPresent_,
                  panelDidEnd,returnCode,local_34,0);
  }
  return;
}

*/
- (void)panelDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    NSMutableArray *webPages = nil;

    [_webCamImageLoader cancelAllRequests];
    [_webCamImageLoader autorelease];
    _webCamImageLoader = nil;
    [_webCamPreviewView stopPlaying];
    [aEnd orderOut:self];
    if (![_delegate respondsToSelector:@selector(webcamWorkshopSheetDidEnd:returnCode:contextInfo:invalidWebCamsWasPresent:)]) {
        return;
    }
    if (aCode == 1) {
        NSIndexSet *rows = [_webCamContainerView selectedRowIndexes];
        NSUInteger index;
        webPages = [NSMutableArray arrayWithCapacity:[rows count]];
        for (index = [rows firstIndex]; index != NSNotFound; index = [rows indexGreaterThanIndex:index]) {
            id camID = [_selectedCamIDs objectAtIndex:index];
            NSArray *keys = [NSArray arrayWithObjects:@"name", @"location", @"framerate", @"originalSize", @"timeZoneName", @"copyright", @"sourcePageURL", nil];
            NSError *error = nil;
            id attributes = [[HSWebCamDataProvider sharedWebCamDataProvider] attributes:keys forWebCam:camID error:&error];
            if (error != nil) {
                [self reportError:error];
                continue;
            }
            HSWebPageObject *webPage = [[[HSWebPageObject alloc] init] autorelease];
            NSSize size = [[attributes objectForKey:@"originalSize"] sizeValue];
            id sizeAttributes = [webPage queryHyperInterface:@protocol(HSMutableSizeAttributes)];
            if (NSEqualSizes(size, NSZeroSize)) {
                size = [sizeAttributes defaultSize];
            }
            [(id<HSMutableSizeAttributes>)sizeAttributes setSize:size];
            size = [(id<HSMutableSizeAttributes>)sizeAttributes size];
            NSSize cardSize = [[[[NSDocumentController sharedDocumentController] currentDocument] stack] hyperCardSize];
            if (cardSize.width < size.width || cardSize.height < size.height) {
                [(id<HSMutableSizeAttributes>)sizeAttributes setSize:cardSize];
            }
            [webPage setPageCameraID:camID];
            [webPage setHyperOpacity:1.0];
            id name = [attributes objectForKey:@"name"];
            [webPage setHyperName:name usingTemplateName:NO];
            [webPage setPageTitle:name];
            [webPage setPageLocation:[attributes objectForKey:@"location"]];
            float rate = [[attributes objectForKey:@"framerate"] floatValue];
            if (0.0f < rate) {
                [webPage setPageRefreshRate:rate];
            }
            [webPage setPageTimeZone:[attributes objectForKey:@"timeZoneName"]];
            [webPage setPageCopyright:[attributes objectForKey:@"copyright"]];
            [webPage setPageURL:[NSURL URLWithString:[attributes objectForKey:@"sourcePageURL"]]];
            [webPages addObject:webPage];
        }
    }
    [_delegate webcamWorkshopSheetDidEnd:aEnd returnCode:aCode contextInfo:webPages invalidWebCamsWasPresent:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0016144c @ 0016144c, 482 bytes * /

void FUN_0016144c(HSWebcamWorkshopController *self,SEL _cmd)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  SEL pcVar4;
  
  puVar1 = cls_NSBundle;
  pcVar4 = sel_loadNibNamed_owner_;
  if (self->_sheetPanel != (id)0x0) {
    pvVar2 = _objc_msgSend(self->_outlineView,sel_numberOfRows);
    if (pvVar2 != (id)0x0) goto LAB_001614b7;
    puVar1 = self->_outlineView;
    pcVar4 = sel_reloadData;
  }
  _objc_msgSend(puVar1,pcVar4);
LAB_001614b7:
  pvVar2 = _objc_msgSend(self->_webCamContainerView,sel_selectedRow);
  pvVar3 = self->_webCamContainerView;
  pcVar4 = sel_scrollRowToVisible_;
  if (pvVar2 == (id)0x7fffffff) {
    pvVar2 = _objc_msgSend(pvVar3,sel_enclosingScrollView);
    pvVar3 = _objc_msgSend(pvVar2,sel_contentView);
    pvVar2 = *(id *)PTR_00336074;
    pcVar4 = sel_scrollToPoint_;
  }
  _objc_msgSend(pvVar3,pcVar4,pvVar2);
  pvVar2 = _objc_msgSend(self->_webCamContainerView,sel_enclosingScrollView);
  pvVar3 = _objc_msgSend(self->_webCamContainerView,sel_enclosingScrollView);
  pvVar3 = _objc_msgSend(pvVar3,sel_contentView);
  _objc_msgSend(pvVar2,sel_reflectScrolledClipView_,pvVar3);
  _objc_msgSend(self->_filterField,sel_setStringValue_,&cfstr_empty);
  _objc_msgSend(self,sel_reloadWebCams_,0);
  puVar1 = sel_panelDidEnd_returnCode_contextInfo_;
  pvVar2 = *(id *)PTR_00336058;
  pvVar3 = _objc_msgSend(pvVar2,sel_mainWindow);
  _objc_msgSend(pvVar2,sel_beginSheet_modalForWindow_modalDelegate_didEndSelector_contextInfo_,
                self->_sheetPanel,pvVar3,self,puVar1,0);
  return;
}

*/
- (void)runModal
{
    if (_sheetPanel == nil) {
        [NSBundle loadNibNamed:@"WebcamWorkshopPanel" owner:self];
    }
    else if ([_outlineView numberOfRows] == 0) {
        [_outlineView reloadData];
    }
    NSInteger row = [_webCamContainerView selectedRow];
    // The original only tested for NSNotFound, but an empty selection reports -1.
    if (row == NSNotFound || row == -1) {
        [[[_webCamContainerView enclosingScrollView] contentView] scrollToPoint:NSZeroPoint];
    }
    else {
        [_webCamContainerView scrollRowToVisible:row];
    }
    [[_webCamContainerView enclosingScrollView] reflectScrolledClipView:[[_webCamContainerView enclosingScrollView] contentView]];
    [_filterField setStringValue:@""];
    [self reloadWebCams:nil];
    [NSApp beginSheet:_sheetPanel modalForWindow:[NSApp mainWindow] modalDelegate:self didEndSelector:@selector(panelDidEnd:returnCode:contextInfo:) contextInfo:NULL];
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
/* FUN_00161356 @ 00161356, 246 bytes * /

void FUN_00161356(HSWebcamWorkshopController *self,SEL _cmd,id filterRuleChanged)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  int iVar3;
  
  pvVar1 = _objc_msgSend(filterRuleChanged,sel_tag);
  self->_currentFilterRuleTag = (int)pvVar1;
  pvVar1 = _objc_msgSend(filterRuleChanged,sel_menu);
  pvVar1 = _objc_msgSend(pvVar1,sel_itemArray);
  pvVar2 = _objc_msgSend(pvVar1,sel_count);
  if (0 < (int)pvVar2) {
    iVar3 = 0;
    do {
      self_00 = _objc_msgSend(pvVar1,sel_objectAtIndex_,iVar3);
      _objc_msgSend(self_00,sel_setState_,(uint)(self_00 == filterRuleChanged));
      iVar3 = iVar3 + 1;
    } while (iVar3 < (int)pvVar2);
  }
  pvVar1 = _objc_msgSend(self->_filterField,sel_stringValue);
  pvVar1 = _objc_msgSend(pvVar1,sel_length);
  if (pvVar1 != (id)0x0) {
    _objc_msgSend(self,sel_setNeedToReloadCams);
  }
  return;
}

*/
- (void)filterRuleChanged:(id)aChanged
{
    _currentFilterRuleTag = (int)[aChanged tag];
    NSArray *items = [[aChanged menu] itemArray];
    int count = (int)[items count];
    int index;
    for (index = 0; index < count; index++) {
        id item = [items objectAtIndex:index];
        [item setState:(item == aChanged ? NSControlStateValueOn : NSControlStateValueOff)];
    }
    if ([[_filterField stringValue] length] != 0) {
        [self setNeedToReloadCams];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00160c17 @ 00160c17, 1855 bytes * /

void FUN_00160c17(HSWebcamWorkshopController *self,SEL _cmd)

{
  undefined4 uVar1;
  undefined4 uVar2;
  undefined *self_00;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  
  pvVar3 = _objc_msgSend(self->_outlineView,sel_enclosingScrollView);
  _objc_msgSend(pvVar3,sel_retain);
  pvVar3 = _objc_msgSend(self->_webCamContainerView,sel_enclosingScrollView);
  _objc_msgSend(pvVar3,sel_retain);
  _objc_msgSend(self->_webCamContainerView,sel_setDoubleAction_,sel_addToCardWebcam_);
  pvVar3 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,
                         &cfstr_Please_wait_for_webcams_to_load___,&cfstr_empty,0);
  self_00 = cls_NSDictionary;
  uVar1 = *(undefined4 *)PTR_00336394;
  pvVar4 = _objc_msgSend(cls_NSColor,sel_grayColor);
  uVar2 = *(undefined4 *)PTR_00336068;
  pvVar5 = _objc_msgSend(cls_NSFont,sel_boldSystemFontOfSize_,0x41800000);
  pvVar4 = _objc_msgSend(self_00,sel_dictionaryWithObjectsAndKeys_,pvVar5,uVar2,pvVar4,uVar1,0);
  pvVar5 = _objc_msgSend(cls_NSAttributedString,sel_alloc);
  pvVar3 = _objc_msgSend(pvVar5,sel_initWithString_attributes_,pvVar3,pvVar4);
  _objc_msgSend(self->_placeholderView,sel_setTitle_,pvVar3);
  pvVar3 = _objc_msgSend(cls_HSWebCamDataProvider,sel_sharedWebCamDataProvider);
  _objc_msgSend(pvVar3,sel_setApplicationIdentifier_,&cfstr_com_mackiev_hyperstudio);
  pvVar3 = _objc_msgSend(cls_NSMutableDictionary,sel_alloc);
  pvVar4 = _objc_msgSend(cls_NSMutableDictionary,sel_dictionary);
  pvVar3 = _objc_msgSend(pvVar3,sel_initWithObjectsAndKeys_,pvVar4,&cfstr_0,0);
  self->_categoryItemsCache = pvVar3;
  _objc_msgSend(self->_splitView,sel_setDividerThickness_,0x41200000);
  pvVar3 = self->_addToFavouritesButton;
  pvVar4 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,&cfstr_Add_to_Favorites,
                         &cfstr_empty,0);
  _objc_msgSend(pvVar3,sel_setTitle_,pvVar4);
  _objc_msgSend(self->_confirmButton,sel_setEnabled_,0);
  _objc_msgSend(self->_addToFavouritesButton,sel_setEnabled_,0);
  _objc_msgSend(self->_webCamContainerViewCounterTextField,sel_setHidden_,1);
  pvVar3 = _objc_msgSend(self->_outlineView,sel_tableColumns);
  pvVar3 = _objc_msgSend(pvVar3,sel_objectAtIndex_,0);
  pvVar4 = _objc_msgSend(cls_HSImageTextTableCell,sel_alloc);
  pvVar4 = _objc_msgSend(pvVar4,sel_initTextCell_,&cfstr_empty);
  pvVar4 = _objc_msgSend(pvVar4,sel_autorelease);
  _objc_msgSend(pvVar4,sel_setImageTextPosition_,1);
  _objc_msgSend(pvVar4,sel_setControlSize_,1);
  _objc_msgSend(pvVar4,sel_setLineBreakMode_,5);
  _objc_msgSend(pvVar3,sel_setDataCell_,pvVar4);
  pvVar3 = _objc_msgSend(self->_webCamContainerView,sel_tableColumns);
  pvVar3 = _objc_msgSend(pvVar3,sel_objectAtIndex_,1);
  pvVar4 = _objc_msgSend(cls_NSImageCell,sel_alloc);
  pvVar4 = _objc_msgSend(pvVar4,sel_initImageCell_,0);
  pvVar4 = _objc_msgSend(pvVar4,sel_autorelease);
  _objc_msgSend(pvVar3,sel_setDataCell_,pvVar4);
  pvVar3 = _objc_msgSend(self->_webCamContainerView,sel_enclosingScrollView);
  pvVar3 = _objc_msgSend(pvVar3,sel_contentView);
  pvVar4 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar4,sel_addObserver_selector_name_object_,self,sel_tableViewDidScrolled_,
                *(undefined4 *)PTR_00336574,pvVar3);
  _objc_msgSend(pvVar3,sel_setPostsBoundsChangedNotifications_,1);
  pvVar3 = _objc_msgSend(self->_filterField,sel_cell);
  _objc_msgSend(pvVar3,sel_setSearchMenuTemplate_,self->_filterRulesMenu);
  pvVar3 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar4 = _objc_msgSend(&cfstr_WebCamShortInfoTemplate_rtf,sel_pathExtension);
  pvVar5 = _objc_msgSend(&cfstr_WebCamShortInfoTemplate_rtf,sel_stringByDeletingPathExtension);
  pvVar3 = _objc_msgSend(pvVar3,sel_pathForResource_ofType_,pvVar5,pvVar4);
  pvVar4 = _objc_msgSend(cls_NSAttributedString,sel_alloc);
  pvVar3 = _objc_msgSend(pvVar4,sel_initWithPath_documentAttributes_,pvVar3,0);
  self->_shortInfoTemplate = pvVar3;
  _objc_msgSend(self,sel_displayInfoForCam_,0);
  pvVar3 = _objc_msgSend(cls_NSDistributedNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar3,sel_addObserver_selector_name_object_suspensionBehavior_,self,
                sel_webCamsFilterRequestDidExecute_,&cfstr_WCDPWebCamFilterResultNotification,0,2);
  _objc_msgSend(self->_outlineView,sel_reloadData);
  pvVar3 = self->_outlineView;
  pvVar4 = _objc_msgSend(cls_NSIndexSet,sel_indexSetWithIndex_,0);
  _objc_msgSend(pvVar3,sel_selectRowIndexes_byExtendingSelection_,pvVar4,0);
  _objc_msgSend(self->_sheetPanel,sel_makeFirstResponder_,self->_outlineView);
  _objc_msgSend(self->_filterField,sel_setEnabled_,1);
  _objc_msgSend(self->_outlineView,sel_setEnabled_,1);
  _objc_msgSend(self->_webCamPreviewView,sel_setWebCamViewDelegate_,self);
  return;
}

*/
- (void)awakeFromNib
{
    [[_outlineView enclosingScrollView] retain];
    [[_webCamContainerView enclosingScrollView] retain];
    [_webCamContainerView setDoubleAction:@selector(addToCardWebcam:)];
    NSString *waitString = [[NSBundle mainBundle] localizedStringForKey:@"Please wait for webcams to load..." value:@"" table:nil];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont boldSystemFontOfSize:16], NSFontAttributeName, [NSColor grayColor], NSForegroundColorAttributeName, nil];
    [_placeholderView setTitle:[[[NSAttributedString alloc] initWithString:waitString attributes:attributes] autorelease]];
    [[HSWebCamDataProvider sharedWebCamDataProvider] setApplicationIdentifier:@"com.mackiev.hyperstudio"];
    _categoryItemsCache = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSMutableDictionary dictionary], @"0", nil];
    [_splitView setDividerThickness:10];
    [_addToFavouritesButton setTitle:[[NSBundle mainBundle] localizedStringForKey:@"Add to Favorites" value:@"" table:nil]];
    [_confirmButton setEnabled:NO];
    [_addToFavouritesButton setEnabled:NO];
    [_webCamContainerViewCounterTextField setHidden:YES];
    NSTableColumn *column = [[_outlineView tableColumns] objectAtIndex:0];
    HSImageTextTableCell *cell = [[[HSImageTextTableCell alloc] initTextCell:@""] autorelease];
    [cell setImageTextPosition:1];
    [cell setControlSize:NSControlSizeSmall];
    [cell setLineBreakMode:NSLineBreakByTruncatingMiddle];
    [column setDataCell:cell];
    [[[_webCamContainerView tableColumns] objectAtIndex:1] setDataCell:[[[NSImageCell alloc] initImageCell:nil] autorelease]];
    NSClipView *clipView = [[_webCamContainerView enclosingScrollView] contentView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableViewDidScrolled:) name:NSViewBoundsDidChangeNotification object:clipView];
    [clipView setPostsBoundsChangedNotifications:YES];
    [[_filterField cell] setSearchMenuTemplate:_filterRulesMenu];
    NSString *templateName = @"WebCamShortInfoTemplate.rtf";
    NSString *path = [[NSBundle mainBundle] pathForResource:[templateName stringByDeletingPathExtension] ofType:[templateName pathExtension]];
    _shortInfoTemplate = [[NSAttributedString alloc] initWithPath:path documentAttributes:NULL];
    [self displayInfoForCam:nil];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(webCamsFilterRequestDidExecute:) name:@"WCDPWebCamFilterResultNotification" object:nil suspensionBehavior:NSNotificationSuspensionBehaviorCoalesce];
    [_outlineView reloadData];
    [_outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    [_sheetPanel makeFirstResponder:_outlineView];
    [_filterField setEnabled:YES];
    [_outlineView setEnabled:YES];
    [_webCamPreviewView setWebCamViewDelegate:self];
}

- (void)dealloc
{
    int uVar3;

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
    uVar3 = 0;
    [_webCamPreviewView setWebCamViewDelegate:nil];
    [_outlineSelectionChangeTimer invalidate];
    [_outlineSelectionChangeTimer release];
    [_webCamViewSelectionChangeTimer invalidate];
    [_webCamViewSelectionChangeTimer release];
    [_webCamViewScrollTimer invalidate];
    [_webCamViewScrollTimer release];
    if ([_webCamContainerView delegate] == self) {
        uVar3 = 0;
        [_webCamContainerView setDelegate:0];
    }
    [[_outlineView enclosingScrollView] release];
    [[_webCamContainerView enclosingScrollView] release];
    [_selectedCamIDs release];
    [_categoryItemsCache release];
    [_shortInfoTemplate release];
    [_webCamImageLoader cancelAllRequests];
    [_webCamImageLoader release];
    [_webCamViewVisibleCams release];
    [super dealloc];
}

@end

@implementation NSObject (HSRefreshRateDisplayMapping)

/* --- i386 decompilation (Ghidra) ---
/* FUN_00160851 @ 00160851, 966 bytes * /

id FUN_00160851(id self,SEL _cmd,double localizedRefreshRateStringForRate)

{
  double dVar1;
  id pvVar2;
  undefined4 uVar3;
  
  if (DAT_00342998 == (id)0x0) {
    pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    DAT_00342998 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_1_second,
                                 &cfstr_empty,0);
  }
  if (DAT_0034299c == (id)0x0) {
    pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    DAT_0034299c = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr___0f_seconds,
                                 &cfstr_empty,0);
  }
  if (DAT_003429a0 == (id)0x0) {
    pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    DAT_003429a0 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_1_minute,
                                 &cfstr_empty,0);
  }
  if (DAT_003429a4 == (id)0x0) {
    pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    DAT_003429a4 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr___0f_minutes,
                                 &cfstr_empty,0);
  }
  if (DAT_003429a8 == (id)0x0) {
    pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    DAT_003429a8 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_Immediately,
                                 &cfstr_empty,0);
  }
  pvVar2 = DAT_0034299c;
  if (localizedRefreshRateStringForRate < 30.0) {
    if (localizedRefreshRateStringForRate < 5.0) {
      if (localizedRefreshRateStringForRate < 2.0) {
        if (localizedRefreshRateStringForRate < 1.0) {
          return DAT_003429a8;
        }
        return DAT_00342998;
      }
      dVar1 = 3.0;
      goto LAB_00160ab6;
    }
    if (localizedRefreshRateStringForRate < 15.0) {
      dVar1 = 10.0;
      goto LAB_00160a6f;
    }
    if (20.0 <= localizedRefreshRateStringForRate) {
      uVar3 = 0x40340000;
      goto LAB_00160b7c;
    }
  }
  else {
    if (localizedRefreshRateStringForRate < 300.0) {
      if (localizedRefreshRateStringForRate < 120.0) {
        if (60.0 <= localizedRefreshRateStringForRate) {
          return DAT_003429a0;
        }
        uVar3 = 0x403e0000;
        goto LAB_00160b7c;
      }
      dVar1 = 180.0;
      pvVar2 = DAT_003429a4;
LAB_00160ab6:
      if (localizedRefreshRateStringForRate < dVar1) {
        uVar3 = 0x40000000;
      }
      else {
        uVar3 = 0x40080000;
      }
      goto LAB_00160b7c;
    }
    pvVar2 = DAT_003429a4;
    if (localizedRefreshRateStringForRate < 900.0) {
      dVar1 = 600.0;
LAB_00160a6f:
      if (localizedRefreshRateStringForRate < dVar1) {
        uVar3 = 0x40140000;
      }
      else {
        uVar3 = 0x40240000;
      }
      goto LAB_00160b7c;
    }
  }
  uVar3 = 0x402e0000;
LAB_00160b7c:
  pvVar2 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,pvVar2,0,uVar3,0);
  return pvVar2;
}

*/
+ (id)localizedRefreshRateStringForRate:(double)aRate
{
    NSString *format = sSecondsFormat;
    double value;

    if (sOneSecondString == nil) {
        sOneSecondString = [[[NSBundle mainBundle] localizedStringForKey:@"1 second" value:@"" table:nil] retain];
    }
    if (sSecondsFormat == nil) {
        sSecondsFormat = [[[NSBundle mainBundle] localizedStringForKey:@"%.0f seconds" value:@"" table:nil] retain];
    }
    if (sOneMinuteString == nil) {
        sOneMinuteString = [[[NSBundle mainBundle] localizedStringForKey:@"1 minute" value:@"" table:nil] retain];
    }
    if (sMinutesFormat == nil) {
        sMinutesFormat = [[[NSBundle mainBundle] localizedStringForKey:@"%.0f minutes" value:@"" table:nil] retain];
    }
    if (sImmediatelyString == nil) {
        sImmediatelyString = [[[NSBundle mainBundle] localizedStringForKey:@"Immediately" value:@"" table:nil] retain];
    }
    format = sSecondsFormat;
    if (aRate < 1.0) {
        return sImmediatelyString;
    }
    else if (aRate < 2.0) {
        return sOneSecondString;
    }
    else if (aRate < 5.0) {
        value = aRate < 3.0 ? 2 : 3;
    }
    else if (aRate < 15.0) {
        value = aRate < 10.0 ? 5 : 10;
    }
    else if (aRate < 20.0) {
        value = 15;
    }
    else if (aRate < 30.0) {
        value = 20;
    }
    else if (aRate < 60.0) {
        value = 30;
    }
    else if (aRate < 120.0) {
        return sOneMinuteString;
    }
    else if (aRate < 300.0) {
        format = sMinutesFormat;
        value = aRate < 180.0 ? 2 : 3;
    }
    else if (aRate < 900.0) {
        format = sMinutesFormat;
        value = aRate < 600.0 ? 5 : 10;
    }
    else {
        format = sMinutesFormat;
        value = 15;
    }
    return [NSString stringWithFormat:format, value];
}

@end

