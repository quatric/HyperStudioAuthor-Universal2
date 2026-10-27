#import "HSActionSetupPaneSwitcher.h"

@implementation HSActionSetupPaneSwitcher

- (void)showHelp:(id)aHelp
{
    if ([[self delegate] respondsToSelector:@selector(helpTopicKey)])
        [[HSHelpBookManager sharedHelpBookManager] openHelpTopic:[[self delegate] helpTopicKey]];
}

- (void)validateUserInterface
{
    [super validateUserInterface];
    BOOL canGoNext = YES;
    if ([[self delegate] respondsToSelector:@selector(canGoToNextPane)])
        canGoNext = [[self delegate] canGoToNextPane];
    [_goNextButton setEnabled:canGoNext && !_isModalWindowRunning];

    BOOL showsContinue = YES;
    if ([[self delegate] respondsToSelector:@selector(shouldRewindToPreviousHubPane)])
        showsContinue = ![[self delegate] shouldRewindToPreviousHubPane];
    if (showsContinue) {
        [_goNextButton setTitle:[[NSBundle mainBundle] localizedStringForKey:@"Continue" value:@"" table:@"AssistantPanes"]];
        [_goNextButton setToolTip:[[NSBundle mainBundle] localizedStringForKey:@"Click to go to the next settings screen." value:@"" table:@"AssistantPanes"]];
        [_goNextButton setAction:@selector(goNext:)];
    } else {
        [_goNextButton setTitle:[[NSBundle mainBundle] localizedStringForKey:@"OK" value:@"" table:@"AssistantPanes"]];
        [_goNextButton setAction:@selector(finishSequence:)];
    }
}

- (void)setGoNextButtonTitle:(id)aTitle
{
    [_goNextButton setTitle:aTitle];
}

- (void)finishSequence:(id)aSequence
{
    if ([[self delegate] respondsToSelector:@selector(paneWillGoToInitial:settingsCanceled:)])
        [[self delegate] paneWillGoToInitial:aSequence settingsCanceled:NO];
    [[self applier] applyChanges];
    [self goToInitialPane];
}

- (void)cancelSequence:(id)aSequence
{
    if ([[self delegate] respondsToSelector:@selector(paneWillGoToInitial:settingsCanceled:)])
        [[self delegate] paneWillGoToInitial:aSequence settingsCanceled:YES];
    [[self applier] restoreIfNotApplied];
    [self goToInitialPane];
}

- (void)goNext:(id)aNext
{
    id assistant = nil;
    if ([[self delegate] respondsToSelector:@selector(objectAssistantForNavigationPaneSwitcher:)])
        assistant = [[self delegate] performSelector:@selector(objectAssistantForNavigationPaneSwitcher:) withObject:self];
    if ([[self delegate] respondsToSelector:@selector(shouldRewindToPreviousHubPane)]
        && [[self delegate] respondsToSelector:@selector(hubPaneClass)]
        && [[self delegate] shouldRewindToPreviousHubPane]) {
        Class hubPaneClass = [[self delegate] hubPaneClass];
        while ([[assistant paneHistory] count] != 0) {
            if ([[[assistant paneHistory] lastObject] class] == hubPaneClass)
                return;
            [assistant assistantGoBack:nil];
        }
        return;
    }
    id pane = [self nextPane];
    if (pane == nil)
        pane = [self firstPane];
    if (pane == nil)
        return;
    if ([[self delegate] respondsToSelector:@selector(willGoToNextPane)])
        [[self delegate] willGoToNextPane];
    [[self navigationController] pushViewController:pane withIdentifier:nil animate:YES replacePrevious:YES];
}

- (void)goToInitialPane
{
    [[self delegate] dismiss:YES];
}

- (id)firstPane
{
    if (![[self delegate] respondsToSelector:@selector(firstPaneForObjectAssistant:)])
        return nil;
    return [[self delegate] firstPaneForObjectAssistant:self];
}

- (id)nextPane
{
    if (![[self delegate] respondsToSelector:@selector(nextPaneForObjectAssistant:)])
        return nil;
    return [[self delegate] nextPaneForObjectAssistant:self];
}

- (id)defaultButtonCell
{
    return [_goNextButton cell];
}

@end
