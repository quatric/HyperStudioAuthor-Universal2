#import "HyperStudioPrefix.h"
#import "HSActionAssistantSettingsApplier.h"
#import "HSNBAAssistantPane.h"


@interface HSCompareTextActionAssistantPane : HSNBAAssistantPane
{
    HSPopUpButton *_responseObjectPopUpButton;
    HSPopUpButton *_textToMatchObjectPopUpButton;
    HSPopUpButton *_comparisonSelectorPopUpButton;
    NSTextField *_definedStringTextField;
    HSPopUpButton *_rightAnswerObjectPopUpButton;
    HSPopUpButton *_wrongAnswerObjectPopUpButton;
    HSCheckBox *_ignoreCaseSensitivityButton;
    HSStack *_stack;
    NSMenu *_rightAnswerObjectsMenu;
    NSMenu *_wrongAnswerObjectsMenu;
    NSMenu *_responseObjectsMenu;
    NSMenu *_textToMatchObjectsMenu;
    NSMenu *_comparisonSelectorMenu;
}
- (void)ignoreCaseSensitivityChanged:(id)aChanged;
- (void)comparisonSelectorChanged:(id)aChanged;
- (void)definedStringChanged:(id)aChanged;
- (void)wrongAnswerObjectChanged:(id)aChanged;
- (void)rightAnswerObjectChanged:(id)aChanged;
- (void)textToMatchObjectChanged:(id)aChanged;
- (void)responseObjectChanged:(id)aChanged;
- (void)controlTextDidChange:(id)aChange;
- (id)helpTopicKey;
- (void)autosetupActionSettings;
- (void)validateUI;
- (void)validatePopUpButton:(id)aButton withMenu:(id)aMenu;
- (void)popUpButtonWillPopUp:(id)aUp;
- (id)wrongAnswerCardsMenu;
- (id)rightAnswerCardsMenu;
- (id)textToMatchObjectsMenu;
- (id)responseObjectsMenu;
- (void)composeMenues;
- (void)validateUIWithNotification:(id)aNotification;
- (id)initialKeyView;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (id)actionAttribute;
- (id)actionAttributes;
- (id)actionType;
- (id)compareTextActionAssistantPaneApplier;
- (Class)applierClass;
- (void)dealloc;
- (id)init;
@end

@interface HSCompareTextActionAssistantPaneApplier : HSActionAssistantSettingsApplier
{
    HSUID *_initialResponseObjectUID;
    HSUID *_initialTextToMatchObjectUID;
    NSString *_initialDefinedString;
    HSUID *_initialComparisonMatchObjectUID;
    HSUID *_initialComparisonMismatchObjectUID;
    SEL _initialComparisonSelector;
    BOOL _isCaseSensitiveComparisonInitially;
    HSUID *_responseObjectUID;
    HSUID *_textToMatchObjectUID;
    NSString *_definedString;
    HSUID *_comparisonMatchObjectUID;
    HSUID *_comparisonMismatchObjectUID;
    SEL _comparisonSelector;
    BOOL _isCaseSensitiveComparison;
}
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setCaseSensitiveComparison:(BOOL)aComparison;
- (void)setComparisonSelector:(SEL)aSelector;
- (void)setDefinedString:(id)aString;
- (void)setComparisonMismatchObjectUID:(id)aUID;
- (void)setComparisonMatchObjectUID:(id)aUID;
- (void)setTextToMatchObjectUID:(id)aUID;
- (void)setResponseObjectUID:(id)aUID;
- (id)compareTextActionAttributes;
- (void)setUpInitialSettings;
- (void)dealloc;
@end

