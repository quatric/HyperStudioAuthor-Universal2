#import "HyperStudioPrefix.h"


@interface HSRegistrationKeyEquivalentButton : NSButton
{
}
- (BOOL)canBecomeKeyView;
@end

@interface HSRegistrationLinkButton : NSButton
{
}
- (void)resetCursorRects;
@end

@interface HSRegistrationFormController : NSWindowController
{
    int _type;
    NSDictionary *_countriesMap;
    NSView *_optionsView;
    NSView *_buttonsView;
    NSView *_trialOptionsView;
    NSView *_trialReducedOptionsView;
    NSView *_serialOptionsView;
    NSView *_trialButtonsView;
    NSView *_serialButtonsView;
    NSTextField *_trialFirstNameField;
    NSTextField *_trialLastNameField;
    NSTextField *_trialEmailField;
    NSTextField *_trialAddressField;
    NSTextField *_trialCityField;
    NSTextField *_trialZipField;
    NSTextField *_trialSchoolTitleField;
    NSTextField *_trialSchoolNameField;
    NSTextField *_trialSchoolDistrictField;
    NSPopUpButton *_trialCountryPopUp;
    NSPopUpButton *_trialStateProvPopUp;
    NSTextField *_trialStatesStarField;
    NSPopUpButton *_trialMySchoolDistrictPopUp;
    NSPopUpButton *_trialMacsTypePopUp;
    NSButton *_trialSchoolPricesCheckBox;
    NSButton *_trialFreeUpdatesCheckBox;
    NSButton *_trialLessonPlanesCheckBox;
    NSButton *_trialENewsEmailsCheckBox;
    NSButton *_trialPrivacyStatementButton;
    NSTextField *_trialReducedFirstNameField;
    NSTextField *_trialReducedLastNameField;
    NSTextField *_trialReducedEmailField;
    NSButton *_trialReducedSchoolPricesCheckBox;
    NSButton *_trialReducedFreeUpdatesCheckBox;
    NSButton *_trialReducedLessonPlanesCheckBox;
    NSButton *_trialReducedENewsEmailsCheckBox;
    NSButton *_trialReducedPrivacyStatementButton;
    NSTextField *_serialFirstNameField;
    NSTextField *_serialLastNameField;
    NSTextField *_serialEmailField;
    NSTextField *_serialCityField;
    NSTextField *_serialSchoolNameField;
    NSPopUpButton *_serialCountryPopUp;
    NSPopUpButton *_serialStateProvPopUp;
    NSTextField *_serialStatesStarField;
    NSPopUpButton *_serialLocationPopUp;
    NSButton *_serialFreeUpdatesCheckBox;
    NSButton *_serialCompanyNewsCheckBox;
    NSButton *_serialEducationPricingCheckBox;
    NSButton *_serialPrivacyStatementButton;
    NSMenu *_noStatesMenu;
    NSWindow *_privacyStatementWindow;
    struct HSFormControls *_formControls;
}
+ (id)completeRegistrationDictionaryWithSerial:(id)aSerial type:(id)aType;
+ (id)keysDictionaryForType:(id)aType;
+ (id)defaultsPanelOptionsDictionary;
+ (BOOL)shouldShowRegistrationForm;
- (void)paste:(id)aPaste;
- (void)cut:(id)aCut;
- (void)copy:(id)aCopy;
- (void)sheetDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (void)alertSheetDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (void)privacyStatementWindowOK:(id)aOK;
- (void)showPrivacyStatement:(id)aStatement;
- (void)changeUseLocation:(id)aLocation;
- (void)changeCountry:(id)aCountry;
- (void)otherButtonClick:(id)aClick;
- (void)alternateButtonClick:(id)aClick;
- (void)defaultButtonClick:(id)aClick;
- (BOOL)HSRegistrationFormController_isRequiredFieldsFilled:(int *)aFilled;
- (BOOL)HSRegistrationFormController_areTextFieldsValid:(id *)aValid count:(NSUInteger)aCount;
- (NSInteger)HSRegistrationFormController_typeFromRegistrationFormControllerType:(id)aType;
- (NSInteger)runModal;
- (void)HSRegistrationFormController_createPanelOptions;
- (id)HSRegistrationFormController_normalizedString:(id)aString;
- (void)windowDidLoad;
- (void)HSRegistrationFormController_loadPanelOptionsDictionary:(id)aDictionary;
- (id)HSRegistrationFormController_defaultsPanelOptionsFromAddressBook;
- (id)HSRegistrationFormController_menuWithTitles:(id)aTitles;
- (void)HSRegistrationFormController_setupWindow:(id)aWindow forType:(NSInteger)aType;
- (id)initWithType:(id)aType;
- (id)init;
- (void)dealloc;
@end

