#import "HSGraphicCompositionPlayer.h"

// Plays a graphic composition on a timer at up to maxFPS (60 by default),
// stopping after its duration.
@implementation HSGraphicCompositionPlayer
- (void)playNewFrame
{
    [_delegate graphicCompositionPlayerDidPlayNewFrame:self];
}
- (void)setPlayTime:(double)aTime
{
    if (_playTime == aTime)
        return;
    _playTime = aTime;
    if (_timer) {
        _startTime = [NSDate timeIntervalSinceReferenceDate] - _playTime;
        [self HSGraphicComposition_play];
    }
}
- (double)playTime
{
    return _playTime;
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
    _timer = [self HSGraphicComposition_createAndScheduleTimerWithTimeInterval:[self HSGraphicComposition_timeInterval]];
    if (!_timer)
        return NO;
    _startTime = [NSDate timeIntervalSinceReferenceDate];
    _playTime = 0.0;
    return YES;
}
// The delegate is not retained.
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
    if (_timer) {
        double current = [_timer timeInterval];
        double interval = [self HSGraphicComposition_timeInterval];
        if (interval < current - 5e-07 || current + 5e-07 < interval) {
            [_timer invalidate];
            [_timer release];
            _timer = [self HSGraphicComposition_createAndScheduleTimerWithTimeInterval:interval];
        }
    }
}
- (double)maxFPS
{
    return _maxFPS;
}
- (void)setDuration:(double)aDuration
{
    if (_duration == aDuration)
        return;
    _duration = aDuration;
    if (_timer && aDuration <= _playTime)
        [self HSGraphicComposition_finish];
}
- (double)duration
{
    return _duration;
}
- (void)setGraphicComposition:(id)aComposition
{
    if (_graphicComposition != aComposition) {
        [aComposition retain];
        [_graphicComposition release];
        _graphicComposition = aComposition;
    }
}
- (id)graphicComposition
{
    return _graphicComposition;
}
- (void)dealloc
{
    [_timer invalidate];
    [_timer release];
    [_graphicComposition release];
    [super dealloc];
}
- (void)HSGraphicComposition_play
{
    double time = [NSDate timeIntervalSinceReferenceDate] - _startTime;
    double previous = _playTime;
    if (_duration <= time)
        time = _duration;
    BOOL isNewFrame = [_graphicComposition isNewFrameAtTime:time relativeToTime:previous];
    _playTime = time;
    if (isNewFrame)
        [self playNewFrame];
    if (time == _duration)
        [self HSGraphicComposition_finish];
}
- (void)HSGraphicComposition_finish
{
    [_timer invalidate];
    [_timer release];
    _timer = nil;
    [_delegate graphicCompositionPlayerDidFinish:self];
}
- (id)HSGraphicComposition_createAndScheduleTimerWithTimeInterval:(double)aInterval
{
    return [[NSThread hyperScheduledThreadTimerWithInterval:aInterval mainThreadTarget:self selector:@selector(HSGraphicComposition_play) repeats:YES] retain];
}
- (double)HSGraphicComposition_timeInterval
{
    double fps = (_maxFPS <= 60.0 && _maxFPS != 0.0) ? _maxFPS : 60.0;
    return MIN(1.0 / fps, _duration);
}
@end

@implementation NSObject (HSGraphicCompositionPlayerDelegate)
- (void)graphicCompositionPlayerDidFinish:(id)aFinish
{
}
- (void)graphicCompositionPlayerDidPlayNewFrame:(id)aFrame
{
}
@end
