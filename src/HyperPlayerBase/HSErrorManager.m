#import "HSErrorManager.h"
#import <objc/message.h>
// Presents errors as HyperStudio alerts, modally or as a sheet, and runs
// the error's recovery attempter with the chosen option. Webcam service
// errors get their own alerts. Also checks document package layouts.

@implementation HSErrorManager

+ (id)sharedErrorManager
{
    static HSErrorManager *manager = nil;
    if (!manager)
        manager = [HSErrorManager new];
    return manager;
}

- (id)missingWebCamDatabaseErrorAlert
{
    HSAlert *alert = [HSAlert new];
    HSExecutableResourceProvider *resources = [HSExecutableResourceProvider sharedInstance];
    [alert setMessageText:[resources localizedStringForKey:@"Cannot find webcam database" value:@"" table:@"Alerts"]];
    [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"The database may have been renamed, moved, or deleted, or you may not have sufficient privileges to open it. Reinstall HyperStudio and try again." value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"OK" value:@"" table:@"Alerts"]];
    return [alert autorelease];
}

- (id)genericWebCamServiceErrorAlert
{
    HSAlert *alert = [HSAlert new];
    [alert setMessageText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Cannot open webcam database" value:@"" table:@"Alerts"]];
    [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"There may be file system errors when accessing the webcam database. Choose Check for Updates from the HyperStudio menu to check for available updates and download the webcam database update. If this does not help, submit a Tech Support request by choosing HyperStudio Tech Support from the Help menu." value:@"" table:@"Alerts"]];
    NSString *iconPath = [[NSBundle bundleForClass:[HSWebCamDataProvider class]] pathForResource:@"WebCamServiceIcon" ofType:@"icns"];
    NSImage *icon = [[NSImage alloc] initByReferencingFile:iconPath];
    [alert setIcon:icon];
    [icon release];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"OK" value:@"" table:@"Alerts"]];
    return [alert autorelease];
}

// Sheet ended: recover with the chosen option, or tell the delegate there
// was no recovery (didPresentSelector takes a BOOL and the context info).
- (void)alertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    HSErrorManagerContextInfo *info = (HSErrorManagerContextInfo *)aInfo;
    _isErrorPresent = NO;
    NSError *error = [info error];
    id attempter = [error recoveryAttempter];
    id delegate = [info errorDelegate];
    if ([attempter respondsToSelector:@selector(attemptRecoveryFromError:optionIndex:delegate:didRecoverSelector:contextInfo:)]) {
        [attempter attemptRecoveryFromError:error optionIndex:aCode - NSAlertFirstButtonReturn delegate:delegate didRecoverSelector:[info didPresentSelector] contextInfo:[info contextInfo]];
    } else if (delegate) {
        ((void (*)(id, SEL, BOOL, void *))objc_msgSend)(delegate, [info didPresentSelector], NO, [info contextInfo]);
    }
    [info release];
}

// An iPad document has Contents with a card*.xml, document.xml and
// media.xml.
- (BOOL)isCorrectIPadDocumentFileWrapper:(id)aWrapper
{
    NSFileWrapper *contents = [[aWrapper fileWrappers] objectForKey:@"Contents"];
    NSEnumerator *enumerator = [[[contents fileWrappers] allKeys] objectEnumerator];
    BOOL hasCard = NO, hasDocument = NO, hasMedia = NO;
    NSString *name;
    while (contents && (name = [enumerator nextObject])) {
        if ([name isEqual:@"Resources"])
            continue;
        if (!hasCard && [name hasPrefix:@"card"] && [[name pathExtension] isEqualToString:@"xml"])
            hasCard = YES;
        else if (!hasDocument && [name isEqualToString:@"document.xml"])
            hasDocument = YES;
        else if (!hasMedia && [name isEqualToString:@"media.xml"])
            hasMedia = YES;
    }
    return contents && hasCard && hasDocument && hasMedia;
}

// A document package has a regular .plist or .stack file at the top and a
// Contents folder. (The original also scans each .hsstack in Contents for
// a .hscard, but the flag it tests is never cleared, so stacks without
// cards pass; that scan is left out.)
- (BOOL)isCorrectDocumentFileWrapper:(id)aWrapper
{
    NSDictionary *wrappers = [aWrapper fileWrappers];
    NSEnumerator *enumerator = [[wrappers allKeys] objectEnumerator];
    BOOL found = NO;
    NSString *name;
    while (!found && (name = [enumerator nextObject])) {
        NSFileWrapper *wrapper = [wrappers objectForKey:name];
        if ([[name pathExtension] isEqualToString:@"plist"] || [[name pathExtension] isEqualToString:@"stack"])
            found = [wrapper isRegularFile];
    }
    return found && [wrappers objectForKey:@"Contents"] != nil;
}

- (NSInteger)lastResult
{
    return _lastResult;
}

- (BOOL)presentError:(id)aError
{
    return [self presentError:aError inWindow:nil];
}

- (BOOL)presentError:(id)aError inWindow:(id)aWindow
{
    return [self presentError:aError inWindow:aWindow delegate:nil didPresentSelector:NULL contextInfo:NULL];
}

// Returns whether an error alert is still up (a sheet). Error 10001 is
// never shown.
- (BOOL)presentError:(id)aError inWindow:(id)aWindow delegate:(id)aDelegate didPresentSelector:(SEL)aSelector contextInfo:(void *)aInfo
{
    if (_isErrorPresent || !aError || [(NSError *)aError code] == 10001)
        return _isErrorPresent;

    HSAlert *alert;
    if ([[aError domain] isEqualToString:@"WebCamDataProviderErrorDomain"]) {
        if ([(NSError *)aError code] == 0x900d3 || [(NSError *)aError code] == 0x900d1)
            alert = [self missingWebCamDatabaseErrorAlert];
        else
            alert = [self genericWebCamServiceErrorAlert];
    } else {
        alert = [[HSAlert new] autorelease];
        NSArray *options = [aError localizedRecoveryOptions];
        if (options) {
            NSInteger count = [options count];
            for (NSInteger i = 0; i < count; i++)
                [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:[options objectAtIndex:i] value:@"" table:@"Alerts"]];
        } else {
            [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"OK" value:@"" table:@"Alerts"]];
        }
        [alert setMessageText:[aError localizedDescription]];
        NSString *informativeText = [aError localizedRecoverySuggestion];
        if ([(NSError *)aError code] == NSFileReadCorruptFileError) {
            NSString *path = [[aError userInfo] objectForKey:NSFilePathErrorKey];
            if ([[NSImage imageFileTypes] containsObject:[path pathExtension]])
                informativeText = [NSString stringWithFormat:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSImageCantBeCreatedWithPathInformativeText" value:@"" table:@"Alerts"], [path lastPathComponent]];
        }
        [alert setInformativeText:informativeText ? informativeText : @""];
        [alert setAlertStyle:5];
    }

    _isErrorPresent = YES;
    if (!aWindow) {
        _lastResult = (int)[alert runModal];
        _isErrorPresent = NO;
        // (The original passes the raw modal result as the option index.)
        if ([[aError recoveryAttempter] respondsToSelector:@selector(attemptRecoveryFromError:optionIndex:)])
            [[aError recoveryAttempter] attemptRecoveryFromError:aError optionIndex:_lastResult];
    } else {
        HSErrorManagerContextInfo *info = [[HSErrorManagerContextInfo alloc] initWithError:aError delegate:aDelegate didPresentSelector:aSelector contextInfo:aInfo];
        [alert beginSheetModalForWindow:aWindow modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:info];
    }
    return _isErrorPresent;
}

@end

@implementation HSErrorManagerContextInfo

- (void *)contextInfo
{
    return _contextInfo;
}

- (SEL)didPresentSelector
{
    return _didPresentSelector;
}

- (id)errorDelegate
{
    return _errorDelegate;
}

- (id)error
{
    return _error;
}

- (void)dealloc
{
    [_error release];
    [super dealloc];
}

- (id)initWithError:(id)aError delegate:(id)aDelegate didPresentSelector:(SEL)aSelector contextInfo:(void *)aInfo
{
    self = [super init];
    if (self) {
        _error = [aError retain];
        _errorDelegate = aDelegate;
        _didPresentSelector = aSelector;
        _contextInfo = aInfo;
    }
    return self;
}

@end
