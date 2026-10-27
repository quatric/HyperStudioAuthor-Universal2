#import "PRDOSetObjectValueTransaction.h"

@implementation PRDOSetObjectValueTransaction

+ (id)transactionWithServer:(id)aServer client:(id)aClient objectValue:(id)aValue valueType:(id)aType item:(id)aItem delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout
{
    return [[[PRDOSetObjectValueTransaction alloc] initWithServer:aServer client:aClient objectValue:aValue valueType:aType item:aItem delegate:aDelegate isSynchronous:aSynchronous password:aPassword timeout:aTimeout] autorelease];
}

- (id)initWithServer:(id)aServer client:(id)aClient objectValue:(id)aValue valueType:(id)aType item:(id)aItem delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout
{
    self = [super initWithServer:aServer client:aClient item:aItem delegate:aDelegate password:aPassword timeout:aTimeout];
    if (self != nil) {
        _valueType = [aType retain];
        _object = [aValue retain];
        [self startTransaction:aSynchronous];
    }
    return self;
}

- (void)transactionThreadFunction
{
    [super transactionThreadFunction];
    if ([_client isUnexpectedDisconnect])
        return;
    BOOL result;
    @try {
        result = _serverItem != nil
            && [(id<PRDOServerProtocol>)_serverProtocol setObjectValue:_object forType:_valueType byItem:_serverItem password:_password];
    } @catch (NSException *exception) {
        [_client unexpectedDisconnect];
        result = NO;
    }
    [_transactionLock lock];
    [_value release];
    _value = [[NSNumber allocWithZone:[self zone]] initWithBool:result];
    [_transactionLock unlock];
}

- (void)dealloc
{
    [_valueType release];
    [_object release];
    [super dealloc];
}

@end
