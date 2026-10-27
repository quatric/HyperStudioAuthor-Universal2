#import "HSITunesPublisher.h"

@implementation HSITunesPublisher

+ (id)applicationBundleForBundleID:(id)aID creator:(NSUInteger)aCreator
{
    // Fix: LSFindApplicationForInfo (which also matched the creator code) is replaced by the bundle identifier lookup.
    NSURL *url = [[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier:aID];
    if (url == nil || ![url isFileURL])
        return nil;
    NSString *path = [[url absoluteURL] path];
    return path != nil ? [NSBundle bundleWithPath:path] : nil;
}

+ (BOOL)iTunesApplicationVersionSupported
{
    return [self iTunesApplicationVersion] >= 6.0f;
}

+ (CGFloat)iTunesApplicationVersion
{
    NSBundle *bundle = [self applicationBundleForBundleID:@"com.apple.iTunes" creator:'hook'];
    if (bundle == nil)
        return 0.0;
    return [[[bundle infoDictionary] objectForKey:@"CFBundleShortVersionString"] floatValue];
}

- (void)iTunesLibraryMissingAlertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    [self notifyPublishDidTerminate];
}

- (void)iTunesUnaccessableAlertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    NSString *path = [[self publishLocation] stringByAppendingPathComponent:[_publishWrapper preferredFilename]];
    if (aCode != NSAlertFirstButtonReturn) {
        [self notifyPublishDidTerminate];
        return;
    }
    id error = nil;
    BOOL proceed = NO;
    BOOL writable;
    if (![[HSSystem sharedSystem] isSandboxed]) {
        BOOL isDirectory = YES;
        writable = [[NSFileManager defaultManager] hyperIsFileWritableAtPath:path directory:&isDirectory] && isDirectory;
    } else {
        writable = [[NSFileManager defaultManager] hyperIsFileWritableAtPath:path checkDirectory:NO];
    }
    if (!writable)
        error = [HSError errorWithHSCode:0x502b];
    else if (![_publishWrapper writeToFile:path atomically:NO updateFilenames:NO])
        error = [HSError errorWithHSCode:0x5025];
    else
        proceed = !_shouldTerminatePublish;
    if (proceed)
        [self transferDataToITunesLibraryFromPath:path];
    else if (error != nil)
        [self notifyPublishErrorInProgress:error];
    else
        [self notifyPublishDidTerminate];
}

- (void)publish:(id)aPublish
{
    NSString *filename = [aPublish preferredFilename];
    // Original quirk kept: a previous wrapper is not released.
    _publishWrapper = [aPublish retain];
    _shouldTerminatePublish = NO;
    [self notifyPublishWillStart];
    [self notifyPublishDidStart];
    if ([[self class] iTunesApplicationVersionSupported]) {
        [self iTunesUnaccessableAlertDidEnd:nil returnCode:NSAlertFirstButtonReturn contextInfo:NULL];
        return;
    }
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *informativeText = [bundle localizedStringForKey:@"HSExportiTunesUnaccessableInformativeText" value:@"" table:@"Export"];
    NSString *cancel = [bundle localizedStringForKey:@"HSExportiTunesUnaccessableCancel" value:@"" table:@"Export"];
    NSString *proceed = [bundle localizedStringForKey:@"HSExportiTunesUnaccessableContinue" value:@"" table:@"Export"];
    NSString *message = [NSString stringWithFormat:[bundle localizedStringForKey:@"HSExportiTunesUnaccessableMessageText" value:@"" table:@"Export"], [filename stringByDeletingPathExtension]];
    id alert = [HSAlert alertWithMessageText:message defaultButton:proceed alternateButton:cancel otherButton:nil informativeText:informativeText];
    NSDictionary *alertInfo = [NSDictionary dictionaryWithObjectsAndKeys:alert, HSExportAlertKey, self, HSExportAlertTargetKey, [NSNumber numberWithBool:YES], HSExportAlertTargetActivityKey, NSStringFromSelector(@selector(iTunesUnaccessableAlertDidEnd:returnCode:contextInfo:)), HSExportAlertDidEndSelectorKey, nil];
    [self notifyPublishAlertInProgress:alertInfo];
}

- (void)transferDataToITunesLibraryFromPath:(id)aPath
{
    BOOL failed;
    NSAppleScript *script = nil;
    NSString *hfsPath = nil;
    if (![[HSSystem sharedSystem] isSandboxed]) {
        NSURL *url = [NSURL fileURLWithPath:aPath];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        hfsPath = (NSString *)CFURLCopyFileSystemPath((CFURLRef)url, kCFURLHFSPathStyle);
#pragma clang diagnostic pop
        NSString *source = [NSString stringWithFormat:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"HSExportAddFileToiTunesLibrary" value:@"" table:@"Export"], hfsPath];
        script = [[NSAppleScript alloc] initWithSource:source];
        NSDictionary *errorInfo = nil;
        [script executeAndReturnError:&errorInfo];
        failed = errorInfo != nil;
    } else {
        failed = ![[NSWorkspace sharedWorkspace] openFile:aPath withApplication:@"iTunes"];
    }
    [script release];
    [hfsPath release];
    if (!failed) {
        [self notifyPublishDidEnd];
        return;
    }
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *informativeText = [bundle localizedStringForKey:@"HSExportiTunesLibraryMissingInformativeText" value:@"" table:@"Export"];
    NSString *ok = [bundle localizedStringForKey:@"HSExportiTunesLibraryMissingOK" value:@"" table:@"Export"];
    NSString *message = [NSString stringWithFormat:[bundle localizedStringForKey:@"HSExportiTunesLibraryMissingMessageText" value:@"" table:@"Export"], [[aPath lastPathComponent] stringByDeletingPathExtension]];
    id alert = [HSAlert alertWithMessageText:message defaultButton:ok alternateButton:nil otherButton:nil informativeText:informativeText];
    NSDictionary *alertInfo = [NSDictionary dictionaryWithObjectsAndKeys:alert, HSExportAlertKey, self, HSExportAlertTargetKey, NSStringFromSelector(@selector(iTunesLibraryMissingAlertDidEnd:returnCode:contextInfo:)), HSExportAlertDidEndSelectorKey, nil];
    [self notifyPublishAlertInProgress:alertInfo];
}

- (id)progressSheetDescription
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"PublishSheetProgressITunesDescription" value:@"" table:@"Publish"];
}

- (void)dealloc
{
    [_publishWrapper release];
    [super dealloc];
}

@end
