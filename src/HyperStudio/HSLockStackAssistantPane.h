#import "HyperStudioPrefix.h"
#import "HSGenericPasswordAssistantPane.h"


@interface HSLockStackAssistantPane : HSGenericPasswordAssistantPane <NSTextFieldDelegate, NSControlTextEditingDelegate, NSObject>
{
    NSSecureTextField *_confirmationTextField;
    HSLockStackAssistantPaneSwitcher *_navigationPaneSwitcher;
}
- (BOOL)passwordContainsWrongSymbols;
- (void)showIncorrectPasswordConfirmationAlert;
- (void)showWrongPasswordSymbolsAlert;
- (id)navigationPaneSwitcher;
- (id)nibName;
- (void)rejectPassword;
- (void)acceptPassword;
- (BOOL)isPasswordValid;
- (void)setPasswordConfirmation:(id)aConfirmation;
- (id)passwordConfirmation;
- (void)viewWillAppear:(BOOL)aAppear;
- (BOOL)requiresDarkBottomArea;
- (void)dealloc;
@end

