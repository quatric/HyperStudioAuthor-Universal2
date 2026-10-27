#import "PTransaction.h"

// A request whose value arrives later. States: 1 new, 2 running, 3 done,
// 4 aborted, 5 failed (see PTransaction+PTransactionPrivate).

@implementation PTransaction

- (NSInteger)state
{
    [_transactionLock lock];
    int state = _state;
    [_transactionLock unlock];
    return state;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (NSInteger)error
{
    [_transactionLock lock];
    int error = _error;
    [_transactionLock unlock];
    return error;
}

- (void)abort
{
    [self abortTransaction];
}

- (BOOL)isFinished
{
    return (unsigned)(_state - 3) < 3;
}

- (id)objectValue
{
    [_transactionLock lock];
    id value = _objectValue;
    [_transactionLock unlock];
    return value;
}

- (BOOL)boolValue
{
    [_transactionLock lock];
    BOOL value = [_value boolValue];
    [_transactionLock unlock];
    return value;
}

- (int)intValue
{
    [_transactionLock lock];
    int value = [_value intValue];
    [_transactionLock unlock];
    return value;
}

- (void)dealloc
{
    [_transactionLock release];
    [_value release];
    [_objectValue release];
    [_startThread release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    _transactionLock = [[NSRecursiveLock allocWithZone:[self zone]] init];
    _state = 1;
    _error = 0;
    return self;
}

@end
