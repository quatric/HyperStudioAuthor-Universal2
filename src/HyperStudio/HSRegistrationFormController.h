#import "HyperStudioPrefix.h"


@interface HSRegistrationFormController : NSWindowController
{
    NSString *_settingsType;
    NSString *_registrationType;
    NSView *_settingsView;
    NSView *_buttonsView;
    NSWindow *_privacyStatementWindow;
    HSRegistrationForm *registrationFormTrial;
    HSRegistrationForm *registrationFormTrialReduced;
    HSRegistrationForm *registrationFormSerial;
    NSView *buttonsViewRegistrationOptional;
    NSView *buttonsViewRegistrationForcedWithGoBack;
    NSView *buttonsViewRegistrationForcedWithQuit;
    NSDictionary *_registrationFormMap;
    NSDictionary *_buttonsViewMap;
}
+ (id)registrationInfoWithSerialNumber:(id)aSerial settingsType:(id)aType;
- (id)initWithRegistrationType:(id)aType settings:(id)aSettings;
- (id)init;
- (void)dealloc;
- (void)windowDidLoad;
- (void)setupWindow:(id)aWindow;
- (NSInteger)runModal;
- (id)buttonsView;
- (id)registrationForm;
- (id)settingsView;
- (id)settingsType;
- (id)registrationType;
- (void)defaultButtonClick:(id)aSender;
- (void)alternateButtonClick:(id)aSender;
- (void)otherButtonClick:(id)aSender;
- (void)otherAlternateButtonClick:(id)aSender;
- (void)alertSheetDidEnd:(id)aAlert returnCode:(int)aCode contextInfo:(void *)aInfo;
- (void)sheetDidEnd:(id)aSheet returnCode:(int)aCode contextInfo:(void *)aInfo;
- (void)showPrivacyStatement:(id)aSender;
- (void)privacyStatementWindowOK:(id)aSender;
- (void)cut:(id)aSender;
- (void)copy:(id)aSender;
- (void)paste:(id)aSender;
- (void)writeRegistrationChoiceToUserDefaultsForModalResult:(int)aResult;
- (void)writeRegistrationTypeToUserDefaults;
@end
