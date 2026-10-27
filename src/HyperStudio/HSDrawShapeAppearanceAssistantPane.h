#import "HyperStudioPrefix.h"
#import "HSCommentsTextView.h"


@interface HSDrawShapeAppearanceAssistantPane : HSObjectAssistantPane
{
    HSGradientColorWell *_fillColorWell;
    NSTextField *_nameTextField;
    HSGradientColorWell *_outlineColorWell;
    id _shadowButton;
    NSButton *_shadowSwitch;
    HSSegmentedControl *_fillTypeMatrix;
    NSSlider *_outlineSizeSlider;
    NSTextField *_outlineTextField;
    NSStepper *_outlineStepper;
    NSSlider *_opacitySlider;
    NSTextField *_opacityTextField;
    NSStepper *_opacityStepper;
    id<HSGraphics> _oldBackgroundGraphics;
    HSVectorGraphicsLineDashInfoObject *_oldLineInfo;
    id _hyperObjectForVectorGraphics;
}
- (id)shapeTypeControlFillWithOutlineImage;
- (id)shapeTypeControlFillImage;
- (id)shapeTypeControlOutlineImage;
- (id)opacityAttributes;
- (id)shadowAttributes;
- (id)backgroundAttributes;
- (id)objectAttributes;
- (id)vectorGraphics;
- (void)validateShadowUI;
- (void)validateOpacityUI;
- (void)validateUI;
- (void)validateColorUI;
- (void)validateShadowUIWithNotification:(id)aNotification;
- (void)validateOpacityUIWithNotification:(id)aNotification;
- (void)validateColorUIWithNotification:(id)aNotification;
- (void)validateUIWithNotification:(id)aNotification;
- (void)opacityChanged:(id)aChanged;
- (void)editShadow:(id)aShadow;
- (void)setShadow:(id)aShadow;
- (void)showShadowPane;
- (void)outlineSizeChanged:(id)aChanged;
- (void)outlineColorChanged:(id)aChanged;
- (void)fillColorChanged:(id)aChanged;
- (void)fillTypeChanged:(id)aChanged;
- (id)defaultStrokeLineColor;
- (CGFloat)defaultLineWidth;
- (id)defaultBackgroundGraphics;
- (void)storeStrokeLineColorAsDefault;
- (void)storeLineWidthAsDefault;
- (void)storeBackgroundGraphicsAsDefault;
- (void)setName:(id)aName;
- (void)dealloc;
- (id)nameTextfField;
- (id)initialKeyView;
- (BOOL)isEditingTextAttribute;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)viewDidLoad;
- (id)init;
@end

