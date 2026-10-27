#import "NSWindow+BTEvents.h"
#import "NSApplication+BTEvents.h"
#import "NSEvent+BTLocation.h"

// Events with a location, current or still queued.
static const NSEventMask kLocationEventMask = 0xfc203fe;

@implementation NSWindow (BTEvents)

// A mouse-moved event at the effective mouse location.
- (id)BT_mouseMovedEvent
{
    NSPoint location;
    NSEvent *event = [self BT_nearestLocationEvent];
    if (!event)
        location = [self mouseLocationOutsideOfEventStream];
    else {
        NSWindow *window = [event window];
        location = [event locationInWindow];
        if (window != self) {
            if (window)
                location = [window convertPointToScreen:location];
            location = [self convertPointFromScreen:location];
        }
    }
    NSEvent *current = [self currentEvent];
    NSTimeInterval timestamp = current ? [current timestamp] : 0;
    return [NSEvent mouseEventWithType:NSEventTypeMouseMoved location:location
                         modifierFlags:[self BT_effectiveModifierFlags] timestamp:timestamp
                          windowNumber:[self windowNumber] context:nil eventNumber:0 clickCount:0 pressure:0];
}

- (NSUInteger)BT_effectivePointingDeviceType
{
    return [NSApp BT_effectivePointingDeviceType];
}

- (NSUInteger)BT_effectivePointingDeviceTypeWithEvent:(id)aEvent
{
    return [NSApp BT_effectivePointingDeviceTypeWithEvent:aEvent];
}

- (NSUInteger)BT_effectiveModifierFlags
{
    return [NSApp BT_effectiveModifierFlags];
}

- (NSUInteger)BT_effectiveModifierFlagsWithEvent:(id)aEvent
{
    return [NSApp BT_effectiveModifierFlagsWithEvent:aEvent];
}

- (id)BT_nearestModifierFlagsEvent
{
    return [NSApp BT_nearestModifierFlagsEvent];
}

- (NSPoint)BT_effectiveMouseLocation
{
    return [self BT_effectiveMouseLocationWithEvent:nil];
}

- (NSPoint)BT_effectiveMouseLocationWithEvent:(id)aEvent
{
    NSEvent *event = aEvent;
    if (![event BT_hasLocation])
        event = [self BT_nearestLocationEvent];
    if (!event)
        return [self mouseLocationOutsideOfEventStream];
    NSWindow *window = [event window];
    NSPoint location = [event locationInWindow];
    if (window == self)
        return location;
    if (window)
        location = [window convertPointToScreen:location];
    return [self convertPointFromScreen:location];
}

- (id)BT_nearestLocationEvent
{
    NSEvent *event = [self currentEvent];
    if (![event BT_hasLocation])
        event = [self nextEventMatchingMask:kLocationEventMask untilDate:nil
                                     inMode:@"BTEventQueueParsingRunLoopMode" dequeue:NO];
    return event;
}

@end
