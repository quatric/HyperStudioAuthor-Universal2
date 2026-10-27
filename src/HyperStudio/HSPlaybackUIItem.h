#import "HyperStudioPrefix.h"


@interface HSPlaybackUIItem : NSObject
{
    id<HSPlaybackItemSupport> _playbackItemSupport;
}
- (id)isEnableForSorting;
- (NSInteger)localizedCompare:(id)aCompare;
- (id)playbackItem;
- (id)duration;
- (id)deviceName;
- (BOOL)isTemporary;
- (BOOL)isEnabled;
- (BOOL)isInAction;
- (id)displayName;
- (void)setPlaybackItemSupport:(id)aSupport;
- (id)playbackItemSupport;
- (void)dealloc;
- (id)initWithPlaybackItemSupport:(id)aSupport;
@end

