#import "HyperPlayerBasePrefix.h"
#import "HSGraphics.h"


@interface HSColor : HSGraphics <HSMutableColor, HSColor, HSGraphics, HyperInterface, NSObject, EXKeyValueCoding, NSCopying, HSMutableGraphics, HSXMLStoringSupport, HSXMLLoadingSupport>
{
    BOOL _isClear;
    BOOL _isSolid;
    int _kind;
    BOOL _isCacheEnabled;
    NSImage *_cache;
    float _angle;
    float _centerX;
    float _centerY;
    NSColor *_startColor;
    NSColor *_endColor;
}
+ (id)defaultColor;
- (NSUInteger)hash;
- (BOOL)isEqual:(id)aEqual;
- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext;
- (id)XMLElementRepresentationInContext:(id)aContext;
- (BOOL)canBeStoredAsXMLElement;
- (id)XMLElementName;
- (id)copyWithZone:(NSZone *)aZone;
- (void)setKindAsString:(id)aString;
- (id)kindAsString;
- (id)keysForExtraLoadingWithCodingContext:(id)aContext;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)setCacheImage:(id)aImage;
- (void)drawRectangularGradientWithStartColor:(float *)aColor endColor:(float *)aColor2;
- (void)drawGradientInRect:(NSRect)aRect ofBounds:(NSRect)aBounds;
- (void)discardCache;
- (void)hyperDrawHighlightedInRect:(NSRect)aRect ofBounds:(NSRect)aBounds;
- (void)hyperDrawInRect:(NSRect)aRect ofBounds:(NSRect)aBounds;
- (void)setHyperCenterX:(CGFloat)aX andY:(CGFloat)aY;
- (void)setCenterX:(CGFloat)aX andY:(CGFloat)aY;
- (void)setHyperCenterX:(CGFloat)aX;
- (void)setHyperAngle:(CGFloat)aAngle;
- (void)setAngle:(CGFloat)aAngle;
- (CGFloat)hyperCenterY;
- (CGFloat)hyperCenterX;
- (CGFloat)hyperAngle;
- (void)hyperSwapGradientColors;
- (void)swapGradientColors;
- (void)setHyperEndColor:(id)aColor;
- (void)setEndColor:(id)aColor;
- (void)setHyperStartColor:(id)aColor;
- (void)setStartColor:(id)aColor;
- (id)hyperEndColor;
- (id)hyperStartColor;
- (void)setHyperKind:(NSInteger)aKind;
- (void)setKind:(NSInteger)aKind;
- (NSInteger)hyperKind;
- (void)setHyperCacheEnabled:(BOOL)aEnabled;
- (BOOL)isHyperCacheEnabled;
- (void)drawGradientInCocoaContext:(id)aContext rect:(NSRect)aRect ofBounds:(NSRect)aBounds;
- (void)drawGradientInCGContext:(struct CGContext *)aContext rect:(NSRect)aRect ofBounds:(NSRect)aBounds;
- (void)setHyperSolidColor:(id)aColor;
- (id)hyperSolidColor;
- (void)setSolid:(BOOL)aSolid;
- (void)setHyperClear:(BOOL)aClear;
- (void)setClear:(BOOL)aClear;
- (BOOL)isHyperGradient;
- (BOOL)isHyperSolid;
- (BOOL)isHyperClear;
- (void)controlTintDidChangeNotification:(id)aNotification;
- (void)dealloc;
- (id)init;
@end

