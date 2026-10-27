#import "HyperPlayerBasePrefix.h"
#import "HSBorderedBackgroundRenderLayer.h"


@interface HSButtonObjectShapeBackgroundRenderlayerInEditor : HSBorderedBackgroundRenderLayer
{
}
- (id)calculateBoundingRegion;
- (void)fillBoundingRegionAttributesSet:(id)aSet;
- (BOOL)requiresTransparencyLayer;
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate;
- (BOOL)isEmpty;
- (void)drawBorderIfNeededInRegion:(id)aRegion withDelegate:(id)aDelegate;
- (void)fillVisualizationAttributesSet:(id)aSet;
@end

