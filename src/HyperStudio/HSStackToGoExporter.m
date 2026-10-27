#import "HSStackToGoExporter.h"

@implementation HSStackToGoExporter

- (BOOL)canRunAction:(id)aAction
{
    return [aAction supportedInStackToGo];
}

- (BOOL)shouldVerifyDocumentActions
{
    return YES;
}

// Copies the HyperStackToGo player and puts the stack in its Contents/Stack folder.
// Original quirk kept: progress is reported as one third at every step.
- (void)performExportDocument:(id)aDocument ofType:(id)aType
{
    NSAutoreleasePool *pool;
    NSFileWrapper *application;
    NSFileWrapper *contents;
    NSError *documentError = nil;
    id error = nil;
    BOOL failed = YES;

    _shouldTerminateExport = 0;
    [self notifyExportWillStartWithSlideshowAttributes:nil];
    [self notifyExportDidStart];
    pool = [NSAutoreleasePool new];
    [self notifyExportProgressDidChangeWithProgress:0.0];
    application = [[[NSFileWrapper alloc] initWithPath:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/Resources/HyperStackToGo.app"]] autorelease];
    if (application != nil && !_shouldTerminateExport) {
        [application setPreferredFilename:[[self exportedDocumentName] stringByAppendingPathExtension:@"app"]];
        contents = [[application fileWrappers] objectForKey:@"Contents"];
        if (contents != nil) {
            NSFileWrapper *document;

            [self notifyExportProgressDidChangeWithProgress:100.0 / 3.0];
            document = [aDocument fileWrapperOfType:@"HSDocumentType" error:&documentError];
            if (document == nil || documentError != nil || _shouldTerminateExport) {
                // Fix: the error outlives the pool now.
                if (documentError != nil)
                    error = [[HSError errorWithError:documentError] retain];
            }
            else {
                NSString *path = [NSString extraCreateUniqueFilename:[[[HSPathsProvider sharedPathsProvider] temporaryFolder] stringByAppendingPathComponent:[self exportedDocumentName]] extension:@"stack"];

                if ([document writeToFile:path atomically:NO updateFilenames:NO]) {
                    [self notifyExportProgressDidChangeWithProgress:100.0 / 3.0];
                    if (!_shouldTerminateExport) {
                        NSString *fileName = [[self exportedDocumentName] stringByAppendingPathExtension:@"stack"];
                        NSFileWrapper *stack;

                        if (fileName != nil && (stack = [[NSFileWrapper alloc] initWithPath:path]) != nil) {
                            NSDictionary *wrappers;
                            NSFileWrapper *folder;

                            [stack setPreferredFilename:fileName];
                            wrappers = [NSDictionary dictionaryWithObject:stack forKey:fileName];
                            [stack release];
                            if (wrappers != nil && (folder = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:wrappers]) != nil) {
                                [folder setPreferredFilename:@"Stack"];
                                [contents addFileWrapper:folder];
                                [folder release];
                                [self notifyExportProgressDidChangeWithProgress:100.0 / 3.0];
                                failed = _shouldTerminateExport;
                            }
                        }
                    }
                }
            }
        }
    }
    [_exportRepresentation autorelease];
    if (!failed) {
        _exportRepresentation = [application retain];
        [pool release];
        [self notifyExportDidEnd];
    }
    else {
        _exportRepresentation = nil;
        [pool release];
        if (_shouldTerminateExport)
            [self notifyExportDidTerminate];
        else
            [self notifyExportErrorInProgress:error != nil ? error : [HSError errorWithHSCode:0x5025]];
    }
    [error release];
}

- (id)progressSheetDescription
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"ExportSheetProgressStackToGoDescription" value:@"" table:@"Export"];
}

- (id)exportAccessoryViewControllerForPublishType:(NSInteger)aType
{
    if (_exportAccessoryViewController == nil)
        _exportAccessoryViewController = [[HSStackToGoExportAccessoryViewController alloc] initWithExporter:self publishType:aType];
    return _exportAccessoryViewController;
}

@end
