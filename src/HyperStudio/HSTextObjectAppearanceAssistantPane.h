#import "HyperStudioPrefix.h"
#import "HSCommentsTextView.h"


@interface HSTextObjectAppearanceAssistantPane : HSObjectAssistantPane
{
    NSTextField *_nameTextField;
    HSGradientColorWell *_textColorWell;
    NSSlider *_opacitySlider;
    NSTextField *_opacityTextField;
    NSStepper *_opacityStepper;
}
+ (BOOL)canEditObject:(id)aObject;
- (void)validateUI;
- (void)validateUIWithNotification:(id)aNotification;
- (void)opacityChanged:(id)aChanged;
- (void)setTextColor:(id)aColor;
- (void)setName:(id)aName;
- (id)nameTextfField;
- (id)initialKeyView;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)viewDidLoad;
- (id)init;
@end

