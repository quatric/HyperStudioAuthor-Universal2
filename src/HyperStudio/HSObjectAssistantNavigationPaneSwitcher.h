#import "HyperStudioPrefix.h"
#import "HSViewController.h"


@interface HSObjectAssistantNavigationPaneSwitcher : HSViewController
{
    HSObjectAssistantNavigationController *_navigationController;
    id _delegate;
    NSButton *_OKButton;
    NSButton *_cancelButton;
    NSButton *_backButton;
    HSAssistantPaneApplier *_applier;
    BOOL _isHelpAssistantPaneSwitcher;
    BOOL _isModalWindowRunning;
}
- (void)showHelp:(id)aHelp;
- (void)doCancel:(id)aCancel;
- (void)doOK:(id)aOK;
- (void)assistantGoBack:(id)aBack;
- (void)validateUserInterface;
- (void)validateUIWithModalWindowChange;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewDidAppear:(BOOL)aAppear;
- (void)viewWillAppear:(BOOL)aAppear;
- (id)defaultButtonCell;
- (id)window;
- (void)didEndModalWindow:(id)aWindow;
- (void)willRunModalWindow:(id)aWindow;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)setApplier:(id)aApplier;
- (id)applier;
- (void)setNavigationController:(id)aController;
- (id)navigationController;
- (void)dealloc;
- (id)initWithAssistantSettingsApplier:(id)aApplier windowNibName:(id)aName;
- (id)initWithNibName:(id)aName;
- (id)init;
@end

