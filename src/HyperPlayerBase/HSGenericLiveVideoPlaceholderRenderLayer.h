#import "HyperPlayerBasePrefix.h"
#import "HSGenericRenderLayer.h"


@interface HSGenericLiveVideoPlaceholderRenderLayer : HSGenericRenderLayer
{
    id<HSLiveVideoAttributes> _liveVideoAttributes;
    id<HSVideoStreamAttributes> _videoStreamAttributes;
    HSVideoCaptureDevicePlaceholderRenderer *_placeholderRenderer;
}
- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce;
- (id)calculateBoundingRegion;
- (void)fillBoundingRegionAttributesSet:(id)aSet;
- (BOOL)requiresTransparencyLayer;
- (void)HSGenericLiveVideoPlaceholderRenderLayer_liveVideoDeviceDidChange:(id)aChange;
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate;
- (void)fillVisualizationAttributesSet:(id)aSet;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy;
@end

