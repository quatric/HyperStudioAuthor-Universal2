#import "HyperStudioPrefix.h"
#import "HSCommentsTextView.h"


@interface HSGenericPasswordAssistantPane : HSObjectAssistantPane <NSTextFieldDelegate, NSControlTextEditingDelegate, NSObject>
{
    NSSecureTextField *_passwordTextField;
    NSCharacterSet *_invalidCharactersSet;
}
- (void)controlTextDidChange:(id)aChange;
- (id)invalidCharactersSet;
- (void)setPassword:(id)aPassword;
- (id)password;
- (void)rejectPassword;
- (void)acceptPassword;
- (BOOL)isPasswordValid;
- (void)paneDidOK:(id)aOK;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)dealloc;
@end

