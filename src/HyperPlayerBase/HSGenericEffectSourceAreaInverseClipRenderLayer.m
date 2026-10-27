#import "HSGenericEffectSourceAreaInverseClipRenderLayer.h"
// Draws its sublayers everywhere except inside the effect's source area.
@implementation HSGenericEffectSourceAreaInverseClipRenderLayer
- (void)renderLayerDidChangeBoundingRegion:(id)aRegion
{
    [_contentBoundingRegion release];
    _contentBoundingRegion = nil;
    [super renderLayerDidChangeBoundingRegion:aRegion];
}
- (id)calculateBoundingRegion
{
    return [self contentBoundingRegion];
}
- (void)HSGenericEffectSourceAreaInverseClipRenderLayer_contentBoundingRegionDidChange:(id)aChange
{
    [_contentBoundingRegion release];
    _contentBoundingRegion = nil;
}
// The sublayers' bounding region, cached until their attributes change.
- (id)contentBoundingRegion
{
    if (_contentBoundingRegion == nil) {
        _contentBoundingRegion = [[super calculateBoundingRegion] copy];
        if (_contentBoundingRegionAttributes == nil)
            [self HSGenericEffectSourceAreaInverseClipRenderLayer_linkContentBoundingRegionToAttributes];
    }
    return _contentBoundingRegion;
}
- (void)fillBoundingRegionAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSEffectSourceAreaAttribute) forObject:[self hyperObject]];
    if (_contentBoundingRegionAttributes == nil)
        [self HSGenericEffectSourceAreaInverseClipRenderLayer_linkContentBoundingRegionToAttributes];
    [aSet unionMultipleObjectsAttributeSet:_contentBoundingRegionAttributes];
}
- (void)HSGenericEffectSourceAreaInverseClipRenderLayer_linkContentBoundingRegionToAttributes
{
    _contentBoundingRegionAttributes = [[HSMutableMultipleObjectsAttributeSet alloc] init];
    [super fillBoundingRegionAttributesSet:_contentBoundingRegionAttributes];
    [_contentBoundingRegionAttributes addObserver:self
                                         selector:@selector(HSGenericEffectSourceAreaInverseClipRenderLayer_contentBoundingRegionDidChange:)
                                        ofChanges:HSActualDidAttributeChanges
                                     withPriority:0.25];
}
// Clipped to the content bounds minus the source area (the area's path
// reversed inside the bounds rect); nothing is drawn when there's no content.
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate
{
    CGPathRef sourceArea = [_effectAttributes effectSourceAreaBoundingPath];
    if (sourceArea != NULL) {
        id region = [self contentBoundingRegion];
        if ([region isEmpty])
            return;
        NSBezierPath *clip = [NSBezierPath bezierPathWithRect:[region boundingRect]];
        [clip appendBezierPath:[[NSBezierPath hyperBezierPathWithCGPath:(CGMutablePathRef)sourceArea] bezierPathByReversingPath]];
        [clip addClip];
    }
    [super predrawRegion:aRegion withDelegate:aDelegate];
}
- (void)fillVisualizationAttributesSet:(id)aSet
{
    id object = [self hyperObject];
    [super fillVisualizationAttributesSet:aSet];
    [aSet addAttribute:@protocol(HSEffectSourceAreaAttribute) forObject:object];
}
- (void)dealloc
{
    [_effectAttributes release];
    [_contentBoundingRegionAttributes removeObserver:self
                                            selector:@selector(HSGenericEffectSourceAreaInverseClipRenderLayer_contentBoundingRegionDidChange:)
                                           ofChanges:HSActualDidAttributeChanges];
    [_contentBoundingRegionAttributes release];
    [_contentBoundingRegion release];
    [super dealloc];
}
- (id)initWithHyperObject:(id)aObject renderSublayerCapacity:(NSUInteger)aCapacity cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject renderSublayerCapacity:aCapacity cachingPolicy:aPolicy];
    if (self != nil) {
        _effectAttributes = [[aObject queryHyperInterface:@protocol(HSEffectAttributes)] retain];
        if (_effectAttributes == nil) {
            [self release];
            return nil;
        }
    }
    return self;
}
@end
