#import "HSUnlockStackAssistantPane.h"

@implementation HSUnlockStackAssistantPane

- (id)navigationPaneSwitcher
{
    if (_navigationPaneSwitcher == nil) {
        _navigationPaneSwitcher = [HSLockStackAssistantPaneSwitcher new];
        [_navigationPaneSwitcher setLocking:NO];
        [_navigationPaneSwitcher setDelegate:self];
    }
    return _navigationPaneSwitcher;
}

- (void)paneDidCancel:(id)aCancel
{
    [self hideUnlockStackPane];
}

- (void)rejectPassword
{
    HSAlert *alert = [HSAlert new];
    NSBundle *bundle = [NSBundle mainBundle];
    [alert setMessageText:[bundle localizedStringForKey:@"HSIncorrectPasswordMessageText" value:@"" table:@"Alerts"]];
    [alert setInformativeText:[bundle localizedStringForKey:@"HSIncorrectPasswordInformativeText" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[bundle localizedStringForKey:@"HSIncorrectPasswordTryAgainButtonTitle" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[bundle localizedStringForKey:@"Cancel" value:@"" table:@"Alerts"]];
    if ([alert runModal] == NSAlertSecondButtonReturn)
        [self hideUnlockStackPane];
    [alert release];
}

- (void)acceptPassword
{
    [[self stack] setHyperPassword:nil];
    [self dismiss:YES];
    [[[NSDocumentController sharedDocumentController] currentDocument] switchToEditor];
}

- (BOOL)isPasswordValid
{
    id stack = [self stack];
    if (![stack isStackProtected])
        return NO;
    return [stack isPasswordCorrect:[self password]];
}

- (void)hideUnlockStackPane
{
    [[HSObjectAssistantController sharedAssistantController] setSelectedInModelObject:nil];
}

- (BOOL)requiresDarkBottomArea
{
    return YES;
}

- (void)dealloc
{
    [_navigationPaneSwitcher setDelegate:nil];
    [_navigationPaneSwitcher release];
    [super dealloc];
}

- (id)init
{
    return [super initWithNibName:@"UnlockStackPane"];
}

@end
