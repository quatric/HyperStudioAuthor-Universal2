#import "LUUserDataValidation.h"

static LUUserDataValidation *sSharedInstance;

static uint32_t LUReadBE32(const uint8_t *p)
{
    return ((uint32_t)p[0] << 24) | ((uint32_t)p[1] << 16) | ((uint32_t)p[2] << 8) | p[3];
}

static double LUReadBEDouble(const uint8_t *p)
{
    uint64_t bits = ((uint64_t)LUReadBE32(p) << 32) | LUReadBE32(p + 4);
    double value;
    memcpy(&value, &bits, sizeof(value));
    return value;
}

static void LUWriteBEDouble(uint8_t *p, double value)
{
    uint64_t bits;
    memcpy(&bits, &value, sizeof(bits));
    for (int i = 0; i < 8; i++) {
        p[i] = (uint8_t)(bits >> (56 - 8 * i));
    }
}

@implementation LUUserDataValidation

/* i386 ivar offsets: _dateStoragePath=0x4, _dateStoragePermissions=0x8, _lastSessionDate=0xc */

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024d47e @ 0024d47e, 225 bytes * /

id FUN_0024d47e(id self,SEL _cmd)

{
  short sVar1;
  int iVar2;
  id self_00;
  id self_01;
  id pvVar3;
  undefined1 local_64 [84];
  
  if (DAT_00342a34 == (id)0x0) {
    sVar1 = _FSFindFolder(0xffff8005,0x70726566,1,local_64);
    if (sVar1 == 0) {
      iVar2 = _CFURLCreateFromFSRef(0,local_64);
      if (iVar2 != 0) {
        self_00 = (id)_CFURLCopyFileSystemPath(iVar2,0);
        _CFRelease(iVar2);
        if (self_00 != (id)0x0) {
          self_01 = _objc_msgSend(self,sel_alloc);
          pvVar3 = _objc_msgSend(self_00,sel_stringByAppendingPathComponent_,
                                 &cfstr__com_clpaths_local_plist);
          DAT_00342a34 = _objc_msgSend(self_01,sel_LUUserDataValidation_initWithDateStoragePath_,
                                       pvVar3);
          _CFRelease(self_00);
        }
      }
    }
  }
  return DAT_00342a34;
}

*/
+ (id)sharedInstance
{
    if (sSharedInstance == nil) {
        FSRef ref;
        if (FSFindFolder(kUserDomain, kPreferencesFolderType, true, &ref) == noErr) {
            CFURLRef url = CFURLCreateFromFSRef(NULL, &ref);
            if (url != NULL) {
                NSString *path = (NSString *)CFURLCopyFileSystemPath(url, kCFURLPOSIXPathStyle);
                CFRelease(url);
                if (path != nil) {
                    sSharedInstance = [[self alloc] LUUserDataValidation_initWithDateStoragePath:[path stringByAppendingPathComponent:@".com.clpaths.local.plist"]];
                    CFRelease(path);
                }
            }
        }
    }
    return sSharedInstance;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024d3e5 @ 0024d3e5, 54 bytes * /

void FUN_0024d3e5(LUUserDataValidation *self,SEL _cmd)

{
  _objc_msgSend(self,sel_saveCurrentApplicationSessionDateForKey_,0,0x40140000);
  return;
}

*/
- (void)updateApplicationSessionInfo
{
    [self saveCurrentApplicationSessionDateForKey:5.0];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024d55f @ 0024d55f, 783 bytes * /

id FUN_0024d55f(LUUserDataValidation *self,SEL _cmd,SLLicense *licenseDescription)

{
  id self_00;
  id pvVar1;
  cfstringStruct *pcVar2;
  int iVar3;
  int iVar4;
  undefined4 *puVar5;
  undefined4 uVar6;
  int *piVar7;
  undefined4 local_2c;
  int local_28;
  undefined4 local_24;
  undefined4 uStack_20;
  undefined4 local_1c;
  undefined4 uStack_18;
  
  self_00 = _objc_msgSend(cls_NSMutableDictionary,sel_dictionary);
  if (self_00 != (id)0x0) {
    uStack_18 = 0;
    local_1c = 0;
    uStack_20 = 0;
    local_24 = 0;
    local_28 = 0;
    piVar7 = &local_28;
    puVar5 = &local_24;
    uVar6 = 0;
    pvVar1 = _objc_msgSend(self,sel_license_expirationTime_creationTime_usageTimeFlags_type_,
                           licenseDescription,&local_1c,puVar5,0,piVar7);
    if (pvVar1 == (id)0x0) {
      if (local_28 == 3) {
        pcVar2 = &cfstr_Trial;
      }
      else if (local_28 == 2) {
        pcVar2 = &cfstr_Multiuser;
      }
      else if (local_28 == 1) {
        pcVar2 = &cfstr_Single_user;
      }
      else {
        pcVar2 = &cfstr_Unknown;
      }
      _objc_msgSend(self_00,sel_setObject_forKey_,pcVar2,&cfstr_LULicenseInfoType,puVar5,uVar6,
                    piVar7);
      pvVar1 = _objc_msgSend(cls_NSDate,sel_dateWithTimeIntervalSinceReferenceDate_,
                             CONCAT44(uStack_20,local_24));
      uVar6 = 0;
      pvVar1 = _objc_msgSend(pvVar1,sel_descriptionWithCalendarFormat_timeZone_locale_,0,0,0);
      pvVar1 = _objc_msgSend(pvVar1,sel_description);
      _objc_msgSend(self_00,sel_setObject_forKey_,pvVar1,&cfstr_LULicenseInfoCreationDate);
      if ((double)CONCAT44(uStack_18,local_1c) != 0.0) {
        pvVar1 = _objc_msgSend(cls_NSDate,sel_dateWithTimeIntervalSinceReferenceDate_,
                               CONCAT44(uStack_18,local_1c),uVar6);
        pvVar1 = _objc_msgSend(pvVar1,sel_descriptionWithCalendarFormat_timeZone_locale_,0,0,0);
        pvVar1 = _objc_msgSend(pvVar1,sel_description);
        _objc_msgSend(self_00,sel_setObject_forKey_,pvVar1,&cfstr_LULicenseInfoExpirationDate);
      }
      local_2c = 0;
      iVar3 = FUN_002b49fc(licenseDescription,0,&local_2c);
      if ((iVar3 == 0) && (iVar3 = _NSZoneMalloc(0,local_2c), iVar3 != 0)) {
        iVar4 = FUN_002b49fc(licenseDescription,iVar3,&local_2c);
        if ((iVar4 == 0) &&
           (pvVar1 = _objc_msgSend(cls_NSString,sel_stringWithUTF8String_,iVar3), pvVar1 != (id)0x0)
           ) {
          _objc_msgSend(self_00,sel_setObject_forKey_,pvVar1,&cfstr_LULicenseInfoIdentifier);
        }
        _NSZoneFree(0,iVar3);
      }
      iVar3 = FUN_002b4aad(licenseDescription);
      if (iVar3 == -1) {
        return self_00;
      }
      pvVar1 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr__u,iVar3);
      _objc_msgSend(self_00,sel_setObject_forKey_,pvVar1,&cfstr_LULicenseInfoCopiesCount);
      return self_00;
    }
  }
  return (id)0x0;
}

*/
- (id)licenseDescription:(struct SLLicense *)aDescription
{
    NSMutableDictionary *description = [NSMutableDictionary dictionary];
    if (description != nil) {
        double expirationTime = 0;
        double creationTime = 0;
        int type = 0;
        if ([self license:aDescription expirationTime:&expirationTime creationTime:&creationTime usageTimeFlags:NULL type:&type] == 0) {
            NSString *typeName;
            if (type == 3) {
                typeName = @"Trial";
            }
            else if (type == 2) {
                typeName = @"Multiuser";
            }
            else if (type == 1) {
                typeName = @"Single user";
            }
            else {
                typeName = @"Unknown";
            }
            [description setObject:typeName forKey:LULicenseInfoType];
            [description setObject:[[[NSDate dateWithTimeIntervalSinceReferenceDate:creationTime] descriptionWithCalendarFormat:nil timeZone:nil locale:nil] description] forKey:LULicenseInfoCreationDate];
            if (expirationTime != 0.0) {
                [description setObject:[[[NSDate dateWithTimeIntervalSinceReferenceDate:expirationTime] descriptionWithCalendarFormat:nil timeZone:nil locale:nil] description] forKey:LULicenseInfoExpirationDate];
            }
            uint32_t identifierSize = 0;
            if (SLLicenseGetRegistrationString(aDescription, NULL, &identifierSize) == 0) {
                char *identifier = NSZoneMalloc(NULL, identifierSize);
                if (identifier != NULL) {
                    if (SLLicenseGetRegistrationString(aDescription, identifier, &identifierSize) == 0) {
                        NSString *identifierString = [NSString stringWithUTF8String:identifier];
                        if (identifierString != nil) {
                            [description setObject:identifierString forKey:LULicenseInfoIdentifier];
                        }
                    }
                    NSZoneFree(NULL, identifier);
                }
            }
            int copiesCount = (int)SLLicenseGetCodeLimit(aDescription);
            if (copiesCount != -1) {
                [description setObject:[NSString stringWithFormat:@"%u", copiesCount] forKey:LULicenseInfoCopiesCount];
            }
        }
    }
    return description;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024d86e @ 0024d86e, 314 bytes * /

int FUN_0024d86e(LUUserDataValidation *self,SEL _cmd,SLLicense *validateLicenseUserData,
                int *usageTimeFlags,int *licenseType)

{
  id pvVar1;
  id pvVar2;
  double dVar3;
  undefined4 *puVar4;
  int *piVar5;
  undefined4 local_24;
  undefined4 uStack_20;
  undefined4 local_1c;
  undefined4 uStack_18;
  
  uStack_18 = 0;
  local_1c = 0;
  uStack_20 = 0;
  local_24 = 0;
  puVar4 = &local_24;
  piVar5 = usageTimeFlags;
  pvVar1 = _objc_msgSend(self,sel_license_expirationTime_creationTime_usageTimeFlags_type_,
                         validateLicenseUserData,&local_1c,puVar4,usageTimeFlags,licenseType);
  if (pvVar1 == (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_loadLastApplicationSessionDateForKey_,0,0x40140000,puVar4,piVar5
                           ,licenseType);
    if ((double)CONCAT44(uStack_18,local_1c) == 0.0) {
      if (usageTimeFlags != (int *)0x0) {
        *(byte *)usageTimeFlags = (byte)*usageTimeFlags & 0xfc;
      }
    }
    else {
      dVar3 = _objc_msgSend_fpret(cls_NSDate,sel_timeIntervalSinceReferenceDate);
      if (((dVar3 < (double)CONCAT44(uStack_20,local_24)) ||
          ((double)CONCAT44(uStack_18,local_1c) < dVar3)) ||
         (((char)pvVar2 != '\0' && ((double)CONCAT44(uStack_18,local_1c) < self->_lastSessionDate)))
         ) {
        pvVar1 = (id)0x6;
      }
      *(byte *)usageTimeFlags = (byte)*usageTimeFlags & 0xf3;
    }
    if (pvVar1 == (id)0x0) {
      _objc_msgSend(self,sel_saveCurrentApplicationSessionDateForKey_,0,0x40140000,puVar4,piVar5,
                    licenseType);
    }
  }
  return (int)pvVar1;
}

*/
- (NSInteger)validateLicenseUserData:(struct SLLicense *)aData usageTimeFlags:(int *)aFlags licenseType:(int *)aType
{
    double expiration = 0;
    double creation = 0;
    NSInteger result = [self license:aData expirationTime:&expiration creationTime:&creation usageTimeFlags:aFlags type:aType];
    if (result == 0) {
        BOOL loaded = [self loadLastApplicationSessionDateForKey:5.0];
        if (expiration == 0) {
            if (aFlags != NULL) {
                *(uint8_t *)aFlags &= 0xfc;
            }
        } else {
            double now = [NSDate timeIntervalSinceReferenceDate];
            if (now < creation || expiration < now || (loaded && expiration < _lastSessionDate)) {
                result = 6;
            }
            if (aFlags != NULL) {
                *(uint8_t *)aFlags &= 0xf3;
            }
        }
        if (result == 0) {
            [self saveCurrentApplicationSessionDateForKey:5.0];
        }
    }
    return result;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024d9a8 @ 0024d9a8, 789 bytes * /

int FUN_0024d9a8(LUUserDataValidation *self,SEL _cmd,SLLicense *license,double *expirationTime,
                double *creationTime,int *usageTimeFlags,int *type)

{
  double dVar1;
  double dVar2;
  uint uVar3;
  int iVar4;
  int iVar5;
  id pvVar6;
  uint uVar7;
  void *pvVar8;
  uint uVar9;
  longdouble lVar10;
  undefined4 local_34;
  undefined4 uStack_30;
  uint local_28;
  uint local_24;
  int local_20;
  double local_1c;
  
  iVar4 = FUN_002b48a2(license);
  lVar10 = (longdouble)FUN_002b49d8(license);
  dVar1 = (double)lVar10;
  if ((iVar4 == 0) || ((dVar1 == 0.0 && (!NAN(dVar1))))) {
LAB_0024d9ef:
    iVar5 = 1;
  }
  else {
    local_1c = 0.0;
    local_20 = 0;
    if (iVar4 == 3) {
      pvVar6 = _objc_msgSend(cls_NSCalendarDate,sel_dateWithTimeIntervalSinceReferenceDate_,dVar1);
      pvVar6 = _objc_msgSend(pvVar6,sel_dateByAddingYears_months_days_hours_minutes_seconds_,0,0,
                             0x1e,0,0,0);
      local_1c = _objc_msgSend_fpret(pvVar6,sel_timeIntervalSinceReferenceDate);
      if (local_1c == 0.0) {
        local_1c = dVar1 + 2592000.0;
      }
      local_20 = 3;
    }
    else {
      if (1 < iVar4 - 1U) goto LAB_0024d9ef;
      local_24 = 0;
      pvVar6 = (id)FUN_002b4cc8(license,0,&local_24);
      if (pvVar6 == (id)0x0) {
        local_28 = 0;
        pvVar6 = (id)FUN_002b4d44(license,0,&local_28);
        uVar9 = local_24;
        uVar3 = local_28;
        if (pvVar6 == (id)0x0) {
          uVar7 = local_28;
          if (local_28 <= local_24) {
            uVar7 = local_24;
          }
          if ((uVar7 != 0) && (pvVar8 = _malloc(uVar7), pvVar8 != (void *)0x0)) {
            if ((((uVar3 == 0) ||
                 ((pvVar6 = (id)FUN_002b4d44(license,pvVar8,&local_28), pvVar6 == (id)0x0 &&
                  (pvVar6 = _objc_msgSend(self,
                                          sel_LUUserDataValidation_validateUserBytes_bytesSize_licenseCreationTime_expirationTime_usageTimeFlags_
                                          ,pvVar8,local_28,dVar1,&local_1c,&local_20),
                  uVar9 = local_24, pvVar6 == (id)0x0)))) && (uVar9 != 0)) &&
               (pvVar6 = (id)FUN_002b4cc8(license,pvVar8,&local_24), pvVar6 == (id)0x0)) {
              uStack_30 = 0;
              local_34 = 0;
              pvVar6 = _objc_msgSend(self,
                                     sel_LUUserDataValidation_validateUserBytes_bytesSize_licenseCreationTime_expirationTime_usageTimeFlags_
                                     ,pvVar8,local_24,dVar1,&local_34,&local_20);
              if (pvVar6 == (id)0x0) {
                dVar2 = (double)CONCAT44(uStack_30,local_34);
                if (((dVar2 != 0.0) || (NAN(dVar2))) && ((local_1c == 0.0 || (dVar2 < local_1c)))) {
                  local_1c = dVar2;
                }
              }
            }
            _free(pvVar8);
          }
        }
      }
      if (pvVar6 != (id)0x0) {
        return (int)pvVar6;
      }
    }
    iVar5 = 0;
    if (expirationTime != (double *)0x0) {
      *expirationTime = local_1c;
    }
    if (creationTime != (double *)0x0) {
      *creationTime = dVar1;
    }
    if (usageTimeFlags != (int *)0x0) {
      *usageTimeFlags = local_20;
    }
    if (type != (int *)0x0) {
      *type = iVar4;
    }
  }
  return iVar5;
}

*/
- (NSInteger)license:(struct SLLicense *)aLicense expirationTime:(double *)aTime creationTime:(double *)aTime2 usageTimeFlags:(int *)aFlags type:(int *)aType
{
    int licenseType = SLLicenseGetType(aLicense);
    double creationTime = SLLicenseGetCreationDate(aLicense);
    if (licenseType == 0 || creationTime == 0.0) {
        return 1;
    }
    double expirationTime = 0.0;
    int usageFlags = 0;
    if (licenseType == 3) {
        NSDate *trialEnd = [[NSCalendarDate dateWithTimeIntervalSinceReferenceDate:creationTime] dateByAddingYears:0 months:0 days:30 hours:0 minutes:0 seconds:0];
        expirationTime = [trialEnd timeIntervalSinceReferenceDate];
        if (expirationTime == 0.0) {
            expirationTime = creationTime + 2592000.0;
        }
        usageFlags = 3;
    }
    else {
        if (licenseType - 1U > 1) {
            return 1;
        }
        NSInteger error;
        uint32_t primarySize = 0;
        error = SLLicenseGetUserData(aLicense, NULL, &primarySize);
        if (error == 0) {
            uint32_t secondarySize = 0;
            error = SLLicenseGetSerialUserData(aLicense, NULL, &secondarySize);
            if (error == 0) {
                uint32_t maxSize = MAX(primarySize, secondarySize);
                void *bytes;
                if (maxSize != 0 && (bytes = malloc(maxSize)) != NULL) {
                    if ((secondarySize == 0 || ((error = SLLicenseGetSerialUserData(aLicense, bytes, &secondarySize)) == 0 && (error = [self LUUserDataValidation_validateUserBytes:bytes bytesSize:secondarySize licenseCreationTime:creationTime expirationTime:&expirationTime usageTimeFlags:&usageFlags]) == 0)) && primarySize != 0 && (error = SLLicenseGetUserData(aLicense, bytes, &primarySize)) == 0) {
                        double otherExpiration = 0.0;
                        error = [self LUUserDataValidation_validateUserBytes:bytes bytesSize:primarySize licenseCreationTime:creationTime expirationTime:&otherExpiration usageTimeFlags:&usageFlags];
                        if (error == 0) {
                            if (otherExpiration != 0.0 && (expirationTime == 0.0 || otherExpiration < expirationTime)) {
                                expirationTime = otherExpiration;
                            }
                        }
                    }
                    free(bytes);
                }
            }
        }
        if (error != 0) {
            return error;
        }
    }
    if (aTime != NULL) {
        *aTime = expirationTime;
    }
    if (aTime2 != NULL) {
        *aTime2 = creationTime;
    }
    if (aFlags != NULL) {
        *aFlags = usageFlags;
    }
    if (aType != NULL) {
        *aType = licenseType;
    }
    return 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024dcbd @ 0024dcbd, 660 bytes * /

int FUN_0024dcbd(LUUserDataValidation *self,SEL _cmd,void *LUUserDataValidation_validateUserBytes,
                uint bytesSize,double licenseCreationTime,double *expirationTime,int *usageTimeFlags
                )

{
  int iVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  uint uVar5;
  uint *puVar6;
  double dVar7;
  undefined4 uVar8;
  undefined4 uVar9;
  undefined4 uVar10;
  uint local_24;
  char *local_20;
  undefined4 local_1c;
  undefined4 local_18;
  
  local_24 = 0xc;
  local_20 = "Network limited";
  local_1c = 0xf;
  local_18 = 8;
  uVar5 = 0;
  puVar6 = &local_24;
  while ((uVar5 < 2 &&
         ((puVar6[-1] != bytesSize ||
          (iVar1 = _memcmp((void *)puVar6[-2],LUUserDataValidation_validateUserBytes,bytesSize),
          iVar1 != 0))))) {
    puVar6 = puVar6 + 3;
    uVar5 = uVar5 + 1;
  }
  if (uVar5 == 2) {
    pvVar2 = _objc_msgSend(cls_NSData,sel_alloc);
    pvVar2 = _objc_msgSend(pvVar2,sel_initWithBytesNoCopy_length_freeWhenDone_,
                           LUUserDataValidation_validateUserBytes,bytesSize,0);
    uVar10 = 0;
    uVar9 = 0;
    uVar8 = 0;
    pvVar3 = _objc_msgSend(cls_NSPropertyListSerialization,
                           sel_propertyListFromData_mutabilityOption_format_errorDescription_,pvVar2
                           ,0,0,0);
    _objc_msgSend(pvVar2,sel_release);
    pvVar2 = _objc_msgSend(cls_NSDate,sel_class);
    pvVar4 = _objc_msgSend(pvVar3,sel_isKindOfClass_,pvVar2);
    if ((char)pvVar4 == '\0') {
      pvVar2 = _objc_msgSend(cls_NSDictionary,sel_class,pvVar2,uVar8,uVar9,uVar10);
      pvVar2 = _objc_msgSend(pvVar3,sel_isKindOfClass_,pvVar2);
      if ((char)pvVar2 != '\0') {
        pvVar2 = _objc_msgSend(pvVar3,sel_objectForKey_,&cfstr_HSTrialRefDate);
        pvVar4 = _objc_msgSend(cls_NSDate,sel_class);
        pvVar4 = _objc_msgSend(pvVar2,sel_isKindOfClass_,pvVar4);
        if ((char)pvVar4 != '\0') {
          dVar7 = _objc_msgSend_fpret(pvVar2,sel_timeIntervalSinceReferenceDate);
          *expirationTime = licenseCreationTime + dVar7;
          *(byte *)usageTimeFlags = (byte)*usageTimeFlags | 1;
          pvVar2 = _objc_msgSend(pvVar3,sel_objectForKey_,&cfstr_HSIsTrialRefFinal);
          pvVar3 = _objc_msgSend(cls_NSNumber,sel_class);
          pvVar4 = _objc_msgSend(pvVar2,sel_isKindOfClass_,pvVar3);
          if (((char)pvVar4 != '\0') &&
             (pvVar2 = _objc_msgSend(pvVar2,sel_boolValue,pvVar3), (char)pvVar2 != '\0')) {
            return 0;
          }
          *(byte *)usageTimeFlags = (byte)*usageTimeFlags | 2;
          return 0;
        }
      }
      return 1;
    }
    dVar7 = _objc_msgSend_fpret(pvVar3,sel_timeIntervalSinceReferenceDate);
    *expirationTime = dVar7;
    *(byte *)usageTimeFlags = (byte)*usageTimeFlags | 1;
  }
  else {
    *usageTimeFlags = *usageTimeFlags | *puVar6;
  }
  return 0;
}

*/
- (NSInteger)LUUserDataValidation_validateUserBytes:(void *)aBytes bytesSize:(NSUInteger)aSize licenseCreationTime:(double)aTime expirationTime:(double *)aTime2 usageTimeFlags:(int *)aFlags
{
    static const struct { const char *bytes; NSUInteger length; uint8_t flags; } knownUserData[2] = {
        { "Online Activation", 17, 0xc },
        { "Network limited", 15, 8 },
    };
    NSUInteger index = 0;
    while (index < 2 && (knownUserData[index].length != aSize || memcmp(knownUserData[index].bytes, aBytes, aSize) != 0)) {
        index++;
    }
    if (index != 2) {
        *(uint8_t *)aFlags |= knownUserData[index].flags;
        return 0;
    }
    NSData *data = [[NSData alloc] initWithBytesNoCopy:aBytes length:aSize freeWhenDone:NO];
    id plist = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:0 format:NULL errorDescription:NULL];
    [data release];
    if ([plist isKindOfClass:[NSDate class]]) {
        *aTime2 = [plist timeIntervalSinceReferenceDate];
        *(uint8_t *)aFlags |= 1;
        return 0;
    }
    if (![plist isKindOfClass:[NSDictionary class]]) {
        return 1;
    }
    id refDate = [plist objectForKey:@"HSTrialRefDate"];
    if (![refDate isKindOfClass:[NSDate class]]) {
        return 1;
    }
    *aTime2 = aTime + [refDate timeIntervalSinceReferenceDate];
    *(uint8_t *)aFlags |= 1;
    id isFinal = [plist objectForKey:@"HSIsTrialRefFinal"];
    if (!([isFinal isKindOfClass:[NSNumber class]] && [isFinal boolValue])) {
        *(uint8_t *)aFlags |= 2;
    }
    return 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024df51 @ 0024df51, 379 bytes * /

void FUN_0024df51(LUUserDataValidation *self,SEL _cmd,double saveCurrentApplicationSessionDateForKey
                 )

{
  id pvVar1;
  double dVar2;
  undefined8 uVar3;
  undefined4 uVar4;
  uint local_124;
  uint uStack_120;
  uint local_11c;
  uint uStack_118;
  undefined1 local_10c [80];
  uint local_bc;
  uint local_b8;
  uint local_a4;
  uint local_a0;
  uint local_8c;
  uint local_88;
  uint local_74;
  uint local_70;
  
  dVar2 = _objc_msgSend_fpret(cls_NSDate,sel_timeIntervalSinceReferenceDate);
  pvVar1 = _objc_msgSend(self,sel_loadLastApplicationSessionDateForKey_,
                         saveCurrentApplicationSessionDateForKey);
  if (((char)pvVar1 == '\0') || (self->_lastSessionDate <= dVar2 && dVar2 != self->_lastSessionDate)
     ) {
    local_11c = SUB84(saveCurrentApplicationSessionDateForKey,0);
    uStack_118 = (uint)((ulonglong)saveCurrentApplicationSessionDateForKey >> 0x20);
    local_a0 = local_11c >> 0x18 | (local_11c & 0xff0000) >> 8 | (local_11c & 0xff00) << 8 |
               local_11c << 0x18;
    local_a4 = uStack_118 >> 0x18 | (uStack_118 & 0xff0000) >> 8 | (uStack_118 & 0xff00) << 8 |
               uStack_118 << 0x18;
    local_124 = SUB84(dVar2,0);
    uStack_120 = (uint)((ulonglong)dVar2 >> 0x20);
    local_b8 = local_124 >> 0x18 | (local_124 & 0xff0000) >> 8 | (local_124 & 0xff00) << 8 |
               local_124 << 0x18;
    local_bc = uStack_120 >> 0x18 | (uStack_120 & 0xff0000) >> 8 | (uStack_120 & 0xff00) << 8 |
               uStack_120 << 0x18;
    uVar4 = 0;
    local_8c = local_bc;
    local_88 = local_b8;
    local_74 = local_a4;
    local_70 = local_a0;
    pvVar1 = _objc_msgSend(cls_NSData,sel_dataWithBytesNoCopy_length_freeWhenDone_,local_10c,0x100,0
                          );
    uVar3 = CONCAT44(1,self->_dateStoragePath);
    pvVar1 = _objc_msgSend(pvVar1,sel_writeToFile_atomically_,self->_dateStoragePath,1);
    if ((char)pvVar1 != '\0') {
      pvVar1 = _objc_msgSend(cls_NSFileManager,sel_defaultManager,uVar3,uVar4);
      _objc_msgSend(pvVar1,sel_changeFileAttributes_atPath_,self->_dateStoragePermissions,
                    self->_dateStoragePath);
    }
    self->_lastSessionDate = dVar2;
  }
  return;
}

*/
- (void)saveCurrentApplicationSessionDateForKey:(double)aKey
{
    double now = [NSDate timeIntervalSinceReferenceDate];
    if (![self loadLastApplicationSessionDateForKey:aKey] || _lastSessionDate < now) {
        uint8_t buffer[0x100];
        memset(buffer, 0, sizeof(buffer));
        LUWriteBEDouble(buffer + 0x68, aKey);
        LUWriteBEDouble(buffer + 0x98, aKey);
        LUWriteBEDouble(buffer + 0x50, now);
        LUWriteBEDouble(buffer + 0x80, now);
        NSData *data = [NSData dataWithBytesNoCopy:buffer length:sizeof(buffer) freeWhenDone:NO];
        if ([data writeToFile:_dateStoragePath atomically:YES]) {
            [[NSFileManager defaultManager] changeFileAttributes:_dateStoragePermissions atPath:_dateStoragePath];
        }
        _lastSessionDate = now;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024e0cc @ 0024e0cc, 322 bytes * /

BOOL FUN_0024e0cc(LUUserDataValidation *self,SEL _cmd,double loadLastApplicationSessionDateForKey)

{
  uint uVar1;
  uint uVar2;
  uint uVar3;
  uint uVar4;
  double dVar5;
  double dVar6;
  BOOL BVar7;
  id pvVar8;
  id pvVar9;
  id pvVar10;
  
  if (self->_lastSessionDate == 0.0) {
    pvVar8 = _objc_msgSend(cls_NSData,sel_alloc);
    pvVar10 = self->_dateStoragePath;
    pvVar8 = _objc_msgSend(pvVar8,sel_initWithContentsOfMappedFile_,pvVar10);
    pvVar8 = _objc_msgSend(pvVar8,sel_autorelease);
    pvVar9 = _objc_msgSend(pvVar8,sel_length);
    if ((pvVar9 == (id)0x100) &&
       (pvVar10 = _objc_msgSend(pvVar8,sel_bytes,pvVar10), pvVar10 != (id)0x0)) {
      uVar1 = *(uint *)((int)pvVar10 + 0x68);
      uVar2 = *(uint *)((int)pvVar10 + 0x6c);
      uVar3 = *(uint *)((int)pvVar10 + 0x98);
      uVar4 = *(uint *)((int)pvVar10 + 0x9c);
      dVar5 = (double)CONCAT44(uVar1 >> 0x18 | (uVar1 & 0xff0000) >> 8 | (uVar1 & 0xff00) << 8 |
                               uVar1 << 0x18,
                               uVar2 >> 0x18 | (uVar2 & 0xff0000) >> 8 | (uVar2 & 0xff00) << 8 |
                               uVar2 << 0x18);
      if ((double)CONCAT44(uVar3 >> 0x18 | (uVar3 & 0xff0000) >> 8 | (uVar3 & 0xff00) << 8 |
                           uVar3 << 0x18,
                           uVar4 >> 0x18 | (uVar4 & 0xff0000) >> 8 | (uVar4 & 0xff00) << 8 |
                           uVar4 << 0x18) == dVar5) {
        if ((dVar5 == loadLastApplicationSessionDateForKey) &&
           (!NAN(dVar5) && !NAN(loadLastApplicationSessionDateForKey))) {
          uVar1 = *(uint *)((int)pvVar10 + 0x50);
          uVar2 = *(uint *)((int)pvVar10 + 0x54);
          uVar3 = *(uint *)((int)pvVar10 + 0x80);
          uVar4 = *(uint *)((int)pvVar10 + 0x84);
          dVar6 = (double)CONCAT44(uVar1 >> 0x18 | (uVar1 & 0xff0000) >> 8 | (uVar1 & 0xff00) << 8 |
                                   uVar1 << 0x18,
                                   uVar2 >> 0x18 | (uVar2 & 0xff0000) >> 8 | (uVar2 & 0xff00) << 8 |
                                   uVar2 << 0x18);
          dVar5 = (double)CONCAT44(uVar3 >> 0x18 | (uVar3 & 0xff0000) >> 8 | (uVar3 & 0xff00) << 8 |
                                   uVar3 << 0x18,
                                   uVar4 >> 0x18 | (uVar4 & 0xff0000) >> 8 | (uVar4 & 0xff00) << 8 |
                                   uVar4 << 0x18);
          if ((dVar5 == dVar6) && (!NAN(dVar5) && !NAN(dVar6))) {
            self->_lastSessionDate = dVar6;
            return '\x01';
          }
        }
      }
    }
    BVar7 = '\0';
  }
  else {
    BVar7 = '\x01';
  }
  return BVar7;
}

*/
- (BOOL)loadLastApplicationSessionDateForKey:(double)aKey
{
    if (_lastSessionDate != 0.0) {
        return YES;
    }
    NSData *data = [[[NSData alloc] initWithContentsOfMappedFile:_dateStoragePath] autorelease];
    if ([data length] == 0x100) {
        const uint8_t *bytes = [data bytes];
        if (bytes != NULL) {
            double key = LUReadBEDouble(bytes + 0x68);
            if (LUReadBEDouble(bytes + 0x98) == key && key == aKey) {
                double date = LUReadBEDouble(bytes + 0x50);
                if (LUReadBEDouble(bytes + 0x80) == date && !isnan(date)) {
                    _lastSessionDate = date;
                    return YES;
                }
            }
        }
    }
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024e20e @ 0024e20e, 265 bytes * /

id FUN_0024e20e(LUUserDataValidation *self,SEL _cmd,id LUUserDataValidation_initWithDateStoragePath)

{
  LUUserDataValidation *pLVar1;
  id pvVar2;
  id pvVar3;
  undefined4 uVar4;
  undefined4 uVar5;
  LUUserDataValidation *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_NSObject_00355d60;
  pLVar1 = _objc_msgSendSuper(&local_14,sel_init);
  if ((pLVar1 != (LUUserDataValidation *)0x0) &&
     (LUUserDataValidation_initWithDateStoragePath != (id)0x0)) {
    pvVar2 = _objc_msgSend(cls_NSDictionary,sel_alloc);
    pvVar3 = _objc_msgSend(cls_NSNumber,sel_numberWithUnsignedLong_,0x180);
    uVar4 = *(undefined4 *)PTR_003368dc;
    uVar5 = 0;
    pvVar2 = _objc_msgSend(pvVar2,sel_initWithObjectsAndKeys_,pvVar3,uVar4,0);
    pLVar1->_dateStoragePermissions = pvVar2;
    if (pvVar2 != (id)0x0) {
      pvVar2 = _objc_msgSend(LUUserDataValidation_initWithDateStoragePath,sel_retain,pvVar3,uVar4,
                             uVar5);
      pLVar1->_dateStoragePath = pvVar2;
      *(undefined4 *)((int)&pLVar1->_lastSessionDate + 4) = 0;
      *(undefined4 *)&pLVar1->_lastSessionDate = 0;
      return pLVar1;
    }
  }
  local_10 = PTR_s_NSObject_00355d60;
  local_14 = pLVar1;
  _objc_msgSendSuper(&local_14,sel_release);
  return (id)0x0;
}

*/
- (id)LUUserDataValidation_initWithDateStoragePath:(id)aPath
{
    self = [super init];
    if (self != nil && aPath != nil) {
        _dateStoragePermissions = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithUnsignedLong:0x180], NSFilePosixPermissions, nil];
        if (_dateStoragePermissions != nil) {
            _dateStoragePath = [aPath retain];
            _lastSessionDate = 0;
            return self;
        }
    }
    [self release];
    return nil;
}

- (id)init
{
    [super release];
    return nil;
}

- (void)dealloc
{
    [_dateStoragePermissions release];
    [_dateStoragePath release];
    [super dealloc];
}

@end

