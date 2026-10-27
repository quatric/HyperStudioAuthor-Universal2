#import "HyperPlayerBasePrefix.h"
#import "HSCardObjectTracker.h"


@interface HSMoveCardObjectTracker : HSCardObjectTracker
{
    BOOL _didStartDragging;
    BOOL _shiftModifierPresent;
    id _alignedCopyObject;
}
- (void)setTrackingObject:(id)aObject;
- (void)flagsChanged:(id)aChanged inView:(id)aView;
- (void)mouseUp:(id)aUp inView:(id)aView;
- (void)mouseDown:(id)aDown inView:(id)aView;
- (void)processMouseDragged:(id)aDragged inView:(id)aView;
- (void)mouseEvent:(id)aEvent inView:(id)aView;
- (void)moveCardObjectOriginTo:(NSPoint)aTo;
- (BOOL)adjustOrigin:(NSPoint *)aOrigin;
@end

