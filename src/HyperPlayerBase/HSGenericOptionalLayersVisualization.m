#import "HSGenericOptionalLayersVisualization.h"

// Wraps the expanded tree in optional layers, outermost first: show/hide
// transition (when the object can be hidden), shadow and opacity, effect.
@implementation HSGenericOptionalLayersVisualization
- (id)expandedRenderLayerTreeWithVisualizationOptions:(id)aOptions
{
    id subtree = [self expandedShowHideTransitionRenderLayerSubtreeWithVisualizationOptions:aOptions];
    if (!subtree || ![self canBeHidden])
        return subtree;
    id layer = [self showHideTransitionRenderLayerWithVisualizationOptions:aOptions];
    if (!layer)
        return subtree;
    [layer setContentRenderLayer:subtree];
    return layer;
}
- (id)expandedShowHideTransitionRenderLayerSubtreeWithVisualizationOptions:(id)aOptions
{
    id layer = [self shadowAndOpacityRenderLayerWithVisualizationOptions:aOptions];
    if (!layer)
        return nil;
    id subtree = [self expandedShadowAndOpacityRenderLayerSubtreeWithVisualizationOptions:aOptions];
    if (!subtree)
        return nil;
    [layer setContentRenderLayer:subtree];
    return layer;
}
- (id)expandedShadowAndOpacityRenderLayerSubtreeWithVisualizationOptions:(id)aOptions
{
    id layer = [self effectRenderLayerWithVisualizationOptions:aOptions];
    if (!layer)
        return nil;
    id subtree = [self expandedEffectRenderLayerSubtreeWithVisualizationOptions:aOptions];
    if (!subtree)
        return nil;
    [layer addRenderSublayer:subtree forRole:@"HSEffectContentRenderLayerRole" asRoot:NO addingTransparencyLayerRequirement:YES];
    return layer;
}
- (id)expandedEffectRenderLayerSubtreeWithVisualizationOptions:(id)aOptions
{
    return nil;
}
// Objects without their own effect share a placeholder layer.
- (id)effectRenderLayerWithVisualizationOptions:(id)aOptions
{
    if ([self hasEffectPerObject])
        return [self expandableRenderLayerWithIdentifier:[self effectRenderLayerIdentifierForVisualizationOptions:aOptions] precreateSelector:@selector(precreateEffectRenderLayerForVisualizationOptions:) visualizationOptions:aOptions];
    return [self expandableRenderLayerWithIdentifier:[self effectPlaceholderRenderLayerIdentifierForVisualizationOptions:aOptions] precreateSelector:@selector(precreateEffectPlaceholderRenderLayerForVisualizationOptions:) visualizationOptions:aOptions];
}
- (id)precreateEffectPlaceholderRenderLayerForVisualizationOptions:(id)aOptions
{
    return [[HSGenericEffectPlaceholderRenderLayer alloc] initWithHyperObject:[self hyperObject] cachingPolicy:1];
}
- (id)effectPlaceholderRenderLayerIdentifierForVisualizationOptions:(id)aOptions
{
    return @"HSEffectPlaceholderRenderLayerIdentifier";
}
// Core Image first, QuickTime as the fallback.
- (id)precreateEffectRenderLayerForVisualizationOptions:(id)aOptions
{
    id object = [self hyperObject];
    id layer = [[HSGenericCIEffectRenderLayer alloc] initWithHyperObject:object];
    if (!layer)
        layer = [[HSGenericQTEffectRenderLayer alloc] initWithHyperObject:object];
    return layer;
}
- (id)effectRenderLayerIdentifierForVisualizationOptions:(id)aOptions
{
    id object = [self hyperObject];
    if ([[object queryHyperInterface:@protocol(HSCoreImageEffectAccessing)] coreImageEffect])
        return @"HSEffectRenderLayerIdentifier-CoreImage";
    if ([[object queryHyperInterface:@protocol(HSQuickTimeEffectAccessing)] quickTimeEffect])
        return @"HSEffectRenderLayerIdentifier-QuickTime";
    return @"HSEffectRenderLayerIdentifier";
}
- (BOOL)hasEffectPerObject
{
    if (![self supportsEffectPerObject])
        return NO;
    return [[[self hyperObject] queryHyperInterface:@protocol(HSCardObjectAttributes)] hasEffectPerObject];
}
- (BOOL)supportsEffectPerObject
{
    if (![self hyperObject])
        return NO;
    return [[self hyperObject] implementsHyperInterface:@protocol(HSEffectPerObjectAttributes)];
}
- (id)shadowAndOpacityRenderLayerWithVisualizationOptions:(id)aOptions
{
    return [self renderLayerWithIdentifier:[self shadowAndOpacityRenderLayerIdentifierForVisualizationOptions:aOptions] precreateSelector:@selector(precreateShadowAndOpacityRenderLayerForVisualizationOptions:) visualizationOptions:aOptions];
}
- (id)precreateShadowAndOpacityRenderLayerForVisualizationOptions:(id)aOptions
{
    return [[HSShadowAndOpacityRenderLayer alloc] initWithHyperObject:[self hyperObject] opacityAttributes:![self ignoresTransparency] cachingPolicy:0];
}
- (id)shadowAndOpacityRenderLayerIdentifierForVisualizationOptions:(id)aOptions
{
    return [self ignoresTransparency] ? @"HSShadowAndOpacityRenderLayerIdentifier-HSObjectListPaletteVisualization" : @"HSShadowAndOpacityRenderLayerIdentifier";
}
- (id)opacityRenderLayerWithVisualizationOptions:(id)aOptions
{
    return [self renderLayerWithIdentifier:[self opacityRenderLayerIdentifierForVisualizationOptions:aOptions] precreateSelector:@selector(precreateOpacityRenderLayerForVisualizationOptions:) visualizationOptions:aOptions];
}
- (id)precreateOpacityRenderLayerForVisualizationOptions:(id)aOptions
{
    return [[HSOpacityRenderLayer alloc] initWithHyperObject:[self hyperObject] cachingPolicy:0];
}
- (id)opacityRenderLayerIdentifierForVisualizationOptions:(id)aOptions
{
    return @"HSOpacityRenderLayerIdentifier";
}
- (id)showHideTransitionRenderLayerWithVisualizationOptions:(id)aOptions
{
    return [self renderLayerWithIdentifier:[self showHideTransitionRenderLayerIdentifierForVisualizationOptions:aOptions] precreateSelector:@selector(precreateShowHideTransitionRenderLayerForVisualizationOptions:) visualizationOptions:aOptions];
}
- (id)precreateShowHideTransitionRenderLayerForVisualizationOptions:(id)aOptions
{
    return [[HSShowHideTransitionRenderLayer alloc] initWithHyperObject:[self hyperObject]];
}
- (id)showHideTransitionRenderLayerIdentifierForVisualizationOptions:(id)aOptions
{
    return [self ignoresTransparency] ? @"HSShowHideTransitionRenderLayerIdentifier-HSObjectListPaletteVisualization" : @"HSShowHideTransitionRenderLayerIdentifier";
}
// Object list palette thumbnails ignore transparency.
- (BOOL)ignoresTransparency
{
    return protocol_conformsToProtocol([self visualizationProtocol], @protocol(HSObjectListPaletteVisualization));
}
// Editor visualizations always show the object.
- (BOOL)canBeHidden
{
    return !protocol_conformsToProtocol([self visualizationProtocol], @protocol(HSEditorVisualization));
}
@end
