#import "HyperStudioPrefix.h"


@interface HSTrackingRectCanvasLayer : HSCanvasItemsSublayer <HSAutoscrollingTrackingLoopClient, HSTrackingLoopClient, NSObject>
{
    HSTrackingRectCanvasItem *_trackingRectCanvasItem;
    NSRect _lastTrackingRect;
    NSRect _startPoint;
    id _delegate;
}
- (NSRect)boundingRectOccupiedByLayer;
- (void)handleFlagsChanged:(id)aChanged inTrackingLoop:(id)aLoop;
- (void)handleMouseUp:(id)aUp inTrackingLoop:(id)aLoop;
- (void)handleMouseDragged:(id)aDragged inTrackingLoop:(id)aLoop;
- (void)handleMouseDown:(id)aDown inTrackingLoop:(id)aLoop;
- (void)updateTrackingRectWithMouseEvent:(id)aEvent inView:(id)aView;
- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo;
- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo;
- (NSRect)lastTrackingRect;
- (void)setTrackingRectCanvasItem:(id)aItem;
- (id)canvasItemAtIndex:(NSUInteger)aIndex;
- (NSUInteger)numberOfCanvasItems;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)dealloc;
@end

