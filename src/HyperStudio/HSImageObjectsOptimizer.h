#import "HyperStudioPrefix.h"
#import "HSObjectsOptimizer.h"


@interface HSImageObjectsOptimizer : HSObjectsOptimizer
{
    NSSet *_nonEmptyObjects;
    NSSet *_emptyObjects;
}
+ (BOOL)canConsolidateObject:(id)aObject;
+ (BOOL)canOptimizeMediaUID:(id)aUID usedInObjects:(id)aObjects;
+ (BOOL)canOptimizeImageObjectsInSet:(id)aSet;
+ (BOOL)isImageObjectsInSet:(id)aSet;
- (void)postprocessAfterOptimization;
- (void)optimizeIgnoringDataLength:(BOOL)aLength;
- (void)optimize;
- (id)emptyObjects;
- (id)nonEmptyObjects;
- (void)filterObjects;
- (id)cropAppliers;
- (void)dealloc;
@end

