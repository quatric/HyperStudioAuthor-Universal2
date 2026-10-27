#import "NSFont+EXFont.h"
@implementation NSFont (EXFont)
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray array];
}
- (id)extraDictionaryRepresentationWithCodingContext:(id)aContext
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
        NSStringFromClass([NSFont class]), EXClassNameKey,
        [self fontName], @"fontName",
        [NSNumber numberWithFloat:[self pointSize]], @"pointSize",
        [self displayName], @"displayName",
        [self familyName], @"familyName",
        nil];
}
- (id)initWithExtraDictionary:(id)aDictionary codingContext:(id)aContext
{
    // Fonts are shared: drop the allocated instance and return the named font,
    // a font matching the stored description (Helvetica as replacement), or the
    // user font, in that order.
    [self release];
    NSNumber *pointSize = [aDictionary objectForKey:@"pointSize"];
    CGFloat size = pointSize != nil ? [pointSize floatValue] : 11.0f;
    NSFont *font = [[NSFont fontWithName:[aDictionary objectForKey:@"fontName"] size:size] retain];
    if (font == nil)
        font = [[NSFont convertedFontWithDictionary:aDictionary replacementFontName:@"Helvetica"] retain];
    if (font == nil)
        font = [[NSFont userFontOfSize:size] retain];
    return font;
}
- (BOOL)canBeExtraPostLoaded
{
    return NO;
}
@end
