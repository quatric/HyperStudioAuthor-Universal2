#import "HSGenericEffectSourceAreaRenderLayer.h"
// The area an effect takes its source from: a group clipped by its path.
@implementation HSGenericEffectSourceAreaRenderLayer
// The sublayers' region within the source area's bounds.
- (BOOL)unionBoundingRegionOfSublayersVisualAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion
{
    CGPathRef path = [_effectAttributes effectSourceAreaBoundingPath];
    if (path == NULL)
        return [super unionBoundingRegionOfSublayersVisualAttributeSet:aSet ofHyperObject:aObject withInfo:aInfo withRegion:aRegion];
    HSMutableRegion *region = nil;
    if (![super unionBoundingRegionOfSublayersVisualAttributeSet:aSet ofHyperObject:aObject withInfo:aInfo withRegion:&region])
        return NO;
    [region intersectRegion:[HSRegion regionWithRect:[[NSBezierPath hyperBezierPathWithCGPath:(CGMutablePathRef)path] bounds]]];
    if ([region isEmpty])
        return NO;
    if (*aRegion == nil)
        *aRegion = region;
    else
        [*aRegion addRegion:region];
    return YES;
}
- (id)calculateBoundingRegion
{
    id region = [super calculateBoundingRegion];
    if ([region isEmpty])
        return region;
    CGPathRef path = [_effectAttributes effectSourceAreaBoundingPath];
    if (path == NULL)
        return region;
    HSMutableRegion *clipped = [HSMutableRegion regionWithRect:[[NSBezierPath hyperBezierPathWithCGPath:(CGMutablePathRef)path] bounds]];
    [clipped intersectRegion:region];
    return [[clipped copy] autorelease];
}
- (void)fillBoundingRegionAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSEffectSourceAreaAttribute) forObject:[self hyperObject]];
    [super fillBoundingRegionAttributesSet:aSet];
}
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate
{
    CGPathRef path = [_effectAttributes effectSourceAreaBoundingPath];
    if (path != NULL) {
        CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
        CGContextBeginPath(context);
        CGContextAddPath(context, path);
        CGContextClip(context);
    }
    [super predrawRegion:aRegion withDelegate:aDelegate];
}
- (void)fillVisualizationMaskAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSEffectSourceAreaAttribute) forObject:[self hyperObject]];
    [super fillVisualizationMaskAttributesSet:aSet];
}
- (void)fillVisualizationAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSEffectSourceAreaAttribute) forObject:[self hyperObject]];
    [super fillVisualizationAttributesSet:aSet];
}
- (void)dealloc
{
    [_effectAttributes release];
    [super dealloc];
}
- (id)initWithHyperObject:(id)aObject renderSublayerCapacity:(NSUInteger)aCapacity cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject renderSublayerCapacity:aCapacity cachingPolicy:aPolicy];
    if (self != nil) {
        _effectAttributes = [[aObject queryHyperInterface:@protocol(HSEffectAttributes)] retain];
        if (_effectAttributes != nil)
            return self;
        [self release];
    }
    return nil;
}
@end
