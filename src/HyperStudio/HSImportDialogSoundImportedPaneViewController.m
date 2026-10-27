#import "HSImportDialogSoundImportedPaneViewController.h"
static id sDAT_003429e8;

static id sDAT_003429e8;


// Sounds sort by duration; those without a known duration come first, and two
// such sounds sort by name.
static NSInteger HSCompareSoundDurations(id aPath1, id aPath2, void *aContext)
{
    id duration1 = [(NSDictionary *)aContext objectForKey:aPath1];
    id duration2 = [(NSDictionary *)aContext objectForKey:aPath2];
    if (duration1 != nil && duration2 != nil) {
        return [duration1 compare:duration2];
    }
    if (duration1 != nil && duration2 == nil) {
        return NSOrderedDescending;
    }
    if (duration1 == nil && duration2 != nil) {
        return NSOrderedAscending;
    }
    return [aPath1 caseInsensitiveCompare:aPath2];
}

@implementation HSImportDialogSoundImportedPaneViewController

/* i386 ivar offsets: _browseTableViewDataSource=0x94, _cancelAllThreads=0x98, _locationForThreads=0x9c, _predefinedSoundLocations=0xa0, _primaryHistory=0xa4, _secondaryHistory=0xa8, _switchingHistory=0xac, _mediaDurationsHash=0xb0 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_001bbf7c @ 001bbf7c, 108 bytes * /

void FUN_001bbf7c(id self,SEL _cmd)

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

- (void)applicationDidBecomeActive:(id)aActive
{
    if ([[[self paneView] window] isVisible]) {
        if ([[self paneView] superview] != nil) {
            [self fileOrFolderStructureMightDidChange];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001bbe2f @ 001bbe2f, 193 bytes * /

void FUN_001bbe2f(HSImportDialogSoundImportedPaneViewController *self,SEL _cmd)

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
    NSIndexSet *pvVar1;

    pvVar1 = [_soundsTableView selectedRowIndexes];
    [self invalidateMediaPaths];
    [_soundsTableView selectRowIndexes:pvVar1 byExtendingSelection:NO];
}

- (id)tableViewDataSource
{
    id pvVar1;
    id pvVar2;
    id pvVar3;
    id pvVar1_2;
    id pvVar1_3;

    pvVar1 = _browseTableViewDataSource;
    if (pvVar1 == nil) {
        pvVar1_2 = [HSImportDialogImportedPaneBrowseController alloc];
        pvVar2 = [NSSound soundUnfilteredFileTypes];
        pvVar3 = [self customImageLocationsDefaultsKey];
        pvVar1_3 = [pvVar1_2 initWithPredefinedLocations:[self predefinedSoundLocations] userLocationsDefaultsKey:pvVar3 fileTypes:pvVar2];
        _browseTableViewDataSource = pvVar1_3;
        [pvVar1_3 setDelegate:self];
        pvVar1 = _browseTableViewDataSource;
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001bc191 @ 001bc191, 646 bytes * /

id FUN_001bc191(HSImportDialogSoundImportedPaneViewController *self,SEL _cmd)

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
  pvVar3 = self->_predefinedSoundLocations;
  if (pvVar3 == (id)0x0) {
    pvVar3 = _objc_msgSend(self,sel_zone);
    pvVar3 = _objc_msgSend(puVar2,sel_allocWithZone_,pvVar3);
    puVar2 = cls_NSBundle;
    pvVar4 = _objc_msgSend(self,sel_class);
    pvVar4 = _objc_msgSend(puVar2,sel_bundleForClass_,pvVar4);
    pcVar8 = &cfstr_plist;
    pvVar4 = _objc_msgSend(pvVar4,sel_pathForResource_ofType_,&cfstr_SoundsImportedLocations,
                           &cfstr_plist);
    pvVar3 = _objc_msgSend(pvVar3,sel_initWithContentsOfFile_,pvVar4);
    self->_predefinedSoundLocations = pvVar3;
    pvVar3 = _objc_msgSend(cls_HSSystem,sel_sharedSystem);
    pvVar3 = _objc_msgSend(pvVar3,sel_isSandboxed);
    if ((char)pvVar3 == '\0') {
      pvVar3 = self->_predefinedSoundLocations;
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
      pvVar4 = self->_predefinedSoundLocations;
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
              _objc_enumerationMutation(self->_predefinedSoundLocations);
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
      _objc_msgSend(self->_predefinedSoundLocations,sel_release,puVar7,puVar9,uVar10);
      self->_predefinedSoundLocations = pvVar3;
    }
  }
  return pvVar3;
}

*/
- (id)predefinedSoundLocations
{
    if (_predefinedSoundLocations == nil) {
        _predefinedSoundLocations = [[NSArray allocWithZone:[self zone]] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"SoundsImportedLocations" ofType:@"plist"]];
        if ([[HSSystem sharedSystem] isSandboxed]) {
            NSMutableArray *locations = [NSMutableArray new];
            for (id location in _predefinedSoundLocations) {
                if (![location isEqualToString:@"~/Desktop"] && ![location isEqualToString:@"~/Documents"]) {
                    [locations addObject:location];
                }
            }
            [_predefinedSoundLocations release];
            _predefinedSoundLocations = locations;
        }
    }
    return _predefinedSoundLocations;
}

- (id)customImageLocationsDefaultsKey
{
    return @"HSImportDialogSoundImportedPaneCustomImageLocations";
}

- (id)desktopLastPathComponent
{
    if (sDAT_003429e8 == nil) {
        sDAT_003429e8 = [[[[self predefinedSoundLocations] objectAtIndex:0] lastPathComponent] retain];
    }
    return sDAT_003429e8;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001bc417 @ 001bc417, 247 bytes * /

void FUN_001bc417(HSImportDialogSoundImportedPaneViewController *self,SEL _cmd,
                 id readMovieDurationInMainThread)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  double dVar3;
  ulonglong uVar4;
  
  pvVar1 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_,readMovieDurationInMainThread);
  pvVar2 = _objc_msgSend(cls_HSMovie,sel_alloc);
  uVar4 = ZEXT48(pvVar1);
  pvVar1 = _objc_msgSend(pvVar2,sel_initWithURL_error_,pvVar1,0);
  self_00 = cls_NSDate;
  if (pvVar1 != (id)0x0) {
    dVar3 = _objc_msgSend_fpret(pvVar1,sel_duration);
    pvVar2 = _objc_msgSend(self_00,sel_dateWithTimeIntervalSinceReferenceDate_,dVar3);
    pvVar2 = _objc_msgSend(cls_NSDictionary,sel_dictionaryWithObject_forKey_,pvVar2,
                           readMovieDurationInMainThread);
    uVar4 = CONCAT44(readMovieDurationInMainThread,pvVar2);
    _objc_msgSend(self,sel_addMediaDurations_,pvVar2);
  }
  _objc_msgSend(pvVar1,sel_release,uVar4);
  return;
}

*/
- (void)readMovieDurationInMainThread:(id)aThread
{
    HSMovie *movie = [[HSMovie alloc] initWithURL:[NSURL fileURLWithPath:aThread] error:NULL];
    if (movie != nil) {
        [self addMediaDurations:[NSDictionary dictionaryWithObject:[NSDate dateWithTimeIntervalSinceReferenceDate:[movie duration]] forKey:aThread]];
    }
    [movie release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001bc50e @ 001bc50e, 486 bytes * /

void FUN_001bc50e(HSImportDialogSoundImportedPaneViewController *self,SEL _cmd,id addMediaDurations)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  int *piVar5;
  id pvVar6;
  undefined8 local_44;
  undefined8 local_3c;
  undefined8 local_34;
  undefined8 local_2c;
  undefined8 local_24;
  undefined8 local_1c;
  
  pvVar1 = _objc_msgSend(addMediaDurations,sel_mutableCopy);
  _objc_msgSend(pvVar1,sel_addEntriesFromDictionary_);
  _objc_msgSend(self->_mediaDurationsHash,sel_release);
  pvVar2 = _objc_msgSend(pvVar1,sel_copy);
  self->_mediaDurationsHash = pvVar2;
  _objc_msgSend(pvVar1,sel_release);
  pvVar1 = _objc_msgSend(addMediaDurations,sel_allKeys);
  pvVar2 = _objc_msgSend(pvVar1,sel_count);
  if (pvVar2 != (id)0x0) {
    pvVar6 = (id)0x0;
    piVar5 = (int *)&stack0xffffff84;
    do {
      piVar5[2] = (int)pvVar6;
      piVar5[1] = (int)sel_objectAtIndex_;
      *piVar5 = (int)pvVar1;
      piVar5[-1] = 0x1bc5e5;
      pvVar3 = _objc_msgSend((id)*piVar5,(SEL)piVar5[1]);
      piVar5[1] = (int)sel_filteredItems;
      *piVar5 = (int)self;
      piVar5[-1] = 0x1bc5fc;
      pvVar4 = _objc_msgSend((id)*piVar5,(SEL)piVar5[1]);
      piVar5[2] = (int)pvVar3;
      piVar5[1] = (int)sel_indexOfObject_;
      *piVar5 = (int)pvVar4;
      piVar5[-1] = 0x1bc612;
      pvVar4 = _objc_msgSend((id)*piVar5,(SEL)piVar5[1]);
      pvVar3 = (self->super)._soundsTableView;
      piVar5[3] = (int)pvVar4;
      piVar5[2] = (int)sel_rectOfRow_;
      piVar5[1] = (int)pvVar3;
      *piVar5 = (int)&local_34;
      piVar5[-1] = 0x1bc635;
      _objc_msgSend_stret((void *)*piVar5,(id)piVar5[1],(SEL)piVar5[2]);
      pvVar3 = (self->super)._soundsTableView;
      piVar5[1] = (int)&cfstr_SoundDuration;
      *piVar5 = (int)sel_columnWithIdentifier_;
      piVar5[-1] = (int)pvVar3;
      piVar5[-2] = 0x1bc65a;
      pvVar4 = _objc_msgSend((id)piVar5[-1],(SEL)*piVar5);
      piVar5[2] = (int)pvVar4;
      piVar5[1] = (int)sel_rectOfColumn_;
      *piVar5 = (int)pvVar3;
      piVar5[-1] = (int)&local_44;
      piVar5[-2] = 0x1bc677;
      _objc_msgSend_stret((void *)piVar5[-1],(id)*piVar5,(SEL)piVar5[1]);
      pvVar3 = (self->super)._soundsTableView;
      *(undefined8 *)(piVar5 + 5) = local_3c;
      *(undefined8 *)(piVar5 + 3) = local_44;
      *(undefined8 *)(piVar5 + 1) = local_2c;
      *(undefined8 *)(piVar5 + -1) = local_34;
      piVar5[-2] = (int)&local_24;
      piVar5[-3] = 0x1bc6b7;
      _NSIntersectionRect();
      *(undefined8 *)(piVar5 + 1) = local_1c;
      *(undefined8 *)(piVar5 + -1) = local_24;
      piVar5[-2] = (int)sel_setNeedsDisplayInRect_;
      piVar5[-3] = (int)pvVar3;
      piVar5[-4] = 0x1bc6e2;
      _objc_msgSend((id)piVar5[-3],(SEL)piVar5[-2]);
      pvVar6 = (id)((int)pvVar6 + 1);
      piVar5 = piVar5 + -3;
    } while (pvVar6 < pvVar2);
  }
  return;
}

*/
- (void)addMediaDurations:(id)aDurations
{
    NSMutableDictionary *durations = [aDurations mutableCopy];
    NSArray *keys;
    NSUInteger count;
    NSUInteger i;
    // Durations already known take precedence over the new ones.
    [durations addEntriesFromDictionary:_mediaDurationsHash];
    [_mediaDurationsHash release];
    _mediaDurationsHash = [durations copy];
    [durations release];
    keys = [aDurations allKeys];
    count = [keys count];
    for (i = 0; i < count; i++) {
        NSInteger row = [[self filteredItems] indexOfObject:[keys objectAtIndex:i]];
        NSRect rowRect = [_soundsTableView rectOfRow:row];
        NSRect columnRect = [_soundsTableView rectOfColumn:[_soundsTableView columnWithIdentifier:@"SoundDuration"]];
        [_soundsTableView setNeedsDisplayInRect:NSIntersectionRect(rowRect, columnRect)];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001bbb34 @ 001bbb34, 335 bytes * /

void FUN_001bbb34(HSImportDialogSoundImportedPaneViewController *self,SEL _cmd,
                 id scaningThreadFunction)

{
  undefined4 uVar1;
  undefined *puVar2;
  undefined *puVar3;
  id self_00;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  
  self_00 = _objc_msgSend(cls_NSAutoreleasePool,sel_new);
  pvVar4 = _objc_msgSend(self,sel_filteredItems);
  uVar1 = *(undefined4 *)PTR_003361b4;
  pvVar4 = _objc_msgSend(pvVar4,sel_objectEnumerator);
  puVar3 = PTR_003363f8;
  puVar2 = PTR_00336064;
  while (self->_cancelAllThreads == '\0') {
    pvVar5 = self->_locationForThreads;
    pvVar6 = _objc_msgSend(scaningThreadFunction,sel_isEqual_,pvVar5);
    if ((char)pvVar6 == '\0') break;
    pvVar5 = _objc_msgSend(pvVar4,sel_nextObject,pvVar5);
    if (pvVar5 == (id)0x0) break;
    pvVar6 = _objc_msgSend(cls_NSArray,sel_arrayWithObjects_,uVar1,*(undefined4 *)puVar3,
                           *(undefined4 *)puVar2,0);
    _objc_msgSend(self,sel_performSelectorOnMainThread_withObject_waitUntilDone_modes_,
                  sel_readMovieDurationInMainThread_,pvVar5,1,pvVar6);
  }
  _objc_msgSend(self_00,sel_release);
  return;
}

*/
- (void)scaningThreadFunction:(id)aFunction
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSEnumerator *items = [[self filteredItems] objectEnumerator];
    id path;
    while (!_cancelAllThreads && [aFunction isEqual:_locationForThreads] && (path = [items nextObject]) != nil) {
        [self performSelectorOnMainThread:@selector(readMovieDurationInMainThread:) withObject:path waitUntilDone:YES modes:[NSArray arrayWithObjects:NSDefaultRunLoopMode, NSModalPanelRunLoopMode, NSEventTrackingRunLoopMode, nil]];
    }
    [pool release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001bb9c2 @ 001bb9c2, 370 bytes * /

void FUN_001bb9c2(HSImportDialogSoundImportedPaneViewController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  HSImportDialogSoundImportedPaneViewController *pHVar4;
  
  pvVar1 = _objc_msgSend(self,sel_currentMediaPathsLocation);
  pvVar2 = _objc_msgSend(self,sel_filteredMediaPathsForKey_,pvVar1);
  if (self->_mediaDurationsHash != (id)0x0) {
    pvVar1 = _objc_msgSend(self->_mediaDurationsHash,sel_count,pvVar1);
    pvVar3 = _objc_msgSend(pvVar2,sel_count);
    if (pvVar3 <= pvVar1) {
      return;
    }
  }
  _objc_msgSend(self,sel_setFilteredItems_,pvVar2);
  pvVar1 = _objc_msgSend(self,sel_filteredItems);
  pvVar1 = _objc_msgSend(pvVar1,sel_count);
  if (pvVar1 != (id)0x0) {
    _objc_msgSend(self->_locationForThreads,sel_release,pvVar2);
    pvVar1 = _objc_msgSend(self,sel_currentMediaPathsLocation);
    pvVar2 = _objc_msgSend(pvVar1,sel_retain);
    self->_locationForThreads = pvVar2;
    pHVar4 = self;
    _objc_msgSend(cls_NSThread,sel_detachNewThreadSelector_toTarget_withObject_,
                  sel_scaningThreadFunction_,self,pvVar2);
    pvVar1 = (self->super)._sortedIdentifier;
    if (pvVar1 != (id)0x0) {
      pvVar1 = _objc_msgSend(self,sel_sortedSoundItemsForIdentifier_,pvVar1,pHVar4,pvVar2);
      _objc_msgSend(self,sel_setFilteredItems_,pvVar1);
    }
  }
  return;
}

*/
- (void)updateFilteredMedia
{
    id paths = [self filteredMediaPathsForKey:[self currentMediaPathsLocation]];
    if (_mediaDurationsHash != nil && [paths count] <= [_mediaDurationsHash count]) {
        return;
    }
    [self setFilteredItems:paths];
    if ([[self filteredItems] count] != 0) {
        [_locationForThreads release];
        _locationForThreads = [[self currentMediaPathsLocation] retain];
        [NSThread detachNewThreadSelector:@selector(scaningThreadFunction:) toTarget:self withObject:_locationForThreads];
        if (_sortedIdentifier != nil) {
            [self setFilteredItems:[self sortedSoundItemsForIdentifier:_sortedIdentifier]];
        }
    }
}

- (void)invalidateSearch
{
    [super invalidateSearch];
    [self invalidateMediaPaths];
}

- (void)tableView:(id)aView didClickTableColumn:(id)aColumn
{
    if (![[aColumn identifier] isEqualToString:biSoundIconKey]) {
        [super tableView:aView didClickTableColumn:aColumn];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001bb8b0 @ 001bb8b0, 274 bytes * /

id FUN_001bb8b0(HSImportDialogSoundImportedPaneViewController *self,SEL _cmd,id valueForSoundObject,
               id forIdentifier,id lineBreakInfo)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  undefined4 uVar3;
  char *pcVar4;
  char local_11;
  
  uVar3 = *(undefined4 *)PTR_003366f4;
  pvVar1 = _objc_msgSend(forIdentifier,sel_isEqualToString_,uVar3);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(self,sel_stringForSoundObject_forIdentifier_lineBreakInfo_,
                           valueForSoundObject,forIdentifier,lineBreakInfo);
  }
  else {
    local_11 = '\0';
    pvVar2 = _objc_msgSend(cls_NSFileManager,sel_defaultManager,uVar3);
    pcVar4 = &local_11;
    pvVar1 = valueForSoundObject;
    pvVar2 = _objc_msgSend(pvVar2,sel_fileExistsAtPath_isDirectory_,valueForSoundObject,pcVar4);
    op = sel_defaultSoundIcon;
    if (((char)pvVar2 != '\0') && (local_11 != '\0')) {
      self = _objc_msgSend(cls_NSWorkspace,sel_sharedWorkspace,pvVar1,pcVar4);
      op = sel_iconForFile_;
      pvVar1 = valueForSoundObject;
    }
    pvVar1 = _objc_msgSend(self,op,pvVar1,pcVar4);
    _objc_msgSend(pvVar1,sel_setSize_,0x41800000,0x41800000);
  }
  return pvVar1;
}

*/
- (id)valueForSoundObject:(id)aObject forIdentifier:(id)aIdentifier lineBreakInfo:(id)aInfo
{
    BOOL isDirectory = NO;
    NSImage *icon;
    if (![aIdentifier isEqualToString:biSoundIconKey]) {
        return [self stringForSoundObject:aObject forIdentifier:aIdentifier lineBreakInfo:aInfo];
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:aObject isDirectory:&isDirectory] && isDirectory) {
        icon = [[NSWorkspace sharedWorkspace] iconForFile:aObject];
    }
    else {
        icon = [self defaultSoundIcon];
    }
    [icon setSize:NSMakeSize(16.0f, 16.0f)];
    return icon;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001bb804 @ 001bb804, 172 bytes * /

id FUN_001bb804(HSImportDialogSoundImportedPaneViewController *self,SEL _cmd,id stringForSoundObject
               ,id forIdentifier,id lineBreakInfo)

{
  id pvVar1;
  SEL op;
  cfstringStruct *pcVar2;
  
  pcVar2 = &cfstr_SoundName;
  pvVar1 = _objc_msgSend(forIdentifier,sel_isEqualToString_,&cfstr_SoundName);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(forIdentifier,sel_isEqualToString_,&cfstr_SoundDuration);
    if (((char)pvVar1 == '\0') || (stringForSoundObject == (id)0x0)) {
      return (id)0x0;
    }
    pvVar1 = self->_mediaDurationsHash;
    op = sel_objectForKey_;
  }
  else {
    pvVar1 = _objc_msgSend(cls_NSFileManager,sel_defaultManager,pcVar2);
    op = sel_displayNameAtPath_;
  }
  pvVar1 = _objc_msgSend(pvVar1,op,stringForSoundObject);
  return pvVar1;
}

*/
- (id)stringForSoundObject:(id)aObject forIdentifier:(id)aIdentifier lineBreakInfo:(id)aInfo
{
    if ([aIdentifier isEqualToString:@"SoundName"]) {
        return [[NSFileManager defaultManager] displayNameAtPath:aObject];
    }
    if (![aIdentifier isEqualToString:@"SoundDuration"] || aObject == nil) {
        return nil;
    }
    return [_mediaDurationsHash objectForKey:aObject];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001bb69a @ 001bb69a, 199 bytes * /

id FUN_001bb69a(HSImportDialogSoundImportedPaneViewController *self,SEL _cmd,
               id sortedSoundItemsForIdentifier)

{
  id pvVar1;
  SEL op;
  cfstringStruct *pcVar2;
  code *pcVar3;
  
  pcVar2 = &cfstr_SoundName;
  pvVar1 = _objc_msgSend(sortedSoundItemsForIdentifier,sel_isEqualToString_,&cfstr_SoundName);
  if ((char)pvVar1 == '\0') {
    pcVar2 = &cfstr_SoundDuration;
    pvVar1 = _objc_msgSend(sortedSoundItemsForIdentifier,sel_isEqualToString_,&cfstr_SoundDuration);
    if ((char)pvVar1 == '\0') {
      return (id)0x0;
    }
    pvVar1 = _objc_msgSend(self,sel_filteredItems,pcVar2);
    op = sel_sortedArrayUsingFunction_context_hint_;
    pcVar3 = FUN_001bb761;
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_filteredItems,pcVar2);
    op = sel_sortedArrayUsingSelector_;
    pcVar3 = (code *)sel_caseInsensitiveCompare_;
  }
  pvVar1 = _objc_msgSend(pvVar1,op,pcVar3);
  return pvVar1;
}

*/
- (id)sortedSoundItemsForIdentifier:(id)aIdentifier
{
    if ([aIdentifier isEqualToString:@"SoundName"]) {
        return [[self filteredItems] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    }
    if ([aIdentifier isEqualToString:@"SoundDuration"]) {
        return [[self filteredItems] sortedArrayUsingFunction:HSCompareSoundDurations context:_mediaDurationsHash hint:_sortedArrayHint];
    }
    return nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001bc7ba @ 001bc7ba, 144 bytes * /

BOOL FUN_001bc7ba(HSImportDialogSoundImportedPaneViewController *self,SEL _cmd,
                 id mediaPathConformsToFilter)

{
  char cVar1;
  id pvVar2;
  char local_1d;
  HSImportDialogSoundImportedPaneViewController *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSImportDialogSoundPaneViewContr_00353750;
  pvVar2 = _objc_msgSendSuper(&local_1c,sel_mediaPathConformsToFilter_,mediaPathConformsToFilter);
  cVar1 = (char)pvVar2;
  if (cVar1 != '\0') {
    local_1d = '\0';
    pvVar2 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
    pvVar2 = _objc_msgSend(pvVar2,sel_fileExistsAtPath_isDirectory_,mediaPathConformsToFilter,
                           &local_1d);
    if (((char)pvVar2 != '\0') && (local_1d != '\0')) {
      cVar1 = '\0';
    }
  }
  return cVar1;
}

*/
- (BOOL)mediaPathConformsToFilter:(id)aFilter
{
    BOOL isDirectory;
    if (![super mediaPathConformsToFilter:aFilter]) {
        return NO;
    }
    isDirectory = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:aFilter isDirectory:&isDirectory] && isDirectory) {
        return NO;
    }
    return YES;
}

- (id)currentMediaPathsLocation
{
    return [[self tableViewDataSource] currentPathForTableView:_browseTableView];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001bb3be @ 001bb3be, 665 bytes * /

void FUN_001bb3be(HSImportDialogSoundImportedPaneViewController *self,SEL _cmd)

{
  undefined *self_00;
  undefined *self_01;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar1 = _objc_msgSend(self,sel_currentMediaPathsLocation);
  if (pvVar1 != (id)0x0) {
    _objc_msgSend((self->super).super._mediaPathDictionary,sel_removeObjectForKey_,pvVar1);
  }
  _objc_msgSend(self->_mediaDurationsHash,sel_release);
  self->_mediaDurationsHash = (id)0x0;
  _objc_msgSend(self,sel_updateFilteredMedia);
  self_01 = cls_NSString;
  pvVar1 = (self->super)._itemsCountTextField;
  pvVar2 = _objc_msgSend((self->super)._filteredItems,sel_count);
  self_00 = cls_NSBundle;
  pvVar3 = _objc_msgSend(self,sel_class);
  pvVar3 = _objc_msgSend(self_00,sel_bundleForClass_,pvVar3);
  pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr__dItems,&cfstr_empty,
                         &cfstr_ImportDialogs);
  pvVar2 = _objc_msgSend(self_01,sel_stringWithFormat_,pvVar3,pvVar2);
  _objc_msgSend(pvVar1,sel_setStringValue_,pvVar2);
  _objc_msgSend((self->super)._soundsTableView,sel_reloadData);
  pvVar1 = _objc_msgSend(self,sel_tableViewDataSource);
  pvVar1 = _objc_msgSend(pvVar1,sel_currentFilenameForSelection);
  if (pvVar1 != (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_filteredItems,pvVar2);
    pvVar2 = _objc_msgSend(self,sel_currentMediaPathsLocation);
    pvVar3 = _objc_msgSend(self,sel_tableViewDataSource);
    pvVar3 = _objc_msgSend(pvVar3,sel_currentFilenameForSelection);
    pvVar2 = _objc_msgSend(pvVar2,sel_stringByAppendingPathComponent_,pvVar3);
    pvVar3 = _objc_msgSend(pvVar1,sel_indexOfObject_,pvVar2);
    if (pvVar3 != (id)0x7fffffff) {
      if (((self->super)._sortAscending == '\0') && ((self->super)._sortedIdentifier != (id)0x0)) {
        pvVar1 = _objc_msgSend(pvVar1,sel_count,pvVar2);
        pvVar3 = (id)((int)pvVar1 + ~(uint)pvVar3);
      }
      pvVar1 = (self->super)._soundsTableView;
      pvVar2 = _objc_msgSend(cls_NSIndexSet,sel_indexSetWithIndex_,pvVar3);
      _objc_msgSend(pvVar1,sel_selectRowIndexes_byExtendingSelection_,pvVar2,0);
      _objc_msgSend((self->super)._soundsTableView,sel_scrollRowToVisible_,pvVar3);
    }
  }
  return;
}

*/
- (void)reloadMediaPaths
{
    id location = [self currentMediaPathsLocation];
    id items;
    NSUInteger index;
    if (location != nil) {
        [_mediaPathDictionary removeObjectForKey:location];
    }
    [_mediaDurationsHash release];
    _mediaDurationsHash = nil;
    [self updateFilteredMedia];
    [_itemsCountTextField setStringValue:[NSString stringWithFormat:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"%dItems" value:@"" table:@"ImportDialogs"], (int)[_filteredItems count]]];
    [_soundsTableView reloadData];
    if ([[self tableViewDataSource] currentFilenameForSelection] == nil) {
        return;
    }
    items = [self filteredItems];
    index = [items indexOfObject:[[self currentMediaPathsLocation] stringByAppendingPathComponent:[[self tableViewDataSource] currentFilenameForSelection]]];
    if (index == NSNotFound) {
        return;
    }
    if (!_sortAscending && _sortedIdentifier != nil) {
        index = [items count] - 1 - index;
    }
    [_soundsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
    [_soundsTableView scrollRowToVisible:index];
}

- (void)tvDataSourceSelectionDidChange:(id)aChange
{
    id pvVar1;
    id pvVar2;

    [_mediaDurationsHash release];
    _mediaDurationsHash = nil;
    [self invalidateMediaPaths];
    if (_switchingHistory == NO) {
        pvVar1 = [self primaryHistory];
        pvVar2 = [self currentMediaPathsLocation];
        if (![[pvVar1 lastObject] isEqualToString:pvVar2]) {
            [pvVar1 addObject:pvVar2];
            [_secondaryHistory release];
            _secondaryHistory = nil;
            [self validateHistoryNavigationControl];
        }
    }
    [self setFilePath:[self paneFilePath]];
    [self updatePreviewMovie];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001bafe2 @ 001bafe2, 674 bytes * /

id FUN_001bafe2(HSImportDialogSoundImportedPaneViewController *self,SEL _cmd,
               id createMediaPathsForKey)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id self_01;
  id pvVar3;
  id pvVar4;
  id self_02;
  id pvVar5;
  undefined4 local_18;
  
  pvVar1 = _objc_msgSend(cls_NSString,sel_class);
  pvVar2 = _objc_msgSend(createMediaPathsForKey,sel_isKindOfClass_,pvVar1);
  if (((char)pvVar2 != '\0') && (createMediaPathsForKey != (id)0x0)) {
    pvVar2 = _objc_msgSend(self,sel_supportedMediaTypes,pvVar1);
    self_01 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
    pvVar1 = createMediaPathsForKey;
    pvVar3 = _objc_msgSend(self_01,sel_directoryContentsAtPath_,createMediaPathsForKey);
    pvVar3 = _objc_msgSend(pvVar3,sel_objectEnumerator);
    pvVar4 = _objc_msgSend(pvVar3,sel_nextObject);
    if (pvVar4 != (id)0x0) {
      local_18 = (id)0x0;
      do {
        self_02 = _objc_msgSend(cls_NSAutoreleasePool,sel_new,pvVar1);
        pvVar1 = _objc_msgSend(createMediaPathsForKey,sel_stringByAppendingPathComponent_,pvVar4);
        pvVar4 = _objc_msgSend(pvVar1,sel_stringByResolvingSymlinksInPath);
        pvVar1 = _objc_msgSend(self_01,sel_hyperFileTypeAtPath_,pvVar4);
        pvVar1 = _objc_msgSend(pvVar2,sel_containsObject_,pvVar1);
        if ((char)pvVar1 == '\0') {
          pvVar1 = pvVar4;
          pvVar5 = _objc_msgSend(self_01,sel_hyperResolveAliasAtPath_,pvVar4);
          if (pvVar5 != (id)0x0) {
            pvVar1 = _objc_msgSend(pvVar5,sel_length,pvVar1);
            if (pvVar1 != (id)0x0) {
              pvVar4 = pvVar5;
            }
          }
        }
        pvVar1 = _objc_msgSend(self_01,sel_hyperFileTypeAtPath_,pvVar4);
        pvVar5 = _objc_msgSend(pvVar2,sel_containsObject_,pvVar1);
        if ((char)pvVar5 != '\0') {
          pvVar1 = pvVar4;
          pvVar5 = _objc_msgSend(self_01,sel_hyperIsFileInvisibleAtPath_,pvVar4);
          self_00 = cls_NSMutableArray;
          if ((char)pvVar5 == '\0') {
            if (local_18 == (id)0x0) {
              pvVar1 = _objc_msgSend(self,sel_zone,pvVar1);
              pvVar1 = _objc_msgSend(self_00,sel_allocWithZone_,pvVar1);
              local_18 = _objc_msgSend(pvVar1,sel_initWithCapacity_,0);
            }
            _objc_msgSend(local_18,sel_addObject_,pvVar4);
            pvVar1 = pvVar4;
          }
        }
        _objc_msgSend(self_02,sel_release,pvVar1);
        pvVar4 = _objc_msgSend(pvVar3,sel_nextObject);
      } while (pvVar4 != (id)0x0);
      goto LAB_001bb267;
    }
  }
  local_18 = (id)0x0;
LAB_001bb267:
  pvVar1 = _objc_msgSend(local_18,sel_autorelease,pvVar1);
  return pvVar1;
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
            NSAutoreleasePool *pool = [NSAutoreleasePool new];
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
                    paths = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:0];
                }
                [paths addObject:path];
            }
            [pool release];
        }
    }
    return [paths autorelease];
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
/* FUN_001bae3d @ 001bae3d, 112 bytes * /

void FUN_001bae3d(HSImportDialogSoundImportedPaneViewController *self,SEL _cmd,id switchHistoryTo)

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
    }
    else if (segment == 0) {
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

/* --- i386 decompilation (Ghidra) ---
/* FUN_001bac15 @ 001bac15, 141 bytes * /

id FUN_001bac15(HSImportDialogSoundImportedPaneViewController *self,SEL _cmd)

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
        row = [_filteredItems count] - 1 - row;
    }
    return [_filteredItems objectAtIndex:row];
}

- (void)paneDialogWillOpen
{
    _cancelAllThreads = NO;
    [super paneDialogWillOpen];
    if ([_paneView superview] != nil) {
        [self fileOrFolderStructureMightDidChange];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:NSApplicationDidBecomeActiveNotification object:NSApp];
}

- (void)paneDialogWillClose
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidBecomeActiveNotification object:0];
    _cancelAllThreads = YES;
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
    return @"HSImportDialogImportedSound";
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001bc98c @ 001bc98c, 519 bytes * /

void FUN_001bc98c(HSImportDialogSoundImportedPaneViewController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  HSImportDialogSoundImportedPaneViewController *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSImportDialogSoundPaneViewContr_00353750;
  _objc_msgSendSuper(&local_1c,sel_awakeFromNib);
  pvVar1 = _objc_msgSend(self,sel_tableViewDataSource);
  _objc_msgSend(pvVar1,sel_configureTableView_,(self->super)._browseTableView);
  _objc_msgSend((self->super)._browseTableView,sel_setDataSource_,pvVar1);
  _objc_msgSend((self->super)._browseTableView,sel_setDelegate_,pvVar1);
  pvVar1 = (self->super)._browseTableView;
  pvVar2 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,*(undefined4 *)PTR_00336414);
  _objc_msgSend(pvVar1,sel_registerForDraggedTypes_,pvVar2);
  _objc_msgSend((self->super)._soundsTableView,sel_setGridStyleMask_,0);
  pvVar1 = _objc_msgSend(cls_NSParagraphStyle,sel_hyperParagraphStyleWithLineBreakMode_,4);
  _objc_msgSend((self->super)._lineBreakInfo,sel_release);
  pvVar2 = _objc_msgSend(cls_NSDictionary,sel_alloc);
  pvVar1 = _objc_msgSend(pvVar2,sel_initWithObjectsAndKeys_,pvVar1,*(undefined4 *)PTR_00336150,0);
  (self->super)._lineBreakInfo = pvVar1;
  _objc_msgSend((self->super)._historyNavigationControl,sel_setLabel_forSegment_,0,0);
  _objc_msgSend((self->super)._historyNavigationControl,sel_setLabel_forSegment_,0,1);
  _objc_msgSend(self,sel_validateHistoryNavigationControl);
  _objc_msgSend(self,sel_tvDataSourceSelectionDidChange_,0);
  return;
}

*/
- (void)awakeFromNib
{
    id dataSource;
    [super awakeFromNib];
    dataSource = [self tableViewDataSource];
    [dataSource configureTableView:_browseTableView];
    [_browseTableView setDataSource:dataSource];
    [_browseTableView setDelegate:dataSource];
    [_browseTableView registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
    [_soundsTableView setGridStyleMask:NSTableViewGridNone];
    [_lineBreakInfo release];
    _lineBreakInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSParagraphStyle hyperParagraphStyleWithLineBreakMode:NSLineBreakByTruncatingTail], NSParagraphStyleAttributeName, nil];
    [_historyNavigationControl setLabel:@"" forSegment:0];
    [_historyNavigationControl setLabel:@"" forSegment:1];
    [self validateHistoryNavigationControl];
    [self tvDataSourceSelectionDidChange:nil];
}

- (void)dealloc
{
    id pvVar1;
    id pvVar3;
    HSImportDialogSoundImportedPaneViewController *pHVar4;

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
    [_predefinedSoundLocations release];
    [_primaryHistory release];
    [_secondaryHistory release];
    [_mediaDurationsHash release];
    [_locationForThreads release];
    [super dealloc];
}

@end

