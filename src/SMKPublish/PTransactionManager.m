#import "PTransactionManager.h"

// Runs queued transactions on three worker threads. States: 1 stopped,
// 2 running. The condition lock's condition is 1 while work may be waiting.

static PTransactionManager *sSharedTransactionManager;

@implementation PTransactionManager

+ (id)sharedTransactionManager
{
    if (sSharedTransactionManager == nil)
        sSharedTransactionManager = [[self alloc] init];
    return sSharedTransactionManager;
}

- (id)queue
{
    if (_queue == nil)
        _queue = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:0];
    return _queue;
}

- (void)setState:(NSInteger)aState
{
    [_stateLock lock];
    _state = (int)aState;
    [_stateLock unlock];
}

- (void)transactionsCoreThread:(id)aThread
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    while ([self state] == 2) {
        id transaction = nil;
        [_queueLock lock];
        if ([[self queue] count] != 0) {
            transaction = [[[self queue] objectAtIndex:0] retain];
            [[self queue] removeObjectAtIndex:0];
        }
        [_queueLock unlock];
        if (transaction == nil) {
            [_emptyQueueLock lockWhenCondition:1];
            [_emptyQueueLock unlockWithCondition:0];
        } else {
            [transaction transactionThread:self];
            [transaction autorelease];
        }
    }
    [pool release];
}

- (void)addTransaction:(id)aTransaction
{
    if (aTransaction == nil)
        return;
    [_queueLock lock];
    [[self queue] addObject:aTransaction];
    [_queueLock unlock];
    if ([_emptyQueueLock tryLockWhenCondition:0])
        [_emptyQueueLock unlockWithCondition:1];
}

- (void)clearQueue
{
    [_queueLock lock];
    [[self queue] removeAllObjects];
    [_queueLock unlock];
}

- (NSInteger)state
{
    [_stateLock lock];
    int state = _state;
    [_stateLock unlock];
    return state;
}

- (void)stop
{
    if ([self state] != 2)
        return;
    [self setState:1];
    if ([_emptyQueueLock tryLockWhenCondition:0])
        [_emptyQueueLock unlockWithCondition:1];
}

- (void)start
{
    if ([self state] != 1)
        return;
    [self setState:2];
    for (int i = 0; i < 3; i++)
        [NSThread detachNewThreadSelector:@selector(transactionsCoreThread:) toTarget:self withObject:nil];
}

- (void)dealloc
{
    [_queue release];
    [_queueLock release];
    [_stateLock release];
    [_emptyQueueLock release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    _queueLock = [[NSRecursiveLock allocWithZone:[self zone]] init];
    _state = 1;
    _stateLock = [[NSRecursiveLock allocWithZone:[self zone]] init];
    _emptyQueueLock = [[NSConditionLock allocWithZone:[self zone]] initWithCondition:0];
    return self;
}

@end
