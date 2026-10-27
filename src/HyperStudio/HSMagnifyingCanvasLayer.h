#import "HyperStudioPrefix.h"
#import "HSDragCardViewCanvasLayer.h"


@interface HSMagnifyingCanvasLayer : HSDragCardViewCanvasLayer
{
    NSRect _selectionRect;
    HSMagnifyingTool *_owner;
    id<HSEditorCanvasLayerContext> _layerContext;
}
- (void)renderRect:(NSRect)aRect;
- (void)invalidateDisplay;
- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo;
- (void)handleFlagsChanged:(id)aChanged inTrackingLoop:(id)aLoop;
- (void)handleMouseUp:(id)aUp inTrackingLoop:(id)aLoop;
- (void)handleMouseDragged:(id)aDragged inTrackingLoop:(id)aLoop;
- (void)handleMouseDown:(id)aDown inTrackingLoop:(id)aLoop;
- (BOOL)handleRawKeyDownEvent:(id)aEvent;
- (BOOL)handleFlagsChanged:(id)aChanged atPoint:(NSPoint)aPoint;
- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo;
- (void)willStopRunningInWindow;
- (void)willStopRunning;
- (void)HSMagnifyingCanvasLayerAuxiliary_magnifyingCanvasLayeViewDidChangeUserSpaceToViewSpaceTransform:(id)aTransform;
- (id)HSMagnifyingCanvasLayerAuxiliary_cursorForLayerMode:(NSInteger)aMode modifierFlags:(NSUInteger)aFlags zoomFactor:(CGFloat)aFactor;
- (id)cursorForLayerMode:(NSInteger)aMode modifierFlags:(NSUInteger)aFlags;
- (void)initialzeCanvasLayer;
- (id)owner;
- (void)setOwner:(id)aOwner;
- (void)dealloc;
@end

