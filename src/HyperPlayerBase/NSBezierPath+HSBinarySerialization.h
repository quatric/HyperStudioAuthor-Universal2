#import "HyperPlayerBasePrefix.h"


@interface NSBezierPath (HSBinarySerialization)
+ (id)hyperCGPathsFromBinaryStoredDataArray:(id)aArray;
+ (id)hyperBinaryDataArrayForStoringFromCGPaths:(id)aPaths;
+ (id)hyperBezierPathWithContentsOfBinaryFile:(id)aFile;
+ (id)hyperBezierPathWithBinaryStoredData:(id)aData;
- (id)hyperDataForBinaryStoring;
@end

@interface NSBezierPath (HSHitTesting)
- (BOOL)hyperPathContainsPoint:(NSPoint)aPoint tolerance:(CGFloat)aTolerance index:(int *)aIndex relativeDistance:(float *)aDistance;
- (void)hyperDistanceToA:(NSPoint)aA B:(NSPoint)aB fromC:(NSPoint)aC distance:(float *)aDistance u:(float *)aU;
- (CGFloat)hyperDistanceSquared:(NSPoint)aSquared :(NSPoint)aArg;
@end

@interface NSBezierPath (HSCreationFromCGPath)
+ (id)hyperBezierPathWithCGPath:(struct CGPath *)aPath;
+ (id)hyperBezierPathWithCGPath:(struct CGPath *)aPath affineTransform:(CGAffineTransform)aTransform;
- (struct CGPath *)hyperCGPath;
@end

@interface NSString (SVGParsing)
- (id)nodeTreeWithCurrentRecurseLevel:(NSUInteger)aLevel characterSets:(id)aSets;
- (NSRange)rangeOfCharacterSequenceFromSet:(id)aSet;
@end

@interface NSBezierPath (EXKeyValueCoding)
+ (id)hyperBezierPathFromOneBitMask:(void *)aMask width:(NSInteger)aWidth height:(NSInteger)aHeight bytesPerRow:(NSInteger)aRow pathColor:(NSInteger)aColor;
+ (id)extraStringRepresentationOfLineDashStyleRepresentationOfPattern:(float *)aPattern count:(NSInteger)aCount phase:(CGFloat)aPhase;
+ (BOOL)isExtraSVGRepFilled:(id)aFilled isMixed:(BOOL *)aMixed;
- (void)setExtraLineDashString:(id)aString;
- (void)setAndScaleExtraLineDashString:(id)aString;
- (void)setExtraLineDashString:(id)aString scaleFactor:(CGFloat)aFactor;
- (id)extraLineDashString;
- (void)setExtraSVGRep:(id)aRep;
- (id)extraSVGRep;
- (void)setExtraSVGAttributes:(id)aAttributes;
- (void)addSVGLine:(id)aLine;
- (void)addSVGCircle:(id)aCircle;
- (void)addSVGRect:(id)aRect;
- (void)addSVGEllipse:(id)aEllipse;
- (void)addSVGPolyline:(id)aPolyline;
- (void)addSVGPolygon:(id)aPolygon;
- (void)addSVGPolyline:(id)aPolyline closePath:(BOOL)aPath;
- (void)addSVGPath:(id)aPath;
- (void)addSVGPathString:(id)aString;
- (void)setExtraPathString:(id)aString;
- (id)extraPathString;
- (id)extraCanonizeWithScaling:(BOOL)aScaling appliedTransform:(id)aTransform;
- (id)keysForExtraLoadingWithCodingContext:(id)aContext;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
@end

@interface NSBezierPath (HSExtensions)
+ (id)hyperRoundedBorderPathWithRect:(NSRect)aRect cornerRadius:(CGFloat)aRadius;
+ (id)hyperBezierPathWithString:(id)aString;
- (id)hyperSubpathForElementRange:(NSRange)aRange;
- (CGFloat)hyperInclineAngleOfElementAtIndex:(NSUInteger)aIndex;
- (void)setHyperAssociatedPoints:(NSPoint *)aPoints atIndex:(NSUInteger)aIndex;
- (NSPoint)hyperBasePointOfElementAtIndex:(NSUInteger)aIndex;
- (NSUInteger)hyperElementAtIndex:(NSUInteger)aIndex associatedPoints:(NSPoint *)aPoints;
- (void)hyperAppendElement:(NSUInteger)aElement associatedPoints:(NSPoint *)aPoints;
- (void)hyperLineToPoint:(NSPoint)aPoint;
- (void)hyperClosePath;
- (void)hyperCopyVisualAttributesFrom:(id)aFrom;
- (NSRect)hyperVisualBounds;
- (NSRect)hyperVisualBoundsForElementRange:(NSRange)aRange;
- (NSSize)hyperMiterOffsetForPoints:(NSPoint *)aPoints;
- (NSRect)hyperLineCapRectForPointAtIndex:(NSUInteger)aIndex;
- (CGFloat)hyperLengthOfElementAtIndex:(NSInteger)aIndex;
- (NSPoint)hyperPointAtLength:(CGFloat)aLength;
- (CGFloat)hyperLength;
- (CGFloat)hyperCurveLength:(NSPoint)aLength :(NSPoint)aArg :(NSPoint)aArg2 :(NSPoint)aArg3;
- (CGFloat)hyperLineLength:(NSPoint)aLength :(NSPoint)aArg;
- (BOOL)isHyperStraightLine;
- (BOOL)isHyperLastContourClosed;
- (BOOL)isHyperEmpty;
@end

