#import "HyperPlayerBasePrefix.h"
#import "HSWeaklyReferencedObject.h"


@interface HSGenericRenderCache : HSWeaklyReferencedObject <HSRenderCache, NSObject, HSWeakReferencer>
{
    id<HSRenderLayer> _renderLayer;
    CGAffineTransform _transform;
    CGAffineTransform _drawingTransform;
    float _temporaryValidness;
    float _persistentValidness;
    id<HSRenderCacheValidnessEvaluator> _validnessEvaluator;
    NSMutableDictionary *_attachments;
    unsigned int _containsWholeRenderLayer:1;
    unsigned int _isContainsWholeRenderLayerFlagInitialized:1;
    unsigned int _isDrawingTransformCalculated:1;
}
+ (id)defaultValidnessEvaluator;
- (NSUInteger)cashSize;
- (void)drawRegion:(id)aRegion;
- (id)attachments;
- (void)setAttachment:(id)aAttachment forKey:(id)aKey;
- (id)attachmentForKey:(id)aKey;
- (CGFloat)validnessForAffineTransform:(CGAffineTransform)aTransform;
- (void)setPersistentValidness:(CGFloat)aValidness;
- (void)setTemporaryValidness:(CGFloat)aValidness;
- (CGFloat)persistentValidness;
- (CGFloat)validness;
- (BOOL)intersectsWithRegion:(id)aRegion;
- (BOOL)containsWholeRenderLayer;
- (BOOL)containsRegion:(id)aRegion;
- (CGAffineTransform)drawingAffineTransform;
- (void)setAffineTransform:(CGAffineTransform)aTransform;
- (CGAffineTransform)affineTransform;
- (id)renderLayer;
- (void)dereferenceObject:(id)aObject;
- (void)dealloc;
- (id)initWithRenderLayer:(id)aLayer affineTransform:(CGAffineTransform)aTransform temporaryValidness:(CGFloat)aValidness persistentValidness:(CGFloat)aValidness2 validnessEvaluator:(id)aEvaluator;
- (id)init;
@end

