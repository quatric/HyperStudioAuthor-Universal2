#import "HSNetworkBlocker.h"

@implementation HSNetworkBlocker

/* i386 ivar offsets: _identifier=0x4, _licenseType=0x8, _allowedCount=0xc, _blockingRegistrations=0x10, _information=0x14 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024a11a @ 0024a11a, 1034 bytes * /

void FUN_0024a11a(HSNetworkBlocker *self,SEL _cmd,id HSNetworkBlocker_connectionDataRead)

{
  uint *puVar1;
  uint uVar2;
  uint uVar3;
  id self_00;
  id pvVar4;
  id pvVar5;
  uint *puVar6;
  int iVar7;
  int iVar8;
  uint uVar9;
  uint uVar10;
  uint uVar11;
  cfstringStruct *pcVar12;
  undefined4 uVar13;
  int local_74 [23];
  id local_18;
  HSNetworkBlocker *local_14;
  
  local_14 = self;
  local_18 = HSNetworkBlocker_connectionDataRead;
  self_00 = _objc_msgSend(HSNetworkBlocker_connectionDataRead,sel_object);
  pvVar4 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  uVar13 = *(undefined4 *)PTR_003368b4;
  pvVar5 = self_00;
  _objc_msgSend(pvVar4,sel_removeObserver_name_object_,local_14,uVar13,self_00);
  pvVar4 = _objc_msgSend(local_18,sel_userInfo);
  pcVar12 = &cfstr_NSFileHandleError;
  pvVar4 = _objc_msgSend(pvVar4,sel_objectForKey_,&cfstr_NSFileHandleError);
  pvVar4 = _objc_msgSend(pvVar4,sel_intValue);
  if (pvVar4 != (id)0x0) {
    return;
  }
  pvVar5 = _objc_msgSend(local_18,sel_userInfo,pcVar12,uVar13,pvVar5);
  pvVar5 = _objc_msgSend(pvVar5,sel_objectForKey_,*(undefined4 *)PTR_003368b0);
  pvVar4 = _objc_msgSend(pvVar5,sel_length);
  puVar6 = _objc_msgSend(pvVar5,sel_bytes);
  if (puVar6 == (uint *)0x0) {
    return;
  }
  if (pvVar4 < (id)0xc) {
    return;
  }
  uVar9 = *puVar6;
  pvVar5 = (id)(uVar9 >> 0x18 | (uVar9 & 0xff0000) >> 8 | (uVar9 & 0xff00) << 8 | uVar9 << 0x18);
  if (pvVar5 < pvVar4) {
    return;
  }
  uVar9 = (int)pvVar5 - 0xc;
  puVar1 = puVar6 + 3;
  if (puVar6[1] != 0x66446d56) {
    return;
  }
  if (puVar6[2] != 0x1000000) {
    return;
  }
  if (puVar1 == (uint *)0x0) {
    return;
  }
  if (uVar9 < 0x10) {
    return;
  }
  uVar2 = puVar6[3];
  uVar3 = puVar6[4];
  uVar10 = puVar6[5];
  if (uVar10 == 0) {
    return;
  }
  uVar11 = puVar6[6];
  if (uVar11 == 0) {
    return;
  }
  uVar11 = uVar11 >> 0x18 | (uVar11 & 0xff0000) >> 8 | (uVar11 & 0xff00) << 8 | uVar11 << 0x18;
  uVar10 = uVar10 >> 0x18 | (uVar10 & 0xff0000) >> 8 | (uVar10 & 0xff00) << 8 | uVar10 << 0x18;
  if (uVar9 < uVar11 + 0x10 + uVar10) {
    return;
  }
  if (*(char *)((int)puVar6 + uVar10 + 0x1b) != '\0') {
    return;
  }
  if (*(char *)((int)puVar1 + uVar11 + uVar10 + 0xf) != '\0') {
    return;
  }
  if ((uVar2 >> 0x18 | (uVar2 & 0xff0000) >> 8 | (uVar2 & 0xff00) << 8 | uVar2 << 0x18) !=
      local_14->_allowedCount) {
    return;
  }
  if ((uVar3 >> 0x18 | (uVar3 & 0xff0000) >> 8 | (uVar3 & 0xff00) << 8 | uVar3 << 0x18) !=
      local_14->_licenseType) {
    return;
  }
  pvVar5 = _objc_msgSend(cls_NSString,sel_stringWithUTF8String_,puVar6 + 7);
  pvVar5 = _objc_msgSend(pvVar5,sel_isEqualToString_,local_14->_identifier);
  if ((char)pvVar5 == '\0') {
    return;
  }
  uVar13 = 0x1e;
  pvVar5 = _objc_msgSend(cls_NSString,sel_stringWithCString_encoding_,(int)puVar1 + uVar10 + 0x10,
                         0x1e);
  pvVar4 = _objc_msgSend(local_14->_blockingRegistrations,sel_objectForKey_,pvVar5);
  if (pvVar4 == (id)0x0) {
    return;
  }
  _objc_exception_try_enter(local_74);
  iVar7 = __setjmp(local_74);
  if (iVar7 == 0) {
    pvVar5 = _objc_msgSend(local_14,sel_HSNetworkBlocker_blockingMessage,pvVar5,uVar13);
    _objc_msgSend(self_00,sel_writeData_,pvVar5);
  }
  else {
    iVar8 = _objc_exception_extract(local_74);
    _objc_exception_try_enter(local_74);
    iVar7 = __setjmp(local_74);
    if (iVar7 == 0) {
      iVar7 = _objc_exception_match(cls_NSException,iVar8);
      if (iVar7 != 0) goto LAB_0024a4b6;
      _objc_exception_try_exit(local_74);
    }
    else {
      iVar8 = _objc_exception_extract(local_74);
    }
    if (iVar8 != 0) {
                    /* WARNING: Subroutine does not return * /
      _objc_exception_throw(iVar8);
    }
  }
LAB_0024a4b6:
  _objc_exception_try_exit(local_74);
  _objc_msgSend(self_00,sel_closeFile,pvVar5);
  return;
}

*/
- (void)HSNetworkBlocker_connectionDataRead:(id)aRead
{
    id fileHandle = [aRead object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadCompletionNotification object:fileHandle];
    if ([[[aRead userInfo] objectForKey:@"NSFileHandleError"] intValue] != 0) {
        return;
    }
    NSData *data = [[aRead userInfo] objectForKey:NSFileHandleNotificationDataItem];
    NSUInteger length = [data length];
    const uint32_t *words = [data bytes];
    if (words == NULL || length < 0xc) {
        return;
    }
    uint32_t total = ntohl(words[0]);
    if (total < length) {
        return;
    }
    uint32_t remaining = total - 0xc;
    if (words[1] != 0x66446d56 || words[2] != 0x1000000 || remaining < 0x10) {
        return;
    }
    if (words[5] == 0 || words[6] == 0) {
        return;
    }
    uint32_t identifierLength = ntohl(words[5]);
    uint32_t networkIdentifierLength = ntohl(words[6]);
    const char *bytes = (const char *)words;
    if (remaining < networkIdentifierLength + 0x10 + identifierLength) {
        return;
    }
    if (bytes[identifierLength + 0x1b] != '\0' || bytes[networkIdentifierLength + identifierLength + 0x1b] != '\0') {
        return;
    }
    if (ntohl(words[3]) != _allowedCount || ntohl(words[4]) != _licenseType) {
        return;
    }
    if (![[NSString stringWithUTF8String:(const char *)(words + 7)] isEqualToString:_identifier]) {
        return;
    }
    NSString *blockedIdentifier = [NSString stringWithCString:bytes + identifierLength + 0x1c encoding:NSMacOSRomanStringEncoding];
    if ([_blockingRegistrations objectForKey:blockedIdentifier] == nil) {
        return;
    }
    @try {
        [(NSFileHandle *)fileHandle writeData:[self HSNetworkBlocker_blockingMessage]];
    }
    @catch (NSException *exception) {
    }
    [fileHandle closeFile];
}

- (id)HSNetworkBlocker_blockingMessage
{
    id pvVar1;
    int *puVar2;
    id pvVar1_2;

    pvVar1 = _information;
    if (pvVar1 == nil) {
        pvVar1_2 = [NSMutableData alloc];
        pvVar1 = [pvVar1_2 initWithLength:0x18];
        puVar2 = [pvVar1 mutableBytes];
        if (puVar2 == NULL) {
            [pvVar1 release];
            pvVar1 = _information;
        }
        else {
            puVar2[3] = 0x416d7254;
            puVar2[4] = 0;
            puVar2[5] = 0;
            *puVar2 = 0x18000000;
            puVar2[1] = 0x66446441;
            puVar2[2] = 0x1000000;
            _information = pvVar1;
        }
    }
    return pvVar1;
}

- (void)HSNetworkBlocker_connectionDataAvailable:(id)aAvailable
{
    id self_00;

    self_00 = [aAvailable object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleDataAvailableNotification object:self_00];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSNetworkBlocker_connectionDataRead:) name:NSFileHandleReadCompletionNotification object:self_00];
    [self_00 readInBackgroundAndNotify];
}

- (void)listeningConnection:(id)aConnection isEstablishedForItem:(id)aItem properties:(id)aProperties
{
    if ([_blockingRegistrations objectForKey:[aItem identifier]] != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSNetworkBlocker_connectionDataAvailable:) name:NSFileHandleDataAvailableNotification object:aConnection];
        [aConnection waitForDataInBackgroundAndNotify];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024a757 @ 0024a757, 105 bytes * /

void FUN_0024a757(HSNetworkBlocker *self,SEL _cmd,id networkItem,id didFindConnectionItem)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(didFindConnectionItem,sel_isProvider);
  if ((char)pvVar1 == '\0') {
    _objc_msgSend(didFindConnectionItem,sel_setDelegate_,self);
    _objc_msgSend(didFindConnectionItem,sel_establishListeningConnectionWithTimeout_,0,0x40140000);
  }
  return;
}

*/
- (void)networkItem:(id)aItem didFindConnectionItem:(id)aItem2
{
    if (![(id<SRConnectionItem>)aItem2 isProvider]) {
        [(id<SRConnectionItem>)aItem2 setDelegate:self];
        [(id<SRConnectionItem>)aItem2 establishListeningConnectionWithTimeout:5.0];
    }
}

- (void)monitoringDidFinishedForItem:(id)aItem withError:(NSInteger)aError
{
    NSString *pvVar1;
    id pvVar2_2;

    pvVar1 = [aItem identifier];
    pvVar2_2 = [[_blockingRegistrations objectForKey:pvVar1] retain];
    [_blockingRegistrations removeObjectForKey:pvVar1];
    [pvVar2_2 autorelease];
}

- (void)stopBlocking
{
    NSArray *self_00;
    id self_01;
    NSUInteger pvVar1_2;

    if ([_blockingRegistrations count] != 0) {
        self_00 = [_blockingRegistrations allValues];
        [_blockingRegistrations removeAllObjects];
        pvVar1_2 = [self_00 count];
        while (pvVar1_2 != 0) {
            pvVar1_2 = (pvVar1_2 + -1);
            self_01 = [self_00 objectAtIndex:pvVar1_2];
            [self_01 setDelegate:0];
            [self_01 stopMonitoring];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024a919 @ 0024a919, 374 bytes * /

int FUN_0024a919(HSNetworkBlocker *self,SEL _cmd,id blockIdentifier)

{
  id pvVar1;
  HSNetworkBlocker *self_00;
  int iVar2;
  HSNetworkBlocker *pHVar3;
  
  if (self->_blockingRegistrations == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSMutableDictionary,sel_new);
    self->_blockingRegistrations = pvVar1;
    if (pvVar1 == (id)0x0) {
      return 1;
    }
  }
  pvVar1 = _objc_msgSend(cls_NSString,sel_alloc);
  self_00 = _objc_msgSend(pvVar1,sel_initWithFormat_,&cfstr______tcp_,blockIdentifier);
  pvVar1 = _objc_msgSend(self_00,sel_length);
  if (pvVar1 == (id)0x0) {
    return 1;
  }
  pHVar3 = self_00;
  pvVar1 = _objc_msgSend(self->_blockingRegistrations,sel_objectForKey_,self_00,blockIdentifier);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_SRNetworkItem,sel_alloc,pHVar3,blockIdentifier);
    pHVar3 = self_00;
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithIdentifier_,self_00);
    if (pvVar1 == (id)0x0) {
      iVar2 = 1;
      goto LAB_0024aa6c;
    }
    _objc_msgSend(self->_blockingRegistrations,sel_setObject_forKey_,pvVar1,self_00);
    _objc_msgSend(pvVar1,sel_setDelegate_,self);
    _objc_msgSend(pvVar1,sel_startMonitoring);
    _objc_msgSend(pvVar1,sel_release);
    pHVar3 = self;
  }
  iVar2 = 0;
LAB_0024aa6c:
  _objc_msgSend(self_00,sel_release,pHVar3);
  return iVar2;
}

*/
- (NSInteger)blockIdentifier:(id)aIdentifier
{
    if (_blockingRegistrations == nil) {
        _blockingRegistrations = [[NSMutableDictionary alloc] init];
        if (_blockingRegistrations == nil) {
            return 1;
        }
    }
    NSString *serviceType = [[NSString alloc] initWithFormat:@"_%@._tcp.", aIdentifier];
    if ([serviceType length] == 0) {
        // Fix: the original leaked serviceType here.
        [serviceType release];
        return 1;
    }
    NSInteger result = 0;
    if ([_blockingRegistrations objectForKey:serviceType] == nil) {
        SRNetworkItem *item = [[SRNetworkItem alloc] initWithIdentifier:serviceType];
        if (item == nil) {
            result = 1;
        }
        else {
            [_blockingRegistrations setObject:item forKey:serviceType];
            [item setDelegate:self];
            [item startMonitoring];
            [item release];
        }
    }
    [serviceType release];
    return result;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_blockingRegistrations release];
    [_information release];
    [_identifier release];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024a0b3 @ 0024a0b3, 103 bytes * /

id FUN_0024a0b3(HSNetworkBlocker *self,SEL _cmd,id initWithBundleIdentifier,uint licenseType,
               uint allowedCount)

{
  id pvVar1;
  id pvVar2;
  HSNetworkBlocker *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_NSObject_00355bb0;
  pvVar1 = _objc_msgSendSuper(&local_1c,sel_init);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(initWithBundleIdentifier,sel_retain);
    *(id *)((int)pvVar1 + 4) = pvVar2;
    *(uint *)((int)pvVar1 + 8) = licenseType;
    *(uint *)((int)pvVar1 + 0xc) = allowedCount;
  }
  return pvVar1;
}

*/
- (id)initWithBundleIdentifier:(id)aIdentifier licenseType:(NSUInteger)aType allowedCount:(NSUInteger)aCount
{
    self = [super init];
    if (self != nil) {
        _identifier = [aIdentifier retain];
        _licenseType = aType;
        _allowedCount = aCount;
    }
    return self;
}

@end

@implementation HSNetworkRegistrar

/* i386 ivar offsets: _identifier=0x4, _licenseType=0x8, _networkRegistration=0xc, _registrationConnection=0x10, _infoRegistration=0x14, _infoConnection=0x18, _allowedRegistrationCount=0x1c, _registrationCount=0x20, _verificationInfo=0x24, _infoMessage=0x28, _dataAccumulator=0x2c, _accumulationLimit=0x30, _networkBlocker=0x34, _isRegistered=0x38, _isCalcuationFinished=0x38, _isOwnConnectionProcessed=0x38 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_00248798 @ 00248798, 607 bytes * /

void FUN_00248798(HSNetworkRegistrar *self,SEL _cmd,id providingConnection,id isEstablishedForItem,
                 id properties)

{
  id pvVar1;
  id pvVar2;
  int iVar3;
  int iVar4;
  SEL op;
  int local_74 [22];
  id local_1c;
  id local_18;
  HSNetworkRegistrar *local_14;
  
  local_14 = self;
  local_18 = providingConnection;
  local_1c = isEstablishedForItem;
  if (isEstablishedForItem == self->_registrationConnection) {
    pvVar1 = _objc_msgSend(self,sel_HSNetworkRegistrar_verificationInfo);
    pvVar2 = _objc_msgSend(pvVar1,sel_length);
    op = sel_closeFile;
    if (pvVar2 != (id)0x0) {
      _objc_exception_try_enter(local_74);
      iVar3 = __setjmp(local_74);
      if (iVar3 == 0) {
        _objc_msgSend(local_18,sel_writeData_,pvVar1);
        pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
        _objc_msgSend(pvVar1,sel_addObserver_selector_name_object_,local_14,
                      sel_HSNetworkRegistrar_adminMessageReceived_,*(undefined4 *)PTR_003368b8,
                      local_18);
        _objc_msgSend(local_18,sel_readToEndOfFileInBackgroundAndNotify);
      }
      else {
        iVar4 = _objc_exception_extract(local_74);
        _objc_exception_try_enter(local_74);
        iVar3 = __setjmp(local_74);
        if (iVar3 == 0) {
          iVar3 = _objc_exception_match(cls_NSException,iVar4);
          if (iVar3 != 0) {
            _objc_msgSend(local_18,sel_closeFile);
            goto LAB_00248913;
          }
          _objc_exception_try_exit(local_74);
        }
        else {
          iVar4 = _objc_exception_extract(local_74);
        }
        if (iVar4 != 0) {
                    /* WARNING: Subroutine does not return * /
          _objc_exception_throw(iVar4);
        }
      }
LAB_00248913:
      _objc_exception_try_exit(local_74);
      return;
    }
  }
  else {
    op = sel_closeFile;
    if (isEstablishedForItem == self->_infoConnection) {
      _objc_msgSend(self->_dataAccumulator,sel_release);
      local_14->_dataAccumulator = (id)0x0;
      local_14->_accumulationLimit = 0;
      pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
      _objc_msgSend(pvVar1,sel_addObserver_selector_name_object_,local_14,
                    sel_HSNetworkRegistrar_verificationMessageReceived_,*(undefined4 *)PTR_003368b4,
                    local_18);
      op = sel_readInBackgroundAndNotify;
    }
  }
  _objc_msgSend(local_18,op);
  return;
}

*/
- (void)providingConnection:(id)aConnection isEstablishedForItem:(id)aItem properties:(id)aProperties
{
    if (aItem == _registrationConnection) {
        NSData *info = [self HSNetworkRegistrar_verificationInfo];
        if ([info length] != 0) {
            @try {
                [(NSFileHandle *)aConnection writeData:info];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSNetworkRegistrar_adminMessageReceived:) name:NSFileHandleReadToEndOfFileCompletionNotification object:aConnection];
                [aConnection readToEndOfFileInBackgroundAndNotify];
            }
            @catch (NSException *exception) {
                [aConnection closeFile];
            }
            return;
        }
    }
    else if (aItem == _infoConnection) {
        [_dataAccumulator release];
        _dataAccumulator = nil;
        _accumulationLimit = 0;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSNetworkRegistrar_verificationMessageReceived:) name:NSFileHandleReadCompletionNotification object:aConnection];
        [aConnection readInBackgroundAndNotify];
        return;
    }
    [aConnection closeFile];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002489f7 @ 002489f7, 1877 bytes * /

void FUN_002489f7(HSNetworkRegistrar *self,SEL _cmd,
                 id HSNetworkRegistrar_verificationMessageReceived)

{
  bool bVar1;
  HSNetworkRegistrar *pHVar2;
  id self_00;
  id pvVar3;
  cfstringStruct *pcVar4;
  uint *puVar5;
  uint uVar6;
  cfstringStruct *pcVar7;
  char *pcVar8;
  size_t sVar9;
  char *pcVar10;
  size_t sVar11;
  id pvVar12;
  int iVar13;
  int iVar14;
  uint uVar15;
  uint uVar16;
  undefined4 uVar17;
  id local_84;
  int local_74 [23];
  id local_18;
  HSNetworkRegistrar *local_14;
  
  local_14 = self;
  local_18 = HSNetworkRegistrar_verificationMessageReceived;
  self_00 = _objc_msgSend(HSNetworkRegistrar_verificationMessageReceived,sel_object);
  bVar1 = false;
  pvVar3 = _objc_msgSend(local_18,sel_userInfo);
  pcVar7 = &cfstr_NSFileHandleError;
  pvVar3 = _objc_msgSend(pvVar3,sel_objectForKey_,&cfstr_NSFileHandleError);
  pvVar3 = _objc_msgSend(pvVar3,sel_intValue);
  if (pvVar3 != (id)0x0) goto LAB_0024909c;
  pvVar3 = _objc_msgSend(local_18,sel_userInfo,pcVar7);
  pcVar7 = *(cfstringStruct **)PTR_003368b0;
  pcVar4 = _objc_msgSend(pvVar3,sel_objectForKey_,pcVar7);
  local_84 = _objc_msgSend(pcVar4,sel_length);
  if (local_14->_accumulationLimit == 0) {
    if (local_84 < (id)0x4) goto LAB_0024909c;
    puVar5 = _objc_msgSend(pcVar4,sel_bytes,pcVar7);
    pHVar2 = local_14;
    if (puVar5 == (uint *)0x0) goto LAB_0024909c;
    uVar15 = *puVar5;
    local_14->_accumulationLimit =
         uVar15 >> 0x18 | (uVar15 & 0xff0000) >> 8 | (uVar15 & 0xff00) << 8 | uVar15 << 0x18;
    if (local_14->_accumulationLimit < 0x1c) goto LAB_0024909c;
    if (local_84 < (id)local_14->_accumulationLimit) {
      pvVar3 = _objc_msgSend(pcVar4,sel_mutableCopy,pcVar7);
      pHVar2->_dataAccumulator = pvVar3;
    }
    else {
      pvVar3 = _objc_msgSend(pcVar4,sel_retain,pcVar7);
      pHVar2->_dataAccumulator = pvVar3;
      local_84 = (id)0x0;
    }
  }
  if (local_84 != (id)0x0) {
    pvVar3 = _objc_msgSend(local_14->_dataAccumulator,sel_length,pcVar7);
    if (pvVar3 < (id)local_14->_accumulationLimit) {
      _objc_msgSend(local_14->_dataAccumulator,sel_appendData_,pcVar4);
      _objc_msgSend(self_00,sel_readInBackgroundAndNotify);
      bVar1 = true;
      pcVar7 = pcVar4;
      goto LAB_0024909c;
    }
  }
  pvVar3 = _objc_msgSend(local_14->_dataAccumulator,sel_length,pcVar7);
  if (pvVar3 < (id)local_14->_accumulationLimit) goto LAB_0024909c;
  puVar5 = _objc_msgSend(local_14->_dataAccumulator,sel_bytes);
  if (puVar5 == (uint *)0x0) goto LAB_0024909c;
  if ((puVar5 == (uint *)0x0) || (local_14->_accumulationLimit < 0xc)) goto LAB_0024909c;
  uVar15 = *puVar5;
  uVar15 = uVar15 >> 0x18 | (uVar15 & 0xff0000) >> 8 | (uVar15 & 0xff00) << 8 | uVar15 << 0x18;
  if (uVar15 < local_14->_accumulationLimit) goto LAB_0024909c;
  uVar15 = uVar15 - 0xc;
  if ((puVar5[1] != 0x66446d56) || (puVar5[2] != 0x1000000)) goto LAB_0024909c;
  if ((puVar5 == (uint *)0xfffffff4) || (uVar15 < 0x10)) goto LAB_0024909c;
  uVar6 = puVar5[5];
  if ((uVar6 == 0) || (uVar16 = puVar5[6], uVar16 == 0)) goto LAB_0024909c;
  uVar16 = uVar16 >> 0x18 | (uVar16 & 0xff0000) >> 8 | (uVar16 & 0xff00) << 8 | uVar16 << 0x18;
  uVar6 = uVar6 >> 0x18 | (uVar6 & 0xff0000) >> 8 | (uVar6 & 0xff00) << 8 | uVar6 << 0x18;
  if ((uVar15 < uVar6 + 0x10 + uVar16) ||
     ((*(char *)(uVar6 + 0x1b + (int)puVar5) != '\0' ||
      (*(char *)((int)puVar5 + uVar16 + uVar6 + 0x1b) != '\0')))) goto LAB_0024909c;
  if ((puVar5[3] == 0) || (puVar5[4] == 0)) goto LAB_0024909c;
  pvVar3 = _objc_msgSend(cls_NSString,sel_stringWithUTF8String_,puVar5 + 7);
  pcVar7 = &cfstr_com_mackiev_netregistrar;
  pvVar3 = _objc_msgSend(pvVar3,sel_isEqualToString_,&cfstr_com_mackiev_netregistrar);
  if ((char)pvVar3 == '\0') goto LAB_0024909c;
  uVar17 = 0x1e;
  pcVar7 = _objc_msgSend(cls_NSString,sel_stringWithCString_encoding_,uVar6 + 0x1c + (int)puVar5,
                         0x1e);
  pvVar3 = _objc_msgSend(local_14->_infoConnection,sel_identifier);
  pvVar3 = _objc_msgSend(pvVar3,sel_isEqualToString_,pcVar7);
  if ((char)pvVar3 == '\0') goto LAB_0024909c;
  if (local_14->_infoMessage == (id)0x0) {
    pvVar3 = _objc_msgSend(cls_NSBundle,sel_mainBundle,pcVar7,uVar17);
    pvVar3 = _objc_msgSend(pvVar3,sel_bundleIdentifier);
    pcVar8 = _objc_msgSend(pvVar3,sel_UTF8String);
    if (pcVar8 == (char *)0x0) goto LAB_0024909c;
    sVar9 = _strlen(pcVar8);
    if (sVar9 == 0) goto LAB_0024909c;
    pvVar3 = _objc_msgSend(local_14->_networkRegistration,sel_identifier);
    pcVar4 = (cfstringStruct *)0x1e;
    pcVar10 = _objc_msgSend(pvVar3,sel_cStringUsingEncoding_,0x1e);
    pcVar7 = pcVar4;
    if (pcVar10 == (char *)0x0) goto LAB_0024909c;
    sVar11 = _strlen(pcVar10);
    pcVar7 = pcVar4;
    if (sVar11 == 0) goto LAB_0024909c;
    uVar15 = sVar9 + 1;
    pcVar7 = (cfstringStruct *)(sVar11 + 0x1d + uVar15);
    pvVar3 = _objc_msgSend(cls_NSMutableData,sel_alloc,pcVar4);
    pvVar3 = _objc_msgSend(pvVar3,sel_initWithLength_,pcVar7);
    puVar5 = _objc_msgSend(pvVar3,sel_mutableBytes);
    if (puVar5 == (uint *)0x0) goto LAB_0024909c;
    pvVar12 = _objc_msgSend(pvVar3,sel_length,pcVar7);
    if ((id)0xb < pvVar12) {
      uVar6 = sVar11 + uVar15 + 0x1d;
      *puVar5 = uVar6 >> 0x18 | (uVar6 & 0xff0000) >> 8 | (uVar6 & 0xff00) << 8 | uVar6 * 0x1000000;
      puVar5[1] = 0x6669524e;
      puVar5[2] = 0x1000000;
    }
    pcVar7 = (cfstringStruct *)(sVar11 + 1);
    puVar5[3] = uVar15 >> 0x18 | (uVar15 & 0xff0000) >> 8 | (uVar15 & 0xff00) << 8 |
                uVar15 * 0x1000000;
    _memcpy(puVar5 + 4,pcVar8,uVar15);
    *(undefined4 *)((int)puVar5 + sVar9 + 0x11) = 0x1000000;
    *(undefined4 *)(sVar9 + 0x15 + (int)puVar5) = 0x67527348;
    *(uint *)(sVar9 + 0x19 + (int)puVar5) =
         (uint)pcVar7 >> 0x18 | ((uint)pcVar7 & 0xff0000) >> 8 | ((uint)pcVar7 & 0xff00) << 8 |
         (int)pcVar7 * 0x1000000;
    _memcpy((void *)(sVar9 + 0x1d + (int)puVar5),pcVar10,(size_t)pcVar7);
    local_14->_infoMessage = pvVar3;
  }
  _objc_exception_try_enter(local_74);
  iVar13 = __setjmp(local_74);
  if (iVar13 == 0) {
    pcVar7 = local_14->_infoMessage;
    _objc_msgSend(self_00,sel_writeData_,pcVar7);
  }
  else {
    iVar14 = _objc_exception_extract(local_74);
    _objc_exception_try_enter(local_74);
    iVar13 = __setjmp(local_74);
    if (iVar13 == 0) {
      iVar13 = _objc_exception_match(cls_NSException,iVar14);
      if (iVar13 != 0) goto LAB_0024908a;
      _objc_exception_try_exit(local_74);
    }
    else {
      iVar14 = _objc_exception_extract(local_74);
    }
    if (iVar14 != 0) {
                    /* WARNING: Subroutine does not return * /
      _objc_exception_throw(iVar14);
    }
  }
LAB_0024908a:
  _objc_exception_try_exit(local_74);
LAB_0024909c:
  if (!bVar1) {
    pvVar3 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter,pcVar7);
    _objc_msgSend(pvVar3,sel_removeObserver_name_object_,local_14,*(undefined4 *)PTR_003368b4,
                  self_00);
    _objc_msgSend(local_14->_dataAccumulator,sel_release);
    local_14->_dataAccumulator = (id)0x0;
    _objc_msgSend(self_00,sel_closeFile);
  }
  return;
}

*/
- (void)HSNetworkRegistrar_verificationMessageReceived:(id)aReceived
{
    id fileHandle = [aReceived object];
    BOOL keepReading = NO;
    if ([[[aReceived userInfo] objectForKey:@"NSFileHandleError"] intValue] == 0) {
        NSData *data = [[aReceived userInfo] objectForKey:NSFileHandleNotificationDataItem];
        NSUInteger length = [data length];
        if (_accumulationLimit == 0) {
            if (length < 4) {
                goto finished;
            }
            const uint32_t *header = [data bytes];
            if (header == NULL) {
                goto finished;
            }
            _accumulationLimit = ntohl(header[0]);
            if (_accumulationLimit < 0x1c) {
                goto finished;
            }
            if (length < _accumulationLimit) {
                _dataAccumulator = [data mutableCopy];
            }
            else {
                _dataAccumulator = (NSMutableData *)[data retain];
                length = 0;
            }
        }
        // Note: after the mutableCopy above the first chunk is appended a second time, as in the original.
        if (length != 0 && [_dataAccumulator length] < _accumulationLimit) {
            [_dataAccumulator appendData:data];
            [fileHandle readInBackgroundAndNotify];
            keepReading = YES;
            goto finished;
        }
        if ([_dataAccumulator length] < _accumulationLimit) {
            goto finished;
        }
        const uint32_t *words = [_dataAccumulator bytes];
        if (words == NULL || _accumulationLimit < 0xc) {
            goto finished;
        }
        uint32_t total = ntohl(words[0]);
        if (total < _accumulationLimit) {
            goto finished;
        }
        total -= 0xc;
        if (words[1] != 0x66446d56 || words[2] != 0x1000000 || total < 0x10) {
            goto finished;
        }
        if (words[5] == 0 || words[6] == 0) {
            goto finished;
        }
        uint32_t identifierLength = ntohl(words[5]);
        uint32_t networkIdentifierLength = ntohl(words[6]);
        const char *bytes = (const char *)words;
        if (total < identifierLength + 0x10 + networkIdentifierLength || bytes[identifierLength + 0x1b] != '\0' || bytes[networkIdentifierLength + identifierLength + 0x1b] != '\0') {
            goto finished;
        }
        if (words[3] == 0 || words[4] == 0) {
            goto finished;
        }
        if (![[NSString stringWithUTF8String:(const char *)(words + 7)] isEqualToString:@"com.mackiev.netregistrar"]) {
            goto finished;
        }
        NSString *senderIdentifier = [NSString stringWithCString:bytes + identifierLength + 0x1c encoding:NSMacOSRomanStringEncoding];
        if (![[_infoConnection identifier] isEqualToString:senderIdentifier]) {
            goto finished;
        }
        if (_infoMessage == nil) {
            const char *bundleIdentifier = [[[NSBundle mainBundle] bundleIdentifier] UTF8String];
            if (bundleIdentifier == NULL) {
                goto finished;
            }
            size_t bundleIdentifierLength = strlen(bundleIdentifier);
            if (bundleIdentifierLength == 0) {
                goto finished;
            }
            const char *networkIdentifier = [[_networkRegistration identifier] cStringUsingEncoding:NSMacOSRomanStringEncoding];
            if (networkIdentifier == NULL) {
                goto finished;
            }
            size_t networkLength = strlen(networkIdentifier);
            if (networkLength == 0) {
                goto finished;
            }
            size_t bundleSize = bundleIdentifierLength + 1;
            NSMutableData *message = [[NSMutableData alloc] initWithLength:networkLength + 0x1d + bundleSize];
            uint32_t *out = [message mutableBytes];
            if (out == NULL) {
                goto finished;
            }
            if ([message length] > 0xb) {
                out[0] = htonl((uint32_t)(networkLength + bundleSize + 0x1d));
                out[1] = 0x6669524e;
                out[2] = 0x1000000;
            }
            out[3] = htonl((uint32_t)bundleSize);
            memcpy(out + 4, bundleIdentifier, bundleSize);
            *(uint32_t *)((char *)out + bundleIdentifierLength + 0x11) = 0x1000000;
            *(uint32_t *)((char *)out + bundleIdentifierLength + 0x15) = 0x67527348;
            *(uint32_t *)((char *)out + bundleIdentifierLength + 0x19) = htonl((uint32_t)(networkLength + 1));
            memcpy((char *)out + bundleIdentifierLength + 0x1d, networkIdentifier, networkLength + 1);
            _infoMessage = message;
        }
        @try {
            [(NSFileHandle *)fileHandle writeData:_infoMessage];
        }
        @catch (NSException *exception) {
        }
    }
finished:
    if (!keepReading) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadCompletionNotification object:fileHandle];
        [_dataAccumulator release];
        _dataAccumulator = nil;
        [fileHandle closeFile];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024914c @ 0024914c, 740 bytes * /

void FUN_0024914c(HSNetworkRegistrar *self,SEL _cmd,id HSNetworkRegistrar_adminMessageReceived)

{
  uint *puVar1;
  undefined *self_00;
  id pvVar2;
  id pvVar3;
  uint *puVar4;
  uint uVar5;
  id pvVar6;
  uint uVar7;
  uint uVar8;
  cfstringStruct *pcVar9;
  undefined4 uVar10;
  
  pvVar2 = _objc_msgSend(HSNetworkRegistrar_adminMessageReceived,sel_object);
  pvVar3 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  uVar10 = *(undefined4 *)PTR_003368b8;
  _objc_msgSend(pvVar3,sel_removeObserver_name_object_,self,uVar10,pvVar2);
  pvVar3 = _objc_msgSend(HSNetworkRegistrar_adminMessageReceived,sel_userInfo);
  pcVar9 = &cfstr_NSFileHandleError;
  pvVar3 = _objc_msgSend(pvVar3,sel_objectForKey_,&cfstr_NSFileHandleError);
  pvVar3 = _objc_msgSend(pvVar3,sel_intValue);
  if (pvVar3 != (id)0x0) {
    return;
  }
  pvVar2 = _objc_msgSend(HSNetworkRegistrar_adminMessageReceived,sel_userInfo,pcVar9,uVar10,pvVar2);
  uVar10 = *(undefined4 *)PTR_003368b0;
  pvVar2 = _objc_msgSend(pvVar2,sel_objectForKey_,uVar10);
  pvVar3 = _objc_msgSend(pvVar2,sel_length);
  puVar4 = _objc_msgSend(pvVar2,sel_bytes);
  if (puVar4 == (uint *)0x0) {
    return;
  }
  if (pvVar3 < (id)0xc) {
    return;
  }
  uVar5 = *puVar4;
  pvVar2 = (id)(uVar5 >> 0x18 | (uVar5 & 0xff0000) >> 8 | (uVar5 & 0xff00) << 8 | uVar5 << 0x18);
  if (pvVar2 < pvVar3) {
    return;
  }
  if (puVar4[1] != 0x66446441) {
    return;
  }
  if (puVar4[2] != 0x1000000) {
    return;
  }
  if (puVar4 == (uint *)0xfffffff4) {
    return;
  }
  uVar5 = (int)pvVar2 - 0xc;
  if (uVar5 < 0xc) {
    return;
  }
  uVar7 = puVar4[5];
  uVar7 = uVar7 >> 0x18 | (uVar7 & 0xff0000) >> 8 | (uVar7 & 0xff00) << 8 | uVar7 << 0x18;
  if (uVar5 < uVar7 + 0xc) {
    return;
  }
  if (puVar4[3] != 0x416d7254) {
    return;
  }
  uVar5 = puVar4[4];
  _objc_msgSend(self->_registrationConnection,sel_refuseConnection,uVar10);
  if (((uVar5 == 0x45646c41) && (puVar1 = puVar4 + 6, puVar1 != (uint *)0x0)) && (7 < uVar7)) {
    uVar5 = puVar4[6];
    uVar8 = puVar4[7];
    uVar8 = uVar8 >> 0x18 | (uVar8 & 0xff0000) >> 8 | (uVar8 & 0xff00) << 8 | uVar8 << 0x18;
    uVar5 = uVar5 >> 0x18 | (uVar5 & 0xff0000) >> 8 | (uVar5 & 0xff00) << 8 | uVar5 << 0x18;
    if (((uVar5 + 10 + uVar8 <= uVar7) && (*(char *)(uVar5 + 8 + (int)puVar1) == '\0')) &&
       (*(char *)((int)puVar1 + uVar8 + 9 + uVar5) == '\0')) {
      pvVar3 = _objc_msgSend(cls_NSString,sel_stringWithUTF8String_,(int)puVar1 + uVar5 + 9);
      if (pvVar3 == (id)0x0) {
        pvVar2 = (id)0x0;
      }
      else {
        pvVar2 = _objc_msgSend(cls_NSString,sel_stringWithUTF8String_,puVar4 + 8);
      }
      goto LAB_00249371;
    }
  }
  pvVar2 = (id)0x0;
  pvVar3 = (id)0x0;
LAB_00249371:
  self_00 = cls_NSDictionary;
  pvVar6 = _objc_msgSend(cls_NSNumber,sel_numberWithInt_,2);
  pvVar2 = _objc_msgSend(self_00,sel_dictionaryWithObjectsAndKeys_,pvVar6,
                         &cfstr_HSNetworkRegistrarRefusedErrorCode,pvVar2,
                         &cfstr_HSNetworkRegistrarRefusedCutomErrorTitle,pvVar3,
                         &cfstr_HSNetworkRegistrarRefusedCutomErrorExplanation,0);
  pvVar3 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar3,sel_postNotificationName_object_userInfo_,
                &cfstr_HSNetworkRegistrarRefusedNotification,self,pvVar2);
  return;
}

*/
- (void)HSNetworkRegistrar_adminMessageReceived:(id)aReceived
{
    id fileHandle = [aReceived object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadToEndOfFileCompletionNotification object:fileHandle];
    if ([[[aReceived userInfo] objectForKey:@"NSFileHandleError"] intValue] != 0) {
        return;
    }
    NSData *data = [[aReceived userInfo] objectForKey:NSFileHandleNotificationDataItem];
    NSUInteger length = [data length];
    const uint32_t *words = [data bytes];
    if (words == NULL || length < 0xc) {
        return;
    }
    uint32_t total = ntohl(words[0]);
    if (total < length) {
        return;
    }
    if (words[1] != 0x66446441 || words[2] != 0x1000000) {
        return;
    }
    uint32_t remaining = total - 0xc;
    if (remaining < 0xc) {
        return;
    }
    uint32_t bodyLength = ntohl(words[5]);
    if (remaining < bodyLength + 0xc) {
        return;
    }
    if (words[3] != 0x416d7254) {
        return;
    }
    uint32_t kind = words[4];
    [_registrationConnection refuseConnection];
    NSString *title = nil;
    NSString *explanation = nil;
    if (kind == 0x45646c41 && bodyLength > 7) {
        uint32_t titleLength = ntohl(words[6]);
        uint32_t explanationLength = ntohl(words[7]);
        const char *text = (const char *)(words + 6);
        if (titleLength + 10 + explanationLength <= bodyLength && text[titleLength + 8] == '\0' && text[explanationLength + 9 + titleLength] == '\0') {
            explanation = [NSString stringWithUTF8String:text + titleLength + 9];
            if (explanation != nil) {
                title = [NSString stringWithUTF8String:(const char *)(words + 8)];
            }
        }
    }
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:2], @"HSNetworkRegistrarRefusedErrorCode", title, @"HSNetworkRegistrarRefusedCutomErrorTitle", explanation, @"HSNetworkRegistrarRefusedCutomErrorExplanation", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSNetworkRegistrarRefusedNotification" object:self userInfo:userInfo];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00249430 @ 00249430, 479 bytes * /

id FUN_00249430(HSNetworkRegistrar *self,SEL _cmd)

{
  uint uVar1;
  uint uVar2;
  char *pcVar3;
  id pvVar4;
  char *pcVar5;
  size_t sVar6;
  size_t sVar7;
  id pvVar8;
  uint *puVar9;
  undefined4 uVar10;
  int iVar11;
  
  pvVar4 = self->_verificationInfo;
  if (pvVar4 == (id)0x0) {
    pcVar3 = _objc_msgSend(self->_identifier,sel_UTF8String);
    if (pcVar3 != (char *)0x0) {
      pvVar4 = _objc_msgSend(self->_networkRegistration,sel_identifier);
      uVar10 = 0x1e;
      pcVar5 = _objc_msgSend(pvVar4,sel_cStringUsingEncoding_,0x1e);
      if (pcVar5 != (char *)0x0) {
        sVar6 = _strlen(pcVar3);
        sVar7 = _strlen(pcVar5);
        iVar11 = sVar6 + 0x1e + sVar7;
        pvVar4 = _objc_msgSend(cls_NSMutableData,sel_alloc,uVar10);
        pvVar4 = _objc_msgSend(pvVar4,sel_initWithLength_,iVar11);
        pvVar8 = _objc_msgSend(pvVar4,sel_length);
        if (pvVar8 != (id)0x0) {
          puVar9 = _objc_msgSend(pvVar4,sel_mutableBytes,iVar11);
          _memcpy(puVar9 + 7,pcVar3,sVar6 + 1);
          _memcpy((void *)((int)puVar9 + sVar6 + 0x1d),pcVar5,sVar7 + 1);
          uVar1 = self->_licenseType;
          uVar2 = self->_allowedRegistrationCount;
          sVar6 = _strlen(pcVar3);
          sVar7 = _strlen(pcVar5);
          if ((sVar6 != 0) && (sVar7 != 0)) {
            puVar9[3] = uVar2 >> 0x18 | (uVar2 & 0xff0000) >> 8 | (uVar2 & 0xff00) << 8 |
                        uVar2 << 0x18;
            puVar9[4] = uVar1 >> 0x18 | (uVar1 & 0xff0000) >> 8 | (uVar1 & 0xff00) << 8 |
                        uVar1 << 0x18;
            puVar9[5] = sVar6 >> 0x18 | (sVar6 & 0xff0000) >> 8 | (sVar6 & 0xff00) << 8 |
                        sVar6 << 0x18;
            puVar9[6] = sVar7 >> 0x18 | (sVar7 & 0xff0000) >> 8 | (sVar7 & 0xff00) << 8 |
                        sVar7 << 0x18;
          }
          pvVar8 = _objc_msgSend(pvVar4,sel_length);
          *puVar9 = (uint)pvVar8 >> 0x18 | ((uint)pvVar8 & 0xff0000) >> 8 |
                    ((uint)pvVar8 & 0xff00) << 8 | (int)pvVar8 << 0x18;
          puVar9[1] = 0x66446d56;
          puVar9[2] = 0x1000000;
          self->_verificationInfo = pvVar4;
          return pvVar4;
        }
        _objc_msgSend(pvVar4,sel_release,iVar11);
      }
    }
    pvVar4 = (id)0x0;
  }
  return pvVar4;
}

*/
- (id)HSNetworkRegistrar_verificationInfo
{
    if (_verificationInfo != nil) {
        return _verificationInfo;
    }
    const char *identifier = [_identifier UTF8String];
    if (identifier != NULL) {
        const char *networkIdentifier = [[_networkRegistration identifier] cStringUsingEncoding:NSMacOSRomanStringEncoding];
        if (networkIdentifier != NULL) {
            size_t identifierLength = strlen(identifier);
            size_t networkIdentifierLength = strlen(networkIdentifier);
            NSUInteger totalLength = identifierLength + 0x1e + networkIdentifierLength;
            NSMutableData *data = [[NSMutableData alloc] initWithLength:totalLength];
            if ([data length] != 0) {
                uint32_t *bytes = [data mutableBytes];
                memcpy(bytes + 7, identifier, identifierLength + 1);
                memcpy((char *)bytes + identifierLength + 0x1d, networkIdentifier, networkIdentifierLength + 1);
                if (strlen(identifier) != 0 && strlen(networkIdentifier) != 0) {
                    bytes[3] = htonl(_allowedRegistrationCount);
                    bytes[4] = htonl(_licenseType);
                    bytes[5] = htonl((uint32_t)identifierLength);
                    bytes[6] = htonl((uint32_t)networkIdentifierLength);
                }
                bytes[0] = htonl((uint32_t)[data length]);
                bytes[1] = 0x66446d56;
                bytes[2] = 0x1000000;
                _verificationInfo = data;
                return data;
            }
            [data release];
        }
    }
    return nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024873d @ 0024873d, 36 bytes * /

BOOL FUN_0024873d(HSNetworkRegistrar *self,SEL _cmd,
                 id stopMonitoringWhenLastConnectionDidFindForItem)

{
  if ((self->_networkRegistration == stopMonitoringWhenLastConnectionDidFindForItem) &&
     ((self->_isRegistered[0] & 4) != 0)) {
    return 1 < self->_registrationCount;
  }
  return '\0';
}

*/
- (BOOL)stopMonitoringWhenLastConnectionDidFindForItem:(id)aItem
{
    return _networkRegistration == aItem && _isOwnConnectionProcessed && _registrationCount > 1;
}

- (void)networkItem:(id)aItem didRemoveConnectionItem:(id)aItem2 withError:(NSInteger)aError
{
    id *ppvVar3;
    int uVar4;

    if (![aItem2 isProvider]) {
        _registrationCount = _registrationCount - 1;
    }
    else {
        if (_networkRegistration == aItem) {
            ppvVar3 = &_registrationConnection;
        }
        else {
            ppvVar3 = &_infoConnection;
        }
        [*ppvVar3 setDelegate:0];
        [*ppvVar3 release];
        *ppvVar3 = nil;
        if (aError == -0x11941) {
            uVar4 = 3;
        }
        if (aError == 0) {
            uVar4 = 0;
        }
        else {
            [aItem stopMonitoring];
            uVar4 = 1;
        }
        if (aError != 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HSNetworkRegistrarRefusedNotification" object:self userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:uVar4] forKey:@"HSNetworkRegistrarRefusedErrorCode"]];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024975e @ 0024975e, 437 bytes * /

void FUN_0024975e(HSNetworkRegistrar *self,SEL _cmd,id networkItem,id didFindConnectionItem)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  uint uVar3;
  id *ppvVar4;
  
  pvVar1 = _objc_msgSend(didFindConnectionItem,sel_isProvider);
  if ((char)pvVar1 == '\0') {
    uVar3 = self->_registrationCount + 1;
    self->_registrationCount = uVar3;
    if (self->_allowedRegistrationCount < uVar3) {
      _objc_msgSend(networkItem,sel_performSelector_withObject_afterDelay_,sel_stopMonitoring,0,0,0)
      ;
      pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
      self_00 = cls_NSDictionary;
      pvVar2 = _objc_msgSend(cls_NSNumber,sel_numberWithInt_,3);
      pvVar2 = _objc_msgSend(self_00,sel_dictionaryWithObject_forKey_,pvVar2,
                             &cfstr_HSNetworkRegistrarRefusedErrorCode);
      _objc_msgSend(pvVar1,sel_postNotificationName_object_userInfo_,
                    &cfstr_HSNetworkRegistrarRefusedNotification,self,pvVar2);
    }
    else {
      pvVar1 = _objc_msgSend(didFindConnectionItem,sel_name);
      pvVar2 = _objc_msgSend(self->_registrationConnection,sel_name);
      pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_,pvVar2);
      if ((char)pvVar1 != '\0') {
        self->_isRegistered[0] = self->_isRegistered[0] | 4;
      }
    }
  }
  else {
    if (self->_networkRegistration == networkItem) {
      ppvVar4 = &self->_registrationConnection;
    }
    else {
      ppvVar4 = &self->_infoConnection;
    }
    _objc_msgSend(didFindConnectionItem,sel_setDelegate_,self);
    _objc_msgSend(*ppvVar4,sel_release);
    pvVar1 = _objc_msgSend(didFindConnectionItem,sel_retain);
    *ppvVar4 = pvVar1;
  }
  return;
}

*/
- (void)networkItem:(id)aItem didFindConnectionItem:(id)aItem2
{
    if (![(id<SRConnectionItem>)aItem2 isProvider]) {
        _registrationCount++;
        if (_allowedRegistrationCount < _registrationCount) {
            [aItem performSelector:@selector(stopMonitoring) withObject:nil afterDelay:0.0];
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:3] forKey:@"HSNetworkRegistrarRefusedErrorCode"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HSNetworkRegistrarRefusedNotification" object:self userInfo:userInfo];
        }
        else if ([[(id<SRConnectionItem>)aItem2 name] isEqualToString:[_registrationConnection name]]) {
            _isOwnConnectionProcessed = 1;
        }
    }
    else {
        id<SRConnectionItem> *connection = (aItem == _networkRegistration) ? &_registrationConnection : &_infoConnection;
        [(id<SRConnectionItem>)aItem2 setDelegate:self];
        [*connection release];
        *connection = [aItem2 retain];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00249913 @ 00249913, 344 bytes * /

void FUN_00249913(HSNetworkRegistrar *self,SEL _cmd,id monitoringDidFinishedForItem,int withError)

{
  undefined *puVar1;
  id pvVar2;
  cfstringStruct *pcVar3;
  id local_14;
  
  if (self->_networkRegistration != monitoringDidFinishedForItem) {
    return;
  }
  if (withError == 0) {
    if ((self->_isRegistered[0] & 1) == 0) {
      return;
    }
    self->_isRegistered[0] = self->_isRegistered[0] | 2;
    if (self->_allowedRegistrationCount < self->_registrationCount) {
      return;
    }
    local_14 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    puVar1 = cls_NSDictionary;
    pvVar2 = _objc_msgSend(cls_NSNumber,sel_numberWithUnsignedInt_,self->_registrationCount);
    pvVar2 = _objc_msgSend(puVar1,sel_dictionaryWithObject_forKey_,pvVar2,
                           &cfstr_HSNetworkRegistrarCheckingFinishedCount);
    pcVar3 = &cfstr_HSNetworkRegistrarCheckingFinishedNotification;
  }
  else {
    local_14 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    puVar1 = cls_NSDictionary;
    pvVar2 = _objc_msgSend(cls_NSNumber,sel_numberWithInt_,1);
    pvVar2 = _objc_msgSend(puVar1,sel_dictionaryWithObject_forKey_,pvVar2,
                           &cfstr_HSNetworkRegistrarRefusedErrorCode);
    pcVar3 = &cfstr_HSNetworkRegistrarRefusedNotification;
  }
  _objc_msgSend(local_14,sel_postNotificationName_object_userInfo_,pcVar3,self,pvVar2);
  return;
}

*/
- (void)monitoringDidFinishedForItem:(id)aItem withError:(NSInteger)aError
{
    if (_networkRegistration != aItem) {
        return;
    }
    NSNotificationCenter *center;
    NSString *name;
    NSDictionary *userInfo;
    if (aError == 0) {
        if (!_isRegistered) {
            return;
        }
        _isCalcuationFinished = 1;
        if (_allowedRegistrationCount < _registrationCount) {
            return;
        }
        center = [NSNotificationCenter defaultCenter];
        userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:_registrationCount] forKey:@"HSNetworkRegistrarCheckingFinishedCount"];
        name = @"HSNetworkRegistrarCheckingFinishedNotification";
    }
    else {
        center = [NSNotificationCenter defaultCenter];
        userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:@"HSNetworkRegistrarRefusedErrorCode"];
        name = @"HSNetworkRegistrarRefusedNotification";
    }
    [center postNotificationName:name object:self userInfo:userInfo];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00249a6b @ 00249a6b, 92 bytes * /

void FUN_00249a6b(HSNetworkRegistrar *self,SEL _cmd,id providingDidFinishedForItem)

{
  if (self->_infoRegistration == providingDidFinishedForItem) {
    _objc_msgSend(self->_infoRegistration,sel_setDelegate_,0);
    _objc_msgSend(self->_infoRegistration,sel_autorelease);
    self->_infoRegistration = (SRNetworkItem *)0x0;
  }
  else {
    self->_isRegistered[0] = self->_isRegistered[0] & 0xfe;
  }
  return;
}

*/
- (void)providingDidFinishedForItem:(id)aItem
{
    if (_infoRegistration == aItem) {
        [_infoRegistration setDelegate:nil];
        [_infoRegistration autorelease];
        _infoRegistration = nil;
    }
    else {
        _isRegistered = 0;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00249ac7 @ 00249ac7, 88 bytes * /

void FUN_00249ac7(HSNetworkRegistrar *self,SEL _cmd,id providingWillStartForItem)

{
  if (self->_infoRegistration != providingWillStartForItem) {
    if (1 < self->_allowedRegistrationCount) {
      _objc_msgSend(self,sel_performSelector_withObject_afterDelay_,
                    sel_HSNetworkRegistrar_startMonitoringForItem_,providingWillStartForItem,0,0);
    }
    self->_isRegistered[0] = self->_isRegistered[0] | 1;
  }
  return;
}

*/
- (void)providingWillStartForItem:(id)aItem
{
    if (_infoRegistration != aItem) {
        if (_allowedRegistrationCount > 1) {
            [self performSelector:@selector(HSNetworkRegistrar_startMonitoringForItem:) withObject:aItem afterDelay:0.0];
        }
        _isRegistered = 1;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00249b1f @ 00249b1f, 185 bytes * /

void FUN_00249b1f(HSNetworkRegistrar *self,SEL _cmd,id HSNetworkRegistrar_startMonitoringForItem)

{
  undefined *self_00;
  id pvVar1;
  id self_01;
  
  pvVar1 = _objc_msgSend(HSNetworkRegistrar_startMonitoringForItem,sel_startMonitoring);
  self_00 = cls_NSDictionary;
  if (pvVar1 != (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSNumber,sel_numberWithInt_,1);
    pvVar1 = _objc_msgSend(self_00,sel_dictionaryWithObject_forKey_,pvVar1,
                           &cfstr_HSNetworkRegistrarRefusedErrorCode);
    self_01 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    _objc_msgSend(self_01,sel_postNotificationName_object_userInfo_,
                  &cfstr_HSNetworkRegistrarRefusedNotification,self,pvVar1);
  }
  return;
}

*/
- (void)HSNetworkRegistrar_startMonitoringForItem:(id)aItem
{
    if ([(SRNetworkItem *)aItem startMonitoring] != 0) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:@"HSNetworkRegistrarRefusedErrorCode"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSNetworkRegistrarRefusedNotification" object:self userInfo:userInfo];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00249bd8 @ 00249bd8, 175 bytes * /

int FUN_00249bd8(HSNetworkRegistrar *self,SEL _cmd,id registerBlockingIdentifier)

{
  id pvVar1;
  HSNetworkBlocker *self_00;
  
  pvVar1 = _objc_msgSend(registerBlockingIdentifier,sel_length);
  if (pvVar1 == (id)0x0) {
LAB_00249c7a:
    pvVar1 = (id)0x1;
  }
  else {
    self_00 = self->_networkBlocker;
    if (self_00 == (HSNetworkBlocker *)0x0) {
      pvVar1 = _objc_msgSend(cls_HSNetworkBlocker,sel_alloc);
      self_00 = _objc_msgSend(pvVar1,sel_initWithBundleIdentifier_licenseType_allowedCount_,
                              self->_identifier,self->_licenseType,self->_allowedRegistrationCount);
      self->_networkBlocker = self_00;
      if (self_00 == (HSNetworkBlocker *)0x0) goto LAB_00249c7a;
    }
    pvVar1 = _objc_msgSend(self_00,sel_blockIdentifier_,registerBlockingIdentifier);
  }
  return (int)pvVar1;
}

*/
- (NSInteger)registerBlockingIdentifier:(id)aIdentifier
{
    if ([aIdentifier length] == 0) {
        return 1;
    }
    if (_networkBlocker == nil) {
        _networkBlocker = [[HSNetworkBlocker alloc] initWithBundleIdentifier:_identifier licenseType:_licenseType allowedCount:_allowedRegistrationCount];
        if (_networkBlocker == nil) {
            return 1;
        }
    }
    return [_networkBlocker blockIdentifier:aIdentifier];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00249c87 @ 00249c87, 474 bytes * /

int FUN_00249c87(HSNetworkRegistrar *self,SEL _cmd,id registerWithIdentifier,uint allowedCount)

{
  id pvVar1;
  id pvVar2;
  cfstringStruct *self_00;
  SRNetworkItem *self_01;
  int iVar3;
  cfstringStruct *pcVar4;
  cfstringStruct *local_18;
  
  pvVar1 = _objc_msgSend(registerWithIdentifier,sel_length);
  if ((pvVar1 == (id)0x0) || (allowedCount == 0)) {
    return 1;
  }
  pvVar2 = _objc_msgSend(cls_NSString,sel_alloc);
  pcVar4 = &cfstr______tcp_;
  pvVar1 = registerWithIdentifier;
  self_00 = _objc_msgSend(pvVar2,sel_initWithFormat_,&cfstr______tcp_,registerWithIdentifier);
  if (self_00 == (cfstringStruct *)0x0) {
    return 1;
  }
  if (self->_networkRegistration == (SRNetworkItem *)0x0) {
    if (allowedCount < 2) {
      local_18 = (cfstringStruct *)0x0;
    }
    else {
      iVar3 = _CFUUIDCreate(0);
      if (iVar3 == 0) {
        local_18 = (cfstringStruct *)0x0;
      }
      else {
        local_18 = (cfstringStruct *)_CFUUIDCreateString(0,iVar3);
        _CFRelease(iVar3);
      }
      pvVar2 = _objc_msgSend(local_18,sel_length,pcVar4,pvVar1);
      registerWithIdentifier = local_18;
      if (pvVar2 == (id)0x0) goto LAB_00249d3b;
    }
    pvVar2 = _objc_msgSend(cls_SRNetworkItem,sel_alloc,pcVar4,pvVar1);
    pcVar4 = self_00;
    self_01 = _objc_msgSend(pvVar2,sel_initWithIdentifier_,self_00);
    if (self_01 != (SRNetworkItem *)0x0) {
      self->_allowedRegistrationCount = allowedCount;
      self->_networkRegistration = self_01;
      _objc_msgSend(self_01,sel_setDelegate_,self,pvVar1);
      pvVar2 = _objc_msgSend(self->_networkRegistration,sel_startProvidingWithName_,
                             registerWithIdentifier);
      pcVar4 = registerWithIdentifier;
      if (pvVar2 == (id)0x0) {
        iVar3 = 0;
        goto LAB_00249e29;
      }
    }
    iVar3 = 1;
  }
  else {
    pvVar2 = _objc_msgSend(self->_networkRegistration,sel_identifier,pcVar4,pvVar1);
    pcVar4 = self_00;
    pvVar2 = _objc_msgSend(pvVar2,sel_isEqualToString_,self_00);
    if ((char)pvVar2 != '\0') {
      iVar3 = 0;
      local_18 = (cfstringStruct *)0x0;
      goto LAB_00249e29;
    }
    local_18 = (cfstringStruct *)0x0;
LAB_00249d3b:
    iVar3 = 1;
  }
LAB_00249e29:
  _objc_msgSend(local_18,sel_release,pcVar4,pvVar1);
  _objc_msgSend(self_00,sel_release);
  return iVar3;
}

*/
- (NSInteger)registerWithIdentifier:(id)aIdentifier allowedCount:(NSUInteger)aCount
{
    if ([aIdentifier length] == 0 || aCount == 0) {
        return 1;
    }
    NSString *serviceType = [[NSString alloc] initWithFormat:@"_%@._tcp.", aIdentifier];
    if (serviceType == nil) {
        return 1;
    }
    NSString *uniqueName = nil;
    NSInteger result;
    if (_networkRegistration == nil) {
        id providedName = aIdentifier;
        if (aCount >= 2) {
            CFUUIDRef uuid = CFUUIDCreate(NULL);
            if (uuid != NULL) {
                uniqueName = (NSString *)CFUUIDCreateString(NULL, uuid);
                CFRelease(uuid);
            }
            providedName = uniqueName;
            if ([uniqueName length] == 0) {
                result = 1;
                goto finished;
            }
        }
        SRNetworkItem *item = [[SRNetworkItem alloc] initWithIdentifier:serviceType];
        result = 1;
        if (item != nil) {
            _allowedRegistrationCount = aCount;
            _networkRegistration = item;
            [item setDelegate:self];
            if ([_networkRegistration startProvidingWithName:providedName] == 0) {
                result = 0;
            }
        }
    }
    else if ([[_networkRegistration identifier] isEqualToString:serviceType]) {
        result = 0;
    }
    else {
        result = 1;
    }
finished:
    [uniqueName release];
    [serviceType release];
    return result;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_registrationConnection setDelegate:0];
    [_registrationConnection release];
    [_networkRegistration setDelegate:0];
    [_networkRegistration stopMonitoring];
    [_networkRegistration stopProviding];
    [_networkRegistration release];
    [_infoConnection setDelegate:0];
    [_infoConnection release];
    [_infoRegistration setDelegate:0];
    [_infoRegistration stopProviding];
    [_infoRegistration release];
    [_networkBlocker release];
    [_verificationInfo release];
    [_identifier release];
    [_infoMessage release];
    [_dataAccumulator release];
    [super dealloc];
}

- (id)initWithBundleIdentifier:(id)aIdentifier licenseType:(NSUInteger)aType
{
    id pvVar1;

    self = [super init];
    if (self == nil) {
        self = nil;
    }
    else {
        pvVar1 = [aIdentifier retain];
        _identifier = pvVar1;
        if (pvVar1 == nil) {
            [self release];
        }
        else {
            _licenseType = aType;
        }
    }
    return self;
}

- (id)init
{
    [super release];
    return nil;
}

@end

