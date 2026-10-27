#import "HSInteractiveGraphicObject.h"
@implementation HSInteractiveGraphicObject
- (void)trackMouseWithMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext
{
    id view = [[aContext context] renderingView];
    id<HSGeometryAttributes> geometry = [[self hyperObject] queryHyperInterface:@protocol(HSGeometryAttributes)];
    NSRect viewRect = [(HSCardView *)view viewBoundingRectForUserRect:[geometry frameBoundingRect]];
    if (NSIsEmptyRect(viewRect))
        return;
    NSWindow *window = [view window];
    id<HSUserObjectInteractiveHitTesting> hitTester = [[self hyperObject] queryNewHyperInterface:@protocol(HSUserObjectInteractiveHitTesting)];
    id<HSHighlightAttributes> highlight = [[self hyperObject] queryHyperInterface:@protocol(HSHighlightAttributes)];
    id<HSCardObjectAttributes> cardAttributes = [[self hyperObject] queryHyperInterface:@protocol(HSCardObjectAttributes)];

    if ([aEvent modifierFlags] & NSEventModifierFlagOption) {
        if ([view respondsToSelector:@selector(startDragWithNodes:event:)])
            [view startDragWithNodes:[NSArray arrayWithObject:[self hyperObject]] event:aEvent];
        return;
    }
    if ([cardAttributes isDraggable]) {
        [highlight setHighlightedInInteractiveMode:YES];
        BOOL wasDragged = NO;
        [aContext trackMouseForDraggableItem:self withMouseDownEvent:aEvent wasDragged:&wasDragged];
        [highlight setHighlightedInInteractiveMode:NO];
        [aContext sendClickActionsForItemIfNeeded:self];
        if (wasDragged)
            [aContext sendDropOffActionsFromItemIfNeeded:self];
        return;
    }
    if ([cardAttributes isResizable]) {
        [highlight setHighlightedInInteractiveMode:YES];
        [aContext trackMouseForResizableItem:self withMouseDownEvent:aEvent wasResized:NULL];
        [highlight setHighlightedInInteractiveMode:NO];
        [aContext sendClickActionsForItemIfNeeded:self];
        return;
    }
    BOOL rotatable = [cardAttributes isRotatable];
    [highlight setHighlightedInInteractiveMode:YES];
    if (rotatable) {
        [aContext trackMouseForRotatableItem:self withMouseDownEvent:aEvent wasRotated:NULL];
        [highlight setHighlightedInInteractiveMode:NO];
        [aContext sendClickActionsForItemIfNeeded:self];
        return;
    }
    // Plain button-like tracking: highlight while the mouse is inside, click on mouse-up inside.
    for (;;) {
        NSEvent *event = [window nextEventMatchingMask:NSEventMaskAny];
        NSEventType type = [event type];
        if (type != NSEventTypeLeftMouseUp && type != NSEventTypeLeftMouseDragged)
            continue;
        NSPoint point = [view convertPointFromViewSpaceToUserSpace:[view convertPoint:[event locationInWindow] fromView:nil]];
        BOOL inside = [hitTester hitTestUserPoint:point];
        if (type == NSEventTypeLeftMouseUp) {
            [highlight setHighlightedInInteractiveMode:NO];
            if (inside)
                [aContext sendClickActionsForItemIfNeeded:self];
            return;
        }
        [highlight setHighlightedInInteractiveMode:inside];
    }
}
- (BOOL)sendingActionsIsDisabled
{
    return [self isImageHidden];
}
- (BOOL)wantsToTrackMouseWithMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext
{
    return [[[self hyperObject] queryHyperInterface:@protocol(HSHighlightAttributes)] canBeHighlighted];
}
- (BOOL)isImageHidden
{
    return [[[self hyperObject] queryHyperInterface:@protocol(HSCardObjectAttributes)] isHiddenInPlayer];
}
@end
