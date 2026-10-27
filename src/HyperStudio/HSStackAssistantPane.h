#import "HyperStudioPrefix.h"
#import "HSCommentsTextView.h"


@interface HSStackAssistantPane : HSObjectAssistantPane <NSTextViewDelegate, NSTextDelegate, NSObject>
{
    NSTextField *_stackNameTextField;
    NSTextField *_stackSizeTextField;
    NSTextField *_numberOfCardsField;
    HSCommentsTextView *_commentsTextView;
    NSImageView *_cursorImageView;
    NSButton *_cursorButton;
    NSButton *_lockStackButton;
    NSButton *_presentationModeButton;
    NSButton *_arriveThisStackSwitch;
    NSButton *_leaveThisStackSwitch;
    NSButton *_clickThisStackSwitch;
    NSButton *_arriveThisStackButton;
    NSButton *_leaveThisStackButton;
    NSButton *_clickThisStackButton;
    NSButton *_saveChangesCheckBox;
    NSButton *_openHomeStackInSeparateWindowSwitch;
}
+ (BOOL)canEditObject:(id)aObject;
- (void)openActionsPaneForClickEvent:(id)aEvent;
- (void)editClickThisStack:(id)aStack;
- (void)editLeaveThisStack:(id)aStack;
- (void)editArriveThisStack:(id)aStack;
- (void)editPresentationMode:(id)aMode;
- (void)editLockStackState:(id)aState;
- (void)editCursor:(id)aCursor;
- (void)editCardSize:(id)aSize;
- (void)clickingThisStackChanged:(id)aChanged;
- (void)leaveThisStackChanged:(id)aChanged;
- (void)arriveThisStackChanged:(id)aChanged;
- (void)commentsChanged:(id)aChanged;
- (void)setPresentationMode:(id)aMode;
- (void)textDidChange:(id)aChange;
- (void)documentTitleChanged:(id)aChanged;
- (void)HSStackAssistantPane_automaticTimerDidChange:(id)aChange;
- (void)HSStackAssistantPane_actorDidChange:(id)aChange;
- (void)stackCursorAttributesDidChange:(id)aChange;
- (void)stackCommentsAttributesDidChange:(id)aChange;
- (void)textDidEndEditing:(id)aEditing;
- (void)stackContainerAttributesDidChange:(id)aChange;
- (void)stackAttributesDidChange:(id)aChange;
- (void)validateActionSwitches;
- (void)validateCursorView;
- (void)validateCommentsView;
- (void)validateNumberOfCards;
- (void)validateStackSizeField;
- (void)validateStackName;
- (void)validateUI;
- (void)openActionsAssistantForActionEvent:(id)aEvent animate:(BOOL)aAnimate;
- (void)handleActionsAssistantForActionEvent:(id)aEvent;
- (void)unsubscribeFromNotifications;
- (void)subscribeToNotifications;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewDidAppear:(BOOL)aAppear;
- (void)viewWillAppear:(BOOL)aAppear;
- (id)windowTitle;
- (id)stackAttributes;
- (id)init;
- (id)assistantPaneUndoManager;
- (void)toggleOpenHomeStackInSeparateWindow:(id)aWindow;
- (void)validateOpenHomeStackInSeparateWindowSwitch;
- (void)validateSaveChanges;
- (void)saveChangesCheckBoxDidChangeState:(id)aState;
@end

