#import "HSGenericCIEffectRenderLayer.h"
// Renders an effect object with a Core Image effect: the layers under the
// effect's area are drawn into a bitmap, the effect is applied to it, and the
// result is cached as a Core Image render cache (always cached, never scaled,
// skewed or rotated with the cache).
@implementation HSGenericCIEffectRenderLayer
- (BOOL)cacheRenderingInRegion:(id)aRegion withAffineTransform:(CGAffineTransform)aTransform validness:(CGFloat)aValidness validnessEvaluator:(id)aEvaluator delegate:(id)aDelegate force:(BOOL)aForce share:(BOOL)aShare resultCache:(id *)aCache
{
    if (aCache != NULL) {
        CGFloat persistent = [self persistentValidnessForTemporaryValidness:aValidness region:aRegion];
        *aCache = [self HSGenericCIEffectRenderLayer_cacheRenderingInRegion:aRegion withTemporaryValidness:aValidness persistentValidness:persistent delegate:aDelegate share:aShare];
    }
    return YES;
}
- (void)getRenderCacheValidness:(float *)aValidness validnessEvaluator:(id *)aEvaluator includeScaling:(BOOL *)aScaling includeSkewing:(BOOL *)aSkewing includeRotation:(BOOL *)aRotation includeDevicePointAligning:(BOOL *)aAligning forRegion:(id)aRegion affineTransform:(CGAffineTransform)aTransform transformationIntent:(struct HyperPlayerBase_anon12 *)aIntent
{
    [super getRenderCacheValidness:aValidness validnessEvaluator:NULL includeScaling:NULL includeSkewing:NULL includeRotation:NULL includeDevicePointAligning:NULL forRegion:aRegion affineTransform:aTransform transformationIntent:aIntent];
    if (aEvaluator != NULL)
        *aEvaluator = nil;
    if (aScaling != NULL)
        *aScaling = NO;
    if (aSkewing != NULL)
        *aSkewing = NO;
    if (aRotation != NULL)
        *aRotation = NO;
    if (aAligning != NULL)
        *aAligning = NO;
}
- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce
{
    return YES;
}
// Draws through a cache of the whole bounding region, shared unless the
// delegate asks for an exclusive one.
- (void)drawRenderSublayersInRegion:(id)aRegion withDelegate:(id)aDelegate
{
    id boundingRegion = [self boundingRegion];
    NSDictionary *options = [aDelegate renderLayerWillCacheDrawingInRegion:boundingRegion];
    float validness = 1;
    [self getRenderCacheValidness:&validness validnessEvaluator:NULL includeScaling:NULL includeSkewing:NULL includeRotation:NULL includeDevicePointAligning:NULL forRegion:boundingRegion affineTransform:CGAffineTransformIdentity transformationIntent:NULL];
    BOOL exclusive = [[options objectForKey:@"HSExclusiveRenderCacheKey"] boolValue];
    CGFloat persistent = [self persistentValidnessForTemporaryValidness:validness region:boundingRegion];
    id cache = [self HSGenericCIEffectRenderLayer_cacheRenderingInRegion:boundingRegion withTemporaryValidness:validness persistentValidness:persistent delegate:aDelegate share:!exclusive];
    [aDelegate renderLayerDidCacheDrawingInRegion:boundingRegion intoRenderCache:cache];
    [cache drawRegion:aRegion];
}
// The source layers are drawn (by super) into a premultiplied ARGB bitmap of
// the source area; the effect, sized to that area, takes it as its context
// image. The cache covers the region, placed by the source and region
// origins.
- (id)HSGenericCIEffectRenderLayer_cacheRenderingInRegion:(id)aRegion withTemporaryValidness:(CGFloat)aValidness persistentValidness:(CGFloat)aValidness2 delegate:(id)aDelegate share:(BOOL)aShare
{
    id sourceLayer = [self sourceAreaRenderSublayer];
    if (sourceLayer == nil)
        return nil;
    NSRect source = [[sourceLayer boundingRegion] boundingRect];
    NSRect integral = NSIntegralRect(source);
    NSRect regionRect = [aRegion boundingRect];
    size_t width = integral.size.width > 0 ? lroundf(ceilf(integral.size.width)) : 0;
    size_t height = integral.size.height > 0 ? lroundf(ceilf(integral.size.height)) : 0;
    size_t rowBytes = (width * 4 + 15) & ~(size_t)15;
    CFMutableDataRef data = CFDataCreateMutable(kCFAllocatorDefault, rowBytes * height);
    if ([(id)data autorelease] == nil)
        return nil;
    CFDataSetLength(data, rowBytes * height);
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    if (space == NULL)
        return nil;
    CGContextRef context = CGBitmapContextCreate(CFDataGetMutableBytePtr(data), width, height, 8, rowBytes, space, kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host);
    CGColorSpaceRelease(space);
    if (context == NULL)
        return nil;
    CGContextConcatCTM(context, CGAffineTransformMakeTranslation(-source.origin.x, -source.origin.y));
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSGraphicsContext *graphicsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:YES];
    if (graphicsContext == nil) {
        CGContextRelease(context);
        [pool release];
        return nil;
    }
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:graphicsContext];
    [super drawRenderSublayersInRegion:[sourceLayer boundingRegion] withDelegate:aDelegate];
    [NSGraphicsContext restoreGraphicsState];
    [pool release];
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
    if (provider == NULL) {
        CGContextRelease(context);
        return nil;
    }
    CGImageRef image = CGEImageCreateAsBitmapContext(context, provider, NULL, true, kCGRenderingIntentDefault);
    CGContextRelease(context);
    CGDataProviderRelease(provider);
    if (image == NULL)
        return nil;
    CIImage *contextImage = [CIImage imageWithCGImage:image];
    CGImageRelease(image);
    if (contextImage == nil)
        return nil;
    CIImage *effectImage = [[_coreImageEffectAccessing coreImageEffectAdjustedToSize:source.size] effectImageForContextImage:contextImage];
    if (effectImage == nil)
        return nil;
    CGAffineTransform transform = CGAffineTransformMakeTranslation(-(source.origin.x + regionRect.origin.x), -(source.origin.y + regionRect.origin.y));
    id cache = [[[HSCoreImageRenderCache alloc] initWithCoreImage:effectImage rect:regionRect renderLayer:self affineTransform:transform temporaryValidness:aValidness persistentValidness:aValidness2 validnessEvaluator:nil] autorelease];
    if (cache != nil && aShare)
        [self shareRenderCache:cache withValidationAttributes:[self validationAttributesForBitmapRenderCache]];
    return cache;
}
static BOOL HSGenericCIEffectRenderLayerNearlyEqual(CGFloat aValue, CGFloat aValue2)
{
    CGFloat scale = MAX(aValue2 != 0 ? fabs(aValue2) : 1, aValue != 0 ? fabs(aValue) : 1);
    return fabs(aValue - aValue2) <= scale * 0.0005;
}
// The effect's extent for a blank image of the source's size, recomputed when
// the size changes. As in the original, the source size is compared with the
// cached extent's size (which an effect may well enlarge), so the extent is
// often recomputed.
- (id)calculateBoundingRegion
{
    id sourceLayer = [self sourceAreaRenderSublayer];
    if (sourceLayer == nil)
        return [HSRegion region];
    id sourceRegion = [sourceLayer boundingRegion];
    if ([sourceRegion isEmpty])
        return sourceRegion;
    NSRect source = [sourceRegion boundingRect];
    if (!HSGenericCIEffectRenderLayerNearlyEqual(source.size.width, _cachedBoundingRect.size.width)
        || !HSGenericCIEffectRenderLayerNearlyEqual(source.size.height, _cachedBoundingRect.size.height)) {
        CIImage *effectImage = [[_coreImageEffectAccessing coreImageEffectAdjustedToSize:source.size] effectImageForContextImage:[self dummyCIImageWithSize:source.size]];
        _cachedBoundingRect = effectImage != nil ? [effectImage extent] : CGRectZero;
    }
    return [HSRegion regionWithRect:NSRectFromCGRect(_cachedBoundingRect)];
}
- (void)fillBoundingRegionAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSEffectVisualAttribute) forObject:[self hyperObject]];
    [super fillBoundingRegionAttributesSet:aSet];
}
// The original requires one from Leopard on.
- (BOOL)requiresTransparencyLayer
{
    return YES;
}
// A clear premultiplied ARGB image.
- (id)dummyCIImageWithSize:(NSSize)aSize
{
    size_t width = aSize.width > 0 ? lroundf(ceilf(aSize.width)) : 0;
    size_t height = aSize.height > 0 ? lroundf(ceilf(aSize.height)) : 0;
    size_t size = width * 4 * height;
    void *bytes = malloc(size);
    memset(bytes, 0, size);
    CFDataRef data = CFDataCreateWithBytesNoCopy(NULL, bytes, size, kCFAllocatorMalloc);
    if (data == NULL)
        return nil;
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGImageRef image = CGImageCreate(width, height, 8, 32, width * 4, space, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst, provider, NULL, false, kCGRenderingIntentDefault);
    CFRelease(data);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(space);
    CIImage *result = [[CIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return [result autorelease];
}
- (void)dealloc
{
    [_coreImageEffectAccessing release];
    [super dealloc];
}
// Only for objects that have a Core Image effect.
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject cachingPolicy:aPolicy];
    if (self == nil)
        return nil;
    _coreImageEffectAccessing = [[aObject queryHyperInterface:@protocol(HSCoreImageEffectAccessing)] retain];
    if (_coreImageEffectAccessing == nil || [_coreImageEffectAccessing coreImageEffect] == nil) {
        [self release];
        return nil;
    }
    return self;
}
@end
