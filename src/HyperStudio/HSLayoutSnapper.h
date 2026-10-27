#import "HyperStudioPrefix.h"


@interface HSLayoutSnapper : NSObject
{
}
- (BOOL)supportsRulesOfType:(NSInteger)aType;
- (void)calculateSuggestedRulesForSnappingRect:(NSRect)aRect snapDelta:(CGFloat)aDelta edges:(NSInteger)aEdges processor:(id)aProcessor;
- (id)ruleWithSingleFloatValue:(CGFloat)aValue inArray:(id)aArray;
- (NSUInteger)indexForRuleWithSingleFloatValue:(CGFloat)aValue inArray:(id)aArray foundExact:(BOOL *)aExact;
@end

