#import "HyperStudioPrefix.h"
#import "HSObjectsOptimizer.h"


@interface HSPlaySoundActionsOptimizer : HSObjectsOptimizer
{
}
+ (id)soundForMediaUID:(id)aUID inPlaySoundAction:(id)aAction;
+ (BOOL)canOptimizeMediaUID:(id)aUID usedInObjects:(id)aObjects;
- (id)optimizedMedia;
- (id)anySoundPlayback;
- (void)optimize;
@end

