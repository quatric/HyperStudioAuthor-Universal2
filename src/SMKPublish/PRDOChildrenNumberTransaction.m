#import "PRDOChildrenNumberTransaction.h"

@implementation PRDOChildrenNumberTransaction

+ (id)transactionWithClient:(id)aClient delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout
{
    return [[[PRDOChildrenNumberTransaction alloc] initWithServer:nil item:nil client:aClient delegate:aDelegate isSynchronous:aSynchronous password:aPassword timeout:aTimeout] autorelease];
}

+ (id)transactionWithNumberOfChildren:(NSInteger)aChildren delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous
{
    return [[[PRDOChildrenNumberTransaction alloc] initWithNumberOfChildren:aChildren delegate:aDelegate isSynchronous:aSynchronous] autorelease];
}

+ (id)transactionWithServer:(id)aServer client:(id)aClient item:(id)aItem delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout
{
    return [[[PRDOChildrenNumberTransaction alloc] initWithServer:aServer item:aItem client:aClient delegate:aDelegate isSynchronous:aSynchronous password:aPassword timeout:aTimeout] autorelease];
}

- (id)initWithNumberOfChildren:(NSInteger)aChildren delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous
{
    self = [super initWithServer:nil client:nil item:nil delegate:aDelegate password:nil timeout:0.0];
    if (self == nil)
        return nil;
    _value = [[NSNumber allocWithZone:[self zone]] initWithInt:(int)aChildren];
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
    NSInteger count;
    @try {
        if (_serverItem == nil)
            count = [[_client rootServerItemsWithPassword:_password] count];
        else
            count = [(id<PRDOServerProtocol>)_serverProtocol numberOfChildrenOfItem:_serverItem password:_password];
    } @catch (NSException *exception) {
        [_client unexpectedDisconnect];
        count = 0;
    }
    [_transactionLock lock];
    [_value release];
    _value = [[NSNumber allocWithZone:[self zone]] initWithInt:(int)count];
    [_transactionLock unlock];
}

@end
