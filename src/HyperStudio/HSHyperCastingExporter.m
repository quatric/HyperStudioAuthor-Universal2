#import "HSHyperCastingExporter.h"

@implementation HSHyperCastingExporter

- (void)notifyExportDidTerminate
{
    [self setHyperCastingLauncher:nil];
    [super notifyExportDidTerminate];
}

- (void)notifyExportDidEnd
{
    [self setHyperCastingLauncher:nil];
    [super notifyExportDidEnd];
}

// Converts the recorded movie to the requested format (iPod/iPhone) or wraps
// it as is (QuickTime), adding the artwork image, and reports the result.
- (void)didConfirmHyperCastingWindowController:(id)aController
{
    [[self hyperCastingLauncher] exitFromHyperCastingModeWithReturnCode:1];
    NSError *error = nil;
    NSString *recordingPath = [[[self hyperCastingLauncher] hyperCastingWindowController] recordingPath];
    QTMovie *movie = [QTMovie movieWithFile:recordingPath error:&error];
    NSString *extension;
    NSString *path;
    BOOL succeeded;
    OSType type = 0;
    if (!movie) {
        extension = @"mov";
        path = nil;
        succeeded = NO;
    } else {
        if ([_documentType isEqualToString:@"HSiPodDocumentType"]) {
            type = 'M4V ';
            extension = @"m4v";
            path = nil;
            succeeded = NO;
        } else if ([_documentType isEqualToString:@"HSiPhoneDocumentType"]) {
            type = 'M4VP';
            extension = @"m4v";
            path = nil;
            succeeded = NO;
        } else if ([_documentType isEqualToString:@"HSQTMovieDocumentType"]) {
            type = 'MOV ';
            extension = @"mov";
            succeeded = YES;
            path = recordingPath;
        } else {
            path = nil;
            extension = @"mov";
            succeeded = NO;
            type = 0;
        }
        id artwork = [[self dataSource] artworkImageForExporter:self];
        if (artwork)
            [HSQuickTimeMovieHelper addArtworkImage:artwork inMovie:movie ofType:type];
        if (type != 0 && type != 'MOV ') {
            path = [NSString extraCreateUniqueFilename:[[[HSPathsProvider sharedPathsProvider] temporaryFolder] stringByAppendingPathComponent:[self exportedDocumentName]] extension:extension];
            NSInteger result = [HSQuickTimeMovieHelper convertMovie:movie frameSize:[self movieFrameSize] ofType:type toFile:path progressCallback:NULL sender:self];
            [[NSFileManager defaultManager] removeFileAtPath:recordingPath handler:nil];
            succeeded = result == 0;
        }
    }
    [_exportRepresentation autorelease];
    if (succeeded) {
        _exportRepresentation = [[NSFileWrapper alloc] initWithPath:path];
        [_exportRepresentation setPreferredFilename:[[self exportedDocumentName] stringByAppendingPathExtension:extension]];
    } else {
        _exportRepresentation = nil;
        if (!error)
            error = [HSError errorWithHSCode:0x5025];
        [self notifyExportErrorInProgress:error];
    }
    [[NSFileManager defaultManager] removeFileAtPath:path handler:nil];
    [self notifyExportDidEnd];
}

- (void)didCancelHyperCastingWindowController:(id)aController
{
    [self terminateExport];
    [[self hyperCastingLauncher] exitFromHyperCastingModeWithReturnCode:0];
    [self notifyExportDidTerminate];
}

- (void)terminateExport
{
    [super terminateExport];
    if ([[[self hyperCastingLauncher] hyperCastingWindowController] isRecording])
        [[[self hyperCastingLauncher] hyperCastingWindowController] cancelRecording];
}

- (void)performExportDocument:(id)aDocument ofType:(id)aType
{
    _shouldTerminateExport = NO;
    [self notifyExportWillStartWithSlideshowAttributes:nil];
    [self notifyExportDidStart];
    [_documentType autorelease];
    _documentType = [aType retain];
    NSString *path = [NSString extraCreateUniqueFilename:[[[HSPathsProvider sharedPathsProvider] temporaryFolder] stringByAppendingPathComponent:[self exportedDocumentName]] extension:@"mov"];
    [self setHyperCastingLauncher:[[self dataSource] hyperCastingLauncherForExporter:self]];
    id controller = [[self hyperCastingLauncher] hyperCastingWindowController];
    [controller setRecordingPath:path];
    [controller setRoundedCornersForMovie:[self canUseRoundedCorners]];
    [controller setRecordedMovieFormat:[self recordedMovieFormat]];
    [controller setMovieSize:[self movieFrameSize]];
    [controller setFramesPerSecondLimit:[self framesPerSecondLimit]];
    [[self hyperCastingLauncher] switchToHyperCastingModeWithDelegate:self];
}

- (void)setUseRoundedCorners:(BOOL)aCorners
{
    if (_canUseRoundedCorners != aCorners)
        _canUseRoundedCorners = aCorners;
}

- (BOOL)canUseRoundedCorners
{
    return _canUseRoundedCorners;
}

- (void)setMovieFrameSize:(NSSize)aSize
{
    if (!NSEqualSizes(_movieFrameSize, aSize))
        _movieFrameSize = aSize;
}

- (NSSize)movieFrameSize
{
    return _movieFrameSize;
}

- (void)setRecordedMovieFormat:(NSInteger)aFormat
{
    if (_recordedMovieFormat != aFormat)
        _recordedMovieFormat = (int)aFormat;
}

- (NSInteger)recordedMovieFormat
{
    return _recordedMovieFormat;
}

- (void)setHyperCastingLauncher:(id)aLauncher
{
    if (_hyperCastingLauncher != aLauncher) {
        [_hyperCastingLauncher release];
        _hyperCastingLauncher = [aLauncher retain];
    }
}

- (id)hyperCastingLauncher
{
    return _hyperCastingLauncher;
}

- (BOOL)isSupportedProgressSheet
{
    return NO;
}

- (void)setDataSource:(id)aSource
{
    [super setDataSource:aSource];
}

- (void)dealloc
{
    [_documentType release];
    [_hyperCastingLauncher release];
    [super dealloc];
}

@end
