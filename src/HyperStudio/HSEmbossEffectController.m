#import "HSEmbossEffectController.h"

@implementation HSEmbossEffectController

+ (id)createEffect
{
    return [[HSEmbossEffect alloc] initWithName:@"Emboss"];
}

- (void)grayscaleDidChange:(id)aChange
{
    [self setColorized:[aChange state] != NSControlStateValueOn];
}

- (void)reliefDidChange:(id)aChange
{
    [self setReliefValue:[aChange floatValue]];
}

- (void)didLoadNib
{
    NSDictionary *relief = [[[[[self effect] class] effectsDescription] objectForKey:@"Emboss"] objectForKey:HSEEReliefValueKey];
    float minValue = [[relief objectForKey:HSAttributeMin] floatValue];
    float maxValue = [[relief objectForKey:HSAttributeMax] floatValue];
    [_reliefSlider setMaxValue:maxValue];
    [_reliefSlider setMinValue:minValue];
    [super didLoadNib];
}

- (void)revertSettingsToDefault
{
    [[self effect] setDefaults];
    [_reliefSlider setFloatValue:[self reliefValue]];
    [_grayscaleSwitch setState:![self isColorized]];
    [self update];
}

- (BOOL)isColorized
{
    return [[[self effect] valueForKey:HSEEColorizeFlagKey] boolValue];
}

- (void)setColorized:(BOOL)aColorized
{
    [[self effect] setValue:[NSNumber numberWithBool:aColorized] forKey:HSEEColorizeFlagKey];
    [self update];
}

- (CGFloat)reliefValue
{
    return [[[self effect] valueForKey:HSEEReliefValueKey] floatValue];
}

- (void)setReliefValue:(CGFloat)aValue
{
    [[self effect] setValue:[NSNumber numberWithFloat:aValue] forKey:HSEEReliefValueKey];
    [self update];
}

- (id)undoActionName
{
    NSString *effectName = [[NSBundle mainBundle] localizedStringForKey:@"Emboss" value:@"" table:@"UndoManager"];
    return [NSString stringWithFormat:[[NSBundle mainBundle] localizedStringForKey:@"ApplyGraphicEffect" value:@"" table:@"UndoManager"], effectName];
}

- (id)nibName
{
    return @"EmbossEffectController";
}

@end
