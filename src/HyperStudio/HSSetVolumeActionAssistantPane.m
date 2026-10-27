#import "HSSetVolumeActionAssistantPane.h"

@implementation HSSetVolumeActionAssistantPane

/* i386 ivar offsets: _volumeSlider=0x88 */

- (void)validateUIWithNotification:(id)aNotification
{
    [self validateUI];
}

- (void)volumeLevelInChanged:(id)aChanged
{
    [[self setVolumeActionSettingsApplier] setVolumeLevel:(float)[_volumeSlider maxValue]];
}

- (void)volumeLevelOutChanged:(id)aChanged
{
    [[self setVolumeActionSettingsApplier] setVolumeLevel:(float)[_volumeSlider minValue]];
}

- (void)volumeLevelChanged:(id)aChanged
{
    [[self setVolumeActionSettingsApplier] setVolumeLevel:(float)[_volumeSlider floatValue]];
}

- (id)initialKeyView
{
    return _volumeSlider;
}

- (id)helpTopicKey
{
    return @"HSSetVolume";
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [super viewWillDisappear:aDisappear];
    [self removeActionAssistantPaneObserver];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [self addActionAssistantPaneObserver];
    [self validateUI];
}

- (id)actionAttribute
{
    return (id)@protocol(HSSetVolumeActionAttributes);
}

- (void)validateUI
{
    [_volumeSlider setFloatValue:(float)[[self actionAttributes] volumeLevel]];
}

- (id)actionAttributes
{
    return [[self setVolumeActionSettingsApplier] setVolumeActionAttributes];
}

- (id)setVolumeActionSettingsApplier
{
    return [self applier];
}

- (Class)applierClass
{
    return [HSSetVolumeActionSettingsApplier class];
}

- (id)actionType
{
    return [HSSetVolumeAction actionType];
}

- (id)init
{
    self = [super initWithNibName:@"SetVolumeAssistantPane"];
    return self;
}

@end

@implementation HSSetVolumeActionSettingsApplier

/* i386 ivar offsets: _initialVolumeLevel=0x30, _volumeLevel=0x34 */

- (BOOL)areSettingsEqual
{
    float fVar1;
    float fVar2;
    BOOL bVar3;
    float fVar5;
    float fVar6;

    if (![super areSettingsEqual]) {
        bVar3 = NO;
    }
    else {
        fVar1 = _initialVolumeLevel;
        fVar2 = _volumeLevel;
        fVar5 = fVar1 != 0.0 ? fabs(fVar1) : 1.0;
        fVar6 = fVar2 != 0.0 ? fabs(fVar2) : 1.0;
        if (fVar6 <= fVar5) {
            fVar6 = fVar5;
        }
        bVar3 = fabs(fVar1 - fVar2) <= fVar6 * 0.0005;
    }
    return bVar3;
}

- (void)makeCurrentEqualToInitial
{
    [super makeCurrentEqualToInitial];
    _volumeLevel = _initialVolumeLevel;
}

- (void)makeInitialEqualToCurrent
{
    [super makeInitialEqualToCurrent];
    _initialVolumeLevel = _volumeLevel;
}

- (void)setInitialSettingsToObject
{
    [[self setVolumeActionAttributes] setVolumeLevel:_initialVolumeLevel];
    [super setInitialSettingsToObject];
}

- (void)setCurrentSettingsToObject
{
    [super setCurrentSettingsToObject];
    [[self setVolumeActionAttributes] setVolumeLevel:_volumeLevel];
}

- (void)setVolumeLevel:(CGFloat)aLevel
{
    if (_volumeLevel != aLevel) {
        _volumeLevel = aLevel;
        [self disableUndo];
        [[self setVolumeActionAttributes] setVolumeLevel:aLevel];
        [self enableUndo];
    }
}

- (void)setUpInitialSettings
{
    double dVar1;

    dVar1 = [[self setVolumeActionAttributes] volumeLevel];
    _volumeLevel = (float)dVar1;
    _initialVolumeLevel = (float)dVar1;
}

- (id)setVolumeActionAttributes
{
    return [[self actionAttributes] queryHyperInterface:@protocol(HSSetVolumeActionAttributes)];
}

@end

