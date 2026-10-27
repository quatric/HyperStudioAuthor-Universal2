#import "SMKPublishPrefix.h"
#import "PRDOLocalTransaction.h"


@interface PRDOValidatePasswordTransaction : PRDOLocalTransaction
{
}
+ (id)transactionWithValidation:(BOOL)aValidation delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous;
+ (id)transactionWithServer:(id)aServer client:(id)aClient item:(id)aItem delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout;
- (id)initWithValidation:(BOOL)aValidation delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous;
- (id)initWithServer:(id)aServer client:(id)aClient item:(id)aItem delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout;
- (void)transactionThreadFunction;
@end

