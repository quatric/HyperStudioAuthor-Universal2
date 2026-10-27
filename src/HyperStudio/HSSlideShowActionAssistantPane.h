#import "HyperStudioPrefix.h"
#import "HSActionAssistantSettingsApplier.h"
#import "HSNBAAssistantPane.h"


@interface HSSlideShowActionAssistantPane : HSNBAAssistantPane
{
    NSSlider *_speedSlider;
    NSPopUpButton *_transitionPopup;
    NSSlider *_durationSlider;
    NSTextField *_slideDurationField;
    NSStepper *_slideDurationStepper;
    HSTransitionView *_effectTransitionView;
    NSButton *_effectTransitionImageView;
    NSButton *_returnToOriginalCardButton;
    NSButton *_useClickOnExitCardButton;
    NSButton *_loopButton;
}
- (id)initialKeyView;
- (void)transitionViewDidFinishTransition:(id)aTransition;
- (void)transitionViewDidStopTransition:(id)aTransition;
- (void)showTransition:(id)aTransition;
- (void)loopChanged:(id)aChanged;
- (void)useClickOnExitCardChanged:(id)aChanged;
- (void)returnToOriginalCardChanged:(id)aChanged;
- (void)slideDurationChanged:(id)aChanged;
- (void)durationChanged:(id)aChanged;
- (void)transitionChanged:(id)aChanged;
- (id)helpTopicKey;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (id)actionAttribute;
- (void)HSSlideShowActionAssistantPane_hideTransition;
- (void)HSSlideShowActionAssistantPane_startTransition;
- (void)viewDidLoad;
- (void)validateUIWithNotification:(id)aNotification;
- (id)actionAttributes;
- (id)actionType;
- (id)slideShowActionAssistantPaneApplier;
- (Class)applierClass;
- (void)dealloc;
- (id)init;
@end

@interface HSSlideShowActionAssistantPaneApplier : HSActionAssistantSettingsApplier
{
    NSString *_initialTransitionName;
    double _initialTransitionDuration;
    double _initialSlideDuration;
    BOOL _initialReturnsToOriginalCard;
    BOOL _initialLoopSlideshow;
    BOOL _initialUseClickOnExitCard;
    NSString *_transitionName;
    double _transitionDuration;
    double _slideDuration;
    BOOL _returnsToOriginalCard;
    BOOL _loopSlideshow;
    BOOL _useClickOnExitCard;
}
- (void)setUseClickOnExitCard:(BOOL)aCard;
- (void)setLoopSlideShow:(BOOL)aShow;
- (void)setReturnsToOriginalCard:(BOOL)aCard;
- (void)setSlideDuration:(double)aDuration;
- (void)setTransitionDuration:(double)aDuration;
- (void)setTransitionName:(id)aName;
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setUpInitialSettings;
- (id)slideShowActionAttributes;
- (void)dealloc;
@end

