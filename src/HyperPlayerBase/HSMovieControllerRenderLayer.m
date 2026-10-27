#import "HSMovieControllerRenderLayer.h"
// A movie object's controller bar, when it has a usable one.
@implementation HSMovieControllerRenderLayer
// Drawn flipped within the controller rect.
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate
{
    id object = [self hyperObject];
    if ([object hasController] && [object hyperCanUseController]) {
        NSRect rect = [_movieControllerAttributes movieControllerRect];
        CGAffineTransform flip = CGAffineTransformMake(1, 0, 0, -1, 0, (float)(rect.size.height + rect.origin.y + rect.origin.y));
        [[NSAffineTransform transformWithHyperCGAffineTransform:flip] concat];
        [[object movieWithController] drawController:rect];
    }
}
- (id)calculateBoundingRegion
{
    return [HSRegion regionWithRect:[_movieControllerAttributes movieControllerRect]];
}
- (void)fillBoundingRegionAttributesSet:(id)aSet
{
    id object = [self hyperObject];
    [aSet addAttribute:@protocol(HSMovieControllerRectAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSMovieObjectCanUseControllerAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSMovieObjectHasControllerAttribute) forObject:object];
}
- (BOOL)requiresTransparencyLayer
{
    id object = [self hyperObject];
    return [object hasController] && [object hyperCanUseController];
}
- (BOOL)isEmpty
{
    id object = [self hyperObject];
    return ![object hasController] || ![object hyperCanUseController];
}
- (void)fillVisualizationMaskAttributesSet:(id)aSet
{
    id object = [self hyperObject];
    [aSet addAttribute:@protocol(HSMovieObjectCanUseControllerAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSMovieObjectHasControllerAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSMovieControllerRectAttribute) forObject:object];
}
- (void)fillVisualizationAttributesSet:(id)aSet
{
    id object = [self hyperObject];
    [aSet addAttribute:@protocol(HSMovieObjectCanUseControllerAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSMovieObjectHasControllerAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSMovieControllerRectAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSMovieControllerVisualStateAttribute) forObject:object];
}
- (void)dealloc
{
    [_movieControllerAttributes release];
    [super dealloc];
}
// Movie objects only.
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy
{
    if (![aObject isKindOfClass:[HSMovieObject class]]) {
        [self release];
        return nil;
    }
    return [self initWithMovieObject:aObject cachingPolicy:aPolicy];
}
- (id)initWithMovieObject:(id)aObject cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject cachingPolicy:aPolicy];
    if (self != nil) {
        _movieControllerAttributes = [[aObject queryHyperInterface:@protocol(HSMovieControllerAttributes)] retain];
        if (_movieControllerAttributes == nil) {
            [self release];
            return nil;
        }
    }
    return self;
}
@end
