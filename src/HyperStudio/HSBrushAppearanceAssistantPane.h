#import "HyperStudioPrefix.h"
#import "HSCommentsTextView.h"


@interface HSBrushAppearanceAssistantPane : HSObjectAssistantPane
{
    HSGradientColorWell *_brushColorWell;
    NSTextField *_nameTextField;
    NSSlider *_brushSizeSlider;
    NSTextField *_brushSizeTextField;
    NSStepper *_brushSizeStepper;
    NSSlider *_opacitySlider;
    NSTextField *_opacityTextField;
    NSStepper *_opacityStepper;
    NSButton *_shadowSwitch;
    NSButton *_shadowButton;
}
- (id)shadowAttributes;
- (id)opacityAttributes;
- (id)vectorGraphicsAttributes;
- (id)brushAttributes;
- (id)objectAttributes;
- (void)validateShadowUI;
- (void)validateOpacityUI;
- (void)validateColorUI;
- (void)validateBrushUI;
- (void)validateUI;
- (void)validateColorUIWithNotification:(id)aNotification;
- (void)validateShadowUIWithNotification:(id)aNotification;
- (void)validateOpacityUIWithNotification:(id)aNotification;
- (void)validateBrushUIWithNotification:(id)aNotification;
- (void)validateUIWithNotification:(id)aNotification;
- (void)editShadow:(id)aShadow;
- (void)setShadow:(id)aShadow;
- (void)showShadowPane;
- (void)opacityChanged:(id)aChanged;
- (void)brushSizeTextFieldValueChanged:(id)aChanged;
- (void)sizeChanged:(id)aChanged;
- (void)setBrushSize:(CGFloat)aSize;
- (void)colorChanged:(id)aChanged;
- (void)setName:(id)aName;
- (id)nameTextfField;
- (id)initialKeyView;
- (BOOL)isEditingTextAttribute;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (id)init;
@end

