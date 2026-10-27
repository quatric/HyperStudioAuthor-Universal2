#import "HSYouTubeRenderLayer.h"
// A YouTube object's current frame.
@implementation HSYouTubeRenderLayer
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate
{
    NSRect rect = [_youTubeAttributes youTubeRect];
    [[_youTubeAttributes youTubeRenderer] drawCurrentFrameInRect:rect];
}
- (id)calculateBoundingRegion
{
    return [HSRegion regionWithRect:[_youTubeAttributes youTubeRect]];
}
- (void)fillBoundingRegionAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSYouTubeRectAttribute) forObject:[self hyperObject]];
}
- (BOOL)requiresTransparencyLayer
{
    return NO;
}
- (void)fillVisualizationAttributesSet:(id)aSet
{
    id hyperObject = [self hyperObject];
    [aSet addAttribute:@protocol(HSYouTubeRectAttribute) forObject:hyperObject];
    [aSet addAttribute:@protocol(HSYouTubeFrameContentAttribute) forObject:hyperObject];
}
- (void)dealloc
{
    [_youTubeAttributes release];
    [super dealloc];
}
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject cachingPolicy:aPolicy];
    if (self != nil) {
        _youTubeAttributes = [[aObject queryHyperInterface:@protocol(HSYouTubeAttributes)] retain];
        if (_youTubeAttributes == nil) {
            [self release];
            self = nil;
        }
    }
    return self;
}
@end
