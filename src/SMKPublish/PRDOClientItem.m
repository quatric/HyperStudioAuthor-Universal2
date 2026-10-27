#import "PRDOClientItem.h"

// A server item seen from a client; every request goes through the client.

@implementation PRDOClientItem

+ (id)itemWithClient:(id)aClient serverItem:(id)aItem
{
    return [[[PRDOClientItem alloc] initWithClient:aClient serverItem:aItem] autorelease];
}

- (id)serverItem
{
    return _serverItem;
}

- (id)initWithClient:(id)aClient serverItem:(id)aItem
{
    self = [super init];
    if (self != nil) {
        _client = [aClient retain];
        _serverItem = [aItem retain];
    }
    return self;
}

- (void)disconnectServer
{
    [_client disconnectFromServer];
}

- (id)setObjectValue:(id)aValue forType:(id)aType delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout
{
    return [_client setObjectValue:aValue forType:aType byItem:_serverItem delegate:aDelegate isSynchronous:aSynchronous password:aPassword timeout:aTimeout];
}

- (id)objectValueForType:(id)aType delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout
{
    return [_client objectValueForType:aType byItem:_serverItem delegate:aDelegate isSynchronous:aSynchronous password:aPassword timeout:aTimeout];
}

- (id)isItemExpandableWithDelegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout
{
    return [_client isItemExpandable:_serverItem delegate:aDelegate isSynchronous:aSynchronous password:aPassword timeout:aTimeout];
}

- (id)childForIndex:(NSInteger)aIndex delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout
{
    return [_client childForIndex:aIndex ofItem:_serverItem delegate:aDelegate isSynchronous:aSynchronous password:aPassword timeout:aTimeout];
}

- (id)numberOfChildrenOfItemWithDelegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout
{
    return [_client numberOfChildrenOfItem:_serverItem delegate:aDelegate isSynchronous:aSynchronous password:aPassword timeout:aTimeout];
}

- (id)validatePassword:(id)aPassword delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous timeout:(double)aTimeout
{
    return [_client validatePasswordForItem:_serverItem delegate:aDelegate isSynchronous:aSynchronous password:aPassword timeout:aTimeout];
}

- (id)isProtectedWithdelegate:(id)aWithdelegate isSynchronous:(BOOL)aSynchronous timeout:(double)aTimeout
{
    return [_client isItemProtected:_serverItem delegate:aWithdelegate isSynchronous:aSynchronous timeout:aTimeout];
}

- (BOOL)isEqual:(id)aEqual
{
    return [[aEqual serverItem] isEqual:_serverItem];
}

- (void)dealloc
{
    [_client release];
    [_serverItem release];
    [super dealloc];
}

@end
