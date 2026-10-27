#import "KeynoteTools.h"

static NSDictionary *HSKeynoteClassNames = nil;

@implementation KeynoteTools

// Decodes "&#xHHHH;" character references left in Keynote strings.
+ (id)stringWithKeynoteString:(id)aString
{
    if (!aString)
        return nil;
    NSMutableString *result = [NSMutableString string];
    NSEnumerator *enumerator = [[aString componentsSeparatedByString:@"&#x"] objectEnumerator];
    [result appendString:[enumerator nextObject]];
    NSString *piece;
    while ((piece = [enumerator nextObject])) {
        NSString *code = [[piece componentsSeparatedByString:@";"] objectAtIndex:0];
        unichar character = [code hyperUnicharValue];
        NSString *characterString = [NSString stringWithCharacters:&character length:1];
        NSString *rest = [piece substringFromIndex:[@";" length] + [code length]];
        [result appendString:[characterString stringByAppendingString:rest]];
    }
    return result;
}

+ (Class)classForXMLTreeName:(id)aName
{
    id suffix = [self suffixForXMLTreeName:aName];
    Class aClass = NSClassFromString([[self classNamesForKeynote] objectForKey:suffix]);
    if (!aClass)
        aClass = [KeynoteObject class];
    return aClass;
}

+ (id)classNamesForKeynote
{
    if (!HSKeynoteClassNames)
        HSKeynoteClassNames = [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ClassNamesForKeynote" ofType:@"plist"]] retain];
    return HSKeynoteClassNames;
}

+ (id)parseSelectorNameSuffixForXMLTreeName:(id)aName
{
    return [self suffixForXMLTreeName:aName];
}

// "master-slide" becomes "MasterSlide".
+ (id)suffixForXMLTreeName:(id)aName
{
    if (!aName)
        return nil;
    NSMutableString *suffix = [NSMutableString stringWithString:[aName capitalizedString]];
    [suffix replaceOccurrencesOfString:@"-" withString:@"" options:0 range:NSMakeRange(0, [suffix length])];
    return suffix;
}

// Builds the attributed string from a Keynote style dictionary (font, colour,
// alignment, line spacing, paragraph spacing, tracking, underline, bold, italic).
+ (id)attributedStringFromString:(id)aString withStringAttributes:(id)aAttributes
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle new] autorelease];
    id fontSize = [aAttributes objectForKey:@"fontSize"];
    id fontName = [aAttributes objectForKey:@"fontName"];
    NSFont *font = nil;
    if (fontSize && fontName) {
        float size = [fontSize floatValue];
        font = [NSFont fontWithName:fontName size:size];
        if (!font)
            font = [NSFont systemFontOfSize:size];
        [attributes setObject:font forKey:NSFontAttributeName];
    }
    id alignment = [aAttributes objectForKey:@"alignment"];
    if (alignment) {
        [style setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
        [style setAlignment:[alignment intValue]];
    }
    id color = [aAttributes objectForKey:@"fontColor"];
    if (color)
        [attributes setObject:color forKey:NSForegroundColorAttributeName];
    id lineSpacing = [aAttributes objectForKey:@"lineSpacing"];
    if (lineSpacing) {
        float amount = [[lineSpacing objectForKey:@"amt"] floatValue];
        id mode = [lineSpacing objectForKey:@"mode"];
        if ([mode isEqualToString:@"relative"])
            amount = (amount + -1.0f) * [fontSize floatValue];
        else if ([mode isEqualToString:@"minimum"])
            amount = amount - [fontSize floatValue];
        else if (![mode isEqualToString:@"keynote"])
            amount = 0.0f;
        [style setLineSpacing:amount];
    }
    id spaceBefore = [aAttributes objectForKey:@"spaceBefore"];
    float before = spaceBefore ? [spaceBefore floatValue] : 0.0f;
    id spaceAfter = [aAttributes objectForKey:@"spaceAfter"];
    float after = spaceAfter ? [spaceAfter floatValue] : 0.0f;
    if (after <= before)
        after = before;
    [style setParagraphSpacing:after];
    id tracking = [aAttributes objectForKey:@"tracking"];
    if (tracking)
        [attributes setObject:[NSNumber numberWithFloat:[tracking floatValue] * [fontSize floatValue]] forKey:NSKernAttributeName];
    id underline = [aAttributes objectForKey:@"underline"];
    if (underline)
        [attributes setObject:[NSNumber numberWithInt:[underline intValue]] forKey:NSUnderlineStyleAttributeName];
    [attributes setObject:style forKey:NSParagraphStyleAttributeName];
    NSMutableAttributedString *result = [[[NSMutableAttributedString alloc] initWithString:aString attributes:attributes] autorelease];
    NSFontTraitMask traits = [[NSFontManager sharedFontManager] traitsOfFont:font];
    if ([[aAttributes objectForKey:@"bold"] isEqualToString:@"1"])
        traits = (traits & 0xfffffff9) + 2;
    else
        traits = traits | 4;
    if ([[aAttributes objectForKey:@"italic"] isEqualToString:@"1"])
        traits = (traits & 0xfefffffe) + 1;
    else
        traits = traits | 0x1000000;
    [result applyFontTraits:traits range:NSMakeRange(0, [result length])];
    return result;
}

+ (NSInteger)playLoopModeWithAttributesDictionary:(id)aDictionary
{
    id looping = [aDictionary objectForKey:@"looping"];
    if ([looping isEqualToString:@"yes"])
        return 1;
    return [looping isEqualToString:@"palindrome"] ? 2 : 0;
}

+ (id)pathWithAttributesDictionary:(id)aDictionary
{
    return [self stringWithKeynoteString:[aDictionary objectForKey:@"path"]];
}

+ (BOOL)verticalFlipWithAttributesDictionary:(id)aDictionary
{
    return [[aDictionary objectForKey:@"verticalFlip"] isEqualToString:@"true"];
}

+ (BOOL)horizontalFlipWithAttributesDictionary:(id)aDictionary
{
    return [[aDictionary objectForKey:@"horizontalFlip"] isEqualToString:@"true"];
}

+ (NSInteger)fractionWithAttributesDictionary:(id)aDictionary
{
    return [[aDictionary objectForKey:@"fraction"] intValue];
}

+ (NSInteger)scaleTypeWithAttributesDictionary:(id)aDictionary
{
    id technique = [aDictionary objectForKey:@"technique"];
    if ([technique isEqualToString:@"fill"])
        return 2;
    if ([technique isEqualToString:@"fit"])
        return 0;
    if ([technique isEqualToString:@"stretch"])
        return 3;
    if ([technique isEqualToString:@"natural"])
        return 4;
    return [technique isEqualToString:@"tile"] ? 5 : -1;
}

+ (CGFloat)angleWithAttributesDictionary:(id)aDictionary
{
    id angle = [aDictionary objectForKey:@"angle"];
    if (!angle)
        return 0.0f;
    return [self angleWithFloat:[angle floatValue]];
}

+ (CGFloat)angleWithFloat:(CGFloat)aFloat
{
    return ((360.0f - (float)aFloat) / 180.0f) * 3.1415927f;
}

+ (CGFloat)angleAsDegreeWithAttributesDictionary:(id)aDictionary
{
    id angle = [aDictionary objectForKey:@"angle"];
    if (!angle)
        return 0.0f;
    return [self angleAsDegreeWithFloat:[angle floatValue]];
}

+ (CGFloat)angleAsDegreeWithFloat:(CGFloat)aFloat
{
    return ((float)aFloat / 3.1415927f) * 180.0f;
}

+ (NSPoint)pointWithAttributesDictionary:(id)aDictionary
{
    float y = [[aDictionary objectForKey:@"y"] floatValue];
    float x = [[aDictionary objectForKey:@"x"] floatValue];
    return NSMakePoint(x, y);
}

+ (NSSize)sizeWithAttributesDictionary:(id)aDictionary
{
    float height = [[aDictionary objectForKey:@"h"] floatValue];
    float width = [[aDictionary objectForKey:@"w"] floatValue];
    return NSMakeSize(width, height);
}

@end
