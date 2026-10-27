#import "HSWebElementRenderLayer.h"
// A web element's page, drawn flipped.
@implementation HSWebElementRenderLayer
// Original quirk kept: the clip rect's origin is flipped without its height.
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate
{
    NSSize size = [_sizeAttributes size];
    NSRect rect = NSMakeRect(0, 0, size.width, size.height);
    NSRect clip = [aRegion boundingRect];
    float flippedHeight = rect.origin.y + rect.origin.y + rect.size.height;
    CGContextConcatCTM([[NSGraphicsContext currentContext] CGContext], CGAffineTransformMake(1, 0, 0, -1, 0, flippedHeight));
    clip.origin.y = flippedHeight - clip.origin.y;
    [_webElementAttributes drawInRect:rect clipToRect:clip];
}
// Cached unless refreshed every second or more often.
- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce
{
    return (float)[_webElementAttributes refreshRate] < 1.0f;
}
- (id)calculateBoundingRegion
{
    NSSize size = [_sizeAttributes size];
    return [HSRegion regionWithRect:NSMakeRect(0, 0, size.width, size.height)];
}
- (void)fillVisualizationAttributesSet:(id)aSet
{
    id hyperObject = [self hyperObject];
    [aSet addAttribute:@protocol(HSSizeAttribute) forObject:hyperObject];
    [aSet addAttribute:@protocol(HSWebElementContentAttribute) forObject:hyperObject];
}
- (void)fillBoundingRegionAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSSizeAttribute) forObject:[self hyperObject]];
}
- (void)dealloc
{
    [_webElementAttributes release];
    [_sizeAttributes release];
    [super dealloc];
}
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject cachingPolicy:aPolicy];
    if (self != nil) {
        _sizeAttributes = [[aObject queryHyperInterface:@protocol(HSSizeAttributes)] retain];
        if (_sizeAttributes != nil) {
            _webElementAttributes = [[aObject queryHyperInterface:@protocol(HSWebElementAttributes)] retain];
            if (_webElementAttributes != nil)
                return self;
        }
        [self release];
    }
    return nil;
}
@end
