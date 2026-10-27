#import "PRDOChildTransaction.h"

@implementation PRDOChildTransaction

+ (id)transactionWithClient:(id)aClient index:(NSInteger)aIndex delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout
{
    return [[[PRDOChildTransaction alloc] initWithServer:nil index:aIndex item:nil client:aClient delegate:aDelegate isSynchronous:aSynchronous password:aPassword timeout:aTimeout] autorelease];
}

+ (id)transactionWithChild:(id)aChild delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous
{
    return [[[PRDOChildTransaction alloc] initWithChild:aChild delegate:aDelegate isSynchronous:aSynchronous] autorelease];
}

+ (id)transactionWithServer:(id)aServer index:(NSInteger)aIndex item:(id)aItem client:(id)aClient delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout
{
    return [[[PRDOChildTransaction alloc] initWithServer:aServer index:aIndex item:aItem client:aClient delegate:aDelegate isSynchronous:aSynchronous password:aPassword timeout:aTimeout] autorelease];
}

- (id)initWithChild:(id)aChild delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous
{
    self = [super initWithServer:nil client:nil item:nil delegate:aDelegate password:nil timeout:0.0];
    if (self != nil) {
        _objectValue = [aChild retain];
        [self quickTransaction:aSynchronous];
    }
    return self;
}

- (id)initWithServer:(id)aServer index:(NSInteger)aIndex item:(id)aItem client:(id)aClient delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout
{
    self = [super initWithServer:aServer client:aClient item:aItem delegate:aDelegate password:aPassword timeout:aTimeout];
    if (self == nil)
        return nil;
    _index = (int)aIndex;
    [self startTransaction:aSynchronous];
    return self;
}

// Without an item the child comes from the client's root items.
- (void)transactionThreadFunction
{
    [super transactionThreadFunction];
    if ([_client isUnexpectedDisconnect])
        return;
    id child;
    @try {
        if (_serverItem == nil) {
            NSArray *roots = [_client rootServerItemsWithPassword:_password];
            if (_index < 0 || (NSInteger)[roots count] <= _index)
                child = nil;
            else
                child = [roots objectAtIndex:_index];
        } else {
            child = [(id<PRDOServerProtocol>)_serverProtocol childForIndex:_index ofItem:_serverItem password:_password];
        }
    } @catch (NSException *exception) {
        [_client unexpectedDisconnect];
        child = nil;
    }
    [_transactionLock lock];
    [_objectValue release];
    _objectValue = nil;
    if (child != nil)
        _objectValue = [[PRDOClientItem itemWithClient:_client serverItem:child] retain];
    [_transactionLock unlock];
}

@end
