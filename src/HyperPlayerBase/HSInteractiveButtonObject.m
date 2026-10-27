#import "HSInteractiveButtonObject.h"
@implementation HSInteractiveButtonObject
// A draggable button is tracked by the context (click, then drop off actions
// when it was dragged). Otherwise a duplicate of the system button view is
// put over the object and its cell tracks the mouse, like a real button:
// when the mouse leaves, events are followed until it comes back (tracking
// again) or goes up (no click).
- (void)trackMouseWithMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext
{
    id renderingView = [[aContext context] renderingView];
    id duplicating = [[self hyperObject] queryHyperInterface:@protocol(HSSystemViewDuplicatingInterface)];
    if (duplicating == nil)
        return;
    id button = [duplicating addDuplicateHyperSystemView];
    NSRect frame = [[[self hyperObject] queryHyperInterface:@protocol(HSGeometryAttributes)] frameBoundingRect];
    frame = [renderingView viewBoundingRectForUserRect:frame];
    [button setFrame:frame];
    frame = [button frame];
    id cell = [button cell];
    id interactiveMode = [[self hyperObject] queryHyperInterface:@protocol(HSSystemButtonInteractiveModeAttributes)];
    // Original quirk kept: on these early returns (and in the draggable case)
    // the duplicate view isn't removed here.
    if (NSIsEmptyRect(frame))
        return;
    NSEvent *event = aEvent;
    NSWindow *window = [renderingView window];
    if ([[[self hyperObject] queryHyperInterface:@protocol(HSCardObjectAttributes)] isDraggable]) {
        [interactiveMode setHyperHighlightedInInteractiveMode:YES];
        BOOL wasDragged = NO;
        [aContext trackMouseForDraggableItem:self withMouseDownEvent:aEvent wasDragged:&wasDragged];
        [interactiveMode setHyperHighlightedInInteractiveMode:NO];
        [aContext sendClickActionsForItemIfNeeded:self];
        if (wasDragged)
            [aContext sendDropOffActionsFromItemIfNeeded:self];
        return;
    }
    BOOL clicked = NO;
    BOOL mouseUp = NO;
    while (!clicked && !mouseUp) {
        [interactiveMode setHyperHighlightedInInteractiveMode:YES];
        clicked = [cell trackMouse:event inRect:frame ofView:renderingView untilMouseUp:NO];
        [interactiveMode setHyperHighlightedInInteractiveMode:NO];
        if (clicked) {
            [renderingView displayIfNeeded];
            break;
        }
        for (;;) {
            event = [window nextEventMatchingMask:NSEventMaskLeftMouseUp | NSEventMaskLeftMouseDragged];
            if ([event type] == NSEventTypeLeftMouseUp) {
                mouseUp = YES;
                break;
            }
            NSPoint location = [renderingView convertPoint:[event locationInWindow] fromView:nil];
            if ([renderingView mouse:location inRect:frame])
                break;
        }
    }
    [duplicating removeDuplicateHyperSystemView:button];
    if (clicked)
        [aContext sendClickActionsForItemIfNeeded:self];
}
- (BOOL)sendingActionsIsDisabled
{
    return ![self buttonIsEnabled] || [self buttonIsHidden];
}
// Clicks go through a button without click actions that can't be dragged.
- (BOOL)wantsToPassThroughMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext
{
    id cardObjectAttributes = [[self hyperObject] queryHyperInterface:@protocol(HSCardObjectAttributes)];
    id actor = [self queryHyperInterface:@protocol(HSActor)];
    id event = [HSActionEvent actionEventOfType:kHSClickActionEventType];
    if ([[actor hyperActionsForEvent:event] count] != 0)
        return NO;
    return ![cardObjectAttributes isDraggable];
}
- (BOOL)wantsToTrackMouseWithMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext
{
    return [self buttonIsEnabled];
}
- (BOOL)buttonIsHidden
{
    return [[[self hyperObject] queryHyperInterface:@protocol(HSCardObjectAttributes)] isHiddenInPlayer];
}
- (BOOL)buttonIsEnabled
{
    return [[[self hyperObject] queryHyperInterface:@protocol(HSSystemButtonAttributes)] isEnabled];
}
@end
