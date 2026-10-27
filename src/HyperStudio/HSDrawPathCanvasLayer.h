#import "HyperStudioPrefix.h"


@interface HSDrawPathCanvasLayer : HSCompositeCanvasLayer <HSAutoscrollingTrackingLoopClient, HSTrackingLoopClient, NSObject>
{
    int _pathCreationMode;
    id<HSDrawPathCanvasLayerOwner> _owner;
}
- (NSPoint)userPointFromEvent:(id)aEvent;
- (void)handleFlagsChanged:(id)aChanged inTrackingLoop:(id)aLoop;
- (void)handleMouseUp:(id)aUp inTrackingLoop:(id)aLoop;
- (void)handleMouseDragged:(id)aDragged inTrackingLoop:(id)aLoop;
- (void)handleMouseDown:(id)aDown inTrackingLoop:(id)aLoop;
- (BOOL)handleRawKeyDownEvent:(id)aEvent;
- (BOOL)handleKeyEventSelector:(SEL)aSelector;
- (BOOL)handleMouseMovedAtPoint:(NSPoint)aPoint insideView:(BOOL)aView event:(id)aEvent;
- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo;
- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo;
- (NSInteger)pathCreationMode;
- (void)setOwner:(id)aOwner;
- (id)owner;
- (id)initWithPathCreationMode:(NSInteger)aMode;
@end

