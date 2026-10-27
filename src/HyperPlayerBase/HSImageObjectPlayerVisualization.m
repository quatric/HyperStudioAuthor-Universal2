#import "HSImageObjectPlayerVisualization.h"
@implementation HSImageObjectPlayerVisualization
- (id)expandedShadowAndOpacityRenderLayerSubtreeWithVisualizationOptions:(id)aOptions
{
    id highlightLayer = [self expandableRenderLayerWithIdentifier:@"HSHighlightRenderLayerIdentifier"
                                               precreateSelector:@selector(precreateHighlightRenderLayerForVisualizationOptions:)
                                            visualizationOptions:aOptions];
    if (highlightLayer == nil)
        return nil;
    id subtree = [super expandedShadowAndOpacityRenderLayerSubtreeWithVisualizationOptions:aOptions];
    if (subtree == nil)
        return nil;
    [highlightLayer addRenderSublayer:subtree forRole:@"HSEffectRenderLayerRole" asRoot:NO addingTransparencyLayerRequirement:YES];
    return highlightLayer;
}
- (id)precreateHighlightRenderLayerForVisualizationOptions:(id)aOptions
{
    return [[HSHighlightRenderLayer alloc] initWithHyperObject:[self hyperObject]];
}
- (id)shadowAndOpacityRenderLayerIdentifierForVisualizationOptions:(id)aOptions
{
    return @"HSShadowAndOpacityRenderLayerIdentifier-HSPlayerVisualization";
}
- (id)showHideTransitionRenderLayerIdentifierForVisualizationOptions:(id)aOptions
{
    return @"HSShowHideTransitionRenderLayerIdentifier-HSPlayerVisualization";
}
@end
