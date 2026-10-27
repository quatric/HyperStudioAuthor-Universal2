#import "HyperPlayerBasePrefix.h"
#import "HSTextObject.h"


@interface HSPreviewTextObject : HSTextObject
{
    NSSize _maxAllowedSize;
    float _characterSpaceValue;
    float _realFontSize;
}
- (void)setFontSize:(CGFloat)aSize;
- (void)readjustFontSize;
- (NSSize)maxAllowedSize;
- (id)genericFontAttributes;
- (id)shadowAttributes;
- (id)textObjectAttributes;
- (void)setupWithTextObject:(id)aObject;
- (void)setHyperSpaceBetweenCharactersInPercent:(CGFloat)aPercent;
- (void)setHyperFontSize:(CGFloat)aSize;
- (void)setHyperFont:(id)aFont;
- (void)setHyperOutlineColor:(id)aColor;
- (void)setHyperOutlineWidth:(CGFloat)aWidth;
- (void)setHyperOutlineEnabled:(BOOL)aEnabled;
- (void)setHyperTextColor:(id)aColor;
- (void)setHyperUnderlined:(BOOL)aUnderlined;
- (void)setHyperItalic:(BOOL)aItalic;
- (void)setHyperBold:(BOOL)aBold;
- (void)updateWithTextObject:(id)aObject;
- (id)initWithTextObject:(id)aObject sizeOfOwnerView:(NSSize)aView;
@end

