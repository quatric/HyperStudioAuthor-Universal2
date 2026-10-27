#import "HSLayoutGridSnapper.h"

@implementation HSLayoutGridSnapper

- (BOOL)supportsRulesOfType:(NSInteger)aType
{
    return aType == 0;
}

- (void)calculateSuggestedRulesForSnappingRect:(NSRect)aRect snapDelta:(CGFloat)aDelta edges:(NSInteger)aEdges processor:(id)aProcessor
{
    id grid;

    if ([aProcessor countOfHyperGeometryHoldersForInterface:@protocol(HSLayoutGridGeometry)] == 0)
        return;
    grid = [aProcessor objectInHyperGeometryHoldersForInterface:@protocol(HSLayoutGridGeometry) atIndex:0];
    if (grid == nil || ![grid isHyperInfluencingLayout])
        return;
    if ([grid snapToCornersOnMove] && ((aEdges & 5) == 5 || (aEdges & 10) == 10))
        [self calculateSuggestedRulesForSnappingMovingRect:aRect toCornersOfGrid:grid snapDelta:aDelta processor:aProcessor];
    else
        [self calculateSuggestedRulesForSnappingRect:aRect toGrid:grid snapDelta:aDelta edges:aEdges processor:aProcessor];
}

// Corners are tried in the order bottom-left (mask 3), top-right (12), bottom-right (6), top-left (9).
- (void)calculateSuggestedRulesForSnappingMovingRect:(NSRect)aRect toCornersOfGrid:(id)aGrid snapDelta:(CGFloat)aDelta processor:(id)aProcessor
{
    static const NSInteger kCorners[4][3] = { { 0, 1, 3 }, { 2, 3, 12 }, { 2, 1, 6 }, { 0, 3, 9 } };
    NSMutableArray *xRules = [NSMutableArray array];
    NSMutableArray *yRules = [NSMutableArray array];
    float yMajorStep = [aGrid yHyperGridMajorStep];
    float xMajorStep = [aGrid xHyperGridMajorStep];
    float yMinorStep = [aGrid yHyperGridMinorStep];
    float xMinorStep = [aGrid xHyperGridMinorStep];
    float delta = aDelta;
    NSInteger corner;

    if ([aGrid hyperGridUseMajorSteps])
        delta = MAX(MAX(yMajorStep, xMajorStep), (float)aDelta);
    if ([aGrid hyperGridUseMinorSteps])
        delta = MAX(MAX(yMinorStep, xMinorStep), delta);
    for (corner = 0; corner < 4; corner++) {
        NSInteger xSide = kCorners[corner][0], ySide = kCorners[corner][1];
        float x = xSide == 0 ? NSMinX(aRect) : NSMaxX(aRect);
        float y = ySide == 1 ? NSMinY(aRect) : NSMaxY(aRect);
        NSUInteger xCount, yCount, i, j;

        if ([aGrid hyperGridUseMajorSteps]) {
            [self calculateRulesWithGridStep:xMajorStep snappingValue:x rectSide:xSide snapDelta:delta snapToNegativeValues:[aGrid snapToNegativeValues] rulesFactory:nil storeInArray:xRules notIncludingRulesInArray:nil];
            [self calculateRulesWithGridStep:yMajorStep snappingValue:y rectSide:ySide snapDelta:delta snapToNegativeValues:[aGrid snapToNegativeValues] rulesFactory:nil storeInArray:yRules notIncludingRulesInArray:nil];
        }
        if ([aGrid hyperGridUseMinorSteps]) {
            NSArray *majorRules = [NSArray arrayWithArray:xRules];
            [self calculateRulesWithGridStep:xMinorStep snappingValue:x rectSide:xSide snapDelta:delta snapToNegativeValues:[aGrid snapToNegativeValues] rulesFactory:nil storeInArray:xRules notIncludingRulesInArray:majorRules];
            majorRules = [NSArray arrayWithArray:yRules];
            [self calculateRulesWithGridStep:yMinorStep snappingValue:y rectSide:ySide snapDelta:delta snapToNegativeValues:[aGrid snapToNegativeValues] rulesFactory:nil storeInArray:yRules notIncludingRulesInArray:majorRules];
        }
        xCount = [xRules count];
        yCount = [yRules count];
        if (xCount != 0 && yCount != 0) {
            for (i = 0; i < xCount; i++) {
                for (j = 0; j < yCount; j++) {
                    float yValue = [[yRules objectAtIndex:j] layoutRuleFloatValueForRectSide:ySide];
                    float xValue = [[xRules objectAtIndex:i] layoutRuleFloatValueForRectSide:xSide];
                    [[aProcessor createGridCornerRuleWithCorner:NSMakePoint(xValue, yValue) rectEdgeMask:kCorners[corner][2]] release];
                }
            }
        }
        [xRules removeAllObjects];
        [yRules removeAllObjects];
    }
}

static float HSGridSnappingValue(NSRect aRect, NSInteger aSide)
{
    switch (aSide) {
    case 0: return aRect.origin.x;
    case 1: return aRect.origin.y;
    case 2: return aRect.origin.x + aRect.size.width;
    case 3: return aRect.origin.y + aRect.size.height;
    case 4: return aRect.size.width * 0.5 + aRect.origin.x;
    case 5: return aRect.size.height * 0.5 + aRect.origin.y;
    case 6: return aRect.size.width;
    case 7: return aRect.size.height;
    default: return 0.0;
    }
}

// Sides 0, 2, 4 and 6 are horizontal.
static BOOL HSGridIsHorizontalSide(NSInteger aSide)
{
    return aSide < 7 && ((0x55 >> aSide) & 1) != 0;
}

- (void)calculateSuggestedRulesForSnappingRect:(NSRect)aRect toGrid:(id)aGrid snapDelta:(CGFloat)aDelta edges:(NSInteger)aEdges processor:(id)aProcessor
{
    NSMutableArray *majorRules[4] = { nil, nil, nil, nil };
    float yStep, xStep;
    NSInteger side;

    if ([aGrid hyperGridUseMinorSteps]) {
        for (side = 0; side < 4; side++)
            if ((aEdges >> side) & 1)
                majorRules[side] = [NSMutableArray new];
    }
    yStep = [aGrid yHyperGridMajorStep];
    xStep = [aGrid xHyperGridMajorStep];
    for (side = 0; side < 4; side++) {
        if ((aEdges >> side) & 1)
            [self calculateRulesWithGridStep:HSGridIsHorizontalSide(side) ? xStep : yStep snappingValue:HSGridSnappingValue(aRect, side) rectSide:side snapDelta:aDelta snapToNegativeValues:[aGrid snapToNegativeValues] rulesFactory:aProcessor storeInArray:majorRules[side] notIncludingRulesInArray:nil];
    }
    if ([aGrid hyperGridUseMinorSteps]) {
        yStep = [aGrid yHyperGridMinorStep];
        xStep = [aGrid xHyperGridMinorStep];
        for (side = 0; side < 4; side++) {
            if ((aEdges >> side) & 1)
                [self calculateRulesWithGridStep:HSGridIsHorizontalSide(side) ? xStep : yStep snappingValue:HSGridSnappingValue(aRect, side) rectSide:side snapDelta:aDelta snapToNegativeValues:[aGrid snapToNegativeValues] rulesFactory:aProcessor storeInArray:nil notIncludingRulesInArray:majorRules[side]];
        }
    }
    for (side = 0; side < 4; side++)
        [majorRules[side] release];
}

- (void)calculateRulesWithGridStep:(CGFloat)aStep snappingValue:(CGFloat)aValue rectSide:(NSInteger)aSide snapDelta:(CGFloat)aDelta snapToNegativeValues:(BOOL)aValues rulesFactory:(id)aFactory storeInArray:(id)aArray notIncludingRulesInArray:(id)aArray2
{
    const float tolerance = 0.0005f;
    float step = aStep, value = aValue, delta = aDelta;
    float first = floorf((value - delta) / step) * step;
    float last;

    if (first < (value - delta) - tolerance)
        first += step;
    if (!aValues && first < 0.0f - tolerance)
        first = 0.0f;
    last = ceilf((value + delta) / step) * step;
    if (last <= value + delta + tolerance)
        last += step;
    if (!aValues && last < 0.0f - tolerance)
        last = 0.0f;
    for (; first < last; first += step) {
        id rule;

        if (aArray2 != nil && [self ruleWithSingleFloatValue:first inArray:aArray2] != nil)
            continue;
        // Fix: the factory's rule (owned by the processor too) was leaked.
        if (aFactory == nil)
            rule = [[HSLayoutSimpleRule alloc] initWithAxisType:HSGridIsHorizontalSide(aSide) ? 0 : 1 rectSide:aSide value:first type:0];
        else
            rule = [aFactory createLayoutRuleWithType:0 rectSide:aSide value:first];
        if (aArray != nil)
            [aArray addObject:rule];
        [rule release];
    }
}

@end
