#import "HSStarFieldActionAssistantPane.h"

@implementation HSStarFieldActionAssistantPane

/* i386 ivar offsets: _starFieldDurationModeMatrix=0x88, _starFieldDurationField=0x8c, _starFieldDurationStepper=0x90 */

- (void)validateUI
{
    id self_00;

    self_00 = [self actionAttributes];
    [_starFieldDurationModeMatrix selectCellWithTag:[self_00 starFieldDurationMode]];
    [_starFieldDurationField setDoubleValue:[self_00 starFieldDuration]];
    [_starFieldDurationStepper setDoubleValue:[self_00 starFieldDuration]];
}

- (void)validateUIWithNotification:(id)aNotification
{
    [self validateUI];
}

- (void)startFieldDurationModeChanged:(id)aChanged
{
    [[self starFieldActionAssistantPaneApplier] setStarFieldDurationMode:[[_starFieldDurationModeMatrix selectedCell] tag]];
}

- (void)starFieldDurationChanged:(id)aChanged
{
    [[self starFieldActionAssistantPaneApplier] setStarFieldDuration:[aChanged doubleValue]];
}

- (id)initialKeyView
{
    return _starFieldDurationModeMatrix;
}

- (id)helpTopicKey
{
    return @"HSStarField";
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [self removeActionAssistantPaneObserver];
    [super viewWillDisappear:aDisappear];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [self addActionAssistantPaneObserver];
    [self validateUI];
}

- (id)actionAttribute
{
    return (id)@protocol(HSStarFieldActionAttributes);
}

- (id)actionType
{
    return [HSStarFieldAction actionType];
}

- (id)actionAttributes
{
    return [[self starFieldActionAssistantPaneApplier] starFieldActionAttributes];
}

- (id)starFieldActionAssistantPaneApplier
{
    return [self applier];
}

- (Class)applierClass
{
    return [HSStarFieldActionAssistantPaneApplier class];
}

- (id)init
{
    self = [super initWithNibName:@"StarFieldAssistantPane"];
    return self;
}

@end

@implementation HSStarFieldActionAssistantPaneApplier

/* i386 ivar offsets: _initialStarFieldDurationMode=0x30, _initialDuration=0x34, _starFieldDurationMode=0x3c, _duration=0x40 */

- (BOOL)areSettingsEqual
{
    double dVar1;
    double dVar2;
    BOOL bVar3;
    double dVar5;
    double dVar6;

    if ((![super areSettingsEqual]) || (_initialStarFieldDurationMode != _starFieldDurationMode)) {
        bVar3 = NO;
    }
    else {
        dVar1 = _initialDuration;
        dVar2 = _duration;
        dVar5 = dVar1 != 0.0 ? fabs(dVar1) : 1.0;
        dVar6 = dVar2 != 0.0 ? fabs(dVar2) : 1.0;
        if (dVar6 <= dVar5) {
            dVar6 = dVar5;
        }
        bVar3 = fabs(dVar1 - dVar2) <= dVar6 * 1e-05;
    }
    return bVar3;
}

- (void)makeCurrentEqualToInitial
{
    [super makeCurrentEqualToInitial];
    _starFieldDurationMode = _initialStarFieldDurationMode;
    _duration = _initialDuration;
}

- (void)makeInitialEqualToCurrent
{
    [super makeInitialEqualToCurrent];
    _initialStarFieldDurationMode = _starFieldDurationMode;
    _initialDuration = _duration;
}

- (void)setInitialSettingsToObject
{
    [[self starFieldActionAttributes] setStarFieldDurationMode:_initialStarFieldDurationMode];
    [[self starFieldActionAttributes] setStarFieldDuration:_initialDuration];
    [super setInitialSettingsToObject];
}

- (void)setCurrentSettingsToObject
{
    [super setCurrentSettingsToObject];
    [[self starFieldActionAttributes] setStarFieldDurationMode:_starFieldDurationMode];
    [[self starFieldActionAttributes] setStarFieldDuration:_duration];
}

- (void)setStarFieldDuration:(double)aDuration
{
    if (_duration != aDuration) {
        _duration = aDuration;
        [self disableUndo];
        [[self starFieldActionAttributes] setStarFieldDuration:_duration];
        [self enableUndo];
    }
}

- (void)setStarFieldDurationMode:(NSInteger)aMode
{
    if (_starFieldDurationMode != aMode) {
        _starFieldDurationMode = aMode;
        [self disableUndo];
        [[self starFieldActionAttributes] setStarFieldDurationMode:_starFieldDurationMode];
        [self enableUndo];
    }
}

- (void)setUpInitialSettings
{
    double dVar2;
    NSInteger pvVar1_2;

    pvVar1_2 = [[self starFieldActionAttributes] starFieldDurationMode];
    _initialStarFieldDurationMode = (int)pvVar1_2;
    _starFieldDurationMode = (int)pvVar1_2;
    dVar2 = [[self starFieldActionAttributes] starFieldDuration];
    _initialDuration = dVar2;
    _duration = dVar2;
}

- (id)starFieldActionAttributes
{
    return [[self actionAttributes] queryHyperInterface:@protocol(HSStarFieldActionAttributes)];
}

@end

