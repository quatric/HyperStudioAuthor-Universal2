#import "HyperPlayerBasePrefix.h"
#import "HSGenericOptionalLayersVisualization.h"


@interface HSWebPageObjectVisualization : HSGenericOptionalLayersVisualization
{
}
- (id)expandedEffectRenderLayerSubtreeWithVisualizationOptions:(id)aOptions;
- (id)precreateWebPageObjectRenderLayerForVisualizationOptions:(id)aOptions;
- (BOOL)ignoresTransparency;
@end

