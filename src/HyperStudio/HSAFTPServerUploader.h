#import "HyperStudioPrefix.h"
#import "HSANetworkUploader.h"


@interface HSAFTPServerUploader : HSANetworkUploader <NSStreamDelegate>
{
    NSURL *_uploadURL;
    NSMutableSet *_uploadedResourcesURLs;
    NSSet *_skipUploadPaths;
    NSInputStream *_fileStream;
    NSMutableData *_readData;
    int _bufferOffset;
    NSURL *_fileURL;
    NSEnumerator *_URLsEnumerator;
}
+ (id)localizedErrorForOutputStreamError:(id)aError;
- (BOOL)uploadFileAtURL:(id)aURL removeIfExist:(BOOL)aRemove error:(id *)aError;
- (void)uploadFolderAtURL:(id)aURL removeIfExist:(BOOL)aRemove;
- (void)cancel;
- (void)cleanup;
- (void)connection:(id)aConnection didFailWithError:(id)aError;
- (void)connectionDidCompleteResourceRemoving:(id)aConnection withSkippedResources:(id)aResources;
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)aEvent;
- (void)dealloc;
@end


@interface HSAHTML5FTPServerUploader : HSAFTPServerUploader
@end
