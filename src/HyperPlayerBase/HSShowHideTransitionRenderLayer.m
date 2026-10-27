#import "HSShowHideTransitionRenderLayer.h"
#import "CGEBitmapContext.h"
#import "CGEContext.h"
#import "CVEPixelBuffer.h"
#import "HSBitmapRenderCacheValidnessEvaluator.h"
#import "HSMutableMultipleObjectsAttributeSet.h"
#import "HSMutableRegion.h"
#import "HSPixelBufferRenderCache.h"

// While a transition is drawn, the render layers hand each other the Quartz
// transition renderer, its pixel buffer pool and transforms through
// attachments of the CG context, each holding a pointer to the asker's
// variable.
static NSString * const HSCGEContextQuartzTransitionRendererConsumerKey = @"HSCGEContextQuartzTransitionRendererConsumerKey";
static NSString * const HSCGEContextQuartzTransitionRendererPixelBufferPoolConsumerKey = @"HSCGEContextQuartzTransitionRendererPixelBufferPoolConsumerKey";
static NSString * const HSCGEContextQuartzTransitionRendererContentAffineTransformConsumerKey = @"HSCGEContextQuartzTransitionRendererContentAffineTransformConsumerKey";
static NSString * const HSCGEContextQuartzTransitionRendererAffineTransformConsumerKey = @"HSCGEContextQuartzTransitionRendererAffineTransformConsumerKey";

static id HSShowHideTransitionContextAttachment(CGContextRef aContext, NSString *aKey)
{
    return [[(id)CGEContextGetAttachmentForKey(aContext, (CFStringRef)aKey) retain] autorelease];
}

static void HSShowHideTransitionSetContextAttachment(CGContextRef aContext, NSString *aKey, id aValue)
{
    CGEContextSetAttachmentForKey(aContext, (CFStringRef)aKey, (CFTypeRef)aValue);
}

// Draws the first render sublayer as its delegate allows.
static void HSShowHideTransitionDrawSublayer(id aLayer, id aRegion, id aDelegate)
{
    id delegate = [aDelegate delegateForRenderSublayerAtIndex:0];
    if (delegate && ![delegate renderLayerShouldBeRenderedInRegion:aRegion])
        return;
    [NSGraphicsContext saveGraphicsState];
    if (!delegate || [delegate renderLayerShouldBeDrawnInRegion:aRegion intoRenderCache:NO]) {
        [NSGraphicsContext saveGraphicsState];
        [aLayer drawRegion:aRegion withDelegate:delegate];
        [NSGraphicsContext restoreGraphicsState];
        [delegate renderLayerIsDrawnInRegion:aRegion intoRenderCache:NO];
    }
    [NSGraphicsContext restoreGraphicsState];
    [delegate renderLayerIsRenderedInRegion:aRegion];
}

// The rotation (in [0, 2π)) and skew (in [-π/2, π/2], nudged towards zero) of
// a transform, and whether it flips.
static void HSShowHideTransitionDecompose(CGAffineTransform aTransform, float *aRotation, float *aSkew, BOOL *aFlipped)
{
    float a = aTransform.a, b = aTransform.b, c = aTransform.c, d = aTransform.d;
    float rotation;
    float skew = 0;
    BOOL flipped = NO;
    if (a != 0 || b != 0) {
        float determinant = a * d - b * c;
        double angle = atan2(a * c + b * d, determinant);
        flipped = determinant < 0;
        if (angle < -M_PI_2)
            angle += M_PI;
        else if (angle > M_PI_2)
            angle -= M_PI;
        skew = nextafterf((float)angle, 0);
        rotation = atan2f(b, a);
    } else {
        rotation = (float)(atan2f(d, c) - M_PI_2);
    }
    if (rotation < 0)
        rotation = (float)(rotation + 2 * M_PI);
    if (aRotation)
        *aRotation = rotation;
    if (aSkew)
        *aSkew = skew;
    if (aFlipped)
        *aFlipped = flipped;
}

static BOOL HSShowHideTransitionIsNearZero(float aValue)
{
    return aValue >= -5e-05f && aValue <= 5e-05f;
}

// A flipped, unrotated and unskewed pixel buffer cache of the content can stand
// for the transition's content image, unless the drawing is axis aligned and
// the cache's pixels are offset from the content transform's.
static BOOL HSShowHideTransitionCacheMatches(CGAffineTransform aCacheTransform, CGAffineTransform aContentTransform, CGAffineTransform aCTM)
{
    float rotation, skew;
    BOOL flipped;
    HSShowHideTransitionDecompose(aCacheTransform, &rotation, &skew, &flipped);
    if (!flipped || !HSShowHideTransitionIsNearZero(skew) || !HSShowHideTransitionIsNearZero(rotation))
        return NO;
    HSShowHideTransitionDecompose(aCTM, &rotation, &skew, NULL);
    if (!HSShowHideTransitionIsNearZero(skew) || !HSShowHideTransitionIsNearZero(remainderf(rotation, (float)M_PI)))
        return YES;
    float contentX = fmodf((float)aContentTransform.tx, 1), cacheX = fmodf((float)aCacheTransform.tx, 1);
    if (cacheX < contentX - 5e-05f || cacheX > contentX + 5e-05f)
        return NO;
    float contentY = fmodf((float)aContentTransform.ty, 1), cacheY = fmodf((float)aCacheTransform.ty, 1);
    return cacheY >= contentY - 5e-05f && cacheY <= contentY + 5e-05f;
}

// An object's content, shown as is, or through its show/hide transition while
// one runs: the Quartz layer below hands back the transition renderer, which
// renders the current frame here.
@implementation HSShowHideTransitionRenderLayer

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

- (void)drawRenderSublayersInRegion:(id)aRegion withDelegate:(id)aDelegate
{
    id content = [_transitionRenderLayer contentRenderLayer];
    if (!content)
        return;
    if (![_showHideTransitionAtributes transition]) {
        if (![_cardObjectAttributes isHiddenInPlayer])
            HSShowHideTransitionDrawSublayer(content, aRegion, aDelegate);
        return;
    }
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    if (!context)
        return;
    id renderer = nil;
    NSValue *rendererPointer = [NSValue valueWithPointer:&renderer];
    if (!rendererPointer)
        return;
    CGAffineTransform transform = CGAffineTransformIdentity;
    NSValue *transformPointer = [NSValue valueWithPointer:&transform];
    if (!transformPointer)
        return;
    id previousRendererPointer = HSShowHideTransitionContextAttachment(context, HSCGEContextQuartzTransitionRendererConsumerKey);
    id previousTransformPointer = HSShowHideTransitionContextAttachment(context, HSCGEContextQuartzTransitionRendererAffineTransformConsumerKey);
    [NSGraphicsContext saveGraphicsState];
    HSShowHideTransitionSetContextAttachment(context, HSCGEContextQuartzTransitionRendererConsumerKey, rendererPointer);
    HSShowHideTransitionSetContextAttachment(context, HSCGEContextQuartzTransitionRendererAffineTransformConsumerKey, transformPointer);
    HSShowHideTransitionDrawSublayer(_transitionRenderLayer, aRegion, aDelegate);
    HSShowHideTransitionSetContextAttachment(context, HSCGEContextQuartzTransitionRendererAffineTransformConsumerKey, previousTransformPointer);
    HSShowHideTransitionSetContextAttachment(context, HSCGEContextQuartzTransitionRendererConsumerKey, previousRendererPointer);
    [NSGraphicsContext restoreGraphicsState];
    CGContextConcatCTM(context, transform);
    [renderer renderFrameAtTime:[_showHideTransitionAtributes transitionTime] inCoreGraphicsContext:context];
    [renderer release];
}

- (void)getRenderCacheValidness:(float *)aValidness validnessEvaluator:(id *)aEvaluator includeScaling:(BOOL *)aScaling includeSkewing:(BOOL *)aSkewing includeRotation:(BOOL *)aRotation includeDevicePointAligning:(BOOL *)aAligning forRegion:(id)aRegion affineTransform:(CGAffineTransform)aTransform transformationIntent:(struct HyperPlayerBase_anon12 *)aIntent
{
    id layer = [_transitionRenderLayer contentRenderLayer];
    if (!layer) {
        [super getRenderCacheValidness:aValidness validnessEvaluator:aEvaluator includeScaling:aScaling includeSkewing:aSkewing includeRotation:aRotation includeDevicePointAligning:aAligning forRegion:aRegion affineTransform:aTransform transformationIntent:aIntent];
        return;
    }
    if ([_showHideTransitionAtributes transition])
        layer = _transitionRenderLayer;
    [layer getRenderCacheValidness:aValidness validnessEvaluator:aEvaluator includeScaling:aScaling includeSkewing:aSkewing includeRotation:aRotation includeDevicePointAligning:aAligning forRegion:aRegion affineTransform:aTransform transformationIntent:aIntent];
}

- (BOOL)unionBoundingRegionOfSublayersVisualAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion
{
    id content = [_transitionRenderLayer contentRenderLayer];
    if (!content)
        return NO;
    if ([_showHideTransitionAtributes transition]) {
        if (!*aRegion)
            *aRegion = [HSMutableRegion region];
        return [self unionBoundingRegionWithRegion:*aRegion];
    }
    if ([_cardObjectAttributes isHiddenInPlayer])
        return NO;
    return [content unionBoundingRegionOfConcreteAttributeSet:aSet ofHyperObject:aObject withInfo:aInfo withRegion:aRegion];
}

- (id)calculateBoundingRegion
{
    id content = [_transitionRenderLayer contentRenderLayer];
    if (!content)
        return [HSRegion region];
    if ([_showHideTransitionAtributes transition])
        return [_transitionRenderLayer boundingRegion];
    if ([_cardObjectAttributes isHiddenInPlayer])
        return [HSRegion region];
    return [content boundingRegion];
}

- (void)fillBoundingRegionAttributesSet:(id)aSet
{
    id object = [self hyperObject];
    [aSet addAttribute:@protocol(HSCardObjectHiddenAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSShowHideTransitionAttribute) forObject:object];
}

// As in the original, the sublayers add their visualization attributes, not
// their mask ones.
- (void)fillVisualizationMaskAttributesSet:(id)aSet
{
    id object = [self hyperObject];
    [aSet addAttribute:@protocol(HSCardObjectHiddenAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSShowHideTransitionFrameAttribute) forObject:object];
    [_transitionRenderLayer addVisualizationAttributesToSet:aSet];
    [[_transitionRenderLayer contentRenderLayer] addVisualizationAttributesToSet:aSet];
}

- (void)fillVisualizationAttributesSet:(id)aSet
{
    id object = [self hyperObject];
    [aSet addAttribute:@protocol(HSCardObjectHiddenAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSShowHideTransitionFrameAttribute) forObject:object];
    [_transitionRenderLayer addVisualizationAttributesToSet:aSet];
    [[_transitionRenderLayer contentRenderLayer] addVisualizationAttributesToSet:aSet];
}

- (BOOL)isEmpty
{
    return [_cardObjectAttributes isHiddenInPlayer] && ![_showHideTransitionAtributes transition];
}

- (void)setContentRenderLayer:(id)aLayer
{
    id content = [_transitionRenderLayer contentRenderLayer];
    if (content == aLayer)
        return;
    [content removeObserver:self];
    [[self HSShowHideTransitionRenderLayer_transitionRendererRenderLayer] setContentRenderLayer:aLayer];
    [[_transitionRenderLayer contentRenderLayer] addObserver:self];
    [self visualizationAttributesSetDidChange:nil];
    [self boundingRegionDidChange];
}

- (id)contentRenderLayer
{
    return [_transitionRenderLayer contentRenderLayer];
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
    return [_showHideTransitionAtributes transition] ? @"HSShowHideTransitionRenderLayerRole" : @"HSObjectContentRenderLayerRole";
}

- (id)renderSublayerAtIndex:(NSUInteger)aIndex
{
    if ([_showHideTransitionAtributes transition])
        return _transitionRenderLayer;
    return [_transitionRenderLayer contentRenderLayer];
}

- (NSUInteger)renderSublayerCount
{
    return [_transitionRenderLayer contentRenderLayer] != nil;
}

- (id)renderSublayers
{
    id content = [_transitionRenderLayer contentRenderLayer];
    if (!content)
        return [NSArray array];
    if ([_showHideTransitionAtributes transition])
        return [NSArray arrayWithObject:_transitionRenderLayer];
    return [NSArray arrayWithObject:content];
}

- (id)HSShowHideTransitionRenderLayer_transitionRendererRenderLayer
{
    if (!_transitionRenderLayer) {
        _transitionRenderLayer = [[HSShowHideTransitionRenderLayer_QuartzShowHideTransitionRenderLayer alloc] initWithHyperObject:[self hyperObject] cachingPolicy:2];
        [_transitionRenderLayer addObserver:self];
    }
    return _transitionRenderLayer;
}

- (id)copyRemovingRenderSublayers
{
    return [[[self class] allocWithZone:[self zone]] initWithHyperObject:[self hyperObject] cachingPolicy:[self cachingPolicy]];
}

- (void)dealloc
{
    [[_transitionRenderLayer contentRenderLayer] removeObserver:self];
    [_transitionRenderLayer removeObserver:self];
    [_transitionRenderLayer release];
    [_cardObjectAttributes release];
    [_showHideTransitionAtributes release];
    [super dealloc];
}

- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject cachingPolicy:aPolicy];
    if (!self)
        return nil;
    _cardObjectAttributes = [[aObject queryHyperInterface:@protocol(HSCardObjectAttributes)] retain];
    if (_cardObjectAttributes) {
        _showHideTransitionAtributes = [[aObject queryHyperInterface:@protocol(HSShowHideTransitionAttributes)] retain];
        if (_showHideTransitionAtributes)
            return self;
    }
    [self release];
    return nil;
}

@end

// Caches the transition: draws its renderer layer to get the renderer, gives
// it the content drawn into a pixel buffer (or a matching pixel buffer cache of
// the content) as its end image when showing, start image when hiding, and
// keeps the renderer in its cache.
@implementation HSShowHideTransitionRenderLayer_QuartzShowHideTransitionRenderLayer

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

- (BOOL)cacheRenderingInRegion:(id)aRegion withAffineTransform:(CGAffineTransform)aTransform validness:(CGFloat)aValidness validnessEvaluator:(id)aEvaluator delegate:(id)aDelegate force:(BOOL)aForce share:(BOOL)aShare resultCache:(id *)aCache
{
    if (!aCache)
        return YES;
    id content = [_transitionRendererRenderLayer contentRenderLayer];
    if (!content || ![_showHideTransitionAtributes transition])
        return *aCache != nil;
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    if (!context || !HSShowHideTransitionContextAttachment(context, HSCGEContextQuartzTransitionRendererConsumerKey))
        return *aCache != nil;
    id previousRendererPointer = HSShowHideTransitionContextAttachment(context, HSCGEContextQuartzTransitionRendererConsumerKey);
    id previousPoolPointer = HSShowHideTransitionContextAttachment(context, HSCGEContextQuartzTransitionRendererPixelBufferPoolConsumerKey);
    id previousContentTransformPointer = HSShowHideTransitionContextAttachment(context, HSCGEContextQuartzTransitionRendererContentAffineTransformConsumerKey);
    id renderer = nil;
    NSValue *rendererPointer = [NSValue valueWithPointer:&renderer];
    if (!rendererPointer)
        return *aCache != nil;
    CVPixelBufferPoolRef pool = NULL;
    NSValue *poolPointer = [NSValue valueWithPointer:&pool];
    if (!poolPointer)
        return *aCache != nil;
    CGAffineTransform contentTransform = CGAffineTransformIdentity;
    NSValue *contentTransformPointer = [NSValue valueWithPointer:&contentTransform];
    if (!contentTransformPointer)
        return *aCache != nil;
    HSShowHideTransitionSetContextAttachment(context, HSCGEContextQuartzTransitionRendererConsumerKey, rendererPointer);
    HSShowHideTransitionSetContextAttachment(context, HSCGEContextQuartzTransitionRendererPixelBufferPoolConsumerKey, poolPointer);
    HSShowHideTransitionSetContextAttachment(context, HSCGEContextQuartzTransitionRendererContentAffineTransformConsumerKey, contentTransformPointer);
    HSShowHideTransitionDrawSublayer(_transitionRendererRenderLayer, aRegion, aDelegate);
    HSShowHideTransitionSetContextAttachment(context, HSCGEContextQuartzTransitionRendererContentAffineTransformConsumerKey, previousContentTransformPointer);
    HSShowHideTransitionSetContextAttachment(context, HSCGEContextQuartzTransitionRendererPixelBufferPoolConsumerKey, previousPoolPointer);
    HSShowHideTransitionSetContextAttachment(context, HSCGEContextQuartzTransitionRendererConsumerKey, previousRendererPointer);
    [renderer autorelease];
    [(id)pool autorelease];
    if (!renderer || !pool)
        return *aCache != nil;
    id contentRegion = [content boundingRegion];
    if (!contentRegion)
        return *aCache != nil;

    // The content image, from a cache of the content proposed while the
    // context draws in the content transform, or drawn anew.
    CVPixelBufferRef image = NULL;
    id contentDelegate = [aDelegate delegateForRenderSublayerAtIndex:1];
    if (contentDelegate && ![contentDelegate renderLayerShouldBeRenderedInRegion:contentRegion])
        return *aCache != nil;
    CGAffineTransform ctm = CGContextGetCTM(context);
    CGContextConcatCTM(context, CGAffineTransformConcat(contentTransform, CGAffineTransformInvert(ctm)));
    NSDictionary *cachingInfo = [contentDelegate renderLayerDrawingWillBeCachedInRegion:contentRegion];
    CGContextConcatCTM(context, CGAffineTransformConcat(ctm, CGAffineTransformInvert(contentTransform)));
    NSArray *proposedCaches = [cachingInfo objectForKey:@"HSProposedRenderCachesKey"];
    Class pixelBufferCacheClass = [HSPixelBufferRenderCache class];
    id contentCache = nil;
    NSUInteger count = [proposedCaches count];
    for (NSUInteger index = 0; index < count; index++) {
        id proposed = [proposedCaches objectAtIndex:index];
        if ([proposed isKindOfClass:pixelBufferCacheClass] && HSShowHideTransitionCacheMatches([(HSPixelBufferRenderCache *)proposed affineTransform], contentTransform, ctm)) {
            contentCache = [proposed retain];
            if (contentCache)
                image = CVPixelBufferRetain([contentCache pixelBuffer]);
            break;
        }
    }
    if (!contentCache) {
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pool, &image);
        if (image) {
            CGContextRef bitmapContext = CGEBitmapContextCreateWithPixelBuffer(image, 0);
            NSAutoreleasePool *autoreleasePool = nil;
            NSGraphicsContext *graphicsContext = nil;
            if (bitmapContext) {
                CGContextClearRect(bitmapContext, CGRectMake(0, 0, CVPixelBufferGetWidth(image), CVPixelBufferGetHeight(image)));
                CGContextConcatCTM(bitmapContext, contentTransform);
                autoreleasePool = [[NSAutoreleasePool alloc] init];
                graphicsContext = [NSGraphicsContext graphicsContextWithCGContext:bitmapContext flipped:YES];
            }
            if (!graphicsContext) {
                [autoreleasePool release];
                if (bitmapContext)
                    CGContextRelease(bitmapContext);
                CVPixelBufferRelease(image);
                image = NULL;
            } else {
                [NSGraphicsContext saveGraphicsState];
                [NSGraphicsContext setCurrentContext:graphicsContext];
                if (!contentDelegate || [contentDelegate renderLayerShouldBeDrawnInRegion:contentRegion intoRenderCache:YES]) {
                    [content drawRegion:contentRegion withDelegate:contentDelegate];
                    [contentDelegate renderLayerIsDrawnInRegion:contentRegion intoRenderCache:YES];
                }
                [NSGraphicsContext restoreGraphicsState];
                [autoreleasePool release];
                CGContextRelease(bitmapContext);
                float temporaryValidness = 0;
                id evaluator = nil;
                [content getRenderCacheValidness:&temporaryValidness validnessEvaluator:&evaluator includeScaling:NULL includeSkewing:NULL includeRotation:NULL includeDevicePointAligning:NULL forRegion:contentRegion affineTransform:contentTransform transformationIntent:NULL];
                contentCache = [[HSPixelBufferRenderCache alloc] initWithPixelBuffer:image renderLayer:content affineTransform:contentTransform temporaryValidness:temporaryValidness persistentValidness:[content persistentValidnessForTemporaryValidness:temporaryValidness region:contentRegion] validnessEvaluator:evaluator];
                if (contentCache && ![[cachingInfo objectForKey:@"HSExclusiveRenderCacheKey"] boolValue])
                    [content shareRenderCache:contentCache withValidationAttributes:[content validationAttributesForBitmapRenderCache]];
            }
        }
    }
    [contentDelegate renderLayerDrawingIsCachedInRegion:contentRegion intoRenderCache:contentCache];
    [contentCache release];
    [contentDelegate renderLayerIsRenderedInRegion:aRegion];
    if (!image)
        return *aCache != nil;

    if ([_cardObjectAttributes isHiddenInPlayer])
        [renderer setStartImage:(id)image];
    else
        [renderer setEndImage:(id)image];
    CVPixelBufferRelease(image);
    *aCache = [[[HSShowHideTransitionRenderLayer_QuartzShowHideTransitionRendererRenderCache alloc] initWithQuartzTransitionRenderer:renderer pixelBufferPool:pool renderLayer:self affineTransform:aTransform temporaryValidness:aValidness persistentValidness:[self persistentValidnessForTemporaryValidness:aValidness region:aRegion] validnessEvaluator:aEvaluator] autorelease];
    if (*aCache && aShare)
        [self shareRenderCache:*aCache withValidationAttributes:[self validationAttributesForBitmapRenderCache]];
    return *aCache != nil;
}

- (id)continuousChangeSensitiveVisualizationAttributes
{
    return [[[HSMultipleObjectsAttributeSet alloc] init] autorelease];
}

- (void)getRenderCacheValidness:(float *)aValidness validnessEvaluator:(id *)aEvaluator includeScaling:(BOOL *)aScaling includeSkewing:(BOOL *)aSkewing includeRotation:(BOOL *)aRotation includeDevicePointAligning:(BOOL *)aAligning forRegion:(id)aRegion affineTransform:(CGAffineTransform)aTransform transformationIntent:(struct HyperPlayerBase_anon12 *)aIntent
{
    [_transitionRendererRenderLayer getRenderCacheValidness:aValidness validnessEvaluator:aEvaluator includeScaling:aScaling includeSkewing:aSkewing includeRotation:aRotation includeDevicePointAligning:aAligning forRegion:aRegion affineTransform:aTransform transformationIntent:aIntent];
}

- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce
{
    return YES;
}

// Always drawn through a cache.
- (void)drawRenderSublayersInRegion:(id)aRegion withDelegate:(id)aDelegate
{
    id cache = nil;
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    BOOL exclusive = [[[aDelegate renderLayerWillCacheDrawingInRegion:aRegion] objectForKey:@"HSExclusiveRenderCacheKey"] boolValue];
    [self cacheRenderingInRegion:aRegion forAffineTransform:CGContextGetCTM(context) withTransformationIntent:NULL acceptableValidnessLimit:1.0 delegate:aDelegate force:YES share:!exclusive resultCache:&cache];
    [aDelegate renderLayerDidCacheDrawingInRegion:aRegion intoRenderCache:cache];
    [cache drawRegion:aRegion];
}

- (BOOL)unionBoundingRegionOfConcreteAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion
{
    if (![_transitionRendererRenderLayer contentRenderLayer])
        return NO;
    if (![[[self visualizationAttributes] attributesForObject:aObject] intersectsProtocolSet:aSet])
        return NO;
    if (!*aRegion)
        *aRegion = [HSMutableRegion region];
    return [self unionBoundingRegionWithRegion:*aRegion];
}

- (id)calculateBoundingRegion
{
    if (!_transitionRendererRenderLayer)
        return [HSRegion region];
    return [_transitionRendererRenderLayer boundingRegion];
}

- (void)fillVisualizationMaskAttributesSet:(id)aSet
{
    [_transitionRendererRenderLayer addVisualizationMaskAttributesToSet:aSet];
    [[_transitionRendererRenderLayer contentRenderLayer] addVisualizationMaskAttributesToSet:aSet];
}

- (void)fillVisualizationAttributesSet:(id)aSet
{
    [_transitionRendererRenderLayer addVisualizationAttributesToSet:aSet];
    [[_transitionRendererRenderLayer contentRenderLayer] addVisualizationAttributesToSet:aSet];
}

- (BOOL)isEmpty
{
    return ![_transitionRendererRenderLayer contentRenderLayer] || ![_showHideTransitionAtributes transition];
}

- (void)setContentRenderLayer:(id)aLayer
{
    id content = [_transitionRendererRenderLayer contentRenderLayer];
    if (content == aLayer)
        return;
    [content removeObserver:self];
    [[self HSShowHideTransitionRenderLayer_QuartzShowHideTransitionRenderLayer_transitionRendererRenderLayer] setContentRenderLayer:aLayer];
    [[_transitionRendererRenderLayer contentRenderLayer] addObserver:self];
    [self visualizationAttributesSetDidChange:nil];
    [self boundingRegionDidChange];
}

- (id)contentRenderLayer
{
    return [_transitionRendererRenderLayer contentRenderLayer];
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
    if (aIndex == 0)
        return @"HSShowHideTransitionRendererRenderLayerRole";
    if (aIndex == 1)
        return @"HSShowHideTransitionContentRenderLayerRole";
    return nil;
}

- (id)renderSublayerAtIndex:(NSUInteger)aIndex
{
    if (aIndex == 1)
        return [_transitionRendererRenderLayer contentRenderLayer];
    if (aIndex == 0)
        return _transitionRendererRenderLayer;
    return nil;
}

- (NSUInteger)renderSublayerCount
{
    if (![_transitionRendererRenderLayer contentRenderLayer])
        return 0;
    return [_showHideTransitionAtributes transition] ? 2 : 0;
}

- (id)renderSublayers
{
    id content = [_transitionRendererRenderLayer contentRenderLayer];
    if (!content || ![_showHideTransitionAtributes transition])
        return [NSArray array];
    return [NSArray arrayWithObjects:_transitionRendererRenderLayer, content, nil];
}

- (id)HSShowHideTransitionRenderLayer_QuartzShowHideTransitionRenderLayer_transitionRendererRenderLayer
{
    if (!_transitionRendererRenderLayer) {
        _transitionRendererRenderLayer = [[HSShowHideTransitionRenderLayer_QuartzShowHideTransitionRendererRenderLayer alloc] initWithHyperObject:[self hyperObject] cachingPolicy:2];
        [_transitionRendererRenderLayer addObserver:self];
    }
    return _transitionRendererRenderLayer;
}

- (id)copyRemovingRenderSublayers
{
    return [[[self class] allocWithZone:[self zone]] initWithHyperObject:[self hyperObject] cachingPolicy:[self cachingPolicy]];
}

- (void)dealloc
{
    [[_transitionRendererRenderLayer contentRenderLayer] removeObserver:self];
    [_transitionRendererRenderLayer removeObserver:self];
    [_transitionRendererRenderLayer release];
    [_showHideTransitionAtributes release];
    [_cardObjectAttributes release];
    [super dealloc];
}

- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject cachingPolicy:aPolicy];
    if (!self)
        return nil;
    _cardObjectAttributes = [[aObject queryHyperInterface:@protocol(HSCardObjectAttributes)] retain];
    if (_cardObjectAttributes) {
        _showHideTransitionAtributes = [[aObject queryHyperInterface:@protocol(HSShowHideTransitionAttributes)] retain];
        if (_showHideTransitionAtributes)
            return self;
    }
    [self release];
    return nil;
}

@end

// Caches the transition renderer made by the transition's effect for the
// device size of the content, with a blank image on the content's side, and
// its pixel buffer pool.
@implementation HSShowHideTransitionRenderLayer_QuartzShowHideTransitionRendererRenderLayer

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

// Without a result cache, answers whether the transformed bounds fit the
// maximum bitmap cache area.
- (BOOL)cacheRenderingInRegion:(id)aRegion withAffineTransform:(CGAffineTransform)aTransform validness:(CGFloat)aValidness validnessEvaluator:(id)aEvaluator delegate:(id)aDelegate force:(BOOL)aForce share:(BOOL)aShare resultCache:(id *)aCache
{
    if (!aCache && aForce)
        return YES;
    id boundingRegion = [self boundingRegion];
    id transformed = [(HSMutableRegion *)[[boundingRegion mutableCopy] autorelease] applyAffineTransform:aTransform];
    if (!transformed)
        return NO;
    NSRect bounds = NSIntegralRect([transformed boundingRect]);
    if (bounds.size.width <= 0 || bounds.size.height <= 0)
        return NO;
    float width = lroundf(ceilf((float)bounds.size.width));
    float height = lroundf(ceilf((float)bounds.size.height));
    if (!aForce) {
        float maxArea = (float)[[self class] maxBitmapCacheArea];
        float area = width * height;
        if (maxArea < area || !aCache)
            return area <= maxArea;
    } else if (!aCache) {
        return YES;
    }
    id renderer = [[[_showHideTransitionAtributes transition] effect] createQuartzRendererForSize:CGSizeMake(width, height)];
    if (!renderer)
        return NO;
    CVPixelBufferPoolRef pool = [self HSShowHideTransitionRenderLayer_QuartzShowHideTransitionRendererRenderLayer_createPixelBufferPoolWithWidth:lroundf(width) height:lroundf(height)];
    if (!pool) {
        [renderer release];
        return NO;
    }
    CVPixelBufferRef blank = NULL;
    CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pool, &blank);
    if (blank) {
        if (CVPixelBufferLockBaseAddress(blank, 0) == kCVReturnSuccess) {
            memset(CVPixelBufferGetBaseAddress(blank), 0, CVEPixelBufferGetDataSize(blank));
            CVPixelBufferUnlockBaseAddress(blank, 0);
            if ([_cardObjectAttributes isHiddenInPlayer])
                [renderer setEndImage:(id)blank];
            else
                [renderer setStartImage:(id)blank];
        }
        CVPixelBufferRelease(blank);
    }
    CGAffineTransform transform = aTransform;
    transform.tx -= bounds.origin.x;
    transform.ty -= bounds.origin.y;
    *aCache = [[[HSShowHideTransitionRenderLayer_QuartzShowHideTransitionRendererRenderCache alloc] initWithQuartzTransitionRenderer:renderer pixelBufferPool:pool renderLayer:self affineTransform:transform temporaryValidness:aValidness persistentValidness:[self persistentValidnessForTemporaryValidness:aValidness region:boundingRegion] validnessEvaluator:aEvaluator] autorelease];
    [renderer release];
    CVPixelBufferPoolRelease(pool);
    if (!*aCache)
        return NO;
    [*aCache setAttachment:[NSValue valueWithRect:[boundingRegion boundingRect]] forKey:@"HSObjectCacheRect"];
    if (aShare)
        [self shareRenderCache:*aCache withValidationAttributes:[self validationAttributesForBitmapRenderCache]];
    return YES;
}

- (struct __CVPixelBufferPool *)HSShowHideTransitionRenderLayer_QuartzShowHideTransitionRendererRenderLayer_createPixelBufferPoolWithWidth:(NSUInteger)aWidth height:(NSUInteger)aHeight
{
    CVPixelBufferPoolRef pool = NULL;
    NSDictionary *nonPropagated = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], (id)kCVEPixelBufferAlphaInfoKey, nil];
    if (!nonPropagated)
        return NULL;
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA], (id)kCVPixelBufferPixelFormatTypeKey,
        [NSNumber numberWithUnsignedLong:aWidth], (id)kCVPixelBufferWidthKey,
        [NSNumber numberWithUnsignedLong:aHeight], (id)kCVPixelBufferHeightKey,
        (id)kCFBooleanTrue, (id)kCVPixelBufferCGBitmapContextCompatibilityKey,
        (id)kCFBooleanTrue, (id)kCVPixelBufferCGImageCompatibilityKey,
        nonPropagated, (id)kCVBufferNonPropagatedAttachmentsKey, nil];
    if (attributes)
        CVPixelBufferPoolCreate(kCFAllocatorDefault, NULL, (CFDictionaryRef)attributes, &pool);
    return pool;
}

- (id)continuousChangeSensitiveVisualizationAttributes
{
    return [[[HSMultipleObjectsAttributeSet alloc] init] autorelease];
}

// A change of anything but the transition alone moves the cached frame from the
// bounds it was made for to the new bounds; only a change of the transition
// invalidates it.
- (void)invalidateRenderCache:(id)aCache withAttributeChangeNotification:(id)aNotification
{
    id attributes = aNotification ? [aNotification attributeProtocolSet] : nil;
    if (attributes) {
        BOOL transitionChanged = [attributes containsProtocol:@protocol(HSShowHideTransitionAttribute)];
        NSValue *cacheRect = nil;
        if ((!transitionChanged || [attributes count] != 1) && (cacheRect = [aCache attachmentForKey:@"HSObjectCacheRect"])) {
            NSRect oldRect = [cacheRect rectValue];
            NSRect newRect = [[self boundingRegion] boundingRect];
            CGFloat scaleX = newRect.size.width == 0 ? 1 : oldRect.size.width / newRect.size.width;
            CGFloat scaleY = newRect.size.height == 0 ? 1 : oldRect.size.height / newRect.size.height;
            CGAffineTransform move = CGAffineTransformMake(scaleX, 0, 0, scaleY, oldRect.origin.x - newRect.origin.x * scaleX, oldRect.origin.y - newRect.origin.y * scaleY);
            [aCache setAffineTransform:CGAffineTransformConcat(move, [(HSGenericRenderCache *)aCache affineTransform])];
            [aCache setAttachment:[NSValue valueWithRect:newRect] forKey:@"HSObjectCacheRect"];
            if (!transitionChanged)
                return;
        }
    }
    [super invalidateRenderCache:aCache withAttributeChangeNotification:aNotification];
}

// Cached unrotated and unskewed: the scales, flipped, and the device pixel
// offset of the transform.
- (void)getRenderCacheValidness:(float *)aValidness validnessEvaluator:(id *)aEvaluator cachingTransform:(CGAffineTransform *)aTransform forRegion:(id)aRegion affineTransform:(CGAffineTransform)aTransform2 transformationIntent:(struct HyperPlayerBase_anon12 *)aIntent
{
    if (aValidness)
        *aValidness = 1.0f;
    if (aEvaluator)
        *aEvaluator = [HSBitmapRenderCacheValidnessEvaluator validnessEvaluatorForScaling:YES skewing:NO rotation:NO offset:NO];
    if (!aTransform)
        return;
    float a = aTransform2.a, b = aTransform2.b, c = aTransform2.c, d = aTransform2.d;
    float tx = aTransform2.tx, ty = aTransform2.ty;
    float rotation;
    if (a != 0 || b != 0)
        rotation = atan2f(b, a);
    else
        rotation = (float)(atan2f(d, c) - M_PI_2);
    if (rotation < 0)
        rotation = rotation + 6.2831855f;
    float sine = sinf(-rotation), cosine = cosf(-rotation);
    float y = ty * cosine + tx * sine;
    float offsetX = fmodf((tx * cosine - ty * sine) - ((a * c + b * d) * y) / (a * d - b * c), 1);
    float offsetY = fmodf(y, 1);
    if (b * c <= a * d)
        offsetY = -offsetY;
    float scaleY = hypotf(c, d);
    float scaleX = hypotf(a, b);
    float skew = tanf(0);
    float skewScale = hypotf(skew, 1);
    aTransform->a = scaleX;
    aTransform->b = scaleX * 0.0f;
    aTransform->c = skew * -(scaleY / skewScale);
    aTransform->d = (skew * 0.0f + 1.0f) * -(scaleY / skewScale);
    aTransform->tx = offsetX;
    aTransform->ty = offsetY;
}

- (void)getRenderCacheValidness:(float *)aValidness validnessEvaluator:(id *)aEvaluator includeScaling:(BOOL *)aScaling includeSkewing:(BOOL *)aSkewing includeRotation:(BOOL *)aRotation includeDevicePointAligning:(BOOL *)aAligning forRegion:(id)aRegion affineTransform:(CGAffineTransform)aTransform transformationIntent:(struct HyperPlayerBase_anon12 *)aIntent
{
    if (aValidness)
        *aValidness = 1.0f;
    if (aEvaluator)
        *aEvaluator = [HSBitmapRenderCacheValidnessEvaluator validnessEvaluatorForScaling:YES skewing:NO rotation:NO offset:NO];
    if (aScaling)
        *aScaling = YES;
    if (aSkewing)
        *aSkewing = NO;
    if (aRotation)
        *aRotation = NO;
    if (aAligning)
        *aAligning = YES;
}

- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce
{
    return YES;
}

// Always drawn through a cache.
- (void)drawRenderSublayersInRegion:(id)aRegion withDelegate:(id)aDelegate
{
    id cache = nil;
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    BOOL exclusive = [[[aDelegate renderLayerWillCacheDrawingInRegion:aRegion] objectForKey:@"HSExclusiveRenderCacheKey"] boolValue];
    [self cacheRenderingInRegion:aRegion forAffineTransform:CGContextGetCTM(context) withTransformationIntent:NULL acceptableValidnessLimit:1.0 delegate:aDelegate force:YES share:!exclusive resultCache:&cache];
    [aDelegate renderLayerDidCacheDrawingInRegion:aRegion intoRenderCache:cache];
    [cache drawRegion:aRegion];
}

- (BOOL)unionBoundingRegionOfConcreteAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion
{
    if (!_contentRenderLayer)
        return NO;
    if (![[[self visualizationAttributes] attributesForObject:aObject] intersectsProtocolSet:aSet])
        return NO;
    if (!*aRegion)
        *aRegion = [HSMutableRegion region];
    return [self unionBoundingRegionWithRegion:*aRegion];
}

- (id)calculateBoundingRegion
{
    if (!_contentRenderLayer)
        return [HSRegion region];
    return [_contentRenderLayer boundingRegion];
}

- (void)fillBoundingRegionAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSShowHideTransitionAttribute) forObject:[self hyperObject]];
}

- (void)fillVisualizationMaskAttributesSet:(id)aSet
{
    if (!_contentRenderLayer)
        return;
    [aSet addAttribute:@protocol(HSShowHideTransitionAttribute) forObject:[self hyperObject]];
    [_contentRenderLayer addVisualizationMaskAttributesToSet:aSet];
}

- (void)fillVisualizationAttributesSet:(id)aSet
{
    if (!_contentRenderLayer)
        return;
    [aSet addAttribute:@protocol(HSShowHideTransitionAttribute) forObject:[self hyperObject]];
    [_contentRenderLayer addVisualizationAttributesToSet:aSet];
}

- (BOOL)isEmpty
{
    return !_contentRenderLayer || ![_showHideTransitionAtributes transition];
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
    return @"HSShowHideTransitionRendererContentRenderLayerRole";
}

- (id)renderSublayerAtIndex:(NSUInteger)aIndex
{
    return _contentRenderLayer;
}

- (NSUInteger)renderSublayerCount
{
    if (!_contentRenderLayer)
        return 0;
    return [_showHideTransitionAtributes transition] != nil;
}

- (id)renderSublayers
{
    if (!_contentRenderLayer || ![_showHideTransitionAtributes transition])
        return [NSArray array];
    return [NSArray arrayWithObject:_contentRenderLayer];
}

- (id)copyRemovingRenderSublayers
{
    return [[[self class] allocWithZone:[self zone]] initWithHyperObject:[self hyperObject] cachingPolicy:[self cachingPolicy]];
}

- (void)dealloc
{
    [_contentRenderLayer removeObserver:self];
    [_contentRenderLayer release];
    [_showHideTransitionAtributes release];
    [_cardObjectAttributes release];
    [super dealloc];
}

- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject cachingPolicy:aPolicy];
    if (!self)
        return nil;
    _cardObjectAttributes = [[aObject queryHyperInterface:@protocol(HSCardObjectAttributes)] retain];
    if (_cardObjectAttributes) {
        _showHideTransitionAtributes = [[aObject queryHyperInterface:@protocol(HSShowHideTransitionAttributes)] retain];
        if (_showHideTransitionAtributes)
            return self;
    }
    [self release];
    return nil;
}

@end

// Draws nothing itself: it hands its renderer, pool and transforms to the
// render layers asking through the context attachments.
@implementation HSShowHideTransitionRenderLayer_QuartzShowHideTransitionRendererRenderCache

- (void)drawRegion:(id)aRegion
{
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    id *renderer = [(NSValue *)CGEContextGetAttachmentForKey(context, (CFStringRef)HSCGEContextQuartzTransitionRendererConsumerKey) pointerValue];
    if (renderer) {
        [*renderer release];
        *renderer = [_quartzTransitionRenderer retain];
    }
    CVPixelBufferPoolRef *pool = [(NSValue *)CGEContextGetAttachmentForKey(context, (CFStringRef)HSCGEContextQuartzTransitionRendererPixelBufferPoolConsumerKey) pointerValue];
    if (pool) {
        CVPixelBufferPoolRelease(*pool);
        *pool = CVPixelBufferPoolRetain(_pixelBufferPool);
    }
    CGAffineTransform *contentTransform = [(NSValue *)CGEContextGetAttachmentForKey(context, (CFStringRef)HSCGEContextQuartzTransitionRendererContentAffineTransformConsumerKey) pointerValue];
    if (contentTransform)
        *contentTransform = [self affineTransform];
    CGAffineTransform *transform = [(NSValue *)CGEContextGetAttachmentForKey(context, (CFStringRef)HSCGEContextQuartzTransitionRendererAffineTransformConsumerKey) pointerValue];
    if (transform)
        *transform = [self drawingAffineTransform];
}

// The renderer's frame with a 0.01 margin, in the cache's space.
- (BOOL)intersectsWithRegion:(id)aRegion
{
    CGSize size = [_quartzTransitionRenderer rendererSize];
    HSMutableRegion *region = [[aRegion mutableCopy] autorelease];
    return [[region applyAffineTransform:[self affineTransform]] intersectsRect:NSMakeRect(-0.01f, -0.01f, size.width + 0.02f, size.height + 0.02f)];
}

- (BOOL)containsRegion:(id)aRegion
{
    CGSize size = [_quartzTransitionRenderer rendererSize];
    HSMutableRegion *region = [[aRegion mutableCopy] autorelease];
    return NSContainsRect(NSMakeRect(-0.01f, -0.01f, size.width + 0.02f, size.height + 0.02f), [[region applyAffineTransform:[self affineTransform]] boundingRect]);
}

- (id)description
{
    NSString *poolDescription = [(NSString *)CFCopyDescription(_pixelBufferPool) autorelease];
    return [NSString stringWithFormat:@"<%@: %p>{%@, %@}", NSStringFromClass([self class]), self, _quartzTransitionRenderer, poolDescription];
}

- (void)dealloc
{
    CVPixelBufferPoolRelease(_pixelBufferPool);
    [_quartzTransitionRenderer release];
    [super dealloc];
}

- (id)initWithQuartzTransitionRenderer:(id)aRenderer pixelBufferPool:(struct __CVPixelBufferPool *)aPool renderLayer:(id)aLayer affineTransform:(CGAffineTransform)aTransform temporaryValidness:(CGFloat)aValidness persistentValidness:(CGFloat)aValidness2 validnessEvaluator:(id)aEvaluator
{
    self = [super initWithRenderLayer:aLayer affineTransform:aTransform temporaryValidness:aValidness persistentValidness:aValidness2 validnessEvaluator:aEvaluator];
    if (!self)
        return nil;
    _quartzTransitionRenderer = [aRenderer retain];
    _pixelBufferPool = CVPixelBufferPoolRetain(aPool);
    return self;
}

// Made only with a renderer.
- (id)initWithRenderLayer:(id)aLayer affineTransform:(CGAffineTransform)aTransform temporaryValidness:(CGFloat)aValidness persistentValidness:(CGFloat)aValidness2 validnessEvaluator:(id)aEvaluator
{
    [self release];
    return nil;
}

@end
