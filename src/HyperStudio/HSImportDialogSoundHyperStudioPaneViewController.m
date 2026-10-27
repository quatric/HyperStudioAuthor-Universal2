#import "HSImportDialogSoundHyperStudioPaneViewController.h"

static NSInteger HSImportDialogSoundHyperStudioSoundCompare(id a, id b, void *context)
{
    id identifier = (id)context;
    return [[HSLibrarySound stringForValue:[a valueForKey:identifier] forIdentifier:identifier] caseInsensitiveCompare:[HSLibrarySound stringForValue:[b valueForKey:identifier] forIdentifier:identifier]];
}

@implementation HSImportDialogSoundHyperStudioPaneViewController

/* i386 ivar offsets: _browseOutlineView=0x94, _rootOutlineItems=0x98, _selectedMediaItem=0x9c, _mediaDataProvider=0xa0 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e095e @ 001e095e, 108 bytes * /

void FUN_001e095e(id self,SEL _cmd)

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
/* FUN_001e086f @ 001e086f, 239 bytes * /

void FUN_001e086f(HSImportDialogSoundHyperStudioPaneViewController *self,SEL _cmd)

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
            pvVar2 = [[HSSoundsLibraryBuiltInMediaDataProvider allocWithZone:[self zone]] init];
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
/* FUN_001e0535 @ 001e0535, 479 bytes * /

id FUN_001e0535(HSImportDialogSoundHyperStudioPaneViewController *self,SEL _cmd,
               id objectValueForItem)

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
    NSMutableDictionary *value;
    id icon;
    id actionImage;
    SEL actionSelector;
    id actionTarget;
    if (_lineBreakInfo != nil) {
        text = [[[NSAttributedString alloc] initWithString:text attributes:_lineBreakInfo] autorelease];
    }
    if (text == nil) {
        return nil;
    }
    value = [NSMutableDictionary dictionaryWithCapacity:0];
    [value setObject:text forKey:textKey];
    icon = [aItem icon];
    if (icon != nil) {
        [value setObject:icon forKey:imageKey];
    }
    actionImage = [aItem actionImage];
    if (actionImage != nil) {
        [value setObject:actionImage forKey:actionImageKey];
    }
    actionSelector = [aItem actionSelector];
    if (actionSelector != NULL) {
        [value setObject:[NSValue valueWithPointer:actionSelector] forKey:actionSelectorKey];
    }
    actionTarget = [aItem actionTarget];
    if (actionTarget != nil) {
        [value setObject:actionTarget forKey:actionTargetKey];
    }
    return value;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e0341 @ 001e0341, 500 bytes * /

void FUN_001e0341(HSImportDialogSoundHyperStudioPaneViewController *self,SEL _cmd,id filterSounds,
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
  pvVar1 = _objc_msgSend(self->_selectedMediaItem,sel_mediaItem);
  pcVar3 = (self->super)._filterString;
  pvVar2 = (self->super)._categoryString;
  pvVar1 = _objc_msgSend(pvVar1,sel_filterSounds_byCategory_,pcVar3,pvVar2);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  (self->super)._filteredItems = pvVar1;
  _objc_msgSend((self->super)._sortedArrayHint,sel_release);
  pvVar1 = _objc_msgSend((self->super)._filteredItems,sel_sortedArrayHint);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  (self->super)._sortedArrayHint = pvVar1;
  if ((self->super)._sortedIdentifier != (id)0x0) {
    _objc_msgSend((self->super)._filteredItems,sel_autorelease);
    pvVar2 = (self->super)._sortedIdentifier;
    pcVar3 = FUN_001dffac;
    pvVar1 = _objc_msgSend((self->super)._filteredItems,sel_sortedArrayUsingFunction_context_hint_,
                           FUN_001dffac,pvVar2,(self->super)._sortedArrayHint);
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
    _filteredItems = [[(HSLibrarySoundsMediaItem *)[_selectedMediaItem mediaItem] filterSounds:_filterString byCategory:_categoryString] retain];
    [_sortedArrayHint release];
    _sortedArrayHint = [[_filteredItems sortedArrayHint] retain];
    if (_sortedIdentifier != nil) {
        [_filteredItems autorelease];
        _filteredItems = [[_filteredItems sortedArrayUsingFunction:HSImportDialogSoundHyperStudioSoundCompare context:_sortedIdentifier hint:_sortedArrayHint] retain];
    }
    [self reloadMediaPaths];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e0282 @ 001e0282, 191 bytes * /

void FUN_001e0282(HSImportDialogSoundHyperStudioPaneViewController *self,SEL _cmd,id filter,
                 id byCategory)

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
      if (pvVar3 == (id)0x0) goto LAB_001e02ec;
    }
    bVar1 = true;
  }
  else {
LAB_001e02ec:
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
/* FUN_001e0164 @ 001e0164, 286 bytes * /

void FUN_001e0164(HSImportDialogSoundHyperStudioPaneViewController *self,SEL _cmd,id selectItem)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  if (selectItem != (id)0x0) {
    pvVar1 = _objc_msgSend(cls_HSSoundsLibraryBuiltInMediaItem,sel_class);
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
    NSInteger selectedRows;
    if (aItem != nil && ![aItem isKindOfClass:[HSSoundsLibraryBuiltInMediaItem class]]) {
        return;
    }
    if (_selectedMediaItem == aItem) {
        return;
    }
    selectedRows = [_soundsTableView numberOfSelectedRows];
    _selectedMediaItem = aItem;
    [self filterSounds:_filterString byCategory:_categoryString];
    if ([_soundsTableView numberOfSelectedRows] > 0) {
        if (selectedRows > 0) {
            [_soundsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
        }
        [_soundsTableView scrollRowToVisible:0];
    }
}

- (void)tableView:(id)aView didClickTableColumn:(id)aColumn
{
    if (![[aColumn identifier] isEqualToString:biSoundIconKey]) {
        [super tableView:aView didClickTableColumn:aColumn];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e00a7 @ 001e00a7, 189 bytes * /

id FUN_001e00a7(HSImportDialogSoundHyperStudioPaneViewController *self,SEL _cmd,
               id valueForSoundObject,id forIdentifier,id lineBreakInfo)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  
  pvVar2 = *(id *)PTR_003366f4;
  pvVar1 = _objc_msgSend(forIdentifier,sel_isEqualToString_,pvVar2);
  op = sel_defaultSoundIcon;
  if ((char)pvVar1 == '\0') {
    pvVar1 = lineBreakInfo;
    pvVar2 = _objc_msgSend(self,sel_stringForSoundObject_forIdentifier_lineBreakInfo_,
                           valueForSoundObject,forIdentifier,lineBreakInfo);
    if (lineBreakInfo == (id)0x0) {
      return pvVar2;
    }
    pvVar1 = _objc_msgSend(cls_NSAttributedString,sel_alloc,valueForSoundObject,forIdentifier,pvVar1
                          );
    self = _objc_msgSend(pvVar1,sel_initWithString_attributes_,pvVar2,lineBreakInfo);
    op = sel_autorelease;
  }
  pvVar2 = _objc_msgSend(self,op,pvVar2);
  return pvVar2;
}

*/
- (id)valueForSoundObject:(id)aObject forIdentifier:(id)aIdentifier lineBreakInfo:(id)aInfo
{
    id string;
    if ([aIdentifier isEqualToString:biSoundIconKey]) {
        return [self defaultSoundIcon];
    }
    string = [self stringForSoundObject:aObject forIdentifier:aIdentifier lineBreakInfo:aInfo];
    if (aInfo == nil) {
        return string;
    }
    return [[[NSAttributedString alloc] initWithString:string attributes:aInfo] autorelease];
}

- (id)stringForSoundObject:(id)aObject forIdentifier:(id)aIdentifier lineBreakInfo:(id)aInfo
{
    return [HSLibrarySound stringForValue:[aObject valueForKey:aIdentifier] forIdentifier:aIdentifier];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001dff55 @ 001dff55, 87 bytes * /

id FUN_001dff55(HSImportDialogSoundHyperStudioPaneViewController *self,SEL _cmd,
               id sortedSoundItemsForIdentifier)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_filteredItems);
  pvVar1 = _objc_msgSend(pvVar1,sel_sortedArrayUsingFunction_context_hint_,FUN_001dffac,
                         sortedSoundItemsForIdentifier,(self->super)._sortedArrayHint);
  return pvVar1;
}

*/
- (id)sortedSoundItemsForIdentifier:(id)aIdentifier
{
    return [[self filteredItems] sortedArrayUsingFunction:HSImportDialogSoundHyperStudioSoundCompare context:aIdentifier hint:_sortedArrayHint];
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
/* FUN_001dfcb6 @ 001dfcb6, 135 bytes * /

id FUN_001dfcb6(HSImportDialogSoundHyperStudioPaneViewController *self,SEL _cmd,id outlineView,
               int child,id ofItem)

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
    NSArray *rootItems;
    if (aItem != nil) {
        return [aItem subitemAtIndex:aChild];
    }
    rootItems = [self rootItems];
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
/* FUN_001dfc30 @ 001dfc30, 77 bytes * /

int FUN_001dfc30(HSImportDialogSoundHyperStudioPaneViewController *self,SEL _cmd,id outlineView,
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

/* --- i386 decompilation (Ghidra) ---
/* FUN_001dfb8d @ 001dfb8d, 163 bytes * /

id FUN_001dfb8d(HSImportDialogSoundHyperStudioPaneViewController *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  
  self_00 = cls_NSDictionary;
  pvVar1 = _objc_msgSend(cls_NSValue,sel_valueWithPointer_,sel_setSortAscending_);
  pvVar2 = _objc_msgSend(cls_NSValue,sel_valueWithPointer_,sel_setSortedIdentifier_);
  pvVar1 = _objc_msgSend(self_00,sel_dictionaryWithObjectsAndKeys_,pvVar2,
                         *(undefined4 *)PTR_PTR_00336788,pvVar1,*(undefined4 *)PTR_PTR_00336784,0);
  return pvVar1;
}

*/
- (id)optionsKeyToProcessingSelectorMap
{
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithPointer:@selector(setSortedIdentifier:)], HSImportDialogSoundSortIdentifierKey, [NSValue valueWithPointer:@selector(setSortAscending:)], HSImportDialogSoundSortAscendingKey, nil];
}

- (BOOL)isPaneValid
{
    return (BOOL)[HSRestrictionsManager restrictionState:HSUsageMediaLibraryEnabled];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001dfaa4 @ 001dfaa4, 177 bytes * /

id FUN_001dfaa4(HSImportDialogSoundHyperStudioPaneViewController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  
  pvVar1 = _objc_msgSend((self->super)._soundsTableView,sel_selectedRow);
  if ((int)pvVar1 < 0) {
    pvVar1 = (id)0x0;
  }
  else {
    if (((self->super)._sortAscending == '\0') && ((self->super)._sortedIdentifier != (id)0x0)) {
      self_00 = (self->super)._filteredItems;
      pvVar2 = _objc_msgSend(self_00,sel_count);
      pvVar1 = (id)(~(uint)pvVar1 + (int)pvVar2);
    }
    else {
      self_00 = (self->super)._filteredItems;
    }
    pvVar1 = _objc_msgSend(self_00,sel_objectAtIndex_,pvVar1);
    pvVar1 = _objc_msgSend(pvVar1,sel_URL);
    pvVar1 = _objc_msgSend(pvVar1,sel_path);
  }
  return pvVar1;
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
    return [[[_filteredItems objectAtIndex:row] URL] path];
}

- (id)paneTitle
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"ImportDialogGraphicsHyperStudioPaneTitle" value:@"" table:@"ImportDialogs"];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001df9f1 @ 001df9f1, 61 bytes * /

void FUN_001df9f1(HSImportDialogSoundHyperStudioPaneViewController *self,SEL _cmd)

{
  id self_00;
  
  self_00 = _objc_msgSend(cls_HSLibrarySoundIndexer,sel_sharedLibrarySoundIndexing);
  _objc_msgSend(self_00,sel_synchronize);
  return;
}

*/
- (void)paneDialogWillClose
{
    [(HSLibrarySoundIndexer *)[HSLibrarySoundIndexer sharedLibrarySoundIndexing] synchronize];
}

- (id)paneViewNibName
{
    return @"IDSoundHyperStudioPaneView";
}

- (NSInteger)paneWeight
{
    return 0;
}

- (id)paneIdentifier
{
    return @"HSImportDialogHyperStudioSound";
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e0b26 @ 001e0b26, 1091 bytes * /

void FUN_001e0b26(HSImportDialogSoundHyperStudioPaneViewController *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  undefined *puVar3;
  id pvVar4;
  HSImportDialogSoundHyperStudioPaneViewController *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSImportDialogSoundPaneViewContr_003540b0;
  _objc_msgSendSuper(&local_1c,sel_awakeFromNib);
  puVar3 = cls_HSMediaOutlineCell;
  pvVar1 = _objc_msgSend(self,sel_zone);
  pvVar1 = _objc_msgSend(puVar3,sel_allocWithZone_,pvVar1);
  pvVar1 = _objc_msgSend(pvVar1,sel_init);
  pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  puVar3 = sel_setLineBreakMode_;
  pvVar2 = _objc_msgSend(pvVar1,sel_respondsToSelector_,sel_setLineBreakMode_);
  if ((char)pvVar2 == '\0') {
    puVar3 = _objc_msgSend(cls_NSParagraphStyle,sel_hyperParagraphStyleWithLineBreakMode_,4);
    self_00 = cls_NSDictionary;
    pvVar2 = _objc_msgSend(self,sel_zone);
    pvVar2 = _objc_msgSend(self_00,sel_allocWithZone_,pvVar2);
    pvVar2 = _objc_msgSend(pvVar2,sel_initWithObjectsAndKeys_,puVar3,*(undefined4 *)PTR_00336150,0);
    (self->super)._lineBreakInfo = pvVar2;
  }
  pvVar2 = _objc_msgSend(self->_browseOutlineView,sel_outlineTableColumn,puVar3);
  _objc_msgSend(pvVar2,sel_setDataCell_,pvVar1);
  _objc_msgSend(self->_browseOutlineView,sel_setAllowsMultipleSelection_,0);
  _objc_msgSend(self->_browseOutlineView,sel_setAllowsColumnSelection_,0);
  _objc_msgSend(self->_browseOutlineView,sel_setIntercellSpacing_,0x3f800000,0x40000000);
  _objc_msgSend(self->_browseOutlineView,sel_setAllowsColumnReordering_,0);
  _objc_msgSend(self->_browseOutlineView,sel_setAllowsColumnResizing_,0);
  _objc_msgSend(self->_browseOutlineView,sel_setAllowsEmptySelection_,0);
  _objc_msgSend(self->_browseOutlineView,sel_setColumnAutoresizingStyle_,3);
  _objc_msgSend(self->_browseOutlineView,sel_setIndentationPerLevel_,0);
  _objc_msgSend(self->_browseOutlineView,sel_setAutosaveExpandedItems_,1);
  _objc_msgSend(self->_browseOutlineView,sel_setDataSource_,self);
  _objc_msgSend(self->_browseOutlineView,sel_setDelegate_,self);
  _objc_msgSend((self->super)._soundsTableView,sel_setGridStyleMask_,0);
  pvVar1 = _objc_msgSend((self->super)._soundsTableView,sel_tableColumns);
  pvVar2 = _objc_msgSend(pvVar1,sel_objectAtIndex_,0);
  _objc_msgSend(pvVar2,sel_setIdentifier_,*(undefined4 *)PTR_003366f4);
  pvVar2 = _objc_msgSend(pvVar1,sel_objectAtIndex_,1);
  pvVar4 = _objc_msgSend(cls_HSLibrarySound,sel_soundIdentifiers);
  pvVar4 = _objc_msgSend(pvVar4,sel_objectAtIndex_,0);
  _objc_msgSend(pvVar2,sel_setIdentifier_,pvVar4);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,2);
  pvVar2 = _objc_msgSend(cls_HSLibrarySound,sel_soundIdentifiers);
  pvVar2 = _objc_msgSend(pvVar2,sel_objectAtIndex_,1);
  _objc_msgSend(pvVar1,sel_setIdentifier_,pvVar2);
  _objc_msgSend(self,sel_outlineViewSelectionDidChange_,0);
  return;
}

*/
- (void)awakeFromNib
{
    HSMediaOutlineCell *cell;
    id style;
    NSArray *columns;
    [super awakeFromNib];
    cell = [[[HSMediaOutlineCell allocWithZone:[self zone]] init] autorelease];
    if (![cell respondsToSelector:@selector(setLineBreakMode:)]) {
        style = [NSParagraphStyle hyperParagraphStyleWithLineBreakMode:4];
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
    [_soundsTableView setGridStyleMask:NSTableViewGridNone];
    columns = [_soundsTableView tableColumns];
    [[columns objectAtIndex:0] setIdentifier:biSoundIconKey];
    [[columns objectAtIndex:1] setIdentifier:[[HSLibrarySound soundIdentifiers] objectAtIndex:0]];
    [[columns objectAtIndex:2] setIdentifier:[[HSLibrarySound soundIdentifiers] objectAtIndex:1]];
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

