#import "HSLayoutObjectsSnapper.h"

static float HSRectSideValue(NSRect aRect, NSInteger aSide)
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

@implementation HSLayoutObjectsSnapper

- (BOOL)supportsRulesOfType:(NSInteger)aType
{
    return aType == 1 || aType == 3;
}

// Makes object rules (sides 0-5) and size rules (6, 7) for every layout influencing
// object whose side is within the snap delta of the snapping rect's side.
- (void)calculateSuggestedRulesForSnappingRect:(NSRect)aRect snapDelta:(CGFloat)aDelta edges:(NSInteger)aEdges processor:(id)aProcessor
{
    NSUInteger count = [aProcessor countOfHyperGeometryHoldersForInterface:@protocol(HSLayoutInfluencingObjectGeometry)];
    BOOL objectRulesEnabled = [aProcessor areLayoutRulesEnabledForType:1];
    BOOL allowed[8] = { NO, NO, NO, NO, NO, NO, NO, NO };
    NSMutableArray *rules[8] = { nil, nil, nil, nil, nil, nil, nil, nil };
    BOOL skipsUnallowedSides;
    id ownHolder = nil;
    NSUInteger i;
    NSInteger side;

    if (![self fillAllowedGuidesForSide:allowed withModifyingEdgesMask:aEdges processor:aProcessor])
        return;
    // Unallowed sides 0-3 still collect rules when object rules are on and no size is snapped.
    skipsUnallowedSides = !objectRulesEnabled || allowed[6] || allowed[7];
    for (side = 0; side < 8; side++)
        if (allowed[side] || (!skipsUnallowedSides && side <= 3))
            rules[side] = [NSMutableArray new];
    // The first holder that does not influence layout is the object being moved.
    for (i = 0; i < count; i++) {
        id holder = [aProcessor objectInHyperGeometryHoldersForInterface:@protocol(HSLayoutInfluencingObjectGeometry) atIndex:i];
        if (![holder isHyperInfluencingLayout]) {
            ownHolder = holder;
            break;
        }
    }
    for (i = 0; i < count; i++) {
        id holder = [aProcessor objectInHyperGeometryHoldersForInterface:@protocol(HSLayoutInfluencingObjectGeometry) atIndex:i];
        NSRect bounds = NSRectFromCGRect(CGRectApplyAffineTransform(NSRectToCGRect([holder hyperLayoutInfluencingBoundingRect]), [holder hyperLayoutInfluencingTransform]));

        if (![holder isHyperInfluencingLayout])
            continue;
        for (side = 0; side < 8; side++) {
            float value = HSRectSideValue(aRect, side);
            float otherValue;
            BOOL inRange, found = NO;
            NSUInteger index;
            id rule;

            // Sizes compare with the untransformed size when the moved object is known.
            if (ownHolder != nil && side > 5)
                otherValue = HSRectSideValue([holder hyperLayoutInfluencingBoundingRect], side);
            else
                otherValue = HSRectSideValue(bounds, side);
            if (!allowed[side] && (skipsUnallowedSides || side > 3))
                continue;
            inRange = fabsf(value - otherValue) <= aDelta + 0.0005f;
            if (!inRange)
                continue;
            index = [self indexForRuleWithSingleFloatValue:otherValue inArray:rules[side] foundExact:&found];
            if (!found) {
                if (side == 6 || side == 7) {
                    rule = [aProcessor createLayoutRuleWithType:3 rectSide:side value:otherValue];
                    if (ownHolder != nil)
                        [rule setOwnGeometryHolder:ownHolder];
                }
                else
                    rule = [aProcessor createLayoutRuleWithType:1 rectSide:side value:otherValue];
                [rules[side] insertObject:rule atIndex:index];
                // Fix: the created rule (owned by the processor too) was leaked.
                [rule release];
                if (side == 6)
                    [rule setScalesBySide:allowed[0] ? 0 : 2];
                else if (side == 7)
                    [rule setScalesBySide:allowed[1] ? 1 : 3];
            }
            else
                rule = [rules[side] objectAtIndex:index];
            [[rule usedObjects] addObject:holder];
            [rule setCanSnapTo:allowed[side]];
        }
    }
    if ((aEdges & 5) == 5)
        [self filterOutMidRulesFromArray:rules[4] withMinSideRulesArray:rules[0] maxSideRulesArray:rules[2]];
    if ((aEdges & 10) == 10)
        [self filterOutMidRulesFromArray:rules[5] withMinSideRulesArray:rules[1] maxSideRulesArray:rules[3]];
    for (side = 0; side < 8; side++)
        [rules[side] release];
}

// A middle rule is dropped for objects that already snap to both the min and max side.
- (void)filterOutMidRulesFromArray:(id)aArray withMinSideRulesArray:(id)aArray2 maxSideRulesArray:(id)aArray3
{
    NSEnumerator *enumerator = [aArray2 objectEnumerator];
    id rule;
    NSUInteger index;

    while ((rule = [enumerator nextObject]) != nil) {
        if ([rule affectedRectSidesCount] == 1) {
            float value = [rule layoutRuleFloatValueForRectSide:[rule affectedRectSideAtIndex:0]];
            id maxRule = [self ruleWithSingleFloatValue:value inArray:aArray3];
            id midRule;

            if (!_filtersMidRulesForEachSide && maxRule != nil && (midRule = [self ruleWithSingleFloatValue:value inArray:aArray]) != nil)
                [self filterOutObjectsExistingInSet:[rule usedObjects] andSet:[maxRule usedObjects] outOfSet:[midRule usedObjects]];
        }
    }
    index = 0;
    while (index < [aArray count]) {
        if ([[[aArray objectAtIndex:index] usedObjects] count] == 0)
            [aArray removeObjectAtIndex:index];
        else
            index++;
    }
}

- (void)filterOutObjectsExistingInSet:(id)aSet andSet:(id)aSet2 outOfSet:(id)aSet3
{
    NSEnumerator *enumerator = [aSet objectEnumerator];
    id object;

    while ((object = [enumerator nextObject]) != nil) {
        if ([aSet2 member:object] != nil) {
            id member = [aSet3 member:object];
            if (member != nil)
                [aSet3 removeObject:member];
        }
    }
}

- (void)filterOutObjectsInSet:(id)aSet outOfSet:(id)aSet2
{
    NSEnumerator *enumerator = [aSet objectEnumerator];
    id object;

    while ((object = [enumerator nextObject]) != nil) {
        id member = [aSet2 member:object];
        if (member != nil)
            [aSet2 removeObject:member];
    }
}

// Sides 0-3 follow the edges, 4/5 the middles when both edges of an axis move,
// 6/7 the size when only one edge of an axis moves.
- (BOOL)fillAllowedGuidesForSide:(BOOL *)aSide withModifyingEdgesMask:(NSInteger)aMask processor:(id)aProcessor
{
    BOOL objects = [aProcessor areLayoutRulesEnabledForType:1];
    BOOL sizes = [aProcessor areLayoutRulesEnabledForType:3];
    BOOL bothX = (aMask & 5) == 5;
    BOOL bothY = (aMask & 10) == 10;
    NSInteger side;

    aSide[0] = (aMask & 1) && objects;
    aSide[1] = ((aMask >> 1) & 1) && objects;
    aSide[2] = ((aMask >> 2) & 1) && objects;
    aSide[3] = ((aMask >> 3) & 1) && objects;
    aSide[4] = bothX && objects;
    aSide[5] = bothY && objects;
    aSide[6] = !bothX && (aMask & 5) != 0 && sizes;
    aSide[7] = !bothY && (aMask & 10) != 0 && sizes;
    for (side = 0; side < 8; side++)
        if (aSide[side])
            return YES;
    return NO;
}

@end
