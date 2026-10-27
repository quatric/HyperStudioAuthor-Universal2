#import "HyperPlayerBasePrefix.h"


@interface HSAnimationTimes : NSObject
{
    id<HSAnimationTimesDataSource> _dataSource;
}
- (double)loopPlaybackTimeForPlaybackTime:(double)aTime;
- (double)pathTimeForLoopPlaybackTime:(double)aTime;
- (double)loopPlaybackDuration;
- (double)pathPlaybackDuration;
- (NSInteger)normalTimesPerSecond;
- (NSInteger)timesPerSecond;
- (id)options;
- (id)structure;
- (BOOL)isReturningAtPlaybackTime:(double)aTime;
- (double)pathTimeForPlaybackTime:(double)aTime;
- (double)playbackDuration;
- (void)setDataSource:(id)aSource;
- (id)dataSource;
@end

