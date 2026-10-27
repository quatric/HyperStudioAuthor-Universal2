#import "PRDOServer.h"
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <objc/message.h>

// Publishes a delegate's item tree over Distributed Objects, advertised
// with Bonjour. States: 1 stopped, 2 publishing, 3 running, 4 stopping.

@implementation PRDOServer

+ (id)localIPAddresses
{
    struct ifaddrs *list = NULL;
    NSMutableArray *addresses = nil;
    getifaddrs(&list);
    for (struct ifaddrs *entry = list; entry != NULL; entry = entry->ifa_next) {
        struct sockaddr *address = entry->ifa_addr;
        char buffer[256];
        if (address == NULL || address->sa_family != AF_INET
            || inet_ntop(AF_INET, &((struct sockaddr_in *)address)->sin_addr, buffer, sizeof(buffer)) == NULL)
            continue;
        NSString *string = [NSString stringWithCString:buffer encoding:NSASCIIStringEncoding];
        if (string == nil)
            continue;
        if (addresses == nil)
            addresses = [NSMutableArray arrayWithCapacity:0];
        [addresses addObject:string];
    }
    if (list != NULL)
        freeifaddrs(list);
    return addresses;
}

- (void)clenupServer
{
    [_netService setDelegate:nil];
    [_netService release];
    _netService = nil;
    [_connectionPort invalidate];
    [_connectionPort release];
    _connectionPort = nil;
    [_connection invalidate];
    [_connection release];
    _connection = nil;
    _serverState = 1;
    if (_destroyServer)
        [self autorelease];
}

- (BOOL)setObjectValue:(id)aValue forType:(id)aType byItem:(id)aItem password:(id)aPassword
{
    if ([self validatePassword:aPassword forItem:aItem] && [[self delegate] respondsToSelector:@selector(setObjectValue:forType:byItem:)])
        return ((BOOL (*)(id, SEL, id, id, id))objc_msgSend)([self delegate], @selector(setObjectValue:forType:byItem:), aValue, aType, aItem);
    return NO;
}

- (id)objectValueForType:(id)aType byItem:(id)aItem password:(id)aPassword
{
    if ([self validatePassword:aPassword forItem:aItem] && [[self delegate] respondsToSelector:@selector(objectValueForType:byItem:)])
        return ((id (*)(id, SEL, id, id))objc_msgSend)([self delegate], @selector(objectValueForType:byItem:), aType, aItem);
    return nil;
}

- (NSInteger)numberOfChildrenOfItem:(id)aItem password:(id)aPassword
{
    if ([self validatePassword:aPassword forItem:aItem] && [[self delegate] respondsToSelector:@selector(numberOfChildrenOfItem:)])
        return ((int (*)(id, SEL, id))objc_msgSend)([self delegate], @selector(numberOfChildrenOfItem:), aItem);
    return 0;
}

- (BOOL)isItemExpandable:(id)aExpandable password:(id)aPassword
{
    if ([self validatePassword:aPassword forItem:aExpandable] && [[self delegate] respondsToSelector:@selector(isItemExpandable:)])
        return ((BOOL (*)(id, SEL, id))objc_msgSend)([self delegate], @selector(isItemExpandable:), aExpandable);
    return NO;
}

- (id)childForIndex:(NSInteger)aIndex ofItem:(id)aItem password:(id)aPassword
{
    if ([self validatePassword:aPassword forItem:aItem] && [[self delegate] respondsToSelector:@selector(childForIndex:ofItem:)])
        return ((id (*)(id, SEL, int, id))objc_msgSend)([self delegate], @selector(childForIndex:ofItem:), (int)aIndex, aItem);
    return nil;
}

- (BOOL)validatePassword:(id)aPassword forItem:(id)aItem
{
    if (_password != nil)
        return [aPassword isEqualToString:_password];
    return YES;
}

- (BOOL)isItemProtected:(id)aProtected
{
    return _password != nil;
}

- (void)addLocalClient:(id)aClient
{
    if ([[self delegate] respondsToSelector:@selector(addLocalClient:)])
        [[self delegate] addLocalClient:aClient];
}

- (void)netServiceDidStop:(id)aStop
{
    [self clenupServer];
    if ([[self delegate] respondsToSelector:@selector(serverDidStop:)])
        ((void (*)(id, SEL, id))objc_msgSend)([self delegate], @selector(serverDidStop:), self);
}

- (void)netService:(id)aService didNotPublish:(id)aPublish
{
    [self clenupServer];
    if ([[self delegate] respondsToSelector:@selector(serverDidStop:)])
        ((void (*)(id, SEL, id))objc_msgSend)([self delegate], @selector(serverDidStop:), self);
}

- (void)netServiceWillPublish:(id)aPublish
{
    _connection = [[NSConnection allocWithZone:[self zone]] initWithReceivePort:_connectionPort sendPort:nil];
    [_connection setRootObject:self];
    [_connection runInNewThread];
    _serverState = 3;
    if ([[self delegate] respondsToSelector:@selector(serverDidStart:)])
        ((void (*)(id, SEL, id))objc_msgSend)([self delegate], @selector(serverDidStart:), self);
}

- (id)delegate
{
    return _delegate;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (NSInteger)serverState
{
    return _serverState;
}

- (void)stop
{
    if (_netService != nil) {
        _serverState = 4;
        [_netService stop];
    } else {
        [self clenupServer];
    }
}

// Listens on a free TCP port and publishes it under the name plus
// "#<number>", so that servers of the same name stay apart.
- (void)start
{
    if (_netService != nil)
        return;
    _connectionPort = [[NSSocketPort allocWithZone:[self zone]] init];
    if (_connectionPort != nil) {
        const struct sockaddr_in *address = [[_connectionPort address] bytes];
        if (address != NULL && address->sin_family == AF_INET) {
            // TickCount() was the ticks (1/60 s) since startup.
            int ticks = (int)([[NSProcessInfo processInfo] systemUptime] * 60.0);
            int number = ticks + (int)[[NSDate date] timeIntervalSinceReferenceDate];
            if (number < 0)
                number = -number;
            NSString *name = [_name stringByAppendingFormat:@"#%d", number];
            _netService = [[NSNetService allocWithZone:[self zone]] initWithDomain:_domain type:_type name:name port:ntohs(address->sin_port)];
            if (_netService != nil) {
                [_netService setDelegate:(id)self];
                _serverState = 2;
                [_netService publish];
                return;
            }
        }
    }
    [self stop];
}

- (void)dealloc
{
    [_domain release];
    [_type release];
    [_name release];
    [_netService release];
    [_connectionPort release];
    [_connection release];
    [super dealloc];
}

- (void)destroy
{
    _destroyServer = YES;
    [self stop];
}

- (id)initWithDomain:(id)aDomain type:(id)aType name:(id)aName delegate:(id)aDelegate password:(id)aPassword
{
    self = [super init];
    if (self != nil) {
        _domain = [aDomain copy];
        _type = [aType copy];
        _name = [aName copy];
        _password = [aPassword copy];
        _delegate = aDelegate;
        _destroyServer = NO;
        _serverState = 1;
    }
    return self;
}

- (id)init
{
    [self release];
    return nil;
}

@end
