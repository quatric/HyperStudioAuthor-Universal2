#import "HSAnimationPlaybackTimer.h"
// One timer (30 fps for the shared one) that tells its delegates
// playbackTimerDidFired:; it runs only while there are delegates.
@implementation HSAnimationPlaybackTimer
static HSAnimationPlaybackTimer *sSharedPlaybackTimer;
+ (id)sharedPlaybackTimer
{
    if (sSharedPlaybackTimer == nil)
        sSharedPlaybackTimer = [[self alloc] initWithFireTimesPerSecond:30];
    return sSharedPlaybackTimer;
}
// A copy of the delegates, since they may remove themselves.
- (void)HSAnimationPlaybackTimer_timerFired:(id)aFired
{
    [self retain];
    NSSet *delegates = [_delegates copy];
    [delegates makeObjectsPerformSelector:@selector(playbackTimerDidFired:) withObject:self];
    [delegates release];
    [self stopTimerIfNeeded];
    [self release];
}
- (void)stopTimer
{
    [_playbackTimer invalidate];
    [_playbackTimer release];
    _playbackTimer = nil;
}
- (void)stopTimerIfNeeded
{
    if ([_delegates count] == 0)
        [self stopTimer];
}
- (void)startTimerIfNeeded
{
    if (_playbackTimer == nil)
        _playbackTimer = [[NSThread hyperScheduledThreadTimerWithInterval:[self timeInterval] mainThreadTarget:self selector:@selector(HSAnimationPlaybackTimer_timerFired:) repeats:YES] retain];
}
- (double)timeInterval
{
    return _timeInterval;
}
// Fires for one delegate right away.
- (void)touchDelegate:(id)aDelegate
{
    [self retain];
    [aDelegate playbackTimerDidFired:self];
    [self stopTimerIfNeeded];
    [self release];
}
- (void)removeDelegate:(id)aDelegate
{
    [_delegates removeObject:aDelegate];
}
- (void)addDelegate:(id)aDelegate
{
    [self startTimerIfNeeded];
    [_delegates addObject:aDelegate];
}
- (void)dealloc
{
    [self stopTimer];
    [_delegates release];
    [super dealloc];
}
- (id)initWithFireTimesPerSecond:(NSInteger)aSecond
{
    self = [super init];
    if (self != nil) {
        _timeInterval = 1.0 / (double)aSecond;
        _delegates = [NSMutableSet new];
    }
    return self;
}
@end
