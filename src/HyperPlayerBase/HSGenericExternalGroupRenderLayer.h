#import "HyperPlayerBasePrefix.h"
#import "HSGenericGroupRenderLayer.h"


@interface HSGenericExternalGroupRenderLayer : HSGenericGroupRenderLayer
{
    id<HSNodeChild> _nodeChild;
    id<HSGeometryAttributes> _geometryAttributes;
}
- (void)drawRenderSublayersInRegion:(id)aRegion withDelegate:(id)aDelegate;
- (id)calculateBoundingRegion;
- (void)fillBoundingRegionAttributesSet:(id)aSet;
- (void)HSGenericExternalGroupRenderLayer_siblingsDidChange:(id)aChange;
- (void)HSGenericExternalGroupRenderLayer_superobjectDidChange:(id)aChange;
- (void)HSGenericExternalGroupRenderLayer_superobjectWillChange:(id)aChange;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject renderSublayerCapacity:(NSUInteger)aCapacity cachingPolicy:(NSInteger)aPolicy;
@end

