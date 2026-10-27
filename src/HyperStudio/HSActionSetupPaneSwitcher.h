#import "HyperStudioPrefix.h"
#import "HSObjectAssistantNavigationPaneSwitcher.h"


@interface HSActionSetupPaneSwitcher : HSObjectAssistantNavigationPaneSwitcher
{
    NSButton *_goNextButton;
}
- (void)showHelp:(id)aHelp;
- (void)validateUserInterface;
- (void)setGoNextButtonTitle:(id)aTitle;
- (void)finishSequence:(id)aSequence;
- (void)cancelSequence:(id)aSequence;
- (void)goNext:(id)aNext;
- (void)goToInitialPane;
- (id)firstPane;
- (id)nextPane;
- (id)defaultButtonCell;
@end

