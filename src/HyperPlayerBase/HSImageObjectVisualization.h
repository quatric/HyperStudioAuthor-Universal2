#import "HyperPlayerBasePrefix.h"
#import "HSGenericOptionalLayersVisualization.h"


@interface HSImageObjectVisualization : HSGenericOptionalLayersVisualization
{
}
- (id)expandedEffectRenderLayerSubtreeWithVisualizationOptions:(id)aOptions;
- (id)precreateMultiClipRenderLayerForVisualizationOptions:(id)aOptions;
- (id)multiClipRenderLayerIdentifierForVisualizationOptions:(id)aOptions;
- (id)precreateImageBorderRenderLayerForVisualizationOptions:(id)aOptions;
- (id)precreateImageRenderLayerForVisualizationOptions:(id)aOptions;
@end

