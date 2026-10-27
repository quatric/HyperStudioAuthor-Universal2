#import "KeynoteGradientStop.h"

@implementation KeynoteGradientStop

- (id)endColor
{
    if ([KeynoteTools fractionWithAttributesDictionary:[self nodeAttributes]] != 1)
        return nil;
    return [(KeynoteColor *)[self keynoteObjectForXMLPath:@"./color"] color];
}

- (id)startColor
{
    if ([KeynoteTools fractionWithAttributesDictionary:[self nodeAttributes]] != 0)
        return nil;
    return [(KeynoteColor *)[self keynoteObjectForXMLPath:@"./color"] color];
}

@end
