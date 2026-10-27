#import "SMKPublishPrefix.h"
#import "PRDOLocalTransaction.h"


@interface PRDOChildTransaction : PRDOLocalTransaction
{
    int _index;
}
+ (id)transactionWithClient:(id)aClient index:(NSInteger)aIndex delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout;
+ (id)transactionWithChild:(id)aChild delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous;
+ (id)transactionWithServer:(id)aServer index:(NSInteger)aIndex item:(id)aItem client:(id)aClient delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout;
- (id)initWithChild:(id)aChild delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous;
- (id)initWithServer:(id)aServer index:(NSInteger)aIndex item:(id)aItem client:(id)aClient delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout;
- (void)transactionThreadFunction;
@end

