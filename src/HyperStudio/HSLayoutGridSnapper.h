#import "HyperStudioPrefix.h"
#import "HSLayoutSnapper.h"


@interface HSLayoutGridSnapper : HSLayoutSnapper
{
}
- (BOOL)supportsRulesOfType:(NSInteger)aType;
- (void)calculateSuggestedRulesForSnappingRect:(NSRect)aRect snapDelta:(CGFloat)aDelta edges:(NSInteger)aEdges processor:(id)aProcessor;
- (void)calculateSuggestedRulesForSnappingMovingRect:(NSRect)aRect toCornersOfGrid:(id)aGrid snapDelta:(CGFloat)aDelta processor:(id)aProcessor;
- (void)calculateSuggestedRulesForSnappingRect:(NSRect)aRect toGrid:(id)aGrid snapDelta:(CGFloat)aDelta edges:(NSInteger)aEdges processor:(id)aProcessor;
- (void)calculateRulesWithGridStep:(CGFloat)aStep snappingValue:(CGFloat)aValue rectSide:(NSInteger)aSide snapDelta:(CGFloat)aDelta snapToNegativeValues:(BOOL)aValues rulesFactory:(id)aFactory storeInArray:(id)aArray notIncludingRulesInArray:(id)aArray2;
@end

