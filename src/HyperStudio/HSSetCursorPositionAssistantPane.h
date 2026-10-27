#import "HyperStudioPrefix.h"
#import "HSHelpAssistantPane.h"


@interface HSSetCursorPositionAssistantPane : HSHelpAssistantPane <HSPointSelectionToolDelegate, HSActionAssistantPaneActionEvents, NSObject>
{
    int _previousToolTag;
    HSPointSelectionTool *_pointSelectionTool;
    id _delegate;
    NSPoint _position;
    HSObjectAssistantNavigationPaneSwitcher *_navigationPaneSwitcher;
    NSArray *_actionEvents;
}
- (void)pointSelectionToolDidCancelSelection;
- (void)pointSelectionTool:(id)aTool selectedPointChange:(NSPoint)aChange;
- (void)setActionEvents:(id)aEvents;
- (id)actionEvents;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)paneWillGoBack:(id)aBack;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)viewDidLoad;
- (BOOL)assistantShouldBeKeyWindow;
- (BOOL)shouldDismissWhenDisappearedByDefault;
- (BOOL)needsToBeSavedInHistory;
- (id)navigationPaneSwitcher;
- (void)dealloc;
- (void)HSSetCursorPositionAssistantPane_windowDidResignMain:(id)aResign;
@end

