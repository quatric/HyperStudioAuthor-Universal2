#import "PRDOExpandableTransaction.h"

@implementation PRDOExpandableTransaction

+ (id)transactionWithClient:(id)aClient delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout
{
    return [[[PRDOExpandableTransaction alloc] initWithServer:nil item:nil client:aClient delegate:aDelegate isSynchronous:aSynchronous password:aPassword timeout:aTimeout] autorelease];
}

+ (id)transactionWithExpandable:(BOOL)aExpandable delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous
{
    return [[[PRDOExpandableTransaction alloc] initWithExpandable:aExpandable delegate:aDelegate isSynchronous:aSynchronous] autorelease];
}

+ (id)transactionWithServer:(id)aServer client:(id)aClient item:(id)aItem delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout
{
    return [[[PRDOExpandableTransaction alloc] initWithServer:aServer item:aItem client:aClient delegate:aDelegate isSynchronous:aSynchronous password:aPassword timeout:aTimeout] autorelease];
}

- (id)initWithExpandable:(BOOL)aExpandable delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous
{
    self = [super initWithServer:nil client:nil item:nil delegate:aDelegate password:nil timeout:0.0];
    if (self == nil)
        return nil;
    _value = [[NSNumber allocWithZone:[self zone]] initWithBool:aExpandable];
    [self quickTransaction:aSynchronous];
    return self;
}

- (id)initWithServer:(id)aServer item:(id)aItem client:(id)aClient delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout
{
    self = [super initWithServer:aServer client:aClient item:aItem delegate:aDelegate password:aPassword timeout:aTimeout];
    if (self != nil)
        [self startTransaction:aSynchronous];
    return self;
}

- (void)transactionThreadFunction
{
    [super transactionThreadFunction];
    if ([_client isUnexpectedDisconnect])
        return;
    BOOL result;
    @try {
        if (_serverItem == nil)
            result = [[_client rootServerItemsWithPassword:_password] count] != 0;
        else
            result = [(id<PRDOServerProtocol>)_serverProtocol isItemExpandable:_serverItem password:_password];
    } @catch (NSException *exception) {
        [_client unexpectedDisconnect];
        result = NO;
    }
    [_transactionLock lock];
    [_value release];
    _value = [[NSNumber allocWithZone:[self zone]] initWithBool:result];
    [_transactionLock unlock];
}

@end
