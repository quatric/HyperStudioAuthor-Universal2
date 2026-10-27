#import "HyperStudioPrefix.h"
#import "HSCommentsTextView.h"


@interface HSActionAssistantPane : HSObjectAssistantPaneWithApplier <HSActionAssistantPaneActionEvents, NSObject>
{
    NSArray *_actionEvents;
    HSObjectAssistantNavigationPaneSwitcher *_paneSwitcher;
    id<HSActor> _observedActorAttributes;
    id<HSAttributeObserving> _actionAssistantPaneObserver;
}
- (id)windowTitle;
- (id)helpTopicKey;
- (void)paneWillGoBack:(id)aBack;
- (void)willGoToNextPane;
- (void)paneWillGoToInitial:(id)aInitial settingsCanceled:(BOOL)aCanceled;
- (void)paneDidCancel:(id)aCancel;
- (void)paneDidOK:(id)aOK;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)updateObjectWithApplier;
- (id)navigationPaneSwitcher;
- (void)actorDidChageActions:(id)aActions;
- (void)removeActionAssistantPaneObserver;
- (void)addActionAssistantPaneObserver;
- (id)actionAttribute;
- (void)removeActorObserver;
- (void)addActorObserver;
- (void)setActionEvent:(id)aEvent;
- (id)actionEvent;
- (void)setActionEvents:(id)aEvents;
- (id)actionEvents;
- (id)applier;
- (id)actionType;
- (BOOL)requiresDarkBottomArea;
- (void)dealloc;
@end

