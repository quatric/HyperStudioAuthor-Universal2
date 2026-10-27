#import "HSShowInFinderActionAssistantPane.h"

@implementation HSShowInFinderActionAssistantPane

/* i386 ivar offsets: _pathTextField=0x88, _fileIconForPath=0x8c */

- (void)controlTextDidChange:(id)aChange
{
    if ([aChange object] == _pathTextField) {
        [[self showInFinderActionAssistantPaneApplier] setFilePath:[_pathTextField stringValue]];
    }
}

- (id)helpTopicKey
{
    return @"HSShowInFinder";
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002647de @ 002647de, 295 bytes * /

void FUN_002647de(HSShowInFinderActionAssistantPane *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  undefined4 uVar3;
  id pvVar4;
  id pvVar5;
  cfstringStruct *pcVar6;
  
  pvVar1 = _objc_msgSend(self,sel_actionAttributes);
  pvVar2 = _objc_msgSend(pvVar1,sel_filePath);
  self_00 = cls_HSNavigationController;
  uVar3 = _NSHomeDirectory();
  pvVar4 = _objc_msgSend(pvVar2,sel_stringByExpandingTildeInPath);
  pvVar5 = _objc_msgSend(self_00,sel_findFile_base_,pvVar4,uVar3);
  pvVar1 = self->_pathTextField;
  if (pvVar2 == (id)0x0) {
    pcVar6 = &cfstr_empty;
  }
  else {
    pvVar2 = _objc_msgSend(pvVar2,sel_lastPathComponent,pvVar4,uVar3);
    pcVar6 = _objc_msgSend(pvVar2,sel_stringByDeletingPathExtension);
  }
  _objc_msgSend(pvVar1,sel_setStringValue_,pcVar6,uVar3);
  if (pvVar5 != (id)0x0) {
    pvVar1 = self->_fileIconForPath;
    pvVar2 = _objc_msgSend(cls_NSWorkspace,sel_sharedWorkspace,pcVar6,uVar3);
    pvVar2 = _objc_msgSend(pvVar2,sel_iconForFile_,pvVar5);
    _objc_msgSend(pvVar1,sel_setImage_,pvVar2);
  }
  return;
}

*/
- (void)validateUI
{
    NSString *filePath = [[self actionAttributes] filePath];
    id foundPath = [HSNavigationController findFile:[filePath stringByExpandingTildeInPath] base:NSHomeDirectory()];
    [_pathTextField setStringValue:filePath == nil ? @"" : [[filePath lastPathComponent] stringByDeletingPathExtension]];
    if (foundPath != nil) {
        [_fileIconForPath setImage:[[NSWorkspace sharedWorkspace] iconForFile:foundPath]];
    }
}

- (void)validateUIWithNotification:(id)aNotification
{
    [self validateUI];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00264905 @ 00264905, 520 bytes * /

void FUN_00264905(HSShowInFinderActionAssistantPane *self,SEL _cmd,id chooseFilePath)

{
  undefined *self_00;
  id pvVar1;
  id self_01;
  id pvVar2;
  cfstringStruct *pcVar3;
  id pvVar4;
  SEL op;
  int extraout_EDX;
  
  pvVar1 = _objc_msgSend(cls_NSOpenPanel,sel_openPanel);
  self_01 = _objc_msgSend(pvVar1,sel_retain);
  pvVar1 = (id)0x1;
  _objc_msgSend(self_01,sel_setCanChooseDirectories_,1);
  pvVar2 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider);
  pvVar2 = _objc_msgSend(pvVar2,sel_usersDocumentsFolder);
  if (pvVar2 != (id)0x0) {
    op = sel_setDirectory_;
    if (1038.0 < *(double *)PTR_0033605c || *(double *)PTR_0033605c == 1038.0) {
      pvVar2 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_isDirectory_,pvVar2,1);
      op = sel_setDirectoryURL_;
    }
    _objc_msgSend(self_01,op,pvVar2);
    pvVar1 = pvVar2;
  }
  pvVar2 = _objc_msgSend(self_01,sel_runModal,pvVar1);
  if (pvVar2 == (id)0x1) {
    pvVar2 = _objc_msgSend(self_01,sel_URL,pvVar1);
    pvVar2 = _objc_msgSend(pvVar2,sel_path);
    if (pvVar2 != (id)0x0) {
      pcVar3 = (cfstringStruct *)_NSHomeDirectory();
      pvVar1 = _objc_msgSend(pvVar2,sel_rangeOfString_,pcVar3);
      self_00 = cls_NSString;
      if (extraout_EDX != 0) {
        pvVar4 = _objc_msgSend(pvVar2,sel_length,pcVar3);
        pvVar1 = _objc_msgSend(pvVar2,sel_substringWithRange_,extraout_EDX + (int)pvVar1,
                               (int)pvVar4 - (extraout_EDX + (int)pvVar1));
        pcVar3 = &cfstr____;
        pvVar2 = _objc_msgSend(self_00,sel_stringWithFormat_,&cfstr____,pvVar1);
      }
      pvVar1 = _objc_msgSend(self,sel_showInFinderActionAssistantPaneApplier,pcVar3);
      _objc_msgSend(pvVar1,sel_setFilePath_,pvVar2);
      pvVar1 = pvVar2;
    }
  }
  _objc_msgSend(self_01,sel_release,pvVar1);
  _objc_msgSend(self,sel_validateUI);
  return;
}

*/
- (void)chooseFilePath:(id)aPath
{
    NSOpenPanel *panel = [[NSOpenPanel openPanel] retain];
    [panel setCanChooseDirectories:YES];
    id documentsFolder = [[HSPathsProvider sharedPathsProvider] usersDocumentsFolder];
    if (documentsFolder != nil) {
        [panel setDirectoryURL:[NSURL fileURLWithPath:documentsFolder isDirectory:YES]];
    }
    if ([panel runModal] == NSOKButton) {
        NSString *path = [[panel URL] path];
        if (path != nil) {
            NSRange range = [path rangeOfString:NSHomeDirectory()];
            if (range.length != 0) {
                path = [NSString stringWithFormat:@"~%@", [path substringWithRange:NSMakeRange(NSMaxRange(range), [path length] - NSMaxRange(range))]];
            }
            [[self showInFinderActionAssistantPaneApplier] setFilePath:path];
        }
    }
    [panel release];
    [self validateUI];
}

- (id)initialKeyView
{
    return _pathTextField;
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [self removeActionAssistantPaneObserver];
    [super viewWillDisappear:aDisappear];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [self validateUI];
    [self addActionAssistantPaneObserver];
}

- (id)actionAttribute
{
    return (id)@protocol(HSShowInFinderActionAttributes);
}

- (id)actionAttributes
{
    return [[self showInFinderActionAssistantPaneApplier] showInFinderActionAttributes];
}

- (id)actionType
{
    return [HSShowInFinderAction actionType];
}

- (id)showInFinderActionAssistantPaneApplier
{
    return [self applier];
}

- (Class)applierClass
{
    return [HSShowInFinderActionAssistantPaneApplier class];
}

- (id)init
{
    self = [super initWithNibName:@"ShowInFinderAssistantPane"];
    return self;
}

@end

@implementation HSShowInFinderActionAssistantPaneApplier

/* i386 ivar offsets: _filePath=0x30, _initialFilePath=0x34 */

- (BOOL)areSettingsEqual
{
    BOOL pvVar1;
    BOOL bVar2;

    pvVar1 = [super areSettingsEqual];
    bVar2 = pvVar1;
    if (_initialFilePath != nil || _filePath != nil) {
        pvVar1 = [_initialFilePath isEqual:_filePath];
        bVar2 = (BOOL)(bVar2 & pvVar1);
    }
    return bVar2;
}

- (void)makeCurrentEqualToInitial
{
    [super makeCurrentEqualToInitial];
    [_filePath release];
    _filePath = [_initialFilePath retain];
}

- (void)makeInitialEqualToCurrent
{
    [super makeInitialEqualToCurrent];
    [_initialFilePath release];
    _initialFilePath = [_filePath retain];
}

- (void)setInitialSettingsToObject
{
    [[self showInFinderActionAttributes] setFilePath:_initialFilePath];
    [super setInitialSettingsToObject];
}

- (void)setCurrentSettingsToObject
{
    [super setCurrentSettingsToObject];
    [[self showInFinderActionAttributes] setFilePath:_filePath];
}

- (void)setFilePath:(id)aPath
{
    if (![_filePath isEqualToString:aPath]) {
        [_filePath release];
        _filePath = [aPath retain];
        [self disableUndo];
        [[self showInFinderActionAttributes] setFilePath:_filePath];
        [self enableUndo];
    }
}

- (void)setUpInitialSettings
{
    _filePath = [[[self showInFinderActionAttributes] filePath] retain];
    _initialFilePath = [[[self showInFinderActionAttributes] filePath] retain];
}

- (id)showInFinderActionAttributes
{
    return [[self actionAttributes] queryHyperInterface:@protocol(HSShowInFinderActionAttributes)];
}

- (void)dealloc
{
    [_filePath release];
    [_initialFilePath release];
    [super dealloc];
}

@end

