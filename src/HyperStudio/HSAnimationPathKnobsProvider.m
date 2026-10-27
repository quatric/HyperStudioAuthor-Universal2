#import "HSAnimationPathKnobsProvider.h"

@implementation HSAnimationPathKnobsProvider

// Drops the first knob; the default index moves down with it.
- (id)selectionKnobsArrayAndDefaultKnobIndex:(unsigned int *)aIndex
{
    NSMutableArray *knobs = [super selectionKnobsArrayAndDefaultKnobIndex:aIndex];
    if ([knobs count] == 0)
        return knobs;
    [knobs removeObjectAtIndex:0];
    if (aIndex == NULL)
        return knobs;
    if (*aIndex != 0)
        *aIndex -= 1;
    else if ([knobs count] == 0)
        *aIndex = 0x7fffffff;
    else
        *aIndex = (unsigned int)[knobs count] - 1;
    return knobs;
}

@end
