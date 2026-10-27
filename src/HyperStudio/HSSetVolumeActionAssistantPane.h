#import "HyperStudioPrefix.h"
#import "HSActionAssistantSettingsApplier.h"
#import "HSNBAAssistantPane.h"


@interface HSSetVolumeActionAssistantPane : HSNBAAssistantPane
{
    NSSlider *_volumeSlider;
}
- (void)validateUIWithNotification:(id)aNotification;
- (void)volumeLevelInChanged:(id)aChanged;
- (void)volumeLevelOutChanged:(id)aChanged;
- (void)volumeLevelChanged:(id)aChanged;
- (id)initialKeyView;
- (id)helpTopicKey;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (id)actionAttribute;
- (void)validateUI;
- (id)actionAttributes;
- (id)setVolumeActionSettingsApplier;
- (Class)applierClass;
- (id)actionType;
- (id)init;
@end

@interface HSSetVolumeActionSettingsApplier : HSActionAssistantSettingsApplier
{
    float _initialVolumeLevel;
    float _volumeLevel;
}
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setVolumeLevel:(CGFloat)aLevel;
- (void)setUpInitialSettings;
- (id)setVolumeActionAttributes;
@end

