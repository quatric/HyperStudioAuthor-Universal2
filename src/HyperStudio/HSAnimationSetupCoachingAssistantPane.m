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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSAnimationSetupCoachingAssistantPane_windowDidResignMain:) name:NSWindowDidResignMainNotification object:[[[[self stack] document] cardView] window]];
    [_delegate prepareToolAndCardViewForAnimationSetupCoachingAssistantPane:self];
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignMainNotification object:[[[[self stack] document] cardView] window]];
    [super viewWillDisappear:aDisappear];
}

- (void)HSAnimationSetupCoachingAssistantPane_windowDidResignMain:(id)aResign
{
    [_delegate prepareToolAndCardViewAfterSwitchForAnimationSetupCoachingAssistantPane:self];
}

@end
