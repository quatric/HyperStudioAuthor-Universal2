#import "HyperStudioPrefix.h"
#import "HSSelectionKnobTracker.h"


@interface HSEffectCenterSelectionTracker : HSSelectionKnobTracker
{
    id<HSEffectMutableAttributes> _effectsAttributes;
}
- (void)mouseUp:(id)aUp inView:(id)aView;
- (void)processMouseDragged:(id)aDragged inView:(id)aView;
- (void)mouseEvent:(id)aEvent inView:(id)aView;
- (void)processMouseDown:(id)aDown inView:(id)aView;
- (void)setTrackingObject:(id)aObject;
- (void)dealloc;
@end

