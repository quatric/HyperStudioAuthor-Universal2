#import "HyperStudioPrefix.h"
#import "HSLayoutSnapper.h"


@interface HSLayoutGuideSnapper : HSLayoutSnapper
{
}
- (BOOL)supportsRulesOfType:(NSInteger)aType;
- (void)calculateSuggestedRulesForSnappingRect:(NSRect)aRect snapDelta:(CGFloat)aDelta edges:(NSInteger)aEdges processor:(id)aProcessor;
@end

