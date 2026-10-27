#import "HyperStudioPrefix.h"
#import "HSHelpAssistantPane.h"


@interface HSDropOffPlaceObjectAssistantPane : HSHelpAssistantPane
{
    id<HSDropOffPlaceObjectAssistantPaneDelegate> _delegate;
    HSObjectAssistantNavigationPaneSwitcher *_currentNavigationPaneSwitcher;
    NSUndoManager *_dummyUndoManager;
}
- (id)helpTopicKey;
- (void)paneWillGoBack:(id)aBack;
- (void)cancel:(id)aCancel;
- (id)assistantPaneUndoManager;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (BOOL)needsToBeSavedInHistory;
- (BOOL)assistantShouldBeKeyWindow;
- (BOOL)shouldDismissWhenDisappearedByDefault;
- (id)dummyUndoManager;
- (void)HSAnimationSetupDrawPathAssistantPane_windowDidResignMain:(id)aMain;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)viewDidLoad;
- (id)newBackgroundImage;
- (void)dealloc;
@end

