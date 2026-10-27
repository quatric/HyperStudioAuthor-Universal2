#import "HyperPlayerBasePrefix.h"


@interface NSDictionary (HSCoreTextAttributes)
- (CGFloat)hyperShadowBlurRadius;
- (NSSize)hyperShadowOffset;
- (CGFloat)hyperShadowDistance;
- (CGFloat)hyperShadowAngle;
- (BOOL)isHyperShadowEnabled;
- (CGFloat)hyperOutlineWidth;
- (id)hyperOutlineColor;
- (BOOL)isHyperOutlineEnabled;
- (id)hyperTextAttributesDictionary;
- (CGFloat)hyperSpaceBetweenCharacters;
- (CGFloat)hyperSpaceBetweenLines;
- (NSUInteger)hyperTextAlignment;
- (id)hyperTextColor;
- (BOOL)isHyperExpanded;
- (BOOL)isHyperCondensed;
- (BOOL)isHyperUnderlined;
- (BOOL)isHyperItalic;
- (BOOL)isHyperBold;
- (CGFloat)hyperFontSize;
- (id)hyperFontFamily;
- (id)hyperFont;
@end

