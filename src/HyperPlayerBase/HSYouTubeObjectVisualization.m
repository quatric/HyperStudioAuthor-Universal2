#import "HSYouTubeObjectVisualization.h"
@implementation HSYouTubeObjectVisualization
- (id)expandedShadowAndOpacityRenderLayerSubtreeWithVisualizationOptions:(id)aOptions
{
    return [self expandedEffectRenderLayerSubtreeWithVisualizationOptions:aOptions];
}
- (id)expandedEffectRenderLayerSubtreeWithVisualizationOptions:(id)aOptions
{
    return [self renderLayerWithIdentifier:@"HSYouTubeRenderLayerIdentifier"
                         precreateSelector:@selector(precreateYouTubeRenderLayerForVisualizationOptions:)
                      visualizationOptions:aOptions];
}
- (id)precreateYouTubeRenderLayerForVisualizationOptions:(id)aOptions
{
    return [[HSYouTubeRenderLayer alloc] initWithHyperObject:[self hyperObject]];
}
- (id)precreateShadowAndOpacityRenderLayerForVisualizationOptions:(id)aOptions
{
    return [[HSShadowAndOpacityRenderLayer alloc] initWithHyperObject:[self hyperObject] opacityAttributes:NO cachingPolicy:0];
}
- (BOOL)ignoresTransparency
{
    return NO;
}
@end
