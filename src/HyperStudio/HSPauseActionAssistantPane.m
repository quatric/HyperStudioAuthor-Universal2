#import "HSPauseActionAssistantPane.h"

@implementation HSPauseActionAssistantPane

/* i386 ivar offsets: _pauseDurationField=0x88, _pauseDurationStepperField=0x8c */

- (void)durationChanged:(id)aChanged
{
    [[self pauseActionAssistantPaneApplier] setPauseDuration:[aChanged doubleValue]];
}

- (void)validateUIWithNotification:(id)aNotification
{
    [self validateUI];
}

- (id)initialKeyView
{
    return _pauseDurationField;
}

- (id)helpTopicKey
{
    return @"HSPause";
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [self removeActionAssistantPaneObserver];
    [super viewWillDisappear:aDisappear];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [self validateUI];
    [self addActionAssistantPaneObserver];
}

- (id)actionAttribute
{
    return (id)@protocol(HSPauseActionAttributes);
}

- (void)validateUI
{
    double dVar1;

    dVar1 = [[self actionAttributes] pauseDuration];
    [_pauseDurationField setDoubleValue:dVar1];
    [_pauseDurationStepperField setDoubleValue:dVar1];
}

- (id)actionAttributes
{
    return [[self pauseActionAssistantPaneApplier] pauseActionAttributes];
}

- (id)pauseActionAssistantPaneApplier
{
    return [self applier];
}

- (Class)applierClass
{
    return [HSPauseActionAssistantPaneApplier class];
}

- (id)actionType
{
    return [HSPauseAction actionType];
}

- (id)init
{
    self = [super initWithNibName:@"PauseAssistantPane"];
    return self;
}

@end

@implementation HSPauseActionAssistantPaneApplier

/* i386 ivar offsets: _initialDuration=0x30, _duration=0x38 */

- (BOOL)areSettingsEqual
{
    double dVar1;
    double dVar2;
    BOOL bVar3;
    double dVar5;
    double dVar6;

    if (![super areSettingsEqual]) {
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
    _duration = _initialDuration;
}

- (void)makeInitialEqualToCurrent
{
    [super makeInitialEqualToCurrent];
    _initialDuration = _duration;
}

- (void)setInitialSettingsToObject
{
    [[self pauseActionAttributes] setPauseDuration:_initialDuration];
    [super setInitialSettingsToObject];
}

- (void)setCurrentSettingsToObject
{
    [super setCurrentSettingsToObject];
    [[self pauseActionAttributes] setPauseDuration:_duration];
}

- (void)setPauseDuration:(double)aDuration
{
    if (_duration != aDuration) {
        _duration = aDuration;
        [self disableUndo];
        [[self pauseActionAttributes] setPauseDuration:_duration];
        [self enableUndo];
    }
}

- (void)setUpInitialSettings
{
    double dVar1;

    dVar1 = [[self pauseActionAttributes] pauseDuration];
    _duration = dVar1;
    _initialDuration = dVar1;
}

- (id)pauseActionAttributes
{
    return [[self actionAttributes] queryHyperInterface:@protocol(HSPauseActionAttributes)];
}

@end

