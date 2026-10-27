#import "HSPreviewTextObject.h"

@implementation HSPreviewTextObject
// The preview caps the font size at 28 points and shrinks it to fit.
- (void)setFontSize:(CGFloat)aSize
{
    float size = (float)aSize;
    if (size > 28.0f)
        size = 28.0f;
    [[self genericFontAttributes] setHyperFontSize:size];
    [self setHyperSpaceBetweenCharactersInPercent:_characterSpaceValue];
    if ((float)[[self genericFontAttributes] hyperFontSize] == size)
        [self readjustFontSize];
}
- (void)readjustFontSize
{
    NSRect bounds = [self maximumVisibleBoundsForText];
    if ([self maxAllowedSize].width < bounds.size.width)
        [self setFontSize:[[self genericFontAttributes] hyperFontSize] - 1.0];
}
- (NSSize)maxAllowedSize
{
    return _maxAllowedSize;
}
- (id)genericFontAttributes
{
    return [self queryHyperInterface:@protocol(HSGenericFontAttributes)];
}
- (id)shadowAttributes
{
    return [self queryHyperInterface:@protocol(HSMutableShadowAttributes)];
}
- (id)textObjectAttributes
{
    return [self queryHyperInterface:@protocol(HSTextObjectAttributes)];
}
- (void)setupWithTextObject:(id)aObject
{
    id textAttributes = [aObject queryHyperInterface:@protocol(HSTextObjectAttributes)];
    id shadowAttributes = [aObject queryHyperInterface:@protocol(HSMutableShadowAttributes)];
    id attributes = [self textObjectAttributes];
    [attributes hyperReplaceText:[textAttributes hyperText]];
    [attributes setHyperBold:[textAttributes isHyperBold]];
    [attributes setHyperItalic:[textAttributes isHyperItalic]];
    [attributes setHyperUnderlined:[textAttributes isHyperUnderlined]];
    [attributes setHyperFont:[textAttributes hyperFont]];
    [self setHyperFontSize:[textAttributes hyperFontSize]];
    [attributes setHyperTextColor:[textAttributes hyperTextColor]];
    [attributes setHyperOutlineColor:[textAttributes hyperOutlineColor]];
    [self setHyperSpaceBetweenCharactersInPercent:roundf((float)([textAttributes hyperSpaceBetweenCharacters] * 100.0f) / (float)[textAttributes hyperFontSize])];
    [attributes setHyperTextAlignment:NSTextAlignmentCenter];
    id shadow = [self shadowAttributes];
    [shadow setHyperShadowEnabled:[shadowAttributes isHyperShadowEnabled]];
    [shadow setHyperShadowOffset:[shadowAttributes hyperShadowOffset]];
    [shadow setHyperShadowAngle:[shadowAttributes hyperShadowAngle]];
    [shadow setHyperShadowBlurRadius:[shadowAttributes hyperShadowBlurRadius]];
    [shadow setHyperShadowOpacity:[shadowAttributes hyperShadowOpacity]];
}
// Spacing is kept as a percentage of the font size; growing it back restores
// the real font size before shrinking again.
- (void)setHyperSpaceBetweenCharactersInPercent:(CGFloat)aPercent
{
    float previous = _characterSpaceValue;
    _characterSpaceValue = (float)aPercent;
    if ((float)aPercent < previous)
        [self setFontSize:_realFontSize];
    id attributes = [self textObjectAttributes];
    [attributes setHyperSpaceBetweenCharacters:((float)[attributes hyperFontSize] * _characterSpaceValue) / 100.0f];
    [self readjustFontSize];
}
- (void)setHyperFontSize:(CGFloat)aSize
{
    _realFontSize = (float)aSize;
    [self setFontSize:aSize];
}
- (void)setHyperFont:(id)aFont
{
    [[self genericFontAttributes] setHyperFont:aFont];
}
- (void)setHyperOutlineColor:(id)aColor
{
    [[self textObjectAttributes] setHyperOutlineColor:aColor];
}
- (void)setHyperOutlineWidth:(CGFloat)aWidth
{
    [[self textObjectAttributes] setHyperOutlineWidth:aWidth];
}
- (void)setHyperOutlineEnabled:(BOOL)aEnabled
{
    [[self textObjectAttributes] setHyperOutlineEnabled:aEnabled];
}
- (void)setHyperTextColor:(id)aColor
{
    [[self textObjectAttributes] setHyperTextColor:aColor];
}
- (void)setHyperUnderlined:(BOOL)aUnderlined
{
    [[self textObjectAttributes] setHyperUnderlined:aUnderlined];
}
- (void)setHyperItalic:(BOOL)aItalic
{
    [[self textObjectAttributes] setHyperItalic:aItalic];
}
- (void)setHyperBold:(BOOL)aBold
{
    [[self textObjectAttributes] setHyperBold:aBold];
    [self readjustFontSize];
}
- (void)updateWithTextObject:(id)aObject
{
    [self setupWithTextObject:aObject];
}
- (id)initWithTextObject:(id)aObject sizeOfOwnerView:(NSSize)aView
{
    self = [super init];
    if (self) {
        _maxAllowedSize = aView;
        _characterSpaceValue = 0;
        _realFontSize = 0;
        if (aObject)
            [self setupWithTextObject:aObject];
    }
    return self;
}
@end
