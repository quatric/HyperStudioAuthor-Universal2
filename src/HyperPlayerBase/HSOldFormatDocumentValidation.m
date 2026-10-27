#import "HSOldFormatDocumentValidation.h"

// Checks a HyperStudio 4 file by parsing it with the "__Validation" types; the
// parser's values clear _isValid and fill the errors as they go.
@implementation HSOldFormatDocumentValidation

- (BOOL)isOldFileFormatValidForData:(id)aData
{
    if ([aData length] <= 0x80) {
        [_validationErrors setObject:@"" forKey:@"dataSizeError"];
        _isValid = NO;
        return NO;
    }
    [self setParser:[[[HSOldFormatParser alloc] initWithData:aData] autorelease]];
    [[self parser] resultDictionary];
    return _isValid;
}

- (void)setValidationErrors:(id)aErrors
{
    if (_validationErrors != aErrors) {
        [_validationErrors release];
        _validationErrors = [aErrors retain];
    }
}

- (id)validationErrors
{
    return _validationErrors;
}

- (void)setParser:(id)aParser
{
    if (_parser != aParser) {
        [_parser release];
        _parser = [aParser retain];
        [_parser setDelegate:self];
        NSString *path = [[NSBundle bundleForClass:[HSOldFormatDocument class]] pathForResource:@"OldFileFormatStructures" ofType:@"plist"];
        [_parser setTypesTree:[NSMutableDictionary dictionaryWithContentsOfFile:path]];
        [_parser setParsingType:@"__Validation"];
    }
}

- (id)parser
{
    return _parser;
}

- (void)dealloc
{
    [_parser setDelegate:nil];
    [_parser release];
    [_validationErrors release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setValidationErrors:[NSMutableDictionary dictionary]];
        _isValid = YES;
    }
    return self;
}

@end

// Imports a HyperStudio 4 stack into a document: a checking pass, a pass that
// collects the cards, then the pass that recreates the stack's contents.
@implementation HSOldFormatDocument

// One media per distinct image, compared by its PNG data.
- (id)mediaForImage:(id)aImage
{
    NSData *png = [[NSBitmapImageRep imageRepWithData:[aImage TIFFRepresentation]] representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
    if (!png)
        return nil;
    id media = NSMapGet([self pngRepresentationsToMediaMap], png);
    if (!media) {
        media = [HSNewMedia mediaWithData:png name:@"Image" type:@"png"];
        NSMapInsert([self pngRepresentationsToMediaMap], png, media);
    }
    return media;
}

- (id)pngRepresentationsToMediaMap
{
    if (!_pngRepresentationsToMediaMap)
        _pngRepresentationsToMediaMap = NSCreateMapTable(NSObjectMapKeyCallBacks, NSObjectMapValueCallBacks, 0);
    return _pngRepresentationsToMediaMap;
}

- (void)cancelImport
{
    [[self parser] setKernelBreak:YES];
    _isCanceledByUser = YES;
}

- (id)progressDialog
{
    return _progressDialog;
}

- (id)uniqueImportedIndexString
{
    return [NSString stringWithFormat:@"_%u", ++_uniqueImportedIndex];
}

- (id)oldFileFormatStructures
{
    if (!_oldFileFormatStructures) {
        NSString *path = [[NSBundle bundleForClass:[HSOldFormatDocument class]] pathForResource:@"OldFileFormatStructures" ofType:@"plist"];
        _oldFileFormatStructures = [[NSMutableDictionary dictionaryWithContentsOfFile:path] retain];
    }
    return [NSMutableDictionary dictionaryWithDictionary:_oldFileFormatStructures];
}

- (id)firstGroupCards
{
    if (!_firstGroupCards)
        _firstGroupCards = [NSMutableArray new];
    return _firstGroupCards;
}

- (id)cardsById
{
    if (!_cardsById)
        _cardsById = [NSMutableDictionary new];
    return _cardsById;
}

- (id)cards
{
    if (!_cards)
        _cards = [NSMutableArray new];
    return _cards;
}

- (id)keyMappings
{
    if (!_keyMapDictionary) {
        NSString *path = [[NSBundle bundleForClass:[HSOldFormatDocument class]] pathForResource:@"keymapper" ofType:@"plist"];
        _keyMapDictionary = [[NSDictionary dictionaryWithContentsOfFile:path] retain];
    }
    return _keyMapDictionary;
}

- (void)setNbaById:(id)aId
{
    if (_nbaById != aId) {
        [_nbaById release];
        _nbaById = [aId retain];
    }
}

- (id)nbaById
{
    if (!_nbaById) {
        NSString *path = [[NSBundle bundleForClass:[HSOldFormatDocument class]] pathForResource:@"OldFileFormatNbaById" ofType:@"plist"];
        [self setNbaById:[NSMutableDictionary dictionaryWithContentsOfFile:path]];
    }
    return _nbaById;
}

- (void)setOldCursorHotSpot:(id)aSpot
{
    if (_oldCursorHotSpot != aSpot) {
        [_oldCursorHotSpot release];
        _oldCursorHotSpot = [aSpot retain];
    }
}

- (id)oldCursorHotSpot
{
    if (!_oldCursorHotSpot) {
        NSString *path = [[NSBundle bundleForClass:[HSOldFormatDocument class]] pathForResource:@"OFFICursorsHotSpot" ofType:@"plist"];
        [self setOldCursorHotSpot:[NSMutableDictionary dictionaryWithContentsOfFile:path]];
    }
    return _oldCursorHotSpot;
}

- (void)showImportingWarnings
{
    if (_isHyperLogoWarning || _isFontWarning) {
        HSError *warning = [HSError errorWithDomain:HSSpecificErrorDomain code:0x4e26 userInfo:nil];
        id document = [self document];
        if ([document respondsToSelector:@selector(setOpenWarning:)])
            [document performSelector:@selector(setOpenWarning:) withObject:warning];
    }
}

- (void)addImportingWarning:(id)aWarning
{
    [[self importingWarnings] addObject:aWarning];
}

- (void)setImportingWarnings:(id)aWarnings
{
    if (_importingWarnings != aWarnings) {
        [_importingWarnings release];
        _importingWarnings = [aWarnings retain];
    }
}

- (id)importingWarnings
{
    return _importingWarnings;
}

// File names are kept quoted, once each.
- (void)addFilesForWarnings2:(id)aWarnings2
{
    NSString *name = [NSString stringWithFormat:@"\"%@\"", aWarnings2];
    if ([[self filesForWarnings2] indexOfObject:name] == NSNotFound)
        [[self filesForWarnings2] addObject:name];
}

- (void)setFilesForWarnings2:(id)aWarnings2
{
    if (_filesForWarnings2 != aWarnings2) {
        [_filesForWarnings2 release];
        _filesForWarnings2 = [aWarnings2 retain];
    }
}

- (id)filesForWarnings2
{
    return _filesForWarnings2;
}

- (void)addFilesForWarnings1:(id)aWarnings1
{
    NSString *name = [NSString stringWithFormat:@"\"%@\"", aWarnings1];
    if ([[self filesForWarnings1] indexOfObject:name] == NSNotFound)
        [[self filesForWarnings1] addObject:name];
}

- (void)setFilesForWarnings1:(id)aWarnings1
{
    if (_filesForWarnings1 != aWarnings1) {
        [_filesForWarnings1 release];
        _filesForWarnings1 = [aWarnings1 retain];
    }
}

- (id)filesForWarnings1
{
    return _filesForWarnings1;
}

- (BOOL)oldFormatDocument
{
    return YES;
}

- (BOOL)isFontWarning
{
    return _isFontWarning;
}

- (void)setFontWarning:(BOOL)aWarning
{
    _isFontWarning = aWarning;
}

- (BOOL)isHyperLogoWarning
{
    return _isHyperLogoWarning;
}

- (void)setHyperLogoWarning:(BOOL)aWarning
{
    _isHyperLogoWarning = aWarning;
}

- (BOOL)isLegacyPlayerDetected
{
    return _isLegacyPlayerDetected;
}

- (BOOL)isCanceledByUser
{
    return _isCanceledByUser;
}

- (void)setDebugFlag:(BOOL)aFlag
{
    _debugFlag = aFlag;
}

- (BOOL)debugFlag
{
    return _debugFlag;
}

- (void)setDocument:(id)aDocument
{
    if (_document != aDocument) {
        [_document release];
        _document = [aDocument retain];
        [self setStack:[_document stack]];
        [self setFileName:[[_document fileURL] path]];
    }
}

- (id)document
{
    return _document;
}

- (void)setStack:(id)aStack
{
    if (_stack != aStack) {
        [_stack release];
        _stack = [aStack retain];
    }
}

- (id)stack
{
    return _stack;
}

- (void)setFileName:(id)aName
{
    if (_fileName != aName) {
        [_fileName release];
        _fileName = [aName copy];
    }
}

- (id)fileName
{
    return _fileName;
}

- (void)setGraphicsImport:(id)aImport
{
    if (_graphicsImport != aImport) {
        [_graphicsImport release];
        _graphicsImport = [aImport retain];
    }
}

- (id)graphicsImport
{
    return _graphicsImport;
}

- (void)setParser:(id)aParser
{
    if (_parser != aParser) {
        [_parser release];
        _parser = [aParser retain];
    }
}

- (id)parser
{
    return _parser;
}

- (void)setFileContents:(id)aContents
{
    if (_fileContents != aContents) {
        [_fileContents release];
        _fileContents = [aContents retain];
    }
}

- (id)fileContents
{
    return _fileContents;
}

// A new parser over the file contents with the stack's types.
- (void)HSOldFormatDocument_setParserWithPath:(NSString *)aPath delegate:(id)aDelegate parsingType:(NSString *)aType
{
    [self setParser:[[[HSOldFormatParser alloc] initWithData:_fileContents] autorelease]];
    [_parser setPath:aPath];
    [_parser setDelegate:aDelegate];
    [_parser setTypesTree:[self oldFileFormatStructures]];
    [_parser setParsingType:aType];
}

// Outside debugging the stack is first checked for import problems, which
// the user may cancel on. The debug flag skips that and saves the parse
// results next to the file.
- (BOOL)createContents
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [[_document undoManager] disableUndoRegistration];
    NSString *path = [self fileName];
    [self setGraphicsImport:[[HSOldFormatGraphicsImport new] autorelease]];
    BOOL debug = [self debugFlag];
    if (!debug) {
        HSOldFormatImportProblemsChecker *checker = [[HSOldFormatImportProblemsChecker new] autorelease];
        [checker setOldFormatDocument:self];
        [checker setParser:[[[HSOldFormatParser alloc] initWithData:_fileContents] autorelease]];
        HSOldFormatParser *checkerParser = [checker parser];
        [checkerParser setPath:path];
        [checkerParser setDelegate:checker];
        [checkerParser setTypesTree:[self oldFileFormatStructures]];
        [checkerParser setParsingType:@"_Stack"];
        [checkerParser resultDictionary];
        _isLegacyPlayerDetected = [checker isLegacyPlayerDetected];
        if (![_document suppressAlerts] && !_isLegacyPlayerDetected && ![checker shouldImportStack])
            [self cancelImport];
    }
    if (!_isCanceledByUser) {
        [_oldFormatPreViewer release];
        _oldFormatPreViewer = [HSOldFormatPreViewer new];
        [_oldFormatPreViewer setCards:[self cards]];
        [_oldFormatPreViewer setCardsById:[self cardsById]];
        [self HSOldFormatDocument_setParserWithPath:path delegate:_oldFormatPreViewer parsingType:@"_StackForward"];
        [[self parser] resultDictionary];
        [self HSOldFormatDocument_setParserWithPath:path delegate:self parsingType:@"_Stack"];
        if (debug) {
            [[[self parser] resultDictionary] writeToFile:[path stringByAppendingString:@".0.plist"] atomically:YES];
            [[[self parser] valuesBufferForSave] writeToFile:[path stringByAppendingString:@".result.plist"] atomically:YES];
            [self debugStackCreation];
        } else {
            [[self parser] resultDictionary];
        }
    }
    BOOL kernelError = [[self parser] hasKernelError];
    [[_document undoManager] enableUndoRegistration];
    [pool release];
    return !kernelError && !_isCanceledByUser;
}

// Validates the file, then imports it under a progress dialog. A file that
// fails validation with a version is reported as an unsupported version.
- (BOOL)readFromFile:(id)aFile ofType:(id)aType error:(id *)aError
{
    [self setFileName:aFile];
    [self setFileContents:[NSData dataWithContentsOfFile:aFile]];
    [self setDebugFlag:[[NSFileManager defaultManager] fileExistsAtPath:@"/tmp/HSDebug.flag"]];
    HSOldFormatDocumentValidation *validation = [HSOldFormatDocumentValidation new];
    BOOL ok = [validation isOldFileFormatValidForData:_fileContents];
    id version = [[validation validationErrors] objectForKey:@"version"];
    int versionNumber = (!ok && version) ? [version intValue] : 0;
    [validation release];
    if (ok) {
        NSString *title = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"OldFileFormatImportCoverting" value:@"" table:@"ImportLocalizable"];
        _progressDialog = [[HSImportProgressDialog alloc] initWithTitle:title];
        [_progressDialog setImporter:self];
        NSModalSession session = [_progressDialog runModalSession];
        ok = [self createContents];
        [_progressDialog stopModalSession:session];
        [_progressDialog release];
        _progressDialog = nil;
    }
    if (!ok && aError) {
        if (_isCanceledByUser) {
            NSDictionary *info = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:HSUserCancelledImportKey];
            *aError = [HSError errorWithDomain:HSSpecificErrorDomain code:0x2711 userInfo:info];
        } else {
            *aError = [HSError fileErrorWithHSCode:versionNumber ? 0x4e35 : 0x5028 filePath:aFile];
        }
    }
    if (ok)
        [[[self document] stack] cleanupUserInfo];
    return ok;
}

// Parsing fills the second half of the progress, by offset up to the blobs.
- (void)oldFormatParser:(id)aParser progressForParseOperationDidChange:(double)aChange
{
    [_progressDialog setValue:aChange * 0.5 / (double)_offsetToBlobs + 0.5];
}

- (void)oldFormatParserFinishParseOperation
{
    [_progressDialog finishCurrentOperation];
}

- (void)oldFormatParser:(id)aParser startParseOperationMinValue:(double)aValue maxValue:(double)aValue2
{
    NSString *name = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"OldFileFormatImportCreateItemsTask" value:@"" table:@"ImportLocalizable"];
    [_progressDialog startOperationName:name minValue:aValue maxValue:aValue2];
}

- (void)dealloc
{
    [_fileContents release];
    [_parser setDelegate:nil];
    [_parser release];
    [_graphicsImport release];
    [_importingWarnings release];
    [_filesForWarnings1 release];
    [_filesForWarnings2 release];
    [_document release];
    [_fileName release];
    [_stack release];
    [_error release];
    [_oldCursorHotSpot release];
    [_nbaById release];
    [_cards release];
    [_cardsById release];
    [_firstGroupCards release];
    [_oldFormatPreViewer release];
    [_oldFileFormatStructures release];
    [_keyMapDictionary release];
    if (_pngRepresentationsToMediaMap) {
        NSFreeMapTable(_pngRepresentationsToMediaMap);
        _pngRepresentationsToMediaMap = nil;
    }
    [_transitionsProcessedAsFromMac release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setImportingWarnings:[NSMutableArray array]];
        [self setFilesForWarnings1:[NSMutableArray array]];
        [self setFilesForWarnings2:[NSMutableArray array]];
        _isHyperLogoWarning = NO;
        _isFontWarning = NO;
        _isCanceledByUser = NO;
        _isAlertForMissingExternalsDisplayed = NO;
        _presMode = 0x7fffffff;
        _isPresModeSet = NO;
    }
    return self;
}

@end
