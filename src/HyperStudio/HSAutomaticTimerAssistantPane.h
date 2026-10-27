#import "HyperStudioPrefix.h"
#import "HSAssistantPaneApplier.h"
#import "HSCommentsTextView.h"


@interface HSAutomaticTimerAssistantPane : HSObjectAssistantPaneWithApplier
{
    NSMatrix *_timerTypeMatrix;
    NSTextField *_delayField;
    NSStepper *_delayStepper;
    NSButton *_repeatingSwitch;
    NSTextField *_delayBetweenRepeatingActionsField;
    NSStepper *_delayBetweenRepeatingActionsStepper;
    id<HSActor> _observedActorAttributes;
    HSObjectAssistantNavigationPaneSwitcher *_paneSwitcher;
    HSActionEvent *_actionEvent;
    BOOL _isDelayBetweenRepeatingActionsSet;
}
- (void)validateUserInterfaceWithNotification:(id)aNotification;
- (void)delayBetweenRepeatingActionsChanged:(id)aChanged;
- (void)repeatingChanged:(id)aChanged;
- (void)delayChanged:(id)aChanged;
- (void)timerTypeChanged:(id)aChanged;
- (id)actionEvent;
- (void)setActionEvent:(id)aEvent;
- (id)windowTitle;
- (id)helpTopicKey;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)setObservedActorAttributes:(id)aAttributes;
- (void)setupUIElements;
- (void)validateUserInterface;
- (id)navigationPaneSwitcher;
- (id)automaticTimer;
- (id)actor;
- (Class)applierClass;
- (BOOL)requiresDarkBottomArea;
- (void)dealloc;
- (id)HSAutomaticTimerAssistantPane_applier;
- (id)init;
@end

@interface HSAutomaticTimerAssistantPaneApplier : HSAssistantPaneApplier
{
    BOOL _initialRunActionsAutomatically;
    double _initialDelay;
    double _initialDelayBetweenRepeatingActions;
    BOOL _runActionsAutomatically;
    double _delay;
    double _delayBetweenRepeatingActions;
    BOOL _runActionsImmediatedly;
    HSActionEvent *_actionEvent;
}
- (id)actionEvent;
- (BOOL)areSettingsEqual;
- (void)setUpInitialSettings;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setDelayBetweenRepeatingActions:(double)aActions;
- (void)setDelay:(double)aDelay;
- (void)setRunActionsAutomatically:(BOOL)aAutomatically;
- (id)undoActionName;
- (void)dealloc;
- (id)automaticTimer;
- (id)actor;
@end

