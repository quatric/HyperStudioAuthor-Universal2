#import "HyperPlayerBasePrefix.h"
#import "HSMoveCardObjectTracker.h"


@interface HSMoveSnappingCardObjectTracker : HSMoveCardObjectTracker
{
    BOOL _isSnapped;
}
- (BOOL)unsnapIfNeededToPoint:(NSPoint)aPoint;
- (void)snapFromCurrentPoint:(NSPoint)aPoint toPoint:(NSPoint)aPoint2 animated:(BOOL)aAnimated;
- (BOOL)snapToDropOffTargetIfNeededObjectWithOrigin:(NSPoint)aOrigin;
- (NSPoint)snappingPoint;
- (id)snappingTarget;
- (void)moveCardObjectOriginTo:(NSPoint)aTo;
- (void)processMouseDown:(id)aDown inView:(id)aView;
@end

