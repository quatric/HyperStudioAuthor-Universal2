#import "HSTransitionPlayer.h"
#import "HSThreadInvocationWrapper.h"
#import "HSTransitionEffect.h"

// Plays _transitionEffect over the range [start, start + rangeDuration] of transition time (rangeDuration may
// be negative to play backwards), taking _duration seconds for a range of 1.
@implementation HSTransitionPlayer
- (void)playNewFrame
{
    [_delegate transitionPlayerDidPlayNewFrame:self];
}
- (void)setTransitionTime:(double)aTime
{
    if (_transitionTime == aTime)
        return;
    if (_timer == nil) {
        _transitionTime = aTime;
    } else {
        _startTime = [NSDate timeIntervalSinceReferenceDate] - copysign((aTime - _transitionPlayRangeStartTime) * _duration, _transitionPlayRangeDuration);
        [self HSTransitionPlayer_play];
    }
}
- (double)transitionTime
{
    return _transitionTime;
}
- (BOOL)isPlaying
{
    return _timer != nil;
}
- (void)stop
{
    [_timer invalidate];
    [_timer release];
    _timer = nil;
}
- (BOOL)start
{
    if (_duration == 0.0)
        return NO;
    _timer = [self HSTransitionPlayer_createAndScheduleTimerWithTimeInterval:[self HSTransitionPlayer_timeInterval]];
    if (_timer == nil)
        return NO;
    _startTime = [NSDate timeIntervalSinceReferenceDate];
    _transitionTime = _transitionPlayRangeStartTime;
    return YES;
}
- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}
- (id)delegate
{
    return _delegate;
}
- (void)setMaxFPS:(double)aFPS
{
    if (_maxFPS == aFPS)
        return;
    _maxFPS = aFPS;
    if (_timer == nil)
        return;
    double current = [_timer timeInterval];
    double interval = [self HSTransitionPlayer_timeInterval];
    if (interval < current - 5e-07 || current + 5e-07 < interval) {
        [_timer invalidate];
        [_timer release];
        _timer = [self HSTransitionPlayer_createAndScheduleTimerWithTimeInterval:interval];
    }
}
- (double)maxFPS
{
    return _maxFPS;
}
// While playing, the start time shifts so playback continues from the same transition time.
- (void)setTransitionPlayRangeStartTime:(double)aTime duration:(double)aDuration
{
    double oldStart = _transitionPlayRangeStartTime;
    double oldDuration = _transitionPlayRangeDuration;
    if (oldStart == aTime && oldDuration == aDuration)
        return;
    _transitionPlayRangeStartTime = aTime;
    _transitionPlayRangeDuration = aDuration;
    if (_timer == nil)
        return;
    double now = [NSDate timeIntervalSinceReferenceDate];
    _startTime = copysign((_transitionPlayRangeStartTime - oldStart) * _duration, oldDuration) + _startTime;
    if (oldDuration * _transitionPlayRangeDuration < 0.0)
        _startTime = (now + now) - _startTime;
    if (now < _startTime)
        _startTime = now;
    [self HSTransitionPlayer_play];
}
- (double)transitionPlayRangeDuration
{
    return _transitionPlayRangeDuration;
}
- (double)transitionPlayRangeStartTime
{
    return _transitionPlayRangeStartTime;
}
- (void)setDuration:(double)aDuration
{
    double oldDuration = _duration;
    if (oldDuration == aDuration)
        return;
    _duration = aDuration;
    if (_timer == nil)
        return;
    if (aDuration == 0.0) {
        [self HSTransitionPlayer_finish];
        return;
    }
    double now = [NSDate timeIntervalSinceReferenceDate];
    _startTime = now - ((now - _startTime) * _duration) / oldDuration;
    [self HSTransitionPlayer_play];
}
- (double)duration
{
    return _duration;
}
- (void)setTransitionEffect:(id)aEffect
{
    if (_transitionEffect == aEffect)
        return;
    [aEffect retain];
    [_transitionEffect release];
    _transitionEffect = aEffect;
}
- (id)transitionEffect
{
    return _transitionEffect;
}
- (void)dealloc
{
    [_timer invalidate];
    [_timer release];
    [_transitionEffect release];
    [super dealloc];
}
- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (defaults != nil) {
        _maxFPS = [defaults floatForKey:@"HSDefaultTransitionFPS"];
        _duration = [defaults floatForKey:@"HSDefaultTransitionDuration"];
    }
    _transitionPlayRangeDuration = 1.0;
    return self;
}
- (void)HSTransitionPlayer_play
{
    double elapsed = ([NSDate timeIntervalSinceReferenceDate] - _startTime) / _duration;
    double progress = _transitionPlayRangeDuration;
    if (elapsed <= fabs(progress))
        progress = copysign(elapsed, progress);
    double time = _transitionPlayRangeStartTime + progress;
    BOOL isNewFrame = [_transitionEffect isNewFrameAtTime:time relativeToTime:_transitionTime];
    _transitionTime = time;
    if (isNewFrame)
        [self playNewFrame];
    if (progress == _transitionPlayRangeDuration)
        [self HSTransitionPlayer_finish];
}
- (void)HSTransitionPlayer_finish
{
    [_timer invalidate];
    [_timer release];
    _timer = nil;
    [_delegate transitionPlayerDidFinish:self];
}
- (id)HSTransitionPlayer_createAndScheduleTimerWithTimeInterval:(double)aInterval
{
    return [[NSThread hyperScheduledThreadTimerWithInterval:aInterval mainThreadTarget:self selector:@selector(HSTransitionPlayer_play) repeats:YES] retain];
}
// One frame at maxFPS (capped at 60), but never longer than the whole transition.
- (double)HSTransitionPlayer_timeInterval
{
    double fps = 60.0;
    if (_maxFPS <= 60.0 && _maxFPS != 0.0)
        fps = _maxFPS;
    double interval = _duration;
    if (1.0 / fps <= _duration)
        interval = 1.0 / fps;
    return interval;
}
@end

@implementation NSObject (HSTransitionPlayerDelegate)
- (void)transitionPlayerDidFinish:(id)aFinish
{
}
- (void)transitionPlayerDidPlayNewFrame:(id)aFrame
{
}
@end
