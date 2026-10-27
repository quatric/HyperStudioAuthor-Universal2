#import "SMKPublishPrefix.h"


@interface PRDOClient : NSObject <PRDOClientProtocol, NSObject>
{
    NSString *_ipAddressString;
    NSConnection *_serverConnection;
    NSNetService *_netService;
    NSMutableArray *_rootItems;
    NSDistantObject *_rootProxy;
    NSRecursiveLock *_serverInterfaceLock;
    unsigned short _connectionPort;
    id _delegate;
    BOOL _unexpectedDisconnect;
}
+ (id)serverNameFromFullName:(id)aName;
- (void)createServerConnection:(id)aConnection;
- (id)serverConnection;
- (void)reloadItem:(id)aItem;
- (id)serverInterface;
- (BOOL)isUnexpectedDisconnect;
- (void)unexpectedDisconnect;
- (id)ipAddress;
- (id)rootServerItemsWithPassword:(id)aPassword;
- (void)reload:(id)aReload;
- (id)setObjectValue:(id)aValue forType:(id)aType byItem:(id)aItem delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout;
- (id)objectValueForType:(id)aType byItem:(id)aItem delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout;
- (id)numberOfChildrenOfItem:(id)aItem delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout;
- (id)isItemExpandable:(id)aExpandable delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout;
- (id)childForIndex:(NSInteger)aIndex ofItem:(id)aItem delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout;
- (id)validatePasswordForItem:(id)aItem delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous password:(id)aPassword timeout:(double)aTimeout;
- (id)isItemProtected:(id)aProtected delegate:(id)aDelegate isSynchronous:(BOOL)aSynchronous timeout:(double)aTimeout;
- (id)serverName;
- (id)netService;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)disconnectFromServer;
- (void)dealloc;
- (id)initWithNetService:(id)aService;
- (id)init;
@end

