#import "HyperPlayerBasePrefix.h"
#import "HSGenericRenderLayer.h"


@interface HSYouTubeRenderLayer : HSGenericRenderLayer
{
    id<HSYouTubeAttributes> _youTubeAttributes;
}
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate;
- (id)calculateBoundingRegion;
- (void)fillBoundingRegionAttributesSet:(id)aSet;
- (BOOL)requiresTransparencyLayer;
- (void)fillVisualizationAttributesSet:(id)aSet;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy;
@end

