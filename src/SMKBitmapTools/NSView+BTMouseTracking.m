#import "NSView+BTMouseTracking.h"

// The view tracking the mouse; aborting clears it and ends the loop.
static NSView *trackingView;

@implementation NSView (BTMouseTracking)

+ (id)BT_mouseTrackingView
{
    return trackingView;
}

- (void)BT_abortMouseTracking
{
    trackingView = nil;
}

// Runs the mouse-down tracking loop of aTracker (trackMouseDown:inView:,
// trackMouseDragged:inView:, trackFlagsChanged:inView:, trackMouseUp:inView:,
// or haltWithMouseUp:inView: when the button goes up before tracking
// started). Tracking starts after aDelay, or as soon as the mouse moves or a
// modifier changes. Queued drags are coalesced into the latest one. While a
// drag autoscrolls (if the tracker agrees), periodic events keep scrolling.
// Returns the mouse-up event.
- (id)BT_trackMouseWithEvent:(id)aEvent tracker:(id<BTMouseTracker>)aTracker startDelay:(double)aDelay
{
    NSEvent *mouseUp = nil;
    BOOL started = NO;
    NSWindow *window = [self window];
    NSEvent *autoscrollEvent = nil;
    @try {
        trackingView = self;
        if (aDelay == 0) {
            started = YES;
            [aTracker trackMouseDown:aEvent inView:self];
        } else
            [NSEvent startPeriodicEventsAfterDelay:aDelay withPeriod:DBL_MAX];
        while (trackingView) {
            NSAutoreleasePool *pool = [NSAutoreleasePool new];
            NSEvent *event = [window nextEventMatchingMask:NSEventMaskAny];
            if ([event type] == NSEventTypeLeftMouseDragged) {
                // Skip to the last queued drag, discarding events in between,
                // up to a mouse up, a flags change or a periodic event.
                NSEvent *next = [window nextEventMatchingMask:NSEventMaskAny untilDate:nil
                                                       inMode:@"BTEventQueueParsingRunLoopMode" dequeue:NO];
                while (next) {
                    NSEventType type = [next type];
                    if (type == NSEventTypeLeftMouseUp || type == NSEventTypeFlagsChanged ||
                        type == NSEventTypePeriodic)
                        break;
                    if (type == NSEventTypeLeftMouseDragged)
                        event = next;
                    [window nextEventMatchingMask:NSEventMaskAny untilDate:nil
                                           inMode:@"BTEventQueueParsingRunLoopMode" dequeue:YES];
                    next = [window nextEventMatchingMask:NSEventMaskAny untilDate:nil
                                                  inMode:@"BTEventQueueParsingRunLoopMode" dequeue:NO];
                }
            }
            switch ([event type]) {
            case NSEventTypeLeftMouseUp:
                if (started)
                    [aTracker trackMouseUp:event inView:self];
                else {
                    [NSEvent stopPeriodicEvents];
                    [aTracker haltWithMouseUp:event inView:self];
                }
                if (trackingView) {
                    mouseUp = [event retain];
                    trackingView = nil;
                }
                break;
            case NSEventTypePeriodic:
                if (!started) {
                    [NSEvent stopPeriodicEvents];
                    started = YES;
                    [aTracker trackMouseDown:aEvent inView:self];
                } else if (autoscrollEvent) {
                    BOOL scrolled = [self autoscroll:autoscrollEvent];
                    [aTracker trackingView:self didAutoscroll:scrolled withMouseEvent:autoscrollEvent];
                    if (!trackingView)
                        break;
                    if (scrolled)
                        [aTracker trackMouseDragged:autoscrollEvent inView:self];
                    else {
                        [autoscrollEvent release];
                        autoscrollEvent = nil;
                        [NSEvent stopPeriodicEvents];
                    }
                }
                break;
            case NSEventTypeFlagsChanged:
                if (!started) {
                    [NSEvent stopPeriodicEvents];
                    started = YES;
                    [aTracker trackMouseDown:aEvent inView:self];
                }
                [aTracker trackFlagsChanged:event inView:self];
                break;
            case NSEventTypeLeftMouseDragged: {
                if (!started) {
                    [NSEvent stopPeriodicEvents];
                    started = YES;
                    [aTracker trackMouseDown:aEvent inView:self];
                } else if (autoscrollEvent) {
                    [autoscrollEvent release];
                    autoscrollEvent = nil;
                    [NSEvent stopPeriodicEvents];
                }
                BOOL autoscrolls = YES;
                if (aTracker) {
                    autoscrolls = [aTracker trackingView:self shouldAutoscrollWithMouseEvent:event];
                    if (!trackingView)
                        break;
                }
                if (autoscrolls) {
                    autoscrollEvent = [event retain];
                    [NSEvent startPeriodicEventsAfterDelay:0.1 withPeriod:0.1];
                    BOOL scrolled = [self autoscroll:event];
                    [aTracker trackingView:self didAutoscroll:scrolled withMouseEvent:event];
                    if (!trackingView)
                        break;
                }
                [aTracker trackMouseDragged:event inView:self];
                break;
            }
            default:
                break;
            }
            [pool release];
        }
        if (autoscrollEvent) {
            [autoscrollEvent release];
            [NSEvent stopPeriodicEvents];
        }
    } @catch (id exception) {
        NSLog(@"Exception was raised while tracking mouse. Tracking is aborted.");
        NSLog(@"(%@)", exception);
        [mouseUp release];
        trackingView = nil;
        @throw;
    }
    return [mouseUp autorelease];
}

- (id)BT_trackMouseWithEvent:(id)aEvent tracker:(id<BTMouseTracker>)aTracker
{
    return [self BT_trackMouseWithEvent:aEvent tracker:aTracker startDelay:0.3];
}

@end
