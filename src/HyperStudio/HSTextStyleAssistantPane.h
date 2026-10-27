#import "HyperStudioPrefix.h"
#import "HSCommentsTextView.h"


@interface HSTextStyleAssistantPane : HSObjectAssistantPane
{
    NSComboBox *_fontComboBox;
    NSTextField *_fontSizeTextField;
    NSStepper *_fontSizeStepper;
    HSBlueCircleSlider *_fontSizeSlider;
    HSSegmentedControl *_textStyleMatrix;
    HSGradientColorWell *_textColorWell;
    HSGradientColorWell *_backgroundColorWell;
    HSSegmentedControl *_alignmentMatrix;
    HSSegmentedControl *_verticalAlignmentMatrix;
    NSButton *_characterSpaceSwitch;
    NSTextField *_characterSpaceField;
    NSStepper *_characterSpaceStepper;
    NSButton *_outlineSwitch;
    NSButton *_outlineButton;
    NSButton *_shadowButton;
    NSButton *_shadowSwitch;
    NSTextField *_backgroundTextField;
    HSFontComboboxDataSource *_dataSource;
    float _characterSpaceValue;
    BOOL _isUpdatingFontName;
    id<HSTextAttributes> _observedTextAttributes;
    id<HSSystemTextViewFontTraitsAttributes> _fontAttributes;
    id<HSGenericFontAttributes> _genericFontAttributes;
    BOOL _fontSizeSliderIsTracking;
}
+ (BOOL)canEditObject:(id)aObject;
- (void)controlTextDidEndEditing:(id)aEditing;
- (void)comboBoxSelectionDidChange:(id)aChange;
- (void)applyFontFamilyAtIndex:(NSUInteger)aIndex;
- (void)hyperCustomSliderDidFinishTracking:(id)aTracking;
- (void)hyperCustomSliderDidStartTracking:(id)aTracking;
- (void)validateCharacterSpacingControls;
- (void)validateUI;
- (void)validateUIWithNotification:(id)aNotification;
- (void)enableSpaceCharactersControls:(BOOL)aControls;
- (void)characterSpacingValueChanged:(id)aChanged;
- (void)characterSpacingEnabled:(id)aEnabled;
- (void)fontSizeChanged:(id)aChanged;
- (void)backgroundColorChanged:(id)aChanged;
- (void)textColorChanged:(id)aChanged;
- (void)setVerticalAlignment:(id)aAlignment;
- (void)setAlign:(id)aAlign;
- (void)editShadow:(id)aShadow;
- (void)setShadow:(id)aShadow;
- (void)showShadowPane;
- (void)editOutline:(id)aOutline;
- (void)setOutline:(id)aOutline;
- (void)showOutlinePane;
- (void)setUnderline:(id)aUnderline;
- (void)setItalic:(id)aItalic;
- (void)setBold:(id)aBold;
- (void)setCharacterSpaceValue:(CGFloat)aValue;
- (CGFloat)characterSpaceValue;
- (void)readjustCharacterSpacingValue;
- (void)validateAlignmentMatrixState;
- (void)validateTextStyleMatrixState;
- (void)loadFontComboBox;
- (BOOL)isEditingTextAttribute;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)setObservedTextAttributes:(id)aAttributes;
- (id)lastKeyView;
- (id)firstKeyView;
- (void)viewDidLoad;
- (BOOL)isEnabled;
- (void)dealloc;
- (id)init;
- (void)validateBackgroundColorControls;
@end

