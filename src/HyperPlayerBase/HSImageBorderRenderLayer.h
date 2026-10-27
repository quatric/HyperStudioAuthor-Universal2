#import "HyperPlayerBasePrefix.h"
#import "HSGenericRenderLayer.h"


@interface HSImageBorderRenderLayer : HSGenericRenderLayer
{
    id<HSImageAttributes> _imageAttributes;
    id<HSBorderAttributes> _borderAttributes;
    id<HSMutableClipPathsAttributes> _mutableClipPathsAttributes;
}
- (id)calculateBoundingRegion;
- (void)fillBoundingRegionAttributesSet:(id)aSet;
- (BOOL)isEmpty;
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate;
- (struct CGPath *)HSImageBorderRenderLayer_createImageObjectBorderBezierPath;
- (void)fillVisualizationAttributesSet:(id)aSet;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy;
@end

