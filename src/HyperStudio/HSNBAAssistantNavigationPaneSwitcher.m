#import "HSNBAAssistantNavigationPaneSwitcher.h"

@implementation HSNBAAssistantNavigationPaneSwitcher

- (void)toggleHelp:(id)aHelp
{
    if ([[self delegate] isHelpVisible])
        [[self delegate] hideHelp:aHelp];
    else
        [[self delegate] showHelp:aHelp];
    [self validateUserInterface];
}

- (void)validateUserInterface
{
    NSString *key = [[self delegate] isHelpVisible] ? @"HSNBAAssistantPaneHideHelp" : @"HSNBAAssistantPaneShowHelp";
    [_toggleHelpButton setTitle:[[NSBundle mainBundle] localizedStringForKey:key value:@"" table:@"AssistantPanes"]];
    [super validateUserInterface];
}

- (void)setDelegate:(id)aDelegate
{
    [super setDelegate:aDelegate];
}

- (id)init
{
    return [self initWithNibName:@"NBANavigationSwitcher"];
}

@end
