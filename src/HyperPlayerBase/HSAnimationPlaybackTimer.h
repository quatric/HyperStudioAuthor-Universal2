#import "HyperPlayerBasePrefix.h"


@interface HSAnimationPlaybackTimer : NSObject
{
    double _timeInterval;
    NSMutableSet *_delegates;
    NSTimer *_playbackTimer;
}
+ (id)sharedPlaybackTimer;
- (void)HSAnimationPlaybackTimer_timerFired:(id)aFired;
- (void)stopTimer;
- (void)stopTimerIfNeeded;
- (void)startTimerIfNeeded;
- (double)timeInterval;
- (void)touchDelegate:(id)aDelegate;
- (void)removeDelegate:(id)aDelegate;
- (void)addDelegate:(id)aDelegate;
- (void)dealloc;
- (id)initWithFireTimesPerSecond:(NSInteger)aSecond;
@end

