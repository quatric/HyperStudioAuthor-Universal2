#import "HyperPlayerBasePrefix.h"
#import "HSInteractiveCanvasItem.h"


@interface HSInteractiveGraphicObject : HSInteractiveCanvasItem
{
}
- (void)trackMouseWithMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext;
- (BOOL)sendingActionsIsDisabled;
- (BOOL)wantsToTrackMouseWithMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext;
- (BOOL)isImageHidden;
@end

