#import "HyperPlayerBasePrefix.h"
#import "HSAbstractCompositeCanvasLayer.h"


@interface HSCanvasRootLayerImplementationData : NSObject
{
    // HSCanvasRootLayerMixin reads and sets the flags directly.
@public
    id<HSCanvasLayerContext> _context;
    id _representedObject;
    id<HSCanvasSublayer> _activeLayer;
    HSCanvasActionRegistry *_canvasActionRegistry;
    unsigned int _pendingSublayerTreeNotificationsCount;
    unsigned int _sublayerTreeNotificationsDelayCount;
    struct flags flags;
}
- (void)removeAllPendingSublayerTreeNotifications;
- (void)addPendingSublayerTreeNotification;
- (BOOL)hasPendingSublayerTreeNotifications;
- (void)decrementSublayerTreeNotificationsDelayCount;
- (void)incrementSublayerTreeNotificationsDelayCount;
- (BOOL)areSublayerTreeNotificationsDelayed;
- (void)setCanvasActionRegistry:(id)aRegistry;
- (id)canvasActionRegistry;
- (void)setActiveLayer:(id)aLayer;
- (id)activeLayer;
- (void)setRepresentedObject:(id)aObject;
- (id)representedObject;
- (void)setContext:(id)aContext;
- (id)context;
- (void)dealloc;
@end

@interface HSCanvasRootLayerMixin : HSAbstractCompositeCanvasLayer
{
    id _rootLayerImplementationData;
    id<HSCanvasLayer> _gestureLayer;
}
+ (BOOL)instancesRespondToSelector:(SEL)aSelector;
- (void)performActionSelector:(SEL)aSelector withSender:(id)aSender;
- (BOOL)validateActionSelector:(SEL)aSelector withUserInterfaceItem:(id)aItem;
- (BOOL)respondsToActionSelector:(SEL)aSelector;
- (void)registerSupportedActionSelector:(SEL)aSelector;
- (BOOL)handleTouchesCancelled:(id)aCancelled;
- (BOOL)handleTouchesEnded:(id)aEnded;
- (BOOL)handleTouchesMoved:(id)aMoved;
- (BOOL)handleTouchesBegan:(id)aBegan;
- (BOOL)handleSwipeGesture:(id)aGesture;
- (BOOL)handleRotationGesture:(id)aGesture;
- (BOOL)handleMagnificationGesture:(id)aGesture;
- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags event:(id)aEvent;
- (BOOL)handleKeyEventSelector:(SEL)aSelector;
- (BOOL)handleRawKeyUpEvent:(id)aEvent;
- (BOOL)handleRawKeyDownEvent:(id)aEvent;
- (BOOL)handleKeyEquivalent:(id)aEquivalent;
- (BOOL)handleFlagsChanged:(id)aChanged;
- (BOOL)handleScrollWheel:(id)aWheel;
- (void)handleMouseMoved:(id)aMoved;
- (BOOL)handleMouseUp:(id)aUp;
- (BOOL)handleMouseDown:(id)aDown;
- (void)endSublayerTreeChanging;
- (void)beginSublayerTreeChanging;
- (void)sublayerTreeDidChange;
- (id)activeLayer;
- (void)setActiveLayer:(id)aLayer;
- (void)setRunningDisabled:(BOOL)aDisabled;
- (void)setRepresentedObject:(id)aObject;
- (void)setContext:(id)aContext;
- (id)rootLayer;
- (void)setParentLayer:(id)aLayer;
- (id)parentLayer;
- (void)representedObjectDidChange;
- (void)representedObjectWillChange;
- (void)contextDidChange;
- (void)contextWillChange;
- (BOOL)isRunningInWindow;
- (BOOL)isRunning;
- (id)representedObject;
- (id)context;
- (BOOL)handleRootLayerKeyEventSelector:(SEL)aSelector;
- (BOOL)handleKeyEventSelector:(SEL)aSelector andTraverseCanvasLayer:(id)aLayer isRootLayer:(BOOL)aLayer2;
- (BOOL)handleKeyEventSelector:(SEL)aSelector inCanvasLayer:(id)aLayer;
- (BOOL)handleRootLayerEventInvocation:(id)aInvocation;
- (BOOL)handleEventInvocation:(id)aInvocation andTraverseCanvasLayer:(id)aLayer isRootLayer:(BOOL)aLayer2;
- (BOOL)handleEventInvocation:(id)aInvocation inCanvasLayer:(id)aLayer;
- (BOOL)respondsToSelector:(SEL)aSelector;
- (BOOL)canvasActionRegistry:(id)aRegistry isAvailableActionSelector:(SEL)aSelector;
- (id)targetLayerForActionSelector:(SEL)aSelector;
- (id)canvasActionRegistry;
- (id)canvasActionRegistryCreateIfNeeded:(BOOL)aNeeded;
- (id)targetLayerForActionSelector:(SEL)aSelector inCompositeLayer:(id)aLayer;
- (void)stopObservingRenderingViewNotifications;
- (void)observeRenderingViewNotifications;
- (void)rootLayerViewDidChangeUserSpaceToViewSpaceTransform:(id)aTransform;
- (void)setRootLayerRunningDisabled:(BOOL)aDisabled;
- (void)rootLayerViewDidMountIntoWindow:(id)aWindow;
- (void)rootLayerViewWillUnmountFromWindow:(id)aWindow;
- (void)setRootLayerRunningInWindow:(BOOL)aWindow;
- (BOOL)isRootLayerRunningInWindow;
- (void)activateRootLayerIfNeeded;
- (void)setRootLayerActive:(BOOL)aActive;
- (void)rootLayerNotifyWillStopRunningInWindow;
- (void)rootLayerNotifyWillStopRunning;
- (void)rootLayerNotifyDidStartRunningInWindow;
- (void)rootLayerNotifyDidStartRunning;
- (void)setRootLayerObservesViewMountNotifications:(BOOL)aNotifications;
- (BOOL)isRootLayerActive;
- (void)dealloc;
- (id)init;
@end

