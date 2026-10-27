#import "HSLockStackAssistantPane.h"

@implementation HSLockStackAssistantPane

- (BOOL)passwordContainsWrongSymbols
{
    return [[self password] rangeOfCharacterFromSet:[self invalidCharactersSet] options:NSBackwardsSearch].location != NSNotFound;
}

- (void)showIncorrectPasswordConfirmationAlert
{
    HSAlert *alert = [HSAlert new];
    [alert setMessageText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSIncorrectPasswordConfirmationMessageText" value:@"" table:@"Alerts"]];
    [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSIncorrectPasswordConfirmationInformativeText" value:@"" table:@"Alerts"]];
    [alert runModal];
    [alert release];
}

- (void)showWrongPasswordSymbolsAlert
{
    NSString *message = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Password cannot contain certain system symbols" value:@"" table:@"Alerts"];
    NSString *information = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"The password can only contain letters, numbers, spaces and punctuation marks." value:@"" table:@"Alerts"];
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert setMessageText:message];
    [alert setInformativeText:information];
    [alert runModal];
}

- (id)navigationPaneSwitcher
{
    if (_navigationPaneSwitcher == nil) {
        _navigationPaneSwitcher = [HSLockStackAssistantPaneSwitcher new];
        [_navigationPaneSwitcher setLocking:YES];
        [_navigationPaneSwitcher setDelegate:self];
    }
    return _navigationPaneSwitcher;
}

- (id)nibName
{
    return @"LockStackPane";
}

- (void)rejectPassword
{
    if ([self passwordContainsWrongSymbols])
        [self showWrongPasswordSymbolsAlert];
    else
        [self showIncorrectPasswordConfirmationAlert];
}

- (void)acceptPassword
{
    [[self assistant] hideAssistant:NO];
    id stack = [self stack];
    [self dismiss:YES slide:NO];
    [stack setHyperPassword:[self password]];
}

- (BOOL)isPasswordValid
{
    if (![[[_confirmationTextField stringValue] lowercaseString] isEqualToString:[self password]])
        return NO;
    return ![self passwordContainsWrongSymbols];
}

- (void)setPasswordConfirmation:(id)aConfirmation
{
    NSString *confirmation = [aConfirmation lowercaseString];
    if (![confirmation isEqualToString:[self passwordConfirmation]])
        [_confirmationTextField setStringValue:confirmation];
}

- (id)passwordConfirmation
{
    return [[_confirmationTextField stringValue] lowercaseString];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [_confirmationTextField setDelegate:self];
    NSString *password = [[self stack] recentPassword];
    if (password != nil) {
        [self setPassword:password];
        [self setPasswordConfirmation:password];
    }
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

@end
