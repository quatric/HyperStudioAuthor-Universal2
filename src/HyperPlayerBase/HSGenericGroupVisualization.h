#import "HyperPlayerBasePrefix.h"
#import "HSGenericVisualization.h"


@interface HSGenericGroupVisualization : HSGenericVisualization
{
    id<HSNodeContainer> _nodeContainer;
    NSMutableArray *_subobjects;
    NSMapTable *_subobjectToVisualizationMap;
}
- (id)expandedRenderLayerTreeWithVisualizationOptions:(id)aOptions;
- (id)expandWithVisualSubobjectsRenderLayersRenderLayerTreeWithRoot:(id)aRoot fromRenderLayerAtPath:(id)aPath withVisualizationOptions:(id)aOptions;
- (id)precreateVisualSubobjectsRenderLayerForVisualizationOptions:(id)aOptions;
- (id)visualSubobjectsRenderLayerIdentifierForVisualizationOptions:(id)aOptions;
- (id)visualizationForSubobject:(id)aSubobject;
- (id)subobjectVisualizations;
- (id)subobjects;
- (id)HSGenericGroupVisualization_visualizationForSubobject:(id)aSubobject;
- (void)HSGenericGroupVisualization_subobjectsDidChange:(id)aChange;
- (void)HSGenericGroupVisualization_removeVisualizationsForRemovedObjects;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject visualizationProtocol:(id)aProtocol;
@end

