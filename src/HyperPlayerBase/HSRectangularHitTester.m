#import "HSRectangularHitTester.h"
@implementation HSRectangularHitTester
- (BOOL)hitTestUserRect:(NSRect)aRect
{
    return !NSIsEmptyRect(NSIntersectionRect([self boundingRect], aRect));
}
- (BOOL)hitTestUserPoint:(NSPoint)aPoint
{
    return NSPointInRect(aPoint, [self boundingRect]);
}
- (NSRect)boundingRect
{
    NSRect rect = NSZeroRect;
    id<HSGeometryAttributes> geometry = [self geometryAttributes];
    if (geometry != nil)
        rect = [geometry frameBoundingRect];
    return rect;
}
- (id)geometryAttributes
{
    return [[self hyperObject] queryHyperInterface:@protocol(HSGeometryAttributes)];
}
@end
