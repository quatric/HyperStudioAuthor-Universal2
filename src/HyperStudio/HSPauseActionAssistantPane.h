#import "HyperStudioPrefix.h"
#import "HSActionAssistantSettingsApplier.h"
#import "HSNBAAssistantPane.h"


@interface HSPauseActionAssistantPane : HSNBAAssistantPane
{
    NSTextField *_pauseDurationField;
    NSStepper *_pauseDurationStepperField;
}
- (void)durationChanged:(id)aChanged;
- (void)validateUIWithNotification:(id)aNotification;
- (id)initialKeyView;
- (id)helpTopicKey;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (id)actionAttribute;
- (void)validateUI;
- (id)actionAttributes;
- (id)pauseActionAssistantPaneApplier;
- (Class)applierClass;
- (id)actionType;
- (id)init;
@end

@interface HSPauseActionAssistantPaneApplier : HSActionAssistantSettingsApplier
{
    double _initialDuration;
    double _duration;
}
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setPauseDuration:(double)aDuration;
- (void)setUpInitialSettings;
- (id)pauseActionAttributes;
@end

