#import "HSOpenWebPageAction.h"
// Opens a URL in the browser, in the foreground or behind the player.
@implementation HSOpenWebPageAction
// Not in iBooks Author documents.
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return ![aType isEqualToString:@"HSiBooksAuthorDocumentType"];
}
- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    if (![self isValid])
        return nil;
    NSMutableDictionary *dictionary = [super HTML5DictionaryRepresentationInContext:aContext];
    if ([self URL] != nil) {
        [dictionary setObject:[[self URL] absoluteString] forKey:@"href"];
        [dictionary setObject:[self launchInForeground] ? @"1" : @"0" forKey:@"inForeground"];
    }
    return dictionary;
}
- (BOOL)isValid
{
    return [[[self URL] absoluteString] length] != 0;
}
- (void)setLaunchInForeground:(BOOL)aForeground
{
    if (!aForeground == !_launchInForeground)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Launch Browser In Foreground" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setLaunchInForeground:_launchInForeground];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSOpenWebPageInForegroundAttribute) ofObject:self withUserInfo:nil];
    _launchInForeground = aForeground;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSOpenWebPageInForegroundAttribute) ofObject:self withUserInfo:nil];
}
- (BOOL)launchInForeground
{
    return _launchInForeground;
}
- (void)setURL:(id)aURL
{
    if ([aURL isEqual:[self URL]])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change URL" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setURL:[self URL]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSURLAttribute) ofObject:self withUserInfo:nil];
    [_URL release];
    _URL = [aURL retain];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSURLAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
}
- (id)URL
{
    return _URL;
}
// Web player documents always use Safari. The original's options are
// 0x30000 (asynchronous launch, allowing Classic) or 0x200 (without
// activation); Classic is long gone.
- (void)startInContext:(id)aContext
{
    BOOL opened = NO;
    if (_URL != nil) {
        NSArray *URLs = [NSArray arrayWithObject:_URL];
        BOOL webPlayer = [[aContext document] isWebPlayerDocument];
        NSWorkspaceLaunchOptions options = _launchInForeground ? NSWorkspaceLaunchDefault : NSWorkspaceLaunchWithoutActivation;
        opened = [[NSWorkspace sharedWorkspace] openURLs:URLs withAppBundleIdentifier:webPlayer ? @"com.apple.Safari" : nil options:options additionalEventParamDescriptor:nil launchIdentifiers:NULL];
    }
    if (!opened) {
        HSAlert *alert = [HSAlert new];
        HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
        [alert setMessageText:[provider localizedStringForKey:@"HSCannotOpenWebPageMessageText" value:@"" table:@"Alerts"]];
        [alert setInformativeText:[provider localizedStringForKey:@"HSCannotOpenWebPageInformativeText" value:@"" table:@"Alerts"]];
        [alert runModal];
        [alert release];
    }
    [self notifyDidFinish];
}
// Actions stored before the option existed open in the foreground.
- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext
{
    if ([aRepresentation objectForKey:@"launchInForeground"] == nil)
        [self setLaunchInForeground:YES];
    [super loadExtraDictionaryRepresentation:aRepresentation withCodingContext:aContext];
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSArray *keys = [NSArray arrayWithObjects:[@"URL" extraKeyForMultiRepresentations], @"launchInForeground", nil];
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObjectsFromArray:keys];
}
- (void)dealloc
{
    [_URL release];
    [super dealloc];
}
@end
