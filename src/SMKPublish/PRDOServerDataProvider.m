#import "PRDOServerDataProvider.h"

// Base class for a published tree: subclasses answer the item questions;
// this class runs the server and tells the connected clients to reload.

@implementation PRDOServerDataProvider

- (void)notifyClientsAboutItemChangingThreadFunction:(id)aFunction
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    [_serverProviderLock lock];
    NSInteger count = [_clientsConnections count];
    for (NSInteger i = 0; i < count; i++) {
        @try {
            NSDistantObject *client = [[_clientsConnections objectAtIndex:i] rootProxy];
            [client setProtocolForProxy:@protocol(PRDOClientProtocol)];
            [(id<PRDOClientProtocol>)client reload:aFunction];
        } @catch (NSException *exception) {
            [self performSelectorOnMainThread:@selector(invalidateConnection:) withObject:[_clientsConnections objectAtIndex:i] waitUntilDone:NO];
        }
    }
    [_serverProviderLock unlock];
    _notifyThreadActive = NO;
    [pool release];
}

- (void)invalidateConnection:(id)aConnection
{
    [aConnection invalidate];
}

- (void)connectionDidDie:(id)aDie
{
    [_serverProviderLock lock];
    [self removeClientByIndex:[_clientsConnections indexOfObject:[aDie object]]];
    [_serverProviderLock unlock];
}

- (void)removeClientByIndex:(NSInteger)aIndex
{
    if (aIndex < 0 || aIndex >= (NSInteger)[_clientsConnections count])
        return;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSConnectionDidDieNotification object:[_clientsConnections objectAtIndex:aIndex]];
    [_clientsConnections removeObjectAtIndex:aIndex];
}

- (void)applicationWillTerminate:(id)aTerminate
{
    [self stop];
}

- (BOOL)setObjectValue:(id)aValue forType:(id)aType byItem:(id)aItem
{
    return NO;
}

- (id)objectValueForType:(id)aType byItem:(id)aItem
{
    return nil;
}

- (NSInteger)numberOfChildrenOfItem:(id)aItem
{
    return 0;
}

- (BOOL)isItemExpandable:(id)aExpandable
{
    return NO;
}

- (id)childForIndex:(NSInteger)aIndex ofItem:(id)aItem
{
    return nil;
}

// A client connected: keep its connection to notify it later.
- (void)addLocalClient:(id)aClient
{
    [_serverProviderLock lock];
    @try {
        NSConnection *connection = [aClient connectionForProxy];
        [connection setRequestTimeout:60.0];
        [connection setReplyTimeout:60.0];
        [_clientsConnections addObject:connection];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionDidDie:) name:NSConnectionDidDieNotification object:connection];
    } @catch (NSException *exception) {
    }
    [_serverProviderLock unlock];
}

- (void)serverDidStop:(id)aStop
{
    [self serverDidStop];
}

- (void)serverDidStart:(id)aStart
{
    [self serverDidStart];
}

// One notifying thread at a time; while one runs, retries on the next pass.
- (void)notifyClientsAboutItemChanging:(id)aChanging
{
    if (!_notifyThreadActive) {
        [NSThread detachNewThreadSelector:@selector(notifyClientsAboutItemChangingThreadFunction:) toTarget:self withObject:aChanging];
        _notifyThreadActive = YES;
    } else if ([self serverState] == 3) {
        [self performSelector:@selector(notifyClientsAboutItemChanging:) withObject:aChanging afterDelay:0.0];
    }
}

- (void)serverDidStop
{
}

- (void)serverDidStart
{
}

- (NSInteger)serverState
{
    return [_server serverState];
}

- (void)stop
{
    if ((NSUInteger)([self serverState] - 2) >= 2)
        return;
    [_serverProviderLock lock];
    // Invalidating a connection removes it (connectionDidDie:).
    NSUInteger count = [_clientsConnections count];
    for (NSUInteger i = 0; i != count; i++)
        [[_clientsConnections objectAtIndex:0] invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationWillTerminateNotification object:nil];
    [_server stop];
    [_serverProviderLock unlock];
}

- (void)start
{
    if ([self serverState] != 1)
        return;
    [_serverProviderLock lock];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:NSApplicationWillTerminateNotification object:nil];
    [_server start];
    [_serverProviderLock unlock];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_server setDelegate:nil];
    [_server stop];
    [_server destroy];
    [_clientsConnections release];
    [_serverProviderLock release];
    [super dealloc];
}

- (id)initWithDomain:(id)aDomain type:(id)aType name:(id)aName password:(id)aPassword
{
    self = [super init];
    if (self == nil)
        return nil;
    _server = [[PRDOServer allocWithZone:[self zone]] initWithDomain:aDomain type:aType name:aName delegate:self password:aPassword];
    _clientsConnections = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:0];
    _serverProviderLock = [[NSRecursiveLock allocWithZone:[self zone]] init];
    return self;
}

- (id)init
{
    [self release];
    return nil;
}

@end
