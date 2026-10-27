#import "HSAnimationPlaybackState.h"
// The clock of one animation playback: a start date ticked by a playback
// timer (the shared one at the normal rate, or its own), paused and resumed
// by moving the start date. The owner (not retained) gives the duration (−1
// for endless) and is told when the time changes, starts and ends.
@implementation HSAnimationPlaybackState
- (double)playbackTime
{
    return _playbackTime;
}
- (void)proceedAnimationOnTimer
{
    if (_paused)
        return;
    _playbackTime = MAX([[NSDate date] timeIntervalSinceDate:_startDate], 0.0);
    double duration = [_owner playbackDurationForAnimationPlaybackState:self];
    if (duration == -1.0 || _playbackTime < duration) {
        [_owner playbackTimeDidChangeForAnimationPlaybackState:self];
    } else {
        _playbackTime = duration;
        [_owner playbackTimeDidChangeForAnimationPlaybackState:self];
        [self stop];
    }
}

- (void)resume
{
    if (!_paused)
        return;
    _paused = NO;
    [_startDate release];
    _startDate = [[NSDate dateWithTimeIntervalSinceNow:-_playbackTime] retain];
    [_playbackTimer touchAnimation:self];
}
- (void)pause
{
    if (_playbackTimer != nil)
        _paused = YES;
}
- (BOOL)isPaused
{
    return _paused;
}
- (void)stop
{
    if (_playbackTimer == nil)
        return;
    [_playbackTimer removeAnimation:self];
    [_playbackTimer release];
    _playbackTimer = nil;
    [_startDate release];
    _startDate = nil;
    _paused = NO;
    [_owner playbackDidEndForAnimationPlaybackState:self];
    _playbackTime = 0;
}
- (void)start
{
    [self stop];
    [_owner playbackWillStartForAnimationPlaybackState:self];
    if ([_owner usesNormalTimesPerSecondForAnimationPlaybackState:self])
        _playbackTimer = [[HSAnimationPlaybackTimer sharedController] retain];
    else
        _playbackTimer = [[HSAnimationPlaybackTimer alloc]
            initWithRate:[_owner timesPerSecondForAnimationPlaybackState:self]];
    _startDate = [[NSDate date] retain];
    _playbackTime = 0;
    _paused = NO;
    [_playbackTimer addAnimation:self];
}
- (BOOL)isPlaying
{
    return _playbackTimer != nil && !_paused;
}
- (void)setOwner:(id)aOwner
{
    _owner = aOwner;
}
- (id)owner
{
    return _owner;
}
// (Like the original, assumes the playback was stopped.)
- (void)dealloc
{
    [super dealloc];
}
- (id)init
{
    self = [super init];
    if (self != nil) {
        _playbackTime = 0;
        _paused = NO;
    }
    return self;
}
@end
