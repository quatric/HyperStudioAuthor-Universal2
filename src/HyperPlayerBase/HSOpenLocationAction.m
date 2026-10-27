#import "HSOpenLocationAction.h"
#import "HSOpenStackAction.h"
#import "HSNavigationController.h"
#import "HSGoogleEarthAction.h"
#import "HSActionExecutionContext.h"
#import "HSPathsProvider.h"
#import "HSAlert.h"
#import "HSExecutableResourceProvider.h"
#import "NSFileManager+HSExtensions.h"
#import "NSMutableArray+EXMutableArray.h"
#import "EXCodingContext.h"
#import "NSWorkspace+NSEWorkspace.h"

static NSString * const HSOpenLocationActionKeyFlag = @"HSOpenLocationActionKeyFlag";
static NSString * const HSOpenLocationActionKeyContext = @"HSOpenLocationActionKeyContext";
static NSString * const HSOpenLocationActionKeyPath = @"HSOpenLocationActionKeyPath";

static NSDictionary *sAuxiliaryApplicationNames = nil;

static BOOL HSIsHyperStudioApplicationName(NSString *name)
{
    return [name isEqualToString:@"HyperStudio"] || [name isEqualToString:@"HyperStudio 5"] || [name isEqualToString:@"HyperStudio Player"];
}

@implementation HSOpenLocationAction

+ (id)auxiliaryApplicationNamesDictionary
{
    if (sAuxiliaryApplicationNames == nil) {
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"ApplicationNames" ofType:@"plist"];
        sAuxiliaryApplicationNames = [[NSDictionary alloc] initWithContentsOfFile:path];
    }
    return sAuxiliaryApplicationNames;
}

+ (id)actionWithPathToFile:(id)aFile
{
    HSOpenLocationAction *action = [self action];
    if ([[aFile pathExtension] isEqualToString:@"app"]) {
        [action setApplicationName:[[aFile lastPathComponent] stringByDeletingPathExtension]];
        [action setOpensApplication:YES];
    } else {
        [action setURL:[NSURL fileURLWithPath:aFile]];
        [action setOpensDocument:YES];
    }
    return action;
}

// A HyperStudio stack opened with HyperStudio itself is exported as an
// open-stack action.
- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    NSString *appName = [self applicationName];
    if (_opensDocument && [[_URL path] hasSuffix:@".stack"] && (appName == nil || HSIsHyperStudioApplicationName(appName))) {
        NSURL *url = [self URL];
        if (url == nil)
            return nil;
        if (![url isFileURL]) {
            id document = [aContext document];
            if (document == nil)
                return nil;
            NSString *documentPath = [[document fileURL] path];
            if (documentPath == nil)
                return nil;
            NSString *found = [HSNavigationController findFile:[url path] base:[documentPath stringByDeletingLastPathComponent]];
            if (found == nil)
                return nil;
            url = [[[NSURL alloc] initFileURLWithPath:found] autorelease];
        }
        HSOpenStackAction *stackAction = [HSOpenStackAction new];
        [stackAction setURL:url];
        id dict = [stackAction HTML5DictionaryRepresentationInContext:aContext];
        [stackAction release];
        return dict;
    }
    NSMutableDictionary *dict = [super HTML5DictionaryRepresentationInContext:aContext];
    [dict setObject:[self quitAfterLaunch] ? @"1" : @"0" forKey:@"quitAfterLaunch"];
    [dict setObject:[self launchInForeground] ? @"1" : @"0" forKey:@"launchInForeground"];
    [dict setObject:[self opensDocument] ? @"1" : @"0" forKey:@"opensDocument"];
    [dict setObject:[self opensApplication] ? @"1" : @"0" forKey:@"opensApplication"];
    if ([self applicationName] != nil)
        [dict setObject:[self applicationName] forKey:@"applicationName"];
    NSURL *url = [self URL];
    if (url != nil)
        [dict setObject:[url path] forKey:@"src"];
    return dict;
}

- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    NSString *appName = [self applicationName];
    if (!_opensDocument || ![[_URL path] hasSuffix:@".stack"])
        return NO;
    return appName == nil || HSIsHyperStudioApplicationName(appName);
}

- (BOOL)isAbleToStartInInvalidState
{
    return YES;
}

// The document-relative lookup uses the document path itself as the base
// (original behaviour).
- (BOOL)isValid
{
    if ([self opensApplication]) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:[self pathToApplication]]
            && ![[NSFileManager defaultManager] fileExistsAtPath:[self pathToApplicationWithName:[self auxiliaryApplicationName]]])
            return NO;
    }
    NSURL *url;
    if (![self opensDocument] || (url = [self URL]) == nil)
        return YES;
    NSString *path = [url path];
    if (!([url isFileURL] && [[NSFileManager defaultManager] fileExistsAtPath:path]))
        path = [HSNavigationController findFile:path base:[[[self document] fileURL] path]];
    return [[NSFileManager defaultManager] hyperIsReadableFileAtPath:path showAlert:NO error:NULL];
}

- (id)pathToApplication
{
    if (_applicationPath == nil) {
        _applicationPath = [[self pathToApplicationWithName:[self applicationName]] copy];
        if (_applicationPath == nil)
            _applicationPath = [[self pathToApplicationWithName:[self auxiliaryApplicationName]] copy];
    }
    return _applicationPath;
}

// HyperStudio's own applications are looked up among the running
// applications and next to this bundle before asking NSWorkspace.
- (id)pathToApplicationWithName:(id)aName
{
    NSString *appName = [aName stringByAppendingPathExtension:@"app"];
    if (appName == nil)
        return nil;
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *bundlePath = [mainBundle bundlePath];
    if ([[bundlePath lastPathComponent] isEqualToString:appName])
        return bundlePath;
    BOOL isPlayer = [appName isEqualToString:@"HyperStudio Player.app"];
    BOOL isHyperStudio = [appName isEqualToString:@"HyperStudio.app"];
    BOOL isHyperStudio5 = [appName isEqualToString:@"HyperStudio 5.app"];
    NSString *alternateName = @"HyperStudio.app";
    if (isHyperStudio)
        alternateName = @"HyperStudio 5.app";
    else if (!isHyperStudio5)
        alternateName = nil;

    if (isHyperStudio || isPlayer || isHyperStudio5) {
        NSString *names[3] = { appName, alternateName, nil };
        NSArray *launched = [[NSWorkspace sharedWorkspace] launchedApplications];
        NSString **name;
        for (name = names; *name != nil; name++) {
            NSString *baseName = [*name stringByDeletingPathExtension];
            for (NSDictionary *info in launched) {
                if ([[info objectForKey:@"NSApplicationName"] isEqualToString:baseName])
                    return [info objectForKey:@"NSApplicationPath"];
            }
        }
        NSString *dir = [bundlePath stringByDeletingLastPathComponent];
        if (dir == nil)
            return nil;
        for (name = names; *name != nil; name++) {
            NSString *candidate = [dir stringByAppendingPathComponent:*name];
            if (candidate == nil)
                return nil;
            BOOL isDirectory = NO;
            if ([[NSFileManager defaultManager] fileExistsAtPath:candidate isDirectory:&isDirectory] && isDirectory)
                return candidate;
        }
        if (isPlayer) {
            NSString *path = [mainBundle pathForResource:@"HyperStudio Player" ofType:@"app"];
            if (path != nil)
                return path;
        } else if (isHyperStudio5 || isHyperStudio) {
            NSString *outer = [[dir stringByDeletingLastPathComponent] stringByDeletingLastPathComponent];
            if (outer == nil)
                return nil;
            NSString *last = [outer lastPathComponent];
            if (![last isEqualToString:@"HyperStudio 5.app"] && ![last isEqualToString:@"HyperStudio.app"])
                return nil;
            if ([[NSFileManager defaultManager] fileExistsAtPath:outer])
                return outer;
        }
    }
    NSString *path = [[NSWorkspace sharedWorkspace] fullPathForApplication:appName];
    if (path == nil && alternateName != nil)
        path = [[NSWorkspace sharedWorkspace] fullPathForApplication:alternateName];
    return path;
}

- (id)auxiliaryApplicationName
{
    return [[[self class] auxiliaryApplicationNamesDictionary] objectForKey:[self applicationName]];
}

- (void)setOpensApplication:(BOOL)aApplication
{
    if (_opensApplication == aApplication)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Open Application" value:@"" table:@"UndoManager"]];
    [(HSOpenLocationAction *)[[self undoManager] prepareWithInvocationTarget:self] setOpensApplication:[self opensApplication]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSOpenLocationOpensApplicationAttribute) ofObject:self withUserInfo:nil];
    _opensApplication = aApplication;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSOpenLocationOpensApplicationAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
}

- (BOOL)opensApplication
{
    return _opensApplication;
}

- (void)setOpensDocument:(BOOL)aDocument
{
    if (_opensDocument == aDocument)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Open Document" value:@"" table:@"UndoManager"]];
    [(HSOpenLocationAction *)[[self undoManager] prepareWithInvocationTarget:self] setOpensDocument:[self opensDocument]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSOpenLocationOpensDocumentAttribute) ofObject:self withUserInfo:nil];
    _opensDocument = aDocument;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSOpenLocationOpensDocumentAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
}

- (BOOL)opensDocument
{
    return _opensDocument;
}

// Windows paths ("C:\...\App") keep only the last component. The original
// calls substringFromIndex:1 unguarded, which raises for empty names.
- (void)setApplicationName:(id)aName
{
    if ([_applicationName isEqual:aName])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Application Name" value:@"" table:@"UndoManager"]];
    [(HSOpenLocationAction *)[[self undoManager] prepareWithInvocationTarget:self] setApplicationName:[self applicationName]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSOpenLocationApplicationNameAttribute) ofObject:self withUserInfo:nil];
    id name = aName;
    if ([aName length] >= 1 && [[aName substringFromIndex:1] hasPrefix:@":\\"])
        name = [[aName componentsSeparatedByString:@"\\"] lastObject];
    [_applicationName release];
    _applicationName = [name retain];
    if (_applicationName == nil)
        [self setOpensApplication:NO];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSOpenLocationApplicationNameAttribute) ofObject:self withUserInfo:nil];
}

- (id)applicationName
{
    return _applicationName;
}

- (void)setLaunchInForeground:(BOOL)aForeground
{
    if (_launchInForeground == aForeground)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Launch In Foreground" value:@"" table:@"UndoManager"]];
    [(HSOpenLocationAction *)[[self undoManager] prepareWithInvocationTarget:self] setLaunchInForeground:[self launchInForeground]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSOpenLocationLaunchInForegroundAttribute) ofObject:self withUserInfo:nil];
    _launchInForeground = aForeground;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSOpenLocationLaunchInForegroundAttribute) ofObject:self withUserInfo:nil];
}

- (BOOL)launchInForeground
{
    return _launchInForeground;
}

- (void)setQuitAfterLaunch:(BOOL)aLaunch
{
    if (_quitAfterLaunch == aLaunch)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Quit From Player" value:@"" table:@"UndoManager"]];
    [(HSOpenLocationAction *)[[self undoManager] prepareWithInvocationTarget:self] setQuitAfterLaunch:[self quitAfterLaunch]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSOpenLocationQuitAfterLaunchAttribute) ofObject:self withUserInfo:nil];
    _quitAfterLaunch = aLaunch;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSOpenLocationQuitAfterLaunchAttribute) ofObject:self withUserInfo:nil];
}

- (BOOL)quitAfterLaunch
{
    return _quitAfterLaunch;
}

- (void)startInContext:(id)aContext
{
    if ([[self applicationName] isEqualToString:@"Google Earth"]) {
        [self HSOpenLocationAction_startOpenLocationWithContext:aContext];
        return;
    }
    if ([[NSBundle mainBundle] resourceURL] != nil) {
        if ([self findFileAtPath:[[self URL] path] isApplication:NO context:aContext])
            [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:[self URL] display:YES error:NULL];
    }
}

- (void)HSOpenLocationAction_startOpenLocationWithContext:(id)aContext
{
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    BOOL launched = NO;
    if ([self opensApplication]) {
        if (![self findFileAtPath:[self pathToApplication] isApplication:YES context:aContext])
            return;
        if ([self opensDocument]) {
            if (![self findFileAtPath:[[self URL] path] isApplication:NO context:aContext])
                return;
            BOOL foreground = [self launchInForeground];
            launched = [workspace openFile:[[self URL] path] withApplication:_applicationPath andDeactivate:foreground];
        } else {
            NSUInteger options = [self launchInForeground] ? 0x30000 : 0x30200;
            launched = [workspace NSE_launchApplication:_applicationPath options:options configuration:nil error:NULL];
        }
    } else if ([self opensDocument]) {
        if (![self findFileAtPath:[[self URL] path] isApplication:NO context:aContext])
            return;
        BOOL foreground = [self launchInForeground];
        launched = [workspace openFile:[[self URL] path] withApplication:nil andDeactivate:foreground];
    }
    if (!launched && [[self applicationName] isEqualToString:@"Google Earth"])
        [aContext displayAlert:[HSGoogleEarthAction cantLaunchGoogleEarthAlert] modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
    [self notifyDidFinish];
    if (_quitAfterLaunch && ![aContext isInHyperCastingMode])
        [aContext closePlayer];
}

- (void)setURL:(id)aURL
{
    if ([_URL isEqual:aURL])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Action URL" value:@"" table:@"UndoManager"]];
    [(HSOpenLocationAction *)[[self undoManager] prepareWithInvocationTarget:self] setURL:[self URL]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSURLAttribute) ofObject:self withUserInfo:nil];
    [_URL release];
    _URL = [aURL retain];
    if ([self URL] == nil)
        [self setOpensDocument:NO];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSURLAttribute) ofObject:self withUserInfo:nil];
}

- (id)URL
{
    return _URL;
}

- (void)openPanelDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    NSOpenPanel *panel = [aEnd autorelease];
    [panel orderOut:nil];
    NSDictionary *info = [(id)aInfo autorelease];
    if (aCode != 1 || [[panel URLs] count] == 0) {
        [self notifyDidFinish];
        return;
    }
    NSURL *url = [(NSMutableArray *)[panel URLs] extraFirstObject];
    [[HSPathsProvider sharedPathsProvider] setOpenLocationFolder:[[url path] stringByDeletingLastPathComponent]];
    if ([[info objectForKey:HSOpenLocationActionKeyFlag] boolValue]) {
        [_applicationPath release];
        _applicationPath = [[url path] copy];
        [self setApplicationName:[[_applicationPath lastPathComponent] stringByDeletingPathExtension]];
    } else {
        [self setURL:url];
    }
    [self startInContext:[info objectForKey:HSOpenLocationActionKeyContext]];
}

// "Find..." (1000) lets the user locate the missing file or application.
- (void)alertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    [[aEnd window] orderOut:nil];
    [aEnd release];
    NSDictionary *info = [(id)aInfo autorelease];
    if (aCode != 1000) {
        [self notifyDidFinish];
        return;
    }
    NSOpenPanel *panel = [NSOpenPanel new];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:NO];
    NSString *directory = [[info objectForKey:HSOpenLocationActionKeyPath] stringByDeletingLastPathComponent];
    if (![[NSFileManager defaultManager] fileExistsAtPath:directory])
        directory = [[HSPathsProvider sharedPathsProvider] openLocationFolder];
    NSArray *types = nil;
    if ([[info objectForKey:HSOpenLocationActionKeyFlag] boolValue])
        types = [NSArray arrayWithObject:@"app"];
    [info retain];
    NSWindow *window = [[[info objectForKey:HSOpenLocationActionKeyContext] document] windowForSheet];
    [panel beginSheetForDirectory:directory file:nil types:types modalForWindow:window modalDelegate:self didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:) contextInfo:info];
}

- (BOOL)findFileAtPath:(id)aPath isApplication:(BOOL)aApplication context:(id)aContext
{
    if (aPath != nil && [[NSFileManager defaultManager] fileExistsAtPath:aPath])
        return YES;
    if (!aApplication) {
        NSString *base = [[[[aContext document] fileURL] path] stringByDeletingLastPathComponent];
        NSString *found = [HSNavigationController findFile:aPath base:base];
        if (found != nil) {
            [[self undoManager] disableUndoRegistration];
            [self setURL:[NSURL fileURLWithPath:found]];
            [[self undoManager] enableUndoRegistration];
            return YES;
        }
    }
    HSAlert *alert = [HSAlert new];
    [alert setAlertStyle:5];
    HSExecutableResourceProvider *provider;
    NSString *message;
    NSString *informative;
    if (!aApplication) {
        NSString *fileName = [aPath lastPathComponent];
        provider = [HSExecutableResourceProvider sharedInstance];
        message = [NSString stringWithFormat:[provider localizedStringForKey:@"HSOpenLocationActionCantOpenFileMsgDoc" value:@"" table:@"Alerts"], fileName];
        informative = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSOpenLocationActionCantOpenFileInfDoc" value:@"" table:@"Alerts"];
    } else {
        NSString *appName = [self applicationName];
        provider = [HSExecutableResourceProvider sharedInstance];
        message = [NSString stringWithFormat:[provider localizedStringForKey:@"HSOpenLocationActionCantOpenFileMsgApp" value:@"" table:@"Alerts"], appName];
        informative = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSOpenLocationActionCantOpenFileInfApp" value:@"" table:@"Alerts"];
    }
    [alert setMessageText:message];
    [alert setInformativeText:informative];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Find..." value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Cancel" value:@"" table:@"Alerts"]];
    NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys:
                          [NSNumber numberWithBool:aApplication], HSOpenLocationActionKeyFlag,
                          aContext, HSOpenLocationActionKeyContext,
                          aPath, HSOpenLocationActionKeyPath, nil];
    [alert beginSheetModalForWindow:[[aContext document] windowForSheet] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:info];
    return NO;
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSArray *keys = [NSArray arrayWithObjects:[@"URL" extraKeyForMultiRepresentations], @"quitAfterLaunch", @"applicationName", @"opensDocument", @"opensApplication", @"launchInForeground", nil];
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObjectsFromArray:keys];
}

- (void)dealloc
{
    [_applicationPath release];
    [_applicationName release];
    [_URL release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil)
        _launchInForeground = YES;
    return self;
}

@end
