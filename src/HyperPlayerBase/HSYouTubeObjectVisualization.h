#import "HyperPlayerBasePrefix.h"
#import "HSGenericOptionalLayersVisualization.h"


@interface HSYouTubeObjectVisualization : HSGenericOptionalLayersVisualization
{
}
- (id)expandedShadowAndOpacityRenderLayerSubtreeWithVisualizationOptions:(id)aOptions;
- (id)expandedEffectRenderLayerSubtreeWithVisualizationOptions:(id)aOptions;
- (id)precreateYouTubeRenderLayerForVisualizationOptions:(id)aOptions;
- (id)precreateShadowAndOpacityRenderLayerForVisualizationOptions:(id)aOptions;
- (BOOL)ignoresTransparency;
@end

