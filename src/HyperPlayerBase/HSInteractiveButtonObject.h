#import "HyperPlayerBasePrefix.h"
#import "HSInteractiveCanvasItem.h"


@interface HSInteractiveButtonObject : HSInteractiveCanvasItem
{
}
- (void)trackMouseWithMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext;
- (BOOL)sendingActionsIsDisabled;
- (BOOL)wantsToPassThroughMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext;
- (BOOL)wantsToTrackMouseWithMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext;
- (BOOL)buttonIsHidden;
- (BOOL)buttonIsEnabled;
@end

