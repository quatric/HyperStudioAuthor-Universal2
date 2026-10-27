#import "HyperPlayerBasePrefix.h"
#import "HSImageObjectVisualization.h"


@interface HSImageObjectCropVisualization : HSImageObjectVisualization
{
}
- (id)expandedShowHideTransitionRenderLayerSubtreeWithVisualizationOptions:(id)aOptions;
- (id)expandedEffectRenderLayerSubtreeWithVisualizationOptions:(id)aOptions;
- (id)multiClipRenderLayerIdentifierForVisualizationOptions:(id)aOptions;
- (id)effectPlaceholderRenderLayerIdentifierForVisualizationOptions:(id)aOptions;
- (id)effectRenderLayerIdentifierForVisualizationOptions:(id)aOptions;
- (BOOL)canBeHidden;
@end

