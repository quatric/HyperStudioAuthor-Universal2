#import "HyperPlayerBasePrefix.h"
#import "HSGenericRenderLayer.h"


@interface HSBorderedBackgroundRenderLayer : HSGenericRenderLayer
{
    id<HSBackgroundAttributes> _backgroundAttributes;
    id<HSButtonObjectBorderAttributes> _borderAttributes;
    id<HSGeometryAttributes> _geometryAttributes;
    id<HSButtonObjectAttributes> _buttonAttributes;
    id<HSCardObjectAttributes> _cardObjectAttributes;
}
- (void)drawBorderIfNeededInRegion:(id)aRegion withDelegate:(id)aDelegate;
- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce;
- (id)calculateBoundingRegion;
- (void)fillBoundingRegionAttributesSet:(id)aSet;
- (BOOL)requiresTransparencyLayer;
- (BOOL)isEmpty;
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate;
- (void)fillVisualizationAttributesSet:(id)aSet;
- (id)cardObjectAttributes;
- (id)buttonAttributes;
- (id)geometryAttributes;
- (id)borderAttributes;
- (id)backgroundAttributes;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy;
@end

