#import "SMKPublishPrefix.h"
#import "PTransaction.h"


@interface PTransaction (PTransactionPrivate)
- (void)setState:(NSInteger)aState;
- (void)abortTransaction;
- (void)abortTransactionThread:(id)aThread;
- (void)finishTransactionThread:(id)aThread;
- (void)setError:(NSInteger)aError;
- (void)quickTransaction:(BOOL)aTransaction;
- (void)startTransaction:(BOOL)aTransaction;
- (void)transactionThreadFunction;
- (void)transactionThread:(id)aThread;
@end

