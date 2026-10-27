#import "SMKBitmapToolsPrefix.h"


@interface NSApplication (BTEvents)
- (NSUInteger)BT_effectivePointingDeviceType;
- (NSUInteger)BT_effectivePointingDeviceTypeWithEvent:(id)aEvent;
- (NSUInteger)BT_effectiveModifierFlags;
- (NSUInteger)BT_effectiveModifierFlagsWithEvent:(id)aEvent;
- (id)BT_nearestModifierFlagsEvent;
@end

