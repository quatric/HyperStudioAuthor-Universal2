#import "HSAuthorizeStackAlert.h"

@implementation HSAuthorizeStackAlert

- (id)init
{
    self = [super init];
    if (self != nil) {
        HSExecutableResourceProvider *resources = [HSExecutableResourceProvider sharedInstance];
        [self setMessageText:[NSString stringWithFormat:[resources localizedStringForKey:@"HSAuthorizeStackAlertMessageText" value:@"" table:@"Alerts"], [_stack name]]];
        [self setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSAuthorizeStackAlertInformativeText" value:@"" table:@"Alerts"]];
        [self addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSAuthorizeStackAlertFirstButtonTitle" value:@"" table:@"Alerts"]];
        [self addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSAuthorizeStackAlertSecondButtonTitle" value:@"" table:@"Alerts"]];
        [NSBundle loadNibNamed:@"PasswordView" owner:self];
        [self setCustomView:_passwordView];
        [_passwordView release];
        [self setIcon:[NSImage imageNamed:@"alertLock"]];
    }
    return self;
}

- (id)initWithStack:(id)aStack
{
    _stack = aStack;
    return [self init];
}

@end

@implementation HSAuthorizeStackAlert (IBActions)

// A wrong password clears the field and explains why on a sheet.
- (void)firstButtonPressed:(id)aPressed
{
    if ([_stack isPasswordCorrect:[_passwordField stringValue]]) {
        [super firstButtonPressed:aPressed];
        return;
    }
    [_passwordField setStringValue:@""];
    NSString *message = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSAuthorizeStackAlertInvalidPasswordInformativeText" value:@"" table:@"Alerts"];
    NSWindow *window = [self window];
    NSString *button = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSAuthorizeStackAlertInformativeTextButtonTitle" value:@"" table:@"Alerts"];
    NSString *title = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSAuthorizeStackAlertInvalidPasswordTitle" value:@"" table:@"Alerts"];
    // Fix: the message is passed as an argument, not used as the format string.
    NSBeginInformationalAlertSheet(title, button, nil, nil, window, nil, NULL, NULL, NULL, @"%@", message);
}

@end
