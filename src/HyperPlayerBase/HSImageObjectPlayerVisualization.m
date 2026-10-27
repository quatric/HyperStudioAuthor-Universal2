#import "HSImageObjectPlayerVisualization.h"
@implementation HSImageObjectPlayerVisualization
- (id)expandedShadowAndOpacityRenderLayerSubtreeWithVisualizationOptions:(id)aOptions
{
    id highlightLayer = [self expandableRenderLayerWithIdentifier:@"HSHighlightRenderLayerIdentifier"
                                               precreateSelector:@selector(precreateHighlightRenderLayerForVisualizationOptions:)
                                            visualizationOptions:aOptions];
    if (highlightLayer != nil) {
        id subtree = [super expandedShadowAndOpacityRenderLayerSubtreeWithVisualizationOptions:aOptions];
        if (subtree != nil)
            [highlightLayer addRenderSublayer:subtree forRole:@"HSEffectRenderLayerRole" asRoot:NO addingTransparencyLayerRequirement:YES];
    }
    // The original always returns nil here.
    return nil;
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
