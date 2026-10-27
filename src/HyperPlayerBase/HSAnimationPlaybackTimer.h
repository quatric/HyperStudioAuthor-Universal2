#import "HyperPlayerBasePrefix.h"


@interface HSAnimationPlaybackTimer : NSObject
{
    int _timesPerSecond;
    NSMutableSet *_entries;
    NSMutableSet *_finishedEntries;
    NSTimer *_playbackTimer;
}
+ (id)sharedController;
+ (NSInteger)defaultTimesPerSecond;
- (id)initWithRate:(NSInteger)aRate;
- (NSInteger)timesPerSecond;
- (void)dealloc;
- (void)addAnimation:(id)aAnimation;
- (void)removeAnimation:(id)aAnimation;
- (void)animationDidFinish:(id)aAnimation;
- (BOOL)hasAnimation:(id)aAnimation;
- (void)touchAnimation:(id)aAnimation;
- (double)timerPeriod;
- (void)startTimerIfNecessary;
- (void)stopTimer;
- (void)HSAnimationPlaybackTimer_timerFired:(id)aFired;
- (void)removeFinishedAnimations;
@end
