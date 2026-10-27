#import "HSBevelerEffectController.h"

@implementation HSBevelerEffectController

+ (id)createEffect
{
    return [[HSBevelerEffect alloc] initWithName:@"Beveler"];
}

- (void)HSBevelerEffectController_setupWidthControls
{
    [_widthStepper setMaxValue:[[(HSBevelerEffect *)[self effect] maxWidth] floatValue]];
}

// Keeps the stepper and the text field in sync (the stepper moves the width
// by its delta) and clamps the width to the effect's maximum.
- (void)widthDidChange:(id)aChange
{
    float width = [[(HSBevelerEffect *)[self effect] maxWidth] floatValue];
    if ([aChange floatValue] <= width)
        width = [aChange floatValue];
    if (_widthStepper == aChange) {
        double current = [self bevelWidth];
        double field = [_widthTextField floatValue];
        double minimum = [_widthStepper minValue];
        width = (width - (float)current) + (float)field;
        if (minimum <= (double)width) {
            if ([_widthStepper maxValue] < (double)width)
                width = [_widthStepper maxValue];
        } else {
            width = [_widthStepper minValue];
        }
        [_widthTextField setFloatValue:width];
    } else if (_widthTextField == aChange) {
        if ((double)width >= [_widthStepper minValue]) {
            [_widthStepper setFloatValue:width];
            float field = [_widthTextField floatValue];
            float magnitude = field != 0 ? fabsf(field) : 1.0f;
            float widthMagnitude = width != 0 ? fabsf(width) : 1.0f;
            if (widthMagnitude <= magnitude)
                widthMagnitude = magnitude;
            if (fabsf(field - width) > widthMagnitude * 0.0005f)
                [_widthTextField setFloatValue:width];
        }
    }
    [self setBevelWidth:width];
}

- (BOOL)control:(id)aControl textShouldEndEditing:(id)aEditing
{
    return [[aEditing string] length] != 0;
}

- (void)raisedDidChange:(id)aChange
{
    [self updateSettingsBasedOnSwitchesState];
}

- (void)roundedDidChange:(id)aChange
{
    [self updateSettingsBasedOnSwitchesState];
}

// Round bevels are not flat; the bevel is inversed when the two switches agree.
- (void)updateSettingsBasedOnSwitchesState
{
    NSInteger rounded = [_roundedSwitch state];
    NSInteger raised = [_raisedSwitch state];
    [self setFlated:rounded != 1];
    [self setInversed:(rounded == 1) == (raised == 1)];
}

- (void)didLoadNib
{
    [super didLoadNib];
    [self HSBevelerEffectController_setupWidthControls];
}

- (void)revertSettingsToDefault
{
    [[self effect] setDefaults];
    [_widthTextField setFloatValue:[self bevelWidth]];
    [self widthDidChange:_widthTextField];
    [_roundedSwitch setState:1];
    [_raisedSwitch setState:1];
    [self updateSettingsBasedOnSwitchesState];
    [self update];
}

- (BOOL)isInversed
{
    return [[[self effect] valueForKey:HSBEInversionFlagKey] boolValue];
}

- (void)setInversed:(BOOL)aInversed
{
    [[self effect] setValue:[NSNumber numberWithBool:aInversed] forKey:HSBEInversionFlagKey];
    [[self previewController] update];
}

- (BOOL)isFlated
{
    return [[[self effect] valueForKey:HSBETypeFlagKey] boolValue];
}

- (void)setFlated:(BOOL)aFlated
{
    [[self effect] setValue:[NSNumber numberWithBool:aFlated] forKey:HSBETypeFlagKey];
    [[self previewController] update];
}

- (CGFloat)bevelWidth
{
    return [[[self effect] valueForKey:HSBEWidthKey] floatValue];
}

- (void)setBevelWidth:(CGFloat)aWidth
{
    [[self effect] setValue:[NSNumber numberWithFloat:aWidth] forKey:HSBEWidthKey];
    [[self previewController] update];
}

- (void)setObject:(id)aObject
{
    [super setObject:aObject];
    [self HSBevelerEffectController_setupWidthControls];
}

- (id)undoActionName
{
    NSString *effectName = [[NSBundle mainBundle] localizedStringForKey:@"Beveler" value:@"" table:@"UndoManager"];
    return [NSString stringWithFormat:[[NSBundle mainBundle] localizedStringForKey:@"ApplyGraphicEffect" value:@"" table:@"UndoManager"], effectName];
}

- (id)nibName
{
    return @"BevelEffectController";
}

@end
