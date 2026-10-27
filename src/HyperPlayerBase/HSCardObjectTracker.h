#import "HyperPlayerBasePrefix.h"
#import "HSMouseTracker.h"


@interface HSCardObjectTracker : HSMouseTracker
{
    id _trackingObject;
    NSPoint _startPoint;
    NSPoint _startOrigin;
    NSAffineTransform *_startTransform;
    NSAffineTransform *_inverseStartTransform;
    NSPoint _moveDirection;
}
- (void)mouseUp:(id)aUp inView:(id)aView;
- (void)processMouseDown:(id)aDown inView:(id)aView;
- (void)mouseEvent:(id)aEvent inView:(id)aView;
- (NSRect)currentBoundingRect;
- (void)drawRect:(NSRect)aRect inView:(id)aView;
- (id)inverseStartTransform;
- (id)startTransform;
- (NSPoint)startOrigin;
- (NSPoint)startPoint;
- (void)setTrackingObject:(id)aObject;
- (id)trackingObject;
- (id)geometryApplier;
- (id)mutableGeometryAttributes;
- (id)geometryAttributes;
- (id)copyWithZone:(NSZone *)aZone;
- (void)dealloc;
@end

