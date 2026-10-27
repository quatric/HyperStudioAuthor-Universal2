#import "HyperStudioPrefix.h"
#import "HSActionAssistantSettingsApplier.h"
#import "HSNBAAssistantPane.h"


@interface HSAutoRecordActionAssistantPane : HSNBAAssistantPane
{
    NSTextField *_recordTimeField;
    NSMatrix *_sensitivityLevelMatrix;
    NSTextField *_recordNameField;
    NSStepper *_recordTimeStepper;
}
- (void)controlTextDidChange:(id)aChange;
- (void)validateUI;
- (void)validateUIWithNotification:(id)aNotification;
- (void)sensivityLevelChanged:(id)aChanged;
- (void)recordTimeChanged:(id)aChanged;
- (void)recordNameChanged:(id)aChanged;
- (id)helpTopicKey;
- (id)initialKeyView;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (id)actionAttribute;
- (id)actionType;
- (id)actionAttributes;
- (id)autoRecordActionAssistantPaneApplier;
- (Class)applierClass;
- (id)init;
@end

@interface HSAutoRecordActionAssistantPaneApplier : HSActionAssistantSettingsApplier
{
    double _initialRecordTime;
    int _initialSensitivityLevel;
    NSString *_initialRecordName;
    double _recordTime;
    int _sensitivityLevel;
    NSString *_recordName;
}
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setSensitivityLevel:(NSInteger)aLevel;
- (void)setRecordTime:(double)aTime;
- (void)setRecordName:(id)aName;
- (void)setUpInitialSettings;
- (id)autoRecordActionAttributes;
- (void)dealloc;
@end

