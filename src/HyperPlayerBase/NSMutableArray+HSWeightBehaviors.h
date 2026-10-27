#import "HyperPlayerBasePrefix.h"


@interface NSMutableArray (HSWeightBehaviors)
- (id)weightForDelta:(double)aDelta betweenWeight:(id)aWeight andWeight:(id)aWeight2;
- (double)deltaForWeight:(id)aWeight betweenWeight:(id)aWeight2 andWeight:(id)aWeight3;
- (void)sortByHyperOrder;
- (void)exchangeWeighedObjectAtIndex:(NSUInteger)aIndex withObjectAtIndex:(NSUInteger)aIndex2;
- (void)insertWeighedHyperObject:(id)aObject atIndex:(NSUInteger)aIndex;
- (void)normalizeHyperWeight;
- (id)hyperWeightForIndex:(NSUInteger)aIndex;
- (NSUInteger)hyperIndexForWeight:(id)aWeight;
@end

