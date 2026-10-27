#import "SMKPublishPrefix.h"


@interface PTransactionManager : NSObject
{
    NSMutableArray *_queue;
    NSRecursiveLock *_queueLock;
    int _state;
    NSRecursiveLock *_stateLock;
    NSConditionLock *_emptyQueueLock;
}
+ (id)sharedTransactionManager;
- (id)queue;
- (void)setState:(NSInteger)aState;
- (void)transactionsCoreThread:(id)aThread;
- (void)addTransaction:(id)aTransaction;
- (void)clearQueue;
- (NSInteger)state;
- (void)stop;
- (void)start;
- (void)dealloc;
- (id)init;
@end

