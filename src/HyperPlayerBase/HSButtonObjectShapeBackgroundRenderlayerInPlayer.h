#import "HyperPlayerBasePrefix.h"
#import "HSBorderedBackgroundRenderLayer.h"


@interface HSButtonObjectShapeBackgroundRenderlayerInPlayer : HSBorderedBackgroundRenderLayer
{
}
+ (void)renderInvisibleButtonBorderPath:(id)aPath forShapeButtonType:(id)aType;
+ (void)renderButtonBorderPath:(id)aPath forShapeButtonType:(id)aType;
- (BOOL)isEmpty;
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate;
- (void)drawBorderIfNeededInRegion:(id)aRegion withDelegate:(id)aDelegate;
- (void)fillVisualizationAttributesSet:(id)aSet;
@end

