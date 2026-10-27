#import "HSRunAppleScriptActionAssistantPane.h"

@implementation HSRunAppleScriptActionAssistantPane

/* i386 ivar offsets: _scriptView=0x88, _checkButton=0x8c, _runButton=0x90, _offScreenScriptView=0x94, _scriptController=0x98 */

- (void)textViewDidChangeSelection:(id)aSelection
{
    [_scriptView setTypingAttributes:[_offScreenScriptView typingAttributes]];
}

- (void)textDidChange:(id)aChange
{
    [[self runAppleScriptActionAssistantPaneApplier] setAppleScriptSource:[[_scriptView textStorage] string]];
    [self validateButtons];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00110530 @ 00110530, 299 bytes * /

void FUN_00110530(HSRunAppleScriptActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(cls_HSAlert,sel_new);
  pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  _objc_msgSend(pvVar1,sel_setAlertStyle_,5);
  pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                         &cfstr_NBA_RunAppleScript_Error_MessageText,&cfstr_empty,&cfstr_Alerts);
  _objc_msgSend(pvVar1,sel_setMessageText_,pvVar2);
  pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                         &cfstr_NBA_RunAppleScript_Error_DescriptionText,&cfstr_empty,&cfstr_Alerts)
  ;
  _objc_msgSend(pvVar1,sel_setInformativeText_,pvVar2);
  _objc_msgSend(pvVar1,sel_runModal);
  return;
}

*/
- (void)showErrorAlert
{
    HSAlert *alert = [[HSAlert new] autorelease];
    [alert setAlertStyle:5];
    [alert setMessageText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"NBA_RunAppleScript_Error_MessageText" value:@"" table:@"Alerts"]];
    [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"NBA_RunAppleScript_Error_DescriptionText" value:@"" table:@"Alerts"]];
    [alert runModal];
}

- (BOOL)compile:(id *)aCompile
{
    char cVar1;
    NSTextStorage *self_00;
    NSTextStorage *pvVar2;
    NSString *pvVar3;
    NSAttributedString *pvVar2_2;

    if ((_scriptView == nil) || (_offScreenScriptView == nil) ) {
        cVar1 = NO;
    }
    else {
        self_00 = [_scriptView textStorage];
        pvVar2 = [_offScreenScriptView textStorage];
        pvVar3 = [self_00 string];
        [pvVar2 replaceCharactersInRange:NSMakeRange(0, [pvVar2 length]) withString:pvVar3];
        cVar1 = [[[[OSAScript alloc] initWithSource:pvVar3] autorelease] compileAndReturnError:aCompile];
        if (cVar1 != NO) {
            [_scriptController compileScript:0];
            pvVar2_2 = [pvVar2 attributedSubstringFromRange:NSMakeRange(0, [pvVar2 length])];
            [self_00 replaceCharactersInRange:NSMakeRange(0, [self_00 length]) withAttributedString:pvVar2_2];
        }
    }
    return cVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001101c2 @ 001101c2, 448 bytes * /

void FUN_001101c2(HSRunAppleScriptActionAssistantPane *self,SEL _cmd)

{
  HSPlaceholderTextView *self_00;
  undefined4 uVar1;
  undefined4 uVar2;
  undefined *self_01;
  id self_02;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  
  self_02 = _objc_msgSend(self->_scriptView,sel_textStorage);
  pvVar3 = _objc_msgSend(self_02,sel_length);
  if (pvVar3 != (id)0x0) {
    self_00 = self->_scriptView;
    pvVar3 = _objc_msgSend(self->_offScreenScriptView,sel_typingAttributes);
    _objc_msgSend(self_00,sel_setTypingAttributes_,pvVar3);
    pvVar3 = _objc_msgSend(self->_scriptView,sel_typingAttributes);
    self_01 = cls_NSDictionary;
    uVar1 = *(undefined4 *)PTR_00336068;
    pvVar4 = _objc_msgSend(pvVar3,sel_objectForKey_,&cfstr_NSFont);
    uVar2 = *(undefined4 *)PTR_00336394;
    pvVar3 = _objc_msgSend(pvVar3,sel_objectForKey_,&cfstr_NSColor);
    pvVar3 = _objc_msgSend(self_01,sel_dictionaryWithObjectsAndKeys_,pvVar3,uVar2,pvVar4,uVar1,0);
    pvVar4 = _objc_msgSend(cls_NSAttributedString,sel_alloc);
    pvVar5 = _objc_msgSend(self_02,sel_string);
    pvVar3 = _objc_msgSend(pvVar4,sel_initWithString_attributes_,pvVar5,pvVar3);
    pvVar4 = _objc_msgSend(self_02,sel_length);
    _objc_msgSend(self_02,sel_replaceCharactersInRange_withAttributedString_,0,pvVar4,pvVar3);
    _objc_msgSend(pvVar3,sel_release);
  }
  return;
}

*/
- (void)validateStyleForContainsText
{
    NSTextStorage *storage = [_scriptView textStorage];
    if ([storage length] != 0) {
        [_scriptView setTypingAttributes:[_offScreenScriptView typingAttributes]];
        NSDictionary *typingAttributes = [_scriptView typingAttributes];
        id font = [typingAttributes objectForKey:@"NSFont"];
        id color = [typingAttributes objectForKey:@"NSColor"];
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:color, NSForegroundColorAttributeName, font, NSFontAttributeName, nil];
        NSAttributedString *styled = [[NSAttributedString alloc] initWithString:[storage string] attributes:attributes];
        [storage replaceCharactersInRange:NSMakeRange(0, [storage length]) withAttributedString:styled];
        [styled release];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001100e3 @ 001100e3, 223 bytes * /

void FUN_001100e3(HSRunAppleScriptActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  undefined4 uVar2;
  
  pvVar1 = _objc_msgSend(self->_scriptView,sel_textStorage);
  pvVar1 = _objc_msgSend(pvVar1,sel_length);
  if (pvVar1 == (id)0x0) {
    _objc_msgSend(self->_checkButton,sel_setEnabled_,0);
    pvVar1 = self->_runButton;
    uVar2 = 0;
  }
  else {
    pvVar1 = _objc_msgSend(self->_runButton,sel_isEnabled);
    if ((char)pvVar1 != '\0') {
      return;
    }
    _objc_msgSend(self->_checkButton,sel_setEnabled_,1);
    pvVar1 = self->_runButton;
    uVar2 = 1;
  }
  _objc_msgSend(pvVar1,sel_setEnabled_,uVar2);
  return;
}

*/
- (void)validateButtons
{
    if ([[_scriptView textStorage] length] == 0) {
        [_checkButton setEnabled:NO];
        [_runButton setEnabled:NO];
    } else if (![_runButton isEnabled]) {
        [_checkButton setEnabled:YES];
        [_runButton setEnabled:YES];
    }
}

- (void)validateUI
{
    NSTextStorage *self_00;
    NSString *pvVar2;
    id pvVar1_2;
    unsigned pvVar2_3;

    pvVar1_2 = [[self actionAttributes] appleScriptSource];
    if (pvVar1_2 == nil) {
        pvVar1_2 = [NSString string];
    }
    self_00 = [_scriptView textStorage];
    pvVar2 = [self_00 string];
    if (![pvVar2 isEqual:pvVar1_2]) {
        pvVar2_3 = [self_00 length];
        [self_00 replaceCharactersInRange:NSMakeRange(0, pvVar2_3) withString:pvVar1_2];
    }
    [self validateButtons];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0010ff71 @ 0010ff71, 132 bytes * /

void FUN_0010ff71(HSRunAppleScriptActionAssistantPane *self,SEL _cmd,id runScript)

{
  id pvVar1;
  int *piVar2;
  int *piVar3;
  int local_14;
  
  local_14 = 0;
  piVar3 = &local_14;
  piVar2 = piVar3;
  pvVar1 = _objc_msgSend(self,sel_compile_,piVar3);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(self->_scriptController,sel_script,piVar2);
    _objc_msgSend(pvVar1,sel_executeAndReturnError_,piVar3);
    piVar2 = piVar3;
  }
  if (local_14 != 0) {
    _objc_msgSend(self,sel_showErrorAlert,piVar2);
  }
  return;
}

*/
- (void)runScript:(id)aScript
{
    id error = nil;
    if ([self compile:&error]) {
        [[_scriptController script] executeAndReturnError:&error];
    }
    if (error != nil) {
        [self showErrorAlert];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0010ff23 @ 0010ff23, 78 bytes * /

void FUN_0010ff23(HSRunAppleScriptActionAssistantPane *self,SEL _cmd,id compileScript)

{
  id pvVar1;
  undefined4 *puVar2;
  undefined4 local_10;
  
  local_10 = 0;
  puVar2 = &local_10;
  pvVar1 = _objc_msgSend(self,sel_compile_,puVar2);
  if ((char)pvVar1 == '\0') {
    _objc_msgSend(self,sel_showErrorAlert,puVar2);
  }
  return;
}

*/
- (void)compileScript:(id)aScript
{
    id error = nil;
    if (![self compile:&error]) {
        [self showErrorAlert];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0010fc87 @ 0010fc87, 668 bytes * /

void FUN_0010fc87(HSRunAppleScriptActionAssistantPane *self,SEL _cmd,id chooseScriptFile)

{
  id pvVar1;
  id pvVar2;
  cfstringStruct *self_00;
  id pvVar3;
  cfstringStruct *pcVar4;
  SEL op;
  cfstringStruct *pcVar5;
  cfstringStruct *pcVar6;
  undefined4 uVar7;
  
  pvVar1 = _objc_msgSend(cls_NSOpenPanel,sel_openPanel);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  pvVar2 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider);
  pvVar2 = _objc_msgSend(pvVar2,sel_appleScriptsFolder);
  if (pvVar2 != (id)0x0) {
    op = sel_setDirectory_;
    if (1038.0 < *(double *)PTR_0033605c || *(double *)PTR_0033605c == 1038.0) {
      pvVar2 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_isDirectory_,pvVar2,1);
      op = sel_setDirectoryURL_;
    }
    _objc_msgSend(pvVar1,op,pvVar2);
  }
  pcVar6 = &cfstr_scptd;
  pcVar5 = &cfstr_scpt;
  uVar7 = 0;
  self_00 = _objc_msgSend(cls_NSArray,sel_arrayWithObjects_,&cfstr_applescript,&cfstr_scpt,
                          &cfstr_scptd,0);
  pvVar2 = _objc_msgSend(pvVar1,sel_runModalForTypes_,self_00);
  if (pvVar2 == (id)0x1) {
    pvVar2 = _objc_msgSend(pvVar1,sel_URLs,self_00,pcVar5,pcVar6,uVar7);
    self_00 = _objc_msgSend(pvVar2,sel_extraFirstObject);
    pvVar2 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider);
    pvVar3 = _objc_msgSend(self_00,sel_path);
    pvVar3 = _objc_msgSend(pvVar3,sel_stringByDeletingLastPathComponent);
    _objc_msgSend(pvVar2,sel_setAppleScriptsFolder_,pvVar3);
    pvVar2 = _objc_msgSend(cls_NSAppleScript,sel_alloc);
    pcVar5 = (cfstringStruct *)0x0;
    pvVar2 = _objc_msgSend(pvVar2,sel_initWithContentsOfURL_error_,self_00,0);
    pcVar4 = _objc_msgSend(pvVar2,sel_source);
    if (pcVar4 != (cfstringStruct *)0x0) {
      pvVar2 = _objc_msgSend(self->_scriptView,sel_textStorage,self_00,pcVar5);
      pcVar5 = _objc_msgSend(pvVar2,sel_length);
      pcVar6 = pcVar4;
      _objc_msgSend(pvVar2,sel_replaceCharactersInRange_withString_,0,pcVar5,pcVar4);
      pvVar2 = _objc_msgSend(self,sel_runAppleScriptActionAssistantPaneApplier);
      _objc_msgSend(pvVar2,sel_setAppleScriptSource_,pcVar4);
      self_00 = pcVar4;
    }
    _objc_msgSend(self,sel_validateUI,self_00,pcVar5,pcVar6);
  }
  _objc_msgSend(pvVar1,sel_release,self_00,pcVar5,pcVar6,uVar7);
  return;
}

*/
- (void)chooseScriptFile:(id)aFile
{
    NSOpenPanel *panel = [[NSOpenPanel openPanel] retain];
    id folder = [[HSPathsProvider sharedPathsProvider] appleScriptsFolder];
    if (folder != nil) {
        [panel setDirectoryURL:[NSURL fileURLWithPath:folder isDirectory:YES]];
    }
    if ([panel runModalForTypes:[NSArray arrayWithObjects:@"applescript", @"scpt", @"scptd", nil]] == NSOKButton) {
        NSURL *url = [[panel URLs] extraFirstObject];
        [[HSPathsProvider sharedPathsProvider] setAppleScriptsFolder:[[url path] stringByDeletingLastPathComponent]];
        id source = [[[[NSAppleScript alloc] initWithContentsOfURL:url error:nil] autorelease] source];
        if (source != nil) {
            NSTextStorage *storage = [_scriptView textStorage];
            [storage replaceCharactersInRange:NSMakeRange(0, [storage length]) withString:source];
            [[self runAppleScriptActionAssistantPaneApplier] setAppleScriptSource:source];
        }
        [self validateUI];
    }
    [panel release];
}

- (id)helpTopicKey
{
    return @"HSRunAppleScript";
}

- (void)paneDidOK:(id)aOK
{
    [[self runAppleScriptActionAssistantPaneApplier] setAppleScriptSource:[[_scriptView textStorage] string]];
    [super paneDidOK:aOK];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00110beb @ 00110beb, 159 bytes * /

void FUN_00110beb(HSRunAppleScriptActionAssistantPane *self,SEL _cmd,BOOL viewWillDisappear)

{
  id self_00;
  id pvVar1;
  HSRunAppleScriptActionAssistantPane *local_1c;
  undefined *local_18;
  
  if ((self->super).super.super._userMadeTheDecision == '\0') {
    self_00 = _objc_msgSend(self,sel_runAppleScriptActionAssistantPaneApplier);
    pvVar1 = _objc_msgSend(self->_scriptView,sel_textStorage);
    pvVar1 = _objc_msgSend(pvVar1,sel_string);
    _objc_msgSend(self_00,sel_setAppleScriptSource_,pvVar1);
  }
  local_1c = self;
  local_18 = PTR_s_HSNBAAssistantPane_00350e10;
  _objc_msgSendSuper(&local_1c,sel_viewWillDisappear_,(int)viewWillDisappear);
  return;
}

*/
- (void)viewWillDisappear:(BOOL)aDisappear
{
    if (!_userMadeTheDecision) {
        [[self runAppleScriptActionAssistantPaneApplier] setAppleScriptSource:[[_scriptView textStorage] string]];
    }
    [super viewWillDisappear:aDisappear];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [self validateUI];
    [self validateStyleForContainsText];
    [[self runAppleScriptActionAssistantPaneApplier] setUseCustomAppleScriptSource:YES];
    [_scriptView setDelegate:self];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00110d37 @ 00110d37, 313 bytes * /

void FUN_00110d37(HSRunAppleScriptActionAssistantPane *self,SEL _cmd)

{
  HSPlaceholderTextView *self_00;
  id pvVar1;
  HSRunAppleScriptActionAssistantPane *local_24;
  undefined *local_20;
  undefined4 local_1c;
  undefined4 uStack_18;
  undefined4 local_14;
  undefined4 uStack_10;
  
  local_24 = self;
  local_20 = PTR_s_HSNBAAssistantPane_00350e10;
  _objc_msgSendSuper(&local_24,sel_viewDidLoad);
  pvVar1 = _objc_msgSend(cls_OSAScriptController,sel_new);
  self->_scriptController = pvVar1;
  pvVar1 = _objc_msgSend(cls_OSAScriptView,sel_alloc);
  local_1c = 0;
  uStack_18 = 0;
  local_14 = 0x42c80000;
  uStack_10 = 0x42c80000;
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithFrame_,0,0x42c8000042c80000);
  self->_offScreenScriptView = pvVar1;
  _objc_msgSend(self->_scriptController,sel_setScriptView_,pvVar1);
  self_00 = self->_scriptView;
  pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                         &cfstr_NBA_RunAppleScript_Placeholder,&cfstr_empty,&cfstr_AssistantPanes);
  _objc_msgSend(self_00,sel_setPlaceholderString_,pvVar1);
  return;
}

*/
- (void)viewDidLoad
{
    [super viewDidLoad];
    _scriptController = [OSAScriptController new];
    _offScreenScriptView = [[OSAScriptView alloc] initWithFrame:NSMakeRect(0.0f, 0.0f, 100.0f, 100.0f)];
    [_scriptController setScriptView:_offScreenScriptView];
    [_scriptView setPlaceholderString:[[NSBundle mainBundle] localizedStringForKey:@"NBA_RunAppleScript_Placeholder" value:@"" table:@"AssistantPanes"]];
}

- (id)actionType
{
    return [HSRunAppleScriptAction actionType];
}

- (id)actionAttributes
{
    return [[self runAppleScriptActionAssistantPaneApplier] runAppleScriptActionAttributes];
}

- (id)runAppleScriptActionAssistantPaneApplier
{
    return [self applier];
}

- (Class)applierClass
{
    return [HSRunAppleScriptActionAssistantPaneApplier class];
}

- (void)dealloc
{
    [_offScreenScriptView release];
    [_scriptController release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"RunAppleScriptAssistantPane"];
    return self;
}

@end

@implementation HSRunAppleScriptActionAssistantPaneApplier

/* i386 ivar offsets: _initialUseCustomAppleScriptSource=0x30, _initialAppleScriptURL=0x34, _initialAppleScriptSource=0x38, _useCustomAppleScriptSource=0x3c, _appleScriptURL=0x40, _appleScriptSource=0x44 */

- (BOOL)areSettingsEqual
{
    BOOL pvVar1;
    BOOL bVar2;

    pvVar1 = [super areSettingsEqual];
    if ((!pvVar1) || (_initialUseCustomAppleScriptSource != _useCustomAppleScriptSource)) {
        bVar2 = NO;
    }
    else {
        bVar2 = YES;
    }
    if ((_initialAppleScriptURL != nil) || (_appleScriptURL != nil)) {
        if ((bVar2 == NO) || (pvVar1 = [_initialAppleScriptURL isEqual:_appleScriptURL], !pvVar1)) {
            bVar2 = NO;
        }
        else {
            bVar2 = YES;
        }
    }
    if ((_initialAppleScriptSource != nil) || (_appleScriptSource != nil)) {
        if (bVar2 == NO) {
            bVar2 = NO;
        }
        else {
            pvVar1 = [_initialAppleScriptSource isEqual:_appleScriptSource];
            bVar2 = pvVar1;
        }
    }
    return bVar2;
}

- (void)makeCurrentEqualToInitial
{
    [super makeCurrentEqualToInitial];
    [_appleScriptURL release];
    [_appleScriptSource release];
    _appleScriptURL = [_initialAppleScriptURL retain];
    _appleScriptSource = [_initialAppleScriptSource retain];
    _useCustomAppleScriptSource = _initialUseCustomAppleScriptSource;
}

- (void)makeInitialEqualToCurrent
{
    [super makeInitialEqualToCurrent];
    [_initialAppleScriptURL release];
    [_initialAppleScriptSource release];
    _initialAppleScriptURL = [_appleScriptURL retain];
    _initialAppleScriptSource = [_appleScriptSource retain];
    _initialUseCustomAppleScriptSource = _useCustomAppleScriptSource;
}

- (void)setInitialSettingsToObject
{
    [[self runAppleScriptActionAttributes] setUseCustomAppleScriptSource:_initialUseCustomAppleScriptSource];
    [[self runAppleScriptActionAttributes] setAppleScriptURL:_initialAppleScriptURL];
    [[self runAppleScriptActionAttributes] setAppleScriptSource:_initialAppleScriptSource];
    [super setInitialSettingsToObject];
}

- (void)setCurrentSettingsToObject
{
    [super setCurrentSettingsToObject];
    [[self runAppleScriptActionAttributes] setUseCustomAppleScriptSource:_useCustomAppleScriptSource];
    [[self runAppleScriptActionAttributes] setAppleScriptURL:_appleScriptURL];
    [[self runAppleScriptActionAttributes] setAppleScriptSource:_appleScriptSource];
}

- (void)setAppleScriptSource:(id)aSource
{
    if (![_appleScriptSource isEqualToString:aSource]) {
        [_appleScriptSource release];
        _appleScriptSource = [aSource retain];
        [self disableUndo];
        [[self runAppleScriptActionAttributes] setAppleScriptSource:_appleScriptSource];
        [self enableUndo];
    }
}

- (void)setAppleScriptURL:(id)aURL
{
    if (![_appleScriptURL isEqualTo:aURL]) {
        [_appleScriptURL release];
        _appleScriptURL = [aURL retain];
        [self disableUndo];
        [[self runAppleScriptActionAttributes] setAppleScriptURL:_appleScriptURL];
        [self enableUndo];
    }
}

- (void)setUseCustomAppleScriptSource:(BOOL)aSource
{
    if (_useCustomAppleScriptSource != aSource) {
        _useCustomAppleScriptSource = aSource;
        [self disableUndo];
        [[self runAppleScriptActionAttributes] setUseCustomAppleScriptSource:_useCustomAppleScriptSource]
        ;
        [self enableUndo];
    }
}

- (void)setUpInitialSettings
{
    BOOL pvVar1_14;

    _appleScriptURL = [[[self runAppleScriptActionAttributes] appleScriptURL] retain];
    _appleScriptSource = [[[self runAppleScriptActionAttributes] appleScriptSource] retain];
    _initialAppleScriptURL = [[[self runAppleScriptActionAttributes] appleScriptURL] retain];
    _initialAppleScriptSource = [[[self runAppleScriptActionAttributes] appleScriptSource] retain];
    pvVar1_14 = [[self runAppleScriptActionAttributes] useCustomAppleScriptSource];
    _initialUseCustomAppleScriptSource = (BOOL)pvVar1_14;
    _useCustomAppleScriptSource = (BOOL)pvVar1_14;
}

- (id)runAppleScriptActionAttributes
{
    return [[self actionAttributes] queryHyperInterface:@protocol(HSRunAppleScriptActionAttributes)];
}

- (void)dealloc
{
    [_initialAppleScriptURL release];
    [_initialAppleScriptSource release];
    [_appleScriptURL release];
    [_appleScriptSource release];
    [super dealloc];
}

@end

