#import "HSAnimationTimes.h"
// Maps playback time to path time for an animation, from its structure
// (path duration) and options (loop mode, speed mode, back and forth,
// direction) given by the data source (not retained).
//
// Loop modes: 0 once, 1 and 4 forever, 2 a number of times, 3 for a number
// of seconds. Speed modes: 0 by multiplier, 1 a fixed duration, 2 at the
// normal rate. Directions: 0 forward, 1 backward.
@implementation HSAnimationTimes
- (double)loopPlaybackTimeForPlaybackTime:(double)aTime
{
    double loopDuration = [self loopPlaybackDuration];
    NSInteger loopMode = [[self options] loopMode];
    switch (loopMode) {
    case 1:
    case 3:
    case 4:
        return fmod(aTime, loopDuration);
    case 0:
    case 2:
        if (aTime < [self playbackDuration])
            return fmod(aTime, loopDuration);
        return loopDuration;
    default:
        return 0.0;
    }
}
- (double)pathTimeForLoopPlaybackTime:(double)aTime
{
    double duration = [(HSAnimationStructure *)[self structure] duration];
    BOOL backAndForth = [[self options] playBackAndForth];
    NSInteger direction = [[self options] playbackDirection];
    if (!backAndForth) {
        double pathTime = aTime * duration / [self loopPlaybackDuration];
        if (direction == 1)
            return duration - pathTime;
        return direction == 0 ? pathTime : 0.0;
    }
    double pathDuration = [self pathPlaybackDuration];
    if (aTime <= pathDuration) {
        double pathTime = aTime * duration / pathDuration;
        if (direction == 1)
            return duration - pathTime;
        return direction == 0 ? pathTime : 0.0;
    }
    // The way back.
    double pathTime = (aTime - pathDuration) * duration / pathDuration;
    if (direction == 0)
        return duration - pathTime;
    return direction == 1 ? pathTime : 0.0;
}
- (double)loopPlaybackDuration
{
    double duration = [self pathPlaybackDuration];
    if ([[self options] playBackAndForth])
        duration += duration;
    return duration;
}
- (double)pathPlaybackDuration
{
    switch ([[self options] speedMode]) {
    case 0:
        return [(HSAnimationStructure *)[self structure] duration] / [[self options] speedMultiplier];
    case 1:
        return [[self options] clampedDuration];
    case 2:
        if ([[self structure] path] != nil)
            return ((double)[self normalTimesPerSecond] / (double)[self timesPerSecond]) * [(HSAnimationStructure *)[self structure] duration];
        return 0.0;
    default:
        return 0.0;
    }
}
- (NSInteger)normalTimesPerSecond
{
    return [_dataSource normalTimesPerSecondForAnimationTimes:self];
}
- (NSInteger)timesPerSecond
{
    return [_dataSource timesPerSecondForAnimationTimes:self];
}
- (id)options
{
    return [_dataSource optionsForAnimationTimes:self];
}
- (id)structure
{
    return [_dataSource structureForAnimationTimes:self];
}
- (BOOL)isReturningAtPlaybackTime:(double)aTime
{
    return [self pathPlaybackDuration] < [self loopPlaybackTimeForPlaybackTime:aTime];
}
- (double)pathTimeForPlaybackTime:(double)aTime
{
    return [self pathTimeForLoopPlaybackTime:[self loopPlaybackTimeForPlaybackTime:aTime]];
}
// −1 for endless playback.
- (double)playbackDuration
{
    switch ([[self options] loopMode]) {
    case 0:
        return [self loopPlaybackDuration];
    case 1:
    case 4:
        return -1.0;
    case 2:
        return (double)[[self options] loopPathRepeats] * [self loopPlaybackDuration];
    case 3:
        return [[self options] loopSeconds];
    default:
        return 0.0;
    }
}
- (void)setDataSource:(id)aSource
{
    _dataSource = aSource;
}
- (id)dataSource
{
    return _dataSource;
}
@end
