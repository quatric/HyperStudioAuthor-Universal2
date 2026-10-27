#import "HyperStudioPrefix.h"
#import "HSHelpAssistantPane.h"


@interface HSScrollCardPositionAssistantPane : HSHelpAssistantPane <HSPointSelectionToolDelegate>
{
    id<HSPositionAttributes> _positionActionAttributes;
    int _previousToolTag;
    HSPointSelectionTool *_pointSelectionTool;
    id<HSScrollCardPositionAssistantPaneDelegate> _delegate;
    NSPoint _position;
    HSObjectAssistantNavigationPaneSwitcher *_navigationPaneSwitcher;
}
- (void)pointSelectionToolDidCancelSelection;
- (void)pointSelectionTool:(id)aTool selectedPointChange:(NSPoint)aChange;
- (void)setPositionAttributes:(id)aAttributes;
- (id)positionAttributes;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)paneWillGoBack:(id)aBack;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)viewDidLoad;
- (BOOL)shouldDismissWhenDisappearedByDefault;
- (BOOL)needsToBeSavedInHistory;
- (id)navigationPaneSwitcher;
- (void)dealloc;
@end

