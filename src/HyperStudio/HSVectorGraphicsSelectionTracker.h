#import "HyperStudioPrefix.h"
#import "HSSelectionKnobTracker.h"


@interface HSVectorGraphicsSelectionTracker : HSSelectionKnobTracker
{
    id<HSMutableVectorGraphicsAttributes> _vectorGraphicsAttributes;
}
- (void)mouseUp:(id)aUp inView:(id)aView;
- (void)processMouseDragged:(id)aDragged inView:(id)aView;
- (void)mouseEvent:(id)aEvent inView:(id)aView;
- (BOOL)adjustPoint:(NSPoint *)aPoint;
- (void)processMouseDown:(id)aDown inView:(id)aView;
- (id)mutableVectorGraphicsAttributes;
- (id)vectorGraphicsAttributes;
- (void)setTrackingObject:(id)aObject;
- (void)dealloc;
@end

