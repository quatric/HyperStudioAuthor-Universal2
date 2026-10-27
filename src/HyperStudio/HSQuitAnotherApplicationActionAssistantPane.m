#import "HSQuitAnotherApplicationActionAssistantPane.h"

@implementation HSQuitAnotherApplicationActionAssistantPane

/* i386 ivar offsets: _appTextField=0x88, _appIconView=0x8c, _appIcon=0x90 */

- (id)helpTopicKey
{
    return @"HSQuitAnother";
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0010f30c @ 0010f30c, 173 bytes * /

void FUN_0010f30c(HSQuitAnotherApplicationActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  cfstringStruct *self_00;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(self,sel_actionAttributes);
  self_00 = _objc_msgSend(pvVar1,sel_applicationToQuit);
  pvVar1 = self->_appTextField;
  if (self_00 != (cfstringStruct *)0x0) {
    pvVar2 = _objc_msgSend(self_00,sel_length);
    if (pvVar2 != (id)0x0) goto LAB_0010f36a;
  }
  self_00 = &cfstr_empty;
LAB_0010f36a:
  _objc_msgSend(pvVar1,sel_setStringValue_,self_00);
  pvVar1 = self->_appIconView;
  pvVar2 = _objc_msgSend(self,sel_applicationIcon);
  _objc_msgSend(pvVar1,sel_setImage_,pvVar2);
  return;
}

*/
- (void)validateUI
{
    NSString *applicationName = [[self actionAttributes] applicationToQuit];
    [_appTextField setStringValue:(applicationName != nil && [applicationName length] != 0) ? applicationName : @""];
    [_appIconView setImage:[self applicationIcon]];
}

- (void)validateUIWithNotification:(id)aNotification
{
    [self validateUI];
}

- (id)applicationIcon
{
    [self createApplicationIconIfNeeded];
    return _appIcon;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0010f65e @ 0010f65e, 282 bytes * /

void FUN_0010f65e(HSQuitAnotherApplicationActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id local_14;
  
  if (self->_appIcon == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_actionAttributes);
    pvVar1 = _objc_msgSend(pvVar1,sel_applicationToQuit);
    if (pvVar1 != (id)0x0) {
      pvVar2 = _objc_msgSend(pvVar1,sel_length);
      if (pvVar2 != (id)0x0) {
        local_14 = (id)0x0;
        pvVar1 = _objc_msgSend(pvVar1,sel_stringByAppendingPathExtension_,&cfstr_app);
        _LSFindApplicationForInfo(0,0,pvVar1,0,&local_14);
        if (local_14 != (id)0x0) {
          pvVar1 = _objc_msgSend(cls_NSWorkspace,sel_sharedWorkspace);
          pvVar2 = _objc_msgSend(local_14,sel_path);
          pvVar1 = _objc_msgSend(pvVar1,sel_iconForFile_,pvVar2);
          _objc_msgSend(self,sel_setApplicationIcon_,pvVar1);
        }
      }
    }
  }
  return;
}

*/
- (void)createApplicationIconIfNeeded
{
    if (_appIcon == nil) {
        NSString *applicationName = [[self actionAttributes] applicationToQuit];
        if (applicationName != nil && [applicationName length] != 0) {
            CFURLRef applicationURL = NULL;
            LSFindApplicationForInfo(kLSUnknownCreator, NULL, (CFStringRef)[applicationName stringByAppendingPathExtension:@"app"], NULL, &applicationURL);
            if (applicationURL != NULL) {
                [self setApplicationIcon:[[NSWorkspace sharedWorkspace] iconForFile:[(NSURL *)applicationURL path]]];
                CFRelease(applicationURL);   /* the original leaked the URL */
            }
        }
    }
}

- (void)setApplicationIcon:(id)aIcon
{
    if (_appIcon != aIcon) {
        [_appIcon release];
        _appIcon = [aIcon retain];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0010f040 @ 0010f040, 551 bytes * /

void FUN_0010f040(HSQuitAnotherApplicationActionAssistantPane *self,SEL _cmd,id chooseApplication)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  SEL op;
  
  pvVar1 = _objc_msgSend(cls_NSOpenPanel,sel_openPanel);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  pvVar2 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider);
  pvVar2 = _objc_msgSend(pvVar2,sel_applicationsFolder);
  if (pvVar2 != (id)0x0) {
    op = sel_setDirectory_;
    if (1038.0 < *(double *)PTR_0033605c || *(double *)PTR_0033605c == 1038.0) {
      pvVar2 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_isDirectory_,pvVar2,1);
      op = sel_setDirectoryURL_;
    }
    _objc_msgSend(pvVar1,op,pvVar2);
  }
  pvVar2 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,&cfstr_app);
  pvVar3 = _objc_msgSend(pvVar1,sel_runModalForTypes_,pvVar2);
  if (pvVar3 == (id)0x1) {
    pvVar2 = _objc_msgSend(pvVar1,sel_URL,pvVar2);
    pvVar2 = _objc_msgSend(pvVar2,sel_path);
    pvVar3 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider);
    pvVar4 = _objc_msgSend(pvVar2,sel_stringByDeletingLastPathComponent);
    _objc_msgSend(pvVar3,sel_setApplicationsFolder_,pvVar4);
    pvVar3 = _objc_msgSend(cls_NSWorkspace,sel_sharedWorkspace);
    pvVar3 = _objc_msgSend(pvVar3,sel_iconForFile_,pvVar2);
    _objc_msgSend(self,sel_setApplicationIcon_,pvVar3);
    pvVar2 = _objc_msgSend(pvVar2,sel_stringByDeletingPathExtension);
    pvVar2 = _objc_msgSend(pvVar2,sel_lastPathComponent);
    pvVar3 = _objc_msgSend(self,sel_quitAnotherApplicationActionAssistantPaneApplier);
    _objc_msgSend(pvVar3,sel_setApplicationToQuit_,pvVar2);
  }
  _objc_msgSend(pvVar1,sel_release,pvVar2);
  return;
}

*/
- (void)chooseApplication:(id)aApplication
{
    NSOpenPanel *panel = [[NSOpenPanel openPanel] retain];
    id applicationsFolder = [[HSPathsProvider sharedPathsProvider] applicationsFolder];
    if (applicationsFolder != nil) {
        [panel setDirectoryURL:[NSURL fileURLWithPath:applicationsFolder isDirectory:YES]];
    }
    if ([panel runModalForTypes:[NSArray arrayWithObject:@"app"]] == NSOKButton) {
        NSString *path = [[panel URL] path];
        [[HSPathsProvider sharedPathsProvider] setApplicationsFolder:[path stringByDeletingLastPathComponent]];
        [self setApplicationIcon:[[NSWorkspace sharedWorkspace] iconForFile:path]];
        [[self quitAnotherApplicationActionAssistantPaneApplier] setApplicationToQuit:[[path stringByDeletingPathExtension] lastPathComponent]];
    }
    [panel release];
}

- (id)initialKeyView
{
    return _appTextField;
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
    return (id)@protocol(HSQuitAnotherApplicationActionAttributes);
}

- (id)actionAttributes
{
    return [[self quitAnotherApplicationActionAssistantPaneApplier] quitAnotherApplicationActionAttributes];
}

- (id)actionType
{
    return [HSQuitAnotherApplicationAction actionType];
}

- (id)quitAnotherApplicationActionAssistantPaneApplier
{
    return [self applier];
}

- (Class)applierClass
{
    return [HSQuitAnotherApplicationActionAssistantPaneApplier class];
}

- (void)dealloc
{
    [_appIcon release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"QuitApplicationAssistantPane"];
    return self;
}

@end

@implementation HSQuitAnotherApplicationActionAssistantPaneApplier

/* i386 ivar offsets: _applicationToQuit=0x30, _initialApplicationToQuit=0x34 */

- (BOOL)areSettingsEqual
{
    char cVar1;
    BOOL pvVar2;

    pvVar2 = [super areSettingsEqual];
    cVar1 = pvVar2;
    if ((_initialApplicationToQuit != nil) || (_applicationToQuit != nil)) {
        if (cVar1 == NO) {
            return NO;
        }
        pvVar2 = [_initialApplicationToQuit isEqual:_applicationToQuit];
        cVar1 = pvVar2;
    }
    return cVar1 != NO;
}

- (void)makeCurrentEqualToInitial
{
    [super makeCurrentEqualToInitial];
    [_applicationToQuit release];
    _applicationToQuit = [_initialApplicationToQuit retain];
}

- (void)makeInitialEqualToCurrent
{
    [super makeInitialEqualToCurrent];
    [_initialApplicationToQuit release];
    _initialApplicationToQuit = [_applicationToQuit retain];
}

- (void)setInitialSettingsToObject
{
    [[self quitAnotherApplicationActionAttributes] setApplicationToQuit:_initialApplicationToQuit];
    [super setInitialSettingsToObject];
}

- (void)setCurrentSettingsToObject
{
    [super setCurrentSettingsToObject];
    [[self quitAnotherApplicationActionAttributes] setApplicationToQuit:_applicationToQuit];
}

- (void)setApplicationToQuit:(id)aQuit
{
    if (![_applicationToQuit isEqualToString:aQuit]) {
        [_applicationToQuit release];
        _applicationToQuit = [aQuit retain];
        [self disableUndo];
        [[self quitAnotherApplicationActionAttributes] setApplicationToQuit:_applicationToQuit];
        [self enableUndo];
    }
}

- (void)setUpInitialSettings
{
    _applicationToQuit = [[[self quitAnotherApplicationActionAttributes] applicationToQuit] retain];
    _initialApplicationToQuit = [[[self quitAnotherApplicationActionAttributes] applicationToQuit] retain];
}

- (id)quitAnotherApplicationActionAttributes
{
    return [[self actionAttributes] queryHyperInterface:@protocol(HSQuitAnotherApplicationActionAttributes)];
}

- (void)dealloc
{
    [_applicationToQuit release];
    [_initialApplicationToQuit release];
    [super dealloc];
}

@end

