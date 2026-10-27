#import "HyperPlayerBasePrefix.h"


@interface HSAnimationPlaybackState : NSObject <HSAnimationPlaybackState, HSAnimationPlaybackTimerDelegate, NSObject>
{
    id<HSAnimationPlaybackStateDataSource, HSAnimationPlaybackStateDelegate> _owner;
    HSAnimationPlaybackTimer *_playbackTimer;
    NSDate *_startDate;
    double _playbackTime;
    BOOL _paused;
}
- (void)proceedAnimationOnTimer;
- (double)playbackTime;
- (void)resume;
- (void)pause;
- (BOOL)isPaused;
- (void)stop;
- (void)start;
- (BOOL)isPlaying;
- (void)setOwner:(id)aOwner;
- (id)owner;
- (void)dealloc;
- (id)init;
@end

