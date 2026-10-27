#import "HSMutableClipPathsRenderLayer.h"
// A group clipped by the object's unit rect and clip paths (in the object's
// space).
@implementation HSMutableClipPathsRenderLayer
- (BOOL)unionBoundingRegionOfLocalVisualAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion
{
    if ([[_mutableClipPathsAttributes clipPaths] count] == 0)
        return [super unionBoundingRegionOfLocalVisualAttributeSet:aSet ofHyperObject:aObject withInfo:aInfo withRegion:aRegion];
    id region = [self boundingRegion];
    if ([region isEmpty])
        return NO;
    if (*aRegion == nil)
        *aRegion = [[region mutableCopy] autorelease];
    else
        [*aRegion addRegion:region];
    return YES;
}
// The sublayers' region within the object's bounds and every clip path's.
- (id)calculateBoundingRegion
{
    id region = [super calculateBoundingRegion];
    NSArray *clipPaths = [_mutableClipPathsAttributes clipPaths];
    HSMutableRegion *clipped = [HSMutableRegion region];
    CGAffineTransform transform = [_mutableClipPathsAttributes relativeToObjectAffineTransform];
    CGRect bounds = NSRectToCGRect([_geometryAttributes boundingRect]);
    for (id path in clipPaths)
        bounds = CGRectIntersection(bounds, CGRectApplyAffineTransform(CGEPathGetPathBoundingBox((CGPathRef)path), transform));
    [clipped addRect:NSRectFromCGRect(bounds)];
    [clipped intersectRegion:region];
    return clipped;
}
- (void)fillBoundingRegionAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSClipPathsAttribute) forObject:[self hyperObject]];
    [super fillBoundingRegionAttributesSet:aSet];
}
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate
{
    NSArray *clipPaths = [_mutableClipPathsAttributes clipPaths];
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    CGAffineTransform transform = [_mutableClipPathsAttributes relativeToObjectAffineTransform];
    CGContextConcatCTM(context, transform);
    CGContextAddRect(context, CGRectMake(0, 0, 1, 1));
    CGContextClip(context);
    for (id path in clipPaths) {
        CGContextAddPath(context, (CGPathRef)path);
        CGContextClip(context);
    }
    CGContextConcatCTM(context, CGAffineTransformInvert(transform));
    [super predrawRegion:aRegion withDelegate:aDelegate];
}
- (void)fillVisualizationMaskAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSClipPathsAttribute) forObject:[self hyperObject]];
    [super fillVisualizationMaskAttributesSet:aSet];
}
- (void)fillVisualizationAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSClipPathsAttribute) forObject:[self hyperObject]];
    [super fillVisualizationAttributesSet:aSet];
}
- (void)dealloc
{
    [_geometryAttributes release];
    [_mutableClipPathsAttributes release];
    [super dealloc];
}
- (id)initWithHyperObject:(id)aObject renderSublayerCapacity:(NSUInteger)aCapacity cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject renderSublayerCapacity:aCapacity cachingPolicy:aPolicy];
    if (self != nil) {
        _geometryAttributes = [[aObject queryHyperInterface:@protocol(HSGeometryAttributes)] retain];
        if (_geometryAttributes != nil) {
            _mutableClipPathsAttributes = [[aObject queryHyperInterface:@protocol(HSMutableClipPathsAttributes)] retain];
            if (_mutableClipPathsAttributes != nil)
                return self;
        }
        [self release];
    }
    return nil;
}
@end
