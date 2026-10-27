#import "HSGenericPasswordAssistantPane.h"

@implementation HSGenericPasswordAssistantPane

- (void)controlTextDidChange:(id)aChange
{
    NSTextField *field = [aChange object];
    NSString *string = [field stringValue];
    if ([string length] < 16)
        return;
    [field setStringValue:[string substringToIndex:15]];
    NSBeep();
}

- (id)invalidCharactersSet
{
    if (_invalidCharactersSet == nil)
        _invalidCharactersSet = [[[NSCharacterSet characterSetWithRange:NSMakeRange(0x21, 0x5e)] invertedSet] retain];
    return _invalidCharactersSet;
}

- (void)setPassword:(id)aPassword
{
    NSString *password = [aPassword lowercaseString];
    if (![password isEqualToString:[self password]])
        [_passwordTextField setStringValue:password];
}

- (id)password
{
    return [[_passwordTextField stringValue] lowercaseString];
}

- (void)rejectPassword
{
}

- (void)acceptPassword
{
}

- (BOOL)isPasswordValid
{
    return NO;
}

- (void)paneDidOK:(id)aOK
{
    if ([self isPasswordValid])
        [self acceptPassword];
    else
        [self rejectPassword];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [_passwordTextField setDelegate:self];
}

- (void)dealloc
{
    [_invalidCharactersSet release];
    [super dealloc];
}

@end
