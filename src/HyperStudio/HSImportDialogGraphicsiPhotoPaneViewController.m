#import "HSImportDialogGraphicsiPhotoPaneViewController.h"

@implementation HSImportDialogGraphicsiPhotoPaneViewController

/* i386 ivar offsets: _lineBreakInfo=0x98, _rootOutlineItems=0x9c, _selectedAlbum=0xa0, _mediaDataProvider=0xa4, _selectedPhotoIndex=0xa8, _invalidPhotoImage=0xac, _filteredPhotosHash=0xb0, _filteredPhotosHashLock=0xb4, _openiPhotoButton=0xb8, _browseOutlineView=0xbc */

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b42d9 @ 001b42d9, 232 bytes * /

void FUN_001b42d9(id self,SEL _cmd)

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

- (void)openiPhotoApp:(id)aApp
{
    if (![[NSWorkspace sharedWorkspace] launchApplication:@"iPhoto.app"]) {
        [[NSAlert alertWithMessageText:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Cannot launch iPhoto" value:@"" table:@"ImportDialogs"] defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"This application may have been renamed, moved or deleted, or you may not have sufficient privileges to open it." value:@"" table:@"ImportDialogs"]] runModal];
    }
}

- (void)iPhotoLibraryMightDidChange
{
    id pvVar2;
    id pvVar2_2;
    NSInteger pvVar2_3;

    _selectedAlbum = nil;
    pvVar2 = _browseOutlineView;
    pvVar2_2 = [pvVar2 itemAtRow:[pvVar2 selectedRow]];
    [_rootOutlineItems release];
    _rootOutlineItems = nil;
    [_browseOutlineView reloadData];
    pvVar2_3 = [_browseOutlineView rowForItem:pvVar2_2];
    if (pvVar2_3 != 0xffffffff) {
        [_browseOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:pvVar2_3] byExtendingSelection:NO];
    }
    [self outlineViewSelectionDidChange:0];
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
            pvVar2 = [[HSGraphicsLibraryiPhotoMediaDataProvider allocWithZone:[self zone]] init];
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
/* FUN_001b4786 @ 001b4786, 485 bytes * /

id FUN_001b4786(HSImportDialogGraphicsiPhotoPaneViewController *self,SEL _cmd,id objectValueForItem)

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

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b496b @ 001b496b, 379 bytes * /

id FUN_001b496b(HSImportDialogGraphicsiPhotoPaneViewController *self,SEL _cmd,id gridControl,
               int imageForItemAt)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  undefined4 extraout_EDX;
  
  pvVar2 = _objc_msgSend(self,sel_currentSelectedAlbum);
  pvVar2 = _objc_msgSend(self,sel_filteredPhotosForAlbum_,pvVar2);
  pvVar2 = _objc_msgSend(pvVar2,sel_objectAtIndex_,imageForItemAt);
  pvVar2 = _objc_msgSend(pvVar2,sel_URL);
  pvVar2 = _objc_msgSend(pvVar2,sel_path);
  pvVar3 = _objc_msgSend((self->super)._imageGrid,sel_mode);
  if (pvVar3 == (id)0x0) {
    pvVar3 = _objc_msgSend(cls_HSThumbnailManager,sel_sharedThumbnailManager,imageForItemAt);
    imageForItemAt = (int)pvVar2;
    pvVar3 = _objc_msgSend(pvVar3,sel_thumbnailForPath_,pvVar2);
    if (pvVar3 != (id)0x0) goto LAB_001b4a6f;
  }
  pvVar3 = _objc_msgSend(cls_NSImage,sel_alloc,imageForItemAt);
  pvVar3 = _objc_msgSend(pvVar3,sel_initByReferencingFile_,pvVar2);
  pvVar3 = _objc_msgSend(pvVar3,sel_autorelease);
  imageForItemAt = (int)pvVar2;
LAB_001b4a6f:
  pvVar2 = _objc_msgSend(pvVar3,sel_size,imageForItemAt);
  cVar1 = _NSEqualSizes(pvVar2,extraout_EDX,*(undefined4 *)PTR_0033607c,
                        *(undefined4 *)(PTR_0033607c + 4));
  if (cVar1 == '\0') {
    _objc_msgSend(pvVar3,sel_setCachedSeparately_,1);
  }
  else {
    pvVar3 = _objc_msgSend(self,sel_invalidPhotoImage);
  }
  return pvVar3;
}

*/
- (id)gridControl:(id)aControl imageForItemAt:(NSInteger)aAt
{
    id path = [[[[self filteredPhotosForAlbum:[self currentSelectedAlbum]] objectAtIndex:aAt] URL] path];
    NSImage *image = nil;
    if ([_imageGrid mode] == 0) {
        image = [[HSThumbnailManager sharedThumbnailManager] thumbnailForPath:path];
    }
    if (image == nil) {
        image = [[[NSImage alloc] initByReferencingFile:path] autorelease];
    }
    if (NSEqualSizes([image size], NSZeroSize)) {
        return [self invalidPhotoImage];
    }
    [image setCachedSeparately:YES];
    return image;
}

- (id)gridControl:(id)aControl titleForItemAt:(NSInteger)aAt
{
    id self_00;
    NSUInteger pvVar1_2;

    self_00 = [self filteredPhotosForAlbum:[self currentSelectedAlbum]];
    if ((aAt != NSNotFound) && (pvVar1_2 = [self_00 count], aAt < (int)pvVar1_2)) {
        return [[self_00 objectAtIndex:aAt] displayName];
    }
    return nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b4b77 @ 001b4b77, 255 bytes * /

int FUN_001b4b77(HSImportDialogGraphicsiPhotoPaneViewController *self,SEL _cmd,
                id numberOfItemsInGridControl)

{
  undefined *self_00;
  undefined *self_01;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar1 = _objc_msgSend(self,sel_currentSelectedAlbum);
  pvVar1 = _objc_msgSend(self,sel_filteredPhotosForAlbum_,pvVar1);
  pvVar2 = _objc_msgSend(pvVar1,sel_count);
  self_01 = cls_NSString;
  self_00 = cls_NSBundle;
  pvVar1 = (self->super)._itemsCountTextField;
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
    NSUInteger count = [[self filteredPhotosForAlbum:[self currentSelectedAlbum]] count];
    [_itemsCountTextField setStringValue:[NSString stringWithFormat:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"%dItems" value:@"" table:@"ImportDialogs"], count]];
    return count;
}

- (void)reloadMediaPaths
{
    [_imageGrid reloadData];
    if (_selectedPhotoIndex < [_imageGrid count]) {
        [_imageGrid selectItemAtIndex:_selectedPhotoIndex byExtendingSelection:NO];
    }
    [self selectionDidChangeInGridControl:_imageGrid];
}

- (void)selectionDidChangeInGridControl:(id)aControl
{
    [super selectionDidChangeInGridControl:aControl]
    ;
    _selectedPhotoIndex = (unsigned int)[aControl selectedItemIndex];
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
    id pvVar1_3;
    BOOL pvVar2_3;

    if ([_browseOutlineView autosaveExpandedItems]) {
        pvVar1_2 = _browseOutlineView;
        pvVar1_3 = [pvVar1_2 itemAtRow:[pvVar1_2 selectedRow]];
        pvVar2_3 = [pvVar1_3 isKindOfClass:[HSGraphicsLibraryiPhotoAlbum class]];
        if (((pvVar1_3 != nil) && (pvVar2_3)) && (pvVar1_3 != _selectedAlbum)) {
            _selectedAlbum = pvVar1_3;
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
/* FUN_001b4f25 @ 001b4f25, 135 bytes * /

id FUN_001b4f25(HSImportDialogGraphicsiPhotoPaneViewController *self,SEL _cmd,id outlineView,
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
/* FUN_001b4fe5 @ 001b4fe5, 77 bytes * /

int FUN_001b4fe5(HSImportDialogGraphicsiPhotoPaneViewController *self,SEL _cmd,id outlineView,
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

- (void)invalidateMediaPaths
{
    [_filteredPhotosHashLock lock];
    [_filteredPhotosHash release];
    _filteredPhotosHash = nil;
    [_filteredPhotosHashLock unlock];
    [self reloadMediaPaths];
}

- (id)filteredPhotosForAlbum:(id)aAlbum
{
    [_filteredPhotosHashLock lock];
    if (_filteredPhotosHash == nil) {
        _filteredPhotosHash = [[aAlbum filterPhotos:[_searchField stringValue] byCategory:@""] copy];
    }
    [_filteredPhotosHashLock unlock];
    return _filteredPhotosHash;
}

- (id)currentSelectedAlbum
{
    return _selectedAlbum;
}

- (id)currentSelectedPhoto
{
    id self_00;
    NSUInteger pvVar2;
    NSUInteger pvVar1_2;

    self_00 = [self filteredPhotosForAlbum:[self currentSelectedAlbum]];
    pvVar2 = [_imageGrid selectedItemIndex];
    if ((pvVar2 != NSNotFound) && (pvVar1_2 = [self_00 count], pvVar2 < pvVar1_2)) {
        return [self_00 objectAtIndex:pvVar2];
    }
    return nil;
}

- (void)applicationDidBecomeActive:(id)aActive
{
    if ([[[self paneView] window] isVisible]) {
        if ([[self paneView] superview] != nil) {
            [self iPhotoLibraryMightDidChange];
        }
    }
}

- (void)willMountToDialogController:(id)aController
{
    [super willMountToDialogController:aController];
    if (!_iPhotoDBWasNotFoundAlertWasShown && [HSGraphicsLibraryiPhotoHelper iPhotoRecentDatabasesWasNotFound]) {
        HSAlert *alert = [HSAlert new];
        [alert setAlertStyle:NSAlertStyleWarning];
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        [alert setMessageText:[bundle localizedStringForKey:@"Cannot open iPhoto library alert message text" value:@"" table:@"ImportDialogs"]];
        [alert setInformativeText:[bundle localizedStringForKey:@"Cannot open iPhoto library alert informative text" value:@"" table:@"ImportDialogs"]];
        [alert runModal];
        [alert release];
        _iPhotoDBWasNotFoundAlertWasShown = YES;
    }
}

- (void)paneDialogWillOpen
{
    [super paneDialogWillOpen];
    if ([_paneView superview] != nil) {
        [self iPhotoLibraryMightDidChange];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:NSApplicationDidBecomeActiveNotification object:NSApp];
}

- (void)paneDialogWillClose
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidBecomeActiveNotification object:0];
    [super paneDialogWillClose];
}

- (id)paneFileDisplayName
{
    return [[self currentSelectedPhoto] displayName];
}

- (id)paneFilePath
{
    return [[[self currentSelectedPhoto] URL] path];
}

- (id)paneTitle
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"ImportDialogGraphicsiPhotoPaneTitle" value:@"" table:@"ImportDialogs"];
}

- (id)paneViewNibName
{
    return @"IDGraphicsiPhotoPaneView";
}

- (NSInteger)paneWeight
{
    return 1;
}

- (id)paneIdentifier
{
    return @"HSImportDialogiPhotoGraphics";
}

- (id)invalidPhotoImage
{
    id pvVar1;
    id pvVar1_3;

    pvVar1 = _invalidPhotoImage;
    if (pvVar1 == nil) {
        pvVar1_3 = [[HSImagesProvider sharedImagesProvider] imageForName:@"InvalidPicturePreview" ofType:@"tiff"]
        ;
        pvVar1 = [pvVar1_3 retain];
        _invalidPhotoImage = pvVar1;
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b551b @ 001b551b, 939 bytes * /

void FUN_001b551b(HSImportDialogGraphicsiPhotoPaneViewController *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  undefined *puVar3;
  cfstringStruct *pcVar4;
  undefined4 uVar5;
  HSImportDialogGraphicsiPhotoPaneViewController *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSImportDialogGraphicsPaneViewCo_00353660;
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
  pvVar2 = _objc_msgSend(self->_browseOutlineView,sel_outlineTableColumn,puVar3);
  _objc_msgSend(pvVar2,sel_setDataCell_,pvVar1);
  _objc_msgSend(self->_browseOutlineView,sel_setAllowsMultipleSelection_,0);
  _objc_msgSend(self->_browseOutlineView,sel_setAllowsColumnSelection_,0);
  uVar5 = 0x40000000;
  _objc_msgSend(self->_browseOutlineView,sel_setIntercellSpacing_,0x3f800000,0x40000000);
  _objc_msgSend(self->_browseOutlineView,sel_setAllowsColumnReordering_,0);
  _objc_msgSend(self->_browseOutlineView,sel_setAllowsColumnResizing_,0);
  _objc_msgSend(self->_browseOutlineView,sel_setAllowsEmptySelection_,0);
  _objc_msgSend(self->_browseOutlineView,sel_setColumnAutoresizingStyle_,3);
  _objc_msgSend(self->_browseOutlineView,sel_setAutosaveExpandedItems_,1);
  _objc_msgSend(self->_browseOutlineView,sel_setDataSource_,self);
  _objc_msgSend(self->_browseOutlineView,sel_setDelegate_,self);
  pvVar1 = _objc_msgSend(cls_NSWorkspace,sel_sharedWorkspace);
  pcVar4 = &cfstr_iPhoto_app;
  pvVar1 = _objc_msgSend(pvVar1,sel_fullPathForApplication_,&cfstr_iPhoto_app);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(cls_NSWorkspace,sel_sharedWorkspace,pcVar4);
    pvVar2 = _objc_msgSend(pvVar2,sel_iconForFile_,pvVar1);
    uVar5 = 0x41800000;
    _objc_msgSend(pvVar2,sel_setSize_,0x41800000,0x41800000);
    _objc_msgSend(self->_openiPhotoButton,sel_setImage_,pvVar2);
  }
  _objc_msgSend(self->_openiPhotoButton,sel_setEnabled_,(int)(pvVar1 != (id)0x0),uVar5);
  _objc_msgSend(self->_openiPhotoButton,sel_sizeToFit);
  _objc_msgSend(self,sel_iPhotoLibraryMightDidChange);
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
    [_browseOutlineView setAutosaveExpandedItems:YES];
    [_browseOutlineView setDataSource:self];
    [_browseOutlineView setDelegate:self];
    NSString *iPhotoPath = [[NSWorkspace sharedWorkspace] fullPathForApplication:@"iPhoto.app"];
    if (iPhotoPath != nil) {
        NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:iPhotoPath];
        [icon setSize:NSMakeSize(16.0f, 16.0f)];
        [_openiPhotoButton setImage:icon];
    }
    [_openiPhotoButton setEnabled:(iPhotoPath != nil)];
    [_openiPhotoButton sizeToFit];
    [self iPhotoLibraryMightDidChange];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b58c6 @ 001b58c6, 387 bytes * /

void FUN_001b58c6(HSImportDialogGraphicsiPhotoPaneViewController *self,SEL _cmd)

{
  id self_00;
  HSImportDialogGraphicsiPhotoPaneViewController *pHVar1;
  HSImportDialogGraphicsiPhotoPaneViewController *pHVar2;
  undefined4 uVar3;
  undefined4 uVar4;
  HSImportDialogGraphicsiPhotoPaneViewController *local_14;
  undefined *local_10;
  
  self_00 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  uVar3 = *(undefined4 *)PTR_00336060;
  uVar4 = 0;
  pHVar2 = self;
  _objc_msgSend(self_00,sel_removeObserver_name_object_,self,uVar3,0);
  pHVar1 = _objc_msgSend(self->_browseOutlineView,sel_delegate);
  if (pHVar1 == self) {
    pHVar2 = (HSImportDialogGraphicsiPhotoPaneViewController *)0x0;
    _objc_msgSend(self->_browseOutlineView,sel_setDelegate_,0,uVar3,uVar4);
  }
  pHVar1 = _objc_msgSend(self->_browseOutlineView,sel_dataSource,pHVar2,uVar3,uVar4);
  if (pHVar1 == self) {
    pHVar2 = (HSImportDialogGraphicsiPhotoPaneViewController *)0x0;
    _objc_msgSend(self->_browseOutlineView,sel_setDataSource_,0,uVar3,uVar4);
  }
  _objc_msgSend(self->_lineBreakInfo,sel_release,pHVar2);
  _objc_msgSend(self->_rootOutlineItems,sel_release);
  _objc_msgSend(self->_invalidPhotoImage,sel_release);
  _objc_msgSend(self->_mediaDataProvider,sel_release);
  _objc_msgSend(self->_filteredPhotosHash,sel_release);
  _objc_msgSend(self->_filteredPhotosHashLock,sel_release);
  local_14 = self;
  local_10 = PTR_s_HSImportDialogGraphicsPaneViewCo_00353660;
  _objc_msgSendSuper(&local_14,sel_dealloc);
  return;
}

*/
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidBecomeActiveNotification object:nil];
    if ([_browseOutlineView delegate] == self) {
        [_browseOutlineView setDelegate:nil];
    }
    if ([_browseOutlineView dataSource] == self) {
        [_browseOutlineView setDataSource:nil];
    }
    [_lineBreakInfo release];
    [_rootOutlineItems release];
    [_invalidPhotoImage release];
    [_mediaDataProvider release];
    [_filteredPhotosHash release];
    [_filteredPhotosHashLock release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _filteredPhotosHashLock = [[NSRecursiveLock allocWithZone:[self zone]] init];
    }
    return self;
}

@end

