#import "HSTimerBasedTrackingController.h"

// A continuous change lasts while new values keep coming, ending half a
// second after the last.

@implementation HSTimerBasedTrackingController

- (void)idleTime:(id)aTime
{
    [[[self dataInterface] attributeObservingController] endContinuousChangeOfAttribute:[self attribute]];
    [_idleTimer release];
    _idleTimer = nil;
}

- (void)didSetNewValue:(id)aValue
{
}

- (void)willSetNewValue:(id)aValue
{
    id controller = [[self dataInterface] attributeObservingController];
    if (![[controller attributesBeingChangedContinuously] containsProtocol:[self attribute]])
        [controller beginContinuousChangeOfAttribute:[self attribute]];
    if (_idleTimer == nil) {
        _idleTimer = [[NSTimer timerWithTimeInterval:0.5 target:[[self NSE_newWeakProxy] autorelease] selector:@selector(idleTime:) userInfo:nil repeats:NO] retain];
        [[NSRunLoop currentRunLoop] addTimer:_idleTimer forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] addTimer:_idleTimer forMode:NSEventTrackingRunLoopMode];
    } else
        [_idleTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
}

- (void)dealloc
{
    [_idleTimer invalidate];
    [_idleTimer release];
    [super dealloc];
}

@end
