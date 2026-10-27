#import "NSDictionary+HSCoreTextAttributes.h"

// Text attributes read through the attribute-dictionary replacements.
@implementation NSDictionary (HSCoreTextAttributes)
- (CGFloat)hyperShadowBlurRadius
{
    NSShadow *shadow = [NSAttributedString hyperAttribute:NSShadowAttributeName fromDictionary:self];
    return shadow ? (float)[shadow shadowBlurRadius] : 0.0f;
}
- (NSSize)hyperShadowOffset
{
    NSShadow *shadow = [NSAttributedString hyperAttribute:NSShadowAttributeName fromDictionary:self];
    return shadow ? [shadow shadowOffset] : NSZeroSize;
}
- (CGFloat)hyperShadowDistance
{
    NSShadow *shadow = [NSAttributedString hyperAttribute:NSShadowAttributeName fromDictionary:self];
    return shadow ? (float)[NSShadow hyperShadowDistanceWithShadowOffset:[shadow shadowOffset]] : 0.0f;
}
- (CGFloat)hyperShadowAngle
{
    NSShadow *shadow = [NSAttributedString hyperAttribute:NSShadowAttributeName fromDictionary:self];
    return shadow ? (float)[NSShadow hyperShadowAngleWithShadowOffset:[shadow shadowOffset]] : 0.0f;
}
- (BOOL)isHyperShadowEnabled
{
    return [NSAttributedString hyperActualAttribute:NSShadowAttributeName fromDictionary:self] != nil;
}
- (CGFloat)hyperOutlineWidth
{
    id width = [NSAttributedString hyperAttribute:NSStrokeWidthAttributeName fromDictionary:self];
    return width ? (float)[width floatValue] : 0.0f;
}
// Without a stroke color the outline uses the text color.
- (id)hyperOutlineColor
{
    id color = [NSAttributedString hyperAttribute:NSStrokeColorAttributeName fromDictionary:self];
    return color ? color : [NSAttributedString hyperAttribute:NSForegroundColorAttributeName fromDictionary:self];
}
- (BOOL)isHyperOutlineEnabled
{
    return [NSAttributedString hyperAttribute:NSStrokeWidthAttributeName fromDictionary:self] != nil;
}
- (id)hyperTextAttributesDictionary
{
    return self;
}
- (CGFloat)hyperSpaceBetweenCharacters
{
    id kern = [NSAttributedString hyperAttribute:NSKernAttributeName fromDictionary:self];
    return kern ? (float)[kern floatValue] : 0.0f;
}
- (CGFloat)hyperSpaceBetweenLines
{
    return (float)[(NSParagraphStyle *)[NSAttributedString hyperAttribute:NSParagraphStyleAttributeName fromDictionary:self] lineSpacing];
}
- (NSUInteger)hyperTextAlignment
{
    return [(NSParagraphStyle *)[NSAttributedString hyperAttribute:NSParagraphStyleAttributeName fromDictionary:self] alignment];
}
// Gradient colors report their original color.
- (id)hyperTextColor
{
    id color = [NSAttributedString hyperAttribute:NSForegroundColorAttributeName fromDictionary:self];
    if ([color hyperGradientColor])
        color = [[color hyperGradientColor] originalColor];
    return color;
}
- (BOOL)isHyperExpanded
{
    return ([[NSFontManager sharedFontManager] traitsOfFont:[self hyperFont]] & NSExpandedFontMask) != 0;
}
- (BOOL)isHyperCondensed
{
    return ([[NSFontManager sharedFontManager] traitsOfFont:[self hyperFont]] & NSCondensedFontMask) != 0;
}
- (BOOL)isHyperUnderlined
{
    id underline = [NSAttributedString hyperAttribute:NSUnderlineStyleAttributeName fromDictionary:self];
    return underline && [underline intValue] != 0;
}
- (BOOL)isHyperItalic
{
    return ([[NSFontManager sharedFontManager] traitsOfFont:[self hyperFont]] & NSItalicFontMask) != 0;
}
- (BOOL)isHyperBold
{
    return ([[NSFontManager sharedFontManager] traitsOfFont:[self hyperFont]] & NSBoldFontMask) != 0;
}
- (CGFloat)hyperFontSize
{
    return (float)[[self hyperFont] pointSize];
}
- (id)hyperFontFamily
{
    return [[self hyperFont] familyName];
}
- (id)hyperFont
{
    return [NSAttributedString hyperAttribute:NSFontAttributeName fromDictionary:self];
}
@end
