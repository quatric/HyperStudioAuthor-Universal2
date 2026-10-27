#import "HyperStudioPrefix.h"


@interface HSFreehandPathCreationCanvasLayer : HSCompositeCanvasLayer <HSAutoscrollingTrackingLoopClient, HSTrackingLoopClient, NSObject>
{
    id _delegate;
    id _prototypeObject;
    id _creatingObject;
    NSMutableArray *_keyFrames;
    double _lastEventTimestamp;
    BOOL _didDrag;
}
- (void)finishCreatingPathWithEvent:(id)aEvent;
- (void)continueCreatingPathWithEvent:(id)aEvent;
- (void)startCreatingPathWithEvent:(id)aEvent;
- (void)setObjectPositionAccordingToMouseMovedEvent:(id)aEvent;
- (BOOL)isCreatingPath;
- (void)handleFlagsChanged:(id)aChanged inTrackingLoop:(id)aLoop;
- (void)handleMouseUp:(id)aUp inTrackingLoop:(id)aLoop;
- (void)handleMouseDragged:(id)aDragged inTrackingLoop:(id)aLoop;
- (void)handleMouseDown:(id)aDown inTrackingLoop:(id)aLoop;
- (BOOL)handleMouseMovedAtPoint:(NSPoint)aPoint insideView:(BOOL)aView event:(id)aEvent;
- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo;
- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo;
- (id)defaultBezierPath;
- (id)vectorAttributes;
- (void)setCreatingObject:(id)aObject;
- (id)creatingObject;
- (id)keyFrames;
- (void)setPrototypeObject:(id)aObject;
- (id)prototypeObject;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)dealloc;
- (id)init;
@end

