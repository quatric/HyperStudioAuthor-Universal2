#import "SMKPublishPrefix.h"


@interface PTransaction : NSObject
{
    NSNumber *_value;
    id _objectValue;
    int _state;
    int _error;
    NSRecursiveLock *_transactionLock;
    NSThread *_startThread;
    id _delegate;
}
- (NSInteger)state;
- (void)setDelegate:(id)aDelegate;
- (NSInteger)error;
- (void)abort;
- (BOOL)isFinished;
- (id)objectValue;
- (BOOL)boolValue;
- (int)intValue;
- (void)dealloc;
- (id)init;
@end

