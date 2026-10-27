#import "HyperStudioPrefix.h"
#import "HSANetworkConnection.h"


@protocol HSANetworkServerUploaderDelegate <NSObject>
@optional
- (void)serverUploader:(id)aUploader didFailWithError:(id)aError;
- (void)serverUploaderDidFinish:(id)aUploader;
@end

@interface HSANetworkUploader : NSObject <HSANetworkConnectionDelegate>
{
    id<HSANetworkServerUploaderDelegate> _delegate;
    HSANetworkConnection *_connection;
    BOOL _isUploading:1;
}
- (id)initWithConnection:(id)aConnection;
- (id)init;
- (id)delegate;
- (void)setDelegate:(id)aDelegate;
- (BOOL)isUploading;
- (BOOL)uploadFileAtURL:(id)aURL removeIfExist:(BOOL)aRemove error:(id *)aError;
- (void)uploadFolderAtURL:(id)aURL removeIfExist:(BOOL)aRemove;
- (void)cancel;
- (void)dealloc;
@end
