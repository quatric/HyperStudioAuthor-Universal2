#import "SMKPublishPrefix.h"
#import "PRDOLocalTransaction.h"


@interface PRDOObjectValueTransaction : PRDOLocalTransaction
{
    id _valueType;
}
+ (id)transactionWithObjectValue:(id)aValue delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous;
+ (id)transactionWithServer:(id)aServer client:(id)aClient valueType:(id)aType item:(id)aItem delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout;
- (id)initWithObjectValue:(id)aValue delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous;
- (id)initWithServer:(id)aServer client:(id)aClient valueType:(id)aType item:(id)aItem delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout;
- (void)transactionThreadFunction;
- (void)dealloc;
@end

