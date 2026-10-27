#import "HSOpenLocationActionAssistantPane.h"

@implementation HSOpenLocationActionAssistantPane

/* i386 ivar offsets: _documentNameField=0x78, _applicationNameField=0x7c, _documentIconView=0x80, _applicationIconView=0x84, _openDocumentSwitch=0x88, _openApplicationSwitch=0x8c, _quitAfterLaunchSwitch=0x90, _launchInForegroundSwitch=0x94 */

- (void)openApplicationChanged:(id)aChanged
{
    [[self openLocationActionAssistantPaneApplier] setOpensApplication:[aChanged intValue]];
}

- (void)openDocumentChanged:(id)aChanged
{
    [[self openLocationActionAssistantPaneApplier] setOpensDocument:[aChanged intValue]];
}

- (void)launchInForeground:(id)aForeground
{
    [[self openLocationActionAssistantPaneApplier] setLaunchInForeground:[aForeground intValue]];
}

- (void)quitFromPlayer:(id)aPlayer
{
    [[self openLocationActionAssistantPaneApplier] setQuitAfterLaunch:[aPlayer intValue]];
}

- (void)chooseApplication:(id)aApplication
{
    id pvVar1_2;
    NSString *pvVar1_4;

    pvVar1_2 = [[HSOpenPanelProvider sharedOpenPanelProvider] chooseFileOfType:kHSApplicationsFileType];
    if (pvVar1_2 != nil) {
        pvVar1_4 = [[pvVar1_2 lastPathComponent] stringByDeletingPathExtension];
        [[self openLocationActionAssistantPaneApplier] setApplicationName:pvVar1_4];
        [[self openLocationActionAssistantPaneApplier] setOpensApplication:YES];
    }
}

- (void)chooseLocation:(id)aLocation
{
    id pvVar1_2;
    NSURL *pvVar1_3;

    pvVar1_2 = [[HSOpenPanelProvider sharedOpenPanelProvider] chooseFileOfType:kHSUsersDocumentsFileType];
    if (pvVar1_2 != nil) {
        pvVar1_3 = [NSURL fileURLWithPath:pvVar1_2];
        [[self openLocationActionAssistantPaneApplier] setURL:pvVar1_3];
        [[self openLocationActionAssistantPaneApplier] setOpensDocument:YES];
    }
}

- (void)validateUIWithNotification:(id)aNotification
{
    [self validateUI];
}

- (BOOL)shouldEnableOKButtonInNavigationPaneSwitcher:(id)aSwitcher
{
    BOOL bVar2;

    if (![[self actionAttributes] opensApplication]) {
        bVar2 = [[self actionAttributes] opensDocument];
    }
    else {
        bVar2 = YES;
    }
    return bVar2;
}

- (BOOL)canApplyCurrentSettingsForObjectAssistant:(id)aAssistant
{
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00104cbb @ 00104cbb, 994 bytes * /

void FUN_00104cbb(HSOpenLocationActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  cfstringStruct *pcVar5;
  SEL op;
  undefined4 uVar6;
  
  pvVar1 = _objc_msgSend(self,sel_actionAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_URL);
  pvVar1 = _objc_msgSend(pvVar1,sel_path);
  uVar6 = 4;
  pvVar2 = _objc_msgSend(pvVar1,sel_stringByReplacingPercentEscapesUsingEncoding_,4);
  pvVar3 = _objc_msgSend(cls_NSWorkspace,sel_sharedWorkspace);
  pvVar1 = self->_documentNameField;
  if (pvVar2 == (id)0x0) {
    pvVar4 = _objc_msgSend(cls_NSString,sel_string,uVar6);
    _objc_msgSend(pvVar1,sel_setStringValue_,pvVar4);
    pvVar1 = self->_documentIconView;
    pvVar4 = (id)0x0;
  }
  else {
    pvVar4 = _objc_msgSend(pvVar2,sel_lastPathComponent,uVar6);
    _objc_msgSend(pvVar1,sel_setStringValue_,pvVar4);
    pvVar1 = self->_documentIconView;
    pvVar4 = _objc_msgSend(pvVar2,sel_pathExtension);
    pvVar4 = _objc_msgSend(pvVar3,sel_iconForFileType_,pvVar4);
  }
  _objc_msgSend(pvVar1,sel_setImage_,pvVar4);
  _objc_msgSend(self->_openDocumentSwitch,sel_setEnabled_,(uint)(pvVar2 != (id)0x0));
  pvVar1 = self->_openDocumentSwitch;
  pvVar2 = _objc_msgSend(self,sel_actionAttributes);
  pvVar2 = _objc_msgSend(pvVar2,sel_opensDocument);
  _objc_msgSend(pvVar1,sel_setState_,(uint)((char)pvVar2 != '\0'));
  pvVar1 = _objc_msgSend(self,sel_actionAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_applicationName);
  if (pvVar1 == (id)0x0) {
    _objc_msgSend(self->_applicationNameField,sel_setStringValue_,&cfstr_empty);
    pvVar2 = self->_applicationIconView;
    pvVar3 = (id)0x0;
  }
  else {
    _objc_msgSend(self->_applicationNameField,sel_setStringValue_,pvVar1);
    pvVar2 = _objc_msgSend(pvVar1,sel_stringByAppendingPathExtension_,&cfstr_app);
    pcVar5 = _objc_msgSend(pvVar3,sel_fullPathForApplication_,pvVar2);
    pvVar2 = self->_applicationIconView;
    op = sel_iconForFile_;
    if (pcVar5 == (cfstringStruct *)0x0) {
      pcVar5 = &cfstr_APPL;
      op = sel_iconForFileType_;
    }
    pvVar3 = _objc_msgSend(pvVar3,op,pcVar5);
  }
  _objc_msgSend(pvVar2,sel_setImage_,pvVar3);
  _objc_msgSend(self->_openApplicationSwitch,sel_setEnabled_,(uint)(pvVar1 != (id)0x0));
  pvVar1 = self->_openApplicationSwitch;
  pvVar2 = _objc_msgSend(self,sel_actionAttributes);
  pvVar2 = _objc_msgSend(pvVar2,sel_opensApplication);
  _objc_msgSend(pvVar1,sel_setState_,(uint)((char)pvVar2 != '\0'));
  pvVar1 = self->_quitAfterLaunchSwitch;
  pvVar2 = _objc_msgSend(self,sel_actionAttributes);
  pvVar2 = _objc_msgSend(pvVar2,sel_quitAfterLaunch);
  _objc_msgSend(pvVar1,sel_setState_,(uint)((char)pvVar2 == '\x01'));
  pvVar1 = self->_launchInForegroundSwitch;
  pvVar2 = _objc_msgSend(self,sel_actionAttributes);
  pvVar2 = _objc_msgSend(pvVar2,sel_launchInForeground);
  _objc_msgSend(pvVar1,sel_setState_,(uint)((char)pvVar2 == '\x01'));
  pvVar1 = _objc_msgSend(self,sel_navigationPaneSwitcher);
  _objc_msgSend(pvVar1,sel_validateUserInterface);
  return;
}

*/
- (void)validateUI
{
    NSString *documentPath = [[[[self actionAttributes] URL] path] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    if (documentPath == nil) {
        [_documentNameField setStringValue:[NSString string]];
        [_documentIconView setImage:nil];
    } else {
        [_documentNameField setStringValue:[documentPath lastPathComponent]];
        [_documentIconView setImage:[workspace iconForFileType:[documentPath pathExtension]]];
    }
    [_openDocumentSwitch setEnabled:documentPath != nil];
    [_openDocumentSwitch setState:[[self actionAttributes] opensDocument]];
    NSString *applicationName = [[self actionAttributes] applicationName];
    if (applicationName == nil) {
        [_applicationNameField setStringValue:@""];
        [_applicationIconView setImage:nil];
    } else {
        [_applicationNameField setStringValue:applicationName];
        NSString *applicationPath = [workspace fullPathForApplication:[applicationName stringByAppendingPathExtension:@"app"]];
        [_applicationIconView setImage:applicationPath != nil ? [workspace iconForFile:applicationPath] : [workspace iconForFileType:@"APPL"]];
    }
    [_openApplicationSwitch setEnabled:applicationName != nil];
    [_openApplicationSwitch setState:[[self actionAttributes] opensApplication]];
    [_quitAfterLaunchSwitch setState:[[self actionAttributes] quitAfterLaunch] == YES];
    [_launchInForegroundSwitch setState:[[self actionAttributes] launchInForeground] == YES];
    [[self navigationPaneSwitcher] validateUserInterface];
}

- (id)helpTopicKey
{
    return @"HSAnotherProgram";
}

- (void)viewDidAppear:(BOOL)aAppear
{
    [super viewDidAppear:aAppear];
    [[self navigationPaneSwitcher] validateUserInterface];
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [self removeActionAssistantPaneObserver];
    [super viewWillDisappear:aDisappear];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [self addActionAssistantPaneObserver];
    [self validateUI];
}

- (id)actionAttribute
{
    return (id)@protocol(HSOpenLocationActionAttributes);
}

- (id)actionAttributes
{
    return [[self openLocationActionAssistantPaneApplier] openLocationActionAttributes];
}

- (id)actionType
{
    return [HSOpenLocationAction actionType];
}

- (id)openLocationActionAssistantPaneApplier
{
    return [self applier];
}

- (Class)applierClass
{
    return [HSOpenLocationActionAssistantPaneApplier class];
}

- (id)init
{
    self = [super initWithNibName:@"OpenLocationAssistantPane"];
    return self;
}

@end

@implementation HSOpenLocationActionAssistantPaneApplier

/* i386 ivar offsets: _quitFromPlayer=0x30, _launchInForeground=0x31, _opensDocument=0x32, _opensApplication=0x33, _applicationName=0x34, _URL=0x38, _initialQuitFromPlayer=0x3c, _initialLaunchInForeground=0x3d, _initialOpensDocument=0x3e, _initialOpensApplication=0x3f, _initialApplicationName=0x40, _initialURL=0x44 */

- (void)setOpensApplication:(BOOL)aApplication
{
    if (_opensApplication != aApplication) {
        _opensApplication = aApplication;
        [self disableUndo];
        [[self openLocationActionAttributes] setOpensApplication:_opensApplication];
        [self enableUndo];
    }
}

- (void)setOpensDocument:(BOOL)aDocument
{
    if (_opensDocument != aDocument) {
        _opensDocument = aDocument;
        [self disableUndo];
        [[self openLocationActionAttributes] setOpensDocument:_opensDocument];
        [self enableUndo];
    }
}

- (void)setLaunchInForeground:(BOOL)aForeground
{
    if (_launchInForeground != aForeground) {
        _launchInForeground = aForeground;
        [self disableUndo];
        [[self openLocationActionAttributes] setLaunchInForeground:_launchInForeground];
        [self enableUndo];
    }
}

- (void)setQuitAfterLaunch:(BOOL)aLaunch
{
    if (_quitFromPlayer != aLaunch) {
        _quitFromPlayer = aLaunch;
        [self disableUndo];
        [[self openLocationActionAttributes] setQuitAfterLaunch:_quitFromPlayer];
        [self enableUndo];
    }
}

- (void)setURL:(id)aURL
{
    if (![_URL isEqual:aURL]) {
        [_URL release];
        _URL = [aURL retain];
        [self disableUndo];
        [[self openLocationActionAttributes] setURL:_URL];
        [self enableUndo];
    }
}

- (void)setApplicationName:(id)aName
{
    if (![_applicationName isEqual:aName]) {
        [_applicationName release];
        _applicationName = [aName retain];
        [self disableUndo];
        [[self openLocationActionAttributes] setApplicationName:_applicationName];
        [self enableUndo];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001054bf @ 001054bf, 184 bytes * /

BOOL FUN_001054bf(HSOpenLocationActionAssistantPaneApplier *self,SEL _cmd)

{
  id pvVar1;
  bool bVar2;
  HSOpenLocationActionAssistantPaneApplier *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_HSActionAssistantSettingsApplier_00350b40;
  pvVar1 = _objc_msgSendSuper(&local_14,sel_areSettingsEqual);
  if (((((char)pvVar1 == '\0') || (self->_quitFromPlayer != self->_initialQuitFromPlayer)) ||
      (self->_opensDocument != self->_initialOpensDocument)) ||
     ((self->_opensApplication != self->_initialOpensApplication ||
      (self->_launchInForeground != self->_initialLaunchInForeground)))) {
LAB_00105573:
    bVar2 = false;
  }
  else {
    if (self->_applicationName != (id)0x0 || self->_initialApplicationName != (id)0x0) {
      pvVar1 = _objc_msgSend(self->_applicationName,sel_isEqual_,self->_initialApplicationName);
      if ((char)pvVar1 == '\0') goto LAB_00105573;
    }
    if (self->_URL == (id)0x0 && self->_initialURL == (id)0x0) {
      bVar2 = true;
    }
    else {
      pvVar1 = _objc_msgSend(self->_URL,sel_isEqual_,self->_initialURL);
      bVar2 = (char)pvVar1 != '\0';
    }
  }
  return bVar2;
}

*/
- (BOOL)areSettingsEqual
{
    if (![super areSettingsEqual] || _quitFromPlayer != _initialQuitFromPlayer || _opensDocument != _initialOpensDocument
        || _opensApplication != _initialOpensApplication || _launchInForeground != _initialLaunchInForeground) {
        return NO;
    }
    if ((_applicationName != nil || _initialApplicationName != nil) && ![_applicationName isEqual:_initialApplicationName]) {
        return NO;
    }
    if (_URL == nil && _initialURL == nil) {
        return YES;
    }
    return [_URL isEqual:_initialURL];
    return 0;
}

- (void)makeCurrentEqualToInitial
{
    [super makeCurrentEqualToInitial];
    [_URL release];
    _URL = [_initialURL retain];
    [_applicationName release];
    _applicationName = [_initialApplicationName retain];
    _quitFromPlayer = _initialQuitFromPlayer;
    _launchInForeground = _initialLaunchInForeground;
    _opensDocument = _initialOpensDocument;
    _opensApplication = _initialOpensApplication;
}

- (void)makeInitialEqualToCurrent
{
    [super makeInitialEqualToCurrent];
    [_initialURL release];
    _initialURL = [_URL retain];
    [_initialApplicationName release];
    _initialApplicationName = [_applicationName retain];
    _initialQuitFromPlayer = _quitFromPlayer;
    _initialLaunchInForeground = _launchInForeground;
    _initialOpensDocument = _opensDocument;
    _initialOpensApplication = _opensApplication;
}

- (void)setInitialSettingsToObject
{
    id self_00;

    self_00 = [self openLocationActionAttributes];
    [self_00 setURL:_initialURL];
    [self_00 setOpensDocument:_initialOpensDocument];
    [self_00 setQuitAfterLaunch:_initialQuitFromPlayer];
    [self_00 setLaunchInForeground:_initialLaunchInForeground];
    [self_00 setApplicationName:_initialApplicationName];
    [self_00 setOpensApplication:_initialOpensApplication];
    [super setInitialSettingsToObject];
}

- (void)setCurrentSettingsToObject
{
    id self_00;

    [super setCurrentSettingsToObject];
    self_00 = [self openLocationActionAttributes];
    [self_00 setURL:_URL];
    [self_00 setOpensDocument:_opensDocument];
    [self_00 setQuitAfterLaunch:_quitFromPlayer];
    [self_00 setLaunchInForeground:_launchInForeground];
    [self_00 setApplicationName:_applicationName];
    [self_00 setOpensApplication:_opensApplication];
}

- (void)setUpInitialSettings
{
    id pvVar1;
    BOOL pvVar2;
    id pvVar1_3;
    BOOL pvVar2_2;
    BOOL pvVar2_3;
    BOOL pvVar2_4;
    id pvVar2_6;

    pvVar1 = [self openLocationActionAttributes];
    pvVar2 = [pvVar1 quitAfterLaunch];
    _quitFromPlayer = (BOOL)pvVar2;
    _initialQuitFromPlayer = (BOOL)pvVar2;
    pvVar2_2 = [pvVar1 launchInForeground];
    _launchInForeground = (BOOL)pvVar2_2;
    _initialLaunchInForeground = (BOOL)pvVar2_2;
    pvVar2_3 = [pvVar1 opensDocument];
    _opensDocument = (BOOL)pvVar2_3;
    _initialOpensDocument = (BOOL)pvVar2_3;
    pvVar2_4 = [pvVar1 opensApplication];
    _opensApplication = (BOOL)pvVar2_4;
    _initialOpensApplication = (BOOL)pvVar2_4;
    pvVar2_6 = [[pvVar1 applicationName] retain];
    _initialApplicationName = pvVar2_6;
    _applicationName = [pvVar2_6 retain];
    pvVar1_3 = [[pvVar1 URL] retain];
    _initialURL = pvVar1_3;
    _URL = [pvVar1_3 retain];
}

- (id)openLocationActionAttributes
{
    return [[self actionAttributes] queryHyperInterface:@protocol(HSOpenLocationActionAttributes)];
}

- (void)dealloc
{
    [_initialURL release];
    [_URL release];
    [_initialApplicationName release];
    [_applicationName release];
    [super dealloc];
}

@end

