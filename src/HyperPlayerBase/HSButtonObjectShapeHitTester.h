#import "HyperPlayerBasePrefix.h"
#import "HSVisualHitTester.h"


@interface HSButtonObjectShapeHitTester : HSVisualHitTester
{
}
- (BOOL)hitTestUserPoint:(NSPoint)aPoint;
- (id)borderAttributes;
- (id)geometryAttributes;
@end

