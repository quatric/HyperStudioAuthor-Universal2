#import "HyperPlayerBasePrefix.h"
#import "HSGenericOptionalLayersVisualization.h"


@interface HSButtonObjectVisualization : HSGenericOptionalLayersVisualization
{
}
- (Class)backgroundRenderLayerClass;
- (id)expandedShowHideTransitionRenderLayerSubtreeWithVisualizationOptions:(id)aOptions;
- (id)expandedEffectRenderLayerSubtreeWithVisualizationOptions:(id)aOptions;
- (id)precreateContentCellRenderLayerForVisualizationOptions:(id)aOptions;
- (id)precreateButtonObjectBackgroundRenderLayerForVisualizationOptions:(id)aOptions;
- (id)precreateButtonGroupRenderLayerForVisualizationOptions:(id)aOptions;
- (id)buttonGroupRenderLayerIdentifierForVisualizationOptions:(id)aOptions;
- (id)effectPlaceholderRenderLayerIdentifierForVisualizationOptions:(id)aOptions;
- (id)effectRenderLayerIdentifierForVisualizationOptions:(id)aOptions;
- (id)showHideTransitionRenderLayerIdentifierForVisualizationOptions:(id)aOptions;
- (id)HSButtonObjectVisualization_visualizationIdentifierWithGenericIdentifier:(id)aIdentifier;
- (BOOL)ignoresTransparency;
@end

