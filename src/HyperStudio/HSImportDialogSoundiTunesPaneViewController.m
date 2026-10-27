#import "HSImportDialogSoundiTunesPaneViewController.h"

static NSInteger HSImportDialogSoundiTunesSongCompare(id a, id b, void *context)
{
    id identifier = (id)context;
    if ([identifier isEqualToString:itTotalTimeKey]) {
        return [[[a info] objectForKey:identifier] compare:[[b info] objectForKey:identifier]];
    }
    return [[HSSoundsLibraryiTunesSong stringForSong:a forIdentifier:identifier] caseInsensitiveCompare:[HSSoundsLibraryiTunesSong stringForSong:b forIdentifier:identifier]];
}

@implementation HSImportDialogSoundiTunesPaneViewController

/* i386 ivar offsets: _browseOutlineView=0x94, _rootOutlineItems=0x98, _openiTunesButton=0x9c, _selectedMediaItem=0xa0, _mediaDataProvider=0xa4 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e1ecf @ 001e1ecf, 108 bytes * /

void FUN_001e1ecf(id self,SEL _cmd)

{
  id self_00;
  
  self_00 = _objc_msgSend(cls_NSAutoreleasePool,sel_new);
  _objc_msgSend(cls_HSImportDialogController,sel_registerPaneViewController_withIdentifier_,self,
                *(undefined4 *)PTR_PTR_003360dc);
  _objc_msgSend(self_00,sel_release);
  return;
}

*/
+ (void)load
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    [HSImportDialogController registerPaneViewController:self withIdentifier:HSImportDialogControllerTypeSound];
    [pool release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e1de0 @ 001e1de0, 239 bytes * /

void FUN_001e1de0(HSImportDialogSoundiTunesPaneViewController *self,SEL _cmd)

{
  id self_00;
  undefined *self_01;
  undefined *self_02;
  id pvVar1;
  id pvVar2;
  
  self_02 = cls_NSString;
  self_00 = (self->super)._itemsCountTextField;
  pvVar1 = _objc_msgSend((self->super)._filteredItems,sel_count);
  self_01 = cls_NSBundle;
  pvVar2 = _objc_msgSend(self,sel_class);
  pvVar2 = _objc_msgSend(self_01,sel_bundleForClass_,pvVar2);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr__dItems,&cfstr_empty,
                         &cfstr_ImportDialogs);
  pvVar1 = _objc_msgSend(self_02,sel_stringWithFormat_,pvVar2,pvVar1);
  _objc_msgSend(self_00,sel_setStringValue_,pvVar1);
  _objc_msgSend((self->super)._soundsTableView,sel_reloadData);
  return;
}

*/
- (void)reloadMediaPaths
{
    NSString *format = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"%d items" value:@"" table:@"ImportDialogs"];
    [_itemsCountTextField setStringValue:[NSString stringWithFormat:format, (int)[_filteredItems count]]];
    [_soundsTableView reloadData];
}

- (id)rootItems
{
    id pvVar2;
    NSUInteger pvVar3;
    id pvVar4;
    int iVar6;
    id pvVar2_4;

    if (_rootOutlineItems == nil) {
        pvVar2 = _mediaDataProvider;
        if (pvVar2 == nil) {
            pvVar2 = [[HSSoundsLibraryiTunesMediaDataProvider allocWithZone:[self zone]] init];
            _mediaDataProvider = pvVar2;
        }
        pvVar2_4 = [pvVar2 rootItem];
        if (pvVar2_4 != nil) {
            pvVar3 = [pvVar2_4 numberOfSubitems];
            if (0 < (int)pvVar3) {
                iVar6 = 0;
                do {
                    pvVar4 = _rootOutlineItems;
                    if (pvVar4 == nil) {
                        pvVar4 = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:0];
                        _rootOutlineItems = pvVar4;
                    }
                    [pvVar4 addObject:[pvVar2_4 subitemAtIndex:iVar6]];
                    iVar6 = iVar6 + 1;
                } while (iVar6 < (int)pvVar3);
            }
        }
    }
    return _rootOutlineItems;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e1aa6 @ 001e1aa6, 479 bytes * /

id FUN_001e1aa6(HSImportDialogSoundiTunesPaneViewController *self,SEL _cmd,id objectValueForItem)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined4 uVar4;
  undefined4 uVar5;
  
  pvVar1 = _objc_msgSend(objectValueForItem,sel_displayName);
  if ((self->super)._lineBreakInfo != (id)0x0) {
    pvVar2 = _objc_msgSend(cls_NSAttributedString,sel_alloc);
    pvVar1 = _objc_msgSend(pvVar2,sel_initWithString_attributes_,pvVar1,(self->super)._lineBreakInfo
                          );
    pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  }
  if (pvVar1 == (id)0x0) {
    pvVar2 = (id)0x0;
  }
  else {
    pvVar2 = _objc_msgSend(cls_NSMutableDictionary,sel_dictionaryWithCapacity_,0);
    uVar4 = *(undefined4 *)PTR_003366f0;
    _objc_msgSend(pvVar2,sel_setObject_forKey_,pvVar1,uVar4);
    pvVar3 = _objc_msgSend(objectValueForItem,sel_icon);
    if (pvVar3 != (id)0x0) {
      uVar4 = *(undefined4 *)PTR_003366ec;
      _objc_msgSend(pvVar2,sel_setObject_forKey_,pvVar3,uVar4);
      pvVar1 = pvVar3;
    }
    pvVar3 = _objc_msgSend(objectValueForItem,sel_actionImage,pvVar1,uVar4);
    if (pvVar3 != (id)0x0) {
      uVar4 = *(undefined4 *)PTR_003366e0;
      _objc_msgSend(pvVar2,sel_setObject_forKey_,pvVar3,uVar4);
      pvVar1 = pvVar3;
    }
    pvVar3 = _objc_msgSend(objectValueForItem,sel_actionSelector,pvVar1,uVar4);
    uVar5 = uVar4;
    if (pvVar3 != (id)0x0) {
      uVar5 = *(undefined4 *)PTR_003366e4;
      pvVar1 = _objc_msgSend(cls_NSValue,sel_valueWithPointer_,pvVar3,uVar4);
      _objc_msgSend(pvVar2,sel_setObject_forKey_,pvVar1,uVar5);
    }
    pvVar1 = _objc_msgSend(objectValueForItem,sel_actionTarget,pvVar1,uVar5);
    if (pvVar1 != (id)0x0) {
      _objc_msgSend(pvVar2,sel_setObject_forKey_,pvVar1,*(undefined4 *)PTR_003366e8);
    }
  }
  return pvVar2;
}

*/
- (id)objectValueForItem:(id)aItem
{
    id text = [aItem displayName];
    if (_lineBreakInfo != nil) {
        text = [[[NSAttributedString alloc] initWithString:text attributes:_lineBreakInfo] autorelease];
    }
    if (text == nil) {
        return nil;
    }
    NSMutableDictionary *value = [NSMutableDictionary dictionaryWithCapacity:0];
    [value setObject:text forKey:textKey];
    id icon = [aItem icon];
    if (icon != nil) {
        [value setObject:icon forKey:imageKey];
    }
    id actionImage = [aItem actionImage];
    if (actionImage != nil) {
        [value setObject:actionImage forKey:actionImageKey];
    }
    SEL actionSelector = [aItem actionSelector];
    if (actionSelector != NULL) {
        [value setObject:[NSValue valueWithPointer:actionSelector] forKey:actionSelectorKey];
    }
    id actionTarget = [aItem actionTarget];
    if (actionTarget != nil) {
        [value setObject:actionTarget forKey:actionTargetKey];
    }
    return value;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e18eb @ 001e18eb, 443 bytes * /

void FUN_001e18eb(HSImportDialogSoundiTunesPaneViewController *self,SEL _cmd,id filterSounds,
                 id byCategory)

{
  id pvVar1;
  id pvVar2;
  code *pcVar3;
  
  pvVar2 = filterSounds;
  pvVar1 = _objc_msgSend((self->super)._filterString,sel_isEqualToString_,filterSounds);
  if ((char)pvVar1 == '\0') {
    _objc_msgSend((self->super)._filterString,sel_release,pvVar2);
    pvVar2 = _objc_msgSend(filterSounds,sel_copy);
    (self->super)._filterString = pvVar2;
  }
  pvVar2 = byCategory;
  pvVar1 = _objc_msgSend((self->super)._categoryString,sel_isEqualToString_,byCategory);
  if ((char)pvVar1 == '\0') {
    _objc_msgSend((self->super)._categoryString,sel_release,pvVar2);
    pvVar1 = _objc_msgSend(byCategory,sel_copy);
    (self->super)._categoryString = pvVar1;
  }
  _objc_msgSend((self->super)._filteredItems,sel_release,pvVar2);
  pcVar3 = (self->super)._filterString;
  pvVar2 = (self->super)._categoryString;
  pvVar1 = _objc_msgSend(self->_selectedMediaItem,sel_filterTracks_byCategory_,pcVar3,pvVar2);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  (self->super)._filteredItems = pvVar1;
  _objc_msgSend((self->super)._sortedArrayHint,sel_release);
  pvVar1 = _objc_msgSend((self->super)._filteredItems,sel_sortedArrayHint);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  (self->super)._sortedArrayHint = pvVar1;
  if ((self->super)._sortedIdentifier != (id)0x0) {
    _objc_msgSend((self->super)._filteredItems,sel_autorelease);
    pvVar2 = (self->super)._sortedIdentifier;
    pcVar3 = FUN_001e15d1;
    pvVar1 = _objc_msgSend((self->super)._filteredItems,sel_sortedArrayUsingFunction_context_hint_,
                           FUN_001e15d1,pvVar2,(self->super)._sortedArrayHint);
    pvVar1 = _objc_msgSend(pvVar1,sel_retain);
    (self->super)._filteredItems = pvVar1;
  }
  _objc_msgSend(self,sel_reloadMediaPaths,pcVar3,pvVar2);
  return;
}

*/
- (void)filterSounds:(id)aSounds byCategory:(id)aCategory
{
    if (![_filterString isEqualToString:aSounds]) {
        [_filterString release];
        _filterString = [aSounds copy];
    }
    if (![_categoryString isEqualToString:aCategory]) {
        [_categoryString release];
        _categoryString = [aCategory copy];
    }
    [_filteredItems release];
    _filteredItems = [[_selectedMediaItem filterTracks:_filterString byCategory:_categoryString] retain];
    [_sortedArrayHint release];
    _sortedArrayHint = [[_filteredItems sortedArrayHint] retain];
    if (_sortedIdentifier != nil) {
        [_filteredItems autorelease];
        _filteredItems = [[_filteredItems sortedArrayUsingFunction:HSImportDialogSoundiTunesSongCompare context:_sortedIdentifier hint:_sortedArrayHint] retain];
    }
    [self reloadMediaPaths];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e182c @ 001e182c, 191 bytes * /

void FUN_001e182c(HSImportDialogSoundiTunesPaneViewController *self,SEL _cmd,id filter,id byCategory
                 )

{
  bool bVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar3 = filter;
  pvVar2 = _objc_msgSend((self->super)._filterString,sel_isEqualToString_,filter);
  if ((char)pvVar2 == '\0') {
    pvVar2 = _objc_msgSend(filter,sel_length,pvVar3);
    if (pvVar2 == (id)0x0) {
      pvVar3 = _objc_msgSend((self->super)._filterString,sel_length,pvVar3);
      if (pvVar3 == (id)0x0) goto LAB_001e1896;
    }
    bVar1 = true;
  }
  else {
LAB_001e1896:
    bVar1 = false;
  }
  pvVar3 = _objc_msgSend((self->super)._categoryString,sel_isEqualToString_,byCategory);
  if ((char)pvVar3 == '\0' || bVar1) {
    _objc_msgSend(self,sel_filterSounds_byCategory_,filter,byCategory);
  }
  return;
}

*/
- (void)filter:(id)aFilter byCategory:(id)aCategory
{
    BOOL filterChanged = NO;
    if (![_filterString isEqualToString:aFilter]) {
        filterChanged = ([aFilter length] != 0 || [_filterString length] != 0);
    }
    if (![_categoryString isEqualToString:aCategory] || filterChanged) {
        [self filterSounds:aFilter byCategory:aCategory];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e170e @ 001e170e, 286 bytes * /

void FUN_001e170e(HSImportDialogSoundiTunesPaneViewController *self,SEL _cmd,id selectItem)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  if (selectItem != (id)0x0) {
    pvVar1 = _objc_msgSend(cls_HSSoundsLibraryiTunesPlaylist,sel_class);
    pvVar1 = _objc_msgSend(selectItem,sel_isKindOfClass_,pvVar1);
    if ((char)pvVar1 == '\0') {
      return;
    }
  }
  if (self->_selectedMediaItem != selectItem) {
    pvVar2 = _objc_msgSend((self->super)._soundsTableView,sel_numberOfSelectedRows);
    self->_selectedMediaItem = selectItem;
    pvVar1 = (self->super)._categoryString;
    _objc_msgSend(self,sel_filterSounds_byCategory_,(self->super)._filterString,pvVar1);
    pvVar3 = _objc_msgSend((self->super)._soundsTableView,sel_numberOfSelectedRows);
    if (0 < (int)pvVar3) {
      if (0 < (int)pvVar2) {
        pvVar2 = (self->super)._soundsTableView;
        pvVar3 = _objc_msgSend(cls_NSIndexSet,sel_indexSetWithIndex_,0,pvVar1);
        pvVar1 = (id)0x0;
        _objc_msgSend(pvVar2,sel_selectRowIndexes_byExtendingSelection_,pvVar3,0);
      }
      _objc_msgSend((self->super)._soundsTableView,sel_scrollRowToVisible_,0,pvVar1);
    }
  }
  return;
}

*/
- (void)selectItem:(id)aItem
{
    if (aItem != nil && ![aItem isKindOfClass:[HSSoundsLibraryiTunesPlaylist class]]) {
        return;
    }
    if (_selectedMediaItem == aItem) {
        return;
    }
    NSInteger selectedRows = [_soundsTableView numberOfSelectedRows];
    _selectedMediaItem = aItem;
    [self filterSounds:_filterString byCategory:_categoryString];
    if ([_soundsTableView numberOfSelectedRows] > 0) {
        if (selectedRows > 0) {
            [_soundsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
        }
        [_soundsTableView scrollRowToVisible:0];
    }
}

- (id)stringForSoundObject:(id)aObject forIdentifier:(id)aIdentifier lineBreakInfo:(id)aInfo
{
    return [HSSoundsLibraryiTunesSong valueForSong:aObject forIdentifier:aIdentifier lineBreakInfo:aInfo];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e157a @ 001e157a, 87 bytes * /

id FUN_001e157a(HSImportDialogSoundiTunesPaneViewController *self,SEL _cmd,
               id sortedSoundItemsForIdentifier)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_filteredItems);
  pvVar1 = _objc_msgSend(pvVar1,sel_sortedArrayUsingFunction_context_hint_,FUN_001e15d1,
                         sortedSoundItemsForIdentifier,(self->super)._sortedArrayHint);
  return pvVar1;
}

*/
- (id)sortedSoundItemsForIdentifier:(id)aIdentifier
{
    return [[self filteredItems] sortedArrayUsingFunction:HSImportDialogSoundiTunesSongCompare context:aIdentifier hint:_sortedArrayHint];
}

- (BOOL)outlineView:(id)aView shouldExpandItem:(id)aItem
{
    return [[_mediaDataProvider rootItem] subitemAtIndex:0] == aItem;
}

- (id)outlineView:(id)aView persistentObjectForItem:(id)aItem
{
    return [aItem displayName];
}

- (id)outlineView:(id)aView itemForPersistentObject:(id)aObject
{
    id self_00;
    NSEnumerator *pvVar1_3;
    BOOL pvVar2_2;

    if (aObject != nil) {
        if (![aObject isKindOfClass:[NSString class]]) {
            return nil;
        }
    }
    pvVar1_3 = [_rootOutlineItems objectEnumerator];
    do {
        self_00 = [pvVar1_3 nextObject];
        if (self_00 == nil) {
            return nil;
        }
        pvVar2_2 = [[self_00 displayName] isEqualToString:aObject];
    } while (!pvVar2_2);
    return self_00;
}

- (void)outlineViewSelectionDidChange:(id)aChange
{
    id pvVar1_2;

    if ([_browseOutlineView autosaveExpandedItems]) {
        pvVar1_2 = _browseOutlineView;
        [self selectItem:[pvVar1_2 itemAtRow:[pvVar1_2 selectedRow]]];
    }
    [self setFilePath:[self paneFilePath]];
    [self updatePreviewMovie];
}

- (BOOL)outlineView:(id)aView shouldSelectItem:(id)aItem
{
    return YES;
}

- (id)outlineView:(id)aView objectValueForTableColumn:(id)aColumn byItem:(id)aItem
{
    return [self objectValueForItem:aItem];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e12db @ 001e12db, 135 bytes * /

id FUN_001e12db(HSImportDialogSoundiTunesPaneViewController *self,SEL _cmd,id outlineView,int child,
               id ofItem)

{
  id pvVar1;
  SEL op;
  
  op = sel_subitemAtIndex_;
  if ((ofItem == (id)0x0) &&
     (((ofItem = _objc_msgSend(self,sel_rootItems), child == 0x7fffffff || (child < 0)) ||
      (pvVar1 = _objc_msgSend(ofItem,sel_count), op = sel_objectAtIndex_, pvVar1 <= (uint)child))))
  {
    pvVar1 = (id)0x0;
  }
  else {
    pvVar1 = _objc_msgSend(ofItem,op,child);
  }
  return pvVar1;
}

*/
- (id)outlineView:(id)aView child:(NSInteger)aChild ofItem:(id)aItem
{
    if (aItem != nil) {
        return [aItem subitemAtIndex:aChild];
    }
    NSArray *rootItems = [self rootItems];
    if (aChild == NSNotFound || aChild < 0 || (NSUInteger)aChild >= [rootItems count]) {
        return nil;
    }
    return [rootItems objectAtIndex:aChild];
}

- (BOOL)outlineView:(id)aView isItemExpandable:(id)aExpandable
{
    BOOL bVar2;

    if (aExpandable == nil) {
        bVar2 = YES;
    }
    else {
        bVar2 = [aExpandable numberOfSubitems] != 0;
    }
    return bVar2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e1255 @ 001e1255, 77 bytes * /

int FUN_001e1255(HSImportDialogSoundiTunesPaneViewController *self,SEL _cmd,id outlineView,
                id numberOfChildrenOfItem)

{
  id pvVar1;
  SEL op;
  
  op = sel_numberOfSubitems;
  if (numberOfChildrenOfItem == (id)0x0) {
    numberOfChildrenOfItem = _objc_msgSend(self,sel_rootItems);
    op = sel_count;
  }
  pvVar1 = _objc_msgSend(numberOfChildrenOfItem,op);
  return (int)pvVar1;
}

*/
- (NSInteger)outlineView:(id)aView numberOfChildrenOfItem:(id)aItem
{
    if (aItem == nil) {
        return [[self rootItems] count];
    }
    return [aItem numberOfSubitems];
}

- (void)openiTunesApp:(id)aApp
{
    if (![[NSWorkspace sharedWorkspace] launchApplication:@"iTunes.app"]) {
        [[NSAlert alertWithMessageText:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Cannot launch iTunes" value:@"" table:@"ImportDialogs"] defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"This application may have been renamed, moved or deleted, or you may not have sufficient privileges to open it." value:@"" table:@"ImportDialogs"]] runModal];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e1015 @ 001e1015, 223 bytes * /

id FUN_001e1015(HSImportDialogSoundiTunesPaneViewController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar1 = _objc_msgSend((self->super)._soundsTableView,sel_selectedRow);
  if (-1 < (int)pvVar1) {
    if (((self->super)._sortAscending == '\0') && ((self->super)._sortedIdentifier != (id)0x0)) {
      pvVar2 = (self->super)._filteredItems;
      pvVar3 = _objc_msgSend(pvVar2,sel_count);
      pvVar1 = (id)(~(uint)pvVar1 + (int)pvVar3);
    }
    else {
      pvVar2 = (self->super)._filteredItems;
    }
    pvVar2 = _objc_msgSend(pvVar2,sel_objectAtIndex_,pvVar1);
    _objc_msgSend(pvVar2,sel_resetURLAccessTested);
    pvVar3 = _objc_msgSend(pvVar2,sel_hasAccessibleURL);
    if ((char)pvVar3 != '\0') {
      pvVar1 = _objc_msgSend(pvVar2,sel_URL,pvVar1);
      pvVar1 = _objc_msgSend(pvVar1,sel_path);
      return pvVar1;
    }
  }
  return (id)0x0;
}

*/
- (id)paneFilePath
{
    NSInteger row = [_soundsTableView selectedRow];
    if (row < 0) {
        return nil;
    }
    if (!_sortAscending && _sortedIdentifier != nil) {
        row = (NSInteger)[_filteredItems count] - row - 1;
    }
    id song = [_filteredItems objectAtIndex:row];
    [song resetURLAccessTested];
    if (![song hasAccessibleURL]) {
        return nil;
    }
    return [[song URL] path];
}

- (id)paneTitle
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"ImportDialogSoundiTunesPaneTitle" value:@"" table:@"ImportDialogs"];
}

- (id)paneViewNibName
{
    return @"IDSoundiTunesPaneView";
}

- (NSInteger)paneWeight
{
    return 1;
}

- (id)paneIdentifier
{
    return @"HSImportDialogiTunesSound";
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e201c @ 001e201c, 2244 bytes * /

void FUN_001e201c(HSImportDialogSoundiTunesPaneViewController *self,SEL _cmd)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  undefined4 *puVar6;
  double dVar7;
  HSImportDialogSoundiTunesPaneViewController *local_3c;
  undefined *local_38;
  float local_34 [2];
  float local_2c;
  undefined1 local_24 [8];
  float local_1c;
  
  local_3c = self;
  local_38 = PTR_s_HSImportDialogSoundPaneViewContr_003540e0;
  _objc_msgSendSuper(&local_3c,sel_awakeFromNib);
  puVar1 = cls_HSMediaOutlineCell;
  _objc_msgSend(self,sel_zone);
  pvVar2 = _objc_msgSend(puVar1,sel_allocWithZone_);
  pvVar2 = _objc_msgSend(pvVar2,sel_init);
  pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
  pvVar2 = _objc_msgSend(pvVar2,sel_respondsToSelector_);
  if ((char)pvVar2 == '\0') {
    _objc_msgSend(cls_NSParagraphStyle,sel_hyperParagraphStyleWithLineBreakMode_);
    puVar1 = cls_NSDictionary;
    _objc_msgSend(self,sel_zone);
    pvVar2 = _objc_msgSend(puVar1,sel_allocWithZone_);
    pvVar2 = _objc_msgSend(pvVar2,sel_initWithObjectsAndKeys_);
    (self->super)._lineBreakInfo = pvVar2;
  }
  pvVar2 = _objc_msgSend(self->_browseOutlineView,sel_outlineTableColumn);
  _objc_msgSend(pvVar2,sel_setDataCell_);
  _objc_msgSend(self->_browseOutlineView,sel_setAllowsMultipleSelection_);
  _objc_msgSend(self->_browseOutlineView,sel_setAllowsColumnSelection_);
  _objc_msgSend(self->_browseOutlineView,sel_setIntercellSpacing_);
  _objc_msgSend(self->_browseOutlineView,sel_setAllowsColumnReordering_);
  _objc_msgSend(self->_browseOutlineView,sel_setAllowsColumnResizing_);
  _objc_msgSend(self->_browseOutlineView,sel_setAllowsEmptySelection_);
  _objc_msgSend(self->_browseOutlineView,sel_setColumnAutoresizingStyle_);
  _objc_msgSend(self->_browseOutlineView,sel_setIndentationPerLevel_);
  _objc_msgSend(self->_browseOutlineView,sel_setAutosaveExpandedItems_);
  _objc_msgSend(self->_browseOutlineView,sel_setDataSource_);
  _objc_msgSend(self->_browseOutlineView,sel_setDelegate_);
  pvVar2 = _objc_msgSend((self->super)._soundsTableView,sel_tableColumns);
  pvVar2 = _objc_msgSend(pvVar2,sel_reverseObjectEnumerator);
  while (pvVar3 = _objc_msgSend(pvVar2,sel_nextObject), pvVar3 != (id)0x0) {
    _objc_msgSend((self->super)._soundsTableView,sel_removeTableColumn_);
  }
  pvVar2 = _objc_msgSend(cls_HSSoundsLibraryiTunesSong,sel_songIdentifiers);
  pvVar2 = _objc_msgSend(pvVar2,sel_objectEnumerator);
  pvVar3 = _objc_msgSend(pvVar2,sel_nextObject);
  puVar1 = cls_NSTableColumn;
  while (cls_NSTableColumn = puVar1, pvVar3 != (id)0x0) {
    _objc_msgSend(self,sel_zone);
    pvVar3 = _objc_msgSend(puVar1,sel_allocWithZone_);
    pvVar3 = _objc_msgSend(pvVar3,sel_initWithIdentifier_);
    _objc_msgSend(pvVar3,sel_setResizingMask_);
    _objc_msgSend(pvVar3,sel_setEditable_);
    pvVar4 = _objc_msgSend(pvVar3,sel_headerCell);
    puVar1 = cls_NSBundle;
    _objc_msgSend(self,sel_class);
    pvVar5 = _objc_msgSend(puVar1,sel_bundleForClass_);
    _objc_msgSend(pvVar5,sel_localizedStringForKey_value_table_);
    _objc_msgSend(pvVar4,sel_setTitle_);
    _objc_msgSend(pvVar4,sel_setAlignment_);
    pvVar4 = _objc_msgSend(cls_HSSoundsLibraryiTunesSong,sel_dataCellForIdentifier_);
    if (pvVar4 != (id)0x0) {
      _objc_msgSend(pvVar3,sel_setDataCell_);
    }
    pvVar4 = _objc_msgSend(pvVar3,sel_dataCell);
    pvVar5 = _objc_msgSend(pvVar4,sel_respondsToSelector_);
    if (((char)pvVar5 == '\0') &&
       (_objc_msgSend(pvVar4,sel_setWraps_), (self->super)._lineBreakInfo == (id)0x0)) {
      _objc_msgSend(cls_NSParagraphStyle,sel_hyperParagraphStyleWithLineBreakMode_);
      puVar1 = cls_NSDictionary;
      _objc_msgSend(self,sel_zone);
      pvVar4 = _objc_msgSend(puVar1,sel_allocWithZone_);
      pvVar4 = _objc_msgSend(pvVar4,sel_initWithObjectsAndKeys_);
      (self->super)._lineBreakInfo = pvVar4;
    }
    puVar1 = cls_HSSoundsLibraryiTunesSong;
    _objc_msgSend(pvVar3,sel_dataCell);
    dVar7 = _objc_msgSend_fpret(puVar1,sel_minWidthForIdentifier_cell_);
    if (0.0 < (float)dVar7) {
      _objc_msgSend(pvVar3,sel_setMinWidth_);
    }
    puVar1 = cls_HSSoundsLibraryiTunesSong;
    _objc_msgSend(pvVar3,sel_dataCell);
    dVar7 = _objc_msgSend_fpret(puVar1,sel_maxWidthForIdentifier_cell_);
    if (0.0 < (float)dVar7) {
      _objc_msgSend(pvVar3,sel_setMaxWidth_);
    }
    _objc_msgSend((self->super)._soundsTableView,sel_addTableColumn_);
    _objc_msgSend(pvVar3,sel_release);
    pvVar3 = _objc_msgSend(pvVar2,sel_nextObject);
    puVar1 = cls_NSTableColumn;
  }
  pvVar2 = _objc_msgSend((self->super)._soundsTableView,sel_tableColumns);
  pvVar2 = _objc_msgSend(pvVar2,sel_count);
  puVar6 = (undefined4 *)&stack0xffffff94;
  if (pvVar2 != (id)0x0) {
    pvVar2 = (self->super)._soundsTableView;
    pvVar3 = _objc_msgSend(pvVar2,sel_tableColumns);
    _objc_msgSend(pvVar3,sel_count);
    _objc_msgSend_stret(local_34,pvVar2,sel_rectOfColumn_);
    _objc_msgSend_stret(local_24,(self->super)._soundsTableView,sel_bounds);
    puVar6 = (undefined4 *)&stack0xffffff8c;
    if (local_34[0] + local_2c < local_1c) {
      _objc_msgSend((self->super)._soundsTableView,sel_sizeToFit);
      puVar6 = (undefined4 *)&stack0xffffff8c;
    }
  }
  puVar6[1] = sel_sharedWorkspace;
  *puVar6 = cls_NSWorkspace;
  puVar6[-1] = 0x1e27ce;
  pvVar2 = _objc_msgSend((id)*puVar6,(SEL)puVar6[1]);
  puVar6[2] = &cfstr_iTunes_app;
  puVar6[1] = sel_fullPathForApplication_;
  *puVar6 = pvVar2;
  puVar6[-1] = 0x1e27ea;
  pvVar2 = _objc_msgSend((id)*puVar6,(SEL)puVar6[1]);
  if (pvVar2 != (id)0x0) {
    puVar6[1] = sel_sharedWorkspace;
    *puVar6 = cls_NSWorkspace;
    puVar6[-1] = 0x1e280c;
    pvVar3 = _objc_msgSend((id)*puVar6,(SEL)puVar6[1]);
    puVar6[2] = pvVar2;
    puVar6[1] = sel_iconForFile_;
    *puVar6 = pvVar3;
    puVar6[-1] = 0x1e2822;
    pvVar4 = _objc_msgSend((id)*puVar6,(SEL)puVar6[1]);
    puVar6[1] = sel_setSize_;
    *puVar6 = pvVar4;
    puVar6[3] = 0x41800000;
    puVar6[2] = 0x41800000;
    puVar6[-1] = 0x1e2846;
    _objc_msgSend((id)*puVar6,(SEL)puVar6[1]);
    pvVar3 = self->_openiTunesButton;
    puVar6[2] = pvVar4;
    puVar6[1] = sel_setImage_;
    *puVar6 = pvVar3;
    puVar6[-1] = 0x1e2865;
    _objc_msgSend((id)*puVar6,(SEL)puVar6[1]);
  }
  pvVar3 = self->_openiTunesButton;
  puVar6[2] = (int)(pvVar2 != (id)0x0);
  puVar6[1] = sel_setEnabled_;
  *puVar6 = pvVar3;
  puVar6[-1] = 0x1e2889;
  _objc_msgSend((id)*puVar6,(SEL)puVar6[1]);
  pvVar2 = self->_openiTunesButton;
  puVar6[1] = sel_sizeToFit;
  *puVar6 = pvVar2;
  puVar6[-1] = 0x1e28a1;
  _objc_msgSend((id)*puVar6,(SEL)puVar6[1]);
  pvVar2 = (self->super)._soundsTableView;
  puVar6[1] = sel_setGridStyleMask_;
  *puVar6 = pvVar2;
  puVar6[2] = 1;
  puVar6[-1] = 0x1e28be;
  _objc_msgSend((id)*puVar6,(SEL)puVar6[1]);
  puVar6[1] = sel_outlineViewSelectionDidChange_;
  *puVar6 = self;
  puVar6[2] = 0;
  puVar6[-1] = 0x1e28d8;
  _objc_msgSend((id)*puVar6,(SEL)puVar6[1]);
  return;
}

*/
- (void)awakeFromNib
{
    [super awakeFromNib];
    HSMediaOutlineCell *cell = [[[HSMediaOutlineCell allocWithZone:[self zone]] init] autorelease];
    if (![cell respondsToSelector:@selector(setLineBreakMode:)]) {
        id style = [NSParagraphStyle hyperParagraphStyleWithLineBreakMode:4];
        _lineBreakInfo = [[NSDictionary allocWithZone:[self zone]] initWithObjectsAndKeys:style, NSParagraphStyleAttributeName, nil];
    }
    [[_browseOutlineView outlineTableColumn] setDataCell:cell];
    [_browseOutlineView setAllowsMultipleSelection:NO];
    [_browseOutlineView setAllowsColumnSelection:NO];
    [_browseOutlineView setIntercellSpacing:NSMakeSize(1.0f, 2.0f)];
    [_browseOutlineView setAllowsColumnReordering:NO];
    [_browseOutlineView setAllowsColumnResizing:NO];
    [_browseOutlineView setAllowsEmptySelection:NO];
    [_browseOutlineView setColumnAutoresizingStyle:3];
    [_browseOutlineView setIndentationPerLevel:0.0];
    [_browseOutlineView setAutosaveExpandedItems:YES];
    [_browseOutlineView setDataSource:self];
    [_browseOutlineView setDelegate:self];
    for (NSTableColumn *column in [[_soundsTableView tableColumns] reverseObjectEnumerator]) {
        [_soundsTableView removeTableColumn:column];
    }
    for (NSString *identifier in [HSSoundsLibraryiTunesSong songIdentifiers]) {
        NSTableColumn *column = [[NSTableColumn allocWithZone:[self zone]] initWithIdentifier:identifier];
        [column setResizingMask:3];
        [column setEditable:NO];
        NSTableHeaderCell *headerCell = [column headerCell];
        [headerCell setTitle:[[NSBundle bundleForClass:[self class]] localizedStringForKey:identifier value:@"" table:@"ImportDialogs"]];
        [headerCell setAlignment:NSLeftTextAlignment];
        id dataCell = [HSSoundsLibraryiTunesSong dataCellForIdentifier:identifier];
        if (dataCell != nil) {
            [column setDataCell:dataCell];
        }
        dataCell = [column dataCell];
        if (![dataCell respondsToSelector:@selector(setLineBreakMode:)]) {
            [dataCell setWraps:YES];
            if (_lineBreakInfo == nil) {
                id style = [NSParagraphStyle hyperParagraphStyleWithLineBreakMode:4];
                _lineBreakInfo = [[NSDictionary allocWithZone:[self zone]] initWithObjectsAndKeys:style, NSParagraphStyleAttributeName, nil];
            }
        }
        CGFloat minWidth = [HSSoundsLibraryiTunesSong minWidthForIdentifier:identifier cell:[column dataCell]];
        if (minWidth > 0.0) {
            [column setMinWidth:minWidth];
        }
        CGFloat maxWidth = [HSSoundsLibraryiTunesSong maxWidthForIdentifier:identifier cell:[column dataCell]];
        if (maxWidth > 0.0) {
            [column setMaxWidth:maxWidth];
        }
        [_soundsTableView addTableColumn:column];
        [column release];
    }
    if ([[_soundsTableView tableColumns] count] != 0) {
        NSRect lastColumn = [_soundsTableView rectOfColumn:[[_soundsTableView tableColumns] count] - 1];
        if (lastColumn.origin.x + lastColumn.size.width < [_soundsTableView bounds].size.width) {
            [_soundsTableView sizeToFit];
        }
    }
    NSString *iTunesPath = [[NSWorkspace sharedWorkspace] fullPathForApplication:@"iTunes.app"];
    if (iTunesPath != nil) {
        NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:iTunesPath];
        [icon setSize:NSMakeSize(16.0f, 16.0f)];
        [_openiTunesButton setImage:icon];
    }
    [_openiTunesButton setEnabled:(iTunesPath != nil)];
    [_openiTunesButton sizeToFit];
    [_soundsTableView setGridStyleMask:NSTableViewSolidVerticalGridLineMask];
    [self outlineViewSelectionDidChange:nil];
}

- (void)dealloc
{
    if ([_browseOutlineView delegate] == self) {
        [_browseOutlineView setDelegate:0];
    }
    if ([_browseOutlineView dataSource] == self) {
        [_browseOutlineView setDataSource:0];
    }
    [_rootOutlineItems release];
    [_mediaDataProvider release];
    [super dealloc];
}

@end

