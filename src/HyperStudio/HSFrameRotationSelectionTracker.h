#import "HyperStudioPrefix.h"
#import "HSSelectionKnobTracker.h"


@interface HSFrameRotationSelectionTracker : HSSelectionKnobTracker
{
    NSPoint _centerPoint;
}
- (void)drawRect:(NSRect)aRect inView:(id)aView;
- (void)invalidateSelectionKnobInView:(id)aView;
- (void)mouseUp:(id)aUp inView:(id)aView;
- (void)postprocessMouseDown:(id)aDown inView:(id)aView;
- (void)processMouseDragged:(id)aDragged inView:(id)aView;
- (void)mouseEvent:(id)aEvent inView:(id)aView;
- (id)selectionKnob;
- (NSPoint)centerPoint;
@end

