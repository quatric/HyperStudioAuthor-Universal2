#import "KeynoteAngleGradient.h"

@implementation KeynoteAngleGradient

- (CGFloat)angle
{
    return [KeynoteTools angleAsDegreeWithAttributesDictionary:[self nodeAttributes]];
}

- (id)endColor
{
    NSArray *stops = [self keynoteObjectForXMLPath:@"./stops/gradient-stop"];
    for (int i = 0; i < (int)[stops count]; i++) {
        id color = [[stops objectAtIndex:i] endColor];
        if (color != nil)
            return color;
    }
    return nil;
}

- (id)startColor
{
    NSArray *stops = [self keynoteObjectForXMLPath:@"./stops/gradient-stop"];
    for (int i = 0; i < (int)[stops count]; i++) {
        id color = [[stops objectAtIndex:i] startColor];
        if (color != nil)
            return color;
    }
    return nil;
}

@end
