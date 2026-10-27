#import "HSWebExporter2.h"

@implementation HSWebExporter2

+ (id)htmlTemplateDocumentWithDocument:(id)aDocument resourcePath:(id)aPath
{
    NSSize size = aDocument != nil ? [[aDocument stack] hyperCardSize] : [HSUserObjectDefaultAttributesProvider defaultCardSize];
    CFURLRef url = CFURLCreateWithFileSystemPathRelativeToBase(kCFAllocatorDefault, (CFStringRef)aPath, kCFURLPOSIXPathStyle, false, NULL);
    if (url == NULL)
        return nil;
    CFStringRef path = CFURLCopyStrictPath(url, NULL);
    CFRelease(url);
    if (path == NULL)
        return nil;
    id document = [self htmlTemplateDocumentWithWidth:size.width height:size.height forStackAtURLWithString:(NSString *)path];
    CFRelease(path);
    return document;
}

+ (id)htmlTemplateDocumentWithWidth:(CGFloat)aWidth height:(CGFloat)aHeight forStackAtURLWithString:(id)aString
{
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"webtemplate" ofType:@"html"]];
    HSXMLDocument *document = [[[HSXMLDocument alloc] initWithData:data] autorelease];
    id root = [document rootElement];
    [(HSXMLNode *)[root elementNamed:@"DOCUMENT_NAME"] setName:@""];
    id embed = [root elementNamed:@"embed"];
    NSMutableDictionary *embedAttributes = [NSMutableDictionary dictionaryWithDictionary:[embed attributes]];
    id object = [root elementNamed:@"object"];
    NSMutableDictionary *objectAttributes = [NSMutableDictionary dictionaryWithDictionary:[object attributes]];
    NSSize frameSize = [HSPlayerInEditorWindowController frameSizeForStackSize:NSMakeSize(aWidth, aHeight) withScrollView:NO];
    [embedAttributes setObject:[NSString stringWithFormat:@"%d", (int)frameSize.width] forKey:@"width"];
    [embedAttributes setObject:[NSString stringWithFormat:@"%d", (int)frameSize.height] forKey:@"height"];
    [objectAttributes setObject:[NSString stringWithFormat:@"%d", (int)frameSize.width] forKey:@"width"];
    [objectAttributes setObject:[NSString stringWithFormat:@"%d", (int)frameSize.height] forKey:@"height"];
    NSMutableString *source = [aString mutableCopy];
    [source replaceOccurrencesOfString:@"&" withString:@"%26" options:0 range:NSMakeRange(0, [source length])];
    [source autorelease];
    id param = [object elementNamed:@"param"];
    NSMutableDictionary *paramAttributes = [NSMutableDictionary dictionaryWithDictionary:[param attributes]];
    [paramAttributes setObject:source forKey:@"value"];
    [embedAttributes setObject:source forKey:@"src"];
    [embed setAttributes:embedAttributes];
    [object setAttributes:objectAttributes];
    [param setAttributes:paramAttributes];
    return document;
}

- (BOOL)canRunAction:(id)aAction
{
    return [aAction supportedInWebPlayer];
}

- (BOOL)shouldVerifyDocumentActions
{
    return YES;
}

- (id)embeddedCode
{
    return _embeddedCode;
}

// Builds the web page folder: the player data, a .files folder with the stack and its preview image, and index.html.
- (void)performExportDocument:(id)aDocument ofType:(id)aType
{
    NSAutoreleasePool *pool;
    NSFileWrapper *page;
    NSString *webdataPath;
    NSError *documentError = nil;
    id error = nil;
    BOOL succeeded = NO;

    _shouldTerminateExport = 0;
    [self notifyExportWillStartWithSlideshowAttributes:nil];
    [self notifyExportDidStart];
    pool = [NSAutoreleasePool new];
    [self notifyExportProgressDidChangeWithProgress:0.0];
    page = [[[NSFileWrapper alloc] initDirectoryWithFileWrappers:[NSDictionary dictionary]] autorelease];
    [page setPreferredFilename:[self exportedDocumentName]];
    webdataPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"webdata"];
    if (webdataPath != nil && !_shouldTerminateExport) {
        NSFileWrapper *files;
        NSFileWrapper *document;

        [page addFileWrapper:[[[NSFileWrapper alloc] initWithPath:webdataPath] autorelease]];
        [self notifyExportProgressDidChangeWithProgress:25.0];
        files = [[[NSFileWrapper alloc] initDirectoryWithFileWrappers:[NSDictionary dictionary]] autorelease];
        [files setPreferredFilename:[[self exportedDocumentName] stringByAppendingPathExtension:@"files"]];
        document = [aDocument fileWrapperOfType:@"HSDocumentType" error:&documentError];
        if (document == nil || documentError != nil || _shouldTerminateExport) {
            // Fix: the error outlives the pool now.
            if (documentError != nil)
                error = [[HSError errorWithError:documentError] retain];
        }
        else {
            NSString *path = [NSString extraCreateUniqueFilename:[[[HSPathsProvider sharedPathsProvider] temporaryFolder] stringByAppendingPathComponent:[self exportedDocumentName]] extension:@"stack"];

            succeeded = [document writeToFile:path atomically:NO updateFilenames:NO];
            if (succeeded) {
                NSFileWrapper *stack;

                [self notifyExportProgressDidChangeWithProgress:25.0];
                stack = [[[NSFileWrapper alloc] initWithPath:path] autorelease];
                [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
                if (stack == nil || _shouldTerminateExport) {
                    succeeded = NO;
                }
                else {
                    NSData *image;
                    NSData *html;

                    [stack setPreferredFilename:[[self exportedDocumentName] stringByAppendingPathExtension:@"stack"]];
                    [files addFileWrapper:stack];
                    image = [[[[aDocument stack] queryHyperInterface:@protocol(HSUserObjectImageProvider)] imageForExport] hyperRepresentationUsingType:NSBitmapImageFileTypeJPEG properties:nil];
                    if ([image length] != 0)
                        [files addRegularFileWithContents:image preferredFilename:[[self exportedDocumentName] stringByAppendingPathExtension:@"jpg"]];
                    [page addFileWrapper:files];
                    [self notifyExportProgressDidChangeWithProgress:25.0];
                    html = [self htmlTemplateWithDocument:aDocument resourcePath:[[files preferredFilename] stringByAppendingPathComponent:[stack preferredFilename]]];
                    if (html == nil || _shouldTerminateExport) {
                        succeeded = NO;
                    }
                    else {
                        [page addRegularFileWithContents:html preferredFilename:@"index.html"];
                        [self notifyExportProgressDidChangeWithProgress:25.0];
                    }
                }
            }
        }
    }
    [_exportRepresentation autorelease];
    if (succeeded) {
        _exportRepresentation = [page retain];
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

- (id)htmlTemplateWithDocument:(id)aDocument resourcePath:(id)aPath
{
    HSXMLDocument *document = [[self class] htmlTemplateDocumentWithDocument:aDocument resourcePath:aPath];
    // Original quirk kept: a previous embedded code is not released.
    _embeddedCode = [[document rootElement] retain];
    return [document data];
}

- (id)progressSheetDescription
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"ExportSheetProgressWebPageDescription" value:@"" table:@"Export"];
}

- (id)exportAccessoryViewControllerForPublishType:(NSInteger)aType
{
    if (_exportAccessoryViewController == nil)
        _exportAccessoryViewController = [[HSWebPageExportAccessoryViewController alloc] initWithExporter:self publishType:aType];
    return _exportAccessoryViewController;
}

- (void)dealloc
{
    [_embeddedCode release];
    [super dealloc];
}

@end
