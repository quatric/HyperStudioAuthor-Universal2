#import "HyperStudioPrefix.h"
#import "HSActionAssistantSettingsApplier.h"
#import "HSNBAAssistantPane.h"


@interface HSRunCommandActionAssistancePane : HSNBAAssistantPane
{
    NSMatrix *_runCommandActionTypeMatrix;
}
- (void)runCommandActionTypeChanged:(id)aChanged;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)validateUserInterface;
- (id)actionAttributes;
- (id)actionType;
- (id)runCommandActionAssistantApplier;
- (Class)applierClass;
- (id)init;
@end

@interface HSRunCommandActionAssistantPaneApplier : HSActionAssistantSettingsApplier
{
    int _initialRunCommandActionType;
    int _runCommandActionType;
}
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setRunCommandActionType:(NSInteger)aType;
- (void)setUpInitialSettings;
- (id)runCommandActionAttributes;
@end

