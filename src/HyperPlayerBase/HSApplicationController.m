#import "HSApplicationController.h"
#import "EXDocumentController.h"
#import "HSError.h"
#import "HSErrorManager.h"
#import "HSSubmitRequest.h"
#import "HSMediaSaver.h"
#import "HSSaveOperationQueue.h"
#import "HSTemporaryFilesManager.h"
#import "HSSystemChecker.h"
#import "HSSystem.h"
#import "HSBackgroundWindowController.h"
#import "HSPathsProvider.h"
#import "HSDocument.h"
#import "HSEULAWindowController.h"
#import "HSPreferencesController.h"
#import "HSLinkButton.h"
#import "HSMainWindowController.h"
#import "NSBundle+HSBundle.h"
#import "NSFileManager+HSExtensions.h"
#import "NSMutableArray+EXMutableArray.h"
#import "NSMutableDictionary+EXExtensions.h"

static BOOL HSMultiDocumentChecked;
static BOOL HSMultiDocument;
static NSString *HSEULAStartupStateKeyString;

// The application's document controller and delegate: startup (defaults,
// the license agreement shown once per EULA version, reopening the last
// stack), errors presented through the HyperStudio error manager, stacks
// opened in place of the document in a window, and the shared menu items.
@implementation HSApplicationController

+ (id)buildVersionString
{
    return [[NSBundle mainBundle] HS_buildVersion];
}

// Windows aren't restored; the untitled document (or the last stack) opens
// instead, unless the license agreement is still to be shown.
+ (void)restoreWindowWithIdentifier:(id)aIdentifier state:(id)aState completionHandler:(id /* block */)aHandler
{
    ((void (^)(NSWindow *, NSError *))aHandler)(nil, nil);
    id delegate = [NSApp delegate];
    BOOL showsEULA = [delegate respondsToSelector:@selector(shouldShowEULA)] ? [delegate shouldShowEULA] : NO;
    BOOL cancels = [delegate respondsToSelector:@selector(shouldCancelWindowRestoration)] ? [delegate shouldCancelWindowRestoration] : NO;
    if (cancels || showsEULA)
        return;
    if ([[NSUserDefaults standardUserDefaults] integerForKey:HSStartupActionKey] == 2)
        return;
    if ([delegate respondsToSelector:@selector(applicationOpenUntitledFile:)])
        [delegate applicationOpenUntitledFile:NSApp];
}

- (BOOL)hasPlayerDocuments
{
    NSEnumerator *documents = [[self documents] objectEnumerator];
    id document;
    while ((document = [documents nextObject])) {
        if ([document isInPlayerMode])
            return YES;
    }
    return NO;
}

- (BOOL)shouldCancelWindowRestoration
{
    return NO;
}

// The startup action 2 reopens the most recent stack.
- (BOOL)applicationOpenUntitledFile:(id)aFile
{
    NSInteger startupAction = [[NSUserDefaults standardUserDefaults] integerForKey:HSStartupActionKey];
    NSURL *url = [[self recentDocumentURLs] extraFirstObject];
    if (startupAction == 2 && url)
        return [self openDocumentWithContentsOfURL:url display:YES error:NULL] != nil;
    return NO;
}

- (BOOL)applicationShouldOpenUntitledFile:(id)aFile
{
    return ![self isModalSessionPresent] && ![self shouldShowEULA];
}

- (BOOL)isModalSessionPresent
{
    return [NSApp modalWindow] != nil;
}

- (BOOL)resolvingError
{
    return _resolvingError;
}

- (void)setResolvingError:(BOOL)aError
{
    if (_resolvingError != aError)
        _resolvingError = aError;
}

- (BOOL)ignoreVersioning
{
    return _ignoreVersioning;
}

- (void)setIgnoreVersioning:(BOOL)aVersioning
{
    if (_ignoreVersioning != aVersioning)
        _ignoreVersioning = aVersioning;
}

// Errors of the Cocoa and HyperStudio domains become HSErrors, which the
// error manager presents.
static NSError *HSApplicationControllerHyperError(NSError *aError)
{
    if ([[aError domain] isEqualToString:HSCocoaErrorDomain] || [[aError domain] isEqualToString:HSSpecificErrorDomain])
        return [HSError errorWithDomain:[aError domain] code:[aError code] userInfo:[aError userInfo]];
    return aError;
}

- (void)presentError:(id)aError modalForWindow:(id)aWindow delegate:(id)aDelegate didPresentSelector:(SEL)aSelector contextInfo:(void *)aInfo
{
    aError = HSApplicationControllerHyperError(aError);
    if ([aError isKindOfClass:[HSError class]])
        [[HSErrorManager sharedErrorManager] presentError:aError inWindow:aWindow delegate:aDelegate didPresentSelector:aSelector contextInfo:aInfo];
    else
        [super presentError:aError modalForWindow:aWindow delegate:aDelegate didPresentSelector:aSelector contextInfo:aInfo];
}

- (BOOL)presentError:(id)aError
{
    BOOL result;
    _resolvingError = YES;
    aError = HSApplicationControllerHyperError(aError);
    if ([aError isKindOfClass:[HSError class]])
        result = [[HSErrorManager sharedErrorManager] presentError:aError];
    else
        result = [super presentError:aError];
    _resolvingError = NO;
    return result;
}

- (void)document:(id)aDocument shouldClose:(BOOL)aClose contextInfo:(void *)aInfo
{
    if (aClose)
        [aDocument close];
}

- (void)applicationWillTerminate:(id)aTerminate
{
    [[HSSubmitRequest sharedInstance] storeUnsentRequests];
    [[HSNewMediaAccessor sharedMediaAccessor] cleanupMediaUsedByApplication];
    [HSSaveOperationQueue cleanupTempFolder];
    [HSTemporaryFilesManager clean];
}

- (void)applicationDidFinishLaunching:(id)aLaunching
{
    [NSThread detachNewThreadSelector:@selector(HSApplicationController_initializeQuartzComposerFramework) toTarget:self withObject:nil];
    [[HSSystemChecker sharedInstance] checkMinSpec];
    if (![[HSSystem sharedSystem] isQTKitCapturingAvailable]) {
        NSString *ok = [[NSBundle mainBundle] localizedStringForKey:@"OK" value:@"" table:@"Alerts"];
        NSString *message = [[NSBundle mainBundle] localizedStringForKey:@"QuickTime version 7.2.1 is required for capturing video." value:@"" table:@"Alerts"];
        NSString *title = [[NSBundle mainBundle] localizedStringForKey:@"QuickTime is out of date" value:@"" table:@"Alerts"];
        NSRunAlertPanel(title, @"%@", ok, nil, nil, message);
    }
    [[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
    [[NSSpellChecker sharedSpellChecker] learnWord:@"HyperStudio"];
    [self validateMenuShortcuts];
    [[HSSubmitRequest sharedInstance] submitInformation:nil];
}

- (void)applicationWillFinishLaunching:(id)aLaunching
{
    [self HSApplicationController_unregister3IVXComponent];
    [[NSUserDefaults standardUserDefaults] registerDefaults:[self applicationDefaults]];
    [HSBackgroundWindowController backgroundWindowController];
    [[HSSubmitRequest sharedInstance] setRequestsQueueLimit:20];
}

- (id)applicationDefaults
{
    NSMutableDictionary *defaults = [NSMutableDictionary extraDictionaryNamed:@"ApplicationDefaults"];
    if ([[HSSystem sharedSystem] isLeopardOrGreater]) {
        NSDictionary *leopardDefaults = [NSDictionary extraDictionaryNamed:@"LeopardDefaults"];
        if (leopardDefaults)
            [defaults addEntriesFromDictionary:leopardDefaults];
    }
    return defaults;
}

// The original unregistered 3ivx QuickTime components, putting Apple's in
// their place; QuickTime components are gone.
- (void)HSApplicationController_unregister3IVXComponent
{
}

// Loads Quartz Composer ahead of use by rendering a dummy composition once.
- (void)HSApplicationController_initializeQuartzComposerFramework
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString *path = [[NSBundle bundleForClass:[HSApplicationController class]] pathForResource:@"Dummy" ofType:@"qtz"];
    if (path) {
        NSOpenGLPixelFormatAttribute attributes[] = { NSOpenGLPFAWindow, 0 };
        NSOpenGLPixelFormat *format = [[[NSOpenGLPixelFormat alloc] initWithAttributes:attributes] autorelease];
        if (format) {
            NSOpenGLContext *context = [[NSOpenGLContext alloc] initWithFormat:format shareContext:nil];
            if (context) {
                QCRenderer *renderer = [[QCRenderer alloc] initWithOpenGLContext:context pixelFormat:format file:path];
                [context release];
                [renderer release];
            }
        }
    }
    [pool release];
}

- (BOOL)isStackToGoController
{
    return NO;
}

// Moves the window of aDocument2 over to aDocument, closing aDocument2.
- (id)openDocument:(id)aDocument inWindowOfDocument:(id)aDocument2 error:(id *)aError
{
    id windowController = [aDocument currentWindowController];
    [windowController setShouldCloseDocument:NO];
    [windowController close];
    [aDocument setPlayerView:nil];
    [aDocument removeWindowControllers];
    [aDocument takeDataFromDocument:aDocument2];
    [aDocument2 updateChangeCount:NSChangeCleared];
    [aDocument2 retain];
    [self setLastDocument:aDocument];
    [aDocument createWindowControllers];
    [aDocument2 close];
    [aDocument2 autorelease];
    [self applicationDidReplaceDocumentWithDocument:aDocument];
    return aDocument;
}

// Reads the stack into a new document that takes over the window (and main
// window controller) of aDocument. With multiple documents an open stack
// is moved over instead. A failed or cancelled read opens nothing.
- (id)openDocumentWithContentsOfURL:(id)aURL inWindowOfDocument:(id)aDocument error:(id *)aError
{
    NSError *error = nil;
    NSString *type = [self typeForContentsOfURL:aURL error:&error];
    if (!type || error) {
        if (aError)
            *aError = error;
        return nil;
    }
    _sharedMainWindowController = [[aDocument mainWindowController] retain];
    id openDocument = [self documentForURL:aURL];
    if ([self isMultiDocument] && openDocument && ![aURL isEqual:[aDocument fileURL]])
        return [self openDocument:openDocument inWindowOfDocument:aDocument error:aError];
    id document = [[self documentClassForType:type] new];
    BOOL failed;
    if (!document) {
        error = [HSError errorWithDomain:HSSpecificErrorDomain code:10001 userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:HSUserCancelledImportKey]];
        failed = NO;
    } else {
        failed = ![document readFromURL:aURL ofType:type error:&error];
    }
    if (!failed && error) {
        NSNumber *cancelled = [[error userInfo] objectForKey:HSUserCancelledImportKey];
        if (cancelled)
            failed = [cancelled boolValue];
    }
    if (failed) {
        [_sharedMainWindowController release];
        _sharedMainWindowController = nil;
        [document release];
        document = nil;
    } else {
        [document setFileURL:aURL];
        [document setFileType:type];
        [document takeDataFromDocument:aDocument];
        [aDocument updateChangeCount:NSChangeCleared];
        [aDocument retain];
        [self setLastDocument:document];
        [document makeWindowControllers];
        [aDocument close];
        [self addDocument:document];
        [document autorelease];
        [aDocument autorelease];
        [self applicationDidReplaceDocumentWithDocument:document];
    }
    if (aError)
        *aError = error;
    return document;
}

- (void)applicationDidReplaceDocumentWithDocument:(id)aDocument
{
}

- (id)sharedMainWindowController
{
    return _sharedMainWindowController;
}

- (void)sharedMainWindowControllerHandled
{
    [_sharedMainWindowController release];
    _sharedMainWindowController = nil;
}

- (void)removeDocument:(id)aDocument
{
    [[NSNotificationCenter defaultCenter] postNotificationName:HSDocumentWillRemoveFromDocumentControllerNotification object:aDocument];
    if ([aDocument respondsToSelector:@selector(hyperDocumentWillRemoveFromDocumentController:)])
        [aDocument hyperDocumentWillRemoveFromDocumentController:self];
    [super removeDocument:aDocument];
    [[NSNotificationCenter defaultCenter] postNotificationName:HSDocumentDidRemoveFromDocumentControllerNotification object:aDocument];
    if ([aDocument respondsToSelector:@selector(hyperDocumentDidRemoveFromDocumentController:)])
        [aDocument hyperDocumentDidRemoveFromDocumentController:self];
}

// HyperStudio 4 stacks by file type.
- (id)typeForContentsOfURL:(id)aURL error:(id *)aError
{
    NSString *fileType = [[NSFileManager defaultManager] hyperFileTypeAtPath:[aURL path]];
    if ([@"stack" isEqualToString:fileType])
        return @"HSDocumentType";
    if ([@"'Stak'" isEqualToString:fileType])
        return @"HSNativeDocumentType";
    return [super typeForContentsOfURL:aURL error:aError];
}

- (id)readableFileExtensions
{
    NSMutableArray *extensions = [NSMutableArray new];
    NSEnumerator *classNames = [[self documentClassNames] objectEnumerator];
    NSString *className;
    while ((className = [classNames nextObject])) {
        NSEnumerator *types = [[NSClassFromString(className) readableTypes] objectEnumerator];
        NSString *type;
        while ((type = [types nextObject]))
            [extensions addObjectsFromArray:[self fileExtensionsFromType:type]];
    }
    NSArray *result = [[extensions copy] autorelease];
    [extensions release];
    return result;
}

- (BOOL)areDocumentSpecificPresentationSettingsActive
{
    return YES;
}

- (BOOL)supportsHomeStack
{
    return NO;
}

- (BOOL)isMultiDocument
{
    if (!HSMultiDocumentChecked) {
        HSMultiDocument = [[NSUserDefaults standardUserDefaults] boolForKey:@"HSMultiDocumentEnabled"];
        HSMultiDocumentChecked = YES;
    }
    return HSMultiDocument;
}

- (void)validateMenuShortcuts
{
    [_toggleBrowseEditModeMenuItem setKeyEquivalent:@"\t"];
    [_toggleBrowseEditModeMenuItem setKeyEquivalentModifierMask:NSEventModifierFlagControl];
    [_bringToFrontMenuItem setKeyEquivalentModifierMask:[_bringToFrontMenuItem keyEquivalentModifierMask] | NSEventModifierFlagShift];
    [_sendToBackMenuItem setKeyEquivalentModifierMask:[_sendToBackMenuItem keyEquivalentModifierMask] | NSEventModifierFlagShift];
}

// Opens in the HyperStudio documents folder and remembers the folder chosen.
- (NSInteger)runModalOpenPanel:(id)aPanel forTypes:(id)aTypes
{
    NSString *folder = [[HSPathsProvider sharedPathsProvider] hyperStudioDocumentsFolder];
    [aPanel setDirectoryURL:[NSURL fileURLWithPath:folder isDirectory:YES]];
    NSInteger result = [super runModalOpenPanel:aPanel forTypes:aTypes];
    if (result == NSModalResponseOK)
        [[HSPathsProvider sharedPathsProvider] setHyperStudioDocumentsFolder:[[aPanel directoryURL] path]];
    return result;
}

- (id)selectedHyperObject
{
    return [[self currentDocument] selectedHyperObject];
}

- (Class)defaultNavigationControllerClass
{
    [self doesNotRecognizeSelector:_cmd];
    return Nil;
}

- (void)dealloc
{
    [_sharedMainWindowController release];
    [super dealloc];
}

- (id)exportCompatibilityChecker
{
    return _exportCompatibilityChecker;
}

- (BOOL)isPauseResumeEnabled
{
    return [[HSApplicationController sharedDocumentController] isPauseResumeEnabled];
}

- (void)setWasWindowRestoration:(BOOL)aRestoration
{
    _wasWindowRestoration = aRestoration;
}

- (void)startHTML5CompatibilityCheckForDocument:(id)aDocument
{
    _exportCompatibilityChecker = [[HSAHTML5ExportCompatibilityChecker alloc] init];
    [_exportCompatibilityChecker setVerifiableDocumentURL:aDocument];
}

- (void)stopHTML5CompatibilityCheckForDocument
{
    [_exportCompatibilityChecker release];
    _exportCompatibilityChecker = nil;
}

- (BOOL)wasWindowRestoration
{
    return _wasWindowRestoration;
}

@end

@implementation HSApplicationController (IBActions)

- (void)techSupportForHyperStudio:(id)aStudio
{
    NSString *version = [[self class] buildVersionString];
    NSString *url = [[NSBundle bundleForClass:[HSDocument class]] localizedStringForKey:@"HSTechSupportForHyperStudioURL" value:@"" table:@"HyperPlayerBase"];
    [HSDocument openURL:url versionString:version addPlatformInfo:YES addProductName:YES];
}

- (void)registerHyperStudio:(id)aStudio
{
    NSString *version = [[self class] buildVersionString];
    NSString *url = [[NSBundle bundleForClass:[HSDocument class]] localizedStringForKey:@"HSRegisterHyperStudioURL" value:@"" table:@"HyperPlayerBase"];
    [HSDocument openURL:url versionString:version addPlatformInfo:YES addProductName:YES];
}

- (void)provideHyperStudioFeedback:(id)aFeedback
{
    NSString *version = [[self class] buildVersionString];
    NSString *url = [[NSBundle bundleForClass:[HSDocument class]] localizedStringForKey:@"HSProvideHyperStudioFeedbackURL" value:@"" table:@"HyperPlayerBase"];
    [HSDocument openURL:url versionString:version addPlatformInfo:YES addProductName:YES];
}

// Declining quits. Acceptance is recorded for any user of the machine, in
// the preferences and in a shared plist under /Users/Shared.
- (void)showEULAAppModalDialog
{
    HSEULAWindowController *controller = [HSEULAWindowController new];
    [controller setEULAWindowTitle:[self EULAWindowTitle]];
    [controller setEULATitle:[self EULATitle]];
    [controller setEULAAttributedString:[self EULAAttributedString]];
    _appModalEULADialogIsShowing = YES;
    NSInteger response = [NSApp runModalForWindow:[controller window]];
    _appModalEULADialogIsShowing = NO;
    [controller release];
    if (response != 1) {
        [NSApp terminate:self];
        return;
    }
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"HSFirstApplicationStartupKey"];
    NSString *key = [self EULAStartupStateKey];
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    if (!identifier || !key)
        return;
    CFDictionaryRef values = CFPreferencesCopyMultiple((CFArrayRef)[NSArray arrayWithObject:key], (CFStringRef)identifier, kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
    CFDictionaryRef newValues = NULL;
    if (!values) {
        newValues = CFDictionaryCreate(NULL, (const void **)&key, (const void **)&kCFBooleanTrue, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    } else if (CFDictionaryGetValue(values, key) == kCFBooleanTrue) {
        CFRelease(values);
    } else {
        CFMutableDictionaryRef copy = CFDictionaryCreateMutableCopy(NULL, 0, values);
        CFRelease(values);
        if (copy)
            CFDictionarySetValue(copy, key, kCFBooleanTrue);
        newValues = copy;
    }
    if (newValues) {
        CFPreferencesSetMultiple(newValues, NULL, (CFStringRef)identifier, kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
        CFPreferencesSynchronize((CFStringRef)identifier, kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
        CFRelease(newValues);
    }
    NSString *path = nil;
    id preferences = [self sharedPreferencesWithIdentifier:identifier mutabilityOption:NSPropertyListMutableContainers path:&path];
    if (!path)
        return;
    if (!preferences) {
        preferences = [NSDictionary dictionaryWithObject:(id)kCFBooleanTrue forKey:key];
    } else {
        id accepted = [preferences objectForKey:key];
        if ([accepted isKindOfClass:[NSNumber class]] && [accepted boolValue])
            return;
        [preferences setObject:(id)kCFBooleanTrue forKey:key];
    }
    if (!preferences)
        return;
    NSData *data = [NSPropertyListSerialization dataFromPropertyList:preferences format:NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
    if (![data length])
        return;
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedLong:0777] forKey:NSFilePosixPermissions];
    if ([self restoreParentFolder:[path stringByDeletingLastPathComponent] attributes:attributes])
        [data writeToFile:path atomically:YES];
}

// Creates the folder and any missing parents.
- (BOOL)restoreParentFolder:(id)aFolder attributes:(id)aAttributes
{
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    if ([manager fileExistsAtPath:aFolder isDirectory:&isDirectory] && isDirectory)
        return YES;
    if (![self restoreParentFolder:[aFolder stringByDeletingLastPathComponent] attributes:aAttributes])
        return NO;
    return [manager createDirectoryAtPath:aFolder attributes:aAttributes];
}

- (BOOL)isEULAWasAcceptedInApplicationWithIdentifier:(id)aIdentifier
{
    if (!aIdentifier)
        return NO;
    NSString *key = [self EULAStartupStateKey];
    if (!key)
        return NO;
    CFPreferencesSynchronize((CFStringRef)aIdentifier, kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
    CFDictionaryRef values = CFPreferencesCopyMultiple((CFArrayRef)[NSArray arrayWithObject:key], (CFStringRef)aIdentifier, kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
    if (values) {
        CFTypeRef accepted = CFDictionaryGetValue(values, key);
        CFRelease(values);
        if (accepted == kCFBooleanTrue) {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"HSFirstApplicationStartupKey"];
            return YES;
        }
    }
    if (![[[self sharedPreferencesWithIdentifier:aIdentifier mutabilityOption:NSPropertyListImmutable path:NULL] objectForKey:key] boolValue])
        return NO;
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"HSFirstApplicationStartupKey"];
    return YES;
}

- (BOOL)shouldShowEULA
{
    BOOL accepted;
    NSNumber *firstStartup = [[NSUserDefaults standardUserDefaults] objectForKey:@"HSFirstApplicationStartupKey"];
    if (firstStartup && ![firstStartup boolValue])
        accepted = YES;
    else
        accepted = [self isEULAWasAcceptedInApplicationWithIdentifier:[[NSBundle mainBundle] bundleIdentifier]];
    return !(accepted || _appModalEULADialogIsShowing);
}

// Per EULA version, so a new agreement is shown again.
- (id)EULAStartupStateKey
{
    if (!HSEULAStartupStateKeyString) {
        NSString *version = [self EULAVersion];
        if (![version length])
            HSEULAStartupStateKeyString = @"HSEULAStartupState";
        else
            HSEULAStartupStateKeyString = [[NSString alloc] initWithFormat:@"%@_%@", @"HSEULAStartupState", version];
    }
    return HSEULAStartupStateKeyString;
}

- (id)sharedPreferencesWithIdentifier:(id)aIdentifier mutabilityOption:(NSUInteger)aOption path:(id *)aPath
{
    NSString *path = [self pathToSharedPreferencesWithIdentifier:aIdentifier];
    if (![path length])
        return nil;
    if (aPath)
        *aPath = path;
    NSData *data = [NSData dataWithContentsOfMappedFile:path];
    if (!data)
        return nil;
    id preferences = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:aOption format:NULL errorDescription:NULL];
    if (![preferences isKindOfClass:[NSDictionary class]])
        return nil;
    return preferences;
}

// The user's preferences folder relative to the home folder, under the
// shared user data folder: /Users/Shared/Library/Preferences/<id>.plist.
- (id)pathToSharedPreferencesWithIdentifier:(id)aIdentifier
{
    if (![aIdentifier length])
        return nil;
    FSRef sharedRef, preferencesRef, homeRef;
    char sharedPath[1024], preferencesPath[1024], homePath[1024];
    if (FSFindFolder(kLocalDomain, kSharedUserDataFolderType, kCreateFolder, &sharedRef) != noErr
        || FSRefMakePath(&sharedRef, (UInt8 *)sharedPath, sizeof(sharedPath)) != noErr || !sharedPath[0])
        return nil;
    if (FSFindFolder(kUserDomain, kPreferencesFolderType, kCreateFolder, &preferencesRef) != noErr
        || FSRefMakePath(&preferencesRef, (UInt8 *)preferencesPath, sizeof(preferencesPath)) != noErr || !preferencesPath[0])
        return nil;
    if (FSFindFolder(kUserDomain, kDomainTopLevelFolderType, kCreateFolder, &homeRef) != noErr
        || FSRefMakePath(&homeRef, (UInt8 *)homePath, sizeof(homePath)) != noErr)
        return nil;
    size_t homeLength = strlen(homePath);
    if (!homeLength)
        return nil;
    return [NSString stringWithFormat:@"%s/%s/%@.plist", sharedPath, preferencesPath + homeLength + 1, aIdentifier];
}

- (id)EULAAttributedString
{
    return [[[NSAttributedString alloc] initWithString:@"HyperStudio 5 Editor/Player End User License Agreement."] autorelease];
}

- (id)EULAVersion
{
    return @"1.0";
}

- (id)EULATitle
{
    return @"HyperStudio 5 Editor/Player License Agreement";
}

- (id)EULAWindowTitle
{
    return @"< HyperStudio 5 Editor/Player >";
}

- (id)productName
{
    return @"HyperStudio 5";
}

- (BOOL)allowProvideHyperStudioFeedback
{
    return YES;
}

- (BOOL)allowOpenDocument
{
    return YES;
}

- (BOOL)allowNewDocument
{
    return YES;
}

- (void)goToHome:(id)aHome
{
    [[self defaultNavigationControllerClass] goToHomeStack];
}

// An autosaved copy opens the original if it is still there.
- (id)openDocumentWithContentsOfURL:(id)aURL display:(BOOL)aDisplay error:(id *)aError
{
    NSString *autosaved = [[NSBundle mainBundle] localizedStringForKey:@"(Autosaved)" value:@"" table:nil];
    NSString *path = [aURL path];
    NSMutableString *originalPath = [[NSMutableString alloc] initWithString:path];
    [originalPath replaceOccurrencesOfString:[@" " stringByAppendingString:autosaved] withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [originalPath length])];
    if ([[NSFileManager defaultManager] fileExistsAtPath:originalPath])
        path = [[originalPath copy] autorelease];
    [originalPath release];
    return [super openDocumentWithContentsOfURL:[NSURL fileURLWithPath:path] display:aDisplay error:aError];
}

// Closes each document whose window can be closed, asking about changes.
- (void)performCloseAll:(id)aAll
{
    NSEnumerator *documents = [[self documents] objectEnumerator];
    id document;
    while ((document = [documents nextObject])) {
        NSWindowController *controller = [[[document windowControllers] objectEnumerator] nextObject];
        if (controller && [[[controller window] standardWindowButton:NSWindowCloseButton] isEnabled])
            [document canCloseDocumentWithDelegate:self shouldCloseSelector:@selector(document:shouldClose:contextInfo:) contextInfo:NULL];
    }
}

- (void)performMiniaturizeAll:(id)aAll
{
    NSEnumerator *documents = [[self documents] objectEnumerator];
    id document;
    while ((document = [documents nextObject])) {
        NSEnumerator *controllers = [[document windowControllers] objectEnumerator];
        NSWindowController *controller;
        while ((controller = [controllers nextObject])) {
            if (![[controller window] isMiniaturized] && [[[controller window] standardWindowButton:NSWindowMiniaturizeButton] isEnabled])
                [[controller window] miniaturize:self];
        }
    }
}

- (void)showPreferences:(id)aPreferences
{
    [[HSPreferencesController sharedPreferencesController] showWindow:aPreferences];
}

- (void)showHyperAboutBox:(id)aBox
{
    [[HSAboutBoxController sharedInstance] showWindow:aBox];
}

// Close and minimize all need every window closable (the original checks
// the close button for both). Under a modal session only the guides and
// tech support stay available.
- (BOOL)validateUserInterfaceItem:(id)aItem
{
    BOOL result = [super validateUserInterfaceItem:aItem];
    SEL action = [(id<NSValidatedUserInterfaceItem>)aItem action];
    if ([self isModalSessionPresent])
        return action == @selector(openReferenceGuide:) || action == @selector(openTutorial:) || action == @selector(techSupportForHyperStudio:);
    if (action == @selector(performCloseAll:) || action == @selector(performMiniaturizeAll:)) {
        NSEnumerator *documents = [[self documents] objectEnumerator];
        id document;
        while ((document = [documents nextObject])) {
            NSEnumerator *controllers = [[document windowControllers] objectEnumerator];
            NSWindowController *controller;
            while ((controller = [controllers nextObject])) {
                if (![[[controller window] standardWindowButton:NSWindowCloseButton] isEnabled])
                    return NO;
                result = YES;
            }
            if (!result)
                break;
        }
    }
    return result;
}

@end

@implementation EXDocumentController (HSExtension)

- (void)setLastDocument:(id)aDocument
{
    _lastCreatedDocument = aDocument;
}

@end
