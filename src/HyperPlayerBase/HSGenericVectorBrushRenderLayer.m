#import "HSGenericVectorBrushRenderLayer.h"
// A vector brush stroke, drawn by the brush's renderer.
@implementation HSGenericVectorBrushRenderLayer
// Unscaled strokes aren't cached (they're drawn directly) unless forced.
- (BOOL)cacheRenderingInRegion:(id)aRegion withAffineTransform:(CGAffineTransform)aTransform validness:(CGFloat)aValidness validnessEvaluator:(id)aEvaluator delegate:(id)aDelegate force:(BOOL)aForce share:(BOOL)aShare resultCache:(id *)aCache
{
    if (!aForce) {
        float xScale = hypotf(aTransform.a, aTransform.b);
        float yScale = hypotf(aTransform.c, aTransform.d);
        if (xScale >= 0.9999f && xScale <= 1.0001f && yScale >= 0.9999f && yScale <= 1.0001f)
            return NO;
    }
    return [super cacheRenderingInRegion:aRegion withAffineTransform:aTransform validness:aValidness validnessEvaluator:aEvaluator delegate:aDelegate force:aForce share:aShare resultCache:aCache];
}
- (BOOL)willCacheRenderingInRegion:(id)aRegion withTransformationIntent:(struct HyperPlayerBase_anon12 *)aIntent countOnRenderSublayersInfluence:(NSInteger)aInfluence force:(BOOL)aForce
{
    return [self willCacheRenderingInRegion:aRegion force:aForce];
}
- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce
{
    return YES;
}
- (id)calculateBoundingRegion
{
    return [HSRegion regionWithRect:[_brushAttributes hyperToolBoundingRect]];
}
- (void)fillBoundingRegionAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSBrushThicknessAttribute) forObject:[self hyperObject]];
}
- (BOOL)requiresTransparencyLayer
{
    return YES;
}
// Drawn flipped within the tool bounds.
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate
{
    NSRect bounds = [_brushAttributes hyperToolBoundingRect];
    CGAffineTransform flip = CGAffineTransformMake(1, 0, 0, -1, 0, (float)(bounds.size.height + bounds.origin.y + bounds.origin.y));
    CGContextConcatCTM([[NSGraphicsContext currentContext] graphicsPort], flip);
    [[_brushAttributes brushRenderer] drawInRegion:aRegion];
}
- (void)fillVisualizationAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSBrushVisualAttribute) forObject:[self hyperObject]];
}
- (void)dealloc
{
    [_brushAttributes release];
    [super dealloc];
}
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject cachingPolicy:aPolicy];
    if (self != nil)
        _brushAttributes = [[aObject queryHyperInterface:@protocol(HSVectorBrushAttributes)] retain];
    return self;
}
@end
