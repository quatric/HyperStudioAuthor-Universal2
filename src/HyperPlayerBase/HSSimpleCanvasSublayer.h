#import "HyperPlayerBasePrefix.h"


@interface HSSimpleCanvasSublayer : NSObject <HSCanvasSublayer, HSCanvasLayer, NSObject>
{
    id<HSCanvasSuperlayer> _parentLayer;
}
- (BOOL)isRunningInWindow;
- (BOOL)isRunning;
- (void)willStopRunningInWindow;
- (void)didStartRunningInWindow;
- (void)willStopRunning;
- (void)didStartRunning;
- (void)willResignActiveLayer;
- (void)didBecomeActiveLayer;
- (void)renderingViewTransformDidChange;
- (void)contextDidChange;
- (void)contextWillChange;
- (void)representedObjectDidChange;
- (void)representedObjectWillChange;
- (id)parentLayer;
- (void)setParentLayer:(id)aLayer;
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
- (void)invalidateDisplay;
- (id)representedObject;
- (id)context;
- (id)renderingView;
@end

