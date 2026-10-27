#import "HyperStudioPrefix.h"
#import "HSCommentsTextView.h"


@interface HSActionsAssistantPane : HSObjectAssistantPane <HSAnimationSetupPickImageAssistantPaneDelegate>
{
    HSActionEvent *_actionEvent;
    NSView *_containerView;
    NSView *_placesToGoView;
    NSView *_thingsToDoView;
    NSTableView *_placesToGoTableView;
    NSTableView *_thingsToDoTableView;
    NSArray *_thingsToDoActionTypes;
    NSArray *_placesToGoActionTypes;
    NSArray *_availablePlacesToGoActionTypes;
    HSActionsPaneButtonBackgroundRenderer *_buttonBackgroundRenderer;
    BOOL _hasNavigationSwitcher;
    Class _navigationSwitcherClass;
    HSObjectAssistantNavigationPaneSwitcher *_navigationPaneSwitcher;
}
+ (BOOL)canEditObject:(id)aObject;
- (void)hideAnimationObjectForAssistantPane:(id)aPane;
- (void)cancelFromPickImageAssistantPane:(id)aPane;
- (void)pickMovie:(id)aMovie name:(id)aName forPickImageAssistantPane:(id)aPane;
- (id)actionEventsForObject:(id)aObject;
- (id)tableView:(id)aView toolTipForCell:(id)aCell rect:(NSRect *)aRect tableColumn:(id)aColumn row:(NSInteger)aRow mouseLocation:(NSPoint)aLocation;
- (void)tableView:(id)aView willDisplayCell:(id)aCell forTableColumn:(id)aColumn row:(NSInteger)aRow;
- (id)buttonBackgroundRenderer;
- (void)tableView:(id)aView setObjectValue:(id)aValue forTableColumn:(id)aColumn row:(NSInteger)aRow;
- (id)tableView:(id)aView objectValueForTableColumn:(id)aColumn row:(NSInteger)aRow;
- (NSInteger)numberOfRowsInTableView:(id)aView;
- (id)actionTypeForTableView:(id)aView row:(NSInteger)aRow;
- (id)thingsToDoActionTypes;
- (id)placesToGoActionTypes;
- (id)availablePlacesToGoActionTypes;
- (void)openAssistantPaneForActionType:(id)aType forEvents:(id)aEvents;
- (void)openAssistantPaneForActionType:(id)aType forEvents:(id)aEvents animate:(BOOL)aAnimate;
- (void)openNBAAssistantPane;
- (void)openAutomaticTimerActionsAssistantPane;
- (id)initialKeyView;
- (void)paneWillGoBack:(id)aBack;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)HSActionsAssistantPane_automaticTimerDidChange:(id)aChange;
- (void)HSActionsAssistantPane_actorDidChange:(id)aChange;
- (void)validateNib;
- (void)setActionEvent:(id)aEvent;
- (id)actionEvent;
- (id)actor;
- (void)dealloc;
- (id)navigationPaneSwitcher;
- (id)initWithActionEvent:(id)aEvent navigationSwitcherClass:(Class)aClass;
- (id)initWithActionEvent:(id)aEvent;
- (id)initWithNibName:(id)aName;
- (id)init;
- (id)enabledActionsWithoutHomeStackAllowedActionsForActionType:(id)aType;
@end

@interface HSActionsTableView : NSTableView
{
}
- (void)selectRowIndexes:(id)aIndexes byExtendingSelection:(BOOL)aSelection;
@end

