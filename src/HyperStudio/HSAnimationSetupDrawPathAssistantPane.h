#import "HyperStudioPrefix.h"
#import "HSHelpAssistantPane.h"


@interface HSAnimationSetupDrawPathAssistantPane : HSHelpAssistantPane
{
    id<HSAnimationSetupDrawPathAssistantPaneDelegate> _delegate;
    HSObjectAssistantNavigationPaneSwitcher *_currentNavigationPaneSwitcher;
    NSButton *_cancelButton;
    BOOL _isSegmentedPathCreationModeActive;
    BOOL _pathCreationCanBeFinished;
}
- (void)setupUIForNonSegmentedPathCreationMode;
- (void)setupUIForSegmentedPathCreationMode;
- (id)windowTitle;
- (id)helpTopicKey;
- (void)setPathCreationCanBeFinished:(BOOL)aFinished;
- (void)updatePaneSwitcherIfNeeded;
- (void)paneContinue:(id)aContinue;
- (void)paneWillGoBack:(id)aBack;
- (void)cancel:(id)aCancel;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (BOOL)needsToBeSavedInHistory;
- (BOOL)assistantShouldBeKeyWindow;
- (BOOL)shouldDismissWhenDisappearedByDefault;
- (void)paneDidCancel:(id)aCancel;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)viewDidLoad;
- (id)newBackgroundImage;
- (id)assistantPaneUndoManager;
@end

