#import "HyperStudioPrefix.h"


@interface HSObjectsOptimizer : NSObject
{
    HSUID *_mediaUID;
    NSSet *_objects;
}
+ (BOOL)canOptimizeMediaUID:(id)aUID usedInObjects:(id)aObjects;
+ (id)optimizerForMediaUID:(id)aUID usedInObjects:(id)aObjects;
- (void)postprocessAfterOptimization;
- (void)optimize;
- (id)objects;
- (id)mediaUID;
- (void)dealloc;
- (id)initWithMediaUID:(id)aUID usedInObjects:(id)aObjects;
@end

