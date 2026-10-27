#import "NSMutableArray+HSWeightBehaviors.h"
// Ordering by weights: dotted strings of 32-bit numbers ("2147483647",
// "5.2147483647") that sort numerically, so an object can be put between
// two others without renumbering the rest.
@implementation NSMutableArray (HSWeightBehaviors)
// The single-level weight a fraction of the way between two (nil: the ends).
- (id)weightForDelta:(double)aDelta betweenWeight:(id)aWeight andWeight:(id)aWeight2
{
    unsigned int low = aWeight != nil ? (unsigned int)[aWeight hyperUnsignedValue] : 0;
    unsigned int high = aWeight2 != nil ? (unsigned int)[aWeight2 hyperUnsignedValue] : 0xffffffff;
    return [NSString stringWithFormat:@"%u", (unsigned int)(low + (double)(unsigned int)(high - low) * aDelta)];
}
- (double)deltaForWeight:(id)aWeight betweenWeight:(id)aWeight2 andWeight:(id)aWeight3
{
    unsigned int low = aWeight2 != nil ? (unsigned int)[aWeight2 hyperUnsignedValue] : 0;
    unsigned int weight = (unsigned int)[aWeight hyperUnsignedValue];
    unsigned int high = aWeight3 != nil ? (unsigned int)[aWeight3 hyperUnsignedValue] : 0xffffffff;
    return ((double)weight - (double)low) / (double)(unsigned int)(high - low);
}
- (void)sortByHyperOrder
{
    [self sortUsingSelector:@selector(compareWeight:)];
}
- (void)exchangeWeighedObjectAtIndex:(NSUInteger)aIndex withObjectAtIndex:(NSUInteger)aIndex2
{
    id weight = [[[[self objectAtIndex:aIndex] weight] retain] autorelease];
    id weight2 = [[[[self objectAtIndex:aIndex2] weight] retain] autorelease];
    [[self objectAtIndex:aIndex] setWeight:weight2];
    [[self objectAtIndex:aIndex2] setWeight:weight];
    [self exchangeObjectAtIndex:aIndex withObjectAtIndex:aIndex2];
}
// The object keeps its weight if that already sorts it at the index (and
// isn't the default "1" or a tie), else gets one between its neighbours.
- (void)insertWeighedHyperObject:(id)aObject atIndex:(NSUInteger)aIndex
{
    id weight = [aObject weight];
    BOOL keep = [self count] != aIndex && ![weight isEqualToString:@"1"] && [self hyperIndexForWeight:weight] == aIndex
                && ![weight isEqualToString:[[self objectAtIndex:aIndex] weight]];
    if (!keep)
        [aObject setWeight:[self hyperWeightForIndex:aIndex]];
    [self insertObject:aObject atIndex:aIndex];
}
// Evenly spread single-level weights.
- (void)normalizeHyperWeight
{
    unsigned int step = (unsigned int)(0xffffffffULL / ((unsigned long long)[self count] + 1));
    unsigned int weight = step;
    for (id object in [[self copy] autorelease]) {
        [object setWeight:[NSString stringWithFormat:@"%u", weight]];
        weight += step;
    }
}
// Halfway between the neighbours' weights, a level deeper wherever they
// are too close.
- (id)hyperWeightForIndex:(NSUInteger)aIndex
{
    NSArray *before = aIndex != 0 ? [[[self objectAtIndex:aIndex - 1] weight] componentsSeparatedByString:@"."] : nil;
    NSArray *after = aIndex < [self count] ? [[[self objectAtIndex:aIndex] weight] componentsSeparatedByString:@"."] : nil;
    NSMutableString *weight = nil;
    NSUInteger level = 0;
    unsigned int half;
    do {
        unsigned int low = level < [before count] ? (unsigned int)[[before objectAtIndex:level] hyperUnsignedValue] : 0;
        unsigned int high = level < [after count] ? (unsigned int)[[after objectAtIndex:level] hyperUnsignedValue] : 0xffffffff;
        half = (unsigned int)(high - low) >> 1;
        if (weight == nil)
            weight = [NSMutableString stringWithFormat:@"%u", low + half];
        else
            [weight appendFormat:@".%u", low + half];
        level++;
    } while (half == 0);
    return weight;
}
// The index of the first object weighing at least that much (numerically).
- (NSUInteger)hyperIndexForWeight:(id)aWeight
{
    NSUInteger count = [self count];
    for (NSUInteger index = 0; index < count; index++)
        if ([[[self objectAtIndex:index] weight] compare:aWeight options:NSNumericSearch] != NSOrderedAscending)
            return index;
    return count;
}
@end
