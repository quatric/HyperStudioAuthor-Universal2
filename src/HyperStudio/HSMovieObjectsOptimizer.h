#import "HyperStudioPrefix.h"
#import "HSObjectsOptimizer.h"


@interface HSMovieObjectsOptimizer : HSObjectsOptimizer
{
}
+ (BOOL)canOptimizeMediaUID:(id)aUID usedInObjects:(id)aObjects;
+ (struct HSTimeRange)timeRangeInObject:(id)aObject uid:(id)aUid hyperDuration:(double *)aDuration;
+ (id)movieForMediaUID:(id)aUID inPlayMovieAction:(id)aAction;
- (void)optimize;
- (id)optimizedMedia;
- (struct HSTimeRange)mergedPlayRangeUsedInObjects:(id)aObjects;
@end

