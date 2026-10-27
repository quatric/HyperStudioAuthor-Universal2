#import "HyperPlayerBasePrefix.h"
#import "HSGenericRenderLayer.h"


@interface HSGenericWebPageRenderLayer : HSGenericRenderLayer
{
    id<HSWebPageAttributes> _webPageAttributes;
}
- (id)calculateBoundingRegion;
- (void)fillBoundingRegionAttributesSet:(id)aSet;
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate;
- (void)fillVisualizationAttributesSet:(id)aSet;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy;
@end

