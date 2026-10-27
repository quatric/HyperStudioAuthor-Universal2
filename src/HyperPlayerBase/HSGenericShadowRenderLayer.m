#import "HSGenericShadowRenderLayer.h"
// Group render layer that draws its sublayers with the object's drop
// shadow. The shadow region is the content region in canvas space, grown
// by the blur radius about its centre and moved by the shadow offset, and
// then mapped back into object space.

// Maps a region in object space to canvas space, scales it about the
// centre of its bounds so it grows by twice the blur radius, moves it by
// the offset, and maps it back to object space.
static id HSGenericShadowRenderLayerTransformRegion(id aRegion, CGAffineTransform aTransform, NSSize anOffset, CGFloat aBlurRadius)
{
    HSMutableRegion *region = [[aRegion mutableCopy] autorelease];
    [region applyAffineTransform:aTransform];
    NSRect bounds = [region boundingRect];
    CGFloat sx = (bounds.size.width + aBlurRadius + aBlurRadius) / bounds.size.width;
    CGFloat sy = (aBlurRadius + aBlurRadius + bounds.size.height) / bounds.size.height;
    CGFloat cx = (bounds.size.width * 0.5 + bounds.origin.x) * (1.0 - sx);
    CGFloat cy = (bounds.size.height * 0.5 + bounds.origin.y) * (1.0 - sy);
    CGAffineTransform grow = CGAffineTransformMake(sx, 0, 0, sy, cx + anOffset.width, cy + anOffset.height);
    [region applyAffineTransform:CGAffineTransformConcat(grow, CGAffineTransformInvert(aTransform))];
    return region;
}

@implementation HSGenericShadowRenderLayer

- (void)renderLayerDidChangeBoundingRegion:(id)aRegion
{
    [_contentBoundingRegion release];
    _contentBoundingRegion = nil;
    [super renderLayerDidChangeBoundingRegion:aRegion];
}

- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce
{
    if (aForce)
        return YES;
    return [_shadowAttributes isHyperShadowEnabled];
}

- (BOOL)unionBoundingRegionOfSublayersVisualAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion
{
    if (![_shadowAttributes isHyperShadowEnabled])
        return [super unionBoundingRegionOfSublayersVisualAttributeSet:aSet ofHyperObject:aObject withInfo:aInfo withRegion:aRegion];

    if ([aObject hyperIdentifier] == [[self hyperObject] hyperIdentifier]
        && ([aSet containsProtocol:@protocol(HSShadowAttribute)]
            || [aSet containsProtocol:@protocol(HSSizeAttribute)]
            || [aSet containsProtocol:@protocol(HSScaleAttribute)]
            || [aSet containsProtocol:@protocol(HSFlipAttribute)]
            || [aSet containsProtocol:@protocol(HSRotationAngleAttribute)]
            || [aSet containsProtocol:@protocol(HSSkewAngleAttribute)])) {
        // A change of the shadow or geometry moves the whole shadow.
        if (!*aRegion)
            *aRegion = [HSMutableRegion region];
        return [self unionBoundingRegionWithRegion:*aRegion];
    }

    id region = nil;
    if (![super unionBoundingRegionOfSublayersVisualAttributeSet:aSet ofHyperObject:aObject withInfo:aInfo withRegion:&region]
        || [region isEmpty])
        return NO;
    if (*aRegion)
        [*aRegion addRegion:region];
    else
        *aRegion = region;
    [*aRegion addRegion:[self shadowRegionForContentRegion:region]];
    return YES;
}

- (id)calculateBoundingRegion
{
    id region = [self contentBoundingRegion];
    if ([_shadowAttributes isHyperShadowEnabled] && ![region isEmpty])
        region = [[[[self shadowRegionForContentRegion:region] addRegion:region] copy] autorelease];
    return region;
}

- (void)HSGenericShadowRenderLayer_contentBoundingRegionDidChange:(id)aChange
{
    [_contentBoundingRegion release];
    _contentBoundingRegion = nil;
}

- (id)contentBoundingRegion
{
    if (!_contentBoundingRegion) {
        _contentBoundingRegion = [[super calculateBoundingRegion] copy];
        if (!_contentBoundingRegionAttributes)
            [self HSGenericShadowRenderLayer_linkContentBoundingRegionToAttributes];
    }
    return _contentBoundingRegion;
}

- (void)fillBoundingRegionAttributesSet:(id)aSet
{
    id object = [self hyperObject];
    [aSet addAttribute:@protocol(HSSizeAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSScaleAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSFlipAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSRotationAngleAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSSkewAngleAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSShadowAttribute) forObject:object];
    if (!_contentBoundingRegionAttributes)
        [self HSGenericShadowRenderLayer_linkContentBoundingRegionToAttributes];
    [aSet unionMultipleObjectsAttributeSet:_contentBoundingRegionAttributes];
}

- (void)HSGenericShadowRenderLayer_linkContentBoundingRegionToAttributes
{
    _contentBoundingRegionAttributes = [[HSMutableMultipleObjectsAttributeSet alloc] init];
    [super fillBoundingRegionAttributesSet:_contentBoundingRegionAttributes];
    [_contentBoundingRegionAttributes addObserver:self selector:@selector(HSGenericShadowRenderLayer_contentBoundingRegionDidChange:) ofChanges:HSActualDidAttributeChanges withPriority:0.25];
}

// (The original grows the region here too, rather than shrinking it, and
// only reverses the offset; the result is used as a generous bound.)
- (id)contentRegionForShadowRegion:(id)aRegion
{
    NSShadow *shadow = [_shadowAttributes hyperShadow];
    NSSize offset = [shadow shadowOffset];
    return HSGenericShadowRenderLayerTransformRegion(aRegion, [_geometryAttributes affineTransform], NSMakeSize(-offset.width, offset.height), [shadow shadowBlurRadius]);
}

- (id)shadowRegionForContentRegion:(id)aRegion
{
    NSShadow *shadow = [_shadowAttributes hyperShadow];
    NSSize offset = [shadow shadowOffset];
    return HSGenericShadowRenderLayerTransformRegion(aRegion, [_geometryAttributes affineTransform], NSMakeSize(offset.width, -offset.height), [shadow shadowBlurRadius]);
}

- (void)drawRenderSublayersInRegion:(id)aRegion withDelegate:(id)aDelegate
{
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    if (![_shadowAttributes isHyperShadowEnabled]) {
        [super drawRenderSublayersInRegion:aRegion withDelegate:aDelegate];
        return;
    }
    CGAffineTransform transform = [_geometryAttributes affineTransform];
    CGAffineTransform ctm = [context currentHyperCGAffineTransform];
    NSShadow *shadow = [[[_shadowAttributes hyperShadow] copy] autorelease];
    if (!shadow) {
        [super drawRenderSublayersInRegion:aRegion withDelegate:aDelegate];
        return;
    }

    // The shadow is set in object space; NSShadow works in base space, so
    // map the offset and blur through the object-to-base transform (the
    // linear part only).
    transform.tx = transform.ty = 0;
    CGAffineTransform m = CGAffineTransformConcat(CGAffineTransformInvert(transform), ctm);
    NSSize offset = [shadow shadowOffset];
    [shadow setShadowOffset:NSMakeSize(m.a * offset.width + m.c * -offset.height + 0.0,
                                       m.b * offset.width + m.d * -offset.height + 0.0)];
    float radius = [shadow shadowBlurRadius];
    float sx = hypotf(m.a, m.b);
    float sy = hypotf(m.c, m.d);
    [shadow setShadowBlurRadius:sqrtf(2.0 / (1.0 / ((radius * sx) * (radius * sx)) + 1.0 / ((radius * sy) * (radius * sy))))];
    [shadow set];

    id content = [self contentBoundingRegion];
    if ([content isEmpty])
        return;
    id region = [[[self contentRegionForShadowRegion:aRegion] intersectRegion:content] addRegion:aRegion];
    [context beginHyperTransparencyLayerRequest];
    [super drawRenderSublayersInRegion:region withDelegate:aDelegate];
    [context endHyperTransparencyLayerRequest];
}

- (void)fillVisualizationMaskAttributesSet:(id)aSet
{
    id object = [self hyperObject];
    [aSet addAttribute:@protocol(HSSizeAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSScaleAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSFlipAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSRotationAngleAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSSkewAngleAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSShadowAttribute) forObject:object];
    [super fillVisualizationMaskAttributesSet:aSet];
}

- (void)fillVisualizationAttributesSet:(id)aSet
{
    id object = [self hyperObject];
    [aSet addAttribute:@protocol(HSSizeAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSScaleAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSFlipAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSRotationAngleAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSSkewAngleAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSShadowAttribute) forObject:object];
    [super fillVisualizationAttributesSet:aSet];
}

- (void)dealloc
{
    [_geometryAttributes release];
    [_shadowAttributes release];
    [_contentBoundingRegionAttributes removeObserver:self selector:@selector(HSGenericShadowRenderLayer_contentBoundingRegionDidChange:) ofChanges:HSActualDidAttributeChanges];
    [_contentBoundingRegionAttributes release];
    [_contentBoundingRegion release];
    [super dealloc];
}

- (id)initWithHyperObject:(id)aObject renderSublayerCapacity:(NSUInteger)aCapacity cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject renderSublayerCapacity:aCapacity cachingPolicy:aPolicy];
    if (!self)
        return nil;
    _geometryAttributes = [[aObject queryHyperInterface:@protocol(HSGeometryAttributes)] retain];
    if (_geometryAttributes)
        _shadowAttributes = [[aObject queryHyperInterface:@protocol(HSShadowAttributes)] retain];
    if (!_shadowAttributes) {
        [self release];
        return nil;
    }
    return self;
}

@end
