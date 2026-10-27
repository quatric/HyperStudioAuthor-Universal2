#import "HyperPlayerBasePrefix.h"


@interface HSCanvasItemsSublayer : NSObject <HSCanvasSublayer, HSCanvasLayer, NSObject>
{
    id<HSCanvasSuperlayer> _parentLayer;
    id<HSCanvasItem> _activeItem;
    id<HSCanvasItemActivation> _activeItemActivationInterface;
}
- (void)didActivateItem:(id)aItem;
- (void)willDeactivateItem:(id)aItem;
- (void)willResignActiveLayer;
- (void)didBecomeActiveLayer;
- (void)setActiveItem:(id)aItem;
- (void)privateSetActiveItem:(id)aItem;
- (id)activeItem;
- (BOOL)handleTouchesCancelledWithEvent:(id)aEvent hitTestInfo:(id)aInfo;
- (BOOL)handleTouchesEndedWithEvent:(id)aEvent hitTestInfo:(id)aInfo;
- (BOOL)handleTouchesMovedWithEvent:(id)aEvent hitTestInfo:(id)aInfo;
- (BOOL)handleTouchesBeganWithEvent:(id)aEvent hitTestInfo:(id)aInfo;
- (BOOL)handleSwipeGesture:(id)aGesture hitTestInfo:(id)aInfo;
- (BOOL)handleRotationGestureWithEvent:(id)aEvent hitTestInfo:(id)aInfo;
- (BOOL)handleMagnificationGestureWithEvent:(id)aEvent hitTestInfo:(id)aInfo;
- (BOOL)handleScrollWheelAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo;
- (BOOL)handleMouseUpAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo;
- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo;
- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo;
- (id)hitTestNextInteractiveItemAfterItem:(id)aItem atPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo;
- (void)updateCanvasItemIfNeeded:(id)aNeeded;
- (void)updateCanvasItemsIfNeeded;
- (void)invalidateDisplayForCanvasItem:(id)aItem;
- (void)invalidateDisplayForItemsInRange:(NSRange)aRange;
- (BOOL)supportsHitTesting;
- (id)canvasItemAtIndex:(NSUInteger)aIndex;
- (NSUInteger)numberOfCanvasItems;
- (void)representedObjectDidChange;
- (void)representedObjectWillChange;
- (NSUInteger)indexOfCanvasItem:(id)aItem;
- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inHitItem:(id)aItem;
- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags hitTestInfo:(id)aInfo event:(id)aEvent;
- (BOOL)hitTestRect:(NSRect)aRect inItem:(id)aItem;
- (BOOL)hitTestPoint:(NSPoint)aPoint inItem:(id)aItem;
- (id)hitTestItem:(NSPoint)aItem afterItem:(id)aItem2;
- (id)hitTestItem:(NSPoint)aItem;
- (id)hitTestItem:(NSPoint)aItem totalCount:(NSUInteger)aCount;
- (NSRect)boundingRectOccupiedByLayer;
- (void)renderRect:(NSRect)aRect;
- (void)renderItem:(id)aItem invalidRect:(NSRect)aRect isActive:(BOOL)aActive;
- (NSRect)boundingRectForItem:(id)aItem;
- (void)invalidateDisplay;
- (id)renderingView;
- (void)renderingViewTransformDidChange;
- (BOOL)isRunningInWindow;
- (BOOL)isRunning;
- (void)willStopRunningInWindow;
- (void)didStartRunningInWindow;
- (void)willStopRunning;
- (void)didStartRunning;
- (void)contextWillChange;
- (void)contextDidChange;
- (id)representedObject;
- (id)context;
- (id)parentLayer;
- (void)setParentLayer:(id)aLayer;
- (void)dealloc;
@end

