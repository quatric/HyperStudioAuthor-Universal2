#import "HSImportDialogGraphicsImportedPaneViewController.h"

@implementation HSImportDialogGraphicsImportedPaneViewController

/* i386 ivar offsets: _browseTableViewDataSource=0x98, _concreteMediaTypesDictionary=0x9c, _predefinedImageLocations=0xa0, _primaryHistory=0xa4, _secondaryHistory=0xa8, _switchingHistory=0xac */

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b3624 @ 001b3624, 232 bytes * /

void FUN_001b3624(id self,SEL _cmd)

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

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b3563 @ 001b3563, 193 bytes * /

void FUN_001b3563(HSImportDialogGraphicsImportedPaneViewController *self,SEL _cmd)

{
  id self_00;
  id pvVar1;
  
  self_00 = _objc_msgSend((self->super)._historyNavigationControl,sel_cell);
  pvVar1 = _objc_msgSend(self,sel_primaryHistory);
  pvVar1 = _objc_msgSend(pvVar1,sel_count);
  _objc_msgSend(self_00,sel_setEnabled_forSegment_,(uint)((id)0x1 < pvVar1),0);
  pvVar1 = _objc_msgSend(self,sel_secondaryHistory);
  pvVar1 = _objc_msgSend(pvVar1,sel_count);
  _objc_msgSend(self_00,sel_setEnabled_forSegment_,(int)(char)pvVar1,1);
  return;
}

*/
- (void)validateHistoryNavigationControl
{
    id cell = [_historyNavigationControl cell];
    [cell setEnabled:([[self primaryHistory] count] > 1) forSegment:0];
    [cell setEnabled:(char)[[self secondaryHistory] count] forSegment:1];
}

- (void)fileOrFolderStructureMightDidChange
{
    NSUInteger pvVar1;

    pvVar1 = [_imageGrid selectedItemIndex];
    [self invalidateMediaPaths];
    [_imageGrid selectItemAtIndex:pvVar1 byExtendingSelection:NO];
    [self validateRunCropImageButton];
}

- (id)tableViewDataSource
{
    id pvVar2;
    id pvVar3;
    HSImportDialogImportedPaneBrowseController *pHVar5;
    HSImportDialogImportedPaneBrowseController *pHVar5_2;
    id pvVar1_2;

    pHVar5 = _browseTableViewDataSource;
    if (pHVar5 == nil) {
        pvVar1_2 = [HSImportDialogImportedPaneBrowseController allocWithZone:[self zone]];
        pvVar2 = [NSImage imageUnfilteredFileTypes];
        pvVar3 = [self customImageLocationsDefaultsKey];
        pHVar5_2 = [pvVar1_2 initWithPredefinedLocations:[self predefinedImageLocations] userLocationsDefaultsKey:pvVar3 fileTypes:pvVar2];
        _browseTableViewDataSource = pHVar5_2;
        [pHVar5_2 setDelegate:self];
        pHVar5 = _browseTableViewDataSource;
    }
    return pHVar5;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b389d @ 001b389d, 646 bytes * /

id FUN_001b389d(HSImportDialogGraphicsImportedPaneViewController *self,SEL _cmd)

{
  int iVar1;
  id self_00;
  undefined *puVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  undefined4 *puVar7;
  cfstringStruct *pcVar8;
  undefined1 *puVar9;
  undefined4 uVar10;
  id local_78;
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined1 local_50 [64];
  
  puVar2 = cls_NSArray;
  pvVar3 = self->_predefinedImageLocations;
  if (pvVar3 == (id)0x0) {
    pvVar3 = _objc_msgSend(self,sel_zone);
    pvVar3 = _objc_msgSend(puVar2,sel_allocWithZone_,pvVar3);
    puVar2 = cls_NSBundle;
    pvVar4 = _objc_msgSend(self,sel_class);
    pvVar4 = _objc_msgSend(puVar2,sel_bundleForClass_,pvVar4);
    pcVar8 = &cfstr_plist;
    pvVar4 = _objc_msgSend(pvVar4,sel_pathForResource_ofType_,&cfstr_GraphicsImportedLocations,
                           &cfstr_plist);
    pvVar3 = _objc_msgSend(pvVar3,sel_initWithContentsOfFile_,pvVar4);
    self->_predefinedImageLocations = pvVar3;
    pvVar3 = _objc_msgSend(cls_HSSystem,sel_sharedSystem);
    pvVar3 = _objc_msgSend(pvVar3,sel_isSandboxed);
    if ((char)pvVar3 == '\0') {
      pvVar3 = self->_predefinedImageLocations;
    }
    else {
      pvVar3 = _objc_msgSend(cls_NSMutableArray,sel_new,pvVar4,pcVar8);
      local_74 = 0;
      local_70 = 0;
      local_6c = (int *)0x0;
      local_68 = 0;
      local_64 = 0;
      local_60 = 0;
      local_5c = 0;
      local_58 = 0;
      pvVar4 = self->_predefinedImageLocations;
      puVar9 = local_50;
      puVar7 = &local_74;
      uVar10 = 0x10;
      local_78 = _objc_msgSend(pvVar4,sel_countByEnumeratingWithState_objects_count_,puVar7,puVar9,
                               0x10);
      if (local_78 != (id)0x0) {
        iVar1 = *local_6c;
        do {
          pvVar6 = (id)0x0;
          do {
            if (iVar1 != *local_6c) {
              _objc_enumerationMutation(self->_predefinedImageLocations);
            }
            self_00 = *(id *)(local_70 + (int)pvVar6 * 4);
            pvVar5 = _objc_msgSend(self_00,sel_isEqualToString_,&cfstr___Desktop,puVar9,uVar10);
            if ((char)pvVar5 == '\0') {
              pvVar5 = _objc_msgSend(self_00,sel_isEqualToString_,&cfstr___Documents);
              if ((char)pvVar5 == '\0') {
                _objc_msgSend(pvVar3,sel_addObject_,self_00);
              }
            }
            pvVar6 = (id)((int)pvVar6 + 1);
          } while (pvVar6 < local_78);
          puVar9 = local_50;
          puVar7 = &local_74;
          uVar10 = 0x10;
          local_78 = _objc_msgSend(pvVar4,sel_countByEnumeratingWithState_objects_count_,puVar7,
                                   puVar9,0x10);
        } while (local_78 != (id)0x0);
      }
      _objc_msgSend(self->_predefinedImageLocations,sel_release,puVar7,puVar9,uVar10);
      self->_predefinedImageLocations = pvVar3;
    }
  }
  return pvVar3;
}

*/
- (id)predefinedImageLocations
{
    if (_predefinedImageLocations == nil) {
        _predefinedImageLocations = [[NSArray allocWithZone:[self zone]] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"GraphicsImportedLocations" ofType:@"plist"]];
        if ([[HSSystem sharedSystem] isSandboxed]) {
            NSMutableArray *locations = [NSMutableArray new];
            for (id location in _predefinedImageLocations) {
                if (![location isEqualToString:@"~/Desktop"] && ![location isEqualToString:@"~/Documents"]) {
                    [locations addObject:location];
                }
            }
            [_predefinedImageLocations release];
            _predefinedImageLocations = locations;
        }
    }
    return _predefinedImageLocations;
}

- (id)customImageLocationsDefaultsKey
{
    return @"HSImportDialogGraphicsImportedPaneCustomImageLocations";
}

- (id)concreteMediaTypesDictionary
{
    id pvVar2;

    pvVar2 = _concreteMediaTypesDictionary;
    if (pvVar2 == nil) {
        pvVar2 = [[NSDictionary allocWithZone:[self zone]] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"ImportedMediaTypes" ofType:@"plist"]];
        _concreteMediaTypesDictionary = pvVar2;
    }
    return pvVar2;
}

- (id)gridControl:(id)aControl titleForItemAt:(NSInteger)aAt
{
    id pvVar1_3;

    pvVar1_3 = [[self filteredMediaPathsForKey:[self currentMediaPathsLocation]] objectAtIndex:aAt];
    return [[NSFileManager defaultManager] displayNameAtPath:pvVar1_3];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b3b23 @ 001b3b23, 922 bytes * /

BOOL FUN_001b3b23(HSImportDialogGraphicsImportedPaneViewController *self,SEL _cmd,
                 id mediaPathConformsToFilter)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  cfstringStruct *pcVar5;
  char *pcVar6;
  BOOL local_1e;
  char local_1d;
  HSImportDialogGraphicsImportedPaneViewController *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSImportDialogGraphicsPaneViewCo_00353630;
  pvVar1 = _objc_msgSendSuper(&local_1c,sel_mediaPathConformsToFilter_,mediaPathConformsToFilter);
  local_1e = '\0';
  if ((char)pvVar1 != '\0') {
    pvVar2 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
    local_1d = '\0';
    pcVar6 = &local_1d;
    pvVar3 = mediaPathConformsToFilter;
    _objc_msgSend(pvVar2,sel_fileExistsAtPath_isDirectory_,mediaPathConformsToFilter,pcVar6);
    if (local_1d == '\0') {
      pvVar3 = _objc_msgSend(self,sel_concreteMediaTypesDictionary,pvVar3,pcVar6);
      pvVar2 = _objc_msgSend(pvVar2,sel_hyperFileTypeAtPath_,mediaPathConformsToFilter);
      pvVar3 = _objc_msgSend(pvVar3,sel_objectForKey_,pvVar2);
      pvVar4 = _objc_msgSend((self->super)._itemsFilterPopUp,sel_selectedItem);
      pvVar4 = _objc_msgSend(pvVar4,sel_tag);
      if (pvVar4 == (id)0x7d1) {
        pcVar5 = &cfstr_BMPImage;
      }
      else {
        pvVar2 = _objc_msgSend((self->super)._itemsFilterPopUp,sel_selectedItem,pvVar2);
        pvVar2 = _objc_msgSend(pvVar2,sel_tag);
        if (pvVar2 == (id)0x7d2) {
          pcVar5 = &cfstr_JPEGImage;
        }
        else {
          pvVar2 = _objc_msgSend((self->super)._itemsFilterPopUp,sel_selectedItem);
          pvVar2 = _objc_msgSend(pvVar2,sel_tag);
          if (pvVar2 == (id)0x7d3) {
            pcVar5 = &cfstr_PDFImage;
          }
          else {
            pvVar2 = _objc_msgSend((self->super)._itemsFilterPopUp,sel_selectedItem);
            pvVar2 = _objc_msgSend(pvVar2,sel_tag);
            if (pvVar2 == (id)0x7d4) {
              pcVar5 = &cfstr_TIFFImage;
            }
            else {
              pvVar2 = _objc_msgSend((self->super)._itemsFilterPopUp,sel_selectedItem);
              pvVar2 = _objc_msgSend(pvVar2,sel_tag);
              if (pvVar2 == (id)0x7d5) {
                pcVar5 = &cfstr_GIFImage;
              }
              else {
                pvVar2 = _objc_msgSend((self->super)._itemsFilterPopUp,sel_selectedItem);
                pvVar2 = _objc_msgSend(pvVar2,sel_tag);
                if (pvVar2 == (id)0x7d6) {
                  pcVar5 = &cfstr_PSDImage;
                }
                else {
                  pvVar2 = _objc_msgSend((self->super)._itemsFilterPopUp,sel_selectedItem);
                  pvVar2 = _objc_msgSend(pvVar2,sel_tag);
                  if (pvVar2 == (id)0x7d7) {
                    pcVar5 = &cfstr_PICTImage;
                  }
                  else {
                    pvVar2 = _objc_msgSend((self->super)._itemsFilterPopUp,sel_selectedItem);
                    pvVar2 = _objc_msgSend(pvVar2,sel_tag);
                    if (pvVar2 == (id)0x7d8) {
                      pcVar5 = &cfstr_PNGImage;
                    }
                    else {
                      pvVar2 = _objc_msgSend((self->super)._itemsFilterPopUp,sel_selectedItem);
                      pvVar2 = _objc_msgSend(pvVar2,sel_tag);
                      if (pvVar2 != (id)0x7d9) {
                        pvVar2 = _objc_msgSend((self->super)._itemsFilterPopUp,sel_selectedItem);
                        pvVar2 = _objc_msgSend(pvVar2,sel_tag);
                        if (pvVar2 != (id)0x7da) {
                          return (char)pvVar1;
                        }
                        pvVar1 = _objc_msgSend(pvVar3,sel_isEqualToString_,&cfstr_EPSImage);
                        return (BOOL)pvVar1;
                      }
                      pcVar5 = &cfstr_ICONImage;
                    }
                  }
                }
              }
            }
          }
        }
      }
      pvVar1 = _objc_msgSend(pvVar3,sel_isEqualToString_,pcVar5);
      local_1e = (BOOL)pvVar1;
    }
    else {
      local_1e = '\0';
    }
  }
  return local_1e;
}

*/
- (BOOL)mediaPathConformsToFilter:(id)aFilter
{
    BOOL conforms = [super mediaPathConformsToFilter:aFilter];
    BOOL result = NO;
    if (conforms) {
        BOOL isDirectory = NO;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager fileExistsAtPath:aFilter isDirectory:&isDirectory];
        if (!isDirectory) {
            id type = [[self concreteMediaTypesDictionary] objectForKey:[fileManager hyperFileTypeAtPath:aFilter]];
            NSString *expected = nil;
            switch ([[_itemsFilterPopUp selectedItem] tag]) {
                case 0x7d1: expected = @"BMPImage"; break;
                case 0x7d2: expected = @"JPEGImage"; break;
                case 0x7d3: expected = @"PDFImage"; break;
                case 0x7d4: expected = @"TIFFImage"; break;
                case 0x7d5: expected = @"GIFImage"; break;
                case 0x7d6: expected = @"PSDImage"; break;
                case 0x7d7: expected = @"PICTImage"; break;
                case 0x7d8: expected = @"PNGImage"; break;
                case 0x7d9: expected = @"ICONImage"; break;
                case 0x7da: expected = @"EPSImage"; break;
                default: return conforms;
            }
            result = [type isEqualToString:expected];
        }
    }
    return result;
}

- (id)currentMediaPathsLocation
{
    return [[self tableViewDataSource] currentPathForTableView:_browseTableView];
}

- (void)tvDataSourceSelectionDidChange:(id)aChange
{
    id self_00;
    id pvVar1;

    [self invalidateMediaPaths];
    if (_switchingHistory == NO) {
        self_00 = [self primaryHistory];
        pvVar1 = [self currentMediaPathsLocation];
        if (![[self_00 lastObject] isEqualToString:pvVar1]) {
            [self_00 addObject:pvVar1];
            [_secondaryHistory release];
            _secondaryHistory = nil;
            [self validateHistoryNavigationControl];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b2f46 @ 001b2f46, 581 bytes * /

id FUN_001b2f46(HSImportDialogGraphicsImportedPaneViewController *self,SEL _cmd,
               id createMediaPathsForKey)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id self_01;
  id pvVar3;
  id self_02;
  id pvVar4;
  undefined4 local_1c;
  
  pvVar1 = _objc_msgSend(cls_NSString,sel_class);
  pvVar2 = _objc_msgSend(createMediaPathsForKey,sel_isKindOfClass_,pvVar1);
  if (((char)pvVar2 == '\0') || (createMediaPathsForKey == (id)0x0)) {
    local_1c = (id)0x0;
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_supportedMediaTypes,pvVar1);
    self_01 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
    pvVar1 = createMediaPathsForKey;
    pvVar3 = _objc_msgSend(self_01,sel_directoryContentsAtPath_,createMediaPathsForKey);
    local_1c = (id)0x0;
    pvVar3 = _objc_msgSend(pvVar3,sel_objectEnumerator);
    while( true ) {
      pvVar1 = _objc_msgSend(pvVar3,sel_nextObject,pvVar1);
      if (pvVar1 == (id)0x0) break;
      pvVar1 = _objc_msgSend(createMediaPathsForKey,sel_stringByAppendingPathComponent_,pvVar1);
      self_02 = _objc_msgSend(pvVar1,sel_stringByResolvingSymlinksInPath);
      pvVar1 = self_02;
      pvVar4 = _objc_msgSend(self_01,sel_isHyperAliasAtPath_,self_02);
      if ((char)pvVar4 != '\0') {
        pvVar1 = self_02;
        self_02 = _objc_msgSend(self_01,sel_hyperResolveAliasAtPath_,self_02);
      }
      if (self_02 != (id)0x0) {
        pvVar4 = _objc_msgSend(self_02,sel_length,pvVar1);
        if (pvVar4 != (id)0x0) {
          pvVar1 = _objc_msgSend(self_01,sel_hyperFileTypeAtPath_,self_02);
          pvVar4 = _objc_msgSend(pvVar2,sel_containsObject_,pvVar1);
          if ((char)pvVar4 != '\0') {
            pvVar1 = self_02;
            pvVar4 = _objc_msgSend(self_01,sel_hyperIsFileInvisibleAtPath_,self_02);
            self_00 = cls_NSMutableArray;
            if ((char)pvVar4 == '\0') {
              if (local_1c == (id)0x0) {
                pvVar1 = _objc_msgSend(self,sel_zone,pvVar1);
                pvVar1 = _objc_msgSend(self_00,sel_allocWithZone_,pvVar1);
                pvVar1 = _objc_msgSend(pvVar1,sel_initWithCapacity_,0);
                local_1c = _objc_msgSend(pvVar1,sel_autorelease);
              }
              _objc_msgSend(local_1c,sel_addObject_,self_02);
              pvVar1 = self_02;
            }
          }
        }
      }
    }
  }
  return local_1c;
}

*/
- (id)createMediaPathsForKey:(id)aKey
{
    NSMutableArray *paths = nil;
    if ([aKey isKindOfClass:[NSString class]] && aKey != nil) {
        id supportedTypes = [self supportedMediaTypes];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSEnumerator *enumerator = [[fileManager directoryContentsAtPath:aKey] objectEnumerator];
        id name;
        while ((name = [enumerator nextObject]) != nil) {
            id path = [[aKey stringByAppendingPathComponent:name] stringByResolvingSymlinksInPath];
            if ([fileManager isHyperAliasAtPath:path]) {
                path = [fileManager hyperResolveAliasAtPath:path];
            }
            if (path != nil && [path length] != 0
                && [supportedTypes containsObject:[fileManager hyperFileTypeAtPath:path]]
                && ![fileManager hyperIsFileInvisibleAtPath:path]) {
                if (paths == nil) {
                    paths = [[[NSMutableArray allocWithZone:[self zone]] initWithCapacity:0] autorelease];
                }
                [paths addObject:path];
            }
        }
    }
    return paths;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b3ebd @ 001b3ebd, 336 bytes * /

void FUN_001b3ebd(HSImportDialogGraphicsImportedPaneViewController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  HSImportDialogGraphicsImportedPaneViewController *local_1c;
  undefined *local_18;
  
  pvVar1 = _objc_msgSend(self,sel_currentMediaPathsLocation);
  if (pvVar1 != (id)0x0) {
    _objc_msgSend((self->super).super._mediaPathDictionary,sel_removeObjectForKey_,pvVar1);
  }
  local_1c = self;
  local_18 = PTR_s_HSImportDialogGraphicsPaneViewCo_00353630;
  _objc_msgSendSuper(&local_1c,sel_reloadMediaPaths);
  pvVar1 = _objc_msgSend(self,sel_tableViewDataSource);
  pvVar1 = _objc_msgSend(pvVar1,sel_currentFilenameForSelection);
  if (pvVar1 != (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_currentMediaPathsLocation);
    pvVar1 = _objc_msgSend(self,sel_filteredMediaPathsForKey_,pvVar1);
    pvVar2 = _objc_msgSend(self,sel_currentMediaPathsLocation);
    pvVar3 = _objc_msgSend(self,sel_tableViewDataSource);
    pvVar3 = _objc_msgSend(pvVar3,sel_currentFilenameForSelection);
    pvVar2 = _objc_msgSend(pvVar2,sel_stringByAppendingPathComponent_,pvVar3);
    pvVar1 = _objc_msgSend(pvVar1,sel_indexOfObject_,pvVar2);
    if (pvVar1 != (id)0x7fffffff) {
      _objc_msgSend((self->super)._imageGrid,sel_selectItemAtIndex_byExtendingSelection_,pvVar1,0);
    }
  }
  return;
}

*/
- (void)reloadMediaPaths
{
    id location = [self currentMediaPathsLocation];
    if (location != nil) {
        [_mediaPathDictionary removeObjectForKey:location];
    }
    [super reloadMediaPaths];
    id filename = [[self tableViewDataSource] currentFilenameForSelection];
    if (filename != nil) {
        id filtered = [self filteredMediaPathsForKey:[self currentMediaPathsLocation]];
        NSUInteger index = [filtered indexOfObject:[[self currentMediaPathsLocation] stringByAppendingPathComponent:[[self tableViewDataSource] currentFilenameForSelection]]];
        if (index != NSNotFound) {
            [_imageGrid selectItemAtIndex:index byExtendingSelection:NO];
        }
    }
}

- (void)applicationDidBecomeActive:(id)aActive
{
    if ([[[self paneView] window] isVisible]) {
        if ([[self paneView] superview] != nil) {
            [self fileOrFolderStructureMightDidChange];
        }
    }
}

- (void)paneDialogWillOpen
{
    [super paneDialogWillOpen];
    if ([_paneView superview] != nil) {
        [self fileOrFolderStructureMightDidChange];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:NSApplicationDidBecomeActiveNotification object:NSApp];
}

- (void)paneDialogWillClose
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidBecomeActiveNotification object:0];
    [super paneDialogWillClose];
}

- (id)paneTitle
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"ImportDialogGraphicsImportedPaneTitle" value:@"" table:@"ImportDialogs"];
}

- (NSInteger)paneWeight
{
    return 2;
}

- (id)paneIdentifier
{
    return @"HSImportDialogImportedGraphics";
}

- (id)secondaryHistory
{
    id pvVar1;

    pvVar1 = _secondaryHistory;
    if (pvVar1 == nil) {
        pvVar1 = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:0];
        _secondaryHistory = pvVar1;
    }
    return pvVar1;
}

- (id)primaryHistory
{
    id pvVar1;

    pvVar1 = _primaryHistory;
    if (pvVar1 == nil) {
        _primaryHistory = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:0];
        [_primaryHistory addObject:[[self tableViewDataSource] currentPathForTableView:_browseTableView]];
        pvVar1 = _primaryHistory;
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b2c9f @ 001b2c9f, 112 bytes * /

void FUN_001b2c9f(HSImportDialogGraphicsImportedPaneViewController *self,SEL _cmd,id switchHistoryTo
                 )

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(switchHistoryTo,sel_selectedSegment);
  self->_switchingHistory = '\x01';
  op = sel_switchHistoryForward;
  if ((pvVar1 == (id)0x1) || (op = sel_switchHistoryBack, pvVar1 == (id)0x0)) {
    _objc_msgSend(self,op);
  }
  self->_switchingHistory = '\0';
  _objc_msgSend(self,sel_validateHistoryNavigationControl);
  return;
}

*/
- (void)switchHistoryTo:(id)aTo
{
    NSInteger segment = [aTo selectedSegment];
    _switchingHistory = YES;
    if (segment == 1) {
        [self switchHistoryForward];
    } else if (segment == 0) {
        [self switchHistoryBack];
    }
    _switchingHistory = NO;
    [self validateHistoryNavigationControl];
}

- (void)switchHistoryForward
{
    id pvVar1;
    id pvVar2;
    id pvVar2_2;
    id pvVar3_2;

    pvVar1 = [self primaryHistory];
    pvVar2 = [self secondaryHistory];
    [pvVar1 addObject:[pvVar2 lastObject]];
    [pvVar2 removeLastObject];
    pvVar3_2 = [self tableViewDataSource];
    pvVar2_2 = _browseTableView;
    [pvVar3_2 setCurrentPath:[pvVar1 lastObject] forTableView:pvVar2_2];
}

- (void)switchHistoryBack
{
    id pvVar1;
    id pvVar2_2;
    id pvVar3_2;

    pvVar1 = [self primaryHistory];
    [[self secondaryHistory] addObject:[pvVar1 lastObject]];
    [pvVar1 removeLastObject];
    pvVar3_2 = [self tableViewDataSource];
    pvVar2_2 = _browseTableView;
    [pvVar3_2 setCurrentPath:[pvVar1 lastObject] forTableView:pvVar2_2];
}

- (void)awakeFromNib
{
    id pvVar1;

    [super awakeFromNib];
    pvVar1 = [self tableViewDataSource];
    [pvVar1 configureTableView:_browseTableView];
    [_browseTableView setDataSource:pvVar1];
    [_browseTableView setDelegate:pvVar1];
    [_browseTableView registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
    [self tvDataSourceSelectionDidChange:nil];
    [self validateHistoryNavigationControl];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b370c @ 001b370c, 401 bytes * /

void FUN_001b370c(HSImportDialogGraphicsImportedPaneViewController *self,SEL _cmd)

{
  id self_00;
  HSImportDialogGraphicsImportedPaneViewController *pHVar1;
  HSImportDialogImportedPaneBrowseController *pHVar2;
  HSImportDialogImportedPaneBrowseController *pHVar3;
  HSImportDialogGraphicsImportedPaneViewController *pHVar4;
  HSImportDialogGraphicsImportedPaneViewController *local_14;
  undefined *local_10;
  
  self_00 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  pHVar4 = self;
  _objc_msgSend(self_00,sel_removeObserver_,self);
  pHVar1 = _objc_msgSend(self->_browseTableViewDataSource,sel_delegate);
  if (pHVar1 == self) {
    pHVar4 = (HSImportDialogGraphicsImportedPaneViewController *)0x0;
    _objc_msgSend(self->_browseTableViewDataSource,sel_setDelegate_,0);
  }
  pHVar2 = _objc_msgSend((self->super)._browseTableView,sel_delegate,pHVar4);
  if (pHVar2 == self->_browseTableViewDataSource) {
    pHVar4 = (HSImportDialogGraphicsImportedPaneViewController *)0x0;
    _objc_msgSend((self->super)._browseTableView,sel_setDelegate_,0);
  }
  pHVar3 = _objc_msgSend((self->super)._browseTableView,sel_dataSource,pHVar4);
  pHVar2 = self->_browseTableViewDataSource;
  if (pHVar3 == pHVar2) {
    pHVar4 = (HSImportDialogGraphicsImportedPaneViewController *)0x0;
    _objc_msgSend((self->super)._browseTableView,sel_setDataSource_,0);
    pHVar2 = self->_browseTableViewDataSource;
  }
  _objc_msgSend(pHVar2,sel_release,pHVar4);
  _objc_msgSend(self->_concreteMediaTypesDictionary,sel_release);
  _objc_msgSend(self->_predefinedImageLocations,sel_release);
  _objc_msgSend(self->_primaryHistory,sel_release);
  _objc_msgSend(self->_secondaryHistory,sel_release);
  local_14 = self;
  local_10 = PTR_s_HSImportDialogGraphicsPaneViewCo_00353630;
  _objc_msgSendSuper(&local_14,sel_dealloc);
  return;
}

*/
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ([_browseTableViewDataSource delegate] == self) {
        [_browseTableViewDataSource setDelegate:nil];
    }
    if ([_browseTableView delegate] == _browseTableViewDataSource) {
        [_browseTableView setDelegate:nil];
    }
    if ([_browseTableView dataSource] == _browseTableViewDataSource) {
        [_browseTableView setDataSource:nil];
    }
    [_browseTableViewDataSource release];
    [_concreteMediaTypesDictionary release];
    [_predefinedImageLocations release];
    [_primaryHistory release];
    [_secondaryHistory release];
    [super dealloc];
}

@end

