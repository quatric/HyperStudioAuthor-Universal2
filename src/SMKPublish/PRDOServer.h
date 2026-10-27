#import "SMKPublishPrefix.h"


@interface PRDOServer : NSObject <PRDOServerProtocol, NSObject>
{
    NSNetService *_netService;
    NSConnection *_connection;
    NSSocketPort *_connectionPort;
    BOOL _destroyServer;
    NSString *_domain;
    NSString *_type;
    NSString *_name;
    NSString *_password;
    id _delegate;
    int _serverState;
}
+ (id)localIPAddresses;
- (void)clenupServer;
- (BOOL)setObjectValue:(id)aValue forType:(id)aType byItem:(id)aItem password:(id)aPassword;
- (id)objectValueForType:(id)aType byItem:(id)aItem password:(id)aPassword;
- (NSInteger)numberOfChildrenOfItem:(id)aItem password:(id)aPassword;
- (BOOL)isItemExpandable:(id)aExpandable password:(id)aPassword;
- (id)childForIndex:(NSInteger)aIndex ofItem:(id)aItem password:(id)aPassword;
- (BOOL)validatePassword:(id)aPassword forItem:(id)aItem;
- (BOOL)isItemProtected:(id)aProtected;
- (void)addLocalClient:(id)aClient;
- (void)netServiceDidStop:(id)aStop;
- (void)netService:(id)aService didNotPublish:(id)aPublish;
- (void)netServiceWillPublish:(id)aPublish;
- (id)delegate;
- (void)setDelegate:(id)aDelegate;
- (NSInteger)serverState;
- (void)stop;
- (void)start;
- (void)dealloc;
- (void)destroy;
- (id)initWithDomain:(id)aDomain type:(id)aType name:(id)aName delegate:(id)aDelegate password:(id)aPassword;
- (id)init;
@end

