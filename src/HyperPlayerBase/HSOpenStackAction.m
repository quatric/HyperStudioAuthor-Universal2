#import "HSOpenStackAction.h"
#import "HSActionExecutionContext.h"
#import "HSAlert.h"
#import "HSApplicationController.h"
#import "HSExecutableResourceProvider.h"
#import "HSHomeStackController.h"
#import "HSNavigationController.h"
#import "HSNavigationOperation.h"
#import "HSTemporaryFilesManager.h"

// Goes to another stack. A stack that is not a file URL is downloaded to a
// temporary file first; a missing stack lets the user locate it, and the
// action keeps the new location.
@implementation HSOpenStackAction

- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return YES;
}

- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    if (![self isValid])
        return nil;
    NSURL *URL = [self URL];
    NSString *name = [aContext nameForLinkedStackURL:URL];
    if ([name length] != 0) {
        NSMutableDictionary *dictionary = [super HTML5DictionaryRepresentationInContext:aContext];
        [dictionary setObject:[NSString stringWithFormat:@"%@/stack.json", name] forKey:@"goto"];
        return dictionary;
    }
    if ([aContext shouldAddLinkedStacks]) {
        NSMutableDictionary *dictionary = [super HTML5DictionaryRepresentationInContext:aContext];
        [aContext addLinkedStackURL:URL];
        [dictionary setObject:[NSString stringWithFormat:@"%@/stack.json", [aContext nameForLinkedStackURL:URL]] forKey:@"goto"];
        return dictionary;
    }
    return nil;
}

- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    [super importFromXMLElementRepresentation:aRepresentation inContext:aContext];
    NSString *string = [[[aRepresentation elementsForName:@"stackURL"] extraFirstObject] stringValue];
    if (string == nil)
        return;
    NSURL *URL = [NSURL URLWithString:string];
    if (URL != nil && [URL isFileURL])
        [self setURL:URL];
}

- (id)XMLElementRepresentationInContext:(id)aContext
{
    NSXMLElement *element = [super XMLElementRepresentationInContext:aContext];
    [element addChild:[NSXMLElement elementWithName:@"stackURL" stringValue:[[self URL] absoluteString]]];
    return element;
}

- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}

- (id)XMLElementName
{
    return @"actAnotherStack";
}

- (BOOL)supportedInIPad
{
    return YES;
}

- (void)cleanupDownloadedFile
{
    if (_downloadFilePath == nil)
        return;
    [_temporaryURL release];
    _temporaryURL = nil;
    [HSTemporaryFilesManager unregisterTempFileAtPath:_downloadFilePath];
    [_downloadFilePath release];
    _downloadFilePath = nil;
}

// Stage 11 ends the navigation, so the download progress goes away.
- (void)navigationOperationStageDidChange:(id)aChange
{
    [super navigationOperationStageDidChange:aChange];
    if ([[aChange object] stage] == 11)
        [[[[self document] playerView] queryHyperInterface:@protocol(HSWebPlayerURLLoading)] hideProgress];
}

// A data size of -1 means the length is unknown, so there is no progress.
- (void)download:(id)aDownload didReceiveDataOfLength:(NSUInteger)aLength
{
    if (_dowloadFileDataSize == -1)
        return;
    _currentDowloadedFileSize += aLength;
    [[[[self document] playerView] queryHyperInterface:@protocol(HSWebPlayerURLLoading)] updateProgressWithDownloadedBytes:_currentDowloadedFileSize overallBytes:_dowloadFileDataSize];
}

- (void)download:(id)aDownload didReceiveResponse:(id)aResponse
{
    if (_dowloadFileDataSize != 0)
        return;
    long long length = [aResponse expectedContentLength];
    if (length == 0) {
        _dowloadFileDataSize = -1;
        return;
    }
    _dowloadFileDataSize = length;
    [[[[self document] playerView] queryHyperInterface:@protocol(HSWebPlayerURLLoading)] updateProgressWithDownloadedBytes:_currentDowloadedFileSize overallBytes:_dowloadFileDataSize];
}

- (BOOL)download:(id)aDownload shouldDecodeSourceDataOfMIMEType:(id)aType
{
    return NO;
}

- (void)download:(id)aDownload didFailWithError:(id)aError
{
    [self performSelectorOnMainThread:@selector(cleanupDownloadedFile) withObject:nil waitUntilDone:NO];
    _isDownloadFinished = YES;
}

- (void)downloadDidFinish:(id)aFinish
{
    [_temporaryURL release];
    _temporaryURL = [[NSURL alloc] initFileURLWithPath:_downloadFilePath];
    _isDownloadFinished = YES;
}

- (void)downloadDidBegin:(id)aBegin
{
    _dowloadFileDataSize = 0;
    _currentDowloadedFileSize = 0;
    [[[[self document] playerView] queryHyperInterface:@protocol(HSWebPlayerURLLoading)] showProgress];
}

// Downloads synchronously, spinning the run loop until the download ends.
- (void)downloadFile:(id)aFile
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:aFile];
    if (request != nil) {
        NSURLDownload *download = [[NSURLDownload alloc] initWithRequest:request delegate:(id)self];
        [request release];
        if (download != nil) {
            _downloadFilePath = [[HSTemporaryFilesManager generatedTempFilePathWithExtension:@"stack"] retain];
            if (_downloadFilePath == nil) {
                [download cancel];
            } else {
                [HSTemporaryFilesManager registerTempFileAtPath:_downloadFilePath];
                [download setDestination:_downloadFilePath allowOverwrite:YES];
                while (!_isDownloadFinished) {
                    NSAutoreleasePool *loopPool = [[NSAutoreleasePool alloc] init];
                    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
                    [loopPool release];
                }
            }
            [download release];   // the original leaked the download
        }
    }
    [pool release];
}

- (BOOL)isAbleToStartInInvalidState
{
    return YES;
}

// A remote stack is valid when the server names the same file and knows its
// length.
- (BOOL)isValid
{
    NSURL *URL = [self URL];
    if ([URL isFileURL])
        return [[NSFileManager defaultManager] fileExistsAtPath:[URL path]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    if (![NSURLConnection canHandleRequest:request])
        return NO;
    NSURLResponse *response = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
    if (![[URL lastPathComponent] isEqualToString:[response suggestedFilename]])
        return NO;
    return [response expectedContentLength] > 0;
}

- (void)openStackFromNewLocationWithContext:(id)aContext
{
    [super startInContext:aContext];
}

// The new location also goes to the action of the same type on the same
// object, which is the one that runs.
- (void)openPanelDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    if (aCode != NSModalResponseOK) {
        [self notifyDidFinish];
        return;
    }
    [[self undoManager] disableUndoRegistration];
    [self setURL:[[aEnd URLs] extraFirstObject]];
    [[self undoManager] enableUndoRegistration];
    id actor = [[[[self owner] hyperObjectForAction:self] hyperObject] queryHyperInterface:@protocol(HSActor)];
    id action = [actor hyperActionOfType:[[self class] actionType] forEvent:[[self events] objectAtIndex:0]];
    [action setURL:[self URL]];
    [self performSelector:@selector(openStackFromNewLocationWithContext:) withObject:(id)aInfo afterDelay:0];
}

- (void)alertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    if (aCode == NSAlertFirstButtonReturn)
        [self askUserToLocateTheStackInContext:(id)aInfo];
    else
        [self notifyDidFinish];
}

- (void)validateURL
{
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
}

- (void)setURL:(id)aURL
{
    if ([_URL isEqual:aURL])
        return;
    [[[self undoManager] prepareWithInvocationTarget:self] setURL:[self URL]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSURLAttribute) ofObject:self withUserInfo:nil];
    [_URL release];
    _URL = [aURL retain];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSURLAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
}

// The stored URL when it exists, then the downloaded copy, then a search
// relative to this stack.
- (id)URL
{
    if (_URL == nil)
        return nil;
    if ([_URL isFileURL] && [[NSFileManager defaultManager] fileExistsAtPath:[_URL path]])
        return _URL;
    if (_temporaryURL != nil && [_temporaryURL isFileURL] && [[NSFileManager defaultManager] fileExistsAtPath:[_temporaryURL path]])
        return _temporaryURL;
    return [HSNavigationController findURLUsingActionURL:_URL baseURL:[self baseURL]];
}

- (id)baseURL
{
    id document = [self document];
    NSURL *URL;
    if ([document isWebPlayerDocument])
        URL = [[[document playerView] queryHyperInterface:@protocol(HSWebPlayerURLLoading)] stackURL];
    else
        URL = [document fileURL];
    return [URL URLByDeletingLastPathComponent];
}

// A converted HyperStudio 4 stack (.stk) is replaced by its .stack next to it.
- (void)notifyDidFinish
{
    [self cleanupDownloadedFile];
    [super notifyDidFinish];
}

- (void)startInContext:(id)aContext
{
    if (![self canBeStopped])
        return;
    [self updateURL];
    NSURL *URL = [self URL];
    if (![URL isFileURL]) {
        [self downloadFile:URL];
        URL = [self URL];
    }
    if (URL != nil && !([URL isFileURL] && [[NSFileManager defaultManager] fileExistsAtPath:[URL path]])) {
        [aContext displayAlert:[self stackNotFoundAlert] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:aContext];
        return;
    }
    [[[aContext navigationController] presentationSync] prepareForUserInitiatedNavigationOperation];
    [super startInContext:aContext];
}

- (BOOL)supportedInStackToGo
{
    return ![self hasLinkToOFFStack];
}

- (BOOL)supportedInWebPlayer
{
    return ![self hasLinkToOFFStack];
}

// True for a link to a HyperStudio file (native, or an old 'Stak'/.stk one),
// or to a file of unknown type.
- (BOOL)hasLinkToOFFStack
{
    if ([self URL] == nil)
        return NO;
    NSString *type = [[NSFileManager defaultManager] hyperFileTypeAtPath:[[self URL] path]];
    if (type == nil)
        type = [[[[self URL] path] pathExtension] lowercaseString];
    return type == nil || [type isEqualToString:@"HSNativeDocumentType"] || [type isEqualToString:@"'Stak'"] || [type isEqualToString:@"stk"];
}

- (void)askUserToLocateTheStackInContext:(id)aContext
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:NO];
    NSArray *types;
    if ([[HSApplicationController sharedDocumentController] respondsToSelector:@selector(readableFileExtensions)])
        types = [[HSApplicationController sharedDocumentController] readableFileExtensions];
    else
        types = [NSArray arrayWithObjects:@"stack", nil];
    [aContext showOpenPanel:panel sheetForDirectory:nil file:nil types:types modalDelegate:self didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:) contextInfo:aContext];
}

- (id)stackNotFoundAlert
{
    if (_stackNotFoundAlert == nil) {
        HSExecutableResourceProvider *resources = [HSExecutableResourceProvider sharedInstance];
        _stackNotFoundAlert = [HSAlert new];
        [_stackNotFoundAlert setMessageText:[NSString stringWithFormat:[resources localizedStringForKey:@"OtherStackMissingAlertMessage" value:@"" table:@"Alerts"], [[[self URL] path] lastPathComponent]]];
        [_stackNotFoundAlert setInformativeText:[resources localizedStringForKey:@"OtherStackMissingAlertInformativeText" value:@"" table:@"Alerts"]];
        [_stackNotFoundAlert addButtonWithTitle:[resources localizedStringForKey:@"OtherStackMissingAlertFirstButtonTitle" value:@"" table:@"Alerts"]];
        [_stackNotFoundAlert addButtonWithTitle:[resources localizedStringForKey:@"OtherStackMissingAlertSecondButtonTitle" value:@"" table:@"Alerts"]];
        [_stackNotFoundAlert setAlertStyle:5];
    }
    return _stackNotFoundAlert;
}

// Returns +1. The home stack opens at its default card.
- (id)createNavigationOperation
{
    NSURL *URL = [self URL];
    NSUInteger cardIndex = 0;
    if (![[self document] isWebPlayerDocument]) {
        HSHomeStackController *controller = [HSHomeStackController sharedHomeStackController];
        if ([[controller homeStackURL] isEqual:URL])
            cardIndex = [controller defaultCardIndex];
    }
    HSNavigationOperation *operation = [[HSNavigationOperation alloc] initWithDestinationStackURL:URL destinationCardIndex:cardIndex transition:[self transition]];
    [operation setShouldReopenDocumentIfSoureIsDestination:YES];
    return operation;
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObjectsFromArray:[NSArray arrayWithObject:[@"URL" extraKeyForMultiRepresentations]]];
}

- (void)dealloc
{
    [_URL release];
    [_temporaryURL release];
    [_downloadFilePath release];
    [_stackNotFoundAlert release];
    [super dealloc];
}

- (void)setShouldOpenInSeparateWindow:(BOOL)aOpen
{
    if (aOpen != _shouldOpenInSeparateWindow) {
        [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Open in Separate Window" value:@"" table:@"UndoManager"]];
        [[[self undoManager] prepareWithInvocationTarget:self] setShouldOpenInSeparateWindow:_shouldOpenInSeparateWindow];
        id center = [self attributeNotificationCenter];
        [center notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
        [center notifyChange:1 ofAttribute:@protocol(HSOtherStackOpenInSeparateWindowAttribute) ofObject:self withUserInfo:nil];
        _shouldOpenInSeparateWindow = aOpen != NO;
        [center notifyChange:2 ofAttribute:@protocol(HSOtherStackOpenInSeparateWindowAttribute) ofObject:self withUserInfo:nil];
        [center notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    }
}

- (BOOL)shouldOpenInSeparateWindow
{
    return _shouldOpenInSeparateWindow;
}

- (id)initialURL
{
    return _URL;
}

@end
