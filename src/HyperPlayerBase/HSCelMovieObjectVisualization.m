#import "HSCelMovieObjectVisualization.h"
@implementation HSCelMovieObjectVisualization
// A cel movie has no show/hide transition, shadow or effect layers: each
// level is just the image layer.
- (id)expandedShowHideTransitionRenderLayerSubtreeWithVisualizationOptions:(id)aOptions
{
    return [self expandedShadowAndOpacityRenderLayerSubtreeWithVisualizationOptions:aOptions];
}
- (id)expandedShadowAndOpacityRenderLayerSubtreeWithVisualizationOptions:(id)aOptions
{
    return [self expandedEffectRenderLayerSubtreeWithVisualizationOptions:aOptions];
}
- (id)expandedEffectRenderLayerSubtreeWithVisualizationOptions:(id)aOptions
{
    return [self renderLayerWithIdentifier:@"HSImageRenderLayerIdentifier"
                         precreateSelector:@selector(precreateImageRenderLayerForVisualizationOptions:)
                      visualizationOptions:aOptions];
}
- (id)precreateImageRenderLayerForVisualizationOptions:(id)aOptions
{
    return [[HSGenericImageRenderLayer alloc] initWithHyperObject:[self hyperObject]];
}
- (BOOL)canBeHidden
{
    return NO;
}
@end
