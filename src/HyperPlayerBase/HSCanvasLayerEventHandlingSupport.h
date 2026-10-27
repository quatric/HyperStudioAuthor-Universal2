#import "HyperPlayerBasePrefix.h"


@interface HSCanvasLayerEventHandlingSupport : NSObject
{
}
+ (id)keyEquivalentHandlerInvocationWithEvent:(id)aEvent;
+ (id)rawKeyUpHandlerInvocationWithEvent:(id)aEvent;
+ (id)rawKeyDownHandlerInvocationWithEvent:(id)aEvent;
+ (id)flagsChangedHandlerInvocationWithEvent:(id)aEvent point:(NSPoint)aPoint;
+ (id)mouseMovedHandlerInvocationWithPoint:(NSPoint)aPoint insideView:(BOOL)aView event:(id)aEvent;
+ (id)eventHandlerInvocationWithTag:(NSInteger)aTag;
+ (id)eventHandlerMethodSignatureWithTag:(NSInteger)aTag;
- (BOOL)handleKeyEquivalent:(id)aEquivalent;
- (BOOL)handleRawKeyUpEvent:(id)aEvent;
- (BOOL)handleRawKeyDownEvent:(id)aEvent;
- (BOOL)handleFlagsChanged:(id)aChanged atPoint:(NSPoint)aPoint;
- (BOOL)handleMouseMovedAtPoint:(NSPoint)aPoint insideView:(BOOL)aView event:(id)aEvent;
@end

