#import "SMKPublishPrefix.h"
#import "PRDOLocalTransaction.h"


@interface PRDOChildrenNumberTransaction : PRDOLocalTransaction
{
}
+ (id)transactionWithClient:(id)aClient delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout;
+ (id)transactionWithNumberOfChildren:(NSInteger)aChildren delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous;
+ (id)transactionWithServer:(id)aServer client:(id)aClient item:(id)aItem delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout;
- (id)initWithNumberOfChildren:(NSInteger)aChildren delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous;
- (id)initWithServer:(id)aServer item:(id)aItem client:(id)aClient delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout;
- (void)transactionThreadFunction;
@end

