#import "HyperPlayerBasePrefix.h"
#import "HSInteractiveViewItem.h"


@interface HSInteractiveWebObject : HSInteractiveViewItem
{
    id<HSWebElementAttributes> _webElementAttributes;
    HSOverlayView *_overlayView;
}
- (void)overlayViewDidDraw:(id)aDraw;
- (void)trackMouseWithMouseUpEvent:(id)aEvent inInteractiveContext:(id)aContext;
- (BOOL)wantsToTrackMouseWithMouseUpEvent:(id)aEvent inInteractiveContext:(id)aContext;
- (void)trackMouseWithMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext;
- (BOOL)wantsToTrackMouseWithMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext;
- (BOOL)wantsToPassThroughMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext;
- (void)deactivate;
- (void)activateInCanvasLayer:(id)aLayer;
- (void)setupViewFrameInCanvasLayer:(id)aLayer;
- (void)invalidateView;
- (id)createView;
- (BOOL)objectCanBeActivated;
- (void)dealloc;
@end

