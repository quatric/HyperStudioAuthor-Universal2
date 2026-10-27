#import "HSOtherCardAction.h"
#import "HSActionExecutionContext.h"
#import "HSAlert.h"
#import "HSApplicationController.h"
#import "HSDocumentStoring.h"
#import "HSExecutableResourceProvider.h"
#import "HSNavigationController.h"
#import "HSNavigationOperation.h"
#import "HSTemporaryFilesManager.h"

// No old-format card id (NSNotFound on i386, where the ivar was declared).
#define HSOtherCardNoOldFormatCardId 0x7fffffff

// Goes to a card of this or another stack, by UID (or by the card id of an
// old-format document). A stack that is not a file URL is downloaded first;
// a missing stack lets the user locate it.
@implementation HSOtherCardAction

- (id)unrefreshingUIDs
{
    return _destinationCardUID != nil ? [NSSet setWithObject:_destinationCardUID] : [NSSet set];
}

// Older documents stored the card id under "_cardIdOldFileFormat".
- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext
{
    NSMutableDictionary *representation = [aRepresentation mutableCopy];
    id cardId = [[representation valueForKey:@"_cardIdOldFileFormat"] retain];
    if (cardId != nil) {
        [representation removeObjectForKey:@"_cardIdOldFileFormat"];
        [representation setObject:cardId forKey:@"cardIdOldFileFormat"];
        [cardId release];
    }
    [super loadExtraDictionaryRepresentation:representation withCodingContext:aContext];
    [representation release];
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

// Runs on its own thread, spinning that thread's run loop until the download
// ends.
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

- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    [super importFromXMLElementRepresentation:aRepresentation inContext:aContext];
    [self setDestinationCardUID:[HSUID UIDWithString:[[aRepresentation attributeForName:@"destinationCardId"] stringValue]]];
    NSString *string = [[[aRepresentation elementsForName:@"stackURL"] extraFirstObject] stringValue];
    if (string == nil)
        return;
    NSURL *URL = [NSURL URLWithString:string];
    if (URL != nil && [URL isFileURL])
        [self setURL:URL];
}

- (id)XMLElementRepresentationInContext:(id)aContext
{
    id element = [super XMLElementRepresentationInContext:aContext];
    [element addAttribute:[NSXMLNode attributeWithName:@"destinationCardId" stringValue:[[self destinationCardUID] stringValue]]];
    NSURL *URL = [self URL];
    if (URL != nil && [URL isFileURL])
        [element addChild:[NSXMLElement elementWithName:@"stackURL" stringValue:[URL absoluteString]]];
    return element;
}

- (id)XMLElementName
{
    return @"actOtherCard";
}

- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}

- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return YES;
}

// A card of another stack exports that stack too (when the context adds
// linked stacks).
- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    if (![self isValid])
        return nil;
    id stack = [self destinationStackForContext:aContext];
    if (stack == nil)
        return nil;
    id card = [stack childWithUID:_destinationCardUID];
    NSUInteger cardIndex = card != nil ? [stack indexOfHyperChild:card] : 0;
    NSURL *URL = [self URL];
    if (URL == nil)
        URL = [[stack document] fileURL];
    NSString *name = [aContext nameForLinkedStackURL:URL];
    id dictionary;
    if ([name length] != 0) {
        dictionary = [super HTML5DictionaryRepresentationInContext:aContext];
        [dictionary setObject:[NSString stringWithFormat:@"%@/stack.json", name] forKey:@"destinationStack"];
    } else if (URL != nil && ![URL isEqual:[[aContext document] fileURL]]) {
        if (![aContext shouldAddLinkedStacks])
            return nil;
        dictionary = [super HTML5DictionaryRepresentationInContext:aContext];
        [aContext addLinkedStackURL:URL];
        [dictionary setObject:[NSString stringWithFormat:@"%@/stack.json", [aContext nameForLinkedStackURL:URL]] forKey:@"destinationStack"];
    } else {
        dictionary = [super HTML5DictionaryRepresentationInContext:aContext];
    }
    [dictionary setObject:[NSString stringWithFormat:@"%u", (unsigned int)cardIndex] forKey:@"goto"];
    [dictionary setObject:@"HSGoToSpecificCardAction" forKey:@"type"];
    return dictionary;
}

// This stack, or the other stack read without alerts (cancelling it ends
// the export).
- (id)destinationStackForContext:(id)aContext
{
    id document = [aContext document];
    NSURL *documentURL = [document fileURL];
    NSURL *URL = [self URL];
    if (URL == nil || [URL isEqual:documentURL])
        return [document stack];
    HSDocumentStoring *storing = [HSDocumentStoring new];
    [storing setSuppressAlerts:YES];
    NSString *fileType = [[NSFileManager defaultManager] hyperFileTypeAtPath:[URL path]];
    NSString *type = [fileType isEqualToString:@"'Stak'"] || [fileType isEqualToString:@"stk"] ? @"HSNativeDocumentType" : @"HSDocumentType";
    if (![storing readFromURL:URL ofType:type error:NULL] && [storing isCanceledByUser])
        [aContext setShouldTerminateExport:YES];
    id stack = [[storing stack] retain];
    [storing release];
    return [stack autorelease];
}

// A card of this stack, or a reachable other stack (a remote one when the
// server names the same file and knows its length).
- (BOOL)isValid
{
    if ([self destinationCardUID] == nil && _cardIdOldFileFormat == HSOtherCardNoOldFormatCardId)
        return NO;
    NSURL *URL = [self URL];
    if (URL == nil && [self canGoToHyperDestinationCard])
        return YES;
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

- (void)notifyDidFinish
{
    [self cleanupDownloadedFile];
    [super notifyDidFinish];
}

// A remote stack is downloaded on another thread while this one waits.
- (void)startInContext:(id)aContext
{
    if (![self canBeStopped])
        return;
    NSURL *URL = [self URL];
    if (URL != nil && ![URL isFileURL]) {
        _isDownloadFinished = NO;
        [NSThread detachNewThreadSelector:@selector(downloadFile:) toTarget:self withObject:URL];
        while (!*(volatile BOOL *)&_isDownloadFinished)
            usleep(200000);
        URL = [self URL];
    }
    if (URL != nil && !([URL isFileURL] && [[NSFileManager defaultManager] fileExistsAtPath:[URL path]])) {
        [aContext displayAlert:[self stackNotFoundAlert] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:aContext];
        return;
    }
    URL = [self URL];
    if (URL != nil && ![URL isEqual:[[aContext document] fileURL]])
        [[[aContext navigationController] presentationSync] prepareForUserInitiatedNavigationOperation];
    [super startInContext:aContext];
}

// Only from this action's own stack.
- (BOOL)canRunInContext:(id)aContext
{
    if (![super canRunInContext:aContext])
        return NO;
    return [[aContext document] stack] == [self stack];
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

- (BOOL)supportedInStackToGo
{
    return ![self hasLinkToOFFStack];
}

- (BOOL)supportedInWebPlayer
{
    return ![self hasLinkToOFFStack];
}

// A card of another stack given by an old-format card id.
- (BOOL)hasLinkToOFFStack
{
    return [self URL] != nil && _cardIdOldFileFormat != 0 && _cardIdOldFileFormat != HSOtherCardNoOldFormatCardId;
}

// Returns +1: by card UID (in this stack or another .stack file), else by
// old-format card id, else nil.
- (id)createNavigationOperation
{
    NSURL *URL = [self URL];
    if ([self destinationCardUID] != nil && (URL == nil || [[[URL path] pathExtension] isEqualToString:@"stack"]))
        return [[HSNavigationOperation alloc] initWithDestinationStackURL:URL destinationCardUID:[self destinationCardUID] transition:[self transition]];
    if (_cardIdOldFileFormat == 0 || _cardIdOldFileFormat == HSOtherCardNoOldFormatCardId)
        return nil;
    return [[HSNavigationOperation alloc] initWithDestinationStackURL:URL destinationCardIdOldFileFormat:[self cardIdOldFileFormat] transition:[self transition]];
}

- (void)setDestinationCardUID:(id)aUID
{
    if ([_destinationCardUID isEqual:aUID])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Destination Card" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setDestinationCardUID:[self destinationCardUID]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSDestinationCardUIDAttribute) ofObject:self withUserInfo:nil];
    [_destinationCardUID release];
    _destinationCardUID = [aUID retain];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSDestinationCardUIDAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
}

- (id)destinationCardUID
{
    return _destinationCardUID;
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
- (void)setCardIdOldFileFormat:(NSInteger)aFormat
{
    _cardIdOldFileFormat = (int)aFormat;
}

- (NSInteger)cardIdOldFileFormat
{
    return _cardIdOldFileFormat;
}

- (BOOL)canGoToHyperDestinationCard
{
    if ([[[self document] stack] childWithUID:_destinationCardUID] != nil)
        return YES;
    return [self URL] != nil;
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:@"destinationCardUID", @"URL", @"cardIdOldFileFormat", nil]];
}

- (void)dealloc
{
    [_destinationCardUID release];
    [_temporaryURL release];
    [_URL release];
    // Fixed: the download path and the alert were leaked.
    [_downloadFilePath release];
    [_stackNotFoundAlert release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil)
        _cardIdOldFileFormat = HSOtherCardNoOldFormatCardId;
    return self;
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

@end
