#import "SMKBitmapToolsPrefix.h"


@interface NSEvent (BTLocation)
+ (NSUInteger)NSEvent_BTLocation_effectivePointingDeviceType;
+ (void)NSEvent_BTLocation_pointingEventTapThread;
+ (void)NSEvent_BTLocation_installPointingEventTap:(id)aTap;
- (BOOL)BT_hasLocation;
- (NSUInteger)BT_pointingDeviceType;
- (BOOL)BT_isPointingEvent;
@end

