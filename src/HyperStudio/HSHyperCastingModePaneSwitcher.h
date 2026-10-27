#import "HyperStudioPrefix.h"
#import "HSObjectAssistantNavigationPaneSwitcher.h"


@interface HSHyperCastingModePaneSwitcher : HSObjectAssistantNavigationPaneSwitcher
{
    NSButton *_defaultButton;
}
- (void)setDefaultButtonTitle:(id)aTitle;
- (id)defaultButtonTitle;
- (void)validateUserInterface;
- (void)viewDidAppear:(BOOL)aAppear;
- (id)init;
@end

