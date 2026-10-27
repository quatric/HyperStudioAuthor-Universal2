#import "HyperStudioPrefix.h"


@interface HSSelectionKnobTracker : HSCardObjectTracker
{
    HSSelectionKnob *_selectionKnob;
}
- (void)handleFlagsChanged:(id)aChanged inTrackingLoop:(id)aLoop;
- (void)handleMouseDown:(id)aDown inTrackingLoop:(id)aLoop;
- (void)updateCursorWithEvent:(id)aEvent inTrackingLoop:(id)aLoop;
- (id)cursorWithMouseEvent:(id)aEvent inTrackingLoop:(id)aLoop;
- (void)setSelectionKnob:(id)aKnob;
- (id)selectionKnob;
- (void)dealloc;
@end

