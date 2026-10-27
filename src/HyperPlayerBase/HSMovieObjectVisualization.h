#import "HyperPlayerBasePrefix.h"
#import "HSGenericOptionalLayersVisualization.h"


@interface HSMovieObjectVisualization : HSGenericOptionalLayersVisualization
{
}
- (id)expandedShadowAndOpacityRenderLayerSubtreeWithVisualizationOptions:(id)aOptions;
- (id)expandedEffectRenderLayerSubtreeWithVisualizationOptions:(id)aOptions;
- (id)precreateMovieControllerRenderLayerForVisualizationOptions:(id)aOptions;
- (id)precreateMovieRenderLayerForVisualizationOptions:(id)aOptions;
- (id)precreateMovieGroupRenderLayerForVisualizationOptions:(id)aOptions;
@end

