#import "HSQuitAnotherApplicationAction.h"
@implementation HSQuitAnotherApplicationAction
- (BOOL)isValid
{
    return [[self applicationToQuit] length] != 0;
}
- (void)setApplicationToQuit:(id)aQuit
{
    if ([_applicationToQuit isEqual:aQuit])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Application To Quit" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setApplicationToQuit:[self applicationToQuit]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSApplicationToQuitAttribute) ofObject:self withUserInfo:nil];
    [_applicationToQuit release];
    _applicationToQuit = [aQuit retain];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSApplicationToQuitAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
}
- (id)applicationToQuit
{
    return _applicationToQuit;
}
// Quits the named application if Finder reports it running. The original
// found "<name>.app" with LSFindApplicationForInfo, got its process from
// LSOpenApplication (kLSLaunchDontSwitch) and sent it a quit Apple event;
// NSRunningApplication -terminate sends the same event.
- (void)startInContext:(id)aContext
{
    NSString *name = [self applicationToQuit];
    if ([name length] != 0) {
        NSString *source = [NSString stringWithFormat:@"tell application \"Finder\"\n get exists application process \"%@\"\nend tell", name];
        NSAppleScript *script = [[[NSAppleScript alloc] initWithSource:source] autorelease];
        NSDictionary *error = nil;
        NSAppleEventDescriptor *result = [script executeAndReturnError:&error];
        if (error == nil && [result booleanValue]) {
            NSString *path = [[NSWorkspace sharedWorkspace] fullPathForApplication:[name stringByAppendingString:@".app"]];
            NSString *identifier = path != nil ? [[NSBundle bundleWithPath:path] bundleIdentifier] : nil;
            if (identifier != nil) {
                for (NSRunningApplication *application in [NSRunningApplication runningApplicationsWithBundleIdentifier:identifier])
                    [application terminate];
            }
        }
    }
    [self notifyDidFinish];
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObject:@"applicationToQuit"];
}
- (void)dealloc
{
    [_applicationToQuit release];
    [super dealloc];
}
@end
