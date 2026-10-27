#import "HyperPlayerBasePrefix.h"


@interface HSTransitionPlayer : NSObject
{
    HSTransitionEffect *_transitionEffect;
    double _duration;
    double _transitionPlayRangeStartTime;
    double _transitionPlayRangeDuration;
    double _maxFPS;
    id _delegate;
    double _startTime;
    double _transitionTime;
    NSTimer *_timer;
}
- (void)playNewFrame;
- (void)setTransitionTime:(double)aTime;
- (double)transitionTime;
- (BOOL)isPlaying;
- (void)stop;
- (BOOL)start;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)setMaxFPS:(double)aFPS;
- (double)maxFPS;
- (void)setTransitionPlayRangeStartTime:(double)aTime duration:(double)aDuration;
- (double)transitionPlayRangeDuration;
- (double)transitionPlayRangeStartTime;
- (void)setDuration:(double)aDuration;
- (double)duration;
- (void)setTransitionEffect:(id)aEffect;
- (id)transitionEffect;
- (void)dealloc;
- (id)init;
- (void)HSTransitionPlayer_play;
- (void)HSTransitionPlayer_finish;
- (id)HSTransitionPlayer_createAndScheduleTimerWithTimeInterval:(double)aInterval;
- (double)HSTransitionPlayer_timeInterval;
@end

@interface NSObject (HSTransitionPlayerDelegate)
- (void)transitionPlayerDidFinish:(id)aFinish;
- (void)transitionPlayerDidPlayNewFrame:(id)aFrame;
@end

