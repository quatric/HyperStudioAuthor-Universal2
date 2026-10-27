#import "HSRunCommandActionAssistancePane.h"

@implementation HSRunCommandActionAssistancePane

- (void)runCommandActionTypeChanged:(id)aChanged
{
    [[self runCommandActionAssistantApplier] setRunCommandActionType:[_runCommandActionTypeMatrix selectedTag]];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [self validateUserInterface];
}

- (void)validateUserInterface
{
    [_runCommandActionTypeMatrix selectCellWithTag:[[self actionAttributes] runCommandActionType]];
}

- (id)actionAttributes
{
    return [[self runCommandActionAssistantApplier] runCommandActionAttributes];
}

- (id)actionType
{
    return [HSRunCommandAction actionType];
}

- (id)runCommandActionAssistantApplier
{
    return [self applier];
}

- (Class)applierClass
{
    return [HSRunCommandActionAssistantPaneApplier class];
}

- (id)init
{
    return [super initWithNibName:@"RunCommandAssistantPane"];
}
@end

@implementation HSRunCommandActionAssistantPaneApplier

- (BOOL)areSettingsEqual
{
    return [super areSettingsEqual] && _initialRunCommandActionType == _runCommandActionType;
}

- (void)makeCurrentEqualToInitial
{
    [super makeCurrentEqualToInitial];
    _runCommandActionType = _initialRunCommandActionType;
}

- (void)makeInitialEqualToCurrent
{
    [super makeInitialEqualToCurrent];
    _initialRunCommandActionType = _runCommandActionType;
}

- (void)setInitialSettingsToObject
{
    [[self runCommandActionAttributes] setRunCommandActionType:_initialRunCommandActionType];
    [super setInitialSettingsToObject];
}

- (void)setCurrentSettingsToObject
{
    [super setCurrentSettingsToObject];
    [[self runCommandActionAttributes] setRunCommandActionType:_runCommandActionType];
}

- (void)setRunCommandActionType:(NSInteger)aType
{
    if (_runCommandActionType != aType) {
        _runCommandActionType = (int)aType;
        [self disableUndo];
        [[self runCommandActionAttributes] setRunCommandActionType:_runCommandActionType];
        [self enableUndo];
    }
}

- (void)setUpInitialSettings
{
    _runCommandActionType = (int)[[self runCommandActionAttributes] runCommandActionType];
    _initialRunCommandActionType = _runCommandActionType;
}

- (id)runCommandActionAttributes
{
    return [[self actionAttributes] queryHyperInterface:@protocol(HSRunCommandActionAttributes)];
}

@end
