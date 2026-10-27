#import "HyperStudioPrefix.h"
#import "HSCommentsTextView.h"


@interface HSTextFieldAppearanceAssistantPane : HSObjectAssistantPane
{
    NSTextField *_nameTextField;
    HSGradientColorWell *_textColorWell;
    HSGradientColorWell *_backgroundColorWell;
    NSButton *_readOnlyButton;
    NSButton *_roundedButton;
}
+ (BOOL)canEditObject:(id)aObject;
- (void)validateUI;
- (void)validateUIWithNotification:(id)aNotification;
- (void)readOnlyEnabled:(id)aEnabled;
- (void)roundedEnabled:(id)aEnabled;
- (void)setBackgoundColor:(id)aColor;
- (void)setTextColor:(id)aColor;
- (void)setName:(id)aName;
- (id)nameTextfField;
- (id)initialKeyView;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (id)init;
@end

