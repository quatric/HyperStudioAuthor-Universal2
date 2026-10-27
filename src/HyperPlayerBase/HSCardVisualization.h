#import "HyperPlayerBasePrefix.h"
#import "HSGenericGroupVisualization.h"


@interface HSCardVisualization : HSGenericGroupVisualization
{
}
- (id)expandedRenderLayerTreeWithVisualizationOptions:(id)aOptions;
- (id)precreateCardRootRenderLayerForVisualizationOptions:(id)aOptions;
- (id)precreateBackgroundRenderLayerForVisualizationOptions:(id)aOptions;
- (id)precreateVisualSubobjectsRenderLayerForVisualizationOptions:(id)aOptions;
- (id)visualSubobjectsRenderLayerIdentifierForVisualizationOptions:(id)aOptions;
- (id)cardRootRenderLayerIdentifierForVisualizationOptions:(id)aOptions;
@end

