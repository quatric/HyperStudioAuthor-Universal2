#import "SMKBitmapToolsPrefix.h"


@interface NSView (BTMouseTracking)
+ (id)BT_mouseTrackingView;
- (void)BT_abortMouseTracking;
- (id)BT_trackMouseWithEvent:(id)aEvent tracker:(id)aTracker startDelay:(double)aDelay;
- (id)BT_trackMouseWithEvent:(id)aEvent tracker:(id)aTracker;
@end

