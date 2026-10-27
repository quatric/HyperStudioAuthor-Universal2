#import "HyperStudioPrefix.h"


@interface HSSegmentViewSliderCell : NSSliderCell
{
    id _delegate;
    NSRect _oldFrame;
    BOOL _isTracking;
}
- (void)onSlider:(id)aSlider;
- (void)stopTracking:(NSPoint)aTracking at:(NSPoint)aAt inView:(id)aView mouseIsUp:(BOOL)aUp;
- (BOOL)continueTracking:(NSPoint)aTracking at:(NSPoint)aAt inView:(id)aView;
- (BOOL)startTrackingAt:(NSPoint)aAt inView:(id)aView;
- (void)drawWithFrame:(NSRect)aFrame inView:(id)aView;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (id)init;
@end

