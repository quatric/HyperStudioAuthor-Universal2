#import "HyperStudioPrefix.h"


@interface HSPlaceObjectCanvasLayer : HSCompositeCanvasLayer
{
    id<HSPlaceObjectCanvasLayerOwner> _owner;
}
- (NSPoint)userPointFromEvent:(id)aEvent;
- (BOOL)handleRawKeyDownEvent:(id)aEvent;
- (BOOL)handleKeyEventSelector:(SEL)aSelector;
- (BOOL)handleMouseMovedAtPoint:(NSPoint)aPoint insideView:(BOOL)aView event:(id)aEvent;
- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo;
- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo;
- (void)setOwner:(id)aOwner;
- (id)owner;
@end

