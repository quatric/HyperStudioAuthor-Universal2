#import "HyperStudioPrefix.h"


@interface HSTrackingPointCanvasLayer : HSSimpleCanvasSublayer <HSAutoscrollingTrackingLoopClient, HSTrackingLoopClient, NSObject>
{
    NSPoint _trackingPoint;
    BOOL _isTracking;
    id _delegate;
}
- (BOOL)handleKeyEventSelector:(SEL)aSelector;
- (void)willResignActiveLayer;
- (void)didBecomeActiveLayer;
- (NSRect)boundingRectOccupiedByLayer;
- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags hitTestInfo:(id)aInfo event:(id)aEvent;
- (void)handleFlagsChanged:(id)aChanged inTrackingLoop:(id)aLoop;
- (void)handleMouseUp:(id)aUp inTrackingLoop:(id)aLoop;
- (void)handleMouseDragged:(id)aDragged inTrackingLoop:(id)aLoop;
- (void)handleMouseDown:(id)aDown inTrackingLoop:(id)aLoop;
- (void)updateTrackingPointWithMouseEvent:(id)aEvent inView:(id)aView;
- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo;
- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)notifyDidFinishTrackingPoint;
- (void)setTrackingPoint:(NSPoint)aPoint;
- (NSPoint)trackingPoint;
@end

