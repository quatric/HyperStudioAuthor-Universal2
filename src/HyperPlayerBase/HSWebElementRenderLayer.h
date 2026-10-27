#import "HyperPlayerBasePrefix.h"
#import "HSGenericRenderLayer.h"


@interface HSWebElementRenderLayer : HSGenericRenderLayer
{
    id<HSSizeAttributes> _sizeAttributes;
    id<HSWebElementAttributes> _webElementAttributes;
}
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate;
- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce;
- (id)calculateBoundingRegion;
- (void)fillVisualizationAttributesSet:(id)aSet;
- (void)fillBoundingRegionAttributesSet:(id)aSet;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy;
@end

