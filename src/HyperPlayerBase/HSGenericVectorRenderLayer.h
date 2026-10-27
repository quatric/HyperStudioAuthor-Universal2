#import "HyperPlayerBasePrefix.h"
#import "HSGenericRenderLayer.h"


@interface HSGenericVectorRenderLayer : HSGenericRenderLayer
{
    id<HSVectorAttributes> _vectorAttributes;
    int _vectorRenderStyle;
}
- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce;
- (id)calculateBoundingRegion;
- (void)fillBoundingRegionAttributesSet:(id)aSet;
- (BOOL)requiresTransparencyLayer;
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate;
- (void)fillVisualizationAttributesSet:(id)aSet;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject withVectorRenderStyle:(NSInteger)aStyle cachingPolicy:(NSInteger)aPolicy;
- (id)initWithHyperObject:(id)aObject withVectorRenderStyle:(NSInteger)aStyle;
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy;
@end

