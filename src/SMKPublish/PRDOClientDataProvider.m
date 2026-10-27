#import "PRDOClientDataProvider.h"

// Browses for published servers and presents them as one tree: the root
// items are the server names (NSStrings), below them PRDOClientItems.
// Answers come back as transactions (see PTransaction).

// Server name keys; equality is identity, as in the original.
static NSUInteger PRDOClientDataProviderHash(NSMapTable *aTable, const void *aKey)
{
    return [(id)aKey hash];
}

static BOOL PRDOClientDataProviderIsEqual(NSMapTable *aTable, const void *aKey, const void *aKey2)
{
    return aKey == aKey2;
}

static void PRDOClientDataProviderRetain(NSMapTable *aTable, const void *aKey)
{
    [(id)aKey retain];
}

static void PRDOClientDataProviderRelease(NSMapTable *aTable, void *aKey)
{
    [(id)aKey release];
}

static NSString *PRDOClientDataProviderDescribe(NSMapTable *aTable, const void *aKey)
{
    return [(id)aKey description];
}

@implementation PRDOClientDataProvider

- (void)timeoutFlushCacheToAdd:(id)aAdd
{
    [self flushCacheToAdd];
}

- (void)removeNetService:(id)aService
{
    [self netServiceBrowser:_netServiceBrowser didRemoveService:aService moreComing:NO];
}

- (void)serverConnectionDidDieWithNetService:(id)aService
{
    [self performSelectorOnMainThread:@selector(removeNetService:) withObject:aService waitUntilDone:NO];
}

- (id)clientNameForIndex:(NSInteger)aIndex
{
    NSMapEnumerator enumerator = NSEnumerateMapTable(_clients);
    void *name = NULL, *client = NULL;
    id found = nil;
    NSInteger i = 0;
    while (NSNextMapEnumeratorPair(&enumerator, &name, &client)) {
        if (aIndex == i) {
            found = name;
            break;
        }
        i++;
    }
    NSEndMapTableEnumeration(&enumerator);
    return found;
}

- (id)clientForName:(id)aName
{
    return NSMapGet(_clients, aName);
}

- (void)clientDidChange:(id)aChange
{
    id serverName = [[aChange object] serverName];
    id item = [[aChange userInfo] objectForKey:PRDOClientReloadServerItemKey];
    [self reloadItem:item ofServer:serverName];
}

// With aRemove, drops the client of that service (and returns NO).
- (BOOL)isNetServiceRegistred:(id)aRegistred remove:(BOOL)aRemove
{
    NSMapEnumerator enumerator = NSEnumerateMapTable(_clients);
    void *name = NULL;
    PRDOClient *client = nil;
    BOOL found = NO;
    while (NSNextMapEnumeratorPair(&enumerator, &name, (void **)&client)) {
        if (![[client netService] isEqual:aRegistred])
            continue;
        if (!aRemove) {
            found = YES;
        } else {
            [self removeServer:name];
            [client setDelegate:nil];
            [client disconnectFromServer];
            NSMapRemove(_clients, name);
        }
        break;
    }
    NSEndMapTableEnumeration(&enumerator);
    return found;
}

- (void)flushCacheToRemove
{
    [_addRemoveServicesLock lock];
    NSEnumerator *enumerator = [_cacheToRemove objectEnumerator];
    id service;
    while ((service = [enumerator nextObject]) != nil) {
        [self isNetServiceRegistred:service remove:YES];
        [_cacheToAdd removeObject:service];
    }
    [_cacheToRemove removeAllObjects];
    [_addRemoveServicesLock unlock];
}

- (void)flushCacheToAdd
{
    [_addRemoveServicesLock lock];
    NSEnumerator *enumerator = [_cacheToAdd objectEnumerator];
    NSNetService *service;
    while ((service = [enumerator nextObject]) != nil) {
        [service setDelegate:(id)self];
        [service resolveWithTimeout:0.0];
        [_resolvingServices addObject:service];
    }
    [_cacheToAdd removeAllObjects];
    [_addRemoveServicesLock unlock];
}

- (void)netServiceDidResolveAddress:(id)aAddress
{
    if ([self isNetServiceRegistred:aAddress remove:NO])
        return;
    PRDOClient *client = [[PRDOClient allocWithZone:[self zone]] initWithNetService:aAddress];
    if (client == nil)
        return;
    [client setDelegate:self];
    id name = [PRDOClient serverNameFromFullName:[(NSNetService *)aAddress name]];
    NSMapInsert(_clients, name, client);
    [client release];
    [self addServer:name];
    [_resolvingServices removeObject:aAddress];
}

- (void)netService:(id)aService didNotResolve:(id)aResolve
{
    [_resolvingServices removeObject:aService];
}

- (void)netServiceBrowser:(id)aBrowser didRemoveService:(id)aService moreComing:(BOOL)aComing
{
    [_cacheToRemove addObject:aService];
    if (!aComing)
        [self flushCacheToRemove];
}

- (void)netServiceBrowser:(id)aBrowser didRemoveDomain:(id)aDomain moreComing:(BOOL)aComing
{
}

// Found services are resolved in groups, or 5 s after the last one.
- (void)netServiceBrowser:(id)aBrowser didFindService:(id)aService moreComing:(BOOL)aComing
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeoutFlushCacheToAdd:) object:nil];
    [_cacheToAdd addObject:aService];
    if (!aComing)
        [self flushCacheToAdd];
    else
        [self performSelector:@selector(timeoutFlushCacheToAdd:) withObject:nil afterDelay:5.0];
}

- (void)netServiceBrowserDidStopSearch:(id)aSearch
{
    [NSAllMapTableValues(_clients) makeObjectsPerformSelector:@selector(setDelegate:) withObject:nil];
    [NSAllMapTableValues(_clients) makeObjectsPerformSelector:@selector(disconnectFromServer)];
    NSResetMapTable(_clients);
    [self reloadItem:nil ofServer:nil];
}

- (void)removeServer:(id)aServer
{
}

- (void)addServer:(id)aServer
{
}

- (void)reloadItem:(id)aItem ofServer:(id)aServer
{
}

- (void)disconnectServerByItem:(id)aItem
{
    if ([aItem isKindOfClass:[NSString class]])
        [[self clientForName:aItem] disconnectFromServer];
    else if ([aItem isKindOfClass:[PRDOClientItem class]])
        [aItem disconnectServer];
}

- (id)setObjectValue:(id)aValue forType:(id)aType byItem:(id)aItem password:(id)aPassword
{
    if (![aItem isKindOfClass:[PRDOClientItem class]])
        return nil;
    return [aItem setObjectValue:aValue forType:aType delegate:_delegate isSynchronous:_isSynchronous password:aPassword timeout:_timeout];
}

// A server's SMKPublishIpAddressKey is answered locally.
- (id)objectValueForType:(id)aType byItem:(id)aItem password:(id)aPassword
{
    if ([aItem isKindOfClass:[NSString class]] && [aType isKindOfClass:[NSString class]]
        && [aType isEqualToString:SMKPublishIpAddressKey]) {
        PRDOClient *client = [self clientForName:aItem];
        if (client == nil)
            return nil;
        return [PRDOObjectValueTransaction transactionWithObjectValue:[client ipAddress] delegate:_delegate isSynchronous:_isSynchronous];
    }
    if (![aItem isKindOfClass:[PRDOClientItem class]])
        return nil;
    return [aItem objectValueForType:aType delegate:_delegate isSynchronous:_isSynchronous password:aPassword timeout:_timeout];
}

- (id)numberOfChildrenOfItem:(id)aItem password:(id)aPassword
{
    if (aItem == nil)
        return [PRDOChildrenNumberTransaction transactionWithNumberOfChildren:NSCountMapTable(_clients) delegate:_delegate isSynchronous:_isSynchronous];
    if ([aItem isKindOfClass:[NSString class]]) {
        PRDOClient *client = [self clientForName:aItem];
        if (client == nil)
            return nil;
        return [PRDOChildrenNumberTransaction transactionWithClient:client delegate:_delegate isSynchronous:_isSynchronous password:aPassword timeout:_timeout];
    }
    if (![aItem isKindOfClass:[PRDOClientItem class]])
        return nil;
    return [aItem numberOfChildrenOfItemWithDelegate:_delegate isSynchronous:_isSynchronous password:aPassword timeout:_timeout];
}

- (id)isItemExpandable:(id)aExpandable password:(id)aPassword
{
    if (aExpandable == nil)
        return [PRDOExpandableTransaction transactionWithExpandable:YES delegate:_delegate isSynchronous:_isSynchronous];
    if ([aExpandable isKindOfClass:[NSString class]]) {
        PRDOClient *client = [self clientForName:aExpandable];
        if (client == nil)
            return nil;
        return [PRDOExpandableTransaction transactionWithClient:client delegate:_delegate isSynchronous:_isSynchronous password:aPassword timeout:_timeout];
    }
    if (![aExpandable isKindOfClass:[PRDOClientItem class]])
        return nil;
    return [aExpandable isItemExpandableWithDelegate:_delegate isSynchronous:_isSynchronous password:aPassword timeout:_timeout];
}

- (id)childForIndex:(NSInteger)aIndex ofItem:(id)aItem password:(id)aPassword
{
    if (aItem == nil) {
        if (aIndex < 0 || aIndex >= (NSInteger)NSCountMapTable(_clients))
            return nil;
        return [PRDOChildTransaction transactionWithChild:[self clientNameForIndex:aIndex] delegate:_delegate isSynchronous:_isSynchronous];
    }
    if ([aItem isKindOfClass:[NSString class]]) {
        PRDOClient *client = [self clientForName:aItem];
        if (client == nil)
            return nil;
        return [PRDOChildTransaction transactionWithClient:client index:aIndex delegate:_delegate isSynchronous:_isSynchronous password:aPassword timeout:_timeout];
    }
    if (![aItem isKindOfClass:[PRDOClientItem class]])
        return nil;
    return [aItem childForIndex:aIndex delegate:_delegate isSynchronous:_isSynchronous password:aPassword timeout:_timeout];
}

- (id)validatePassword:(id)aPassword forItem:(id)aItem
{
    if (aItem == nil)
        return [PRDOValidatePasswordTransaction transactionWithValidation:YES delegate:_delegate isSynchronous:_isSynchronous];
    if ([aItem isKindOfClass:[NSString class]])
        return [[self clientForName:aItem] validatePasswordForItem:nil delegate:_delegate isSynchronous:_isSynchronous password:aPassword timeout:_timeout];
    if (![aItem isKindOfClass:[PRDOClientItem class]])
        return nil;
    return [aItem validatePassword:aPassword delegate:_delegate isSynchronous:_isSynchronous timeout:_timeout];
}

- (id)isItemProtected:(id)aProtected
{
    if (aProtected == nil)
        return [PRDOProtectedTransaction transactionWithProtected:NO delegate:_delegate isSynchronous:_isSynchronous];
    if ([aProtected isKindOfClass:[NSString class]])
        return [[self clientForName:aProtected] isItemProtected:nil delegate:_delegate isSynchronous:_isSynchronous timeout:_timeout];
    if (![aProtected isKindOfClass:[PRDOClientItem class]])
        return nil;
    return [aProtected isProtectedWithdelegate:_delegate isSynchronous:_isSynchronous timeout:_timeout];
}

- (void)setTimeout:(double)aTimeout
{
    _timeout = aTimeout;
}

- (void)setIsSynchronous:(BOOL)aSynchronous
{
    _isSynchronous = aSynchronous;
}

- (void)stop
{
    [_netServiceBrowser stop];
    [(PTransactionManager *)[PTransactionManager sharedTransactionManager] stop];
}

- (void)start
{
    [(PTransactionManager *)[PTransactionManager sharedTransactionManager] start];
    [_netServiceBrowser searchForServicesOfType:_type inDomain:_domain];
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [(PTransactionManager *)[PTransactionManager sharedTransactionManager] stop];
    [_netServiceBrowser stop];
    [_netServiceBrowser release];
    [_domain release];
    [_type release];
    [_localName release];
    [_cacheToAdd release];
    [_cacheToRemove release];
    [_resolvingServices release];
    [_addRemoveServicesLock release];
    if (_clients != NULL)
        NSFreeMapTable(_clients);
    [super dealloc];
}

- (id)initWithDomain:(id)aDomain type:(id)aType localName:(id)aName
{
    self = [super init];
    if (self == nil)
        return nil;
    _domain = [aDomain retain];
    _type = [aType retain];
    _localName = [aName retain];
    _addRemoveServicesLock = [[NSRecursiveLock allocWithZone:[self zone]] init];
    _cacheToAdd = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:0];
    _cacheToRemove = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:0];
    _resolvingServices = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:0];
    _netServiceBrowser = [[NSNetServiceBrowser allocWithZone:[self zone]] init];
    [_netServiceBrowser setDelegate:(id)self];
    _isSynchronous = NO;
    _timeout = 0.0;
    NSMapTableKeyCallBacks keyCallBacks = {
        PRDOClientDataProviderHash, PRDOClientDataProviderIsEqual, PRDOClientDataProviderRetain,
        PRDOClientDataProviderRelease, PRDOClientDataProviderDescribe, NSNotAPointerMapKey
    };
    _clients = NSCreateMapTableWithZone(keyCallBacks, NSObjectMapValueCallBacks, 0, [self zone]);
    if (_clients == NULL) {
        [self release];
        return nil;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clientDidChange:) name:PRDOClientReloadServerNotificationName object:nil];
    return self;
}

- (id)init
{
    [self release];
    return nil;
}

@end
