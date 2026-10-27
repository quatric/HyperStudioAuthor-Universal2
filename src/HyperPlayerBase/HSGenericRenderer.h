#import "HyperPlayerBasePrefix.h"
#import "HSWeaklyReferencedObject.h"


@interface HSGenericRenderer : HSWeaklyReferencedObject <HSRendererUpdating, HSRenderer, NSObject, HSRenderLayerObserver>
{
    id<HSVisualizationLayering> _visualization;
    NSDictionary *_visualizationOptions;
    id<HSRenderLayer> _rootRenderLayer;
    unsigned int _isRenderLayerTreeValid:1;
}
- (void)renderLayerWantsToReexpand:(id)aReexpand;
- (void)renderLayerDidChangeBoundingRegion:(id)aRegion;
- (void)renderLayerDidChangeVisualizationMaskAttributesSet:(id)aSet;
- (void)renderLayerDidChangeVisualizationAttributesSet:(id)aSet;
- (void)invalidateRenderLayerTree;
- (void)drawRegion:(id)aRegion withDelegate:(id)aDelegate;
- (id)description;
- (BOOL)unionBoundingRegionOfAttribute:(id)aAttribute ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id)aRegion;
- (id)boundingRegionOfAttribute:(id)aAttribute ofHyperObject:(id)aObject withInfo:(id)aInfo;
- (BOOL)unionBoundingRegionOfAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id)aRegion;
- (id)boundingRegionOfAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo;
- (BOOL)unionBoundingRegionWithRegion:(id)aRegion;
- (id)boundingRegion;
- (id)rootRenderLayer;
- (BOOL)drawsOnlySubobjects;
- (id)ignoredSubobjects;
- (id)visualizationOptions;
- (id)visualization;
- (void)dealloc;
- (id)init;
- (id)initWithVisualization:(id)aVisualization options:(id)aOptions;
@end

