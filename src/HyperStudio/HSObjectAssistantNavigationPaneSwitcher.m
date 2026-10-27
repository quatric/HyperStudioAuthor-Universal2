#import "HSObjectAssistantNavigationPaneSwitcher.h"

@implementation HSObjectAssistantNavigationPaneSwitcher

/* i386 ivar offsets: _navigationController=0x40, _delegate=0x44, _OKButton=0x48, _cancelButton=0x4c, _backButton=0x50, _applier=0x54, _isHelpAssistantPaneSwitcher=0x58, _isModalWindowRunning=0x59 */

- (void)showHelp:(id)aHelp
{
    if ([[self delegate] respondsToSelector:@selector(helpTopicKey)]) {
        [[HSHelpBookManager sharedHelpBookManager] openHelpTopic:[[self delegate] helpTopicKey]];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018e974 @ 0018e974, 133 bytes * /

void FUN_0018e974(HSObjectAssistantNavigationPaneSwitcher *self,SEL _cmd,id doCancel)

{
  id pvVar1;
  HSObjectAssistantNavigationPaneSwitcher *self_00;
  SEL op;
  undefined *puVar2;
  
  pvVar1 = _objc_msgSend(self,sel_delegate);
  puVar2 = sel_paneDidCancel_;
  pvVar1 = _objc_msgSend(pvVar1,sel_respondsToSelector_,sel_paneDidCancel_);
  self_00 = self;
  op = sel_assistantGoBack_;
  if ((char)pvVar1 != '\0') {
    self_00 = _objc_msgSend(self,sel_delegate,puVar2);
    op = sel_paneDidCancel_;
  }
  _objc_msgSend(self_00,op,self);
  return;
}

*/
- (void)doCancel:(id)aCancel
{
    if ([[self delegate] respondsToSelector:@selector(paneDidCancel:)]) {
        [[self delegate] paneDidCancel:self];
    } else {
        [self assistantGoBack:self];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018e8a6 @ 0018e8a6, 206 bytes * /

void FUN_0018e8a6(HSObjectAssistantNavigationPaneSwitcher *self,SEL _cmd,id doOK)

{
  id pvVar1;
  HSObjectAssistantNavigationPaneSwitcher *self_00;
  SEL op;
  undefined *puVar2;
  undefined4 uVar3;
  undefined4 uVar4;
  undefined4 uVar5;
  
  pvVar1 = _objc_msgSend((self->super)._presentationView,sel_retain);
  uVar5 = 0;
  uVar4 = 0;
  uVar3 = 0;
  _objc_msgSend(pvVar1,sel_performSelector_withObject_afterDelay_,sel_release,0,0,0);
  pvVar1 = _objc_msgSend(self,sel_delegate);
  puVar2 = sel_paneDidOK_;
  pvVar1 = _objc_msgSend(pvVar1,sel_respondsToSelector_,sel_paneDidOK_);
  self_00 = self;
  op = sel_assistantGoBack_;
  if ((char)pvVar1 != '\0') {
    self_00 = _objc_msgSend(self,sel_delegate,puVar2,uVar3,uVar4,uVar5);
    op = sel_paneDidOK_;
  }
  _objc_msgSend(self_00,op,self,uVar3,uVar4,uVar5);
  return;
}

*/
- (void)doOK:(id)aOK
{
    [[_presentationView retain] performSelector:@selector(release) withObject:nil afterDelay:0.0];
    if ([[self delegate] respondsToSelector:@selector(paneDidOK:)]) {
        [[self delegate] paneDidOK:self];
    } else {
        [self assistantGoBack:self];
    }
}

- (void)assistantGoBack:(id)aBack
{
    if ([[self delegate] respondsToSelector:@selector(paneWillGoBack:)]) {
        [[self delegate] paneWillGoBack:self];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0018ebbf @ 0018ebbf, 838 bytes * /

void FUN_0018ebbf(HSObjectAssistantNavigationPaneSwitcher *self,SEL _cmd)

{
  char cVar1;
  id pvVar2;
  cfstringStruct *pcVar3;
  id pvVar4;
  SEL op;
  bool bVar5;
  HSObjectAssistantNavigationPaneSwitcher *pHVar6;
  undefined *puVar7;
  
  pvVar2 = _objc_msgSend(self,sel_delegate);
  pHVar6 = (HSObjectAssistantNavigationPaneSwitcher *)
           sel_shouldEnableOKButtonInNavigationPaneSwitcher_;
  pvVar2 = _objc_msgSend(pvVar2,sel_respondsToSelector_,
                         sel_shouldEnableOKButtonInNavigationPaneSwitcher_);
  if ((char)pvVar2 == '\0') {
    cVar1 = '\x01';
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_delegate,pHVar6);
    pHVar6 = self;
    pvVar2 = _objc_msgSend(pvVar2,sel_shouldEnableOKButtonInNavigationPaneSwitcher_,self);
    cVar1 = (char)pvVar2;
  }
  pvVar2 = _objc_msgSend(self,sel_navigationController,pHVar6);
  pvVar2 = _objc_msgSend(pvVar2,sel_topViewController);
  pcVar3 = (cfstringStruct *)_NSClassFromString(&cfstr_HSObjectsBrowserCoachingPane);
  pvVar2 = _objc_msgSend(pvVar2,sel_isKindOfClass_,pcVar3);
  if ((char)pvVar2 == '\0') {
    if (self->_isHelpAssistantPaneSwitcher != '\0') {
      pvVar2 = self->_OKButton;
      pvVar4 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController,pcVar3);
      op = sel_coachingHintDefaultButton;
      goto LAB_0018ecf3;
    }
  }
  else {
    pvVar2 = self->_OKButton;
    pvVar4 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pcVar3);
    pcVar3 = &cfstr_OK;
    op = sel_localizedStringForKey_value_table_;
LAB_0018ecf3:
    pvVar4 = _objc_msgSend(pvVar4,op,pcVar3);
    _objc_msgSend(pvVar2,sel_setTitle_,pvVar4);
  }
  if ((cVar1 == '\0') || (self->_isModalWindowRunning != '\0')) {
    cVar1 = '\0';
  }
  else {
    cVar1 = '\x01';
  }
  _objc_msgSend(self->_OKButton,sel_setEnabled_,(int)cVar1);
  pvVar2 = _objc_msgSend(self,sel_delegate);
  puVar7 = sel_shouldEnableCancelButtonInNavigationPaneSwitcher_;
  pvVar2 = _objc_msgSend(pvVar2,sel_respondsToSelector_,
                         sel_shouldEnableCancelButtonInNavigationPaneSwitcher_);
  if ((char)pvVar2 == '\0') {
    pvVar2 = self->_cancelButton;
LAB_0018edb8:
    if (self->_isModalWindowRunning != '\0') goto LAB_0018edc5;
    cVar1 = '\x01';
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_delegate,puVar7);
    pvVar4 = _objc_msgSend(pvVar2,sel_shouldEnableCancelButtonInNavigationPaneSwitcher_,self);
    pvVar2 = self->_cancelButton;
    if ((char)pvVar4 != '\0') goto LAB_0018edb8;
LAB_0018edc5:
    cVar1 = '\0';
  }
  _objc_msgSend(pvVar2,sel_setEnabled_,(int)cVar1);
  pvVar2 = _objc_msgSend(self,sel_delegate);
  puVar7 = sel_shouldShowCancelButtonInNavigationPaneSwitcher_;
  pvVar2 = _objc_msgSend(pvVar2,sel_respondsToSelector_,
                         sel_shouldShowCancelButtonInNavigationPaneSwitcher_);
  if ((char)pvVar2 == '\0') {
    bVar5 = false;
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_delegate,puVar7);
    pvVar2 = _objc_msgSend(pvVar2,sel_shouldShowCancelButtonInNavigationPaneSwitcher_,self);
    bVar5 = (char)pvVar2 == '\0';
  }
  _objc_msgSend(self->_cancelButton,sel_setHidden_,bVar5);
  pvVar2 = _objc_msgSend(self,sel_delegate);
  puVar7 = sel_shouldEnableBackButtonInNavigationPaneSwitcher_;
  pvVar2 = _objc_msgSend(pvVar2,sel_respondsToSelector_,
                         sel_shouldEnableBackButtonInNavigationPaneSwitcher_);
  if ((char)pvVar2 == '\0') {
    pvVar2 = self->_backButton;
LAB_0018eed6:
    if (self->_isModalWindowRunning == '\0') {
      cVar1 = '\x01';
      goto LAB_0018eee5;
    }
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_delegate,puVar7);
    pvVar4 = _objc_msgSend(pvVar2,sel_shouldEnableBackButtonInNavigationPaneSwitcher_,self);
    pvVar2 = self->_backButton;
    if ((char)pvVar4 != '\0') goto LAB_0018eed6;
  }
  cVar1 = '\0';
LAB_0018eee5:
  _objc_msgSend(pvVar2,sel_setEnabled_,(int)cVar1);
  return;
}

*/
- (void)validateUserInterface
{
    BOOL enableOK = YES;
    if ([[self delegate] respondsToSelector:@selector(shouldEnableOKButtonInNavigationPaneSwitcher:)]) {
        enableOK = [[self delegate] shouldEnableOKButtonInNavigationPaneSwitcher:self];
    }
    if ([[[self navigationController] topViewController] isKindOfClass:NSClassFromString(@"HSObjectsBrowserCoachingPane")]) {
        [_OKButton setTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"OK" value:@"" table:@"AssistantPanes"]];
    } else if (_isHelpAssistantPaneSwitcher) {
        [_OKButton setTitle:[[HSObjectAssistantController sharedAssistantController] coachingHintDefaultButton]];
    }
    [_OKButton setEnabled:enableOK && !_isModalWindowRunning];
    BOOL enableCancel = YES;
    if ([[self delegate] respondsToSelector:@selector(shouldEnableCancelButtonInNavigationPaneSwitcher:)]) {
        enableCancel = [[self delegate] shouldEnableCancelButtonInNavigationPaneSwitcher:self];
    }
    [_cancelButton setEnabled:enableCancel && !_isModalWindowRunning];
    BOOL hideCancel = NO;
    if ([[self delegate] respondsToSelector:@selector(shouldShowCancelButtonInNavigationPaneSwitcher:)]) {
        hideCancel = ![[self delegate] shouldShowCancelButtonInNavigationPaneSwitcher:self];
    }
    [_cancelButton setHidden:hideCancel];
    BOOL enableBack = YES;
    if ([[self delegate] respondsToSelector:@selector(shouldEnableBackButtonInNavigationPaneSwitcher:)]) {
        enableBack = [[self delegate] shouldEnableBackButtonInNavigationPaneSwitcher:self];
    }
    [_backButton setEnabled:enableBack && !_isModalWindowRunning];
}

- (void)validateUIWithModalWindowChange
{
    [_OKButton setEnabled:(unsigned int)(_isModalWindowRunning == NO)];
    [_cancelButton setEnabled:(unsigned int)(_isModalWindowRunning == NO)];
    [_backButton setEnabled:(unsigned int)(_isModalWindowRunning == NO)];
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [super viewWillDisappear:aDisappear];
    [[self window] setDefaultButtonCell:nil];
}

- (void)viewDidAppear:(BOOL)aAppear
{
    [super viewDidAppear:aAppear];
    [[self window] setDefaultButtonCell:[self defaultButtonCell]];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [self validateUserInterface];
}

- (id)defaultButtonCell
{
    return [_OKButton cell];
}

- (id)window
{
    return [[self view] window];
}

- (void)didEndModalWindow:(id)aWindow
{
    if (_isModalWindowRunning != NO) {
        _isModalWindowRunning = NO;
        [self validateUIWithModalWindowChange];
    }
}

- (void)willRunModalWindow:(id)aWindow
{
    if (_isModalWindowRunning == NO) {
        _isModalWindowRunning = YES;
        [self validateUIWithModalWindowChange];
    }
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (void)setApplier:(id)aApplier
{
    if (_applier != aApplier) {
        [_applier release];
        _applier = [aApplier retain];
    }
}

- (id)applier
{
    return _applier;
}

- (void)setNavigationController:(id)aController
{
    _navigationController = aController;
}

- (id)navigationController
{
    return _navigationController;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_applier release];
    [super dealloc];
}

- (id)initWithAssistantSettingsApplier:(id)aApplier windowNibName:(id)aName
{
    self = [super initWithNibName:aName];
    if (self != nil) {
        [self setApplier:aApplier];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willRunModalWindow:) name:HSWillRunModalWindowNotification object:0];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEndModalWindow:) name:HSDidEndModalWindowNotification object:0];
        if ([aName isEqualToString:@"HSHelpAssistantPaneSwitcher"]) {
            _isHelpAssistantPaneSwitcher = 1;
        }
    }
    return self;
}

- (id)initWithNibName:(id)aName
{
    id pvVar1;

    pvVar1 = [self initWithAssistantSettingsApplier:nil windowNibName:aName]
    ;
    return pvVar1;
}

- (id)init
{
    return [self initWithAssistantSettingsApplier:nil windowNibName:@"AssistantNavigationSwitcher"];
}

@end

