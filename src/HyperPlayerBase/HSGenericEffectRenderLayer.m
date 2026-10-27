#import "HSGenericEffectRenderLayer.h"
// A group drawn through an effect: its one sublayer is the source area.
@implementation HSGenericEffectRenderLayer
- (BOOL)unionBoundingRegionOfSublayersVisualAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion
{
    if (*aRegion == nil)
        *aRegion = [HSMutableRegion region];
    return [self unionBoundingRegionWithRegion:*aRegion];
}
- (void)fillVisualizationMaskAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSEffectVisualAttribute) forObject:[self hyperObject]];
    [super fillVisualizationMaskAttributesSet:aSet];
}
- (void)fillVisualizationAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSEffectVisualAttribute) forObject:[self hyperObject]];
    [super fillVisualizationAttributesSet:aSet];
}
- (id)effectAttributes
{
    return _effectAttributes;
}
- (id)sourceAreaRenderSublayer
{
    if ([self renderSublayerCount] == 0)
        return nil;
    return [self renderSublayerAtIndex:0];
}
- (void)HSGenericEffectRenderLayer_effectDidChange:(id)aChange
{
    [self notifyObserversWithSelector:@selector(renderLayerWantsToReexpand:)];
}
- (void)dealloc
{
    [[_effectAttributes attributeObservingController] removeObserver:self selector:@selector(HSGenericEffectRenderLayer_effectDidChange:)
                                                           ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSEffectNameAttribute)];
    [_effectAttributes release];
    [super dealloc];
}
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject renderSublayerCapacity:1 cachingPolicy:aPolicy];
    if (self != nil) {
        _effectAttributes = [[aObject queryHyperInterface:@protocol(HSEffectAttributes)] retain];
        if (_effectAttributes == nil) {
            [self release];
            return nil;
        }
        [[_effectAttributes attributeObservingController] addObserver:self selector:@selector(HSGenericEffectRenderLayer_effectDidChange:)
                                                            ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSEffectNameAttribute) withPriority:0.25f];
    }
    return self;
}
- (id)initWithHyperObject:(id)aObject renderSublayerCapacity:(NSUInteger)aCapacity cachingPolicy:(NSInteger)aPolicy
{
    return [self initWithHyperObject:aObject cachingPolicy:aPolicy];
}
@end
