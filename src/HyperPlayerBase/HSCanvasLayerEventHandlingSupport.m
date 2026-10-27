#import "HSCanvasLayerEventHandlingSupport.h"
// Invocations of the event handler methods, for passing an event down the
// canvas layers until one handles it. The handlers here handle nothing.
@implementation HSCanvasLayerEventHandlingSupport
// The handler selectors by tag.
static SEL sEventHandlerSelectors[5];
static NSMethodSignature *sEventHandlerMethodSignatures[5];
static void HSCanvasLayerEventHandlingSupportInitSelectors(void)
{
    if (sEventHandlerSelectors[0] != NULL)
        return;
    sEventHandlerSelectors[0] = @selector(handleMouseMovedAtPoint:insideView:event:);
    sEventHandlerSelectors[1] = @selector(handleFlagsChanged:atPoint:);
    sEventHandlerSelectors[2] = @selector(handleRawKeyDownEvent:);
    sEventHandlerSelectors[3] = @selector(handleRawKeyUpEvent:);
    sEventHandlerSelectors[4] = @selector(handleKeyEquivalent:);
}
+ (id)keyEquivalentHandlerInvocationWithEvent:(id)aEvent
{
    NSInvocation *invocation = [self eventHandlerInvocationWithTag:4];
    [invocation setArgument:&aEvent atIndex:2];
    return invocation;
}
+ (id)rawKeyUpHandlerInvocationWithEvent:(id)aEvent
{
    NSInvocation *invocation = [self eventHandlerInvocationWithTag:3];
    [invocation setArgument:&aEvent atIndex:2];
    return invocation;
}
+ (id)rawKeyDownHandlerInvocationWithEvent:(id)aEvent
{
    NSInvocation *invocation = [self eventHandlerInvocationWithTag:2];
    [invocation setArgument:&aEvent atIndex:2];
    return invocation;
}
+ (id)flagsChangedHandlerInvocationWithEvent:(id)aEvent point:(NSPoint)aPoint
{
    NSInvocation *invocation = [self eventHandlerInvocationWithTag:1];
    [invocation setArgument:&aEvent atIndex:2];
    [invocation setArgument:&aPoint atIndex:3];
    return invocation;
}
+ (id)mouseMovedHandlerInvocationWithPoint:(NSPoint)aPoint insideView:(BOOL)aView event:(id)aEvent
{
    NSInvocation *invocation = [self eventHandlerInvocationWithTag:0];
    [invocation setArgument:&aPoint atIndex:2];
    [invocation setArgument:&aView atIndex:3];
    [invocation setArgument:&aEvent atIndex:4];
    return invocation;
}
// Without a target.
+ (id)eventHandlerInvocationWithTag:(NSInteger)aTag
{
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self eventHandlerMethodSignatureWithTag:aTag]];
    HSCanvasLayerEventHandlingSupportInitSelectors();
    [invocation setSelector:sEventHandlerSelectors[aTag]];
    return invocation;
}
// Asked of an instance once per tag and kept.
+ (id)eventHandlerMethodSignatureWithTag:(NSInteger)aTag
{
    if (sEventHandlerMethodSignatures[aTag] == nil) {
        HSCanvasLayerEventHandlingSupportInitSelectors();
        id instance = [[self alloc] init];
        sEventHandlerMethodSignatures[aTag] = [[instance methodSignatureForSelector:sEventHandlerSelectors[aTag]] retain];
        [instance release];
    }
    return sEventHandlerMethodSignatures[aTag];
}
- (BOOL)handleKeyEquivalent:(id)aEquivalent
{
    return NO;
}
- (BOOL)handleRawKeyUpEvent:(id)aEvent
{
    return NO;
}
- (BOOL)handleRawKeyDownEvent:(id)aEvent
{
    return NO;
}
- (BOOL)handleFlagsChanged:(id)aChanged atPoint:(NSPoint)aPoint
{
    return NO;
}
- (BOOL)handleMouseMovedAtPoint:(NSPoint)aPoint insideView:(BOOL)aView event:(id)aEvent
{
    return NO;
}
@end
