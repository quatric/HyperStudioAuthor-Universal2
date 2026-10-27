#import "HSImportDialogImportedPaneBrowseController.h"

@implementation HSImportDialogImportedPaneBrowseController

/* i386 ivar offsets: _predefinedLocations=0x4, _fileTypes=0x8, _defaultsKey=0xc, _defaultPath=0x10, _currentEnclosedDirectoryPathForSelection=0x14, _currentFilenameForSelection=0x18, _canReleasePathForSelection=0x1c, _lastSelectedRow=0x20, _draggedCustomLocations=0x24, _delegate=0x28 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_001dee16 @ 001dee16, 920 bytes * /

void FUN_001dee16(HSImportDialogImportedPaneBrowseController *self,SEL _cmd,id openPanelDidEnd,
                 int returnCode,void *contextInfo)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  char *pcVar4;
  undefined *puVar5;
  int local_18;
  char local_11;
  
  local_18 = self->_lastSelectedRow;
  if (returnCode == 1) {
    pvVar1 = _objc_msgSend(openPanelDidEnd,sel_URLs);
    pvVar1 = _objc_msgSend(pvVar1,sel_count);
    if (pvVar1 != (id)0x0) {
      pvVar1 = _objc_msgSend(openPanelDidEnd,sel_URLs);
      pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,0);
      pvVar2 = _objc_msgSend(pvVar1,sel_path);
      local_11 = '\0';
      pvVar3 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
      pcVar4 = &local_11;
      pvVar1 = pvVar2;
      pvVar3 = _objc_msgSend(pvVar3,sel_fileExistsAtPath_isDirectory_,pvVar2,pcVar4);
      if ((char)pvVar3 != '\0') {
        pvVar3 = _objc_msgSend(cls_NSWorkspace,sel_sharedWorkspace,pvVar1,pcVar4);
        pvVar1 = pvVar2;
        pvVar3 = _objc_msgSend(pvVar3,sel_isFilePackageAtPath_,pvVar2);
        if ((local_11 == '\0') || ((char)pvVar3 != '\0')) {
          _objc_msgSend(self->_currentFilenameForSelection,sel_release,pvVar1,pcVar4);
          pvVar3 = _objc_msgSend(pvVar2,sel_lastPathComponent);
          pvVar3 = _objc_msgSend(pvVar3,sel_retain);
          self->_currentFilenameForSelection = pvVar3;
          pvVar2 = _objc_msgSend(pvVar2,sel_stringByDeletingLastPathComponent);
          _objc_msgSend(self->_currentEnclosedDirectoryPathForSelection,sel_release);
          pvVar3 = _objc_msgSend(pvVar2,sel_stringByExpandingTildeInPath);
          pvVar3 = _objc_msgSend(pvVar3,sel_retain);
          self->_currentEnclosedDirectoryPathForSelection = pvVar3;
        }
        pvVar3 = _objc_msgSend(self,sel_customImageLocations,pvVar1,pcVar4);
        pvVar1 = pvVar2;
        pvVar3 = _objc_msgSend(pvVar3,sel_containsObject_,pvVar2);
        if ((char)pvVar3 == '\0') {
          pvVar1 = _objc_msgSend(self,sel_customImageLocations,pvVar1);
          pcVar4 = _objc_msgSend(pvVar1,sel_count);
          pvVar1 = pvVar2;
          _objc_msgSend(self,sel_insertCustomImageLocation_atIndex_,pvVar2,pcVar4);
          _objc_msgSend(contextInfo,sel_reloadData);
        }
        pvVar3 = _objc_msgSend(self,sel_customImageLocations,pvVar1,pcVar4);
        pvVar3 = _objc_msgSend(pvVar3,sel_count);
        if (pvVar3 != (id)0x0) {
          pvVar1 = _objc_msgSend(self,sel_customImageLocations,pvVar1);
          pvVar1 = _objc_msgSend(pvVar1,sel_indexOfObject_,pvVar2);
          if (pvVar1 != (id)0x7fffffff) {
            pvVar2 = _objc_msgSend(self,sel_predefinedImageLocations,pvVar2);
            pvVar2 = _objc_msgSend(pvVar2,sel_count);
            local_18 = (int)pvVar1 + 1 + (int)pvVar2;
            self->_lastSelectedRow = local_18;
          }
        }
      }
    }
  }
  pvVar2 = _objc_msgSend(cls_NSIndexSet,sel_indexSetWithIndex_,local_18);
  pvVar3 = _objc_msgSend(contextInfo,sel_selectedRowIndexes);
  pvVar1 = pvVar2;
  pvVar3 = _objc_msgSend(pvVar3,sel_isEqualToIndexSet_,pvVar2);
  if ((char)pvVar3 != '\0') {
    pvVar1 = _objc_msgSend(self,sel_delegate,pvVar1);
    puVar5 = sel_tvDataSourceSelectionDidChange_;
    pvVar1 = _objc_msgSend(pvVar1,sel_respondsToSelector_,sel_tvDataSourceSelectionDidChange_);
    if ((char)pvVar1 != '\0') {
      pvVar1 = _objc_msgSend(self,sel_delegate,puVar5);
      _objc_msgSend(pvVar1,sel_tvDataSourceSelectionDidChange_,self);
      return;
    }
  }
  self->_canReleasePathForSelection = '\0';
  _objc_msgSend(contextInfo,sel_selectRowIndexes_byExtendingSelection_,pvVar2,0);
  self->_canReleasePathForSelection = '\x01';
  return;
}

*/
- (void)openPanelDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    NSTableView *tableView = (NSTableView *)aInfo;
    NSInteger row = _lastSelectedRow;
    if (aCode == NSOKButton && [[aEnd URLs] count] != 0) {
        NSString *path = [[[aEnd URLs] objectAtIndex:0] path];
        BOOL isDirectory = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory]) {
            BOOL isPackage = [[NSWorkspace sharedWorkspace] isFilePackageAtPath:path];
            if (!isDirectory || isPackage) {
                [_currentFilenameForSelection release];
                _currentFilenameForSelection = [[path lastPathComponent] retain];
                path = [path stringByDeletingLastPathComponent];
                [_currentEnclosedDirectoryPathForSelection release];
                _currentEnclosedDirectoryPathForSelection = [[path stringByExpandingTildeInPath] retain];
            }
            if (![[self customImageLocations] containsObject:path]) {
                [self insertCustomImageLocation:path atIndex:[[self customImageLocations] count]];
                [tableView reloadData];
            }
            if ([[self customImageLocations] count] != 0) {
                NSUInteger index = [[self customImageLocations] indexOfObject:path];
                if (index != NSNotFound) {
                    row = (NSInteger)index + 1 + (NSInteger)[[self predefinedImageLocations] count];
                    _lastSelectedRow = (int)row;
                }
            }
        }
    }
    NSIndexSet *rowIndexes = [NSIndexSet indexSetWithIndex:row];
    if ([[tableView selectedRowIndexes] isEqualToIndexSet:rowIndexes] && [[self delegate] respondsToSelector:@selector(tvDataSourceSelectionDidChange:)]) {
        [[self delegate] tvDataSourceSelectionDidChange:self];
        return;
    }
    _canReleasePathForSelection = NO;
    [tableView selectRowIndexes:rowIndexes byExtendingSelection:NO];
    _canReleasePathForSelection = YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001deb0a @ 001deb0a, 780 bytes * /

void FUN_001deb0a(HSImportDialogImportedPaneBrowseController *self,SEL _cmd,
                 id tableViewSelectionDidChange)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  SEL op;
  undefined4 uVar5;
  undefined *puVar6;
  
  pvVar1 = _objc_msgSend(tableViewSelectionDidChange,sel_object);
  uVar5 = 0;
  _objc_msgSend(pvVar1,sel_setAllowsEmptySelection_,0);
  if (self->_canReleasePathForSelection != '\0') {
    _objc_msgSend(self->_currentEnclosedDirectoryPathForSelection,sel_release,uVar5);
    self->_currentEnclosedDirectoryPathForSelection = (id)0x0;
    _objc_msgSend(self->_currentFilenameForSelection,sel_release);
    self->_currentFilenameForSelection = (id)0x0;
  }
  pvVar2 = _objc_msgSend(pvVar1,sel_selectedRow,uVar5);
  pvVar3 = _objc_msgSend(self,sel_predefinedImageLocations);
  pvVar3 = _objc_msgSend(pvVar3,sel_count);
  pvVar4 = _objc_msgSend(self,sel_customImageLocations);
  pvVar4 = _objc_msgSend(pvVar4,sel_count);
  if (pvVar2 == (id)((int)pvVar3 + 1 + (int)pvVar4)) {
    pvVar2 = _objc_msgSend(cls_NSOpenPanel,sel_openPanel);
    puVar6 = cls_NSBundle;
    pvVar3 = _objc_msgSend(self,sel_class);
    pvVar3 = _objc_msgSend(puVar6,sel_bundleForClass_,pvVar3);
    pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_ChooseImagePrompt,
                           &cfstr_empty,&cfstr_ImportDialogs);
    _objc_msgSend(pvVar2,sel_setPrompt_,pvVar3);
    pvVar3 = _objc_msgSend(cls_HSSystem,sel_sharedSystem);
    pvVar3 = _objc_msgSend(pvVar3,sel_isSandboxed);
    _objc_msgSend(pvVar2,sel_setCanChooseFiles_,(uint)((char)pvVar3 == '\0'));
    _objc_msgSend(pvVar2,sel_setCanChooseDirectories_,1);
    _objc_msgSend(pvVar2,sel_setAllowsMultipleSelection_,0);
    self = _objc_msgSend(self,sel_directoryPathForTableRow_,self->_lastSelectedRow);
    _objc_msgSend(pvVar1,sel_window);
    op = 
    sel_beginSheetForDirectory_file_types_modalForWindow_modalDelegate_didEndSelector_contextInfo_;
  }
  else {
    pvVar1 = _objc_msgSend(pvVar1,sel_selectedRow);
    self->_lastSelectedRow = (int)pvVar1;
    pvVar1 = _objc_msgSend(self,sel_delegate);
    puVar6 = sel_tvDataSourceSelectionDidChange_;
    pvVar1 = _objc_msgSend(pvVar1,sel_respondsToSelector_,sel_tvDataSourceSelectionDidChange_);
    if ((char)pvVar1 == '\0') {
      return;
    }
    pvVar2 = _objc_msgSend(self,sel_delegate,puVar6);
    op = sel_tvDataSourceSelectionDidChange_;
  }
  _objc_msgSend(pvVar2,op,self);
  return;
}

*/
- (void)tableViewSelectionDidChange:(id)aChange
{
    NSTableView *tableView = [aChange object];
    [tableView setAllowsEmptySelection:NO];
    if (_canReleasePathForSelection) {
        [_currentEnclosedDirectoryPathForSelection release];
        _currentEnclosedDirectoryPathForSelection = nil;
        [_currentFilenameForSelection release];
        _currentFilenameForSelection = nil;
    }
    if ([tableView selectedRow] == (NSInteger)([[self predefinedImageLocations] count] + 1 + [[self customImageLocations] count])) {
        NSOpenPanel *panel = [NSOpenPanel openPanel];
        [panel setPrompt:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"ChooseImagePrompt" value:@"" table:@"ImportDialogs"]];
        [panel setCanChooseFiles:![[HSSystem sharedSystem] isSandboxed]];
        [panel setCanChooseDirectories:YES];
        [panel setAllowsMultipleSelection:NO];
        NSString *directory = [self directoryPathForTableRow:_lastSelectedRow];
        [panel beginSheetForDirectory:directory file:nil types:_fileTypes modalForWindow:[tableView window] modalDelegate:self didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:) contextInfo:tableView];
        return;
    }
    _lastSelectedRow = (int)[tableView selectedRow];
    if ([[self delegate] respondsToSelector:@selector(tvDataSourceSelectionDidChange:)]) {
        [[self delegate] tvDataSourceSelectionDidChange:self];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001de8b2 @ 001de8b2, 600 bytes * /

BOOL FUN_001de8b2(HSImportDialogImportedPaneBrowseController *self,SEL _cmd,id tableView,
                 id acceptDrop,int row,uint dropOperation)

{
  undefined *puVar1;
  BOOL BVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id self_00;
  char *pcVar6;
  int local_1c;
  char local_11;
  
  pvVar3 = _objc_msgSend(acceptDrop,sel_draggingPasteboard);
  pvVar4 = _objc_msgSend(pvVar3,sel_types);
  puVar1 = PTR_00336414;
  pvVar4 = _objc_msgSend(pvVar4,sel_containsObject_,*(undefined4 *)PTR_00336414);
  if ((char)pvVar4 == '\0') {
    BVar2 = '\0';
  }
  else {
    local_1c = self->_lastSelectedRow;
    pvVar4 = *(id *)puVar1;
    pvVar3 = _objc_msgSend(pvVar3,sel_propertyListForType_,pvVar4);
    pvVar3 = _objc_msgSend(pvVar3,sel_reverseObjectEnumerator);
    while (self_00 = _objc_msgSend(pvVar3,sel_nextObject,pvVar4), self_00 != (id)0x0) {
      local_11 = '\0';
      pvVar5 = _objc_msgSend(cls_NSFileManager,sel_defaultManager,pvVar4);
      pcVar6 = &local_11;
      pvVar4 = self_00;
      pvVar5 = _objc_msgSend(pvVar5,sel_fileExistsAtPath_isDirectory_,self_00,pcVar6);
      if ((char)pvVar5 != '\0') {
        pvVar5 = _objc_msgSend(cls_NSWorkspace,sel_sharedWorkspace,pvVar4,pcVar6);
        pvVar4 = self_00;
        pvVar5 = _objc_msgSend(pvVar5,sel_isFilePackageAtPath_,self_00);
        if ((local_11 == '\0') || ((char)pvVar5 != '\0')) {
          self_00 = _objc_msgSend(self_00,sel_stringByDeletingLastPathComponent,pvVar4,pcVar6);
        }
        pvVar5 = _objc_msgSend(self,sel_customImageLocations,pvVar4,pcVar6);
        pvVar4 = self_00;
        pvVar5 = _objc_msgSend(pvVar5,sel_containsObject_,self_00);
        if ((char)pvVar5 == '\0') {
          pvVar4 = _objc_msgSend(self,sel_predefinedImageLocations,pvVar4);
          pvVar4 = _objc_msgSend(pvVar4,sel_count);
          _objc_msgSend(self,sel_insertCustomImageLocation_atIndex_,self_00,(row + -1) - (int)pvVar4
                       );
          local_1c = local_1c + (uint)(row <= self->_lastSelectedRow);
          pvVar4 = self_00;
        }
      }
    }
    _objc_msgSend(tableView,sel_reloadData,pvVar4);
    if ((local_1c == self->_lastSelectedRow) || (local_1c == -1)) {
      BVar2 = '\x01';
    }
    else {
      pvVar3 = _objc_msgSend(cls_NSIndexSet,sel_indexSetWithIndex_,local_1c);
      _objc_msgSend(tableView,sel_selectRowIndexes_byExtendingSelection_,pvVar3,0);
      BVar2 = '\x01';
    }
  }
  return BVar2;
}

*/
- (BOOL)tableView:(id)aView acceptDrop:(id)aDrop row:(NSInteger)aRow dropOperation:(NSUInteger)aOperation
{
    NSPasteboard *pasteboard = [aDrop draggingPasteboard];
    if (![[pasteboard types] containsObject:NSFilenamesPboardType]) {
        return NO;
    }
    NSInteger selectedRow = _lastSelectedRow;
    for (NSString *path in [[pasteboard propertyListForType:NSFilenamesPboardType] reverseObjectEnumerator]) {
        BOOL isDirectory = NO;
        if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory]) {
            continue;
        }
        BOOL isPackage = [[NSWorkspace sharedWorkspace] isFilePackageAtPath:path];
        if (!isDirectory || isPackage) {
            path = [path stringByDeletingLastPathComponent];
        }
        if (![[self customImageLocations] containsObject:path]) {
            [self insertCustomImageLocation:path atIndex:aRow - 1 - (NSInteger)[[self predefinedImageLocations] count]];
            selectedRow += (aRow <= _lastSelectedRow) ? 1 : 0;
        }
    }
    [aView reloadData];
    if (selectedRow != _lastSelectedRow && selectedRow != -1) {
        [aView selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow] byExtendingSelection:NO];
    }
    return YES;
}

- (NSUInteger)tableView:(id)aView validateDrop:(id)aDrop proposedRow:(NSInteger)aRow proposedDropOperation:(NSUInteger)aOperation
{
    NSUInteger pvVar1_2;
    NSUInteger pvVar2_2;

    pvVar1_2 = [[self predefinedImageLocations] count];
    pvVar2_2 = [[self customImageLocations] count];
    if ((aOperation == 1) && ((int)pvVar1_2 + 1 <= aRow)) {
        return (unsigned int)(aRow <= (int)pvVar2_2 + (int)pvVar1_2 + 1);
    }
    return 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001de7e8 @ 001de7e8, 74 bytes * /

float FUN_001de7e8(HSImportDialogImportedPaneBrowseController *self,SEL _cmd,id tableView,
                  int heightOfRow)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_predefinedImageLocations);
  pvVar1 = _objc_msgSend(pvVar1,sel_count);
  return *(float *)(&DAT_00335af0 + (uint)(pvVar1 == (id)heightOfRow) * 4);
}

*/
- (CGFloat)tableView:(id)aView heightOfRow:(NSInteger)aRow
{
    return ((NSInteger)[[self predefinedImageLocations] count] == aRow) ? 10.0 : 32.0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001de701 @ 001de701, 231 bytes * /

BOOL FUN_001de701(HSImportDialogImportedPaneBrowseController *self,SEL _cmd,id tableView,
                 int shouldSelectRow)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  bool bVar4;
  
  pvVar1 = _objc_msgSend(self,sel_predefinedImageLocations);
  pvVar1 = _objc_msgSend(pvVar1,sel_count);
  pvVar2 = _objc_msgSend(self,sel_directoryPathForTableRow_,shouldSelectRow);
  pvVar3 = _objc_msgSend(self,sel_customImageLocations);
  bVar4 = pvVar1 != (id)shouldSelectRow;
  pvVar1 = pvVar2;
  pvVar3 = _objc_msgSend(pvVar3,sel_containsObject_,pvVar2);
  if ((char)pvVar3 != '\0') {
    pvVar1 = _objc_msgSend(self,sel_customImageLocations,pvVar1);
    pvVar1 = _objc_msgSend(pvVar1,sel_indexOfObject_,pvVar2);
    pvVar1 = _objc_msgSend(self,sel_customImageLocationAtIndex_,pvVar1);
    bVar4 = pvVar1 != (id)0x0 && bVar4;
  }
  return bVar4;
}

*/
- (BOOL)tableView:(id)aView shouldSelectRow:(NSInteger)aRow
{
    BOOL shouldSelect = (NSInteger)[[self predefinedImageLocations] count] != aRow;
    id path = [self directoryPathForTableRow:aRow];
    if ([[self customImageLocations] containsObject:path]) {
        shouldSelect = [self customImageLocationAtIndex:[[self customImageLocations] indexOfObject:path]] != nil && shouldSelect;
    }
    return shouldSelect;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001de53e @ 001de53e, 451 bytes * /

void FUN_001de53e(HSImportDialogImportedPaneBrowseController *self,SEL _cmd,id tableView,
                 id willDisplayCell,id forTableColumn,int row)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  int iVar3;
  undefined4 uVar4;
  undefined4 local_14;
  
  iVar3 = row;
  pvVar1 = _objc_msgSend(self,sel_directoryPathForTableRow_,row);
  self_00 = _objc_msgSend(self,sel_predefinedImageLocations);
  pvVar2 = _objc_msgSend(self,sel_customImageLocations);
  local_14 = willDisplayCell;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self_00,sel_count,iVar3);
    pvVar2 = _objc_msgSend(pvVar2,sel_count);
    if ((int)pvVar1 + 1 + (int)pvVar2 != row) {
      pvVar1 = (id)0x0;
      goto LAB_001de65c;
    }
    pvVar2 = _objc_msgSend(cls_NSWorkspace,sel_sharedWorkspace);
    pvVar1 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider);
    pvVar1 = _objc_msgSend(pvVar1,sel_localApplicationSupportFolder);
  }
  else {
    pvVar2 = _objc_msgSend(cls_NSWorkspace,sel_sharedWorkspace,iVar3);
  }
  pvVar1 = _objc_msgSend(pvVar2,sel_iconForFile_,pvVar1);
LAB_001de65c:
  _objc_msgSend(willDisplayCell,sel_setIcon_,pvVar1);
  pvVar1 = _objc_msgSend(cls_HSImageTextTableCell,sel_class);
  pvVar2 = _objc_msgSend(willDisplayCell,sel_isKindOfClass_,pvVar1);
  if ((char)pvVar2 == '\0') {
    local_14 = (id)0x0;
  }
  pvVar1 = _objc_msgSend(self_00,sel_count,pvVar1);
  if (pvVar1 == (id)row) {
    uVar4 = 3;
  }
  else {
    uVar4 = 1;
  }
  _objc_msgSend(local_14,sel_setImageTextPosition_,uVar4);
  return;
}

*/
- (void)tableView:(id)aView willDisplayCell:(id)aCell forTableColumn:(id)aColumn row:(NSInteger)aRow
{
    NSString *path = [self directoryPathForTableRow:aRow];
    NSArray *predefinedLocations = [self predefinedImageLocations];
    NSArray *customLocations = [self customImageLocations];
    NSImage *icon = nil;
    if (path != nil) {
        icon = [[NSWorkspace sharedWorkspace] iconForFile:path];
    }
    else if ((NSInteger)([predefinedLocations count] + 1 + [customLocations count]) == aRow) {
        icon = [[NSWorkspace sharedWorkspace] iconForFile:[[HSPathsProvider sharedPathsProvider] localApplicationSupportFolder]];
    }
    [aCell setIcon:icon];
    id imageTextCell = [aCell isKindOfClass:[HSImageTextTableCell class]] ? aCell : nil;
    [imageTextCell setImageTextPosition:((NSInteger)[predefinedLocations count] == aRow) ? 3 : 1];
}

- (void)setDefaultPath:(id)aPath
{
    if (![aPath isEqualToString:_defaultPath]) {
        [_defaultPath release];
        _defaultPath = [aPath retain];
    }
}

- (id)defaultPath
{
    return _defaultPath;
}

- (NSInteger)tableRowForDirectoryPath:(id)aPath
{
    NSUInteger pvVar1_4;
    id pvVar2_2;

    if (![[self predefinedImageLocations] containsObject:[aPath stringByAbbreviatingWithTildeInPath]]) {
        pvVar2_2 = [self customImageLocations];
        if (![pvVar2_2 containsObject:aPath]) {
            pvVar1_4 = 0xffffffff;
        }
        else {
            pvVar1_4 = ([[self predefinedImageLocations] count] + 1 + (int)[[self customImageLocations] indexOfObject:aPath]);
        }
    }
    else {
        pvVar1_4 = [[self predefinedImageLocations] indexOfObject:[aPath stringByAbbreviatingWithTildeInPath]];
    }
    return (int)pvVar1_4;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001de239 @ 001de239, 373 bytes * /

id FUN_001de239(HSImportDialogImportedPaneBrowseController *self,SEL _cmd,
               int directoryPathForTableRow)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  
  op = sel_defaultPath;
  if (-1 < directoryPathForTableRow) {
    pvVar1 = _objc_msgSend(self,sel_predefinedImageLocations);
    pvVar1 = _objc_msgSend(pvVar1,sel_count);
    op = sel_defaultPath;
    if (pvVar1 != (id)directoryPathForTableRow) {
      pvVar1 = _objc_msgSend(self,sel_predefinedImageLocations);
      pvVar1 = _objc_msgSend(pvVar1,sel_count);
      pvVar2 = _objc_msgSend(self,sel_predefinedImageLocations);
      if (directoryPathForTableRow < (int)pvVar1) {
        self = _objc_msgSend(pvVar2,sel_objectAtIndex_,directoryPathForTableRow);
        op = sel_stringByExpandingTildeInPath;
      }
      else {
        pvVar1 = _objc_msgSend(pvVar2,sel_count);
        pvVar2 = _objc_msgSend(self,sel_customImageLocations);
        pvVar2 = _objc_msgSend(pvVar2,sel_count);
        if ((int)pvVar1 + 1 + (int)pvVar2 <= directoryPathForTableRow) {
          return (id)0x0;
        }
        pvVar1 = _objc_msgSend(self,sel_customImageLocations);
        pvVar2 = _objc_msgSend(self,sel_predefinedImageLocations);
        pvVar2 = _objc_msgSend(pvVar2,sel_count);
        self = _objc_msgSend(pvVar1,sel_objectAtIndex_,(directoryPathForTableRow + -1) - (int)pvVar2
                            );
        op = sel_stringByExpandingTildeInPath;
      }
    }
  }
  pvVar1 = _objc_msgSend(self,op);
  return pvVar1;
}

*/
- (id)directoryPathForTableRow:(NSInteger)aRow
{
    if (aRow < 0 || (NSInteger)[[self predefinedImageLocations] count] == aRow) {
        return [self defaultPath];
    }
    if (aRow < (NSInteger)[[self predefinedImageLocations] count]) {
        return [[[self predefinedImageLocations] objectAtIndex:aRow] stringByExpandingTildeInPath];
    }
    if ((NSInteger)([[self predefinedImageLocations] count] + 1 + [[self customImageLocations] count]) <= aRow) {
        return nil;
    }
    return [[[self customImageLocations] objectAtIndex:aRow - 1 - (NSInteger)[[self predefinedImageLocations] count]] stringByExpandingTildeInPath];
}

- (id)predefinedImageLocations
{
    return _predefinedLocations;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001df27a @ 001df27a, 428 bytes * /

void FUN_001df27a(HSImportDialogImportedPaneBrowseController *self,SEL _cmd,
                 id insertCustomImageLocation,uint atIndex)

{
  char cVar1;
  short sVar2;
  id pvVar3;
  int iVar4;
  SEL op;
  undefined4 uVar5;
  undefined4 uVar6;
  undefined4 *local_68;
  undefined1 local_64 [84];
  
  pvVar3 = _objc_msgSend(self,sel_customImageLocations);
  op = sel_mutableCopy;
  if (pvVar3 == (id)0x0) {
    pvVar3 = _objc_msgSend(cls_NSMutableArray,sel_alloc);
    op = sel_init;
  }
  pvVar3 = _objc_msgSend(pvVar3,op);
  _objc_msgSend(pvVar3,sel_insertObject_atIndex_,insertCustomImageLocation,atIndex);
  _objc_msgSend(self,sel_setCustomImageLocations_,pvVar3);
  _objc_msgSend(pvVar3,sel_release);
  if (insertCustomImageLocation != (id)0x0) {
    uVar6 = 1;
    uVar5 = 0;
    iVar4 = _CFURLCreateWithFileSystemPath(0,insertCustomImageLocation,0,1);
    if (iVar4 != 0) {
      cVar1 = _CFURLGetFSRef(iVar4,local_64,uVar5,uVar6,iVar4);
      if (cVar1 != '\0') {
        local_68 = (undefined4 *)0x0;
        sVar2 = _FSNewAlias(0,local_64,&local_68);
        if (sVar2 == 0) {
          uVar5 = _GetAliasSize(local_68);
          pvVar3 = _objc_msgSend(cls_NSData,sel_alloc);
          pvVar3 = _objc_msgSend(pvVar3,sel_initWithBytes_length_,*local_68,uVar5);
          _objc_msgSend(self,sel_setCustomImageLocationAliasData_forLocation_,pvVar3,
                        insertCustomImageLocation);
          _objc_msgSend(pvVar3,sel_release);
        }
        _DisposeHandle(local_68);
      }
      _CFRelease(iVar4);
    }
  }
  return;
}

*/
- (void)insertCustomImageLocation:(id)aLocation atIndex:(NSUInteger)aIndex
{
    NSArray *locations = [self customImageLocations];
    NSMutableArray *newLocations = (locations != nil) ? [locations mutableCopy] : [[NSMutableArray alloc] init];
    [newLocations insertObject:aLocation atIndex:aIndex];
    [self setCustomImageLocations:newLocations];
    [newLocations release];
    if (aLocation == nil) {
        return;
    }
    CFURLRef url = CFURLCreateWithFileSystemPath(NULL, (CFStringRef)aLocation, kCFURLPOSIXPathStyle, true);
    if (url == NULL) {
        return;
    }
    FSRef ref;
    if (CFURLGetFSRef(url, &ref)) {
        AliasHandle alias = NULL;
        if (FSNewAlias(NULL, &ref, &alias) == noErr) {
            Size size = GetAliasSize(alias);
            NSData *data = [[NSData alloc] initWithBytes:*alias length:size];
            [self setCustomImageLocationAliasData:data forLocation:aLocation];
            [data release];
        }
        DisposeHandle((Handle)alias);
    }
    CFRelease(url);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001df426 @ 001df426, 833 bytes * /

id FUN_001df426(HSImportDialogImportedPaneBrowseController *self,SEL _cmd,
               uint customImageLocationAtIndex)

{
  short sVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  undefined4 uVar5;
  uint uVar6;
  id local_6c;
  char local_65;
  undefined1 local_64 [80];
  undefined4 *local_14;
  
  pvVar2 = _objc_msgSend(self,sel_customImageLocations);
  uVar6 = customImageLocationAtIndex;
  pvVar2 = _objc_msgSend(pvVar2,sel_objectAtIndex_,customImageLocationAtIndex);
  pvVar3 = _objc_msgSend(pvVar2,sel_length);
  if (pvVar3 == (id)0x0) {
    local_6c = (id)0x0;
  }
  else {
    pvVar3 = _objc_msgSend(self,sel_customImageLocationAliases,uVar6);
    pvVar4 = _objc_msgSend(self,sel_customImageLocations);
    pvVar4 = _objc_msgSend(pvVar4,sel_objectAtIndex_,customImageLocationAtIndex);
    pvVar3 = _objc_msgSend(pvVar3,sel_objectForKey_,pvVar4);
    local_6c = pvVar2;
    if (pvVar3 != (id)0x0) {
      local_14 = (undefined4 *)0x0;
      pvVar4 = _objc_msgSend(pvVar3,sel_length,pvVar4);
      pvVar3 = _objc_msgSend(pvVar3,sel_bytes);
      _PtrToHand(pvVar3,&local_14,pvVar4);
      if (local_14 != (undefined4 *)0x0) {
        sVar1 = _FSResolveAlias(0,local_14,local_64,&local_65);
        if (sVar1 == 0) {
          pvVar3 = (id)_CFURLCreateFromFSRef(0,local_64);
          local_6c = _objc_msgSend(pvVar3,sel_path);
          _objc_msgSend(pvVar3,sel_release);
          if (local_65 != '\0') {
            pvVar3 = _objc_msgSend(self,sel_customImageLocations);
            pvVar3 = _objc_msgSend(pvVar3,sel_mutableCopy);
            _objc_msgSend(pvVar3,sel_replaceObjectAtIndex_withObject_,customImageLocationAtIndex,
                          local_6c);
            _objc_msgSend(self,sel_setCustomImageLocations_,pvVar3);
            _objc_msgSend(pvVar3,sel_release);
            pvVar3 = _objc_msgSend(self,sel_customImageLocationAliases);
            pvVar3 = _objc_msgSend(pvVar3,sel_mutableCopy);
            _objc_msgSend(pvVar3,sel_removeObjectForKey_,pvVar2);
            pvVar2 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
            pvVar4 = _objc_msgSend(self->_defaultsKey,sel_stringByAppendingString_,&cfstr__aliases);
            _objc_msgSend(pvVar2,sel_setObject_forKey_,pvVar3,pvVar4);
            _objc_msgSend(pvVar3,sel_release);
            uVar5 = _GetAliasSize(local_14);
            pvVar2 = _objc_msgSend(cls_NSData,sel_alloc);
            pvVar2 = _objc_msgSend(pvVar2,sel_initWithBytes_length_,*local_14,uVar5);
            _objc_msgSend(self,sel_setCustomImageLocationAliasData_forLocation_,pvVar2,local_6c);
            _objc_msgSend(pvVar2,sel_release);
          }
        }
        else {
          local_6c = (id)0x0;
        }
      }
      _DisposeHandle(local_14);
    }
  }
  return local_6c;
}

*/
- (id)customImageLocationAtIndex:(NSUInteger)aIndex
{
    NSString *location = [[self customImageLocations] objectAtIndex:aIndex];
    if ([location length] == 0) {
        return nil;
    }
    NSData *aliasData = [[self customImageLocationAliases] objectForKey:[[self customImageLocations] objectAtIndex:aIndex]];
    NSString *path = location;
    if (aliasData == nil) {
        return path;
    }
    Handle handle = NULL;
    PtrToHand([aliasData bytes], &handle, (long)[aliasData length]);
    if (handle != NULL) {
        FSRef ref;
        Boolean wasChanged = false;
        if (FSResolveAlias(NULL, (AliasHandle)handle, &ref, &wasChanged) == noErr) {
            NSURL *url = (NSURL *)CFURLCreateFromFSRef(NULL, &ref);
            path = [url path];
            [url release];
            if (wasChanged) {
                NSMutableArray *locations = [[self customImageLocations] mutableCopy];
                [locations replaceObjectAtIndex:aIndex withObject:path];
                [self setCustomImageLocations:locations];
                [locations release];
                NSMutableDictionary *aliases = [[self customImageLocationAliases] mutableCopy];
                [aliases removeObjectForKey:location];
                [[NSUserDefaults standardUserDefaults] setObject:aliases forKey:[_defaultsKey stringByAppendingString:@"_aliases"]];
                [aliases release];
                Size size = GetAliasSize((AliasHandle)handle);
                NSData *data = [[NSData alloc] initWithBytes:*handle length:size];
                [self setCustomImageLocationAliasData:data forLocation:path];
                [data release];
            }
        }
        else {
            path = nil;
        }
    }
    DisposeHandle(handle);
    return path;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001de149 @ 001de149, 240 bytes * /

void FUN_001de149(HSImportDialogImportedPaneBrowseController *self,SEL _cmd,
                 id setCustomImageLocationAliasData,id forLocation)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_customImageLocationAliases);
  op = sel_mutableCopy;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSMutableDictionary,sel_alloc);
    op = sel_init;
  }
  pvVar1 = _objc_msgSend(pvVar1,op);
  _objc_msgSend(pvVar1,sel_setObject_forKey_,setCustomImageLocationAliasData,forLocation);
  self_00 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  pvVar2 = _objc_msgSend(self->_defaultsKey,sel_stringByAppendingString_,&cfstr__aliases);
  _objc_msgSend(self_00,sel_setObject_forKey_,pvVar1,pvVar2);
  _objc_msgSend(pvVar1,sel_release);
  return;
}

*/
- (void)setCustomImageLocationAliasData:(id)aData forLocation:(id)aLocation
{
    NSDictionary *aliases = [self customImageLocationAliases];
    NSMutableDictionary *newAliases = (aliases != nil) ? [aliases mutableCopy] : [[NSMutableDictionary alloc] init];
    [newAliases setObject:aData forKey:aLocation];
    [[NSUserDefaults standardUserDefaults] setObject:newAliases forKey:[_defaultsKey stringByAppendingString:@"_aliases"]];
    [newAliases release];
}

- (id)customImageLocationAliases
{
    id pvVar1;

    if (_defaultsKey == nil) {
        pvVar1 = nil;
    }
    else {
        pvVar1 = [[NSUserDefaults standardUserDefaults] objectForKey:[_defaultsKey stringByAppendingString:@"_aliases"]];
    }
    return pvVar1;
}

- (void)setCustomImageLocations:(id)aLocations
{
    [[NSUserDefaults standardUserDefaults] setObject:aLocations forKey:_defaultsKey];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001df767 @ 001df767, 456 bytes * /

id FUN_001df767(HSImportDialogImportedPaneBrowseController *self,SEL _cmd)

{
  int iVar1;
  id pvVar2;
  id pvVar3;
  undefined4 *puVar4;
  undefined4 *puVar5;
  undefined1 *puVar6;
  undefined4 uVar7;
  id local_80;
  id local_7c;
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
  
  if (self->_defaultsKey == (id)0x0) {
    local_7c = (id)0x0;
  }
  else {
    pvVar3 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
    local_7c = _objc_msgSend(pvVar3,sel_objectForKey_,self->_defaultsKey);
  }
  local_74 = 0;
  local_70 = 0;
  local_6c = (int *)0x0;
  local_68 = 0;
  local_64 = 0;
  local_60 = 0;
  local_5c = 0;
  local_58 = 0;
  puVar6 = local_50;
  puVar4 = &local_74;
  uVar7 = 0x10;
  local_80 = _objc_msgSend(local_7c,sel_countByEnumeratingWithState_objects_count_,puVar4,puVar6,
                           0x10);
  if (local_80 == (id)0x0) {
    local_78 = (id)0x0;
  }
  else {
    iVar1 = *local_6c;
    local_78 = (id)0x0;
    do {
      pvVar3 = (id)0x0;
      do {
        if (iVar1 != *local_6c) {
          _objc_enumerationMutation(local_7c);
        }
        puVar5 = *(undefined4 **)(local_70 + (int)pvVar3 * 4);
        pvVar2 = _objc_msgSend(cls_NSFileManager,sel_defaultManager,puVar4,puVar6,uVar7);
        pvVar3 = (id)((int)pvVar3 + 1);
        puVar4 = puVar5;
        pvVar2 = _objc_msgSend(pvVar2,sel_fileExistsAtPath_);
        if ((char)pvVar2 != '\0') {
          if (local_78 == (id)0x0) {
            pvVar2 = _objc_msgSend(cls_NSMutableArray,sel_new,puVar4);
            local_78 = _objc_msgSend(pvVar2,sel_autorelease);
          }
          _objc_msgSend(local_78,sel_addObject_,puVar5);
          puVar4 = puVar5;
        }
      } while (pvVar3 < local_80);
      puVar6 = local_50;
      puVar4 = &local_74;
      uVar7 = 0x10;
      local_80 = _objc_msgSend(local_7c,sel_countByEnumeratingWithState_objects_count_,puVar4,puVar6
                               ,0x10);
    } while (local_80 != (id)0x0);
  }
  return local_78;
}

*/
- (id)customImageLocations
{
    NSArray *storedLocations = (_defaultsKey != nil) ? [[NSUserDefaults standardUserDefaults] objectForKey:_defaultsKey] : nil;
    NSMutableArray *locations = nil;
    for (NSString *location in storedLocations) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:location]) {
            if (locations == nil) {
                locations = [[NSMutableArray new] autorelease];
            }
            [locations addObject:location];
        }
    }
    return locations;
}

- (void)removeDraggedOutRowsFromTableView:(id)aView
{
    id pvVar1;
    NSUInteger pvVar1_2;
    id pvVar2_2;
    id pvVar2_4;
    NSInteger pvVar2_5;
    id pvVar3_4;
    NSUserDefaults *pvVar4_2;

    if (_draggedCustomLocations != nil) {
        pvVar1 = [self directoryPathForTableRow:_lastSelectedRow];
        pvVar2_2 = [[self customImageLocationAliases] mutableCopy];
        [pvVar2_2 removeObjectsForKeys:[[self customImageLocations] objectsAtIndexes:_draggedCustomLocations]];
        [[NSUserDefaults standardUserDefaults] setObject:pvVar2_2 forKey:[_defaultsKey stringByAppendingString:@"_aliases"]];
        [pvVar2_2 release];
        pvVar3_4 = [[self customImageLocations] mutableCopy];
        [pvVar3_4 removeObjectsAtIndexes:_draggedCustomLocations];
        pvVar4_2 = [NSUserDefaults standardUserDefaults];
        pvVar2_4 = _defaultsKey;
        [pvVar4_2 setObject:[[pvVar3_4 copy] autorelease] forKey:pvVar2_4];
        [pvVar3_4 release];
        [aView reloadData];
        [_draggedCustomLocations release];
        _draggedCustomLocations = nil;
        pvVar2_5 = [self tableRowForDirectoryPath:pvVar1];
        if (pvVar2_5 != _lastSelectedRow) {
            pvVar1_2 = 0;
            if (pvVar2_5 != 0xffffffff) {
                pvVar1_2 = pvVar2_5;
            }
            [aView selectRowIndexes:[NSIndexSet indexSetWithIndex:pvVar1_2] byExtendingSelection:NO];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ddcb7 @ 001ddcb7, 342 bytes * /

BOOL FUN_001ddcb7(HSImportDialogImportedPaneBrowseController *self,SEL _cmd,id tableView,
                 id writeRowsWithIndexes,id toPasteboard)

{
  BOOL BVar1;
  id pvVar2;
  id pvVar3;
  id self_00;
  id pvVar4;
  uint uVar5;
  
  pvVar2 = _objc_msgSend(self,sel_predefinedImageLocations);
  pvVar3 = _objc_msgSend(pvVar2,sel_count);
  pvVar2 = _objc_msgSend(self,sel_customImageLocations);
  pvVar2 = _objc_msgSend(pvVar2,sel_count);
  self_00 = _objc_msgSend(writeRowsWithIndexes,sel_mutableCopy);
  uVar5 = ~(uint)pvVar3;
  pvVar3 = (id)((int)pvVar3 + 1);
  _objc_msgSend(self_00,sel_shiftIndexesStartingAtIndex_by_,pvVar3,uVar5);
  pvVar4 = _objc_msgSend(self_00,sel_firstIndex);
  if (pvVar4 != (id)0x7fffffff) {
    pvVar4 = _objc_msgSend(self_00,sel_lastIndex,pvVar3,uVar5);
    if (pvVar4 < pvVar2) {
      _objc_msgSend(self->_draggedCustomLocations,sel_release,pvVar3,uVar5);
      pvVar2 = _objc_msgSend(self_00,sel_copy);
      self->_draggedCustomLocations = pvVar2;
      pvVar3 = _objc_msgSend(cls_NSArray,sel_array);
      uVar5 = 0;
      _objc_msgSend(toPasteboard,sel_declareTypes_owner_,pvVar3,0);
      BVar1 = '\x01';
      goto LAB_001dddee;
    }
  }
  BVar1 = '\0';
LAB_001dddee:
  _objc_msgSend(self_00,sel_release,pvVar3,uVar5);
  return BVar1;
}

*/
- (BOOL)tableView:(id)aView writeRowsWithIndexes:(id)aIndexes toPasteboard:(id)aPasteboard
{
    NSUInteger predefinedCount = [[self predefinedImageLocations] count];
    NSUInteger customCount = [[self customImageLocations] count];
    NSMutableIndexSet *indexes = [aIndexes mutableCopy];
    [indexes shiftIndexesStartingAtIndex:predefinedCount + 1 by:-(NSInteger)(predefinedCount + 1)];
    BOOL result = NO;
    if ([indexes firstIndex] != NSNotFound && [indexes lastIndex] < customCount) {
        [_draggedCustomLocations release];
        _draggedCustomLocations = [indexes copy];
        [aPasteboard declareTypes:[NSArray array] owner:nil];
        result = YES;
    }
    [indexes release];
    return result;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001dda82 @ 001dda82, 565 bytes * /

id FUN_001dda82(HSImportDialogImportedPaneBrowseController *self,SEL _cmd,id tableView,
               id objectValueForTableColumn,int row)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  cfstringStruct *pcVar3;
  id pvVar4;
  SEL op;
  
  if (row < 0) {
    return (id)0x0;
  }
  pvVar1 = _objc_msgSend(self,sel_predefinedImageLocations);
  pvVar1 = _objc_msgSend(pvVar1,sel_count);
  if (pvVar1 == (id)row) {
    return (id)0x0;
  }
  pvVar1 = _objc_msgSend(self,sel_predefinedImageLocations);
  pvVar1 = _objc_msgSend(pvVar1,sel_count);
  if (row < (int)pvVar1) {
    pvVar1 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
    pvVar2 = _objc_msgSend(self,sel_predefinedImageLocations);
    pcVar3 = _objc_msgSend(pvVar2,sel_objectAtIndex_,row);
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_predefinedImageLocations);
    pvVar1 = _objc_msgSend(pvVar1,sel_count);
    pvVar2 = _objc_msgSend(self,sel_customImageLocations);
    pvVar2 = _objc_msgSend(pvVar2,sel_count);
    self_00 = cls_NSBundle;
    if ((int)pvVar1 + 1 + (int)pvVar2 <= row) {
      pvVar1 = _objc_msgSend(self,sel_class);
      pvVar1 = _objc_msgSend(self_00,sel_bundleForClass_,pvVar1);
      pcVar3 = &cfstr_ImportDialogGraphicsImportedPaneChooseFolder;
      op = sel_localizedStringForKey_value_table_;
      goto LAB_001ddb5b;
    }
    pvVar1 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
    pvVar2 = _objc_msgSend(self,sel_customImageLocations);
    pvVar4 = _objc_msgSend(self,sel_predefinedImageLocations);
    pvVar4 = _objc_msgSend(pvVar4,sel_count);
    pcVar3 = _objc_msgSend(pvVar2,sel_objectAtIndex_,(row + -1) - (int)pvVar4);
  }
  pvVar1 = _objc_msgSend(pvVar1,sel_displayNameAtPath_,pcVar3);
  op = sel_stringByDeletingPathExtension;
LAB_001ddb5b:
  pvVar1 = _objc_msgSend(pvVar1,op,pcVar3);
  return pvVar1;
}

*/
- (id)tableView:(id)aView objectValueForTableColumn:(id)aColumn row:(NSInteger)aRow
{
    if (aRow < 0 || (NSInteger)[[self predefinedImageLocations] count] == aRow) {
        return nil;
    }
    NSString *path;
    if (aRow < (NSInteger)[[self predefinedImageLocations] count]) {
        path = [[self predefinedImageLocations] objectAtIndex:aRow];
    }
    else {
        if ((NSInteger)([[self predefinedImageLocations] count] + 1 + [[self customImageLocations] count]) <= aRow) {
            return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"ImportDialogGraphicsImportedPaneChooseFolder" value:@"" table:@"ImportDialogs"];
        }
        path = [[self customImageLocations] objectAtIndex:aRow - 1 - (NSInteger)[[self predefinedImageLocations] count]];
    }
    return [[[NSFileManager defaultManager] displayNameAtPath:path] stringByDeletingPathExtension];
}

- (NSInteger)numberOfRowsInTableView:(id)aView
{
    return (int)[[self predefinedImageLocations] count] + 2 + (int)[[self customImageLocations] count];
}

- (id)currentFilenameForSelection
{
    return _currentFilenameForSelection;
}

- (id)currentEnclosedDirectoryPathForSelection
{
    return _currentEnclosedDirectoryPathForSelection;
}

- (void)configureTableView:(id)aView
{
    id pvVar1_2;
    id pvVar2_2;

    pvVar1_2 = [[aView tableColumns] objectAtIndex:0];
    pvVar2_2 = [[HSImageTextTableCell alloc] initTextCell:@""];
    [pvVar2_2 setImageTextPosition:1];
    [pvVar2_2 setTextHeight:17.0];
    [pvVar1_2 setDataCell:pvVar2_2];
    [pvVar2_2 release];
    [aView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
}

- (void)setCurrentPath:(id)aPath forTableView:(id)aView
{
    NSUInteger pvVar1_2;
    id pvVar1_10;
    id pvVar2_2;
    NSUInteger pvVar2_3;

    [self setDefaultPath:aPath];
    pvVar1_2 = [[self predefinedImageLocations] indexOfObject:[aPath stringByAbbreviatingWithTildeInPath]];
    if (pvVar1_2 == NSNotFound) {
        pvVar2_2 = [self customImageLocations];
        pvVar2_3 = [pvVar2_2 indexOfObject:aPath];
        if (pvVar2_3 == NSNotFound) {
            [self insertCustomImageLocation:aPath atIndex:[[self customImageLocations] count]];
            pvVar2_3 = [[self customImageLocations] indexOfObject:aPath];
        }
        [aView reloadData];
        pvVar1_10 = [NSIndexSet indexSetWithIndex:(int)pvVar2_3 + 1 + (int)[[self predefinedImageLocations] count]];
    }
    else {
        pvVar1_10 = [NSIndexSet indexSetWithIndex:pvVar1_2];
    }
    [aView selectRowIndexes:pvVar1_10 byExtendingSelection:NO];
    [self tableViewSelectionDidChange:[NSNotification notificationWithName:NSTableViewSelectionDidChangeNotification object:aView]];
}

- (id)currentPathForTableView:(id)aView
{
    return [self directoryPathForTableRow:[aView selectedRow]];
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (id)initWithPredefinedLocations:(id)aLocations userLocationsDefaultsKey:(id)aKey fileTypes:(id)aTypes
{
    self = [super init];
    if (self != nil) {
        _predefinedLocations = [aLocations retain];
        _defaultsKey = [aKey retain];
        _fileTypes = [aTypes retain];
        _canReleasePathForSelection = 1;
    }
    return self;
}

- (void)dealloc
{
    [_predefinedLocations release];
    [_defaultsKey release];
    [_defaultPath release];
    [_fileTypes release];
    [_currentEnclosedDirectoryPathForSelection release];
    [_currentFilenameForSelection release];
    [_draggedCustomLocations release];
    [super dealloc];
}

- (id)customImageLocationBookmarkData
{
    if (_defaultsKey == nil)
        return nil;
    return [[NSUserDefaults standardUserDefaults] objectForKey:[_defaultsKey stringByAppendingString:@"_bookmarkData"]];
}

- (void)setCustomImageLocationBookmarkData:(id)aData forLocation:(id)aLocation
{
    id existing = [self customImageLocationBookmarkData];
    NSMutableDictionary *bookmarks = existing != nil ? [existing mutableCopy] : [[NSMutableDictionary alloc] init];
    [bookmarks setObject:aData forKey:aLocation];
    [[NSUserDefaults standardUserDefaults] setObject:bookmarks forKey:[_defaultsKey stringByAppendingString:@"_bookmarkData"]];
    [bookmarks release];
}

@end

