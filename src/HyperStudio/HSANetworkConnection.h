#import "HyperStudioPrefix.h"


@protocol HSANetworkConnectionDelegate <NSObject>
@optional
- (void)connection:(id)aConnection didFailWithError:(id)aError;
- (void)connectionDidSucceed:(id)aConnection;
- (void)connection:(id)aConnection didFinishChecking:(id)aResult;
- (void)connectionDidCompleteResourceRemoving:(id)aConnection withSkippedResources:(id)aResources;
@end

@interface HSANetworkConnection : NSObject
{
    id<HSANetworkConnectionDelegate> _delegate;
    NSURL *_URL;
    int _port;
    NSURLCredential *_credential;
}
+ (NSUInteger)defaultPort;
+ (id)schemes;
+ (id)localizedErrorForError:(id)aError;
+ (BOOL)removeFileAtURL:(id)aURL error:(id *)aError;
+ (BOOL)removeResources:(id)aResources removedURLs:(id *)aURLs error:(id *)aError;
- (id)initWithURL:(id)aURL delegate:(id)aDelegate;
- (id)init;
- (id)delegate;
- (void)setDelegate:(id)aDelegate;
- (id)URL;
- (id)scheme;
- (int)port;
- (void)setPort:(int)aPort;
- (id)userName;
- (id)password;
- (void)useCredential:(id)aCredential;
- (void)checkConnection;
- (void)checkReachability;
- (void)removeDirectory;
- (void)resourceExistsAtPath:(id)aPath;
- (void)dealloc;
@end
