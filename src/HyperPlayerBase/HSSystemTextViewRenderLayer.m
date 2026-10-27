#import "HSSystemTextViewRenderLayer.h"
@implementation HSSystemTextViewRenderLayer
// Caches the region's integral bounds in the transform as a bitmap (unless
// it's too large and not forced).
- (BOOL)cacheRenderingInRegion:(id)aRegion withAffineTransform:(CGAffineTransform)aTransform validness:(CGFloat)aValidness validnessEvaluator:(id)aEvaluator delegate:(id)aDelegate force:(BOOL)aForce share:(BOOL)aShare resultCache:(id *)aCache
{
    if (aCache == NULL && aForce)
        return YES;
    HSMutableRegion *region = [[aRegion mutableCopy] autorelease];
    if (region == nil)
        return NO;
    [region applyAffineTransform:aTransform];
    NSRect rect = NSIntegralRect([region boundingRect]);
    if (!aForce && rect.size.width * rect.size.height > [[self class] maxBitmapCacheArea])
        return NO;
    CGFloat persistentValidness = [self persistentValidnessForTemporaryValidness:aValidness region:aRegion];
    id cache = [[self createBitmapRenderCacheWithAffineTransform:aTransform cacheRect:rect temporaryValidness:aValidness
                                             persistentValidness:persistentValidness validnessEvaluator:aEvaluator
                                                        delegate:aDelegate share:aShare] autorelease];
    // The original stored through a NULL result pointer here.
    if (aCache != NULL)
        *aCache = cache;
    return YES;
}
// Rotatable text caches stay valid under any transform, except skewing
// or rotation the intent rules out.
- (void)getRenderCacheValidness:(float *)aValidness validnessEvaluator:(id *)aEvaluator includeScaling:(BOOL *)aScaling includeSkewing:(BOOL *)aSkewing includeRotation:(BOOL *)aRotation includeDevicePointAligning:(BOOL *)aAligning forRegion:(id)aRegion affineTransform:(CGAffineTransform)aTransform transformationIntent:(struct HyperPlayerBase_anon12 *)aIntent
{
    if (![_systemTextViewAttributes isRotatableText]) {
        [super getRenderCacheValidness:aValidness validnessEvaluator:aEvaluator includeScaling:aScaling includeSkewing:aSkewing
                       includeRotation:aRotation includeDevicePointAligning:aAligning forRegion:aRegion affineTransform:aTransform
                  transformationIntent:aIntent];
        return;
    }
    if (aValidness != NULL)
        *aValidness = 1.0f;
    if (aEvaluator != NULL)
        *aEvaluator = [HSBitmapRenderCacheValidnessEvaluator validnessEvaluatorForScaling:YES skewing:YES rotation:YES offset:YES];
    if (aScaling != NULL)
        *aScaling = YES;
    if (aSkewing != NULL)
        *aSkewing = aIntent == NULL || aIntent->f2 != 1;
    if (aRotation != NULL)
        *aRotation = aIntent == NULL || aIntent->f1 != 3;
    if (aAligning != NULL)
        *aAligning = YES;
}
// Rotatable text is drawn by its layout manager directly, through the text
// view's (flipped) transform, only the glyphs in the region.
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate
{
    if (![_systemTextViewAttributes isRotatableText]) {
        [super predrawRegion:aRegion withDelegate:aDelegate];
        return;
    }
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    if (context == NULL)
        return;
    id systemView = [self drawingSystemView];
    if (systemView == nil)
        return;
    NSSize size = [(id<HSSizeAttributes>)[self geometryAttributes] size];
    [systemView setFrame:NSMakeRect(0, 0, ceilf(size.width), ceilf(size.height))];
    NSTextView *textView = [self drawingSystemTextView];
    if (textView == nil)
        return;
    NSLayoutManager *layoutManager = [textView layoutManager];
    if (layoutManager == nil)
        return;
    NSTextContainer *textContainer = [textView textContainer];
    if (textContainer == nil)
        return;
    CGAffineTransform transform = [textView NSE_affineTransformToView:nil];
    transform.b = -transform.b;
    transform.d = -transform.d;
    transform.ty = size.height - transform.ty;
    CGRect rect = CGRectApplyAffineTransform([aRegion boundingRect], CGAffineTransformInvert(transform));
    NSRange glyphRange = [layoutManager glyphRangeForBoundingRect:rect inTextContainer:textContainer];
    if (glyphRange.length == 0)
        return;
    CGContextClipToRect(context, (CGRect){ CGPointZero, { size.width, size.height } });
    CGContextConcatCTM(context, transform);
    NSPoint origin = [textView textContainerOrigin];
    // A horizontally scrolled text starts that far into its bounds.
    float scroll = [_systemTextViewAttributes horizontalScrollPosition];
    float magnitude = scroll != 0 ? fabsf(scroll) : 1.0f;
    float tolerance = magnitude < 1.0f ? 0.0005f : magnitude * 0.0005f;
    if (tolerance < fabsf(scroll))
        origin.x = (1.0f - scroll) * [textView bounds].size.width;
    if (![[NSGraphicsContext currentContext] isFlipped]) {
        [NSGraphicsContext saveGraphicsState];
        [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithCGContext:context flipped:YES]];
        [layoutManager drawBackgroundForGlyphRange:glyphRange atPoint:origin];
        [layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:origin];
        [NSGraphicsContext restoreGraphicsState];
    } else {
        [layoutManager drawBackgroundForGlyphRange:glyphRange atPoint:origin];
        [layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:origin];
    }
}
- (id)drawingSystemTextView
{
    if ([self drawsPlaceholderView]) {
        id placeholder = [_systemTextViewAttributes placeholderSystemTextView];
        if (placeholder != nil)
            return placeholder;
    }
    return [_systemTextViewAttributes systemTextView];
}
- (void)dealloc
{
    [_systemTextViewAttributes release];
    [super dealloc];
}
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy drawPlaceholderView:(BOOL)aView
{
    self = [super initWithHyperObject:aObject cachingPolicy:aPolicy drawPlaceholderView:aView];
    if (self != nil) {
        _systemTextViewAttributes = [[aObject queryHyperInterface:@protocol(HSSystemTextViewAttributes)] retain];
        if (_systemTextViewAttributes != nil)
            return self;
    }
    [self release];
    return nil;
}
@end
