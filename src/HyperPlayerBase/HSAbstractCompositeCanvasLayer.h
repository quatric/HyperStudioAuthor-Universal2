#import "HyperPlayerBasePrefix.h"


@interface HSAbstractCompositeCanvasLayer : NSObject <HSCanvasSuperlayer, HSCanvasLayer, NSObject, HSCanvasSublayer>
{
    id<HSCanvasSuperlayer> _parentLayer;
}
- (BOOL)handleTouchesCancelledWithEvent:(id)aEvent hitTestInfo:(id)aInfo;
- (BOOL)handleTouchesEndedWithEvent:(id)aEvent hitTestInfo:(id)aInfo;
- (BOOL)handleTouchesMovedWithEvent:(id)aEvent hitTestInfo:(id)aInfo;
- (BOOL)handleTouchesBeganWithEvent:(id)aEvent hitTestInfo:(id)aInfo;
- (BOOL)handleSwipeGesture:(id)aGesture hitTestInfo:(id)aInfo;
- (BOOL)handleRotationGestureWithEvent:(id)aEvent hitTestInfo:(id)aInfo;
- (BOOL)handleMagnificationGestureWithEvent:(id)aEvent hitTestInfo:(id)aInfo;
- (BOOL)handleScrollWheelAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo;
- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags hitTestInfo:(id)aInfo event:(id)aEvent;
- (BOOL)handleMouseUpAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo;
- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo;
- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo;
- (id)hitTestNextInteractiveItemAfterItem:(id)aItem atPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo;
- (NSRect)boundingRectOccupiedByLayer;
- (void)renderRect:(NSRect)aRect;
- (void)renderSublayersInRange:(NSRange)aRange inRect:(NSRect)aRect;
- (void)invalidateDisplay;
- (BOOL)isRunningInWindow;
- (BOOL)isRunning;
- (id)representedObject;
- (id)context;
- (void)willResignActiveLayer;
- (void)didBecomeActiveLayer;
- (void)renderingViewTransformDidChange;
- (void)representedObjectDidChange;
- (void)representedObjectWillChange;
- (void)willStopRunningInWindow;
- (void)willStopRunning;
- (void)didStartRunningInWindow;
- (void)didStartRunning;
- (void)contextDidChange;
- (void)contextWillChange;
- (id)parentLayer;
- (void)setParentLayer:(id)aLayer;
- (id)rootLayer;
- (void)willRemoveSublayer:(id)aSublayer;
- (void)didAddSublayer:(id)aSublayer;
- (void)removeAllSublayers;
- (void)removeSublayerAtIndex:(NSUInteger)aIndex;
- (void)removeSublayer:(id)aSublayer;
- (void)removeSublayer:(id)aSublayer atIndex:(NSUInteger)aIndex;
- (void)addSublayer:(id)aSublayer;
- (void)addSublayer:(id)aSublayer atIndex:(NSUInteger)aIndex;
- (NSUInteger)indexOfSublayer:(id)aSublayer;
- (void)removeSublayerFromStorage:(id)aStorage atIndex:(NSUInteger)aIndex;
- (void)insertSublayerInStorage:(id)aStorage atIndex:(NSUInteger)aIndex;
- (id)sublayerAtIndex:(NSUInteger)aIndex;
- (NSUInteger)numberOfSublayers;
- (id)allSublayers;
- (id)renderingView;
- (void)dealloc;
@end

