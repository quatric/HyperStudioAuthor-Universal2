#import "HyperStudioPrefix.h"
#import "HSPlaybackUIItem.h"


@interface HSLiveVideoUIItem : HSPlaybackUIItem <HSLiveVideoUIItemInterface, NSObject>
{
    HSLiveVideoPlaybackItem *_liveVideoPlaybackItem;
    NSCalendarDate *_duration;
}
- (id)playbackItem;
- (BOOL)isTemporary;
- (BOOL)isEnabled;
- (BOOL)isInAction;
- (id)displayName;
- (void)setLiveVideoPlaybackItem:(id)aItem;
- (id)liveVideoPlaybackItem;
- (id)deviceName;
- (id)duration;
- (void)dealloc;
- (id)initWithLiveVideoPlaybackItem:(id)aItem playbackItemSupport:(id)aSupport;
@end

