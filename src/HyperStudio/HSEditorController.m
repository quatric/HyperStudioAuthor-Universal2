#import "HSEditorController.h"

static NSInteger HSSortHyperCardsByTitle(id aCard1, id aCard2, void *aContext)
{
    NSString *title1 = [[aCard1 queryHyperInterface:@protocol(HSCardAttributes)] hyperTitle];
    NSString *title2 = [[aCard2 queryHyperInterface:@protocol(HSCardAttributes)] hyperTitle];
    return CFStringCompareWithOptions((CFStringRef)title1, (CFStringRef)title2, CFRangeMake(0, CFStringGetLength((CFStringRef)title1)), 0x71);
}

@implementation HSEditorController

static BOOL sLastTextFieldTamerReadOnly;
static BOOL sLastTextFieldTamerThisCard;

/* i386 ivar offsets: _sharedPlayerInEditorWindowController=0x4c, _sharedPurePlayerWindowController=0x50, _sharedPresentationWindowController=0x54, _windowsOwnerDocument=0x58, _filesToOpen=0x5c, _applicationLicensor=0x60, _applicationWillFinishCriticalLaunching=0x64, _applicationOpenUntitledFilePending=0x64, _needCancelImportFiles=0x64, _replacingDocument=0x64, _documentInEditor=0x65, _documentsInPurePlayerAndPresentationModesCount=0x68, _onionSkinMode=0x6c */

- (void)cancelExport:(id)aExport
{
    _needCancelImportFiles = YES;
}

- (void)insertInOrderedDocuments:(id)aDocuments
{
    [self insertInOrderedDocuments:aDocuments atIndex:0];
}

- (void)insertInOrderedDocuments:(id)aDocuments atIndex:(NSInteger)aIndex
{
    [self openUntitledDocumentAndDisplay:YES error:0];
}

- (BOOL)application:(id)aApplication delegateHandlesKey:(id)aKey
{
    return (BOOL)[aKey isEqualToString:@"orderedDocuments"];
}

- (id)orderedDocuments
{
    return [self documents];
}

- (id)EULAAttributedString
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] pathForResource:@"HS5LA" ofType:@"rtf"];
    return [[[NSAttributedString alloc] initWithPath:pvVar1_2 documentAttributes:nil] autorelease];
}

- (id)EULATitle
{
    return [[NSBundle mainBundle] localizedStringForKey:@"HSEditorEULATitle" value:@"" table:0];
}

- (id)EULAWindowTitle
{
    return [[NSBundle mainBundle] localizedStringForKey:@"HSEditorEULAWindowTitle" value:@"" table:0];
}

- (BOOL)HSEditorController_validateApplicationLicenseWithInteraction:(BOOL)aInteraction forced:(BOOL)aForced
{
    // Licensing is intentionally not ported (HSApplicationLicensor stays untranslated): every launch is treated as licensed.
    return YES;
}

- (void)HSEditorController_updateMenu:(id)aMenu licenseType:(NSInteger)aType usageTimeFlags:(NSInteger)aFlags
{
    // Registration menu items are tied to the (unported) licensing code; nothing to update.
}

- (void)showLicenseInfo:(id)aInfo
{
    [_applicationLicensor showLicenseInfoDialog];
}

- (void)enterSerialNumber:(id)aNumber
{
    [self HSEditorController_validateApplicationLicenseWithInteraction:YES forced:YES];
}

- (void)techSupportForHyperStudio:(id)aStudio
{
    [_applicationLicensor createRequestWithURLString:[[NSBundle bundleForClass:[HSDocument class]] localizedStringForKey:@"HSTechSupportForHyperStudioURL" value:@"" table:@"HyperPlayerBase"]];
}

- (void)provideHyperStudioFeedback:(id)aFeedback
{
    NSString *url = [[NSBundle bundleForClass:[HSDocument class]] localizedStringForKey:@"HSProvideHyperStudioFeedbackURL" value:@"" table:@"HyperPlayerBase"];
    [HSDocument openURL:url versionString:[[NSBundle bundleForClass:[self class]] HS_buildVersion] addPlatformInfo:YES addProductName:YES];
}

- (void)registerHyperStudio:(id)aStudio
{
    id self_00;

    self_00 = [_applicationLicensor showRegistrationDialog];
    if ([self_00 count] != 0) {
        [[HSSubmitRequest sharedInstance] submitInformationDictionary:self_00];
    }
}

- (void)addReadyMadeCards:(id)aCards
{
    NSString *path = [aCards representedObject];
    NSString *resolved = [[NSFileManager defaultManager] hyperResolveAliasAtPath:path];
    if (resolved == nil) {
        resolved = path;
    }
    if ([[NSFileManager defaultManager] hyperIsFileReadableAtPath:resolved]) {
        [self addReadyMadeCardsFromPath:resolved];
        return;
    }
    HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
    HSAlert *alert = [HSAlert new];
    [alert setMessageText:[NSString stringWithFormat:[provider localizedStringForKey:@"OtherStackMissingAlertMessage" value:@"" table:@"Alerts"], [resolved lastPathComponent]]];
    [alert setInformativeText:[provider localizedStringForKey:@"OtherStackMissingAlertInformativeText" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[provider localizedStringForKey:@"OtherStackMissingAlertFirstButtonTitle" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[provider localizedStringForKey:@"OtherStackMissingAlertSecondButtonTitle" value:@"" table:@"Alerts"]];
    [alert setAlertStyle:NSAlertStyleCritical];
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    if (resolved != nil) {
        [info setObject:resolved forKey:@"HSReadyMadeCardsUserInfoPathKey"];
    }
    NSWindow *window = [[self currentDocument] windowForSheet];
    if (window != nil) {
        [alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:@selector(missingReadyMadeCardAlertDidEnd:returnCode:contextInfo:) contextInfo:info];
        return;
    }
    if ([alert runModal] == 1000) {
        NSOpenPanel *panel = [NSOpenPanel openPanel];
        [panel setAllowsOtherFileTypes:NO];
        [panel setAllowsMultipleSelection:NO];
        [panel setCanChooseDirectories:NO];
        [panel setAllowedFileTypes:[NSArray arrayWithObjects:@"HSDocumentType", @"stack", nil]];
        [panel setDirectoryURL:[NSURL fileURLWithPath:[[HSPathsProvider sharedPathsProvider] hyperStudioDocumentsFolder] isDirectory:YES]];
        NSInteger result = [panel runModal];
        [self findReadyMadeCardPanelDidEnd:panel returnCode:result contextInfo:info];
    } else {
        [info release];
    }
    [alert release];
}

- (void)findReadyMadeCardPanelDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    if (aCode == NSModalResponseOK) {
        NSString *path = [[aEnd URL] path];
        if ([[NSFileManager defaultManager] hyperIsReadableFileAtPath:path showAlert:YES error:NULL]) {
            [self addReadyMadeCardsFromPath:path];
            NSString *directory = [[aEnd directoryURL] path];
            [[HSPathsProvider sharedPathsProvider] setHyperStudioDocumentsFolder:directory];
            NSString *name = [[(NSDictionary *)aInfo objectForKey:@"HSReadyMadeCardsUserInfoPathKey"] lastPathComponent];
            [self storeSymbolicLinkToReadyMadeCardAtPath:path withName:name overwrite:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HSReadyMadeCardsDidChange" object:self];
        }
    }
    [(id)aInfo release];
}

- (void)missingReadyMadeCardAlertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    if (aCode == 1000) {
        NSOpenPanel *panel = [NSOpenPanel openPanel];
        [panel setAllowsMultipleSelection:NO];
        [panel setCanChooseDirectories:NO];
        [panel setDirectoryURL:[NSURL fileURLWithPath:[[HSPathsProvider sharedPathsProvider] hyperStudioDocumentsFolder] isDirectory:YES]];
        [panel setAllowedFileTypes:[NSArray arrayWithObjects:@"HSDocumentType", @"stack", nil]];
        [panel setNameFieldStringValue:@""];
        id contextInfo = (id)aInfo;
        [contextInfo retain];
        [panel beginSheetModalForWindow:[[self currentDocument] windowForSheet] completionHandler:^(NSModalResponse result) {
            [self findReadyMadeCardPanelDidEnd:panel returnCode:result contextInfo:contextInfo];
        }];
    }
    [(id)aInfo release];
    [aEnd release];
}

- (void)addReadyMadeCardsFromPath:(id)aPath
{
    NSError *error = nil;
    HSEditorDocument *currentDocument = [self currentDocument];
    HSEditorDocument *document;
    HSEditorDocument *readDocument;
    if (currentDocument == nil) {
        readDocument = [[self openUntitledDocumentAndDisplay:NO error:&error] retain];
        document = readDocument;
    } else {
        readDocument = [[HSEditorDocument alloc] init];
        document = currentDocument;
    }
    NSString *type = [self typeForContentsOfURL:[NSURL fileURLWithPath:aPath] error:&error];
    if (error == nil) {
        [readDocument readFromURL:[NSURL fileURLWithPath:aPath] ofType:type error:&error];
    }
    if (error == nil) {
        [[document undoManager] setMultipleActionsName:[[NSBundle mainBundle] localizedStringForKey:@"Add Ready Made Cards" value:@"" table:@"UndoManager"]];
        BOOL isNewAndNotChanged = [document isNewAndNotChanged];
        HSStack *documentStack = [document stack];
        if (currentDocument == nil) {
            documentStack = [document createDefaultStack];
        }
        HSStack *sizedStack;
        HSEditorDocument *sizeSource;
        if (!isNewAndNotChanged) {
            sizedStack = [readDocument stack];
            sizeSource = document;
        } else {
            [documentStack removeHyperAllChildren];
            sizedStack = documentStack;
            sizeSource = readDocument;
        }
        [sizedStack setHyperCardSize:[[sizeSource stack] hyperCardSize]];
        NSMutableArray *cardDictionaries = [NSMutableArray array];
        NSMutableSet *mediaUIDs = [NSMutableSet set];
        NSEnumerator *cards = [[[readDocument stack] hyperChildren] objectEnumerator];
        id card;
        while ((card = [cards nextObject]) != nil) {
            [card setHyperTitle:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"HSReadyMadeCardsDefaultTitle" value:@"" table:@"Localizable"]];
            [cardDictionaries addObject:[card fullDictionaryRepresentation]];
            [mediaUIDs unionSet:[[card queryHyperInterface:@protocol(HSMediaCopySupport)] mediaUIDs]];
        }
        NSDictionary *serialized = [NSDictionary dictionaryWithObjectsAndKeys:cardDictionaries, @"HSSerializedCardsKey", [[mediaUIDs allObjects] extraPlistRepresentation], @"HSSerializedCardsMediaUIDsKey", nil];
        NSUInteger insertIndex;
        id selectedCard = [[document editorWindowController] selectedCard];
        if (selectedCard == nil) {
            id activeCard = [self activeCard];
            insertIndex = ([activeCard hyperIndex] == NSNotFound) ? 0 : [[self activeCard] hyperIndex] + 1;
        } else {
            insertIndex = ([[[document editorWindowController] selectedCard] hyperIndex] == NSNotFound) ? 0 : [[[document editorWindowController] selectedCard] hyperIndex] + 1;
        }
        NSArray *inserted = [documentStack insertCards:serialized atIndex:insertIndex];
        if ([inserted count] != 0) {
            [[document mainWindowController] setActiveCard:[inserted objectAtIndex:0]];
        }
        if (currentDocument == nil) {
            [self addDocument:readDocument];
            [readDocument makeWindowControllers];
            [readDocument showWindows];
        }
    } else {
        if ([error code] == 0x4e36) {
            HSAlert *alert = [HSAlert new];
            [alert setMessageText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Cannot create a Ready Made Card" value:@"" table:@"Alerts"]];
            [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"There is not enough disk space to add a Ready Made Card to your stack. Free some disk space and try again." value:@"" table:@"Alerts"]];
            [alert runModal];
            [alert release];
        }
        if (currentDocument == nil && readDocument != nil) {
            [readDocument close];
        }
    }
    [readDocument release];
}

- (id)activeCard
{
    HSEditorDocument *document = [self currentDocument];
    if (document != nil && ![document isInStoryboardMode]) {
        return [[document editorWindowController] activeCard];
    }
    return nil;
}

- (void)saveAsReadyMadeCardPanelDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    [NSApp endSheet:aEnd];
    [aEnd orderOut:self];
    if (aCode != NSModalResponseOK) {
        return;
    }
    NSString *documentsFolder = [[HSPathsProvider sharedPathsProvider] hyperStudioDocumentsFolder];
    [[self currentDocument] saveToURL:[aEnd URL] ofType:@"HSDocumentType" forSaveOperation:NSSaveAsOperation delegate:nil didSaveSelector:NULL contextInfo:NULL];
    [[HSPathsProvider sharedPathsProvider] setHyperStudioDocumentsFolder:documentsFolder];
    NSString *path = [[aEnd URL] path];
    BOOL sandboxed = [[HSSystem sharedSystem] isSandboxed];
    if (!sandboxed && ![[NSFileManager defaultManager] hyperIsFileWritableAtPath:path]) {
        return;
    }
    NSString *directory = [[aEnd directoryURL] path];
    BOOL skipLink = NO;
    if (!sandboxed) {
        skipLink = [directory isEqualToString:[[HSPathsProvider sharedPathsProvider] readyMadeCardsSupportFolder]]
            || [directory isEqualToString:[[HSPathsProvider sharedPathsProvider] readyMadeCardsLocalSupportFolder]];
    }
    if (!skipLink) {
        [self storeSymbolicLinkToReadyMadeCardAtPath:path withName:[path lastPathComponent] overwrite:NO];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSReadyMadeCardsDidChange" object:self];
}

- (void)saveAsReadyMadeCard:(id)aCard
{
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setAllowedFileTypes:[NSArray arrayWithObject:@"stack"]];
    if (![[HSSystem sharedSystem] isSandboxed]) {
        HSSavePanelAccessoryViewController *accessory = [[HSSavePanelAccessoryViewController alloc] initWithNibName:@"SaveAsReadyMadeAccessoryView"];
        [panel setAccessoryView:[accessory accessoryView]];
        [accessory release];
    }
    HSEditorDocument *document = [self currentDocument];
    NSString *name = [[[[document fileURL] path] lastPathComponent] stringByDeletingPathExtension];
    NSString *folder = [[HSPathsProvider sharedPathsProvider] readyMadeCardsSupportFolder];
    if (folder != nil) {
        [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    [panel setDirectoryURL:[NSURL fileURLWithPath:folder isDirectory:YES]];
    if (name == nil) {
        name = [document displayName];
    }
    [panel setNameFieldStringValue:name];
    [panel beginSheetModalForWindow:[[document currentWindowController] window] completionHandler:^(NSModalResponse result) {
        [self saveAsReadyMadeCardPanelDidEnd:panel returnCode:result contextInfo:NULL];
    }];
}

- (void)storeSymbolicLinkToReadyMadeCardAtPath:(id)aPath withName:(id)aName overwrite:(BOOL)aOverwrite
{
    NSString *supportFolder = [[HSPathsProvider sharedPathsProvider] readyMadeCardsSupportFolder];
    NSFileWrapper *wrapper = [[NSFileWrapper alloc] initWithPath:supportFolder];
    NSDictionary *wrappers = [wrapper fileWrappers];
    NSString *name = aName;
    if (!aOverwrite) {
        NSString *base = [aName stringByDeletingPathExtension];
        NSString *extension = [aName pathExtension];
        if ([wrappers objectForKey:aName] != nil) {
            int index = 1;
            NSString *candidate;
            do {
                candidate = [base stringByAppendingFormat:@"%i", index];
                if (extension != nil) {
                    candidate = [candidate stringByAppendingPathExtension:extension];
                }
                index++;
            } while ([wrappers objectForKey:candidate] != nil);
            aName = candidate;
        }
        if (aName != nil) {
            name = aName;
        }
    } else {
        NSFileWrapper *existing = [wrappers objectForKey:aName];
        if (existing != nil) {
            [wrapper removeFileWrapper:existing];
        }
    }
    [wrapper addSymbolicLinkWithDestination:aPath preferredFilename:name];
    [wrapper writeToFile:supportFolder atomically:YES updateFilenames:YES];
    [wrapper release];
}

- (void)setOnionSkinMode:(NSInteger)aMode
{
    if (_onionSkinMode != aMode) {
        _onionSkinMode = (int)aMode;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSOnionSkinModeDidChangeNotification" object:self];
    }
}

- (NSInteger)onionSkinMode
{
    return _onionSkinMode;
}

- (void)runEmbedCodeForStackDialog:(id)aDialog
{
    id controller = [[HSEmbedCodeForStackDialogController alloc] init];
    [controller runModal];
    [controller release];
}

- (void)setOnionSkin:(id)aSkin
{
    [self setOnionSkinMode:[aSkin tag]];
    HSEditorDocument *document = [self currentDocument];
    if ([document isInPlayerMode]) {
        [document switchToEditor];
    }
}

- (void)paste:(id)aPaste
{
    if ([[NSPasteboard generalPasteboard] availableTypeFromArray:[NSArray arrayWithObject:@"HSCardPasteboardType"]] != nil) {
        [[[self openUntitledDocumentAndDisplay:YES error:0] editorWindowController] paste:aPaste];
    }
}

- (void)sameBackground:(id)aBackground
{
    id document = [self currentDocument] != nil ? [self currentDocument] : [self openUntitledDocumentAndDisplay:YES error:NULL];
    [[document editorWindowController] sameBackground:aBackground];
}

- (void)makeGroupCard:(id)aCard
{
    id document = [self currentDocument] != nil ? [self currentDocument] : [self openUntitledDocumentAndDisplay:YES error:NULL];
    [[document editorWindowController] makeGroupCard:aCard];
}

- (void)newCard:(id)aCard
{
    HSEditorDocument *document = [self currentDocument];
    if (document != nil) {
        [document newCard:aCard];
    } else {
        [self newDocument:aCard];
    }
}

- (void)goToHomeWithoutLeaveActions:(id)aActions
{
    [[self defaultNavigationControllerClass] goToHomeStack];
}

- (void)openReferenceGuide:(id)aGuide
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] pathForResource:@"HyperStudio 5 Reference Guide" ofType:@"pdf"];
    [[NSWorkspace sharedWorkspace] openFile:pvVar1_2];
}

- (void)importFromKeynote:(id)aKeynote
{
    NSOpenPanel *panel = [[NSOpenPanel openPanel] retain];
    [panel setAllowsOtherFileTypes:NO];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    [panel setPrompt:[[NSBundle mainBundle] localizedStringForKey:@"ImportKeynotePrompt" value:@"" table:nil]];
    [panel setMessage:[[NSBundle mainBundle] localizedStringForKey:@"ImportKeynoteMessage" value:@"" table:nil]];
    [panel setAllowedFileTypes:[NSArray arrayWithObject:@"key"]];
    [panel setDirectoryURL:[NSURL fileURLWithPath:[[HSPathsProvider sharedPathsProvider] keynoteDocumentsImportFolder] isDirectory:YES]];
    if ([panel runModal] == NSModalResponseOK) {
        [[HSPathsProvider sharedPathsProvider] setKeynoteDocumentsImportFolder:[[[panel URL] path] stringByDeletingLastPathComponent]];
        NSError *error = nil;
        [self openDocumentWithContentsOfURL:[panel URL] display:YES error:&error];
        if (error != nil) {
            [[HSErrorManager sharedErrorManager] presentError:error];
        }
    }
    [panel release];
}

- (void)toggleCoverDesktop:(id)aDesktop
{
    BOOL enabled = [[[HSUI sharedUI] settingsForKey:HSUIModeIsCoverDesktopEnabled] boolValue];
    [[HSUI sharedUI] setSettings:[NSNumber numberWithBool:!enabled] forKey:HSUIModeIsCoverDesktopEnabled];
}

- (void)hideShowToolbar:(id)aToolbar
{
    BOOL enabled = [[[HSUI sharedUI] settingsForKey:HSUIModeIsToolbarShown] boolValue];
    [[HSUI sharedUI] setSettings:[NSNumber numberWithBool:!enabled] forKey:HSUIModeIsToolbarShown];
}

- (void)toggleCommentsAndAttributionsPalette:(id)aPalette
{
    [[HSCommentsAndAttributionsPaletteController sharedInstance] togglePalette];
}

- (void)toggleShortcutsPalette:(id)aPalette
{
    [[HSShortcutsPaletteController sharedInstance] togglePalette];
}

- (void)toggleObjectListPalette:(id)aPalette
{
    [[HSObjectListPaletteController sharedInstance] togglePalette];
}

- (void)toggleLayoutPanel:(id)aPanel
{
    [[HSLayoutPaletteController sharedInstance] togglePalette];
}

- (void)toggleToolsPalette:(id)aPalette
{
    [[HSToolPaletteController sharedInstance] togglePalette];
}

- (void)toggleColorPanel:(id)aPanel
{
    NSColorPanel *panel = [NSColorPanel sharedColorPanel];
    if ([panel isVisible]) {
        [panel performClose:self];
    } else {
        [panel orderFront:self];
    }
}

- (void)toggleFontPanel:(id)aPanel
{
    NSFontPanel *panel = [NSFontPanel sharedFontPanel];
    if ([panel isVisible]) {
        [panel orderOut:self];
    } else {
        [[NSFontManager sharedFontManager] orderFrontFontPanel:self];
    }
}

- (void)toggleLibrary:(id)aLibrary
{
    HSLibraryController *library = [HSLibraryController sharedLibraryController];
    if ([library isLibraryVisible]) {
        [library hideLibrary];
    } else {
        [library showLibrary];
    }
}

- (void)launchTextEdit:(id)aEdit
{
    if (![[NSWorkspace sharedWorkspace] launchApplication:@"TextEdit"]) {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSString *title = [bundle localizedStringForKey:@"Cannot launch TextEdit" value:@"" table:@"Alerts"];
        NSString *information = [bundle localizedStringForKey:@"The TextEdit application may have been deleted, or you may not have sufficient privileges to launch it. Reinstall TextEdit or change its privileges to \"Read & Write\" and try again." value:@"" table:@"Alerts"];
        NSAlert *alert = [NSAlert alertWithMessageText:title defaultButton:[bundle localizedStringForKey:@"OK" value:@"" table:@"Alerts"] alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", information];
        [alert runModal];
    }
}

- (void)launchGrab:(id)aGrab
{
    if (![[NSWorkspace sharedWorkspace] launchApplication:@"Grab"]) {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSString *title = [bundle localizedStringForKey:@"Cannot launch Grab" value:@"" table:@"Alerts"];
        NSString *information = [bundle localizedStringForKey:@"The Grab application may have been deleted, or you may not have sufficient privileges to launch it. Reinstall Grab or change its privileges to \"Read & Write\" and try again." value:@"" table:@"Alerts"];
        NSAlert *alert = [NSAlert alertWithMessageText:title defaultButton:[bundle localizedStringForKey:@"OK" value:@"" table:@"Alerts"] alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", information];
        [alert runModal];
    }
}

- (void)launchGrapher:(id)aGrapher
{
    if (![[NSWorkspace sharedWorkspace] launchApplication:@"Grapher"]) {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSString *title = [bundle localizedStringForKey:@"Cannot launch Grapher" value:@"" table:@"Alerts"];
        NSString *information = [bundle localizedStringForKey:@"The Grapher application may have been deleted, or you may not have sufficient privileges to launch it. Reinstall Grapher or change its privileges to \"Read & Write\" and try again." value:@"" table:@"Alerts"];
        NSAlert *alert = [NSAlert alertWithMessageText:title defaultButton:[bundle localizedStringForKey:@"OK" value:@"" table:@"Alerts"] alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", information];
        [alert runModal];
    }
}

- (BOOL)validateUserInterfaceItem:(id)aItem
{
    BOOL superResult = [super validateUserInterfaceItem:aItem];
    HSEditorDocument *document = [self currentDocument];
    SEL action = [aItem action];
    if ([[document actionExecutionContext] waitingForMouseDownEvent] || [document isInHyperCastingMode]) {
        return action == @selector(openReferenceGuide:) || action == @selector(openTutorial:) || action == @selector(techSupportForHyperStudio:);
    }
    if (!superResult && [[document mainWindowController] isSheetRunning]) {
        return NO;
    }
    if (action == @selector(toggleLibrary:)) {
        if ([aItem isKindOfClass:[NSMenuItem class]]) {
            [aItem setState:[[HSLibraryController sharedLibraryController] isLibraryVisible]];
        }
        if ([document isInPurePlayerMode] || [document isInPresentationMode] || [document isStackProtected]) {
            return NO;
        }
        return ![document isModalSessionPresent];
    }
    if (action == @selector(toggleObjects:)) {
        return NO;
    }
    if (action == @selector(toggleToolsPalette:)) {
        if ([document isInPurePlayerMode] || [document isInPresentationMode] || [document isStackProtected] || [document isModalSessionPresent]) {
            return NO;
        }
        return [[HSToolPaletteController sharedInstance] validateTogglePaletteUserInterfaceItem:aItem];
    }
    if (action == @selector(toggleLayoutPanel:) || action == @selector(toggleObjectListPalette:)) {
        Class paletteController = (action == @selector(toggleLayoutPanel:)) ? [HSLayoutPaletteController class] : [HSObjectListPaletteController class];
        if (![[paletteController sharedInstance] validateTogglePaletteUserInterfaceItem:aItem]) {
            return NO;
        }
        if ([document isInStoryboardMode] || [document isInHyperCastingMode] || [document isInPresentationMode] || [document isInPurePlayerMode] || [document isStackProtected]) {
            return NO;
        }
        return ![document isModalSessionPresent];
    }
    if (action == @selector(toggleShortcutsPalette:)) {
        if ([document isInPresentationMode] || [document isInPlayerMode]) {
            return NO;
        }
        return [[HSShortcutsPaletteController sharedInstance] validateTogglePaletteUserInterfaceItem:aItem];
    }
    if (action == @selector(toggleCommentsAndAttributionsPalette:)) {
        if (![[HSCommentsAndAttributionsPaletteController sharedInstance] validateTogglePaletteUserInterfaceItem:aItem]) {
            return NO;
        }
        if ([document isInStoryboardMode] || [document isInHyperCastingMode] || [document isInPurePlayerMode]) {
            return NO;
        }
        return ![document isInPresentationMode];
    }
    if (action == @selector(togglePresentationModeButton:)) {
        BOOL switchesPlayerMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"HSPresentationModeButtonSwitchesPlayerMode"];
        if ([aItem respondsToSelector:@selector(setState:)]) {
            [aItem setState:(!switchesPlayerMode && [[HSUI sharedUI] currentMode] == 1) ? 1 : 0];
        }
        BOOL result = [document validateUserInterfaceItemThatRequiresTogglePlayEditModes:aItem];
        if (![aItem isKindOfClass:[NSButton class]]) {
            return result;
        }
        BOOL playerMode;
        BOOL entering;
        if (switchesPlayerMode || [[HSUI sharedUI] currentMode] != 1 || !result) {
            playerMode = switchesPlayerMode;
            entering = YES;
        } else {
            playerMode = NO;
            entering = NO;
        }
        if (playerMode) {
            [aItem setImage:[NSImage imageNamed:entering ? @"PlayerMode" : @"PlayerMode_On"]];
            [aItem setToolTip:[[NSBundle mainBundle] localizedStringForKey:entering ? @"Enter Player view." : @"Leave Player view." value:@"" table:nil]];
            return result;
        }
        [aItem setImage:[NSImage imageNamed:entering ? @"PMode" : @"PMode_On"]];
        [aItem setToolTip:[[NSBundle mainBundle] localizedStringForKey:entering ? @"Enter Presentation view." : @"Leave Presentation view." value:@"" table:nil]];
        return result;
    }
    if (action == @selector(toggleCoverDesktop:)) {
        if ([aItem respondsToSelector:@selector(setState:)]) {
            [aItem setState:![[[HSUI sharedUI] settingsForKey:HSUIModeIsCoverDesktopEnabled] boolValue]];
        }
        return ![document isInPresentationMode];
    }
    if (action == @selector(sameBackground:)) {
        if (document == nil || [document isModalSessionPresent] || [document isStackProtected]) {
            return NO;
        }
        return ![document isInPresentationMode];
    }
    if (action == @selector(makeGroupCard:)) {
        if (document == nil || [document isModalSessionPresent] || [document isStackProtected] || [document isInPresentationMode]) {
            return NO;
        }
        return ![document isInAnimationMode];
    }
    if (action == @selector(goToHomeWithoutLeaveActions:) || action == @selector(importFromKeynote:) || action == @selector(runEmbedCodeForStackDialog:)) {
        return ![document isModalSessionPresent];
    }
    if (action == @selector(addReadyMadeCards:) || action == @selector(newCard:)) {
        if ([document isStackProtected]) {
            return NO;
        }
        return ![document isModalSessionPresent];
    }
    if (action == @selector(launchGrapher:) || action == @selector(launchGrab:) || action == @selector(launchTextEdit:)) {
        NSString *application = (action == @selector(launchGrapher:)) ? @"Grapher" : (action == @selector(launchGrab:)) ? @"Grab" : @"TextEdit";
        if ([[NSWorkspace sharedWorkspace] fullPathForApplication:application] == nil) {
            return NO;
        }
        return ![document isModalSessionPresent];
    }
    if (action == @selector(paste:)) {
        if ([self isMultiDocument]) {
            if ([self isModalSessionPresent]) {
                return NO;
            }
        } else if ([document isModalSessionPresent]) {
            return NO;
        }
        if ([document isInPresentationMode] || [document isInPurePlayerMode]) {
            return NO;
        }
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        if ([pasteboard availableTypeFromArray:[NSArray arrayWithObject:@"HSCardPasteboardType"]] == nil) {
            return NO;
        }
        if (![aItem isKindOfClass:[NSMenuItem class]]) {
            return YES;
        }
        NSString *menuTitle = [[HSEditorWindowController class] localizedMenuTitleForCardsPasteBoardType:[NSPasteboard generalPasteboard]];
        NSString *format = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSPasteFormat" value:@"" table:@"Editor"];
        [aItem setTitle:[NSString stringWithFormat:format, menuTitle]];
        return YES;
    }
    if (action == @selector(saveAsReadyMadeCard:)) {
        if (document == nil || [document isModalSessionPresent] || [document isInAnimationMode] || [document isWritingDisabled] || [document isInHyperCastingMode] || [document isInPurePlayerMode] || [document isStackProtected]) {
            return NO;
        }
        return ![document isModalSessionPresent];
    }
    if (action == @selector(hideShowToolbar:)) {
        if (document == nil) {
            return NO;
        }
        return ![document isModalSessionPresent];
    }
    if (action == @selector(setOnionSkin:)) {
        [aItem setState:[self onionSkinMode] == [aItem tag]];
        if (![document isInStandardMode]) {
            return NO;
        }
        return ![document isModalSessionPresent];
    }
    if (action != @selector(newDocument:) && action != @selector(openDocument:)) {
        if (!superResult) {
            return NO;
        }
        if (![aItem isKindOfClass:[NSMenuItem class]]) {
            return superResult;
        }
        if ([[[[aItem menu] itemArray] lastObject] action] != @selector(clearRecentDocuments:)) {
            return superResult;
        }
        if ([[document exportManager] isExporting]) {
            return NO;
        }
        if ([self isMultiDocument]) {
            return YES;
        }
        if ([[document mainWindowController] isSheetRunning]) {
            return NO;
        }
        return ![document isModalSessionPresent];
    }
    if (superResult) {
        if ([[document exportManager] isExporting]) {
            superResult = NO;
        } else if (![self isMultiDocument]) {
            superResult = !([[document mainWindowController] isSheetRunning] || [document isModalSessionPresent]);
        } else {
            superResult = YES;
        }
    }
    if (![[HSSystem sharedSystem] isMountainLionOrGreater]) {
        return superResult;
    }
    if (![self isModalSessionPresent]) {
        return superResult;
    }
    [[[[[NSApp mainMenu] itemAtIndex:1] submenu] itemAtIndex:0] setEnabled:NO];
    return superResult;
}

- (BOOL)toolPaletteControllerShouldUseToolManager
{
    return ![[self currentDocument] isInStoryboardMode];
}

- (void)contextHelpModeDidActivate:(id)aActivate
{
    [NSApp showHelp:0];
}

- (void)applicationDidResignActive:(id)aActive
{
    [[HSKeysRegistry sharedRegistry] resetKeysRegistry];
}

- (NSUInteger)importMediaOrTextFiles:(id)aFiles importDenied:(BOOL *)aDenied selectedCard:(id)aCard addedCards:(id)aCards
{
    NSUInteger result = 0;
    BOOL denied = NO;
    if ([aFiles count] != 0) {
        denied = YES;
        HSEditorDocument *document = [self currentDocument];
        HSCard *firstCard = nil;
        BOOL replaceCard = NO;
        BOOL canImport = YES;
        if (document == nil) {
            document = [self openUntitledDocumentAndDisplay:YES error:NULL];
            firstCard = [document currentCard];
            [aCards addObject:firstCard];
            replaceCard = YES;
        } else if ([document isNewAndNotChanged]) {
            firstCard = [document currentCard];
            [aCards addObject:firstCard];
            replaceCard = YES;
        } else if ([[[document stack] queryHyperInterface:@protocol(HSMutableStackAttributes)] isStackProtected]) {
            canImport = NO;
        }
        if (canImport && [[[document mainWindowController] cardView] respondsToSelector:@selector(importToCardDataFromFiles:showHelpPane:)]) {
            HSStack *stack = [document stack];
            HSCard *selected = aCard != nil ? aCard : [document currentCard];
            result = [self importMediaOrTextFiles:aFiles asCardsAtIndex:[stack indexOfHyperChild:selected] + 1 replaceCard:replaceCard toDocument:document addedCards:aCards];
            [[document undoManager] disableUndoRegistration];
            id event = [HSActionEvent actionEventOfType:kHSClickActionEventType];
            id actor = [firstCard queryHyperInterface:@protocol(HSActor)];
            if ([actor hyperActionOfType:[HSOpenLocationAction actionType] forEvent:event] == nil) {
                [actor addHyperAction:[HSNextCardAction nextCardActionWithFadeTransition] forEvent:event];
            }
            [[document undoManager] enableUndoRegistration];
            denied = NO;
        }
    }
    if (aDenied != NULL) {
        *aDenied = denied;
    }
    return result;
}

- (void)importDataFromFiles:(id)aFiles asCardWithIndex:(NSUInteger)aIndex toDocument:(id)aDocument
{
    HSStack *stack = [aDocument stack];
    NSUndoManager *undoManager = [aDocument undoManager];
    [undoManager disableUndoRegistration];
    NSArray *images = nil;
    NSArray *movies = nil;
    NSArray *otherMediaOrText = nil;
    [self chooseFilesForImportWithFiles:aFiles images:&images movies:&movies otherMediaOrText:&otherMediaOrText];
    NSMutableArray *addedCards = [NSMutableArray new];
    NSUInteger index = aIndex;
    NSEnumerator *imageEnumerator = [images objectEnumerator];
    NSString *file;
    while ((file = [imageEnumerator nextObject]) != nil) {
        NSImage *image = [[NSImage alloc] initWithContentsOfFile:file];
        if (image != nil) {
            HSCard *card = [HSCard defaultObject];
            [stack insertHyperChild:card atIndex:index];
            [addedCards addObject:card];
            if (index != 0) {
                HSCard *previous = [stack hyperChildAtIndex:index - 1];
                if ([previous isGroupCard]) {
                    [card makeGroupCardWithGroupUID:[previous cardGroupUID]];
                }
            }
            [self importImage:image withFileURL:[NSURL fileURLWithPath:file] toDocument:aDocument withCard:card];
            index++;
        }
        [image release];
    }
    HSMovieVerifier *verifier = [[HSMovieVerifier alloc] init];
    NSAutoreleasePool *pool = nil;
    NSEnumerator *movieEnumerator = [movies objectEnumerator];
    while ((file = [movieEnumerator nextObject]) != nil) {
        [pool release];
        pool = [NSAutoreleasePool new];
        NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:file, QTMovieFileNameAttribute, (id)kCFBooleanFalse, QTMovieResolveDataRefsAttribute, nil];
        if (attributes == nil) {
            break;
        }
        QTMovie *movie = [[QTMovie alloc] initWithAttributes:attributes error:NULL];
        [attributes release];
        if (movie != nil) {
            QTMovie *verified = [verifier verifyMovie:movie withOptions:0 error:NULL];
            if (movie == verified) {
                [movie autorelease];
            } else {
                [movie release];
            }
            if (verified != nil) {
                NSURL *url = [NSURL fileURLWithPath:file];
                HSCard *card = url != nil ? [HSCard defaultObject] : nil;
                if (card == nil) {
                    break;
                }
                [stack insertHyperChild:card atIndex:index];
                [addedCards addObject:card];
                [self importMovie:verified withFileURL:url toCard:card];
                index++;
            }
        }
    }
    [verifier release];
    [pool release];
    [self importMediaOrTextFiles:otherMediaOrText asCardsAtIndex:index replaceCard:NO toDocument:aDocument addedCards:addedCards];
    [undoManager enableUndoRegistration];
    NSUInteger count = [addedCards count];
    if (count != 0) {
        [undoManager disableUndoRegistration];
        NSArray *sorted = [addedCards sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            NSString *titleA = [[a queryHyperInterface:@protocol(HSCardAttributes)] hyperTitle];
            NSString *titleB = [[b queryHyperInterface:@protocol(HSCardAttributes)] hyperTitle];
            return (NSComparisonResult)CFStringCompareWithOptions((CFStringRef)titleA, (CFStringRef)titleB, CFRangeMake(0, CFStringGetLength((CFStringRef)titleA)), 0x71);
        }];
        for (NSUInteger i = 0; i < count; i++) {
            [stack setIndex:aIndex + i ofHyperChild:[sorted objectAtIndex:i]];
        }
        [undoManager enableUndoRegistration];
        [undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:(count == 1 ? @"Add Item" : @"Add Items") value:@"" table:@"UndoManager"]];
        [[undoManager prepareWithInvocationTarget:self] undoImportingFilesCount:count lastAddedCardIndex:(aIndex - 1) + count];
    }
    [addedCards release];
}

- (NSUInteger)importMediaOrTextFiles:(id)aFiles asCardsAtIndex:(NSUInteger)aIndex replaceCard:(BOOL)aCard toDocument:(id)aDocument addedCards:(id)aCards
{
    NSMutableArray *added = [NSMutableArray new];
    id stack = [[aDocument stack] queryHyperInterface:@protocol(HSNodeContainer)];
    NSUInteger index = aIndex;
    BOOL replaceCard = aCard;
    id groupUID = nil;
    if (!replaceCard) {
        groupUID = [[stack hyperChildAtIndex:(aIndex != 0 ? aIndex - 1 : 0)] cardGroupUID];
    }
    NSUndoManager *undoManager = [aDocument undoManager];
    [undoManager disableUndoRegistration];
    BOOL registerUndo = !replaceCard && [stack hyperCount] != [aCards count];
    NSUInteger fileCount = [aFiles count];
    NSUInteger result = 0;
    if (fileCount != 0 && stack != nil) {
        id cardView = [[aDocument mainWindowController] cardView];
        if ([cardView respondsToSelector:@selector(importToCardDataFromFiles:showHelpPane:)]) {
            for (NSUInteger i = 0; i < fileCount; i++) {
                NSString *path = [aFiles objectAtIndex:i];
                NSString *title = [[path lastPathComponent] stringByDeletingPathExtension];
                if (!replaceCard) {
                    id card = [HSCard defaultObject];
                    if (card == nil) {
                        break;
                    }
                    [added addObject:card];
                    [[card queryHyperInterface:@protocol(HSMutableCardAttributes)] setHyperTitle:title];
                    [stack insertHyperChild:card atIndex:index];
                    [cardView setCard:card];
                } else {
                    [[[stack hyperChildAtIndex:index - 1] queryHyperInterface:@protocol(HSMutableCardAttributes)] setHyperTitle:title];
                }
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSString *extension = [path pathExtension];
                BOOL textAsTarget = [defaults boolForKey:HSImportTextAsTargetForOpenThisDocumentActionKey];
                NSUInteger imported;
                if (!textAsTarget && [extension compare:@"pdf" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                    NSArray *objects = [cardView objectsFromPDFFile:path firstPageOnly:![defaults boolForKey:HSImportAllPDFPagesKey]];
                    NSUInteger pageCount = [objects count];
                    if (pageCount == 0) {
                        imported = 0;
                    } else {
                        if (replaceCard && [stack hyperCount] == 1) {
                            NSSize largest = NSZeroSize;
                            for (NSUInteger j = 0; j < pageCount; j++) {
                                NSSize size = [[[objects objectAtIndex:j] queryHyperInterface:@protocol(HSSizeAttributes)] size];
                                if (size.width > largest.width) {
                                    largest.width = size.width;
                                }
                                if (size.height > largest.height) {
                                    largest.height = size.height;
                                }
                            }
                            if (largest.width > 0 && largest.height > 0) {
                                [[stack queryHyperInterface:@protocol(HSMutableStackAttributes)] setHyperCardSize:largest];
                            }
                            [cardView fitInWindow];
                        }
                        for (NSUInteger j = 0; j < pageCount; j++) {
                            NSString *pageTitle = [NSString stringWithFormat:@"%@ %d", title, (int)(j + 1)];
                            if (j != 0) {
                                id card = [HSCard defaultObject];
                                if (card == nil) {
                                    break;
                                }
                                [added addObject:card];
                                [[card queryHyperInterface:@protocol(HSMutableCardAttributes)] setHyperTitle:pageTitle];
                                [stack insertHyperChild:card atIndex:index];
                                [cardView setCard:card];
                            }
                            NSUInteger advance = (j < pageCount - 1) ? 1 : 0;
                            index += advance;
                            result += advance;
                            [cardView addObjectToCenter:[objects objectAtIndex:j] useDragPreferences:YES];
                        }
                        imported = 1;
                    }
                } else if ([extension isEqualToString:@"kmz"] || [extension isEqualToString:@"kml"]) {
                    id card = [cardView card];
                    HSGoogleEarthAction *action = [HSGoogleEarthAction new];
                    [action setURL:[NSURL fileURLWithPath:path]];
                    [[card queryHyperInterface:@protocol(HSActor)] addHyperAction:action forEvent:[HSActionEvent actionEventOfType:kHSClickActionEventType]];
                    [action release];
                    imported = 0;
                } else {
                    NSArray *single = [NSArray arrayWithObject:path];
                    if (single == nil) {
                        break;
                    }
                    BOOL showHelpPane = (fileCount == i + 1);
                    if (!showHelpPane && !textAsTarget) {
                        showHelpPane = YES;
                        for (NSUInteger j = i + 1; j < fileCount; j++) {
                            if ([[[aFiles objectAtIndex:j] pathExtension] compare:@"pdf" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                                showHelpPane = NO;
                                break;
                            }
                        }
                    }
                    imported = [cardView importToCardDataFromFiles:single showHelpPane:showHelpPane];
                }
                result += imported;
                replaceCard = (imported == 0);
                index += (imported != 0);
            }
        }
    }
    HSActionEvent *clickEvent = [HSActionEvent actionEventOfType:kHSClickActionEventType];
    for (id card in added) {
        id actor = [card queryHyperInterface:@protocol(HSActor)];
        if (groupUID == nil || [[actor hyperActions] count] != 0) {
            id openLocation = [actor hyperActionOfType:[HSOpenLocationAction actionType] forEvent:clickEvent];
            if (openLocation == nil) {
                [actor addHyperAction:[HSNextCardAction nextCardActionWithFadeTransition] forEvent:clickEvent];
            }
        } else {
            [card makeGroupCardWithGroupUID:groupUID];
        }
    }
    [aCards addObjectsFromArray:added];
    [undoManager enableUndoRegistration];
    NSUInteger addedCount = [added count];
    if (registerUndo && addedCount != 0) {
        [undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:(addedCount == 1 ? @"Add Item" : @"Add Items") value:@"" table:@"UndoManager"]];
        [[undoManager prepareWithInvocationTarget:self] undoImportingFilesCount:addedCount lastAddedCardIndex:index - 1];
    }
    [added release];
    return result;
}

- (NSUInteger)importMovieFiles:(id)aFiles importDenied:(BOOL *)aDenied
{
    return (unsigned int)[self importMovieFiles:aFiles importDenied:aDenied selectedCard:nil addedCards:nil];
}

- (NSUInteger)importMovieFiles:(id)aFiles importDenied:(BOOL *)aDenied selectedCard:(id)aCard addedCards:(id)aCards
{
    HSEditorDocument *document = [self currentDocument];
    BOOL registerUndo = (document != nil) && [[document stack] hyperCount] != [aCards count];
    NSUInteger imported = 0;
    BOOL denied = NO;
    if (aFiles == nil || [aFiles count] == 0) {
        if (aDenied != NULL) {
            *aDenied = NO;
        }
        return 0;
    }
    HSCard *firstCard = nil;
    BOOL proceed = NO;
    if (document == nil) {
        document = [self openUntitledDocumentAndDisplay:YES error:NULL];
        firstCard = [document currentCard];
        [aCards addObject:firstCard];
        proceed = YES;
    } else if ([document isNewAndNotChanged]) {
        firstCard = [document currentCard];
        [aCards addObject:firstCard];
        proceed = YES;
    } else if (![[[document stack] queryHyperInterface:@protocol(HSMutableStackAttributes)] isStackProtected]) {
        proceed = YES;
    }
    if (!proceed) {
        if (aDenied != NULL) {
            *aDenied = YES;
        }
        return 0;
    }
    NSUInteger count = [aFiles count];
    NSUndoManager *undoManager = [document undoManager];
    [undoManager disableUndoRegistration];
    HSExportProgressSheetController *progress = nil;
    if (count > 20) {
        progress = [HSExportProgressSheetController new];
        [progress setDelegate:self];
        [progress setDescription:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"ImportMoviesSheetProgressDescription" value:@"" table:@"Dialogs"]];
        [progress setProgressIndicatorIndeterminate:NO];
        [progress setProgress:0];
        [progress beginSheetForWindow:[document windowForSheet]];
    }
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    HSMovieVerifier *verifier = [[HSMovieVerifier alloc] init];
    NSUInteger index = 0;
    if (firstCard != nil) {
        NSString *file = [aFiles objectAtIndex:0];
        NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:file, QTMovieFileNameAttribute, (id)kCFBooleanFalse, QTMovieResolveDataRefsAttribute, nil];
        if (attributes != nil) {
            QTMovie *movie = [[QTMovie alloc] initWithAttributes:attributes error:NULL];
            [attributes release];
            if (movie != nil) {
                QTMovie *verified = [verifier verifyMovie:movie withOptions:0 error:NULL];
                if (movie == verified) {
                    [movie autorelease];
                } else {
                    [movie release];
                }
                if (verified != nil) {
                    NSURL *url = [NSURL fileURLWithPath:file];
                    if (url != nil) {
                        [self importMovie:verified withFileURL:url toCard:firstCard];
                        imported = 1;
                    }
                }
            }
        }
        index = 1;
    }
    for (; index < count; index++) {
        NSString *file = [aFiles objectAtIndex:index];
        if (_needCancelImportFiles) {
            break;
        }
        [pool release];
        pool = [NSAutoreleasePool new];
        if (count > 20) {
            [progress setProgress:((double)index * 100.0) / (double)count];
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
        NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:file, QTMovieFileNameAttribute, (id)kCFBooleanFalse, QTMovieResolveDataRefsAttribute, nil];
        if (attributes == nil) {
            break;
        }
        QTMovie *movie = [[QTMovie alloc] initWithAttributes:attributes error:NULL];
        [attributes release];
        if (movie != nil) {
            QTMovie *verified = [verifier verifyMovie:movie withOptions:0 error:NULL];
            if (movie == verified) {
                [movie autorelease];
            } else {
                [movie release];
            }
            if (verified != nil) {
                NSURL *url = [NSURL fileURLWithPath:file];
                HSCard *card = (url != nil) ? [HSCard defaultObject] : nil;
                if (card == nil) {
                    break;
                }
                [aCards addObject:card];
                HSStack *stack = [document stack];
                NSUInteger insertIndex = [stack indexOfHyperChild:(aCard != nil ? aCard : [document currentCard])] + 1 + (imported - (firstCard != nil ? 1 : 0));
                [stack insertHyperChild:card atIndex:insertIndex];
                [self importMovie:verified withFileURL:url toCard:card];
                imported++;
            }
        }
    }
    [verifier release];
    [pool release];
    if (!_needCancelImportFiles && imported != 0) {
        if (firstCard == nil) {
            if (registerUndo) {
                [undoManager enableUndoRegistration];
                [undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:(imported == 1 ? @"Add Item" : @"Add Items") value:@"" table:@"UndoManager"]];
                [[undoManager prepareWithInvocationTarget:self] undoImportingFilesCount:imported lastAddedCardIndex:[[document stack] indexOfHyperChild:aCard] + count];
                [undoManager disableUndoRegistration];
            }
        } else {
            [[[document selectionController] stackController] selectHyperObject:firstCard];
            [document updateChangeCount:0];
        }
        denied = NO;
    } else {
        denied = YES;
    }
    if (count > 20) {
        if (!_needCancelImportFiles) {
            [progress setProgress:100.0];
        } else {
            [self undoImportingFilesCount:imported lastAddedCardIndex:[[document stack] indexOfHyperChild:aCard] + 1];
        }
        [progress endSheet];
        [progress setDelegate:nil];
        [progress release];
    }
    [undoManager enableUndoRegistration];
    if (aDenied != NULL) {
        *aDenied = denied;
    }
    return imported;
}

- (void)importMovie:(id)aMovie withFileURL:(id)aURL asCardWithIndex:(NSUInteger)aIndex toDocument:(id)aDocument
{
    id pvVar1;

    pvVar1 = [HSCard defaultObject];
    [[aDocument stack] insertHyperChild:pvVar1 atIndex:aIndex];
    [self importMovie:aMovie withFileURL:aURL toCard:pvVar1];
}

- (void)importMovie:(id)aMovie withFileURL:(id)aURL toCard:(id)aCard
{
    NSString *name = nil;
    HSNewMedia *media;
    if ([aURL isFileURL]) {
        media = [HSNewMedia mediaWithPath:[aURL path]];
    } else {
        id displayName = [[aMovie movieAttributes] objectForKey:QTMovieDisplayNameAttribute];
        name = displayName != [NSNull null] ? displayName : nil;
        NSData *data = [aMovie movieFormatRepresentation];
        if (data == nil) {
            return;
        }
        media = [HSNewMedia mediaWithData:data name:name type:@"mov"];
    }
    if (media == nil) {
        return;
    }
    HSMovieObject *movieObject = [[[HSMovieObject alloc] initWithMedia:media error:NULL] autorelease];
    if (movieObject == nil) {
        return;
    }
    [[movieObject queryHyperInterface:@protocol(HSStartingPlayableObjectAttributes)] setHyperStartingOnClick:NO];
    NSSize cardSize = [[aCard queryHyperInterface:@protocol(HSSizeAttributes)] size];
    [movieObject stretchIfNeededToCardSize:cardSize];
    [[[movieObject queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier] moveCenterTo:NSMakePoint(cardSize.width * 0.5, cardSize.height * 0.5) withLayoutGuidingContext:nil];
    [aCard addHyperChild:movieObject];
    if ([aURL isFileURL]) {
        name = [[[aURL path] lastPathComponent] stringByDeletingPathExtension];
    }
    if (name != nil) {
        [aCard setHyperTitle:name];
    }
    [aCard hyperRefreshTitle];
    NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:HSToolEraserColorPreferencesKey];
    NSColor *color;
    if (colorData == nil) {
        color = [NSColor blackColor];
    } else {
        NSColor *white = [NSColor whiteColor];
        if (white == nil) {
            color = nil;
        } else {
            color = [NSUnarchiver unarchiveObjectWithData:colorData];
            if ([color isEqual:white]) {
                color = nil;
            }
        }
    }
    if (color != nil) {
        [aCard eraseBackgroundWithColor:color];
    }
    id actor = [aCard queryHyperInterface:@protocol(HSActor)];
    [actor replaceHyperActionsForEvent:[HSActionEvent actionEventOfType:kHSClickActionEventType] withAction:[HSNextCardAction nextCardActionWithFadeTransition]];
}

- (NSUInteger)importImageFiles:(id)aFiles orImages:(id)aImages importDenied:(BOOL *)aDenied selectedCard:(id)aCard addedCards:(id)aCards
{
    NSUInteger count = [(aFiles != nil ? aFiles : aImages) count];
    BOOL denied = NO;
    NSUInteger imported = 0;
    if ((aFiles == nil && aImages == nil) || count == 0) {
        if (aDenied != NULL) {
            *aDenied = NO;
        }
        return 0;
    }
    HSEditorDocument *document = [self currentDocument];
    HSCard *firstCard = nil;
    BOOL proceed = NO;
    if (document == nil) {
        document = [self openUntitledDocumentAndDisplay:YES error:NULL];
        firstCard = [document currentCard];
        [aCards addObject:firstCard];
        proceed = YES;
    } else if ([document isNewAndNotChanged]) {
        firstCard = [document currentCard];
        [aCards addObject:firstCard];
        proceed = YES;
    } else if (![[[document stack] queryHyperInterface:@protocol(HSMutableStackAttributes)] isStackProtected]) {
        proceed = YES;
    }
    if (!proceed || [[self currentDocument] isInPurePlayerMode]) {
        if (aDenied != NULL) {
            *aDenied = YES;
        }
        return 0;
    }
    NSUndoManager *undoManager = [document undoManager];
    [undoManager disableUndoRegistration];
    HSExportProgressSheetController *progress = nil;
    if (count > 20) {
        progress = [HSExportProgressSheetController new];
        [progress setDelegate:self];
        [progress setDescription:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"ImportImagesSheetProgressDescription" value:@"" table:@"Dialogs"]];
        [progress setProgressIndicatorIndeterminate:NO];
        [progress setProgress:0];
        [progress beginSheetForWindow:[document windowForSheet]];
    }
    NSMutableArray *names = [NSMutableArray array];
    NSMutableArray *images = [NSMutableArray array];
    if (aImages == nil) {
        for (NSUInteger i = 0; i < count; i++) {
            NSImage *image = [[NSImage alloc] initWithContentsOfFile:[aFiles objectAtIndex:i]];
            NSString *name = [aFiles objectAtIndex:i];
            if (image != nil) {
                [images addObject:image];
                [image release];
                [names addObject:name];
            }
        }
    } else {
        [images addObjectsFromArray:aImages];
        for (NSUInteger i = 0; i < count; i++) {
            [names addObject:[[aImages objectAtIndex:i] name]];
        }
    }
    NSUInteger start = 0;
    if (firstCard != nil) {
        NSSize size = NSZeroSize;
        for (NSUInteger i = 0; i < count; i++) {
            size = [[images objectAtIndex:i] hyperPixelsSize];
            if (!NSEqualSizes(size, NSZeroSize)) {
                break;
            }
        }
        if (!NSEqualSizes(size, NSZeroSize)) {
            [[document stack] setHyperCardSize:size];
        }
        [self importImage:[images objectAtIndex:0] withFileURL:[NSURL fileURLWithPath:[names objectAtIndex:0]] toDocument:document withCard:firstCard];
        [[document cardView] autosizePreservingVisibleCenter];
        start = 1;
    }
    imported = start;
    for (NSUInteger i = start; i < count && !_needCancelImportFiles; i++) {
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        if (count > 20) {
            [progress setProgress:((double)i * 100.0) / (double)count];
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
        id image = [images objectAtIndex:i];
        NSString *name = [names objectAtIndex:i];
        if (firstCard == nil) {
            if ([self importImage:image withFileURL:[NSURL fileURLWithPath:name] toDocument:document selectedCard:aCard addedCards:aCards]) {
                imported++;
            }
        } else {
            HSCard *card = [HSCard defaultObject];
            [[document stack] addHyperChild:card];
            [aCards addObject:card];
            [card fillBackgroundWithEraserColorIfNeeded];
            [self importImage:image withFileURL:[NSURL fileURLWithPath:name] toDocument:document withCard:card];
            imported++;
        }
        [pool release];
    }
    if (!_needCancelImportFiles && imported != 0) {
        if (firstCard == nil) {
            [undoManager enableUndoRegistration];
            [undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:(imported == 1 ? @"Add Item" : @"Add Items") value:@"" table:@"UndoManager"]];
            [[undoManager prepareWithInvocationTarget:self] undoImportingFilesCount:imported lastAddedCardIndex:[[document stack] indexOfHyperChild:aCard] + count];
            [undoManager disableUndoRegistration];
        } else {
            [[[document selectionController] stackController] selectHyperObject:firstCard];
            [document updateChangeCount:0];
        }
        denied = NO;
    } else {
        denied = YES;
    }
    if (count > 20) {
        if (!_needCancelImportFiles) {
            [progress setProgress:100.0];
        } else {
            [self undoImportingFilesCount:imported lastAddedCardIndex:[[document stack] indexOfHyperChild:aCard] + 1];
        }
        [progress endSheet];
        [progress setDelegate:nil];
        [progress release];
    }
    [undoManager enableUndoRegistration];
    if (aDenied != NULL) {
        *aDenied = denied;
    }
    return imported;
}

- (BOOL)importImage:(id)aImage withFileURL:(id)aURL toDocument:(id)aDocument
{
    return (BOOL)[self importImage:aImage withFileURL:aURL toDocument:aDocument selectedCard:nil addedCards:nil];
}

- (void)importImage:(id)aImage withFileURL:(id)aURL asCardWithIndex:(NSUInteger)aIndex toDocument:(id)aDocument
{
    HSCard *card = [HSCard defaultObject];
    [[aDocument stack] insertHyperChild:card atIndex:aIndex];
    HSCard *previous = (aIndex == 0) ? nil : [[aDocument stack] hyperChildAtIndex:aIndex - 1];
    if ([previous isGroupCard]) {
        [card makeGroupCardWithGroupUID:[previous cardGroupUID]];
    } else {
        [card fillBackgroundWithEraserColorIfNeeded];
    }
    [self importImage:aImage withFileURL:aURL toDocument:aDocument withCard:card];
}

- (BOOL)importImage:(id)aImage withFileURL:(id)aURL toDocument:(id)aDocument selectedCard:(id)aCard addedCards:(id)aCards
{
    HSEditorDocument *document = aDocument;
    HSCard *card;
    if (document == nil) {
        document = [self openUntitledDocumentAndDisplay:YES error:NULL];
        card = [document currentCard];
    } else {
        card = [HSCard defaultObject];
    }
    [aCards addObject:card];
    HSStack *stack = [document stack];
    NSUInteger index = [stack indexOfHyperChild:(aCard != nil ? aCard : [document currentCard])] + 1;
    [stack insertHyperChild:card atIndex:index];
    if ([aCard isGroupCard]) {
        [card makeGroupCardWithGroupUID:[aCard cardGroupUID]];
    }
    [card fillBackgroundWithEraserColorIfNeeded];
    [self importImage:aImage withFileURL:aURL toDocument:document withCard:card];
    return YES;
}

- (void)importImage:(id)aImage withFileURL:(id)aURL toDocument:(id)aDocument withCard:(id)aCard
{
    NSString *name = [aURL isFileURL] ? [[[aURL path] lastPathComponent] stringByDeletingPathExtension] : [aImage name];
    if (name != nil) {
        [aCard setHyperTitle:name];
    }
    [aCard hyperRefreshTitle];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:HSImportImageAsBackgroundKey] && ![aCard isGroupCard]) {
        [self importImage:aImage withFileURL:aURL toBackgroundOfCard:aCard];
    } else {
        id media = [aURL isFileURL] ? [HSNewMedia mediaWithPath:[aURL path]] : [HSNewMedia mediaWithImage:aImage];
        if (media == nil) {
            return;
        }
        HSImageObject *object = [[HSImageObject alloc] initWithMedia:media];
        if (object == nil) {
            return;
        }
        [[object queryHyperInterface:@protocol(HSMutableShadowAttributes)] setHyperShadowEnabled:[defaults boolForKey:HSImportImageWithShadowKey]];
        id applier = [[object queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
        if (applier != nil) {
            NSSize cardSize = [[aDocument stack] hyperCardSize];
            NSSize pixelsSize = [aImage hyperPixelsSize];
            NSRect frame = NSZeroRect;
            id layout = [defaults objectForKey:HSImportedImageLayoutKey];
            NSInteger layoutValue = (layout != nil) ? [layout intValue] : 3;
            switch (layoutValue) {
                case 0:
                    frame.size = pixelsSize;
                    frame.origin.x += (cardSize.width * 0.5 + 0) - (pixelsSize.width * 0.5 + 0);
                    frame.origin.y += (cardSize.height * 0.5 + 0) - (pixelsSize.height * 0.5 + 0);
                    break;
                case 1:
                case 2: {
                    CGFloat aspect = pixelsSize.width / pixelsSize.height;
                    CGFloat cardAspect = cardSize.width / cardSize.height;
                    BOOL heightFills = (layoutValue == 1) ? (aspect <= cardAspect) : (cardAspect <= aspect);
                    if (heightFills) {
                        frame.size.width = aspect * cardSize.height;
                        frame.size.height = cardSize.height;
                    } else {
                        frame.size.height = cardSize.width / aspect;
                        frame.size.width = cardSize.width;
                    }
                    frame.origin.y = (cardSize.height * 0.5) - (frame.size.height * 0.5);
                    frame.origin.x = (cardSize.width * 0.5) - (frame.size.width * 0.5);
                    break;
                }
                case 3:
                default:
                    if (layoutValue != 3) {
                        frame = NSZeroRect;
                        break;
                    }
                    if (cardSize.width < pixelsSize.width || cardSize.height < pixelsSize.height) {
                        CGFloat aspect = pixelsSize.width / pixelsSize.height;
                        if (aspect <= cardSize.width / cardSize.height) {
                            frame.size.width = aspect * cardSize.height;
                            frame.size.height = cardSize.height;
                        } else {
                            frame.size.height = cardSize.width / aspect;
                            frame.size.width = cardSize.width;
                        }
                    } else {
                        frame.size = pixelsSize;
                    }
                    frame.origin.y = (cardSize.height * 0.5) - (frame.size.height * 0.5);
                    frame.origin.x = (cardSize.width * 0.5) - (frame.size.width * 0.5);
                    break;
            }
            [applier resizeFrameTo:frame.size aboutRelativePoint:NSZeroPoint followResizingScalingPreference:YES maintainAspectRatio:2 byAspectRatioMaintainingRule:0 withLayoutGuidingContext:nil];
            [applier moveFrameBoundingRectOriginTo:NSMakePoint(roundf(frame.origin.x), roundf(frame.origin.y)) withLayoutGuidingContext:nil];
            NSString *comments = (aURL == nil) ? nil : [HSEditorCardViewDragHelper commentsForDroppedObjectWithURL:aURL];
            if ([comments length] != 0) {
                [[object queryHyperInterface:@protocol(HSCommentsAttributes)] setHyperComments:[[comments copy] autorelease]];
            }
        }
        if ([defaults boolForKey:HSImportImageWithGoogleMapsConnectionKey]) {
            NSDictionary *gps = [[object media] GPSDictionary];
            id latitude;
            id longitude;
            if (gps != nil && (latitude = [gps objectForKey:(id)kCGImagePropertyGPSLatitude]) != nil && (longitude = [gps objectForKey:(id)kCGImagePropertyGPSLongitude]) != nil) {
                NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/?q=%@,%@&spn=0.05,0.05&t=h&om=1&hl=en", latitude, longitude];
                NSURL *mapsURL = (urlString != nil) ? [NSURL URLWithString:urlString] : nil;
                id action = (mapsURL != nil) ? [HSGoToURLAction actionWithURL:mapsURL] : nil;
                if (action != nil) {
                    [[object queryHyperInterface:@protocol(HSActor)] addHyperAction:action forEvent:[HSActionEvent actionEventOfType:kHSClickActionEventType]];
                }
            }
        }
        [aCard addHyperChild:object];
        [object release];
    }
    if (![aCard isGroupCard]) {
        [[aCard queryHyperInterface:@protocol(HSActor)] replaceHyperActionsForEvent:[HSActionEvent actionEventOfType:kHSClickActionEventType] withAction:[HSNextCardAction nextCardActionWithFadeTransition]];
    }
}

- (void)importImage:(id)aImage withFileURL:(id)aURL toBackgroundOfCard:(id)aCard
{
    NSInteger option = 6;
    id layout = [[NSUserDefaults standardUserDefaults] objectForKey:HSImportedImageLayoutKey];
    if (layout != nil) {
        switch ([layout intValue]) {
            case 1: option = 0; break;
            case 2: option = 2; break;
            case 3: option = 6; break;
            default: option = 4; break;
        }
    }
    [aCard importBackgroundFromImage:aImage imageScalingOption:option eraseBackground:YES];
    NSString *comments = (aURL == nil) ? nil : [HSEditorCardViewDragHelper commentsForDroppedObjectWithURL:aURL];
    if ([comments length] != 0) {
        [[aCard queryHyperInterface:@protocol(HSCommentsAttributes)] setHyperComments:[[comments copy] autorelease]];
    }
}

- (BOOL)canImportFileAtPath:(id)aPath showAlert:(BOOL)aAlert
{
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[aPath stringByResolvingSymlinksInPath] error:NULL];
    if (attributes == nil) {
        return NO;
    }
    if ([attributes fileSize] <= INT_MAX) {
        return YES;
    }
    if (aAlert) {
        NSAlert *alert = [[[NSAlert alloc] init] autorelease];
        HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
        NSString *title = [provider localizedStringForKey:@"HSCannotAddFileTitle" value:@"" table:@"Alerts"];
        NSString *text = [provider localizedStringForKey:@"HSCannotAddFileText" value:@"" table:@"Alerts"];
        NSString *button = [provider localizedStringForKey:@"OK" value:@"" table:@"Alerts"];
        if (alert != nil && title != nil && text != nil && button != nil) {
            [alert setMessageText:title];
            [alert setInformativeText:text];
            [alert addButtonWithTitle:button];
            [alert runModal];
        }
    }
    return NO;
}

- (BOOL)shouldCancelWindowRestoration
{
    return ![self HSEditorController_validateApplicationLicenseWithInteraction:NO forced:NO];
}

- (void)chooseFilesForImportWithFiles:(id)aFiles images:(id *)aImages movies:(id *)aMovies otherMediaOrText:(id *)aText
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    NSMutableArray *expanded = [NSMutableArray new];
    for (NSString *path in aFiles) {
        BOOL isDirectory = NO;
        if (![fileManager fileExistsAtPath:path isDirectory:&isDirectory]) {
            continue;
        }
        if (isDirectory) {
            NSString *type = [self typeForContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
            if (![type isEqualToString:@"HSKeynoteDocumentType"] && ![workspace isFilePackageAtPath:path]) {
                NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:path];
                NSString *relativePath;
                while ((relativePath = [enumerator nextObject]) != nil) {
                    if (![[relativePath substringToIndex:1] isEqualToString:@"."]) {
                        NSString *fullPath = [path stringByAppendingPathComponent:relativePath];
                        BOOL isSubdirectory = NO;
                        if ([fileManager fileExistsAtPath:fullPath isDirectory:&isSubdirectory] && !isSubdirectory) {
                            [expanded addObject:fullPath];
                        }
                    }
                }
                continue;
            }
        }
        if (!isDirectory) {
            [expanded addObject:path];
        }
    }
    NSMutableArray *images = nil;
    NSMutableArray *movies = nil;
    NSMutableArray *otherMediaOrText = nil;
    for (NSString *path in expanded) {
        NSString *extension = [path pathExtension];
        if ([extension compare:@"rtfd" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:path];
            NSString *relativePath;
            while ((relativePath = [enumerator nextObject]) != nil) {
                NSString *fullPath = [path stringByAppendingPathComponent:relativePath];
                BOOL isSubdirectory = NO;
                if ([fileManager fileExistsAtPath:fullPath isDirectory:&isSubdirectory] && isSubdirectory) {
                    [enumerator skipDescendents];
                    continue;
                }
                if (![[relativePath substringToIndex:1] isEqualToString:@"."] && ![workspace isFileImageAtPath:fullPath] && [workspace isFileMediaOrTextAtPath:fullPath]) {
                    if (otherMediaOrText == nil) {
                        otherMediaOrText = [[NSMutableArray new] autorelease];
                    }
                    [otherMediaOrText addObject:fullPath];
                }
            }
            continue;
        }
        if ([workspace isFileImageAtPath:path] && [extension compare:@"pdf" options:NSCaseInsensitiveSearch] != NSOrderedSame) {
            if (images == nil) {
                images = [[NSMutableArray new] autorelease];
            }
            [images addObject:path];
        } else if ([workspace isFileMovieAtPath:path]) {
            if (movies == nil) {
                movies = [[NSMutableArray new] autorelease];
            }
            [movies addObject:path];
        } else if ([workspace isFileMediaOrTextAtPath:path] || [extension isEqualToString:@"kmz"] || [extension isEqualToString:@"kml"]) {
            if (otherMediaOrText == nil) {
                otherMediaOrText = [[NSMutableArray new] autorelease];
            }
            [otherMediaOrText addObject:path];
        }
    }
    [expanded release];
    if (aImages != NULL) {
        *aImages = images;
    }
    if (aMovies != NULL) {
        *aMovies = movies;
    }
    if (aText != NULL) {
        *aText = otherMediaOrText;
    }
}

- (void)openSelection:(id)aSelection userData:(id)aData error:(id *)aError
{
    HSEditorDocument *originalDocument = [self currentDocument];
    HSEditorDocument *document;
    HSCard *card;
    if (originalDocument == nil) {
        document = [self openUntitledDocumentAndDisplay:YES error:NULL];
        card = [document currentCard];
    } else {
        card = [HSCard defaultObject];
        HSStack *stack = [originalDocument stack];
        [stack insertHyperChild:card atIndex:[stack indexOfHyperChild:[originalDocument currentCard]]];
        document = originalDocument;
    }
    NSURL *url = nil;
    if ([[aSelection types] containsObject:NSPasteboardTypeString]) {
        url = [[NSURL alloc] initWithString:[aSelection stringForType:NSPasteboardTypeString]];
    }
    id actor;
    id event;
    BOOL addNextCard = NO;
    NSImage *image = nil;
    if ([[url scheme] length] != 0) {
        image = [[NSImage alloc] initWithContentsOfURL:url];
    }
    if (image != nil) {
        [self importImage:image withFileURL:url toDocument:document withCard:card];
        [image release];
        actor = [card queryHyperInterface:@protocol(HSActor)];
        event = [HSActionEvent actionEventOfType:kHSClickActionEventType];
        addNextCard = YES;
    } else {
        id cardView = [document cardView];
        [cardView setCard:card];
        [cardView readSelectionFromPasteboard:aSelection useDragPreferences:YES];
        actor = [card queryHyperInterface:@protocol(HSActor)];
        event = [HSActionEvent actionEventOfType:kHSClickActionEventType];
        addNextCard = [actor hyperActionOfType:[HSOpenLocationAction actionType] forEvent:event] == nil
            && [actor hyperActionOfType:[HSGoToURLAction actionType] forEvent:event] == nil;
    }
    [url release];
    if (addNextCard) {
        [actor addHyperAction:[HSNextCardAction nextCardActionWithFadeTransition] forEvent:event];
    }
    if (originalDocument == nil) {
        [[self currentDocument] testCard:nil];
    }
}

- (void)applicationWillTerminate:(id)aTerminate
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HSPreserveToolsSettings"]) {
        [[[HSToolManager sharedToolManager] toolSettings] saveToolsSettingsToDefaults];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSContextHelpModeDidActivateNotification object:nil];
    [_applicationLicensor release];
    _applicationLicensor = nil;
    [[HSObjectAssistantController sharedAssistantController] setSelectedInModelObject:nil];
    [super applicationWillTerminate:aTerminate];
}

- (BOOL)applicationOpenUntitledFile:(id)aFile
{
    _applicationOpenUntitledFilePending = NO;
    BOOL result = [super applicationOpenUntitledFile:aFile];
    NSInteger action = [[NSUserDefaults standardUserDefaults] integerForKey:HSStartupActionKey];
    if (!result && action == 0) {
        result = [[self defaultNavigationControllerClass] goToHomeStack];
    }
    return result;
}

- (BOOL)applicationShouldOpenUntitledFile:(id)aFile
{
    if (![super applicationShouldOpenUntitledFile:aFile] || [self resolvingError]) {
        return NO;
    }
    if (!_applicationWillFinishCriticalLaunching) {
        return YES;
    }
    _applicationOpenUntitledFilePending = YES;
    return NO;
}

- (void)applicationDidFinishLaunching:(id)aLaunching
{
    BOOL showedEULA = [self shouldShowEULA];
    if (showedEULA) {
        [self showEULAAppModalDialog];
    }
    [[HSSubmitRequest sharedInstance] submitInformationDictionary:nil];
    [self HSEditorController_validateApplicationLicenseWithInteraction:YES forced:NO];
    [[HSSplashScreenWindowController sharedSplashWindow] showSplashWithMinimalTimeout:3.0];
    _applicationWillFinishCriticalLaunching = NO;
    [self configureObjectsMenu];
    [self HSEditorController_setMenuVisible:YES];
    if (_filesToOpen != nil) {
        [self application:NSApp openFiles:_filesToOpen];
        [_filesToOpen release];
        _filesToOpen = nil;
    } else if ([[self documents] count] == 0 && (_applicationOpenUntitledFilePending || showedEULA)
               && ![self applicationOpenUntitledFile:NSApp]) {
        [self newDocument:nil];
    }
    [super applicationDidFinishLaunching:aLaunching];
    [self setAutosaving];
    HSEditorDocument *document = [self currentDocument];
    BOOL show = document != nil && ![document isStackProtected] && ![document isInPurePlayerMode];
    [[HSLibraryController sharedLibraryController] showLibraryIfNeededByDefault:show];
    [[HSToolPaletteController sharedInstance] showPaletteIfNeededByDefault:show];
    [[HSLayoutPaletteController sharedInstance] showPaletteIfNeededByDefault:show];
    [[HSObjectListPaletteController sharedInstance] showPaletteIfNeededByDefault:show];
    [[HSCommentsAndAttributionsPaletteController sharedInstance] showPaletteIfNeededByDefault:YES];
    [[HSShortcutsPaletteController sharedInstance] showPaletteIfNeededByDefault:YES];
    [[HSUpdater sharedUpdater] automaticCheckForUpdates];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextHelpModeDidActivate:) name:NSContextHelpModeDidActivateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSEditorController_HSUIModeSettingsDidChangeNotification:) name:HSUIModeSettingsDidChangeNotification object:[HSUI sharedUI]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSEditorController_HSUIModeSettingsDidChangeNotification:) name:HSUIModeDidChangeNotification object:[HSUI sharedUI]];
    [NSApp setServicesProvider:self];
    [[HSSplashScreenWindowController sharedSplashWindow] hideSplashWaitUntilTimeout:YES];
    [HSCrayonsView setDefaultDataSourceClass:[HSSystemCrayonsDataSource class]];
}

- (void)applicationWillFinishLaunching:(id)aLaunching
{
    _applicationWillFinishCriticalLaunching = YES;
    [[HSExecutableResourceProvider sharedInstance] setExecutableBundle:[NSBundle bundleForClass:[self class]]];
    [super applicationWillFinishLaunching:aLaunching];
    [HSObjectAssistantController sharedAssistantController];
    [HSCoachingHelpManager sharedCoachingHelpManager];
}

- (id)applicationDefaults
{
    id pvVar1_2;

    pvVar1_2 = [HSDefaultWindowsLayoutManager windowsLayoutManagerWithDefaults:[super applicationDefaults]];
    [pvVar1_2 applySmartDefaultWindowsLayout];
    return [pvVar1_2 defaults];
}

- (void)documentProtectionDidChange:(id)aChange
{
    [self updateOnDocumentProtectionChange];
}

- (void)updateOnDocumentProtectionChange
{
    HSEditorDocument *document = [self currentDocument];
    BOOL protected = [document isStackProtected];
    BOOL pure = [document isInPurePlayerMode];
    if (protected) {
        if (!pure) {
            [document enterPurePlayerModeWithAnimation:YES];
        }
    } else if (pure && ![self replacingDocument]) {
        [document exitPurePlayerModeWithAnimation:YES];
    }
    [self updateToolDeviceAndLibraryOnDocumentProtectionChange];
}

- (void)updateToolDeviceAndLibraryOnDocumentProtectionChange
{
    if (![[self currentDocument] isStackProtected] && ![[self currentDocument] isInPurePlayerMode]) {
        [[HSLibraryController sharedLibraryController] showLibraryIfNeededByDefault:YES];
        [[HSToolPaletteController sharedInstance] showPaletteIfNeededByDefault:YES];
        return;
    }
    if ([[HSLibraryController sharedLibraryController] isLibraryVisible]) {
        [[[HSLibraryController sharedLibraryController] window] hyperOrderOutWithSavingVisibilityState:self];
    }
    if ([[HSToolPaletteController sharedInstance] isPaletteVisible]) {
        [[[HSToolPaletteController sharedInstance] window] hyperOrderOutWithSavingVisibilityState:self];
    }
}

- (id)openUntitledDocumentAndDisplay:(BOOL)aDisplay error:(id *)aError
{
    HSEditorDocument *current = [self currentDocument];
    if (current != nil) {
        [HSStack setNewStackCardSize:[[current stack] hyperCardSize]];
    }
    id document = [super openUntitledDocumentAndDisplay:aDisplay error:aError];
    if (document != nil && document != current) {
        [[HSLibraryController sharedLibraryController] showLibraryIfNeededByDefault:YES];
        [[HSToolPaletteController sharedInstance] showPaletteIfNeededByDefault:YES];
        [[HSLayoutPaletteController sharedInstance] showPaletteIfNeededByDefault:YES];
        [[HSObjectListPaletteController sharedInstance] showPaletteIfNeededByDefault:YES];
        [[HSCommentsAndAttributionsPaletteController sharedInstance] showPaletteIfNeededByDefault:YES];
        [[HSShortcutsPaletteController sharedInstance] showPaletteIfNeededByDefault:YES];
    }
    [HSStack setNewStackCardSize:NSZeroSize];
    return document;
}

- (void)setAutosaving
{
    NSTimeInterval delay = 0.0;
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:HSAutoSaveOnKey] intValue] == 1) {
        delay = [[[NSUserDefaults standardUserDefaults] objectForKey:HSAutoSavePeriodKey] intValue] * 60;
    }
    [self setAutosavingDelay:delay];
}

- (void)removeDocument:(id)aDocument
{
    [[HSCoachingHelpManager sharedCoachingHelpManager] removeStack:[aDocument stack]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HSDocumentDidChangeProtectionNotification object:aDocument];
    [super removeDocument:aDocument];
}

- (void)addDocument:(id)aDocument
{
    [super addDocument:aDocument];
    [[HSCoachingHelpManager sharedCoachingHelpManager] addStack:[aDocument stack]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentProtectionDidChange:) name:HSDocumentDidChangeProtectionNotification object:aDocument];
    if (!_replacingDocument) {
        [self updateToolDeviceAndLibraryOnDocumentProtectionChange];
    }
    if ([aDocument respondsToSelector:@selector(openWarning)]) {
        id warning = [aDocument openWarning];
        if (warning != nil) {
            [[HSErrorManager sharedErrorManager] presentError:warning];
        }
    }
}

- (void)HSEditorController_HSUIModeSettingsDidChangeNotification:(id)aNotification
{
    if (*(int *)&_documentInEditor == 0) {
        [self HSEditorController_setMenuVisible:YES];
        [[HSBackgroundWindowController backgroundWindowController] validateAndDisplay:YES];
    }
}

- (void)HSEditorController_setMenuVisible:(BOOL)aVisible
{
    int uVar2;
    id pvVar1_3;

    if ([[HSSystemUI sharedSystemUI] menuBarVisible] != aVisible) {
        pvVar1_3 = [HSSystemUI sharedSystemUI];
        if (aVisible != NO) {
            uVar2 = 0;
        }
        else {
            uVar2 = 4;
        }
        [pvVar1_3 setupWithMode:uVar2 options:(unsigned int)(aVisible == NO)];
    }
}

- (void)configureObjectsMenu
{
    NSMenu *mainMenu = [NSApp mainMenu];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HSWebObjectUIEnabled"]) {
        NSMenu *submenu = [[mainMenu itemAtIndex:[mainMenu indexOfItemWithTag:6]] submenu];
        [submenu removeItem:[submenu itemAtIndex:[submenu indexOfItemWithTag:0x40]]];
    }
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HSExportToIPadEnabled"]) {
        NSMenuItem *item = [[[mainMenu itemWithTag:3] submenu] itemWithTag:6];
        [[item menu] removeItem:item];
    }
}

- (BOOL)lastTextFieldTamerThisCard
{
    return sLastTextFieldTamerThisCard;
}

- (void)setLastTextFieldTamerThisCard:(BOOL)aCard
{
    sLastTextFieldTamerThisCard = aCard;
}

- (BOOL)lastTextFieldTamerReadyOnly
{
    return sLastTextFieldTamerReadOnly;
}

- (void)setLastTextFieldTamerReadOnly:(BOOL)aOnly
{
    sLastTextFieldTamerReadOnly = aOnly;
}

- (BOOL)hasEditedDocuments
{
    if ([super hasEditedDocuments]) {
        return YES;
    }
    for (id document in [self documents]) {
        if ([[document actionExecutionContext] isRecording] || [document isInHyperCastingMode]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)documentInEditor
{
    return _documentInEditor;
}

- (void)setDocumentInEditor:(BOOL)aEditor
{
    _documentInEditor = aEditor;
}

- (BOOL)replacingDocument
{
    return _replacingDocument;
}

- (BOOL)shouldBeDocumentOpenedInEditorMode
{
    BOOL bVar2;

    if (![self documentInEditor]) {
        if (_windowsOwnerDocument == nil) {
            bVar2 = NO;
        }
        else {
            bVar2 = ![_windowsOwnerDocument isInPlayerMode];
        }
    }
    else {
        bVar2 = YES;
    }
    return bVar2;
}

- (id)openDocumentWithContentsOfURL:(id)aURL inWindowOfDocument:(id)aDocument error:(id *)aError
{
    _replacingDocument = YES;
    _windowsOwnerDocument = aDocument;
    id currentController = [aDocument currentWindowController];
    if (currentController == [aDocument purePlayerWindowControllerCreateIfNeeded:NO]) {
        _sharedPurePlayerWindowController = [currentController retain];
    } else if (currentController == [aDocument presentationWindowControllerCreateIfNeeded:NO]) {
        _sharedPresentationWindowController = [currentController retain];
    }
    _sharedPlayerInEditorWindowController = [[aDocument playerInEditorWindowController] retain];
    if ([aDocument isInPurePlayerMode] || [aDocument isInPresentationMode]) {
        _documentsInPurePlayerAndPresentationModesCount++;
    }
    BOOL wasProtected = [aDocument isStackProtected];
    id document = [super openDocumentWithContentsOfURL:aURL inWindowOfDocument:aDocument error:aError];
    _replacingDocument = NO;
    if (document == nil || document == aDocument) {
        [self sharedPLayerInEditorWindowControllerHandled];
        [self sharedPurePlayerWindowControllerHandled];
        [self sharedPresentationWindowControllerHandled];
        if ([aDocument isInPurePlayerMode] || [aDocument isInPresentationMode]) {
            _documentsInPurePlayerAndPresentationModesCount--;
        }
    } else {
        [document loadWindows];
        if (wasProtected != [document isStackProtected]) {
            NSTimeInterval duration = [[aDocument navigationController] transitionDurationForCurrentNavigationOperation];
            if ([[aDocument navigationController] currentNavigationOperation] != nil && duration != 0.0) {
                [self performSelector:@selector(updateOnDocumentProtectionChange) withObject:nil afterDelay:duration];
            } else {
                [self updateOnDocumentProtectionChange];
            }
        }
    }
    _windowsOwnerDocument = nil;
    return document;
}

- (void)applicationDidReplaceDocumentWithDocument:(id)aDocument
{
    id pvVar1_2;

    pvVar1_2 = [[aDocument mainWindowController] cardView];
    [[aDocument selectionSync] setCardView:pvVar1_2];
    [[aDocument selectionSync] setEnabled:YES];
    [[aDocument selectionController] setEnabled:YES];
    [[HSBackgroundWindowController backgroundWindowController] validateAndDisplay:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSDocumentDidActivateObjectListDataProviderNotification" object:aDocument];
}

- (void)sharedPresentationWindowControllerHandled
{
    [_sharedPresentationWindowController release];
    _sharedPresentationWindowController = nil;
}

- (id)sharedPresentationWindowController
{
    return _sharedPresentationWindowController;
}

- (void)sharedPurePlayerWindowControllerHandled
{
    [_sharedPurePlayerWindowController release];
    _sharedPurePlayerWindowController = nil;
}

- (id)sharedPurePlayerWindowController
{
    return _sharedPurePlayerWindowController;
}

- (void)sharedPLayerInEditorWindowControllerHandled
{
    [_sharedPlayerInEditorWindowController release];
    _sharedPlayerInEditorWindowController = nil;
}

- (id)sharedPlayerInEditorWindowController
{
    return _sharedPlayerInEditorWindowController;
}

- (Class)remoteHyperDocumentClass
{
    return [HSEditorDocument class];
}

- (void)documentEnteredPurePlayerMode:(BOOL)aMode
{
    int iVar1;

    iVar1 = *(int *)&_documentInEditor;
    if (aMode == NO) {
        *(int *)&_documentInEditor = iVar1 + -1;
        if (iVar1 + -1 == 0) {
            [self HSEditorController_HSUIModeSettingsDidChangeNotification:nil];
        }
    }
    else {
        if (iVar1 == 0) {
            [[HSBackgroundWindowController backgroundWindowController] validateAndDisplay:YES];
            iVar1 = *(int *)&_documentInEditor;
        }
        *(int *)&_documentInEditor = iVar1 + 1;
    }
}

- (BOOL)areDocumentSpecificPresentationSettingsActive
{
    return *(int *)&_documentInEditor != 0;
}

- (BOOL)supportsHomeStack
{
    return YES;
}

- (Class)defaultNavigationControllerClass
{
    return [HSEditorNavigationController class];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _onionSkinMode = 0;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_sharedPlayerInEditorWindowController release];
    [_sharedPurePlayerWindowController release];
    [_sharedPresentationWindowController release];
    [_applicationLicensor release];
    [_filesToOpen release];
    [super dealloc];
}

- (BOOL)addReadyMadeCardsFromPath:(id)aPath alwaysCreateNewDocument:(BOOL)aNew
{
    NSError *error = nil;
    HSEditorDocument *currentDocument = [self currentDocument];
    BOOL needsNewDocument = currentDocument == nil || aNew;
    HSEditorDocument *readDocument;
    HSEditorDocument *document;
    if (needsNewDocument) {
        readDocument = [[self openUntitledDocumentAndDisplay:NO error:&error] retain];
        document = readDocument;
    } else {
        readDocument = [[HSEditorDocument alloc] init];
        document = currentDocument;
    }
    NSString *type = [self typeForContentsOfURL:[NSURL fileURLWithPath:aPath] error:&error];
    BOOL success = NO;
    if (error == nil) {
        success = [readDocument readFromURL:[NSURL fileURLWithPath:aPath] ofType:type error:&error];
    }
    if (error == nil && success) {
        [[document undoManager] setMultipleActionsName:[[NSBundle mainBundle] localizedStringForKey:@"Add Ready Made Cards" value:@"" table:@"UndoManager"]];
        BOOL isNewAndNotChanged = [document isNewAndNotChanged];
        HSStack *documentStack = [document stack];
        if (needsNewDocument) {
            documentStack = [document createDefaultStack];
        }
        HSStack *sizedStack;
        HSEditorDocument *sizeSource;
        if (!isNewAndNotChanged) {
            sizedStack = [readDocument stack];
            sizeSource = document;
        } else {
            [documentStack removeHyperAllChildren];
            sizedStack = documentStack;
            sizeSource = readDocument;
        }
        [sizedStack setHyperCardSize:[[sizeSource stack] hyperCardSize]];
        if (!needsNewDocument) {
            NSMutableArray *cardDictionaries = [NSMutableArray array];
            NSMutableSet *mediaUIDs = [NSMutableSet set];
            for (id card in [[readDocument stack] hyperChildren]) {
                if ([card hyperTitle] == nil || [[card hyperTitle] isEqualToString:@""]) {
                    [card setHyperTitle:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"HSReadyMadeCardsDefaultTitle" value:@"" table:@"Localizable"]];
                }
                [cardDictionaries addObject:[card fullDictionaryRepresentation]];
                [mediaUIDs unionSet:[[card queryHyperInterface:@protocol(HSMediaCopySupport)] mediaUIDs]];
            }
            NSDictionary *serialized = [NSDictionary dictionaryWithObjectsAndKeys:cardDictionaries, @"HSSerializedCardsKey", [[mediaUIDs allObjects] extraPlistRepresentation], @"HSSerializedCardsMediaUIDsKey", nil];
            NSUInteger insertIndex = 0;
            if ([[document editorWindowController] selectedCard] == nil) {
                if ([[self activeCard] hyperIndex] != NSNotFound) {
                    insertIndex = [[self activeCard] hyperIndex] + 1;
                }
            } else if ([[[document editorWindowController] selectedCard] hyperIndex] != NSNotFound) {
                insertIndex = [[[document editorWindowController] selectedCard] hyperIndex] + 1;
            }
            NSArray *inserted = [documentStack insertCards:serialized atIndex:insertIndex];
            if ([inserted count] != 0) {
                [[document mainWindowController] setActiveCard:[inserted objectAtIndex:0]];
            }
        } else {
            [self addDocument:readDocument];
            [readDocument makeWindowControllers];
            [readDocument showWindows];
            [readDocument updateChangeCount:NSChangeDone];
            [[readDocument undoManager] removeAllActions];
        }
    } else {
        if ([error code] == 0x4e36) {
            HSAlert *alert = [HSAlert new];
            [alert setMessageText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Cannot create a Ready Made Card" value:@"" table:@"Alerts"]];
            [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"There is not enough disk space to add a Ready Made Card to your stack. Free some disk space and try again." value:@"" table:@"Alerts"]];
            [alert runModal];
            [alert release];
        }
        if (readDocument != nil && (currentDocument == nil || aNew)) {
            [readDocument close];
        }
    }
    [readDocument release];
    return success;
}

- (void)application:(id)aApplication openFiles:(id)aFiles
{
    if (![self isApplicationLaunchFinished]) {
        [self setFilesToOpen:aFiles];
        return;
    }
    NSNumber *writable = [NSNumber numberWithBool:NO];
    [[[self currentDocument] fileURL] getResourceValue:&writable forKey:NSURLIsWritableKey error:nil];
    if ([writable boolValue]) {
        [self application:aApplication shouldOpenFiles:aFiles];
    } else {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(application:shouldOpenFiles:)]];
        [invocation setTarget:self];
        [invocation setSelector:@selector(application:shouldOpenFiles:)];
        [invocation setArgument:&aApplication atIndex:2];
        [invocation setArgument:&aFiles atIndex:3];
        [invocation retainArguments];
        [invocation performSelector:@selector(invoke) withObject:nil afterDelay:0];
    }
}

- (void)application:(id)aApplication shouldOpenFiles:(id)aFiles
{
    NSError *error = nil;
    NSInteger reply = 1;
    if (![self isApplicationLaunchFinished]) {
        reply = 1;
    } else if ([aFiles count] == 0) {
        reply = 0;
    } else if ([self isModalSessionPresent] || (![self isMultiDocument] && [[[self currentDocument] mainWindowController] isSheetRunning])) {
        reply = 1;
    } else {
        _applicationWillFinishCriticalLaunching = NO;
        NSArray *images = nil;
        NSArray *movies = nil;
        NSArray *otherFiles = nil;
        HSEditorDocument *document = [self currentDocument];
        BOOL isNewAndNotChanged = [document isNewAndNotChanged];
        NSSize cardSize = NSZeroSize;
        if (isNewAndNotChanged) {
            cardSize = [[document stack] hyperCardSize];
        }
        NSUInteger importedImages = 0;
        NSUInteger importedMovies = 0;
        NSUInteger importedOther = 0;
        BOOL denied = YES;
        if (![document isModalSessionPresent]) {
            [self chooseFilesForImportWithFiles:aFiles images:&images movies:&movies otherMediaOrText:&otherFiles];
            if (([images count] != 0 || [movies count] != 0 || [otherFiles count] != 0) && ![document isStackProtected] && ([document isInPlayerMode] || [document isInPresentationMode])) {
                [document switchToEditor:YES];
            }
            BOOL importDenied = NO;
            id selectedCard = [document isInStoryboardMode] ? [[[document selectionController] storyboardView] activeCard] : [document currentCard];
            NSMutableArray *addedCards = [NSMutableArray new];
            importedImages = [self importImageFiles:images orImages:nil importDenied:&importDenied selectedCard:selectedCard addedCards:addedCards];
            if (importDenied) {
                importedMovies = 0;
                importedOther = 0;
                NSBeep();
            } else {
                importedMovies = [self importMovieFiles:movies importDenied:&importDenied selectedCard:selectedCard addedCards:addedCards];
                if (importDenied) {
                    importedOther = 0;
                    NSBeep();
                } else {
                    importedOther = [self importMediaOrTextFiles:otherFiles importDenied:&importDenied selectedCard:selectedCard addedCards:addedCards];
                    if (importDenied) {
                        NSBeep();
                    } else if ([addedCards count] != 0) {
                        NSUndoManager *undoManager = [[self currentDocument] undoManager];
                        [undoManager disableUndoRegistration];
                        NSUInteger firstIndex = 0;
                        if (selectedCard != nil && !isNewAndNotChanged) {
                            firstIndex = [[document stack] indexOfHyperChild:selectedCard] + 1;
                        }
                        HSStack *stack = [[self currentDocument] stack];
                        NSArray *sorted = [addedCards sortedArrayUsingFunction:HSSortHyperCardsByTitle context:NULL];
                        NSUInteger count = [addedCards count];
                        for (NSUInteger index = 0; index < count; index++) {
                            [[document stack] setIndex:firstIndex + index ofHyperChild:[sorted objectAtIndex:index]];
                        }
                        [undoManager enableUndoRegistration];
                        if (isNewAndNotChanged) {
                            [undoManager beginUndoGrouping];
                            [[undoManager prepareWithInvocationTarget:stack] addHyperChild:[HSCard defaultObject]];
                            [[undoManager prepareWithInvocationTarget:stack] setHyperCardSize:cardSize];
                            [[undoManager prepareWithInvocationTarget:stack] removeHyperChildren:sorted];
                            [undoManager endUndoGrouping];
                            [undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:(count == 1 ? @"Add Item" : @"Add Items") value:@"" table:@"UndoManager"]];
                        }
                    }
                }
            }
            [addedCards release];
            denied = importedImages == 0;
        }
        reply = 0;
        if (denied && importedMovies == 0 && importedOther == 0 && !_applicationWillFinishCriticalLaunching) {
            if ([images count] == 0 && [movies count] == 0 && [otherFiles count] == 0) {
                for (NSString *path in aFiles) {
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    if (![fileManager isReadableFileAtPath:path]) {
                        continue;
                    }
                    NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
                    if (url == nil) {
                        reply = 0;
                        goto done;
                    }
                    id opened = [self openDocumentWithContentsOfURL:[url absoluteURL] display:YES error:&error];
                    [url release];
                    BOOL isDirectory = NO;
                    BOOL exists = [fileManager fileExistsAtPath:path isDirectory:&isDirectory];
                    if (opened == nil) {
                        if ([[error userInfo] objectForKey:HSUserCancelledImportKey] != nil) {
                            goto done;
                        }
                        if (exists && isDirectory && [[error domain] isEqualToString:NSCocoaErrorDomain] && [error code] == 0x100) {
                            error = nil;
                            NSBeep();
                        }
                        goto finish;
                    }
                    if (!exists) {
                        goto done;
                    }
                    NSString *folder = path;
                    if (!isDirectory) {
                        folder = [path stringByDeletingLastPathComponent];
                    }
                    NSString *temporaryDirectory = NSTemporaryDirectory();
                    BOOL isTemporary = temporaryDirectory != nil && [folder rangeOfString:temporaryDirectory].length != 0;
                    if (![folder hasPrefix:[[NSBundle mainBundle] bundlePath]] && [opened typeOfAcceptedFile] == nil && !isTemporary) {
                        [[HSPathsProvider sharedPathsProvider] setHyperStudioDocumentsFolder:folder];
                    }
                }
            } else {
                NSBeep();
            }
        }
    }
done:
    [aApplication replyToOpenOrPrint:reply];
finish:
    if (error != nil) {
        [self presentError:error];
    }
}

- (void)applicationDidFinishRestoring:(id)aRestoring
{
    if ([self respondsToSelector:@selector(wasWindowRestoration)] && [self wasWindowRestoration]) {
        NSArray *documents = [self documents];
        NSInteger option = [[HSPreferencesController sharedPreferencesController] getStartupPreferencesOption];
        if (option == 1) {
            HSEditorDocument *target = nil;
            for (HSEditorDocument *document in documents) {
                if ([document isNewAndNotChanged]) {
                    target = document;
                    break;
                }
            }
            if (target == nil) {
                target = [self openUntitledDocumentAndDisplay:YES error:nil];
            }
            [[[target currentWindowController] window] performSelector:@selector(makeKeyAndOrderFront:) withObject:nil afterDelay:0];
        } else if (option == 0) {
            [self applicationOpenUntitledFile:NSApp];
        }
        for (HSEditorDocument *document in documents) {
            if ([document isStackProtected] || [document isTutorialStack]) {
                [document showWindows];
            }
        }
    }
}

- (void)application:(id)aApplication willEncodeRestorableState:(id)aState
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:HSOpenHomeStackOnStartup];
    for (id document in [self documents]) {
        if ([document isDefaultHomeStack]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:HSOpenHomeStackOnStartup];
        }
    }
}

- (id)applicationDockMenu:(id)aMenu
{
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@""];
    [menu addItemWithTitle:[[NSBundle mainBundle] localizedStringForKey:@"HSNewStackDockMenuItemTitle" value:@"" table:@"Editor"] action:@selector(newDocument:) keyEquivalent:@""];
    return [menu autorelease];
}

- (void)applicationWillResignActive:(id)aActive
{
    if ([[HSApplicationController sharedDocumentController] isPauseResumeEnabled]) {
        id document = [self currentDocument];
        if ([document isInPlayerMode]) {
            [document pause];
        }
    }
}

- (void)cascadeDocument:(id)aDocument prevDocument:(id)aPrev
{
    NSWindow *previousWindow = [[aPrev currentWindowController] window];
    NSWindow *window = [[aDocument currentWindowController] window];
    if (window == nil) {
        return;
    }
    if (previousWindow != nil) {
        NSValue *stored = [[self windowToTopLeftPointMap] objectForKey:[NSNumber numberWithUnsignedInteger:[previousWindow hash]]];
        if (stored == nil) {
            NSRect previousFrame = [previousWindow frame];
            NSRect frame = [window frame];
            if (fabs(NSMaxY(previousFrame) - NSMaxY(frame)) + fabs(NSMinX(previousFrame) - NSMinX(frame)) >= 10.0) {
                goto save;
            }
            [window setFrameTopLeftPoint:[window cascadeTopLeftFromPoint:NSMakePoint(NSMinX(previousFrame), NSMaxY(previousFrame))]];
        } else {
            [window setFrameTopLeftPoint:[stored pointValue]];
        }
    }
save:
    [self saveTopLeftPointForWindow:window];
}

- (id)documentForWindow:(id)aWindow
{
    id document = [super documentForWindow:aWindow];
    if ([[HSPathsProvider sharedPathsProvider] isTutorialURL:[document fileURL]]) {
        return nil;
    }
    return document;
}

- (id)filesToOpen
{
    return _filesToOpen;
}

- (void)setFilesToOpen:(id)aFiles
{
    if (_filesToOpen != aFiles) {
        [_filesToOpen release];
        _filesToOpen = [aFiles copy];
    }
}

- (void)invokeDelayedDocumentsReopen
{
    if (_delayedDocumentsReopenInvokes != nil) {
        for (NSInvocation *invocation in _delayedDocumentsReopenInvokes) {
            [invocation invoke];
        }
        [_delayedDocumentsReopenInvokes release];
        _delayedDocumentsReopenInvokes = nil;
        [_copysOfDocumentsReopenInvokesArguments release];
        _copysOfDocumentsReopenInvokesArguments = nil;
    }
}

- (BOOL)isApplicationLaunchFinished
{
    return ![self shouldShowEULA] && [self HSEditorController_validateApplicationLicenseWithInteraction:NO forced:NO] && !_applicationWillFinishCriticalLaunching;
}

- (BOOL)isDuplicationInProgress
{
    return _isDuplicationInProgress;
}

- (void)setDuplicationInProgress:(BOOL)aProgress
{
    _isDuplicationInProgress = aProgress;
}

- (BOOL)isInViewingMode
{
    return _isInViewingMode;
}

- (void)setViewingMode:(BOOL)aMode
{
    _isInViewingMode = aMode;
}

- (BOOL)isPauseResumeEnabled
{
    return [self isMultiDocument] && ![[self currentDocument] isTutorialStack];
}

- (void)newDocument:(id)aDocument
{
    id previousDocument = [[self documents] lastObject];
    [super newDocument:aDocument];
    id document = [self currentDocument];
    [self cascadeDocument:document prevDocument:previousDocument];
    [[document mainWindowController] fitWindowToCardSizeAnimated:NO];
}

- (void)newDocumentFromTemplateChooser:(id)aChooser
{
    id chooser = [HSATemplateChooser sharedTemplateChooser];
    [chooser setDelegate:self];
    [chooser showWindow];
}

- (id)openDocumentWithContentsOfURL:(id)aURL display:(BOOL)aDisplay error:(id *)aError
{
    id previousDocument = [[self documents] lastObject];
    NSString *type = [self typeForContentsOfURL:aURL error:nil];
    id document;
    if ([type isEqual:@"HSDocumentType"]) {
        document = nil;
        if ([self addReadyMadeCardsFromPath:[aURL path] alwaysCreateNewDocument:YES]) {
            document = [[self documents] lastObject];
        }
    } else if ([type isEqual:@"HSKeynoteDocumentType"]) {
        document = [self makeUntitledDocumentOfType:[self defaultType] error:aError];
        if (document != nil && [document readFromURL:aURL ofType:@"HSKeynoteDocumentType" error:aError]) {
            [document setDisplayName:[[[aURL lastPathComponent] stringByDeletingPathExtension] copy]];
            [self addDocument:document];
            [document makeWindowControllers];
            [document showWindows];
        }
    } else {
        document = [super openDocumentWithContentsOfURL:aURL display:aDisplay error:aError];
        if (document != nil) {
            [[HSATemplateChooser sharedTemplateChooser] close];
        }
    }
    if (![[HSPathsProvider sharedPathsProvider] isTutorialURL:[document fileURL]]) {
        [self cascadeDocument:document prevDocument:previousDocument];
    }
    return document;
}

- (void)openTutorials:(id)aTutorials
{
    [[self defaultNavigationControllerClass] goToTutorialsPage];
}

- (void)reopenDocumentForURL:(id)aURL withContentsOfURL:(id)aContents display:(BOOL)aDisplay completionHandler:(id)aHandler
{
    if (!_needsDelayDocumentsReopen) {
        [super reopenDocumentForURL:aURL withContentsOfURL:aContents display:aDisplay completionHandler:aHandler];
        return;
    }
    if (_delayedDocumentsReopenInvokes == nil) {
        _delayedDocumentsReopenInvokes = [NSMutableArray new];
    }
    if (_copysOfDocumentsReopenInvokesArguments == nil) {
        _copysOfDocumentsReopenInvokesArguments = [NSMutableArray new];
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:_cmd]];
    [invocation setTarget:self];
    [invocation setSelector:_cmd];
    if (aURL != nil) {
        id copy = [[aURL copy] autorelease];
        [_copysOfDocumentsReopenInvokesArguments addObject:copy];
        [invocation setArgument:&copy atIndex:2];
    }
    if (aContents != nil) {
        id copy = [[aContents copy] autorelease];
        [_copysOfDocumentsReopenInvokesArguments addObject:copy];
        [invocation setArgument:&copy atIndex:3];
    }
    [invocation setArgument:&aDisplay atIndex:4];
    if (aHandler != nil) {
        id copy = [[aHandler copy] autorelease];
        [_copysOfDocumentsReopenInvokesArguments addObject:copy];
        [invocation setArgument:&copy atIndex:5];
    }
    [_delayedDocumentsReopenInvokes addObject:invocation];
}

- (void)saveTopLeftPointForWindow:(id)aWindow
{
    NSNumber *key = [NSNumber numberWithUnsignedInteger:[aWindow hash]];
    if ([[self windowToTopLeftPointMap] objectForKey:key] == nil) {
        NSRect frame = aWindow != nil ? [aWindow frame] : NSZeroRect;
        [[self windowToTopLeftPointMap] setObject:[NSValue valueWithPoint:NSMakePoint(NSMinX(frame), NSMaxY(frame))] forKey:key];
    }
}

- (id)windowToTopLeftPointMap
{
    if (_windowToTopLeftPointMap == nil) {
        _windowToTopLeftPointMap = [NSMutableDictionary new];
    }
    return _windowToTopLeftPointMap;
}

- (void)templateChooser:(id)aChooser didChooseTemplateAtPath:(id)aPath
{
    [self addReadyMadeCardsFromPath:aPath alwaysCreateNewDocument:YES];
}

- (void)undoImportingFilesCount:(NSUInteger)aCount lastAddedCardIndex:(NSUInteger)aIndex inDocument:(id)aDocument
{
    HSStack *stack = [aDocument stack];
    if (aCount > 1) {
        [stack hyperRemoveChildrenBeginGrouping];
    }
    if ([stack hyperCount] == aCount) {
        [stack addHyperChild:[HSCard defaultObject]];
    }
    for (NSUInteger remaining = aCount; remaining != 0; remaining--) {
        [stack removeHyperChild:[stack hyperChildAtIndex:(1 - aCount) + aIndex]];
    }
    if (aCount > 1) {
        [stack hyperRemoveChildrenEndGrouping];
    }
}

@end

@implementation NSWorkspace (HSFileTypesUtilities)

- (BOOL)isFileMediaOrTextAtPath:(id)aPath
{
    if ([[NSFileManager defaultManager] hyperIsTextForPath:aPath]) {
        return YES;
    }
    NSString *fileType = [[[NSFileManager defaultManager] attributesOfItemAtPath:aPath error:NULL] fileType];
    if (![fileType isEqualToString:NSFileTypeRegular]) {
        return NO;
    }
    if ([[aPath pathExtension] compare:@"pdf" options:NSCaseInsensitiveSearch] != NSOrderedSame) {
        return [QTMovie canInitWithFile:aPath];
    }
    return YES;
}

- (BOOL)isFileMovieAtPath:(id)aPath
{
    NSString *fileType = [[[NSFileManager defaultManager] attributesOfItemAtPath:aPath error:NULL] fileType];
    if (![fileType isEqualToString:NSFileTypeRegular]) {
        return NO;
    }
    NSString *type = nil;
    BOOL found = [self getInfoForFile:aPath application:NULL type:&type];
    if (![type isEqualToString:NSHFSTypeOfFile(aPath)]) {
        type = [type lowercaseString];
    }
    if (!found) {
        return NO;
    }
    return [[HSMovieObject movieFileTypes] containsObject:type];
}

- (BOOL)isFileImageAtPath:(id)aPath
{
    NSString *fileType = [[[NSFileManager defaultManager] attributesOfItemAtPath:aPath error:NULL] fileType];
    if (![fileType isEqualToString:NSFileTypeRegular]) {
        return NO;
    }
    NSString *type = nil;
    if (![self getInfoForFile:aPath application:NULL type:&type]) {
        return NO;
    }
    if (![[NSImage imageFileTypes] containsObject:type]) {
        return NO;
    }
    NSError *error = nil;
    HSMovie *movie = [HSMovie movieWithURL:[NSURL fileURLWithPath:aPath] error:&error];
    if (error != nil) {
        return YES;
    }
    return ![movie isAnimatedGifMovie];
}

@end

