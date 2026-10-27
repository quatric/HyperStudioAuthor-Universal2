#import "HyperPlayerBasePrefix.h"
#import "HSCardObjectTracker.h"


@interface HSResizeCardObjectTracker : HSCardObjectTracker
{
    NSSize _startSize;
    NSPoint _centerPoint;
    float _distanceFromCenterToStartPoint;
}
- (void)mouseUp:(id)aUp inView:(id)aView;
- (void)processMouseDragged:(id)aDragged inView:(id)aView;
- (void)processMouseDown:(id)aDown inView:(id)aView;
- (void)mouseEvent:(id)aEvent inView:(id)aView;
@end

