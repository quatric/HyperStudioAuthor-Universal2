#import "HyperPlayerBasePrefix.h"
#import "HSNodeUnit.h"


@interface HSGeometryNodeUnit : HSNodeUnit
{
    union __HSGeometry _geometry;
    unsigned int _isGeometryAffine:1;
    unsigned int _areCornerPositionsRead:1;
}
- (void)setCornerPositions:(NSPoint *)aPositions;
- (void)HSGeometryNodeUnit_setCornerPositions:(struct __HSCornerPositions)aPositions;
- (void)setPosition:(NSPoint)aPosition forCornerAtIndex:(NSUInteger)aIndex;
- (void)setAffineTransform:(CGAffineTransform)aTransform flippedHorizontally:(BOOL)aHorizontally;
- (void)setAffineTransform:(CGAffineTransform)aTransform;
- (NSPoint *)cornerPositions;
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
- (Class)hyperImplementationClassForHyperInterface:(id)aInterface;
- (BOOL)implementsHyperInterface:(id)aInterface;
- (id)implementedHyperInterfaces;
- (id)attributes;
- (void)setCornerPositionsAsArray:(id)aArray;
- (id)cornerPositionsAsArray;
- (void)setIsFlippedHorizontally:(BOOL)aHorizontally;
- (void)setAffineTransformAsArray:(id)aArray;
- (id)affineTransformAsArray;
- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext;
- (id)keysForExtraLoadingWithCodingContext:(id)aContext;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (id)copyWithZone:(NSZone *)aZone;
- (id)init;
@end

