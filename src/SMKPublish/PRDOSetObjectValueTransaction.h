#import "SMKPublishPrefix.h"
#import "PRDOLocalTransaction.h"


@interface PRDOSetObjectValueTransaction : PRDOLocalTransaction
{
    id _valueType;
    id _object;
}
+ (id)transactionWithServer:(id)aServer client:(id)aClient objectValue:(id)aValue valueType:(id)aType item:(id)aItem delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout;
- (id)initWithServer:(id)aServer client:(id)aClient objectValue:(id)aValue valueType:(id)aType item:(id)aItem delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout;
- (void)transactionThreadFunction;
- (void)dealloc;
@end

