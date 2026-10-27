#import "HyperPlayerBasePrefix.h"
#import "HSGenericOptionalLayersVisualization.h"


@interface HSTextObjectVisualization : HSGenericOptionalLayersVisualization
{
}
- (id)expandedEffectRenderLayerSubtreeWithVisualizationOptions:(id)aOptions;
- (id)precreateTextRenderLayerForVisualizationOptions:(id)aOptions;
- (BOOL)ignoresTransparency;
@end

