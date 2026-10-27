#import "HSHyperCastingModePaneSwitcher.h"

@implementation HSHyperCastingModePaneSwitcher

- (void)setDefaultButtonTitle:(id)aTitle
{
    [_defaultButton setTitle:aTitle];
}

- (id)defaultButtonTitle
{
    return [_defaultButton title];
}

- (void)validateUserInterface
{
    BOOL enabled = YES;

    if ([[self delegate] respondsToSelector:@selector(shouldEnableOKButtonInNavigationPaneSwitcher:)])
        enabled = [[self delegate] shouldEnableOKButtonInNavigationPaneSwitcher:self];
    [_defaultButton setEnabled:enabled && !_isModalWindowRunning];
    [super validateUserInterface];
}

- (void)viewDidAppear:(BOOL)aAppear
{
    [super viewDidAppear:aAppear];
    [[[self view] window] setDefaultButtonCell:[_defaultButton cell]];
}

- (id)init
{
    return [self initWithAssistantSettingsApplier:nil windowNibName:@"HyperCastingModePaneSwitcher"];
}

@end
