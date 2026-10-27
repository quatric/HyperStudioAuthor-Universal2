#import "HyperStudioPrefix.h"
#import "HSActionAssistantSettingsApplier.h"
#import "HSNBAAssistantPane.h"


@interface HSTestingFunctionsAssistantPane : HSNBAAssistantPane
{
    NSMatrix *_testingFunctionMatrix;
}
- (id)initialKeyView;
- (id)helpTopicKey;
- (void)testingFunctionTypeChanged:(id)aChanged;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)validateUserInterface;
- (id)actionAttributes;
- (id)actionType;
- (id)testingFunctionsAssistantApplier;
- (Class)applierClass;
- (id)init;
@end

@interface HSTestingFunctionsAssistantPaneApplier : HSActionAssistantSettingsApplier
{
    int _initialTestingFunctionType;
    int _testingFunctionType;
}
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setTestingFunctionType:(NSInteger)aType;
- (void)setUpInitialSettings;
- (id)testingFunctionsActionAttributes;
@end

