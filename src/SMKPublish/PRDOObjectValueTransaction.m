#import "PRDOObjectValueTransaction.h"

@implementation PRDOObjectValueTransaction

+ (id)transactionWithObjectValue:(id)aValue delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous
{
    return [[[PRDOObjectValueTransaction alloc] initWithObjectValue:aValue delegate:aDelegate isSynchronous:aSynchronous] autorelease];
}

+ (id)transactionWithServer:(id)aServer client:(id)aClient valueType:(id)aType item:(id)aItem delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout
{
    return [[[PRDOObjectValueTransaction alloc] initWithServer:aServer client:aClient valueType:aType item:aItem delegate:aDelegate isSynchronous:aSynchronous password:aPassword timeout:aTimeout] autorelease];
}

- (id)initWithObjectValue:(id)aValue delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous
{
    self = [super initWithServer:nil client:nil item:nil delegate:aDelegate password:nil timeout:0.0];
    if (self != nil) {
        _objectValue = [aValue retain];
        [self quickTransaction:aSynchronous];
    }
    return self;
}

- (id)initWithServer:(id)aServer client:(id)aClient valueType:(id)aType item:(id)aItem delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout
{
    self = [super initWithServer:aServer client:aClient item:aItem delegate:aDelegate password:aPassword timeout:aTimeout];
    if (self != nil) {
        _valueType = [aType retain];
        [self startTransaction:aSynchronous];
    }
    return self;
}

- (void)transactionThreadFunction
{
    [super transactionThreadFunction];
    if ([_client isUnexpectedDisconnect])
        return;
    id value;
    @try {
        value = [(id<PRDOServerProtocol>)_serverProtocol objectValueForType:_valueType byItem:_serverItem password:_password];
    } @catch (NSException *exception) {
        [_client unexpectedDisconnect];
        value = nil;
    }
    [_transactionLock lock];
    [_objectValue release];
    _objectValue = [value retain];
    [_transactionLock unlock];
}

- (void)dealloc
{
    [_valueType release];
    [super dealloc];
}

@end
