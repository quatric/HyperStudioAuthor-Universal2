#import "HSHTML5ExporterHelper.h"
@implementation HSHTML5ExporterHelper
// Moves each "; line-height: ..." of a style after the "font: ..." that
// follows it (browsers let the font shorthand reset the line height), and
// shortens the tab spans' class.
+ (id)HTMLStringAdaptedToBrowsersSpecific:(id)aSpecific
{
    NSMutableString *result = [NSMutableString string];
    NSScanner *scanner = [NSScanner scannerWithString:aSpecific];
    [scanner setCharactersToBeSkipped:nil];
    NSCharacterSet *ends = [NSCharacterSet characterSetWithCharactersInString:@";\""];
    // (Strings not found are skipped; the original appended nil.)
#define HSAppend(aString, aPart) do { if ((aPart) != nil) [(aString) appendString:(aPart)]; } while (0)
    while (![scanner isAtEnd]) {
        NSString *part = nil;
        [scanner scanUpToString:@"; line-height: " intoString:&part];
        HSAppend(result, part);
        if (![scanner scanString:@"; line-height: " intoString:&part])
            break;
        NSMutableString *lineHeight = [NSMutableString string];
        HSAppend(lineHeight, part);
        [scanner scanUpToCharactersFromSet:ends intoString:&part];
        HSAppend(lineHeight, part);
        [scanner scanUpToString:@"font: " intoString:&part];
        HSAppend(result, part);
        [scanner scanUpToCharactersFromSet:ends intoString:&part];
        HSAppend(result, part);
        [result appendString:lineHeight];
        [scanner scanCharactersFromSet:ends intoString:&part];
        HSAppend(result, part);
    }
#undef HSAppend
    [result replaceOccurrencesOfString:@"class=\"Apple-tab-span\" style=\"white-space:pre\">" withString:@"c"
                               options:NSCaseInsensitiveSearch range:NSMakeRange(0, [result length])];
    return [[result copy] autorelease];
}
+ (id)HTML5StringWithAttributedString:(id)aString
{
    if ([aString length] == 0)
        return nil;
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [attributes setObject:[NSArray arrayWithObjects:@"XML", @"APPLET", @"BASEFONT", @"DIR", @"FONT", @"ISINDEX", @"MENU",
                           @"S", @"STRIKE", @"U", @"CENTER", @"HEAD", @"HTML", @"BODY", nil]
                   forKey:NSExcludedElementsDocumentAttribute];
    [attributes setObject:NSHTMLTextDocumentType forKey:NSDocumentTypeDocumentOption];
    NSData *data = [aString dataFromRange:NSMakeRange(0, [aString length]) documentAttributes:attributes error:NULL];
    if (data == nil)
        return nil;
    NSString *HTML = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    return [HSHTML5ExporterHelper HTMLStringAdaptedToBrowsersSpecific:HTML];
}
// "rgba(r,g,b,a)".
+ (id)HTMLStringWithRGBAColor:(id)aColor
{
    NSColor *color = [aColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    if (color == nil)
        return nil;
    NSMutableString *string = [NSMutableString stringWithString:@"rgba("];
    CGFloat components[4] = { 0, 0, 0, 0 };
    [color getRed:&components[0] green:&components[1] blue:&components[2] alpha:&components[3]];
    for (int i = 0; i < 3; i++)
        [string appendString:[NSString stringWithFormat:@"%d,", (int)(float)(components[i] * 255.0f)]];
    [string appendString:[NSString stringWithFormat:@"%f)", components[3]]];
    return string;
}
// "#rrggbb".
+ (id)HTMLStringWithColor:(id)aColor
{
    NSColor *color = [aColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    if (color == nil)
        return nil;
    NSMutableString *string = [NSMutableString stringWithString:@"#"];
    CGFloat components[4] = { 0, 0, 0, 0 };
    [color getRed:&components[0] green:&components[1] blue:&components[2] alpha:&components[3]];
    for (int i = 0; i < 3; i++)
        [string appendString:[NSString stringWithFormat:@"%02x", (int)(float)(components[i] * 255.0f)]];
    return string;
}
// The card's default background image, drawn at its size.
+ (id)defaultCardBackgroundImageForCard:(id)aCard
{
    NSSize size = [(id<HSSizeAttributes>)[aCard queryHyperInterface:@protocol(HSSizeAttributes)] size];
    Protocol *required[2] = { @protocol(BTCGImage), nil };
    id image = [[aCard queryHyperInterface:@protocol(HSEditableImageAttributes)] queryImageWithRequiredProtocols:required optionalProtocols:NULL];
    if (image == nil)
        return nil;
    NSImage *result = [[NSImage alloc] initWithSize:size];
    [result lockFocus];
    [image drawInCGContext:[[NSGraphicsContext currentContext] CGContext] atPoint:CGPointZero];
    [result unlockFocus];
    return [result autorelease];
}
// The media's UID with its type as extension (a four char code type made
// an extension); AAC files get "m4a".
+ (id)JSonCorrectFilenameForMedia:(id)aMedia andDocumentType:(id)aType
{
    NSString *filename = [[[aMedia mediaUID] stringValue] lowercaseString];
    NSString *extension = [aMedia mediaType];
    if (extension == nil)
        return filename;
    unsigned int code = (unsigned int)[extension extraFourCharCode];
    if (code != 0 && [extension hasPrefix:@"'"])
        extension = [HSNewMediaAccessor extensionForHFSType:[NSNumber numberWithUnsignedLong:code]];
    // (The original turned "m4a" into "aac" outside iBooks Author documents
    // and then every "aac" back into "m4a".)
    if (![aType isEqualToString:@"HSiBooksAuthorDocumentType"] && [extension isEqualToString:@"m4a"])
        extension = @"aac";
    return [filename stringByAppendingPathExtension:[extension isEqualToString:@"aac"] ? @"m4a" : extension];
}
+ (id)JSonCorrectFilenameForMedia:(id)aMedia
{
    return [[self class] JSonCorrectFilenameForMedia:aMedia andDocumentType:nil];
}
// Lowercase letters, digits, "-" and "_" only.
+ (id)JSonCorrectFilenameWithString:(id)aString
{
    NSMutableCharacterSet *allowed = [NSMutableCharacterSet characterSetWithCharactersInString:@"-_"];
    [allowed formUnionWithCharacterSet:[NSCharacterSet lowercaseLetterCharacterSet]];
    [allowed formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
    [allowed invert];
    return [[aString lowercaseString] hyperStringByRemovingCharactersInSet:allowed];
}
// The relative paths of everything in the HTML5Template resources folder.
+ (id)HTML5TemplateResourcesURLs
{
    static NSSet *sResourcesURLs;
    if (sResourcesURLs == nil) {
        NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"HTML5Template"];
        sResourcesURLs = [[NSSet alloc] initWithArray:[[NSFileManager defaultManager] subpathsOfDirectoryAtPath:path error:NULL]];
    }
    return sResourcesURLs;
}

@end
