#import "NSApplication+HSAppleScriptNavigationExtension.h"
// AppleScript navigation commands, sent to the main window's document.
@implementation NSApplication (HSAppleScriptNavigationExtension)
- (void)handleHyperGoToSpecificCardScriptCommand:(id)aCommand
{
    id document = [[[NSApp mainWindow] windowController] document];
    if (![document respondsToSelector:@selector(navigationController)])
        return;
    HSNavigationController *controller = [document performSelector:@selector(navigationController)];
    [controller goToCardAtIndex:[[[aCommand evaluatedArguments] objectForKey:@"index"] intValue]];
}
- (void)handleHyperGoToPreviousCardScriptCommand:(id)aCommand
{
    [NSApp sendAction:@selector(goToPreviousCard:) to:nil from:NSApp];
}
- (void)handleHyperGoToNextCardScriptCommand:(id)aCommand
{
    [NSApp sendAction:@selector(goToNextCard:) to:nil from:NSApp];
}
- (void)handleHyperGoToLastCardScriptCommand:(id)aCommand
{
    [NSApp sendAction:@selector(goToLastCard:) to:nil from:NSApp];
}
- (void)handleHyperGoToFirstCardScriptCommand:(id)aCommand
{
    [NSApp sendAction:@selector(goToFirstCard:) to:nil from:NSApp];
}
- (void)handleHyperGoForwardScriptCommand:(id)aCommand
{
    [NSApp sendAction:@selector(goForward:) to:nil from:NSApp];
}
- (void)handleHyperGoBackScriptCommand:(id)aCommand
{
    [NSApp sendAction:@selector(goBack:) to:nil from:NSApp];
}
@end
