#import "HSImportDialogSoundPaneViewController.h"

@implementation HSImportDialogSoundPaneViewController

/* i386 ivar offsets: _paneAccessoryView=0x1c, _searchField=0x20, _playButtonImage=0x24, _playButtonAquaImage=0x28, _playButtonGraphiteImage=0x2c, _stopButtonImage=0x30, _stopButtonAquaImage=0x34, _stopButtonGraphiteImage=0x38, _playButtonCell=0x3c, _previewMovie=0x40, _previewMovieTimer=0x44, _paneView=0x48, _historyNavigationControl=0x4c, _browseTableView=0x50, _soundsTableView=0x54, _itemsCountTextField=0x58, _volumeSlider=0x5c, _volumeMin=0x60, _volumeMax=0x64, _currentSoundProgressField=0x68, _testButton=0x6c, _lineBreakInfo=0x70, _filteredItems=0x74, _filterString=0x78, _categoryString=0x7c, _sortAscending=0x80, _sortedIdentifier=0x84, _sortedArrayHint=0x88, _filePath=0x8c, _defaultSoundIcon=0x90 */

- (void)previewMovieTimerFireMethod:(id)aMethod
{
    [_currentSoundProgressField setObjectValue:[NSDate dateWithTimeIntervalSinceReferenceDate:[[NSDate date] timeIntervalSinceDate:[aMethod userInfo]]]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ba16e @ 001ba16e, 330 bytes * /

void FUN_001ba16e(HSImportDialogSoundPaneViewController *self,SEL _cmd)

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
    NSRunLoop *runLoop;
    _previewMovieTimer = [[NSTimer timerWithTimeInterval:1.0 target:[[self NSE_newWeakProxy] autorelease] selector:@selector(previewMovieTimerFireMethod:) userInfo:[NSDate date] repeats:YES] retain];
    runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:_previewMovieTimer forMode:NSDefaultRunLoopMode];
    [runLoop addTimer:_previewMovieTimer forMode:NSModalPanelRunLoopMode];
    [runLoop addTimer:_previewMovieTimer forMode:NSEventTrackingRunLoopMode];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ba0de @ 001ba0de, 144 bytes * /

void FUN_001ba0de(HSImportDialogSoundPaneViewController *self,SEL _cmd)

{
  id self_00;
  id pvVar1;
  undefined4 uVar2;
  
  self_00 = self->_currentSoundProgressField;
  uVar2 = 0;
  pvVar1 = _objc_msgSend(cls_NSDate,sel_dateWithTimeIntervalSinceReferenceDate_,0,0);
  _objc_msgSend(self_00,sel_setObjectValue_,pvVar1);
  if (self->_previewMovieTimer != (id)0x0) {
    _objc_msgSend(self->_previewMovieTimer,sel_invalidate,pvVar1,uVar2);
    _objc_msgSend(self->_previewMovieTimer,sel_release);
    self->_previewMovieTimer = (id)0x0;
  }
  return;
}

*/
- (void)stopPreviewMovieTimer
{
    [_currentSoundProgressField setObjectValue:[NSDate dateWithTimeIntervalSinceReferenceDate:0.0]];
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
        [_testButton setImage:_playButtonImage];
        [_playButtonCell setAquaAlternateImage:_playButtonAquaImage];
        pvVar1 = _playButtonGraphiteImage;
        self_00 = _playButtonCell;
    }
    else {
        [_testButton setImage:_stopButtonImage];
        [_playButtonCell setAquaAlternateImage:_stopButtonAquaImage];
        pvVar1 = _stopButtonGraphiteImage;
        self_00 = _playButtonCell;
    }
    [self_00 setGraphiteAlternateImage:pvVar1];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b9e2d @ 001b9e2d, 497 bytes * /

void FUN_001b9e2d(HSImportDialogSoundPaneViewController *self,SEL _cmd)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  int iVar4;
  HSImportDialogSoundPaneViewController *self_00;
  SEL op;
  undefined4 uVar5;
  
  pvVar2 = _objc_msgSend(self,sel_filePath);
  pvVar2 = _objc_msgSend(pvVar2,sel_length);
  puVar1 = cls_HSMovie;
  if (pvVar2 == (id)0x0) {
    _objc_msgSend(self,sel_setPreviewMovie_,0);
    self_00 = self->_currentSoundProgressField;
    uVar5 = 0;
    pvVar2 = _objc_msgSend(cls_NSDate,sel_dateWithTimeIntervalSinceReferenceDate_,0,0);
    op = sel_setObjectValue_;
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_zone);
    pvVar2 = _objc_msgSend(puVar1,sel_allocWithZone_,pvVar2);
    puVar1 = cls_NSURL;
    pvVar3 = _objc_msgSend(self,sel_filePath);
    pvVar3 = _objc_msgSend(puVar1,sel_fileURLWithPath_,pvVar3);
    uVar5 = 0;
    pvVar2 = _objc_msgSend(pvVar2,sel_initWithURL_error_,pvVar3,0);
    pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
    _objc_msgSend(self,sel_setPreviewMovie_,pvVar2);
    self_00 = self;
    op = sel_updatePreviewMovieVolume;
  }
  _objc_msgSend(self_00,op,pvVar2,uVar5);
  pvVar2 = _objc_msgSend(self,sel_previewMovie);
  pvVar2 = _objc_msgSend(pvVar2,sel_hasSound);
  iVar4 = (int)(char)pvVar2;
  _objc_msgSend(self->_testButton,sel_setEnabled_,iVar4);
  _objc_msgSend(self->_volumeSlider,sel_setEnabled_,iVar4);
  _objc_msgSend(self->_volumeMin,sel_setEnabled_,iVar4);
  _objc_msgSend(self->_volumeMax,sel_setEnabled_,iVar4);
  return;
}

*/
- (void)updatePreviewMovie
{
    BOOL hasSound;
    if ([[self filePath] length] == 0) {
        [self setPreviewMovie:nil];
        [_currentSoundProgressField setObjectValue:[NSDate dateWithTimeIntervalSinceReferenceDate:0.0]];
    }
    else {
        [self setPreviewMovie:[[[HSMovie allocWithZone:[self zone]] initWithURL:[NSURL fileURLWithPath:[self filePath]] error:NULL] autorelease]];
        [self updatePreviewMovieVolume];
    }
    hasSound = [[self previewMovie] hasSound];
    [_testButton setEnabled:hasSound];
    [_volumeSlider setEnabled:hasSound];
    [_volumeMin setEnabled:hasSound];
    [_volumeMax setEnabled:hasSound];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ba60b @ 001ba60b, 57 bytes * /

void FUN_001ba60b(HSImportDialogSoundPaneViewController *self,SEL _cmd)

{
  longdouble lVar1;
  
  lVar1 = (longdouble)_HSNonLinearValueForSlider(self->_volumeSlider);
  _objc_msgSend(self,sel_setPreviewMovieVolume_,(float)lVar1);
  return;
}

*/
- (void)updatePreviewMovieVolume
{
    [self setPreviewMovieVolume:HSNonLinearValueForSlider(_volumeSlider)];
}

- (void)setPreviewMovie:(id)aMovie
{
    id pvVar1_3;

    if (_previewMovie != aMovie) {
        if ([_previewMovie isPlaying]) {
            [self stopPreviewMovieTimer];
            [_previewMovie stop];
        }
        [self setImagesForPlayButton:((int)[_previewMovie isPlaying])];
        if ([_previewMovie delegate] == self) {
            [_previewMovie setDelegate:0];
        }
        [_previewMovie release];
        pvVar1_3 = [aMovie retain];
        _previewMovie = pvVar1_3;
        [pvVar1_3 setDelegate:self];
    }
}

- (id)previewMovie
{
    return _previewMovie;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ba644 @ 001ba644, 227 bytes * /

BOOL FUN_001ba644(HSImportDialogSoundPaneViewController *self,SEL _cmd,id mediaPathConformsToFilter)

{
  id pvVar1;
  id pvVar2;
  char cVar3;
  HSImportDialogSoundPaneViewController *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSImportDialogBasePaneViewContro_00353720;
  pvVar1 = _objc_msgSendSuper(&local_1c,sel_mediaPathConformsToFilter_,mediaPathConformsToFilter);
  cVar3 = (char)pvVar1;
  if (cVar3 != '\0') {
    pvVar1 = _objc_msgSend(self->_searchField,sel_stringValue);
    pvVar1 = _objc_msgSend(pvVar1,sel_length);
    if (pvVar1 != (id)0x0) {
      pvVar1 = _objc_msgSend(mediaPathConformsToFilter,sel_lastPathComponent);
      pvVar1 = _objc_msgSend(pvVar1,sel_stringByDeletingPathExtension);
      pvVar2 = _objc_msgSend(self->_searchField,sel_stringValue);
      pvVar1 = _objc_msgSend(pvVar1,sel_rangeOfString_options_,pvVar2,1);
      cVar3 = pvVar1 != (id)0x7fffffff;
    }
  }
  return cVar3;
}

*/
- (BOOL)mediaPathConformsToFilter:(id)aFilter
{
    if (![super mediaPathConformsToFilter:aFilter]) {
        return NO;
    }
    if ([[_searchField stringValue] length] == 0) {
        return YES;
    }
    return [[[aFilter lastPathComponent] stringByDeletingPathExtension] rangeOfString:[_searchField stringValue] options:NSCaseInsensitiveSearch].location != NSNotFound;
}

- (void)filter:(id)aFilter byCategory:(id)aCategory
{

}

- (void)invalidateSearch
{
    [_searchField setStringValue:@""];
    [self filter:@"" byCategory:nil];
}

- (void)movieDidStop:(id)aStop
{
    [self movieDidEnd:aStop];
}

- (void)movieDidPlayOnce:(id)aOnce
{
    [[self previewMovie] gotoBeginning];
    [self stopPreviewMovieTimer];
    [self startPreviewMovieTimer];
}

- (void)movieDidEnd:(id)aEnd
{
    [[self previewMovie] gotoBeginning];
    [self stopPreviewMovieTimer];
    [self setImagesForPlayButton:[[self previewMovie] isPlaying]];
}

- (void)movieDidChangeImage:(id)aImage
{

}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b97b5 @ 001b97b5, 1024 bytes * /

void FUN_001b97b5(HSImportDialogSoundPaneViewController *self,SEL _cmd,id tableView,
                 id didClickTableColumn)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  cfstringStruct *pcVar6;
  bool bVar7;
  SEL op;
  id local_18;
  
  pvVar1 = _objc_msgSend(didClickTableColumn,sel_identifier);
  pvVar2 = _objc_msgSend(tableView,sel_selectedRowIndexes);
  local_18 = pvVar2;
  if ((self->_sortAscending == '\0') && (self->_sortedIdentifier != (id)0x0)) {
    pvVar3 = _objc_msgSend(pvVar2,sel_firstIndex);
    local_18 = _objc_msgSend(cls_NSMutableIndexSet,sel_indexSet);
    for (; pvVar3 != (id)0x7fffffff;
        pvVar3 = _objc_msgSend(pvVar2,sel_indexGreaterThanIndex_,pvVar3)) {
      pvVar4 = _objc_msgSend(self,sel_filteredItems);
      pvVar4 = _objc_msgSend(pvVar4,sel_count);
      _objc_msgSend(local_18,sel_addIndex_,~(uint)pvVar3 + (int)pvVar4);
    }
  }
  pvVar2 = _objc_msgSend(self,sel_filteredItems);
  pvVar2 = _objc_msgSend(pvVar2,sel_objectsAtIndexes_,local_18);
  pvVar3 = _objc_msgSend(self->_sortedIdentifier,sel_isEqualToString_,pvVar1);
  if ((char)pvVar3 == '\0') {
    if (self->_sortedIdentifier != (id)0x0) {
      pvVar3 = _objc_msgSend(tableView,sel_tableColumnWithIdentifier_,self->_sortedIdentifier);
      _objc_msgSend(tableView,sel_setIndicatorImage_inTableColumn_,0,pvVar3);
    }
    self->_sortAscending = '\x01';
    pvVar3 = _objc_msgSend(self,sel_sortedSoundItemsForIdentifier_,pvVar1);
    _objc_msgSend(self,sel_setFilteredItems_,pvVar3);
    _objc_msgSend(self->_sortedIdentifier,sel_release);
    pvVar1 = _objc_msgSend(pvVar1,sel_retain);
    self->_sortedIdentifier = pvVar1;
    pvVar1 = _objc_msgSend(cls_NSImage,sel_imageNamed_,&cfstr_NSAscendingSortIndicator);
    pvVar3 = didClickTableColumn;
    _objc_msgSend(tableView,sel_setIndicatorImage_inTableColumn_,pvVar1,didClickTableColumn);
    op = sel_setHighlightedTableColumn_;
    pvVar1 = didClickTableColumn;
    didClickTableColumn = pvVar3;
  }
  else {
    bVar7 = self->_sortAscending == '\0';
    self->_sortAscending = bVar7;
    pcVar6 = &cfstr_NSDescendingSortIndicator;
    if (bVar7) {
      pcVar6 = &cfstr_NSAscendingSortIndicator;
    }
    pvVar1 = _objc_msgSend(cls_NSImage,sel_imageNamed_,pcVar6);
    op = sel_setIndicatorImage_inTableColumn_;
  }
  _objc_msgSend(tableView,op,pvVar1,didClickTableColumn);
  _objc_msgSend(tableView,sel_reloadData);
  pvVar3 = _objc_msgSend(cls_NSMutableIndexSet,sel_indexSet);
  pvVar4 = _objc_msgSend(pvVar2,sel_objectEnumerator);
  pvVar2 = _objc_msgSend(pvVar4,sel_nextObject);
  while (pvVar2 != (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_filteredItems,pvVar1);
    pvVar5 = _objc_msgSend(pvVar1,sel_indexOfObject_);
    pvVar1 = pvVar2;
    if (pvVar5 != (id)0x7fffffff) {
      if (self->_sortAscending == '\0') {
        pvVar1 = _objc_msgSend(self->_filteredItems,sel_count,pvVar2);
        pvVar5 = (id)((int)pvVar1 + ~(uint)pvVar5);
      }
      _objc_msgSend(pvVar3,sel_addIndex_,pvVar5);
      pvVar1 = pvVar5;
    }
    pvVar2 = _objc_msgSend(pvVar4,sel_nextObject,pvVar1);
  }
  _objc_msgSend(tableView,sel_selectRowIndexes_byExtendingSelection_,pvVar3,0);
  pvVar1 = _objc_msgSend(pvVar3,sel_firstIndex);
  _objc_msgSend(tableView,sel_scrollRowToVisible_,pvVar1);
  return;
}

*/
- (void)tableView:(id)aView didClickTableColumn:(id)aColumn
{
    id identifier = [aColumn identifier];
    NSIndexSet *selection = [aView selectedRowIndexes];
    NSIndexSet *itemIndexes = selection;
    NSArray *selectedItems;
    NSMutableIndexSet *newSelection;
    NSEnumerator *enumerator;
    id item;
    if (!_sortAscending && _sortedIdentifier != nil) {
        NSMutableIndexSet *reversed = [NSMutableIndexSet indexSet];
        NSUInteger index;
        for (index = [selection firstIndex]; index != NSNotFound; index = [selection indexGreaterThanIndex:index]) {
            [reversed addIndex:[[self filteredItems] count] - 1 - index];
        }
        itemIndexes = reversed;
    }
    selectedItems = [[self filteredItems] objectsAtIndexes:itemIndexes];
    if (![_sortedIdentifier isEqualToString:identifier]) {
        if (_sortedIdentifier != nil) {
            [aView setIndicatorImage:nil inTableColumn:[aView tableColumnWithIdentifier:_sortedIdentifier]];
        }
        _sortAscending = YES;
        [self setFilteredItems:[self sortedSoundItemsForIdentifier:identifier]];
        [_sortedIdentifier release];
        _sortedIdentifier = [identifier retain];
        [aView setIndicatorImage:[NSImage imageNamed:@"NSAscendingSortIndicator"] inTableColumn:aColumn];
        [aView setHighlightedTableColumn:aColumn];
    }
    else {
        _sortAscending = !_sortAscending;
        [aView setIndicatorImage:[NSImage imageNamed:(_sortAscending ? @"NSAscendingSortIndicator" : @"NSDescendingSortIndicator")] inTableColumn:aColumn];
    }
    [aView reloadData];
    newSelection = [NSMutableIndexSet indexSet];
    enumerator = [selectedItems objectEnumerator];
    while ((item = [enumerator nextObject]) != nil) {
        NSUInteger index = [[self filteredItems] indexOfObject:item];
        if (index != NSNotFound) {
            if (!_sortAscending) {
                index = [_filteredItems count] - 1 - index;
            }
            [newSelection addIndex:index];
        }
    }
    [aView selectRowIndexes:newSelection byExtendingSelection:NO];
    [aView scrollRowToVisible:[newSelection firstIndex]];
}

- (void)tableViewSelectionDidChange:(id)aChange
{
    if (![[self filePath] isEqualToString:[self paneFilePath]]) {
        [_dialogController validateUIElements];
        [self setFilePath:[self paneFilePath]];
        [self updatePreviewMovie];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b9559 @ 001b9559, 435 bytes * /

id FUN_001b9559(HSImportDialogSoundPaneViewController *self,SEL _cmd,id tableView,
               id objectValueForTableColumn,int row)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id self_00;
  id pvVar4;
  id pvVar5;
  SEL op;
  int iVar6;
  
  pvVar1 = _objc_msgSend(self,sel_filteredItems);
  if ((row < 0) || (pvVar2 = _objc_msgSend(pvVar1,sel_count), pvVar2 <= (uint)row)) {
    pvVar1 = (id)0x0;
  }
  else {
    pvVar2 = _objc_msgSend(objectValueForTableColumn,sel_identifier);
    iVar6 = row;
    if ((self->_sortAscending == '\0') && (self->_sortedIdentifier != (id)0x0)) {
      pvVar3 = _objc_msgSend(pvVar1,sel_count);
      iVar6 = ~row + (int)pvVar3;
    }
    pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,iVar6);
    pvVar3 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0037e160);
    if (pvVar3 != (id)0x0) {
      self_00 = _objc_msgSend(objectValueForTableColumn,sel_dataCellForRow_,row);
      pvVar4 = _objc_msgSend(cls_NSTextFieldCell,sel_class);
      pvVar5 = _objc_msgSend(self_00,sel_isKindOfClass_,pvVar4);
      if ((char)pvVar5 != '\0') {
        pvVar3 = _objc_msgSend(pvVar3,sel_hasAccessibleURL,pvVar4);
        op = sel_grayColor;
        if ((char)pvVar3 != '\0') {
          op = sel_blackColor;
        }
        pvVar3 = _objc_msgSend(cls_NSColor,op,pvVar4);
        _objc_msgSend(self_00,sel_setTextColor_,pvVar3);
      }
    }
    pvVar1 = _objc_msgSend(self,sel_valueForSoundObject_forIdentifier_lineBreakInfo_,pvVar1,pvVar2,
                           self->_lineBreakInfo);
  }
  return pvVar1;
}

*/
- (id)tableView:(id)aView objectValueForTableColumn:(id)aColumn row:(NSInteger)aRow
{
    NSArray *items = [self filteredItems];
    id identifier;
    NSInteger index;
    id item;
    id accessibility;
    if (aRow < 0 || (NSUInteger)aRow >= [items count]) {
        return nil;
    }
    identifier = [aColumn identifier];
    index = aRow;
    if (!_sortAscending && _sortedIdentifier != nil) {
        index = [items count] - 1 - aRow;
    }
    item = [items objectAtIndex:index];
    accessibility = [item queryHyperInterface:@protocol(HSLibraryMediaDataItemAccessibility)];
    if (accessibility != nil) {
        id cell = [aColumn dataCellForRow:aRow];
        if ([cell isKindOfClass:[NSTextFieldCell class]]) {
            [cell setTextColor:([accessibility hasAccessibleURL] ? [NSColor blackColor] : [NSColor grayColor])];
        }
    }
    return [self valueForSoundObject:item forIdentifier:identifier lineBreakInfo:_lineBreakInfo];
}

- (NSInteger)numberOfRowsInTableView:(id)aView
{
    return (int)[[self filteredItems] count];
}

- (id)valueForSoundObject:(id)aObject forIdentifier:(id)aIdentifier lineBreakInfo:(id)aInfo
{
    id pvVar1;

    pvVar1 = [self stringForSoundObject:aObject forIdentifier:aIdentifier lineBreakInfo:aInfo];
    if (aInfo != nil) {
        pvVar1 = [[[NSAttributedString alloc] initWithString:pvVar1 attributes:aInfo] autorelease];
    }
    return pvVar1;
}

- (id)stringForSoundObject:(id)aObject forIdentifier:(id)aIdentifier lineBreakInfo:(id)aInfo
{
    return nil;
}

- (id)sortedSoundItemsForIdentifier:(id)aIdentifier
{
    return [self filteredItems];
}

- (id)defaultSoundIcon
{
    id pvVar1;

    pvVar1 = _defaultSoundIcon;
    if (pvVar1 == nil) {
        pvVar1 = [[[HSImagesProvider sharedImagesProvider] imageForName:@"Sound_icon.png"] retain];
        _defaultSoundIcon = pvVar1;
    }
    return pvVar1;
}

- (void)setSortAscending:(id)aAscending
{
    _sortAscending = (BOOL)[aAscending boolValue];
}

- (void)setSortedIdentifier:(id)aIdentifier
{
    if (![aIdentifier isEqualToString:_sortedIdentifier]) {
        [_sortedIdentifier release];
        _sortedIdentifier = [aIdentifier retain];
    }
}

- (void)setFilteredItems:(id)aItems
{
    if (![aItems isEqualToArray:_filteredItems]) {
        [_filteredItems release];
        _filteredItems = [aItems retain];
    }
}

- (id)filteredItems
{
    return _filteredItems;
}

- (void)setFilePath:(id)aPath
{
    if (![_filePath isEqualToString:aPath]) {
        [_filePath release];
        _filePath = [aPath copy];
    }
}

- (id)filePath
{
    return _filePath;
}

- (void)switchHistoryTo:(id)aTo
{

}

- (void)onDoubleClick:(id)aClick
{
    if (_soundsTableView == aClick) {
        if (-1 < (int)[_soundsTableView selectedRow]) {
            if ((int)[_soundsTableView selectedRow] < (int)[[self filteredItems] count]) {
                [_dialogController addToCard:aClick];
            }
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b90b2 @ 001b90b2, 328 bytes * /

void FUN_001b90b2(HSImportDialogSoundPaneViewController *self,SEL _cmd,id controlTextDidChange)

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
    _objc_msgSend(self->_soundsTableView,sel_setPlaceholderString_,pvVar1);
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
        [_soundsTableView setPlaceholderString:[[NSBundle bundleForClass:[self class]] localizedStringForKey:([_filterString length] == 0 ? @"Empty_placeholderString" : @"NotFound_placeholderString") value:@"" table:@"ImportDialogs"]];
    }
    [self invalidateMediaPaths];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b8d90 @ 001b8d90, 802 bytes * /

void FUN_001b8d90(HSImportDialogSoundPaneViewController *self,SEL _cmd,id startPreviewMovie)

{
  undefined *puVar1;
  undefined *self_00;
  id pvVar2;
  id pvVar3;
  id self_01;
  SEL op;
  
  pvVar2 = _objc_msgSend(self,sel_filePath);
  pvVar3 = _objc_msgSend(self,sel_paneFilePath);
  pvVar2 = _objc_msgSend(pvVar2,sel_isEqualToString_,pvVar3);
  if ((char)pvVar2 == '\0') {
    pvVar3 = _objc_msgSend(self,sel_paneFilePath,pvVar3);
    _objc_msgSend(self,sel_setFilePath_,pvVar3);
    _objc_msgSend(self,sel_updatePreviewMovie);
  }
  pvVar2 = _objc_msgSend(self,sel_previewMovie,pvVar3);
  if (pvVar2 == (id)0x0) {
    return;
  }
  pvVar2 = _objc_msgSend(self,sel_previewMovie,pvVar3);
  pvVar2 = _objc_msgSend(pvVar2,sel_isPlaying);
  if ((char)pvVar2 == '\0') {
    pvVar3 = _objc_msgSend(self,sel_previewMovie);
    pvVar2 = _objc_msgSend(pvVar3,sel_hasProtectedMovieTrack);
    self_01 = _objc_msgSend(cls_HSMediaPlaySynchronizer,sel_sharedSynchronizer);
    pvVar3 = _objc_msgSend(self,sel_previewMovie);
    _objc_msgSend(self_01,sel_playMediaSingle_,pvVar3);
    self_00 = cls_NSTimer;
    if ((char)pvVar2 != '\0') goto LAB_001b906a;
    pvVar3 = _objc_msgSend(cls_NSDate,sel_date,pvVar3);
    puVar1 = sel_previewMovieTimerFireMethod_;
    pvVar2 = _objc_msgSend(self,sel_NSE_newWeakProxy);
    pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
    pvVar3 = _objc_msgSend(self_00,sel_timerWithTimeInterval_target_selector_userInfo_repeats_,0,
                           0x3ff00000,pvVar2,puVar1,pvVar3,1);
    pvVar3 = _objc_msgSend(pvVar3,sel_retain);
    self->_previewMovieTimer = pvVar3;
    pvVar2 = _objc_msgSend(cls_NSRunLoop,sel_currentRunLoop);
    _objc_msgSend(pvVar2,sel_addTimer_forMode_,self->_previewMovieTimer,*(undefined4 *)PTR_003361b4)
    ;
    _objc_msgSend(pvVar2,sel_addTimer_forMode_,self->_previewMovieTimer,*(undefined4 *)PTR_003363f8)
    ;
    pvVar3 = self->_previewMovieTimer;
    op = sel_addTimer_forMode_;
  }
  else {
    _objc_msgSend(self,sel_stopPreviewMovieTimer);
    pvVar2 = _objc_msgSend(self,sel_previewMovie);
    _objc_msgSend(pvVar2,sel_stop);
    pvVar2 = _objc_msgSend(self,sel_previewMovie);
    op = sel_gotoBeginning;
  }
  _objc_msgSend(pvVar2,op,pvVar3);
LAB_001b906a:
  pvVar3 = _objc_msgSend(self,sel_previewMovie,pvVar3);
  pvVar3 = _objc_msgSend(pvVar3,sel_isPlaying);
  _objc_msgSend(self,sel_setImagesForPlayButton_,(int)(char)pvVar3);
  return;
}

*/
- (void)startPreviewMovie:(id)aMovie
{
    NSRunLoop *runLoop;
    if (![[self filePath] isEqualToString:[self paneFilePath]]) {
        [self setFilePath:[self paneFilePath]];
        [self updatePreviewMovie];
    }
    if ([self previewMovie] == nil) {
        return;
    }
    if (![[self previewMovie] isPlaying]) {
        BOOL isProtected = [[self previewMovie] hasProtectedMovieTrack];
        [[HSMediaPlaySynchronizer sharedSynchronizer] playMediaSingle:[self previewMovie]];
        if (!isProtected) {
            _previewMovieTimer = [[NSTimer timerWithTimeInterval:1.0 target:[[self NSE_newWeakProxy] autorelease] selector:@selector(previewMovieTimerFireMethod:) userInfo:[NSDate date] repeats:YES] retain];
            runLoop = [NSRunLoop currentRunLoop];
            [runLoop addTimer:_previewMovieTimer forMode:NSDefaultRunLoopMode];
            [runLoop addTimer:_previewMovieTimer forMode:NSModalPanelRunLoopMode];
            [runLoop addTimer:_previewMovieTimer forMode:NSEventTrackingRunLoopMode];
        }
    }
    else {
        [self stopPreviewMovieTimer];
        [(HSMovie *)[self previewMovie] stop];
        [[self previewMovie] gotoBeginning];
    }
    [self setImagesForPlayButton:[[self previewMovie] isPlaying]];
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
/* FUN_001ba807 @ 001ba807, 55 bytes * /

void FUN_001ba807(HSImportDialogSoundPaneViewController *self,SEL _cmd,id volumeChanged)

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

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ba83e @ 001ba83e, 73 bytes * /

void FUN_001ba83e(HSImportDialogSoundPaneViewController *self,SEL _cmd,float setPreviewMovieVolume)

{
  id self_00;
  
  self_00 = _objc_msgSend(self,sel_previewMovie);
  _objc_msgSend(self_00,sel_setVolume_,setPreviewMovieVolume * setPreviewMovieVolume);
  return;
}

*/
- (void)setPreviewMovieVolume:(CGFloat)aVolume
{
    [(HSMovie *)[self previewMovie] setVolume:(float)aVolume * (float)aVolume];
}

- (void)filter:(id)aFilter
{
    [self filter:[aFilter stringValue] byCategory:nil];
}

- (id)helpTopicKey
{
    return @"HSAddSound";
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ba887 @ 001ba887, 257 bytes * /

void FUN_001ba887(HSImportDialogSoundPaneViewController *self,SEL _cmd,
                 id willUnmountFromDialogController)

{
  id pvVar1;
  HSImportDialogSoundPaneViewController *local_1c;
  undefined *local_18;
  
  pvVar1 = _objc_msgSend(self,sel_previewMovie);
  pvVar1 = _objc_msgSend(pvVar1,sel_isPlaying);
  if ((char)pvVar1 != '\0') {
    _objc_msgSend(self,sel_stopPreviewMovieTimer);
    pvVar1 = _objc_msgSend(self,sel_previewMovie);
    _objc_msgSend(pvVar1,sel_stop);
    pvVar1 = _objc_msgSend(self,sel_previewMovie);
    _objc_msgSend(pvVar1,sel_gotoBeginning);
  }
  pvVar1 = _objc_msgSend(self,sel_previewMovie);
  pvVar1 = _objc_msgSend(pvVar1,sel_isPlaying);
  _objc_msgSend(self,sel_setImagesForPlayButton_,(int)(char)pvVar1);
  local_1c = self;
  local_18 = PTR_s_HSImportDialogBasePaneViewContro_00353720;
  _objc_msgSendSuper(&local_1c,sel_willUnmountFromDialogController_,willUnmountFromDialogController)
  ;
  return;
}

*/
- (void)willUnmountFromDialogController:(id)aController
{
    if ([[self previewMovie] isPlaying]) {
        [self stopPreviewMovieTimer];
        [(HSMovie *)[self previewMovie] stop];
        [[self previewMovie] gotoBeginning];
    }
    [self setImagesForPlayButton:[[self previewMovie] isPlaying]];
    [super willUnmountFromDialogController:aController];
}

- (void)willMountToDialogController:(id)aController
{
    [self invalidateSearch];
    [super willMountToDialogController:aController];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ba9da @ 001ba9da, 248 bytes * /

void FUN_001ba9da(HSImportDialogSoundPaneViewController *self,SEL _cmd)

{
  id pvVar1;
  HSImportDialogSoundPaneViewController *local_14;
  undefined *local_10;
  
  pvVar1 = _objc_msgSend(self,sel_previewMovie);
  pvVar1 = _objc_msgSend(pvVar1,sel_isPlaying);
  if ((char)pvVar1 != '\0') {
    _objc_msgSend(self,sel_stopPreviewMovieTimer);
    pvVar1 = _objc_msgSend(self,sel_previewMovie);
    _objc_msgSend(pvVar1,sel_stop);
    pvVar1 = _objc_msgSend(self,sel_previewMovie);
    _objc_msgSend(pvVar1,sel_gotoBeginning);
  }
  pvVar1 = _objc_msgSend(self,sel_previewMovie);
  pvVar1 = _objc_msgSend(pvVar1,sel_isPlaying);
  _objc_msgSend(self,sel_setImagesForPlayButton_,(int)(char)pvVar1);
  local_14 = self;
  local_10 = PTR_s_HSImportDialogBasePaneViewContro_00353720;
  _objc_msgSendSuper(&local_14,sel_paneDialogWillClose);
  return;
}

*/
- (void)paneDialogWillClose
{
    if ([[self previewMovie] isPlaying]) {
        [self stopPreviewMovieTimer];
        [(HSMovie *)[self previewMovie] stop];
        [[self previewMovie] gotoBeginning];
    }
    [self setImagesForPlayButton:[[self previewMovie] isPlaying]];
    [super paneDialogWillClose];
}

- (void)paneDialogWillOpen
{
    [self invalidateSearch];
    [super paneDialogWillOpen];
}

- (id)currentMediaPathsLocation
{
    return nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b8c30 @ 001b8c30, 279 bytes * /

void FUN_001b8c30(HSImportDialogSoundPaneViewController *self,SEL _cmd)

{
  id self_00;
  undefined *self_01;
  undefined *self_02;
  id pvVar1;
  id pvVar2;
  
  self_02 = cls_NSString;
  self_00 = self->_itemsCountTextField;
  pvVar1 = _objc_msgSend(self,sel_currentMediaPathsLocation);
  pvVar1 = _objc_msgSend(self,sel_filteredMediaPathsForKey_,pvVar1);
  pvVar1 = _objc_msgSend(pvVar1,sel_count);
  self_01 = cls_NSBundle;
  pvVar2 = _objc_msgSend(self,sel_class);
  pvVar2 = _objc_msgSend(self_01,sel_bundleForClass_,pvVar2);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr__dItems,&cfstr_empty,
                         &cfstr_ImportDialogs);
  pvVar1 = _objc_msgSend(self_02,sel_stringWithFormat_,pvVar2,pvVar1);
  _objc_msgSend(self_00,sel_setStringValue_,pvVar1);
  _objc_msgSend(self->_soundsTableView,sel_reloadData);
  return;
}

*/
- (void)reloadMediaPaths
{
    [_itemsCountTextField setStringValue:[NSString stringWithFormat:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"%dItems" value:@"" table:@"ImportDialogs"], (int)[[self filteredMediaPathsForKey:[self currentMediaPathsLocation]] count]]];
    [_soundsTableView reloadData];
}

- (id)supportedMediaTypes
{
    return [HSNewMediaAccessor supportedMediaTypesForClass:@"HSPlaySoundAction"];
}

- (id)paneFilePath
{
    id pvVar1_4;

    if ((int)[_soundsTableView selectedRow] < (int)[[self filteredMediaPathsForKey:[self currentMediaPathsLocation]] count]) {
        pvVar1_4 = [[self filteredMediaPathsForKey:[self currentMediaPathsLocation]] objectAtIndex:[_soundsTableView selectedRow]];
    }
    else {
        pvVar1_4 = nil;
    }
    return pvVar1_4;
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
    return @"HSImportDialogBaseSound";
}

- (id)paneViewNibName
{
    return @"ImportDialogSoundPaneView";
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b82b1 @ 001b82b1, 2051 bytes * /

void FUN_001b82b1(HSImportDialogSoundPaneViewController *self,SEL _cmd)

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
  _objc_msgSend(self->_testButton,sel_setCell_,pvVar2);
  _objc_msgSend(self->_testButton,sel_setButtonType_,5);
  _objc_msgSend(self->_testButton,sel_setBordered_,0);
  _objc_msgSend(self->_testButton,sel_setImagePosition_,1);
  _objc_msgSend(self->_testButton,sel_setAction_,sel_startPreviewMovie_);
  _objc_msgSend(self->_testButton,sel_setTarget_,self);
  _objc_msgSend(self,sel_setImagesForPlayButton_,0);
  _objc_msgSend(self->_testButton,sel_setEnabled_,0);
  pvVar2 = _objc_msgSend(self->_testButton,sel_cell);
  puVar1 = cls_NSBundle;
  pvVar4 = _objc_msgSend(self,sel_class);
  pvVar4 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar4);
  pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,&cfstr_Play,&cfstr_empty,
                         &cfstr_ImportDialogs);
  _objc_msgSend(pvVar2,sel_accessibilitySetOverrideValue_forAttribute_,pvVar4,
                *(undefined4 *)PTR_0033653c);
  _objc_msgSend(self->_volumeSlider,sel_setEnabled_,0);
  _objc_msgSend(self->_volumeMin,sel_setEnabled_,0);
  _objc_msgSend(self->_volumeMax,sel_setEnabled_,0);
  _objc_msgSend(self->_soundsTableView,sel_setDataSource_,self);
  _objc_msgSend(self->_soundsTableView,sel_setDelegate_,self);
  _objc_msgSend(self->_soundsTableView,sel_setAllowsColumnReordering_,0);
  _objc_msgSend(self->_soundsTableView,sel_setAllowsEmptySelection_,0);
  _objc_msgSend(self->_soundsTableView,sel_setAllowsMultipleSelection_,0);
  _objc_msgSend(self->_soundsTableView,sel_setTarget_,self);
  _objc_msgSend(self->_soundsTableView,sel_setDoubleAction_,sel_onDoubleClick_);
  _objc_msgSend(self->_soundsTableView,sel_setRowHeight_,0x41900000);
  _objc_msgSend(self->_soundsTableView,sel_setUsesAlternatingRowBackgroundColors_,1);
  puVar1 = cls_NSBundle;
  pvVar2 = self->_soundsTableView;
  pvVar4 = _objc_msgSend(self,sel_class);
  pvVar4 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar4);
  pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,
                         &cfstr_Empty_placeholderString,&cfstr_empty,&cfstr_ImportDialogs);
  _objc_msgSend(pvVar2,sel_setPlaceholderString_,pvVar4);
  _objc_msgSend(self->_searchField,sel_setDelegate_,self);
  return;
}

*/
- (void)awakeFromNib
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
    [_testButton setCell:_playButtonCell];
    [_testButton setButtonType:NSMomentaryChangeButton];
    [_testButton setBordered:NO];
    [_testButton setImagePosition:NSImageOnly];
    [_testButton setAction:@selector(startPreviewMovie:)];
    [_testButton setTarget:self];
    [self setImagesForPlayButton:NO];
    [_testButton setEnabled:NO];
    [[_testButton cell] accessibilitySetOverrideValue:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Play" value:@"" table:@"ImportDialogs"] forAttribute:NSAccessibilityDescriptionAttribute];
    [_volumeSlider setEnabled:NO];
    [_volumeMin setEnabled:NO];
    [_volumeMax setEnabled:NO];
    [_soundsTableView setDataSource:self];
    [_soundsTableView setDelegate:self];
    [_soundsTableView setAllowsColumnReordering:NO];
    [_soundsTableView setAllowsEmptySelection:NO];
    [_soundsTableView setAllowsMultipleSelection:NO];
    [_soundsTableView setTarget:self];
    [_soundsTableView setDoubleAction:@selector(onDoubleClick:)];
    [_soundsTableView setRowHeight:18.0f];
    [_soundsTableView setUsesAlternatingRowBackgroundColors:YES];
    [_soundsTableView setPlaceholderString:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Empty_placeholderString" value:@"" table:@"ImportDialogs"]];
    [_searchField setDelegate:(id)self];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ba2b8 @ 001ba2b8, 705 bytes * /

void FUN_001ba2b8(HSImportDialogSoundPaneViewController *self,SEL _cmd)

{
  HSImportDialogSoundPaneViewController *pHVar1;
  HSImportDialogSoundPaneViewController *local_14;
  undefined *local_10;
  
  _objc_msgSend(self->_previewMovieTimer,sel_invalidate);
  _objc_msgSend(self->_previewMovieTimer,sel_release);
  pHVar1 = _objc_msgSend(self->_searchField,sel_delegate);
  if (pHVar1 == self) {
    _objc_msgSend(self->_searchField,sel_setDelegate_,0);
  }
  pHVar1 = _objc_msgSend(self->_soundsTableView,sel_delegate);
  if (pHVar1 == self) {
    _objc_msgSend(self->_soundsTableView,sel_setDelegate_,0);
  }
  pHVar1 = _objc_msgSend(self->_soundsTableView,sel_dataSource);
  if (pHVar1 == self) {
    _objc_msgSend(self->_soundsTableView,sel_setDataSource_,0);
  }
  _objc_msgSend(self->_paneAccessoryView,sel_release);
  _objc_msgSend(self->_paneView,sel_release);
  pHVar1 = _objc_msgSend(self->_previewMovie,sel_delegate);
  if (pHVar1 == self) {
    _objc_msgSend(self->_previewMovie,sel_setDelegate_,0);
  }
  _objc_msgSend(self->_previewMovie,sel_release);
  _objc_msgSend(self->_playButtonImage,sel_release);
  _objc_msgSend(self->_playButtonAquaImage,sel_release);
  _objc_msgSend(self->_playButtonGraphiteImage,sel_release);
  _objc_msgSend(self->_stopButtonImage,sel_release);
  _objc_msgSend(self->_stopButtonAquaImage,sel_release);
  _objc_msgSend(self->_stopButtonGraphiteImage,sel_release);
  _objc_msgSend(self->_playButtonCell,sel_release);
  _objc_msgSend(self->_sortedIdentifier,sel_release);
  _objc_msgSend(self->_sortedArrayHint,sel_release);
  _objc_msgSend(self->_filePath,sel_release);
  _objc_msgSend(self->_defaultSoundIcon,sel_release);
  _objc_msgSend(self->_filteredItems,sel_release);
  _objc_msgSend(self->_lineBreakInfo,sel_release);
  _objc_msgSend(self->_filterString,sel_release);
  _objc_msgSend(self->_categoryString,sel_release);
  local_14 = self;
  local_10 = PTR_s_HSImportDialogBasePaneViewContro_00353720;
  _objc_msgSendSuper(&local_14,sel_dealloc);
  return;
}

*/
- (void)dealloc
{
    [_previewMovieTimer invalidate];
    [_previewMovieTimer release];
    if ([_searchField delegate] == (id)self) {
        [_searchField setDelegate:nil];
    }
    if ([_soundsTableView delegate] == (id)self) {
        [_soundsTableView setDelegate:nil];
    }
    if ([_soundsTableView dataSource] == (id)self) {
        [_soundsTableView setDataSource:nil];
    }
    [_paneAccessoryView release];
    [_paneView release];
    if ([_previewMovie delegate] == (id)self) {
        [_previewMovie setDelegate:nil];
    }
    [_previewMovie release];
    [_playButtonImage release];
    [_playButtonAquaImage release];
    [_playButtonGraphiteImage release];
    [_stopButtonImage release];
    [_stopButtonAquaImage release];
    [_stopButtonGraphiteImage release];
    [_playButtonCell release];
    [_sortedIdentifier release];
    [_sortedArrayHint release];
    [_filePath release];
    [_defaultSoundIcon release];
    [_filteredItems release];
    [_lineBreakInfo release];
    [_filterString release];
    [_categoryString release];
    [super dealloc];
}

@end

