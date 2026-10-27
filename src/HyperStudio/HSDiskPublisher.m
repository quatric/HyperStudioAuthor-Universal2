#import "HSDiskPublisher.h"

@implementation HSDiskPublisher

- (void)publish:(id)aPublish
{
    NSString *filename = [aPublish preferredFilename];
    NSString *location = [self publishLocation];
    [self notifyPublishWillStart];
    [self notifyPublishDidStart];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    id error = nil;
    if (location != nil) {
        NSString *path = [location stringByAppendingPathComponent:filename];
        BOOL writable;
        if (![[HSSystem sharedSystem] isSandboxed]) {
            BOOL isDirectory = YES;
            writable = [fileManager hyperIsFileWritableAtPath:path directory:&isDirectory] && isDirectory;
        } else {
            writable = [fileManager hyperIsFileWritableAtPath:path checkDirectory:NO];
        }
        if (!writable) {
            error = [HSError errorWithHSCode:0x502b];
        } else {
            id creationDate = [NSDate date];
            if ([fileManager fileExistsAtPath:path])
                creationDate = [[fileManager attributesOfItemAtPath:[path stringByResolvingSymlinksInPath] error:NULL] objectForKey:NSFileCreationDate];
            NSMutableDictionary *attributes = [[aPublish fileAttributes] mutableCopy];
            if (creationDate != nil)
                [attributes setObject:creationDate forKey:NSFileCreationDate];
            [attributes setObject:[NSDate date] forKey:NSFileModificationDate];
            if (attributes != nil) {
                [aPublish setFileAttributes:attributes];
                [attributes release];
            }
            // The pre-10.6 -writeToFile:atomically:updateFilenames: branch of the original is not needed.
            NSURL *url = [NSURL fileURLWithPath:path];
            BOOL succeeded = NO;
            if (url != nil) {
                NSError *writeError = nil;
                BOOL written = [aPublish writeToURL:url options:NSFileWrapperWritingAtomic originalContentsURL:nil error:&writeError];
                if (writeError != nil) {
                    error = [HSError errorWithError:writeError];
                    succeeded = written;
                } else {
                    succeeded = written && !_shouldTerminatePublish;
                }
            }
            if (succeeded) {
                [_storePath release];
                _storePath = [path retain];
                BOOL isMovie = [[HSNewMediaAccessor supportedMediaTypesForClass:@"HSMovieObject"] containsObject:[path pathExtension]];
                BOOL openMovie = [[[NSUserDefaults standardUserDefaults] objectForKey:HSOpenMovieInQTPlayerKey] boolValue];
                if (isMovie && openMovie)
                    [[NSWorkspace sharedWorkspace] openFile:path];
                BOOL isDirectory = NO;
                if ([fileManager fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory && [fileManager fileExistsAtPath:[path stringByAppendingPathComponent:@"index.html"]])
                    [self showFinishWindow];
                else
                    [self notifyPublishDidEnd];
                return;
            }
        }
    }
    if (_shouldTerminatePublish) {
        [self notifyPublishDidTerminate];
        return;
    }
    if (error == nil)
        error = [HSError errorWithHSCode:0x5025];
    [self notifyPublishErrorInProgress:error];
}

- (id)progressSheetDescription
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"PublishSheetProgressDiskDescription" value:@"" table:@"Publish"];
}

- (void)dealloc
{
    [_storePath release];
    [_embeddedCode release];
    [_finishWindow release];
    [super dealloc];
}

@end
