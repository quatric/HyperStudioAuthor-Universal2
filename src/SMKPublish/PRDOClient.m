#import "PRDOClient.h"
#import <arpa/inet.h>
#import <objc/message.h>

// The client side of a published server: a Distributed Objects connection
// to the address a Bonjour service resolved to. Requests come back as
// transactions (see PTransaction).

@implementation PRDOClient

// Published names end in "#<number>" (see -[PRDOServer start]); drops it.
+ (id)serverNameFromFullName:(id)aName
{
    NSRange range = [aName rangeOfString:@"#" options:NSBackwardsSearch];
    if (range.location == NSNotFound)
        return aName;
    if ([[aName substringFromIndex:range.location + 1] intValue] == 0)
        return aName;
    return [aName substringToIndex:range.location];
}

- (void)createServerConnection:(id)aConnection
{
    if (_rootProxy != nil)
        return;
    @try {
        _rootProxy = [[[self serverConnection] rootProxy] retain];
        [_rootProxy setProtocolForProxy:@protocol(PRDOServerProtocol)];
        [(id<PRDOServerProtocol>)_rootProxy addLocalClient:self];
    } @catch (NSException *exception) {
        [self unexpectedDisconnect];
    }
}

- (id)serverConnection
{
    if (_serverConnection == nil) {
        NSSocketPort *port = [[NSSocketPort allocWithZone:[self zone]] initRemoteWithTCPPort:_connectionPort host:_ipAddressString];
        _serverConnection = [[NSConnection allocWithZone:[self zone]] initWithReceivePort:nil sendPort:port];
        [_serverConnection setRequestTimeout:60.0];
        [_serverConnection setReplyTimeout:60.0];
        [_serverConnection setRootObject:self];
        [_serverConnection enableMultipleThreads];
        [_serverConnection addRequestMode:NSModalPanelRunLoopMode];
        [port release];
        _unexpectedDisconnect = NO;
        if (_serverConnection == nil)
            [self unexpectedDisconnect];
    }
    return _serverConnection;
}

// A nil item reloads everything (the root items are fetched again).
- (void)reloadItem:(id)aItem
{
    NSDictionary *userInfo;
    if (aItem == nil) {
        [_rootItems release];
        _rootItems = nil;
        userInfo = nil;
    } else {
        userInfo = [NSDictionary dictionaryWithObject:[PRDOClientItem itemWithClient:self serverItem:aItem]
                                               forKey:PRDOClientReloadServerItemKey];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:PRDOClientReloadServerNotificationName object:self userInfo:userInfo];
}

- (id)serverInterface
{
    if (_rootProxy == nil)
        [self performSelectorOnMainThread:@selector(createServerConnection:) withObject:nil waitUntilDone:YES];
    return _rootProxy;
}

- (BOOL)isUnexpectedDisconnect
{
    return _unexpectedDisconnect;
}

- (void)unexpectedDisconnect
{
    _unexpectedDisconnect = YES;
    if ([[self delegate] respondsToSelector:@selector(serverConnectionDidDieWithNetService:)])
        ((void (*)(id, SEL, id))objc_msgSend)([self delegate], @selector(serverConnectionDidDieWithNetService:), [self netService]);
}

- (id)ipAddress
{
    return _ipAddressString;
}

- (id)rootServerItemsWithPassword:(id)aPassword
{
    if (_rootItems != nil || _unexpectedDisconnect)
        return _rootItems;
    [_serverInterfaceLock lock];
    @try {
        NSInteger count = [(id<PRDOServerProtocol>)[self serverInterface] numberOfChildrenOfItem:nil password:aPassword];
        for (NSInteger i = 0; i < count; i++) {
            if (_rootItems == nil)
                _rootItems = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:0];
            [_rootItems addObject:[(id<PRDOServerProtocol>)[self serverInterface] childForIndex:i ofItem:nil password:aPassword]];
        }
    } @catch (NSException *exception) {
        [_rootItems release];
        _rootItems = nil;
        [self unexpectedDisconnect];
    }
    [_serverInterfaceLock unlock];
    return _rootItems;
}

- (void)reload:(id)aReload
{
    [self performSelectorOnMainThread:@selector(reloadItem:) withObject:aReload waitUntilDone:NO];
}

- (id)setObjectValue:(id)aValue forType:(id)aType byItem:(id)aItem delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout
{
    if (_unexpectedDisconnect)
        return nil;
    id transaction;
    [_serverInterfaceLock lock];
    @try {
        transaction = [PRDOSetObjectValueTransaction transactionWithServer:[self serverInterface] client:self objectValue:aValue valueType:aType item:aItem delegate:aDelegate isSynchronous:aSynchronous password:aPassword timeout:aTimeout];
    } @catch (NSException *exception) {
        [self unexpectedDisconnect];
        transaction = nil;
    }
    [_serverInterfaceLock unlock];
    return transaction;
}

// SMKPublishIpAddressKey is answered locally with the server's address.
- (id)objectValueForType:(id)aType byItem:(id)aItem delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout
{
    if (_unexpectedDisconnect)
        return nil;
    if ([aType isKindOfClass:[NSString class]] && [aType isEqualToString:SMKPublishIpAddressKey])
        return [PRDOObjectValueTransaction transactionWithObjectValue:_ipAddressString delegate:aDelegate isSynchronous:aSynchronous];
    id transaction;
    [_serverInterfaceLock lock];
    @try {
        transaction = [PRDOObjectValueTransaction transactionWithServer:[self serverInterface] client:self valueType:aType item:aItem delegate:aDelegate isSynchronous:aSynchronous password:aPassword timeout:aTimeout];
    } @catch (NSException *exception) {
        [self unexpectedDisconnect];
        transaction = nil;
    }
    [_serverInterfaceLock unlock];
    return transaction;
}

- (id)numberOfChildrenOfItem:(id)aItem delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout
{
    if (_unexpectedDisconnect)
        return nil;
    id transaction;
    [_serverInterfaceLock lock];
    @try {
        transaction = [PRDOChildrenNumberTransaction transactionWithServer:[self serverInterface] client:self item:aItem delegate:aDelegate isSynchronous:aSynchronous password:aPassword timeout:aTimeout];
    } @catch (NSException *exception) {
        [self unexpectedDisconnect];
        transaction = nil;
    }
    [_serverInterfaceLock unlock];
    return transaction;
}

- (id)isItemExpandable:(id)aExpandable delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout
{
    if (_unexpectedDisconnect)
        return nil;
    id transaction;
    [_serverInterfaceLock lock];
    @try {
        transaction = [PRDOExpandableTransaction transactionWithServer:[self serverInterface] client:self item:aExpandable delegate:aDelegate isSynchronous:aSynchronous password:aPassword timeout:aTimeout];
    } @catch (NSException *exception) {
        [self unexpectedDisconnect];
        transaction = nil;
    }
    [_serverInterfaceLock unlock];
    return transaction;
}

- (id)childForIndex:(NSInteger)aIndex ofItem:(id)aItem delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout
{
    if (_unexpectedDisconnect)
        return nil;
    id transaction;
    [_serverInterfaceLock lock];
    @try {
        transaction = [PRDOChildTransaction transactionWithServer:[self serverInterface] index:aIndex item:aItem client:self delegate:aDelegate isSynchronous:aSynchronous password:aPassword timeout:aTimeout];
    } @catch (NSException *exception) {
        [self unexpectedDisconnect];
        transaction = nil;
    }
    [_serverInterfaceLock unlock];
    return transaction;
}

- (id)validatePasswordForItem:(id)aItem delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout
{
    if (_unexpectedDisconnect)
        return nil;
    id transaction;
    [_serverInterfaceLock lock];
    @try {
        transaction = [PRDOValidatePasswordTransaction transactionWithServer:[self serverInterface] client:self item:aItem delegate:aDelegate isSynchronous:aSynchronous password:aPassword timeout:aTimeout];
    } @catch (NSException *exception) {
        [self unexpectedDisconnect];
        transaction = nil;
    }
    [_serverInterfaceLock unlock];
    return transaction;
}

- (id)isItemProtected:(id)aProtected delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous timeout:(double)aTimeout
{
    if (_unexpectedDisconnect)
        return nil;
    id transaction;
    [_serverInterfaceLock lock];
    @try {
        transaction = [PRDOProtectedTransaction transactionWithServer:[self serverInterface] client:self item:aProtected delegate:aDelegate isSynchronous:aSynchronous timeout:aTimeout];
    } @catch (NSException *exception) {
        [self unexpectedDisconnect];
        transaction = nil;
    }
    [_serverInterfaceLock unlock];
    return transaction;
}

- (id)serverName
{
    return [PRDOClient serverNameFromFullName:[(NSNetService *)[self netService] name]];
}

- (id)netService
{
    return _netService;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (void)disconnectFromServer
{
    [_serverInterfaceLock lock];
    [_rootItems release];
    _rootItems = nil;
    [_rootProxy release];
    _rootProxy = nil;
    [_serverConnection setRootObject:nil];
    [_serverConnection invalidate];
    [_serverConnection release];
    _serverConnection = nil;
    [_serverInterfaceLock unlock];
}

- (void)dealloc
{
    [_ipAddressString release];
    [_netService release];
    [_rootItems release];
    [_rootProxy release];
    [_serverConnection release];
    [_serverInterfaceLock release];
    [super dealloc];
}

// Takes the service's first IPv4 address; fails (nil) without one, or when
// the service is published by this machine.
- (id)initWithNetService:(id)aService
{
    self = [super init];
    if (self == nil)
        return nil;
    if ([[aService addresses] count] != 0) {
        NSEnumerator *enumerator = [[aService addresses] objectEnumerator];
        NSData *address;
        while ((address = [enumerator nextObject]) != nil) {
            const struct sockaddr_in *sin = [address bytes];
            char buffer[256];
            if (sin == NULL || sin->sin_family != AF_INET || inet_ntop(AF_INET, &sin->sin_addr, buffer, sizeof(buffer)) == NULL)
                continue;
            _ipAddressString = [[NSString allocWithZone:[self zone]] initWithCString:buffer encoding:NSASCIIStringEncoding];
            _connectionPort = ntohs(sin->sin_port);
            break;
        }
        if (_ipAddressString != nil && _connectionPort != 0
            && ![[PRDOServer localIPAddresses] containsObject:_ipAddressString]) {
            _netService = [aService retain];
            _serverInterfaceLock = [[NSRecursiveLock allocWithZone:[self zone]] init];
            return self;
        }
    }
    [self release];
    return nil;
}

- (id)init
{
    [self release];
    return nil;
}

@end
