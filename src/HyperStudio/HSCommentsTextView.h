#import "HyperStudioPrefix.h"
#import "HSViewController.h"


@interface HSCommentsTextView : NSTextView
{
}
- (BOOL)acceptsFirstMouse:(id)aMouse;
@end

@interface HSObjectAssistantPane : HSViewController <NSCopying>
{
    NSWindow *_window;
    HSObjectAssistant *_assistant;
    BOOL _validateTextFieldsWithFormatters;
    id _objectAssistantPaneDelegate;
    id _object;
    NSString *_windowTitle;
    HSObjectAssistantNavigationController *_objectAssistantNavigationController;
}
- (BOOL)isCoachingPane;
- (void)setParentViewController:(id)aController;
- (void)layout;
- (BOOL)control:(id)aControl didFailToFormatString:(id)aString errorDescription:(id)aDescription;
- (BOOL)shouldDismissWhenDisappeared;
- (void)dismiss:(BOOL)aDismiss;
- (void)dismiss:(BOOL)aDismiss slide:(BOOL)aSlide;
- (BOOL)isEditingTextAttribute;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewDidAppear:(BOOL)aAppear;
- (void)paneDidCancel:(id)aCancel;
- (void)assistantGoBack:(id)aBack;
- (void)setWindowTitle:(id)aTitle;
- (id)windowTitle;
- (id)helpTopicKey;
- (id)stack;
- (id)card;
- (id)window;
- (id)assistantPaneUndoManager;
- (BOOL)needsToBeSavedInHistory;
- (BOOL)assistantShouldBeKeyWindow;
- (void)showCoachingHelpIfNeeded;
- (void)dismissModalViewControllerAnimated:(BOOL)aAnimated;
- (void)presentModalViewControllerAsRootViewController:(id)aController withIdentifier:(id)aIdentifier;
- (void)presentModalViewControllerAsRootViewController:(id)aController;
- (void)presentModalViewController:(id)aController animated:(BOOL)aAnimated;
- (void)setFooterView:(id)aView;
- (void)loadView;
- (BOOL)isEnabled;
- (void)setObjectAssistantPaneDelegate:(id)aDelegate;
- (id)objectAssistantPaneDelegate;
- (void)setObject:(id)aObject;
- (id)object;
- (BOOL)requiresDarkBottomArea;
- (BOOL)isEqual:(id)aEqual;
- (id)copyWithZone:(NSZone *)aZone;
- (void)dealloc;
- (void)setAssistant:(id)aAssistant;
- (BOOL)needToRelayoutAssistant;
- (id)assistant;
@end

@interface HSObjectAssistantPaneWithApplier : HSObjectAssistantPane
{
    HSAssistantPaneApplier *_applier;
    id _delegate;
    BOOL _userMadeTheDecision;
}
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)paneDidCancel:(id)aCancel;
- (void)paneDidOK:(id)aOK;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)viewDidLoad;
- (void)applySettingsOnOK;
- (void)revertSettingsOnCancel;
- (void)restoreApplierSettings;
- (void)updateObjectWithApplier;
- (id)applier;
- (Class)applierClass;
- (void)dealloc;
@end

