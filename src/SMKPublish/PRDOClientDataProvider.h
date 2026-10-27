#import "SMKPublishPrefix.h"


@interface PRDOClientDataProvider : NSObject
{
    NSNetServiceBrowser *_netServiceBrowser;
    NSMapTable *_clients;
    NSString *_domain;
    NSString *_type;
    NSString *_localName;
    NSMutableArray *_cacheToAdd;
    NSMutableArray *_cacheToRemove;
    NSMutableArray *_resolvingServices;
    id _delegate;
    BOOL _isSynchronous;
    double _timeout;
    NSRecursiveLock *_addRemoveServicesLock;
}
- (void)timeoutFlushCacheToAdd:(id)aAdd;
- (void)removeNetService:(id)aService;
- (void)serverConnectionDidDieWithNetService:(id)aService;
- (id)clientNameForIndex:(NSInteger)aIndex;
- (id)clientForName:(id)aName;
- (void)clientDidChange:(id)aChange;
- (BOOL)isNetServiceRegistred:(id)aRegistred remove:(BOOL)aRemove;
- (void)flushCacheToRemove;
- (void)flushCacheToAdd;
- (void)netServiceDidResolveAddress:(id)aAddress;
- (void)netService:(id)aService didNotResolve:(id)aResolve;
- (void)netServiceBrowser:(id)aBrowser didRemoveService:(id)aService moreComing:(BOOL)aComing;
- (void)netServiceBrowser:(id)aBrowser didRemoveDomain:(id)aDomain moreComing:(BOOL)aComing;
- (void)netServiceBrowser:(id)aBrowser didFindService:(id)aService moreComing:(BOOL)aComing;
- (void)netServiceBrowserDidStopSearch:(id)aSearch;
- (void)removeServer:(id)aServer;
- (void)addServer:(id)aServer;
- (void)reloadItem:(id)aItem ofServer:(id)aServer;
- (void)disconnectServerByItem:(id)aItem;
- (id)setObjectValue:(id)aValue forType:(id)aType byItem:(id)aItem password:(id)aPassword;
- (id)objectValueForType:(id)aType byItem:(id)aItem password:(id)aPassword;
- (id)numberOfChildrenOfItem:(id)aItem password:(id)aPassword;
- (id)isItemExpandable:(id)aExpandable password:(id)aPassword;
- (id)childForIndex:(NSInteger)aIndex ofItem:(id)aItem password:(id)aPassword;
- (id)validatePassword:(id)aPassword forItem:(id)aItem;
- (id)isItemProtected:(id)aProtected;
- (void)setTimeout:(double)aTimeout;
- (void)setIsSynchronous:(BOOL)aSynchronous;
- (void)stop;
- (void)start;
- (void)setDelegate:(id)aDelegate;
- (void)dealloc;
- (id)initWithDomain:(id)aDomain type:(id)aType localName:(id)aName;
- (id)init;
@end

