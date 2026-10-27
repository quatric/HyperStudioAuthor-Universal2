#import "HSInteractiveCanvasItem.h"

// Canvas item for player-side (interactive) objects: hit testing goes through
// the canvas hit tester, and plain click-through is allowed when the object has
// no click actions and cannot be dragged, resized or rotated.
@implementation HSInteractiveCanvasItem
- (BOOL)updateIfNeededInCanvasLayer:(id)aLayer
{
    return NO;
}
- (id)renderingRegionInCanvasLayer:(id)aLayer
{
    return nil;
}
- (NSRect)renderingBoundsInCanvasLayer:(id)aLayer
{
    return NSZeroRect;
}
- (BOOL)prefersRegionInvalidation
{
    return NO;
}
- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inCanvasLayer:(id)aLayer
{
    id cursorAttributes = [self queryHyperInterface:@protocol(HSCursorAttributes)];
    return cursorAttributes ? [cursorAttributes hyperCursor] : nil;
}
- (BOOL)hitTestPoint:(NSPoint)aPoint inCanvasLayer:(id)aLayer
{
    id hitTester = [[[aLayer context] canvasHitTester] hitTesterForNode:[self node] point:aPoint];
    if (hitTester == nil)
        return NO;
    NSPoint userPoint = [[[aLayer context] renderingView] convertPointFromViewSpaceToUserSpace:aPoint];
    return [hitTester hitTestUserPoint:userPoint];
}
- (void)renderRect:(NSRect)aRect inCanvasLayer:(id)aLayer isActive:(BOOL)aActive
{
}
- (void)awakeInPlayer
{
}
- (BOOL)trackMouseWithScrollWheelEvent:(id)aEvent inInteractiveContext:(id)aContext
{
    return NO;
}
- (BOOL)wantsToTrackMouseWithScrollWheelEvent:(id)aEvent inInteractiveContext:(id)aContext
{
    return NO;
}
- (BOOL)wantsToInterceptSendingClickActionsInInteractiveContext:(id)aContext
{
    return NO;
}
- (BOOL)sendingActionsIsDisabled
{
    return NO;
}
- (void)trackMouseWithMouseUpEvent:(id)aEvent inInteractiveContext:(id)aContext
{
}
- (BOOL)wantsToTrackMouseWithMouseUpEvent:(id)aEvent inInteractiveContext:(id)aContext
{
    return NO;
}
- (void)trackMouseWithMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext
{
}
- (BOOL)wantsToTrackMouseWithMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext
{
    return NO;
}
- (BOOL)hasExecutableActionsForMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext
{
    return NO;
}
- (BOOL)wantsToPassThroughMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext
{
    id attributes = [[self hyperObject] queryHyperInterface:@protocol(HSCardObjectAttributes)];
    if ([(NSEvent *)aEvent modifierFlags] & NSEventModifierFlagOption)
        return NO;
    id actor = [[self hyperObject] queryHyperInterface:@protocol(HSActor)];
    id event = [HSActionEvent actionEventOfType:kHSClickActionEventType];
    if ([[actor hyperActionsForEvent:event] count] != 0)
        return NO;
    if ([attributes isDraggable] || [attributes isResizable])
        return NO;
    return ![attributes isRotatable];
}
- (id)node
{
    return [self hyperObject];
}
- (void)dealloc
{
    [super dealloc];
}
- (id)initWithHyperObject:(id)aObject
{
    return [self initWithNode:aObject];
}
- (id)initWithNode:(id)aNode
{
    return [super initWithHyperObject:aNode];
}
@end
