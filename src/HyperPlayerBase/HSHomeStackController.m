#import "HSHomeStackController.h"
// The home stack (Go Home): the stack set in the preferences (found again
// if moved, relative to the application) or the default one, and the card
// to return to.
static HSHomeStackController *HSHomeStackControllerSharedController = nil;

@implementation HSHomeStackController
+ (id)homeStackPathPreferencesKey
{
    return HSHomeStackPathPreferencesKey;
}
// Not in Stack-to-Go players.
+ (BOOL)isHomeStackSupportedByCurrentEnvironment
{
    if (![[NSDocumentController sharedDocumentController] isKindOfClass:[HSApplicationController class]])
        return NO;
    return ![(HSApplicationController *)[HSApplicationController sharedDocumentController] isStackToGoController];
}
+ (id)allocWithZone:(NSZone *)aZone
{
    @synchronized(self) {
        if (!HSHomeStackControllerSharedController) {
            HSHomeStackControllerSharedController = [super allocWithZone:aZone];
            return HSHomeStackControllerSharedController;
        }
    }
    return nil;
}
+ (id)sharedHomeStackController
{
    @synchronized(self) {
        if (!HSHomeStackControllerSharedController)
            [[self alloc] init];
    }
    return HSHomeStackControllerSharedController;
}
// While on the home stack, Go Home returns to the current card.
- (void)updateDefaultCardIndexUsingCurrentCard:(id)aCard
{
    if ([[self homeStackURL] isEqual:[[aCard document] fileURL]])
        _defaultCardIndex = (unsigned int)[aCard hyperIndex];
}
- (NSUInteger)defaultCardIndex
{
    return _defaultCardIndex;
}
- (void)resetHomeStackURL
{
    [self setHomeStackURL:[self defaultHomeStackURL]];
}
- (void)setHomeStackURL:(id)aURL storeInDefaults:(BOOL)aDefaults
{
    if ([[self homeStackURL] isEqual:aURL]) {
        if ([[self homeStackURL] isEqual:[self homeStackURLFromPreferences]])
            return;
        if (!aDefaults)
            return;
    }
    if (aDefaults) {
        [[NSUserDefaults standardUserDefaults] setObject:[aURL absoluteString] forKey:[[self class] homeStackPathPreferencesKey]];
        [[NSNotificationCenter defaultCenter] postNotificationName:HSHomeStackURLDidChangeNotification object:self];
    }
    [_tempHomeStackURL release];
    _tempHomeStackURL = [aURL retain];
}
- (void)setHomeStackURL:(id)aURL
{
    [self setHomeStackURL:aURL storeInDefaults:YES];
}
- (id)defaultHomeStackURL
{
    NSString *path = [[HSPathsProvider sharedPathsProvider] defaultHomeStackPath];
    if (path == nil)
        return nil;
    return [NSURL fileURLWithPath:path];
}
- (id)homeStackURL
{
    if (_tempHomeStackURL == nil)
        _tempHomeStackURL = [[self homeStackURLFromPreferences] retain];
    return _tempHomeStackURL;
}
- (id)homeStackURLFromPreferences
{
    NSString *string = [[NSUserDefaults standardUserDefaults] stringForKey:[[self class] homeStackPathPreferencesKey]];
    if (string != nil) {
        NSString *path = [HSNavigationController findFile:[[NSURL URLWithString:string] path] base:[[NSBundle mainBundle] bundlePath]];
        if (path != nil) {
            NSURL *url = [NSURL fileURLWithPath:path];
            if (url != nil)
                return url;
        }
    }
    return [self defaultHomeStackURL];
}
- (void)dealloc
{
    [_tempHomeStackURL release];
    [super dealloc];
}
// A singleton.
- (id)autorelease
{
    return self;
}
- (void)release
{
}
- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}
- (id)retain
{
    return self;
}
- (id)copyWithZone:(NSZone *)aZone
{
    return self;
}
@end
