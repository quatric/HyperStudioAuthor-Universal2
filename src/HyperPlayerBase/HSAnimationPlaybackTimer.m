#import "HSAnimationPlaybackTimer.h"
// One timer (30 fps for the shared one) that tells its delegates
// playbackTimerDidFired:; it runs only while there are delegates.
@implementation HSAnimationPlaybackTimer
static HSAnimationPlaybackTimer *sSharedPlaybackTimer;
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
// Fires for one delegate right away.
- (void)dealloc
{
    [self stopTimer];
    [_delegates release];
    [super dealloc];
}
@end
