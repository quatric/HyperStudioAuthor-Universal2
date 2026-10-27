#import "HyperPlayerBasePrefix.h"
#import "HSGenericOptionalLayersVisualization.h"


@interface HSHeadlineObjectVisualization : HSGenericOptionalLayersVisualization
{
}
- (id)expandedEffectRenderLayerSubtreeWithVisualizationOptions:(id)aOptions;
- (id)precreateVectorRenderLayerForVisualizationOptions:(id)aOptions;
- (BOOL)ignoresTransparency;
@end

