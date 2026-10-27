#import "NSFont+HSFont.h"
@implementation NSFont (HSFont)
+ (id)convertedFontWithDictionary:(id)aDictionary replacementFontName:(id)aName
{
    // the font name is "Family-Style[-Style]" with Bold / Italic styles
    NSString *fontName = [aDictionary objectForKey:HSFontNameKey];
    NSNumber *pointSize = [aDictionary objectForKey:HSFontPointSizeKey];
    float size = pointSize != nil ? [pointSize floatValue] : 11.0f;
    BOOL bold = NO, italic = NO;
    if (fontName != nil) {
        NSScanner *scanner = [NSScanner scannerWithString:fontName];
        NSCharacterSet *dash = [NSCharacterSet characterSetWithCharactersInString:@"-"];
        [scanner scanUpToCharactersFromSet:dash intoString:NULL];
        [scanner scanCharactersFromSet:dash intoString:NULL];
        for (int style = 0; style < 2 && ![scanner isAtEnd]; style++) {
            NSString *word = nil;
            [scanner scanUpToCharactersFromSet:dash intoString:&word];
            if ([word isEqualToString:@"Bold"])
                bold = YES;
            else if ([word isEqualToString:@"Italic"])
                italic = YES;
            [scanner scanCharactersFromSet:dash intoString:NULL];
        }
    }
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:[aDictionary objectForKey:HSFontFamilyNameKey]
                                                           forKey:NSFontFamilyAttribute];
    NSFontDescriptor *descriptor = [NSFontDescriptor fontDescriptorWithFontAttributes:attributes];
    NSFont *font = descriptor != nil ? [NSFont fontWithDescriptor:descriptor size:size] : nil;
    NSFontTraitMask traits = (bold ? NSBoldFontMask : 0) | (italic ? NSItalicFontMask : 0);
    if (traits != 0) {
        NSFont *converted = [[NSFontManager sharedFontManager] convertFont:font toHaveTrait:traits];
        if (converted != nil)
            font = converted;
    }
    // as in the original, the fallback is always the default font, not aName
    if (font == nil && aName != nil) {
        NSFont *fallback = [NSFont fontWithName:HSDefaultFontName size:size];
        if (fallback != nil)
            font = [[NSFontManager sharedFontManager] convertFont:fallback toHaveTrait:traits];
    }
    return font;
}
+ (id)convertedFontWithDictionary:(id)aDictionary
{
    return [self convertedFontWithDictionary:aDictionary replacementFontName:nil];
}
+ (CGFloat)systemHyperFontSizeForControlSize:(NSUInteger)aSize
{
    return [NSFont systemFontSizeForControlSize:aSize];
}
@end
