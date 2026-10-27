#import "HSLockStackAssistantPaneSwitcher.h"

@implementation HSLockStackAssistantPaneSwitcher

- (void)viewDidAppear:(BOOL)aAppear
{
    [super viewDidAppear:aAppear];
    [[[self view] window] setDefaultButtonCell:[_lockButton cell]];
}

- (void)updateLockButtonTitle
{
    [_lockButton setTitle:[[NSBundle mainBundle] localizedStringForKey:[self isLocking] ? @"HSLockStackButtonTitle" : @"HSUnlockStackButtonTitle" value:@"" table:@"AssistantPanes"]];
}

- (void)setLocking:(BOOL)aLocking
{
    if (_isLocking != aLocking) {
        _isLocking = aLocking;
        [self updateLockButtonTitle];
    }
}

- (BOOL)isLocking
{
    return _isLocking;
}

- (void)viewDidLoad
{
    [self updateLockButtonTitle];
}

- (id)init
{
    return [self initWithNibName:@"LockStackPaneSwitcher"];
}

@end
