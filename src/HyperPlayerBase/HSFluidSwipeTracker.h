#import "HyperPlayerBasePrefix.h"


@interface HSFluidSwipeTracker : NSResponder
{
    BOOL *_stopper;
}
- (BOOL)wantsScrollEventsForSwipeTrackingOnAxis:(int)aAxis;
- (void)scrollWheel:(NSEvent *)aEvent;
@end
