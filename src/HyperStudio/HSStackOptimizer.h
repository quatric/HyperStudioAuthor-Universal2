#import "HyperStudioPrefix.h"


@interface HSStackOptimizer : NSObject
{
    NSMutableArray *_optimizers;
}
- (void)createOptimizersForStack:(id)aStack;
- (id)newMediaUIDToObjectsMapForStack:(id)aStack;
- (void)addOptimizableObjectsFromEnumerator:(id)aEnumerator inMediaUIDToObjectsMap:(id)aMap;
- (void)postprocessAfterOptimization;
- (void)optimizeStack:(id)aStack;
- (void)dealloc;
@end

