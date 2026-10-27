#import "HyperPlayerBasePrefix.h"
#import "HSCardObjectTracker.h"


@interface HSRotateCardObjectTracker : HSCardObjectTracker
{
    NSPoint _centerPoint;
    float _startObjectAngle;
    float _rotationHandleStartAngle;
}
- (void)mouseUp:(id)aUp inView:(id)aView;
- (void)postprocessMouseDown:(id)aDown inView:(id)aView;
- (void)processMouseDragged:(id)aDragged inView:(id)aView;
- (void)mouseEvent:(id)aEvent inView:(id)aView;
@end

