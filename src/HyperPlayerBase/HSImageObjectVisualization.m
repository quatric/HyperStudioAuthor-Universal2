#import "HSImageObjectVisualization.h"
@implementation HSImageObjectVisualization
// The multi-clip layer holding the image and, on top, its border. Without an
// image layer there is no subtree; a missing border is left out.
- (id)expandedEffectRenderLayerSubtreeWithVisualizationOptions:(id)aOptions
{
    id clipLayer = [self expandableRenderLayerWithIdentifier:[self multiClipRenderLayerIdentifierForVisualizationOptions:aOptions]
                                           precreateSelector:@selector(precreateMultiClipRenderLayerForVisualizationOptions:)
                                        visualizationOptions:aOptions];
    if (clipLayer == nil)
        return nil;
    id imageLayer = [self renderLayerWithIdentifier:@"HSImageRenderLayerIdentifier"
                                  precreateSelector:@selector(precreateImageRenderLayerForVisualizationOptions:)
                               visualizationOptions:aOptions];
    if (imageLayer == nil)
        return nil;
    [clipLayer addRenderSublayer:imageLayer forRole:@"HSImageRenderLayerRole" asRoot:NO addingTransparencyLayerRequirement:YES];
    id borderLayer = [self renderLayerWithIdentifier:@"HSImageBorderRenderLayerIdentifier"
                                   precreateSelector:@selector(precreateImageBorderRenderLayerForVisualizationOptions:)
                                visualizationOptions:aOptions];
    if (borderLayer != nil)
        [clipLayer addRenderSublayer:borderLayer forRole:@"HSImageBorderRenderLayerRole" asRoot:NO addingTransparencyLayerRequirement:YES];
    return clipLayer;
}
- (id)precreateMultiClipRenderLayerForVisualizationOptions:(id)aOptions
{
    return [[HSMutableClipPathsRenderLayer alloc] initWithHyperObject:[self hyperObject]];
}
- (id)multiClipRenderLayerIdentifierForVisualizationOptions:(id)aOptions
{
    return @"HSMultiClipRenderLayerIdentifier";
}
- (id)precreateImageBorderRenderLayerForVisualizationOptions:(id)aOptions
{
    return [[HSImageBorderRenderLayer alloc] initWithHyperObject:[self hyperObject] cachingPolicy:2];
}
- (id)precreateImageRenderLayerForVisualizationOptions:(id)aOptions
{
    return [[HSGenericImageRenderLayer alloc] initWithHyperObject:[self hyperObject]];
}
@end
