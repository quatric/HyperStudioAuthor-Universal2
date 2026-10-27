#import "PRDOValidatePasswordTransaction.h"

@implementation PRDOValidatePasswordTransaction

+ (id)transactionWithValidation:(BOOL)aValidation delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous
{
    return [[[PRDOValidatePasswordTransaction alloc] initWithValidation:aValidation delegate:aDelegate isSynchronous:aSynchronous] autorelease];
}

+ (id)transactionWithServer:(id)aServer client:(id)aClient item:(id)aItem delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout
{
    return [[[PRDOValidatePasswordTransaction alloc] initWithServer:aServer client:aClient item:aItem delegate:aDelegate isSynchronous:aSynchronous password:aPassword timeout:aTimeout] autorelease];
}

- (id)initWithValidation:(BOOL)aValidation delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous
{
    self = [super initWithServer:nil client:nil item:nil delegate:aDelegate password:nil timeout:0.0];
    if (self == nil)
        return nil;
    _value = [[NSNumber allocWithZone:[self zone]] initWithBool:aValidation];
    [self quickTransaction:aSynchronous];
    return self;
}

- (id)initWithServer:(id)aServer client:(id)aClient item:(id)aItem delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout
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
        result = [(id<PRDOServerProtocol>)_serverProtocol validatePassword:_password forItem:_serverItem];
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
