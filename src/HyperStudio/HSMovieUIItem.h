#import "HyperStudioPrefix.h"
#import "HSPlaybackUIItem.h"


@interface HSMovieUIItem : HSPlaybackUIItem <HSMovieUIItemInterface, NSObject>
{
    HSMoviePlaybackItem *_moviePlaybackItem;
    NSCalendarDate *_movieDuration;
}
- (id)playbackItem;
- (id)duration;
- (BOOL)isTemporary;
- (BOOL)isEnabled;
- (BOOL)isInAction;
- (id)displayName;
- (void)setMoviePlaybackItem:(id)aItem;
- (id)moviePlaybackItem;
- (id)movieDuration;
- (void)dealloc;
- (id)initWithMoviePlaybackItem:(id)aItem playbackItemSupport:(id)aSupport;
@end

