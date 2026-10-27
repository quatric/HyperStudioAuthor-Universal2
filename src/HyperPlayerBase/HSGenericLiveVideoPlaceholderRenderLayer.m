#import "HSGenericLiveVideoPlaceholderRenderLayer.h"
// A live video object while its camera isn't running: the device's
// placeholder picture in the video rect.
@implementation HSGenericLiveVideoPlaceholderRenderLayer
- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce
{
    return YES;
}
- (id)calculateBoundingRegion
{
    return [HSRegion regionWithRect:[_videoStreamAttributes videoRect]];
}
- (void)fillBoundingRegionAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSVideoRectAttribute) forObject:[self hyperObject]];
}
- (BOOL)requiresTransparencyLayer
{
    return YES;
}
- (void)HSGenericLiveVideoPlaceholderRenderLayer_liveVideoDeviceDidChange:(id)aChange
{
    [_placeholderRenderer release];
    _placeholderRenderer = nil;
}
// Flipped within the video rect.
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate
{
    if (_placeholderRenderer == nil) {
        _placeholderRenderer = [[HSVideoCaptureDevicePlaceholderRenderer placeholderRendererForVideoCaptureDevice:[_liveVideoAttributes liveVideoDevice]] retain];
        if (_placeholderRenderer == nil)
            return;
    }
    NSRect rect = [_videoStreamAttributes videoRect];
    CGContextConcatCTM([[NSGraphicsContext currentContext] CGContext],
                       CGAffineTransformMake(1, 0, 0, -1, 0, rect.size.height + rect.origin.y + rect.origin.y));
    [_placeholderRenderer drawRect:[aRegion boundingRect] withBounds:rect];
}
- (void)fillVisualizationAttributesSet:(id)aSet
{
    id object = [self hyperObject];
    [aSet addAttribute:@protocol(HSVideoRectAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSVideoFrameAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSLiveVideoDeviceAttribute) forObject:object];
}
- (void)dealloc
{
    [[_liveVideoAttributes attributeObservingController] removeObserver:self selector:@selector(HSGenericLiveVideoPlaceholderRenderLayer_liveVideoDeviceDidChange:)
                                                              ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSLiveVideoDeviceAttribute)];
    [_placeholderRenderer release];
    [_videoStreamAttributes release];
    [_liveVideoAttributes release];
    [super dealloc];
}
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject cachingPolicy:aPolicy];
    if (self != nil) {
        _liveVideoAttributes = [[aObject queryHyperInterface:@protocol(HSLiveVideoAttributes)] retain];
        if (_liveVideoAttributes != nil) {
            _videoStreamAttributes = [[aObject queryHyperInterface:@protocol(HSVideoStreamAttributes)] retain];
            if (_videoStreamAttributes != nil) {
                [[_liveVideoAttributes attributeObservingController] addObserver:self selector:@selector(HSGenericLiveVideoPlaceholderRenderLayer_liveVideoDeviceDidChange:)
                                                                       ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSLiveVideoDeviceAttribute) withPriority:0.25f];
                return self;
            }
        }
        [self release];
    }
    return nil;
}
@end
