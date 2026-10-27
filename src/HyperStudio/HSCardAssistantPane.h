#import "HyperStudioPrefix.h"
#import "HSCommentsTextView.h"


@interface HSCardAssistantPane : HSObjectAssistantPane <NSTextViewDelegate, NSTextDelegate, NSObject, NSTextFieldDelegate, NSControlTextEditingDelegate>
{
    NSTextField *_cardTitleField;
    HSCommentsTextView *_commentsTextView;
    NSImageView *_cursorImageView;
    NSButton *_cursorButton;
    NSButton *_groupCardSwitch;
    NSButton *_markedCardSwitch;
    NSButton *_arriveThisCardSwitch;
    NSButton *_leaveThisCardSwitch;
    NSButton *_clickThisCardSwitch;
    NSButton *_arriveThisCardButton;
    NSButton *_leaveThisCardButton;
    NSButton *_clickThisCardButton;
    id<HSNodeChild> _objectParentObserver;
    BOOL _cardTitleFieldChanged;
}
+ (BOOL)canEditObject:(id)aObject;
- (void)openActionsPaneForArriveEvent:(id)aEvent;
- (void)openActionsPaneForClickEvent:(id)aEvent;
- (void)editClickingThisCard:(id)aCard;
- (void)editLeaveThisCard:(id)aCard;
- (void)editArriveThisCard:(id)aCard;
- (void)editCursor:(id)aCursor;
- (void)clickingThisCardChanged:(id)aChanged;
- (void)leaveThisCardChanged:(id)aChanged;
- (void)arriveThisCardChanged:(id)aChanged;
- (void)markedCardChanged:(id)aChanged;
- (void)groupCardChanged:(id)aChanged;
- (void)commentsChanged:(id)aChanged;
- (void)cardTitleChanged:(id)aChanged;
- (void)textDidChange:(id)aChange;
- (void)HSCardAssistantPane_automaticTimerDidChange:(id)aChange;
- (void)HSCardAssistantPane_actorDidChange:(id)aChange;
- (void)cardCursorAttributesDidChange:(id)aChange;
- (void)cardCommentsAttributesDidChange:(id)aChange;
- (void)controlTextDidChange:(id)aChange;
- (void)textDidEndEditing:(id)aEditing;
- (void)cardAttributesDidChange:(id)aChange;
- (void)validateActionSwitches;
- (void)validateGroupCardSwitch;
- (void)validateMarkedCardSwitch;
- (void)validateCursorView;
- (void)validateCommentsView;
- (void)validateTitleField;
- (void)validateUI;
- (void)openActionsAssistantForActionEvent:(id)aEvent animate:(BOOL)aAnimate;
- (void)handleActionsAssistantForActionEvent:(id)aEvent;
- (void)unsubscribeFromNotifications;
- (void)subscribeToNotifications;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)openPaneWithIdentifier:(id)aIdentifier;
- (id)init;
- (id)assistantPaneUndoManager;
@end

