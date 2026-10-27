#import "HyperStudioPrefix.h"
#import "HSDiskPublisher.h"
#import "HSANetworkUploader.h"


@interface HSAFTPServerPublisher : HSDiskPublisher <HSANetworkServerUploaderDelegate>
{
    HSAFTPServerUploader *_ftpServerUploader;
    unsigned int _fileShouldBeRemoved:1;
}
- (void)setConnection:(id)aConnection;
- (void)setStorePath:(id)aPath;
- (void)setFileShouldBeRemoved:(BOOL)aRemoved;
- (id)exportPanelController;
- (id)progressSheetDescription;
- (void)publish:(id)aPublish;
- (void)terminatePublish;
- (void)notifyPublishDidTerminate;
- (void)serverUploader:(id)aUploader didFailWithError:(id)aError;
- (void)serverUploaderDidFinish:(id)aUploader;
- (void)dealloc;
@end
