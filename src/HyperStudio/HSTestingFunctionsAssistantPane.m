#import "HSTestingFunctionsAssistantPane.h"

@implementation HSTestingFunctionsAssistantPane

- (id)initialKeyView
{
    return _testingFunctionMatrix;
}

- (id)helpTopicKey
{
    return @"HSTestingFunctions";
}

- (void)testingFunctionTypeChanged:(id)aChanged
{
    [[self testingFunctionsAssistantApplier] setTestingFunctionType:[_testingFunctionMatrix selectedTag]];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [self validateUserInterface];
}

- (void)validateUserInterface
{
    [_testingFunctionMatrix selectCellWithTag:[[self actionAttributes] testingFunctionType]];
}

- (id)actionAttributes
{
    return [[self testingFunctionsAssistantApplier] testingFunctionsActionAttributes];
}

- (id)actionType
{
    return [HSTestingFunctionsAction actionType];
}

- (id)testingFunctionsAssistantApplier
{
    return [self applier];
}

- (Class)applierClass
{
    return [HSTestingFunctionsAssistantPaneApplier class];
}

- (id)init
{
    return [super initWithNibName:@"TestingAssistantPane"];
}
@end

@implementation HSTestingFunctionsAssistantPaneApplier

- (BOOL)areSettingsEqual
{
    return [super areSettingsEqual] && _initialTestingFunctionType == _testingFunctionType;
}

- (void)makeCurrentEqualToInitial
{
    [super makeCurrentEqualToInitial];
    _testingFunctionType = _initialTestingFunctionType;
}

- (void)makeInitialEqualToCurrent
{
    [super makeInitialEqualToCurrent];
    _initialTestingFunctionType = _testingFunctionType;
}

- (void)setInitialSettingsToObject
{
    [[self testingFunctionsActionAttributes] setTestingFunctionType:_initialTestingFunctionType];
    [super setInitialSettingsToObject];
}

- (void)setCurrentSettingsToObject
{
    [super setCurrentSettingsToObject];
    [[self testingFunctionsActionAttributes] setTestingFunctionType:_testingFunctionType];
}

- (void)setTestingFunctionType:(NSInteger)aType
{
    if (_testingFunctionType != aType) {
        _testingFunctionType = (int)aType;
        [self disableUndo];
        [[self testingFunctionsActionAttributes] setTestingFunctionType:_testingFunctionType];
        [self enableUndo];
    }
}

- (void)setUpInitialSettings
{
    NSInteger type = [[self testingFunctionsActionAttributes] testingFunctionType];
    _testingFunctionType = (int)type;
    _initialTestingFunctionType = (int)type;
}

- (id)testingFunctionsActionAttributes
{
    return [[self actionAttributes] queryHyperInterface:@protocol(HSTestingFunctionsActionAttributes)];
}

@end
