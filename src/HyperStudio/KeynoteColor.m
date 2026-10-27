#import "KeynoteColor.h"

@implementation KeynoteColor

- (id)color
{
    NSDictionary *attributes = [self nodeAttributes];
    id white = [attributes objectForKey:@"w"];
    if (white != nil)
        return [NSColor colorWithCalibratedWhite:[white floatValue] alpha:[self valueForColorComponentName:@"a" dictionary:attributes]];
    CGFloat red = [self valueForColorComponentName:@"r" dictionary:attributes];
    CGFloat green = [self valueForColorComponentName:@"g" dictionary:attributes];
    CGFloat blue = [self valueForColorComponentName:@"b" dictionary:attributes];
    CGFloat alpha = [self valueForColorComponentName:@"a" dictionary:attributes];
    return [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:alpha];
}

- (CGFloat)valueForColorComponentName:(id)aName dictionary:(id)aDictionary
{
    id value = [aDictionary objectForKey:aName];
    return value != nil ? [value floatValue] : 0.0f;
}

@end
