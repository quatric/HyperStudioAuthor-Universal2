#import "HyperPlayerBasePrefix.h"
#import "HSViewEmbeddingCanvasItem.h"


@interface HSInteractiveViewItem : HSViewEmbeddingCanvasItem <HSInteractivePlayerItem, HSCanvasItem, HyperInterface, NSObject, HSInteractivePlayerItemActivation, HSCanvasItemActivation>
{
    id<HSNodeAttributes> _node;
    id<HSInteractiveCanvasContext> _activeItemContext;
    BOOL _isHandlingMouseEvent;
}
- (void)geometryWillChange:(id)aChange;
- (void)setHandlingMouseEvent:(BOOL)aEvent;
- (BOOL)isHandlingMouseEvent;
- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inCanvasLayer:(id)aLayer;
- (BOOL)hitTestPoint:(NSPoint)aPoint inCanvasLayer:(id)aLayer;
- (void)nodeVisibilityDidChange:(id)aChange;
- (BOOL)trackMouseWithScrollWheelEvent:(id)aEvent inInteractiveContext:(id)aContext;
- (BOOL)wantsToTrackMouseWithScrollWheelEvent:(id)aEvent inInteractiveContext:(id)aContext;
- (void)awakeInPlayer;
- (BOOL)wantsToInterceptSendingClickActionsInInteractiveContext:(id)aContext;
- (BOOL)sendingActionsIsDisabled;
- (void)trackMouseWithMouseUpEvent:(id)aEvent inInteractiveContext:(id)aContext;
- (BOOL)wantsToTrackMouseWithMouseUpEvent:(id)aEvent inInteractiveContext:(id)aContext;
- (void)trackMouseWithMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext;
- (BOOL)hasExecutableActionsForMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext;
- (BOOL)wantsToPassThroughMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext;
- (BOOL)wantsToTrackMouseWithMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext;
- (id)activeItemContext;
- (BOOL)objectCanBeActivated;
- (void)invalidateParentCanvasLayer;
- (void)deactivate;
- (void)activateInCanvasLayer:(id)aLayer;
- (void)setupViewFrameInCanvasLayer:(id)aLayer;
- (void)invalidateView;
- (id)createView;
- (BOOL)wantsToActivateImplicitlyInInteractiveContext:(id)aContext;
- (BOOL)wantsToActivateWithMouseInInteractiveContext:(id)aContext;
- (id)node;
- (id)implementationForHyperObject:(id)aObject;
- (id)hyperObject;
- (void)dealloc;
- (id)initWithNode:(id)aNode;
@end

