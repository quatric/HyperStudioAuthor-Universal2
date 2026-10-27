#import "HSGenericBackgroundRenderLayer.h"
// A background (color, gradient, pattern or image) over its bounds.
@implementation HSGenericBackgroundRenderLayer
// Solid colors are drawn directly.
- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce
{
    if (aForce)
        return YES;
    id graphics = [_backgroundAttributes backgroundGraphics];
    if (graphics == nil)
        return NO;
    if (![graphics isKindOfClass:[HSColor class]])
        return YES;
    return ![graphics isHyperSolid];
}
- (id)calculateBoundingRegion
{
    return [HSRegion regionWithRect:[_backgroundAttributes backgroundBounds]];
}
- (void)fillBoundingRegionAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSBackgroundBoundsAttribute) forObject:[self hyperObject]];
}
- (BOOL)requiresTransparencyLayer
{
    return YES;
}
// Drawn flipped within the bounds: the part of the region in them.
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate
{
    NSRect bounds = [_backgroundAttributes backgroundBounds];
    CGAffineTransform flip = CGAffineTransformMake(1, 0, 0, -1, 0, (float)(bounds.size.height + bounds.origin.y + bounds.origin.y));
    [[NSAffineTransform transformWithHyperCGAffineTransform:flip] concat];
    NSRect rect = NSIntersectionRect([aRegion boundingRect], bounds);
    CGPoint origin = CGPointApplyAffineTransform(CGPointMake(rect.origin.x, rect.origin.y + rect.size.height), flip);
    rect.origin = NSPointFromCGPoint(origin);
    [[_backgroundAttributes backgroundGraphics] hyperDrawInRect:rect ofBounds:bounds];
}
- (void)fillVisualizationAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSBackgroundAttribute) forObject:[self hyperObject]];
}
- (void)dealloc
{
    [_backgroundAttributes release];
    [super dealloc];
}
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject cachingPolicy:aPolicy];
    if (self != nil) {
        _backgroundAttributes = [[aObject queryHyperInterface:@protocol(HSBackgroundAttributes)] retain];
        if (_backgroundAttributes == nil) {
            [self release];
            self = nil;
        }
    }
    return self;
}
@end
