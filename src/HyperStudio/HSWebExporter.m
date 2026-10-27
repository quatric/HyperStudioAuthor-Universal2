#import "HSWebExporter.h"

@implementation HSWebExporter

- (BOOL)fileManager:(id)aManager shouldProceedAfterError:(id)aError
{
    return YES;
}

- (void)fileManager:(id)aManager willProcessPath:(id)aPath
{
}

- (id)backupPathWithPath:(id)aPath
{
    return [NSString stringWithFormat:@"%@~", aPath];
}

- (void)setfullDocumentPath:(id)aPath
{
    if (_fullDocumentPath != aPath) {
        [_fullDocumentPath release];
        _fullDocumentPath = [aPath retain];
    }
}

- (id)htmlTemplateWithDocument:(id)aDocument dirPath:(id)aPath
{
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"webtemplate" ofType:@"html"]];
    HSXMLDocument *document = [[[HSXMLDocument alloc] initWithData:data] autorelease];
    id root = [document rootElement];
    [(HSXMLNode *)[root elementNamed:@"DOCUMENT_NAME"] setName:[_fullDocumentPath lastPathComponent]];
    id embed = [root elementNamed:@"embed"];
    NSMutableDictionary *embedAttributes = [NSMutableDictionary dictionaryWithDictionary:[embed attributes]];
    id object = [root elementNamed:@"object"];
    NSMutableDictionary *objectAttributes = [NSMutableDictionary dictionaryWithDictionary:[object attributes]];
    NSSize frameSize = [HSPlayerInEditorWindowController frameSizeForStackSize:[[aDocument stack] hyperCardSize] withScrollView:NO];
    int width = (int)frameSize.width;
    int height = (int)frameSize.height;
    [embedAttributes setObject:[NSString stringWithFormat:@"%d", width] forKey:@"width"];
    [embedAttributes setObject:[NSString stringWithFormat:@"%d", height] forKey:@"height"];
    [objectAttributes setObject:[NSString stringWithFormat:@"%d", width] forKey:@"width"];
    [objectAttributes setObject:[NSString stringWithFormat:@"%d", height] forKey:@"height"];
    id noscript = [root elementNamed:@"noscript"];
    id noscriptEmbed = [noscript elementNamed:@"embed"];
    id noscriptObject = [noscript elementNamed:@"object"];
    NSMutableDictionary *noscriptEmbedAttributes = [NSMutableDictionary dictionaryWithDictionary:[noscriptEmbed attributes]];
    NSMutableDictionary *noscriptObjectAttributes = [NSMutableDictionary dictionaryWithDictionary:[noscriptObject attributes]];
    [noscriptEmbedAttributes setObject:[NSString stringWithFormat:@"%d", width] forKey:@"width"];
    [noscriptEmbedAttributes setObject:[NSString stringWithFormat:@"%d", height] forKey:@"height"];
    [noscriptObjectAttributes setObject:[NSString stringWithFormat:@"%d", width] forKey:@"width"];
    [noscriptObjectAttributes setObject:[NSString stringWithFormat:@"%d", height] forKey:@"height"];
    // The stack is referenced by the last two path components: "<name>.files/<name>.stack".
    NSArray *components = [aPath pathComponents];
    NSString *source = [[NSString pathWithComponents:[components subarrayWithRange:NSMakeRange([components count] - 2, 2)]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    id param = [object elementNamed:@"param"];
    id noscriptParam = [noscriptObject elementNamed:@"param"];
    NSMutableDictionary *paramAttributes = [NSMutableDictionary dictionaryWithDictionary:[param attributes]];
    NSMutableDictionary *noscriptParamAttributes = [NSMutableDictionary dictionaryWithDictionary:[noscriptParam attributes]];
    [paramAttributes setObject:source forKey:@"value"];
    [noscriptParamAttributes setObject:source forKey:@"value"];
    [embedAttributes setObject:source forKey:@"src"];
    [embed setAttributes:embedAttributes];
    [object setAttributes:objectAttributes];
    [param setAttributes:paramAttributes];
    [noscriptEmbedAttributes setObject:source forKey:@"src"];
    // Original quirk kept: the noscript elements get the outer embed and object attributes, not their own.
    [noscriptEmbed setAttributes:embedAttributes];
    [noscriptObject setAttributes:objectAttributes];
    [noscriptParam setAttributes:noscriptParamAttributes];
    return [document data];
}

- (void)stopExport
{
    _needStopExport = YES;
}

// Writes a folder at the destination with the player data, a .files folder holding the stack and index.html.
// The folder is built under a "~" backup path first and moved into place at the end.
// The file manager calls with handlers are gone from the SDK; the -...Item... calls replace them.
- (BOOL)exportDocument:(id)aDocument withBackupToFile:(id)aFile ofType:(id)aType error:(id *)aError
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL succeeded = NO;
    BOOL directory = YES;
    id error = nil;
    NSString *backupPath;
    NSDictionary *attributes;

    _needStopExport = NO;
    if ([[self delegate] respondsToSelector:@selector(shouldStartWebExporter:)] && ![[self delegate] shouldStartWebExporter:self])
        goto end;
    if ([[self delegate] respondsToSelector:@selector(webExportProgressDidChange:withProgress:)])
        [_delegate webExportProgressDidChange:self withProgress:0.0];
    [self setfullDocumentPath:aFile];
    attributes = [aDocument fileAttributesToWriteToURL:[NSURL fileURLWithPath:_fullDocumentPath] ofType:aType forSaveOperation:NSSaveToOperation originalContentsURL:nil error:NULL];
    backupPath = _fullDocumentPath;
    if (![fileManager hyperIsFileWritableAtPath:_fullDocumentPath directory:&directory] || !directory) {
        error = [HSError fileErrorWithHSCode:0x502b filePath:[aDocument displayName]];
        goto failed;
    }
    do {
        backupPath = [self backupPathWithPath:backupPath];
    } while ([fileManager fileExistsAtPath:backupPath] && !_needStopExport);
    if (![fileManager createDirectoryAtPath:backupPath withIntermediateDirectories:NO attributes:attributes error:NULL] || _needStopExport)
        goto failed;
    if ([[self delegate] respondsToSelector:@selector(webExportProgressDidChange:withProgress:)])
        [_delegate webExportProgressDidChange:self withProgress:100.0 / 6.0];
    [fileManager copyItemAtPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"webdata"] toPath:[backupPath stringByAppendingPathComponent:@"webdata"] error:NULL];
    NSString *filesPath = [[backupPath stringByAppendingPathComponent:[[_fullDocumentPath lastPathComponent] stringByDeletingPathExtension]] stringByAppendingPathExtension:@"files"];
    if (![fileManager createDirectoryAtPath:filesPath withIntermediateDirectories:NO attributes:attributes error:NULL] || _needStopExport)
        goto failed;
    if ([[self delegate] respondsToSelector:@selector(webExportProgressDidChange:withProgress:)])
        [_delegate webExportProgressDidChange:self withProgress:100.0 / 6.0];
    NSString *stackPath = [[filesPath stringByAppendingPathComponent:[_fullDocumentPath lastPathComponent]] stringByAppendingPathExtension:@"stack"];
    NSFileWrapper *wrapper = [self fileWrapperForExportFromDocument:aDocument exportError:&error];
    if (wrapper == nil || _needStopExport)
        goto failed;
    id resources = [[[[wrapper fileWrappers] objectForKey:@"Contents"] fileWrappers] objectForKey:@"Resources"];
    [[HSMediaValidator mediaValidatorForDocument:aDocument] validateMedia];
    [HSMediaSaver saveMediaForDocument:aDocument resourcesWrapper:resources];
    if ([[self delegate] respondsToSelector:@selector(webExportProgressDidChange:withProgress:)])
        [_delegate webExportProgressDidChange:self withProgress:100.0 / 6.0];
    NSData *html = [self htmlTemplateWithDocument:aDocument dirPath:stackPath];
    // Rough space check: the page plus the original document, rounded up to a whole block.
    // Fix: the sizes were read as 32-bit values and a volume reporting no free nodes divided by zero.
    NSDictionary *fileSystem = [fileManager attributesOfFileSystemForPath:[stackPath stringByDeletingLastPathComponent] error:NULL];
    unsigned long long freeSize = [[fileSystem objectForKey:NSFileSystemFreeSize] unsignedLongLongValue];
    unsigned long long freeNodes = [[fileSystem objectForKey:NSFileSystemFreeNodes] unsignedLongLongValue];
    unsigned long long blockSize = freeNodes != 0 ? freeSize / freeNodes : 0;
    unsigned long long neededSize = 0;
    if (blockSize != 0) {
        neededSize = [html length];
        if ([aDocument fileURL] != nil)
            neededSize += [[fileManager attributesOfItemAtPath:[[aDocument fileURL] path] error:NULL] fileSize];
        neededSize += blockSize - neededSize % blockSize;
    }
    if (freeSize < neededSize || _needStopExport) {
        if (!_needStopExport)
            error = [HSError fileErrorWithHSCode:0x4e23 filePath:_fullDocumentPath];
        goto failed;
    }
    if (![wrapper writeToFile:stackPath atomically:NO updateFilenames:NO] || _needStopExport)
        goto failed;
    if ([[self delegate] respondsToSelector:@selector(webExportProgressDidChange:withProgress:)])
        [_delegate webExportProgressDidChange:self withProgress:100.0 / 6.0];
    if (![html writeToFile:[backupPath stringByAppendingPathComponent:@"index.html"] atomically:NO] || _needStopExport)
        goto failed;
    if ([[self delegate] respondsToSelector:@selector(webExportProgressDidChange:withProgress:)])
        [_delegate webExportProgressDidChange:self withProgress:100.0 / 6.0];
    if ([fileManager fileExistsAtPath:_fullDocumentPath])
        [fileManager removeItemAtPath:_fullDocumentPath error:NULL];
    if ([fileManager fileExistsAtPath:_fullDocumentPath] || _needStopExport)
        goto failed;
    [fileManager moveItemAtPath:backupPath toPath:_fullDocumentPath error:NULL];
    if ([fileManager fileExistsAtPath:backupPath]) {
        error = [HSError fileErrorWithHSCode:0x200 filePath:_fullDocumentPath];
        goto failed;
    }
    succeeded = YES;
    goto done;

failed:
    if (!_needStopExport) {
        if (error == nil)
            error = [HSError fileErrorWithHSCode:0x502d filePath:[aDocument displayName]];
        if ([_delegate respondsToSelector:@selector(webExportErrorInProgress:error:)])
            [_delegate webExportErrorInProgress:self error:error];
    }
    // Original quirk kept: when the destination is not writable, backupPath is still the destination itself.
    [fileManager removeItemAtPath:backupPath error:NULL];
    [fileManager removeItemAtPath:_fullDocumentPath error:NULL];
done:
    if (aError != NULL && error != nil)
        *aError = error;
end:
    if (!_needStopExport && [[self delegate] respondsToSelector:@selector(webExportProgressDidChange:withProgress:)])
        [_delegate webExportProgressDidChange:self withProgress:100.0];
    if ([[self delegate] respondsToSelector:@selector(shouldEndWebExporter:)])
        [_delegate shouldEndWebExporter:self];
    return succeeded;
}

- (id)fileWrapperForExportFromDocument:(id)aDocument exportError:(id *)aError
{
    return [aDocument fileWrapperOfType:@"HSDocumentType" error:aError];
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (void)dealloc
{
    [_fullDocumentPath release];
    [super dealloc];
}

@end
