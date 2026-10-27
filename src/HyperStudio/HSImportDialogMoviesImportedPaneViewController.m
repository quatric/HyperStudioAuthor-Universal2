#import "HSImportDialogMoviesImportedPaneViewController.h"

@implementation HSImportDialogMoviesImportedPaneViewController

/* i386 ivar offsets: _historyNavigationControl=0xa4, _browseTableViewDataSource=0xa8, _predefinedMovieLocations=0xac, _primaryHistory=0xb0, _secondaryHistory=0xb4, _switchingHistory=0xb8 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_001dae67 @ 001dae67, 152 bytes * /

void FUN_001dae67(id self,SEL _cmd)

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

- (void)applicationDidBecomeActive:(id)aActive
{
    if ([[[self paneView] window] isVisible]) {
        if ([[self paneView] superview] != nil) {
            [self moviesMightDidChange];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001daf8b @ 001daf8b, 196 bytes * /

void FUN_001daf8b(HSImportDialogMoviesImportedPaneViewController *self,SEL _cmd)

{
  id self_00;
  id pvVar1;
  
  self_00 = _objc_msgSend(self->_historyNavigationControl,sel_cell);
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

- (id)gridControl:(id)aControl titleForItemAt:(NSInteger)aAt
{
    id pvVar1_3;

    pvVar1_3 = [[self filteredMediaPathsForKey:[self currentMediaPathsLocation]] objectAtIndex:aAt];
    return [[NSFileManager defaultManager] displayNameAtPath:pvVar1_3];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001db0d8 @ 001db0d8, 147 bytes * /

void FUN_001db0d8(HSImportDialogMoviesImportedPaneViewController *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_currentMediaPathsLocation);
  if (pvVar1 != (id)0x0) {
    _objc_msgSend((self->super).super._mediaPathDictionary,sel_removeObjectForKey_,pvVar1);
  }
  pvVar1 = _objc_msgSend((self->super)._imageGrid,sel_selectedItem);
  _objc_msgSend(self,sel_invalidateMediaPaths);
  _objc_msgSend((self->super)._imageGrid,sel_setSelectedItem_byExtendingSelection_,pvVar1,0);
  return;
}

*/
- (void)moviesMightDidChange
{
    id location = [self currentMediaPathsLocation];
    if (location != nil) {
        [_mediaPathDictionary removeObjectForKey:location];
    }
    id selected = [_imageGrid selectedItem];
    [self invalidateMediaPaths];
    [_imageGrid setSelectedItem:selected byExtendingSelection:NO];
}

- (id)tableViewDataSource
{
    id pvVar1;
    id pvVar3;
    id pvVar1_3;
    NSArray *pvVar1_4;
    id pvVar1_5;
    id pvVar2_2;

    pvVar1 = _browseTableViewDataSource;
    if (pvVar1 == nil) {
        if (![self respondsToSelector:@selector(concreteMediaTypesDictionary)]) {
            pvVar1_3 = nil;
        }
        else {
            pvVar1_3 = [self performSelector:@selector(concreteMediaTypesDictionary)];
        }
        pvVar2_2 = [HSImportDialogImportedPaneBrowseController allocWithZone:[self zone]];
        pvVar1_4 = [pvVar1_3 allKeys];
        pvVar3 = [self customImageLocationsDefaultsKey];
        pvVar1_5 = [pvVar2_2 initWithPredefinedLocations:[self predefinedMovieLocations] userLocationsDefaultsKey:pvVar3 fileTypes:pvVar1_4];
        _browseTableViewDataSource = pvVar1_5;
        [pvVar1_5 setDelegate:self];
        pvVar1 = _browseTableViewDataSource;
    }
    return pvVar1;
}

- (id)customImageLocationsDefaultsKey
{
    return @"HSImportDialogMoviesImportedPaneCustomImageLocations";
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001db298 @ 001db298, 646 bytes * /

id FUN_001db298(HSImportDialogMoviesImportedPaneViewController *self,SEL _cmd)

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
  pvVar3 = self->_predefinedMovieLocations;
  if (pvVar3 == (id)0x0) {
    pvVar3 = _objc_msgSend(self,sel_zone);
    pvVar3 = _objc_msgSend(puVar2,sel_allocWithZone_,pvVar3);
    puVar2 = cls_NSBundle;
    pvVar4 = _objc_msgSend(self,sel_class);
    pvVar4 = _objc_msgSend(puVar2,sel_bundleForClass_,pvVar4);
    pcVar8 = &cfstr_plist;
    pvVar4 = _objc_msgSend(pvVar4,sel_pathForResource_ofType_,&cfstr_MoviesImportedLocations,
                           &cfstr_plist);
    pvVar3 = _objc_msgSend(pvVar3,sel_initWithContentsOfFile_,pvVar4);
    self->_predefinedMovieLocations = pvVar3;
    pvVar3 = _objc_msgSend(cls_HSSystem,sel_sharedSystem);
    pvVar3 = _objc_msgSend(pvVar3,sel_isSandboxed);
    if ((char)pvVar3 == '\0') {
      pvVar3 = self->_predefinedMovieLocations;
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
      pvVar4 = self->_predefinedMovieLocations;
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
              _objc_enumerationMutation(self->_predefinedMovieLocations);
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
      _objc_msgSend(self->_predefinedMovieLocations,sel_release,puVar7,puVar9,uVar10);
      self->_predefinedMovieLocations = pvVar3;
    }
  }
  return pvVar3;
}

*/
- (id)predefinedMovieLocations
{
    if (_predefinedMovieLocations == nil) {
        _predefinedMovieLocations = [[NSArray allocWithZone:[self zone]] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"MoviesImportedLocations" ofType:@"plist"]];
        if ([[HSSystem sharedSystem] isSandboxed]) {
            NSMutableArray *locations = [NSMutableArray new];
            for (id location in _predefinedMovieLocations) {
                if (![location isEqualToString:@"~/Desktop"] && ![location isEqualToString:@"~/Documents"]) {
                    [locations addObject:location];
                }
            }
            [_predefinedMovieLocations release];
            _predefinedMovieLocations = locations;
        }
    }
    return _predefinedMovieLocations;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001db51e @ 001db51e, 532 bytes * /

id FUN_001db51e(HSImportDialogMoviesImportedPaneViewController *self,SEL _cmd,
               id createMediaPathsForKey)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  undefined4 local_20;
  
  pvVar1 = _objc_msgSend(cls_NSString,sel_class);
  pvVar2 = _objc_msgSend(createMediaPathsForKey,sel_isKindOfClass_,pvVar1);
  if ((char)pvVar2 == '\0') {
    local_20 = (id)0x0;
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_supportedMediaTypes,pvVar1);
    self_00 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
    pvVar1 = createMediaPathsForKey;
    pvVar3 = _objc_msgSend(self_00,sel_directoryContentsAtPath_,createMediaPathsForKey);
    local_20 = (id)0x0;
    pvVar3 = _objc_msgSend(pvVar3,sel_objectEnumerator);
    while( true ) {
      pvVar1 = _objc_msgSend(pvVar3,sel_nextObject,pvVar1);
      if (pvVar1 == (id)0x0) break;
      pvVar1 = _objc_msgSend(createMediaPathsForKey,sel_stringByAppendingPathComponent_,pvVar1);
      pvVar4 = _objc_msgSend(pvVar1,sel_stringByResolvingSymlinksInPath);
      pvVar1 = _objc_msgSend(self_00,sel_hyperFileTypeAtPath_,pvVar4);
      pvVar1 = _objc_msgSend(pvVar2,sel_containsObject_,pvVar1);
      if ((char)pvVar1 == '\0') {
        pvVar1 = pvVar4;
        pvVar5 = _objc_msgSend(self_00,sel_hyperResolveAliasAtPath_,pvVar4);
        if (pvVar5 != (id)0x0) {
          pvVar1 = _objc_msgSend(pvVar5,sel_length,pvVar1);
          if (pvVar1 != (id)0x0) {
            pvVar4 = pvVar5;
          }
        }
      }
      pvVar1 = _objc_msgSend(self_00,sel_hyperFileTypeAtPath_,pvVar4);
      pvVar5 = _objc_msgSend(pvVar2,sel_containsObject_,pvVar1);
      if ((char)pvVar5 != '\0') {
        pvVar1 = pvVar4;
        pvVar5 = _objc_msgSend(self_00,sel_hyperIsFileInvisibleAtPath_,pvVar4);
        if ((char)pvVar5 == '\0') {
          if (local_20 == (id)0x0) {
            local_20 = _objc_msgSend(cls_NSMutableArray,sel_arrayWithCapacity_,0);
          }
          _objc_msgSend(local_20,sel_addObject_,pvVar4);
          pvVar1 = pvVar4;
        }
      }
    }
  }
  return local_20;
}

*/
- (id)createMediaPathsForKey:(id)aKey
{
    NSMutableArray *paths = nil;
    if ([aKey isKindOfClass:[NSString class]]) {
        id supportedTypes = [self supportedMediaTypes];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSEnumerator *enumerator = [[fileManager directoryContentsAtPath:aKey] objectEnumerator];
        id name;
        while ((name = [enumerator nextObject]) != nil) {
            id path = [[aKey stringByAppendingPathComponent:name] stringByResolvingSymlinksInPath];
            if (![supportedTypes containsObject:[fileManager hyperFileTypeAtPath:path]]) {
                id resolved = [fileManager hyperResolveAliasAtPath:path];
                if (resolved != nil && [resolved length] != 0) {
                    path = resolved;
                }
            }
            if ([supportedTypes containsObject:[fileManager hyperFileTypeAtPath:path]]
                && ![fileManager hyperIsFileInvisibleAtPath:path]) {
                if (paths == nil) {
                    paths = [NSMutableArray arrayWithCapacity:0];
                }
                [paths addObject:path];
            }
        }
    }
    return paths;
}

- (id)currentMediaPathsLocation
{
    return [[self tableViewDataSource] currentPathForTableView:_browseTableView];
}

- (void)tvDataSourceSelectionDidChange:(id)aChange
{
    id pvVar1;
    NSUInteger pvVar1_2;
    id pvVar1_3;
    id pvVar2_3;

    [self invalidateMediaPaths];
    pvVar1 = [_browseTableViewDataSource currentEnclosedDirectoryPathForSelection];
    if (pvVar1 != nil) {
        pvVar1_2 = [[self filteredMediaPathsForKey:[self currentMediaPathsLocation]] indexOfObject:pvVar1];
        if (pvVar1_2 != NSNotFound) {
            [_imageGrid selectItemAtIndex:pvVar1_2 byExtendingSelection:NO];
        }
    }
    if (_switchingHistory == NO) {
        pvVar1_3 = [self primaryHistory];
        pvVar2_3 = [self currentMediaPathsLocation];
        if (![[pvVar1_3 lastObject] isEqualToString:pvVar2_3]) {
            [pvVar1_3 addObject:pvVar2_3];
            [_secondaryHistory release];
            _secondaryHistory = nil;
            [self validateHistoryNavigationControl];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001db8e1 @ 001db8e1, 468 bytes * /

BOOL FUN_001db8e1(HSImportDialogMoviesImportedPaneViewController *self,SEL _cmd,
                 id mediaPathConformsToFilter)

{
  id pvVar1;
  id pvVar2;
  char cVar3;
  undefined4 *puVar4;
  char *pcVar5;
  char local_1d;
  HSImportDialogMoviesImportedPaneViewController *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSImportDialogMoviesPaneViewCont_00353ff0;
  pvVar1 = _objc_msgSendSuper(&local_1c,sel_mediaPathConformsToFilter_,mediaPathConformsToFilter);
  cVar3 = (char)pvVar1;
  if (cVar3 != '\0') {
    local_1d = '\0';
    pvVar1 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
    pcVar5 = &local_1d;
    _objc_msgSend(pvVar1,sel_fileExistsAtPath_isDirectory_,mediaPathConformsToFilter,pcVar5);
    pvVar1 = _objc_msgSend(cls_NSWorkspace,sel_sharedWorkspace);
    pvVar1 = _objc_msgSend(pvVar1,sel_isFilePackageAtPath_,mediaPathConformsToFilter);
    if ((local_1d == '\0') || ((char)pvVar1 != '\0')) {
      pvVar1 = _objc_msgSend(self,sel_concreteMediaTypeForMovie_,mediaPathConformsToFilter,pcVar5);
      pvVar2 = _objc_msgSend((self->super)._itemsFilterPopUp,sel_selectedItem);
      pvVar2 = _objc_msgSend(pvVar2,sel_tag);
      switch(pvVar2) {
      case (id)0x7d1:
        puVar4 = (undefined4 *)PTR_PTR_00336768;
        break;
      case (id)0x7d2:
        puVar4 = (undefined4 *)PTR_PTR_00336770;
        break;
      case (id)0x7d3:
        puVar4 = (undefined4 *)PTR_PTR_00336774;
        break;
      case (id)0x7d4:
        puVar4 = (undefined4 *)PTR_PTR_0033675c;
        break;
      case (id)0x7d5:
        puVar4 = (undefined4 *)PTR_PTR_00336760;
        break;
      default:
        goto switchD_001dba00_caseD_7d6;
      case (id)0x7d7:
        puVar4 = (undefined4 *)PTR_PTR_00336778;
        break;
      case (id)0x7d8:
        puVar4 = (undefined4 *)PTR_PTR_00336764;
        break;
      case (id)0x7d9:
        puVar4 = (undefined4 *)PTR_PTR_0033676c;
        break;
      case (id)0x7da:
        pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_,*(undefined4 *)PTR_PTR_0033677c);
        return (BOOL)pvVar1;
      }
      pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_,*puVar4);
      return (BOOL)pvVar1;
    }
    cVar3 = '\0';
  }
switchD_001dba00_caseD_7d6:
  return cVar3;
}

*/
- (BOOL)mediaPathConformsToFilter:(id)aFilter
{
    BOOL conforms = [super mediaPathConformsToFilter:aFilter];
    if (!conforms) {
        return NO;
    }
    BOOL isDirectory = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:aFilter isDirectory:&isDirectory];
    BOOL isPackage = [[NSWorkspace sharedWorkspace] isFilePackageAtPath:aFilter];
    if (isDirectory && !isPackage) {
        return NO;
    }
    id type = [self concreteMediaTypeForMovie:aFilter];
    NSString *expected;
    switch ([[_itemsFilterPopUp selectedItem] tag]) {
        case 0x7d1: expected = GIFMovie; break;
        case 0x7d2: expected = MOOVMovie; break;
        case 0x7d3: expected = MPEG4Movie; break;
        case 0x7d4: expected = AVIMovie; break;
        case 0x7d5: expected = DVMovie; break;
        case 0x7d7: expected = @"3GPMovie"; break;
        case 0x7d8: expected = FLCMovie; break;
        case 0x7d9: expected = M4VMovie; break;
        case 0x7da: expected = @"iMovie"; break;
        default: return conforms;
    }
    return [type isEqualToString:expected];
}

- (void)reloadMediaPaths
{
    NSUInteger pvVar1_5;

    [super reloadMediaPaths];
    if ([[self tableViewDataSource] currentFilenameForSelection] != nil) {
        pvVar1_5 = [[self filteredMediaPathsForKey:[self currentMediaPathsLocation]] indexOfObject:[[self currentMediaPathsLocation] stringByAppendingPathComponent:[[self tableViewDataSource] currentFilenameForSelection]]];
        if (pvVar1_5 != NSNotFound) {
            [_imageGrid selectItemAtIndex:pvVar1_5 byExtendingSelection:NO];
        }
    }
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
/* FUN_001dbd39 @ 001dbd39, 112 bytes * /

void FUN_001dbd39(HSImportDialogMoviesImportedPaneViewController *self,SEL _cmd,id switchHistoryTo)

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

- (void)paneDialogWillOpen
{
    [super paneDialogWillOpen];
    if ([_paneView superview] != nil) {
        [self moviesMightDidChange];
    }
}

- (id)paneTitle
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"ImportDialogGraphicsImportedPaneTitle" value:@"" table:@"ImportDialogs"];
}

- (NSInteger)paneWeight
{
    return 3;
}

- (id)paneIdentifier
{
    return @"HSImportDialogImportedMovies";
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001dc024 @ 001dc024, 399 bytes * /

void FUN_001dc024(HSImportDialogMoviesImportedPaneViewController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  HSImportDialogMoviesImportedPaneViewController *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSImportDialogMoviesPaneViewCont_00353ff0;
  _objc_msgSendSuper(&local_1c,sel_awakeFromNib);
  pvVar1 = _objc_msgSend(self,sel_tableViewDataSource);
  _objc_msgSend(pvVar1,sel_configureTableView_,(self->super)._browseTableView);
  _objc_msgSend((self->super)._browseTableView,sel_setDataSource_,pvVar1);
  _objc_msgSend((self->super)._browseTableView,sel_setDelegate_,pvVar1);
  pvVar1 = (self->super)._browseTableView;
  pvVar2 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,*(undefined4 *)PTR_00336414);
  _objc_msgSend(pvVar1,sel_registerForDraggedTypes_,pvVar2);
  _objc_msgSend(self,sel_tvDataSourceSelectionDidChange_,0);
  _objc_msgSend(self,sel_moviesMightDidChange);
  _objc_msgSend(self->_historyNavigationControl,sel_setLabel_forSegment_,0,0);
  _objc_msgSend(self->_historyNavigationControl,sel_setLabel_forSegment_,0,1);
  _objc_msgSend(self,sel_validateHistoryNavigationControl);
  return;
}

*/
- (void)awakeFromNib
{
    [super awakeFromNib];
    id dataSource = [self tableViewDataSource];
    [dataSource configureTableView:_browseTableView];
    [_browseTableView setDataSource:dataSource];
    [_browseTableView setDelegate:dataSource];
    [_browseTableView registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
    [self tvDataSourceSelectionDidChange:nil];
    [self moviesMightDidChange];
    [_historyNavigationControl setLabel:nil forSegment:0];
    [_historyNavigationControl setLabel:nil forSegment:1];
    [self validateHistoryNavigationControl];
}

- (void)dealloc
{
    id pvVar1;
    id pvVar3;
    HSImportDialogMoviesImportedPaneViewController *pHVar4;

    pvVar1 = [NSNotificationCenter defaultCenter];
    pHVar4 = self;
    [pvVar1 removeObserver:self];
    if ([_browseTableViewDataSource delegate] == self) {
        pHVar4 = nil;
        [_browseTableViewDataSource setDelegate:0];
    }
    pvVar1 = [_browseTableView delegate];
    if (pvVar1 == _browseTableViewDataSource) {
        pHVar4 = nil;
        [_browseTableView setDelegate:0];
    }
    pvVar3 = [_browseTableView dataSource];
    pvVar1 = _browseTableViewDataSource;
    if (pvVar3 == pvVar1) {
        pHVar4 = nil;
        [_browseTableView setDataSource:0];
        pvVar1 = _browseTableViewDataSource;
    }
    [pvVar1 release];
    [_predefinedMovieLocations release];
    [_primaryHistory release];
    [_secondaryHistory release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:NSApplicationDidBecomeActiveNotification object:NSApp];
    }
    return self;
}

@end

