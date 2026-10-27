#import "HSGenericQTEffectRenderLayer.h"
#import "HSGenericImageRenderCache.h"
#import "NSAffineTransform+HSKeyValueCoding.h"
// A QuickTime effect applied to its source area, always through a cache: the
// source area is drawn into a premultiplied ARGB bitmap (a GWorld over it in
// the original), which the effect filters.
@implementation HSGenericQTEffectRenderLayer
- (BOOL)cacheRenderingInRegion:(id)aRegion withAffineTransform:(CGAffineTransform)aTransform validness:(CGFloat)aValidness validnessEvaluator:(id)aEvaluator delegate:(id)aDelegate force:(BOOL)aForce share:(BOOL)aShare resultCache:(id *)aCache
{
    if (aCache != NULL)
        *aCache = [self HSGenericQTEffectRenderLayer_cacheRenderingInRegion:aRegion withTemporaryValidness:aValidness
                                                        persistentValidness:[self persistentValidnessForTemporaryValidness:aValidness region:aRegion]
                                                                   delegate:aDelegate share:aShare];
    return YES;
}
// A cache valid for this transform only.
- (void)getRenderCacheValidness:(float *)aValidness validnessEvaluator:(id *)aEvaluator includeScaling:(BOOL *)aScaling includeSkewing:(BOOL *)aSkewing includeRotation:(BOOL *)aRotation includeDevicePointAligning:(BOOL *)aAligning forRegion:(id)aRegion affineTransform:(CGAffineTransform)aTransform transformationIntent:(struct HyperPlayerBase_anon12 *)aIntent
{
    [super getRenderCacheValidness:aValidness validnessEvaluator:NULL includeScaling:NULL includeSkewing:NULL includeRotation:NULL
        includeDevicePointAligning:NULL forRegion:aRegion affineTransform:aTransform transformationIntent:aIntent];
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
- (void)drawRenderSublayersInRegion:(id)aRegion withDelegate:(id)aDelegate
{
    id region = [self boundingRegion];
    NSDictionary *info = [aDelegate renderLayerWillCacheDrawingInRegion:region];
    float validness = 1.0f;
    [self getRenderCacheValidness:&validness validnessEvaluator:NULL includeScaling:NULL includeSkewing:NULL includeRotation:NULL
       includeDevicePointAligning:NULL forRegion:region affineTransform:CGAffineTransformIdentity transformationIntent:NULL];
    BOOL exclusive = [[info objectForKey:@"HSExclusiveRenderCacheKey"] boolValue];
    id cache = [self HSGenericQTEffectRenderLayer_cacheRenderingInRegion:region withTemporaryValidness:validness
                                                     persistentValidness:[self persistentValidnessForTemporaryValidness:validness region:region]
                                                                delegate:aDelegate share:!exclusive];
    [aDelegate renderLayerDidCacheDrawingInRegion:region intoRenderCache:cache];
    [cache drawRegion:aRegion];
}
- (id)HSGenericQTEffectRenderLayer_cacheRenderingInRegion:(id)aRegion withTemporaryValidness:(CGFloat)aValidness persistentValidness:(CGFloat)aValidness2 delegate:(id)aDelegate share:(BOOL)aShare
{
    id sublayer = [self sourceAreaRenderSublayer];
    if (sublayer == nil)
        return nil;
    NSGraphicsContext *previous = [[[NSGraphicsContext currentContext] retain] autorelease];
    if ([previous CGContext] == NULL)
        return nil;
    id region = [sublayer boundingRegion];
    NSRect bounds = [region boundingRect];
    if (NSIsEmptyRect(bounds))
        return nil;
    size_t width = (short)ceilf(bounds.size.width), height = (short)ceilf(bounds.size.height);
    size_t rowBytes = (width * 4 + 15) & ~(size_t)15;
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    if (space == NULL)
        return nil;
    // The context keeps its own memory, so the image the effect makes from
    // it stays valid after the context goes.
    CGContextRef bitmap = CGBitmapContextCreate(NULL, width, height, 8, rowBytes, space, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(space);
    if (bitmap == NULL)
        return nil;
    CGContextClearRect(bitmap, CGRectMake(0, 0, width, height));
    id cache = nil;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithCGContext:bitmap flipped:NO];
    if (context != nil) {
        [NSGraphicsContext setCurrentContext:context];
        CGAffineTransform flip = { 1, 0, 0, -1, -bounds.origin.x, bounds.origin.y + bounds.size.height };
        [[NSAffineTransform transformWithHyperCGAffineTransform:flip] concat];
        [super drawRenderSublayersInRegion:region withDelegate:aDelegate];
        [NSGraphicsContext setCurrentContext:previous];
        id image = [[_quickTimeEffectAccessing quickTimeEffectAdjustedToSize:bounds.size] effectImageForContextImage:bitmap];
        if (image != nil) {
            CGAffineTransform transform = { 1, 0, 0, -1, 0, bounds.origin.y * 2 + bounds.size.height };
            cache = [[HSGenericImageRenderCache alloc] initWithImageRep:[image bestRepresentationForDevice:nil] renderLayer:self affineTransform:transform
                                                     temporaryValidness:aValidness persistentValidness:aValidness2 validnessEvaluator:nil];
            if (aShare && cache != nil)
                [self shareRenderCache:cache withValidationAttributes:[self validationAttributesForBitmapRenderCache]];
        }
    }
    [pool release];
    CGContextRelease(bitmap);
    return [cache autorelease];
}
- (BOOL)requiresTransparencyLayer
{
    return NO;
}
- (void)dealloc
{
    [_quickTimeEffectAccessing release];
    [super dealloc];
}
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject cachingPolicy:aPolicy];
    if (self != nil) {
        _quickTimeEffectAccessing = [[aObject queryHyperInterface:@protocol(HSQuickTimeEffectAccessing)] retain];
        if (_quickTimeEffectAccessing == nil || [_quickTimeEffectAccessing quickTimeEffect] == nil) {
            [self release];
            self = nil;
        }
    }
    return self;
}
@end
