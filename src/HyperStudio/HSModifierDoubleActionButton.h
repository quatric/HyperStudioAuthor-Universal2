#import "HyperStudioPrefix.h"


@interface HSModifierDoubleActionButton : NSButton
{
    unsigned int _doubleActionModifier;
    SEL _modifierDoubleAction;
    SEL _doubleAction;
}
- (BOOL)sendAction:(SEL)aAction to:(id)aTo;
- (SEL)modifierDoubleAction;
- (NSUInteger)doubleActionModifier;
- (void)setDoubleAction:(SEL)aAction forModifier:(NSUInteger)aModifier;
- (SEL)doubleAction;
- (void)setDoubleAction:(SEL)aAction;
@end

