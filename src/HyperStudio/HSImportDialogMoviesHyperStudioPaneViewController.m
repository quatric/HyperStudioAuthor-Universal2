#import "HSImportDialogMoviesHyperStudioPaneViewController.h"

@implementation HSImportDialogMoviesHyperStudioPaneViewController

/* i386 ivar offsets: _lineBreakInfo=0xa4, _rootOutlineItems=0xa8, _selectedMediaItem=0xac, _mediaDataProvider=0xb0 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_001dccc2 @ 001dccc2, 152 bytes * /

void FUN_001dccc2(id self,SEL _cmd)

{
  id self_00;
  
  self_00 = _objc_msgSend(cls_NSAutoreleasePool,sel_new);
  _objc_msgSend(cls_HSImportDialogController,sel_registerPaneViewController_withIdentifier_,self,
                *(undefined4 *)PTR_PTR_00336670);
  _objc_msgSend(cls_HSImportDialogController,sel_registerPaneViewController_withIdentifier_,self,
                *(undefined4 *)PTR_PTR_003360cc);
  _objc_msgSend(self_00,sel_release);
  return;
}

*/
+ (void)load
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    [HSImportDialogController registerPaneViewController:self withIdentifier:HSImportDialogControllerTypeMovies];
    [HSImportDialogController registerPaneViewController:self withIdentifier:HSImportDialogControllerTypeAnimations];
    [pool release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001dcb21 @ 001dcb21, 417 bytes * /

id FUN_001dcb21(HSImportDialogMoviesHyperStudioPaneViewController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  undefined *puVar5;
  int iVar6;
  undefined4 uVar7;
  
  if (self->_rootOutlineItems == (id)0x0) {
    pvVar1 = self->_mediaDataProvider;
    if (pvVar1 == (id)0x0) {
      pvVar1 = _objc_msgSend(self,sel_dialogType);
      uVar7 = *(undefined4 *)PTR_PTR_003360cc;
      pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_,uVar7);
      puVar5 = cls_HSImportDialogBuiltinMoviesDataProvider;
      if ((char)pvVar1 != '\0') {
        puVar5 = cls_HSGraphicsLibraryBuiltinMoviesDataProvider;
      }
      pvVar1 = _objc_msgSend(self,sel_zone,uVar7);
      pvVar1 = _objc_msgSend(puVar5,sel_allocWithZone_,pvVar1);
      pvVar1 = _objc_msgSend(pvVar1,sel_init);
      self->_mediaDataProvider = pvVar1;
    }
    pvVar1 = _objc_msgSend(pvVar1,sel_rootItem);
    if ((pvVar1 != (id)0x0) &&
       (pvVar2 = _objc_msgSend(pvVar1,sel_numberOfSubitems), 0 < (int)pvVar2)) {
      iVar6 = 0;
      do {
        puVar5 = cls_NSMutableArray;
        pvVar3 = self->_rootOutlineItems;
        if (pvVar3 == (id)0x0) {
          pvVar3 = _objc_msgSend(self,sel_zone);
          pvVar3 = _objc_msgSend(puVar5,sel_allocWithZone_,pvVar3);
          pvVar3 = _objc_msgSend(pvVar3,sel_initWithCapacity_,0);
          self->_rootOutlineItems = pvVar3;
        }
        pvVar4 = _objc_msgSend(pvVar1,sel_subitemAtIndex_,iVar6);
        _objc_msgSend(pvVar3,sel_addObject_,pvVar4);
        iVar6 = iVar6 + 1;
      } while (iVar6 < (int)pvVar2);
    }
  }
  return self->_rootOutlineItems;
}

*/
- (id)rootItems
{
    if (_rootOutlineItems == nil) {
        if (_mediaDataProvider == nil) {
            Class providerClass;
            if ([[self dialogType] isEqualToString:HSImportDialogControllerTypeAnimations]) {
                providerClass = [HSGraphicsLibraryBuiltinMoviesDataProvider class];
            } else {
                providerClass = [HSImportDialogBuiltinMoviesDataProvider class];
            }
            _mediaDataProvider = [[providerClass allocWithZone:[self zone]] init];
        }
        id rootItem = [_mediaDataProvider rootItem];
        if (rootItem != nil) {
            NSInteger count = [rootItem numberOfSubitems];
            for (NSInteger i = 0; i < count; i++) {
                if (_rootOutlineItems == nil) {
                    _rootOutlineItems = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:0];
                }
                [_rootOutlineItems addObject:[rootItem subitemAtIndex:i]];
            }
        }
    }
    return _rootOutlineItems;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001dc93c @ 001dc93c, 485 bytes * /

id FUN_001dc93c(HSImportDialogMoviesHyperStudioPaneViewController *self,SEL _cmd,
               id objectValueForItem)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined4 uVar4;
  undefined4 uVar5;
  
  pvVar1 = _objc_msgSend(objectValueForItem,sel_displayName);
  if (self->_lineBreakInfo != (id)0x0) {
    pvVar2 = _objc_msgSend(cls_NSAttributedString,sel_alloc);
    pvVar1 = _objc_msgSend(pvVar2,sel_initWithString_attributes_,pvVar1,self->_lineBreakInfo);
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

- (BOOL)outlineView:(id)aView shouldExpandItem:(id)aItem
{
    return [[aItem queryHyperInterface:@protocol(HSLibraryMediaItem)] numberOfSubitems] != 0;
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

/* --- i386 decompilation (Ghidra) ---
/* FUN_001dc780 @ 001dc780, 138 bytes * /

void FUN_001dc780(HSImportDialogMoviesHyperStudioPaneViewController *self,SEL _cmd,
                 id outlineViewSelectionDidChange)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend((self->super)._browseTableView,sel_autosaveExpandedItems);
  if ((char)pvVar1 != '\0') {
    pvVar1 = (self->super)._browseTableView;
    pvVar2 = _objc_msgSend(pvVar1,sel_selectedRow);
    pvVar1 = _objc_msgSend(pvVar1,sel_itemAtRow_,pvVar2);
    if ((pvVar1 != (id)0x0) && (pvVar1 != self->_selectedMediaItem)) {
      self->_selectedMediaItem = pvVar1;
    }
  }
  _objc_msgSend(self,sel_invalidateMediaPaths);
  return;
}

*/
- (void)outlineViewSelectionDidChange:(id)aChange
{
    if ([_browseTableView autosaveExpandedItems]) {
        id item = [_browseTableView itemAtRow:[_browseTableView selectedRow]];
        if (item != nil && item != _selectedMediaItem) {
            _selectedMediaItem = item;
        }
    }
    [self invalidateMediaPaths];
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
/* FUN_001dc6cc @ 001dc6cc, 135 bytes * /

id FUN_001dc6cc(HSImportDialogMoviesHyperStudioPaneViewController *self,SEL _cmd,id outlineView,
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
    if (aItem == nil) {
        id items = [self rootItems];
        if (aChild != NSNotFound && aChild >= 0 && (NSUInteger)aChild < [items count]) {
            return [items objectAtIndex:aChild];
        }
        return nil;
    }
    return [aItem subitemAtIndex:aChild];
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
/* FUN_001dc646 @ 001dc646, 77 bytes * /

int FUN_001dc646(HSImportDialogMoviesHyperStudioPaneViewController *self,SEL _cmd,id outlineView,
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
        aItem = [self rootItems];
    }
    return [aItem numberOfSubitems];
}

- (BOOL)mediaPathConformsToFilter:(id)aFilter
{
    NSString *pvVar1;
    id pvVar2_2;

    pvVar1 = [self filterString];
    pvVar2_2 = [[_itemsFilterPopUp selectedItem] representedObject];
    return (BOOL)[[HSLibraryMoviesContentFilter sharedContentFilter] mediaItem:aFilter conformsToDisplayNameFilter:pvVar1 mediaTypeFilter:pvVar2_2];
}

- (id)currentMediaPathsLocation
{
    return _selectedMediaItem;
}

- (id)createMediaPathsForKey:(id)aKey
{
    Class pvVar1;
    id self_01;
    id self_02;
    id pvVar1_3;
    id pvVar1_4;

    pvVar1 = [HSGraphicsLibraryAnimationsMediaItem class];
    if (![aKey isKindOfClass:pvVar1]) {
        if (![aKey isKindOfClass:[HSGraphicsLibraryAnimationsAllMediaItem class]]) {
            pvVar1_3 = [NSMutableArray array];
            if (pvVar1_3 != nil) {
                return pvVar1_3;
            }
            aKey = nil;
        }
    }
    pvVar1_4 = [aKey filterPictures:@"" byCategory:@""];
    self_01 = [NSMutableArray arrayWithCapacity:[pvVar1_4 count]];
    NSEnumerator *enumerator = [pvVar1_4 objectEnumerator];
    while (self_02 = [enumerator nextObject], self_02 != nil) {
        [self_01 addObject:[[self_02 URL] path]];
    }
    return self_01;
}

- (BOOL)isPaneValid
{
    return (BOOL)[HSRestrictionsManager restrictionState:HSUsageMediaLibraryEnabled];
}

- (id)paneTitle
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"ImportDialogGraphicsHyperStudioPaneTitle" value:@"" table:@"ImportDialogs"];
}

- (NSInteger)paneWeight
{
    return 1;
}

- (id)paneIdentifier
{
    return @"HSImportDialogHyperStudioMovies";
}

- (id)paneViewNibName
{
    return @"IDMoviesHyperPaneView";
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001dce53 @ 001dce53, 738 bytes * /

void FUN_001dce53(HSImportDialogMoviesHyperStudioPaneViewController *self,SEL _cmd,
                 id willMountToDialogController)

{
  undefined *puVar1;
  id pvVar2;
  HSImportDialogMoviesHyperStudioPaneViewController *pHVar3;
  cfstringStruct *pcVar4;
  id pvVar5;
  id pvVar6;
  cfstringStruct *pcVar7;
  undefined4 uVar8;
  cfstringStruct *pcVar9;
  cfstringStruct *pcVar10;
  HSImportDialogMoviesHyperStudioPaneViewController *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSImportDialogMoviesPaneViewCont_00354020;
  _objc_msgSendSuper(&local_1c,sel_willMountToDialogController_,willMountToDialogController);
  pvVar2 = _objc_msgSend(self,sel_dialogType);
  pcVar7 = *(cfstringStruct **)PTR_PTR_003360cc;
  pvVar2 = _objc_msgSend(pvVar2,sel_isEqualToString_,pcVar7);
  if ((char)pvVar2 == '\0') {
    pcVar7 = &cfstr_Animation;
    pHVar3 = _objc_msgSend((self->super)._itemsFilterPopUp,sel_indexOfItemWithRepresentedObject_,
                           &cfstr_Animation);
    if (pHVar3 != (HSImportDialogMoviesHyperStudioPaneViewController *)0xffffffff) {
      _objc_msgSend((self->super)._itemsFilterPopUp,sel_removeItemAtIndex_,pHVar3);
      pcVar7 = (cfstringStruct *)pHVar3;
    }
  }
  pHVar3 = _objc_msgSend((self->super)._browseTableView,sel_dataSource,pcVar7);
  if (pHVar3 != self) {
    pcVar7 = (cfstringStruct *)self;
    _objc_msgSend((self->super)._browseTableView,sel_setDataSource_,self);
  }
  pHVar3 = _objc_msgSend((self->super)._browseTableView,sel_delegate,pcVar7);
  if (pHVar3 != self) {
    pcVar7 = (cfstringStruct *)self;
    _objc_msgSend((self->super)._browseTableView,sel_setDelegate_,self);
  }
  pvVar2 = _objc_msgSend(self,sel_dialogType,pcVar7);
  uVar8 = *(undefined4 *)PTR_PTR_00336670;
  pvVar2 = _objc_msgSend(pvVar2,sel_isEqualToString_,uVar8);
  puVar1 = cls_NSBundle;
  if ((char)pvVar2 != '\0') {
    pvVar2 = _objc_msgSend(self,sel_class,uVar8);
    pvVar2 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar2);
    pcVar7 = &cfstr_ImportDialogs;
    pcVar10 = &cfstr_empty;
    pcVar9 = &cfstr_Movies;
    pcVar4 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_Movies,&cfstr_empty,
                           &cfstr_ImportDialogs);
    pvVar2 = _objc_msgSend(self,sel_rootItems);
    pvVar2 = _objc_msgSend(pvVar2,sel_objectEnumerator);
    do {
      pvVar5 = _objc_msgSend(pvVar2,sel_nextObject,pcVar9,pcVar10,pcVar7);
      if (pvVar5 == (id)0x0) goto LAB_001dd0f6;
      pvVar6 = _objc_msgSend(pvVar5,sel_displayName,pcVar9);
      pcVar9 = pcVar4;
      pvVar6 = _objc_msgSend(pvVar6,sel_isEqualToString_);
      puVar1 = cls_NSIndexSet;
    } while ((char)pvVar6 == '\0');
    pvVar2 = (self->super)._browseTableView;
    pvVar5 = _objc_msgSend(pvVar2,sel_rowForItem_,pvVar5);
    pvVar5 = _objc_msgSend(puVar1,sel_indexSetWithIndex_,pvVar5);
    _objc_msgSend(pvVar2,sel_selectRowIndexes_byExtendingSelection_,pvVar5,0);
  }
LAB_001dd0f6:
  _objc_msgSend(self,sel_outlineViewSelectionDidChange_,0);
  _objc_msgSend(self,sel_itemsFilterPopUpDidChange_,0);
  return;
}

*/
- (void)willMountToDialogController:(id)aController
{
    [super willMountToDialogController:aController];
    if (![[self dialogType] isEqualToString:HSImportDialogControllerTypeAnimations]) {
        NSInteger index = [_itemsFilterPopUp indexOfItemWithRepresentedObject:@"Animation"];
        if (index != -1) {
            [_itemsFilterPopUp removeItemAtIndex:index];
        }
    }
    if ([_browseTableView dataSource] != self) {
        [_browseTableView setDataSource:self];
    }
    if ([_browseTableView delegate] != self) {
        [_browseTableView setDelegate:self];
    }
    if ([[self dialogType] isEqualToString:HSImportDialogControllerTypeMovies]) {
        NSString *moviesTitle = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Movies" value:@"" table:@"ImportDialogs"];
        NSEnumerator *enumerator = [[self rootItems] objectEnumerator];
        id item;
        while ((item = [enumerator nextObject]) != nil) {
            if ([[item displayName] isEqualToString:moviesTitle]) {
                [_browseTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:[_browseTableView rowForItem:item]] byExtendingSelection:NO];
                break;
            }
        }
    }
    [self outlineViewSelectionDidChange:nil];
    [self itemsFilterPopUpDidChange:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001dd135 @ 001dd135, 1333 bytes * /

void FUN_001dd135(HSImportDialogMoviesHyperStudioPaneViewController *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  undefined *puVar3;
  id self_01;
  id self_02;
  id pvVar4;
  HSImportDialogMoviesHyperStudioPaneViewController *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSImportDialogMoviesPaneViewCont_00354020;
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
    self->_lineBreakInfo = pvVar2;
  }
  pvVar2 = _objc_msgSend((self->super)._browseTableView,sel_outlineTableColumn,puVar3);
  _objc_msgSend(pvVar2,sel_setDataCell_,pvVar1);
  _objc_msgSend((self->super)._browseTableView,sel_setAllowsMultipleSelection_,0);
  _objc_msgSend((self->super)._browseTableView,sel_setAllowsColumnSelection_,0);
  _objc_msgSend((self->super)._browseTableView,sel_setIntercellSpacing_,0x3f800000,0x40000000);
  _objc_msgSend((self->super)._browseTableView,sel_setAllowsColumnReordering_,0);
  _objc_msgSend((self->super)._browseTableView,sel_setAllowsColumnResizing_,0);
  _objc_msgSend((self->super)._browseTableView,sel_setAllowsEmptySelection_,0);
  _objc_msgSend((self->super)._browseTableView,sel_setColumnAutoresizingStyle_,3);
  _objc_msgSend((self->super)._browseTableView,sel_setAutosaveExpandedItems_,1);
  puVar3 = cls_NSBundle;
  pvVar1 = _objc_msgSend(self,sel_class);
  pvVar1 = _objc_msgSend(puVar3,sel_bundleForClass_,pvVar1);
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,&cfstr_AllTypes,&cfstr_empty,
                         &cfstr_ImportDialogs);
  pvVar2 = _objc_msgSend(cls_NSMenuItem,sel_alloc);
  pvVar1 = _objc_msgSend(pvVar2,sel_initWithTitle_action_keyEquivalent_,pvVar1,0,&cfstr_empty);
  _objc_msgSend(pvVar1,sel_setRepresentedObject_,0);
  pvVar2 = _objc_msgSend(cls_NSMenu,sel_alloc);
  self_01 = _objc_msgSend(pvVar2,sel_init);
  pvVar2 = pvVar1;
  _objc_msgSend(self_01,sel_insertItem_atIndex_,pvVar1,0);
  _objc_msgSend(pvVar1,sel_release);
  pvVar1 = _objc_msgSend(cls_HSLibraryMoviesContentFilter,sel_sharedContentFilter);
  pvVar1 = _objc_msgSend(pvVar1,sel_sortedMediaTypes);
  self_02 = _objc_msgSend(pvVar1,sel_objectEnumerator);
  pvVar1 = _objc_msgSend(self_02,sel_nextObject);
  puVar3 = cls_NSBundle;
  while (cls_NSBundle = puVar3, pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_class,pvVar2);
    pvVar2 = _objc_msgSend(puVar3,sel_bundleForClass_,pvVar2);
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,pvVar1,&cfstr_empty,
                           &cfstr_ImportDialogs);
    pvVar4 = _objc_msgSend(cls_NSMenuItem,sel_alloc);
    pvVar4 = _objc_msgSend(pvVar4,sel_initWithTitle_action_keyEquivalent_,pvVar2,0,&cfstr_empty);
    _objc_msgSend(pvVar4,sel_setRepresentedObject_,pvVar1);
    pvVar2 = pvVar4;
    _objc_msgSend(self_01,sel_addItem_);
    _objc_msgSend(pvVar4,sel_release);
    pvVar1 = _objc_msgSend(self_02,sel_nextObject);
    puVar3 = cls_NSBundle;
  }
  _objc_msgSend((self->super)._itemsFilterPopUp,sel_setMenu_,self_01);
  _objc_msgSend(self_01,sel_release);
  _objc_msgSend((self->super)._itemsFilterPopUp,sel_selectItemAtIndex_,0);
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
    [[_browseTableView outlineTableColumn] setDataCell:cell];
    [_browseTableView setAllowsMultipleSelection:NO];
    [_browseTableView setAllowsColumnSelection:NO];
    [_browseTableView setIntercellSpacing:NSMakeSize(1.0f, 2.0f)];
    [_browseTableView setAllowsColumnReordering:NO];
    [_browseTableView setAllowsColumnResizing:NO];
    [_browseTableView setAllowsEmptySelection:NO];
    [_browseTableView setColumnAutoresizingStyle:3];
    [_browseTableView setAutosaveExpandedItems:YES];
    NSMenuItem *allTypes = [[NSMenuItem alloc] initWithTitle:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"AllTypes" value:@"" table:@"ImportDialogs"] action:NULL keyEquivalent:@""];
    [allTypes setRepresentedObject:nil];
    NSMenu *menu = [[NSMenu alloc] init];
    [menu insertItem:allTypes atIndex:0];
    [allTypes release];
    NSEnumerator *enumerator = [[[HSLibraryMoviesContentFilter sharedContentFilter] sortedMediaTypes] objectEnumerator];
    id type;
    while ((type = [enumerator nextObject]) != nil) {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[[NSBundle bundleForClass:[self class]] localizedStringForKey:type value:@"" table:@"ImportDialogs"] action:NULL keyEquivalent:@""];
        [item setRepresentedObject:type];
        [menu addItem:item];
        [item release];
    }
    [_itemsFilterPopUp setMenu:menu];
    [menu release];
    [_itemsFilterPopUp selectItemAtIndex:0];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001dcd5a @ 001dcd5a, 249 bytes * /

void FUN_001dcd5a(HSImportDialogMoviesHyperStudioPaneViewController *self,SEL _cmd)

{
  HSImportDialogMoviesHyperStudioPaneViewController *pHVar1;
  HSImportDialogMoviesHyperStudioPaneViewController *local_14;
  undefined *local_10;
  
  pHVar1 = _objc_msgSend((self->super)._browseTableView,sel_delegate);
  if (pHVar1 == self) {
    _objc_msgSend((self->super)._browseTableView,sel_setDelegate_,0);
  }
  pHVar1 = _objc_msgSend((self->super)._browseTableView,sel_dataSource);
  if (pHVar1 == self) {
    _objc_msgSend((self->super)._browseTableView,sel_setDataSource_,0);
  }
  _objc_msgSend(self->_lineBreakInfo,sel_release);
  _objc_msgSend(self->_rootOutlineItems,sel_release);
  _objc_msgSend(self->_mediaDataProvider,sel_release);
  local_14 = self;
  local_10 = PTR_s_HSImportDialogMoviesPaneViewCont_00354020;
  _objc_msgSendSuper(&local_14,sel_dealloc);
  return;
}

*/
- (void)dealloc
{
    if ([_browseTableView delegate] == self) {
        [_browseTableView setDelegate:nil];
    }
    if ([_browseTableView dataSource] == self) {
        [_browseTableView setDataSource:nil];
    }
    [_lineBreakInfo release];
    [_rootOutlineItems release];
    [_mediaDataProvider release];
    [super dealloc];
}

@end

@implementation HSImportDialogBuiltinMoviesDataProvider

- (id)builtinMoviesFolders
{
    return [HSGraphicsLibraryMoviesHelper hyperStudioMoviesFolders];
}

@end

