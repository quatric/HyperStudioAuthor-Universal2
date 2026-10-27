#import "KeynoteShadow.h"

@implementation KeynoteShadow

- (id)shadow
{
    SMKShadow *shadow = nil;
    id node = [self keynoteObjectForXMLPath:@"./shadow"];
    if (node != nil) {
        NSDictionary *attributes = [node nodeAttributes];
        id value = [attributes objectForKey:@"opacity"];
        float opacity = value != nil ? [value floatValue] : 0.0f;
        value = [attributes objectForKey:@"radius"];
        if (value != nil) {
            float radius = [value floatValue];
            if (radius > 0.0f && opacity > 0.0f) {
                float angle = [KeynoteTools angleWithAttributesDictionary:attributes];
                float offset = [[attributes objectForKey:@"offset"] floatValue];
                NSColor *color = [[node keynoteObjectForXMLPath:@"./color"] color];
                color = [color colorWithAlphaComponent:opacity * [color alphaComponent]];
                shadow = [SMKShadow new];
                [shadow setShadowColor:color];
                [shadow setShadowOffset:NSMakeSize(offset * cosf(angle), sinf(angle) * offset)];
                [shadow setShadowBlurRadius:radius];
            }
        }
    }
    return [shadow autorelease];
}

@end
