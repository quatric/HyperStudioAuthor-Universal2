#import "KeynoteGraphicStyle.h"

@implementation KeynoteGraphicStyle

- (CGFloat)opacity
{
    id child = [self deepStyleChildForXMLPath:@"./property-map/opacity"];

    if (child != nil) {
        id number = [[[child keynoteObjectForXMLPath:@"./number"] nodeAttributes] objectForKey:@"number"];
        if (number != nil)
            return [number floatValue];
    }
    return 1.0f;
}

- (id)stroke
{
    return [self deepStyleChildForXMLPath:@"./property-map/stroke"];
}

- (id)shadow
{
    id child = [self deepStyleChildForXMLPath:@"./property-map/shadow"];

    if (child != nil)
        return [child shadow];
    child = [self deepStyleChildForXMLPath:@"./property-map/filters/mutable-array/core-image-filter-info"];
    if (child != nil && [child isKindOfClass:[NSArray class]]) {
        NSUInteger count = [child count], i;
        for (i = 0; i < count; i++) {
            id shadow = [[child objectAtIndex:i] shadow];
            if (shadow != nil)
                return shadow;
        }
        return nil;
    }
    return [child shadow];
}

- (id)texturedFill
{
    return [[self deepStyleChildForXMLPath:@"./property-map/fill"] keynoteObjectForXMLPath:@"./textured-fill"];
}

- (id)angleGradient
{
    return [[self deepStyleChildForXMLPath:@"./property-map/fill"] keynoteObjectForXMLPath:@"./angle-gradient"];
}

- (id)fillColor
{
    return [(KeynoteColor *)[[self deepStyleChildForXMLPath:@"./property-map/fill"] keynoteObjectForXMLPath:@"./color"] color];
}

@end
