#import "HSAFTPServerPublisher.h"
#import "HyperStudioUmbrella.h"

@interface NSFileManager (HSAFTPServerPublisherWritable)
- (BOOL)hyperIsFileWritableAtPath:(id)aPath checkDirectory:(BOOL)aCheck;
@end

@interface HSError (HSAFTPServerPublisherErrors)
+ (id)errorWithHSCode:(NSInteger)aCode;
@end

@interface HSAFTPServerPublisher (HSAFTPServerPublisher_)
- (void)HSAFTPServerPublisher_cleanupTemporaryResources;
- (void)HSAFTPServerPublisher_cleanup;
@end


@implementation HSAFTPServerPublisher

- (void)dealloc
{
    [_ftpServerUploader setDelegate:nil];
    [_ftpServerUploader release];
    [super dealloc];
}

- (void)setConnection:(id)aConnection
{
    if (aConnection != nil) {
        [_ftpServerUploader setDelegate:nil];
        [_ftpServerUploader release];
        _ftpServerUploader = [[HSAHTML5FTPServerUploader alloc] initWithConnection:aConnection];
        [_ftpServerUploader setDelegate:self];
    }
}

- (void)setStorePath:(id)aPath
{
    if (![_storePath isEqualToString:aPath]) {
        [_storePath release];
        _storePath = [aPath copy];
    }
}

- (void)setFileShouldBeRemoved:(BOOL)aRemoved
{
    if ((BOOL)_fileShouldBeRemoved != aRemoved) {
        _fileShouldBeRemoved = aRemoved ? 1 : 0;
    }
}

- (void)HSAFTPServerPublisher_cleanupTemporaryResources
{
    if (_storePath != nil) {
        if (![NSTemporaryDirectory() isEqualToString:_storePath]) {
            [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:_storePath isDirectory:YES] error:NULL];
            [_storePath release];
            _storePath = nil;
        }
    }
}

- (void)HSAFTPServerPublisher_cleanup
{
    [self HSAFTPServerPublisher_cleanupTemporaryResources];
    [_ftpServerUploader setDelegate:nil];
    [_ftpServerUploader release];
    _ftpServerUploader = nil;
}

- (id)exportPanelController
{
    if (_exportPanelController == nil) {
        _exportPanelController = [[HSAFTPServerExportPanelController alloc] initWithPublisher:self];
    }
    return _exportPanelController;
}

- (id)progressSheetDescription
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"PublishSheetProgressFTPServerDescription" value:@"" table:@"Publish"];
}

- (void)publish:(id)aPublish
{
    [self notifyPublishWillStart];
    [self notifyPublishDidStart];
    NSError *error = nil;
    if (![[NSFileManager defaultManager] hyperIsFileWritableAtPath:_storePath checkDirectory:NO]) {
        error = [HSError errorWithHSCode:0x502b];
    } else {
        NSURL *url = [NSURL fileURLWithPath:_storePath];
        if (url != nil) {
            [aPublish writeToURL:url options:1 originalContentsURL:nil error:&error];
            if (error == nil) {
                [_ftpServerUploader uploadFolderAtURL:[NSURL fileURLWithPath:_storePath isDirectory:YES] removeIfExist:_fileShouldBeRemoved];
            }
        }
    }
    if (_shouldTerminatePublish) {
        [self notifyPublishDidTerminate];
    } else if (error != nil) {
        [self notifyPublishErrorInProgress:error];
    }
}

- (void)terminatePublish
{
    [super terminatePublish];
    [self notifyPublishDidTerminate];
}

- (void)notifyPublishDidTerminate
{
    [_ftpServerUploader cleanup];
    [self HSAFTPServerPublisher_cleanup];
    [super notifyPublishDidTerminate];
}

- (void)serverUploaderDidFinish:(id)aUploader
{
    [self HSAFTPServerPublisher_cleanup];
    [self notifyPublishDidEnd];
}

- (void)serverUploader:(id)aUploader didFailWithError:(id)aError
{
    [_ftpServerUploader cleanup];
    [self HSAFTPServerPublisher_cleanup];
    [self notifyPublishErrorInProgress:aError];
}

@end
