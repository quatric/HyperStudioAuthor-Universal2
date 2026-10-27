#import "HSDiskPublisher.h"

@implementation HSDiskPublisher

- (void)embedCode:(id)aCode
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    if (_embeddedCode == nil && [[self delegate] respondsToSelector:@selector(embeddedCode:)]) {
        id code = [[self delegate] embeddedCode:self];
        if (code != nil) {
            id iframe = [code elementNamed:@"iframe"];
            NSString *string = [[NSString alloc] initWithData:[code data] encoding:NSUTF8StringEncoding];
            if (iframe != nil) {
                _embeddedCode = string;
            } else {
                [string autorelease];
                NSRange start = [string rangeOfString:@"<!-- Start of Embed Code -->"];
                NSRange end = [string rangeOfString:@"<!-- End of Embed Code -->"];
                if (start.length != 0 && end.length != 0) {
                    NSString *embedded = [string substringWithRange:NSMakeRange(start.location, end.location - start.location + end.length)];
                    if (embedded != nil)
                        _embeddedCode = [embedded retain];
                }
            }
        }
    }
    if (_embeddedCode != nil) {
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard declareTypes:[NSArray arrayWithObject:NSPasteboardTypeString] owner:nil];
        [pasteboard setString:_embeddedCode forType:NSPasteboardTypeString];
    }
    [pool release];
}

- (void)finish:(id)aFinish
{
    [NSApp endSheet:[self finishWindow] returnCode:1];
    [_finishWindow close];
    // Original quirk kept: the nib-loaded window is dropped without a release.
    _finishWindow = nil;
}

- (void)previewSiteNow:(id)aNow
{
    [NSApp endSheet:[self finishWindow] returnCode:0];
    [[NSWorkspace sharedWorkspace] openFile:[_storePath stringByAppendingPathComponent:@"index.html"] withApplication:@"Safari"];
    [_finishWindow close];
    _finishWindow = nil;
}

- (void)finishSheetDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    [self notifyPublishDidEnd];
}

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

- (void)showFinishWindow
{
    id window = [self finishWindow];
    [_filePathTextField setStringValue:[_storePath stringByAppendingString:@"."]];
    NSDictionary *alertInfo = [NSDictionary dictionaryWithObjectsAndKeys:window, HSExportCustomAlertKey, self, HSExportAlertTargetKey, NSStringFromSelector(@selector(finishSheetDidEnd:returnCode:contextInfo:)), HSExportAlertDidEndSelectorKey, nil];
    [self notifyPublishAlertInProgress:alertInfo];
}

- (id)finishWindow
{
    if (_finishWindow == nil)
        [NSBundle loadNibNamed:@"HSDiskPublisherFinishWindow" owner:self];
    return _finishWindow;
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
