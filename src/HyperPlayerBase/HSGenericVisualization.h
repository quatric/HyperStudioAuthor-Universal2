#import "HyperPlayerBasePrefix.h"


@interface HSGenericVisualization : NSObject <HSVisualizationLayering, HSVisualization, HyperInterface, NSObject, HSWeakReferencer>
{
    id _hyperObject;
    Protocol *_visualizationProtocol;
    struct __CFDictionary *_visualizationOptionsToRendererMap;
    unsigned int _renderLayersExpandingCounter;
    struct __CFArray *_renderLayersWithSublayersOperationGroups;
}
+ (void)unassignRenderLayer:(id)aLayer;
+ (void)unassignRenderLayerForIdentifier:(id)aIdentifier forHyperObject:(id)aObject;
+ (id)renderLayerForIdentifier:(id)aIdentifier forHyperObject:(id)aObject;
+ (void)assignRenderLayer:(id)aLayer forIdentifier:(id)aIdentifier;
+ (id)HSGenericVisualization_renderLayerAssigner;
- (id)expandableRenderLayerWithIdentifier:(id)aIdentifier precreateSelector:(SEL)aSelector visualizationOptions:(id)aOptions;
- (id)renderLayerWithIdentifier:(id)aIdentifier precreateSelector:(SEL)aSelector visualizationOptions:(id)aOptions;
- (id)expandableRenderLayerForIdentifier:(id)aIdentifier;
- (id)renderLayerForIdentifier:(id)aIdentifier;
- (void)prepareRenderLayerForExpanding:(id)aExpanding;
- (void)endExpandingRenderLayers;
- (void)beginExpandingRenderLayers;
- (id)expandRenderLayerTreeWithRoot:(id)aRoot fromRenderLayerAtPath:(id)aPath withVisualizationOptions:(id)aOptions;
- (id)buildRenderLayerTreeWithVisualizationOptions:(id)aOptions;
- (id)expandedRenderLayerTreeWithVisualizationOptions:(id)aOptions;
- (id)renderLayerIdentifierAppendingSuffixForVisualizationOptions:(id)aOptions toBaseIdentifier:(id)aIdentifier;
- (id)existingRenders;
- (id)existingRendererWithVisualizationOptions:(id)aOptions;
- (id)createRendererWithVisualizationOptions:(id)aOptions;
- (id)queryRendererWithVisualizationOptions:(id)aOptions;
- (id)queryRenderer;
- (id)visualizationForSubobject:(id)aSubobject;
- (id)subobjectVisualizations;
- (id)subobjects;
- (id)visualizationProtocol;
- (id)implementationForHyperObject:(id)aObject;
- (BOOL)implementsHyperInterface:(id)aInterface;
- (id)queryHyperInterface:(id)aInterface;
- (id)hyperObject;
- (id)description;
- (void)dereferenceObject:(id)aObject;
- (void)dealloc;
- (id)init;
- (id)initWithHyperObject:(id)aObject visualizationProtocol:(id)aProtocol;
- (id)HSGenericVisualization_rendererIdentifierForVisualizationOptions:(id)aOptions;
@end

@interface HSGenericVisualization_HSRenderLayerAssigner : NSObject <HSWeakReferencer>
{
    NSMapTable *_hyperObjectToRenderLayersMap;
    NSMapTable *_renderLayerToHyperObjectMap;
    NSMapTable *_renderLayerToIdentifiersMap;
}
- (void)unassignRenderLayer:(id)aLayer;
- (void)unassignRenderLayerForIdentifier:(id)aIdentifier forHyperObject:(id)aObject;
- (id)renderLayerForIdentifier:(id)aIdentifier forHyperObject:(id)aObject;
- (void)assignRenderLayer:(id)aLayer forIdentifier:(id)aIdentifier;
- (void)dereferenceObject:(id)aObject;
- (void)dealloc;
@end

