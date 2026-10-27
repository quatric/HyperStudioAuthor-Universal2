#import "HyperStudioPrefix.h"


@interface HSBezierPathCreationCanvasLayer : HSCompositeCanvasLayer <HSAutoscrollingTrackingLoopClient, HSTrackingLoopClient, NSObject>
{
    id _creatingObject;
    id _delegate;
    id _prototypeObject;
    BOOL _isStraightLineMode;
    BOOL _isAppendPending;
    BOOL _isAppendPendingWithCurrentPoint;
    BOOL _createsClosedPathByDefault;
    NSPoint _pendingPoint;
}
- (void)cancelCreatingVectorGraphicsObject;
- (void)finishCreatingVectorGraphicsObject;
- (void)finishCreatingVectorGraphicsObjectWithMouseEvent:(id)aEvent;
- (void)startCreatingVectorGraphicsObjectWithMouseEvent:(id)aEvent;
- (void)removeTemporaryPointIfAnyWithMouseEvent:(id)aEvent;
- (void)addTemporaryPointWithMouseEvent:(id)aEvent;
- (void)addPointWithMouseEvent:(id)aEvent;
- (BOOL)shouldIgnoreMouseMovedEvent:(id)aEvent;
- (NSInteger)editingMode;
- (NSUInteger)currentPointIndex;
- (void)handleFlagsChanged:(id)aChanged inTrackingLoop:(id)aLoop;
- (void)handleMouseUp:(id)aUp inTrackingLoop:(id)aLoop;
- (void)handleMouseDragged:(id)aDragged inTrackingLoop:(id)aLoop;
- (void)handleMouseDown:(id)aDown inTrackingLoop:(id)aLoop;
- (BOOL)handleMouseMovedAtPoint:(NSPoint)aPoint insideView:(BOOL)aView event:(id)aEvent;
- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo;
- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo;
- (id)vectorAttributes;
- (void)setCreatingObject:(id)aObject;
- (id)creatingObject;
- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags hitTestInfo:(id)aInfo event:(id)aEvent;
- (BOOL)supportsDynamicPathClosing;
- (void)setCreatesClosedPathByDefault:(BOOL)aDefault;
- (BOOL)createsClosedPathByDefault;
- (void)setStraightLineMode:(BOOL)aMode;
- (BOOL)isStraightLineMode;
- (id)defaultBezierPath;
- (void)setPrototypeObject:(id)aObject;
- (id)prototypeObject;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)dealloc;
@end

