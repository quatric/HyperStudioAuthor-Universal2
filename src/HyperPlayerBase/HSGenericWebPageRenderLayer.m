#import "HSGenericWebPageRenderLayer.h"
@implementation HSGenericWebPageRenderLayer
- (id)calculateBoundingRegion
{
    return [HSRegion regionWithRect:[_webPageAttributes webPageRect]];
}
- (void)fillBoundingRegionAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSWebPageRectAttribute) forObject:[self hyperObject]];
}
// The page renderer draws flipped into the page rect; with a crop path the
// path's bounds are scaled onto the page rect and the page drawn at full
// size, clipped to the path.
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate
{
    NSRect rect = [_webPageAttributes webPageRect];
    NSBezierPath *cropPath = [_webPageAttributes webPageCropPath];
    CGAffineTransform flip = { 1, 0, 0, -1, 0, (CGFloat)(rect.size.height + rect.origin.y * 2.0) };
    [[NSAffineTransform transformWithHyperCGAffineTransform:flip] concat];
    if (cropPath != nil) {
        NSRect bounds = [cropPath bounds];
        float scaleX = bounds.size.width != 0 ? rect.size.width / bounds.size.width : 1.0f;
        float scaleY = bounds.size.height != 0 ? rect.size.height / bounds.size.height : 1.0f;
        CGAffineTransform scale = { scaleX, 0, 0, scaleY, rect.origin.x - bounds.origin.x * scaleX, rect.origin.y - bounds.origin.y * scaleY };
        [[NSAffineTransform transformWithHyperCGAffineTransform:scale] concat];
        rect.origin = NSZeroPoint;
        rect.size = [_webPageAttributes webPageSize];
        [cropPath addClip];
    }
    [[_webPageAttributes webPageRenderer] drawInRect:rect];
}
- (void)fillVisualizationAttributesSet:(id)aSet
{
    id hyperObject = [self hyperObject];
    [aSet addAttribute:@protocol(HSWebPageContentAttribute) forObject:hyperObject];
    [aSet addAttribute:@protocol(HSWebPageLoadStateAttribute) forObject:hyperObject];
    [aSet addAttribute:@protocol(HSWebPageCropPathAttribute) forObject:hyperObject];
    [aSet addAttribute:@protocol(HSWebPageRectAttribute) forObject:hyperObject];
    [aSet addAttribute:@protocol(HSSizeAttribute) forObject:hyperObject];
}
- (void)dealloc
{
    [_webPageAttributes release];
    [super dealloc];
}
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject cachingPolicy:aPolicy];
    if (self != nil) {
        _webPageAttributes = [[aObject queryHyperInterface:@protocol(HSWebPageAttributes)] retain];
        if (_webPageAttributes == nil) {
            [self release];
            return nil;
        }
    }
    return self;
}
@end
