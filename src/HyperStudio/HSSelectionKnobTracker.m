#import "HSSelectionKnobTracker.h"

@implementation HSSelectionKnobTracker

- (void)handleFlagsChanged:(id)aChanged inTrackingLoop:(id)aLoop
{
    [super handleFlagsChanged:aChanged inTrackingLoop:aLoop];
    if ([aLoop cursor] != nil)
        [self updateCursorWithEvent:aChanged inTrackingLoop:aLoop];
}

- (void)handleMouseDown:(id)aDown inTrackingLoop:(id)aLoop
{
    [self updateCursorWithEvent:aDown inTrackingLoop:aLoop];
    [super handleMouseDown:aDown inTrackingLoop:aLoop];
}

// Fix: the original converted an uninitialised point here; the event location is used instead.
- (void)updateCursorWithEvent:(id)aEvent inTrackingLoop:(id)aLoop
{
    if ([[self selectionKnob] overridesTrackingLoopCursor])
        return;

    id view = [aLoop view];
    NSPoint point = [view convertPoint:[(NSEvent *)aEvent locationInWindow] fromView:nil];
    id cursor = [[self selectionKnob] cursorAtPoint:point modifierFlags:[aEvent modifierFlags] inView:view owner:[self trackingObject]];

    if (cursor != nil)
        [aLoop setCursor:cursor];
}

// Fix: same uninitialised point as above.
- (id)cursorWithMouseEvent:(id)aEvent inTrackingLoop:(id)aLoop
{
    if (![[self selectionKnob] overridesTrackingLoopCursor])
        return nil;

    id view = [aLoop view];
    NSPoint point = [view convertPoint:[(NSEvent *)aEvent locationInWindow] fromView:nil];
    return [[self selectionKnob] cursorAtPoint:point modifierFlags:[aEvent modifierFlags] inView:view owner:[self trackingObject]];
}

- (void)setSelectionKnob:(id)aKnob
{
    if (_selectionKnob != aKnob) {
        [_selectionKnob release];
        _selectionKnob = [aKnob retain];
    }
}

- (id)selectionKnob
{
    return _selectionKnob;
}

- (void)dealloc
{
    [_selectionKnob release];
    [super dealloc];
}

@end
