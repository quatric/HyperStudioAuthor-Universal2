#import "HyperPlayerBasePrefix.h"


@interface HSGradientColor : NSColor
{
    HSColor *_color;
    NSColor *_embeddedColor;
    HSGradientColor *_storedOriginalColor;
    BOOL _overridesAlpha;
    float _overriddenAlpha;
}
+ (id)colorWithGradientColor:(id)aColor overriddenAlpha:(CGFloat)aAlpha;
+ (id)gradientColorWithHSColor:(id)aColor;
+ (id)gradientColorWithStartColor:(id)aColor endColor:(id)aColor2;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (BOOL)shouldUseHyperDefaultImplementationForKeyValueCoding;
- (BOOL)canBeExtraPostLoaded;
- (CGFloat)overriddenAlpha;
- (void)setStoredOriginalColor:(id)aColor;
- (id)storedOriginalColor;
- (void)setOverriddenAlpha:(CGFloat)aAlpha;
- (BOOL)overridesAlpha;
- (void)setOverridesAlpha:(BOOL)aAlpha;
- (id)hyperHSColor;
- (void)encodeWithCoder:(id)aCoder;
- (id)initWithCoder:(id)aCoder;
- (Class)classForCoder;
- (NSUInteger)hash;
- (BOOL)isEqual:(id)aEqual;
- (id)patternImage;
- (void)writeToPasteboard:(id)aPasteboard;
- (CGFloat)alphaComponent;
- (void)getComponents:(CGFloat *)aComponents;
- (NSInteger)numberOfComponents;
- (id)colorSpace;
- (void)getCyan:(CGFloat *)aCyan magenta:(CGFloat *)aMagenta yellow:(CGFloat *)aYellow black:(CGFloat *)aBlack alpha:(CGFloat *)aAlpha;
- (CGFloat)blackComponent;
- (CGFloat)yellowComponent;
- (CGFloat)magentaComponent;
- (CGFloat)cyanComponent;
- (void)getWhite:(CGFloat *)aWhite alpha:(CGFloat *)aAlpha;
- (CGFloat)whiteComponent;
- (void)getHue:(CGFloat *)aHue saturation:(CGFloat *)aSaturation brightness:(CGFloat *)aBrightness alpha:(CGFloat *)aAlpha;
- (CGFloat)brightnessComponent;
- (CGFloat)saturationComponent;
- (CGFloat)hueComponent;
- (void)getRed:(CGFloat *)aRed green:(CGFloat *)aGreen blue:(CGFloat *)aBlue alpha:(CGFloat *)aAlpha;
- (CGFloat)blueComponent;
- (CGFloat)greenComponent;
- (CGFloat)redComponent;
- (id)localizedColorNameComponent;
- (id)localizedCatalogNameComponent;
- (id)colorNameComponent;
- (id)catalogNameComponent;
- (id)colorWithAlphaComponent:(CGFloat)aComponent;
- (id)blendedColorWithFraction:(CGFloat)aFraction ofColor:(id)aColor;
- (id)colorUsingColorSpace:(id)aSpace;
- (id)colorUsingColorSpaceName:(id)aName device:(id)aDevice;
- (id)colorUsingColorSpaceName:(id)aName;
- (id)colorSpaceName;
- (void)setStroke;
- (void)setFill;
- (void)set;
- (id)shadowWithLevel:(CGFloat)aLevel;
- (id)highlightWithLevel:(CGFloat)aLevel;
- (void)setOverridesAlphaWithValue:(CGFloat)aValue originalColor:(id)aColor;
- (id)originalColor;
- (void)setHyperHSColor:(id)aColor;
- (id)embeddedColor;
- (id)clonedTransparentColor;
- (void)drawSwatchInRect:(NSRect)aRect;
- (struct CGEColor *)BT_coreGraphicsExtendedColor;
- (id)queryHyperInterface:(id)aInterface;
- (void)dealloc;
@end

