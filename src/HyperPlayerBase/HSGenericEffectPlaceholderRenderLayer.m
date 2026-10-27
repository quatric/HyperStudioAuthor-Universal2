#import "HSGenericEffectPlaceholderRenderLayer.h"
@implementation HSGenericEffectPlaceholderRenderLayer
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
// A new effect needs a new layer subtree.
- (void)HSGenericEffectPlaceholderRenderLayer_effectDidChange:(id)aChange
{
    [self notifyObserversWithSelector:@selector(renderLayerWantsToReexpand:)];
}
- (void)dealloc
{
    [[_effectAttributes attributeObservingController] removeObserver:self selector:@selector(HSGenericEffectPlaceholderRenderLayer_effectDidChange:)
                                                           ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSEffectNameAttribute)];
    [_effectAttributes release];
    [super dealloc];
}
- (id)initWithHyperObject:(id)aObject renderSublayerCapacity:(NSUInteger)aCapacity cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject renderSublayerCapacity:aCapacity cachingPolicy:aPolicy];
    if (self == nil)
        return nil;
    _effectAttributes = [[aObject queryHyperInterface:@protocol(HSEffectAttributes)] retain];
    if (_effectAttributes == nil) {
        [self release];
        return nil;
    }
    [[_effectAttributes attributeObservingController] addObserver:self selector:@selector(HSGenericEffectPlaceholderRenderLayer_effectDidChange:)
                                                        ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSEffectNameAttribute) withPriority:0.25];
    return self;
}
@end
