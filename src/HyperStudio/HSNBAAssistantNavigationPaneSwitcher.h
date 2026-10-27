#import "HyperStudioPrefix.h"
#import "HSObjectAssistantNavigationPaneSwitcher.h"


@interface HSNBAAssistantNavigationPaneSwitcher : HSObjectAssistantNavigationPaneSwitcher
{
    NSButton *_toggleHelpButton;
}
- (void)toggleHelp:(id)aHelp;
- (void)validateUserInterface;
- (void)setDelegate:(id)aDelegate;
- (id)init;
@end

