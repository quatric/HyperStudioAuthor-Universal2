#import "HSGenericWebPageObjectRenderLayer.h"
// A web page object: the page once loaded (or a picture of it), the
// placeholder before.
@implementation HSGenericWebPageObjectRenderLayer
- (id)calculateBoundingRegion
{
    return [HSRegion regionWithRect:[_geometryAttributes boundingRect]];
}
- (void)fillBoundingRegionAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSSizeAttribute) forObject:[self hyperObject]];
}
- (BOOL)requiresTransparencyLayer
{
    if ([_webPageAttributes loadState] == 3)
        return [[self webPageRenderLayer] requiresTransparencyLayer];
    return [[self placeholderRenderLayer] requiresTransparencyLayer];
}
- (void)drawRenderSublayersInRegion:(id)aRegion withDelegate:(id)aDelegate
{
    id layer;
    if ([_webPageAttributes loadState] == 3 || [_webPageAttributes webPageImage] != nil)
        layer = [self webPageRenderLayer];
    else
        layer = [self placeholderRenderLayer];
    [layer drawRegion:aRegion withDelegate:aDelegate];
}
- (void)fillVisualizationAttributesSet:(id)aSet
{
    id object = [self hyperObject];
    [aSet addAttribute:@protocol(HSWebPageContentAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSWebPageLoadStateAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSWebPageCropPathAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSWebPageRectAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSSizeAttribute) forObject:object];
}
- (id)webPageRenderLayer
{
    if (_webPageRenderLayer == nil)
        _webPageRenderLayer = [[HSGenericWebPageRenderLayer alloc] initWithHyperObject:[self hyperObject]];
    return _webPageRenderLayer;
}
- (id)placeholderRenderLayer
{
    if (_placeholderRenderLayer == nil)
        _placeholderRenderLayer = [[HSGenericWebPagePlaceholderRenderLayer alloc] initWithHyperObject:[self hyperObject]];
    return _placeholderRenderLayer;
}
- (void)dealloc
{
    [_webPageAttributes release];
    [_geometryAttributes release];
    [_placeholderRenderLayer release];
    [_webPageRenderLayer release];
    [super dealloc];
}
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject cachingPolicy:aPolicy];
    if (self != nil) {
        _webPageAttributes = [[aObject queryHyperInterface:@protocol(HSWebPageAttributes)] retain];
        if (_webPageAttributes != nil) {
            _geometryAttributes = [[aObject queryHyperInterface:@protocol(HSGeometryAttributes)] retain];
            if (_geometryAttributes != nil)
                return self;
        }
        [self release];
    }
    return nil;
}
@end
