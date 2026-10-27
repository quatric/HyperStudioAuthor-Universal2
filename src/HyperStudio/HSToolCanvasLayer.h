#import "HyperStudioPrefix.h"


@interface HSToolCanvasLayer : HSCompositeCanvasLayer <HSAutoscrollingTrackingLoopClient, HSTrackingLoopClient, NSObject>
{
    HSTool<HSToolCanvasLayerClient> *_tool;
}
- (BOOL)trackingLoop:(id)aLoop shouldAutoscrollWithMouseEvent:(id)aEvent;
- (void)handleFlagsChanged:(id)aChanged inTrackingLoop:(id)aLoop;
- (void)handleMouseUp:(id)aUp inTrackingLoop:(id)aLoop;
- (void)handleMouseDragged:(id)aDragged inTrackingLoop:(id)aLoop;
- (void)handleMouseDown:(id)aDown inTrackingLoop:(id)aLoop;
- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags hitTestInfo:(id)aInfo event:(id)aEvent;
- (BOOL)handleKeyEventSelector:(SEL)aSelector;
- (BOOL)handleFlagsChanged:(id)aChanged atPoint:(NSPoint)aPoint;
- (BOOL)handleMouseMovedAtPoint:(NSPoint)aPoint insideView:(BOOL)aView event:(id)aEvent;
- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo;
- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo;
- (void)setTool:(id)aTool;
- (id)tool;
@end

