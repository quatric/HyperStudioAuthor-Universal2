#import "HyperPlayerBasePrefix.h"


@interface HSVectorGraphicsLineEnding : NSObject <EXKeyValueCoding, HSMutableVectorGraphicsLineEndingAttributes, HSVectorGraphicsLineEndingAttributes, HSAttributes, HyperInterface, NSObject, HSVectorGraphicsLineEndingScaleAttribute, HSVectorGraphicsObjectLineEndingsAttribute, HSVisualAttribute, HSUndoableAttribute, HSAttribute, HSVectorGraphicsLineEndingsInfoObjectAttribute>
{
    id<HSVectorGraphicsLineEndingOwner> _owner;
    HSVectorGraphicsLineEndingInfoObject *_infoObject;
    int _scale;
    NSBezierPath *_cachedPath;
    float _angle;
    float _additionalScale;
    NSPoint _origin;
    BOOL _isInverse;
}
- (id)attributeObservingController;
- (id)keysForExtraLoadingWithCodingContext:(id)aContext;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)setHyperInfoObject:(id)aObject;
- (void)setHyperScale:(NSInteger)aScale;
- (id)hyperInfoObject;
- (NSInteger)hyperScale;
- (void)setInfoObjectKey:(id)aKey;
- (void)setInfoObject:(id)aObject;
- (void)setScale:(NSInteger)aScale;
- (BOOL)isFilled;
- (id)path;
- (id)infoObjectKey;
- (id)pathAtPoint:(NSPoint)aPoint angle:(CGFloat)aAngle additionalScale:(CGFloat)aScale isInverse:(BOOL)aInverse;
- (id)undoManager;
- (id)hyperObject;
- (void)setOwner:(id)aOwner;
- (id)owner;
- (void)invalidateCache;
- (void)dealloc;
- (id)init;
@end

