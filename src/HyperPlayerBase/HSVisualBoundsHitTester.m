#import "HSVisualBoundsHitTester.h"
// Whether a corner of the rect, through the transform, is in the other rect.
static BOOL HSVisualBoundsHitTesterCornerInRect(NSRect aRect, CGAffineTransform aTransform, NSRect aOther)
{
    NSPoint corners[4] = {
        aRect.origin,
        NSMakePoint(aRect.origin.x + aRect.size.width, aRect.origin.y + aRect.size.height),
        NSMakePoint(aRect.origin.x, aRect.origin.y + aRect.size.height),
        NSMakePoint(aRect.origin.x + aRect.size.width, aRect.origin.y),
    };
    for (int i = 0; i < 4; i++) {
        if (NSPointInRect(NSPointFromCGPoint(CGPointApplyAffineTransform(NSPointToCGPoint(corners[i]), aTransform)), aOther))
            return YES;
    }
    return NO;
}

// Hits an object's rendered bounds (its bounding region's rect, in the
// renderer's space).
@implementation HSVisualBoundsHitTester
// The bounds (transformed) and the rect overlap when a corner of either
// lies in the other or, failing that, when their diagonals cross.
- (BOOL)hitTestUserRect:(NSRect)aRect
{
    id geometry = [self geometryAttributes];
    id region = [self userBoundingRegion];
    if (geometry == nil || region == nil)
        return NO;
    CGAffineTransform transform = [self rendererToRootUserSpaceAffineTransform];
    NSRect bounds = [region boundingRect];
    NSRect transformedBounds = NSRectFromCGRect(CGRectApplyAffineTransform(NSRectToCGRect(bounds), transform));
    NSRect overlap = NSIntersectionRect(aRect, transformedBounds);
    if (NSIsEmptyRect(overlap))
        return NO;
    if (HSVisualBoundsHitTesterCornerInRect(overlap, CGAffineTransformInvert(transform), NSIntegralRect(bounds)))
        return YES;
    if (HSVisualBoundsHitTesterCornerInRect(bounds, transform, NSIntegralRect(overlap)))
        return YES;
    CGPoint start = CGPointApplyAffineTransform(NSPointToCGPoint(bounds.origin), transform);
    CGPoint end = CGPointApplyAffineTransform(CGPointMake(NSMaxX(bounds), NSMaxY(bounds)), transform);
    float dx = end.x - start.x, dy = end.y - start.y;
    float width = (overlap.size.width + overlap.origin.x) - overlap.origin.x;
    float height = (overlap.size.height + overlap.origin.y) - overlap.origin.y;
    float denominator = dy * width - dx * height;
    float rx = overlap.origin.x - start.x, ry = overlap.origin.y - start.y;
    float t = (dx * ry - dy * rx) / denominator;
    float s = (ry * width - rx * height) / denominator;
    return t >= 0 && t <= 1 && s >= 0 && s <= 1;
}
- (BOOL)hitTestUserPoint:(NSPoint)aPoint
{
    id geometry = [self geometryAttributes];
    id region = [self userBoundingRegion];
    if (geometry == nil || region == nil)
        return NO;
    CGAffineTransform inverse = CGAffineTransformInvert([self rendererToRootUserSpaceAffineTransform]);
    return NSPointInRect(NSPointFromCGPoint(CGPointApplyAffineTransform(NSPointToCGPoint(aPoint), inverse)), [region boundingRect]);
}
- (CGAffineTransform)rendererToRootUserSpaceAffineTransform
{
    return [[[[self renderer] visualization] queryHyperInterface:@protocol(HSGeometryAttributes)] affineTransform];
}
- (id)userBoundingRegion
{
    return [[self renderer] boundingRegion];
}
// The renderer of the given visualization, or of the default one.
- (id)renderer
{
    id visualization = nil;
    if (_visualizationProtocol != nil)
        visualization = [[self hyperObject] queryHyperInterface:_visualizationProtocol];
    if (visualization == nil)
        visualization = [[self hyperObject] queryHyperInterface:@protocol(HSVisualization)];
    return [visualization queryRenderer];
}
- (id)geometryAttributes
{
    return [[self hyperObject] queryHyperInterface:@protocol(HSGeometryAttributes)];
}
- (id)initWithHyperObject:(id)aObject visualizationProtocol:(id)aProtocol
{
    self = [super initWithHyperObject:aObject];
    if (self != nil)
        _visualizationProtocol = aProtocol;
    return self;
}
@end
