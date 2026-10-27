#import "SMKPublishPrefix.h"


@interface PRDOServerDataProvider : NSObject
{
    PRDOServer *_server;
    NSMutableArray *_clientsConnections;
    NSRecursiveLock *_serverProviderLock;
    BOOL _notifyThreadActive;
}
- (void)notifyClientsAboutItemChangingThreadFunction:(id)aFunction;
- (void)invalidateConnection:(id)aConnection;
- (void)connectionDidDie:(id)aDie;
- (void)removeClientByIndex:(NSInteger)aIndex;
- (void)applicationWillTerminate:(id)aTerminate;
- (BOOL)setObjectValue:(id)aValue forType:(id)aType byItem:(id)aItem;
- (id)objectValueForType:(id)aType byItem:(id)aItem;
- (NSInteger)numberOfChildrenOfItem:(id)aItem;
- (BOOL)isItemExpandable:(id)aExpandable;
- (id)childForIndex:(NSInteger)aIndex ofItem:(id)aItem;
- (void)addLocalClient:(id)aClient;
- (void)serverDidStop:(id)aStop;
- (void)serverDidStart:(id)aStart;
- (void)notifyClientsAboutItemChanging:(id)aChanging;
- (void)serverDidStop;
- (void)serverDidStart;
- (NSInteger)serverState;
- (void)stop;
- (void)start;
- (void)dealloc;
- (id)initWithDomain:(id)aDomain type:(id)aType name:(id)aName password:(id)aPassword;
- (id)init;
@end

