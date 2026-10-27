#import "HyperPlayerBasePrefix.h"


@interface HSAnimationMoviePlayback : NSObject
{
    id<HSAnimationMoviePlaybackDataSource, HSAnimationMoviePlaybackDelegate> _owner;
    int _playTimeLoopFrameRepeats;
    int _playTimeLoopMode;
    unsigned int _playTimeIsMatchToMovement:1;
    id<HSExtendedPlayableObjectAttributes> _playTimeAttributes;
    double _playTimeLoopFrameRepeatsStopTime;
    double _playbackCompletionTime;
}
- (void)stop;
- (BOOL)isPlaying;
- (id)objectToAnimate;
- (id)options;
- (id)structure;
- (void)hyperPlayableObjectDidStop:(id)aStop;
- (void)hyperPlayableObjectDidPlayOnce:(id)aOnce frameCount:(NSInteger)aCount;
- (CGFloat)movieDuration;
- (CGFloat)movieRelativeSpeed;
- (void)playbackTimeDidChange:(double)aChange;
- (void)stopMovieIfNecessary;
- (void)startMovieIfNecessary;
- (void)setOwner:(id)aOwner;
- (id)owner;
- (void)dealloc;
@end

