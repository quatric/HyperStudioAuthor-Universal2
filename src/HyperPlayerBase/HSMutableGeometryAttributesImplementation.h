#import "HyperPlayerBasePrefix.h"
#import "HSWeaklyReferencedObject.h"


@interface HSMutableGeometryAttributesImplementation : HSWeaklyReferencedObject <HSNodeUnitBasedHyperImplementationCreating, HSMutableGeometryAttributes, HSGeometryAttributes, HSSizeAttributes, HSAttributes, HyperInterface, NSObject, HSWidthAttribute, HSSizeAttribute, HSGeometryAttribute, HSVisualAttribute, HSUndoableAttribute, HSAttribute, HSHeightAttribute, HSGeometryAffinenessAttribute, HSHorizontalFlipAttribute, HSFlipAttribute, HSAffineTransformAttribute, HSVerticalFlipAttribute, HSHorizontalScaleAttribute, HSBaseScaleAttribute, HSScaleAttribute, HSVerticalScaleAttribute, HSSkewAngleAttribute, HSWidthScaleAttribute, HSSizeScaleAttribute, HSHeightScaleAttribute, HSRotationAngleAttribute, HSHorizontalOffsetAttribute, HSOffsetAttribute, HSVerticalOffsetAttribute, HSRelativeCornerPositionsAttribute, HSAbsoluteCornerPositionsAttribute, HSMutableSizeAttributes>
{
    HSNode *_node;
    HSGeometryNodeUnit *_nodeUnit;
    id<HSStandaloneSizeAttributes> _sizeAttributes;
    id<HSStandaloneMutableSizeAttributes> _mutableSizeAttributes;
}
+ (id)hyperImplementationWithNode:(id)aNode unit:(id)aUnit;
- (id)attributeObservingController;
- (void)setSize:(NSSize)aSize aboutRelativePoint:(NSPoint)aPoint;
- (void)setSize:(NSSize)aSize affineTransform:(CGAffineTransform)aTransform flippedHorizontally:(BOOL)aHorizontally;
- (void)setSize:(NSSize)aSize affineTransform:(CGAffineTransform)aTransform;
- (void)setCornerPositions:(NSPoint *)aPositions;
- (void)setPosition:(NSPoint)aPosition forCornerAtIndex:(NSUInteger)aIndex;
- (void)setAffineTransform:(CGAffineTransform)aTransform flippedHorizontally:(BOOL)aHorizontally;
- (void)setAffineTransform:(CGAffineTransform)aTransform;
- (void)setSize:(NSSize)aSize;
- (NSPoint *)cornerPositions;
- (NSRect)frameBoundingRect;
- (NSSize)affineFrameSize;
- (CGFloat)affineFrameHeight;
- (CGFloat)affineFrameWidth;
- (NSSize)offset;
- (CGFloat)verticalOffset;
- (CGFloat)horizontalOffset;
- (CGFloat)rotationAngle;
- (NSSize)sizeScale;
- (CGFloat)heightScale;
- (CGFloat)widthScale;
- (CGFloat)skewAngle;
- (NSSize)baseScale;
- (CGFloat)verticalScale;
- (CGFloat)horizontalScale;
- (BOOL)isFlippedVertically;
- (BOOL)isFlippedHorizontally;
- (CGAffineTransform)affineTransform;
- (BOOL)isGeometryAffine;
- (NSRect)boundingRect;
- (NSSize)size;
- (NSSize)defaultSize;
- (CGFloat)height;
- (CGFloat)width;
- (id)hyperObject;
- (id)nodeUnit;
- (id)node;
- (void)dealloc;
- (id)initWithNodeUnit:(id)aUnit node:(id)aNode;
- (id)init;
@end

