#import "HSRegistrationKeyEquivalentButton.h"

@implementation HSRegistrationKeyEquivalentButton

- (BOOL)canBecomeKeyView
{
    return NO;
}

@end

@implementation HSRegistrationLinkButton

- (void)resetCursorRects
{
    [self addCursorRect:[[self cell] drawingRectForBounds:[self bounds]] cursor:[NSCursor pointingHandCursor]];
}

@end

@implementation HSRegistrationFormController

/* i386 ivar offsets: _type=0x28, _countriesMap=0x2c, _optionsView=0x30, _buttonsView=0x34, _trialOptionsView=0x38, _trialReducedOptionsView=0x3c, _serialOptionsView=0x40, _trialButtonsView=0x44, _serialButtonsView=0x48, _trialFirstNameField=0x4c, _trialLastNameField=0x50, _trialEmailField=0x54, _trialAddressField=0x58, _trialCityField=0x5c, _trialZipField=0x60, _trialSchoolTitleField=0x64, _trialSchoolNameField=0x68, _trialSchoolDistrictField=0x6c, _trialCountryPopUp=0x70, _trialStateProvPopUp=0x74, _trialStatesStarField=0x78, _trialMySchoolDistrictPopUp=0x7c, _trialMacsTypePopUp=0x80, _trialSchoolPricesCheckBox=0x84, _trialFreeUpdatesCheckBox=0x88, _trialLessonPlanesCheckBox=0x8c, _trialENewsEmailsCheckBox=0x90, _trialPrivacyStatementButton=0x94, _trialReducedFirstNameField=0x98, _trialReducedLastNameField=0x9c, _trialReducedEmailField=0xa0, _trialReducedSchoolPricesCheckBox=0xa4, _trialReducedFreeUpdatesCheckBox=0xa8, _trialReducedLessonPlanesCheckBox=0xac, _trialReducedENewsEmailsCheckBox=0xb0, _trialReducedPrivacyStatementButton=0xb4, _serialFirstNameField=0xb8, _serialLastNameField=0xbc, _serialEmailField=0xc0, _serialCityField=0xc4, _serialSchoolNameField=0xc8, _serialCountryPopUp=0xcc, _serialStateProvPopUp=0xd0, _serialStatesStarField=0xd4, _serialLocationPopUp=0xd8, _serialFreeUpdatesCheckBox=0xdc, _serialCompanyNewsCheckBox=0xe0, _serialEducationPricingCheckBox=0xe4, _serialPrivacyStatementButton=0xe8, _noStatesMenu=0xec, _privacyStatementWindow=0xf0, _formControls=0xf4 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_0023b785 @ 0023b785, 1561 bytes * /

id FUN_0023b785(id self,SEL _cmd,id completeRegistrationDictionaryWithSerial,id type)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  undefined4 *self_01;
  id pvVar6;
  cfstringStruct *pcVar7;
  int iVar8;
  undefined4 *puVar9;
  undefined1 *puVar10;
  cfstringStruct *pcVar11;
  undefined4 uVar12;
  id local_f8;
  cfstringStruct *local_f4;
  cfstringStruct *local_ec [6];
  undefined4 local_d4;
  int local_d0;
  int *local_cc;
  undefined4 local_c8;
  undefined4 local_c4;
  undefined4 local_c0;
  undefined4 local_bc;
  undefined4 local_b8;
  undefined1 local_b4 [64];
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  cfstringStruct local_50 [4];
  
  pvVar1 = _objc_msgSend(self,sel_defaultsPanelOptionsDictionary);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
    pvVar2 = _objc_msgSend(pvVar2,sel_stringForKey_,
                           &cfstr_HSRegistrationDefaultsKeyRegistrationChoice);
    pcVar7 = &cfstr_HSRegistrationDefaultsValRegistered;
    pvVar2 = _objc_msgSend(pvVar2,sel_isEqualToString_,&cfstr_HSRegistrationDefaultsValRegistered);
    if ((char)pvVar2 != '\0') {
      pvVar1 = _objc_msgSend(pvVar1,sel_mutableCopy,pcVar7);
      pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
      if (pvVar1 != (id)0x0) {
        local_f4 = &cfstr_HSRegistrationFormOptionsKeyReceiveHSMail;
        local_ec[1] = &cfstr_HSRegistrationFormOptionsKeyReceiveAllMail;
        local_ec[2] = &cfstr_HSRegistrationFormOptionsKeyReceiveSchoolMail;
        local_ec[3] = &cfstr_HSRegistrationFormSchoolPrices;
        local_ec[4] = &cfstr_HSRegistrationFormLessonPlanes;
        local_ec[5] = &cfstr_HSRegistrationFormENewsEmails;
        iVar8 = 1;
        local_ec[0] = local_f4;
        while( true ) {
          pvVar2 = _objc_msgSend(pvVar1,sel_objectForKey_,local_f4);
          pvVar2 = _objc_msgSend(pvVar2,sel_intValue);
          if (pvVar2 == (id)0x0) {
            _objc_msgSend(pvVar1,sel_removeObjectForKey_,local_f4);
          }
          if (iVar8 == 6) break;
          local_f4 = local_ec[iVar8];
          iVar8 = iVar8 + 1;
        }
        pvVar2 = _objc_msgSend(self,sel_keysDictionaryForType_,type);
        pvVar3 = _objc_msgSend(pvVar2,sel_objectForKey_,&cfstr_required);
        local_d4 = 0;
        local_d0 = 0;
        local_cc = (int *)0x0;
        local_c8 = 0;
        local_c4 = 0;
        local_c0 = 0;
        local_bc = 0;
        local_b8 = 0;
        puVar10 = local_b4;
        puVar9 = &local_d4;
        uVar12 = 0x10;
        pvVar4 = _objc_msgSend(pvVar3,sel_countByEnumeratingWithState_objects_count_,puVar9,puVar10,
                               0x10);
        if (pvVar4 != (id)0x0) {
          iVar8 = *local_cc;
          do {
            pvVar6 = (id)0x0;
            do {
              if (iVar8 != *local_cc) {
                _objc_enumerationMutation(pvVar3);
              }
              pvVar5 = _objc_msgSend(pvVar1,sel_objectForKey_,
                                     *(undefined4 *)(local_d0 + (int)pvVar6 * 4),puVar10,uVar12);
              if (pvVar5 == (id)0x0) {
                return (id)0x0;
              }
              pvVar6 = (id)((int)pvVar6 + 1);
            } while (pvVar6 < pvVar4);
            puVar10 = local_b4;
            puVar9 = &local_d4;
            uVar12 = 0x10;
            pvVar4 = _objc_msgSend(pvVar3,sel_countByEnumeratingWithState_objects_count_,puVar9,
                                   puVar10,0x10);
          } while (pvVar4 != (id)0x0);
        }
        self_00 = cls_NSMutableDictionary;
        pvVar3 = _objc_msgSend(pvVar1,sel_count,puVar9,puVar10,uVar12);
        pvVar3 = _objc_msgSend(self_00,sel_dictionaryWithCapacity_,pvVar3);
        pvVar2 = _objc_msgSend(pvVar2,sel_objectForKey_,&cfstr_acceptable);
        local_74 = 0;
        local_70 = 0;
        local_6c = (int *)0x0;
        local_68 = 0;
        local_64 = 0;
        local_60 = 0;
        local_5c = 0;
        local_58 = 0;
        pcVar7 = local_50;
        puVar9 = &local_74;
        uVar12 = 0x10;
        local_f8 = _objc_msgSend(pvVar2,sel_countByEnumeratingWithState_objects_count_,puVar9,pcVar7
                                 ,0x10);
        if (local_f8 != (id)0x0) {
          iVar8 = *local_6c;
          do {
            pvVar4 = (id)0x0;
            do {
              if (iVar8 != *local_6c) {
                _objc_enumerationMutation(pvVar2);
              }
              pcVar11 = *(cfstringStruct **)(local_70 + (int)pvVar4 * 4);
              pvVar6 = _objc_msgSend(pvVar1,sel_objectForKey_,pcVar11,pcVar7,uVar12);
              if (pvVar6 != (id)0x0) {
                _objc_msgSend(pvVar3,sel_setObject_forKey_,pvVar6,pcVar11);
                pcVar7 = pcVar11;
              }
              pvVar4 = (id)((int)pvVar4 + 1);
            } while (pvVar4 < local_f8);
            pcVar7 = local_50;
            puVar9 = &local_74;
            uVar12 = 0x10;
            local_f8 = _objc_msgSend(pvVar2,sel_countByEnumeratingWithState_objects_count_,puVar9,
                                     pcVar7,0x10);
          } while (local_f8 != (id)0x0);
        }
        pvVar1 = _objc_msgSend(completeRegistrationDictionaryWithSerial,sel_length,puVar9,pcVar7,
                               uVar12);
        if (pvVar1 != (id)0x0) {
          pcVar7 = &cfstr_serial;
          _objc_msgSend(pvVar3,sel_setObject_forKey_,completeRegistrationDictionaryWithSerial,
                        &cfstr_serial,uVar12);
          puVar9 = completeRegistrationDictionaryWithSerial;
        }
        pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle,puVar9,pcVar7,uVar12);
        self_01 = _objc_msgSend(pvVar1,sel_HS_buildVersion);
        pvVar1 = _objc_msgSend(self_01,sel_length);
        if (pvVar1 != (id)0x0) {
          pcVar7 = &cfstr_build_number;
          _objc_msgSend(pvVar3,sel_setObject_forKey_,self_01,&cfstr_build_number);
          puVar9 = self_01;
        }
        pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle,puVar9,pcVar7);
        pvVar1 = _objc_msgSend(pvVar1,sel_objectForInfoDictionaryKey_,
                               &cfstr_CFBundleShortVersionString);
        pvVar2 = _objc_msgSend(pvVar1,sel_length);
        if (pvVar2 != (id)0x0) {
          pcVar7 = &cfstr_short_version;
          _objc_msgSend(pvVar3,sel_setObject_forKey_,pvVar1,&cfstr_short_version);
        }
        pvVar1 = _objc_msgSend(pvVar3,sel_objectForKey_,&cfstr_HSRegistrationFormMacsType,pcVar7);
        if (pvVar1 == (id)0x0) {
          if (DAT_00342a30 == 0) {
            _Gestalt(0x73797361,&DAT_00342a30);
          }
          pcVar7 = &cfstr_Only_older_Macs;
          if (DAT_00342a30 == 10) {
            pcVar7 = &cfstr_Only_Intel_Macs;
          }
          _objc_msgSend(pvVar3,sel_setObject_forKey_,pcVar7,&cfstr_HSRegistrationFormMacsType);
          return pvVar3;
        }
        return pvVar3;
      }
    }
  }
  return (id)0x0;
}

*/
+ (id)completeRegistrationDictionaryWithSerial:(id)aSerial type:(id)aType
{
    id stored = [self defaultsPanelOptionsDictionary];
    if (stored == nil) {
        return nil;
    }
    NSString *choice = [[NSUserDefaults standardUserDefaults] stringForKey:@"HSRegistrationDefaultsKeyRegistrationChoice"];
    if (![choice isEqualToString:@"HSRegistrationDefaultsValRegistered"]) {
        return nil;
    }
    NSMutableDictionary *options = [[stored mutableCopy] autorelease];
    if (options == nil) {
        return nil;
    }
    NSString *flagKeys[6] = { @"HSRegistrationFormOptionsKeyReceiveHSMail", @"HSRegistrationFormOptionsKeyReceiveAllMail", @"HSRegistrationFormOptionsKeyReceiveSchoolMail", @"HSRegistrationFormSchoolPrices", @"HSRegistrationFormLessonPlanes", @"HSRegistrationFormENewsEmails" };
    for (int i = 0; i < 6; i++) {
        if ([[options objectForKey:flagKeys[i]] intValue] == 0) {
            [options removeObjectForKey:flagKeys[i]];
        }
    }
    NSDictionary *keys = [self keysDictionaryForType:aType];
    for (id key in [keys objectForKey:@"required"]) {
        if ([options objectForKey:key] == nil) {
            return nil;
        }
    }
    NSMutableDictionary *registration = [NSMutableDictionary dictionaryWithCapacity:[options count]];
    for (id key in [keys objectForKey:@"acceptable"]) {
        id value = [options objectForKey:key];
        if (value != nil) {
            [registration setObject:value forKey:key];
        }
    }
    if ([aSerial length] != 0) {
        [registration setObject:aSerial forKey:@"serial"];
    }
    NSString *buildVersion = [[NSBundle mainBundle] HS_buildVersion];
    if ([buildVersion length] != 0) {
        [registration setObject:buildVersion forKey:@"build number"];
    }
    id shortVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if ([shortVersion length] != 0) {
        [registration setObject:shortVersion forKey:@"short version"];
    }
    if ([registration objectForKey:@"HSRegistrationFormMacsType"] == nil) {
        static SInt32 sSystemArchitecture;
        if (sSystemArchitecture == 0) {
            Gestalt(gestaltSysArchitecture, &sSystemArchitecture);
        }
        [registration setObject:(sSystemArchitecture == gestaltIntel) ? @"Only Intel Macs" : @"Only older Macs" forKey:@"HSRegistrationFormMacsType"];
    }
    return registration;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0023b68d @ 0023b68d, 144 bytes * /

id FUN_0023b68d(id self,SEL _cmd,id keysDictionaryForType)

{
  id pvVar1;
  cfstringStruct *pcVar2;
  
  pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pcVar2 = &cfstr_plist;
  pvVar1 = _objc_msgSend(pvVar1,sel_pathForResource_ofType_,&cfstr_registrationKeys,&cfstr_plist);
  if (pvVar1 == (id)0x0) {
    pvVar1 = (id)0x0;
  }
  else {
    pvVar1 = _objc_msgSend(cls_NSDictionary,sel_dictionaryWithContentsOfFile_,pvVar1,pcVar2);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,keysDictionaryForType);
  }
  return pvVar1;
}

*/
+ (id)keysDictionaryForType:(id)aType
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"registrationKeys" ofType:@"plist"];
    if (path == nil) {
        return nil;
    }
    return [[NSDictionary dictionaryWithContentsOfFile:path] objectForKey:aType];
}

+ (id)defaultsPanelOptionsDictionary
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"HSRegistrationDefaultsKeyStoredPanelOptions"];
}

+ (BOOL)shouldShowRegistrationForm
{
    BOOL bVar2;
    id pvVar1_2;

    pvVar1_2 = [[NSUserDefaults standardUserDefaults] objectForKey:@"HSRegistrationDefaultsKeyRegistrationChoice"];
    if (pvVar1_2 == nil) {
        bVar2 = NO;
    }
    else {
        bVar2 = ![pvVar1_2 isEqualToString:@"HSRegistrationDefaultsValRegisterLater"];
    }
    return bVar2;
}

- (void)paste:(id)aPaste
{
    NSResponder *pvVar1_2;

    pvVar1_2 = [[self window] firstResponder];
    if ([pvVar1_2 respondsToSelector:_cmd]) {
        [[[self window] firstResponder] performSelector:_cmd withObject:aPaste];
    }
}

- (void)cut:(id)aCut
{
    NSResponder *pvVar1_2;

    pvVar1_2 = [[self window] firstResponder];
    if ([pvVar1_2 respondsToSelector:_cmd]) {
        [[[self window] firstResponder] performSelector:_cmd withObject:aCut];
    }
}

- (void)copy:(id)aCopy
{
    NSResponder *pvVar1_2;

    pvVar1_2 = [[self window] firstResponder];
    if ([pvVar1_2 respondsToSelector:_cmd]) {
        [[[self window] firstResponder] performSelector:_cmd withObject:aCopy];
    }
}

- (void)sheetDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    [aEnd orderOut:nil];
}

- (void)alertSheetDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    [[aEnd window] orderOut:nil];
}

- (void)privacyStatementWindowOK:(id)aOK
{
    [NSApp endSheet:_privacyStatementWindow returnCode:1];
}

- (void)showPrivacyStatement:(id)aStatement
{
    [NSApp beginSheet:_privacyStatementWindow modalForWindow:[self window] modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:0];
}

- (void)changeUseLocation:(id)aLocation
{
    [_formControls->f4 setStringValue:@""];
    [(_formControls->f4) setEnabled:(unsigned int)([[_serialLocationPopUp selectedItem] tag] == 0x1)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0023b0cd @ 0023b0cd, 387 bytes * /

void FUN_0023b0cd(HSRegistrationFormController *self,SEL _cmd,id changeCountry)

{
  id pvVar1;
  id pvVar2;
  cfstringStruct *pcVar3;
  
  _objc_msgSend(self->_formControls->f6,sel_selectItemAtIndex_,0);
  pvVar1 = _objc_msgSend(self->_countriesMap,sel_objectForKey_,&cfstr_States);
  pvVar2 = _objc_msgSend(self->_formControls->f5,sel_selectedItem);
  pvVar2 = _objc_msgSend(pvVar2,sel_title);
  pvVar2 = _objc_msgSend(pvVar1,sel_objectForKey_,pvVar2);
  pvVar1 = self->_formControls->f6;
  if (pvVar2 == (id)0x0) {
    _objc_msgSend(pvVar1,sel_setMenu_,self->_noStatesMenu);
    _objc_msgSend(self->_formControls->f6,sel_setEnabled_,0);
    pvVar1 = self->_formControls->f7;
    pcVar3 = &cfstr_empty;
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_HSRegistrationFormController_menuWithTitles_,pvVar2);
    _objc_msgSend(pvVar1,sel_setMenu_,pvVar2);
    _objc_msgSend(self->_formControls->f6,sel_setEnabled_,1);
    pvVar1 = self->_formControls->f7;
    pcVar3 = &cfstr__;
  }
  _objc_msgSend(pvVar1,sel_setStringValue_,pcVar3);
  return;
}

*/
- (void)changeCountry:(id)aCountry
{
    [_formControls->f6 selectItemAtIndex:0];
    NSArray *states = [[_countriesMap objectForKey:@"States"] objectForKey:[[_formControls->f5 selectedItem] title]];
    NSPopUpButton *statePopUp = _formControls->f6;
    NSString *stateStar;
    if (states == nil) {
        [statePopUp setMenu:_noStatesMenu];
        [_formControls->f6 setEnabled:NO];
        stateStar = @"";
    }
    else {
        [statePopUp setMenu:[self HSRegistrationFormController_menuWithTitles:states]];
        [_formControls->f6 setEnabled:YES];
        stateStar = @"*";
    }
    [_formControls->f7 setStringValue:stateStar];
}

- (void)otherButtonClick:(id)aClick
{
    [NSApp stopModalWithCode:2];
}

- (void)alternateButtonClick:(id)aClick
{
    [NSApp stopModalWithCode:1];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0023acab @ 0023acab, 956 bytes * /

void FUN_0023acab(HSRegistrationFormController *self,SEL _cmd,id defaultButtonClick)

{
  undefined *puVar1;
  undefined *self_00;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  SEL op;
  int *piVar5;
  int local_14;
  
  local_14 = 0;
  piVar5 = &local_14;
  pvVar2 = _objc_msgSend(self,sel_HSRegistrationFormController_isRequiredFieldsFilled_,piVar5);
  self_00 = cls_NSAlert;
  puVar1 = cls_NSBundle;
  if ((char)pvVar2 == '\0') {
    if (local_14 == 2) {
      pvVar2 = _objc_msgSend(self,sel_class,piVar5);
      pvVar2 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar2);
      pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                             &cfstr_Email_address_not_complete___,&cfstr_empty,
                             &cfstr_RegistrationFormLocalized);
      puVar1 = cls_NSBundle;
      pvVar3 = _objc_msgSend(self,sel_class);
      pvVar3 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar3);
      pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_OK,&cfstr_empty,
                             &cfstr_RegistrationFormLocalized);
      puVar1 = cls_NSBundle;
      pvVar4 = _objc_msgSend(self,sel_class);
      pvVar4 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar4);
      pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,
                             &cfstr_Email_address_not_complete,&cfstr_empty,
                             &cfstr_RegistrationFormLocalized);
      pvVar2 = _objc_msgSend(self_00,
                             sel_alertWithMessageText_defaultButton_alternateButton_otherButton_informativeTextWithFormat_
                             ,pvVar4,pvVar3,0,0,pvVar2);
      pvVar3 = _objc_msgSend(self,sel_window);
      op = sel_beginSheetModalForWindow_modalDelegate_didEndSelector_contextInfo_;
    }
    else {
      if (local_14 != 1) {
        return;
      }
      pvVar2 = _objc_msgSend(self,sel_class,piVar5);
      pvVar2 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar2);
      pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                             &cfstr_Required_information_incomplete___,&cfstr_empty,
                             &cfstr_RegistrationFormLocalized);
      puVar1 = cls_NSBundle;
      pvVar3 = _objc_msgSend(self,sel_class);
      pvVar3 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar3);
      pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_OK,&cfstr_empty,
                             &cfstr_RegistrationFormLocalized);
      puVar1 = cls_NSBundle;
      pvVar4 = _objc_msgSend(self,sel_class);
      pvVar4 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar4);
      pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,
                             &cfstr_Required_information_incomplete,&cfstr_empty,
                             &cfstr_RegistrationFormLocalized);
      pvVar2 = _objc_msgSend(self_00,
                             sel_alertWithMessageText_defaultButton_alternateButton_otherButton_informativeTextWithFormat_
                             ,pvVar4,pvVar3,0,0,pvVar2);
      pvVar3 = _objc_msgSend(self,sel_window);
      op = sel_beginSheetModalForWindow_modalDelegate_didEndSelector_contextInfo_;
    }
  }
  else {
    pvVar2 = *(id *)PTR_00336058;
    pvVar3 = (id)0x0;
    op = sel_stopModalWithCode_;
  }
  _objc_msgSend(pvVar2,op,pvVar3);
  return;
}

*/
- (void)defaultButtonClick:(id)aClick
{
    int reason = 0;
    if ([self HSRegistrationFormController_isRequiredFieldsFilled:&reason]) {
        [NSApp stopModalWithCode:0];
        return;
    }
    NSString *messageKey;
    NSString *informativeKey;
    if (reason == 2) {
        messageKey = @"Email address not complete";
        informativeKey = @"Email address not complete...";
    }
    else if (reason == 1) {
        messageKey = @"Required information incomplete";
        informativeKey = @"Required information incomplete...";
    }
    else {
        return;
    }
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *informativeText = [bundle localizedStringForKey:informativeKey value:@"" table:@"RegistrationFormLocalized"];
    NSString *okTitle = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"OK" value:@"" table:@"RegistrationFormLocalized"];
    NSString *messageText = [[NSBundle bundleForClass:[self class]] localizedStringForKey:messageKey value:@"" table:@"RegistrationFormLocalized"];
    NSAlert *alert = [NSAlert alertWithMessageText:messageText defaultButton:okTitle alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", informativeText];
    [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(alertSheetDidEnd:returnCode:contextInfo:) contextInfo:alert];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0023a8f8 @ 0023a8f8, 947 bytes * /

BOOL FUN_0023a8f8(HSRegistrationFormController *self,SEL _cmd,
                 int *HSRegistrationFormController_isRequiredFieldsFilled)

{
  id pvVar1;
  int iVar2;
  HSFormControls *pHVar3;
  id pvVar4;
  id pvVar5;
  id self_00;
  BOOL BVar6;
  int extraout_EDX;
  id *ppvVar7;
  cfstringStruct *pcVar8;
  undefined4 uVar9;
  id local_28;
  id local_24;
  id local_20;
  id local_1c;
  id local_18;
  id local_14;
  
  pHVar3 = self->_formControls;
  if (pHVar3->f5 == (id)0x0) {
LAB_0023a93f:
    pvVar1 = _objc_msgSend(pHVar3->f6,sel_isEnabled);
    if ((char)pvVar1 != '\0') {
      pvVar1 = _objc_msgSend(self->_formControls->f6,sel_indexOfSelectedItem);
      if ((int)pvVar1 < 1) goto LAB_0023a92d;
    }
    pHVar3 = self->_formControls;
    local_14 = pHVar3->f2;
    local_1c = pHVar3->f0;
    local_18 = pHVar3->f1;
    ppvVar7 = &local_1c;
    uVar9 = 3;
    pvVar1 = _objc_msgSend(self,sel_HSRegistrationFormController_areTextFieldsValid_count_,ppvVar7,3
                          );
    if ((char)pvVar1 != '\0') {
      if (self->_type - 2U < 3) {
LAB_0023aa3a:
        pvVar1 = _objc_msgSend(self->_formControls->f2,sel_stringValue,ppvVar7,uVar9);
        pvVar4 = _objc_msgSend(pvVar1,sel_canBeConvertedToEncoding_,1);
        if ((char)pvVar4 != '\0') {
          pvVar4 = _objc_msgSend(pvVar1,sel_rangeOfString_,&cfstr__,uVar9);
          if ((pvVar4 != (id)0x0) && (extraout_EDX == 1)) {
            pcVar8 = &cfstr__;
            uVar9 = 4;
            pvVar5 = _objc_msgSend(pvVar1,sel_rangeOfString_options_,&cfstr__,4);
            if (pvVar5 == pvVar4) {
              pvVar5 = _objc_msgSend(pvVar1,sel_length,pcVar8,uVar9);
              if ((id)((int)pvVar5 + -1) != pvVar4) {
                pvVar5 = _objc_msgSend(pvVar1,sel_substringToIndex_,pvVar4,uVar9);
                pvVar1 = _objc_msgSend(pvVar1,sel_substringFromIndex_,(int)pvVar4 + 1);
                pvVar4 = _objc_msgSend(cls_NSMutableCharacterSet,sel_alphanumericCharacterSet);
                _objc_msgSend(pvVar4,sel_addCharactersInString_,&cfstr__________________);
                self_00 = _objc_msgSend(cls_NSMutableCharacterSet,sel_alphanumericCharacterSet);
                pcVar8 = &cfstr___;
                _objc_msgSend(self_00,sel_addCharactersInString_,&cfstr___);
                if ((pvVar5 != (id)0x0) && (pvVar1 != (id)0x0)) {
                  pvVar4 = _objc_msgSend(pvVar4,sel_invertedSet,pcVar8);
                  pvVar5 = _objc_msgSend(pvVar5,sel_rangeOfCharacterFromSet_,pvVar4);
                  if (pvVar5 == (id)0x7fffffff) {
                    pvVar4 = _objc_msgSend(self_00,sel_invertedSet,pvVar4);
                    pvVar4 = _objc_msgSend(pvVar1,sel_rangeOfCharacterFromSet_,pvVar4);
                    if (pvVar4 == (id)0x7fffffff) {
                      pvVar4 = _objc_msgSend(pvVar1,sel_hasSuffix_,&cfstr__);
                      if ((char)pvVar4 == '\0') {
                        pvVar4 = _objc_msgSend(pvVar1,sel_hasPrefix_,&cfstr__);
                        if ((char)pvVar4 == '\0') {
                          pvVar4 = _objc_msgSend(pvVar1,sel_rangeOfString_,&cfstr___);
                          if (pvVar4 == (id)0x7fffffff) {
                            pvVar1 = _objc_msgSend(pvVar1,sel_rangeOfString_,&cfstr__);
                            if (pvVar1 != (id)0x7fffffff) {
                              iVar2 = 0;
                              BVar6 = '\x01';
                              goto LAB_0023ac95;
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
        iVar2 = 2;
        BVar6 = '\0';
        goto LAB_0023ac95;
      }
      local_24 = self->_trialSchoolDistrictField;
      local_28 = self->_trialSchoolTitleField;
      local_20 = self->_trialSchoolNameField;
      pvVar1 = _objc_msgSend(self->_trialMacsTypePopUp,sel_indexOfSelectedItem,ppvVar7,uVar9);
      if (0 < (int)pvVar1) {
        pvVar1 = _objc_msgSend(self->_trialMySchoolDistrictPopUp,sel_indexOfSelectedItem,ppvVar7,
                               uVar9);
        if (0 < (int)pvVar1) {
          ppvVar7 = &local_28;
          uVar9 = 3;
          pvVar1 = _objc_msgSend(self,sel_HSRegistrationFormController_areTextFieldsValid_count_,
                                 ppvVar7,3);
          if ((char)pvVar1 != '\0') goto LAB_0023aa3a;
        }
      }
    }
  }
  else {
    pvVar1 = _objc_msgSend(pHVar3->f5,sel_indexOfSelectedItem);
    if (0 < (int)pvVar1) {
      pHVar3 = self->_formControls;
      goto LAB_0023a93f;
    }
  }
LAB_0023a92d:
  iVar2 = 1;
  BVar6 = '\0';
LAB_0023ac95:
  if (HSRegistrationFormController_isRequiredFieldsFilled != (int *)0x0) {
    *HSRegistrationFormController_isRequiredFieldsFilled = iVar2;
  }
  return BVar6;
}

*/
- (BOOL)HSRegistrationFormController_isRequiredFieldsFilled:(int *)aFilled
{
    NSInteger reason = 1;
    BOOL filled = NO;
    BOOL generalFieldsFilled = NO;
    if (_formControls->f5 == nil || [_formControls->f5 indexOfSelectedItem] > 0) {
        if (![_formControls->f6 isEnabled] || [_formControls->f6 indexOfSelectedItem] >= 1) {
            id fields[3] = { _formControls->f0, _formControls->f1, _formControls->f2 };
            if ([self HSRegistrationFormController_areTextFieldsValid:fields count:3]) {
                generalFieldsFilled = YES;
                if (!(_type - 2U < 3)) {
                    id schoolFields[3] = { _trialSchoolTitleField, _trialSchoolDistrictField, _trialSchoolNameField };
                    generalFieldsFilled = NO;
                    if ([_trialMacsTypePopUp indexOfSelectedItem] > 0 && [_trialMySchoolDistrictPopUp indexOfSelectedItem] > 0) {
                        generalFieldsFilled = [self HSRegistrationFormController_areTextFieldsValid:schoolFields count:3];
                    }
                }
            }
        }
    }
    if (generalFieldsFilled) {
        reason = 2;
        NSString *email = [_formControls->f2 stringValue];
        if ([email canBeConvertedToEncoding:NSASCIIStringEncoding]) {
            NSRange at = [email rangeOfString:@"@"];
            if (at.location != 0 && at.length == 1) {
                NSRange lastAt = [email rangeOfString:@"@" options:NSBackwardsSearch];
                if (lastAt.location == at.location && at.location != [email length] - 1) {
                    NSString *local = [email substringToIndex:at.location];
                    NSString *domain = [email substringFromIndex:at.location + 1];
                    // The original sent addCharactersInString: straight to +[NSMutableCharacterSet alphanumericCharacterSet].
                    NSMutableCharacterSet *localAllowed = [[[NSCharacterSet alphanumericCharacterSet] mutableCopy] autorelease];
                    [localAllowed addCharactersInString:@"!#$%'*+-./=?^_`~&"];
                    NSMutableCharacterSet *domainAllowed = [[[NSCharacterSet alphanumericCharacterSet] mutableCopy] autorelease];
                    [domainAllowed addCharactersInString:@".-"];
                    if (local != nil && domain != nil &&
                        [local rangeOfCharacterFromSet:[localAllowed invertedSet]].location == NSNotFound &&
                        [domain rangeOfCharacterFromSet:[domainAllowed invertedSet]].location == NSNotFound &&
                        ![domain hasSuffix:@"."] && ![domain hasPrefix:@"."] &&
                        [domain rangeOfString:@".."].location == NSNotFound &&
                        [domain rangeOfString:@"."].location != NSNotFound) {
                        reason = 0;
                        filled = YES;
                    }
                }
            }
        }
    }
    if (aFilled != NULL) {
        *aFilled = (int)reason;
    }
    return filled;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0023a86c @ 0023a86c, 140 bytes * /

BOOL FUN_0023a86c(HSRegistrationFormController *self,SEL _cmd,
                 id *HSRegistrationFormController_areTextFieldsValid,uint count)

{
  id pvVar1;
  id self_00;
  
  while( true ) {
    if (count == 0) {
      return '\x01';
    }
    _objc_msgSend(HSRegistrationFormController_areTextFieldsValid[count - 1],sel_validateEditing);
    pvVar1 = _objc_msgSend(HSRegistrationFormController_areTextFieldsValid[count - 1],
                           sel_stringValue);
    self_00 = _objc_msgSend(self,sel_HSRegistrationFormController_normalizedString_,pvVar1);
    if ((self_00 == (id)0x0) ||
       (pvVar1 = _objc_msgSend(self_00,sel_length,pvVar1), pvVar1 == (id)0x0)) break;
    count = count - 1;
  }
  return '\0';
}

*/
- (BOOL)HSRegistrationFormController_areTextFieldsValid:(id *)aValid count:(NSUInteger)aCount
{
    while (aCount != 0) {
        [aValid[aCount - 1] validateEditing];
        NSString *string = [self HSRegistrationFormController_normalizedString:[aValid[aCount - 1] stringValue]];
        if (string == nil || [string length] == 0) {
            return NO;
        }
        aCount--;
    }
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0023a7b9 @ 0023a7b9, 179 bytes * /

int FUN_0023a7b9(HSRegistrationFormController *self,SEL _cmd,
                id HSRegistrationFormController_typeFromRegistrationFormControllerType)

{
  id pvVar1;
  int iVar2;
  
  pvVar1 = _objc_msgSend(HSRegistrationFormController_typeFromRegistrationFormControllerType,
                         sel_isEqualToString_,&cfstr_HSRegistrationFormControllerTypeCommon);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(HSRegistrationFormController_typeFromRegistrationFormControllerType,
                           sel_isEqualToString_,
                           &cfstr_HSRegistrationFormControllerTypeCommonWithForced);
    if ((char)pvVar1 == '\0') {
      pvVar1 = _objc_msgSend(HSRegistrationFormController_typeFromRegistrationFormControllerType,
                             sel_isEqualToString_,&cfstr_HSRegistrationFormControllerTypeTrial);
      if ((char)pvVar1 == '\0') {
        pvVar1 = _objc_msgSend(HSRegistrationFormController_typeFromRegistrationFormControllerType,
                               sel_isEqualToString_,
                               &cfstr_HSRegistrationFormControllerTypeTrialReduced);
        iVar2 = (uint)((char)pvVar1 != '\0') * 2;
      }
      else {
        iVar2 = 1;
      }
    }
    else {
      iVar2 = 4;
    }
  }
  else {
    iVar2 = 3;
  }
  return iVar2;
}

*/
- (NSInteger)HSRegistrationFormController_typeFromRegistrationFormControllerType:(id)aType
{
    if ([aType isEqualToString:HSRegistrationFormControllerTypeCommon]) {
        return 3;
    }
    if ([aType isEqualToString:HSRegistrationFormControllerTypeCommonWithForcedResponse]) {
        return 4;
    }
    if ([aType isEqualToString:HSRegistrationFormControllerTypeTrial]) {
        return 1;
    }
    return [aType isEqualToString:HSRegistrationFormControllerTypeTrialReduced] ? 2 : 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0023a66e @ 0023a66e, 331 bytes * /

int FUN_0023a66e(HSRegistrationFormController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  byte bVar3;
  undefined4 uVar4;
  cfstringStruct *pcVar5;
  
  pvVar2 = *(id *)PTR_00336058;
  pvVar1 = _objc_msgSend(self,sel_window);
  pvVar2 = _objc_msgSend(pvVar2,sel_runModalForWindow_,pvVar1);
  pvVar1 = _objc_msgSend(self,sel_window);
  uVar4 = 0;
  _objc_msgSend(pvVar1,sel_orderOut_,0);
  bVar3 = (byte)pvVar2;
  if (bVar3 < 2) {
    _objc_msgSend(self,sel_HSRegistrationFormController_createPanelOptions,uVar4);
  }
  if (bVar3 == 2) {
    pvVar2 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults,uVar4);
    pcVar5 = &cfstr_HSRegistrationDefaultsValDontRegister;
  }
  else if (bVar3 == 1) {
    pvVar2 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults,uVar4);
    pcVar5 = &cfstr_HSRegistrationDefaultsValRegisterLater;
  }
  else {
    if (bVar3 != 0) goto LAB_0023a7ae;
    pvVar2 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults,uVar4);
    pcVar5 = &cfstr_HSRegistrationDefaultsValRegistered;
  }
  _objc_msgSend(pvVar2,sel_setObject_forKey_,pcVar5,
                &cfstr_HSRegistrationDefaultsKeyRegistrationChoice);
LAB_0023a7ae:
  return (int)(char)bVar3;
}

*/
- (NSInteger)runModal
{
    NSInteger result = [NSApp runModalForWindow:[self window]];
    [[self window] orderOut:nil];
    unsigned char choice = (unsigned char)result;
    if (choice < 2) {
        [self HSRegistrationFormController_createPanelOptions];
    }
    NSString *value = nil;
    if (choice == 2) {
        value = @"HSRegistrationDefaultsValDontRegister";
    }
    else if (choice == 1) {
        value = @"HSRegistrationDefaultsValRegisterLater";
    }
    else if (choice == 0) {
        value = @"HSRegistrationDefaultsValRegistered";
    }
    if (value != nil) {
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:@"HSRegistrationDefaultsKeyRegistrationChoice"];
    }
    return (char)choice;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00239f1b @ 00239f1b, 1875 bytes * /

void FUN_00239f1b(HSRegistrationFormController *self,SEL _cmd)

{
  HSFormControls *pHVar1;
  int iVar2;
  undefined *puVar3;
  id pvVar4;
  id self_00;
  id pvVar5;
  cfstringStruct *pcVar6;
  cfstringStruct *pcVar7;
  int iVar8;
  id pvVar9;
  cfstringStruct *pcVar10;
  cfstringStruct *local_b4;
  id local_a4;
  cfstringStruct *local_a0;
  id local_9c;
  cfstringStruct *local_98;
  id local_94;
  cfstringStruct *local_90;
  id local_8c;
  cfstringStruct *local_88;
  id local_84;
  cfstringStruct *local_80;
  id local_7c;
  cfstringStruct *local_78;
  id local_74;
  cfstringStruct *local_70;
  id local_6c;
  cfstringStruct *local_68;
  id local_64;
  cfstringStruct *local_60;
  id local_5c;
  cfstringStruct *local_58;
  id local_54;
  cfstringStruct *local_50;
  id local_4c;
  cfstringStruct *local_48;
  id local_44;
  cfstringStruct *local_40;
  id local_3c;
  cfstringStruct *local_38;
  id local_34;
  cfstringStruct *local_30;
  id local_2c;
  cfstringStruct *local_28;
  id local_24;
  cfstringStruct *local_20;
  id local_1c;
  cfstringStruct *local_18;
  
  pvVar4 = _objc_msgSend(cls_NSMutableDictionary,sel_alloc);
  pvVar9 = (id)0x0;
  pvVar4 = _objc_msgSend(pvVar4,sel_initWithCapacity_,0);
  self_00 = _objc_msgSend(pvVar4,sel_autorelease);
  pHVar1 = self->_formControls;
  local_1c = pHVar1->f4;
  local_24 = pHVar1->f3;
  local_2c = pHVar1->f2;
  pvVar4 = pHVar1->f0;
  local_34 = pHVar1->f1;
  local_38 = &cfstr_HSRegistrationFormOptionsKeyFirstName;
  local_30 = &cfstr_HSRegistrationFormOptionsKeyLastName;
  local_28 = &cfstr_HSRegistrationFormOptionsKeyEmail;
  local_20 = &cfstr_HSRegistrationFormOptionsKeyCity;
  local_18 = &cfstr_HSRegistrationFormOptionsKeySchoolName;
  iVar8 = 0;
  local_3c = pvVar4;
  while( true ) {
    pvVar9 = _objc_msgSend(pvVar4,sel_stringValue,pvVar9);
    pvVar4 = _objc_msgSend(self,sel_HSRegistrationFormController_normalizedString_);
    pvVar5 = _objc_msgSend(pvVar4,sel_length);
    if (pvVar5 != (id)0x0) {
      _objc_msgSend(self_00,sel_setObject_forKey_,pvVar4,(&local_38)[iVar8 * 2]);
      pvVar9 = pvVar4;
    }
    if (iVar8 == 4) break;
    pvVar4 = (&local_34)[iVar8 * 2];
    iVar8 = iVar8 + 1;
  }
  pvVar4 = self->_formControls->f5;
  local_44 = self->_formControls->f6;
  local_48 = &cfstr_HSRegistrationFormOptionsKeyCountry;
  local_40 = &cfstr_HSRegistrationFormOptionsKeyStateProv;
  iVar8 = 0;
  local_4c = pvVar4;
  while( true ) {
    pvVar5 = _objc_msgSend(pvVar4,sel_indexOfSelectedItem,pvVar9);
    if (0 < (int)pvVar5) {
      pcVar10 = (&local_48)[iVar8 * 2];
      pvVar4 = _objc_msgSend(pvVar4,sel_selectedItem,pvVar9);
      pvVar9 = _objc_msgSend(pvVar4,sel_title);
      _objc_msgSend(self_00,sel_setObject_forKey_,pvVar9,pcVar10);
    }
    puVar3 = cls_NSString;
    if (iVar8 == 1) break;
    pvVar4 = (&local_44)[iVar8 * 2];
    iVar8 = iVar8 + 1;
  }
  pvVar4 = _objc_msgSend(self->_formControls->f8,sel_intValue,pvVar9);
  pcVar6 = _objc_msgSend(puVar3,sel_stringWithFormat_,&cfstr__u,pvVar4);
  pcVar10 = &cfstr_HSRegistrationFormOptionsKeyReceiveHSMail;
  _objc_msgSend(self_00,sel_setObject_forKey_,pcVar6,
                &cfstr_HSRegistrationFormOptionsKeyReceiveHSMail);
  if (self->_type == 2) {
    local_9c = self->_trialReducedENewsEmailsCheckBox;
    pvVar4 = self->_trialReducedSchoolPricesCheckBox;
    local_a4 = self->_trialReducedLessonPlanesCheckBox;
    local_a0 = &cfstr_HSRegistrationFormLessonPlanes;
    local_98 = &cfstr_HSRegistrationFormENewsEmails;
    iVar8 = 0;
    local_b4 = &cfstr_HSRegistrationFormSchoolPrices;
    while( true ) {
      puVar3 = cls_NSString;
      pvVar4 = _objc_msgSend(pvVar4,sel_intValue,pcVar6,pcVar10);
      pcVar6 = _objc_msgSend(puVar3,sel_stringWithFormat_,&cfstr__u,pvVar4);
      _objc_msgSend(self_00,sel_setObject_forKey_);
      if (iVar8 == 2) break;
      iVar2 = iVar8 * 2;
      pvVar4 = (&local_a4)[iVar8 * 2];
      iVar8 = iVar8 + 1;
      pcVar10 = local_b4;
      local_b4 = (&local_a0)[iVar2];
    }
  }
  else if (self->_type - 3U < 2) {
    pvVar4 = _objc_msgSend(self->_serialLocationPopUp,sel_indexOfSelectedItem,pcVar6,pcVar10);
    if (0 < (int)pvVar4) {
      pvVar4 = _objc_msgSend(self->_serialLocationPopUp,sel_selectedItem,pcVar6,pcVar10);
      pcVar6 = _objc_msgSend(pvVar4,sel_title);
      pcVar10 = &cfstr_HSRegistrationFormOptionsKeyUseLocation;
      _objc_msgSend(self_00,sel_setObject_forKey_,pcVar6,
                    &cfstr_HSRegistrationFormOptionsKeyUseLocation);
    }
    pvVar4 = _objc_msgSend(self->_serialLocationPopUp,sel_selectedItem,pcVar6,pcVar10);
    pvVar4 = _objc_msgSend(pvVar4,sel_tag);
    if (pvVar4 != (id)0x1) {
      pcVar6 = &cfstr_HSRegistrationFormOptionsKeySchoolName;
      _objc_msgSend(self_00,sel_removeObjectForKey_,&cfstr_HSRegistrationFormOptionsKeySchoolName,
                    pcVar10);
    }
    puVar3 = cls_NSString;
    pvVar4 = _objc_msgSend(self->_serialCompanyNewsCheckBox,sel_intValue,pcVar6);
    pvVar4 = _objc_msgSend(puVar3,sel_stringWithFormat_,&cfstr__u,pvVar4);
    _objc_msgSend(self_00,sel_setObject_forKey_,pvVar4,
                  &cfstr_HSRegistrationFormOptionsKeyReceiveAllMail);
    puVar3 = cls_NSString;
    pvVar4 = _objc_msgSend(self->_serialEducationPricingCheckBox,sel_intValue);
    pcVar6 = _objc_msgSend(puVar3,sel_stringWithFormat_,&cfstr__u,pvVar4);
    local_b4 = &cfstr_HSRegistrationFormOptionsKeyReceiveSchoolMail;
    _objc_msgSend(self_00,sel_setObject_forKey_,pcVar6,
                  &cfstr_HSRegistrationFormOptionsKeyReceiveSchoolMail);
  }
  else {
    local_54 = self->_trialSchoolDistrictField;
    local_5c = self->_trialSchoolTitleField;
    pvVar4 = self->_trialAddressField;
    local_64 = self->_trialZipField;
    local_68 = &cfstr_HSRegistrationFormAddress;
    local_60 = &cfstr_HSRegistrationFormZip;
    local_58 = &cfstr_HSRegistrationFormSchoolTitle;
    local_50 = &cfstr_HSRegistrationFormSchoolDistrict;
    iVar8 = 1;
    local_6c = pvVar4;
    while( true ) {
      pcVar6 = _objc_msgSend(pvVar4,sel_stringValue,pcVar6,pcVar10);
      pcVar7 = _objc_msgSend(self,sel_HSRegistrationFormController_normalizedString_);
      pvVar4 = _objc_msgSend(pcVar7,sel_length);
      if (pvVar4 != (id)0x0) {
        pcVar10 = (&local_70)[iVar8 * 2];
        _objc_msgSend(self_00,sel_setObject_forKey_,pcVar7,pcVar10);
        pcVar6 = pcVar7;
      }
      if (iVar8 == 4) break;
      pvVar4 = (&local_6c)[iVar8 * 2];
      iVar8 = iVar8 + 1;
    }
    pvVar4 = self->_trialMySchoolDistrictPopUp;
    local_74 = self->_trialMacsTypePopUp;
    local_78 = &cfstr_HSRegistrationFormMySchoolDistrict;
    local_70 = &cfstr_HSRegistrationFormMacsType;
    iVar8 = 0;
    local_7c = pvVar4;
    while( true ) {
      pvVar9 = _objc_msgSend(pvVar4,sel_indexOfSelectedItem,pcVar6,pcVar10);
      pcVar7 = pcVar10;
      if (0 < (int)pvVar9) {
        pcVar7 = (&local_78)[iVar8 * 2];
        pvVar4 = _objc_msgSend(pvVar4,sel_selectedItem,pcVar6,pcVar10);
        pcVar6 = _objc_msgSend(pvVar4,sel_title);
        _objc_msgSend(self_00,sel_setObject_forKey_);
      }
      if (iVar8 == 1) break;
      pvVar4 = (&local_74)[iVar8 * 2];
      iVar8 = iVar8 + 1;
      pcVar10 = pcVar7;
    }
    local_84 = self->_trialENewsEmailsCheckBox;
    pvVar4 = self->_trialSchoolPricesCheckBox;
    local_8c = self->_trialLessonPlanesCheckBox;
    local_90 = &cfstr_HSRegistrationFormSchoolPrices;
    local_88 = &cfstr_HSRegistrationFormLessonPlanes;
    local_80 = &cfstr_HSRegistrationFormENewsEmails;
    iVar8 = 0;
    local_b4 = local_90;
    local_94 = pvVar4;
    while( true ) {
      puVar3 = cls_NSString;
      pvVar4 = _objc_msgSend(pvVar4,sel_intValue,pcVar6,pcVar7);
      pcVar6 = _objc_msgSend(puVar3,sel_stringWithFormat_,&cfstr__u,pvVar4);
      _objc_msgSend(self_00,sel_setObject_forKey_);
      if (iVar8 == 2) break;
      iVar2 = iVar8 * 2;
      pvVar4 = (&local_8c)[iVar8 * 2];
      iVar8 = iVar8 + 1;
      pcVar7 = local_b4;
      local_b4 = (&local_88)[iVar2];
    }
  }
  pvVar4 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults,pcVar6,local_b4);
  _objc_msgSend(pvVar4,sel_setObject_forKey_,self_00,
                &cfstr_HSRegistrationDefaultsKeyStoredPanelOptions);
  pvVar4 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  _objc_msgSend(pvVar4,sel_synchronize);
  return;
}

*/
- (void)HSRegistrationFormController_createPanelOptions
{
    NSMutableDictionary *options = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
    id textFields[5] = { _formControls->f0, _formControls->f1, _formControls->f2, _formControls->f3, _formControls->f4 };
    NSString *textKeys[5] = { @"HSRegistrationFormOptionsKeyFirstName", @"HSRegistrationFormOptionsKeyLastName", @"HSRegistrationFormOptionsKeyEmail", @"HSRegistrationFormOptionsKeyCity", @"HSRegistrationFormOptionsKeySchoolName" };
    for (int i = 0; i < 5; i++) {
        NSString *value = [self HSRegistrationFormController_normalizedString:[textFields[i] stringValue]];
        if ([value length] != 0) {
            [options setObject:value forKey:textKeys[i]];
        }
    }
    id popUps[2] = { _formControls->f5, _formControls->f6 };
    NSString *popUpKeys[2] = { @"HSRegistrationFormOptionsKeyCountry", @"HSRegistrationFormOptionsKeyStateProv" };
    for (int i = 0; i < 2; i++) {
        if ([popUps[i] indexOfSelectedItem] > 0) {
            [options setObject:[[popUps[i] selectedItem] title] forKey:popUpKeys[i]];
        }
    }
    [options setObject:[NSString stringWithFormat:@"%u", (unsigned int)[_formControls->f8 intValue]] forKey:@"HSRegistrationFormOptionsKeyReceiveHSMail"];
    NSString *checkBoxKeys[3] = { @"HSRegistrationFormSchoolPrices", @"HSRegistrationFormLessonPlanes", @"HSRegistrationFormENewsEmails" };
    if (_type == 2) {
        id checkBoxes[3] = { _trialReducedSchoolPricesCheckBox, _trialReducedLessonPlanesCheckBox, _trialReducedENewsEmailsCheckBox };
        for (int i = 0; i < 3; i++) {
            [options setObject:[NSString stringWithFormat:@"%u", (unsigned int)[checkBoxes[i] intValue]] forKey:checkBoxKeys[i]];
        }
    }
    else if (_type - 3U < 2) {
        if ([_serialLocationPopUp indexOfSelectedItem] > 0) {
            [options setObject:[[_serialLocationPopUp selectedItem] title] forKey:@"HSRegistrationFormOptionsKeyUseLocation"];
        }
        if ([[_serialLocationPopUp selectedItem] tag] != 1) {
            [options removeObjectForKey:@"HSRegistrationFormOptionsKeySchoolName"];
        }
        [options setObject:[NSString stringWithFormat:@"%u", (unsigned int)[_serialCompanyNewsCheckBox intValue]] forKey:@"HSRegistrationFormOptionsKeyReceiveAllMail"];
        [options setObject:[NSString stringWithFormat:@"%u", (unsigned int)[_serialEducationPricingCheckBox intValue]] forKey:@"HSRegistrationFormOptionsKeyReceiveSchoolMail"];
    }
    else {
        id trialFields[4] = { _trialAddressField, _trialZipField, _trialSchoolTitleField, _trialSchoolDistrictField };
        NSString *trialKeys[4] = { @"HSRegistrationFormAddress", @"HSRegistrationFormZip", @"HSRegistrationFormSchoolTitle", @"HSRegistrationFormSchoolDistrict" };
        for (int i = 0; i < 4; i++) {
            NSString *value = [self HSRegistrationFormController_normalizedString:[trialFields[i] stringValue]];
            if ([value length] != 0) {
                [options setObject:value forKey:trialKeys[i]];
            }
        }
        id trialPopUps[2] = { _trialMySchoolDistrictPopUp, _trialMacsTypePopUp };
        NSString *trialPopUpKeys[2] = { @"HSRegistrationFormMySchoolDistrict", @"HSRegistrationFormMacsType" };
        for (int i = 0; i < 2; i++) {
            if ([trialPopUps[i] indexOfSelectedItem] > 0) {
                [options setObject:[[trialPopUps[i] selectedItem] title] forKey:trialPopUpKeys[i]];
            }
        }
        id checkBoxes[3] = { _trialSchoolPricesCheckBox, _trialLessonPlanesCheckBox, _trialENewsEmailsCheckBox };
        for (int i = 0; i < 3; i++) {
            [options setObject:[NSString stringWithFormat:@"%u", (unsigned int)[checkBoxes[i] intValue]] forKey:checkBoxKeys[i]];
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:options forKey:@"HSRegistrationDefaultsKeyStoredPanelOptions"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00239e0e @ 00239e0e, 269 bytes * /

id FUN_00239e0e(HSRegistrationFormController *self,SEL _cmd,
               id HSRegistrationFormController_normalizedString)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  undefined4 uVar5;
  
  pvVar1 = _objc_msgSend(cls_NSCharacterSet,sel_whitespaceAndNewlineCharacterSet);
  while (pvVar2 = _objc_msgSend(HSRegistrationFormController_normalizedString,sel_length),
        pvVar2 != (id)0x0) {
    uVar5 = 2;
    pvVar2 = _objc_msgSend(HSRegistrationFormController_normalizedString,
                           sel_rangeOfCharacterFromSet_options_,pvVar1,2);
    if (pvVar2 != (id)0x0) break;
    HSRegistrationFormController_normalizedString =
         _objc_msgSend(HSRegistrationFormController_normalizedString,sel_substringFromIndex_,1,uVar5
                      );
  }
  while( true ) {
    pvVar2 = _objc_msgSend(HSRegistrationFormController_normalizedString,sel_length);
    if (pvVar2 == (id)0x0) {
      return HSRegistrationFormController_normalizedString;
    }
    uVar5 = 4;
    pvVar2 = pvVar1;
    pvVar3 = _objc_msgSend(HSRegistrationFormController_normalizedString,
                           sel_rangeOfCharacterFromSet_options_,pvVar1,4);
    pvVar4 = _objc_msgSend(HSRegistrationFormController_normalizedString,sel_length);
    if (pvVar3 != (id)((int)pvVar4 + -1)) break;
    pvVar2 = _objc_msgSend(HSRegistrationFormController_normalizedString,sel_length,pvVar2,uVar5);
    HSRegistrationFormController_normalizedString =
         _objc_msgSend(HSRegistrationFormController_normalizedString,sel_substringToIndex_,
                       (int)pvVar2 + -1);
  }
  return HSRegistrationFormController_normalizedString;
}

*/
- (id)HSRegistrationFormController_normalizedString:(id)aString
{
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    while ([aString length] != 0) {
        if ([aString rangeOfCharacterFromSet:whitespace options:NSAnchoredSearch].location != 0) {
            break;
        }
        aString = [aString substringFromIndex:1];
    }
    while ([aString length] != 0) {
        if ([aString rangeOfCharacterFromSet:whitespace options:NSBackwardsSearch].location != [aString length] - 1) {
            break;
        }
        aString = [aString substringToIndex:[aString length] - 1];
    }
    return aString;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0023bd9e @ 0023bd9e, 1242 bytes * /

void FUN_0023bd9e(HSRegistrationFormController *self,SEL _cmd)

{
  HSFormControls *pHVar1;
  undefined4 uVar2;
  undefined *puVar3;
  id pvVar4;
  id pvVar5;
  int iVar6;
  id self_00;
  id pvVar7;
  id pvVar8;
  id *ppvVar9;
  int *piVar10;
  cfstringStruct *pcVar11;
  undefined4 uVar12;
  int local_6c [2];
  id local_64;
  undefined4 local_60;
  id local_5c;
  undefined4 local_58;
  undefined4 local_54;
  undefined4 local_50;
  id local_4c;
  undefined4 local_48;
  id local_44 [5];
  undefined4 local_30;
  id local_2c;
  undefined4 local_28;
  undefined4 local_24;
  undefined4 local_20;
  HSRegistrationFormController *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_NSWindowController_003556d0;
  _objc_msgSendSuper(&local_1c,sel_windowDidLoad);
  iVar6 = self->_type;
  pvVar4 = _objc_msgSend(self,sel_window);
  _objc_msgSend(self,sel_HSRegistrationFormController_setupWindow_forType_,pvVar4,iVar6);
  pcVar11 = &cfstr_Countries;
  pvVar4 = _objc_msgSend(self->_countriesMap,sel_objectForKey_,&cfstr_Countries);
  if (pvVar4 != (id)0x0) {
    pvVar5 = _objc_msgSend(cls_NSArray,sel_class,pcVar11,iVar6);
    pvVar5 = _objc_msgSend(pvVar4,sel_isKindOfClass_,pvVar5);
    if ((char)pvVar5 != '\0') {
      pvVar5 = self->_formControls->f5;
      pvVar4 = _objc_msgSend(self,sel_HSRegistrationFormController_menuWithTitles_,pvVar4,iVar6);
      _objc_msgSend(pvVar5,sel_setMenu_,pvVar4);
    }
  }
  _objc_msgSend(self->_formControls->f5,sel_selectItemAtIndex_,0,iVar6);
  pHVar1 = self->_formControls;
  local_2c = pHVar1->f4;
  local_44[4] = pHVar1->f3;
  local_44[2] = pHVar1->f2;
  pvVar4 = pHVar1->f0;
  local_44[0] = pHVar1->f1;
  local_48 = 0x40;
  local_44[1] = (id)0x40;
  local_44[3] = (id)0x40;
  local_30 = 0x40;
  local_28 = 0xff;
  local_24 = 0;
  local_20 = 0;
  local_4c = pvVar4;
  if (pvVar4 != (id)0x0) {
    pvVar5 = (id)0x40;
    ppvVar9 = local_44 + 1;
    while( true ) {
      pvVar5 = _objc_msgSend(cls_HSLimitedLengthStringFormatter,sel_formatterWithLengthLimit_,pvVar5
                            );
      _objc_msgSend(pvVar4,sel_setFormatter_,pvVar5);
      pvVar4 = ppvVar9[-1];
      if (pvVar4 == (id)0x0) break;
      pvVar5 = *ppvVar9;
      ppvVar9 = ppvVar9 + 2;
    }
  }
  if (self->_type == 1) {
    local_5c = self->_trialSchoolDistrictField;
    local_64 = self->_trialSchoolTitleField;
    pvVar4 = self->_trialAddressField;
    local_6c[1] = 0x40;
    local_60 = 0xff;
    local_58 = 0xff;
    local_54 = 0;
    local_50 = 0;
    if (pvVar4 != (id)0x0) {
      iVar6 = 0xff;
      piVar10 = local_6c + 1;
      while( true ) {
        pvVar5 = _objc_msgSend(cls_HSLimitedLengthStringFormatter,sel_formatterWithLengthLimit_,
                               iVar6);
        _objc_msgSend(pvVar4,sel_setFormatter_,pvVar5);
        pvVar4 = (id)piVar10[-1];
        if (pvVar4 == (id)0x0) break;
        iVar6 = *piVar10;
        piVar10 = piVar10 + 2;
      }
    }
  }
  pcVar11 = &cfstr_Helvetica_Oblique;
  uVar12 = 0x41300000;
  pvVar4 = _objc_msgSend(cls_NSFont,sel_fontWithName_size_,&cfstr_Helvetica_Oblique,0x41300000);
  if (pvVar4 == (id)0x0) {
    pcVar11 = (cfstringStruct *)0x41300000;
    pvVar4 = _objc_msgSend(cls_NSFont,sel_systemFontOfSize_,0x41300000,uVar12);
  }
  pvVar5 = self->_formControls->f9;
  self_00 = _objc_msgSend(cls_NSAttributedString,sel_alloc,pcVar11,uVar12);
  puVar3 = cls_NSDictionary;
  uVar12 = *(undefined4 *)PTR_003363e4;
  pvVar7 = _objc_msgSend(cls_NSNumber,sel_numberWithInt_,1);
  uVar2 = *(undefined4 *)PTR_00336394;
  pvVar8 = _objc_msgSend(cls_NSColor,sel_blueColor);
  pvVar4 = _objc_msgSend(puVar3,sel_dictionaryWithObjectsAndKeys_,pvVar4,*(undefined4 *)PTR_00336068
                         ,pvVar8,uVar2,pvVar7,uVar12,0);
  puVar3 = cls_NSBundle;
  pvVar7 = _objc_msgSend(self,sel_class);
  pvVar7 = _objc_msgSend(puVar3,sel_bundleForClass_,pvVar7);
  pvVar7 = _objc_msgSend(pvVar7,sel_localizedStringForKey_value_table_,&cfstr_HSPrivacyStatement,
                         &cfstr_empty,&cfstr_RegistrationFormLocalized);
  pvVar4 = _objc_msgSend(self_00,sel_initWithString_attributes_,pvVar7,pvVar4);
  pvVar4 = _objc_msgSend(pvVar4,sel_autorelease);
  _objc_msgSend(pvVar5,sel_setAttributedTitle_,pvVar4);
  pvVar5 = _objc_msgSend(self,sel_class);
  pvVar5 = _objc_msgSend(pvVar5,sel_defaultsPanelOptionsDictionary);
  if (pvVar5 == (id)0x0) {
    pvVar5 = _objc_msgSend(self,sel_HSRegistrationFormController_defaultsPanelOptionsFromAddressBook
                           ,pvVar4);
  }
  if (pvVar5 != (id)0x0) {
    _objc_msgSend(self,sel_HSRegistrationFormController_loadPanelOptionsDictionary_,pvVar5);
  }
  return;
}

*/
- (void)windowDidLoad
{
    [super windowDidLoad];
    [self HSRegistrationFormController_setupWindow:[self window] forType:_type];
    id countries = [_countriesMap objectForKey:@"Countries"];
    if (countries != nil && [countries isKindOfClass:[NSArray class]]) {
        [_formControls->f5 setMenu:[self HSRegistrationFormController_menuWithTitles:countries]];
    }
    [_formControls->f5 selectItemAtIndex:0];
    // Each text field paired with its length limit, nil-terminated in the original.
    id limitedFields[5] = { _formControls->f0, _formControls->f1, _formControls->f2, _formControls->f3, _formControls->f4 };
    NSUInteger limits[5] = { 0x40, 0x40, 0x40, 0x40, 0xff };
    for (int i = 0; i < 5 && limitedFields[i] != nil; i++) {
        [limitedFields[i] setFormatter:[HSLimitedLengthStringFormatter formatterWithLengthLimit:limits[i]]];
    }
    if (_type == 1) {
        id trialFields[3] = { _trialAddressField, _trialSchoolTitleField, _trialSchoolDistrictField };
        NSUInteger trialLimits[3] = { 0x40, 0xff, 0xff };
        for (int i = 0; i < 3 && trialFields[i] != nil; i++) {
            [trialFields[i] setFormatter:[HSLimitedLengthStringFormatter formatterWithLengthLimit:trialLimits[i]]];
        }
    }
    NSFont *font = [NSFont fontWithName:@"Helvetica-Oblique" size:11.0f];
    if (font == nil) {
        font = [NSFont systemFontOfSize:11.0f];
    }
    id privacyButton = _formControls->f9;
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [NSColor blueColor], NSForegroundColorAttributeName, [NSNumber numberWithInt:1], NSUnderlineStyleAttributeName, nil];
    NSString *title = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"HSPrivacyStatement" value:@"" table:@"RegistrationFormLocalized"];
    [privacyButton setAttributedTitle:[[[NSAttributedString alloc] initWithString:title attributes:attributes] autorelease]];
    id options = [[self class] defaultsPanelOptionsDictionary];
    if (options == nil) {
        options = [self HSRegistrationFormController_defaultsPanelOptionsFromAddressBook];
    }
    if (options != nil) {
        [self HSRegistrationFormController_loadPanelOptionsDictionary:options];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00239596 @ 00239596, 2168 bytes * /

void FUN_00239596(HSRegistrationFormController *self,SEL _cmd,
                 id HSRegistrationFormController_loadPanelOptionsDictionary)

{
  id pvVar1;
  cfstringStruct *pcVar2;
  cfstringStruct *pcVar3;
  
  pvVar1 = _objc_msgSend(HSRegistrationFormController_loadPanelOptionsDictionary,sel_objectForKey_,
                         &cfstr_HSRegistrationFormOptionsKeyFirstName);
  if (pvVar1 != (id)0x0) {
    _objc_msgSend(self->_formControls->f0,sel_setStringValue_,pvVar1);
  }
  pvVar1 = _objc_msgSend(HSRegistrationFormController_loadPanelOptionsDictionary,sel_objectForKey_,
                         &cfstr_HSRegistrationFormOptionsKeyLastName);
  if (pvVar1 != (id)0x0) {
    _objc_msgSend(self->_formControls->f1,sel_setStringValue_,pvVar1);
  }
  pvVar1 = _objc_msgSend(HSRegistrationFormController_loadPanelOptionsDictionary,sel_objectForKey_,
                         &cfstr_HSRegistrationFormOptionsKeyEmail);
  if (pvVar1 != (id)0x0) {
    _objc_msgSend(self->_formControls->f2,sel_setStringValue_,pvVar1);
  }
  pvVar1 = _objc_msgSend(HSRegistrationFormController_loadPanelOptionsDictionary,sel_objectForKey_,
                         &cfstr_HSRegistrationFormOptionsKeyCity);
  if (pvVar1 != (id)0x0) {
    _objc_msgSend(self->_formControls->f3,sel_setStringValue_,pvVar1);
  }
  pcVar3 = &cfstr_HSRegistrationFormOptionsKeyCountry;
  pcVar2 = _objc_msgSend(HSRegistrationFormController_loadPanelOptionsDictionary,sel_objectForKey_,
                         &cfstr_HSRegistrationFormOptionsKeyCountry);
  if (pcVar2 != (cfstringStruct *)0x0) {
    _objc_msgSend(self->_formControls->f5,sel_selectItemWithTitle_,pcVar2);
    pcVar3 = pcVar2;
  }
  pvVar1 = _objc_msgSend(self->_formControls->f5,sel_selectedItem,pcVar3);
  if (pvVar1 == (id)0x0) {
    _objc_msgSend(self->_formControls->f5,sel_selectItemAtIndex_,0);
  }
  pcVar3 = (cfstringStruct *)0x0;
  _objc_msgSend(self,sel_changeCountry_,0);
  pvVar1 = _objc_msgSend(self->_formControls->f6,sel_isEnabled);
  if ((char)pvVar1 != '\0') {
    pcVar3 = &cfstr_HSRegistrationFormOptionsKeyStateProv;
    pcVar2 = _objc_msgSend(HSRegistrationFormController_loadPanelOptionsDictionary,sel_objectForKey_
                           ,&cfstr_HSRegistrationFormOptionsKeyStateProv);
    if (pcVar2 != (cfstringStruct *)0x0) {
      _objc_msgSend(self->_formControls->f6,sel_selectItemWithTitle_,pcVar2);
      pcVar3 = pcVar2;
    }
  }
  pvVar1 = _objc_msgSend(self->_formControls->f6,sel_selectedItem,pcVar3);
  if (pvVar1 == (id)0x0) {
    _objc_msgSend(self->_formControls->f6,sel_selectItemAtIndex_,0);
  }
  if (self->_type == 2) {
    pvVar1 = _objc_msgSend(HSRegistrationFormController_loadPanelOptionsDictionary,sel_objectForKey_
                           ,&cfstr_HSRegistrationFormSchoolPrices);
    pvVar1 = _objc_msgSend(pvVar1,sel_intValue);
    if (0 < (int)pvVar1) {
      _objc_msgSend(self->_trialReducedSchoolPricesCheckBox,sel_setIntValue_,1);
    }
    pvVar1 = _objc_msgSend(HSRegistrationFormController_loadPanelOptionsDictionary,sel_objectForKey_
                           ,&cfstr_HSRegistrationFormLessonPlanes);
    pvVar1 = _objc_msgSend(pvVar1,sel_intValue);
    if (0 < (int)pvVar1) {
      _objc_msgSend(self->_trialReducedLessonPlanesCheckBox,sel_setIntValue_,1);
    }
    pvVar1 = _objc_msgSend(HSRegistrationFormController_loadPanelOptionsDictionary,sel_objectForKey_
                           ,&cfstr_HSRegistrationFormENewsEmails);
    pvVar1 = _objc_msgSend(pvVar1,sel_intValue);
    if ((int)pvVar1 < 1) {
      return;
    }
    pvVar1 = self->_trialReducedENewsEmailsCheckBox;
  }
  else if (self->_type - 3U < 2) {
    pcVar3 = &cfstr_HSRegistrationFormOptionsKeyUseLocation;
    pcVar2 = _objc_msgSend(HSRegistrationFormController_loadPanelOptionsDictionary,sel_objectForKey_
                           ,&cfstr_HSRegistrationFormOptionsKeyUseLocation);
    if (pcVar2 != (cfstringStruct *)0x0) {
      _objc_msgSend(self->_serialLocationPopUp,sel_selectItemWithTitle_,pcVar2);
      pcVar3 = pcVar2;
    }
    pvVar1 = _objc_msgSend(self->_serialLocationPopUp,sel_selectedItem,pcVar3);
    if (pvVar1 == (id)0x0) {
      _objc_msgSend(self->_serialLocationPopUp,sel_selectItemAtIndex_,0);
    }
    _objc_msgSend(self,sel_changeUseLocation_,0);
    pvVar1 = _objc_msgSend(self->_formControls->f4,sel_isEnabled);
    if (((char)pvVar1 != '\0') &&
       (pvVar1 = _objc_msgSend(HSRegistrationFormController_loadPanelOptionsDictionary,
                               sel_objectForKey_,&cfstr_HSRegistrationFormOptionsKeySchoolName),
       pvVar1 != (id)0x0)) {
      _objc_msgSend(self->_formControls->f4,sel_setStringValue_,pvVar1);
    }
    pvVar1 = _objc_msgSend(HSRegistrationFormController_loadPanelOptionsDictionary,sel_objectForKey_
                           ,&cfstr_HSRegistrationFormOptionsKeyReceiveHSMail);
    pvVar1 = _objc_msgSend(pvVar1,sel_intValue);
    if (0 < (int)pvVar1) {
      _objc_msgSend(self->_formControls->f8,sel_setIntValue_,1);
    }
    pvVar1 = _objc_msgSend(HSRegistrationFormController_loadPanelOptionsDictionary,sel_objectForKey_
                           ,&cfstr_HSRegistrationFormOptionsKeyReceiveAllMail);
    pvVar1 = _objc_msgSend(pvVar1,sel_intValue);
    if (0 < (int)pvVar1) {
      _objc_msgSend(self->_serialCompanyNewsCheckBox,sel_setIntValue_,1);
    }
    pvVar1 = _objc_msgSend(HSRegistrationFormController_loadPanelOptionsDictionary,sel_objectForKey_
                           ,&cfstr_HSRegistrationFormOptionsKeyReceiveSchoolMail);
    pvVar1 = _objc_msgSend(pvVar1,sel_intValue);
    if ((int)pvVar1 < 1) {
      return;
    }
    pvVar1 = self->_serialEducationPricingCheckBox;
  }
  else {
    pvVar1 = _objc_msgSend(HSRegistrationFormController_loadPanelOptionsDictionary,sel_objectForKey_
                           ,&cfstr_HSRegistrationFormOptionsKeySchoolName);
    if (pvVar1 != (id)0x0) {
      _objc_msgSend(self->_formControls->f4,sel_setStringValue_,pvVar1);
    }
    pvVar1 = _objc_msgSend(HSRegistrationFormController_loadPanelOptionsDictionary,sel_objectForKey_
                           ,&cfstr_HSRegistrationFormAddress);
    if (pvVar1 != (id)0x0) {
      _objc_msgSend(self->_trialAddressField,sel_setStringValue_,pvVar1);
    }
    pvVar1 = _objc_msgSend(HSRegistrationFormController_loadPanelOptionsDictionary,sel_objectForKey_
                           ,&cfstr_HSRegistrationFormZip);
    if (pvVar1 != (id)0x0) {
      _objc_msgSend(self->_trialZipField,sel_setStringValue_,pvVar1);
    }
    pvVar1 = _objc_msgSend(HSRegistrationFormController_loadPanelOptionsDictionary,sel_objectForKey_
                           ,&cfstr_HSRegistrationFormSchoolTitle);
    if (pvVar1 != (id)0x0) {
      _objc_msgSend(self->_trialSchoolTitleField,sel_setStringValue_,pvVar1);
    }
    pvVar1 = _objc_msgSend(HSRegistrationFormController_loadPanelOptionsDictionary,sel_objectForKey_
                           ,&cfstr_HSRegistrationFormSchoolDistrict);
    if (pvVar1 != (id)0x0) {
      _objc_msgSend(self->_trialSchoolDistrictField,sel_setStringValue_,pvVar1);
    }
    pcVar3 = &cfstr_HSRegistrationFormMySchoolDistrict;
    pcVar2 = _objc_msgSend(HSRegistrationFormController_loadPanelOptionsDictionary,sel_objectForKey_
                           ,&cfstr_HSRegistrationFormMySchoolDistrict);
    if (pcVar2 != (cfstringStruct *)0x0) {
      _objc_msgSend(self->_trialMySchoolDistrictPopUp,sel_selectItemWithTitle_,pcVar2);
      pcVar3 = pcVar2;
    }
    pvVar1 = _objc_msgSend(self->_trialMySchoolDistrictPopUp,sel_selectedItem,pcVar3);
    if (pvVar1 == (id)0x0) {
      _objc_msgSend(self->_trialMySchoolDistrictPopUp,sel_selectItemAtIndex_,0);
    }
    pcVar3 = &cfstr_HSRegistrationFormMacsType;
    pcVar2 = _objc_msgSend(HSRegistrationFormController_loadPanelOptionsDictionary,sel_objectForKey_
                           ,&cfstr_HSRegistrationFormMacsType);
    if (pcVar2 != (cfstringStruct *)0x0) {
      _objc_msgSend(self->_trialMacsTypePopUp,sel_selectItemWithTitle_,pcVar2);
      pcVar3 = pcVar2;
    }
    pvVar1 = _objc_msgSend(self->_trialMacsTypePopUp,sel_selectedItem,pcVar3);
    if (pvVar1 == (id)0x0) {
      _objc_msgSend(self->_trialMacsTypePopUp,sel_selectItemAtIndex_,0);
    }
    pvVar1 = _objc_msgSend(HSRegistrationFormController_loadPanelOptionsDictionary,sel_objectForKey_
                           ,&cfstr_HSRegistrationFormSchoolPrices);
    pvVar1 = _objc_msgSend(pvVar1,sel_intValue);
    if (0 < (int)pvVar1) {
      _objc_msgSend(self->_trialSchoolPricesCheckBox,sel_setIntValue_,1);
    }
    pvVar1 = _objc_msgSend(HSRegistrationFormController_loadPanelOptionsDictionary,sel_objectForKey_
                           ,&cfstr_HSRegistrationFormLessonPlanes);
    pvVar1 = _objc_msgSend(pvVar1,sel_intValue);
    if (0 < (int)pvVar1) {
      _objc_msgSend(self->_trialLessonPlanesCheckBox,sel_setIntValue_,1);
    }
    pvVar1 = _objc_msgSend(HSRegistrationFormController_loadPanelOptionsDictionary,sel_objectForKey_
                           ,&cfstr_HSRegistrationFormENewsEmails);
    pvVar1 = _objc_msgSend(pvVar1,sel_intValue);
    if ((int)pvVar1 < 1) {
      return;
    }
    pvVar1 = self->_trialENewsEmailsCheckBox;
  }
  _objc_msgSend(pvVar1,sel_setIntValue_,1);
  return;
}

*/
- (void)HSRegistrationFormController_loadPanelOptionsDictionary:(id)aDictionary
{
    id value = [aDictionary objectForKey:@"HSRegistrationFormOptionsKeyFirstName"];
    if (value != nil) {
        [_formControls->f0 setStringValue:value];
    }
    value = [aDictionary objectForKey:@"HSRegistrationFormOptionsKeyLastName"];
    if (value != nil) {
        [_formControls->f1 setStringValue:value];
    }
    value = [aDictionary objectForKey:@"HSRegistrationFormOptionsKeyEmail"];
    if (value != nil) {
        [_formControls->f2 setStringValue:value];
    }
    value = [aDictionary objectForKey:@"HSRegistrationFormOptionsKeyCity"];
    if (value != nil) {
        [_formControls->f3 setStringValue:value];
    }
    NSString *title = [aDictionary objectForKey:@"HSRegistrationFormOptionsKeyCountry"];
    if (title != nil) {
        [_formControls->f5 selectItemWithTitle:title];
    }
    if ([_formControls->f5 selectedItem] == nil) {
        [_formControls->f5 selectItemAtIndex:0];
    }
    [self changeCountry:nil];
    if ([_formControls->f6 isEnabled]) {
        title = [aDictionary objectForKey:@"HSRegistrationFormOptionsKeyStateProv"];
        if (title != nil) {
            [_formControls->f6 selectItemWithTitle:title];
        }
    }
    if ([_formControls->f6 selectedItem] == nil) {
        [_formControls->f6 selectItemAtIndex:0];
    }
    NSButton *lastCheckBox;
    if (_type == 2) {
        if ([[aDictionary objectForKey:@"HSRegistrationFormSchoolPrices"] intValue] > 0) {
            [_trialReducedSchoolPricesCheckBox setIntValue:1];
        }
        if ([[aDictionary objectForKey:@"HSRegistrationFormLessonPlanes"] intValue] > 0) {
            [_trialReducedLessonPlanesCheckBox setIntValue:1];
        }
        if ([[aDictionary objectForKey:@"HSRegistrationFormENewsEmails"] intValue] < 1) {
            return;
        }
        lastCheckBox = _trialReducedENewsEmailsCheckBox;
    }
    else if (_type - 3U < 2) {
        title = [aDictionary objectForKey:@"HSRegistrationFormOptionsKeyUseLocation"];
        if (title != nil) {
            [_serialLocationPopUp selectItemWithTitle:title];
        }
        if ([_serialLocationPopUp selectedItem] == nil) {
            [_serialLocationPopUp selectItemAtIndex:0];
        }
        [self changeUseLocation:nil];
        if ([_formControls->f4 isEnabled]) {
            value = [aDictionary objectForKey:@"HSRegistrationFormOptionsKeySchoolName"];
            if (value != nil) {
                [_formControls->f4 setStringValue:value];
            }
        }
        if ([[aDictionary objectForKey:@"HSRegistrationFormOptionsKeyReceiveHSMail"] intValue] > 0) {
            [_formControls->f8 setIntValue:1];
        }
        if ([[aDictionary objectForKey:@"HSRegistrationFormOptionsKeyReceiveAllMail"] intValue] > 0) {
            [_serialCompanyNewsCheckBox setIntValue:1];
        }
        if ([[aDictionary objectForKey:@"HSRegistrationFormOptionsKeyReceiveSchoolMail"] intValue] < 1) {
            return;
        }
        lastCheckBox = _serialEducationPricingCheckBox;
    }
    else {
        value = [aDictionary objectForKey:@"HSRegistrationFormOptionsKeySchoolName"];
        if (value != nil) {
            [_formControls->f4 setStringValue:value];
        }
        value = [aDictionary objectForKey:@"HSRegistrationFormAddress"];
        if (value != nil) {
            [_trialAddressField setStringValue:value];
        }
        value = [aDictionary objectForKey:@"HSRegistrationFormZip"];
        if (value != nil) {
            [_trialZipField setStringValue:value];
        }
        value = [aDictionary objectForKey:@"HSRegistrationFormSchoolTitle"];
        if (value != nil) {
            [_trialSchoolTitleField setStringValue:value];
        }
        value = [aDictionary objectForKey:@"HSRegistrationFormSchoolDistrict"];
        if (value != nil) {
            [_trialSchoolDistrictField setStringValue:value];
        }
        title = [aDictionary objectForKey:@"HSRegistrationFormMySchoolDistrict"];
        if (title != nil) {
            [_trialMySchoolDistrictPopUp selectItemWithTitle:title];
        }
        if ([_trialMySchoolDistrictPopUp selectedItem] == nil) {
            [_trialMySchoolDistrictPopUp selectItemAtIndex:0];
        }
        title = [aDictionary objectForKey:@"HSRegistrationFormMacsType"];
        if (title != nil) {
            [_trialMacsTypePopUp selectItemWithTitle:title];
        }
        if ([_trialMacsTypePopUp selectedItem] == nil) {
            [_trialMacsTypePopUp selectItemAtIndex:0];
        }
        if ([[aDictionary objectForKey:@"HSRegistrationFormSchoolPrices"] intValue] > 0) {
            [_trialSchoolPricesCheckBox setIntValue:1];
        }
        if ([[aDictionary objectForKey:@"HSRegistrationFormLessonPlanes"] intValue] > 0) {
            [_trialLessonPlanesCheckBox setIntValue:1];
        }
        if ([[aDictionary objectForKey:@"HSRegistrationFormENewsEmails"] intValue] < 1) {
            return;
        }
        lastCheckBox = _trialENewsEmailsCheckBox;
    }
    [lastCheckBox setIntValue:1];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00239224 @ 00239224, 882 bytes * /

id FUN_00239224(HSRegistrationFormController *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  cfstringStruct *pcVar4;
  int iVar5;
  undefined4 uVar6;
  id local_48 [2];
  cfstringStruct *local_40;
  id local_3c;
  cfstringStruct *local_38;
  undefined4 local_34;
  cfstringStruct *local_30;
  undefined4 local_2c;
  cfstringStruct *local_28;
  cfstringStruct *local_24;
  cfstringStruct *local_20 [4];
  
  pvVar1 = _objc_msgSend(cls_HSSystem,sel_sharedSystem);
  pvVar1 = _objc_msgSend(pvVar1,sel_isMountainLionOrGreater);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(cls_ABAddressBook,sel_sharedAddressBook);
    pvVar1 = _objc_msgSend(pvVar1,sel_me);
    if (pvVar1 != (id)0x0) {
      pcVar4 = *(cfstringStruct **)PTR_00336894;
      local_48[0] = _objc_msgSend(cls_NSMutableDictionary,sel_dictionary);
      local_20[0] = &cfstr_HSRegistrationFormOptionsKeyFirstName;
      local_20[1] = *(cfstringStruct **)PTR_00336898;
      local_20[2] = &cfstr_HSRegistrationFormOptionsKeyLastName;
      iVar5 = 0;
      local_24 = pcVar4;
      while( true ) {
        pvVar2 = _objc_msgSend(pvVar1,sel_valueForProperty_,pcVar4);
        if (pvVar2 != (id)0x0) {
          _objc_msgSend(local_48[0],sel_setObject_forKey_,pvVar2,local_20[iVar5 * 2]);
        }
        if (iVar5 == 1) break;
        pcVar4 = local_20[iVar5 * 2 + 1];
        iVar5 = iVar5 + 1;
      }
      pvVar2 = _objc_msgSend(pvVar1,sel_valueForProperty_,*(undefined4 *)PTR_00336890);
      pvVar3 = _objc_msgSend(pvVar2,sel_primaryIdentifier);
      pvVar3 = _objc_msgSend(pvVar2,sel_indexForIdentifier_,pvVar3);
      pvVar2 = _objc_msgSend(pvVar2,sel_valueAtIndex_,pvVar3);
      if (pvVar2 != (id)0x0) {
        _objc_msgSend(local_48[0],sel_setObject_forKey_,pvVar2,
                      &cfstr_HSRegistrationFormOptionsKeyEmail);
      }
      pvVar1 = _objc_msgSend(pvVar1,sel_valueForProperty_,*(undefined4 *)PTR_00336880);
      pvVar2 = _objc_msgSend(pvVar1,sel_primaryIdentifier);
      pvVar2 = _objc_msgSend(pvVar1,sel_indexForIdentifier_,pvVar2);
      pvVar1 = _objc_msgSend(pvVar1,sel_valueAtIndex_,pvVar2);
      uVar6 = *(undefined4 *)PTR_0033687c;
      pvVar2 = _objc_msgSend(pvVar1,sel_objectForKey_,uVar6);
      self_00 = cls_NSBundle;
      if (pvVar2 == (id)0x0) {
        pvVar2 = _objc_msgSend(self,sel_class,uVar6);
        pvVar2 = _objc_msgSend(self_00,sel_bundleForClass_,pvVar2);
        pvVar3 = _objc_msgSend(pvVar1,sel_objectForKey_,*(undefined4 *)PTR_00336878);
        pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,pvVar3,&cfstr_empty,
                               &cfstr_CountryCodes);
      }
      if (pvVar2 != (id)0x0) {
        _objc_msgSend(local_48[0],sel_setObject_forKey_,pvVar2,
                      &cfstr_HSRegistrationFormOptionsKeyCountry);
      }
      pvVar2 = *(id *)PTR_00336884;
      local_40 = &cfstr_HSRegistrationFormOptionsKeyStateProv;
      local_3c = *(id *)PTR_00336874;
      local_38 = &cfstr_HSRegistrationFormOptionsKeyCity;
      local_34 = *(undefined4 *)PTR_00336888;
      local_30 = &cfstr_HSRegistrationFormAddress;
      local_2c = *(undefined4 *)PTR_0033688c;
      local_28 = &cfstr_HSRegistrationFormZip;
      iVar5 = 1;
      local_48[1] = pvVar2;
      while( true ) {
        pvVar2 = _objc_msgSend(pvVar1,sel_objectForKey_,pvVar2);
        if (pvVar2 != (id)0x0) {
          _objc_msgSend(local_48[0],sel_setObject_forKey_,pvVar2,local_48[iVar5 * 2]);
        }
        if (iVar5 == 4) break;
        pvVar2 = local_48[iVar5 * 2 + 1];
        iVar5 = iVar5 + 1;
      }
      return local_48[0];
    }
  }
  return (id)0x0;
}

*/
- (id)HSRegistrationFormController_defaultsPanelOptionsFromAddressBook
{
    if ([[HSSystem sharedSystem] isMountainLionOrGreater]) {
        return nil;
    }
    ABPerson *me = [[ABAddressBook sharedAddressBook] me];
    if (me == nil) {
        return nil;
    }
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    id firstName = [me valueForProperty:kABFirstNameProperty];
    if (firstName != nil) {
        [options setObject:firstName forKey:@"HSRegistrationFormOptionsKeyFirstName"];
    }
    id lastName = [me valueForProperty:kABLastNameProperty];
    if (lastName != nil) {
        [options setObject:lastName forKey:@"HSRegistrationFormOptionsKeyLastName"];
    }
    ABMultiValue *emails = [me valueForProperty:kABEmailProperty];
    id email = [emails valueAtIndex:[emails indexForIdentifier:[emails primaryIdentifier]]];
    if (email != nil) {
        [options setObject:email forKey:@"HSRegistrationFormOptionsKeyEmail"];
    }
    ABMultiValue *addresses = [me valueForProperty:kABAddressProperty];
    NSDictionary *address = [addresses valueAtIndex:[addresses indexForIdentifier:[addresses primaryIdentifier]]];
    id country = [address objectForKey:kABAddressCountryKey];
    if (country == nil) {
        country = [[NSBundle bundleForClass:[self class]] localizedStringForKey:[address objectForKey:kABAddressCountryCodeKey] value:@"" table:@"CountryCodes"];
    }
    if (country != nil) {
        [options setObject:country forKey:@"HSRegistrationFormOptionsKeyCountry"];
    }
    id state = [address objectForKey:kABAddressStateKey];
    if (state != nil) {
        [options setObject:state forKey:@"HSRegistrationFormOptionsKeyStateProv"];
    }
    id city = [address objectForKey:kABAddressCityKey];
    if (city != nil) {
        [options setObject:city forKey:@"HSRegistrationFormOptionsKeyCity"];
    }
    id street = [address objectForKey:kABAddressStreetKey];
    if (street != nil) {
        [options setObject:street forKey:@"HSRegistrationFormAddress"];
    }
    id zip = [address objectForKey:kABAddressZIPKey];
    if (zip != nil) {
        [options setObject:zip forKey:@"HSRegistrationFormZip"];
    }
    return options;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002390da @ 002390da, 330 bytes * /

id FUN_002390da(HSRegistrationFormController *self,SEL _cmd,
               id HSRegistrationFormController_menuWithTitles)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  id pvVar3;
  id pvVar4;
  SEL op;
  cfstringStruct *pcVar5;
  
  pvVar1 = _objc_msgSend(cls_NSMenu,sel_new);
  pvVar2 = _objc_msgSend(HSRegistrationFormController_menuWithTitles,sel_count);
  if (pvVar2 != (id)0x0) {
    pvVar2 = (id)0x0;
    do {
      self_00 = _objc_msgSend(HSRegistrationFormController_menuWithTitles,sel_objectAtIndex_,pvVar2)
      ;
      pvVar3 = _objc_msgSend(cls_NSString,sel_class);
      pvVar4 = _objc_msgSend(self_00,sel_isKindOfClass_,pvVar3);
      if ((char)pvVar4 != '\0') {
        pcVar5 = &cfstr__;
        pvVar4 = _objc_msgSend(self_00,sel_isEqualToString_,&cfstr__);
        op = sel_addItemWithTitle_action_keyEquivalent_;
        pvVar3 = self_00;
        if ((char)pvVar4 != '\0') {
          pvVar3 = _objc_msgSend(cls_NSMenuItem,sel_separatorItem,pcVar5);
          op = sel_addItem_;
        }
        _objc_msgSend(pvVar1,op,pvVar3);
      }
      pvVar2 = (id)((int)pvVar2 + 1);
      pvVar3 = _objc_msgSend(HSRegistrationFormController_menuWithTitles,sel_count,pvVar3);
    } while (pvVar2 < pvVar3);
  }
  pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  return pvVar1;
}

*/
- (id)HSRegistrationFormController_menuWithTitles:(id)aTitles
{
    NSMenu *menu = [NSMenu new];
    for (NSUInteger i = 0; i < [aTitles count]; i++) {
        id title = [aTitles objectAtIndex:i];
        if ([title isKindOfClass:[NSString class]]) {
            if ([title isEqualToString:@"-"]) {
                [menu addItem:[NSMenuItem separatorItem]];
            }
            else {
                [menu addItemWithTitle:title action:NULL keyEquivalent:@""];
            }
        }
    }
    return [menu autorelease];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0023c278 @ 0023c278, 915 bytes * /

void FUN_0023c278(HSRegistrationFormController *self,SEL _cmd,
                 id HSRegistrationFormController_setupWindow,int forType)

{
  id *ppvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id local_4c;
  id local_48;
  undefined8 local_44;
  undefined4 local_3c;
  float fStack_38;
  undefined1 local_34 [12];
  float local_28;
  undefined1 local_24 [12];
  float local_18;
  
  if (forType == 2) {
    local_48 = self->_trialReducedOptionsView;
    local_4c = self->_trialButtonsView;
    self->_formControls->f0 = self->_trialReducedFirstNameField;
    self->_formControls->f1 = self->_trialReducedLastNameField;
    self->_formControls->f2 = self->_trialReducedEmailField;
    self->_formControls->f8 = self->_trialReducedFreeUpdatesCheckBox;
    pvVar2 = self->_trialReducedPrivacyStatementButton;
  }
  else {
    if (forType == 3) {
      ppvVar1 = &self->_serialButtonsView;
    }
    else {
      if (forType != 4) {
        local_48 = self->_trialOptionsView;
        local_4c = self->_trialButtonsView;
        self->_formControls->f0 = self->_trialFirstNameField;
        self->_formControls->f1 = self->_trialLastNameField;
        self->_formControls->f2 = self->_trialEmailField;
        self->_formControls->f3 = self->_trialCityField;
        self->_formControls->f4 = self->_trialSchoolNameField;
        self->_formControls->f5 = self->_trialCountryPopUp;
        self->_formControls->f6 = self->_trialStateProvPopUp;
        self->_formControls->f7 = self->_trialStatesStarField;
        self->_formControls->f8 = self->_trialFreeUpdatesCheckBox;
        pvVar2 = self->_trialPrivacyStatementButton;
        goto LAB_0023c41e;
      }
      ppvVar1 = &self->_trialButtonsView;
    }
    local_4c = *ppvVar1;
    local_48 = self->_serialOptionsView;
    self->_formControls->f0 = self->_serialFirstNameField;
    self->_formControls->f1 = self->_serialLastNameField;
    self->_formControls->f2 = self->_serialEmailField;
    self->_formControls->f3 = self->_serialCityField;
    self->_formControls->f4 = self->_serialSchoolNameField;
    self->_formControls->f5 = self->_serialCountryPopUp;
    self->_formControls->f6 = self->_serialStateProvPopUp;
    self->_formControls->f7 = self->_serialStatesStarField;
    self->_formControls->f8 = self->_serialFreeUpdatesCheckBox;
    pvVar2 = self->_serialPrivacyStatementButton;
  }
LAB_0023c41e:
  self->_formControls->f9 = pvVar2;
  pvVar2 = self->_buttonsView;
  pvVar3 = _objc_msgSend(pvVar2,sel_subviews);
  pvVar4 = _objc_msgSend(pvVar3,sel_count);
  if (pvVar4 == (id)0x0) {
LAB_0023c485:
    _objc_msgSend(pvVar2,sel_addSubview_);
  }
  else {
    pvVar3 = _objc_msgSend(pvVar3,sel_objectAtIndex_);
    if (pvVar3 != local_4c) {
      _objc_msgSend(pvVar3,sel_removeFromSuperviewWithoutNeedingDisplay);
      goto LAB_0023c485;
    }
  }
  _objc_msgSend_stret(local_34,self->_optionsView,sel_frame);
  _objc_msgSend_stret(local_24,local_48,sel_frame);
  _objc_msgSend(self->_optionsView,sel_setFrameSize_);
  pvVar2 = self->_optionsView;
  pvVar3 = _objc_msgSend(pvVar2,sel_subviews);
  pvVar4 = _objc_msgSend(pvVar3,sel_count);
  if (pvVar4 != (id)0x0) {
    pvVar3 = _objc_msgSend(pvVar3,sel_objectAtIndex_);
    if (pvVar3 == local_48) goto LAB_0023c5a5;
    _objc_msgSend(pvVar3,sel_removeFromSuperviewWithoutNeedingDisplay);
  }
  _objc_msgSend(pvVar2,sel_addSubview_);
LAB_0023c5a5:
  _objc_msgSend_stret(&local_44,HSRegistrationFormController_setupWindow,sel_frame);
  fStack_38 = (local_18 - local_28) + fStack_38;
  _objc_msgSend(HSRegistrationFormController_setupWindow,sel_setFrame_display_,local_44,
                CONCAT44(fStack_38,local_3c),0);
  return;
}

*/
- (void)HSRegistrationFormController_setupWindow:(id)aWindow forType:(NSInteger)aType
{
    NSView *newOptionsView;
    NSView *newButtonsView;
    id privacyButton;
    if (aType == 2) {
        newOptionsView = _trialReducedOptionsView;
        newButtonsView = _trialButtonsView;
        _formControls->f0 = _trialReducedFirstNameField;
        _formControls->f1 = _trialReducedLastNameField;
        _formControls->f2 = _trialReducedEmailField;
        _formControls->f8 = _trialReducedFreeUpdatesCheckBox;
        privacyButton = _trialReducedPrivacyStatementButton;
    }
    else if (aType == 3 || aType == 4) {
        newButtonsView = (aType == 3) ? _serialButtonsView : _trialButtonsView;
        newOptionsView = _serialOptionsView;
        _formControls->f0 = _serialFirstNameField;
        _formControls->f1 = _serialLastNameField;
        _formControls->f2 = _serialEmailField;
        _formControls->f3 = _serialCityField;
        _formControls->f4 = _serialSchoolNameField;
        _formControls->f5 = _serialCountryPopUp;
        _formControls->f6 = _serialStateProvPopUp;
        _formControls->f7 = _serialStatesStarField;
        _formControls->f8 = _serialFreeUpdatesCheckBox;
        privacyButton = _serialPrivacyStatementButton;
    }
    else {
        newOptionsView = _trialOptionsView;
        newButtonsView = _trialButtonsView;
        _formControls->f0 = _trialFirstNameField;
        _formControls->f1 = _trialLastNameField;
        _formControls->f2 = _trialEmailField;
        _formControls->f3 = _trialCityField;
        _formControls->f4 = _trialSchoolNameField;
        _formControls->f5 = _trialCountryPopUp;
        _formControls->f6 = _trialStateProvPopUp;
        _formControls->f7 = _trialStatesStarField;
        _formControls->f8 = _trialFreeUpdatesCheckBox;
        privacyButton = _trialPrivacyStatementButton;
    }
    _formControls->f9 = privacyButton;
    NSArray *buttonSubviews = [_buttonsView subviews];
    if ([buttonSubviews count] == 0) {
        [_buttonsView addSubview:newButtonsView];
    }
    else {
        NSView *current = [buttonSubviews objectAtIndex:[buttonSubviews count] - 1];
        if (current != newButtonsView) {
            [current removeFromSuperviewWithoutNeedingDisplay];
            [_buttonsView addSubview:newButtonsView];
        }
    }
    NSRect optionsFrame = [_optionsView frame];
    NSRect newOptionsFrame = [newOptionsView frame];
    float heightChange = newOptionsFrame.size.height - optionsFrame.size.height;
    [_optionsView setFrameSize:NSMakeSize(optionsFrame.size.width, optionsFrame.size.height + heightChange)];
    NSArray *optionSubviews = [_optionsView subviews];
    BOOL needsAdd = YES;
    if ([optionSubviews count] != 0) {
        NSView *current = [optionSubviews objectAtIndex:[optionSubviews count] - 1];
        if (current == newOptionsView) {
            needsAdd = NO;
        }
        else {
            [current removeFromSuperviewWithoutNeedingDisplay];
        }
    }
    if (needsAdd) {
        [_optionsView addSubview:newOptionsView];
    }
    NSRect windowFrame = [aWindow frame];
    windowFrame.size.height = heightChange + windowFrame.size.height;
    [aWindow setFrame:windowFrame display:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0023c60b @ 0023c60b, 399 bytes * /

id FUN_0023c60b(HSRegistrationFormController *self,SEL _cmd,id initWithType)

{
  undefined *self_00;
  HSRegistrationFormController *self_01;
  id pvVar1;
  cfstringStruct *pcVar2;
  HSFormControls *pHVar3;
  cfstringStruct *pcVar4;
  cfstringStruct *pcVar5;
  HSRegistrationFormController *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_NSWindowController_003556d0;
  pcVar2 = &cfstr_RegistrationForm;
  self_01 = _objc_msgSendSuper(&local_1c,sel_initWithWindowNibName_,&cfstr_RegistrationForm);
  if (self_01 != (HSRegistrationFormController *)0x0) {
    pvVar1 = _objc_msgSend(self_01,
                           sel_HSRegistrationFormController_typeFromRegistrationFormControllerType_,
                           initWithType);
    self_01->_type = (int)pvVar1;
    self_00 = cls_NSBundle;
    pvVar1 = _objc_msgSend(cls_HSRegistrationFormController,sel_class);
    pvVar1 = _objc_msgSend(self_00,sel_bundleForClass_,pvVar1);
    pcVar5 = &cfstr_plist;
    pcVar4 = &cfstr_Countries;
    pcVar2 = _objc_msgSend(pvVar1,sel_pathForResource_ofType_,&cfstr_Countries,&cfstr_plist);
    if (pcVar2 == (cfstringStruct *)0x0) {
      pvVar1 = self_01->_countriesMap;
      pcVar2 = pcVar4;
    }
    else {
      pvVar1 = _objc_msgSend(cls_NSDictionary,sel_alloc,pcVar4,pcVar5);
      pvVar1 = _objc_msgSend(pvVar1,sel_initWithContentsOfFile_,pcVar2);
      self_01->_countriesMap = pvVar1;
    }
    if (pvVar1 != (id)0x0) {
      pHVar3 = (HSFormControls *)_NSZoneMalloc(0,0x28);
      self_01->_formControls = pHVar3;
      if (pHVar3 != (HSFormControls *)0x0) {
        pHVar3->f1 = (id)0x0;
        pHVar3->f0 = (id)0x0;
        pHVar3->f3 = (id)0x0;
        pHVar3->f2 = (id)0x0;
        pHVar3->f5 = (id)0x0;
        pHVar3->f4 = (id)0x0;
        pHVar3->f7 = (id)0x0;
        pHVar3->f6 = (id)0x0;
        pHVar3->f9 = (id)0x0;
        pHVar3->f8 = (id)0x0;
        return self_01;
      }
    }
  }
  local_18 = PTR_s_NSWindowController_003556d0;
  local_1c = self_01;
  _objc_msgSendSuper(&local_1c,sel_release,pcVar2);
  return (id)0x0;
}

*/
- (id)initWithType:(id)aType
{
    self = [super initWithWindowNibName:@"RegistrationForm"];
    if (self != nil) {
        _type = (int)[self HSRegistrationFormController_typeFromRegistrationFormControllerType:aType];
        NSString *countriesPath = [[NSBundle bundleForClass:[HSRegistrationFormController class]] pathForResource:@"Countries" ofType:@"plist"];
        if (countriesPath != nil) {
            _countriesMap = [[NSDictionary alloc] initWithContentsOfFile:countriesPath];
        }
        if (_countriesMap != nil) {
            _formControls = NSZoneMalloc(NULL, sizeof(struct HSFormControls));
            if (_formControls != NULL) {
                _formControls->f0 = nil;
                _formControls->f1 = nil;
                _formControls->f2 = nil;
                _formControls->f3 = nil;
                _formControls->f4 = nil;
                _formControls->f5 = nil;
                _formControls->f6 = nil;
                _formControls->f7 = nil;
                _formControls->f8 = nil;
                _formControls->f9 = nil;
                return self;
            }
        }
    }
    [super release];
    return nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002390aa @ 002390aa, 48 bytes * /

id FUN_002390aa(HSRegistrationFormController *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_initWithType_,&cfstr_HSRegistrationFormControllerTypeCommon);
  return pvVar1;
}

*/
- (id)init
{
    return [self initWithType:HSRegistrationFormControllerTypeCommon];
}

- (void)dealloc
{
    [_countriesMap release];
    if (_formControls != nil) {
        NSZoneFree(0,_formControls);
    }
    [super dealloc];
}

@end

