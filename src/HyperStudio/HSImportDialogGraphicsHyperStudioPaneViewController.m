#import "HSImportDialogGraphicsHyperStudioPaneViewController.h"

@implementation HSImportDialogGraphicsHyperStudioPaneViewController

/* i386 ivar offsets: _lineBreakInfo=0x98, _rootOutlineItems=0x9c, _selectedMediaItem=0xa0, _mediaDataProvider=0xa4 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b22c4 @ 001b22c4, 232 bytes * /

void FUN_001b22c4(id self,SEL _cmd)

{
  id self_00;
  
  self_00 = _objc_msgSend(cls_NSAutoreleasePool,sel_new);
  _objc_msgSend(cls_HSImportDialogController,sel_registerPaneViewController_withIdentifier_,self,
                *(undefined4 *)PTR_PTR_003360d0);
  _objc_msgSend(cls_HSImportDialogController,sel_registerPaneViewController_withIdentifier_,self,
                *(undefined4 *)PTR_PTR_003360d4);
  _objc_msgSend(cls_HSImportDialogController,sel_registerPaneViewController_withIdentifier_,self,
                *(undefined4 *)PTR_PTR_003360d8);
  _objc_msgSend(cls_HSImportDialogController,sel_registerPaneViewController_withIdentifier_,self,
                *(undefined4 *)PTR_PTR_00336664);
  _objc_msgSend(self_00,sel_release);
  return;
}

*/
+ (void)load
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    [HSImportDialogController registerPaneViewController:self withIdentifier:HSImportDialogControllerTypeBackground];
    [HSImportDialogController registerPaneViewController:self withIdentifier:HSImportDialogControllerTypeGraphic];
    [HSImportDialogController registerPaneViewController:self withIdentifier:HSImportDialogControllerTypeGraphicObject];
    [HSImportDialogController registerPaneViewController:self withIdentifier:HSImportDialogControllerTypeGetAnotherPicture];
    [pool release];
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
            pvVar2 = [[HSGraphicsLibraryBuiltInMediaDataProvider allocWithZone:[self zone]] init];
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
/* FUN_001b1f84 @ 001b1f84, 485 bytes * /

id FUN_001b1f84(HSImportDialogGraphicsHyperStudioPaneViewController *self,SEL _cmd,
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
/* FUN_001b1d9c @ 001b1d9c, 182 bytes * /

void FUN_001b1d9c(HSImportDialogGraphicsHyperStudioPaneViewController *self,SEL _cmd,
                 id outlineViewSelectionDidChange)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend((self->super)._browseTableView,sel_autosaveExpandedItems);
  if ((char)pvVar1 != '\0') {
    pvVar1 = (self->super)._browseTableView;
    pvVar2 = _objc_msgSend(pvVar1,sel_selectedRow);
    pvVar1 = _objc_msgSend(pvVar1,sel_itemAtRow_,pvVar2);
    pvVar2 = _objc_msgSend(cls_HSGraphicsLibraryBuiltInMediaItem,sel_class);
    pvVar2 = _objc_msgSend(pvVar1,sel_isKindOfClass_,pvVar2);
    if (((pvVar1 != (id)0x0) && ((char)pvVar2 != '\0')) && (pvVar1 != self->_selectedMediaItem)) {
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
        if (item != nil && [item isKindOfClass:[HSGraphicsLibraryBuiltInMediaItem class]] && item != _selectedMediaItem) {
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
/* FUN_001b1ce8 @ 001b1ce8, 135 bytes * /

id FUN_001b1ce8(HSImportDialogGraphicsHyperStudioPaneViewController *self,SEL _cmd,id outlineView,
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
/* FUN_001b1c62 @ 001b1c62, 77 bytes * /

int FUN_001b1c62(HSImportDialogGraphicsHyperStudioPaneViewController *self,SEL _cmd,id outlineView,
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

- (BOOL)mediaPathConformsToFilter:(id)aFilter
{
    id pvVar1_2;

    pvVar1_2 = [[_itemsFilterPopUp selectedItem] representedObject];
    return (BOOL)[[HSLibraryContentFilter sharedContentFilter] mediaItem:aFilter conformsToDisplayNameFilter:_filterString mediaTypeFilter:pvVar1_2];
}

- (id)currentMediaPathsLocation
{
    return [_selectedMediaItem mediaItem];
}

- (id)createMediaPathsForKey:(id)aKey
{
    Class pvVar1;
    id self_01;
    id self_02;
    id pvVar1_3;
    id pvVar1_4;

    pvVar1 = [HSLibraryPicturesMediaItem class];
    if (![aKey isKindOfClass:pvVar1]) {
        if (![aKey isKindOfClass:[HSLibraryPicturesAllMediaItem class]]) {
            pvVar1_3 = [NSArray array];
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

- (id)paneFileDisplayName
{
    return [[[[self paneFilePath] lastPathComponent] stringByDeletingPathExtension] hyperStringByReplacingUnderlineWithSlashes];
}

- (BOOL)isPaneValid
{
    return (BOOL)[HSRestrictionsManager restrictionState:HSUsageMediaLibraryEnabled];
}

- (id)paneTitle
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"ImportDialogGraphicsHyperStudioPaneTitle" value:@"" table:@"ImportDialogs"];
}

- (id)paneViewNibName
{
    return @"IDGHyperStudioPaneView";
}

- (NSInteger)paneWeight
{
    return 0;
}

- (id)paneIdentifier
{
    return @"HSImportDialogHyperStudioGraphics";
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b2499 @ 001b2499, 252 bytes * /

void FUN_001b2499(HSImportDialogGraphicsHyperStudioPaneViewController *self,SEL _cmd,
                 id willMountToDialogController)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  HSImportDialogGraphicsHyperStudioPaneViewController *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_HSImportDialogGraphicsPaneViewCo_00353600;
  _objc_msgSendSuper(&local_14,sel_willMountToDialogController_,willMountToDialogController);
  pvVar1 = _objc_msgSend(self,sel_dialogType);
  pvVar2 = _objc_msgSend(pvVar1,sel_isEqualToString_,*(undefined4 *)PTR_PTR_003360d0);
  pvVar1 = (self->super)._itemsFilterPopUp;
  if ((char)pvVar2 == '\0') {
    pvVar1 = _objc_msgSend(pvVar1,sel_indexOfItemWithRepresentedObject_,&cfstr_Graphic);
    if (pvVar1 == (id)0xffffffff) {
      return;
    }
    self = (self->super)._itemsFilterPopUp;
    op = sel_selectItemAtIndex_;
  }
  else {
    pvVar1 = _objc_msgSend(pvVar1,sel_indexOfItemWithRepresentedObject_,&cfstr_Background);
    if (pvVar1 == (id)0xffffffff) {
      return;
    }
    _objc_msgSend((self->super)._itemsFilterPopUp,sel_selectItemAtIndex_,pvVar1);
    pvVar1 = (id)0x0;
    op = sel_itemsFilterPopUpDidChange_;
  }
  _objc_msgSend(self,op,pvVar1);
  return;
}

*/
- (void)willMountToDialogController:(id)aController
{
    [super willMountToDialogController:aController];
    if ([[self dialogType] isEqualToString:HSImportDialogControllerTypeBackground]) {
        NSInteger index = [_itemsFilterPopUp indexOfItemWithRepresentedObject:@"Background"];
        if (index == -1) {
            return;
        }
        [_itemsFilterPopUp selectItemAtIndex:index];
        [self itemsFilterPopUpDidChange:nil];
    } else {
        NSInteger index = [_itemsFilterPopUp indexOfItemWithRepresentedObject:@"Graphic"];
        if (index == -1) {
            return;
        }
        [_itemsFilterPopUp selectItemAtIndex:index];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b2595 @ 001b2595, 1347 bytes * /

void FUN_001b2595(HSImportDialogGraphicsHyperStudioPaneViewController *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  undefined *puVar3;
  id self_01;
  id self_02;
  id pvVar4;
  HSImportDialogGraphicsHyperStudioPaneViewController *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSImportDialogGraphicsPaneViewCo_00353600;
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
  _objc_msgSend((self->super)._browseTableView,sel_setDataSource_,self);
  _objc_msgSend((self->super)._browseTableView,sel_setDelegate_,self);
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
  pvVar1 = _objc_msgSend(cls_HSLibraryContentFilter,sel_sharedContentFilter);
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
  _objc_msgSend(self,sel_outlineViewSelectionDidChange_,0);
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
    [_browseTableView setDataSource:self];
    [_browseTableView setDelegate:self];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSMenuItem *allTypes = [[NSMenuItem alloc] initWithTitle:[bundle localizedStringForKey:@"AllTypes" value:@"" table:@"ImportDialogs"] action:NULL keyEquivalent:@""];
    [allTypes setRepresentedObject:nil];
    NSMenu *menu = [[NSMenu alloc] init];
    [menu insertItem:allTypes atIndex:0];
    [allTypes release];
    NSEnumerator *enumerator = [[[HSLibraryContentFilter sharedContentFilter] sortedMediaTypes] objectEnumerator];
    id type;
    while ((type = [enumerator nextObject]) != nil) {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[[NSBundle bundleForClass:[self class]] localizedStringForKey:type value:@"" table:@"ImportDialogs"] action:NULL keyEquivalent:@""];
        [item setRepresentedObject:type];
        [menu addItem:item];
        [item release];
    }
    [_itemsFilterPopUp setMenu:menu];
    [menu release];
    [self outlineViewSelectionDidChange:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b23ac @ 001b23ac, 237 bytes * /

void FUN_001b23ac(HSImportDialogGraphicsHyperStudioPaneViewController *self,SEL _cmd)

{
  HSImportDialogGraphicsHyperStudioPaneViewController *pHVar1;
  HSImportDialogGraphicsHyperStudioPaneViewController *local_14;
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
  local_10 = PTR_s_HSImportDialogGraphicsPaneViewCo_00353600;
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

