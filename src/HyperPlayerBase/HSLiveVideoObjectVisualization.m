#import "HSLiveVideoObjectVisualization.h"
@implementation HSLiveVideoObjectVisualization
- (id)expandedEffectRenderLayerSubtreeWithVisualizationOptions:(id)aOptions
{
    return [self renderLayerWithIdentifier:@"HSVideoStreamObjectRenderLayerIdentifier"
                         precreateSelector:@selector(precreateVideoStreamObjectRenderLayerForVisualizationOptions:)
                      visualizationOptions:aOptions];
}
- (id)precreateVideoStreamObjectRenderLayerForVisualizationOptions:(id)aOptions
{
    id placeholder = [self renderLayerWithIdentifier:@"HSLiveVideoPlaceholderRenderLayerIdentifier"
                                   precreateSelector:@selector(precreateLiveVideoPlaceholderRenderLayerForVisualizationOptions:)
                                visualizationOptions:aOptions];
    return [[HSGenericVideoStreamObjectRenderLayer alloc] initWithHyperObject:[self hyperObject]
                                             withPlaceholderRenderSublayer:placeholder];
}
- (id)precreateLiveVideoPlaceholderRenderLayerForVisualizationOptions:(id)aOptions
{
    return [[HSGenericLiveVideoPlaceholderRenderLayer alloc] initWithHyperObject:[self hyperObject]];
}
@end
