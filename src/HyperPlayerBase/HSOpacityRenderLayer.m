#import "HSOpacityRenderLayer.h"

// Draws its content layer at the object's opacity; content that needs a
// transparency layer is first rendered into a cache.
@implementation HSOpacityRenderLayer
- (void)renderLayerWantsToReexpand:(id)aReexpand
{
    [self notifyObserversWithSelector:@selector(renderLayerWantsToReexpand:)];
}
- (void)renderLayerDidChangeBoundingRegion:(id)aRegion
{
    [self boundingRegionDidChange];
}
- (void)renderLayerDidChangeVisualizationMaskAttributesSet:(id)aSet
{
    [self visualizationMaskAttributesSetDidChange:nil];
}
- (void)renderLayerDidChangeVisualizationAttributesSet:(id)aSet
{
    [self visualizationAttributesSetDidChange:nil];
}
- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce
{
    return aForce && ![self isEmpty];
}
// The opacity is also published to sublayers as the context's alpha
// attachment. The original sets the context alpha outside the saved
// graphics state, so it outlives this call; kept.
- (void)drawRenderSublayersInRegion:(id)aRegion withDelegate:(id)aDelegate
{
    if (!_contentRenderLayer)
        return;
    float opacity = (float)[_opacityAttributes hyperOpacity];
    if (opacity >= -0.001f && opacity <= 0.001f)
        return;
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetAlpha(context, opacity);
    CFNumberRef alpha = CFNumberCreate(kCFAllocatorDefault, kCFNumberFloatType, &opacity);
    if (!alpha)
        return;
    CFStringRef key = (CFStringRef)kCGEContextAlphaAttachmentKey;
    CFTypeRef savedAlpha = CGEContextGetAttachmentForKey(context, key);
    if (savedAlpha)
        CFRetain(savedAlpha);
    CGEContextSetAttachmentForKey(context, key, alpha);
    CFRelease(alpha);
    id delegate = [aDelegate delegateForRenderSublayerAtIndex:0];
    BOOL draw;
    if (!delegate) {
        [NSGraphicsContext saveGraphicsState];
        draw = YES;
    } else {
        if (![delegate renderLayerShouldBeRenderedInRegion:aRegion])
            goto restoreAlpha;
        [NSGraphicsContext saveGraphicsState];
        draw = [delegate renderLayerShouldBeDrawnInRegion:aRegion intoRenderCache:NO];
    }
    if (draw) {
        [NSGraphicsContext saveGraphicsState];
        if ((opacity >= 0.998047f && opacity <= 1.00195f) || ![_contentRenderLayer requiresTransparencyLayer]) {
            [_contentRenderLayer drawRegion:aRegion withDelegate:delegate];
        } else {
            id cache = nil;
            BOOL exclusive = [[[delegate renderLayerWillCacheDrawingInRegion:aRegion] objectForKey:@"HSExclusiveRenderCacheKey"] boolValue];
            [(HSGenericRenderLayer *)_contentRenderLayer cacheRenderingInRegion:aRegion forAffineTransform:CGContextGetCTM(context) withTransformationIntent:NULL acceptableValidnessLimit:1.0 delegate:delegate force:YES share:!exclusive resultCache:&cache];
            [delegate renderLayerDidCacheDrawingInRegion:aRegion intoRenderCache:cache];
            [cache drawRegion:aRegion];
        }
        [NSGraphicsContext restoreGraphicsState];
        [delegate renderLayerIsDrawnInRegion:aRegion intoRenderCache:NO];
    }
    [NSGraphicsContext restoreGraphicsState];
    [delegate renderLayerIsRenderedInRegion:aRegion];
restoreAlpha:
    CGEContextSetAttachmentForKey(context, key, savedAlpha);
    if (savedAlpha)
        CFRelease(savedAlpha);
}
- (id)calculateBoundingRegion
{
    if (_contentRenderLayer)
        return [_contentRenderLayer boundingRegion];
    return [HSRegion region];
}
- (void)fillVisualizationMaskAttributesSet:(id)aSet
{
    if (_contentRenderLayer) {
        [aSet addAttribute:@protocol(HSOpacityAttribute) forObject:[self hyperObject]];
        [_contentRenderLayer addVisualizationMaskAttributesToSet:aSet];
    }
}
- (void)fillVisualizationAttributesSet:(id)aSet
{
    if (_contentRenderLayer) {
        [aSet addAttribute:@protocol(HSOpacityAttribute) forObject:[self hyperObject]];
        [_contentRenderLayer addVisualizationAttributesToSet:aSet];
    }
}
// Fully transparent content counts as empty.
- (BOOL)isEmpty
{
    if (_contentRenderLayer) {
        float opacity = (float)[_opacityAttributes hyperOpacity];
        if (opacity < -0.001f || opacity > 0.001f)
            return [_contentRenderLayer isEmpty];
    }
    return YES;
}
- (void)setContentRenderLayer:(id)aLayer
{
    if (_contentRenderLayer == aLayer)
        return;
    [_contentRenderLayer removeObserver:self];
    [aLayer retain];
    [_contentRenderLayer release];
    _contentRenderLayer = aLayer;
    [aLayer addObserver:self];
    [self visualizationAttributesSetDidChange:nil];
    [self boundingRegionDidChange];
}
- (id)contentRenderLayer
{
    return _contentRenderLayer;
}
- (BOOL)transparencyLayerRequirementAdditionFlagOfRenderSublayerAtIndex:(NSUInteger)aIndex
{
    return NO;
}
- (BOOL)rootFlagOfRenderSublayerAtIndex:(NSUInteger)aIndex
{
    return NO;
}
- (id)roleOfRenderSublayerAtIndex:(NSUInteger)aIndex
{
    return @"HSOpacityContentRenderLayerRole";
}
- (id)renderSublayerAtIndex:(NSUInteger)aIndex
{
    return _contentRenderLayer;
}
- (NSUInteger)renderSublayerCount
{
    return _contentRenderLayer != nil;
}
- (id)renderSublayers
{
    return _contentRenderLayer ? [NSArray arrayWithObject:_contentRenderLayer] : [NSArray array];
}
- (id)copyRemovingRenderSublayers
{
    return [[[self class] allocWithZone:[self zone]] initWithHyperObject:[self hyperObject] cachingPolicy:[self cachingPolicy]];
}
- (void)dealloc
{
    [_contentRenderLayer removeObserver:self];
    [_contentRenderLayer release];
    [_opacityAttributes release];
    [super dealloc];
}
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject cachingPolicy:aPolicy];
    if (self) {
        _opacityAttributes = [[aObject queryHyperInterface:@protocol(HSOpacityAttributes)] retain];
        if (!_opacityAttributes) {
            [self release];
            return nil;
        }
    }
    return self;
}
@end
