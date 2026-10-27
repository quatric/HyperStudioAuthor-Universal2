#import "HyperPlayerBasePrefix.h"
#import "HSVectorGraphicsObjectVisualization.h"


@interface HSHitTestingVectorGraphicsObjectVisualization : HSVectorGraphicsObjectVisualization
{
}
- (id)expandedShowHideTransitionRenderLayerSubtreeWithVisualizationOptions:(id)aOptions;
- (id)precreateVectorGraphicsRenderLayerForVisualizationOptions:(id)aOptions;
- (id)vectorGraphicsRenderLayerIdentifierForVisualizationOptions:(id)aOptions;
- (id)effectPlaceholderRenderLayerIdentifierForVisualizationOptions:(id)aOptions;
- (id)effectRenderLayerIdentifierForVisualizationOptions:(id)aOptions;
- (id)showHideTransitionRenderLayerIdentifierForVisualizationOptions:(id)aOptions;
- (BOOL)canBeHidden;
@end

