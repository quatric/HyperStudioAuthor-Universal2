#import "HyperStudioPrefix.h"
#import "HSAssistantPaneApplier.h"
#import "HSCommentsTextView.h"


@interface HSNBAApplier : HSAssistantPaneApplier
{
    HSActionEvent *_initialActionEvent;
    HSAction *_initialAction;
    HSActionEvent *_actionEvent;
    HSAction *_action;
}
- (id)undoActionName;
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (id)addHyperActionOfType:(id)aType forEvent:(id)aEvent;
- (id)initWithObject:(id)aObject actionEvent:(id)aEvent;
- (void)dealloc;
- (id)actor;
@end

@interface HSNewButtonActionsAssistantPane : HSObjectAssistantPane <NSTableViewDataSource, NSObject>
{
    NSTableView *_actionsTable;
    NSTextView *_actionDescriptionView;
    HSSegmentedControl *_segmentedControl;
    HSActionEvent *_actionEvent;
    NSArray *_availableNewButtonActions;
    NSArray *_newButtonActions;
    HSActionsPaneButtonBackgroundRenderer *_buttonBackgroundRenderer;
    HSActionsPaneButtonBackgroundRenderer *_enabledButtonBackgroundRenderer;
    HSAssistantPaneApplier *_applier;
    HSObjectAssistantNavigationPaneSwitcher *_navigationPaneSwitcher;
}
- (void)tableDoubleAction:(id)aAction;
- (void)actionsSourceChanged:(id)aChanged;
- (void)disabledActionsListDidChange:(id)aChange;
- (BOOL)isEnabledActionOfType:(id)aType;
- (id)tableView:(id)aView toolTipForCell:(id)aCell rect:(NSRect *)aRect tableColumn:(id)aColumn row:(NSInteger)aRow mouseLocation:(NSPoint)aLocation;
- (void)tableViewSelectionDidChange:(id)aChange;
- (void)tableView:(id)aView willDisplayCell:(id)aCell forTableColumn:(id)aColumn row:(NSInteger)aRow;
- (id)enabledButtonBackgroundRenderer;
- (id)buttonBackgroundRenderer;
- (void)tableView:(id)aView setObjectValue:(id)aValue forTableColumn:(id)aColumn row:(NSInteger)aRow;
- (id)tableView:(id)aView objectValueForTableColumn:(id)aColumn row:(NSInteger)aRow;
- (NSInteger)numberOfRowsInTableView:(id)aView;
- (void)actionPaneDidClose:(id)aClose withApplier:(id)aApplier canceled:(BOOL)aCanceled;
- (void)paneDidCancel:(id)aCancel;
- (void)paneDidOK:(id)aOK;
- (void)applySettings;
- (void)revertSettings;
- (void)openAssistantPaneForActionType:(id)aType forEvents:(id)aEvents;
- (void)setApplier:(id)aApplier;
- (id)applier;
- (id)windowTitle;
- (id)helpTopicKey;
- (void)HSNewButtonActionsAssistantPane_actorDidChange:(id)aChange;
- (id)initialKeyView;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)updateInUseTab;
- (void)validateActionDescription;
- (void)viewDidLoad;
- (id)navigationPaneSwitcher;
- (id)currentActions;
- (id)inUseButtonActions;
- (id)availableNewButtonActions;
- (id)actionsForObject:(id)aObject ofType:(id)aType forEvent:(id)aEvent;
- (id)actor;
- (void)setActionEvent:(id)aEvent;
- (id)actionEvent;
- (void)dealloc;
- (id)init;
@end

