#import "HSLayoutGuideSnapper.h"

static BOOL HSWithinSnapDelta(float aDistance, float aDelta)
{
    float distance = fabsf(aDistance);
    float magnitude = MAX(aDelta != 0.0f ? fabsf(aDelta) : 1.0f, distance != 0.0f ? distance : 1.0f);
    return distance <= magnitude * 0.0005f + aDelta;
}

@implementation HSLayoutGuideSnapper

- (BOOL)supportsRulesOfType:(NSInteger)aType
{
    return aType == 2;
}

- (void)calculateSuggestedRulesForSnappingRect:(NSRect)aRect snapDelta:(CGFloat)aDelta edges:(NSInteger)aEdges processor:(id)aProcessor
{
    NSUInteger count = [aProcessor countOfHyperGeometryHoldersForInterface:@protocol(HSLayoutGuideGeometry)];
    for (NSUInteger i = 0; i < count; i++) {
        id guide = [aProcessor objectInHyperGeometryHoldersForInterface:@protocol(HSLayoutGuideGeometry) atIndex:i];
        float coordinate = [guide hyperLayoutGuideCoordinate];
        if (![guide isHyperInfluencingLayout])
            continue;
        if (![guide isHorizontalHyperLayoutGuide]) {
            if ((aEdges & 1) && HSWithinSnapDelta(NSMinX(aRect) - coordinate, aDelta))
                [aProcessor createLayoutRuleWithType:2 rectSide:0 value:coordinate];
            if ((aEdges & 4) && HSWithinSnapDelta(NSMaxX(aRect) - coordinate, aDelta))
                [aProcessor createLayoutRuleWithType:2 rectSide:2 value:coordinate];
        } else {
            if ((aEdges & 2) && HSWithinSnapDelta(NSMinY(aRect) - coordinate, aDelta))
                [aProcessor createLayoutRuleWithType:2 rectSide:1 value:coordinate];
            if ((aEdges & 8) && HSWithinSnapDelta(NSMaxY(aRect) - coordinate, aDelta))
                [aProcessor createLayoutRuleWithType:2 rectSide:3 value:coordinate];
        }
    }
}

@end
