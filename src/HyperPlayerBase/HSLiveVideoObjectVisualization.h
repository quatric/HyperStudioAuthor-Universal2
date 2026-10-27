#import "HyperPlayerBasePrefix.h"
#import "HSGenericOptionalLayersVisualization.h"


@interface HSLiveVideoObjectVisualization : HSGenericOptionalLayersVisualization
{
}
- (id)expandedEffectRenderLayerSubtreeWithVisualizationOptions:(id)aOptions;
- (id)precreateVideoStreamObjectRenderLayerForVisualizationOptions:(id)aOptions;
- (id)precreateLiveVideoPlaceholderRenderLayerForVisualizationOptions:(id)aOptions;
@end

