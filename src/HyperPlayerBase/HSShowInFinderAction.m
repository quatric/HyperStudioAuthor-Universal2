#import "HSShowInFinderAction.h"
// Reveals a file in the Finder (searched for from the home folder). Its
// validity is rechecked whenever the app comes forward.
@implementation HSShowInFinderAction
- (void)applicationDidActivate:(id)aActivate
{
    [self updateActionValidationStatus];
}
- (void)setFilePath:(id)aPath
{
    if ([_filePath isEqualToString:aPath])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set File's Path To Show in Finder" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setFilePath:[self filePath]];
    id center = [self attributeNotificationCenter];
    [center notifyChange:1 ofAttribute:@protocol(HSShowInFinderActionAttribute) ofObject:self withUserInfo:nil];
    [center notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    [_filePath release];
    _filePath = [aPath retain];
    [center notifyChange:2 ofAttribute:@protocol(HSShowInFinderActionAttribute) ofObject:self withUserInfo:nil];
    [center notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
}
- (id)filePath
{
    return _filePath;
}
- (BOOL)isValid
{
    if ([[self filePath] length] == 0)
        return NO;
    return [HSNavigationController findFile:[[self filePath] stringByExpandingTildeInPath] base:NSHomeDirectory()] != nil;
}
- (BOOL)isAbleToStartInInvalidState
{
    return YES;
}
- (void)startInContext:(id)aContext
{
    NSString *path = [HSNavigationController findFile:[[self filePath] stringByExpandingTildeInPath] base:NSHomeDirectory()];
    if ([path length] != 0)
        [[NSWorkspace sharedWorkspace] selectFile:path inFileViewerRootedAtPath:@""];
    else {
        HSExecutableResourceProvider *resources = [HSExecutableResourceProvider sharedInstance];
        NSString *name = [[NSFileManager defaultManager] displayNameAtPath:[self filePath]];
        NSString *message = [NSString stringWithFormat:[resources localizedStringForKey:@"HSCannotOpenTheFileAlertMessageTextTemplate" value:@"" table:@"Alerts"], name];
        HSAlert *alert = [HSAlert alertWithMessageText:message defaultButton:[resources localizedStringForKey:@"OK" value:@"" table:@"Alerts"]
                                       alternateButton:nil otherButton:nil
                                       informativeText:[resources localizedStringForKey:@"HSCannotOpenTheFileAlertInformativeText" value:@"" table:@"Alerts"]];
        [aContext displayAlert:alert modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
    }
    [self notifyDidFinish];
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObject:@"filePath"];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_filePath release];
    [super dealloc];
}
- (id)init
{
    self = [super init];
    if (self != nil)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidActivate:)
                                                     name:NSApplicationDidBecomeActiveNotification object:[NSApplication sharedApplication]];
    return self;
}
@end
