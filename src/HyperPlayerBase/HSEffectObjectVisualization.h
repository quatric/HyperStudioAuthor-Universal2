#import "HyperPlayerBasePrefix.h"
#import "HSGenericVisualization.h"


@interface HSEffectObjectVisualization : HSGenericVisualization
{
    id<HSNodeChild> _nodeChild;
    id<HSExpandableRenderLayer> *_rootRenderLayerPointer;
    unsigned int _isInReplaceMode:1;
}
- (id)expandRenderLayerTreeWithRoot:(id)aRoot fromRenderLayerAtPath:(id)aPath withVisualizationOptions:(id)aOptions;
- (id)expandedRenderLayerTreeWithVisualizationOptions:(id)aOptions;
- (id)precreateEffectSourceAreaInverseClipExternalGroupRenderLayerForVisualizationOptions:(id)aOptions;
- (id)precreateEffectSourceAreaInverseClipRenderLayerForVisualizationOptions:(id)aOptions;
- (id)precreateEffectSourceAreaExternalGroupRenderLayerForVisualizationOptions:(id)aOptions;
- (id)precreateEffectSourceAreaRenderLayerForVisualizationOptions:(id)aOptions;
- (id)precreateEffectRenderLayerForVisualizationOptions:(id)aOptions;
- (id)effectRenderLayerIdentifierForVisualizationOptions:(id)aOptions;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject visualizationProtocol:(id)aProtocol inReplaceMode:(BOOL)aMode;
- (id)initWithHyperObject:(id)aObject visualizationProtocol:(id)aProtocol;
- (BOOL)ignoresTransparency;
@end

