#import "HSGenericRenderCache.h"

// A rendered copy of a render layer under a transform; the layer is weakly
// referenced.
@implementation HSGenericRenderCache
+ (id)defaultValidnessEvaluator
{
    return nil;
}
- (NSUInteger)cashSize
{
    return 0;
}
- (void)drawRegion:(id)aRegion
{
}
- (id)attachments
{
    return _attachments ? [[_attachments copy] autorelease] : [NSDictionary dictionary];
}
- (void)setAttachment:(id)aAttachment forKey:(id)aKey
{
    if (!_attachments) {
        _attachments = [[NSMutableDictionary alloc] init];
        if (!_attachments)
            return;
    }
    if (aAttachment)
        [_attachments setObject:aAttachment forKey:aKey];
    else
        [_attachments removeObjectForKey:aKey];
}
- (id)attachmentForKey:(id)aKey
{
    return [_attachments objectForKey:aKey];
}
- (CGFloat)validnessForAffineTransform:(CGAffineTransform)aTransform
{
    float validness = (float)[self validness];
    if (_validnessEvaluator)
        validness = (float)[_validnessEvaluator evaluateForAffineTransform:CGAffineTransformConcat([self drawingAffineTransform], aTransform) withContentValidness:validness contentAffineTransform:[self affineTransform]];
    return validness;
}
- (void)setPersistentValidness:(CGFloat)aValidness
{
    if (_persistentValidness != (float)aValidness) {
        _persistentValidness = (float)aValidness;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSRenderCacheDidChangePersistentValidness" object:self];
    }
}
- (void)setTemporaryValidness:(CGFloat)aValidness
{
    if (_temporaryValidness != (float)aValidness) {
        _temporaryValidness = (float)aValidness;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSRenderCacheDidChangeTemporaryValidness" object:self];
    }
}
- (CGFloat)persistentValidness
{
    return _persistentValidness;
}
- (CGFloat)validness
{
    return _temporaryValidness;
}
- (BOOL)intersectsWithRegion:(id)aRegion
{
    return NO;
}
// Computed once.
- (BOOL)containsWholeRenderLayer
{
    if (!_isContainsWholeRenderLayerFlagInitialized) {
        _containsWholeRenderLayer = _renderLayer ? ([self containsRegion:[_renderLayer boundingRegion]] ? 1 : 0) : 0;
        _isContainsWholeRenderLayerFlagInitialized = 1;
    }
    return _containsWholeRenderLayer;
}
- (BOOL)containsRegion:(id)aRegion
{
    return NO;
}
// The inverse of the cache transform, computed lazily.
- (CGAffineTransform)drawingAffineTransform
{
    if (!_isDrawingTransformCalculated) {
        _drawingTransform = CGAffineTransformInvert(_transform);
        _isDrawingTransformCalculated = 1;
    }
    return _drawingTransform;
}
- (void)setAffineTransform:(CGAffineTransform)aTransform
{
    _transform = aTransform;
    _isDrawingTransformCalculated = 0;
}
- (CGAffineTransform)affineTransform
{
    return _transform;
}
- (id)renderLayer
{
    return _renderLayer;
}
- (void)dereferenceObject:(id)aObject
{
    if (_renderLayer == aObject) {
        _renderLayer = nil;
        _temporaryValidness = 0.0f;
        _persistentValidness = 0.0f;
    }
}
- (void)dealloc
{
    [_renderLayer unregisterWeakReferencer:self];
    [_validnessEvaluator release];
    [_attachments release];
    [super dealloc];
}
- (id)initWithRenderLayer:(id)aLayer affineTransform:(CGAffineTransform)aTransform temporaryValidness:(CGFloat)aValidness persistentValidness:(CGFloat)aValidness2 validnessEvaluator:(id)aEvaluator
{
    self = [super init];
    if (!self)
        return nil;
    _renderLayer = aLayer;
    [aLayer registerWeakReferencer:self];
    _transform = aTransform;
    _temporaryValidness = (float)aValidness;
    _persistentValidness = (float)aValidness2;
    if (!aEvaluator)
        aEvaluator = [[self class] defaultValidnessEvaluator];
    _validnessEvaluator = [aEvaluator retain];
    return self;
}
- (id)init
{
    [self release];
    return nil;
}
@end
