#import "HyperPlayerBasePrefix.h"
#import "HSGenericOptionalLayersVisualization.h"


@interface HSSystemObjectVisualization : HSGenericOptionalLayersVisualization
{
    unsigned int _drawsPlaceholderView:1;
}
- (id)expandedShowHideTransitionRenderLayerSubtreeWithVisualizationOptions:(id)aOptions;
- (id)expandedEffectRenderLayerSubtreeWithVisualizationOptions:(id)aOptions;
- (id)precreateSystemViewRenderLayerForVisualizationOptions:(id)aOptions;
- (id)systemViewRenderLayerIdentifierForVisualizationOptions:(id)aOptions;
- (id)effectPlaceholderRenderLayerIdentifierForVisualizationOptions:(id)aOptions;
- (id)effectRenderLayerIdentifierForVisualizationOptions:(id)aOptions;
- (id)showHideTransitionRenderLayerIdentifierForVisualizationOptions:(id)aOptions;
- (BOOL)drawsPlaceholderView;
- (id)initWithHyperObject:(id)aObject visualizationProtocol:(id)aProtocol drawPlaceholderView:(BOOL)aView;
- (id)initWithHyperObject:(id)aObject visualizationProtocol:(id)aProtocol;
- (BOOL)ignoresTransparency;
@end

