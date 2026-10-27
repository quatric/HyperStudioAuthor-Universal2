#import "HSTransparencyRenderLayer.h"
// A group drawn through a cache of its own (a transparency layer) while the
// context asks for one and the group needs it.
@implementation HSTransparencyRenderLayer
- (BOOL)cacheRenderingInRegion:(id)aRegion forAffineTransform:(CGAffineTransform)aTransform withTransformationIntent:(struct HyperPlayerBase_anon12 *)aIntent acceptableValidnessLimit:(CGFloat)aLimit delegate:(id)aDelegate force:(BOOL)aForce share:(BOOL)aShare resultCache:(id *)aCache
{
    _isCreatingRenderCache = YES;
    BOOL result = [super cacheRenderingInRegion:aRegion forAffineTransform:aTransform withTransformationIntent:(void *)aIntent
                       acceptableValidnessLimit:aLimit delegate:aDelegate force:aForce share:aShare resultCache:aCache];
    _isCreatingRenderCache = NO;
    return result;
}
- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce
{
    if (aForce)
        return YES;
    return [super requiresTransparencyLayer];
}
- (void)drawRegion:(id)aRegion withDelegate:(id)aDelegate
{
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    if (!_isCreatingRenderCache && [context isHyperTransparencyLayerRequested] && [super requiresTransparencyLayer]) {
        id cache = nil;
        NSDictionary *info = [aDelegate renderLayerWillCacheDrawingInRegion:aRegion];
        CGAffineTransform transform = CGContextGetCTM([context CGContext]);
        BOOL exclusive = [[info objectForKey:@"HSExclusiveRenderCacheKey"] boolValue];
        [self cacheRenderingInRegion:aRegion forAffineTransform:transform withTransformationIntent:NULL
            acceptableValidnessLimit:0.0001f delegate:aDelegate force:YES share:!exclusive resultCache:&cache];
        [aDelegate renderLayerDidCacheDrawingInRegion:aRegion intoRenderCache:cache];
        [cache drawRegion:aRegion];
        return;
    }
    [super drawRegion:aRegion withDelegate:aDelegate];
}
// Only through the cache above.
- (BOOL)requiresTransparencyLayer
{
    return NO;
}
@end

// Nested requests for transparency layers, counted per context.
@implementation NSGraphicsContext (HSTransparencyRenderLayer)
+ (id)NSGraphicsContext_HSTransparencyRenderLayer_transparencyLayerRequests
{
    static NSMapTable *requests = nil;
    if (requests == nil)
        requests = NSCreateMapTable(NSNonOwnedPointerMapKeyCallBacks, NSIntegerMapValueCallBacks, 0);
    return requests;
}
- (BOOL)isHyperTransparencyLayerRequested
{
    NSMapTable *requests = [[self class] NSGraphicsContext_HSTransparencyRenderLayer_transparencyLayerRequests];
    return requests != nil && NSMapGet(requests, self) != NULL;
}
- (void)endHyperTransparencyLayerRequest
{
    NSMapTable *requests = [[self class] NSGraphicsContext_HSTransparencyRenderLayer_transparencyLayerRequests];
    if (requests == nil)
        return;
    intptr_t count = (intptr_t)NSMapGet(requests, self);
    if (count == 1)
        NSMapRemove(requests, self);
    else if (count != 0)
        NSMapInsert(requests, self, (void *)(count - 1));
}
- (void)beginHyperTransparencyLayerRequest
{
    NSMapTable *requests = [[self class] NSGraphicsContext_HSTransparencyRenderLayer_transparencyLayerRequests];
    if (requests != nil)
        NSMapInsert(requests, self, (void *)((intptr_t)NSMapGet(requests, self) + 1));
}
@end
