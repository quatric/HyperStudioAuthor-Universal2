#import "NSEvent+BTLocation.h"

// The pointing device (pen, eraser, cursor) of the latest pointing event,
// and each tablet's device in proximity. The original ran a listen-only
// CGEventTap on a thread, queued copies of the events and replayed them on
// the main thread up to the current event's timestamp (event taps need the
// Input Monitoring permission now). Local and global NSEvent monitors see the
// same events in order, on the main thread, before they are dispatched.

static NSPointingDeviceType effectiveDeviceType;
static CFMutableDictionaryRef deviceTypes; // deviceID -> NSPointingDeviceType
static id localMonitor, globalMonitor;

static const NSEventMask kPointingEventMask =
    NSEventMaskLeftMouseDown | NSEventMaskLeftMouseUp | NSEventMaskRightMouseDown | NSEventMaskRightMouseUp |
    NSEventMaskMouseMoved | NSEventMaskLeftMouseDragged | NSEventMaskRightMouseDragged | NSEventMaskScrollWheel |
    NSEventMaskTabletPoint | NSEventMaskTabletProximity | NSEventMaskOtherMouseDown | NSEventMaskOtherMouseUp |
    NSEventMaskOtherMouseDragged;

static void noteProximity(NSEvent *event)
{
    effectiveDeviceType = [event pointingDeviceType];
    if ([event isEnteringProximity]) {
        if (!deviceTypes) {
            deviceTypes = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
            if (!deviceTypes)
                return;
        }
        if (effectiveDeviceType) {
            CFDictionarySetValue(deviceTypes, (const void *)[event deviceID], (const void *)effectiveDeviceType);
            return;
        }
    } else if (!deviceTypes)
        return;
    CFDictionaryRemoveValue(deviceTypes, (const void *)[event deviceID]);
}

static void noteTabletPoint(NSEvent *event)
{
    if (deviceTypes)
        effectiveDeviceType = (NSPointingDeviceType)CFDictionaryGetValue(deviceTypes, (const void *)[event deviceID]);
    else
        effectiveDeviceType = NSPointingDeviceTypeUnknown;
}

static void notePointingEvent(NSEvent *event)
{
    switch ([event type]) {
    case NSEventTypeTabletProximity:
        noteProximity(event);
        return;
    case NSEventTypeTabletPoint:
        noteTabletPoint(event);
        return;
    case NSEventTypeLeftMouseDown:
    case NSEventTypeLeftMouseUp:
    case NSEventTypeRightMouseDown:
    case NSEventTypeRightMouseUp:
    case NSEventTypeMouseMoved:
    case NSEventTypeLeftMouseDragged:
    case NSEventTypeRightMouseDragged:
    case NSEventTypeScrollWheel:
    case NSEventTypeOtherMouseDown:
    case NSEventTypeOtherMouseUp:
    case NSEventTypeOtherMouseDragged:
        if ([event subtype] == NSEventSubtypeTabletPoint) {
            noteTabletPoint(event);
            return;
        }
        if ([event subtype] == NSEventSubtypeTabletProximity) {
            noteProximity(event);
            return;
        }
        break;
    default:
        break;
    }
    effectiveDeviceType = NSPointingDeviceTypeUnknown;
}

__attribute__((constructor)) static void installAtLaunch(void)
{
    @autoreleasepool {
        if ([[[[NSProcessInfo processInfo] environment] objectForKey:@"BTEffectivePointingDeviceTypeDisabled"]
                isEqualToString:@"YES"])
            return;
        if ([NSApp isRunning])
            [NSEvent NSEvent_BTLocation_installPointingEventTap:nil];
        else
            [[NSNotificationCenter defaultCenter] addObserver:[NSEvent class]
                                                     selector:@selector(NSEvent_BTLocation_installPointingEventTap:)
                                                         name:NSApplicationDidFinishLaunchingNotification
                                                       object:nil];
    }
}

@implementation NSEvent (BTLocation)

+ (NSUInteger)NSEvent_BTLocation_effectivePointingDeviceType
{
    return effectiveDeviceType;
}

// The original's tap thread; the monitors need none.
+ (void)NSEvent_BTLocation_pointingEventTapThread
{
}

+ (void)NSEvent_BTLocation_installPointingEventTap:(id)aTap
{
    if (localMonitor)
        return;
    if (aTap)
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    localMonitor = [[NSEvent addLocalMonitorForEventsMatchingMask:kPointingEventMask handler:^NSEvent *(NSEvent *event) {
        notePointingEvent(event);
        return event;
    }] retain];
    globalMonitor = [[NSEvent addGlobalMonitorForEventsMatchingMask:kPointingEventMask handler:^(NSEvent *event) {
        notePointingEvent(event);
    }] retain];
}

- (BOOL)BT_hasLocation
{
    NSEventType type = [self type];
    return type < 32 && (0xfc203feU >> type & 1);
}

- (NSUInteger)BT_pointingDeviceType
{
    NSEventType type = [self type];
    if (type == NSEventTypeTabletProximity)
        return [self pointingDeviceType];
    if (type < 32 && (0xe4000feU >> type & 1)) {
        short subtype = [self subtype];
        if (subtype == NSEventSubtypeTabletProximity)
            return [self pointingDeviceType];
        if (subtype != NSEventSubtypeTabletPoint)
            return NSPointingDeviceTypeUnknown;
    } else if (type != NSEventTypeTabletPoint)
        return [self pointingDeviceType];
    if (!deviceTypes)
        return NSPointingDeviceTypeUnknown;
    return (NSUInteger)CFDictionaryGetValue(deviceTypes, (const void *)[self deviceID]);
}

- (BOOL)BT_isPointingEvent
{
    NSEventType type = [self type];
    return type < 32 && (0xfc000feU >> type & 1);
}

@end
