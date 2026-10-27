#import "HyperStudioPrefix.h"


@interface SRServiceListener : NSObject <NSNetServiceDelegate, NSObject, SRConnectionItem>
{
    NSNetService *_service;
    NSString *_serviceType;
    NSString *_serviceName;
    id<SRConnectionConsumer> _consumer;
    id _delegate;
    unsigned int _linksCounter;
}
- (void)netService:(id)aService didNotResolve:(id)aResolve;
- (void)netServiceDidResolveAddress:(id)aAddress;
- (void)refuseConnection;
- (NSInteger)establishListeningConnectionWithTimeout:(double)aTimeout;
- (unsigned short)port;
- (BOOL)isProvider;
- (id)domain;
- (id)name;
- (id)identifier;
- (id)delegate;
- (void)setDelegate:(id)aDelegate;
- (NSUInteger)unlink;
- (NSUInteger)link;
- (void)dealloc;
- (id)initWithNetService:(id)aService consumer:(id)aConsumer;
@end

@interface SRServiceProvider : SRServiceListener
{
    NSFileHandle *_serviceHandle;
    unsigned short _servicePort;
    int _serviceDescriptor;
}
- (void)SRServiceProvider_connectionReceived:(id)aReceived;
- (void)netServiceDidStop:(id)aStop;
- (void)netService:(id)aService didNotPublish:(id)aPublish;
- (void)netServiceWillPublish:(id)aPublish;
- (NSInteger)establishListeningConnectionWithTimeout:(double)aTimeout;
- (unsigned short)port;
- (BOOL)isProvider;
- (void)publish;
- (NSUInteger)unlink;
- (NSUInteger)link;
- (void)refuseConnection;
- (void)dealloc;
- (id)initWithIdentifier:(id)aIdentifier name:(id)aName port:(unsigned short)aPort communicationDescriptor:(NSInteger)aDescriptor consumer:(id)aConsumer;
@end

@interface SRNetworkItem : NSObject
{
    NSString *_identifier;
    NSNetServiceBrowser *_browser;
    NSMutableDictionary *_providers;
    NSMutableDictionary *_foundItems;
    id _delegate;
    unsigned int _isMonitoring:1;
}
- (void)netServiceConnection:(id)aConnection didRefusedWithError:(NSInteger)aError;
- (void)netServiceConnectionWillStart:(id)aStart;
- (void)netServiceBrowser:(id)aBrowser didRemoveService:(id)aService moreComing:(BOOL)aComing;
- (void)netServiceBrowser:(id)aBrowser didFindService:(id)aService moreComing:(BOOL)aComing;
- (void)netServiceBrowser:(id)aBrowser didNotSearch:(id)aSearch;
- (void)netServiceBrowserDidStopSearch:(id)aSearch;
- (void)SRNetworkItem_cleanupMonitoring;
- (void)netServiceBrowserWillSearch:(id)aSearch;
- (BOOL)isItemActive;
- (void)stopMonitoring;
- (NSInteger)startMonitoring;
- (void)stopProviding;
- (void)stopProvidingForName:(id)aName;
- (NSInteger)startProvidingWithName:(id)aName;
- (id)delegate;
- (void)setDelegate:(id)aDelegate;
- (id)identifier;
- (void)dealloc;
- (id)initWithIdentifier:(id)aIdentifier;
@end

