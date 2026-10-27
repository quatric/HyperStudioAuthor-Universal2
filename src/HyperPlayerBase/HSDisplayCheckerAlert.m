#import "HSDisplayCheckerAlert.h"
@implementation HSDisplayCheckerAlert
- (void)stopModal
{
    [self setCanClose:YES];
    [self close];
}
- (id)init
{
    self = [super init];
    if (self != nil) {
        NSString *appName = [[[[NSBundle mainBundle] bundlePath] lastPathComponent] stringByDeletingPathExtension];
        HSExecutableResourceProvider *resources = [HSExecutableResourceProvider sharedInstance];
        [self setMessageText:[NSString stringWithFormat:
            [resources localizedStringForKey:@"HSMinSpecAlertMessageText" value:@"" table:@"Alerts"], appName]];
        [self setInformativeText:[NSString stringWithFormat:
            [resources localizedStringForKey:@"HSMinSpecAlertInformativeText" value:@"" table:@"Alerts"], appName, appName]];
        [self addButtonWithTitle:[resources localizedStringForKey:@"HSMinSpecAlertFirstButtonTitle" value:@"" table:@"Alerts"]];
        [self addButtonWithTitle:[resources localizedStringForKey:@"HSMinSpecAlertSecondButtonTitle" value:@"" table:@"Alerts"]];
        [self setCanClose:NO];
    }
    return self;
}
@end

@implementation HSDisplayCheckerAlert (IBActions)
- (void)secondButtonPressed:(id)aPressed
{
    [self setCanClose:YES];
    [super secondButtonPressed:aPressed];
}
- (void)firstButtonPressed:(id)aPressed
{
    [[NSWorkspace sharedWorkspace] openFile:@"/System/Library/PreferencePanes/Displays.prefPane"];
    [super firstButtonPressed:aPressed];
}
@end
