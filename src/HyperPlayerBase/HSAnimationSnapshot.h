#import "HyperPlayerBasePrefix.h"
#import "HSAnimation.h"


@interface HSAnimationSnapshot : NSObject
{
    HSAnimationStructure *_structure;
    HSAnimationOptions *_options;
    double _pathTime;
    HSAnimationFixation *_fixation;
}
+ (id)snapshotWithStructure:(id)aStructure options:(id)aOptions pathTime:(double)aTime fixation:(id)aFixation;
- (id)fixation;
- (double)pathTime;
- (id)options;
- (id)structure;
- (void)dealloc;
- (id)initWithStructure:(id)aStructure options:(id)aOptions pathTime:(double)aTime fixation:(id)aFixation;
@end

@interface HSAnimation (Snapshot)
- (void)replaceWithSnapshot:(id)aSnapshot;
- (id)makeSnapshot;
@end

