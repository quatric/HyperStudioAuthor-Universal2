#import "HSDocument.h"

/* The localized alert strings HSDocument uses all live in the "Alerts" table. */
static NSString *HSDocumentAlertString(NSString *aKey)
{
    return [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:aKey value:@"" table:@"Alerts"];
}

/* Looks up a key in the HSDocumentType entry of CFBundleDocumentTypes. */
static id HSDocumentTypeInfoValue(NSString *aKey)
{
    NSEnumerator *types = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDocumentTypes"] objectEnumerator];
    NSDictionary *type;
    while ((type = [types nextObject]) != nil) {
        if ([[type objectForKey:@"CFBundleTypeName"] isEqual:@"HSDocumentType"])
            return [type objectForKey:aKey];
    }
    return nil;
}

static NSString *sMaxDocumentCompatibilityVersion;
static NSString *sMinDocumentVersion;
static NSString *sCurrentDocumentVersion;
static NSString *sCurrentDocumentCompatibilityVersion;
static NSString *sPlatformInformation;

@implementation HSDocument

+ (void)openURL:(id)aURL versionString:(id)aString addPlatformInfo:(BOOL)aInfo addProductName:(BOOL)aName
{
    NSString *string = [self completeURLStringWithString:aURL versionString:aString addPlatformInfo:aInfo addProductName:aName];
    if (string == nil)
        return;
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSURL *url = [NSURL URLWithString:string];
    if (![[NSWorkspace sharedWorkspace] openURL:url]) {
        NSString *ok = HSDocumentAlertString(@"OK");
        NSString *message = HSDocumentAlertString(@"BrowserNotFound_message");
        NSString *title = HSDocumentAlertString(@"BrowserNotFound_title");
        NSRunAlertPanel(title, @"%@", ok, nil, nil, message);
    }
    [pool release];
}

+ (id)completeURLStringWithString:(id)aString versionString:(id)aString2 addPlatformInfo:(BOOL)aInfo addProductName:(BOOL)aName
{
    if (aString == nil)
        return nil;
    NSString *result = aString;
    BOOL noQuery = [aString2 length] == 0;
    if (!noQuery)
        result = [NSString stringWithFormat:@"%@?ver=%@", result, aString2];
    if (aInfo) {
        NSString *platform = [self platformInformation];
        if (platform != nil) {
            NSString *string = [NSString stringWithFormat:noQuery ? @"%@?mac=%@" : @"%@&mac=%@", result, platform];
            if (string != nil) {
                noQuery = NO;
                result = string;
            }
        }
    }
    if (aName) {
        id controller = [NSDocumentController sharedDocumentController];
        if ([controller respondsToSelector:@selector(productName)]) {
            NSString *product = [controller productName];
            if (product != nil) {
                NSString *string = [NSString stringWithFormat:noQuery ? @"%@?prod=%@" : @"%@&prod=%@", result, product];
                if (string != nil)
                    result = string;
            }
        }
    }
    return [result stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (id)platformInformation
{
    // The original asked Gestalt('sysa') and answered "intel" for an x86
    // machine, "ppc" otherwise. Apple silicon hosts answer "intel" as well so
    // the update server keeps recognizing the Mac build.
    if (sPlatformInformation == nil) {
#if defined(__ppc__) || defined(__ppc64__)
        sPlatformInformation = @"ppc";
#else
        sPlatformInformation = @"intel";
#endif
    }
    return sPlatformInformation;
}

+ (id)currentDocumentCompatibilityVersion
{
    if (sCurrentDocumentCompatibilityVersion == nil) {
        sCurrentDocumentCompatibilityVersion = @"";
        id value = HSDocumentTypeInfoValue(@"HSDocumentCompatibilityVersion");
        if (value != nil)
            sCurrentDocumentCompatibilityVersion = value;
    }
    return sCurrentDocumentCompatibilityVersion;
}

+ (id)currentDocumentVersion
{
    if (sCurrentDocumentVersion == nil) {
        sCurrentDocumentVersion = @"";
        id value = HSDocumentTypeInfoValue(@"HSDocumentVersion");
        if (value != nil)
            sCurrentDocumentVersion = value;
    }
    return sCurrentDocumentVersion;
}

+ (id)minDocumentVersion
{
    if (sMinDocumentVersion == nil) {
        sMinDocumentVersion = @"";
        id value = HSDocumentTypeInfoValue(@"HSMinDocumentVersion");
        if (value != nil)
            sMinDocumentVersion = value;
    }
    return sMinDocumentVersion;
}

+ (id)maxDocumentCompatibilityVersion
{
    if (sMaxDocumentCompatibilityVersion == nil) {
        sMaxDocumentCompatibilityVersion = @"";
        id value = HSDocumentTypeInfoValue(@"HSMaxDocumentCompatibilityVersion");
        if (value != nil)
            sMaxDocumentCompatibilityVersion = value;
    }
    return sMaxDocumentCompatibilityVersion;
}

- (void)openUpdaterLinkAndQuit
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.hyperstudio.com/updates"]];
    [NSApp terminate:self];
}

- (id)defaultSavePanelAccessoryViewController
{
    if (_defaultSavePanelAccessoryViewController == nil) {
        id controller = [NSDocumentController sharedDocumentController];
        if ([controller respondsToSelector:@selector(isStackToGoController)] && ![controller isStackToGoController])
            _defaultSavePanelAccessoryViewController = [HSDefaultSavePanelAccessoryViewController new];
    }
    return _defaultSavePanelAccessoryViewController;
}

- (void)awakeFromImporting
{
    NSEnumerator *controllers = [[self windowControllers] objectEnumerator];
    id controller;
    while ((controller = [controllers nextObject]) != nil) {
        if ([controller respondsToSelector:@selector(awakeFromImporting)])
            [controller awakeFromImporting];
    }
}

- (void)cleanTemporaryFileAtPath:(id)aPath
{
    if (aPath == nil)
        return;
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([aPath hasPrefix:[[HSPathsProvider sharedPathsProvider] temporaryFolder]] && [manager isDeletableFileAtPath:aPath])
        [manager removeItemAtPath:aPath error:NULL];
}

- (void)printOperationDidRun:(id)aRun success:(BOOL)aSuccess contextInfo:(void *)aInfo
{
    // The context is the off-screen window that hosted the printing view.
    [(id)aInfo release];
    [self autorelease];
}

- (NSSize)documentSize
{
    NSPrintInfo *printInfo = [self printInfo];
    if ([printInfo respondsToSelector:@selector(imageablePageBounds)])
        return [printInfo imageablePageBounds].size;
    NSSize paper = [printInfo paperSize];
    return NSMakeSize(paper.width - ([printInfo leftMargin] + [printInfo rightMargin]),
                      paper.height - ([printInfo topMargin] + [printInfo bottomMargin]));
}

- (void)setAttributes:(id)aAttributes
{
    if (_attributes != aAttributes) {
        [_attributes release];
        _attributes = [aAttributes retain];
    }
}

- (void)setResourcesWrapper:(id)aWrapper
{
    if (_resourcesWrapper != aWrapper) {
        [_resourcesWrapper release];
        _resourcesWrapper = [aWrapper retain];
        [self reloadDocumentMedia];
    }
}

- (void)reloadDocumentMedia
{
    if (_resourcesWrapper == nil)
        return;
    NSString *path = [[[self fileNameSource] stringByAppendingPathComponent:@"Contents"] stringByAppendingPathComponent:@"Resources"];
    NSArray *media = [HSMediaLoader loadResourcesWrapper:_resourcesWrapper resourcesFolderPath:path loadUIDs:YES filenamesMapping:[self filenamesMapping]];
    [_documentMedia release];
    _documentMedia = [media retain];
}

- (void)clearCaches
{
}

- (id)filenamesMapping
{
    return nil;
}

- (void)hyperDocumentDidRemoveFromDocumentController:(id)aController
{
    [self cleanupResources];
}

- (void)cleanupResources
{
    [self destoryModelIfNeeded];
    [_resourcesWrapper release];
    _resourcesWrapper = nil;
    [self cleanTemporaryFileAtPath:_fileNameSource];
    [_fileNameSource release];
    _fileNameSource = nil;
    [self cleanTemporaryFileAtPath:_imageCachePath];
    [_imageCachePath release];
    _imageCachePath = nil;
    [_documentMedia release];
    _documentMedia = nil;
    [self invalidatePreviewImages];
}

- (void)hyperDocumentWillRemoveFromDocumentController:(id)aController
{
    if ([[self navigationController] currentNavigationOperation] == nil)
        [[HSActionMediaPlayer sharedActionMediaPlayer] stopAllSounds];
}

- (void)setSuppressAlerts:(BOOL)aAlerts
{
    if (_suppressAlerts != aAlerts)
        _suppressAlerts = aAlerts;
}

- (BOOL)suppressAlerts
{
    return _suppressAlerts;
}

- (id)actionExecutionManager
{
    if (_actionExecutionManager == nil)
        _actionExecutionManager = [HSActionExecutionManager new];
    return _actionExecutionManager;
}

- (id)actionExecutionContext
{
    if (_actionExecutionContext == nil)
        _actionExecutionContext = [self newActionExecutionContext];
    return _actionExecutionContext;
}

- (id)newActionExecutionContext
{
    return [(HSActionExecutionContext *)[HSActionExecutionContext alloc] initWithDocument:self];
}

- (void)goToSpecificCardController:(id)aController goToCardAtIndex:(NSUInteger)aIndex context:(void *)aContext
{
    if (aIndex == NSNotFound)
        return;
    // The context is the retained NSNumber holding the leave-actions state
    // the dialog was opened with.
    HSActionExecutionManager *manager = [self actionExecutionManager];
    BOOL disabled = [manager isLeaveActionsDisabled];
    [[self actionExecutionManager] setLeaveActionsDisabled:[(id)aContext boolValue]];
    [[self navigationController] goToCardAtIndex:aIndex allowGoToCurrent:YES];
    [[self actionExecutionManager] setLeaveActionsDisabled:disabled];
    [(id)aContext release];
}

- (void)goToHomeWithoutLeaveActions:(id)aActions
{
    [self performNavigationWithoutLeaveActions:@selector(goToHome:) sender:aActions];
}

- (void)goToHome:(id)aHome
{
    [[self navigationController] performSelector:_cmd withObject:aHome];
}

- (void)goToSpecificCardWithoutLeaveActions:(id)aActions
{
    [[self actionExecutionManager] setLeaveActionsDisabled:YES];
    [self goToSpecificCard:aActions];
    [[self actionExecutionManager] setLeaveActionsDisabled:NO];
}

- (void)goToSpecificCard:(id)aCard
{
    NSUInteger count = [[self stack] hyperCount];
    NSUInteger index = [[[self cardViewForNavigation] card] hyperIndex];
    NSNumber *context = [[NSNumber alloc] initWithBool:[[self actionExecutionManager] isLeaveActionsDisabled]];
    if (_goToCardController == nil) {
        _goToCardController = [[HSGoToSpecificCardController allocWithZone:[self zone]] initWithDelegate:self cardCount:count cardIndex:index context:context];
    } else {
        [_goToCardController setContext:context];
        [_goToCardController setCardCount:count];
        [_goToCardController setCardIndex:index];
    }
    [_goToCardController runModalForWindow:[self windowForSheet]];
}

- (void)advanceToNextCardWithoutLeaveActions:(id)aActions
{
    [self performNavigationWithoutLeaveActions:@selector(advanceToNextCard:) sender:aActions];
}

- (void)goToFirstCardWithoutLeaveActions:(id)aActions
{
    [self performNavigationWithoutLeaveActions:@selector(goToFirstCard:) sender:aActions];
}

- (void)goToFirstCard:(id)aCard
{
    [[self navigationController] performSelector:_cmd withObject:aCard];
}

- (void)goToLastCardWithoutLeaveActions:(id)aActions
{
    [self performNavigationWithoutLeaveActions:@selector(goToLastCard:) sender:aActions];
}

- (void)goToLastCard:(id)aCard
{
    [[self navigationController] performSelector:_cmd withObject:aCard];
}

- (void)goToPreviousCardWithoutLeaveActions:(id)aActions
{
    [self performNavigationWithoutLeaveActions:@selector(goToPreviousCard:) sender:aActions];
}

- (void)goToPreviousCard:(id)aCard
{
    [[self navigationController] performSelector:_cmd withObject:aCard];
}

- (void)goToNextCardWithoutLeaveActions:(id)aActions
{
    [self performNavigationWithoutLeaveActions:@selector(goToNextCard:) sender:aActions];
}

- (void)goToNextCard:(id)aCard
{
    [[self navigationController] performSelector:_cmd withObject:aCard];
}

- (void)goForwardWithoutLeaveActions:(id)aActions
{
    [self performNavigationWithoutLeaveActions:@selector(goForward:) sender:aActions];
}

- (void)goForward:(id)aForward
{
    [[self navigationController] performSelector:_cmd withObject:aForward];
}

- (void)goBackWithoutLeaveActions:(id)aActions
{
    [self performNavigationWithoutLeaveActions:@selector(goBack:) sender:aActions];
}

- (void)goBack:(id)aBack
{
    [[self navigationController] performSelector:_cmd withObject:aBack];
}

- (void)performNavigationWithoutLeaveActions:(SEL)aActions sender:(id)aSender
{
    [self retain];
    [[self actionExecutionManager] setLeaveActionsDisabled:YES];
    [[self navigationController] performSelector:aActions withObject:aSender];
    [[self actionExecutionManager] setLeaveActionsDisabled:NO];
    [self release];
}

- (BOOL)validateUserInterfaceItem:(id)aItem
{
    BOOL result = [super validateUserInterfaceItem:aItem];
    SEL action = [(id <NSValidatedUserInterfaceItem>)aItem action];
    if (action == @selector(goBack:) || action == @selector(goForward:)
        || action == @selector(goBackWithoutLeaveActions:) || action == @selector(goForwardWithoutLeaveActions:)
        || action == @selector(goToNextCard:) || action == @selector(goToPreviousCard:)
        || action == @selector(goToNextCardWithoutLeaveActions:) || action == @selector(goToPreviousCardWithoutLeaveActions:)
        || action == @selector(goToLastCard:) || action == @selector(goToFirstCard:)
        || action == @selector(goToLastCardWithoutLeaveActions:) || action == @selector(goToFirstCardWithoutLeaveActions:)
        || action == @selector(goToSpecificCard:) || action == @selector(goToSpecificCardWithoutLeaveActions:)) {
        if (![[self navigationController] validateUserInterfaceItem:aItem])
            return NO;
        return ![self isStackProtected];
    }
    if (action == @selector(advanceToNextCardWithoutLeaveActions:)) {
        if ([[self currentWindowController] isSheetRunning])
            return NO;
        return ![self isStackProtected];
    }
    if (action == @selector(printDocument:))
        return ![HSRestrictionsManager restrictionState:HSPrintCardsAndTextDisabled];
    if (action == @selector(printCard:)) {
        if ([HSRestrictionsManager restrictionState:HSPrintCardsAndTextDisabled])
            return NO;
        return [[self selectedCards] count] != 0;
    }
    if (action == @selector(printText:)) {
        if ([HSRestrictionsManager restrictionState:HSPrintCardsAndTextDisabled])
            return NO;
        if ([[self mainWindowController] queryHyperInterface:@protocol(HSSelectionAccessor)] != nil) {
            id selection = [self selectedHyperObject];
            if ([selection queryHyperInterface:@protocol(HSTextViewTextAttribute)] != nil && [selection countOfAllHyperInterfaces] == 1)
                return YES;
        }
        return [[self playerCardView] activeTextField] != nil;
    }
    if (action == @selector(runPageLayout:))
        return ![[self currentWindowController] isSheetRunning];
    return result;
}

- (id)anyCard
{
    id card = [self currentCard];
    if (card == nil)
        card = [[[self stack] hyperChildren] extraFirstObject];
    return card;
}

- (id)selectedCards
{
    id card = [self currentCard];
    return card != nil ? [NSArray arrayWithObject:card] : nil;
}

- (void)setCurrentCard:(id)aCard
{
    if ([self currentCard] == aCard)
        return;
    [[NSNotificationCenter defaultCenter] postNotificationName:HSDocumentWillChangeCurrentCardNotification object:self];
    [[self cardView] setCard:aCard];
    [[NSNotificationCenter defaultCenter] postNotificationName:HSDocumentDidChangeCurrentCardNotification object:self];
}

- (id)currentCard
{
    return [[self cardView] card];
}

- (id)attributeNotificationCenter
{
    return [HSAttributeNotificationCenter defaultCenter];
}

- (void)updateChangeCount:(NSUInteger)aCount
{
    if (aCount == NSChangeDone)
        _isNewAndNotChanged = NO;
    [super updateChangeCount:aCount];
    if ([self isDocumentEdited])
        [self setNeedsUpdateSlideshowCache:YES];
}

- (BOOL)isNewAndNotChanged
{
    return _isNewAndNotChanged;
}

- (void)clearChanges
{
    if ([[self undoManager] isUndoRegistrationEnabled]) {
        [[self undoManager] removeAllActions];
        [self updateChangeCount:NSChangeCleared];
    }
}

- (id)auxillaryPath
{
    return [[self fileURL] path];
}

- (id)fileNameSource
{
    return _fileNameSource;
}

- (void)setStack:(id)aStack
{
    [self setStack:aStack notify:YES];
}

- (void)setStack:(id)aStack notify:(BOOL)aNotify
{
    [self setStack:aStack notify:aNotify clearChanges:YES];
}

- (void)setStack:(id)aStack notify:(BOOL)aNotify clearChanges:(BOOL)aChanges
{
    if (_stack == aStack)
        return;
    if (_stack != nil && aNotify)
        [[NSNotificationCenter defaultCenter] postNotificationName:HSDocumentWillChangeCurrentStack object:self];
    BOOL wasProtected = [_stack isStackProtected];
    [_stack removeObserver:self selector:@selector(stackProtectionDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSStackPasswordAttribute)];
    [_stack setSupport:nil];
    [_stack autorelease];
    _stack = [aStack retain];
    [_stack setSupport:self];
    if (aChanges)
        [self clearChanges];
    if (wasProtected != [_stack isStackProtected])
        [self postDocumentProtectionDidChange];
    [_stack addObserver:self selector:@selector(stackProtectionDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSStackPasswordAttribute) withPriority:-0.75];
    if (_stack != nil && aNotify)
        [[NSNotificationCenter defaultCenter] postNotificationName:HSDocumentDidChangeCurrentStack object:self];
}

- (void)stackProtectionDidChange:(id)aChange
{
    [self postDocumentProtectionDidChange];
}

- (void)postDocumentProtectionDidChange
{
    [[NSNotificationCenter defaultCenter] postNotificationName:HSDocumentDidChangeProtectionNotification object:self];
}

- (id)scriptableObjectsIncludingPseudoObjects:(BOOL)aObjects
{
    NSMutableSet *objects = [NSMutableSet set];
    NSEnumerator *cards = [[self stack] hyperEnumerator];
    if (aObjects) {
        HSEnvironmentJSObject *environment = [[HSEnvironmentJSObject new] autorelease];
        [environment setDocument:self];
        [objects addObject:[environment queryHyperInterface:@protocol(HSScriptObject)]];
        [objects addObject:[[[HSSpeechObject new] autorelease] queryHyperInterface:@protocol(HSScriptObject)]];
    }
    id stackScript = [[self stack] queryHyperInterface:@protocol(HSScriptObject)];
    if (stackScript != nil)
        [objects addObject:stackScript];
    // The stack's children first, then the children of every card.
    id node = [self stack];
    do {
        [objects addObjectsFromArray:[[node hyperChildren] queryAnyHyperInterfaces:@protocol(HSScriptObject)]];
        node = [cards nextObject];
    } while (node != nil);
    return [objects allObjects];
}

- (id)scriptableObjects
{
    return [self scriptableObjectsIncludingPseudoObjects:YES];
}

- (void)setTypeOfAcceptedFile:(id)aFile
{
    if (_typeOfAcceptedFile != aFile) {
        [_typeOfAcceptedFile release];
        _typeOfAcceptedFile = [aFile retain];
    }
}

- (id)typeOfAcceptedFile
{
    return _typeOfAcceptedFile;
}

/* The loaders below were wrapped in handlers that only re-raised what they
   caught, so exceptions simply propagate here. */
- (BOOL)loadStackWrapper:(id)aWrapper error:(id *)aError
{
    id stack = [self createStackNodeWithWrapper:aWrapper error:aError];
    if (stack == nil) {
        if (aError != NULL && *aError == nil)
            *aError = [HSError fileErrorWithHSCode:0x4e22 URL:[self fileURL]];
    } else {
        [self setStack:stack];
    }
    return _stack != nil;
}

- (BOOL)loadResourcesWrapper:(id)aWrapper error:(id *)aError
{
    [self setResourcesWrapper:aWrapper];
    return YES;
}

- (BOOL)loadProjectAttributesWrapper:(id)aWrapper error:(id *)aError
{
    NSDictionary *attributes = [aWrapper hyperDictionaryRepresentation];
    if (attributes == nil)
        return NO;
    id version = [attributes objectForKey:@"HSDocumentVersion"];
    id compatibility = [attributes objectForKey:@"HSDocumentCompatibilityVersion"];
    id creator = [attributes objectForKey:@"HSDocumentCreatorVersion"];
    if (version == nil) {
        // Documents written by the editor before versioning only carry the
        // editor version; it doubles as every version number.
        creator = [attributes objectForKey:@"HSEditorVersion"];
        version = creator;
        compatibility = creator;
    }
    BOOL result = [self checkDocumentVersion:version compatibilityVersion:compatibility creatorVersion:creator error:aError];
    if (result)
        [self setAttributes:attributes];
    return result;
}

- (BOOL)attemptRecoveryFromError:(id)aError optionIndex:(NSUInteger)aIndex
{
    if ([[aError domain] isEqual:HSCompatibilityErrorDomain]) {
        if ([(NSError *)aError code] == 0x5027) {
            if (aIndex == 1)
                return [self reopenDocumentIgnoringVersioning];
        } else if ([(NSError *)aError code] == 0x502a) {
            if (aIndex == 0)
                return [self reopenDocumentIgnoringVersioning];
            [self openUpdaterLinkAndQuit];
        }
    }
    return YES;
}

- (void)attemptRecoveryFromError:(id)aError optionIndex:(NSUInteger)aIndex delegate:(id)aDelegate didRecoverSelector:(SEL)aSelector contextInfo:(void *)aInfo
{
    if (![[aError domain] isEqual:HSCompatibilityErrorDomain])
        return;
    BOOL recovered = YES;
    if ([(NSError *)aError code] == 0x5027) {
        if (aIndex == 1)
            recovered = [self reopenDocumentIgnoringVersioning];
    } else if ([(NSError *)aError code] == 0x502a) {
        if (aIndex == 0)
            recovered = [self reopenDocumentIgnoringVersioning];
        else
            [self openUpdaterLinkAndQuit];
    }
    IMP imp = [aDelegate methodForSelector:aSelector];
    if (imp != NULL)
        ((void (*)(id, SEL, BOOL, void *))imp)(aDelegate, aSelector, recovered, aInfo);
}

- (BOOL)reopenDocumentIgnoringVersioning
{
    NSError *error = nil;
    BOOL ignored = [self ignoreVersioning];
    [self setIgnoreVersioning:YES];
    HSApplicationController *controller = [NSDocumentController sharedDocumentController];
    id document;
    if ([self fileURL] == nil)
        document = [controller openUntitledDocumentAndDisplay:YES error:&error];
    else
        document = [controller openDocumentWithContentsOfURL:[self fileURL] display:YES error:&error];
    [self setIgnoreVersioning:ignored];
    // The original reports success when no document was opened.
    return document == nil;
}

- (BOOL)checkDocumentVersion:(id)aVersion compatibilityVersion:(id)aVersion2 creatorVersion:(id)aVersion3 error:(id *)aError
{
    if ([self ignoreVersioning])
        return YES;
    NSString *maxCompatibility = [[self class] maxDocumentCompatibilityVersion];
    NSString *minVersion = [[self class] minDocumentVersion];
    NSString *build = [HSApplicationController buildVersionString];
    if (minVersion == nil)
        minVersion = @"0";
    if (aVersion == nil)
        aVersion = @"0";
    if (maxCompatibility == nil)
        maxCompatibility = @"0";
    if (build == nil)
        build = @"0";

    NSString *title, *message;
    NSArray *options;
    NSInteger code;
    if ([aVersion compare:minVersion options:NSNumericSearch] == NSOrderedAscending) {
        title = HSDocumentAlertString(@"The document format is too old");
        message = [NSString stringWithFormat:HSDocumentAlertString(@"The document was created using %@ version of HyperStudio. The format is very old and not supported any more. Please open the document in %@ version of HyperStudio, resave it and then open again by current application."), aVersion3, minVersion];
        options = [NSArray arrayWithObjects:HSDocumentAlertString(@"Close"), nil];
        code = 0x5027;
    } else {
        NSString *compatibility = aVersion2 != nil ? aVersion2 : @"0";
        if ([compatibility compare:maxCompatibility options:NSNumericSearch] != NSOrderedDescending)
            return YES;
        title = HSDocumentAlertString(@"This stack was created in a newer version of HyperStudio");
        message = [NSString stringWithFormat:HSDocumentAlertString(@"This stack was created using a newer (%@) version of HyperStudio. Your version of HyperStudio (%@) does not support certain features which may (or may not) have been used in this stack.\n\nYou can either update your copy of HyperStudio now, or try opening the stack, although some features may not function as expected."), aVersion3, build];
        options = [NSArray arrayWithObjects:HSDocumentAlertString(@"Open It Anyway"), HSDocumentAlertString(@"Update Now"), nil];
        code = 0x502a;
    }
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              title, NSLocalizedDescriptionKey,
                              message, NSLocalizedRecoverySuggestionErrorKey,
                              options, NSLocalizedRecoveryOptionsErrorKey,
                              aVersion, HSCompatibilityDocumentVersionKey,
                              maxCompatibility, HSCompatibilityMaxVersionKey,
                              self, NSRecoveryAttempterErrorKey, nil];
    if (aError != NULL)
        *aError = [[[NSError alloc] initWithDomain:HSCompatibilityErrorDomain code:code userInfo:userInfo] autorelease];
    return NO;
}

- (void)setIgnoreVersioning:(BOOL)aVersioning
{
    [(HSApplicationController *)[NSDocumentController sharedDocumentController] setIgnoreVersioning:aVersioning];
}

- (BOOL)ignoreVersioning
{
    id controller = [NSDocumentController sharedDocumentController];
    if (![controller respondsToSelector:@selector(ignoreVersioning)])
        return YES;
    return [controller ignoreVersioning];
}

- (id)documentCreatorVersion
{
    id version = [_attributes objectForKey:@"HSDocumentCreatorVersion"];
    if (version == nil)
        version = [HSApplicationController buildVersionString];
    return version;
}

- (id)documentCompatibilityVersion
{
    id version = [_attributes objectForKey:@"HSDocumentCompatibilityVersion"];
    if (version == nil)
        version = [[self class] currentDocumentCompatibilityVersion];
    return version;
}

- (id)documentVersion
{
    id version = [_attributes objectForKey:@"HSDocumentVersion"];
    if (version == nil)
        version = [[self class] currentDocumentVersion];
    return version;
}

- (BOOL)loadContentsWrapper:(id)aWrapper error:(id *)aError
{
    NSDictionary *wrappers = [aWrapper fileWrappers];
    NSEnumerator *keys = [[wrappers allKeys] objectEnumerator];
    BOOL noStack = YES;
    BOOL resourcesLoaded = [self loadResourcesWrapper:[wrappers objectForKey:@"Resources"] error:aError];
    BOOL result = resourcesLoaded;
    while (result) {
        NSString *key;
        while ((key = [keys nextObject]) != nil && ![[key pathExtension] isEqual:@"hsstack"])
            ;
        if (key == nil)
            break;
        noStack = NO;
        result = [self loadStackWrapper:[wrappers objectForKey:key] error:aError];
    }
    if ((noStack || !resourcesLoaded) && aError != NULL) {
        *aError = [HSError fileErrorWithHSCode:0x103 filePath:[[self fileURL] path]];
        result = NO;
    }
    id quickLook = [wrappers objectForKey:@"quicklook"];
    if (quickLook != nil)
        [self loadCardPreviewImagesWrapper:quickLook];
    return result;
}

- (void)loadCardPreviewImagesWrapper:(id)aWrapper
{
    NSDictionary *wrappers = [aWrapper fileWrappers];
    id info = [wrappers objectForKey:@"Info.plist"];
    if (info == nil)
        info = [wrappers objectForKey:@"info.plist"];
    NSEnumerator *cards = [[[info hyperDictionaryRepresentation] objectForKey:@"cards"] objectEnumerator];
    NSDictionary *cardInfo;
    while ((cardInfo = [cards nextObject]) != nil) {
        id uid = [HSUID UIDWithString:[cardInfo objectForKey:@"uid"]];
        id card = [[self stack] childWithUID:uid];
        if (card == nil)
            continue;
        [self setThumbnailImage:[self quickLookImageFromFileWrappers:wrappers cardDictionary:cardInfo forKey:@"thumbnail"] forCard:card];
        [self setPreviewImage:[self quickLookImageFromFileWrappers:wrappers cardDictionary:cardInfo forKey:@"preview"] forCard:card];
    }
}

- (id)quickLookImageFromFileWrappers:(id)aWrappers cardDictionary:(id)aDictionary forKey:(id)aKey
{
    id name = [aDictionary objectForKey:aKey];
    if (name == nil)
        return nil;
    NSData *data = [[aWrappers objectForKey:name] regularFileContents];
    if (data == nil)
        return nil;
    return [[[NSImage alloc] initWithData:data] autorelease];
}

- (id)selectedHyperObject
{
    id object = [[self mainWindowController] selectedHyperObject];
    if (object == nil)
        object = [self stack];
    return object;
}

- (id)stack
{
    if (_stack == nil) {
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        [self setStack:[self createDefaultStack]];
        [pool release];
    }
    return _stack;
}

- (id)attributes
{
    if (_attributes == nil)
        _attributes = [[NSDictionary dictionary] retain];
    return _attributes;
}

- (id)createDefaultStack
{
    id stack = [HSStack defaultObject];
    id card = [HSCard defaultObject];
    [stack addChild:card];
    [card fillBackgroundWithEraserColorIfNeeded];
    return stack;
}

- (id)createStackNodeWithWrapper:(id)aWrapper error:(id *)aError
{
    return [HSStack rootNodeWithFileWrapper:aWrapper explicitNodeDataProvider:nil error:aError];
}

- (id)willPresentError:(id)aError
{
    if ([[aError domain] isEqualToString:HSCocoaErrorDomain] || [[aError domain] isEqualToString:HSSpecificErrorDomain])
        return [HSError errorWithError:aError];
    return [super willPresentError:aError];
}

- (void)readyToCloseDocument
{
    [[NSApplication sharedApplication] performSelector:@selector(terminate:) withObject:self afterDelay:0];
}

- (void)closePlayer
{
    [[self navigationController] interruptAllNavigationOperations];
    [[[self navigationController] presentationSync] documentWillCloseWithDelegate:self readyToCloseSelector:@selector(readyToCloseDocument) contextInfo:NULL];
}

- (BOOL)isDocumentClosing
{
    id sync = nil;
    if ([[self navigationController] respondsToSelector:@selector(presentationSync)])
        sync = [[self navigationController] presentationSync];
    return [sync isDocumentClosing];
}

- (void)close
{
    id card = [[[self navigationController] historyStack] lastMarkedCard];
    [card setCardDocumentPath:[[[self fileURL] path] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[self navigationController] willBeClosedWithDocument];
    [[[self actionExecutionManager] automaticTimerManager] stopAllAutomaticActionTimers];
    [self cleanupWindowControllers];
    [super close];
}

- (void)loadWindows
{
    for (NSWindowController *controller in [self windowControllers])
        [controller window];
}

- (void)removeWindowControllers
{
    [self cleanupWindowControllers];
    NSArray *controllers = [[self windowControllers] copy];
    for (NSWindowController *controller in controllers)
        [self removeWindowController:controller];
    [controllers release];
}

- (void)createWindowControllers
{
    HSApplicationController *controller = [HSApplicationController sharedDocumentController];
    [self setMainWindowController:[controller sharedMainWindowController]];
    [self addWindowController:[self mainWindowController]];
    [controller sharedMainWindowControllerHandled];
}

- (void)cleanupWindowControllers
{
    if ([[HSApplicationController sharedDocumentController] sharedMainWindowController] == [self mainWindowController])
        [self removeWindowController:[self mainWindowController]];
}

- (void)showWindows
{
    id controller = [self currentWindowController];
    id stack = [self stack];
    if (stack == nil || ![stack containsWebCams]) {
        [controller showWindow:self];
        return;
    }
    HSAlert *alert = [HSAlert new];
    [alert setMessageText:HSDocumentAlertString(@"Webcam objects will not be displayed")];
    [alert setInformativeText:HSDocumentAlertString(@"WebCam Submit Request Informative Message Text")];
    [alert addButtonWithTitle:HSDocumentAlertString(@"Continue")];
    [alert addButtonWithTitle:HSDocumentAlertString(@"Cancel")];
    [alert addButtonWithTitle:HSDocumentAlertString(@"Submit Request")];
    [alert setAlertStyle:5];
    NSInteger response = [alert runModal];
    if (response == NSAlertThirdButtonReturn) {
        [[HSSubmitRequest sharedInstance] submitInformation:@"WebCam"];
        [controller showWindow:self];
    } else if (response == NSAlertSecondButtonReturn) {
        [self performSelector:@selector(close) withObject:nil afterDelay:0];
    } else if (response == NSAlertFirstButtonReturn) {
        [controller showWindow:self];
    }
    [alert release];
}

- (void)refreshMoviesHiddenStateForCard:(id)aCard
{
    NSEnumerator *nodes = [aCard hyperDeepEnumerator];
    id node;
    while ((node = [nodes nextObject]) != nil) {
        if ([node implementsHyperInterface:@protocol(HSMovieObjectAttributes)])
            [node setHiddenInPlayer:[node isHidden]];
    }
}

- (void)canCloseDocumentWithDelegate:(id)aDelegate shouldCloseSelector:(SEL)aSelector contextInfo:(void *)aInfo
{
    if ([self isInPlayerMode]) {
        if ([[[self navigationController] presentationSync] isPerformingLeaveActions])
            [[self navigationController] interruptAllNavigationOperations];
        [[[self navigationController] presentationSync] endPresentation];
    }
    [super canCloseDocumentWithDelegate:aDelegate shouldCloseSelector:aSelector contextInfo:aInfo];
}

- (void)printShowingPrintPanel:(BOOL)aPanel
{
    NSSize size = [self documentSize];
    NSPrintInfo *printInfo = [self printInfo];
    // The original asked for retained backing, which AppKit now treats as
    // buffered.
    NSWindow *window = [[NSWindow allocWithZone:[self zone]] initWithContentRect:NSMakeRect(0, 0, size.width, size.height)
                                                                        styleMask:0
                                                                          backing:NSBackingStoreBuffered
                                                                            defer:NO];
    id view = nil;
    SEL selector = _printingSelector;
    if (selector == NULL) {
        if (_printAllPages)
            view = [[HSStackPrintingView allocWithZone:[self zone]] initWithStack:_stack];
        else
            view = [[HSStackPrintingView allocWithZone:[self zone]] initWithCards:[NSArray arrayWithObject:[self currentCard]]];
    } else if (selector == @selector(printCard:)) {
        view = [[HSStackPrintingView allocWithZone:[self zone]] initWithCards:[self selectedCards]];
    } else if (selector == @selector(printText:)) {
        id text = nil;
        if ([[self mainWindowController] queryHyperInterface:@protocol(HSSelectionAccessor)] != nil) {
            id selection = [self selectedHyperObject];
            id storage = [selection queryHyperInterface:@protocol(HSCocoaTextStorageAccessing)];
            if (storage != nil) {
                text = [storage cocoaTextStorage];
            } else {
                id attribute = [selection queryHyperInterface:@protocol(HSTextViewTextAttribute)];
                if (attribute != nil)
                    text = [attribute hyperText];
                else
                    text = [[[self playerCardView] activeTextField] hyperAttributedStringValue];
            }
        } else {
            text = [[[self playerCardView] activeTextField] hyperAttributedStringValue];
        }
        view = [[HSTextPrintingView allocWithZone:[self zone]] initWithContentText:text];
    }
    if (selector == NULL || selector == @selector(printCard:)) {
        [view setDontCenterPrintout:_dontCenterPrintout];
        [view setInPlayerMode:[self isInPlayerMode]];
    }
    _printingSelector = NULL;

    [[window contentView] addSubview:view];
    NSPrintOperation *operation = [NSPrintOperation printOperationWithView:view printInfo:printInfo];
    [operation setCanSpawnSeparateThread:NO];
    NSString *title = [[self displayName] stringByDeletingPathExtension];
    [view setPrintJobTitle:title];
    [view preparePrinting];
    [view release];

    [operation setShowsPrintPanel:aPanel];
    [operation setShowsProgressPanel:YES];
    // The original reached the job name through the private
    // _printSettingsForSetting; the public print settings carry it now.
    PMPrintSettingsSetJobName([printInfo PMPrintSettings], (CFStringRef)title);
    [self retain];
    NSPrintPanel *panel = [operation printPanel];
    [panel setOptions:[panel options] | NSPrintPanelShowsPaperSize | NSPrintPanelShowsOrientation];
    [operation runOperation];
    [self printOperationDidRun:operation success:YES contextInfo:window];
}

- (void)printDocumentWithSettings:(id)aSettings showPrintPanel:(BOOL)aPanel delegate:(id)aDelegate didPrintSelector:(SEL)aSelector contextInfo:(void *)aInfo
{
    _dontCenterPrintout = [[aSettings objectForKey:HSDocumentDontCenterPrintoutKey] boolValue];
    _printAllPages = ![[aSettings objectForKey:HSDocumentPrintCurrentCardKey] boolValue];
    [[self currentWindowController] saveEditingState];
    [super printDocumentWithSettings:aSettings showPrintPanel:aPanel delegate:aDelegate didPrintSelector:aSelector contextInfo:aInfo];
}

- (BOOL)hyperReadFromFileWrapper:(id)aWrapper ofType:(id)aType error:(id *)aError
{
    if (aError != NULL)
        *aError = nil;
    _isNewAndNotChanged = NO;
    BOOL result = NO;
    if (([aType isEqual:@"HSDocumentType"] || [aType isEqual:@"HSWebDocumentType"])
        && [[HSErrorManager sharedErrorManager] isCorrectDocumentFileWrapper:aWrapper]) {
        NSMutableDictionary *wrappers = [NSMutableDictionary dictionaryWithDictionary:[aWrapper fileWrappers]];
        NSEnumerator *keys = [[[aWrapper fileWrappers] allKeys] objectEnumerator];
        if ([wrappers objectForKey:@"Version.plist"] != nil)
            [wrappers removeObjectForKey:@"Version.plist"];
        result = aWrapper != nil;
        while (result) {
            NSString *key;
            while ((key = [keys nextObject]) != nil
                   && ![key isEqualToString:@"Contents.plist"] && ![key isEqualToString:@"Contents.stack"])
                ;
            if (key == nil)
                break;
            result = [self loadProjectAttributesWrapper:[wrappers objectForKey:key] error:aError];
            if (result)
                [wrappers removeObjectForKey:key];
        }
        keys = [[wrappers allKeys] objectEnumerator];
        while (result) {
            NSString *key;
            while ((key = [keys nextObject]) != nil && ![key isEqual:@"Contents"])
                ;
            if (key == nil)
                break;
            result = [self loadContentsWrapper:[wrappers objectForKey:key] error:aError];
        }
    }
    if (!result && aError != NULL && *aError == nil)
        *aError = [HSError fileErrorWithHSCode:0x5028 filePath:[[self fileURL] path]];
    return result;
}

- (id)hyperFileWrapperOfType:(id)aType error:(id *)aError
{
    return nil;
}

- (void)setFileNameSource:(id)aSource
{
    if (_fileNameSource != aSource) {
        [_fileNameSource release];
        _fileNameSource = [aSource retain];
    }
}

- (id)mainDocumentExtensionForType:(id)aType
{
    return [[[NSDocumentController sharedDocumentController] fileExtensionsFromType:aType] extraFirstObject];
}

- (id)displayName
{
    NSString *name = [super displayName];
    if ([[[name pathExtension] lowercaseString] isEqualToString:@"stk"])
        name = [[name lastPathComponent] stringByDeletingPathExtension];
    return name;
}

- (BOOL)readFromURL:(id)aURL ofType:(id)aType error:(id *)aError
{
    BOOL result = NO;
    [self setLoading:YES];
    _isNewAndNotChanged = NO;
    if ([aURL isFileURL]) {
        NSString *path = [aURL path];
        if ([[NSFileManager defaultManager] hyperIsFileReadableAtPath:path]) {
            if (![aType isEqualToString:@"HSNativeDocumentType"]) {
                [self setTypeOfAcceptedFile:aType];
                [self setResourcesWrapper:nil];
                [self setFileNameSource:path];
                if ([aType isEqual:@"HSKeynoteDocumentType"])
                    [self updateChangeCount:NSChangeDone];
                result = [super readFromURL:aURL ofType:aType error:aError];
            } else {
                HSOldFormatDocument *importer = [HSOldFormatDocument new];
                [self setStack:[HSStack defaultObject] notify:YES clearChanges:NO];
                [importer setDocument:self];
                result = [importer readFromFile:path ofType:@"HSNativeDocumentType" error:aError];
                _isCanceledByUser = [importer isCanceledByUser];
                [importer setDocument:nil];
                [importer release];
                if (result) {
                    [self clearChanges];
                    [self awakeFromImporting];
                    [self updateChangeCount:NSChangeReadOtherContents];
                }
            }
        } else if (aError != NULL) {
            *aError = [HSError fileErrorWithHSCode:0x101 filePath:path];
        }
    }
    [self setLoading:NO];
    return result;
}

- (BOOL)revertToContentsOfURL:(id)aURL ofType:(id)aType error:(id *)aError
{
    BOOL playerMode = [self isInPlayerMode];
    if (playerMode) {
        [[[self navigationController] presentationSync] endPresentation];
        [[self actionExecutionContext] deactivate];
    }
    *aError = nil;
    BOOL result = [super revertToContentsOfURL:aURL ofType:aType error:aError];
    [self setCurrentCard:[_stack hyperChildAtIndex:0]];
    if (playerMode) {
        [[self actionExecutionContext] activate];
        [[[self navigationController] presentationSync] runAutomaticTimersAndArrivingActions];
    }
    return result;
}

- (BOOL)isLoading
{
    return _loading;
}

- (void)setLoading:(BOOL)aLoading
{
    if (_loading != aLoading)
        _loading = aLoading;
}

- (void)saveToURL:(id)aURL ofType:(id)aType forSaveOperation:(NSUInteger)aOperation delegate:(id)aDelegate didSaveSelector:(SEL)aSelector contextInfo:(void *)aInfo
{
    BOOL native = [aType isEqualToString:@"HSNativeDocumentType"];
    [[self currentWindowController] saveEditingState];
    HSDefaultSavePanelAccessoryViewController *accessory = [self defaultSavePanelAccessoryViewController];
    NSString *type = native ? @"HSDocumentType" : aType;
    if ([accessory shouldChangeHomeStackURL])
        [[HSHomeStackController sharedHomeStackController] setHomeStackURL:aURL];
    [self setResourcesWrapper:nil];
    [super saveToURL:aURL ofType:type forSaveOperation:aOperation delegate:aDelegate didSaveSelector:aSelector contextInfo:aInfo];
}

- (void)saveDocumentWithDelegate:(id)aDelegate didSaveSelector:(SEL)aSelector contextInfo:(void *)aInfo
{
    [[self currentWindowController] saveEditingState];
    NSString *fileType = [self fileType];
    NSString *stackPath = [[[[self fileURL] path] stringByDeletingPathExtension] stringByAppendingPathExtension:@"stack"];
    if ([fileType isEqual:@"HSDocumentType"]) {
        NSString *path = [[self fileURL] path];
        BOOL isHome = [path isEqual:[[HSPathsProvider sharedPathsProvider] defaultHomeStackPath]];
        [[self defaultSavePanelAccessoryViewController] setShouldChangeHomeStackURL:isHome];
        BOOL inBundle = [path hasPrefix:[[NSBundle mainBundle] bundlePath]];
        id controller = [NSDocumentController sharedDocumentController];
        BOOL stackToGo = [controller respondsToSelector:@selector(isStackToGoController)]
            && [[HSApplicationController sharedDocumentController] isStackToGoController];
        // Stacks inside the application or the default home stack must be
        // saved somewhere else.
        if (!stackToGo && (inBundle || isHome))
            [self runModalSavePanelForSaveOperation:NSSaveOperation delegate:aDelegate didSaveSelector:aSelector contextInfo:aInfo];
        else
            [super saveDocumentWithDelegate:aDelegate didSaveSelector:aSelector contextInfo:aInfo];
    } else if ([fileType isEqual:@"HSNativeDocumentType"] && stackPath != nil
               && ![[NSFileManager defaultManager] fileExistsAtPath:stackPath]) {
        // A converted classic stack is saved next to the original.
        [self setFileType:@"HSDocumentType"];
        [self saveToURL:[NSURL fileURLWithPath:stackPath] ofType:@"HSDocumentType" forSaveOperation:NSSaveAsOperation
               delegate:aDelegate didSaveSelector:aSelector contextInfo:aInfo];
    } else {
        [self setFileType:@"HSDocumentType"];
        [self runModalSavePanelForSaveOperation:NSSaveAsOperation delegate:aDelegate didSaveSelector:aSelector contextInfo:aInfo];
        [self setFileType:fileType];
    }
}

- (BOOL)prepareSavePanel:(id)aPanel
{
    HSDefaultSavePanelAccessoryViewController *accessory = [self defaultSavePanelAccessoryViewController];
    if (accessory != nil)
        [aPanel setAccessoryView:[accessory accessoryView]];
    NSString *folder = [[HSPathsProvider sharedPathsProvider] hyperStudioDocumentsFolder];
    if (folder != nil)
        [aPanel setDirectoryURL:[NSURL fileURLWithPath:folder isDirectory:YES]];
    if ([[aPanel allowedFileTypes] containsObject:@"stk"])
        [aPanel setAllowedFileTypes:[NSArray arrayWithObject:@"stack"]];
    return YES;
}

- (void)removeWindowController:(id)aController
{
    if ([self mainWindowController] != nil && [self mainWindowController] == aController)
        [self setMainWindowController:nil];
    [super removeWindowController:aController];
}

- (void)makeWindowControllers
{
    [self loadPrintInfo];
    [self stack];
    id controller = [[HSApplicationController sharedDocumentController] sharedMainWindowController];
    if (controller == nil)
        controller = [[self mainWindowControllerClass] mainWindowController];
    [self setMainWindowController:controller];
    [self addWindowController:[self mainWindowController]];
    [[HSApplicationController sharedDocumentController] sharedMainWindowControllerHandled];
}

- (void)loadPrintInfo
{
    NSData *data = [[self attributes] objectForKey:@"HSPrintInfoDictionary"];
    if (data == nil)
        return;
    NSPrintInfo *printInfo = [NSUnarchiver unarchiveObjectWithData:data];
    if (printInfo == nil)
        return;
    NSUndoManager *undoManager = [self undoManager];
    [undoManager disableUndoRegistration];
    [self setPrintInfo:printInfo];
    [undoManager enableUndoRegistration];
}

- (id)minimalWindowApplier
{
    return nil;
}

- (id)mainWindowController
{
    return _mainWindowController;
}

- (void)setMainWindowController:(id)aController
{
    if (_mainWindowController != aController)
        _mainWindowController = aController;
}

- (BOOL)isCanceledByUser
{
    return _isCanceledByUser;
}

- (BOOL)isModalSessionPresent
{
    if ([[HSApplicationController sharedDocumentController] isModalSessionPresent])
        return YES;
    for (NSWindowController *controller in [self windowControllers]) {
        if ([[controller window] attachedSheet] != nil)
            return YES;
    }
    return NO;
}

- (BOOL)isWebPlayerDocument
{
    return NO;
}

- (BOOL)isInPurePlayerMode
{
    return NO;
}

- (BOOL)isInPresentationMode
{
    return NO;
}

- (BOOL)isStackProtected
{
    return [[self stack] isStackProtected];
}

- (BOOL)isInAnimationMode
{
    return NO;
}

- (BOOL)isInPlayerMode
{
    return [self cardView] == [self playerCardView];
}

- (id)currentWindowController
{
    return [self mainWindowController];
}

- (void)setNavigationController:(id)aController
{
    if (_navigationController != aController) {
        [_navigationController release];
        _navigationController = [aController retain];
    }
}

- (id)navigationController
{
    if (_navigationController == nil)
        _navigationController = [(HSNavigationController *)[[self navigationControllerClass] alloc] initWithDocument:self];
    return _navigationController;
}

- (id)resourcesWrapper
{
    return _resourcesWrapper;
}

- (id)playerCardView
{
    return [self cardView];
}

- (id)cardViewForNavigation
{
    return [self cardView];
}

- (id)cardView
{
    return [[self mainWindowController] cardView];
}

- (void)takeDataFromDocument:(id)aDocument
{
    if ([_actionExecutionContext document] == self)
        [_actionExecutionContext setDocument:nil];
    [_actionExecutionContext release];
    _actionExecutionContext = [[aDocument actionExecutionContext] retain];
    [_actionExecutionContext setDocument:self];
}

- (void)destoyModel
{
    NSEnumerator *nodes = [_stack hyperDeepLoadedNodeEnumerator];
    id node;
    while ((node = [nodes nextObject]) != nil) {
        if ([node support] == self)
            [node setSupport:nil];
    }
    [_stack removeAttributeObserver:self];
    [_stack release];
    // The original kept the released pointer; clear it so nothing reaches the
    // freed stack afterwards.
    _stack = nil;
}

- (void)destoryModelIfNeeded
{
    if (!_isModelDestroyed) {
        _isModelDestroyed = 1;
        [self destoyModel];
    }
}

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self destoryModelIfNeeded];
    [_resourcesWrapper release];
    [_attributes release];
    [_scriptController setDataSource:nil];
    [_scriptController setDelegate:nil];
    [_scriptController release];
    [self cleanTemporaryFileAtPath:_fileNameSource];
    [_fileNameSource release];
    [_typeOfAcceptedFile release];
    [_navigationController setDocument:nil];
    [_navigationController release];
    [self cleanTemporaryFileAtPath:_imageCachePath];
    [_imageCachePath release];
    [_requiredSlideshowItemType release];
    if ([_actionExecutionContext document] == self)
        [_actionExecutionContext setDocument:nil];
    [_actionExecutionContext release];
    [_actionExecutionManager release];
    [_defaultSavePanelAccessoryViewController release];
    [_goToCardController release];
    [_documentMedia release];
    [_cardThumbnailImages release];
    [_cardPreviewImages release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil)
        _isNewAndNotChanged = YES;
    return self;
}

@end

@implementation HSDocument (CardPreviewImages)

- (void)setPreviewImage:(id)aImage forCard:(id)aCard
{
    if (aImage == nil)
        [_cardPreviewImages removeObjectForKey:[aCard hyperUID]];
    else
        [[self cardPreviewImages] setObject:aImage forKey:[aCard hyperUID]];
}

- (id)previewImageForCard:(id)aCard
{
    return [_cardPreviewImages objectForKey:[aCard hyperUID]];
}

- (void)setThumbnailImage:(id)aImage forCard:(id)aCard
{
    if (aImage == nil)
        [_cardThumbnailImages removeObjectForKey:[aCard hyperUID]];
    else
        [[self cardThumbnailImages] setObject:aImage forKey:[aCard hyperUID]];
}

- (id)thumbnailImageForCard:(id)aCard
{
    return [_cardThumbnailImages objectForKey:[aCard hyperUID]];
}

- (void)invalidatePreviewImages
{
    [_cardThumbnailImages release];
    _cardThumbnailImages = nil;
    [_cardPreviewImages release];
    _cardPreviewImages = nil;
}

- (id)cardPreviewImages
{
    if (_cardPreviewImages == nil)
        _cardPreviewImages = [[NSMutableDictionary alloc] init];
    return _cardPreviewImages;
}

- (id)cardThumbnailImages
{
    if (_cardThumbnailImages == nil)
        _cardThumbnailImages = [[NSMutableDictionary alloc] init];
    return _cardThumbnailImages;
}

@end

@implementation HSDocument (HSSlideshowDataSource)

- (void)setRequiredSlideshowItemType:(id)aType
{
    if (_requiredSlideshowItemType != aType) {
        [_requiredSlideshowItemType release];
        _requiredSlideshowItemType = [aType retain];
    }
}

- (id)requiredSlideshowItemType
{
    return _requiredSlideshowItemType;
}

- (void)setNeedsUpdateSlideshowCache:(BOOL)aCache
{
    if (_needsUpdateSlideshowCache != aCache)
        _needsUpdateSlideshowCache = aCache;
}

- (BOOL)needsUpdateSlideshowCache
{
    return _needsUpdateSlideshowCache;
}

- (void)slideshowDidChangeCurrentIndex:(NSUInteger)aIndex
{
    [self setCurrentCard:[[self stack] hyperChildAtIndex:aIndex]];
}

- (void)slideshowDidStop
{
}

- (void)slideshowWillStart
{
}

- (BOOL)canExportSlideshowItemAtIndex:(NSUInteger)aIndex toApplication:(id)aApplication
{
    return YES;
}

- (id)nameOfSlideshowItemAtIndex:(NSUInteger)aIndex
{
    return [[[[self stack] hyperChildAtIndex:aIndex] queryHyperInterface:@protocol(HSObjectAttributes)] hyperName];
}

- (id)slideshowItemAtIndex:(NSUInteger)aIndex
{
    id image = [[[self stack] hyperChildAtIndex:aIndex] imageForPresentationContext:[[self cardView] presentationContext]];
    if (![[self requiredSlideshowItemType] isEqual:HSSlideshowItemImagePath])
        return image;
    if ([self needsUpdateSlideshowCache] && _imageCachePath != nil) {
        [[NSFileManager defaultManager] removeItemAtPath:_imageCachePath error:NULL];
        [self setImageCachePath:nil];
    }
    NSString *path = [[[self imageCachePath] stringByAppendingPathComponent:[self nameOfSlideshowItemAtIndex:aIndex]] stringByAppendingPathExtension:@"tiff"];
    // As in the original, an image already in the cache yields nil.
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
        return nil;
    [[image TIFFRepresentation] writeToFile:path atomically:NO];
    return path;
}

- (NSUInteger)numberOfSlideshowItems
{
    return [[self stack] hyperCount];
}

- (id)imageCachePath
{
    if (_imageCachePath == nil) {
        NSString *path = [[[HSPathsProvider sharedPathsProvider] temporaryFolder] stringByAppendingPathComponent:[self displayName]];
        path = [NSString extraCreateUniqueFilename:path extension:nil];
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:NULL];
        [self setImageCachePath:path];
    }
    return _imageCachePath;
}

- (void)setImageCachePath:(id)aPath
{
    if (_imageCachePath != aPath) {
        [_imageCachePath release];
        _imageCachePath = [aPath retain];
    }
}

@end

@implementation HSDocument (HSMediaAccess)

+ (id)getMediaNameFromItem:(id)aItem
{
    id attributes = [aItem queryHyperInterface:@protocol(HSMediaAttributes)];
    if (attributes == nil)
        return nil;
    id media = [attributes media];
    if (media == nil)
        return nil;
    return [media mediaName];
}

+ (id)keyForMadiaGroup:(NSInteger)aGroup
{
    if (aGroup == 2)
        return @"HSSoundMediaGroup";
    if (aGroup == 1)
        return @"HSMovieMediaGroup";
    return nil;
}

+ (id)userObjectWithMedia:(id)aMedia
{
    return [self userObjectWithMedia:aMedia error:NULL];
}

+ (id)userObjectWithMedia:(id)aMedia error:(id *)aError
{
    return [self userObjectWithMedia:aMedia animation:NO error:aError];
}

+ (id)userObjectWithMedia:(id)aMedia animation:(BOOL)aAnimation error:(id *)aError
{
    id mediaType = [aMedia mediaType];
    NSArray *classNames = aAnimation ? [HSNewMediaAccessor userAnimationObjectClassNamesForMediaType:mediaType]
                                     : [HSNewMediaAccessor userObjectClassNamesForMediaType:mediaType];
    if (classNames == nil && aError != NULL) {
        NSString *name = [[NSFileManager defaultManager] displayNameAtPath:[aMedia fullPathToMediaFile]];
        *aError = [HSError cantOpenFileErrorWithFileName:name];
    }
    NSError *error = nil;
    id object = nil;
    NSEnumerator *names = [classNames objectEnumerator];
    NSString *className;
    while (object == nil && (className = [names nextObject]) != nil) {
        Class class = NSClassFromString(className);
        if (![class conformsToProtocol:@protocol(HSMediaObject)])
            continue;
        object = [[[class alloc] initWithMedia:aMedia error:&error] autorelease];
        if (object == nil && error != nil) {
            if (aError != NULL)
                *aError = error;
            return nil;
        }
    }
    return object;
}

+ (id)userObjectWithAttributedString:(id)aString
{
    NSDictionary *attributes = [[HSUserObjectDefaultAttributesProvider sharedInstance] defaultAttributesForUserObjectClassName:@"HSSystemTextView"];
    id node = [HSNode nodeWithDictionary:attributes];
    [[node queryHyperInterface:@protocol(HSSystemTextViewAttributes)] setHyperText:aString];
    return node;
}

+ (id)imageObjectsWithPDFMedia:(id)aMedia firstPageOnly:(BOOL)aOnly error:(id *)aError
{
    NSMutableArray *objects = [NSMutableArray new];
    NSArray *images = nil;
    if (!aOnly) {
        images = [NSImage hyperImagesWithContentsOfPDFFile:aMedia];
    } else {
        NSData *data = [[NSData alloc] initWithContentsOfFile:aMedia];
        if (data != nil) {
            HSPDFArtBoxImageRep *rep = [[HSPDFArtBoxImageRep alloc] initWithData:data];
            [data release];
            if (rep != nil) {
                NSImage *image = [[NSImage alloc] initWithSize:[rep size]];
                [image addRepresentation:rep];
                [rep release];
                if (image != nil) {
                    images = [NSArray arrayWithObject:image];
                    [image release];
                }
            }
        }
    }
    for (NSImage *image in images) {
        id media = [HSNewMedia mediaWithImage:image];
        if (media == nil)
            continue;
        id object = [[HSImageObject alloc] initWithMedia:media error:aError];
        if (object != nil) {
            [objects addObject:object];
            [object release];
        }
    }
    return [objects autorelease];
}

- (id)userActionWithMedia:(id)aMedia
{
    return [self userActionWithMedia:aMedia error:NULL];
}

- (id)userActionWithMedia:(id)aMedia error:(id *)aError
{
    if (aMedia == nil)
        return nil;
    NSDictionary *classNames = [HSNewMediaAccessor userActionClassNamesForMediaType:[aMedia mediaType]];
    Class actionClass = NSClassFromString([classNames objectForKey:[[self class] keyForMadiaGroup:[aMedia mediaGroup]]]);
    NSError *error = nil;
    id action = nil;
    if ([actionClass conformsToProtocol:@protocol(HSPlaySoundActionAttributes)]) {
        HSMovie *sound = nil;
        HSSoundItem *item = nil;
        NSString *path = [aMedia fullPathToMediaFileCreateIfNeeded:YES];
        if (path != nil) {
            sound = [[HSMovie alloc] initWithURL:[NSURL fileURLWithPath:path] error:&error];
            if (sound != nil) {
                item = [[HSSoundItem alloc] initWithMediaUID:[aMedia mediaUID] andApplyOptionsFromSound:sound];
                if (item != nil) {
                    action = [[actionClass new] autorelease];
                    [[action queryHyperInterface:@protocol(HSPlaySoundActionAttributes)] addSound:item];
                }
            }
        }
        [sound release];
        [item release];
        if (action == nil && error != nil && aError != NULL)
            *aError = error;
        return action;
    }
    if (![actionClass conformsToProtocol:@protocol(HSPlayMovieActionAttributes)])
        return nil;
    HSMovieObject *movieObject = nil;
    HSMoviePlaybackItem *item = nil;
    action = [[[actionClass alloc] init] autorelease];
    if (action != nil && [action queryHyperInterface:@protocol(HSPlaybackItemSupport)] != nil) {
        movieObject = [[HSMovieObject alloc] initWithMedia:aMedia];
        if (movieObject != nil) {
            id applier = [[movieObject queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
            if (applier != nil) {
                // Center the movie on the card.
                NSSize cardSize = [[self stack] hyperCardSize];
                NSRect frame = [[movieObject queryHyperInterface:@protocol(HSGeometryAttributes)] frameBoundingRect];
                NSPoint origin = NSMakePoint(ceilf((cardSize.width - frame.size.width) * 0.5f),
                                             ceilf((cardSize.height - frame.size.height) * 0.5f));
                [applier moveFrameBoundingRectOriginTo:origin withLayoutGuidingContext:nil];
            }
            item = [[HSMoviePlaybackItem alloc] initWithMovieObject:movieObject playMovieAction:action];
            id attributes = item != nil ? [action queryHyperInterface:@protocol(HSPlayMovieActionAttributes)] : nil;
            if (attributes != nil) {
                [item setEnabled:YES];
                [attributes setMovies:[NSArray arrayWithObject:item]];
            } else {
                action = nil;
            }
        } else {
            action = nil;
        }
    } else {
        action = nil;
    }
    [item release];
    [movieObject release];
    return action;
}

@end

@implementation HSDocument (IBActions)

- (void)printText:(id)aText
{
    _printingSelector = @selector(printText:);
    [self printDocument:aText];
}

- (void)printCard:(id)aCard
{
    _printingSelector = @selector(printCard:);
    [self printDocument:aCard];
}

@end

@implementation HSDocument (HSJavaScriptSupport)

- (id)scriptControllerAllScriptObjects:(id)aObjects
{
    return [self scriptableObjects];
}

- (void)scriptController:(id)aController didErrorWithScript:(id)aScript
{
}

- (void)scriptController:(id)aController didFinishWithScript:(id)aScript
{
}

- (void)scriptController:(id)aController didStartWithScript:(id)aScript
{
}

- (void)scriptControllerDidReady:(id)aReady
{
}

- (void)scriptControllerApplicationClose:(id)aClose
{
    [[NSApplication sharedApplication] terminate:self];
}

- (void)scriptControllerDocumentClose:(id)aClose
{
    [self close];
}

- (void)scriptController:(id)aController transiteToURL:(id)aURL
{
    // A missing target is looked up next to this document.
    NSString *path = [aURL path];
    NSString *name = [path lastPathComponent];
    NSString *folder = [[[self fileURL] path] stringByDeletingLastPathComponent];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *found = path;
    if (![manager fileExistsAtPath:found]) {
        found = [folder stringByAppendingPathComponent:name];
        if (![manager fileExistsAtPath:found])
            found = nil;
    }
    if (found != nil)
        aURL = [NSURL fileURLWithPath:found];
    NSString *type = [[NSDocumentController sharedDocumentController] typeFromFileExtension:[path pathExtension]];
    [self readFromURL:aURL ofType:type error:NULL];
}

- (void)runNonOwnedAction:(id)aAction
{
}

@end

@implementation HSDocument (HSNodeSupport)

- (BOOL)isAttributesNotificationPostingDisabled
{
    return [self isLoading];
}

- (id)cardGroupController
{
    return [_stack cardGroupController];
}

- (id)scriptController
{
    if (_scriptController == nil) {
        _scriptController = [[HSJavaScriptController alloc] init];
        [_scriptController setDelegate:self];
        [_scriptController setDataSource:self];
    }
    return _scriptController;
}

- (id)delegate
{
    return [self mainWindowController];
}

- (id)undoManager
{
    if (!_isUndoManagerCreated) {
        HSUndoManager *undoManager = [[HSUndoManager alloc] init];
        if (undoManager != nil) {
            [self setUndoManager:undoManager];
            [undoManager release];
            _isUndoManagerCreated = 1;
        }
    }
    return [super undoManager];
}

@end
