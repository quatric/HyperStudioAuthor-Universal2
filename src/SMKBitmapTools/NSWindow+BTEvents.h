#import "SMKBitmapToolsPrefix.h"


@interface NSWindow (BTEvents)
- (id)BT_mouseMovedEvent;
- (NSUInteger)BT_effectivePointingDeviceType;
- (NSUInteger)BT_effectivePointingDeviceTypeWithEvent:(id)aEvent;
- (NSUInteger)BT_effectiveModifierFlags;
- (NSUInteger)BT_effectiveModifierFlagsWithEvent:(id)aEvent;
- (id)BT_nearestModifierFlagsEvent;
- (NSPoint)BT_effectiveMouseLocation;
- (NSPoint)BT_effectiveMouseLocationWithEvent:(id)aEvent;
- (id)BT_nearestLocationEvent;
@end

