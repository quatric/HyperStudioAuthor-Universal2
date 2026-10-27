#import "HyperStudioPrefix.h"
#import "HSActionAssistantPane.h"
#import "HSActionAssistantSettingsApplier.h"


@interface HSTransitionsAssistantPane : HSActionAssistantPane <HSTransitionsGridDelegate, NSMatrixDelegate, NSControlTextEditingDelegate, NSObject, HSTransitionsGridDataSource>
{
    HSTransitionsGrid *_transitionsGrid;
    HSPaneScrollView *_transitionScrollView;
    NSButton *_tryItButton;
    NSSlider *_durationSlider;
    NSString *_actionType;
    HSTransitionView *_transitionPreviewView;
    HSAssistantPaneMultiApplier *_paneMultiApplier;
    BOOL _transitionPreviewIsRunning;
}
+ (double)maxSliderDuration;
+ (double)minSliderDuration;
+ (double)sliderDurationFromTransitionDuration:(double)aDuration;
+ (double)transitionDurationFromSliderDuration:(double)aDuration;
- (id)attributeNotificationCenterForTransition:(id)aTransition;
- (void)selectionDidChangeInTransitionsGrid:(id)aGrid;
- (id)endImageForTransitionEffect:(id)aEffect inTransitionsGrid:(id)aGrid;
- (id)startImageForTransitionEffect:(id)aEffect inTransitionsGrid:(id)aGrid;
- (id)transitionEffectWithDisplayName:(id *)aName thumbnail:(id *)aThumbnail atIndex:(NSUInteger)aIndex inTransitionsGrid:(id)aGrid;
- (NSUInteger)transitionEffectCountInTransitionsGrid:(id)aGrid;
- (void)transitionViewDidFinishTransition:(id)aTransition;
- (void)transitionViewDidStopTransition:(id)aTransition;
- (void)HSTransitionsAssistantPane_transitionDidEnd;
- (void)transitionDurationChanged:(id)aChanged;
- (void)tryIt:(id)aIt;
- (void)dismiss:(BOOL)aDismiss;
- (id)objectAssistantForNavigationPaneSwitcher:(id)aSwitcher;
- (id)helpTopicKey;
- (Class)hubPaneClass;
- (BOOL)shouldRewindToPreviousHubPane;
- (id)firstPaneForObjectAssistant:(id)aAssistant;
- (void)viewDidAppear:(BOOL)aAppear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)applySettingsOnOK;
- (void)revertSettingsOnCancel;
- (void)validateUI;
- (void)validateTransitionItems;
- (void)viewDidLoad;
- (id)transitionAttributes;
- (id)transitionOwner;
- (id)actionType;
- (id)navigationPaneSwitcher;
- (id)transitionPaneApplier;
- (Class)applierClass;
- (id)paneMultiApplier;
- (void)dealloc;
- (id)copyWithZone:(NSZone *)aZone;
- (id)initialKeyView;
- (id)initWithActionType:(id)aType paneMultiApplier:(id)aApplier;
@end

@interface HSTransitionsAssistantPaneApplier : HSActionAssistantSettingsApplier
{
    NSString *_initialTransitionName;
    double _initialDuration;
    NSString *_transitionName;
    double _duration;
}
- (void)setDuration:(double)aDuration;
- (void)setTransitionName:(id)aName;
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setUpInitialSettings;
- (id)transitionOwner;
- (void)dealloc;
@end

