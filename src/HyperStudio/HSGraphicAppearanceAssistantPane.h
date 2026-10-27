#import "HyperStudioPrefix.h"
#import "HSCommentsTextView.h"


@interface HSGraphicAppearanceAssistantPane : HSObjectAssistantPane
{
    NSTextField *_nameTextField;
    HSGradientColorWell *_frameColorWell;
    NSButton *_shadowButton;
    NSButton *_shadowSwitch;
    NSSlider *_frameWidthSlider;
    NSTextField *_frameWidthTextField;
    NSStepper *_frameWidthStepper;
    NSSlider *_opacitySlider;
    NSTextField *_opacityTextField;
    NSStepper *_opacityStepper;
    NSButton *_highlightSwitch;
    NSButton *_transparentColorButton;
    NSButton *_transparentColorSwitch;
    id<HSTransparentColorAttributes> _transparentColorAttributes;
}
- (id)geometryAttributes;
- (id)shadowAttributes;
- (id)objectAttributes;
- (id)opacityAttributes;
- (id)outlineAttributes;
- (id)highlightAttributes;
- (void)updateHighlight;
- (void)updateName;
- (void)updateOpacity:(CGFloat)aOpacity;
- (void)setOriginalObjectOpacity:(CGFloat)aOpacity;
- (void)updateOutlineControls;
- (void)updateOutlineWidth:(CGFloat)aWidth;
- (void)setOriginalObjectOutlineWidth:(CGFloat)aWidth;
- (void)updateOutlineColor:(id)aColor;
- (void)setOriginalObjectOutlineColor:(id)aColor;
- (void)updateShadow;
- (void)updateOutline;
- (void)validateTransparentAttributesWithNotification:(id)aNotification;
- (void)validateShadowAttributesWithNotification:(id)aNotification;
- (void)validateOpacityAttributesWithNotification:(id)aNotification;
- (void)validateOutlineAttributesWithNotification:(id)aNotification;
- (void)validateOutlineControlsWithNotification:(id)aNotification;
- (void)validateObjectAttributesWithNotification:(id)aNotification;
- (void)validateHighlightAttributesWithNotification:(id)aNotification;
- (void)HSGraphicAppearanceAssistantPane_validateTransparentColorSwitchAndButton;
- (void)editTransparentColor:(id)aColor;
- (void)setTransparentColor:(id)aColor;
- (void)highlightStateChanged:(id)aChanged;
- (void)frameWidthChanged:(id)aChanged;
- (void)colorInWellChanged:(id)aChanged;
- (void)opacityChanged:(id)aChanged;
- (void)editShadow:(id)aShadow;
- (void)setShadow:(id)aShadow;
- (void)showShadowPane;
- (void)setName:(id)aName;
- (id)nameTextfField;
- (id)initialKeyView;
- (BOOL)isEditingTextAttribute;
- (void)viewDidLoad;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)dealloc;
- (id)init;
@end

