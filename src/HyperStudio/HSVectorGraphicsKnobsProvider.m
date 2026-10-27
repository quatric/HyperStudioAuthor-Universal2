#import "HSVectorGraphicsKnobsProvider.h"

@implementation HSVectorGraphicsKnobsProvider

- (id)buildDefaultKnob
{
    return [super buildDefaultKnob];
}

- (id)buildSelectionKnobs
{
    return [super buildSelectionKnobs];
}

// One knob per path element; an element followed by a close-path (type 3)
// gets no knob of its own.
- (id)selectionKnobsArrayAndDefaultKnobIndex:(unsigned int *)aIndex
{
    id attributes = [[self hyperObject] queryHyperInterface:@protocol(HSVectorGraphicsAttributes)];
    NSUInteger count = [attributes hyperElementCount];
    NSMutableArray *knobs = [NSMutableArray arrayWithCapacity:count];
    NSUInteger index = 0;
    while (index < count) {
        if (index + 1 < count && [attributes hyperElementAtIndex:index + 1 associatedPoints:NULL] == 3) {
            index += 2;
            continue;
        }
        if ([attributes hyperElementAtIndex:index associatedPoints:NULL] != 3) {
            HSVectorGraphicsSelectionKnob *knob = [[HSVectorGraphicsSelectionKnob new] autorelease];
            [knob setAssociatedElementIndex:index owner:self];
            [knobs addObject:knob];
        }
        index++;
    }
    if (aIndex != NULL)
        *aIndex = [knobs count] == 0 ? 0x7fffffff : (unsigned int)[knobs count] - 1;
    return knobs;
}

- (id)buildSelectionKnobsAndDefaultKnob:(id *)aKnob
{
    unsigned int index = 0x7fffffff;
    NSArray *knobs = [self selectionKnobsArrayAndDefaultKnobIndex:&index];
    if (aKnob != NULL)
        *aKnob = index < [knobs count] ? [knobs objectAtIndex:index] : nil;
    return knobs;
}

@end
