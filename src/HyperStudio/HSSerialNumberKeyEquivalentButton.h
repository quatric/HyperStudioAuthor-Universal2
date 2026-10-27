#import "HyperStudioPrefix.h"


@interface HSSerialNumberKeyEquivalentButton : NSButton
{
}
- (BOOL)canBecomeKeyView;
@end

@interface HSSerialNumberDialogController : NSWindowController <NSTextFieldDelegate, NSControlTextEditingDelegate, NSObject>
{
    NSString *_dialogType;
    NSView *_contentView;
    NSView *_buttonsView;
    NSView *_commonContentView;
    NSView *_commonButtonsView;
    NSView *_trialContentView;
    NSView *_trialButtonsView;
    NSView *_trialExtendedContentView;
    NSView *_trialExtendedButtonsView;
    NSView *_trialLastExtendedContentView;
    NSView *_trialLastExtendedButtonsView;
    NSView *_activateContentView;
    NSView *_activateButtonsView;
    NSButton *_commonContinueButton;
    NSButton *_commonQuitButton;
    NSButton *_commonAlternateButton;
    NSButton *_trialContinueButton;
    NSButton *_trialQuitButton;
    NSButton *_trialAlternateButton;
    NSButton *_trialExtendedContinueButton;
    NSButton *_trialExtendedQuitButton;
    NSButton *_trialExtendedAlternateButton;
    NSButton *_trialExtendedAlternateOtherButton;
    NSButton *_trialLastExtendedContinueButton;
    NSButton *_trialLastExtendedQuitButton;
    NSButton *_trialLastExtendedAlternateButton;
    NSButton *_trialLastExtendedAlternateOtherButton;
    NSButton *_activateContinueButton;
    NSButton *_activateQuitButton;
    NSButton *_activateAlternateButton;
    NSTextField *_commonSerialString;
    NSTextField *_trialSerialString;
    NSTextField *_trialExtendedSerialString;
    NSTextField *_trialLastExtendedSerialString;
    NSTextField *_activateSerialString;
    NSTextField *_activateInformationString;
    NSButton *_firstExtensionLinkButton;
    NSButton *_lastExtensionLinkButton;
    NSButton *_continueButton;
    NSButton *_quitButton;
    NSButton *_alternateButton;
    NSButton *_alternateOtherButton;
    NSTextField *_serialStringField;
    id _delegate;
    id _validationContext;
    int _result;
}
- (void)controlTextDidChange:(id)aChange;
- (void)linkPressed:(id)aPressed;
- (void)orderNow:(id)aNow;
- (void)actionLicenseInfo:(id)aInfo;
- (void)actionAlternateOther:(id)aOther;
- (void)actionAlternate:(id)aAlternate;
- (void)actionQuit:(id)aQuit;
- (void)actionContinue:(id)aContinue;
- (void)setValidationContext:(id)aContext;
- (id)validationContext;
- (NSInteger)runModal;
- (BOOL)isActionButtonEnabled:(NSInteger)aEnabled;
- (void)enableButton:(BOOL)aButton forAction:(NSInteger)aAction;
- (id)delegate;
- (void)setDelegate:(id)aDelegate;
- (void)windowDidLoad;
- (void)HSSerialNumberDialogController_configureLinkButton:(id)aButton;
- (void)dealloc;
- (id)initWithType:(id)aType;
- (id)init;
@end

