#import "HSShadowAndOpacityRenderLayer.h"
#import <Accelerate/Accelerate.h>
#import "HSMutableMultipleObjectsAttributeSet.h"
#import "HSMutableRegion.h"
#import "HSOpacityRenderLayer.h"
#import "SMKApplicationKitData.h"

// The object's drop shadow and opacity. The layer tree is
//   HSShadowAndOpacityRenderLayer
//     ShadowOpacityRenderLayer (shadow opacity times object opacity)
//       ShadowRenderLayer (fills black through the shadow mask)
//         ShadowMaskRenderLayer (renders the content offset and blurred into a mask)
//     HSOpacityRenderLayer, or the content itself (the object above its shadow)
// The shadow mask reaches the shadow layer through the graphics context: the
// mask's render cache hands it to the context's registered consumer.

// Draws a sublayer the way the render delegate wants it, clipped to its
// bounding region.
static void HSShadowAndOpacityDrawSublayer(id aLayer, id aRegion, id aDelegate)
{
    HSMutableRegion *region = [[[aLayer boundingRegion] mutableCopy] autorelease];
    if (region != nil) {
        [region intersectRegion:aRegion];
        if (![region isEmpty]) {
            [NSGraphicsContext saveGraphicsState];
            if (aDelegate == nil || [aDelegate renderLayerShouldBeDrawnInRegion:region intoRenderCache:NO]) {
                [NSGraphicsContext saveGraphicsState];
                [aLayer drawRegion:region withDelegate:aDelegate];
                [NSGraphicsContext restoreGraphicsState];
                [aDelegate renderLayerIsDrawnInRegion:region intoRenderCache:NO];
            }
            [NSGraphicsContext restoreGraphicsState];
        }
    }
    [aDelegate renderLayerIsRenderedInRegion:aRegion];
}

@implementation HSShadowAndOpacityRenderLayer

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

// The lowest validness of the shadow and the opacity (or content) layers
// where they meet the region; any rotation, skew or scale invalidates.
- (void)getRenderCacheValidness:(float *)aValidness validnessEvaluator:(id *)aEvaluator includeScaling:(BOOL *)aScaling includeSkewing:(BOOL *)aSkewing includeRotation:(BOOL *)aRotation includeDevicePointAligning:(BOOL *)aAligning forRegion:(id)aRegion affineTransform:(CGAffineTransform)aTransform transformationIntent:(struct HyperPlayerBase_anon12 *)aIntent
{
    if (aValidness == NULL && aEvaluator == NULL && aScaling == NULL && aSkewing == NULL && aRotation == NULL && aAligning == NULL)
        return;
    if (aValidness != NULL)
        *aValidness = 1.0f;
    if (aEvaluator != NULL)
        *aEvaluator = nil;
    if (aScaling != NULL)
        *aScaling = YES;
    if (aSkewing != NULL)
        *aSkewing = YES;
    if (aRotation != NULL)
        *aRotation = YES;
    // the original walks a nil-terminated list, so a missing shadow opacity
    // layer stops it before the opacity layer
    id layers[3] = { _shadowOpacityRenderLayer, _opacityRenderLayer, nil };
    BOOL aligning = NO;
    for (int i = 0; layers[i] != nil; i++) {
        HSMutableRegion *region = [[aRegion mutableCopy] autorelease];
        if (region == nil)
            break;
        [region intersectRegion:[layers[i] boundingRegion]];
        if ([region isEmpty])
            continue;
        float validness = 0.0f;
        id evaluator = nil;
        BOOL layerAligning = NO;
        [layers[i] getRenderCacheValidness:aValidness != NULL ? &validness : NULL
                        validnessEvaluator:aEvaluator != NULL ? &evaluator : NULL
                            includeScaling:NULL
                            includeSkewing:NULL
                           includeRotation:NULL
                includeDevicePointAligning:(aAligning != NULL || aEvaluator != NULL) ? &layerAligning : NULL
                                 forRegion:region
                           affineTransform:aTransform
                      transformationIntent:aIntent];
        if (aValidness != NULL && validness < *aValidness)
            *aValidness = validness;
        if (aEvaluator != NULL && evaluator != nil)
            *aEvaluator = *aEvaluator == nil ? evaluator : [*aEvaluator validnessEvaluatorByMergingWithValidnessEvaluator:evaluator];
        aligning = aligning || layerAligning;
    }
    if (aEvaluator != NULL) {
        id evaluator = [HSBitmapRenderCacheValidnessEvaluator validnessEvaluatorForScaling:YES skewing:YES rotation:YES offset:aligning];
        if (*aEvaluator != nil)
            evaluator = [evaluator validnessEvaluatorByMergingWithValidnessEvaluator:*aEvaluator];
        *aEvaluator = evaluator;
    }
    if (aAligning != NULL)
        *aAligning = aligning;
}

- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce
{
    return YES;
}

// The shadow (when enabled) first, then the object.
- (void)drawRenderSublayersInRegion:(id)aRegion withDelegate:(id)aDelegate
{
    id contentLayer = [_shadowOpacityRenderLayer contentRenderLayer];
    if (contentLayer == nil)
        return;
    NSUInteger index = 0;
    if ([_shadowAttributes isHyperShadowEnabled]) {
        id delegate = [aDelegate delegateForRenderSublayerAtIndex:0];
        if (delegate == nil || [delegate renderLayerShouldBeRenderedInRegion:aRegion])
            HSShadowAndOpacityDrawSublayer(_shadowOpacityRenderLayer, aRegion, delegate);
        index = 1;
    }
    id objectLayer = _opacityRenderLayer != nil ? _opacityRenderLayer : contentLayer;
    id delegate = [aDelegate delegateForRenderSublayerAtIndex:index];
    if (delegate != nil && ![delegate renderLayerShouldBeRenderedInRegion:aRegion])
        return;
    HSShadowAndOpacityDrawSublayer(objectLayer, aRegion, delegate);
}

- (BOOL)unionBoundingRegionOfSublayersVisualAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion
{
    id contentLayer = [_shadowOpacityRenderLayer contentRenderLayer];
    if (contentLayer == nil)
        return NO;
    BOOL changed = NO;
    if ([_shadowAttributes isHyperShadowEnabled]) {
        BOOL shadowChanged;
        if ([aSet containsProtocol:@protocol(HSShadowEnabledAttribute)]) {
            // the whole shadow appears or goes
            if (*aRegion == nil)
                *aRegion = [HSMutableRegion region];
            shadowChanged = [_shadowOpacityRenderLayer unionBoundingRegionWithRegion:*aRegion];
        } else {
            shadowChanged = [_shadowOpacityRenderLayer unionBoundingRegionOfConcreteAttributeSet:aSet ofHyperObject:aObject withInfo:aInfo withRegion:aRegion];
        }
        if (shadowChanged)
            changed = YES;
    }
    id objectLayer = _opacityRenderLayer != nil ? _opacityRenderLayer : contentLayer;
    if ([objectLayer unionBoundingRegionOfConcreteAttributeSet:aSet ofHyperObject:aObject withInfo:aInfo withRegion:aRegion])
        changed = YES;
    return changed;
}

- (BOOL)unionBoundingRegionOfLocalVisualAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion
{
    return NO;
}

- (id)calculateBoundingRegion
{
    id contentLayer = [_shadowOpacityRenderLayer contentRenderLayer];
    if (contentLayer == nil)
        return [HSRegion region];
    HSMutableRegion *region = [HSMutableRegion region];
    if ([_shadowAttributes isHyperShadowEnabled])
        [_shadowOpacityRenderLayer unionBoundingRegionWithRegion:region];
    [(_opacityRenderLayer != nil ? _opacityRenderLayer : contentLayer) unionBoundingRegionWithRegion:region];
    return [[region copy] autorelease];
}

- (void)fillBoundingRegionAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSShadowEnabledAttribute) forObject:[self hyperObject]];
}

- (void)fillVisualizationMaskAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSShadowEnabledAttribute) forObject:[self hyperObject]];
    [_shadowOpacityRenderLayer addVisualizationMaskAttributesToSet:aSet];
    [_opacityRenderLayer addVisualizationMaskAttributesToSet:aSet];
}

- (void)fillVisualizationAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSShadowEnabledAttribute) forObject:[self hyperObject]];
    [_shadowOpacityRenderLayer addVisualizationAttributesToSet:aSet];
    [_opacityRenderLayer addVisualizationAttributesToSet:aSet];
}

- (BOOL)isEmpty
{
    id contentLayer = [_shadowOpacityRenderLayer contentRenderLayer];
    return contentLayer == nil || [contentLayer isEmpty];
}

// The shadow chain is made with the first content.
- (void)setContentRenderLayer:(id)aLayer
{
    if (_shadowOpacityRenderLayer == nil) {
        if (aLayer == nil)
            return;
        _shadowOpacityRenderLayer = [[HSShadowAndOpacityRenderLayer_ShadowOpacityRenderLayer alloc] initWithHyperObject:[self hyperObject]
                                                                                                  opacityAttributes:_opacityRenderLayer != nil
                                                                                                      cachingPolicy:[self cachingPolicy]];
        if (_shadowOpacityRenderLayer == nil)
            return;
        [_shadowOpacityRenderLayer addObserver:self];
    }
    [_shadowOpacityRenderLayer setContentRenderLayer:aLayer];
    [_opacityRenderLayer setContentRenderLayer:aLayer];
    [self visualizationAttributesSetDidChange:nil];
    [self boundingRegionDidChange];
}

- (id)contentRenderLayer
{
    return [_shadowOpacityRenderLayer contentRenderLayer];
}

- (BOOL)transparencyLayerRequirementAdditionFlagOfRenderSublayerAtIndex:(NSUInteger)aIndex
{
    return aIndex == 1;
}

- (BOOL)rootFlagOfRenderSublayerAtIndex:(NSUInteger)aIndex
{
    return NO;
}

- (id)roleOfRenderSublayerAtIndex:(NSUInteger)aIndex
{
    NSString *objectRole = _opacityRenderLayer != nil ? @"HSOpacityRenderLayerRole" : @"HSContentRenderLayerRole";
    if (aIndex == 0)
        return [_shadowAttributes isHyperShadowEnabled] ? @"HSShadowOpacityRenderLayerRole" : objectRole;
    if (aIndex == 1)
        return objectRole;
    return nil;
}

- (id)renderSublayerAtIndex:(NSUInteger)aIndex
{
    if (aIndex == 0 && [_shadowAttributes isHyperShadowEnabled])
        return _shadowOpacityRenderLayer;
    if (aIndex > 1)
        return nil;
    if (_opacityRenderLayer != nil)
        return _opacityRenderLayer;
    return [_shadowOpacityRenderLayer contentRenderLayer];
}

- (NSUInteger)renderSublayerCount
{
    if ([_shadowOpacityRenderLayer contentRenderLayer] == nil)
        return 0;
    return [_shadowAttributes isHyperShadowEnabled] ? 2 : 1;
}

- (id)renderSublayers
{
    id contentLayer = [_shadowOpacityRenderLayer contentRenderLayer];
    if (contentLayer == nil)
        return [NSArray array];
    id objectLayer = _opacityRenderLayer != nil ? _opacityRenderLayer : contentLayer;
    if ([_shadowAttributes isHyperShadowEnabled])
        return [NSArray arrayWithObjects:_shadowOpacityRenderLayer, objectLayer, nil];
    return [NSArray arrayWithObject:objectLayer];
}

- (id)copyRemovingRenderSublayers
{
    return [[[self class] allocWithZone:[self zone]] initWithHyperObject:[self hyperObject] opacityAttributes:_opacityRenderLayer != nil cachingPolicy:[self cachingPolicy]];
}

- (void)dealloc
{
    [_shadowOpacityRenderLayer removeObserver:self];
    [_shadowOpacityRenderLayer release];
    [_opacityRenderLayer removeObserver:self];
    [_opacityRenderLayer release];
    [_shadowAttributes release];
    [super dealloc];
}

- (id)initWithHyperObject:(id)aObject opacityAttributes:(BOOL)aAttributes cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject cachingPolicy:aPolicy];
    if (self == nil)
        return nil;
    _shadowAttributes = [[aObject queryHyperInterface:@protocol(HSShadowAttributes)] retain];
    if (_shadowAttributes == nil) {
        [self release];
        return nil;
    }
    if (aAttributes) {
        _opacityRenderLayer = [[HSOpacityRenderLayer alloc] initWithHyperObject:aObject cachingPolicy:aPolicy];
        if (_opacityRenderLayer == nil) {
            [self release];
            return nil;
        }
        [_opacityRenderLayer addObserver:self];
    }
    return self;
}

- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy
{
    return [self initWithHyperObject:aObject opacityAttributes:NO cachingPolicy:aPolicy];
}

@end

// Draws the shadow at the shadow opacity (times the object's opacity).
@implementation HSShadowAndOpacityRenderLayer_ShadowOpacityRenderLayer

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

- (void)getRenderCacheValidness:(float *)aValidness validnessEvaluator:(id *)aEvaluator includeScaling:(BOOL *)aScaling includeSkewing:(BOOL *)aSkewing includeRotation:(BOOL *)aRotation includeDevicePointAligning:(BOOL *)aAligning forRegion:(id)aRegion affineTransform:(CGAffineTransform)aTransform transformationIntent:(struct HyperPlayerBase_anon12 *)aIntent
{
    [_shadowRenderLayer getRenderCacheValidness:aValidness validnessEvaluator:aEvaluator includeScaling:aScaling includeSkewing:aSkewing includeRotation:aRotation includeDevicePointAligning:aAligning forRegion:aRegion affineTransform:aTransform transformationIntent:aIntent];
}

- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce
{
    return YES;
}

// The original sets the context alpha outside a saved graphics state, so it
// outlives this call (the caller's state is restored around it); kept.
- (void)drawRenderSublayersInRegion:(id)aRegion withDelegate:(id)aDelegate
{
    if ([_shadowRenderLayer contentRenderLayer] == nil)
        return;
    float opacity = (float)[_shadowAttributes hyperShadowOpacity];
    if (_opacityAttributes != nil)
        opacity *= (float)[_opacityAttributes hyperOpacity];
    if (opacity >= -0.001953125f && opacity <= 0.001953125f)
        return;
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    if (context == NULL)
        return;
    CGContextSetAlpha(context, opacity);
    id delegate = [aDelegate delegateForRenderSublayerAtIndex:0];
    if (delegate != nil && ![delegate renderLayerShouldBeRenderedInRegion:aRegion])
        return;
    HSShadowAndOpacityDrawSublayer(_shadowRenderLayer, aRegion, delegate);
}

- (BOOL)unionBoundingRegionOfConcreteAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion
{
    if (_shadowRenderLayer == nil)
        return NO;
    id attributes = [[self visualizationAttributes] attributesForObject:aObject];
    if ([attributes count] == 0)
        return NO;
    id changes = [[aSet mutableCopy] autorelease];
    if (changes == nil)
        return NO;
    [changes intersectProtocolSet:attributes];
    if ([changes count] == 0)
        return NO;
    // an opacity change redraws the whole shadow
    if ([changes containsProtocol:@protocol(HSShadowOpacityAttribute)]
        || (_opacityAttributes != nil && [changes containsProtocol:@protocol(HSOpacityAttribute)])) {
        if (*aRegion == nil)
            *aRegion = [HSMutableRegion region];
        return [self unionBoundingRegionWithRegion:*aRegion];
    }
    return [_shadowRenderLayer unionBoundingRegionOfConcreteAttributeSet:changes ofHyperObject:aObject withInfo:aInfo withRegion:aRegion];
}

- (id)calculateBoundingRegion
{
    if (_shadowRenderLayer == nil)
        return [HSRegion region];
    return [_shadowRenderLayer boundingRegion];
}

- (void)fillVisualizationMaskAttributesSet:(id)aSet
{
    id object = [self hyperObject];
    if (_opacityAttributes != nil)
        [aSet addAttribute:@protocol(HSOpacityAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSShadowOpacityAttribute) forObject:object];
    [_shadowRenderLayer addVisualizationMaskAttributesToSet:aSet];
}

- (void)fillVisualizationAttributesSet:(id)aSet
{
    id object = [self hyperObject];
    if (_opacityAttributes != nil)
        [aSet addAttribute:@protocol(HSOpacityAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSShadowOpacityAttribute) forObject:object];
    [_shadowRenderLayer addVisualizationAttributesToSet:aSet];
}

- (BOOL)isEmpty
{
    return _shadowRenderLayer == nil || [_shadowRenderLayer isEmpty];
}

- (void)setContentRenderLayer:(id)aLayer
{
    if (_shadowRenderLayer == nil) {
        if (aLayer == nil)
            return;
        _shadowRenderLayer = [[HSShadowAndOpacityRenderLayer_ShadowRenderLayer alloc] initWithHyperObject:[self hyperObject] cachingPolicy:[self cachingPolicy]];
        if (_shadowRenderLayer == nil)
            return;
        [_shadowRenderLayer addObserver:self];
    }
    [_shadowRenderLayer setContentRenderLayer:aLayer];
    [self visualizationAttributesSetDidChange:nil];
    [self boundingRegionDidChange];
}

- (id)contentRenderLayer
{
    return [_shadowRenderLayer contentRenderLayer];
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
    return @"HSShadowRenderLayerRole";
}

- (id)renderSublayerAtIndex:(NSUInteger)aIndex
{
    return _shadowRenderLayer;
}

- (NSUInteger)renderSublayerCount
{
    return [_shadowRenderLayer contentRenderLayer] != nil;
}

- (id)renderSublayers
{
    if ([_shadowRenderLayer contentRenderLayer] == nil)
        return [NSArray array];
    return [NSArray arrayWithObject:_shadowRenderLayer];
}

- (id)copyRemovingRenderSublayers
{
    return [[[self class] allocWithZone:[self zone]] initWithHyperObject:[self hyperObject] opacityAttributes:_opacityAttributes != nil cachingPolicy:[self cachingPolicy]];
}

- (void)dealloc
{
    [_shadowRenderLayer removeObserver:self];
    [_shadowRenderLayer release];
    [_shadowAttributes release];
    [_opacityAttributes release];
    [super dealloc];
}

// With opacity attributes the shadow also fades with the object.
- (id)initWithHyperObject:(id)aObject opacityAttributes:(BOOL)aAttributes cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject cachingPolicy:aPolicy];
    if (self == nil)
        return nil;
    _shadowAttributes = [[aObject queryHyperInterface:@protocol(HSShadowAttributes)] retain];
    if (_shadowAttributes == nil) {
        [self release];
        return nil;
    }
    if (aAttributes) {
        _opacityAttributes = [[aObject queryHyperInterface:@protocol(HSOpacityAttributes)] retain];
        if (_opacityAttributes == nil) {
            [self release];
            return nil;
        }
    }
    return self;
}

- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy
{
    return [self initWithHyperObject:aObject opacityAttributes:NO cachingPolicy:aPolicy];
}

@end

// Fills black through the shadow mask its mask layer hands it while drawing.
@implementation HSShadowAndOpacityRenderLayer_ShadowRenderLayer

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

- (void)getRenderCacheValidness:(float *)aValidness validnessEvaluator:(id *)aEvaluator includeScaling:(BOOL *)aScaling includeSkewing:(BOOL *)aSkewing includeRotation:(BOOL *)aRotation includeDevicePointAligning:(BOOL *)aAligning forRegion:(id)aRegion affineTransform:(CGAffineTransform)aTransform transformationIntent:(struct HyperPlayerBase_anon12 *)aIntent
{
    [_shadowMaskRenderLayer getRenderCacheValidness:aValidness validnessEvaluator:NULL includeScaling:NULL includeSkewing:NULL includeRotation:NULL includeDevicePointAligning:NULL forRegion:aRegion affineTransform:aTransform transformationIntent:aIntent];
    if (aEvaluator != NULL)
        *aEvaluator = [HSBitmapRenderCacheValidnessEvaluator validnessEvaluatorForScaling:YES skewing:YES rotation:YES offset:YES];
    if (aScaling != NULL)
        *aScaling = YES;
    if (aSkewing != NULL)
        *aSkewing = YES;
    if (aRotation != NULL)
        *aRotation = YES;
    if (aAligning != NULL)
        *aAligning = YES;
}

- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce
{
    return YES;
}

// The mask layer draws with this layer registered as the context's mask
// consumer; the mask it hands over is then filled black and dropped.
- (void)drawRenderSublayersInRegion:(id)aRegion withDelegate:(id)aDelegate
{
    if ([_shadowMaskRenderLayer contentRenderLayer] == nil)
        return;
    id delegate = [aDelegate delegateForRenderSublayerAtIndex:0];
    if (delegate != nil && ![delegate renderLayerShouldBeRenderedInRegion:aRegion])
        return;
    NSGraphicsContext *graphicsContext = [NSGraphicsContext currentContext];
    HSMutableRegion *region = [[[_shadowMaskRenderLayer boundingRegion] mutableCopy] autorelease];
    if (region != nil) {
        [region intersectRegion:aRegion];
        if (![region isEmpty]) {
            [graphicsContext HSShadowAndOpacityRenderLayer_ShadowMaskConsumer_setShadowMaskConsumer:self];
            [NSGraphicsContext saveGraphicsState];
            if (delegate == nil || [delegate renderLayerShouldBeDrawnInRegion:region intoRenderCache:NO]) {
                [NSGraphicsContext saveGraphicsState];
                [_shadowMaskRenderLayer drawRegion:region withDelegate:delegate];
                [NSGraphicsContext restoreGraphicsState];
                [delegate renderLayerIsDrawnInRegion:region intoRenderCache:NO];
            }
            [NSGraphicsContext restoreGraphicsState];
            [graphicsContext HSShadowAndOpacityRenderLayer_ShadowMaskConsumer_setShadowMaskConsumer:nil];
        }
    }
    [delegate renderLayerIsRenderedInRegion:aRegion];
    if (_shadowMask == NULL)
        return;
    CGContextRef context = [graphicsContext CGContext];
    CGColorSpaceRef space;
    if (context != NULL && (space = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB)) != NULL) {
        CGContextSetFillColorSpace(context, space);
        CGColorSpaceRelease(space);
        const CGFloat black[4] = { 0.0, 0.0, 0.0, 1.0 };
        CGContextSetFillColor(context, black);
        CGContextConcatCTM(context, _shadowMaskTransform);
        CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
        CGRect maskRect = CGRectMake(0.0, 0.0, (float)CGImageGetWidth(_shadowMask), (float)CGImageGetHeight(_shadowMask));
        CGContextClipToMask(context, maskRect, _shadowMask);
        CGContextFillRect(context, maskRect);
    }
    CGImageRelease(_shadowMask);
    _shadowMask = NULL;
}

// The original retained the new mask without releasing an unused old one.
- (void)HSShadowAndOpacityRenderLayer_ShadowMaskConsumer_setShadowMask:(struct CGImage *)aMask transform:(CGAffineTransform)aTransform
{
    CGImageRef old = _shadowMask;
    _shadowMask = CGImageRetain(aMask);
    CGImageRelease(old);
    _shadowMaskTransform = aTransform;
}

- (BOOL)unionBoundingRegionOfSublayersVisualAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion
{
    return [_shadowMaskRenderLayer unionBoundingRegionOfConcreteAttributeSet:aSet ofHyperObject:aObject withInfo:aInfo withRegion:aRegion];
}

- (BOOL)unionBoundingRegionOfLocalVisualAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion
{
    return NO;
}

- (id)calculateBoundingRegion
{
    if (_shadowMaskRenderLayer == nil)
        return [HSRegion region];
    return [_shadowMaskRenderLayer boundingRegion];
}

- (void)fillVisualizationMaskAttributesSet:(id)aSet
{
    [_shadowMaskRenderLayer addVisualizationMaskAttributesToSet:aSet];
}

- (void)fillVisualizationAttributesSet:(id)aSet
{
    [_shadowMaskRenderLayer addVisualizationAttributesToSet:aSet];
}

- (BOOL)isEmpty
{
    return _shadowMaskRenderLayer == nil || [_shadowMaskRenderLayer isEmpty];
}

- (void)setContentRenderLayer:(id)aLayer
{
    if (_shadowMaskRenderLayer == nil) {
        if (aLayer == nil)
            return;
        _shadowMaskRenderLayer = [[HSShadowAndOpacityRenderLayer_ShadowMaskRenderLayer alloc] initWithHyperObject:[self hyperObject] cachingPolicy:[self cachingPolicy]];
        if (_shadowMaskRenderLayer == nil)
            return;
        [_shadowMaskRenderLayer addObserver:self];
    }
    [_shadowMaskRenderLayer setContentRenderLayer:aLayer];
    [self visualizationAttributesSetDidChange:nil];
    [self boundingRegionDidChange];
}

- (id)contentRenderLayer
{
    return [_shadowMaskRenderLayer contentRenderLayer];
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
    return @"HSShadowMaskRenderLayerRole";
}

- (id)renderSublayerAtIndex:(NSUInteger)aIndex
{
    return _shadowMaskRenderLayer;
}

- (NSUInteger)renderSublayerCount
{
    return [_shadowMaskRenderLayer contentRenderLayer] != nil;
}

- (id)renderSublayers
{
    if ([_shadowMaskRenderLayer contentRenderLayer] == nil)
        return [NSArray array];
    return [NSArray arrayWithObject:_shadowMaskRenderLayer];
}

- (id)copyRemovingRenderSublayers
{
    return [[[self class] allocWithZone:[self zone]] initWithHyperObject:[self hyperObject] cachingPolicy:[self cachingPolicy]];
}

// The original did not release a mask still held.
- (void)dealloc
{
    [_shadowMaskRenderLayer removeObserver:self];
    [_shadowMaskRenderLayer release];
    CGImageRelease(_shadowMask);
    [super dealloc];
}

- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy
{
    return [super initWithHyperObject:aObject cachingPolicy:aPolicy];
}

@end

// Blur kernels are capped at this many device pixels; past it the mask is
// rendered at a lower resolution instead.
static const float HSShadowMaskMaxBlurRadius = 30.0f;

// Renders the content, offset by the shadow offset, into an alpha mask and
// blurs it. The mask goes out through its render cache.
@implementation HSShadowAndOpacityRenderLayer_ShadowMaskRenderLayer

- (void)renderLayerWantsToReexpand:(id)aReexpand
{
    [self notifyObserversWithSelector:@selector(renderLayerWantsToReexpand:)];
}

- (void)renderLayerDidChangeBoundingRegion:(id)aRegion
{
    [self boundingRegionDidChange];
}

// Forgets which attributes the content depends on.
- (void)renderLayerDidChangeVisualizationMaskAttributesSet:(id)aSet
{
    _isHorizontalScaleInContentFlagInitialized = 0;
    _isVerticalScaleInContentFlagInitialized = 0;
    _isWidthScaleInContentFlagInitialized = 0;
    _isHeightScaleInContentFlagInitialized = 0;
    _isHorizontalFlipInContentFlagInitialized = 0;
    _isVerticalFlipInContentFlagInitialized = 0;
    _isRotationAngleInContentFlagInitialized = 0;
    _isSkewAngleInContentFlagInitialized = 0;
    _isShadowOffsetInContentFlagInitialized = 0;
    [self visualizationAttributesSetDidChange:nil];
}

- (void)renderLayerDidChangeVisualizationAttributesSet:(id)aSet
{
}

// The cache keeps the shadow offset it was made with (in object space), so a
// later offset change can just move it.
- (BOOL)cacheRenderingInRegion:(id)aRegion withAffineTransform:(CGAffineTransform)aTransform validness:(CGFloat)aValidness validnessEvaluator:(id)aEvaluator delegate:(id)aDelegate force:(BOOL)aForce share:(BOOL)aShare resultCache:(id *)aCache
{
    if (aCache == NULL && aForce)
        return YES;
    CGImageRef mask = NULL;
    CGAffineTransform maskTransform = CGAffineTransformIdentity;
    float maxArea = aForce ? FLT_MAX : (float)[[self class] maxBitmapCacheArea];
    if (![self HSShadowAndOpacityRenderLayer_ShadowMaskRenderLayer_createShadowMask:aCache != NULL ? &mask : NULL
                                                                           transform:aCache != NULL ? &maskTransform : NULL
                                                                           forRegion:aRegion
                                                                     deviceTransform:aTransform
                                                                        withDelegate:aDelegate
                                                                             maxArea:maxArea])
        return NO;
    if (aCache == NULL)
        return YES;
    *aCache = [[[HSShadowAndOpacityRenderLayer_ShadowMaskRenderCache alloc] initWithShadowMask:mask
                                                                                    renderLayer:self
                                                                                affineTransform:maskTransform
                                                                             temporaryValidness:aValidness
                                                                            persistentValidness:[self persistentValidnessForTemporaryValidness:aValidness region:aRegion]
                                                                             validnessEvaluator:aEvaluator] autorelease];
    CGImageRelease(mask);
    if (*aCache == nil)
        return NO;
    CGAffineTransform inverse = CGAffineTransformInvert([_geometryAttributes affineTransform]);
    float horizontalOffset = (float)[_shadowAttributes hyperHorizontalShadowOffset];
    float verticalOffset = (float)[_shadowAttributes hyperVerticalShadowOffset];
    NSSize offset = NSMakeSize(horizontalOffset * (float)inverse.a - verticalOffset * (float)inverse.c,
                               (float)inverse.b * horizontalOffset - (float)inverse.d * verticalOffset);
    [*aCache setAttachment:[NSValue valueWithSize:offset] forKey:@"HSObjectShadowOffset"];
    if (aShare)
        [self shareRenderCache:*aCache withValidationAttributes:[self validationAttributesForBitmapRenderCache]];
    return YES;
}

- (id)continuousChangeSensitiveVisualizationAttributes
{
    return [[[HSMultipleObjectsAttributeSet alloc] init] autorelease];
}

// Whether the content's own drawing depends on the attribute (cached until
// the content's mask attributes change).
#define HS_ATTRIBUTE_IN_CONTENT(flag, protocolName)                                                                         \
    ({                                                                                                                      \
        if (!flag##FlagInitialized) {                                                                                       \
            flag##FlagInitialized = 1;                                                                                      \
            flag = [[_contentRenderLayer visualizationMaskAttributes] includesAttribute:@protocol(protocolName) forObject:[self hyperObject]] ? 1 : 0; \
        }                                                                                                                   \
        (BOOL)flag;                                                                                                         \
    })

// Geometry and shadow offset changes that the content doesn't draw with only
// move the cached mask: its transform is shifted by the change in the shadow
// offset. Anything else invalidates as usual.
- (void)invalidateRenderCache:(id)aCache withAttributeChangeNotification:(id)aNotification
{
    id changes = aNotification != nil ? [aNotification attributeProtocolSet] : nil;
    id object = aNotification != nil ? [aNotification object] : nil;
    if (changes != nil && object != nil && [[[self visualizationAttributes] attributesForObject:object] count] != 0) {
        changes = [[changes mutableCopy] autorelease];
        if (changes != nil) {
            [changes intersectProtocolSet:[[self visualizationAttributes] attributesForObject:object]];
            if ([changes count] != 0) {
                NSUInteger handled = 0;
                BOOL inContent = NO;
                if ([changes containsProtocol:@protocol(HSHorizontalScaleAttribute)]) {
                    handled++;
                    inContent = HS_ATTRIBUTE_IN_CONTENT(_isHorizontalScaleInContent, HSHorizontalScaleAttribute) || inContent;
                }
                if ([changes containsProtocol:@protocol(HSVerticalScaleAttribute)]) {
                    handled++;
                    inContent = HS_ATTRIBUTE_IN_CONTENT(_isVerticalScaleInContent, HSVerticalScaleAttribute) || inContent;
                }
                if ([changes containsProtocol:@protocol(HSWidthScaleAttribute)]) {
                    handled++;
                    inContent = HS_ATTRIBUTE_IN_CONTENT(_isWidthScaleInContent, HSWidthScaleAttribute) || inContent;
                }
                if ([changes containsProtocol:@protocol(HSHeightScaleAttribute)]) {
                    handled++;
                    inContent = HS_ATTRIBUTE_IN_CONTENT(_isHeightScaleInContent, HSHeightScaleAttribute) || inContent;
                }
                if ([changes containsProtocol:@protocol(HSHorizontalFlipAttribute)]) {
                    handled++;
                    inContent = HS_ATTRIBUTE_IN_CONTENT(_isHorizontalFlipInContent, HSHorizontalFlipAttribute) || inContent;
                }
                if ([changes containsProtocol:@protocol(HSVerticalFlipAttribute)]) {
                    handled++;
                    inContent = HS_ATTRIBUTE_IN_CONTENT(_isVerticalFlipInContent, HSVerticalFlipAttribute) || inContent;
                }
                if ([changes containsProtocol:@protocol(HSRotationAngleAttribute)]) {
                    handled++;
                    inContent = HS_ATTRIBUTE_IN_CONTENT(_isRotationAngleInContent, HSRotationAngleAttribute) || inContent;
                }
                if ([changes containsProtocol:@protocol(HSSkewAngleAttribute)]) {
                    handled++;
                    inContent = HS_ATTRIBUTE_IN_CONTENT(_isSkewAngleInContent, HSSkewAngleAttribute) || inContent;
                }
                if ([changes containsProtocol:@protocol(HSShadowOffsetAttribute)]) {
                    handled++;
                    inContent = HS_ATTRIBUTE_IN_CONTENT(_isShadowOffsetInContent, HSShadowOffsetAttribute) || inContent;
                }
                id cachedOffset = handled != 0 ? [aCache attachmentForKey:@"HSObjectShadowOffset"] : nil;
                if (cachedOffset != nil) {
                    NSSize oldOffset = [cachedOffset sizeValue];
                    CGAffineTransform inverse = CGAffineTransformInvert([_geometryAttributes affineTransform]);
                    float horizontalOffset = (float)[_shadowAttributes hyperHorizontalShadowOffset];
                    float verticalOffset = (float)[_shadowAttributes hyperVerticalShadowOffset];
                    float width = horizontalOffset * (float)inverse.a - verticalOffset * (float)inverse.c;
                    float height = horizontalOffset * (float)inverse.b - verticalOffset * (float)inverse.d;
                    CGAffineTransform transform = [aCache affineTransform];
                    float dx = (float)oldOffset.width - width;
                    float dy = (float)oldOffset.height - height;
                    transform.tx = (float)transform.a * dx + (float)transform.c * dy + (float)transform.tx;
                    transform.ty = dx * (float)transform.b + dy * (float)transform.d + (float)transform.ty;
                    [aCache setAffineTransform:transform];
                    [aCache setAttachment:[NSValue valueWithSize:NSMakeSize(width, height)] forKey:@"HSObjectShadowOffset"];
                    if (!inContent && [changes count] == handled)
                        return;
                }
            }
        }
    }
    [super invalidateRenderCache:aCache withAttributeChangeNotification:aNotification];
}

#undef HS_ATTRIBUTE_IN_CONTENT

// A blurred mask can be scaled (within limits: see the evaluator) but not
// skewed or rotated.
- (void)getRenderCacheValidness:(float *)aValidness validnessEvaluator:(id *)aEvaluator includeScaling:(BOOL *)aScaling includeSkewing:(BOOL *)aSkewing includeRotation:(BOOL *)aRotation includeDevicePointAligning:(BOOL *)aAligning forRegion:(id)aRegion affineTransform:(CGAffineTransform)aTransform transformationIntent:(struct HyperPlayerBase_anon12 *)aIntent
{
    BOOL scaling = NO, skewing = NO, rotation = NO, aligning = NO;
    [(HSGenericRenderLayer *)_contentRenderLayer getRenderCacheValidness:aValidness
                              validnessEvaluator:NULL
                                  includeScaling:(aScaling != NULL || aEvaluator != NULL) ? &scaling : NULL
                                  includeSkewing:(aSkewing != NULL || aEvaluator != NULL) ? &skewing : NULL
                                 includeRotation:(aRotation != NULL || aEvaluator != NULL) ? &rotation : NULL
                      includeDevicePointAligning:(aAligning != NULL || aEvaluator != NULL) ? &aligning : NULL
                                       forRegion:aRegion
                                 affineTransform:aTransform
                            transformationIntent:aIntent];
    float blurRadius = (float)[_shadowAttributes hyperShadowBlurRadius];
    if (aEvaluator != NULL) {
        if (blurRadius != 0.0f) {
            CGAffineTransform local = CGAffineTransformConcat(CGAffineTransformInvert([_geometryAttributes affineTransform]), aTransform);
            float horizontalScale = hypotf((float)local.a, (float)local.b);
            float verticalScale = hypotf((float)local.c, (float)local.d);
            *aEvaluator = [[[HSShadowAndOpacityRenderLayer_ShadowMaskRenderCacheValidnessEvaluator alloc]
                initWithBlurRadiusMaximizedHorizontally:horizontalScale * blurRadius >= HSShadowMaskMaxBlurRadius
                                             vertically:verticalScale * blurRadius >= HSShadowMaskMaxBlurRadius
                                   toEvaluateForScaling:YES
                                                skewing:NO
                                               rotation:NO
                                                 offset:NO] autorelease];
        } else {
            *aEvaluator = [HSBitmapRenderCacheValidnessEvaluator validnessEvaluatorForScaling:scaling skewing:skewing rotation:rotation offset:aligning];
        }
    }
    if (aScaling != NULL)
        *aScaling = scaling || blurRadius > 0.0f;
    if (aSkewing != NULL)
        *aSkewing = skewing && blurRadius == 0.0f;
    if (aRotation != NULL)
        *aRotation = rotation && blurRadius == 0.0f;
    if (aAligning != NULL)
        *aAligning = aligning && blurRadius == 0.0f;
}

- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce
{
    return YES;
}

// Always drawn through a cache (the mask reaches the consumer from there).
- (void)drawRenderSublayersInRegion:(id)aRegion withDelegate:(id)aDelegate
{
    id cache = nil;
    NSGraphicsContext *graphicsContext = [NSGraphicsContext currentContext];
    BOOL exclusive = [[[aDelegate renderLayerWillCacheDrawingInRegion:aRegion] objectForKey:@"HSExclusiveRenderCacheKey"] boolValue];
    CGContextRef context = [graphicsContext CGContext];
    [self cacheRenderingInRegion:aRegion forAffineTransform:CGContextGetCTM(context) withTransformationIntent:NULL acceptableValidnessLimit:1.0 delegate:aDelegate force:YES share:!exclusive resultCache:&cache];
    [aDelegate renderLayerDidCacheDrawingInRegion:aRegion intoRenderCache:cache];
    [cache drawRegion:aRegion];
}

// Renders the content for the shadow region (offset back by the shadow
// offset) into an 8-bit alpha mask in device space, blurs it with a
// Gaussian, and returns it with the transform to draw it with. Blur radii
// past 30 device pixels are reached by rendering at a lower resolution.
// Only checks the size against maxArea when aMask is NULL.
- (BOOL)HSShadowAndOpacityRenderLayer_ShadowMaskRenderLayer_createShadowMask:(struct CGImage **)aMask transform:(CGAffineTransform *)aTransform forRegion:(id)aRegion deviceTransform:(CGAffineTransform)aTransform2 withDelegate:(id)aDelegate maxArea:(CGFloat)aArea
{
    if (_contentRenderLayer == nil)
        return NO;
    HSMutableRegion *contentRegion = [self contentRegionForShadowRegion:aRegion];
    if (contentRegion == nil)
        return NO;
    id contentBounds = [_contentRenderLayer boundingRegion];
    if (contentBounds == nil)
        return NO;
    [contentRegion intersectRegion:contentBounds];
    if ([contentRegion isEmpty])
        return NO;

    CGAffineTransform geometry = [_geometryAttributes affineTransform];
    CGAffineTransform local = CGAffineTransformConcat(CGAffineTransformInvert(geometry), aTransform2);
    float horizontalScale = hypotf((float)local.a, (float)local.b);
    float verticalScale = hypotf((float)local.c, (float)local.d);
    float verticalOffset = (float)[_shadowAttributes hyperVerticalShadowOffset];
    float horizontalOffset = (float)[_shadowAttributes hyperHorizontalShadowOffset];
    CGAffineTransform shifted = geometry;
    shifted.tx = (float)geometry.tx + horizontalOffset;
    shifted.ty = (float)geometry.ty - verticalOffset;
    CGAffineTransform device = CGAffineTransformConcat(shifted, local);

    float blurRadius = (float)[_shadowAttributes hyperShadowBlurRadius];
    float horizontalBlur = horizontalScale * blurRadius;
    float verticalBlur = blurRadius * verticalScale;
    float horizontalKernelBlur, verticalKernelBlur, horizontalFactor, verticalFactor;
    if (horizontalBlur > HSShadowMaskMaxBlurRadius) {
        horizontalKernelBlur = HSShadowMaskMaxBlurRadius;
        horizontalFactor = HSShadowMaskMaxBlurRadius / horizontalBlur;
    } else {
        horizontalFactor = 1.0f;
        horizontalKernelBlur = horizontalBlur;
    }
    if (verticalBlur > HSShadowMaskMaxBlurRadius) {
        verticalKernelBlur = HSShadowMaskMaxBlurRadius;
        verticalFactor = HSShadowMaskMaxBlurRadius / verticalBlur;
    } else {
        verticalFactor = 1.0f;
        verticalKernelBlur = verticalBlur;
    }
    HSMutableRegion *deviceRegion = [(HSMutableRegion *)[[contentRegion mutableCopy] autorelease] applyAffineTransform:device];
    if (deviceRegion == nil)
        return NO;
    NSRect bounds = NSIntegralRect(NSInsetRect([deviceRegion boundingRect], horizontalBlur * -2.0f, verticalBlur * -2.0f));
    CGAffineTransform drawTransform;
    drawTransform.a = (float)device.a * horizontalFactor;
    drawTransform.b = (float)device.b * verticalFactor;
    drawTransform.c = (float)device.c * horizontalFactor;
    drawTransform.d = (float)device.d * verticalFactor;
    drawTransform.tx = ((float)device.tx - (float)NSMinX(bounds)) * horizontalFactor;
    drawTransform.ty = ((float)device.ty - (float)NSMinY(bounds)) * verticalFactor;
    float scaledWidth = (float)NSWidth(bounds) * horizontalFactor;
    float scaledHeight = (float)NSHeight(bounds) * verticalFactor;
    size_t width = scaledWidth > 0.0f ? (size_t)lroundf(ceilf(scaledWidth)) : 0;
    size_t height = scaledHeight > 0.0f ? (size_t)lroundf(ceilf(scaledHeight)) : 0;
    if (aArea < (float)height * (float)width)
        return NO;
    if (aMask == NULL)
        return YES;

    size_t rowBytes = (width + 15) & ~(size_t)15;
    CFIndex dataLength = (CFIndex)(rowBytes * height);
    CFMutableDataRef data = CFDataCreateMutable(kCFAllocatorDefault, dataLength);
    if (data == NULL)
        return NO;
    CFDataSetLength(data, dataLength);
    vImage_Buffer source = { CFDataGetMutableBytePtr(data), height, width, rowBytes };
    CGContextRef context = CGBitmapContextCreate(source.data, width, height, 8, rowBytes, NULL, (CGBitmapInfo)kCGImageAlphaOnly);
    if (context == NULL) {
        CFRelease(data);
        return NO;
    }
    CGContextConcatCTM(context, drawTransform);
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSGraphicsContext *graphicsContext = [NSGraphicsContext graphicsContextWithCGContext:context flipped:YES];
    CGContextRelease(context);
    if (graphicsContext == nil) {
        [pool release];
        CFRelease(data);
        return NO;
    }
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:graphicsContext];
    id delegate = [aDelegate delegateForRenderSublayerAtIndex:0];
    if (delegate == nil || [delegate renderLayerShouldBeRenderedInRegion:contentRegion]) {
        [NSGraphicsContext saveGraphicsState];
        if (delegate == nil || [delegate renderLayerShouldBeDrawnInRegion:contentRegion intoRenderCache:NO]) {
            [NSGraphicsContext saveGraphicsState];
            [_contentRenderLayer drawRegion:contentRegion withDelegate:delegate];
            [NSGraphicsContext restoreGraphicsState];
            [delegate renderLayerIsDrawnInRegion:contentRegion intoRenderCache:NO];
        }
        [NSGraphicsContext restoreGraphicsState];
        [delegate renderLayerIsRenderedInRegion:aRegion];
    }
    [NSGraphicsContext restoreGraphicsState];
    [pool release];

    if (horizontalKernelBlur != 0.0f || verticalKernelBlur != 0.0f) {
        // an elliptical Gaussian kernel (odd sizes), 8.8 fixed point
        CFMutableDataRef blurred = CFDataCreateMutable(kCFAllocatorDefault, dataLength);
        if (blurred == NULL) {
            CFRelease(data);
            return NO;
        }
        CFDataSetLength(blurred, dataLength);
        uint32_t kernelWidthBase = horizontalKernelBlur + horizontalKernelBlur > 0.0f ? (uint32_t)lroundf(ceilf(horizontalKernelBlur + horizontalKernelBlur)) : 0;
        uint32_t kernelHeightBase = verticalKernelBlur + verticalKernelBlur > 0.0f ? (uint32_t)lroundf(ceilf(verticalKernelBlur + verticalKernelBlur)) : 0;
        uint32_t kernelWidth = kernelWidthBase | 1;
        uint32_t kernelHeight = kernelHeightBase | 1;
        uint32_t kernelCount = kernelWidth * kernelHeight;
        CFMutableDataRef kernelData = CFDataCreateMutable(kCFAllocatorDefault, kernelCount * sizeof(int16_t));
        if (kernelData == NULL) {
            CFRelease(blurred);
            CFRelease(data);
            return NO;
        }
        CFDataSetLength(kernelData, kernelCount * sizeof(int16_t));
        int16_t *kernel = (int16_t *)CFDataGetMutableBytePtr(kernelData);
        int32_t divisor = 0;
        float kernelWidthValue = (float)kernelWidth;
        float kernelHeightValue = (float)kernelHeight;
        for (uint32_t i = 0; i < kernelCount; i++) {
            float dy = (float)(i / kernelWidth) - (float)(kernelHeightBase >> 1);
            dy *= dy;
            float dx = (float)(i % kernelWidth) - (float)(kernelWidthBase >> 1);
            dx *= dx;
            if (dx * (4.0f / (kernelWidthValue * kernelWidthValue)) + dy * (4.0f / (kernelHeightValue * kernelHeightValue)) <= 1.0f) {
                int16_t value = (int16_t)lroundf(expf((dx + dy) * (float)(-18.0 / (double)kernelCount)) * 255.0f);
                kernel[i] = value;
                divisor += value;
            }
        }
        vImage_Buffer destination = { CFDataGetMutableBytePtr(blurred), height, width, rowBytes };
        vImageConvolve_Planar8(&source, &destination, NULL, 0, 0, kernel, kernelHeight, kernelWidth, divisor, 0, kvImageBackgroundColorFill);
        CFRelease(kernelData);
        CFRelease(data);
        data = blurred;
    }
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
    CFRelease(data);
    if (provider == NULL)
        return NO;
    const CGFloat decode[2] = { 1.0, 0.0 };
    *aMask = CGImageMaskCreate(width, height, 8, 8, rowBytes, provider, decode, true);
    CGDataProviderRelease(provider);
    if (*aMask == NULL)
        return NO;
    if (aTransform != NULL) {
        aTransform->a = (float)aTransform2.a * horizontalFactor;
        aTransform->b = (float)aTransform2.b * verticalFactor;
        aTransform->c = (float)aTransform2.c * horizontalFactor;
        aTransform->d = (float)aTransform2.d * verticalFactor;
        aTransform->tx = ((float)aTransform2.tx - (float)NSMinX(bounds)) * horizontalFactor;
        aTransform->ty = ((float)aTransform2.ty - (float)NSMinY(bounds)) * verticalFactor;
    }
    return YES;
}

// Enabling the shadow, or changing its blur or offset, changes the whole
// shadow; other changes move the shadow with the content's changed region.
- (BOOL)unionBoundingRegionOfConcreteAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion
{
    if (_contentRenderLayer == nil)
        return NO;
    id attributes = [[self visualizationAttributes] attributesForObject:aObject];
    if ([attributes count] == 0)
        return NO;
    id changes = [[aSet mutableCopy] autorelease];
    if (changes == nil)
        return NO;
    [changes intersectProtocolSet:attributes];
    if ([changes count] == 0)
        return NO;
    if ([changes containsProtocol:@protocol(HSShadowEnabledAttribute)] || [changes containsProtocol:@protocol(HSShadowBlurRadiusAttribute)]
        || [changes containsProtocol:@protocol(HSShadowOffsetAttribute)]) {
        if (*aRegion == nil)
            *aRegion = [HSMutableRegion region];
        return [self unionBoundingRegionWithRegion:*aRegion];
    }
    id contentRegion = nil;
    if (![_contentRenderLayer unionBoundingRegionOfConcreteAttributeSet:changes ofHyperObject:aObject withInfo:aInfo withRegion:&contentRegion])
        return NO;
    id shadowRegion = [self shadowRegionForContentRegion:contentRegion];
    if (*aRegion == nil)
        *aRegion = shadowRegion;
    else
        [*aRegion addRegion:shadowRegion];
    return YES;
}

- (id)calculateBoundingRegion
{
    if (_contentRenderLayer == nil)
        return [HSRegion region];
    id contentBounds = [_contentRenderLayer boundingRegion];
    if (contentBounds == nil)
        return nil;
    return [[[self shadowRegionForContentRegion:contentBounds] copy] autorelease];
}

// In object space: the region grown by the blur on each side (about its
// centre) and shifted by the shadow offset, or back.
static HSMutableRegion *HSShadowMaskRegionTransformed(id aRegion, CGAffineTransform aGeometry, float aBlurRadius, float aHorizontalOffset, float aVerticalOffset, BOOL aToShadow)
{
    HSMutableRegion *region = [(HSMutableRegion *)[[aRegion mutableCopy] autorelease] applyAffineTransform:aGeometry];
    NSRect bounds = [region boundingRect];
    CGAffineTransform inverse = CGAffineTransformInvert(aGeometry);
    float blur = aBlurRadius + aBlurRadius;
    float verticalScale = ((float)NSHeight(bounds) + blur) / (float)NSHeight(bounds);
    float horizontalScale = (blur + (float)NSWidth(bounds)) / (float)NSWidth(bounds);
    float centerX = ((float)NSWidth(bounds) * 0.5f + (float)NSMinX(bounds)) * (1.0f - horizontalScale);
    float centerY = ((float)NSHeight(bounds) * 0.5f + (float)NSMinY(bounds)) * (1.0f - verticalScale);
    float a = (float)inverse.a, b = (float)inverse.b, c = (float)inverse.c, d = (float)inverse.d;
    CGAffineTransform transform;
    transform.a = a * horizontalScale;
    transform.b = horizontalScale * b;
    transform.c = c * verticalScale;
    transform.d = verticalScale * d;
    if (aToShadow) {
        transform.tx = (a * aHorizontalOffset - c * aVerticalOffset) + (float)inverse.tx + centerY * c + centerX * a;
        transform.ty = (b * aHorizontalOffset - d * aVerticalOffset) + (float)inverse.ty + centerX * b + centerY * d;
    } else {
        transform.tx = (c * aVerticalOffset - a * aHorizontalOffset) + (float)inverse.tx + centerY * c + centerX * a;
        transform.ty = (d * aVerticalOffset - b * aHorizontalOffset) + (float)inverse.ty + centerX * b + centerY * d;
    }
    return [region applyAffineTransform:transform];
}

// What content a shadow region needs: grown by the blur, shifted back.
- (id)contentRegionForShadowRegion:(id)aRegion
{
    return HSShadowMaskRegionTransformed(aRegion, [_geometryAttributes affineTransform], (float)[_shadowAttributes hyperShadowBlurRadius],
                                         (float)[_shadowAttributes hyperHorizontalShadowOffset], (float)[_shadowAttributes hyperVerticalShadowOffset], NO);
}

- (id)shadowRegionForContentRegion:(id)aRegion
{
    return HSShadowMaskRegionTransformed(aRegion, [_geometryAttributes affineTransform], (float)[_shadowAttributes hyperShadowBlurRadius],
                                         (float)[_shadowAttributes hyperHorizontalShadowOffset], (float)[_shadowAttributes hyperVerticalShadowOffset], YES);
}

- (void)fillBoundingRegionAttributesSet:(id)aSet
{
    id object = [self hyperObject];
    [aSet addAttribute:@protocol(HSSizeAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSScaleAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSRotationAngleAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSSkewAngleAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSShadowBlurRadiusAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSShadowOffsetAttribute) forObject:object];
}

// The content's mask attributes plus the geometry and shadow shape.
- (void)fillVisualizationAttributesSet:(id)aSet
{
    if (_contentRenderLayer == nil)
        return;
    id object = [self hyperObject];
    [_contentRenderLayer addVisualizationMaskAttributesToSet:aSet];
    [aSet addAttribute:@protocol(HSSizeAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSScaleAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSFlipAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSRotationAngleAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSSkewAngleAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSShadowBlurRadiusAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSShadowOffsetAttribute) forObject:object];
}

- (BOOL)isEmpty
{
    return _contentRenderLayer == nil || [_contentRenderLayer isEmpty];
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
    return @"HSShadowContentRenderLayerRole";
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
    return _contentRenderLayer != nil ? [NSArray arrayWithObject:_contentRenderLayer] : [NSArray array];
}

- (id)copyRemovingRenderSublayers
{
    return [[[self class] allocWithZone:[self zone]] initWithHyperObject:[self hyperObject] cachingPolicy:[self cachingPolicy]];
}

- (void)dealloc
{
    [_contentRenderLayer removeObserver:self];
    [_contentRenderLayer release];
    [_geometryAttributes release];
    [_shadowAttributes release];
    [super dealloc];
}

- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject cachingPolicy:aPolicy];
    if (self == nil)
        return nil;
    _geometryAttributes = [[aObject queryHyperInterface:@protocol(HSGeometryAttributes)] retain];
    if (_geometryAttributes != nil)
        _shadowAttributes = [[aObject queryHyperInterface:@protocol(HSShadowAttributes)] retain];
    if (_geometryAttributes == nil || _shadowAttributes == nil) {
        [self release];
        return nil;
    }
    return self;
}

@end

// A shadow mask whose blur hit the 30 pixel cap stays valid when scaled up
// in that direction: a sharper blur could not be made anyway.
@implementation HSShadowAndOpacityRenderLayer_ShadowMaskRenderCacheValidnessEvaluator

- (NSSize)scaleFactorForAffineTransform:(CGAffineTransform)aTransform withContentAffineTransform:(CGAffineTransform)aTransform2
{
    float horizontalScale = hypotf((float)aTransform.a, (float)aTransform.b);
    float verticalScale = hypotf((float)aTransform.c, (float)aTransform.d);
    if (horizontalScale > 1.0f && _isBlurRadiusMaximizedHorizontally)
        horizontalScale = 1.0f;
    if (verticalScale > 1.0f && _isBlurRadiusMaximizedVertically)
        verticalScale = 1.0f;
    return NSMakeSize(horizontalScale, verticalScale);
}

- (BOOL)isEqual:(id)aEqual
{
    if (self == aEqual)
        return YES;
    if (![aEqual isKindOfClass:[HSShadowAndOpacityRenderLayer_ShadowMaskRenderCacheValidnessEvaluator class]])
        return NO;
    if ((BOOL)[aEqual HSShadowAndOpacityRenderLayer_ShadowMaskRenderCacheValidnessEvaluator_isBlurRadiusMaximizedHorizontally] != (BOOL)_isBlurRadiusMaximizedHorizontally)
        return NO;
    if ((BOOL)[aEqual HSShadowAndOpacityRenderLayer_ShadowMaskRenderCacheValidnessEvaluator_isBlurRadiusMaximizedVertically] != (BOOL)_isBlurRadiusMaximizedVertically)
        return NO;
    return [super isEqual:aEqual];
}

- (BOOL)HSShadowAndOpacityRenderLayer_ShadowMaskRenderCacheValidnessEvaluator_isBlurRadiusMaximizedVertically
{
    return _isBlurRadiusMaximizedVertically;
}

- (BOOL)HSShadowAndOpacityRenderLayer_ShadowMaskRenderCacheValidnessEvaluator_isBlurRadiusMaximizedHorizontally
{
    return _isBlurRadiusMaximizedHorizontally;
}

- (id)initWithBlurRadiusMaximizedHorizontally:(BOOL)aHorizontally vertically:(BOOL)aVertically toEvaluateForScaling:(BOOL)aScaling skewing:(BOOL)aSkewing rotation:(BOOL)aRotation offset:(BOOL)aOffset
{
    self = [super initToEvaluateForScaling:aScaling skewing:aSkewing rotation:aRotation offset:aOffset];
    if (self != nil) {
        _isBlurRadiusMaximizedHorizontally = aHorizontally ? 1 : 0;
        _isBlurRadiusMaximizedVertically = aVertically ? 1 : 0;
    }
    return self;
}

- (id)initToEvaluateForScaling:(BOOL)aScaling skewing:(BOOL)aSkewing rotation:(BOOL)aRotation offset:(BOOL)aOffset
{
    return [self initWithBlurRadiusMaximizedHorizontally:NO vertically:NO toEvaluateForScaling:aScaling skewing:aSkewing rotation:aRotation offset:aOffset];
}

@end

// Drawing hands the mask to the context's consumer instead of drawing it.
@implementation HSShadowAndOpacityRenderLayer_ShadowMaskRenderCache

- (void)drawRegion:(id)aRegion
{
    [[NSGraphicsContext currentContext] HSShadowAndOpacityRenderLayer_ShadowMaskConsumer_setShadowMask:_shadowMask transform:[self drawingAffineTransform]];
}

// Against the mask's pixel rect (with a little slack).
- (BOOL)intersectsWithRegion:(id)aRegion
{
    size_t width = CGImageGetWidth(_shadowMask);
    size_t height = CGImageGetHeight(_shadowMask);
    HSMutableRegion *region = [(HSMutableRegion *)[[aRegion mutableCopy] autorelease] applyAffineTransform:[self affineTransform]];
    return [region intersectsRect:NSMakeRect(-0.01f, -0.01f, (float)((double)width + 0.02), (float)((double)height + 0.02))];
}

- (BOOL)containsRegion:(id)aRegion
{
    size_t width = CGImageGetWidth(_shadowMask);
    size_t height = CGImageGetHeight(_shadowMask);
    HSMutableRegion *region = [(HSMutableRegion *)[[aRegion mutableCopy] autorelease] applyAffineTransform:[self affineTransform]];
    return NSContainsRect(NSMakeRect(-0.01f, -0.01f, (float)((double)width + 0.02), (float)((double)height + 0.02)), [region boundingRect]);
}

- (void)dealloc
{
    CGImageRelease(_shadowMask);
    [super dealloc];
}

- (id)initWithShadowMask:(struct CGImage *)aMask renderLayer:(id)aLayer affineTransform:(CGAffineTransform)aTransform temporaryValidness:(CGFloat)aValidness persistentValidness:(CGFloat)aValidness2 validnessEvaluator:(id)aEvaluator
{
    self = [super initWithRenderLayer:aLayer affineTransform:aTransform temporaryValidness:aValidness persistentValidness:aValidness2 validnessEvaluator:aEvaluator];
    if (self != nil)
        _shadowMask = CGImageRetain(aMask);
    return self;
}

// A mask cache needs its mask.
- (id)initWithRenderLayer:(id)aLayer affineTransform:(CGAffineTransform)aTransform temporaryValidness:(CGFloat)aValidness persistentValidness:(CGFloat)aValidness2 validnessEvaluator:(id)aEvaluator
{
    [self release];
    return nil;
}

@end

// Graphics contexts to the layer that takes the next shadow mask drawn into
// them (weak both ways).
static CFMutableDictionaryRef HSShadowMaskConsumers;

@implementation NSGraphicsContext (HSShadowAndOpacityRenderLayer_ShadowMaskConsumer)

- (void)HSShadowAndOpacityRenderLayer_ShadowMaskConsumer_setShadowMask:(struct CGImage *)aMask transform:(CGAffineTransform)aTransform
{
    [[self HSShadowAndOpacityRenderLayer_ShadowMaskConsumer_shadowMaskConsumer] HSShadowAndOpacityRenderLayer_ShadowMaskConsumer_setShadowMask:aMask transform:aTransform];
}

- (void)HSShadowAndOpacityRenderLayer_ShadowMaskConsumer_setShadowMaskConsumer:(id)aConsumer
{
    if (HSShadowMaskConsumers == NULL) {
        HSShadowMaskConsumers = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFEWeakObjectPointerDictionaryKeyCallBacks,
                                                          &kCFEWeakObjectPointerDictionaryValueCallBacks);
        if (HSShadowMaskConsumers == NULL)
            return;
    }
    if (aConsumer == nil)
        CFDictionaryRemoveValue(HSShadowMaskConsumers, self);
    else
        CFDictionarySetValue(HSShadowMaskConsumers, self, aConsumer);
}

- (id)HSShadowAndOpacityRenderLayer_ShadowMaskConsumer_shadowMaskConsumer
{
    if (HSShadowMaskConsumers == NULL)
        return nil;
    return (id)CFDictionaryGetValue(HSShadowMaskConsumers, self);
}

@end
