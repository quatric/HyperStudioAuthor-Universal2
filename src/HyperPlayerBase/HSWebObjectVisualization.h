#import "HyperPlayerBasePrefix.h"
#import "HSGenericOptionalLayersVisualization.h"


@interface HSWebObjectVisualization : HSGenericOptionalLayersVisualization
{
    id<HSWebElementAttributes> _webElementAttributes;
}
- (id)expandedShowHideTransitionRenderLayerSubtreeWithVisualizationOptions:(id)aOptions;
- (id)precreateWebElementRenderLayerForVisualizationOptions:(id)aOptions;
- (id)showHideTransitionRenderLayerIdentifierForVisualizationOptions:(id)aOptions;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject visualizationProtocol:(id)aProtocol;
@end

