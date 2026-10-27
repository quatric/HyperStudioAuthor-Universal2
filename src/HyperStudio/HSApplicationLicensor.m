#import "HSApplicationLicensor.h"

static HSLicenseInfoDialogController *sLicenseInfoDialogController; // DAT_00342a5c

static void HSApplicationLicensorRunAuthenticationAlert(id self)
{
    HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
    NSString *quit = [provider localizedStringForKey:@"Quit" value:@"" table:@"Alerts"];
    NSString *authenticate = [provider localizedStringForKey:@"Authenticate" value:@"" table:@"Alerts"];
    NSString *message = [provider localizedStringForKey:@"You should authenticate with your administrator password to activate HyperStudio" value:@"" table:@"Alerts"];
    NSString *title = [provider localizedStringForKey:@"Cannot launch HyperStudio" value:@"" table:@"Alerts"];
    if (NSRunAlertPanel(title, @"%@", authenticate, quit, nil, message) != NSAlertDefaultReturn) {
        [NSApp terminate:self];
    }
}

@implementation HSApplicationLicensor

/* i386 ivar offsets: _registrationInfo=0x4, _applicationBundle=0x8, _majorVersion=0xc, _minorVersion=0x10, _licenseStatus=0x14, _licenseType=0x18, _licenseUsageTimeInfo=0x1c, _applicationRegistrar=0x20, _trialSerial=0x24, _fisrtTrialExtensionSerial=0x28, _secondTrialExtensionSerial=0x2c, _hiddenTrialExtensionSerial=0x30 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_00287e65 @ 00287e65, 233 bytes * /

void FUN_00287e65(HSApplicationLicensor *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = DAT_00342a5c;
  if (DAT_00342a5c == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_HSLicenseInfoDialogController,sel_alloc);
    pvVar2 = _objc_msgSend(cls_LUUserDataValidation,sel_sharedInstance);
    pvVar2 = _objc_msgSend(pvVar2,sel_licenseDescription_,0);
    DAT_00342a5c = _objc_msgSend(pvVar1,sel_initWithInfo_,pvVar2);
  }
  else {
    pvVar2 = _objc_msgSend(cls_LUUserDataValidation,sel_sharedInstance);
    pvVar2 = _objc_msgSend(pvVar2,sel_licenseDescription_,0);
    _objc_msgSend(pvVar1,sel_setLicenseInfo_,pvVar2);
  }
  _objc_msgSend(DAT_00342a5c,sel_run,pvVar2);
  return;
}

*/
- (void)showLicenseInfoDialog
{
    if (sLicenseInfoDialogController == nil) {
        sLicenseInfoDialogController = [[HSLicenseInfoDialogController alloc] initWithInfo:[[LUUserDataValidation sharedInstance] licenseDescription:nil]];
    }
    else {
        [sLicenseInfoDialogController setLicenseInfo:[[LUUserDataValidation sharedInstance] licenseDescription:nil]];
    }
    [sLicenseInfoDialogController run];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00287e11 @ 00287e11, 84 bytes * /

id FUN_00287e11(HSApplicationLicensor *self,SEL _cmd,BOOL showRegistrationDialogForceUI,
               BOOL *isGoBack)

{
  id pvVar1;
  
  if (self->_registrationInfo == (id)0x0) {
    pvVar1 = (id)0x0;
  }
  else {
    pvVar1 = _objc_msgSend(self,
                           sel_HSApplicationLicensor_showRegistrationDialog_registrationString_forceUI_isGoBack_
                           ,*(undefined4 *)PTR_PTR_00336994,self->_registrationInfo,
                           (uint)(byte)showRegistrationDialogForceUI,isGoBack);
  }
  return pvVar1;
}

*/
- (id)showRegistrationDialogForceUI:(BOOL)aUI isGoBack:(BOOL *)aBack
{
    if (_registrationInfo == nil) {
        return nil;
    }
    return [self HSApplicationLicensor_showRegistrationDialog:HSRegistrationFormControllerTypeCommon registrationString:_registrationInfo forceUI:aUI isGoBack:aBack];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00289de1 @ 00289de1, 1046 bytes * /

void FUN_00289de1(HSApplicationLicensor *self,SEL _cmd,id createRequestWithURLString)

{
  undefined *puVar1;
  undefined *self_00;
  int iVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  undefined4 uVar7;
  undefined4 uVar8;
  undefined4 uVar9;
  
  iVar2 = _CFURLCreateStringByAddingPercentEscapes
                    (0,self->_registrationInfo,0,&cfstr_____,0x8000100);
  if (iVar2 != 0) {
    pvVar3 = _objc_msgSend(self->_applicationBundle,sel_pathForResource_ofType_,&cfstr_reg_template,
                           &cfstr_html);
    if (pvVar3 != (id)0x0) {
      uVar8 = 0;
      uVar7 = 4;
      pvVar4 = _objc_msgSend(cls_NSMutableString,sel_stringWithContentsOfFile_encoding_error_,pvVar3
                             ,4,0);
      puVar1 = cls_HSDocument;
      if (pvVar4 != (id)0x0) {
        pvVar3 = _objc_msgSend(cls_HSApplicationController,sel_buildVersionString,pvVar3,uVar7,uVar8
                              );
        uVar8 = 1;
        uVar7 = 1;
        pvVar5 = _objc_msgSend(puVar1,
                               sel_completeURLStringWithString_versionString_addPlatformInfo_addProductName_
                               ,createRequestWithURLString,pvVar3,1,1);
        if (pvVar5 != (id)0x0) {
          pvVar3 = _objc_msgSend(pvVar4,sel_length,createRequestWithURLString,pvVar3,uVar7,uVar8);
          pvVar6 = _objc_msgSend(&cfstr_window_name____,sel_stringByAppendingString_,iVar2);
          _objc_msgSend(pvVar4,sel_replaceOccurrencesOfString_withString_options_range_,
                        &cfstr_window_name____,pvVar6,0,0,pvVar3);
          pvVar3 = _objc_msgSend(pvVar4,sel_length);
          pvVar5 = _objc_msgSend(&cfstr_window_location_href____,sel_stringByAppendingString_,pvVar5
                                );
          _objc_msgSend(pvVar4,sel_replaceOccurrencesOfString_withString_options_range_,
                        &cfstr_window_location_href____,pvVar5,0,0,pvVar3);
          self_00 = cls_NSURL;
          pvVar3 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider);
          pvVar3 = _objc_msgSend(pvVar3,sel_temporaryFolder);
          puVar1 = cls_NSString;
          pvVar5 = _objc_msgSend(cls_HSUID,sel_UID);
          pvVar5 = _objc_msgSend(pvVar5,sel_stringValue);
          pvVar5 = _objc_msgSend(puVar1,sel_stringWithFormat_,&cfstr____html,pvVar5);
          pvVar3 = _objc_msgSend(pvVar3,sel_stringByAppendingPathComponent_,pvVar5);
          pvVar3 = _objc_msgSend(self_00,sel_fileURLWithPath_,pvVar3);
          if (pvVar3 != (id)0x0) {
            uVar9 = 0;
            uVar8 = 4;
            uVar7 = 1;
            pvVar5 = pvVar3;
            pvVar4 = _objc_msgSend(pvVar4,sel_writeToURL_atomically_encoding_error_,pvVar3,1,4,0);
            if ((char)pvVar4 != '\0') {
              pvVar4 = _objc_msgSend(cls_NSWorkspace,sel_sharedWorkspace,pvVar5,uVar7,uVar8,uVar9);
              pvVar4 = _objc_msgSend(pvVar4,sel_openURL_,pvVar3);
              if ((char)pvVar4 == '\0') {
                pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar3,
                                       uVar7,uVar8,uVar9);
                pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_OK,
                                       &cfstr_empty,&cfstr_Alerts);
                pvVar4 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
                pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,
                                       &cfstr_BrowserNotFound_message,&cfstr_empty,&cfstr_Alerts);
                pvVar5 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
                pvVar5 = _objc_msgSend(pvVar5,sel_localizedStringForKey_value_table_,
                                       &cfstr_BrowserNotFound_title,&cfstr_empty,&cfstr_Alerts);
                _NSRunAlertPanel(pvVar5,pvVar4,pvVar3,0,0);
              }
            }
          }
        }
      }
    }
    _CFRelease(iVar2);
  }
  return;
}

*/
- (void)createRequestWithURLString:(id)aString
{
    NSString *escapedInfo = [(NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)_registrationInfo, NULL, CFSTR("+?=&"), kCFStringEncodingUTF8) autorelease];
    if (escapedInfo == nil) {
        return;
    }
    NSString *templatePath = [_applicationBundle pathForResource:@"reg_template" ofType:@"html"];
    if (templatePath == nil) {
        return;
    }
    NSMutableString *page = [NSMutableString stringWithContentsOfFile:templatePath encoding:NSUTF8StringEncoding error:NULL];
    if (page == nil) {
        return;
    }
    NSString *urlString = [HSDocument completeURLStringWithString:aString versionString:[HSApplicationController buildVersionString] addPlatformInfo:YES addProductName:YES];
    if (urlString == nil) {
        return;
    }
    [page replaceOccurrencesOfString:@"window.name = \"" withString:[@"window.name = \"" stringByAppendingString:escapedInfo] options:0 range:NSMakeRange(0, [page length])];
    [page replaceOccurrencesOfString:@"window.location.href = \"" withString:[@"window.location.href = \"" stringByAppendingString:urlString] options:0 range:NSMakeRange(0, [page length])];
    NSString *path = [[[HSPathsProvider sharedPathsProvider] temporaryFolder] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.html", [[HSUID UID] stringValue]]];
    NSURL *url = [NSURL fileURLWithPath:path];
    if (url != nil && [page writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:NULL]) {
        if (![[NSWorkspace sharedWorkspace] openURL:url]) {
            HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
            NSRunAlertPanel([provider localizedStringForKey:@"BrowserNotFound_title" value:@"" table:@"Alerts"], @"%@", [provider localizedStringForKey:@"OK" value:@"" table:@"Alerts"], nil, nil, [provider localizedStringForKey:@"BrowserNotFound_message" value:@"" table:@"Alerts"]);
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002895b8 @ 002895b8, 890 bytes * /

int FUN_002895b8(HSApplicationLicensor *self,SEL _cmd,id validateSerialString,id controller)

{
  id pvVar1;
  id pvVar2;
  int iVar3;
  undefined4 *puVar4;
  undefined4 uVar5;
  undefined4 local_14;
  int local_10;
  
  local_10 = 0;
  pvVar1 = _objc_msgSend(self,sel_HSApplicationLicensor_trialSerial);
  if ((((pvVar1 == (id)0x0) ||
       (pvVar1 = _objc_msgSend(self,sel_HSApplicationLicensor_fisrtTrialExtensionSerial),
       pvVar1 == (id)0x0)) ||
      (pvVar1 = _objc_msgSend(self,sel_HSApplicationLicensor_secondTrialExtensionSerial),
      pvVar1 == (id)0x0)) ||
     (pvVar1 = _objc_msgSend(self,sel_HSApplicationLicensor_hiddenTrialExtensionSerial),
     pvVar1 == (id)0x0)) goto LAB_002895e6;
  pvVar1 = _objc_msgSend(validateSerialString,sel_UTF8String);
  iVar3 = FUN_002afb3b(pvVar1,&local_10);
  if (iVar3 == 0) {
    if (local_10 == 0) {
      iVar3 = 1;
      goto LAB_002897ae;
    }
    pvVar1 = _objc_msgSend(validateSerialString,sel_isEqualToString_,self->_trialSerial);
    if (((char)pvVar1 == '\0') &&
       (pvVar1 = _objc_msgSend(validateSerialString,sel_isEqualToString_,
                               self->_fisrtTrialExtensionSerial), (char)pvVar1 == '\0')) {
      pvVar1 = self->_secondTrialExtensionSerial;
      pvVar2 = _objc_msgSend(validateSerialString,sel_isEqualToString_,pvVar1);
      if ((char)pvVar2 == '\0') {
        if (((self->_licenseStatus != 6) || (self->_licenseType == 3)) ||
           ((self->_licenseUsageTimeInfo & 2) != 0)) {
          pvVar1 = self->_hiddenTrialExtensionSerial;
          pvVar2 = _objc_msgSend(validateSerialString,sel_isEqualToString_,pvVar1);
          if ((char)pvVar2 != '\0') goto LAB_002897e1;
        }
        local_14 = 0;
        pvVar1 = _objc_msgSend(cls_LUUserDataValidation,sel_sharedInstance,pvVar1);
        puVar4 = &local_14;
        uVar5 = 0;
        iVar3 = local_10;
        pvVar1 = _objc_msgSend(pvVar1,sel_validateLicenseUserData_usageTimeFlags_licenseType_,
                               local_10,puVar4,0);
        if (pvVar1 == (id)0x6) goto LAB_00289798;
        if (pvVar1 == (id)0x0) {
          pvVar1 = _objc_msgSend(cls_HSSerialValidationContext,sel_alloc,iVar3,puVar4,uVar5);
          iVar3 = local_10;
          uVar5 = local_14;
          pvVar1 = _objc_msgSend(pvVar1,sel_initWithSerialString_license_usageTimeFlags_,
                                 validateSerialString,local_10,local_14);
          if (pvVar1 != (id)0x0) {
            _objc_msgSend(controller,sel_setValidationContext_,pvVar1,iVar3,uVar5);
            _objc_msgSend(pvVar1,sel_release);
            return 0;
          }
        }
        goto LAB_002895e6;
      }
    }
LAB_002897e1:
    iVar3 = 3;
    goto LAB_002897ae;
  }
  if (iVar3 == 7) {
    pvVar1 = _objc_msgSend(validateSerialString,sel_isEqualToString_,self->_trialSerial);
    if ((((char)pvVar1 != '\0') ||
        (pvVar1 = _objc_msgSend(validateSerialString,sel_isEqualToString_,
                                self->_fisrtTrialExtensionSerial), (char)pvVar1 != '\0')) ||
       ((pvVar1 = _objc_msgSend(validateSerialString,sel_isEqualToString_,
                                self->_secondTrialExtensionSerial), (char)pvVar1 != '\0' ||
        (pvVar1 = _objc_msgSend(validateSerialString,sel_isEqualToString_,
                                self->_hiddenTrialExtensionSerial), (char)pvVar1 != '\0'))))
    goto LAB_00289798;
  }
  else if (iVar3 == 10) {
    if (((self->_licenseStatus != 6) &&
        (pvVar1 = _objc_msgSend(validateSerialString,sel_isEqualToString_,self->_trialSerial),
        (char)pvVar1 == '\0')) &&
       ((pvVar1 = _objc_msgSend(validateSerialString,sel_isEqualToString_,
                                self->_fisrtTrialExtensionSerial), (char)pvVar1 == '\0' &&
        ((pvVar1 = _objc_msgSend(validateSerialString,sel_isEqualToString_,
                                 self->_secondTrialExtensionSerial), (char)pvVar1 == '\0' &&
         (pvVar1 = _objc_msgSend(validateSerialString,sel_isEqualToString_,
                                 self->_hiddenTrialExtensionSerial), (char)pvVar1 == '\0')))))) {
      iVar3 = 0;
      goto LAB_002897ae;
    }
LAB_00289798:
    iVar3 = 2;
    goto LAB_002897ae;
  }
LAB_002895e6:
  iVar3 = 1;
LAB_002897ae:
  if (local_10 != 0) {
    FUN_002af216(local_10);
  }
  return iVar3;
}

*/
- (NSInteger)validateSerialString:(id)aString controller:(id)aController
{
    struct SLLicense *license = NULL;
    NSInteger result;
    if ([self HSApplicationLicensor_trialSerial] == nil || [self HSApplicationLicensor_fisrtTrialExtensionSerial] == nil || [self HSApplicationLicensor_secondTrialExtensionSerial] == nil || [self HSApplicationLicensor_hiddenTrialExtensionSerial] == nil) {
        return 1;
    }
    int status = SLLicenseCreateFromSerial([aString UTF8String], &license);
    if (status == 0) {
        if (license == NULL) {
            return 1;
        }
        if ([aString isEqualToString:_trialSerial] || [aString isEqualToString:_fisrtTrialExtensionSerial] || [aString isEqualToString:_secondTrialExtensionSerial]) {
            result = 3;
        }
        else if ((_licenseStatus != 6 || _licenseType == 3 || (_licenseUsageTimeInfo & 2) != 0) && [aString isEqualToString:_hiddenTrialExtensionSerial]) {
            result = 3;
        }
        else {
            int usageTimeFlags = 0;
            NSInteger validation = [[LUUserDataValidation sharedInstance] validateLicenseUserData:license usageTimeFlags:&usageTimeFlags licenseType:NULL];
            if (validation == 6) {
                result = 2;
            }
            else if (validation != 0) {
                result = 1;
            }
            else {
                HSSerialValidationContext *context = [[HSSerialValidationContext alloc] initWithSerialString:aString license:license usageTimeFlags:usageTimeFlags];
                if (context == nil) {
                    result = 1;
                }
                else {
                    [aController setValidationContext:context];
                    [context release];
                    return 0;
                }
            }
        }
    }
    else if (status == 7) {
        if ([aString isEqualToString:_trialSerial] || [aString isEqualToString:_fisrtTrialExtensionSerial] || [aString isEqualToString:_secondTrialExtensionSerial] || [aString isEqualToString:_hiddenTrialExtensionSerial]) {
            result = 2;
        }
        else {
            result = 1;
        }
    }
    else if (status == 10) {
        if (_licenseStatus == 6 || [aString isEqualToString:_trialSerial] || [aString isEqualToString:_fisrtTrialExtensionSerial] || [aString isEqualToString:_secondTrialExtensionSerial] || [aString isEqualToString:_hiddenTrialExtensionSerial]) {
            result = 2;
        }
        else {
            result = 0;
        }
    }
    else {
        result = 1;
    }
    if (license != NULL) {
        SLLicenseRelease(license);
    }
    return result;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00287bde @ 00287bde, 563 bytes * /

BOOL FUN_00287bde(HSApplicationLicensor *self,SEL _cmd,
                 BOOL validateApplicationLicenseWithInteraction,BOOL forced)

{
  int *piVar1;
  int *piVar2;
  BOOL BVar3;
  id pvVar4;
  id pvVar5;
  int *piVar6;
  int iVar7;
  undefined4 uVar8;
  int iVar9;
  int *piVar10;
  char *pcVar11;
  char local_12;
  char local_11;
  
  piVar1 = &self->_licenseUsageTimeInfo;
  piVar2 = &self->_licenseType;
  piVar6 = piVar2;
  piVar10 = piVar1;
  pvVar4 = _objc_msgSend(self,
                         sel_HSApplicationLicensor_loadLicenseForBundle_licenseType_usageTimeFlags_,
                         self->_applicationBundle,piVar2,piVar1);
  self->_licenseStatus = (int)pvVar4;
  if (validateApplicationLicenseWithInteraction == '\0') {
    return pvVar4 == (id)0x0;
  }
  local_11 = '\0';
  local_12 = '\0';
  if (forced == '\0') {
    if (pvVar4 == (id)0x6) {
      piVar6 = (int *)*piVar2;
      if (piVar6 == (int *)0x3) {
        iVar7 = 1;
      }
      else {
        iVar7 = ((*piVar1 & 2) == 0) + 2;
      }
    }
    else {
      pvVar5 = (id)0x0;
      if (pvVar4 == (id)0x0) goto LAB_00287d9f;
      piVar6 = (int *)*piVar2;
      iVar7 = 0;
    }
    pcVar11 = &local_11;
    piVar10 = (int *)0x0;
    iVar9 = iVar7;
    pvVar5 = _objc_msgSend(self,
                           sel_HSApplicationLicensor_licenseApplicationWithReason_currentLicenseType_isCanceled_isLicenseChanged_
                           ,iVar7,piVar6,0,pcVar11);
    self->_licenseStatus = (int)pvVar5;
    if (pvVar5 == (id)0x0) {
      pvVar4 = _objc_msgSend(cls_LUUserDataValidation,sel_sharedInstance,iVar9,piVar6,piVar10,
                             pcVar11);
      piVar6 = piVar1;
      piVar10 = piVar2;
      pvVar5 = _objc_msgSend(pvVar4,sel_validateLicenseUserData_usageTimeFlags_licenseType_,0,piVar1
                             ,piVar2);
      self->_licenseStatus = (int)pvVar5;
      if ((pvVar5 == (id)0x6) && (iVar7 != 0)) {
        self->_licenseStatus = 0;
        pvVar5 = (id)0x0;
      }
    }
  }
  else {
    piVar6 = (int *)self->_licenseType;
    pcVar11 = &local_11;
    piVar10 = (int *)&local_12;
    uVar8 = 4;
    pvVar5 = _objc_msgSend(self,
                           sel_HSApplicationLicensor_licenseApplicationWithReason_currentLicenseType_isCanceled_isLicenseChanged_
                           ,4,piVar6,piVar10,pcVar11);
    self->_licenseStatus = (int)pvVar5;
    if ((pvVar5 == (id)0x0) && (local_12 == '\0')) {
      pvVar4 = _objc_msgSend(cls_LUUserDataValidation,sel_sharedInstance,uVar8,piVar6,piVar10,
                             pcVar11);
      piVar6 = piVar1;
      piVar10 = piVar2;
      pvVar5 = _objc_msgSend(pvVar4,sel_validateLicenseUserData_usageTimeFlags_licenseType_,0,piVar1
                             ,piVar2);
      self->_licenseStatus = (int)pvVar5;
    }
  }
LAB_00287d9f:
  if ((local_12 == '\0') && (pvVar5 == (id)0x0)) {
    if (local_11 != '\0') {
      _objc_msgSend(self,sel_HSApplicationLicensor_storeApplicationLicenseForBundle_,
                    self->_applicationBundle,piVar6,piVar10);
    }
    iVar7 = *piVar2;
    if (((iVar7 == 1) && ((*piVar1 & 8) != 0)) || (iVar7 == 2)) {
      _objc_msgSend(self,sel_HSApplicationLicensor_registerApplicationOnNetworkForLicenseType_,iVar7
                    ,piVar6,piVar10);
      BVar3 = '\x01';
    }
    else {
      BVar3 = '\x01';
    }
  }
  else {
    BVar3 = '\0';
  }
  return BVar3;
}

*/
- (BOOL)validateApplicationLicenseWithInteraction:(BOOL)aInteraction forced:(BOOL)aForced
{
    _licenseStatus = [self HSApplicationLicensor_loadLicenseForBundle:_applicationBundle licenseType:&_licenseType usageTimeFlags:&_licenseUsageTimeInfo];
    if (!aInteraction) {
        return _licenseStatus == 0;
    }
    BOOL isLicenseChanged = NO;
    BOOL isCanceled = NO;
    NSInteger status;
    if (!aForced) {
        NSInteger reason;
        if (_licenseStatus == 6) {
            if (_licenseType == 3) {
                reason = 1;
            }
            else {
                reason = ((_licenseUsageTimeInfo & 2) == 0) + 2;
            }
        }
        else if (_licenseStatus == 0) {
            status = 0;
            goto finish;
        }
        else {
            reason = 0;
        }
        status = [self HSApplicationLicensor_licenseApplicationWithReason:reason currentLicenseType:_licenseType isCanceled:NULL isLicenseChanged:&isLicenseChanged];
        _licenseStatus = status;
        if (status == 0) {
            status = [[LUUserDataValidation sharedInstance] validateLicenseUserData:NULL usageTimeFlags:&_licenseUsageTimeInfo licenseType:&_licenseType];
            _licenseStatus = status;
            if (status == 6 && reason != 0) {
                _licenseStatus = 0;
                status = 0;
            }
        }
    }
    else {
        status = [self HSApplicationLicensor_licenseApplicationWithReason:4 currentLicenseType:_licenseType isCanceled:&isCanceled isLicenseChanged:&isLicenseChanged];
        _licenseStatus = status;
        if (status == 0 && !isCanceled) {
            status = [[LUUserDataValidation sharedInstance] validateLicenseUserData:NULL usageTimeFlags:&_licenseUsageTimeInfo licenseType:&_licenseType];
            _licenseStatus = status;
        }
    }
finish:
    if (!isCanceled && status == 0) {
        if (isLicenseChanged) {
            [self HSApplicationLicensor_storeApplicationLicenseForBundle:_applicationBundle];
        }
        if ((_licenseType == 1 && (_licenseUsageTimeInfo & 8) != 0) || _licenseType == 2) {
            [self HSApplicationLicensor_registerApplicationOnNetworkForLicenseType:_licenseType];
        }
        return YES;
    }
    return NO;
}

- (id)registrationInfo
{
    return _registrationInfo;
}

- (NSInteger)licenseUsageTimeInfo
{
    return _licenseUsageTimeInfo;
}

- (NSInteger)licenseType
{
    return _licenseType;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0028a1f7 @ 0028a1f7, 401 bytes * /

id FUN_0028a1f7(HSApplicationLicensor *self,SEL _cmd,void *initWithLicensorBytes,uint bytesSize,
               id bundle,id majorVersion,id minorVersion)

{
  id self_00;
  id pvVar1;
  int iVar2;
  id pvVar3;
  id pvVar4;
  HSApplicationLicensor *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_NSObject_003567e0;
  self_00 = _objc_msgSendSuper(&local_1c,sel_init);
  if (self_00 != (id)0x0) {
    if ((initWithLicensorBytes != (void *)0x0) && (bytesSize != 0)) {
      pvVar1 = _objc_msgSend(majorVersion,sel_copy);
      *(id *)((int)self_00 + 0xc) = pvVar1;
      pvVar1 = _objc_msgSend(minorVersion,sel_copy);
      *(id *)((int)self_00 + 0x10) = pvVar1;
      iVar2 = FUN_002afbe2(initWithLicensorBytes,bytesSize,0,0);
      if (iVar2 == 0) {
        pvVar1 = _objc_msgSend(*(id *)((int)self_00 + 0x10),sel_UTF8String);
        pvVar3 = _objc_msgSend(*(id *)((int)self_00 + 0xc),sel_UTF8String);
        pvVar4 = _objc_msgSend(bundle,sel_bundleIdentifier);
        pvVar4 = _objc_msgSend(pvVar4,sel_UTF8String);
        iVar2 = FUN_002af494("HS500",pvVar4,pvVar3,pvVar1);
        if (iVar2 == 0) {
          pvVar1 = _objc_msgSend(bundle,sel_retain);
          *(id *)((int)self_00 + 8) = pvVar1;
          *(undefined4 *)((int)self_00 + 0x18) = 0;
          *(undefined4 *)((int)self_00 + 0x1c) = 0;
          pvVar1 = _objc_msgSend(cls_LUUserDataValidation,sel_sharedInstance);
          _objc_msgSend(pvVar1,sel_updateApplicationSessionInfo);
          return self_00;
        }
        FUN_002ae0d4();
      }
    }
    _objc_msgSend(self_00,sel_release);
  }
  return (id)0x0;
}

*/
- (id)initWithLicensorBytes:(void *)aBytes bytesSize:(NSUInteger)aSize bundle:(id)aBundle majorVersion:(id)aVersion minorVersion:(id)aVersion2
{
    self = [super init];
    if (self) {
        if (aBytes != NULL && aSize != 0) {
            _majorVersion = [aVersion copy];
            _minorVersion = [aVersion2 copy];
            if (SLInitialize(aBytes, aSize, NULL, NULL) == 0) {
                if (SLSetApplicationInfo("HS500", [[aBundle bundleIdentifier] UTF8String], [_majorVersion UTF8String], [_minorVersion UTF8String]) == 0) {
                    _applicationBundle = [aBundle retain];
                    _licenseType = 0;
                    _licenseUsageTimeInfo = 0;
                    [[LUUserDataValidation sharedInstance] updateApplicationSessionInfo];
                    return self;
                }
                SLShutdown();
            }
        }
        [self release];
    }
    return nil;
}

- (id)init
{
    [self release];
    return nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00289c75 @ 00289c75, 364 bytes * /

void FUN_00289c75(HSApplicationLicensor *self,SEL _cmd)

{
  id pvVar1;
  HSApplicationLicensor *local_14;
  undefined *local_10;
  
  if (self->_applicationRegistrar != (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    _objc_msgSend(pvVar1,sel_removeObserver_name_object_,self,*(undefined4 *)PTR_PTR_00336990,
                  self->_applicationRegistrar);
    _objc_msgSend(self->_applicationRegistrar,sel_release);
  }
  pvVar1 = _objc_msgSend(cls_LUUserDataValidation,sel_sharedInstance);
  _objc_msgSend(pvVar1,sel_updateApplicationSessionInfo);
  FUN_002ae0d4();
  _objc_msgSend(self->_registrationInfo,sel_release);
  _objc_msgSend(self->_applicationBundle,sel_release);
  _objc_msgSend(self->_majorVersion,sel_release);
  _objc_msgSend(self->_minorVersion,sel_release);
  _objc_msgSend(self->_trialSerial,sel_release);
  _objc_msgSend(self->_fisrtTrialExtensionSerial,sel_release);
  _objc_msgSend(self->_secondTrialExtensionSerial,sel_release);
  _objc_msgSend(self->_hiddenTrialExtensionSerial,sel_release);
  local_14 = self;
  local_10 = PTR_s_NSObject_003567e0;
  _objc_msgSendSuper(&local_14,sel_dealloc);
  return;
}

*/
- (void)dealloc
{
    if (_applicationRegistrar != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:HSNetworkRegistrarRefusedNotification object:_applicationRegistrar];
        [_applicationRegistrar release];
    }
    [[LUUserDataValidation sharedInstance] updateApplicationSessionInfo];
    SLShutdown();
    [_registrationInfo release];
    [_applicationBundle release];
    [_majorVersion release];
    [_minorVersion release];
    [_trialSerial release];
    [_fisrtTrialExtensionSerial release];
    [_secondTrialExtensionSerial release];
    [_hiddenTrialExtensionSerial release];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00289932 @ 00289932, 835 bytes * /

void FUN_00289932(HSApplicationLicensor *self,SEL _cmd,
                 int HSApplicationLicensor_registerApplicationOnNetworkForLicenseType)

{
  int iVar1;
  HSApplicationLicensor *pHVar2;
  HSApplicationLicensor *pHVar3;
  id pvVar4;
  id self_00;
  HSApplicationLicensor *pHVar5;
  uint *puVar6;
  uint uVar7;
  undefined4 uVar8;
  id local_1c;
  byte local_14 [4];
  
  local_14[0] = 0;
  local_14[1] = 0;
  local_14[2] = 0;
  local_14[3] = 0;
  iVar1 = FUN_002b4acc(0,0,local_14);
  if (iVar1 != 0) {
    return;
  }
  if (local_14 == (byte  [4])0x0) {
    return;
  }
  pHVar2 = _malloc((size_t)local_14);
  if (pHVar2 == (HSApplicationLicensor *)0x0) {
    return;
  }
  pHVar5 = (HSApplicationLicensor *)local_14;
  iVar1 = FUN_002b4acc(0,pHVar2,pHVar5);
  if (iVar1 == 0) {
    uVar8 = 0x1e;
    pHVar5 = pHVar2;
    pHVar3 = _objc_msgSend(cls_NSString,sel_stringWithCString_encoding_,pHVar2,0x1e);
    if (pHVar3 != (HSApplicationLicensor *)0x0) {
      if (self->_applicationRegistrar != (id)0x0) {
        pvVar4 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter,pHVar5,uVar8);
        uVar8 = *(undefined4 *)PTR_PTR_00336990;
        pHVar5 = self;
        _objc_msgSend(pvVar4,sel_removeObserver_name_object_,self,uVar8,self->_applicationRegistrar)
        ;
        _objc_msgSend(self->_applicationRegistrar,sel_release);
        self->_applicationRegistrar = (id)0x0;
      }
      pvVar4 = _objc_msgSend(cls_HSNetworkRegistrar,sel_alloc,pHVar5,uVar8);
      self_00 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
      pHVar5 = _objc_msgSend(self_00,sel_bundleIdentifier);
      local_1c = _objc_msgSend(pvVar4,sel_initWithBundleIdentifier_licenseType_,pHVar5,
                               HSApplicationLicensor_registerApplicationOnNetworkForLicenseType);
      if (local_1c == (id)0x0) goto LAB_00289c40;
      pvVar4 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter,pHVar5,
                             HSApplicationLicensor_registerApplicationOnNetworkForLicenseType);
      _objc_msgSend(pvVar4,sel_addObserver_selector_name_object_,self,
                    sel_HSApplicationLicensor_networkRegistrarRefused_,
                    *(undefined4 *)PTR_PTR_00336990,local_1c);
      uVar8 = FUN_002b4aad(0);
      pvVar4 = _objc_msgSend(local_1c,sel_registerWithIdentifier_allowedCount_,pHVar3,uVar8);
      pHVar5 = pHVar3;
      if (pvVar4 != (id)0x0) goto LAB_00289c40;
      pHVar5 = (HSApplicationLicensor *)local_14;
      iVar1 = FUN_002b4b3d(0,0,pHVar5);
      if ((iVar1 == 0) && (local_14 != (byte  [4])0x0)) {
        puVar6 = _malloc((size_t)local_14);
        if (puVar6 == (uint *)0x0) goto LAB_00289c40;
        pHVar5 = (HSApplicationLicensor *)local_14;
        iVar1 = FUN_002b4b3d(0,puVar6,pHVar5);
        if (iVar1 != 0) {
          _free(puVar6);
          goto LAB_00289c40;
        }
        if (*puVar6 != 0) {
          uVar7 = 0;
          do {
            pvVar4 = _objc_msgSend(cls_NSString,sel_alloc,pHVar5,uVar8);
            pHVar5 = (HSApplicationLicensor *)puVar6[uVar7 + 1];
            uVar8 = 0x1e;
            pHVar3 = _objc_msgSend(pvVar4,sel_initWithCString_encoding_);
            if (pHVar3 != (HSApplicationLicensor *)0x0) {
              pHVar5 = pHVar3;
              _objc_msgSend(local_1c,sel_registerBlockingIdentifier_,pHVar3,uVar8);
              _objc_msgSend(pHVar3,sel_release);
            }
            uVar7 = uVar7 + 1;
          } while (uVar7 < *puVar6);
        }
        _free(puVar6);
      }
      self->_applicationRegistrar = local_1c;
    }
  }
  local_1c = (id)0x0;
LAB_00289c40:
  _objc_msgSend(local_1c,sel_release,pHVar5);
  _free(pHVar2);
  return;
}

*/
- (void)HSApplicationLicensor_registerApplicationOnNetworkForLicenseType:(NSInteger)aType
{
    uint32_t size = 0;
    if (SLLicenseCopyNetworkIdentifier(NULL, NULL, &size) != 0 || size == 0) {
        return;
    }
    char *identifierBytes = malloc(size);
    if (identifierBytes == NULL) {
        return;
    }
    HSNetworkRegistrar *registrar = nil;
    if (SLLicenseCopyNetworkIdentifier(NULL, identifierBytes, &size) == 0) {
        NSString *identifier = [NSString stringWithCString:identifierBytes encoding:NSMacOSRomanStringEncoding];
        if (identifier != nil) {
            if (_applicationRegistrar != nil) {
                [[NSNotificationCenter defaultCenter] removeObserver:self name:HSNetworkRegistrarRefusedNotification object:_applicationRegistrar];
                [_applicationRegistrar release];
                _applicationRegistrar = nil;
            }
            registrar = [[HSNetworkRegistrar alloc] initWithBundleIdentifier:[[NSBundle mainBundle] bundleIdentifier] licenseType:aType];
            if (registrar != nil) {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSApplicationLicensor_networkRegistrarRefused:) name:HSNetworkRegistrarRefusedNotification object:registrar];
                if ([registrar registerWithIdentifier:identifier allowedCount:SLLicenseGetAllowedCount(NULL)] == 0) {
                    uint32_t blockingSize = 0;
                    if (SLLicenseCopyBlockingIdentifiers(NULL, NULL, &blockingSize) == 0 && blockingSize != 0) {
                        uintptr_t *blocking = malloc(blockingSize);
                        if (blocking != NULL) {
                            if (SLLicenseCopyBlockingIdentifiers(NULL, blocking, &blockingSize) == 0) {
                                for (uintptr_t i = 0; i < blocking[0]; i++) {
                                    NSString *blockingIdentifier = [[NSString alloc] initWithCString:(const char *)blocking[i + 1] encoding:NSMacOSRomanStringEncoding];
                                    if (blockingIdentifier != nil) {
                                        [registrar registerBlockingIdentifier:blockingIdentifier];
                                        [blockingIdentifier release];
                                    }
                                }
                            }
                            free(blocking);
                        }
                    }
                    _applicationRegistrar = registrar;
                    registrar = nil;
                }
            }
        }
    }
    [registrar release];
    free(identifierBytes);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002884a0 @ 002884a0, 654 bytes * /

void FUN_002884a0(HSApplicationLicensor *self,SEL _cmd,
                 id HSApplicationLicensor_networkRegistrarRefused)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  cfstringStruct *pcVar4;
  undefined4 uVar5;
  
  pvVar1 = _objc_msgSend(HSApplicationLicensor_networkRegistrarRefused,sel_userInfo);
  uVar5 = *(undefined4 *)PTR_PTR_0033698c;
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,uVar5);
  pvVar1 = _objc_msgSend(pvVar1,sel_intValue);
  if (pvVar1 == (id)0x0) {
    return;
  }
  if (pvVar1 == (id)0x3) {
    pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,uVar5);
    pcVar4 = &cfstr_The_quota_of_users_that_can_use_the_same_registr;
LAB_0028862f:
    pvVar2 = (id)0x0;
  }
  else {
    if (pvVar1 != (id)0x2) {
      pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,uVar5);
      pcVar4 = &cfstr_Application_network_registration_is_denied;
      goto LAB_0028862f;
    }
    pvVar1 = _objc_msgSend(HSApplicationLicensor_networkRegistrarRefused,sel_userInfo,uVar5);
    pvVar2 = _objc_msgSend(pvVar1,sel_objectForKey_,*(undefined4 *)PTR_PTR_00336988);
    pvVar1 = _objc_msgSend(HSApplicationLicensor_networkRegistrarRefused,sel_userInfo);
    pcVar4 = *(cfstringStruct **)PTR_PTR_00336984;
    pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,pcVar4);
    if (pvVar1 != (id)0x0) goto LAB_00288641;
    pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pcVar4);
    pcVar4 = &cfstr_The_registration_number_you_have_entered_has_alr;
  }
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,pcVar4,&cfstr_empty,
                         &cfstr_Alerts);
LAB_00288641:
  if (pvVar1 != (id)0x0) {
    if (pvVar2 == (id)0x0) {
      pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pcVar4);
      pcVar4 = &cfstr_HyperStudio_will_quit_now;
      pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                             &cfstr_HyperStudio_will_quit_now,&cfstr_empty,&cfstr_Alerts);
    }
    pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pcVar4);
    pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_Quit,&cfstr_empty,
                           &cfstr_Alerts);
    _NSRunAlertPanel(pvVar2,pvVar1,pvVar3,0,0);
    _objc_msgSend(*(id *)PTR_00336058,sel_terminate_,self);
  }
  return;
}

*/
- (void)HSApplicationLicensor_networkRegistrarRefused:(id)aRefused
{
    NSDictionary *userInfo = [aRefused userInfo];
    NSInteger errorCode = [[userInfo objectForKey:HSNetworkRegistrarRefusedErrorCode] intValue];
    if (errorCode == 0) {
        return;
    }
    HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
    NSString *title = nil;
    NSString *explanation;
    if (errorCode == 3) {
        explanation = [provider localizedStringForKey:@"The quota of users that can use the same registration number has been reached. Please contact with your system administrator" value:@"" table:@"Alerts"];
    }
    else {
        NSString *fallbackKey;
        if (errorCode != 2) {
            fallbackKey = @"Application network registration is denied";
        }
        else {
            fallbackKey = @"The registration number you have entered has already been used to register another copy of the application. Please contact with your system administrator";
        }
        title = [[aRefused userInfo] objectForKey:HSNetworkRegistrarRefusedCutomErrorTitle];
        explanation = [[aRefused userInfo] objectForKey:HSNetworkRegistrarRefusedCutomErrorExplanation];
        if (explanation == nil) {
            explanation = [provider localizedStringForKey:fallbackKey value:@"" table:@"Alerts"];
        }
    }
    if (explanation != nil) {
        if (title == nil) {
            title = [provider localizedStringForKey:@"HyperStudio will quit now" value:@"" table:@"Alerts"];
        }
        NSRunAlertPanel(title, @"%@", [provider localizedStringForKey:@"Quit" value:@"" table:@"Alerts"], nil, nil, explanation);
        [NSApp terminate:self];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00288bbe @ 00288bbe, 2519 bytes * /

int FUN_00288bbe(HSApplicationLicensor *self,SEL _cmd,
                int HSApplicationLicensor_licenseApplicationWithReason,int currentLicenseType,
                BOOL *isCanceled,BOOL *isLicenseChanged)

{
  HSApplicationLicensor *pHVar1;
  HSApplicationLicensor *pHVar2;
  HSApplicationLicensor *pHVar3;
  bool bVar4;
  int iVar5;
  id pvVar6;
  id pvVar7;
  id pvVar8;
  id pvVar9;
  HSApplicationLicensor *pHVar10;
  void *pvVar11;
  HSApplicationLicensor *pHVar12;
  id pvVar13;
  HSApplicationLicensor *pHVar14;
  undefined4 *puVar15;
  id pvVar16;
  size_t *psVar17;
  undefined4 uVar18;
  char *pcVar19;
  BOOL local_85;
  int local_84;
  id local_80;
  BOOL local_79;
  id local_64;
  size_t local_60;
  char local_5a;
  char local_59;
  HSApplicationLicensor *local_58;
  size_t local_54 [8];
  undefined1 local_34;
  size_t local_30 [7];
  undefined1 local_14;
  
  local_54[0] = 0;
  switch(HSApplicationLicensor_licenseApplicationWithReason) {
  case 1:
    uVar18 = *(undefined4 *)PTR_PTR_003369b0;
    break;
  case 2:
    uVar18 = *(undefined4 *)PTR_PTR_003369b4;
    break;
  case 3:
    puVar15 = (undefined4 *)PTR_PTR_003369ac;
    goto LAB_00288c5f;
  case 4:
    uVar18 = *(undefined4 *)PTR_PTR_003369a0;
    local_84 = 2;
    goto LAB_00288c68;
  default:
    puVar15 = (undefined4 *)PTR_PTR_003369a8;
    if (currentLicenseType != 3) {
      uVar18 = *(undefined4 *)PTR_PTR_003369a4;
      iVar5 = FUN_002afb5d();
      if (iVar5 == 0) {
        iVar5 = FUN_002af75b(0,local_54);
      }
      puVar15 = (undefined4 *)PTR_PTR_003369a8;
      if ((iVar5 == 0) && (local_54[0] != 0)) break;
    }
LAB_00288c5f:
    uVar18 = *puVar15;
    local_84 = 3;
    goto LAB_00288c68;
  }
  local_84 = 1;
LAB_00288c68:
  pvVar6 = _objc_msgSend(cls_HSSerialNumberDialogController,sel_alloc);
  pvVar6 = _objc_msgSend(pvVar6,sel_initWithType_,uVar18);
  pHVar14 = self;
  _objc_msgSend(pvVar6,sel_setDelegate_,self);
  local_58 = (HSApplicationLicensor *)0x0;
  pHVar1 = *(HSApplicationLicensor **)PTR_PTR_0033699c;
  pHVar2 = *(HSApplicationLicensor **)PTR_PTR_00336998;
  pHVar3 = *(HSApplicationLicensor **)PTR_PTR_00336994;
  local_64 = (id)0x1;
  bVar4 = true;
  local_85 = '\0';
  local_79 = '\0';
LAB_00288d10:
  do {
    local_59 = '\0';
    if (bVar4) {
      local_64 = _objc_msgSend(pvVar6,sel_runModal,pHVar14);
    }
    switch(local_64) {
    case (id)0x0:
      if (HSApplicationLicensor_licenseApplicationWithReason != 4) goto switchD_00288d42_default;
      local_85 = '\x01';
      pvVar16 = (id)0x1;
      bVar4 = true;
      break;
    case (id)0x1:
      pvVar16 = _objc_msgSend(pvVar6,sel_validationContext,pHVar14);
      pHVar14 = _objc_msgSend(pvVar16,sel_license);
      pvVar13 = _objc_msgSend(self,sel_HSApplicationLicensor_registrationInfoForLicense_);
      if (pvVar13 == (id)0x0) goto switchD_00288d42_default;
      local_5a = '\0';
      pvVar7 = _objc_msgSend(self,sel_HSApplicationLicensor_hiddenTrialExtensionSerial,pHVar14);
      pvVar8 = _objc_msgSend(pvVar16,sel_serialString);
      pvVar7 = _objc_msgSend(pvVar7,sel_isEqualToString_,pvVar8);
      if ((char)pvVar7 == '\0') {
        pvVar7 = _objc_msgSend(pvVar16,sel_usageTimeFlags,pvVar8);
        pcVar19 = &local_5a;
        pHVar14 = pHVar2;
        if (((uint)pvVar7 & 4) == 0) {
          pHVar14 = pHVar3;
        }
        uVar18 = 0;
        pvVar8 = pvVar13;
        pHVar12 = _objc_msgSend(self,
                                sel_HSApplicationLicensor_showRegistrationDialog_registrationString_forceUI_isGoBack_
                                ,pHVar14,pvVar13,0,pcVar19);
        if (((uint)pvVar7 & 4) != 0) {
          if (local_5a == '\0') {
            pvVar7 = _objc_msgSend(pHVar12,sel_count,pHVar14,pvVar8,uVar18,pcVar19);
            if (pvVar7 == (id)0x0) {
              bVar4 = true;
              pvVar16 = (id)0x2;
              break;
            }
            pvVar7 = (id)FUN_0028708d();
            pvVar8 = _objc_msgSend(pvVar7,sel_length,pHVar14,pvVar8,uVar18,pcVar19);
            if (pvVar8 != (id)0x0) {
              local_60 = 0;
              pHVar14 = (HSApplicationLicensor *)0x0;
              iVar5 = FUN_002af2e3(0,(uint)pvVar8 & 0xff,0,&local_60);
              if ((iVar5 == 0) &&
                 (pHVar10 = _malloc(local_60), pHVar10 != (HSApplicationLicensor *)0x0)) {
                pvVar7 = _objc_msgSend(pvVar7,sel_bytes);
                psVar17 = &local_60;
                pHVar14 = pHVar10;
                iVar5 = FUN_002af2e3(pvVar7,(uint)pvVar8 & 0xff,pHVar10,psVar17);
                if (iVar5 == 0) {
                  psVar17 = (size_t *)0x1e;
                  pHVar14 = pHVar10;
                  local_80 = _objc_msgSend(cls_NSString,sel_stringWithCString_encoding_,pHVar10,0x1e
                                          );
                }
                else {
                  local_80 = (id)0x0;
                }
                _free(pHVar10);
                pvVar7 = _objc_msgSend(local_80,sel_length,pHVar14,psVar17);
                if (pvVar7 != (id)0x0) {
                  pvVar7 = _objc_msgSend(cls_HSSubmitInformationDialogController,sel_alloc,pHVar14,
                                         psVar17);
                  pvVar7 = _objc_msgSend(pvVar7,sel_initWithWindowNibName_,
                                         &cfstr_SubmitInformationDialog);
                  _objc_msgSend(pvVar7,sel_setTrialLicenseState_,local_84);
                  pvVar8 = _objc_msgSend(pvVar7,
                                         sel_runModalWithInformationDictionary_applicationRegistrationIdentifier_
                                         ,pHVar12,local_80);
                  if (pvVar8 == (id)0x0) {
                    pvVar16 = _objc_msgSend(pvVar16,sel_activateLicense,pHVar12,local_80);
                    if (pvVar16 == (id)0x0) {
                      _objc_msgSend(self->_registrationInfo,sel_release,pHVar12,local_80);
                      pvVar13 = _objc_msgSend(pvVar13,sel_copy);
                      self->_registrationInfo = pvVar13;
                      bVar4 = true;
                      local_79 = '\x01';
                    }
                    else {
                      bVar4 = true;
                    }
                  }
                  else {
                    if (pvVar8 == (id)0x1) {
                      if (HSApplicationLicensor_licenseApplicationWithReason == 4) {
                        local_85 = '\x01';
                      }
                    }
                    else if (pvVar8 == (id)0x3) {
                      if (local_84 == 1) {
                        local_59 = '\x01';
                        bVar4 = false;
                        pvVar16 = (id)0x1;
                        local_64 = (id)((HSApplicationLicensor_licenseApplicationWithReason != 0) +
                                       2);
                      }
                      else {
                        bVar4 = true;
                        pvVar16 = (id)0x0;
                      }
                      goto LAB_0028920b;
                    }
                    bVar4 = true;
                    pvVar16 = (id)0x1;
                  }
LAB_0028920b:
                  _objc_msgSend(pvVar7,sel_release,pHVar12,local_80);
                  pHVar14 = pHVar12;
                  break;
                }
              }
            }
            goto switchD_00288d42_default;
          }
          bVar4 = true;
          goto LAB_00288d10;
        }
      }
      else {
        pvVar7 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar8);
        pHVar14 = _objc_msgSend(pvVar7,sel_localizedStringForKey_value_table_,&cfstr_OK,&cfstr_empty
                                ,&cfstr_Alerts);
        pvVar7 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
        pvVar7 = _objc_msgSend(pvVar7,sel_localizedStringForKey_value_table_,
                               &cfstr_You_now_have_an_additional_10_days_to_try_HyperS,&cfstr_empty,
                               &cfstr_Alerts);
        pvVar8 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
        pvVar9 = _objc_msgSend(pvVar8,sel_localizedStringForKey_value_table_,
                               &cfstr_The_trial_period_has_been_extended,&cfstr_empty,&cfstr_Alerts)
        ;
        uVar18 = 0;
        pvVar8 = (id)0x0;
        _NSRunAlertPanel(pvVar9,pvVar7,pHVar14,0,0);
        pHVar12 = (HSApplicationLicensor *)0x0;
      }
      pvVar7 = _objc_msgSend(pHVar12,sel_count,pHVar14,pvVar8,uVar18);
      if (pvVar7 != (id)0x0) {
        pvVar7 = _objc_msgSend(cls_HSSubmitRequest,sel_sharedInstance,pHVar14,pvVar8,uVar18);
        _objc_msgSend(pvVar7,sel_submitInformationDictionary_,pHVar12);
        pHVar14 = pHVar12;
      }
      pvVar16 = _objc_msgSend(pvVar16,sel_activateLicense,pHVar14,pvVar8,uVar18);
      if (pvVar16 == (id)0x0) {
        _objc_msgSend(self->_registrationInfo,sel_release,pHVar14);
        pvVar13 = _objc_msgSend(pvVar13,sel_copy);
        self->_registrationInfo = pvVar13;
        goto LAB_00289533;
      }
LAB_00288f4a:
      bVar4 = true;
      break;
    case (id)0x2:
      if (local_54[0] != 0) {
        if (local_58 == (HSApplicationLicensor *)0x0) {
          pvVar11 = _malloc(local_54[0]);
          if (pvVar11 == (void *)0x0) goto switchD_00288d42_default;
          pvVar16 = (id)FUN_002af75b(pvVar11,local_54);
          if (pvVar16 == (id)0x0) {
            pvVar16 = (id)FUN_002afb3b(pvVar11,&local_58);
          }
          _free(pvVar11);
          if (pvVar16 != (id)0x0) goto LAB_00288f4a;
        }
        else {
          pvVar16 = (id)0x1;
        }
        pHVar14 = local_58;
        pvVar13 = _objc_msgSend(self,sel_HSApplicationLicensor_registrationInfoForLicense_,local_58)
        ;
        if (pvVar13 != (id)0x0) {
          pcVar19 = &local_59;
          uVar18 = 0;
          pHVar14 = pHVar1;
          pvVar7 = pvVar13;
          pHVar12 = _objc_msgSend(self,
                                  sel_HSApplicationLicensor_showRegistrationDialog_registrationString_forceUI_isGoBack_
                                  ,pHVar1,pvVar13,0,pcVar19);
          if (local_59 != '\0') {
            bVar4 = true;
            break;
          }
          pvVar16 = _objc_msgSend(pHVar12,sel_count,pHVar14,pvVar7,uVar18,pcVar19);
          if (pvVar16 != (id)0x0) {
            pvVar16 = _objc_msgSend(cls_HSSubmitRequest,sel_sharedInstance,pHVar14,pvVar7,uVar18,
                                    pcVar19);
            _objc_msgSend(pvVar16,sel_submitInformationDictionary_,pHVar12);
            pHVar14 = pHVar12;
          }
          pvVar16 = (id)FUN_002af240(local_58);
          if (pvVar16 == (id)0x0) {
            _objc_msgSend(self->_registrationInfo,sel_release,pHVar14,pvVar7,uVar18,pcVar19);
            pvVar13 = _objc_msgSend(pvVar13,sel_copy);
            self->_registrationInfo = pvVar13;
            local_58 = (HSApplicationLicensor *)0x0;
            goto LAB_00289533;
          }
        }
        goto LAB_00288f4a;
      }
    default:
switchD_00288d42_default:
      bVar4 = true;
      pvVar16 = (id)0x1;
      break;
    case (id)0x3:
      iVar5 = FUN_002b48a2(0);
      if (local_58 == (HSApplicationLicensor *)0x0) {
        if (iVar5 == 3) {
          local_34 = 0;
          local_54[7] = 0x41443250;
          local_54[6] = 0x2d4b3947;
          local_54[5] = 0x524c2d39;
          local_54[4] = 0x3456334d;
          local_54[3] = 0x2d424742;
          local_54[2] = 0x54342d38;
          local_54[1] = 0x484b4a50;
          psVar17 = local_54 + 1;
        }
        else {
          local_14 = 0;
          local_30[6] = 0x41433450;
          local_30[5] = 0x2d4b3946;
          local_30[4] = 0x504c2d39;
          local_30[3] = 0x3456334d;
          local_30[2] = 0x2d424741;
          local_30[1] = 0x55352d39;
          local_30[0] = 0x484d4a4e;
          psVar17 = local_30;
        }
        pvVar16 = (id)FUN_002afb3b(psVar17,&local_58);
        if (pvVar16 != (id)0x0) {
          bVar4 = true;
          break;
        }
      }
      else {
        pvVar16 = (id)0x1;
      }
      pHVar14 = local_58;
      pvVar13 = _objc_msgSend(self,sel_HSApplicationLicensor_registrationInfoForLicense_,local_58);
      if ((pvVar13 == (id)0x0) || (pvVar16 = (id)FUN_002af240(local_58), pvVar16 != (id)0x0))
      goto LAB_00288f4a;
      _objc_msgSend(self->_registrationInfo,sel_release,pHVar14);
      pvVar13 = _objc_msgSend(pvVar13,sel_copy);
      self->_registrationInfo = pvVar13;
      local_58 = (HSApplicationLicensor *)0x0;
      pvVar13 = _objc_msgSend(cls_HSExtensionAlertController,sel_sharedInstance);
      pHVar14 = (HSApplicationLicensor *)(uint)(iVar5 != 3);
      _objc_msgSend(pvVar13,sel_runModalForMode_,pHVar14);
LAB_00289533:
      bVar4 = true;
      local_79 = '\x01';
    }
    if (local_59 == '\0') {
      _objc_msgSend(pvVar6,sel_release,pHVar14);
      if (local_58 != (HSApplicationLicensor *)0x0) {
        FUN_002af216(local_58);
      }
      if (isCanceled != (BOOL *)0x0) {
        *isCanceled = local_85;
      }
      if (isLicenseChanged != (BOOL *)0x0) {
        *isLicenseChanged = local_79;
      }
      return (int)pvVar16;
    }
  } while( true );
}

*/
- (NSInteger)HSApplicationLicensor_licenseApplicationWithReason:(NSInteger)aReason currentLicenseType:(NSInteger)aType isCanceled:(BOOL *)aCanceled isLicenseChanged:(BOOL *)aChanged
{
    uint32_t serialSize = 0;
    NSString *dialogType;
    NSInteger trialState;
    switch (aReason) {
    case 1:
        dialogType = HSSerialNumberDialogControllerTypeTrialFirstExtended;
        trialState = 1;
        break;
    case 2:
        dialogType = HSSerialNumberDialogControllerTypeTrialLastExtended;
        trialState = 1;
        break;
    case 3:
        dialogType = HSSerialNumberDialogControllerTypeTrial;
        trialState = 3;
        break;
    case 4:
        dialogType = HSSerialNumberDialogControllerTypeActivate;
        trialState = 2;
        break;
    default:
        if (aType != 3) {
            dialogType = HSSerialNumberDialogControllerTypeCommon;
            int status = SLLicenseHasPendingSerial();
            if (status == 0) {
                status = SLLicenseCopyPendingSerial(NULL, &serialSize);
            }
            if (status == 0 && serialSize != 0) {
                trialState = 1;
                break;
            }
        }
        dialogType = HSSerialNumberDialogControllerTypeCommonWOTrial;
        trialState = 3;
        break;
    }
    HSSerialNumberDialogController *dialog = [[HSSerialNumberDialogController alloc] initWithType:dialogType];
    [dialog setDelegate:self];
    struct SLLicense *license = NULL;
    BOOL isCanceled = NO;
    BOOL isLicenseChanged = NO;
    BOOL goBack = NO;
    NSInteger fallbackMode = (aReason != 0) + 2;
    NSInteger dialogResult = 1;
    NSInteger result = 1;
    BOOL runDialog = YES;
    do {
        goBack = NO;
        if (runDialog) {
            dialogResult = [dialog runModal];
        }
        runDialog = YES;
        result = 1;
        switch (dialogResult) {
        case 0:
            if (aReason == 4) {
                isCanceled = YES;
            }
            break;
        case 1: {
            HSSerialValidationContext *context = [dialog validationContext];
            struct SLLicense *contextLicense = [context license];
            NSString *info = [self HSApplicationLicensor_registrationInfoForLicense:contextLicense];
            if (info == nil) {
                break;
            }
            BOOL contextGoBack = NO;
            NSDictionary *information;
            if ([[self HSApplicationLicensor_hiddenTrialExtensionSerial] isEqualToString:[context serialString]]) {
                HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
                NSString *okTitle = [provider localizedStringForKey:@"OK" value:@"" table:@"Alerts"];
                NSString *message = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"You now have an additional 10 days to try HyperStudio on a single computer. To continue using the product after the trial period is over, you will need to register it with a non-expiring license." value:@"" table:@"Alerts"];
                NSString *title = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"The trial period has been extended" value:@"" table:@"Alerts"];
                NSRunAlertPanel(title, @"%@", okTitle, nil, nil, message);
                information = nil;
            }
            else {
                NSInteger flags = [context usageTimeFlags];
                NSString *registrationType = (flags & 4) ? HSRegistrationFormControllerTypeCommonWithForcedResponse : HSRegistrationFormControllerTypeCommon;
                information = [self HSApplicationLicensor_showRegistrationDialog:registrationType registrationString:info forceUI:NO isGoBack:&contextGoBack];
                if ((flags & 4) != 0) {
                    if (contextGoBack) {
                        break;
                    }
                    if ([information count] == 0) {
                        result = 2;
                        break;
                    }
                    NSData *hardwareAddress = HSPrimaryEthernetMACAddress();
                    NSUInteger addressLength = [hardwareAddress length];
                    if (addressLength == 0) {
                        break;
                    }
                    uint32_t identifierSize = 0;
                    if (SLEncodeHardwareIdentifier(NULL, addressLength & 0xff, NULL, &identifierSize) != 0) {
                        break;
                    }
                    char *identifierBuffer = malloc(identifierSize);
                    if (identifierBuffer == NULL) {
                        break;
                    }
                    NSString *identifier = nil;
                    if (SLEncodeHardwareIdentifier([hardwareAddress bytes], addressLength & 0xff, identifierBuffer, &identifierSize) == 0) {
                        identifier = [NSString stringWithCString:identifierBuffer encoding:NSMacOSRomanStringEncoding];
                    }
                    free(identifierBuffer);
                    if ([identifier length] == 0) {
                        break;
                    }
                    HSSubmitInformationDialogController *submitDialog = [[HSSubmitInformationDialogController alloc] initWithWindowNibName:@"SubmitInformationDialog"];
                    [submitDialog setTrialLicenseState:trialState];
                    NSInteger submitResult = [submitDialog runModalWithInformationDictionary:information applicationRegistrationIdentifier:identifier];
                    if (submitResult == 0) {
                        result = [context activateLicense];
                        if (result == 0) {
                            [_registrationInfo release];
                            _registrationInfo = [info copy];
                            isLicenseChanged = YES;
                        }
                    }
                    else if (submitResult == 1) {
                        if (aReason == 4) {
                            isCanceled = YES;
                        }
                    }
                    else if (submitResult == 3) {
                        if (trialState == 1) {
                            goBack = YES;
                            runDialog = NO;
                            dialogResult = fallbackMode;
                        }
                        else {
                            result = 0;
                        }
                    }
                    [submitDialog release];
                    break;
                }
            }
            if ([information count] != 0) {
                [[HSSubmitRequest sharedInstance] submitInformationDictionary:information];
            }
            result = [context activateLicense];
            if (result == 0) {
                [_registrationInfo release];
                _registrationInfo = [info copy];
                isLicenseChanged = YES;
            }
            break;
        }
        case 2: {
            if (serialSize == 0) {
                break;
            }
            if (license == NULL) {
                char *serialBuffer = malloc(serialSize);
                if (serialBuffer == NULL) {
                    break;
                }
                result = SLLicenseCopyPendingSerial(serialBuffer, &serialSize);
                if (result == 0) {
                    result = SLLicenseCreateFromSerial(serialBuffer, &license);
                }
                free(serialBuffer);
                if (result != 0) {
                    break;
                }
            }
            else {
                result = 1;
            }
            NSString *info = [self HSApplicationLicensor_registrationInfoForLicense:license];
            if (info == nil) {
                break;
            }
            NSDictionary *information = [self HSApplicationLicensor_showRegistrationDialog:HSRegistrationFormControllerTypeTrialReduced registrationString:info forceUI:NO isGoBack:&goBack];
            if (goBack) {
                break;
            }
            if ([information count] != 0) {
                [[HSSubmitRequest sharedInstance] submitInformationDictionary:information];
            }
            result = SLLicenseActivate(license);
            if (result == 0) {
                [_registrationInfo release];
                _registrationInfo = [info copy];
                license = NULL;
                isLicenseChanged = YES;
            }
            break;
        }
        case 3: {
            int currentType = SLLicenseGetType(NULL);
            if (license == NULL) {
                const char *extensionSerial = (currentType == 3) ? "PJKH8-4TBGB-M3V49-LRG9K-P2DA" : "NJMH9-5UAGB-M3V49-LPF9K-P4CA";
                result = SLLicenseCreateFromSerial(extensionSerial, &license);
                if (result != 0) {
                    break;
                }
            }
            else {
                result = 1;
            }
            NSString *info = [self HSApplicationLicensor_registrationInfoForLicense:license];
            if (info == nil) {
                break;
            }
            result = SLLicenseActivate(license);
            if (result != 0) {
                break;
            }
            [_registrationInfo release];
            _registrationInfo = [info copy];
            license = NULL;
            [[HSExtensionAlertController sharedInstance] runModalForMode:currentType != 3];
            isLicenseChanged = YES;
            break;
        }
        default:
            break;
        }
    } while (goBack);
    [dialog release];
    if (license != NULL) {
        SLLicenseRelease(license);
    }
    if (aCanceled != NULL) {
        *aCanceled = isCanceled;
    }
    if (aChanged != NULL) {
        *aChanged = isLicenseChanged;
    }
    return result;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00287ac3 @ 00287ac3, 243 bytes * /

id FUN_00287ac3(HSApplicationLicensor *self,SEL _cmd,id HSApplicationLicensor_showRegistrationDialog
               ,id registrationString,BOOL forceUI,BOOL *isGoBack)

{
  id pvVar1;
  id pvVar2;
  BOOL BVar3;
  id pvVar4;
  id pvVar5;
  undefined4 local_14;
  
  pvVar4 = registrationString;
  pvVar5 = HSApplicationLicensor_showRegistrationDialog;
  local_14 = _objc_msgSend(cls_HSRegistrationFormController,
                           sel_completeRegistrationDictionaryWithSerial_type_,registrationString,
                           HSApplicationLicensor_showRegistrationDialog);
  if ((local_14 == (id)0x0) || (forceUI != '\0')) {
    pvVar1 = _objc_msgSend(cls_HSRegistrationFormController,sel_alloc,pvVar4,pvVar5);
    pvVar4 = HSApplicationLicensor_showRegistrationDialog;
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithType_,HSApplicationLicensor_showRegistrationDialog);
    pvVar2 = _objc_msgSend(pvVar1,sel_runModal);
    if (pvVar2 == (id)0x0) {
      BVar3 = '\0';
      local_14 = _objc_msgSend(cls_HSRegistrationFormController,
                               sel_completeRegistrationDictionaryWithSerial_type_,registrationString
                               ,HSApplicationLicensor_showRegistrationDialog);
    }
    else {
      registrationString = pvVar4;
      HSApplicationLicensor_showRegistrationDialog = pvVar5;
      if (pvVar2 == (id)0x1) {
        BVar3 = '\x01';
      }
      else {
        BVar3 = '\0';
      }
    }
    _objc_msgSend(pvVar1,sel_release,registrationString,HSApplicationLicensor_showRegistrationDialog
                 );
  }
  else {
    BVar3 = '\0';
  }
  if (isGoBack != (BOOL *)0x0) {
    *isGoBack = BVar3;
  }
  return local_14;
}

*/
- (id)HSApplicationLicensor_showRegistrationDialog:(id)aDialog registrationString:(id)aString forceUI:(BOOL)aUI isGoBack:(BOOL *)aBack
{
    id registration = [HSRegistrationFormController completeRegistrationDictionaryWithSerial:aString type:aDialog];
    BOOL goBack = NO;
    if (registration == nil || aUI) {
        HSRegistrationFormController *controller = [[HSRegistrationFormController alloc] initWithType:aDialog];
        NSInteger result = [controller runModal];
        if (result == 0) {
            registration = [HSRegistrationFormController completeRegistrationDictionaryWithSerial:aString type:aDialog];
        }
        else {
            goBack = (result == 1);
        }
        [controller release];
    }
    if (aBack != NULL) {
        *aBack = goBack;
    }
    return registration;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00287a33 @ 00287a33, 144 bytes * /

id FUN_00287a33(HSApplicationLicensor *self,SEL _cmd)

{
  id pvVar1;
  undefined4 local_2c;
  undefined4 local_28;
  undefined4 local_24;
  undefined4 local_20;
  undefined4 local_1c;
  undefined4 local_18;
  undefined4 local_14;
  undefined1 local_10;
  
  pvVar1 = self->_hiddenTrialExtensionSerial;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSString,sel_alloc);
    local_10 = 0;
    local_14 = 0x41443450;
    local_18 = 0x2d4c3646;
    local_1c = 0x514c2d38;
    local_20 = 0x3255334d;
    local_24 = 0x2d4d5944;
    local_28 = 0x32442d39;
    local_2c = 0x484b4a50;
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithCString_encoding_,&local_2c,4);
    self->_hiddenTrialExtensionSerial = pvVar1;
  }
  return pvVar1;
}

*/
- (id)HSApplicationLicensor_hiddenTrialExtensionSerial
{
    if (!_hiddenTrialExtensionSerial) {
        _hiddenTrialExtensionSerial = [[NSString alloc] initWithCString:"PJKH9-D2DYM-M3U28-LQF6L-P4DA" encoding:NSUTF8StringEncoding];
    }
    return _hiddenTrialExtensionSerial;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002879a3 @ 002879a3, 144 bytes * /

id FUN_002879a3(HSApplicationLicensor *self,SEL _cmd)

{
  id pvVar1;
  undefined4 local_2c;
  undefined4 local_28;
  undefined4 local_24;
  undefined4 local_20;
  undefined4 local_1c;
  undefined4 local_18;
  undefined4 local_14;
  undefined1 local_10;
  
  pvVar1 = self->_secondTrialExtensionSerial;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSString,sel_alloc);
    local_10 = 0;
    local_14 = 0x41433450;
    local_18 = 0x2d4b3946;
    local_1c = 0x504c2d39;
    local_20 = 0x3456334d;
    local_24 = 0x2d424741;
    local_28 = 0x55352d39;
    local_2c = 0x484d4a4e;
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithCString_encoding_,&local_2c,4);
    self->_secondTrialExtensionSerial = pvVar1;
  }
  return pvVar1;
}

*/
- (id)HSApplicationLicensor_secondTrialExtensionSerial
{
    if (!_secondTrialExtensionSerial) {
        _secondTrialExtensionSerial = [[NSString alloc] initWithCString:"NJMH9-5UAGB-M3V49-LPF9K-P4CA" encoding:NSUTF8StringEncoding];
    }
    return _secondTrialExtensionSerial;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00287913 @ 00287913, 144 bytes * /

id FUN_00287913(HSApplicationLicensor *self,SEL _cmd)

{
  id pvVar1;
  undefined4 local_2c;
  undefined4 local_28;
  undefined4 local_24;
  undefined4 local_20;
  undefined4 local_1c;
  undefined4 local_18;
  undefined4 local_14;
  undefined1 local_10;
  
  pvVar1 = self->_fisrtTrialExtensionSerial;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSString,sel_alloc);
    local_10 = 0;
    local_14 = 0x41443250;
    local_18 = 0x2d4b3947;
    local_1c = 0x524c2d39;
    local_20 = 0x3456334d;
    local_24 = 0x2d424742;
    local_28 = 0x54342d38;
    local_2c = 0x484b4a50;
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithCString_encoding_,&local_2c,4);
    self->_fisrtTrialExtensionSerial = pvVar1;
  }
  return pvVar1;
}

*/
- (id)HSApplicationLicensor_fisrtTrialExtensionSerial
{
    if (!_fisrtTrialExtensionSerial) {
        _fisrtTrialExtensionSerial = [[NSString alloc] initWithCString:"PJKH8-4TBGB-M3V49-LRG9K-P2DA" encoding:NSUTF8StringEncoding];
    }
    return _fisrtTrialExtensionSerial;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00287883 @ 00287883, 144 bytes * /

id FUN_00287883(HSApplicationLicensor *self,SEL _cmd)

{
  id pvVar1;
  undefined4 local_2c;
  undefined4 local_28;
  undefined4 local_24;
  undefined4 local_20;
  undefined4 local_1c;
  undefined4 local_18;
  undefined4 local_14;
  undefined1 local_10;
  
  pvVar1 = self->_trialSerial;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSString,sel_alloc);
    local_10 = 0;
    local_14 = 0x4952544c;
    local_18 = 0x2d414952;
    local_1c = 0x544c2d41;
    local_20 = 0x49525430;
    local_24 = 0x2d303553;
    local_28 = 0x484f2d4d;
    local_2c = 0x45445348;
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithCString_encoding_,&local_2c,4);
    self->_trialSerial = pvVar1;
  }
  return pvVar1;
}

*/
- (id)HSApplicationLicensor_trialSerial
{
    if (!_trialSerial) {
        _trialSerial = [[NSString alloc] initWithCString:"HSDEM-OHS50-0TRIA-LTRIA-LTRI" encoding:NSUTF8StringEncoding];
    }
    return _trialSerial;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0028872e @ 0028872e, 1168 bytes * /

int FUN_0028872e(HSApplicationLicensor *self,SEL _cmd,
                id HSApplicationLicensor_storeApplicationLicenseForBundle)

{
  id pvVar1;
  int iVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  void *pvVar7;
  int iVar8;
  int iVar9;
  cfstringStruct *pcVar10;
  int iVar11;
  void *pvVar12;
  int iVar13;
  int local_18;
  int local_14;
  
  pvVar1 = _objc_msgSend(HSApplicationLicensor_storeApplicationLicenseForBundle,sel_bundlePath);
  pvVar1 = _objc_msgSend(pvVar1,sel_fileSystemRepresentation);
  iVar2 = FUN_002aeef1(pvVar1);
  if (iVar2 == 9) {
    pcVar10 = &cfstr__authorizationTool;
    pvVar1 = _objc_msgSend(HSApplicationLicensor_storeApplicationLicenseForBundle,
                           sel_pathForAuxiliaryExecutable_,&cfstr__authorizationTool);
    pvVar1 = _objc_msgSend(pvVar1,sel_fileSystemRepresentation);
    if (pvVar1 != (id)0x0) {
      pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pcVar10);
      pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_Quit,&cfstr_empty,
                             &cfstr_Alerts);
      pvVar4 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
      pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,&cfstr_Authenticate,
                             &cfstr_empty,&cfstr_Alerts);
      pvVar5 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
      pvVar5 = _objc_msgSend(pvVar5,sel_localizedStringForKey_value_table_,
                             &cfstr_You_should_authenticate_with_your_administrator_,&cfstr_empty,
                             &cfstr_Alerts);
      pvVar6 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
      pvVar6 = _objc_msgSend(pvVar6,sel_localizedStringForKey_value_table_,
                             &cfstr_Cannot_launch_HyperStudio,&cfstr_empty,&cfstr_Alerts);
      iVar2 = _NSRunAlertPanel(pvVar6,pvVar5,pvVar4,pvVar3,0);
      if (iVar2 != 1) {
        _objc_msgSend(*(id *)PTR_00336058,sel_terminate_,self);
      }
      local_14 = 0;
      iVar2 = FUN_002aed55(0,0,&local_14);
      if (iVar2 == 0) {
        local_18 = 0;
        iVar2 = FUN_002af392(0,&local_18);
        if (iVar2 == 0) {
          pvVar7 = _malloc(local_18 + local_14);
          if (pvVar7 == (void *)0x0) {
            iVar2 = 1;
          }
          else {
            iVar2 = FUN_002af392(pvVar7,&local_18);
            if (iVar2 == 0) {
              iVar8 = local_18 + (int)pvVar7;
              iVar2 = FUN_002aed55(0,iVar8,&local_14);
              if (iVar2 == 0) {
                while (pvVar3 = pvVar1, iVar9 = iVar8, iVar11 = local_14, pvVar12 = pvVar7,
                      iVar13 = local_18,
                      pvVar4 = _objc_msgSend(self,
                                             sel_HSApplicationLicensor_storeWithAuthorizatonTool_licenseBytes_licenseBytesSize_environment_environmentSize_
                                             ,pvVar1,iVar8,local_14,pvVar7,local_18),
                      pvVar4 == (id)0xffffffff) {
                  pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar3,
                                         iVar9,iVar11,pvVar12,iVar13);
                  pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_Quit,
                                         &cfstr_empty,&cfstr_Alerts);
                  pvVar4 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
                  pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,
                                         &cfstr_Authenticate,&cfstr_empty,&cfstr_Alerts);
                  pvVar5 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
                  pvVar5 = _objc_msgSend(pvVar5,sel_localizedStringForKey_value_table_,
                                         &cfstr_You_should_authenticate_with_your_administrator_,
                                         &cfstr_empty,&cfstr_Alerts);
                  pvVar6 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
                  pvVar6 = _objc_msgSend(pvVar6,sel_localizedStringForKey_value_table_,
                                         &cfstr_Cannot_launch_HyperStudio,&cfstr_empty,&cfstr_Alerts
                                        );
                  iVar9 = _NSRunAlertPanel(pvVar6,pvVar5,pvVar4,pvVar3,0);
                  if (iVar9 != 1) {
                    _objc_msgSend(*(id *)PTR_00336058,sel_terminate_,self);
                  }
                }
              }
              _free(pvVar7);
            }
            else {
              _free(pvVar7);
            }
          }
        }
      }
    }
  }
  return iVar2;
}

*/
- (NSInteger)HSApplicationLicensor_storeApplicationLicenseForBundle:(id)aBundle
{
    NSInteger result = SLLicenseStoreToHostFile([[aBundle bundlePath] fileSystemRepresentation]);
    if (result == 9) {
        const char *tool = [[aBundle pathForAuxiliaryExecutable:@".authorizationTool"] fileSystemRepresentation];
        if (tool != NULL) {
            HSApplicationLicensorRunAuthenticationAlert(self);
            uint32_t licenseSize = 0;
            result = SLLicenseCopyData(NULL, NULL, &licenseSize);
            if (result == 0) {
                uint32_t environmentSize = 0;
                result = SLLicenseCopyEnvironment(NULL, &environmentSize);
                if (result == 0) {
                    void *buffer = malloc(environmentSize + licenseSize);
                    if (buffer == NULL) {
                        result = 1;
                    }
                    else {
                        result = SLLicenseCopyEnvironment(buffer, &environmentSize);
                        if (result == 0) {
                            void *licenseBytes = (char *)buffer + environmentSize;
                            result = SLLicenseCopyData(NULL, licenseBytes, &licenseSize);
                            if (result == 0) {
                                while ((result = [self HSApplicationLicensor_storeWithAuthorizatonTool:(char *)tool licenseBytes:licenseBytes licenseBytesSize:licenseSize environment:buffer environmentSize:environmentSize]) == -1) {
                                    HSApplicationLicensorRunAuthenticationAlert(self);
                                }
                            }
                        }
                        free(buffer);
                    }
                }
            }
        }
    }
    return result;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00288134 @ 00288134, 876 bytes * /

int FUN_00288134(HSApplicationLicensor *self,SEL _cmd,
                char *HSApplicationLicensor_storeWithAuthorizatonTool,void *licenseBytes,
                uint licenseBytesSize,void *environment,uint environmentSize)

{
  id pvVar1;
  int iVar2;
  int iVar3;
  size_t sVar4;
  undefined4 local_8c;
  uint local_88;
  FILE *local_84;
  undefined4 local_80;
  undefined4 local_7c;
  char **local_78;
  char *local_74;
  undefined4 local_70;
  undefined4 local_6c;
  undefined4 local_68;
  int local_64;
  undefined4 local_60;
  id local_5c [2];
  id *local_54;
  id local_50;
  id local_48;
  undefined4 local_44;
  undefined2 local_40;
  undefined4 local_3c;
  undefined4 local_38;
  undefined4 local_34;
  undefined4 local_30;
  id local_2c [7];
  
  if (((licenseBytes != (void *)0x0) && (environment != (void *)0x0)) && (environmentSize != 0)) {
    pvVar1 = _objc_msgSend(self->_applicationBundle,sel_bundleIdentifier);
    local_2c[0] = _objc_msgSend(pvVar1,sel_UTF8String);
    local_2c[1] = (id)0x0;
    local_2c[2] = (id)0x0;
    local_2c[3] = (id)0x0;
    local_2c[4] = (id)0x0;
    local_2c[5] = (id)0x0;
    local_2c[6] = (id)0x0;
    local_30 = 0x6e6f69;
    local_34 = 0x73726576;
    local_38 = 0x2d74726f;
    local_3c = 0x68732d2d;
    local_40 = 0x6e;
    local_44 = 0x6f697372;
    local_48 = (id)0x65762d2d;
    pvVar1 = _objc_msgSend(self->_applicationBundle,sel_bundlePath);
    local_2c[1] = _objc_msgSend(pvVar1,sel_fileSystemRepresentation);
    if (local_2c[1] != (id)0x0) {
      pvVar1 = _objc_msgSend(self->_majorVersion,sel_UTF8String);
      local_50 = _objc_msgSend(self->_minorVersion,sel_UTF8String);
      local_5c[0] = &local_3c;
      local_5c[1] = pvVar1;
      local_54 = local_5c + 5;
      iVar2 = 2;
      iVar3 = 0;
      while( true ) {
        if (pvVar1 != (id)0x0) {
          local_2c[iVar2] = local_5c[iVar3 * 2];
          local_2c[iVar2 + 1] = pvVar1;
          iVar2 = iVar2 + 2;
        }
        if (iVar3 == 1) break;
        pvVar1 = local_5c[iVar3 * 2 + 3];
        iVar3 = iVar3 + 1;
      }
      local_60 = 0;
      iVar3 = _AuthorizationCreate(0,0,0,&local_60);
      if (iVar3 == 0) {
        local_64 = 1;
        local_74 = "system.privilege.admin";
        local_70 = 0;
        local_6c = 0;
        local_68 = 0;
        local_7c = 1;
        local_78 = &local_74;
        local_80 = 0;
        iVar3 = _AuthorizationCopyRights(local_60,&local_7c,0,0x13,&local_80);
        if (iVar3 == -0xea66) {
          local_64 = -1;
          iVar3 = -1;
        }
        else {
          if (iVar3 == 0) {
            local_84 = (FILE *)0x0;
            iVar3 = _AuthorizationExecuteWithPrivileges
                              (local_60,HSApplicationLicensor_storeWithAuthorizatonTool,0,local_2c,
                               &local_84);
            if ((iVar3 == 0) && (local_84 != (FILE *)0x0)) {
              local_8c = 0x68736165;
              local_88 = environmentSize;
              sVar4 = _fwrite(&local_8c,1,8,local_84);
              if ((sVar4 == 8) &&
                 (sVar4 = _fwrite(environment,1,environmentSize,local_84), sVar4 == environmentSize)
                 ) {
                local_8c = 0x68736c69;
                local_88 = licenseBytesSize;
                sVar4 = _fwrite(&local_8c,1,8,local_84);
                if ((sVar4 == 8) &&
                   (sVar4 = _fwrite(licenseBytes,1,licenseBytesSize,local_84),
                   sVar4 == licenseBytesSize)) {
                  sVar4 = _fread(&local_64,1,4,local_84);
                  iVar3 = local_64;
                  if (sVar4 != 4) {
                    local_64 = 0;
                    iVar3 = 0;
                  }
                  goto LAB_00288479;
                }
              }
            }
          }
          iVar3 = 1;
        }
LAB_00288479:
        _AuthorizationFree(local_60,8);
        return iVar3;
      }
    }
  }
  return 1;
}

*/
- (NSInteger)HSApplicationLicensor_storeWithAuthorizatonTool:(char *)aTool licenseBytes:(void *)aBytes licenseBytesSize:(NSUInteger)aSize environment:(void *)aEnvironment environmentSize:(NSUInteger)aSize2
{
    if (aBytes == NULL || aEnvironment == NULL || aSize2 == 0) {
        return 1;
    }
    const char *arguments[7] = { [[_applicationBundle bundleIdentifier] UTF8String], [[_applicationBundle bundlePath] fileSystemRepresentation], NULL, NULL, NULL, NULL, NULL };
    if (arguments[1] == NULL) {
        return 1;
    }
    const char *major = [_majorVersion UTF8String];
    const char *minor = [_minorVersion UTF8String];
    int count = 2;
    if (major != NULL) {
        arguments[count++] = "--short-version";
        arguments[count++] = major;
    }
    if (minor != NULL) {
        arguments[count++] = "--version";
        arguments[count++] = minor;
    }
    AuthorizationRef authorization = NULL;
    if (AuthorizationCreate(NULL, NULL, kAuthorizationFlagDefaults, &authorization) != errAuthorizationSuccess) {
        return 1;
    }
    int result = 1;
    AuthorizationItem item = { "system.privilege.admin", 0, NULL, 0 };
    AuthorizationRights rights = { 1, &item };
    AuthorizationRights *grantedRights = NULL;
    OSStatus status = AuthorizationCopyRights(authorization, &rights, NULL, kAuthorizationFlagInteractionAllowed | kAuthorizationFlagExtendRights | kAuthorizationFlagPreAuthorize, &grantedRights);
    if (status == errAuthorizationCanceled) {
        result = -1;
    }
    else if (status == errAuthorizationSuccess) {
        FILE *pipe = NULL;
        if (AuthorizationExecuteWithPrivileges(authorization, aTool, kAuthorizationFlagDefaults, (char * const *)arguments, &pipe) == errAuthorizationSuccess && pipe != NULL) {
            uint32_t header[2];
            memcpy(header, "eash", 4);
            header[1] = (uint32_t)aSize2;
            if (fwrite(header, 1, 8, pipe) == 8 && fwrite(aEnvironment, 1, aSize2, pipe) == aSize2) {
                memcpy(header, "ilsh", 4);
                header[1] = (uint32_t)aSize;
                if (fwrite(header, 1, 8, pipe) == 8 && fwrite(aBytes, 1, aSize, pipe) == aSize) {
                    if (fread(&result, 1, 4, pipe) != 4) {
                        result = 0;
                    }
                }
            }
        }
    }
    AuthorizationFree(authorization, kAuthorizationFlagDestroyRights);
    return result;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00288029 @ 00288029, 267 bytes * /

int FUN_00288029(HSApplicationLicensor *self,SEL _cmd,id HSApplicationLicensor_loadLicenseForBundle,
                int *licenseType,int *usageTimeFlags)

{
  id pvVar1;
  int iVar2;
  id pvVar3;
  undefined4 uVar4;
  int *piVar5;
  int local_14;
  
  local_14 = FUN_002b48a2(0);
  if (local_14 == 0) {
    pvVar1 = _objc_msgSend(HSApplicationLicensor_loadLicenseForBundle,sel_bundlePath);
    pvVar1 = _objc_msgSend(pvVar1,sel_fileSystemRepresentation);
    iVar2 = FUN_002aea49(pvVar1);
    if (iVar2 != 0) {
      return iVar2;
    }
  }
  pvVar1 = _objc_msgSend(cls_LUUserDataValidation,sel_sharedInstance);
  piVar5 = &local_14;
  uVar4 = 0;
  pvVar1 = _objc_msgSend(pvVar1,sel_validateLicenseUserData_usageTimeFlags_licenseType_,0,
                         usageTimeFlags,piVar5);
  if (pvVar1 == (id)0x0) {
    _objc_msgSend(self->_registrationInfo,sel_release,uVar4,usageTimeFlags,piVar5);
    pvVar3 = _objc_msgSend(self,sel_HSApplicationLicensor_registrationInfoForLicense_,0);
    pvVar3 = _objc_msgSend(pvVar3,sel_retain);
    self->_registrationInfo = pvVar3;
  }
  if ((pvVar1 == (id)0x0 || pvVar1 == (id)0x6) && (licenseType != (int *)0x0)) {
    *licenseType = local_14;
  }
  return (int)pvVar1;
}

*/
- (NSInteger)HSApplicationLicensor_loadLicenseForBundle:(id)aBundle licenseType:(int *)aType usageTimeFlags:(int *)aFlags
{
    int type = SLLicenseGetType(NULL);
    if (type == 0) {
        SLLicenseLoadHostFile([[aBundle bundlePath] fileSystemRepresentation]);
    }
    NSInteger result = [[LUUserDataValidation sharedInstance] validateLicenseUserData:NULL usageTimeFlags:aFlags licenseType:&type];
    if (result == 0) {
        [_registrationInfo release];
        _registrationInfo = [[self HSApplicationLicensor_registrationInfoForLicense:NULL] retain];
    }
    if ((result == 0 || result == 6) && aType != NULL) {
        *aType = type;
    }
    return result;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00287f4e @ 00287f4e, 219 bytes * /

id FUN_00287f4e(HSApplicationLicensor *self,SEL _cmd,
               SLLicense *HSApplicationLicensor_registrationInfoForLicense)

{
  int iVar1;
  void *pvVar2;
  id pvVar3;
  size_t local_14;
  
  local_14 = 0;
  iVar1 = FUN_002b49fc(HSApplicationLicensor_registrationInfoForLicense,0,&local_14);
  if (((iVar1 == 0) && (local_14 != 0)) && (pvVar2 = _malloc(local_14), pvVar2 != (void *)0x0)) {
    iVar1 = FUN_002b49fc(HSApplicationLicensor_registrationInfoForLicense,pvVar2,&local_14);
    if (iVar1 == 0) {
      pvVar3 = _objc_msgSend(cls_NSString,sel_alloc);
      pvVar3 = _objc_msgSend(pvVar3,sel_initWithBytesNoCopy_length_encoding_freeWhenDone_,pvVar2,
                             local_14 - 1,4,1);
      pvVar3 = _objc_msgSend(pvVar3,sel_autorelease);
      if (pvVar3 != (id)0x0) {
        return pvVar3;
      }
    }
    _free(pvVar2);
    return (id)0x0;
  }
  return (id)0x0;
}

*/
- (id)HSApplicationLicensor_registrationInfoForLicense:(struct SLLicense *)aLicense
{
    uint32_t size = 0;
    if (SLLicenseCopyRegistrationInfo(aLicense, NULL, &size) == 0 && size != 0) {
        void *buffer = malloc(size);
        if (buffer) {
            if (SLLicenseCopyRegistrationInfo(aLicense, buffer, &size) == 0) {
                NSString *info = [[NSString alloc] initWithBytesNoCopy:buffer length:size - 1 encoding:NSUTF8StringEncoding freeWhenDone:YES];
                return [info autorelease];
            }
            free(buffer);
        }
    }
    return nil;
}

@end

@implementation HSSerialValidationContext

/* i386 ivar offsets: _serialString=0x4, _license=0x8, _usageTimeFlags=0xc */

/* --- i386 decompilation (Ghidra) ---
/* FUN_002877f5 @ 002877f5, 49 bytes * /

int FUN_002877f5(HSSerialValidationContext *self,SEL _cmd)

{
  int iVar1;
  
  if (self->_license == (SLLicense *)0x0) {
    iVar1 = 1;
  }
  else {
    iVar1 = FUN_002af240(self->_license);
    if (iVar1 == 0) {
      self->_license = (SLLicense *)0x0;
    }
  }
  return iVar1;
}

*/
- (NSInteger)activateLicense
{
    if (_license == NULL) {
        return 1;
    }
    NSInteger result = SLLicenseActivate(_license);
    if (result == 0) {
        _license = NULL;
    }
    return result;
}

- (NSInteger)usageTimeFlags
{
    return _usageTimeFlags;
}

- (struct SLLicense *)license
{
    return _license;
}

- (id)serialString
{
    return _serialString;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00287826 @ 00287826, 93 bytes * /

void FUN_00287826(HSSerialValidationContext *self,SEL _cmd)

{
  HSSerialValidationContext *local_14;
  undefined *local_10;
  
  if (self->_license != (SLLicense *)0x0) {
    FUN_002af216(self->_license);
  }
  _objc_msgSend(self->_serialString,sel_release);
  local_14 = self;
  local_10 = PTR_s_NSObject_003567b0;
  _objc_msgSendSuper(&local_14,sel_dealloc);
  return;
}

*/
- (void)dealloc
{
    if (_license != NULL) {
        SLLicenseRelease(_license);
    }
    [_serialString release];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0028778e @ 0028778e, 103 bytes * /

id FUN_0028778e(HSSerialValidationContext *self,SEL _cmd,id initWithSerialString,SLLicense *license,
               int usageTimeFlags)

{
  id pvVar1;
  id pvVar2;
  HSSerialValidationContext *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_NSObject_003567b0;
  pvVar1 = _objc_msgSendSuper(&local_1c,sel_init);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(initWithSerialString,sel_copy);
    *(id *)((int)pvVar1 + 4) = pvVar2;
    *(SLLicense **)((int)pvVar1 + 8) = license;
    *(int *)((int)pvVar1 + 0xc) = usageTimeFlags;
  }
  return pvVar1;
}

*/
- (id)initWithSerialString:(id)aString license:(struct SLLicense *)aLicense usageTimeFlags:(NSInteger)aFlags
{
    self = [super init];
    if (self) {
        _serialString = [aString copy];
        _license = aLicense;
        _usageTimeFlags = aFlags;
    }
    return self;
}

@end

