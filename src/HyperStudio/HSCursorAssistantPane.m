#import "HSCursorAssistantPane.h"

@implementation HSCursorAssistantPane

/* i386 ivar offsets: _gridContentView=0x68, _placeholderView=0x6c, _folderTabPlaceholderView=0x70, _folderTabView=0x74, _sourceMatrix=0x78, _containerView=0x7c, _gridControl=0x80, _imageView=0x84, _currentPath=0x88, _folderTabContainerView=0x8c, _paneSwitcher=0x90, _stackCursorsDataSource=0x94, _folderCursorsDataSource=0x98, _dataSource=0x9c, _currentContentView=0xa0, _currentFolderTabContentView=0xa4 */

+ (id)defaultCursorsDataSorce
{
    return [HSCursorsLibraryDataSource sharedCursorsLibraryDataSource];
}

- (void)mountFolderTabContentView:(id)aView
{
    id self_00;

    if (_currentFolderTabContentView != aView) {
        [_currentFolderTabContentView removeFromSuperview];
        [_currentFolderTabContentView release];
        self_00 = [aView retain];
        _currentFolderTabContentView = self_00;
        [self_00 setFrame:[_folderTabContainerView bounds]];
        [_folderTabContainerView addSubview:_currentFolderTabContentView];
    }
}

- (void)mountContentView:(id)aView
{
    id self_00;

    if (_currentContentView != aView) {
        [_currentContentView removeFromSuperview];
        [_currentContentView release];
        self_00 = [aView retain];
        _currentContentView = self_00;
        [self_00 setFrame:[_containerView bounds]];
        [_containerView addSubview:_currentContentView];
    }
}

- (id)helpTopicKey
{
    return @"HSCursorPane";
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ed5ea @ 000ed5ea, 89 bytes * /

id FUN_000ed5ea(HSCursorAssistantPane *self,SEL _cmd,id contentViewForDataSource)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_folderCursorsDataSource);
  op = sel_contentViewForHyperDataSource_;
  if (pvVar1 == contentViewForDataSource) {
    op = sel_contentViewForFolderDataSource_;
  }
  pvVar1 = _objc_msgSend(self,op,contentViewForDataSource);
  return pvVar1;
}

*/
- (id)contentViewForDataSource:(id)aSource
{
    if ([self folderCursorsDataSource] == aSource) {
        return [self contentViewForFolderDataSource:aSource];
    }
    return [self contentViewForHyperDataSource:aSource];
    return 0;
}

- (id)contentViewForHyperDataSource:(id)aSource
{
    id *ppvVar2;
    id pvVar1_2;

    if ([aSource countOfCursors] == 0) {
        ppvVar2 = &_placeholderView;
    }
    else {
        ppvVar2 = &_gridContentView;
    }
    pvVar1_2 = *ppvVar2;
    if (pvVar1_2 == _currentFolderTabContentView) {
        [_currentFolderTabContentView removeFromSuperview];
        [_currentFolderTabContentView release];
        _currentFolderTabContentView = nil;
    }
    return pvVar1_2;
}

- (id)contentViewForFolderDataSource:(id)aSource
{
    id pvVar1;
    id pvVar2;

    pvVar1 = _folderTabView;
    pvVar2 = [self contentSubviewForFolderDataSource:aSource]
    ;
    [self mountFolderTabContentView:pvVar2];
    return pvVar1;
}

- (id)contentSubviewForFolderDataSource:(id)aSource
{
    id *ppvVar2;
    id pvVar1_2;

    if ([aSource countOfCursors] == 0) {
        ppvVar2 = &_folderTabPlaceholderView;
    }
    else {
        ppvVar2 = &_gridContentView;
    }
    pvVar1_2 = *ppvVar2;
    if (pvVar1_2 == _currentContentView) {
        [_currentContentView removeFromSuperview];
        [_currentContentView release];
        _currentContentView = nil;
    }
    return pvVar1_2;
}

- (void)validatePaneSwither
{
    [[self navigationPaneSwitcher] validateUserInterface];
}

- (BOOL)shouldEnableOKButtonInNavigationPaneSwitcher:(id)aSwitcher
{
    return (BOOL)[[self HSCursorAssistantPane_applier] canApplyCurrentSettings];
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

- (void)selectItemWithCursor:(id)aCursor
{
    HSIconsGrid *self_00;
    id pvVar1;
    NSUInteger pvVar2;
    id pvVar3;
    NSUInteger pvVar4;

    pvVar1 = [self dataSource];
    pvVar4 = 0;
    pvVar2 = [pvVar1 countOfCursors];
    while( YES ) {
        if (pvVar2 <= pvVar4) {
            return;
        }
        pvVar3 = [pvVar1 cursorAtIndex:pvVar4];
        if ([pvVar3 isEqualTo:aCursor]) break;
        pvVar4 = (pvVar4 + 1);
    }
    self_00 = _gridControl;
    pvVar1 = [[self_00 cells] objectAtIndex:pvVar4];
    [self_00 selectCell:pvVar1];
}

- (void)cursorDataSourceDidChange:(id)aChange
{
    [_gridControl reloadData];
    [_gridControl sizeToCells];
}

- (void)doubleClickAtIndex:(NSInteger)aIndex inIconsGrid:(id)aGrid
{
    if ((unsigned int)aIndex < [[self dataSource] countOfCursors]) {
        [[self HSCursorAssistantPane_applier] setHyperCursor:[[self dataSource] cursorAtIndex:aIndex]];
    }
    [self paneDidOK:nil];
}

- (void)selectionDidChangeInIconsGrid:(id)aGrid
{
    NSArray *pvVar1;
    id pvVar2;
    NSUInteger pvVar1_2;
    id pvVar3_3;

    pvVar1 = [_gridControl cells];
    pvVar2 = [_gridControl selectedCell];
    pvVar1_2 = [pvVar1 indexOfObject:pvVar2];
    if (pvVar1_2 < [[self dataSource] countOfCursors]) {
        pvVar3_3 = [[self dataSource] cursorAtIndex:pvVar1_2];
    }
    else {
        pvVar3_3 = nil;
    }
    [[self HSCursorAssistantPane_applier] setHyperCursor:pvVar3_3];
    [self validatePaneSwither];
}

- (id)dataSource
{
    id pvVar1;

    pvVar1 = _dataSource;
    if (pvVar1 == nil) {
        [self setDataSource:[[self class] defaultCursorsDataSorce]];
        pvVar1 = _dataSource;
    }
    return pvVar1;
}

- (void)setDataSource:(id)aSource
{
    if (_dataSource != aSource) {
        if (_dataSource != nil) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSCursorDataSourceDidChangeNotification" object:_dataSource];
        }
        _dataSource = aSource;
        if (aSource != nil) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cursorDataSourceDidChange:) name:@"HSCursorDataSourceDidChangeNotification" object:_dataSource];
        }
        [_gridControl reloadData];
        [_sourceMatrix selectCellWithTag:[self tagForCurrentDataSource]];
        if ([[self assistant] object] != nil) {
            [self selectItemWithCursor:[[self HSCursorAssistantPane_applier] hyperCursor]];
        }
        [self mountContentView:[self contentViewForDataSource:aSource]];
        [_gridControl sizeToCells];
    }
}

- (id)folderCursorsDataSource
{
    id pvVar1;

    pvVar1 = _folderCursorsDataSource;
    if (pvVar1 == nil) {
        pvVar1 = [[HSFolderCursorsDataSource alloc] init];
        _folderCursorsDataSource = pvVar1;
    }
    return pvVar1;
}

- (id)stackCursorsDataSource
{
    return _stackCursorsDataSource;
}

- (void)setStackCursorsDataSource:(id)aSource
{
    if (_stackCursorsDataSource != aSource) {
        [_stackCursorsDataSource release];
        _stackCursorsDataSource = [aSource retain];
    }
}

- (void)changeFolder:(id)aFolder
{
    NSOpenPanel *pvVar2;
    id pvVar1_2;
    id pvVar1_5;

    pvVar1_2 = [[HSPathsProvider sharedPathsProvider] cursorLocationFolder];
    pvVar2 = [NSOpenPanel openPanel];
    [pvVar2 setCanChooseDirectories:YES];
    [pvVar2 setCanChooseFiles:NO];
    if ([pvVar2 runModalForDirectory:pvVar1_2 file:nil types:nil] == 0x1) {
        pvVar1_5 = [[[pvVar2 URLs] objectAtIndex:0] path];
        [[HSPathsProvider sharedPathsProvider] setCursorLocationFolder:pvVar1_5];
        [self updateUI];
    }
}

- (void)chooseFromFolder:(id)aFolder
{
    [self setDataSource:[self folderCursorsDataSource]];
    [self updateUI];
}

- (void)chooseFromBundle:(id)aBundle
{
    [self setDataSource:[HSCursorsLibraryDataSource sharedCursorsLibraryDataSource]];
}

- (void)chooseFromStack:(id)aStack
{
    [self setDataSource:[self stackCursorsDataSource]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ecb9d @ 000ecb9d, 141 bytes * /

uint FUN_000ecb9d(HSCursorAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  uint uVar3;
  
  pvVar1 = self->_dataSource;
  pvVar2 = _objc_msgSend(self,sel_stackCursorsDataSource);
  if (pvVar1 == pvVar2) {
    uVar3 = 2;
  }
  else {
    pvVar1 = self->_dataSource;
    pvVar2 = _objc_msgSend(cls_HSCursorsLibraryDataSource,sel_sharedCursorsLibraryDataSource);
    if (pvVar1 == pvVar2) {
      uVar3 = 1;
    }
    else {
      pvVar1 = self->_dataSource;
      pvVar2 = _objc_msgSend(self,sel_folderCursorsDataSource);
      uVar3 = 0x7fffffff;
      if (pvVar1 == pvVar2) {
        uVar3 = 3;
      }
    }
  }
  return uVar3;
}

*/
- (NSUInteger)tagForCurrentDataSource
{
    if (_dataSource == [self stackCursorsDataSource]) {
        return 2;
    }
    if (_dataSource == [HSCursorsLibraryDataSource sharedCursorsLibraryDataSource]) {
        return 1;
    }
    if (_dataSource == [self folderCursorsDataSource]) {
        return 3;
    }
    return NSNotFound;
    return 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000eca34 @ 000eca34, 361 bytes * /

void FUN_000eca34(HSCursorAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider);
  self_00 = _objc_msgSend(pvVar1,sel_cursorLocationFolder);
  pvVar1 = self->_imageView;
  pvVar2 = _objc_msgSend(cls_NSWorkspace,sel_sharedWorkspace);
  pvVar2 = _objc_msgSend(pvVar2,sel_iconForFile_,self_00);
  _objc_msgSend(pvVar1,sel_setImage_,pvVar2);
  pvVar1 = self->_currentPath;
  pvVar2 = _objc_msgSend(self_00,sel_lastPathComponent);
  _objc_msgSend(pvVar1,sel_setStringValue_,pvVar2);
  pvVar1 = _objc_msgSend(self,sel_folderCursorsDataSource);
  _objc_msgSend(pvVar1,sel_setPath_,self_00);
  pvVar1 = _objc_msgSend(self,sel_dataSource);
  pvVar1 = _objc_msgSend(self,sel_contentSubviewForFolderDataSource_,pvVar1);
  _objc_msgSend(self,sel_mountFolderTabContentView_,pvVar1);
  _objc_msgSend(self->_gridControl,sel_reloadData);
  _objc_msgSend(self->_gridControl,sel_sizeToCells);
  return;
}

*/
- (void)updateUI
{
    id folder = [[HSPathsProvider sharedPathsProvider] cursorLocationFolder];
    [_imageView setImage:[[NSWorkspace sharedWorkspace] iconForFile:folder]];
    [_currentPath setStringValue:[folder lastPathComponent]];
    [[self folderCursorsDataSource] setPath:folder];
    [self mountFolderTabContentView:[self contentSubviewForFolderDataSource:[self dataSource]]];
    [_gridControl reloadData];
    [_gridControl sizeToCells];
}

- (void)viewDidAppear:(BOOL)aAppear
{
    [super viewDidAppear:aAppear];
    [self validatePaneSwither];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ed911 @ 000ed911, 382 bytes * /

void FUN_000ed911(HSCursorAssistantPane *self,SEL _cmd,BOOL viewWillAppear)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  HSCursorAssistantPane *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSObjectAssistantPaneWithApplier_00350810;
  _objc_msgSendSuper(&local_1c,sel_viewWillAppear_,(int)viewWillAppear);
  pvVar1 = _objc_msgSend(self,sel_stackCursorsDataSource);
  pvVar2 = _objc_msgSend(pvVar1,sel_countOfCursors);
  if (pvVar2 != (id)0x0) {
    _objc_msgSend(self,sel_setDataSource_,pvVar1);
    _objc_msgSend(pvVar1,sel_updateCursors);
    _objc_msgSend(self->_gridControl,sel_reloadData);
    pvVar1 = _objc_msgSend(self->_sourceMatrix,sel_cellWithTag_,2);
    self_00 = cls_NSString;
    pvVar2 = _objc_msgSend(self,sel_stackCursorsDataSource);
    pvVar2 = _objc_msgSend(pvVar2,sel_countOfCursors);
    pvVar3 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_In_Use___d_,
                           &cfstr_empty,&cfstr_AssistantPanes);
    pvVar2 = _objc_msgSend(self_00,sel_stringWithFormat_,pvVar3,pvVar2);
    _objc_msgSend(pvVar1,sel_setTitle_,pvVar2);
  }
  return;
}

*/
- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    id stackCursors = [self stackCursorsDataSource];
    if ([stackCursors countOfCursors] != 0) {
        [self setDataSource:stackCursors];
        [stackCursors updateCursors];
        [_gridControl reloadData];
        [[_sourceMatrix cellWithTag:2] setTitle:[NSString stringWithFormat:[[NSBundle mainBundle] localizedStringForKey:@"In Use (%d)" value:@"" table:@"AssistantPanes"], (int)[[self stackCursorsDataSource] countOfCursors]]];
    }
}

- (void)viewDidLoad
{
    HSIconsGrid *self_01;
    int iVar2;

    [_gridControl setDataSource:self];
    [_gridControl setDelegate:self];
    [_gridControl setCellSize:NSMakeSize(37.0, 36.0)];
    [_gridControl setAllowsEmptySelection:YES];
    self_01 = _gridControl;
    iVar2 = 7;
    do {
        [self_01 addColumn];
        iVar2 = iVar2 + -1;
        self_01 = _gridControl;
    } while (iVar2 != 0);
    [self_01 reloadData];
    [_gridControl sizeToCells];
    [_sourceMatrix setBackgroundRenderer:[HSAssistantSegmentedControlBackgroundRenderer sharedBackgroundRenderer]];
}

- (id)iconAtIndex:(NSInteger)aIndex inIconsGrid:(id)aGrid
{
    return [[[self dataSource] cursorAtIndex:aIndex] image];
}

- (NSUInteger)iconsCountInIconsGrid:(id)aGrid
{
    return (unsigned int)[[self dataSource] countOfCursors];
}

- (id)HSCursorAssistantPane_applier
{
    return [self applier];
}

- (Class)applierClass
{
    return [HSCursorAssistantPaneApplier class];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_folderCursorsDataSource release];
    [_stackCursorsDataSource release];
    [_gridControl dataSource];
    [_gridControl setDataSource:0];
    [_paneSwitcher setDelegate:self];
    [_paneSwitcher release];
    [_gridContentView release];
    [_placeholderView release];
    [_folderTabView release];
    [_folderTabPlaceholderView release];
    [_currentContentView release];
    [_currentFolderTabContentView release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"HSChooseCursorAssistantPane"];
    return self;
}

@end

@implementation HSCursorAssistantPaneApplier

/* i386 ivar offsets: _initialCursor=0xc, _currentCursor=0x10 */

- (BOOL)areSettingsEqual
{
    BOOL BVar1;

    if (_initialCursor == nil && _currentCursor == nil) {
        BVar1 = YES;
    }
    else {
        BVar1 = (BOOL)[_initialCursor isEqual:_currentCursor];
    }
    return BVar1;
}

- (BOOL)canApplyCurrentSettings
{
    return _currentCursor != nil;
}

- (void)setHyperCursor:(id)aCursor
{
    if (_currentCursor != aCursor) {
        [_currentCursor release];
        _currentCursor = [aCursor retain];
        [self disableUndo];
        [[self cursorAttributes] setHyperCursor:_currentCursor];
        [self enableUndo];
    }
}

- (id)hyperCursor
{
    return _currentCursor;
}

- (void)makeCurrentEqualToInitial
{
    [_currentCursor release];
    _currentCursor = [_initialCursor retain];
}

- (void)makeInitialEqualToCurrent
{
    [_initialCursor release];
    _initialCursor = [_currentCursor retain];
}

- (void)setInitialSettingsToObject
{
    [[self cursorAttributes] setHyperCursor:_initialCursor];
}

- (void)setCurrentSettingsToObject
{
    [[self cursorAttributes] setHyperCursor:_currentCursor];
}

- (void)setUpInitialSettings
{
    id pvVar1_3;

    pvVar1_3 = [[[self cursorAttributes] hyperCursor] retain];
    _initialCursor = pvVar1_3;
    _currentCursor = [pvVar1_3 retain];
}

- (void)dealloc
{
    [_initialCursor release];
    [_currentCursor release];
    [super dealloc];
}

- (id)undoActionName
{
    return [[NSBundle mainBundle] localizedStringForKey:@"Change Cursor" value:@"" table:@"UndoManager"];
}

- (id)cursorAttributes
{
    return [[self object] queryHyperInterface:@protocol(HSCursorAttributes)];
}

@end

