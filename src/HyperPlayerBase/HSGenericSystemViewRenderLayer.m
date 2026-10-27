#import "HSGenericSystemViewRenderLayer.h"
// Render layer that draws a system object's Cocoa view (or its
// placeholder view) sized to the object's geometry. The view is drawn
// without the current scale, and cached bitmaps are made at integral
// scale factors.

@implementation HSGenericSystemViewRenderLayer

// The source rect in view coordinates for a region of the object.
static NSRect HSGenericSystemViewSourceRect(NSRect aBounds, NSSize aSize, NSRect aFrame)
{
    float scaleX = aFrame.size.width / aSize.width;
    float scaleY = aFrame.size.height / aSize.height;
    return NSMakeRect(scaleX * aBounds.origin.x + aFrame.origin.x, scaleY * aBounds.origin.y + aFrame.origin.y,
                      aBounds.size.width * scaleX, aBounds.size.height * scaleY);
}

- (BOOL)cacheRenderingInRegion:(id)aRegion withAffineTransform:(CGAffineTransform)aTransform validness:(CGFloat)aValidness validnessEvaluator:(id)aEvaluator delegate:(id)aDelegate force:(BOOL)aForce share:(BOOL)aShare resultCache:(id *)aCache
{
    if (aForce && !aCache)
        return YES;
    NSRect bounds = [aRegion boundingRect];
    NSSize size = [_geometryAttributes size];
    NSView *view = [self drawingSystemView];
    [view setFrameSize:NSMakeSize(ceilf(size.width), ceilf(size.height))];
    if (!aForce) {
        // Without force, only views small enough at an integral scale are
        // cached.
        NSSize scale = [view hyperIntegralScaleFactorForScaleFactor:NSMakeSize(aTransform.a, aTransform.d)];
        float maxArea = [[self class] maxBitmapCacheArea];
        float area = scale.height * (bounds.size.height * (scale.width * bounds.size.width));
        if (area > maxArea || !aCache)
            return area <= maxArea;
    }
    float offsetX = bounds.origin.x * aTransform.a;
    float offsetY = bounds.origin.y * aTransform.d;
    NSSize cacheSize = NSMakeSize(aTransform.a * bounds.size.width, aTransform.d * bounds.size.height);
    NSRect sourceRect = HSGenericSystemViewSourceRect(bounds, size, [view frame]);
    id imageRep = nil;
    id cacheTransform = nil;
    [view hyperCacheInSize:cacheSize fromRect:sourceRect flipped:YES withIntegralScaling:YES resultCacheImageRep:&imageRep resultCacheTransform:&cacheTransform];
    aTransform.tx -= offsetX;
    aTransform.ty -= offsetY;
    // The cache's transform maps it into the region; undo the view's own.
    CGAffineTransform inverse = CGAffineTransformInvert([cacheTransform hyperCGAffineTransform]);
    CGAffineTransform transform = CGAffineTransformConcat(aTransform, inverse);
    *aCache = [[[HSGenericImageRenderCache alloc] initWithImageRep:imageRep renderLayer:self affineTransform:transform temporaryValidness:aValidness persistentValidness:[self persistentValidnessForTemporaryValidness:aValidness region:aRegion] validnessEvaluator:aEvaluator] autorelease];
    if (aShare && *aCache)
        [self shareRenderCache:*aCache withValidationAttributes:[self validationAttributesForBitmapRenderCache]];
    return YES;
}

// Caches stay valid under integral scaling only.
- (void)getRenderCacheValidness:(float *)aValidness validnessEvaluator:(id *)aEvaluator includeScaling:(BOOL *)aScaling includeSkewing:(BOOL *)aSkewing includeRotation:(BOOL *)aRotation includeDevicePointAligning:(BOOL *)aAligning forRegion:(id)aRegion affineTransform:(CGAffineTransform)aTransform transformationIntent:(struct HyperPlayerBase_anon12 *)aIntent
{
    if (aValidness)
        *aValidness = 1.0f;
    if (aEvaluator)
        *aEvaluator = [HSIntegralScaleBitmapRenderCacheValidnessEvaluator validnessEvaluatorForScaling:YES skewing:NO rotation:NO offset:NO];
    if (aScaling)
        *aScaling = YES;
    if (aSkewing)
        *aSkewing = NO;
    if (aRotation)
        *aRotation = NO;
    if (aAligning)
        *aAligning = NO;
}

- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce
{
    return YES;
}

- (id)calculateBoundingRegion
{
    return [HSRegion regionWithRect:[_geometryAttributes boundingRect]];
}

- (void)fillBoundingRegionAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSSizeAttribute) forObject:[self hyperObject]];
}

// Draws the view unscaled into the region scaled to device space.
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate
{
    NSAffineTransform *transform = [[NSGraphicsContext currentContext] currentHyperTransform];
    NSSize scale = [transform hyperRemoveScale];
    [transform set];
    NSSize size = [_geometryAttributes size];
    NSRect bounds = [aRegion boundingRect];
    NSRect destination = NSMakeRect(bounds.origin.x * scale.width, bounds.origin.y * scale.height,
                                    bounds.size.width * scale.width, bounds.size.height * scale.height);
    NSView *view = [self drawingSystemView];
    [view setFrameSize:NSMakeSize(ceilf(size.width), ceilf(size.height))];
    NSRect source = HSGenericSystemViewSourceRect(bounds, size, [view frame]);
    [view hyperDrawInRect:destination fromRect:source flipped:YES withIntegralScaling:YES];
}

- (void)fillVisualizationAttributesSet:(id)aSet
{
    id hyperObject = [self hyperObject];
    [aSet addAttribute:@protocol(HSSizeAttribute) forObject:hyperObject];
    [aSet addAttribute:@protocol(HSSystemViewAttribute) forObject:hyperObject];
}

- (id)drawingSystemView
{
    if (_drawsPlaceholderView) {
        id view = [_systemObjectAttributes placeholderSystemView];
        if (view)
            return view;
    }
    return [_systemObjectAttributes hyperSystemView];
}

- (BOOL)drawsPlaceholderView
{
    return _drawsPlaceholderView;
}

- (id)systemObjectAttributes
{
    return _systemObjectAttributes;
}

- (id)geometryAttributes
{
    return _geometryAttributes;
}

- (void)dealloc
{
    [_geometryAttributes release];
    [_systemObjectAttributes release];
    [super dealloc];
}

- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy drawPlaceholderView:(BOOL)aView
{
    self = [super initWithHyperObject:aObject cachingPolicy:aPolicy];
    if (self) {
        _geometryAttributes = [[aObject queryHyperInterface:@protocol(HSGeometryAttributes)] retain];
        if (_geometryAttributes) {
            _systemObjectAttributes = [[aObject queryHyperInterface:@protocol(HSSystemObjectAttributes)] retain];
            if (_systemObjectAttributes) {
                _drawsPlaceholderView = aView;
                return self;
            }
        }
    }
    // (The original returns the released object here.)
    [self release];
    return nil;
}

- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy
{
    return [self initWithHyperObject:aObject cachingPolicy:aPolicy drawPlaceholderView:NO];
}

@end
