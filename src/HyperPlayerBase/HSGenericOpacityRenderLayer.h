#import "HyperPlayerBasePrefix.h"
#import "HSGenericGroupRenderLayer.h"


@interface HSGenericOpacityRenderLayer : HSGenericGroupRenderLayer
{
    id<HSOpacityAttributes> _opacityAttributes;
}
- (BOOL)unionBoundingRegionOfSublayersVisualAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion;
- (void)drawRenderSublayersInRegion:(id)aRegion withDelegate:(id)aDelegate;
- (void)fillVisualizationMaskAttributesSet:(id)aSet;
- (void)fillVisualizationAttributesSet:(id)aSet;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject renderSublayerCapacity:(NSUInteger)aCapacity cachingPolicy:(NSInteger)aPolicy;
@end

