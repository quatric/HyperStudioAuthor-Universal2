#import "HSGenericClipRenderLayer.h"
// A group clipped by a path.
@implementation HSGenericClipRenderLayer
// The sublayers' region within the clip path's bounds.
- (BOOL)unionBoundingRegionOfSublayersVisualAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion
{
    NSBezierPath *path = [_clipAttributes clipPath];
    if (path == NULL)
        return [super unionBoundingRegionOfSublayersVisualAttributeSet:aSet ofHyperObject:aObject withInfo:aInfo withRegion:aRegion];
    HSMutableRegion *region = nil;
    if (![super unionBoundingRegionOfSublayersVisualAttributeSet:aSet ofHyperObject:aObject withInfo:aInfo withRegion:&region])
        return NO;
    [region intersectRegion:[HSRegion regionWithRect:[path bounds]]];
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
    NSBezierPath *path = [_clipAttributes clipPath];
    if (path == NULL)
        return region;
    HSMutableRegion *clipped = [HSMutableRegion regionWithRect:[path bounds]];
    [clipped intersectRegion:region];
    return [[clipped copy] autorelease];
}
- (void)fillBoundingRegionAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSClipPathAttribute) forObject:[self hyperObject]];
    [super fillBoundingRegionAttributesSet:aSet];
}
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate
{
    [[_clipAttributes clipPath] addClip];
    [super predrawRegion:aRegion withDelegate:aDelegate];
}
- (void)fillVisualizationMaskAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSClipPathAttribute) forObject:[self hyperObject]];
    [super fillVisualizationMaskAttributesSet:aSet];
}
- (void)fillVisualizationAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSClipPathAttribute) forObject:[self hyperObject]];
    [super fillVisualizationAttributesSet:aSet];
}
- (void)dealloc
{
    [_clipAttributes release];
    [super dealloc];
}
- (id)initWithHyperObject:(id)aObject renderSublayerCapacity:(NSUInteger)aCapacity cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject renderSublayerCapacity:aCapacity cachingPolicy:aPolicy];
    if (self != nil) {
        _clipAttributes = [[aObject queryHyperInterface:@protocol(HSClipAttributes)] retain];
        if (_clipAttributes != nil)
            return self;
        [self release];
    }
    return nil;
}
@end
