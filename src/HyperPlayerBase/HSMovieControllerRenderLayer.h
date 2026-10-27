#import "HyperPlayerBasePrefix.h"
#import "HSGenericRenderLayer.h"


@interface HSMovieControllerRenderLayer : HSGenericRenderLayer
{
    id<HSMovieControllerAttributes> _movieControllerAttributes;
}
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate;
- (id)calculateBoundingRegion;
- (void)fillBoundingRegionAttributesSet:(id)aSet;
- (BOOL)requiresTransparencyLayer;
- (BOOL)isEmpty;
- (void)fillVisualizationMaskAttributesSet:(id)aSet;
- (void)fillVisualizationAttributesSet:(id)aSet;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy;
- (id)initWithMovieObject:(id)aObject cachingPolicy:(NSInteger)aPolicy;
@end

