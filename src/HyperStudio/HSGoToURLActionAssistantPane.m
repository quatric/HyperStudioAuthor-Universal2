#import "HSGoToURLActionAssistantPane.h"

@implementation HSGoToURLActionAssistantPane

/* i386 ivar offsets: _webPageView=0x78, _mailView=0x7c, _containerView=0x80, _urlTypePopup=0x84, _addressField=0x88, _launchInForegroundSwitch=0x8c, _emailAddressField=0x90, _emailSubjectField=0x94, _emailTextFieldController=0x98, _addressBookEmailTokenFieldController=0x9c, _observableActionAttributes=0xa0, _currentView=0xa4 */

- (void)controlTextDidChange:(id)aChange
{
    [[self navigationPaneSwitcher] validateUserInterface];
}

- (void)sendMailActionEmailSubjectAttributeDidChange:(id)aChange
{
    [self validateSendMailActionEmailSubject];
    [[self navigationPaneSwitcher] validateUserInterface];
}

- (void)sendMailActionEmailAddressesAttributeDidChange:(id)aChange
{
    [self validateSendMailActionEmailAddresses];
    [[self navigationPaneSwitcher] validateUserInterface];
}

- (void)openWebPageActionLaunchInForegroundAttributeDidChange:(id)aChange
{
    [self validateOpenWebPageActionLaunchInForeground];
}

- (void)openWebPageActionURLAttributeDidChange:(id)aChange
{
    [self validateOpenWebPageActionURL];
    [[self navigationPaneSwitcher] validateUserInterface];
}

- (void)actionTypeDidChange:(id)aChange
{
    [self validateCurrentPane];
}

- (void)paneDidCancel:(id)aCancel
{
    [[self window] makeFirstResponder:[self window]];
    [super paneDidCancel:aCancel];
}

- (void)toggleLaunchInForeground:(id)aForeground
{
    [[self goToURLActionAssistantApplier] setLaunchInForeground:(unsigned int)([aForeground state] == 0x1)];
}

- (void)emailSubjectChanged:(id)aChanged
{
    [[self goToURLActionAssistantApplier] setEmailSubject:[aChanged stringValue]];
}

- (void)emailAddressesChanged:(id)aChanged
{
    id pvVar1;

    pvVar1 = [_emailTextFieldController emailAddresses];
    [[self goToURLActionAssistantApplier] setEmailAddresses:pvVar1];
    if ([[self sendMailActionAttributes] hyperInvalidEmailAddressError] != nil) {
        [[HSErrorManager sharedErrorManager] presentError:[[self sendMailActionAttributes] hyperInvalidEmailAddressError]];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0016861c @ 0016861c, 582 bytes * /

void FUN_0016861c(HSGoToURLActionAssistantPane *self,SEL _cmd,id URLChanged)

{
  undefined4 uVar1;
  id pvVar2;
  id pvVar3;
  char *pcVar4;
  size_t sVar5;
  int iVar6;
  int iVar7;
  id local_14;
  
  pvVar2 = _objc_msgSend(self->_addressField,sel_stringValue);
  if (pvVar2 == (id)0x0) {
    return;
  }
  pvVar3 = _objc_msgSend(pvVar2,sel_length);
  if (pvVar3 == (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_goToURLActionAssistantApplier);
    local_14 = (id)0x0;
  }
  else {
    pcVar4 = _objc_msgSend(pvVar2,sel_cStringUsingEncoding_,4);
    if (pcVar4 == (char *)0x0) {
      return;
    }
    sVar5 = _strlen(pcVar4);
    if (sVar5 == 0) {
      return;
    }
    uVar1 = *(undefined4 *)PTR_003363a4;
    local_14 = (id)_CFURLCreateWithBytes(uVar1,pcVar4,sVar5,0x8000100,0);
    if (local_14 == (id)0x0) {
      return;
    }
    pvVar3 = _objc_msgSend(self,sel_openWebPageActionAttributes);
    pvVar3 = _objc_msgSend(pvVar3,sel_URL);
    pvVar3 = _objc_msgSend(local_14,sel_isEqual_,pvVar3);
    if ((char)pvVar3 != '\0') {
      return;
    }
    iVar6 = _CFURLCopyScheme(local_14);
    if ((iVar6 == 0) || (iVar7 = _CFStringGetLength(iVar6), iVar7 == 0)) {
      pvVar2 = (id)_CFStringCreateWithFormat(uVar1,0,&cfstr_____,&cfstr_http___,pvVar2);
      if (pvVar2 == (id)0x0) {
        return;
      }
      pcVar4 = _objc_msgSend(pvVar2,sel_cStringUsingEncoding_,4);
      if ((pcVar4 == (char *)0x0) || (sVar5 = _strlen(pcVar4), sVar5 == 0)) {
        _CFRelease(pvVar2);
        return;
      }
      _CFRelease(local_14);
      local_14 = (id)_CFURLCreateWithBytes(uVar1,pcVar4,sVar5,0x8000100,0);
      _CFRelease(pvVar2);
      if (local_14 == (id)0x0) {
        return;
      }
    }
    if (iVar6 != 0) {
      _CFRelease(iVar6);
    }
    pvVar2 = _objc_msgSend(self,sel_goToURLActionAssistantApplier);
  }
  _objc_msgSend(pvVar2,sel_setURL_,local_14);
  return;
}

*/
- (void)URLChanged:(id)aChanged
{
    NSString *string = [_addressField stringValue];
    if (string == nil) {
        return;
    }
    id applier;
    CFURLRef url;
    if ([string length] == 0) {
        applier = [self goToURLActionAssistantApplier];
        url = NULL;
    } else {
        const char *bytes = [string cStringUsingEncoding:NSUTF8StringEncoding];
        if (bytes == NULL) {
            return;
        }
        size_t length = strlen(bytes);
        if (length == 0) {
            return;
        }
        url = CFURLCreateWithBytes(kCFAllocatorDefault, (const UInt8 *)bytes, length, kCFStringEncodingUTF8, NULL);
        if (url == NULL) {
            return;
        }
        if ([(id)url isEqual:[[self openWebPageActionAttributes] URL]]) {
            CFRelease(url);
            return;
        }
        CFStringRef scheme = CFURLCopyScheme(url);
        if (scheme == NULL || CFStringGetLength(scheme) == 0) {
            CFStringRef withScheme = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@%@"), CFSTR("http://"), string);
            if (withScheme == NULL) {
                CFRelease(url);
                if (scheme != NULL) {
                    CFRelease(scheme);
                }
                return;
            }
            bytes = [(NSString *)withScheme cStringUsingEncoding:NSUTF8StringEncoding];
            if (bytes == NULL || (length = strlen(bytes)) == 0) {
                CFRelease(withScheme);
                CFRelease(url);
                if (scheme != NULL) {
                    CFRelease(scheme);
                }
                return;
            }
            CFRelease(url);
            url = CFURLCreateWithBytes(kCFAllocatorDefault, (const UInt8 *)bytes, length, kCFStringEncodingUTF8, NULL);
            CFRelease(withScheme);
            if (url == NULL) {
                if (scheme != NULL) {
                    CFRelease(scheme);
                }
                return;
            }
        }
        if (scheme != NULL) {
            CFRelease(scheme);
        }
        applier = [self goToURLActionAssistantApplier];
    }
    [applier setURL:(NSURL *)url];
    if (url != NULL) {
        CFRelease(url);
    }
}

- (void)actionURLTypeChanged:(id)aChanged
{
    [[self goToURLActionAssistantApplier] setURLType:[aChanged indexOfSelectedItem]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00168862 @ 00168862, 304 bytes * /

void FUN_00168862(HSGoToURLActionAssistantPane *self,SEL _cmd,id mountView)

{
  id pvVar1;
  undefined1 local_24 [8];
  undefined4 local_1c;
  undefined4 local_18;
  
  if (self->_currentView != mountView) {
    _objc_msgSend(self->_currentView,sel_removeFromSuperview);
    _objc_msgSend(self->_currentView,sel_release);
    pvVar1 = _objc_msgSend(mountView,sel_retain);
    self->_currentView = pvVar1;
    _objc_msgSend(pvVar1,sel_setFrameOrigin_,*(undefined4 *)PTR_00336074,
                  *(undefined4 *)(PTR_00336074 + 4));
    pvVar1 = self->_currentView;
    _objc_msgSend_stret(local_24,self->_containerView,sel_frame);
    _objc_msgSend(pvVar1,sel_setFrameSize_,local_1c,local_18);
    _objc_msgSend(self->_containerView,sel_addSubview_,self->_currentView);
    pvVar1 = _objc_msgSend(self,sel_window);
    _objc_msgSend(pvVar1,sel_recalculateKeyViewLoop);
  }
  return;
}

*/
- (void)mountView:(id)aView
{
    if (_currentView != aView) {
        [_currentView removeFromSuperview];
        [_currentView release];
        _currentView = [aView retain];
        [_currentView setFrameOrigin:NSZeroPoint];
        [_currentView setFrameSize:[_containerView frame].size];
        [_containerView addSubview:_currentView];
        [[self window] recalculateKeyViewLoop];
    }
}

- (void)viewDidAppear:(BOOL)aAppear
{
    [super viewDidAppear:aAppear];
    [[self navigationPaneSwitcher] validateUserInterface];
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [self setObservableActionAttributes:nil];
    [super viewWillDisappear:aDisappear];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [self validateCurrentPane];
    [self setObservableActionAttributes:[self actionAttributes]];
}

- (void)setObservableActionAttributes:(id)aAttributes
{
    int uVar1;
    id pvVar2;
    id pvVar2_3;
    id pvVar2_5;
    id pvVar2_6;
    id pvVar2_8;
    id pvVar2_10;

    if (_observableActionAttributes != aAttributes) {
        pvVar2 = [_observableActionAttributes attributeObservingController];
        uVar1 = HSActualDidAttributeChanges;
        [pvVar2 removeObserver:self selector:@selector(actionTypeDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSGoToURLActionTypeAttribute)];
        pvVar2_3 = [[_observableActionAttributes openWebPageActionAttributes] attributeObservingController];
        [pvVar2_3 removeObserver:self selector:@selector(openWebPageActionURLAttributeDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSURLAttribute)];
        [pvVar2_3 removeObserver:self selector:@selector(openWebPageActionLaunchInForegroundAttributeDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSOpenWebPageInForegroundAttribute)];
        pvVar2_5 = [[_observableActionAttributes sendMailActionAttributes] attributeObservingController];
        [pvVar2_5 removeObserver:self selector:@selector(sendMailActionEmailAddressesAttributeDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSEmailAddressesAttribute)];
        [pvVar2_5 removeObserver:self selector:@selector(sendMailActionEmailSubjectAttributeDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSEmailSubjectAttribute)];
        [_observableActionAttributes release];
        pvVar2_6 = [aAttributes retain];
        _observableActionAttributes = pvVar2_6;
        pvVar2_8 = [[pvVar2_6 openWebPageActionAttributes] attributeObservingController];
        [pvVar2_8 addObserver:self selector:@selector(openWebPageActionURLAttributeDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSURLAttribute) withPriority:-0.25];
        [pvVar2_8 addObserver:self selector:@selector(openWebPageActionLaunchInForegroundAttributeDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSOpenWebPageInForegroundAttribute) withPriority:-0.25];
        pvVar2_10 = [[_observableActionAttributes sendMailActionAttributes] attributeObservingController];
        [pvVar2_10 addObserver:self selector:@selector(sendMailActionEmailAddressesAttributeDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSEmailAddressesAttribute) withPriority:-0.25];
        [pvVar2_10 addObserver:self selector:@selector(sendMailActionEmailSubjectAttributeDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSEmailSubjectAttribute) withPriority:-0.25];
        [[_observableActionAttributes attributeObservingController] addObserver:self selector:@selector(actionTypeDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSGoToURLActionTypeAttribute) withPriority:-0.25];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0016781c @ 0016781c, 298 bytes * /

BOOL FUN_0016781c(HSGoToURLActionAssistantPane *self,SEL _cmd,
                 id shouldEnableOKButtonInNavigationPaneSwitcher)

{
  id pvVar1;
  SEL op;
  undefined *puVar2;
  
  pvVar1 = _objc_msgSend(self,sel_actionAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_URLType);
  if (pvVar1 == (id)0x1) {
    pvVar1 = _objc_msgSend(self,sel_sendMailActionAttributes);
    puVar2 = &DAT_00374c8c;
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00374c8c);
    pvVar1 = _objc_msgSend(pvVar1,sel_isValid);
    if ((char)pvVar1 != '\0') {
      return '\x01';
    }
    pvVar1 = _objc_msgSend(self->_addressBookEmailTokenFieldController,sel_emailAddresses,puVar2);
    op = sel_count;
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_openWebPageActionAttributes);
    puVar2 = &DAT_00374c8c;
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00374c8c);
    pvVar1 = _objc_msgSend(pvVar1,sel_isValid);
    if ((char)pvVar1 != '\0') {
      return '\x01';
    }
    pvVar1 = _objc_msgSend(self->_addressField,sel_stringValue,puVar2);
    op = sel_length;
  }
  pvVar1 = _objc_msgSend(pvVar1,op,puVar2);
  return pvVar1 != (id)0x0;
}

*/
- (BOOL)shouldEnableOKButtonInNavigationPaneSwitcher:(id)aSwitcher
{
    if ([[self actionAttributes] URLType] == 1) {
        if ([[[self sendMailActionAttributes] queryHyperInterface:@protocol(HSActionValidation)] isValid]) {
            return YES;
        }
        return [[_addressBookEmailTokenFieldController emailAddresses] count] != 0;
    }
    if ([[[self openWebPageActionAttributes] queryHyperInterface:@protocol(HSActionValidation)] isValid]) {
        return YES;
    }
    return [[_addressField stringValue] length] != 0;
    return 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00167706 @ 00167706, 278 bytes * /

void FUN_00167706(HSGoToURLActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  
  pvVar2 = self->_urlTypePopup;
  pvVar1 = _objc_msgSend(self,sel_actionAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_URLType);
  _objc_msgSend(pvVar2,sel_selectItemAtIndex_,pvVar1);
  pvVar2 = _objc_msgSend(self,sel_actionAttributes);
  pvVar2 = _objc_msgSend(pvVar2,sel_URLType);
  if (pvVar2 == (id)0x0) {
    pvVar2 = self->_webPageView;
    _objc_msgSend(self,sel_mountView_,pvVar2);
    _objc_msgSend(self,sel_validateOpenWebPageActionURL);
    op = sel_validateOpenWebPageActionLaunchInForeground;
  }
  else {
    pvVar2 = self->_mailView;
    _objc_msgSend(self,sel_mountView_,pvVar2);
    _objc_msgSend(self,sel_validateSendMailActionEmailAddresses);
    op = sel_validateSendMailActionEmailSubject;
  }
  _objc_msgSend(self,op,pvVar2);
  pvVar2 = _objc_msgSend(self,sel_navigationPaneSwitcher);
  _objc_msgSend(pvVar2,sel_validateUserInterface);
  return;
}

*/
- (void)validateCurrentPane
{
    [_urlTypePopup selectItemAtIndex:[[self actionAttributes] URLType]];
    if ([[self actionAttributes] URLType] == 0) {
        [self mountView:_webPageView];
        [self validateOpenWebPageActionURL];
        [self validateOpenWebPageActionLaunchInForeground];
    } else {
        [self mountView:_mailView];
        [self validateSendMailActionEmailAddresses];
        [self validateSendMailActionEmailSubject];
    }
    [[self navigationPaneSwitcher] validateUserInterface];
}

- (void)validateSendMailActionEmailSubject
{
    id pvVar1;

    pvVar1 = [self sendMailActionAttributes];
    if (pvVar1 != nil) {
        [_emailSubjectField setStringValue:[pvVar1 hyperEmailSubject]];
    }
}

- (void)validateSendMailActionEmailAddresses
{
    id pvVar1;

    pvVar1 = [self sendMailActionAttributes];
    if (pvVar1 != nil) {
        [_emailTextFieldController setEmailAddresses:[pvVar1 hyperEmailAddresses]];
    }
}

- (void)validateOpenWebPageActionLaunchInForeground
{
    id pvVar1;

    pvVar1 = [self openWebPageActionAttributes];
    if (pvVar1 != nil) {
        [_launchInForegroundSwitch setState:(unsigned int)([pvVar1 launchInForeground])];
    }
}

- (void)validateOpenWebPageActionURL
{
    id pvVar1;
    NSString *pvVar1_3;
    NSString *pvVar1_4;

    pvVar1 = [self openWebPageActionAttributes];
    if (pvVar1 != nil) {
        pvVar1_3 = [[pvVar1 URL] absoluteString];
        pvVar1_4 = [pvVar1_3 stringByReplacingPercentEscapesUsingEncoding:4];
        if (pvVar1_4 == nil) {
            pvVar1_4 = [NSString string];
        }
        [_addressField setStringValue:pvVar1_4];
    }
}

- (id)helpTopicKey
{
    return @"HSGoToURL";
}

- (id)openWebPageActionAttributes
{
    return [[self goToURLActionAssistantApplier] openWebPageActionAttributes];
}

- (id)sendMailActionAttributes
{
    return [[self goToURLActionAssistantApplier] sendMailActionAttributes];
}

- (id)actionAttributes
{
    return [[self goToURLActionAssistantApplier] goToURLActionAttributes];
}

- (id)actionType
{
    return [HSGoToURLAction actionType];
}

- (id)goToURLActionAssistantApplier
{
    return [self applier];
}

- (Class)applierClass
{
    return [HSGoToURLActionAssistantPaneApplier class];
}

- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controlTextDidChange:) name:NSControlTextDidChangeNotification object:_addressField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controlTextDidChange:) name:NSControlTextDidChangeNotification object:_emailAddressField];
    [super viewDidLoad];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[_observableActionAttributes attributeObservingController] removeAttributeObserver:self];
    [_observableActionAttributes release];
    [_currentView release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"GoToURLAssistantPane"];
    return self;
}

@end

@implementation HSGoToURLActionAssistantPaneApplier

/* i386 ivar offsets: _initialEmailAddresses=0x30, _initialEmailSubject=0x34, _initialURL=0x38, _initialLaunchInForeground=0x3c, _initialURLType=0x40, _emailAddresses=0x44, _emailSubject=0x48, _URL=0x4c, _launchInForeground=0x50, _URLType=0x54 */

- (void)setLaunchInForeground:(BOOL)aForeground
{
    if (aForeground == NO) {
        if (_launchInForeground == NO) {
            return;
        }
    }
    if (_launchInForeground != NO) {
        return;
    }
    _launchInForeground = aForeground;
    [self disableUndo];
    [[self openWebPageActionAttributes] setLaunchInForeground:_launchInForeground];
    [self enableUndo];
}

- (void)setURL:(id)aURL
{
    if (![_URL isEqual:aURL]) {
        [_URL release];
        _URL = [aURL retain];
        [self disableUndo];
        [[self openWebPageActionAttributes] setURL:_URL];
        [self enableUndo];
    }
}

- (void)setEmailSubject:(id)aSubject
{
    if (![_emailSubject isEqual:aSubject]) {
        [_emailSubject release];
        _emailSubject = [aSubject retain];
        [self disableUndo];
        [[self sendMailActionAttributes] setHyperEmailSubject:_emailSubject];
        [self enableUndo];
    }
}

- (void)setEmailAddresses:(id)aAddresses
{
    if (![_emailAddresses isEqual:aAddresses]) {
        [_emailAddresses release];
        _emailAddresses = [aAddresses retain];
        [self disableUndo];
        [[self sendMailActionAttributes] setHyperEmailAddresses:_emailAddresses];
        [self enableUndo];
    }
}

- (void)setURLType:(NSInteger)aType
{
    if (_URLType != aType) {
        _URLType = aType;
        [self disableUndo];
        [[self goToURLActionAttributes] setURLType:_URLType];
        [self enableUndo];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001680cd @ 001680cd, 216 bytes * /

BOOL FUN_001680cd(HSGoToURLActionAssistantPaneApplier *self,SEL _cmd)

{
  id pvVar1;
  HSGoToURLActionAssistantPaneApplier *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_HSActionAssistantSettingsApplier_00351f80;
  pvVar1 = _objc_msgSendSuper(&local_14,sel_areSettingsEqual);
  if ((char)pvVar1 == '\0') {
    return '\0';
  }
  if (self->_launchInForeground != '\0') {
    if (self->_initialLaunchInForeground == '\0') {
      return '\0';
    }
    if (self->_launchInForeground != '\0') goto LAB_00168122;
  }
  if (self->_initialLaunchInForeground != '\0') {
    return '\0';
  }
LAB_00168122:
  pvVar1 = _objc_msgSend(self->_initialEmailAddresses,sel_isEqualToArray_,self->_emailAddresses);
  if ((char)pvVar1 != '\0') {
    if ((self->_initialEmailSubject == (id)0x0 && self->_emailSubject == (id)0x0) ||
       (pvVar1 = _objc_msgSend(self->_initialEmailSubject,sel_isEqual_,self->_emailSubject),
       (char)pvVar1 != '\0')) {
      if ((self->_initialURL == (id)0x0 && self->_URL == (id)0x0) ||
         (pvVar1 = _objc_msgSend(self->_initialURL,sel_isEqual_,self->_URL), (char)pvVar1 != '\0'))
      {
        return self->_initialURLType == self->_URLType;
      }
    }
  }
  return '\0';
}

*/
- (BOOL)areSettingsEqual
{
    if (![super areSettingsEqual]) {
        return NO;
    }
    if ((_launchInForeground != NO) != (_initialLaunchInForeground != NO)) {
        return NO;
    }
    if (![_initialEmailAddresses isEqualToArray:_emailAddresses]) {
        return NO;
    }
    if (!((_initialEmailSubject == nil && _emailSubject == nil) || [_initialEmailSubject isEqual:_emailSubject])) {
        return NO;
    }
    if (!((_initialURL == nil && _URL == nil) || [_initialURL isEqual:_URL])) {
        return NO;
    }
    return _initialURLType == _URLType;
    return 0;
}

- (void)makeCurrentEqualToInitial
{
    [super makeCurrentEqualToInitial];
    _URLType = _initialURLType;
    [_emailAddresses release];
    _emailAddresses = [_initialEmailAddresses retain];
    [_emailSubject release];
    _emailSubject = [_initialEmailSubject retain];
    [_URL release];
    _URL = [_initialURL retain];
    _launchInForeground = _initialLaunchInForeground;
}

- (void)makeInitialEqualToCurrent
{
    [super makeInitialEqualToCurrent];
    _initialURLType = _URLType;
    [_initialEmailAddresses release];
    _initialEmailAddresses = [_emailAddresses retain];
    [_initialEmailSubject release];
    _initialEmailSubject = [_emailSubject retain];
    [_initialURL release];
    _initialURL = [_URL retain];
    _initialLaunchInForeground = _launchInForeground;
}

- (void)setInitialSettingsToObject
{
    [[self goToURLActionAttributes] setURLType:_initialURLType];
    [[self sendMailActionAttributes] setHyperEmailAddresses:_initialEmailAddresses];
    [[self sendMailActionAttributes] setHyperEmailSubject:_initialEmailSubject];
    [[self openWebPageActionAttributes] setURL:_initialURL];
    [[self openWebPageActionAttributes] setLaunchInForeground:_initialLaunchInForeground];
    [super setInitialSettingsToObject];
}

- (void)setCurrentSettingsToObject
{
    [super setCurrentSettingsToObject];
    [[self goToURLActionAttributes] setURLType:_URLType];
    [[self sendMailActionAttributes] setHyperEmailAddresses:_emailAddresses];
    [[self sendMailActionAttributes] setHyperEmailSubject:_emailSubject];
    [[self openWebPageActionAttributes] setURL:_URL];
    [[self openWebPageActionAttributes] setLaunchInForeground:_launchInForeground];
}

- (void)setUpInitialSettings
{
    NSInteger pvVar1_2;
    id pvVar1_5;
    id pvVar1_9;
    id pvVar1_13;
    BOOL pvVar1_16;

    pvVar1_2 = [[self goToURLActionAttributes] URLType];
    _URLType = (int)pvVar1_2;
    _initialURLType = (int)pvVar1_2;
    pvVar1_5 = [[[self sendMailActionAttributes] hyperEmailAddresses] retain];
    _initialEmailAddresses = pvVar1_5;
    _emailAddresses = [pvVar1_5 retain];
    pvVar1_9 = [[[self sendMailActionAttributes] hyperEmailSubject] retain];
    _initialEmailSubject = pvVar1_9;
    _emailSubject = [pvVar1_9 retain];
    pvVar1_13 = [[[self openWebPageActionAttributes] URL] retain];
    _initialURL = pvVar1_13;
    _URL = [pvVar1_13 retain];
    pvVar1_16 = [[self openWebPageActionAttributes] launchInForeground];
    _initialLaunchInForeground = (BOOL)pvVar1_16;
    _launchInForeground = (BOOL)pvVar1_16;
}

- (id)openWebPageActionAttributes
{
    return [[self goToURLActionAttributes] openWebPageActionAttributes];
}

- (id)sendMailActionAttributes
{
    return [[self goToURLActionAttributes] sendMailActionAttributes];
}

- (id)goToURLActionAttributes
{
    return [[self actionAttributes] queryHyperInterface:@protocol(HSGoToURLActionAttributes)];
}

- (void)dealloc
{
    [_emailAddresses release];
    [_emailSubject release];
    [_URL release];
    [_initialEmailAddresses release];
    [_initialEmailSubject release];
    [_initialURL release];
    [super dealloc];
}

@end

