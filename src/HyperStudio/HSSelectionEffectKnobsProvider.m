#import "HSSelectionEffectKnobsProvider.h"

@implementation HSSelectionEffectKnobsProvider

// Adds a center knob for every center input of the effect.
- (id)selectionKnobsArrayAndDefaultKnobIndex:(unsigned int *)aIndex
{
    NSMutableArray *knobs = [super selectionKnobsArrayAndDefaultKnobIndex:aIndex];
    id effect = [[self hyperObject] queryHyperInterface:@protocol(HSEffectAttributes)];
    if (effect == nil)
        return knobs;
    NSEnumerator *enumerator = [[effect hyperInputKeys] objectEnumerator];
    NSInteger centerIndex = 0;
    NSString *key;
    while ((key = [enumerator nextObject]) != nil) {
        if (![key hasPrefix:kCIInputCenterKey])
            continue;
        HSEffectCenterSelectionKnob *knob = [[HSEffectCenterSelectionKnob alloc] init];
        if (knob == nil)
            continue;
        [knobs addObject:knob];
        [knob setAssociatedCenterIndex:centerIndex];
        [knob release];
        centerIndex++;
    }
    return knobs;
}

@end
