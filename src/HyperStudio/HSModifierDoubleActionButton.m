#import "HSModifierDoubleActionButton.h"

@implementation HSModifierDoubleActionButton

// A double click sends the double action, or the modifier double action with the modifier held.
- (BOOL)sendAction:(SEL)aAction to:(id)aTo
{
    NSEvent *event = [[self window] currentEvent];

    if ([event clickCount] == 2) {
        if ([self modifierDoubleAction] != NULL && (_doubleActionModifier & [event modifierFlags]) != 0)
            aAction = [self modifierDoubleAction];
        else
            aAction = [self doubleAction];
    }
    return [super sendAction:aAction to:aTo];
}

- (SEL)modifierDoubleAction
{
    return _modifierDoubleAction;
}

- (NSUInteger)doubleActionModifier
{
    return _doubleActionModifier;
}

- (void)setDoubleAction:(SEL)aAction forModifier:(NSUInteger)aModifier
{
    _modifierDoubleAction = aAction;
    _doubleActionModifier = (unsigned int)aModifier;
}

- (SEL)doubleAction
{
    return _doubleAction;
}

- (void)setDoubleAction:(SEL)aAction
{
    _doubleAction = aAction;
}

@end
