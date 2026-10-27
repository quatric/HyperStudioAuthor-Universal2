#import "HyperStudioPrefix.h"


@interface HSAnimationSetupEditPathCanvasLayer : HSCompositeCanvasLayer <HSAutoscrollingTrackingLoopClient, HSTrackingLoopClient, NSObject>
{
    id<HSAnimationSetupEditPathCanvasLayerOwner> _owner;
    unsigned int _mouseDownKnobIndex;
    BOOL _mouseDownWithCommand;
    BOOL _mouseDownWithShift;
    BOOL _mouseDownOnSelectedKnob;
    NSPoint _mouseDownUserPoint;
    BOOL _didDrag;
    NSBezierPath *_pathBeforeDrag;
    BOOL _draggingPath;
    BOOL _tracking;
}
- (void)setPoint:(NSPoint)aPoint atIndex:(NSUInteger)aIndex forPath:(id)aPath;
- (NSPoint)pointAtIndex:(NSUInteger)aIndex forPath:(id)aPath;
- (BOOL)prefersRegionInvalidation;
- (void)dragToUserPoint:(NSPoint)aPoint;
- (NSPoint)userPointFromEvent:(id)aEvent;
- (NSPoint)viewPointFromEvent:(id)aEvent;
- (void)handleFlagsChanged:(id)aChanged inTrackingLoop:(id)aLoop;
- (void)handleMouseUp:(id)aUp inTrackingLoop:(id)aLoop;
- (void)handleMouseDragged:(id)aDragged inTrackingLoop:(id)aLoop;
- (void)handleMouseDown:(id)aDown inTrackingLoop:(id)aLoop;
- (BOOL)handleKeyEventSelector:(SEL)aSelector;
- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags hitTestInfo:(id)aInfo event:(id)aEvent;
- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo;
- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo;
- (void)setOwner:(id)aOwner;
- (id)owner;
- (void)dealloc;
@end

