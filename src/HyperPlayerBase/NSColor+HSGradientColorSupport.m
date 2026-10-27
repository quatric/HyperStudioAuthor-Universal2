#import "NSColor+HSGradientColorSupport.h"
@implementation NSColor (HSGradientColorSupport)
- (id)hyperGradientColor
{
    return [self isKindOfClass:[HSGradientColor class]] ? self : nil;
}
@end
@implementation NSColor (HSExtensions)
// {w, a} for a gray, else {r, g, b, a} (missing components are 0).
+ (id)hyperColorWithDictionary:(id)aDictionary
{
    id white = [aDictionary objectForKey:@"w"];
    if (white != nil)
        return [NSColor colorWithCalibratedWhite:[white floatValue]
                                           alpha:[NSColor hyperValueForColorComponentName:@"a" dictionary:aDictionary]];
    return [NSColor colorWithCalibratedRed:[NSColor hyperValueForColorComponentName:@"r" dictionary:aDictionary]
                                     green:[NSColor hyperValueForColorComponentName:@"g" dictionary:aDictionary]
                                      blue:[NSColor hyperValueForColorComponentName:@"b" dictionary:aDictionary]
                                     alpha:[NSColor hyperValueForColorComponentName:@"a" dictionary:aDictionary]];
}
+ (CGFloat)hyperValueForColorComponentName:(id)aName dictionary:(id)aDictionary
{
    id value = [aDictionary objectForKey:aName];
    return value != nil ? [value floatValue] : 0.0f;
}
// "r g b [a]", or "g<white> [a]" for a gray (device RGB, alpha 1 by default).
+ (id)hyperColorWithString:(id)aString
{
    if (aString == nil)
        return nil;
    float components[4] = { 0, 0, 0, 1 };
    NSEnumerator *values = [[aString componentsSeparatedByString:@" "] objectEnumerator];
    int index = 0;
    if ([aString hasPrefix:@"g"]) {
        float white = [[[values nextObject] substringFromIndex:1] floatValue];
        components[0] = components[1] = components[2] = white;
        index = 3;
    }
    id value;
    // The original wrote past the four components for longer strings; extra
    // values are ignored here.
    while ((value = [values nextObject]) != nil) {
        if (index < 4)
            components[index] = [value floatValue];
        index++;
    }
    return [NSColor colorWithDeviceRed:components[0] green:components[1] blue:components[2] alpha:components[3]];
}
- (id)hyperStringRepresentation
{
    return [NSString stringWithFormat:@"%f %f %f %f", [self redComponent], [self greenComponent], [self blueComponent], [self alphaComponent]];
}
@end

@implementation NSColor (HSPDFTexturedColor)

// A pattern color is re-created from the PDF data of its pattern image so
// that it stays vector in saved output; nil for other colors.
- (id)hyperPDFColor
{
    if (![[self colorSpaceName] isEqualToString:NSPatternColorSpace])
        return nil;
    NSImage *image = [self patternImage];
    [image lockFocus];
    NSRect rect = NSMakeRect(0, 0, [image size].width, [image size].height);
    NSImageView *view = [[NSImageView alloc] initWithFrame:rect];
    [view setImage:image];
    [view setFrame:rect];
    NSData *data = [view dataWithPDFInsideRect:rect];
    NSImage *pdfImage = [[NSImage alloc] initWithData:data];
    NSColor *color = [NSColor colorWithPatternImage:pdfImage];
    [view release];
    [pdfImage release];
    [image unlockFocus];
    return color;
}

@end
