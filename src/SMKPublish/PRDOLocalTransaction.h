#import "SMKPublishPrefix.h"
#import "PTransaction.h"


@interface PRDOLocalTransaction : PTransaction
{
    id _serverProtocol;
    id _serverItem;
    PRDOClient *_client;
    NSString *_password;
    double _timeout;
}
- (void)transactionThreadFunction;
- (void)dealloc;
- (id)initWithServer:(id)aServer client:(id)aClient item:(id)aItem delegate:(id)aDelegate password:(id)aPassword timeout:(double)aTimeout;
@end

