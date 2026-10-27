#import "HSAnimationPlaybackTimer.h"

// One timer (30 fps for the shared one) that tells the animations it
// holds to proceed; it runs only while there are animations.

@implementation HSAnimationPlaybackTimer

+ (id)sharedController
{
    static HSAnimationPlaybackTimer *animationController;
    if (animationController == nil)
        animationController = [[self alloc] initWithRate:[self defaultTimesPerSecond]];
    return animationController;
}

+ (NSInteger)defaultTimesPerSecond
{
    return 30;
}

- (id)initWithRate:(NSInteger)aRate
{
    if ((self = [super init])) {
        _timesPerSecond = (int)aRate;
        _entries = [NSMutableSet new];
        _finishedEntries = [NSMutableSet new];
    }
    return self;
}

- (NSInteger)timesPerSecond
{
    return _timesPerSecond;
}

- (void)dealloc
{
    if (_playbackTimer != nil) {
        [_playbackTimer invalidate];
        [_playbackTimer release];
    }
    [_finishedEntries release];
    [_entries release];
    [super dealloc];
}

- (void)addAnimation:(id)aAnimation
{
    [self startTimerIfNecessary];
    [_entries addObject:aAnimation];
    [_finishedEntries removeObject:aAnimation];
}

- (void)removeAnimation:(id)aAnimation
{
    [_entries removeObject:aAnimation];
}

- (void)animationDidFinish:(id)aAnimation
{
    [_finishedEntries addObject:aAnimation];
}

- (BOOL)hasAnimation:(id)aAnimation
{
    return [_entries containsObject:aAnimation];
}

// Proceeds one animation right away.
- (void)touchAnimation:(id)aAnimation
{
    [self retain];
    [aAnimation proceedAnimationOnTimer];
    [self removeFinishedAnimations];
    [self release];
}

- (double)timerPeriod
{
    return 1.0 / (double)_timesPerSecond;
}

- (void)startTimerIfNecessary
{
    if (_playbackTimer == nil)
        _playbackTimer = [[NSThread hyperScheduledThreadTimerWithInterval:[self timerPeriod] mainThreadTarget:self selector:@selector(HSAnimationPlaybackTimer_timerFired:) repeats:YES] retain];
}

- (void)stopTimer
{
    [_playbackTimer invalidate];
    [_playbackTimer release];
    _playbackTimer = nil;
}

// A copy of the animations, since they may remove themselves.
- (void)HSAnimationPlaybackTimer_timerFired:(id)aFired
{
    [self retain];
    NSSet *entries = [_entries copy];
    [entries makeObjectsPerformSelector:@selector(proceedAnimationOnTimer)];
    [entries release];
    [self removeFinishedAnimations];
    [self release];
}

- (void)removeFinishedAnimations
{
    [_entries minusSet:_finishedEntries];
    [_finishedEntries removeAllObjects];
    if ([_entries count] == 0)
        [self stopTimer];
}

@end
