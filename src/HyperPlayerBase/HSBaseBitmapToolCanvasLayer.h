#import "HyperPlayerBasePrefix.h"
#import "HSSimpleCanvasSublayer.h"


@interface HSBaseBitmapToolCanvasLayer : HSSimpleCanvasSublayer
{
    HSBaseBitmapTool *_tool;
}
- (BOOL)validateUserInterfaceItem:(id)aItem;
- (void)forwardInvocation:(id)aInvocation;
- (id)methodSignatureForSelector:(SEL)aSelector;
- (BOOL)respondsToSelector:(SEL)aSelector;
- (void)representedObjectDidChange;
- (BOOL)handleRawKeyDownEvent:(id)aEvent;
- (BOOL)handleFlagsChanged:(id)aChanged atPoint:(NSPoint)aPoint;
- (BOOL)handleMouseMovedAtPoint:(NSPoint)aPoint insideView:(BOOL)aView event:(id)aEvent;
- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags hitTestInfo:(id)aInfo event:(id)aEvent;
- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo;
- (id)hitTestCanvasLayerAtPoint:(NSPoint)aPoint insideView:(BOOL)aView clickCount:(NSUInteger)aCount modifierFlags:(NSUInteger)aFlags hitTestInfo:(id *)aInfo;
- (void)renderRect:(NSRect)aRect;
- (void)setTool:(id)aTool;
- (id)tool;
@end

