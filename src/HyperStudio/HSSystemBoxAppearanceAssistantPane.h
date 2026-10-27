#import "HyperStudioPrefix.h"
#import "HSCommentsTextView.h"


@interface HSSystemBoxAppearanceAssistantPane : HSObjectAssistantPane
{
    NSTextField *_nameTextField;
    NSTextField *_titleTextField;
    NSButton *_showTitleSwitch;
}
- (void)validateTitle;
- (void)validateName;
- (void)validateUI;
- (void)validateTitleWithNotification:(id)aNotification;
- (void)validateNameWithNotification:(id)aNotification;
- (void)changeTitleVisibility:(id)aVisibility;
- (void)changeTitle:(id)aTitle;
- (void)changeName:(id)aName;
- (id)nameTextfField;
- (id)initialKeyView;
- (BOOL)isEditingTextAttribute;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (id)init;
@end

