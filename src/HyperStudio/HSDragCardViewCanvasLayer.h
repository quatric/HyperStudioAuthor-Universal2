#import "HyperStudioPrefix.h"


@interface HSDragCardViewCanvasLayer : HSSimpleCanvasSublayer <HSTrackingLoopClient, NSObject>
{
    NSPoint _startPoint;
    HSCursor *_currentCursor;
    BOOL _isLayerStarted;
    int _activeLayerMode;
}
- (void)HSDragCardViewCanvasLayer_windowDidBecomeKey:(id)aKey;
- (void)HSDragCardViewCanvasLayer_selectCursorForLayerMode:(NSInteger)aMode modifierFlags:(NSUInteger)aFlags;
- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags hitTestInfo:(id)aInfo event:(id)aEvent;
- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo;
- (id)cursorWithMouseEvent:(id)aEvent inTrackingLoop:(id)aLoop;
- (void)handleKeyUp:(id)aUp inTrackingLoop:(id)aLoop;
- (void)handleKeyDown:(id)aDown inTrackingLoop:(id)aLoop;
- (void)handleFlagsChanged:(id)aChanged inTrackingLoop:(id)aLoop;
- (void)handleMouseUp:(id)aUp inTrackingLoop:(id)aLoop;
- (void)handleMouseDragged:(id)aDragged inTrackingLoop:(id)aLoop;
- (void)handleMouseDown:(id)aDown inTrackingLoop:(id)aLoop;
- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo;
- (BOOL)handleRawKeyUpEvent:(id)aEvent;
- (BOOL)handleRawKeyDownEvent:(id)aEvent;
- (void)willStopRunningInWindow;
- (void)willStopRunning;
- (void)didStartRunningInWindow;
- (void)didStartRunning;
- (void)resetCurrentCursor;
- (id)cursorForLayerMode:(NSInteger)aMode modifierFlags:(NSUInteger)aFlags;
- (NSInteger)activeLayerMode;
- (BOOL)isLayerStarted;
- (void)initialzeCanvasLayer;
- (void)dealloc;
@end

