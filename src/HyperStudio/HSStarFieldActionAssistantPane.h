#import "HyperStudioPrefix.h"
#import "HSActionAssistantSettingsApplier.h"
#import "HSNBAAssistantPane.h"


@interface HSStarFieldActionAssistantPane : HSNBAAssistantPane
{
    NSMatrix *_starFieldDurationModeMatrix;
    NSTextField *_starFieldDurationField;
    NSStepper *_starFieldDurationStepper;
}
- (void)validateUI;
- (void)validateUIWithNotification:(id)aNotification;
- (void)startFieldDurationModeChanged:(id)aChanged;
- (void)starFieldDurationChanged:(id)aChanged;
- (id)initialKeyView;
- (id)helpTopicKey;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (id)actionAttribute;
- (id)actionType;
- (id)actionAttributes;
- (id)starFieldActionAssistantPaneApplier;
- (Class)applierClass;
- (id)init;
@end

@interface HSStarFieldActionAssistantPaneApplier : HSActionAssistantSettingsApplier
{
    int _initialStarFieldDurationMode;
    double _initialDuration;
    int _starFieldDurationMode;
    double _duration;
}
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setStarFieldDuration:(double)aDuration;
- (void)setStarFieldDurationMode:(NSInteger)aMode;
- (void)setUpInitialSettings;
- (id)starFieldActionAttributes;
@end

