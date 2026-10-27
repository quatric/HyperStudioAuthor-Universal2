#import "HyperStudioPrefix.h"
#import "HSLayoutSnapper.h"


@interface HSLayoutObjectsSnapper : HSLayoutSnapper
{
    BOOL _filtersMidRulesForEachSide;
}
- (BOOL)supportsRulesOfType:(NSInteger)aType;
- (void)calculateSuggestedRulesForSnappingRect:(NSRect)aRect snapDelta:(CGFloat)aDelta edges:(NSInteger)aEdges processor:(id)aProcessor;
- (void)filterOutMidRulesFromArray:(id)aArray withMinSideRulesArray:(id)aArray2 maxSideRulesArray:(id)aArray3;
- (void)filterOutObjectsExistingInSet:(id)aSet andSet:(id)aSet2 outOfSet:(id)aSet3;
- (void)filterOutObjectsInSet:(id)aSet outOfSet:(id)aSet2;
- (BOOL)fillAllowedGuidesForSide:(BOOL *)aSide withModifyingEdgesMask:(NSInteger)aMask processor:(id)aProcessor;
@end

