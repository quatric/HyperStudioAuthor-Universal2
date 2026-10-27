#import "SMKPublishPrefix.h"
#import "PRDOLocalTransaction.h"


@interface PRDOProtectedTransaction : PRDOLocalTransaction
{
}
+ (id)transactionWithProtected:(BOOL)aProtected delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous;
+ (id)transactionWithServer:(id)aServer client:(id)aClient item:(id)aItem delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous timeout:(double)aTimeout;
- (id)initWithProtected:(BOOL)aProtected delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous;
- (id)initWithServer:(id)aServer client:(id)aClient item:(id)aItem delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous timeout:(double)aTimeout;
- (void)transactionThreadFunction;
@end

