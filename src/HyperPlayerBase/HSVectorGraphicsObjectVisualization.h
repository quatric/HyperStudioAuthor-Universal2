#import "HyperPlayerBasePrefix.h"
#import "HSGenericOptionalLayersVisualization.h"


@interface HSVectorGraphicsObjectVisualization : HSGenericOptionalLayersVisualization
{
}
- (id)expandedEffectRenderLayerSubtreeWithVisualizationOptions:(id)aOptions;
- (id)precreateVectorGraphicsRenderLayerForVisualizationOptions:(id)aOptions;
- (id)vectorGraphicsRenderLayerIdentifierForVisualizationOptions:(id)aOptions;
@end

