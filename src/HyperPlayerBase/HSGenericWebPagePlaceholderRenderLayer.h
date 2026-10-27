#import "HyperPlayerBasePrefix.h"
#import "HSGenericRenderLayer.h"


@interface HSGenericWebPagePlaceholderRenderLayer : HSGenericRenderLayer
{
    id<HSWebPageAttributes> _webPageAttributes;
    id<HSGeometryAttributes> _geometryAttributes;
}
- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce;
- (id)calculateBoundingRegion;
- (void)fillBoundingRegionAttributesSet:(id)aSet;
- (BOOL)requiresTransparencyLayer;
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate;
- (void)getPlaceholderLabel:(id *)aLabel icon:(id *)aIcon;
- (void)fillVisualizationAttributesSet:(id)aSet;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy;
@end

