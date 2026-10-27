#import "NSColor+EXColorValue.h"
// Colors stored as sRGB components (colorType 0) or a pattern image as PNG
// (colorType 1).
@implementation NSColor (EXColorValue)
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray array];
}
- (id)extraDictionaryRepresentationWithCodingContext:(id)aContext
{
    if ([self shouldUseHyperDefaultImplementationForKeyValueCoding])
        return [super extraDictionaryRepresentationWithCodingContext:aContext];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSString *className = NSStringFromClass([NSColor class]);
    if (className == nil)
        return dictionary;
    [dictionary setObject:className forKey:EXClassNameKey];
    int type;
    if ([[self colorSpaceName] isEqualToString:NSPatternColorSpace]) {
        // (Skipped when the image has no PNG, where the original raised.)
        NSData *png = [[self patternImage] hyperPNGRepresentation];
        if (png != nil)
            [dictionary setObject:png forKey:@"patternImagePNGRepresentation"];
        type = 1;
    } else {
        CGFloat components[4] = { 0, 0, 0, 0 };
        [[self colorUsingColorSpace:[NSColorSpace sRGBColorSpace]] getComponents:components];
        [dictionary setObject:[NSNumber numberWithFloat:components[0]] forKey:@"redComponent"];
        [dictionary setObject:[NSNumber numberWithFloat:components[1]] forKey:@"greenComponent"];
        [dictionary setObject:[NSNumber numberWithFloat:components[2]] forKey:@"blueComponent"];
        [dictionary setObject:[NSNumber numberWithFloat:components[3]] forKey:@"alphaComponent"];
        type = 0;
    }
    [dictionary setObject:[NSNumber numberWithInt:type] forKey:@"colorType"];
    return dictionary;
}
// Replaces self with the stored color (pattern images may be TIFF in older
// files).
- (id)initWithExtraDictionary:(id)aDictionary codingContext:(id)aContext
{
    if ([self shouldUseHyperDefaultImplementationForKeyValueCoding])
        return [super initWithExtraDictionary:aDictionary codingContext:aContext];
    [self release];
    if ([[aDictionary objectForKey:@"colorType"] intValue] == 0) {
        NSColorSpace *space = [NSColorSpace sRGBColorSpace];
        if (space == nil)
            return nil;
        CGFloat components[4] = {
            [[aDictionary objectForKey:@"redComponent"] floatValue],
            [[aDictionary objectForKey:@"greenComponent"] floatValue],
            [[aDictionary objectForKey:@"blueComponent"] floatValue],
            [[aDictionary objectForKey:@"alphaComponent"] floatValue] };
        return [[NSColor colorWithColorSpace:space components:components count:4] retain];
    }
    NSData *data = [aDictionary objectForKey:@"patternImagePNGRepresentation"];
    if (data == nil)
        data = [aDictionary objectForKey:@"patternImageTIFFRepresentation"];
    if (data == nil)
        return nil;
    NSImage *image = [[NSImage alloc] initWithData:data];
    if (image == nil)
        return nil;
    NSColor *color = [[NSColor colorWithPatternImage:image] retain];
    [image release];
    return color;
}
- (BOOL)shouldUseHyperDefaultImplementationForKeyValueCoding
{
    return NO;
}
- (BOOL)canBeExtraPostLoaded
{
    return NO;
}
@end

@implementation NSDictionary (EXColorValue)
+ (id)extraDictionaryWithColor:(id)aColor
{
    return [aColor extraDictionaryRepresentation];
}
@end

@implementation NSObject (EXColorValue)
- (id)extraColorValueForKey:(id)aKey
{
    return [[self safeExtraValueForKey:aKey] extraColorValue];
}
// A dictionary of calibrated components.
- (id)extraColorValue
{
    return [NSColor colorWithCalibratedRed:[(id)self extraFloatForKey:@"redComponent"]
                                     green:[(id)self extraFloatForKey:@"greenComponent"]
                                      blue:[(id)self extraFloatForKey:@"blueComponent"]
                                     alpha:[(id)self extraFloatForKey:@"alphaComponent"]];
}
@end
