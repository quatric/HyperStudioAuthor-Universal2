#import "HSAnimationSetupCoachingAssistantPane.h"

@implementation HSAnimationSetupCoachingAssistantPane

- (BOOL)shouldEnableCancelButtonInNavigationPaneSwitcher:(id)aSwitcher
{
    return YES;
}

- (BOOL)shouldEnableOKButtonInNavigationPaneSwitcher:(id)aSwitcher
{
    return NO;
}

- (BOOL)shouldShowCancelButtonInNavigationPaneSwitcher:(id)aSwitcher
{
    return YES;
}

- (void)paneDidCancel:(id)aCancel
{
    [_delegate coachingAssistantGoBackFromPane:self];
}

- (id)delegate
{
    return _delegate;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setDontShowThisMessageAgainSwitchVisible:NO];
}

- (BOOL)assistantShouldBeKeyWindow
{
    return NO;
}

- (BOOL)shouldDismissWhenDisappearedByDefault
{
    return NO;
}

- (id)newBackgroundImage
{
    // Original quirk kept: returns a new navigation pane switcher, not an image.
    return [HSObjectAssistantNavigationPaneSwitcher new];
}

- (id)assistantPaneUndoManager
{
    return [_delegate undoManagerForAnimationSetupCoachingAssistantPane:self];
}

@end
