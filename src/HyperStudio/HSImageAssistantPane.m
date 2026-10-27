#import "HSImageAssistantPane.h"

@implementation HSImageAssistantPane

/* i386 ivar offsets: _gridControl=0x68, _sourceMatrix=0x6c, _gridContentView=0x70, _containerView=0x74, _placeholderView=0x78, _folderTabPlaceholderView=0x7c, _folderTabView=0x80, _folderTabContainerView=0x84, _imageView=0x88, _currentPath=0x8c, _currentContentView=0x90, _chooser=0x94, _stackImagesDataSource=0x98, _libraryImagesDataSource=0x9c, _folderImagesDataSource=0xa0, _paneSwitcher=0xa4 */

- (void)validatePaneSwither
{
    [[self navigationPaneSwitcher] validateUserInterface];
}

- (id)helpTopicKey
{
    return @"HSIconPane";
}

- (id)contentViewForDataSource:(id)aSource
{
    id pvVar1;
    id pvVar2_2;

    if ([self folderImagesDataSource] == aSource) {
        pvVar2_2 = _folderTabView;
        pvVar1 = _folderTabContainerView;
        [self mountView:[self contentSubviewForDataSource:aSource] inView:pvVar1];
    }
    else {
        pvVar2_2 = [self contentSubviewForDataSource:aSource];
    }
    return pvVar2_2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000f16ad @ 000f16ad, 94 bytes * /

id FUN_000f16ad(HSImageAssistantPane *self,SEL _cmd,id contentSubviewForDataSource)

{
  id pvVar1;
  id pvVar2;
  id *ppvVar3;
  
  pvVar1 = _objc_msgSend(self,sel_folderImagesDataSource);
  pvVar2 = _objc_msgSend(contentSubviewForDataSource,sel_countOfChoosableItems);
  if (pvVar1 == contentSubviewForDataSource) {
    if (pvVar2 == (id)0x0) {
      ppvVar3 = &self->_folderTabPlaceholderView;
      goto LAB_000f1701;
    }
  }
  else if (pvVar2 == (id)0x0) {
    ppvVar3 = &self->_placeholderView;
    goto LAB_000f1701;
  }
  ppvVar3 = &self->_gridContentView;
LAB_000f1701:
  return *ppvVar3;
}

*/
- (id)contentSubviewForDataSource:(id)aSource
{
    id folderDataSource = [self folderImagesDataSource];
    NSUInteger count = [aSource countOfChoosableItems];
    if (folderDataSource == aSource) {
        if (count == 0) {
            return _folderTabPlaceholderView;
        }
    } else if (count == 0) {
        return _placeholderView;
    }
    return _gridContentView;
    return 0;
}

- (void)mountView:(id)aView inView:(id)aView2
{
    id pvVar1_2;

    pvVar1_2 = [[aView2 subviews] copy];
    [pvVar1_2 makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [aView setFrame:[aView2 bounds]];
    [aView2 addSubview:aView];
    [pvVar1_2 release];
}

- (void)viewDidAppear:(BOOL)aAppear
{
    [super viewDidAppear:aAppear];
    [self validatePaneSwither];
}

- (id)navigationPaneSwitcher
{
    HSObjectAssistantNavigationPaneSwitcher *pHVar1;
    HSObjectAssistantNavigationPaneSwitcher *pHVar1_2;

    pHVar1 = _paneSwitcher;
    if (pHVar1 == nil) {
        pHVar1_2 = [HSObjectAssistantNavigationPaneSwitcher new];
        _paneSwitcher = pHVar1_2;
        [pHVar1_2 setDelegate:self];
        pHVar1 = _paneSwitcher;
    }
    return pHVar1;
}

- (BOOL)requiresDarkBottomArea
{
    return YES;
}

- (void)doubleClickAtIndex:(NSInteger)aIndex inIconsGrid:(id)aGrid
{
    id pvVar1_4;

    if ((unsigned int)aIndex < [[[self chooser] dataSource] countOfChoosableItems]) {
        pvVar1_4 = [self HSImageAssistantPane_applier];
        [pvVar1_4 setMedia:[[[self chooser] dataSource] mediaForChoosableItemAtIndex:aIndex]];
        [pvVar1_4 applyChanges];
        [pvVar1_4 makeInitialEqualToCurrent];
    }
    [self dismiss:YES];
}

- (id)folderImagesDataSource
{
    HSFolderImagesDataSource *pHVar1;

    pHVar1 = _folderImagesDataSource;
    if (pHVar1 == nil) {
        pHVar1 = [[HSFolderImagesDataSource alloc] init];
        _folderImagesDataSource = pHVar1;
    }
    return pHVar1;
}

- (void)changeFolder:(id)aFolder
{
    NSOpenPanel *pvVar2;
    id pvVar1_2;
    id pvVar1_5;

    pvVar1_2 = [[HSPathsProvider sharedPathsProvider] iconLocationFolder];
    pvVar2 = [NSOpenPanel openPanel];
    [pvVar2 setCanChooseDirectories:YES];
    [pvVar2 setCanChooseFiles:NO];
    if ([pvVar2 runModalForDirectory:pvVar1_2 file:nil types:nil] == 0x1) {
        pvVar1_5 = [[[pvVar2 URLs] objectAtIndex:0] path];
        [[HSPathsProvider sharedPathsProvider] setIconLocationFolder:pvVar1_5];
        [self updateUI];
    }
}

- (void)chooseFromFolder:(id)aFolder
{
    [self setChooserDataSource:[self folderImagesDataSource]];
    [self updateUI];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000f11e5 @ 000f11e5, 383 bytes * /

void FUN_000f11e5(HSImageAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar1 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider);
  pvVar2 = _objc_msgSend(pvVar1,sel_iconLocationFolder);
  pvVar1 = self->_imageView;
  pvVar3 = _objc_msgSend(cls_NSWorkspace,sel_sharedWorkspace);
  pvVar3 = _objc_msgSend(pvVar3,sel_iconForFile_,pvVar2);
  _objc_msgSend(pvVar1,sel_setImage_,pvVar3);
  pvVar1 = self->_currentPath;
  pvVar3 = _objc_msgSend(pvVar2,sel_lastPathComponent);
  _objc_msgSend(pvVar1,sel_setStringValue_,pvVar3);
  pvVar1 = _objc_msgSend(self,sel_folderImagesDataSource);
  _objc_msgSend(pvVar1,sel_setPath_,pvVar2);
  pvVar1 = self->_folderTabContainerView;
  pvVar2 = _objc_msgSend(self,sel_chooser);
  pvVar2 = _objc_msgSend(pvVar2,sel_dataSource);
  pvVar2 = _objc_msgSend(self,sel_contentSubviewForDataSource_,pvVar2);
  _objc_msgSend(self,sel_mountView_inView_,pvVar2,pvVar1);
  _objc_msgSend(self->_gridControl,sel_reloadData);
  _objc_msgSend(self->_gridControl,sel_sizeToCells);
  return;
}

*/
- (void)updateUI
{
    id folder = [[HSPathsProvider sharedPathsProvider] iconLocationFolder];
    [_imageView setImage:[[NSWorkspace sharedWorkspace] iconForFile:folder]];
    [_currentPath setStringValue:[folder lastPathComponent]];
    [[self folderImagesDataSource] setPath:folder];
    [self mountView:[self contentSubviewForDataSource:[[self chooser] dataSource]] inView:_folderTabContainerView];
    [_gridControl reloadData];
    [_gridControl sizeToCells];
}

- (void)viewDidLoad
{
    HSIconsGrid *pHVar2;
    int iVar4;

    [super viewDidLoad];
    pHVar2 = _gridControl;
    [pHVar2 setDataSource:[self chooser]];
    [_gridControl setDelegate:self];
    [_gridControl setCellSize:NSMakeSize(37.0, 36.0)];
    [_gridControl setAllowsEmptySelection:YES];
    pHVar2 = _gridControl;
    iVar4 = 7;
    do {
        [pHVar2 addColumn];
        iVar4 = iVar4 + -1;
        pHVar2 = _gridControl;
    } while (iVar4 != 0);
    [pHVar2 reloadData];
    [_gridControl sizeToCells];
    [_sourceMatrix setBackgroundRenderer:[HSAssistantSegmentedControlBackgroundRenderer sharedBackgroundRenderer]];
}

- (void)imageDataSourceDidChange:(id)aChange
{
    [_gridControl reloadData];
}

- (void)selectionDidChangeInIconsGrid:(id)aGrid
{
    NSArray *pvVar1;
    id pvVar2;
    NSUInteger pvVar1_2;
    id pvVar3_4;

    pvVar1 = [_gridControl cells];
    pvVar2 = [_gridControl selectedCell];
    pvVar1_2 = [pvVar1 indexOfObject:pvVar2];
    if (pvVar1_2 < [[[self chooser] dataSource] countOfChoosableItems]) {
        pvVar3_4 = [[[self chooser] dataSource] mediaForChoosableItemAtIndex:pvVar1_2];
    }
    else {
        pvVar3_4 = nil;
    }
    [[self HSImageAssistantPane_applier] setMedia:pvVar3_4];
    [self validatePaneSwither];
}

- (id)stackImagesDataSource
{
    HSStackImagesDataSource *pHVar2;

    pHVar2 = _stackImagesDataSource;
    if (pHVar2 == nil) {
        pHVar2 = [[HSStackImagesDataSource alloc] initWithStack:[self stack]];
        _stackImagesDataSource = pHVar2;
    }
    return pHVar2;
}

- (id)libraryImagesDataSource
{
    HSImageLibraryDataSource *pHVar1;

    pHVar1 = _libraryImagesDataSource;
    if (pHVar1 == nil) {
        pHVar1 = [HSImageLibraryDataSource sharedImageLibraryDataSource];
        _libraryImagesDataSource = pHVar1;
    }
    return pHVar1;
}

- (void)chooseFromBundle:(id)aBundle
{
    [self setChooserDataSource:[self libraryImagesDataSource]];
    [_gridControl reloadData];
}

- (void)chooseFromStack:(id)aStack
{
    [self setChooserDataSource:[self stackImagesDataSource]];
    [_gridControl reloadData];
}

- (void)setChooserDataSource:(id)aSource
{
    HSIconsGrid *self_00;
    id pvVar1_9;

    if ([[self chooser] dataSource] == aSource) {
        [aSource updateChoosableItemsIfNeeded];
        [_gridControl reloadData];
        self_00 = _gridControl;
    }
    else {
        if ([[self chooser] dataSource] != nil) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSChoserDataSourceDidChangeNotification" object:[[self chooser] dataSource]];
        }
        if (aSource != nil) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageDataSourceDidChange:) name:@"HSChoserDataSourceDidChangeNotification" object:aSource];
        }
        [[self chooser] setDataSource:aSource];
        [aSource updateChoosableItemsIfNeeded];
        [_gridControl reloadData];
        [_sourceMatrix selectCellWithTag:[self tagForCurrentDataSource]];
        pvVar1_9 = _containerView;
        [self mountView:[self contentViewForDataSource:aSource] inView:pvVar1_9];
        self_00 = _gridControl;
    }
    [self_00 sizeToCells];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000f0c17 @ 000f0c17, 271 bytes * /

uint FUN_000f0c17(HSImageAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  uint uVar3;
  
  pvVar1 = _objc_msgSend(self,sel_chooser);
  pvVar1 = _objc_msgSend(pvVar1,sel_dataSource);
  pvVar2 = _objc_msgSend(self,sel_stackImagesDataSource);
  if (pvVar1 == pvVar2) {
    uVar3 = 2;
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_chooser);
    pvVar1 = _objc_msgSend(pvVar1,sel_dataSource);
    pvVar2 = _objc_msgSend(self,sel_libraryImagesDataSource);
    if (pvVar1 == pvVar2) {
      uVar3 = 1;
    }
    else {
      pvVar1 = _objc_msgSend(self,sel_chooser);
      pvVar1 = _objc_msgSend(pvVar1,sel_dataSource);
      pvVar2 = _objc_msgSend(self,sel_folderImagesDataSource);
      if (pvVar1 == pvVar2) {
        uVar3 = 3;
      }
      else {
        pvVar1 = _objc_msgSend(self,sel_chooser);
        _objc_msgSend(pvVar1,sel_dataSource);
        uVar3 = 0x7fffffff;
      }
    }
  }
  return uVar3;
}

*/
- (NSUInteger)tagForCurrentDataSource
{
    if ([[self chooser] dataSource] == [self stackImagesDataSource]) {
        return 2;
    }
    if ([[self chooser] dataSource] == [self libraryImagesDataSource]) {
        return 1;
    }
    if ([[self chooser] dataSource] == [self folderImagesDataSource]) {
        return 3;
    }
    return NSNotFound;
    return 0;
}

- (id)chooser
{
    HSChoosableItemProvider *pHVar2;

    pHVar2 = _chooser;
    if (pHVar2 == nil) {
        pHVar2 = [[HSChoosableItemProvider alloc] initWithDestinationObjectClass:[NSImage class]];
        _chooser = pHVar2;
    }
    return pHVar2;
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [[self navigationPaneSwitcher] setApplier:nil];
    [super viewWillDisappear:aDisappear];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000f1b42 @ 000f1b42, 428 bytes * /

void FUN_000f1b42(HSImageAssistantPane *self,SEL _cmd,BOOL viewWillAppear)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  HSImageAssistantPane *self_01;
  SEL op;
  HSImageAssistantPane *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSObjectAssistantPaneWithApplier_003508a0;
  _objc_msgSendSuper(&local_1c,sel_viewWillAppear_,(int)viewWillAppear);
  pvVar1 = _objc_msgSend(self,sel_stackImagesDataSource);
  pvVar2 = _objc_msgSend(pvVar1,sel_countOfChoosableItems);
  if (pvVar2 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_libraryImagesDataSource);
    self_01 = self;
    op = sel_setChooserDataSource_;
  }
  else {
    _objc_msgSend(self,sel_setChooserDataSource_,pvVar1);
    self_01 = _objc_msgSend(self->_sourceMatrix,sel_cellWithTag_,2);
    self_00 = cls_NSString;
    pvVar1 = _objc_msgSend(pvVar1,sel_countOfChoosableItems);
    pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_In_Use___d_,
                           &cfstr_empty,&cfstr_AssistantPanes);
    pvVar1 = _objc_msgSend(self_00,sel_stringWithFormat_,pvVar2,pvVar1);
    op = sel_setTitle_;
  }
  _objc_msgSend(self_01,op,pvVar1);
  pvVar1 = _objc_msgSend(self,sel_navigationPaneSwitcher);
  pvVar2 = _objc_msgSend(self,sel_HSImageAssistantPane_applier);
  _objc_msgSend(pvVar1,sel_setApplier_,pvVar2);
  return;
}

*/
- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    id stackDataSource = [self stackImagesDataSource];
    if ([stackDataSource countOfChoosableItems] == 0) {
        [self setChooserDataSource:[self libraryImagesDataSource]];
    } else {
        [self setChooserDataSource:stackDataSource];
        [[_sourceMatrix cellWithTag:2] setTitle:[NSString stringWithFormat:[[NSBundle mainBundle] localizedStringForKey:@"In Use (%d)" value:@"" table:@"AssistantPanes"], (int)[stackDataSource countOfChoosableItems]]];
    }
    [[self navigationPaneSwitcher] setApplier:[self HSImageAssistantPane_applier]];
}

- (id)HSImageAssistantPane_applier
{
    return [self applier];
}

- (Class)applierClass
{
    return [HSImageAssistantPaneApplier class];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_folderImagesDataSource release];
    [_stackImagesDataSource release];
    [_gridControl setDataSource:0];
    [_paneSwitcher setDelegate:0];
    [_paneSwitcher release];
    [_gridContentView release];
    [_placeholderView release];
    [_folderTabPlaceholderView release];
    [_folderTabView release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"HSIconsAssistantPane"];
    return self;
}

@end

@implementation HSImageAssistantPaneApplier

/* i386 ivar offsets: _initialMedia=0xc, _media=0x10 */

- (BOOL)areSettingsEqual
{
    BOOL BVar1;

    if (_media == nil && _initialMedia == nil) {
        BVar1 = YES;
    }
    else {
        BVar1 = (BOOL)[_media isEqual:_initialMedia];
    }
    return BVar1;
}

- (void)makeCurrentEqualToInitial
{
    [_media release];
    _media = [_initialMedia retain];
}

- (void)makeInitialEqualToCurrent
{
    [_initialMedia release];
    _initialMedia = [_media retain];
}

- (void)setInitialSettingsToObject
{
    [[self mediaAttributes] setMedia:_initialMedia];
}

- (void)setCurrentSettingsToObject
{
    [[self mediaAttributes] setMedia:_media];
}

- (void)setUpInitialSettings
{
    id pvVar1_4;

    pvVar1_4 = [[[[self mediaAttributes] media] retain] retain];
    _initialMedia = pvVar1_4;
    _media = pvVar1_4;
}

- (void)setMedia:(id)aMedia
{
    if (_media != aMedia) {
        [_media release];
        _media = [aMedia retain];
        [self disableUndo];
        [[self mediaAttributes] setMedia:_media];
        [self enableUndo];
    }
}

- (id)undoActionName
{
    return [[NSBundle mainBundle] localizedStringForKey:@"Change Image" value:@"" table:@"UndoManager"];
}

- (id)mediaAttributes
{
    return [[self object] queryHyperInterface:@protocol(HSMediaAttributes)];
}

- (void)dealloc
{
    [_initialMedia release];
    [_media release];
    [super dealloc];
}

@end

