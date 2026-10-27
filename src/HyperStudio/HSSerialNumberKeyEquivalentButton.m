#import "HSSerialNumberKeyEquivalentButton.h"

@implementation HSSerialNumberKeyEquivalentButton

- (BOOL)canBecomeKeyView
{
    return NO;
}

@end

@implementation HSSerialNumberDialogController

/* i386 ivar offsets: _dialogType=0x28, _contentView=0x2c, _buttonsView=0x30, _commonContentView=0x34, _commonButtonsView=0x38, _trialContentView=0x3c, _trialButtonsView=0x40, _trialExtendedContentView=0x44, _trialExtendedButtonsView=0x48, _trialLastExtendedContentView=0x4c, _trialLastExtendedButtonsView=0x50, _activateContentView=0x54, _activateButtonsView=0x58, _commonContinueButton=0x5c, _commonQuitButton=0x60, _commonAlternateButton=0x64, _trialContinueButton=0x68, _trialQuitButton=0x6c, _trialAlternateButton=0x70, _trialExtendedContinueButton=0x74, _trialExtendedQuitButton=0x78, _trialExtendedAlternateButton=0x7c, _trialExtendedAlternateOtherButton=0x80, _trialLastExtendedContinueButton=0x84, _trialLastExtendedQuitButton=0x88, _trialLastExtendedAlternateButton=0x8c, _trialLastExtendedAlternateOtherButton=0x90, _activateContinueButton=0x94, _activateQuitButton=0x98, _activateAlternateButton=0x9c, _commonSerialString=0xa0, _trialSerialString=0xa4, _trialExtendedSerialString=0xa8, _trialLastExtendedSerialString=0xac, _activateSerialString=0xb0, _activateInformationString=0xb4, _firstExtensionLinkButton=0xb8, _lastExtensionLinkButton=0xbc, _continueButton=0xc0, _quitButton=0xc4, _alternateButton=0xc8, _alternateOtherButton=0xcc, _serialStringField=0xd0, _delegate=0xd4, _validationContext=0xd8, _result=0xdc */

/* --- i386 decompilation (Ghidra) ---
/* FUN_0023d28b @ 0023d28b, 102 bytes * /

void FUN_0023d28b(HSSerialNumberDialogController *self,SEL _cmd,id controlTextDidChange)

{
  id self_00;
  id pvVar1;
  
  self_00 = self->_continueButton;
  pvVar1 = _objc_msgSend(self->_serialStringField,sel_stringValue);
  pvVar1 = _objc_msgSend(pvVar1,sel_length);
  _objc_msgSend(self_00,sel_setEnabled_,(uint)(pvVar1 != (id)0x0));
  return;
}

*/
- (void)controlTextDidChange:(id)aChange
{
    [_continueButton setEnabled:[[_serialStringField stringValue] length] != 0];
}

- (void)linkPressed:(id)aPressed
{
    [HSDocument openURL:[[NSBundle bundleForClass:[HSDocument class]] localizedStringForKey:@"HSEducationLink" value:@"" table:@"HyperPlayerBase"] versionString:nil addPlatformInfo:NO addProductName:NO];
}

- (void)orderNow:(id)aNow
{
    [HSDocument openURL:[[NSBundle bundleForClass:[HSDocument class]] localizedStringForKey:@"HSOrderHyperStudioURL" value:@"" table:@"HyperPlayerBase"] versionString:nil addPlatformInfo:NO addProductName:NO];
}

- (void)actionLicenseInfo:(id)aInfo
{
    [HSDocument openURL:[[NSBundle bundleForClass:[HSDocument class]] localizedStringForKey:@"HSLicenseInfoHyperStudioURL" value:@"" table:@"HyperPlayerBase"] versionString:nil addPlatformInfo:NO addProductName:NO];
}

- (void)actionAlternateOther:(id)aOther
{
    _result = 3;
    [NSApp stopModal];
}

- (void)actionAlternate:(id)aAlternate
{
    _result = 2;
    [NSApp stopModal];
}

- (void)actionQuit:(id)aQuit
{
    _result = 0;
    [NSApp stopModal];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0023d354 @ 0023d354, 1708 bytes * /

void FUN_0023d354(HSSerialNumberDialogController *self,SEL _cmd,id actionContinue)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  int iVar4;
  cfstringStruct *pcVar5;
  cfstringStruct *pcVar6;
  HSSerialNumberDialogController *pHVar7;
  cfstringStruct *pcVar8;
  cfstringStruct *local_1c;
  id local_18;
  id local_14;
  
  local_1c = (cfstringStruct *)sel_validateSerialString_controller_;
  pvVar2 = _objc_msgSend(self->_delegate,sel_respondsToSelector_,
                         sel_validateSerialString_controller_);
  if ((char)pvVar2 == '\0') {
    self->_result = 0;
    pvVar2 = *(id *)PTR_00336058;
    goto LAB_0023d3f9;
  }
  pvVar2 = self->_delegate;
  local_1c = _objc_msgSend(self->_serialStringField,sel_stringValue,local_1c);
  pHVar7 = self;
  pvVar2 = _objc_msgSend(pvVar2,sel_validateSerialString_controller_,local_1c,self);
  puVar1 = cls_NSBundle;
  switch(pvVar2) {
  case (id)0x0:
    self->_result = 1;
    goto LAB_0023d3e7;
  case (id)0x1:
    pvVar2 = _objc_msgSend(self->_dialogType,sel_isEqualToString_,
                           &cfstr_HSSerialNumberDialogControllerTypeActivate,pHVar7);
    puVar1 = cls_NSBundle;
    pvVar3 = _objc_msgSend(self,sel_class);
    pvVar3 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar3);
    if ((char)pvVar2 == '\0') {
      local_1c = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_Try_Again,
                               &cfstr_empty,&cfstr_Alerts);
      puVar1 = cls_NSBundle;
      pvVar2 = _objc_msgSend(self,sel_class);
      pvVar2 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar2);
      pcVar5 = &cfstr_Alerts;
      pcVar8 = &cfstr_empty;
      pcVar6 = &cfstr_Quit;
      local_14 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_Quit,
                               &cfstr_empty,&cfstr_Alerts);
    }
    else {
      pcVar5 = &cfstr_Alerts;
      pcVar8 = &cfstr_empty;
      pcVar6 = &cfstr_OK;
      local_14 = (id)0x0;
      local_1c = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_OK,&cfstr_empty,
                               &cfstr_Alerts);
    }
    puVar1 = cls_NSBundle;
    pvVar2 = _objc_msgSend(self,sel_class,pcVar6,pcVar8,pcVar5);
    pvVar2 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar2);
    local_18 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                             &cfstr_This_is_not_a_valid_serial_number,&cfstr_empty,&cfstr_Alerts);
    puVar1 = cls_NSBundle;
    pvVar2 = _objc_msgSend(self,sel_class);
    pvVar2 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar2);
    pcVar5 = &cfstr_Please_make_sure_you_have_entered_the_correct_se;
    break;
  case (id)0x2:
    pvVar2 = _objc_msgSend(self,sel_class,local_1c,pHVar7);
    pvVar2 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar2);
    local_1c = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_Try_Again,
                             &cfstr_empty,&cfstr_Alerts);
    pvVar2 = _objc_msgSend(self->_dialogType,sel_isEqualToString_,
                           &cfstr_HSSerialNumberDialogControllerTypeActivate);
    puVar1 = cls_NSBundle;
    pvVar3 = _objc_msgSend(self,sel_class);
    pvVar3 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar3);
    if ((char)pvVar2 == '\0') {
      pcVar5 = &cfstr_Quit;
    }
    else {
      pcVar5 = &cfstr_Cancel;
    }
    local_14 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,pcVar5,&cfstr_empty,
                             &cfstr_Alerts);
    puVar1 = cls_NSBundle;
    pvVar2 = _objc_msgSend(self,sel_class);
    pvVar2 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar2);
    local_18 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                             &cfstr_Your_HyperStudio_5_registration_number_has_been_,&cfstr_empty,
                             &cfstr_Alerts);
    puVar1 = cls_NSBundle;
    pvVar2 = _objc_msgSend(self,sel_class);
    pvVar2 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar2);
    pcVar5 = &cfstr_The_registration_number_you_have_entered_is_not_;
    break;
  case (id)0x3:
    local_1c = &cfstr_HSSerialNumberDialogControllerTypeCommon;
    pvVar2 = _objc_msgSend(self->_dialogType,sel_isEqualToString_,
                           &cfstr_HSSerialNumberDialogControllerTypeCommon,pHVar7);
    if ((char)pvVar2 == '\0') {
      local_1c = &cfstr_HSSerialNumberDialogControllerTypeTrialFirstExte;
      pvVar2 = _objc_msgSend(self->_dialogType,sel_isEqualToString_,
                             &cfstr_HSSerialNumberDialogControllerTypeTrialFirstExte,pHVar7);
      if ((char)pvVar2 != '\0') {
LAB_0023d841:
        self->_result = 3;
        goto LAB_0023d3e7;
      }
      local_1c = &cfstr_HSSerialNumberDialogControllerTypeTrialLastExten;
      pvVar2 = _objc_msgSend(self->_dialogType,sel_isEqualToString_,
                             &cfstr_HSSerialNumberDialogControllerTypeTrialLastExten,pHVar7);
      puVar1 = cls_NSBundle;
      if ((char)pvVar2 != '\0') goto LAB_0023d841;
      pvVar2 = _objc_msgSend(self,sel_class,local_1c,pHVar7);
      pvVar2 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar2);
      local_18 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                               &cfstr_Trial_HyperStudio_5_registration_number,&cfstr_empty,
                               &cfstr_Alerts);
      puVar1 = cls_NSBundle;
      pvVar2 = _objc_msgSend(self,sel_class);
      pvVar2 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar2);
      pvVar3 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                             &cfstr_The_number_you_have_entered_allows_to_extend_Tri,&cfstr_empty,
                             &cfstr_Alerts);
      puVar1 = cls_NSBundle;
      pvVar2 = _objc_msgSend(self,sel_class);
      pvVar2 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar2);
      local_14 = (id)0x0;
      local_1c = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_OK,&cfstr_empty,
                               &cfstr_Alerts);
      goto LAB_0023d981;
    }
    goto LAB_0023d7e3;
  default:
    return;
  }
  pvVar3 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,pcVar5,&cfstr_empty,
                         &cfstr_Alerts);
LAB_0023d981:
  if (local_18 == (id)0x0) {
    return;
  }
  if (pvVar3 == (id)0x0) {
    return;
  }
  iVar4 = _NSRunAlertPanel(local_18,pvVar3,local_1c,local_14,0);
  if (iVar4 == -1) {
LAB_0023d7e3:
    self->_result = 2;
  }
  else {
    if (iVar4 == 1) {
      return;
    }
    self->_result = 0;
  }
LAB_0023d3e7:
  pvVar2 = *(id *)PTR_00336058;
LAB_0023d3f9:
  _objc_msgSend(pvVar2,sel_stopModal,local_1c);
  return;
}

*/
- (void)actionContinue:(id)aContinue
{
    NSString *title;
    NSString *otherTitle = nil;
    NSString *message;
    NSString *informative;
    if (![_delegate respondsToSelector:@selector(validateSerialString:controller:)]) {
        _result = 0;
        [NSApp stopModal];
        return;
    }
    switch ((NSInteger)[_delegate validateSerialString:[_serialStringField stringValue] controller:self]) {
    case 0:
        _result = 1;
        [NSApp stopModal];
        return;
    case 1: {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        if ([_dialogType isEqualToString:@"HSSerialNumberDialogControllerTypeActivate"]) {
            title = [bundle localizedStringForKey:@"OK" value:@"" table:@"Alerts"];
        } else {
            title = [bundle localizedStringForKey:@"Try Again" value:@"" table:@"Alerts"];
            otherTitle = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Quit" value:@"" table:@"Alerts"];
        }
        message = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"This is not a valid serial number" value:@"" table:@"Alerts"];
        informative = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Please make sure you have entered the correct serial number" value:@"" table:@"Alerts"];
        break;
    }
    case 2:
        title = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Try Again" value:@"" table:@"Alerts"];
        otherTitle = [[NSBundle bundleForClass:[self class]] localizedStringForKey:([_dialogType isEqualToString:@"HSSerialNumberDialogControllerTypeActivate"] ? @"Cancel" : @"Quit") value:@"" table:@"Alerts"];
        message = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Your HyperStudio 5 registration number has been expired" value:@"" table:@"Alerts"];
        informative = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"The registration number you have entered is not valid anymore. Get a new registration number and try again" value:@"" table:@"Alerts"];
        break;
    case 3:
        if ([_dialogType isEqualToString:@"HSSerialNumberDialogControllerTypeCommon"] ||
            [_dialogType isEqualToString:@"HSSerialNumberDialogControllerTypeTrialFirstExtended"] ||
            [_dialogType isEqualToString:@"HSSerialNumberDialogControllerTypeTrialLastExtended"]) {
            _result = 3;
            [NSApp stopModal];
            return;
        }
        message = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Trial HyperStudio 5 registration number" value:@"" table:@"Alerts"];
        informative = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"The number you have entered allows to extend Trial period when it is over. Enter the registration number for non-expiring license and try again." value:@"" table:@"Alerts"];
        title = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"OK" value:@"" table:@"Alerts"];
        break;
    default:
        return;
    }
    if (message == nil || informative == nil) {
        return;
    }
    NSInteger button = NSRunAlertPanel(message, @"%@", title, otherTitle, nil, informative);
    if (button == -1) {
        _result = 2;
    } else {
        if (button == 1) {
            return;
        }
        _result = 0;
    }
    [NSApp stopModal];
}

- (void)setValidationContext:(id)aContext
{
    if (_validationContext != aContext) {
        [_validationContext release];
        _validationContext = [aContext retain];
    }
}

- (id)validationContext
{
    return _validationContext;
}

- (NSInteger)runModal
{
    unsigned int uVar3;

    [[self window] center];
    [NSApp runModalForWindow:[self window]];
    [self close];
    uVar3 = _result;
    if (3 < uVar3) {
        _result = 0;
        uVar3 = 0;
    }
    return uVar3;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0023ce84 @ 0023ce84, 107 bytes * /

BOOL FUN_0023ce84(HSSerialNumberDialogController *self,SEL _cmd,int isActionButtonEnabled)

{
  id pvVar1;
  
  switch(isActionButtonEnabled) {
  case 0:
    pvVar1 = self->_quitButton;
    break;
  case 1:
    pvVar1 = self->_continueButton;
    break;
  case 2:
    pvVar1 = self->_alternateButton;
    break;
  case 3:
    pvVar1 = self->_alternateOtherButton;
    break;
  default:
    return '\0';
  }
  pvVar1 = _objc_msgSend(pvVar1,sel_isEnabled);
  return (BOOL)pvVar1;
}

*/
- (BOOL)isActionButtonEnabled:(NSInteger)aEnabled
{
    NSButton *button;
    switch (aEnabled) {
    case 0: button = _quitButton; break;
    case 1: button = _continueButton; break;
    case 2: button = _alternateButton; break;
    case 3: button = _alternateOtherButton; break;
    default: return NO;
    }
    return [button isEnabled];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0023cdfc @ 0023cdfc, 119 bytes * /

void FUN_0023cdfc(HSSerialNumberDialogController *self,SEL _cmd,BOOL enableButton,int forAction)

{
  id self_00;
  
  switch(forAction) {
  case 0:
    self_00 = self->_quitButton;
    break;
  case 1:
    self_00 = self->_continueButton;
    break;
  case 2:
    self_00 = self->_alternateButton;
    break;
  case 3:
    self_00 = self->_alternateOtherButton;
    break;
  default:
    goto switchD_0023ce20_default;
  }
  _objc_msgSend(self_00,sel_setEnabled_,(int)enableButton);
switchD_0023ce20_default:
  return;
}

*/
- (void)enableButton:(BOOL)aButton forAction:(NSInteger)aAction
{
    NSButton *button;
    switch (aAction) {
    case 0: button = _quitButton; break;
    case 1: button = _continueButton; break;
    case 2: button = _alternateButton; break;
    case 3: button = _alternateOtherButton; break;
    default: return;
    }
    [button setEnabled:aButton];
}

- (id)delegate
{
    return _delegate;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0023da10 @ 0023da10, 1038 bytes * /

void FUN_0023da10(HSSerialNumberDialogController *self,SEL _cmd)

{
  id pvVar1;
  id local_54;
  id local_50;
  HSSerialNumberDialogController *local_4c;
  undefined *local_48;
  undefined1 local_44 [8];
  float local_3c;
  float local_38;
  undefined1 local_34 [8];
  float local_2c;
  float local_28;
  undefined1 local_24 [8];
  float local_1c;
  float local_18;
  
  local_4c = self;
  local_48 = PTR_s_NSWindowController_00355790;
  _objc_msgSendSuper(&local_4c,sel_windowDidLoad);
  pvVar1 = _objc_msgSend(self->_dialogType,sel_isEqualToString_,
                         &cfstr_HSSerialNumberDialogControllerTypeTrial);
  if ((char)pvVar1 == '\0') {
    local_54 = (id)0x0;
    local_50 = (id)0x0;
  }
  else {
    local_54 = self->_trialContentView;
    local_50 = self->_trialButtonsView;
    self->_serialStringField = self->_trialSerialString;
    self->_continueButton = self->_trialContinueButton;
    self->_quitButton = self->_trialQuitButton;
    self->_alternateButton = self->_trialAlternateButton;
  }
  pvVar1 = _objc_msgSend(self->_dialogType,sel_isEqualToString_,
                         &cfstr_HSSerialNumberDialogControllerTypeTrialFirstExte);
  if ((char)pvVar1 != '\0') {
    local_54 = self->_trialExtendedContentView;
    local_50 = self->_trialExtendedButtonsView;
    self->_serialStringField = self->_trialExtendedSerialString;
    self->_continueButton = self->_trialExtendedContinueButton;
    self->_quitButton = self->_trialExtendedQuitButton;
    self->_alternateButton = self->_trialExtendedAlternateButton;
    self->_alternateOtherButton = self->_trialExtendedAlternateOtherButton;
    _objc_msgSend(self,sel_HSSerialNumberDialogController_configureLinkButton_,
                  self->_firstExtensionLinkButton);
  }
  pvVar1 = _objc_msgSend(self->_dialogType,sel_isEqualToString_,
                         &cfstr_HSSerialNumberDialogControllerTypeTrialLastExten);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(self->_dialogType,sel_isEqualToString_,
                           &cfstr_HSSerialNumberDialogControllerTypeCommon);
    if ((char)pvVar1 == '\0') {
      pvVar1 = _objc_msgSend(self->_dialogType,sel_isEqualToString_,
                             &cfstr_HSSerialNumberDialogControllerTypeCommonWOTrial);
      if ((char)pvVar1 == '\0') {
        pvVar1 = _objc_msgSend(self->_dialogType,sel_isEqualToString_,
                               &cfstr_HSSerialNumberDialogControllerTypeActivate);
        if ((char)pvVar1 == '\0') goto LAB_0023dcb3;
        local_54 = self->_activateContentView;
        local_50 = self->_activateButtonsView;
        self->_serialStringField = self->_activateSerialString;
        self->_continueButton = self->_activateContinueButton;
        self->_quitButton = self->_activateQuitButton;
        pvVar1 = self->_activateAlternateButton;
      }
      else {
        local_54 = self->_commonContentView;
        local_50 = self->_trialButtonsView;
        self->_serialStringField = self->_commonSerialString;
        self->_continueButton = self->_trialContinueButton;
        self->_quitButton = self->_trialQuitButton;
        pvVar1 = self->_trialAlternateButton;
      }
    }
    else {
      local_54 = self->_commonContentView;
      local_50 = self->_commonButtonsView;
      self->_serialStringField = self->_commonSerialString;
      self->_continueButton = self->_commonContinueButton;
      self->_quitButton = self->_commonQuitButton;
      pvVar1 = self->_commonAlternateButton;
    }
    self->_alternateButton = pvVar1;
  }
  else {
    local_54 = self->_trialLastExtendedContentView;
    local_50 = self->_trialLastExtendedButtonsView;
    self->_serialStringField = self->_trialLastExtendedSerialString;
    self->_continueButton = self->_trialLastExtendedContinueButton;
    self->_quitButton = self->_trialLastExtendedQuitButton;
    self->_alternateButton = self->_trialLastExtendedAlternateButton;
    self->_alternateOtherButton = self->_trialLastExtendedAlternateOtherButton;
    _objc_msgSend(self,sel_HSSerialNumberDialogController_configureLinkButton_,
                  self->_lastExtensionLinkButton);
  }
LAB_0023dcb3:
  _objc_msgSend_stret(local_44,self->_contentView,sel_bounds);
  _objc_msgSend_stret(local_34,local_54,sel_bounds);
  pvVar1 = _objc_msgSend(self,sel_window);
  pvVar1 = _objc_msgSend(pvVar1,sel_contentView);
  _objc_msgSend_stret(local_24,pvVar1,sel_bounds);
  pvVar1 = _objc_msgSend(self,sel_window);
  _objc_msgSend(pvVar1,sel_setContentSize_,(local_2c - local_3c) + local_1c,
                (local_28 - local_38) + local_18);
  _objc_msgSend(self->_contentView,sel_addSubview_,local_54);
  _objc_msgSend(self->_buttonsView,sel_addSubview_,local_50);
  _objc_msgSend(self->_serialStringField,sel_setDelegate_,self);
  return;
}

*/
- (void)windowDidLoad
{
    [super windowDidLoad];
    NSView *content = nil;
    NSView *buttons = nil;
    if ([_dialogType isEqualToString:@"HSSerialNumberDialogControllerTypeTrial"]) {
        content = _trialContentView;
        buttons = _trialButtonsView;
        _serialStringField = _trialSerialString;
        _continueButton = _trialContinueButton;
        _quitButton = _trialQuitButton;
        _alternateButton = _trialAlternateButton;
    }
    if ([_dialogType isEqualToString:@"HSSerialNumberDialogControllerTypeTrialFirstExtended"]) {
        content = _trialExtendedContentView;
        buttons = _trialExtendedButtonsView;
        _serialStringField = _trialExtendedSerialString;
        _continueButton = _trialExtendedContinueButton;
        _quitButton = _trialExtendedQuitButton;
        _alternateButton = _trialExtendedAlternateButton;
        _alternateOtherButton = _trialExtendedAlternateOtherButton;
        [self HSSerialNumberDialogController_configureLinkButton:_firstExtensionLinkButton];
    }
    if ([_dialogType isEqualToString:@"HSSerialNumberDialogControllerTypeTrialLastExtended"]) {
        content = _trialLastExtendedContentView;
        buttons = _trialLastExtendedButtonsView;
        _serialStringField = _trialLastExtendedSerialString;
        _continueButton = _trialLastExtendedContinueButton;
        _quitButton = _trialLastExtendedQuitButton;
        _alternateButton = _trialLastExtendedAlternateButton;
        _alternateOtherButton = _trialLastExtendedAlternateOtherButton;
        [self HSSerialNumberDialogController_configureLinkButton:_lastExtensionLinkButton];
    } else if ([_dialogType isEqualToString:@"HSSerialNumberDialogControllerTypeCommon"]) {
        content = _commonContentView;
        buttons = _commonButtonsView;
        _serialStringField = _commonSerialString;
        _continueButton = _commonContinueButton;
        _quitButton = _commonQuitButton;
        _alternateButton = _commonAlternateButton;
    } else if ([_dialogType isEqualToString:@"HSSerialNumberDialogControllerTypeCommonWOTrial"]) {
        content = _commonContentView;
        buttons = _trialButtonsView;
        _serialStringField = _commonSerialString;
        _continueButton = _trialContinueButton;
        _quitButton = _trialQuitButton;
        _alternateButton = _trialAlternateButton;
    } else if ([_dialogType isEqualToString:@"HSSerialNumberDialogControllerTypeActivate"]) {
        content = _activateContentView;
        buttons = _activateButtonsView;
        _serialStringField = _activateSerialString;
        _continueButton = _activateContinueButton;
        _quitButton = _activateQuitButton;
        _alternateButton = _activateAlternateButton;
    }
    NSRect contentBounds = [_contentView bounds];
    NSRect newContentBounds = [content bounds];
    NSRect windowBounds = [[[self window] contentView] bounds];
    [[self window] setContentSize:NSMakeSize((windowBounds.size.width - contentBounds.size.width) + newContentBounds.size.width,
                                             (windowBounds.size.height - contentBounds.size.height) + newContentBounds.size.height)];
    [_contentView addSubview:content];
    [_buttonsView addSubview:buttons];
    [_serialStringField setDelegate:self];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0023cae8 @ 0023cae8, 788 bytes * /

void FUN_0023cae8(HSSerialNumberDialogController *self,SEL _cmd,
                 id HSSerialNumberDialogController_configureLinkButton)

{
  undefined4 uVar1;
  undefined4 uVar2;
  undefined *puVar3;
  undefined *puVar4;
  undefined *puVar5;
  id pvVar6;
  id pvVar7;
  id pvVar8;
  id pvVar9;
  
  pvVar6 = _objc_msgSend(cls_NSMutableAttributedString,sel_alloc);
  pvVar7 = _objc_msgSend(HSSerialNumberDialogController_configureLinkButton,sel_attributedTitle);
  pvVar6 = _objc_msgSend(pvVar6,sel_initWithAttributedString_,pvVar7);
  pvVar6 = _objc_msgSend(pvVar6,sel_autorelease);
  pvVar7 = _objc_msgSend(pvVar6,sel_length);
  puVar5 = cls_NSDictionary;
  puVar3 = PTR_00336394;
  uVar1 = *(undefined4 *)PTR_00336394;
  pvVar8 = _objc_msgSend(cls_NSColor,sel_blueColor);
  puVar4 = PTR_003363e4;
  uVar2 = *(undefined4 *)PTR_003363e4;
  pvVar9 = _objc_msgSend(cls_NSNumber,sel_numberWithInt_,1);
  pvVar8 = _objc_msgSend(puVar5,sel_dictionaryWithObjectsAndKeys_,pvVar9,uVar2,pvVar8,uVar1,0);
  _objc_msgSend(pvVar6,sel_addAttributes_range_,pvVar8,0,pvVar7);
  pvVar7 = _objc_msgSend(pvVar6,sel_length);
  _objc_msgSend(pvVar6,sel_setAlignment_range_,2,0,pvVar7);
  _objc_msgSend(HSSerialNumberDialogController_configureLinkButton,sel_setAttributedTitle_,pvVar6);
  puVar5 = cls_NSDictionary;
  uVar1 = *(undefined4 *)puVar3;
  pvVar6 = _objc_msgSend(cls_NSColor,sel_brownColor);
  uVar2 = *(undefined4 *)puVar4;
  pvVar7 = _objc_msgSend(cls_NSNumber,sel_numberWithInt_,1);
  pvVar6 = _objc_msgSend(puVar5,sel_dictionaryWithObjectsAndKeys_,pvVar7,uVar2,pvVar6,uVar1,0);
  pvVar7 = _objc_msgSend(cls_NSMutableAttributedString,sel_alloc);
  pvVar8 = _objc_msgSend(HSSerialNumberDialogController_configureLinkButton,sel_attributedTitle);
  pvVar7 = _objc_msgSend(pvVar7,sel_initWithAttributedString_,pvVar8);
  pvVar7 = _objc_msgSend(pvVar7,sel_autorelease);
  pvVar8 = _objc_msgSend(pvVar7,sel_length);
  _objc_msgSend(pvVar7,sel_addAttributes_range_,pvVar6,0,pvVar8);
  pvVar6 = _objc_msgSend(pvVar7,sel_length);
  _objc_msgSend(pvVar7,sel_setAlignment_range_,2,0,pvVar6);
  _objc_msgSend(HSSerialNumberDialogController_configureLinkButton,sel_setAttributedAlternateTitle_,
                pvVar7);
  _objc_msgSend(HSSerialNumberDialogController_configureLinkButton,sel_setFocusRingType_,1);
  return;
}

*/
- (void)HSSerialNumberDialogController_configureLinkButton:(id)aButton
{
    NSMutableAttributedString *title = [[[NSMutableAttributedString alloc] initWithAttributedString:[aButton attributedTitle]] autorelease];
    [title addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], NSUnderlineStyleAttributeName, [NSColor blueColor], NSForegroundColorAttributeName, nil] range:NSMakeRange(0, [title length])];
    [title setAlignment:NSCenterTextAlignment range:NSMakeRange(0, [title length])];
    [aButton setAttributedTitle:title];
    NSDictionary *pressed = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], NSUnderlineStyleAttributeName, [NSColor brownColor], NSForegroundColorAttributeName, nil];
    NSMutableAttributedString *alternate = [[[NSMutableAttributedString alloc] initWithAttributedString:[aButton attributedTitle]] autorelease];
    [alternate addAttributes:pressed range:NSMakeRange(0, [alternate length])];
    [alternate setAlignment:NSCenterTextAlignment range:NSMakeRange(0, [alternate length])];
    [aButton setAttributedAlternateTitle:alternate];
    [aButton setFocusRingType:NSFocusRingTypeNone];
}

- (void)dealloc
{
    [_dialogType release];
    [_validationContext release];
    [super dealloc];
}

- (id)initWithType:(id)aType
{
    self = [super initWithWindowNibName:@"SerializationDialog"];
    if (self != nil) {
        _dialogType = [aType retain];
    }
    return self;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0023cab8 @ 0023cab8, 48 bytes * /

id FUN_0023cab8(HSSerialNumberDialogController *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_initWithType_,&cfstr_HSSerialNumberDialogControllerTypeCommon);
  return pvVar1;
}

*/
- (id)init
{
    return [self initWithType:@"HSSerialNumberDialogControllerTypeCommon"];
}

@end

