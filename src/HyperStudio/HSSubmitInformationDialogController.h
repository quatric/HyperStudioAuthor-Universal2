#import "HyperStudioPrefix.h"


@interface HSSubmitInformationDialogController : NSWindowController
{
    NSView *_containerView;
    NSView *_waitingView;
    NSView *_succeededView;
    NSProgressIndicator *_progressIndicator;
    NSButton *_cancelButton;
    NSDictionary *_infoToSend;
    int _trialLicenseState;
}
- (void)mountContentView:(id)aView animated:(BOOL)aAnimated;
- (void)submitInformationErrorAlertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (void)requestAssistance:(id)aAssistance;
- (void)submitInfoDidEndWithResult:(NSInteger)aResult;
- (void)continueButtonPressed:(id)aPressed;
- (void)cancelButtonPressed:(id)aPressed;
- (NSInteger)runModalWithInformationDictionary:(id)aDictionary applicationRegistrationIdentifier:(id)aIdentifier;
- (void)setTrialLicenseState:(NSInteger)aState;
- (NSInteger)trialLicenseState;
- (void)dealloc;
@end

