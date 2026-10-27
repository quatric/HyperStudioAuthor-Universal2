#import "HyperPlayerBasePrefix.h"
#import "HSGenericRenderLayer.h"


@interface HSGenericWebPageObjectRenderLayer : HSGenericRenderLayer
{
    id<HSWebPageAttributes> _webPageAttributes;
    id<HSGeometryAttributes> _geometryAttributes;
    id<HSRenderLayer> _placeholderRenderLayer;
    id<HSRenderLayer> _webPageRenderLayer;
}
- (id)calculateBoundingRegion;
- (void)fillBoundingRegionAttributesSet:(id)aSet;
- (BOOL)requiresTransparencyLayer;
- (void)drawRenderSublayersInRegion:(id)aRegion withDelegate:(id)aDelegate;
- (void)fillVisualizationAttributesSet:(id)aSet;
- (id)webPageRenderLayer;
- (id)placeholderRenderLayer;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy;
@end

