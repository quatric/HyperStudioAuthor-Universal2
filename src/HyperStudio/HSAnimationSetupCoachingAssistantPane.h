#import "HyperStudioPrefix.h"
#import "HSHelpAssistantPane.h"


@interface HSAnimationSetupCoachingAssistantPane : HSHelpAssistantPane
{
    id<HSAnimationSetupCoachingAssistantPaneDelegate> _delegate;
}
- (BOOL)shouldEnableCancelButtonInNavigationPaneSwitcher:(id)aSwitcher;
- (BOOL)shouldEnableOKButtonInNavigationPaneSwitcher:(id)aSwitcher;
- (BOOL)shouldShowCancelButtonInNavigationPaneSwitcher:(id)aSwitcher;
- (void)paneDidCancel:(id)aCancel;
- (id)delegate;
- (void)setDelegate:(id)aDelegate;
- (void)viewDidLoad;
- (BOOL)assistantShouldBeKeyWindow;
- (BOOL)shouldDismissWhenDisappearedByDefault;
- (id)newBackgroundImage;
- (id)assistantPaneUndoManager;
- (void)HSAnimationSetupCoachingAssistantPane_windowDidResignMain:(id)aResign;
@end

