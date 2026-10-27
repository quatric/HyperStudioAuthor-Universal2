#import "HSEventBasedTrackingController.h"

@implementation HSEventBasedTrackingController

// A continuous change ends with the mouse up that ends the tracking.
- (void)didSetNewValue:(id)aValue
{
    if (!_isTracking)
        return;
    NSEvent *current = [NSApp currentEvent];
    NSEvent *next = [NSApp nextEventMatchingMask:NSEventMaskLeftMouseUp untilDate:[NSDate dateWithTimeIntervalSinceNow:0.3]
                                          inMode:NSEventTrackingRunLoopMode dequeue:NO];
    if ([current type] != NSEventTypeLeftMouseUp && [next type] != NSEventTypeLeftMouseUp)
        return;
    [[[self dataInterface] attributeObservingController] endContinuousChangeOfAttribute:[self attribute]];
    _isTracking = NO;
}

// A change made with the mouse down (and not released at once) begins a
// continuous change.
- (void)willSetNewValue:(id)aValue
{
    if (_isTracking)
        return;
    NSEvent *current = [NSApp currentEvent];
    NSEvent *next = [NSApp nextEventMatchingMask:NSEventMaskLeftMouseDown | NSEventMaskLeftMouseUp untilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]
                                          inMode:NSEventTrackingRunLoopMode dequeue:NO];
    if (!(([current type] == NSEventTypeLeftMouseDown && [next type] != NSEventTypeLeftMouseUp) || [next type] == NSEventTypeLeftMouseDown))
        return;
    [[[self dataInterface] attributeObservingController] beginContinuousChangeOfAttribute:[self attribute]];
    _isTracking = YES;
}

@end
