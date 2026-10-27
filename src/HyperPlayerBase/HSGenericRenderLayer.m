#import "HSGenericRenderLayer.h"
#import "HSBitmapRenderCacheValidnessEvaluator.h"
#import "HSMutableMultipleObjectsAttributeSet.h"
#import "HSMutableRegion.h"
#import "HSPixelBufferRenderCache.h"
#import "HSFunctions.h"
#import "SMKApplicationKitData.h"

// Splits an affine transform into scale (x along the first column, y along
// the second), skew, flip and rotation the same way the bitmap cache validness
// evaluator does. When the rotation is not kept it survives only if it is a
// multiple of a right angle.
static void HSGenericRenderLayerDecomposeTransform(CGAffineTransform t, BOOL wantSkew, BOOL keepRotation,
                                                   float *scaleX, float *scaleY, float *skew, BOOL *flipped, float *rotation)
{
    BOOL hasXAxis = t.a != 0.0 || t.b != 0.0;
    float rot;
    *scaleY = hypotf(t.c, t.d);
    *skew = 0.0f;
    if (hasXAxis) {
        float det = t.a * t.d - t.b * t.c;
        *scaleX = hypotf(t.a, t.b);
        *flipped = det < 0.0f;
        if (wantSkew) {
            double angle = atan2((double)(float)(t.a * t.c + t.b * t.d), (double)det);
            if (angle < -M_PI_2)
                angle += M_PI;
            else if (angle > M_PI_2)
                angle -= M_PI;
            *skew = nextafterf((float)angle, 0.0f);
        }
        rot = atan2f(t.b, t.a);
    } else {
        *scaleX = 0.0f;
        *flipped = NO;
        rot = (float)((double)atan2f(t.d, t.c) - M_PI_2);
    }
    if (rot < 0.0f)
        rot += 6.2831855f;
    if (!keepRotation) {
        float rem = remainderf(rot, (float)M_PI_2);
        if (rem < -0.001f || rem > 0.001f)
            rot = 0.0f;
    }
    *rotation = rot;
}

// Rebuilds the linear part of a transform from the decomposition above.
static void HSGenericRenderLayerComposeTransform(float rotation, float skew, BOOL flipped, float scaleX, float scaleY, CGAffineTransform *out)
{
    float tangent = tanf(skew);
    float factor = scaleY / hypotf(tangent, 1.0f);
    float sine = sinf(rotation), cosine = cosf(rotation);
    if (flipped)
        factor = -factor;
    out->a = cosine * scaleX;
    out->b = scaleX * sine;
    out->c = (cosine * tangent - sine) * factor;
    out->d = (sine * tangent + cosine) * factor;
}

static void HSGenericRenderLayerUnregisterCacheApplier(const void *key, const void *value, void *context)
{
    [(id)key unregisterWeakReferencer:(id)context];
}

@implementation HSGenericRenderLayer

/* i386 ivar offsets: _hyperObject=0x8, _cachingPolicy=0xc, _observers=0x10, _renderCaches=0x14, _boundingRegion=0x18, _boundingRegionAttributes=0x1c, _visualizationAttributes=0x20, _visualizationMaskAttributes=0x24 */

// The largest screen area plus 10% in each direction, computed once.
+ (CGFloat)maxBitmapCacheArea
{
    static float maxArea = 0.0f;
    if (maxArea == 0.0f) {
        NSEnumerator *screens = [[NSScreen screens] objectEnumerator];
        NSScreen *screen;
        while ((screen = [screens nextObject]) != nil) {
            NSRect frame = [screen frame];
            if (maxArea < frame.size.width * frame.size.height)
                maxArea = frame.size.width * frame.size.height;
        }
        maxArea = maxArea * 1.21f;
    }
    return maxArea;
}

- (BOOL)cacheRenderingInRegion:(id)aRegion forAffineTransform:(CGAffineTransform)aTransform withTransformationIntent:(struct HyperPlayerBase_anon12 *)aIntent acceptableValidnessLimit:(CGFloat)aLimit delegate:(id)aDelegate force:(BOOL)aForce share:(BOOL)aShare resultCache:(id *)aCache
{
    NSInteger influence = 0;
    if (!aForce) {
        switch (_cachingPolicy) {
        case 1: // never cache
            return NO;
        case 2: // always cache
            aForce = YES;
            break;
        case 3: // cache if any sublayer caches
            influence = 1;
            break;
        case 4: // cache if all sublayers cache
            influence = 2;
            break;
        default:
            break;
        }
    }
    if (![self willCacheRenderingInRegion:aRegion withTransformationIntent:aIntent countOnRenderSublayersInfluence:influence force:aForce])
        return NO;
    float validness = 0.0f;
    id evaluator = nil;
    CGAffineTransform cachingTransform = CGAffineTransformIdentity;
    [self getRenderCacheValidness:&validness validnessEvaluator:&evaluator cachingTransform:&cachingTransform
                        forRegion:aRegion affineTransform:aTransform transformationIntent:aIntent];
    if (validness < aLimit)
        return NO;
    return [self cacheRenderingInRegion:aRegion withAffineTransform:cachingTransform validness:validness validnessEvaluator:evaluator
                               delegate:aDelegate force:aForce share:aShare resultCache:aCache];
}

- (BOOL)cacheRenderingInRegion:(id)aRegion withAffineTransform:(CGAffineTransform)aTransform validness:(CGFloat)aValidness validnessEvaluator:(id)aEvaluator delegate:(id)aDelegate force:(BOOL)aForce share:(BOOL)aShare resultCache:(id *)aCache
{
    if (aCache == NULL && aForce)
        return YES;
    id region = [(HSMutableRegion *)[[aRegion mutableCopy] autorelease] applyAffineTransform:aTransform];
    if (region == nil)
        return NO;
    NSRect cacheRect = NSIntegralRect([region boundingRect]);
    if (!aForce && [[self class] maxBitmapCacheArea] < (float)(cacheRect.size.width * cacheRect.size.height))
        return NO;
    CGFloat persistent = [self persistentValidnessForTemporaryValidness:aValidness region:aRegion];
    // Quirk kept: a NULL result pointer is only tolerated when forced.
    *aCache = [[self createBitmapRenderCacheWithAffineTransform:aTransform cacheRect:cacheRect temporaryValidness:aValidness
                                            persistentValidness:persistent validnessEvaluator:aEvaluator delegate:aDelegate share:aShare] autorelease];
    return YES;
}

// Draws the layer into a BGRA pixel buffer carrying the destination's colour
// space and profile and wraps it in a pixel buffer render cache (returned
// retained).
- (id)createBitmapRenderCacheWithAffineTransform:(CGAffineTransform)aTransform cacheRect:(NSRect)aRect temporaryValidness:(CGFloat)aValidness persistentValidness:(CGFloat)aValidness2 validnessEvaluator:(id)aEvaluator delegate:(id)aDelegate share:(BOOL)aShare
{
    NSRect bounds = { NSZeroPoint, aRect.size };
    if (NSIsEmptyRect(bounds))
        return nil;
    aTransform.tx -= aRect.origin.x;
    aTransform.ty -= aRect.origin.y;
    HSMutableRegion *region = [(HSMutableRegion *)[HSMutableRegion regionWithRect:bounds] applyAffineTransform:CGAffineTransformInvert(aTransform)];
    if (region == nil)
        return nil;
    CGContextRef destination = [[NSGraphicsContext currentContext] CGContext];
    CFTypeRef profile = CGEContextGetAttachmentForKey(destination, (CFStringRef)kCGEContextColorSyncProfileAttachmentKey);
    CFTypeRef colorSpace = CGEContextGetAttachmentForKey(destination, (CFStringRef)kCGEContextColorSpaceAttachmentKey);
    size_t width = aRect.size.width > 0 ? lroundf(ceilf(aRect.size.width)) : 0;
    size_t height = aRect.size.height > 0 ? lroundf(ceilf(aRect.size.height)) : 0;
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                (id)kCFBooleanTrue, (id)kCVPixelBufferCGBitmapContextCompatibilityKey,
                                (id)kCFBooleanTrue, (id)kCVPixelBufferCGImageCompatibilityKey, nil];
    CVPixelBufferRef pixelBuffer = NULL;
    CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, (CFDictionaryRef)attributes, &pixelBuffer);
    if (pixelBuffer == NULL)
        return nil;
    CVBufferSetAttachment(pixelBuffer, (CFStringRef)kCVEPixelBufferAlphaInfoKey, [NSNumber numberWithInt:kCGImageAlphaPremultipliedFirst], kCVAttachmentMode_ShouldNotPropagate);
    if (colorSpace != NULL)
        CVBufferSetAttachment(pixelBuffer, kCVImageBufferCGColorSpaceKey, colorSpace, kCVAttachmentMode_ShouldPropagate);
    CGContextRef bitmap = CGEBitmapContextCreateWithPixelBuffer(pixelBuffer, 0);
    if (bitmap == NULL) {
        CVPixelBufferRelease(pixelBuffer);
        return nil;
    }
    CFTypeRef savedProfile = CGEContextGetAttachmentForKey(bitmap, (CFStringRef)kCGEContextColorSyncProfileAttachmentKey);
    if (savedProfile != NULL)
        CFRetain(savedProfile);
    CGEContextSetAttachmentForKey(bitmap, (CFStringRef)kCGEContextColorSyncProfileAttachmentKey, profile);
    CFTypeRef savedColorSpace = CGEContextGetAttachmentForKey(bitmap, (CFStringRef)kCGEContextColorSpaceAttachmentKey);
    if (savedColorSpace != NULL)
        CFRetain(savedColorSpace);
    CGEContextSetAttachmentForKey(bitmap, (CFStringRef)kCGEContextColorSpaceAttachmentKey, colorSpace);
    CGContextClearRect(bitmap, CGRectMake(0, 0, CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer)));
    CGContextConcatCTM(bitmap, aTransform);
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithCGContext:bitmap flipped:YES];
    if (context == nil) {
        // The original leaves the saved attachments retained here.
        [pool release];
        CGContextRelease(bitmap);
        CVPixelBufferRelease(pixelBuffer);
        return nil;
    }
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:context];
    [self drawRegion:region withDelegate:aDelegate];
    [NSGraphicsContext restoreGraphicsState];
    [pool release];
    CGEContextSetAttachmentForKey(bitmap, (CFStringRef)kCGEContextColorSpaceAttachmentKey, savedColorSpace);
    if (savedColorSpace != NULL)
        CFRelease(savedColorSpace);
    CGEContextSetAttachmentForKey(bitmap, (CFStringRef)kCGEContextColorSyncProfileAttachmentKey, savedProfile);
    if (savedProfile != NULL)
        CFRelease(savedProfile);
    CGContextRelease(bitmap);
    id cache = [[HSPixelBufferRenderCache alloc] initWithPixelBuffer:pixelBuffer renderLayer:self affineTransform:aTransform
                                                temporaryValidness:aValidness persistentValidness:aValidness2 validnessEvaluator:aEvaluator];
    CVPixelBufferRelease(pixelBuffer);
    if (cache == nil)
        return nil;
    if (aShare)
        [self shareRenderCache:cache withValidationAttributes:[self validationAttributesForBitmapRenderCache]];
    return cache;
}

- (id)validationAttributesForBitmapRenderCache
{
    return [self visualizationAttributes];
}

- (id)continuousChangeSensitiveVisualizationAttributes
{
    return [self visualizationAttributes];
}

// Works out the transform a cache should be rendered with: the parts of the
// drawing transform the evaluator says the cache can follow (scaling, skewing,
// rotation, sub-pixel offset) are kept, the rest is reduced to identity.
- (void)getRenderCacheValidness:(float *)aValidness validnessEvaluator:(id *)aEvaluator cachingTransform:(CGAffineTransform *)aTransform forRegion:(id)aRegion affineTransform:(CGAffineTransform)aTransform2 transformationIntent:(struct HyperPlayerBase_anon12 *)aIntent
{
    if (aTransform == NULL) {
        [self getRenderCacheValidness:aValidness validnessEvaluator:aEvaluator includeScaling:NULL includeSkewing:NULL includeRotation:NULL
           includeDevicePointAligning:NULL forRegion:aRegion affineTransform:aTransform2 transformationIntent:aIntent];
        return;
    }
    BOOL scaling = NO, skewing = NO, rotation = NO, aligning = NO;
    [self getRenderCacheValidness:aValidness validnessEvaluator:aEvaluator includeScaling:&scaling includeSkewing:&skewing includeRotation:&rotation
       includeDevicePointAligning:&aligning forRegion:aRegion affineTransform:aTransform2 transformationIntent:aIntent];
    float scaleX, scaleY, skew, angle;
    BOOL flipped;
    if (scaling) {
        if (skewing && rotation) {
            aTransform->a = aTransform2.a;
            aTransform->b = aTransform2.b;
            aTransform->c = aTransform2.c;
            aTransform->d = aTransform2.d;
        } else {
            HSGenericRenderLayerDecomposeTransform(aTransform2, skewing, rotation, &scaleX, &scaleY, &skew, &flipped, &angle);
            HSGenericRenderLayerComposeTransform(angle, skew, flipped, scaleX, scaleY, aTransform);
        }
        if (aligning) {
            aTransform->tx = fmodf(aTransform2.tx, 1.0f);
            aTransform->ty = fmodf(aTransform2.ty, 1.0f);
            return;
        }
    } else if (aligning) {
        // The sub-pixel offset is expressed in the unscaled space.
        HSGenericRenderLayerDecomposeTransform(aTransform2, skewing, rotation, &scaleX, &scaleY, &skew, &flipped, &angle);
        HSGenericRenderLayerComposeTransform(angle, skew, flipped, 1.0f, 1.0f, aTransform);
        aTransform->tx = fmodf(aTransform2.tx, 1.0f) / scaleX;
        aTransform->ty = fmodf(aTransform2.ty, 1.0f) / scaleY;
        return;
    } else if (!skewing && !rotation) {
        *aTransform = CGAffineTransformIdentity;
        return;
    } else {
        HSGenericRenderLayerDecomposeTransform(aTransform2, skewing, rotation, &scaleX, &scaleY, &skew, &flipped, &angle);
        HSGenericRenderLayerComposeTransform(angle, skew, flipped, 1.0f, 1.0f, aTransform);
    }
    aTransform->tx = 0.0;
    aTransform->ty = 0.0;
}

- (void)getRenderCacheValidness:(float *)aValidness validnessEvaluator:(id *)aEvaluator includeScaling:(BOOL *)aScaling includeSkewing:(BOOL *)aSkewing includeRotation:(BOOL *)aRotation includeDevicePointAligning:(BOOL *)aAligning forRegion:(id)aRegion affineTransform:(CGAffineTransform)aTransform transformationIntent:(struct HyperPlayerBase_anon12 *)aIntent
{
    if (aValidness != NULL)
        *aValidness = 1.0f;
    if (aEvaluator != NULL)
        *aEvaluator = [HSBitmapRenderCacheValidnessEvaluator validnessEvaluatorForScaling:YES skewing:NO rotation:NO offset:NO];
    if (aScaling != NULL)
        *aScaling = YES;
    if (aSkewing != NULL)
        *aSkewing = NO;
    if (aRotation != NULL)
        *aRotation = NO;
    if (aAligning != NULL)
        *aAligning = NO;
}

- (BOOL)willCacheRenderingInRegion:(id)aRegion withTransformationIntent:(struct HyperPlayerBase_anon12 *)aIntent countOnRenderSublayersInfluence:(NSInteger)aInfluence force:(BOOL)aForce
{
    if (!aForce && aIntent != NULL && aIntent->f0 == 1)
        return NO;
    return [self willCacheRenderingInRegion:aRegion force:aForce];
}

- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce
{
    return aForce;
}

- (CGFloat)persistentValidnessForTemporaryValidness:(CGFloat)aValidness region:(id)aRegion
{
    if ([self containsTemporaryChangedAttributes])
        return 0.0;
    return aValidness;
}

- (void)invalidateRenderCache:(id)aCache withAttributeChangeNotification:(id)aNotification
{
    if (aNotification == nil) {
        [aCache setTemporaryValidness:0.0];
        [aCache setPersistentValidness:0.0];
        return;
    }
    switch ([aNotification attributeChange]) {
    case 0x20:
        [aCache setTemporaryValidness:[aCache persistentValidness]];
        break;
    case 0x08:
        [aCache setTemporaryValidness:0.0];
        break;
    case 0x02:
        [aCache setTemporaryValidness:0.0];
        [aCache setPersistentValidness:0.0];
        break;
    default:
        break;
    }
}

- (BOOL)containsTemporaryChangedAttributes
{
    HSMultipleObjectsAttributeSet *attributes = [self visualizationAttributes];
    NSEnumerator *objects = [attributes objectEnumerator];
    id object;
    while ((object = [objects nextObject]) != nil) {
        id changed = [[[object queryHyperInterface:@protocol(HSAttributes)] attributeObservingController] attributesChangedTemporary];
        for (id attribute in changed) {
            if ([attributes includesAttribute:attribute forObject:object])
                return YES;
        }
    }
    return NO;
}

- (void)shareRenderCache:(id)aCache withValidationAttributes:(id)aAttributes
{
    if (_renderCaches == NULL) {
        _renderCaches = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFEWeakObjectPointerDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        if (_renderCaches == NULL)
            return;
    }
    if (CFDictionaryGetValue(_renderCaches, aCache) != NULL)
        return;
    id validator = [[HSGenericRenderLayer_HSRenderCacheValidator alloc] initWithRenderLayer:self renderCache:aCache validationAttributes:aAttributes];
    if (validator != nil) {
        CFDictionaryAddValue(_renderCaches, aCache, validator);
        [validator release];
        [aCache registerWeakReferencer:self];
    }
}

- (id)sharedRenderCaches
{
    if (_renderCaches != NULL) {
        CFIndex count = CFDictionaryGetCount(_renderCaches);
        if (count > 0) {
            const void **keys = malloc(count * sizeof(void *));
            if (keys == NULL)
                return nil;
            CFDictionaryGetKeysAndValues(_renderCaches, keys, NULL);
            id caches = [NSArray arrayWithObjects:(id *)keys count:count];
            free(keys);
            return caches;
        }
    }
    return [NSArray array];
}

- (void)postDrawRegion:(id)aRegion withDelegate:(id)aDelegate
{
}

- (void)drawRenderSublayersInRegion:(id)aRegion withDelegate:(id)aDelegate
{
}

- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate
{
}

- (void)drawRegion:(id)aRegion withDelegate:(id)aDelegate
{
    [self predrawRegion:aRegion withDelegate:aDelegate];
    [self drawRenderSublayersInRegion:aRegion withDelegate:aDelegate];
    [self postDrawRegion:aRegion withDelegate:aDelegate];
}

- (BOOL)unionBoundingRegionOfSublayersVisualAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion
{
    return NO;
}

- (BOOL)unionBoundingRegionOfLocalVisualAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion
{
    if (*aRegion == nil)
        *aRegion = [HSMutableRegion region];
    return [self unionBoundingRegionWithRegion:*aRegion];
}

- (BOOL)unionBoundingRegionOfConcreteAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion
{
    id visualized = [[self visualizationAttributes] attributesForObject:aObject];
    if ([visualized count] == 0)
        return NO;
    id set = [[aSet mutableCopy] autorelease];
    if (set == nil)
        return NO;
    [set intersectProtocolSet:visualized];
    if ([set count] == 0)
        return NO;
    BOOL local = [self unionBoundingRegionOfLocalVisualAttributeSet:set ofHyperObject:aObject withInfo:aInfo withRegion:aRegion];
    BOOL sublayers = [self unionBoundingRegionOfSublayersVisualAttributeSet:set ofHyperObject:aObject withInfo:aInfo withRegion:aRegion];
    return sublayers ? YES : local;
}

- (BOOL)unionBoundingRegionOfAttribute:(id)aAttribute ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id)aRegion
{
    id region = aRegion;
    return [self unionBoundingRegionOfConcreteAttributeSet:[NSEProtocolSet protocolSetWithProtocolsAdoptedByProtocol:aAttribute]
                                             ofHyperObject:aObject withInfo:aInfo withRegion:&region];
}

- (id)boundingRegionOfAttribute:(id)aAttribute ofHyperObject:(id)aObject withInfo:(id)aInfo
{
    id region = [HSMutableRegion region];
    [self unionBoundingRegionOfAttribute:aAttribute ofHyperObject:aObject withInfo:aInfo withRegion:region];
    return region;
}

- (BOOL)unionBoundingRegionOfAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id)aRegion
{
    id region = aRegion;
    id concrete = [aSet copyAdoptedProtocols];
    if (concrete == nil)
        return NO;
    BOOL result = [self unionBoundingRegionOfConcreteAttributeSet:concrete ofHyperObject:aObject withInfo:aInfo withRegion:&region];
    [concrete release];
    return result;
}

- (id)boundingRegionOfAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo
{
    id region = [HSMutableRegion region];
    [self unionBoundingRegionOfAttributeSet:aSet ofHyperObject:aObject withInfo:aInfo withRegion:region];
    return region;
}

- (BOOL)unionBoundingRegionWithRegion:(id)aRegion
{
    BOOL notEmpty = ![[self boundingRegion] isEmpty];
    if (notEmpty)
        [aRegion addRegion:_boundingRegion];
    return notEmpty;
}

// Calculated lazily; the attributes it depends on are observed (once) so it
// is dropped when any of them changes.
- (id)boundingRegion
{
    if (_boundingRegion == nil) {
        _boundingRegion = [[self calculateBoundingRegion] copy];
        if (_boundingRegionAttributes == nil) {
            _boundingRegionAttributes = [[HSMutableMultipleObjectsAttributeSet alloc] init];
            [self fillBoundingRegionAttributesSet:_boundingRegionAttributes];
            [_boundingRegionAttributes addObserver:self selector:@selector(HSGenericRenderLayer_boundingRegionDidChange:)
                                         ofChanges:HSActualDidAttributeChanges withPriority:0.25];
        }
    }
    return _boundingRegion;
}

- (id)calculateBoundingRegion
{
    return [HSRegion region];
}

- (void)boundingRegionDidChange
{
    if (_boundingRegion != nil) {
        [_boundingRegion release];
        _boundingRegion = nil;
        [self notifyObserversWithSelector:@selector(renderLayerDidChangeBoundingRegion:)];
    }
}

- (void)HSGenericRenderLayer_boundingRegionDidChange:(id)aChange
{
    [self boundingRegionDidChange];
}

- (void)unlinkBoundingRegionFromAttribute:(id)aAttribute ofHyperObject:(id)aObject withAttributeObservingController:(id)aController
{
    if (_boundingRegionAttributes == nil)
        return;
    if (aController == nil)
        aController = [[aObject queryHyperInterface:@protocol(HSAttributes)] attributeObservingController];
    [aController removeObserver:self selector:@selector(HSGenericRenderLayer_boundingRegionDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:aAttribute];
    [_boundingRegionAttributes removeAttribute:aAttribute forObject:aObject];
}

- (void)linkBoundingRegionToAttribute:(id)aAttribute ofHyperObject:(id)aObject withAttributeObservingController:(id)aController
{
    if (_boundingRegionAttributes == nil)
        return;
    if (aController == nil)
        aController = [[aObject queryHyperInterface:@protocol(HSAttributes)] attributeObservingController];
    [aController addObserver:self selector:@selector(HSGenericRenderLayer_boundingRegionDidChange:) ofChanges:HSActualDidAttributeChanges
                 ofAttribute:aAttribute withPriority:0.25];
    [_boundingRegionAttributes addAttribute:aAttribute forObject:aObject];
}

- (void)fillBoundingRegionAttributesSet:(id)aSet
{
}

- (BOOL)requiresTransparencyLayer
{
    return NO;
}

- (BOOL)isOpaqueInRect:(NSRect)aRect
{
    return NO;
}

- (BOOL)isEmpty
{
    return NO;
}

// Observers are notified from a snapshot, skipping any removed meanwhile;
// exceptions they raise are logged and ignored.
- (void)notifyObserversWithSelector:(SEL)aSelector
{
    if (_observers == NULL)
        return;
    CFIndex count = CFSetGetCount(_observers);
    if (count <= 0)
        return;
    const void **observers = malloc(count * sizeof(void *));
    if (observers == NULL)
        return;
    CFSetGetValues(_observers, observers);
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    for (const void **observer = observers; observer < observers + count; observer++) {
        if (!CFSetContainsValue(_observers, *observer))
            continue;
        @try {
            [(id)*observer performSelector:aSelector withObject:self];
        } @catch (id exception) {
            NSLog(@"Exception was raised while notifying an render layer observer. Ignored.");
            NSLog(@"(%@)", exception);
        }
    }
    [pool release];
    free(observers);
}

- (void)removeObserver:(void *)aObserver
{
    if (_observers != NULL)
        CFSetRemoveValue(_observers, aObserver);
}

- (void)addObserver:(id)aObserver
{
    if (_observers == NULL) {
        _observers = CFSetCreateMutable(kCFAllocatorDefault, 0, &kCFEWeakObjectPointerSetCallBacks);
        if (_observers == NULL)
            return;
    }
    CFSetAddValue(_observers, aObserver);
}

- (void)visualizationMaskAttributesSetDidChange:(id)aChange
{
    HSMultipleObjectsAttributeSet *old = _visualizationMaskAttributes;
    [old release];
    _visualizationMaskAttributes = [aChange copy];
    // Observers hear about it only when a previous set existed.
    if (old != nil)
        [self notifyObserversWithSelector:@selector(renderLayerDidChangeVisualizationMaskAttributesSet:)];
}

- (void)addVisualizationMaskAttributesToSet:(id)aSet
{
    [aSet unionMultipleObjectsAttributeSet:[self visualizationMaskAttributes]];
}

- (id)visualizationMaskAttributes
{
    if (_visualizationMaskAttributes == nil) {
        HSMutableMultipleObjectsAttributeSet *set = [[HSMutableMultipleObjectsAttributeSet alloc] init];
        [self fillVisualizationMaskAttributesSet:set];
        _visualizationMaskAttributes = [set copy];
        [set release];
    }
    return _visualizationMaskAttributes;
}

- (void)fillVisualizationMaskAttributesSet:(id)aSet
{
    [self fillVisualizationAttributesSet:aSet];
}

// A new attribute set invalidates every shared cache.
- (void)visualizationAttributesSetDidChange:(id)aChange
{
    HSMultipleObjectsAttributeSet *old = _visualizationAttributes;
    [old release];
    _visualizationAttributes = [aChange copy];
    if (_renderCaches != NULL) {
        CFIndex count = CFDictionaryGetCount(_renderCaches);
        const void **caches;
        if (count > 0 && (caches = malloc(count * sizeof(void *))) != NULL) {
            CFDictionaryGetKeysAndValues(_renderCaches, caches, NULL);
            for (const void **cache = caches; cache < caches + count; cache++) {
                if (CFDictionaryGetValue(_renderCaches, *cache) != NULL) {
                    [(id)*cache retain];
                    [self invalidateRenderCache:(id)*cache withAttributeChangeNotification:nil];
                    [(id)*cache release];
                }
            }
            free(caches);
        }
    }
    if (old != nil)
        [self notifyObserversWithSelector:@selector(renderLayerDidChangeVisualizationAttributesSet:)];
}

- (void)addVisualizationAttributesToSet:(id)aSet
{
    [aSet unionMultipleObjectsAttributeSet:[self visualizationAttributes]];
}

- (id)visualizationAttributes
{
    if (_visualizationAttributes == nil) {
        HSMutableMultipleObjectsAttributeSet *set = [[HSMutableMultipleObjectsAttributeSet alloc] init];
        [self fillVisualizationAttributesSet:set];
        _visualizationAttributes = [set copy];
        [set release];
    }
    return _visualizationAttributes;
}

- (void)fillVisualizationAttributesSet:(id)aSet
{
}

- (id)description
{
    id hyperObject = [self hyperObject];
    return [NSString stringWithFormat:@"<%@: 0x%lx>{hyper-object: <%@: 0x%lx>; caching policy: %@; render sub-layers: (%@);}",
            NSStringFromClass([self class]), (unsigned long)self, NSStringFromClass([hyperObject class]), (unsigned long)hyperObject,
            [self HSGenericRenderLayer_cachingPolicyString], [self HSGenericRenderLayer_renderSublayersDescription]];
}

// One line per sublayer, indented through a per-thread indent so nested
// layers line up.
- (id)HSGenericRenderLayer_renderSublayersDescription
{
    NSUInteger count = [self renderSublayerCount];
    if (count == 0)
        return @" ";
    NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
    NSString *oldIndent = [threadDictionary objectForKey:@"HSRenderLayerIndent"];
    if (oldIndent == nil)
        oldIndent = @"";
    NSString *indent = [oldIndent stringByAppendingString:@"\t"];
    [threadDictionary setObject:indent forKey:@"HSRenderLayerIndent"];
    NSMutableString *description = [NSMutableString stringWithFormat:@"\n%@%@ {is hyper-object's root: %s; adds transparency layer requirement to neighbours: %s;}",
                                    indent, [self renderSublayerAtIndex:0],
                                    [self rootFlagOfRenderSublayerAtIndex:0] ? "YES" : "NO",
                                    [self transparencyLayerRequirementAdditionFlagOfRenderSublayerAtIndex:0] ? "YES" : "NO"];
    for (NSUInteger i = 1; i < count; i++)
        [description appendFormat:@",\n%@%@ {is hyper-object's root: %s; adds transparency layer requirement to neighbours: %s;}",
                                  indent, [self renderSublayerAtIndex:i],
                                  [self rootFlagOfRenderSublayerAtIndex:i] ? "YES" : "NO",
                                  [self transparencyLayerRequirementAdditionFlagOfRenderSublayerAtIndex:i] ? "YES" : "NO"];
    [description appendFormat:@"\n%@", oldIndent];
    [threadDictionary setObject:oldIndent forKey:@"HSRenderLayerIndent"];
    return description;
}

- (id)HSGenericRenderLayer_cachingPolicyString
{
    switch ([self cachingPolicy]) {
    case 0:
        return @"HSRenderLayerCachingPolicyDefault";
    case 1:
        return @"HSRenderLayerCachingPolicyNeverCache";
    case 2:
        return @"HSRenderLayerCachingPolicyAlwaysCache";
    case 3:
        return @"HSRenderLayerCachingPolicyCacheIfAnySublayerCaches";
    case 4:
        return @"HSRenderLayerCachingPolicyCacheIfAllSublayersCache";
    default:
        return nil;
    }
}

- (id)renderLayerAtPosition:(NSUInteger)aPosition inIndexPath:(id)aPath role:(id *)aRole
{
    id layer = self;
    for (NSUInteger position = 0; position < aPosition; position++)
        layer = [layer renderSublayerAtIndex:[aPath indexAtPosition:position]];
    NSUInteger index = [aPath indexAtPosition:aPosition];
    if (aRole != NULL)
        *aRole = [layer roleOfRenderSublayerAtIndex:index];
    return [layer renderSublayerAtIndex:index];
}

- (id)renderLayerAtIndexPath:(id)aPath role:(id *)aRole
{
    NSUInteger length = [aPath length];
    if (length == 0) {
        if (aRole != NULL)
            *aRole = nil;
        return self;
    }
    return [self renderLayerAtPosition:length - 1 inIndexPath:aPath role:aRole];
}

- (id)renderLayerPathForIndexPath:(id)aPath
{
    NSUInteger length = [aPath length];
    NSMutableArray *path = [NSMutableArray arrayWithCapacity:length + 1];
    id layer = self;
    [path addObject:layer];
    for (NSUInteger position = 0; position < length; position++) {
        layer = [layer renderSublayerAtIndex:[aPath indexAtPosition:position]];
        [path addObject:layer];
    }
    return [[path copy] autorelease];
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
    return nil;
}

- (id)renderSublayerAtIndex:(NSUInteger)aIndex
{
    return nil;
}

- (NSUInteger)renderSublayerCount
{
    return 0;
}

- (id)renderSublayers
{
    return [NSArray array];
}

- (NSInteger)cachingPolicy
{
    return _cachingPolicy;
}

- (id)hyperObject
{
    return _hyperObject;
}

- (id)copyRemovingRenderSublayers
{
    return [self retain];
}

- (void)dereferenceObject:(id)aObject
{
    if (_renderCaches != NULL)
        CFDictionaryRemoveValue(_renderCaches, aObject);
}

- (void)dealloc
{
    if (_observers != NULL)
        CFRelease(_observers);
    if (_renderCaches != NULL) {
        CFDictionaryApplyFunction(_renderCaches, HSGenericRenderLayerUnregisterCacheApplier, self);
        CFRelease(_renderCaches);
    }
    [_boundingRegionAttributes removeObserver:self selector:@selector(HSGenericRenderLayer_boundingRegionDidChange:) ofChanges:HSActualDidAttributeChanges];
    [_boundingRegionAttributes release];
    [_boundingRegion release];
    [_visualizationAttributes release];
    [_visualizationMaskAttributes release];
    [_hyperObject release];
    [super dealloc];
}

- (id)init
{
    [self release];
    return nil;
}

- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy
{
    self = [super init];
    if (self != nil) {
        _hyperObject = [aObject retain];
        _cachingPolicy = (int)aPolicy;
    }
    return self;
}

- (id)initWithHyperObject:(id)aObject
{
    return [self initWithHyperObject:aObject cachingPolicy:0];
}

@end

@implementation HSGenericRenderLayer_HSRenderCacheValidator

/* i386 ivar offsets: _renderLayer=0x4, _renderCache=0x8, _validationObservingSession=0xc */

- (void)validationAttibutesDidChange:(id)aChange
{
    [_renderCache retain];
    [_renderLayer invalidateRenderCache:_renderCache withAttributeChangeNotification:aChange];
    [_renderCache release];
}

- (void)dealloc
{
    [_validationObservingSession removeObserver:self selector:@selector(validationAttibutesDidChange:)];
    [_validationObservingSession release];
    [super dealloc];
}

// Neither the layer nor the cache is retained: the layer owns the validator
// and the cache is only weakly referenced.
- (id)initWithRenderLayer:(id)aLayer renderCache:(id)aCache validationAttributes:(id)aAttributes
{
    self = [super init];
    if (self == nil)
        return nil;
    _renderLayer = aLayer;
    _renderCache = aCache;
    _validationObservingSession = [[aAttributes sharedObservingSessionForChanges:HSActualDidAttributeChanges withPriority:0.25] retain];
    [_validationObservingSession addObserver:self selector:@selector(validationAttibutesDidChange:)];
    return self;
}

- (id)init
{
    [self release];
    return nil;
}

@end
