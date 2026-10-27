#import "HSButtonObjectShapeHitTester.h"
@implementation HSButtonObjectShapeHitTester
- (BOOL)hitTestUserPoint:(NSPoint)aPoint
{
    id<HSGeometryAttributes> geometry = [self geometryAttributes];
    NSBezierPath *path = [[(id<HSButtonObjectBorderAttributes>)[self borderAttributes] borderPath] copy];
    BOOL hit = NO;
    if (geometry != nil && path != nil) {
        // the border path, centred on the object, in the object's own
        // (unrotated, flipped) coordinates
        NSRect bounds = [path bounds];
        NSSize size = [geometry size];
        NSAffineTransform *center = [NSAffineTransform transform];
        [center translateXBy:size.width * 0.5f + NSZeroPoint.x - (bounds.size.width * 0.5f + bounds.origin.x) + bounds.origin.x
                         yBy:size.height * 0.5f + NSZeroPoint.y - (bounds.size.height * 0.5f + bounds.origin.y) + bounds.origin.y];
        [path transformUsingAffineTransform:center];
        CGAffineTransform transform = [geometry affineTransform];
        if (transform.a * transform.d - transform.b * transform.c != 0)
            transform = CGAffineTransformInvert(transform);
        bounds = [path bounds];
        CGAffineTransform flip = {1, 0, 0, -1, 0, bounds.origin.y * 2 + bounds.size.height};
        [path transformUsingAffineTransform:[NSAffineTransform transformWithHyperCGAffineTransform:flip]];
        hit = [path containsPoint:NSPointFromCGPoint(CGPointApplyAffineTransform(NSPointToCGPoint(aPoint), transform))];
    }
    [path release];
    return hit;
}
- (id)borderAttributes
{
    return [[self hyperObject] queryHyperInterface:@protocol(HSButtonObjectBorderAttributes)];
}
- (id)geometryAttributes
{
    return [[self hyperObject] queryHyperInterface:@protocol(HSGeometryAttributes)];
}
@end
