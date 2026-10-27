#import "NSMutableAttributedString+EXAttributedString.h"
// Attributed strings stored as an array of runs ({string, attributes}), with
// only the storable attributes, values in their extra dictionary form.
@implementation NSMutableAttributedString (EXAttributedString)
- (void)replaceOccurencesOfString:(id)aString withString:(id)aString2
{
    NSMutableString *string = [self mutableString];
    NSRange range;
    while ((range = [string rangeOfString:aString]).location != NSNotFound)
        [self replaceCharactersInRange:range withString:aString2];
}
@end
@implementation NSAttributedString (EXAttributedString)
+ (id)hyperAcceptableStringAttributesForStoring
{
    return [NSArray arrayWithObjects:NSBackgroundColorAttributeName, NSBaselineOffsetAttributeName, NSExpansionAttributeName,
                                     NSFontAttributeName, NSForegroundColorAttributeName, NSKernAttributeName,
                                     NSLigatureAttributeName, NSObliquenessAttributeName, NSParagraphStyleAttributeName,
                                     NSShadowAttributeName, NSStrikethroughColorAttributeName, NSStrikethroughStyleAttributeName,
                                     NSStrokeColorAttributeName, NSStrokeWidthAttributeName, NSSuperscriptAttributeName,
                                     NSToolTipAttributeName, NSUnderlineColorAttributeName, NSUnderlineStyleAttributeName,
                                     NSLinkAttributeName, nil];
}
// The image as a TIFF attachment.
+ (id)extraAttributedStringWithImage:(id)aImage
{
    NSFileWrapper *wrapper = [[[NSFileWrapper alloc] initRegularFileWithContents:[aImage TIFFRepresentation]] autorelease];
    [wrapper setPreferredFilename:@"image.tiff"];
    NSTextAttachment *attachment = [[[NSTextAttachment alloc] initWithFileWrapper:wrapper] autorelease];
    return [self attributedStringWithAttachment:attachment];
}
- (BOOL)isExtraEqualToAttributedString:(id)aString
{
    return [[self hyperArrayRepresentation] isEqualToArray:[aString hyperArrayRepresentation]];
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray array];
}
- (id)extraDictionaryRepresentationWithCodingContext:(id)aContext
{
    return [NSDictionary dictionaryWithObjectsAndKeys:NSStringFromClass([NSAttributedString class]), EXClassNameKey,
                                                      [self hyperArrayRepresentation], @"attributedString", nil];
}
// Rebuilt run by run (a run whose attributes fail keeps its string); returns
// an immutable copy in place of self.
- (id)initWithExtraDictionary:(id)aDictionary codingContext:(id)aContext
{
    NSArray *runs = [aDictionary objectForKey:@"attributedString"];
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] init];
    if (result == nil)
        NSLog(@"Can't init empty attributed string");
    for (NSDictionary *run in runs) {
        NSString *string = [run objectForKey:@"string"];
        NSDictionary *attributes = [self hyperAttributesFromDictionaryRepresentation:[run objectForKey:@"attributes"]];
        NSAttributedString *part = [[NSAttributedString alloc] initWithString:string attributes:attributes];
        if (part == nil) {
            if ([string length] != 0)
                NSLog(@"Can't init attributed string (%@) with attributes: %@", string, attributes);
            part = [[NSAttributedString alloc] initWithString:string];
        }
        if (part == nil)
            NSLog(@"Can't init attributed string with string: %@", string);
        [result appendAttributedString:part];
        [part release];
    }
    // logged before the release (the original logs the released string)
    id copy = [result copy];
    if (copy == nil)
        NSLog(@"Can't copy attributed string: %@", result);
    [result release];
    [self release];
    return copy;
}
- (BOOL)canBeExtraPostLoaded
{
    return NO;
}
- (id)hyperArrayRepresentation
{
    NSMutableArray *runs = [NSMutableArray array];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSUInteger length = [self length];
    NSRange range = NSMakeRange(0, 0);
    while (NSMaxRange(range) < length) {
        NSUInteger index = NSMaxRange(range);
        NSDictionary *attributes = [self attributesAtIndex:index longestEffectiveRange:&range inRange:NSMakeRange(index, length - index)];
        NSDictionary *stored = [self hyperDictionaryRepresentationFromAttributes:attributes];
        NSString *string = [[self attributedSubstringFromRange:range] string];
        [runs addObject:[NSDictionary dictionaryWithObjectsAndKeys:string, @"string", stored, @"attributes", nil]];
    }
    [pool release];
    return [[runs copy] autorelease];
}
// Values stored as extra dictionaries become objects again (dropped when
// they can't).
- (id)hyperAttributesFromDictionaryRepresentation:(id)aRepresentation
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    for (id key in aRepresentation) {
        id value = [aRepresentation objectForKey:key];
        if ([value isKindOfClass:[NSDictionary class]])
            value = [NSObject objectWithExtraDictionary:value];
        if (value != nil)
            [attributes setObject:value forKey:key];
    }
    return [[attributes copy] autorelease];
}
- (id)hyperDictionaryRepresentationFromAttributes:(id)aAttributes
{
    NSMutableDictionary *stored = [NSMutableDictionary dictionary];
    NSArray *acceptable = [NSAttributedString hyperAcceptableStringAttributesForStoring];
    for (id key in aAttributes) {
        if (![acceptable containsObject:key])
            continue;
        id value = [aAttributes objectForKey:key];
        id dictionary = [value extraDictionaryRepresentation];
        [stored setObject:dictionary != nil ? dictionary : value forKey:key];
    }
    return [[stored copy] autorelease];
}
@end
