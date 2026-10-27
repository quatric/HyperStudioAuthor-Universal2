#import "SMKPublishPrefix.h"


@interface PRDOClientItem : NSObject
{
    PRDOClient *_client;
    id _serverItem;
}
+ (id)itemWithClient:(id)aClient serverItem:(id)aItem;
- (id)serverItem;
- (id)initWithClient:(id)aClient serverItem:(id)aItem;
- (void)disconnectServer;
- (id)setObjectValue:(id)aValue forType:(id)aType delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout;
- (id)objectValueForType:(id)aType delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout;
- (id)isItemExpandableWithDelegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout;
- (id)childForIndex:(NSInteger)aIndex delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout;
- (id)numberOfChildrenOfItemWithDelegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout;
- (id)validatePassword:(id)aPassword delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous timeout:(double)aTimeout;
- (id)isProtectedWithdelegate:(id)aWithdelegate isSynchronous:(BOOL)aSynchronous timeout:(double)aTimeout;
- (BOOL)isEqual:(id)aEqual;
- (void)dealloc;
@end

