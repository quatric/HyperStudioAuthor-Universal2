#import "SRServiceProvider.h"
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <errno.h>
#include <unistd.h>

@implementation SRServiceListener

/* i386 ivar offsets: _service=0x4, _serviceType=0x8, _serviceName=0xc, _consumer=0x10, _delegate=0x14, _linksCounter=0x18 */

- (void)netService:(id)aService didNotResolve:(id)aResolve
{
    int uVar2;

    switch([[aResolve objectForKey:NSNetServicesErrorCode] intValue]) {
        case 0xfffee6b9:
        uVar2 = 0x3c;
        break;
        default:
        uVar2 = 0x16;
        break;
        case 0xfffee6bb:
        uVar2 = 0x35;
        break;
        case 0xfffee6bd:
        uVar2 = 0x3d;
        break;
        case 0xfffee6be:
        uVar2 = 0x39;
    }
    if ([_delegate respondsToSelector:@selector(connectionWithItem:didRefusedWithError:)]) {
        [_delegate connectionWithItem:self didRefusedWithError:uVar2];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024b884 @ 0024b884, 979 bytes * /

void FUN_0024b884(SRServiceListener *self,SEL _cmd,id netServiceDidResolveAddress)

{
  id pvVar1;
  id pvVar2;
  int *piVar3;
  undefined *self_00;
  int iVar4;
  id pvVar5;
  sockaddr *psVar6;
  char *pcVar7;
  id pvVar8;
  int iVar9;
  undefined *puVar10;
  SRServiceListener *pSVar11;
  id local_12c;
  id local_128;
  id local_120;
  undefined1 local_11c [16];
  undefined1 local_10c [16];
  undefined1 local_fc [16];
  undefined1 local_ec [16];
  undefined1 local_dc [16];
  undefined1 local_cc [16];
  undefined1 local_bc [16];
  undefined1 local_ac [16];
  undefined1 local_9c [16];
  undefined1 local_8c [16];
  undefined1 local_7c [16];
  undefined1 local_6c [16];
  undefined1 local_5c [16];
  undefined1 local_4c [16];
  undefined1 local_3c [16];
  undefined1 local_2c [16];
  
  pvVar1 = _objc_msgSend(netServiceDidResolveAddress,sel_addresses);
  pvVar2 = _objc_msgSend(pvVar1,sel_count);
  if (pvVar2 == (id)0x0) {
    iVar9 = 0x16;
LAB_0024b8cc:
    pvVar1 = _objc_msgSend(self->_delegate,sel_respondsToSelector_,
                           sel_connectionWithItem_didRefusedWithError_);
    if ((char)pvVar1 != '\0') {
      _objc_msgSend(self->_delegate,sel_connectionWithItem_didRefusedWithError_,self,iVar9);
    }
  }
  else {
    local_2c = (undefined1  [16])0x0;
    local_3c = (undefined1  [16])0x0;
    local_4c = (undefined1  [16])0x0;
    local_5c = (undefined1  [16])0x0;
    local_6c = (undefined1  [16])0x0;
    local_7c = (undefined1  [16])0x0;
    local_8c = (undefined1  [16])0x0;
    local_9c = (undefined1  [16])0x0;
    local_ac = (undefined1  [16])0x0;
    local_bc = (undefined1  [16])0x0;
    local_cc = (undefined1  [16])0x0;
    local_dc = (undefined1  [16])0x0;
    local_ec = (undefined1  [16])0x0;
    local_fc = (undefined1  [16])0x0;
    local_10c = (undefined1  [16])0x0;
    local_11c = (undefined1  [16])0x0;
    local_128 = pvVar2;
    for (local_12c = (id)0x0; local_128 = (id)((int)local_128 + -1), local_12c != pvVar2;
        local_12c = (id)((int)local_12c + 1)) {
      pvVar5 = _objc_msgSend(pvVar1,sel_objectAtIndex_,local_128);
      psVar6 = _objc_msgSend(pvVar5,sel_bytes);
      if (psVar6 == (sockaddr *)0x0) {
        iVar9 = 0x27;
        goto LAB_0024b8cc;
      }
      if (psVar6->sa_family == '\x02') {
        iVar4 = _socket(2,1,0);
        if (iVar4 < 1) {
          piVar3 = ___error();
          iVar9 = *piVar3;
        }
        else {
          pvVar5 = _objc_msgSend(pvVar5,sel_length);
          iVar9 = _connect(iVar4,psVar6,(socklen_t)pvVar5);
          if (iVar9 == 0) {
            pvVar5 = _objc_msgSend(cls_NSFileHandle,sel_alloc);
            self_00 = _objc_msgSend(pvVar5,sel_initWithFileDescriptor_closeOnDealloc_,iVar4,1);
            if (self_00 != (undefined *)0x0) {
              pSVar11 = (SRServiceListener *)0x100;
              pcVar7 = _inet_ntop(2,psVar6->sa_data + 2,local_11c,0x100);
              if (pcVar7 == (char *)0x0) {
                pvVar5 = (id)0x0;
                local_120 = (id)0x0;
              }
              else {
                local_120 = _objc_msgSend(cls_NSNumber,sel_numberWithUnsignedShort_,
                                          (uint)(ushort)(*(ushort *)psVar6->sa_data << 8 |
                                                        *(ushort *)psVar6->sa_data >> 8));
                pvVar5 = _objc_msgSend(cls_NSString,sel_stringWithUTF8String_,local_11c);
              }
              puVar10 = sel_listeningConnection_isEstablishedForItem_properties_;
              pvVar8 = _objc_msgSend(self->_delegate,sel_respondsToSelector_,
                                     sel_listeningConnection_isEstablishedForItem_properties_);
              if ((char)pvVar8 != '\0') {
                pvVar8 = _objc_msgSend(cls_NSDictionary,sel_alloc,puVar10);
                pvVar5 = _objc_msgSend(pvVar8,sel_initWithObjectsAndKeys_,pvVar5,
                                       &cfstr_SRConnectionIPAddress,local_120,
                                       &cfstr_SRConnectionPort,0);
                puVar10 = self_00;
                pSVar11 = self;
                _objc_msgSend(self->_delegate,
                              sel_listeningConnection_isEstablishedForItem_properties_,self_00,self,
                              pvVar5);
                _objc_msgSend(pvVar5,sel_release);
              }
              _objc_msgSend(self_00,sel_release,puVar10,pSVar11);
              goto LAB_0024bc2e;
            }
            _close(iVar4);
            iVar9 = 9;
            goto LAB_0024b8cc;
          }
          piVar3 = ___error();
          iVar9 = *piVar3;
          _close(iVar4);
        }
        if (iVar9 == 0) {
          return;
        }
        goto LAB_0024b8cc;
      }
LAB_0024bc2e:
    }
  }
  return;
}

*/
- (void)netServiceDidResolveAddress:(id)aAddress
{
    NSArray *addresses = [aAddress addresses];
    NSUInteger count = [addresses count];
    int error = 0;
    if (count == 0) {
        error = EINVAL;
    }
    else {
        NSUInteger index = count - 1;
        for (NSUInteger i = 0; i != count; i++, index--) {
            NSData *data = [addresses objectAtIndex:index];
            const struct sockaddr *address = [data bytes];
            if (address == NULL) {
                error = 0x27;
                break;
            }
            if (address->sa_family != AF_INET) {
                continue;
            }
            int descriptor = socket(AF_INET, SOCK_STREAM, 0);
            if (descriptor <= 0) {
                error = errno;
                if (error == 0) {
                    return;
                }
                break;
            }
            if (connect(descriptor, address, (socklen_t)[data length]) != 0) {
                error = errno;
                close(descriptor);
                if (error == 0) {
                    return;
                }
                break;
            }
            NSFileHandle *handle = [[NSFileHandle alloc] initWithFileDescriptor:descriptor closeOnDealloc:YES];
            if (handle == nil) {
                close(descriptor);
                error = EBADF;
                break;
            }
            const struct sockaddr_in *inetAddress = (const struct sockaddr_in *)address;
            char buffer[256];
            NSNumber *port = nil;
            NSString *ipAddress = nil;
            if (inet_ntop(AF_INET, &inetAddress->sin_addr, buffer, sizeof(buffer)) != NULL) {
                port = [NSNumber numberWithUnsignedShort:ntohs(inetAddress->sin_port)];
                ipAddress = [NSString stringWithUTF8String:buffer];
            }
            if ([_delegate respondsToSelector:@selector(listeningConnection:isEstablishedForItem:properties:)]) {
                NSDictionary *properties = [[NSDictionary alloc] initWithObjectsAndKeys:ipAddress, @"SRConnectionIPAddress", port, @"SRConnectionPort", nil];
                [_delegate listeningConnection:handle isEstablishedForItem:self properties:properties];
                [properties release];
            }
            [handle release];
        }
        if (error == 0) {
            return;
        }
    }
    if ([_delegate respondsToSelector:@selector(connectionWithItem:didRefusedWithError:)]) {
        [_delegate connectionWithItem:self didRefusedWithError:error];
    }
}

- (void)refuseConnection
{
    [_service stop];
}

- (NSInteger)establishListeningConnectionWithTimeout:(double)aTimeout
{
    int iVar1;
    double dVar2;

    if (_service == nil) {
        iVar1 = -72000;
    }
    else {
        dVar2 = 5.0;
        if (aTimeout != 0.0) {
            dVar2 = aTimeout;
        }
        [_service resolveWithTimeout:dVar2];
        iVar1 = 0;
    }
    return iVar1;
}

- (unsigned short)port
{
    return 0xffff;
}

- (BOOL)isProvider
{
    return NO;
}

- (id)domain
{
    return [_service domain];
}

- (id)name
{
    return _serviceName;
}

- (id)identifier
{
    return _serviceType;
}

- (id)delegate
{
    return _delegate;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (NSUInteger)unlink
{
    unsigned int uVar1;

    uVar1 = _linksCounter - 1;
    _linksCounter = uVar1;
    return uVar1;
}

- (NSUInteger)link
{
    unsigned int uVar1;

    uVar1 = _linksCounter + 1;
    _linksCounter = uVar1;
    return uVar1;
}

- (void)dealloc
{
    _consumer = nil;
    [_service setDelegate:0];
    [_service stop];
    [_service release];
    [_serviceType release];
    [_serviceName release];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024b6aa @ 0024b6aa, 252 bytes * /

id FUN_0024b6aa(SRServiceListener *self,SEL _cmd,id initWithNetService,id consumer)

{
  SRServiceListener *pSVar1;
  id pvVar2;
  SRServiceListener *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_NSObject_00355c10;
  pSVar1 = _objc_msgSendSuper(&local_1c,sel_init);
  if (pSVar1 != (SRServiceListener *)0x0) {
    pvVar2 = _objc_msgSend(initWithNetService,sel_retain);
    pSVar1->_service = pvVar2;
    if (pvVar2 != (id)0x0) {
      pSVar1->_consumer = consumer;
      pvVar2 = _objc_msgSend(pvVar2,sel_type);
      pvVar2 = _objc_msgSend(pvVar2,sel_retain);
      pSVar1->_serviceType = pvVar2;
      pvVar2 = _objc_msgSend(pSVar1->_service,sel_name);
      pvVar2 = _objc_msgSend(pvVar2,sel_retain);
      pSVar1->_serviceName = pvVar2;
      _objc_msgSend(pSVar1->_service,sel_setDelegate_,pSVar1);
      pSVar1->_linksCounter = 1;
      return pSVar1;
    }
    local_18 = PTR_s_NSObject_00355c10;
    local_1c = pSVar1;
    _objc_msgSendSuper(&local_1c,sel_release);
  }
  return (id)0x0;
}

*/
- (id)initWithNetService:(id)aService consumer:(id)aConsumer
{
    self = [super init];
    if (self != nil) {
        _service = [aService retain];
        if (_service == nil) {
            [self release];
            return nil;
        }
        _consumer = aConsumer;
        _serviceType = [[_service type] retain];
        _serviceName = [[_service name] retain];
        [_service setDelegate:self];
        _linksCounter = 1;
    }
    return self;
}

@end

@implementation SRServiceProvider

/* i386 ivar offsets: _serviceHandle=0x1c, _servicePort=0x20, _serviceDescriptor=0x24 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024bebe @ 0024bebe, 429 bytes * /

void FUN_0024bebe(SRServiceProvider *self,SEL _cmd,id SRServiceProvider_connectionReceived)

{
  undefined *self_00;
  id pvVar1;
  SRServiceProvider *pSVar2;
  SRServiceProvider *pSVar3;
  id pvVar4;
  SEL op;
  cfstringStruct *pcVar5;
  
  pvVar1 = _objc_msgSend(SRServiceProvider_connectionReceived,sel_userInfo);
  pcVar5 = &cfstr_NSFileHandleError;
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_NSFileHandleError);
  pSVar2 = _objc_msgSend(pvVar1,sel_intValue);
  if (pSVar2 == (SRServiceProvider *)0x0) {
    pvVar1 = _objc_msgSend(SRServiceProvider_connectionReceived,sel_userInfo,pcVar5);
    pcVar5 = *(cfstringStruct **)PTR_003368c0;
    pSVar3 = _objc_msgSend(pvVar1,sel_objectForKey_,pcVar5);
    if (pSVar3 == (SRServiceProvider *)0x0) {
      pSVar2 = (SRServiceProvider *)0x16;
    }
  }
  else {
    pSVar3 = (SRServiceProvider *)0x0;
  }
  pvVar1 = _objc_msgSend(SRServiceProvider_connectionReceived,sel_object,pcVar5);
  _objc_msgSend(pvVar1,sel_acceptConnectionInBackgroundAndNotify);
  pvVar1 = (self->super)._delegate;
  if (pSVar2 == (SRServiceProvider *)0x0) {
    pvVar1 = _objc_msgSend(pvVar1,sel_respondsToSelector_,
                           sel_providingConnection_isEstablishedForItem_properties_);
    self_00 = cls_NSDictionary;
    if ((char)pvVar1 == '\0') {
      return;
    }
    pvVar1 = (self->super)._delegate;
    pvVar4 = _objc_msgSend(cls_NSNumber,sel_numberWithUnsignedInt_,(uint)self->_servicePort);
    _objc_msgSend(self_00,sel_dictionaryWithObject_forKey_,pvVar4,&cfstr_SRConnectionPort);
    op = sel_providingConnection_isEstablishedForItem_properties_;
  }
  else {
    pvVar1 = _objc_msgSend(pvVar1,sel_respondsToSelector_,
                           sel_connectionWithItem_didRefusedWithError_);
    if ((char)pvVar1 == '\0') {
      return;
    }
    pvVar1 = (self->super)._delegate;
    op = sel_connectionWithItem_didRefusedWithError_;
    pSVar3 = self;
    self = pSVar2;
  }
  _objc_msgSend(pvVar1,op,pSVar3,self);
  return;
}

*/
- (void)SRServiceProvider_connectionReceived:(id)aReceived
{
    NSDictionary *userInfo = [aReceived userInfo];
    int error = [[userInfo objectForKey:@"NSFileHandleError"] intValue];
    NSFileHandle *handle = nil;
    if (error == 0) {
        handle = [[aReceived userInfo] objectForKey:NSFileHandleNotificationFileHandleItem];
        if (handle == nil) {
            error = EINVAL;
        }
    }
    [[aReceived object] acceptConnectionInBackgroundAndNotify];
    if (error == 0) {
        if ([_delegate respondsToSelector:@selector(providingConnection:isEstablishedForItem:properties:)]) {
            [_delegate providingConnection:handle isEstablishedForItem:self properties:[NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:_servicePort] forKey:@"SRConnectionPort"]];
        }
    }
    else if ([_delegate respondsToSelector:@selector(connectionWithItem:didRefusedWithError:)]) {
        [_delegate connectionWithItem:self didRefusedWithError:error];
    }
}

- (void)netServiceDidStop:(id)aStop
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleConnectionAcceptedNotification object:_serviceHandle];
    [_serviceHandle release];
    _serviceHandle = nil;
    [_consumer netServiceConnection:self didRefusedWithError:0];
}

- (void)netService:(id)aService didNotPublish:(id)aPublish
{
    [_consumer netServiceConnection:self didRefusedWithError:[[aPublish objectForKey:NSNetServicesErrorCode] intValue]];
}

- (void)netServiceWillPublish:(id)aPublish
{
    id pvVar1;
    int iVar2;
    id pvVar1_2;

    pvVar1 = [NSFileHandle alloc];
    iVar2 = _serviceDescriptor;
    pvVar1_2 = [pvVar1 initWithFileDescriptor:iVar2 closeOnDealloc:YES];
    if (pvVar1_2 != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SRServiceProvider:connectionReceived:) name:NSFileHandleConnectionAcceptedNotification object:pvVar1_2];
        [pvVar1_2 acceptConnectionInBackgroundAndNotify];
        _serviceHandle = pvVar1_2;
        [_consumer netServiceConnectionWillStart:self];
    }
}

- (NSInteger)establishListeningConnectionWithTimeout:(double)aTimeout
{
    return -0x11946;
}

- (unsigned short)port
{
    return _servicePort;
}

- (BOOL)isProvider
{
    return YES;
}

- (void)publish
{
    [_service publish];
}

- (NSUInteger)unlink
{
    return 0;
}

- (NSUInteger)link
{
    return 0;
}

- (void)refuseConnection
{
    if (_serviceHandle != nil) {
        [_service stop];
    }
}

- (void)dealloc
{
    if (_serviceHandle == nil) {
        close(_serviceDescriptor);
    }
    else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleConnectionAcceptedNotification object:_serviceHandle];
        [_serviceHandle release];
    }
    [super dealloc];
}

- (id)initWithIdentifier:(id)aIdentifier name:(id)aName port:(unsigned short)aPort communicationDescriptor:(NSInteger)aDescriptor consumer:(id)aConsumer
{
    unsigned int uVar1;
    id pvVar2_2;

    if ((((aIdentifier != nil) && (aName != nil)) && (uVar1 = (unsigned int)aPort, aPort != 0xffff)) && (aDescriptor != -1)) {
        pvVar2_2 = [[NSNetService alloc] initWithDomain:@"" type:aIdentifier name:aName port:uVar1];
        if (pvVar2_2 != nil) {
            self = [super initWithNetService:pvVar2_2 consumer:aConsumer];
            [pvVar2_2 release];
            self = nil;
            if (self != nil) {
                _servicePort = aPort;
                _serviceDescriptor = aDescriptor;
                return self;
            }
        }
    }
    [self release];
    return nil;
}

@end

@implementation SRNetworkItem

/* i386 ivar offsets: _identifier=0x4, _browser=0x8, _providers=0xc, _foundItems=0x10, _delegate=0x14, _isMonitoring=0x18 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024aca9 @ 0024aca9, 309 bytes * /

void FUN_0024aca9(SRNetworkItem *self,SEL _cmd,id netServiceConnection,int didRefusedWithError)

{
  id pvVar1;
  id pvVar2;
  SRNetworkItem *pSVar3;
  
  pvVar1 = _objc_msgSend(netServiceConnection,sel_name);
  pvVar2 = _objc_msgSend(self->_providers,sel_objectForKey_,pvVar1);
  pvVar2 = _objc_msgSend(pvVar2,sel_retain);
  if (pvVar2 != (id)0x0) {
    _objc_msgSend(self->_providers,sel_removeObjectForKey_,pvVar1);
    pSVar3 = (SRNetworkItem *)sel_networkItem_didRemoveConnectionItem_withError_;
    pvVar1 = _objc_msgSend(self->_delegate,sel_respondsToSelector_,
                           sel_networkItem_didRemoveConnectionItem_withError_);
    if ((char)pvVar1 != '\0') {
      pSVar3 = self;
      _objc_msgSend(self->_delegate,sel_networkItem_didRemoveConnectionItem_withError_,self,
                    netServiceConnection,didRefusedWithError);
    }
    pvVar1 = _objc_msgSend(self->_providers,sel_count,pSVar3);
    if (pvVar1 == (id)0x1) {
      pSVar3 = (SRNetworkItem *)sel_providingDidFinishedForItem_;
      pvVar1 = _objc_msgSend(self->_delegate,sel_respondsToSelector_,
                             sel_providingDidFinishedForItem_);
      if ((char)pvVar1 != '\0') {
        _objc_msgSend(self->_delegate,sel_providingDidFinishedForItem_,self);
        pSVar3 = self;
      }
    }
    _objc_msgSend(pvVar2,sel_autorelease,pSVar3);
  }
  return;
}

*/
- (void)netServiceConnection:(id)aConnection didRefusedWithError:(NSInteger)aError
{
    id name = [(NSNetService *)aConnection name];
    id provider = [[_providers objectForKey:name] retain];
    if (provider != nil) {
        [_providers removeObjectForKey:name];
        if ([_delegate respondsToSelector:@selector(networkItem:didRemoveConnectionItem:withError:)]) {
            [_delegate networkItem:self didRemoveConnectionItem:aConnection withError:aError];
        }
        if ([_providers count] == 1 && [_delegate respondsToSelector:@selector(providingDidFinishedForItem:)]) {
            [_delegate providingDidFinishedForItem:self];
        }
        [provider autorelease];
    }
}

- (void)netServiceConnectionWillStart:(id)aStart
{
    if ([_providers count] == 0x1) {
        if ([_delegate respondsToSelector:@selector(providingWillStartForItem:)]) {
            [_delegate providingWillStartForItem:self];
        }
    }
    if ([_delegate respondsToSelector:@selector(networkItem:didFindConnectionItem:)]) {
        [_delegate networkItem:self didFindConnectionItem:aStart];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024ae8f @ 0024ae8f, 252 bytes * /

void FUN_0024ae8f(SRNetworkItem *self,SEL _cmd,id netServiceBrowser,id didRemoveService,
                 BOOL moreComing)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  id pvVar3;
  SRNetworkItem *pSVar4;
  
  pvVar1 = _objc_msgSend(didRemoveService,sel_name);
  pvVar3 = pvVar1;
  self_00 = _objc_msgSend(self->_foundItems,sel_objectForKey_,pvVar1);
  if (self_00 != (id)0x0) {
    pvVar2 = _objc_msgSend(self_00,sel_unlink,pvVar3);
    if (pvVar2 == (id)0x0) {
      _objc_msgSend(self_00,sel_retain,pvVar3);
      _objc_msgSend(self->_foundItems,sel_removeObjectForKey_,pvVar1);
      pSVar4 = (SRNetworkItem *)sel_networkItem_didRemoveConnectionItem_withError_;
      pvVar3 = _objc_msgSend(self->_delegate,sel_respondsToSelector_,
                             sel_networkItem_didRemoveConnectionItem_withError_);
      if ((char)pvVar3 != '\0') {
        _objc_msgSend(self->_delegate,sel_networkItem_didRemoveConnectionItem_withError_,self,
                      self_00,0);
        pSVar4 = self;
      }
      _objc_msgSend(self_00,sel_autorelease,pSVar4);
    }
  }
  return;
}

*/
- (void)netServiceBrowser:(id)aBrowser didRemoveService:(id)aService moreComing:(BOOL)aComing
{
    id name = [(NSNetService *)aService name];
    id item = [_foundItems objectForKey:name];
    if (item != nil && [item unlink] == 0) {
        [item retain];
        [_foundItems removeObjectForKey:name];
        if ([_delegate respondsToSelector:@selector(networkItem:didRemoveConnectionItem:withError:)]) {
            [_delegate networkItem:self didRemoveConnectionItem:item withError:0];
        }
        [item autorelease];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024af8b @ 0024af8b, 384 bytes * /

void FUN_0024af8b(SRNetworkItem *self,SEL _cmd,id netServiceBrowser,id didFindService,
                 BOOL moreComing)

{
  SRNetworkItem *pSVar1;
  id pvVar2;
  SRNetworkItem *pSVar3;
  id pvVar4;
  SEL op;
  SRNetworkItem *pSVar5;
  
  pSVar1 = _objc_msgSend(didFindService,sel_name);
  pSVar3 = pSVar1;
  pvVar2 = _objc_msgSend(self->_foundItems,sel_objectForKey_,pSVar1);
  op = sel_link;
  if (pvVar2 == (id)0x0) {
    pvVar2 = _objc_msgSend(cls_SRServiceListener,sel_alloc,pSVar3);
    pSVar3 = _objc_msgSend(pvVar2,sel_initWithNetService_consumer_,didFindService,self);
    if (pSVar3 == (SRNetworkItem *)0x0) {
      return;
    }
    _objc_msgSend(self->_foundItems,sel_setObject_forKey_,pSVar3,pSVar1);
    pSVar5 = (SRNetworkItem *)sel_networkItem_didFindConnectionItem_;
    pvVar2 = _objc_msgSend(self->_delegate,sel_respondsToSelector_,
                           sel_networkItem_didFindConnectionItem_);
    if ((char)pvVar2 != '\0') {
      pSVar5 = self;
      pSVar1 = pSVar3;
      _objc_msgSend(self->_delegate,sel_networkItem_didFindConnectionItem_,self,pSVar3);
    }
    _objc_msgSend(pSVar3,sel_release,pSVar5,pSVar1);
    if (moreComing != '\0') {
      return;
    }
    pvVar2 = _objc_msgSend(self->_delegate,sel_respondsToSelector_,
                           sel_stopMonitoringWhenLastConnectionDidFindForItem_,pSVar1);
    if ((char)pvVar2 == '\0') {
      return;
    }
    pvVar4 = _objc_msgSend(self->_delegate,sel_stopMonitoringWhenLastConnectionDidFindForItem_,self,
                           pSVar1);
    pvVar2 = netServiceBrowser;
    op = sel_stop;
    pSVar3 = self;
    if ((char)pvVar4 == '\0') {
      return;
    }
  }
  _objc_msgSend(pvVar2,op,pSVar3);
  return;
}

*/
- (void)netServiceBrowser:(id)aBrowser didFindService:(id)aService moreComing:(BOOL)aComing
{
    id name = [(NSNetService *)aService name];
    id item = [_foundItems objectForKey:name];
    if (item != nil) {
        [(SRServiceListener *)item link];
        return;
    }
    item = [[SRServiceListener alloc] initWithNetService:aService consumer:self];
    if (item == nil) {
        return;
    }
    [_foundItems setObject:item forKey:name];
    if ([_delegate respondsToSelector:@selector(networkItem:didFindConnectionItem:)]) {
        [_delegate networkItem:self didFindConnectionItem:item];
    }
    [item release];
    if (aComing) {
        return;
    }
    if ([_delegate respondsToSelector:@selector(stopMonitoringWhenLastConnectionDidFindForItem:)] && [_delegate stopMonitoringWhenLastConnectionDidFindForItem:self]) {
        [(NSNetServiceBrowser *)aBrowser stop];
    }
}

- (void)netServiceBrowser:(id)aBrowser didNotSearch:(id)aSearch
{
    if ((_isMonitoring & 1) != 0) {
        [self SRNetworkItem_cleanupMonitoring];
    }
    if ([_delegate respondsToSelector:@selector(monitoringDidFinishedForItem:withError:)]) {
        [_delegate monitoringDidFinishedForItem:self withError:[[aSearch objectForKey:NSNetServicesErrorCode] intValue]];
    }
}

- (void)netServiceBrowserDidStopSearch:(id)aSearch
{
    if ((_isMonitoring & 1) != 0) {
        [self SRNetworkItem_cleanupMonitoring];
    }
    if ([_delegate respondsToSelector:@selector(monitoringDidFinishedForItem:withError:)]) {
        [_delegate monitoringDidFinishedForItem:self withError:0];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024b224 @ 0024b224, 77 bytes * /

void FUN_0024b224(SRNetworkItem *self,SEL _cmd)

{
  _objc_msgSend(self->_foundItems,sel_removeAllObjects);
  _objc_msgSend(self->_browser,sel_release);
  self->_browser = (id)0x0;
  *(byte *)&self->_isMonitoring = (byte)self->_isMonitoring & 0xfe;
  return;
}

*/
- (void)SRNetworkItem_cleanupMonitoring
{
    [_foundItems removeAllObjects];
    [_browser release];
    _browser = nil;
    _isMonitoring = 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024b271 @ 0024b271, 88 bytes * /

void FUN_0024b271(SRNetworkItem *self,SEL _cmd,id netServiceBrowserWillSearch)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self->_delegate,sel_respondsToSelector_,sel_monitoringWillStartForItem_);
  if ((char)pvVar1 != '\0') {
    _objc_msgSend(self->_delegate,sel_monitoringWillStartForItem_,self);
  }
  *(byte *)&self->_isMonitoring = (byte)self->_isMonitoring | 1;
  return;
}

*/
- (void)netServiceBrowserWillSearch:(id)aSearch
{
    if ([_delegate respondsToSelector:@selector(monitoringWillStartForItem:)]) {
        [_delegate monitoringWillStartForItem:self];
    }
    _isMonitoring = 1;
}

- (BOOL)isItemActive
{
    BOOL bVar2;

    if ((_isMonitoring & 1) == 0) {
        bVar2 = [_providers count] != 0;
    }
    else {
        bVar2 = YES;
    }
    return bVar2;
}

- (void)stopMonitoring
{
    [_browser stop];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024b330 @ 0024b330, 130 bytes * /

int FUN_0024b330(SRNetworkItem *self,SEL _cmd)

{
  id self_00;
  
  if (self->_browser == (id)0x0) {
    self_00 = _objc_msgSend(cls_NSNetServiceBrowser,sel_new);
    self->_browser = self_00;
    if (self_00 == (id)0x0) {
      return -72000;
    }
    _objc_msgSend(self_00,sel_setDelegate_,self);
    _objc_msgSend(self->_browser,sel_searchForServicesOfType_inDomain_,self->_identifier,
                  &cfstr_empty);
  }
  return 0;
}

*/
- (NSInteger)startMonitoring
{
    if (_browser == nil) {
        _browser = [NSNetServiceBrowser new];
        if (_browser == nil) {
            return -72000;
        }
        [_browser setDelegate:(id)self];
        [_browser searchForServicesOfType:_identifier inDomain:@""];
    }
    return 0;
}

- (void)stopProviding
{
    [[_providers allValues] makeObjectsPerformSelector:@selector(refuseConnection)];
}

- (void)stopProvidingForName:(id)aName
{
    if (aName != nil) {
        [[_providers objectForKey:aName] refuseConnection];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024b441 @ 0024b441, 426 bytes * /

int FUN_0024b441(SRNetworkItem *self,SEL _cmd,id startProvidingWithName)

{
  undefined1 auVar1 [16];
  undefined4 uVar2;
  sockaddr sVar3;
  undefined2 uVar4;
  int iVar5;
  id pvVar6;
  int iVar7;
  uint uVar8;
  SRNetworkItem *pSVar9;
  socklen_t local_30;
  sockaddr local_2c;
  
  if (startProvidingWithName == (id)0x0) {
    iVar5 = -0x11944;
  }
  else {
    pvVar6 = _objc_msgSend(self->_providers,sel_objectForKey_,startProvidingWithName);
    if (pvVar6 == (id)0x0) {
      iVar5 = _socket(2,1,0);
      if (0 < iVar5) {
        local_2c.sa_data = SUB1614((undefined1  [16])0x0,2);
        local_2c.sa_len = '\0';
        local_2c.sa_family = '\x02';
        sVar3 = local_2c;
        local_2c._0_4_ = sVar3._0_4_;
        uVar2 = local_2c._0_4_;
        auVar1._8_8_ = 0;
        auVar1[0] = local_2c.sa_data[6];
        auVar1[1] = local_2c.sa_data[7];
        auVar1[2] = local_2c.sa_data[8];
        auVar1[3] = local_2c.sa_data[9];
        auVar1[4] = local_2c.sa_data[10];
        auVar1[5] = local_2c.sa_data[0xb];
        auVar1[6] = local_2c.sa_data[0xc];
        auVar1[7] = local_2c.sa_data[0xd];
        local_2c = (sockaddr)(auVar1 << 0x40);
        local_2c = (sockaddr)CONCAT124(local_2c.sa_data._2_12_,uVar2);
        iVar7 = _bind(iVar5,&local_2c,0x10);
        if (iVar7 == 0) {
          local_30 = 0x10;
          iVar7 = _getsockname(iVar5,&local_2c,&local_30);
          if (iVar7 == 0) {
            uVar4 = local_2c.sa_data._0_2_;
            iVar7 = _listen(iVar5,1);
            if (iVar7 == 0) {
              pvVar6 = _objc_msgSend(cls_SRServiceProvider,sel_alloc);
              uVar8 = (uint)(ushort)(uVar4 << 8 | (ushort)uVar4 >> 8);
              iVar7 = iVar5;
              pSVar9 = self;
              pvVar6 = _objc_msgSend(pvVar6,
                                     sel_initWithIdentifier_name_port_communicationDescriptor_consumer_
                                     ,self->_identifier,startProvidingWithName,uVar8,iVar5,self);
              if (pvVar6 != (id)0x0) {
                _objc_msgSend(self->_providers,sel_setObject_forKey_,pvVar6,startProvidingWithName,
                              uVar8,iVar7,pSVar9);
                _objc_msgSend(pvVar6,sel_publish);
                _objc_msgSend(pvVar6,sel_release);
                return 0;
              }
            }
          }
        }
      }
      if (iVar5 != -1) {
        _close(iVar5);
      }
      iVar5 = -72000;
    }
    else {
      iVar5 = -0x11941;
    }
  }
  return iVar5;
}

*/
- (NSInteger)startProvidingWithName:(id)aName
{
    if (aName == nil) {
        return -72004;
    }
    if ([_providers objectForKey:aName] != nil) {
        return -72001;
    }
    int descriptor = socket(AF_INET, SOCK_STREAM, 0);
    if (descriptor > 0) {
        struct sockaddr_in address;
        memset(&address, 0, sizeof(address));
        address.sin_family = AF_INET;
        if (bind(descriptor, (struct sockaddr *)&address, sizeof(address)) == 0) {
            socklen_t length = sizeof(address);
            if (getsockname(descriptor, (struct sockaddr *)&address, &length) == 0) {
                unsigned short port = ntohs(address.sin_port);
                if (listen(descriptor, 1) == 0) {
                    id provider = [[SRServiceProvider alloc] initWithIdentifier:_identifier name:aName port:port communicationDescriptor:descriptor consumer:self];
                    if (provider != nil) {
                        [_providers setObject:provider forKey:aName];
                        [provider publish];
                        [provider release];
                        return 0;
                    }
                }
            }
        }
    }
    if (descriptor != -1) {
        close(descriptor);
    }
    return -72000;
}

- (id)delegate
{
    return _delegate;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)identifier
{
    return _identifier;
}

- (void)dealloc
{
    [_browser setDelegate:0];
    [_browser stop];
    [_browser release];
    [_providers release];
    [_foundItems release];
    [_identifier release];
    [super dealloc];
}

- (id)initWithIdentifier:(id)aIdentifier
{
    id pvVar2;

    self = [super init];
    if (self != nil) {
        pvVar2 = [aIdentifier copy];
        _identifier = pvVar2;
        if (pvVar2 != nil) {
            pvVar2 = [NSMutableDictionary new];
            _providers = pvVar2;
            if (pvVar2 != nil) {
                pvVar2 = [NSMutableDictionary new];
                _foundItems = pvVar2;
                if (pvVar2 != nil) {
                    return self;
                }
            }
        }
        [super release];
    }
    return nil;
}

@end

