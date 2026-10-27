#import "HyperStudioPrefix.h"
#import "HSCommentsTextView.h"


@interface HSHypertextLinksAssistantPane : HSObjectAssistantPane <NSTextFieldDelegate, NSControlTextEditingDelegate, NSObject, NSTableViewDataSource, NSTableViewDelegate>
{
    NSTextField *_titleTextField;
    NSButton *_addButton;
    NSButton *_replaceButton;
    NSTableView *_linksTableView;
    NSButton *_thisFieldOnlyButton;
    NSButton *_editActionsButton;
    NSString *_initialText;
    HSStack *_initialStack;
    id<HSAttributeObserving, HSTextAttributes> _initialField;
    id _initialPane;
    id<HSHypertextLinkContainerAttributes> _stackContainer;
    id<HSHypertextLinkContainerAttributes> _fieldContainer;
    HSObjectAssistantNavigationPaneSwitcher *_paneSwitcher;
    NSView *_actionHelpView;
    NSTextView *_helpTextView;
    NSAttributedString *_helpText;
    HSObjectAssistantDrawer *_helpDrawer;
    BOOL _helpIsActive;
    id<HSHypertextLink> _linkInModalSession;
}
+ (id)invalidActionImage;
+ (id)validActionImage;
- (void)tableViewSelectionDidChange:(id)aChange;
- (id)tableView:(id)aView toolTipForCell:(id)aCell rect:(NSRect *)aRect tableColumn:(id)aColumn row:(NSInteger)aRow mouseLocation:(NSPoint)aLocation;
- (id)tableView:(id)aView objectValueForTableColumn:(id)aColumn row:(NSInteger)aRow;
- (NSInteger)numberOfRowsInTableView:(id)aView;
- (void)clearTextFieldAndSelectLinkAtIndex:(NSUInteger)aIndex;
- (void)selectLinkAtIndex:(NSUInteger)aIndex;
- (void)updateUI;
- (void)editActions:(id)aActions;
- (void)removeLink:(id)aLink;
- (void)toggleThisFieldOnly:(id)aOnly;
- (void)replaceLink:(id)aLink;
- (void)addLink:(id)aLink;
- (void)changeTitle:(id)aTitle;
- (void)textViewTextDidChange:(id)aChange;
- (void)controlTextDidChange:(id)aChange;
- (void)containerWillChangeDuringModal:(id)aModal;
- (void)containerDidChange:(id)aChange;
- (void)removeLinkAtIndex:(NSUInteger)aIndex;
- (void)replaceLinkAtIndex:(NSUInteger)aIndex withTitle:(id)aTitle;
- (void)addLinkWithTitle:(id)aTitle;
- (BOOL)confirmLinkReplacement;
- (id)containerForLinkAtIndex:(NSUInteger)aIndex;
- (id)linkAtIndex:(NSUInteger)aIndex;
- (NSRange)fieldContainerRange;
- (NSRange)stackContainerRange;
- (NSUInteger)fieldLinkCount;
- (id)fieldContainer;
- (id)stackContainer;
- (id)field;
- (id)document;
- (void)dismissModalViewControllerAnimated:(BOOL)aAnimated;
- (void)presentModalViewController:(id)aController animated:(BOOL)aAnimated;
- (id)windowTitle;
- (void)cleanUp;
- (void)setUp:(id)aUp;
- (BOOL)canClosePane;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)setInitialPane:(id)aPane;
- (id)initialField;
- (void)setInitialField:(id)aField;
- (void)setInitialStack:(id)aStack;
- (void)setInitialText:(id)aText;
- (id)undoManager;
- (BOOL)isEqual:(id)aEqual;
- (BOOL)assistantShouldBeKeyWindow;
- (id)navigationPaneSwitcher;
- (void)hideHelp:(id)aHelp;
- (void)showHelp:(id)aHelp;
- (void)hideHelpNeedsRelayout:(BOOL)aRelayout;
- (id)helpDrawer;
- (BOOL)isHelpVisible;
- (id)actionHelpView;
- (id)helpText;
- (BOOL)requiresDarkBottomArea;
- (void)dealloc;
- (id)init;
@end

