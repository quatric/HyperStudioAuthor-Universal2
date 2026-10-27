#import "HyperPlayerBasePrefix.h"
#import "HSInteractiveViewItem.h"


@interface HSInteractiveYouTubeObject : HSInteractiveViewItem
{
    NSRect _originalViewFrame;
    HSOverlayView *_overlayView;
}
- (void)overlayViewDidDraw:(id)aDraw;
- (id)youTubeInteractiveAttribute;
- (void)trackMouseWithMouseUpEvent:(id)aEvent inInteractiveContext:(id)aContext;
- (BOOL)wantsToTrackMouseWithMouseUpEvent:(id)aEvent inInteractiveContext:(id)aContext;
- (void)trackMouseWithMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext;
- (BOOL)wantsToTrackMouseWithMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext;
- (BOOL)wantsToPassThroughMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext;
- (void)removeViewFromSuperview;
- (void)deactivate;
- (void)activateInCanvasLayer:(id)aLayer;
- (void)invalidateView;
- (void)setupViewFrameInCanvasLayer:(id)aLayer;
- (void)setupView:(id)aView;
- (id)createView;
- (BOOL)objectCanBeActivated;
- (void)dealloc;
@end

