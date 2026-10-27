#import "HSLayoutSnapper.h"

@implementation HSLayoutSnapper

- (BOOL)supportsRulesOfType:(NSInteger)aType
{
    return NO;
}

- (void)calculateSuggestedRulesForSnappingRect:(NSRect)aRect snapDelta:(CGFloat)aDelta edges:(NSInteger)aEdges processor:(id)aProcessor
{
}

- (id)ruleWithSingleFloatValue:(CGFloat)aValue inArray:(id)aArray
{
    BOOL exact = NO;
    NSUInteger index = [self indexForRuleWithSingleFloatValue:aValue inArray:aArray foundExact:&exact];
    return exact ? [aArray objectAtIndex:index] : nil;
}

// Single-side rules are sorted by value: returns the match, or where the value would be inserted.
- (NSUInteger)indexForRuleWithSingleFloatValue:(CGFloat)aValue inArray:(id)aArray foundExact:(BOOL *)aExact
{
    float tolerance = 0.0005f;
    NSUInteger count = [aArray count];
    NSUInteger index;
    BOOL exact = NO;
    for (index = 0; index < count; index++) {
        id rule = [aArray objectAtIndex:index];
        if ([rule affectedRectSidesCount] != 1)
            continue;
        float value = [rule layoutRuleFloatValueForRectSide:[rule affectedRectSideAtIndex:0]];
        if (fabsf(value - (float)aValue) <= tolerance) {
            exact = YES;
            break;
        }
        if (value > tolerance + (float)aValue)
            break;
    }
    *aExact = exact;
    return index;
}

@end
