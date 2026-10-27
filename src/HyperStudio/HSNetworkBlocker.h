#import "HyperStudioPrefix.h"


@interface HSNetworkBlocker : NSObject
{
    NSString *_identifier;
    unsigned int _licenseType;
    unsigned int _allowedCount;
    NSMutableDictionary *_blockingRegistrations;
    NSData *_information;
}
- (void)HSNetworkBlocker_connectionDataRead:(id)aRead;
- (id)HSNetworkBlocker_blockingMessage;
- (void)HSNetworkBlocker_connectionDataAvailable:(id)aAvailable;
- (void)listeningConnection:(id)aConnection isEstablishedForItem:(id)aItem properties:(id)aProperties;
- (void)networkItem:(id)aItem didFindConnectionItem:(id)aItem2;
- (void)monitoringDidFinishedForItem:(id)aItem withError:(NSInteger)aError;
- (void)stopBlocking;
- (NSInteger)blockIdentifier:(id)aIdentifier;
- (void)dealloc;
- (id)initWithBundleIdentifier:(id)aIdentifier licenseType:(NSUInteger)aType allowedCount:(NSUInteger)aCount;
@end

@interface HSNetworkRegistrar : NSObject
{
    NSString *_identifier;
    unsigned int _licenseType;
    SRNetworkItem *_networkRegistration;
    id<SRConnectionItem> _registrationConnection;
    SRNetworkItem *_infoRegistration;
    id<SRConnectionItem> _infoConnection;
    unsigned int _allowedRegistrationCount;
    unsigned int _registrationCount;
    NSData *_verificationInfo;
    NSData *_infoMessage;
    NSMutableData *_dataAccumulator;
    unsigned int _accumulationLimit;
    HSNetworkBlocker *_networkBlocker;
    unsigned int _isRegistered:1;
    unsigned int _isCalcuationFinished:1;
    unsigned int _isOwnConnectionProcessed:1;
}
- (void)providingConnection:(id)aConnection isEstablishedForItem:(id)aItem properties:(id)aProperties;
- (void)HSNetworkRegistrar_verificationMessageReceived:(id)aReceived;
- (void)HSNetworkRegistrar_adminMessageReceived:(id)aReceived;
- (id)HSNetworkRegistrar_verificationInfo;
- (BOOL)stopMonitoringWhenLastConnectionDidFindForItem:(id)aItem;
- (void)networkItem:(id)aItem didRemoveConnectionItem:(id)aItem2 withError:(NSInteger)aError;
- (void)networkItem:(id)aItem didFindConnectionItem:(id)aItem2;
- (void)monitoringDidFinishedForItem:(id)aItem withError:(NSInteger)aError;
- (void)providingDidFinishedForItem:(id)aItem;
- (void)providingWillStartForItem:(id)aItem;
- (void)HSNetworkRegistrar_startMonitoringForItem:(id)aItem;
- (NSInteger)registerBlockingIdentifier:(id)aIdentifier;
- (NSInteger)registerWithIdentifier:(id)aIdentifier allowedCount:(NSUInteger)aCount;
- (void)dealloc;
- (id)initWithBundleIdentifier:(id)aIdentifier licenseType:(NSUInteger)aType;
- (id)init;
@end

