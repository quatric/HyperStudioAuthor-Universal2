#import "NSAttributedString+HSCoreTextInterface.h"
#import "HSAttributeDictionaryReplacements.h"

// The text attributes of the whole string, and its required text block size
// (an empty string is measured as a space with its attributes).
@implementation NSAttributedString (HSCoreTextInterface)

- (NSSize)hyperRequiredSizeForTextBlockOfHeight:(CGFloat)aHeight maximumWidth:(CGFloat)aWidth
{
    if ([self isHyperEmpty]) {
        NSAttributedString *string = [[[NSAttributedString alloc] initWithString:@" " attributes:[self hyperTextAttributesDictionary]] autorelease];
        return [NSTextStorage hyperTextBlockSizeForAttributedString:string ofHeight:aHeight maxWidth:aWidth];
    }
    if ([self isKindOfClass:[NSTextStorage class]])
        return [NSTextStorage hyperTextBlockSizeForTextStorage:self ofHeight:aHeight maxWidth:aWidth];
    return [NSTextStorage hyperTextBlockSizeForAttributedString:self ofHeight:aHeight maxWidth:aWidth];
}

- (NSSize)hyperRequiredSizeToFitWidth:(CGFloat)aWidth fixedWidth:(BOOL)aWidth2
{
    if ([self isHyperEmpty]) {
        NSAttributedString *string = [[[NSAttributedString alloc] initWithString:@" " attributes:[self hyperTextAttributesDictionary]] autorelease];
        return [NSTextStorage hyperSizeForAttributedString:string withWidth:aWidth fixedWidth:aWidth2];
    }
    if ([self isKindOfClass:[NSTextStorage class]])
        return [NSTextStorage hyperSizeForTextStorage:self withWidth:aWidth fixedWidth:aWidth2];
    return [NSTextStorage hyperSizeForAttributedString:self withWidth:aWidth fixedWidth:aWidth2];
}

- (BOOL)isHyperEmpty
{
    return [self length] == 0;
}

- (id)hyperString
{
    return [self string];
}

- (BOOL)hasBackground
{
    return NO;
}

- (id)hyperTextBackgroundColor
{
    return nil;
}

- (void)getHyperTextAttributes:(id *)aAttributes multipleValues:(BOOL *)aValues
{
    id attributes = nil;
    [self getHyperAttributesDictionary:&attributes inRange:NSMakeRange(0, [self length]) multipleValues:aValues];
    *aAttributes = attributes;
}

- (void)getHyperSpaceBetweenCharacters:(float *)aCharacters multipleValues:(BOOL *)aValues
{
    [self getHyperSpaceBetweenCharacters:aCharacters inRange:NSMakeRange(0, [self length]) multipleValues:aValues];
}

- (void)getHyperSpaceBetweenLines:(float *)aLines multipleValues:(BOOL *)aValues
{
    [self getHyperSpaceBetweenLines:aLines inRange:NSMakeRange(0, [self length]) multipleValues:aValues];
}

- (void)getHyperTextAlignment:(unsigned int *)aAlignment multipleValues:(BOOL *)aValues
{
    [self getHyperTextAlignment:aAlignment inRange:NSMakeRange(0, [self length]) multipleValues:aValues];
}

- (void)getHyperTextColor:(id *)aColor multipleValues:(BOOL *)aValues
{
    [self getHyperTextColor:aColor inRange:NSMakeRange(0, [self length]) multipleValues:aValues];
}

- (void)getHyperShadowDistance:(float *)aDistance multipleValues:(BOOL *)aValues
{
    [self getHyperShadowDistance:aDistance inRange:NSMakeRange(0, [self length]) multipleValues:aValues];
}

- (void)getHyperShadowOffset:(NSSize *)aOffset multipleValues:(BOOL *)aValues
{
    [self getHyperShadowOffset:aOffset inRange:NSMakeRange(0, [self length]) multipleValues:aValues];
}

- (void)getHyperShadowBlurRadius:(float *)aRadius multipleValues:(BOOL *)aValues
{
    [self getHyperShadowBlurRadius:aRadius inRange:NSMakeRange(0, [self length]) multipleValues:aValues];
}

- (void)getHyperShadowAngle:(float *)aAngle multipleValues:(BOOL *)aValues
{
    [self getHyperShadowAngle:aAngle inRange:NSMakeRange(0, [self length]) multipleValues:aValues];
}

- (void)getHyperShadowEnabled:(BOOL *)aEnabled multipleValues:(BOOL *)aValues
{
    [self getHyperShadowEnabled:aEnabled inRange:NSMakeRange(0, [self length]) multipleValues:aValues];
}

- (void)getHyperShadow:(id *)aShadow multipleValues:(BOOL *)aValues
{
    [self getHyperShadow:aShadow inRange:NSMakeRange(0, [self length]) multipleValues:aValues];
}

- (void)getHyperOutlineColor:(id *)aColor multipleValues:(BOOL *)aValues
{
    [self getHyperOutlineColor:aColor inRange:NSMakeRange(0, [self length]) multipleValues:aValues];
}

- (void)getHyperOutlineWidth:(float *)aWidth multipleValues:(BOOL *)aValues
{
    [self getHyperOutlineWidth:aWidth inRange:NSMakeRange(0, [self length]) multipleValues:aValues];
}

- (void)getHyperOutlineEnabled:(BOOL *)aEnabled multipleValues:(BOOL *)aValues
{
    [self getHyperOutlineEnabled:aEnabled inRange:NSMakeRange(0, [self length]) multipleValues:aValues];
}

- (void)getHyperExpanded:(BOOL *)aExpanded multipleValues:(BOOL *)aValues
{
    [self getHyperExpanded:aExpanded inRange:NSMakeRange(0, [self length]) multipleValues:aValues];
}

- (void)getHyperCondensed:(BOOL *)aCondensed multipleValues:(BOOL *)aValues
{
    [self getHyperCondensed:aCondensed inRange:NSMakeRange(0, [self length]) multipleValues:aValues];
}

- (void)getHyperUnderlined:(BOOL *)aUnderlined multipleValues:(BOOL *)aValues
{
    [self getHyperUnderlined:aUnderlined inRange:NSMakeRange(0, [self length]) multipleValues:aValues];
}

- (void)getHyperItalic:(BOOL *)aItalic multipleValues:(BOOL *)aValues
{
    [self getHyperItalic:aItalic inRange:NSMakeRange(0, [self length]) multipleValues:aValues];
}

- (void)getHyperBold:(BOOL *)aBold multipleValues:(BOOL *)aValues
{
    [self getHyperBold:aBold inRange:NSMakeRange(0, [self length]) multipleValues:aValues];
}

- (void)getHyperFontSize:(float *)aSize multipleValues:(BOOL *)aValues
{
    [self getHyperFontSize:aSize inRange:NSMakeRange(0, [self length]) multipleValues:aValues];
}

- (void)getHyperFontFamily:(id *)aFamily multipleValues:(BOOL *)aValues
{
    [self getHyperFontFamily:aFamily inRange:NSMakeRange(0, [self length]) multipleValues:aValues];
}

- (void)getHyperFont:(id *)aFont multipleValues:(BOOL *)aValues
{
    [self getHyperFont:aFont inRange:NSMakeRange(0, [self length]) multipleValues:aValues];
}

- (id)hyperTextAttributesDictionary
{
    id attributes = nil;
    [self getHyperAttributesDictionary:&attributes inRange:NSMakeRange(0, [self length]) multipleValues:NULL];
    return attributes;
}

- (CGFloat)hyperSpaceBetweenCharacters
{
    float value = 0;
    [self getHyperSpaceBetweenCharacters:&value multipleValues:NULL];
    return value;
}

- (CGFloat)hyperSpaceBetweenLines
{
    float value = 0;
    [self getHyperSpaceBetweenLines:&value multipleValues:NULL];
    return value;
}

- (NSUInteger)hyperTextAlignment
{
    unsigned int value = 0;
    [self getHyperTextAlignment:&value multipleValues:NULL];
    return value;
}

- (id)hyperTextColor
{
    id value = nil;
    [self getHyperTextColor:&value multipleValues:NULL];
    return value;
}

- (CGFloat)hyperShadowBlurRadius
{
    float value = 0;
    [self getHyperShadowBlurRadius:&value multipleValues:NULL];
    return value;
}

- (CGFloat)hyperShadowDistance
{
    float value = 0;
    [self getHyperShadowDistance:&value multipleValues:NULL];
    return value;
}

- (NSSize)hyperShadowOffset
{
    NSSize value = NSZeroSize;
    [self getHyperShadowOffset:&value multipleValues:NULL];
    return value;
}

- (CGFloat)hyperShadowAngle
{
    float value = 0;
    [self getHyperShadowAngle:&value multipleValues:NULL];
    return value;
}

- (BOOL)isHyperShadowEnabled
{
    BOOL value = NO;
    [self getHyperShadowEnabled:&value multipleValues:NULL];
    return value;
}

- (id)hyperOutlineColor
{
    id value = nil;
    [self getHyperOutlineColor:&value multipleValues:NULL];
    return value;
}

- (CGFloat)hyperOutlineWidth
{
    float value = 0;
    [self getHyperOutlineWidth:&value multipleValues:NULL];
    return value;
}

- (BOOL)isHyperOutlineEnabled
{
    BOOL value = NO;
    [self getHyperOutlineEnabled:&value multipleValues:NULL];
    return value;
}

- (BOOL)isHyperCondensed
{
    BOOL value = NO;
    [self getHyperCondensed:&value multipleValues:NULL];
    return value;
}

- (BOOL)isHyperExpanded
{
    BOOL value = NO;
    [self getHyperExpanded:&value multipleValues:NULL];
    return value;
}

- (BOOL)isHyperUnderlined
{
    BOOL value = NO;
    [self getHyperUnderlined:&value multipleValues:NULL];
    return value;
}

- (BOOL)isHyperItalic
{
    BOOL value = NO;
    [self getHyperItalic:&value multipleValues:NULL];
    return value;
}

- (BOOL)isHyperBold
{
    BOOL value = NO;
    [self getHyperBold:&value multipleValues:NULL];
    return value;
}

- (CGFloat)hyperFontSize
{
    float value = 0;
    [self getHyperFontSize:&value multipleValues:NULL];
    return value;
}

- (id)hyperFontFamily
{
    id value = nil;
    [self getHyperFontFamily:&value multipleValues:NULL];
    return value;
}

- (id)hyperFont
{
    id value = nil;
    [self getHyperFont:&value multipleValues:NULL];
    return value;
}

@end
