#import "HyperPlayerBasePrefix.h"
#import "HSGenericVisualization.h"


@interface HSGenericOptionalLayersVisualization : HSGenericVisualization
{
}
- (id)expandedRenderLayerTreeWithVisualizationOptions:(id)aOptions;
- (id)expandedShowHideTransitionRenderLayerSubtreeWithVisualizationOptions:(id)aOptions;
- (id)expandedShadowAndOpacityRenderLayerSubtreeWithVisualizationOptions:(id)aOptions;
- (id)expandedEffectRenderLayerSubtreeWithVisualizationOptions:(id)aOptions;
- (id)effectRenderLayerWithVisualizationOptions:(id)aOptions;
- (id)precreateEffectPlaceholderRenderLayerForVisualizationOptions:(id)aOptions;
- (id)effectPlaceholderRenderLayerIdentifierForVisualizationOptions:(id)aOptions;
- (id)precreateEffectRenderLayerForVisualizationOptions:(id)aOptions;
- (id)effectRenderLayerIdentifierForVisualizationOptions:(id)aOptions;
- (BOOL)hasEffectPerObject;
- (BOOL)supportsEffectPerObject;
- (id)shadowAndOpacityRenderLayerWithVisualizationOptions:(id)aOptions;
- (id)precreateShadowAndOpacityRenderLayerForVisualizationOptions:(id)aOptions;
- (id)shadowAndOpacityRenderLayerIdentifierForVisualizationOptions:(id)aOptions;
- (id)opacityRenderLayerWithVisualizationOptions:(id)aOptions;
- (id)precreateOpacityRenderLayerForVisualizationOptions:(id)aOptions;
- (id)opacityRenderLayerIdentifierForVisualizationOptions:(id)aOptions;
- (id)showHideTransitionRenderLayerWithVisualizationOptions:(id)aOptions;
- (id)precreateShowHideTransitionRenderLayerForVisualizationOptions:(id)aOptions;
- (id)showHideTransitionRenderLayerIdentifierForVisualizationOptions:(id)aOptions;
- (BOOL)ignoresTransparency;
- (BOOL)canBeHidden;
@end

