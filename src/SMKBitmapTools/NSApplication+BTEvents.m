#import "NSApplication+BTEvents.h"
#import "NSEvent+BTLocation.h"

// Pointing events with location or modifier flags, current or still queued.
static const NSEventMask kModifierFlagsEventMask = 0xfc31ffe;

@implementation NSApplication (BTEvents)

- (NSUInteger)BT_effectivePointingDeviceType
{
    return [NSEvent NSEvent_BTLocation_effectivePointingDeviceType];
}

- (NSUInteger)BT_effectivePointingDeviceTypeWithEvent:(id)aEvent
{
    if ([aEvent BT_isPointingEvent])
        return [aEvent BT_pointingDeviceType];
    return [NSEvent NSEvent_BTLocation_effectivePointingDeviceType];
}

- (NSUInteger)BT_effectiveModifierFlags
{
    return [self BT_effectiveModifierFlagsWithEvent:nil];
}

- (NSUInteger)BT_effectiveModifierFlagsWithEvent:(id)aEvent
{
    id event = aEvent;
    if (![event NSE_hasModifierFlags])
        event = [self BT_nearestModifierFlagsEvent];
    if (!event)
        return [NSEvent modifierFlags];
    return [event modifierFlags];
}

- (id)BT_nearestModifierFlagsEvent
{
    NSEvent *event = [self currentEvent];
    if (![event NSE_hasModifierFlags])
        event = [self nextEventMatchingMask:kModifierFlagsEventMask untilDate:nil
                                     inMode:@"BTEventQueueParsingRunLoopMode" dequeue:NO];
    return event;
}

@end
