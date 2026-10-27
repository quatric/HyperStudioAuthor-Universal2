#import "HyperPlayerBasePrefix.h"


@interface NSAttributedString (HSCoreTextInterface)
- (NSSize)hyperRequiredSizeForTextBlockOfHeight:(CGFloat)aHeight maximumWidth:(CGFloat)aWidth;
- (NSSize)hyperRequiredSizeToFitWidth:(CGFloat)aWidth fixedWidth:(BOOL)aWidth2;
- (BOOL)isHyperEmpty;
- (id)hyperString;
- (BOOL)hasBackground;
- (id)hyperTextBackgroundColor;
- (void)getHyperTextAttributes:(id *)aAttributes multipleValues:(BOOL *)aValues;
- (void)getHyperSpaceBetweenCharacters:(float *)aCharacters multipleValues:(BOOL *)aValues;
- (void)getHyperSpaceBetweenLines:(float *)aLines multipleValues:(BOOL *)aValues;
- (void)getHyperTextAlignment:(unsigned int *)aAlignment multipleValues:(BOOL *)aValues;
- (void)getHyperTextColor:(id *)aColor multipleValues:(BOOL *)aValues;
- (void)getHyperShadowDistance:(float *)aDistance multipleValues:(BOOL *)aValues;
- (void)getHyperShadowOffset:(NSSize *)aOffset multipleValues:(BOOL *)aValues;
- (void)getHyperShadowBlurRadius:(float *)aRadius multipleValues:(BOOL *)aValues;
- (void)getHyperShadowAngle:(float *)aAngle multipleValues:(BOOL *)aValues;
- (void)getHyperShadowEnabled:(BOOL *)aEnabled multipleValues:(BOOL *)aValues;
- (void)getHyperShadow:(id *)aShadow multipleValues:(BOOL *)aValues;
- (void)getHyperOutlineColor:(id *)aColor multipleValues:(BOOL *)aValues;
- (void)getHyperOutlineWidth:(float *)aWidth multipleValues:(BOOL *)aValues;
- (void)getHyperOutlineEnabled:(BOOL *)aEnabled multipleValues:(BOOL *)aValues;
- (void)getHyperExpanded:(BOOL *)aExpanded multipleValues:(BOOL *)aValues;
- (void)getHyperCondensed:(BOOL *)aCondensed multipleValues:(BOOL *)aValues;
- (void)getHyperUnderlined:(BOOL *)aUnderlined multipleValues:(BOOL *)aValues;
- (void)getHyperItalic:(BOOL *)aItalic multipleValues:(BOOL *)aValues;
- (void)getHyperBold:(BOOL *)aBold multipleValues:(BOOL *)aValues;
- (void)getHyperFontSize:(float *)aSize multipleValues:(BOOL *)aValues;
- (void)getHyperFontFamily:(id *)aFamily multipleValues:(BOOL *)aValues;
- (void)getHyperFont:(id *)aFont multipleValues:(BOOL *)aValues;
- (id)hyperTextAttributesDictionary;
- (CGFloat)hyperSpaceBetweenCharacters;
- (CGFloat)hyperSpaceBetweenLines;
- (NSUInteger)hyperTextAlignment;
- (id)hyperTextColor;
- (CGFloat)hyperShadowBlurRadius;
- (CGFloat)hyperShadowDistance;
- (NSSize)hyperShadowOffset;
- (CGFloat)hyperShadowAngle;
- (BOOL)isHyperShadowEnabled;
- (id)hyperOutlineColor;
- (CGFloat)hyperOutlineWidth;
- (BOOL)isHyperOutlineEnabled;
- (BOOL)isHyperCondensed;
- (BOOL)isHyperExpanded;
- (BOOL)isHyperUnderlined;
- (BOOL)isHyperItalic;
- (BOOL)isHyperBold;
- (CGFloat)hyperFontSize;
- (id)hyperFontFamily;
- (id)hyperFont;
@end

