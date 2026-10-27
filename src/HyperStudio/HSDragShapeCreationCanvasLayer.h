#import "HyperStudioPrefix.h"


@interface HSDragShapeCreationCanvasLayer : HSSimpleCanvasSublayer
{
    id _creatingObject;
    id _delegate;
    id _prototypeObject;
}
- (void)cancelCreatingObject;
- (void)finishCreatingObject;
- (void)startCreatingShapeWithMouseEvent:(id)aEvent;
- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags hitTestInfo:(id)aInfo event:(id)aEvent;
- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo;
- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo;
- (void)setCreatingObject:(id)aObject;
- (id)creatingObject;
- (void)setPrototypeObject:(id)aObject;
- (id)prototypeObject;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)dealloc;
@end

