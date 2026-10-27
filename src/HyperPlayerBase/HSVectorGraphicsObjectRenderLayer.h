#import "HyperPlayerBasePrefix.h"
#import "HSGenericRenderLayer.h"


@interface HSVectorGraphicsObjectRenderLayer : HSGenericRenderLayer
{
}
- (void)drawBackground:(id)aBackground inRect:(NSRect)aRect;
- (id)strokeColor;
- (id)hyperObject;
- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce;
- (id)calculateBoundingRegion;
- (void)fillBoundingRegionAttributesSet:(id)aSet;
- (BOOL)requiresTransparencyLayer;
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate;
- (void)fillVisualizationAttributesSet:(id)aSet;
@end

