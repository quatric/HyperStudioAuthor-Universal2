#import "HSLibraryController.h"

static HSLibraryController *sSharedLibraryController = nil;

/* Messages the library view containers answer. */
@protocol HSLibraryViewContainerMessages <NSObject>
- (NSUInteger)numberOfItems;
- (void)filter:(id)aFilter byCategory:(id)aCategory;
@end

/* Orders library types by plugin weight, then by name. */
static NSInteger HSCompareLibraryTypes(id aType, id aType2, void *aContext)
{
    NSInteger weight = [(id<HSLibraryPlugin>)[[HSLibraryManager sharedLibraryManager] pluginForLibraryType:aType] weight];
    NSInteger weight2 = [(id<HSLibraryPlugin>)[[HSLibraryManager sharedLibraryManager] pluginForLibraryType:aType2] weight];
    if (weight > weight2) {
        return NSOrderedDescending;
    }
    if (weight < weight2) {
        return NSOrderedAscending;
    }
    return [aType compare:aType2];
}

@implementation HSLibraryController

/* i386 ivar offsets: _mainView=0x28, _segmentedControl=0x2c, _statusBarImage=0x30, _playButton=0x34, _searchField=0x38, _infoTextField=0x3c, _selectedToolbarItem=0x40, _selectedSearchCategory=0x44, _libraryPanels=0x48, _activeViewContainer=0x4c, _playButtonImage=0x50, _playButtonAquaImage=0x54, _playButtonGraphiteImage=0x58, _stopButtonImage=0x5c, _stopButtonAquaImage=0x60, _stopButtonGraphiteImage=0x64, _playButtonCell=0x68, _storedVisibilityStates=0x6c */

/* --- i386 decompilation (Ghidra) ---
/* FUN_000de789 @ 000de789, 224 bytes * /

id FUN_000de789(id self,SEL _cmd,NSZone *allocWithZone)

{
  bool bVar1;
  int iVar2;
  id unaff_EBX;
  id local_7c;
  undefined *local_78;
  int local_74 [23];
  NSZone *local_18;
  id local_14;
  
  local_14 = self;
  local_18 = allocWithZone;
  _objc_sync_enter(self);
  _objc_exception_try_enter(local_74);
  iVar2 = __setjmp(local_74);
  if (iVar2 == 0) {
    if (DAT_00342910 == (id)0x0) {
      local_7c = local_14;
      local_78 = PTR_s_NSWindowController_003596f0;
      unaff_EBX = _objc_msgSendSuper(&local_7c,sel_allocWithZone_,local_18);
      iVar2 = 0;
      bVar1 = false;
      DAT_00342910 = unaff_EBX;
    }
    else {
      bVar1 = true;
      iVar2 = 0;
      unaff_EBX = (id)0x0;
    }
  }
  else {
    iVar2 = _objc_exception_extract(local_74);
    if (iVar2 != 0) {
      bVar1 = true;
      goto LAB_000de83e;
    }
    bVar1 = true;
    unaff_EBX = (id)0x0;
  }
  _objc_exception_try_exit(local_74);
LAB_000de83e:
  _objc_sync_exit(self);
  if (iVar2 != 0) {
                    /* WARNING: Subroutine does not return * /
    _objc_exception_throw(iVar2);
  }
  if (bVar1) {
    unaff_EBX = (id)0x0;
  }
  return unaff_EBX;
}

*/
+ (id)allocWithZone:(NSZone *)aZone
{
    @synchronized (self) {
        if (sSharedLibraryController == nil) {
            sSharedLibraryController = [super allocWithZone:aZone];
            return sSharedLibraryController;
        }
    }
    return nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000de869 @ 000de869, 175 bytes * /

id FUN_000de869(id self,SEL _cmd)

{
  int iVar1;
  id self_00;
  int local_6c [22];
  id local_14;
  
  local_14 = self;
  _objc_sync_enter(self);
  _objc_exception_try_enter(local_6c);
  iVar1 = __setjmp(local_6c);
  if (iVar1 == 0) {
    if (DAT_00342910 == (id)0x0) {
      self_00 = _objc_msgSend(local_14,sel_alloc);
      _objc_msgSend(self_00,sel_init);
    }
    iVar1 = 0;
  }
  else {
    iVar1 = _objc_exception_extract(local_6c);
    if (iVar1 != 0) goto LAB_000de8f1;
  }
  _objc_exception_try_exit(local_6c);
LAB_000de8f1:
  _objc_sync_exit(self);
  if (iVar1 != 0) {
                    /* WARNING: Subroutine does not return * /
    _objc_exception_throw(iVar1);
  }
  return DAT_00342910;
}

*/
+ (id)sharedLibraryController
{
    @synchronized (self) {
        if (sSharedLibraryController == nil) {
            [[self alloc] init];
        }
    }
    return sSharedLibraryController;
}

+ (id)visibilityKeyForDefaults
{
    return [NSString stringWithFormat:@"%@Visible", (NSStringFromClass([self class]))];
}

- (BOOL)windowShouldOrderFrontRespectingLastVisibilityState:(id)aState
{
    BOOL BVar1;

    if ([[self storedVisibilityStates] count] == 0) {
        BVar1 = NO;
    }
    else {
        BVar1 = (BOOL)[[[self storedVisibilityStates] lastObject] boolValue];
        [[self storedVisibilityStates] removeObjectAtIndex:(int)[[self storedVisibilityStates] count] + -1];
    }
    return BVar1;
}

- (void)windowWillHideWithSavingVisibilityState:(id)aState
{
    [self stopPlaying];
    [[self storedVisibilityStates] addObject:[NSNumber numberWithBool:(unsigned int)[self isLibraryVisible] & 0xff]];
}

- (id)storedVisibilityStates
{
    id pvVar1;

    pvVar1 = _storedVisibilityStates;
    if (pvVar1 == nil) {
        pvVar1 = [NSMutableArray new];
        _storedVisibilityStates = pvVar1;
    }
    return pvVar1;
}

- (id)windowWillReturnUndoManager:(id)aManager
{
    return [[[[[NSDocumentController sharedDocumentController] currentDocument] currentWindowController] queryHyperInterface:@protocol(HSPreferedUndoManagerOwner)] preferedUndoManager];
}

- (BOOL)validateMenuItem:(id)aItem
{
    id self_00;
    int uVar2;

    self_00 = [aItem representedObject];
    if ((![self_00 isEqualToString:_selectedSearchCategory]) && (self_00 != _selectedSearchCategory)) {
        uVar2 = 0;
    }
    else {
        uVar2 = 1;
    }
    [aItem setState:uVar2];
    return YES;
}

- (void)segmentedControlDidChange:(id)aChange
{
    [self updatePanels];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000de26b @ 000de26b, 105 bytes * /

void FUN_000de26b(HSLibraryController *self,SEL _cmd,id libraryPlayingStateDidChange)

{
  id pvVar1;
  undefined *puVar2;
  
  puVar2 = sel_isPlaying;
  pvVar1 = _objc_msgSend(self->_activeViewContainer,sel_respondsToSelector_,sel_isPlaying);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(self->_activeViewContainer,sel_isPlaying,puVar2);
    _objc_msgSend(self,sel_setImagesForPlayButton_,(int)(char)pvVar1);
  }
  return;
}

*/
- (void)libraryPlayingStateDidChange:(id)aChange
{
    if ([_activeViewContainer respondsToSelector:@selector(isPlaying)]) {
        [self setImagesForPlayButton:[(id)_activeViewContainer isPlaying]];
    }
}

- (void)libraryNumberOfItemsDidChange:(id)aChange
{
    [self updateInfoTextField];
}

- (void)setImagesForPlayButton:(BOOL)aButton
{
    id self_00;
    id pvVar1;

    if (aButton == NO) {
        [_playButton setImage:_playButtonImage];
        [_playButtonCell setAquaAlternateImage:_playButtonAquaImage];
        pvVar1 = _playButtonGraphiteImage;
        self_00 = _playButtonCell;
    }
    else {
        [_playButton setImage:_stopButtonImage];
        [_playButtonCell setAquaAlternateImage:_stopButtonAquaImage];
        pvVar1 = _stopButtonGraphiteImage;
        self_00 = _playButtonCell;
    }
    [self_00 setGraphiteAlternateImage:pvVar1];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000de04e @ 000de04e, 311 bytes * /

void FUN_000de04e(HSLibraryController *self,SEL _cmd)

{
  undefined *self_00;
  cfstringStruct *pcVar1;
  id pvVar2;
  undefined *self_01;
  cfstringStruct *pcVar3;
  SEL op;
  cfstringStruct *pcVar4;
  
  pcVar1 = _objc_msgSend(self->_activeViewContainer,sel_numberOfItems);
  self_01 = cls_NSString;
  self_00 = cls_NSBundle;
  if (pcVar1 == (cfstringStruct *)0x1) {
    pvVar2 = _objc_msgSend(self,sel_class);
    self_01 = _objc_msgSend(self_00,sel_bundleForClass_,pvVar2);
    pcVar4 = &cfstr_Library;
    pcVar1 = &cfstr_empty;
    pcVar3 = &cfstr_filterOneItem;
    op = sel_localizedStringForKey_value_table_;
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_class);
    pvVar2 = _objc_msgSend(self_00,sel_bundleForClass_,pvVar2);
    pcVar4 = &cfstr_Library;
    pcVar3 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_filterManyItems,
                           &cfstr_empty,&cfstr_Library);
    op = sel_stringWithFormat_;
  }
  pvVar2 = _objc_msgSend(self_01,op,pcVar3,pcVar1,pcVar4);
  _objc_msgSend(self->_infoTextField,sel_setStringValue_,pvVar2);
  return;
}

*/
- (void)updateInfoTextField
{
    NSInteger count = [(id<HSLibraryViewContainerMessages>)_activeViewContainer numberOfItems];
    NSString *info;
    if (count == 1) {
        info = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"filterOneItem" value:@"" table:@"Library"];
    } else {
        info = [NSString stringWithFormat:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"filterManyItems" value:@"" table:@"Library"], count];
    }
    [_infoTextField setStringValue:info];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000dde74 @ 000dde74, 474 bytes * /

void FUN_000dde74(HSLibraryController *self,SEL _cmd,id filter)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  undefined *puVar4;
  
  pvVar1 = _objc_msgSend(cls_HSLibraryManager,sel_sharedLibraryManager);
  pvVar1 = _objc_msgSend(pvVar1,sel_pluginForLibraryType_,self->_selectedToolbarItem);
  puVar4 = &DAT_0036c53c;
  pvVar2 = _objc_msgSend(pvVar1,sel_conformsToProtocol_,&DAT_0036c53c);
  if ((char)pvVar2 != '\0') {
    pvVar1 = _objc_msgSend(pvVar1,sel_isSearchable,puVar4);
    if ((char)pvVar1 != '\0') {
      puVar4 = sel_filter_byCategory_;
      pvVar1 = _objc_msgSend(self->_activeViewContainer,sel_respondsToSelector_,
                             sel_filter_byCategory_);
      if ((char)pvVar1 == '\0') {
        puVar4 = sel_filter_;
        pvVar1 = _objc_msgSend(self->_activeViewContainer,sel_respondsToSelector_,sel_filter_);
        if ((char)pvVar1 == '\0') goto LAB_000de031;
        pvVar1 = self->_activeViewContainer;
        op = sel_filter_;
      }
      else {
        pvVar2 = _objc_msgSend(cls_NSMenuItem,sel_class,puVar4);
        pvVar1 = _objc_msgSend(filter,sel_isKindOfClass_,pvVar2);
        if ((char)pvVar1 != '\0') {
          pvVar1 = self->_selectedSearchCategory;
          pvVar3 = _objc_msgSend(filter,sel_representedObject,pvVar2);
          if (pvVar1 != pvVar3) {
            _objc_msgSend(self->_selectedSearchCategory,sel_release,pvVar2);
            pvVar1 = _objc_msgSend(filter,sel_representedObject);
            pvVar1 = _objc_msgSend(pvVar1,sel_retain);
            self->_selectedSearchCategory = pvVar1;
          }
        }
        pvVar1 = self->_activeViewContainer;
        filter = _objc_msgSend(self->_searchField,sel_stringValue,pvVar2);
        op = sel_filter_byCategory_;
      }
      _objc_msgSend(pvVar1,op,filter);
      puVar4 = filter;
    }
  }
LAB_000de031:
  _objc_msgSend(self,sel_updateInfoTextField,puVar4);
  return;
}

*/
- (void)filter:(id)aFilter
{
    id plugin = [[HSLibraryManager sharedLibraryManager] pluginForLibraryType:_selectedToolbarItem];
    if ([plugin conformsToProtocol:@protocol(HSLibraryMediaPlugin)] && [plugin isSearchable]) {
        if ([_activeViewContainer respondsToSelector:@selector(filter:byCategory:)]) {
            if ([aFilter isKindOfClass:[NSMenuItem class]] && _selectedSearchCategory != [aFilter representedObject]) {
                [_selectedSearchCategory release];
                _selectedSearchCategory = [[aFilter representedObject] retain];
            }
            [(id<HSLibraryViewContainerMessages>)_activeViewContainer filter:[_searchField stringValue] byCategory:_selectedSearchCategory];
        } else if ([_activeViewContainer respondsToSelector:@selector(filter:)]) {
            [(id)_activeViewContainer filter:aFilter];
        }
    }
    [self updateInfoTextField];
}

- (void)stopPlaying
{
    if ([_activeViewContainer conformsToProtocol:@protocol(HSLibraryMediaViewContainer)]) {
        if ([_activeViewContainer isPlaying]) {
            [_activeViewContainer stopPlaying];
        }
    }
}

- (void)playSelection:(id)aSelection
{
    if ([_activeViewContainer respondsToSelector:@selector(playSelection:)]) {
        [_activeViewContainer playSelection:aSelection];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000de970 @ 000de970, 1716 bytes * /

void FUN_000de970(HSLibraryController *self,SEL _cmd,id panelSwitched)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  undefined4 *puVar5;
  undefined1 local_24 [20];
  
  puVar5 = (undefined4 *)&stack0xffffffa4;
  pvVar1 = _objc_msgSend(self->_activeViewContainer,sel_conformsToProtocol_);
  if (((char)pvVar1 != '\0') &&
     (pvVar1 = _objc_msgSend(self->_activeViewContainer,sel_isPlaying), (char)pvVar1 != '\0')) {
    _objc_msgSend(self->_activeViewContainer,sel_stopPlaying);
  }
  pvVar1 = _objc_msgSend(panelSwitched,sel_selectedCell);
  _objc_msgSend(pvVar1,sel_tag);
  _objc_msgSend(self,sel_setActivePanelTag_forPluginIdentifier_);
  pvVar1 = _objc_msgSend(self->_libraryPanels,sel_objectForKey_);
  pvVar2 = _objc_msgSend(panelSwitched,sel_selectedCell);
  _objc_msgSend(pvVar2,sel_tag);
  pvVar1 = _objc_msgSend(pvVar1,sel_extraObjectAtIndex_);
  pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar2,sel_removeObserver_name_object_);
  pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar2,sel_removeObserver_name_object_);
  _objc_msgSend(self->_activeViewContainer,sel_release);
  pvVar2 = _objc_msgSend(pvVar1,sel_libraryViewContainer);
  pvVar2 = _objc_msgSend(pvVar2,sel_retain);
  self->_activeViewContainer = pvVar2;
  pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar2,sel_addObserver_selector_name_object_);
  pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar2,sel_addObserver_selector_name_object_);
  pvVar2 = _objc_msgSend(self->_activeViewContainer,sel_libraryView);
  if (pvVar2 != (id)0x0) {
    _objc_msgSend_stret(local_24,self->_mainView,sel_bounds);
    puVar5 = (undefined4 *)&stack0xffffffa0;
    _objc_msgSend(pvVar2,sel_setFrameSize_);
    _objc_msgSend(self->_mainView,sel_setContentView_);
    _objc_msgSend(pvVar2,sel_setAutoresizingMask_);
    pvVar2 = _objc_msgSend(self,sel_window);
    _objc_msgSend(pvVar2,sel_recalculateKeyViewLoop);
    self_00 = cls_NSBundle;
    _objc_msgSend(self,sel_class);
    pvVar2 = _objc_msgSend(self_00,sel_bundleForClass_);
    _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_);
    pvVar2 = _objc_msgSend(cls_NSMenuItem,sel_alloc);
    pvVar2 = _objc_msgSend(pvVar2,sel_initWithTitle_action_keyEquivalent_);
    _objc_msgSend(pvVar2,sel_setTarget_);
    _objc_msgSend(pvVar2,sel_setRepresentedObject_);
    _objc_msgSend(self->_selectedSearchCategory,sel_release);
    pvVar3 = _objc_msgSend(pvVar2,sel_representedObject);
    pvVar3 = _objc_msgSend(pvVar3,sel_retain);
    self->_selectedSearchCategory = pvVar3;
    pvVar3 = _objc_msgSend(cls_NSMenu,sel_alloc);
    pvVar3 = _objc_msgSend(pvVar3,sel_init);
    _objc_msgSend(pvVar3,sel_setDelegate_);
    _objc_msgSend(pvVar3,sel_insertItem_atIndex_);
    _objc_msgSend(pvVar2,sel_release);
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_);
    pvVar2 = _objc_msgSend(pvVar1,sel_searchCategories);
    pvVar2 = _objc_msgSend(pvVar2,sel_objectEnumerator);
    pvVar4 = _objc_msgSend(pvVar2,sel_nextObject);
    while (pvVar4 != (id)0x0) {
      _objc_msgSend(pvVar1,sel_displayStringForCategory_);
      pvVar4 = _objc_msgSend(cls_NSMenuItem,sel_alloc);
      pvVar4 = _objc_msgSend(pvVar4,sel_initWithTitle_action_keyEquivalent_);
      _objc_msgSend(pvVar4,sel_setTarget_);
      _objc_msgSend(pvVar4,sel_setRepresentedObject_);
      _objc_msgSend(pvVar3,sel_addItem_);
      _objc_msgSend(pvVar4,sel_release);
      pvVar4 = _objc_msgSend(pvVar2,sel_nextObject);
    }
    pvVar1 = _objc_msgSend(self->_searchField,sel_cell);
    _objc_msgSend(pvVar1,sel_setSearchMenuTemplate_);
    _objc_msgSend(pvVar3,sel_release);
    _objc_msgSend(self,sel_filter_);
  }
  puVar5[-1] = 0xdec23;
  _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
  return;
}

*/
- (void)panelSwitched:(id)aSwitched
{
    if ([_activeViewContainer conformsToProtocol:@protocol(HSLibraryMediaViewContainer)] && [(id)_activeViewContainer isPlaying]) {
        [(id)_activeViewContainer stopPlaying];
    }
    [self setActivePanelTag:[[aSwitched selectedCell] tag] forPluginIdentifier:_selectedToolbarItem];
    id panel = [[_libraryPanels objectForKey:_selectedToolbarItem] extraObjectAtIndex:[[aSwitched selectedCell] tag]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HSLibraryNumberOfItemsDidChangeNotification object:_activeViewContainer];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HSLibraryPlayingStateDidChangeNotification object:_activeViewContainer];
    [_activeViewContainer release];
    _activeViewContainer = [[panel libraryViewContainer] retain];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(libraryNumberOfItemsDidChange:) name:HSLibraryNumberOfItemsDidChangeNotification object:_activeViewContainer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(libraryPlayingStateDidChange:) name:HSLibraryPlayingStateDidChangeNotification object:_activeViewContainer];
    NSView *libraryView = [_activeViewContainer libraryView];
    if (libraryView == nil) {
        [_mainView setContentView:nil];
        return;
    }
    [libraryView setFrameSize:[_mainView bounds].size];
    [_mainView setContentView:libraryView];
    [libraryView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [[self window] recalculateKeyViewLoop];
    NSMenuItem *allItem = [[NSMenuItem alloc] initWithTitle:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"AllTypesCategoryName" value:@"" table:@"Library"] action:@selector(filter:) keyEquivalent:@""];
    [allItem setTarget:self];
    [allItem setRepresentedObject:nil];
    [_selectedSearchCategory release];
    _selectedSearchCategory = [[allItem representedObject] retain];
    NSMenu *menu = [[NSMenu alloc] init];
    [menu setDelegate:self];
    [menu insertItem:allItem atIndex:0];
    [allItem release];
    id filtering = [panel queryHyperInterface:@protocol(HSLibraryMediaFiltering)];
    for (id category in [filtering searchCategories]) {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[filtering displayStringForCategory:category] action:@selector(filter:) keyEquivalent:@""];
        [item setTarget:self];
        [item setRepresentedObject:category];
        [menu addItem:item];
        [item release];
    }
    [[_searchField cell] setSearchMenuTemplate:menu];
    [menu release];
    [self filter:_searchField];
    [_activeViewContainer containerDidMount];
}

- (void)pluginSwitched:(id)aSwitched
{
    [self switchToPluginWithLibraryType:[aSwitched itemIdentifier] panelType:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ddcd2 @ 000ddcd2, 153 bytes * /

id FUN_000ddcd2(HSLibraryController *self,SEL _cmd,id panelForType,id inPluginLibraryType)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  
  pvVar1 = _objc_msgSend(self->_libraryPanels,sel_objectForKey_,inPluginLibraryType);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectEnumerator);
  do {
    self_00 = _objc_msgSend(pvVar1,sel_nextObject,inPluginLibraryType);
    if (self_00 == (id)0x0) {
      return (id)0x0;
    }
    pvVar2 = _objc_msgSend(self_00,sel_panelType,inPluginLibraryType);
    inPluginLibraryType = panelForType;
    pvVar2 = _objc_msgSend(pvVar2,sel_isEqualToString_);
  } while ((char)pvVar2 == '\0');
  return self_00;
}

*/
- (id)panelForType:(id)aType inPluginLibraryType:(id)aType2
{
    for (id panel in [_libraryPanels objectForKey:aType2]) {
        if ([[panel panelType] isEqualToString:aType]) {
            return panel;
        }
    }
    return nil;
}

- (id)currentPluginLibraryPanel
{
    return [[_libraryPanels objectForKey:_selectedToolbarItem] extraObjectAtIndex:[[_segmentedControl selectedCell] tag]];
}

- (id)currentPluginLibraryPanelType
{
    return [[self currentPluginLibraryPanel] panelType];
}

- (id)currentPluginLibraryType
{
    return _selectedToolbarItem;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000df024 @ 000df024, 3175 bytes * /

void FUN_000df024(HSLibraryController *self,SEL _cmd,id switchToPluginWithLibraryType,id panelType)

{
  undefined *puVar1;
  undefined *puVar2;
  undefined *puVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  id pvVar8;
  id pvVar9;
  id pvVar10;
  id pvVar11;
  undefined4 extraout_EDX;
  ushort uVar12;
  float fVar13;
  double dVar14;
  undefined8 uVar15;
  undefined8 uVar16;
  undefined8 in_stack_ffffff5c;
  undefined4 uVar17;
  float local_6c;
  undefined1 local_64 [4];
  float local_60;
  float local_5c;
  undefined4 local_54;
  float local_50;
  undefined4 local_4c;
  float local_48;
  undefined4 local_44;
  undefined4 uStack_40;
  undefined8 local_3c;
  undefined4 local_34;
  float fStack_30;
  undefined4 local_2c;
  float fStack_28;
  undefined4 local_24;
  float fStack_20;
  undefined4 local_1c;
  float fStack_18;
  
  uVar15 = CONCAT44((int)((ulonglong)in_stack_ffffff5c >> 0x20),self->_selectedToolbarItem);
  pvVar4 = _objc_msgSend(switchToPluginWithLibraryType,sel_isEqualToString_,
                         self->_selectedToolbarItem);
  if ((char)pvVar4 != '\0') {
    pvVar4 = _objc_msgSend(self,sel_currentPluginLibraryPanelType,uVar15);
    uVar15 = CONCAT44((int)((ulonglong)uVar15 >> 0x20),panelType);
    pvVar4 = _objc_msgSend(pvVar4,sel_isEqualToString_,panelType);
    if ((char)pvVar4 != '\0') {
      return;
    }
  }
  _objc_msgSend(self->_selectedToolbarItem,sel_release,uVar15);
  pvVar4 = _objc_msgSend(switchToPluginWithLibraryType,sel_retain);
  self->_selectedToolbarItem = pvVar4;
  pvVar4 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  uVar17 = *(undefined4 *)PTR_003364e8;
  _objc_msgSend(pvVar4,sel_setObject_forKey_,self->_selectedToolbarItem);
  pvVar4 = _objc_msgSend(self->_libraryPanels,sel_objectForKey_,switchToPluginWithLibraryType);
  pvVar5 = _objc_msgSend(pvVar4,sel_count);
  _objc_msgSend(self->_segmentedControl,sel_setHidden_,(uint)((int)pvVar5 < 2));
  pvVar6 = _objc_msgSend(cls_HSLibraryManager,sel_sharedLibraryManager);
  pvVar6 = _objc_msgSend(pvVar6,sel_pluginForLibraryType_,switchToPluginWithLibraryType);
  uVar15 = CONCAT44(uVar17,&DAT_0036c53c);
  pvVar7 = _objc_msgSend(pvVar6,sel_conformsToProtocol_,&DAT_0036c53c);
  if ((char)pvVar7 == '\0') {
    uVar12 = 0x101;
  }
  else {
    pvVar7 = _objc_msgSend(pvVar6,sel_isPlayable,uVar15);
    pvVar8 = _objc_msgSend(pvVar6,sel_isSearchable);
    uVar12 = CONCAT11((char)pvVar8 == '\0',(char)pvVar7 == '\0');
  }
  uVar17 = (undefined4)((ulonglong)uVar15 >> 0x20);
  _objc_msgSend(self->_playButton,sel_setHidden_,uVar12 & 0xff);
  _objc_msgSend(self->_searchField,sel_setHidden_,uVar12 >> 8);
  _objc_msgSend(self->_searchField,sel_setStringValue_,&cfstr_empty);
  uVar15 = CONCAT44(uVar17,&DAT_0036c5b4);
  pvVar7 = _objc_msgSend(pvVar6,sel_conformsToProtocol_,&DAT_0036c5b4);
  if ((char)pvVar7 != '\0') {
    pvVar7 = self->_searchField;
    pvVar8 = _objc_msgSend(pvVar6,sel_librarySearchFieldTooltip,uVar15);
    _objc_msgSend(pvVar7,sel_setToolTip_,pvVar8);
    pvVar7 = self->_playButton;
    pvVar6 = _objc_msgSend(pvVar6,sel_libraryPlayButtonTooltip);
    _objc_msgSend(pvVar7,sel_setToolTip_,pvVar6);
  }
  _objc_msgSend_stret(&local_34,self->_statusBarImage,sel_frame);
  _objc_msgSend_stret(&local_44,self->_infoTextField,sel_frame);
  pvVar6 = _objc_msgSend(self->_playButton,sel_isHidden);
  if (((char)pvVar6 == '\0') ||
     (pvVar6 = _objc_msgSend(self->_searchField,sel_isHidden), (char)pvVar6 == '\0')) {
    fStack_28 = 33.0;
    uStack_40 = 0x41200000;
  }
  else {
    fStack_28 = 20.0;
    uStack_40 = 0x40400000;
  }
  _objc_msgSend(self->_statusBarImage,sel_setFrame_,CONCAT44(fStack_30,local_34),
                CONCAT44(fStack_28,local_2c));
  _objc_msgSend(self->_infoTextField,sel_setFrame_,CONCAT44(uStack_40,local_44),local_3c);
  _objc_msgSend(self->_statusBarImage,sel_setNeedsDisplay);
  _objc_msgSend(self->_infoTextField,sel_setNeedsDisplay);
  pvVar6 = _objc_msgSend(self->_mainView,sel_superview);
  _objc_msgSend_stret(&local_54,pvVar6,sel_frame);
  _objc_msgSend_stret(local_64,self->_segmentedControl,sel_frame);
  fVar13 = fStack_30 + fStack_28;
  local_6c = (local_50 + local_48) - fVar13;
  pvVar6 = _objc_msgSend(self->_segmentedControl,sel_isHidden);
  if ((char)pvVar6 == '\0') {
    local_6c = local_6c - ((fVar13 + local_6c) - local_60);
  }
  local_24 = local_54;
  local_1c = local_4c;
  fStack_18 = local_6c;
  uVar15 = CONCAT44(fVar13,local_54);
  uVar16 = CONCAT44(local_6c,local_4c);
  fStack_20 = fVar13;
  _objc_msgSend(self->_mainView,sel_setFrame_,uVar15,uVar16);
  if (1 < (int)pvVar5) {
    while (pvVar6 = _objc_msgSend(self->_segmentedControl,sel_numberOfColumns,uVar15,uVar16),
          (int)pvVar5 < (int)pvVar6) {
      pvVar6 = self->_segmentedControl;
      pvVar7 = _objc_msgSend(pvVar6,sel_numberOfColumns,uVar15,uVar16);
      uVar15 = CONCAT44((int)((ulonglong)uVar15 >> 0x20),(int)pvVar7 + -1);
      _objc_msgSend(pvVar6,sel_removeColumn_);
    }
    while( true ) {
      pvVar6 = _objc_msgSend(self->_segmentedControl,sel_numberOfColumns,uVar15,uVar16);
      if ((int)pvVar5 <= (int)pvVar6) break;
      _objc_msgSend(self->_segmentedControl,sel_addColumn);
    }
    _objc_msgSend(self->_segmentedControl,sel_cellSize);
    pvVar5 = _objc_msgSend(self->_segmentedControl,sel_numberOfColumns);
    _objc_msgSend(self->_segmentedControl,sel_setCellSize_,local_5c / (float)(int)pvVar5,
                  extraout_EDX);
    _objc_msgSend(self->_segmentedControl,sel_setNeedsDisplay);
    pvVar6 = _objc_msgSend(self->_segmentedControl,sel_cells);
    pvVar7 = _objc_msgSend(pvVar6,sel_objectEnumerator);
    pvVar5 = _objc_msgSend(pvVar7,sel_nextObject);
    puVar2 = PTR_00336394;
    puVar1 = PTR_00336068;
    while (pvVar5 != (id)0x0) {
      pvVar8 = _objc_msgSend(pvVar6,sel_indexOfObject_,pvVar5);
      _objc_msgSend(pvVar5,sel_setTag_,pvVar8);
      _objc_msgSend(pvVar5,sel_setTarget_,self);
      _objc_msgSend(pvVar5,sel_setAction_,sel_panelSwitched_);
      pvVar8 = _objc_msgSend(pvVar5,sel_tag);
      pvVar8 = _objc_msgSend(pvVar4,sel_objectAtIndex_,pvVar8);
      pvVar8 = _objc_msgSend(pvVar8,sel_panelIcon);
      puVar3 = cls_NSString;
      pvVar9 = _objc_msgSend(pvVar5,sel_tag);
      pvVar9 = _objc_msgSend(pvVar4,sel_objectAtIndex_,pvVar9);
      pvVar9 = _objc_msgSend(pvVar9,sel_panelTitle);
      pvVar9 = _objc_msgSend(puVar3,sel_stringWithFormat_,&cfstr____,pvVar9);
      puVar3 = cls_NSFont;
      dVar14 = _objc_msgSend_fpret(cls_NSFont,sel_systemFontSizeForControlSize_,1);
      pvVar10 = _objc_msgSend(puVar3,sel_controlContentFontOfSize_,(float)dVar14);
      pvVar11 = _objc_msgSend(cls_HSCenteredTextAttachmentCell,sel_alloc);
      pvVar11 = _objc_msgSend(pvVar11,sel_init);
      _objc_msgSend(pvVar11,sel_setImage_,pvVar8);
      _objc_msgSend(pvVar11,sel_centerCellForFont_,pvVar10);
      pvVar8 = _objc_msgSend(cls_NSTextAttachment,sel_alloc);
      pvVar8 = _objc_msgSend(pvVar8,sel_init);
      _objc_msgSend(pvVar8,sel_setAttachmentCell_,pvVar11);
      _objc_msgSend(pvVar11,sel_release);
      pvVar11 = _objc_msgSend(cls_NSAttributedString,sel_attributedStringWithAttachment_,pvVar8);
      _objc_msgSend(pvVar8,sel_release);
      pvVar8 = _objc_msgSend(cls_NSMutableAttributedString,sel_alloc);
      pvVar8 = _objc_msgSend(pvVar8,sel_initWithString_,pvVar9);
      pvVar9 = _objc_msgSend(pvVar8,sel_length);
      _objc_msgSend(pvVar8,sel_addAttribute_value_range_,*(undefined4 *)puVar1,pvVar10,0,pvVar9);
      pvVar9 = _objc_msgSend(cls_NSMutableAttributedString,sel_alloc);
      pvVar9 = _objc_msgSend(pvVar9,sel_initWithAttributedString_,pvVar11);
      _objc_msgSend(pvVar9,sel_appendAttributedString_,pvVar8);
      _objc_msgSend(pvVar8,sel_release);
      pvVar8 = _objc_msgSend(pvVar9,sel_length);
      _objc_msgSend(pvVar9,sel_setAlignment_range_,2,0,pvVar8);
      _objc_msgSend(pvVar5,sel_setAttributedTitle_,pvVar9);
      pvVar8 = _objc_msgSend(pvVar9,sel_mutableCopy);
      _objc_msgSend(pvVar8,sel_length);
      pvVar10 = _objc_msgSend(cls_NSColor,sel_whiteColor);
      _objc_msgSend(pvVar8,sel_addAttribute_value_range_,*(undefined4 *)puVar2,pvVar10,0);
      _objc_msgSend(pvVar5,sel_setAttributedAlternateTitle_,pvVar8);
      _objc_msgSend(pvVar8,sel_release);
      _objc_msgSend(pvVar9,sel_release);
      pvVar8 = self->_segmentedControl;
      pvVar9 = _objc_msgSend(pvVar5,sel_tag);
      pvVar9 = _objc_msgSend(pvVar4,sel_objectAtIndex_,pvVar9);
      pvVar9 = _objc_msgSend(pvVar9,sel_panelToolTip);
      _objc_msgSend(pvVar8,sel_setToolTip_forCell_,pvVar9);
      pvVar8 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
      pvVar8 = _objc_msgSend(pvVar8,sel_localizedStringForKey_value_table_,&cfstr_tab);
      _objc_msgSend(pvVar5,sel_accessibilitySetOverrideValue_forAttribute_,pvVar8);
      pvVar5 = _objc_msgSend(pvVar7,sel_nextObject);
    }
  }
  if ((panelType == (id)0x0) ||
     (pvVar4 = _objc_msgSend(self,sel_tagOfPanelWithType_forPluginIdentifier_,panelType,
                             switchToPluginWithLibraryType), pvVar4 == (id)0xffffffff)) {
    pvVar4 = _objc_msgSend(self,sel_activePanelTagForPluginIdentifier_,switchToPluginWithLibraryType
                          );
  }
  _objc_msgSend(self->_segmentedControl,sel_selectCellWithTag_,pvVar4);
  _objc_msgSend(self,sel_panelSwitched_,self->_segmentedControl);
  _objc_msgSend(self,sel_updatePanels);
  pvVar4 = _objc_msgSend(self,sel_window);
  pvVar4 = _objc_msgSend(pvVar4,sel_toolbar);
  pvVar5 = _objc_msgSend(pvVar4,sel_selectedItemIdentifier);
  pvVar5 = _objc_msgSend(pvVar5,sel_isEqualToString_,switchToPluginWithLibraryType);
  if ((char)pvVar5 == '\0') {
    _objc_msgSend(pvVar4,sel_setSelectedItemIdentifier_,switchToPluginWithLibraryType);
  }
  return;
}

*/
- (void)switchToPluginWithLibraryType:(id)aType panelType:(id)aType2
{
    if ([aType isEqualToString:_selectedToolbarItem] && [[self currentPluginLibraryPanelType] isEqualToString:aType2]) {
        return;
    }
    [_selectedToolbarItem release];
    _selectedToolbarItem = [aType retain];
    [[NSUserDefaults standardUserDefaults] setObject:_selectedToolbarItem forKey:HSSelectedLibraryPluginKey];
    NSArray *panels = [_libraryPanels objectForKey:aType];
    NSInteger panelCount = [panels count];
    [_segmentedControl setHidden:panelCount < 2];
    id plugin = [[HSLibraryManager sharedLibraryManager] pluginForLibraryType:aType];
    BOOL hidePlayButton = YES;
    BOOL hideSearchField = YES;
    if ([plugin conformsToProtocol:@protocol(HSLibraryMediaPlugin)]) {
        hidePlayButton = ![plugin isPlayable];
        hideSearchField = ![plugin isSearchable];
    }
    [_playButton setHidden:hidePlayButton];
    [_searchField setHidden:hideSearchField];
    [_searchField setStringValue:@""];
    if ([plugin conformsToProtocol:@protocol(HSLibraryPluginControlsToolTip)]) {
        [_searchField setToolTip:[plugin librarySearchFieldTooltip]];
        [_playButton setToolTip:[plugin libraryPlayButtonTooltip]];
    }
    NSRect statusFrame = [_statusBarImage frame];
    NSRect infoFrame = [_infoTextField frame];
    if (![_playButton isHidden] || ![_searchField isHidden]) {
        statusFrame.size.height = 33;
        infoFrame.origin.y = 10;
    } else {
        statusFrame.size.height = 20;
        infoFrame.origin.y = 3;
    }
    [_statusBarImage setFrame:statusFrame];
    [_infoTextField setFrame:infoFrame];
    [_statusBarImage setNeedsDisplay:YES];
    [_infoTextField setNeedsDisplay:YES];
    NSRect containerFrame = [[_mainView superview] frame];
    NSRect segmentedFrame = [_segmentedControl frame];
    float bottom = (float)(statusFrame.origin.y + statusFrame.size.height);
    float height = (float)((containerFrame.origin.y + containerFrame.size.height) - bottom);
    if (![_segmentedControl isHidden]) {
        height = (float)(height - ((bottom + height) - segmentedFrame.origin.y));
    }
    [_mainView setFrame:NSMakeRect(containerFrame.origin.x, bottom, containerFrame.size.width, height)];
    if (panelCount > 1) {
        while (panelCount < [_segmentedControl numberOfColumns]) {
            [_segmentedControl removeColumn:[_segmentedControl numberOfColumns] - 1];
        }
        while ([_segmentedControl numberOfColumns] < panelCount) {
            [_segmentedControl addColumn];
        }
        NSSize cellSize = [_segmentedControl cellSize];
        [_segmentedControl setCellSize:NSMakeSize((float)(segmentedFrame.size.width / (float)[_segmentedControl numberOfColumns]), cellSize.height)];
        [_segmentedControl setNeedsDisplay:YES];
        NSArray *cells = [_segmentedControl cells];
        for (NSButtonCell *cell in cells) {
            [cell setTag:[cells indexOfObject:cell]];
            [cell setTarget:self];
            [cell setAction:@selector(panelSwitched:)];
            NSImage *icon = [[panels objectAtIndex:[cell tag]] panelIcon];
            NSString *title = [NSString stringWithFormat:@" %@", [[panels objectAtIndex:[cell tag]] panelTitle]];
            NSFont *font = [NSFont controlContentFontOfSize:[NSFont systemFontSizeForControlSize:NSControlSizeSmall]];
            HSCenteredTextAttachmentCell *attachmentCell = [[HSCenteredTextAttachmentCell alloc] init];
            [attachmentCell setImage:icon];
            [attachmentCell centerCellForFont:font];
            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            [attachment setAttachmentCell:attachmentCell];
            [attachmentCell release];
            NSAttributedString *iconString = [NSAttributedString attributedStringWithAttachment:attachment];
            [attachment release];
            NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:title];
            [titleString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [titleString length])];
            NSMutableAttributedString *fullTitle = [[NSMutableAttributedString alloc] initWithAttributedString:iconString];
            [fullTitle appendAttributedString:titleString];
            [titleString release];
            [fullTitle setAlignment:NSTextAlignmentCenter range:NSMakeRange(0, [fullTitle length])];
            [cell setAttributedTitle:fullTitle];
            NSMutableAttributedString *alternateTitle = [fullTitle mutableCopy];
            [alternateTitle addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:NSMakeRange(0, [alternateTitle length])];
            [cell setAttributedAlternateTitle:alternateTitle];
            [alternateTitle release];
            [fullTitle release];
            [_segmentedControl setToolTip:[[panels objectAtIndex:[cell tag]] panelToolTip] forCell:cell];
            [cell accessibilitySetOverrideValue:[[NSBundle mainBundle] localizedStringForKey:@"tab" value:@"" table:nil] forAttribute:NSAccessibilityRoleDescriptionAttribute];
        }
    }
    NSInteger tag = aType2 != nil ? [self tagOfPanelWithType:aType2 forPluginIdentifier:aType] : 0;
    if (aType2 == nil || tag == -1) {
        tag = [self activePanelTagForPluginIdentifier:aType];
    }
    [_segmentedControl selectCellWithTag:tag];
    [self panelSwitched:_segmentedControl];
    [self updatePanels];
    NSToolbar *toolbar = [[self window] toolbar];
    if (![[toolbar selectedItemIdentifier] isEqualToString:aType]) {
        [toolbar setSelectedItemIdentifier:aType];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000dda66 @ 000dda66, 445 bytes * /

void FUN_000dda66(HSLibraryController *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  id self_01;
  id pvVar2;
  id pvVar3;
  
  pvVar1 = _objc_msgSend(self->_segmentedControl,sel_cells);
  self_00 = _objc_msgSend(pvVar1,sel_objectEnumerator);
  self_01 = _objc_msgSend(self_00,sel_nextObject);
  pvVar1 = self->_selectedToolbarItem;
  pvVar3 = self->_libraryPanels;
  while( true ) {
    pvVar3 = _objc_msgSend(pvVar3,sel_objectForKey_,pvVar1);
    if (self_01 == (id)0x0) break;
    pvVar3 = _objc_msgSend(pvVar3,sel_count,pvVar1);
    pvVar2 = _objc_msgSend(self_01,sel_tag);
    if (pvVar2 < pvVar3) {
      pvVar1 = _objc_msgSend(self->_libraryPanels,sel_objectForKey_,self->_selectedToolbarItem);
      pvVar3 = _objc_msgSend(self_01,sel_tag);
      pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,pvVar3);
      pvVar1 = _objc_msgSend(pvVar1,sel_isPaneValid);
      pvVar1 = (id)(int)(char)pvVar1;
      _objc_msgSend(self_01,sel_setEnabled_,pvVar1);
    }
    self_01 = _objc_msgSend(self_00,sel_nextObject,pvVar1);
    pvVar1 = self->_selectedToolbarItem;
    pvVar3 = self->_libraryPanels;
  }
  pvVar1 = _objc_msgSend(self->_segmentedControl,sel_selectedCell,pvVar1);
  pvVar1 = _objc_msgSend(pvVar1,sel_tag);
  pvVar3 = _objc_msgSend(pvVar3,sel_objectAtIndex_,pvVar1);
  pvVar3 = _objc_msgSend(pvVar3,sel_isPaneValid);
  if ((char)pvVar3 == '\0') {
    _objc_msgSend(self,sel_switchToNextAccessiblePanel,pvVar1);
  }
  return;
}

*/
- (void)updatePanels
{
    NSArray *panels = [_libraryPanels objectForKey:_selectedToolbarItem];
    for (NSCell *cell in [_segmentedControl cells]) {
        panels = [_libraryPanels objectForKey:_selectedToolbarItem];
        if ((NSUInteger)[cell tag] < [panels count]) {
            [cell setEnabled:[[[_libraryPanels objectForKey:_selectedToolbarItem] objectAtIndex:[cell tag]] isPaneValid]];
        }
    }
    panels = [_libraryPanels objectForKey:_selectedToolbarItem];
    if (![[panels objectAtIndex:[[_segmentedControl selectedCell] tag]] isPaneValid]) {
        [self switchToNextAccessiblePanel];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000dd954 @ 000dd954, 274 bytes * /

BOOL FUN_000dd954(HSLibraryController *self,SEL _cmd)

{
  BOOL BVar1;
  id pvVar2;
  id self_00;
  id self_01;
  id pvVar3;
  id self_02;
  
  pvVar2 = _objc_msgSend(self->_segmentedControl,sel_cells);
  self_00 = _objc_msgSend(pvVar2,sel_objectEnumerator);
  pvVar2 = self->_selectedToolbarItem;
  self_01 = _objc_msgSend(self->_libraryPanels,sel_objectForKey_,pvVar2);
  do {
    self_02 = _objc_msgSend(self_00,sel_nextObject,pvVar2);
    if (self_02 == (id)0x0) goto LAB_000dda09;
    pvVar2 = _objc_msgSend(self_02,sel_tag,pvVar2);
    pvVar3 = _objc_msgSend(self_01,sel_objectAtIndex_);
    pvVar3 = _objc_msgSend(pvVar3,sel_isPaneValid);
  } while ((char)pvVar3 == '\0');
  pvVar2 = _objc_msgSend(self_02,sel_tag,pvVar2);
  if (pvVar2 == (id)0xffffffff) {
LAB_000dda09:
    BVar1 = '\0';
  }
  else {
    _objc_msgSend(self->_segmentedControl,sel_selectCellWithTag_,pvVar2);
    _objc_msgSend(self,sel_panelSwitched_,self->_segmentedControl);
    BVar1 = '\x01';
  }
  return BVar1;
}

*/
- (BOOL)switchToNextAccessiblePanel
{
    NSArray *panels = [_libraryPanels objectForKey:_selectedToolbarItem];
    for (NSCell *cell in [_segmentedControl cells]) {
        if ([[panels objectAtIndex:[cell tag]] isPaneValid]) {
            NSInteger tag = [cell tag];
            if (tag == -1) {
                return NO;
            }
            [_segmentedControl selectCellWithTag:tag];
            [self panelSwitched:_segmentedControl];
            return YES;
        }
    }
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000dd897 @ 000dd897, 189 bytes * /

int FUN_000dd897(HSLibraryController *self,SEL _cmd,id tagOfPanelWithType,id forPluginIdentifier)

{
  id pvVar1;
  id self_00;
  id self_01;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(self->_libraryPanels,sel_objectForKey_,forPluginIdentifier);
  self_00 = _objc_msgSend(pvVar1,sel_objectEnumerator);
  do {
    self_01 = _objc_msgSend(self_00,sel_nextObject,forPluginIdentifier);
    if (self_01 == (id)0x0) goto LAB_000dd947;
    pvVar2 = _objc_msgSend(self_01,sel_panelType,forPluginIdentifier);
    forPluginIdentifier = tagOfPanelWithType;
    pvVar2 = _objc_msgSend(pvVar2,sel_isEqualToString_);
  } while ((char)pvVar2 == '\0');
  pvVar1 = _objc_msgSend(pvVar1,sel_indexOfObject_,self_01);
  if (pvVar1 == (id)0x7fffffff) {
LAB_000dd947:
    pvVar1 = (id)0xffffffff;
  }
  return (int)pvVar1;
}

*/
- (NSInteger)tagOfPanelWithType:(id)aType forPluginIdentifier:(id)aIdentifier
{
    NSArray *panels = [_libraryPanels objectForKey:aIdentifier];
    for (id panel in panels) {
        if ([[panel panelType] isEqualToString:aType]) {
            NSUInteger index = [panels indexOfObject:panel];
            return index == NSNotFound ? -1 : (NSInteger)index;
        }
    }
    return -1;
}

- (void)setActivePanelTag:(NSInteger)aTag forPluginIdentifier:(id)aIdentifier
{
    id pvVar2_3;

    pvVar2_3 = [[[NSUserDefaults standardUserDefaults] objectForKey:HSSelectedLibraryPanelsKey] mutableCopy];
    [pvVar2_3 setObject:[NSNumber numberWithInt:aTag] forKey:aIdentifier];
    [[NSUserDefaults standardUserDefaults] setObject:pvVar2_3 forKey:HSSelectedLibraryPanelsKey];
    [pvVar2_3 release];
}

- (NSInteger)activePanelTagForPluginIdentifier:(id)aIdentifier
{
    id pvVar1_3;

    pvVar1_3 = [[[NSUserDefaults standardUserDefaults] objectForKey:HSSelectedLibraryPanelsKey] objectForKey:aIdentifier];
    if (pvVar1_3 == nil) {
        aIdentifier = nil;
        pvVar1_3 = [NSNumber numberWithInt:0];
    }
    return (int)[pvVar1_3 intValue];
}

- (id)toolbarSelectableItemIdentifiers:(id)aIdentifiers
{
    return [[HSLibraryManager sharedLibraryManager] libraryTypes];
}

- (id)toolbarAllowedItemIdentifiers:(id)aIdentifiers
{
    return [[HSLibraryManager sharedLibraryManager] libraryTypes];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000dd597 @ 000dd597, 263 bytes * /

id FUN_000dd597(HSLibraryController *self,SEL _cmd,id toolbarDefaultItemIdentifiers)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar2 = _objc_msgSend(cls_HSLibraryManager,sel_sharedLibraryManager);
  pvVar2 = _objc_msgSend(pvVar2,sel_libraryTypes);
  pvVar2 = _objc_msgSend(pvVar2,sel_sortedArrayUsingFunction_context_,FUN_000dcea9,0);
  pvVar2 = _objc_msgSend(pvVar2,sel_mutableCopy);
  puVar1 = PTR_003364ec;
  _objc_msgSend(pvVar2,sel_insertObject_atIndex_,*(undefined4 *)PTR_003364ec,0);
  pvVar3 = _objc_msgSend(pvVar2,sel_count);
  _objc_msgSend(pvVar2,sel_insertObject_atIndex_,*(undefined4 *)puVar1,pvVar3);
  pvVar3 = _objc_msgSend(pvVar2,sel_copy);
  pvVar3 = _objc_msgSend(pvVar3,sel_autorelease);
  _objc_msgSend(pvVar2,sel_release);
  return pvVar3;
}

*/
- (id)toolbarDefaultItemIdentifiers:(id)aIdentifiers
{
    NSMutableArray *identifiers = [[[[HSLibraryManager sharedLibraryManager] libraryTypes] sortedArrayUsingFunction:HSCompareLibraryTypes context:NULL] mutableCopy];
    [identifiers insertObject:NSToolbarFlexibleSpaceItemIdentifier atIndex:0];
    [identifiers insertObject:NSToolbarFlexibleSpaceItemIdentifier atIndex:[identifiers count]];
    NSArray *result = [[identifiers copy] autorelease];
    [identifiers release];
    return result;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000dd41c @ 000dd41c, 379 bytes * /

id FUN_000dd41c(HSLibraryController *self,SEL _cmd,id toolbar,id itemForItemIdentifier,
               BOOL willBeInsertedIntoToolbar)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar1 = _objc_msgSend(cls_NSToolbarItem,sel_alloc);
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithItemIdentifier_,itemForItemIdentifier);
  pvVar2 = _objc_msgSend(cls_HSLibraryManager,sel_sharedLibraryManager);
  pvVar2 = _objc_msgSend(pvVar2,sel_pluginForLibraryType_,itemForItemIdentifier);
  pvVar3 = _objc_msgSend(pvVar2,sel_pluginIcon);
  _objc_msgSend(pvVar1,sel_setImage_,pvVar3);
  pvVar3 = _objc_msgSend(pvVar2,sel_pluginTitle);
  _objc_msgSend(pvVar1,sel_setLabel_,pvVar3);
  pvVar3 = _objc_msgSend(pvVar2,sel_pluginTitle);
  _objc_msgSend(pvVar1,sel_setPaletteLabel_,pvVar3);
  pvVar2 = _objc_msgSend(pvVar2,sel_pluginTooltip);
  _objc_msgSend(pvVar1,sel_setToolTip_,pvVar2);
  _objc_msgSend(pvVar1,sel_setEnabled_,1);
  _objc_msgSend(pvVar1,sel_setTarget_,self);
  _objc_msgSend(pvVar1,sel_setAction_,sel_pluginSwitched_);
  pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  return pvVar1;
}

*/
- (id)toolbar:(id)aToolbar itemForItemIdentifier:(id)aIdentifier willBeInsertedIntoToolbar:(BOOL)aToolbar2
{
    NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:aIdentifier];
    id plugin = [[HSLibraryManager sharedLibraryManager] pluginForLibraryType:aIdentifier];
    [item setImage:[plugin pluginIcon]];
    [item setLabel:[plugin pluginTitle]];
    [item setPaletteLabel:[plugin pluginTitle]];
    [item setToolTip:[plugin pluginTooltip]];
    [item setEnabled:YES];
    [item setTarget:self];
    [item setAction:@selector(pluginSwitched:)];
    return [item autorelease];
}

- (BOOL)isLibraryVisible
{
    BOOL BVar1;

    if (![self isWindowLoaded]) {
        BVar1 = NO;
    }
    else {
        BVar1 = (BOOL)[[self window] isVisible];
    }
    return BVar1;
}

- (void)hideLibraryWithSaveToDefaults:(BOOL)aSave
{
    id pvVar1_2;

    if ([self isLibraryVisible]) {
        pvVar1_2 = [self window];
        if ([pvVar1_2 makeFirstResponder:nil]) {
            [[self window] orderOut:self];
            [self stopPlaying];
            if (aSave)
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[[self class] visibilityKeyForDefaults]];
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self name:HSMediaLibraryAccessDidChangeNotification object:0];
    }
}

- (void)hideLibrary
{
    [self hideLibraryWithSaveToDefaults:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000dd198 @ 000dd198, 235 bytes * /

void FUN_000dd198(HSLibraryController *self,SEL _cmd,BOOL showLibraryIfNeededByDefault)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  
  pvVar1 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  pvVar2 = _objc_msgSend(self,sel_class);
  pvVar2 = _objc_msgSend(pvVar2,sel_visibilityKeyForDefaults);
  pvVar1 = _objc_msgSend(pvVar1,sel_boolForKey_,pvVar2);
  if ((char)pvVar1 != '\0') {
    op = sel_showLibrary;
    if (showLibraryIfNeededByDefault == '\0') {
      _objc_msgSend(self,sel_window,pvVar2);
      self = _objc_msgSend(self,sel_storedVisibilityStates);
      pvVar2 = _objc_msgSend(cls_NSNumber,sel_numberWithBool_,(uint)pvVar1 & 0xff);
      op = sel_addObject_;
    }
    _objc_msgSend(self,op,pvVar2);
  }
  return;
}

*/
- (void)showLibraryIfNeededByDefault:(BOOL)aDefault
{
    BOOL wasVisible = [[NSUserDefaults standardUserDefaults] boolForKey:[[self class] visibilityKeyForDefaults]];
    if (!wasVisible) {
        return;
    }
    if (aDefault) {
        [self showLibrary];
    } else {
        /* Load the window and remember it should come back. */
        [self window];
        [[self storedVisibilityStates] addObject:[NSNumber numberWithBool:wasVisible]];
    }
}

- (void)showLibrary
{
    if (![self isLibraryVisible]) {
        [_searchField setStringValue:@""];
        [self filter:_searchField];
        [self showWindow:self];
        [self updatePanels];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[[self class] visibilityKeyForDefaults]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(segmentedControlDidChange:) name:HSMediaLibraryAccessDidChangeNotification object:0];
    }
}

- (BOOL)windowShouldClose:(id)aClose
{
    [self stopPlaying];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[[self class] visibilityKeyForDefaults]];
    return YES;
}

- (void)windowWillClose:(id)aClose
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HSMediaLibraryAccessDidChangeNotification object:0];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000dc7f1 @ 000dc7f1, 1720 bytes * /

void FUN_000dc7f1(HSLibraryController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  HSLibraryController *pHVar7;
  undefined *puVar8;
  cfstringStruct *pcVar9;
  id local_18;
  
  pvVar1 = _objc_msgSend(self,sel_window);
  puVar8 = cls_NSBundle;
  pvVar2 = _objc_msgSend(self,sel_class);
  pvVar2 = _objc_msgSend(puVar8,sel_bundleForClass_,pvVar2);
  pcVar9 = &cfstr_empty;
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_LibraryTitle,
                         &cfstr_empty,&cfstr_Library);
  _objc_msgSend(pvVar1,sel_setTitle_,pvVar2);
  pvVar1 = _objc_msgSend(self,sel_window);
  _objc_msgSend(pvVar1,sel_setFrameAutosaveName_,PTR_cfstr_HSLibraryPanelFramePosition_003424e8);
  pvVar1 = _objc_msgSend(self,sel_window);
  _objc_msgSend(pvVar1,sel_setDelegate_,self);
  pvVar1 = _objc_msgSend(self,sel_window);
  _objc_msgSend(pvVar1,sel_setOpaque_,0);
  pvVar1 = _objc_msgSend(self,sel_window);
  pvVar1 = _objc_msgSend(pvVar1,sel_toolbar);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  pvVar2 = _objc_msgSend(cls_NSToolbar,sel_alloc);
  pvVar2 = _objc_msgSend(pvVar2,sel_initWithIdentifier_,&cfstr_HSLibrary);
  _objc_msgSend(pvVar2,sel_setAutosavesConfiguration_,0);
  _objc_msgSend(pvVar2,sel_setAllowsUserCustomization_,0);
  pHVar7 = self;
  _objc_msgSend(pvVar2,sel_setDelegate_,self);
  if (pvVar1 == (id)0x0) {
    _objc_msgSend(pvVar2,sel_setVisible_,1);
    _objc_msgSend(pvVar2,sel_setDisplayMode_,1);
    puVar8 = sel_setSizeMode_;
    pvVar3 = _objc_msgSend(pvVar2,sel_respondsToSelector_,sel_setSizeMode_);
    if ((char)pvVar3 == '\0') goto LAB_000dcb01;
    puVar8 = (undefined *)0x2;
  }
  else {
    pvVar3 = _objc_msgSend(pvVar1,sel_isVisible,pHVar7);
    _objc_msgSend(pvVar2,sel_setVisible_,(int)(char)pvVar3);
    pvVar3 = _objc_msgSend(pvVar1,sel_displayMode);
    _objc_msgSend(pvVar2,sel_setDisplayMode_,pvVar3);
    puVar8 = sel_setSizeMode_;
    pvVar3 = _objc_msgSend(pvVar2,sel_respondsToSelector_,sel_setSizeMode_);
    if ((char)pvVar3 == '\0') goto LAB_000dcb01;
    puVar8 = _objc_msgSend(pvVar1,sel_sizeMode,puVar8);
  }
  _objc_msgSend(pvVar2,sel_setSizeMode_,puVar8);
LAB_000dcb01:
  pvVar3 = _objc_msgSend(self,sel_window,puVar8);
  _objc_msgSend(pvVar3,sel_setToolbar_,pvVar2);
  _objc_msgSend(pvVar1,sel_release);
  pvVar1 = _objc_msgSend(self,sel_window);
  puVar8 = (undefined *)0x0;
  _objc_msgSend(pvVar1,sel_setShowsToolbarButton_,0);
  pvVar1 = _objc_msgSend(pvVar2,sel_items);
  pvVar3 = _objc_msgSend(pvVar1,sel_count);
  if (pvVar3 == (id)0x0) {
    local_18 = (id)0x0;
  }
  else {
    local_18 = (id)0x0;
    pvVar3 = _objc_msgSend(pvVar1,sel_objectEnumerator,puVar8);
    while (pvVar4 = _objc_msgSend(pvVar3,sel_nextObject,puVar8), pvVar4 != (id)0x0) {
      pvVar5 = _objc_msgSend(pvVar4,sel_itemIdentifier,puVar8);
      puVar8 = self->_selectedToolbarItem;
      pvVar5 = _objc_msgSend(pvVar5,sel_isEqualToString_);
      if ((char)pvVar5 != '\0') {
        local_18 = pvVar4;
      }
    }
    if (local_18 == (id)0x0) {
      pvVar4 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults,puVar8);
      pvVar3 = *(id *)PTR_003364e8;
      pvVar4 = _objc_msgSend(pvVar4,sel_stringForKey_,pvVar3);
      if (pvVar4 == (id)0x0) {
        pvVar3 = _objc_msgSend(cls_HSLibraryManager,sel_sharedLibraryManager,pvVar3);
        pvVar3 = _objc_msgSend(pvVar3,sel_libraryTypes);
        pcVar9 = (cfstringStruct *)0x0;
        pvVar4 = _objc_msgSend(pvVar3,sel_sortedArrayUsingFunction_context_,FUN_000dcea9,0);
        pvVar3 = (id)0x0;
        pvVar4 = _objc_msgSend(pvVar4,sel_objectAtIndex_,0);
      }
      pvVar5 = _objc_msgSend(pvVar1,sel_objectEnumerator,pvVar3,pcVar9);
      pvVar1 = local_18;
      while (local_18 = pvVar1, local_18 == (id)0x0) {
        do {
          pvVar1 = _objc_msgSend(pvVar5,sel_nextObject,pvVar3);
          if (pvVar1 == (id)0x0) goto LAB_000dcd43;
          pvVar6 = _objc_msgSend(pvVar1,sel_itemIdentifier,pvVar3);
          pvVar3 = pvVar4;
          pvVar6 = _objc_msgSend(pvVar6,sel_isEqualToString_);
        } while ((char)pvVar6 == '\0');
      }
    }
LAB_000dcd43:
    puVar8 = sel_setSelectedItemIdentifier_;
    pvVar1 = _objc_msgSend(pvVar2,sel_respondsToSelector_,sel_setSelectedItemIdentifier_);
    if ((char)pvVar1 != '\0') {
      puVar8 = _objc_msgSend(local_18,sel_itemIdentifier,puVar8);
      _objc_msgSend(pvVar2,sel_setSelectedItemIdentifier_,puVar8);
    }
  }
  pvVar1 = self->_segmentedControl;
  pvVar3 = _objc_msgSend(cls_HSLibraryPanelControlBackgroundRenderer,sel_sharedBackgroundRenderer,
                         puVar8);
  _objc_msgSend(pvVar1,sel_setBackgroundRenderer_,pvVar3);
  pvVar1 = _objc_msgSend(self->_segmentedControl,sel_cellAtRow_column_,0,1);
  _objc_msgSend(self->_segmentedControl,sel_setPrototype_,pvVar1);
  _objc_msgSend(self,sel_pluginSwitched_,local_18);
  _objc_msgSend(pvVar2,sel_release);
  pvVar1 = _objc_msgSend(self,sel_window);
  puVar8 = sel_setBecomesKeyOnlyIfNeeded_;
  pvVar1 = _objc_msgSend(pvVar1,sel_respondsToSelector_,sel_setBecomesKeyOnlyIfNeeded_);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(self,sel_window,puVar8);
    _objc_msgSend(pvVar1,sel_setBecomesKeyOnlyIfNeeded_,1);
  }
  return;
}

*/
- (void)windowDidLoad
{
    [[self window] setTitle:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"LibraryTitle" value:@"" table:@"Library"]];
    [[self window] setFrameAutosaveName:@"HSLibraryPanelFramePosition"];
    [[self window] setDelegate:self];
    [[self window] setOpaque:NO];
    NSToolbar *oldToolbar = [[[self window] toolbar] retain];
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"HSLibrary"];
    [toolbar setAutosavesConfiguration:NO];
    [toolbar setAllowsUserCustomization:NO];
    [toolbar setDelegate:self];
    if (oldToolbar == nil) {
        [toolbar setVisible:YES];
        [toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
        if ([toolbar respondsToSelector:@selector(setSizeMode:)]) {
            [toolbar setSizeMode:NSToolbarSizeModeSmall];
        }
    } else {
        [toolbar setVisible:[oldToolbar isVisible]];
        [toolbar setDisplayMode:[oldToolbar displayMode]];
        if ([toolbar respondsToSelector:@selector(setSizeMode:)]) {
            [toolbar setSizeMode:[oldToolbar sizeMode]];
        }
    }
    [[self window] setToolbar:toolbar];
    [oldToolbar release];
    [[self window] setShowsToolbarButton:NO];
    NSArray *items = [toolbar items];
    NSToolbarItem *selectedItem = nil;
    if ([items count] != 0) {
        for (NSToolbarItem *item in items) {
            if ([[item itemIdentifier] isEqualToString:_selectedToolbarItem]) {
                selectedItem = item;
            }
        }
        if (selectedItem == nil) {
            NSString *identifier = [[NSUserDefaults standardUserDefaults] stringForKey:HSSelectedLibraryPluginKey];
            if (identifier == nil) {
                identifier = [[[[HSLibraryManager sharedLibraryManager] libraryTypes] sortedArrayUsingFunction:HSCompareLibraryTypes context:NULL] objectAtIndex:0];
            }
            for (NSToolbarItem *item in items) {
                if ([[item itemIdentifier] isEqualToString:identifier]) {
                    selectedItem = item;
                    break;
                }
            }
        }
        if ([toolbar respondsToSelector:@selector(setSelectedItemIdentifier:)]) {
            [toolbar setSelectedItemIdentifier:[selectedItem itemIdentifier]];
        }
    }
    [_segmentedControl setBackgroundRenderer:[HSLibraryPanelControlBackgroundRenderer sharedBackgroundRenderer]];
    [_segmentedControl setPrototype:[_segmentedControl cellAtRow:0 column:1]];
    [self pluginSwitched:selectedItem];
    [toolbar release];
    if ([[self window] respondsToSelector:@selector(setBecomesKeyOnlyIfNeeded:)]) {
        [(NSPanel *)[self window] setBecomesKeyOnlyIfNeeded:YES];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000dc255 @ 000dc255, 1436 bytes * /

void FUN_000dc255(HSLibraryController *self,SEL _cmd)

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
  _objc_msgSend(self->_playButton,sel_setCell_,pvVar2);
  _objc_msgSend(self->_playButton,sel_setButtonType_,5);
  _objc_msgSend(self->_playButton,sel_setBordered_,0);
  _objc_msgSend(self->_playButton,sel_setAction_,sel_playSelection_);
  _objc_msgSend(self->_playButton,sel_setTarget_,self);
  pvVar2 = self->_playButton;
  pvVar4 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,&cfstr_Play,&cfstr_empty,0);
  _objc_msgSend(pvVar2,sel_setTitle_,pvVar4);
  _objc_msgSend(self->_playButton,sel_setImagePosition_,1);
  _objc_msgSend(self,sel_setImagesForPlayButton_,0);
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
    [_playButton setCell:_playButtonCell];
    [_playButton setButtonType:5];
    [_playButton setBordered:NO];
    [_playButton setAction:@selector(playSelection:)];
    [_playButton setTarget:self];
    [_playButton setTitle:[[NSBundle mainBundle] localizedStringForKey:@"Play" value:@"" table:nil]];
    [_playButton setImagePosition:NSImageOnly];
    [self setImagesForPlayButton:NO];
}

- (id)autorelease
{
    return self;
}

- (void)release
{

}

- (NSUInteger)retainCount
{
    return 0xffffffff;
}

- (id)retain
{
    return self;
}

- (id)copyWithZone:(NSZone *)aZone
{
    return self;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000dfc8b @ 000dfc8b, 373 bytes * /

id FUN_000dfc8b(HSLibraryController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  cfstringStruct *pcVar3;
  id pvVar4;
  cfstringStruct *self_00;
  cfstringStruct *pcVar5;
  HSLibraryController *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_NSWindowController_00350540;
  pcVar5 = &cfstr_Library;
  pvVar1 = _objc_msgSendSuper(&local_1c,sel_initWithWindowNibName_,&cfstr_Library);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(cls_NSMutableDictionary,sel_alloc);
    pvVar2 = _objc_msgSend(pvVar2,sel_init);
    *(id *)((int)pvVar1 + 0x48) = pvVar2;
    pvVar2 = _objc_msgSend(cls_HSLibraryManager,sel_sharedLibraryManager);
    pvVar2 = _objc_msgSend(pvVar2,sel_libraryTypes);
    pvVar2 = _objc_msgSend(pvVar2,sel_objectEnumerator);
    pcVar3 = _objc_msgSend(pvVar2,sel_nextObject);
    while (pcVar3 != (cfstringStruct *)0x0) {
      pvVar4 = _objc_msgSend(cls_HSLibraryManager,sel_sharedLibraryManager,pcVar5);
      pcVar5 = pcVar3;
      pvVar4 = _objc_msgSend(pvVar4,sel_pluginForLibraryType_);
      self_00 = _objc_msgSend(pvVar4,sel_pluginPanels);
      pvVar4 = _objc_msgSend(self_00,sel_count);
      if (pvVar4 != (id)0x0) {
        _objc_msgSend(*(id *)((int)pvVar1 + 0x48),sel_setObject_forKey_,self_00,pcVar3);
        pcVar5 = self_00;
      }
      pcVar3 = _objc_msgSend(pvVar2,sel_nextObject,pcVar5);
    }
  }
  return pvVar1;
}

*/
- (id)init
{
    self = [super initWithWindowNibName:@"Library"];
    if (self != nil) {
        _libraryPanels = [[NSMutableDictionary alloc] init];
        for (id libraryType in [[HSLibraryManager sharedLibraryManager] libraryTypes]) {
            NSArray *panels = [[[HSLibraryManager sharedLibraryManager] pluginForLibraryType:libraryType] pluginPanels];
            if ([panels count] != 0) {
                [_libraryPanels setObject:panels forKey:libraryType];
            }
        }
    }
    return self;
}

- (void)dealloc
{
    id pvVar1;
    HSLibraryController *pHVar3;

    pvVar1 = [NSNotificationCenter defaultCenter];
    pHVar3 = self;
    [pvVar1 removeObserver:self];
    [_selectedToolbarItem release];
    [_selectedSearchCategory release];
    [_libraryPanels release];
    [_activeViewContainer release];
    [_playButtonImage release];
    [_playButtonAquaImage release];
    [_playButtonGraphiteImage release];
    [_stopButtonImage release];
    [_stopButtonAquaImage release];
    [_stopButtonGraphiteImage release];
    [_playButtonCell release];
    pvVar1 = [[_searchField cell] searchMenuTemplate];
    if ([pvVar1 delegate] == self) {
        pvVar1 = [[_searchField cell] searchMenuTemplate];
        pHVar3 = nil;
        [pvVar1 setDelegate:0];
    }
    [_storedVisibilityStates release];
    [super dealloc];
}

- (void)documentWindowDidBecomeMain:(id)aMain
{
    if ([[[[NSDocumentController sharedDocumentController] currentDocument] stack] isStackProtected])
        [self hideLibraryWithSaveToDefaults:NO];
    else
        [self showLibraryIfNeededByDefault:YES];
}

@end

