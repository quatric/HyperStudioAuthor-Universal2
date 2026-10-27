#import "HyperStudioPrefix.h"
#import "HSCommentsTextView.h"


@interface HSButtonObjectAssistantPane : HSObjectAssistantPane
{
    NSMatrix *_buttonTypeMatrix;
    SMKTintedView *_tintedView;
    NSButton *_updateStyleButton;
    NSButton *_showTitleSwitch;
    NSButton *_showIconSwitch;
    NSButton *_highlightSwitch;
    NSButton *_showIconButton;
    HSGradientColorWell *_titleColorWell;
    HSGradientColorWell *_backgroundColorWell;
    BOOL _titleDidChange;
    NSTextField *_titleTextField;
    HSButtonObjectAssistantPaneState *_paneState;
    BOOL _needToRelayoutAssistance;
}
+ (BOOL)canEditObject:(id)aObject;
- (void)applyShapeBackgroundStyleWithButtonType;
- (void)applySystemBackgroundStyleWithButtonType;
- (void)applyPaneStateToButtonObject;
- (void)selectToolWithTag:(NSInteger)aTag;
- (void)finishButtonTypeEditingWithSelectingToolWithTag:(NSInteger)aTag;
- (void)runDrawShapeBackground;
- (void)setBackgrounStyle:(id)aStyle withButtonType:(id)aType;
- (NSUInteger)toolTagForShapeButtonType:(id)aType;
- (NSInteger)tagForButtonType:(id)aType;
- (id)currentButtonType;
- (id)shapeBackgroundInterface;
- (id)systemBackgroundInterface;
- (id)buttonObjectInterface;
- (void)runImagesDialog;
- (void)validateUIElements;
- (void)validateUIElementsWithNotification:(id)aNotification;
- (void)updateButtonObjectStyle:(id)aStyle;
- (void)controlTextDidChange:(id)aChange;
- (void)titleTextFieldChanged:(id)aChanged;
- (void)commitTitleChangesToModel;
- (void)backgroundColorChanged:(id)aChanged;
- (void)titleColorChanged:(id)aChanged;
- (void)highlightStateChanged:(id)aChanged;
- (void)showIconStateChanged:(id)aChanged;
- (void)showTitleStateChanged:(id)aChanged;
- (void)iconsButtonClicked:(id)aClicked;
- (void)lassoAreaShapeButtonTypeChosen:(id)aChosen;
- (void)expandingAreaShapeButtonTypeChosen:(id)aChosen;
- (void)freehandAreaButtonTypeChosen:(id)aChosen;
- (void)invisibleShapeButtonTypeChosen:(id)aChosen;
- (void)dropShadowRectangleSystemButtonTypeChosen:(id)aChosen;
- (void)rectangleSystemButtonTypeChosen:(id)aChosen;
- (void)defaultSystemButtonTypeChosen:(id)aChosen;
- (void)regularSystemButtonTypeChosen:(id)aChosen;
- (id)nameTextfField;
- (id)initialKeyView;
- (BOOL)needToRelayoutAssistant;
- (BOOL)assistantShouldBeKeyWindow;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)viewDidLoad;
- (id)init;
@end

